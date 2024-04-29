--------------------------------------------------------
--  DDL for Package Body BEN_CWB_PERSON_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_PERSON_INFO_API" as
/* $Header: becpiapi.pkb 120.1 2005/06/29 04:25:24 steotia noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  BEN_CWB_PERSON_INFO_API.';
g_debug boolean := hr_utility.debug_enabled;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_audit_record >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
-- This is an internal procedure to write into the BEN_CWB_AUDIT table to
-- record particular changes in the values of BEN_CWB_PERSON_RATES.
-- Changes evaluated:
-- Code              Desciption
-- BS               Update Base Salary
-- CM               Update Employee Notes
-- CF1-30           Update CPI Flex 1-30
-- CU1-20           Update Custom Segment 1-20
--
procedure create_audit_record
         (p_info_old ben_cwb_person_info%rowtype
         ) is

   l_info_new ben_cwb_person_info%rowtype;
   l_cwb_audit_id ben_cwb_audit.cwb_audit_id%type;
   l_object_version_number ben_cwb_audit.object_version_number%type;
   l_cd_meaning_old hr_lookups.meaning%type;
   l_cd_meaning_new hr_lookups.meaning%type;
   l_group_pl_id ben_cwb_audit.group_pl_id%type;
   l_lf_evt_ocrd_dt ben_cwb_audit.lf_evt_ocrd_dt%type;
   l_group_oipl_id ben_cwb_audit.group_oipl_id%type;
   l_person_id fnd_user.employee_id%type;
   old_ws_comments ben_cwb_audit.old_val_varchar%type;

    begin

      select * into l_info_new
      from ben_cwb_person_info
      where group_per_in_ler_id = p_info_old.group_per_in_ler_id;

      select group_pl_id,lf_evt_ocrd_dt
      into l_group_pl_id, l_lf_evt_ocrd_dt
      from ben_per_in_ler
      where per_in_ler_id = p_info_old.group_per_in_ler_id;

      l_group_oipl_id := -1;

      select employee_id into l_person_id
      from fnd_user
      where user_id = l_info_new.last_updated_by;

      if(  ((p_info_old.base_salary is null)
         and (l_info_new.base_salary is not null))
        or ((l_info_new.base_salary is null)
	 and (p_info_old.base_salary is not null))
	or (p_info_old.base_salary <> l_info_new.base_salary) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('BS')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'BS'
            ,p_old_val_number           => p_info_old.base_salary
            ,p_new_val_number           => l_info_new.base_salary
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if(  ((p_info_old.ws_comments is null)
          and (l_info_new.ws_comments is not null))
        or ((l_info_new.ws_comments is null)
	  and (p_info_old.ws_comments is not null))
	or (p_info_old.ws_comments <> l_info_new.ws_comments) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CM')=true) then

	  if length(p_info_old.ws_comments) > 190 then
	   old_ws_comments := substr(p_info_old.ws_comments,0,190)||'...';
	  else
	   old_ws_comments := p_info_old.ws_comments;
	  end if;

	  if length(l_info_new.ws_comments) > 190 then
	   l_info_new.ws_comments := substr(l_info_new.ws_comments,0,190)||'...';
	  end if;

	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CM'
            ,p_old_val_varchar          => old_ws_comments
            ,p_new_val_varchar          => l_info_new.ws_comments
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute1 is null)
         and (l_info_new.cpi_attribute1 is not null))
        or ((l_info_new.cpi_attribute1 is null)
	 and (p_info_old.cpi_attribute1 is not null))
	or (p_info_old.cpi_attribute1 <> l_info_new.cpi_attribute1) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF1')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF1'
            ,p_old_val_varchar          => p_info_old.cpi_attribute1
            ,p_new_val_varchar          => l_info_new.cpi_attribute1
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute2 is null)
         and (l_info_new.cpi_attribute2 is not null))
        or ((l_info_new.cpi_attribute2 is null)
	 and (p_info_old.cpi_attribute2 is not null))
	or (p_info_old.cpi_attribute2 <> l_info_new.cpi_attribute2) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF2')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF2'
            ,p_old_val_varchar          => p_info_old.cpi_attribute2
            ,p_new_val_varchar          => l_info_new.cpi_attribute2
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute3 is null)
         and (l_info_new.cpi_attribute3 is not null))
        or ((l_info_new.cpi_attribute3 is null)
	 and (p_info_old.cpi_attribute3 is not null))
	or (p_info_old.cpi_attribute3 <> l_info_new.cpi_attribute3) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF3')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF3'
            ,p_old_val_varchar          => p_info_old.cpi_attribute3
            ,p_new_val_varchar          => l_info_new.cpi_attribute3
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute4 is null)
         and (l_info_new.cpi_attribute4 is not null))
        or ((l_info_new.cpi_attribute4 is null)
	 and (p_info_old.cpi_attribute4 is not null))
	or (p_info_old.cpi_attribute4 <> l_info_new.cpi_attribute4) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF4')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF4'
            ,p_old_val_varchar          => p_info_old.cpi_attribute4
            ,p_new_val_varchar          => l_info_new.cpi_attribute4
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute5 is null)
         and (l_info_new.cpi_attribute5 is not null))
        or ((l_info_new.cpi_attribute5 is null)
	 and (p_info_old.cpi_attribute5 is not null))
	or (p_info_old.cpi_attribute5 <> l_info_new.cpi_attribute5) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF5')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF5'
            ,p_old_val_varchar          => p_info_old.cpi_attribute5
            ,p_new_val_varchar          => l_info_new.cpi_attribute5
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute6 is null)
         and (l_info_new.cpi_attribute6 is not null))
        or ((l_info_new.cpi_attribute6 is null)
	 and (p_info_old.cpi_attribute6 is not null))
	or (p_info_old.cpi_attribute6 <> l_info_new.cpi_attribute6) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF6')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF6'
            ,p_old_val_varchar          => p_info_old.cpi_attribute6
            ,p_new_val_varchar          => l_info_new.cpi_attribute6
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute7 is null)
         and (l_info_new.cpi_attribute7 is not null))
        or ((l_info_new.cpi_attribute7 is null)
	 and (p_info_old.cpi_attribute7 is not null))
	or (p_info_old.cpi_attribute7 <> l_info_new.cpi_attribute7) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF7')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF7'
            ,p_old_val_varchar          => p_info_old.cpi_attribute7
            ,p_new_val_varchar          => l_info_new.cpi_attribute7
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute8 is null)
         and (l_info_new.cpi_attribute8 is not null))
        or ((l_info_new.cpi_attribute8 is null)
	 and (p_info_old.cpi_attribute8 is not null))
	or (p_info_old.cpi_attribute8 <> l_info_new.cpi_attribute8) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF8')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF8'
            ,p_old_val_varchar          => p_info_old.cpi_attribute8
            ,p_new_val_varchar          => l_info_new.cpi_attribute8
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute9 is null)
         and (l_info_new.cpi_attribute9 is not null))
        or ((l_info_new.cpi_attribute9 is null)
	 and (p_info_old.cpi_attribute9 is not null))
	or (p_info_old.cpi_attribute9 <> l_info_new.cpi_attribute9) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF9')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF9'
            ,p_old_val_varchar          => p_info_old.cpi_attribute9
            ,p_new_val_varchar          => l_info_new.cpi_attribute9
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute10 is null)
         and (l_info_new.cpi_attribute10 is not null))
        or ((l_info_new.cpi_attribute10 is null)
	 and (p_info_old.cpi_attribute10 is not null))
	or (p_info_old.cpi_attribute10 <> l_info_new.cpi_attribute10) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF10')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF10'
            ,p_old_val_varchar          => p_info_old.cpi_attribute10
            ,p_new_val_varchar          => l_info_new.cpi_attribute10
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute11 is null)
         and (l_info_new.cpi_attribute11 is not null))
        or ((l_info_new.cpi_attribute11 is null)
	 and (p_info_old.cpi_attribute11 is not null))
	or (p_info_old.cpi_attribute11 <> l_info_new.cpi_attribute11) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF11')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF11'
            ,p_old_val_varchar          => p_info_old.cpi_attribute11
            ,p_new_val_varchar          => l_info_new.cpi_attribute11
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute12 is null)
         and (l_info_new.cpi_attribute12 is not null))
        or ((l_info_new.cpi_attribute12 is null)
	 and (p_info_old.cpi_attribute12 is not null))
	or (p_info_old.cpi_attribute12 <> l_info_new.cpi_attribute12) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF12')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF12'
            ,p_old_val_varchar          => p_info_old.cpi_attribute12
            ,p_new_val_varchar          => l_info_new.cpi_attribute12
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute13 is null)
         and (l_info_new.cpi_attribute13 is not null))
        or ((l_info_new.cpi_attribute13 is null)
	 and (p_info_old.cpi_attribute13 is not null))
	or (p_info_old.cpi_attribute13 <> l_info_new.cpi_attribute13) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF13')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF13'
            ,p_old_val_varchar          => p_info_old.cpi_attribute13
            ,p_new_val_varchar          => l_info_new.cpi_attribute13
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute14 is null)
         and (l_info_new.cpi_attribute14 is not null))
        or ((l_info_new.cpi_attribute14 is null)
	 and (p_info_old.cpi_attribute14 is not null))
	or (p_info_old.cpi_attribute14 <> l_info_new.cpi_attribute14) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF14')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF14'
            ,p_old_val_varchar          => p_info_old.cpi_attribute14
            ,p_new_val_varchar          => l_info_new.cpi_attribute14
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute15 is null)
         and (l_info_new.cpi_attribute15 is not null))
        or ((l_info_new.cpi_attribute15 is null)
	 and (p_info_old.cpi_attribute15 is not null))
	or (p_info_old.cpi_attribute15 <> l_info_new.cpi_attribute15) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF15')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF15'
            ,p_old_val_varchar          => p_info_old.cpi_attribute15
            ,p_new_val_varchar          => l_info_new.cpi_attribute15
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute16 is null)
         and (l_info_new.cpi_attribute16 is not null))
        or ((l_info_new.cpi_attribute16 is null)
	 and (p_info_old.cpi_attribute16 is not null))
	or (p_info_old.cpi_attribute16 <> l_info_new.cpi_attribute16) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF16')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF16'
            ,p_old_val_varchar          => p_info_old.cpi_attribute16
            ,p_new_val_varchar          => l_info_new.cpi_attribute16
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute17 is null)
         and (l_info_new.cpi_attribute17 is not null))
        or ((l_info_new.cpi_attribute17 is null)
	 and (p_info_old.cpi_attribute17 is not null))
	or (p_info_old.cpi_attribute17 <> l_info_new.cpi_attribute17) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF17')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF17'
            ,p_old_val_varchar          => p_info_old.cpi_attribute17
            ,p_new_val_varchar          => l_info_new.cpi_attribute17
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute18 is null)
         and (l_info_new.cpi_attribute18 is not null))
        or ((l_info_new.cpi_attribute18 is null)
	 and (p_info_old.cpi_attribute18 is not null))
	or (p_info_old.cpi_attribute18 <> l_info_new.cpi_attribute18) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF18')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF18'
            ,p_old_val_varchar          => p_info_old.cpi_attribute18
            ,p_new_val_varchar          => l_info_new.cpi_attribute18
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute19 is null)
         and (l_info_new.cpi_attribute19 is not null))
        or ((l_info_new.cpi_attribute19 is null)
	 and (p_info_old.cpi_attribute19 is not null))
	or (p_info_old.cpi_attribute19 <> l_info_new.cpi_attribute19) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF19')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF19'
            ,p_old_val_varchar          => p_info_old.cpi_attribute1
            ,p_new_val_varchar          => l_info_new.cpi_attribute1
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute20 is null)
         and (l_info_new.cpi_attribute20 is not null))
        or ((l_info_new.cpi_attribute20 is null)
	 and (p_info_old.cpi_attribute20 is not null))
	or (p_info_old.cpi_attribute20 <> l_info_new.cpi_attribute20) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF20')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF20'
            ,p_old_val_varchar          => p_info_old.cpi_attribute20
            ,p_new_val_varchar          => l_info_new.cpi_attribute20
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute21 is null)
         and (l_info_new.cpi_attribute21 is not null))
        or ((l_info_new.cpi_attribute21 is null)
	 and (p_info_old.cpi_attribute21 is not null))
	or (p_info_old.cpi_attribute21 <> l_info_new.cpi_attribute21) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF21')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF21'
            ,p_old_val_varchar          => p_info_old.cpi_attribute21
            ,p_new_val_varchar          => l_info_new.cpi_attribute21
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute22 is null)
         and (l_info_new.cpi_attribute22 is not null))
        or ((l_info_new.cpi_attribute22 is null)
	 and (p_info_old.cpi_attribute22 is not null))
	or (p_info_old.cpi_attribute22 <> l_info_new.cpi_attribute22) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF22')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF22'
            ,p_old_val_varchar          => p_info_old.cpi_attribute22
            ,p_new_val_varchar          => l_info_new.cpi_attribute22
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute23 is null)
         and (l_info_new.cpi_attribute23 is not null))
        or ((l_info_new.cpi_attribute23 is null)
	 and (p_info_old.cpi_attribute23 is not null))
	or (p_info_old.cpi_attribute23 <> l_info_new.cpi_attribute23) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF23')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF23'
            ,p_old_val_varchar          => p_info_old.cpi_attribute23
            ,p_new_val_varchar          => l_info_new.cpi_attribute23
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute24 is null)
         and (l_info_new.cpi_attribute24 is not null))
        or ((l_info_new.cpi_attribute24 is null)
	 and (p_info_old.cpi_attribute24 is not null))
	or (p_info_old.cpi_attribute24 <> l_info_new.cpi_attribute24) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF24')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF24'
            ,p_old_val_varchar          => p_info_old.cpi_attribute24
            ,p_new_val_varchar          => l_info_new.cpi_attribute24
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute25 is null)
         and (l_info_new.cpi_attribute25 is not null))
        or ((l_info_new.cpi_attribute25 is null)
	 and (p_info_old.cpi_attribute25 is not null))
	or (p_info_old.cpi_attribute25 <> l_info_new.cpi_attribute25) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF25')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF25'
            ,p_old_val_varchar          => p_info_old.cpi_attribute25
            ,p_new_val_varchar          => l_info_new.cpi_attribute25
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute26 is null)
         and (l_info_new.cpi_attribute26 is not null))
        or ((l_info_new.cpi_attribute26 is null)
	 and (p_info_old.cpi_attribute26 is not null))
	or (p_info_old.cpi_attribute26 <> l_info_new.cpi_attribute26) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF26')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF26'
            ,p_old_val_varchar          => p_info_old.cpi_attribute26
            ,p_new_val_varchar          => l_info_new.cpi_attribute26
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute27 is null)
         and (l_info_new.cpi_attribute27 is not null))
        or ((l_info_new.cpi_attribute27 is null)
	 and (p_info_old.cpi_attribute27 is not null))
	or (p_info_old.cpi_attribute27 <> l_info_new.cpi_attribute27) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF27')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF27'
            ,p_old_val_varchar          => p_info_old.cpi_attribute27
            ,p_new_val_varchar          => l_info_new.cpi_attribute27
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute28 is null)
         and (l_info_new.cpi_attribute28 is not null))
        or ((l_info_new.cpi_attribute28 is null)
	 and (p_info_old.cpi_attribute28 is not null))
	or (p_info_old.cpi_attribute28 <> l_info_new.cpi_attribute28) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF28')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF28'
            ,p_old_val_varchar          => p_info_old.cpi_attribute28
            ,p_new_val_varchar          => l_info_new.cpi_attribute28
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute29 is null)
         and (l_info_new.cpi_attribute29 is not null))
        or ((l_info_new.cpi_attribute29 is null)
	 and (p_info_old.cpi_attribute29 is not null))
	or (p_info_old.cpi_attribute29 <> l_info_new.cpi_attribute29) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF29')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF29'
            ,p_old_val_varchar          => p_info_old.cpi_attribute29
            ,p_new_val_varchar          => l_info_new.cpi_attribute29
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.cpi_attribute30 is null)
         and (l_info_new.cpi_attribute30 is not null))
        or ((l_info_new.cpi_attribute30 is null)
	 and (p_info_old.cpi_attribute30 is not null))
	or (p_info_old.cpi_attribute30 <> l_info_new.cpi_attribute30) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CF30')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CF30'
            ,p_old_val_varchar          => p_info_old.cpi_attribute30
            ,p_new_val_varchar          => l_info_new.cpi_attribute30
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment1 is null)
         and (l_info_new.custom_segment1 is not null))
        or ((l_info_new.custom_segment1 is null)
	 and (p_info_old.custom_segment1 is not null))
	or (p_info_old.custom_segment1 <> l_info_new.custom_segment1) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU1')=true) then
	 	 hr_utility.set_location('CU1',9);
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU1'
            ,p_old_val_varchar          => p_info_old.custom_segment1
            ,p_new_val_varchar          => l_info_new.custom_segment1
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment2 is null)
         and (l_info_new.custom_segment2 is not null))
        or ((l_info_new.custom_segment2 is null)
	 and (p_info_old.custom_segment2 is not null))
	or (p_info_old.custom_segment2 <> l_info_new.custom_segment2) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU2')=true) then
	 	 hr_utility.set_location('CU2',9);
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU2'
            ,p_old_val_varchar          => p_info_old.custom_segment2
            ,p_new_val_varchar          => l_info_new.custom_segment2
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment3 is null)
         and (l_info_new.custom_segment3 is not null))
        or ((l_info_new.custom_segment3 is null)
	 and (p_info_old.custom_segment3 is not null))
	or (p_info_old.custom_segment3 <> l_info_new.custom_segment3) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU3')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU3'
            ,p_old_val_varchar          => p_info_old.custom_segment3
            ,p_new_val_varchar          => l_info_new.custom_segment3
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment4 is null)
         and (l_info_new.custom_segment4 is not null))
        or ((l_info_new.custom_segment4 is null)
	 and (p_info_old.custom_segment4 is not null))
	or (p_info_old.custom_segment4 <> l_info_new.custom_segment4) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU4')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU4'
            ,p_old_val_varchar          => p_info_old.custom_segment4
            ,p_new_val_varchar          => l_info_new.custom_segment4
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment5 is null)
         and (l_info_new.custom_segment5 is not null))
        or ((l_info_new.custom_segment5 is null)
	 and (p_info_old.custom_segment5 is not null))
	or (p_info_old.custom_segment5 <> l_info_new.custom_segment5) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU5')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU5'
            ,p_old_val_varchar          => p_info_old.custom_segment5
            ,p_new_val_varchar          => l_info_new.custom_segment5
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment6 is null)
         and (l_info_new.custom_segment6 is not null))
        or ((l_info_new.custom_segment6 is null)
	 and (p_info_old.custom_segment6 is not null))
	or (p_info_old.custom_segment6 <> l_info_new.custom_segment6) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU6')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU6'
            ,p_old_val_varchar          => p_info_old.custom_segment6
            ,p_new_val_varchar          => l_info_new.custom_segment6
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment7 is null)
         and (l_info_new.custom_segment7 is not null))
        or ((l_info_new.custom_segment7 is null)
	 and (p_info_old.custom_segment7 is not null))
	or (p_info_old.custom_segment7 <> l_info_new.custom_segment7) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU7')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU7'
            ,p_old_val_varchar          => p_info_old.custom_segment7
            ,p_new_val_varchar          => l_info_new.custom_segment7
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment8 is null)
         and (l_info_new.custom_segment8 is not null))
        or ((l_info_new.custom_segment8 is null)
	 and (p_info_old.custom_segment8 is not null))
	or (p_info_old.custom_segment8 <> l_info_new.custom_segment8) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU8')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU8'
            ,p_old_val_varchar          => p_info_old.custom_segment8
            ,p_new_val_varchar          => l_info_new.custom_segment8
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment9 is null)
         and (l_info_new.custom_segment9 is not null))
        or ((l_info_new.custom_segment9 is null)
	 and (p_info_old.custom_segment9 is not null))
	or (p_info_old.custom_segment9 <> l_info_new.custom_segment9) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU9')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU9'
            ,p_old_val_varchar          => p_info_old.custom_segment9
            ,p_new_val_varchar          => l_info_new.custom_segment9
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment10 is null)
         and (l_info_new.custom_segment10 is not null))
        or ((l_info_new.custom_segment10 is null)
	 and (p_info_old.custom_segment10 is not null))
	or (p_info_old.custom_segment10 <> l_info_new.custom_segment10) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU10')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU10'
            ,p_old_val_varchar          => p_info_old.custom_segment10
            ,p_new_val_varchar          => l_info_new.custom_segment10
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment11 is null)
         and (l_info_new.custom_segment11 is not null))
        or ((l_info_new.custom_segment11 is null)
	 and (p_info_old.custom_segment11 is not null))
	or (p_info_old.custom_segment11 <> l_info_new.custom_segment11) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU11')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU11'
            ,p_old_val_number           => p_info_old.custom_segment11
            ,p_new_val_number           => l_info_new.custom_segment11
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment12 is null)
         and (l_info_new.custom_segment12 is not null))
        or ((l_info_new.custom_segment12 is null)
	 and (p_info_old.custom_segment12 is not null))
	or (p_info_old.custom_segment12 <> l_info_new.custom_segment12) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU12')=true) then
	 	 hr_utility.set_location('CU12',9);
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU12'
            ,p_old_val_number           => p_info_old.custom_segment12
            ,p_new_val_number           => l_info_new.custom_segment12
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment13 is null)
         and (l_info_new.custom_segment13 is not null))
        or ((l_info_new.custom_segment13 is null)
	 and (p_info_old.custom_segment13 is not null))
	or (p_info_old.custom_segment13 <> l_info_new.custom_segment13) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU13')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU13'
            ,p_old_val_number           => p_info_old.custom_segment13
            ,p_new_val_number           => l_info_new.custom_segment13
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment14 is null)
         and (l_info_new.custom_segment14 is not null))
        or ((l_info_new.custom_segment14 is null)
	 and (p_info_old.custom_segment14 is not null))
	or (p_info_old.custom_segment14 <> l_info_new.custom_segment14) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU14')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU14'
            ,p_old_val_number           => p_info_old.custom_segment14
            ,p_new_val_number           => l_info_new.custom_segment14
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment15 is null)
         and (l_info_new.custom_segment15 is not null))
        or ((l_info_new.custom_segment15 is null)
	 and (p_info_old.custom_segment15 is not null))
	or (p_info_old.custom_segment15 <> l_info_new.custom_segment15) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU15')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU15'
            ,p_old_val_number           => p_info_old.custom_segment15
            ,p_new_val_number           => l_info_new.custom_segment15
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment16 is null)
         and (l_info_new.custom_segment16 is not null))
        or ((l_info_new.custom_segment16 is null)
	 and (p_info_old.custom_segment16 is not null))
	or (p_info_old.custom_segment16 <> l_info_new.custom_segment16) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU16')=true) then
	 	 hr_utility.set_location('CU16',9);
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU16'
            ,p_old_val_number           => p_info_old.custom_segment16
            ,p_new_val_number           => l_info_new.custom_segment16
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment17 is null)
         and (l_info_new.custom_segment17 is not null))
        or ((l_info_new.custom_segment17 is null)
	 and (p_info_old.custom_segment17 is not null))
	or (p_info_old.custom_segment17 <> l_info_new.custom_segment17) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU17')=true) then
	 	 hr_utility.set_location('CU17',9);
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU17'
            ,p_old_val_number           => p_info_old.custom_segment17
            ,p_new_val_number           => l_info_new.custom_segment17
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment18 is null)
         and (l_info_new.custom_segment18 is not null))
        or ((l_info_new.custom_segment18 is null)
	 and (p_info_old.custom_segment18 is not null))
	or (p_info_old.custom_segment18 <> l_info_new.custom_segment18) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU18')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU18'
            ,p_old_val_number           => p_info_old.custom_segment18
            ,p_new_val_number           => l_info_new.custom_segment18
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment19 is null)
         and (l_info_new.custom_segment19 is not null))
        or ((l_info_new.custom_segment19 is null)
	 and (p_info_old.custom_segment19 is not null))
	or (p_info_old.custom_segment19 <> l_info_new.custom_segment19) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU19')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU19'
            ,p_old_val_number           => p_info_old.custom_segment19
            ,p_new_val_number           => l_info_new.custom_segment19
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
       if( ((p_info_old.custom_segment20 is null)
         and (l_info_new.custom_segment20 is not null))
        or ((l_info_new.custom_segment20 is null)
	 and (p_info_old.custom_segment20 is not null))
	or (p_info_old.custom_segment20 <> l_info_new.custom_segment20) ) then
	 if(ben_cwb_audit_api.return_lookup_validity('CU20')=true) then
	    ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_info_new.group_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => l_group_oipl_id
            ,p_audit_type_cd            => 'CU20'
            ,p_old_val_number           => p_info_old.custom_segment20
            ,p_new_val_number           => l_info_new.custom_segment20
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
       end if;
     end if;
end create_audit_record;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_person_info >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person_info
  (p_validate                    in     boolean   default false
  ,p_group_per_in_ler_id         in     number
  ,p_assignment_id               in     number
  ,p_person_id                   in     number
  ,p_supervisor_id               in     number    default null
  ,p_effective_date              in     date      default null
  ,p_full_name                   in     varchar2  default null
  ,p_brief_name                  in     varchar2  default null
  ,p_custom_name                 in     varchar2  default null
  ,p_supervisor_full_name        in     varchar2  default null
  ,p_supervisor_brief_name       in     varchar2  default null
  ,p_supervisor_custom_name      in     varchar2  default null
  ,p_legislation_code            in     varchar2  default null
  ,p_years_employed              in     number    default null
  ,p_years_in_job                in     number    default null
  ,p_years_in_position           in     number    default null
  ,p_years_in_grade              in     number    default null
  ,p_employee_number             in     varchar2  default null
  ,p_start_date                  in     date      default null
  ,p_original_start_date         in     date      default null
  ,p_adjusted_svc_date           in     date      default null
  ,p_base_salary                 in     number    default null
  ,p_base_salary_change_date     in     date      default null
  ,p_payroll_name                in     varchar2  default null
  ,p_performance_rating          in     varchar2  default null
  ,p_performance_rating_type     in     varchar2  default null
  ,p_performance_rating_date     in     date      default null
  ,p_business_group_id           in     number    default null
  ,p_organization_id             in     number    default null
  ,p_job_id                      in     number    default null
  ,p_grade_id                    in     number    default null
  ,p_position_id                 in     number    default null
  ,p_people_group_id             in     number    default null
  ,p_soft_coding_keyflex_id      in     number    default null
  ,p_location_id                 in     number    default null
  ,p_pay_rate_id                 in     number    default null
  ,p_assignment_status_type_id   in     number    default null
  ,p_frequency                   in     varchar2  default null
  ,p_grade_annulization_factor   in     number    default null
  ,p_pay_annulization_factor     in     number    default null
  ,p_grd_min_val                 in     number    default null
  ,p_grd_max_val                 in     number    default null
  ,p_grd_mid_point               in     number    default null
  ,p_grd_quartile                in     varchar2  default null
  ,p_grd_comparatio              in     number    default null
  ,p_emp_category                in     varchar2  default null
  ,p_change_reason               in     varchar2  default null
  ,p_normal_hours                in     number    default null
  ,p_email_address               in     varchar2  default null
  ,p_base_salary_frequency       in     varchar2  default null
  ,p_new_assgn_ovn               in     number    default null
  ,p_new_perf_event_id           in     number    default null
  ,p_new_perf_review_id          in     number    default null
  ,p_post_process_stat_cd        in     varchar2  default null
  ,p_feedback_rating             in     varchar2  default null
  ,p_feedback_comments           in     varchar2  default null
  ,p_custom_segment1             in     varchar2  default null
  ,p_custom_segment2             in     varchar2  default null
  ,p_custom_segment3             in     varchar2  default null
  ,p_custom_segment4             in     varchar2  default null
  ,p_custom_segment5             in     varchar2  default null
  ,p_custom_segment6             in     varchar2  default null
  ,p_custom_segment7             in     varchar2  default null
  ,p_custom_segment8             in     varchar2  default null
  ,p_custom_segment9             in     varchar2  default null
  ,p_custom_segment10            in     varchar2  default null
  ,p_custom_segment11            in     number    default null
  ,p_custom_segment12            in     number    default null
  ,p_custom_segment13            in     number    default null
  ,p_custom_segment14            in     number    default null
  ,p_custom_segment15            in     number    default null
  ,p_custom_segment16            in     number    default null
  ,p_custom_segment17            in     number    default null
  ,p_custom_segment18            in     number    default null
  ,p_custom_segment19            in     number    default null
  ,p_custom_segment20            in     number    default null
  ,p_ass_attribute_category      in     varchar2  default null
  ,p_ass_attribute1              in     varchar2  default null
  ,p_ass_attribute2              in     varchar2  default null
  ,p_ass_attribute3              in     varchar2  default null
  ,p_ass_attribute4              in     varchar2  default null
  ,p_ass_attribute5              in     varchar2  default null
  ,p_ass_attribute6              in     varchar2  default null
  ,p_ass_attribute7              in     varchar2  default null
  ,p_ass_attribute8              in     varchar2  default null
  ,p_ass_attribute9              in     varchar2  default null
  ,p_ass_attribute10             in     varchar2  default null
  ,p_ass_attribute11             in     varchar2  default null
  ,p_ass_attribute12             in     varchar2  default null
  ,p_ass_attribute13             in     varchar2  default null
  ,p_ass_attribute14             in     varchar2  default null
  ,p_ass_attribute15             in     varchar2  default null
  ,p_ass_attribute16             in     varchar2  default null
  ,p_ass_attribute17             in     varchar2  default null
  ,p_ass_attribute18             in     varchar2  default null
  ,p_ass_attribute19             in     varchar2  default null
  ,p_ass_attribute20             in     varchar2  default null
  ,p_ass_attribute21             in     varchar2  default null
  ,p_ass_attribute22             in     varchar2  default null
  ,p_ass_attribute23             in     varchar2  default null
  ,p_ass_attribute24             in     varchar2  default null
  ,p_ass_attribute25             in     varchar2  default null
  ,p_ass_attribute26             in     varchar2  default null
  ,p_ass_attribute27             in     varchar2  default null
  ,p_ass_attribute28             in     varchar2  default null
  ,p_ass_attribute29             in     varchar2  default null
  ,p_ass_attribute30             in     varchar2  default null
  ,p_ws_comments                 in     varchar2  default null
  ,p_people_group_name           in     varchar2  default null
  ,p_people_group_segment1       in     varchar2  default null
  ,p_people_group_segment2       in     varchar2  default null
  ,p_people_group_segment3       in     varchar2  default null
  ,p_people_group_segment4       in     varchar2  default null
  ,p_people_group_segment5       in     varchar2  default null
  ,p_people_group_segment6       in     varchar2  default null
  ,p_people_group_segment7       in     varchar2  default null
  ,p_people_group_segment8       in     varchar2  default null
  ,p_people_group_segment9       in     varchar2  default null
  ,p_people_group_segment10      in     varchar2  default null
  ,p_people_group_segment11      in     varchar2  default null
  ,p_cpi_attribute_category      in     varchar2  default null
  ,p_cpi_attribute1              in     varchar2  default null
  ,p_cpi_attribute2              in     varchar2  default null
  ,p_cpi_attribute3              in     varchar2  default null
  ,p_cpi_attribute4              in     varchar2  default null
  ,p_cpi_attribute5              in     varchar2  default null
  ,p_cpi_attribute6              in     varchar2  default null
  ,p_cpi_attribute7              in     varchar2  default null
  ,p_cpi_attribute8              in     varchar2  default null
  ,p_cpi_attribute9              in     varchar2  default null
  ,p_cpi_attribute10             in     varchar2  default null
  ,p_cpi_attribute11             in     varchar2  default null
  ,p_cpi_attribute12             in     varchar2  default null
  ,p_cpi_attribute13             in     varchar2  default null
  ,p_cpi_attribute14             in     varchar2  default null
  ,p_cpi_attribute15             in     varchar2  default null
  ,p_cpi_attribute16             in     varchar2  default null
  ,p_cpi_attribute17             in     varchar2  default null
  ,p_cpi_attribute18             in     varchar2  default null
  ,p_cpi_attribute19             in     varchar2  default null
  ,p_cpi_attribute20             in     varchar2  default null
  ,p_cpi_attribute21             in     varchar2  default null
  ,p_cpi_attribute22             in     varchar2  default null
  ,p_cpi_attribute23             in     varchar2  default null
  ,p_cpi_attribute24             in     varchar2  default null
  ,p_cpi_attribute25             in     varchar2  default null
  ,p_cpi_attribute26             in     varchar2  default null
  ,p_cpi_attribute27             in     varchar2  default null
  ,p_cpi_attribute28             in     varchar2  default null
  ,p_cpi_attribute29             in     varchar2  default null
  ,p_cpi_attribute30             in     varchar2  default null
  ,p_feedback_date               in     date      default null
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number number;
  --
  l_proc                varchar2(72) := g_package||'create_person_info';
begin
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_person_info;
  --
  -- Call Before Process User Hook
  --
  begin
     ben_cwb_person_info_bk1.create_person_info_b
               (p_group_per_in_ler_id          => p_group_per_in_ler_id
               ,p_assignment_id                => p_assignment_id
               ,p_person_id                    => p_person_id
	       ,p_supervisor_id                => p_supervisor_id
               ,p_effective_date               => p_effective_date
               ,p_full_name                    => p_full_name
               ,p_brief_name                   => p_brief_name
               ,p_custom_name                  => p_custom_name
               ,p_supervisor_full_name         => p_supervisor_full_name
               ,p_supervisor_brief_name        => p_supervisor_brief_name
               ,p_supervisor_custom_name       => p_supervisor_custom_name
               ,p_legislation_code             => p_legislation_code
               ,p_years_employed               => p_years_employed
               ,p_years_in_job                 => p_years_in_job
               ,p_years_in_position            => p_years_in_position
               ,p_years_in_grade               => p_years_in_grade
               ,p_employee_number              => p_employee_number
               ,p_start_date                   => p_start_date
               ,p_original_start_date          => p_original_start_date
               ,p_adjusted_svc_date            => p_adjusted_svc_date
               ,p_base_salary                  => p_base_salary
               ,p_base_salary_change_date      => p_base_salary_change_date
               ,p_payroll_name                 => p_payroll_name
               ,p_performance_rating           => p_performance_rating
               ,p_performance_rating_type      => p_performance_rating_type
               ,p_performance_rating_date      => p_performance_rating_date
               ,p_business_group_id            => p_business_group_id
               ,p_organization_id              => p_organization_id
               ,p_job_id                       => p_job_id
               ,p_grade_id                     => p_grade_id
               ,p_position_id                  => p_position_id
               ,p_people_group_id              => p_people_group_id
               ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
               ,p_location_id                  => p_location_id
               ,p_pay_rate_id                  => p_pay_rate_id
               ,p_assignment_status_type_id    => p_assignment_status_type_id
               ,p_frequency                    => p_frequency
               ,p_grade_annulization_factor    => p_grade_annulization_factor
               ,p_pay_annulization_factor      => p_pay_annulization_factor
               ,p_grd_min_val                  => p_grd_min_val
               ,p_grd_max_val                  => p_grd_max_val
               ,p_grd_mid_point                => p_grd_mid_point
               ,p_grd_quartile                 => p_grd_quartile
               ,p_grd_comparatio               => p_grd_comparatio
               ,p_emp_category                 => p_emp_category
               ,p_change_reason                => p_change_reason
               ,p_normal_hours                 => p_normal_hours
               ,p_email_address                => p_email_address
               ,p_base_salary_frequency        => p_base_salary_frequency
               ,p_new_assgn_ovn                => p_new_assgn_ovn
               ,p_new_perf_event_id            => p_new_perf_event_id
               ,p_new_perf_review_id           => p_new_perf_review_id
               ,p_post_process_stat_cd         => p_post_process_stat_cd
	       ,p_feedback_rating              => p_feedback_rating
	       ,p_feedback_comments            => p_feedback_comments
               ,p_custom_segment1              => p_custom_segment1
               ,p_custom_segment2              => p_custom_segment2
               ,p_custom_segment3              => p_custom_segment3
               ,p_custom_segment4              => p_custom_segment4
               ,p_custom_segment5              => p_custom_segment5
               ,p_custom_segment6              => p_custom_segment6
               ,p_custom_segment7              => p_custom_segment7
               ,p_custom_segment8              => p_custom_segment8
               ,p_custom_segment9              => p_custom_segment9
               ,p_custom_segment10             => p_custom_segment10
               ,p_custom_segment11             => p_custom_segment11
               ,p_custom_segment12             => p_custom_segment12
               ,p_custom_segment13             => p_custom_segment13
               ,p_custom_segment14             => p_custom_segment14
               ,p_custom_segment15             => p_custom_segment15
               ,p_custom_segment16             => p_custom_segment16
               ,p_custom_segment17             => p_custom_segment17
               ,p_custom_segment18             => p_custom_segment18
               ,p_custom_segment19             => p_custom_segment19
               ,p_custom_segment20             => p_custom_segment20
               ,p_ass_attribute_category       => p_ass_attribute_category
               ,p_ass_attribute1               => p_ass_attribute1
               ,p_ass_attribute2               => p_ass_attribute2
               ,p_ass_attribute3               => p_ass_attribute3
               ,p_ass_attribute4               => p_ass_attribute4
               ,p_ass_attribute5               => p_ass_attribute5
               ,p_ass_attribute6               => p_ass_attribute6
               ,p_ass_attribute7               => p_ass_attribute7
               ,p_ass_attribute8               => p_ass_attribute8
               ,p_ass_attribute9               => p_ass_attribute9
               ,p_ass_attribute10              => p_ass_attribute10
               ,p_ass_attribute11              => p_ass_attribute11
               ,p_ass_attribute12              => p_ass_attribute12
               ,p_ass_attribute13              => p_ass_attribute13
               ,p_ass_attribute14              => p_ass_attribute14
               ,p_ass_attribute15              => p_ass_attribute15
               ,p_ass_attribute16              => p_ass_attribute16
               ,p_ass_attribute17              => p_ass_attribute17
               ,p_ass_attribute18              => p_ass_attribute18
               ,p_ass_attribute19              => p_ass_attribute19
               ,p_ass_attribute20              => p_ass_attribute20
               ,p_ass_attribute21              => p_ass_attribute21
               ,p_ass_attribute22              => p_ass_attribute22
               ,p_ass_attribute23              => p_ass_attribute23
               ,p_ass_attribute24              => p_ass_attribute24
               ,p_ass_attribute25              => p_ass_attribute25
               ,p_ass_attribute26              => p_ass_attribute26
               ,p_ass_attribute27              => p_ass_attribute27
               ,p_ass_attribute28              => p_ass_attribute28
               ,p_ass_attribute29              => p_ass_attribute29
               ,p_ass_attribute30              => p_ass_attribute30
               ,p_ws_comments                  => p_ws_comments
               ,p_people_group_name            => p_people_group_name
               ,p_people_group_segment1        => p_people_group_segment1
               ,p_people_group_segment2        => p_people_group_segment2
               ,p_people_group_segment3        => p_people_group_segment3
               ,p_people_group_segment4        => p_people_group_segment4
               ,p_people_group_segment5        => p_people_group_segment5
               ,p_people_group_segment6        => p_people_group_segment6
               ,p_people_group_segment7        => p_people_group_segment7
               ,p_people_group_segment8        => p_people_group_segment8
               ,p_people_group_segment9        => p_people_group_segment9
               ,p_people_group_segment10       => p_people_group_segment10
               ,p_people_group_segment11       => p_people_group_segment11
               ,p_cpi_attribute_category       => p_cpi_attribute_category
               ,p_cpi_attribute1               => p_cpi_attribute1
               ,p_cpi_attribute2               => p_cpi_attribute2
               ,p_cpi_attribute3               => p_cpi_attribute3
               ,p_cpi_attribute4               => p_cpi_attribute4
               ,p_cpi_attribute5               => p_cpi_attribute5
               ,p_cpi_attribute6               => p_cpi_attribute6
               ,p_cpi_attribute7               => p_cpi_attribute7
               ,p_cpi_attribute8               => p_cpi_attribute8
               ,p_cpi_attribute9               => p_cpi_attribute9
               ,p_cpi_attribute10              => p_cpi_attribute10
               ,p_cpi_attribute11              => p_cpi_attribute11
               ,p_cpi_attribute12              => p_cpi_attribute12
               ,p_cpi_attribute13              => p_cpi_attribute13
               ,p_cpi_attribute14              => p_cpi_attribute14
               ,p_cpi_attribute15              => p_cpi_attribute15
               ,p_cpi_attribute16              => p_cpi_attribute16
               ,p_cpi_attribute17              => p_cpi_attribute17
               ,p_cpi_attribute18              => p_cpi_attribute18
               ,p_cpi_attribute19              => p_cpi_attribute19
               ,p_cpi_attribute20              => p_cpi_attribute20
               ,p_cpi_attribute21              => p_cpi_attribute21
               ,p_cpi_attribute22              => p_cpi_attribute22
               ,p_cpi_attribute23              => p_cpi_attribute23
               ,p_cpi_attribute24              => p_cpi_attribute24
               ,p_cpi_attribute25              => p_cpi_attribute25
               ,p_cpi_attribute26              => p_cpi_attribute26
               ,p_cpi_attribute27              => p_cpi_attribute27
               ,p_cpi_attribute28              => p_cpi_attribute28
               ,p_cpi_attribute29              => p_cpi_attribute29
               ,p_cpi_attribute30              => p_cpi_attribute30
               ,p_feedback_date                => p_feedback_date
               );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PERSON_INFO'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  ben_cpi_ins.ins
         (p_group_per_in_ler_id         =>   p_group_per_in_ler_id
         ,p_assignment_id               =>   p_assignment_id
         ,p_person_id                   =>   p_person_id
         ,p_supervisor_id               =>   p_supervisor_id
         ,p_effective_date              =>   p_effective_date
         ,p_full_name                   =>   p_full_name
         ,p_brief_name                  =>   p_brief_name
         ,p_custom_name                 =>   p_custom_name
         ,p_supervisor_full_name        =>   p_supervisor_full_name
         ,p_supervisor_brief_name       =>   p_supervisor_brief_name
         ,p_supervisor_custom_name      =>   p_supervisor_custom_name
         ,p_legislation_code            =>   p_legislation_code
         ,p_years_employed              =>   p_years_employed
         ,p_years_in_job                =>   p_years_in_job
         ,p_years_in_position           =>   p_years_in_position
         ,p_years_in_grade              =>   p_years_in_grade
         ,p_employee_number             =>   p_employee_number
         ,p_start_date                  =>   p_start_date
         ,p_original_start_date         =>   p_original_start_date
         ,p_adjusted_svc_date           =>   p_adjusted_svc_date
         ,p_base_salary                 =>   p_base_salary
         ,p_base_salary_change_date     =>   p_base_salary_change_date
         ,p_payroll_name                =>   p_payroll_name
         ,p_performance_rating          =>   p_performance_rating
         ,p_performance_rating_type     =>   p_performance_rating_type
         ,p_performance_rating_date     =>   p_performance_rating_date
         ,p_business_group_id           =>   p_business_group_id
         ,p_organization_id             =>   p_organization_id
         ,p_job_id                      =>   p_job_id
         ,p_grade_id                    =>   p_grade_id
         ,p_position_id                 =>   p_position_id
         ,p_people_group_id             =>   p_people_group_id
         ,p_soft_coding_keyflex_id      =>   p_soft_coding_keyflex_id
         ,p_location_id                 =>   p_location_id
         ,p_pay_rate_id                 =>   p_pay_rate_id
         ,p_assignment_status_type_id   =>   p_assignment_status_type_id
         ,p_frequency                   =>   p_frequency
         ,p_grade_annulization_factor   =>   p_grade_annulization_factor
         ,p_pay_annulization_factor     =>   p_pay_annulization_factor
         ,p_grd_min_val                 =>   p_grd_min_val
         ,p_grd_max_val                 =>   p_grd_max_val
         ,p_grd_mid_point               =>   p_grd_mid_point
         ,p_grd_quartile                =>   p_grd_quartile
         ,p_grd_comparatio              =>   p_grd_comparatio
         ,p_emp_category                =>   p_emp_category
         ,p_change_reason               =>   p_change_reason
         ,p_normal_hours                =>   p_normal_hours
         ,p_email_address               =>   p_email_address
         ,p_base_salary_frequency       =>   p_base_salary_frequency
         ,p_new_assgn_ovn               =>   p_new_assgn_ovn
         ,p_new_perf_event_id           =>   p_new_perf_event_id
         ,p_new_perf_review_id          =>   p_new_perf_review_id
         ,p_post_process_stat_cd        =>   p_post_process_stat_cd
         ,p_feedback_rating             =>   p_feedback_rating
         ,p_feedback_comments           =>   p_feedback_comments
         ,p_custom_segment1             =>   p_custom_segment1
         ,p_custom_segment2             =>   p_custom_segment2
         ,p_custom_segment3             =>   p_custom_segment3
         ,p_custom_segment4             =>   p_custom_segment4
         ,p_custom_segment5             =>   p_custom_segment5
         ,p_custom_segment6             =>   p_custom_segment6
         ,p_custom_segment7             =>   p_custom_segment7
         ,p_custom_segment8             =>   p_custom_segment8
         ,p_custom_segment9             =>   p_custom_segment9
         ,p_custom_segment10            =>   p_custom_segment10
         ,p_custom_segment11            =>   p_custom_segment11
         ,p_custom_segment12            =>   p_custom_segment12
         ,p_custom_segment13            =>   p_custom_segment13
         ,p_custom_segment14            =>   p_custom_segment14
         ,p_custom_segment15            =>   p_custom_segment15
         ,p_custom_segment16            =>   p_custom_segment16
         ,p_custom_segment17            =>   p_custom_segment17
         ,p_custom_segment18            =>   p_custom_segment18
         ,p_custom_segment19            =>   p_custom_segment19
         ,p_custom_segment20            =>   p_custom_segment20
         ,p_ass_attribute_category      =>   p_ass_attribute_category
         ,p_ass_attribute1              =>   p_ass_attribute1
         ,p_ass_attribute2              =>   p_ass_attribute2
         ,p_ass_attribute3              =>   p_ass_attribute3
         ,p_ass_attribute4              =>   p_ass_attribute4
         ,p_ass_attribute5              =>   p_ass_attribute5
         ,p_ass_attribute6              =>   p_ass_attribute6
         ,p_ass_attribute7              =>   p_ass_attribute7
         ,p_ass_attribute8              =>   p_ass_attribute8
         ,p_ass_attribute9              =>   p_ass_attribute9
         ,p_ass_attribute10             =>   p_ass_attribute10
         ,p_ass_attribute11             =>   p_ass_attribute11
         ,p_ass_attribute12             =>   p_ass_attribute12
         ,p_ass_attribute13             =>   p_ass_attribute13
         ,p_ass_attribute14             =>   p_ass_attribute14
         ,p_ass_attribute15             =>   p_ass_attribute15
         ,p_ass_attribute16             =>   p_ass_attribute16
         ,p_ass_attribute17             =>   p_ass_attribute17
         ,p_ass_attribute18             =>   p_ass_attribute18
         ,p_ass_attribute19             =>   p_ass_attribute19
         ,p_ass_attribute20             =>   p_ass_attribute20
         ,p_ass_attribute21             =>   p_ass_attribute21
         ,p_ass_attribute22             =>   p_ass_attribute22
         ,p_ass_attribute23             =>   p_ass_attribute23
         ,p_ass_attribute24             =>   p_ass_attribute24
         ,p_ass_attribute25             =>   p_ass_attribute25
         ,p_ass_attribute26             =>   p_ass_attribute26
         ,p_ass_attribute27             =>   p_ass_attribute27
         ,p_ass_attribute28             =>   p_ass_attribute28
         ,p_ass_attribute29             =>   p_ass_attribute29
         ,p_ass_attribute30             =>   p_ass_attribute30
         ,p_ws_comments                 =>   p_ws_comments
         ,p_people_group_name           =>   p_people_group_name
         ,p_people_group_segment1       =>   p_people_group_segment1
         ,p_people_group_segment2       =>   p_people_group_segment2
         ,p_people_group_segment3       =>   p_people_group_segment3
         ,p_people_group_segment4       =>   p_people_group_segment4
         ,p_people_group_segment5       =>   p_people_group_segment5
         ,p_people_group_segment6       =>   p_people_group_segment6
         ,p_people_group_segment7       =>   p_people_group_segment7
         ,p_people_group_segment8       =>   p_people_group_segment8
         ,p_people_group_segment9       =>   p_people_group_segment9
         ,p_people_group_segment10      =>   p_people_group_segment10
         ,p_people_group_segment11      =>   p_people_group_segment11
         ,p_cpi_attribute_category      =>   p_cpi_attribute_category
         ,p_cpi_attribute1              =>   p_cpi_attribute1
         ,p_cpi_attribute2              =>   p_cpi_attribute2
         ,p_cpi_attribute3              =>   p_cpi_attribute3
         ,p_cpi_attribute4              =>   p_cpi_attribute4
         ,p_cpi_attribute5              =>   p_cpi_attribute5
         ,p_cpi_attribute6              =>   p_cpi_attribute6
         ,p_cpi_attribute7              =>   p_cpi_attribute7
         ,p_cpi_attribute8              =>   p_cpi_attribute8
         ,p_cpi_attribute9              =>   p_cpi_attribute9
         ,p_cpi_attribute10             =>   p_cpi_attribute10
         ,p_cpi_attribute11             =>   p_cpi_attribute11
         ,p_cpi_attribute12             =>   p_cpi_attribute12
         ,p_cpi_attribute13             =>   p_cpi_attribute13
         ,p_cpi_attribute14             =>   p_cpi_attribute14
         ,p_cpi_attribute15             =>   p_cpi_attribute15
         ,p_cpi_attribute16             =>   p_cpi_attribute16
         ,p_cpi_attribute17             =>   p_cpi_attribute17
         ,p_cpi_attribute18             =>   p_cpi_attribute18
         ,p_cpi_attribute19             =>   p_cpi_attribute19
         ,p_cpi_attribute20             =>   p_cpi_attribute20
         ,p_cpi_attribute21             =>   p_cpi_attribute21
         ,p_cpi_attribute22             =>   p_cpi_attribute22
         ,p_cpi_attribute23             =>   p_cpi_attribute23
         ,p_cpi_attribute24             =>   p_cpi_attribute24
         ,p_cpi_attribute25             =>   p_cpi_attribute25
         ,p_cpi_attribute26             =>   p_cpi_attribute26
         ,p_cpi_attribute27             =>   p_cpi_attribute27
         ,p_cpi_attribute28             =>   p_cpi_attribute28
         ,p_cpi_attribute29             =>   p_cpi_attribute29
         ,p_cpi_attribute30             =>   p_cpi_attribute30
         ,p_feedback_date               =>   p_feedback_date
         ,p_object_version_number       =>   l_object_version_number
         );
  --
  -- Call After Process User Hook
  --
  --
  begin
     ben_cwb_person_info_bk1.create_person_info_a
               (p_group_per_in_ler_id          => p_group_per_in_ler_id
               ,p_assignment_id                => p_assignment_id
               ,p_person_id                    => p_person_id
	       ,p_supervisor_id                => p_supervisor_id
               ,p_effective_date               => p_effective_date
               ,p_full_name                    => p_full_name
               ,p_brief_name                   => p_brief_name
               ,p_custom_name                  => p_custom_name
               ,p_supervisor_full_name         => p_supervisor_full_name
               ,p_supervisor_brief_name        => p_supervisor_brief_name
               ,p_supervisor_custom_name       => p_supervisor_custom_name
               ,p_legislation_code             => p_legislation_code
               ,p_years_employed               => p_years_employed
               ,p_years_in_job                 => p_years_in_job
               ,p_years_in_position            => p_years_in_position
               ,p_years_in_grade               => p_years_in_grade
               ,p_employee_number              => p_employee_number
               ,p_start_date                   => p_start_date
               ,p_original_start_date          => p_original_start_date
               ,p_adjusted_svc_date            => p_adjusted_svc_date
               ,p_base_salary                  => p_base_salary
               ,p_base_salary_change_date      => p_base_salary_change_date
               ,p_payroll_name                 => p_payroll_name
               ,p_performance_rating           => p_performance_rating
               ,p_performance_rating_type      => p_performance_rating_type
               ,p_performance_rating_date      => p_performance_rating_date
               ,p_business_group_id            => p_business_group_id
               ,p_organization_id              => p_organization_id
               ,p_job_id                       => p_job_id
               ,p_grade_id                     => p_grade_id
               ,p_position_id                  => p_position_id
               ,p_people_group_id              => p_people_group_id
               ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
               ,p_location_id                  => p_location_id
               ,p_pay_rate_id                  => p_pay_rate_id
               ,p_assignment_status_type_id    => p_assignment_status_type_id
               ,p_frequency                    => p_frequency
               ,p_grade_annulization_factor    => p_grade_annulization_factor
               ,p_pay_annulization_factor      => p_pay_annulization_factor
               ,p_grd_min_val                  => p_grd_min_val
               ,p_grd_max_val                  => p_grd_max_val
               ,p_grd_mid_point                => p_grd_mid_point
               ,p_grd_quartile                 => p_grd_quartile
               ,p_grd_comparatio               => p_grd_comparatio
               ,p_emp_category                 => p_emp_category
               ,p_change_reason                => p_change_reason
               ,p_normal_hours                 => p_normal_hours
               ,p_email_address                => p_email_address
               ,p_base_salary_frequency        => p_base_salary_frequency
               ,p_new_assgn_ovn                => p_new_assgn_ovn
               ,p_new_perf_event_id            => p_new_perf_event_id
               ,p_new_perf_review_id           => p_new_perf_review_id
               ,p_post_process_stat_cd         => p_post_process_stat_cd
               ,p_feedback_rating              => p_feedback_rating
               ,p_feedback_comments            => p_feedback_comments
               ,p_custom_segment1              => p_custom_segment1
               ,p_custom_segment2              => p_custom_segment2
               ,p_custom_segment3              => p_custom_segment3
               ,p_custom_segment4              => p_custom_segment4
               ,p_custom_segment5              => p_custom_segment5
               ,p_custom_segment6              => p_custom_segment6
               ,p_custom_segment7              => p_custom_segment7
               ,p_custom_segment8              => p_custom_segment8
               ,p_custom_segment9              => p_custom_segment9
               ,p_custom_segment10             => p_custom_segment10
               ,p_custom_segment11             => p_custom_segment11
               ,p_custom_segment12             => p_custom_segment12
               ,p_custom_segment13             => p_custom_segment13
               ,p_custom_segment14             => p_custom_segment14
               ,p_custom_segment15             => p_custom_segment15
               ,p_custom_segment16             => p_custom_segment16
               ,p_custom_segment17             => p_custom_segment17
               ,p_custom_segment18             => p_custom_segment18
               ,p_custom_segment19             => p_custom_segment19
               ,p_custom_segment20             => p_custom_segment20
               ,p_ass_attribute_category       => p_ass_attribute_category
               ,p_ass_attribute1               => p_ass_attribute1
               ,p_ass_attribute2               => p_ass_attribute2
               ,p_ass_attribute3               => p_ass_attribute3
               ,p_ass_attribute4               => p_ass_attribute4
               ,p_ass_attribute5               => p_ass_attribute5
               ,p_ass_attribute6               => p_ass_attribute6
               ,p_ass_attribute7               => p_ass_attribute7
               ,p_ass_attribute8               => p_ass_attribute8
               ,p_ass_attribute9               => p_ass_attribute9
               ,p_ass_attribute10              => p_ass_attribute10
               ,p_ass_attribute11              => p_ass_attribute11
               ,p_ass_attribute12              => p_ass_attribute12
               ,p_ass_attribute13              => p_ass_attribute13
               ,p_ass_attribute14              => p_ass_attribute14
               ,p_ass_attribute15              => p_ass_attribute15
               ,p_ass_attribute16              => p_ass_attribute16
               ,p_ass_attribute17              => p_ass_attribute17
               ,p_ass_attribute18              => p_ass_attribute18
               ,p_ass_attribute19              => p_ass_attribute19
               ,p_ass_attribute20              => p_ass_attribute20
               ,p_ass_attribute21              => p_ass_attribute21
               ,p_ass_attribute22              => p_ass_attribute22
               ,p_ass_attribute23              => p_ass_attribute23
               ,p_ass_attribute24              => p_ass_attribute24
               ,p_ass_attribute25              => p_ass_attribute25
               ,p_ass_attribute26              => p_ass_attribute26
               ,p_ass_attribute27              => p_ass_attribute27
               ,p_ass_attribute28              => p_ass_attribute28
               ,p_ass_attribute29              => p_ass_attribute29
               ,p_ass_attribute30              => p_ass_attribute30
               ,p_ws_comments                  => p_ws_comments
               ,p_people_group_name            => p_people_group_name
               ,p_people_group_segment1        => p_people_group_segment1
               ,p_people_group_segment2        => p_people_group_segment2
               ,p_people_group_segment3        => p_people_group_segment3
               ,p_people_group_segment4        => p_people_group_segment4
               ,p_people_group_segment5        => p_people_group_segment5
               ,p_people_group_segment6        => p_people_group_segment6
               ,p_people_group_segment7        => p_people_group_segment7
               ,p_people_group_segment8        => p_people_group_segment8
               ,p_people_group_segment9        => p_people_group_segment9
               ,p_people_group_segment10       => p_people_group_segment10
               ,p_people_group_segment11       => p_people_group_segment11
               ,p_cpi_attribute_category       => p_cpi_attribute_category
               ,p_cpi_attribute1               => p_cpi_attribute1
               ,p_cpi_attribute2               => p_cpi_attribute2
               ,p_cpi_attribute3               => p_cpi_attribute3
               ,p_cpi_attribute4               => p_cpi_attribute4
               ,p_cpi_attribute5               => p_cpi_attribute5
               ,p_cpi_attribute6               => p_cpi_attribute6
               ,p_cpi_attribute7               => p_cpi_attribute7
               ,p_cpi_attribute8               => p_cpi_attribute8
               ,p_cpi_attribute9               => p_cpi_attribute9
               ,p_cpi_attribute10              => p_cpi_attribute10
               ,p_cpi_attribute11              => p_cpi_attribute11
               ,p_cpi_attribute12              => p_cpi_attribute12
               ,p_cpi_attribute13              => p_cpi_attribute13
               ,p_cpi_attribute14              => p_cpi_attribute14
               ,p_cpi_attribute15              => p_cpi_attribute15
               ,p_cpi_attribute16              => p_cpi_attribute16
               ,p_cpi_attribute17              => p_cpi_attribute17
               ,p_cpi_attribute18              => p_cpi_attribute18
               ,p_cpi_attribute19              => p_cpi_attribute19
               ,p_cpi_attribute20              => p_cpi_attribute20
               ,p_cpi_attribute21              => p_cpi_attribute21
               ,p_cpi_attribute22              => p_cpi_attribute22
               ,p_cpi_attribute23              => p_cpi_attribute23
               ,p_cpi_attribute24              => p_cpi_attribute24
               ,p_cpi_attribute25              => p_cpi_attribute25
               ,p_cpi_attribute26              => p_cpi_attribute26
               ,p_cpi_attribute27              => p_cpi_attribute27
               ,p_cpi_attribute28              => p_cpi_attribute28
               ,p_cpi_attribute29              => p_cpi_attribute29
               ,p_cpi_attribute30              => p_cpi_attribute30
               ,p_feedback_date                => p_feedback_date
               ,p_object_version_number        => l_object_version_number
               );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PERSON_INFO'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_person_info;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_person_info;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end create_person_info;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_person_info >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_info
  (p_validate                    in     boolean   default false
  ,p_group_per_in_ler_id         in     number
  ,p_assignment_id               in     number    default hr_api.g_number
  ,p_person_id                   in     number    default hr_api.g_number
  ,p_supervisor_id               in     number    default hr_api.g_number
  ,p_effective_date              in     date      default hr_api.g_date
  ,p_full_name                   in     varchar2  default hr_api.g_varchar2
  ,p_brief_name                  in     varchar2  default hr_api.g_varchar2
  ,p_custom_name                 in     varchar2  default hr_api.g_varchar2
  ,p_supervisor_full_name        in     varchar2  default hr_api.g_varchar2
  ,p_supervisor_brief_name       in     varchar2  default hr_api.g_varchar2
  ,p_supervisor_custom_name      in     varchar2  default hr_api.g_varchar2
  ,p_legislation_code            in     varchar2  default hr_api.g_varchar2
  ,p_years_employed              in     number    default hr_api.g_number
  ,p_years_in_job                in     number    default hr_api.g_number
  ,p_years_in_position           in     number    default hr_api.g_number
  ,p_years_in_grade              in     number    default hr_api.g_number
  ,p_employee_number             in     varchar2  default hr_api.g_varchar2
  ,p_start_date                  in     date      default hr_api.g_date
  ,p_original_start_date         in     date      default hr_api.g_date
  ,p_adjusted_svc_date           in     date      default hr_api.g_date
  ,p_base_salary                 in     number    default hr_api.g_number
  ,p_base_salary_change_date     in     date      default hr_api.g_date
  ,p_payroll_name                in     varchar2  default hr_api.g_varchar2
  ,p_performance_rating          in     varchar2  default hr_api.g_varchar2
  ,p_performance_rating_type     in     varchar2  default hr_api.g_varchar2
  ,p_performance_rating_date     in     date      default hr_api.g_date
  ,p_business_group_id           in     number    default hr_api.g_number
  ,p_organization_id             in     number    default hr_api.g_number
  ,p_job_id                      in     number    default hr_api.g_number
  ,p_grade_id                    in     number    default hr_api.g_number
  ,p_position_id                 in     number    default hr_api.g_number
  ,p_people_group_id             in     number    default hr_api.g_number
  ,p_soft_coding_keyflex_id      in     number    default hr_api.g_number
  ,p_location_id                 in     number    default hr_api.g_number
  ,p_pay_rate_id                 in     number    default hr_api.g_number
  ,p_assignment_status_type_id   in     Number    default hr_api.g_number
  ,p_frequency                   in     varchar2  default hr_api.g_varchar2
  ,p_grade_annulization_factor   in     number    default hr_api.g_number
  ,p_pay_annulization_factor     in     number    default hr_api.g_number
  ,p_grd_min_val                 in     number    default hr_api.g_number
  ,p_grd_max_val                 in     number    default hr_api.g_number
  ,p_grd_mid_point               in     number    default hr_api.g_number
  ,p_grd_quartile                in     varchar2  default hr_api.g_varchar2
  ,p_grd_comparatio              in     Number    default hr_api.g_number
  ,p_emp_category                in     varchar2  default hr_api.g_varchar2
  ,p_change_reason               in     varchar2  default hr_api.g_varchar2
  ,p_normal_hours                in     number    default hr_api.g_number
  ,p_email_address               in     varchar2  default hr_api.g_varchar2
  ,p_base_salary_frequency       in     varchar2  default hr_api.g_varchar2
  ,p_new_assgn_ovn               in     number    default hr_api.g_number
  ,p_new_perf_event_id           in     number    default hr_api.g_number
  ,p_new_perf_review_id          in     number    default hr_api.g_number
  ,p_post_process_stat_cd        in     varchar2  default hr_api.g_varchar2
  ,p_feedback_rating             in     varchar2  default hr_api.g_varchar2
  ,p_feedback_comments           in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment1             in     Varchar2  default hr_api.g_varchar2
  ,p_custom_segment2             in     Varchar2  default hr_api.g_varchar2
  ,p_custom_segment3             in     Varchar2  default hr_api.g_varchar2
  ,p_custom_segment4             in     Varchar2  default hr_api.g_varchar2
  ,p_custom_segment5             in     Varchar2  default hr_api.g_varchar2
  ,p_custom_segment6             in     Varchar2  default hr_api.g_varchar2
  ,p_custom_segment7             in     Varchar2  default hr_api.g_varchar2
  ,p_custom_segment8             in     Varchar2  default hr_api.g_varchar2
  ,p_custom_segment9             in     Varchar2  default hr_api.g_varchar2
  ,p_custom_segment10            in     Varchar2  default hr_api.g_varchar2
  ,p_custom_segment11            in     number    default hr_api.g_number
  ,p_custom_segment12            in     number    default hr_api.g_number
  ,p_custom_segment13            in     number    default hr_api.g_number
  ,p_custom_segment14            in     number    default hr_api.g_number
  ,p_custom_segment15            in     number    default hr_api.g_number
  ,p_custom_segment16            in     number    default hr_api.g_number
  ,p_custom_segment17            in     number    default hr_api.g_number
  ,p_custom_segment18            in     number    default hr_api.g_number
  ,p_custom_segment19            in     number    default hr_api.g_number
  ,p_custom_segment20            in     number    default hr_api.g_number
  ,p_ass_attribute_category      in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute1              in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute2              in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute3              in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute4              in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute5              in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute6              in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute7              in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute8              in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute9              in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute10             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute11             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute12             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute13             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute14             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute15             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute16             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute17             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute18             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute19             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute20             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute21             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute22             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute23             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute24             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute25             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute26             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute27             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute28             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute29             in     Varchar2  default hr_api.g_varchar2
  ,p_ass_attribute30             in     Varchar2  default hr_api.g_varchar2
  ,p_ws_comments                 in     Varchar2  default hr_api.g_varchar2
  ,p_people_group_name           in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment1       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment2       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment3       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment4       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment5       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment6       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment7       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment8       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment9       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment10      in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment11      in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute_category      in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute1              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute2              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute3              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute4              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute5              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute6              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute7              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute8              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute9              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute10             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute11             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute12             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute13             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute14             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute15             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute16             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute17             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute18             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute19             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute20             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute21             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute22             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute23             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute24             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute25             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute26             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute27             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute28             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute29             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute30             in     varchar2  default hr_api.g_varchar2
  ,p_feedback_date               in     date      default hr_api.g_date
  ,p_object_version_number       in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number number;
  --
  l_proc                varchar2(72) := g_package||'update_person_info';
  l_old_record          ben_cwb_person_info%rowtype;
begin
  -- get old record

  select * into l_old_record
  from ben_cwb_person_info
  where group_per_in_ler_id = p_group_per_in_ler_id;

  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint update_person_info;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
     ben_cwb_person_info_bk2.update_person_info_b
               (p_group_per_in_ler_id          => p_group_per_in_ler_id
               ,p_assignment_id                => p_assignment_id
               ,p_person_id                    => p_person_id
	       ,p_supervisor_id                => p_supervisor_id
               ,p_effective_date               => p_effective_date
               ,p_full_name                    => p_full_name
               ,p_brief_name                   => p_brief_name
               ,p_custom_name                  => p_custom_name
               ,p_supervisor_full_name         => p_supervisor_full_name
               ,p_supervisor_brief_name        => p_supervisor_brief_name
               ,p_supervisor_custom_name       => p_supervisor_custom_name
               ,p_legislation_code             => p_legislation_code
               ,p_years_employed               => p_years_employed
               ,p_years_in_job                 => p_years_in_job
               ,p_years_in_position            => p_years_in_position
               ,p_years_in_grade               => p_years_in_grade
               ,p_employee_number              => p_employee_number
               ,p_start_date                   => p_start_date
               ,p_original_start_date          => p_original_start_date
               ,p_adjusted_svc_date            => p_adjusted_svc_date
               ,p_base_salary                  => p_base_salary
               ,p_base_salary_change_date      => p_base_salary_change_date
               ,p_payroll_name                 => p_payroll_name
               ,p_performance_rating           => p_performance_rating
               ,p_performance_rating_type      => p_performance_rating_type
               ,p_performance_rating_date      => p_performance_rating_date
               ,p_business_group_id            => p_business_group_id
               ,p_organization_id              => p_organization_id
               ,p_job_id                       => p_job_id
               ,p_grade_id                     => p_grade_id
               ,p_position_id                  => p_position_id
               ,p_people_group_id              => p_people_group_id
               ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
               ,p_location_id                  => p_location_id
               ,p_pay_rate_id                  => p_pay_rate_id
               ,p_assignment_status_type_id    => p_assignment_status_type_id
               ,p_frequency                    => p_frequency
               ,p_grade_annulization_factor    => p_grade_annulization_factor
               ,p_pay_annulization_factor      => p_pay_annulization_factor
               ,p_grd_min_val                  => p_grd_min_val
               ,p_grd_max_val                  => p_grd_max_val
               ,p_grd_mid_point                => p_grd_mid_point
               ,p_grd_quartile                 => p_grd_quartile
               ,p_grd_comparatio               => p_grd_comparatio
               ,p_emp_category                 => p_emp_category
               ,p_change_reason                => p_change_reason
               ,p_normal_hours                 => p_normal_hours
               ,p_email_address                => p_email_address
               ,p_base_salary_frequency        => p_base_salary_frequency
               ,p_new_assgn_ovn                => p_new_assgn_ovn
               ,p_new_perf_event_id            => p_new_perf_event_id
               ,p_new_perf_review_id           => p_new_perf_review_id
               ,p_post_process_stat_cd         => p_post_process_stat_cd
               ,p_feedback_rating              => p_feedback_rating
               ,p_feedback_comments            => p_feedback_comments
               ,p_custom_segment1              => p_custom_segment1
               ,p_custom_segment2              => p_custom_segment2
               ,p_custom_segment3              => p_custom_segment3
               ,p_custom_segment4              => p_custom_segment4
               ,p_custom_segment5              => p_custom_segment5
               ,p_custom_segment6              => p_custom_segment6
               ,p_custom_segment7              => p_custom_segment7
               ,p_custom_segment8              => p_custom_segment8
               ,p_custom_segment9              => p_custom_segment9
               ,p_custom_segment10             => p_custom_segment10
               ,p_custom_segment11             => p_custom_segment11
               ,p_custom_segment12             => p_custom_segment12
               ,p_custom_segment13             => p_custom_segment13
               ,p_custom_segment14             => p_custom_segment14
               ,p_custom_segment15             => p_custom_segment15
               ,p_custom_segment16             => p_custom_segment16
               ,p_custom_segment17             => p_custom_segment17
               ,p_custom_segment18             => p_custom_segment18
               ,p_custom_segment19             => p_custom_segment19
               ,p_custom_segment20             => p_custom_segment20
               ,p_ass_attribute_category       => p_ass_attribute_category
               ,p_ass_attribute1               => p_ass_attribute1
               ,p_ass_attribute2               => p_ass_attribute2
               ,p_ass_attribute3               => p_ass_attribute3
               ,p_ass_attribute4               => p_ass_attribute4
               ,p_ass_attribute5               => p_ass_attribute5
               ,p_ass_attribute6               => p_ass_attribute6
               ,p_ass_attribute7               => p_ass_attribute7
               ,p_ass_attribute8               => p_ass_attribute8
               ,p_ass_attribute9               => p_ass_attribute9
               ,p_ass_attribute10              => p_ass_attribute10
               ,p_ass_attribute11              => p_ass_attribute11
               ,p_ass_attribute12              => p_ass_attribute12
               ,p_ass_attribute13              => p_ass_attribute13
               ,p_ass_attribute14              => p_ass_attribute14
               ,p_ass_attribute15              => p_ass_attribute15
               ,p_ass_attribute16              => p_ass_attribute16
               ,p_ass_attribute17              => p_ass_attribute17
               ,p_ass_attribute18              => p_ass_attribute18
               ,p_ass_attribute19              => p_ass_attribute19
               ,p_ass_attribute20              => p_ass_attribute20
               ,p_ass_attribute21              => p_ass_attribute21
               ,p_ass_attribute22              => p_ass_attribute22
               ,p_ass_attribute23              => p_ass_attribute23
               ,p_ass_attribute24              => p_ass_attribute24
               ,p_ass_attribute25              => p_ass_attribute25
               ,p_ass_attribute26              => p_ass_attribute26
               ,p_ass_attribute27              => p_ass_attribute27
               ,p_ass_attribute28              => p_ass_attribute28
               ,p_ass_attribute29              => p_ass_attribute29
               ,p_ass_attribute30              => p_ass_attribute30
               ,p_ws_comments                  => p_ws_comments
               ,p_people_group_name            => p_people_group_name
               ,p_people_group_segment1        => p_people_group_segment1
               ,p_people_group_segment2        => p_people_group_segment2
               ,p_people_group_segment3        => p_people_group_segment3
               ,p_people_group_segment4        => p_people_group_segment4
               ,p_people_group_segment5        => p_people_group_segment5
               ,p_people_group_segment6        => p_people_group_segment6
               ,p_people_group_segment7        => p_people_group_segment7
               ,p_people_group_segment8        => p_people_group_segment8
               ,p_people_group_segment9        => p_people_group_segment9
               ,p_people_group_segment10       => p_people_group_segment10
               ,p_people_group_segment11       => p_people_group_segment11
               ,p_cpi_attribute_category       => p_cpi_attribute_category
               ,p_cpi_attribute1               => p_cpi_attribute1
               ,p_cpi_attribute2               => p_cpi_attribute2
               ,p_cpi_attribute3               => p_cpi_attribute3
               ,p_cpi_attribute4               => p_cpi_attribute4
               ,p_cpi_attribute5               => p_cpi_attribute5
               ,p_cpi_attribute6               => p_cpi_attribute6
               ,p_cpi_attribute7               => p_cpi_attribute7
               ,p_cpi_attribute8               => p_cpi_attribute8
               ,p_cpi_attribute9               => p_cpi_attribute9
               ,p_cpi_attribute10              => p_cpi_attribute10
               ,p_cpi_attribute11              => p_cpi_attribute11
               ,p_cpi_attribute12              => p_cpi_attribute12
               ,p_cpi_attribute13              => p_cpi_attribute13
               ,p_cpi_attribute14              => p_cpi_attribute14
               ,p_cpi_attribute15              => p_cpi_attribute15
               ,p_cpi_attribute16              => p_cpi_attribute16
               ,p_cpi_attribute17              => p_cpi_attribute17
               ,p_cpi_attribute18              => p_cpi_attribute18
               ,p_cpi_attribute19              => p_cpi_attribute19
               ,p_cpi_attribute20              => p_cpi_attribute20
               ,p_cpi_attribute21              => p_cpi_attribute21
               ,p_cpi_attribute22              => p_cpi_attribute22
               ,p_cpi_attribute23              => p_cpi_attribute23
               ,p_cpi_attribute24              => p_cpi_attribute24
               ,p_cpi_attribute25              => p_cpi_attribute25
               ,p_cpi_attribute26              => p_cpi_attribute26
               ,p_cpi_attribute27              => p_cpi_attribute27
               ,p_cpi_attribute28              => p_cpi_attribute28
               ,p_cpi_attribute29              => p_cpi_attribute29
               ,p_cpi_attribute30              => p_cpi_attribute30
               ,p_feedback_date                => p_feedback_date
               ,p_object_version_number        => l_object_version_number
               );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERSON_INFO'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  ben_cpi_upd.upd
         (p_group_per_in_ler_id         =>   p_group_per_in_ler_id
         ,p_assignment_id               =>   p_assignment_id
         ,p_person_id                   =>   p_person_id
         ,p_supervisor_id               =>   p_supervisor_id
         ,p_effective_date              =>   p_effective_date
         ,p_full_name                   =>   p_full_name
         ,p_brief_name                  =>   p_brief_name
         ,p_custom_name                 =>   p_custom_name
         ,p_supervisor_full_name        =>   p_supervisor_full_name
         ,p_supervisor_brief_name       =>   p_supervisor_brief_name
         ,p_supervisor_custom_name      =>   p_supervisor_custom_name
         ,p_legislation_code            =>   p_legislation_code
         ,p_years_employed              =>   p_years_employed
         ,p_years_in_job                =>   p_years_in_job
         ,p_years_in_position           =>   p_years_in_position
         ,p_years_in_grade              =>   p_years_in_grade
         ,p_employee_number             =>   p_employee_number
         ,p_start_date                  =>   p_start_date
         ,p_original_start_date         =>   p_original_start_date
         ,p_adjusted_svc_date           =>   p_adjusted_svc_date
         ,p_base_salary                 =>   p_base_salary
         ,p_base_salary_change_date     =>   p_base_salary_change_date
         ,p_payroll_name                =>   p_payroll_name
         ,p_performance_rating          =>   p_performance_rating
         ,p_performance_rating_type     =>   p_performance_rating_type
         ,p_performance_rating_date     =>   p_performance_rating_date
         ,p_business_group_id           =>   p_business_group_id
         ,p_organization_id             =>   p_organization_id
         ,p_job_id                      =>   p_job_id
         ,p_grade_id                    =>   p_grade_id
         ,p_position_id                 =>   p_position_id
         ,p_people_group_id             =>   p_people_group_id
         ,p_soft_coding_keyflex_id      =>   p_soft_coding_keyflex_id
         ,p_location_id                 =>   p_location_id
         ,p_pay_rate_id                 =>   p_pay_rate_id
         ,p_assignment_status_type_id   =>   p_assignment_status_type_id
         ,p_frequency                   =>   p_frequency
         ,p_grade_annulization_factor   =>   p_grade_annulization_factor
         ,p_pay_annulization_factor     =>   p_pay_annulization_factor
         ,p_grd_min_val                 =>   p_grd_min_val
         ,p_grd_max_val                 =>   p_grd_max_val
         ,p_grd_mid_point               =>   p_grd_mid_point
         ,p_grd_quartile                =>   p_grd_quartile
         ,p_grd_comparatio              =>   p_grd_comparatio
         ,p_emp_category                =>   p_emp_category
         ,p_change_reason               =>   p_change_reason
         ,p_normal_hours                =>   p_normal_hours
         ,p_email_address               =>   p_email_address
         ,p_base_salary_frequency       =>   p_base_salary_frequency
         ,p_new_assgn_ovn               =>   p_new_assgn_ovn
         ,p_new_perf_event_id           =>   p_new_perf_event_id
         ,p_new_perf_review_id          =>   p_new_perf_review_id
         ,p_post_process_stat_cd        =>   p_post_process_stat_cd
         ,p_feedback_rating             =>   p_feedback_rating
         ,p_feedback_comments           =>   p_feedback_comments
         ,p_custom_segment1             =>   p_custom_segment1
         ,p_custom_segment2             =>   p_custom_segment2
         ,p_custom_segment3             =>   p_custom_segment3
         ,p_custom_segment4             =>   p_custom_segment4
         ,p_custom_segment5             =>   p_custom_segment5
         ,p_custom_segment6             =>   p_custom_segment6
         ,p_custom_segment7             =>   p_custom_segment7
         ,p_custom_segment8             =>   p_custom_segment8
         ,p_custom_segment9             =>   p_custom_segment9
         ,p_custom_segment10            =>   p_custom_segment10
         ,p_custom_segment11            =>   p_custom_segment11
         ,p_custom_segment12            =>   p_custom_segment12
         ,p_custom_segment13            =>   p_custom_segment13
         ,p_custom_segment14            =>   p_custom_segment14
         ,p_custom_segment15            =>   p_custom_segment15
         ,p_custom_segment16            =>   p_custom_segment16
         ,p_custom_segment17            =>   p_custom_segment17
         ,p_custom_segment18            =>   p_custom_segment18
         ,p_custom_segment19            =>   p_custom_segment19
         ,p_custom_segment20            =>   p_custom_segment20
         ,p_ass_attribute_category      =>   p_ass_attribute_category
         ,p_ass_attribute1              =>   p_ass_attribute1
         ,p_ass_attribute2              =>   p_ass_attribute2
         ,p_ass_attribute3              =>   p_ass_attribute3
         ,p_ass_attribute4              =>   p_ass_attribute4
         ,p_ass_attribute5              =>   p_ass_attribute5
         ,p_ass_attribute6              =>   p_ass_attribute6
         ,p_ass_attribute7              =>   p_ass_attribute7
         ,p_ass_attribute8              =>   p_ass_attribute8
         ,p_ass_attribute9              =>   p_ass_attribute9
         ,p_ass_attribute10             =>   p_ass_attribute10
         ,p_ass_attribute11             =>   p_ass_attribute11
         ,p_ass_attribute12             =>   p_ass_attribute12
         ,p_ass_attribute13             =>   p_ass_attribute13
         ,p_ass_attribute14             =>   p_ass_attribute14
         ,p_ass_attribute15             =>   p_ass_attribute15
         ,p_ass_attribute16             =>   p_ass_attribute16
         ,p_ass_attribute17             =>   p_ass_attribute17
         ,p_ass_attribute18             =>   p_ass_attribute18
         ,p_ass_attribute19             =>   p_ass_attribute19
         ,p_ass_attribute20             =>   p_ass_attribute20
         ,p_ass_attribute21             =>   p_ass_attribute21
         ,p_ass_attribute22             =>   p_ass_attribute22
         ,p_ass_attribute23             =>   p_ass_attribute23
         ,p_ass_attribute24             =>   p_ass_attribute24
         ,p_ass_attribute25             =>   p_ass_attribute25
         ,p_ass_attribute26             =>   p_ass_attribute26
         ,p_ass_attribute27             =>   p_ass_attribute27
         ,p_ass_attribute28             =>   p_ass_attribute28
         ,p_ass_attribute29             =>   p_ass_attribute29
         ,p_ass_attribute30             =>   p_ass_attribute30
         ,p_ws_comments                 =>   p_ws_comments
         ,p_people_group_name           =>   p_people_group_name
         ,p_people_group_segment1       =>   p_people_group_segment1
         ,p_people_group_segment2       =>   p_people_group_segment2
         ,p_people_group_segment3       =>   p_people_group_segment3
         ,p_people_group_segment4       =>   p_people_group_segment4
         ,p_people_group_segment5       =>   p_people_group_segment5
         ,p_people_group_segment6       =>   p_people_group_segment6
         ,p_people_group_segment7       =>   p_people_group_segment7
         ,p_people_group_segment8       =>   p_people_group_segment8
         ,p_people_group_segment9       =>   p_people_group_segment9
         ,p_people_group_segment10      =>   p_people_group_segment10
         ,p_people_group_segment11      =>   p_people_group_segment11
         ,p_cpi_attribute_category      =>   p_cpi_attribute_category
         ,p_cpi_attribute1              =>   p_cpi_attribute1
         ,p_cpi_attribute2              =>   p_cpi_attribute2
         ,p_cpi_attribute3              =>   p_cpi_attribute3
         ,p_cpi_attribute4              =>   p_cpi_attribute4
         ,p_cpi_attribute5              =>   p_cpi_attribute5
         ,p_cpi_attribute6              =>   p_cpi_attribute6
         ,p_cpi_attribute7              =>   p_cpi_attribute7
         ,p_cpi_attribute8              =>   p_cpi_attribute8
         ,p_cpi_attribute9              =>   p_cpi_attribute9
         ,p_cpi_attribute10             =>   p_cpi_attribute10
         ,p_cpi_attribute11             =>   p_cpi_attribute11
         ,p_cpi_attribute12             =>   p_cpi_attribute12
         ,p_cpi_attribute13             =>   p_cpi_attribute13
         ,p_cpi_attribute14             =>   p_cpi_attribute14
         ,p_cpi_attribute15             =>   p_cpi_attribute15
         ,p_cpi_attribute16             =>   p_cpi_attribute16
         ,p_cpi_attribute17             =>   p_cpi_attribute17
         ,p_cpi_attribute18             =>   p_cpi_attribute18
         ,p_cpi_attribute19             =>   p_cpi_attribute19
         ,p_cpi_attribute20             =>   p_cpi_attribute20
         ,p_cpi_attribute21             =>   p_cpi_attribute21
         ,p_cpi_attribute22             =>   p_cpi_attribute22
         ,p_cpi_attribute23             =>   p_cpi_attribute23
         ,p_cpi_attribute24             =>   p_cpi_attribute24
         ,p_cpi_attribute25             =>   p_cpi_attribute25
         ,p_cpi_attribute26             =>   p_cpi_attribute26
         ,p_cpi_attribute27             =>   p_cpi_attribute27
         ,p_cpi_attribute28             =>   p_cpi_attribute28
         ,p_cpi_attribute29             =>   p_cpi_attribute29
         ,p_cpi_attribute30             =>   p_cpi_attribute30
         ,p_feedback_date               =>   p_feedback_date
         ,p_object_version_number       =>   l_object_version_number
         );
  --
  -- Call After Process User Hook
  --
  --
  begin
     ben_cwb_person_info_bk2.update_person_info_a
               (p_group_per_in_ler_id          => p_group_per_in_ler_id
               ,p_assignment_id                => p_assignment_id
               ,p_person_id                    => p_person_id
	       ,p_supervisor_id                => p_supervisor_id
               ,p_effective_date               => p_effective_date
               ,p_full_name                    => p_full_name
               ,p_brief_name                   => p_brief_name
               ,p_custom_name                  => p_custom_name
               ,p_supervisor_full_name         => p_supervisor_full_name
               ,p_supervisor_brief_name        => p_supervisor_brief_name
               ,p_supervisor_custom_name       => p_supervisor_custom_name
               ,p_legislation_code             => p_legislation_code
               ,p_years_employed               => p_years_employed
               ,p_years_in_job                 => p_years_in_job
               ,p_years_in_position            => p_years_in_position
               ,p_years_in_grade               => p_years_in_grade
               ,p_employee_number              => p_employee_number
               ,p_start_date                   => p_start_date
               ,p_original_start_date          => p_original_start_date
               ,p_adjusted_svc_date            => p_adjusted_svc_date
               ,p_base_salary                  => p_base_salary
               ,p_base_salary_change_date      => p_base_salary_change_date
               ,p_payroll_name                 => p_payroll_name
               ,p_performance_rating           => p_performance_rating
               ,p_performance_rating_type      => p_performance_rating_type
               ,p_performance_rating_date      => p_performance_rating_date
               ,p_business_group_id            => p_business_group_id
               ,p_organization_id              => p_organization_id
               ,p_job_id                       => p_job_id
               ,p_grade_id                     => p_grade_id
               ,p_position_id                  => p_position_id
               ,p_people_group_id              => p_people_group_id
               ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
               ,p_location_id                  => p_location_id
               ,p_pay_rate_id                  => p_pay_rate_id
               ,p_assignment_status_type_id    => p_assignment_status_type_id
               ,p_frequency                    => p_frequency
               ,p_grade_annulization_factor    => p_grade_annulization_factor
               ,p_pay_annulization_factor      => p_pay_annulization_factor
               ,p_grd_min_val                  => p_grd_min_val
               ,p_grd_max_val                  => p_grd_max_val
               ,p_grd_mid_point                => p_grd_mid_point
               ,p_grd_quartile                 => p_grd_quartile
               ,p_grd_comparatio               => p_grd_comparatio
               ,p_emp_category                 => p_emp_category
               ,p_change_reason                => p_change_reason
               ,p_normal_hours                 => p_normal_hours
               ,p_email_address                => p_email_address
               ,p_base_salary_frequency        => p_base_salary_frequency
               ,p_new_assgn_ovn                => p_new_assgn_ovn
               ,p_new_perf_event_id            => p_new_perf_event_id
               ,p_new_perf_review_id           => p_new_perf_review_id
               ,p_post_process_stat_cd         => p_post_process_stat_cd
               ,p_feedback_rating              => p_feedback_rating
               ,p_feedback_comments            => p_feedback_comments
               ,p_custom_segment1              => p_custom_segment1
               ,p_custom_segment2              => p_custom_segment2
               ,p_custom_segment3              => p_custom_segment3
               ,p_custom_segment4              => p_custom_segment4
               ,p_custom_segment5              => p_custom_segment5
               ,p_custom_segment6              => p_custom_segment6
               ,p_custom_segment7              => p_custom_segment7
               ,p_custom_segment8              => p_custom_segment8
               ,p_custom_segment9              => p_custom_segment9
               ,p_custom_segment10             => p_custom_segment10
               ,p_custom_segment11             => p_custom_segment11
               ,p_custom_segment12             => p_custom_segment12
               ,p_custom_segment13             => p_custom_segment13
               ,p_custom_segment14             => p_custom_segment14
               ,p_custom_segment15             => p_custom_segment15
               ,p_custom_segment16             => p_custom_segment16
               ,p_custom_segment17             => p_custom_segment17
               ,p_custom_segment18             => p_custom_segment18
               ,p_custom_segment19             => p_custom_segment19
               ,p_custom_segment20             => p_custom_segment20
               ,p_ass_attribute_category       => p_ass_attribute_category
               ,p_ass_attribute1               => p_ass_attribute1
               ,p_ass_attribute2               => p_ass_attribute2
               ,p_ass_attribute3               => p_ass_attribute3
               ,p_ass_attribute4               => p_ass_attribute4
               ,p_ass_attribute5               => p_ass_attribute5
               ,p_ass_attribute6               => p_ass_attribute6
               ,p_ass_attribute7               => p_ass_attribute7
               ,p_ass_attribute8               => p_ass_attribute8
               ,p_ass_attribute9               => p_ass_attribute9
               ,p_ass_attribute10              => p_ass_attribute10
               ,p_ass_attribute11              => p_ass_attribute11
               ,p_ass_attribute12              => p_ass_attribute12
               ,p_ass_attribute13              => p_ass_attribute13
               ,p_ass_attribute14              => p_ass_attribute14
               ,p_ass_attribute15              => p_ass_attribute15
               ,p_ass_attribute16              => p_ass_attribute16
               ,p_ass_attribute17              => p_ass_attribute17
               ,p_ass_attribute18              => p_ass_attribute18
               ,p_ass_attribute19              => p_ass_attribute19
               ,p_ass_attribute20              => p_ass_attribute20
               ,p_ass_attribute21              => p_ass_attribute21
               ,p_ass_attribute22              => p_ass_attribute22
               ,p_ass_attribute23              => p_ass_attribute23
               ,p_ass_attribute24              => p_ass_attribute24
               ,p_ass_attribute25              => p_ass_attribute25
               ,p_ass_attribute26              => p_ass_attribute26
               ,p_ass_attribute27              => p_ass_attribute27
               ,p_ass_attribute28              => p_ass_attribute28
               ,p_ass_attribute29              => p_ass_attribute29
               ,p_ass_attribute30              => p_ass_attribute30
               ,p_ws_comments                  => p_ws_comments
               ,p_people_group_name            => p_people_group_name
               ,p_people_group_segment1        => p_people_group_segment1
               ,p_people_group_segment2        => p_people_group_segment2
               ,p_people_group_segment3        => p_people_group_segment3
               ,p_people_group_segment4        => p_people_group_segment4
               ,p_people_group_segment5        => p_people_group_segment5
               ,p_people_group_segment6        => p_people_group_segment6
               ,p_people_group_segment7        => p_people_group_segment7
               ,p_people_group_segment8        => p_people_group_segment8
               ,p_people_group_segment9        => p_people_group_segment9
               ,p_people_group_segment10       => p_people_group_segment10
               ,p_people_group_segment11       => p_people_group_segment11
               ,p_cpi_attribute_category       => p_cpi_attribute_category
               ,p_cpi_attribute1               => p_cpi_attribute1
               ,p_cpi_attribute2               => p_cpi_attribute2
               ,p_cpi_attribute3               => p_cpi_attribute3
               ,p_cpi_attribute4               => p_cpi_attribute4
               ,p_cpi_attribute5               => p_cpi_attribute5
               ,p_cpi_attribute6               => p_cpi_attribute6
               ,p_cpi_attribute7               => p_cpi_attribute7
               ,p_cpi_attribute8               => p_cpi_attribute8
               ,p_cpi_attribute9               => p_cpi_attribute9
               ,p_cpi_attribute10              => p_cpi_attribute10
               ,p_cpi_attribute11              => p_cpi_attribute11
               ,p_cpi_attribute12              => p_cpi_attribute12
               ,p_cpi_attribute13              => p_cpi_attribute13
               ,p_cpi_attribute14              => p_cpi_attribute14
               ,p_cpi_attribute15              => p_cpi_attribute15
               ,p_cpi_attribute16              => p_cpi_attribute16
               ,p_cpi_attribute17              => p_cpi_attribute17
               ,p_cpi_attribute18              => p_cpi_attribute18
               ,p_cpi_attribute19              => p_cpi_attribute19
               ,p_cpi_attribute20              => p_cpi_attribute20
               ,p_cpi_attribute21              => p_cpi_attribute21
               ,p_cpi_attribute22              => p_cpi_attribute22
               ,p_cpi_attribute23              => p_cpi_attribute23
               ,p_cpi_attribute24              => p_cpi_attribute24
               ,p_cpi_attribute25              => p_cpi_attribute25
               ,p_cpi_attribute26              => p_cpi_attribute26
               ,p_cpi_attribute27              => p_cpi_attribute27
               ,p_cpi_attribute28              => p_cpi_attribute28
               ,p_cpi_attribute29              => p_cpi_attribute29
               ,p_cpi_attribute30              => p_cpi_attribute30
               ,p_feedback_date                => p_feedback_date
               ,p_object_version_number        => l_object_version_number
               );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERSON_INFO'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;

  -- calling the create_audit_record procedure to write into
  -- the ben_cwb_audit table with the old record
  create_audit_record(l_old_record);

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_person_info;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_person_info;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end update_person_info;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_person_info >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_info
  (p_validate                    in     boolean   default false
  ,p_group_per_in_ler_id         in     number
  ,p_object_version_number       in     number
  ) is
  --
  --
  l_proc                varchar2(72) := g_package||'delete_person_info';
  --
begin
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint delete_person_info;
  --
  -- Remember IN OUT parameter IN values
  --
  -- Call Before Process User Hook
  --
  begin
     ben_cwb_person_info_bk3.delete_person_info_b
               (p_group_per_in_ler_id          => p_group_per_in_ler_id
               ,p_object_version_number        => p_object_version_number
               );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PERSON_INFO'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  ben_cpi_del.del
         (p_group_per_in_ler_id         =>   p_group_per_in_ler_id
         ,p_object_version_number       =>   p_object_version_number
         );
  --
  -- Call After Process User Hook
  --
  --
  begin
     ben_cwb_person_info_bk3.delete_person_info_a
               (p_group_per_in_ler_id          => p_group_per_in_ler_id
               ,p_object_version_number        => p_object_version_number
               );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PERSON_INFO'
        ,p_hook_type   => 'AP'
        );
  end;


  if g_debug then
     hr_utility.set_location(' Reached '||l_proc, 10);
  end if;

  --****************audit changes**************--
  -- writing into audit log for backing out event --
    if g_debug then
     hr_utility.set_location(' about to BEN_CWB_AUDIT '|| l_proc, 100);
     end if;
    ben_cwb_audit_api.update_per_record(p_group_per_in_ler_id);
  -- ******************************************--

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_person_info;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_person_info;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end delete_person_info;
--
end ben_cwb_person_info_api;

/

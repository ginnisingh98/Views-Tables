--------------------------------------------------------
--  DDL for Package Body BEN_CWB_AUDIT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_AUDIT_API" as
/* $Header: beaudapi.pkb 120.4 2006/10/27 11:13:22 steotia noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  BEN_CWB_AUDIT_API.';
g_debug boolean := hr_utility.debug_enabled;
g_lookup_validity    g_validity_table_type := g_validity_table_type();
--
--
-- -----------------------------------------------------------------------
-- |--------------------------< create_per_record >----------------------|
-- -----------------------------------------------------------------------
procedure create_per_record
  (p_per_in_ler_id           in     number
  ) is
  --
  l_cwb_audit_id          ben_cwb_audit.cwb_audit_id%type;
  l_object_version_number ben_cwb_audit.object_version_number%type;
  l_proc                  varchar2(72) := g_package||'create_per_record';
  l_lf_evt_ocrd_dt        ben_cwb_audit.lf_evt_ocrd_dt%type;
  /*
  l_created_by            ben_per_in_ler.created_by%type;
  */
  l_creation_date         ben_per_in_ler.creation_date%type;
  l_last_updated_by         ben_per_in_ler.last_updated_by%type;
  l_change_made_by_person_id ben_cwb_audit.change_made_by_person_id%type;
  l_group_pl_id           ben_cwb_audit.group_pl_id%type;
  l_person_id             fnd_user.employee_id%type;

  begin
   if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 100);
   end if;

   begin
   /*
    select created_by, creation_date, group_pl_id, lf_evt_ocrd_dt
    into l_created_by, l_creation_date, l_group_pl_id, l_lf_evt_ocrd_dt
    from ben_per_in_ler
    where per_in_ler_id = p_per_in_ler_id;
    */
    select last_updated_by, group_pl_id, lf_evt_ocrd_dt,creation_date
    into l_last_updated_by, l_group_pl_id, l_lf_evt_ocrd_dt, l_creation_date
    from ben_per_in_ler
    where per_in_ler_id = p_per_in_ler_id;

    -- if record exists

    select employee_id into l_person_id
    from fnd_user
    where user_id = l_last_updated_by;

    if(ben_cwb_audit_api.return_lookup_validity('BG')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => p_per_in_ler_id
            ,p_group_pl_id              => l_group_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_group_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'BG'
            ,p_old_val_varchar          => null
            ,p_new_val_varchar          => null
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_supporting_information   => '(as of '||trunc(l_creation_date)||')'
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
      end if;

   if g_debug then
     hr_utility.set_location('BG:'||'p_per_in_ler_id : '||p_per_in_ler_id , 10);
     hr_utility.set_location('done by :'||l_person_id, 12);
   end if;


   exception
    when no_data_found then
    null;
   end;

   if g_debug then
     hr_utility.set_location('Leaving:'|| l_proc, 200);
   end if;


  end create_per_record;
  --
--
-- -----------------------------------------------------------------------
-- |--------------------------< update_per_record >----------------------|
-- -----------------------------------------------------------------------
procedure update_per_record
  (p_per_in_ler_id           in     ben_per_in_ler.per_in_ler_id%type
  ) is
  --
  begin
	update_per_record(p_per_in_ler_id      => p_per_in_ler_id
		  	 ,p_old_val            => null
			 ,p_audit_type_cd      => null
			 );
  end;
--
-- -----------------------------------------------------------------------
-- |--------------------------< update_per_record2 >----------------------|
-- -----------------------------------------------------------------------
procedure update_per_record2
  (p_group_per_in_ler_id      in number
  ) is
  --
  l_cwb_audit_id          ben_cwb_audit.cwb_audit_id%type;
  l_object_version_number ben_cwb_audit.object_version_number%type;
  l_proc                  varchar2(72) := g_package||'update_per_record';
  l_per_record_new        ben_per_in_ler%rowtype;
  l_person_id             fnd_user.employee_id%type;

  begin
   if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 100);
   end if;

   begin

    select *
    into l_per_record_new
    from ben_per_in_ler
    where per_in_ler_id = p_group_per_in_ler_id;

    -- if record exists

    select employee_id into l_person_id
    from fnd_user
    where user_id = l_per_record_new.last_updated_by;

   if g_debug then
     hr_utility.set_location('Record exists for per_in_ler_id: '|| l_per_record_new.per_in_ler_id, 10);
   end if;
     hr_utility.set_location('Record exists for per_in_ler_id: '|| l_per_record_new.per_in_ler_id, 10);

/* -------- overloading
  if(  ((p_per_record_old.ws_mgr_id is null)
    and (l_per_record_new.ws_mgr_id is not null))
    or ((l_per_record_new.ws_mgr_id is null)
    and (p_per_record_old.ws_mgr_id is not null))
     or (p_per_record_old.ws_mgr_id <> l_per_record_new.ws_mgr_id) ) then

    if(ben_cwb_audit_api.return_lookup_validity('MG')=true) then

	begin
	 select DECODE (ben_cwb_utils.get_profile ('BEN_DISPLAY_EMPLOYEE_NAME'),
              'BN', empinfo.brief_name,
              'CN', empinfo.custom_name,
              empinfo.full_name
             )
	 into l_old_ws_mgr_name
         from ben_cwb_person_info empinfo
         where empinfo.group_per_in_ler_id = p_per_record_old.ws_mgr_id;
	exception
	 when no_data_found then
	 l_old_ws_mgr_name := p_per_record_old.ws_mgr_id;
	end;

        begin
	 select DECODE (ben_cwb_utils.get_profile ('BEN_DISPLAY_EMPLOYEE_NAME'),
              'BN', empinfo.brief_name,
              'CN', empinfo.custom_name,
              empinfo.full_name
             )
	 into l_new_ws_mgr_name
         from ben_cwb_person_info empinfo
         where empinfo.group_per_in_ler_id = l_per_record_new.ws_mgr_id;
	exception
	 when no_data_found then
	 l_new_ws_mgr_name := l_per_record_new.ws_mgr_id;
	end;


	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_record_new.per_in_ler_id
            ,p_group_pl_id              => l_per_record_new.group_pl_id
            ,p_lf_evt_ocrd_dt           => l_per_record_new.lf_evt_ocrd_dt
            ,p_pl_id                    => l_per_record_new.group_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'MG'
            ,p_old_val_varchar          => l_old_ws_mgr_name
            ,p_new_val_varchar          => l_new_ws_mgr_name
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );

        if g_debug then
         hr_utility.set_location('MG done: '|| l_per_record_new.per_in_ler_id, 20);
        end if;

      end if;
     end if; */
/* Commenting out as old values are unavailable for comparison
  if(   (p_per_record_old.per_in_ler_stat_cd <> l_per_record_new.per_in_ler_stat_cd) ) then
   --change in status

        if g_debug then
         hr_utility.set_location('Some Change in Status: '|| l_per_record_new.per_in_ler_id, 30);
        end if;

*/

   if(l_per_record_new.per_in_ler_stat_cd = 'PROCD') then
    -- if processed

    if(ben_cwb_audit_api.return_lookup_validity('EN')=true) then

	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_record_new.per_in_ler_id
            ,p_group_pl_id              => l_per_record_new.group_pl_id
            ,p_lf_evt_ocrd_dt           => l_per_record_new.lf_evt_ocrd_dt
            ,p_pl_id                    => l_per_record_new.group_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'EN'
            ,p_old_val_varchar          => null
            ,p_new_val_varchar          => null
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );

        if g_debug then
         hr_utility.set_location('EN done: '|| l_per_record_new.per_in_ler_id, 30);
         hr_utility.set_location('EN by: '|| l_person_id, 31);

        end if;

      end if;
     end if;

   if(l_per_record_new.per_in_ler_stat_cd = 'BCKDT') then
    -- if backed-out

    if(ben_cwb_audit_api.return_lookup_validity('BO')=true) then

	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_record_new.per_in_ler_id
            ,p_group_pl_id              => l_per_record_new.group_pl_id
            ,p_lf_evt_ocrd_dt           => l_per_record_new.lf_evt_ocrd_dt
            ,p_pl_id                    => l_per_record_new.group_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'BO'
            ,p_old_val_varchar          => null
            ,p_new_val_varchar          => null
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );

        if g_debug then
         hr_utility.set_location('BO done: '|| l_per_record_new.per_in_ler_id, 300);
         hr_utility.set_location('BO by: '|| l_person_id, 301);
         hr_utility.set_location('sysdate: '|| sysdate, 305);
        end if;

      end if;
     end if;
   /* end if; */


   exception
    when no_data_found then
    null;
   end;

   if g_debug then
     hr_utility.set_location('Leaving:'|| l_proc, 200);
   end if;


  end update_per_record2;

--
--
-- -----------------------------------------------------------------------
-- |--------------------------< update_per_record >----------------------|
-- -----------------------------------------------------------------------
procedure update_per_record
  (p_per_in_ler_id      in number
  ,p_old_val            in varchar2
  ,p_audit_type_cd      in varchar2
  ) is
 --
  l_proc                  varchar2(72) := g_package||'update_per_record';
  l_ws_mgr_id             ben_per_in_ler.ws_mgr_id%type;
  l_old_ws_mgr_name       ben_cwb_person_info.full_name%type;
  l_new_ws_mgr_name       ben_cwb_person_info.full_name%type;
  l_per_record_new        ben_per_in_ler%rowtype;
  l_person_id             fnd_user.employee_id%type;
  l_cwb_audit_id          ben_cwb_audit.cwb_audit_id%type;
  l_object_version_number ben_cwb_audit.object_version_number%type;
  l_personid             ben_per_in_ler.ws_mgr_id%type;


 begin

   --hr_utility.trace_on(null,'audit1');
   --g_debug:=true;

   if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 100);
   end if;

  if(p_audit_type_cd is null) then
   update_per_record2(p_group_per_in_ler_id => p_per_in_ler_id);

  elsif (p_audit_type_cd is not null) then

   hr_utility.set_location('audit_type_cd :'|| p_audit_type_cd, 10);

   begin

    select *
    into l_per_record_new
    from ben_per_in_ler
    where per_in_ler_id = p_per_in_ler_id;

    -- if record exists

    select employee_id into l_person_id
    from fnd_user
    where user_id = l_per_record_new.last_updated_by;

   if g_debug then
     hr_utility.set_location
  ('Record exists for per_in_ler_id: '||l_per_record_new.per_in_ler_id, 10);
   end if;

   if( p_audit_type_cd = 'MG' ) then

   l_ws_mgr_id := p_old_val;

   if(  ((l_ws_mgr_id is null)
    and (l_per_record_new.ws_mgr_id is not null))
    or ((l_per_record_new.ws_mgr_id is null)
    and (l_ws_mgr_id is not null))
     or (l_ws_mgr_id <> l_per_record_new.ws_mgr_id) ) then

    if(ben_cwb_audit_api.return_lookup_validity('MG')=true) then

	begin

        select distinct ppf.person_id, DECODE
         (ben_cwb_utils.get_profile ('BEN_DISPLAY_EMPLOYEE_NAME'),
          'BN', trim(ppf.first_name ||' '||ppf.last_name||' '||ppf.suffix),
          'CN', nvl(ben_cwb_custom_person_pkg.get_custom_name
                               (ppf.person_id
                               ,pil.assignment_id
                               ,bg.legislation_code
                               ,pil.group_pl_id
                               ,pil.lf_evt_ocrd_dt
                               ,sysdate),
                ppf.full_name),
          ppf.full_name)
	into l_personid, l_old_ws_mgr_name
        from per_all_people_f       ppf
            ,ben_per_in_ler         pil
            ,per_all_assignments_f  paf
            ,per_business_groups    bg
        where ppf.person_id = l_ws_mgr_id
        and   sysdate between ppf.effective_start_date and
                 ppf.effective_end_date
        and   paf.assignment_id  = pil.assignment_id
        and   sysdate between paf.effective_start_date and
                 paf.effective_end_date
        and   paf.person_id = ppf.person_id
        and   bg.business_group_id = paf.business_group_id;

	exception
	 when no_data_found then
	 l_old_ws_mgr_name := l_ws_mgr_id;
	end;

        begin

        select distinct ppf.person_id, DECODE
         (ben_cwb_utils.get_profile ('BEN_DISPLAY_EMPLOYEE_NAME'),
          'BN', trim(ppf.first_name ||' '||ppf.last_name||' '||ppf.suffix),
          'CN', nvl(ben_cwb_custom_person_pkg.get_custom_name
                               (ppf.person_id
                               ,pil.assignment_id
                               ,bg.legislation_code
                               ,pil.group_pl_id
                               ,pil.lf_evt_ocrd_dt
                               ,sysdate),
                ppf.full_name),
          ppf.full_name)
	into l_personid, l_new_ws_mgr_name
        from per_all_people_f       ppf
            ,ben_per_in_ler         pil
            ,per_all_assignments_f  paf
            ,per_business_groups    bg
        where ppf.person_id = l_per_record_new.ws_mgr_id
        and   sysdate between ppf.effective_start_date and
                 ppf.effective_end_date
        and   paf.assignment_id  = pil.assignment_id
        and   sysdate between paf.effective_start_date and
                 paf.effective_end_date
        and   paf.person_id = ppf.person_id
        and   bg.business_group_id = paf.business_group_id;

	exception
	 when no_data_found then
	 l_new_ws_mgr_name := l_per_record_new.ws_mgr_id;
	end;


	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_record_new.per_in_ler_id
            ,p_group_pl_id              => l_per_record_new.group_pl_id
            ,p_lf_evt_ocrd_dt           => l_per_record_new.lf_evt_ocrd_dt
            ,p_pl_id                    => l_per_record_new.group_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'MG'
            ,p_old_val_varchar          => l_old_ws_mgr_name
            ,p_new_val_varchar          => l_new_ws_mgr_name
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );

        if g_debug then
         hr_utility.set_location
	 ('MG done: '|| l_per_record_new.per_in_ler_id, 20);
        end if;

      end if;
     end if;
    end if;

   exception
    when no_data_found then
    null;
   end;

   end if;

   if g_debug then
     hr_utility.set_location('Leaving:'|| l_proc, 200);
   end if;


  end update_per_record;



--
--
-- -----------------------------------------------------------------------
-- |--------------------------< create_audit_entry >----------------------|
-- -----------------------------------------------------------------------
procedure create_audit_entry
  (p_validate                      in     boolean    default false
  ,p_group_per_in_ler_id           in     number
  ,p_group_pl_id                   in     number
  ,p_lf_evt_ocrd_dt                in     date
  ,p_pl_id                         in     number
  ,p_group_oipl_id                 in     number     default null
  ,p_audit_type_cd                 in     varchar2
  ,p_old_val_varchar               in     varchar2   default null
  ,p_new_val_varchar               in     varchar2   default null
  ,p_old_val_number                in     number     default null
  ,p_new_val_number                in     number     default null
  ,p_old_val_date                  in     date       default null
  ,p_new_val_date                  in     date       default null
  ,p_date_stamp                    in     date       default null
  ,p_change_made_by_person_id      in     number     default null
  ,p_supporting_information        in     varchar2   default null
  ,p_request_id                    in     number     default null
  ,p_cwb_audit_id                     out nocopy     number
  ,p_object_version_number            out nocopy     number
  ) is
  --
  l_object_version_number number;
  l_cwb_audit_id ben_cwb_audit.cwb_audit_id%type;
  l_change_made_by_person_id ben_cwb_audit.change_made_by_person_id%type;
  --
  l_proc                varchar2(72) := g_package||'create_audit_entry';
 /* l_change_made_by_person_id number;*/
begin

   --hr_utility.trace_on(null,'audit1');
   --g_debug:=true;

  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  /*  removing because now receiving person_id from fnd_user.employee_id
 begin
  select person_id into l_change_made_by_person_id
  from fnd_user fnduser, per_all_people_f per
  where p_change_made_by_person_id=fnduser.user_id (+)
  and fnduser.person_party_id = per.party_id (+)
  and ((nvl(p_change_made_by_person_id, -1) = -1)  or
    (p_date_stamp between per.effective_start_date and per.effective_end_date));
 exception
  when no_data_found then
   l_change_made_by_person_id := p_change_made_by_person_id;
 end;
 */

   l_change_made_by_person_id := p_change_made_by_person_id;

  if(p_change_made_by_person_id is null) then

   if g_debug then
     hr_utility.set_location('NULL p_change_made_by_person_id ', 12);
   end if;

   l_change_made_by_person_id := -1;
  end if;


  if g_debug then
     hr_utility.set_location('l_change_made_by_person_id:'|| l_change_made_by_person_id||'END',11);
     hr_utility.set_location('p_group_per_in_ler_id: '||p_group_per_in_ler_id,13);
     hr_utility.set_location('p_group_pl_id: '||p_group_pl_id,14);
     hr_utility.set_location('p_lf_evt_ocrd_dt: '||p_lf_evt_ocrd_dt,15);
     hr_utility.set_location('p_pl_id: '||p_pl_id,16);
     hr_utility.set_location('p_audit_type_cd: '||p_audit_type_cd,17);
  end if;

  --
  -- Issue a savepoint
  --
  savepoint create_audit_entry;
  --
  -- Call Before Process User Hook
  --
  begin
  ben_cwb_audit_bk1.create_audit_entry_b
         (p_group_per_in_ler_id           =>   p_group_per_in_ler_id
         ,p_group_pl_id                   =>   p_group_pl_id
         ,p_lf_evt_ocrd_dt                =>   p_lf_evt_ocrd_dt
         ,p_pl_id                         =>   p_pl_id
         ,p_audit_type_cd                 =>   p_audit_type_cd
         ,p_group_oipl_id                 =>   p_group_oipl_id
         ,p_old_val_varchar               =>   p_old_val_varchar
         ,p_new_val_varchar               =>   p_new_val_varchar
         ,p_old_val_number                =>   p_old_val_number
         ,p_new_val_number                =>   p_new_val_number
         ,p_old_val_date                  =>   p_old_val_date
         ,p_new_val_date                  =>   p_new_val_date
         ,p_date_stamp                    =>   p_date_stamp
         ,p_change_made_by_person_id      =>   l_change_made_by_person_id
         ,p_supporting_information        =>   p_supporting_information
         ,p_request_id                    =>   p_request_id
         ,p_cwb_audit_id                  =>   l_cwb_audit_id
   );
   exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_audit_entry'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ben_aud_ins.ins
         (p_group_per_in_ler_id           =>   p_group_per_in_ler_id
         ,p_group_pl_id                   =>   p_group_pl_id
         ,p_lf_evt_ocrd_dt                =>   p_lf_evt_ocrd_dt
         ,p_pl_id                         =>   p_pl_id
         ,p_audit_type_cd                 =>   p_audit_type_cd
         ,p_group_oipl_id                 =>   p_group_oipl_id
         ,p_old_val_varchar               =>   p_old_val_varchar
         ,p_new_val_varchar               =>   p_new_val_varchar
         ,p_old_val_number                =>   p_old_val_number
         ,p_new_val_number                =>   p_new_val_number
         ,p_old_val_date                  =>   p_old_val_date
         ,p_new_val_date                  =>   p_new_val_date
         ,p_date_stamp                    =>   p_date_stamp
         ,p_change_made_by_person_id      =>   l_change_made_by_person_id
         ,p_supporting_information        =>   p_supporting_information
         ,p_request_id                    =>   p_request_id
         ,p_cwb_audit_id                  =>   l_cwb_audit_id
         ,p_object_version_number         =>   l_object_version_number
         );
  --
  -- Call After Process User Hook
  --
  begin
    ben_cwb_audit_bk1.create_audit_entry_a
        (p_group_per_in_ler_id           =>   p_group_per_in_ler_id
        ,p_group_pl_id                   =>   p_group_pl_id
        ,p_lf_evt_ocrd_dt                =>   p_lf_evt_ocrd_dt
        ,p_pl_id                         =>   p_pl_id
        ,p_group_oipl_id                 =>   p_group_oipl_id
        ,p_audit_type_cd                 =>   p_audit_type_cd
        ,p_old_val_varchar               =>   p_old_val_varchar
        ,p_new_val_varchar               =>   p_new_val_varchar
        ,p_old_val_number                =>   p_old_val_number
        ,p_new_val_number                =>   p_new_val_number
        ,p_old_val_date                  =>   p_old_val_date
        ,p_new_val_date                  =>   p_new_val_date
        ,p_date_stamp                    =>   p_date_stamp
        ,p_change_made_by_person_id      =>   l_change_made_by_person_id
        ,p_supporting_information        =>   p_supporting_information
        ,p_request_id                    =>   p_request_id
	,p_cwb_audit_id                  =>   l_cwb_audit_id
        ,p_object_version_number         =>   l_object_version_number
        );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_group_budget'
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
    rollback to create_audit_entry;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_audit_entry;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end create_audit_entry;
--
--
--
-- -------------------------------------------------------------------------
-- |--------------------------< update_audit_entry >------------------------|
-- -------------------------------------------------------------------------
--
procedure update_audit_entry
  (p_validate                     in     boolean    default false
  ,p_cwb_audit_id                 in     number
  ,p_group_per_in_ler_id          in     number
  ,p_group_pl_id                  in     number
  ,p_lf_evt_ocrd_dt               in     date
  ,p_pl_id                        in     number
  ,p_group_oipl_id                in     number     default hr_api.g_number
  ,p_audit_type_cd                in     varchar2
  ,p_old_val_varchar              in     varchar2   default hr_api.g_varchar2
  ,p_new_val_varchar              in     varchar2   default hr_api.g_varchar2
  ,p_old_val_number               in     number     default hr_api.g_number
  ,p_new_val_number               in     number     default hr_api.g_number
  ,p_old_val_date                 in     date       default hr_api.g_date
  ,p_new_val_date                 in     date       default hr_api.g_date
  ,p_date_stamp                   in     date       default hr_api.g_date
  ,p_change_made_by_person_id     in     number     default hr_api.g_number
  ,p_supporting_information       in     varchar2   default hr_api.g_varchar2
  ,p_request_id                   in     number     default hr_api.g_number
  ,p_object_version_number        in out nocopy     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number    number;
  /*l_change_made_by_person_id number;*/
  --
  l_proc                varchar2(72) := g_package||'update_group_budget';
begin
/*
 begin
  select person_id into l_change_made_by_person_id
  from fnd_user fnduser, per_all_people_f per
  where p_change_made_by_person_id=fnduser.user_id (+)
  and fnduser.person_party_id = per.party_id (+)
  and ((nvl(p_change_made_by_person_id, -1) = -1)  or
    (p_date_stamp between per.effective_start_date and per.effective_end_date));
 exception
  when no_data_found then
   l_change_made_by_person_id := p_change_made_by_person_id;
 end;
*/
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint update_audit_entry;
  --
  -- select the existing values from table.
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    ben_cwb_audit_bk2.update_audit_entry_b
        (p_cwb_audit_id                 =>   p_cwb_audit_id
	,p_group_per_in_ler_id          =>   p_group_per_in_ler_id
        ,p_group_pl_id                  =>   p_group_pl_id
        ,p_lf_evt_ocrd_dt               =>   p_lf_evt_ocrd_dt
        ,p_pl_id                        =>   p_pl_id
        ,p_group_oipl_id                =>   p_group_oipl_id
        ,p_audit_type_cd                =>   p_audit_type_cd
        ,p_old_val_varchar              =>   p_old_val_varchar
        ,p_new_val_varchar              =>   p_new_val_varchar
        ,p_old_val_number               =>   p_old_val_number
        ,p_new_val_number               =>   p_new_val_number
        ,p_old_val_date                 =>   p_old_val_date
        ,p_new_val_date                 =>   p_new_val_date
        ,p_date_stamp                   =>   p_date_stamp
        ,p_change_made_by_person_id     =>   p_change_made_by_person_id
        ,p_supporting_information       =>   p_supporting_information
        ,p_request_id                   =>   p_request_id
        ,p_object_version_number        =>   l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_audit_entry'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  -- Min Max Edits (removed)
  --
    --
    if g_debug then
      hr_utility.set_location(l_proc, 30);
    end if;
    --
    --
    if g_debug then
      hr_utility.set_location(l_proc, 40);
    end if;
    --
    --
    if g_debug then
      hr_utility.set_location(l_proc, 50);
    end if;
    --
    --
    if g_debug then
      hr_utility.set_location(l_proc, 60);
    end if;
    --
    --
    -- Check Min, Max and Inc for Ws Bdgt Val
    --
     --
     if g_debug then
       hr_utility.set_location(l_proc, 70);
     end if;
     --
     --
     -- Check Min, Max and Inc for Rsrv Val
     --
  --
  -- Process Logic
  --
  ben_aud_upd.upd
           (p_cwb_audit_id		   =>   p_cwb_audit_id
	   ,p_group_per_in_ler_id          =>   p_group_per_in_ler_id
           ,p_group_pl_id                  =>   p_group_pl_id
           ,p_lf_evt_ocrd_dt               =>   p_lf_evt_ocrd_dt
           ,p_pl_id                        =>   p_pl_id
           ,p_group_oipl_id                =>   p_group_oipl_id
           ,p_audit_type_cd                =>   p_audit_type_cd
           ,p_old_val_varchar              =>   p_old_val_varchar
           ,p_new_val_varchar              =>   p_new_val_varchar
           ,p_old_val_number               =>   p_old_val_number
           ,p_new_val_number               =>   p_new_val_number
           ,p_old_val_date                 =>   p_old_val_date
           ,p_new_val_date                 =>   p_new_val_date
           ,p_date_stamp                   =>   p_date_stamp
           ,p_change_made_by_person_id     =>   p_change_made_by_person_id
           ,p_supporting_information       =>   p_supporting_information
           ,p_request_id                   =>   p_request_id
           ,p_object_version_number        =>   l_object_version_number
         );
  --
  -- Call After Process User Hook
  --
  begin
    ben_cwb_audit_bk2.update_audit_entry_a
        (p_cwb_audit_id                 =>   p_cwb_audit_id
	,p_group_per_in_ler_id          =>   p_group_per_in_ler_id
        ,p_group_pl_id                  =>   p_group_pl_id
        ,p_lf_evt_ocrd_dt               =>   p_lf_evt_ocrd_dt
        ,p_pl_id                        =>   p_pl_id
        ,p_group_oipl_id                =>   p_group_oipl_id
        ,p_audit_type_cd                =>   p_audit_type_cd
        ,p_old_val_varchar              =>   p_old_val_varchar
        ,p_new_val_varchar              =>   p_new_val_varchar
        ,p_old_val_number               =>   p_old_val_number
        ,p_new_val_number               =>   p_new_val_number
        ,p_old_val_date                 =>   p_old_val_date
        ,p_new_val_date                 =>   p_new_val_date
        ,p_date_stamp                   =>   p_date_stamp
        ,p_change_made_by_person_id     =>   p_change_made_by_person_id
        ,p_supporting_information       =>   p_supporting_information
        ,p_request_id                   =>   p_request_id
        ,p_object_version_number        =>   l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_audit_entry'
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
  -- Update is successful. So call the budget summary update.
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 80);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_audit_entry;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_audit_entry;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 99);
    end if;
    raise;
end update_audit_entry;
--
--
-- -------------------------------------------------------------------------
-- |-------------------------< delete_audit_entry >-------------------------|
-- -------------------------------------------------------------------------
--
procedure delete_audit_entry
  (p_validate                      in     boolean  default false
  ,p_cwb_audit_id                  in     number
  ,p_object_version_number         in out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number number;
  l_proc                varchar2(72) := g_package||'delete_audit_entry';
begin
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint delete_audit_entry;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    BEN_CWB_AUDIT_BK3.delete_audit_entry_b
      (p_cwb_audit_id                  =>     p_cwb_audit_id
      ,p_object_version_number         =>     l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_audit_entry'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  ben_aud_del.del
      (p_cwb_audit_id                         =>     p_cwb_audit_id
      ,p_object_version_number                =>     l_object_version_number
      );
  --
  -- Call After Process User Hook
  --
  begin
    ben_cwb_audit_bk3.delete_audit_entry_a
      (p_cwb_audit_id                         =>     p_cwb_audit_id
      ,p_object_version_number                =>     l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_audit_entry'
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
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_audit_entry;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_audit_entry;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end delete_audit_entry;
--
--
-- ------------------------------------------------------------------------
-- |-------------------------< return_column_code >------------------------|
-- ------------------------------------------------------------------------
--
function return_column_code
  (p_lookup_code                in     varchar2
  )return number is
  p_code number;
  begin
   select decode(p_lookup_code,'BO',1
                             ,'BG',1
			     ,'EN',1
			     ,'MG',1
			     ,'RF',1
			     ,'AD',3
			     ,'AS',1
			     ,'BS',2
			     ,'BAD',2
			     ,'BAA',2
			     ,'BPA',2
			     ,'BPD',2
			     ,'BP',1
			     ,'CF1',1
			     ,'CF2',1
			     ,'CF3',1
			     ,'CF4',1
			     ,'CF5',1
			     ,'CF6',1
			     ,'CF7',1
			     ,'CF8',1
			     ,'CF9',1
			     ,'CF10',1
			     ,'CF11',1
			     ,'CF12',1
			     ,'CF13',1
			     ,'CF14',1
			     ,'CF15',1
			     ,'CF16',1
			     ,'CF17',1
			     ,'CF18',1
			     ,'CF19',1
			     ,'CF20',1
			     ,'CF21',1
			     ,'CF22',1
			     ,'CF23',1
			     ,'CF24',1
			     ,'CF25',1
			     ,'CF26',1
			     ,'CF27',1
			     ,'CF28',1
			     ,'CF29',1
			     ,'CF30',1
			     ,'CR',1
			     ,'CA',2
			     ,'CU1',1
			     ,'CU2',1
			     ,'CU3',1
			     ,'CU4',1
			     ,'CU5',1
			     ,'CU6',1
			     ,'CU7',1
			     ,'CU8',1
			     ,'CU9',1
			     ,'CU10',1
			     ,'CU11',2
			     ,'CU12',2
			     ,'CU13',2
			     ,'CU14',2
			     ,'CU15',2
			     ,'CU16',2
			     ,'CU17',2
			     ,'CU18',2
			     ,'CU19',2
			     ,'CU20',2
			     ,'EL',1
			     ,'ES',2
			     ,'CM',1
			     ,'ER',1
			     ,'AC',1
			     ,'M1',2
			     ,'M2',2
			     ,'M3',2
			     ,'OC',2
			     ,'PR',1
			     ,'DD',3
			     ,'AF1',1
			     ,'AF10',1
			     ,'AF11',1
			     ,'AF12',1
			     ,'AF13',1
			     ,'AF14',1
			     ,'AF15',1
			     ,'AF16',1
			     ,'AF17',1
			     ,'AF18',1
			     ,'AF19',1
			     ,'AF20',1
			     ,'AF21',1
			     ,'AF22',1
			     ,'AF23',1
			     ,'AF24',1
			     ,'AF25',1
			     ,'AF26',1
			     ,'AF27',1
			     ,'AF28',1
			     ,'AF29',1
			     ,'AF30',1
			     ,'AF2',1
			     ,'AF3',1
			     ,'AF4',1
			     ,'AF5',1
			     ,'AF6',1
			     ,'AF7',1
			     ,'AF8',1
			     ,'AF9',1
			     ,'GR',1
			     ,'PG',1
			     ,'JO',1
			     ,'PO',1
			     ,'SC',1
			     ,'RA',2
			     ,'RX',2
			     ,'RN',2
			     ,'RS',2
			     ,'SS',2
			     ,'SU',1
			     ,'SD',3
			     ,'TC',2
			     ,'WX',2
			     ,'WN',2
			     ,1) into p_code from dual;

return p_code;
exception
 when no_data_found then
 return 1;
end return_column_code;

--
--
-- ------------------------------------------------------------------------
-- |-------------------------< return_lookup_validity >------------------------|
-- ------------------------------------------------------------------------
--
function return_lookup_validity
  (p_lookup_code                in     varchar2
  )return boolean is
  l_validity        boolean;
  l_lookup          hr_lookups%rowtype;
  l_audit_type_cd   ben_cwb_audit.audit_type_cd%type;
  l_code_flag       code_flag;
  l_found           boolean;
  l_index           number;
begin
  l_validity := false;
  l_found := false;


  if g_debug then
     hr_utility.set_location('loop:'|| g_lookup_validity.COUNT, 23);
  end if;

  if nvl(g_lookup_validity.COUNT,0) > 0 then
    FOR element IN 1..g_lookup_validity.COUNT loop
      if(g_lookup_validity.exists(element)) then
        if(g_lookup_validity(element).code = p_lookup_code) then
          l_found := true;
          l_index := element;
          if g_debug then
             hr_utility.set_location('found:'|| g_lookup_validity(element).code||element, 23);
          end if;
        end if;
      end if;
      exit when(l_found = true);
    end loop;
  end if;


  if(l_found = true) then
    if g_debug then
     hr_utility.set_location('found at: '|| l_index, 24);
    end if;
    if g_debug then
     hr_utility.set_location('with flag: '|| g_lookup_validity(l_index).flag, 25);
    end if;
    if(g_lookup_validity(l_index).flag = 'Y') then
     l_validity := true;
    else
     l_validity := false;
    end if;

  else

     begin
      select * into l_lookup
      from hr_lookups
      where lookup_type='BEN_CWB_AUDIT_TYPE'
      and lookup_code = p_lookup_code;

      l_code_flag.code := l_lookup.lookup_code;

      if( nvl(l_lookup.end_date_active,sysdate)<sysdate or (l_lookup.enabled_flag = 'N')) then
       l_lookup.enabled_flag := 'N';
       l_code_flag.flag := l_lookup.enabled_flag;
       g_lookup_validity.extend(1);
       g_lookup_validity(g_lookup_validity.last) := l_code_flag;
       l_validity := false;

       if g_debug then
        hr_utility.set_location('flag: '||l_code_flag.flag, 25);
       end if;

      else
       l_code_flag.flag := l_lookup.enabled_flag;
       g_lookup_validity.extend(1);
       g_lookup_validity(g_lookup_validity.last) := l_code_flag;
       l_validity := true;
       if g_debug then
        hr_utility.set_location('flag: '||l_code_flag.flag, 25);
       end if;
      end if;
     exception
      when no_data_found then
       l_validity := false;
     end;

  end if;


return l_validity;

end return_lookup_validity;
--
end ben_cwb_audit_api;

/

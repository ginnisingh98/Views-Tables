--------------------------------------------------------
--  DDL for Package Body BEN_CWB_CHANGE_ACCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_CHANGE_ACCESS" as
/* $Header: bencwbca.pkb 120.2 2006/12/01 06:10:50 ddeb noship $ */
--
-- Global cursor and variables declaration
--
g_package  VARCHAR2(80) := 'ben_cwb_change_access.';
g_debug    boolean      := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_group_budget >------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_group_budget
    (
      p_validate                      in     boolean  default false
     ,p_group_per_in_ler_id           in     number
     ,p_group_pl_id                   in     number
     ,p_group_oipl_id                 in     number
     ,p_access_cd                     in     varchar2 default hr_api.g_varchar2
     ,p_comments                      in     varchar2 default null
     ,p_rcvr_person_id                in     number
     ,p_from_person_id                in     number
     ,p_grp_pl_name                   in     varchar2
     ,p_grp_pl_for_strt_dt            in     varchar2
     ,p_grp_pl_for_end_dt             in     varchar2
     ,p_object_version_number         in out nocopy   number
     ,p_requestor_name                 in     varchar2
    ) IS

--
-- Declare cursors and local variables
--
  l_proc  varchar2(72) := g_package||'update_group_budget';
  l_object_version_number number;
  l_transaction_id number;
-- Notification changes for 11510
  l_old_access_cd varchar2(10);
  l_requestor_first_name varchar2(240);
  l_requestor_last_name varchar2(240);
--
BEGIN
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 5);
  end if;
  --
  -- Store initial values for IN OUT parameters
  --
  l_object_version_number := p_object_version_number;

  -- Fetch old access code, which needs to be displayed in notification

      select access_cd into l_old_access_cd
      from  ben_cwb_person_groups
      where group_per_in_ler_id = p_group_per_in_ler_id
          and group_pl_id = p_group_pl_id
          and group_oipl_id = p_group_oipl_id;

    l_requestor_first_name := substr(p_requestor_name,0, instr(p_requestor_name,' ')-1);
    l_requestor_last_name := substr(p_requestor_name, instr(p_requestor_name,' ')+1);

  /* Update the person group information with new access code */
  BEN_CWB_PERSON_GROUPS_API.update_group_budget
     (p_group_per_in_ler_id   => p_group_per_in_ler_id
     ,p_group_pl_id           => p_group_pl_id
     ,p_group_oipl_id         => p_group_oipl_id
     ,p_access_cd             => p_access_cd
     ,p_object_version_number => l_object_version_number
     );

 /* If comments is <> null update the transaction and send the notification */
 if( p_comments is not null) then

 /* Update the transaction table with the contents of notification */
 insert into ben_transaction ( transaction_id,
                              transaction_type,
                              attribute1, -- from_person_id,
                              attribute2, -- to_person_id,
                              attribute3, -- to_per_in_ler_id,
                              attribute4, -- plan_name
                              attribute5, -- for_strt_dt
                              attribute6, -- for_end_dt
                              attribute7, -- new_access_cd
                              attribute40,-- comments
                              attribute9,  -- last updated date/time
                              attribute10,  -- old_access_cd
                              attribute11,  -- requestor first name
                              attribute12  -- requestor last name
                              )
             values         ( ben_transaction_s.nextval,
                              'CWBNTF',
                              p_from_person_id,
                              p_rcvr_person_id,
                              p_group_per_in_ler_id,
                              p_grp_pl_name,
                              p_grp_pl_for_strt_dt,
                              p_grp_pl_for_end_dt,
                              hr_general.decode_lookup('BEN_WS_ACC', p_access_cd ),
                              p_comments,
                              fnd_date.date_to_canonical(sysdate),
                              hr_general.decode_lookup('BEN_WS_ACC', l_old_access_cd ),
                              l_requestor_first_name,
                              l_requestor_last_name
                              )
             returning transaction_id into l_transaction_id ;

 /* Call the notification API */
  ben_cwb_wf_ntf.cwb_fyi_ntf_api (l_transaction_id,
                                   'ACCESS',
                                   p_rcvr_person_id,
                                   p_from_person_id,
                                   p_group_per_in_ler_id );
  end if;

  --
  if g_debug then
    hr_utility.set_location(l_proc, 8);
  end if;
  --
/* NEED TO SAVE DATA IN BEN_TRANSACTIONS AND CALL NTF api */
  -- Populating the OUT parameters.
  --
  p_object_version_number := l_object_version_number;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
  --
END  update_group_budget;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_access >------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_access (
      p_validate                      in     boolean        default false
     ,p_popl_cd                       in     varchar2
     ,p_group_per_in_ler_id           in     BEN_CWB_ACCESS_STRING_ARRAY default null
     ,p_group_pl_id                   in     number
     ,p_group_oipl_id                 in     number
     ,p_access_cd_from                in     varchar2       default 'ANY'
     ,p_access_cd_to                  in     varchar2
     ,p_cascade                       in     varchar2       default 'N'
     ,p_comments                      in     varchar2       default null
     ,p_acting_person_id              in     number
     ,p_grp_pl_name                   in     varchar2
     ,p_grp_pl_for_strt_dt            in     varchar2
     ,p_grp_pl_for_end_dt             in     varchar2
     ,p_return_status                 out nocopy number
     ,p_requestor_name                 in  varchar2
     ,p_throw_exp                     out nocopy varchar2
    ) IS
--
TYPE REF_CURSOR IS REF CURSOR;
fetch_all_managers REF_CURSOR;
fetch_direct_managers REF_CURSOR;
fetch_search_managers REF_CURSOR;
--
--
-- Declare cursors and local variables
--
  l_proc  varchar2(72) := g_package||'update_access';
  --
  l_dynamic_sql varchar2(32000);
  l_per_in_ler_id number;
  l_emp_person_id number;
  l_ovn number;
  l_access_cd varchar2(5);
  l_appr_cd varchar2(5);
  l_submit_cd varchar2(5);
  l_throw_exp varchar2(2);
  l_concat_str varchar2(32000) default null;
  l_num number default 0;
--
BEGIN
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
    --
  FOR l_num in p_group_per_in_ler_id.First..p_group_per_in_ler_id.LAST
   LOOP
    IF l_num = p_group_per_in_ler_id.First THEN
       l_concat_str := l_concat_str || p_group_per_in_ler_id(l_num);
       ELSE
        l_concat_str := l_concat_str ||',' || p_group_per_in_ler_id(l_num);
       END IF;
   END LOOP;
   --
  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;
  --

if (p_popl_cd = 'D') then
  --
   if g_debug then
    hr_utility.set_location(l_proc, 30);
   end if;
      --
  l_dynamic_sql :=
   'select max(emp_per.person_id)              emp_person_id,
       max(mgr_hrchy.emp_per_in_ler_id)    emp_per_in_ler_id,
       max(per_grp.object_version_number)  obj_ver_no,
       max(per_grp.access_cd) access_cd,
       max(per_grp.approval_cd) appr_cd,
       max(per_grp.submit_cd) submit_cd
from
         ben_cwb_person_info    emp_per,
         ben_cwb_group_hrchy    mgr_hrchy,
         ben_cwb_person_groups  per_grp,
         ben_cwb_summary        smry
where
             mgr_hrchy.mgr_per_in_ler_id        in (' || l_concat_str || ')
         and mgr_hrchy.lvl_num                  = 1
         and smry.group_per_in_ler_id           = mgr_hrchy.emp_per_in_ler_id
         and smry.elig_count_all                > 0
         and emp_per.group_per_in_ler_id        = mgr_hrchy.emp_per_in_ler_id
         and per_grp.group_per_in_ler_id        = mgr_hrchy.emp_per_in_ler_id
         and per_grp.group_pl_id                = ' || p_group_pl_id || '
         and per_grp.group_oipl_id              = -1
         and upper(per_grp.access_cd)           = decode(upper(''' || upper(p_access_cd_from) || '''), ''ANY'', upper(per_grp.access_cd), '''|| upper(p_access_cd_from) || ''')
         -- Additional check to avoid records which have worksheet status Approved
	     -- or approval status null and submit status as sumitted
	 --    and nvl(per_grp.approval_cd, ''XX'') <> ''AP''
         -- and NOT ( nvl(per_grp.submit_cd, ''XX'') = ''SU'' and per_grp.approval_cd is null )
group by smry.group_per_in_ler_id'; --
   if g_debug then
    hr_utility.set_location(l_proc, 40);
   end if;
   --
   /* Open Main Cursor to fetch the desired population */
   open fetch_direct_managers for l_dynamic_sql;
    /* Loop through the cursor */
    loop
     fetch fetch_direct_managers into
                     l_emp_person_id,
                     l_per_in_ler_id,
                     l_ovn,
		     l_access_cd,
		     l_appr_cd,
		     l_submit_cd;
     EXIT WHEN fetch_direct_managers%NOTFOUND;

     -- CODE TO UPDATE , CALL TO MAIN API
     p_return_status := l_per_in_ler_id;

     --
     --Access to be changed for the following cases when the PerInLer has Submitted or has been Approved
     --
     if ((l_appr_cd = 'AP' OR l_appr_cd = 'PR') OR (l_submit_cd = 'SU' AND l_appr_cd is null)) AND (l_access_cd <> p_access_cd_to) then
       --
       if g_debug then
         hr_utility.set_location('Entering outer IF'|| l_proc, 50);
       end if;
       --
       if l_access_cd = 'NA' AND p_access_cd_to = 'RO' then
        --
	if g_debug then
          hr_utility.set_location('Entering: '|| l_proc, 55);
        end if;
        --
	update_group_budget ( p_validate, l_per_in_ler_id, p_group_pl_id,
                           p_group_oipl_id, p_access_cd_to, p_comments,
                           l_emp_person_id, p_acting_person_id, p_grp_pl_name, p_grp_pl_for_strt_dt,
                           p_grp_pl_for_end_dt, l_ovn , p_requestor_name);--process;
       elsif l_access_cd = 'UP' AND p_access_cd_to = 'RO' then
        --
	if g_debug then
          hr_utility.set_location('Entering: '|| l_proc, 56);
        end if;
        --
	update_group_budget ( p_validate, l_per_in_ler_id, p_group_pl_id,
                           p_group_oipl_id, p_access_cd_to, p_comments,
                           l_emp_person_id, p_acting_person_id, p_grp_pl_name, p_grp_pl_for_strt_dt,
                           p_grp_pl_for_end_dt, l_ovn , p_requestor_name);--process;
       elsif l_access_cd = 'RO' AND p_access_cd_to = 'NA' then
        --
	if g_debug then
          hr_utility.set_location('Entering: '|| l_proc, 57);
        end if;
        --
	update_group_budget ( p_validate, l_per_in_ler_id, p_group_pl_id,
                           p_group_oipl_id, p_access_cd_to, p_comments,
                           l_emp_person_id, p_acting_person_id, p_grp_pl_name, p_grp_pl_for_strt_dt,
                           p_grp_pl_for_end_dt, l_ovn , p_requestor_name);--process;
       elsif l_access_cd = 'UP' AND p_access_cd_to = 'RO' then
        --
	if g_debug then
          hr_utility.set_location('Entering: '|| l_proc, 58);
        end if;
        --
	update_group_budget ( p_validate, l_per_in_ler_id, p_group_pl_id,
                           p_group_oipl_id, p_access_cd_to, p_comments,
                           l_emp_person_id, p_acting_person_id, p_grp_pl_name, p_grp_pl_for_strt_dt,
                           p_grp_pl_for_end_dt, l_ovn , p_requestor_name);--process;
       else
         --
	 if g_debug then
           hr_utility.set_location('Condition not found:'|| l_proc, 60);
         end if;
         --
	 -- Will set to 'Y' , to throw warning message
	 --
	 l_throw_exp := 'Y';
	 p_throw_exp := l_throw_exp;
       end if;
     else
       --
       if g_debug then
         hr_utility.set_location('Entering: '|| l_proc, 70);
       end if;
       --
       --
       --Update as usual if not Submitted/Approved
       --
       update_group_budget ( p_validate, l_per_in_ler_id, p_group_pl_id,
                           p_group_oipl_id, p_access_cd_to, p_comments,
                           l_emp_person_id, p_acting_person_id, p_grp_pl_name, p_grp_pl_for_strt_dt,
                           p_grp_pl_for_end_dt, l_ovn , p_requestor_name);
     end if;
    end loop;
    --
    if g_debug then
     hr_utility.set_location(l_proc, 80);
    end if;
    --
    close fetch_direct_managers ;
    --
    if g_debug then
     hr_utility.set_location(l_proc, 90);
    end if;
--
elsif (p_popl_cd = 'A') then
--
   if g_debug then
    hr_utility.set_location(l_proc, 100);
   end if;
--
   l_dynamic_sql := '
    select max(emp_per.person_id)              emp_person_id,
       max(mgr_hrchy.emp_per_in_ler_id)    emp_per_in_ler_id,
       max(per_grp.object_version_number)  obj_ver_no,
       max(per_grp.access_cd) access_cd,
       max(per_grp.approval_cd) appr_cd,
       max(per_grp.submit_cd) submit_cd
from
         ben_cwb_person_info    emp_per,
         ben_cwb_group_hrchy    mgr_hrchy,
         ben_cwb_person_groups  per_grp,
         ben_cwb_summary        smry
where
             mgr_hrchy.mgr_per_in_ler_id        in (' || l_concat_str || ')
         and mgr_hrchy.lvl_num                  > 0
         and smry.group_per_in_ler_id           = mgr_hrchy.emp_per_in_ler_id
         and smry.elig_count_all                > 0
         and emp_per.group_per_in_ler_id        = mgr_hrchy.emp_per_in_ler_id
         and per_grp.group_per_in_ler_id        = mgr_hrchy.emp_per_in_ler_id
         and per_grp.group_pl_id                = ' || p_group_pl_id || '
         and per_grp.group_oipl_id              = -1
         and upper(per_grp.access_cd)           = decode(upper(''' || upper(p_access_cd_from) || '''), ''ANY'', upper(per_grp.access_cd), '''|| upper(p_access_cd_from) || ''')
         -- Additional check to avoid records which have worksheet status Approved
	     -- or approval status null and submit status as sumitted
	 --    and nvl(per_grp.approval_cd, ''XX'') <> ''AP''
         -- and NOT ( nvl(per_grp.submit_cd, ''XX'') = ''SU'' and per_grp.approval_cd is null )
group by smry.group_per_in_ler_id';

    /* Open Main Cursor to fetch the desired population */
   --
   if g_debug then
    hr_utility.set_location(l_proc, 110);
   end if;
   --
   open fetch_all_managers for l_dynamic_sql;
   /* Loop through the cursor */
   loop
    fetch fetch_all_managers into
                 l_emp_person_id,
                 l_per_in_ler_id ,
                           l_ovn ,
		              l_access_cd,
		                l_appr_cd,
		              l_submit_cd;
    EXIT WHEN fetch_all_managers%NOTFOUND;

     --
     --Access to be changed for the following cases when the PerInLer has Submitted or has been Approved
     --
     if ((l_appr_cd = 'AP' OR l_appr_cd = 'PR') OR (l_submit_cd = 'SU' AND l_appr_cd is null)) AND (l_access_cd <> p_access_cd_to) then
       --
       if g_debug then
         hr_utility.set_location('Entering outer IF'|| l_proc, 120);
       end if;
       --
       if l_access_cd = 'NA' AND p_access_cd_to = 'RO' then
        --
	if g_debug then
          hr_utility.set_location('Entering: '|| l_proc, 125);
        end if;
        --
	update_group_budget ( p_validate, l_per_in_ler_id, p_group_pl_id,
                           p_group_oipl_id, p_access_cd_to, p_comments,
                           l_emp_person_id, p_acting_person_id, p_grp_pl_name, p_grp_pl_for_strt_dt,
                           p_grp_pl_for_end_dt, l_ovn , p_requestor_name);--process;
       elsif l_access_cd = 'UP' AND p_access_cd_to = 'RO' then
        --
	if g_debug then
          hr_utility.set_location('Entering: '|| l_proc, 126);
        end if;
        --
	update_group_budget ( p_validate, l_per_in_ler_id, p_group_pl_id,
                           p_group_oipl_id, p_access_cd_to, p_comments,
                           l_emp_person_id, p_acting_person_id, p_grp_pl_name, p_grp_pl_for_strt_dt,
                           p_grp_pl_for_end_dt, l_ovn , p_requestor_name);--process;
       elsif l_access_cd = 'RO' AND p_access_cd_to = 'NA' then
        --
	if g_debug then
          hr_utility.set_location('Entering: '|| l_proc, 127);
        end if;
        --
	update_group_budget ( p_validate, l_per_in_ler_id, p_group_pl_id,
                           p_group_oipl_id, p_access_cd_to, p_comments,
                           l_emp_person_id, p_acting_person_id, p_grp_pl_name, p_grp_pl_for_strt_dt,
                           p_grp_pl_for_end_dt, l_ovn , p_requestor_name);--process;
       elsif l_access_cd = 'UP' AND p_access_cd_to = 'RO' then
        --
	if g_debug then
          hr_utility.set_location('Entering: '|| l_proc, 128);
        end if;
        --
	update_group_budget ( p_validate, l_per_in_ler_id, p_group_pl_id,
                           p_group_oipl_id, p_access_cd_to, p_comments,
                           l_emp_person_id, p_acting_person_id, p_grp_pl_name, p_grp_pl_for_strt_dt,
                           p_grp_pl_for_end_dt, l_ovn , p_requestor_name);--process;
       else
         --
	 if g_debug then
           hr_utility.set_location('Condition not found:'|| l_proc, 130);
         end if;
         --
	 -- Will set to 'Y' , to throw warning message
	 --
	 l_throw_exp := 'Y';
	 p_throw_exp := l_throw_exp;
       end if;
     else
       --
       if g_debug then
         hr_utility.set_location('Entering: '|| l_proc, 140);
       end if;
       --
       --
       --Update as usual if not Submitted/Approved
       --
       update_group_budget ( p_validate, l_per_in_ler_id, p_group_pl_id,
                           p_group_oipl_id, p_access_cd_to, p_comments,
                           l_emp_person_id, p_acting_person_id, p_grp_pl_name, p_grp_pl_for_strt_dt,
                           p_grp_pl_for_end_dt, l_ovn , p_requestor_name);
     end if;
   end loop;
   close fetch_all_managers ;
   --
   if g_debug then
    hr_utility.set_location(l_proc, 150);
   end if;
--
else
--
  if g_debug then
   hr_utility.set_location(l_proc, 160);
  end if;
  --
  if(p_group_per_in_ler_id is not null ) then
   l_dynamic_sql := '
     select   distinct
         max(emp_per.person_id)              emp_person_id,
         max(mgr_hrchy.emp_per_in_ler_id)    emp_per_in_ler_id,
         max(per_grp.object_version_number)  obj_ver_no,
	 max(per_grp.access_cd) access_cd,
         max(per_grp.approval_cd) appr_cd,
         max(per_grp.submit_cd) submit_cd
from
         ben_cwb_person_info    emp_per,
         ben_cwb_group_hrchy    mgr_hrchy,
         ben_cwb_person_groups  per_grp,
         ben_cwb_summary        smry
where
         /* Looking for Direct Reports */
             mgr_hrchy.mgr_per_in_ler_id        in (' || l_concat_str || ')
         and ((''' || p_cascade || '''= ''Y'' and mgr_hrchy.lvl_num >=0) or
               (''' || p_cascade || '''= ''N'' and mgr_hrchy.lvl_num =0))
         and smry.group_per_in_ler_id           = mgr_hrchy.emp_per_in_ler_id
         and smry.elig_count_all                > 0
         and emp_per.group_per_in_ler_id        = mgr_hrchy.emp_per_in_ler_id
         and per_grp.group_per_in_ler_id        = mgr_hrchy.emp_per_in_ler_id
         and per_grp.group_pl_id                = ' || p_group_pl_id || '
         and per_grp.group_oipl_id              = -1
         and upper(per_grp.access_cd)           = decode(upper(''' || upper(p_access_cd_from) || '''), ''ANY'', upper(per_grp.access_cd), '''|| upper(p_access_cd_from) || ''')
         -- Additional check to avoid records which have worksheet status Approved
	     -- or approval status null and submit status as sumitted
         -- and nvl(per_grp.approval_cd, ''XX'') <> ''AP''
         -- and NOT ( nvl(per_grp.submit_cd, ''XX'') = ''SU'' and per_grp.approval_cd is null )
group by smry.group_per_in_ler_id'; --
    if g_debug then
     hr_utility.set_location(l_proc, 170);
    end if;
    --
    open fetch_search_managers for l_dynamic_sql;
    /* Loop through the cursor */
    loop
      fetch fetch_search_managers into
                      l_emp_person_id,
                      l_per_in_ler_id ,
                               l_ovn,
		          l_access_cd,
		            l_appr_cd,
		          l_submit_cd ;
      EXIT WHEN fetch_search_managers%NOTFOUND;
      if g_debug then
       hr_utility.set_location(l_proc, 180);
      end if;
      -- CODE TO UPDATE , CALL TO MAIN API
     --
     --Access to be changed for the following cases when the PerInLer has Submitted or has been Approved
     --
     if ((l_appr_cd = 'AP' OR l_appr_cd = 'PR') OR (l_submit_cd = 'SU' AND l_appr_cd is null)) AND (l_access_cd <> p_access_cd_to) then
       --
       if g_debug then
         hr_utility.set_location('Entering outer IF'|| l_proc, 190);
       end if;
       --
       if l_access_cd = 'NA' AND p_access_cd_to = 'RO' then
        --
	if g_debug then
          hr_utility.set_location('Entering: '|| l_proc, 195);
        end if;
        --
	update_group_budget ( p_validate, l_per_in_ler_id, p_group_pl_id,
                           p_group_oipl_id, p_access_cd_to, p_comments,
                           l_emp_person_id, p_acting_person_id, p_grp_pl_name, p_grp_pl_for_strt_dt,
                           p_grp_pl_for_end_dt, l_ovn , p_requestor_name);--process;
       elsif l_access_cd = 'UP' AND p_access_cd_to = 'RO' then
        --
	if g_debug then
          hr_utility.set_location('Entering: '|| l_proc, 196);
        end if;
        --
	update_group_budget ( p_validate, l_per_in_ler_id, p_group_pl_id,
                           p_group_oipl_id, p_access_cd_to, p_comments,
                           l_emp_person_id, p_acting_person_id, p_grp_pl_name, p_grp_pl_for_strt_dt,
                           p_grp_pl_for_end_dt, l_ovn , p_requestor_name);--process;
       elsif l_access_cd = 'RO' AND p_access_cd_to = 'NA' then
        --
	if g_debug then
          hr_utility.set_location('Entering: '|| l_proc, 197);
        end if;
        --
	update_group_budget ( p_validate, l_per_in_ler_id, p_group_pl_id,
                           p_group_oipl_id, p_access_cd_to, p_comments,
                           l_emp_person_id, p_acting_person_id, p_grp_pl_name, p_grp_pl_for_strt_dt,
                           p_grp_pl_for_end_dt, l_ovn , p_requestor_name);--process;
       elsif l_access_cd = 'UP' AND p_access_cd_to = 'RO' then
        --
	if g_debug then
          hr_utility.set_location('Entering: '|| l_proc, 198);
        end if;
        --
	update_group_budget ( p_validate, l_per_in_ler_id, p_group_pl_id,
                           p_group_oipl_id, p_access_cd_to, p_comments,
                           l_emp_person_id, p_acting_person_id, p_grp_pl_name, p_grp_pl_for_strt_dt,
                           p_grp_pl_for_end_dt, l_ovn , p_requestor_name);--process;
       else
         --
	 if g_debug then
           hr_utility.set_location('Condition not found:'|| l_proc, 200);
         end if;
         --
	 -- Will set to 'Y' , to throw warning message
	 --
	 l_throw_exp := 'Y';
	 p_throw_exp := l_throw_exp;
       end if;
     else
       --
       --Update as usual if not Submitted/Approved
       --
       --
       if g_debug then
         hr_utility.set_location('Entering: '|| l_proc, 210);
       end if;
       --
       update_group_budget ( p_validate, l_per_in_ler_id, p_group_pl_id,
                           p_group_oipl_id, p_access_cd_to, p_comments,
                           l_emp_person_id, p_acting_person_id, p_grp_pl_name, p_grp_pl_for_strt_dt,
                           p_grp_pl_for_end_dt, l_ovn , p_requestor_name);
     end if;
      --
    end loop;
    close fetch_search_managers ;
  end if;
end if;
--
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 220);
end if;
--
END update_access;
--
END ben_cwb_change_access;  -- End of Package.

/

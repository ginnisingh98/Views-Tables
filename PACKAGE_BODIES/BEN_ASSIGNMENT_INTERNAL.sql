--------------------------------------------------------
--  DDL for Package Body BEN_ASSIGNMENT_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ASSIGNMENT_INTERNAL" as
/* $Header: beasgbsi.pkb 120.5.12010000.5 2010/02/09 09:15:57 sallumwa ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_assignment_internal.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_second_event >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_second_event
  (p_person_id         in     number
  ,p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_contact_type      in     varchar2
  ,p_death             in     boolean
  )
is
  --
  l_proc             varchar2(72):=g_package||'check_second_event';
  --
  -- Declare cursors and local variables
  --
  cursor c1 is
    select null
    from   per_person_type_usages_f ptu,
           per_person_types ppt
    where  ptu.person_id = p_person_id
    and    p_effective_date
           between ptu.effective_start_date
           and     ptu.effective_end_date
    and    ptu.person_type_id = ppt.person_type_id
    and    ppt.system_person_type = decode(p_contact_type,
                                           'S','SRVNG_SPS',
                                           'D','SRVNG_DP',
                                           'R','SRVNG_DPFM',
                                           'SRVNG_FMLY_MMBR');
  --
  l_dummy varchar2(1);
  l_type  varchar2(30);
  l_ptu_id  number;
  l_pet_id  number;
  l_ptu_ovn number;
  l_esd     date;
  l_eed     date;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  -- Test if a death occurred then we have to create frmr types, etc
  --
  if not p_death then
    --
    return;
    --
  end if;
  --
  -- First check if person type usage already exists for person
  -- If it does do not create it.
  --
  open c1;
    --
    fetch c1 into l_dummy;
    --
    if c1%notfound then
      --
      -- Create the appropriate usages
      --
      if p_contact_type = 'S' then
        --
        l_type := 'SRVNG_SPS';
        --
      elsif p_contact_type = 'D' then
        --
        l_type := 'SRVNG_DP';
        --
      elsif p_contact_type = 'R' then
        --
        l_type := 'SRVNG_DPFM';
        --
      else
        --
        l_type := 'SRVNG_FMLY_MMBR';
        --
      end if;
      --
      select person_type_id
      into   l_pet_id
      from   per_person_types
      where  business_group_id = p_business_group_id
      and    system_person_type = l_type
      and    default_flag = 'Y' ;   -- Bug 3878962
      --
      hr_per_type_usage_internal.create_person_type_usage
        (p_person_id             => p_person_id
        ,p_person_type_id        => l_pet_id
        ,p_effective_date        => p_effective_date
         --
        ,p_person_type_usage_id  => l_ptu_id
        ,p_object_version_number => l_ptu_ovn
        ,p_effective_start_date  => l_esd
        ,p_effective_end_date    => l_eed);
      --
    end if;
    --
  close c1;
  --
  hr_utility.set_location('Leaving: '||l_proc,10);
  --
end check_second_event;

-- ----------------------------------------------------------------------------
-- |-------------------------< check_person_type>------------------------------|
-- this validate whether the person_type_usage already exist
-- this was added  due to the new flag added in organisation level to stop
-- the creation of  benefit assignment
-- so far the duplicate validation is done against benefit asg level
-- which wont work when the ben_Asg creations is set to 'N'
--
-- ----------------------------------------------------------------------------

procedure  check_person_type(
                    p_person_type_id       in     number
                   ,p_person_id            in     number
                   ,p_effective_date       in     date     default null
                   ,p_person_type_usage_id in     number default null
                   ,p_type_exist           out nocopy    varchar2  )
is

l_proc        varchar2(72) := g_package||' chk_person_type';
l_person_type             per_person_types.system_person_type%TYPE;
l_business_group_id       per_person_types.business_group_id%TYPE;
l_person_type_id          number;

  cursor csr_valid_person_type ( lc_person_type_id number)
    is
    select system_person_type ,business_group_id
    from per_person_types
    where person_type_id = lc_person_type_id;

 -- We are doing this check regardless of the enabled flag
 -- as even old records must be used for this validation
  cursor csr_check_uniqueness is
    select person_type_usage_id
    from per_person_type_usages_f
    where person_type_id in ( select person_type_id
                              from per_person_types
                              where system_person_type = l_person_type
                              and business_group_id = l_business_group_id )
    and   person_id      = p_person_id
    and   ((effective_start_date <= p_effective_date and
           effective_end_date   >= p_effective_date) or
          (effective_start_date >= p_effective_date));



begin
    hr_utility.set_location('Entering: '||l_proc,10);
    p_type_exist := 'N' ;
    open csr_valid_person_type(p_person_type_id);
    fetch csr_valid_person_type into l_person_type , l_business_group_id;
    if csr_valid_person_type%notfound then
       close csr_valid_person_type;
       --- the forefigh key validated in per  peckages
       return ;
    end if;
    close csr_valid_person_type;

    open csr_check_uniqueness;
    fetch csr_check_uniqueness into l_person_type_id;
    if csr_check_uniqueness%found then
       p_type_exist := 'Y' ;
    end if;
    close csr_check_uniqueness;
    hr_utility.set_location('Leaving: '||l_proc,10);
end check_person_type ;
-- ----------------------------------------------------------------------------
-- |-------------------------< copy_empasg_to_benasg >------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_empasg_to_benasg
  (p_person_id             in     number
  --
  ,p_pds_atd               in     date     default null
  ,p_pds_leaving_reason    in     varchar2 default null
  ,p_pds_fpd               in     date     default null
  ,p_per_date_of_death     in     date     default null
  ,p_per_marital_status    in     varchar2 default null
  ,p_per_esd               in     date     default null
  ,p_dpnt_person_id        in     number   default null
  ,p_redu_hrs_flag         in     varchar2 default 'N'
  ,p_effective_date        in     date     default null
  --
  ,p_assignment_id            out nocopy number
  ,p_object_version_number    out nocopy number
  ,p_perhasmultptus           out nocopy boolean
  )
is
  --
  l_proc             varchar2(72):=g_package||'copy_empasg_to_benasg';
  --
  -- Declare cursors and local variables
  --
  Type PerDetailsType      is record
    (per_id      per_contact_relationships.contact_person_id%TYPE
    ,contype     varchar2(100)
    );
  Type PerDetails      is table of PerDetailsType     index by binary_integer;
  --
  Type Var2Datatype  is table of varchar2(100)  index by binary_integer;
  --
  -- Declare cursors and local variables
  --
  l_perdetails_set   PerDetails;
  l_ptupetspt_set    Var2Datatype;
  l_asg_dets         per_all_assignments_f%ROWTYPE;
  l_plstab_count     binary_integer;
  --
  l_v2dummy          varchar2(1);
  --
  l_copybenasg       boolean;
  l_divorce          boolean;
  l_death            boolean;
  l_terminate        boolean;
  l_leg_code         varchar2(100);
  l_bgp_id           number;
  l_emp_perid        number;
  l_empasg_effdate   date;
  l_benasg_effdate   date;
  l_asg_id           number;
  l_asg_ovn          number;
  l_asg_esd          date;
  l_aei_id           number;
  l_aei_ovn          number;
  l_assignment_id    number;
  l_pet_id           number;
  l_per_id           number;
  l_ctr_contype      varchar2(100);
  --
  l_date_dummy1      date;
  l_date_dummy2      date;
  l_date_dummy3      date;
  l_date_dummy4      date;
  l_number_dummy1    number;
  l_number_dummy2    number;
  l_number_dummy3    number;
  l_number_dummy4    number;
  l_boolean_dummy1   boolean;
  l_boolean_dummy2   boolean;
  l_boolean_dummy3   boolean;
  l_boolean_dummy4   boolean;
  l_varchar2_dummy1  varchar2(1000);
  l_varchar2_dummy2  varchar2(1000);
  --
  l_business_group_id         number;
  l_period_of_service_id      number;
  l_assignment_status_type_id number;
  l_person_id                 number;
  l_organization_id           number;
  l_assignment_number         varchar2(200);
  l_atd_dtfmstr               varchar2(200);
  l_dtupdate_mode             varchar2(200);
  l_empasg_ovn                number;
  l_prevempasg_ovn            number;
  l_perpet_spt                varchar2(200);
  l_ptu_id                    number;
  l_ptu_ovn                   number;
  l_esd                       date;
  l_eed                       date;
  l_benasg_id                 number;
  l_benasg_esd                date;
  l_empasg_esd                date;
  l_asg_payroll_id            number;
  l_origpayroll_id            number;
  l_emp_pyp_id                number;
  l_emp_salary                varchar2(100);
  l_benasg_pyp_id             number;
  l_benasg_ovn                number;
  l_tmpeffdate_str            varchar2(200);
  l_dummy                     varchar2(200);
  l_dummy1_id                 number;
  l_booldummy_1               boolean;
  l_booldummy_2               boolean;
  l_booldummy_3               boolean;
  l_booldummy_4               boolean;
  l_age                       varchar2(100);
  l_adj_serv_date             date;
  l_orig_hire_date            date;
  l_payroll_changed           varchar2(100);
  l_orig_payroll_id           varchar2(100);
  l_salary                    varchar2(100);
  l_termn_date                date;
  l_termn_reason              varchar2(100);
  l_abs_date                  date;
  l_date_of_hire              date;
  l_abs_type                  varchar2(100);
  l_abs_reason                varchar2(100);
  l_fammem                    boolean;
  l_prptupet_spt              varchar2(100);
  l_count                     number;
  l_pet_spt                   varchar2(1000);
  l_contacts                  boolean default FALSE;
  l_perele_num                pls_integer;
  l_act_pos                   varchar2(1);
  l_exists                    boolean default false;
  lc_effective_date           date;
  l_type_exist                varchar2(1) ;
  l_prior_marital_status      per_all_people_f.marital_status%type;
  --
  cursor c_getbgpdets
    (c_person_id in number
    ,c_effective_date in date
    )
  Is
    select  bgp.business_group_id,
	    bgp.legislation_code,
            pet.system_person_type
    from    per_business_groups bgp,
            per_all_people_f per,
            per_person_types pet
    where   per.business_group_id = bgp.business_group_id
    and     per.person_type_id = pet.person_type_id
    and     per.person_id      = c_person_id
    and     c_effective_date between per.effective_start_date   -- Bug No 4451864 Removed -1 from the c_effective_date
                                 and per.effective_end_date;
  --
  cursor c_get_ss_fm_dets
    (c_person_id    in     number
    ,c_eff_date     in     date
    ,c_contact_type in     varchar2
    )
  is
    select  ctr.contact_person_id, ctr.contact_type
    from    per_contact_relationships ctr
    where   ctr.person_id = c_person_id
    and     c_eff_date
    between nvl(ctr.date_start,hr_api.g_sot) and nvl(ctr.date_end,hr_api.g_eot)
    and     ctr.contact_type = c_contact_type
    order by ctr.sequence_number;
  --
  cursor c_getdpntperdets
    (c_person_id    in     number
    ,c_eff_date     in     date
    )
  is
    select distinct ctr.contact_person_id
    from  per_contact_relationships ctr
    where exists
              (select null
               from per_person_type_usages_f ptu,
                    per_person_types pet
               where ctr.contact_person_id  = ptu.person_id
               and   ptu.person_type_id     = pet.person_type_id
               and   pet.system_person_type = 'DPNT'
               and   c_eff_date between ptu.effective_start_date and ptu.effective_end_date)
    and  ctr.person_id = c_person_id
    and  ctr.personal_flag = 'Y'
    and  c_eff_date between nvl(ctr.date_start,hr_api.g_sot) and nvl(ctr.date_end,hr_api.g_eot)
    order by ctr.contact_person_id;
  --
  cursor c_get_all_contacts
    (c_person_id           in number
    ,c_contact_person_id   in number default null
    ,c_eff_date            in date
    )
  is
    select  ctr.contact_person_id, ctr.contact_type
    from    per_contact_relationships ctr
    where   ctr.person_id = c_person_id
    and     ctr.contact_person_id = nvl(c_contact_person_id, ctr.contact_person_id)
    and     ctr.personal_flag = 'Y'
    and     c_eff_date
    between nvl(ctr.date_start,hr_api.g_sot) and nvl(ctr.date_end,hr_api.g_eot)
    order by ctr.sequence_number;
  --
  cursor c_get_contacts
    (c_person_id           in number
    ,c_contact_person_id   in number default null
    ,c_eff_date            in date
    )
  is
    select  ctr.contact_person_id, ctr.contact_type
    from    per_contact_relationships ctr
    where   ctr.person_id = c_person_id
    and     ctr.contact_person_id = nvl(c_contact_person_id, ctr.contact_person_id)
    and     ctr.personal_flag = 'Y'
    order by ctr.sequence_number;
  --
  cursor c_getbenasgid
    (c_person_id in number
    )
  Is
    select  asg.assignment_id,
            asg.object_version_number,
            asg.effective_start_date
    from    per_all_assignments_f asg
    where   asg.person_id = c_person_id
    and     asg.assignment_type = 'B';
  --
  cursor c_getbenasgdets
    (c_person_id in number
    ,c_eff_date  in date
    )
  Is
    select  null
    from    per_all_assignments_f asg
    where   asg.person_id = c_person_id
    and     asg.assignment_type = 'B'
    and     c_eff_date
      between asg.effective_start_date and asg.effective_end_date;
  --
  -- WWBUG 1202148. handles issue with dt position being ended for federal
  -- at same tine assignment is ended. this causes an error condition in
  -- the create assignment api.
  --
  cursor c_getdt_pos
    (c_position_id in NUMBER
    ,c_eff_date in DATE)
  is
  select 'Y'
  from     hr_positions_f hp
             , per_shared_types ps
  where    hp.position_id    = c_position_id
  and      c_eff_date
  between  hp.date_effective
  and      nvl(hp.date_end, hr_api.g_eot)
  and      ps.shared_type_id = hp.availability_status_id
  and      ps.system_type_cd = 'ACTIVE' ;
  --
  cursor c_getempprasgdets
    (c_person_id in     number
    ,c_eff_date  in     date
    )
  Is
    select  *
    from    per_all_assignments_f asg
    where   asg.person_id = c_person_id
    and     asg.assignment_type = 'E'
    and     asg.primary_flag = 'Y'
    and     c_eff_date
      between asg.effective_start_date and asg.effective_end_date;
  -- 2852514
  cursor c_petprimasgdets
    (c_person_id in     number
    ,c_eff_date  in     date
     )
  Is
    select  *
    from    per_all_assignments_f asg
    where   asg.person_id = c_person_id
    and     asg.primary_flag = 'Y'
    and     c_eff_date
      between asg.effective_start_date and asg.effective_end_date;


  cursor c_getasgdtinsdets
    (c_assignment_id in     number
    ,c_eff_date      in     date
    )
  Is
    select  asg.object_version_number,
            asg.effective_start_date
    from    per_all_assignments_f asg
    where   asg.assignment_id = c_assignment_id
    and     c_eff_date
      between asg.effective_start_date and asg.effective_end_date;
  --
  cursor c_getasgovndtinsdets
    (c_assignment_id in     number
    ,c_ovn           in     number
    )
  Is
    select  null
    from    per_all_assignments_f asg
    where   asg.assignment_id = c_assignment_id
    and     asg.object_version_number = c_ovn;
  --
  cursor c_getaeidets
    (c_assignment_id in     number
    )
  Is
    select  aei.aei_information4,
            aei.aei_information5
    from    per_assignment_extra_info aei
    where   aei.assignment_id = c_assignment_id
    and     aei.information_type = 'BEN_DERIVED';
  --
  cursor c_getpypdets
    (c_pyp_id in     number
    )
  Is
    select  *
    from    per_pay_proposals
    where   pay_proposal_id = c_pyp_id;
  --
  cursor c_getbgpdefpet
    (c_bgp_id  in     number
    ,c_pet_spt in     varchar2
    )
  Is
    select  pet.person_type_id
    from    per_person_types pet
    where   pet.business_group_id = c_bgp_id
    and     pet.system_person_type = c_pet_spt
    and     pet.default_flag = 'Y';
  --
  cursor c_getperptupetdets
    (c_per_id   in     number
    ,c_eff_date in     date
    ,c_type_cd  in     varchar2 default null
    )
  Is
    select  pet.system_person_type
    from    per_person_type_usages_f ptu, per_person_types pet
    where   ptu.person_type_id = pet.person_type_id
    and     ptu.person_id = c_per_id
    ---- added to test a particular type avaialble # 2852514
    and     pet.system_person_type = nvl(c_type_cd,pet.system_person_type )
    and     c_eff_date
      between ptu.effective_start_date and ptu.effective_end_date;
  --
  cursor c1 is
    select business_group_id
    from   per_all_people_f
    where  person_id = p_person_id;
  --
  cursor c_get_prior_marital_status is
    select per.marital_status
    from   per_all_people_f per
    where  per.person_id = p_person_id
    and    p_per_esd - 1
    between per.effective_start_date and per.effective_end_date;
  ---
  cursor c_dptn_cvg
             ( c_contact_person_id number ,
               c_eff_date date  ) is
     select 'x'
       from  ben_elig_cvrd_dpnt_f pdp,
             ben_prtt_enrt_rslt_f pen
       where pen.person_id = p_person_id
         and pen.prtt_enrt_rslt_id = pdp.prtt_enrt_rslt_id
         and pdp.dpnt_person_id    = c_contact_person_id
         and c_eff_date  between
              pen.effective_start_date and pen.effective_end_date
         and c_eff_date  between
              pdp.effective_start_date and pdp.effective_end_date  ;

  --
  cursor c_get_ben_asgdets(p_business_group_id IN NUMBER)
  Is
  select substr(hoi.ORG_INFORMATION3,1)
  from  hr_organization_information hoi
  where hoi.org_information_context = 'Benefits Defaults'
  and   hoi.organization_id         = p_business_group_id
  ;

  l_ben_asg_status_flag       hr_organization_information.ORG_INFORMATION3%type ;
  l_prev_per_id number;

  l_chk_flag varchar2(1) default 'N';
  --
  procedure copy_emppradd_ctrpradd
    (p_empper_id      in     number
    ,p_ctrper_id      in     number
    ,p_benasg_effdate in     date
    ,p_death          in     boolean
    ,p_divorce        in     boolean
    )
  is
    --
    l_add_dets         per_addresses%ROWTYPE;
    --
    l_ctr_shdresflg    varchar2(100);
    l_ctr_id           number;
    l_ctr_ovn          number;
    l_add_id           number;
    l_add_ovn          number;
    --
    cursor c_getctrdets
      (c_per_id    in     number
      ,c_conper_id in     number
      )
    Is
      select  ctr.rltd_per_rsds_w_dsgntr_flag,
              ctr.contact_relationship_id,
              ctr.object_version_number
      from    per_contact_relationships ctr
      where   ctr.person_id   = c_per_id
      and     ctr.contact_person_id = c_conper_id
      and     p_benasg_effdate between ctr.date_start and nvl(ctr.date_end,p_benasg_effdate);
    --
    cursor c_getpradddets
      (c_per_id    in     number
      )
    Is
      select  *
      from    per_addresses adr
      where   adr.person_id    = c_per_id
      and     adr.primary_flag = 'Y'
      and     p_benasg_effdate between adr.date_from and nvl(adr.date_to,p_benasg_effdate)
      order by adr.date_from desc ;
    --

   /*Added Code for Bug: 7506378*/
    cursor c_chk_future_rec
      (c_per_id    in     number
      )
    Is
      select  min(date_from)
      from    per_addresses adr
      where   adr.person_id    = c_per_id
      and     adr.primary_flag = 'Y'
      and     adr.date_from > p_benasg_effdate;

   l_date_to          date default null;

    /*Ended Code for Bug: 7506378*/

  begin
    --
    -- Copy the primary address from the employee when the
    -- if an address does not exist for the contact.
    --
    open c_getctrdets
      (c_per_id    => p_empper_id
      ,c_conper_id => p_ctrper_id
      );
    fetch c_getctrdets into l_ctr_shdresflg, l_ctr_id, l_ctr_ovn;
    close c_getctrdets;
    hr_utility.set_location(l_proc, 210);
    --
    -- Check if a primary address already exists for the contact
    --
    open c_getpradddets
      (c_per_id    => p_ctrper_id
      );
      --
    fetch c_getpradddets into l_add_dets;
    if c_getpradddets%notfound then
      close c_getpradddets;
      --
      -- Get the primary address details for the employee
      --
      open c_getpradddets
        (c_per_id => p_empper_id
        );
      --
      fetch c_getpradddets into l_add_dets;
      --
      -- Check for the employee primary address
      --
      if c_getpradddets%found then
        --
        close c_getpradddets;
        hr_utility.set_location(l_proc, 220);
        --
        -- Create the primary address for the contact
        --
        if (l_ctr_shdresflg = 'Y' and not p_death and not p_divorce) then -- 5750408
	null; -- do not create address
	else

            /*Added Code for Bug: 7506378*/
            open c_chk_future_rec
                (c_per_id    => p_ctrper_id
                     );
            fetch c_chk_future_rec into l_date_to;
	    close c_chk_future_rec;
	    if(l_date_to is not null) then
	      l_date_to := l_date_to -1;
            end if;
	    /*Ended Code for Bug: 7506378*/

	hr_person_address_api.create_person_address
          (p_effective_date          => p_benasg_effdate
          ,p_person_id               => p_ctrper_id
          ,p_primary_flag            => 'Y'
          ,p_style                   => l_add_dets.style
          ,p_date_from               => p_benasg_effdate
	  ,p_date_to                 => l_date_to -- Added parameter for Bug 7506378
          ,p_address_type            => l_add_dets.address_type
          ,p_address_line1           => l_add_dets.address_line1
          ,p_address_line2           => l_add_dets.address_line2
          ,p_address_line3           => l_add_dets.address_line3
          ,p_town_or_city            => l_add_dets.town_or_city
          ,p_region_1                => l_add_dets.region_1
          ,p_region_2                => l_add_dets.region_2
          ,p_region_3                => l_add_dets.region_3
          ,p_postal_code             => l_add_dets.postal_code
          ,p_country                 => l_add_dets.country
          ,p_telephone_number_1      => l_add_dets.telephone_number_1
          ,p_telephone_number_2      => l_add_dets.telephone_number_2
          ,p_telephone_number_3      => l_add_dets.telephone_number_3
          ,p_addr_attribute_category => l_add_dets.addr_attribute_category
          ,p_addr_attribute1         => l_add_dets.addr_attribute1
          ,p_addr_attribute2         => l_add_dets.addr_attribute2
          ,p_addr_attribute3         => l_add_dets.addr_attribute3
          ,p_addr_attribute4         => l_add_dets.addr_attribute4
          ,p_addr_attribute5         => l_add_dets.addr_attribute5
          ,p_addr_attribute6         => l_add_dets.addr_attribute6
          ,p_addr_attribute7         => l_add_dets.addr_attribute7
          ,p_addr_attribute8         => l_add_dets.addr_attribute8
          ,p_addr_attribute9         => l_add_dets.addr_attribute9
          ,p_addr_attribute10        => l_add_dets.addr_attribute10
          ,p_addr_attribute11        => l_add_dets.addr_attribute11
          ,p_addr_attribute12        => l_add_dets.addr_attribute12
          ,p_addr_attribute13        => l_add_dets.addr_attribute13
          ,p_addr_attribute14        => l_add_dets.addr_attribute14
          ,p_addr_attribute15        => l_add_dets.addr_attribute15
          ,p_addr_attribute16        => l_add_dets.addr_attribute16
          ,p_addr_attribute17        => l_add_dets.addr_attribute17
          ,p_addr_attribute18        => l_add_dets.addr_attribute18
          ,p_addr_attribute19        => l_add_dets.addr_attribute19
          ,p_addr_attribute20        => l_add_dets.addr_attribute20
          --
          ,p_address_id              => l_add_id
          ,p_object_version_number   => l_add_ovn
	  --Bug 4310174
	  ,p_add_information13       => l_add_dets.add_information13
	  ,p_add_information14       => l_add_dets.add_information14
	  ,p_add_information15       => l_add_dets.add_information15
	  ,p_add_information16       => l_add_dets.add_information16
	  ,p_add_information17       => l_add_dets.add_information17
	  ,p_add_information18       => l_add_dets.add_information18
	  ,p_add_information19       => l_add_dets.add_information19
	  ,p_add_information20       => l_add_dets.add_information20
	  --End Bug 4310174
          );
        end if;
        --
        if l_ctr_shdresflg = 'Y' and
           (p_death or p_divorce)
        then
          --
          -- Set shared residency flag to N.
          --
          hr_contact_rel_api.update_contact_relationship                                   (p_effective_date              => p_benasg_effdate
            ,p_contact_relationship_id     => l_ctr_id
            ,p_rltd_per_rsds_w_dsgntr_flag => 'N'
            ,p_object_version_number       => l_ctr_ovn
            );
          --
        end if;
        --
      else
        --
        close c_getpradddets;
        --
      end if;
      --
    else
      --
      close c_getpradddets;
      --
    end if;
    --
  end;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory arguments
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'person_id',
     p_argument_value => p_person_id
     );
  --
  -- Check if either of the following are occuring or has occured
  --
  -- - Employee termination - PDS ATD is set
  -- - Employee death       - PER DOD is set
  -- - Employee divorce     - PER marital status is D or L
  --
  open c1;
    --
    fetch c1 into l_business_group_id;
    --
  close c1;
  --

  -- when the  default assgnement is not Y or N then
  -- do nothing  # 3899506
  open c_get_ben_asgdets(l_business_group_id);
  fetch c_get_ben_asgdets into l_ben_asg_status_flag;
  close c_get_ben_asgdets;


  hr_utility.set_location ( ' ben_asg_status_flag ' || l_ben_asg_status_flag , 99 ) ;

  if NVL(l_ben_asg_status_flag,'N') not in ('Y','N')
  then
    return;
  end if;
  --
  if p_per_date_of_death is not null and p_per_esd is not null
     and p_per_date_of_death < p_per_esd
  then
      -- this is possible when entering history for person.
      -- father expires before childs birth and enter contact details of father.
      return ;
  end if;

  if p_pds_atd is not null
    or p_per_date_of_death is not null
    or p_per_marital_status in ('D','L') and p_per_esd is not null
    or p_dpnt_person_id is not null
    or p_redu_hrs_flag  = 'Y'
  then
    hr_utility.set_location('Entering:'|| l_proc, 20);
    --
    -- Get the business group details
    --
/*
    open c_getbgpdets(p_person_id
                     ,nvl(p_pds_atd,
                          nvl(p_per_date_of_death,
                              nvl(p_per_esd, p_effective_date)))
      );
    fetch c_getbgpdets Into l_bgp_id, l_leg_code, l_perpet_spt;
    If c_getbgpdets%notfound then
      close c_getbgpdets;
      --
      --  A benefits assignment cannot be created for the employee.
      --  The employee does not exist.
      --
      hr_utility.set_message(801,'BEN_92112_NOBENASGEMP');
      hr_utility.raise_error;
      --
    End If;
    close c_getbgpdets;
*/
    lc_effective_date := nvl(p_pds_atd,
                          nvl(p_per_date_of_death,
                              nvl(p_per_esd, p_effective_date)));
    --
    open c_getbgpdets(p_person_id
                     ,lc_effective_date
      );
    fetch c_getbgpdets Into l_bgp_id, l_leg_code, l_perpet_spt;
    If c_getbgpdets%notfound then
      close c_getbgpdets;
      --
      -- Bug 1857193
      -- In case of termination and death above lc_effective_date
      -- holds good. In the following case above cursor does not work.
      -- Create employee with divorce status or correct status to divorce
      -- 1. Create person on 01/01/01, with divorce status OR
      -- 2. Create person on 01/01/01 and do date correction of
      --    marital status to DIVORCE.
      -- the date cursor c_getbgpdets uses  31-dec-00
      -- It errors out with BEN_92112_NOBENASGEMP.
      --
      lc_effective_date := lc_effective_date + 1;
      open c_getbgpdets(p_person_id
                     ,lc_effective_date
        );
      fetch c_getbgpdets Into l_bgp_id, l_leg_code, l_perpet_spt;
      If c_getbgpdets%notfound then
        close c_getbgpdets;
        --  A benefits assignment cannot be created for the employee.
        --  The employee does not exist.
        --
        hr_utility.set_message(801,'BEN_92112_NOBENASGEMP');
        hr_utility.raise_error;
        --
      end if;
    End If;
    close c_getbgpdets;
    hr_utility.set_location('Entering:'|| l_proc, 30);
    --
    -- Check that the system person type is an employee related
    -- person type
    --
    if l_perpet_spt not in ('OTHER') then
      --
      l_copybenasg := TRUE;
      --
    else

      --
      l_copybenasg := FALSE;
      --
      --- If the contact is particpant then allow to create the ben asg for the dpnt # 2852514
      --- the date -1 used that he might have losed the participation today the asg may be creadted
      --- because of that
      hr_utility.set_location (' OTHER lc_effective_date ' || lc_effective_date , 991 );
      open  c_getperptupetdets
            (p_person_id
            ,lc_effective_date            -- Bug No 4451864 Removed -1 from lc_effective_date
            ,'PRTN'
            ) ;
      fetch c_getperptupetdets into l_dummy ;
      if  c_getperptupetdets%found then
          hr_utility.set_location ('  l_copybenasg  TRUE  '  , 991 );
           l_copybenasg := TRUE;
      end if ;
      close c_getperptupetdets ;

    end if;
    --
  else
    --
    l_copybenasg := FALSE;
    --
  end if;
  --
  -- Check that OAB is installed in a US legislation
  --
  if l_copybenasg then
    hr_utility.set_location('Entering:'|| l_proc, 40);
    --
    -- Deduce effective dates and determine if to create a benefits assignment for
    -- the employee or the surviving spouse based on the event
    --
    l_divorce             := FALSE;
    l_death               := FALSE;
    l_copybenasg          := FALSE;
    --
    -- Event checks
    --
    -- - Date of death set on the person
    --
    if p_per_date_of_death is not null
    then
      hr_utility.set_location(l_proc, 50);
      --
      -- Death of an employee - date of death set
      --
      l_empasg_effdate := p_per_date_of_death;
      l_benasg_effdate := p_per_date_of_death+1;
      --
      l_copybenasg := TRUE;
      l_death      := TRUE;
    --
    -- - Divorce or legal separation of a person
    --
    elsif p_per_marital_status in ('D','L')
      and p_per_esd is not null
    then
      hr_utility.set_location('divorce '|| l_proc, 60);
      hr_utility.set_location('p_per_esd '|| p_per_esd, 60);
      --
      --  If the marital status has not changed, do not update or
      --  create a benefits assignment.
      --
      open c_get_prior_marital_status;
      fetch c_get_prior_marital_status into l_prior_marital_status;
      if c_get_prior_marital_status%found then
        hr_utility.set_location('l_prior_marital_status '|| l_prior_marital_status, 60);
        hr_utility.set_location('p_per_marital_status '|| p_per_marital_status, 60);
        if nvl(l_prior_marital_status,'NULL') <> p_per_marital_status then
          hr_utility.set_location('create asg ', 60);
          --
          -- The benefit assignment and person type usage information
          -- are created on the day of the divorce or legal separation
          --
          l_empasg_effdate := p_per_esd;
          l_benasg_effdate := p_per_esd;
          --
          l_copybenasg := TRUE;
          l_divorce    := TRUE;
          --
        else
          l_copybenasg := false;
        end if;
      --
      else -- If prior marital status is not found
          hr_utility.set_location('not found ', 60);
        l_copybenasg := false;
      end if;
      --
      close c_get_prior_marital_status;
      --
    --
    -- No leaving reason set and termination leaving reasons
    --
    elsif p_pds_atd is not null
      and nvl(p_pds_leaving_reason,hr_api.g_varchar2) not in('D')
    then
      hr_utility.set_location(l_proc, 90);
      --
      -- Terminating an employee with leaving reason not deceased
      --
      l_empasg_effdate := p_pds_atd;
      l_benasg_effdate := p_pds_atd+1;
      --
      l_copybenasg := TRUE;
      l_terminate  := TRUE;
    --
    -- Deceased leaving reason
    --
    elsif p_pds_atd is not null
      and p_pds_leaving_reason = 'D'
    then
      hr_utility.set_location(l_proc, 100);
      --
      -- Terminating an employee with leaving reason deceased
      --
      l_empasg_effdate := p_pds_atd;
      l_benasg_effdate := p_pds_atd+1;
      --
      l_copybenasg := TRUE;
      l_death      := TRUE;
      --
    elsif (p_dpnt_person_id is not null or
           p_redu_hrs_flag = 'Y') then
      --
      l_empasg_effdate := p_effective_date;
      l_benasg_effdate := p_effective_date;
      l_copybenasg := TRUE;
      l_contacts := TRUE;
      --
    end if;
    --
    -- Check if to copy the emp assignment to the benefits assignment
    --
    if l_copybenasg then
      hr_utility.set_location(l_proc, 120);
      --
      -- Get primary employee assignment details
      --
      open c_getempprasgdets(p_person_id,l_empasg_effdate);
      fetch c_getempprasgdets Into l_asg_dets;
      ---- when dpnt's dpnt get the  benefit asg  there wont be any
      ---  employee assignmnet so pickup from primary asg available # 2852514
      ---  asked siok to answer  the primary can be used for all who is not having Emp asg.
      if  c_getempprasgdets%notfound  then
          open c_petprimasgdets(p_person_id,l_empasg_effdate);
          fetch c_petprimasgdets Into l_asg_dets;
          if c_petprimasgdets%notfound then
             l_copybenasg := false ;
          end if;
          close  c_petprimasgdets ;
          hr_utility.set_location('Geting asg detail from prim asg', 120);
      end if ;

      close c_getempprasgdets;
      hr_utility.set_location(l_proc, 130);
      --
      -- IS position still active?
      --
      --
      if l_asg_dets.position_id is not null
      then

        -- WWBug 2178374 - Added code to pass l_benasg_effdate to the cursor if p_effective_date is null

        open c_getdt_pos(l_asg_dets.position_id,nvl(p_effective_date,l_benasg_effdate));
        fetch c_getdt_pos into l_act_pos;
        if c_getdt_pos%NOTFOUND then
          --
          -- At this point we have a position that
          -- does not exists as of the time of the benefit assignments
          -- creation, but did when the assignment existed, we need to
          -- null the assignment as it will cause benefits assignment
          -- insert to fail.
          l_asg_dets.position_id := NULL;
        end if;
      end if;
      --
      -- Is probation end after assignment start
      --
      if l_asg_dets.date_probation_end < l_benasg_effdate then
        --
        l_asg_dets.date_probation_end := null;
        l_asg_dets.probation_period := null;
        l_asg_dets.probation_unit := null;
        --
      end if;
      --
      -- Check for death and divorce events
      --
      if l_death
        or l_divorce
      then
        --
        -- Get spouse details without benefit assignments
        --
        hr_utility.set_location(l_proc, 140);
        hr_utility.set_location(l_proc||' l_ba_edate: '||l_benasg_effdate, 140);
        --
        l_per_id      := null;
        l_ctr_contype := null;
        --
        open c_get_ss_fm_dets
          (c_person_id    => p_person_id
          ,c_eff_date     => l_benasg_effdate
          ,c_contact_type => 'S'
          );
        fetch c_get_ss_fm_dets Into l_per_id, l_ctr_contype;
        close c_get_ss_fm_dets;
        --
        hr_utility.set_location(l_proc||' SPS l_per_id: '||l_per_id, 141);
        --
        l_plstab_count := 0;
        --
        If l_per_id is not null
        then
          check_bnft_asgn
            (p_person_id      => l_per_id
            --RCHASE BENASG bug fix Start
            ,p_emp_person_id  => p_person_id
            --RCHASE End
            ,p_effective_date => l_benasg_effdate
            ,p_asg_dets       => l_asg_dets
            ,p_exists         => l_exists
            );
          --
          if l_exists = true then
            --
            check_second_event
              (p_person_id         => l_per_id
              ,p_business_group_id => l_business_group_id
              ,p_effective_date    => l_benasg_effdate
              ,p_contact_type      => 'S'
              ,p_death             => l_death);
            --
          end if;
          --
          if l_exists = false then
            l_perdetails_set(l_plstab_count).per_id  := l_per_id;
            l_perdetails_set(l_plstab_count).contype := l_ctr_contype;
             hr_utility.set_location('count and type '||l_plstab_count||' '||l_ctr_contype,10);
            l_plstab_count   := l_plstab_count+1;


          end if;
          --
          hr_utility.set_location('PL_STA AFTER SPS'||l_plstab_count,10);
        end if;
        --
        --  Domestic Partner.
        --
        l_per_id      := null;
        l_ctr_contype := null;
        --
        open c_get_ss_fm_dets
          (c_person_id    => p_person_id
          ,c_eff_date     => l_benasg_effdate
          ,c_contact_type => 'D'
          );
        fetch c_get_ss_fm_dets Into l_per_id, l_ctr_contype;
        close c_get_ss_fm_dets;
        --
        hr_utility.set_location(l_proc||' DP l_per_id: '||l_per_id, 141);
        --
        -- tilak l_plstab_count := 0;
        --
        If l_per_id is not null
        then
          check_bnft_asgn
            (p_person_id      => l_per_id
            --RCHASE BENASG bug fix Start
            ,p_emp_person_id  => p_person_id
            --RCHASE End
            ,p_effective_date => l_benasg_effdate
            ,p_asg_dets       => l_asg_dets
            ,p_exists         => l_exists
            );
          --
          if l_exists = true then
            --
            check_second_event
              (p_person_id         => l_per_id
              ,p_business_group_id => l_business_group_id
              ,p_effective_date    => l_benasg_effdate
              ,p_contact_type      => 'D'
              ,p_death             => l_death);
            --
          end if;
          --
          if l_exists = false then
            l_perdetails_set(l_plstab_count).per_id  := l_per_id;
            l_perdetails_set(l_plstab_count).contype := l_ctr_contype;
            l_plstab_count   := l_plstab_count+1;
          end if;
          --
          hr_utility.set_location('PL_STA AFTER SPS'||l_plstab_count,10);
        end if;
        --
        -- Populate the family member person id set for Child, Foster Child
        -- Step Child and Adopted Child
        --
        hr_utility.set_location(l_proc||' Family Member: ', 140);
        --
        -- Child
        --
        for per_id in c_get_ss_fm_dets
          (c_person_id    => p_person_id
          ,c_eff_date     => l_benasg_effdate
          ,c_contact_type => 'C'
          )
        loop
          --
          --  If benefit assignment exist, update it.
          --
          check_bnft_asgn
            (p_person_id      => per_id.contact_person_id
            --RCHASE BENASG bug fix Start
            ,p_emp_person_id  => p_person_id
            --RCHASE End
            ,p_effective_date => l_benasg_effdate
            ,p_asg_dets       => l_asg_dets
            ,p_exists         => l_exists
            );
          --
          if l_exists = true then
            --
            check_second_event
              (p_person_id         => per_id.contact_person_id
              ,p_business_group_id => l_business_group_id
              ,p_effective_date    => l_benasg_effdate
              ,p_contact_type      => 'C'
              ,p_death             => l_death);
            --
          end if;
          if l_exists = false then
            l_fammem                                     := TRUE;
            l_perdetails_set(l_plstab_count).per_id      := per_id.contact_person_id;
            l_perdetails_set(l_plstab_count).contype := per_id.contact_type;
            l_plstab_count                               := l_plstab_count+1;
          end if;
          --
        end loop;
        --
        -- Foster Child
        --
        for per_id in c_get_ss_fm_dets
          (c_person_id    => p_person_id
          ,c_eff_date     => l_benasg_effdate
          ,c_contact_type => 'O'
          )
        loop
          --
          --  If benefit assignment exist, update it.
          --
          check_bnft_asgn
            (p_person_id      => per_id.contact_person_id
            --RCHASE BENASG bug fix Start
            ,p_emp_person_id  => p_person_id
            --RCHASE End
            ,p_effective_date => l_benasg_effdate
            ,p_asg_dets       => l_asg_dets
            ,p_exists         => l_exists
            );
            --
          if l_exists = true then
            --
            check_second_event
              (p_person_id         => per_id.contact_person_id
              ,p_business_group_id => l_business_group_id
              ,p_effective_date    => l_benasg_effdate
              ,p_contact_type      => 'O'
              ,p_death             => l_death);
            --
          end if;
          if l_exists = false then
            l_fammem                                     := TRUE;
            l_perdetails_set(l_plstab_count).per_id      := per_id.contact_person_id;
            l_perdetails_set(l_plstab_count).contype := per_id.contact_type;
            l_plstab_count                               := l_plstab_count+1;
          end if;
          --
        end loop;
        --
        -- Step Child
        --
        for per_id in c_get_ss_fm_dets
          (c_person_id    => p_person_id
          ,c_eff_date     => l_benasg_effdate
          ,c_contact_type => 'T'
          )
        loop
          --
          --  If benefit assignment exist, update it.
          --
          check_bnft_asgn
            (p_person_id      => per_id.contact_person_id
            --RCHASE BENASG bug fix Start
            ,p_emp_person_id  => p_person_id
            --RCHASE End
            ,p_effective_date => l_benasg_effdate
            ,p_asg_dets       => l_asg_dets
            ,p_exists         => l_exists
            );
          --
          if l_exists = true then
            --
            check_second_event
              (p_person_id         => per_id.contact_person_id
              ,p_business_group_id => l_business_group_id
              ,p_effective_date    => l_benasg_effdate
              ,p_contact_type      => 'T'
              ,p_death             => l_death);
            --
          end if;
          if l_exists = false then
            l_fammem                                     := TRUE;
            l_perdetails_set(l_plstab_count).per_id      := per_id.contact_person_id;
            l_perdetails_set(l_plstab_count).contype := per_id.contact_type;
            l_plstab_count                               := l_plstab_count+1;
          end if;
          --
        end loop;
        --
        -- Adopted Child
        --
        for per_id in c_get_ss_fm_dets
          (c_person_id    => p_person_id
          ,c_eff_date     => l_benasg_effdate
          ,c_contact_type => 'A'
          )
        loop
          --
          --  If benefit assignment exist, update it.
          --
          check_bnft_asgn
            (p_person_id      => per_id.contact_person_id
            --RCHASE BENASG bug fix Start
            ,p_emp_person_id  => p_person_id
            --RCHASE End
            ,p_effective_date => l_benasg_effdate
            ,p_asg_dets       => l_asg_dets
            ,p_exists         => l_exists
            );
          --
          if l_exists = true then
            --
            check_second_event
              (p_person_id         => per_id.contact_person_id
              ,p_business_group_id => l_business_group_id
              ,p_effective_date    => l_benasg_effdate
              ,p_contact_type      => 'A'
              ,p_death             => l_death);
            --
          end if;
          if l_exists = false then
            l_fammem                                     := TRUE;
            l_perdetails_set(l_plstab_count).per_id      := per_id.contact_person_id;
            l_perdetails_set(l_plstab_count).contype := per_id.contact_type;
            l_plstab_count                               := l_plstab_count+1;
          end if;
          --
        end loop;
        --
        -- Domestic Partner Child
        --
        for per_id in c_get_ss_fm_dets
          (c_person_id    => p_person_id
          ,c_eff_date     => l_benasg_effdate
          ,c_contact_type => 'R'
          )
        loop
          --
          --  If benefit assignment exist, update it.
          --
          check_bnft_asgn
            (p_person_id      => per_id.contact_person_id
            --RCHASE BENASG bug fix Start
            ,p_emp_person_id  => p_person_id
            --RCHASE End
            ,p_effective_date => l_benasg_effdate
            ,p_asg_dets       => l_asg_dets
            ,p_exists         => l_exists
            );
          --
          if l_exists = true then
            --
            check_second_event
              (p_person_id         => per_id.contact_person_id
              ,p_business_group_id => l_business_group_id
              ,p_effective_date    => l_benasg_effdate
              ,p_contact_type      => 'R'
              ,p_death             => l_death);
            --
          end if;
          if l_exists = false then
            l_fammem                                     := TRUE;
            l_perdetails_set(l_plstab_count).per_id      := per_id.contact_person_id;
            l_perdetails_set(l_plstab_count).contype := per_id.contact_type;
            l_plstab_count                               := l_plstab_count+1;
          end if;
          --
        end loop;
        --
        hr_utility.set_location(l_proc||' CON count: '||l_perdetails_set.count, 147);
        if l_perdetails_set.count = 0 then
          --
          l_copybenasg    := FALSE;
          --
        else
          --
          l_copybenasg    := TRUE;
          --
        end if;
        --
      elsif l_contacts then
        hr_utility.set_location('l_contacts',147);
        --
        l_per_id      := null;
        l_ctr_contype := null;
        --
        l_plstab_count := 0;
        --
        -- Check if benefit assignment exist for dependent.
        -- in a loss of dependent status event.
        --
        if p_dpnt_person_id is not null then
          hr_utility.set_location('p_dpnt_person_id: '||p_dpnt_person_id,147);
          hr_utility.set_location('l_benasg_effdate: '||l_benasg_effdate,147);
          open c_get_contacts
           (c_person_id         => p_person_id
           ,c_contact_person_id => p_dpnt_person_id
           ,c_eff_date          => l_benasg_effdate
           );
          fetch c_get_contacts Into l_per_id, l_ctr_contype;
          if c_get_contacts%found then
            close c_get_contacts;
            --
            --  If benefit assignment exist, update it.
            --
            check_bnft_asgn
              (p_person_id      => l_per_id
              --RCHASE BENASG bug fix Start
              ,p_emp_person_id  => p_person_id
              --RCHASE End
              ,p_effective_date => l_benasg_effdate
              ,p_asg_dets       => l_asg_dets
              ,p_exists         => l_exists
              );
            --
            if l_exists = false then
                 l_perdetails_set(l_plstab_count).per_id      := l_per_id;
                 l_perdetails_set(l_plstab_count).contype := l_ctr_contype;
                 l_plstab_count   := l_plstab_count+1;
            else
              --
              --  Display an informational message in the benmngle log
              --  indicating that a benefit assignment exist has been updated
              --  with the current employee assignment information.
              --
              fnd_message.set_name('BEN','BEN_92552_BNFT_ASSIGN_EXISTS');
              if fnd_global.conc_request_id <> -1 then
                benutils.write(fnd_message.get);
              end if;
              --
            end if;
          else
            close c_get_contacts;
            --
          end if;
        --
        -- Check is benefit assignment exists for all personal contacts
        --
        elsif p_redu_hrs_flag = 'Y' then
          --
          --  Write benefits assignment for participant and all contacts.
          --
          --  If benefit assignment exist, update it.
          --
          check_bnft_asgn
            (p_person_id      => p_person_id
            --RCHASE BENASG bug fix Start
            ,p_emp_person_id  => p_person_id
            --RCHASE End
            ,p_effective_date => l_benasg_effdate
            ,p_asg_dets       => l_asg_dets
            ,p_exists         => l_exists
            );
          --
          if l_exists = false then
            l_perdetails_set(l_plstab_count).per_id  := p_person_id;
            l_perdetails_set(l_plstab_count).contype := null;
            l_plstab_count := l_plstab_count+1;
          else
            --
            --  Display an informational message in the benmngle log
            --  indicating that a benefit assignment exist has been updated
            --  with the current employee assignment information.
            --
            fnd_message.set_name('BEN','BEN_92552_BNFT_ASSIGN_EXISTS');
            if fnd_global.conc_request_id <> -1 then
              benutils.write(fnd_message.get);
            end if;
          end if;
          --
          l_prev_per_id := -999 ;
          for per_id in c_get_all_contacts
            (c_person_id    => p_person_id
            ,c_eff_date     => l_benasg_effdate
            )
          loop
            --
            --  If benefit assignment exist, update it.
            --
	       /* Bug 9028676 : When reduction in hours life type of Life event is processed on the employee,
	       do not update the benefits assignment record of the dependents. Commented the proc call to update
	       the benefits record of the dependent*/
	       open c_getbenasgdets(per_id.contact_person_id,p_effective_date);
	       fetch c_getbenasgdets into l_chk_flag;
	       if(c_getbenasgdets%found) then
	          l_exists := true;
	       else
	          l_exists := false;
	       end if;
	       close c_getbenasgdets;


		    /*check_bnft_asgn
		      (p_person_id      => per_id.contact_person_id
		      --RCHASE BENASG bug fix Start
		      ,p_emp_person_id  => p_person_id
		      --RCHASE End
		      ,p_effective_date => l_benasg_effdate
		      ,p_asg_dets       => l_asg_dets
		      ,p_exists         => l_exists
		      );*/
		    --
		 /* End of Bug 9028676 */
		    if l_exists = false then
		      if l_prev_per_id <> per_id.contact_person_id
		      then
			 l_prev_per_id := per_id.contact_person_id;
			 l_perdetails_set(l_plstab_count).per_id  := per_id.contact_person_id;
			 l_perdetails_set(l_plstab_count).contype := per_id.contact_type;
			 l_plstab_count                           := l_plstab_count+1;
		      end if;
		    else
		      fnd_message.set_name('BEN','BEN_92554_CON_BNFT_ASS_EXISTS');
		      if fnd_global.conc_request_id <> -1 then
			benutils.write(fnd_message.get);
		      end if;
		    end if;
            --
          end loop;
        end if;
      elsif l_terminate
      then
        --
        --  If benefit assignment exist, update it.
        --
        check_bnft_asgn
          (p_person_id      => p_person_id
          --RCHASE BENASG bug fix Start
          ,p_emp_person_id  => p_person_id
          --RCHASE End
          ,p_effective_date => l_benasg_effdate
          ,p_asg_dets       => l_asg_dets
          ,p_exists         => l_exists
          );
        --
        if l_exists = true then
          hr_utility.set_location('benefit assignment exists', 150);
          --
          l_copybenasg := FALSE;
        else
          l_perele_num := 0;
          l_perdetails_set(l_perele_num).per_id  := p_person_id;
          l_perdetails_set(l_perele_num).contype := null;
          l_copybenasg   := TRUE;
          --
          -- Get all dependents of the employee
          --
          l_perele_num := l_perele_num+1;
          for c_inst in c_getdpntperdets(p_person_id,l_benasg_effdate) loop
            --
            --  If benefit assignment exist, update it.
            --
            check_bnft_asgn
              (p_person_id      => c_inst.contact_person_id
              --RCHASE BENASG bug fix Start
              ,p_emp_person_id  => p_person_id
              --RCHASE End
              ,p_effective_date => l_benasg_effdate
              ,p_asg_dets       => l_asg_dets
              ,p_exists         => l_exists
              );
            --
            if l_exists = false then
              --
              l_perdetails_set(l_perele_num).per_id  := c_inst.contact_person_id;
              l_perdetails_set(l_perele_num).contype := 'DPNT';
              l_perele_num := l_perele_num+1;
            end if;
            --
          end loop;
          --
        end if;
        hr_utility.set_location(l_proc, 150);
        --
      end if;
      --
      -- Create or refresh the benefits assignment
      --
      if l_benasg_id is null
        and l_copybenasg
      then
        --
        -- Loop through the benefits assignment person id set
        --
        hr_utility.set_location(l_proc||'l_perid_set.count: '||l_perdetails_set.count, 155);
        if l_perdetails_set.count > 0 then
          --
          for l_plstab_count in l_perdetails_set.first .. l_perdetails_set.last
          loop
            --

            -- when the person system type is other make sure the dependent are coverd by the person
            -- this happen when the dpnd lose the coverage the dpnt's dpnt get the ben asg
            -- in thos situation validate the dpnt has the coverage  2852514
            l_dummy  := null ;

            hr_utility.set_location(' person   ' || p_person_id , 156 );
            hr_utility.set_location(' dpnt   ' || l_perdetails_set(l_plstab_count).per_id , 156 );
            if l_perdetails_set(l_plstab_count).per_id <> p_person_id  and l_perpet_spt =  'OTHER'  then
               open c_dptn_cvg (l_perdetails_set(l_plstab_count).per_id , l_benasg_effdate-1 ) ;
               fetch c_dptn_cvg into l_dummy ;
               close c_dptn_cvg ;

               hr_utility.set_location(' dpnt covered ' || l_dummy , 156 );
               hr_utility.set_location(' dpnt covered date ' || l_benasg_effdate,156 );

            end if ;
            --- allow to create be asg when the asg for the same person  or
            --- person system type is not other or dpnt has the current covrage
            --- # 2852514
            hr_utility.set_location(' person sys type    ' || l_perpet_spt  , 156 );

            if   l_perdetails_set(l_plstab_count).per_id = p_person_id
              or l_perpet_spt not in ('OTHER')  or l_dummy is not null then

                -- Check for dependents
                --
                if l_perdetails_set(l_plstab_count).contype = 'DPNT' then
                  --
                  -- Copy employee primary address to the spouse/family member
                  -- contact primary address
                  --
                  copy_emppradd_ctrpradd
                    (p_empper_id      => p_person_id
                    ,p_ctrper_id      => l_perdetails_set(l_plstab_count).per_id
                    ,p_benasg_effdate => l_benasg_effdate
                    ,p_death          => l_death
                    ,p_divorce        => l_divorce
                    );
                --
                -- Check for a spouses or family members
                --
                elsif l_perdetails_set(l_plstab_count).contype is not null then
                  --
                  --  By pass creating a person type usage for a loss
                  --  of dependent status and Reduction of Hours event.
                  --
                  if l_contacts = FALSE then
                    hr_utility.set_location(' type and count ' || l_plstab_count || l_perdetails_set(l_plstab_count).contype, 151 );
                    --
                    hr_utility.set_location(l_proc||' Spouse Fammem: ', 155);
                    --
                    -- Create the person type usage
                    --
                    if l_death
                      and l_perdetails_set(l_plstab_count).contype in ('S','D')
                    then
                      --
                      hr_utility.set_location(l_proc, 160);
                      if l_perdetails_set(l_plstab_count).contype = 'S' then
                        l_pet_spt := 'SRVNG_SPS';
                      else
                        l_pet_spt := 'SRVNG_DP';
                      end if;
                      --
                    elsif l_divorce
                      and l_perdetails_set(l_plstab_count).contype = 'S'
                    then
                      --
                      hr_utility.set_location(l_proc, 170);
                      l_pet_spt := 'FRMR_SPS';
                      --
                      hr_utility.set_location('FRMR_SPS :' || l_proc, 172);
                    elsif l_divorce
                      and l_perdetails_set(l_plstab_count).contype = 'D'
                    then
                                 --
                      hr_utility.set_location('FRMR_DP :' || l_proc, 175);
                      l_pet_spt := 'FRMR_DP';

                    elsif l_death
                      and l_perdetails_set(l_plstab_count).contype in ('C','O','T','A','R')
                    then
                      --
                      hr_utility.set_location(l_proc, 180);
                      if l_perdetails_set(l_plstab_count).contype = 'R' then
                        l_pet_spt := 'SRVNG_DPFM';
                      else
                        l_pet_spt := 'SRVNG_FMLY_MMBR';
                      end if;
                      --
                    elsif l_divorce
                      and l_perdetails_set(l_plstab_count).contype in ('C','O','T','A','R') -- Bug 7594105: Added 'R' to the list
                    then
                      --
                      hr_utility.set_location(l_proc, 180);
                      l_pet_spt := 'FRMR_FMLY_MMBR';
                      --
                    end if;
                    --
                    -- Get the default person type id for the PET system person type
                    --
                    hr_utility.set_location('l_pet_spt: '||l_pet_spt||' '||l_proc, 185);
                    hr_utility.set_location('l_bgp_id: '||l_bgp_id||' '||l_proc, 185);
                    open c_getbgpdefpet
                      (c_bgp_id  => l_bgp_id
                      ,c_pet_spt => l_pet_spt
                      );
                    --
                    fetch c_getbgpdefpet into l_pet_id;
                    if c_getbgpdefpet%notfound then
                      close c_getbgpdefpet;
                      --
                      --  A person type usage cannot be created for the person when
                      --  creating the benefits assignment. The person type of the usage
                      --  does not exist for the business group.
                      --
                      hr_utility.set_message(801,'BEN_92113_NOPTUBGPPET');
                      hr_utility.raise_error;
                      --
                    end if;
                    close c_getbgpdefpet;
                    hr_utility.set_location(l_proc, 190);


                    -- added by tilak bug : 2188986
                    -- if the person_type exist dont create that again
                    -- the check_Against ben_Asg is not work when the
                    -- ben_asg creation set to N
                   check_person_type(
                        p_person_type_id       => l_pet_id
                       ,p_person_id            => l_perdetails_set(l_plstab_count).per_id
                       ,p_effective_date       => l_benasg_effdate
                       ,p_person_type_usage_id => l_ptu_id
                       ,p_type_exist           => l_type_exist ) ;
                    hr_utility.set_location(' type exist '|| l_type_exist , 199);
                    --
                    if l_type_exist = 'N'  then
                       hr_per_type_usage_internal.create_person_type_usage
                          (p_person_id             => l_perdetails_set(l_plstab_count).per_id
                          ,p_person_type_id        => l_pet_id
                          ,p_effective_date        => l_benasg_effdate
                          --
                          ,p_person_type_usage_id  => l_ptu_id
                          ,p_object_version_number => l_ptu_ovn
                          ,p_effective_start_date  => l_esd
                          ,p_effective_end_date    => l_eed
                        );
                    end if ;
                  end if;
                  hr_utility.set_location(l_proc, 200);
                  --
                  -- Copy employee primary address to the spouse/family member
                  -- contact primary address
                  --
                  copy_emppradd_ctrpradd
                    (p_empper_id      => p_person_id
                    ,p_ctrper_id      => l_perdetails_set(l_plstab_count).per_id
                    ,p_benasg_effdate => l_benasg_effdate
                    ,p_death          => l_death
                    ,p_divorce        => l_divorce
                    );
                  --
                end if;
                --
                -- Derive the AEI information
                --
                ben_assignment_internal.derive_aei_information
                  (p_person_id       => p_person_id
                  ,p_effective_date  => l_benasg_effdate
                  --
                  ,p_age             => l_age
                  ,p_adj_serv_date   => l_adj_serv_date
                  ,p_orig_hire_date  => l_orig_hire_date
                  ,p_salary          => l_salary
                  ,p_termn_date      => l_termn_date
                  ,p_termn_reason    => l_termn_reason
                  ,p_absence_date    => l_abs_date
                  ,p_absence_type    => l_abs_type
                  ,p_absence_reason  => l_abs_reason
                  ,p_date_of_hire    => l_date_of_hire
                  );
                hr_utility.set_location(l_proc, 210);
                --
                -- Derive the PTU SPT for the employee as of the event
                --
                l_count := 0;
                for c_inst in c_getperptupetdets(p_person_id,l_asg_dets.effective_start_date) loop
                  --
                  l_ptupetspt_set(l_count) := c_inst.system_person_type;
                  l_count := l_count+1;
                  hr_utility.set_location('system_person_type ' || c_inst.system_person_type, 220);
                  --
                end loop;
                hr_utility.set_location(l_proc, 220);
                --
                -- Get the base system person type from the PTU system person type set
                -- for the person
                --
                if l_ptupetspt_set.count > 0 then
                  --
                  -- Loop until a primary person type is found
                  --
                  -- - primary   - APL, APL_EX_APL, EMP, EMP_APL, EX_APL, EX_EMP, EX_EMP_APL, OTHER, RETIREE
                  -- - secondary - BNF, FRMR_SPS, SRVNG_FMLY_MMBR, SRVNG_SPS, FRMR_FMLY_MMBR
                  --               DPNT, PRTN
                  --
                  for l_torrw_num in l_ptupetspt_set.first .. l_ptupetspt_set.last loop
                    --
                    if l_ptupetspt_set(l_torrw_num)
                       in ('APL', 'APL_EX_APL', 'EMP', 'EMP_APL', 'EX_APL', 'EX_EMP', 'EX_EMP_APL', 'OTHER', 'RETIREE')
                    then
                      --
                      l_prptupet_spt := l_ptupetspt_set(l_torrw_num);
                      exit;
                      --
                    end if;
                    --
                  end loop;
                  --
                  -- Check for multiple PTUs
                  --
                  if l_ptupetspt_set.count > 1 then
                    --
                    p_perhasmultptus := TRUE;
                    --
                  else
                    --
                    p_perhasmultptus := FALSE;
                    --
                  end if;
                  --
                end if;
                --
                -- Create the benefits assignment
                --
		if l_asg_dets.assignment_id is not null then  ----Bug 9170856
                ben_assignment_api.create_ben_asg
                  (p_event_mode                   => TRUE
                  ,p_effective_date               => l_benasg_effdate
                  ,p_person_id                    => l_perdetails_set(l_plstab_count).per_id
                  ,p_assignment_status_type_id    => l_asg_dets.assignment_status_type_id
                  ,p_organization_id              => l_asg_dets.organization_id
                  --
                  ,p_grade_id                     => l_asg_dets.grade_id
                  ,p_position_id                  => l_asg_dets.position_id
                  ,p_job_id                       => l_asg_dets.job_id
                  ,p_payroll_id                   => l_asg_dets.payroll_id
                  ,p_location_id                  => l_asg_dets.location_id
                  ,p_supervisor_id                => l_asg_dets.supervisor_id
                  ,p_special_ceiling_step_id      => l_asg_dets.special_ceiling_step_id
                  ,p_people_group_id              => l_asg_dets.people_group_id
                  ,p_soft_coding_keyflex_id       => l_asg_dets.soft_coding_keyflex_id
                  ,p_pay_basis_id                 => l_asg_dets.pay_basis_id
                  ,p_change_reason                => l_asg_dets.change_reason
                  ,p_date_probation_end           => l_asg_dets.date_probation_end
                  ,p_default_code_comb_id         => l_asg_dets.default_code_comb_id
                  ,p_employment_category          => l_asg_dets.employment_category
                  ,p_frequency                    => l_asg_dets.frequency
                  ,p_internal_address_line        => null
                  ,p_manager_flag                 => l_asg_dets.manager_flag
                  ,p_normal_hours                 => l_asg_dets.normal_hours
                  ,p_perf_review_period           => l_asg_dets.perf_review_period
                  ,p_perf_review_period_frequency => l_asg_dets.perf_review_period_frequency
                  ,p_probation_period             => l_asg_dets.probation_period
                  ,p_probation_unit               => l_asg_dets.probation_unit
                  ,p_sal_review_period            => l_asg_dets.sal_review_period
                  ,p_sal_review_period_frequency  => l_asg_dets.sal_review_period_frequency
                  ,p_set_of_books_id              => null
                  ,p_source_type                  => l_asg_dets.source_type
                  ,p_time_normal_finish           => l_asg_dets.time_normal_finish
                  ,p_time_normal_start            => l_asg_dets.time_normal_start
                  ,p_bargaining_unit_code         => l_asg_dets.bargaining_unit_code
                  ,p_labour_union_member_flag     => l_asg_dets.labour_union_member_flag
                  ,p_hourly_salaried_code         => l_asg_dets.hourly_salaried_code
                  ,p_ass_attribute_category       => l_asg_dets.ass_attribute_category
                  ,p_ass_attribute1               => l_asg_dets.ass_attribute1
                  ,p_ass_attribute2               => l_asg_dets.ass_attribute2
                  ,p_ass_attribute3               => l_asg_dets.ass_attribute3
                  ,p_ass_attribute4               => l_asg_dets.ass_attribute4
                  ,p_ass_attribute5               => l_asg_dets.ass_attribute5
                  ,p_ass_attribute6               => l_asg_dets.ass_attribute6
                  ,p_ass_attribute7               => l_asg_dets.ass_attribute7
                  ,p_ass_attribute8               => l_asg_dets.ass_attribute8
                  ,p_ass_attribute9               => l_asg_dets.ass_attribute9
                  ,p_ass_attribute10              => l_asg_dets.ass_attribute10
                  ,p_ass_attribute11              => l_asg_dets.ass_attribute11
                  ,p_ass_attribute12              => l_asg_dets.ass_attribute12
                  ,p_ass_attribute13              => l_asg_dets.ass_attribute13
                  ,p_ass_attribute14              => l_asg_dets.ass_attribute14
                  ,p_ass_attribute15              => l_asg_dets.ass_attribute15
                  ,p_ass_attribute16              => l_asg_dets.ass_attribute16
                  ,p_ass_attribute17              => l_asg_dets.ass_attribute17
                  ,p_ass_attribute18              => l_asg_dets.ass_attribute18
                  ,p_ass_attribute19              => l_asg_dets.ass_attribute19
                  ,p_ass_attribute20              => l_asg_dets.ass_attribute20
                  ,p_ass_attribute21              => l_asg_dets.ass_attribute21
                  ,p_ass_attribute22              => l_asg_dets.ass_attribute22
                  ,p_ass_attribute23              => l_asg_dets.ass_attribute23
                  ,p_ass_attribute24              => l_asg_dets.ass_attribute24
                  ,p_ass_attribute25              => l_asg_dets.ass_attribute25
                  ,p_ass_attribute26              => l_asg_dets.ass_attribute26
                  ,p_ass_attribute27              => l_asg_dets.ass_attribute27
                  ,p_ass_attribute28              => l_asg_dets.ass_attribute28
                  ,p_ass_attribute29              => l_asg_dets.ass_attribute29
                  ,p_ass_attribute30              => l_asg_dets.ass_attribute30
                  ,p_title                        => l_asg_dets.title
                  ,p_age                          => l_age
                  ,p_adjusted_service_date        => l_adj_serv_date
                  ,p_original_hire_date           => l_orig_hire_date
                  ,p_salary                       => l_salary
                  ,p_original_person_type         => l_prptupet_spt
                  ,p_termination_date             => l_termn_date
                  ,p_termination_reason           => l_termn_reason
                  ,p_leave_of_absence_date        => l_abs_date
                  ,p_absence_type                 => l_abs_type
                  ,p_absence_reason               => l_abs_reason
                  ,p_date_of_hire                 => l_date_of_hire
                  ,p_validate                     => FALSE
                  --
                  ,p_assignment_id                => l_assignment_id
                  ,p_object_version_number        => p_object_version_number
                  ,p_effective_start_date         => l_date_dummy1
                  ,p_effective_end_date           => l_date_dummy2
                  ,p_assignment_extra_info_id     => l_number_dummy1
                  ,p_aei_object_version_number    => l_number_dummy2
                  );
		end if ; ----Bug 9170856
                hr_utility.set_location(l_proc, 220);
                --
              end if ;
           end loop;
              --
        end if;
        --
      end if;
    --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 300);
end copy_empasg_to_benasg;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_bnft_asgn >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_bnft_asgn
  (p_person_id      in     number
  ,p_effective_date in     date
  ,p_asg_dets       in     per_all_assignments_f%rowtype
  ,p_exists         out nocopy    boolean
  --RCHASE BENASG bug fix Start
  ,p_emp_person_id  in     number default null
  --RCHASE End
  )
is
  --
  l_proc             varchar2(72):=g_package||'check_bnft_asgn';
  --
  -- Declare cursors and local variables
  --
  cursor c_getbenasgdets
  Is
    select  asg.*
    from    per_all_assignments_f asg
    where   asg.person_id = p_person_id
    and     asg.assignment_type = 'B'
    and     p_effective_date
    between asg.effective_start_date and asg.effective_end_date;

  l_asg_rec                 c_getbenasgdets%rowtype;
  l_object_version_number   per_all_assignments_f.object_version_number%type;
  l_special_ceiling_step_id per_all_assignments_f.special_ceiling_step_id%type;
  l_age                     varchar2(100);
  l_adj_serv_date           date;
  l_orig_hire_date          date;
  l_salary                  varchar2(100);
  l_termn_date              date;
  l_termn_reason            varchar2(100);
  l_abs_date                date;
  l_abs_type                varchar2(100);
  l_abs_reason              varchar2(100);
  l_date_of_hire            date;
  l_datetrack_mode          varchar2(30);
  l_effective_start_date    date;
  l_effective_end_date      date;
  l_correction              boolean;
  l_update                  boolean;
  l_update_override         boolean;
  l_update_change_insert    boolean;
--
BEGIN
  hr_utility.set_location(' Entering:'||l_proc, 100);
  hr_utility.set_location(' p_person_id:'||p_person_id, 100);
  hr_utility.set_location(' p_emp_person_id:'||p_emp_person_id, 100);
  hr_utility.set_location(' p_effective_date:'||p_effective_date, 100);
  --
  --  Check if benefit assignment exist.
  --
  open c_getbenasgdets;
  --
  fetch c_getbenasgdets Into l_asg_rec;
  if c_getbenasgdets%found then
    close c_getbenasgdets;
    p_exists := true;
    --
    -- Bug : 2793136 : If benefits assignment already exists and
    -- employee assignment is not found then simply return.
    --
    if p_asg_dets.assignment_id is null
    then
       hr_utility.set_location('Leaving :' || l_proc, 100);
       return;
    end if;
   hr_utility.set_location(' exist ben asg :'||l_asg_rec.effective_start_date ||'-'||p_effective_date, 100);
    --
    if l_asg_rec.effective_start_date <> p_effective_date then
      --
      -- Check for valid date track mode.
      --
      dt_api.find_dt_upd_modes
        (p_effective_date       => p_effective_date,
         p_base_table_name      => 'PER_ALL_ASSIGNMENTS_F',
         p_base_key_column      => 'assignment_id',
         p_base_key_value       => l_asg_rec.assignment_id,
         p_correction           => l_correction,
         p_update               => l_update,
         p_update_override      => l_update_override,
         p_update_change_insert => l_update_change_insert);
      --
      if l_update_override then
        --
        l_datetrack_mode := hr_api.g_update_override;
        --
      elsif l_update then
        --
        l_datetrack_mode := hr_api.g_update;
        --
      else
        --
        l_datetrack_mode := hr_api.g_correction;
        --
      end if;
      --
      --  Update the current benefit assignment.
      --
      --
      -- Derive the AEI information
      --
      ben_assignment_internal.derive_aei_information
        --RCHASE BENASG bug fix Start
        (p_person_id       => nvl(p_emp_person_id, p_person_id)
        --RCHASE End
        ,p_effective_date  => p_effective_date
        --
        ,p_age             => l_age
        ,p_adj_serv_date   => l_adj_serv_date
        ,p_orig_hire_date  => l_orig_hire_date
        ,p_salary          => l_salary
        ,p_termn_date      => l_termn_date
        ,p_termn_reason    => l_termn_reason
        ,p_absence_date    => l_abs_date
        ,p_absence_type    => l_abs_type
        ,p_absence_reason  => l_abs_reason
        ,p_date_of_hire    => l_date_of_hire
        );
      --
      l_object_version_number := l_asg_rec.object_version_number;
      l_special_ceiling_step_id := p_asg_dets.special_ceiling_step_id;
      --
      -- Update the benefits assignment
      --
      hr_utility.set_location(' updating assignment:', 100);
      ben_assignment_api.update_ben_asg
        (p_validate                     => FALSE
        ,p_effective_date               => p_effective_date
        ,p_datetrack_update_mode        => l_datetrack_mode
        ,p_assignment_id                => l_asg_rec.assignment_id
        ,p_object_version_number        => l_object_version_number
        --
        ,p_grade_id                     => p_asg_dets.grade_id
        ,p_position_id                  => p_asg_dets.position_id
        ,p_job_id                       => p_asg_dets.job_id
        ,p_payroll_id                   => p_asg_dets.payroll_id
        ,p_location_id                  => p_asg_dets.location_id
        ,p_special_ceiling_step_id      => l_special_ceiling_step_id
        ,p_organization_id              => p_asg_dets.organization_id
        ,p_people_group_id              => p_asg_dets.people_group_id
        ,p_pay_basis_id                 => p_asg_dets.pay_basis_id
        ,p_employment_category          => p_asg_dets.employment_category
        --
        ,p_supervisor_id                => p_asg_dets.supervisor_id
        ,p_change_reason                => p_asg_dets.change_reason
        ,p_date_probation_end           => p_asg_dets.date_probation_end
        ,p_default_code_comb_id         => p_asg_dets.default_code_comb_id
        ,p_frequency                    => p_asg_dets.frequency
        ,p_internal_address_line        => p_asg_dets.internal_address_line
        ,p_manager_flag                 => p_asg_dets.manager_flag
        ,p_normal_hours                 => p_asg_dets.normal_hours
        ,p_perf_review_period           => p_asg_dets.perf_review_period
        ,p_perf_review_period_frequency => p_asg_dets.perf_review_period_frequency
        ,p_probation_period             => p_asg_dets.probation_period
        ,p_probation_unit               => p_asg_dets.probation_unit
        ,p_sal_review_period            => p_asg_dets.sal_review_period
        ,p_sal_review_period_frequency  => p_asg_dets.sal_review_period_frequency
        ,p_set_of_books_id              => null
        ,p_source_type                  => p_asg_dets.source_type
        ,p_time_normal_finish           => p_asg_dets.time_normal_finish
        ,p_time_normal_start            => p_asg_dets.time_normal_start
        ,p_bargaining_unit_code         => p_asg_dets.bargaining_unit_code
        ,p_labour_union_member_flag     => p_asg_dets.labour_union_member_flag
        ,p_hourly_salaried_code         => p_asg_dets.hourly_salaried_code
        ,p_ass_attribute_category       => p_asg_dets.ass_attribute_category
        ,p_ass_attribute1               => p_asg_dets.ass_attribute1
        ,p_ass_attribute2               => p_asg_dets.ass_attribute2
        ,p_ass_attribute3               => p_asg_dets.ass_attribute3
        ,p_ass_attribute4               => p_asg_dets.ass_attribute4
        ,p_ass_attribute5               => p_asg_dets.ass_attribute5
        ,p_ass_attribute6               => p_asg_dets.ass_attribute6
        ,p_ass_attribute7               => p_asg_dets.ass_attribute7
        ,p_ass_attribute8               => p_asg_dets.ass_attribute8
        ,p_ass_attribute9               => p_asg_dets.ass_attribute9
        ,p_ass_attribute10              => p_asg_dets.ass_attribute10
        ,p_ass_attribute11              => p_asg_dets.ass_attribute11
        ,p_ass_attribute12              => p_asg_dets.ass_attribute12
        ,p_ass_attribute13              => p_asg_dets.ass_attribute13
        ,p_ass_attribute14              => p_asg_dets.ass_attribute14
        ,p_ass_attribute15              => p_asg_dets.ass_attribute15
        ,p_ass_attribute16              => p_asg_dets.ass_attribute16
        ,p_ass_attribute17              => p_asg_dets.ass_attribute17
        ,p_ass_attribute18              => p_asg_dets.ass_attribute18
        ,p_ass_attribute19              => p_asg_dets.ass_attribute19
        ,p_ass_attribute20              => p_asg_dets.ass_attribute20
        ,p_ass_attribute21              => p_asg_dets.ass_attribute21
        ,p_ass_attribute22              => p_asg_dets.ass_attribute22
        ,p_ass_attribute23              => p_asg_dets.ass_attribute23
        ,p_ass_attribute24              => p_asg_dets.ass_attribute24
        ,p_ass_attribute25              => p_asg_dets.ass_attribute25
        ,p_ass_attribute26              => p_asg_dets.ass_attribute26
        ,p_ass_attribute27              => p_asg_dets.ass_attribute27
        ,p_ass_attribute28              => p_asg_dets.ass_attribute28
        ,p_ass_attribute29              => p_asg_dets.ass_attribute29
        ,p_ass_attribute30              => p_asg_dets.ass_attribute30
        ,p_title                        => p_asg_dets.title
        ,p_age                          => l_age
        ,p_adjusted_service_date        => l_adj_serv_date
        ,p_original_hire_date           => l_orig_hire_date
        ,p_salary                       => l_salary
        ,p_termination_date             => l_termn_date
        ,p_termination_reason           => l_termn_reason
        ,p_leave_of_absence_date        => l_abs_date
        ,p_absence_type                 => l_abs_type
        ,p_absence_reason               => l_abs_reason
        ,p_date_of_hire                 => l_date_of_hire
        --
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date
        );
    end if;
  else
    close c_getbenasgdets;
    p_exists := false;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 100);
end check_bnft_asgn;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< derive_aei_information >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure derive_aei_information
  (p_effective_date in     date
  ,p_person_id      in     number
  --
  ,p_age               out nocopy number
  ,p_adj_serv_date     out nocopy date
  ,p_orig_hire_date    out nocopy date
  ,p_salary            out nocopy varchar2
  ,p_termn_date        out nocopy date
  ,p_termn_reason      out nocopy varchar2
  ,p_absence_date      out nocopy date
  ,p_absence_type      out nocopy varchar2
  ,p_absence_reason    out nocopy varchar2
  ,p_date_of_hire      out nocopy date
  )
is
  --
  l_proc             varchar2(72):=g_package||'derive_aei_information';
  --
  -- Declare cursors and local variables
  --
  l_emp_dob          date;
  l_emp_doh          date;
  l_emp_asd          date;
  l_emp_ohd          date;
  l_emp_tmd          date;
  l_abs_date         date;
  l_age              number;
  l_emp_salary       varchar2(100);
  l_emp_tmr          varchar2(100);
  l_abs_type         varchar2(100);
  l_abs_reason       varchar2(100);
  l_emp_perid        number;
  --
  cursor c_getempdtperdets
    (c_person_id in     number
    ,c_eff_date  in     date
    )
  Is
    select  per.date_of_birth,
            pds.adjusted_svc_date,
            per.original_date_of_hire,
            pds.actual_termination_date,
            pds.leaving_reason,
            pds.date_start
    from    per_all_people_f per,
            per_periods_of_service pds
    where   per.person_id = c_person_id
    and     per.person_id = pds.person_id
    and     c_eff_date
               between per.effective_start_date and per.effective_end_date
    and     pds.date_start = (select max(date_start) from per_periods_of_service
                             pps where pps.person_id = c_person_id) ;
  --
  cursor c_getempabsence
    (c_person_id in     number
    ,c_eff_date  in     date
    )
  Is
   select paa.date_start,
          paa.absence_attendance_type_id,
          paa.abs_attendance_reason_id
   from   per_absence_attendances paa
   where  paa.person_id = c_person_id
   and     c_eff_date
               between nvl(paa.date_start,c_eff_date) and nvl(paa.date_end,c_eff_date);
  --
  cursor c_getsalary
    (c_person_id in     number
    ,c_eff_date  in     date
    )
  Is
    select  pyp.proposed_salary_n
    from    per_all_assignments_f asg,
            per_pay_proposals pyp
    where   asg.assignment_id = pyp.assignment_id
    and     c_eff_date
      between asg.effective_start_date and asg.effective_end_date
    and     asg.person_id = c_person_id
    and     asg.primary_flag = 'Y'
    and     asg.assignment_type = 'E'
    and     pyp.approved = 'Y'
    and     nvl(pyp.change_date,hr_api.g_sot) <= c_eff_date
    order   by pyp.change_date desc;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.set_location('p_person_id '||p_person_id, 300);
  hr_utility.set_location('p_effective_date '||p_effective_date, 300);
  --
  -- Check mandatory arguments
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_person_id',
     p_argument_value => p_person_id
     );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_effective_date',
     p_argument_value => p_effective_date
     );
  --
  -- Get the date of birth, adjusted service date,trmination date,reason and
  -- original hire date of the employee
  --
  hr_utility.set_location('p_per_id: '||p_person_id||' '||l_proc, 20);
  hr_utility.set_location('p_eff_date: '||p_effective_date||' '||l_proc, 20);
  open c_getempdtperdets
    (c_person_id => p_person_id
    ,c_eff_date  => p_effective_date
    );
  fetch c_getempdtperdets into l_emp_dob, l_emp_asd, l_emp_ohd,l_emp_tmd,l_emp_tmr,l_emp_doh;
  close c_getempdtperdets;
  --
  if l_emp_dob is not null then
    --
    -- Bug : 1782261
    -- Changed the ROUND of months to FLOOR to get the correct age .
    --
    l_age := floor(months_between(p_effective_date,l_emp_dob)/12);
    --
    -- Bug : 1782261
  end if;
  --
  -- Get the most recent approved salary for the employee
  --
  open c_getsalary
    (c_person_id => p_person_id
    ,c_eff_date  => p_effective_date
    );
  --
  fetch c_getsalary into l_emp_salary;
  close c_getsalary;
  --
  open c_getempabsence
    (c_person_id => p_person_id
    ,c_eff_date  => p_effective_date
    );
  --
  fetch c_getempabsence into l_abs_date,l_abs_type,l_abs_reason;
  if c_getempabsence%notfound then
    null;
  end if;
  close c_getempabsence;
  --
  -- Set OUT parameters
  --
  p_age             := l_age;
  p_adj_serv_date   := l_emp_asd;
  p_orig_hire_date  := l_emp_ohd;
  p_salary          := l_emp_salary;
  p_termn_date      := l_emp_tmd;
  p_termn_reason    := l_emp_tmr;
  p_absence_date    := l_abs_date;
  p_absence_type    := l_abs_type;
  p_absence_reason  := l_abs_reason;
  p_date_of_hire    := l_emp_doh;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
end derive_aei_information;
--
end ben_assignment_internal;

/

--------------------------------------------------------
--  DDL for Package Body BEN_ICD_PLAN_DESIGN_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ICD_PLAN_DESIGN_SETUP" as
/* $Header: benicdsetup.pkb 120.2 2008/06/12 10:07:09 vkodedal noship $ */

procedure create_setup(p_element_type_id in number
                ,p_business_group_id in number
                ,p_effective_date  in date
                ,p_pl_typ_id       in number
                ,p_pl_id           in number
                ,p_pl_name         in varchar2 default null
                ,p_pl_typ_name     in varchar2 default null
                ,p_elig_prfl_id    in number default null
                ,p_opt_name        in varchar2 default null
                ,p_option_level    in varchar2 default 'N') is
  l_pl_typ_id number;
  l_pl_id     number;
  l_opt_id    number;
  l_oipl_id   number;
  l_pl_typ_opt_typ_id number;
  l_prtn_elig_id number;
  l_prtn_elig_prfl_id number;
  l_acty_base_rt_id number;
  l_max_ordr_num number;
  l_use_pl_id number;

  l_ovn       number;
  l_esd       date;
  l_eed       date;

  cursor c_element is
     select typ.element_type_id
           ,typ.effective_start_date
           ,typ.effective_end_date
           ,nvl(typtl.description,typtl.element_name) use_name
           ,typ.input_currency_code
           ,typ.processing_type
     from pay_element_types_f typ
         ,pay_element_types_f_tl typtl
     where typ.element_type_id = p_element_type_id
     and   p_effective_date between
           typ.effective_start_date and typ.effective_end_date
     and   typ.element_type_id = typtl.element_type_id
     and   typtl.language (+) = userenv('lang');
  l_element c_element%rowtype;

  cursor c_opt(v_name varchar2) is
     select opt.opt_id
     from   ben_opt_f opt
     where  opt.business_group_id = p_business_group_id
     and    p_effective_date between
            opt.effective_start_date and opt.effective_end_date
     and    opt.name = v_name;

  cursor c_pon(v_opt_id number, v_pl_typ_id number) is
     select pon.pl_typ_opt_typ_id
     from   ben_pl_typ_opt_typ_f pon
     where  pon.opt_id = v_opt_id
     and    pon.pl_typ_id = v_pl_typ_id
     and    p_effective_date between
            pon.effective_start_date and pon.effective_end_date;

  cursor c_max_oipl is
     select max(oipl.ordr_num)
     from   ben_oipl_f oipl
     where  oipl.pl_id = l_pl_id
     and    p_effective_date between
            oipl.effective_start_date and oipl.effective_end_date;

begin
   open c_element;
   fetch c_element into l_element;
   close c_element;

   if p_pl_typ_id is null then
     ben_plan_type_api.create_plan_type
        (p_validate => false,
         p_pl_typ_id => l_pl_typ_id,
         p_effective_start_date => l_esd,
         p_effective_end_date => l_eed,
         p_name => nvl(p_pl_typ_name,
                       l_element.use_name),
         p_pl_typ_stat_cd => 'A',
         p_opt_typ_cd => 'ICM', -- New ICD
         p_no_mx_enrl_num_dfnd_flag => 'N',
         p_no_mn_enrl_num_dfnd_flag => 'N',
         p_business_group_id => p_business_group_id,
         p_object_version_number => l_ovn,
         p_effective_date => p_effective_date);
   else
     l_pl_typ_id := p_pl_typ_id;
   end if;

   if p_pl_id is null then
     ben_plan_api.create_plan
        (p_validate => false,
         p_pl_id => l_pl_id,
         p_effective_start_date => l_esd,
         p_effective_end_date => l_eed,
         p_name =>  nvl(p_pl_name,
                        l_element.use_name),
         p_ordr_num => 10,
         p_pl_cd => 'MYNTBPGM', -- May Not Be in a program
         p_enrt_mthd_cd => 'E', -- Explicit
         p_enrt_cvg_strt_dt_cd => 'OED', -- Effective Date
         p_enrt_cvg_end_dt_cd => 'ODBEFFD', -- 1 Day Before Effective Date
         p_nip_pl_uom  => l_element.input_currency_code,
         p_nip_acty_ref_perd_cd => null, -- MO Monthly
         p_nip_enrt_info_rt_freq_cd => 'PP', -- Per Pay Period
         p_prtn_elig_ovrid_alwd_flag => 'Y',
         p_pl_stat_cd => 'A', -- Active
         p_rt_end_dt_cd => 'WAENT', -- 1 Prior or Enterable
         p_rt_strt_dt_cd => 'ENTRBL', --Enterable
         p_pl_typ_id => l_pl_typ_id,
         p_business_group_id => p_business_group_id,
         p_alws_unrstrctd_enrt_flag => 'Y',
         p_object_version_number => l_ovn,
         p_effective_date => p_effective_date);
   else
     l_pl_id := p_pl_id;
   end if;

   if p_option_level = 'Y' then

     l_use_pl_id := null;

     open  c_opt(nvl(p_opt_name,l_element.use_name));
     fetch c_opt into l_opt_id;
     close c_opt;

     if l_opt_id is null then
       ben_option_definition_api.create_option_definition
         (p_validate => false,
          p_opt_id => l_opt_id,
          p_effective_start_date => l_esd,
          p_effective_end_date => l_eed,
          p_name => nvl(p_opt_name,
                        l_element.use_name),
          p_business_group_id => p_business_group_id,
          p_object_version_number => l_ovn,
          p_effective_date => p_effective_date);
      end if;

      open  c_pon(l_opt_id, l_pl_typ_id);
      fetch c_pon into l_pl_typ_opt_typ_id;
      close c_pon;

      if l_pl_typ_opt_typ_id is null then
        ben_plan_type_option_type_api.create_plan_type_option_type
          (p_validate => false,
           p_pl_typ_opt_typ_id => l_pl_typ_opt_typ_id,
           p_effective_start_date => l_esd,
           p_effective_end_date => l_eed,
           p_pl_typ_opt_typ_cd => 'ICM',
           p_opt_id => l_opt_id,
           p_pl_typ_id => l_pl_typ_id,
           p_business_group_id => p_business_group_id,
           p_object_version_number => l_ovn,
           p_effective_date => p_effective_date);
      end if;

      open c_max_oipl;
      fetch c_max_oipl into l_max_ordr_num;
      close c_max_oipl;

      l_max_ordr_num := nvl(l_max_ordr_num, 0) + 10;

      ben_option_in_plan_api.create_option_in_plan
         (p_validate => false,
          p_oipl_id => l_oipl_id,
          p_effective_start_date => l_esd,
          p_effective_end_date => l_eed,
          p_opt_id => l_opt_id,
          p_business_group_id => p_business_group_id,
          p_pl_id => l_pl_id,
          p_ordr_num => l_max_ordr_num,
          p_oipl_stat_cd => 'A',
          p_auto_enrt_flag => 'N',
          p_prtn_elig_ovrid_alwd_flag => 'Y',
          p_object_version_number => l_ovn,
          p_effective_date => p_effective_date);
   else
     l_use_pl_id := l_pl_id;
   end if;

   if p_elig_prfl_id is not null then
     ben_participation_elig_api.create_participation_elig
        (p_validate => false,
         p_prtn_elig_id => l_prtn_elig_id,
         p_effective_start_date => l_esd,
         p_effective_end_date => l_eed,
         p_business_group_id => p_business_group_id,
         p_pl_id => l_use_pl_id,
         p_oipl_id => l_oipl_id,
         p_object_version_number => l_ovn,
         p_effective_date => p_effective_date);

      ben_prtn_elig_prfl_api.create_prtn_elig_prfl
        (p_validate => false,
         p_prtn_elig_prfl_id => l_prtn_elig_prfl_id,
         p_effective_start_date => l_esd,
         p_effective_end_date => l_eed,
         p_business_group_id => p_business_group_id,
         p_mndtry_flag => 'Y',
         p_prtn_elig_id => l_prtn_elig_id,
         p_eligy_prfl_id => p_elig_prfl_id,
         p_object_version_number => l_ovn,
         p_effective_date => p_effective_date);
    end if;

    ben_acty_base_rate_api.create_acty_base_rate
       (p_validate => false,
        p_acty_base_rt_id => l_acty_base_rt_id,
        p_effective_start_date => l_esd,
        p_effective_end_date => l_eed,
        p_acty_typ_cd => 'ERPYD',
        p_name => nvl(p_opt_name,
                      nvl(p_pl_name,
                          l_element.use_name)),
        p_tx_typ_cd => 'NONTAXABLE',
        p_rt_mlt_cd => 'NSVU', -- No Standard Rate Used
        p_asn_on_enrt_flag => 'Y',
        p_acty_base_rt_stat_cd => 'A',
        p_procg_src_cd => 'PYRL', -- Payroll
        p_rt_usg_cd => 'STD', -- Standard Contribution/Distribution
        p_ele_rqd_flag => 'Y',
        p_element_type_id => p_element_type_id,
        p_pl_id => l_use_pl_id,
        p_oipl_id => l_oipl_id,
        p_ele_entry_val_cd => 'DFND', -- Defined Amount
        p_business_group_id => p_business_group_id,
        p_context_pl_id => l_pl_id,
        p_context_opt_id => l_opt_id,
        p_object_version_number => l_ovn,
        p_effective_date => p_effective_date);

   ben_icd_flex_field_setup.create_icd_config
      (p_element_type_id => p_element_type_id,
       p_effective_date => p_effective_date);

exception
  when others then
    rollback;
    raise;

end create_setup;


procedure refresh_setup(p_element_type_id in number
                       ,p_business_group_id in number
                       ,p_effective_date  in date) is
begin
  ben_icd_flex_field_setup.refresh_icd_config
    (p_element_type_id => p_element_type_id,
     p_effective_date => p_effective_date);
exception
  when others then
    rollback;
    raise;
end refresh_setup;

procedure delete_elig(p_prtn_elig_id in number,
                      p_effective_date in date,
                      p_object_version_number in out nocopy number) is
  cursor c_prfl is
     select prfl.prtn_elig_prfl_id
           ,prfl.effective_start_date
           ,prfl.effective_end_date
           ,prfl.object_version_number
     from  ben_prtn_elig_prfl_f prfl
     where prfl.prtn_elig_id = p_prtn_elig_id
     and   p_effective_date between
           prfl.effective_start_date and prfl.effective_end_date;
  l_esd date;
  l_eed date;
begin
  for l_prfl in c_prfl loop
    ben_prtn_elig_prfl_api.delete_prtn_elig_prfl
       (p_validate => false,
        p_prtn_elig_prfl_id => l_prfl.prtn_elig_prfl_id,
        p_effective_start_date => l_esd,
        p_effective_end_date => l_eed,
        p_object_version_number => l_prfl.object_version_number,
        p_effective_date => p_effective_date,
        p_datetrack_mode => hr_api.g_zap);
  end loop;

  ben_participation_elig_api.delete_participation_elig
     (p_validate => false,
     p_prtn_elig_id => p_prtn_elig_id,
     p_effective_start_date => l_esd,
     p_effective_end_date => l_eed,
     p_object_version_number => p_object_version_number,
     p_effective_date => p_effective_date,
     p_datetrack_mode => hr_api.g_zap);

end delete_elig;

procedure delete_setup(p_element_type_id in number
                      ,p_business_group_id in number
                      ,p_effective_date in date) is

  l_esd date;
  l_eed date;

  cursor c_abr is
     select abr.acty_base_rt_id
           ,abr.object_version_number
           ,abr.context_pl_id pl_id
           ,abr.oipl_id
           ,pln.pl_typ_id
     from   ben_acty_base_rt_f abr
           ,ben_pl_f pln
           ,ben_pl_typ_f typ
     where  abr.element_type_id = p_element_type_id
     and    abr.business_group_id = p_business_group_id
     and    p_effective_date between
            abr.effective_start_date and abr.effective_end_date
     and    abr.context_pl_id = pln.pl_id
     and    p_effective_date between
            pln.effective_start_date and pln.effective_end_date
     and    pln.pl_typ_id = typ.pl_typ_id
     and    p_effective_date between
            typ.effective_start_date and typ.effective_end_date
     and    typ.opt_typ_cd = 'ICM';

  cursor c_oipl_prtn(v_oipl_id number) is
     select prtn.prtn_elig_id
           ,prtn.object_version_number
     from ben_prtn_elig_f prtn
     where prtn.oipl_id = v_oipl_id
     and   p_effective_date between
           prtn.effective_start_date and prtn.effective_end_date;

  cursor c_pl_prtn(v_pl_id number) is
     select prtn.prtn_elig_id
           ,prtn.object_version_number
     from ben_prtn_elig_f prtn
     where prtn.pl_id = v_pl_id
     and   p_effective_date between
           prtn.effective_start_date and prtn.effective_end_date;

    cursor c_oipl(v_oipl_id number) is
       select oipl.object_version_number
             ,oipl.opt_id
       from ben_oipl_f oipl
       where oipl.oipl_id = v_oipl_id
       and   p_effective_date between
             oipl.effective_start_date and oipl.effective_end_date;

    cursor c_pon(v_opt_id number,
                 v_pl_typ_id number) is
       select pon.pl_typ_opt_typ_id
             ,pon.object_version_number
       from ben_pl_typ_opt_typ_f pon
       where pon.opt_id = v_opt_id
       and   pon.pl_typ_id = v_pl_typ_id
       and   p_effective_date between
             pon.effective_start_date and pon.effective_end_date
       and not exists
          (select 'Y'
           from ben_oipl_f oipl
               ,ben_pl_f pln
           where oipl.opt_id = v_opt_id
           and   oipl.pl_id = pln.pl_id
           and   pln.pl_typ_id = v_pl_typ_id);

    cursor c_opt(v_opt_id number) is
       select opt.object_version_number
       from ben_opt_f opt
       where opt.opt_id = v_opt_id
       and   p_effective_date between
             opt.effective_start_date and opt.effective_end_date
       and not exists
          (select 'Y'
           from ben_pl_typ_opt_typ_f pon
           where pon.opt_id = v_opt_id);

    cursor c_pln(v_pl_id number) is
       select pln.object_version_number
       from ben_pl_f pln
       where pln.pl_id = v_pl_id
       and   p_effective_date between
             pln.effective_start_date and pln.effective_end_date
       and not exists
            (select 'Y'
             from  ben_oipl_f oipl
             where oipl.pl_id = v_pl_id);

    cursor c_typ(v_pl_typ_id number) is
       select typ.object_version_number
       from ben_pl_typ_f typ
       where typ.pl_typ_id = v_pl_typ_id
       and   p_effective_date between
             typ.effective_start_date and typ.effective_end_date
       and not exists
            (select 'Y'
             from  ben_pl_f pln
             where pln.pl_typ_id = v_pl_typ_id);

    cursor c_abr_exst is
     select abr.acty_base_rt_id
     from   ben_acty_base_rt_f abr
           ,ben_pl_f pln
           ,ben_pl_typ_f typ
     where  abr.element_type_id = p_element_type_id
     and    abr.context_pl_id = pln.pl_id
     and    pln.pl_typ_id = typ.pl_typ_id
     and    typ.opt_typ_cd = 'ICM';

    l_abr_id number;

begin

  for l_abr in c_abr loop
    ben_acty_base_rate_api.delete_acty_base_rate
     (p_validate => false,
     p_acty_base_rt_id => l_abr.acty_base_rt_id,
     p_effective_start_date => l_esd,
     p_effective_end_date => l_eed,
     p_object_version_number => l_abr.object_version_number,
     p_effective_date => p_effective_date,
     p_datetrack_mode => hr_api.g_zap);

    if l_abr.oipl_id is not null then
      for l_prtn_elig in c_oipl_prtn(l_abr.oipl_id) loop
        delete_elig(p_prtn_elig_id => l_prtn_elig.prtn_elig_id,
                    p_effective_date => p_effective_date,
                    p_object_version_number => l_prtn_elig.object_version_number);
      end loop; -- c_oipl_prtn

      for l_oipl in c_oipl(l_abr.oipl_id) loop
        ben_option_in_plan_api.delete_option_in_plan
          (p_validate => false,
           p_oipl_id => l_abr.oipl_id,
           p_effective_start_date => l_esd,
           p_effective_end_date => l_eed,
           p_object_version_number => l_oipl.object_version_number,
           p_effective_date => p_effective_date,
           p_datetrack_mode => hr_api.g_zap);

        for l_pon in c_pon(l_oipl.opt_id, l_abr.pl_typ_id) loop
          ben_plan_type_option_type_api.delete_plan_type_option_type
             (p_validate => false,
              p_pl_typ_opt_typ_id => l_pon.pl_typ_opt_typ_id,
              p_effective_start_date => l_esd,
              p_effective_end_date => l_eed,
              p_object_version_number => l_pon.object_version_number,
              p_effective_date => p_effective_date,
              p_datetrack_mode => hr_api.g_zap);
        end loop; -- c_pon

        for l_opt in c_opt(l_oipl.opt_id) loop
          ben_option_definition_api.delete_option_definition
             (p_validate => false,
              p_opt_id => l_oipl.opt_id,
              p_effective_start_date => l_esd,
              p_effective_end_date => l_eed,
              p_object_version_number => l_opt.object_version_number,
              p_effective_date => p_effective_date,
              p_datetrack_mode => hr_api.g_zap);
        end loop; -- c_opt

      end loop; -- c_oipl
    else
      for l_prtn_elig in c_pl_prtn(l_abr.pl_id) loop
        delete_elig(p_prtn_elig_id => l_prtn_elig.prtn_elig_id,
                    p_effective_date => p_effective_date,
                    p_object_version_number => l_prtn_elig.object_version_number);
      end loop; -- c_pl_rtn
    end if; -- oipl_id is not null

    for l_pln in c_pln(l_abr.pl_id) loop
       ben_plan_api.delete_plan
          (p_validate => false,
           p_pl_id => l_abr.pl_id,
           p_effective_start_date => l_esd,
           p_effective_end_date => l_eed,
           p_object_version_number => l_pln.object_version_number,
           p_effective_date => p_effective_date,
           p_datetrack_mode => hr_api.g_zap);
    end loop; -- c_pln

    for l_typ in c_typ(l_abr.pl_typ_id) loop
       ben_plan_type_api.delete_plan_type
          (p_validate => false,
           p_pl_typ_id => l_abr.pl_typ_id,
           p_effective_start_date => l_esd,
           p_effective_end_date => l_eed,
           p_object_version_number => l_typ.object_version_number,
           p_effective_date => p_effective_date,
           p_datetrack_mode => hr_api.g_zap);
    end loop; -- c_pl_typ

  end loop; -- c_abr;

  open  c_abr_exst;
  fetch c_abr_exst into l_abr_id;
  close c_abr_exst;

  if l_abr_id is null then
    -- No other comp object using the same element, so delete
    -- the setup information
    ben_icd_flex_field_setup.delete_icd_config
    (p_element_type_id => p_element_type_id,
     p_effective_date => p_effective_date);
  end if;

exception
  when others then
    rollback;
    raise;
end delete_setup;

end ben_icd_plan_design_setup;

/

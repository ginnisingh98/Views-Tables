--------------------------------------------------------
--  DDL for Package Body BEN_ELIGIBILITY_OVERRIDE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIGIBILITY_OVERRIDE" as
/* $Header: benovrel.pkb 120.1.12000000.2 2007/08/28 15:38:43 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_eligibility_override.'; -- Global package name

g_lvl_rec g_rec;
--
-- restart the counter variable
procedure reset_counter_rec is
begin
   g_lvl_rec.delete;
end;
--
function format_mesg
return varchar2 is
   i int;
   l_mesg  varchar2(2000);
   l_blank varchar2(5) := rpad(' ',5,' ');
   l_indent varchar2(1) := fnd_global.newline;
begin
   for i in 1..g_lvl_rec.count
   loop
       l_mesg := l_mesg||rpad(substr(g_lvl_rec(i).meaning,1,20),20,' ')||l_indent;
   end loop;
   return l_mesg;
end;
--
procedure update_count(p_lvl_name in varchar2) is

   i int;
   l_meaning hr_lookups.meaning%type;

   cursor hr_lookup is
   select hl.meaning
     from hr_lookups hl
    where hl.lookup_type = 'BEN_COMP_LVL'
      and hl.lookup_code = p_lvl_name;
begin
   for i in 1..g_lvl_rec.count
   loop
       if g_lvl_rec(i).lvl_name = p_lvl_name then
          g_lvl_rec(i).counter := nvl(g_lvl_rec(i).counter,0) + 1;
          return;
       end if;
   end loop;

   open hr_lookup;
   fetch hr_lookup into l_meaning;
   close hr_lookup;

   g_lvl_rec(nvl(g_lvl_rec.count,0) +1).lvl_name := p_lvl_name;
   g_lvl_rec(g_lvl_rec.count).meaning := nvl(l_meaning,p_lvl_name);
   g_lvl_rec(g_lvl_rec.count).counter := 1;
end;
--
function get_level
(p_pgm_id in number,
 p_ptip_id in number,
 p_plip_id in number,
 p_pl_id in number,
 p_oipl_id in number) return varchar2 is

   l_lvl varchar2(10) := 'UNKNOWN';
begin
   if p_pgm_id is not null then
      if p_ptip_id is not null then
         l_lvl := 'PTIP';
      elsif p_plip_id is not null then
         l_lvl := 'PLIP';
      elsif p_pl_id is not null then
         l_lvl := 'PLAN';
      elsif p_oipl_id is not null then
         l_lvl := 'OIPL';
      else
         l_lvl := 'PGM';
      end if;
   elsif p_pl_id is not null then
--      l_lvl := 'PLNIP';
        l_lvl := 'PNIP'; -- Bug 6370016
   end if;
   return l_lvl;
end;

function chk_if_enrolled
(p_pgm_id in number,
 p_pl_id in number,
 p_oipl_id in number,
 p_business_group_id in number,
 p_person_id in number,
 p_effective_date in date)
return varchar2 is

   l_dummy varchar2(1);

   cursor c_elc is
   select 'Y'
     from ben_prtt_enrt_rslt_f prtt
    where prtt.business_group_id = p_business_group_id
      and prtt.person_id = p_person_id
      and p_effective_date between prtt.effective_start_date
      and prtt.effective_end_date
      and nvl(prtt.pgm_id,-1) = nvl(p_pgm_id,-1)
      and prtt.enrt_cvg_thru_dt = hr_api.g_eot
      and prtt.prtt_enrt_rslt_stat_cd is null
      and ( (p_oipl_id is not null and prtt.oipl_id = p_oipl_id)
           or (p_pl_id is not null and prtt.pl_id = p_pl_id));
begin

   open c_elc;
   fetch c_elc into l_dummy;
   close c_elc;

   return(nvl(l_dummy,'N'));

end;

--
-- Updates the elig_flag on a single elig_per_opt record
procedure upd_elig_per_opt_flag
(p_elig_per_rec            in ben_elig_per_f%rowtype,
 p_business_group_id       in number,
 p_elig_flag               in varchar2,
 p_effective_date          in date,
 p_dt_mode                 in varchar2,
 p_cobj_lvl                in varchar2) is

   cursor c_epo is
   select oipl.oipl_id,epo.*
     from ben_elig_per_opt_f epo,
          ben_elig_per_f pep,
          ben_oipl_f oipl
    where epo.elig_per_id = p_elig_per_rec.elig_per_id
      and pep.elig_per_id = epo.elig_per_id
      and oipl.pl_id = pep.pl_id
      and oipl.opt_id = epo.opt_id
      and pep.business_group_id = p_business_group_id
      and epo.business_group_id = p_business_group_id
      and oipl.business_group_id = p_business_group_id
      and p_effective_date between pep.effective_start_date
      and pep.effective_end_date
      and p_effective_date between epo.effective_start_date
      and epo.effective_end_date
      and p_effective_date between oipl.effective_start_date
      and oipl.effective_end_date;

   l_elig_per_opt_rec      c_epo%rowtype;
   l_ovn                   number;
   l_effective_start_date  date;
   l_effective_end_date    date;

begin
   open c_epo;
   loop
      fetch c_epo into l_elig_per_opt_rec;
      if c_epo%notfound then
         exit;
      end if;

      if (chk_if_enrolled
      (p_pgm_id  => p_elig_per_rec.pgm_id,
       p_pl_id   => null,
       p_oipl_id => l_elig_per_opt_rec.oipl_id,
       p_business_group_id => p_business_group_id,
       p_person_id => p_elig_per_rec.person_id,
       p_effective_date => p_effective_date) = 'N') then

         l_ovn := l_elig_per_opt_rec.object_version_number;

         BEN_elig_person_option_API.update_elig_person_option
         (p_validate => FALSE
         ,p_elig_per_opt_id => l_elig_per_opt_rec.elig_per_opt_id
         ,p_elig_per_id => l_elig_per_opt_rec.elig_per_id
         ,p_business_group_id => p_business_group_id
         ,p_elig_flag => p_elig_flag
         ,p_prtn_ovridn_flag => 'Y'
         ,p_effective_start_date => l_effective_start_date
         ,p_effective_end_date => l_effective_end_date
         ,p_object_version_number => l_ovn
         ,p_effective_date => p_effective_date
         ,p_datetrack_mode => p_dt_mode
         );
         update_count(p_cobj_lvl);

      end if;
   end loop;
   close c_epo;

end upd_elig_per_opt_flag;

--
-- Updates the elig_flag on a single elig_per record
procedure upd_elig_per_flag
(p_elig_rec                in ben_elig_per_f%rowtype,
 p_business_group_id       in number,
 p_elig_flag               in varchar2,
 p_effective_date          in date,
 p_dt_mode                 in varchar2,
 p_cobj_lvl                in varchar2) is

   l_ovn                   number := p_elig_rec.object_version_number;
   l_effective_start_date  date;
   l_effective_end_date    date;

begin
   if (chk_if_enrolled
      (p_pgm_id  => p_elig_rec.pgm_id,
       p_pl_id   => p_elig_rec.pl_id,
       p_oipl_id => null,
       p_business_group_id => p_business_group_id,
       p_person_id => p_elig_rec.person_id,
       p_effective_date => p_effective_date) = 'N') then

          BEN_eligible_person_API.update_eligible_person
          (p_validate => FALSE
          ,p_elig_per_id => p_elig_rec.elig_per_id
          ,p_business_group_id => p_business_group_id
          ,p_elig_flag => p_elig_flag
          ,p_prtn_ovridn_flag => 'Y'
          ,p_effective_start_date => l_effective_start_date
          ,p_effective_end_date => l_effective_end_date
          ,p_object_version_number => l_ovn
          ,p_effective_date => p_effective_date
          ,p_datetrack_mode => p_dt_mode
          );

          update_count(p_cobj_lvl);
   end if;

end upd_elig_per_flag;

--
-- if p_elig_flag = Y then marks all the records UP in
-- the hierarchy as eligible
-- if p_elig_flag = N then marks all the records DOWN in
-- the hierarchy as ineligible
--
procedure update_elig_hierarchy
(p_person_id          in number,
 p_pgm_id             in number,
 p_ptip_id            in number,
 p_plip_id            in number,
 p_pl_id              in number,
 p_elig_per_id        in number,
 p_elig_flag          in varchar2,
 p_dt_mode            in varchar2,
 p_business_group_id  in number,
 p_per_in_ler_id      in number,
 p_effective_date     in date,
 p_out_mesg          out nocopy varchar2) is


   l_cobj_lvl           varchar2(30) ;
   l_up                 boolean := false;

   cursor c_elig is
   select pep.*
     from ben_elig_per_f pep
    where pep.person_id = p_person_id
      and nvl(pep.pgm_id,-1) = nvl(p_pgm_id,-1)
      and p_effective_date between pep.effective_start_date and
                                 pep.effective_end_date
      and pep.business_group_id = p_business_group_id
      and ( (p_elig_per_id is not null and
             pep.elig_per_id = p_elig_per_id
            ) or
           (p_pl_id is not null and pep.plip_id is not null and exists
                   (select null
                      from ben_plip_f plip
                     where plip.plip_id = pep.plip_id
                       and plip.pl_id = p_pl_id
                       and plip.pgm_id = p_pgm_id
                       and p_effective_date between plip.effective_start_date and
                                                  plip.effective_end_date
                       and plip.business_group_id = p_business_group_id)
            ) or
            (p_plip_id is not null and pep.ptip_id is not null and exists
                   (select null
                      from ben_ptip_f ptip,
                           ben_plip_f plip,
                           ben_pl_f pln
                     where ptip.ptip_id = pep.ptip_id
                       and ptip.pgm_id = p_pgm_id
                       and plip.plip_id = p_plip_id
                       and pln.pl_id = plip.pl_id
                       and ptip.pl_typ_id = pln.pl_typ_id
                       and p_effective_date between ptip.effective_start_date and
                                                  ptip.effective_end_date
                       and ptip.business_group_id = p_business_group_id
                       and p_effective_date between plip.effective_start_date and
                                                  plip.effective_end_date
                       and plip.business_group_id = p_business_group_id
                       and p_effective_date between pln.effective_start_date and
                                                  pln.effective_end_date
                       and pln.business_group_id = p_business_group_id)
            ) or
            (p_ptip_id is not null and pep.ptip_id is null and
             pep.plip_id is null and pep.pl_id is null)
          );
   l_elig_rec c_elig%rowtype;

   cursor c_inelig is
   select pep.*
     from ben_elig_per_f pep
    where pep.person_id = p_person_id
      and nvl(pep.pgm_id,-1) = nvl(p_pgm_id,-1)
      and p_effective_date between pep.effective_start_date and
                                 pep.effective_end_date
      and pep.business_group_id = p_business_group_id
      and ( (p_pgm_id is not null and p_ptip_id is null and
             p_plip_id is null and p_pl_id is null and
             pep.ptip_id is not null and exists
                   (select null
                      from ben_ptip_f ptip
                     where ptip.ptip_id = pep.ptip_id
                       and ptip.pgm_id = p_pgm_id
                       and p_effective_date between ptip.effective_start_date and
                                                  ptip.effective_end_date
                       and ptip.business_group_id = p_business_group_id)
            ) or
            (p_ptip_id is not null and pep.plip_id is not null and exists
                   (select null
                      from ben_ptip_f ptip,
                           ben_plip_f plip,
                           ben_pl_f pln
                     where ptip.ptip_id = p_ptip_id
                       and ptip.pgm_id = p_pgm_id
                       and ptip.pl_typ_id = pln.pl_typ_id
                       and plip.pl_id = pln.pl_id
                       and plip.plip_id = pep.plip_id
                       and plip.pgm_id = ptip.pgm_id
                       and p_effective_date between ptip.effective_start_date and
                                                  ptip.effective_end_date
                       and ptip.business_group_id = p_business_group_id
                       and p_effective_date between plip.effective_start_date and
                                                  plip.effective_end_date
                       and plip.business_group_id = p_business_group_id
                       and p_effective_date between pln.effective_start_date and
                                                  pln.effective_end_date
                       and pln.business_group_id = p_business_group_id)
            ) or
            (p_plip_id is not null and pep.pl_id is not null and exists
                   (select null
                      from ben_plip_f plip
                     where plip.plip_id = p_plip_id
                       and plip.pgm_id = p_pgm_id
                       and plip.pl_id = pep.pl_id
                       and p_effective_date between plip.effective_start_date and
                                                  plip.effective_end_date
                       and plip.business_group_id = p_business_group_id)
            ) or
            (p_pl_id is not null and pep.pl_id = p_pl_id and exists
                   (select null
                      from ben_elig_per_opt_f epo
                     where epo.elig_per_id = pep.elig_per_id
                       and p_effective_date between epo.effective_start_date and
                                                  epo.effective_end_date
                       and epo.business_group_id = p_business_group_id))
           );

begin

   if p_elig_flag  = 'Y' then

      open c_elig;
      loop
         fetch c_elig into l_elig_rec;
         if c_elig%notfound then
            exit;
         end if;

         l_cobj_lvl := get_level
         (p_pgm_id  => l_elig_rec.pgm_id,
          p_ptip_id => l_elig_rec.ptip_id,
          p_plip_id => l_elig_rec.plip_id,
          p_pl_id   => l_elig_rec.pl_id,
          p_oipl_id => null);

         if nvl(l_elig_rec.elig_flag,'N') <> p_elig_flag then
            upd_elig_per_flag
            (l_elig_rec,
             p_business_group_id,
             p_elig_flag,
             p_effective_date,
             p_dt_mode,
             l_cobj_lvl);
         end if;

         if l_cobj_lvl <> 'PGM' then
            ben_eligibility_override.update_elig_hierarchy
            (p_person_id          => p_person_id,
             p_pgm_id             => p_pgm_id,
             p_ptip_id            => l_elig_rec.ptip_id,
             p_plip_id            => l_elig_rec.plip_id,
             p_pl_id              => l_elig_rec.pl_id,
             p_elig_per_id        => null,
             p_elig_flag          => p_elig_flag,
             p_dt_mode            => p_dt_mode,
             p_business_group_id  => p_business_group_id,
             p_per_in_ler_id      => p_per_in_ler_id,
             p_effective_date     => p_effective_date,
             p_out_mesg           => p_out_mesg);
         end if;
      end loop;
      close c_elig;

   else

      if p_elig_per_id is not null then
         return;
      end if;

      open c_inelig;
      loop
         fetch c_inelig into l_elig_rec;
         if c_inelig%notfound then
            exit;
         end if;

         l_cobj_lvl := get_level
         (p_pgm_id  => l_elig_rec.pgm_id,
          p_ptip_id => l_elig_rec.ptip_id,
          p_plip_id => l_elig_rec.plip_id,
          p_pl_id   => l_elig_rec.pl_id,
          p_oipl_id => null);

         if nvl(l_elig_rec.elig_flag,'N') <> p_elig_flag then
            upd_elig_per_flag
            (l_elig_rec,
             p_business_group_id,
             p_elig_flag,
             p_effective_date,
             p_dt_mode,
             l_cobj_lvl);
         end if;

         if l_cobj_lvl not in ('PLAN','PNIP') then -- Bug 6370016
            ben_eligibility_override.update_elig_hierarchy
            (p_person_id          => p_person_id,
             p_pgm_id             => p_pgm_id,
             p_ptip_id            => l_elig_rec.ptip_id,
             p_plip_id            => l_elig_rec.plip_id,
             p_pl_id              => l_elig_rec.pl_id,
             p_elig_per_id        => null,
             p_elig_flag          => p_elig_flag,
             p_dt_mode            => p_dt_mode,
             p_business_group_id  => p_business_group_id,
             p_per_in_ler_id      => p_per_in_ler_id,
             p_effective_date     => p_effective_date,
             p_out_mesg           => p_out_mesg);
         else
             upd_elig_per_opt_flag
             (l_elig_rec,
              p_business_group_id,
              p_elig_flag,
              p_effective_date,
              p_dt_mode,
              'OIPL');
         end if;

      end loop;
      close c_inelig;
   end if;
   p_out_mesg := format_mesg;
--- no copy
exception
  when others then
    p_out_mesg := null  ;
    raise ;
end update_elig_hierarchy;

--
-- Inserts elig_per records starting from the current level of
-- the comp object upto PGM level
--
procedure create_elig_hierarchy
(p_elig_per           in ben_elig_per_f%rowtype,
 p_cobj_level         in varchar2,
 p_dt_mode            in varchar2,
 p_business_group_id  in number,
 p_effective_date     in date,
 p_out_mesg          out nocopy varchar2) is

   l_elig_per ben_elig_per_f%rowtype := p_elig_per;
   l_eff_dt             date   := p_effective_date;
   l_bg_id              number := p_business_group_id;
   l_cobj_level         varchar2(30) := p_cobj_level;
   l_elig_per_id        number;
   l_effective_start_date  date;
   l_effective_end_date    date;
   l_object_version_number number;
   l_dummy              varchar2(1);

   cursor c_plip is
   select plip.plip_id,plip.ordr_num
     from ben_plip_f plip
    where plip.pl_id = l_elig_per.pl_id
      and plip.pgm_id = l_elig_per.pgm_id
      and l_eff_dt between plip.effective_start_date
      and plip.effective_end_date;

   cursor c_ptip is
   select ptip.ptip_id,ptip.ordr_num
     from ben_ptip_f ptip,
          ben_plip_f plip,
          ben_pl_f pl
    where ptip.pgm_id = l_elig_per.pgm_id
      and ptip.pl_typ_id = pl.pl_typ_id
      and pl.pl_id = plip.pl_id
      and plip.plip_id = l_elig_per.plip_id
      and l_eff_dt between ptip.effective_start_date
      and ptip.effective_end_date
      and l_eff_dt between plip.effective_start_date
      and plip.effective_end_date
      and l_eff_dt between pl.effective_start_date
      and pl.effective_end_date;

   cursor c_elig_cobj is
   select null
     from ben_elig_per_f pep
    where pep.pgm_id = l_elig_per.pgm_id
      and nvl(pep.plip_id,-1) = nvl(l_elig_per.plip_id,-1)
      and nvl(pep.ptip_id,-1) = nvl(l_elig_per.ptip_id,-1)
      and nvl(pep.pl_id,-1) = nvl(l_elig_per.pl_id,-1)
      and pep.person_id = l_elig_per.person_id
      and (pep.per_in_ler_id is null or
           exists
           (select null
              from ben_per_in_ler pil
             where pep.per_in_ler_id = pil.per_in_ler_id
               and pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')))
      and l_eff_dt between pep.effective_start_date
      and pep.effective_end_date;

begin

   if l_elig_per.pgm_id is null then
      return;
   end if;

   -- fetch the next higher level comp object
   if l_cobj_level = 'PLAN' then
      open c_plip;
      fetch c_plip into l_elig_per.plip_id,l_elig_per.plip_ordr_num;
      close c_plip;
      l_elig_per.pl_id := null;
      l_cobj_level := 'PLIP';
   elsif l_cobj_level = 'PLIP' then
      open c_ptip;
      fetch c_ptip into l_elig_per.ptip_id, l_elig_per.ptip_ordr_num ;
      close c_ptip;
      l_elig_per.plip_id    := null;
      l_elig_per.plip_ordr_num := null;
      l_cobj_level := 'PTIP';
   elsif l_cobj_level = 'PTIP' then
      l_elig_per.ptip_id    := null;
      l_elig_per.ptip_ordr_num := null;
      l_cobj_level := 'PGM';
   else
      return;
   end if;

   -- check if the comp object already exists in elig_per
   -- if not, create a new eli_per record for the comp object
   open c_elig_cobj;
   fetch c_elig_cobj into l_dummy;
   if c_elig_cobj%notfound then

      BEN_eligible_person_API.create_eligible_person
      (p_validate => FALSE
      ,p_ELIG_PER_ID => l_elig_per_id
      ,p_EFFECTIVE_START_DATE => l_EFFECTIVE_START_DATE
      ,p_EFFECTIVE_END_DATE => l_EFFECTIVE_END_DATE
      ,p_BUSINESS_GROUP_ID =>l_bg_id
      ,p_PL_ID => l_elig_per.pl_id
      ,p_PGM_ID => l_elig_per.pgm_id
      ,p_PLIP_ID => l_elig_per.plip_id
      ,p_PTIP_ID => l_elig_per.ptip_id
      ,p_LER_ID =>l_elig_per.LER_ID
      ,p_PERSON_ID =>l_elig_per.PERSON_ID
      ,p_PER_IN_LER_ID =>l_elig_per.PER_IN_LER_ID
      ,p_DPNT_OTHR_PL_CVRD_RL_FLAG =>l_elig_per.DPNT_OTHR_PL_CVRD_RL_FLAG
      ,p_PRTN_OVRIDN_THRU_DT =>l_elig_per.PRTN_OVRIDN_THRU_DT
      ,p_PL_KEY_EE_FLAG =>l_elig_per.PL_KEY_EE_FLAG
      ,p_PL_HGHLY_COMPD_FLAG =>l_elig_per.PL_HGHLY_COMPD_FLAG
      ,p_ELIG_FLAG =>l_elig_per.ELIG_FLAG
      ,p_COMP_REF_AMT =>l_elig_per.COMP_REF_AMT
      ,p_CMBN_AGE_N_LOS_VAL =>l_elig_per.CMBN_AGE_N_LOS_VAL
      ,p_COMP_REF_UOM =>l_elig_per.COMP_REF_UOM
      ,p_AGE_VAL =>l_elig_per.AGE_VAL
      ,p_LOS_VAL =>l_elig_per.LOS_VAL
      ,p_PRTN_END_DT =>l_elig_per.PRTN_END_DT
      ,p_PRTN_STRT_DT =>l_elig_per.PRTN_STRT_DT
      ,p_wait_perd_cmpltn_dt =>l_elig_per.wait_perd_cmpltn_dt
      ,p_wait_perd_strt_dt =>l_elig_per.wait_perd_strt_dt
      ,p_WV_CTFN_TYP_CD =>l_elig_per.WV_CTFN_TYP_CD
      ,p_HRS_WKD_VAL =>l_elig_per.HRS_WKD_VAL
      ,p_HRS_WKD_BNDRY_PERD_CD =>l_elig_per.HRS_WKD_BNDRY_PERD_CD
      ,p_PRTN_OVRIDN_FLAG =>l_elig_per.PRTN_OVRIDN_FLAG
      ,p_NO_MX_PRTN_OVRID_THRU_FLAG =>l_elig_per.NO_MX_PRTN_OVRID_THRU_FLAG
      ,p_PRTN_OVRIDN_RSN_CD =>l_elig_per.PRTN_OVRIDN_RSN_CD
      ,p_AGE_UOM =>l_elig_per.AGE_UOM
      ,p_LOS_UOM =>l_elig_per.LOS_UOM
      ,p_OVRID_SVC_DT =>l_elig_per.OVRID_SVC_DT
      ,p_inelg_rsn_cd =>l_elig_per.inelg_rsn_cd
      ,p_FRZ_LOS_FLAG =>l_elig_per.FRZ_LOS_FLAG
      ,p_FRZ_AGE_FLAG =>l_elig_per.FRZ_AGE_FLAG
      ,p_FRZ_CMP_LVL_FLAG =>l_elig_per.FRZ_CMP_LVL_FLAG
      ,p_FRZ_PCT_FL_TM_FLAG =>l_elig_per.FRZ_PCT_FL_TM_FLAG
      ,p_FRZ_HRS_WKD_FLAG =>l_elig_per.FRZ_HRS_WKD_FLAG
      ,p_FRZ_COMB_AGE_AND_LOS_FLAG =>l_elig_per.FRZ_COMB_AGE_AND_LOS_FLAG
      ,p_DSTR_RSTCN_FLAG =>l_elig_per.DSTR_RSTCN_FLAG
      ,p_PCT_FL_TM_VAL =>l_elig_per.PCT_FL_TM_VAL
      ,p_WV_PRTN_RSN_CD =>l_elig_per.WV_PRTN_RSN_CD
      ,p_rt_comp_ref_amt =>l_elig_per.rt_comp_ref_amt
      ,p_rt_cmbn_age_n_los_val =>l_elig_per.rt_cmbn_age_n_los_val
      ,p_rt_comp_ref_uom =>l_elig_per.rt_comp_ref_uom
      ,p_rt_age_val =>l_elig_per.rt_age_val
      ,p_rt_los_val =>l_elig_per.rt_los_val
      ,p_rt_hrs_wkd_val =>l_elig_per.rt_hrs_wkd_val
      ,p_rt_hrs_wkd_bndry_perd_cd =>l_elig_per.rt_hrs_wkd_bndry_perd_cd
      ,p_rt_age_uom =>l_elig_per.rt_age_uom
      ,p_rt_los_uom =>l_elig_per.rt_los_uom
      ,p_rt_pct_fl_tm_val =>l_elig_per.rt_pct_fl_tm_val
      ,p_rt_frz_los_flag =>l_elig_per.rt_frz_los_flag
      ,p_rt_frz_age_flag =>l_elig_per.rt_frz_age_flag
      ,p_rt_frz_cmp_lvl_flag =>l_elig_per.rt_frz_cmp_lvl_flag
      ,p_rt_frz_pct_fl_tm_flag =>l_elig_per.rt_frz_pct_fl_tm_flag
      ,p_rt_frz_hrs_wkd_flag =>l_elig_per.rt_frz_hrs_wkd_flag
      ,p_rt_frz_comb_age_and_los_flag =>l_elig_per.rt_frz_comb_age_and_los_flag
      ,p_once_r_cntug_cd =>l_elig_per.once_r_cntug_cd
      ,p_pl_ordr_num   =>l_elig_per.pl_ordr_num
      ,p_plip_ordr_num =>l_elig_per.plip_ordr_num
      ,p_ptip_ordr_num =>l_elig_per.ptip_ordr_num
      ,p_PEP_ATTRIBUTE_CATEGORY =>l_elig_per.PEP_ATTRIBUTE_CATEGORY
      ,p_PEP_ATTRIBUTE1 =>l_elig_per.PEP_ATTRIBUTE1
      ,p_PEP_ATTRIBUTE2 =>l_elig_per.PEP_ATTRIBUTE2
      ,p_PEP_ATTRIBUTE3 =>l_elig_per.PEP_ATTRIBUTE3
      ,p_PEP_ATTRIBUTE4 =>l_elig_per.PEP_ATTRIBUTE4
      ,p_PEP_ATTRIBUTE5 =>l_elig_per.PEP_ATTRIBUTE5
      ,p_PEP_ATTRIBUTE6 =>l_elig_per.PEP_ATTRIBUTE6
      ,p_PEP_ATTRIBUTE7 =>l_elig_per.PEP_ATTRIBUTE7
      ,p_PEP_ATTRIBUTE8 =>l_elig_per.PEP_ATTRIBUTE8
      ,p_PEP_ATTRIBUTE9 =>l_elig_per.PEP_ATTRIBUTE9
      ,p_PEP_ATTRIBUTE10 =>l_elig_per.PEP_ATTRIBUTE10
      ,p_PEP_ATTRIBUTE11 =>l_elig_per.PEP_ATTRIBUTE11
      ,p_PEP_ATTRIBUTE12 =>l_elig_per.PEP_ATTRIBUTE12
      ,p_PEP_ATTRIBUTE13 =>l_elig_per.PEP_ATTRIBUTE13
      ,p_PEP_ATTRIBUTE14 =>l_elig_per.PEP_ATTRIBUTE14
      ,p_PEP_ATTRIBUTE15 =>l_elig_per.PEP_ATTRIBUTE15
      ,p_PEP_ATTRIBUTE16 =>l_elig_per.PEP_ATTRIBUTE16
      ,p_PEP_ATTRIBUTE17 =>l_elig_per.PEP_ATTRIBUTE17
      ,p_PEP_ATTRIBUTE18 =>l_elig_per.PEP_ATTRIBUTE18
      ,p_PEP_ATTRIBUTE19 =>l_elig_per.PEP_ATTRIBUTE19
      ,p_PEP_ATTRIBUTE20 =>l_elig_per.PEP_ATTRIBUTE20
      ,p_PEP_ATTRIBUTE21 =>l_elig_per.PEP_ATTRIBUTE21
      ,p_PEP_ATTRIBUTE22 =>l_elig_per.PEP_ATTRIBUTE22
      ,p_PEP_ATTRIBUTE23 =>l_elig_per.PEP_ATTRIBUTE23
      ,p_PEP_ATTRIBUTE24 =>l_elig_per.PEP_ATTRIBUTE24
      ,p_PEP_ATTRIBUTE25 =>l_elig_per.PEP_ATTRIBUTE25
      ,p_PEP_ATTRIBUTE26 =>l_elig_per.PEP_ATTRIBUTE26
      ,p_PEP_ATTRIBUTE27 =>l_elig_per.PEP_ATTRIBUTE27
      ,p_PEP_ATTRIBUTE28 =>l_elig_per.PEP_ATTRIBUTE28
      ,p_PEP_ATTRIBUTE29 =>l_elig_per.PEP_ATTRIBUTE29
      ,p_PEP_ATTRIBUTE30 =>l_elig_per.PEP_ATTRIBUTE30
      ,p_request_id =>l_elig_per.request_id
      ,p_program_application_id =>l_elig_per.program_application_id
      ,p_program_id =>l_elig_per.program_id
      ,p_program_update_date =>l_elig_per.program_update_date
      ,p_OBJECT_VERSION_NUMBER =>l_OBJECT_VERSION_NUMBER
      ,p_effective_date => p_effective_date
      );
      update_count(l_cobj_level);
   end if;
   close c_elig_cobj;

   -- if we have not reached the top of hierarchy, recurse
   if l_cobj_level <> 'PGM' then
      create_elig_hierarchy
      (p_elig_per           =>l_elig_per,
       p_cobj_level         =>l_cobj_level,
       p_dt_mode            =>p_dt_mode,
       p_business_group_id  =>p_business_group_id,
       p_effective_date     =>p_effective_date,
       p_out_mesg           =>p_out_mesg);
   else
       p_out_mesg := format_mesg;
       reset_counter_rec;
   end if;
exception
  when others then
    p_out_mesg := null ;
    raise ;

end create_elig_hierarchy;

End ben_eligibility_override;

/

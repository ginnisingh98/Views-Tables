--------------------------------------------------------
--  DDL for Package Body BEN_CARRY_FORWARD_ITEMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CARRY_FORWARD_ITEMS" as
/* $Header: bencfwsu.pkb 120.21.12010000.8 2009/10/11 07:24:49 pvelvano ship $ */

g_package   varchar2(31) := 'ben_carry_forward_items.';
g_debug     boolean      := false;

procedure main
(p_person_id            number,
 p_per_in_ler_id        number,
 p_ler_id               number,
 p_effective_date       date,
 p_lf_evt_ocrd_dt       date,
 p_business_group_id    number
 -- p_called_from          varchar2
  ) is

  l_proc                       varchar2(72) := g_package||'main';
  l_act_effective_date         date;
  l_effective_start_date       date;
  l_effective_end_date         date;
  l_effective_date             date;

  cursor c_pen is
  select pen.*
    from ben_prtt_enrt_rslt_f pen
        ,ben_per_in_ler       pil
        ,ben_ler_f            ler
    where pen.person_id = p_person_id
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.sspndd_flag = 'Y'
    and pen.business_group_id = p_business_group_id
    and pil.per_in_ler_id = pen.per_in_ler_id
    and pil.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
    and pil.lf_evt_ocrd_dt  <= p_lf_evt_ocrd_dt
    and pil.ler_id = ler.ler_id
    and ler.typ_cd not in ('SCHEDDU', 'COMP', 'ABS','GSP')
    and ler.business_group_id = pil.business_group_id
    and p_effective_date between
        ler.effective_start_date and ler.effective_end_date
    and ((p_effective_date between
        pen.effective_start_date and pen.effective_end_date)
        or (p_lf_evt_ocrd_dt <= pen.effective_start_date))    -- 5741760: PEN recs on a Future date shud also be carried fwd.
    and pen.enrt_cvg_thru_dt = hr_api.g_eot
    and pen.effective_end_date = hr_api.g_eot;
  l_pen_rec c_pen%rowtype;
  --
  cursor c_get_actn_items_sus(p_prtt_enrt_rslt_id  number,
                              p_eff_dt             date) is
    select pea.*
    from ben_prtt_enrt_actn_f pea
        ,ben_per_in_ler       pil
    where pea.business_group_id = p_business_group_id
    and pea.cmpltd_dt is null
    and pea.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and pil.per_in_ler_id = pea.per_in_ler_id
    and pil.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
    and p_eff_dt between
        pea.effective_start_date and pea.effective_end_date
    order by pea.rqd_flag desc,pea.due_dt asc;
  l_act_sus  c_get_actn_items_sus%rowtype;
  --
  cursor c_get_opt_actn_items_unsus(p_eff_dt date) is
    select pea.*,
           pen.object_version_number pen_ovn
    from ben_prtt_enrt_actn_f pea
        ,ben_prtt_enrt_rslt_f pen
        ,ben_per_in_ler       pil
        ,ben_ler_f            ler
    where pea.business_group_id = p_business_group_id
    and pea.cmpltd_dt is null
    and pea.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
    and pen.person_id = p_person_id
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.sspndd_flag = 'N'
    and pen.business_group_id = pea.business_group_id
    and pil.per_in_ler_id = pea.per_in_ler_id
    and pil.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
    and pil.ler_id = ler.ler_id
    and p_eff_dt between
        ler.effective_start_date and ler.effective_end_date
--  For Bug 6941981 Added an option
--  and ler.typ_cd not in ('COMP', 'ABS', 'GSP')
    and ler.typ_cd not in ('SCHEDDU','COMP', 'ABS', 'GSP')
    and p_eff_dt between
        pea.effective_start_date and pea.effective_end_date
    and p_eff_dt between
        pen.effective_start_date and pen.effective_end_date
    and nvl(pen.enrt_cvg_thru_dt,hr_api.g_eot) = hr_api.g_eot
    and pen.effective_end_date = hr_api.g_eot;
  l_opt_unsus  c_get_opt_actn_items_unsus%rowtype;
  --
  cursor c_epe(p_per_in_ler_id  number) is
  select 'Y' epe_found_flag
    from ben_elig_per_elctbl_chc epe
   where per_in_ler_id = p_per_in_ler_id
     and (epe.pgm_id is NULL or
          epe.pgm_id = l_pen_rec.pgm_id )
     and (epe.oipl_id is NULL or
          epe.oipl_id = l_pen_rec.oipl_id )
     and  epe.pl_id = l_pen_rec.pl_id ;
  --
  l_epe_found_flag  varchar2(30) := 'N' ;
  --
  /* Cursor Not being used in the code
  cursor c_enrt_window is
  select enrt_perd_strt_dt
    from ben_pil_elctbl_chc_popl
   where pil_elctbl_chc_popl_id = l_epe_rec.pil_elctbl_chc_popl_id;
  --
  */
  cursor c_min_max_date (p_prtt_enrt_rslt_id number) is
  select min(effective_start_date),
         max(effective_end_date)
    from ben_prtt_enrt_rslt_f
   where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id;
  --
  cursor c_pen_ovn(p_eff_dt  date) is
  select object_version_number
    from ben_prtt_enrt_rslt_f
   where prtt_enrt_rslt_id = l_pen_rec.prtt_enrt_rslt_id
     and prtt_enrt_rslt_stat_cd is null
     and p_eff_dt between effective_start_date
     and effective_end_date;
  --
  cursor c_get_enrt_bnft (p_elig_per_elctbl_chc_id number) is
  select enrt_bnft_id
    from ben_elctbl_chc_ctfn
   where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
     and rqd_flag = 'Y'
     and business_group_id = p_business_group_id;
  l_get_enrt_bnft c_get_enrt_bnft%rowtype;


  l_min_start_date                date;
  l_max_end_date                  date;
  l_pea_effective_date            date;
  l_datetrack_mode                varchar2(30);
  l_correction                    boolean;
  l_update                        boolean;
  l_update_override               boolean;
  l_update_change_insert          boolean;
  l_act_item_expired              boolean := false;
  l_enrt_perd_strt_dt             date;
  l_object_version_number         number;
  l_rslt_object_version_number    number;
  l_use_enrt_bnft                 boolean := false;
  l_suspend_flag                  varchar2(30);
  l_dpnt_actn_warning             boolean;
  l_bnf_actn_warning              boolean;
  l_ctfn_actn_warning             boolean;
  l_dummy_number                  number;
  l_dummy_boolean                 boolean;
  l_dummy_char                    varchar2(30);
  l_dummy_date                    date;
  l_prev_popl_id                  number := -1;

begin
--  hr_utility.trace_on(null,'trace');
  hr_utility.set_location('Entering '||l_proc,1);
  hr_utility.set_location('p_effective_date '||p_effective_date,10);
  hr_utility.set_location('p_per_in_ler_id '||p_per_in_ler_id,10);
  g_debug := hr_utility.debug_enabled;
  --
  l_effective_date := p_lf_evt_ocrd_dt;
  --
  open c_pen;
  loop
    --
    fetch c_pen into l_pen_rec;
    if c_pen%notfound then
      exit;
    end if;
    --
      --
      l_act_item_expired := false;
      --
      -- check if the person has an elctbl chc for the current pil
      --
      l_effective_date := GREATEST(p_lf_evt_ocrd_dt,l_pen_rec.effective_start_date);
      --
      -- end all incomplete action items for the suspended result
      --
      open c_get_actn_items_sus(l_pen_rec.prtt_enrt_rslt_id,
                                   l_effective_date);
      loop
         --
         fetch c_get_actn_items_sus into l_act_sus;
         if c_get_actn_items_sus%notfound then
            exit;
         end if;

         if l_act_sus.rqd_flag = 'Y' and
            nvl(l_act_sus.due_dt,hr_api.g_eot) < l_effective_date and
            c_get_actn_items_sus%rowcount = 1  then
                 l_act_item_expired := true;
         end if;

         if l_act_sus.effective_start_date < l_effective_date then
                    l_datetrack_mode := hr_api.g_delete;
         else
                    l_datetrack_mode := hr_api.g_zap;
         end if;

         l_pea_effective_date := greatest(l_effective_date-1,l_act_sus.effective_start_date);
         hr_utility.set_location('Delete A1'||l_pen_rec.prtt_enrt_rslt_id ,10);

         ben_prtt_enrt_actn_api.delete_prtt_enrt_actn
                 (p_prtt_enrt_actn_id     => l_act_sus.prtt_enrt_actn_id
                 ,p_business_group_id     => p_business_group_id
                 ,p_effective_date        => l_pea_effective_date
                 ,p_datetrack_mode        => l_datetrack_mode
                 ,p_object_version_number => l_act_sus.object_version_number
                 ,p_prtt_enrt_rslt_id     => l_pen_rec.prtt_enrt_rslt_id
                 ,p_rslt_object_version_number => l_pen_rec.object_version_number
                 ,p_unsuspend_enrt_flag   => 'N'
                 ,p_gnrt_cm               => false
                 ,p_effective_start_date  => l_effective_start_date
                 ,p_effective_end_date    => l_effective_end_date);
         --
      end loop;
      --
      close c_get_actn_items_sus;
      --
      if l_act_item_expired THEN
         --
         hr_utility.set_location ('Expired action items exist ..',10);
         open c_min_max_date (l_pen_rec.prtt_enrt_rslt_id);
         fetch c_min_max_date into l_min_start_date,l_max_end_date;
         close c_min_max_date;
         --
         open c_pen_ovn(l_effective_date);
         fetch c_pen_ovn into l_pen_rec.object_version_number;
         close c_pen_ovn;

         if l_min_start_date <= l_effective_date and
            l_max_end_date > l_effective_date
         then
            hr_utility.set_location('delete_enrollment 1'||l_pen_rec.prtt_enrt_rslt_id,10);
            ben_prtt_enrt_result_api.delete_enrollment
                 (p_prtt_enrt_rslt_id     => l_pen_rec.prtt_enrt_rslt_id
                 ,p_per_in_ler_id         => p_per_in_ler_id
                 ,p_business_group_id     => p_business_group_id
                 ,p_effective_start_date  => l_effective_start_date
                 ,p_effective_end_date    => l_effective_end_date
                 ,p_object_version_number => l_pen_rec.object_version_number
                 ,p_effective_date        => l_effective_date
                 ,p_datetrack_mode        => hr_api.g_delete
                 ,p_multi_row_validate    => false  --BUG 4718599 to be in sync with inelig
                 ,p_source                => 'beninelg');
         else
               hr_utility.set_location('delete_enrollment 2'
                                       ||l_pen_rec.prtt_enrt_rslt_id,10);
               ben_prtt_enrt_result_api.delete_enrollment
                 (p_prtt_enrt_rslt_id     => l_pen_rec.prtt_enrt_rslt_id
                 ,p_per_in_ler_id         => p_per_in_ler_id
                 ,p_business_group_id     => p_business_group_id
                 ,p_effective_start_date  => l_effective_start_date
                 ,p_effective_end_date    => l_effective_end_date
                 ,p_object_version_number => l_pen_rec.object_version_number
                 ,p_effective_date        => l_effective_date
                 ,p_datetrack_mode        => hr_api.g_delete
                 ,p_multi_row_validate    => false --BUG 4718599 true
                 ,p_source                => 'benmngle');
         end if;
      end if;
  end loop;
  close c_pen;
  --
  --  Close pending optional action items from prior event.
  --
  for l_pea_rec in c_get_opt_actn_items_unsus(l_effective_date) loop
    --
    --If the Previous cert is started on this day..we have an issue.
    --
    IF l_pea_rec.effective_start_date = l_effective_date THEN
      l_pea_effective_date := l_effective_date;
    ELSE
      l_pea_effective_date := l_effective_date - 1;
    END IF;
    --
    -- l_pea_effective_date := l_effective_date - 1;
    --
    if l_pea_effective_date = l_pea_rec.effective_start_date then
       l_datetrack_mode := hr_api.g_zap;
    else
       l_datetrack_mode := hr_api.g_delete;
    end if;
    --
    l_object_version_number :=  l_pea_rec.object_version_number;
    --
    if l_pea_effective_date <> l_pea_rec.effective_end_date then
       --
       hr_utility.set_location('OPtional delete_prtt_enrt_actn'||
                                l_pea_rec.prtt_enrt_actn_id,10);
       ben_prtt_enrt_actn_api.delete_prtt_enrt_actn
         (p_prtt_enrt_actn_id          => l_pea_rec.prtt_enrt_actn_id
         ,p_business_group_id          => p_business_group_id
         ,p_effective_date             => l_pea_effective_date
         ,p_datetrack_mode             => l_datetrack_mode
         ,p_object_version_number      => l_object_version_number
         ,p_prtt_enrt_rslt_id          => l_pea_rec.prtt_enrt_rslt_id
         ,p_rslt_object_version_number => l_pea_rec.pen_ovn
         ,p_unsuspend_enrt_flag        => 'N'
         ,p_effective_start_date       => l_effective_start_date
         ,p_effective_end_date         => l_effective_end_date);
       --
       hr_utility.set_location('prtt_enrt_actn_id:'||
                                l_pea_rec.prtt_enrt_actn_id, 10);
    end if;
    --
  end loop;

  hr_utility.set_location('Leaving '||l_proc,1);

end main;

procedure reinstate_dpnt(p_pgm_id                 in number,
                           p_pl_id                  in number,
                           p_oipl_id                in number,
                           p_business_group_id      in number,
                           p_person_id              in number,
                           p_per_in_ler_id          in number,
                           p_elig_per_elctbl_chc_id in number,
                           p_dpnt_cvg_strt_dt_cd    in varchar2,
                           p_dpnt_cvg_strt_dt_rl    in number,
                           p_enrt_cvg_strt_dt       in date,
                           p_effective_date         in date ,
                           p_prev_prtt_enrt_rslt_id in number default  null ) is

  l_lf_evt_ocrd_dt   date;
  l_cvg_strt_dt      date;
  l_old_cvg_strt_dt  date;
  l_pl_typ_id        number ;
  l_opt_id           number ;
  --
  cursor c_pl_typ is
    select pl_typ_id
     from  ben_pl_f pl
    where  pl.pl_id = p_pl_id
      and  p_effective_date   between
           pl.effective_start_date  and
           pl.effective_end_date ;
   --
   cursor c_opt is
    select opt_id
     from  ben_oipl_f  oipl
    where  oipl.oipl_id  = p_oipl_id
      and  p_effective_date   between
           oipl.effective_start_date  and
           oipl.effective_end_date ;
    --
    cursor c_prev_per_in_ler is
    select max(pil.lf_evt_ocrd_dt)
    from ben_per_in_ler pil
    where pil.business_group_id = p_business_group_id
    and pil.person_id = p_person_id
    and pil.per_in_ler_id <> p_per_in_ler_id
    and pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD');
    --
    cursor c_previous_ptip_oipl_result is
    select  pen.prtt_enrt_rslt_id,pen.ENRT_CVG_STRT_DT ,pen.per_in_ler_id
    from  ben_prtt_enrt_rslt_f pen,
          ben_oipl_f     oipl
    where oipl.oipl_id = pen.oipl_id
    and   pen.pl_typ_id = l_pl_typ_id
    and   oipl.opt_id  = l_opt_id
    and   pen.person_id = p_person_id
    and   pen.per_in_ler_id = p_per_in_ler_id
    and   pen.effective_end_date =  hr_api.g_eot
    and   pen.enrt_cvg_thru_dt   <> hr_api.g_eot
    and   pen.effective_start_date  between oipl.effective_start_date
          and  oipl.effective_end_date
    AND   pen.prtt_enrt_rslt_stat_cd  IS NULL
    ;
    --
    cursor c_previous_pgm_ptip_result is
    select  pen.prtt_enrt_rslt_id,pen.ENRT_CVG_STRT_DT ,pen.per_in_ler_id
    from  ben_prtt_enrt_rslt_f pen
    where  pen.pl_typ_id = l_pl_typ_id
    and   pen.person_id = p_person_id
    and   pen.per_in_ler_id = p_per_in_ler_id
    and   pen.effective_end_date =  hr_api.g_eot
    and   pen.enrt_cvg_thru_dt   <> hr_api.g_eot
    AND   pen.prtt_enrt_rslt_stat_cd  IS NULL
    ;

    cursor c_previous_pl_oipl_result is
    select pen.prtt_enrt_rslt_id,pen.ENRT_CVG_STRT_DT ,pen.per_in_ler_id
    from  ben_prtt_enrt_rslt_f pen,
          ben_oipl_f     oipl
    where oipl.oipl_id = pen.oipl_id
    and   pen.pl_typ_id = l_pl_typ_id
    and   oipl.opt_id  = l_opt_id
    and   pen.person_id = p_person_id
    and   pen.per_in_ler_id = p_per_in_ler_id
    and   pen.effective_end_date =  hr_api.g_eot
    and   pen.enrt_cvg_thru_dt   <> hr_api.g_eot
    and   pen.effective_start_date  between oipl.effective_start_date
          and  oipl.effective_end_date
    AND   pen.prtt_enrt_rslt_stat_cd  IS NULL
    ;
    --
    cursor c_previous_result_id_result is
    select pen.ENRT_CVG_STRT_DT ,pen.per_in_ler_id
    from ben_prtt_enrt_rslt_f pen
    where
        pen.prtt_enrt_rslt_id  = p_prev_prtt_enrt_rslt_id
    and pen.person_id = p_person_id
    -- this condition removed  to CFD from any result
    --and pen.per_in_ler_id = p_per_in_ler_id
    and   pen.effective_end_date =  hr_api.g_eot
    and   pen.enrt_cvg_thru_dt   <> hr_api.g_eot
    AND   pen.prtt_enrt_rslt_stat_cd  is null
    ;


    cursor c_previous_pl_result is
    select pen.prtt_enrt_rslt_id,pen.ENRT_CVG_STRT_DT ,pen.per_in_ler_id
    from  ben_prtt_enrt_rslt_f pen
    where  pen.pl_typ_id = l_pl_typ_id
    and   pen.person_id = p_person_id
    and   pen.per_in_ler_id = p_per_in_ler_id
    and   pen.effective_end_date =  hr_api.g_eot
    and   pen.enrt_cvg_thru_dt   <> hr_api.g_eot
    AND   pen.prtt_enrt_rslt_stat_cd  IS NULL
    ;

    cursor c_prev_pen_dpnts(v_enrt_rslt_id number,v_per_in_ler_id number) is
    select
                pdp_old.EFFECTIVE_END_DATE,
                pdp_old.CVG_STRT_DT,
                pdp_old.CVG_THRU_DT,
                pdp_old.CVG_PNDG_FLAG,
                pdp_old.OVRDN_FLAG,
                pdp_old.OVRDN_THRU_DT,
                pdp_old.PRTT_ENRT_RSLT_ID,
                pdp_old.DPNT_PERSON_ID,
                pdp_old.PER_IN_LER_ID,
                pdp_old.BUSINESS_GROUP_ID,
                pdp_old.PDP_ATTRIBUTE_CATEGORY,
                pdp_old.PDP_ATTRIBUTE1,
                pdp_old.PDP_ATTRIBUTE2,
                pdp_old.PDP_ATTRIBUTE3,
                pdp_old.PDP_ATTRIBUTE4,
                pdp_old.PDP_ATTRIBUTE5,
                pdp_old.PDP_ATTRIBUTE6,
                pdp_old.PDP_ATTRIBUTE7,
                pdp_old.PDP_ATTRIBUTE8,
                pdp_old.PDP_ATTRIBUTE9,
                pdp_old.PDP_ATTRIBUTE10,
                pdp_old.PDP_ATTRIBUTE11,
                pdp_old.PDP_ATTRIBUTE12,
                pdp_old.PDP_ATTRIBUTE13,
                pdp_old.PDP_ATTRIBUTE14,
                pdp_old.PDP_ATTRIBUTE15,
                pdp_old.PDP_ATTRIBUTE16,
                pdp_old.PDP_ATTRIBUTE17,
                pdp_old.PDP_ATTRIBUTE18,
                pdp_old.PDP_ATTRIBUTE19,
                pdp_old.PDP_ATTRIBUTE20,
                pdp_old.PDP_ATTRIBUTE21,
                pdp_old.PDP_ATTRIBUTE22,
                pdp_old.PDP_ATTRIBUTE23,
                pdp_old.PDP_ATTRIBUTE24,
                pdp_old.PDP_ATTRIBUTE25,
                pdp_old.PDP_ATTRIBUTE26,
                pdp_old.PDP_ATTRIBUTE27,
                pdp_old.PDP_ATTRIBUTE28,
                pdp_old.PDP_ATTRIBUTE29,
                pdp_old.PDP_ATTRIBUTE30,
                pdp_old.LAST_UPDATE_DATE,
                pdp_old.LAST_UPDATED_BY,
                pdp_old.LAST_UPDATE_LOGIN,
                pdp_old.CREATED_BY,
                pdp_old.CREATION_DATE,
                pdp_old.REQUEST_ID,
                pdp_old.PROGRAM_APPLICATION_ID,
                pdp_old.PROGRAM_ID,
                pdp_old.PROGRAM_UPDATE_DATE,
                pdp_old.OBJECT_VERSION_NUMBER,
                pdp_old.elig_cvrd_dpnt_id,
                pdp_old.EFFECTIVE_START_DATE
    from ben_elig_cvrd_dpnt_f pdp_old
    where
          pdp_old.per_in_ler_id       = v_per_in_ler_id
      and pdp_old.prtt_enrt_rslt_id   = v_enrt_rslt_id
      and pdp_old.business_group_id   = p_business_group_id;

  cursor c_epe_dpnt(l_elig_per_elctbl_chc_id number,l_dpnt_person_id number) is
  select edg.*
  from ben_elig_dpnt edg
  where  edg.elig_per_elctbl_chc_id = l_elig_per_elctbl_chc_id
    and  edg.business_group_id      = p_business_group_id
    and  edg.dpnt_person_id         = l_dpnt_person_id;


  --# bug  2623034 cursot to find the max dpnd allowed
  cursor c_total_rqmt is
  select r.mx_dpnts_alwd_num,
         r.no_mx_num_dfnd_flag,
         r.dsgn_rqmt_id,
         r.grp_rlshp_cd
    from ben_dsgn_rqmt_f r
  where ((r.pl_id = p_pl_id)
          or
          (r.oipl_id = p_oipl_id)
          or
          (r.opt_id = (select opt_id
                         from ben_oipl_f
                        where oipl_id = p_oipl_id
                          and p_effective_date between effective_start_date
                                                   and effective_end_date
                          and business_group_id = p_business_group_id)))
     and r.dsgn_typ_cd = 'DPNT'
     -- this should be reoved but couldnt locate relation between grp and type
    -- and r.grp_rlshp_cd is null
     --
     and r.business_group_id = p_business_group_id
     and p_effective_date between r.effective_start_date
                              and r.effective_end_date;
  --
  cursor c_tot_elig_dpnt
        ( v_per_in_ler_id number,
          v_prtt_enrt_rslt_id number,
          v_dsgn_rqmt_id number ,
          v_grp_rlshp_cd varchar2 ) is
    select count(pdp.dpnt_person_id)
    from   ben_elig_cvrd_dpnt_f pdp,
           ben_elig_dpnt egd ,
           per_contact_relationships pcr
    where  pdp.business_group_id = p_business_group_id
      and  pdp.per_in_ler_id     = v_per_in_ler_id
      and  pdp.prtt_enrt_rslt_id = v_prtt_enrt_rslt_id
      and  pdp.cvg_strt_dt is not null
      and  p_effective_date between pdp.effective_start_date
          and pdp.effective_end_date
     and egd.business_group_id = pdp.business_group_id
     and pdp.dpnt_person_id = egd.dpnt_person_id
     and egd.per_in_ler_id  = v_per_in_ler_id
     and egd.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
     and pcr.person_id = p_person_id
     and pcr.contact_person_id =  egd.dpnt_person_id
     and p_effective_date between  nvl(pcr.date_start,p_effective_date)
         and  nvl(pcr.date_end,p_effective_date)
     and (pcr.contact_type in
          ( select drt.rlshp_typ_cd
            from  ben_dsgn_rqmt_f bdr ,
            ben_dsgn_rqmt_rlshp_typ drt
            where bdr.dsgn_rqmt_id = v_dsgn_rqmt_id
            and   drt.dsgn_rqmt_id = bdr.dsgn_rqmt_id
            and  ( bdr.grp_rlshp_cd = v_grp_rlshp_cd or
                  (bdr.grp_rlshp_cd is null and v_grp_rlshp_cd is null )
                 )
            and   p_effective_date between bdr.effective_start_date
                  and bdr.effective_end_date
           )
             --- if there is no relation typ defind take all
           or
           not exists
           (select 'x'  from  ben_dsgn_rqmt_rlshp_typ drt
              where drt.dsgn_rqmt_id = v_dsgn_rqmt_id
            )
          ) ;


  l_tot_elig_dpnt            number(15);
  l_tot_rqmt_allow           varchar2(30) ;
  l_ttl_max_num               number(15);
  l_ttl_no_max_flag           varchar2(30);
  l_grp_rlshp_cd              ben_dsgn_rqmt_f.grp_rlshp_cd%type ;
  l_epe_dpnt_rec              c_epe_dpnt%rowtype;
  l_proc      varchar2(80) := g_package||'reinstate_dpnt';
  l_rslt_id      number;
  l_pil_id       number;
  l_dsgn_rqmt_id number;
  l_object_version_number number;
  l_eff_start_date date;
  l_eff_end_date date;
  l_elig_cvrd_dpnt_id         ben_elig_cvrd_dpnt_f.elig_cvrd_dpnt_id%TYPE;

  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('program : '||p_pgm_id,745);
    hr_utility.set_location('plan : '   ||p_pl_id,745);
    hr_utility.set_location('option : ' ||p_oipl_id,745);
    hr_utility.set_location('p_elig_per_elctbl_chc_id : '   ||p_elig_per_elctbl_chc_id,745);
    hr_utility.set_location('eff date : ' ||p_effective_date,745 );

    ---- Pl ty and opt id is determined for pl type and opt validation # 2508745
    open c_pl_typ ;
    fetch  c_pl_typ into l_pl_typ_id ;
    close  c_pl_typ ;

    open c_opt ;
    fetch c_opt into l_opt_id ;
    close c_opt ;

    hr_utility.set_location('option : ' ||l_opt_id,745);
    hr_utility.set_location('pl type : ' ||l_pl_typ_id,745);

    if  p_prev_prtt_enrt_rslt_id is not null  then

           l_rslt_id := p_prev_prtt_enrt_rslt_id ;
           hr_utility.set_location('p_prev_prtt_enrt_rslt_id   after result',745 );
           open   c_previous_result_id_result ;
           fetch  c_previous_result_id_result into l_old_cvg_strt_dt ,l_pil_id;
           if c_previous_result_id_result%notfound then
              hr_utility.set_location('0  null : '||l_proc,745);
           end if ;
           close  c_previous_result_id_result;

       else

          if p_pgm_id is not null then
             if p_oipl_id is not null then
                open c_previous_ptip_oipl_result;
                fetch c_previous_ptip_oipl_result into l_rslt_id,l_old_cvg_strt_dt ,l_pil_id;
                if c_previous_ptip_oipl_result%notfound then null;
                   hr_utility.set_location('1  null : '||l_proc,745);
                end if;
                close c_previous_ptip_oipl_result;
                hr_utility.set_location('1  : '||l_proc,745);

             else
                open c_previous_pgm_ptip_result;
                fetch c_previous_pgm_ptip_result into l_rslt_id,l_old_cvg_strt_dt ,l_pil_id;
                if c_previous_pgm_ptip_result%notfound then null;
                end if;
                close c_previous_pgm_ptip_result;
                hr_utility.set_location('2  : '||l_proc,745);
             end if;
          else

             if p_oipl_id is not null then
                open c_previous_pl_oipl_result;
                fetch c_previous_pl_oipl_result into l_rslt_id,l_old_cvg_strt_dt ,l_pil_id;
                if c_previous_pl_oipl_result%notfound then null;
                   hr_utility.set_location('3  null : '||l_proc,745);
                end if;
                close c_previous_pl_oipl_result;
                hr_utility.set_location('3  : '||l_proc,745);
             elsif p_oipl_id is null then
                open c_previous_pl_result;
                fetch c_previous_pl_result into l_rslt_id,l_old_cvg_strt_dt ,l_pil_id;
                if c_previous_pl_result%notfound then null;
                   hr_utility.set_location('4 nul  : '||l_proc,745);
                end if;
                   close c_previous_pl_result;
                hr_utility.set_location('4  : '||l_proc,745);
                end if;
             end if;
          end if ;  --- p_prev_prtt_enrt_rslt_id

          if l_rslt_id is not null and l_pil_id is not null then

             hr_utility.set_location('Reinstating dependent person id',99);
             hr_utility.set_location('pil id '|| l_pil_id ,99);
             hr_utility.set_location('rslt id '|| l_rslt_id ,99);
             hr_utility.set_location('cvg  start '|| l_old_cvg_strt_dt ,99);

             --- # 2623034  Find out the maximum  required dpnt
             --- Validate every groep of relation match with

             l_tot_rqmt_allow  := 'Y' ;

             open c_total_rqmt;
             Loop
                fetch c_total_rqmt into l_ttl_max_num, l_ttl_no_max_flag,l_dsgn_rqmt_id,l_grp_rlshp_cd;
                if c_total_rqmt%notfound then
                   exit ;
                end if;
                hr_utility.set_location(' grp_rlshp_cd ' || l_grp_rlshp_cd, 99 );
                hr_utility.set_location(' l_dsgn_rqmt_id ' || l_dsgn_rqmt_id, 99 );
                hr_utility.set_location(' ttl_no_max_flag ' || l_ttl_no_max_flag, 99 );
                hr_utility.set_location(' ttl_max_num ' || l_ttl_max_num, 99 );
                l_tot_elig_dpnt  :=   0 ;
                open c_tot_elig_dpnt (l_pil_id,l_rslt_id,l_dsgn_rqmt_id,l_grp_rlshp_cd) ;
                fetch c_tot_elig_dpnt into l_tot_elig_dpnt ;
                close c_tot_elig_dpnt ;
                hr_utility.set_location(' total eligible ' || l_tot_elig_dpnt, 99 );
                if l_ttl_no_max_flag = 'N' and
                   nvl(l_tot_elig_dpnt,0)   > l_ttl_max_num then
                   l_tot_rqmt_allow  := 'N' ;
                   -- exit ;
                end if ;
             End loop  ;
             close c_total_rqmt ;
             hr_utility.set_location(' l_tot_rqmt_allow ' || l_tot_rqmt_allow, 99 );


            if l_tot_rqmt_allow  = 'Y' then
               -- Create the dependents row.
               for l_prev_pen_dpnts in c_prev_pen_dpnts(l_rslt_id,l_pil_id) loop
                   --
                   hr_utility.set_location('Reinstating dependent in loop ',99);
                   hr_utility.set_location('p_dpnt_cvg_strt_dt_cd '|| p_dpnt_cvg_strt_dt_cd,99);
                   if p_dpnt_cvg_strt_dt_cd is null then
                      --
                      fnd_message.set_name('BEN','BEN_92558_DPNT_CVG_CD');
                      fnd_message.raise_error;
                      --
                   end if;
                   --
                   -- Calculate Dependents Coverage Start Date
                   --
                   ben_determine_date.main
                      (p_date_cd                 => p_dpnt_cvg_strt_dt_cd
                      ,p_per_in_ler_id           => null
                      ,p_person_id               => null
                      ,p_pgm_id                  => null
                      ,p_pl_id                   => null
                      ,p_oipl_id                 => null
                      ,p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id
                      ,p_business_group_id       => p_business_group_id
                      ,p_formula_id              => p_dpnt_cvg_strt_dt_rl
                      ,p_effective_date          => p_effective_date
                      ,p_returned_date           => l_cvg_strt_dt);

                   if l_cvg_strt_dt < p_enrt_cvg_strt_dt then
                      l_cvg_strt_dt := p_enrt_cvg_strt_dt;
                   end if;
                   hr_utility.set_location('Cvg start dt ='||to_char(l_cvg_strt_dt), 25);
                   --hook the depenedent to the new enrollment result.
                   open c_epe_dpnt(p_elig_per_elctbl_chc_id,l_prev_pen_dpnts.dpnt_person_id);
                   fetch c_epe_dpnt into l_epe_dpnt_rec;
                   if c_epe_dpnt%notfound then
                      null;
                   else
                      ben_ELIG_DPNT_api.process_dependent(
                         p_elig_dpnt_id          => l_epe_dpnt_rec.elig_dpnt_id,
                         p_business_group_id     => p_business_group_id,
                         p_effective_date        => p_effective_date,
                         p_cvg_strt_dt           => l_cvg_strt_dt,
                         p_cvg_thru_dt           => hr_api.g_eot,
                         p_datetrack_mode        => hr_api.g_insert,
                         p_elig_cvrd_dpnt_id     => l_elig_cvrd_dpnt_id,
                         p_effective_start_date  => l_eff_start_date,
                         p_effective_end_date    => l_eff_end_date,
                         p_object_version_number => l_object_version_number,
                           p_multi_row_actn        => TRUE );
                   end if;
                   close c_epe_dpnt;
               end loop;
            End if  ;
      end if;
      --
      hr_utility.set_location('Leaving: '||l_proc,10);
      --
  end reinstate_dpnt;
--
  ----------------------------------------------------------------------------------------
  --                          reinstate_prvdd_ctfn_items                                --
  ----------------------------------------------------------------------------------------
-- 6057157: During carry-forward of suspended elections, if any certifications were provided
--in future for the past pil, then those certifications are provided again in this new pil.
--
--1. We store certifications provided on a future date for the prev.pil
--   in backup table with backup table type code as BEN_PRTT_ENRT_CTFN_PRVDD_F_UPD
--2. In this procedure we pick up all such records and update
--   the ben_prtt_enrt_ctfn_prvdd_f table with the Certification Provided Date.
--
  procedure reinstate_prvdd_ctfn_items (p_prtt_enrt_rslt_id in number
                                      ,p_per_in_ler_id in number
                                      ,p_business_group_id in number
                                      ,p_effective_date date) is

    cursor c_prvdd_ctfns_past_pil is
    select lcr.bkup_tbl_id                 PREV_PRTT_ENRT_CTFN_PRVDD_ID,
           lcr.effective_start_date,
           lcr.effective_end_date,
           lcr.prtt_is_cvrd_flag           ENRT_CTFN_RQD_FLAG,
           lcr.comp_lvl_cd                 ENRT_CTFN_TYP_CD,
           lcr.enrt_cvg_thru_dt            ENRT_CTFN_RECD_DT,
           lcr.prtt_enrt_rslt_id           PREV_PRTT_ENRT_RSLT_ID,
           lcr.pgm_id                      PREV_PRTT_ENRT_ACTN_ID,
           lcr.enrt_ovrid_thru_dt          ENRT_CTFN_DND_DT,
           lcr.bnft_typ_cd                 ENRT_R_BNFT_CTFN_CD,
           pcs.prtt_enrt_ctfn_prvdd_id,
           pcs.object_version_number,
           pcs.prtt_enrt_actn_id
      from ben_le_clsn_n_rstr lcr
           ,ben_prtt_enrt_ctfn_prvdd_f pcs
     where lcr.per_in_ler_ended_id = p_per_in_ler_id
       and lcr.bkup_tbl_typ_cd = 'BEN_PRTT_ENRT_CTFN_PRVDD_F_UPD'
       and pcs.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and pcs.effective_end_date = hr_api.g_eot
       and pcs.enrt_ctfn_recd_dt is null
       and pcs.enrt_ctfn_typ_cd = lcr.comp_lvl_cd
       and exists (select 'x' -- To confirm if both PENs are for the same comp.object
                     from ben_prtt_enrt_rslt_f pen_lcr
                         ,ben_prtt_enrt_rslt_f pen_pcs
                    where pen_lcr.prtt_enrt_rslt_id = lcr.prtt_enrt_rslt_id
                      and pen_pcs.prtt_enrt_rslt_id = pcs.prtt_enrt_rslt_id
                      and nvl(pen_lcr.pgm_id,-1) = nvl(pen_pcs.pgm_id,-1)
                      and pen_lcr.pl_id = pen_pcs.pl_id
                      and nvl(pen_lcr.oipl_id, -1) = nvl(pen_pcs.oipl_id, -1)
                   )
       ;

       l_esd date;
       l_eed date;
       l_datetrack_mode varchar2(30);
       l_effective_date date;
    --
  begin
    --
    l_effective_date := p_effective_date;
    if (g_debug) then
        hr_utility.set_location('Entering reinstate_prvdd_ctfn_items ', 10);
    end if;
    --
    for l_prvdd_ctfns in c_prvdd_ctfns_past_pil
    loop
        --
        if (g_debug) then
            hr_utility.set_location('l_effective_date ' || l_effective_date, 10);
            hr_utility.set_location('l_prvdd_ctfns.effective_start_date ' || l_prvdd_ctfns.effective_start_date, 10);
            hr_utility.set_location('l_prvdd_ctfns.effective_end_date ' || l_prvdd_ctfns.effective_end_date, 10);
            hr_utility.set_location('l_prvdd_ctfns.prtt_enrt_actn_id ' || l_prvdd_ctfns.prtt_enrt_actn_id, 10);
            hr_utility.set_location('l_prvdd_ctfns.prev_prtt_enrt_actn_id ' || l_prvdd_ctfns.prev_prtt_enrt_actn_id, 10);
            hr_utility.set_location('l_prvdd_ctfns.prtt_enrt_ctfn_prvdd_id' || l_prvdd_ctfns.prtt_enrt_ctfn_prvdd_id, 10);
            hr_utility.set_location('l_prvdd_ctfns.enrt_ctfn_recd_dt' || l_prvdd_ctfns.enrt_ctfn_recd_dt, 10);
            hr_utility.set_location('l_prvdd_ctfns.ENRT_CTFN_TYP_CD' || l_prvdd_ctfns.ENRT_CTFN_TYP_CD, 10);
        end if;
        --
        if (l_effective_date > l_prvdd_ctfns.effective_start_date) then
            l_datetrack_mode := hr_api.g_update;
        else
            l_effective_date := GREATEST(l_effective_date, l_prvdd_ctfns.effective_start_date);
            l_datetrack_mode := hr_api.g_correction;
        end if;
        --
        ben_prtt_enrt_ctfn_prvdd_api.update_prtt_enrt_ctfn_prvdd
            (p_prtt_enrt_ctfn_prvdd_id        => l_prvdd_ctfns.prtt_enrt_ctfn_prvdd_id
            ,p_effective_start_date           => l_esd
            ,p_effective_end_date             => l_eed
            ,p_prtt_enrt_actn_id              => l_prvdd_ctfns.prtt_enrt_actn_id
            ,p_enrt_ctfn_recd_dt              => l_prvdd_ctfns.enrt_ctfn_recd_dt
            ,p_object_version_number          => l_prvdd_ctfns.object_version_number
            ,p_effective_date                 => l_effective_date
            ,p_business_group_id              => p_business_group_id
            ,p_datetrack_mode                 => l_datetrack_mode);
        --
    end loop;
    --
  end reinstate_prvdd_ctfn_items;


  procedure process_person(p_person_id         in number,
                           p_business_group_id in number,
                           p_per_in_ler_id     in number,
                           p_ler_id            in number,
                           p_effective_date    in date) is
    --
    cursor c_pil is
    select pil.lf_evt_ocrd_dt
    from ben_per_in_ler pil
    where pil.per_in_ler_id = p_per_in_ler_id ;
    --
    l_lf_evt_ocrd_dt date;
    --
    cursor c_prtt_result(v_prtt_enrt_rslt_id number,
                         p_effective_date date) is
      select pen.prtt_enrt_rslt_id,
             pen.effective_start_date,
             pen.effective_end_date,
             pen.object_version_number,
             pen.bnft_amt,
             pen.uom,
             pen.enrt_mthd_cd,
             pen.business_group_id,
             pen.enrt_cvg_strt_dt,
             pen.enrt_cvg_thru_dt,
              pen.pen_attribute_category ,
              pen.pen_attribute1 ,
	      pen.pen_attribute2 ,
	      pen.pen_attribute3 ,
	      pen.pen_attribute4 ,
	      pen.pen_attribute5 ,
	      pen.pen_attribute6 ,
	      pen.pen_attribute7 ,
	      pen.pen_attribute8 ,
	      pen.pen_attribute9 ,
	      pen.pen_attribute10 ,
	      pen.pen_attribute11 ,
	      pen.pen_attribute12 ,
	      pen.pen_attribute13 ,
	      pen.pen_attribute14 ,
	      pen.pen_attribute15 ,
	      pen.pen_attribute16 ,
	      pen.pen_attribute17 ,
	      pen.pen_attribute18 ,
	      pen.pen_attribute19 ,
	      pen.pen_attribute20 ,
	      pen.pen_attribute21 ,
	      pen.pen_attribute22,
	      pen.pen_attribute23,
	      pen.pen_attribute24,
	      pen.pen_attribute25,
	      pen.pen_attribute26,
	      pen.pen_attribute27,
	      pen.pen_attribute28,
	      pen.pen_attribute29,
              pen.pen_attribute30,
              pen.bnft_ordr_num,
              pen.rplcs_sspndd_rslt_id
      from   ben_prtt_enrt_rslt_f pen
      where  pen.prtt_enrt_rslt_id = v_prtt_enrt_rslt_id
/*        5741760: PEN in future, can also be carried-fwd.
      and    p_effective_date between
             pen.effective_start_date and pen.effective_end_date
*/    and    p_effective_date <= pen.effective_end_date
      AND    pen.prtt_enrt_rslt_stat_cd is null
      and    pen.business_group_id = p_business_group_id
      order by pen.effective_start_date desc;
    --
    l_prtt_result c_prtt_result%rowtype;
    -- Bug 5102337 several changes in this cursor
    -- a. for handling ben_enrt_bnft and b. future completed certifications
    cursor c_choice_info is
      select pil.object_version_number,
             epe.elig_per_elctbl_chc_id,
             pel.enrt_typ_cycl_cd,
             epe.enrt_cvg_strt_dt_cd,
             pel.enrt_perd_end_dt,
             pel.enrt_perd_strt_dt,
             epe.enrt_cvg_strt_dt_rl,
             epe.enrt_cvg_strt_dt,
             to_date('31-12-4712','DD-MM-YYYY') enrt_cvg_end_dt,
             nvl(enb.crntly_enrld_flag,epe.crntly_enrd_flag) crntly_enrd_flag,
             epe.dflt_flag,
             epe.elctbl_flag,
             epe.mndtry_flag,
             pel.dflt_enrt_dt,
             epe.dpnt_cvg_strt_dt_cd,
             epe.dpnt_cvg_strt_dt_rl,
             epe.alws_dpnt_dsgn_flag,
             epe.dpnt_dsgn_cd,
             epe.ler_chg_dpnt_cvg_cd,
             epe.erlst_deenrt_dt,
             epe.procg_end_dt,
             epe.comp_lvl_cd,
             epe.pl_id,
             epe.oipl_id,
             epe.pgm_id,
             epe.plip_id,
             epe.ptip_id,
             epe.pl_typ_id,
             epe.cmbn_ptip_id,
             epe.cmbn_ptip_opt_id,
             epe.spcl_rt_pl_id,
             epe.spcl_rt_oipl_id,
             epe.must_enrl_anthr_pl_id,
             nvl(enb.prtt_enrt_rslt_id,epe.prtt_enrt_rslt_id) prtt_enrt_rslt_id ,
             epe.bnft_prvdr_pool_id,
             epe.per_in_ler_id,
             epe.yr_perd_id,
             epe.business_group_id,
             'N' stage,
             'N' suspended,
             epe.cryfwd_elig_dpnt_cd
      from   ben_elig_per_elctbl_chc epe,
             ben_enrt_bnft enb,
             ben_per_in_ler pil,
             ben_pil_elctbl_chc_popl pel
      where  NVL(enb.crntly_enrld_flag(+),epe.crntly_enrd_flag) = 'Y'
      and    pil.person_id = p_person_id
      and    pil.per_in_ler_id = p_per_in_ler_id
      and    epe.per_in_ler_id = pil.per_in_ler_id
      and    pel.per_in_ler_id = epe.per_in_ler_id
      and    pil.per_in_ler_stat_cd IN ('STRTD' ,'PROCD') -- 6156874
      --Bug 5617091 for recalc it is set to PROCD before this call
      and    pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
      and    enb.elig_per_elctbl_chc_id (+) = epe.elig_per_elctbl_chc_id
      and    epe.prtt_enrt_rslt_id is NOT NULL
      and not exists (select null
                             from   ben_prtt_enrt_rslt_f pen
                             where  pen.pl_id = epe.pl_id
                             and    pen.prtt_enrt_rslt_stat_cd IS NULL
                             and    pen.per_in_ler_id = epe.per_in_ler_id
                              /* Added the below condition and commented the code for Bug 7426609 */
			     and    pen.per_in_ler_id=p_per_in_ler_id
                             /*and    pen.prtt_enrt_rslt_id = NVL(enb.prtt_enrt_rslt_id,
                                                             epe.prtt_enrt_rslt_id)*/
                             and    pen.enrt_cvg_thru_dt = hr_api.g_eot
                             and    pen.effective_end_date = hr_api.g_eot)
      and exists (select null
                             from   ben_prtt_enrt_rslt_f pen
                             where  pen.pl_id = epe.pl_id
                             and    pen.prtt_enrt_rslt_stat_cd IS NULL
                             and    pen.per_in_ler_id <> epe.per_in_ler_id
                             and    pen.prtt_enrt_rslt_id = NVL(enb.prtt_enrt_rslt_id,
                                                             epe.prtt_enrt_rslt_id)
                             and    pen.sspndd_flag = 'Y'
                             and    pen.enrt_cvg_thru_dt = hr_api.g_eot
--                             and    pen.effective_end_date = hr_api.g_eot -- 6156874
                             and    pen.effective_end_date >= l_lf_evt_ocrd_dt )
      order by epe.pgm_id, epe.pl_id;
    --
    l_choice_info c_choice_info%rowtype;
    --
    cursor c_elctbl_epe is
      select null
      from   ben_elig_per_elctbl_chc epe,
             ben_per_in_ler pil,
             ben_pil_elctbl_chc_popl pel
      where  epe.elctbl_flag = 'Y'
      --and    pil.business_group_id = p_business_group_id
      --and    epe.business_group_id = pil.business_group_id
      --and    pel.business_group_id = epe.business_group_id
      and    pil.person_id = p_person_id
      and    epe.per_in_ler_id = pil.per_in_ler_id
      and    pel.per_in_ler_id = epe.per_in_ler_id
      and    pil.per_in_ler_stat_cd = 'STRTD'
      and    pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
      and    (epe.pgm_id is not null
              and not exists(select null
                             from   ben_prtt_enrt_rslt_f pen
                             where  pen.pgm_id = epe.pgm_id
                             and    pen.per_in_ler_id = epe.per_in_ler_id
                             and    pen.enrt_cvg_thru_dt = hr_api.g_eot
                             and    pen.effective_end_date = hr_api.g_eot)
              or epe.pl_id is not null
              and not exists(select null
                             from   ben_prtt_enrt_rslt_f pen
                             where  pen.pl_id = epe.pl_id
                             and    pen.per_in_ler_id = epe.per_in_ler_id
                             and    pen.enrt_cvg_thru_dt = hr_api.g_eot
                             and    pen.effective_end_date = hr_api.g_eot));
    --
    cursor c_pgm_enrt_dt(v_elig_per_elctbl_chc_id number,v_pgm_id number) is
      select pel.enrt_perd_strt_dt
      from ben_pil_elctbl_chc_popl pel,ben_elig_per_elctbl_chc epe
      where pel.pgm_id = v_pgm_id
      and   pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
      and   epe.elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id;

    l_pgm_enrt_dt c_pgm_enrt_dt%rowtype;

    cursor c_pl_enrt_dt(v_elig_per_elctbl_chc_id number,v_pl_id number) is
      select pel.enrt_perd_strt_dt
      from ben_pil_elctbl_chc_popl pel,ben_elig_per_elctbl_chc epe
      where pel.pl_id = v_pl_id
      and   pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
      and   epe.elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id;

    l_pl_enrt_dt c_pl_enrt_dt%rowtype;

    cursor c_bnft(v_elig_per_elctbl_chc_id number, v_bnft_ordr_num number ) is
      select enb.enrt_bnft_id,
             decode(enb.entr_val_at_enrt_flag,'Y',enb.dflt_val,enb.val) val,
             enb.dflt_flag,
             enb.prtt_enrt_rslt_id,
             enb.cvg_mlt_cd,
             enb.crntly_enrld_flag
      from   ben_enrt_bnft enb
      where  enb.elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id
       and   enb.crntly_enrld_flag = 'Y'
       and   enb.prtt_enrt_rslt_id is not NULL
       and   enb.ordr_num = v_bnft_ordr_num
      ;
    --
    /* REMOVED UNUSED CODE HERE */
    --
    l_pgm_id number;
    l_pl_id number;
    l_pil_id number;
    l_oipl_id number;
    -- l_lf_evt_ocrd_dt date;
    l_bnft c_bnft%rowtype;
    l_bnft_reset c_bnft%rowtype; -- BBULUSU CODE
    l_dflt_bnft c_bnft%rowtype;
    l_dflt_found boolean;
    l_per_in_ler_id number := p_per_in_ler_id ;
    --
    cursor c_rt(v_elig_per_elctbl_chc_id number,
                v_enrt_bnft_id           number) is
      select ecr.enrt_rt_id,
             nvl(ecr.val,ecr.dflt_val) default_value,
             nvl(ecr.ann_dflt_val,ecr.ann_val) ann_rt_val,
             ecr.prtt_rt_val_id
      from   ben_enrt_rt ecr
      where  ecr.elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id
      and    ecr.business_group_id = p_business_group_id
      and    ecr.entr_val_at_enrt_flag = 'Y'
      and    ecr.spcl_rt_enrt_rt_id is null
      union
      select ecr.enrt_rt_id,
             nvl(ecr.val,ecr.dflt_val) default_value,
             nvl(ecr.ann_dflt_val,ecr.ann_val) ann_rt_val,
             ecr.prtt_rt_val_id
      from   ben_enrt_rt ecr
      where  ecr.enrt_bnft_id = v_enrt_bnft_id
      and    ecr.business_group_id = p_business_group_id
      and    ecr.entr_val_at_enrt_flag = 'Y'
      and    ecr.spcl_rt_enrt_rt_id is null
      ;
    --
    l_rt c_rt%rowtype;
    --
    cursor c_prv(p_prtt_enrt_rslt_id number, p_per_in_ler_id number) is
    select prv.*
      from ben_prtt_rt_val prv
     where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and prv.per_in_ler_id = p_per_in_ler_id
       and prv.prtt_rt_val_stat_cd is NULL ;
    --
    cursor c_ecr(p_prtt_rt_val_id number) is
    select ecr.rt_strt_dt,
           ecr.rt_strt_dt_cd,
           ecr.rt_strt_dt_rl,
           nvl(ecr.elig_per_elctbl_chc_id,enb.elig_per_elctbl_chc_id) elig_per_elctbl_chc_id
     from ben_enrt_rt ecr,
          ben_enrt_bnft enb
    where ecr.prtt_rt_val_id = p_prtt_rt_val_id
      and ecr.enrt_bnft_id = enb.enrt_bnft_id (+) ;
    --
    l_ecr   c_ecr%rowtype;
    --
    l_cvg_strt_dt                 date;

    type g_rt_rec is record
      (enrt_rt_id ben_enrt_rt.enrt_rt_id%type,
       dflt_val   ben_enrt_rt.dflt_val%type,
       prtt_rt_val_id ben_enrt_rt.prtt_rt_val_id%type,
       ann_rt_val ben_enrt_rt.ann_val%type);
    --
    type g_rt_table is table of g_rt_rec index by binary_integer;
    --
    l_rt_table g_rt_table;
    --
    type g_pen_id_table is table of number index by binary_integer;
    l_crd_fwd_pen_id g_pen_id_table;
    l_pen_count number;
    --

    -- Local Variables
    --
    l_proc      varchar2(80) := g_package||'process_person';
    l_dpnt_actn_warning boolean;
    l_bnf_actn_warning  boolean;
    l_ctfn_actn_warning boolean;
    l_new_election boolean := false;
    l_datetrack_mode varchar2(30);
    l_prev_pgm_id number := -99999;
    l_prtt_enrt_interim_id number;
    l_rslt_id  number;
    l_count number;
    l_object_version_number number;
    l_ovn_intr number;
    l_suspend_flag varchar2(30);
    l_dummy varchar2(30);
    l_person_susp varchar2(30) := 'N';
    l_cls_enrt_flag boolean := true;
    l_effective_start_date date;
    l_effective_end_date date;
    l_eff_start_date date;
    l_eff_end_date date;
    l_effective_dt date;
    l_prev_eff_dt date;
    l_elig_cvrd_dpnt_id         ben_elig_cvrd_dpnt_f.elig_cvrd_dpnt_id%TYPE;

    l_rec                   ben_env_object.g_global_env_rec_type;
    l_cryfwd_elig_dpnt_cd    varchar2(30) ;
    l_prev_rslt_id_at        number := 0  ;
    l_prev_prtt_enrt_rslt_id number ;
    l_prtt_enrt_rslt_id number ;
    l_bnft_amt          number;

    l_rdefault_table_cnt number;
    --
  begin
    --
    g_debug := hr_utility.debug_enabled;
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    -- ben_env_object.get(p_rec => l_rec);
    --
    hr_utility.set_location('Effective date: '||p_effective_date,10);
    --
    ben_sspndd_enrollment.g_cfw_flag := 'Y';
    --
    l_pen_count := 0;
    l_crd_fwd_pen_id.delete;
    --
    open c_pil ;
      fetch c_pil into l_lf_evt_ocrd_dt;
    close c_pil ;
    --
    open c_choice_info;
      --
      loop
        --
        l_bnft := l_bnft_reset; -- BBULUSU CODE
        --
        fetch c_choice_info into l_choice_info;
        --
        hr_utility.set_location('cvg strt cd: '||l_choice_info.dpnt_cvg_strt_dt_cd,10);
        hr_utility.set_location('epe id  : '||l_choice_info.elig_per_elctbl_chc_id,10);
        --
        exit when c_choice_info%notfound;
        --
        -- Get participant enrollment result information

         hr_utility.set_location('cvg strt cd: '||l_choice_info.dpnt_cvg_strt_dt_cd,10);
         hr_utility.set_location('epe id  : '||l_choice_info.elig_per_elctbl_chc_id,10);
        --
        if l_choice_info.crntly_enrd_flag = 'Y' then
          --
          open c_prtt_result(l_choice_info.prtt_enrt_rslt_id,
                             p_effective_date);
            --
            fetch c_prtt_result into l_prtt_result;
            if c_prtt_result%notfound then
              --
              close c_prtt_result;
              fnd_message.set_name('BEN','BEN_91711_ENRT_RSLT_NOT_FOUND');
              fnd_message.set_token('PROC',l_proc);
              fnd_message.set_token('ID',l_choice_info.prtt_enrt_rslt_id);
              fnd_message.set_token('PERSON_ID',to_char(p_person_id));
              fnd_message.set_token('LER_ID',to_char(p_ler_id));
              fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
              fnd_message.raise_error;
              --
            end if;
            --
          close c_prtt_result;
          --
          l_new_election := false;
          l_datetrack_mode := hr_api.g_update;
          l_choice_info.stage := 'N';
          --
        else
          --
          --Never goes here
          --
          l_new_election := true;
          l_datetrack_mode := hr_api.g_insert;
          l_choice_info.stage := 'Y';
          --
        end if;
        --
        -- Get benefit information
        --
        l_dflt_found:=false;
        hr_utility.set_location(l_proc,20);
        open c_bnft(l_choice_info.elig_per_elctbl_chc_id, l_prtt_result.bnft_ordr_num );
        fetch c_bnft into l_bnft;
        close c_bnft;
        --
        /*
        loop
          hr_utility.set_location(l_proc,30);
          --
          fetch c_bnft into l_bnft;
          --
          exit when c_bnft%notfound;
          hr_utility.set_location(l_proc,40);
          if l_bnft.dflt_flag='Y' then
            hr_utility.set_location(l_proc,50);
            l_dflt_bnft:=l_bnft;
            l_dflt_found:=true;
          end if;
          hr_utility.set_location(l_proc,60);
        end loop;
        hr_utility.set_location(l_proc,70);
        close c_bnft;
        */
        --
        hr_utility.set_location(l_proc||l_bnft.val,90);
        hr_utility.set_location('ENB ID'||l_bnft.enrt_bnft_id,90);
        --
        -- Get Rate information
        --
        for l_count in 1..10 loop
          --
          -- Initialise array to null
          --
          l_rt_table(l_count).enrt_rt_id := null;
          l_rt_table(l_count).dflt_val := null;
          l_rt_table(l_count).prtt_rt_val_id:=null;
          --
        end loop;
        --
        l_count:= 0;
        --
        for l_rec in c_rt(l_choice_info.elig_per_elctbl_chc_id,
                          l_bnft.enrt_bnft_id) loop
          --
          l_count := l_count+1;
          l_rt_table(l_count).enrt_rt_id := l_rec.enrt_rt_id;
          l_rt_table(l_count).dflt_val := l_rec.default_value;
          l_rt_table(l_count).prtt_rt_val_id:=l_rec.prtt_rt_val_id;
          --
        end loop;
        --
        l_suspend_flag := 'N';
        --
        -- Call election information batch process
        --
        if l_choice_info.pgm_id is not null then
          open c_pgm_enrt_dt(l_choice_info.elig_per_elctbl_chc_id,
                             l_choice_info.pgm_id);
          fetch c_pgm_enrt_dt into l_pgm_enrt_dt;
          -- if l_pgm_enrt_dt.enrt_perd_strt_dt < p_effective_date then
          -- 5741760: Create/Update enrollments as of first day of enrt_perd_strt_dt
             l_effective_dt := l_pgm_enrt_dt.enrt_perd_strt_dt;
          -- else
             --l_effective_dt := p_effective_date;
          --end if;
          close c_pgm_enrt_dt;
        elsif l_choice_info.pl_id is not null then
          open c_pl_enrt_dt(l_choice_info.elig_per_elctbl_chc_id,
                             l_choice_info.pl_id);
          fetch c_pl_enrt_dt into l_pl_enrt_dt;
          --if l_pl_enrt_dt.enrt_perd_strt_dt < p_effective_date then
          -- 5741760: Create/Update enrollments as of first day of enrt_perd_strt_dt
             l_effective_dt := l_pl_enrt_dt.enrt_perd_strt_dt;
          --else
            -- l_effective_dt := p_effective_date;
          --end if;
          close c_pl_enrt_dt;
        end if;
        --
        hr_utility.set_location('cvg_mlt_cd='||l_bnft.cvg_mlt_cd,13);
        hr_utility.set_location('bnft_val='||l_bnft.val,13);
        hr_utility.set_location('rate_val='||l_rt_table(1).dflt_val,13);
        hr_utility.set_location('ann_rt_val='||l_rt_table(1).ann_rt_val,13);
        --
        if l_bnft.cvg_mlt_cd='SAAEAR' and
           l_rt_table(1).ann_rt_val is null then
          l_rt_table(1).ann_rt_val:=l_rt_table(1).dflt_val;
        end if;
        --
        l_prtt_enrt_rslt_id := nvl(l_bnft.prtt_enrt_rslt_id,l_choice_info.prtt_enrt_rslt_id);
        --bug#4299428 - benefit amount on enrt bnft passed if calculation is like
        -- compensation
        if instr(l_bnft.cvg_mlt_cd,'CL') <> 0 then
          --
          l_bnft_amt := l_bnft.val;
          --
        else
          --
          l_bnft_amt := NVL(l_prtt_result.bnft_amt,l_bnft.val) ;
          --
        end if;
        --
        --Bug 6519487 when the enrollment is carried forward, we don't want to
        --mark additional plans as default. Resetting all other plans back to
        --'N' so that user won't get into a situation of default one plan from
        --defaulting rules and another plan from carry forward functionality.
        --When carrying forward enrollment, remove defaults for all other
        -- plans/options in that plan type.
        --Need to be changed with API at a later date.
        --
        update ben_elig_per_elctbl_chc
           set dflt_flag = 'N'
         where pl_typ_id = l_choice_info.pl_typ_id
           and elig_per_elctbl_chc_id <> l_choice_info.elig_per_elctbl_chc_id
	   and crntly_enrd_flag = 'N' -- Bug 7378468
           and dflt_flag = 'Y'
           and nvl(pgm_id,-1)= nvl(l_choice_info.pgm_id,-1)
           and per_in_ler_id = p_per_in_ler_id ;

        --
        --END Bug 6519487
        --
        --Bug 4450214 Moved to the begining of the code
        -- ben_sspndd_enrollment.g_cfw_flag := 'Y';
        --

	/* Added for Enhancement Bug 8716679
	   To add the electable choices to pl/sql table that are carry forwarded. This pl/sql
	   is scanned to check whether the enrollment record is already carry forwarded by the carry foward logic
	   while defaulting and reinstating the explicit elections from intervening LE  */
	hr_utility.set_location ('Carry Fwd epe '||l_choice_info.elig_per_elctbl_chc_id,199);
	l_rdefault_table_cnt := nvl( ben_lf_evt_clps_restore.g_reinstated_defaults.LAST, 0) + 1;
        ben_lf_evt_clps_restore.g_reinstated_defaults(l_rdefault_table_cnt) := l_choice_info.elig_per_elctbl_chc_id;
	/* End of Enhancement Bug 8716679*/

        ben_election_information.election_information
          (p_elig_per_elctbl_chc_id => l_choice_info.elig_per_elctbl_chc_id,
           p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id, -- l_choice_info.prtt_enrt_rslt_id,
           p_effective_date         => l_effective_dt,
           p_enrt_mthd_cd           => 'E', --We are making as Explicit [??]
           p_business_group_id      => p_business_group_id,
           p_enrt_bnft_id           => l_bnft.enrt_bnft_id,
           p_bnft_val               => l_bnft_amt,
           p_enrt_rt_id1            => l_rt_table(1).enrt_rt_id,
           p_rt_val1                => l_rt_table(1).dflt_val,
           p_enrt_rt_id2            => l_rt_table(2).enrt_rt_id,
           p_rt_val2                => l_rt_table(2).dflt_val,
           p_enrt_rt_id3            => l_rt_table(3).enrt_rt_id,
           p_rt_val3                => l_rt_table(3).dflt_val,
           p_enrt_rt_id4            => l_rt_table(4).enrt_rt_id,
           p_rt_val4                => l_rt_table(4).dflt_val,
           p_enrt_rt_id5            => l_rt_table(5).enrt_rt_id,
           p_rt_val5                => l_rt_table(5).dflt_val,
           p_enrt_rt_id6            => l_rt_table(6).enrt_rt_id,
           p_rt_val6                => l_rt_table(6).dflt_val,
           p_enrt_rt_id7            => l_rt_table(7).enrt_rt_id,
           p_rt_val7                => l_rt_table(7).dflt_val,
           p_enrt_rt_id8            => l_rt_table(8).enrt_rt_id,
           p_rt_val8                => l_rt_table(8).dflt_val,
           p_enrt_rt_id9            => l_rt_table(9).enrt_rt_id,
           p_rt_val9                => l_rt_table(9).dflt_val,
           p_enrt_rt_id10           => l_rt_table(10).enrt_rt_id,
           p_rt_val10               => l_rt_table(10).dflt_val,
           p_datetrack_mode         => l_datetrack_mode,
           p_suspend_flag           => l_suspend_flag,
           p_prtt_enrt_interim_id   => l_prtt_enrt_interim_id,
           p_prtt_rt_val_id1        => l_rt_table(1).prtt_rt_val_id,
           p_prtt_rt_val_id2        => l_rt_table(2).prtt_rt_val_id,
           p_prtt_rt_val_id3        => l_rt_table(3).prtt_rt_val_id,
           p_prtt_rt_val_id4        => l_rt_table(4).prtt_rt_val_id,
           p_prtt_rt_val_id5        => l_rt_table(5).prtt_rt_val_id,
           p_prtt_rt_val_id6        => l_rt_table(6).prtt_rt_val_id,
           p_prtt_rt_val_id7        => l_rt_table(7).prtt_rt_val_id,
           p_prtt_rt_val_id8        => l_rt_table(8).prtt_rt_val_id,
           p_prtt_rt_val_id9        => l_rt_table(9).prtt_rt_val_id,
           p_prtt_rt_val_id10       => l_rt_table(10).prtt_rt_val_id,
           p_ann_rt_val1            => l_rt_table(1).ann_rt_val,
           p_ann_rt_val2            => l_rt_table(2).ann_rt_val,
           p_ann_rt_val3            => l_rt_table(3).ann_rt_val,
           p_ann_rt_val4            => l_rt_table(4).ann_rt_val,
           p_ann_rt_val5            => l_rt_table(5).ann_rt_val,
           p_ann_rt_val6            => l_rt_table(6).ann_rt_val,
           p_ann_rt_val7            => l_rt_table(7).ann_rt_val,
           p_ann_rt_val8            => l_rt_table(8).ann_rt_val,
           p_ann_rt_val9            => l_rt_table(9).ann_rt_val,
           p_ann_rt_val10           => l_rt_table(10).ann_rt_val,
           -- 3517682 start
            p_pen_attribute_category => l_prtt_result.pen_attribute_category ,
            p_pen_attribute1    => l_prtt_result.pen_attribute1 ,
            p_pen_attribute2    => l_prtt_result.pen_attribute2 ,
            p_pen_attribute3    => l_prtt_result.pen_attribute3 ,
            p_pen_attribute4    => l_prtt_result.pen_attribute4 ,
            p_pen_attribute5    => l_prtt_result.pen_attribute5 ,
            p_pen_attribute6    => l_prtt_result.pen_attribute6 ,
            p_pen_attribute7    => l_prtt_result.pen_attribute7 ,
            p_pen_attribute8    => l_prtt_result.pen_attribute8 ,
            p_pen_attribute9    => l_prtt_result.pen_attribute9 ,
            p_pen_attribute10   => l_prtt_result.pen_attribute10 ,
            p_pen_attribute11   => l_prtt_result.pen_attribute11 ,
            p_pen_attribute12   => l_prtt_result.pen_attribute12 ,
            p_pen_attribute13   => l_prtt_result.pen_attribute13 ,
            p_pen_attribute14   => l_prtt_result.pen_attribute14 ,
            p_pen_attribute15   => l_prtt_result.pen_attribute15 ,
            p_pen_attribute16   => l_prtt_result.pen_attribute16 ,
            p_pen_attribute17   => l_prtt_result.pen_attribute17 ,
            p_pen_attribute18   => l_prtt_result.pen_attribute18 ,
            p_pen_attribute19   => l_prtt_result.pen_attribute19 ,
            p_pen_attribute20   => l_prtt_result.pen_attribute20 ,
            p_pen_attribute21   => l_prtt_result.pen_attribute21 ,
            p_pen_attribute22   => l_prtt_result.pen_attribute22,
            p_pen_attribute23   => l_prtt_result.pen_attribute23,
            p_pen_attribute24   => l_prtt_result.pen_attribute24,
            p_pen_attribute25   => l_prtt_result.pen_attribute25,
            p_pen_attribute26   => l_prtt_result.pen_attribute26,
            p_pen_attribute27   => l_prtt_result.pen_attribute27,
            p_pen_attribute28   => l_prtt_result.pen_attribute28,
            p_pen_attribute29   => l_prtt_result.pen_attribute29,
            p_pen_attribute30   => l_prtt_result.pen_attribute30,
           -- 3517682 end
           p_object_version_number  => l_object_version_number,
           p_effective_start_date   => l_effective_start_date,
           p_effective_end_date     => l_effective_end_date,
           p_dpnt_actn_warning      => l_dpnt_actn_warning,
           p_bnf_actn_warning       => l_bnf_actn_warning,
           p_ctfn_actn_warning      => l_ctfn_actn_warning);
        --
        -- ben_sspndd_enrollment.g_cfw_flag := 'N';
        --
        l_choice_info.suspended := l_suspend_flag;
        --
        if l_choice_info.suspended = 'Y' then
          --
          l_person_susp := 'Y';
          l_choice_info.stage := 'S';
          --
        end if;
        --
        --
        l_pen_count := l_pen_count + 1;
        l_crd_fwd_pen_id(l_pen_count) := l_prtt_enrt_rslt_id;
        --
        --

        --
        -- update the default flag to N on the interim epe
        --
        /* Bug 5474065 : Updating the DFLT_FLAG prevents interim enrollment when interim
                         code has Current - Default
        update ben_elig_per_elctbl_chc
           set dflt_flag = 'N'
         where dflt_flag = 'Y'
           and per_in_ler_id = l_choice_info.per_in_ler_id
           and pl_id = l_choice_info.pl_id
           and oipl_id <> l_choice_info.oipl_id
           and nvl(pgm_id,-1) = nvl(l_choice_info.pgm_id,-1)
           and elig_per_elctbl_chc_id <> l_choice_info.elig_per_elctbl_chc_id;
        */
        /* It is not required to do carryforward since it is handled in beneadeb and benauten
        open c_prtt_result(l_prtt_enrt_rslt_id, --ML l_choice_info.prtt_enrt_rslt_id,
                             l_effective_dt);
          --
          fetch c_prtt_result into l_prtt_result;
          if c_prtt_result%notfound then
            --
            close c_prtt_result;
            fnd_message.set_name('BEN','BEN_91711_ENRT_RSLT_NOT_FOUND');
            fnd_message.set_token('PROC',l_proc);
            fnd_message.set_token('ID',l_prtt_enrt_rslt_id); -- l_choice_info.prtt_enrt_rslt_id);
            fnd_message.set_token('PERSON_ID',to_char(p_person_id));
            fnd_message.set_token('LER_ID',to_char(p_ler_id));
            fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
            fnd_message.raise_error;
            --
          else
            --
            l_choice_info.enrt_cvg_strt_dt := l_prtt_result.enrt_cvg_strt_dt;
            l_choice_info.enrt_cvg_end_dt := l_prtt_result.enrt_cvg_thru_dt;
            --
            -- after the enhncemnt # 2685018 cryfwd_elig_dpnt_cd value is concated with
            -- result id from where the dpnt carry forwarded , this will seprate the code from
            --- result id

            l_prev_prtt_enrt_rslt_id := null; -- Reintializing the previous enrt result id
            l_cryfwd_elig_dpnt_cd := l_choice_info.cryfwd_elig_dpnt_cd ;
            l_prev_rslt_id_at     := instr(l_cryfwd_elig_dpnt_cd, '^') ;
            --- if the  result id concated with the code, then  the caht '^' must be aprt of the
            --- the code

            if l_prev_rslt_id_at   > 0  then
               --- if the to_number errors , catch the exception
               Begin
                  l_prev_prtt_enrt_rslt_id := to_number(substr(l_cryfwd_elig_dpnt_cd,l_prev_rslt_id_at+1) );
               Exception
                  when value_error then
                       l_prev_prtt_enrt_rslt_id := null;
               End  ;

               l_cryfwd_elig_dpnt_cd    := substr(l_cryfwd_elig_dpnt_cd,1,l_prev_rslt_id_at-1) ;
               ---
            end if ;


            hr_utility.set_location('l_cryfwd_elig_dpnt_cd '||l_cryfwd_elig_dpnt_cd,744);
            hr_utility.set_location('l_prev_prtt_enrt_rslt_id '||l_prev_prtt_enrt_rslt_id,744);

            if l_datetrack_mode = hr_api.g_insert and l_cryfwd_elig_dpnt_cd  = 'CFRRWP' then

              hr_utility.set_location('cvg strt cd: '||l_choice_info.dpnt_cvg_strt_dt_cd,10);
              -- p_effective_date is now changed to l_effective_dt , when ever LE reprocessed
              -- result created as on effective date and automeatic enrollment called with
              -- lE_ocurd_Dt as affective date so there is no result as on effective date (le_ocrd_dt)
              -- this is fixed sending l_effective_dt # 3042033

              reinstate_dpnt(p_pgm_id               =>l_choice_info.pgm_id,
                             p_pl_id                => l_choice_info.pl_id,
                             p_oipl_id              => l_choice_info.oipl_id,
                             p_business_group_id    => p_business_group_id,
                             p_person_id            => p_person_id,
                             p_per_in_ler_id        => l_per_in_ler_id,
                             p_elig_per_elctbl_chc_id => l_choice_info.elig_per_elctbl_chc_id,
                             p_dpnt_cvg_strt_dt_cd    => l_choice_info.dpnt_cvg_strt_dt_cd,
                             p_dpnt_cvg_strt_dt_rl    => l_choice_info.dpnt_cvg_strt_dt_rl,
                             p_enrt_cvg_strt_dt       => l_choice_info.enrt_cvg_strt_dt,
                             p_effective_date         => l_effective_dt,
                             p_prev_prtt_enrt_rslt_id => l_prev_prtt_enrt_rslt_id
                            );
            end if;
          end if;
          --
        close c_prtt_result;
        --
        */
        -- Do Post enrollment - Writes elecment entries, calls close enrollment
        --
        if l_choice_info.pgm_id is null then
           --
           -- Invoke post result process
           --
           ben_proc_common_enrt_rslt.process_post_results
             (p_person_id          => p_person_id,
              p_enrt_mthd_cd       => 'E',
              p_effective_date     => l_effective_dt,
              p_business_group_id  => p_business_group_id,
              p_per_in_ler_id      => l_per_in_ler_id);
          --
          /*
          ben_proc_common_enrt_rslt.process_post_enrollment
            (p_per_in_ler_id     => l_per_in_ler_id,
             p_pgm_id            => l_choice_info.pgm_id,
             p_pl_id             => l_choice_info.pl_id,
             p_cls_enrt_flag     => l_cls_enrt_flag,
             p_enrt_mthd_cd      => 'E',
             p_proc_cd           => null,
             p_person_id         => p_person_id,
             p_business_group_id => p_business_group_id,
             p_effective_date    => p_effective_date);
           */
          --
        end if;
        --
        -- Do multi row edit stuff
        --
        if l_prev_pgm_id = -99999 then
          --
          l_prev_pgm_id := l_choice_info.pgm_id;
          l_prev_eff_dt := l_effective_dt;
          --
        elsif nvl(l_prev_pgm_id,-1) <> nvl(l_choice_info.pgm_id,-1) then

          -- call multi-row edit if per-in-ler has no default nor explict
          -- choices available.
          /*
          if l_cls_enrt_flag then
            ben_prtt_enrt_result_api.multi_rows_edit
              (p_person_id         => p_person_id,
               p_effective_date    => l_effective_dt,
               p_business_group_id => p_business_group_id,
               p_pgm_id            => l_prev_pgm_id);
          end if;
          */
          --
          -- Invoke process post enrollment
          --
          if l_prev_pgm_id is not null then
             --
             -- Invoke post result process
             --
             ben_proc_common_enrt_rslt.process_post_results
              (p_person_id          => p_person_id,
               p_enrt_mthd_cd       => 'E',
               p_effective_date     => l_effective_dt,
               p_business_group_id  => p_business_group_id,
               p_per_in_ler_id      => l_per_in_ler_id);
            /*
            ben_proc_common_enrt_rslt.process_post_enrollment
              (p_per_in_ler_id     => l_per_in_ler_id,
               p_pgm_id            => l_prev_pgm_id,
               p_pl_id             => null,
               p_enrt_mthd_cd      => 'E',
               p_cls_enrt_flag     => l_cls_enrt_flag,
               p_proc_cd           => null,
               p_person_id         => p_person_id,
               p_business_group_id => p_business_group_id,
               p_effective_date    => p_effective_date);
            */
            --
          end if;
          --
          l_prev_pgm_id := l_choice_info.pgm_id;
          l_prev_eff_dt := l_effective_dt;
          --
        end if;

	/* Bug 8900007:Reinstate the action items and certifications of carry forwarded enrollments*/
        if(ben_lf_evt_clps_restore.g_bckdt_sspndd_pen_list.count is not null) then
	  hr_utility.set_location('sspnd list1 ',310);
          if(ben_lf_evt_clps_restore.g_bckdt_sspndd_pen_list.count > 0 ) then
	   for i IN ben_lf_evt_clps_restore.g_bckdt_sspndd_pen_list.FIRST..ben_lf_evt_clps_restore.g_bckdt_sspndd_pen_list.LAST loop
	       hr_utility.set_location('sspnd list ' || ben_lf_evt_clps_restore.g_bckdt_sspndd_pen_list(i).PGM_ID||' '||
	                                                ben_lf_evt_clps_restore.g_bckdt_sspndd_pen_list(i).pl_id , 10);
	       hr_utility.set_location('l_choice_info ' || l_choice_info.pgm_id||' '||l_choice_info.pl_id , 10);
               if( nvl(ben_lf_evt_clps_restore.g_bckdt_sspndd_pen_list(i).PGM_ID,-1) = nvl(l_choice_info.pgm_id,-1)
	              and nvl(ben_lf_evt_clps_restore.g_bckdt_sspndd_pen_list(i).pl_id,-1) = nvl(l_choice_info.pl_id,-1)
		      and nvl(ben_lf_evt_clps_restore.g_bckdt_sspndd_pen_list(i).pl_typ_id,-1) = nvl(l_choice_info.pl_typ_id,-1) ) then
		       ben_lf_evt_clps_restore.reinstate_pcs_per_pen(
						 p_person_id  => ben_lf_evt_clps_restore.g_bckdt_sspndd_pen_list(i).person_id
						,p_bckdt_prtt_enrt_rslt_id  => ben_lf_evt_clps_restore.g_bckdt_sspndd_pen_list(i).prtt_enrt_rslt_id
						,p_prtt_enrt_rslt_id        => l_prtt_enrt_rslt_id -- pen_ovn_number
						,p_rslt_object_version_number => l_object_version_number -- prtt_enrt_rslt_id
						,p_business_group_id        => p_business_group_id
						,p_per_in_ler_id            => l_per_in_ler_id
						,p_effective_date           => l_effective_start_date
						,p_bckdt_per_in_ler_id      => ben_lf_evt_clps_restore.g_bckdt_sspndd_pen_list(i).PER_IN_LER_ID
						,p_prtt_enrt_actn_id        => null
						,p_bckdt_prtt_enrt_actn_id  => null);

		      ben_lf_evt_clps_restore.reinstate_pea_per_pen(
			 p_person_id                => ben_lf_evt_clps_restore.g_bckdt_sspndd_pen_list(i).person_id
			,p_bckdt_prtt_enrt_rslt_id  => ben_lf_evt_clps_restore.g_bckdt_sspndd_pen_list(i).prtt_enrt_rslt_id
			,p_prtt_enrt_rslt_id        => l_prtt_enrt_rslt_id -- pen_ovn_number
			,p_rslt_object_version_number => l_object_version_number -- prtt_enrt_rslt_id
			,p_business_group_id        => p_business_group_id
			,p_per_in_ler_id            => l_per_in_ler_id
			,p_effective_date           => l_effective_start_date
			,p_bckdt_per_in_ler_id      => ben_lf_evt_clps_restore.g_bckdt_sspndd_pen_list(i).PER_IN_LER_ID
			);
	      end if;
	   end loop;
	  end if;
	 end if;
	 /* End Bug 8900007:*/
        --
      end loop;
      --
    close c_choice_info;
    --
    -- Check if last multi edit passed
    --
    if l_prev_pgm_id <> -99999 then
      --
     /*
      if l_cls_enrt_flag then
        ben_prtt_enrt_result_api.multi_rows_edit
          (p_person_id         => p_person_id,
           p_effective_date    => l_prev_eff_dt,
           p_business_group_id => p_business_group_id,
           p_pgm_id            => l_prev_pgm_id);
      end if;
     */
      --
      -- Do post enrollment
      --
      if l_prev_pgm_id is not null then
        --
        --
        -- Invoke post result process
        --
        ben_proc_common_enrt_rslt.process_post_results
         (p_person_id          => p_person_id,
          p_enrt_mthd_cd       => 'E',
          p_effective_date     => l_effective_dt,
          p_business_group_id  => p_business_group_id,
          p_per_in_ler_id      => l_per_in_ler_id);
        --
        /*
        ben_proc_common_enrt_rslt.process_post_enrollment
          (p_per_in_ler_id     => l_per_in_ler_id,
           p_pgm_id            => l_prev_pgm_id,
           p_pl_id             => null,
           p_enrt_mthd_cd      => 'E',
           p_cls_enrt_flag     => l_cls_enrt_flag,
           p_proc_cd           => null,
           p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_effective_date);
        */
        --
      end if;
      --
    end if;
    --
    -- 6057157 : Carry Forward Certificatons which were provided on a future
    -- date to the current pil.
    --
    if (l_crd_fwd_pen_id.COUNT > 0) then
        for i in l_crd_fwd_pen_id.FIRST..l_crd_fwd_pen_id.LAST loop
            --
            hr_utility.set_location('CRD FWD CERT l_crd_fwd_pen_id(i) ' || l_crd_fwd_pen_id(i) , 10);
            --
            reinstate_prvdd_ctfn_items(p_prtt_enrt_rslt_id => l_crd_fwd_pen_id(i)
                                  ,p_per_in_ler_id => p_per_in_ler_id
                                  ,p_business_group_id => p_business_group_id
                                  ,p_effective_date => p_effective_date);

        end loop;
    end if;
    --
    ben_sspndd_enrollment.g_cfw_flag := 'N';
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
  exception
      when others then
           ben_sspndd_enrollment.g_cfw_flag := 'N';
           raise;

  end process_person;
  --
  procedure unprocess_susp_enrt_past_pil(p_prtt_enrt_rslt_id in number,
                                       p_per_in_ler_id     in number,
                                       p_business_group_id in number) is
  --
  cursor c_get_past_pil (p_per_in_ler_id number) is
  select max(pea.per_in_ler_id)
  from   ben_prtt_enrt_actn_f pea,
         ben_per_in_ler pil
  where  pea.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
  and    pea.per_in_ler_id <> p_per_in_ler_id
  and    pea.business_group_id = p_business_group_id
  and    pea.per_in_ler_id = pil.per_in_ler_id
  and    pil.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD');
  --
  cursor c_actn_item_for_past_pil (p_per_in_ler_id number) is
  select prtt_enrt_actn_id, effective_start_date, object_version_number
  from   ben_prtt_enrt_actn_f
  where  per_in_ler_id = p_per_in_ler_id
  and    prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
  and    effective_end_date < hr_api.g_eot
  and    business_group_id = p_business_group_id
  order by prtt_enrt_actn_id, effective_start_date;   -- 5394656
  l_actn_item                     c_actn_item_for_past_pil%rowtype;
  --
  cursor c_enrt_ctfn_for_past_pil (p_prtt_enrt_actn_id number) is
  select prtt_enrt_ctfn_prvdd_id, effective_start_date, object_version_number
  from   ben_prtt_enrt_ctfn_prvdd_f
  where  prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
  and    prtt_enrt_actn_id = p_prtt_enrt_actn_id
  and    effective_end_date < hr_api.g_eot
  and    business_group_id = p_business_group_id
  order by prtt_enrt_ctfn_prvdd_id, effective_start_date; -- 5394656
  l_enrt_ctfn                     c_enrt_ctfn_for_past_pil%rowtype;
  --
  cursor c_check_prem_active is
  select 1
  from   ben_prtt_prem_f
  where  prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
  and    effective_end_date = hr_api.g_eot;
  l_check_prem_active             c_check_prem_active%rowtype;
  --
  cursor c_ended_prem_details is
  select ppm.prtt_prem_id, ppm.effective_start_date, ppm.object_version_number
  from   ben_prtt_prem_f ppm
  where  ppm.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
  and    ppm.effective_end_date <> hr_api.g_eot
  and    not exists (select 1
                     from   ben_prtt_prem_f ppm2
                     where  ppm2.prtt_prem_id = ppm.prtt_prem_id
                     and    ppm2.effective_end_date > ppm.effective_end_date)
  order by effective_start_date desc;
  l_ended_prem_details            c_ended_prem_details%rowtype;
  --
  l_proc                          varchar2(80) := g_package||'.unprocess_susp_enrt_past_pil';
  l_per_in_ler_id                 number;
  l_prtt_enrt_actn_id             number;
  l_effective_start_date          date;
  l_effective_end_date            date;
  l_object_version_number         number;
  l_ppe_object_version_number     number;
  --
  l_prev_prtt_enrt_actn_id        number;
  l_prev_prtt_enrt_ctfn_prvdd_id  number;
  --
begin
  --
  hr_utility.set_location ('Entering ' || l_proc , 1230);
  l_per_in_ler_id := p_per_in_ler_id;
  l_prev_prtt_enrt_actn_id := -1;
  --
  for l_actn_item in c_actn_item_for_past_pil (l_per_in_ler_id) loop
  --
     -- 5394656: Since 'FUTURE_CHANGE' mode deletes all future records
     -- we need to run the delete_api only once for every prtt_enrt_actn_id
     --
     l_prtt_enrt_actn_id := l_actn_item.prtt_enrt_actn_id;
     --
     if (l_prev_prtt_enrt_actn_id <> l_prtt_enrt_actn_id) then
         --
         l_prev_prtt_enrt_actn_id := l_prtt_enrt_actn_id;
         --
         -- Un-enddate action item record
         --
         l_object_version_number := l_actn_item.object_version_number;
         --
         ben_pea_del.del(
                         p_prtt_enrt_actn_id => l_actn_item.prtt_enrt_actn_id,
                         p_effective_start_date => l_effective_start_date,
                         p_effective_end_date => l_effective_end_date,
                         p_object_version_number => l_object_version_number,
                         p_effective_date => l_actn_item.effective_start_date,
                         p_datetrack_mode => hr_api.g_future_change);
         --
         l_prev_prtt_enrt_ctfn_prvdd_id := -1;
         --
         -- Un-enddate enrollment certification record(s)
         --
         for l_enrt_ctfn in c_enrt_ctfn_for_past_pil (l_prtt_enrt_actn_id) loop
         --
            l_object_version_number := l_enrt_ctfn.object_version_number;
            --
            -- 5394656: Since 'FUTURE_CHANGE' mode deletes all future records
            -- we need to run the delete_api only once for every prtt_enrt_ctfn_prvdd_id
            --
            if (l_prev_prtt_enrt_ctfn_prvdd_id <> l_enrt_ctfn.prtt_enrt_ctfn_prvdd_id) then
                --
                l_prev_prtt_enrt_ctfn_prvdd_id := l_enrt_ctfn.prtt_enrt_ctfn_prvdd_id;
                --
                ben_pcs_del.del(
                                p_prtt_enrt_ctfn_prvdd_id => l_enrt_ctfn.prtt_enrt_ctfn_prvdd_id,
                                p_effective_start_date => l_effective_start_date,
                                p_effective_end_date => l_effective_end_date,
                                p_object_version_number => l_object_version_number,
                                p_effective_date => l_enrt_ctfn.effective_start_date,
                                p_datetrack_mode => hr_api.g_future_change);
            end if;
         --
         end loop;
      end if;
  --
  end loop;
  --
  -- Process premium, if ended (will be needed for ineligible/due date past cases)
  --
  open c_check_prem_active;
  fetch c_check_prem_active into l_check_prem_active;
  if c_check_prem_active%notfound then
     --
     -- Unend most recent premiums
     --
     for l_ended_prem_details in c_ended_prem_details loop
        l_ppe_object_version_number := l_ended_prem_details.object_version_number;
        ben_ppe_del.del(
                        p_prtt_prem_id => l_ended_prem_details.prtt_prem_id,
                        p_effective_start_date => l_effective_start_date,
                        p_effective_end_date => l_effective_end_date,
                        p_object_version_number => l_ppe_object_version_number,
                        p_effective_date => l_ended_prem_details.effective_start_date,
                        p_datetrack_mode => hr_api.g_future_change);
     end loop;
     --
  end if;
  close c_check_prem_active;
  --
  hr_utility.set_location ('Leaving ' || l_proc, 1230);
end unprocess_susp_enrt_past_pil;
procedure carry_farward_results(
                 p_person_id             in number,
                 p_per_in_ler_id         in number,
                 p_ler_id                in number,
                 p_business_group_id     in number,
                 p_mode                  in varchar2,
                 p_effective_date        in date) is
    --
    l_proc      varchar2(80) := g_package||'carry_farward_results';
    l_person_id number;
    --
    cursor c_pen_sus is
    select pen.prtt_enrt_rslt_id,
           pen.per_in_ler_id
      from ben_prtt_enrt_rslt_f pen,
           ben_per_in_ler pil
     where pen.sspndd_flag = 'Y'
       and pen.per_in_ler_id <> pil.per_in_ler_id
       and pil.per_in_ler_id = p_per_in_ler_id
       and pen.person_id = pil.person_id
       and pen.effective_end_date = hr_api.g_eot
       and pen.enrt_cvg_thru_dt = hr_api.g_eot;
    l_pen_sus c_pen_sus%rowtype;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('p_person_id'||p_person_id,10);
    hr_utility.set_location('p_per_in_ler_id'||p_per_in_ler_id,10);
    hr_utility.set_location('p_business_group_id'||p_business_group_id,10);
    hr_utility.set_location('p_mode'||p_mode,10);
    hr_utility.set_location('p_effective_date'||p_effective_date,10);
    --
    if p_mode not in ('L','C', 'M') then
      --
      -- Wrong mode my friend!
      --
      return;
      --
    end if;
    --
    process_person(p_person_id         => p_person_id,
                   p_business_group_id => p_business_group_id,
                   p_per_in_ler_id     => p_per_in_ler_id,
                   p_ler_id            => p_ler_id,
                   p_effective_date    => p_effective_date);
        --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    --Reopen the closed action items of the enrollment results for which there are no
    --electable choices exists in this life event.
    open c_pen_sus;
    loop
         fetch c_pen_sus into l_pen_sus;
         if c_pen_sus%notfound then
            exit;
         end if;

         unprocess_susp_enrt_past_pil
         (l_pen_sus.prtt_enrt_rslt_id,
          l_pen_sus.per_in_ler_id,
          p_business_group_id);

    end loop;
    close c_pen_sus;
    --
  end carry_farward_results;
end ben_carry_forward_items;

/

--------------------------------------------------------
--  DDL for Package Body BEN_MANAGE_OVERRIDE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_MANAGE_OVERRIDE" as
/* $Header: benovrrd.pkb 120.0.12010000.2 2008/08/05 14:49:18 ubhat ship $ */
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Author	   Comments
  ---------  ---------	---------- --------------------------------------------
  115.0      16-Apr-02	ikasire    Created .
  115.1      20-May-02  ikasire    GSCC Warnings fixed
  115.2      07-Aug-02  ikasire    Bug 2502236 fixes added call to
                                   ben_determine_actual_premium.main
  115.3      06-Dec-02  tjesumic   nocopy
  115.5      26-Dec-02  tjesumic   nocopy
  115.6      08-Apr-03  ikasire    Bug 2852325 End dating the rates and dependets
                                   when coverage is  ended and
                                   reopen_rate_and_dependents.
  115.7      16-Apr-03  ikasire    Bug 2859290 Added new procedure to handle
                                   participant premium computaion. Also adde
                                   calls in the end and open procedures for
                                   premium computation.
  115.8      11-Apr-04  tjesumic   fonm changes
  115.9      05-Sep-04  ikasire    FIDOML Override Enhancements
  115.10     09-Sep-04  ikasire    FIDOML Bug 3882059 -- Validatation rates
  115.11     13-Sep-04  ikasire    FIDOML Need to end the elements properly when
                                   any rate is changed.Bug 3888225
  115.12     09-Feb-05  ikasire    Bug 4158017 changes
  115.13     13-Apr-05  ikasire    Added a new parameter to manage_enrt_bmft call
  115.14     22-Feb-2008 rtagarra  Bug 6840074
  -----------------------------------------------------------------------------
*/
--
-- Globals.
--
--
  procedure create_electable_choices
    (p_called_from_key_listval in varchar2 default 'N'
    ,p_person_id               in number
    ,p_per_in_ler_id           in number
    ,p_run_mode                in varchar2 default 'V'
    ,p_business_group_id       in number
    ,p_effective_date          in date
    ,p_lf_evt_ocrd_dt          in date
    ,p_ler_id                  in number
    ,p_pl_id                   in number
    ,p_pgm_id                  in number default null
    ,p_oipl_id                 in number default null
    ,p_ptip_id                 in number default null
    ,p_plip_id                 in number default null
    ,p_create_anyhow_flag      in varchar2 default 'N'
    ,p_asnd_lf_evt_dt          in date default null
    ,p_electable_flag         out nocopy varchar2
    ,p_elig_per_elctbl_chc_id out nocopy number
    ,p_enrt_cvg_strt_dt       out nocopy date
    ,p_enrt_bnft_id           out nocopy number
    ,p_bnft_amt               out nocopy number
    ,p_bnft_typ_cd            out nocopy varchar2
    ,p_bnft_nnmntry_uom       out nocopy varchar2
    )
  is
   --Declare local variables
   l_electable_flag           varchar2(30);
   l_elig_per_elctbl_chc_id   number;
   l_comp_obj_tree_row        ben_manage_life_events.g_cache_proc_objects_rec;
   l_enb_valrow               ben_determine_coverage.ENBValType;
   l_date_dummy               date ;
   --
   l_package                  varchar2(500) := 'Ben_Manage_Override.Create_Electable_Choices';
   l_char_dummy               varchar2(30) ;
   l_flx_pl_id                number ;
   l_flx_elig_per_elctbl_chc_id number ;
   l_flx_ptip_id              number;
   l_flx_plip_id              number;
   l_flx_electable_flag       varchar2(30);
   l_imp_pl_id                number ;
   l_imp_elig_per_elctbl_chc_id number ;
   l_imp_ptip_id              number;
   l_imp_plip_id              number;
   l_imp_electable_flag       varchar2(30);
   l_oipl_rec                 ben_cobj_cache.g_oipl_inst_row;
   l_ptip_rec                 ben_cobj_cache.g_ptip_inst_row;
   l_plip_rec                 ben_cobj_cache.g_plip_inst_row;
   l_pl_rec                   ben_cobj_cache.g_pl_inst_row;
   l_pgm_rec                  ben_cobj_cache.g_pgm_inst_row;
   --
   cursor c_epe(p_epe_id number) is
     select enrt_cvg_strt_dt,pl_typ_id
     from ben_elig_per_elctbl_chc epe
     where epe.elig_per_elctbl_chc_id = p_epe_id ;
   --
   l_epe                      c_epe%rowtype;
   --
   cursor c_enb(p_enrt_bnft_id number ) is
     select val,
            bnft_typ_cd,
            nnmntry_uom
     from ben_enrt_bnft enb
     where enb.enrt_bnft_id = p_enrt_bnft_id ;
   --
   l_enb                      c_enb%rowtype;
   --
   cursor c_enrt_rt(p_epe_id number, p_enrt_bnft_id number ) is
     select ecr.*
        from   ben_enrt_rt ecr
        where  ecr.elig_per_elctbl_chc_id = p_epe_id
        union
        select ecr.*
        from   ben_enrt_rt ecr
        where  ecr.elig_per_elctbl_chc_id is null
        and    ecr.enrt_bnft_id = p_enrt_bnft_id ;
   --
   cursor c_acty_base_rt(c_acty_base_rt_id number) is
     select abr.*
        from  ben_acty_base_rt_f abr
        where abr.acty_base_rt_id = c_acty_base_rt_id
        and p_effective_date between abr.effective_start_date and abr.effective_end_date ;
   --
   cursor c_flx_epe_ecr(c_per_in_ler_id number ) is
     select epe.elig_per_elctbl_chc_id
     from ben_elig_per_elctbl_chc epe
     where epe.per_in_ler_id = c_per_in_ler_id
     and   epe.bnft_prvdr_pool_id is not null
     and   epe.elig_per_elctbl_chc_id
           not in ( select ecr.elig_per_elctbl_chc_id from ben_enrt_rt ecr
                    where ecr.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
                      and ecr.rt_usg_cd = 'FLXCR'
                  ) ;
   --
   -- Cursor to check whether the program is a flex program.
   --
   cursor c_flx_pgm(c_pgm_id number ) is
            select 'x'
            from  ben_pgm_f pgm
            where
                pgm.pgm_id  = c_pgm_id
            and pgm.pgm_typ_cd in ('COBRAFLX','FLEX', 'FPC' )
            and p_effective_date between
                pgm.effective_start_date and pgm.effective_end_date ;
   -- check for shell plan
   cursor c_flx_plan_exists is
            select pln.pl_id,plip.plip_id,ptip.ptip_id
            from ben_pl_f pln,
                 ben_plip_f plip,
                 ben_ptip_f ptip
            where
                plip.pgm_id = p_pgm_id
            and plip.pl_id  = pln.pl_id
            and pln.invk_flx_cr_pl_flag = 'Y'
            and pln.pl_typ_id = ptip.pl_typ_id
            and ptip.pgm_id = p_pgm_id
            and p_effective_date between
                plip.effective_start_date and plip.effective_end_date
            and p_effective_date between
                pln.effective_start_date and pln.effective_end_date
            and p_effective_date between
                ptip.effective_start_date and ptip.effective_end_date
            and not exists ( select elig_per_elctbl_chc_id
                             from ben_elig_per_elctbl_chc epe
                             where epe.pgm_id = p_pgm_id
                             and   epe.pl_id  = pln.pl_id
                             and   epe.per_in_ler_id = p_per_in_ler_id
                             and   epe.comp_lvl_cd = 'PLANFC' );
   --check for imputed income plan
   cursor c_imp_plan_exists is
            select pln.pl_id,plip.plip_id,ptip.ptip_id
            from ben_pl_f pln,
                 ben_plip_f plip,
                 ben_ptip_f ptip
            where
                plip.pgm_id = p_pgm_id
            and plip.pl_id  = pln.pl_id
            and pln.imptd_incm_calc_cd is not null
            and pln.pl_typ_id = ptip.pl_typ_id
            and ptip.pgm_id = p_pgm_id
            and p_effective_date between
                plip.effective_start_date and plip.effective_end_date
            and p_effective_date between
                pln.effective_start_date and pln.effective_end_date
            and p_effective_date between
                ptip.effective_start_date and ptip.effective_end_date
            and not exists ( select elig_per_elctbl_chc_id
                             from ben_elig_per_elctbl_chc epe
                             where epe.pgm_id = p_pgm_id
                             and   epe.pl_id  = pln.pl_id
                             and   epe.per_in_ler_id = p_per_in_ler_id
                             and   epe.comp_lvl_cd = 'PLANIMP' );
   --
   l_enrt_rt                c_enrt_rt%rowtype;
   l_acty_base_rt           c_acty_base_rt%rowtype;
   l_dummy_date      date;
   l_dummy_number    number;
   l_dummy_varchar2  varchar2(30);
   l_enrt_cvg_strt_dt date;
   --
  begin
    -- When a pl_id is passed,
    -- 1. we need to create the electable choices for that comp object
    -- 2. if that plan is subjected to imputed income and there is no epe for shell create one
    -- 3. If the selected comp object is from a flex program, and there is no electable
    --    choice for the shell program we need to create one for that
    -- 4. If the selected comp object [pl_id] has option, and enroll in plan and options flag
    --    we need to create the electable choices for the options of that plan also.
    --    pl.ENRT_PL_OPT_FLAG is 'Y'for plan and option
    -- 5. We create the electable choices for all the flex credits - we call the flxii everytime
    --    if the program is not a flex program it will come out immidiately.Even if we call this
    --    routine multiple times, there will not be any duplicate records created [make sure???]
    --
    -- Set the env
    --
    if p_called_from_key_listval = 'Y' then
      savepoint called_from_key_listval ;
    end if;
    --
    hr_utility.set_location('Entering '||l_package ,10);
    hr_utility.set_location('Calling ben_env_object.init',20);
    ben_env_object.init(p_business_group_id  => p_business_group_id ,
                         p_effective_date     => p_effective_date,
                         p_thread_id          => 1,
                         p_chunk_size         => 1,
                         p_threads            => 1,
                         p_max_errors         => 1,
                         p_benefit_action_id  => null,
                         p_audit_log_flag     => 'N');
    --
    -- Create epe /popl records
    -- Set the cache values for bendenrr
    l_comp_obj_tree_row.par_ptip_id := p_ptip_id;
    l_comp_obj_tree_row.par_plip_id := p_plip_id;
    --
    if p_oipl_id is not null then
      --
      ben_cobj_cache.get_oipl_dets (
        p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_oipl_id           => p_oipl_id
       ,p_inst_row          => l_oipl_rec
       ) ;
      ben_cobj_cache.g_oipl_currow := l_oipl_rec ;
      --
    end if ;
    --
    if p_pl_id is not null then
      --
      ben_cobj_cache.get_pl_dets (
        p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_pl_id           => p_pl_id
       ,p_inst_row          => l_pl_rec
       ) ;
      ben_cobj_cache.g_pl_currow := l_pl_rec ;
      --
    end if ;
    --
    if p_plip_id is not null then
      --
      ben_cobj_cache.get_plip_dets (
        p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_plip_id           => p_plip_id
       ,p_inst_row          => l_plip_rec
       ) ;
      ben_cobj_cache.g_plip_currow := l_plip_rec ;
      --
    end if ;
    --
    --
    if p_ptip_id is not null then
      --
      ben_cobj_cache.get_ptip_dets (
        p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_ptip_id           => p_ptip_id
       ,p_inst_row          => l_ptip_rec
       ) ;
      ben_cobj_cache.g_ptip_currow := l_ptip_rec ;
      --
    end if ;
    --
    if p_pgm_id is not null then
      --
      ben_cobj_cache.get_pgm_dets (
        p_business_group_id => p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_pgm_id            => p_pgm_id
       ,p_inst_row          => l_pgm_rec
       ) ;
      ben_cobj_cache.g_pgm_currow := l_pgm_rec ;
      --
    end if ;
    --
    hr_utility.set_location('Calling ben_enrolment_requirements_ik.enrolment_requirements',30);
    ben_enrolment_requirements.enrolment_requirements
      (p_comp_obj_tree_row       =>l_comp_obj_tree_row
       ,p_run_mode               =>p_run_mode
       ,p_business_group_id      =>p_business_group_id
       ,p_effective_date         =>p_effective_date
       ,p_lf_evt_ocrd_dt         =>p_lf_evt_ocrd_dt
       ,p_ler_id                 =>p_ler_id
       ,p_per_in_ler_id          =>p_per_in_ler_id
       ,p_person_id              =>p_person_id
       ,p_pl_id                  =>p_pl_id
       ,p_pgm_id                 =>p_pgm_id   --number default null
       ,p_oipl_id                =>p_oipl_id     --number default null
       ,p_electable_flag         =>l_electable_flag
       ,p_elig_per_elctbl_chc_id =>l_elig_per_elctbl_chc_id
      ) ;
    p_elig_per_elctbl_chc_id := l_elig_per_elctbl_chc_id ;
    p_electable_flag := l_electable_flag ;
    -- Create enrt_bnft records
    -- Set cache for bencvrge.pkb cache
    if l_elig_per_elctbl_chc_id is not null then
        --
        open c_epe(l_elig_per_elctbl_chc_id);
          fetch c_epe into l_epe ;
        close c_epe;
        p_enrt_cvg_strt_dt := l_epe.enrt_cvg_strt_dt;
        --
        ben_determine_date.rate_and_coverage_dates
              (p_which_dates_cd         => 'C'
              ,p_business_group_id      => p_business_group_id
              ,p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
              ,p_enrt_cvg_strt_dt       => l_enrt_cvg_strt_dt
              ,p_enrt_cvg_strt_dt_cd    => l_dummy_varchar2
              ,p_enrt_cvg_strt_dt_rl    => l_dummy_number
              ,p_rt_strt_dt             => l_dummy_date
              ,p_rt_strt_dt_cd          => l_dummy_varchar2
              ,p_rt_strt_dt_rl          => l_dummy_number
              ,p_enrt_cvg_end_dt        => l_dummy_date
              ,p_enrt_cvg_end_dt_cd     => l_dummy_varchar2
              ,p_enrt_cvg_end_dt_rl     => l_dummy_number
              ,p_rt_end_dt              => l_dummy_date
              ,p_rt_end_dt_cd           => l_dummy_varchar2
              ,p_rt_end_dt_rl           => l_dummy_number
              ,p_acty_base_rt_id        => null
              ,p_effective_date         => p_effective_date
              ,p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt
        );
        --
        p_enrt_cvg_strt_dt := l_enrt_cvg_strt_dt;
        --
        ben_epe_cache.g_currcobjepe_row.pl_id   :=  p_pl_id ;
        ben_epe_cache.g_currcobjepe_row.plip_id := p_plip_id ;
        ben_epe_cache.g_currcobjepe_row.oipl_id := p_oipl_id ;
        --
        hr_utility.set_location('Calling ben_determine_coverage.main ',40);
        ben_determine_coverage.main
         ( p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
          ,p_effective_date         => p_effective_date
          ,p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt
          ,p_perform_rounding_flg   => true
          ,p_enb_valrow             => l_enb_valrow
          );
        --
        -- p_enb_valrow  := l_enb_valrow ;
        --
        if l_enb_valrow.enrt_bnft_id is not null then
          --
          open c_enb(l_enb_valrow.enrt_bnft_id);
          fetch c_enb into l_enb ;
          --
          p_bnft_amt         := l_enb.val ;
          p_bnft_typ_cd      := l_enb.bnft_typ_cd ;
          p_bnft_nnmntry_uom := l_enb.nnmntry_uom ;
          p_enrt_bnft_id     := l_enb_valrow.enrt_bnft_id;
          --
          close c_enb;
          --
        end if;
        --
        hr_utility.set_location('premium calculation from Override ',111);
        ben_determine_actual_premium.g_computed_prem_val := null ;
        ben_determine_actual_premium.main
          (p_person_id             => p_person_id,
           p_effective_date        => p_effective_date,
           p_lf_evt_ocrd_dt        => p_lf_evt_ocrd_dt,
           p_pgm_id                => p_pgm_id,
           p_pl_id                 => p_pl_id,
           p_pl_typ_id             => l_epe.pl_typ_id,
           p_oipl_id               => p_oipl_id,
           p_per_in_ler_id         => p_per_in_ler_id,
           p_ler_id                => p_ler_id,
           p_bnft_amt              => p_bnft_amt,
           p_business_group_id     => p_business_group_id );
           --
        hr_utility.set_location('premium calculation from override ',112);
        -- Create enrt_rt records
        hr_utility.set_location('Calling ben_determine_rates.main ',50);
        hr_utility.set_location(' l_elig_per_elctbl_chc_id '||l_elig_per_elctbl_chc_id,35);
        --
        ben_epe_cache.clear_down_cache ;
        --
        ben_determine_rates.main
         (p_effective_date          => p_effective_date
         ,p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt
         ,p_person_id               => p_person_id
         ,p_per_in_ler_id           => p_per_in_ler_id
         ,p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id
         );
        --
    end if;
    --
    hr_utility.set_location(' p_pgm_id '||p_pgm_id,123);
    if p_pgm_id is not null then
      --
      open c_flx_pgm(p_pgm_id);
      fetch c_flx_pgm into l_char_dummy ;
      if c_flx_pgm%found then
        --
        hr_utility.set_location(' Flex Program ',123);
        open c_flx_plan_exists ;
        fetch c_flx_plan_exists into l_flx_pl_id ,l_flx_plip_id,l_flx_ptip_id ;
        if c_flx_plan_exists%found then
          --
          hr_utility.set_location(' No epe exists ' ,123);
          --Call bendenrr
          l_comp_obj_tree_row.par_ptip_id := l_flx_ptip_id;
          l_comp_obj_tree_row.par_plip_id := l_flx_plip_id;
          --
          hr_utility.set_location('Call bendenrr create flexshell epefor plan  '||l_flx_pl_id,30);
          ben_enrolment_requirements.enrolment_requirements
                (p_comp_obj_tree_row       =>l_comp_obj_tree_row
                 ,p_run_mode               =>p_run_mode
                 ,p_business_group_id      =>p_business_group_id
                 ,p_effective_date         =>p_effective_date
                 ,p_lf_evt_ocrd_dt         =>p_lf_evt_ocrd_dt
                 ,p_ler_id                 =>p_ler_id
                 ,p_per_in_ler_id          =>p_per_in_ler_id
                 ,p_person_id              =>p_person_id
                 ,p_pl_id                  =>l_flx_pl_id
                 ,p_pgm_id                 =>p_pgm_id   --number default null
                 ,p_oipl_id                =>null      --number default null
                 ,p_electable_flag         =>l_flx_electable_flag
                 ,p_elig_per_elctbl_chc_id =>l_flx_elig_per_elctbl_chc_id
          ) ;
          --Call benrates
          --
          if l_flx_elig_per_elctbl_chc_id is not null then
            --
            ben_epe_cache.clear_down_cache ;
            --
            ben_determine_rates.main
              (p_effective_date          => p_effective_date
               ,p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt
               ,p_person_id               => p_person_id
               ,p_per_in_ler_id           => p_per_in_ler_id
               ,p_elig_per_elctbl_chc_id  => l_flx_elig_per_elctbl_chc_id
                );
            --
            end if;
            --
          end if; --   -- if no electable choices exist for the flex shell plan
          close c_flx_plan_exists ;
          --
        end if;  -- if a the program is Flex
        close c_flx_pgm ;
        --
    end if ; -- if p_pgm_id exists
    -- We need to run only if they don't exist
    -- If we call from Override, even called multiple times
    -- it creates electable choises only if they don't exist.
    ben_determine_elct_chc_flx_imp.main
      (p_person_id         => p_person_id,
       p_business_group_id => p_business_group_id,
       p_per_in_ler_id     => p_per_in_ler_id,
       p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
       p_enrt_perd_strt_dt => l_date_dummy, -- This is not used in benflxii.pkb
       p_effective_date    => p_effective_date,
       p_called_from       => 'O' );
    --
    -- To create the ben_enrt_rt records for the flex credits setup
    --
    for l_flx_epe in c_flx_epe_ecr( p_per_in_ler_id ) loop
      --
      ben_epe_cache.clear_down_cache ;
      --
      ben_determine_rates.main
        (p_effective_date          => p_effective_date
         ,p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt
         ,p_person_id               => p_person_id
         ,p_per_in_ler_id           => p_per_in_ler_id
         ,p_elig_per_elctbl_chc_id  => l_flx_epe.elig_per_elctbl_chc_id
         );
        --
    end loop;
    --
    -- imputed income epe and ecr rows
    --
    for r_imp_plans in c_imp_plan_exists loop
       --
       hr_utility.set_location(' No epe exists ' ,123);
       --Call bendenrr
       l_comp_obj_tree_row.par_ptip_id := r_imp_plans.ptip_id;
       l_comp_obj_tree_row.par_plip_id := r_imp_plans.plip_id;
       --
       hr_utility.set_location('Call bendenrr create imp epefor plan  '||r_imp_plans.pl_id,30);
       ben_enrolment_requirements.enrolment_requirements
                (p_comp_obj_tree_row       =>l_comp_obj_tree_row
                 ,p_run_mode               =>p_run_mode
                 ,p_business_group_id      =>p_business_group_id
                 ,p_effective_date         =>p_effective_date
                 ,p_lf_evt_ocrd_dt         =>p_lf_evt_ocrd_dt
                 ,p_ler_id                 =>p_ler_id
                 ,p_per_in_ler_id          =>p_per_in_ler_id
                 ,p_person_id              =>p_person_id
                 ,p_pl_id                  =>r_imp_plans.pl_id
                 ,p_pgm_id                 =>p_pgm_id
                 ,p_oipl_id                =>null
                 ,p_electable_flag         =>l_imp_electable_flag
                 ,p_elig_per_elctbl_chc_id =>l_imp_elig_per_elctbl_chc_id
       ) ;
       --Call benrates
       --
       if l_imp_elig_per_elctbl_chc_id is not null then
         --
         ben_epe_cache.clear_down_cache ;
         --
         ben_determine_rates.main
           (p_effective_date          => p_effective_date
            ,p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt
            ,p_person_id               => p_person_id
            ,p_per_in_ler_id           => p_per_in_ler_id
            ,p_elig_per_elctbl_chc_id  => l_imp_elig_per_elctbl_chc_id
            );
         --
       end if;
    end loop ;  --imputed income
    --
    hr_utility.set_location('Leaving '||l_package,60);
    --
  --- no copy
   exception
   when others then
    p_electable_flag         := null ;
    p_elig_per_elctbl_chc_id := null ;
    p_enrt_cvg_strt_dt       := null ;
    p_enrt_bnft_id           := null ;
    p_bnft_amt               := null ;
    p_bnft_typ_cd            := null ;
    p_bnft_nnmntry_uom       := null ;
    raise ;
  end create_electable_choices ;
  --
  procedure post_override
     ( p_elig_per_elctbl_chc_id     in number
      ,p_prtt_enrt_rslt_id          in number
      ,p_effective_date             in date
     -- for manage enrt_bnft
      ,p_enrt_bnft_id               in number default null
      ,p_business_group_id          in number
     )
  is
    -- Local variables
    l_package              varchar2(500) := 'Ben_Manage_Override.post_override ';
    l_epe_object_version_number     number;
    l_enb_object_version_number     number;
    -- cursors declaration
    cursor c_epe is
      select object_version_number,per_in_ler_id
      from ben_elig_per_elctbl_chc epe
      where epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id ;
    --
    cursor c_enb is
      select object_version_number
      from ben_enrt_bnft enb
      where enb.enrt_bnft_id = p_enrt_bnft_id ;
    --
    l_per_in_ler_id       number;
    --
  begin
    hr_utility.set_location('Entering '||l_package,10);
    -- Update epe with the prtt_enrt_rslt_id
    open c_epe ;
      fetch c_epe into l_epe_object_version_number,l_per_in_ler_id ;
    close c_epe;
    --
    hr_utility.set_location('Calling ben_ELIG_PER_ELC_CHC_api.update_ELIG_PER_ELC_CHC ',20);
    hr_utility.set_location(' p_elig_per_elctbl_chc_id '||p_elig_per_elctbl_chc_id,22);
    hr_utility.set_location(' l_epe_object_version_number '||l_epe_object_version_number,23);
    --
    ben_ELIG_PER_ELC_CHC_api.update_ELIG_PER_ELC_CHC
         (p_validate                       => FALSE
          ,p_elig_per_elctbl_chc_id         => p_elig_per_elctbl_chc_id
          ,p_prtt_enrt_rslt_id              => p_prtt_enrt_rslt_id
          ,p_object_version_number          => l_epe_object_version_number
          ,p_effective_date                 => p_effective_date
          ,p_request_id                     => fnd_global.conc_request_id
          ,p_program_application_id         => fnd_global.prog_appl_id
          ,p_program_id                     => fnd_global.conc_program_id
          ,p_program_update_date            => sysdate
          );
    --
    -- Update enrt_bnft with the prtt_enrt_rslt_id
    if p_enrt_bnft_id is not null then
      --
      open c_enb ;
        fetch c_enb into l_enb_object_version_number ;
      close c_enb ;
      --
      hr_utility.set_location('Calling ben_election_information.manage_enrt_bnft ',30);
      ben_election_information.manage_enrt_bnft
       ( p_enrt_bnft_id               => p_enrt_bnft_id
        ,p_effective_date             => p_effective_date
        ,p_object_version_number      => l_enb_object_version_number
        ,p_business_group_id          => p_business_group_id
        ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_creation_date              => null
        ,p_created_by                 => null
        ,p_per_in_ler_id              => l_per_in_ler_id
        );
      --
    end if;
    --
    hr_utility.set_location('Leaving '||l_package,40);
  end post_override ;
  --
  -- Wrapper for update_elig_dependents call
  --
  procedure update_elig_dpnt
    ( p_elig_dpnt_id           in number
     ,p_elig_cvrd_dpnt_id      in number
     ,p_effective_date         in date
     ,p_business_group_id      in number
     ,p_object_version_number  in out nocopy number
    ) is
    l_package                  varchar2(500) := 'Ben_Manage_Override.update_elig_dpnt' ;
  begin
    --
    hr_utility.set_location('Calling '||l_package,10);
    ben_elig_dpnt_api.update_elig_dpnt(
      p_elig_dpnt_id           => p_elig_dpnt_id,
      p_elig_cvrd_dpnt_id      => p_elig_cvrd_dpnt_id,
      p_effective_date         => p_effective_date,
      p_business_group_id      => p_business_group_id,
      p_object_version_number  => p_object_version_number,
      p_program_application_id => fnd_global.prog_appl_id,
      p_program_id             => fnd_global.conc_program_id,
      p_request_id             => fnd_global.conc_request_id,
      p_program_update_date    => sysdate
     );
    hr_utility.set_location('Leaving '||l_package,20);
    --
  end;

  procedure rollback_choices is
  begin
    --
    rollback to called_from_key_listval;
    --
  end ;
  -- Procedure end dating the rates and coverages when result is end dated.
  procedure end_rate_and_dependents
    (p_person_id              in number
    ,p_per_in_ler_id          in number
    ,p_prtt_enrt_rslt_id      in number
    ,p_enrt_cvg_thru_dt       in date
    ,p_effective_date         in date
    ) is
    --Cursor to get the ben_prtt_rt_val records with the rt_end_dt as end of time
    --
    l_package                  varchar2(500) := 'Ben_Manage_Override.end_rate_and_dependents';
    --
    cursor c_prv(cv_prtt_enrt_rslt_id number) is
      select prtt_rt_val_id,
             object_version_number,
             acty_base_rt_id,
             per_in_ler_id,
             business_group_id,
             element_entry_value_id
      from ben_prtt_rt_val prv
      where prv.prtt_enrt_rslt_id = cv_prtt_enrt_rslt_id
      and   prv.prtt_rt_val_stat_cd is null
      and   prv.rt_end_dt = to_date('31/12/4712','DD/MM/RRRR') ;
    --
    --Cursor to get the input value and the element type id from abr
    cursor c_abr(cv_acty_base_rt_id number,
                 cv_effective_date date ) is
      select input_value_id,
             element_type_id
      from   ben_acty_base_rt_f abr
      where  abr.acty_base_rt_id = cv_acty_base_rt_id
      and    cv_effective_date between abr.effective_start_date
                                   and abr.effective_end_date ;
    --
    l_abr            c_abr%ROWTYPE;
    --
    --Cursor to get the ben_elig_cvrd_dpnt_f with cvg_thru_dt as end of time
    cursor c_pdp(cv_prtt_enrt_rslt_id number,
                 cv_effective_date date) is
      select pdp.elig_cvrd_dpnt_id,
             pdp.object_version_number,
             pdp.business_group_id,
             pdp.per_in_ler_id
      from  ben_elig_cvrd_dpnt_f pdp
      where pdp.prtt_enrt_rslt_id = cv_prtt_enrt_rslt_id
      and   cv_effective_date between pdp.effective_start_date
                                  and pdp.effective_end_date
      and   pdp.cvg_thru_dt = to_date('31/12/4712','DD/MM/RRRR') ;
    --
    --Bug 2859290 Ending Coverage should end the Participant premiums also.
    --
    cursor c_ppe (p_ppe_dt_to_use IN DATE) is
      select ppe.prtt_prem_id,
           ppe.object_version_number,
           ppe.effective_start_date,
           ppe.effective_end_date,
           ppe.actl_prem_id
      from ben_prtt_prem_f ppe,
           ben_per_in_ler pil
     where ppe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and pil.per_in_ler_id=ppe.per_in_ler_id
       and pil.business_group_id=ppe.business_group_id
       and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
       and p_ppe_dt_to_use between ppe.effective_start_date and ppe.effective_end_date
     UNION
    select ppe1.prtt_prem_id,
           ppe1.object_version_number,
           ppe1.effective_start_date,
           ppe1.effective_end_date,
           ppe1.actl_prem_id
      from ben_prtt_prem_f ppe1,
           ben_per_in_ler pil
     where ppe1.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and pil.per_in_ler_id=ppe1.per_in_ler_id
       and pil.business_group_id=ppe1.business_group_id
       and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
       and ppe1.effective_start_date > p_ppe_dt_to_use
       and not exists
           (select 1
              from ben_prtt_prem_f ppe2,
                   ben_per_in_ler pil
             where ppe2.prtt_prem_id = ppe1.prtt_prem_id
             and   ppe2.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
             and   pil.per_in_ler_id=ppe2.per_in_ler_id
             and   pil.business_group_id=ppe2.business_group_id
             and   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
             and   p_ppe_dt_to_use between
                        ppe2.effective_start_date and ppe2.effective_end_date);
    --
    l_ppe c_ppe%rowtype;
    --
    l_effective_start_date   date;
    l_effective_end_date     date;
    l_ppe_dt_mode            varchar2(30);
    --
    l_zap                    boolean;
    l_delete                 boolean;
    l_future_change          boolean;
    l_delete_next_change     boolean;
    --
  begin
    hr_utility.set_location('Entering '||l_package,10);
    -- End dependents
    for l_pdp in c_pdp(p_prtt_enrt_rslt_id,p_effective_date) loop
      --
          ben_elig_cvrd_dpnt_api.update_elig_cvrd_dpnt(
              p_elig_cvrd_dpnt_id       => l_pdp.elig_cvrd_dpnt_id,
              p_effective_start_date    => l_effective_start_date,
              p_effective_end_date      => l_effective_end_date,
              p_business_group_id       => l_pdp.business_group_id,
              p_per_in_ler_id           => l_pdp.per_in_ler_id,
              p_cvg_thru_dt             => p_enrt_cvg_thru_dt,
              p_ovrdn_flag              => 'Y',
              p_ovrdn_thru_dt           => p_enrt_cvg_thru_dt,
              p_object_version_number   => l_pdp.object_version_number,
              p_datetrack_mode          => 'CORRECTION',
              p_request_id              => fnd_global.conc_request_id,
              p_program_application_id  => fnd_global.prog_appl_id,
              p_program_id              => fnd_global.conc_program_id,
              p_program_update_date     => sysdate,
              p_effective_date          => p_effective_date,
              p_multi_row_actn          => FALSE);
      --
    end loop ;
    --
    for l_prv in c_prv(p_prtt_enrt_rslt_id)  loop
      --
      if l_prv.element_entry_value_id is not null then
        --
        open c_abr(l_prv.acty_base_rt_id,p_effective_date ) ;
          fetch c_abr into l_abr ;
        close c_abr ;
        --
        if l_abr.input_value_id is not null and l_abr.element_type_id is not null then
          ben_prtt_rt_val_api.update_prtt_rt_val
            (p_validate                => false
            ,p_prtt_rt_val_id          => l_prv.prtt_rt_val_id
            ,p_rt_end_dt               => p_enrt_cvg_thru_dt
            ,p_rt_ovridn_flag          => 'Y'
            ,p_rt_ovridn_thru_dt       => p_enrt_cvg_thru_dt
            ,p_person_id               => p_person_id
            ,p_acty_base_rt_id         => l_prv.acty_base_rt_id
            ,p_input_value_id          => l_abr.input_value_id
            ,p_element_type_id         => l_abr.element_type_id
            ,p_ended_per_in_ler_id     => l_prv.per_in_ler_id
            ,p_business_group_id       => l_prv.business_group_id
            ,p_object_version_number   => l_prv.object_version_number
            ,p_effective_date          => p_effective_date
            );
          --
        else
          --
          update ben_prtt_rt_val
          set rt_end_dt         = p_enrt_cvg_thru_dt,
              rt_ovridn_flag    = 'Y',
              rt_ovridn_thru_dt = p_enrt_cvg_thru_dt
          where prtt_rt_val_id = l_prv.prtt_rt_val_id ;
          --
        end if;
        --
      else
        --
        update ben_prtt_rt_val
        set rt_end_dt = p_enrt_cvg_thru_dt,
              rt_ovridn_flag    = 'Y',
              rt_ovridn_thru_dt = p_enrt_cvg_thru_dt
        where prtt_rt_val_id = l_prv.prtt_rt_val_id ;
        --
      end if;
      --
    end loop;
    --
    --Bug 2859290 End date the participant premium records also.
    --
    for l_ppe in c_ppe(p_enrt_cvg_thru_dt) loop
      --
      /*
      ben_ppe_shd.find_dt_del_modes
        (p_effective_date       => p_enrt_cvg_thru_dt,
         p_base_key_value       => l_ppe.prtt_prem_id,
         p_zap                  => l_zap,
         p_delete               => l_delete,
         p_future_change        => l_future_change,
         p_delete_next_change   => l_delete_next_change );
      */
      --
      if p_enrt_cvg_thru_dt < l_ppe.effective_start_date then
        l_ppe_dt_mode := hr_api.g_zap ;
      else
        l_ppe_dt_mode := hr_api.g_delete ;
      end if;
      --
      if l_ppe.effective_end_date > p_enrt_cvg_thru_dt then
        --
        ben_prtt_prem_api.delete_prtt_prem
        (        p_validate              => false,
                 p_prtt_prem_id          => l_ppe.prtt_prem_id,
                 p_object_version_number => l_ppe.object_version_number,
                 p_effective_date        => p_enrt_cvg_thru_dt,
                 p_effective_start_date  => l_ppe.effective_end_date,
                 p_effective_end_date    => l_ppe.effective_start_date,
                 p_datetrack_mode        => l_ppe_dt_mode
        );
        --
      end if;
      --
    end loop ;
    --
    hr_utility.set_location('Leaving '||l_package,20);
    --
  end end_rate_and_dependents;
  --
  -- Procedure reopen the rates and coverages when result is end dated.
  procedure reopen_rate_and_dependents
    (p_person_id              in number
    ,p_per_in_ler_id          in number
    ,p_prtt_enrt_rslt_id      in number
    ,p_effective_date         in date
    ) is
    --Cursor to get the ben_prtt_rt_val records with the rt_end_dt as not end of time
    --
    l_package                  varchar2(500) := 'Ben_Manage_Override.reopen_rate_and_dependents';
    --
    cursor c_prv(cv_prtt_enrt_rslt_id number) is
      select prtt_rt_val_id,
             object_version_number,
             acty_base_rt_id,
             per_in_ler_id,
             business_group_id,
             element_entry_value_id
      from ben_prtt_rt_val prv
      where prv.prtt_enrt_rslt_id = cv_prtt_enrt_rslt_id
      and   prv.prtt_rt_val_stat_cd is null
      and   prv.rt_end_dt <> to_date('31/12/4712','DD/MM/RRRR') and
      not exists ( select 'x' from
                   ben_prtt_rt_val prv1
                   where prv.rowid <> prv1.rowid
                   and   prv1.prtt_enrt_rslt_id = cv_prtt_enrt_rslt_id
                   and   prv1.acty_base_rt_id = prv.acty_base_rt_id
                   and   prv1.prtt_rt_val_stat_cd is null
                   and   prv1.rt_strt_dt > prv.rt_strt_dt ) ;
    --
    --Cursor to get the input value and the element type id from abr
    cursor c_abr(cv_acty_base_rt_id number,
                 cv_effective_date date ) is
      select input_value_id,
             element_type_id
      from   ben_acty_base_rt_f abr
      where  abr.acty_base_rt_id = cv_acty_base_rt_id
      and    cv_effective_date between abr.effective_start_date
                                   and abr.effective_end_date ;
    --
    l_abr            c_abr%ROWTYPE;
    --
    --Cursor to get the ben_elig_cvrd_dpnt_f with cvg_thru_dt as end of time
    cursor c_pdp(cv_prtt_enrt_rslt_id number,
                 cv_effective_date date) is
      select pdp.elig_cvrd_dpnt_id,
             pdp.object_version_number,
             pdp.business_group_id,
             pdp.per_in_ler_id
      from  ben_elig_cvrd_dpnt_f pdp
      where pdp.prtt_enrt_rslt_id = cv_prtt_enrt_rslt_id
      and   cv_effective_date between pdp.effective_start_date
                                  and pdp.effective_end_date
      and   pdp.cvg_thru_dt <> to_date('31/12/4712','DD/MM/RRRR')
      and not exists (
           select 'x' from ben_elig_cvrd_dpnt_f pdp1
           where pdp.elig_cvrd_dpnt_id = pdp1.elig_cvrd_dpnt_id
           and   pdp.rowid <> pdp1.rowid
           and   pdp1.effective_start_date > pdp.effective_start_date
           and   pdp1.cvg_strt_dt > pdp.cvg_thru_dt ) ;
    --

    --Bug 2859290 Ending Coverage should end the Participant premiums also.
    --
    cursor c_ppe (p_ppe_dt_to_use IN DATE) is
      select ppe.prtt_prem_id,
           ppe.object_version_number,
           ppe.effective_start_date,
           ppe.effective_end_date,
           ppe.actl_prem_id,
           ppe.business_group_id
      from ben_prtt_prem_f ppe,
           ben_per_in_ler pil
     where ppe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and pil.per_in_ler_id=ppe.per_in_ler_id
       and pil.business_group_id=ppe.business_group_id
       and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
       and p_ppe_dt_to_use between ppe.effective_start_date and ppe.effective_end_date
       and ppe.effective_end_date <> hr_api.g_eot
     UNION
    select ppe1.prtt_prem_id,
           ppe1.object_version_number,
           ppe1.effective_start_date,
           ppe1.effective_end_date,
           ppe1.actl_prem_id,
           ppe1.business_group_id
      from ben_prtt_prem_f ppe1,
           ben_per_in_ler pil
     where ppe1.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and pil.per_in_ler_id=ppe1.per_in_ler_id
       and pil.business_group_id=ppe1.business_group_id
       and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
       and ppe1.effective_start_date > p_ppe_dt_to_use
       and ppe1.effective_end_date <> hr_api.g_eot
       and not exists
           (select 1
              from ben_prtt_prem_f ppe2,
                   ben_per_in_ler pil
             where ppe2.prtt_prem_id = ppe1.prtt_prem_id
             and   ppe2.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
             and   pil.per_in_ler_id=ppe2.per_in_ler_id
             and   pil.business_group_id=ppe2.business_group_id
             and   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
             and   p_ppe_dt_to_use between
                        ppe2.effective_start_date and ppe2.effective_end_date
             and   ppe2.effective_end_date <> hr_api.g_eot );
    --
    l_ppe c_ppe%rowtype;
    l_effective_start_date   date;
    l_effective_end_date     date;
    --
    l_zap                    boolean;
    l_delete                 boolean;
    l_future_change          boolean;
    l_delete_next_change     boolean;
    --
  begin
    hr_utility.set_location('Entering '||l_package,10);
    -- End dependents
    for l_pdp in c_pdp(p_prtt_enrt_rslt_id,p_effective_date) loop
      --
          ben_elig_cvrd_dpnt_api.update_elig_cvrd_dpnt(
              p_elig_cvrd_dpnt_id       => l_pdp.elig_cvrd_dpnt_id,
              p_effective_start_date    => l_effective_start_date,
              p_effective_end_date      => l_effective_end_date,
              p_business_group_id       => l_pdp.business_group_id,
              p_per_in_ler_id           => l_pdp.per_in_ler_id,
              p_cvg_thru_dt             => to_date('31/12/4712','DD/MM/RRRR'),
              p_ovrdn_flag              => 'Y',
              p_ovrdn_thru_dt           => null,
              p_object_version_number   => l_pdp.object_version_number,
              p_datetrack_mode          => 'CORRECTION',
              p_request_id              => fnd_global.conc_request_id,
              p_program_application_id  => fnd_global.prog_appl_id,
              p_program_id              => fnd_global.conc_program_id,
              p_program_update_date     => sysdate,
              p_effective_date          => p_effective_date,
              p_multi_row_actn          => FALSE);
      --
    end loop ;
    --
    for l_prv in c_prv(p_prtt_enrt_rslt_id)  loop
      --
      if l_prv.element_entry_value_id is not null then
        --
        open c_abr(l_prv.acty_base_rt_id,p_effective_date ) ;
          fetch c_abr into l_abr ;
        close c_abr ;
        --
        if l_abr.input_value_id is not null and l_abr.element_type_id is not null then
          ben_prtt_rt_val_api.update_prtt_rt_val
            (p_validate                => false
            ,p_prtt_rt_val_id          => l_prv.prtt_rt_val_id
            ,p_rt_end_dt               => to_date('31/12/4712','DD/MM/RRRR')
            ,p_rt_ovridn_flag          => 'Y'
            ,p_rt_ovridn_thru_dt       => null
            ,p_person_id               => p_person_id
            ,p_acty_base_rt_id         => l_prv.acty_base_rt_id
            ,p_input_value_id          => l_abr.input_value_id
            ,p_element_type_id         => l_abr.element_type_id
            ,p_ended_per_in_ler_id     => l_prv.per_in_ler_id
            ,p_business_group_id       => l_prv.business_group_id
            ,p_object_version_number   => l_prv.object_version_number
            ,p_effective_date          => p_effective_date
            );
          --
        else
          --
          update ben_prtt_rt_val
          set rt_end_dt         = to_date('31/12/4712','DD/MM/RRRR'),
              rt_ovridn_flag    = 'Y',
              rt_ovridn_thru_dt = null
          where prtt_rt_val_id = l_prv.prtt_rt_val_id ;
          --
        end if;
        --
      else
        --
        update ben_prtt_rt_val
        set rt_end_dt = to_date('31/12/4712','DD/MM/RRRR'),
              rt_ovridn_flag    = 'Y',
              rt_ovridn_thru_dt = null
        where prtt_rt_val_id = l_prv.prtt_rt_val_id ;
        --
      end if;
      --
    end loop;
    --
    --Bug 2859290 reopen  the participant premium records also.
    --
    for l_ppe in c_ppe(p_effective_date) loop
      --
      ben_ppe_shd.find_dt_del_modes
        (p_effective_date       => l_ppe.effective_end_date,
         p_base_key_value       => l_ppe.prtt_prem_id,
         p_zap                  => l_zap,
         p_delete               => l_delete,
         p_future_change        => l_future_change,
         p_delete_next_change   => l_delete_next_change );
      --
      if l_future_change then
        ben_prtt_prem_api.delete_prtt_prem
          (      p_validate              => false,
                 p_prtt_prem_id          => l_ppe.prtt_prem_id,
                 p_object_version_number => l_ppe.object_version_number,
                 p_effective_date        => l_ppe.effective_end_date,
                 p_effective_start_date  => l_effective_end_date,
                 p_effective_end_date    => l_effective_start_date,
                 p_datetrack_mode        => hr_api.g_future_change
          );
        --
      end if;
      --
    end loop ;
    --
    hr_utility.set_location('Leaving '||l_package,20);
    --
  end reopen_rate_and_dependents;
  --
procedure override_prtt_prem
  (p_person_id              in number
  ,p_per_in_ler_id          in number
  ,p_pgm_id                 in number default null
  ,p_pl_id                  in number
  ,p_oipl_id                in number default null
  ,p_enrt_bnft_id           in number default null
  ,p_prtt_enrt_rslt_id      in number
  ,p_elig_per_elctbl_chc_id in number
  ,p_effective_date         in date
  ,p_business_group_id      in number
  ,p_enrt_cvg_strt_dt       in date
  ) is
     --cursors
     --
     l_package                  varchar2(500) := 'Ben_Manage_Override.override_prtt_prem';
     --
     cursor c_prem is
       select ecr.val,
              ecr.uom,
              ecr.actl_prem_id,
              pil.lf_evt_ocrd_dt,
              pil.ler_id,
              epe.elig_per_elctbl_chc_id
       from   ben_enrt_prem ecr,
              ben_per_in_ler pil,
              ben_elig_per_elctbl_chc epe
       where  epe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         and  epe.elig_per_elctbl_chc_id = ecr.elig_per_elctbl_chc_id
         and  pil.per_in_ler_id = epe.per_in_ler_id
         and  pil.per_in_ler_id = p_per_in_ler_id ;
     --
     l_prem c_prem%rowtype;
     --
     cursor c_ppe (p_prtt_enrt_rslt_id in number,
                   p_actl_prem_id      in number,
                   p_ppe_dt_to_use     in date) is
       select ppe.prtt_prem_id,
              ppe.std_prem_uom,
              ppe.std_prem_val,
              ppe.actl_prem_id,
              ppe.object_version_number,
              ppe.effective_start_date
         from ben_prtt_prem_f ppe,
              ben_per_in_ler pil
        where ppe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
          and ppe.actl_prem_id = p_actl_prem_id
          and  p_ppe_dt_to_use between
              ppe.effective_start_date and ppe.effective_end_date
          and pil.per_in_ler_id=ppe.per_in_ler_id
          and pil.business_group_id=ppe.business_group_id
          and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
          ;
     --
     l_ppe c_ppe%rowtype;
     --
        cursor c_pel is
        select pel.enrt_perd_id,
               pel.lee_rsn_id
        from   ben_pil_elctbl_chc_popl pel,
               ben_elig_per_elctbl_chc epe
        where  pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
        and    epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;

        l_pel c_pel%rowtype;
        --
        l_ppe_datetrack_mode        varchar2(30);
        l_ppe_dt_to_use             date;
        lb_correction               boolean;
        lb_update                   boolean;
        lb_update_override          boolean;
        lb_update_change_insert     boolean;
        l_enrt_cvg_strt_dt          date;
        l_enrt_cvg_strt_dt_cd       varchar2(30);
        l_enrt_cvg_strt_dt_rl       number;
        l_rt_strt_dt                date;
        l_rt_strt_dt_cd             varchar2(30);
        l_rt_strt_dt_rl             number;
        l_enrt_cvg_end_dt           date;
        l_enrt_cvg_end_dt_cd        varchar2(30);
        l_enrt_cvg_end_dt_rl        number;
        l_rt_end_dt                 date;
        l_rt_end_dt_cd              varchar2(30);
        l_rt_end_dt_rl              number;
      --
        l_datetrack_mode            varchar2(30) ;
        l_correction                boolean;
        l_update                    boolean;
        l_update_override           boolean;
        l_update_change_insert      boolean;
        l_step                      varchar2(30);
        l_effective_start_date      date;
        l_effective_end_date        date;
    begin
        hr_utility.set_location('Entering '||l_package,10);
             for l_prem in c_prem loop
                l_step := 70;
                l_ppe.prtt_prem_id:=null;
                open c_pel;
                fetch c_pel into l_pel;
                close c_pel;

                ben_determine_date.rate_and_coverage_dates
                       (p_which_dates_cd         => 'R'
                       ,p_date_mandatory_flag    => 'Y'
                       ,p_compute_dates_flag     => 'Y'
                       ,p_business_group_id      => p_business_group_id
                       ,P_PER_IN_LER_ID          => p_per_in_ler_id
                       ,P_PERSON_ID              => p_person_id
                       ,P_PGM_ID                 => p_pgm_id
                       ,P_PL_ID                  => p_pl_id
                       ,P_OIPL_ID                => p_oipl_id
                       ,P_LEE_RSN_ID             => l_pel.lee_rsn_id
                       ,P_ENRT_PERD_ID           => l_pel.enrt_perd_id
                       ,p_enrt_cvg_strt_dt       => l_enrt_cvg_strt_dt     --out
                       ,p_enrt_cvg_strt_dt_cd    => l_enrt_cvg_strt_dt_cd  --out
                       ,p_enrt_cvg_strt_dt_rl    => l_enrt_cvg_strt_dt_rl  --out
                       ,p_rt_strt_dt             => l_rt_strt_dt           --out
                       ,p_rt_strt_dt_cd          => l_rt_strt_dt_cd        --out
                       ,p_rt_strt_dt_rl          => l_rt_strt_dt_rl        --out
                       ,p_enrt_cvg_end_dt        => l_enrt_cvg_end_dt      --out
                       ,p_enrt_cvg_end_dt_cd     => l_enrt_cvg_end_dt_cd   --out
                       ,p_enrt_cvg_end_dt_rl     => l_enrt_cvg_end_dt_rl   --out
                       ,p_rt_end_dt              => l_rt_end_dt            --out
                       ,p_rt_end_dt_cd           => l_rt_end_dt_cd         --out
                       ,p_rt_end_dt_rl           => l_rt_end_dt_rl         --out
                       ,p_effective_date         => p_effective_date
                       ,p_lf_evt_ocrd_dt         => nvl(l_prem.lf_evt_ocrd_dt,p_effective_date)
                       );

                l_ppe_dt_to_use := greatest(p_enrt_cvg_strt_dt,l_rt_strt_dt);
                open c_ppe(p_prtt_enrt_rslt_id, l_prem.actl_prem_id,l_ppe_dt_to_use);
                  fetch c_ppe into l_ppe;
                close c_ppe;
                l_step := 71;
                if l_ppe.prtt_prem_id is not null then
                -- Because the benefit amount could have changed, and the premiums
                -- can be based on the benefit amount, re-calc it.  It does a recalc
                -- if the benefit amount is entered at enrollment.
                -- PPE is from prtt-prem.  prem is from enrt-prem.
                ben_PRTT_PREM_api.recalc_PRTT_PREM
                      (p_prtt_prem_id                   =>  l_ppe.prtt_prem_id
                      ,p_std_prem_uom                   =>  l_prem.uom
                      ,p_std_prem_val                   =>  l_prem.val  -- in/out
                      ,p_actl_prem_id                   =>  l_prem.actl_prem_id
                      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
                      ,p_per_in_ler_id                  =>  p_per_in_ler_id
                      ,p_ler_id                         =>  l_prem.ler_id
                      ,p_lf_evt_ocrd_dt                 =>  l_prem.lf_evt_ocrd_dt
                      ,p_elig_per_elctbl_chc_id         =>  l_prem.elig_per_elctbl_chc_id
                      ,p_enrt_bnft_id                   =>  p_enrt_bnft_id
                      ,p_business_group_id              =>  p_business_group_id
                      ,p_effective_date                 =>  p_effective_date
                       -- bof FONM
                      ,p_enrt_cvg_strt_dt               => l_enrt_cvg_strt_dt
                      ,p_rt_strt_dt                     => l_rt_strt_dt
                       -- eof FONM
                      );

                  l_step := 72;
                  --
                  -- Find the valid datetrack modes.
                  --
                  dt_api.find_dt_upd_modes
                       (p_effective_date       => l_ppe_dt_to_use,
                        p_base_table_name      => 'BEN_PRTT_PREM_F',
                        p_base_key_column      => 'prtt_prem_id',
                        p_base_key_value       => l_ppe.prtt_prem_id,
                        p_correction           => l_correction,
                        p_update               => l_update,
                        p_update_override      => l_update_override,
                        p_update_change_insert => l_update_change_insert);

                  if l_update_override then
                  --
                    l_ppe_datetrack_mode := hr_api.g_update_override;
                  --
                  elsif l_update then
                  --
                    l_ppe_datetrack_mode := hr_api.g_update;
                  --
                  else
                  --
                    l_ppe_datetrack_mode := hr_api.g_correction;
                  end if;
                  --
                  ben_prtt_prem_api.update_prtt_prem
                     ( p_validate                => FALSE
                      ,p_prtt_prem_id            => l_ppe.prtt_prem_id
                      ,p_effective_start_date    => l_effective_start_date
                      ,p_effective_end_date      => l_effective_end_date
                      ,p_std_prem_uom            => l_prem.uom
                      ,p_std_prem_val            => l_prem.val
                      ,p_actl_prem_id            => l_prem.actl_prem_id
                      ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
                      ,p_per_in_ler_id           => p_per_in_ler_id
                      ,p_business_group_id       => p_business_group_id
                      ,p_object_version_number   => l_ppe.object_version_number
                      ,p_request_id              => fnd_global.conc_request_id
                      ,p_program_application_id  => fnd_global.prog_appl_id
                      ,p_program_id              => fnd_global.conc_program_id
                      ,p_program_update_date     => sysdate
                      ,p_effective_date           => l_ppe_dt_to_use
                      ,p_datetrack_mode          => l_ppe_datetrack_mode
                  );
                else
                  ben_PRTT_PREM_api.recalc_PRTT_PREM
                      (p_prtt_prem_id                   =>  null
                      ,p_std_prem_uom                   =>  l_prem.uom
                      ,p_std_prem_val                   =>  l_prem.val  -- in/out
                      ,p_actl_prem_id                   =>  l_prem.actl_prem_id
                      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
                      ,p_per_in_ler_id                  =>  p_per_in_ler_id
                      ,p_ler_id                         =>  l_prem.ler_id
                      ,p_lf_evt_ocrd_dt                 =>  l_prem.lf_evt_ocrd_dt
                      ,p_elig_per_elctbl_chc_id         =>  l_prem.elig_per_elctbl_chc_id
                      ,p_enrt_bnft_id                   =>  p_enrt_bnft_id
                      ,p_business_group_id              =>  p_business_group_id
                      ,p_effective_date                 =>  p_effective_date
                      -- bof FONM
                      ,p_enrt_cvg_strt_dt               => l_enrt_cvg_strt_dt
                      ,p_rt_strt_dt                     => l_rt_strt_dt
                       -- eof FONM
                      );
                  l_step := 130;
                  ben_prtt_prem_api.create_prtt_prem
                   ( p_validate                => FALSE
                    ,p_prtt_prem_id            => l_ppe.prtt_prem_id
                    ,p_effective_start_date    => l_effective_start_date
                    ,p_effective_end_date      => l_effective_end_date
                    ,p_std_prem_uom            => l_prem.uom
                    ,p_std_prem_val            => l_prem.val
                    ,p_actl_prem_id            => l_prem.actl_prem_id
                    ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
                    ,p_per_in_ler_id           => p_per_in_ler_id
                    ,p_business_group_id       => p_business_group_id
                    ,p_object_version_number   => l_ppe.object_version_number
                    ,p_request_id              => fnd_global.conc_request_id
                    ,p_program_application_id  => fnd_global.prog_appl_id
                    ,p_program_id              => fnd_global.conc_program_id
                    ,p_program_update_date     => sysdate
                    ,p_effective_date          => l_ppe_dt_to_use
                  );
                  --
                end if;
             end loop;
      hr_utility.set_location('Leaving '||l_package,20);
  end override_prtt_prem ;
  --
  procedure correct_prtt_enrt_rslt
    (p_prtt_enrt_rslt_id      in number
    ,p_enrt_cvg_strt_dt       in date     default hr_api.g_date
    ,p_enrt_cvg_thru_dt       in date     default hr_api.g_date
    ,p_bnft_amt               in number   default hr_api.g_number
    ,p_enrt_ovridn_flag       in varchar2 default hr_api.g_varchar2
    ,p_enrt_ovrid_thru_dt     in date     default hr_api.g_date
    ,p_enrt_ovrid_rsn_cd      in varchar2 default hr_api.g_varchar2
    ,p_orgnl_enrt_dt          in date     default hr_api.g_date
    ,p_effective_date         in date
    ) is
      --
      cursor c_pen(p_prtt_enrt_rslt_id number) is
        select *
          from ben_prtt_enrt_rslt_f pen
         where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
           and pen.prtt_enrt_rslt_stat_cd IS NULL
        order by pen.effective_start_date;
      --
      l_effective_date        date;
      l_object_version_number number;
      l_dummy_date            date;
      l_desired_datetrack_mode varchar2(30) := hr_api.g_correction;
      l_datetrack_mode        varchar2(30);
      --
    begin
      --
      for l_pen in c_pen( p_prtt_enrt_rslt_id ) loop
        --
        if p_effective_date < l_pen.effective_start_date OR
           p_effective_date > l_pen.effective_end_date THEN
          --
          ben_prtt_enrt_result_api.get_ben_pen_upd_dt_mode
                     (p_effective_date         => l_pen.effective_start_date
                     ,p_base_key_value         => p_prtt_enrt_rslt_id
                     ,P_desired_datetrack_mode => l_desired_datetrack_mode
                     ,P_datetrack_allow        => l_datetrack_mode
                     );
          --
          hr_utility.set_location('l_datetrack_mode '||l_datetrack_mode,10);
          l_object_version_number := l_pen.object_version_number;
          --
          ben_prtt_enrt_result_api.update_prtt_enrt_result
            (p_validate                 => FALSE,
             p_prtt_enrt_rslt_id        => p_prtt_enrt_rslt_id,
             p_effective_start_date     => l_dummy_date,
             p_effective_end_date       => l_dummy_date,
             p_business_group_id        => l_pen.business_group_id,
             p_enrt_cvg_strt_dt         => p_enrt_cvg_strt_dt,
          --    p_enrt_cvg_thru_dt         => p_enrt_cvg_thru_dt, This needs to be updated for the latest only
             p_bnft_amt                 => p_bnft_amt,
             p_enrt_ovridn_flag         => p_enrt_ovridn_flag,
             p_enrt_ovrid_thru_dt       => p_enrt_ovrid_thru_dt,
             p_enrt_ovrid_rsn_cd        => p_enrt_ovrid_rsn_cd,
             p_orgnl_enrt_dt            => p_orgnl_enrt_dt,
             p_object_version_number    => l_object_version_number,
             p_effective_date           => l_pen.effective_start_date,
             p_datetrack_mode           => l_datetrack_mode,
             p_multi_row_validate       => FALSE,
             p_program_application_id   => fnd_global.prog_appl_id,
             p_program_id               => fnd_global.conc_program_id,
             p_request_id               => fnd_global.conc_request_id,
             p_program_update_date      => sysdate);
             --
        end if;
        --
      end loop;
      --
  end correct_prtt_enrt_rslt;
  --
procedure override_debit_ledger_entry
  (p_validate                 in boolean default false
  ,p_calculate_only_mode      in boolean default false
  ,p_person_id                in number
  ,p_per_in_ler_id            in number
  ,p_elig_per_elctbl_chc_id   in number
  ,p_prtt_enrt_rslt_id        in number
  ,p_decr_bnft_prvdr_pool_id  in number
  ,p_acty_base_rt_id          in number
  ,p_prtt_rt_val_id           in number
  ,p_enrt_mthd_cd             in varchar2
  ,p_val                      in number
  ,p_bnft_prvdd_ldgr_id       in out nocopy number
  ,p_business_group_id        in number
  ,p_effective_date           in date
  --
  ,p_bpl_used_val             out nocopy number
  ) is
   --
   l_package              varchar2(500) := 'Ben_Manage_Override.override_debit_ledger_entry';
   l_epe_rec              ben_epe_shd.g_rec_type;
   l_ecr_rec              ben_ecr_shd.g_rec_type;
   l_prtt_enrt_rslt_id    number;
   l_prtt_rt_val_id       number;
   l_pgm_id               number;
   --
   l_effective_start_date date;
   l_effective_end_date date;
   l_object_version_number number;
   l_val number;
   l_datetrack_mode varchar2(30);
   --
   l_correction             boolean := TRUE;
   l_update                 boolean := FALSE;
   l_update_override        boolean := FALSE;
   l_update_change_insert   boolean := FALSE;
   --
   l_per_in_ler_id   number;
   l_used_val        number := 0;

   cursor c_old_ledger is
     select      bpl.bnft_prvdd_ldgr_id,
                 bpl.per_in_ler_id,
                 bpl.used_val,
                 bpl.object_version_number,
                 bpl.effective_start_date
     from        ben_bnft_prvdd_ldgr_f bpl,
                 ben_per_in_ler pil
     where       bpl.bnft_prvdr_pool_id=l_ecr_rec.decr_bnft_prvdr_pool_id
         and     bpl.business_group_id=l_epe_rec.business_group_id
         and     bpl.acty_base_rt_id=l_ecr_rec.acty_base_rt_id
         and     bpl.prtt_enrt_rslt_id=p_prtt_enrt_rslt_id
         and     bpl.used_val is not null
         and     p_effective_date between bpl.effective_start_date
                                      and bpl.effective_end_date
         and pil.per_in_ler_id=bpl.per_in_ler_id
         and pil.business_group_id=bpl.business_group_id
         and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') ;
    --
    cursor c_prtt_rt_val
    is
      select rt_val
      from   ben_prtt_rt_val
      where  prtt_rt_val_id=l_ecr_rec.prtt_rt_val_id;
    --
  begin
    --
    hr_utility.set_location('Entering:'|| l_package, 15);
    --
    l_epe_rec.elig_per_elctbl_chc_id:= p_elig_per_elctbl_chc_id;
    l_epe_rec.prtt_enrt_rslt_id     := p_prtt_enrt_rslt_id;
    l_epe_rec.business_group_id     := p_business_group_id;
    l_epe_rec.per_in_ler_id         := p_per_in_ler_id;
    --
    l_ecr_rec.decr_bnft_prvdr_pool_id := p_decr_bnft_prvdr_pool_id;
    l_ecr_rec.acty_base_rt_id         := p_acty_base_rt_id;
    l_ecr_rec.prtt_rt_val_id          := p_prtt_rt_val_id;
    l_ecr_rec.val                     := p_val;
    --
    if l_ecr_rec.prtt_rt_val_id is null then
      l_val:=l_ecr_rec.val;
    else
      open c_prtt_rt_val ;
      fetch c_prtt_rt_val into l_val;
      if c_prtt_rt_val%notfound then
         l_val:=l_ecr_rec.val;
      end if;
      close c_prtt_rt_val;
    end if;
    --
    open c_old_ledger;
    fetch c_old_ledger into
      p_bnft_prvdd_ldgr_id,
      l_per_in_ler_id,
      l_used_val,
      l_object_version_number,
      l_effective_start_date;
      --
    if not p_calculate_only_mode then
      --
      if c_old_ledger%notfound then
         ben_Benefit_Prvdd_Ledger_api.create_Benefit_Prvdd_Ledger (
             p_bnft_prvdd_ldgr_id           => p_bnft_prvdd_ldgr_id
            ,p_effective_start_date         => l_effective_start_date
            ,p_effective_end_date           => l_effective_end_date
            ,p_prtt_ro_of_unusd_amt_flag    => 'N'
            ,p_frftd_val                    => null
            ,p_prvdd_val                    => null
            ,p_used_val                     => l_val
            ,p_bnft_prvdr_pool_id           => l_ecr_rec.decr_bnft_prvdr_pool_id
            ,p_acty_base_rt_id              => l_ecr_rec.acty_base_rt_id
            ,p_per_in_ler_id                => l_epe_rec.per_in_ler_id
            ,p_enrt_mthd_cd                 => p_enrt_mthd_cd
            ,p_person_id                    => p_person_id
            ,p_prtt_enrt_rslt_id            => p_prtt_enrt_rslt_id
            ,p_business_group_id            => l_epe_rec.business_group_id
            ,p_object_version_number        => l_object_version_number
            ,p_cash_recd_val                => null
            ,p_effective_date               => p_effective_date
          );
          hr_utility.set_location('CREATED LEDGER ID='||to_char(p_bnft_prvdd_ldgr_id),41);
      else
        --
        DT_Api.Find_DT_Upd_Modes(
                    p_effective_date        => p_effective_date,
                    p_base_table_name       => 'BEN_BNFT_PRVDD_LDGR_F',
                    p_base_key_column       =>  'BNFT_PRVDD_LDGR_ID',
                    p_base_key_value        => p_bnft_prvdd_ldgr_id,
                    p_correction            => l_correction,
                    p_update                => l_update,
                    p_update_override       => l_update_override,
                    p_update_change_insert  => l_update_change_insert);
        --
        if l_update_override or l_update_change_insert then
          l_datetrack_mode := 'UPDATE_CHANGE_INSERT';
        elsif l_update then
          l_datetrack_mode := 'UPDATE';
        elsif l_correction then
          l_datetrack_mode := 'CORRECTION';
        end if;
        --
        if l_per_in_ler_id <> l_epe_rec.per_in_ler_id or
           l_used_val <> l_val then
           --
           hr_utility.set_location('UPDATING LEDGER ID='||to_char(p_bnft_prvdd_ldgr_id),51);
           --
           ben_Benefit_Prvdd_Ledger_api.update_Benefit_Prvdd_Ledger (
                p_bnft_prvdd_ldgr_id           => p_bnft_prvdd_ldgr_id
               ,p_effective_start_date         => l_effective_start_date
               ,p_effective_end_date           => l_effective_end_date
               ,p_frftd_val                    => null
               ,p_prvdd_val                    => null
               ,p_used_val                     => l_val
               ,p_bnft_prvdr_pool_id           => l_ecr_rec.decr_bnft_prvdr_pool_id
               ,p_acty_base_rt_id              => l_ecr_rec.acty_base_rt_id
               ,p_per_in_ler_id                => l_epe_rec.per_in_ler_id
               ,p_prtt_enrt_rslt_id            => p_prtt_enrt_rslt_id
               ,p_business_group_id            => l_epe_rec.business_group_id
               ,p_object_version_number        => l_object_version_number
               ,p_cash_recd_val                => null
               ,p_effective_date               => p_effective_date
               ,p_datetrack_mode               => l_datetrack_mode
              );
             hr_utility.set_location('UPDATED LEDGER ID='||to_char(p_bnft_prvdd_ldgr_id),55);
        end if;
      end if;
      close c_old_ledger;
    end if;
    --
  end override_debit_ledger_entry ;
  --
procedure override_prtt_rt_val
  (
   p_validate                       in boolean    default false
  ,p_prtt_rt_val_id                 in  number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_input_value_id                 in  number    default hr_api.g_number
  ,p_element_type_id                in  number    default hr_api.g_number
  ,p_enrt_rt_id                     in  number    default hr_api.g_number
  ,p_rt_strt_dt                     in  date      default hr_api.g_date
  ,p_rt_end_dt                      in  date      default hr_api.g_date
  ,p_rt_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_tx_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_ordr_num			    in number     default hr_api.g_number
  ,p_acty_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_mlt_cd                         in  varchar2  default hr_api.g_varchar2
  ,p_acty_ref_perd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_rt_val                         in  number    default hr_api.g_number
  ,p_ann_rt_val                     in  number    default hr_api.g_number
  ,p_cmcd_rt_val                    in  number    default hr_api.g_number
  ,p_cmcd_ref_perd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_bnft_rt_typ_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_dsply_on_enrt_flag             in  varchar2  default hr_api.g_varchar2
  ,p_rt_ovridn_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_rt_ovridn_thru_dt              in  date      default hr_api.g_date
  ,p_elctns_made_dt                 in  date      default hr_api.g_date
  ,p_prtt_rt_val_stat_cd            in  varchar2  default hr_api.g_varchar2
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_cvg_amt_calc_mthd_id           in  number    default hr_api.g_number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_element_entry_value_id         in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_ended_per_in_ler_id            in  number    default hr_api.g_number
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_prtt_reimbmt_rqst_id           in  number    default hr_api.g_number
  ,p_prtt_rmt_aprvd_fr_pymt_id      in  number    default hr_api.g_number
  ,p_pp_in_yr_used_num              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_prv_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_pk_id_table_name               in  varchar2  default hr_api.g_varchar2
  ,p_pk_id                          in  number    default hr_api.g_number
  ,p_no_end_element                 in  boolean   default false
  ,p_old_rt_strt_dt                 in  date      default hr_api.g_date
  ,p_old_rt_end_dt                  in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  ) is
    --
    l_object_version_number number := p_object_version_number ;
    l_recurring_rt          boolean default false ;
    l_rt_end_dt             date := p_rt_end_dt;
    l_rslt_suspended        varchar2(30) := 'N';
    l_dummy_number          number;
    l_effective_start_date  date;
    l_effective_end_date    date;
    l_delete_warning        boolean;
    --
    cursor c_current_prv is
       select prv.*
        from ben_prtt_rt_val prv
       where prv.prtt_rt_val_id = p_prtt_rt_val_id;
    --
    l_current_prv  c_current_prv%ROWTYPE;
    --
    cursor c_zap_future_ee
        (p_element_type_id in number
        ,p_person_id       in number
        ,p_effective_date  in date
        ) is
        select distinct
           ele.element_entry_id,
           ele.effective_start_date,
           ele.effective_end_date,
           ele.object_version_number,
           ele.creator_type,
           ele.creator_id
     from  pay_element_entries_f ele,
           pay_element_links_f elk,
           pay_element_types_f elt,
           per_all_assignments_f asg
    where  ele.effective_start_date = (select min(ele2.effective_start_date)
                                       from pay_element_entries_f ele2
                                       where ele2.element_entry_id
                                    =  ele.element_entry_id)
      and  ele.effective_start_date > p_effective_date
      and  asg.person_id = p_person_id
      and  ele.assignment_id = asg.assignment_id
      and  ele.effective_start_date between asg.effective_start_date
                                        and asg.effective_end_date
      and  nvl(ele.creator_id,-1) <> p_prtt_enrt_rslt_id
      and  ele.entry_type = 'E'
      and  ele.element_link_id = elk.element_link_id
      and  ele.effective_start_date between elk.effective_start_date
                                        and  elk.effective_end_date
      and  elk.element_type_id = p_element_type_id
      and  elt.element_type_id = elk.element_type_id
      and  elk.effective_start_date between elt.effective_start_date
                                        and  elt.effective_end_date
    order by ele.effective_start_date desc;
    --
    l_zap_future_ee c_zap_future_ee%rowtype;
    --
    cursor c_future_prv(p_person_id number,
                        p_rt_strt_dt date,
                        p_element_type_id number ) is
       select distinct
              prv.prtt_rt_val_id,
              prv.prtt_enrt_rslt_id,
              prv.rt_val,
              prv.cmcd_rt_val,
              prv.ann_rt_val,
              prv.rt_strt_dt,
              abr.acty_base_rt_id,
              abr.element_type_id,
              abr.input_value_id,
              prv.business_group_id,
              prv.acty_ref_perd_cd,
              prv.object_version_number
         from ben_prtt_rt_val prv,
              ben_acty_base_rt_f abr,
              ben_prtt_enrt_rslt_f pen
        where prv.prtt_rt_val_id  <> p_prtt_rt_val_id
          and prv.prtt_rt_val_stat_cd IS NULL
          and prv.rt_strt_dt > p_rt_strt_dt
          and abr.element_type_id = p_element_type_id
          and prv.acty_base_rt_id = abr.acty_base_rt_id
          and prv.rt_strt_dt between abr.effective_start_date
                                 and abr.effective_end_date
          and pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
          and pen.person_id         = p_person_id
          and pen.prtt_enrt_rslt_stat_cd IS NULL
        order by prv.rt_strt_dt ;
    --
    l_future_prv c_future_prv%rowtype;
    --
  begin
    --
    --Check Overlapping rates
    --TEMP 9999
    open c_current_prv ;
      fetch c_current_prv into l_current_prv;
    close c_current_prv;
    --
    --
    ben_prtt_rt_val_api.get_non_recurring_end_dt
       (p_rt_end_dt         => l_rt_end_dt
       ,p_rt_strt_dt        => p_rt_strt_dt
       ,p_acty_base_rt_id   => p_acty_base_rt_id
       ,p_business_group_id => p_business_group_id
       ,p_recurring_rt      => l_recurring_rt
       ,p_effective_date    => p_effective_date
       ) ;
    --
    if l_recurring_rt then
      --
      ben_prtt_rt_val_api.chk_overlapping_dates
        (p_acty_base_rt_id        => p_acty_base_rt_id
        ,p_prtt_rt_val_id         => p_prtt_rt_val_id
        ,p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
        ,p_new_rt_strt_dt         => p_rt_strt_dt
        ,p_new_rt_end_dt          => l_rt_end_dt );
         --
    end if;
    --
    ben_prv_upd.upd
    (
     p_prtt_rt_val_id                => p_prtt_rt_val_id
    ,p_enrt_rt_id                    => p_enrt_rt_id
    ,p_rt_strt_dt                    => p_rt_strt_dt
    ,p_rt_end_dt                     => l_rt_end_dt
    ,p_rt_typ_cd                     => p_rt_typ_cd
    ,p_tx_typ_cd                     => p_tx_typ_cd
    ,p_ordr_num                      => p_ordr_num
    ,p_acty_typ_cd                   => p_acty_typ_cd
    ,p_mlt_cd                        => p_mlt_cd
    ,p_acty_ref_perd_cd              => p_acty_ref_perd_cd
    ,p_rt_val                        => p_rt_val
    ,p_ann_rt_val                    => p_ann_rt_val
    ,p_cmcd_rt_val                   => p_cmcd_rt_val
    ,p_cmcd_ref_perd_cd              => p_cmcd_ref_perd_cd
    ,p_bnft_rt_typ_cd                => p_bnft_rt_typ_cd
    ,p_dsply_on_enrt_flag            => p_dsply_on_enrt_flag
    ,p_rt_ovridn_flag                => p_rt_ovridn_flag
    ,p_rt_ovridn_thru_dt             => p_rt_ovridn_thru_dt
    ,p_elctns_made_dt                => p_elctns_made_dt
    ,p_prtt_rt_val_stat_cd           => p_prtt_rt_val_stat_cd
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_cvg_amt_calc_mthd_id          => p_cvg_amt_calc_mthd_id
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_element_entry_value_id        => p_element_entry_value_id
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_ended_per_in_ler_id           => p_ended_per_in_ler_id
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_prtt_reimbmt_rqst_id          => p_prtt_reimbmt_rqst_id
    ,p_prtt_rmt_aprvd_fr_pymt_id     => p_prtt_rmt_aprvd_fr_pymt_id
    ,p_pp_in_yr_used_num             => p_pp_in_yr_used_num
    ,p_business_group_id             => p_business_group_id
    ,p_prv_attribute_category        => p_prv_attribute_category
    ,p_prv_attribute1                => p_prv_attribute1
    ,p_prv_attribute2                => p_prv_attribute2
    ,p_prv_attribute3                => p_prv_attribute3
    ,p_prv_attribute4                => p_prv_attribute4
    ,p_prv_attribute5                => p_prv_attribute5
    ,p_prv_attribute6                => p_prv_attribute6
    ,p_prv_attribute7                => p_prv_attribute7
    ,p_prv_attribute8                => p_prv_attribute8
    ,p_prv_attribute9                => p_prv_attribute9
    ,p_prv_attribute10               => p_prv_attribute10
    ,p_prv_attribute11               => p_prv_attribute11
    ,p_prv_attribute12               => p_prv_attribute12
    ,p_prv_attribute13               => p_prv_attribute13
    ,p_prv_attribute14               => p_prv_attribute14
    ,p_prv_attribute15               => p_prv_attribute15
    ,p_prv_attribute16               => p_prv_attribute16
    ,p_prv_attribute17               => p_prv_attribute17
    ,p_prv_attribute18               => p_prv_attribute18
    ,p_prv_attribute19               => p_prv_attribute19
    ,p_prv_attribute20               => p_prv_attribute20
    ,p_prv_attribute21               => p_prv_attribute21
    ,p_prv_attribute22               => p_prv_attribute22
    ,p_prv_attribute23               => p_prv_attribute23
    ,p_prv_attribute24               => p_prv_attribute24
    ,p_prv_attribute25               => p_prv_attribute25
    ,p_prv_attribute26               => p_prv_attribute26
    ,p_prv_attribute27               => p_prv_attribute27
    ,p_prv_attribute28               => p_prv_attribute28
    ,p_prv_attribute29               => p_prv_attribute29
    ,p_prv_attribute30               => p_prv_attribute30
    ,p_pk_id_table_name              => p_pk_id_table_name
    ,p_pk_id                         => p_pk_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
     );
  --
     --Delete all future element entries
     if l_recurring_rt Then
       --
       open c_zap_future_ee(p_element_type_id,
                            p_person_id,
                            p_effective_date);
       loop
         fetch c_zap_future_ee into l_zap_future_ee;
         if c_zap_future_ee%notfound then
            exit;
         end if;
         --
         hr_utility.set_location('future ee:'||l_zap_future_ee.element_entry_id,6);
         hr_utility.set_location('creator type:'||l_zap_future_ee.creator_type,6);
         hr_utility.set_location('creator id:'||l_zap_future_ee.creator_id,6);
         --
         if l_zap_future_ee.creator_type ='F' and l_zap_future_ee.creator_id is not null then
           --
           py_element_entry_api.delete_element_entry
             (p_validate              =>p_validate
             ,p_datetrack_delete_mode =>hr_api.g_zap
             ,p_effective_date        =>l_zap_future_ee.effective_end_date
             ,p_element_entry_id      =>l_zap_future_ee.element_entry_id
             ,p_object_version_number =>l_zap_future_ee.object_version_number
             ,p_effective_start_date  =>l_effective_start_date
             ,p_effective_end_date    =>l_effective_end_date
             ,p_delete_warning        =>l_delete_warning);
             --
         end if;
         --
       end loop;
       close c_zap_future_ee;
       --
     end if;
     --
     l_rslt_suspended := ben_prtt_rt_val_api.result_is_suspended
                        (p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id,
                         p_person_id         => p_person_id,
                         p_business_group_id => p_business_group_id,
                         p_effective_date    => p_effective_date) ;
     --
     ben_element_entry.end_enrollment_element
       (p_business_group_id        => p_business_group_id
       ,p_person_id                => p_person_id
       ,p_enrt_rslt_id             => p_prtt_enrt_rslt_id
       ,p_acty_ref_perd            => p_acty_ref_perd_cd
       ,p_element_link_id          => null
       ,p_prtt_rt_val_id           => p_prtt_rt_val_id
       ,p_rt_end_date              => p_old_rt_strt_dt -1
       ,p_effective_date           => p_old_rt_strt_dt
       ,p_dt_delete_mode           => null
       ,p_acty_base_rt_id          => p_acty_base_rt_id
       ,p_amt                      => p_rt_val
       );
     --
     if l_rslt_suspended = 'N' then
       --
       ben_element_entry.create_enrollment_element
        (p_business_group_id        => p_business_group_id
        ,p_prtt_rt_val_id           => p_prtt_rt_val_id
        ,p_person_id                => p_person_id
        ,p_acty_ref_perd            => p_acty_ref_perd_cd
        ,p_acty_base_rt_id          => p_acty_base_rt_id
        ,p_enrt_rslt_id             => p_prtt_enrt_rslt_id
        ,p_rt_start_date            => p_rt_strt_dt
        ,p_rt                       => p_rt_val
        ,p_cmncd_rt                 => p_cmcd_rt_val
        ,p_ann_rt                   => p_ann_rt_val
        ,p_prv_object_version_number=> l_object_version_number
        ,p_effective_date           => p_effective_date
        ,p_eev_screen_entry_value   => l_dummy_number
        ,p_element_entry_value_id   => l_dummy_number
         );
        --
        ben_prv_shd.lck
        (
        p_prtt_rt_val_id                 => p_prtt_rt_val_id
       ,p_object_version_number          => l_object_version_number
        );
        --
     end if;
     --
     --Even the amount is changed, we need to end the element properly if required
     --
     if p_rt_end_dt < p_rt_strt_dt or
       (l_rt_end_dt <> hr_api.g_eot and
       l_rt_end_dt <> p_old_rt_end_dt ) or
       (l_rt_end_dt <> hr_api.g_eot and (
        l_current_prv.rt_val <> p_rt_val or
        l_current_prv.ann_rt_val <> p_ann_rt_val or
        l_current_prv.cmcd_rt_val <> p_cmcd_rt_val ))then
       --
       ben_element_entry.end_enrollment_element
       (p_business_group_id        => p_business_group_id
       ,p_person_id                => p_person_id
       ,p_enrt_rslt_id             => p_prtt_enrt_rslt_id
       ,p_acty_ref_perd            => p_acty_ref_perd_cd
       ,p_element_link_id          => null
       ,p_prtt_rt_val_id           => p_prtt_rt_val_id
       ,p_rt_end_date              => l_rt_end_dt
       ,p_effective_date           => p_effective_date
       ,p_dt_delete_mode           => null
       ,p_acty_base_rt_id          => p_acty_base_rt_id
       ,p_amt                      => p_rt_val
       );
       --
     end if;
     --
     p_object_version_number := l_object_version_number ;
     --
     --Now reprocess the future element entries
     open c_future_prv(p_person_id, p_rt_strt_dt, p_element_type_id) ;
     loop
       fetch c_future_prv into l_future_prv;
       if c_future_prv%notfound then
         exit;
       end if;
       --
       l_rslt_suspended := ben_prtt_rt_val_api.result_is_suspended
                        (p_prtt_enrt_rslt_id => l_future_prv.prtt_enrt_rslt_id,
                         p_person_id         => p_person_id,
                         p_business_group_id => p_business_group_id,
                         p_effective_date    => l_future_prv.rt_strt_dt ) ;
       --
       if l_rslt_suspended = 'N' then
         --
         ben_element_entry.create_enrollment_element
          (p_business_group_id        => p_business_group_id
          ,p_prtt_rt_val_id           => l_future_prv.prtt_rt_val_id
          ,p_person_id                => p_person_id
          ,p_acty_ref_perd            => l_future_prv.acty_ref_perd_cd
          ,p_acty_base_rt_id          => l_future_prv.acty_base_rt_id
          ,p_enrt_rslt_id             => l_future_prv.prtt_enrt_rslt_id
          ,p_rt_start_date            => l_future_prv.rt_strt_dt
          ,p_rt                       => l_future_prv.rt_val
          ,p_cmncd_rt                 => l_future_prv.cmcd_rt_val
          ,p_ann_rt                   => l_future_prv.ann_rt_val
          ,p_prv_object_version_number=> l_future_prv.object_version_number
          ,p_effective_date           => l_future_prv.rt_strt_dt
          ,p_eev_screen_entry_value   => l_dummy_number
          ,p_element_entry_value_id   => l_dummy_number
           );
            --
       end if;
       --
     end loop;
     close c_future_prv;
     --
end override_prtt_rt_val ;
--
procedure override_certifications
    (p_prtt_enrt_rslt_id      in number
    ,p_ctfn_rqd_flag          in varchar2 default hr_api.g_varchar2
    ,p_effective_date         in date
    ,p_business_group_id      in number
    ) is
      --
      l_effective_date        date;
      l_object_version_number number;
      l_dummy_date            date;
      l_desired_datetrack_mode varchar2(30) := hr_api.g_correction;
      l_datetrack_mode        varchar2(30);
      l_pea_effective_start_date date;
      l_pea_effective_end_date   date;
      --
      cursor c_pen(p_prtt_enrt_rslt_id number) is
        select object_version_number
          from ben_prtt_enrt_rslt_f pen
         where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
           and pen.sspndd_flag = 'Y'
           and pen.prtt_enrt_rslt_stat_cd IS NULL
           and p_effective_date between pen.effective_start_date
                                    and pen.effective_end_date;
      --
      cursor c_pea(p_prtt_enrt_rslt_id number) is
      select
          pea.prtt_enrt_actn_id
         ,pea.actn_typ_id
         ,pea.rqd_flag
         ,pea.business_group_id
         ,pea.object_version_number pea_object_version_number
         ,pen.object_version_number pen_object_version_number
         ,pea.effective_start_date pea_effective_date
      from ben_prtt_enrt_actn_f pea,
            ben_prtt_enrt_rslt_f pen
      where
          pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and p_effective_date between pen.effective_start_date and
                                   pen.effective_end_date
      and pen.prtt_enrt_rslt_stat_cd is null
      and pen.prtt_enrt_rslt_id = pea.prtt_enrt_rslt_id
      and pea.rqd_flag = 'Y' ;
      --
      l_pea  c_pea%rowtype;
      --
    begin
      --Make the certifications optional
      open c_pen(p_prtt_enrt_rslt_id);
      fetch c_pen into l_object_version_number;
      if c_pen%found then
        --
        open c_pea(p_prtt_enrt_rslt_id) ;
        loop
          --
          fetch c_pea into l_pea ;
          if c_pea%notfound then
            exit ;
          end if;
          --
          hr_utility.set_location('Updating the Required Flag to No ',5);
          ben_prtt_enrt_actn_api.update_prtt_enrt_actn
            (p_prtt_enrt_actn_id          => l_pea.prtt_enrt_actn_id
            ,p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
            ,p_rslt_object_version_number => l_pea.pen_object_version_number
            ,p_actn_typ_id                => l_pea.actn_typ_id
            ,p_rqd_flag                   => 'N'
            ,p_effective_date             => l_pea.pea_effective_date
            ,p_post_rslt_flag             => 'N' -- 99999 p_post_rslt_flag
            ,p_business_group_id          => p_business_group_id
            ,p_effective_start_date       => l_pea_effective_start_date
            ,p_effective_end_date         => l_pea_effective_end_date
            ,p_object_version_number      => l_pea.pea_object_version_number
            ,p_datetrack_mode             => hr_api.g_correction
          );
          hr_utility.set_location('After ben_prtt_enrt_actn_api.update_prtt_enrt_actn ',20);
          --
        end loop ;
        close c_pea ;
        --
        --Unsuspend the enrollment
        --
        ben_sspndd_enrollment.unsuspend_enrollment
          (p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
          ,p_effective_date        => p_effective_date
          ,p_post_rslt_flag        => 'N'
          ,p_business_group_id     => p_business_group_id
          ,p_object_version_number => l_object_version_number
          ,p_datetrack_mode        => hr_api.g_correction
          ,p_called_from           => 'BENEOPEH' );
        --
      end if;
      close c_pen;
      --
  end override_certifications;
  --
end ben_manage_override;

/

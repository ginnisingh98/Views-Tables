--------------------------------------------------------
--  DDL for Package Body BEN_EXT_FLCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_FLCR" AS
/* $Header: benxflcr.pkb 120.1 2006/04/20 15:48:05 tjesumic noship $ */
g_package  varchar2(33)	:= '  ben_ext_flcr.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< init_detl_globals >------------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure init_detl_globals IS
--
  l_proc               varchar2(72) := g_package||'init_detl_globals';
--
Begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
   --
    ben_ext_person.g_flex_pgm_id                 := null;
    ben_ext_person.g_flex_pgm_name               := null;
    ben_ext_person.g_flex_pl_id                  := null;
    ben_ext_person.g_flex_pl_name                := null;
    ben_ext_person.g_flex_pl_typ_id              := null;
    ben_ext_person.g_flex_pl_typ_name            := null;
    ben_ext_person.g_flex_opt_id                 := null;
    ben_ext_person.g_flex_opt_name               := null;
    ben_ext_person.g_flex_cmbn_plip_id           := null;
    ben_ext_person.g_flex_cmbn_plip_name         := null;
    ben_ext_person.g_flex_cmbn_ptip_id           := null;
    ben_ext_person.g_flex_cmbn_ptip_name         := null;
    ben_ext_person.g_flex_cmbn_ptip_opt_id       := null;
    ben_ext_person.g_flex_cmbn_ptip_opt_name     := null;
    ben_ext_person.g_flex_amt                    := null;
    ben_ext_person.g_flex_currency               := null;
    ben_ext_person.g_flex_bnft_pool_id           := null;
    ben_ext_person.g_flex_bnft_pool_name         := null;
  --
  hr_utility.set_location('Exiting'||l_proc, 15);
  --
End init_detl_globals;
--
-- ----------------------------------------------------------------------------
-- |------< main >-----------------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure main
    (                        p_person_id          in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_chg_evt_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date) is
   --
   l_proc             varchar2(72) := g_package||'main';
   --
   l_include          varchar2(1) := 'Y';
   --
   cursor c_elig(p_person_id number) is
   select
       pler.ler_id                          ler_id,
       pler.per_in_ler_stat_cd              per_in_ler_stat_cd,
       pler.lf_evt_ocrd_dt                  lf_evt_ocrd_dt,
       pler.ntfn_dt                         ntfn_dt,
       echc.enrt_cvg_strt_dt                enrt_cvg_strt_dt,
       echc.yr_perd_id                      yr_perd_id,
       echc.per_in_ler_id                   per_in_ler_id,
       echc.prtt_enrt_rslt_id               prtt_enrt_rslt_id,
       echc.last_update_date                last_update_date,
       echc.pl_id                           pl_id,
       pl.name                              pl_name,
       ptp.name                             pl_typ_name,
       echc.elig_per_elctbl_chc_id          elig_per_elctbl_chc_id,
       echc.oipl_id                         opt_id,
       echc.pl_typ_id                       pl_typ_id,
       opt.name                             opt_name,
       ppopl.uom                            uom,
       nvl(ecr.dflt_val,ecr.val)            flex_amt,
       echc.pgm_id          	            program_id,
       pgm.name          	            program_name,
       echc.cmbn_plip_id                    cmbn_plip_id,
       cmbn_plip.name                       cmbn_plip_name,
       echc.cmbn_ptip_id                    cmbn_ptip_id,
       cmbn_ptip.name                       cmbn_ptip_name,
       echc.cmbn_ptip_opt_id                cmbn_ptip_opt_id,
       cmbn_ptip_opt.name                   cmbn_ptip_opt_name,
       pool.bnft_prvdr_pool_id              pool_id,
       pool.name                            pool_name
   from
       ben_per_in_ler          pler,
       ben_elig_per_elctbl_chc echc,
       ben_enrt_rt             ecr,
       ben_pil_elctbl_chc_popl ppopl,
       ben_opt_f               opt,
       ben_pl_f                pl,
       ben_plip_f              plip,
       ben_oipl_f              oipl,
       ben_pgm_f               pgm,
       ben_pl_typ_f            ptp,
       ben_cmbn_plip_f         cmbn_plip,
       ben_cmbn_ptip_f         cmbn_ptip,
       ben_cmbn_ptip_opt_f     cmbn_ptip_opt,
       ben_bnft_prvdr_pool_f   pool
       where
       pler.person_id = p_person_id
       and pler.per_in_ler_id = echc.per_in_ler_id
       and pler.per_in_ler_id = ppopl.per_in_ler_id -- 3662774: Performance fix: Added this join.
       and echc.elig_per_elctbl_chc_id = ecr.elig_per_elctbl_chc_id
       and echc.bnft_prvdr_pool_id = pool.bnft_prvdr_pool_id(+)
       and ecr.rt_usg_cd = 'FLXCR'
       -- 3662774: Performance fix: Removed the outer join
       -- and echc.pil_elctbl_chc_popl_id(+) = ppopl.pil_elctbl_chc_popl_id
       and echc.pil_elctbl_chc_popl_id = ppopl.pil_elctbl_chc_popl_id
        -- 3662774: Performance fix: end;
       and nvl(echc.pgm_id,-1) = pgm.pgm_id(+)
       and nvl(echc.pl_id,-1) = pl.pl_id(+)
       and nvl(oipl.opt_id,-1) = opt.opt_id(+)
       and nvl(echc.oipl_id,-1) = oipl.oipl_id(+)
       and nvl(echc.plip_id,-1) = plip.plip_id(+)
       and pl.pl_typ_id = ptp.pl_typ_id (+)
       and nvl(echc.cmbn_plip_id,-1) = cmbn_plip.cmbn_plip_id(+)
       and nvl(echc.cmbn_ptip_id,-1) = cmbn_ptip.cmbn_ptip_id(+)
       and nvl(echc.cmbn_ptip_opt_id,-1) = cmbn_ptip_opt.cmbn_ptip_opt_id(+)
       and p_effective_date between nvl(pl.effective_start_date,p_effective_date)
            and nvl(pl.effective_end_date ,p_effective_date)
       and p_effective_date between nvl(opt.effective_start_date,p_effective_date)
            and nvl(opt.effective_end_date ,p_effective_date)
       and p_effective_date between nvl(plip.effective_start_date,p_effective_date)
            and nvl(plip.effective_end_date ,p_effective_date)
       and p_effective_date between nvl(oipl.effective_start_date,p_effective_date)
            and nvl(oipl.effective_end_date ,p_effective_date)
       and p_effective_date between nvl(ptp.effective_start_date,p_effective_date)
            and nvl(ptp.effective_end_date ,p_effective_date)
       and p_effective_date between nvl(cmbn_plip.effective_start_date,p_effective_date)
            and nvl(cmbn_plip.effective_end_date ,p_effective_date)
       and p_effective_date between nvl(cmbn_ptip.effective_start_date,p_effective_date)
            and nvl(cmbn_ptip.effective_end_date ,p_effective_date)
       and p_effective_date between nvl(pool.effective_start_date,p_effective_date)
            and nvl(pool.effective_end_date ,p_effective_date)
       and p_effective_date between nvl(cmbn_ptip_opt.effective_start_date,p_effective_date)
            and nvl(cmbn_ptip_opt.effective_end_date ,p_effective_date)
       and p_effective_date between nvl(pgm.effective_start_date,p_effective_date)
            and nvl(pgm.effective_end_date ,p_effective_date) ;


   Begin
   --
   hr_utility.set_location('Entering'||l_proc, 5);
   --
   init_detl_globals;
   --
        FOR elig IN c_elig(p_person_id) LOOP
        --
           l_include := 'Y';
        --

        ben_ext_evaluate_inclusion.evaluate_eligibility_incl
                    (p_elct_pl_id              => elig.pl_id,
                     p_elct_enrt_strt_dt       => elig.enrt_cvg_strt_dt,
                     p_elct_yrprd_id           => elig.yr_perd_id,
                     p_elct_pgm_id             => elig.program_id,
                     p_elct_pl_typ_id          => elig.pl_typ_id,
                     p_elct_last_upd_dt        => elig.last_update_date,
                     p_elct_per_in_ler_id      => elig.per_in_ler_id,
                     p_elct_ler_id             => elig.ler_id,
                     p_elct_per_in_ler_stat_cd => elig.per_in_ler_stat_cd,
                     p_elct_lf_evt_ocrd_dt     => elig.lf_evt_ocrd_dt,
                     p_elct_ntfn_dt            => elig.ntfn_dt,
                     p_prtt_enrt_rslt_id       => elig.prtt_enrt_rslt_id,
                     p_effective_date          => p_effective_date,
                     p_include => l_include
                     );
        --
        IF l_include = 'Y' THEN

       -- assign eligibility info to global variables
       --
       ben_ext_person.g_flex_pgm_name               := elig.program_name;
       ben_ext_person.g_flex_pl_name                := elig.pl_name;
       ben_ext_person.g_flex_pl_typ_name            := elig.pl_typ_name;
       ben_ext_person.g_flex_opt_name               := elig.opt_name;
       ben_ext_person.g_flex_cmbn_plip_name         := elig.cmbn_plip_name;
       ben_ext_person.g_flex_cmbn_ptip_name         := elig.cmbn_ptip_name;
       ben_ext_person.g_flex_cmbn_ptip_opt_name     := elig.cmbn_ptip_opt_name;
       ben_ext_person.g_flex_amt                    := elig.flex_amt;
       ben_ext_person.g_flex_currency               := elig.uom;
       ben_ext_person.g_flex_opt_id                 := elig.opt_id;
       ben_ext_person.g_flex_pgm_id                 := elig.program_id;
       ben_ext_person.g_flex_pl_id                  := elig.pl_id;
       ben_ext_person.g_flex_pl_typ_id              := elig.pl_typ_id;
       ben_ext_person.g_flex_cmbn_plip_id           := elig.cmbn_plip_id;
       ben_ext_person.g_flex_cmbn_ptip_id           := elig.cmbn_ptip_id;
       ben_ext_person.g_flex_cmbn_ptip_opt_id       := elig.cmbn_ptip_opt_id;
       ben_ext_person.g_flex_bnft_pool_id           := elig.pool_id;
       ben_ext_person.g_flex_bnft_pool_name         := elig.pool_name;

       --
       -- format and write
       --
       ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                    p_ext_file_id       => p_ext_file_id,
                                    p_data_typ_cd       => p_data_typ_cd,
                                    p_ext_typ_cd        => p_ext_typ_cd,
                                    p_rcd_typ_cd        => 'D',  --detail
                                    p_low_lvl_cd        => 'F',  --flex credit?
                                    p_person_id         => p_person_id,
                                    p_chg_evt_cd        => null,
                                    p_business_group_id => p_business_group_id,
                                    p_effective_date    => p_effective_date
                                    );
     --
     END IF;

   END LOOP;
   --
   hr_utility.set_location('Exiting'||l_proc, 15);
   --
   -- Enter further code below as specified in the Package spec.

--
  END;
END;

/

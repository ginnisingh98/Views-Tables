--------------------------------------------------------
--  DDL for Package Body BEN_DETERMINE_ELCT_CHC_FLX_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DETERMINE_ELCT_CHC_FLX_IMP" as
/* $Header: benflxii.pkb 120.0 2005/05/28 09:01:21 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA	  	           |
|			        All rights reserved.			           |
+==============================================================================+
Name:
    Determine Electable Choices for Flex Credits and Imputed Income.

Purpose:
    Determine Electable Choices for Flex Credits and Imputed Income.
    Flex Credits are at the pgm, plip, ptip,cmbn_plip,cmbn_ptip,cmbn_ptip_opt,
    oiplip levels. Imputed income
    is at the plan level.
    Called from benmngle.pkb once per person.

History:
        Date             Who        Version    What?
        ----             ---        -------    -----
        7 May 98        Ty Hayden  110.0      Created.
       16 Jun 98        T Guy      110.1      Removed other exception.
       23 Jun 98        Ty Hayden  110.2      Changed everything!
       30 Jun 98        Ty Hayden  110.3      Remove writing of Flex Cred Plan
                                              and Imp Inc Plan.  They are now
                                              written in Enrt Rqmts.
       09 Oct 98        G Perry    115.2      Fixed error messages and
                                              formatted correctly.
       24 Oct 98        G Perry    115.3      Fixed value of g_package for
                                              debugging purposes.
       29 Oct 98        lmcdonal   115.5      Pass yr-perd-id to create choice.
                                              Add per-in-ler, enrt_perd_strt_dt,
                                              lf-evt-ocrd-dt and BG as input parms.
       18 Jan 99        G Perry    115.7      LED V ED
       29 Jan 99        S Das      115.8      Added codes for cmbn comp objects.
       09 Mar 99        G Perry    115.9      IS to AS.
       23 Aug 99        mhoyes     115.10   - Added new trace messages.
                                            - Replaced +0s.
       23 Aug 99        shdas      115.11     Added codes for plip_ordr_num,ptip_ordr_num
       07 Sep 99        shdas      115.12     Added codes for cmbn ptip opt and oiplip.
       15 Nov 99        mhoyes     115.13   - Added new trace messages.
       08 Mar 00        lmcdonal   115.14     Made some performance changes.  Fixed
                                              OIPLIP so that it would work. Add
                                              use of new comp-lvl-cds.
       31-Mar-00        mmogel     115.15     I changed the message number from
                                              91382 to 91832 in the message name
                                              BEN_91382_PACKAGE_PARAM_NULL
       07-Nov-00        mhoyes     115.16   - Referenced electable choice
                                              performance APIs.
       12-Apr-01        ikasire    115.17     bug 1285336  changed the cursor c_bpp6
       23-Jul-01        ikasire    115.18     bug 1832643 to handle the case where
                                              the benefit pool is defined only at
                                              program level and the flex credits
                                              are defined at different levels
       13-Aug-01        ikasire    115.19     Bug 1832643 also fixed the above
                                              issue for cmbn_ptip and cmbn_plip
       25-Jan-02        ikasire    115.20     Bug 2189693 Enhancement to allow
                                              Flex credits and Benefit Pools at
                                              different level see bug for more details.
       04-Feb-02        pbodla     115.21     Bug 2200783 : c_bpp1 : Removed the
                                              pgm_pool_flag check as it do
                                              not have any significance and similar
                                              check is not available at other levels.
       05-mar-02       tjesumic    115.22     bug 2251364 pgm_id is stored for all levels
                                              of benefit_pool. so in c_pp1 (pgm_level)
                                              all other lelvel id  are validated for null
       30-Apr-02       kmahendr    115.23     Added token to message 91832.
       01-May-02       ikasire     115.24     Bug 2200139 Override Enhancements. Added new parameter
                                              p_called_from with 'B' for benmngle and 'O'
                                              for override. If called from override, added
                                              conditions not to create the duplicate electable
                                              choices.added new cursors to determine this at all
                                              levels.
      15-nov-04       kmahendr     115.25     Added parameter p_mode and codes for Unrest.
                                              enh
*/
--------------------------------------------------------------------------------
g_package varchar2(80) := 'ben_determine_elct_chc_flx_imp';
--
PROCEDURE main
  (p_person_id         IN number,
   p_effective_date    IN date,
   p_enrt_perd_strt_dt in date,
   p_per_in_ler_id     in number,
   p_lf_evt_ocrd_dt    in date,
   p_business_group_id in number,
   p_called_from       in varchar2 default 'B', -- B for Benmngle, O for Override
   p_mode              in varchar2
  ) IS
  --
  l_proc                   varchar2(80) := g_package||'.main';
  l_pgm_id                 number;
  l_plip_id                number;
  l_ptip_id                number;
  l_pl_id                  number;
  l_oipl_id                number;
  l_oiplip_id              number;
  l_elig_per_elctbl_chc_id number;
  l_object_version_number  number;
  l_bnft_prvdr_pool_id     number;
  l_save_pgm_id            number;
  l_found_pgm              varchar2(1) := 'N';
  l_cmbn_ptip_id           number;
  l_cmbn_plip_id           number;
  l_cmbn_ptip_opt_id       number;

  --  Used for PGM
  cursor c_epe_pgm is
    select distinct
           epe.pgm_id
    from   ben_elig_per_elctbl_chc epe, ben_pgm_f pgm
    where  p_per_in_ler_id = epe.per_in_ler_id
    and    pgm.pgm_id = epe.pgm_id
    and    pgm.pgm_typ_cd in ('COBRAFLX', 'FLEX', 'FPC')
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between pgm.effective_start_date
           and     pgm.effective_end_date
    and    nvl(epe.request_id,-1) = fnd_global.conc_request_id
    order by 1;

  --  Used for PLIP and Combo PLIP
  cursor c_epe_plip is
    select distinct epe.pgm_id, epe.plip_id, epe.plip_ordr_num,
           epe.pl_id, epe.pl_typ_id, epe.ptip_id,  epe.ptip_ordr_num
    from   ben_elig_per_elctbl_chc epe, ben_pgm_f pgm
    where  p_per_in_ler_id = epe.per_in_ler_id
    and    epe.plip_id is not null
    and    pgm.pgm_id = epe.pgm_id
    and    pgm.pgm_typ_cd in ('COBRAFLX', 'FLEX', 'FPC')
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between pgm.effective_start_date
           and     pgm.effective_end_date
    and    nvl(epe.request_id,-1) = fnd_global.conc_request_id
    order by 1, 2;

  --  Used for PTIP and Combo PTIP
  cursor c_epe_ptip is
    select distinct epe.pgm_id, epe.ptip_id,epe.ptip_ordr_num, epe.pl_typ_id
    from   ben_elig_per_elctbl_chc epe, ben_pgm_f pgm
    where  p_per_in_ler_id = epe.per_in_ler_id
    and    epe.ptip_id is not null
    and    pgm.pgm_id = epe.pgm_id
    and    pgm.pgm_typ_cd in ('COBRAFLX', 'FLEX', 'FPC')
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between pgm.effective_start_date
           and     pgm.effective_end_date
    and    nvl(epe.request_id,-1) = fnd_global.conc_request_id
    order by 1, 2;

  -- Used for OIPLIP and Combo PTIP Option
  cursor c_epe_oipl is
    select distinct epe.pgm_id,epe.plip_id, epe.ptip_id,epe.oipl_id,epe.oipl_ordr_num,
           epe.oiplip_id, epe.pl_typ_id, epe.pl_id, epe.plip_ordr_num, epe.ptip_ordr_num
    from   ben_elig_per_elctbl_chc epe, ben_pgm_f pgm
    where  p_per_in_ler_id = epe.per_in_ler_id
    and    epe.oiplip_id is not null
    and    pgm.pgm_id = epe.pgm_id
    and    pgm.pgm_typ_cd in ('COBRAFLX', 'FLEX', 'FPC')
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between pgm.effective_start_date
           and     pgm.effective_end_date
    and    nvl(epe.request_id,-1) = fnd_global.conc_request_id
    order by 1, 2,3,4;

  -- Get Flex Credits at PGM level
  cursor c_abr1 is
    select abr.acty_base_rt_id
    from   ben_acty_base_rt_f abr
    where  abr.acty_base_rt_stat_cd = 'A'
    and    abr.rt_usg_cd in ('FLXCR')
    and    abr.pgm_id = l_pgm_id
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between abr.effective_start_date
           and     abr.effective_end_date;
  l_abr1 c_abr1%rowtype;

  -- Get Flex Credits at PLIP level
  cursor c_abr2 is
    select abr.acty_base_rt_id
    from   ben_acty_base_rt_f abr
    where  abr.acty_base_rt_stat_cd = 'A'
    and    abr.rt_usg_cd in ('FLXCR')
    and    abr.plip_id = l_plip_id
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cmbn_plip_id is null;
  l_abr2 c_abr2%rowtype;


  -- Get Flex Credits at PTIP level
  cursor c_abr3 is
    select abr.acty_base_rt_id
    from   ben_acty_base_rt_f abr
    where  abr.acty_base_rt_stat_cd = 'A'
    and    abr.rt_usg_cd in ('FLXCR')
    and    abr.ptip_id = l_ptip_id
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cmbn_ptip_id is null
    and    abr.cmbn_ptip_opt_id is null;

  l_abr3 c_abr3%rowtype;


  -- Get Flex Credits at COMBO PTIP level
/*
  cursor c_abr4 is
    select abr.acty_base_rt_id
    from   ben_acty_base_rt_f abr
    where  abr.acty_base_rt_stat_cd = 'A'
    and    abr.rt_usg_cd in ('FLXCR')
    and    abr.cmbn_ptip_id = l_cmbn_ptip_id
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cmbn_ptip_opt_id is null
    and    abr.ptip_id is null;
*/

  cursor c_abr4 is
    select abr.acty_base_rt_id, abr.cmbn_ptip_id
    from   ben_acty_base_rt_f abr,
           ben_cmbn_ptip_f cptip,
           ben_ptip_f ptip
    where  abr.acty_base_rt_stat_cd = 'A'
    and    abr.rt_usg_cd in ('FLXCR')
    --and    abr.cmbn_ptip_id = l_cmbn_ptip_id
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cmbn_ptip_id  = cptip.cmbn_ptip_id
    and    abr.cmbn_ptip_opt_id is null
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between cptip.effective_start_date
           and     cptip.effective_end_date
    and    cptip.cmbn_ptip_id = ptip.cmbn_ptip_id
    and    cptip.pgm_id = ptip.pgm_id
    and    ptip.pgm_id = l_pgm_id
    and    ptip.ptip_id = l_ptip_id
    and    abr.ptip_id is null;

  --
  l_abr4 c_abr4%rowtype;

  -- Get Flex Credits at COMBO PLIP level
/*
  cursor c_abr5 is
    select abr.acty_base_rt_id
    from   ben_acty_base_rt_f abr
    where  abr.acty_base_rt_stat_cd = 'A'
    and    abr.rt_usg_cd in ('FLXCR')
    and    abr.cmbn_plip_id = l_cmbn_plip_id
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between abr.effective_start_date
           and     abr.effective_end_date;
*/
  cursor c_abr5 is
    select abr.acty_base_rt_id, abr.cmbn_plip_id
    from   ben_acty_base_rt_f abr,
           ben_plip_f plip,
           ben_cmbn_plip_f cplip
    where  abr.acty_base_rt_stat_cd = 'A'
    and    abr.rt_usg_cd in ('FLXCR')
    --and    abr.cmbn_plip_id = l_cmbn_plip_id
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between abr.effective_start_date
           and     abr.effective_end_date
    and   abr.cmbn_plip_id  =  cplip.cmbn_plip_id
    and   nvl(p_lf_evt_ocrd_dt,p_effective_date)
          between cplip.effective_start_date
          and     cplip.effective_end_date
    and   cplip.cmbn_plip_id = plip.cmbn_plip_id
    and   cplip.pgm_id       = plip.pgm_id
    and   plip.plip_id       = l_plip_id
    and   plip.pgm_id        = l_pgm_id ;

  --

  l_abr5 c_abr5%rowtype;
/*
  -- Get Flex Credits at COMBO PTIP OPT level
  cursor c_abr6 is
    select abr.acty_base_rt_id
    from   ben_acty_base_rt_f abr
    where  abr.acty_base_rt_stat_cd = 'A'
    and    abr.rt_usg_cd in ('FLXCR')
    and    abr.cmbn_ptip_opt_id = l_cmbn_ptip_opt_id
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cmbn_ptip_id is null
    and    abr.ptip_id is null;
*/
 -- Bug 1832643 Commented the above code not to look at the
 -- l_cmbn_ptip_opt_id derived from c_bpp6 since we may have
 -- cases where benefit pool defined at program level and
 -- the flex credits defined at different levels.
 --
  cursor c_abr6 is
    select abr.acty_base_rt_id, abr.cmbn_ptip_opt_id
    from   ben_acty_base_rt_f abr,
           ben_optip_f otp,
           ben_oipl_f oipl
    where  abr.acty_base_rt_stat_cd = 'A'
    and    abr.rt_usg_cd in ('FLXCR')
    and    abr.cmbn_ptip_opt_id = otp.cmbn_ptip_opt_id
    and    otp.ptip_id = l_ptip_id
    and    otp.pgm_id  = l_pgm_id
    and    oipl.oipl_id = l_oipl_id
    and    oipl.opt_id = otp.opt_id
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between abr.effective_start_date
           and     abr.effective_end_date
    and    abr.cmbn_ptip_id is null
    and    abr.ptip_id is null;

  l_abr6 c_abr6%rowtype;

  -- Get Flex Credits at OIPLIP level
  cursor c_abr7 is
    select abr.acty_base_rt_id
    from   ben_acty_base_rt_f abr
    where  abr.acty_base_rt_stat_cd = 'A'
    and    abr.rt_usg_cd in ('FLXCR')
    and    abr.oiplip_id = l_oiplip_id
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between abr.effective_start_date
           and     abr.effective_end_date;

  l_abr7 c_abr7%rowtype;

  -- Process Program Level Flex Credits
  cursor c_bpp1 is
     select bpp.bnft_prvdr_pool_id
     from   ben_bnft_prvdr_pool_f bpp
     where  bpp.pgm_id = l_pgm_id
     --bug 2251364 if the other pool created first
     --- this will create problem , pgm_id stored for
     --- all the levels
     and  cmbn_ptip_id is null
     and  cmbn_ptip_opt_id is null
     and  oiplip_id         is null
     and  cmbn_plip_id      is null
     and  plip_id           is null
     and  ptip_id           is null
     --
     -- Bug 2200783 : Removed as the flag do not have any significance and
     -- similar check is not available at other levels.
     --
     -- and    bpp.pgm_pool_flag = 'Y'
     and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
            between bpp.effective_start_date
            and     bpp.effective_end_date
     and    rownum = 1;

-- ?? these cursors should probably not look at rows where pgm-flag is on because
-- they would have been handled by previous cursor?

  -- Process PLIP Level Flex Credits
  cursor c_bpp2 is
     select bpp.bnft_prvdr_pool_id
     from   ben_bnft_prvdr_pool_f bpp
     where  bpp.plip_id = l_plip_id
     and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
            between bpp.effective_start_date
            and     bpp.effective_end_date
     and    rownum = 1
    and    bpp.oiplip_id is null
    and    bpp.cmbn_plip_id is null;

  -- Process PTIP Level Flex Credits
  cursor c_bpp3 is
    select bpp.bnft_prvdr_pool_id
    from   ben_bnft_prvdr_pool_f bpp
    where  bpp.ptip_id = l_ptip_id
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between bpp.effective_start_date
           and     bpp.effective_end_date
    and    rownum = 1
    and    bpp.cmbn_ptip_id is null
    and    bpp.cmbn_ptip_opt_id is null;


  -- Process Combo PTIP Level Flex Credits
  cursor c_bpp4 is
    select bpp.bnft_prvdr_pool_id, bpp.cmbn_ptip_id
    from   ben_bnft_prvdr_pool_f bpp,ben_cmbn_ptip_f cbp,ben_ptip_f ctp
    where  ctp.ptip_id = l_ptip_id
    and    ctp.cmbn_ptip_id = cbp.cmbn_ptip_id
    and    bpp.cmbn_ptip_id = cbp.cmbn_ptip_id
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between bpp.effective_start_date
           and     bpp.effective_end_date
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between cbp.effective_start_date
           and     cbp.effective_end_date
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between ctp.effective_start_date
           and     ctp.effective_end_date
    and    rownum = 1
    and    bpp.ptip_id is null
    and    bpp.cmbn_ptip_opt_id is null;

  -- Process Combo PLIP Level Flex Credits
  cursor c_bpp5 is
     select bpp.bnft_prvdr_pool_id, bpp.cmbn_plip_id
     from   ben_bnft_prvdr_pool_f bpp,ben_cmbn_plip_f cpl, ben_plip_f cpp
     where  cpp.plip_id = l_plip_id
     and    cpp.cmbn_plip_id = cpl.cmbn_plip_id
     and    bpp.cmbn_plip_id = cpl.cmbn_plip_id
     and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
            between bpp.effective_start_date
            and     bpp.effective_end_date
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between cpl.effective_start_date
           and     cpl.effective_end_date
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between cpp.effective_start_date
           and     cpp.effective_end_date
     and    rownum = 1
    and    bpp.oiplip_id is null
    and    bpp.plip_id is null;

 -- Process Combo PTIP Option Level Flex Credits
/* bug 1285336
 cursor c_bpp6 is
    select bpp.bnft_prvdr_pool_id, bpp.cmbn_ptip_opt_id
    from   ben_bnft_prvdr_pool_f bpp,ben_cmbn_ptip_opt_f cpt, ben_opt_f opt,
           ben_oipl_f oipl
    where  oipl.oipl_id = l_oipl_id
    and    opt.opt_id = oipl.opt_id
    and    cpt.ptip_id = l_ptip_id
    and    opt.cmbn_ptip_opt_id = cpt.cmbn_ptip_opt_id
    and    bpp.cmbn_ptip_opt_id = cpt.cmbn_ptip_opt_id
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between bpp.effective_start_date
           and     bpp.effective_end_date
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between cpt.effective_start_date
           and     cpt.effective_end_date
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between opt.effective_start_date
           and     opt.effective_end_date
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between oipl.effective_start_date
           and     oipl.effective_end_date
    and    rownum = 1
    and    bpp.ptip_id is null
    and    bpp.cmbn_ptip_id is null;
*/

 cursor c_bpp6 is
    select bpp.bnft_prvdr_pool_id,
           bpp.cmbn_ptip_opt_id
    from   ben_bnft_prvdr_pool_f bpp,
           ben_cmbn_ptip_opt_f cpt,
           ben_optip_f otp,
           ben_oipl_f oipl
    where  oipl.oipl_id = l_oipl_id
    and    otp.opt_id = oipl.opt_id
    and    otp.ptip_id = l_ptip_id
    and    otp.cmbn_ptip_opt_id = cpt.cmbn_ptip_opt_id
    and    bpp.cmbn_ptip_opt_id = cpt.cmbn_ptip_opt_id
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between bpp.effective_start_date
           and     bpp.effective_end_date
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between cpt.effective_start_date
           and     cpt.effective_end_date
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between otp.effective_start_date
           and     otp.effective_end_date
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between oipl.effective_start_date
           and     oipl.effective_end_date
    and    rownum = 1
    and    bpp.ptip_id is null
    and    bpp.cmbn_ptip_id is null;

 -- Process OIPLIP Level Flex Credits
 cursor c_bpp7 is
     select bpp.bnft_prvdr_pool_id
     from   ben_bnft_prvdr_pool_f bpp
     where  bpp.oiplip_id = l_oiplip_id
     and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
            between bpp.effective_start_date
            and     bpp.effective_end_date
     and    rownum = 1
    and    bpp.plip_id is null
    and    bpp.cmbn_plip_id is null;


  cursor yr_perd_for_pgm (p_pgm_id in number) is
    select yp.yr_perd_id
    from   ben_yr_perd yp,
           ben_popl_yr_perd pop
    where  pop.pgm_id = p_pgm_id
    and    pop.yr_perd_id = yp.yr_perd_id
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
           between yp.start_date
           and     yp.end_date
    and    yp.business_group_id = p_business_group_id;
  --
  -- Override Cursors
  cursor c_chk_pgm (c_pgm_id in number) is
    select 'x'
    from   ben_elig_per_elctbl_chc epe
    where  epe.per_in_ler_id = p_per_in_ler_id
    and    epe.pgm_id        = c_pgm_id
    and    epe.comp_lvl_cd   = 'PGM'
    and    epe.bnft_prvdr_pool_id is not null ;
  -- PLIP
  cursor c_chk_plip (c_plip_id in number) is
    select 'x'
    from   ben_elig_per_elctbl_chc epe
    where  epe.per_in_ler_id = p_per_in_ler_id
    and    epe.plip_id       = c_plip_id
    and    epe.comp_lvl_cd   = 'PLIP'
    and    epe.bnft_prvdr_pool_id is not null ;
  -- 'CPLIP'
  cursor c_chk_cplip (c_cmbn_plip_id in number) is
    select 'x'
    from   ben_elig_per_elctbl_chc epe
    where  epe.per_in_ler_id = p_per_in_ler_id
    and    epe.cmbn_plip_id  = c_cmbn_plip_id
    and    epe.comp_lvl_cd   = 'CPLIP'
    and    epe.bnft_prvdr_pool_id is not null ;
  -- 'PTIP'
  cursor c_chk_ptip (c_ptip_id in number) is
    select 'x'
    from   ben_elig_per_elctbl_chc epe
    where  epe.per_in_ler_id = p_per_in_ler_id
    and    epe.ptip_id  = c_ptip_id
    and    epe.comp_lvl_cd   = 'PTIP'
    and    epe.bnft_prvdr_pool_id is not null ;
  -- 'CPTIP'
  cursor c_chk_cptip (c_cmbn_ptip_id in number) is
    select 'x'
    from   ben_elig_per_elctbl_chc epe
    where  epe.per_in_ler_id = p_per_in_ler_id
    and    epe.cmbn_ptip_id  = c_cmbn_ptip_id
    and    epe.comp_lvl_cd   = 'CPTIP'
    and    epe.bnft_prvdr_pool_id is not null ;
  --  'OIPLIP'
  cursor c_chk_oiplip (c_oiplip_id in number) is
    select 'x'
    from   ben_elig_per_elctbl_chc epe
    where  epe.per_in_ler_id = p_per_in_ler_id
    and    epe.oiplip_id  = c_oiplip_id
    and    epe.comp_lvl_cd   = 'OIPLIP'
    and    epe.bnft_prvdr_pool_id is not null ;
  -- 'CPTIPOPT'
  cursor c_chk_cptipopt (c_cmbn_ptip_opt_id in number) is
    select 'x'
    from   ben_elig_per_elctbl_chc epe
    where  epe.per_in_ler_id = p_per_in_ler_id
    and    epe.cmbn_ptip_opt_id  = c_cmbn_ptip_opt_id
    and    epe.comp_lvl_cd   = 'CPTIPOPT'
    and    epe.bnft_prvdr_pool_id is not null ;

  l_yr_perd_id number;
  type l_cmbn_list is table of number index by binary_integer;
  l_wrote_cmbn l_cmbn_list;
  l_num_cmbn   number := 0;
  l_num_ptip_cmbn   number := 0;
  l_num_plip_cmbn   number := 0;
  l_num_optip_cmbn   number := 0;
  l_write_this_one varchar2(1);
  l_dummy_id  number ;
  l_wrote_ptip_cmbn l_cmbn_list;
  l_wrote_plip_cmbn l_cmbn_list;
  l_wrote_optip_cmbn l_cmbn_list;
  l_exists          varchar2(30);
  l_create_override varchar2(30) := 'N' ;
  --
BEGIN
  -- This module creates choices from which we want to hang flex credit rates
  -- We hang flex credit rates of chcs with comp_lvls of:
  -- PGM, PTIP, PLIP, OIPLIP, CPTIP (Combo ptip), CPLIP, CPTIPOPT (Combo ptip/opt)
  -- Regular rates should not hang off these choices.
  hr_utility.set_location('Entering: '||l_proc,10);
  -- clear out table of combination records that were written.
  l_wrote_cmbn.delete;
  if p_effective_date is null then
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_proc);
    fnd_message.set_token('PROC','Flex Credit');
    fnd_message.set_token('PARAM','p_effective_date');
    fnd_message.raise_error;
  elsif p_person_id is null then
    fnd_message.set_name('BEN','BEN_91832_PACKAGE_PARAM_NULL');
    fnd_message.set_token('PACKAGE',l_proc);
    fnd_message.set_token('PROC','Flex Credit');
    fnd_message.set_token('PARAM','p_person_id');
    fnd_message.raise_error;
  end if;
  ---------------------------------------------------------------------
  -- Process Program Level Flex Credits
  ---------------------------------------------------------------------
  for l_epe_pgm in c_epe_pgm loop
    -- We found a choice with a flex program type on it.
    l_found_pgm := 'Y';
    l_pgm_id := l_epe_pgm.pgm_id;
    --
    --Override Changes
    --
    l_create_override := 'N' ;
    if p_called_from = 'O' then
      open c_chk_pgm (l_pgm_id);
      fetch c_chk_pgm into l_exists ;
      if c_chk_pgm%notfound then
        l_create_override := 'Y' ;
      end if ;
      close c_chk_pgm;
    end if ;
    --
    open yr_perd_for_pgm (l_epe_pgm.pgm_id);
    fetch yr_perd_for_pgm into l_yr_perd_id;
    close yr_perd_for_pgm;
    --
    if nvl(p_called_from,'B') <> 'O'
       or ( p_called_from = 'O' and l_create_override = 'Y' ) then
    --
    -- End Override Changes
    --
      open c_bpp1;
      fetch c_bpp1 into l_bnft_prvdr_pool_id;
      open c_abr1;
      fetch c_abr1 into l_abr1;
      if c_bpp1%found and c_abr1%found then
            --
        if p_mode in ('U','R') then
           --
           l_elig_per_elctbl_chc_id := null;
           l_elig_per_elctbl_chc_id := ben_manage_unres_life_events.epe_exists
                  (p_per_in_ler_id => p_per_in_ler_id,
                   p_pgm_id => l_epe_pgm.pgm_id,
                   p_bnft_prvdr_pool_id  => l_bnft_prvdr_pool_id,
                   p_comp_lvl_cd =>'PGM');
                   --
        end if;
        --
        if l_elig_per_elctbl_chc_id is not null and p_mode in ('U','R') then
           --
           ben_manage_unres_life_events.update_elig_per_elctbl_choice
             (p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id,
               p_elctbl_flag             => 'N',
               p_comp_lvl_cd             => 'PGM',
               p_pgm_id                  => l_epe_pgm.pgm_id,
               p_bnft_prvdr_pool_id      => l_bnft_prvdr_pool_id,
               p_per_in_ler_id           => p_per_in_ler_id,
               p_yr_perd_id              => l_yr_perd_id,
               p_business_group_id       => p_business_group_id,
               p_effective_date          => p_effective_date);
        else
            -- Write Program Level Flex Credit Distribution Record
            --
            hr_utility.set_location('Write Pgm Lvl Flx Cr Distr Rec ',20);
            ben_elig_per_elc_chc_api.create_perf_elig_per_elc_chc
              (p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id,
               p_elctbl_flag             => 'N',
               p_comp_lvl_cd             => 'PGM',
               p_pgm_id                  => l_epe_pgm.pgm_id,
               p_bnft_prvdr_pool_id      => l_bnft_prvdr_pool_id,
               p_per_in_ler_id           => p_per_in_ler_id,
               p_yr_perd_id              => l_yr_perd_id,
               p_business_group_id       => p_business_group_id,
               p_program_application_id  => fnd_global.prog_appl_id,
               p_program_id              => fnd_global.conc_program_id,
               p_request_id              => fnd_global.conc_request_id,
               p_program_update_date     => sysdate,
               p_object_version_number   => l_object_version_number,
       	       p_effective_date          => p_effective_date);
            hr_utility.set_location('Dn BEPECAPI_CRE 1: '||l_proc,10);
        end if;
        --
      end if;
      close c_bpp1;
      close c_abr1;
    end if ;
  end loop;

  hr_utility.set_location('Dn c_epe_pgm ',10);

  -- There is no reason to continue if there are no flex program choices.
  if l_found_pgm = 'Y' then
  ---------------------------------------------------------------------
  -- Process PLIP Level Flex Credits
  ---------------------------------------------------------------------
  for l_epe_plip in c_epe_plip loop
    l_plip_id := l_epe_plip.plip_id;
    l_ptip_id := l_epe_plip.ptip_id;
    l_bnft_prvdr_pool_id := null;
    l_cmbn_plip_id := null;
    --
    if l_pgm_id <> l_epe_plip.pgm_id then
      open yr_perd_for_pgm (l_epe_plip.pgm_id);
      fetch yr_perd_for_pgm into l_yr_perd_id;
      close yr_perd_for_pgm;
    end if;
    --
    --Override Changes
    --
    l_create_override := 'N' ;
    if p_called_from = 'O' then
      open c_chk_plip (l_plip_id);
      fetch c_chk_plip into l_exists ;
      if c_chk_plip%notfound then
        l_create_override := 'Y' ;
      end if ;
      close c_chk_plip;
    end if ;
    --
    --
    if nvl(p_called_from,'B') <> 'O'
       or ( p_called_from = 'O' and l_create_override = 'Y' ) then
    --
    -- End Override Changes
    -- save the pgm id for the next records compare.
    l_pgm_id := l_epe_plip.pgm_id;
    --
    open c_abr2;
    fetch c_abr2 into l_abr2;
    if c_abr2%found then
      --
      open c_bpp2;
      fetch c_bpp2 into l_bnft_prvdr_pool_id ;
      close c_bpp2;
      --
      hr_utility.set_location('PLIP Dn c_bpp2 '||l_bnft_prvdr_pool_id,20);
      --
      -- Combination PLIP level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        -- Look for the Benefit pool at Combination PLIP level
        --
        open c_bpp5;
        fetch c_bpp5 into l_bnft_prvdr_pool_id, l_cmbn_plip_id ;
        close c_bpp5;
        --
      end if;
      --
      hr_utility.set_location('PLIP Dn c_bpp5  '||l_bnft_prvdr_pool_id,20);
      -- Now Find the pool at PTIP level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        open c_bpp3;
        fetch c_bpp3 into l_bnft_prvdr_pool_id ;
        close c_bpp3;
        --
      end if;
      --
      hr_utility.set_location('PLIP Dn c_bpp3 '||l_bnft_prvdr_pool_id,20);
      --
      -- Combination PTIP level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        -- Look for the Benefit pool at Combination PTIP level
        --
        open c_bpp4;
        fetch c_bpp4 into l_bnft_prvdr_pool_id, l_cmbn_ptip_id ;
        close c_bpp4;
        --
      end if;
      --
      hr_utility.set_location('PLIP Dn c_bpp6 '||l_bnft_prvdr_pool_id,20);
      -- Now Find the pool at Program level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        open c_bpp1;
        fetch c_bpp1 into l_bnft_prvdr_pool_id ;
        close c_bpp1;
        --
      end if;
      --
      if l_bnft_prvdr_pool_id is not null then
        --
        if p_mode in ('U','R') then
           --
           l_elig_per_elctbl_chc_id := null;
           l_elig_per_elctbl_chc_id := ben_manage_unres_life_events.epe_exists
                  (p_per_in_ler_id => p_per_in_ler_id,
                   p_pgm_id => l_epe_plip.pgm_id,
                   p_plip_id => l_epe_plip.plip_id,
                   p_bnft_prvdr_pool_id  => l_bnft_prvdr_pool_id,
                   p_comp_lvl_cd =>'PLIP');
                   --
        end if;
        --
        if l_elig_per_elctbl_chc_id is not null and p_mode in ('U','R') then
           --
           ben_manage_unres_life_events.update_elig_per_elctbl_choice
             (p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id,
               p_elctbl_flag             => 'N',
               p_comp_lvl_cd             => 'PLIP',
               p_pgm_id                  => l_epe_plip.pgm_id,
               p_plip_id                 => l_epe_plip.plip_id,
               p_bnft_prvdr_pool_id      => l_bnft_prvdr_pool_id,
               p_per_in_ler_id           => p_per_in_ler_id,
               p_yr_perd_id              => l_yr_perd_id,
               p_business_group_id       => p_business_group_id,
               p_effective_date          => p_effective_date);
        else
          -- Write Plip Level Flex Credit Distribution Record
          --
          hr_utility.set_location('Write Plip Lvl Flx Cr Distr Rec '||
                    to_char(l_epe_plip.plip_id),30);
          ben_elig_per_elc_chc_api.create_perf_elig_per_elc_chc
            (p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id,
             p_elctbl_flag             => 'N',
             p_comp_lvl_cd             => 'PLIP',
             p_pl_id                   => l_epe_plip.pl_id,
             p_pgm_id                  => l_epe_plip.pgm_id,
             p_plip_id                 => l_epe_plip.plip_id,
             p_ptip_id                 => l_epe_plip.ptip_id,
             p_pl_typ_id               => l_epe_plip.pl_typ_id,
             p_plip_ordr_num           => l_epe_plip.plip_ordr_num,
             p_ptip_ordr_num           => l_epe_plip.ptip_ordr_num,
             p_bnft_prvdr_pool_id      => l_bnft_prvdr_pool_id,
             p_per_in_ler_id           => p_per_in_ler_id,
             p_yr_perd_id              => l_yr_perd_id,
             p_business_group_id       => p_business_group_id,
             p_program_application_id  => fnd_global.prog_appl_id,
             p_program_id              => fnd_global.conc_program_id,
             p_request_id              => fnd_global.conc_request_id,
             p_program_update_date     => sysdate,
             p_object_version_number   => l_object_version_number,
       	     p_effective_date          => p_effective_date);
          hr_utility.set_location('Dn BEPECAPI_CRE 2: ',10);
        end if;
        --
      end if;
      --
    end if; -- c_abr2 found
    close c_abr2;
    end if; -- Override loop
  end loop;
 hr_utility.set_location(' Dn PLIP ',10);
  ---------------------------------------------------------------------
  -- Process COMBO PLIP Level Flex Credits
  ---------------------------------------------------------------------
  l_num_cmbn:=0;
  l_wrote_cmbn.delete;
  --
  for l_epe_plip in c_epe_plip loop
    --
    l_plip_id := l_epe_plip.plip_id;
    l_ptip_id := l_epe_plip.ptip_id;
    l_cmbn_plip_id := null;
    l_bnft_prvdr_pool_id := null ;
    --
    hr_utility.set_location('l_plip_id '||to_char(l_plip_id),10);
    --
    if l_pgm_id <> l_epe_plip.pgm_id then
      open yr_perd_for_pgm (l_epe_plip.pgm_id);
      fetch yr_perd_for_pgm into l_yr_perd_id;
      close yr_perd_for_pgm;
    end if;
    -- save the pgm id for the next records compare.
    l_pgm_id := l_epe_plip.pgm_id;
    -- Process COMBO PLIP
    --
    open c_abr5 ;
    fetch c_abr5 into l_abr5;
    --
    if c_abr5%found then
      --
      l_cmbn_plip_id := l_abr5.cmbn_plip_id ;
      -- Look for the Benefit pool at Combination PLIP level
      open c_bpp5;
      fetch c_bpp5 into l_bnft_prvdr_pool_id, l_dummy_id ;
      close c_bpp5;
      --
      hr_utility.set_location('Cmbn PLIP Dn c_bpp5  '||l_bnft_prvdr_pool_id,20);
      -- Now Find the pool at PTIP level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        open c_bpp3;
        fetch c_bpp3 into l_bnft_prvdr_pool_id ;
        close c_bpp3;
        --
      end if;
      --
      hr_utility.set_location('Cmbn PLIP Dn c_bpp3 '||l_bnft_prvdr_pool_id,20);
      --
      -- Combination PTIP level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        -- Look for the Benefit pool at Combination PTIP level
        --
        open c_bpp4;
        fetch c_bpp4 into l_bnft_prvdr_pool_id, l_dummy_id ;
        close c_bpp4;
        --
      end if;
      --
      hr_utility.set_location('Cmbn PLIP Dn c_bpp4 '||l_bnft_prvdr_pool_id,20);
      -- Now Find the pool at Program level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        open c_bpp1;
        fetch c_bpp1 into l_bnft_prvdr_pool_id ;
        close c_bpp1;
        --
      end if;
      --
      hr_utility.set_location('Cmbn PLIP Dn c_bpp1 '||l_bnft_prvdr_pool_id,20);
      if l_bnft_prvdr_pool_id is not null then
          --
          -- Write Cmbn Plip Level Flex Credit Distribution Record
          --
          -- save cmbn id so we only write it once.
          l_write_this_one := 'Y';
          if l_wrote_cmbn.first is not null then
            for j in l_wrote_cmbn.first..l_wrote_cmbn.last loop
              hr_utility.set_location('loop cmbns plips written '||
                to_char(l_wrote_cmbn(j)),30);
              if l_wrote_cmbn(j) = l_cmbn_plip_id then
                  l_write_this_one := 'N';
               end if;
            end loop;
          end if;

          if l_write_this_one = 'Y' then
             hr_utility.set_location('Write Cmbn Plip Lvl Flx Cr Distr Rec '||
                    to_char(l_cmbn_plip_id),30);
             --Override Changes
             --
             l_create_override := 'N' ;
             if p_called_from = 'O' then
               open c_chk_cplip (l_cmbn_plip_id);
               fetch c_chk_cplip into l_exists ;
               if c_chk_cplip%notfound then
                 l_create_override := 'Y' ;
               end if ;
               close c_chk_cplip;
             end if ;
             --
             --
             if nvl(p_called_from,'B') <> 'O'
                or ( p_called_from = 'O' and l_create_override = 'Y' ) then
             --
             -- End Override Changes
               l_wrote_cmbn(l_num_cmbn) := l_cmbn_plip_id;
               l_num_cmbn := l_num_cmbn+1;
               if p_mode in ('U','R') then
                  --
                  l_elig_per_elctbl_chc_id := null;
                  l_elig_per_elctbl_chc_id := ben_manage_unres_life_events.epe_exists
                         (p_per_in_ler_id => p_per_in_ler_id,
                          p_cmbn_plip_id            => l_cmbn_plip_id,
                          p_bnft_prvdr_pool_id  => l_bnft_prvdr_pool_id,
                          p_comp_lvl_cd =>'CPLIP');
                          --
               end if;
               --
               if l_elig_per_elctbl_chc_id is not null and p_mode in ('U','R') then
                  --
                  ben_manage_unres_life_events.update_elig_per_elctbl_choice
                    (p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id,
                      p_elctbl_flag             => 'N',
                      p_comp_lvl_cd             => 'CPLIP',
                      p_pgm_id                  => l_epe_plip.pgm_id,
                      p_cmbn_plip_id            => l_cmbn_plip_id,
                      p_bnft_prvdr_pool_id      => l_bnft_prvdr_pool_id,
                      p_per_in_ler_id           => p_per_in_ler_id,
                      p_yr_perd_id              => l_yr_perd_id,
                      p_business_group_id       => p_business_group_id,
                      p_effective_date          => p_effective_date);
                  --
               else
                 ben_elig_per_elc_chc_api.create_perf_elig_per_elc_chc
                  (p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id,
                   p_elctbl_flag             => 'N',
                   p_comp_lvl_cd             => 'CPLIP',
                   p_pl_id                   => null, --l_abr5.pl_id,
                   p_pgm_id                  => l_epe_plip.pgm_id,
                   p_plip_id                 => null, --l_abr5.plip_id,  -- all plips in combo
                   p_ptip_id                 => null, --l_abr5.ptip_id,  -- do not have same
                   p_pl_typ_id               => null, --l_abr5.pl_typ_id,-- pt_typ_id.
                   p_cmbn_plip_id            => l_cmbn_plip_id,
                   p_bnft_prvdr_pool_id      => l_bnft_prvdr_pool_id,
                   p_per_in_ler_id           => p_per_in_ler_id,
                   p_yr_perd_id              => l_yr_perd_id,
                   p_business_group_id       => p_business_group_id,
                   p_program_application_id  => fnd_global.prog_appl_id,
                   p_program_id              => fnd_global.conc_program_id,
                   p_request_id              => fnd_global.conc_request_id,
                   p_program_update_date     => sysdate,
                   p_object_version_number   => l_object_version_number,
       	           p_effective_date          => p_effective_date);
                   hr_utility.set_location('Dn BEPECAPI_CRE 5: ',10);
                end if;
                --
             end if; -- Override
          end if;
      end if;
    end if;
    close c_abr5;
  end loop;
  hr_utility.set_location('Dn c_epe_plip ',10);
  -- clear out table of combination records that were written.
  ---------------------------------------------------------------------
  -- Process PTIP Level Flex Credits
  ---------------------------------------------------------------------
  for l_epe_ptip in c_epe_ptip loop
    l_ptip_id := l_epe_ptip.ptip_id;
    l_bnft_prvdr_pool_id := null;
    l_cmbn_ptip_id := null ;
    --hr_utility.set_location('pgm_id'||to_char(l_epe_ptip.pgm_id)||
    --    ' ptip_id'||to_char(l_epe_ptip.ptip_id),10);
    --hr_utility.set_location(' ptip_ordr_num'||to_char(l_epe_ptip.ptip_ordr_num)||
    --    ' pl_typ_id'||to_char(l_epe_ptip.pl_typ_id),10);
    --
    --Override Changes
    --
    l_create_override := 'N' ;
    if p_called_from = 'O' then
      open c_chk_ptip (l_ptip_id);
      fetch c_chk_ptip into l_exists ;
      if c_chk_ptip%notfound then
        l_create_override := 'Y' ;
      end if ;
      close c_chk_ptip;
    end if ;
    --
    if l_pgm_id <> l_epe_ptip.pgm_id then
      open yr_perd_for_pgm (l_epe_ptip.pgm_id);
      fetch yr_perd_for_pgm into l_yr_perd_id;
      close yr_perd_for_pgm;
    end if;
    --
    if nvl(p_called_from,'B') <> 'O'
       or ( p_called_from = 'O' and l_create_override = 'Y' ) then
    --
    -- End Override Changes
    l_pgm_id := l_epe_ptip.pgm_id;
    open c_abr3;
    fetch c_abr3 into l_abr3;
    -- If there is a Flex Credit record at this level, then look for the benefit pool at
    -- OIPLIP or higher level.A
    --
    if c_abr3%found then
      --
      hr_utility.set_location('PTIP abr7 found',20);
      -- Now Find the pool at PTIP level
      --
      --
      open c_bpp3;
      fetch c_bpp3 into l_bnft_prvdr_pool_id ;
      close c_bpp3;
      --
      hr_utility.set_location('PTIP Dn c_bpp3 '||l_bnft_prvdr_pool_id,20);
      --
      -- Combination PTIP level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        -- Look for the Benefit pool at Combination PTIP level
        --
        open c_bpp4;
        fetch c_bpp4 into l_bnft_prvdr_pool_id, l_cmbn_ptip_id ;
        close c_bpp4;
        --
      end if;
      --
      hr_utility.set_location('PTIP Dn c_bpp4 '||l_bnft_prvdr_pool_id,20);
      -- Now Find the pool at Program level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        open c_bpp1;
        fetch c_bpp1 into l_bnft_prvdr_pool_id ;
        close c_bpp1;
        --
      end if;
      --
      if l_bnft_prvdr_pool_id is not null then
          --
        if p_mode in ('U','R') then
           --
           l_elig_per_elctbl_chc_id := null;
           l_elig_per_elctbl_chc_id := ben_manage_unres_life_events.epe_exists
                  (p_per_in_ler_id => p_per_in_ler_id,
                   p_pgm_id => l_epe_ptip.pgm_id,
                   p_ptip_id           => l_epe_ptip.ptip_id,
                   p_bnft_prvdr_pool_id  => l_bnft_prvdr_pool_id,
                   p_comp_lvl_cd =>'PTIP');
                   --
        end if;
        --
        if l_elig_per_elctbl_chc_id is not null and p_mode in ('U','R') then
           --
           ben_manage_unres_life_events.update_elig_per_elctbl_choice
             (p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id,
               p_elctbl_flag             => 'N',
               p_comp_lvl_cd             => 'PTIP',
               p_pgm_id                  => l_epe_ptip.pgm_id,
               p_ptip_id                 => l_epe_ptip.ptip_id,
               p_bnft_prvdr_pool_id      => l_bnft_prvdr_pool_id,
               p_per_in_ler_id           => p_per_in_ler_id,
               p_yr_perd_id              => l_yr_perd_id,
               p_business_group_id       => p_business_group_id,
               p_effective_date          => p_effective_date);
        else
          -- Write Ptip Level Flex Credit Distribution Record
          --
          hr_utility.set_location('Write Ptip Lvl Flx Cr Distr Rec '||
                    to_char(l_epe_ptip.ptip_id),40);
          ben_elig_per_elc_chc_api.create_perf_elig_per_elc_chc
            (p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id,
             p_elctbl_flag             => 'N',
             p_comp_lvl_cd             => 'PTIP',
             p_pgm_id                  => l_epe_ptip.pgm_id,
             p_ptip_id                 => l_epe_ptip.ptip_id,
             p_pl_typ_id               => l_epe_ptip.pl_typ_id,
             p_bnft_prvdr_pool_id      => l_bnft_prvdr_pool_id,
             p_per_in_ler_id           => p_per_in_ler_id,
             p_yr_perd_id              => l_yr_perd_id,
             p_ptip_ordr_num           => l_epe_ptip.ptip_ordr_num,
             p_business_group_id       => p_business_group_id,
             p_program_application_id  => fnd_global.prog_appl_id,
             p_program_id              => fnd_global.conc_program_id,
             p_request_id              => fnd_global.conc_request_id,
             p_program_update_date     => sysdate,
             p_object_version_number   => l_object_version_number,
       	     p_effective_date          => p_effective_date);
          hr_utility.set_location('Dn BEPECAPI_CRE 3: ',10);
          --
        end if;
        --
      end if;
      --
    end if;
    close c_abr3;
    --
    end if ; -- Override
  end loop;
  ---------------------------------------------------------------------
  -- Process Combo PTIP Level Flex Credits
  ---------------------------------------------------------------------
  -- clear out table of combination records that were written.
  l_num_cmbn:=0;
  l_wrote_cmbn.delete;
  for l_epe_ptip in c_epe_ptip loop
    l_ptip_id := l_epe_ptip.ptip_id;
    l_bnft_prvdr_pool_id := null;
    l_cmbn_ptip_id := null ;
    --
    if l_pgm_id <> l_epe_ptip.pgm_id then
      open yr_perd_for_pgm (l_epe_ptip.pgm_id);
      fetch yr_perd_for_pgm into l_yr_perd_id;
      close yr_perd_for_pgm;
    end if;
    --
    open c_abr4;
    fetch c_abr4 into l_abr4;
    if c_abr4%found then
      --
      l_cmbn_ptip_id := l_abr4.cmbn_ptip_id ;
      -- Look for the Benefit pool at Combination PTIP level
      --
      --
      --Override Changes
      --
      l_create_override := 'N' ;
      if p_called_from = 'O' then
        open c_chk_cptip (l_cmbn_ptip_id);
        fetch c_chk_cptip into l_exists ;
        if c_chk_cptip%notfound then
          l_create_override := 'Y' ;
        end if ;
        close c_chk_cptip;
      end if ;
      --
      --
      if nvl(p_called_from,'B') <> 'O'
         or ( p_called_from = 'O' and l_create_override = 'Y' ) then
      --
      -- End Override Changes
      open c_bpp4;
      fetch c_bpp4 into l_bnft_prvdr_pool_id, l_dummy_id ;
      close c_bpp4;
      --
      hr_utility.set_location('PTIP Dn c_bpp6 '||l_bnft_prvdr_pool_id,20);
      -- Now Find the pool at Program level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        open c_bpp1;
        fetch c_bpp1 into l_bnft_prvdr_pool_id ;
        close c_bpp1;
        --
      end if;
      --
      --
      if l_bnft_prvdr_pool_id is not null then
          --
          --
          -- Write Cmbn Ptip Level Flex Credit Distribution Record
          --
          -- save cmbn id so we only write it once.
          l_write_this_one := 'Y';
          if l_wrote_cmbn.first is not null then
            for j in l_wrote_cmbn.first..l_wrote_cmbn.last loop
                hr_utility.set_location('loop cmbns ptips written '||
                          to_char(l_wrote_cmbn(j)),30);
                if l_wrote_cmbn(j) = l_cmbn_ptip_id then
                   l_write_this_one := 'N';
                end if;
            end loop;
          end if;

          if l_write_this_one = 'Y' then
             hr_utility.set_location('Write Cmbn Ptip Lvl Flx Cr Distr Rec '||
                    to_char(l_cmbn_ptip_id),40);
             l_wrote_cmbn(l_num_cmbn) := l_cmbn_ptip_id;
             l_num_cmbn := l_num_cmbn+1;
             --
            if p_mode in ('U','R') then
               --
               l_elig_per_elctbl_chc_id := null;
               l_elig_per_elctbl_chc_id := ben_manage_unres_life_events.epe_exists
                  (p_per_in_ler_id => p_per_in_ler_id,
                   p_pgm_id => l_epe_ptip.pgm_id,
                   p_cmbn_ptip_id            => l_cmbn_ptip_id,
                   p_bnft_prvdr_pool_id  => l_bnft_prvdr_pool_id,
                   p_comp_lvl_cd =>'CPTIP');
                   --
            end if;
            --
            if l_elig_per_elctbl_chc_id is not null and p_mode in ('U','R') then
               --
               ben_manage_unres_life_events.update_elig_per_elctbl_choice
                 (p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id,
                   p_elctbl_flag             => 'N',
                   p_comp_lvl_cd             => 'CPTIP',
                   p_pgm_id                  => l_epe_ptip.pgm_id,
                   p_cmbn_ptip_id            => l_cmbn_ptip_id,
                   p_bnft_prvdr_pool_id      => l_bnft_prvdr_pool_id,
                   p_per_in_ler_id           => p_per_in_ler_id,
                   p_yr_perd_id              => l_yr_perd_id,
                   p_business_group_id       => p_business_group_id,
                   p_effective_date          => p_effective_date);
            else
              ben_elig_per_elc_chc_api.create_perf_elig_per_elc_chc
               (p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id,
                p_elctbl_flag             => 'N',
                p_comp_lvl_cd             => 'CPTIP',
                p_pgm_id                  => l_epe_ptip.pgm_id,
                p_ptip_id                 => null, --l_abr4.ptip_id,
                p_pl_typ_id               => null, --l_abr4.pl_typ_id,
                p_cmbn_ptip_id            => l_cmbn_ptip_id,
                p_bnft_prvdr_pool_id      => l_bnft_prvdr_pool_id,
                p_per_in_ler_id           => p_per_in_ler_id,
                p_yr_perd_id              => l_yr_perd_id,
                p_business_group_id       => p_business_group_id,
                p_program_application_id  => fnd_global.prog_appl_id,
                p_program_id              => fnd_global.conc_program_id,
                p_request_id              => fnd_global.conc_request_id,
                p_program_update_date     => sysdate,
                p_object_version_number   => l_object_version_number,
                p_effective_date          => p_effective_date);
               hr_utility.set_location('Dn BEPECAPI_CRE 4: ',10);
            end if;
            --
          end if;
      end if;
      --
      end if ; -- Override
    end if; -- c_abr4 found
    close c_abr4;
    --
  end loop;
  -- clear out table of combination records that were written.
  l_num_cmbn:=0;
  l_wrote_cmbn.delete;
  ---------------------------------------------------------------------
  -- Process OIPLIP Level Flex Credits
  ---------------------------------------------------------------------
  hr_utility.set_location('Start EPE_OIPL loop ',10);
  for l_epe_oipl in c_epe_oipl loop
    l_oipl_id   := l_epe_oipl.oipl_id;
    l_ptip_id   := l_epe_oipl.ptip_id;
    l_oiplip_id := l_epe_oipl.oiplip_id;
    l_plip_id   := l_epe_oipl.plip_id;
    --
    l_dummy_id := null ;
    l_bnft_prvdr_pool_id := null;
    l_cmbn_plip_id := null;
    l_cmbn_ptip_id := null ;
    --
    --
    --Override Changes
    --
    l_create_override := 'N' ;
    if p_called_from = 'O' then
      open c_chk_oiplip (l_oiplip_id);
      fetch c_chk_oiplip into l_exists ;
      if c_chk_oiplip%notfound then
        l_create_override := 'Y' ;
      end if ;
      close c_chk_oiplip;
    end if ;
    --
    if l_pgm_id <> l_epe_oipl.pgm_id then
      open yr_perd_for_pgm (l_epe_oipl.pgm_id);
        fetch yr_perd_for_pgm into l_yr_perd_id;
      close yr_perd_for_pgm;
    end if;
    --
    if nvl(p_called_from,'B') <> 'O'
       or ( p_called_from = 'O' and l_create_override = 'Y' ) then
    --
    -- End Override Changes
    --
    -- save the pgm id for the next records compare.
    l_pgm_id := l_epe_oipl.pgm_id;
    --
    hr_utility.set_location('OIPLIP pgm_id'||to_char(l_pgm_id)||
        ' l_oiplip_id'||to_char(l_oiplip_id)||' l_ptip_id'||to_char(l_ptip_id),10);
    --
    open c_abr7;
    fetch c_abr7 into l_abr7;
    --
    -- If there is a Flex Credit record at this level, then look for the benefit pool at
    -- OIPLIP or higher level.A
    --
    if c_abr7%found then
      --
      hr_utility.set_location('OIPLIP abr7 found',20);
      -- Process OIPLIP
      open c_bpp7;
      fetch c_bpp7 into l_bnft_prvdr_pool_id;  -- get required pool id.
      close c_bpp7;
      --
      -- Now Find the pool at Combination optip level
      hr_utility.set_location('OIPLIP Dn c_bpp7 '||l_bnft_prvdr_pool_id,20);
      --
      if l_bnft_prvdr_pool_id is null then
        --
        -- Look for the Benefit pool at Combination OPTIP level
        --
        open c_bpp6;
        fetch c_bpp6 into l_bnft_prvdr_pool_id, l_dummy_id ;
        close c_bpp6;
        --
      end if;
      hr_utility.set_location('OIPLIP Dn c_bpp6 '||l_bnft_prvdr_pool_id,20);
      --
      -- Now Find the pool at PLIP level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        open c_bpp2;
        fetch c_bpp2 into l_bnft_prvdr_pool_id ;
        close c_bpp2;
        --
      end if;
      --
      hr_utility.set_location('OIPLIP Dn c_bpp2 '||l_bnft_prvdr_pool_id,20);
      --
      -- Combination PLIP level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        -- Look for the Benefit pool at Combination PLIP level
        --
        open c_bpp5;
        fetch c_bpp5 into l_bnft_prvdr_pool_id, l_cmbn_plip_id ;
        close c_bpp5;
        --
      end if;
      --
      hr_utility.set_location('OIPLIP Dn c_bpp5  '||l_bnft_prvdr_pool_id,20);
      -- Now Find the pool at PTIP level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        open c_bpp3;
        fetch c_bpp3 into l_bnft_prvdr_pool_id ;
        close c_bpp3;
        --
      end if;
      --
      hr_utility.set_location('OIPLIP Dn c_bpp3 '||l_bnft_prvdr_pool_id,20);
      --
      -- Combination PTIP level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        -- Look for the Benefit pool at Combination PTIP level
        --
        open c_bpp4;
        fetch c_bpp4 into l_bnft_prvdr_pool_id, l_cmbn_ptip_id ;
        close c_bpp4;
        --
      end if;
      --
      hr_utility.set_location('OIPLIP Dn c_bpp6 '||l_bnft_prvdr_pool_id,20);
      -- Now Find the pool at Program level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        open c_bpp1;
        fetch c_bpp1 into l_bnft_prvdr_pool_id ;
        close c_bpp1;
        --
      end if;
      --
      hr_utility.set_location('OIPLIP Dn c_bpp1 '||l_bnft_prvdr_pool_id,20);
      --
      if l_bnft_prvdr_pool_id is not null then
          --
        if p_mode in ('U','R') then
           --
           l_elig_per_elctbl_chc_id := null;
           l_elig_per_elctbl_chc_id := ben_manage_unres_life_events.epe_exists
                  (p_per_in_ler_id => p_per_in_ler_id,
                   p_pgm_id => l_epe_oipl.pgm_id,
                   p_oiplip_id               => l_epe_oipl.oiplip_id,
                   p_bnft_prvdr_pool_id  => l_bnft_prvdr_pool_id,
                   p_comp_lvl_cd =>'OIPLIP');
                   --
        end if;
        --
        if l_elig_per_elctbl_chc_id is not null and p_mode in ('U','R') then
           --
           ben_manage_unres_life_events.update_elig_per_elctbl_choice
             (p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id,
               p_elctbl_flag             => 'N',
               p_comp_lvl_cd             => 'OIPLIP',
               p_pgm_id                  => l_epe_oipl.pgm_id,
               p_oiplip_id               => l_epe_oipl.oiplip_id,
               p_bnft_prvdr_pool_id      => l_bnft_prvdr_pool_id,
               p_per_in_ler_id           => p_per_in_ler_id,
               p_yr_perd_id              => l_yr_perd_id,
               p_business_group_id       => p_business_group_id,
               p_effective_date          => p_effective_date);
        else
          hr_utility.set_location('BP fount at bpid '||l_bnft_prvdr_pool_id ,30);
            ben_elig_per_elc_chc_api.create_perf_elig_per_elc_chc
            (p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id,
             p_elctbl_flag             => 'N',
             p_comp_lvl_cd             => 'OIPLIP',
             p_pgm_id                  => l_epe_oipl.pgm_id,
             p_ptip_id                 => l_ptip_id,
             p_pl_typ_id               => l_epe_oipl.pl_typ_id,
             p_oipl_id                 => l_oipl_id,
             p_plip_id                 => l_epe_oipl.plip_id,
             p_pl_id                   => l_epe_oipl.pl_id,
             p_oiplip_id               => l_epe_oipl.oiplip_id,
             p_oipl_ordr_num           => l_epe_oipl.oipl_ordr_num,
             p_plip_ordr_num           => l_epe_oipl.plip_ordr_num,
             p_ptip_ordr_num           => l_epe_oipl.ptip_ordr_num,
             p_bnft_prvdr_pool_id      => l_bnft_prvdr_pool_id,
             p_per_in_ler_id           => p_per_in_ler_id,
             p_yr_perd_id              => l_yr_perd_id,
             p_business_group_id       => p_business_group_id,
             p_program_application_id  => fnd_global.prog_appl_id,
             p_program_id              => fnd_global.conc_program_id,
             p_request_id              => fnd_global.conc_request_id,
             p_program_update_date     => sysdate,
             p_object_version_number   => l_object_version_number,
             p_effective_date          => p_effective_date);
           --
         end if;
         --
             --
      end if;
    end if; -- c_abr7 found
    --
    close c_abr7;
    --
    end if ; -- Override
  end loop;
  ---------------------------------------------------------------------
  -- Process Combo PTIP Option Level Flex Credits
  ---------------------------------------------------------------------
  hr_utility.set_location('Start EPE_COPTIP loop ',10);
  -- clear out table of combination records that were written.
  l_num_cmbn:=0;
  l_wrote_cmbn.delete;
  for l_epe_oipl in c_epe_oipl loop
    --
    l_oipl_id   := l_epe_oipl.oipl_id;
    l_ptip_id   := l_epe_oipl.ptip_id;
    l_oiplip_id := l_epe_oipl.oiplip_id;
    l_plip_id   := l_epe_oipl.plip_id;
    --
    l_dummy_id := null ;
    l_cmbn_ptip_opt_id := null;
    l_bnft_prvdr_pool_id := null;
    l_cmbn_plip_id := null;
    l_cmbn_ptip_id := null ;
    --
    hr_utility.set_location('OIPLIP pgm_id'||to_char(l_pgm_id)||
        ' l_oiplip_id'||to_char(l_oiplip_id)||' l_ptip_id'||to_char(l_ptip_id),10);
    --
    if l_pgm_id <> l_epe_oipl.pgm_id then
      open yr_perd_for_pgm (l_epe_oipl.pgm_id);
        fetch yr_perd_for_pgm into l_yr_perd_id;
      close yr_perd_for_pgm;
    end if;
    -- save the pgm id for the next records compare.
    l_pgm_id := l_epe_oipl.pgm_id;
    --
    open c_abr6;
    fetch c_abr6 into l_abr6;
    --
    if c_abr6%found then
      --
      l_cmbn_ptip_opt_id := l_abr6.cmbn_ptip_opt_id ;
      hr_utility.set_location('COPTIP found c_abr6 cmbnptipoptid '||l_cmbn_ptip_opt_id,10);
      --
      --
      --Override Changes
      --
      l_create_override := 'N' ;
      if p_called_from = 'O' then
        open c_chk_cptipopt (l_cmbn_ptip_opt_id);
        fetch c_chk_cptipopt into l_exists ;
        if c_chk_cptipopt%notfound then
          l_create_override := 'Y' ;
        end if ;
        close c_chk_cptipopt;
      end if ;
      --
      --
      if nvl(p_called_from,'B') <> 'O'
         or ( p_called_from = 'O' and l_create_override = 'Y' ) then
      --
      -- End Override Changes
      --
      -- Look for the Benefit pool at Combination OPTIP level
      --
      open c_bpp6;
      fetch c_bpp6 into l_bnft_prvdr_pool_id, l_dummy_id ;
      close c_bpp6;
      --
      hr_utility.set_location('COPTIP Dn c_bpp6 '||l_bnft_prvdr_pool_id,20);
      -- Now Find the pool at PLIP level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        open c_bpp2;
        fetch c_bpp2 into l_bnft_prvdr_pool_id ;
        close c_bpp2;
        --
      end if;
      hr_utility.set_location('COPTIP Dn c_bpp2 '||l_bnft_prvdr_pool_id,20);
      -- Combination PLIP level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        -- Look for the Benefit pool at Combination PLIP level
        --
        open c_bpp5;
        fetch c_bpp5 into l_bnft_prvdr_pool_id, l_cmbn_plip_id ;
        close c_bpp5;
        --
      end if;
      hr_utility.set_location('COPTIP Dn c_bpp5  '||l_bnft_prvdr_pool_id,20);
      -- Now Find the pool at PTIP level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        open c_bpp3;
        fetch c_bpp3 into l_bnft_prvdr_pool_id ;
        close c_bpp3;
        --
      end if;
      hr_utility.set_location('COPTIP Dn c_bpp3 '||l_bnft_prvdr_pool_id,20);
      --
      -- Combination PTIP level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        -- Look for the Benefit pool at Combination PTIP level
        --
        open c_bpp4;
        fetch c_bpp4 into l_bnft_prvdr_pool_id, l_cmbn_ptip_id ;
        close c_bpp4;
        --
      end if;
      hr_utility.set_location('COPTIP Dn c_bpp4 '||l_bnft_prvdr_pool_id,20);
      --
      -- Now Find the pool at Program level
      --
      if l_bnft_prvdr_pool_id is null then
        --
        open c_bpp1;
        fetch c_bpp1 into l_bnft_prvdr_pool_id ;
        close c_bpp1;
        --
      end if;
      hr_utility.set_location('COPTIP Dn c_bpp1 '||l_bnft_prvdr_pool_id,20);
      -- Process COMBO PTIP Option
      if l_bnft_prvdr_pool_id is not null then
          --
          hr_utility.set_location('writing cmbnptipopt ',19 );
          -- save cmbn id so we only write it once.
          l_write_this_one := 'Y';
          if l_wrote_cmbn.first is not null then
            for j in l_wrote_cmbn.first..l_wrote_cmbn.last loop
                hr_utility.set_location('loop cmbns ptip/opts written '||
                           to_char(l_wrote_cmbn(j)),30);
                if l_wrote_cmbn(j) = l_cmbn_ptip_opt_id then
                   l_write_this_one := 'N';
                end if;
            end loop;
          end if;
          if l_write_this_one = 'Y' then
             hr_utility.set_location('Write Cmbn Ptip Opt Lvl Flx Cr Distr Rec '||
                    to_char(l_cmbn_ptip_opt_id),30);
             l_wrote_cmbn(l_num_cmbn) := l_cmbn_ptip_opt_id;
             l_num_cmbn := l_num_cmbn+1;
             --

             if p_mode in ('U','R') then
                --
                l_elig_per_elctbl_chc_id := null;
                l_elig_per_elctbl_chc_id := ben_manage_unres_life_events.epe_exists
                  (p_per_in_ler_id => p_per_in_ler_id,
                   p_pgm_id => l_epe_oipl.pgm_id,
                   p_cmbn_ptip_opt_id        => l_cmbn_ptip_opt_id,
                   p_bnft_prvdr_pool_id  => l_bnft_prvdr_pool_id,
                   p_comp_lvl_cd =>'CPTIPOPT');
                   --
             end if;
             --
             if l_elig_per_elctbl_chc_id is not null and p_mode in ('U','R') then
                --
                ben_manage_unres_life_events.update_elig_per_elctbl_choice
                  (p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id,
                    p_elctbl_flag             => 'N',
                    p_comp_lvl_cd             => 'CPTIPOPT',
                    p_pgm_id                  => l_epe_oipl.pgm_id,
                    p_cmbn_ptip_opt_id        => l_cmbn_ptip_opt_id,
                    p_bnft_prvdr_pool_id      => l_bnft_prvdr_pool_id,
                    p_per_in_ler_id           => p_per_in_ler_id,
                    p_yr_perd_id              => l_yr_perd_id,
                    p_business_group_id       => p_business_group_id,
                    p_effective_date          => p_effective_date);
             else
               ben_elig_per_elc_chc_api.create_perf_elig_per_elc_chc
               (p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id,
                p_elctbl_flag             => 'N',
                p_comp_lvl_cd             => 'CPTIPOPT',
                p_pgm_id                  => l_epe_oipl.pgm_id,
                p_ptip_id                 => l_ptip_id,
                p_pl_id                   => l_epe_oipl.pl_id,
                p_pl_typ_id               => l_epe_oipl.pl_typ_id,
                p_oipl_id                 => l_epe_oipl.oipl_id,
                p_cmbn_ptip_opt_id        => l_cmbn_ptip_opt_id,
                p_oipl_ordr_num           => l_epe_oipl.oipl_ordr_num,
                p_plip_ordr_num           => l_epe_oipl.plip_ordr_num,
                p_ptip_ordr_num           => l_epe_oipl.ptip_ordr_num,
                p_bnft_prvdr_pool_id      => l_bnft_prvdr_pool_id,
                p_per_in_ler_id           => p_per_in_ler_id,
                p_yr_perd_id              => l_yr_perd_id,
                p_business_group_id       => p_business_group_id,
                p_program_application_id  => fnd_global.prog_appl_id,
                p_program_id              => fnd_global.conc_program_id,
                p_request_id              => fnd_global.conc_request_id,
                p_program_update_date     => sysdate,
                p_object_version_number   => l_object_version_number,
       	        p_effective_date          => p_effective_date);
             hr_utility.set_location('Dn BEPECAPI_CRE 6: ',10);
              --
             end if;
             --
          end if;
          --
      end if;
      --
      end if ; -- Override
    end if;
    close c_abr6;
  end loop;
  hr_utility.set_location('Dn c_epe_oipl ',10);
  end if;


  hr_utility.set_location('Leaving: '||l_proc,90);
  --
end main;
--
end ben_determine_elct_chc_flx_imp;

/

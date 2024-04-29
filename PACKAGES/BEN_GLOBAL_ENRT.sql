--------------------------------------------------------
--  DDL for Package BEN_GLOBAL_ENRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_GLOBAL_ENRT" AUTHID CURRENT_USER as
/* $Header: bengenrt.pkh 120.0 2005/05/28 09:02:14 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Enrollment Globals Package
Purpose
	This package is used to load and return globals used in the enrollment
      save processes.
History
  Date        Who        Version    What?
  ---------   ---------  -------    --------------------------------------------
  03 Apr 2000 lmcdonal   115.0      Created
  07 Apr 2000 lmcdonal   115.1      Added more procedures.
  17 May 2001 maagrawa   115.2      Changed the procedure and record
                                    definitions.
  13-Dec-2002 kmahendr   115.4      Nocopy Changes
  10-feb-2005 mmudigon   115.5      Bug 4157759. Added field "typ_cd" to
                                    g_global_pil_rec_type
  ------------------------------------------------------------------------------
*/
--
type g_global_epe_rec_type is record
  (per_in_ler_id          ben_elig_per_elctbl_chc.per_in_ler_id%type
  ,pil_elctbl_chc_popl_id ben_elig_per_elctbl_chc.pil_elctbl_chc_popl_id%type
  ,prtt_enrt_rslt_id      ben_elig_per_elctbl_chc.prtt_enrt_rslt_id%type
  ,pgm_id                 ben_elig_per_elctbl_chc.pgm_id%type
  ,pl_id                  ben_elig_per_elctbl_chc.pl_id%type
  ,pl_typ_id              ben_elig_per_elctbl_chc.pl_typ_id%type
  ,plip_id                ben_elig_per_elctbl_chc.plip_id%type
  ,ptip_id                ben_elig_per_elctbl_chc.ptip_id%type
  ,oipl_id                ben_elig_per_elctbl_chc.oipl_id%type
  ,business_group_id      ben_elig_per_elctbl_chc.business_group_id%type
  ,object_version_number  ben_elig_per_elctbl_chc.object_version_number%type
  ,comp_lvl_cd            ben_elig_per_elctbl_chc.comp_lvl_cd%type
  ,crntly_enrd_flag       ben_elig_per_elctbl_chc.crntly_enrd_flag%type
  ,alws_dpnt_dsgn_flag    ben_elig_per_elctbl_chc.alws_dpnt_dsgn_flag%type
  ,dpnt_cvg_strt_dt_cd    ben_elig_per_elctbl_chc.dpnt_cvg_strt_dt_cd%type
  ,dpnt_cvg_strt_dt_rl    ben_elig_per_elctbl_chc.dpnt_cvg_strt_dt_rl%type
  ,enrt_cvg_strt_dt       ben_elig_per_elctbl_chc.enrt_cvg_strt_dt%type
  ,erlst_deenrt_dt        ben_elig_per_elctbl_chc.erlst_deenrt_dt%type
  ,enrt_cvg_strt_dt_cd    ben_elig_per_elctbl_chc.enrt_cvg_strt_dt_cd%type
  ,enrt_cvg_strt_dt_rl    ben_elig_per_elctbl_chc.enrt_cvg_strt_dt_rl%type);
g_global_epe_rec g_global_epe_rec_type;

type g_global_pel_rec_type is record
  (per_in_ler_id            ben_pil_elctbl_chc_popl.per_in_ler_id%type
  ,pgm_id                   ben_pil_elctbl_chc_popl.pgm_id%type
  ,pl_id                    ben_pil_elctbl_chc_popl.pl_id%type
  ,lee_rsn_id               ben_pil_elctbl_chc_popl.lee_rsn_id%type
  ,enrt_perd_id             ben_pil_elctbl_chc_popl.enrt_perd_id%type
  ,uom                      ben_pil_elctbl_chc_popl.uom%type
  ,acty_ref_perd_cd         ben_pil_elctbl_chc_popl.acty_ref_perd_cd%type);
--
g_global_pel_rec g_global_pel_rec_type;
g_global_pel_id ben_pil_elctbl_chc_popl.pil_elctbl_chc_popl_id%type;

type g_global_pil_rec_type is record
  (person_id      ben_per_in_ler.person_id%type
  ,ler_id         ben_per_in_ler.ler_id%type
  ,lf_evt_ocrd_dt ben_per_in_ler.lf_evt_ocrd_dt%type
  ,typ_cd         ben_ler_f.typ_cd%type);
g_global_pil_rec g_global_pil_rec_type;
g_global_pil_id  ben_per_in_ler.per_in_ler_id%type;

type g_global_enb_rec_type is record
  (ordr_num              ben_enrt_bnft.ordr_num%type
  ,val                   ben_enrt_bnft.val%type
  ,bnft_typ_cd           ben_enrt_bnft.bnft_typ_cd%type
  ,cvg_mlt_cd            ben_enrt_bnft.cvg_mlt_cd%type
  ,nnmntry_uom           ben_enrt_bnft.nnmntry_uom%type
  ,object_version_number ben_enrt_bnft.object_version_number%type);
g_global_enb_rec g_global_enb_rec_type;

type g_global_asg_rec_type is record
  (payroll_id      per_all_assignments_f.payroll_id%type);
g_global_asg_rec g_global_asg_rec_type;
g_global_asg_person_id per_all_people_f.person_id%type;

g_global_pen_rec ben_prtt_enrt_rslt_f%rowtype;
------------------------------------------------------------------------------

procedure get_epe
      (p_elig_per_elctbl_chc_id in number
      ,p_global_epe_rec        out nocopy g_global_epe_rec_type);

procedure reload_epe
      (p_elig_per_elctbl_chc_id in number
      ,p_global_epe_rec        out nocopy g_global_epe_rec_type);

------------------------------------------------------------------------------

procedure get_pel
      (p_pil_elctbl_chc_popl_id in number
      ,p_global_pel_rec        out nocopy g_global_pel_rec_type);
------------------------------------------------------------------------------
procedure get_pil
      (p_per_in_ler_id          in number
      ,p_global_pil_rec        out nocopy g_global_pil_rec_type);
------------------------------------------------------------------------------
procedure clear_enb
      (p_global_enb_rec        out nocopy g_global_enb_rec_type);

procedure get_enb
      (p_enrt_bnft_id           in number
      ,p_global_enb_rec        out nocopy g_global_enb_rec_type);
------------------------------------------------------------------------------
procedure get_asg
      (p_person_id              in number
      ,p_effective_date         in date
      ,p_global_asg_rec        out nocopy g_global_asg_rec_type);
------------------------------------------------------------------------------
procedure clear_pen
      (p_global_pen_rec        out nocopy ben_prtt_enrt_rslt_f%rowtype);

procedure get_pen
      (p_prtt_enrt_rslt_id      in number
      ,p_effective_date         in date
      ,p_global_pen_rec        out nocopy ben_prtt_enrt_rslt_f%rowtype);

procedure get_pen
      (p_per_in_ler_id          in number
      ,p_pgm_id                 in number
      ,p_pl_id                  in number
      ,p_oipl_id                in number
      ,p_effective_date         in date
      ,p_global_pen_rec        out nocopy ben_prtt_enrt_rslt_f%rowtype) ;

procedure reload_pen
      (p_prtt_enrt_rslt_id      in number
      ,p_effective_date         in date
      ,p_global_pen_rec        out nocopy ben_prtt_enrt_rslt_f%rowtype);
------------------------------------------------------------------------------

end ben_global_enrt;

 

/

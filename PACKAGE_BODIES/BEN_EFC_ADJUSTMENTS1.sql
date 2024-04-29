--------------------------------------------------------
--  DDL for Package Body BEN_EFC_ADJUSTMENTS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EFC_ADJUSTMENTS1" as
/* $Header: beefcaj1.pkb 120.0.12010000.2 2008/08/05 14:22:48 ubhat ship $ */
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
  115.0      12-Jul-01	mhoyes     Created.
  115.1      26-Jul-01	mhoyes     Enhanced for Patchset E+ patch.
  115.2      13-Aug-01	mhoyes     Enhanced for Patchset E+ patch.
  115.3      17-Aug-01	mhoyes     Enhanced for BEN July patch.
  115.4      27-Aug-01	mhoyes     Enhanced for BEN July patch.
  115.6      13-Sep-01	mhoyes     Enhanced for BEN July patch.
  115.10     04-Jan-02	mhoyes     Enhanced for BEN G patchset.
  115.12   30-Dec-2002 mmudigon    NOCOPY
  115.13     22-Jan-04 mmudigon    new param to ben_element_entry call
  115.14     15-Nov-06 rtagarra    Bug 5049253:Commented the insert into exception when there is no
				   PRV corresponding to the PIL for prv_adjustments.
  -----------------------------------------------------------------------------
*/
--
-- Globals.
--
g_package varchar2(50) := 'ben_efc_adjustments1.';
--
procedure prv_adjustments
  (p_validate          in     boolean default false
  ,p_worker_id         in     number  default null
  ,p_action_id         in     number  default null
  ,p_total_workers     in     number  default null
  ,p_pk1               in     number  default null
  ,p_chunk             in     number  default null
  ,p_efc_worker_id     in     number  default null
  --
  ,p_valworker_id      in     number  default null
  ,p_valtotal_workers  in     number  default null
  --
  ,p_business_group_id in     number  default null
  --
  ,p_adjustment_counts    out nocopy ben_efc_adjustments.g_adjustment_counts
  )
is
  --
  TYPE cur_type IS REF CURSOR;
  --
  type g_efc_row is record
    (person_id              ben_per_in_ler.person_id%type
    ,per_in_ler_id          ben_per_in_ler.per_in_ler_id%type
    ,business_group_id      ben_per_in_ler.business_group_id%type
    ,lf_evt_ocrd_dt         ben_per_in_ler.lf_evt_ocrd_dt%type
    ,creation_date          ben_per_in_ler.creation_date%type
    ,last_update_date       ben_per_in_ler.last_update_date%type
    ,object_version_number  ben_per_in_ler.object_version_number%type
/*
    ,enrt_mthd_cd           ben_prtt_enrt_rslt_f.enrt_mthd_cd%type
*/
    );
  --
  c_efc_rows               cur_type;
  --
  l_proc                   varchar2(1000) := 'prv_adjustments';
  --
  l_efc_row                g_efc_row;
  --
  l_global_asg_rec         ben_global_enrt.g_global_asg_rec_type;
  --
  l_who_counts             ben_efc_adjustments.g_who_counts;
  l_olddata                boolean;
  --
  l_row_count              pls_integer;
  l_calfail_count          pls_integer;
  l_calsucc_count          pls_integer;
  l_conv_count             pls_integer;
  l_unconv_count           pls_integer;
  l_actconv_count          pls_integer;
  l_dupconv_count          pls_integer;
  l_faterrs_count          pls_integer;
  l_rcoerr_count           pls_integer;
  l_tabrow_count           pls_integer;
  l_chunkrow_count         pls_integer;
  --
  l_pil_count              pls_integer;
  l_pilprv_count           pls_integer;
  l_nopilprv_count         pls_integer;
  --
  l_tmp_count              pls_integer;
  --
  l_sql_str                long;
  l_from_str               long;
  l_where_str              long;
  l_groupby_str            long;
  --
  l_efc_batch              boolean;
  l_pk1                    number;
  --
  l_prv_rtval_set          ben_det_enrt_rates.PRVRtVal_tab;
  --
  l_effective_date         date;
  --
  l_faterr_code            varchar2(100);
  l_faterr_type            varchar2(100);
  --
  l_adjfailed              boolean;
  l_val_type               varchar2(100);
  l_old_val1               number;
  l_new_val1               number;
  --
  l_allpilprv_count        pls_integer;
  --
  l_dtpen_count            pls_integer;
  l_prv_rt_val             number;
  l_prv_ann_rt_val         number;
  --
  l_rco_name               varchar2(100);
  --
  l_ecr_count              pls_integer;
  l_prv_id                 number;
  l_prv_uom                varchar2(100);
  l_ecrnomatchprv_count    pls_integer;
  --
  l_prev_bgp_id            number;
  --
  cursor c_prvdets
    (c_prv_id in number
    )
  is
    select prv.prtt_rt_val_id,
           prv.rt_val,
           prv.ann_rt_val,
           prv.cmcd_rt_val,
           pen.enrt_mthd_cd,
           prv.prtt_enrt_rslt_id,
           prv.acty_base_rt_id,
           prv.creation_date,
           prv.last_update_date,
           prv.object_version_number,
           prv.MLT_CD,
           pil.person_id,
           pil.per_in_ler_id
    from ben_prtt_rt_val prv,
         ben_prtt_enrt_rslt_f pen,
         ben_per_in_ler pil
    where prv.prtt_rt_val_id = c_prv_id
    and   pil.lf_evt_ocrd_dt
      between pen.effective_start_date and pen.effective_end_date
    and   prv.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
    and   prv.per_in_ler_id     = pil.per_in_ler_id;
  --
  l_prvdets c_prvdets%rowtype;
  --
  cursor c_enbdets
    (c_enb_id in number
    )
  is
    select enb.prtt_enrt_rslt_id
    from ben_enrt_bnft enb
    where enb.enrt_bnft_id = c_enb_id;
  --
  l_enbdets c_enbdets%rowtype;
  --
  cursor c_pilprv
    (c_pil_id in number
    )
  is
    select prv.acty_base_rt_id,
           prv.prtt_enrt_rslt_id,
           prv.creation_date,
           prv.last_update_date,
           prv.created_by,
           prv.last_updated_by,
           prv.last_update_login,
           prv.object_version_number,
           prv.business_group_id,
           prv.prtt_rt_val_id,
           prv.per_in_ler_id,
           prv.rt_val,
           prv.ann_rt_val,
           prv.mlt_cd,
           pil.person_id,
           prv.RT_END_DT
    from ben_prtt_rt_val prv,
         ben_per_in_ler pil
    where prv.per_in_ler_id = c_pil_id
    and   prv.per_in_ler_id = pil.per_in_ler_id
    and   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  l_pilprv c_pilprv%rowtype;
  --
  cursor c_ecrdets
    (c_prv_id in number
    )
  is
    select ecr.enrt_rt_id,
           ecr.rt_mlt_cd,
           ecr.enrt_bnft_id,
           ecr.elig_per_elctbl_chc_id,
           ecr.asn_on_enrt_flag,
           ecr.entr_val_at_enrt_flag,
           ecr.rt_strt_dt_cd
    from ben_enrt_rt ecr
    where ecr.prtt_rt_val_id = c_prv_id;
  --
  l_ecrdets c_ecrdets%rowtype;
  --
  cursor c_abrdets
    (c_abr_id   in number
    ,c_eff_date in date
    )
  is
    select abr.last_update_date,
           abr.rt_mlt_cd,
           abr.nnmntry_uom,
           abr.entr_val_at_enrt_flag,
           abr.rt_typ_cd,
           abr.val,
           abr.pgm_id,
           abr.ptip_id,
           abr.pl_id,
           abr.plip_id,
           abr.oipl_id,
           abr.oiplip_id,
           abr.actl_prem_id
    from ben_acty_base_rt_f abr
    where abr.acty_base_rt_id = c_abr_id
    and c_eff_date
      between abr.effective_start_date and abr.effective_end_date;
  --
  l_abrdets c_abrdets%rowtype;
  --
  cursor c_pendets
    (c_pen_id   in number
    ,c_eff_date in date
    )
  is
    select pen.effective_end_date,
           pen.enrt_cvg_strt_dt,
           pen.ENRT_CVG_THRU_DT,
           pen.pgm_id,
           pen.pl_id,
           pen.oipl_id,
           pen.prtt_enrt_rslt_stat_cd,
           pen.enrt_ovridn_flag,
           pen.sspndd_flag,
           pen.enrt_mthd_cd
    from ben_prtt_enrt_rslt_f pen
    where pen.prtt_enrt_rslt_id = c_pen_id
    and c_eff_date
      between pen.effective_start_date and pen.effective_end_date;
  --
  l_pendets c_pendets%rowtype;
  --
  cursor c_dtpendets
    (c_pen_id in number
    )
  is
    select pen.effective_end_date,
           pen.prtt_enrt_rslt_stat_cd
    from ben_prtt_enrt_rslt_f pen
    where pen.prtt_enrt_rslt_id = c_pen_id;
  --
  l_dtpendets c_dtpendets%rowtype;
  --
  cursor c_enrt_rt
    (c_elig_per_elctbl_chc_id in number
    ,c_prtt_enrt_rslt_id      in number
    )
  is
    select ecr.prtt_rt_val_id,
           ecr.enrt_rt_id,
           ecr.val,
           ecr.ann_val,
           ecr.rt_mlt_cd,
           ecr.SPCL_RT_ENRT_RT_ID,
           ecr.business_group_id,
           ecr.enrt_bnft_id,
           ecr.elig_per_elctbl_chc_id,
           ecr.acty_base_rt_id,
           ecr.entr_val_at_enrt_flag
    from ben_enrt_rt  ecr
    where ecr.elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id
      and ecr.SPCL_RT_ENRT_RT_ID is null
/*
      and ecr.entr_val_at_enrt_flag = 'N'
*/
/*
      and ecr.asn_on_enrt_flag = 'Y'
*/
  UNION
    select ecr.prtt_rt_val_id,
           ecr.enrt_rt_id,
           ecr.val,
           ecr.ann_val,
           ecr.rt_mlt_cd,
           ecr.SPCL_RT_ENRT_RT_ID,
           ecr.business_group_id,
           ecr.enrt_bnft_id,
           ecr.elig_per_elctbl_chc_id,
           ecr.acty_base_rt_id,
           ecr.entr_val_at_enrt_flag
    from ben_enrt_bnft  enb,
         ben_enrt_rt    ecr
    where enb.elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id
      and enb.ENRT_BNFT_ID           = ecr.ENRT_BNFT_ID
      and enb.prtt_enrt_rslt_id      = c_prtt_enrt_rslt_id
      and ecr.SPCL_RT_ENRT_RT_ID is null
/*
      and ecr.entr_val_at_enrt_flag = 'N'
*/
/*
      and ecr.asn_on_enrt_flag = 'Y'
*/
      ;
  --
  l_enrt_rt  c_enrt_rt%rowtype;
  --
  cursor c_elctbl_chc
    (c_pen_id   number
    ,c_pil_id   number
    ,c_eff_date date
    )
  is
    select epe.pgm_id,
           epe.pl_id,
           epe.oipl_id,
           epe.elig_per_elctbl_chc_id,
           epe.spcl_rt_pl_id,
           epe.spcl_rt_oipl_id,
           pel.acty_ref_perd_cd
    from ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil,
         ben_pil_elctbl_chc_popl  pel,
         ben_prtt_enrt_rslt_f pen
    where epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
    and   pil.per_in_ler_id          = epe.per_in_ler_id
    and   pil.per_in_ler_id          = c_pil_id
    and   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
    and   pen.prtt_enrt_rslt_id      = c_pen_id
    and   nvl(pen.pgm_id,-1)         = nvl(epe.pgm_id,-1)
    and   pen.pl_id                  = epe.pl_id
    and   nvl(pen.oipl_id,-1)        = nvl(epe.oipl_id,-1)
    and   c_eff_date
      between pen.effective_start_date and pen.effective_end_date;
  --
  l_elctbl_chc       c_elctbl_chc%rowtype;
  --
  cursor c_ncuuomdets
    (c_uom varchar2
    )
  is
    select ncu.currency_code
    from hr_ncu_currencies ncu
    where ncu.currency_code = c_uom;
  --
  l_ncuuomdets   c_ncuuomdets%rowtype;
  --
  cursor c_tmpprvefc
    (c_efc_action_id number
    ,c_pk1           number
    ,c_total_workers number
    ,c_worker_id     number
    )
  is
    select prvefc.prtt_rt_val_id
    from ben_prtt_rt_val_efc prvefc
    where prvefc.efc_action_id = c_efc_action_id
    and   prvefc.prtt_rt_val_id > c_pk1
    and   mod(prvefc.prtt_rt_val_id, c_total_workers) = c_worker_id;
  --
  l_tmpprvefc   c_tmpprvefc%rowtype;
  --
  --
  procedure check_adjusted_values
    (p_prv_mlt_cd         in     varchar2
    ,p_ecr_mlt_cd         in     varchar2
    ,p_old_prv_rt_val     in     number
    ,p_new_prv_rt_val     in     number
    ,p_old_prv_ann_rt_val in     number
    ,p_new_prv_ann_rt_val in     number
    --
    ,p_prv_id             in     number
    ,p_prvabr_id          in     number
    ,p_ecrabr_id          in     number
    ,p_ecrepe_id          in     number
    ,p_ecrenb_id          in     number
    ,p_eff_date           in     date
    ,p_efc_action_id      in     number
    --
    ,p_adjfailed             out nocopy boolean
    ,p_faterr_code           out nocopy varchar2
    ,p_faterr_type           out nocopy varchar2
    ,p_val_type              out nocopy varchar2
    ,p_old_val1              out nocopy number
    ,p_new_val1              out nocopy number
    ,p_prv_uom               out nocopy varchar2
    )
  is
    --
    l_currepe_row  ben_determine_rates.g_curr_epe_rec;
    l_currpil_row  ben_efc_adjustments.g_pil_rowtype;
    --
    l_vpfdets      ben_efc_adjustments.gc_vpfdets%rowtype;
    --
    l_adjfailed    boolean;
    l_old_val1     number;
    l_new_val1     number;
    l_faterr_code  varchar2(100);
    l_faterr_type  varchar2(100);
    l_par_pgm_id   number;
    l_par_pl_id    number;
    l_uom          varchar2(100);
    l_val_type     varchar2(100);
    l_preconv_val  number;
    l_postconv_val number;
    l_vpf_id       number;
    --
    cursor c_preconvdets
      (c_efc_action_id number
      ,c_prv_id        number
      )
    is
      select efc.rt_val,
             efc.ann_rt_val,
             efc.cmcd_rt_val,
             efc.pgm_uom,
             efc.nip_pl_uom
      from ben_prtt_rt_val_efc efc
      where efc.efc_action_id  = c_efc_action_id
      and   efc.prtt_rt_val_id = c_prv_id;
    --
    l_preconvdets c_preconvdets%rowtype;
    --
    cursor c_aprdets
      (c_apr_id   number
      ,c_eff_date date
      )
    is
      select apr.uom
      from ben_actl_prem_f apr
      where apr.actl_prem_id = c_apr_id
      and c_eff_date
        between apr.effective_start_date and apr.effective_end_date;
    --
    l_aprdets c_aprdets%rowtype;
    --
    cursor c_vpfabrdets
      (c_vpf_id   number
      ,c_eff_date date
      )
    is
      SELECT abr.pgm_id,
             abr.ptip_id,
             abr.pl_id,
             abr.plip_id,
             abr.oipl_id,
             abr.oiplip_id,
             abr.nnmntry_uom
      FROM ben_vrbl_rt_prfl_f vpf
         , ben_acty_vrbl_rt_f avr
         , ben_acty_base_rt_f abr
      WHERE avr.vrbl_rt_prfl_id = c_vpf_id
      AND vpf.VRBL_USG_CD = 'RT'
      AND vpf.vrbl_rt_prfl_id = avr.vrbl_rt_prfl_id
      AND avr.acty_base_rt_id = abr.acty_base_rt_id
      AND c_eff_date
        BETWEEN avr.effective_start_date AND avr.effective_end_date
      AND c_eff_date
        BETWEEN abr.effective_start_date AND abr.effective_end_date
      AND avr.acty_base_rt_id =
        (select min(avr1.acty_base_rt_id)
         from ben_acty_vrbl_rt_f avr1,
              ben_acty_base_rt_f abr1
         where avr1.vrbl_rt_prfl_id = avr.vrbl_rt_prfl_id
         AND vpf.effective_start_date
           BETWEEN avr1.effective_start_date AND avr1.effective_end_date
         AND avr1.acty_base_rt_id = abr1.acty_base_rt_id
         AND vpf.effective_start_date
           BETWEEN abr1.effective_start_date AND abr1.effective_end_date
         and abr1.NNMNTRY_UOM is null
         and avr1.ordr_num =
           (select min(avr2.ordr_num)
            from ben_acty_vrbl_rt_f avr2,
                 ben_acty_base_rt_f abr2
            where avr2.vrbl_rt_prfl_id = avr.vrbl_rt_prfl_id
            AND vpf.effective_start_date
              BETWEEN avr2.effective_start_date AND avr2.effective_end_date
            AND avr2.acty_base_rt_id = abr1.acty_base_rt_id
            AND vpf.effective_start_date
              BETWEEN abr2.effective_start_date AND abr2.effective_end_date
            and abr2.NNMNTRY_UOM is null
           )
        )
      ORDER BY avr.ORDR_NUM;

    l_vpfabrdets c_vpfabrdets%rowtype;

  begin
    --
    l_adjfailed := FALSE;
    l_old_val1  := null;
    l_new_val1  := null;
    l_val_type  := null;
    --
    if nvl(p_old_prv_rt_val,999) <> nvl(p_new_prv_rt_val,999)
    then
      --
      l_adjfailed := TRUE;
      l_val_type  := 'PRV_RTVAL';
      l_old_val1  := p_old_prv_rt_val;
      l_new_val1  := p_new_prv_rt_val;
      --
    end if;
    --
    if nvl(p_old_prv_ann_rt_val,999) <> nvl(p_new_prv_ann_rt_val,999)
      and not l_adjfailed
    then
      --
      l_adjfailed := TRUE;
      l_val_type  := 'PRV_ANNRTVAL';
      l_old_val1  := p_old_prv_ann_rt_val;
      l_new_val1  := p_new_prv_ann_rt_val;
      --
    end if;
    --
    -- Success and failure exclusions
    --
    if l_faterr_code is null then
      --
      open c_abrdets
        (c_abr_id   => p_prvabr_id
        ,c_eff_date => p_eff_date
        );
      fetch c_abrdets into l_abrdets;
      if c_abrdets%notfound
      then
        --
        l_adjfailed   := TRUE;
        l_faterr_code := 'NODTABR';
        l_faterr_type := 'DELETEDINFO';
        --
      end if;
      close c_abrdets;
      --
      if l_faterr_code is null
        and l_abrdets.nnmntry_uom is not null
      then
        --
        l_adjfailed   := TRUE;
        l_faterr_code := 'ABRNONMONUOM';
        l_faterr_type := 'VALIDEXCLUSION';
      --
      -- Check for enter value at enrolment
      --
      elsif l_abrdets.entr_val_at_enrt_flag = 'Y'
        and l_faterr_code is null
      then
        --
        l_adjfailed   := TRUE;
        l_faterr_code := 'ABREVAEFLGY';
        l_faterr_type := 'VALIDEXCLUSION';
        --
      end if;
      --
      if l_abrdets.actl_prem_id is not null
        and p_prv_mlt_cd = 'AP'
        and l_faterr_code is null
      then
        --
        open c_aprdets
          (c_apr_id   => l_abrdets.actl_prem_id
          ,c_eff_date => p_eff_date
          );
        fetch c_aprdets into l_aprdets;
        if c_aprdets%notfound then
          --
          l_adjfailed   := TRUE;
          l_faterr_code := 'NODTAPR';
          l_faterr_type := 'DELETEDINFO';
          --
        end if;
        close c_aprdets;
        --
        if l_aprdets.uom = 'EUR'
          and l_faterr_code is null
        then
          --
          l_adjfailed   := TRUE;
          l_faterr_code := 'ABRAPREUROUOM';
          l_faterr_type := 'VALIDEXCLUSION';
          --
        end if;
        --
      end if;
      --
    end if;
    --
    if l_faterr_code is null then
      --
      l_uom := null;
      --
      ben_efc_functions.CompObject_GetParUom
        (p_pgm_id      => l_abrdets.pgm_id
        ,p_ptip_id     => l_abrdets.ptip_id
        ,p_pl_id       => l_abrdets.pl_id
        ,p_plip_id     => l_abrdets.plip_id
        ,p_oipl_id     => l_abrdets.oipl_id
        ,p_oiplip_id   => l_abrdets.oiplip_id
        ,p_eff_date    => p_eff_date
        --
        ,p_paruom      => l_uom
        ,p_faterr_code => l_faterr_code
        ,p_faterr_type => l_faterr_type
        );
      --
      if l_faterr_code is not null then
        --
        l_adjfailed   := TRUE;
        --
      end if;
      --
    end if;
    --
    if p_prv_mlt_cd = 'FLFX'
      and l_faterr_code is null
    then
      --
      l_adjfailed   := TRUE;
      l_faterr_code := 'PRVFLFX';
      l_faterr_type := 'VALIDEXCLUSION';
      --
    elsif nvl(p_ecr_mlt_cd,'ZZZ') = 'FLFX'
      and l_faterr_code is null
    then
      --
      l_adjfailed   := TRUE;
      l_faterr_code := 'ECRMCFLFX';
      l_faterr_type := 'VALIDEXCLUSION';
      --
    elsif l_uom = 'POINTS'
      and l_faterr_code is null
    then
      --
      l_adjfailed   := TRUE;
      l_faterr_code := 'PGMPOINTSUOM';
      l_faterr_type := 'VALIDEXCLUSION';
      --
    elsif nvl(p_ecr_mlt_cd,'ZZZ') = 'NSVU'
      and l_faterr_code is null
      and (p_ecrepe_id is not null or p_ecrenb_id is not null)
    then
      --
      -- Detect EPE or ENB Info
      --
      ben_efc_adjustments.DetectEPEENBInfo
        (p_elig_per_elctbl_chc_id => p_ecrepe_id
        ,p_enrt_bnft_id           => p_ecrenb_id
        --
        ,p_detect_mode            => 'EPEINFO'
        --
        ,p_currepe_row            => l_currepe_row
        ,p_currpil_row            => l_currpil_row
        ,p_faterr_code            => l_faterr_code
        ,p_faterr_type            => l_faterr_type
        );
      --
      -- Validate vapro
      --
      if l_faterr_code is null then
        --
        ben_efc_adjustments.DetectVAPROInfo
          (p_currepe_row      => l_currepe_row
          --
          ,p_lf_evt_ocrd_dt   => l_currepe_row.lf_evt_ocrd_dt
          ,p_last_update_date => null
          --
          ,p_acty_base_rt_id  => p_prvabr_id
          --
          ,p_vpfdets          => l_vpfdets
          ,p_vpf_id           => l_vpf_id
          ,p_faterr_code      => l_faterr_code
          ,p_faterr_type      => l_faterr_type
          );
        --
        if l_faterr_code is not null
        then
          --
          l_adjfailed   := TRUE;
          --
        else
          --
          open c_vpfabrdets
            (c_vpf_id   => l_vpf_id
            ,c_eff_date => p_eff_date
            );
          fetch c_vpfabrdets into l_vpfabrdets;
          if c_vpfabrdets%notfound then
            --
            l_adjfailed   := TRUE;
            l_faterr_code := 'NODTVPFABR';
            l_faterr_type := 'DELETEDINFO';
            --
          else
            --
            ben_efc_functions.CompObject_GetParUom
              (p_pgm_id      => l_vpfabrdets.pgm_id
              ,p_ptip_id     => l_vpfabrdets.ptip_id
              ,p_pl_id       => l_vpfabrdets.pl_id
              ,p_plip_id     => l_vpfabrdets.plip_id
              ,p_oipl_id     => l_vpfabrdets.oipl_id
              ,p_oiplip_id   => l_vpfabrdets.oiplip_id
              ,p_eff_date    => p_eff_date
              --
              ,p_paruom      => l_uom
              ,p_faterr_code => l_faterr_code
              ,p_faterr_type => l_faterr_type
              );
            --
            if l_vpfabrdets.nnmntry_uom is not null
              and l_faterr_code is null
            then
              --
              l_adjfailed   := TRUE;
              l_faterr_code := 'VPFABRNONMONUOM';
              l_faterr_type := 'VALIDEXCLUSION';
            --
            elsif l_uom = 'POINTS'
              and l_faterr_code is null
            then
              --
              l_adjfailed   := TRUE;
              l_faterr_code := 'VPFPOINTSUOM';
              l_faterr_type := 'VALIDEXCLUSION';
              --
            end if;
            --
          end if;
          close c_vpfabrdets;
          --
        end if;
        --
      end if;
      --
    end if;
/*
    --
    -- Check conversion info
    --
    if l_faterr_code is null
      and p_efc_action_id is not null
    then
      --
      -- Check for non NCU UOMs
      --
      if l_faterr_code is null
        and l_uom is not null
      then
        --
        open c_ncuuomdets
          (c_uom => l_uom
          );
        fetch c_ncuuomdets into l_ncuuomdets;
        if c_ncuuomdets%notfound then
          --
          l_adjfailed   := TRUE;
          l_faterr_code := 'NOTNCUUOM';
          l_faterr_type := 'VALIDEXCLUSION';
          --
        end if;
        close c_ncuuomdets;
        --
      end if;
      --
      -- get pre conversion details
      --
      open c_preconvdets
        (c_efc_action_id => p_efc_action_id
        ,c_prv_id        => p_prv_id
        );
      fetch c_preconvdets into l_preconvdets;
      if c_preconvdets%notfound then
        --
        l_faterr_code   := 'NOEFCACTEEV';
        l_faterr_type   := 'CORRUPTDATA';
        --
      end if;
      close c_preconvdets;
      --
      if l_faterr_code is null
        and l_adjfailed
      then
        --
        if l_val_type = 'PRV_RTVAL' then
          --
          l_preconv_val := l_preconvdets.rt_val;
          --
        elsif l_val_type = 'PRV_ANNRTVAL' then
          --
          l_preconv_val := l_preconvdets.ann_rt_val;
          --
        end if;
        --
        ben_efc_adjustments.DetectConvInfo
          (p_ncucurr_code => l_uom
          ,p_new_val      => l_new_val1
          ,p_preconv_val  => l_preconv_val
          --
          ,p_faterr_code  => l_faterr_code
          ,p_faterr_type  => l_faterr_type
          ,p_postconv_val => l_postconv_val
          );
        --
      end if;
      --
    end if;
*/
    --
    -- Failure exclusions
    --
    -- Check for null values
    --
    if l_new_val1 is null
      and l_adjfailed
      and l_faterr_code is null
    then
      --
      l_faterr_code   := 'NULLADJPRVVAL';
      l_faterr_type   := 'ADJUSTBUG';
      --
    end if;
    --
    if not l_adjfailed
      and l_faterr_code is null
    then
      --
      l_val_type  := 'PRV_RTVAL';
      l_old_val1  := p_old_prv_rt_val;
      l_new_val1  := p_new_prv_rt_val;
      --
    end if;
    --
    p_adjfailed   := l_adjfailed;
    p_old_val1    := l_old_val1;
    p_new_val1    := l_new_val1;
    p_faterr_code := l_faterr_code;
    p_faterr_type := l_faterr_type;
    p_val_type    := l_val_type;
    p_prv_uom     := l_uom;
    --
  end;
  --
  procedure update_prv
    (p_prtt_rt_val_id in     number
    ,p_rt_val         in     number
    ,p_ann_rt_val     in     number
    ,p_chunk          in     number
    ,p_efc_worker_id  in     number
    ,p_chunkrow_count in out nocopy number
    )
  is

  begin
    --
    update ben_prtt_rt_val prv
    set  prv.rt_val      = p_rt_val,
         prv.ann_rt_val  = p_ann_rt_val
    where prv.prtt_rt_val_id = p_prtt_rt_val_id;
    --
    -- Check for end of chunk and commit if necessary
    --
    ben_efc_functions.maintain_chunks
      (p_row_count     => p_chunkrow_count
      ,p_pk1           => p_prtt_rt_val_id
      ,p_chunk_size    => p_chunk
      ,p_efc_worker_id => p_efc_worker_id
      );
    --
  end;
  --
begin
  --
  l_efc_batch         := FALSE;
  --
  l_row_count         := 0;
  l_calfail_count     := 0;
  l_calsucc_count     := 0;
  l_dupconv_count     := 0;
  l_conv_count        := 0;
  l_actconv_count     := 0;
  l_unconv_count      := 0;
  l_faterrs_count     := 0;
  l_rcoerr_count      := 0;
  --
  l_pil_count         := 0;
  --
  l_chunkrow_count    := 0;
  l_allpilprv_count   := 0;
  --
  ben_efc_adjustments.g_prv_success_adj_val_set.delete;
  ben_efc_adjustments.g_prv_failed_adj_val_set.delete;
  ben_efc_adjustments.g_prv_rcoerr_val_set.delete;
  ben_efc_adjustments.g_prv_fatal_error_val_set.delete;
  --
  -- Check if EFC process parameters are set
  --
  if p_action_id is not null
    and p_pk1 is not null
    and p_chunk is not null
    and p_efc_worker_id is not null
  then
    --
    l_efc_batch := TRUE;
    --
  end if;
  --
  l_from_str := ' FROM ben_prtt_rt_val prv, '
                ||'    ben_per_in_ler pil, '
                ||'    per_all_people_f per ';
  --
  l_where_str := ' where prv.per_in_ler_id = pil.per_in_ler_id '
                 ||' and pil.person_id = per.person_id '
                 ||' and per.effective_start_date = '
                 ||'   (select min(per1.effective_start_date) '
                 ||'    from   per_all_people_f per1 '
                 ||'    where  per.person_id = per1.person_id '
                 ||'   ) '
                 ||' and pil.lf_evt_ocrd_dt '
                 ||'   between per.effective_start_date and per.effective_end_date '
/* Exclude out nocopy voided and backed out nocopy life events */
                 ||' and pil.per_in_ler_stat_cd not in ('
                 ||''''||'VOIDD'||''''||','||''''||'BCKDT'||''''||') '
                 ||' and (prv.rt_val is not null '
                 ||' or prv.ann_rt_val is not null '
                 ||' or prv.cmcd_rt_val is not null) ';
  --
  -- Check if we are restricting by business group
  --
  if p_business_group_id is not null then
    --
    l_where_str := l_where_str||' and prv.business_group_id = '||p_business_group_id;
    --
  end if;
  --
  l_groupby_str := ' pil.person_id, '
                   ||' pil.per_in_ler_id, '
                   ||' pil.business_group_id, '
                   ||' pil.lf_evt_ocrd_dt, '
                   ||' pil.creation_date, '
                   ||' pil.last_update_date, '
                   ||' pil.object_version_number ';
  --
  -- Build in batch specific restrictions
  --
  if l_efc_batch then
    --
    l_from_str  := l_from_str||', ben_prtt_rt_val_efc efc ';
    l_where_str := l_where_str||' and efc.prtt_rt_val_id = prv.prtt_rt_val_id '
                   ||' and   efc.efc_action_id           = :action_id '
                   ||' and   prv.prtt_rt_val_id          > :pk1 '
                   ||' and   mod(prv.prtt_rt_val_id, :total_workers) = :worker_id ';
    --
  elsif p_valworker_id is not null
    and p_valtotal_workers is not null
  then
    --
    l_where_str := l_where_str||' and mod(pil.per_in_ler_id, :valtotal_workers) = :valworker_id ';
    --
  end if;
  --
  l_sql_str  := ' select '||l_groupby_str
                ||l_from_str
                ||l_where_str
                ||' group by '||l_groupby_str
                ||' order by pil.per_in_ler_id ';
  --
  if l_efc_batch then
    --
    hr_efc_info.insert_line('-- ');
    hr_efc_info.insert_line('-- Adjusting participant rate values ');
    hr_efc_info.insert_line('-- ');
    --
    open c_efc_rows FOR l_sql_str using p_action_id, p_pk1, p_total_workers, p_worker_id;
    --
  elsif p_valworker_id is not null
    and p_valtotal_workers is not null
  then
    --
    open c_efc_rows FOR l_sql_str using p_valtotal_workers, p_valworker_id;
    --
  else
    --
    open c_efc_rows FOR l_sql_str;
    --
  end if;
  --
  loop
    FETCH c_efc_rows INTO l_efc_row;
    EXIT WHEN c_efc_rows%NOTFOUND;
    --
    l_faterr_code := null;
    l_faterr_type := null;
    --
    l_effective_date := l_efc_row.lf_evt_ocrd_dt;
    --
    -- Set up benefits environment
    --
    ben_env_object.init
      (p_business_group_id => l_efc_row.business_group_id
      ,p_effective_date    => l_effective_date
      ,p_thread_id         => 1
      ,p_chunk_size        => 10
      ,p_threads           => 1
      ,p_max_errors        => 100
      ,p_benefit_action_id => 99999
      ,p_audit_log_flag    => 'N'
      );
    --
    -- Check if the payroll id is set for the employee or benefit assignment
    --
    ben_global_enrt.get_asg  -- assignment
      (p_person_id      => l_efc_row.person_id
      ,p_effective_date => l_effective_date
      ,p_global_asg_rec => l_global_asg_rec
      );
    --
    if l_global_asg_rec.payroll_id is null
      and l_faterr_code is null
    then
      --
      l_faterr_code := 'NOASGPAY';
      l_faterr_type := 'MISSINGSETUP';
      --
    end if;
    --
    if l_faterr_code is null then
      --
      begin
        --
        -- Check for a business group change and refresh vapro caches
        --
        if l_efc_row.business_group_id <> nvl(l_prev_bgp_id,-9999)
        then
          --
          ben_rt_prfl_cache.clear_down_cache;
          l_prev_bgp_id := l_efc_row.business_group_id;
          --
        end if;
        --
        l_rco_name := 'BENRATEN';
        --
        ben_det_enrt_rates.p_det_enrt_rates
          (p_calculate_only_mode => TRUE
          ,p_person_id           => l_efc_row.person_id
          ,p_per_in_ler_id       => l_efc_row.per_in_ler_id
          ,p_enrt_mthd_cd        => null
          ,p_business_group_id   => l_efc_row.business_group_id
          ,p_effective_date      => l_effective_date
          ,p_validate            => FALSE
          --
          ,p_prv_rtval_set       => l_prv_rtval_set
          );
        --
        if l_prv_rtval_set.count > 0 then
          --
          for prvele_num in l_prv_rtval_set.first .. l_prv_rtval_set.last
          loop
            --
            l_faterr_code := null;
            l_faterr_type := null;
            l_adjfailed   := FALSE;
            l_prv_uom     := null;
            --
            open c_prvdets
              (c_prv_id => l_prv_rtval_set(prvele_num).prtt_rt_val_id
              );
            fetch c_prvdets into l_prvdets;
            if c_prvdets%notfound then
              --
              l_faterr_code   := 'CORRPRV';
              --
            end if;
            close c_prvdets;
            --
            if l_faterr_code is null then
              --
              check_adjusted_values
                (p_prv_mlt_cd         => l_prvdets.MLT_CD
                ,p_ecr_mlt_cd         => l_prv_rtval_set(prvele_num).ecr_rt_mlt_cd
                ,p_old_prv_rt_val     => l_prvdets.rt_val
                ,p_new_prv_rt_val     => l_prv_rtval_set(prvele_num).rt_val
                ,p_old_prv_ann_rt_val => l_prvdets.ann_rt_val
                ,p_new_prv_ann_rt_val => l_prv_rtval_set(prvele_num).ann_rt_val
                --
                ,p_prv_id             => l_prv_rtval_set(prvele_num).prtt_rt_val_id
                ,p_prvabr_id          => l_prvdets.acty_base_rt_id
                ,p_ecrabr_id          => null
                ,p_ecrepe_id          => null
                ,p_ecrenb_id          => null
                ,p_eff_date           => l_effective_date
                ,p_efc_action_id      => p_action_id
                --
                ,p_adjfailed          => l_adjfailed
                ,p_faterr_code        => l_faterr_code
                ,p_faterr_type        => l_faterr_type
                ,p_val_type           => l_val_type
                ,p_old_val1           => l_old_val1
                ,p_new_val1           => l_new_val1
                ,p_prv_uom            => l_prv_uom
                );
              --
            end if;
            --
            if l_adjfailed
              and l_faterr_code is null
            then
              --
              if l_faterr_code is null
              then
                --
                -- Check rounding
                --
                ben_efc_adjustments.DetectRoundInfo
                  (p_rndg_cd        => null
                  ,p_rndg_rl        => null
                  ,p_old_val        => l_old_val1
                  ,p_new_val        => l_new_val1
                  ,p_eff_date       => l_effective_date
                  --
                  ,p_faterr_code    => l_faterr_code
                  ,p_faterr_type    => l_faterr_type
                  );
                --
              end if;
              --
              if l_faterr_code is null
              then
                --
                -- Check if the coverage has been modified
                --
                ben_efc_adjustments.DetectWhoInfo
                  (p_creation_date         => l_prvdets.creation_date
                  ,p_last_update_date      => l_prvdets.last_update_date
                  ,p_object_version_number => l_prvdets.object_version_number
                  --
                  ,p_who_counts            => l_who_counts
                  ,p_faterr_code           => l_faterr_code
                  ,p_faterr_type           => l_faterr_type
                  );
                --
              end if;
              --
              if l_faterr_code is null then
                --
                ben_efc_adjustments.g_prv_failed_adj_val_set(l_calfail_count).id       := l_prv_rtval_set(prvele_num).prtt_rt_val_id;
                ben_efc_adjustments.g_prv_failed_adj_val_set(l_calfail_count).id1      := l_prvdets.prtt_enrt_rslt_id;
                ben_efc_adjustments.g_prv_failed_adj_val_set(l_calfail_count).id2      := l_efc_row.per_in_ler_id;
                ben_efc_adjustments.g_prv_failed_adj_val_set(l_calfail_count).old_val1 := l_old_val1;
                ben_efc_adjustments.g_prv_failed_adj_val_set(l_calfail_count).new_val1 := l_new_val1;
                ben_efc_adjustments.g_prv_failed_adj_val_set(l_calfail_count).val_type := l_val_type;
                ben_efc_adjustments.g_prv_failed_adj_val_set(l_calfail_count).credt    := l_prvdets.creation_date;
                ben_efc_adjustments.g_prv_failed_adj_val_set(l_calfail_count).lud      := l_prvdets.last_update_date;
                ben_efc_adjustments.g_prv_failed_adj_val_set(l_calfail_count).code1    := l_prvdets.mlt_cd;
                ben_efc_adjustments.g_prv_failed_adj_val_set(l_calfail_count).code2    := l_prv_rtval_set(prvele_num).ecr_rt_mlt_cd;
                ben_efc_adjustments.g_prv_failed_adj_val_set(l_calfail_count).code3    := l_prv_uom;
                --
                l_calfail_count := l_calfail_count+1;
                --
              end if;
              --
            end if;
            --
            -- Check for fatal errors
            --
            if l_faterr_code is not null
            then
              --
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).id          := l_prv_rtval_set(prvele_num).prtt_rt_val_id;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).faterr_code := l_faterr_code;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).faterr_type := l_faterr_type;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).old_val1    := l_old_val1;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).new_val1    := l_new_val1;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).lud         := l_prvdets.last_update_date;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).credt       := l_prvdets.creation_date;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).id1         := l_prvdets.prtt_enrt_rslt_id;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).id2         := l_efc_row.per_in_ler_id;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).code1       := l_prvdets.mlt_cd;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).code2       := l_prv_rtval_set(prvele_num).ecr_rt_mlt_cd;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).code3       := l_prv_uom;
              --
              l_faterrs_count := l_faterrs_count+1;
              --
            elsif l_faterr_code is null
              and not l_adjfailed
            then
              --
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).id       := l_prv_rtval_set(prvele_num).prtt_rt_val_id;
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).id1      := l_prvdets.prtt_enrt_rslt_id;
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).id2      := l_efc_row.per_in_ler_id;
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).old_val1 := l_old_val1;
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).new_val1 := l_new_val1;
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).val_type := l_val_type;
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).credt    := l_prvdets.creation_date;
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).lud      := l_prvdets.last_update_date;
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).code1    := l_prvdets.mlt_cd;
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).code2    := l_prv_rtval_set(prvele_num).ecr_rt_mlt_cd;
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).code3    := l_prv_uom;
              --
              l_calsucc_count := l_calsucc_count+1;
              --
            end if;
            --
            l_row_count := l_row_count+1;
            --
            if l_efc_batch
              and (l_faterr_code is null
                or nvl(l_faterr_type,'ZZZZ') = 'CONVEXCLUSION')
            then
              --
              update_prv
                (p_prtt_rt_val_id => l_prv_rtval_set(prvele_num).prtt_rt_val_id
                ,p_rt_val         => l_prv_rtval_set(prvele_num).rt_val
                ,p_ann_rt_val     => l_prv_rtval_set(prvele_num).ann_rt_val
                ,p_chunk          => p_chunk
                ,p_efc_worker_id  => p_efc_worker_id
                ,p_chunkrow_count => l_chunkrow_count
                );
              --
            end if;
            --
          end loop;
          --
        else
          --
          -- Check for corrupt PRVs for a PIL
          --
          l_pilprv_count := 0;
          --
          for pilprv_row in c_pilprv
            (c_pil_id => l_efc_row.per_in_ler_id
            )
          loop
            --
            l_faterr_code := null;
            l_faterr_type := null;
            l_adjfailed   := TRUE;
            l_prv_uom     := null;
            --
            if l_faterr_code is null then
              --
              open c_abrdets
                (c_abr_id   => pilprv_row.acty_base_rt_id
                ,c_eff_date => l_effective_date
                );
              fetch c_abrdets into l_abrdets;
              if c_abrdets%notfound then
                --
                l_faterr_code := 'NODTPRVABR';
                l_faterr_type := 'DELETEDINFO';
                --
              end if;
              close c_abrdets;
              --
              -- Check for a non monetary UOM
              --
              if l_abrdets.NNMNTRY_UOM is not null
                and l_faterr_code is null
              then
                --
                l_faterr_code   := 'ABRNONMONUOM';
                l_faterr_type   := 'VALIDEXCLUSION';
              --
              -- Check for enter value at enrolment
              --
              elsif l_abrdets.entr_val_at_enrt_flag = 'Y'
                and l_faterr_code is null
              then
                --
                l_faterr_code   := 'ABREVAEFLGY';
                l_faterr_type   := 'VALIDEXCLUSION';
                --
              end if;
              --
            end if;
            --
            -- Check PEN details
            --
            if l_faterr_code is null then
              --
              l_dtpen_count := 0;
              --
              for row in c_dtpendets
                (c_pen_id => pilprv_row.prtt_enrt_rslt_id
                )
              loop
                --
                if row.prtt_enrt_rslt_stat_cd in ('BCKDT','VOIDD') then
                  --
                  l_faterr_code := 'BACKVOIDPEN';
                  l_faterr_type := 'VALIDEXCLUSION';
                  --
                end if;
                --
                l_dtpen_count := l_dtpen_count+1;
                --
              end loop;
              --
              if l_dtpen_count = 0
                and l_faterr_code is null
              then
                --
                l_faterr_code := 'NOPEN';
                l_faterr_type := 'DELETEDINFO';
                --
              end if;
              --
            end if;
            --
            -- Check for a set ESD other than EOT
            --
            if l_faterr_code is null
            then
              --
              open c_elctbl_chc
                (c_pen_id   => pilprv_row.prtt_enrt_rslt_id
                ,c_pil_id   => l_efc_row.per_in_ler_id
                ,c_eff_date => l_effective_date
                );
              fetch c_elctbl_chc into l_elctbl_chc;
              if c_elctbl_chc%notfound then
                --
                open c_pendets
                  (c_pen_id   => pilprv_row.prtt_enrt_rslt_id
                  ,c_eff_date => l_effective_date
                  );
                fetch c_pendets into l_pendets;
                if c_pendets%notfound then
                  --
                  l_faterr_code := 'NOPILLEODPRVPEN';
                  l_faterr_type := 'UNSUPPORTTRANS';
                  --
                else
                  --
                  l_faterr_code := 'NOPENEPE';
                  l_faterr_type := 'POTENTIALCODEBUG';
                  --
                end if;
                close c_pendets;
                --
              end if;
              close c_elctbl_chc;
              --
              if l_elctbl_chc.elig_per_elctbl_chc_id is not null
                and l_faterr_code is null
              then
                --
                l_ecr_count := 0;
                l_ecrnomatchprv_count := 0;
                --
                for ecr_row in c_enrt_rt
                  (c_elig_per_elctbl_chc_id => l_elctbl_chc.elig_per_elctbl_chc_id
                  ,c_prtt_enrt_rslt_id      => pilprv_row.prtt_enrt_rslt_id
                  )
                loop
                  --
                  if l_ecr_count = 0
                    and pilprv_row.prtt_rt_val_id = ecr_row.prtt_rt_val_id
                  then
                    --
                    l_enrt_rt := ecr_row;
                    l_ecr_count := 1;
                    --
                  elsif pilprv_row.prtt_rt_val_id = ecr_row.prtt_rt_val_id
                  then
                    --
                    l_ecr_count := l_ecr_count+1;
                    --
                  else
                    --
                    l_ecrnomatchprv_count := l_ecrnomatchprv_count+1;
                    --
                  end if;
                  --
                end loop;
                --
                if l_ecr_count = 1
                then
                  --
                  begin
                    --
                    l_rco_name := 'BENELINF_ERI';
                    l_prv_id := pilprv_row.prtt_rt_val_id;
                    --
                    ben_election_information.election_rate_information
                      (p_calculate_only_mode => TRUE
                      ,p_enrt_mthd_cd        => l_pendets.enrt_mthd_cd
                      ,p_effective_date      => l_effective_date
                      ,p_prtt_enrt_rslt_id   => pilprv_row.prtt_enrt_rslt_id
                      ,p_per_in_ler_id       => l_efc_row.per_in_ler_id
                      ,p_person_id           => l_efc_row.person_id
                      ,p_pgm_id              => l_elctbl_chc.pgm_id
                      ,p_pl_id               => l_elctbl_chc.pl_id
                      ,p_oipl_id             => l_elctbl_chc.oipl_id
                      ,p_enrt_rt_id          => l_enrt_rt.enrt_rt_id
                      ,p_prtt_rt_val_id      => l_prv_id
                      ,p_rt_val              => l_enrt_rt.val
                      ,p_ann_rt_val          => l_enrt_rt.ann_val
                      ,p_enrt_cvg_strt_dt    => l_pendets.enrt_cvg_strt_dt
                      ,p_acty_ref_perd_cd    => l_elctbl_chc.acty_ref_perd_cd
                      ,p_datetrack_mode      => null
                      ,p_business_group_id   => pilprv_row.business_group_id
                      --
                      ,p_prv_rt_val          => l_prv_rt_val
                      ,p_prv_ann_rt_val      => l_prv_ann_rt_val
                      );
                    --
                    check_adjusted_values
                      (p_prv_mlt_cd         => pilprv_row.mlt_cd
                      ,p_ecr_mlt_cd         => l_enrt_rt.rt_mlt_cd
                      ,p_old_prv_rt_val     => pilprv_row.rt_val
                      ,p_new_prv_rt_val     => l_prv_rt_val
                      ,p_old_prv_ann_rt_val => pilprv_row.ann_rt_val
                      ,p_new_prv_ann_rt_val => l_prv_ann_rt_val
                      --
                      ,p_prv_id             => pilprv_row.prtt_rt_val_id
                      ,p_prvabr_id          => pilprv_row.acty_base_rt_id
                      ,p_ecrabr_id          => l_enrt_rt.acty_base_rt_id
                      ,p_ecrepe_id          => l_enrt_rt.elig_per_elctbl_chc_id
                      ,p_ecrenb_id          => l_enrt_rt.enrt_bnft_id
                      ,p_eff_date           => l_effective_date
                      ,p_efc_action_id      => p_action_id
                      --
                      ,p_adjfailed          => l_adjfailed
                      ,p_faterr_code        => l_faterr_code
                      ,p_faterr_type        => l_faterr_type
                      ,p_val_type           => l_val_type
                      ,p_old_val1           => l_old_val1
                      ,p_new_val1           => l_new_val1
                      ,p_prv_uom            => l_prv_uom
                      );
                    --
                  exception
                    when others then
                      --
                      ben_efc_adjustments.DetectAppError
                        (p_sqlerrm                   => SQLERRM
                        ,p_abr_rt_mlt_cd             => l_abrdets.rt_mlt_cd
                        ,p_abr_val                   => l_abrdets.val
                        ,p_abr_entr_val_at_enrt_flag => l_abrdets.entr_val_at_enrt_flag
                        ,p_abr_id                    => pilprv_row.acty_base_rt_id
                        ,p_eff_date                  => l_effective_date
                        ,p_penepe_id                 => l_elctbl_chc.elig_per_elctbl_chc_id
                        --
                        ,p_faterr_code               => l_faterr_code
                        ,p_faterr_type               => l_faterr_type
                        );
                      --
                      if l_faterr_code is null then
                        --
                        ben_efc_adjustments.g_prv_rcoerr_val_set(l_rcoerr_count).id        := l_efc_row.per_in_ler_id;
                        ben_efc_adjustments.g_prv_rcoerr_val_set(l_rcoerr_count).rco_name  := l_rco_name;
                        ben_efc_adjustments.g_prv_rcoerr_val_set(l_rcoerr_count).sql_error := SQLERRM;
                        ben_efc_adjustments.g_prv_rcoerr_val_set(l_rcoerr_count).credt     := l_efc_row.creation_date;
                        ben_efc_adjustments.g_prv_rcoerr_val_set(l_rcoerr_count).lud       := l_efc_row.last_update_date;
                        --
                        l_rcoerr_count := l_rcoerr_count+1;
                        --
                      end if;
                      --
                  end;
                  --
                elsif l_ecr_count > 1 then
                  --
                  l_faterr_code     := 'MULTPENEPEECR';
                  l_faterr_type     := 'POTENTIALCODEBUG';
                  --
                elsif l_ecr_count = 0
                  and l_ecrnomatchprv_count > 0
                then
                  --
                  l_faterr_code     := 'ECRMCFLFX';
                  l_faterr_type     := 'VALIDEXCLUSION';
                  --
                else
                  --
                  l_faterr_code     := 'NOPENEPEECR';
                  l_faterr_type     := 'POTENTIALCODEBUG';
                  --
                end if;
                --
              end if;
              --
            end if;
            --
            if l_faterr_code is null
              and l_adjfailed
            then
              --
              -- Check rounding
              --
              ben_efc_adjustments.DetectRoundInfo
                (p_rndg_cd        => null
                ,p_rndg_rl        => null
                ,p_old_val        => l_old_val1
                ,p_new_val        => l_new_val1
                ,p_eff_date       => l_effective_date
                --
                ,p_faterr_code    => l_faterr_code
                ,p_faterr_type    => l_faterr_type
                );
              --
            end if;
            --
            -- Check for a PRV mod
            --
            if pilprv_row.creation_date <> pilprv_row.last_update_date
              and l_faterr_code is null
              and l_adjfailed
            then
              --
              if pilprv_row.RT_END_DT <> hr_api.g_eot
              then
                --
                l_faterr_code     := 'PRVENDDATED';
                l_faterr_type     := 'UNSUPPORTTRANS';
                --
              else
                --
                l_faterr_code     := 'PRVMODIFIED';
                l_faterr_type     := 'UNSUPPORTTRANS';
                --
              end if;
              --
              -- Check for a set ECTD other than EOT
              --
              if l_pendets.ENRT_CVG_THRU_DT <> hr_api.g_eot
                and l_faterr_code is null
                and l_adjfailed
              then
                --
                l_faterr_code     := 'PRVPENECTDSET';
                l_faterr_type     := 'UNSUPPORTTRANS';
                --
              end if;
              --
              -- Check for a set ESD other than EOT
              --
              if l_pendets.effective_end_date <> hr_api.g_eot
                and l_faterr_code is null
                and l_adjfailed
              then
                --
                l_faterr_code     := 'PRVPENEEDSET';
                l_faterr_type     := 'UNSUPPORTTRANS';
                --
              end if;
              --
              -- Check for an overidden enrolment. Created from
              -- ben_lf_evt_clps_restore.reinstate_the_prev_enrt
              --
              if l_pendets.enrt_ovridn_flag = 'Y'
                and l_faterr_code is null
                and l_adjfailed
              then
                --
                l_faterr_code     := 'OVERIDDENPEN';
                --
              end if;
              --
            end if;
            --
            if l_faterr_code is null
              and l_adjfailed
            then
              --
              -- Get the attached ECR ID for the PRV
              --
              open c_ecrdets
                (c_prv_id => pilprv_row.prtt_rt_val_id
                );
              fetch c_ecrdets into l_ecrdets;
              if c_ecrdets%notfound then
                --
                l_faterr_code    := 'NOPRVECR';
                --
              end if;
              close c_ecrdets;
              --
            end if;
            --
            -- Check for a correction on the ABR
            --
            if l_abrdets.rt_mlt_cd <> l_ecrdets.rt_mlt_cd
              and l_faterr_code is null
              and l_adjfailed
            then
              --
              l_faterr_code := 'NMABRECRMLTCDS';
              l_faterr_type := 'POTENTIALCODEBUG';
              --
            end if;
            --
            -- Check for a ECR attached to coverage or electable choice
            --
            if l_ecrdets.enrt_bnft_id is not null
              and l_faterr_code is null
              and l_adjfailed
            then
              --
              -- Get the PEN ID from the enrolment benefit
              --
              open c_enbdets
                (c_enb_id => l_ecrdets.enrt_bnft_id
                );
              fetch c_enbdets into l_enbdets;
              close c_enbdets;
              --
              if nvl(pilprv_row.prtt_enrt_rslt_id,999) <> nvl(l_enbdets.prtt_enrt_rslt_id,999)
                and l_faterr_code is null
              then
                --
                l_faterr_code       := 'NMPRVENBPEN';
                --
              end if;
              --
            end if;
            --
            -- Check if the ASN on enrt flag is Y
            --
            if l_ecrdets.asn_on_enrt_flag = 'N'
              and l_faterr_code is null
              and l_adjfailed
            then
              --
              l_faterr_code     := 'ECRAOEFLGN';
              l_faterr_type     := 'VALIDEXCLUSION';
              --
            end if;
            --
            -- Check if the enter val at enrt flag is N
            --
            if l_ecrdets.entr_val_at_enrt_flag = 'Y'
              and l_faterr_code is null
              and l_adjfailed
            then
              --
              l_faterr_code     := 'EPEECREVAENFLGY';
              l_faterr_type     := 'VALIDEXCLUSION';
              --
            end if;
            --
            -- Check if the coverage has been modified
            --
            if l_faterr_code is null
              and l_adjfailed
            then
              --
              ben_efc_adjustments.DetectWhoInfo
                (p_creation_date         => pilprv_row.creation_date
                ,p_last_update_date      => pilprv_row.last_update_date
                ,p_object_version_number => pilprv_row.object_version_number
                --
                ,p_who_counts            => l_who_counts
                ,p_faterr_code           => l_faterr_code
                ,p_faterr_type           => l_faterr_type
                );
              --
            end if;
            --
            -- Check for fatal errors
            --
            if l_faterr_code is not null
            then
              --
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).id          := pilprv_row.prtt_rt_val_id;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).faterr_code := l_faterr_code;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).faterr_type := l_faterr_type;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).old_val1    := l_old_val1;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).new_val1    := l_new_val1;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).ovn         := pilprv_row.object_version_number;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).lud         := pilprv_row.last_update_date;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).credt       := pilprv_row.creation_date;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).id1         := pilprv_row.prtt_enrt_rslt_id;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).id2         := l_efc_row.per_in_ler_id;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).code1       := pilprv_row.mlt_cd;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).code2       := l_enrt_rt.rt_mlt_cd;
              ben_efc_adjustments.g_prv_fatal_error_val_set(l_faterrs_count).code3       := l_prv_uom;
              --
              l_faterrs_count := l_faterrs_count+1;
              --
            elsif not l_adjfailed
              and l_faterr_code is null
            then
              --
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).id       := pilprv_row.prtt_rt_val_id;
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).id2      := l_efc_row.per_in_ler_id;
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).old_val1 := l_old_val1;
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).new_val1 := l_new_val1;
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).credt    := pilprv_row.creation_date;
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).lud      := pilprv_row.last_update_date;
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).code1    := pilprv_row.mlt_cd;
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).code2    := l_enrt_rt.rt_mlt_cd;
              ben_efc_adjustments.g_prv_success_adj_val_set(l_calsucc_count).code3    := l_prv_uom;
              --
              l_calsucc_count := l_calsucc_count+1;
              --
            end if;
            --
            l_pilprv_count := l_pilprv_count+1;
            --
            if l_efc_batch
              and (l_faterr_code is null
                or nvl(l_faterr_type,'ZZZZ') = 'CONVEXCLUSION')
            then
              --
              update_prv
                (p_prtt_rt_val_id => pilprv_row.prtt_rt_val_id
                ,p_rt_val         => l_prv_rt_val
                ,p_ann_rt_val     => l_prv_ann_rt_val
                ,p_chunk          => p_chunk
                ,p_efc_worker_id  => p_efc_worker_id
                ,p_chunkrow_count => l_chunkrow_count
                );
              --
            end if;
            --
          end loop;
          --
          if l_pilprv_count = 0
            and l_faterr_code is null
          then
            --
            l_faterr_code := 'NOPILPRVS';
            l_faterr_type := 'DATACORRUPT';
            --
          end if;
          --
          -- Check if no PRVs exist for the PIL
          --
          if l_pilprv_count = 0
            and l_faterr_code is null
          then
            --
            ben_efc_adjustments.g_prv_failed_adj_val_set(l_calfail_count).id       := l_efc_row.per_in_ler_id;
            ben_efc_adjustments.g_prv_failed_adj_val_set(l_calfail_count).id1      := null;
            ben_efc_adjustments.g_prv_failed_adj_val_set(l_calfail_count).old_val1 := null;
            ben_efc_adjustments.g_prv_failed_adj_val_set(l_calfail_count).new_val1 := null;
            ben_efc_adjustments.g_prv_failed_adj_val_set(l_calfail_count).val_type := 'NORECALPRV';
            ben_efc_adjustments.g_prv_failed_adj_val_set(l_calfail_count).credt    := l_efc_row.creation_date;
            ben_efc_adjustments.g_prv_failed_adj_val_set(l_calfail_count).lud      := l_efc_row.last_update_date;
            --
            l_calfail_count := l_calfail_count+1;
            --
          end if;
          --
        end if;
        --
      exception
        when others then
          --
          ben_efc_adjustments.g_prv_rcoerr_val_set(l_rcoerr_count).id        := l_efc_row.per_in_ler_id;
          ben_efc_adjustments.g_prv_rcoerr_val_set(l_rcoerr_count).rco_name  := l_rco_name;
          ben_efc_adjustments.g_prv_rcoerr_val_set(l_rcoerr_count).sql_error := SQLERRM;
          ben_efc_adjustments.g_prv_rcoerr_val_set(l_rcoerr_count).credt     := l_efc_row.creation_date;
          ben_efc_adjustments.g_prv_rcoerr_val_set(l_rcoerr_count).lud       := l_efc_row.last_update_date;
          --
          l_rcoerr_count := l_rcoerr_count+1;
          --
      end;
      --
    end if;
    --
    -- Count PRVs
    --
    l_pilprv_count := 0;
    --
    for pilprv_row in c_pilprv
      (c_pil_id => l_efc_row.per_in_ler_id
      )
    loop
      --
      l_pilprv_count := l_pilprv_count+1;
      --
    end loop;
    --
    l_allpilprv_count := l_allpilprv_count+l_pilprv_count;
    l_pil_count := l_pil_count+1;
    --
  end loop;
  CLOSE c_efc_rows;
  --
  --Bug 5049253
  -- Write exceptions down to the table
/*
  --
  if l_efc_batch
    and p_valworker_id is null
    and p_valtotal_workers is null
  then
    --
    ben_efc_adjustments.insert_validation_exceptions
      (p_val_set        => ben_efc_adjustments.g_prv_failed_adj_val_set
      ,p_efc_action_id  => p_action_id
      ,p_ent_scode      => 'PRV'
      ,p_exception_type => 'AF'
      );
    --
    ben_efc_adjustments.insert_validation_exceptions
      (p_val_set        => ben_efc_adjustments.g_prv_fatal_error_val_set
      ,p_efc_action_id  => p_action_id
      ,p_ent_scode      => 'PRV'
      ,p_exception_type => null
      );
    --
  end if;
  */
--Bug  5049253
  --
  ben_efc_functions.conv_check
    (p_table_name       => 'ben_prtt_rt_val'
    ,p_efctable_name    => 'ben_prtt_rt_val_efc'
    ,p_tabwhere_clause  => ' (rt_val is not null '
                           ||' or ann_rt_val is not null '
                           ||' or cmcd_rt_val is not null) '
    ,p_bgp_id           => p_business_group_id
    ,p_action_id        => p_action_id
    --
    ,p_conv_count       => l_conv_count
    ,p_unconv_count     => l_unconv_count
    ,p_tabrow_count     => l_tabrow_count
    );
  --
  -- Set counts
  --
  if p_action_id is null then
    --
    l_actconv_count := 0;
    --
  else
    --
    l_actconv_count := l_conv_count;
    --
  end if;
  --
  -- Set counts
  --
  p_adjustment_counts.efcrow_count       := l_allpilprv_count;
  p_adjustment_counts.tabrow_count       := l_tabrow_count;
  p_adjustment_counts.actconv_count      := l_actconv_count;
  p_adjustment_counts.calfail_count      := l_calfail_count;
  p_adjustment_counts.calsucc_count      := l_calsucc_count;
  p_adjustment_counts.conv_count         := l_conv_count;
  p_adjustment_counts.unconv_count       := l_unconv_count;
  p_adjustment_counts.rcoerr_count       := l_rcoerr_count;
  --
end prv_adjustments;
--
procedure eev_adjustments
  (p_validate          in     boolean default false
  ,p_worker_id         in     number  default null
  ,p_action_id         in     number  default null
  ,p_total_workers     in     number  default null
  ,p_pk1               in     number  default null
  ,p_chunk             in     number  default null
  ,p_efc_worker_id     in     number  default null
  --
  ,p_valworker_id      in     number  default null
  ,p_valtotal_workers  in     number  default null
  --
  ,p_business_group_id in     number  default null
  --
  ,p_adjustment_counts    out nocopy ben_efc_adjustments.g_adjustment_counts
  )
is
  --
  TYPE cur_type IS REF CURSOR;
  --
  type g_efc_row is record
    (element_entry_value_id pay_element_entry_values_f.element_entry_value_id%type
    ,effective_start_date   pay_element_entry_values_f.effective_start_date%type
    ,effective_end_date     pay_element_entry_values_f.effective_end_date%type
    ,prv_creation_date      ben_prtt_rt_val.creation_date%type
    ,prv_last_update_date   ben_prtt_rt_val.last_update_date%type
    ,prv_last_update_login  ben_prtt_rt_val.last_update_login%type
    ,prv_created_by         ben_prtt_rt_val.created_by%type
    ,screen_entry_value     pay_element_entry_values_f.screen_entry_value%type
    ,enrt_mthd_cd           ben_prtt_enrt_rslt_f.enrt_mthd_cd%type
    ,business_group_id      ben_prtt_rt_val.business_group_id%type
    ,prtt_rt_val_id         ben_prtt_rt_val.prtt_rt_val_id%type
    ,acty_ref_perd_cd       ben_prtt_rt_val.acty_ref_perd_cd%type
    ,acty_base_rt_id        ben_prtt_rt_val.acty_base_rt_id%type
    ,prtt_enrt_rslt_id      ben_prtt_rt_val.prtt_enrt_rslt_id%type
    ,rt_strt_dt             ben_prtt_rt_val.rt_strt_dt%type
    ,rt_val                 ben_prtt_rt_val.rt_val%type
    ,prv_ovn                ben_prtt_rt_val.object_version_number%type
    ,input_value_id         ben_acty_base_rt_f.input_value_id%type
    ,element_type_id        ben_acty_base_rt_f.element_type_id%type
    ,lf_evt_ocrd_dt         ben_per_in_ler.lf_evt_ocrd_dt%type
    ,person_id              ben_per_in_ler.person_id%type
    ,per_in_ler_id          ben_per_in_ler.per_in_ler_id%type
    ,ELEMENT_ENTRY_ID       pay_element_entry_values_f.ELEMENT_ENTRY_ID%type
    );
  --
  c_efc_rows               cur_type;
  --
  l_proc                   varchar2(1000) := 'eev_adjustments';
  --
  l_efc_row                g_efc_row;
  --
  l_who_counts             ben_efc_adjustments.g_who_counts;
  l_prvwho_counts          ben_efc_adjustments.g_who_counts;
  l_olddata                boolean;
  --
  l_row_count              pls_integer;
  l_calfail_count          pls_integer;
  l_calsucc_count          pls_integer;
  l_conv_count             pls_integer;
  l_unconv_count           pls_integer;
  l_actconv_count          pls_integer;
  l_dupconv_count          pls_integer;
  l_rcoerr_count           pls_integer;
  l_faterrs_count          pls_integer;
  l_preadjexc_count        pls_integer;
  --
  l_sql_str                long;
  l_from_str               long;
  l_where_str              long;
  --
  l_efc_batch              boolean;
  l_pk1                    number;
  --
  l_assign_exists          boolean;
  l_dummy_id               number;
  l_count                  pls_integer;
  --
  l_tabrow_count           pls_integer;
  l_chunkrow_count         pls_integer;
  --
  l_eev_screen_entry_value number;
  l_dummy_number           number;
  --
  l_effective_date         date;
  l_faterr_code            varchar2(100);
  l_faterr_type            varchar2(100);
  --
  l_prev_pkid              number;
  l_prev_esd               date;
  --
  l_old_val1               number;
  l_new_val1               number;
  l_postconv_val           number;
  --
  l_adjfailed              boolean;
  --
  cursor c_multprveevs
    (c_eev_id in     number
    )
  is
    select count(*)
    from ben_prtt_rt_val
    where element_entry_value_id = c_eev_id;
  --
  cursor c_abrdets
    (c_abr_id   in number
    ,c_eff_date in date
    )
  is
    select abr.last_update_date,
           abr.ele_rqd_flag
    from ben_acty_base_rt_f abr
    where abr.acty_base_rt_id = c_abr_id
    and c_eff_date
      between abr.effective_start_date and abr.effective_end_date;
  --
  l_abrdets c_abrdets%rowtype;
  --
  cursor c_eledets
    (c_ele_id   in number
    ,c_eff_date in date
    )
  is
    select ele.creation_date,
           ele.last_update_date,
           ele.object_version_number,
           ele.created_by,
           ele.last_updated_by,
           ele.last_update_login
    from pay_element_entries_f ele
    where ele.ELEMENT_ENTRY_ID = c_ele_id
    and c_eff_date
      between ele.effective_start_date and ele.effective_end_date;
  --
  l_eledets c_eledets%rowtype;
  l_tmpdets c_eledets%rowtype;
  --
  cursor c_eledtinsts
    (c_ele_id in number
    )
  is
    select ele.effective_start_date,
           ele.effective_end_date
    from pay_element_entries_f ele
    where ele.ELEMENT_ENTRY_ID = c_ele_id;
  --
  l_eledtinsts c_eledtinsts%rowtype;
  --
  cursor c_preconvdets
    (c_efc_action_id number
    ,c_eev_id        number
    ,c_eev_esd       date
    )
  is
    select efc.SCREEN_ENTRY_VALUE,
           efc.input_currency_code
    from pay_element_entry_values_f_efc efc
    where efc.efc_action_id = c_efc_action_id
    and   efc.element_entry_value_id = c_eev_id
    and   efc.effective_start_date = c_eev_esd;
  --
  l_preconvdets c_preconvdets%rowtype;
  --
  cursor c_valexcexist
    (c_prv_id        number
    ,c_efc_action_id number
    ,c_ent_scode     varchar2
    )
  is
    select exc.efc_action_id
    from ben_efc_exclusions exc
    where exc.efc_action_id = c_efc_action_id
    and   exc.ent_scode     = c_ent_scode
    and   exc.pk_id         = c_prv_id
    and   exc.exclusion_type = 'VALIDEXCLUSION';
  --
  l_valexcexist c_valexcexist%rowtype;
  --
  cursor c_convvalexist
    (c_prv_id        number
    ,c_efc_action_id number
    )
  is
    select efc.efc_action_id
    from ben_prtt_rt_val_efc efc
    where efc.efc_action_id  = c_efc_action_id
    and   efc.prtt_rt_val_id = c_prv_id;
  --
  l_convvalexist c_convvalexist%rowtype;
  --
begin
  --
  l_efc_batch       := FALSE;
  --
  l_row_count       := 0;
  l_calfail_count   := 0;
  l_calsucc_count   := 0;
  l_dupconv_count   := 0;
  l_conv_count      := 0;
  l_actconv_count   := 0;
  l_unconv_count    := 0;
  l_rcoerr_count    := 0;
  l_faterrs_count   := 0;
  l_preadjexc_count := 0;
  l_chunkrow_count  := 0;
  --
  ben_efc_adjustments.g_eev_failed_adj_val_set.delete;
  ben_efc_adjustments.g_eev_rcoerr_val_set.delete;
  ben_efc_adjustments.g_eev_fatal_error_val_set.delete;
  ben_efc_adjustments.g_eev_success_adj_val_set.delete;
  --
  -- Check if EFC process parameters are set
  --
  if p_action_id is not null
    and p_pk1 is not null
    and p_chunk is not null
    and p_efc_worker_id is not null
  then
    --
    l_efc_batch := TRUE;
    --
  end if;
  --
  l_from_str := ' FROM pay_element_entry_values_f eev, '
                ||' ben_prtt_rt_val prv, '
                ||' ben_prtt_enrt_rslt_f pen, '
                ||' ben_acty_base_rt_f abr, '
                ||' ben_per_in_ler pil, '
                ||' per_all_people_f per ';
  --
  l_where_str := ' where prv.element_entry_value_id = eev.element_entry_value_id '
                 ||' and   prv.prtt_rt_val_id = '
                 ||'   (select min(prv1.prtt_rt_val_id) '
                 ||'    from   ben_prtt_rt_val prv1 '
                 ||'    where  prv.element_entry_value_id = prv1.element_entry_value_id '
                 ||'   ) '
                 ||' and   prv.rt_strt_dt '
                 ||'   between pen.effective_start_date and pen.effective_end_date '
                 ||' and   pen.effective_start_date = '
                 ||'   (select min(pen1.effective_start_date) '
                 ||'    from   ben_prtt_enrt_rslt_f pen1 '
                 ||'    where  pen.prtt_enrt_rslt_id = pen1.prtt_enrt_rslt_id '
                 ||'   ) '
                 ||'   and   prv.prtt_enrt_rslt_id  = pen.prtt_enrt_rslt_id '
                 ||' and   prv.acty_base_rt_id      = abr.acty_base_rt_id '
                 ||' and   prv.rt_strt_dt '
                 ||'   between abr.effective_start_date and abr.effective_end_date '
                 ||' and   abr.effective_start_date = '
                 ||'   (select min(abr1.effective_start_date) '
                 ||'    from   ben_acty_base_rt_f abr1 '
                 ||'    where  abr.acty_base_rt_id = abr1.acty_base_rt_id '
                 ||'   ) '
                 ||' and   prv.per_in_ler_id        = pil.per_in_ler_id '
                 ||' and   per.person_id            = pil.person_id '
                 ||' and   prv.rt_strt_dt '
                 ||'   between per.effective_start_date and per.effective_end_date '
                 ||' and   per.effective_start_date = '
                 ||'   (select min(per1.effective_start_date) '
                 ||'    from   per_all_people_f per1 '
                 ||'    where  per.person_id = per1.person_id '
                 ||'   ) '
                 ||' and   eev.screen_entry_value is not null '
/* Exclude out nocopy voided and backed out nocopy life events */
                 ||' and pil.per_in_ler_stat_cd not in ('
                 ||''''||'VOIDD'||''''||','||''''||'BCKDT'||''''||') '
                 ;
  --
  -- Check if we are restricting by business group
  --
  if p_business_group_id is not null then
    --
    l_where_str := l_where_str||' and prv.business_group_id = '||p_business_group_id;
    --
  end if;
  --
  -- Build in batch specific restrictions
  --
  if l_efc_batch then
    --
    l_from_str  := l_from_str||', pay_element_entry_values_f_efc efc ';
    l_where_str := l_where_str||' and efc.element_entry_value_id = eev.element_entry_value_id '
                   ||' and   efc.effective_start_date   = eev.effective_start_date '
                   ||' and   efc.efc_action_id          = :action_id '
                   ||' and   eev.element_entry_value_id > :pk1 '
                   ||' and   mod(eev.element_entry_value_id, :total_workers) = :worker_id ';
    --
  elsif p_valworker_id is not null
    and p_valtotal_workers is not null
  then
    --
    l_where_str := l_where_str||' and mod(eev.element_entry_value_id, :valtotal_workers) = :valworker_id ';
    --
  end if;
  --
  l_sql_str  := ' select eev.element_entry_value_id, '
                ||'      eev.effective_start_date, '
                ||'      eev.effective_end_date, '
                ||'      prv.creation_date, '
                ||'      prv.last_update_date, '
                ||'      prv.last_update_login, '
                ||'      prv.created_by, '
                ||'      eev.screen_entry_value, '
                ||'      pen.enrt_mthd_cd, '
                ||'      prv.business_group_id, '
                ||'      prv.prtt_rt_val_id, '
                ||'      prv.acty_ref_perd_cd, '
                ||'      prv.acty_base_rt_id, '
                ||'      prv.prtt_enrt_rslt_id, '
                ||'      prv.rt_strt_dt, '
                ||'      prv.rt_val, '
                ||'      prv.object_version_number, '
                ||'      abr.input_value_id, '
                ||'      abr.element_type_id, '
                ||'      pil.lf_evt_ocrd_dt, '
                ||'      pil.person_id, '
                ||'      pil.per_in_ler_id, '
                ||'      eev.ELEMENT_ENTRY_ID '
                ||l_from_str
                ||l_where_str
                ||' order by eev.element_entry_value_id, '
                ||'          eev.effective_start_date ';
  --
  if l_efc_batch then
    --
/*
    l_sql_str := l_sql_str||' for update of eev.element_entry_value_id ';
    --
*/
    hr_efc_info.insert_line('-- ');
    hr_efc_info.insert_line('-- Adjusting element entry values. Worker: '||p_worker_id
                           ||' of '||p_total_workers
                           );
    hr_efc_info.insert_line('-- ');
    --
    open c_efc_rows FOR l_sql_str using p_action_id, p_pk1, p_total_workers, p_worker_id;
    --
  elsif p_valworker_id is not null
    and p_valtotal_workers is not null
  then
    --
    open c_efc_rows FOR l_sql_str using p_valtotal_workers, p_valworker_id;
    --
  else
    --
    hr_efc_info.insert_line('-- ');
    hr_efc_info.insert_line('-- Validating element entry value adjustments');
    hr_efc_info.insert_line('-- ');
    --
    open c_efc_rows FOR l_sql_str;
    --
  end if;
  --
  l_prev_pkid := -999;
  l_prev_esd  := hr_api.g_sot;
  --
  loop
    FETCH c_efc_rows INTO l_efc_row;
    EXIT WHEN c_efc_rows%NOTFOUND;
    --
    l_faterr_code := null;
    l_faterr_type := null;
    l_adjfailed   := FALSE;
    --
    if l_faterr_code is null then
      --
      -- Deduce the effective date
      --
      -- BENAUTEN - Takes the minimum of the effective date and the
      --            enrt perd strt dt from the PEL
      --
      l_effective_date := l_efc_row.rt_strt_dt;
      --
      -- Check for exclusions
      --
      --   Assignments with a null payroll as of EEV effective start date
      --
      l_dummy_id := null;
      --
      begin
        --
        l_assign_exists := ben_element_entry.chk_assign_exists
                             (p_person_id         => l_efc_row.person_id
                             ,p_business_group_id => l_efc_row.business_group_id
                             ,p_effective_date    => l_effective_date
                             ,p_rate_date         => l_efc_row.rt_strt_dt
                             ,p_acty_base_rt_id   => l_efc_row.acty_base_rt_id
                             ,p_assignment_id     => l_dummy_id
                             ,p_organization_id   => l_dummy_id
                             ,p_payroll_id        => l_dummy_id
                             );
        --
      exception
        when others then
          --
          if instr(SQLERRM,'92458') > 0 then
            --
            l_faterr_code   := 'NOASGPAY';
            l_faterr_type   := 'MISSINGSETUP';
            --
          else
            --
            ben_efc_adjustments.g_eev_rcoerr_val_set(l_rcoerr_count).id        := l_efc_row.ELEMENT_ENTRY_VALUE_id;
            ben_efc_adjustments.g_eev_rcoerr_val_set(l_rcoerr_count).esd       := l_efc_row.effective_start_date;
            ben_efc_adjustments.g_eev_rcoerr_val_set(l_rcoerr_count).eed       := l_efc_row.effective_end_date;
            ben_efc_adjustments.g_eev_rcoerr_val_set(l_rcoerr_count).bgp_id    := l_efc_row.business_group_id;
            ben_efc_adjustments.g_eev_rcoerr_val_set(l_rcoerr_count).rco_name  := 'BENELMEN_CHKASG';
            ben_efc_adjustments.g_eev_rcoerr_val_set(l_rcoerr_count).sql_error := SQLERRM;
            --
            l_rcoerr_count  := l_rcoerr_count+1;
            --
          end if;
          --
      end;
      --
    end if;
    --
    if l_faterr_code is null
    then
      --
      -- Check if the ABR was modified after the element entry was created
      --
      open c_abrdets
        (c_abr_id   => l_efc_row.acty_base_rt_id
        ,c_eff_date => l_effective_date
        );
      fetch c_abrdets into l_abrdets;
      if c_abrdets%notfound then
        --
        l_faterr_code   := 'NODTABR';
        --
      end if;
      close c_abrdets;
      --
    end if;
    --
    if l_faterr_code is null
    then
      --
      begin
        --
        -- Clear distribute rates function caches
        --
        ben_distribute_rates.clear_down_cache;
        --
        ben_element_entry.create_enrollment_element
          (p_calculate_only_mode      => TRUE
          ,p_business_group_id        => l_efc_row.business_group_id
          ,p_prtt_rt_val_id           => l_efc_row.prtt_rt_val_id
          ,p_person_id                => l_efc_row.person_id
          ,p_acty_ref_perd            => l_efc_row.acty_ref_perd_cd
          ,p_acty_base_rt_id          => l_efc_row.acty_base_rt_id
          ,p_enrt_rslt_id             => l_efc_row.prtt_enrt_rslt_id
          ,p_rt_start_date            => l_efc_row.rt_strt_dt
          ,p_rt                       => l_efc_row.rt_val
          ,p_input_value_id           => l_efc_row.input_value_id
          ,p_element_type_id          => l_efc_row.element_type_id
          ,p_prv_object_version_number=> l_efc_row.prv_ovn
          ,p_effective_date           => l_effective_date
          --
          ,p_eev_screen_entry_value   => l_eev_screen_entry_value
          ,p_element_entry_value_id   => l_dummy_number
          );
        --
        -- Check for a special values. Multiple datetracked EEVs
        --
        if ben_element_entry.g_creee_calc_vals.special_pp_date is not null
        then
          --
          if ben_element_entry.g_creee_calc_vals.special_pp_date = l_efc_row.effective_start_date
          then
            --
            l_eev_screen_entry_value := ben_element_entry.g_creee_calc_vals.special_amt;
            --
          elsif ben_element_entry.g_creee_calc_vals.normal_pp_date = l_efc_row.effective_start_date
          then
            --
            l_eev_screen_entry_value := ben_element_entry.g_creee_calc_vals.normal_amt;
            --
          end if;
          --
        else
          --
          l_eev_screen_entry_value := ben_element_entry.g_creee_calc_vals.normal_amt;
          --
        end if;
        --
        l_old_val1 := l_efc_row.screen_entry_value;
        l_new_val1 := l_eev_screen_entry_value;
        --
        if nvl(l_eev_screen_entry_value,-9999) <> nvl(l_efc_row.screen_entry_value,-9999)
        then
          --
          -- Post adjustment checks
          --
          if l_eev_screen_entry_value is null then
            --
            if l_abrdets.ele_rqd_flag = 'N' then
              --
              l_faterr_code   := 'PRVABRERQDFLGN';
              l_faterr_type   := 'CODECHANGE';
              --
            else
              --
              l_faterr_code   := 'NULLADJEEVSEV';
              l_faterr_type   := 'ADJUSTBUG';
              --
            end if;
            --
          end if;
          --
          -- Get element entry info
          --
          if l_faterr_code is null then
            --
            open c_eledets
              (c_ele_id   => l_efc_row.ELEMENT_ENTRY_ID
              ,c_eff_date => l_efc_row.effective_start_date
              );
            fetch c_eledets into l_eledets;
            if c_eledets%notfound then
              --
              l_faterr_code   := 'NODTELE';
              l_faterr_type   := 'DATACORRUPT';
              --
            end if;
            close c_eledets;
            --
          end if;
          --
          if l_faterr_code is null then
            --
            -- Check if the EEV is attached to multiple PRVs (bug 1483757)
            --
            open c_multprveevs
              (c_eev_id => l_efc_row.ELEMENT_ENTRY_VALUE_id
              );
            fetch c_multprveevs into l_count;
            close c_multprveevs;
            --
            if l_count > 1 then
              --
              l_faterr_code   := 'WWBUG1483757';
              l_faterr_type   := 'POTENTIALCODEBUG';
              --
            end if;
            --
          end if;
          --
          -- Check for a duplicate DT row
          --
          if l_efc_row.element_entry_value_id = l_prev_pkid
            and l_efc_row.effective_start_date = l_prev_esd
            and l_faterr_code is null
          then
            --
            l_faterr_code   := 'DUPDTROW';
            l_faterr_type   := 'DATACORRUPT';
            --
          end if;
/*
          --
          -- Check for a conversion factor
          --
          if l_efc_batch
            and l_faterr_code is null
          then
            --
            -- Check for un converted PRVs
            --
            open c_convvalexist
              (c_prv_id        => l_efc_row.prtt_rt_val_id
              ,c_efc_action_id => p_action_id
              );
            fetch c_convvalexist into l_convvalexist;
            if c_convvalexist%notfound then
              --
              l_faterr_code   := 'PRVVALNOCONVERT';
              l_faterr_type   := 'CONVEXCLUSION';
              --
            end if;
            close c_convvalexist;
            --
            -- Check for PRV exclusions in batch mode
            --
            if l_faterr_code is null then
              --
              open c_valexcexist
                (c_prv_id        => l_efc_row.prtt_rt_val_id
                ,c_efc_action_id => p_action_id
                ,c_ent_scode     => 'PRV'
                );
              fetch c_valexcexist into l_valexcexist;
              if c_valexcexist%found then
                --
                l_faterr_code   := 'PRVVALEXCL';
                l_faterr_type   := 'CONVEXCLUSION';
                --
              end if;
              close c_valexcexist;
              --
            end if;
            --
            if l_faterr_code is null then
              --
              -- get pre conversion details
              --
              open c_preconvdets
                (c_efc_action_id => p_action_id
                ,c_eev_id        => l_efc_row.ELEMENT_ENTRY_VALUE_id
                ,c_eev_esd       => l_efc_row.effective_start_date
                );
              fetch c_preconvdets into l_preconvdets;
              if c_preconvdets%notfound then
                --
                l_faterr_code   := 'NOEFCACTEEV';
                l_faterr_type   := 'CORRUPTDATA';
                --
              end if;
              close c_preconvdets;
              --
            end if;
            --
            -- Get the currency conversion factor details
            --
            if l_faterr_code is null then
              --
              ben_efc_adjustments.DetectConvInfo
                (p_ncucurr_code => l_preconvdets.input_currency_code
                ,p_new_val      => l_eev_screen_entry_value
                ,p_preconv_val  => l_preconvdets.SCREEN_ENTRY_VALUE
                --
                ,p_faterr_code  => l_faterr_code
                ,p_faterr_type  => l_faterr_type
                ,p_postconv_val => l_postconv_val
                );
              --
              if l_faterr_code is not null then
                --
                l_old_val1 := l_preconvdets.SCREEN_ENTRY_VALUE;
                l_new_val1 := l_postconv_val;
                --
              end if;
              --
            end if;
            --
          end if;
*/
          --
          -- Check rounding
          --
          if l_faterr_code is null then
            --
            ben_efc_adjustments.DetectRoundInfo
              (p_rndg_cd        => null
              ,p_rndg_rl        => null
              ,p_old_val        => l_efc_row.screen_entry_value
              ,p_new_val        => l_eev_screen_entry_value
              ,p_eff_date       => l_efc_row.rt_strt_dt
              --
              ,p_faterr_code    => l_faterr_code
              ,p_faterr_type    => l_faterr_type
              );
            --
          end if;
          --
          -- Check for multiple batch process modifications
          --
          if l_faterr_code is null then
            --
            for row in c_eledtinsts
              (c_ele_id => l_efc_row.ELEMENT_ENTRY_ID
              )
            loop
              --
              open c_eledets
                (c_ele_id   => l_efc_row.ELEMENT_ENTRY_ID
                ,c_eff_date => row.effective_start_date
                );
              fetch c_eledets into l_tmpdets;
              if c_eledets%notfound then
                --
                l_faterr_code   := 'NOELEDETS';
                l_faterr_type   := 'DATACORRUPT';
                --
              end if;
              close c_eledets;
              --
              -- Check for a modified PRV
              --
              if l_tmpdets.last_update_login <> l_efc_row.prv_last_update_login
                and l_tmpdets.created_by = l_efc_row.prv_created_by
                and l_faterr_code is null
              then
                --
                if l_efc_row.prv_last_update_login = -1 then
                  --
                  l_faterr_code := 'SQLPLUSELEPRVCORR';
                  l_faterr_type := 'DATACORRUPT';
                  --
                else
                  --
                  l_faterr_code := 'ELEPRVCORR';
                  l_faterr_type := 'UNSUPPORTTRANS';
                  --
                end if;
                --
              end if;
              --
            end loop;
            --
          end if;
          --
          -- Check for PRV mods
          --
          if l_efc_row.prv_ovn > 1
            and l_faterr_code is null
          then
            --
            l_faterr_code := 'PRVMODS';
            l_faterr_type := 'UNSUPPORTTRANS';
            --
          end if;
          --
          if l_faterr_code is null then
            --
            -- Check if the ELE has been modified
            --
            ben_efc_adjustments.DetectWhoInfo
              (p_creation_date         => l_eledets.creation_date
              ,p_last_update_date      => l_eledets.last_update_date
              ,p_object_version_number => l_eledets.object_version_number
              --
              ,p_who_counts            => l_who_counts
              ,p_faterr_code           => l_faterr_code
              ,p_faterr_type           => l_faterr_type
              );
            --
          end if;
          --
          if l_abrdets.last_update_date > l_eledets.creation_date
            and l_faterr_code is null
          then
            --
            l_faterr_code := 'ABRCORR';
            l_faterr_type := 'CORRECTEDINFO';
            --
          elsif l_faterr_code is null then
            --
            ben_efc_adjustments.g_eev_failed_adj_val_set(l_calfail_count).id       := l_efc_row.ELEMENT_ENTRY_VALUE_id;
            ben_efc_adjustments.g_eev_failed_adj_val_set(l_calfail_count).esd      := l_efc_row.effective_start_date;
            ben_efc_adjustments.g_eev_failed_adj_val_set(l_calfail_count).eed      := l_efc_row.effective_end_date;
            ben_efc_adjustments.g_eev_failed_adj_val_set(l_calfail_count).bgp_id   := l_efc_row.business_group_id;
            ben_efc_adjustments.g_eev_failed_adj_val_set(l_calfail_count).credt    := l_eledets.creation_date;
            ben_efc_adjustments.g_eev_failed_adj_val_set(l_calfail_count).lud      := l_eledets.last_update_date;
            ben_efc_adjustments.g_eev_failed_adj_val_set(l_calfail_count).old_val1 := l_old_val1;
            ben_efc_adjustments.g_eev_failed_adj_val_set(l_calfail_count).new_val1 := l_new_val1;
            ben_efc_adjustments.g_eev_failed_adj_val_set(l_calfail_count).val_type := 'EEV_SCRENTVAL';
            --
            l_adjfailed := TRUE;
            l_calfail_count  := l_calfail_count+1;
            --
          end if;
          --
        else
          --
          l_adjfailed := FALSE;
          --
          -- Success exclusions
          --
          if l_efc_batch
            and l_faterr_code is null
          then
            --
            -- Check for un converted PRVs
            --
            open c_convvalexist
              (c_prv_id        => l_efc_row.prtt_rt_val_id
              ,c_efc_action_id => p_action_id
              );
            fetch c_convvalexist into l_convvalexist;
            if c_convvalexist%notfound then
              --
              l_faterr_code   := 'PRVVALNOCONVERT';
              l_faterr_type   := 'CONVEXCLUSION';
              --
            end if;
            close c_convvalexist;
            --
            if l_faterr_code is null then
              --
              -- Check for PRV exclusions in batch mode
              --
              open c_valexcexist
                (c_prv_id        => l_efc_row.prtt_rt_val_id
                ,c_efc_action_id => p_action_id
                ,c_ent_scode     => 'PRV'
                );
              fetch c_valexcexist into l_valexcexist;
              if c_valexcexist%found then
                --
                l_faterr_code   := 'PRVVALEXCL';
                l_faterr_type   := 'CONVEXCLUSION';
                --
              end if;
              close c_valexcexist;
              --
            end if;
            --
          end if;
          --
        end if;
        --
        if l_efc_batch
          and (l_faterr_code is null
            or nvl(l_faterr_type,'ZZZZ') = 'CONVEXCLUSION')
        then
          --
          update PAY_ELEMENT_ENTRY_VALUES_F eev
          set  eev.screen_entry_value = l_eev_screen_entry_value
          where eev.ELEMENT_ENTRY_VALUE_id = l_efc_row.ELEMENT_ENTRY_VALUE_id
          and   eev.effective_start_date   = l_efc_row.effective_start_date;
          --
          if p_validate then
            --
            rollback;
            --
          end if;
          --
          -- Check for end of chunk and commit if necessary
          --
          l_pk1 := l_efc_row.ELEMENT_ENTRY_VALUE_id;
          --
          ben_efc_functions.maintain_chunks
            (p_row_count     => l_chunkrow_count
            ,p_pk1           => l_pk1
            ,p_chunk_size    => p_chunk
            ,p_efc_worker_id => p_efc_worker_id
            );
          --
        end if;
        --
      exception
        when others then
          --
          if instr(SQLERRM,'92690') > 0 then
            --
            l_faterr_code   := 'WWBUG1691913';
            l_faterr_type   := 'FIXEDCODEBUG';
            --
          elsif instr(SQLERRM,'92547') > 0 then
            --
            l_faterr_code   := 'NOPRVABRDTIPV';
            l_faterr_type   := 'MISSINGSETUP';
            --
          elsif instr(SQLERRM,'91884') > 0 then
            --
            l_faterr_code   := 'PENPLNYPINFO';
            l_faterr_type   := 'POTENTIALCODEBUG';
            --
          elsif instr(SQLERRM,'92346') > 0 then
            --
            l_faterr_code   := 'NOPAYPTPNXMTH';
            l_faterr_type   := 'MISSINGSETUP';
            --
          else
            --
            ben_efc_adjustments.g_eev_rcoerr_val_set(l_rcoerr_count).id        := l_efc_row.ELEMENT_ENTRY_VALUE_id;
            ben_efc_adjustments.g_eev_rcoerr_val_set(l_rcoerr_count).esd       := l_efc_row.effective_start_date;
            ben_efc_adjustments.g_eev_rcoerr_val_set(l_rcoerr_count).eed       := l_efc_row.effective_end_date;
            ben_efc_adjustments.g_eev_rcoerr_val_set(l_rcoerr_count).bgp_id    := l_efc_row.business_group_id;
            ben_efc_adjustments.g_eev_rcoerr_val_set(l_rcoerr_count).lud       := l_eledets.last_update_date;
            ben_efc_adjustments.g_eev_rcoerr_val_set(l_rcoerr_count).rco_name  := 'BENELMEN';
            ben_efc_adjustments.g_eev_rcoerr_val_set(l_rcoerr_count).sql_error := SQLERRM;
            --
            l_rcoerr_count  := l_rcoerr_count+1;
            --
          end if;
          --
      end;
      --
    else
      --
      l_preadjexc_count := l_preadjexc_count+1;
      --
    end if;
    --
    -- Check for fatal errors
    --
    if l_faterr_code is not null
    then
      --
      ben_efc_adjustments.g_eev_fatal_error_val_set(l_faterrs_count).id          := l_efc_row.ELEMENT_ENTRY_VALUE_id;
      ben_efc_adjustments.g_eev_fatal_error_val_set(l_faterrs_count).esd         := l_efc_row.effective_start_date;
      ben_efc_adjustments.g_eev_fatal_error_val_set(l_faterrs_count).eed         := l_efc_row.effective_end_date;
      ben_efc_adjustments.g_eev_fatal_error_val_set(l_faterrs_count).faterr_code := l_faterr_code;
      ben_efc_adjustments.g_eev_fatal_error_val_set(l_faterrs_count).faterr_type := l_faterr_type;
      ben_efc_adjustments.g_eev_fatal_error_val_set(l_faterrs_count).old_val1    := l_old_val1;
      ben_efc_adjustments.g_eev_fatal_error_val_set(l_faterrs_count).new_val1    := l_new_val1;
      ben_efc_adjustments.g_eev_fatal_error_val_set(l_faterrs_count).bgp_id      := l_efc_row.business_group_id;
      ben_efc_adjustments.g_eev_fatal_error_val_set(l_faterrs_count).lud         := l_eledets.last_update_date;
      ben_efc_adjustments.g_eev_fatal_error_val_set(l_faterrs_count).credt       := l_eledets.creation_date;
      ben_efc_adjustments.g_eev_fatal_error_val_set(l_faterrs_count).ovn         := l_eledets.object_version_number;
      ben_efc_adjustments.g_eev_fatal_error_val_set(l_faterrs_count).cre_by      := l_eledets.created_by;
      ben_efc_adjustments.g_eev_fatal_error_val_set(l_faterrs_count).lu_by       := l_eledets.last_updated_by;
      ben_efc_adjustments.g_eev_fatal_error_val_set(l_faterrs_count).id1         := l_efc_row.prtt_rt_val_id;
      --
      l_faterrs_count := l_faterrs_count+1;
      --
    elsif l_faterr_code is null
      and not l_adjfailed
    then
      --
      ben_efc_adjustments.g_eev_success_adj_val_set(l_calsucc_count).id       := l_efc_row.ELEMENT_ENTRY_VALUE_id;
      ben_efc_adjustments.g_eev_success_adj_val_set(l_calsucc_count).esd      := l_efc_row.effective_start_date;
      ben_efc_adjustments.g_eev_success_adj_val_set(l_calsucc_count).eed      := l_efc_row.effective_end_date;
      ben_efc_adjustments.g_eev_success_adj_val_set(l_calsucc_count).old_val1 := l_old_val1;
      ben_efc_adjustments.g_eev_success_adj_val_set(l_calsucc_count).new_val1 := l_new_val1;
      ben_efc_adjustments.g_eev_success_adj_val_set(l_calsucc_count).val_type := 'EEV_SCRENTVAL';
      ben_efc_adjustments.g_eev_success_adj_val_set(l_calsucc_count).credt    := l_eledets.creation_date;
      ben_efc_adjustments.g_eev_success_adj_val_set(l_calsucc_count).lud      := l_eledets.last_update_date;
      ben_efc_adjustments.g_eev_success_adj_val_set(l_calsucc_count).id1      := l_efc_row.prtt_rt_val_id;
      --
      l_calsucc_count := l_calsucc_count+1;
      --          --
    end if;
    --
    l_row_count := l_row_count+1;
    l_prev_pkid := l_efc_row.element_entry_value_id;
    l_prev_esd  := l_efc_row.effective_start_date;
    --
  end loop;
  CLOSE c_efc_rows;
/*
  --
  -- Write exceptions down to the table
  --
  if l_efc_batch
    and p_valworker_id is null
    and p_valtotal_workers is null
  then
    --
    ben_efc_adjustments.insert_validation_exceptions
      (p_val_set        => ben_efc_adjustments.g_eev_failed_adj_val_set
      ,p_efc_action_id  => p_action_id
      ,p_ent_scode      => 'EEV'
      ,p_exception_type => 'AF'
      );
    --
    ben_efc_adjustments.insert_validation_exceptions
      (p_val_set        => ben_efc_adjustments.g_eev_fatal_error_val_set
      ,p_efc_action_id  => p_action_id
      ,p_ent_scode      => 'EEV'
      ,p_exception_type => null
      );
    --
  end if;
*/
  --
  -- Check that all rows have been converted or excluded
  --
  l_sql_str := 'select count(*) '
               ||' from pay_element_entry_values_f eev, '
               ||'      ben_prtt_rt_val prv '
               ||' where prv.element_entry_value_id = eev.element_entry_value_id '
               ||' and   eev.screen_entry_value is not null ';
  --
  if p_business_group_id is not null then
    --
    l_sql_str := l_sql_str||' and prv.business_group_id = '||p_business_group_id;
    --
  end if;
  --
  ben_efc_functions.conv_check
    (p_table_name    => 'pay_element_entry_values_f'
    ,p_efctable_name => 'pay_element_entry_values_f_efc'
    --
    ,p_table_sql     => l_sql_str
    ,p_efctable_sql  => 'select count(*) from pay_element_entry_values_f_efc '
                        ||' where efc_action_id = '||p_action_id
    --
    ,p_bgp_id        => p_business_group_id
    ,p_action_id     => p_action_id
    --
    ,p_conv_count    => l_conv_count
    ,p_unconv_count  => l_unconv_count
    ,p_tabrow_count  => l_tabrow_count
    );
  --
  -- Set counts
  --
  if p_action_id is null then
    --
    l_actconv_count := 0;
    --
  else
    --
    l_actconv_count := l_conv_count;
    --
  end if;
  --
  p_adjustment_counts.tabrow_count       := l_tabrow_count;
  p_adjustment_counts.efcrow_count       := l_row_count;
  p_adjustment_counts.actconv_count      := l_actconv_count;
  p_adjustment_counts.calfail_count      := l_calfail_count;
  p_adjustment_counts.calsucc_count      := l_calsucc_count;
  p_adjustment_counts.rcoerr_count       := l_rcoerr_count;
  p_adjustment_counts.faterrs_count      := l_faterrs_count;
  p_adjustment_counts.preadjexc_count    := l_preadjexc_count;
  --
end eev_adjustments;
--
procedure bpl_adjustments
  (p_validate          in     boolean default false
  ,p_worker_id         in     number  default null
  ,p_action_id         in     number  default null
  ,p_total_workers     in     number  default null
  ,p_pk1               in     number  default null
  ,p_chunk             in     number  default null
  ,p_efc_worker_id     in     number  default null
  --
  ,p_valworker_id      in     number  default null
  ,p_valtotal_workers  in     number  default null
  --
  ,p_business_group_id in     number  default null
  --
  ,p_adjustment_counts    out nocopy ben_efc_adjustments.g_adjustment_counts
  )
is
  --
  TYPE cur_type IS REF CURSOR;
  --
  type g_efc_row is record
    (bnft_prvdd_ldgr_id      ben_bnft_prvdd_ldgr_f.bnft_prvdd_ldgr_id%type
    ,effective_start_date    ben_bnft_prvdd_ldgr_f.effective_start_date%type
    ,effective_end_date      ben_bnft_prvdd_ldgr_f.effective_end_date%type
    ,creation_date           ben_bnft_prvdd_ldgr_f.creation_date%type
    ,last_update_date        ben_bnft_prvdd_ldgr_f.last_update_date%type
    ,object_version_number   ben_bnft_prvdd_ldgr_f.object_version_number%type
    ,created_by              ben_bnft_prvdd_ldgr_f.created_by%type
    ,last_updated_by         ben_bnft_prvdd_ldgr_f.last_updated_by%type
    ,used_val                ben_bnft_prvdd_ldgr_f.used_val%type
    ,FRFTD_VAL               ben_bnft_prvdd_ldgr_f.FRFTD_VAL%type
    ,PRVDD_VAL               ben_bnft_prvdd_ldgr_f.PRVDD_VAL%type
    ,RLD_UP_VAL              ben_bnft_prvdd_ldgr_f.RLD_UP_VAL%type
    ,CASH_RECD_VAL           ben_bnft_prvdd_ldgr_f.CASH_RECD_VAL%type
    ,business_group_id       ben_bnft_prvdd_ldgr_f.business_group_id%type
    ,bnft_prvdr_pool_id      ben_bnft_prvdd_ldgr_f.bnft_prvdr_pool_id%type
    ,acty_base_rt_id         ben_bnft_prvdd_ldgr_f.acty_base_rt_id%type
    ,prtt_enrt_rslt_id       ben_bnft_prvdd_ldgr_f.prtt_enrt_rslt_id%type
    ,person_id               ben_per_in_ler.person_id%type
    ,per_in_ler_id           ben_per_in_ler.per_in_ler_id%type
    ,lf_evt_ocrd_dt          ben_per_in_ler.lf_evt_ocrd_dt%type
    );
  --
  c_efc_rows               cur_type;
  --
  l_proc                   varchar2(1000) := 'bpl_adjustments';
  --
  l_epe_rec                ben_epe_shd.g_rec_type;
  --
  l_efc_batch              boolean;
  --
  l_sql_str                long;
  l_from_str               long;
  l_where_str              long;
  l_groupby_str            long;
  --
  l_efc_row                g_efc_row;
  --
  l_who_counts             ben_efc_adjustments.g_who_counts;
  l_olddata                boolean;
  --
  l_faterr_code            varchar2(100);
  l_faterr_type            varchar2(100);
  --
  l_row_count              pls_integer;
  l_calfail_count          pls_integer;
  l_calsucc_count          pls_integer;
  l_conv_count             pls_integer;
  l_unconv_count           pls_integer;
  l_actconv_count          pls_integer;
  l_dupconv_count          pls_integer;
  --
  l_rcoerr_count           pls_integer;
  l_faterrs_count          pls_integer;
  --
  l_pk1                    number;
  --
  l_tabrow_count           pls_integer;
  l_chunkrow_count         pls_integer;
  --
  l_effective_date         date;
  --
  l_dummy_number           number;
  l_dummy_varchar2         varchar2(30);
  l_dummy_date             date;
  --
  l_bpl_id                 number;
  l_bpl_used_val           number;
  l_bpl_frftd_val          number;
  l_bpl_prvdd_val          number;
  l_bpl_rld_up_val         number;
  l_bpl_cash_recd_val      number;
  --
  l_adjfailed              boolean;
  l_val_type               varchar2(100);
  l_old_val1               number;
  l_new_val1               number;
  --
  l_ecr_count              pls_integer;
  --
  cursor c_penprvdets
    (c_pen_id   in number
    ,c_abr_id   in number
    ,c_eff_date in date
    )
  is
    select ecr.prtt_rt_val_id,
           ecr.ELIG_PER_ELCTBL_CHC_ID
    from   ben_enrt_bnft enb,
           ben_enrt_rt ecr,
           ben_bnft_prvdd_ldgr_f bpl,
           ben_elig_per_elctbl_chc epe
    where  ecr.DECR_BNFT_PRVDR_POOL_ID = bpl.BNFT_PRVDR_POOL_ID
    and    ecr.acty_base_rt_id        = bpl.acty_base_rt_id
    and    ecr.enrt_bnft_id           = enb.enrt_bnft_id
    and    bpl.per_in_ler_id          = epe.per_in_ler_id
    and    enb.ELIG_PER_ELCTBL_CHC_ID = epe.ELIG_PER_ELCTBL_CHC_ID
    and    bpl.acty_base_rt_id        = c_abr_id
    and    bpl.prtt_enrt_rslt_id      = c_pen_id
  union
    select ecr.prtt_rt_val_id,
           ecr.ELIG_PER_ELCTBL_CHC_ID
    from   ben_enrt_rt ecr,
           ben_bnft_prvdd_ldgr_f bpl,
           ben_elig_per_elctbl_chc epe
    where  ecr.DECR_BNFT_PRVDR_POOL_ID = bpl.BNFT_PRVDR_POOL_ID
    and    ecr.acty_base_rt_id         = bpl.acty_base_rt_id
    and    ecr.ELIG_PER_ELCTBL_CHC_ID  = epe.ELIG_PER_ELCTBL_CHC_ID
    and    bpl.per_in_ler_id           = epe.per_in_ler_id
    and    bpl.acty_base_rt_id         = c_abr_id
    and    bpl.prtt_enrt_rslt_id       = c_pen_id
  ;
  --
  l_penprvdets c_penprvdets%rowtype;
  --
  cursor c_bpldets
    (c_bpl_id   in number
    ,c_eff_date in date
    )
  is
    select bpl.bnft_prvdd_ldgr_id,
           bpl.effective_start_date,
           bpl.effective_end_date,
           bpl.used_val,
           bpl.FRFTD_VAL,
           bpl.PRVDD_VAL,
           bpl.RLD_UP_VAL,
           bpl.CASH_RECD_VAL,
           bpl.creation_date,
           bpl.last_update_date,
           bpl.created_by,
           bpl.last_updated_by,
           bpl.object_version_number
    from   ben_bnft_prvdd_ldgr_f bpl
    where  bpl.bnft_prvdd_ldgr_id = c_bpl_id
    and    c_eff_date
      between bpl.effective_start_date and bpl.effective_end_date;
  --
  l_bpldets c_bpldets%rowtype;
  --
  cursor c_ecrdets
    (c_abr_id in number
    ,c_pil_id in number
    )
  is
    select ecr.enrt_rt_id,
           ecr.enrt_bnft_ID,
           ecr.ELIG_PER_ELCTBL_CHC_ID,
           ecr.decr_bnft_prvdr_pool_id,
           ecr.prtt_rt_val_id,
           ecr.val,
           epe.prtt_enrt_rslt_id
    from   ben_enrt_rt ecr,
           ben_elig_per_elctbl_chc epe
    where  ecr.acty_base_rt_id = c_abr_id
/*
    and    ecr.decr_bnft_prvdr_pool_id = c_bpp_id
*/
    and    ecr.ELIG_PER_ELCTBL_CHC_ID = epe.ELIG_PER_ELCTBL_CHC_ID
    and    epe.per_in_ler_id          = c_pil_id
/*
    and    epe.prtt_enrt_rslt_id      = c_pen_id
*/
  union
    select ecr.enrt_rt_id,
           ecr.enrt_bnft_ID,
           ecr.ELIG_PER_ELCTBL_CHC_ID,
           ecr.decr_bnft_prvdr_pool_id,
           ecr.prtt_rt_val_id,
           ecr.val,
           epe.prtt_enrt_rslt_id
    from   ben_enrt_rt ecr,
           ben_enrt_bnft enb,
           ben_elig_per_elctbl_chc epe
    where
/*
           ecr.DECR_BNFT_PRVDR_POOL_ID = c_bpp_id
    and
*/
           ecr.acty_base_rt_id         = c_abr_id
    and    ecr.enrt_bnft_id            = enb.enrt_bnft_id
    and    enb.ELIG_PER_ELCTBL_CHC_ID  = epe.ELIG_PER_ELCTBL_CHC_ID
    and    epe.per_in_ler_id           = c_pil_id;
/*
    and    epe.prtt_enrt_rslt_id       = c_pen_id;
*/
  --
  l_ecrdets c_ecrdets%rowtype;
  --
  cursor c_bppdets
    (c_bpp_id   in number
    ,c_eff_date in date
    )
  is
    select bpp.dflt_excs_trtmt_cd,
           bpp.auto_alct_excs_flag
    from   ben_bnft_prvdr_pool_f bpp
    where  bpp.bnft_prvdr_pool_id = c_bpp_id
    and c_eff_date
      between bpp.effective_start_date and bpp.effective_end_date;
  --
  l_bppdets c_bppdets%rowtype;
  --
begin
  --
  l_efc_batch      := FALSE;
  --
  l_row_count      := 0;
  l_calfail_count  := 0;
  l_calsucc_count  := 0;
  l_dupconv_count  := 0;
  l_conv_count     := 0;
  l_actconv_count  := 0;
  l_unconv_count   := 0;
  --
  l_rcoerr_count   := 0;
  --
  l_faterrs_count  := 0;
  --
  l_chunkrow_count := 0;
  --
  ben_efc_adjustments.g_bpl_success_adj_val_set.delete;
  ben_efc_adjustments.g_bpl_failed_adj_val_set.delete;
  ben_efc_adjustments.g_bpl_rcoerr_val_set.delete;
  ben_efc_adjustments.g_bpl_fatal_error_val_set.delete;
  --
  -- Check if EFC process parameters are set
  --
  if p_action_id is not null
    and p_pk1 is not null
    and p_chunk is not null
    and p_efc_worker_id is not null
  then
    --
    l_efc_batch := TRUE;
    --
  end if;
  --
  l_from_str := ' FROM ben_bnft_prvdd_ldgr_f bpl, '
                ||'    ben_per_in_ler pil, '
                ||'    per_all_people_f per ';
  --
  l_where_str := ' where bpl.per_in_ler_id = pil.per_in_ler_id '
                 ||' and pil.person_id = per.person_id '
                 ||' and pil.LF_EVT_OCRD_DT '
                 ||'   between per.effective_start_date and per.effective_end_date '
                 ||' and pil.LF_EVT_OCRD_DT '
                 ||'   between bpl.effective_start_date and bpl.effective_end_date '
                 ||' and (bpl.used_val is not null '
                 ||'     or bpl.FRFTD_VAL is not null '
                 ||'     or bpl.PRVDD_VAL is not null '
                 ||'     or bpl.RLD_UP_VAL is not null '
                 ||'     or bpl.CASH_RECD_VAL is not null '
                 ||'     ) '
/* Exclude out nocopy voided and backed out nocopy life events */
                 ||' and pil.per_in_ler_stat_cd not in ('
                 ||''''||'VOIDD'||''''||','||''''||'BCKDT'||''''||') '
                 ;
  --
  -- Check if we are restricting by business group
  --
  if p_business_group_id is not null then
    --
    l_where_str := l_where_str||' and bpl.business_group_id = '||p_business_group_id;
    --
  end if;
  --
  -- Build in batch specific restrictions
  --
  if l_efc_batch then
    --
    l_from_str  := l_from_str||', ben_bnft_prvdd_ldgr_f_efc efc ';
    l_where_str := l_where_str||' and efc.bnft_prvdd_ldgr_id = bpl.bnft_prvdd_ldgr_id '
                   ||' and   efc.efc_action_id          = :action_id '
                   ||' and   bpl.bnft_prvdd_ldgr_id > :pk1 '
                   ||' and   mod(bpl.bnft_prvdd_ldgr_id, :total_workers) = :worker_id ';
    --
  elsif p_valworker_id is not null
    and p_valtotal_workers is not null
  then
    --
    l_where_str := l_where_str||' and mod(bpl.bnft_prvdd_ldgr_id, :valtotal_workers) = :valworker_id ';
    --
  end if;
  --
  l_sql_str  := ' select bpl.bnft_prvdd_ldgr_id, '
                ||'      bpl.effective_start_date, '
                ||'      bpl.effective_end_date, '
                ||'      bpl.creation_date, '
                ||'      bpl.last_update_date, '
                ||'      bpl.object_version_number, '
                ||'      bpl.created_by, '
                ||'      bpl.last_updated_by, '
                ||'      bpl.used_val, '
                ||'      bpl.FRFTD_VAL, '
                ||'      bpl.PRVDD_VAL, '
                ||'      bpl.RLD_UP_VAL, '
                ||'      bpl.CASH_RECD_VAL, '
                ||'      bpl.business_group_id, '
                ||'      bpl.bnft_prvdr_pool_id, '
                ||'      bpl.acty_base_rt_id, '
                ||'      bpl.prtt_enrt_rslt_id, '
                ||'      pil.person_id, '
                ||'      pil.per_in_ler_id, '
                ||'      pil.lf_evt_ocrd_dt '
                ||l_from_str
                ||l_where_str
                ||' order by pil.per_in_ler_id, bpl.prtt_enrt_rslt_id ';
  --
  if l_efc_batch then
    --
    hr_efc_info.insert_line('-- ');
    hr_efc_info.insert_line('-- Adjusting benefit provider ledgers ');
    hr_efc_info.insert_line('-- ');
    --
    open c_efc_rows FOR l_sql_str using p_action_id, p_pk1, p_total_workers, p_worker_id;
    --
  elsif p_valworker_id is not null
    and p_valtotal_workers is not null
  then
    --
    open c_efc_rows FOR l_sql_str using p_valtotal_workers, p_valworker_id;
    --
  else
    --
    open c_efc_rows FOR l_sql_str;
    --
  end if;
  --
  loop
    FETCH c_efc_rows INTO l_efc_row;
    EXIT WHEN c_efc_rows%NOTFOUND;
    --
    l_faterr_code := null;
    l_faterr_type := null;
    --
    if l_faterr_code is null then
      --
      begin
        --
        l_dummy_number   := null;
        l_dummy_varchar2 := null;
        l_dummy_date     := null;
        l_adjfailed      := FALSE;
        --
        l_bpl_used_val      := null;
        l_bpl_frftd_val     := null;
        l_bpl_prvdd_val     := null;
        l_bpl_rld_up_val    := null;
        l_bpl_cash_recd_val := null;
        --
        if l_faterr_code is null then
          --
          if l_efc_row.bnft_prvdr_pool_id is null then
            --
            l_faterr_code := 'NULLBPLBPP';
            l_faterr_type := 'MISC';
            --
          end if;
          --
        end if;
        --
        if l_faterr_code is null then
          --
          -- Get the ECRs for the ABR and PIL
          --
          l_ecr_count := 0;
          --
          for ecr_row in c_ecrdets
            (c_abr_id => l_efc_row.acty_base_rt_id
            ,c_pil_id => l_efc_row.per_in_ler_id
            )
          loop
            --
            l_ecrdets   := ecr_row;
            l_ecr_count := l_ecr_count+1;
            --
          end loop;
          --
          -- Check for no and multiple ECRs
          --
          if l_ecr_count = 0 then
            --
            l_faterr_code := 'NOECR';
            l_faterr_type := 'POTENTIALCODEBUG';
            --
          elsif l_ecr_count = 2 then
            --
            l_faterr_code := 'MULTECRS';
            l_faterr_type := 'POTENTIALCODEBUG';
            --
          end if;
          --
        end if;
        --
        l_bpl_id := null;
        --
        if l_efc_row.used_val is not null
          and l_faterr_code is null
        then
          --
          ben_provider_pools.create_debit_ledger_entry
            (p_calculate_only_mode     => TRUE
            ,p_person_id               => l_efc_row.person_id
            ,p_per_in_ler_id           => l_efc_row.per_in_ler_id
            ,p_elig_per_elctbl_chc_id  => null
            ,p_prtt_enrt_rslt_id       => l_efc_row.prtt_enrt_rslt_id
            ,p_decr_bnft_prvdr_pool_id => null
            ,p_acty_base_rt_id         => l_efc_row.acty_base_rt_id
            ,p_prtt_rt_val_id          => l_ecrdets.prtt_rt_val_id
            ,p_enrt_mthd_cd            => null
            ,p_val                     => null
            ,p_bnft_prvdd_ldgr_id      => l_bpl_id
            ,p_business_group_id       => l_efc_row.business_group_id
            ,p_effective_date          => l_efc_row.lf_evt_ocrd_dt
            --
            ,p_bpl_used_val            => l_bpl_used_val
            );
          --
        end if;
        --
        if l_efc_row.prvdd_val is not null
          and l_faterr_code is null
        then
          --
          l_epe_rec.per_in_ler_id          := l_efc_row.per_in_ler_id;
          l_epe_rec.elig_per_elctbl_chc_id := l_ecrdets.ELIG_PER_ELCTBL_CHC_ID;
          l_epe_rec.business_group_id      := l_efc_row.business_group_id;
          l_epe_rec.bnft_prvdr_pool_id     := l_efc_row.bnft_prvdr_pool_id;
          --
          ben_provider_pools.create_credit_ledger_entry
            (p_calculate_only_mode => TRUE
            ,p_person_id           => l_efc_row.person_id
            ,p_epe_rec             => l_epe_rec
            ,p_enrt_mthd_cd        => null
            ,p_effective_date      => l_efc_row.lf_evt_ocrd_dt
            --
            ,p_bnft_prvdd_ldgr_id  => l_bpl_id
            ,p_bpl_prvdd_val       => l_bpl_prvdd_val
            );
          --
        end if;
        --
        if l_efc_row.cash_recd_val is not null
          and l_faterr_code is null
        then
          --
          -- Check for a BPP
          --
          if l_efc_row.bnft_prvdr_pool_id is null then
            --
            l_faterr_code := 'BPLBPPNULL';
            l_faterr_type := 'MISC';
            --
          end if;
          --
/*
          --
          -- Check for a BPP
          --
          if nvl(l_ecrdets.decr_bnft_prvdr_pool_id,-999) <> l_efc_row.bnft_prvdr_pool_id
            and l_faterr_code is null
          then
            --
            l_faterr_code := 'NOECRBPP';
            l_faterr_type := 'MISC';
            --
          end if;
*/
          --
          if l_faterr_code is null then
            --
            open c_bppdets
              (c_bpp_id   => l_efc_row.bnft_prvdr_pool_id
              ,c_eff_date => l_efc_row.lf_evt_ocrd_dt
              );
            fetch c_bppdets into l_bppdets;
            if c_bppdets%notfound then
              --
              l_faterr_code := 'NOBPLBPPDETS';
              l_faterr_type := 'MISC';
              --
            end if;
            close c_bppdets;
            --
          end if;
          --
          if l_faterr_code is null then
            --
            ben_provider_pools.compute_excess
              (p_calculate_only_mode => TRUE
              ,p_bnft_prvdr_pool_id  => l_efc_row.bnft_prvdr_pool_id
              ,p_flex_rslt_id        => l_efc_row.prtt_enrt_rslt_id
              ,p_person_id           => l_efc_row.person_id
              ,p_per_in_ler_id       => l_efc_row.per_in_ler_id
              ,p_enrt_mthd_cd        => null
              ,p_effective_date      => l_efc_row.lf_evt_ocrd_dt
              ,p_business_group_id   => l_efc_row.business_group_id
              ,p_frftd_val           => l_dummy_number
              ,p_def_exc_amount      => l_dummy_number
              ,p_bpl_cash_recd_val   => l_bpl_cash_recd_val
              );
            --
          end if;
          --
        end if;
        --
        if l_faterr_code is null then
          --
          if l_efc_row.used_val is not null
            and nvl(l_bpl_used_val,-999999999) <> l_efc_row.used_val
          then
            --
            l_adjfailed := TRUE;
            l_val_type  := 'BPL_USEDVAL';
            l_old_val1  := l_efc_row.used_val;
            l_new_val1  := l_bpl_used_val;
            --
          elsif l_efc_row.prvdd_val is not null
            and nvl(l_bpl_prvdd_val,-999999999) <> l_efc_row.prvdd_val
          then
            --
            l_adjfailed := TRUE;
            l_val_type  := 'BPL_PRVDDVAL';
            l_old_val1  := l_efc_row.prvdd_val;
            l_new_val1  := l_bpl_prvdd_val;
            --
          elsif l_efc_row.cash_recd_val is not null
            and nvl(l_bpl_cash_recd_val,-999999999) <> l_efc_row.cash_recd_val
          then
            --
            l_adjfailed := TRUE;
            l_val_type  := 'BPL_CASHRECDVAL';
            l_old_val1  := l_efc_row.cash_recd_val;
            l_new_val1  := l_bpl_cash_recd_val;
            --
          elsif l_efc_row.frftd_val is not null
            and nvl(l_bpl_frftd_val,-999999999) <> l_efc_row.frftd_val
          then
            --
            l_adjfailed := TRUE;
            l_val_type  := 'BPL_FRFTDVAL';
            l_old_val1  := l_efc_row.frftd_val;
            l_new_val1  := l_bpl_frftd_val;
            --
          elsif l_efc_row.rld_up_val is not null
            and nvl(l_bpl_rld_up_val,-999999999) <> l_efc_row.rld_up_val
          then
            --
            l_adjfailed := TRUE;
            l_val_type  := 'BPL_RLDUPVAL';
            l_old_val1  := l_efc_row.rld_up_val;
            l_new_val1  := l_bpl_rld_up_val;
            --
          else
            --
            l_adjfailed := FALSE;
            --
            if l_efc_row.used_val is not null then
              --
              l_val_type := 'BPL_USEDVAL';
              l_old_val1 := l_efc_row.used_val;
              l_new_val1 := l_bpl_used_val;
              --
            elsif l_efc_row.prvdd_val is not null then
              --
              l_val_type := 'BPL_PRVDDVAL';
              l_old_val1 := l_efc_row.prvdd_val;
              l_new_val1 := l_bpl_prvdd_val;
              --
            elsif l_efc_row.cash_recd_val is not null then
              --
              l_val_type := 'BPL_CASHRECDVAL';
              l_old_val1 := l_efc_row.cash_recd_val;
              l_new_val1 := l_bpl_cash_recd_val;
              --
            elsif l_efc_row.frftd_val is not null then
              --
              l_val_type := 'BPL_FRFTDVAL';
              l_old_val1 := l_efc_row.frftd_val;
              l_new_val1 := l_bpl_frftd_val;
              --
            elsif l_efc_row.rld_up_val is not null then
              --
              l_val_type := 'BPL_RLDUPVAL';
              l_old_val1 := l_efc_row.rld_up_val;
              l_new_val1 := l_bpl_rld_up_val;
              --
            end if;
            --
          end if;
          --
        end if;
        --
        if l_faterr_code is null
          and l_adjfailed
        then
          --
          if l_efc_row.prtt_enrt_rslt_id is null
            and l_faterr_code is null
          then
            --
            l_faterr_code := 'NULLBPLPENID';
            l_faterr_type := 'POTENTIALCODEBUG';
            --
          end if;
          --
          if l_efc_row.bnft_prvdr_pool_id is null
            and l_faterr_code is null
          then
            --
            l_faterr_code := 'NULLBPLBPPID';
            l_faterr_type := 'POTENTIALCODEBUG';
            --
          end if;
          --
          if l_efc_row.effective_end_date <> hr_api.g_eot
            and l_faterr_code is null
          then
            --
            l_faterr_code := 'BPLDTUPD';
            l_faterr_type := 'UNSUPPORTTRANS';
            --
          end if;
          --
          -- Check rounding
          --
          if l_faterr_code is null then
            --
            ben_efc_adjustments.DetectRoundInfo
              (p_rndg_cd        => null
              ,p_rndg_rl        => null
              ,p_old_val        => l_old_val1
              ,p_new_val        => l_new_val1
              ,p_eff_date       => l_efc_row.lf_evt_ocrd_dt
              --
              ,p_faterr_code    => l_faterr_code
              ,p_faterr_type    => l_faterr_type
              );
            --
          end if;
          --
          if l_faterr_code is null then
            --
            ben_efc_adjustments.DetectWhoInfo
              (p_creation_date         => l_efc_row.creation_date
              ,p_last_update_date      => l_efc_row.last_update_date
              ,p_object_version_number => l_efc_row.object_version_number
              --
              ,p_who_counts            => l_who_counts
              ,p_faterr_code           => l_faterr_code
              ,p_faterr_type           => l_faterr_type
              );
            --
          end if;
          --
          if l_faterr_code is null then
            --
            ben_efc_adjustments.g_bpl_failed_adj_val_set(l_calfail_count).id       := l_efc_row.bnft_prvdd_ldgr_id;
            ben_efc_adjustments.g_bpl_failed_adj_val_set(l_calfail_count).esd      := l_efc_row.effective_start_date;
            ben_efc_adjustments.g_bpl_failed_adj_val_set(l_calfail_count).eed      := l_efc_row.effective_end_date;
            ben_efc_adjustments.g_bpl_failed_adj_val_set(l_calfail_count).ovn      := l_efc_row.object_version_number;
            ben_efc_adjustments.g_bpl_failed_adj_val_set(l_calfail_count).credt    := l_efc_row.creation_date;
            ben_efc_adjustments.g_bpl_failed_adj_val_set(l_calfail_count).lud      := l_efc_row.last_update_date;
            ben_efc_adjustments.g_bpl_failed_adj_val_set(l_calfail_count).old_val1 := l_old_val1;
            ben_efc_adjustments.g_bpl_failed_adj_val_set(l_calfail_count).new_val1 := l_new_val1;
            ben_efc_adjustments.g_bpl_failed_adj_val_set(l_calfail_count).val_type := l_val_type;
            --
            l_calfail_count  := l_calfail_count+1;
            --
          end if;
          --
        end if;
        --
        if l_efc_batch and l_faterr_code is null
        then
          --
          update ben_bnft_prvdd_ldgr_f bpl
          set  bpl.used_val      = l_bpl_used_val,
               bpl.prvdd_val     = l_bpl_prvdd_val,
               bpl.cash_recd_val = l_bpl_cash_recd_val,
               bpl.frftd_val     = l_bpl_frftd_val,
               bpl.rld_up_val    = l_bpl_rld_up_val
          where bpl.bnft_prvdd_ldgr_id   = l_efc_row.bnft_prvdd_ldgr_id
          and   bpl.effective_start_date = l_efc_row.effective_start_date
          and   bpl.effective_end_date   = l_efc_row.effective_end_date;
          --
          if p_validate then
            --
            rollback;
            --
          end if;
          --
          -- Check for end of chunk and commit if necessary
          --
          l_pk1 := l_efc_row.bnft_prvdd_ldgr_id;
          --
          ben_efc_functions.maintain_chunks
            (p_row_count     => l_chunkrow_count
            ,p_pk1           => l_pk1
            ,p_chunk_size    => p_chunk
            ,p_efc_worker_id => p_efc_worker_id
            );
          --
        end if;
        --
      exception
        when others then
          --
          ben_efc_adjustments.g_bpl_rcoerr_val_set(l_rcoerr_count).id        := l_efc_row.bnft_prvdd_ldgr_id;
          ben_efc_adjustments.g_bpl_rcoerr_val_set(l_rcoerr_count).esd       := l_efc_row.effective_start_date;
          ben_efc_adjustments.g_bpl_rcoerr_val_set(l_rcoerr_count).eed       := l_efc_row.effective_end_date;
          ben_efc_adjustments.g_bpl_rcoerr_val_set(l_rcoerr_count).credt     := l_efc_row.creation_date;
          ben_efc_adjustments.g_bpl_rcoerr_val_set(l_rcoerr_count).lud       := l_efc_row.last_update_date;
          ben_efc_adjustments.g_bpl_rcoerr_val_set(l_rcoerr_count).rco_name  := 'BENPSTCR';
          ben_efc_adjustments.g_bpl_rcoerr_val_set(l_rcoerr_count).sql_error := SQLERRM;
          --
          l_rcoerr_count  := l_rcoerr_count+1;
          --
      end;
      --
    end if;
    --
    -- Check for fatal errors
    --
    if l_faterr_code is not null
    then
      --
      ben_efc_adjustments.g_bpl_fatal_error_val_set(l_faterrs_count).id          := l_efc_row.bnft_prvdd_ldgr_id;
      ben_efc_adjustments.g_bpl_fatal_error_val_set(l_faterrs_count).esd         := l_efc_row.effective_start_date;
      ben_efc_adjustments.g_bpl_fatal_error_val_set(l_faterrs_count).eed         := l_efc_row.effective_end_date;
      ben_efc_adjustments.g_bpl_fatal_error_val_set(l_faterrs_count).val_type    := l_val_type;
      ben_efc_adjustments.g_bpl_fatal_error_val_set(l_faterrs_count).old_val1    := l_old_val1;
      ben_efc_adjustments.g_bpl_fatal_error_val_set(l_faterrs_count).new_val1    := l_new_val1;
      ben_efc_adjustments.g_bpl_fatal_error_val_set(l_faterrs_count).faterr_code := l_faterr_code;
      ben_efc_adjustments.g_bpl_fatal_error_val_set(l_faterrs_count).faterr_type := l_faterr_type;
      ben_efc_adjustments.g_bpl_fatal_error_val_set(l_faterrs_count).lud         := l_efc_row.last_update_date;
      ben_efc_adjustments.g_bpl_fatal_error_val_set(l_faterrs_count).credt       := l_efc_row.creation_date;
      ben_efc_adjustments.g_bpl_fatal_error_val_set(l_faterrs_count).ovn         := l_efc_row.object_version_number;
      ben_efc_adjustments.g_bpl_fatal_error_val_set(l_faterrs_count).cre_by      := l_efc_row.created_by;
      ben_efc_adjustments.g_bpl_fatal_error_val_set(l_faterrs_count).lu_by       := l_efc_row.last_updated_by;
      --
      l_faterrs_count := l_faterrs_count+1;
      --
    elsif l_faterr_code is null
      and not l_adjfailed
    then
      --
      ben_efc_adjustments.g_bpl_success_adj_val_set(l_calsucc_count).id       := l_efc_row.bnft_prvdd_ldgr_id;
      ben_efc_adjustments.g_bpl_success_adj_val_set(l_calsucc_count).esd      := l_efc_row.effective_start_date;
      ben_efc_adjustments.g_bpl_success_adj_val_set(l_calsucc_count).eed      := l_efc_row.effective_end_date;
      ben_efc_adjustments.g_bpl_success_adj_val_set(l_calsucc_count).old_val1 := l_old_val1;
      ben_efc_adjustments.g_bpl_success_adj_val_set(l_calsucc_count).new_val1 := l_new_val1;
      ben_efc_adjustments.g_bpl_success_adj_val_set(l_calsucc_count).val_type := l_val_type;
      ben_efc_adjustments.g_bpl_success_adj_val_set(l_calsucc_count).credt    := l_efc_row.creation_date;
      ben_efc_adjustments.g_bpl_success_adj_val_set(l_calsucc_count).lud      := l_efc_row.last_update_date;
      --
      l_calsucc_count := l_calsucc_count+1;
      --
    end if;
    --
    l_row_count := l_row_count+1;
    --
  end loop;
  CLOSE c_efc_rows;
  --
  -- Check that all rows have been converted or excluded
  --
  ben_efc_functions.conv_check
    (p_table_name      => 'ben_bnft_prvdd_ldgr_f'
    ,p_efctable_name   => 'ben_bnft_prvdd_ldgr_f_efc'
    ,p_tabwhere_clause => ' (used_val is not null '
                          ||' or FRFTD_VAL is not null '
                          ||' or PRVDD_VAL is not null '
                          ||' or RLD_UP_VAL is not null '
                          ||' or CASH_RECD_VAL is not null '
                          ||' ) '
    --
    ,p_action_id       => p_action_id
    ,p_bgp_id          => p_business_group_id
    --
    ,p_conv_count      => l_conv_count
    ,p_unconv_count    => l_unconv_count
    ,p_tabrow_count    => l_tabrow_count
    );
  --
  -- Set counts
  --
  if p_action_id is null then
    --
    l_actconv_count := 0;
    --
  else
    --
    l_actconv_count := l_conv_count;
    --
  end if;
  --
  p_adjustment_counts.efcrow_count       := l_row_count;
  p_adjustment_counts.tabrow_count       := l_tabrow_count;
  p_adjustment_counts.calfail_count      := l_calfail_count;
  p_adjustment_counts.calsucc_count      := l_calsucc_count;
  p_adjustment_counts.rcoerr_count       := l_rcoerr_count;
  --
  p_adjustment_counts.actconv_count      := l_actconv_count;
  --
end bpl_adjustments;
--
end ben_efc_adjustments1;

/

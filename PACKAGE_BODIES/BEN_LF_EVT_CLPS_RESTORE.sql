--------------------------------------------------------
--  DDL for Package Body BEN_LF_EVT_CLPS_RESTORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LF_EVT_CLPS_RESTORE" as
/* $Header: benleclr.pkb 120.26.12010000.20 2010/05/14 03:13:19 pvelvano ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_lf_evt_clps_restore.';
--
g_sys_date date := trunc(sysdate);
g_bckt_csd_lf_evt_ocrd_dt date;
--
type g_pgm_rec is record
       (pgm_id              ben_pgm_f.pgm_id%type,
        enrt_mthd_cd        ben_prtt_enrt_rslt_f.enrt_mthd_cd%type,
        multi_row_edit_done boolean,
        non_automatics_flag boolean,
        max_enrt_esd        date);
--
type g_pl_rec is record
       (pl_id               ben_pl_f.pl_id%type,
        enrt_mthd_cd        ben_prtt_enrt_rslt_f.enrt_mthd_cd%type,
        multi_row_edit_done boolean,
        max_enrt_esd        date);
--
type g_enrt_rec is record
       (prtt_enrt_rslt_id        ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%type,
        bckdt_prtt_enrt_rslt_id  ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%type,
        bckdt_enrt_ovridn_flag   varchar2(1),
        bckdt_enrt_cvg_strt_dt   date,
        bckdt_enrt_cvg_thru_dt   date,
        enrt_ovrid_thru_dt       date,
        enrt_ovrid_rsn_cd        ben_prtt_enrt_rslt_f.enrt_ovrid_rsn_cd%type,
        g_sys_date               date,
        pen_ovn_number           ben_prtt_enrt_rslt_f.object_version_number%type,
        old_pl_id                ben_prtt_enrt_rslt_f.pl_id%type,
        new_pl_id                ben_prtt_enrt_rslt_f.pl_id%type,
        old_oipl_id              ben_prtt_enrt_rslt_f.oipl_id%type,
        new_oipl_id              ben_prtt_enrt_rslt_f.oipl_id%type,
        old_pl_typ_id            ben_prtt_enrt_rslt_f.pl_typ_id%type,
        new_pl_typ_id            ben_prtt_enrt_rslt_f.pl_typ_id%type,
        pgm_id                   ben_prtt_enrt_rslt_f.pgm_id%type,
        ler_id                   ben_ler_f.ler_id%type,
        elig_per_elctbl_chc_id   ben_elig_per_elctbl_chc.elig_per_elctbl_chc_id%type,
        dpnt_cvg_strt_dt_cd      ben_elig_per_elctbl_chc.dpnt_cvg_strt_dt_cd%type,
        dpnt_cvg_strt_dt_rl      ben_elig_per_elctbl_chc.dpnt_cvg_strt_dt_rl%type,
        effective_start_date     ben_prtt_enrt_rslt_f.effective_start_date%type,
	reinstate_flag varchar2(1) DEFAULT 'N',
	enrt_mthd_cd             varchar2(1) -- Bug 9045559
        );
--
type g_pgm_table  is table of g_pgm_rec  index by binary_integer;
type g_pl_table   is table of g_pl_rec   index by binary_integer;
type g_enrt_table is table of g_enrt_rec index by binary_integer;

--
--Start Private Cursors
  cursor g_bckdt_pen(
           c_bckdt_per_in_ler_id number,
           c_person_id           number,
           c_effective_date      date,
           c_pgm_id              number,
           c_pl_id               number )
           is
   select
          pen.EFFECTIVE_END_DATE,
          pen.ASSIGNMENT_ID,
          pen.BNFT_AMT,
          pen.BNFT_NNMNTRY_UOM,
          pen.BNFT_ORDR_NUM,
          pen.BNFT_TYP_CD,
          pen.BUSINESS_GROUP_ID,
          pen.COMP_LVL_CD,
          pen.CREATED_BY,
          pen.CREATION_DATE,
          pen.EFFECTIVE_START_DATE,
          pen.ENRT_CVG_STRT_DT,
          pen.ENRT_CVG_THRU_DT,
          pen.ENRT_MTHD_CD,
          pen.ENRT_OVRIDN_FLAG,
          pen.ENRT_OVRID_RSN_CD,
          pen.ENRT_OVRID_THRU_DT,
          pen.ERLST_DEENRT_DT,
          pen.LAST_UPDATED_BY,
          pen.LAST_UPDATE_DATE,
          pen.LAST_UPDATE_LOGIN,
          pen.LER_ID,
          pen.NO_LNGR_ELIG_FLAG,
          pen.OBJECT_VERSION_NUMBER,
          pen.OIPL_ID,
          pen.OIPL_ORDR_NUM,
          pen.ORGNL_ENRT_DT,
          pen.PEN_ATTRIBUTE1,
          pen.PEN_ATTRIBUTE10,
          pen.PEN_ATTRIBUTE11,
          pen.PEN_ATTRIBUTE12,
          pen.PEN_ATTRIBUTE13,
          pen.PEN_ATTRIBUTE14,
          pen.PEN_ATTRIBUTE15,
          pen.PEN_ATTRIBUTE16,
          pen.PEN_ATTRIBUTE17,
          pen.PEN_ATTRIBUTE18,
          pen.PEN_ATTRIBUTE19,
          pen.PEN_ATTRIBUTE2,
          pen.PEN_ATTRIBUTE20,
          pen.PEN_ATTRIBUTE21,
          pen.PEN_ATTRIBUTE22,
          pen.PEN_ATTRIBUTE23,
          pen.PEN_ATTRIBUTE24,
          pen.PEN_ATTRIBUTE25,
          pen.PEN_ATTRIBUTE26,
          pen.PEN_ATTRIBUTE27,
          pen.PEN_ATTRIBUTE28,
          pen.PEN_ATTRIBUTE29,
          pen.PEN_ATTRIBUTE3,
          pen.PEN_ATTRIBUTE30,
          pen.PEN_ATTRIBUTE4,
          pen.PEN_ATTRIBUTE5,
          pen.PEN_ATTRIBUTE6,
          pen.PEN_ATTRIBUTE7,
          pen.PEN_ATTRIBUTE8,
          pen.PEN_ATTRIBUTE9,
          pen.PEN_ATTRIBUTE_CATEGORY,
          pen.PERSON_ID,
          pen.PER_IN_LER_ID,
          pen.PGM_ID,
          pen.PLIP_ORDR_NUM,
          pen.PL_ID,
          pen.PL_ORDR_NUM,
          pen.PL_TYP_ID,
          pen.PROGRAM_APPLICATION_ID,
          pen.PROGRAM_ID,
          pen.PROGRAM_UPDATE_DATE,
          pen.PRTT_ENRT_RSLT_ID,
          pen.PRTT_ENRT_RSLT_STAT_CD,
          pen.PRTT_IS_CVRD_FLAG,
          pen.PTIP_ID,
          pen.PTIP_ORDR_NUM,
          pen.REQUEST_ID,
          pen.RPLCS_SSPNDD_RSLT_ID,
          pen.SSPNDD_FLAG,
          pen.UOM
    from   ben_prtt_enrt_rslt_f pen,
           ben_per_in_ler pil,
           ben_pil_elctbl_chc_popl pel --Added for Bug 4423161
    where  pil.per_in_ler_id       = c_bckdt_per_in_ler_id
    and    pil.person_id           = c_person_id
    and    pil.per_in_ler_id       = pen.per_in_ler_id
    and    pil.per_in_ler_id       = pel.per_in_ler_id
    and    ((pel.pgm_id is null and c_pgm_id is null) or
             pel.pgm_id = c_pgm_id )
    and    ( c_pl_id is null or
             pel.pl_id = c_pl_id )
    and    (pel.dflt_asnd_dt is not null or
            pel.elcns_made_dt is not null or
	    pel.auto_asnd_dt is not null) -- Bug 8305552, Check for Automatic Enrolled Plans
    --To Handle Programs and  Plans not in Program
    and    ((pen.pgm_id is null and c_pgm_id is null) or
             pen.pgm_id = c_pgm_id )
    and    ( c_pl_id is null or
             pen.pl_id = c_pl_id )
    and    (pen.effective_end_date = hr_api.g_eot or
            pen.effective_end_date = (select max(effective_end_date)
                                        from ben_prtt_enrt_rslt_f
                                       where prtt_enrt_rslt_id =
                                                         pen.prtt_enrt_rslt_id))
    and    (pen.enrt_cvg_thru_dt is null or
            pen.enrt_cvg_thru_dt    = hr_api.g_eot
           )
    and    pen.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
    and pen.prtt_enrt_rslt_id not in (
         select nvl(pen_inner.RPLCS_SSPNDD_RSLT_ID, -1)
           from   ben_prtt_enrt_rslt_f pen_inner,
                  ben_per_in_ler pil_inner
           where  pil_inner.per_in_ler_id       = c_bckdt_per_in_ler_id
           and    pil_inner.person_id           = c_person_id
           and    pil_inner.per_in_ler_id       = pen_inner.per_in_ler_id
           and    (pen_inner.enrt_cvg_thru_dt is null or
                   pen_inner.enrt_cvg_thru_dt    = hr_api.g_eot
                  )
           and    pen_inner.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
         union
         select nvl(pen_inner.RPLCS_SSPNDD_RSLT_ID, -1)
             from  ben_le_clsn_n_rstr  pen_inner,
                    ben_per_in_ler pil_inner
             where  pil_inner.per_in_ler_id       = c_bckdt_per_in_ler_id
             and    pil_inner.person_id           = c_person_id
             AND    pil_inner.per_in_ler_id       = pen_inner.per_in_ler_id
             and    pen_inner.bkup_tbl_typ_cd     = 'BEN_PRTT_ENRT_RSLT_F'
           and    (pen_inner.enrt_cvg_thru_dt is null or
                   pen_inner.enrt_cvg_thru_dt    = hr_api.g_eot
                  )
           and    pen_inner.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
       )
   union
   select
          pen.EFFECTIVE_END_DATE,
          pen.ASSIGNMENT_ID,
          pen.BNFT_AMT,
          pen.BNFT_NNMNTRY_UOM,
          pen.BNFT_ORDR_NUM,
          pen.BNFT_TYP_CD,
          pen.BUSINESS_GROUP_ID,
          pen.COMP_LVL_CD,
          pen.CREATED_BY,
          pen.CREATION_DATE,
          pen.EFFECTIVE_START_DATE,
          pen.ENRT_CVG_STRT_DT,
          pen.ENRT_CVG_THRU_DT,
          pen.ENRT_MTHD_CD,
          pen.ENRT_OVRIDN_FLAG,
          pen.ENRT_OVRID_RSN_CD,
          pen.ENRT_OVRID_THRU_DT,
          pen.ERLST_DEENRT_DT,
          pen.LAST_UPDATED_BY,
          pen.LAST_UPDATE_DATE,
          pen.LAST_UPDATE_LOGIN,
          pen.LER_ID,
          pen.NO_LNGR_ELIG_FLAG,
          pen.OBJECT_VERSION_NUMBER,
          pen.OIPL_ID,
          pen.OIPL_ORDR_NUM,
          pen.ORGNL_ENRT_DT,
          pen.LCR_ATTRIBUTE1,
          pen.LCR_ATTRIBUTE10,
          pen.LCR_ATTRIBUTE11,
          pen.LCR_ATTRIBUTE12,
          pen.LCR_ATTRIBUTE13,
          pen.LCR_ATTRIBUTE14,
          pen.LCR_ATTRIBUTE15,
          pen.LCR_ATTRIBUTE16,
          pen.LCR_ATTRIBUTE17,
          pen.LCR_ATTRIBUTE18,
          pen.LCR_ATTRIBUTE19,
          pen.LCR_ATTRIBUTE2,
          pen.LCR_ATTRIBUTE20,
          pen.LCR_ATTRIBUTE21,
          pen.LCR_ATTRIBUTE22,
          pen.LCR_ATTRIBUTE23,
          pen.LCR_ATTRIBUTE24,
          pen.LCR_ATTRIBUTE25,
          pen.LCR_ATTRIBUTE26,
          pen.LCR_ATTRIBUTE27,
          pen.LCR_ATTRIBUTE28,
          pen.LCR_ATTRIBUTE29,
          pen.LCR_ATTRIBUTE3,
          pen.LCR_ATTRIBUTE30,
          pen.LCR_ATTRIBUTE4,
          pen.LCR_ATTRIBUTE5,
          pen.LCR_ATTRIBUTE6,
          pen.LCR_ATTRIBUTE7,
          pen.LCR_ATTRIBUTE8,
          pen.LCR_ATTRIBUTE9,
          pen.LCR_ATTRIBUTE_CATEGORY,
          pen.PERSON_ID,
          pen.PER_IN_LER_ID,
          pen.PGM_ID,
          pen.PLIP_ORDR_NUM,
          pen.PL_ID,
          pen.PL_ORDR_NUM,
          pen.PL_TYP_ID,
          pen.PROGRAM_APPLICATION_ID,
          pen.PROGRAM_ID,
          pen.PROGRAM_UPDATE_DATE,
          pen.bkup_tbl_id, -- Mapped to PRTT_ENRT_RSLT_ID,
          pen.PRTT_ENRT_RSLT_STAT_CD,
          pen.PRTT_IS_CVRD_FLAG,
          pen.PTIP_ID,
          pen.PTIP_ORDR_NUM,
          pen.REQUEST_ID,
          pen.RPLCS_SSPNDD_RSLT_ID,
          pen.SSPNDD_FLAG,
          pen.UOM
    from  ben_le_clsn_n_rstr  pen,
          ben_per_in_ler pil,
          ben_pil_elctbl_chc_popl pel   --Added for Bug 4423161
    where  pil.per_in_ler_id       = c_bckdt_per_in_ler_id
    and    pil.person_id           = c_person_id
    and    pil.per_in_ler_id       = pel.per_in_ler_id
    and    ((pel.pgm_id is null and c_pgm_id is null) or
             pel.pgm_id = c_pgm_id )
    and    ( c_pl_id is null or
             pel.pl_id = c_pl_id )
    and    (pel.dflt_asnd_dt is not null or
            pel.elcns_made_dt is not null or
	    pel.auto_asnd_dt is not null) -- Bug 8305552, Check for Automatic Enrolled Plans
    AND    pil.per_in_ler_id       = pen.per_in_ler_id
    and    pen.bkup_tbl_typ_cd     = 'BEN_PRTT_ENRT_RSLT_F'
    --To Handle Programs and  Plans not in Program
    and    ((pen.pgm_id is null and c_pgm_id is null) or
             pen.pgm_id = c_pgm_id )
    and    ( c_pl_id is null or
             pen.pl_id = c_pl_id )
    and    ((pen.enrt_cvg_thru_dt is null or
            pen.enrt_cvg_thru_dt    = hr_api.g_eot)  and
            pen.effective_end_date  = hr_api.g_eot
           )
    and    pen.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
    and pen.bkup_tbl_id not in (
         select nvl(pen_inner.RPLCS_SSPNDD_RSLT_ID, -1)
           from   ben_prtt_enrt_rslt_f pen_inner,
                  ben_per_in_ler pil_inner
           where  pil_inner.per_in_ler_id       = c_bckdt_per_in_ler_id
           and    pil_inner.person_id           = c_person_id
           and    pil_inner.per_in_ler_id       = pen_inner.per_in_ler_id
           and    (pen_inner.enrt_cvg_thru_dt is null or
                   pen_inner.enrt_cvg_thru_dt    = hr_api.g_eot
                  )
           and    pen_inner.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
         union
         select nvl(pen_inner.RPLCS_SSPNDD_RSLT_ID, -1)
             from  ben_le_clsn_n_rstr  pen_inner,
                    ben_per_in_ler pil_inner
             where  pil_inner.per_in_ler_id       = c_bckdt_per_in_ler_id
             and    pil_inner.person_id           = c_person_id
             AND    pil_inner.per_in_ler_id       = pen_inner.per_in_ler_id
             and    pen_inner.bkup_tbl_typ_cd     = 'BEN_PRTT_ENRT_RSLT_F'
           and    (pen_inner.enrt_cvg_thru_dt is null or
                   pen_inner.enrt_cvg_thru_dt    = hr_api.g_eot
                  )
           and    pen_inner.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
       )
    order by 1;
  --
  TYPE g_bckdt_pen_tbl is TABLE OF g_bckdt_pen%rowtype INDEX BY BINARY_INTEGER;


  /* Bug 8900007: Cursor g_bckdt_pen_sspnd_rslt is used to fetch all the
  carry forward enrollments created for the backedout LE */
  cursor g_bckdt_pen_sspnd_rslt(
           c_bckdt_per_in_ler_id number,
           c_person_id           number,
           c_effective_date      date)
           is
   select
          pen.EFFECTIVE_END_DATE,
          pen.BUSINESS_GROUP_ID,
          pen.EFFECTIVE_START_DATE,
          pen.ENRT_CVG_STRT_DT,
          pen.ENRT_CVG_THRU_DT,
          pen.ENRT_MTHD_CD,
          pen.OBJECT_VERSION_NUMBER,
          pen.OIPL_ID,
          pen.PERSON_ID,
          pen.PER_IN_LER_ID,
          pen.PGM_ID,
          pen.PL_ID,
          pen.PL_TYP_ID,
          pen.PRTT_ENRT_RSLT_ID,
          pen.PRTT_ENRT_RSLT_STAT_CD,
          pen.PTIP_ID,
          pen.RPLCS_SSPNDD_RSLT_ID,
          pen.SSPNDD_FLAG
    from   ben_prtt_enrt_rslt_f pen,
           ben_per_in_ler pil,
           ben_pil_elctbl_chc_popl pel --Added for Bug 4423161
    where  pil.per_in_ler_id       = c_bckdt_per_in_ler_id
    and    pil.person_id           = c_person_id
    and    pil.per_in_ler_id       = pen.per_in_ler_id
    and    pil.per_in_ler_id       = pel.per_in_ler_id
    and    (pel.dflt_asnd_dt is null and
            pel.elcns_made_dt is null) -- Bug 8305552, Check for Automatic Enrolled Plans
    and exists
                 (select '1' from ben_prtt_enrt_rslt_f epen where
	                  epen.per_in_ler_id       = c_bckdt_per_in_ler_id
			  and epen.person_id       = c_person_id
			  and (epen.enrt_cvg_thru_dt is null or
                               epen.enrt_cvg_thru_dt    = hr_api.g_eot)
			  and epen.effective_end_date  = hr_api.g_eot)
    --To Handle Programs and  Plans not in Program
    and    (pen.effective_end_date = hr_api.g_eot or
            pen.effective_end_date = (select max(effective_end_date)
                                        from ben_prtt_enrt_rslt_f
                                       where prtt_enrt_rslt_id =
                                                         pen.prtt_enrt_rslt_id))
    and    (pen.enrt_cvg_thru_dt is null or
            pen.enrt_cvg_thru_dt    = hr_api.g_eot
           )
    and    pen.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
    and pen.prtt_enrt_rslt_id not in (
         select nvl(pen_inner.RPLCS_SSPNDD_RSLT_ID, -1)
           from   ben_prtt_enrt_rslt_f pen_inner,
                  ben_per_in_ler pil_inner
           where  pil_inner.per_in_ler_id       = c_bckdt_per_in_ler_id
           and    pil_inner.person_id           = c_person_id
           and    pil_inner.per_in_ler_id       = pen_inner.per_in_ler_id
           and    (pen_inner.enrt_cvg_thru_dt is null or
                   pen_inner.enrt_cvg_thru_dt    = hr_api.g_eot
                  )
           and    pen_inner.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
         union
         select nvl(pen_inner.RPLCS_SSPNDD_RSLT_ID, -1)
             from  ben_le_clsn_n_rstr  pen_inner,
                    ben_per_in_ler pil_inner
             where  pil_inner.per_in_ler_id       = c_bckdt_per_in_ler_id
             and    pil_inner.person_id           = c_person_id
             AND    pil_inner.per_in_ler_id       = pen_inner.per_in_ler_id
             and    pen_inner.bkup_tbl_typ_cd     = 'BEN_PRTT_ENRT_RSLT_F'
           and    (pen_inner.enrt_cvg_thru_dt is null or
                   pen_inner.enrt_cvg_thru_dt    = hr_api.g_eot
                  )
           and    pen_inner.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
       )
   union
   select
          pen.EFFECTIVE_END_DATE,
          pen.BUSINESS_GROUP_ID,
          pen.EFFECTIVE_START_DATE,
          pen.ENRT_CVG_STRT_DT,
          pen.ENRT_CVG_THRU_DT,
          pen.ENRT_MTHD_CD,
	  pen.OBJECT_VERSION_NUMBER,
          pen.OIPL_ID,
          pen.PERSON_ID,
          pen.PER_IN_LER_ID,
          pen.PGM_ID,
          pen.PL_ID,
          pen.PL_TYP_ID,
          pen.bkup_tbl_id, -- Mapped to PRTT_ENRT_RSLT_ID,
          pen.PRTT_ENRT_RSLT_STAT_CD,
          pen.PTIP_ID,
          pen.RPLCS_SSPNDD_RSLT_ID,
          pen.SSPNDD_FLAG
    from  ben_le_clsn_n_rstr  pen,
          ben_per_in_ler pil,
          ben_pil_elctbl_chc_popl pel   --Added for Bug 4423161
    where  pil.per_in_ler_id       = c_bckdt_per_in_ler_id
    and    pil.person_id           = c_person_id
    and    pil.per_in_ler_id       = pel.per_in_ler_id
    and    (pel.dflt_asnd_dt is null and
            pel.elcns_made_dt is null) -- Bug 8305552, Check for Automatic Enrolled Plans
    and exists
                 (select '1' from ben_prtt_enrt_rslt_f epen where
	                  epen.per_in_ler_id       = c_bckdt_per_in_ler_id
			  and epen.person_id       = c_person_id
			  and (epen.enrt_cvg_thru_dt is null or
                               epen.enrt_cvg_thru_dt    = hr_api.g_eot)
			  and epen.effective_end_date  = hr_api.g_eot)
    AND    pil.per_in_ler_id       = pen.per_in_ler_id
    and    pen.bkup_tbl_typ_cd     = 'BEN_PRTT_ENRT_RSLT_F'
    and    ((pen.enrt_cvg_thru_dt is null or
            pen.enrt_cvg_thru_dt    = hr_api.g_eot)  and
            pen.effective_end_date  = hr_api.g_eot
           )
    and    pen.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
    and pen.bkup_tbl_id not in (
         select nvl(pen_inner.RPLCS_SSPNDD_RSLT_ID, -1)
           from   ben_prtt_enrt_rslt_f pen_inner,
                  ben_per_in_ler pil_inner
           where  pil_inner.per_in_ler_id       = c_bckdt_per_in_ler_id
           and    pil_inner.person_id           = c_person_id
           and    pil_inner.per_in_ler_id       = pen_inner.per_in_ler_id
           and    (pen_inner.enrt_cvg_thru_dt is null or
                   pen_inner.enrt_cvg_thru_dt    = hr_api.g_eot
                  )
           and    pen_inner.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
         union
         select nvl(pen_inner.RPLCS_SSPNDD_RSLT_ID, -1)
             from  ben_le_clsn_n_rstr  pen_inner,
                    ben_per_in_ler pil_inner
             where  pil_inner.per_in_ler_id       = c_bckdt_per_in_ler_id
             and    pil_inner.person_id           = c_person_id
             AND    pil_inner.per_in_ler_id       = pen_inner.per_in_ler_id
             and    pen_inner.bkup_tbl_typ_cd     = 'BEN_PRTT_ENRT_RSLT_F'
           and    (pen_inner.enrt_cvg_thru_dt is null or
                   pen_inner.enrt_cvg_thru_dt    = hr_api.g_eot
                  )
           and    pen_inner.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
       )
    order by 1;
  --
  --
--End Private Cursors
--
function get_epe
  (p_per_in_ler_id  in     number
  ,p_pgm_id         in     number
  ,p_pl_id          in     number
  ,p_oipl_id        in     number
  --
  ) return number
is
  --
  l_proc varchar2(72) :=  'get_epe';
  --
  l_elig_per_elctbl_chc_id number ;
  --
  CURSOR c_choice_exists_for_option
    (c_per_in_ler_id  number
    ,c_pgm_id         number
    ,c_oipl_id        number
    )
  is
    SELECT   epe.elig_per_elctbl_chc_id
    FROM     ben_elig_per_elctbl_chc epe
    WHERE    epe.oipl_id = c_oipl_id
    AND      epe.pgm_id = c_pgm_id
    AND      epe.per_in_ler_id = c_per_in_ler_id;
  --
  CURSOR c_chc_exists_for_plnip_option
    (c_per_in_ler_id  number
    ,c_oipl_id        number
    )
  is
    SELECT   epe.elig_per_elctbl_chc_id
    FROM     ben_elig_per_elctbl_chc epe
    WHERE    epe.oipl_id = c_oipl_id
    AND      epe.pgm_id IS NULL
    AND      epe.per_in_ler_id = c_per_in_ler_id;
  --
  CURSOR c_choice_exists_for_plan
    (c_per_in_ler_id number
    ,c_pgm_id        number
    ,c_pl_id         number
    )
  is
    SELECT   epe.elig_per_elctbl_chc_id
    FROM     ben_elig_per_elctbl_chc epe
    WHERE    epe.pl_id = c_pl_id
    AND      epe.oipl_id IS NULL
    AND      epe.pgm_id = c_pgm_id
    AND      epe.per_in_ler_id = c_per_in_ler_id;
    --
  CURSOR c_choice_exists_for_plnip
    (c_per_in_ler_id number
    ,c_pl_id         number
    )
  is
    SELECT   epe.elig_per_elctbl_chc_id
    FROM     ben_elig_per_elctbl_chc epe
    WHERE    epe.pl_id = c_pl_id
    AND      epe.oipl_id IS NULL
    AND      epe.pgm_id IS NULL
    AND      epe.per_in_ler_id = c_per_in_ler_id;
    --
begin
  --
  if p_oipl_id is null
  then
    --
    if p_pgm_id is not null
    then
      --
      OPEN c_choice_exists_for_plan
        (c_per_in_ler_id  => p_per_in_ler_id
        ,c_pgm_id         => p_pgm_id
        ,c_pl_id          => p_pl_id
        );
      FETCH c_choice_exists_for_plan INTO l_elig_per_elctbl_chc_id;
      CLOSE c_choice_exists_for_plan;
      --
    else
      --
      OPEN c_choice_exists_for_plnip
        (c_per_in_ler_id  => p_per_in_ler_id
        ,c_pl_id          => p_pl_id
        );
      FETCH c_choice_exists_for_plnip INTO l_elig_per_elctbl_chc_id;
      CLOSE c_choice_exists_for_plnip;
      --
    end if;
    --
  else
    --
    if p_pgm_id is not null
    then
      --
      OPEN c_choice_exists_for_option
        (c_per_in_ler_id  => p_per_in_ler_id
        ,c_pgm_id         => p_pgm_id
        ,c_oipl_id        => p_oipl_id
        );
      FETCH c_choice_exists_for_option INTO l_elig_per_elctbl_chc_id;
      CLOSE c_choice_exists_for_option;
      --
    else
      --
      OPEN c_chc_exists_for_plnip_option
        (c_per_in_ler_id  => p_per_in_ler_id
        ,c_oipl_id        => p_oipl_id
        );
      FETCH c_chc_exists_for_plnip_option INTO l_elig_per_elctbl_chc_id;
      CLOSE c_chc_exists_for_plnip_option;
      --
    end if;
    --
  end if;
  --
  return l_elig_per_elctbl_chc_id;
  --
end get_epe;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_ori_bckdt_pil >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure default_comp_obj
                  (p_validate           in  Boolean default FALSE
                  ,p_per_in_ler_id      in  Number
                  ,p_person_id          in  Number
                  ,p_business_group_id  in  Number
                  ,p_effective_date     in  Date
                  ,p_pgm_id             in  Number
                  ,p_pl_nip_id          in  Number
                  ,p_susp_flag          out nocopy Boolean
                  ,p_batch_flag         in  Boolean default FALSE
                  ,p_cls_enrt_flag      in  Boolean default TRUE
                  ,p_called_frm_ss      in  Boolean default FALSE
                  ,p_reinstate_dflts_flag in varchar2 default 'N' -- Enhancement Bug :8716679
                  ,p_prev_per_in_ler_id in Number default null -- Enhancement Bug :8716679
                  ) is
--
l_proc                    varchar2(72) := g_package||'.default_comp_obj';
begin
  --
  ben_manage_default_enrt.default_comp_obj
                  (p_validate           => p_validate
                  ,p_per_in_ler_id      => p_per_in_ler_id
                  ,p_person_id          => p_person_id
                  ,p_business_group_id  => p_business_group_id
                  ,p_effective_date     => p_effective_date
                  ,p_pgm_id             => p_pgm_id
                  ,p_pl_nip_id          => p_pl_nip_id
                  ,p_susp_flag          => p_susp_flag
                  ,p_batch_flag         => p_batch_flag
                  ,p_cls_enrt_flag      => p_cls_enrt_flag
                  ,p_called_frm_ss      => p_called_frm_ss
		  ,p_reinstate_dflts_flag => p_reinstate_dflts_flag -- Enhancement Bug :8716679
		  ,p_prev_per_in_ler_id => p_prev_per_in_ler_id -- Enhancement Bug :8716679
                 );
  --
end default_comp_obj ;
--
procedure get_ori_bckdt_pil(p_person_id            in number
                            ,p_business_group_id   in number
                            ,p_ler_id              in number
                            ,p_effective_date      in date
                            ,p_bckdt_per_in_ler_id out nocopy number
                           ) is
  --
  l_proc                    varchar2(72) := g_package||'.get_ori_bckdt_pil';
  --
  -- Get the info of pil which got backed out and also the pil
  -- which backed it.
  --
  -- #3248770 voided per in ler is not reinsated , the staus is validated

  cursor get_bckdt_per_in_ler is
    select pil.per_in_ler_id,
           ler.name,
           pil.bckt_per_in_ler_id,
           ler_cs_bckdt.name ler_cs_bckdt_name
    from   ben_per_in_ler pil
          ,ben_ler_f      ler
          ,ben_per_in_ler pil_cs_bckdt
          ,ben_ler_f      ler_cs_bckdt
          ,ben_ptnl_ler_for_per  plr
    where  pil.person_id            = p_person_id
    and    pil.business_group_id    = p_business_group_id
    and    pil.ler_id               = p_ler_id
    and    pil.ler_id               = ler.ler_id
    and    ler.business_group_id    = pil.business_group_id
    and    pil.per_in_ler_stat_cd   = 'BCKDT'
    and    pil.bckt_per_in_ler_id   = pil_cs_bckdt.per_in_ler_id(+)
    and    pil_cs_bckdt.ler_id      = ler_cs_bckdt.ler_id(+)
    and    pil.ptnl_ler_for_per_id   = plr.ptnl_ler_for_per_id
    and    plr.ptnl_ler_for_per_stat_cd <> 'VOIDD'
    and    nvl(pil_cs_bckdt.business_group_id, p_business_group_id) = p_business_group_id
    and    nvl(ler_cs_bckdt.business_group_id, p_business_group_id) = p_business_group_id
    and    pil.lf_evt_ocrd_dt       = p_effective_date
    and    pil.ler_id <> ben_manage_life_events.g_ler_id
    and    p_effective_date between ler.effective_start_date
                                and ler.effective_end_date
    and    p_effective_date between nvl(ler_cs_bckdt.effective_start_date, p_effective_date)
                                and nvl(ler_cs_bckdt.effective_end_date, p_effective_date)
    order by pil.per_in_ler_id desc
   ;
  --
  l_bckdt_per_in_ler_rec          get_bckdt_per_in_ler%ROWTYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  open  get_bckdt_per_in_ler;
  fetch get_bckdt_per_in_ler into l_bckdt_per_in_ler_rec;
  --
  p_bckdt_per_in_ler_id := l_bckdt_per_in_ler_rec.per_in_ler_id;
  g_bckdt_ler_name      := l_bckdt_per_in_ler_rec.name;
  g_ler_name_cs_bckdt   := l_bckdt_per_in_ler_rec.ler_cs_bckdt_name;
  g_pil_id_cs_bckdt     := l_bckdt_per_in_ler_rec.bckt_per_in_ler_id;
  --
  if get_bckdt_per_in_ler%found then
    --
    hr_utility.set_location('backout per in ler :'||  p_bckdt_per_in_ler_id, 10);
    fnd_message.set_name('BEN','BEN_92246_BCKDT_PIL_FOUND');
    fnd_message.set_token('LER_NAME',l_bckdt_per_in_ler_rec.name);
    benutils.write(p_text => fnd_message.get);
    --
  end if;
  close get_bckdt_per_in_ler;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end get_ori_bckdt_pil;
--
-- ----------------------------------------------------------------------------
-- |------------------------< ele_made_for_bckdt_pil >-------------------------|
-- ----------------------------------------------------------------------------
--
-- If elections were made for the backout per in ler then
-- return Y else N
--
function  ele_made_for_bckdt_pil (
                        p_bckdt_per_in_ler_id      in number,
                        p_person_id                in number,
                        p_business_group_id        in number,
                        p_effective_date           in date) return varchar2 is
  --
  l_proc                     varchar2(72) := g_package||'.ele_made_for_bckdt_pil';
  --
  --
  -- To determine whether elections are made for backed out
  -- life events.
  --
  cursor c_enrt_rslt_exists is
    select 'Y'
    from   ben_prtt_enrt_rslt_f pen,
           ben_per_in_ler pil
    where  pil.per_in_ler_id = p_bckdt_per_in_ler_id
    and    pil.business_group_id = p_business_group_id
    and    pen.per_in_ler_id = pil.per_in_ler_id
    and    pen.business_group_id = pil.business_group_id
    and    pen.prtt_enrt_rslt_stat_cd = 'BCKDT'
    and    nvl(pen.prtt_enrt_rslt_stat_cd, 'XXXX') =  'BCKDT'
    and    p_effective_date between pen.effective_start_date
                                and pen.effective_end_date
    /* 9999 complete this part from the backup table  */
    union
    select 'Y'
    from  ben_le_clsn_n_rstr lcr
    where lcr.per_in_ler_id = p_bckdt_per_in_ler_id
    and    lcr.business_group_id = p_business_group_id
    and    p_effective_date between lcr.effective_start_date
                                and lcr.effective_end_date;
  -- 9999 only p_effective_date => esd is relevant check with examples.
  --
  l_enrt_rslt_exists varchar2(1) := 'N';
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  open c_enrt_rslt_exists;
  fetch c_enrt_rslt_exists into  l_enrt_rslt_exists;
  close c_enrt_rslt_exists;
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
  return l_enrt_rslt_exists;
  --
end ele_made_for_bckdt_pil;
--
-- ----------------------------------------------------------------------------
-- |------------------------< ele_made_for_inter_pil >-------------------------|
-- ----------------------------------------------------------------------------
--
function comp_prev_new_pen(p_person_id               in number
                              ,p_business_group_id   in number
                              ,p_effective_date      in date
                              ,p_new_per_in_ler_id   in number
                              ,p_prev_per_in_ler_id  in number
                           ) return varchar2 is
  --
  l_proc                   varchar2(72) := g_package||'.comp_ori_new_pen';
  --
  -- Following are the tables whose data will be compared to
  -- find any differences exists between the two runs of same ler.
  --
  -- ben_prtt_enrt_rslt_f
  --
  cursor c_pen_dat(p_pil_id number) is
   select
          pen.OIPL_ID,
          pen.PGM_ID,
          pen.PL_ID,
          pen.SSPNDD_FLAG
    from   ben_prtt_enrt_rslt_f pen,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_pil_id
    and    pil.person_id           = p_person_id
    and    pil.business_group_id = p_business_group_id
    AND    pil.per_in_ler_id       = pen.per_in_ler_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.enrt_cvg_thru_dt    = hr_api.g_eot
    and    pen.comp_lvl_cd         not in ('PLANFC', 'PLANIMP') ;
  --
  TYPE l_prev_pen_rec is TABLE OF c_pen_dat%rowtype INDEX BY BINARY_INTEGER;
  --
  TYPE l_int_pen_rec is TABLE OF c_pen_dat%rowtype INDEX BY BINARY_INTEGER;
  --
  l_differ         varchar2(1) := 'N';
  l_prev_pen_table l_prev_pen_rec;
  l_int_pen_table  l_int_pen_rec;
  l_next_row       binary_integer := 1 ;
  l_found          boolean;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  hr_utility.set_location ('Entering bck pil id '||p_prev_per_in_ler_id,10);
  hr_utility.set_location ('Entering pil id '||p_new_per_in_ler_id,10);
  --
  --
  for  int_pen_rec in c_pen_dat(p_new_per_in_ler_id)
  loop
     --
     l_int_pen_table(l_next_row)   := int_pen_rec;
     l_next_row := l_next_row + 1;
     --
  end loop;
  --
  -- Check Number of records in both tables differ
  --
  if nvl(l_int_pen_table.last, 0) = 0 then
       --
       l_differ := 'N';
       hr_utility.set_location('Leaving:  ' || l_differ
                                            ||' 0 '|| l_proc, 10);
       return l_differ;
       --
  end if;
  --
  -- Now compare the original pen record and new pen record.
  --
  hr_utility.set_location(to_char(nvl(l_int_pen_table.last, 0)) ,4987);
  --
  --
  hr_utility.set_location(' Before first Loop ',4987);
  for  l_int_count in l_int_pen_table.first..l_int_pen_table.last loop
    --
    l_found  := FALSE;
    --
    hr_utility.set_location(' Before Loop ',4987);
    for prev_pen_rec in c_pen_dat(p_prev_per_in_ler_id)
    loop
      --
      hr_utility.set_location(' Before if ',4987);
      if nvl(prev_pen_rec.SSPNDD_FLAG, '$') =
                   nvl(l_int_pen_table(l_int_count).SSPNDD_FLAG, '$') and
         nvl(prev_pen_rec.PGM_ID, -1) =
                   nvl(l_int_pen_table(l_int_count).PGM_ID, -1) and
         nvl(prev_pen_rec.PL_ID, -1) =
                   nvl(l_int_pen_table(l_int_count).PL_ID, -1) and
         nvl(prev_pen_rec.OIPL_ID, -1) =
            nvl(l_int_pen_table(l_int_count).OIPL_ID, -1)
      then
        --
        l_found   := TRUE;
        --
        exit;
      end if;
      --
    end loop;
    --
    if l_found   = FALSE then
       --
       l_differ := 'Y';
       exit;
    end if;
    --
  end loop;
  --
  hr_utility.set_location('Leaving:' || l_differ || l_proc, 10);
  --
  return l_differ;
  --
end comp_prev_new_pen;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_inter_pil_cnt >-------------------------|
-- ----------------------------------------------------------------------------
--
-- If more than one pil exists between two runs of a pil then
-- no restoration to be done.
--
procedure  get_inter_pil_cnt (
                        p_bckdt_per_in_ler_id      in number,
                        p_per_in_ler_id            in number,
                        p_person_id                in number,
                        p_bckt_csd_lf_evt_ocrd_dt  out nocopy date,
                        p_bckt_csd_per_in_ler_id   out nocopy number,
                        p_inter_per_in_ler_id      out nocopy number,
                        p_inter_pil_ovn            out nocopy number,
                        p_inter_pil_cnt            out nocopy number,
                        p_inter_pil_le_dt          out nocopy date,
                        p_business_group_id        in number,
                        p_effective_date           in date) is
  --
  l_proc                     varchar2(72) := g_package||'.get_inter_pil_cnt';
  --
  -- Bug 4987 ( WWW Bug 1266433)
  -- When counting the intervening life events only count the pil's
  -- whose lf_evt_ocrd_dt is more than the back out date of the
  -- backed out per in ler.
  --
  cursor c_bckt_csd_pil is
         select csd_pil.lf_evt_ocrd_dt,
                csd_pil.per_in_ler_id
         from ben_per_in_ler csd_pil,
              ben_per_in_ler bckt_pil
         where bckt_pil.per_in_ler_id = p_bckdt_per_in_ler_id
           and bckt_pil.BCKT_PER_IN_LER_ID = csd_pil.per_in_ler_id
           and bckt_pil.business_group_id = p_business_group_id
           and csd_pil.business_group_id = p_business_group_id;
  --
  l_bckt_csd_lf_evt_ocrd_dt date;
  l_bckt_csd_per_in_ler_id number;
  --
  -- Bug 5415 : Intermediate pil count should be between
  -- the life event occured date of pil which causes back out
  -- and the current reprocessing backed out pil.
  -- iREC : do not consider iRec, ABS, COMP, GSP pils.
  --
  cursor c_inter_pil_cnt(cv_bckt_csd_lf_evt_ocrd_dt date) is
    select pil.per_in_ler_id, pil.object_version_number
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.per_in_ler_id <> p_per_in_ler_id
    and    pil.per_in_ler_id <> p_bckdt_per_in_ler_id
    and    pil.person_id         = p_person_id
    and    pil.ler_id            = ler.ler_id
    and    p_effective_date between
           ler.effective_start_date and ler.effective_end_date
    and    ler.typ_cd not in ('IREC', 'SCHEDDU', 'COMP', 'GSP', 'ABS')
    and    pil.business_group_id = p_business_group_id
    and    nvl(pil.per_in_ler_stat_cd, 'XXXX') not in('BCKDT', 'VOIDD')
    and    pil.lf_evt_ocrd_dt > cv_bckt_csd_lf_evt_ocrd_dt
    and    pil.lf_evt_ocrd_dt < (select lf_evt_ocrd_dt
                                 from ben_per_in_ler
                                 where per_in_ler_id = p_bckdt_per_in_ler_id
                                   and business_group_id = p_business_group_id
                                )
    order by pil.lf_evt_ocrd_dt asc;
  --
  l_count number     := 0;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  p_inter_pil_cnt := 0;
  open c_bckt_csd_pil;
  fetch c_bckt_csd_pil into l_bckt_csd_lf_evt_ocrd_dt,l_bckt_csd_per_in_ler_id;
  close c_bckt_csd_pil;
  --
  p_bckt_csd_lf_evt_ocrd_dt := l_bckt_csd_lf_evt_ocrd_dt;
  p_bckt_csd_per_in_ler_id  := l_bckt_csd_per_in_ler_id;
  --
  g_bckt_csd_lf_evt_ocrd_dt := l_bckt_csd_lf_evt_ocrd_dt;
  --
  open  c_inter_pil_cnt(l_bckt_csd_lf_evt_ocrd_dt);
  fetch c_inter_pil_cnt into  p_inter_per_in_ler_id, p_inter_pil_ovn;
  if c_inter_pil_cnt%found then
     --
     -- Find are there more intervening PIL's.
     --
     p_inter_pil_cnt := 1;
     fetch c_inter_pil_cnt into  p_inter_per_in_ler_id, p_inter_pil_ovn;
     if c_inter_pil_cnt%found then
        p_inter_pil_cnt := p_inter_pil_cnt + 1;
     end if;
     --
  end if;
  --
  close c_inter_pil_cnt;
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
end get_inter_pil_cnt;
--
-- ----------------------------------------------------------------------------
-- |------------------------< ele_made_for_inter_pil >-------------------------|
-- ----------------------------------------------------------------------------
--
-- If elections were made for the backout per in ler then
-- return Y else N
--
function ele_made_for_inter_pil(
                        p_per_in_ler_id            in number,
                        p_bckdt_per_in_ler_id      in number,
                        p_person_id                in number,
                        p_business_group_id        in number,
                        p_effective_date           in date) return varchar2 is
  --
  l_proc                     varchar2(72) := g_package||'.ele_made_for_inter_pil';
  --
  -- To determine whether elections are made for intervening
  -- life events, if so stop the restore process.
  --

  l_prev_per_in_ler_id1 number;

  cursor c_ele_md_for_inter_pil is
    select 'Y'
    from   ben_prtt_enrt_rslt_f pen,
           ben_ler_f ler
    where  pen.per_in_ler_id not in (p_per_in_ler_id,p_bckdt_per_in_ler_id)
           /* Bug 8305552: Added 'not in (p_per_in_ler_id)'. Do not check elections for the current LifeEvent,because for Automatic enrollments
	    record will be present during validation of the cursor*/
    and    pen.person_id           = p_person_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    -- and    pen.enrt_cvg_thru_dt = hr_api.g_eot  BUG  4642657
    and    pen.effective_end_date = hr_api.g_eot
    and    pen.ler_id = ler.ler_id
    and    p_effective_date between ler.effective_start_date and
                                    ler.effective_end_date
    and    ler.typ_cd not in  ('IREC','SCHEDDU', 'COMP', 'GSP', 'ABS')
    /*Commented the below condition and added a new condition for Bug :8716679 */
    /*and    pen.effective_start_date >= (select decode(PRVS_STAT_CD, 'STRTD',STRTD_DT,
                                                                    'PROCD',PROCD_DT,LF_EVT_OCRD_DT)
                                       from ben_per_in_ler
                                       where per_in_ler_id = p_bckdt_per_in_ler_id
                                      ) */
    and  pen.per_in_ler_id= l_prev_per_in_ler_id1
    and rownum =  1 ;
  --

  cursor c_prev_pil(p_bckt_csd_lf_evt_ocrd_dt date,p_bckt_csd_per_in_ler_id number ) is
    select pil.per_in_ler_id
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.per_in_ler_id not in (p_per_in_ler_id,p_bckt_csd_per_in_ler_id)
    and    pil.person_id     = p_person_id
    and    pil.ler_id        = ler.ler_id
    and    p_effective_date between
           ler.effective_start_date and ler.effective_end_date
    and    ler.typ_cd not in ('IREC', 'SCHEDDU', 'COMP', 'GSP', 'ABS')
    and    pil.per_in_ler_stat_cd not in('BCKDT', 'VOIDD')
    and    pil.lf_evt_ocrd_dt in (select max(lf_evt_ocrd_dt)
                                 from ben_per_in_ler pil2
                                 where pil2.ler_id    = pil.ler_id
                                   and pil2.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
                                   and pil2.person_id = p_person_id
                                   and pil2.lf_evt_ocrd_dt < p_bckt_csd_lf_evt_ocrd_dt
                                );
  --
  l_count number     := 0;

 /* Added for Enhancement Bug :8716679 */

 l_int_pil_id number;
 /* Cursor to get the Intervening per_in_ler_id*/
 cursor c_int_pil_id is
  select bckt_per_in_ler_id
        from ben_per_in_ler pil
	where pil.per_in_ler_id = p_bckdt_per_in_ler_id;

/*Cursor to get the latest Intervening per_in_ler_id that has been processed*/
cursor c_prev_pil1 is
       select pil.per_in_ler_id
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.per_in_ler_id not in (p_per_in_ler_id,p_bckdt_per_in_ler_id)
    and    pil.person_id     = p_person_id
    and    pil.ler_id        = ler.ler_id
    and    p_effective_date between
           ler.effective_start_date and ler.effective_end_date
    and    ler.typ_cd not in ('IREC', 'SCHEDDU', 'COMP', 'GSP', 'ABS')
    and    pil.per_in_ler_stat_cd not in('BCKDT', 'VOIDD')
    and    pil.lf_evt_ocrd_dt in (select lf_evt_ocrd_dt
				 from ben_per_in_ler pil2,
				      ben_ler_f ler1
				 where pil2.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
				    and pil2.person_id = p_person_id
				    and    pil2.ler_id        = ler1.ler_id
				    and    p_effective_date between
					   ler1.effective_start_date and ler1.effective_end_date
				    and    ler1.typ_cd not in ('IREC', 'SCHEDDU', 'COMP', 'GSP', 'ABS')
				    and pil2.lf_evt_ocrd_dt > (select lf_evt_ocrd_dt from ben_per_in_ler pil3 where
							      per_in_ler_id = l_int_pil_id)
				    and pil2.lf_evt_ocrd_dt < (select lf_evt_ocrd_dt from ben_per_in_ler pil3 where
							      per_in_ler_id = p_bckdt_per_in_ler_id)
                                )
   order by pil.lf_evt_ocrd_dt desc;
  /* End of Enhancement Bug :8716679 */

  l_enrt_rslt_exists varchar2(1) := 'N';
  l_inter_pil_ovn            number;
  l_inter_pil_cnt            number := 0;
  l_inter_per_in_ler_id      number;
  l_prev_per_in_ler_id       number;
  l_inter_pil_le_dt          date;
  l_bckt_csd_lf_evt_ocrd_dt  date;
  l_bckt_csd_per_in_ler_id   number;
  --
  l_differ                   varchar2(30) := 'N';
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  --First Get the intervening life event count
  --

   /* Added for Enhancement Bug :8716679 */
  open c_int_pil_id;
  fetch c_int_pil_id into l_int_pil_id;
  close c_int_pil_id;
  hr_utility.set_location ('l_int_pil_id '||l_int_pil_id,10);

  open c_prev_pil1;
  fetch c_prev_pil1 into l_prev_per_in_ler_id1;
  if(c_prev_pil1%notfound) then
    hr_utility.set_location ('cursor notfound ',10);
    l_prev_per_in_ler_id1 := l_int_pil_id;
    close c_prev_pil1;
  else
     close c_prev_pil1;
  end if;
  hr_utility.set_location ('l_prev_per_in_ler_id1 '||l_prev_per_in_ler_id1,10);
  /* End of Enhancement Bug :8716679 */

  open  c_ele_md_for_inter_pil;
  fetch c_ele_md_for_inter_pil into  l_enrt_rslt_exists;
  close c_ele_md_for_inter_pil;
  --
  if l_enrt_rslt_exists = 'Y' then
    --
    get_inter_pil_cnt ( p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id,
                      p_per_in_ler_id            => p_per_in_ler_id,
                      p_person_id                => p_person_id,
                      p_business_group_id        => p_business_group_id,
                      p_bckt_csd_lf_evt_ocrd_dt  => l_bckt_csd_lf_evt_ocrd_dt,
                      p_bckt_csd_per_in_ler_id   => l_bckt_csd_per_in_ler_id,
                      p_inter_per_in_ler_id      => l_inter_per_in_ler_id,
                      p_inter_pil_ovn            => l_inter_pil_ovn,
                      p_inter_pil_cnt            => l_inter_pil_cnt,
                      p_inter_pil_le_dt          => l_inter_pil_le_dt,
                      p_effective_date           => p_effective_date);
    --
    hr_utility.set_location ('l_inter_pil_cnt '||l_inter_pil_cnt,199);
    hr_utility.set_location ('l_inter_pil_le_dt '||l_inter_pil_le_dt,199);
    hr_utility.set_location ('l_inter_per_in_ler_id '||l_inter_per_in_ler_id,199);
    hr_utility.set_location ('l_bckt_csd_lf_evt_ocrd_dt '||l_bckt_csd_lf_evt_ocrd_dt,199);
    hr_utility.set_location ('l_bckt_csd_per_in_ler_id '||l_bckt_csd_per_in_ler_id,199);
    --
    if l_inter_pil_cnt = 0 then
      --
      --Get the previous life event
      open c_prev_pil(l_bckt_csd_lf_evt_ocrd_dt,l_bckt_csd_per_in_ler_id);
      fetch c_prev_pil into l_prev_per_in_ler_id ;
      close c_prev_pil;
      --
      if l_prev_per_in_ler_id is not null then
        --
        hr_utility.set_location ('l_prev_per_in_ler_id '||l_prev_per_in_ler_id,199);
        --
        l_differ := comp_prev_new_pen(p_person_id         => p_person_id
                                     ,p_business_group_id => p_business_group_id
                                     ,p_effective_date    => p_effective_date
                                     ,p_new_per_in_ler_id => l_bckt_csd_per_in_ler_id
                                     ,p_prev_per_in_ler_id=> l_prev_per_in_ler_id);
        --
        hr_utility.set_location (' l_differ '||l_differ,199);
        if l_differ = 'N' then
          --
          l_enrt_rslt_exists := 'N';
          --
        else
          --
          l_enrt_rslt_exists := 'Y';
          --
        end if;
        --
      else
        --There was no previous enrollment when the backedout life event was processed bt
        --there is a life event exists. Donot reinstate
        --If there is no life event which backed out the life event then reset
        --l_enrt_rslt_exists to N
        --
        if l_bckt_csd_per_in_ler_id is NULL then
          l_enrt_rslt_exists := 'N';
        else
          l_enrt_rslt_exists := 'Y';
        end if;
        --
      end if ;
      --
    elsif l_inter_pil_cnt = 1 then
      --More than one intevening life events.
      --Dont reinstare
      l_differ := comp_prev_new_pen(p_person_id           => p_person_id
                                   ,p_business_group_id => p_business_group_id
                                   ,p_effective_date    => p_effective_date
                                   ,p_new_per_in_ler_id => l_inter_per_in_ler_id
                                   ,p_prev_per_in_ler_id=> l_bckt_csd_per_in_ler_id );
      --
      hr_utility.set_location (' l_differ '||l_differ,299);
      if l_differ = 'N' then
        --
        l_enrt_rslt_exists := 'N';
        --
      else
        --
        l_enrt_rslt_exists := 'Y';
        --
      end if;
      --
    else
      --Sorry.. You can't get it reinstated.. there are more than two intervening life events.
      l_enrt_rslt_exists := 'Y';
      --
    end if;
  --
  else
    --
    l_enrt_rslt_exists := 'N';
    --
  end if;
  --
  hr_utility.set_location ('Leaving l_enrt_rslt_exists '||l_enrt_rslt_exists,199);
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
  return l_enrt_rslt_exists;
  --
end ele_made_for_inter_pil;
--
-- ----------------------------------------------------------------------------
-- |------------------------< comp_ori_new_egd >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure compares the original and new
-- elig dependents for a electble choice and per in ler id.
--
function comp_ori_new_egd(p_person_id               in number
                          ,p_business_group_id      in number
                          ,p_effective_date         in date
                          ,p_per_in_ler_id          in number
                          ,p_bckdt_per_in_ler_id    in number
                          ,p_curr_epe_id            in number
                          ,p_bckdt_epe_id           in number
                          ) return varchar2 is
  --
  l_proc                    varchar2(72) := g_package||'.comp_ori_new_egd';
  --
  l_differ                  varchar2(1) := 'N';
  --
  cursor c_bckdt_epe_egd is
    select epe_egd.*
    from   ben_elig_dpnt epe_egd
    where epe_egd.elig_per_elctbl_chc_id = p_bckdt_epe_id
    and   epe_egd.business_group_id  = p_business_group_id
    and   epe_egd.per_in_ler_id      = p_bckdt_per_in_ler_id;
  --
  cursor c_curr_epe_egd is
    select epe_egd.*
    from   ben_elig_dpnt epe_egd
    where epe_egd.elig_per_elctbl_chc_id = p_curr_epe_id
    and   epe_egd.business_group_id  = p_business_group_id
    and   epe_egd.per_in_ler_id      = p_per_in_ler_id;
  --
  TYPE l_bckdt_epe_egd_rec is TABLE OF c_bckdt_epe_egd%rowtype
       INDEX BY BINARY_INTEGER;
  --
  TYPE l_curr_epe_egd_rec is TABLE OF c_curr_epe_egd%rowtype
       INDEX BY BINARY_INTEGER;
  --
  l_bckdt_epe_egd_table  l_bckdt_epe_egd_rec;
  l_curr_epe_egd_table   l_curr_epe_egd_rec;
  l_next_row             binary_integer;
  l_found                boolean;
  l_bckdt_epe_egd_count  number;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  select count(*) into l_bckdt_epe_egd_count
    from   ben_elig_dpnt epe_egd
    where epe_egd.elig_per_elctbl_chc_id = p_bckdt_epe_id
    and   epe_egd.business_group_id  = p_business_group_id
    and   epe_egd.per_in_ler_id      = p_bckdt_per_in_ler_id;
  --
  l_curr_epe_egd_table.delete;
  l_next_row := nvl(l_curr_epe_egd_table.LAST, 0) + 1;
  for  curr_epe_egd_rec in c_curr_epe_egd
  loop
     --
     l_curr_epe_egd_table(l_next_row)   := curr_epe_egd_rec;
     l_next_row := l_next_row + 1;
     --
  end loop;
  --
  --
  -- Check Number of records in both tables for difference
  --
  if nvl(l_curr_epe_egd_table.last, 0) = 0  and
     nvl(l_bckdt_epe_egd_count,0)  = 0
  then
       --
       l_differ := 'N';
       hr_utility.set_location ('Leaving : N : 0 '||l_proc,10);
       return l_differ;
       --
  elsif nvl(l_curr_epe_egd_table.last, 0) <> nvl(l_bckdt_epe_egd_count,0) then
       --
       l_differ := 'Y';
       hr_utility.set_location ('Leaving : Y : <>0 '||l_proc,10);
       hr_utility.set_location ('Leaving : Y : ' || nvl(l_curr_epe_egd_table.last, 0)
                                || '  ' || nvl(l_bckdt_epe_egd_count,0) || '  ' ||
                                l_proc,10);
       return l_differ;
       --
  end if;
  --
  -- Now compare the original epe_egd record and new epe_egd record
  -- for each epe record.
  --
  for bckdt_epe_egd_rec in c_bckdt_epe_egd
  loop
    --
    l_found  := FALSE;
    --
    for  l_curr_count in l_curr_epe_egd_table.first..l_curr_epe_egd_table.last
    loop
       /* -- Columns to compare

          DPNT_INELIG_FLAG
          DPNT_PERSON_ID
          INELG_RSN_CD
          ELIG_STRT_DT
          ELIG_THRU_DT
          --
          -- Do we need to compare the following columns.
          --
          OVRDN_THRU_DT
          OVRDN_FLAG
          CREATE_DT
          ELIG_PER_ID
          ELIG_PER_OPT_ID
          ELIG_CVRD_DPNT_ID
      */
      --
      if nvl(bckdt_epe_egd_rec.DPNT_INELIG_FLAG, '$') =
                   nvl(l_curr_epe_egd_table(l_curr_count).DPNT_INELIG_FLAG, '$') and
         nvl(bckdt_epe_egd_rec.INELG_RSN_CD, '$') =
                   nvl(l_curr_epe_egd_table(l_curr_count).INELG_RSN_CD, '$') and
         nvl(bckdt_epe_egd_rec.ELIG_STRT_DT, hr_api.g_eot) =
            nvl(l_curr_epe_egd_table(l_curr_count).ELIG_STRT_DT, hr_api.g_eot) and
         nvl(bckdt_epe_egd_rec.ELIG_THRU_DT, hr_api.g_eot) =
            nvl(l_curr_epe_egd_table(l_curr_count).ELIG_THRU_DT, hr_api.g_eot) and
         nvl(bckdt_epe_egd_rec.DPNT_PERSON_ID, -1) =
                   nvl(l_curr_epe_egd_table(l_curr_count).DPNT_PERSON_ID, -1)
      then
        l_found   := TRUE;
        exit;
      end if;
      --
    end loop;
    --
    if l_found   = FALSE then
       --
       -- Current epe for a given backed out epe is not found
       --
       l_differ := 'Y';
       exit;
    end if;
  --
  end loop;
  --
  hr_utility.set_location('Leaving: ' || l_differ || l_proc, 10);
  --
  return l_differ;
  --
end comp_ori_new_egd;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< comp_ori_new_enb_ecr >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure compares the original and new enrollment benefit
-- for comparable electble choice and per in ler id.
--
function comp_ori_new_enb_ecr(p_person_id               in number
                          ,p_business_group_id      in number
                          ,p_effective_date         in date
                          ,p_per_in_ler_id          in number
                          ,p_bckdt_per_in_ler_id    in number
                          ,p_curr_enb_id            in number
                          ,p_bckdt_enb_id           in number
                          ) return varchar2 is
  --
  l_proc                    varchar2(72) := g_package||'.comp_ori_new_enb_ecr';
  --
  l_differ                  varchar2(1) := 'N';
  --
  cursor c_bckdt_enb_ecr is
    select enb_ecr.*
    from   ben_enrt_rt enb_ecr
    where enb_ecr.enrt_bnft_id = p_bckdt_enb_id
    and   enb_ecr.business_group_id  = p_business_group_id
    and   enb_ecr.elig_per_elctbl_chc_id is null;
  --
  cursor c_curr_enb_ecr is
    select enb_ecr.*
    from   ben_enrt_rt enb_ecr
    where enb_ecr.enrt_bnft_id = p_curr_enb_id
    and   enb_ecr.business_group_id  = p_business_group_id
    and   enb_ecr.elig_per_elctbl_chc_id is null;
  --
  TYPE l_bckdt_enb_ecr_rec is TABLE OF c_bckdt_enb_ecr%rowtype
       INDEX BY BINARY_INTEGER;
  --
  TYPE l_curr_enb_ecr_rec is TABLE OF c_curr_enb_ecr%rowtype
       INDEX BY BINARY_INTEGER;
  --
  l_bckdt_enb_ecr_table l_bckdt_enb_ecr_rec;
  l_curr_enb_ecr_table  l_curr_enb_ecr_rec;
  l_next_row            binary_integer;
  l_found               boolean;
  l_bckdt_enb_ecr_count number;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  select count(*) into l_bckdt_enb_ecr_count
    from   ben_enrt_rt enb_ecr
    where enb_ecr.enrt_bnft_id = p_bckdt_enb_id
    and   enb_ecr.business_group_id  = p_business_group_id
    and   enb_ecr.elig_per_elctbl_chc_id is null;
  --
  l_curr_enb_ecr_table.delete;
  l_next_row := nvl(l_curr_enb_ecr_table.LAST, 0) + 1;
  for  curr_enb_ecr_rec in c_curr_enb_ecr
  loop
     --
     l_curr_enb_ecr_table(l_next_row)   := curr_enb_ecr_rec;
     l_next_row := l_next_row + 1;
     --
  end loop;
  --
  -- Check Number of records in both tables for difference
  --
  if nvl(l_curr_enb_ecr_table.last, 0) = 0  and
     nvl(l_bckdt_enb_ecr_count,0)  = 0
  then
       --
       l_differ := 'N';
       hr_utility.set_location ('Leavingi : N : 0 '||l_proc,10);
       return l_differ;
       --
  elsif nvl(l_curr_enb_ecr_table.last, 0) <> nvl(l_bckdt_enb_ecr_count,0) then
       --
       l_differ := 'Y';
       hr_utility.set_location ('Leavingi : Y : <>0 '||l_proc,10);
       return l_differ;
       --
  end if;
  --
  -- Now compare the original enb_ecr record and new enb_ecr record for each
  -- epe record.
  --
  -- for  l_count in l_bckdt_enb_ecr_table.first..l_bckdt_enb_ecr_table.last loop
  for bckdt_enb_ecr_rec in c_bckdt_enb_ecr
  loop
    --
    l_found  := FALSE;
    --
    for  l_curr_count in l_curr_enb_ecr_table.first..l_curr_enb_ecr_table.last
    loop
      --
      if nvl(bckdt_enb_ecr_rec.ACTY_TYP_CD, '$') =
                   nvl(l_curr_enb_ecr_table(l_curr_count).ACTY_TYP_CD, '$') and
         nvl(bckdt_enb_ecr_rec.TX_TYP_CD, '$') =
                   nvl(l_curr_enb_ecr_table(l_curr_count).TX_TYP_CD, '$') and
         nvl(bckdt_enb_ecr_rec.CTFN_RQD_FLAG, '$') =
                   nvl(l_curr_enb_ecr_table(l_curr_count).CTFN_RQD_FLAG, '$') and
         nvl(bckdt_enb_ecr_rec.DFLT_FLAG, '$') =
                   nvl(l_curr_enb_ecr_table(l_curr_count).DFLT_FLAG, '$') and
         nvl(bckdt_enb_ecr_rec.DFLT_VAL, -1) =
                   nvl(l_curr_enb_ecr_table(l_curr_count).DFLT_VAL, -1) and
         nvl(bckdt_enb_ecr_rec.ANN_VAL, -1) =
                   nvl(l_curr_enb_ecr_table(l_curr_count).ANN_VAL, -1) and
         nvl(bckdt_enb_ecr_rec.ANN_MN_ELCN_VAL, -1) =
                   nvl(l_curr_enb_ecr_table(l_curr_count).ANN_MN_ELCN_VAL, -1) and
         nvl(bckdt_enb_ecr_rec.ANN_MX_ELCN_VAL, -1) =
                   nvl(l_curr_enb_ecr_table(l_curr_count).ANN_MX_ELCN_VAL, -1) and
         nvl(bckdt_enb_ecr_rec.MX_ELCN_VAL, -1) =
                   nvl(l_curr_enb_ecr_table(l_curr_count).MX_ELCN_VAL, -1) and
         nvl(bckdt_enb_ecr_rec.MN_ELCN_VAL, -1) =
                   nvl(l_curr_enb_ecr_table(l_curr_count).MN_ELCN_VAL, -1) and
         nvl(bckdt_enb_ecr_rec.INCRMT_ELCN_VAL, -1) =
                   nvl(l_curr_enb_ecr_table(l_curr_count).INCRMT_ELCN_VAL, -1) and
         nvl(bckdt_enb_ecr_rec.RT_STRT_DT, hr_api.g_eot) =
            nvl(l_curr_enb_ecr_table(l_curr_count).RT_STRT_DT, hr_api.g_eot) and
         nvl(bckdt_enb_ecr_rec.RT_STRT_DT_CD, '$') =
                   nvl(l_curr_enb_ecr_table(l_curr_count).RT_STRT_DT_CD, '$') and
         nvl(bckdt_enb_ecr_rec.RT_STRT_DT_RL, -1) =
                   nvl(l_curr_enb_ecr_table(l_curr_count).RT_STRT_DT_RL, -1) and
         nvl(bckdt_enb_ecr_rec.ACTY_BASE_RT_ID, -1) =
                   nvl(l_curr_enb_ecr_table(l_curr_count).ACTY_BASE_RT_ID, -1) and
         nvl(bckdt_enb_ecr_rec.DECR_BNFT_PRVDR_POOL_ID, -1) =
            nvl(l_curr_enb_ecr_table(l_curr_count).DECR_BNFT_PRVDR_POOL_ID, -1) and
         nvl(bckdt_enb_ecr_rec.CVG_AMT_CALC_MTHD_ID, -1) =
            nvl(l_curr_enb_ecr_table(l_curr_count).CVG_AMT_CALC_MTHD_ID, -1) and
         nvl(bckdt_enb_ecr_rec.ACTL_PREM_ID, -1) =
                   nvl(l_curr_enb_ecr_table(l_curr_count).ACTL_PREM_ID, -1) and
         nvl(bckdt_enb_ecr_rec.COMP_LVL_FCTR_ID, -1) =
                   nvl(l_curr_enb_ecr_table(l_curr_count).COMP_LVL_FCTR_ID, -1)
      then
        l_found   := TRUE;
        exit;
      end if;
      --
    end loop;
    --
    if l_found   = FALSE then
       --
       -- Current epe for a given backed out epe is not found
       --
       l_differ := 'Y';
       exit;
    end if;
  --
  end loop;
  --
  hr_utility.set_location('Leaving:' || l_differ || l_proc, 10);
  --
  return l_differ;
  --
end comp_ori_new_enb_ecr;
--
-- ----------------------------------------------------------------------------
-- |------------------------< comp_ori_new_epe_ecr >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure compares the original and new enrollment benefit
-- for comparable electble choice and per in ler id.
--
function comp_ori_new_epe_ecr(p_person_id               in number
                          ,p_business_group_id      in number
                          ,p_effective_date         in date
                          ,p_per_in_ler_id          in number
                          ,p_bckdt_per_in_ler_id    in number
                          ,p_curr_epe_id            in number
                          ,p_bckdt_epe_id           in number
                          ) return varchar2 is
  --
  l_proc                    varchar2(72) := g_package||'.comp_ori_new_epe_ecr';
  --
  l_differ                  varchar2(1) := 'N';
  --
  cursor c_bckdt_epe_ecr is
    select epe_ecr.*
    from   ben_enrt_rt epe_ecr
    where epe_ecr.elig_per_elctbl_chc_id = p_bckdt_epe_id
    and   epe_ecr.business_group_id  = p_business_group_id
    and   epe_ecr.enrt_bnft_id is null;
  --
  cursor c_curr_epe_ecr is
    select epe_ecr.*
    from   ben_enrt_rt epe_ecr
    where epe_ecr.elig_per_elctbl_chc_id = p_curr_epe_id
    and   epe_ecr.business_group_id  = p_business_group_id
    and   epe_ecr.enrt_bnft_id is null;
  --
  TYPE l_bckdt_epe_ecr_rec is TABLE OF c_bckdt_epe_ecr%rowtype
       INDEX BY BINARY_INTEGER;
  --
  TYPE l_curr_epe_ecr_rec is TABLE OF c_curr_epe_ecr%rowtype
       INDEX BY BINARY_INTEGER;
  --
  l_bckdt_epe_ecr_table  l_bckdt_epe_ecr_rec;
  l_curr_epe_ecr_table   l_curr_epe_ecr_rec;
  l_next_row             binary_integer;
  l_found                boolean;
  l_bckdt_epe_ecr_count  number;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  select count(*) into l_bckdt_epe_ecr_count
    from   ben_enrt_rt epe_ecr
    where epe_ecr.elig_per_elctbl_chc_id = p_bckdt_epe_id
    and   epe_ecr.business_group_id  = p_business_group_id
    and   epe_ecr.enrt_bnft_id is null;

  /* l_bckdt_epe_ecr_table.delete;
  l_next_row := nvl(l_bckdt_epe_ecr_table.LAST, 0) + 1;
  --
  for bckdt_epe_ecr_rec in c_bckdt_epe_ecr
  loop
     --
     l_bckdt_epe_ecr_table(l_next_row)   := bckdt_epe_ecr_rec;
     l_next_row := l_next_row + 1;
     --
  end loop; */
  --
  l_curr_epe_ecr_table.delete;
  l_next_row := nvl(l_curr_epe_ecr_table.LAST, 0) + 1;
  for  curr_epe_ecr_rec in c_curr_epe_ecr
  loop
     --
     l_curr_epe_ecr_table(l_next_row)   := curr_epe_ecr_rec;
     l_next_row := l_next_row + 1;
     --
  end loop;
  --
  --
  -- Check Number of records in both tables for difference
  --
  if nvl(l_curr_epe_ecr_table.last, 0) = 0  and
     nvl(l_bckdt_epe_ecr_count,0)  = 0
  then
       --
       l_differ := 'N';
       hr_utility.set_location ('Leavingi : N : 0 '||l_proc,10);
       return l_differ;
       --
  elsif nvl(l_curr_epe_ecr_table.last, 0) <> nvl(l_bckdt_epe_ecr_count,0) then
       --
       l_differ := 'Y';
       hr_utility.set_location ('Leavingi : Y : <>0 '||l_proc,10);
       return l_differ;
       --
  end if;
  --
  -- Now compare the original epe_ecr record and new epe_ecr record for each epe
  --  record.
  --
  -- for  l_count in l_bckdt_epe_ecr_table.first..l_bckdt_epe_ecr_table.last loop
  for bckdt_epe_ecr_rec in c_bckdt_epe_ecr
  loop
    --
    l_found  := FALSE;
    --
    for  l_curr_count in l_curr_epe_ecr_table.first..l_curr_epe_ecr_table.last
    loop
      --
      if nvl(bckdt_epe_ecr_rec.ACTY_TYP_CD, '$') =
                   nvl(l_curr_epe_ecr_table(l_curr_count).ACTY_TYP_CD, '$') and
         nvl(bckdt_epe_ecr_rec.TX_TYP_CD, '$') =
                   nvl(l_curr_epe_ecr_table(l_curr_count).TX_TYP_CD, '$') and
         nvl(bckdt_epe_ecr_rec.CTFN_RQD_FLAG, '$') =
                   nvl(l_curr_epe_ecr_table(l_curr_count).CTFN_RQD_FLAG, '$') and
         nvl(bckdt_epe_ecr_rec.DFLT_FLAG, '$') =
                   nvl(l_curr_epe_ecr_table(l_curr_count).DFLT_FLAG, '$') and
         nvl(bckdt_epe_ecr_rec.DFLT_VAL, -1) =
                   nvl(l_curr_epe_ecr_table(l_curr_count).DFLT_VAL, -1) and
         nvl(bckdt_epe_ecr_rec.ANN_VAL, -1) =
                   nvl(l_curr_epe_ecr_table(l_curr_count).ANN_VAL, -1) and
         nvl(bckdt_epe_ecr_rec.ANN_MN_ELCN_VAL, -1) =
                   nvl(l_curr_epe_ecr_table(l_curr_count).ANN_MN_ELCN_VAL, -1) and
         nvl(bckdt_epe_ecr_rec.ANN_MX_ELCN_VAL, -1) =
                   nvl(l_curr_epe_ecr_table(l_curr_count).ANN_MX_ELCN_VAL, -1) and
         nvl(bckdt_epe_ecr_rec.MX_ELCN_VAL, -1) =
                   nvl(l_curr_epe_ecr_table(l_curr_count).MX_ELCN_VAL, -1) and
         nvl(bckdt_epe_ecr_rec.MN_ELCN_VAL, -1) =
                   nvl(l_curr_epe_ecr_table(l_curr_count).MN_ELCN_VAL, -1) and
         nvl(bckdt_epe_ecr_rec.INCRMT_ELCN_VAL, -1) =
                   nvl(l_curr_epe_ecr_table(l_curr_count).INCRMT_ELCN_VAL, -1) and
         nvl(bckdt_epe_ecr_rec.RT_STRT_DT, hr_api.g_eot) =
            nvl(l_curr_epe_ecr_table(l_curr_count).RT_STRT_DT, hr_api.g_eot) and
         nvl(bckdt_epe_ecr_rec.RT_STRT_DT_CD, '$') =
                   nvl(l_curr_epe_ecr_table(l_curr_count).RT_STRT_DT_CD, '$') and
         nvl(bckdt_epe_ecr_rec.RT_STRT_DT_RL, -1) =
                   nvl(l_curr_epe_ecr_table(l_curr_count).RT_STRT_DT_RL, -1) and
         nvl(bckdt_epe_ecr_rec.ACTY_BASE_RT_ID, -1) =
                   nvl(l_curr_epe_ecr_table(l_curr_count).ACTY_BASE_RT_ID, -1) and
         nvl(bckdt_epe_ecr_rec.DECR_BNFT_PRVDR_POOL_ID, -1) =
            nvl(l_curr_epe_ecr_table(l_curr_count).DECR_BNFT_PRVDR_POOL_ID, -1) and
         nvl(bckdt_epe_ecr_rec.CVG_AMT_CALC_MTHD_ID, -1) =
            nvl(l_curr_epe_ecr_table(l_curr_count).CVG_AMT_CALC_MTHD_ID, -1) and
         nvl(bckdt_epe_ecr_rec.ACTL_PREM_ID, -1) =
                   nvl(l_curr_epe_ecr_table(l_curr_count).ACTL_PREM_ID, -1) and
         nvl(bckdt_epe_ecr_rec.COMP_LVL_FCTR_ID, -1) =
                   nvl(l_curr_epe_ecr_table(l_curr_count).COMP_LVL_FCTR_ID, -1)
      then
        l_found   := TRUE;
        exit;
      end if;
      --
    end loop;
    --
    if l_found   = FALSE then
       --
       -- Current epe for a given backed out epe is not found
       --
       l_differ := 'Y';
       exit;
    end if;
  --
  end loop;
  --
  hr_utility.set_location('Leaving:'||l_differ ||  l_proc, 10);
  --
  return l_differ;
  --
end comp_ori_new_epe_ecr;
--
-- ----------------------------------------------------------------------------
-- |------------------------< comp_ori_new_enb >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure compares the original and new enrollment benefit
-- for comparable electble choice and per in ler id.
--
function comp_ori_new_enb(p_person_id               in number
                          ,p_business_group_id      in number
                          ,p_effective_date         in date
                          ,p_per_in_ler_id          in number
                          ,p_bckdt_per_in_ler_id    in number
                          ,p_curr_epe_id            in number
                          ,p_bckdt_epe_id           in number
                          ) return varchar2 is
  --
  l_proc                    varchar2(72) := g_package||'.comp_ori_new_enb';
  --
  l_differ                  varchar2(1) := 'N';
  l_enb_ecr_differ          varchar2(1) := 'N';
  --
  cursor c_bckdt_enb is
    select enb.dflt_flag
          ,enb.bndry_perd_cd
          ,enb.val
          ,enb.bnft_typ_cd
          ,enb.mn_val
          ,enb.mx_val
          ,enb.incrmt_val
          ,enb.rt_typ_cd
          ,enb.cvg_mlt_cd
          ,enb.ctfn_rqd_flag
          ,enb.ordr_num
          ,enb.dflt_val
          ,enb.comp_lvl_fctr_id
          ,enb.enrt_bnft_id
    from   ben_enrt_bnft enb
    where enb.elig_per_elctbl_chc_id = p_bckdt_epe_id ;
  --
  cursor c_curr_enb is
    select enb.dflt_flag
          ,enb.bndry_perd_cd
          ,enb.val
          ,enb.bnft_typ_cd
          ,enb.mn_val
          ,enb.mx_val
          ,enb.incrmt_val
          ,enb.rt_typ_cd
          ,enb.cvg_mlt_cd
          ,enb.ctfn_rqd_flag
          ,enb.ordr_num
          ,enb.dflt_val
          ,enb.comp_lvl_fctr_id
          ,enb.enrt_bnft_id
    from   ben_enrt_bnft enb
    where enb.elig_per_elctbl_chc_id = p_curr_epe_id ;
  --
  TYPE l_bckdt_enb_rec is TABLE OF c_bckdt_enb%rowtype
       INDEX BY BINARY_INTEGER;
  --
  TYPE l_curr_enb_rec is TABLE OF c_curr_enb%rowtype
       INDEX BY BINARY_INTEGER;
  --
  l_bckdt_enb_table l_bckdt_enb_rec;
  l_curr_enb_table  l_curr_enb_rec;
  l_next_row        binary_integer;
  l_found           boolean;
  l_bckdt_enb_count number;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  select count(*) into l_bckdt_enb_count
    from   ben_enrt_bnft enb
    where enb.elig_per_elctbl_chc_id = p_bckdt_epe_id
    and   enb.business_group_id  = p_business_group_id;
/*
  l_bckdt_enb_table.delete;
  l_next_row := nvl(l_bckdt_enb_table.LAST, 0) + 1;
  --
  for bckdt_enb_rec in c_bckdt_enb
  loop
     --
     --
     l_bckdt_enb_table(l_next_row)   := bckdt_enb_rec;
     l_next_row := l_next_row + 1;
     --
  end loop;
*/
  --
  l_curr_enb_table.delete;
  l_next_row := nvl(l_curr_enb_table.LAST, 0) + 1;
  for  curr_enb_rec in c_curr_enb
  loop
     --
     l_curr_enb_table(l_next_row)   := curr_enb_rec;
     l_next_row := l_next_row + 1;
     --
  end loop;
  --
  -- Check Number of records in both tables differ
  --
  if nvl(l_curr_enb_table.last, 0) = 0  and
     nvl(l_bckdt_enb_count,0)  = 0
  then
       --
       l_differ := 'N';

       hr_utility.set_location('Leaving:  ' || l_differ ||' 0 '|| l_proc, 10);
       return l_differ;
       --
  elsif nvl(l_curr_enb_table.last, 0) <> nvl(l_bckdt_enb_count,0) then
       --
       l_differ := 'Y';

       hr_utility.set_location('Leaving:  ' || l_differ ||' <>0 '|| l_proc, 10);
       return l_differ;
       --
  end if;
  --
  --
  -- Now compare the original enb record and new enb record for each epe record.
  --
  -- for  l_count in l_bckdt_enb_table.first..l_bckdt_enb_table.last loop
  for bckdt_enb_rec in c_bckdt_enb
  loop
    --
    l_found  := FALSE;
    --
    for  l_curr_count in l_curr_enb_table.first..l_curr_enb_table.last loop
      --
      if nvl(bckdt_enb_rec.dflt_flag, '$') =
                   nvl(l_curr_enb_table(l_curr_count).dflt_flag, '$') and
         nvl(bckdt_enb_rec.bndry_perd_cd, '$') =
                   nvl(l_curr_enb_table(l_curr_count).bndry_perd_cd, '$') and
         nvl(bckdt_enb_rec.val, -1) =
                   nvl(l_curr_enb_table(l_curr_count).val, -1) and
         nvl(bckdt_enb_rec.bnft_typ_cd, '$') =
                   nvl(l_curr_enb_table(l_curr_count).bnft_typ_cd, '$') and
         nvl(bckdt_enb_rec.mn_val, -1) =
                   nvl(l_curr_enb_table(l_curr_count).mn_val, -1) and
         nvl(bckdt_enb_rec.mx_val, -1) =
                   nvl(l_curr_enb_table(l_curr_count).mx_val, -1) and
         nvl(bckdt_enb_rec.incrmt_val, -1) =
                   nvl(l_curr_enb_table(l_curr_count).incrmt_val, -1) and
         nvl(bckdt_enb_rec.rt_typ_cd, '$') =
                   nvl(l_curr_enb_table(l_curr_count).rt_typ_cd, '$') and
         nvl(bckdt_enb_rec.cvg_mlt_cd, '$') =
                   nvl(l_curr_enb_table(l_curr_count).cvg_mlt_cd, '$') and
         nvl(bckdt_enb_rec.cvg_mlt_cd, '$') =
                   nvl(l_curr_enb_table(l_curr_count).cvg_mlt_cd, '$') and
         nvl(bckdt_enb_rec.ctfn_rqd_flag, '$') =
                   nvl(l_curr_enb_table(l_curr_count).ctfn_rqd_flag, '$') and
         nvl(bckdt_enb_rec.ordr_num, -1) =
                   nvl(l_curr_enb_table(l_curr_count).ordr_num, -1) and
         nvl(bckdt_enb_rec.dflt_val, -1) =
                   nvl(l_curr_enb_table(l_curr_count).dflt_val, -1) and
         nvl(bckdt_enb_rec.comp_lvl_fctr_id, -1) =
                   nvl(l_curr_enb_table(l_curr_count).comp_lvl_fctr_id, -1)
      then
        --
        l_enb_ecr_differ := comp_ori_new_enb_ecr(
           p_person_id              => p_person_id
           ,p_business_group_id     => p_business_group_id
           ,p_effective_date        => p_effective_date
           ,p_per_in_ler_id         => p_per_in_ler_id
           ,p_bckdt_per_in_ler_id   => p_bckdt_per_in_ler_id
           ,p_curr_enb_id           => l_curr_enb_table(l_curr_count).enrt_bnft_id
           ,p_bckdt_enb_id          => bckdt_enb_rec.enrt_bnft_id
           );
        --
        if l_enb_ecr_differ = 'Y' then
           --
           -- even though epe, ecd, enb are same there may be differences
           -- in enrt_rt
           --
           l_found   := FALSE;
           --
        else
           --
           l_found   := TRUE;
           --
        end if;
        exit;
      end if;
      --
    end loop;
    --
    if l_found   = FALSE then
       --
       -- Current epe for a given backed out epe is not found
       --
       l_differ := 'Y';
       exit;
    end if;
  --
  end loop;
  --

  hr_utility.set_location('Leaving:' || l_differ || l_proc, 10);
  --
  return l_differ;
  --
end comp_ori_new_enb;
--
-- ----------------------------------------------------------------------------
-- |------------------------< comp_ori_new_ecd >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure compares the original and new elig covered dependents
-- for comparable electble choice and per in ler id.
--
function comp_ori_new_ecd(p_person_id               in number
                          ,p_business_group_id      in number
                          ,p_effective_date         in date
                          ,p_per_in_ler_id          in number
                          ,p_bckdt_per_in_ler_id    in number
                          ,p_curr_epe_id            in number
                          ,p_bckdt_epe_id           in number
                          ) return varchar2 is
  --
  l_proc                    varchar2(72) := g_package||'.comp_ori_new_ecd';
  --
  l_differ                  varchar2(1) := 'N';
  --
  cursor c_bckdt_ecd is
    select ecd.effective_start_date
          ,ecd.effective_end_date
          ,ecd.cvg_strt_dt
          ,ecd.cvg_thru_dt
          ,ecd.cvg_pndg_flag
          ,ecd.ovrdn_flag
          ,ecd.ovrdn_thru_dt
          ,ecd.dpnt_person_id
    from   ben_elig_cvrd_dpnt_f ecd,
           ben_per_in_ler pil
    where  ecd.business_group_id=p_business_group_id
    and p_effective_date between
        ecd.effective_start_date and ecd.effective_end_date
    and pil.per_in_ler_id=ecd.per_in_ler_id
    and ecd.elig_per_elctbl_chc_id = p_bckdt_epe_id
    and pil.per_in_ler_id=p_bckdt_per_in_ler_id
    and pil.business_group_id=ecd.business_group_id
    and pil.per_in_ler_stat_cd = 'BCKDT';
  --
  cursor c_curr_ecd(p_effective_date date,
                    p_curr_epe_id number,
                    p_per_in_ler_id number) is
    select ecd.effective_start_date
          ,ecd.effective_end_date
          ,ecd.cvg_strt_dt
          ,ecd.cvg_thru_dt
          ,ecd.cvg_pndg_flag
          ,ecd.ovrdn_flag
          ,ecd.ovrdn_thru_dt
          ,ecd.dpnt_person_id
    from   ben_elig_cvrd_dpnt_f ecd,
           ben_per_in_ler pil
    where  p_effective_date between
        ecd.effective_start_date and ecd.effective_end_date
    and pil.per_in_ler_id=ecd.per_in_ler_id
    and ecd.elig_per_elctbl_chc_id = p_curr_epe_id
    and pil.per_in_ler_id=p_per_in_ler_id
    and pil.business_group_id=ecd.business_group_id;
  --
  TYPE l_bckdt_ecd_rec is TABLE OF c_bckdt_ecd%rowtype
       INDEX BY BINARY_INTEGER;
  --
  TYPE l_curr_ecd_rec is TABLE OF c_curr_ecd%rowtype
       INDEX BY BINARY_INTEGER;
  --
  l_bckdt_ecd_table l_bckdt_ecd_rec;
  l_curr_ecd_table  l_curr_ecd_rec;
  l_next_row        binary_integer;
  l_found           boolean;
  l_bckdt_ecd_count number;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  select count(*) into l_bckdt_ecd_count
    from   ben_elig_cvrd_dpnt_f ecd,
           ben_per_in_ler pil
    where  ecd.business_group_id=p_business_group_id
    and p_effective_date between
        ecd.effective_start_date and ecd.effective_end_date
    and pil.per_in_ler_id=ecd.per_in_ler_id
    and ecd.elig_per_elctbl_chc_id = p_bckdt_epe_id
    and pil.per_in_ler_id=p_bckdt_per_in_ler_id
    and pil.business_group_id=ecd.business_group_id
    and pil.per_in_ler_stat_cd = 'BCKDT';
  --
  l_curr_ecd_table.delete;
  l_next_row := nvl(l_curr_ecd_table.LAST, 0) + 1;
  --
  for  curr_ecd_rec  in c_curr_ecd(p_effective_date,p_curr_epe_id,p_per_in_ler_id)
  loop
     --
     l_curr_ecd_table(l_next_row)   := curr_ecd_rec;
     l_next_row := l_next_row + 1;
     --
  end loop;
  --
  -- Check Number of records in both tables differ
  --
  if nvl(l_curr_ecd_table.last, 0) = 0  and
     nvl(l_bckdt_ecd_count,0)  = 0
  then
       --
       l_differ := 'N';

       hr_utility.set_location('Leaving:  ' || l_differ ||' 0 '|| l_proc, 10);
       return l_differ;
       --
  elsif nvl(l_curr_ecd_table.last, 0) <> nvl(l_bckdt_ecd_count,0) then
       --
       l_differ := 'Y';

       hr_utility.set_location('Leaving:  ' || l_differ ||' <>0 '|| l_proc, 10);
       return l_differ;
       --
  end if;
  --
  --
  -- Now compare the original ecd record and new ecd record for each epe record.
  --
  for bckdt_ecd_rec in c_bckdt_ecd
  loop
    --
    l_found  := FALSE;
    --
    for  l_curr_count in l_curr_ecd_table.first..l_curr_ecd_table.last loop
      --
      if nvl(bckdt_ecd_rec.dpnt_person_id, -1) =
                   nvl(l_curr_ecd_table(l_curr_count).dpnt_person_id, -1) and
         nvl(bckdt_ecd_rec.effective_end_date, hr_api.g_eot) =
            nvl(l_curr_ecd_table(l_curr_count).effective_end_date, hr_api.g_eot) and
         nvl(bckdt_ecd_rec.cvg_thru_dt, hr_api.g_eot) =
               nvl(l_curr_ecd_table(l_curr_count).cvg_thru_dt, hr_api.g_eot)
      then
        l_found   := TRUE;
        exit;
      end if;
      --
    end loop;
    --
    if l_found   = FALSE then
       --
       -- Current epe for a given backed out epe is not found
       --
       l_differ := 'Y';
       exit;
    end if;
    --
  end loop;
  --

  hr_utility.set_location('Leaving:  ' || l_differ ||' 0 '|| l_proc, 10);
  --
  return l_differ;
  --
end comp_ori_new_ecd;
--
-- ----------------------------------------------------------------------------
-- |------------------------< comp_ori_new_pil_outcome >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure compares the original and new electability
-- data associated with the same ler and returns Y if changes
-- exists else returns N.
--
function comp_ori_new_pil_outcome(p_person_id       in number
                              ,p_business_group_id   in number
                              ,p_ler_id              in number
                              ,p_effective_date      in date
                              ,p_per_in_ler_id       in number
                              ,p_bckdt_per_in_ler_id in number
                           ) return varchar2 is
  --
  l_proc                   varchar2(72) := g_package||'.comp_ori_new_pil_outcome';
  --
  -- Following are the tables whose data will be compared to
  -- find any differences exists between the two runs of same ler.
  --
  -- ben_elig_cvrd_dpnt_f
  -- ben_prtt_enrt_actn_f
  -- ben_elig_per_elctbl_chc    -- 9999 done
  -- ben_enrt_bnft
  -- ben_enrt_rt
  -- ben_elctbl_chc_ctfn
  --
  cursor c_bckdt_epe_cnt is
    select count(*)
    from   ben_elig_per_elctbl_chc epe,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_bckdt_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.business_group_id = p_business_group_id
    AND    pil.per_in_ler_id       = epe.per_in_ler_id;
  --   and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor c_curr_epe_cnt is
    select count(*)
    from   ben_elig_per_elctbl_chc epe,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.business_group_id = p_business_group_id
    AND    pil.per_in_ler_id       = epe.per_in_ler_id;
  --   and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT'); -- 9999 any status codes to add.
  --  and    pil.per_in_ler_stat_cd = 'STRTD'
  --
  l_bckdt_epe_cnt           number  := 0;
  l_curr_epe_cnt            number  := 0;
  l_differ                  varchar2(1) := 'N';
  l_egd_differ              varchar2(1) := 'N';
  l_ecd_differ              varchar2(1) := 'N';
  l_enb_differ              varchar2(1) := 'N';
  l_epe_ecr_differ          varchar2(1) := 'N';
  l_diff_auto_flag          boolean   := true ;
  --
  cursor c_bckdt_epe_dat is
    select epe.*
    from   ben_elig_per_elctbl_chc epe,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_bckdt_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.business_group_id = p_business_group_id
    AND    pil.per_in_ler_id       = epe.per_in_ler_id;
  --   and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor c_curr_epe_dat is
    select epe.*
    from   ben_elig_per_elctbl_chc epe,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.business_group_id = p_business_group_id
    AND    pil.per_in_ler_id       = epe.per_in_ler_id;
  --
  TYPE l_bckdt_epe_rec is TABLE OF c_bckdt_epe_dat%rowtype
       INDEX BY BINARY_INTEGER;
  --
  TYPE l_curr_epe_rec is TABLE OF c_curr_epe_dat%rowtype
       INDEX BY BINARY_INTEGER;
  --
  l_bckdt_epe_table l_bckdt_epe_rec;
  l_curr_epe_table  l_curr_epe_rec;
  l_next_row        binary_integer;
  l_found           boolean;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  open  c_bckdt_epe_cnt;
  fetch c_bckdt_epe_cnt into l_bckdt_epe_cnt;
  close c_bckdt_epe_cnt;
  --
  open  c_curr_epe_cnt;
  fetch c_curr_epe_cnt into l_curr_epe_cnt;
  close c_curr_epe_cnt;
  --
  if l_bckdt_epe_cnt <> l_curr_epe_cnt then
     --
     l_differ := 'Y';
     --
  elsif (l_bckdt_epe_cnt = 0 and  l_curr_epe_cnt = 0) then
     --
     -- How to handle the case where the elecable choices are 0 9999
     --
     l_differ := 'N';
     --
  else
     --
     -- count of epe is same so look for actual diffs.
     --
     l_bckdt_epe_table.delete;
     l_next_row := nvl(l_bckdt_epe_table.LAST, 0) + 1;
     --
     for bckdt_epe_rec in c_bckdt_epe_dat
     loop
        --
        l_bckdt_epe_table(l_next_row)   := bckdt_epe_rec;
        l_next_row := l_next_row + 1;
        --
     end loop;
     --
     l_curr_epe_table.delete;
     l_next_row := nvl(l_curr_epe_table.LAST, 0) + 1;
     for  curr_epe_rec in c_curr_epe_dat
     loop
        --
        l_curr_epe_table(l_next_row)   := curr_epe_rec;
        l_next_row := l_next_row + 1;
        --
     end loop;
     --
     -- Now compare the original epe record and new epe record for each comp
     -- object.
     --
     for  l_count in l_bckdt_epe_table.first..l_bckdt_epe_table.last loop
       --
/*
hr_utility.set_location('pl_id = ' || nvl(l_bckdt_epe_table(l_count).pl_id, -1), 1234);
hr_utility.set_location('oipl_id = ' || nvl(l_bckdt_epe_table(l_count).oipl_id, -1), 1234);
hr_utility.set_location('PGM_ID = ' || nvl(l_bckdt_epe_table(l_count).PGM_ID, -1), 1234);
hr_utility.set_location('PLIP_ID = ' || nvl(l_bckdt_epe_table(l_count).PLIP_ID, -1), 1234);
hr_utility.set_location('PTIP_ID = ' || nvl(l_bckdt_epe_table(l_count).PTIP_ID, -1), 1234);
hr_utility.set_location('PL_TYP_ID = ' || nvl(l_bckdt_epe_table(l_count).PL_TYP_ID, -1), 1234);
hr_utility.set_location('CMBN_PTIP_ID = ' || nvl(l_bckdt_epe_table(l_count).CMBN_PTIP_ID, -1), 1234);
hr_utility.set_location('CMBN_PTIP_OPT_ID = ' || nvl(l_bckdt_epe_table(l_count).CMBN_PTIP_OPT_ID, -1), 1234);
hr_utility.set_location('CMBN_PLIP_ID = ' || nvl(l_bckdt_epe_table(l_count).CMBN_PLIP_ID, -1), 1234);
hr_utility.set_location('SPCL_RT_PL_ID = ' || nvl(l_bckdt_epe_table(l_count).SPCL_RT_PL_ID, -1), 1234);
hr_utility.set_location('SPCL_RT_OIPL_ID = ' || nvl(l_bckdt_epe_table(l_count).SPCL_RT_OIPL_ID, -1), 1234);
hr_utility.set_location('MUST_ENRL_ANTHR_PL_ID = ' || nvl(l_bckdt_epe_table(l_count).MUST_ENRL_ANTHR_PL_ID, -1), 1234);
hr_utility.set_location('DFLT_FLAG = ' || l_bckdt_epe_table(l_count).DFLT_FLAG, 1234);
hr_utility.set_location('ELCTBL_FLAG = ' || l_bckdt_epe_table(l_count).ELCTBL_FLAG, 1234);
hr_utility.set_location('MNDTRY_FLAG = ' || l_bckdt_epe_table(l_count).MNDTRY_FLAG, 1234);
hr_utility.set_location('ALWS_DPNT_DSGN_FLAG = ' || l_bckdt_epe_table(l_count).ALWS_DPNT_DSGN_FLAG, 1234);
hr_utility.set_location('AUTO_ENRT_FLAG = ' || l_bckdt_epe_table(l_count).AUTO_ENRT_FLAG, 1234);
hr_utility.set_location('CTFN_RQD_FLAG = ' || l_bckdt_epe_table(l_count).CTFN_RQD_FLAG, 1234);
hr_utility.set_location('BNFT_PRVDR_POOL_ID = ' || nvl(l_bckdt_epe_table(l_count).BNFT_PRVDR_POOL_ID, -1), 1234);
hr_utility.set_location('YR_PERD_ID = ' || nvl(l_bckdt_epe_table(l_count).YR_PERD_ID, -1), 1234);
hr_utility.set_location('ENRT_CVG_STRT_DT_CD = ' || nvl(l_bckdt_epe_table(l_count).ENRT_CVG_STRT_DT_CD, '$'), 1234);
hr_utility.set_location('ENRT_CVG_STRT_DT_RL = ' || nvl(l_bckdt_epe_table(l_count).ENRT_CVG_STRT_DT_RL, -1), 1234);
hr_utility.set_location('DPNT_CVG_STRT_DT_CD = ' || nvl(l_bckdt_epe_table(l_count).DPNT_CVG_STRT_DT_CD, '$'), 1234);
hr_utility.set_location('LER_CHG_DPNT_CVG_CD = ' || nvl(l_bckdt_epe_table(l_count).LER_CHG_DPNT_CVG_CD, '$'), 1234);
hr_utility.set_location('DPNT_CVG_STRT_DT_RL = ' || nvl(l_bckdt_epe_table(l_count).DPNT_CVG_STRT_DT_RL, -1), 1234);
hr_utility.set_location('ENRT_CVG_STRT_DT = ' || nvl(l_bckdt_epe_table(l_count).ENRT_CVG_STRT_DT, hr_api.g_eot), 1234);
hr_utility.set_location('ERLST_DEENRT_DT = ' || nvl(l_bckdt_epe_table(l_count).ERLST_DEENRT_DT, hr_api.g_eot), 1234);
*/
       l_found  := FALSE;
       l_diff_auto_flag := TRUE ;
       --
       for  l_curr_count in l_curr_epe_table.first..l_curr_epe_table.last loop
         --
/*
hr_utility.set_location('Curr pl_id = ' || nvl(l_curr_epe_table(l_curr_count).pl_id, -1), 1234);
hr_utility.set_location('Curr oipl_id = ' || nvl(l_curr_epe_table(l_curr_count).oipl_id, -1), 1234);
hr_utility.set_location('Curr PGM_ID = ' || nvl(l_curr_epe_table(l_curr_count).PGM_ID, -1), 1234);
hr_utility.set_location('Curr PLIP_ID = ' || nvl(l_curr_epe_table(l_curr_count).PLIP_ID, -1), 1234);
hr_utility.set_location('Curr PTIP_ID = ' || nvl(l_curr_epe_table(l_curr_count).PTIP_ID, -1), 1234);
hr_utility.set_location('Curr PL_TYP_ID = ' || nvl(l_curr_epe_table(l_curr_count).PL_TYP_ID, -1), 1234);
hr_utility.set_location('Curr CMBN_PTIP_ID = ' || nvl(l_curr_epe_table(l_curr_count).CMBN_PTIP_ID, -1), 1234);
hr_utility.set_location('Curr CMBN_PTIP_OPT_ID = ' || nvl(l_curr_epe_table(l_curr_count).CMBN_PTIP_OPT_ID, -1), 1234);
hr_utility.set_location('Curr CMBN_PLIP_ID = ' || nvl(l_curr_epe_table(l_curr_count).CMBN_PLIP_ID, -1), 1234);
hr_utility.set_location('Curr SPCL_RT_PL_ID = ' || nvl(l_curr_epe_table(l_curr_count).SPCL_RT_PL_ID, -1), 1234);
hr_utility.set_location('Curr SPCL_RT_OIPL_ID = ' || nvl(l_curr_epe_table(l_curr_count).SPCL_RT_OIPL_ID, -1), 1234);
hr_utility.set_location('Curr MUST_ENRL_ANTHR_PL_ID = ' || nvl(l_curr_epe_table(l_curr_count).MUST_ENRL_ANTHR_PL_ID, -1), 1234);
hr_utility.set_location('Curr DFLT_FLAG = ' || l_curr_epe_table(l_curr_count).DFLT_FLAG, 1234);
hr_utility.set_location('Curr ELCTBL_FLAG = ' || l_curr_epe_table(l_curr_count).ELCTBL_FLAG, 1234);
hr_utility.set_location('Curr MNDTRY_FLAG = ' || l_curr_epe_table(l_curr_count).MNDTRY_FLAG, 1234);
hr_utility.set_location('Curr ALWS_DPNT_DSGN_FLAG = ' || l_curr_epe_table(l_curr_count).ALWS_DPNT_DSGN_FLAG, 1234);
hr_utility.set_location('Curr AUTO_ENRT_FLAG = ' || l_curr_epe_table(l_curr_count).AUTO_ENRT_FLAG, 1234);
hr_utility.set_location('Curr CTFN_RQD_FLAG = ' || l_curr_epe_table(l_curr_count).CTFN_RQD_FLAG, 1234);
hr_utility.set_location('Curr BNFT_PRVDR_POOL_ID = ' || nvl(l_curr_epe_table(l_curr_count).BNFT_PRVDR_POOL_ID, -1), 1234);
hr_utility.set_location('Curr YR_PERD_ID = ' || nvl(l_curr_epe_table(l_curr_count).YR_PERD_ID, -1), 1234);
hr_utility.set_location('Curr ENRT_CVG_STRT_DT_CD = ' || nvl(l_curr_epe_table(l_curr_count).ENRT_CVG_STRT_DT_CD,  '$'), 1234);
hr_utility.set_location('Curr ENRT_CVG_STRT_DT_RL = ' || nvl(l_curr_epe_table(l_curr_count).ENRT_CVG_STRT_DT_RL, -1), 1234);
hr_utility.set_location('Curr DPNT_CVG_STRT_DT_CD = ' || nvl(l_curr_epe_table(l_curr_count).DPNT_CVG_STRT_DT_CD,  '$'), 1234);
hr_utility.set_location('Curr LER_CHG_DPNT_CVG_CD = ' || nvl(l_curr_epe_table(l_curr_count).LER_CHG_DPNT_CVG_CD,  '$'), 1234);
hr_utility.set_location('Curr DPNT_CVG_STRT_DT_RL = ' || nvl(l_curr_epe_table(l_curr_count).DPNT_CVG_STRT_DT_RL, -1), 1234);
hr_utility.set_location('Curr ENRT_CVG_STRT_DT = ' || nvl(l_curr_epe_table(l_curr_count).ENRT_CVG_STRT_DT, hr_api.g_eot), 1234);
hr_utility.set_location('Curr ERLST_DEENRT_DT = ' || nvl(l_curr_epe_table(l_curr_count).ERLST_DEENRT_DT, hr_api.g_eot) , 1234);


 if l_bckdt_epe_table(l_count).AUTO_ENRT_FLAG = 'Y'     and
    l_curr_epe_table(l_curr_count).AUTO_ENRT_FLAG = 'Y' and
    l_bckdt_epe_table(l_count).CRNTLY_ENRD_FLAG   =
                l_curr_epe_table(l_curr_count).CRNTLY_ENRD_FLAG

 then
      l_diff_auto_flag := FALSE ;
 end if ;
*/

     --    if l_diff_auto_flag and
         if  nvl(l_bckdt_epe_table(l_count).pl_id, -1) =
                      nvl(l_curr_epe_table(l_curr_count).pl_id, -1) and
            nvl(l_bckdt_epe_table(l_count).oipl_id, -1) =
                      nvl(l_curr_epe_table(l_curr_count).oipl_id, -1) and
            nvl(l_bckdt_epe_table(l_count).PGM_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).PGM_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).PLIP_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).PLIP_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).PTIP_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).PTIP_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).PL_TYP_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).PL_TYP_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).CMBN_PTIP_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).CMBN_PTIP_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).CMBN_PTIP_OPT_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).CMBN_PTIP_OPT_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).CMBN_PLIP_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).CMBN_PLIP_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).SPCL_RT_PL_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).SPCL_RT_PL_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).SPCL_RT_OIPL_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).SPCL_RT_OIPL_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).MUST_ENRL_ANTHR_PL_ID, -1) =
               nvl(l_curr_epe_table(l_curr_count).MUST_ENRL_ANTHR_PL_ID, -1) and
            l_bckdt_epe_table(l_count).DFLT_FLAG =
                      l_curr_epe_table(l_curr_count).DFLT_FLAG and
            l_bckdt_epe_table(l_count).ELCTBL_FLAG =
                      l_curr_epe_table(l_curr_count).ELCTBL_FLAG and
            l_bckdt_epe_table(l_count).MNDTRY_FLAG =
                      l_curr_epe_table(l_curr_count).MNDTRY_FLAG and
            l_bckdt_epe_table(l_count).ALWS_DPNT_DSGN_FLAG =
                      l_curr_epe_table(l_curr_count).ALWS_DPNT_DSGN_FLAG and
            l_bckdt_epe_table(l_count).AUTO_ENRT_FLAG =
                      l_curr_epe_table(l_curr_count).AUTO_ENRT_FLAG and
            l_bckdt_epe_table(l_count).CTFN_RQD_FLAG =
                      l_curr_epe_table(l_curr_count).CTFN_RQD_FLAG and
            nvl(l_bckdt_epe_table(l_count).BNFT_PRVDR_POOL_ID, -1) =
               nvl(l_curr_epe_table(l_curr_count).BNFT_PRVDR_POOL_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).YR_PERD_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).YR_PERD_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).ENRT_CVG_STRT_DT_CD, '$') =
               nvl(l_curr_epe_table(l_curr_count).ENRT_CVG_STRT_DT_CD,  '$') and
            nvl(l_bckdt_epe_table(l_count).ENRT_CVG_STRT_DT_RL, -1) =
               nvl(l_curr_epe_table(l_curr_count).ENRT_CVG_STRT_DT_RL, -1) and
            nvl(l_bckdt_epe_table(l_count).DPNT_CVG_STRT_DT_CD, '$') =
               nvl(l_curr_epe_table(l_curr_count).DPNT_CVG_STRT_DT_CD,  '$') and
            nvl(l_bckdt_epe_table(l_count).LER_CHG_DPNT_CVG_CD, '$') =
               nvl(l_curr_epe_table(l_curr_count).LER_CHG_DPNT_CVG_CD,  '$') and
            nvl(l_bckdt_epe_table(l_count).DPNT_CVG_STRT_DT_RL, -1) =
               nvl(l_curr_epe_table(l_curr_count).DPNT_CVG_STRT_DT_RL, -1) and
            nvl(l_bckdt_epe_table(l_count).ENRT_CVG_STRT_DT, hr_api.g_eot) =
               nvl(l_curr_epe_table(l_curr_count).ENRT_CVG_STRT_DT, hr_api.g_eot) and
            nvl(l_bckdt_epe_table(l_count).ERLST_DEENRT_DT, hr_api.g_eot) =
               nvl(l_curr_epe_table(l_curr_count).ERLST_DEENRT_DT, hr_api.g_eot)
         then
          --
          -- Now check elig_dpnt rows for any differences.
          --
          l_egd_differ := comp_ori_new_egd(
                           p_person_id              => p_person_id
                          ,p_business_group_id      => p_business_group_id
                          ,p_effective_date         => p_effective_date
                          ,p_per_in_ler_id          => p_per_in_ler_id
                          ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
                          ,p_curr_epe_id            =>
                            l_curr_epe_table(l_curr_count).ELIG_PER_ELCTBL_CHC_ID
                          ,p_bckdt_epe_id           =>
                            l_bckdt_epe_table(l_count).ELIG_PER_ELCTBL_CHC_ID
                          );
          --
          if l_egd_differ = 'Y' then
           --
           l_found   := FALSE;
           --
          else
           --
           l_ecd_differ := comp_ori_new_ecd(
                           p_person_id              => p_person_id
                          ,p_business_group_id      => p_business_group_id
                          ,p_effective_date         => p_effective_date
                          ,p_per_in_ler_id          => p_per_in_ler_id
                          ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
                          ,p_curr_epe_id            =>
                            l_curr_epe_table(l_curr_count).ELIG_PER_ELCTBL_CHC_ID
                          ,p_bckdt_epe_id           =>
                            l_bckdt_epe_table(l_count).ELIG_PER_ELCTBL_CHC_ID
                          );
           --
           if l_ecd_differ = 'Y' then
              --
              -- even though epe is same ecd differ logically we need to exit.
              --
              l_found   := FALSE;
           else
              --
              l_enb_differ := comp_ori_new_enb(
                           p_person_id              => p_person_id
                          ,p_business_group_id      => p_business_group_id
                          ,p_effective_date         => p_effective_date
                          ,p_per_in_ler_id          => p_per_in_ler_id
                          ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
                          ,p_curr_epe_id            =>
                            l_curr_epe_table(l_curr_count).ELIG_PER_ELCTBL_CHC_ID
                          ,p_bckdt_epe_id           =>
                            l_bckdt_epe_table(l_count).ELIG_PER_ELCTBL_CHC_ID
                          );
              --
              if l_enb_differ = 'Y' then
                 --
                 -- even though epe, ecd are same there may be differences in
                 -- enrt_bnft
                 --
                 l_found   := FALSE;
              else
                 --
                 l_epe_ecr_differ := comp_ori_new_epe_ecr(
                           p_person_id              => p_person_id
                          ,p_business_group_id      => p_business_group_id
                          ,p_effective_date         => p_effective_date
                          ,p_per_in_ler_id          => p_per_in_ler_id
                          ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
                          ,p_curr_epe_id            =>
                            l_curr_epe_table(l_curr_count).ELIG_PER_ELCTBL_CHC_ID
                          ,p_bckdt_epe_id           =>
                            l_bckdt_epe_table(l_count).ELIG_PER_ELCTBL_CHC_ID
                          );
                 --
                 if l_epe_ecr_differ = 'Y' then
                    --
                    -- even though epe, ecd, enb are same there may be
                    -- differences in enrt_rt
                    --
                    l_found   := FALSE;
                    --
                 else
                    --
                    l_found   := TRUE;
                    --
                 end if;
              end if;
              --
           end if;
           --
          end if; -- Diff in egd
          exit;
         end if;
         --
       end loop;
       --
       if l_found   = FALSE then
          --
          -- Current epe for a given backed out epe is not found
          --
          l_differ := 'Y';
          exit;
       end if;
       --
     end loop;
     --
  end if; -- epe ckecks if statement
  --

  hr_utility.set_location('Leaving:' || l_differ || l_proc, 10);
  --
  return l_differ;
  --
end comp_ori_new_pil_outcome;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< comp_ori_new_pil_for_popl >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure compares the original and new electability
-- data associated with the same ler and returns Y if changes
-- exists else returns N.
--
function comp_ori_new_pil_for_popl(p_person_id       in number
                              ,p_business_group_id   in number
                              ,p_ler_id              in number
                              ,p_effective_date      in date
                              ,p_per_in_ler_id       in number
                              ,p_bckdt_per_in_ler_id in number
                              ,p_pgm_id              in number
                              ,p_pl_id               in number
                           ) return varchar2 is
  --
  l_proc                   varchar2(72) := g_package||'.comp_ori_new_pil_outcome';
  --
  -- Following are the tables whose data will be compared to
  -- find any differences exists between the two runs of same ler.
  --
  -- ben_elig_cvrd_dpnt_f
  -- ben_prtt_enrt_actn_f
  -- ben_elig_per_elctbl_chc
  -- ben_enrt_bnft
  -- ben_enrt_rt
  -- ben_elctbl_chc_ctfn
  --
  cursor c_bckdt_epe_cnt is
    select count(*)
    from   ben_elig_per_elctbl_chc epe,
           ben_pil_elctbl_chc_popl pel,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_bckdt_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.per_in_ler_id       = pel.per_in_ler_id
    and    (pel.pgm_id = p_pgm_id or
            (p_pgm_id is null and pel.pgm_id is null))
    and    (pel.pl_id = p_pl_id or
            (pel.pl_id is null and p_pl_id is null))
    and    pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id;
  --
  cursor c_curr_epe_cnt is
    select count(*)
    from   ben_elig_per_elctbl_chc epe,
           ben_pil_elctbl_chc_popl pel,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.per_in_ler_id       = pel.per_in_ler_id
    and    (pel.pgm_id = p_pgm_id or
            (p_pgm_id is null and pel.pgm_id is null))
    and    (pel.pl_id = p_pl_id or
            (pel.pl_id is null and p_pl_id is null))
    and    pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id;
  --
  l_bckdt_epe_cnt           number  := 0;
  l_curr_epe_cnt            number  := 0;
  l_differ                  varchar2(1) := 'N';
  l_egd_differ              varchar2(1) := 'N';
  l_ecd_differ              varchar2(1) := 'N';
  l_enb_differ              varchar2(1) := 'N';
  l_epe_ecr_differ          varchar2(1) := 'N';
  l_diff_auto_flag          boolean   := true ;
  --
  cursor c_bckdt_epe_dat is
    select epe.*
    from   ben_elig_per_elctbl_chc epe,
           ben_pil_elctbl_chc_popl pel,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_bckdt_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.per_in_ler_id       = pel.per_in_ler_id
    and    (pel.pgm_id = p_pgm_id or
            (p_pgm_id is null and pel.pgm_id is null))
    and    (pel.pl_id = p_pl_id or
            (pel.pl_id is null and p_pl_id is null))
    and    pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id ;
  --
  cursor c_curr_epe_dat is
    select epe.*
    from   ben_elig_per_elctbl_chc epe,
           ben_pil_elctbl_chc_popl pel,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.per_in_ler_id       = pel.per_in_ler_id
    and    (pel.pgm_id = p_pgm_id or
            (p_pgm_id is null and pel.pgm_id is null))
    and    (pel.pl_id = p_pl_id or
            (pel.pl_id is null and p_pl_id is null))
    and    pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id ;
  --
  TYPE l_bckdt_epe_rec is TABLE OF c_bckdt_epe_dat%rowtype
       INDEX BY BINARY_INTEGER;
  --
  TYPE l_curr_epe_rec is TABLE OF c_curr_epe_dat%rowtype
       INDEX BY BINARY_INTEGER;
  --
  l_bckdt_epe_table l_bckdt_epe_rec;
  l_curr_epe_table  l_curr_epe_rec;
  l_next_row        binary_integer;
  l_found           boolean;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  open  c_bckdt_epe_cnt;
  fetch c_bckdt_epe_cnt into l_bckdt_epe_cnt;
  close c_bckdt_epe_cnt;
  --
  open  c_curr_epe_cnt;
  fetch c_curr_epe_cnt into l_curr_epe_cnt;
  close c_curr_epe_cnt;
  --
  if l_bckdt_epe_cnt <> l_curr_epe_cnt then
     --
     l_differ := 'Y';
     --
  elsif (l_bckdt_epe_cnt = 0 and  l_curr_epe_cnt = 0) then
     --
     -- How to handle the case where the elecable choices are 0 9999
     --
     l_differ := 'N';
     --
  else
     --
     -- count of epe is same so look for actual diffs.
     --
     l_bckdt_epe_table.delete;
     l_next_row := nvl(l_bckdt_epe_table.LAST, 0) + 1;
     --
     for bckdt_epe_rec in c_bckdt_epe_dat
     loop
        --
        l_bckdt_epe_table(l_next_row)   := bckdt_epe_rec;
        l_next_row := l_next_row + 1;
        --
     end loop;
     --
     l_curr_epe_table.delete;
     l_next_row := nvl(l_curr_epe_table.LAST, 0) + 1;
     for  curr_epe_rec in c_curr_epe_dat
     loop
        --
        l_curr_epe_table(l_next_row)   := curr_epe_rec;
        l_next_row := l_next_row + 1;
        --
     end loop;
     --
     -- Now compare the original epe record and new epe record for each comp
     -- object.
     --
     for  l_count in l_bckdt_epe_table.first..l_bckdt_epe_table.last loop
       --
       l_found  := FALSE;
       l_diff_auto_flag := TRUE ;
       --
       for  l_curr_count in l_curr_epe_table.first..l_curr_epe_table.last loop
         --
         if  nvl(l_bckdt_epe_table(l_count).pl_id, -1) =
                      nvl(l_curr_epe_table(l_curr_count).pl_id, -1) and
            nvl(l_bckdt_epe_table(l_count).oipl_id, -1) =
                      nvl(l_curr_epe_table(l_curr_count).oipl_id, -1) and
            nvl(l_bckdt_epe_table(l_count).PGM_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).PGM_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).PLIP_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).PLIP_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).PTIP_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).PTIP_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).PL_TYP_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).PL_TYP_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).CMBN_PTIP_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).CMBN_PTIP_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).CMBN_PTIP_OPT_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).CMBN_PTIP_OPT_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).CMBN_PLIP_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).CMBN_PLIP_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).SPCL_RT_PL_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).SPCL_RT_PL_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).SPCL_RT_OIPL_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).SPCL_RT_OIPL_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).MUST_ENRL_ANTHR_PL_ID, -1) =
               nvl(l_curr_epe_table(l_curr_count).MUST_ENRL_ANTHR_PL_ID, -1) and
            l_bckdt_epe_table(l_count).DFLT_FLAG =
                      l_curr_epe_table(l_curr_count).DFLT_FLAG and
            l_bckdt_epe_table(l_count).ELCTBL_FLAG =
                      l_curr_epe_table(l_curr_count).ELCTBL_FLAG and
            l_bckdt_epe_table(l_count).MNDTRY_FLAG =
                      l_curr_epe_table(l_curr_count).MNDTRY_FLAG and
            l_bckdt_epe_table(l_count).ALWS_DPNT_DSGN_FLAG =
                      l_curr_epe_table(l_curr_count).ALWS_DPNT_DSGN_FLAG and
            l_bckdt_epe_table(l_count).AUTO_ENRT_FLAG =
                      l_curr_epe_table(l_curr_count).AUTO_ENRT_FLAG and
            l_bckdt_epe_table(l_count).CTFN_RQD_FLAG =
                      l_curr_epe_table(l_curr_count).CTFN_RQD_FLAG and
            nvl(l_bckdt_epe_table(l_count).BNFT_PRVDR_POOL_ID, -1) =
               nvl(l_curr_epe_table(l_curr_count).BNFT_PRVDR_POOL_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).YR_PERD_ID, -1) =
                      nvl(l_curr_epe_table(l_curr_count).YR_PERD_ID, -1) and
            nvl(l_bckdt_epe_table(l_count).ENRT_CVG_STRT_DT_CD, '$') =
               nvl(l_curr_epe_table(l_curr_count).ENRT_CVG_STRT_DT_CD,  '$') and
            nvl(l_bckdt_epe_table(l_count).ENRT_CVG_STRT_DT_RL, -1) =
               nvl(l_curr_epe_table(l_curr_count).ENRT_CVG_STRT_DT_RL, -1) and
            nvl(l_bckdt_epe_table(l_count).DPNT_CVG_STRT_DT_CD, '$') =
               nvl(l_curr_epe_table(l_curr_count).DPNT_CVG_STRT_DT_CD,  '$') and
            nvl(l_bckdt_epe_table(l_count).LER_CHG_DPNT_CVG_CD, '$') =
               nvl(l_curr_epe_table(l_curr_count).LER_CHG_DPNT_CVG_CD,  '$') and
            nvl(l_bckdt_epe_table(l_count).DPNT_CVG_STRT_DT_RL, -1) =
               nvl(l_curr_epe_table(l_curr_count).DPNT_CVG_STRT_DT_RL, -1) and
            nvl(l_bckdt_epe_table(l_count).ENRT_CVG_STRT_DT, hr_api.g_eot) =
               nvl(l_curr_epe_table(l_curr_count).ENRT_CVG_STRT_DT, hr_api.g_eot) and
            nvl(l_bckdt_epe_table(l_count).ERLST_DEENRT_DT, hr_api.g_eot) =
               nvl(l_curr_epe_table(l_curr_count).ERLST_DEENRT_DT, hr_api.g_eot)
         then
          --
          -- Now check elig_dpnt rows for any differences.
          --
          l_egd_differ := comp_ori_new_egd(
                           p_person_id              => p_person_id
                          ,p_business_group_id      => p_business_group_id
                          ,p_effective_date         => p_effective_date
                          ,p_per_in_ler_id          => p_per_in_ler_id
                          ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
                          ,p_curr_epe_id            =>
                            l_curr_epe_table(l_curr_count).ELIG_PER_ELCTBL_CHC_ID
                          ,p_bckdt_epe_id           =>
                            l_bckdt_epe_table(l_count).ELIG_PER_ELCTBL_CHC_ID
                          );
          --
          if l_egd_differ = 'Y' then
           --
           l_found   := FALSE;
           --
          else
           --
           l_ecd_differ := comp_ori_new_ecd(
                           p_person_id              => p_person_id
                          ,p_business_group_id      => p_business_group_id
                          ,p_effective_date         => p_effective_date
                          ,p_per_in_ler_id          => p_per_in_ler_id
                          ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
                          ,p_curr_epe_id            =>
                            l_curr_epe_table(l_curr_count).ELIG_PER_ELCTBL_CHC_ID
                          ,p_bckdt_epe_id           =>
                            l_bckdt_epe_table(l_count).ELIG_PER_ELCTBL_CHC_ID
                          );
           --
           if l_ecd_differ = 'Y' then
              --
              -- even though epe is same ecd differ logically we need to exit.
              --
              l_found   := FALSE;
           else
              --
              l_enb_differ := comp_ori_new_enb(
                           p_person_id              => p_person_id
                          ,p_business_group_id      => p_business_group_id
                          ,p_effective_date         => p_effective_date
                          ,p_per_in_ler_id          => p_per_in_ler_id
                          ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
                          ,p_curr_epe_id            =>
                            l_curr_epe_table(l_curr_count).ELIG_PER_ELCTBL_CHC_ID
                          ,p_bckdt_epe_id           =>
                            l_bckdt_epe_table(l_count).ELIG_PER_ELCTBL_CHC_ID
                          );
              --
              if l_enb_differ = 'Y' then
                 --
                 -- even though epe, ecd are same there may be differences in
                 -- enrt_bnft
                 --
                 l_found   := FALSE;
              else
                 --
                 l_epe_ecr_differ := comp_ori_new_epe_ecr(
                           p_person_id              => p_person_id
                          ,p_business_group_id      => p_business_group_id
                          ,p_effective_date         => p_effective_date
                          ,p_per_in_ler_id          => p_per_in_ler_id
                          ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
                          ,p_curr_epe_id            =>
                            l_curr_epe_table(l_curr_count).ELIG_PER_ELCTBL_CHC_ID
                          ,p_bckdt_epe_id           =>
                            l_bckdt_epe_table(l_count).ELIG_PER_ELCTBL_CHC_ID
                          );
                 --
                 if l_epe_ecr_differ = 'Y' then
                    --
                    -- even though epe, ecd, enb are same there may be
                    -- differences in enrt_rt
                    --
                    l_found   := FALSE;
                    --
                 else
                    --
                    l_found   := TRUE;
                    --
                 end if;
              end if;
              --
           end if;
           --
          end if; -- Diff in egd
          exit;
         end if;
         --
       end loop;
       --
       if l_found   = FALSE then
          --
          -- Current epe for a given backed out epe is not found
          --
          l_differ := 'Y';
          exit;
       end if;
       --
     end loop;
     --
  end if; -- epe ckecks if statement
  --

  hr_utility.set_location('Leaving:' || l_differ || l_proc, 10);
  --
  return l_differ;
  --
end comp_ori_new_pil_for_popl;
--
procedure void_literature(p_person_id            in number
                          ,p_business_group_id   in number
                          ,p_effective_date      in date
                          ,p_ler_id              in number
                          ,p_per_in_ler_id       in number
                         ) is
  --
  l_proc                    varchar2(72) := g_package||'.void_literature';
  --
  -- Output variables
  --
  l_object_version_number number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  --
  cursor c_per_cm is
      select pcd.*
      from   ben_per_cm_f pcm,
             ben_per_cm_prvdd_f pcd
      where  pcm.person_id           = p_person_id
      and    pcm.ler_id              = p_ler_id
      and    pcm.business_group_id  = p_business_group_id
      and    p_effective_date
             between pcm.effective_start_date
             and     pcm.effective_end_date
      and    pcd.per_cm_id = pcm.per_cm_id
      and    pcd.sent_dt is null
      and    pcd.business_group_id  = p_business_group_id
      and    p_effective_date
             between pcd.effective_start_date
             and     pcd.effective_end_date;

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  for per_cm_rec in c_per_cm loop
    --
    ben_per_cm_prvdd_api.update_per_cm_prvdd
            (p_validate                       => false
            ,p_per_cm_prvdd_id                => per_cm_rec.per_cm_prvdd_id
            ,p_effective_start_date           => l_effective_start_date
            ,p_effective_end_date             => l_effective_end_date
            ,p_per_cm_prvdd_stat_cd           => 'VOID'
            ,p_object_version_number          => per_cm_rec.object_version_number
            ,p_effective_date                 => p_effective_date
            ,p_datetrack_mode                 => hr_api.g_correction);
    --
  end loop;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end void_literature;
--
procedure pad_cmnt_to_rsnd_lit(
                          p_person_id            in number
                          ,p_business_group_id   in number
                          ,p_effective_date      in date
                          ,p_ler_id              in number
                          ,p_per_in_ler_id       in number
                          ,p_cmnt_txt            in varchar2
                         ) is
  --
  l_proc                    varchar2(72) := g_package||'.pad_cmnt_to_rsnd_lit';
  --
  -- Output variables
  --
  l_object_version_number number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_resnd_cmnt_txt        fnd_new_messages.message_text%type;
  --
  cursor c_per_cm is
      select pcd.*
      from   ben_per_cm_f pcm,
             ben_per_cm_prvdd_f pcd
      where  pcm.person_id           = p_person_id
      and    pcm.ler_id              = p_ler_id
      and    pcm.business_group_id  = p_business_group_id
      and    p_effective_date
             between pcm.effective_start_date
             and     pcm.effective_end_date
      and    pcd.per_cm_id = pcm.per_cm_id
      and    pcd.sent_dt is null
      and    pcd.business_group_id  = p_business_group_id
      and    p_effective_date
             between pcd.effective_start_date
             and     pcd.effective_end_date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  for per_cm_rec in c_per_cm loop
    --
    --
    ben_per_cm_prvdd_api.update_per_cm_prvdd
            (p_validate                       => false
            ,p_per_cm_prvdd_id                => per_cm_rec.per_cm_prvdd_id
            ,p_effective_start_date           => l_effective_start_date
            ,p_effective_end_date             => l_effective_end_date
            ,p_sent_dt                        => null
            ,p_resnd_rsn_cd                   => 'RPE'  -- event reprocessed
            ,p_resnd_cmnt_txt                 => l_resnd_cmnt_txt
            ,p_object_version_number          => per_cm_rec.object_version_number
            ,p_effective_date                 => p_effective_date
            ,p_datetrack_mode                 => hr_api.g_correction);
   --
  end loop;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end pad_cmnt_to_rsnd_lit;
--
procedure extend_enrt_date(p_person_id             in number
                            ,p_business_group_id   in number
                            ,p_ler_id              in number
                            ,p_effective_date      in date
                            ,p_per_in_ler_id       in number
                           ) is
  --
  l_proc                    varchar2(72) := g_package||'.extend_enrt_date';
  --
  cursor c_ben_pil_elctbl_chc_popl is
    select pel.*
    from   ben_pil_elctbl_chc_popl pel,
           ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id
    and    pil.business_group_id = p_business_group_id
    and    pel.per_in_ler_id = pil.per_in_ler_id
    and    pel.business_group_id = pil.business_group_id;
  --
  l_move_out_by number;
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only extend the dates if the pel status was STRTD
  --
  if g_bckdt_pil_prvs_stat_cd = 'STRTD'  then
  --
   for pel_rec in c_ben_pil_elctbl_chc_popl
   loop
    --
    -- Give person same enrollment period starting from now
    -- Or if the enrollment period has not yet started then
    -- leave it alone.
    --
    if pel_rec.enrt_perd_strt_dt<trunc(sysdate) then
      --
      -- Now need to extend dates by difference between
      -- sysdate and old enrt_perd_strt_dt
      --
      l_move_out_by:=trunc(sysdate)-pel_rec.enrt_perd_strt_dt;
      --
      -- Update pel now
      --

      ben_Pil_Elctbl_chc_Popl_api.update_Pil_Elctbl_chc_Popl (
         p_validate               => false
        ,p_pil_elctbl_chc_popl_id => pel_rec.pil_elctbl_chc_popl_id
        ,p_object_version_number  => pel_rec.object_version_number
        ,p_effective_date         => p_effective_date
        ,p_enrt_perd_strt_dt      => pel_rec.enrt_perd_strt_dt+l_move_out_by
        ,p_enrt_perd_end_dt       => pel_rec.enrt_perd_end_dt+l_move_out_by
        ,p_dflt_enrt_dt           => pel_rec.dflt_enrt_dt+l_move_out_by
        ,p_procg_end_dt           => pel_rec.procg_end_dt+l_move_out_by
      );
      --
    end if;
   end loop;
   --
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end extend_enrt_date;
--
-- ----------------------------------------------------------------------------
-- |------------------------< reinstate_cbr_dates >-------------------------|
-- ----------------------------------------------------------------------------
procedure reinstate_cbr_dates(
                            p_person_id            in number
                            ,p_business_group_id   in number
                            ,p_ler_id              in number
                            ,p_effective_date      in date
                            ,p_per_in_ler_id       in number
                            ,p_bckdt_per_in_ler_id in number
                           ) is
  --
  l_proc                    varchar2(72) := g_package||'.reinstate_cbr_dates';
  --
  l_exists                  varchar2(1);
  l_object_version_number   ben_cbr_quald_bnf.object_version_number%type;
  --
  --  Get cobra secondary qualifying event
  --
  cursor c_get_cbr_per_in_ler is
    select crp.*
    from   ben_cbr_per_in_ler crp
    where  crp.per_in_ler_id = p_bckdt_per_in_ler_id
    and    crp.init_evt_flag = 'N'
    and    crp.business_group_id = p_business_group_id;
  --
  cursor c_bckdt_cqb is
    select cqb.*
    from   ben_le_clsn_n_rstr cqb
    where  cqb.per_in_ler_id       = p_bckdt_per_in_ler_id
    and    cqb.business_group_id = p_business_group_id
    and    cqb.bkup_tbl_typ_cd     = 'BEN_CBR_QUALD_BNF';
  --
  cursor c_cqb(p_cbr_quald_bnf_id in number) is
    select cqb.*
    from   ben_cbr_quald_bnf cqb
    where  cqb.cbr_quald_bnf_id  = p_cbr_quald_bnf_id
    and    cqb.business_group_id = p_business_group_id;
  --
  l_bckdt_cqb_rec             c_bckdt_cqb%rowtype;
  l_cqb_rec                   c_cqb%rowtype;
  l_crp_rec                   c_get_cbr_per_in_ler%rowtype;
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --  If backout event was a secondary COBRA qualifying event,
  --  re-instate the COBRA eligibility end date.
  --
  open c_get_cbr_per_in_ler;
  fetch c_get_cbr_per_in_ler into l_crp_rec;
  if c_get_cbr_per_in_ler%found then
    close c_get_cbr_per_in_ler;
    --
    --  Get backed up data.
    --
    for l_bckdt_cqb_rec in c_bckdt_cqb loop
      --
      --  Get object version number.
      --
      open c_cqb(l_bckdt_cqb_rec.bkup_tbl_id);
      fetch c_cqb into l_cqb_rec;
      if c_cqb%found then
        close c_cqb;
        --
        l_object_version_number := l_cqb_rec.object_version_number;
        --
        ben_cbr_quald_bnf_api.update_cbr_quald_bnf
          (p_validate              => false
          ,p_cbr_quald_bnf_id      => l_cqb_rec.cbr_quald_bnf_id
          ,p_cbr_elig_perd_end_dt  => l_bckdt_cqb_rec.elig_thru_dt
          ,p_business_group_id     => p_business_group_id
          ,p_object_version_number => l_object_version_number
          ,p_effective_date        => p_effective_date
          );
      else
        close c_cqb;
      end if;
    end loop;
  else
    close c_get_cbr_per_in_ler;
  end if;
  --
  -- Delete all the backup rows from the backup table after the
  -- restoration of rows.
  --
  delete from ben_le_clsn_n_rstr cqb
  where  cqb.per_in_ler_id       = p_bckdt_per_in_ler_id
    and  cqb.business_group_id = p_business_group_id
    and  cqb.bkup_tbl_typ_cd     = 'BEN_CBR_QUALD_BNF';
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);

end reinstate_cbr_dates;
--
-- ----------------------------------------------------------------------------
-- |------------------------< comp_ori_new_prv >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure compares the original and new rates for Enrollment results
-- data associated with the same ler and returns Y if changes
-- exists else returns N.
--
function comp_ori_new_prv(p_person_id       in number
                              ,p_business_group_id   in number
                              ,p_effective_date      in date
                              ,p_per_in_ler_id       in number
                              ,p_bckdt_per_in_ler_id in number
                              ,p_curr_pen_id         in number
                              ,p_bckdt_pen_id        in number
                              ,p_dont_check_cnt_flag in varchar2 default 'N'
                           ) return varchar2 is
  --
  l_proc                   varchar2(72) := g_package||'.comp_ori_new_prv';
  --
  l_differ                  varchar2(1) := 'N';
  --
  cursor c_bckdt_prv is
    select prv.*
    from   ben_prtt_rt_val prv
    where prv.prtt_enrt_rslt_id  = p_bckdt_pen_id
    and   prv.business_group_id  = p_business_group_id;
  --
  cursor c_curr_prv is
    select prv.*
    from   ben_prtt_rt_val prv
    where prv.prtt_enrt_rslt_id  = p_curr_pen_id
    and   prv.business_group_id  = p_business_group_id;
  --
  TYPE l_bckdt_prv_rec is TABLE OF c_bckdt_prv%rowtype
       INDEX BY BINARY_INTEGER;
  --
  TYPE l_curr_prv_rec is TABLE OF c_curr_prv%rowtype
       INDEX BY BINARY_INTEGER;
  --
  l_bckdt_prv_table     l_bckdt_prv_rec;
  l_curr_prv_table      l_curr_prv_rec;
  l_next_row            binary_integer;
  l_found               boolean;
  l_bckdt_prv_count     number;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  select count(*) into l_bckdt_prv_count
    from   ben_prtt_rt_val prv
    where prv.prtt_enrt_rslt_id = p_bckdt_pen_id
    and   prv.business_group_id  = p_business_group_id;
  --
  l_curr_prv_table.delete;
  l_next_row := nvl(l_curr_prv_table.LAST, 0) + 1;
  for  curr_prv_rec in c_curr_prv
  loop
     --
     l_curr_prv_table(l_next_row)   := curr_prv_rec;
     l_next_row := l_next_row + 1;
     --
  end loop;
  --
  -- Check Number of records in both tables for difference
  --
  if nvl(l_curr_prv_table.last, 0) = 0  and
     nvl(l_bckdt_prv_count,0)  = 0
  then
       --
       l_differ := 'N';

       hr_utility.set_location('Leaving:  ' || l_differ ||' 0 '|| l_proc, 10);
       return l_differ;
       --
  elsif nvl(l_curr_prv_table.last, 0) <> nvl(l_bckdt_prv_count,0) then
       --
       l_differ := 'Y';

       hr_utility.set_location('Leaving:  ' || l_differ ||'<> 0 '|| l_proc, 10);
       return l_differ;
       --
  end if;
  --
  -- Now compare the original prv record and new prv record for each
  -- pen record.
  --
  for bckdt_prv_rec in c_bckdt_prv
  loop
    --
    l_found  := FALSE;
    --
    for  l_curr_count in l_curr_prv_table.first..l_curr_prv_table.last
    loop
      --
      if nvl(bckdt_prv_rec.RT_TYP_CD, '$') =
                   nvl(l_curr_prv_table(l_curr_count).RT_TYP_CD, '$') and
         nvl(bckdt_prv_rec.RT_STRT_DT, hr_api.g_eot) =
            nvl(l_curr_prv_table(l_curr_count).RT_STRT_DT, hr_api.g_eot) and
         (nvl(bckdt_prv_rec.RT_END_DT, hr_api.g_eot) =
            nvl(l_curr_prv_table(l_curr_count).RT_END_DT, hr_api.g_eot) or
            p_dont_check_cnt_flag = 'Y'
         ) and
         nvl(bckdt_prv_rec.TX_TYP_CD, '$') =
                   nvl(l_curr_prv_table(l_curr_count).TX_TYP_CD, '$') and
         nvl(bckdt_prv_rec.ACTY_TYP_CD, '$') =
                   nvl(l_curr_prv_table(l_curr_count).ACTY_TYP_CD, '$') and
         nvl(bckdt_prv_rec.MLT_CD, '$') =
                   nvl(l_curr_prv_table(l_curr_count).MLT_CD, '$') and
         nvl(bckdt_prv_rec.ACTY_REF_PERD_CD, '$') =
                   nvl(l_curr_prv_table(l_curr_count).ACTY_REF_PERD_CD, '$') and
         (nvl(bckdt_prv_rec.RT_VAL, -1) =
                   nvl(l_curr_prv_table(l_curr_count).RT_VAL, -1) or
            p_dont_check_cnt_flag = 'Y'  -- 999 also check entr_val_at_enrt_flag = 'Y'
         ) and
         (nvl(bckdt_prv_rec.ANN_RT_VAL, -1) =
                   nvl(l_curr_prv_table(l_curr_count).ANN_RT_VAL, -1) or
            p_dont_check_cnt_flag = 'Y'  -- 999 also check entr_val_at_enrt_flag
         ) and
         (nvl(bckdt_prv_rec.CMCD_RT_VAL, -1) =
                   nvl(l_curr_prv_table(l_curr_count).CMCD_RT_VAL, -1) or
            p_dont_check_cnt_flag = 'Y'  -- 999 also check entr_val_at_enrt_flag
         ) and
         nvl(bckdt_prv_rec.CMCD_REF_PERD_CD, '$') =
                   nvl(l_curr_prv_table(l_curr_count).CMCD_REF_PERD_CD, '$') and
         nvl(bckdt_prv_rec.BNFT_RT_TYP_CD, '$') =
                   nvl(l_curr_prv_table(l_curr_count).BNFT_RT_TYP_CD, '$') and
         nvl(bckdt_prv_rec.DSPLY_ON_ENRT_FLAG, '$') =
                   nvl(l_curr_prv_table(l_curr_count).DSPLY_ON_ENRT_FLAG, '$') and
         nvl(bckdt_prv_rec.RT_OVRIDN_FLAG, '$') =
                   nvl(l_curr_prv_table(l_curr_count).RT_OVRIDN_FLAG, '$') and
         nvl(bckdt_prv_rec.RT_OVRIDN_THRU_DT, hr_api.g_eot) =
            nvl(l_curr_prv_table(l_curr_count).RT_OVRIDN_THRU_DT, hr_api.g_eot) and
         nvl(bckdt_prv_rec.ELCTNS_MADE_DT, hr_api.g_eot) =
            nvl(l_curr_prv_table(l_curr_count).ELCTNS_MADE_DT, hr_api.g_eot) and
         nvl(bckdt_prv_rec.CVG_AMT_CALC_MTHD_ID, -1) =
                   nvl(l_curr_prv_table(l_curr_count).CVG_AMT_CALC_MTHD_ID, -1) and
         nvl(bckdt_prv_rec.ACTL_PREM_ID, -1) =
                   nvl(l_curr_prv_table(l_curr_count).ACTL_PREM_ID, -1) and
         nvl(bckdt_prv_rec.COMP_LVL_FCTR_ID, -1) =
                   nvl(l_curr_prv_table(l_curr_count).COMP_LVL_FCTR_ID, -1) and
         nvl(bckdt_prv_rec.ACTY_BASE_RT_ID, -1) =
                   nvl(l_curr_prv_table(l_curr_count).ACTY_BASE_RT_ID, -1)
      then
        l_found   := TRUE;
        exit;
      end if;
      --
    end loop;
    --
    if l_found   = FALSE then
       --
       -- Current prv for a given backed out prv is not found
       --
       l_differ := 'Y';
       exit;
    end if;
  --
  end loop;
  --

  hr_utility.set_location('Leaving:' || l_differ || l_proc, 10);
  --
  return l_differ;
  --
end comp_ori_new_prv;
--
-- ----------------------------------------------------------------------------
-- |------------------------< comp_ori_new_pen >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure compares the original and new Enrollment results
-- data associated with the same ler and returns Y if changes
-- exists else returns N.
--
function comp_ori_new_pen(p_person_id       in number
                              ,p_business_group_id   in number
                              ,p_ler_id              in number
                              ,p_effective_date      in date
                              ,p_per_in_ler_id       in number
                              ,p_bckdt_per_in_ler_id in number
                              ,p_dont_check_cnt_flag in varchar2 default 'N'
                           ) return varchar2 is
  --
  l_proc                   varchar2(72) := g_package||'.comp_ori_new_pen';
  --
  -- Following are the tables whose data will be compared to
  -- find any differences exists between the two runs of same ler.
  --
  -- ben_prtt_enrt_rslt_f
  -- ben_prtt_rt_val
  --
  l_bckdt_pen_cnt           number  := 0;
  l_bckdt_pen_cnt_temp      number  := 0;
  l_curr_pen_cnt            number  := 0;
  l_differ                  varchar2(1) := 'N';
  l_prv_differ              varchar2(1) := 'N';
  --
  cursor c_bckdt_pen_dat is
   select pen.ASSIGNMENT_ID,
          pen.BNFT_AMT,
          pen.BNFT_NNMNTRY_UOM,
          pen.BNFT_ORDR_NUM,
          pen.BNFT_TYP_CD,
          pen.BUSINESS_GROUP_ID,
          pen.COMP_LVL_CD,
          pen.CREATED_BY,
          pen.CREATION_DATE,
          pen.EFFECTIVE_END_DATE,
          pen.EFFECTIVE_START_DATE,
          pen.ENRT_CVG_STRT_DT,
          pen.ENRT_CVG_THRU_DT,
          pen.ENRT_MTHD_CD,
          pen.ENRT_OVRIDN_FLAG,
          pen.ENRT_OVRID_RSN_CD,
          pen.ENRT_OVRID_THRU_DT,
          pen.ERLST_DEENRT_DT,
          pen.LAST_UPDATED_BY,
          pen.LAST_UPDATE_DATE,
          pen.LAST_UPDATE_LOGIN,
          pen.LER_ID,
          pen.NO_LNGR_ELIG_FLAG,
          pen.OBJECT_VERSION_NUMBER,
          pen.OIPL_ID,
          pen.OIPL_ORDR_NUM,
          pen.ORGNL_ENRT_DT,
          pen.PEN_ATTRIBUTE1,
          pen.PEN_ATTRIBUTE10,
          pen.PEN_ATTRIBUTE11,
          pen.PEN_ATTRIBUTE12,
          pen.PEN_ATTRIBUTE13,
          pen.PEN_ATTRIBUTE14,
          pen.PEN_ATTRIBUTE15,
          pen.PEN_ATTRIBUTE16,
          pen.PEN_ATTRIBUTE17,
          pen.PEN_ATTRIBUTE18,
          pen.PEN_ATTRIBUTE19,
          pen.PEN_ATTRIBUTE2,
          pen.PEN_ATTRIBUTE20,
          pen.PEN_ATTRIBUTE21,
          pen.PEN_ATTRIBUTE22,
          pen.PEN_ATTRIBUTE23,
          pen.PEN_ATTRIBUTE24,
          pen.PEN_ATTRIBUTE25,
          pen.PEN_ATTRIBUTE26,
          pen.PEN_ATTRIBUTE27,
          pen.PEN_ATTRIBUTE28,
          pen.PEN_ATTRIBUTE29,
          pen.PEN_ATTRIBUTE3,
          pen.PEN_ATTRIBUTE30,
          pen.PEN_ATTRIBUTE4,
          pen.PEN_ATTRIBUTE5,
          pen.PEN_ATTRIBUTE6,
          pen.PEN_ATTRIBUTE7,
          pen.PEN_ATTRIBUTE8,
          pen.PEN_ATTRIBUTE9,
          pen.PEN_ATTRIBUTE_CATEGORY,
          pen.PERSON_ID,
          pen.PER_IN_LER_ID,
          pen.PGM_ID,
          pen.PLIP_ORDR_NUM,
          pen.PL_ID,
          pen.PL_ORDR_NUM,
          pen.PL_TYP_ID,
          pen.PROGRAM_APPLICATION_ID,
          pen.PROGRAM_ID,
          pen.PROGRAM_UPDATE_DATE,
          pen.PRTT_ENRT_RSLT_ID,
          pen.PRTT_ENRT_RSLT_STAT_CD,
          pen.PRTT_IS_CVRD_FLAG,
          pen.PTIP_ID,
          pen.PTIP_ORDR_NUM,
          pen.REQUEST_ID,
          pen.RPLCS_SSPNDD_RSLT_ID,
          pen.SSPNDD_FLAG,
          pen.UOM
    from   ben_prtt_enrt_rslt_f pen,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_bckdt_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.business_group_id = p_business_group_id
    AND    pil.per_in_ler_id       = pen.per_in_ler_id
    and    pen.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
   union
   select
          pen.ASSIGNMENT_ID,
          pen.BNFT_AMT,
          pen.BNFT_NNMNTRY_UOM,
          pen.BNFT_ORDR_NUM,
          pen.BNFT_TYP_CD,
          pen.BUSINESS_GROUP_ID,
          pen.COMP_LVL_CD,
          pen.CREATED_BY,
          pen.CREATION_DATE,
          pen.EFFECTIVE_END_DATE,
          pen.EFFECTIVE_START_DATE,
          pen.ENRT_CVG_STRT_DT,
          pen.ENRT_CVG_THRU_DT,
          pen.ENRT_MTHD_CD,
          pen.ENRT_OVRIDN_FLAG,
          pen.ENRT_OVRID_RSN_CD,
          pen.ENRT_OVRID_THRU_DT,
          pen.ERLST_DEENRT_DT,
          pen.LAST_UPDATED_BY,
          pen.LAST_UPDATE_DATE,
          pen.LAST_UPDATE_LOGIN,
          pen.LER_ID,
          pen.NO_LNGR_ELIG_FLAG,
          pen.OBJECT_VERSION_NUMBER,
          pen.OIPL_ID,
          pen.OIPL_ORDR_NUM,
          pen.ORGNL_ENRT_DT,
          pen.LCR_ATTRIBUTE1,
          pen.LCR_ATTRIBUTE10,
          pen.LCR_ATTRIBUTE11,
          pen.LCR_ATTRIBUTE12,
          pen.LCR_ATTRIBUTE13,
          pen.LCR_ATTRIBUTE14,
          pen.LCR_ATTRIBUTE15,
          pen.LCR_ATTRIBUTE16,
          pen.LCR_ATTRIBUTE17,
          pen.LCR_ATTRIBUTE18,
          pen.LCR_ATTRIBUTE19,
          pen.LCR_ATTRIBUTE2,
          pen.LCR_ATTRIBUTE20,
          pen.LCR_ATTRIBUTE21,
          pen.LCR_ATTRIBUTE22,
          pen.LCR_ATTRIBUTE23,
          pen.LCR_ATTRIBUTE24,
          pen.LCR_ATTRIBUTE25,
          pen.LCR_ATTRIBUTE26,
          pen.LCR_ATTRIBUTE27,
          pen.LCR_ATTRIBUTE28,
          pen.LCR_ATTRIBUTE29,
          pen.LCR_ATTRIBUTE3,
          pen.LCR_ATTRIBUTE30,
          pen.LCR_ATTRIBUTE4,
          pen.LCR_ATTRIBUTE5,
          pen.LCR_ATTRIBUTE6,
          pen.LCR_ATTRIBUTE7,
          pen.LCR_ATTRIBUTE8,
          pen.LCR_ATTRIBUTE9,
          pen.LCR_ATTRIBUTE_CATEGORY,
          pen.PERSON_ID,
          pen.PER_IN_LER_ID,
          pen.PGM_ID,
          pen.PLIP_ORDR_NUM,
          pen.PL_ID,
          pen.PL_ORDR_NUM,
          pen.PL_TYP_ID,
          pen.PROGRAM_APPLICATION_ID,
          pen.PROGRAM_ID,
          pen.PROGRAM_UPDATE_DATE,
          pen.bkup_tbl_id, -- Mapped to PRTT_ENRT_RSLT_ID,
          pen.PRTT_ENRT_RSLT_STAT_CD,
          pen.PRTT_IS_CVRD_FLAG,
          pen.PTIP_ID,
          pen.PTIP_ORDR_NUM,
          pen.REQUEST_ID,
          pen.RPLCS_SSPNDD_RSLT_ID,
          pen.SSPNDD_FLAG,
          pen.UOM
    from  ben_le_clsn_n_rstr  pen,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_bckdt_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.business_group_id   = p_business_group_id
    AND    pil.per_in_ler_id       = pen.per_in_ler_id
    and    pen.bkup_tbl_typ_cd     = 'BEN_PRTT_ENRT_RSLT_F'
    and    pen.comp_lvl_cd         not in ('PLANFC', 'PLANIMP');
  --   and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor c_curr_pen_dat is
    select pen.*
    from   ben_prtt_enrt_rslt_f pen,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.business_group_id = p_business_group_id
    AND    pil.per_in_ler_id       = pen.per_in_ler_id
    and    pen.comp_lvl_cd         not in ('PLANFC', 'PLANIMP');
  --
  TYPE l_bckdt_pen_rec is TABLE OF c_bckdt_pen_dat%rowtype
       INDEX BY BINARY_INTEGER;
  --
  TYPE l_curr_pen_rec is TABLE OF c_curr_pen_dat%rowtype
       INDEX BY BINARY_INTEGER;
  --
  l_bckdt_pen_table l_bckdt_pen_rec;
  l_curr_pen_table  l_curr_pen_rec;
  l_next_row        binary_integer;
  l_found           boolean;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  hr_utility.set_location ('Entering bck pil id '||p_bckdt_per_in_ler_id,10);
  hr_utility.set_location ('Entering pil id '||p_per_in_ler_id,10);
  --
  -- Bug 1266433 : Do not consider the results of flex credits and
  -- imputed income as they are not considered in c_curr_pen_dat
  --
  select count(*) into l_bckdt_pen_cnt_temp
    from   ben_prtt_enrt_rslt_f pen,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_bckdt_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.business_group_id   = p_business_group_id
    and    pen.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
    AND    pil.per_in_ler_id       = pen.per_in_ler_id;
  --
  select count(*) into l_bckdt_pen_cnt
    from  ben_le_clsn_n_rstr  pen,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_bckdt_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.business_group_id   = p_business_group_id
    AND    pil.per_in_ler_id       = pen.per_in_ler_id
    and    pen.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
    and    pen.bkup_tbl_typ_cd     = 'BEN_PRTT_ENRT_RSLT_F';
  --
  l_bckdt_pen_cnt  := l_bckdt_pen_cnt_temp + l_bckdt_pen_cnt;
  l_curr_pen_table.delete;
  l_next_row := nvl(l_curr_pen_table.LAST, 0) + 1;
  for  curr_pen_rec in c_curr_pen_dat
  loop
     --
     l_curr_pen_table(l_next_row)   := curr_pen_rec;
     l_next_row := l_next_row + 1;
     --
  end loop;
  --
  -- Check Number of records in both tables differ
  --
  if nvl(l_curr_pen_table.last, 0) = 0  and
     nvl(l_bckdt_pen_cnt,0)  = 0
  then
       --
       l_differ := 'N';

       hr_utility.set_location('Leaving:  ' || l_differ
                                            ||' 0 '|| l_proc, 10);
       return l_differ;
       --
  elsif nvl(l_curr_pen_table.last, 0) = 0 and
       p_dont_check_cnt_flag  =  'Y' then
       --
       l_differ := 'N';

       hr_utility.set_location('Leaving:  ' || l_differ
                                            ||' 0 '|| l_proc, 10);
       return l_differ;
       --
  elsif nvl(l_curr_pen_table.last, 0) <> nvl(l_bckdt_pen_cnt,0) and
       p_dont_check_cnt_flag  =  'N' then
       --
       l_differ := 'Y';

       hr_utility.set_location('Leaving:  ' || l_differ ||' <>0 '||
                      nvl(l_curr_pen_table.last, 0) || ' bck= '
                   || nvl(l_bckdt_pen_cnt,0) || l_proc, 10);
       return l_differ;
       --
  end if;
  --
  -- Now compare the original pen record and new pen record.
  --
  l_found  := FALSE;
  --
  hr_utility.set_location(to_char(nvl(l_curr_pen_table.last, 0)) ,4987);
  if nvl(l_curr_pen_table.last, 0) > 0 then
    --
    hr_utility.set_location(' Before first Loop ',4987);
   for  l_curr_count in l_curr_pen_table.first..l_curr_pen_table.last loop
    --
    l_found  := FALSE;
    --
    hr_utility.set_location(' Before Loop ',4987);
    for bckdt_pen_rec in c_bckdt_pen_dat
    loop
      --

        hr_utility.set_location(' Before if ',4987);
        /*
        hr_utility.set_location(  'SSPNDD_FLAG '     ||
                 nvl(bckdt_pen_rec.SSPNDD_FLAG, '$r') ||'--'||
                 nvl(l_curr_pen_table(l_curr_count).SSPNDD_FLAG, '$'),4987);
        hr_utility.set_location( 'ENRT_CVG_STRT_DT '
                 ||  nvl(bckdt_pen_rec.ENRT_CVG_STRT_DT, hr_api.g_eot)  ||'--'||
                nvl(l_curr_pen_table(l_curr_count).ENRT_CVG_STRT_DT, hr_api.g_eot),4987);
        hr_utility.set_location( 'ENRT_CVG_THRU_DT '
                 ||  nvl(bckdt_pen_rec.ENRT_CVG_THRU_DT, hr_api.g_eot)||'--'||
               nvl(l_curr_pen_table(l_curr_count).ENRT_CVG_THRU_DT, hr_api.g_eot),4987);
        hr_utility.set_location( 'PRTT_IS_CVRD_FLA '
                 ||  nvl(bckdt_pen_rec.PRTT_IS_CVRD_FLAG, '$') ||'--'||
              nvl(l_curr_pen_table(l_curr_count).PRTT_IS_CVRD_FLAG, '$'),4987);
        hr_utility.set_location( 'PRTT_IS_CVRD_FLAG'
                 ||  nvl(bckdt_pen_rec.BNFT_AMT, -1)||'--'||
              nvl(l_curr_pen_table(l_curr_count).BNFT_AMT, -1),4987);
        hr_utility.set_location( 'BNFT_NNMNTRY_UOM '
                 ||  nvl(bckdt_pen_rec.BNFT_NNMNTRY_UOM, '$') ||'--'||
              nvl(l_curr_pen_table(l_curr_count).BNFT_NNMNTRY_UOM, '$'),4987);
        hr_utility.set_location( 'BNFT_TYP_CD '
                 ||  nvl(bckdt_pen_rec.BNFT_TYP_CD, '$') ||'--'||
              nvl(l_curr_pen_table(l_curr_count).BNFT_TYP_CD, '$'),4987);
        hr_utility.set_location( 'UOM ' ||  nvl(bckdt_pen_rec.UOM, '$') ||'--'||
              nvl(l_curr_pen_table(l_curr_count).UOM, '$'),4987);
        hr_utility.set_location( 'ORGNL_ENRT_DT '
                 ||  nvl(bckdt_pen_rec.ORGNL_ENRT_DT, hr_api.g_eot)  ||'--'||
              nvl(l_curr_pen_table(l_curr_count).ORGNL_ENRT_DT, hr_api.g_eot),4987);
        hr_utility.set_location( 'ENRT_MTHD_CD '
                 ||  nvl(bckdt_pen_rec.ENRT_MTHD_CD, '$') ||'--'||
              nvl(l_curr_pen_table(l_curr_count).ENRT_MTHD_CD, '$'),4987);
        hr_utility.set_location( 'ENRT_OVRIDN_FLAG '||
                 nvl(bckdt_pen_rec.ENRT_OVRIDN_FLAG, '$') ||'--'||
              nvl(l_curr_pen_table(l_curr_count).ENRT_OVRIDN_FLAG, '$'),4987);
        hr_utility.set_location( 'ENRT_OVRID_RSN_CD '
                 ||  nvl(bckdt_pen_rec.ENRT_OVRID_RSN_CD, '$')||'--'||
              nvl(l_curr_pen_table(l_curr_count).ENRT_OVRID_RSN_CD, '$'),4987);
        hr_utility.set_location( 'ERLST_DEENRT_DT '
                 ||  nvl(bckdt_pen_rec.ERLST_DEENRT_DT, hr_api.g_eot)||'--'||
              nvl(l_curr_pen_table(l_curr_count).ERLST_DEENRT_DT, hr_api.g_eot),4987);

       hr_utility.set_location( 'ENRT_OVRID_THRU_DT'
                 ||  nvl(bckdt_pen_rec.ENRT_OVRID_THRU_DT, hr_api.g_eot) ||'--'||
              nvl(l_curr_pen_table(l_curr_count).ENRT_OVRID_THRU_DT, hr_api.g_eot),4987);
        hr_utility.set_location( 'NO_LNGR_ELIG_FLAG'
                 ||  nvl(bckdt_pen_rec.NO_LNGR_ELIG_FLAG, '$')||'--'||
              nvl(l_curr_pen_table(l_curr_count).NO_LNGR_ELIG_FLAG, '$'),4987);
        hr_utility.set_location( 'PRTT_ENRT_RSLT_STAT_CD'
                 || nvl(bckdt_pen_rec.PRTT_ENRT_RSLT_STAT_CD, '$')||'--'||
              nvl(l_curr_pen_table(l_curr_count).PRTT_ENRT_RSLT_STAT_CD, '$')
                 ||'--'||  p_dont_check_cnt_flag ,4987);
        hr_utility.set_location( 'COMP_LVL_CD' || nvl(bckdt_pen_rec.COMP_LVL_CD, '$')||'--'||
              nvl(l_curr_pen_table(l_curr_count). COMP_LVL_CD, '$'),4987);
        hr_utility.set_location( 'PGM_ID '  || nvl(bckdt_pen_rec.PGM_ID, -1)||'--'||
              nvl(l_curr_pen_table(l_curr_count).PGM_ID,-1),4987);
        hr_utility.set_location( 'PL_ID '   || nvl(bckdt_pen_rec.PL_ID, -1)||'--'||
             nvl(l_curr_pen_table(l_curr_count).PL_ID, -1), 4987);
        hr_utility.set_location( 'PL_TYP_ID '||nvl(bckdt_pen_rec.PL_TYP_ID, -1)||'--'||
             nvl(l_curr_pen_table(l_curr_count).PL_TYP_ID, -1),4987);

         hr_utility.set_location( 'OIPL_ID'          ||  nvl(bckdt_pen_rec.OIPL_ID, -1) ||'--'||
             nvl(l_curr_pen_table(l_curr_count).OIPL_ID, -1),4987);
        hr_utility.set_location( 'PTIP_ID ' ||  nvl(bckdt_pen_rec.PTIP_ID, -1) ||'--'||
             nvl(l_curr_pen_table(l_curr_count).PTIP_ID, -1),4987);
        hr_utility.set_location( 'LER_ID '  ||  nvl(bckdt_pen_rec.LER_ID, -1) ||'--'||
             nvl(l_curr_pen_table(l_curr_count).LER_ID, -1),4987);
        hr_utility.set_location( 'RPLCS_SSPNDD_RSLT_ID '
                 || nvl(bckdt_pen_rec.RPLCS_SSPNDD_RSLT_ID, -1)||'--'||
            nvl(l_curr_pen_table(l_curr_count).RPLCS_SSPNDD_RSLT_ID, -1),4987);

        */
      if nvl(bckdt_pen_rec.SSPNDD_FLAG, '$') =
                   nvl(l_curr_pen_table(l_curr_count).SSPNDD_FLAG, '$') and
         nvl(bckdt_pen_rec.ENRT_CVG_STRT_DT, hr_api.g_eot) =
            nvl(l_curr_pen_table(l_curr_count).ENRT_CVG_STRT_DT, hr_api.g_eot) and
         nvl(bckdt_pen_rec.ENRT_CVG_THRU_DT, hr_api.g_eot) =
            nvl(l_curr_pen_table(l_curr_count).ENRT_CVG_THRU_DT, hr_api.g_eot) and
         nvl(bckdt_pen_rec.PRTT_IS_CVRD_FLAG, '$') =
                   nvl(l_curr_pen_table(l_curr_count).PRTT_IS_CVRD_FLAG, '$') and
         nvl(bckdt_pen_rec.BNFT_AMT, -1) =
                   nvl(l_curr_pen_table(l_curr_count).BNFT_AMT, -1) and
         nvl(bckdt_pen_rec.BNFT_NNMNTRY_UOM, '$') =
                   nvl(l_curr_pen_table(l_curr_count).BNFT_NNMNTRY_UOM, '$') and
         nvl(bckdt_pen_rec.BNFT_TYP_CD, '$') =
                   nvl(l_curr_pen_table(l_curr_count).BNFT_TYP_CD, '$') and
         nvl(bckdt_pen_rec.UOM, '$') =
                   nvl(l_curr_pen_table(l_curr_count).UOM, '$') and
         nvl(bckdt_pen_rec.ORGNL_ENRT_DT, hr_api.g_eot) =
            nvl(l_curr_pen_table(l_curr_count).ORGNL_ENRT_DT, hr_api.g_eot) and
         nvl(bckdt_pen_rec.ENRT_MTHD_CD, '$') =
                   nvl(l_curr_pen_table(l_curr_count).ENRT_MTHD_CD, '$') and
         nvl(bckdt_pen_rec.ENRT_OVRIDN_FLAG, '$') =
                   nvl(l_curr_pen_table(l_curr_count).ENRT_OVRIDN_FLAG, '$') and
         nvl(bckdt_pen_rec.ENRT_OVRID_RSN_CD, '$') =
                   nvl(l_curr_pen_table(l_curr_count).ENRT_OVRID_RSN_CD, '$') and
         nvl(bckdt_pen_rec.ERLST_DEENRT_DT, hr_api.g_eot) =
            nvl(l_curr_pen_table(l_curr_count).ERLST_DEENRT_DT, hr_api.g_eot) and
         nvl(bckdt_pen_rec.ENRT_OVRID_THRU_DT, hr_api.g_eot) =
            nvl(l_curr_pen_table(l_curr_count).ENRT_OVRID_THRU_DT, hr_api.g_eot) and
         nvl(bckdt_pen_rec.NO_LNGR_ELIG_FLAG, '$') =
                   nvl(l_curr_pen_table(l_curr_count).NO_LNGR_ELIG_FLAG, '$') and
         /*
           Bug 1266433 : Do not compare the status codes.
         ( nvl(bckdt_pen_rec.PRTT_ENRT_RSLT_STAT_CD, '$') =
                   nvl(l_curr_pen_table(l_curr_count).PRTT_ENRT_RSLT_STAT_CD, '$') or
           p_dont_check_cnt_flag  =  'Y'
         ) and
         */
         nvl(bckdt_pen_rec.COMP_LVL_CD, '$') =
                   nvl(l_curr_pen_table(l_curr_count).COMP_LVL_CD, '$') and
         nvl(bckdt_pen_rec.PGM_ID, -1) =
                   nvl(l_curr_pen_table(l_curr_count).PGM_ID, -1) and
         nvl(bckdt_pen_rec.PL_ID, -1) =
                   nvl(l_curr_pen_table(l_curr_count).PL_ID, -1) and
         nvl(bckdt_pen_rec.PL_TYP_ID, -1) =
            nvl(l_curr_pen_table(l_curr_count).PL_TYP_ID, -1) and
         nvl(bckdt_pen_rec.OIPL_ID, -1) =
            nvl(l_curr_pen_table(l_curr_count).OIPL_ID, -1) and
         nvl(bckdt_pen_rec.PTIP_ID, -1) =
                   nvl(l_curr_pen_table(l_curr_count).PTIP_ID, -1) and
         /*
           Bug 1266433 : Do not compare the ler id .
         nvl(bckdt_pen_rec.LER_ID, -1) =
                   nvl(l_curr_pen_table(l_curr_count).LER_ID, -1)  and
         */
         nvl(bckdt_pen_rec.RPLCS_SSPNDD_RSLT_ID, -1) =
                   nvl(l_curr_pen_table(l_curr_count).RPLCS_SSPNDD_RSLT_ID, -1)
      then
        --
        l_prv_differ := comp_ori_new_prv(
           p_person_id              => p_person_id
           ,p_business_group_id     => p_business_group_id
           ,p_effective_date        => p_effective_date
           ,p_per_in_ler_id         => p_per_in_ler_id
           ,p_bckdt_per_in_ler_id   => p_bckdt_per_in_ler_id
           ,p_curr_pen_id           => l_curr_pen_table(l_curr_count).prtt_enrt_rslt_id
           ,p_bckdt_pen_id          => bckdt_pen_rec.prtt_enrt_rslt_id
           ,p_dont_check_cnt_flag   => p_dont_check_cnt_flag
           );
        --
        if l_prv_differ = 'Y' then
           --
           -- even though pen are same there may be differences
           -- in prtt_rt_val
           --
           l_found   := FALSE;
           --
        else
           --
           l_found   := TRUE;
           --
        end if;
        exit;
      end if;
      --
    end loop;
    --
    if l_found   = FALSE then
       --
       -- Current pen for a given backed out pen is not found
       --
       l_differ := 'Y';
       exit;
    end if;
    --
   end loop;
   --
  else
   --
   if l_found   = FALSE then
       --
       -- Current pen for a given backed out pen is not found
       --
       l_differ := 'Y';
       --
   end if;
   --
  end if;
  --

  hr_utility.set_location('Leaving:' || l_differ || l_proc, 10);
  --
  return l_differ;
  --
end comp_ori_new_pen;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_inter_pil_cnt >-------------------------|
-- ----------------------------------------------------------------------------
--
-- If more than one pil exists between two runs of a pil then
-- no restoration to be done.
--
/*
procedure  get_inter_pil_cnt (
                        p_bckdt_per_in_ler_id      in number,
                        p_per_in_ler_id            in number,
                        p_person_id                in number,
                        p_inter_per_in_ler_id      out nocopy number,
                        p_inter_pil_ovn            out nocopy number,
                        p_inter_pil_cnt            out nocopy number,
                        p_business_group_id        in number,
                        p_effective_date           in date) is
  --
  l_proc                     varchar2(72) := g_package||'.get_inter_pil_cnt';
  --
  -- Bug 4987 ( WWW Bug 1266433)
  -- When counting the intervening life events only count the pil's
  -- whose lf_evt_ocrd_dt is more than the back out date of the
  -- backed out per in ler.
  --
  cursor c_bckt_csd_pil is
         select csd_pil.lf_evt_ocrd_dt
         from ben_per_in_ler csd_pil,
              ben_per_in_ler bckt_pil
         where bckt_pil.per_in_ler_id = p_bckdt_per_in_ler_id
           and bckt_pil.BCKT_PER_IN_LER_ID = csd_pil.per_in_ler_id
           and bckt_pil.business_group_id = p_business_group_id
           and csd_pil.business_group_id = p_business_group_id;
  --
  l_bckt_csd_lf_evt_ocrd_dt date;
  --
  -- Bug 5415 : Intermediate pil count should be between
  -- the life event occured date of pil which causes back out
  -- and the current reprocessing backed out pil.
  -- iREC : do not consider iRec, ABS, COMP, GSP pils.
  --
  cursor c_inter_pil_cnt(cv_bckt_csd_lf_evt_ocrd_dt date) is
    select pil.per_in_ler_id, pil.object_version_number
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.per_in_ler_id <> p_per_in_ler_id
    and    pil.per_in_ler_id <> p_bckdt_per_in_ler_id
    and    pil.person_id         = p_person_id
    and    pil.ler_id            = ler.ler_id
    and    p_effective_date between
           ler.effective_start_date and ler.effective_end_date
    and    ler.typ_cd not in ('IREC', 'SCHEDDU', 'COMP', 'GSP', 'ABS')
    and    pil.business_group_id = p_business_group_id
    and    nvl(pil.per_in_ler_stat_cd, 'XXXX') not in('BCKDT', 'VOIDD')
    and    pil.lf_evt_ocrd_dt > cv_bckt_csd_lf_evt_ocrd_dt
    and    pil.lf_evt_ocrd_dt < (select lf_evt_ocrd_dt
                                 from ben_per_in_ler
                                 where per_in_ler_id = p_bckdt_per_in_ler_id
                                   and business_group_id = p_business_group_id
                                );
  --
  l_count number     := 0;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  p_inter_pil_cnt := 0;
  open c_bckt_csd_pil;
  fetch c_bckt_csd_pil into l_bckt_csd_lf_evt_ocrd_dt;
  close c_bckt_csd_pil;
  --
  g_bckt_csd_lf_evt_ocrd_dt := l_bckt_csd_lf_evt_ocrd_dt;
  --
  open  c_inter_pil_cnt(l_bckt_csd_lf_evt_ocrd_dt);
  fetch c_inter_pil_cnt into  p_inter_per_in_ler_id, p_inter_pil_ovn;
  if c_inter_pil_cnt%found then
     --
     -- Find are there more intervening PIL's.
     --
     p_inter_pil_cnt := 1;
     fetch c_inter_pil_cnt into  p_inter_per_in_ler_id, p_inter_pil_ovn;
     if c_inter_pil_cnt%found then
        p_inter_pil_cnt := p_inter_pil_cnt + 1;
     end if;
     --
  end if;
  --
  close c_inter_pil_cnt;
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
end get_inter_pil_cnt;
*/
--
procedure reinstate_bpl_per_pen(
                           p_person_id              in number
                          ,p_business_group_id      in number
                          ,p_effective_date         in date
                          ,p_per_in_ler_id          in number
                          ,p_bckdt_per_in_ler_id    in number
                          ) is
  --
  l_proc                    varchar2(72) := g_package||'.reinstate_bpl_per_pen';
  --
  cursor c_bckdt_pen is
   select  pen.EFFECTIVE_END_DATE,
           pen.OIPL_ID,
           pen.prtt_enrt_rslt_id,
           pen.OBJECT_VERSION_NUMBER,
           pen.PGM_ID,
           pen.PL_ID,
           pen.PL_TYP_ID,
           pen.PTIP_ID
    from   ben_prtt_enrt_rslt_f pen,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_bckdt_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.business_group_id = p_business_group_id
    and    pil.per_in_ler_id       = pen.per_in_ler_id
    and    pen.comp_lvl_cd         = 'PLANFC'
   union
   select  pen.EFFECTIVE_END_DATE,
           pen.OIPL_ID,
           pen.bkup_tbl_id, -- Mapped to PRTT_ENRT_RSLT_ID,
           pen.OBJECT_VERSION_NUMBER,
           pen.PGM_ID,
           pen.PL_ID,
           pen.PL_TYP_ID,
           pen.PTIP_ID
    from  ben_le_clsn_n_rstr  pen,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_bckdt_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.business_group_id   = p_business_group_id
    AND    pil.per_in_ler_id       = pen.per_in_ler_id
    and    pen.bkup_tbl_typ_cd     = 'BEN_PRTT_ENRT_RSLT_F'
    and    pen.comp_lvl_cd         = 'PLANFC'
    order by 1; -- pen.effective_end_date; -- Low to High
  --
  cursor c_curr_pen(cp_pl_id in number, cp_oipl_id in number,
                    cp_pgm_id in number) is
   select  pen.EFFECTIVE_END_DATE,
           pen.OIPL_ID,
           pen.prtt_enrt_rslt_id,
           pen.OBJECT_VERSION_NUMBER,
           pen.PGM_ID,
           pen.PL_ID,
           pen.PL_TYP_ID,
           pen.PTIP_ID,
           pen.effective_start_date
    from   ben_prtt_enrt_rslt_f pen,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.business_group_id   = p_business_group_id
    and    pil.per_in_ler_id       = pen.per_in_ler_id
    and    nvl(pen.pl_id, -1)      = nvl(cp_pl_id, -1)
    and    nvl(pen.oipl_id, -1)    = nvl(cp_oipl_id, -1)
    and    nvl(pen.pgm_id, -1)     = nvl(cp_pgm_id, -1)
    and    pen.comp_lvl_cd         = 'PLANFC';
  --
  cursor c_bckdt_bpl(cp_bckdt_prtt_enrt_rslt_id in number)
   is
    select
           bckdt_bpl.EFFECTIVE_END_DATE
           ,bckdt_bpl.BNFT_PRVDD_LDGR_ID
           ,bckdt_bpl.EFFECTIVE_START_DATE
           ,bckdt_bpl.PRTT_RO_OF_UNUSD_AMT_FLAG
           ,bckdt_bpl.FRFTD_VAL
           ,bckdt_bpl.PRVDD_VAL
           ,bckdt_bpl.USED_VAL
           ,bckdt_bpl.CASH_RECD_VAL
           ,bckdt_bpl.BNFT_PRVDR_POOL_ID
           ,bckdt_bpl.ACTY_BASE_RT_ID
           ,bckdt_bpl.PRTT_ENRT_RSLT_ID
           ,bckdt_bpl.BUSINESS_GROUP_ID
           ,bckdt_bpl.BPL_ATTRIBUTE_CATEGORY
           ,bckdt_bpl.BPL_ATTRIBUTE1
           ,bckdt_bpl.BPL_ATTRIBUTE2
           ,bckdt_bpl.BPL_ATTRIBUTE3
           ,bckdt_bpl.BPL_ATTRIBUTE4
           ,bckdt_bpl.BPL_ATTRIBUTE5
           ,bckdt_bpl.BPL_ATTRIBUTE6
           ,bckdt_bpl.BPL_ATTRIBUTE7
           ,bckdt_bpl.BPL_ATTRIBUTE8
           ,bckdt_bpl.BPL_ATTRIBUTE9
           ,bckdt_bpl.BPL_ATTRIBUTE10
           ,bckdt_bpl.BPL_ATTRIBUTE11
           ,bckdt_bpl.BPL_ATTRIBUTE12
           ,bckdt_bpl.BPL_ATTRIBUTE13
           ,bckdt_bpl.BPL_ATTRIBUTE14
           ,bckdt_bpl.BPL_ATTRIBUTE15
           ,bckdt_bpl.BPL_ATTRIBUTE16
           ,bckdt_bpl.BPL_ATTRIBUTE17
           ,bckdt_bpl.BPL_ATTRIBUTE18
           ,bckdt_bpl.BPL_ATTRIBUTE19
           ,bckdt_bpl.BPL_ATTRIBUTE20
           ,bckdt_bpl.BPL_ATTRIBUTE21
           ,bckdt_bpl.BPL_ATTRIBUTE22
           ,bckdt_bpl.BPL_ATTRIBUTE23
           ,bckdt_bpl.BPL_ATTRIBUTE24
           ,bckdt_bpl.BPL_ATTRIBUTE25
           ,bckdt_bpl.BPL_ATTRIBUTE26
           ,bckdt_bpl.BPL_ATTRIBUTE27
           ,bckdt_bpl.BPL_ATTRIBUTE28
           ,bckdt_bpl.BPL_ATTRIBUTE29
           ,bckdt_bpl.BPL_ATTRIBUTE30
           ,bckdt_bpl.LAST_UPDATE_DATE
           ,bckdt_bpl.LAST_UPDATED_BY
           ,bckdt_bpl.LAST_UPDATE_LOGIN
           ,bckdt_bpl.CREATED_BY
           ,bckdt_bpl.CREATION_DATE
           ,bckdt_bpl.OBJECT_VERSION_NUMBER
           ,bckdt_bpl.RLD_UP_VAL
           ,bckdt_bpl.PER_IN_LER_ID
    from   ben_bnft_prvdd_ldgr_f bckdt_bpl
    where bckdt_bpl.per_in_ler_id = p_bckdt_per_in_ler_id
      and bckdt_bpl.business_group_id  = p_business_group_id
      and bckdt_bpl.prtt_enrt_rslt_id = cp_bckdt_prtt_enrt_rslt_id
    union
    select
           bckdt_bpl.EFFECTIVE_END_DATE
           ,bckdt_bpl.BKUP_TBL_ID
           ,bckdt_bpl.EFFECTIVE_START_DATE
           ,bckdt_bpl.NO_LNGR_ELIG_FLAG -- Used for PRTT_RO_OF_UNUSD_AMT_FLAG
           ,bckdt_bpl.AMT_DSGD_VAL -- Used for FRFTD_VAL
           ,bckdt_bpl.ANN_RT_VAL   -- Used for PRVDD_VAL
           ,bckdt_bpl.CMCD_RT_VAL  -- Used for USED_VAL
           ,bckdt_bpl.RT_VAL       -- Used for CASH_RECD_VAL
           ,bckdt_bpl.COMP_LVL_FCTR_ID -- Used as BNFT_PRVDR_POOL_ID
           ,bckdt_bpl.ACTY_BASE_RT_ID
           ,bckdt_bpl.PRTT_ENRT_RSLT_ID
           ,bckdt_bpl.BUSINESS_GROUP_ID
           ,bckdt_bpl.LCR_ATTRIBUTE_CATEGORY
           ,bckdt_bpl.LCR_ATTRIBUTE1
           ,bckdt_bpl.LCR_ATTRIBUTE2
           ,bckdt_bpl.LCR_ATTRIBUTE3
           ,bckdt_bpl.LCR_ATTRIBUTE4
           ,bckdt_bpl.LCR_ATTRIBUTE5
           ,bckdt_bpl.LCR_ATTRIBUTE6
           ,bckdt_bpl.LCR_ATTRIBUTE7
           ,bckdt_bpl.LCR_ATTRIBUTE8
           ,bckdt_bpl.LCR_ATTRIBUTE9
           ,bckdt_bpl.LCR_ATTRIBUTE10
           ,bckdt_bpl.LCR_ATTRIBUTE11
           ,bckdt_bpl.LCR_ATTRIBUTE12
           ,bckdt_bpl.LCR_ATTRIBUTE13
           ,bckdt_bpl.LCR_ATTRIBUTE14
           ,bckdt_bpl.LCR_ATTRIBUTE15
           ,bckdt_bpl.LCR_ATTRIBUTE1
           ,bckdt_bpl.LCR_ATTRIBUTE17
           ,bckdt_bpl.LCR_ATTRIBUTE18
           ,bckdt_bpl.LCR_ATTRIBUTE19
           ,bckdt_bpl.LCR_ATTRIBUTE20
           ,bckdt_bpl.LCR_ATTRIBUTE21
           ,bckdt_bpl.LCR_ATTRIBUTE22
           ,bckdt_bpl.LCR_ATTRIBUTE23
           ,bckdt_bpl.LCR_ATTRIBUTE24
           ,bckdt_bpl.LCR_ATTRIBUTE25
           ,bckdt_bpl.LCR_ATTRIBUTE26
           ,bckdt_bpl.LCR_ATTRIBUTE27
           ,bckdt_bpl.LCR_ATTRIBUTE28
           ,bckdt_bpl.LCR_ATTRIBUTE29
           ,bckdt_bpl.LCR_ATTRIBUTE30
           ,bckdt_bpl.LAST_UPDATE_DATE
           ,bckdt_bpl.LAST_UPDATED_BY
           ,bckdt_bpl.LAST_UPDATE_LOGIN
           ,bckdt_bpl.CREATED_BY
           ,bckdt_bpl.CREATION_DATE
           ,bckdt_bpl.OBJECT_VERSION_NUMBER
           ,bckdt_bpl.VAL -- Used for RLD_UP_VAL
           ,bckdt_bpl.PER_IN_LER_ID
    from  ben_le_clsn_n_rstr bckdt_bpl
    where bckdt_bpl.per_in_ler_id = p_bckdt_per_in_ler_id
      and bckdt_bpl.business_group_id  = p_business_group_id
      and bckdt_bpl.prtt_enrt_rslt_id = cp_bckdt_prtt_enrt_rslt_id
      and bckdt_bpl.BKUP_TBL_TYP_CD   = 'BEN_BNFT_PRVDD_LDGR_F'
    order by 1;
  --
  cursor c_curr_bpl(cp_acty_base_rt_id    in number,
                    cp_bnft_prvdr_pool_id in number,
                    cp_prtt_enrt_rslt_id in number,
                    cp_effective_date in date) is
    select bpl.*
    from   ben_bnft_prvdd_ldgr_f  bpl
    where bpl.per_in_ler_id     = p_per_in_ler_id
      and bpl.prtt_enrt_rslt_id = cp_prtt_enrt_rslt_id
      --
      and cp_effective_date between bpl.effective_start_date
                              and bpl.effective_end_date
      and bpl.business_group_id  = p_business_group_id
      and bpl.acty_base_rt_id    = cp_acty_base_rt_id
      and nvl(bpl.bnft_prvdr_pool_id, -1)  = nvl(cp_bnft_prvdr_pool_id, -1);

  --
  l_curr_bpl_rec             c_curr_bpl%rowtype;
  l_datetrack_mode           varchar2(80);
  l_bpl_effective_start_date date;
  l_bpl_effective_end_date   date;
  l_bpl_object_version_number number;
  l_bnft_prvdd_ldgr_id       number;
  --
begin
 --
 hr_utility.set_location ('Entering '||l_proc,10);
 --
  for l_bckdt_pen_rec in c_bckdt_pen loop
   --
   for l_curr_pen_rec in c_curr_pen(l_bckdt_pen_rec.pl_id ,
                                    l_bckdt_pen_rec.oipl_id ,
                                    l_bckdt_pen_rec.pgm_id )
   loop
     --
     for bckdt_bpl_rec in c_bckdt_bpl(l_bckdt_pen_rec.prtt_enrt_rslt_id) loop
      --
      open c_curr_bpl(bckdt_bpl_rec.acty_base_rt_id,
                      bckdt_bpl_rec.bnft_prvdr_pool_id,
                      l_curr_pen_rec.prtt_enrt_rslt_id,
                      l_curr_pen_rec.effective_start_date);
      fetch c_curr_bpl into l_curr_bpl_rec;
      if c_curr_bpl%found then
         --
         -- If the corresponding record is found then is it different.
         -- If so then go and update it with the old values.
         --
         if bckdt_bpl_rec.PRTT_RO_OF_UNUSD_AMT_FLAG   <> l_curr_bpl_rec.PRTT_RO_OF_UNUSD_AMT_FLAG or
            bckdt_bpl_rec.FRFTD_VAL     <> l_curr_bpl_rec.FRFTD_VAL or
            bckdt_bpl_rec.PRVDD_VAL     <> l_curr_bpl_rec.PRVDD_VAL or
            bckdt_bpl_rec.USED_VAL      <> l_curr_bpl_rec.USED_VAL  or
            bckdt_bpl_rec.CASH_RECD_VAL <> l_curr_bpl_rec.CASH_RECD_VAL
         then
           --
           l_curr_bpl_rec.PRTT_RO_OF_UNUSD_AMT_FLAG := bckdt_bpl_rec.PRTT_RO_OF_UNUSD_AMT_FLAG;
           l_curr_bpl_rec.FRFTD_VAL := bckdt_bpl_rec.FRFTD_VAL;
           l_curr_bpl_rec.PRVDD_VAL := bckdt_bpl_rec.PRVDD_VAL;
           l_curr_bpl_rec.USED_VAL  := bckdt_bpl_rec.USED_VAL;
           l_curr_bpl_rec.CASH_RECD_VAL := bckdt_bpl_rec.CASH_RECD_VAL;
           --
           if l_curr_pen_rec.effective_start_date = l_curr_bpl_rec.effective_start_date  or
              l_curr_pen_rec.effective_start_date = l_curr_bpl_rec.effective_end_date
           then
              l_datetrack_mode := hr_api.g_correction;
           else
              l_datetrack_mode := hr_api.g_update;
           end if;
           --
           ben_Benefit_Prvdd_Ledger_api.update_Benefit_Prvdd_Ledger (
             p_bnft_prvdd_ldgr_id           => l_curr_bpl_rec.bnft_prvdd_ldgr_id
            ,p_effective_start_date         => l_bpl_effective_start_date
            ,p_effective_end_date           => l_bpl_effective_end_date
            ,p_object_version_number        => l_curr_bpl_rec.object_version_number
            ,p_prtt_ro_of_unusd_amt_flag    => l_curr_bpl_rec.prtt_ro_of_unusd_amt_flag
            ,p_frftd_val                    => l_curr_bpl_rec.frftd_val
            ,p_prvdd_val                    => l_curr_bpl_rec.prvdd_val
            ,p_used_val                     => l_curr_bpl_rec.used_val
            ,p_bnft_prvdr_pool_id           => l_curr_bpl_rec.bnft_prvdr_pool_id
            ,p_acty_base_rt_id              => l_curr_bpl_rec.acty_base_rt_id
            ,p_per_in_ler_id                => p_per_in_ler_id
            ,p_prtt_enrt_rslt_id            => l_curr_bpl_rec.prtt_enrt_rslt_id
            ,p_business_group_id            => p_business_group_id
            ,p_cash_recd_val                => l_curr_bpl_rec.cash_recd_val
            ,p_effective_date               => l_curr_pen_rec.effective_start_date
            ,p_datetrack_mode               => l_datetrack_mode
            ,p_process_enrt_flag             => 'Y'
            ,p_from_reinstate_enrt_flag     => 'Y'
           );
           --
         end if;
         --
      end if;
      close c_curr_bpl;
      --
     end loop;
   end loop;
 end loop;
 --
 hr_utility.set_location('Leaving:'|| l_proc, 10);
 --
end reinstate_bpl_per_pen;
--
procedure reinstate_ppr_per_pen(
                             p_person_id                in number
                            ,p_bckdt_prtt_enrt_rslt_id  in number
                            ,p_prtt_enrt_rslt_id        in number
                            ,p_business_group_id        in number
                            ,p_elig_cvrd_dpnt_id        in number
                            ,p_effective_date           in date
                            ,p_bckdt_elig_cvrd_dpnt_id  in number
                           ) is
  --
  l_proc                    varchar2(72) := g_package || '.reinstate_ppr_per_pen';
  --
  cursor c_old_ppr_pen is
  select
       ppr.EFFECTIVE_END_DATE
       ,ppr.PRMRY_CARE_PRVDR_ID
       ,ppr.EFFECTIVE_START_DATE
       ,ppr.PRMRY_CARE_PRVDR_TYP_CD
       ,ppr.NAME
       ,ppr.EXT_IDENT
       ,ppr.PRTT_ENRT_RSLT_ID
       ,ppr.ELIG_CVRD_DPNT_ID
       ,ppr.BUSINESS_GROUP_ID
       ,ppr.PPR_ATTRIBUTE_CATEGORY
       ,ppr.PPR_ATTRIBUTE1
       ,ppr.PPR_ATTRIBUTE2
       ,ppr.PPR_ATTRIBUTE3
       ,ppr.PPR_ATTRIBUTE4
       ,ppr.PPR_ATTRIBUTE5
       ,ppr.PPR_ATTRIBUTE6
       ,ppr.PPR_ATTRIBUTE7
       ,ppr.PPR_ATTRIBUTE8
       ,ppr.PPR_ATTRIBUTE9
       ,ppr.PPR_ATTRIBUTE10
       ,ppr.PPR_ATTRIBUTE11
       ,ppr.PPR_ATTRIBUTE12
       ,ppr.PPR_ATTRIBUTE13
       ,ppr.PPR_ATTRIBUTE14
       ,ppr.PPR_ATTRIBUTE15
       ,ppr.PPR_ATTRIBUTE16
       ,ppr.PPR_ATTRIBUTE17
       ,ppr.PPR_ATTRIBUTE18
       ,ppr.PPR_ATTRIBUTE19
       ,ppr.PPR_ATTRIBUTE20
       ,ppr.PPR_ATTRIBUTE21
       ,ppr.PPR_ATTRIBUTE22
       ,ppr.PPR_ATTRIBUTE23
       ,ppr.PPR_ATTRIBUTE24
       ,ppr.PPR_ATTRIBUTE25
       ,ppr.PPR_ATTRIBUTE26
       ,ppr.PPR_ATTRIBUTE27
       ,ppr.PPR_ATTRIBUTE28
       ,ppr.PPR_ATTRIBUTE29
       ,ppr.PPR_ATTRIBUTE30
       ,ppr.LAST_UPDATE_DATE
       ,ppr.LAST_UPDATED_BY
       ,ppr.LAST_UPDATE_LOGIN
       ,ppr.CREATED_BY
       ,ppr.CREATION_DATE
       ,ppr.REQUEST_ID
       ,ppr.PROGRAM_APPLICATION_ID
       ,ppr.PROGRAM_ID
       ,ppr.PROGRAM_UPDATE_DATE
       ,ppr.OBJECT_VERSION_NUMBER
    from ben_prmry_care_prvdr_f ppr
    where ppr.prtt_enrt_rslt_id = p_bckdt_prtt_enrt_rslt_id -- Bug 3709516
      and ppr.business_group_id = p_business_group_id
      and p_effective_date between ppr.effective_start_date and ppr.effective_end_date; --Added p_effective_date condition for Bug 7497016
--
  cursor c_old_ppr_pdp is
  select
       ppr.EFFECTIVE_END_DATE
       ,ppr.PRMRY_CARE_PRVDR_ID
       ,ppr.EFFECTIVE_START_DATE
       ,ppr.PRMRY_CARE_PRVDR_TYP_CD
       ,ppr.NAME
       ,ppr.EXT_IDENT
       ,ppr.PRTT_ENRT_RSLT_ID
       ,ppr.ELIG_CVRD_DPNT_ID
       ,ppr.BUSINESS_GROUP_ID
       ,ppr.PPR_ATTRIBUTE_CATEGORY
       ,ppr.PPR_ATTRIBUTE1
       ,ppr.PPR_ATTRIBUTE2
       ,ppr.PPR_ATTRIBUTE3
       ,ppr.PPR_ATTRIBUTE4
       ,ppr.PPR_ATTRIBUTE5
       ,ppr.PPR_ATTRIBUTE6
       ,ppr.PPR_ATTRIBUTE7
       ,ppr.PPR_ATTRIBUTE8
       ,ppr.PPR_ATTRIBUTE9
       ,ppr.PPR_ATTRIBUTE10
       ,ppr.PPR_ATTRIBUTE11
       ,ppr.PPR_ATTRIBUTE12
       ,ppr.PPR_ATTRIBUTE13
       ,ppr.PPR_ATTRIBUTE14
       ,ppr.PPR_ATTRIBUTE15
       ,ppr.PPR_ATTRIBUTE16
       ,ppr.PPR_ATTRIBUTE17
       ,ppr.PPR_ATTRIBUTE18
       ,ppr.PPR_ATTRIBUTE19
       ,ppr.PPR_ATTRIBUTE20
       ,ppr.PPR_ATTRIBUTE21
       ,ppr.PPR_ATTRIBUTE22
       ,ppr.PPR_ATTRIBUTE23
       ,ppr.PPR_ATTRIBUTE24
       ,ppr.PPR_ATTRIBUTE25
       ,ppr.PPR_ATTRIBUTE26
       ,ppr.PPR_ATTRIBUTE27
       ,ppr.PPR_ATTRIBUTE28
       ,ppr.PPR_ATTRIBUTE29
       ,ppr.PPR_ATTRIBUTE30
       ,ppr.LAST_UPDATE_DATE
       ,ppr.LAST_UPDATED_BY
       ,ppr.LAST_UPDATE_LOGIN
       ,ppr.CREATED_BY
       ,ppr.CREATION_DATE
       ,ppr.REQUEST_ID
       ,ppr.PROGRAM_APPLICATION_ID
       ,ppr.PROGRAM_ID
       ,ppr.PROGRAM_UPDATE_DATE
       ,ppr.OBJECT_VERSION_NUMBER
    from ben_prmry_care_prvdr_f ppr
    where ppr.elig_cvrd_dpnt_id = p_bckdt_elig_cvrd_dpnt_id -- Bug 3709516
      and ppr.business_group_id   = p_business_group_id ;

-- 5123666
CURSOR c_curr_ppr(c_prmry_care_prvdr_id in number)
   IS
      SELECT *
        FROM ben_prmry_care_prvdr_f ppr
       WHERE ppr.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         AND ppr.business_group_id = p_business_group_id
         AND ppr.prmry_care_prvdr_id = c_prmry_care_prvdr_id
         AND NVL (ppr.elig_cvrd_dpnt_id, -1) = NVL (p_elig_cvrd_dpnt_id, -1)
	 and p_effective_date between ppr.effective_start_date and ppr.effective_end_date; --Added p_effective_date condition for Bug 7497016

 --
  l_PRMRY_CARE_PRVDR_ID         number(15);
  l_ppr_effective_start_date    date;
  l_ppr_effective_end_date      date;
  l_ppr_object_version_number   number(9);
  -- 5123666
  l_curr_ppr                 c_curr_ppr%rowtype;
  l_datetrack_mode           varchar2(80);
  --
begin
  --
  hr_utility.set_location('Entering ' || l_proc,10);
  hr_utility.set_location('p_bckdt_prtt_enrt_rslt_id ' || p_bckdt_prtt_enrt_rslt_id,10);
  hr_utility.set_location('p_prtt_enrt_rslt_id ' || p_prtt_enrt_rslt_id,10);
  hr_utility.set_location('p_effective_date ' || p_effective_date,10);
  hr_utility.set_location('p_bckdt_elig_cvrd_dpnt_id ' || p_bckdt_elig_cvrd_dpnt_id,10);
  --
  -- for participant
  --
  IF  p_bckdt_prtt_enrt_rslt_id is not null
  and p_bckdt_elig_cvrd_dpnt_id is null
  then
  --
  FOR l_old_ppr_rec IN c_old_ppr_pen
  LOOP
      -- create the primary care provider records.
      -- 5123666
      OPEN c_curr_ppr (l_old_ppr_rec.prmry_care_prvdr_id
                      );
      FETCH c_curr_ppr INTO l_curr_ppr;

      IF c_curr_ppr%NOTFOUND
      THEN
         hr_utility.set_location('Reinstate Provider by Creating ',99099);
         ben_prmry_care_prvdr_api.create_prmry_care_prvdr (p_validate                     => FALSE,
                                                           p_prmry_care_prvdr_id          => l_prmry_care_prvdr_id,
                                                           p_effective_start_date         => l_ppr_effective_start_date,
                                                           p_effective_end_date           => l_ppr_effective_end_date,
                                                           p_name                         => l_old_ppr_rec.NAME,
                                                           p_ext_ident                    => l_old_ppr_rec.ext_ident,
                                                           p_prmry_care_prvdr_typ_cd      => l_old_ppr_rec.prmry_care_prvdr_typ_cd,
                                                           p_prtt_enrt_rslt_id            => p_prtt_enrt_rslt_id,
                                                           p_elig_cvrd_dpnt_id            => p_elig_cvrd_dpnt_id,
                                                           p_business_group_id            => p_business_group_id,
                                                           p_ppr_attribute_category       => l_old_ppr_rec.ppr_attribute_category,
                                                           p_ppr_attribute1               => l_old_ppr_rec.ppr_attribute1,
                                                           p_ppr_attribute2               => l_old_ppr_rec.ppr_attribute2,
                                                           p_ppr_attribute3               => l_old_ppr_rec.ppr_attribute3,
                                                           p_ppr_attribute4               => l_old_ppr_rec.ppr_attribute4,
                                                           p_ppr_attribute5               => l_old_ppr_rec.ppr_attribute5,
                                                           p_ppr_attribute6               => l_old_ppr_rec.ppr_attribute6,
                                                           p_ppr_attribute7               => l_old_ppr_rec.ppr_attribute7,
                                                           p_ppr_attribute8               => l_old_ppr_rec.ppr_attribute8,
                                                           p_ppr_attribute9               => l_old_ppr_rec.ppr_attribute9,
                                                           p_ppr_attribute10              => l_old_ppr_rec.ppr_attribute10,
                                                           p_ppr_attribute11              => l_old_ppr_rec.ppr_attribute11,
                                                           p_ppr_attribute12              => l_old_ppr_rec.ppr_attribute12,
                                                           p_ppr_attribute13              => l_old_ppr_rec.ppr_attribute13,
                                                           p_ppr_attribute14              => l_old_ppr_rec.ppr_attribute14,
                                                           p_ppr_attribute15              => l_old_ppr_rec.ppr_attribute15,
                                                           p_ppr_attribute16              => l_old_ppr_rec.ppr_attribute16,
                                                           p_ppr_attribute17              => l_old_ppr_rec.ppr_attribute17,
                                                           p_ppr_attribute18              => l_old_ppr_rec.ppr_attribute18,
                                                           p_ppr_attribute19              => l_old_ppr_rec.ppr_attribute19,
                                                           p_ppr_attribute20              => l_old_ppr_rec.ppr_attribute20,
                                                           p_ppr_attribute21              => l_old_ppr_rec.ppr_attribute21,
                                                           p_ppr_attribute22              => l_old_ppr_rec.ppr_attribute22,
                                                           p_ppr_attribute23              => l_old_ppr_rec.ppr_attribute23,
                                                           p_ppr_attribute24              => l_old_ppr_rec.ppr_attribute24,
                                                           p_ppr_attribute25              => l_old_ppr_rec.ppr_attribute25,
                                                           p_ppr_attribute26              => l_old_ppr_rec.ppr_attribute26,
                                                           p_ppr_attribute27              => l_old_ppr_rec.ppr_attribute27,
                                                           p_ppr_attribute28              => l_old_ppr_rec.ppr_attribute28,
                                                           p_ppr_attribute29              => l_old_ppr_rec.ppr_attribute29,
                                                           p_ppr_attribute30              => l_old_ppr_rec.ppr_attribute30,
                                                           p_request_id                   => l_old_ppr_rec.request_id,
                                                           p_program_application_id       => l_old_ppr_rec.program_application_id,
                                                           p_program_id                   => l_old_ppr_rec.program_id,
                                                           p_program_update_date          => l_old_ppr_rec.program_update_date,
                                                           p_object_version_number        => l_ppr_object_version_number,
                                                           p_effective_date               => p_effective_date      -- Bug : 5124 As per Jeana, data
                                                                                                              -- should be reinstated with system date
                                                                                                              -- rather than p_effective_date
                                                          );
      ELSE
         IF    l_curr_ppr.effective_start_date = l_old_ppr_rec.effective_start_date
            OR l_curr_ppr.effective_start_date = l_old_ppr_rec.effective_end_date
         THEN
            l_datetrack_mode := hr_api.g_correction;
         ELSE
            l_datetrack_mode := hr_api.g_update;
         END IF;
         hr_utility.set_location('Reinstate Provider by Updating in mode '||l_datetrack_mode,99099);
         ben_prmry_care_prvdr_api.update_prmry_care_prvdr (p_validate                     => FALSE,
                                                           p_prmry_care_prvdr_id          => l_old_ppr_rec.prmry_care_prvdr_id,
                                                           p_effective_start_date         => l_ppr_effective_start_date,
                                                           p_effective_end_date           => l_ppr_effective_end_date,
                                                           p_name                         => l_old_ppr_rec.NAME,
                                                           p_ext_ident                    => l_old_ppr_rec.ext_ident,
                                                           p_prmry_care_prvdr_typ_cd      => l_old_ppr_rec.prmry_care_prvdr_typ_cd,
                                                           p_prtt_enrt_rslt_id            => p_prtt_enrt_rslt_id,
                                                           p_elig_cvrd_dpnt_id            => p_elig_cvrd_dpnt_id,
                                                           p_business_group_id            => p_business_group_id,
                                                           p_ppr_attribute_category       => l_old_ppr_rec.ppr_attribute_category,
                                                           p_ppr_attribute1               => l_old_ppr_rec.ppr_attribute1,
                                                           p_ppr_attribute2               => l_old_ppr_rec.ppr_attribute2,
                                                           p_ppr_attribute3               => l_old_ppr_rec.ppr_attribute3,
                                                           p_ppr_attribute4               => l_old_ppr_rec.ppr_attribute4,
                                                           p_ppr_attribute5               => l_old_ppr_rec.ppr_attribute5,
                                                           p_ppr_attribute6               => l_old_ppr_rec.ppr_attribute6,
                                                           p_ppr_attribute7               => l_old_ppr_rec.ppr_attribute7,
                                                           p_ppr_attribute8               => l_old_ppr_rec.ppr_attribute8,
                                                           p_ppr_attribute9               => l_old_ppr_rec.ppr_attribute9,
                                                           p_ppr_attribute10              => l_old_ppr_rec.ppr_attribute10,
                                                           p_ppr_attribute11              => l_old_ppr_rec.ppr_attribute11,
                                                           p_ppr_attribute12              => l_old_ppr_rec.ppr_attribute12,
                                                           p_ppr_attribute13              => l_old_ppr_rec.ppr_attribute13,
                                                           p_ppr_attribute14              => l_old_ppr_rec.ppr_attribute14,
                                                           p_ppr_attribute15              => l_old_ppr_rec.ppr_attribute15,
                                                           p_ppr_attribute16              => l_old_ppr_rec.ppr_attribute16,
                                                           p_ppr_attribute17              => l_old_ppr_rec.ppr_attribute17,
                                                           p_ppr_attribute18              => l_old_ppr_rec.ppr_attribute18,
                                                           p_ppr_attribute19              => l_old_ppr_rec.ppr_attribute19,
                                                           p_ppr_attribute20              => l_old_ppr_rec.ppr_attribute20,
                                                           p_ppr_attribute21              => l_old_ppr_rec.ppr_attribute21,
                                                           p_ppr_attribute22              => l_old_ppr_rec.ppr_attribute22,
                                                           p_ppr_attribute23              => l_old_ppr_rec.ppr_attribute23,
                                                           p_ppr_attribute24              => l_old_ppr_rec.ppr_attribute24,
                                                           p_ppr_attribute25              => l_old_ppr_rec.ppr_attribute25,
                                                           p_ppr_attribute26              => l_old_ppr_rec.ppr_attribute26,
                                                           p_ppr_attribute27              => l_old_ppr_rec.ppr_attribute27,
                                                           p_ppr_attribute28              => l_old_ppr_rec.ppr_attribute28,
                                                           p_ppr_attribute29              => l_old_ppr_rec.ppr_attribute29,
                                                           p_ppr_attribute30              => l_old_ppr_rec.ppr_attribute30,
                                                           p_request_id                   => l_old_ppr_rec.request_id,
                                                           p_program_application_id       => l_old_ppr_rec.program_application_id,
                                                           p_program_id                   => l_old_ppr_rec.program_id,
                                                           p_program_update_date          => l_old_ppr_rec.program_update_date,
                                                           p_object_version_number        => l_old_ppr_rec.object_version_number,
                                                           p_effective_date               => p_effective_date,
                                                           p_datetrack_mode               => l_datetrack_mode
                                                          );
      END IF;   -- main if
              --
  END LOOP;
  --
  END IF;
  --
  hr_utility.set_location('after participant ' || l_proc,20);
  -- for dependent
  --
  IF  p_bckdt_prtt_enrt_rslt_id is null
  and p_bckdt_elig_cvrd_dpnt_id is not null
  then
  --
  FOR l_old_ppr_rec IN c_old_ppr_pdp
  LOOP
      -- create the primary care provider records.
      -- 5123666
      OPEN c_curr_ppr (l_old_ppr_rec.prmry_care_prvdr_id
                      );
      FETCH c_curr_ppr INTO l_curr_ppr;

      IF c_curr_ppr%NOTFOUND
      THEN
         hr_utility.set_location('Reinstate Provider by Creating ',99099);
         ben_prmry_care_prvdr_api.create_prmry_care_prvdr (p_validate                     => FALSE,
                                                           p_prmry_care_prvdr_id          => l_prmry_care_prvdr_id,
                                                           p_effective_start_date         => l_ppr_effective_start_date,
                                                           p_effective_end_date           => l_ppr_effective_end_date,
                                                           p_name                         => l_old_ppr_rec.NAME,
                                                           p_ext_ident                    => l_old_ppr_rec.ext_ident,
                                                           p_prmry_care_prvdr_typ_cd      => l_old_ppr_rec.prmry_care_prvdr_typ_cd,
                                                           p_prtt_enrt_rslt_id            => p_prtt_enrt_rslt_id,
                                                           p_elig_cvrd_dpnt_id            => p_elig_cvrd_dpnt_id,
                                                           p_business_group_id            => p_business_group_id,
                                                           p_ppr_attribute_category       => l_old_ppr_rec.ppr_attribute_category,
                                                           p_ppr_attribute1               => l_old_ppr_rec.ppr_attribute1,
                                                           p_ppr_attribute2               => l_old_ppr_rec.ppr_attribute2,
                                                           p_ppr_attribute3               => l_old_ppr_rec.ppr_attribute3,
                                                           p_ppr_attribute4               => l_old_ppr_rec.ppr_attribute4,
                                                           p_ppr_attribute5               => l_old_ppr_rec.ppr_attribute5,
                                                           p_ppr_attribute6               => l_old_ppr_rec.ppr_attribute6,
                                                           p_ppr_attribute7               => l_old_ppr_rec.ppr_attribute7,
                                                           p_ppr_attribute8               => l_old_ppr_rec.ppr_attribute8,
                                                           p_ppr_attribute9               => l_old_ppr_rec.ppr_attribute9,
                                                           p_ppr_attribute10              => l_old_ppr_rec.ppr_attribute10,
                                                           p_ppr_attribute11              => l_old_ppr_rec.ppr_attribute11,
                                                           p_ppr_attribute12              => l_old_ppr_rec.ppr_attribute12,
                                                           p_ppr_attribute13              => l_old_ppr_rec.ppr_attribute13,
                                                           p_ppr_attribute14              => l_old_ppr_rec.ppr_attribute14,
                                                           p_ppr_attribute15              => l_old_ppr_rec.ppr_attribute15,
                                                           p_ppr_attribute16              => l_old_ppr_rec.ppr_attribute16,
                                                           p_ppr_attribute17              => l_old_ppr_rec.ppr_attribute17,
                                                           p_ppr_attribute18              => l_old_ppr_rec.ppr_attribute18,
                                                           p_ppr_attribute19              => l_old_ppr_rec.ppr_attribute19,
                                                           p_ppr_attribute20              => l_old_ppr_rec.ppr_attribute20,
                                                           p_ppr_attribute21              => l_old_ppr_rec.ppr_attribute21,
                                                           p_ppr_attribute22              => l_old_ppr_rec.ppr_attribute22,
                                                           p_ppr_attribute23              => l_old_ppr_rec.ppr_attribute23,
                                                           p_ppr_attribute24              => l_old_ppr_rec.ppr_attribute24,
                                                           p_ppr_attribute25              => l_old_ppr_rec.ppr_attribute25,
                                                           p_ppr_attribute26              => l_old_ppr_rec.ppr_attribute26,
                                                           p_ppr_attribute27              => l_old_ppr_rec.ppr_attribute27,
                                                           p_ppr_attribute28              => l_old_ppr_rec.ppr_attribute28,
                                                           p_ppr_attribute29              => l_old_ppr_rec.ppr_attribute29,
                                                           p_ppr_attribute30              => l_old_ppr_rec.ppr_attribute30,
                                                           p_request_id                   => l_old_ppr_rec.request_id,
                                                           p_program_application_id       => l_old_ppr_rec.program_application_id,
                                                           p_program_id                   => l_old_ppr_rec.program_id,
                                                           p_program_update_date          => l_old_ppr_rec.program_update_date,
                                                           p_object_version_number        => l_ppr_object_version_number,
                                                           p_effective_date               => p_effective_date      -- Bug : 5124 As per Jeana, data
                                                                                                              -- should be reinstated with system date
                                                                                                              -- rather than p_effective_date
                                                          );
      ELSE
         IF    l_curr_ppr.effective_start_date = l_old_ppr_rec.effective_start_date
            OR l_curr_ppr.effective_start_date = l_old_ppr_rec.effective_end_date
         THEN
            l_datetrack_mode := hr_api.g_correction;
         ELSE
            l_datetrack_mode := hr_api.g_update;
         END IF;
         hr_utility.set_location('Reinstate Provider by Updating in mode '||l_datetrack_mode,99099);
         ben_prmry_care_prvdr_api.update_prmry_care_prvdr (p_validate                     => FALSE,
                                                           p_prmry_care_prvdr_id          => l_old_ppr_rec.prmry_care_prvdr_id,
                                                           p_effective_start_date         => l_ppr_effective_start_date,
                                                           p_effective_end_date           => l_ppr_effective_end_date,
                                                           p_name                         => l_old_ppr_rec.NAME,
                                                           p_ext_ident                    => l_old_ppr_rec.ext_ident,
                                                           p_prmry_care_prvdr_typ_cd      => l_old_ppr_rec.prmry_care_prvdr_typ_cd,
                                                           p_prtt_enrt_rslt_id            => p_prtt_enrt_rslt_id,
                                                           p_elig_cvrd_dpnt_id            => p_elig_cvrd_dpnt_id,
                                                           p_business_group_id            => p_business_group_id,
                                                           p_ppr_attribute_category       => l_old_ppr_rec.ppr_attribute_category,
                                                           p_ppr_attribute1               => l_old_ppr_rec.ppr_attribute1,
                                                           p_ppr_attribute2               => l_old_ppr_rec.ppr_attribute2,
                                                           p_ppr_attribute3               => l_old_ppr_rec.ppr_attribute3,
                                                           p_ppr_attribute4               => l_old_ppr_rec.ppr_attribute4,
                                                           p_ppr_attribute5               => l_old_ppr_rec.ppr_attribute5,
                                                           p_ppr_attribute6               => l_old_ppr_rec.ppr_attribute6,
                                                           p_ppr_attribute7               => l_old_ppr_rec.ppr_attribute7,
                                                           p_ppr_attribute8               => l_old_ppr_rec.ppr_attribute8,
                                                           p_ppr_attribute9               => l_old_ppr_rec.ppr_attribute9,
                                                           p_ppr_attribute10              => l_old_ppr_rec.ppr_attribute10,
                                                           p_ppr_attribute11              => l_old_ppr_rec.ppr_attribute11,
                                                           p_ppr_attribute12              => l_old_ppr_rec.ppr_attribute12,
                                                           p_ppr_attribute13              => l_old_ppr_rec.ppr_attribute13,
                                                           p_ppr_attribute14              => l_old_ppr_rec.ppr_attribute14,
                                                           p_ppr_attribute15              => l_old_ppr_rec.ppr_attribute15,
                                                           p_ppr_attribute16              => l_old_ppr_rec.ppr_attribute16,
                                                           p_ppr_attribute17              => l_old_ppr_rec.ppr_attribute17,
                                                           p_ppr_attribute18              => l_old_ppr_rec.ppr_attribute18,
                                                           p_ppr_attribute19              => l_old_ppr_rec.ppr_attribute19,
                                                           p_ppr_attribute20              => l_old_ppr_rec.ppr_attribute20,
                                                           p_ppr_attribute21              => l_old_ppr_rec.ppr_attribute21,
                                                           p_ppr_attribute22              => l_old_ppr_rec.ppr_attribute22,
                                                           p_ppr_attribute23              => l_old_ppr_rec.ppr_attribute23,
                                                           p_ppr_attribute24              => l_old_ppr_rec.ppr_attribute24,
                                                           p_ppr_attribute25              => l_old_ppr_rec.ppr_attribute25,
                                                           p_ppr_attribute26              => l_old_ppr_rec.ppr_attribute26,
                                                           p_ppr_attribute27              => l_old_ppr_rec.ppr_attribute27,
                                                           p_ppr_attribute28              => l_old_ppr_rec.ppr_attribute28,
                                                           p_ppr_attribute29              => l_old_ppr_rec.ppr_attribute29,
                                                           p_ppr_attribute30              => l_old_ppr_rec.ppr_attribute30,
                                                           p_request_id                   => l_old_ppr_rec.request_id,
                                                           p_program_application_id       => l_old_ppr_rec.program_application_id,
                                                           p_program_id                   => l_old_ppr_rec.program_id,
                                                           p_program_update_date          => l_old_ppr_rec.program_update_date,
                                                           p_object_version_number        => l_old_ppr_rec.object_version_number,
                                                           p_effective_date               => p_effective_date,
                                                           p_datetrack_mode               => l_datetrack_mode
                                                          );
      END IF;   -- main if
              --
  END LOOP;
  --
  END IF;
  --
  hr_utility.set_location('Leaving ' || l_proc,30);
  --
end reinstate_ppr_per_pen;
--
procedure reinstate_pea_per_pen(
                             p_person_id                in number
                            ,p_bckdt_prtt_enrt_rslt_id  in number
                            ,p_prtt_enrt_rslt_id        in number
                            ,p_rslt_object_version_number in number
                            ,p_business_group_id        in number
                            ,p_per_in_ler_id            in number
                            ,p_effective_date           in date
                            ,p_bckdt_per_in_ler_id      in number
                            ,p_pl_bnf_id                in number default null
                            ,p_elig_cvrd_dpnt_id        in number default null
                            ,p_old_pl_bnf_id            in number default null
                            ,p_old_elig_cvrd_dpnt_id    in number default null
                           ) is
  --
  l_proc                    varchar2(72) := g_package || '.reinstate_pea_per_pen';
  --
  --BUG 4502165
  --When the certification is made on a later date, we need to take the latest record
  --otherwise pea record will not have the CMPLTD_DT.
  --
  cursor c_old_pea is
  select pea.CMPLTD_DT,
         pea.ACTN_TYP_ID
    from ben_prtt_enrt_actn_f pea
    where pea.per_in_ler_id       = p_bckdt_per_in_ler_id
      and pea.prtt_enrt_rslt_id   = p_bckdt_prtt_enrt_rslt_id
      and pea.business_group_id   = p_business_group_id
      and nvl(pea.pl_bnf_id, -1)  = nvl(p_old_pl_bnf_id, -1)
      and nvl(pea.elig_cvrd_dpnt_id, -1) = nvl(p_old_elig_cvrd_dpnt_id, -1)
      and pea.effective_end_date = hr_api.g_eot  --BUG 4502165 fix
     --  and pea.PL_BNF_ID is null
     --  and pea.ELIG_CVRD_DPNT_ID is null
  union
  select pea.OVRDN_THRU_DT, -- used as pea.CMPLTD_DT
         pea.PL_TYP_ID -- used as ACTN_TYP_ID
    from ben_le_clsn_n_rstr pea
   where pea.prtt_enrt_rslt_id = p_bckdt_prtt_enrt_rslt_id
     and pea.business_group_id = p_business_group_id
     and pea.per_in_ler_id     = p_bckdt_per_in_ler_id
     and p_effective_date between pea.effective_start_date
                              and pea.effective_end_date
     and nvl(pea.enrt_bnft_id, -1)  = nvl(p_old_pl_bnf_id, -1)
              -- enrt_bnft_id used as PL_BNF_ID
     and nvl(pea.dpnt_person_id, -1) = nvl(p_old_elig_cvrd_dpnt_id, -1)
              -- dpnt_person_id used as elig_cvrd_dpnt_id
     -- and pea.ENRT_BNFT_ID is null -- used as pea.PL_BNF_ID
     -- and pea.DPNT_PERSON_ID is null -- used as ELIG_CVRD_DPNT_ID is null
     and pea.bkup_tbl_typ_cd = 'BEN_PRTT_ENRT_ACTN_F'
     order by 1; -- pbn.effective_end_date; -- Low to High
  --
  l_prtt_enrt_actn_id           number(15);
  l_pea_effective_start_date    date;
  l_pea_effective_end_date      date;
  l_pea_object_version_number   number(9);
  --
  cursor c_pea(cp_actn_typ_id in number) is
  select pea.*
    from ben_prtt_enrt_actn_f pea
   where pea.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pea.actn_typ_id     = cp_actn_typ_id
     and pea.business_group_id = p_business_group_id
     and pea.per_in_ler_id     = p_per_in_ler_id
     and nvl(pea.PL_BNF_ID, -1) = nvl(p_PL_BNF_ID, -1)
     and nvl(pea.ELIG_CVRD_DPNT_ID, -1) = nvl(p_ELIG_CVRD_DPNT_ID, -1)
     -- and pea.PL_BNF_ID is null
     -- and pea.ELIG_CVRD_DPNT_ID is null
     --
     and p_effective_date between pea.effective_start_date
                              and pea.effective_end_date;
  --
  l_pea_rec               c_pea%rowtype;
  l_datetrack_mode        varchar2(80) := null;
  l_rslt_ovn              number;
  --
begin
  --
  hr_utility.set_location('Entering benleclr' || l_proc,10);
  --
  for l_old_pea_rec in c_old_pea loop
      --
      open c_pea(l_old_pea_rec.actn_typ_id);
      fetch c_pea into l_pea_rec;
      if c_pea%found then
        --
        if nvl(l_old_pea_rec.CMPLTD_DT, hr_api.g_eot) <> nvl(l_pea_rec.CMPLTD_DT, hr_api.g_eot)
        then
           --
           -- Use the correction mode.
           l_datetrack_mode := hr_api.g_correction;
           --
           -- update the action items.
           --
           -- If completion date is > p_effective_date .
           --
           /* BUG 4558512
           if l_old_pea_rec.CMPLTD_DT > p_effective_date then
              l_old_pea_rec.CMPLTD_DT := p_effective_date;
           end if;
           */
           --
           l_rslt_ovn := p_rslt_object_version_number;
           --
           ben_prtt_enrt_actn_api.update_prtt_enrt_actn
             (p_cmpltd_dt                  => l_old_pea_rec.CMPLTD_DT
             ,p_prtt_enrt_actn_id          => l_pea_rec.prtt_enrt_actn_id
             ,p_prtt_enrt_rslt_id          => l_pea_rec.prtt_enrt_rslt_id
             ,p_rslt_object_version_number => l_rslt_ovn
             ,p_actn_typ_id                => l_pea_rec.actn_typ_id
             ,p_rqd_flag                   => l_pea_rec.rqd_flag
             ,p_effective_date             => p_effective_date
             ,p_post_rslt_flag             => 'Y' -- p_post_rslt_flag
             ,p_business_group_id          => p_business_group_id
             ,p_effective_start_date       => l_pea_effective_start_date
             ,p_effective_end_date         => l_pea_effective_end_date
             ,p_object_version_number      => l_pea_rec.object_version_number
             ,p_datetrack_mode             => l_datetrack_mode
             );
           --
           --
        end if;
        --
      end if;
      --
      close c_pea;
  end loop;
  --
  hr_utility.set_location('Leaving ' || l_proc,10);
  --
end reinstate_pea_per_pen;

procedure reinstate_cpp_per_pdp(
                             p_person_id                in number
                            ,p_bckdt_prtt_enrt_rslt_id  in number
                            ,p_prtt_enrt_rslt_id        in number
                            ,p_business_group_id        in number
                            ,p_per_in_ler_id            in number
                            ,p_effective_date           in date
                            ,p_bckdt_per_in_ler_id      in number
                            ,p_elig_cvrd_dpnt_id        in number default null
                            ,p_old_elig_cvrd_dpnt_id    in number default null
                           ) is
  --
  l_proc          varchar2(72) :=  g_package ||'.reinstate_cpp_per_pdp';
  --
  cursor c_old_cpp is
  select cpp.DPNT_DSGN_CTFN_RECD_DT,
         pea.ACTN_TYP_ID,
         cpp.DPNT_DSGN_CTFN_TYP_CD
    from ben_prtt_enrt_actn_f pea,
         ben_cvrd_dpnt_ctfn_prvdd_f cpp
    where pea.per_in_ler_id       = p_bckdt_per_in_ler_id
      and pea.prtt_enrt_rslt_id   = p_bckdt_prtt_enrt_rslt_id
      and pea.business_group_id   = p_business_group_id
      and pea.elig_cvrd_dpnt_id   = p_old_elig_cvrd_dpnt_id
      and cpp.PRTT_ENRT_ACTN_ID   = pea.PRTT_ENRT_ACTN_ID
      and pea.elig_cvrd_dpnt_id   = p_old_elig_cvrd_dpnt_id
      and cpp.elig_cvrd_dpnt_id   = p_old_elig_cvrd_dpnt_id
     --  and pea.PL_BNF_ID is null
     --  and pea.ELIG_CVRD_DPNT_ID is null
     order by 1; -- pbn.effective_end_date; -- Low to High
  --
  l_prtt_enrt_actn_id           number(15);
  l_cpp_effective_start_date    date;
  l_cpp_effective_end_date      date;
  l_cpp_object_version_number   number(9);
  --
  cursor c_cpp(cp_actn_typ_id in number,
               cp_DPNT_DSGN_CTFN_TYP_CD in varchar2) is
  select cpp.*
    from ben_prtt_enrt_actn_f pea,
         ben_cvrd_dpnt_ctfn_prvdd_f cpp
   where pea.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pea.actn_typ_id       = cp_actn_typ_id
     and pea.business_group_id = p_business_group_id
     and pea.per_in_ler_id     = p_per_in_ler_id
     and cpp.PRTT_ENRT_ACTN_ID = pea.PRTT_ENRT_ACTN_ID
     and pea.ELIG_CVRD_DPNT_ID = p_elig_cvrd_dpnt_id
     and cpp.elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
     and cpp.DPNT_DSGN_CTFN_TYP_CD = cp_DPNT_DSGN_CTFN_TYP_CD
     --
     and p_effective_date between pea.effective_start_date
                        and pea.effective_end_date
     and p_effective_date between cpp.effective_start_date
                        and cpp.effective_end_date;
     -- and p_effective_date between pea.effective_start_date
     --                          and pea.effective_end_date;
  --
  l_cpp_rec               c_cpp%rowtype;
  l_datetrack_mode        varchar2(80) := null;
  --
begin
  --
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  for l_old_cpp_rec in c_old_cpp loop
      --
      open c_cpp(l_old_cpp_rec.actn_typ_id, l_old_cpp_rec.dpnt_dsgn_ctfn_typ_cd);
      fetch c_cpp into l_cpp_rec;
      if c_cpp%found then
        --
        if nvl(l_old_cpp_rec.DPNT_DSGN_CTFN_RECD_DT, hr_api.g_eot) <>
           nvl(l_cpp_rec.DPNT_DSGN_CTFN_RECD_DT, hr_api.g_eot)
        then
           --
           -- Use the correction mode.
           -- update the dependent certification received.
           --
           l_datetrack_mode := hr_api.g_correction;
           --
           if l_old_cpp_rec.DPNT_DSGN_CTFN_RECD_DT < p_effective_date then
              l_old_cpp_rec.DPNT_DSGN_CTFN_RECD_DT := p_effective_date;
           end if;
           --
              BEN_cvrd_dpnt_ctfn_prvdd_API.update_cvrd_dpnt_ctfn_prvdd
                 (p_validate => FALSE
                 ,p_CVRD_DPNT_CTFN_PRVDD_ID  => l_cpp_rec.CVRD_DPNT_CTFN_PRVDD_ID
                 ,p_EFFECTIVE_START_DATE     => l_cpp_EFFECTIVE_START_DATE
                 ,p_EFFECTIVE_END_DATE       => l_cpp_EFFECTIVE_END_DATE
                 ,p_DPNT_DSGN_CTFN_TYP_CD    => l_cpp_rec.DPNT_DSGN_CTFN_TYP_CD
                 ,p_DPNT_DSGN_CTFN_RQD_FLAG  => l_cpp_rec.DPNT_DSGN_CTFN_RQD_FLAG
                 ,p_DPNT_DSGN_CTFN_RECD_DT   => l_old_cpp_rec.DPNT_DSGN_CTFN_RECD_DT
                 ,p_ELIG_CVRD_DPNT_ID        => l_cpp_rec.ELIG_CVRD_DPNT_ID
                 ,p_prtt_enrt_actn_id        => l_cpp_rec.PRTT_ENRT_ACTN_ID
                 ,p_BUSINESS_GROUP_ID        => l_cpp_rec.BUSINESS_GROUP_ID
                 ,p_CCP_ATTRIBUTE_CATEGORY   => l_cpp_rec.CCP_ATTRIBUTE_CATEGORY
                 ,p_CCP_ATTRIBUTE1           => l_cpp_rec.CCP_ATTRIBUTE1
                 ,p_CCP_ATTRIBUTE2           => l_cpp_rec.CCP_ATTRIBUTE2
                 ,p_CCP_ATTRIBUTE3           => l_cpp_rec.CCP_ATTRIBUTE3
                 ,p_CCP_ATTRIBUTE4           => l_cpp_rec.CCP_ATTRIBUTE4
                 ,p_CCP_ATTRIBUTE5           => l_cpp_rec.CCP_ATTRIBUTE5
                 ,p_CCP_ATTRIBUTE6           => l_cpp_rec.CCP_ATTRIBUTE6
                 ,p_CCP_ATTRIBUTE7           => l_cpp_rec.CCP_ATTRIBUTE7
                 ,p_CCP_ATTRIBUTE8           => l_cpp_rec.CCP_ATTRIBUTE8
                 ,p_CCP_ATTRIBUTE9           => l_cpp_rec.CCP_ATTRIBUTE9
                 ,p_CCP_ATTRIBUTE10           => l_cpp_rec.CCP_ATTRIBUTE10
                 ,p_CCP_ATTRIBUTE11           => l_cpp_rec.CCP_ATTRIBUTE11
                 ,p_CCP_ATTRIBUTE12           => l_cpp_rec.CCP_ATTRIBUTE12
                 ,p_CCP_ATTRIBUTE13           => l_cpp_rec.CCP_ATTRIBUTE13
                 ,p_CCP_ATTRIBUTE14           => l_cpp_rec.CCP_ATTRIBUTE14
                 ,p_CCP_ATTRIBUTE15           => l_cpp_rec.CCP_ATTRIBUTE15
                 ,p_CCP_ATTRIBUTE16           => l_cpp_rec.CCP_ATTRIBUTE16
                 ,p_CCP_ATTRIBUTE17           => l_cpp_rec.CCP_ATTRIBUTE17
                 ,p_CCP_ATTRIBUTE18           => l_cpp_rec.CCP_ATTRIBUTE18
                 ,p_CCP_ATTRIBUTE19           => l_cpp_rec.CCP_ATTRIBUTE19
                 ,p_CCP_ATTRIBUTE20           => l_cpp_rec.CCP_ATTRIBUTE20
                 ,p_CCP_ATTRIBUTE21           => l_cpp_rec.CCP_ATTRIBUTE21
                 ,p_CCP_ATTRIBUTE22           => l_cpp_rec.CCP_ATTRIBUTE22
                 ,p_CCP_ATTRIBUTE23           => l_cpp_rec.CCP_ATTRIBUTE23
                 ,p_CCP_ATTRIBUTE24           => l_cpp_rec.CCP_ATTRIBUTE24
                 ,p_CCP_ATTRIBUTE25           => l_cpp_rec.CCP_ATTRIBUTE25
                 ,p_CCP_ATTRIBUTE26           => l_cpp_rec.CCP_ATTRIBUTE26
                 ,p_CCP_ATTRIBUTE27           => l_cpp_rec.CCP_ATTRIBUTE27
                 ,p_CCP_ATTRIBUTE28           => l_cpp_rec.CCP_ATTRIBUTE28
                 ,p_CCP_ATTRIBUTE29           => l_cpp_rec.CCP_ATTRIBUTE29
                 ,p_CCP_ATTRIBUTE30           => l_cpp_rec.CCP_ATTRIBUTE30
                 ,p_request_id                => l_cpp_rec.REQUEST_ID
                 ,p_program_application_id    => l_cpp_rec.PROGRAM_APPLICATION_ID
                 ,p_program_id                => l_cpp_rec.PROGRAM_ID
                 ,p_program_update_date       => l_cpp_rec.PROGRAM_UPDATE_DATE
                 ,p_OBJECT_VERSION_NUMBER     => l_cpp_rec.OBJECT_VERSION_NUMBER
                 ,p_effective_date            => p_effective_date
                 ,p_datetrack_mode            => l_datetrack_mode
                 );
           --
        end if;
        --
      end if;
      --
      close c_cpp;
  end loop;
  --
  hr_utility.set_location('Leaving ' || l_proc,10);
  --
end reinstate_cpp_per_pdp;
--
-- This procedure creates the enrollment results based on what participant
-- enrolled as of the backed out per in ler.
--
procedure reinstate_dpnts_per_pen(
                             p_person_id                in number
                            ,p_bckdt_prtt_enrt_rslt_id  in number
                            ,p_prtt_enrt_rslt_id        in number
                            ,p_pen_ovn_number           in out nocopy number
                            ,p_old_pl_id                in number default null
                            ,p_new_pl_id                in number default null
                            ,p_old_oipl_id              in number default null
                            ,p_new_oipl_id              in number default null
                            ,p_old_pl_typ_id            in number default null
                            ,p_new_pl_typ_id            in number default null
                            ,p_pgm_id                   in number default null
                            ,p_ler_id                   in number default null
                            ,p_elig_per_elctbl_chc_id   in number
                            ,p_business_group_id        in number
                            ,p_effective_date           in date
                            ,p_per_in_ler_id            in number
                            ,p_bckdt_per_in_ler_id      in number
                            ,p_dpnt_cvg_strt_dt_cd      in varchar2
                            ,p_dpnt_cvg_strt_dt_rl      in number
                            ,p_enrt_cvg_strt_dt         in date
                           ) is
  --
  l_proc                    varchar2(72) := g_package||'.reinstate_dpnts_per_pen';
  --
  -- Cursor to fetch all the depenedents attched to the backed out
  -- enrollment result.
  --
  cursor c_bckdt_pen_dpnts is
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
    where pdp_old.per_in_ler_id       = p_bckdt_per_in_ler_id
      and pdp_old.prtt_enrt_rslt_id   = p_bckdt_prtt_enrt_rslt_id
      and pdp_old.business_group_id   = p_business_group_id
    union
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
                pdp_old.LCR_ATTRIBUTE_CATEGORY,
                pdp_old.LCR_ATTRIBUTE1,
                pdp_old.LCR_ATTRIBUTE2,
                pdp_old.LCR_ATTRIBUTE3,
                pdp_old.LCR_ATTRIBUTE4,
                pdp_old.LCR_ATTRIBUTE5,
                pdp_old.LCR_ATTRIBUTE6,
                pdp_old.LCR_ATTRIBUTE7,
                pdp_old.LCR_ATTRIBUTE8,
                pdp_old.LCR_ATTRIBUTE9,
                pdp_old.LCR_ATTRIBUTE10,
                pdp_old.LCR_ATTRIBUTE11,
                pdp_old.LCR_ATTRIBUTE12,
                pdp_old.LCR_ATTRIBUTE13,
                pdp_old.LCR_ATTRIBUTE14,
                pdp_old.LCR_ATTRIBUTE15,
                pdp_old.LCR_ATTRIBUTE16,
                pdp_old.LCR_ATTRIBUTE17,
                pdp_old.LCR_ATTRIBUTE18,
                pdp_old.LCR_ATTRIBUTE19,
                pdp_old.LCR_ATTRIBUTE20,
                pdp_old.LCR_ATTRIBUTE21,
                pdp_old.LCR_ATTRIBUTE22,
                pdp_old.LCR_ATTRIBUTE23,
                pdp_old.LCR_ATTRIBUTE24,
                pdp_old.LCR_ATTRIBUTE25,
                pdp_old.LCR_ATTRIBUTE26,
                pdp_old.LCR_ATTRIBUTE27,
                pdp_old.LCR_ATTRIBUTE28,
                pdp_old.LCR_ATTRIBUTE29,
                pdp_old.LCR_ATTRIBUTE30,
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
                pdp_old.BKUP_TBL_ID,
                pdp_old.EFFECTIVE_START_DATE
    from   ben_le_clsn_n_rstr pdp_old
    where  pdp_old.per_in_ler_id       = p_bckdt_per_in_ler_id
    and    pdp_old.prtt_enrt_rslt_id   = p_bckdt_prtt_enrt_rslt_id
    and    pdp_old.business_group_id   = p_business_group_id
    and    pdp_old.bkup_tbl_typ_cd     = 'BEN_ELIG_CVRD_DPNT_F'
    order by 1; -- pdp_old.effective_end_date; -- Low to High
  --
  --5692797
  cursor c_chk_valid_pdp(p_elig_cvrd_dpnt_id number) is
    select 'Y'
    from   ben_elig_cvrd_dpnt_f pdp_old
    where  pdp_old.elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
    and    pdp_old.prtt_enrt_rslt_id = p_bckdt_prtt_enrt_rslt_id
    and    (pdp_old.effective_end_date = hr_api.g_eot or
            pdp_old.effective_end_date = (select max(effective_end_date)
                                          from ben_elig_cvrd_dpnt_f
                                          where elig_cvrd_dpnt_id = pdp_old.elig_cvrd_dpnt_id
                                          and prtt_enrt_rslt_id = pdp_old.prtt_enrt_rslt_id))
    and    (pdp_old.cvg_thru_dt is null or pdp_old.cvg_thru_dt = hr_api.g_eot)
    union
    select 'Y'
    from   ben_le_clsn_n_rstr pdp_old
    where  pdp_old.bkup_tbl_id = p_elig_cvrd_dpnt_id
    and    pdp_old.bkup_tbl_typ_cd = 'BEN_ELIG_CVRD_DPNT_F'
    and    pdp_old.prtt_enrt_rslt_id = p_bckdt_prtt_enrt_rslt_id
    and    ((pdp_old.cvg_thru_dt is null or pdp_old.cvg_thru_dt = hr_api.g_eot)  and
            pdp_old.effective_end_date = hr_api.g_eot
           );
  --
  l_chk_valid_pdp char;
  --
  cursor c_pen_dpnts(cp_dpnt_person_id in number) is
  select pdp.*
    from ben_elig_cvrd_dpnt_f pdp ,
         ben_per_in_ler pil
   where pdp.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pdp.cvg_strt_dt is not null
     and nvl(pdp.cvg_thru_dt, hr_api.g_eot) = hr_api.g_eot
     and pdp.business_group_id = p_business_group_id
     and pdp.dpnt_person_id    = cp_dpnt_person_id
     and p_effective_date between pdp.effective_start_date
                              and pdp.effective_end_date
     and pdp.per_in_ler_id =  pil.per_in_ler_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  l_pen_dpnts_rec               c_pen_dpnts%rowtype;
  --
  --
  cursor c_epe_dpnt(cp_dpnt_person_id in number) is
  select edg.*
  from ben_elig_dpnt edg
  where  edg.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
    and  edg.business_group_id      = p_business_group_id
    and  edg.dpnt_person_id         = cp_dpnt_person_id;
  --
  l_epe_dpnt_rec               c_epe_dpnt%rowtype;
  -- bug 5895645
  cursor get_dt_c is
     select enrt_cvg_strt_dt
     from   ben_prtt_enrt_rslt_f
     where  prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and    p_effective_date between effective_start_date
                               and effective_end_date;
-- end 5895645
  l_cvg_strt_dt                 date;
  l_elig_cvrd_dpnt_id           number(15);
  l_effective_start_date        date;
  l_effective_end_date          date;
  l_pdp_object_version_number   number(9);
  l_pdp_cr_up_flag              boolean := FALSE;
  l_new_pl_id                   number;
  l_enrt_cvg_strt_dt            date;  -- bug 5895645
  --
begin
  --
  hr_utility.set_location('Entering ' || l_proc,10);
  hr_utility.set_location('p_bckdt_per_in_ler_id ' || p_bckdt_per_in_ler_id,10);
  hr_utility.set_location('p_bckdt_prtt_enrt_rslt_id ' || p_bckdt_prtt_enrt_rslt_id,10);
  hr_utility.set_location('p_prtt_enrt_rslt_id ' || p_prtt_enrt_rslt_id,10);
  --

   --
  for bckdt_pen_dpnts_rec in c_bckdt_pen_dpnts loop
      --
      hr_utility.set_location('Reinstating dependent person id = ' ||
                               bckdt_pen_dpnts_rec.dpnt_person_id, 999);
      open c_pen_dpnts(bckdt_pen_dpnts_rec.dpnt_person_id);
      fetch c_pen_dpnts into l_pen_dpnts_rec;
      if c_pen_dpnts%notfound then
         hr_utility.set_location('Creating new dependent row', 8085);
         --
         -- Create the dependents row.
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
           ,p_effective_date          => p_effective_date -- Bug : 5124 As per Jeana, data
                                                   -- should be reinstated with system date
                                                   -- rather than p_effective_date,
           ,p_returned_date           => l_cvg_strt_dt);
         -- start bug 5895645
	 open get_dt_c;
         fetch get_dt_c into l_enrt_cvg_strt_dt;
         close get_dt_c;
	 -- end bug 5895645

         if l_cvg_strt_dt is null then
           -- error
           --
           fnd_message.set_name('BEN', 'BEN_91657_DPNT_CVG_STRT_DT');
           fnd_message.raise_error;
         end if;
         --
         -- Take the latter of the calculated date and p_enrt_cvg_strt_dt
         --
         if l_cvg_strt_dt < nvl(p_enrt_cvg_strt_dt,l_enrt_cvg_strt_dt) then
           --
           l_cvg_strt_dt := nvl(p_enrt_cvg_strt_dt,l_enrt_cvg_strt_dt);
           --
         end if;
         --
	 hr_utility.set_location('Cvg start dt ='||to_char(l_cvg_strt_dt), 25);
         hr_utility.set_location('p_enrt_cvg_strt_dt  ='||to_char(p_enrt_cvg_strt_dt), 25);
	  hr_utility.set_location('l_enrt_cvg_strt_dt  =' || l_enrt_cvg_strt_dt, 25);
         --
         -- Now hook the depenedent to the new enrollment result.
         --
         open c_epe_dpnt(bckdt_pen_dpnts_rec.dpnt_person_id);
         fetch c_epe_dpnt into l_epe_dpnt_rec;
         if c_epe_dpnt%found then
            l_pdp_cr_up_flag  := TRUE;
            ben_ELIG_DPNT_api.process_dependent(
                p_elig_dpnt_id          => l_epe_dpnt_rec.elig_dpnt_id,
                p_business_group_id     => p_business_group_id,
                p_effective_date        => p_effective_date, -- Bug : 5124 As per Jeana, data
                                                   -- should be reinstated with system date
                                                   -- rather than p_effective_date,
                p_cvg_strt_dt           => l_cvg_strt_dt,
                p_cvg_thru_dt           => hr_api.g_eot,
                p_datetrack_mode        => hr_api.g_insert,
                p_elig_cvrd_dpnt_id     => l_elig_cvrd_dpnt_id,
                p_effective_start_date  => l_effective_start_date,
                p_effective_end_date    => l_effective_end_date,
                p_object_version_number => l_pdp_object_version_number,
                p_multi_row_actn        => TRUE );
         end if;
         close c_epe_dpnt;
         --
       --
      elsif bckdt_pen_dpnts_rec.cvg_thru_dt <> hr_api.g_eot then
         hr_utility.set_location('End-dated row found - vvp', 7777);

         --5692797 Check whether backed out PDP record exists for the dependent in same enrollment
         --with valid coverage. If yes, no need to reinstate this end-dated record.
         l_chk_valid_pdp := null;
         open c_chk_valid_pdp(bckdt_pen_dpnts_rec.elig_cvrd_dpnt_id);
         fetch c_chk_valid_pdp into l_chk_valid_pdp;
         close c_chk_valid_pdp;

         hr_utility.set_location('l_chk_valid_pdp = '|| l_chk_valid_pdp, 8085);
         if l_chk_valid_pdp is null then
           open c_epe_dpnt(bckdt_pen_dpnts_rec.dpnt_person_id);
           fetch c_epe_dpnt into l_epe_dpnt_rec;
           if c_epe_dpnt%found then
              l_pdp_cr_up_flag  := TRUE;
              ben_ELIG_DPNT_api.process_dependent(
                  p_elig_dpnt_id          => l_epe_dpnt_rec.elig_dpnt_id,
                  p_business_group_id     => p_business_group_id,
                  p_effective_date        => p_effective_date, -- Bug : 5124 As per Jeana, data
                                                     -- should be reinstated with system date
                                                     -- rather than p_effective_date,
                  p_cvg_strt_dt           => bckdt_pen_dpnts_rec.cvg_strt_dt,
                  p_cvg_thru_dt           => bckdt_pen_dpnts_rec.cvg_thru_dt,
                  p_datetrack_mode        => hr_api.g_update,
                  p_elig_cvrd_dpnt_id     => l_elig_cvrd_dpnt_id,
                  p_effective_start_date  => l_effective_start_date,
                  p_effective_end_date    => l_effective_end_date,
                  p_object_version_number => l_pdp_object_version_number,
                  p_multi_row_actn        => TRUE );
           end if;
           close c_epe_dpnt;
         end if; --end l_chk_valid_pdp
      end if;
      close c_pen_dpnts;
      --
      hr_utility.set_location('l_elig_cvrd_dpnt_id ='||l_elig_cvrd_dpnt_id, 25);
      hr_utility.set_location('p_bckdt_prtt_enrt_rslt_id'||p_bckdt_prtt_enrt_rslt_id,25);
      hr_utility.set_location('bckdt_pen_dpnts_rec.elig_cvrd_dpnt_id'||bckdt_pen_dpnts_rec.elig_cvrd_dpnt_id,25);
      hr_utility.set_location('p_prtt_enrt_rslt_id'||p_prtt_enrt_rslt_id,25);
      hr_utility.set_location('p_business_group_id'||p_business_group_id,25);
      hr_utility.set_location('p_effective_date'||p_effective_date,25);
      hr_utility.set_location('p_person_id '||p_person_id,25);
      --
      if l_elig_cvrd_dpnt_id is not null then
         --Reinstates PCP at dependent level.
         reinstate_ppr_per_pen(
                p_person_id                => p_person_id
                ,p_bckdt_prtt_enrt_rslt_id => NULL -- p_bckdt_prtt_enrt_rslt_id Bug 3709516
                ,p_prtt_enrt_rslt_id       => NULL -- p_prtt_enrt_rslt_id
                ,p_business_group_id       => p_business_group_id
                ,p_elig_cvrd_dpnt_id       => l_elig_cvrd_dpnt_id
                ,p_effective_date          => p_effective_date
                ,p_bckdt_elig_cvrd_dpnt_id => bckdt_pen_dpnts_rec.elig_cvrd_dpnt_id
                );
         --
         -- Complete the certifications associated with the dependents.
         --
         reinstate_cpp_per_pdp(
            p_person_id                => p_person_id
            ,p_bckdt_prtt_enrt_rslt_id  => p_bckdt_prtt_enrt_rslt_id
            ,p_prtt_enrt_rslt_id        => p_prtt_enrt_rslt_id
            ,p_business_group_id        => p_business_group_id
            ,p_per_in_ler_id            => p_per_in_ler_id
            ,p_effective_date           => p_effective_date
            ,p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id
            ,p_elig_cvrd_dpnt_id        => l_elig_cvrd_dpnt_id
            ,p_old_elig_cvrd_dpnt_id    => bckdt_pen_dpnts_rec.elig_cvrd_dpnt_id
            );
         --
      end if;
  end loop;
  if l_pdp_cr_up_flag then
     --
     if p_pgm_id is null then
        l_new_pl_id := p_new_pl_id;
     else
        l_new_pl_id := null;
     end if;
     --
     ben_proc_common_enrt_rslt.process_post_enrollment(
           p_per_in_ler_id     => p_PER_IN_LER_ID
          ,p_pgm_id            => p_pgm_id
          ,p_pl_id             => l_new_pl_id
          ,p_enrt_mthd_cd      => 'E'   -- Explicit
          ,p_cls_enrt_flag     => FALSE
          ,p_proc_cd           => 'DSGNDPNT'
          ,p_person_id         => p_PERSON_ID
          ,p_business_group_id => p_BUSINESS_GROUP_ID
          ,p_effective_date    => p_effective_date -- Bug : 5124 As per Jeana, data
                                             -- should be reinstated with system date
                                             -- rather than  p_effective_date
          ,p_validate          => FALSE
           );
     --
  end if;
  --
  hr_utility.set_location('Leaving ' || l_proc,10);
  --
end reinstate_dpnts_per_pen;
--
procedure reinstate_pbc_per_pbn(
                             p_person_id                in number
                            ,p_bckdt_prtt_enrt_rslt_id  in number
                            ,p_prtt_enrt_rslt_id        in number
                            ,p_business_group_id        in number
                            ,p_per_in_ler_id            in number
                            ,p_effective_date           in date
                            ,p_bckdt_per_in_ler_id      in number
                            ,p_PL_BNF_ID        in number default null
                            ,p_old_PL_BNF_ID    in number default null
                           ) is
  --
  l_proc          varchar2(72) :=  g_package ||'.reinstate_pbc_per_pbn';
  --
  cursor c_old_pbc is
  select pbc.BNF_CTFN_RECD_DT,
         pea.ACTN_TYP_ID,
         pbc.BNF_CTFN_TYP_CD
    from ben_prtt_enrt_actn_f pea,
         ben_pl_bnf_ctfn_prvdd_f pbc
    where pea.per_in_ler_id       = p_bckdt_per_in_ler_id
      and pea.prtt_enrt_rslt_id   = p_bckdt_prtt_enrt_rslt_id
      and pea.business_group_id   = p_business_group_id
      and pea.PL_BNF_ID           = p_old_PL_BNF_ID
      and pbc.PRTT_ENRT_ACTN_ID   = pea.PRTT_ENRT_ACTN_ID
      and pbc.PL_BNF_ID           = p_old_PL_BNF_ID
     order by 1; -- pbn.effective_end_date; -- Low to High
  --
  l_prtt_enrt_actn_id           number(15);
  l_pbc_effective_start_date    date;
  l_pbc_effective_end_date      date;
  l_pbc_object_version_number   number(9);
  --
  cursor c_pbc(cp_actn_typ_id in number,
               cp_BNF_CTFN_TYP_CD in varchar2) is
  select pbc.*
    from ben_prtt_enrt_actn_f pea,
         ben_pl_bnf_ctfn_prvdd_f pbc
   where pea.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pea.actn_typ_id       = cp_actn_typ_id
     and pea.business_group_id = p_business_group_id
     and pea.per_in_ler_id     = p_per_in_ler_id
     and pbc.PRTT_ENRT_ACTN_ID = pea.PRTT_ENRT_ACTN_ID
     and pea.ELIG_CVRD_DPNT_ID = p_PL_BNF_ID
     and pbc.PL_BNF_ID = p_PL_BNF_ID
     and pbc.BNF_CTFN_TYP_CD = cp_BNF_CTFN_TYP_CD
     and p_effective_date between pea.effective_start_date
                        and pea.effective_end_date
     and p_effective_date between pbc.effective_start_date
                        and pbc.effective_end_date;
     -- and p_effective_date between pea.effective_start_date
     --                          and pea.effective_end_date;
  --
  l_pbc_rec               c_pbc%rowtype;
  l_datetrack_mode        varchar2(80) := null;
  --
begin
  --
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  for l_old_pbc_rec in c_old_pbc loop
      --
      open c_pbc(l_old_pbc_rec.actn_typ_id, l_old_pbc_rec.BNF_CTFN_TYP_CD);
      fetch c_pbc into l_pbc_rec;
      if c_pbc%found then
        --
        if nvl(l_old_pbc_rec.BNF_CTFN_RECD_DT, hr_api.g_eot) <>
           nvl(l_pbc_rec.BNF_CTFN_RECD_DT, hr_api.g_eot)
        then
           --
           -- Use the correction mode.
           -- update the dependent certification received.
           --
           l_datetrack_mode := hr_api.g_correction;
           --
           if l_old_pbc_rec.BNF_CTFN_RECD_DT < p_effective_date then
              l_old_pbc_rec.BNF_CTFN_RECD_DT := p_effective_date;
           end if;
           --
           BEN_pl_bnf_ctfn_prvdd_API.update_pl_bnf_ctfn_prvdd
                 (p_validate => FALSE
                 ,p_PL_BNF_CTFN_PRVDD_ID     => l_pbc_rec.PL_BNF_CTFN_PRVDD_ID
                 ,p_EFFECTIVE_START_DATE     => l_pbc_EFFECTIVE_START_DATE
                 ,p_EFFECTIVE_END_DATE       => l_pbc_EFFECTIVE_END_DATE
                 ,p_BNF_CTFN_TYP_CD          => l_pbc_rec.BNF_CTFN_TYP_CD
                 ,p_BNF_CTFN_RECD_DT         => l_old_pbc_rec.BNF_CTFN_RECD_DT
                 ,p_BNF_CTFN_RQD_FLAG        => l_pbc_rec.BNF_CTFN_RQD_FLAG
                 ,p_PL_BNF_ID                => l_pbc_rec.PL_BNF_ID
                 ,p_prtt_enrt_actn_id        => l_pbc_rec.PRTT_ENRT_ACTN_ID
                 ,p_BUSINESS_GROUP_ID        => l_pbc_rec.BUSINESS_GROUP_ID
                 ,p_PBC_ATTRIBUTE_CATEGORY   => l_pbc_rec.PBC_ATTRIBUTE_CATEGORY
                 ,p_PBC_ATTRIBUTE1           => l_pbc_rec.PBC_ATTRIBUTE1
                 ,p_PBC_ATTRIBUTE2           => l_pbc_rec.PBC_ATTRIBUTE2
                 ,p_PBC_ATTRIBUTE3           => l_pbc_rec.PBC_ATTRIBUTE3
                 ,p_PBC_ATTRIBUTE4           => l_pbc_rec.PBC_ATTRIBUTE4
                 ,p_PBC_ATTRIBUTE5           => l_pbc_rec.PBC_ATTRIBUTE5
                 ,p_PBC_ATTRIBUTE6           => l_pbc_rec.PBC_ATTRIBUTE6
                 ,p_PBC_ATTRIBUTE7           => l_pbc_rec.PBC_ATTRIBUTE7
                 ,p_PBC_ATTRIBUTE8           => l_pbc_rec.PBC_ATTRIBUTE8
                 ,p_PBC_ATTRIBUTE9           => l_pbc_rec.PBC_ATTRIBUTE9
                 ,p_PBC_ATTRIBUTE10           => l_pbc_rec.PBC_ATTRIBUTE10
                 ,p_PBC_ATTRIBUTE11           => l_pbc_rec.PBC_ATTRIBUTE11
                 ,p_PBC_ATTRIBUTE12           => l_pbc_rec.PBC_ATTRIBUTE12
                 ,p_PBC_ATTRIBUTE13           => l_pbc_rec.PBC_ATTRIBUTE13
                 ,p_PBC_ATTRIBUTE14           => l_pbc_rec.PBC_ATTRIBUTE14
                 ,p_PBC_ATTRIBUTE15           => l_pbc_rec.PBC_ATTRIBUTE15
                 ,p_PBC_ATTRIBUTE16           => l_pbc_rec.PBC_ATTRIBUTE16
                 ,p_PBC_ATTRIBUTE17           => l_pbc_rec.PBC_ATTRIBUTE17
                 ,p_PBC_ATTRIBUTE18           => l_pbc_rec.PBC_ATTRIBUTE18
                 ,p_PBC_ATTRIBUTE19           => l_pbc_rec.PBC_ATTRIBUTE19
                 ,p_PBC_ATTRIBUTE20           => l_pbc_rec.PBC_ATTRIBUTE20
                 ,p_PBC_ATTRIBUTE21           => l_pbc_rec.PBC_ATTRIBUTE21
                 ,p_PBC_ATTRIBUTE22           => l_pbc_rec.PBC_ATTRIBUTE22
                 ,p_PBC_ATTRIBUTE23           => l_pbc_rec.PBC_ATTRIBUTE23
                 ,p_PBC_ATTRIBUTE24           => l_pbc_rec.PBC_ATTRIBUTE24
                 ,p_PBC_ATTRIBUTE25           => l_pbc_rec.PBC_ATTRIBUTE25
                 ,p_PBC_ATTRIBUTE26           => l_pbc_rec.PBC_ATTRIBUTE26
                 ,p_PBC_ATTRIBUTE27           => l_pbc_rec.PBC_ATTRIBUTE27
                 ,p_PBC_ATTRIBUTE28           => l_pbc_rec.PBC_ATTRIBUTE28
                 ,p_PBC_ATTRIBUTE29           => l_pbc_rec.PBC_ATTRIBUTE29
                 ,p_PBC_ATTRIBUTE30           => l_pbc_rec.PBC_ATTRIBUTE30
                 ,p_request_id                => l_pbc_rec.REQUEST_ID
                 ,p_program_application_id    => l_pbc_rec.PROGRAM_APPLICATION_ID
                 ,p_program_id                => l_pbc_rec.PROGRAM_ID
                 ,p_program_update_date       => l_pbc_rec.PROGRAM_UPDATE_DATE
                 ,p_OBJECT_VERSION_NUMBER     => l_pbc_rec.OBJECT_VERSION_NUMBER
                 ,p_effective_date            => p_effective_date
                 ,p_datetrack_mode            => l_datetrack_mode
                 );
           --
        end if;
        --
      end if;
      --
      close c_pbc;
  end loop;
  --
  hr_utility.set_location('Leaving ' || l_proc,10);
  --
end reinstate_pbc_per_pbn;
--
-- This procedure creates the enrollment beneficiary records for each
-- enrollment linked to backed out per in ler.
--
procedure reinstate_pbn_per_pen(
                             p_person_id                in number
                            ,p_bckdt_prtt_enrt_rslt_id  in number
                            ,p_rslt_object_version_number in number
                            ,p_prtt_enrt_rslt_id        in number
                            ,p_business_group_id        in number
                            ,p_per_in_ler_id            in number
                            ,p_effective_date           in date
                            ,p_bckdt_per_in_ler_id      in number
                           ) is
  --
  l_proc                    varchar2(72) := g_package||'.reinstate_pbn_per_pen';
  --
  cursor c_old_bnf is
  select
          pbn.EFFECTIVE_END_DATE,
          pbn.pbn_ATTRIBUTE1,
          pbn.pbn_ATTRIBUTE2,
          pbn.pbn_ATTRIBUTE3,
          pbn.pbn_ATTRIBUTE4,
          pbn.pbn_ATTRIBUTE5,
          pbn.pbn_ATTRIBUTE6,
          pbn.pbn_ATTRIBUTE7,
          pbn.pbn_ATTRIBUTE8,
          pbn.pbn_ATTRIBUTE9,
          pbn.pbn_ATTRIBUTE10,
          pbn.pbn_ATTRIBUTE11,
          pbn.pbn_ATTRIBUTE12,
          pbn.pbn_ATTRIBUTE13,
          pbn.pbn_ATTRIBUTE14,
          pbn.pbn_ATTRIBUTE15,
          pbn.pbn_ATTRIBUTE16,
          pbn.pbn_ATTRIBUTE17,
          pbn.pbn_ATTRIBUTE18,
          pbn.pbn_ATTRIBUTE19,
          pbn.pbn_ATTRIBUTE20,
          pbn.pbn_ATTRIBUTE21,
          pbn.pbn_ATTRIBUTE22,
          pbn.pbn_ATTRIBUTE23,
          pbn.pbn_ATTRIBUTE24,
          pbn.pbn_ATTRIBUTE25,
          pbn.pbn_ATTRIBUTE26,
          pbn.pbn_ATTRIBUTE27,
          pbn.pbn_ATTRIBUTE28,
          pbn.pbn_ATTRIBUTE29,
          pbn.pbn_ATTRIBUTE30,
          pbn.LAST_UPDATE_DATE,
          pbn.LAST_UPDATED_BY,
          pbn.LAST_UPDATE_LOGIN,
          pbn.CREATED_BY,
          pbn.CREATION_DATE,
          pbn.REQUEST_ID,
          pbn.PROGRAM_APPLICATION_ID,
          pbn.PROGRAM_ID,
          pbn.PROGRAM_UPDATE_DATE,
          pbn.OBJECT_VERSION_NUMBER,
          pbn.pl_bnf_id,
          pbn.EFFECTIVE_START_DATE,
          pbn.PRMRY_CNTNGNT_CD,
          pbn.PCT_DSGD_NUM,
          pbn.AMT_DSGD_VAL,
          pbn.AMT_DSGD_UOM,
          pbn.ADDL_INSTRN_TXT,
          pbn.DSGN_THRU_DT,
          pbn.DSGN_STRT_DT,
          pbn.PRTT_ENRT_RSLT_ID,
          pbn.ORGANIZATION_ID,
          pbn.BNF_PERSON_ID,
          pbn.TTEE_PERSON_ID,
          pbn.BUSINESS_GROUP_ID,
          pbn.PER_IN_LER_ID,
          pbn.pbn_ATTRIBUTE_CATEGORY
    from ben_pl_bnf_f pbn
    where pbn.per_in_ler_id       = p_bckdt_per_in_ler_id
      and pbn.prtt_enrt_rslt_id   = p_bckdt_prtt_enrt_rslt_id
      and pbn.business_group_id   = p_business_group_id
  union
  select
          pbn.EFFECTIVE_END_DATE,
          pbn.LCR_ATTRIBUTE1,
          pbn.LCR_ATTRIBUTE2,
          pbn.LCR_ATTRIBUTE3,
          pbn.LCR_ATTRIBUTE4,
          pbn.LCR_ATTRIBUTE5,
          pbn.LCR_ATTRIBUTE6,
          pbn.LCR_ATTRIBUTE7,
          pbn.LCR_ATTRIBUTE8,
          pbn.LCR_ATTRIBUTE9,
          pbn.LCR_ATTRIBUTE10,
          pbn.LCR_ATTRIBUTE11,
          pbn.LCR_ATTRIBUTE12,
          pbn.LCR_ATTRIBUTE13,
          pbn.LCR_ATTRIBUTE14,
          pbn.LCR_ATTRIBUTE15,
          pbn.LCR_ATTRIBUTE16,
          pbn.LCR_ATTRIBUTE17,
          pbn.LCR_ATTRIBUTE18,
          pbn.LCR_ATTRIBUTE19,
          pbn.LCR_ATTRIBUTE20,
          pbn.LCR_ATTRIBUTE21,
          pbn.LCR_ATTRIBUTE22,
          pbn.LCR_ATTRIBUTE23,
          pbn.LCR_ATTRIBUTE24,
          pbn.LCR_ATTRIBUTE25,
          pbn.LCR_ATTRIBUTE26,
          pbn.LCR_ATTRIBUTE27,
          pbn.LCR_ATTRIBUTE28,
          pbn.LCR_ATTRIBUTE29,
          pbn.LCR_ATTRIBUTE30,
          pbn.LAST_UPDATE_DATE,
          pbn.LAST_UPDATED_BY,
          pbn.LAST_UPDATE_LOGIN,
          pbn.CREATED_BY,
          pbn.CREATION_DATE,
          pbn.REQUEST_ID,
          pbn.PROGRAM_APPLICATION_ID,
          pbn.PROGRAM_ID,
          pbn.PROGRAM_UPDATE_DATE,
          pbn.OBJECT_VERSION_NUMBER,
          pbn.BKUP_TBL_ID,
          pbn.EFFECTIVE_START_DATE,
          pbn.PRMRY_CNTNGNT_CD,
          pbn.PCT_DSGD_NUM,
          pbn.AMT_DSGD_VAL,
          pbn.AMT_DSGD_UOM,
          pbn.ADDL_INSTRN_TXT,
          pbn.DSGN_THRU_DT,
          pbn.DSGN_STRT_DT,
          pbn.PRTT_ENRT_RSLT_ID,
          pbn.ORGANIZATION_ID,
          pbn.BNF_PERSON_ID,
          pbn.PERSON_TTEE_ID,
          pbn.BUSINESS_GROUP_ID,
          pbn.PER_IN_LER_ID,
          pbn.LCR_ATTRIBUTE_CATEGORY
    from ben_le_clsn_n_rstr pbn
   where pbn.prtt_enrt_rslt_id = p_bckdt_prtt_enrt_rslt_id
     and pbn.business_group_id = p_business_group_id
     and pbn.per_in_ler_id     = p_bckdt_per_in_ler_id
     and p_effective_date between pbn.effective_start_date
                               and pbn.effective_end_date
     and pbn.bkup_tbl_typ_cd = 'BEN_PL_BNF_F'
     order by 1;
  --
  l_old_pl_bnf_id               number(15);
  l_pl_bnf_id                   number(15);
  l_bnf_effective_start_date    date;
  l_bnf_effective_end_date      date;
  l_bnf_object_version_number   number(9);
  --
  cursor c_bnf(cp_bnf_person_id in number) is
  select pbn.*
    from ben_pl_bnf_f pbn
   where pbn.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pbn.bnf_person_id     = cp_bnf_person_id
     and pbn.business_group_id = p_business_group_id
    --  and pbn.per_in_ler_id     = p_per_in_ler_id  --BUG Bug 4178570
     and p_effective_date between pbn.effective_start_date
                              and pbn.effective_end_date;
  --
  l_bnf_rec c_bnf%rowtype;
  l_datetrack_mode             varchar2(80) := null;
  --
begin
  --
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  for l_old_bnf_rec in c_old_bnf loop
      --
      open c_bnf(l_old_bnf_rec.bnf_person_id);
      fetch c_bnf into l_bnf_rec;
      if c_bnf%notfound then
        --
        ben_plan_beneficiary_api.create_plan_beneficiary
          (p_validate                => FALSE
          ,p_pl_bnf_id               => l_pl_bnf_id
          ,p_effective_start_date    => l_bnf_effective_start_date
          ,p_effective_end_date      => l_bnf_effective_end_date
          ,p_business_group_id       => p_business_group_id
          ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
          ,p_bnf_person_id           => l_old_bnf_rec.bnf_person_id
          ,p_organization_id         => l_old_bnf_rec.organization_id
          ,p_ttee_person_id          => l_old_bnf_rec.ttee_person_id
          ,p_prmry_cntngnt_cd        => l_old_bnf_rec.prmry_cntngnt_cd
          ,p_pct_dsgd_num            => l_old_bnf_rec.pct_dsgd_num
          ,p_amt_dsgd_val            => l_old_bnf_rec.amt_dsgd_val
          ,p_amt_dsgd_uom            => l_old_bnf_rec.amt_dsgd_uom
          ,p_addl_instrn_txt         => l_old_bnf_rec.addl_instrn_txt
          ,p_per_in_ler_id           => p_per_in_ler_id
          ,p_pbn_attribute_category  => l_old_bnf_rec.pbn_attribute_category
          ,p_pbn_attribute1          => l_old_bnf_rec.pbn_attribute1
          ,p_pbn_attribute2          => l_old_bnf_rec.pbn_attribute2
          ,p_pbn_attribute3          => l_old_bnf_rec.pbn_attribute3
          ,p_pbn_attribute4          => l_old_bnf_rec.pbn_attribute4
          ,p_pbn_attribute5          => l_old_bnf_rec.pbn_attribute5
          ,p_pbn_attribute6          => l_old_bnf_rec.pbn_attribute6
          ,p_pbn_attribute7          => l_old_bnf_rec.pbn_attribute7
          ,p_pbn_attribute8          => l_old_bnf_rec.pbn_attribute8
          ,p_pbn_attribute9          => l_old_bnf_rec.pbn_attribute9
          ,p_pbn_attribute10         => l_old_bnf_rec.pbn_attribute10
          ,p_pbn_attribute11         => l_old_bnf_rec.pbn_attribute11
          ,p_pbn_attribute12         => l_old_bnf_rec.pbn_attribute12
          ,p_pbn_attribute13         => l_old_bnf_rec.pbn_attribute13
          ,p_pbn_attribute14         => l_old_bnf_rec.pbn_attribute14
          ,p_pbn_attribute15         => l_old_bnf_rec.pbn_attribute15
          ,p_pbn_attribute16         => l_old_bnf_rec.pbn_attribute16
          ,p_pbn_attribute17         => l_old_bnf_rec.pbn_attribute17
          ,p_pbn_attribute18         => l_old_bnf_rec.pbn_attribute18
          ,p_pbn_attribute19         => l_old_bnf_rec.pbn_attribute19
          ,p_pbn_attribute20         => l_old_bnf_rec.pbn_attribute20
          ,p_pbn_attribute21         => l_old_bnf_rec.pbn_attribute21
          ,p_pbn_attribute22         => l_old_bnf_rec.pbn_attribute22
          ,p_pbn_attribute23         => l_old_bnf_rec.pbn_attribute23
          ,p_pbn_attribute24         => l_old_bnf_rec.pbn_attribute24
          ,p_pbn_attribute25         => l_old_bnf_rec.pbn_attribute25
          ,p_pbn_attribute26         => l_old_bnf_rec.pbn_attribute26
          ,p_pbn_attribute27         => l_old_bnf_rec.pbn_attribute27
          ,p_pbn_attribute28         => l_old_bnf_rec.pbn_attribute28
          ,p_pbn_attribute29         => l_old_bnf_rec.pbn_attribute29
          ,p_pbn_attribute30         => l_old_bnf_rec.pbn_attribute30
          ,p_request_id              => fnd_global.conc_request_id
          ,p_program_application_id  => fnd_global.prog_appl_id
          ,p_program_id              => fnd_global.conc_program_id
          ,p_program_update_date     => sysdate
          ,p_object_version_number   => l_bnf_object_version_number
          ,p_multi_row_actn          => FALSE --TRUE                        -- bug  2552295
          ,p_effective_date          => p_effective_date
          ,p_dsgn_thru_dt            => l_old_bnf_rec.dsgn_thru_dt
          ,p_dsgn_strt_dt            => l_old_bnf_rec.dsgn_strt_dt);
        --
      else
        --
        if p_effective_date = l_bnf_rec.effective_start_date or
           p_effective_date = l_bnf_rec.effective_end_date then
           l_datetrack_mode := hr_api.g_correction;
        else
           l_datetrack_mode := hr_api.g_update;
        end if;
        --
        ben_plan_beneficiary_api.update_PLAN_BENEFICIARY
          (p_validate                       => FALSE
          ,p_pl_bnf_id                      => l_bnf_rec.pl_bnf_id
          ,p_effective_start_date           => l_bnf_effective_start_date
          ,p_effective_end_date             => l_bnf_effective_end_date
          ,p_business_group_id              => p_business_group_id
          ,p_prtt_enrt_rslt_id              => p_prtt_enrt_rslt_id
          ,p_bnf_person_id                  => l_old_bnf_rec.bnf_person_id
          ,p_organization_id                => l_old_bnf_rec.organization_id
          ,p_ttee_person_id                 => l_old_bnf_rec.ttee_person_id
          ,p_prmry_cntngnt_cd               => l_old_bnf_rec.prmry_cntngnt_cd
          ,p_pct_dsgd_num                   => l_old_bnf_rec.pct_dsgd_num
          ,p_amt_dsgd_val                   => l_old_bnf_rec.amt_dsgd_val
          ,p_amt_dsgd_uom                   => l_old_bnf_rec.amt_dsgd_uom
          ,p_dsgn_strt_dt                   => l_old_bnf_rec.dsgn_strt_dt
          ,p_dsgn_thru_dt                   => l_old_bnf_rec.dsgn_thru_dt
          ,p_addl_instrn_txt                => l_old_bnf_rec.addl_instrn_txt
          ,p_pbn_attribute_category         => l_old_bnf_rec.pbn_attribute_category
          ,p_pbn_attribute1                 => l_old_bnf_rec.pbn_attribute1
          ,p_pbn_attribute2                 => l_old_bnf_rec.pbn_attribute2
          ,p_pbn_attribute3                 => l_old_bnf_rec.pbn_attribute3
          ,p_pbn_attribute4                 => l_old_bnf_rec.pbn_attribute4
          ,p_pbn_attribute5                 => l_old_bnf_rec.pbn_attribute5
          ,p_pbn_attribute6                 => l_old_bnf_rec.pbn_attribute6
          ,p_pbn_attribute7                 => l_old_bnf_rec.pbn_attribute7
          ,p_pbn_attribute8                 => l_old_bnf_rec.pbn_attribute8
          ,p_pbn_attribute9                 => l_old_bnf_rec.pbn_attribute9
          ,p_pbn_attribute10                => l_old_bnf_rec.pbn_attribute10
          ,p_pbn_attribute11                => l_old_bnf_rec.pbn_attribute11
          ,p_pbn_attribute12                => l_old_bnf_rec.pbn_attribute12
          ,p_pbn_attribute13                => l_old_bnf_rec.pbn_attribute13
          ,p_pbn_attribute14                => l_old_bnf_rec.pbn_attribute14
          ,p_pbn_attribute15                => l_old_bnf_rec.pbn_attribute15
          ,p_pbn_attribute16                => l_old_bnf_rec.pbn_attribute16
          ,p_pbn_attribute17                => l_old_bnf_rec.pbn_attribute17
          ,p_pbn_attribute18                => l_old_bnf_rec.pbn_attribute18
          ,p_pbn_attribute19                => l_old_bnf_rec.pbn_attribute19
          ,p_pbn_attribute20                => l_old_bnf_rec.pbn_attribute20
          ,p_pbn_attribute21                => l_old_bnf_rec.pbn_attribute21
          ,p_pbn_attribute22                => l_old_bnf_rec.pbn_attribute22
          ,p_pbn_attribute23                => l_old_bnf_rec.pbn_attribute23
          ,p_pbn_attribute24                => l_old_bnf_rec.pbn_attribute24
          ,p_pbn_attribute25                => l_old_bnf_rec.pbn_attribute25
          ,p_pbn_attribute26                => l_old_bnf_rec.pbn_attribute26
          ,p_pbn_attribute27                => l_old_bnf_rec.pbn_attribute27
          ,p_pbn_attribute28                => l_old_bnf_rec.pbn_attribute28
          ,p_pbn_attribute29                => l_old_bnf_rec.pbn_attribute29
          ,p_pbn_attribute30                => l_old_bnf_rec.pbn_attribute30
          ,p_request_id                     => fnd_global.conc_request_id
          ,p_program_application_id         => fnd_global.prog_appl_id
          ,p_program_id                     => fnd_global.conc_program_id
          ,p_program_update_date            => sysdate
          ,p_object_version_number          => l_bnf_rec.object_version_number
          ,p_per_in_ler_id                  => p_per_in_ler_id
          ,p_effective_date                 => p_effective_date
          ,p_datetrack_mode                 => l_datetrack_mode
          ,p_multi_row_actn                 => FALSE -- TRUE    -- bug 2552295
          );
        --
        l_pl_bnf_id := l_bnf_rec.pl_bnf_id;
        --
        -- Reinstate the certifications.
        --
        reinstate_pbc_per_pbn(
                 p_person_id                => p_person_id
                ,p_bckdt_prtt_enrt_rslt_id  => p_bckdt_prtt_enrt_rslt_id
                ,p_prtt_enrt_rslt_id        => p_prtt_enrt_rslt_id
                ,p_business_group_id        => p_business_group_id
                ,p_per_in_ler_id            => p_per_in_ler_id
                ,p_effective_date           => p_effective_date
                ,p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id
                ,p_pl_bnf_id                => l_pl_bnf_id
                ,p_old_pl_bnf_id            => l_old_bnf_rec.pl_bnf_id
                );
      end if;
      --
      --
      -- maybe a table having all pl_bnf_id needs to put reinstate_pea_per_pen
      -- outside loop;
      --
      -- Reinstate the action items.
      --

      -- May not be necessary as plan beneficiary certifications are
      -- reinstated.
      --

      -- bug  2552295 uncommented the code to reinstate the action items
         reinstate_pea_per_pen(
                 p_person_id                => p_person_id
                ,p_bckdt_prtt_enrt_rslt_id  => p_bckdt_prtt_enrt_rslt_id
                ,p_prtt_enrt_rslt_id        => p_prtt_enrt_rslt_id
                ,p_rslt_object_version_number => p_rslt_object_version_number
                ,p_business_group_id        => p_business_group_id
                ,p_per_in_ler_id            => p_per_in_ler_id
                ,p_effective_date           => p_effective_date
                ,p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id
                ,p_pl_bnf_id                => l_pl_bnf_id
                ,p_old_pl_bnf_id            => l_old_bnf_rec.pl_bnf_id
                );
      -- end bug 2552295
      close c_bnf;
  end loop;
  --
  --We need to add the call to process_bnf_actn_items which will
  hr_utility.set_location('Leaving ' || l_proc,10);
  --
end reinstate_pbn_per_pen;
--
procedure reinstate_pcs_per_pen(
                             p_person_id                in number
                            ,p_bckdt_prtt_enrt_rslt_id  in number
                            ,p_prtt_enrt_rslt_id        in number
                            ,p_rslt_object_version_number in number
                            ,p_business_group_id        in number
                            ,p_prtt_enrt_actn_id        in number
                            ,p_effective_date           in date
                            ,p_bckdt_prtt_enrt_actn_id  in number
                            ,p_per_in_ler_id            in number
                            ,p_bckdt_per_in_ler_id      in number
                           ) is
  --
  l_proc                    varchar2(72) := g_package || '.reinstate_pcs_per_pen';
  --
  cursor c_old_pcs is
  select pcs.*, pea.ACTN_TYP_ID
    from ben_prtt_enrt_ctfn_prvdd_f pcs,
         ben_prtt_enrt_actn_f pea
    where pcs.prtt_enrt_actn_id   = pea.prtt_enrt_actn_id
      and pcs.prtt_enrt_rslt_id   = p_bckdt_prtt_enrt_rslt_id
      and pea.per_in_ler_id       = p_bckdt_per_in_ler_id
      and pea.prtt_enrt_rslt_id   = pcs.prtt_enrt_rslt_id
      and pcs.business_group_id   = p_business_group_id
      and p_effective_date between pcs.effective_start_date
                               and pcs.effective_end_date
      and p_effective_date between pea.effective_start_date
                               and pea.effective_end_date
   /* Bug 8910111: While reinstating the certifications, if the certification records
      are end dated by the next life event, then as on p_effective_date cursor will not fetch any records.
      Added union condition to get the latest certification  record(if records exists in update mode) while
      reinstating the certification record.*/
   union
   select pcs.*, pea.ACTN_TYP_ID
    from ben_prtt_enrt_ctfn_prvdd_f pcs,
         ben_prtt_enrt_actn_f pea
    where pcs.prtt_enrt_actn_id   = pea.prtt_enrt_actn_id
      and pcs.prtt_enrt_rslt_id   = p_bckdt_prtt_enrt_rslt_id
      and pea.per_in_ler_id       = p_bckdt_per_in_ler_id
      and pea.prtt_enrt_rslt_id   = pcs.prtt_enrt_rslt_id
      and pcs.business_group_id   = p_business_group_id
      and pea.effective_start_date = (select max(effective_start_date) from ben_prtt_enrt_actn_f pea1
                                      where pea1.per_in_ler_id = pea.per_in_ler_id
                                      and pea1.prtt_enrt_rslt_id = pea.prtt_enrt_rslt_id
                                      and pea1.prtt_enrt_actn_id = pea.prtt_enrt_actn_id)
      and pcs.effective_start_date = (select max(effective_start_date)  from ben_prtt_enrt_ctfn_prvdd_f pcs1
                                     where pcs1.prtt_enrt_rslt_id = pcs.prtt_enrt_rslt_id
                                      and pcs1.prtt_enrt_actn_id = pcs.prtt_enrt_actn_id);
  --
  l_pcs_effective_start_date    date;
  l_pcs_effective_end_date      date;
  l_pcs_object_version_number   number(9);
  --
  cursor c_pcs(cp_enrt_ctfn_typ_cd in varchar2,
               cp_ENRT_R_BNFT_CTFN_CD in varchar2,
               cp_ACTN_TYP_ID in varchar2) is
  select pcs.*
    from ben_prtt_enrt_ctfn_prvdd_f pcs,
         ben_prtt_enrt_actn_f pea
   where pcs.prtt_enrt_rslt_id          = p_prtt_enrt_rslt_id
     and nvl(pcs.enrt_ctfn_typ_cd, -1)  = nvl(cp_enrt_ctfn_typ_cd, -1)
     and nvl(pcs.enrt_r_bnft_ctfn_cd, -1)  = nvl(cp_enrt_r_bnft_ctfn_cd, -1)
     and pea.prtt_enrt_rslt_id   = pcs.prtt_enrt_rslt_id
     and pea.ACTN_TYP_ID         = cp_ACTN_TYP_ID
     and pcs.business_group_id   = p_business_group_id
     and pcs.prtt_enrt_actn_id   = pea.prtt_enrt_actn_id
     and pea.per_in_ler_id       = p_per_in_ler_id
     and p_effective_date between pcs.effective_start_date
                        and pcs.effective_end_date
     and p_effective_date between pea.effective_start_date
                        and pea.effective_end_date;
  --
  l_pcs_rec               c_pcs%rowtype;
  l_datetrack_mode        varchar2(80) := null;
  --
begin
  --
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  for l_old_pcs_rec in c_old_pcs loop
      --
      open c_pcs(l_old_pcs_rec.enrt_ctfn_typ_cd,
                 l_old_pcs_rec.ENRT_R_BNFT_CTFN_CD,
                 l_old_pcs_rec.ACTN_TYP_ID);
      fetch c_pcs into l_pcs_rec;
      if c_pcs%found then
        --
        if nvl(l_old_pcs_rec.ENRT_CTFN_RECD_DT, hr_api.g_eot) <>
           nvl(l_pcs_rec.ENRT_CTFN_RECD_DT, hr_api.g_eot) or
           nvl(l_old_pcs_rec.ENRT_CTFN_DND_DT, hr_api.g_eot) <>
           nvl(l_pcs_rec.ENRT_CTFN_DND_DT, hr_api.g_eot)
        then
           --
           -- Use the correction mode.
           l_datetrack_mode := hr_api.g_correction;
           --
           -- update the action items.
           --
           -- If completion date is > p_effective_date .
           --
           --
           /* BUG 4558512
           if l_old_pcs_rec.ENRT_CTFN_RECD_DT < p_effective_date then
              l_old_pcs_rec.ENRT_CTFN_RECD_DT := p_effective_date;
           end if;
           --
           if l_old_pcs_rec.ENRT_CTFN_DND_DT < p_effective_date then
              l_old_pcs_rec.ENRT_CTFN_DND_DT := p_effective_date;
           end if;
           */
           --
           BEN_prtt_enrt_ctfn_prvdd_API.update_prtt_enrt_ctfn_prvdd (
               p_prtt_enrt_ctfn_prvdd_id => l_pcs_rec.PRTT_ENRT_CTFN_PRVDD_ID
               ,p_prtt_enrt_actn_id       => l_pcs_rec.prtt_enrt_actn_id
               ,p_prtt_enrt_rslt_id       => l_pcs_rec.prtt_enrt_rslt_id
               ,p_business_group_id       => p_business_group_id
               ,p_EFFECTIVE_START_DATE    => l_pcs_EFFECTIVE_START_DATE
               ,p_EFFECTIVE_END_DATE      => l_pcs_EFFECTIVE_END_DATE
               ,p_ENRT_CTFN_RECD_DT       => l_old_pcs_rec.ENRT_CTFN_RECD_DT
               ,p_ENRT_CTFN_DND_DT        => l_old_pcs_rec.ENRT_CTFN_DND_DT
               ,p_OBJECT_VERSION_NUMBER   => l_pcs_rec.OBJECT_VERSION_NUMBER
               ,p_effective_date          => p_effective_date
               ,p_datetrack_mode          => l_datetrack_mode
           );
           --
           --
        end if;
        --
      end if;
      --
      close c_pcs;
  end loop;
  --
  hr_utility.set_location('Leaving ' || l_proc,10);
  --
end reinstate_pcs_per_pen;
--
-- This procedure creates the enrollment results based on what participant
-- enrolled as of the backed out per in ler.
--
procedure reinstate_the_prev_enrt(
                             p_person_id            in number
                            ,p_business_group_id   in number
                            ,p_ler_id              in number
                            ,p_effective_date      in date
                            ,p_per_in_ler_id       in number
                            ,p_bckdt_per_in_ler_id in number
                            ,p_bckdt_pil_prev_stat_cd in varchar2 default null
                           ) is
  --
  l_proc                    varchar2(72) := g_package||'.reinstate_the_prev_enrt';
  --
  cursor c_bckdt_pil is
    select pil.PRVS_STAT_CD, pil.object_version_number, pil.BCKT_PER_IN_LER_ID
    from ben_per_in_ler pil
    where pil.per_in_ler_id = p_bckdt_per_in_ler_id
      and pil.business_group_id = p_business_group_id;
  --
  l_bckt_csd_per_in_ler_id  number;
  l_bckdt_pil_prev_stat_cd  varchar2(80);
  l_bckdt_pil_ovn           number;
  l_date                    date;
  l_procd_dt                date;
  l_strtd_dt                date;
  l_voidd_dt                date;

  --
  -- Get the enrollment results from the backup table for backed out pil.
  --
  cursor c_bckdt_pen is
   select
          pen.EFFECTIVE_END_DATE,
          pen.ASSIGNMENT_ID,
          pen.BNFT_AMT,
          pen.BNFT_NNMNTRY_UOM,
          pen.BNFT_ORDR_NUM,
          pen.BNFT_TYP_CD,
          pen.BUSINESS_GROUP_ID,
          pen.COMP_LVL_CD,
          pen.CREATED_BY,
          pen.CREATION_DATE,
          pen.EFFECTIVE_START_DATE,
          pen.ENRT_CVG_STRT_DT,
          pen.ENRT_CVG_THRU_DT,
          pen.ENRT_MTHD_CD,
          pen.ENRT_OVRIDN_FLAG,
          pen.ENRT_OVRID_RSN_CD,
          pen.ENRT_OVRID_THRU_DT,
          pen.ERLST_DEENRT_DT,
          pen.LAST_UPDATED_BY,
          pen.LAST_UPDATE_DATE,
          pen.LAST_UPDATE_LOGIN,
          pen.LER_ID,
          pen.NO_LNGR_ELIG_FLAG,
          pen.OBJECT_VERSION_NUMBER,
          pen.OIPL_ID,
          pen.OIPL_ORDR_NUM,
          pen.ORGNL_ENRT_DT,
          pen.PEN_ATTRIBUTE1,
          pen.PEN_ATTRIBUTE10,
          pen.PEN_ATTRIBUTE11,
          pen.PEN_ATTRIBUTE12,
          pen.PEN_ATTRIBUTE13,
          pen.PEN_ATTRIBUTE14,
          pen.PEN_ATTRIBUTE15,
          pen.PEN_ATTRIBUTE16,
          pen.PEN_ATTRIBUTE17,
          pen.PEN_ATTRIBUTE18,
          pen.PEN_ATTRIBUTE19,
          pen.PEN_ATTRIBUTE2,
          pen.PEN_ATTRIBUTE20,
          pen.PEN_ATTRIBUTE21,
          pen.PEN_ATTRIBUTE22,
          pen.PEN_ATTRIBUTE23,
          pen.PEN_ATTRIBUTE24,
          pen.PEN_ATTRIBUTE25,
          pen.PEN_ATTRIBUTE26,
          pen.PEN_ATTRIBUTE27,
          pen.PEN_ATTRIBUTE28,
          pen.PEN_ATTRIBUTE29,
          pen.PEN_ATTRIBUTE3,
          pen.PEN_ATTRIBUTE30,
          pen.PEN_ATTRIBUTE4,
          pen.PEN_ATTRIBUTE5,
          pen.PEN_ATTRIBUTE6,
          pen.PEN_ATTRIBUTE7,
          pen.PEN_ATTRIBUTE8,
          pen.PEN_ATTRIBUTE9,
          pen.PEN_ATTRIBUTE_CATEGORY,
          pen.PERSON_ID,
          pen.PER_IN_LER_ID,
          pen.PGM_ID,
          pen.PLIP_ORDR_NUM,
          pen.PL_ID,
          pen.PL_ORDR_NUM,
          pen.PL_TYP_ID,
          pen.PROGRAM_APPLICATION_ID,
          pen.PROGRAM_ID,
          pen.PROGRAM_UPDATE_DATE,
          pen.PRTT_ENRT_RSLT_ID,
          pen.PRTT_ENRT_RSLT_STAT_CD,
          pen.PRTT_IS_CVRD_FLAG,
          pen.PTIP_ID,
          pen.PTIP_ORDR_NUM,
          pen.REQUEST_ID,
          pen.RPLCS_SSPNDD_RSLT_ID,
          pen.SSPNDD_FLAG,
          pen.UOM
    from   ben_prtt_enrt_rslt_f pen,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_bckdt_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.business_group_id = p_business_group_id
    and    pil.per_in_ler_id       = pen.per_in_ler_id
           /*Pick up both end-dated and non-end-dated results*/
    and    (pen.effective_end_date = hr_api.g_eot or
            pen.effective_end_date = (select max(effective_end_date)
                                        from ben_prtt_enrt_rslt_f
                                       where prtt_enrt_rslt_id =
                                                         pen.prtt_enrt_rslt_id))
    and    (pen.enrt_cvg_thru_dt is null or
            pen.enrt_cvg_thru_dt    = hr_api.g_eot
           )
    and    pen.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
    and pen.prtt_enrt_rslt_id not in (
         select nvl(pen_inner.RPLCS_SSPNDD_RSLT_ID, -1)
           from   ben_prtt_enrt_rslt_f pen_inner,
                  ben_per_in_ler pil_inner
           where  pil_inner.per_in_ler_id       = p_bckdt_per_in_ler_id
           and    pil_inner.person_id           = p_person_id
           and    pil_inner.business_group_id = p_business_group_id
           and    pil_inner.per_in_ler_id       = pen_inner.per_in_ler_id
           and    (pen_inner.enrt_cvg_thru_dt is null or
                   pen_inner.enrt_cvg_thru_dt    = hr_api.g_eot
                  )
           and    pen_inner.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
         union
         select nvl(pen_inner.RPLCS_SSPNDD_RSLT_ID, -1)
             from  ben_le_clsn_n_rstr  pen_inner,
                    ben_per_in_ler pil_inner
             where  pil_inner.per_in_ler_id       = p_bckdt_per_in_ler_id
             and    pil_inner.person_id           = p_person_id
             and    pil_inner.business_group_id   = p_business_group_id
             AND    pil_inner.per_in_ler_id       = pen_inner.per_in_ler_id
             and    pen_inner.bkup_tbl_typ_cd     = 'BEN_PRTT_ENRT_RSLT_F'
           and    (pen_inner.enrt_cvg_thru_dt is null or
                   pen_inner.enrt_cvg_thru_dt    = hr_api.g_eot
                  )
           and    pen_inner.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
       )
   union
   select
          pen.EFFECTIVE_END_DATE,
          pen.ASSIGNMENT_ID,
          pen.BNFT_AMT,
          pen.BNFT_NNMNTRY_UOM,
          pen.BNFT_ORDR_NUM,
          pen.BNFT_TYP_CD,
          pen.BUSINESS_GROUP_ID,
          pen.COMP_LVL_CD,
          pen.CREATED_BY,
          pen.CREATION_DATE,
          pen.EFFECTIVE_START_DATE,
          pen.ENRT_CVG_STRT_DT,
          pen.ENRT_CVG_THRU_DT,
          pen.ENRT_MTHD_CD,
          pen.ENRT_OVRIDN_FLAG,
          pen.ENRT_OVRID_RSN_CD,
          pen.ENRT_OVRID_THRU_DT,
          pen.ERLST_DEENRT_DT,
          pen.LAST_UPDATED_BY,
          pen.LAST_UPDATE_DATE,
          pen.LAST_UPDATE_LOGIN,
          pen.LER_ID,
          pen.NO_LNGR_ELIG_FLAG,
          pen.OBJECT_VERSION_NUMBER,
          pen.OIPL_ID,
          pen.OIPL_ORDR_NUM,
          pen.ORGNL_ENRT_DT,
          pen.LCR_ATTRIBUTE1,
          pen.LCR_ATTRIBUTE10,
          pen.LCR_ATTRIBUTE11,
          pen.LCR_ATTRIBUTE12,
          pen.LCR_ATTRIBUTE13,
          pen.LCR_ATTRIBUTE14,
          pen.LCR_ATTRIBUTE15,
          pen.LCR_ATTRIBUTE16,
          pen.LCR_ATTRIBUTE17,
          pen.LCR_ATTRIBUTE18,
          pen.LCR_ATTRIBUTE19,
          pen.LCR_ATTRIBUTE2,
          pen.LCR_ATTRIBUTE20,
          pen.LCR_ATTRIBUTE21,
          pen.LCR_ATTRIBUTE22,
          pen.LCR_ATTRIBUTE23,
          pen.LCR_ATTRIBUTE24,
          pen.LCR_ATTRIBUTE25,
          pen.LCR_ATTRIBUTE26,
          pen.LCR_ATTRIBUTE27,
          pen.LCR_ATTRIBUTE28,
          pen.LCR_ATTRIBUTE29,
          pen.LCR_ATTRIBUTE3,
          pen.LCR_ATTRIBUTE30,
          pen.LCR_ATTRIBUTE4,
          pen.LCR_ATTRIBUTE5,
          pen.LCR_ATTRIBUTE6,
          pen.LCR_ATTRIBUTE7,
          pen.LCR_ATTRIBUTE8,
          pen.LCR_ATTRIBUTE9,
          pen.LCR_ATTRIBUTE_CATEGORY,
          pen.PERSON_ID,
          pen.PER_IN_LER_ID,
          pen.PGM_ID,
          pen.PLIP_ORDR_NUM,
          pen.PL_ID,
          pen.PL_ORDR_NUM,
          pen.PL_TYP_ID,
          pen.PROGRAM_APPLICATION_ID,
          pen.PROGRAM_ID,
          pen.PROGRAM_UPDATE_DATE,
          pen.bkup_tbl_id, -- Mapped to PRTT_ENRT_RSLT_ID,
          pen.PRTT_ENRT_RSLT_STAT_CD,
          pen.PRTT_IS_CVRD_FLAG,
          pen.PTIP_ID,
          pen.PTIP_ORDR_NUM,
          pen.REQUEST_ID,
          pen.RPLCS_SSPNDD_RSLT_ID,
          pen.SSPNDD_FLAG,
          pen.UOM
    from  ben_le_clsn_n_rstr  pen,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_bckdt_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.business_group_id   = p_business_group_id
    AND    pil.per_in_ler_id       = pen.per_in_ler_id
    and    pen.bkup_tbl_typ_cd     = 'BEN_PRTT_ENRT_RSLT_F'
    and    ((pen.enrt_cvg_thru_dt is null or
            pen.enrt_cvg_thru_dt    = hr_api.g_eot)  and
--bug#2604375 - added to control updated result rows for the same per_in_ler
            pen.effective_end_date  = hr_api.g_eot
           )
    and    pen.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
    and pen.bkup_tbl_id not in (
         select nvl(pen_inner.RPLCS_SSPNDD_RSLT_ID, -1)
           from   ben_prtt_enrt_rslt_f pen_inner,
                  ben_per_in_ler pil_inner
           where  pil_inner.per_in_ler_id       = p_bckdt_per_in_ler_id
           and    pil_inner.person_id           = p_person_id
           and    pil_inner.business_group_id = p_business_group_id
           and    pil_inner.per_in_ler_id       = pen_inner.per_in_ler_id
           and    (pen_inner.enrt_cvg_thru_dt is null or
                   pen_inner.enrt_cvg_thru_dt    = hr_api.g_eot
                  )
           and    pen_inner.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
         union
         select nvl(pen_inner.RPLCS_SSPNDD_RSLT_ID, -1)
             from  ben_le_clsn_n_rstr  pen_inner,
                    ben_per_in_ler pil_inner
             where  pil_inner.per_in_ler_id       = p_bckdt_per_in_ler_id
             and    pil_inner.person_id           = p_person_id
             and    pil_inner.business_group_id   = p_business_group_id
             AND    pil_inner.per_in_ler_id       = pen_inner.per_in_ler_id
             and    pen_inner.bkup_tbl_typ_cd     = 'BEN_PRTT_ENRT_RSLT_F'
           and    (pen_inner.enrt_cvg_thru_dt is null or
                   pen_inner.enrt_cvg_thru_dt    = hr_api.g_eot
                  )
           and    pen_inner.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
       )
    order by 1, 11 desc; -- pen.effective_end_date; -- Low to High
  --
  -- Get the electable choice data.
  --
  cursor c_epe_pen(cp_pl_id in number,
                   cp_pgm_id in number,
                   cp_oipl_id in number) is
    select epe.*,
           pel.enrt_typ_cycl_cd,
           pel.enrt_perd_end_dt,
           pel.enrt_perd_strt_dt,
           to_date('31-12-4712','DD-MM-YYYY') enrt_cvg_end_dt,
           pel.dflt_enrt_dt
    from   ben_elig_per_elctbl_chc epe,
           ben_per_in_ler pil,
           ben_pil_elctbl_chc_popl pel
    where  epe.per_in_ler_id     = p_per_in_ler_id
      and  epe.business_group_id = p_business_group_id
      and  epe.pl_id             = cp_pl_id
      and  nvl(epe.pgm_id, -1)   = nvl(cp_pgm_id, -1)
      and  nvl(epe.oipl_id, -1)  = nvl(cp_oipl_id, -1)
      and  pil.business_group_id = p_business_group_id
      and  pel.business_group_id = epe.business_group_id
      and  pil.person_id = p_person_id
      and  epe.per_in_ler_id = pil.per_in_ler_id
      and  pel.per_in_ler_id = epe.per_in_ler_id
      and  pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id;
  --
  l_epe_pen_rec c_epe_pen%rowtype;
  --
  cursor c_bnft(cp_elig_per_elctbl_chc_id in number,cp_ordr_num number ) is
     select enb.enrt_bnft_id,
            enb.entr_val_at_enrt_flag,
            enb.dflt_val,
            enb.val,
            enb.dflt_flag,
            enb.cvg_mlt_cd   --Bug 3315323
      from  ben_enrt_bnft enb
      where enb.elig_per_elctbl_chc_id = cp_elig_per_elctbl_chc_id
  -- Bug  2526994 we need take the right one
  --    and   nvl(enb.mx_wo_ctfn_flag,'N') = 'N' ;
        and enb.ordr_num = cp_ordr_num ; --This is more accurate
  --
  l_bnft_rec            c_bnft%rowtype;
  l_bnft_rec_reset      c_bnft%rowtype;
  l_bnft_entr_val_found boolean;
  l_num_bnft_recs       number := 0;
  --
  cursor c_rt(cp_elig_per_elctbl_chc_id number,
              cp_enrt_bnft_id           number) is
      select ecr.enrt_rt_id,
             ecr.dflt_val,
             ecr.val,
             ecr.entr_val_at_enrt_flag,
             ecr.acty_base_rt_id
      from   ben_enrt_rt ecr
      where  ecr.elig_per_elctbl_chc_id = cp_elig_per_elctbl_chc_id
      and    ecr.business_group_id = p_business_group_id
      and    ecr.entr_val_at_enrt_flag = 'Y'
      and    ecr.spcl_rt_enrt_rt_id is null
  --    and    ecr.prtt_rt_val_id is null
      union
      select ecr.enrt_rt_id,
             ecr.dflt_val,
             ecr.val,
             ecr.entr_val_at_enrt_flag,
             ecr.acty_base_rt_id
      from   ben_enrt_rt ecr
      where  ecr.enrt_bnft_id = cp_enrt_bnft_id
      and    ecr.business_group_id = p_business_group_id
      and    ecr.entr_val_at_enrt_flag = 'Y'
      and    ecr.spcl_rt_enrt_rt_id is null;
  --    and    ecr.prtt_rt_val_id is null;
  --
  l_rt c_rt%rowtype;
  --
  type g_rt_rec is record
      (enrt_rt_id ben_enrt_rt.enrt_rt_id%type,
       dflt_val   ben_enrt_rt.dflt_val%type,
       calc_val   ben_enrt_rt.dflt_val%type,
       cmcd_rt_val number,
       ann_rt_val  number);
  --
  type g_rt_table is table of g_rt_rec index by binary_integer;
  --
  l_rt_table g_rt_table;
  l_count    number;
  --
  type pgm_rec is record
       (pgm_id        ben_pgm_f.pgm_id%type,
        enrt_mthd_cd  ben_prtt_enrt_rslt_f.enrt_mthd_cd%type,
        multi_row_edit_done boolean,
        non_automatics_flag boolean,
        max_enrt_esd  date);
  --
  type pl_rec is record
       (pl_id         ben_pl_f.pl_id%type,
        enrt_mthd_cd  ben_prtt_enrt_rslt_f.enrt_mthd_cd%type,
        multi_row_edit_done boolean,
        max_enrt_esd  date);
  --
  type enrt_rec is record
       (prtt_enrt_rslt_id        ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%type,
        bckdt_prtt_enrt_rslt_id  ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%type,
        bckdt_enrt_ovridn_flag    varchar2(1),
        bckdt_enrt_cvg_strt_dt   date,
        bckdt_enrt_cvg_thru_dt   date,
        g_sys_date               date,
        pen_ovn_number           ben_prtt_enrt_rslt_f.object_version_number%type,
        old_pl_id                ben_prtt_enrt_rslt_f.pl_id%type,
        new_pl_id                ben_prtt_enrt_rslt_f.pl_id%type,
        old_oipl_id              ben_prtt_enrt_rslt_f.oipl_id%type,
        new_oipl_id              ben_prtt_enrt_rslt_f.oipl_id%type,
        old_pl_typ_id            ben_prtt_enrt_rslt_f.pl_typ_id%type,
        new_pl_typ_id            ben_prtt_enrt_rslt_f.pl_typ_id%type,
        pgm_id                   ben_prtt_enrt_rslt_f.pgm_id%type,
        ler_id                   ben_ler_f.ler_id%type,
        elig_per_elctbl_chc_id   ben_elig_per_elctbl_chc.elig_per_elctbl_chc_id%type,
        dpnt_cvg_strt_dt_cd      ben_elig_per_elctbl_chc.dpnt_cvg_strt_dt_cd%type,
        dpnt_cvg_strt_dt_rl      ben_elig_per_elctbl_chc.dpnt_cvg_strt_dt_rl%type,
        effective_start_date     ben_prtt_enrt_rslt_f.effective_start_date%type
        );
  --
  type t_pgm_table is table of pgm_rec index by binary_integer;
  type t_pl_table is table of pl_rec index by binary_integer;
  type t_enrt_table is table of enrt_rec index by binary_integer;
  type t_prtt_rt_val_table is table of number index by binary_integer;
  l_pgm_table     t_pgm_table;
  l_pl_table      t_pl_table;
  l_enrt_table    t_enrt_table;
  l_pgm_count     number;
  l_pl_count      number;
  l_enrt_count    number;
  l_prtt_rt_val_table t_prtt_rt_val_table;
  --
  cursor c_prv(cv_prtt_enrt_rslt_id in number,
               cv_acty_base_rt_id   in number) is
         select  prv.*
         from ben_prtt_rt_val prv
         where prv.prtt_enrt_rslt_id      = cv_prtt_enrt_rslt_id
           and prv.per_in_ler_id     = p_bckdt_per_in_ler_id
           and prv.business_group_id = p_business_group_id
           and prv.acty_base_rt_id   = cv_acty_base_rt_id;
  --
  l_prv_rec c_prv%rowtype;
  l_prv_rec_nulls c_prv%rowtype;
  --
  cursor c_bckt_csd_pen(cv_per_in_ler_id in number) is
         select pen.*, pil.lf_evt_ocrd_dt
         from ben_prtt_enrt_rslt_f pen,
              ben_per_in_ler pil
         where pen.per_in_ler_id = cv_per_in_ler_id
           and pen.per_in_ler_id = pil.per_in_ler_id
           and pen.business_group_id = p_business_group_id
           and pil.business_group_id = p_business_group_id
           and pen.prtt_enrt_rslt_stat_cd is null
           and pen.effective_end_date = hr_api.g_eot
           and pen.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
           and (pen.enrt_cvg_thru_dt is null or
                pen.enrt_cvg_thru_dt    = hr_api.g_eot
               );
  type t_bckt_csd_pen_table is table of c_bckt_csd_pen%rowtype index by binary_integer;
  l_bckt_csd_pil_enrt_table t_bckt_csd_pen_table;
  l_bckt_csd_pen_esd        date;
  l_bckt_csd_pil_leod       date;
  -- Bug 2677804 Added new parameter to see the thru date
  cursor c_ovridn_rt(v_bckdt_pen_id number
                    ,v_new_pen_id   number ) is
  select prv2.prtt_rt_val_id new_prv_id,
         prv2.object_version_number new_prv_ovn,
         prv1.*
    from ben_prtt_rt_val prv1, ben_prtt_rt_val prv2
   where prv1.prtt_enrt_rslt_id = v_bckdt_pen_id
     and prv2.prtt_enrt_rslt_id = v_new_pen_id
     and prv1.acty_base_rt_id = prv2.acty_base_rt_id
     and prv1.rt_ovridn_flag = 'Y'
     and prv1.rt_end_dt <> hr_api.g_eot
     and prv1.rt_ovridn_thru_dt >= prv2.rt_strt_dt
--     and prv1.prtt_rt_val_stat_cd is null
     and prv2.prtt_rt_val_stat_cd is null
     and prv2.per_in_ler_id = p_per_in_ler_id ;
  --
  cursor c_ovridn_dpnt(v_bckdt_pen_id number
                      ,v_new_pen_id   number
                      ,v_effective_date date) is
  select pdp2.elig_cvrd_dpnt_id new_pdp_id,
         pdp2.object_version_number new_pdp_ovn,
         pdp1.*
    from ben_elig_cvrd_dpnt_f pdp1,
         ben_elig_cvrd_dpnt_f pdp2
   where pdp1.prtt_enrt_rslt_id = v_bckdt_pen_id
     and pdp2.prtt_enrt_rslt_id = v_new_pen_id
     and pdp1.dpnt_person_id = pdp2.dpnt_person_id
     and pdp1.ovrdn_flag = 'Y'
     and v_effective_date between pdp1.effective_start_date
                              and pdp1.effective_end_date
     and v_effective_date between pdp2.effective_start_date
                            and pdp2.effective_end_date;
  --
  cursor c_ovn(v_prtt_enrt_rslt_id number) is
  select object_version_number
    from ben_prtt_enrt_rslt_f
   where prtt_enrt_rslt_id = v_prtt_enrt_rslt_id
     and effective_end_date = hr_api.g_eot;
  --
  cursor c_prv_ovn (v_prtt_rt_val_id number) is
    select prv.*
          ,abr.input_value_id
          ,abr.element_type_id
    from   ben_prtt_rt_val  prv,
           ben_acty_base_rt_f abr
    where  prtt_rt_val_id = v_prtt_rt_val_id
       and abr.acty_base_rt_id=prv.acty_base_rt_id
       and abr.business_group_id = p_business_group_id
       and p_effective_date between
             abr.effective_start_date and abr.effective_end_date;
  --
  l_upd_rt_val            boolean;
  l_prv_ovn               c_prv_ovn%rowtype;
  l_suspend_flag          varchar2(30);
  l_prtt_rt_val_id1       number;
  l_prtt_rt_val_id2       number;
  l_prtt_rt_val_id3       number;
  l_prtt_rt_val_id4       number;
  l_prtt_rt_val_id5       number;
  l_prtt_rt_val_id6       number;
  l_prtt_rt_val_id7       number;
  l_prtt_rt_val_id8       number;
  l_prtt_rt_val_id9       number;
  l_prtt_rt_val_id10      number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_dpnt_actn_warning     boolean;
  l_bnf_actn_warning      boolean;
  l_ctfn_actn_warning     boolean;
  l_prtt_enrt_interim_id  number;
  l_prtt_enrt_rslt_id     number;
  l_object_version_number number;
  l_cls_enrt_flag         boolean := FALSE;
  l_prev_pgm_id           number := NULL; -- Do not change it
  l_enrt_mthd_cd          varchar2(30);
  l_found                 boolean;
  l_enrt_cnt              number := 1;
  l_max_enrt_esd          date;
  l_esd_out               date;
  l_eed_out               date;
  l_ovn                   number(15);
  --RCHASE - ensure automatics are handled differently than
  --         form enrollments by process_post_enrollment
  l_proc_cd               varchar2(30);
  --
  l_found_non_automatics  boolean;
  l_dummy_number          number;
  --
  l_enrt_cvg_strt_dt      date;
  --

begin
  --
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  open c_bckdt_pil;
  fetch c_bckdt_pil into l_bckdt_pil_prev_stat_cd, l_bckdt_pil_ovn, l_bckt_csd_per_in_ler_id;
  close c_bckdt_pil;
  if l_bckdt_pil_prev_stat_cd = 'PROCD' then
     --
     l_cls_enrt_flag := TRUE;
     --
  end if;
  l_pgm_table.delete;
  l_pl_table.delete;
  l_enrt_table.delete;
  l_bckt_csd_pil_enrt_table.delete;
  --
  -- Get the enrollment results attached to per in ler which
  -- caused the back out of currenlty backed out per in ler.
  --
  if l_bckt_csd_per_in_ler_id is not null then
     --
     for l_bckt_csd_pen_rec in c_bckt_csd_pen(l_bckt_csd_per_in_ler_id) loop
         --
         l_bckt_csd_pil_enrt_table(l_enrt_cnt) := l_bckt_csd_pen_rec;
         l_enrt_cnt := l_enrt_cnt + 1;
         --
     end loop;
     --
  end if;
  --
  -- For each of the enrollment result in back up table, create
  -- a enrollment.
  --
  FOR l_bckdt_pen_rec in c_bckdt_pen loop
    --
    -- If the enrollment record is valid for the current
    -- effective_date then recreate the enrollment.
    --
    hr_utility.set_location('Inside BCKDT pen loop ' || l_proc,20);
    --
    -- if p_effective_date <= l_bckdt_pen_rec.effective_end_date
    --
    l_bckt_csd_pen_esd  := null;
    l_bckt_csd_pil_leod := null;
    if nvl(l_bckt_csd_pil_enrt_table.last,0) > 0 then
       --
       for l_cnt in 1..l_bckt_csd_pil_enrt_table.LAST loop
           --
           if nvl(l_bckt_csd_pil_enrt_table(l_cnt).pl_id, -1) = nvl(l_bckdt_pen_rec.pl_id, -1) and
              nvl(l_bckt_csd_pil_enrt_table(l_cnt).pgm_id, -1) = nvl(l_bckdt_pen_rec.pgm_id, -1) and
              nvl(l_bckt_csd_pil_enrt_table(l_cnt).oipl_id, -1) = nvl(l_bckdt_pen_rec.oipl_id, -1)
           then
                 l_bckt_csd_pen_esd := l_bckt_csd_pil_enrt_table(l_cnt).effective_start_date;
                 l_bckt_csd_pil_leod := l_bckt_csd_pil_enrt_table(l_cnt).lf_evt_ocrd_dt;
                 exit;
           end if;
           --
       end loop;
       --
    end if;
    --
    open c_epe_pen(l_bckdt_pen_rec.pl_id,
                     l_bckdt_pen_rec.pgm_id,
                     l_bckdt_pen_rec.oipl_id);
    fetch c_epe_pen into l_epe_pen_rec;
    close c_epe_pen;
    hr_utility.set_location('After epe fetch ' || l_proc,30);
    --
     g_sys_date := greatest(trunc(l_epe_pen_rec.enrt_perd_strt_dt),
                    nvl(nvl(l_bckt_csd_pen_esd, g_bckt_csd_lf_evt_ocrd_dt), hr_api.g_sot),
                    l_bckdt_pen_rec.effective_start_date);
    /*
    g_sys_date := greatest(trunc(sysdate),
                    nvl(nvl(l_bckt_csd_pen_esd, g_bckt_csd_lf_evt_ocrd_dt), hr_api.g_sot) + 1,
                    l_bckdt_pen_rec.effective_start_date);
    */
    --
    l_max_enrt_esd := greatest(g_sys_date, nvl(l_max_enrt_esd, hr_api.g_sot));
    --
    --
    hr_utility.set_location('Date used to reinstate the enrollment = ' || g_sys_date, 333);
    if g_sys_date <= l_bckdt_pen_rec.effective_end_date
    then
       --
       -- Get the benefits Information.
       --
       l_num_bnft_recs := 0;
       l_bnft_entr_val_found := FALSE;
       l_bnft_rec := l_bnft_rec_reset;
       --
       open c_bnft(l_epe_pen_rec.elig_per_elctbl_chc_id,l_bckdt_pen_rec.bnft_ordr_num );
       loop
         --

         hr_utility.set_location('Inside bnft loop ' || l_proc,40);
         --Bug 3315323 we need to reinstate the previuos benefit amount for the case
         --of SAAEAR also as enb record may have null value there for first enrollment
         --or it may not be the right amount.
         --
         fetch c_bnft into l_bnft_rec;
         exit when c_bnft%notfound;
         if l_bnft_rec.entr_val_at_enrt_flag = 'Y' OR l_bnft_rec.cvg_mlt_cd='SAAEAR' then
            l_bnft_entr_val_found := TRUE;
         end if;
         l_num_bnft_recs := l_num_bnft_recs + 1;
         --
         if l_bckdt_pen_rec.BNFT_AMT = l_bnft_rec.VAL then
            --
            -- Found the benefit we are looking for, so exit.
            --
            exit;
            --
         end if;
         --
       end loop;
       --
       -- Bug 5282 :  When a backed out life event is repeocessed
       -- plans with enter 'enter val at enrollment' coverage amount
       -- previous amount is not used when enrollments reinstated.
       --
       if l_bnft_entr_val_found
       then
         if l_num_bnft_recs =  0 then
            null;
            -- This is a error condition, so rollback all the reinstate process.
         else
            --
            l_bnft_rec.val := l_bckdt_pen_rec.BNFT_AMT;
            --
         end if;
       end if;
       hr_utility.set_location(l_proc,50);
       close c_bnft;
       --
       for l_count in 1..10 loop
          --
          -- Initialise array to null
          --
          l_rt_table(l_count).enrt_rt_id := null;
          l_rt_table(l_count).dflt_val := null;
          --
       end loop;
       --
       -- Now get the rates.
       --
       l_count:= 0;
       --
       for l_rec in c_rt(l_epe_pen_rec.elig_per_elctbl_chc_id,
                         l_bnft_rec.enrt_bnft_id)
       loop
          --
          hr_utility.set_location('Inside rate loop ' ||l_proc,50);
          --
          -- Get the prtt rate val for this enrollment result.
          -- Use to pass to the enrollment process.
          --
          -- Bug : 1634870 : If the user not selected the rate before backout
          -- then do not pass it to the reinstate process.
          --
          hr_utility.set_location('enrt_rt_id : dflt_val : val : entr_val' ||
                                  '_at_enrt_flag : acty_base_rt_id : ' , 501);
          hr_utility.set_location(l_rec.enrt_rt_id || ' : ' || l_rec.dflt_val || ' : ' || l_rec.val || ' : '
                                  || l_rec.entr_val_at_enrt_flag || ' : ' ||
                                  l_rec.acty_base_rt_id, 501);
          --
          l_prv_rec := l_prv_rec_nulls;
          open c_prv(l_bckdt_pen_rec.prtt_enrt_rslt_id ,
                     l_rec.acty_base_rt_id);
          fetch c_prv into l_prv_rec;
          if c_prv%found then -- l_prv_rec.prtt_rt_val_id is not null then
             --
             l_count := l_count+1;
             hr_utility.set_location('prtt_rt_val_id : rt_val : ' ||
                     l_prv_rec.prtt_rt_val_id ||  ' : ' || l_prv_rec.rt_val
                     || ' : ' || l_prv_rec.acty_base_rt_id , 502);
             l_rt_table(l_count).enrt_rt_id := l_rec.enrt_rt_id;
             if l_prv_rec.mlt_cd in ('CL','CVG','AP','PRNT','CLANDCVG','APANDCVG','PRNTANDCVG') then
                l_rt_table(l_count).dflt_val := l_rec.dflt_val;
                l_rt_table(l_count).calc_val := l_prv_rec.rt_val;
                l_rt_table(l_count).cmcd_rt_val := l_prv_rec.cmcd_rt_val;
                l_rt_table(l_count).ann_rt_val  := l_prv_rec.ann_rt_val;
             else
                l_rt_table(l_count).dflt_val   := l_prv_rec.rt_val;
                l_rt_table(l_count).calc_val   := l_prv_rec.rt_val;
                l_rt_table(l_count).cmcd_rt_val := l_prv_rec.cmcd_rt_val;
                l_rt_table(l_count).ann_rt_val  := l_prv_rec.ann_rt_val;
             end if;
             --
          end if;
          close c_prv;
          --
       end loop;
       --
       -- Call election information batch process
       --
       -- initialize all the out parameters.
       l_suspend_flag          := null;
       l_prtt_rt_val_id1       := null;
       l_prtt_rt_val_id2       := null;
       l_prtt_rt_val_id3       := null;
       l_prtt_rt_val_id4       := null;
       l_prtt_rt_val_id5       := null;
       l_prtt_rt_val_id6       := null;
       l_prtt_rt_val_id7       := null;
       l_prtt_rt_val_id8       := null;
       l_prtt_rt_val_id9       := null;
       l_prtt_rt_val_id10      := null;
       l_effective_start_date  := null;
       l_effective_end_date    := null;
       l_dpnt_actn_warning     := null;
       l_bnf_actn_warning      := null;
       l_ctfn_actn_warning     := null;
       l_prtt_enrt_interim_id  := null;
       l_prtt_enrt_rslt_id     := null;
       l_object_version_number := null;
       l_enrt_cvg_strt_dt := null;

       -- if cvg_st_dt_cd is enterable then copy the l_bckdt_pen_rec.enrt_cvg_strt_dt
       -- 5746429 starts

       if  l_epe_pen_rec.enrt_cvg_strt_dt_cd = 'ENTRBL'
        then
	      l_enrt_cvg_strt_dt := l_bckdt_pen_rec.enrt_cvg_strt_dt ;
       end if ;
       -- 5746429 ends
       hr_utility.set_location('Calling ben_election_information ' ||l_proc,60);
       hr_utility.set_location('Calling l_bnft_rec.val ' ||l_bnft_rec.val,60);
       hr_utility.set_location('Calling l_enrt_cvg_strt_dt ' ||l_enrt_cvg_strt_dt,60);
       --
       --

       ben_election_information.election_information
          (p_elig_per_elctbl_chc_id => l_epe_pen_rec.elig_per_elctbl_chc_id,
           p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id,-- l_epe_pen_rec.prtt_enrt_rslt_id,
           p_effective_date         => g_sys_date,
           p_enrt_mthd_cd           => l_bckdt_pen_rec.enrt_mthd_cd,
           p_business_group_id      => p_business_group_id,
           p_enrt_bnft_id           => l_bnft_rec.enrt_bnft_id,
           p_bnft_val               => l_bnft_rec.val,
	       p_enrt_cvg_strt_dt       => l_enrt_cvg_strt_dt, -- 5746429
           p_enrt_rt_id1            => l_rt_table(1).enrt_rt_id,
           p_rt_val1                => l_rt_table(1).dflt_val,
           p_ann_rt_val1            => l_rt_table(1).ann_rt_val,
           p_enrt_rt_id2            => l_rt_table(2).enrt_rt_id,
           p_rt_val2                => l_rt_table(2).dflt_val,
           p_ann_rt_val2            => l_rt_table(2).ann_rt_val,
           p_enrt_rt_id3            => l_rt_table(3).enrt_rt_id,
           p_rt_val3                => l_rt_table(3).dflt_val,
           p_ann_rt_val3            => l_rt_table(3).ann_rt_val,
           p_enrt_rt_id4            => l_rt_table(4).enrt_rt_id,
           p_rt_val4                => l_rt_table(4).dflt_val,
           p_ann_rt_val4            => l_rt_table(4).ann_rt_val,
           p_enrt_rt_id5            => l_rt_table(5).enrt_rt_id,
           p_rt_val5                => l_rt_table(5).dflt_val,
           p_ann_rt_val5            => l_rt_table(5).ann_rt_val,
           p_enrt_rt_id6            => l_rt_table(6).enrt_rt_id,
           p_rt_val6                => l_rt_table(6).dflt_val,
           p_ann_rt_val6            => l_rt_table(6).ann_rt_val,
           p_enrt_rt_id7            => l_rt_table(7).enrt_rt_id,
           p_rt_val7                => l_rt_table(7).dflt_val,
           p_ann_rt_val7            => l_rt_table(7).ann_rt_val,
           p_enrt_rt_id8            => l_rt_table(8).enrt_rt_id,
           p_rt_val8                => l_rt_table(8).dflt_val,
           p_ann_rt_val8            => l_rt_table(8).ann_rt_val,
           p_enrt_rt_id9            => l_rt_table(9).enrt_rt_id,
           p_rt_val9                => l_rt_table(9).dflt_val,
           p_ann_rt_val9            => l_rt_table(9).ann_rt_val,
           p_enrt_rt_id10           => l_rt_table(10).enrt_rt_id,
           p_rt_val10               => l_rt_table(10).dflt_val,
           p_ann_rt_val10           => l_rt_table(10).ann_rt_val,
           p_datetrack_mode         => hr_api.g_insert, --
           p_suspend_flag           => l_suspend_flag,
           p_called_from_sspnd      => 'N',
           p_prtt_enrt_interim_id   => l_prtt_enrt_interim_id,
           p_prtt_rt_val_id1        => l_prtt_rt_val_id1,
           p_prtt_rt_val_id2        => l_prtt_rt_val_id2,
           p_prtt_rt_val_id3        => l_prtt_rt_val_id3,
           p_prtt_rt_val_id4        => l_prtt_rt_val_id4,
           p_prtt_rt_val_id5        => l_prtt_rt_val_id5,
           p_prtt_rt_val_id6        => l_prtt_rt_val_id6,
           p_prtt_rt_val_id7        => l_prtt_rt_val_id7,
           p_prtt_rt_val_id8        => l_prtt_rt_val_id8,
           p_prtt_rt_val_id9        => l_prtt_rt_val_id9,
           p_prtt_rt_val_id10       => l_prtt_rt_val_id10,
           -- 6131609 : reinstate DFF values
            p_pen_attribute_category => l_bckdt_pen_rec.pen_attribute_category,
            p_pen_attribute1  => l_bckdt_pen_rec.pen_attribute1,
            p_pen_attribute2  => l_bckdt_pen_rec.pen_attribute2,
            p_pen_attribute3  => l_bckdt_pen_rec.pen_attribute3,
            p_pen_attribute4  => l_bckdt_pen_rec.pen_attribute4,
            p_pen_attribute5  => l_bckdt_pen_rec.pen_attribute5,
            p_pen_attribute6  => l_bckdt_pen_rec.pen_attribute6,
            p_pen_attribute7  => l_bckdt_pen_rec.pen_attribute7,
            p_pen_attribute8  => l_bckdt_pen_rec.pen_attribute8,
            p_pen_attribute9  => l_bckdt_pen_rec.pen_attribute9,
            p_pen_attribute10 => l_bckdt_pen_rec.pen_attribute10,
            p_pen_attribute11 => l_bckdt_pen_rec.pen_attribute11,
            p_pen_attribute12 => l_bckdt_pen_rec.pen_attribute12,
            p_pen_attribute13 => l_bckdt_pen_rec.pen_attribute13,
            p_pen_attribute14 => l_bckdt_pen_rec.pen_attribute14,
            p_pen_attribute15 => l_bckdt_pen_rec.pen_attribute15,
            p_pen_attribute16 => l_bckdt_pen_rec.pen_attribute16,
            p_pen_attribute17 => l_bckdt_pen_rec.pen_attribute17,
            p_pen_attribute18 => l_bckdt_pen_rec.pen_attribute18,
            p_pen_attribute19 => l_bckdt_pen_rec.pen_attribute19,
            p_pen_attribute20 => l_bckdt_pen_rec.pen_attribute20,
            p_pen_attribute21 => l_bckdt_pen_rec.pen_attribute21,
            p_pen_attribute22 => l_bckdt_pen_rec.pen_attribute22,
            p_pen_attribute23 => l_bckdt_pen_rec.pen_attribute23,
            p_pen_attribute24 => l_bckdt_pen_rec.pen_attribute24,
            p_pen_attribute25 => l_bckdt_pen_rec.pen_attribute25,
            p_pen_attribute26 => l_bckdt_pen_rec.pen_attribute26,
            p_pen_attribute27 => l_bckdt_pen_rec.pen_attribute27,
            p_pen_attribute28 => l_bckdt_pen_rec.pen_attribute28,
            p_pen_attribute29 => l_bckdt_pen_rec.pen_attribute29,
            p_pen_attribute30 => l_bckdt_pen_rec.pen_attribute30,
            --
           p_object_version_number  => l_object_version_number,
           p_effective_start_date   => l_effective_start_date,
           p_effective_end_date     => l_effective_end_date,
           p_dpnt_actn_warning      => l_dpnt_actn_warning,
           p_bnf_actn_warning       => l_bnf_actn_warning,
           p_ctfn_actn_warning      => l_ctfn_actn_warning);
       --

       l_prtt_rt_val_table(1)       := l_prtt_rt_val_id1;
       l_prtt_rt_val_table(2)       := l_prtt_rt_val_id2;
       l_prtt_rt_val_table(3)       := l_prtt_rt_val_id3;
       l_prtt_rt_val_table(4)       := l_prtt_rt_val_id4;
       l_prtt_rt_val_table(5)       := l_prtt_rt_val_id5;
       l_prtt_rt_val_table(6)       := l_prtt_rt_val_id6;
       l_prtt_rt_val_table(7)       := l_prtt_rt_val_id7;
       l_prtt_rt_val_table(8)       := l_prtt_rt_val_id8;
       l_prtt_rt_val_table(9)       := l_prtt_rt_val_id9;
       l_prtt_rt_val_table(10)      := l_prtt_rt_val_id10;



       -- if rate is enter value at enrollment and calculation method is like multiple and
       -- calculate flag is on, first the prtt_rt_val is created with default value and
       -- subsequently the calculated value is updated by taking values from backedout rows
       for i  in 1..l_count loop
          l_upd_rt_val  := FALSE;
          open c_prv_ovn (l_prtt_rt_val_table(i));
          fetch c_prv_ovn into l_prv_ovn;
          if c_prv_ovn%found then
              if l_prv_ovn.rt_val <>l_rt_table(i).calc_val  then
                 l_upd_rt_val := TRUE;
              end if;
          end if;
          close c_prv_ovn;
          if l_upd_rt_val then
              ben_prtt_rt_val_api.update_prtt_rt_val
                (p_prtt_rt_val_id        => l_prtt_rt_val_table(i)
                ,p_person_id             => p_person_id
                ,p_rt_val                => l_rt_table(i).calc_val
                ,p_acty_ref_perd_cd      => l_prv_ovn.acty_ref_perd_cd
                ,p_cmcd_rt_val           => l_rt_table(i).cmcd_rt_val
                ,p_cmcd_ref_perd_cd      => l_prv_ovn.cmcd_ref_perd_cd
                ,p_ann_rt_val            => l_rt_table(i).ann_rt_val
                ,p_business_group_id     => p_business_group_id
                ,p_object_version_number => l_prv_ovn.object_version_number
                ,p_effective_date        => g_sys_date);
              --
          end if;
       end loop;



       -- Populate the enrollment results electble choice data
       -- to be used for dependents and beneficiaries restoration.
       -- the reinstate beneficiaries and dependents processes
       -- from hare as multi row edit process may create
       -- these records as part of recycle. So reinstate beneficiaries
       -- and dependents processes should be called after multi row edits.
       --
       l_found := FALSE;
       if nvl(l_enrt_table.LAST, 0) > 0 then
          for l_cnt in 1..l_enrt_table.LAST loop
              --
              if l_enrt_table(l_cnt).prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
              then
                 l_found := TRUE;
                 exit;
              end if;
              --
           end loop;
       end if;
       --
       if not l_found then
          --
          --
          l_enrt_count := nvl(l_enrt_table.LAST, 0) + 1;
          l_enrt_table(l_enrt_count).prtt_enrt_rslt_id := l_prtt_enrt_rslt_id;
          l_enrt_table(l_enrt_count).effective_start_date := l_effective_start_date;
          l_enrt_table(l_enrt_count).bckdt_prtt_enrt_rslt_id
                                           := l_bckdt_pen_rec.prtt_enrt_rslt_id;
          l_enrt_table(l_enrt_count).bckdt_enrt_ovridn_flag
                                           := l_bckdt_pen_rec.enrt_ovridn_flag;
          l_enrt_table(l_enrt_count).bckdt_enrt_cvg_strt_dt
                                           := l_bckdt_pen_rec.enrt_cvg_strt_dt;
          l_enrt_table(l_enrt_count).bckdt_enrt_cvg_thru_dt
                                           := l_bckdt_pen_rec.enrt_cvg_thru_dt;
          l_enrt_table(l_enrt_count).g_sys_date := g_sys_date;
          l_enrt_table(l_enrt_count).pen_ovn_number := l_object_version_number;
          l_enrt_table(l_enrt_count).old_pl_id := l_bckdt_pen_rec.pl_id;
          l_enrt_table(l_enrt_count).new_pl_id := l_bckdt_pen_rec.pl_id;
          l_enrt_table(l_enrt_count).old_oipl_id := l_bckdt_pen_rec.oipl_id;
          l_enrt_table(l_enrt_count).new_oipl_id := l_bckdt_pen_rec.oipl_id;
          l_enrt_table(l_enrt_count).old_pl_typ_id := l_bckdt_pen_rec.pl_typ_id;
          l_enrt_table(l_enrt_count).new_pl_typ_id := l_bckdt_pen_rec.pl_typ_id;
          l_enrt_table(l_enrt_count).pgm_id := l_bckdt_pen_rec.pgm_id;
          l_enrt_table(l_enrt_count).ler_id := null;
          l_enrt_table(l_enrt_count).elig_per_elctbl_chc_id
                                           := l_epe_pen_rec.elig_per_elctbl_chc_id;
          l_enrt_table(l_enrt_count).dpnt_cvg_strt_dt_cd
                                           := l_epe_pen_rec.dpnt_cvg_strt_dt_cd;
          l_enrt_table(l_enrt_count).dpnt_cvg_strt_dt_rl
                                           := l_epe_pen_rec.dpnt_cvg_strt_dt_rl;
          /* Trace messages for the enrollments, uncomment for tracing bugs */
          hr_utility.set_location('prtt_enrt_rslt_id = ' ||
                     l_enrt_table(l_enrt_count).prtt_enrt_rslt_id, 9999);
          hr_utility.set_location('bckdt_prtt_enrt_rslt_id = ' ||
                     l_enrt_table(l_enrt_count).bckdt_prtt_enrt_rslt_id, 9999);
          hr_utility.set_location('bckdt_enrt_ovridn_flag = ' ||
                     l_enrt_table(l_enrt_count).bckdt_enrt_ovridn_flag, 72);
          hr_utility.set_location('bckdt_enrt_cvg_strt_dt = ' ||
                     l_enrt_table(l_enrt_count).bckdt_enrt_cvg_strt_dt, 72);
          hr_utility.set_location('pen_ovn_number = ' ||
                     l_enrt_table(l_enrt_count).pen_ovn_number, 9999);
          hr_utility.set_location('old_pl_id = ' ||
                     l_enrt_table(l_enrt_count).old_pl_id, 9999);
          hr_utility.set_location('new_pl_id = ' ||
                     l_enrt_table(l_enrt_count).new_pl_id, 9999);
          hr_utility.set_location('old_oipl_id = ' ||
                     l_enrt_table(l_enrt_count).old_oipl_id, 9999);
          hr_utility.set_location('new_oipl_id = ' ||
                     l_enrt_table(l_enrt_count).new_oipl_id, 9999);
          hr_utility.set_location('old_pl_typ_id = ' ||
                     l_enrt_table(l_enrt_count).old_pl_typ_id, 9999);
          hr_utility.set_location('new_pl_typ_id = ' ||
                     l_enrt_table(l_enrt_count).new_pl_typ_id, 9999);
          hr_utility.set_location('pgm_id = ' ||
                     l_enrt_table(l_enrt_count).pgm_id, 9999);
          hr_utility.set_location('elig_per_elctbl_chc_id = ' ||
                     l_enrt_table(l_enrt_count).elig_per_elctbl_chc_id, 9999);
          /**/
          --
       end if;
       --
       -- Populate the pgm and pl tables, to pocess post results.
       --
       if l_epe_pen_rec.pgm_id is null then
          --
          --
          l_found := FALSE;
          if nvl(l_pl_table.LAST, 0) > 0 then
             --
             --
             for l_cnt in 1..l_pl_table.LAST loop
                 --
	         --
                 if l_pl_table(l_cnt).pl_id = l_epe_pen_rec.pl_id  and
                    l_pl_table(l_cnt).enrt_mthd_cd = l_bckdt_pen_rec.enrt_mthd_cd
                 then
                    l_found := TRUE;
                    l_pl_table(l_cnt).max_enrt_esd := greatest(l_pl_table(l_cnt).max_enrt_esd,
                                                               g_sys_date);
                    exit;
                 end if;
                 --
             end loop;
          end if;
          --
          if not l_found then
             --
             --
             l_pl_count := nvl(l_pl_table.LAST, 0) + 1;
             l_pl_table(l_pl_count).pl_id            := l_epe_pen_rec.pl_id;
             l_pl_table(l_pl_count).enrt_mthd_cd     := l_bckdt_pen_rec.enrt_mthd_cd;
             l_pl_table(l_pl_count).multi_row_edit_done := FALSE;
             l_pl_table(l_pl_count).max_enrt_esd := g_sys_date;
             --
          end if;
       else
          --
          l_found := FALSE;
          --
	  --
          if nvl(l_pgm_table.LAST, 0) > 0 then
             for l_cnt in 1..l_pgm_table.LAST loop
                 --
                 --

                 if l_pgm_table(l_cnt).pgm_id = l_epe_pen_rec.pgm_id and
                    l_pgm_table(l_cnt).enrt_mthd_cd = l_bckdt_pen_rec.enrt_mthd_cd
                 then
                    l_found := TRUE;
                    l_pgm_table(l_cnt).max_enrt_esd := greatest(l_pgm_table(l_cnt).max_enrt_esd,
                                                               g_sys_date);
                    exit;
                 end if;
                 --
             end loop;
          end if;
          --
          if not l_found then
             --
             --
             l_pgm_count := nvl(l_pgm_table.LAST, 0) + 1;
             l_pgm_table(l_pgm_count).pgm_id         := l_epe_pen_rec.pgm_id;
             l_pgm_table(l_pgm_count).enrt_mthd_cd   := l_bckdt_pen_rec.enrt_mthd_cd;
             l_pgm_table(l_pgm_count).multi_row_edit_done := FALSE;
             l_pgm_table(l_pgm_count).max_enrt_esd := g_sys_date;
             --
          end if;
          --
       end if;
       --
    end if;
    --
  end loop;
  --
  -- Apply the multi row edits.
  --
  if nvl(l_pgm_table.LAST, 0) > 0 then
     for l_cnt in 1..l_pgm_table.LAST loop
        --
        -- First see multi row edits are already checked.
        --
        l_found  := FALSE;
        for l_inn_cnt in 1..l_cnt loop
          if l_pgm_table(l_inn_cnt).pgm_id = l_pgm_table(l_cnt).pgm_id and
             l_pgm_table(l_inn_cnt).multi_row_edit_done
          then
             l_found  := TRUE;
             exit;
          end if;
        end loop;
        --
        if not l_found then
           --
           --
           -- Now see if there are non automatic enrollments
           --
           if l_bckdt_pil_prev_stat_cd='STRTD' then
             l_found_non_automatics:=FALSE;
             for l_inn_cnt in 1..l_pgm_table.last loop
               if l_pgm_table(l_inn_cnt).pgm_id = l_pgm_table(l_cnt).pgm_id and
                  l_pgm_table(l_inn_cnt).enrt_mthd_cd<>'A'
               then
                  l_found_non_automatics  := TRUE;
                  exit;
               end if;
             end loop;
           end if;
           --
           if l_bckdt_pil_prev_stat_cd<>'STRTD' or
              l_found_non_automatics then
             hr_utility.set_location('Date for multi row edits = ' ||
                                      l_pgm_table(l_cnt).max_enrt_esd || '  ' || ' pgm = ' ||
                                      l_pgm_table(l_cnt).pgm_id, 333);
             ben_prtt_enrt_result_api.multi_rows_edit
              (p_person_id         => p_person_id,
               p_effective_date    => l_pgm_table(l_cnt).max_enrt_esd,
               p_business_group_id => p_business_group_id,
               p_per_in_ler_id     => p_per_in_ler_id,
               p_pgm_id            => l_pgm_table(l_cnt).pgm_id);
             --
           end if;
           l_pgm_table(l_cnt).multi_row_edit_done := TRUE;
           --
        end if;
        --
     end loop;
  end if;
  --
  -- Call multi_rows_edit, process_post_results, reinstate_bpl_per_pen
  -- Only if the enrollments are reinstated.
  --
  if nvl(l_enrt_table.LAST, 0) > 0 then
     --
     -- Call multi row edits and post results only if enrollments are
     -- created.
     --
     -- Call multi row edits just as miscellanious form calls.
     --
     hr_utility.set_location('Date for multi row edits = ' ||
                              l_max_enrt_esd , 333);
     ben_prtt_enrt_result_api.multi_rows_edit
      (p_person_id         => p_person_id,
       p_effective_date    => l_max_enrt_esd,
       p_business_group_id => p_business_group_id,
       p_per_in_ler_id     => p_per_in_ler_id,
       p_pgm_id            => null);
     --
     -- Invoke post result process once for Explicit/Automatic/ Default.
     --
     ben_proc_common_enrt_rslt.process_post_results
      (p_person_id          => p_person_id,
       p_enrt_mthd_cd       => 'E',
       p_effective_date     => l_max_enrt_esd,
       p_business_group_id  => p_business_group_id,
       p_per_in_ler_id      => p_per_in_ler_id);
     --
     ben_proc_common_enrt_rslt.process_post_results
      (p_person_id          => p_person_id,
       p_enrt_mthd_cd       => 'D',
       p_effective_date     => l_max_enrt_esd,
       p_business_group_id  => p_business_group_id,
       p_per_in_ler_id      => p_per_in_ler_id);
     --
     ben_proc_common_enrt_rslt.process_post_results
      (p_person_id          => p_person_id,
       p_enrt_mthd_cd       => 'A',
       p_effective_date     => l_max_enrt_esd,
       p_business_group_id  => p_business_group_id,
       p_per_in_ler_id      => p_per_in_ler_id);
     --
  end if;
  --
  -- Apply process post enrollments once for each program.
  --
  if nvl(l_pgm_table.LAST, 0) > 0 then
     for l_cnt in 1..l_pgm_table.LAST loop
        --
        --RCHASE - ensure automatics are handled differently than
        --         form enrollments by process_post_enrollment
        --
        -- Bug 5623259.
        --
        if l_pgm_table(l_cnt).enrt_mthd_cd = 'E' then
           l_proc_cd := 'FORMENRT';
        elsif l_pgm_table(l_cnt).enrt_mthd_cd = 'D' then
           l_proc_cd := 'DFLTENRT';
        else
           l_proc_cd := NULL;
        end if;
        ben_proc_common_enrt_rslt.process_post_enrollment
          (p_per_in_ler_id     => p_per_in_ler_id,
           p_pgm_id            => l_pgm_table(l_cnt).pgm_id,
           p_pl_id             => null,
           p_enrt_mthd_cd      => l_pgm_table(l_cnt).enrt_mthd_cd,
           p_cls_enrt_flag     => FALSE,
           --RCHASE
           p_proc_cd           => l_proc_cd,--'FORMENRT',
           p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => l_pgm_table(l_cnt).max_enrt_esd );
        --
      end loop;
  end if;
  --
  -- Apply process post enrollments once for each program.
  --
  if nvl(l_pl_table.LAST, 0) > 0 then
     for l_cnt in 1..l_pl_table.LAST loop
        --
        -- Invoke post result process
        --
        hr_utility.set_location('Date = ' || l_pl_table(l_cnt).max_enrt_esd, 333);
        hr_utility.set_location('PL = ' || l_pl_table(l_cnt).pl_id, 333);
        --RCHASE - ensure automatics are handled differently than
        --         form enrollments by process_post_enrollment
        -- Bug 5623259.
        --
        if l_pl_table(l_cnt).enrt_mthd_cd = 'E' then
           l_proc_cd := 'FORMENRT';
        elsif l_pl_table(l_cnt).enrt_mthd_cd = 'D' then
           l_proc_cd := 'DFLTENRT';
        else
           l_proc_cd := NULL;
        end if;
        ben_proc_common_enrt_rslt.process_post_enrollment
          (p_per_in_ler_id     => p_per_in_ler_id,
           p_pgm_id            => null,
           p_pl_id             => l_pl_table(l_cnt).pl_id,
           p_enrt_mthd_cd      => l_pl_table(l_cnt).enrt_mthd_cd,
           p_cls_enrt_flag     => FALSE,
           --RCHASE
           p_proc_cd           => l_proc_cd,--'FORMENRT',
           p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => l_pl_table(l_cnt).max_enrt_esd );
        --
      end loop;
  end if;
  --
  if nvl(l_enrt_table.LAST, 0) > 0 then
     --
     -- Reinstate the ledgers if any created.
     --
     reinstate_bpl_per_pen(
         p_person_id              => p_person_id
         ,p_business_group_id      => p_business_group_id
         ,p_effective_date         => p_effective_date
         ,p_per_in_ler_id          => p_per_in_ler_id
         ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
         );
     --
     for l_cnt in 1..l_enrt_table.LAST loop
       --
       -- Reinstate the enrollment beneficiary rows.
       --
       hr_utility.set_location('Enrt Date = ' ||
                                l_enrt_table(l_cnt).effective_start_date, 333);
  hr_utility.set_location('Reinstate the enrollment beneficiary rows',12);
       reinstate_pbn_per_pen(
         p_person_id                => p_person_id
         ,p_bckdt_prtt_enrt_rslt_id
                                    => l_enrt_table(l_cnt).bckdt_prtt_enrt_rslt_id
         ,p_prtt_enrt_rslt_id       => l_enrt_table(l_cnt).prtt_enrt_rslt_id
         ,p_rslt_object_version_number => l_enrt_table(l_cnt).pen_ovn_number
         ,p_business_group_id        => p_business_group_id
         ,p_per_in_ler_id            => p_per_in_ler_id
         ,p_effective_date           => nvl(l_enrt_table(l_cnt).effective_start_date,
                                            g_sys_date)
         ,p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id
         );
       --
      --Bug 3709516 to reinstate participant PCP
        reinstate_ppr_per_pen(
           p_person_id                => p_person_id
          ,p_bckdt_prtt_enrt_rslt_id => l_enrt_table(l_cnt).bckdt_prtt_enrt_rslt_id
          ,p_prtt_enrt_rslt_id       => l_enrt_table(l_cnt).prtt_enrt_rslt_id
          ,p_business_group_id       => p_business_group_id
          ,p_elig_cvrd_dpnt_id       => NULL
          ,p_effective_date          => nvl(l_enrt_table(l_cnt).effective_start_date,
                                                   nvl(g_sys_date, p_effective_date) ) -- bug 5344392
          ,p_bckdt_elig_cvrd_dpnt_id => NULL
          );
       -- Reinstate the covered dependents.
       --
       reinstate_dpnts_per_pen(
               p_person_id                 => p_person_id
               ,p_bckdt_prtt_enrt_rslt_id  => l_enrt_table(l_cnt).bckdt_prtt_enrt_rslt_id
               ,p_prtt_enrt_rslt_id        => l_enrt_table(l_cnt).prtt_enrt_rslt_id
               ,p_pen_ovn_number           => l_enrt_table(l_cnt).pen_ovn_number
               ,p_old_pl_id                => l_enrt_table(l_cnt).old_pl_id
               ,p_new_pl_id                => l_enrt_table(l_cnt).new_pl_id
               ,p_old_oipl_id              => l_enrt_table(l_cnt).old_oipl_id
               ,p_new_oipl_id              => l_enrt_table(l_cnt).new_oipl_id
               ,p_old_pl_typ_id            => l_enrt_table(l_cnt).old_pl_typ_id
               ,p_new_pl_typ_id            => l_enrt_table(l_cnt).new_pl_typ_id
               ,p_pgm_id                   => l_enrt_table(l_cnt).pgm_id
               ,p_ler_id                   => l_enrt_table(l_cnt).ler_id
               ,p_elig_per_elctbl_chc_id   => l_enrt_table(l_cnt).elig_per_elctbl_chc_id
               ,p_business_group_id        => p_business_group_id
               -- # 2508745
               ,p_effective_date           => nvl(l_enrt_table(l_cnt).effective_start_date,
                                                    p_effective_date)
               ,p_per_in_ler_id            => p_per_in_ler_id
               ,p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id
               ,p_dpnt_cvg_strt_dt_cd      => l_enrt_table(l_cnt).dpnt_cvg_strt_dt_cd
               ,p_dpnt_cvg_strt_dt_rl      => l_enrt_table(l_cnt).dpnt_cvg_strt_dt_rl
               ,p_enrt_cvg_strt_dt         => null -- 9999 this should be fetched from base table
               );
        --
        -- Reinstate the enrollment certifications.
        --
        reinstate_pcs_per_pen(
               p_person_id                 => p_person_id
               ,p_bckdt_prtt_enrt_rslt_id  => l_enrt_table(l_cnt).bckdt_prtt_enrt_rslt_id
               ,p_prtt_enrt_rslt_id        => l_enrt_table(l_cnt).prtt_enrt_rslt_id
               ,p_rslt_object_version_number => l_enrt_table(l_cnt).pen_ovn_number -- prtt_enrt_rslt_id
               ,p_business_group_id        => p_business_group_id
               ,p_prtt_enrt_actn_id        => null
               ,p_effective_date           => l_enrt_table(l_cnt).effective_start_date
               ,p_bckdt_prtt_enrt_actn_id  => null
               -- CFW
               ,p_per_in_ler_id            => p_per_in_ler_id
               ,p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id
               );
       --
       -- Reinstate the action items.
       --
       reinstate_pea_per_pen(
                 p_person_id                => p_person_id
                ,p_bckdt_prtt_enrt_rslt_id  => l_enrt_table(l_cnt).bckdt_prtt_enrt_rslt_id
                ,p_prtt_enrt_rslt_id        => l_enrt_table(l_cnt).prtt_enrt_rslt_id -- pen_ovn_number
                ,p_rslt_object_version_number => l_enrt_table(l_cnt).pen_ovn_number -- prtt_enrt_rslt_id
                ,p_business_group_id        => p_business_group_id
                ,p_per_in_ler_id            => p_per_in_ler_id
                ,p_effective_date           => l_enrt_table(l_cnt).effective_start_date
                ,p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id
                );
     end loop;
  end if;
  --
  -- If any of the backed out enrt rslts were overriden, then update the new
  -- rslts with the overriden data.
  --
  if nvl(l_enrt_table.last, 0) > 0 then
    --
    for i in 1..l_enrt_table.last loop
      --
      if l_enrt_table(i).bckdt_enrt_ovridn_flag = 'Y' then
        --
        hr_utility.set_location('Restoring the overriden result: ' ||
                                l_enrt_table(i).bckdt_prtt_enrt_rslt_id, 72);
        --
        -- Get the latest object version number as the post enrollment process
        -- may have updated the new enrt result.
        --
        open c_ovn(l_enrt_table(i).prtt_enrt_rslt_id);
        fetch c_ovn into l_ovn;
        close c_ovn;
        --
        ben_prtt_enrt_result_api.update_prtt_enrt_result
          (p_prtt_enrt_rslt_id      => l_enrt_table(i).prtt_enrt_rslt_id
          ,p_effective_start_date   => l_esd_out
          ,p_effective_end_date     => l_eed_out
          ,p_enrt_cvg_strt_dt       => l_enrt_table(i).bckdt_enrt_cvg_strt_dt
          ,p_enrt_cvg_thru_dt       => l_enrt_table(i).bckdt_enrt_cvg_thru_dt
          ,p_enrt_ovridn_flag       => 'Y'
          ,p_object_version_number  => l_ovn
          ,p_effective_date         => l_enrt_table(i).g_sys_date
          ,p_datetrack_mode         => hr_api.g_correction
          ,p_multi_row_validate     => FALSE);
        --
      end if;
      --
      -- Check if any of the rates have been overriden and update the new
      -- rates with the overriden values.
      -- Bug 2677804 changed the cursor
      -- We need to see the overriden thru date also.
      for l_rt_rec in c_ovridn_rt(l_enrt_table(i).bckdt_prtt_enrt_rslt_id
                                 ,l_enrt_table(i).prtt_enrt_rslt_id )
      loop
        --
        hr_utility.set_location('Updating new prv: ' || l_rt_rec.new_prv_id ||
                                ' with overriden prv_id: ' ||
                                l_rt_rec.prtt_rt_val_id, 72);
        --
        ben_prtt_rt_val_api.update_prtt_rt_val
          (p_prtt_rt_val_id        => l_rt_rec.new_prv_id
          ,p_person_id             => p_person_id
          ,p_rt_strt_dt            => l_rt_rec.rt_strt_dt
          ,p_rt_val                => l_rt_rec.rt_val
          ,p_acty_ref_perd_cd      => l_rt_rec.acty_ref_perd_cd
          ,p_cmcd_rt_val           => l_rt_rec.cmcd_rt_val
          ,p_cmcd_ref_perd_cd      => l_rt_rec.cmcd_ref_perd_cd
          ,p_ann_rt_val            => l_rt_rec.ann_rt_val
          ,p_rt_ovridn_flag        => l_rt_rec.rt_ovridn_flag
          ,p_rt_ovridn_thru_dt     => l_rt_rec.rt_ovridn_thru_dt
          ,p_business_group_id     => p_business_group_id
          ,p_object_version_number => l_rt_rec.new_prv_ovn
          ,p_effective_date        => l_enrt_table(i).g_sys_date);
        --
      end loop;
      --
      -- Check if there are any dependents that are overriden and update the new
      -- elig_cvrd_dpnt records with the overriden values.
      --
      for l_dpnt_rec in c_ovridn_dpnt(l_enrt_table(i).bckdt_prtt_enrt_rslt_id
                                     ,l_enrt_table(i).prtt_enrt_rslt_id
                                     ,l_enrt_table(i).g_sys_date)
      loop
        --
        hr_utility.set_location('Updating new ecd with overriden ecd_id: ' ||
                                l_dpnt_rec.elig_cvrd_dpnt_id, 72);
        --
        ben_elig_cvrd_dpnt_api.update_elig_cvrd_dpnt
          (p_elig_cvrd_dpnt_id     => l_dpnt_rec.new_pdp_id
          ,p_effective_start_date  => l_esd_out
          ,p_effective_end_date    => l_eed_out
          ,p_cvg_strt_dt           => l_dpnt_rec.cvg_strt_dt
          ,p_cvg_thru_dt           => l_dpnt_rec.cvg_thru_dt
          ,p_ovrdn_flag            => l_dpnt_rec.ovrdn_flag
          ,p_ovrdn_thru_dt         => l_dpnt_rec.ovrdn_thru_dt
          ,p_object_version_number => l_dpnt_rec.new_pdp_ovn
          ,p_datetrack_mode        => hr_api.g_correction
          ,p_effective_date        => l_enrt_table(i).g_sys_date);
        --
      end loop;
      --
    end loop;
    --
  end if;
  --
  -- Call the Close enrollement process if the
  -- backed out pil's status is PROCD.
  --
  if l_cls_enrt_flag then
     --
        ben_close_enrollment.close_single_enrollment
                      (p_per_in_ler_id      => p_per_in_ler_id
                      ,p_effective_date     => nvl(l_max_enrt_esd,p_effective_date)
                      ,p_business_group_id  => p_business_group_id
                      ,p_close_cd           => 'FORCE'
                      ,p_validate           => FALSE
                      ,p_close_uneai_flag     => NULL
                      ,p_uneai_effective_date => NULL);
     --
  end if;
  --
  -- VOIDD the backed out per in ler.
  --
  ben_Person_Life_Event_api.update_person_life_event
             (p_per_in_ler_id         => p_bckdt_per_in_ler_id
             ,p_per_in_ler_stat_cd    => 'VOIDD'
             ,p_object_version_number => l_bckdt_pil_ovn
             ,p_effective_date        => nvl(l_max_enrt_esd,p_effective_date)
             ,P_PROCD_DT              => l_procd_dt  -- outputs
             ,P_STRTD_DT              => l_strtd_dt
             ,P_VOIDD_DT              => l_voidd_dt  );
  --
  g_bckdt_pil_restored_flag := 'Y';
  --
  -- Void the communications created to new per_in ler.
  --
  void_literature(p_person_id           => p_person_id
                 ,p_business_group_id   => p_business_group_id
                 ,p_effective_date      => nvl(l_max_enrt_esd,p_effective_date)
                 ,p_ler_id              => null
                 ,p_per_in_ler_id       => p_per_in_ler_id
                 );
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
end reinstate_the_prev_enrt;
--
-- ----------------------------------------------------------------------------
-- |------------------------< comp_rslts_n_process >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure comp_rslts_n_process (
         p_bckdt_per_in_ler_id      in number,
         p_per_in_ler_id            in number,
         p_person_id                in number,
         p_business_group_id        in number,
         p_effective_date           in date) is
  --
  l_proc                     varchar2(72) := g_package||'.comp_rslts_n_process';
  --
  l_inter_pil_ovn            number;
  l_inter_pil_cnt            number;
  l_inter_per_in_ler_id      number;
  l_inter_pil_le_dt          date;
  l_resnd_cmnt_txt           fnd_new_messages.message_text%type;
  l_bckt_csd_lf_evt_ocrd_dt  date;
  l_bckt_csd_per_in_ler_id   number;

  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  get_inter_pil_cnt (
                        p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id,
                        p_per_in_ler_id            => p_per_in_ler_id,
                        p_person_id                => p_person_id,
                        p_business_group_id        => p_business_group_id,
                        p_bckt_csd_lf_evt_ocrd_dt  => l_bckt_csd_lf_evt_ocrd_dt,
                        p_bckt_csd_per_in_ler_id   => l_bckt_csd_per_in_ler_id,
                        p_inter_per_in_ler_id      => l_inter_per_in_ler_id,
                        p_inter_pil_ovn            => l_inter_pil_ovn,
                        p_inter_pil_cnt            => l_inter_pil_cnt,
                        p_inter_pil_le_dt          => l_inter_pil_le_dt,
                        p_effective_date           => p_effective_date);
  --
  hr_utility.set_location ('Entering Inter pil ='|| l_inter_pil_cnt , 4987);
  if  l_inter_pil_cnt = 0
  then
      --
      -- No intervening pil's so need to check the backed out
      -- enrollment results and current results.
      -- If the results are same and check bckdt have more enrt rows then
      -- restore the backdt rows and make the current pil voidd.
      -- Decision DW, PB : Restore the old backed out pil if the
      -- automatic enrollments are same.
      --
      -- Bug 5108 : JB/DW : Decision is no need to compare the
      -- enrollment results. These are automatics.
      -- Just go and reinstate the enrollment results.
      --
      /* if comp_ori_new_pen(p_person_id           => p_person_id
                         ,p_business_group_id   => p_business_group_id
                         ,p_ler_id              => null
                         ,p_effective_date      => p_effective_date
                         ,p_per_in_ler_id       => p_per_in_ler_id
                         ,p_bckdt_per_in_ler_id => p_bckdt_per_in_ler_id
                         ,p_dont_check_cnt_flag => 'Y'
        ) = 'N' then
      */
        --
        -- Now restore the original pil i.e., backed out pil.
        --
        -- Mark the per-in-ler as voidd
        -- 9999 do I need to void any other data, status etc.,
        --
        -- Now restore the backed out pil to Started status.
        -- It should be restored to the prev status 99999 once the column is
        -- added to the ben_per_in_ler.
        --
        reinstate_the_prev_enrt(
                            p_person_id            => p_person_id
                            ,p_business_group_id   => p_business_group_id
                            ,p_ler_id              => null
                            ,p_effective_date      => p_effective_date
                            ,p_per_in_ler_id       => p_per_in_ler_id
                            ,p_bckdt_per_in_ler_id => p_bckdt_per_in_ler_id
                            ,p_bckdt_pil_prev_stat_cd => null
                           );
        --
      /* Bug 5108 : This else part never gets executed
         as enrollment results are not compared.
         --
      else
        --
        -- Literature needs to be added with comment text.
        --
        -- Add comments to new literature sent out
        -- Comment Ex: Because you have experienced another enrollment, your
        -- originlal elections have been voided. You must call benefits centre
        -- to re-elect.
        --
        fnd_message.set_name('BEN','BEN_91283_ORI_ELE_VOID_CMNT');
        fnd_message.set_token('LER_NAME',
                  ben_lf_evt_clps_restore.g_ler_name_cs_bckdt);
        l_resnd_cmnt_txt :=  fnd_message.get;
        --
        pad_cmnt_to_rsnd_lit(
                          p_person_id            => p_person_id
                          ,p_business_group_id   => p_business_group_id
                          ,p_effective_date      => p_effective_date
                          ,p_ler_id              => null
                          ,p_per_in_ler_id       => p_per_in_ler_id
                          ,p_cmnt_txt            => l_resnd_cmnt_txt
                         );
        --
      end if;
      */
      --
   elsif l_inter_pil_cnt = 1 then
      --
      -- Exactly one inrevening pil just needs to compare the intervening pil
      -- and current pil, if differ do nothing, else compare inter pil and
      -- backdt pil. if they are same then see the count differ. if count
      -- differ then restore the bckdt pil, else void the bckdt pil and keep the
      -- inter pil results, void the current pil as well.
      --
      -- Decision PB, DW: First compare the intervening pil results and
      -- backed out results, if they are same then compare results of
      -- current pil and intervening pil. If they are same then restore
      -- the enrollment results of backed out pil.
      -- Bug 1266433 : When intervening ler results and backed out ler results
      -- are compared consider the number of enrollments for finding diffrences.
      --
      if comp_ori_new_pen(p_person_id           => p_person_id
                         ,p_business_group_id   => p_business_group_id
                         ,p_ler_id              => null
                         ,p_effective_date      => p_effective_date
                         ,p_per_in_ler_id       => l_inter_per_in_ler_id
                         ,p_bckdt_per_in_ler_id => p_bckdt_per_in_ler_id
                         ,p_dont_check_cnt_flag => 'N'
         ) = 'N' and
         comp_ori_new_pen(p_person_id           => p_person_id
                         ,p_business_group_id   => p_business_group_id
                         ,p_ler_id              => null
                         ,p_effective_date      => p_effective_date
                         ,p_per_in_ler_id       => p_per_in_ler_id
                         ,p_bckdt_per_in_ler_id => p_bckdt_per_in_ler_id
                         ,p_dont_check_cnt_flag => 'Y'
         ) = 'N'
      then
        --
        reinstate_the_prev_enrt(
                            p_person_id            => p_person_id
                            ,p_business_group_id   => p_business_group_id
                            ,p_ler_id              => null
                            ,p_effective_date      => p_effective_date
                            ,p_per_in_ler_id       => p_per_in_ler_id
                            ,p_bckdt_per_in_ler_id => p_bckdt_per_in_ler_id
                            ,p_bckdt_pil_prev_stat_cd => null
                           );
        --
      else
         --
         -- Add comments to literature. and continue with the current pil.
         --
         null;
        --
        -- Add comments to new literature sent out
        -- Comment Ex: Because you have experienced another enrollment, your
        -- originlal elections have been voided. You must call benefits centre
        -- to re-elect.
        --
        fnd_message.set_name('BEN','BEN_91283_ORI_ELE_VOID_CMNT');
        fnd_message.set_token('LER_NAME',
                  ben_lf_evt_clps_restore.g_ler_name_cs_bckdt);
        l_resnd_cmnt_txt :=  fnd_message.get;
        --
        pad_cmnt_to_rsnd_lit(
                          p_person_id            => p_person_id
                          ,p_business_group_id   => p_business_group_id
                          ,p_effective_date      => p_effective_date
                          ,p_ler_id              => null
                          ,p_per_in_ler_id       => p_per_in_ler_id
                          ,p_cmnt_txt            => l_resnd_cmnt_txt
                         );
         --
      end if;
      --
   else
      --
      -- More than one intervening PIL's so do nothing.
      -- VOID the new pil literature.
      --
      void_literature(p_person_id                 => p_person_id
                          ,p_business_group_id   => p_business_group_id
                          ,p_effective_date      => p_effective_date
                          ,p_ler_id              => null
                          ,p_per_in_ler_id       => p_per_in_ler_id
                         );
     --
   end if;
   --
end comp_rslts_n_process;
--
-- ----------------------------------------------------------------------------
-- |------------------------< comp_ori_new_epe >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure compares the original and new electability
-- data associated with the same ler and returns Y if changes
-- exists else returns N.
--
function comp_ori_new_epe(p_bckdt_epe_row        ben_reinstate_epe_cache.g_pilepe_inst_row,
                          p_current_epe_row      ben_reinstate_epe_cache.g_pilepe_inst_row,
                          p_per_in_ler_id        number,
                          p_bckdt_per_in_ler_id  number,
                          p_person_id            number,
                          p_business_group_id    number,
                          p_effective_date       date
                           ) return varchar2 is
  --
  l_proc                   varchar2(72) := g_package||'.comp_ori_new_epe';
  --
  --
  l_bckdt_epe_cnt           number  := 0;
  l_curr_epe_cnt            number  := 0;
  l_differ                  varchar2(1) := 'N';
  l_egd_differ              varchar2(1) := 'N';
  l_ecd_differ              varchar2(1) := 'N';
  l_enb_differ              varchar2(1) := 'N';
  l_epe_ecr_differ          varchar2(1) := 'N';
  --
  l_next_row        binary_integer;
  l_found           boolean;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  l_found  := FALSE;
  --
  if  nvl(p_bckdt_epe_row.pl_id, -1)                = nvl(p_current_epe_row.pl_id, -1) and
      nvl(p_bckdt_epe_row.oipl_id, -1)              = nvl(p_current_epe_row.oipl_id, -1) and
      nvl(p_bckdt_epe_row.PGM_ID, -1)               = nvl(p_current_epe_row.PGM_ID, -1) and
      nvl(p_bckdt_epe_row.PLIP_ID, -1)              = nvl(p_current_epe_row.PLIP_ID, -1) and
      nvl(p_bckdt_epe_row.PTIP_ID, -1)              = nvl(p_current_epe_row.PTIP_ID, -1) and
      nvl(p_bckdt_epe_row.PL_TYP_ID, -1)            = nvl(p_current_epe_row.PL_TYP_ID, -1) and
      nvl(p_bckdt_epe_row.CMBN_PTIP_ID, -1)         = nvl(p_current_epe_row.CMBN_PTIP_ID, -1) and
      nvl(p_bckdt_epe_row.CMBN_PTIP_OPT_ID, -1)     = nvl(p_current_epe_row.CMBN_PTIP_OPT_ID, -1) and
      nvl(p_bckdt_epe_row.CMBN_PLIP_ID, -1)         = nvl(p_current_epe_row.CMBN_PLIP_ID, -1) and
      nvl(p_bckdt_epe_row.SPCL_RT_PL_ID, -1)        = nvl(p_current_epe_row.SPCL_RT_PL_ID, -1) and
      nvl(p_bckdt_epe_row.SPCL_RT_OIPL_ID, -1)      = nvl(p_current_epe_row.SPCL_RT_OIPL_ID, -1) and
      nvl(p_bckdt_epe_row.MUST_ENRL_ANTHR_PL_ID, -1)= nvl(p_current_epe_row.MUST_ENRL_ANTHR_PL_ID, -1) and
      p_bckdt_epe_row.DFLT_FLAG                     = p_current_epe_row.DFLT_FLAG and
      p_bckdt_epe_row.ELCTBL_FLAG                   = p_current_epe_row.ELCTBL_FLAG and
      p_bckdt_epe_row.MNDTRY_FLAG                   = p_current_epe_row.MNDTRY_FLAG and
      p_bckdt_epe_row.ALWS_DPNT_DSGN_FLAG           = p_current_epe_row.ALWS_DPNT_DSGN_FLAG and
      p_bckdt_epe_row.AUTO_ENRT_FLAG                = p_current_epe_row.AUTO_ENRT_FLAG and
      p_bckdt_epe_row.CTFN_RQD_FLAG                 = p_current_epe_row.CTFN_RQD_FLAG and
      nvl(p_bckdt_epe_row.BNFT_PRVDR_POOL_ID, -1)   = nvl(p_current_epe_row.BNFT_PRVDR_POOL_ID, -1) and
      nvl(p_bckdt_epe_row.YR_PERD_ID, -1)           = nvl(p_current_epe_row.YR_PERD_ID, -1) and
      nvl(p_bckdt_epe_row.ENRT_CVG_STRT_DT_CD, '$') = nvl(p_current_epe_row.ENRT_CVG_STRT_DT_CD,  '$') and
      nvl(p_bckdt_epe_row.ENRT_CVG_STRT_DT_RL, -1)  = nvl(p_current_epe_row.ENRT_CVG_STRT_DT_RL, -1) and
      nvl(p_bckdt_epe_row.DPNT_CVG_STRT_DT_CD, '$') = nvl(p_current_epe_row.DPNT_CVG_STRT_DT_CD,  '$') and
      nvl(p_bckdt_epe_row.LER_CHG_DPNT_CVG_CD, '$') = nvl(p_current_epe_row.LER_CHG_DPNT_CVG_CD,  '$') and
      nvl(p_bckdt_epe_row.DPNT_CVG_STRT_DT_RL, -1)  = nvl(p_current_epe_row.DPNT_CVG_STRT_DT_RL, -1) and
      nvl(p_bckdt_epe_row.ENRT_CVG_STRT_DT, hr_api.g_eot) = nvl(p_current_epe_row.ENRT_CVG_STRT_DT, hr_api.g_eot) and
      nvl(p_bckdt_epe_row.ERLST_DEENRT_DT, hr_api.g_eot) = nvl(p_current_epe_row.ERLST_DEENRT_DT, hr_api.g_eot)
  then
    --
    -- Now check elig_dpnt rows for any differences.
    --
    l_egd_differ := comp_ori_new_egd(
                           p_person_id              => p_person_id
                          ,p_business_group_id      => p_business_group_id
                          ,p_effective_date         => p_effective_date
                          ,p_per_in_ler_id          => p_per_in_ler_id
                          ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
                          ,p_curr_epe_id            => p_current_epe_row.ELIG_PER_ELCTBL_CHC_ID
                          ,p_bckdt_epe_id           => p_bckdt_epe_row.ELIG_PER_ELCTBL_CHC_ID
                          );
    --
    if l_egd_differ = 'Y' then
      --
      l_found   := FALSE;
      --
    else
      --
      l_ecd_differ := comp_ori_new_ecd(
                           p_person_id              => p_person_id
                          ,p_business_group_id      => p_business_group_id
                          ,p_effective_date         => p_effective_date
                          ,p_per_in_ler_id          => p_per_in_ler_id
                          ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
                          ,p_curr_epe_id            => p_current_epe_row.ELIG_PER_ELCTBL_CHC_ID
                          ,p_bckdt_epe_id           => p_bckdt_epe_row.ELIG_PER_ELCTBL_CHC_ID
                          );
      --
      if l_ecd_differ = 'Y' then
        --
        -- even though epe is same ecd differ logically we need to exit.
        --
        l_found   := FALSE;
      else
        --
        l_enb_differ := comp_ori_new_enb(
                           p_person_id              => p_person_id
                          ,p_business_group_id      => p_business_group_id
                          ,p_effective_date         => p_effective_date
                          ,p_per_in_ler_id          => p_per_in_ler_id
                          ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
                          ,p_curr_epe_id            => p_current_epe_row.ELIG_PER_ELCTBL_CHC_ID
                          ,p_bckdt_epe_id           => p_bckdt_epe_row.ELIG_PER_ELCTBL_CHC_ID
                          );
        --
        if l_enb_differ = 'Y' then
          --
          -- even though epe, ecd are same there may be differences in
          -- enrt_bnft
          --
          l_found   := FALSE;
        else
          --
          l_epe_ecr_differ := comp_ori_new_epe_ecr(
                           p_person_id              => p_person_id
                          ,p_business_group_id      => p_business_group_id
                          ,p_effective_date         => p_effective_date
                          ,p_per_in_ler_id          => p_per_in_ler_id
                          ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
                          ,p_curr_epe_id            => p_current_epe_row.ELIG_PER_ELCTBL_CHC_ID
                          ,p_bckdt_epe_id           => p_bckdt_epe_row.ELIG_PER_ELCTBL_CHC_ID
                          );
          --
          if l_epe_ecr_differ = 'Y' then
            --
            -- even though epe, ecd, enb are same there may be
            -- differences in enrt_rt
            --
            l_found   := FALSE;
            --
          else
            --
            l_found   := TRUE;
            --
          end if;
        end if;
        --
      end if;
      --
    end if; -- Diff in egd
  end if;
  --
  if l_found   = FALSE then
    --
    -- Current epe for a given backed out epe is not found
    --
    l_differ := 'Y';
    --
  end if; -- epe ckecks if statement
  --
  hr_utility.set_location('Leaving:' || l_differ || l_proc, 10);
  --
  return l_differ;
  --
end comp_ori_new_epe;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_backedout_results >-------------------------
-- ----------------------------------------------------------------------------
procedure get_backedout_results(
                             p_person_id              in number
                            ,p_pgm_id                 in number
                            ,p_pl_id                  in number
                            ,p_effective_date         in date
                            ,p_bckdt_per_in_ler_id    in number
                            ,p_pilepe_inst_table     out nocopy ben_reinstate_epe_cache.g_pilepe_inst_tbl
                            ,p_bckdt_pen_table       out nocopy g_bckdt_pen_tbl
                           ) is
  --
  l_proc                    varchar2(72) := g_package||'.get_backedout_results';
  --
  -- Get the electable choice data.
  --
  l_bkd_pilepe_inst_row     ben_reinstate_epe_cache.g_pilepe_inst_row;
  l_bkd_pilepe_inst_table     ben_reinstate_epe_cache.g_pilepe_inst_tbl;
  l_bkd_penepe_counter      binary_integer  ;
  l_hv                      pls_integer;
  --
  l_dummy_number        number;
  --Table for backed out Enrollment results
  --Table for EPE records associated with backed out enrollment results
  --
  --
  --Table for valid enrollment results and associated EPE data for reinstante
  l_bckdt_pen_table         g_bckdt_pen_tbl ;
  l_bckdt_pen_rec           g_bckdt_pen%rowtype ;
  --
  --
begin
  --
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  l_bkd_penepe_counter := 0 ;
  l_bkd_pilepe_inst_table.delete ;
  l_bckdt_pen_table.delete ;
  --
  FOR l_bckdt_pen_rec in g_bckdt_pen(
           c_bckdt_per_in_ler_id => p_bckdt_per_in_ler_id ,
           c_person_id           => p_person_id,
           c_effective_date      => p_effective_date,
           c_pgm_id              => p_pgm_id,
           c_pl_id               => p_pl_id ) loop
    --
    --
    hr_utility.set_location('Inside BCKDT pen loop ' || l_proc,20);
    --
    ben_reinstate_epe_cache.get_pilcobjepe_dets(
      p_per_in_ler_id => p_bckdt_per_in_ler_id
     ,p_pgm_id        => l_bckdt_pen_rec.pgm_id
     ,p_pl_id         => l_bckdt_pen_rec.pl_id
     ,p_oipl_id       => l_bckdt_pen_rec.oipl_id
     ,p_inst_row      => l_bkd_pilepe_inst_row
      );
    --
    --
    if l_bkd_pilepe_inst_row.elig_per_elctbl_chc_id is not null then
      --
      --Write EPE records to a table
      --
      l_bkd_penepe_counter := l_bkd_penepe_counter + 1;
      l_bkd_pilepe_inst_table(l_bkd_penepe_counter) := l_bkd_pilepe_inst_row;
      --
      --Also write the backedout results to another table
      --
      l_bckdt_pen_table(l_bkd_penepe_counter) := l_bckdt_pen_rec ;
      --
    else
      -- write into a exception table for further notification that all the results are not
      -- reinstated due to getting the electable choice data in the backed out per in ler
      -- this is uncommon.
      null;
      --
    end if;
    --
  end loop;
  p_pilepe_inst_table := l_bkd_pilepe_inst_table ;
  p_bckdt_pen_table := l_bckdt_pen_table ;
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
end get_backedout_results;
--
/**** NO LONGER USED.... NEEDS TO BE DELETED COMPLETD
-- ----------------------------------------------------------------------------
-- |------------------------< p_lf_evt_clps_restore >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure p_lf_evt_clps_restore_old(p_person_id               in number
                          ,p_business_group_id      in number
                          ,p_effective_date         in date
                          ,p_per_in_ler_id          in number
                          ,p_bckdt_per_in_ler_id    in number
                          ) is
  --
  cursor c_pil(p_per_in_ler_id in number) is
    select pil.object_version_number
    from   ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id;
  --
  cursor c_multiple_rate is
    select null
    from   ben_le_clsn_n_rstr
    where  BKUP_TBL_TYP_CD = 'MULTIPLE_RATE'
    and    per_in_ler_id  = p_bckdt_per_in_ler_id;
   --
  l_dummy     varchar2(1);

  l_pil                     c_pil%rowtype;
  --
  l_proc                    varchar2(72) := g_package||'.p_lf_evt_clps_restore';
  l_chages_ocrd_flag        varchar2(1);
  l_rslt_exist_flag         varchar2(1);
  l_date                    date;
  l_resnd_cmnt_txt          fnd_new_messages.message_text%type;
  l_dummy1 VARCHAR2(4000);
  l_dummy2 VARCHAR2(4000);
  l_schema VARCHAR2(10);
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- 9999 Remove it after complete test.
  -- bug 4615207 : added GHR product installation chk -Multiple Rate chk to be performed only for GHR
  IF (fnd_installation.get_app_info('GHR',l_dummy1, l_dummy2, l_schema)) THEN
  open c_multiple_rate;
  fetch c_multiple_rate into l_dummy;
  if c_multiple_rate%found then
  close c_multiple_rate;
    -- Multiple rate is found and no reinstate
    hr_utility.set_location ('Multiple rate found and no reinstate done',11);
    return;
  end if;
  close c_multiple_rate;

  end if;
  --
  l_chages_ocrd_flag := comp_ori_new_pil_outcome(
                           p_person_id            => p_person_id
                           ,p_business_group_id   => p_business_group_id
                           ,p_ler_id              => null
                           ,p_effective_date      => p_effective_date
                           ,p_per_in_ler_id       => p_per_in_ler_id
                           ,p_bckdt_per_in_ler_id => p_bckdt_per_in_ler_id
                          );
  --
  l_rslt_exist_flag  := ele_made_for_bckdt_pil (
                           p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id
                           ,p_person_id               => p_person_id
                           ,p_business_group_id       => p_business_group_id
                           ,p_effective_date          => p_effective_date
                          );
  --
  if l_chages_ocrd_flag = 'Y' then
     --
     -- Changes in electable choices or rates or costs occure.
     --
     if l_rslt_exist_flag = 'Y' then
        --
        -- Add comments to new literature sent out
        -- Comment Ex: Because you have experienced another enrollment, your
        -- originlal elections have been voided. You must call benefits centre
        -- to re-elect.
        --
        fnd_message.set_name('BEN','BEN_91283_ORI_ELE_VOID_CMNT');
        fnd_message.set_token('LER_NAME',
                  ben_lf_evt_clps_restore.g_ler_name_cs_bckdt);
        l_resnd_cmnt_txt :=  fnd_message.get;
        --
        pad_cmnt_to_rsnd_lit(
                          p_person_id            => p_person_id
                          ,p_business_group_id   => p_business_group_id
                          ,p_effective_date      => p_effective_date
                          ,p_ler_id              => null
                          ,p_per_in_ler_id       => p_per_in_ler_id
                          ,p_cmnt_txt            => l_resnd_cmnt_txt
                         );
     else
        --
        -- Add comments to new literature sent out
        -- Comment Ex: This is a replacement PFS generated as a result of the
        --    { name of the new event }
        --
        fnd_message.set_name('BEN','BEN_92284_RESND_LIT_CMNT');
        fnd_message.set_token('LER_NAME',
                  ben_lf_evt_clps_restore.g_ler_name_cs_bckdt);
        l_resnd_cmnt_txt :=  fnd_message.get;
        --
        pad_cmnt_to_rsnd_lit(
                          p_person_id            => p_person_id
                          ,p_business_group_id   => p_business_group_id
                          ,p_effective_date      => p_effective_date
                          ,p_ler_id              => null
                          ,p_per_in_ler_id       => p_per_in_ler_id
                          ,p_cmnt_txt            => l_resnd_cmnt_txt
                         );
        --
     end if;
     --
  else
     --
     -- Now compare the enrollment results and decide whether to restore or
     -- not.
     comp_rslts_n_process (
         p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id,
         p_per_in_ler_id            => p_per_in_ler_id,
         p_person_id                => p_person_id,
         p_business_group_id        => p_business_group_id,
         p_effective_date           => p_effective_date);
     --
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end p_lf_evt_clps_restore_old;
-- New reinstate Enrollment routine
*/
--
procedure reinstate_prev_enrt_for_popl(
                             p_bckdt_pen_table     in g_bckdt_pen_tbl
                            ,p_epe_table           in ben_reinstate_epe_cache.g_pilepe_inst_tbl
                            ,p_pgm_table       in out nocopy g_pgm_table
                            ,p_pl_table        in out nocopy g_pl_table
                            ,p_enrt_table      in out nocopy g_enrt_table
                            ,p_person_id           in number
                            ,p_pgm_id              in number
                            ,p_pl_id               in number
                            ,p_business_group_id   in number
                            ,p_effective_date      in date
                            ,p_per_in_ler_id       in number
                            ,p_bckdt_per_in_ler_id in number
                            ,p_enrt_perd_strt_dt   in date
                            ,p_max_enrt_esd        out nocopy date
                           ) is
  --
  l_proc                    varchar2(72) := g_package||'.reinstate_prev_enrt_for_popl';
  --
  cursor c_bckdt_pil is
    select pil.PRVS_STAT_CD, pil.object_version_number, pil.BCKT_PER_IN_LER_ID
    from ben_per_in_ler pil
    where pil.per_in_ler_id = p_bckdt_per_in_ler_id
      and pil.business_group_id = p_business_group_id;
  --
  l_bckt_csd_per_in_ler_id  number;
  l_bckdt_pil_prev_stat_cd  varchar2(80);
  l_bckdt_pil_ovn           number;
  l_date                    date;
  l_procd_dt                date;
  l_strtd_dt                date;
  l_voidd_dt                date;
  --
  l_bckdt_pen_count         number := 0 ;
  l_bckdt_pen_rec           g_bckdt_pen%rowtype;
  --
  -- Get the enrollment results from the backup table for backed out pil.
  --
  l_epe_pen_rec ben_reinstate_epe_cache.g_pilepe_inst_row;
  --
  cursor c_bnft(cp_elig_per_elctbl_chc_id in number,cp_ordr_num number ) is
     select enb.enrt_bnft_id,
            enb.entr_val_at_enrt_flag,
            enb.dflt_val,
            enb.val,
            enb.dflt_flag,
            enb.cvg_mlt_cd   --Bug 3315323
      from  ben_enrt_bnft enb
      where enb.elig_per_elctbl_chc_id = cp_elig_per_elctbl_chc_id
  -- Bug  2526994 we need take the right one
  --    and   nvl(enb.mx_wo_ctfn_flag,'N') = 'N' ;
        and enb.ordr_num = cp_ordr_num ; --This is more accurate
  --
  l_bnft_rec            c_bnft%rowtype;
  l_bnft_rec_reset      c_bnft%rowtype;
  l_bnft_entr_val_found boolean;
  l_num_bnft_recs       number := 0;
  --
  cursor c_rt(cp_elig_per_elctbl_chc_id number,
              cp_enrt_bnft_id           number) is
      select ecr.enrt_rt_id,
             ecr.dflt_val,
             ecr.val,
             ecr.entr_val_at_enrt_flag,
             ecr.acty_base_rt_id
      from   ben_enrt_rt ecr
      where  ecr.elig_per_elctbl_chc_id = cp_elig_per_elctbl_chc_id
      and    ecr.business_group_id = p_business_group_id
      and    ecr.entr_val_at_enrt_flag = 'Y'
      and    ecr.spcl_rt_enrt_rt_id is null
  --    and    ecr.prtt_rt_val_id is null
      union
      select ecr.enrt_rt_id,
             ecr.dflt_val,
             ecr.val,
             ecr.entr_val_at_enrt_flag,
             ecr.acty_base_rt_id
      from   ben_enrt_rt ecr
      where  ecr.enrt_bnft_id = cp_enrt_bnft_id
      and    ecr.business_group_id = p_business_group_id
      and    ecr.entr_val_at_enrt_flag = 'Y'
      and    ecr.spcl_rt_enrt_rt_id is null;
  --    and    ecr.prtt_rt_val_id is null;
  --
  l_rt c_rt%rowtype;
  --
  type g_rt_rec is record
      (enrt_rt_id ben_enrt_rt.enrt_rt_id%type,
       dflt_val   ben_enrt_rt.dflt_val%type,
       calc_val   ben_enrt_rt.dflt_val%type,
       cmcd_rt_val number,
       ann_rt_val  number);
  --
  type g_rt_table is table of g_rt_rec index by binary_integer;
  --
  l_rt_table g_rt_table;
  l_count    number;
  --
  type t_prtt_rt_val_table is table of number index by binary_integer;
  --
  l_pgm_table     g_pgm_table := p_pgm_table ;
  l_pl_table      g_pl_table  := p_pl_table ;
  l_enrt_table    g_enrt_table:= p_enrt_table ;
  l_pgm_count     number;
  l_pl_count      number;
  l_enrt_count    number;
  l_prtt_rt_val_table t_prtt_rt_val_table;
  --
  cursor c_prv(cv_prtt_enrt_rslt_id in number,
               cv_acty_base_rt_id   in number) is
         select  prv.*
         from ben_prtt_rt_val prv
         where prv.prtt_enrt_rslt_id      = cv_prtt_enrt_rslt_id
           and prv.per_in_ler_id     = p_bckdt_per_in_ler_id
           and prv.business_group_id = p_business_group_id
           and prv.acty_base_rt_id   = cv_acty_base_rt_id;
  --
  --
  l_prv_rec c_prv%rowtype;
  l_prv_rec_nulls c_prv%rowtype;
  --
  cursor c_bckt_csd_pen(cv_per_in_ler_id in number) is
         select pen.*, pil.lf_evt_ocrd_dt
         from ben_prtt_enrt_rslt_f pen,
              ben_per_in_ler pil
         where pen.per_in_ler_id = cv_per_in_ler_id
           and pen.per_in_ler_id = pil.per_in_ler_id
           and pen.business_group_id = p_business_group_id
           and pil.business_group_id = p_business_group_id
           and pen.prtt_enrt_rslt_stat_cd is null
           and pen.effective_end_date = hr_api.g_eot
           and pen.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
           and (pen.enrt_cvg_thru_dt is null or
                pen.enrt_cvg_thru_dt    = hr_api.g_eot
               );
  type t_bckt_csd_pen_table is table of c_bckt_csd_pen%rowtype index by binary_integer;
  l_bckt_csd_pil_enrt_table t_bckt_csd_pen_table;
  l_bckt_csd_pen_esd        date;
  l_bckt_csd_pil_leod       date;
  --
  --
  cursor c_prv_ovn (v_prtt_rt_val_id number) is
    select prv.*
          ,abr.input_value_id
          ,abr.element_type_id
    from   ben_prtt_rt_val  prv,
           ben_acty_base_rt_f abr
    where  prtt_rt_val_id = v_prtt_rt_val_id
       and abr.acty_base_rt_id=prv.acty_base_rt_id
       and abr.business_group_id = p_business_group_id
       and p_effective_date between
             abr.effective_start_date and abr.effective_end_date;
  --
  --
  l_upd_rt_val            boolean;
  l_prv_ovn               c_prv_ovn%rowtype;
  l_suspend_flag          varchar2(30);
  l_prtt_rt_val_id1       number;
  l_prtt_rt_val_id2       number;
  l_prtt_rt_val_id3       number;
  l_prtt_rt_val_id4       number;
  l_prtt_rt_val_id5       number;
  l_prtt_rt_val_id6       number;
  l_prtt_rt_val_id7       number;
  l_prtt_rt_val_id8       number;
  l_prtt_rt_val_id9       number;
  l_prtt_rt_val_id10      number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_dpnt_actn_warning     boolean;
  l_bnf_actn_warning      boolean;
  l_ctfn_actn_warning     boolean;
  l_prtt_enrt_interim_id  number;
  l_prtt_enrt_rslt_id     number;
  l_object_version_number number;
  l_cls_enrt_flag         boolean := FALSE;
  l_prev_pgm_id           number := NULL; -- Do not change it
  l_enrt_mthd_cd          varchar2(30);
  l_found                 boolean;
  l_enrt_cnt              number := 1;
  l_max_enrt_esd          date;
  l_esd_out               date;
  l_eed_out               date;
  l_ovn                   number(15);
  l_proc_cd               varchar2(30);
  --
  l_found_non_automatics  boolean;
  l_dummy_number          number;
  --
  l_enrt_cvg_strt_dt     date;

  /* Bug 9307262:Moved the fix done for Bug 7426609 from procedure 'reinstate_the_prev_enrt' to 'reinstate_prev_enrt_for_popl'*/
  /*Added for Bug 7426609*/
 cursor c_get_epe_id(c_prtt_enrt_rslt_id number,c_per_in_ler_id number) is
   select elig_per_elctbl_chc_id from ben_elig_per_elctbl_chc epe,
		ben_prtt_enrt_rslt_f pen
		where pen.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
		and pen.per_in_ler_id = c_per_in_ler_id
		and epe.per_in_ler_id=pen.per_in_ler_id
		and epe.pl_id=pen.pl_id
		and    nvl(epe.pgm_id,-1) = nvl(pen.pgm_id,-1)
		and    nvl(epe.oipl_id,-1) = nvl(pen.oipl_id,-1);
		--and    epe.crntly_enrd_flag = 'Y';

cursor c_interim_bnft(p_elig_per_elctbl_chc_id number) is
        select enb.val bnft_amt,
        enb.enrt_bnft_id
        from   ben_enrt_bnft enb
        where  enb.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
        and    enb.ordr_num in (-1,1)
	order by enb.ordr_num;

l_int_bnft_amt c_interim_bnft%rowtype;
l_sus_bnft_amt c_interim_bnft%rowtype;

cursor c_get_new_epe_id( c_elig_per_elctbl_chc_id number) is
select newchc.elig_per_elctbl_chc_id
from ben_elig_per_elctbl_chc oldchc,
ben_elig_per_elctbl_chc newchc
where oldchc.elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id
and newchc.per_in_ler_id = p_per_in_ler_id
and newchc.pl_id = oldchc.pl_id
and nvl(oldchc.pgm_id,-1) = nvl(newchc.pgm_id,-1)
and nvl(oldchc.oipl_id,-1) = nvl(newchc.oipl_id,-1);

l_interim_chc_id number;

cursor c_prev_pil is
select pil.per_in_ler_id
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.per_in_ler_id not in (p_per_in_ler_id)
    and    pil.person_id     = p_person_id
    and    pil.ler_id        = ler.ler_id
    and    p_effective_date between
           ler.effective_start_date and ler.effective_end_date
    and    ler.typ_cd not in ('IREC', 'SCHEDDU', 'COMP', 'GSP', 'ABS')
    and    pil.per_in_ler_stat_cd not in('BCKDT', 'VOIDD')
    and    pil.lf_evt_ocrd_dt in (select max(lf_evt_ocrd_dt)
				 from ben_per_in_ler pil2,
				      ben_ler_f ler1
				 where pil2.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
				    and pil2.person_id = p_person_id
				    and    pil2.ler_id        = ler1.ler_id
				    and    p_effective_date between
					   ler1.effective_start_date and ler1.effective_end_date
				    and    ler1.typ_cd not in ('IREC', 'SCHEDDU', 'COMP', 'GSP', 'ABS')
				    and pil2.lf_evt_ocrd_dt < (select lf_evt_ocrd_dt from ben_per_in_ler pil3 where
							      per_in_ler_id = p_per_in_ler_id)
                                );

cursor c_prev_pil_epe_id( c_elig_per_elctbl_chc_id number,c_per_in_ler_id number) is
select prevepe.elig_per_elctbl_chc_id
from ben_elig_per_elctbl_chc prevepe,
     ben_elig_per_elctbl_chc newepe,
     ben_prtt_enrt_rslt_f prevpen
where newepe.elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id
and prevepe.per_in_ler_id = c_per_in_ler_id
and newepe.pl_id = prevepe.pl_id
and nvl(prevepe.pgm_id,-1) = nvl(newepe.pgm_id,-1)
and nvl(prevepe.oipl_id,-1) = nvl(newepe.oipl_id,-1)
and prevpen.prtt_enrt_rslt_id = prevepe.prtt_enrt_rslt_id
and prevpen.enrt_cvg_thru_dt = hr_api.g_eot
--and prevpen.effective_end_date = hr_api.g_eot
and prevpen.prtt_enrt_rslt_stat_cd is null;

l_prev_pil_id number;
l_prev_pil_sus_epe_id number;
l_prev_pil_int_epe_id number;
l_prev_sus_bnft_amt number;
l_prev_int_bnft_amt number;
l_prev_sus_bnf_id number;
l_prev_int_bnf_id number;
l_susp_epe_id number;
l_new_susp_epe_id number;
/*End of Bug 7422609*/

/*Bug 9538592: Cursor to check whether the enrollment is an interim enrollment
and suspended and interim enrollment have the same plan,option and plan type*/
cursor c_prev_pil_epe_id1(c_prev_pil_id number,c_epe_id number) is
select epe.elig_per_elctbl_chc_id,
       pen.prtt_enrt_rslt_id,
       pen.bnft_amt,
       epe.object_version_number
from
       ben_elig_per_elctbl_chc epe,
       ben_prtt_enrt_rslt_f pen,
       ben_enrt_bnft bnft
where pen.per_in_ler_id = c_prev_pil_id
      and pen.pl_id = epe.pl_id
      and pen.pgm_id = epe.pgm_id
      and pen.pl_typ_id = epe.pl_typ_id
      and nvl(pen.oipl_id,-1) = nvl(epe.oipl_id,-1)
      and epe.elig_per_elctbl_chc_id = c_epe_id
      and pen.prtt_enrt_rslt_stat_cd is null
      and bnft.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
      and exists
          (select '1' from
	     ben_prtt_enrt_rslt_f pen1
	     where pen1.RPLCS_SSPNDD_RSLT_ID = pen.prtt_enrt_rslt_id
	     and pen1.per_in_ler_id = pen.per_in_ler_id
	     and pen1.prtt_enrt_rslt_stat_cd is null
	     and pen.pl_id = pen1.pl_id
	     and pen.pgm_id = pen1.pgm_id
	     and pen.pl_typ_id = pen1.pl_typ_id
	     and nvl(pen.oipl_id,-1) = nvl(pen1.oipl_id,-1));

 l_prev_pil_epe_id1 c_prev_pil_epe_id1%rowtype;
 /*End Bug 9538592*/
  --
begin
  --
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  open c_bckdt_pil;
  fetch c_bckdt_pil into l_bckdt_pil_prev_stat_cd, l_bckdt_pil_ovn, l_bckt_csd_per_in_ler_id;
  close c_bckdt_pil;
  if l_bckdt_pil_prev_stat_cd = 'PROCD' then
     --
     l_cls_enrt_flag := TRUE;
     --
  end if;
  -- l_pgm_table.delete;
  -- l_pl_table.delete;
  -- l_enrt_table.delete;
  l_bckt_csd_pil_enrt_table.delete;
  --
  -- Get the enrollment results attached to per in ler which
  -- caused the back out of currenlty backed out per in ler.
  --
  if l_bckt_csd_per_in_ler_id is not null then
     --
     for l_bckt_csd_pen_rec in c_bckt_csd_pen(l_bckt_csd_per_in_ler_id) loop
         --
         l_bckt_csd_pil_enrt_table(l_enrt_cnt) := l_bckt_csd_pen_rec;
         l_enrt_cnt := l_enrt_cnt + 1;
         --
     end loop;
     --
  end if;
  --
  -- For each of the enrollment result in back up table, create
  -- a enrollment.
  --
  l_bckdt_pen_count  := p_bckdt_pen_table.COUNT;
  for l_pen_record in 1..l_bckdt_pen_count loop
    --
    l_bckdt_pen_rec := p_bckdt_pen_table(l_pen_record);

         /* Added for Bug 7426609*/
	     g_reinstate_interim_flag := false;
             g_reinstate_interim_chc_id := null;
	 /* End of Bug 7426609*/
    --
    --
    -- If the enrollment record is valid for the current
    -- effective_date then recreate the enrollment.
    --
    hr_utility.set_location('Inside BCKDT pen loop ' || l_proc,20);
    --
    --
    l_bckt_csd_pen_esd  := null;
    l_bckt_csd_pil_leod := null;
    if nvl(l_bckt_csd_pil_enrt_table.last,0) > 0 then
       --
       for l_cnt in 1..l_bckt_csd_pil_enrt_table.LAST loop
           --
           if nvl(l_bckt_csd_pil_enrt_table(l_cnt).pl_id, -1) = nvl(l_bckdt_pen_rec.pl_id, -1) and
              nvl(l_bckt_csd_pil_enrt_table(l_cnt).pgm_id, -1) = nvl(l_bckdt_pen_rec.pgm_id, -1) and
              nvl(l_bckt_csd_pil_enrt_table(l_cnt).oipl_id, -1) = nvl(l_bckdt_pen_rec.oipl_id, -1)
           then
                 l_bckt_csd_pen_esd := l_bckt_csd_pil_enrt_table(l_cnt).effective_start_date;
                 l_bckt_csd_pil_leod := l_bckt_csd_pil_enrt_table(l_cnt).lf_evt_ocrd_dt;
                 exit;
           end if;
           --
       end loop;
       --
    end if;
    --
    --
    l_epe_pen_rec := p_epe_table(l_pen_record);
    --
    hr_utility.set_location('After epe fetch ' || l_proc,30);
    --
    g_sys_date := greatest(trunc(p_enrt_perd_strt_dt),
                    nvl(nvl(l_bckt_csd_pen_esd, g_bckt_csd_lf_evt_ocrd_dt), hr_api.g_sot),
                    l_bckdt_pen_rec.effective_start_date);
    --
    l_max_enrt_esd := greatest(g_sys_date, nvl(l_max_enrt_esd, hr_api.g_sot));
    --
    --
    hr_utility.set_location('Date used to reinstate the enrollment = ' || g_sys_date, 333);
    --
    if g_sys_date <= l_bckdt_pen_rec.effective_end_date
    then
       --
       -- Get the benefits Information.
       --
       l_num_bnft_recs := 0;
       l_bnft_entr_val_found := FALSE;
       l_bnft_rec := l_bnft_rec_reset;
       --
       open c_bnft(l_epe_pen_rec.elig_per_elctbl_chc_id,l_bckdt_pen_rec.bnft_ordr_num );
       loop
         --
         hr_utility.set_location('Inside bnft loop ' || l_proc,40);
         --Bug 3315323 we need to reinstate the previuos benefit amount for the case
         --of SAAEAR also as enb record may have null value there for first enrollment
         --or it may not be the right amount.
         --
         fetch c_bnft into l_bnft_rec;
         exit when c_bnft%notfound;
         if l_bnft_rec.entr_val_at_enrt_flag = 'Y' OR l_bnft_rec.cvg_mlt_cd='SAAEAR' then
            l_bnft_entr_val_found := TRUE;
         end if;
         l_num_bnft_recs := l_num_bnft_recs + 1;
         --
         if l_bckdt_pen_rec.BNFT_AMT = l_bnft_rec.VAL then
            --
            -- Found the benefit we are looking for, so exit.
            --
            exit;
            --
         end if;
         --
       end loop;
       --
       -- Bug 5282 :  When a backed out life event is repeocessed
       -- plans with enter 'enter val at enrollment' coverage amount
       -- previous amount is not used when enrollments reinstated.
       --
       if l_bnft_entr_val_found
       then
         if l_num_bnft_recs =  0 then
            null;
            -- This is a error condition, so rollback all the reinstate process.
         else
            --
            l_bnft_rec.val := l_bckdt_pen_rec.BNFT_AMT;
            --
         end if;
       end if;
       hr_utility.set_location(l_proc,50);
       close c_bnft;
       --
       for l_count in 1..10 loop
          --
          -- Initialise array to null
          --
          l_rt_table(l_count).enrt_rt_id := null;
          l_rt_table(l_count).dflt_val := null;
          --
       end loop;
       --
       -- Now get the rates.
       --
       l_count:= 0;
       --
       for l_rec in c_rt(l_epe_pen_rec.elig_per_elctbl_chc_id,
                         l_bnft_rec.enrt_bnft_id)
       loop
          --
          hr_utility.set_location('Inside rate loop ' ||l_proc,50);
          --
          -- Get the prtt rate val for this enrollment result.
          -- Use to pass to the enrollment process.
          --
          -- Bug : 1634870 : If the user not selected the rate before backout
          -- then do not pass it to the reinstate process.
          --
          hr_utility.set_location('enrt_rt_id : dflt_val : val : entr_val' ||
                                  '_at_enrt_flag : acty_base_rt_id : ' , 501);
          hr_utility.set_location(l_rec.enrt_rt_id || ' : ' || l_rec.dflt_val || ' : ' || l_rec.val || ' : '
                                  || l_rec.entr_val_at_enrt_flag || ' : ' ||
                                  l_rec.acty_base_rt_id, 501);
          --
          l_prv_rec := l_prv_rec_nulls;
          open c_prv(l_bckdt_pen_rec.prtt_enrt_rslt_id ,
                     l_rec.acty_base_rt_id);
          fetch c_prv into l_prv_rec;
          if c_prv%found then -- l_prv_rec.prtt_rt_val_id is not null then
             --
             l_count := l_count+1;
             hr_utility.set_location('prtt_rt_val_id : rt_val : ' ||
                     l_prv_rec.prtt_rt_val_id ||  ' : ' || l_prv_rec.rt_val
                     || ' : ' || l_prv_rec.acty_base_rt_id , 502);
             l_rt_table(l_count).enrt_rt_id := l_rec.enrt_rt_id;
             if l_prv_rec.mlt_cd in ('CL','CVG','AP','PRNT','CLANDCVG','APANDCVG','PRNTANDCVG') then
                l_rt_table(l_count).dflt_val := l_rec.dflt_val;
                l_rt_table(l_count).calc_val := l_prv_rec.rt_val;
                l_rt_table(l_count).cmcd_rt_val := l_prv_rec.cmcd_rt_val;
                l_rt_table(l_count).ann_rt_val  := l_prv_rec.ann_rt_val;
             else
                l_rt_table(l_count).dflt_val   := l_prv_rec.rt_val;
                l_rt_table(l_count).calc_val   := l_prv_rec.rt_val;
                l_rt_table(l_count).cmcd_rt_val := l_prv_rec.cmcd_rt_val;
                l_rt_table(l_count).ann_rt_val  := l_prv_rec.ann_rt_val;
             end if;
             --
          end if;
          close c_prv;
          --
       end loop;
       --
       -- Call election information batch process
       --
       -- initialize all the out parameters.
       l_suspend_flag          := null;
       l_prtt_rt_val_id1       := null;
       l_prtt_rt_val_id2       := null;
       l_prtt_rt_val_id3       := null;
       l_prtt_rt_val_id4       := null;
       l_prtt_rt_val_id5       := null;
       l_prtt_rt_val_id6       := null;
       l_prtt_rt_val_id7       := null;
       l_prtt_rt_val_id8       := null;
       l_prtt_rt_val_id9       := null;
       l_prtt_rt_val_id10      := null;
       l_effective_start_date  := null;
       l_effective_end_date    := null;
       l_dpnt_actn_warning     := null;
       l_bnf_actn_warning      := null;
       l_ctfn_actn_warning     := null;
       l_prtt_enrt_interim_id  := null;
       l_prtt_enrt_rslt_id     := null;
       l_object_version_number := null;
       l_enrt_cvg_strt_dt      := null;

       -- if cvg_st_dt_cd is enterable then copy the l_bckdt_pen_rec.enrt_cvg_strt_dt
       -- 5746429 starts

       if  l_epe_pen_rec.enrt_cvg_strt_dt_cd = 'ENTRBL'
        then
	      l_enrt_cvg_strt_dt := l_bckdt_pen_rec.enrt_cvg_strt_dt ;
       end if ;
       -- 5746429 ends
       --
       hr_utility.set_location('Calling ben_election_information ' ||l_proc,60);
       hr_utility.set_location('Calling l_bnft_rec.val ' ||l_bnft_rec.val,60);
       hr_utility.set_location('Calling l_enrt_cvg_strt_dt ' ||l_enrt_cvg_strt_dt,60);
       --

       /*Added for Bug 7426609 */
       /* Get the old epe id of the Interim from the backed out pen records.  */
       hr_utility.set_location('Suspended Flag  ' ||l_bckdt_pen_rec.SSPNDD_FLAG,60);
       hr_utility.set_location('Interim Rslt Id  ' ||l_bckdt_pen_rec.RPLCS_SSPNDD_RSLT_ID,60);
       hr_utility.set_location('P_per_in_ler_id  ' ||p_per_in_ler_id,60);


       if(l_bckdt_pen_rec.SSPNDD_FLAG = 'Y' and l_bckdt_pen_rec.RPLCS_SSPNDD_RSLT_ID is not NULL) then
		l_prev_pil_id := null;
		l_prev_pil_sus_epe_id := null;
		l_prev_pil_int_epe_id := null;
		l_prev_sus_bnft_amt := null;
		l_prev_int_bnft_amt := null;
		l_prev_sus_bnf_id := null;
		l_prev_int_bnf_id := null;
		l_susp_epe_id := null;
		l_new_susp_epe_id := null;

             open c_prev_pil;
	     fetch c_prev_pil into l_prev_pil_id;
	     close c_prev_pil;
	     hr_utility.set_location('Prev per_in_ler_id='||l_prev_pil_id,9995);

	     /* Get new and old suspended epe id */
	     open c_get_epe_id(l_bckdt_pen_rec.prtt_enrt_rslt_id,l_bckdt_pen_rec.per_in_ler_id);
	     fetch c_get_epe_id into l_susp_epe_id;
	     close c_get_epe_id;
	     hr_utility.set_location('Old Susp_chc='||l_susp_epe_id,9995);

	     open c_get_new_epe_id(l_susp_epe_id);
	     fetch c_get_new_epe_id into l_new_susp_epe_id;
	     close c_get_new_epe_id;
	     hr_utility.set_location('New Susp_chc='||l_new_susp_epe_id,9995);

	     open c_interim_bnft(l_new_susp_epe_id);
	     fetch c_interim_bnft into l_sus_bnft_amt;
	     close c_interim_bnft;

	     open c_prev_pil_epe_id(l_new_susp_epe_id,l_prev_pil_id);
	     fetch c_prev_pil_epe_id into l_prev_pil_sus_epe_id;
	     close c_prev_pil_epe_id;
	     hr_utility.set_location('Prev Susp_chc='||l_prev_pil_sus_epe_id,9995);

	     if(l_prev_pil_sus_epe_id is not null) then
		 open c_interim_bnft(l_prev_pil_sus_epe_id);
		 fetch c_interim_bnft into l_prev_sus_bnft_amt,l_prev_sus_bnf_id;
		 close c_interim_bnft;
		 hr_utility.set_location('Prev Susp bnft amt='||l_prev_sus_bnft_amt,9995);
		      if( nvl(l_prev_sus_bnft_amt,-1) = nvl(l_sus_bnft_amt.bnft_amt,-1) ) then

			     /* Get new and old interim epe id */
			     open c_get_epe_id(l_bckdt_pen_rec.RPLCS_SSPNDD_RSLT_ID,l_bckdt_pen_rec.per_in_ler_id);
			     fetch c_get_epe_id into g_reinstate_interim_chc_id;
			     close c_get_epe_id;

			     open c_get_new_epe_id(g_reinstate_interim_chc_id);
			     fetch c_get_new_epe_id into l_interim_chc_id;
			     close c_get_new_epe_id;
			     g_reinstate_interim_chc_id := l_interim_chc_id;
			     hr_utility.set_location('New interim_chc='||g_reinstate_interim_chc_id,9995);

			     open c_interim_bnft(l_interim_chc_id/*ben_lf_evt_clps_restore.g_reinstate_interim_chc_id*/ );
			     fetch c_interim_bnft into l_int_bnft_amt;
			     close c_interim_bnft;

			     open c_prev_pil_epe_id(l_interim_chc_id,l_prev_pil_id);
			     fetch c_prev_pil_epe_id into l_prev_pil_int_epe_id;
			     close c_prev_pil_epe_id;
			     hr_utility.set_location('Prev epe id='||l_prev_pil_int_epe_id,9995);

			     if(l_prev_pil_int_epe_id is not null) then
				 open c_interim_bnft(l_prev_pil_int_epe_id);
				 fetch c_interim_bnft into l_prev_int_bnft_amt,l_prev_int_bnf_id;
				 close c_interim_bnft;
				 hr_utility.set_location('Prev bnft amt='||l_prev_int_bnft_amt,9995);
				      if( nvl(l_prev_int_bnft_amt,-1) = nvl(l_int_bnft_amt.bnft_amt,-1) ) then
					  ben_lf_evt_clps_restore.g_reinstate_interim_flag := true;
					  hr_utility.set_location('Value set to true ',9995);
				       end if;
			     end if;
          		 end if;
              	 end if;
	   hr_utility.set_location('Interim chc id  ' ||g_reinstate_interim_chc_id,60);
       end if;
       /*Ended for Bug 7426609 */
       --

       /* Bug 9538592:In a case where epe table has only one record for the plan and interim and suspended enrollments corresponds to same plan and opton,
       resinstating the enrollments of the backedout life event, pen_id in epe table is set with the suspended enrollment result of the previous life event.
       Set the pen_id to interim enrollment result*/
       if(l_bckdt_pen_rec.SSPNDD_FLAG <> 'Y') then
          hr_utility.set_location('Inside if cond  ',909);
	  open c_prev_pil;
	  fetch c_prev_pil into l_prev_pil_id;
	  close c_prev_pil;
	  hr_utility.set_location('Prev per_in_ler_id='||l_prev_pil_id,909);
	  open c_prev_pil_epe_id1(l_prev_pil_id,l_epe_pen_rec.elig_per_elctbl_chc_id);
	  fetch c_prev_pil_epe_id1 into l_prev_pil_epe_id1;
	  if(c_prev_pil_epe_id1%found and l_bnft_rec.val = l_prev_pil_epe_id1.bnft_amt) then
	     hr_utility.set_location('Before updating epe ',909);
             hr_utility.set_location('prev pen_id '||l_prev_pil_epe_id1.prtt_enrt_rslt_id,909);
	     ben_ELIG_PER_ELC_CHC_api.update_ELIG_PER_ELC_CHC
			(p_validate                => FALSE
			 ,p_elig_per_elctbl_chc_id  => l_epe_pen_rec.elig_per_elctbl_chc_id
			 ,p_prtt_enrt_rslt_id       => l_prev_pil_epe_id1.prtt_enrt_rslt_id
			 ,p_object_version_number   => l_prev_pil_epe_id1.object_version_number
			 ,p_effective_date          => g_sys_date
			 );

			 g_create_new_result := 'Y';
	  end if;
	  close c_prev_pil_epe_id1;
       end if;
       /*End of Bug 9538592*/

       ben_election_information.election_information
          (p_elig_per_elctbl_chc_id => l_epe_pen_rec.elig_per_elctbl_chc_id,
           p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id,-- l_epe_pen_rec.prtt_enrt_rslt_id,
           p_effective_date         => g_sys_date,
           p_enrt_mthd_cd           => l_bckdt_pen_rec.enrt_mthd_cd,
           p_business_group_id      => p_business_group_id,
           p_enrt_bnft_id           => l_bnft_rec.enrt_bnft_id,
           p_bnft_val               => l_bnft_rec.val,
	       p_enrt_cvg_strt_dt       => l_enrt_cvg_strt_dt, -- 5746429
           p_enrt_rt_id1            => l_rt_table(1).enrt_rt_id,
           p_rt_val1                => l_rt_table(1).dflt_val,
           p_ann_rt_val1            => l_rt_table(1).ann_rt_val,
           p_enrt_rt_id2            => l_rt_table(2).enrt_rt_id,
           p_rt_val2                => l_rt_table(2).dflt_val,
           p_ann_rt_val2            => l_rt_table(2).ann_rt_val,
           p_enrt_rt_id3            => l_rt_table(3).enrt_rt_id,
           p_rt_val3                => l_rt_table(3).dflt_val,
           p_ann_rt_val3            => l_rt_table(3).ann_rt_val,
           p_enrt_rt_id4            => l_rt_table(4).enrt_rt_id,
           p_rt_val4                => l_rt_table(4).dflt_val,
           p_ann_rt_val4            => l_rt_table(4).ann_rt_val,
           p_enrt_rt_id5            => l_rt_table(5).enrt_rt_id,
           p_rt_val5                => l_rt_table(5).dflt_val,
           p_ann_rt_val5            => l_rt_table(5).ann_rt_val,
           p_enrt_rt_id6            => l_rt_table(6).enrt_rt_id,
           p_rt_val6                => l_rt_table(6).dflt_val,
           p_ann_rt_val6            => l_rt_table(6).ann_rt_val,
           p_enrt_rt_id7            => l_rt_table(7).enrt_rt_id,
           p_rt_val7                => l_rt_table(7).dflt_val,
           p_ann_rt_val7            => l_rt_table(7).ann_rt_val,
           p_enrt_rt_id8            => l_rt_table(8).enrt_rt_id,
           p_rt_val8                => l_rt_table(8).dflt_val,
           p_ann_rt_val8            => l_rt_table(8).ann_rt_val,
           p_enrt_rt_id9            => l_rt_table(9).enrt_rt_id,
           p_rt_val9                => l_rt_table(9).dflt_val,
           p_ann_rt_val9            => l_rt_table(9).ann_rt_val,
           p_enrt_rt_id10           => l_rt_table(10).enrt_rt_id,
           p_rt_val10               => l_rt_table(10).dflt_val,
           p_ann_rt_val10           => l_rt_table(10).ann_rt_val,
           p_datetrack_mode         => hr_api.g_insert,
           p_suspend_flag           => l_suspend_flag,
           p_called_from_sspnd      => 'N',
           p_prtt_enrt_interim_id   => l_prtt_enrt_interim_id,
           p_prtt_rt_val_id1        => l_prtt_rt_val_id1,
           p_prtt_rt_val_id2        => l_prtt_rt_val_id2,
           p_prtt_rt_val_id3        => l_prtt_rt_val_id3,
           p_prtt_rt_val_id4        => l_prtt_rt_val_id4,
           p_prtt_rt_val_id5        => l_prtt_rt_val_id5,
           p_prtt_rt_val_id6        => l_prtt_rt_val_id6,
           p_prtt_rt_val_id7        => l_prtt_rt_val_id7,
           p_prtt_rt_val_id8        => l_prtt_rt_val_id8,
           p_prtt_rt_val_id9        => l_prtt_rt_val_id9,
           p_prtt_rt_val_id10       => l_prtt_rt_val_id10,
           -- 6131609 : reinstate DFF values
            p_pen_attribute_category => l_bckdt_pen_rec.pen_attribute_category,
            p_pen_attribute1  => l_bckdt_pen_rec.pen_attribute1,
            p_pen_attribute2  => l_bckdt_pen_rec.pen_attribute2,
            p_pen_attribute3  => l_bckdt_pen_rec.pen_attribute3,
            p_pen_attribute4  => l_bckdt_pen_rec.pen_attribute4,
            p_pen_attribute5  => l_bckdt_pen_rec.pen_attribute5,
            p_pen_attribute6  => l_bckdt_pen_rec.pen_attribute6,
            p_pen_attribute7  => l_bckdt_pen_rec.pen_attribute7,
            p_pen_attribute8  => l_bckdt_pen_rec.pen_attribute8,
            p_pen_attribute9  => l_bckdt_pen_rec.pen_attribute9,
            p_pen_attribute10 => l_bckdt_pen_rec.pen_attribute10,
            p_pen_attribute11 => l_bckdt_pen_rec.pen_attribute11,
            p_pen_attribute12 => l_bckdt_pen_rec.pen_attribute12,
            p_pen_attribute13 => l_bckdt_pen_rec.pen_attribute13,
            p_pen_attribute14 => l_bckdt_pen_rec.pen_attribute14,
            p_pen_attribute15 => l_bckdt_pen_rec.pen_attribute15,
            p_pen_attribute16 => l_bckdt_pen_rec.pen_attribute16,
            p_pen_attribute17 => l_bckdt_pen_rec.pen_attribute17,
            p_pen_attribute18 => l_bckdt_pen_rec.pen_attribute18,
            p_pen_attribute19 => l_bckdt_pen_rec.pen_attribute19,
            p_pen_attribute20 => l_bckdt_pen_rec.pen_attribute20,
            p_pen_attribute21 => l_bckdt_pen_rec.pen_attribute21,
            p_pen_attribute22 => l_bckdt_pen_rec.pen_attribute22,
            p_pen_attribute23 => l_bckdt_pen_rec.pen_attribute23,
            p_pen_attribute24 => l_bckdt_pen_rec.pen_attribute24,
            p_pen_attribute25 => l_bckdt_pen_rec.pen_attribute25,
            p_pen_attribute26 => l_bckdt_pen_rec.pen_attribute26,
            p_pen_attribute27 => l_bckdt_pen_rec.pen_attribute27,
            p_pen_attribute28 => l_bckdt_pen_rec.pen_attribute28,
            p_pen_attribute29 => l_bckdt_pen_rec.pen_attribute29,
            p_pen_attribute30 => l_bckdt_pen_rec.pen_attribute30,
            --
           p_object_version_number  => l_object_version_number,
           p_effective_start_date   => l_effective_start_date,
           p_effective_end_date     => l_effective_end_date,
           p_dpnt_actn_warning      => l_dpnt_actn_warning,
           p_bnf_actn_warning       => l_bnf_actn_warning,
           p_ctfn_actn_warning      => l_ctfn_actn_warning);
       --
       -- changed 7176884 begin
       delete from ben_le_clsn_n_rstr
       where  bkup_tbl_id = l_bckdt_pen_rec.prtt_enrt_rslt_id
       and    per_in_ler_id = p_bckdt_per_in_ler_id
       and    bkup_tbl_typ_cd = 'BEN_PRTT_ENRT_RSLT_F'
       and    person_id = p_person_id;
       -- changed 7176884 end
       --
       l_prtt_rt_val_table(1)       := l_prtt_rt_val_id1;
       l_prtt_rt_val_table(2)       := l_prtt_rt_val_id2;
       l_prtt_rt_val_table(3)       := l_prtt_rt_val_id3;
       l_prtt_rt_val_table(4)       := l_prtt_rt_val_id4;
       l_prtt_rt_val_table(5)       := l_prtt_rt_val_id5;
       l_prtt_rt_val_table(6)       := l_prtt_rt_val_id6;
       l_prtt_rt_val_table(7)       := l_prtt_rt_val_id7;
       l_prtt_rt_val_table(8)       := l_prtt_rt_val_id8;
       l_prtt_rt_val_table(9)       := l_prtt_rt_val_id9;
       l_prtt_rt_val_table(10)      := l_prtt_rt_val_id10;


       -- if rate is enter value at enrollment and calculation method is like multiple and
       -- calculate flag is on, first the prtt_rt_val is created with default value and
       -- subsequently the calculated value is updated by taking values from backedout rows
       for i  in 1..l_count loop
          l_upd_rt_val  := FALSE;
          open c_prv_ovn (l_prtt_rt_val_table(i));
          fetch c_prv_ovn into l_prv_ovn;
          if c_prv_ovn%found then
              if l_prv_ovn.rt_val <>l_rt_table(i).calc_val  then
                 l_upd_rt_val := TRUE;
              end if;
          end if;
          close c_prv_ovn;
          if l_upd_rt_val then
              ben_prtt_rt_val_api.update_prtt_rt_val
                (p_prtt_rt_val_id        => l_prtt_rt_val_table(i)
                ,p_person_id             => p_person_id
                ,p_rt_val                => l_rt_table(i).calc_val
                ,p_acty_ref_perd_cd      => l_prv_ovn.acty_ref_perd_cd
                ,p_cmcd_rt_val           => l_rt_table(i).cmcd_rt_val
                ,p_cmcd_ref_perd_cd      => l_prv_ovn.cmcd_ref_perd_cd
                ,p_ann_rt_val            => l_rt_table(i).ann_rt_val
                ,p_business_group_id     => p_business_group_id
                ,p_object_version_number => l_prv_ovn.object_version_number
                ,p_effective_date        => g_sys_date);
              --
          end if;
       end loop;



       -- Populate the enrollment results electble choice data
       -- to be used for dependents and beneficiaries restoration.
       -- the reinstate beneficiaries and dependents processes
       -- from hare as multi row edit process may create
       -- these records as part of recycle. So reinstate beneficiaries
       -- and dependents processes should be called after multi row edits.
       --
       l_found := FALSE;
       if nvl(l_enrt_table.LAST, 0) > 0 then
          for l_cnt in 1..l_enrt_table.LAST loop
              --
              if l_enrt_table(l_cnt).prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
              then
                 l_found := TRUE;
                 exit;
              end if;
              --
           end loop;
       end if;
       --
       if not l_found then
          --
          --
          l_enrt_count := nvl(l_enrt_table.LAST, 0) + 1;
          l_enrt_table(l_enrt_count).prtt_enrt_rslt_id := l_prtt_enrt_rslt_id;
          l_enrt_table(l_enrt_count).effective_start_date := l_effective_start_date;
          l_enrt_table(l_enrt_count).bckdt_prtt_enrt_rslt_id
                                           := l_bckdt_pen_rec.prtt_enrt_rslt_id;
          l_enrt_table(l_enrt_count).bckdt_enrt_ovridn_flag
                                           := l_bckdt_pen_rec.enrt_ovridn_flag;
          l_enrt_table(l_enrt_count).bckdt_enrt_cvg_strt_dt
                                           := l_bckdt_pen_rec.enrt_cvg_strt_dt;
          l_enrt_table(l_enrt_count).bckdt_enrt_cvg_thru_dt
                                           := l_bckdt_pen_rec.enrt_cvg_thru_dt;
          l_enrt_table(l_enrt_count).enrt_ovrid_thru_dt
                                           := l_bckdt_pen_rec.enrt_ovrid_thru_dt;
          l_enrt_table(l_enrt_count).enrt_ovrid_rsn_cd
                                           := l_bckdt_pen_rec.enrt_ovrid_rsn_cd;
          l_enrt_table(l_enrt_count).g_sys_date := g_sys_date;
          l_enrt_table(l_enrt_count).pen_ovn_number := l_object_version_number;
          l_enrt_table(l_enrt_count).old_pl_id := l_bckdt_pen_rec.pl_id;
          l_enrt_table(l_enrt_count).new_pl_id := l_bckdt_pen_rec.pl_id;
          l_enrt_table(l_enrt_count).old_oipl_id := l_bckdt_pen_rec.oipl_id;
          l_enrt_table(l_enrt_count).new_oipl_id := l_bckdt_pen_rec.oipl_id;
          l_enrt_table(l_enrt_count).old_pl_typ_id := l_bckdt_pen_rec.pl_typ_id;
          l_enrt_table(l_enrt_count).new_pl_typ_id := l_bckdt_pen_rec.pl_typ_id;
          l_enrt_table(l_enrt_count).pgm_id := l_bckdt_pen_rec.pgm_id;
          l_enrt_table(l_enrt_count).ler_id := null;
          l_enrt_table(l_enrt_count).elig_per_elctbl_chc_id
                                           := l_epe_pen_rec.elig_per_elctbl_chc_id;
          l_enrt_table(l_enrt_count).dpnt_cvg_strt_dt_cd
                                           := l_epe_pen_rec.dpnt_cvg_strt_dt_cd;
          l_enrt_table(l_enrt_count).dpnt_cvg_strt_dt_rl
                                           := l_epe_pen_rec.dpnt_cvg_strt_dt_rl;
	  l_enrt_table(l_enrt_count).enrt_mthd_cd := l_bckdt_pen_rec.enrt_mthd_cd; -- Bug 9045559
          --
       end if;
       --
       if l_epe_pen_rec.pgm_id is null then
          --
          l_found := FALSE;
          if nvl(l_pl_table.LAST, 0) > 0 then
             --
             --
             for l_cnt in 1..l_pl_table.LAST loop
                 --
	         --
                 if l_pl_table(l_cnt).pl_id = l_epe_pen_rec.pl_id /* and  -- Bug 5685222
                    l_pl_table(l_cnt).enrt_mthd_cd = l_bckdt_pen_rec.enrt_mthd_cd */
                 then
                    l_found := TRUE;
                    l_pl_table(l_cnt).max_enrt_esd := greatest(l_pl_table(l_cnt).max_enrt_esd,
                                                               g_sys_date);
                    exit;
                 end if;
                 --
             end loop;
          end if;
          --
          if not l_found then
             --
             --
             l_pl_count := nvl(l_pl_table.LAST, 0) + 1;
             l_pl_table(l_pl_count).pl_id            := l_epe_pen_rec.pl_id;
             l_pl_table(l_pl_count).enrt_mthd_cd     := l_bckdt_pen_rec.enrt_mthd_cd;
             l_pl_table(l_pl_count).multi_row_edit_done := FALSE;
             l_pl_table(l_pl_count).max_enrt_esd := g_sys_date;
             --
          end if;
       else
          --
          l_found := FALSE;
          if nvl(l_pgm_table.LAST, 0) > 0 then
             for l_cnt in 1..l_pgm_table.LAST loop
                 --
                 if l_pgm_table(l_cnt).pgm_id = l_epe_pen_rec.pgm_id /* and
                    l_pgm_table(l_cnt).enrt_mthd_cd = l_bckdt_pen_rec.enrt_mthd_cd */
                 then
                    l_found := TRUE;
                    l_pgm_table(l_cnt).max_enrt_esd := greatest(l_pgm_table(l_cnt).max_enrt_esd,
                                                               g_sys_date);
                    exit;
                 end if;
                 --
             end loop;
          end if;
          --
          if not l_found then
             --
             --
             l_pgm_count := nvl(l_pgm_table.LAST, 0) + 1;
             l_pgm_table(l_pgm_count).pgm_id         := l_epe_pen_rec.pgm_id;
             l_pgm_table(l_pgm_count).enrt_mthd_cd   := l_bckdt_pen_rec.enrt_mthd_cd;
             l_pgm_table(l_pgm_count).multi_row_edit_done := FALSE;
             l_pgm_table(l_pgm_count).max_enrt_esd := g_sys_date;
             --
          end if;
          --
       end if;
       --
    end if;
    --
  end loop;
  --
  -- Apply the multi row edits.
  --
  if nvl(l_pgm_table.LAST, 0) > 0 then
     for l_cnt in 1..l_pgm_table.LAST loop
        --
        -- First see multi row edits are already checked.
        --
        l_found  := FALSE;
        for l_inn_cnt in 1..l_cnt loop
          if l_pgm_table(l_inn_cnt).pgm_id = l_pgm_table(l_cnt).pgm_id and
             l_pgm_table(l_inn_cnt).multi_row_edit_done
          then
             l_found  := TRUE;
             exit;
          end if;
        end loop;
        --
        if not l_found then
           --
           --
           -- Now see if there are non automatic enrollments
           --
           if l_bckdt_pil_prev_stat_cd='STRTD' then
             l_found_non_automatics:=FALSE;
             /* Bug 9045559: Instead of checking the enrollment code at the program level, check whether any
	     explicit or default enrollments from the reinstated enrollment list. Commented the below loop.
	     Check for explicit or default enrollments from l_enrt_table instead checking the code set at l_pgm_table level.
	     For few customers Automatic enrollment record is picked up first for reinstatement and enrt_mthd_cd is set to 'A' at the
	     program level. Becuase of this multi_rows_edit is not called even though default and explicit enrollments exist*/
             /*for l_inn_cnt in 1..l_pgm_table.last loop
               hr_utility.set_location('enrt mthd code'||l_pgm_table(l_inn_cnt).enrt_mthd_cd,43333);
               hr_utility.set_location('pgm_id '||l_pgm_table(l_inn_cnt).pgm_id,43333);
               if l_pgm_table(l_inn_cnt).pgm_id = l_pgm_table(l_cnt).pgm_id and
                  l_pgm_table(l_inn_cnt).enrt_mthd_cd<>'A'
               then
                  l_found_non_automatics  := TRUE;
                  exit;
               end if;
             end loop;*/
	     /* added for Bug 9045559*/
             for l_inn_cnt in 1..l_enrt_table.last loop
               hr_utility.set_location('enrt mthd code'||l_enrt_table(l_inn_cnt).enrt_mthd_cd,43333);
               hr_utility.set_location('pgm table pgm_id '||l_pgm_table(l_cnt).pgm_id,43333);
	       hr_utility.set_location('enrt pgm_id '||l_enrt_table(l_inn_cnt).pgm_id,43333);
               if l_enrt_table(l_inn_cnt).pgm_id = l_pgm_table(l_cnt).pgm_id and
                  l_enrt_table(l_inn_cnt).enrt_mthd_cd <> 'A'
               then
                  l_found_non_automatics  := TRUE;
                  exit;
               end if;
	     end loop;
	     /* End of Bug 9045559*/
           end if;
           --
           if l_bckdt_pil_prev_stat_cd<>'STRTD' or
              l_found_non_automatics then
             hr_utility.set_location('Date for multi row edits = ' ||
                                      l_pgm_table(l_cnt).max_enrt_esd || '  ' || ' pgm = ' ||
                                      l_pgm_table(l_cnt).pgm_id, 333);
             ben_prtt_enrt_result_api.multi_rows_edit
              (p_person_id         => p_person_id,
               p_effective_date    => l_pgm_table(l_cnt).max_enrt_esd,
               p_business_group_id => p_business_group_id,
               p_per_in_ler_id     => p_per_in_ler_id,
               p_pgm_id            => l_pgm_table(l_cnt).pgm_id);
             --
           end if;
           l_pgm_table(l_cnt).multi_row_edit_done := TRUE;
           --
        end if;
        --
     end loop;
  end if;
    --
    p_pgm_table := l_pgm_table ;
    p_pl_table := l_pl_table ;
    p_enrt_table := l_enrt_table ;
    p_max_enrt_esd := l_max_enrt_esd ;
    --
    hr_utility.set_location ('Leaving '||l_proc,10);
    --
  end reinstate_prev_enrt_for_popl ;
    --
  procedure reinstate_post_enrt(
                             p_pgm_table           in g_pgm_table
                            ,p_pl_table            in g_pl_table
                            ,p_enrt_table      in out nocopy g_enrt_table
                            ,p_max_enrt_esd        in date
                            ,p_person_id           in number
                            ,p_business_group_id   in number
                            ,p_effective_date      in date
                            ,p_per_in_ler_id       in number
                            ,p_bckdt_per_in_ler_id in number
                            ,p_cls_enrt_flag       in boolean default false
    ) is
    --
    l_proc                  varchar2(72) := g_package||'.reinstate_post_enrt';
    --
    l_proc_cd               varchar2(30);
    l_procd_dt              date;
    l_strtd_dt              date;
    l_voidd_dt              date;
    l_esd_out               date;
    l_eed_out               date;
    l_ovn                   number(15);
    l_enrt_mthd_cd          ben_prtt_enrt_rslt_f.enrt_mthd_cd%type;

    --
  begin
    --
    hr_utility.set_location ('Entering '||l_proc,10);
    hr_utility.set_location ('p_max_enrt_esd '||p_max_enrt_esd,10);
    --
    ben_prtt_enrt_result_api.multi_rows_edit
      (p_person_id         => p_person_id,
       p_effective_date    => p_max_enrt_esd,
       p_business_group_id => p_business_group_id,
       p_per_in_ler_id     => p_per_in_ler_id,
       p_pgm_id            => null);
    --
    -- Invoke post result process once for Explicit/Automatic/ Default.
    --
    ben_proc_common_enrt_rslt.process_post_results
      (p_person_id          => p_person_id,
       p_enrt_mthd_cd       => 'E',
       p_effective_date     => p_max_enrt_esd,
       p_business_group_id  => p_business_group_id,
       p_per_in_ler_id      => p_per_in_ler_id);
    --
    ben_proc_common_enrt_rslt.process_post_results
      (p_person_id          => p_person_id,
       p_enrt_mthd_cd       => 'D',
       p_effective_date     => p_max_enrt_esd,
       p_business_group_id  => p_business_group_id,
       p_per_in_ler_id      => p_per_in_ler_id);
    --
    ben_proc_common_enrt_rslt.process_post_results
      (p_person_id          => p_person_id,
       p_enrt_mthd_cd       => 'A',
       p_effective_date     => p_max_enrt_esd,
       p_business_group_id  => p_business_group_id,
       p_per_in_ler_id      => p_per_in_ler_id);
    --
  -- end if;
  --
  -- Apply process post enrollments once for each program.
  --
  if nvl(p_pgm_table.LAST, 0) > 0 then
     for l_cnt in 1..p_pgm_table.LAST loop
     --
        -- Bug 5623259.
        --
        if p_pgm_table(l_cnt).enrt_mthd_cd = 'E' then
           l_proc_cd := 'FORMENRT';
        elsif p_pgm_table(l_cnt).enrt_mthd_cd = 'D' then
           l_proc_cd := 'DFLTENRT';
        else
           l_proc_cd := NULL;
        end if;
     --
     -- 9575477 -  If explicit elections were made, pass
     --            the correct enrollment method code to post enrollment.
     --
     --
     l_enrt_mthd_cd := p_pgm_table(l_cnt).enrt_mthd_cd;
     --
     for l_enrt_cnt in 1..p_enrt_table.last loop
       hr_utility.set_location('enrt mthd code'||p_enrt_table(l_enrt_cnt).enrt_mthd_cd,43333);
       --
       if p_enrt_table(l_enrt_cnt).pgm_id = p_pgm_table(l_cnt).pgm_id and
          p_enrt_table(l_enrt_cnt).enrt_mthd_cd = 'E' then
          l_enrt_mthd_cd  := p_enrt_table(l_enrt_cnt).enrt_mthd_cd;
          exit;
        end if;
     end loop;
     --
     --  end 9575477
     --
     hr_utility.set_location('enrt mthd cd ' || p_pgm_table(l_cnt).enrt_mthd_cd, 310);
        ben_proc_common_enrt_rslt.process_post_enrollment
          (p_per_in_ler_id     => p_per_in_ler_id,
           p_pgm_id            => p_pgm_table(l_cnt).pgm_id,
           p_pl_id             => null,
           p_enrt_mthd_cd      => l_enrt_mthd_cd, -- 9575477
           p_cls_enrt_flag     => FALSE,
           --RCHASE
           p_proc_cd           => l_proc_cd,
           p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_pgm_table(l_cnt).max_enrt_esd );
        --
      end loop;
  end if;
  --
  -- Apply process post enrollments once for each program.
  --
  if nvl(p_pl_table.LAST, 0) > 0 then
     for l_cnt in 1..p_pl_table.LAST loop
        --
        -- Invoke post result process
        --
        hr_utility.set_location('Date = ' || p_pl_table(l_cnt).max_enrt_esd, 333);
        hr_utility.set_location('PL = ' || p_pl_table(l_cnt).pl_id, 333);
        --
        -- Bug 5623259.
        --
        if p_pl_table(l_cnt).enrt_mthd_cd = 'E' then
           l_proc_cd := 'FORMENRT';
        elsif p_pl_table(l_cnt).enrt_mthd_cd = 'D' then
           l_proc_cd := 'DFLTENRT';
        else
           l_proc_cd := NULL;
        end if;
        --
        ben_proc_common_enrt_rslt.process_post_enrollment
          (p_per_in_ler_id     => p_per_in_ler_id,
           p_pgm_id            => null,
           p_pl_id             => p_pl_table(l_cnt).pl_id,
           p_enrt_mthd_cd      => p_pl_table(l_cnt).enrt_mthd_cd,
           p_cls_enrt_flag     => FALSE,
           p_proc_cd           => l_proc_cd,
           p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => p_pl_table(l_cnt).max_enrt_esd );
        --
      end loop;
  end if;
  --
  --
  --
  if nvl(p_enrt_table.LAST, 0) > 0 then
     --
     -- Reinstate the ledgers if any created.
     --
     reinstate_bpl_per_pen(
         p_person_id              => p_person_id
         ,p_business_group_id      => p_business_group_id
         ,p_effective_date         => p_effective_date
         ,p_per_in_ler_id          => p_per_in_ler_id
         ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
         );
     --
     for l_cnt in 1..p_enrt_table.LAST loop
       --
       -- Reinstate the enrollment beneficiary rows.
       --
       hr_utility.set_location('Enrt Date = ' ||
                                p_enrt_table(l_cnt).effective_start_date, 333);
hr_utility.set_location('Reinstate the enrollment beneficiary rows',13);
       reinstate_pbn_per_pen(
         p_person_id                => p_person_id
         ,p_bckdt_prtt_enrt_rslt_id
                                    => p_enrt_table(l_cnt).bckdt_prtt_enrt_rslt_id
         ,p_prtt_enrt_rslt_id       => p_enrt_table(l_cnt).prtt_enrt_rslt_id
         ,p_rslt_object_version_number => p_enrt_table(l_cnt).pen_ovn_number
         ,p_business_group_id        => p_business_group_id
         ,p_per_in_ler_id            => p_per_in_ler_id
         ,p_effective_date           => nvl(p_enrt_table(l_cnt).effective_start_date,
                                            g_sys_date)
         ,p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id
         );
       --
      --Bug 3709516 to reinstate participant PCP
        reinstate_ppr_per_pen(
           p_person_id                => p_person_id
          ,p_bckdt_prtt_enrt_rslt_id => p_enrt_table(l_cnt).bckdt_prtt_enrt_rslt_id
          ,p_prtt_enrt_rslt_id       => p_enrt_table(l_cnt).prtt_enrt_rslt_id
          ,p_business_group_id       => p_business_group_id
          ,p_elig_cvrd_dpnt_id       => NULL
          ,p_effective_date          =>  nvl(p_enrt_table(l_cnt).effective_start_date,
                                                   nvl(g_sys_date, p_effective_date) ) -- bug 5344392
          ,p_bckdt_elig_cvrd_dpnt_id => NULL
          );
       -- Reinstate the covered dependents.
       --
       reinstate_dpnts_per_pen(
               p_person_id                 => p_person_id
               ,p_bckdt_prtt_enrt_rslt_id  => p_enrt_table(l_cnt).bckdt_prtt_enrt_rslt_id
               ,p_prtt_enrt_rslt_id        => p_enrt_table(l_cnt).prtt_enrt_rslt_id
               ,p_pen_ovn_number           => p_enrt_table(l_cnt).pen_ovn_number
               ,p_old_pl_id                => p_enrt_table(l_cnt).old_pl_id
               ,p_new_pl_id                => p_enrt_table(l_cnt).new_pl_id
               ,p_old_oipl_id              => p_enrt_table(l_cnt).old_oipl_id
               ,p_new_oipl_id              => p_enrt_table(l_cnt).new_oipl_id
               ,p_old_pl_typ_id            => p_enrt_table(l_cnt).old_pl_typ_id
               ,p_new_pl_typ_id            => p_enrt_table(l_cnt).new_pl_typ_id
               ,p_pgm_id                   => p_enrt_table(l_cnt).pgm_id
               ,p_ler_id                   => p_enrt_table(l_cnt).ler_id
               ,p_elig_per_elctbl_chc_id   => p_enrt_table(l_cnt).elig_per_elctbl_chc_id
               ,p_business_group_id        => p_business_group_id
               ,p_effective_date           => nvl(p_enrt_table(l_cnt).effective_start_date,
                                                    p_effective_date)
               ,p_per_in_ler_id            => p_per_in_ler_id
               ,p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id
               ,p_dpnt_cvg_strt_dt_cd      => p_enrt_table(l_cnt).dpnt_cvg_strt_dt_cd
               ,p_dpnt_cvg_strt_dt_rl      => p_enrt_table(l_cnt).dpnt_cvg_strt_dt_rl
               ,p_enrt_cvg_strt_dt         => null
               );
        --
        -- Reinstate the enrollment certifications.
        --
        reinstate_pcs_per_pen(
               p_person_id                 => p_person_id
               ,p_bckdt_prtt_enrt_rslt_id  => p_enrt_table(l_cnt).bckdt_prtt_enrt_rslt_id
               ,p_prtt_enrt_rslt_id        => p_enrt_table(l_cnt).prtt_enrt_rslt_id
               ,p_rslt_object_version_number => p_enrt_table(l_cnt).pen_ovn_number -- prtt_enrt_rslt_id
               ,p_business_group_id        => p_business_group_id
               ,p_prtt_enrt_actn_id        => null
               ,p_effective_date           => p_enrt_table(l_cnt).effective_start_date
               ,p_bckdt_prtt_enrt_actn_id  => null
               -- CFW
               ,p_per_in_ler_id            => p_per_in_ler_id
               ,p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id
               );
       --
       -- Reinstate the action items.
       --
       reinstate_pea_per_pen(
                 p_person_id                => p_person_id
                ,p_bckdt_prtt_enrt_rslt_id  => p_enrt_table(l_cnt).bckdt_prtt_enrt_rslt_id
                ,p_prtt_enrt_rslt_id        => p_enrt_table(l_cnt).prtt_enrt_rslt_id
                ,p_rslt_object_version_number => p_enrt_table(l_cnt).pen_ovn_number
                ,p_business_group_id        => p_business_group_id
                ,p_per_in_ler_id            => p_per_in_ler_id
                ,p_effective_date           => p_enrt_table(l_cnt).effective_start_date
                ,p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id
                );
     end loop;
  end if;
  --
end reinstate_post_enrt;
--
procedure reinstate_override(
                             p_pgm_table           in g_pgm_table
                            ,p_pl_table            in g_pl_table
                            ,p_enrt_table      in out nocopy g_enrt_table
                            ,p_max_enrt_esd        in date
                            ,p_person_id           in number
                            ,p_business_group_id   in number
                            ,p_effective_date      in date
                            ,p_per_in_ler_id       in number
                            ,p_bckdt_per_in_ler_id in number
                            ,p_cls_enrt_flag       in boolean default false
    ) is
    --
    l_proc                  varchar2(72) := g_package||'.reinstate_override';
    --
    cursor c_pel(c_per_in_ler_id in number,
                 c_pgm_id           number,
                 c_pl_id            number ) is
    select pel.pil_elctbl_chc_popl_id,
           pel.pgm_id,
           pel.pl_id,
           pel.reinstate_cd,
           pel.reinstate_ovrdn_cd,
           pel.enrt_perd_strt_dt
    from   ben_pil_elctbl_chc_popl pel
    where  pel.per_in_ler_id = c_per_in_ler_id
      and  ((pel.pgm_id = c_pgm_id and
             pel.pl_id is null ) or
            (pel.pl_id = c_pl_id and
             pel.pgm_id is null ));
    --
    l_pel     c_pel%rowtype;
    --
    cursor c_ovridn_rt(v_bckdt_pen_id number
                      ,v_new_pen_id   number ) is
    select prv2.prtt_rt_val_id new_prv_id,
           prv2.object_version_number new_prv_ovn,
           prv1.*
      from ben_prtt_rt_val prv1, --backed out
           ben_prtt_rt_val prv2  --current
     where prv1.prtt_enrt_rslt_id = v_bckdt_pen_id
       and prv2.prtt_enrt_rslt_id = v_new_pen_id
       and prv1.acty_base_rt_id = prv2.acty_base_rt_id
       and prv1.rt_ovridn_flag = 'Y'
       and nvl(prv1.rt_ovridn_thru_dt,hr_api.g_eot) >= prv2.rt_strt_dt -- Bug 4384574
       and prv1.prtt_rt_val_stat_cd = 'BCKDT'
       and prv2.prtt_rt_val_stat_cd is null
       and prv2.per_in_ler_id = p_per_in_ler_id
       and prv1.per_in_ler_id = p_bckdt_per_in_ler_id ;
  --
    cursor c_ovridn_dpnt(v_bckdt_pen_id number
                        ,v_new_pen_id   number
                        ,v_effective_date date) is
    select pdp2.elig_cvrd_dpnt_id new_pdp_id,
           pdp2.object_version_number new_pdp_ovn,
           pdp1.*
      from ben_elig_cvrd_dpnt_f pdp1,
           ben_elig_cvrd_dpnt_f pdp2
     where pdp1.prtt_enrt_rslt_id = v_bckdt_pen_id
       and pdp2.prtt_enrt_rslt_id = v_new_pen_id
       and pdp1.dpnt_person_id = pdp2.dpnt_person_id
       and pdp1.ovrdn_flag = 'Y'
       and v_effective_date between pdp1.effective_start_date
                                and pdp1.effective_end_date
       and v_effective_date between pdp2.effective_start_date
                              and pdp2.effective_end_date;
    --
    cursor c_ovn(v_prtt_enrt_rslt_id number) is
    select object_version_number
      from ben_prtt_enrt_rslt_f
     where prtt_enrt_rslt_id = v_prtt_enrt_rslt_id
       and effective_end_date = hr_api.g_eot;
    --
    cursor c_epe_enrt_rt(v_elig_per_elctbl_chc_id number,
                         v_acty_base_rt_id number) is
    select ecr.elig_per_elctbl_chc_id
      from ben_enrt_rt ecr
     where ecr.elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id
       and ecr.acty_base_rt_id        = v_acty_base_rt_id ;
    --
    cursor c_enb_enrt_rt(v_elig_per_elctbl_chc_id number,
                         v_acty_base_rt_id number) is
    select ecr.enrt_bnft_id
      from ben_enrt_rt ecr,
           ben_enrt_bnft enb
     where enb.elig_per_elctbl_chc_id = v_elig_per_elctbl_chc_id
       and enb.ordr_num > 0  --9999 Need to check this
       and ecr.enrt_bnft_id           = enb.enrt_bnft_id
       and ecr.acty_base_rt_id        = v_acty_base_rt_id ;
    --
    cursor c_flx_pen(c_person_id number,c_per_in_ler_id number,c_effective_date date ) is
       select pen.prtt_enrt_rslt_id,pen.pgm_id,pen.pl_id
       from   ben_prtt_enrt_rslt_f pen,
              ben_pl_f pln
       where  pen.person_id           = c_person_id
         and  pen.per_in_ler_id       = c_per_in_ler_id
         and  pen.pl_id               = pln.pl_id
         and  pln.invk_flx_cr_pl_flag = 'Y'
         and  c_effective_date between pen.effective_start_date
                                   and pen.effective_end_date
         and  c_effective_date between pln.effective_start_date
                                   and pln.effective_end_date;
    --
    cursor c_flx_pgm(c_pgm_id number,c_effective_date date ) is
            select decode(pgm_typ_cd,'COBRAFLX','Y',
                                     'FLEX','Y',
                                     'FPC','Y','N') pgm_typ_cd
            from  ben_pgm_f pgm
            where pgm.pgm_id  = c_pgm_id
              and c_effective_date between pgm.effective_start_date
                                       and pgm.effective_end_date ;
    --
    cursor c_abp(c_acty_base_rt_id number,c_pgm_id number,c_effective_date date ) is
        select bpp.bnft_prvdr_pool_id
        from
               ben_aplcn_to_bnft_pool_f abp,
               ben_bnft_prvdr_pool_f bpp
        where
               abp.acty_base_rt_id    = c_acty_base_rt_id
        and    abp.bnft_prvdr_pool_id = bpp.bnft_prvdr_pool_id
        and    bpp.pgm_id             = c_pgm_id
        and    c_effective_date between abp.effective_start_date
                                   and abp.effective_end_date
        and    c_effective_date between bpp.effective_start_date
                                   and bpp.effective_end_date ;
    --
    cursor c_flex_epe(c_per_in_ler_id number,c_pgm_id number, c_pl_id number)  is
        select elig_per_elctbl_chc_id
          from ben_elig_per_elctbl_chc epe
         where epe.per_in_ler_id = c_per_in_ler_id
           and epe.pl_id = c_pl_id
           and epe.pgm_id = c_pgm_id ;
    --
    l_flex_elig_per_elctbl_chc_id NUMBER;
    l_proc_cd                     varchar2(30);
    l_procd_dt                    date;
    l_strtd_dt                    date;
    l_voidd_dt                    date;
    l_esd_out                     date;
    l_eed_out                     date;
    l_ovn                         number(15);
    l_bckdt_epe_id                number(15);
    l_elig_per_elctbl_chc_id      number(15);
    l_bckdt_enrt_bnft_id          number(15);
    l_enrt_bnft_id                number(15);
    l_pgm_id                      number(15) := -1;
    l_pl_id                       number(15) := -1;
    l_reinstate_cd                varchar2(30);
    l_reinstate_ovrdn_cd          varchar2(30);
    l_enb_ecr_differ              varchar2(30) := 'N';
    l_epe_ecr_differ              varchar2(30) := 'N';
    l_override                    varchar2(30) := 'Y';
    l_flex_program_flag           varchar2(30) := 'N';
    l_flex_prtt_enrt_rslt_id      number ;
    l_flex_pgm_id                 number ;
    l_flex_pl_id                  number ;
    l_bnft_prvdr_pool_id          number ;
    l_bnft_prvdd_ldgr_id          number ;
    l_bpl_used_val                number ;
    --
    l_acty_ref_perd_cd            varchar2(80);
    l_acty_base_rt_id             number;
    l_rt_strt_dt                  date;
    l_rt_val                      number;
    l_element_type_id             number ;
    l_sh_prtt_rt_val_id           number := null;
    l_rate_flex_ovrrd_exists      varchar2(30):= 'N';
    --
  begin
    --
    hr_utility.set_location ('Entering '||l_proc,10);
  -- If any of the backed out enrt rslts were overriden, then update the new
  -- rslts with the overriden data.
  --
  if nvl(p_enrt_table.last, 0) > 0 then
    --
    for i in 1..p_enrt_table.last loop
      --
      l_elig_per_elctbl_chc_id := p_enrt_table(i).elig_per_elctbl_chc_id;
      --
      l_bckdt_epe_id := get_epe(p_per_in_ler_id  => p_bckdt_per_in_ler_id
                               ,p_pgm_id         => p_enrt_table(i).pgm_id
                               ,p_pl_id          => p_enrt_table(i).old_pl_id
                               ,p_oipl_id        => p_enrt_table(i).old_oipl_id
                               );
      --
      hr_utility.set_location('p_per_in_ler_id '||p_per_in_ler_id,178);
      hr_utility.set_location('p_enrt_table(i).pgm_id '||p_enrt_table(i).pgm_id,178);
      hr_utility.set_location('p_enrt_table(i).new_pl_id '||p_enrt_table(i).new_pl_id,178);
      hr_utility.set_location('l_pgm_id '||l_pgm_id,178);
      hr_utility.set_location('l_pl_id '||l_pl_id,178);
      --
      if l_pgm_id <> nvl(p_enrt_table(i).pgm_id,l_pgm_id) or
         l_pl_id  <> nvl(p_enrt_table(i).new_pl_id,l_pl_id)
      then
        --
        open c_pel(p_per_in_ler_id,p_enrt_table(i).pgm_id,p_enrt_table(i).new_pl_id);
        fetch c_pel into l_pel;
          --
          l_pgm_id := l_pel.pgm_id; -- p_enrt_table(i).pgm_id ;
          l_pl_id  := l_pel.pl_id; -- p_enrt_table(i).new_pl_id ;
          l_reinstate_cd := l_pel.reinstate_cd;
          l_reinstate_ovrdn_cd := l_pel.reinstate_ovrdn_cd;
          --
          hr_utility.set_location('l_pgm_id '||l_pgm_id,168);
          hr_utility.set_location('l_pl_id '||l_pl_id,168);
          --
        close c_pel;
        --
      end if;
      --
      --Check if the program is a flex credits one.
      --
      --hr_utility.set_location('l_pl_id '||l_pl_id,199);
      --hr_utility.set_location('p_enrt_table(i).new_pl_id '||p_enrt_table(i).new_pl_id,199);
      --hr_utility.set_location('p_enrt_table(i).pgm_id '||p_enrt_table(i).pgm_id,199);
      --hr_utility.set_location('l_pgm_id '||l_pgm_id,199);
      --hr_utility.set_location('p_enrt_table(i).g_sys_date '||p_enrt_table(i).g_sys_date,199);
      --
      open c_flx_pgm(p_enrt_table(i).pgm_id,p_enrt_table(i).g_sys_date );
        fetch c_flx_pgm into l_flex_program_flag ;
      close c_flx_pgm ;
      --
      if l_flex_program_flag = 'Y' then
        --
        open c_flx_pen(p_person_id,p_per_in_ler_id,p_enrt_table(i).g_sys_date );
        fetch c_flx_pen into l_flex_prtt_enrt_rslt_id,l_flex_pgm_id,l_flex_pl_id;
        close c_flx_pen;
        --
      end if;
      --
      if p_enrt_table(i).bckdt_enrt_ovridn_flag = 'Y' then
        --
        hr_utility.set_location('Restoring the overriden result: ' ||
                                p_enrt_table(i).bckdt_prtt_enrt_rslt_id, 72);
        -- 9999Why we are not updating the override thru date  and
        -- and all other information on pen record which can be overriden ?
        -- Get the latest object version number as the post enrollment process
        -- may have updated the new enrt result.
        --
        open c_ovn(p_enrt_table(i).prtt_enrt_rslt_id);
        fetch c_ovn into l_ovn;
        close c_ovn;
        --
        ben_prtt_enrt_result_api.update_prtt_enrt_result
          (p_prtt_enrt_rslt_id      => p_enrt_table(i).prtt_enrt_rslt_id
          ,p_effective_start_date   => l_esd_out
          ,p_effective_end_date     => l_eed_out
          ,p_enrt_cvg_strt_dt       => p_enrt_table(i).bckdt_enrt_cvg_strt_dt
          ,p_enrt_cvg_thru_dt       => p_enrt_table(i).bckdt_enrt_cvg_thru_dt
          ,p_enrt_ovrid_thru_dt       => p_enrt_table(i).enrt_ovrid_thru_dt
          ,p_enrt_ovrid_rsn_cd        => p_enrt_table(i).enrt_ovrid_rsn_cd
          ,p_enrt_ovridn_flag       => 'Y'
          ,p_object_version_number  => l_ovn
          ,p_effective_date         => p_enrt_table(i).g_sys_date
          ,p_datetrack_mode         => hr_api.g_correction
          ,p_multi_row_validate     => FALSE);
        --
      end if;
      --
      -- Check if any of the rates have been overriden and update the new
      -- rates with the overriden values.
      -- Bug 2677804 changed the cursor
      -- We need to see the overriden thru date also.
      --
      l_override := 'Y';
      --
      for l_rt_rec in c_ovridn_rt(p_enrt_table(i).bckdt_prtt_enrt_rslt_id
                                 ,p_enrt_table(i).prtt_enrt_rslt_id )
      loop
        --
        hr_utility.set_location('Updating new prv: ' || l_rt_rec.new_prv_id ||
                                ' with overriden prv_id: ' || l_rt_rec.prtt_rt_val_id, 72);
        --
        if l_reinstate_cd = 'VALIDATE_RESULT' and
           l_reinstate_ovrdn_cd = 'OVERRIDE_IF_NO_CHANGE' then
          open c_epe_enrt_rt(l_elig_per_elctbl_chc_id,l_rt_rec.acty_base_rt_id);
            fetch c_epe_enrt_rt into l_elig_per_elctbl_chc_id ;
          close c_epe_enrt_rt ;
          --
          open c_epe_enrt_rt(l_bckdt_epe_id,l_rt_rec.acty_base_rt_id);
            fetch c_epe_enrt_rt into l_bckdt_epe_id ;
          close c_epe_enrt_rt ;
          --
          if l_elig_per_elctbl_chc_id IS NOT NULL and
             l_bckdt_epe_id           IS NOT NULL then
            --
             l_epe_ecr_differ := comp_ori_new_epe_ecr(
                 p_person_id              => p_person_id
                ,p_business_group_id      => p_business_group_id
                ,p_effective_date         => p_effective_date
                ,p_per_in_ler_id          => p_per_in_ler_id
                ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
                ,p_curr_epe_id            => l_elig_per_elctbl_chc_id
                ,p_bckdt_epe_id           => l_bckdt_epe_id
                );
            --
            hr_utility.set_location('l_epe_ecr_differ '||l_epe_ecr_differ,20);
            if l_epe_ecr_differ = 'Y' then
              l_override := 'N';
            end if;
            --
          else
            --
            open c_enb_enrt_rt(l_elig_per_elctbl_chc_id,l_rt_rec.acty_base_rt_id);
              fetch c_enb_enrt_rt into l_enrt_bnft_id ;
            close c_enb_enrt_rt ;
            --
            open c_enb_enrt_rt(l_bckdt_epe_id,l_rt_rec.acty_base_rt_id);
              fetch c_enb_enrt_rt into l_bckdt_enrt_bnft_id ;
            close c_enb_enrt_rt ;
            --
            if l_enrt_bnft_id IS NOT NULL and
               l_bckdt_enrt_bnft_id IS NOT NULL then
              --
              l_enb_ecr_differ := comp_ori_new_enb_ecr(
                p_person_id              => p_person_id
                ,p_business_group_id     => p_business_group_id
                ,p_effective_date        => p_effective_date
                ,p_per_in_ler_id         => p_per_in_ler_id
                ,p_bckdt_per_in_ler_id   => p_bckdt_per_in_ler_id
                ,p_curr_enb_id           => l_enrt_bnft_id
                ,p_bckdt_enb_id          => l_bckdt_enrt_bnft_id
                );
              --
              hr_utility.set_location('l_enb_ecr_differ '||l_enb_ecr_differ,20);
              --
              if l_enb_ecr_differ = 'Y' then
                l_override := 'N';
              end if;
            end if;
            --
          end if;
          --
        end if;
        --
        hr_utility.set_location(' l_override '||l_override,199);
        --
        if l_override = 'Y' then
          --
          l_rate_flex_ovrrd_exists := 'Y';
          --
          ben_prtt_rt_val_api.update_prtt_rt_val
            (p_prtt_rt_val_id        => l_rt_rec.new_prv_id
            ,p_person_id             => p_person_id
            ,p_rt_strt_dt            => l_rt_rec.rt_strt_dt
            ,p_rt_val                => l_rt_rec.rt_val
            ,p_acty_ref_perd_cd      => l_rt_rec.acty_ref_perd_cd
            ,p_cmcd_rt_val           => l_rt_rec.cmcd_rt_val
            ,p_cmcd_ref_perd_cd      => l_rt_rec.cmcd_ref_perd_cd
            ,p_ann_rt_val            => l_rt_rec.ann_rt_val
            ,p_rt_ovridn_flag        => l_rt_rec.rt_ovridn_flag
            ,p_rt_ovridn_thru_dt     => l_rt_rec.rt_ovridn_thru_dt
            ,p_business_group_id     => p_business_group_id
            ,p_object_version_number => l_rt_rec.new_prv_ovn
            ,p_effective_date        => p_enrt_table(i).g_sys_date);
          --
          --Call Override Routines for flex credits
          --Bug 4384574 we need to handle the ledger entries also when the rates are
          --overriden
          hr_utility.set_location(' l_flex_program_flag '||l_flex_program_flag,199);
          hr_utility.set_location(' l_flex_prtt_enrt_rslt_id '||l_flex_prtt_enrt_rslt_id,199);
          --
          if l_flex_program_flag = 'Y' and l_flex_prtt_enrt_rslt_id is not null then
            --
            open c_abp(l_rt_rec.acty_base_rt_id,p_enrt_table(i).pgm_id,p_enrt_table(i).g_sys_date) ;
              fetch c_abp into l_bnft_prvdr_pool_id ;
              hr_utility.set_location(' l_bnft_prvdr_pool_id '||l_bnft_prvdr_pool_id,199);
              --
              if c_abp%found then
                --
                ben_manage_override.override_debit_ledger_entry
                 (p_validate                => false
                 ,p_calculate_only_mode     => false
                 ,p_person_id               => p_person_id
                 ,p_per_in_ler_id           => p_per_in_ler_id
                 ,p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id
                 ,p_prtt_enrt_rslt_id       => l_flex_prtt_enrt_rslt_id
                 ,p_decr_bnft_prvdr_pool_id => l_bnft_prvdr_pool_id
                 ,p_acty_base_rt_id         => l_rt_rec.acty_base_rt_id
                 ,p_prtt_rt_val_id          => l_rt_rec.new_prv_id
                 ,p_enrt_mthd_cd            => 'O'
                 ,p_val                     => l_rt_rec.rt_val
                 ,p_bnft_prvdd_ldgr_id      => l_bnft_prvdd_ldgr_id -- in out number
                 ,p_business_group_id       => p_business_group_id
                 ,p_effective_date          => p_enrt_table(i).g_sys_date
                 ,p_bpl_used_val            => l_bpl_used_val --    out number
                 );
                --
              end if;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
      -- Check if there are any dependents that are overriden and update the new
      -- elig_cvrd_dpnt records with the overriden values.
      --
      for l_dpnt_rec in c_ovridn_dpnt(p_enrt_table(i).bckdt_prtt_enrt_rslt_id
                                     ,p_enrt_table(i).prtt_enrt_rslt_id
                                     ,p_enrt_table(i).g_sys_date)
      loop
        --
        hr_utility.set_location('Updating new ecd with overriden ecd_id: ' ||
                                l_dpnt_rec.elig_cvrd_dpnt_id, 72);
        --
        ben_elig_cvrd_dpnt_api.update_elig_cvrd_dpnt
          (p_elig_cvrd_dpnt_id     => l_dpnt_rec.new_pdp_id
          ,p_effective_start_date  => l_esd_out
          ,p_effective_end_date    => l_eed_out
          ,p_cvg_strt_dt           => l_dpnt_rec.cvg_strt_dt
          ,p_cvg_thru_dt           => l_dpnt_rec.cvg_thru_dt
          ,p_ovrdn_flag            => l_dpnt_rec.ovrdn_flag
          ,p_ovrdn_thru_dt         => l_dpnt_rec.ovrdn_thru_dt
          ,p_object_version_number => l_dpnt_rec.new_pdp_ovn
          ,p_datetrack_mode        => hr_api.g_correction
          ,p_effective_date        => p_enrt_table(i).g_sys_date);
        --
      end loop;
      --
    end loop;
    --
    --program level changes for override flex credits
    --Need to process only when there is atleast one rate override happened
    l_pgm_id := -1;
    --
    if l_rate_flex_ovrrd_exists = 'Y' and nvl(p_pgm_table.LAST, 0) > 0 then
      for l_cnt in 1..p_pgm_table.LAST loop
        --
        hr_utility.set_location('p_pgm_table(l_cnt).pgm_id '||p_pgm_table(l_cnt).pgm_id,166);
        hr_utility.set_location('p_pgm_table(l_cnt).max_enrt_esd '||p_pgm_table(l_cnt).max_enrt_esd,166);
        --
        l_flex_prtt_enrt_rslt_id:= null;
        l_flex_elig_per_elctbl_chc_id:=null;
        l_flex_pgm_id:=null;
        l_flex_pl_id:=null;
        --
        if l_pgm_id <> p_pgm_table(l_cnt).pgm_id then
          --
          l_pgm_id := p_pgm_table(l_cnt).pgm_id ;
          --
          open c_flx_pgm(l_pgm_id,p_pgm_table(l_cnt).max_enrt_esd );
            fetch c_flx_pgm into l_flex_program_flag ;
          close c_flx_pgm ;
          --
          if l_flex_program_flag = 'Y' then
            --
            open c_flx_pen(p_person_id,p_per_in_ler_id,p_pgm_table(l_cnt).max_enrt_esd);
            fetch c_flx_pen into l_flex_prtt_enrt_rslt_id,l_flex_pgm_id,l_flex_pl_id;
            close c_flx_pen;
            --
            open c_flex_epe(p_per_in_ler_id,l_flex_pgm_id, l_flex_pl_id) ;
            fetch c_flex_epe into l_flex_elig_per_elctbl_chc_id ;
            close c_flex_epe ;
            --
          end if;
           --
           --
           if l_flex_elig_per_elctbl_chc_id is not null and
              l_flex_prtt_enrt_rslt_id is not null then
             ben_provider_pools.accumulate_pools
               (p_validate               => false
               ,p_person_id              => p_person_id
               ,p_elig_per_elctbl_chc_id => l_flex_elig_per_elctbl_chc_id
               ,p_business_group_id      => p_business_group_id
               ,p_enrt_mthd_cd           => 'O'
               ,p_effective_date         => p_pgm_table(l_cnt).max_enrt_esd
              );
             --
             ben_provider_pools.cleanup_invalid_ledger_entries(
                p_validate           => false
               ,p_person_id          => p_person_id
               ,p_per_in_ler_id      => p_per_in_ler_id
               ,p_effective_date     => p_pgm_table(l_cnt).max_enrt_esd
               ,p_business_group_id  => p_business_group_id
               );
             --
             -- To compute the balance entries and get the prv for flex shell plan.
             --
             ben_provider_pools.total_pools
                    (p_validate          => FALSE
                     ,p_prtt_enrt_rslt_id => l_flex_prtt_enrt_rslt_id
                     ,p_prtt_rt_val_id    => l_sh_prtt_rt_val_id --dummy
                     ,p_acty_ref_perd_cd  => l_acty_ref_perd_cd --dummy
                     ,p_acty_base_rt_id   => l_acty_base_rt_id --dummy
                     ,p_rt_strt_dt        => l_rt_strt_dt --dummy
                     ,p_rt_val            => l_rt_val --dummy
                     ,p_element_type_id   => l_element_type_id --dummy
                     ,p_person_id         => p_person_id
                     ,p_per_in_ler_id     => p_per_in_ler_id
                     ,p_enrt_mthd_cd      => 'O'
                     ,p_effective_date    => p_pgm_table(l_cnt).max_enrt_esd
                     ,p_business_group_id => p_business_group_id
                     ,p_pgm_id            => l_pgm_id
                     );
           end if;
        end if;
        --
      end loop;
    end if;
    --
  end if;
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
end reinstate_override;
-- ----------------------------------------------------------------------------
-- |------------------------< p_lf_evt_clps_restore_new >-------------------------|
-- ----------------------------------------------------------------------------
procedure p_lf_evt_clps_restore(
                           p_validate               in boolean default false
                          ,p_person_id              in number
                          ,p_business_group_id      in number
                          ,p_effective_date         in date
                          ,p_per_in_ler_id          in number
                          ,p_bckdt_per_in_ler_id    in number
                          ) is
  --
  cursor c_pel(p_per_in_ler_id in number) is
    select pel.pil_elctbl_chc_popl_id,
           pel.pgm_id,
           pel.pl_id,
           pel.reinstate_cd,
           pel.reinstate_ovrdn_cd,
           pel.enrt_perd_strt_dt
    from   ben_pil_elctbl_chc_popl pel
    where  pel.per_in_ler_id = p_per_in_ler_id;
  --
  cursor c_multiple_rate is
    select null
    from   ben_le_clsn_n_rstr
    where  BKUP_TBL_TYP_CD = 'MULTIPLE_RATE'
    and    per_in_ler_id  = p_bckdt_per_in_ler_id;
  --
  cursor c_bckdt_pil is
    select ler.name, pil.PRVS_STAT_CD, pil.object_version_number, pil.BCKT_PER_IN_LER_ID
    from ben_per_in_ler pil,
         ben_ler_f ler
    where pil.per_in_ler_id = p_bckdt_per_in_ler_id
      and ler.ler_id = pil.ler_id
      and p_effective_date between ler.effective_start_date
                               and ler.effective_end_date ;

-----------------------------------------------------------------------------------
  l_pl_typ_id number;
  l_prev_pil_id number;
  l_def_plus_reinsate_flag varchar2(1) default 'N';

cursor c_pl_typ_id(c_pl_id number) is
  select pl_typ_id from
         ben_pl_f
   where pl_id = c_pl_id
   and p_effective_date between effective_start_date
                     and effective_end_date ;


cursor c_exp_enrt_exists(c_per_in_ler_id number,c_pgm_id number,c_pl_typ_id number) is
  select 'Y' from
      ben_prtt_enrt_rslt_f pen
  where pen.per_in_ler_id = c_per_in_ler_id
  and   nvl(pen.pgm_id,-1) = nvl(c_pgm_id,-1)
  and   pen.pl_typ_id = c_pl_typ_id
  and   pen.enrt_mthd_cd = 'E'
  and   pen.prtt_enrt_rslt_stat_cd is null
  and   pen.enrt_cvg_thru_dt = hr_api.g_eot
  and   pen.enrt_cvg_thru_dt >= pen.enrt_cvg_strt_dt ;

cursor c_chk_exp_inter_pil is
    select 'Y'
    from   ben_prtt_enrt_rslt_f pen,
           ben_ler_f ler
    where  pen.per_in_ler_id not in (p_per_in_ler_id,p_bckdt_per_in_ler_id)
    and    pen.person_id           = p_person_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.enrt_cvg_thru_dt = hr_api.g_eot
    and    pen.effective_end_date = hr_api.g_eot
    and    pen.ler_id = ler.ler_id
    and    p_effective_date between ler.effective_start_date and
                                    ler.effective_end_date
    and    ler.typ_cd not in  ('IREC','SCHEDDU', 'COMP', 'GSP', 'ABS')
    and  pen.per_in_ler_id= l_prev_pil_id
    and  pen.enrt_mthd_cd = 'E'
    and exists
        (select 'Y' from ben_elig_per_elctbl_chc epe1
                    where epe1.elctbl_flag = 'Y'
                          and epe1.per_in_ler_id = l_prev_pil_id)
    and rownum =  1 ;

 l_int_pil_id number;

 cursor c_int_pil_id is
  select bckt_per_in_ler_id
        from ben_per_in_ler pil
	where pil.per_in_ler_id = p_bckdt_per_in_ler_id;

 cursor c_chk_intevent_bckdt(c_pil_id number) is
  select 'Y'
        from ben_per_in_ler pil
	where pil.per_in_ler_id = c_pil_id
	      and pil.per_in_ler_stat_cd in('BCKDT', 'VOIDD');

cursor c_future_pil is
       select pil.per_in_ler_id
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.per_in_ler_id not in (p_per_in_ler_id,p_bckdt_per_in_ler_id)
    and    pil.person_id     = p_person_id
    and    pil.ler_id        = ler.ler_id
    and    p_effective_date between
           ler.effective_start_date and ler.effective_end_date
    and    ler.typ_cd not in ('IREC', 'SCHEDDU', 'COMP', 'GSP', 'ABS')
    and    pil.per_in_ler_stat_cd not in('BCKDT', 'VOIDD')
    and    pil.lf_evt_ocrd_dt in (select lf_evt_ocrd_dt
				 from ben_per_in_ler pil2,
				      ben_ler_f ler1
				 where pil2.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
				    and pil2.person_id = p_person_id
				    and    pil2.ler_id        = ler1.ler_id
				    and    p_effective_date between
					   ler1.effective_start_date and ler1.effective_end_date
				    and    ler1.typ_cd not in ('IREC', 'SCHEDDU', 'COMP', 'GSP', 'ABS')
				    and pil2.lf_evt_ocrd_dt > (select lf_evt_ocrd_dt from ben_per_in_ler pil3 where
							      per_in_ler_id = l_int_pil_id)
				    and pil2.lf_evt_ocrd_dt < (select lf_evt_ocrd_dt from ben_per_in_ler pil3 where
							      per_in_ler_id = p_bckdt_per_in_ler_id)
                                )
   order by pil.lf_evt_ocrd_dt desc;

 cursor c_ler_id is
 select le.ler_id
        from ben_ler_f le,ben_per_in_ler pil
        where pil.ler_id=le.ler_id
	and p_effective_date between le.effective_start_date and le.effective_end_date
	and pil.per_in_ler_id = p_bckdt_per_in_ler_id;

 l_ler_id number;
 l_default varchar2(1) default 'N';
 l_reinstate_def varchar2(1) default 'N';
 l_def_applied varchar2(1) default 'N';

 l_env_obj ben_env_object.g_global_env_rec_type;


  --
  l_bckdt_pil              c_bckdt_pil%rowtype;
  l_dummy     varchar2(30) default 'N';
  --
  l_pel                     c_pel%rowtype;
  --
  l_proc                    varchar2(72) := g_package||'.p_lf_evt_clps_restore';
  l_chages_ocrd_flag        varchar2(30) := 'N';
  l_rslt_exist_flag         varchar2(30) := 'N';
  l_int_rslts_exist_flag    varchar2(30) := 'N';
  l_date                    date;
  l_resnd_cmnt_txt          fnd_new_messages.message_text%type;
  l_reinstate_cd            varchar2(30);
  l_reinstate_ovrdn_cd      varchar2(30);
  l_susp_flag               boolean ;
  l_batch_flag              boolean := FALSE ; ---99999 When called from benmngle batch it needs to be TRUE
  l_bckdt_pilepe_table      ben_reinstate_epe_cache.g_pilepe_inst_tbl;
  l_bckdt_pen_table         g_bckdt_pen_tbl;
  l_bckdt_pilepe_inst_row   ben_reinstate_epe_cache.g_pilepe_inst_row;
  l_bckdt_epe_count         number;
  l_pilepe_inst_row         ben_reinstate_epe_cache.g_pilepe_inst_row;
  --
  --To reinstate
  --
  l_valid_count             number;
  l_valid_pen_table         g_bckdt_pen_tbl;
  l_valid_epe_table         ben_reinstate_epe_cache.g_pilepe_inst_tbl;
  --
  --To report non-reinstating results info
  --
  l_invalid_pen_table       g_bckdt_pen_tbl;
  l_invalid_count           number;
  l_invalid_epe_table       ben_reinstate_epe_cache.g_pilepe_inst_tbl;
  --
  l_pgm_table               g_pgm_table;
  l_pl_table                g_pl_table;
  l_enrt_table              g_enrt_table;
  l_max_enrt_esd            date;
  l_max_enrt_esd_out        date;
  l_not_reinstate           number := 1 ;
  l_procd_dt                date;
  l_strtd_dt                date;
  l_voidd_dt                date;
  --
  l_status		    varchar2(1);
  l_industry		    varchar2(1);
  l_oracle_schema	    varchar2(30);
  --
  /*  -- commented against bug 7679297
  -- Bug 6328780
  cursor c_en_dtd_pen_bckdt_pil
    is
     SELECT pen_inner.bkup_tbl_id,
      pen_inner.effective_start_date,
      pen_inner.effective_end_date,
      pen_inner.enrt_cvg_strt_dt,
      pen_inner.enrt_cvg_thru_dt,
      pen_inner.object_version_number
   FROM ben_le_clsn_n_rstr pen_inner,
        ben_per_in_ler pil_inner
   WHERE pil_inner.per_in_ler_id = p_bckdt_per_in_ler_id
   AND pil_inner.person_id = p_person_id
   AND pil_inner.business_group_id = p_business_group_id
   AND pil_inner.per_in_ler_id = pen_inner.per_in_ler_id
   AND pen_inner.bkup_tbl_typ_cd = 'BEN_PRTT_ENRT_RSLT_F'
   AND ( (pen_inner.enrt_cvg_thru_dt IS NOT NULL and pen_inner.enrt_cvg_thru_dt <> hr_api.g_eot )
           and pen_inner.effective_end_date  = hr_api.g_eot
        )
   AND pen_inner.comp_lvl_cd NOT IN('PLANFC','PLANIMP');
  --
 l_en_dtd_pen_bckdt_pil c_en_dtd_pen_bckdt_pil%ROWTYPE;
 l_effective_start_date date;
 l_effective_end_date  date;
  --
 -- Bug 6328780

  cursor c_unres_per_in_ler
    is
	select 'x'
	from ben_ler_f ler, ben_per_in_ler pil
	where ler.ler_id = pil.ler_id
        and ler.business_group_id = pil.business_group_id
	and pil.per_in_ler_id = p_per_in_ler_id
        and pil.business_group_id = p_business_group_id
	and ler.typ_cd = 'SCHEDDU';

  l_unres_per_in_ler c_unres_per_in_ler%ROWTYPE;

  */
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  hr_utility.set_location('p_bckdt_per_in_ler_id '||p_bckdt_per_in_ler_id,30);
  --
  -- Remove it after complete test.
  --
  l_pgm_table.delete;
  l_pl_table.delete;
  l_enrt_table.delete;
  -- bug 4615207 : added GHR product installation chk -Multiple Rate chk to be performed only for GHR
  IF (fnd_installation.get_app_info('GHR',l_status, l_industry, l_oracle_schema)) THEN
   if l_status = 'I' then
    open c_multiple_rate;
    fetch c_multiple_rate into l_dummy;
    if c_multiple_rate%found then
     close c_multiple_rate;
      -- Multiple rate is found and no reinstate
      hr_utility.set_location ('Multiple rate found and no reinstate done',11);
      return;
    end if;
     close c_multiple_rate;
   end if;  --if l_status
  end if;
  --
  open c_bckdt_pil ;
    fetch c_bckdt_pil into l_bckdt_pil ;
  close c_bckdt_pil ;
  --
  --Check if there are Enrollment results for intervening life event
  --
  --Get the Reinstate Codes
  --LOOP THRU ALL PROGRAM AND PLANS NOT IN PROGRAMS IN PEL Table
  --
  --CASE 1 No Reinstate
  --   RETURN
  --CASE 2 If intervening LE exists
  --   PROCESS DEFAULTS
  --   RETURN
  --CASE 3 Complete Validate
  --   Existing functionality
  --CASE 4 Validate ONLY Backed out results
  --
  --CASE 5 enroll into backed out compensation objects
  --
  --END CASE
  --
  --END LOOP
  --
  l_int_rslts_exist_flag := ele_made_for_inter_pil(
                              p_per_in_ler_id        => p_per_in_ler_id,
                              p_bckdt_per_in_ler_id  => p_bckdt_per_in_ler_id,
                              p_person_id            => p_person_id,
                              p_business_group_id    => p_business_group_id,
                              p_effective_date       => p_effective_date
                              );
  --
  hr_utility.set_location ('l_int_rslts_exist_flag '||l_int_rslts_exist_flag,15);
  --
  l_invalid_count := 0;
  l_invalid_pen_table.delete;
  l_invalid_epe_table.delete;
  --
  for r_pel in c_pel(p_per_in_ler_id) loop
    --
    l_valid_count := 0;
    l_valid_pen_table.delete;
    l_valid_epe_table.delete;
    --
    hr_utility.set_location ('r_pel.pgm_id :'||r_pel.pgm_id,20);
    hr_utility.set_location ('r_pel.pl_id :'||r_pel.pl_id,20);
    hr_utility.set_location ('r_pel.reinstate_cd :'||r_pel.reinstate_cd,20);
    --
    if l_int_rslts_exist_flag = 'Y' then
       if r_pel.reinstate_cd = 'DONOT_REINSTATE' then
         --
         hr_utility.set_location('reinstate_cd '||r_pel.reinstate_cd,30);
         hr_utility.set_location('Leaving:'|| l_proc, 30);
         exit ;
         --

	/* Added for Enhancement Bug :8716679 */
        elsif  r_pel.reinstate_cd = 'VALIDATE_EXPLICIT_ENRT' then

	   hr_utility.set_location('reinstate_cd '||r_pel.reinstate_cd,30);
	   hr_utility.set_location('p_bckdt_per_in_ler_id '||p_bckdt_per_in_ler_id,30);
	   l_default := 'N';
	   l_reinstate_def := 'Y';

           /* Get the per_in_ler_id of the Intervening  LE*/
           open c_int_pil_id;
	   fetch c_int_pil_id into l_int_pil_id;
	   close c_int_pil_id;
	   hr_utility.set_location('l_int_pil_id '||l_int_pil_id,30);

           /* Get the latest processed per_in_ler_id of the intervening LE's */
           open c_future_pil;
	   fetch c_future_pil into l_prev_pil_id;
	   if(c_future_pil%notfound) then
	     hr_utility.set_location('cursor not foind ',30);
	     l_prev_pil_id := l_int_pil_id;
	   end if;
           close c_future_pil;
	   hr_utility.set_location('l_prev_pil_id '||l_prev_pil_id,30);



	      if(l_prev_pil_id <> l_int_pil_id) then
	        hr_utility.set_location('cond 1 ',30);
	        l_default := 'Y';
	     else
	       open c_chk_intevent_bckdt(l_int_pil_id);
	       fetch c_chk_intevent_bckdt into l_dummy;
	       if(c_chk_intevent_bckdt%notfound) then
	          close c_chk_intevent_bckdt;
	          hr_utility.set_location('cond 2 ',30);
	          l_default := 'Y';
	       else
	          close c_chk_intevent_bckdt;
	          hr_utility.set_location('cond 2 ',30);
	          l_default := 'N';
	       end if;
	     end if;


           if(l_default = 'Y') then

	      /*open c_prev_pil;
              fetch c_prev_pil into l_prev_pil_id;
              close c_prev_pil;*/

                     g_reinstated_defaults.delete;


                     /* Check explicit elections made for intervening LE*/
		     open c_chk_exp_inter_pil;
		     fetch c_chk_exp_inter_pil into l_dummy;
		     close c_chk_exp_inter_pil;
		     hr_utility.set_location('l_dummy value '||l_dummy,30);

		      open c_ler_id;
		      fetch c_ler_id into l_ler_id;
		      close c_ler_id;

                      if(l_dummy = 'Y') then

			      ben_env_object.get(l_env_obj);
                              hr_utility.set_location('Mode '||l_env_obj.mode_cd,30);

                              /* Carry Forward the suspended enrollments*/
			      ben_carry_forward_items.carry_farward_results(
				p_person_id           => p_person_id
			       ,p_per_in_ler_id       => p_per_in_ler_id
			       ,p_ler_id              => l_ler_id
			       ,p_business_group_id   => p_business_group_id
			       ,p_mode                => l_env_obj.mode_cd --'L'
			       ,p_effective_date      => p_effective_date
				);

		   /* Reinstating Defaults of Intervening lifevent elections.
		      Reinstate only if Explicit Enrollments exist for intervening LE*/

		              l_def_applied := 'Y';
			      default_comp_obj
					  (p_validate           => p_validate
					  ,p_per_in_ler_id      => p_per_in_ler_id
					  ,p_person_id          => p_person_id
					  ,p_business_group_id  => p_business_group_id
					  ,p_effective_date     => p_effective_date
					  ,p_pgm_id             => r_pel.pgm_id
					  ,p_pl_nip_id          => r_pel.pl_id
					  ,p_susp_flag          => l_susp_flag
					  ,p_batch_flag         => l_batch_flag
					  ,p_cls_enrt_flag      => FALSE
					  ,p_called_frm_ss      => FALSE
					  ,p_reinstate_dflts_flag => 'Y'
					  ,p_prev_per_in_ler_id => l_prev_pil_id
					 );
		      end if;
           end if;

	     /* Reinstate enrollments of backedout LifeEvent is no enrollments found for the plantype
	        in intervening lifevent and reinstating the enrollments of backeout LE which are
		explicitly elected and defaulted in intervening LE*/
		 l_rslt_exist_flag  := ele_made_for_bckdt_pil (
                           p_bckdt_per_in_ler_id     => p_bckdt_per_in_ler_id
                          ,p_person_id               => p_person_id
                          ,p_business_group_id       => p_business_group_id
                          ,p_effective_date          => p_effective_date
                          );
		      --
		      hr_utility.set_location('l_rslt_exist_flag '||l_rslt_exist_flag,140);
		      hr_utility.set_location('reinstate_cd '||r_pel.reinstate_cd,50);

		      get_backedout_results(
                             p_person_id              => p_person_id
                            ,p_pgm_id                 => r_pel.pgm_id
                            ,p_pl_id                  => r_pel.pl_id
                            ,p_effective_date         => p_effective_date
                            ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
                            ,p_pilepe_inst_table      => l_bckdt_pilepe_table
                            ,p_bckdt_pen_table        => l_bckdt_pen_table
                      );
                      l_bckdt_epe_count := l_bckdt_pilepe_table.COUNT;

		     /* Loop thru the backedout results*/
		     for l_bckdt_epe in 1..l_bckdt_epe_count loop

		             l_bckdt_pilepe_inst_row := l_bckdt_pilepe_table(l_bckdt_epe);
		             hr_utility.set_location(' Reinstate '||l_bckdt_pen_table(l_bckdt_epe).pgm_id
					      ||' PLN '||l_bckdt_pen_table(l_bckdt_epe).pl_id||' OIPL '
					      ||l_bckdt_pen_table(l_bckdt_epe).oipl_id,175);
			     ben_reinstate_epe_cache.get_pilcobjepe_dets(
					    p_per_in_ler_id => p_per_in_ler_id
					   ,p_pgm_id        => l_bckdt_pen_table(l_bckdt_epe).pgm_id
					   ,p_pl_id         => l_bckdt_pen_table(l_bckdt_epe).pl_id
					   ,p_oipl_id       => l_bckdt_pen_table(l_bckdt_epe).oipl_id
					   ,p_inst_row      => l_pilepe_inst_row
					    );

			    --if epe record found in the latest PIL then go ahead and compare the results
			    --otherwise go to next backedout epe.. but at the same time record the non-backed out
			    --epe records
			    if l_pilepe_inst_row.elig_per_elctbl_chc_id is not null then
			       hr_utility.set_location('l_pilepe_inst_row.pgm_id  '||l_pilepe_inst_row.pgm_id,117);
			       hr_utility.set_location('l_pilepe_inst_row.pl_typ_id  '||l_pilepe_inst_row.pl_typ_id,117);
			       hr_utility.set_location('l_pilepe_inst_row.epe_id  '||l_pilepe_inst_row.elig_per_elctbl_chc_id,117);

			       /*Added to the resintate if the enrollment is not either carry forwarded or defaulted*/
				if(g_reinstated_defaults.COUNT > 0
				   and check_pl_typ_defaulted(l_pilepe_inst_row.pl_typ_id,l_pilepe_inst_row.pgm_id) = 'Y' ) then
					 hr_utility.set_location('Plan Already Defaulted ',117);
					 hr_utility.set_location('Plan Not Added to Reinstate list  ',117);
					 l_invalid_count := l_invalid_count + 1 ;
					 l_invalid_epe_table(l_invalid_count) := l_pilepe_inst_row ;
					 l_invalid_pen_table(l_invalid_count) := l_bckdt_pen_table(l_bckdt_epe);
				else
				       hr_utility.set_location('Plan Added to Reinstate list ',117);
				       l_valid_count := l_valid_count + 1 ;
				       l_valid_epe_table(l_valid_count) := l_pilepe_inst_row ;
				       l_valid_pen_table(l_valid_count) := l_bckdt_pen_table(l_bckdt_epe);
				end if;
			       --
			    else
			      --
			      l_invalid_count := l_invalid_count + 1 ;
			      l_invalid_epe_table(l_invalid_count) := l_pilepe_inst_row ;
			      l_invalid_pen_table(l_invalid_count) := l_bckdt_pen_table(l_bckdt_epe);
			      --
			      hr_utility.set_location('NO EPE '||l_bckdt_pilepe_inst_row.elig_per_elctbl_chc_id,250);
			      --
			    end if ;
		    --
		  end loop;

                  /* Now call the reinstate logic*/
		  if l_valid_pen_table.COUNT > 0 and l_valid_epe_table.COUNT > 0 then
			hr_utility.set_location('Calling reinstate_prev_enrt_for_popl '
						   ||r_pel.pgm_id||' PLN '||r_pel.pl_id,300);
			--
			   l_def_plus_reinsate_flag := 'Y';
			   reinstate_prev_enrt_for_popl(
			     p_bckdt_pen_table          => l_valid_pen_table
			    ,p_epe_table                => l_valid_epe_table
			    ,p_pgm_table                => l_pgm_table
			    ,p_pl_table                 => l_pl_table
			    ,p_enrt_table               => l_enrt_table
			    ,p_person_id                => p_person_id
			    ,p_pgm_id                   => r_pel.pgm_id
			    ,p_pl_id                    => r_pel.pl_id
			    ,p_business_group_id        => p_business_group_id
			    ,p_effective_date           => p_effective_date
			    ,p_per_in_ler_id            => p_per_in_ler_id
			    ,p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id
			    ,p_enrt_perd_strt_dt        => r_pel.enrt_perd_strt_dt
			    ,p_max_enrt_esd             => l_max_enrt_esd_out
			);

			 if l_max_enrt_esd_out >= nvl(l_max_enrt_esd,l_max_enrt_esd_out) then
				l_max_enrt_esd := l_max_enrt_esd_out ;
		         end if;
                  end if;
		  hr_utility.set_location(' l_invalid_count '||l_invalid_count,260);
		  hr_utility.set_location(' l_valid_count '||l_valid_count,260);
		  /* End of enhancement bug 8716679*/

             else
			 --Call the default process for the program or plan not in program
			 hr_utility.set_location ('Before call to default_comp_obj '||l_proc,40);
			 --
			 if fnd_global.conc_request_id in (0,-1) then
			   --
			   l_batch_flag := FALSE ;
			   --
			 else
			   --
			   l_batch_flag := TRUE ;
			   --
			 end if;
			 --
			 default_comp_obj
				  (p_validate           => p_validate
				  ,p_per_in_ler_id      => p_per_in_ler_id
				  ,p_person_id          => p_person_id
				  ,p_business_group_id  => p_business_group_id
				  ,p_effective_date     => p_effective_date
				  ,p_pgm_id             => r_pel.pgm_id
				  ,p_pl_nip_id          => r_pel.pl_id
				  ,p_susp_flag          => l_susp_flag
				  ,p_batch_flag         => l_batch_flag
				  ,p_cls_enrt_flag      => FALSE
				  ,p_called_frm_ss      => FALSE
				 );
			 --
			 if fnd_global.conc_request_id in (0,-1) then
			   --if called from benauthe
			   g_bckdt_pil_restored_flag := 'Y';
			   g_bckdt_pil_restored_cd   := 'DEFAULT';
			   --
			 else
			   --if called from batch concurrent program
			   fnd_message.set_name('BEN','BEN_94226_APPLIED_DEFAULTS');
			   fnd_message.set_token('LER_NAME',l_bckdt_pil.name);
			   benutils.write(p_text => fnd_message.get);
			   --
			 end if;
         --
         hr_utility.set_location ('After call to default_comp_obj '||l_proc,40);
         --
       end if;
    else
      --Now see other reinstate codes and process accordingly.
      --
      l_rslt_exist_flag  := ele_made_for_bckdt_pil (
                           p_bckdt_per_in_ler_id     => p_bckdt_per_in_ler_id
                          ,p_person_id               => p_person_id
                          ,p_business_group_id       => p_business_group_id
                          ,p_effective_date          => p_effective_date
                          );
      --
      hr_utility.set_location('l_rslt_exist_flag '||l_rslt_exist_flag,140);

      hr_utility.set_location('reinstate_cd '||r_pel.reinstate_cd,50);
      --
      if r_pel.reinstate_cd = 'DONOT_REINSTATE' then
        --
        hr_utility.set_location('Leaving:'|| l_proc, 60);
        exit ;
        --
      elsif NVL(r_pel.reinstate_cd,'VALIDATE_ALL') = 'VALIDATE_ALL' then
        ---
        --This needs to be changed to validate for each program or plan not in program
        --
        hr_utility.set_location('Before call to l_chages_ocrd_flag',70);
        --
        l_chages_ocrd_flag := comp_ori_new_pil_for_popl(
                            p_person_id           => p_person_id
                           ,p_business_group_id   => p_business_group_id
                           ,p_ler_id              => null
                           ,p_effective_date      => p_effective_date
                           ,p_per_in_ler_id       => p_per_in_ler_id
                           ,p_bckdt_per_in_ler_id => p_bckdt_per_in_ler_id
                           ,p_pgm_id              => r_pel.pgm_id
                           ,p_pl_id               => r_pel.pl_id
                          );
        --
        hr_utility.set_location(' l_chages_ocrd_flag '||l_chages_ocrd_flag,80);
        --
        if l_chages_ocrd_flag = 'N' then
          --
          --Now Reinstate all the results
          --
          hr_utility.set_location('Before call to get_backedout_results ',90);
          --
          get_backedout_results(
                             p_person_id              => p_person_id
                            ,p_pgm_id                 => r_pel.pgm_id
                            ,p_pl_id                  => r_pel.pl_id
                            ,p_effective_date         => p_effective_date
                            ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
                            ,p_pilepe_inst_table      => l_bckdt_pilepe_table
                            ,p_bckdt_pen_table        => l_bckdt_pen_table
          );
          --
          hr_utility.set_location('After call to get_backedout_results ',90);
          --
          l_bckdt_epe_count := l_bckdt_pilepe_table.COUNT;
          hr_utility.set_location(' l_bckdt_epe_count '||l_bckdt_epe_count,90);
          --
          for l_bckdt_epe in 1..l_bckdt_epe_count loop
            --
            --Get the current per_in_ler info
            --
            l_bckdt_pilepe_inst_row := l_bckdt_pilepe_table(l_bckdt_epe);
            --
            hr_utility.set_location('Calling ben_reinstate_epe_cache.get_pilcobjepe_dets',100);
            hr_utility.set_location('pgm '||l_bckdt_pen_table(l_bckdt_epe).pgm_id,100);
            hr_utility.set_location('pln '||l_bckdt_pen_table(l_bckdt_epe).pl_id,100);
            hr_utility.set_location('oipl '||l_bckdt_pen_table(l_bckdt_epe).oipl_id,100);
            --
            ben_reinstate_epe_cache.get_pilcobjepe_dets(
                            p_per_in_ler_id => p_per_in_ler_id
                           ,p_pgm_id        => l_bckdt_pen_table(l_bckdt_epe).pgm_id
                           ,p_pl_id         => l_bckdt_pen_table(l_bckdt_epe).pl_id
                           ,p_oipl_id       => l_bckdt_pen_table(l_bckdt_epe).oipl_id
                           ,p_inst_row      => l_pilepe_inst_row
                            );
            --
            hr_utility.set_location('from l_pilepe_inst_row EPE'||
                                       l_pilepe_inst_row.elig_per_elctbl_chc_id,110);
            --
            if l_pilepe_inst_row.elig_per_elctbl_chc_id is not null then
               --Lucky Guy found a choice ... You are going be reinstated.
               --for l_pilepe_inst_row record
               l_valid_count := l_valid_count + 1 ;
               l_valid_epe_table(l_valid_count) := l_pilepe_inst_row ;
               l_valid_pen_table(l_valid_count) := l_bckdt_pen_table(l_bckdt_epe);
               --
            else
              --This should not happen as the records were already compared and there was a match for
              --all the backed out and current electable choices
              --
              l_invalid_count := l_invalid_count + 1 ;
              l_invalid_epe_table(l_invalid_count) := l_pilepe_inst_row ;
              l_invalid_pen_table(l_invalid_count) := l_bckdt_pen_table(l_bckdt_epe);
              --
            end if ;
            --
          end loop;
          --
          hr_utility.set_location('Valid results '||l_valid_count,120);
          hr_utility.set_location('Invalid results '||l_invalid_count,120);
          --
          --
        else
          --
          hr_utility.set_location('Not Reinstating - changes occured ' ,125);
          l_not_reinstate := 2 ;
          --
        end if;
        --
      else
        --Now get all the Backedout results and thier associated EPE records
        get_backedout_results(
                             p_person_id              => p_person_id
                            ,p_pgm_id                 => r_pel.pgm_id
                            ,p_pl_id                  => r_pel.pl_id
                            ,p_effective_date         => p_effective_date
                            ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
                            ,p_pilepe_inst_table      => l_bckdt_pilepe_table
                            ,p_bckdt_pen_table        => l_bckdt_pen_table
        );
        --
        hr_utility.set_location('Got get_backedout_results '||l_bckdt_pilepe_table.COUNT ,130);
        --
        l_bckdt_epe_count := l_bckdt_pilepe_table.COUNT;
        --
        if r_pel.reinstate_cd = 'VALIDATE_RESULT_ALL' then
          --In this routine compare all old and new Choice data and if it matches then reinstate else no
          --return
          --
          hr_utility.set_location('Entering VALIDATE_RESULT_ALL',140);
          --
          for l_bckdt_epe in 1..l_bckdt_epe_count loop
            --Get the current per_in_ler info
            --
            l_bckdt_pilepe_inst_row := l_bckdt_pilepe_table(l_bckdt_epe);
            --
            hr_utility.set_location(' Calling ben_reinstate_epe_cache.get_pilcobjepe_dets '||l_bckdt_pen_table(l_bckdt_epe).pgm_id
                                      ||' PLN '||l_bckdt_pen_table(l_bckdt_epe).pl_id||' OIPL '
                                      ||l_bckdt_pen_table(l_bckdt_epe).oipl_id,145);
            ben_reinstate_epe_cache.get_pilcobjepe_dets(
                            p_per_in_ler_id => p_per_in_ler_id
                           ,p_pgm_id        => l_bckdt_pen_table(l_bckdt_epe).pgm_id
                           ,p_pl_id         => l_bckdt_pen_table(l_bckdt_epe).pl_id
                           ,p_oipl_id       => l_bckdt_pen_table(l_bckdt_epe).oipl_id
                           ,p_inst_row      => l_pilepe_inst_row
                            );
            --
            --if epe record found in the latest PIL then go ahead and compare the results
            --otherwise go to next backedout epe.. but at the same time record the non-backed out
            --epe records
            if l_pilepe_inst_row.elig_per_elctbl_chc_id is not null then
              --Call compare process for backed out and new epe records
              l_chages_ocrd_flag :=  comp_ori_new_epe(
                            p_bckdt_epe_row        => l_bckdt_pilepe_inst_row
                           ,p_current_epe_row      => l_pilepe_inst_row
                           ,p_per_in_ler_id        => p_per_in_ler_id
                           ,p_bckdt_per_in_ler_id  => p_bckdt_per_in_ler_id
                           ,p_person_id            => p_person_id
                           ,p_business_group_id    => p_business_group_id
                           ,p_effective_date       => p_effective_date
                           );
              --
              hr_utility.set_location(' l_pilepe_inst_row.elig_per_elctbl_chc_id '||l_pilepe_inst_row.elig_per_elctbl_chc_id,150);
              hr_utility.set_location(' l_chages_ocrd_flag '||l_chages_ocrd_flag,150);
              --
              if l_chages_ocrd_flag = 'N' then
                --Lucky Guy No Changes... You are going be reinstated.
                --
                l_valid_count := l_valid_count + 1 ;
                l_valid_epe_table(l_valid_count) := l_pilepe_inst_row ;
                l_valid_pen_table(l_valid_count) := l_bckdt_pen_table(l_bckdt_epe);
                --
              else
                --Change occured for the choice. Dont reinstate
                l_invalid_count := l_invalid_count + 1 ;
                l_invalid_epe_table(l_invalid_count) := l_pilepe_inst_row ;
                l_invalid_pen_table(l_invalid_count) := l_bckdt_pen_table(l_bckdt_epe);
                --
              end if ;
              --
            else
              --Record the non copied epe records into a pl/sql table since
              --Reason NO EPE Available in current life event.
              l_invalid_count := l_invalid_count + 1 ;
              l_invalid_epe_table(l_invalid_count) := l_pilepe_inst_row ;
              l_invalid_pen_table(l_invalid_count) := l_bckdt_pen_table(l_bckdt_epe);
              --
              hr_utility.set_location('NO EPE '||l_bckdt_pilepe_inst_row.elig_per_elctbl_chc_id,160);
              --
            end if;
            --
          end loop;
          --
          hr_utility.set_location(' l_invalid_count '||l_invalid_count,160);
          hr_utility.set_location(' l_valid_count '||l_valid_count,160);
          --
        elsif r_pel.reinstate_cd = 'VALIDATE_RESULT' or r_pel.reinstate_cd = 'VALIDATE_EXPLICIT_ENRT' then
          --If you get a hit for EPE ENB ECR in the NEW PIL then enroll in the new EPE ENB ECR
          --
          hr_utility.set_location('Entering '||r_pel.reinstate_cd,170);

          /* Added for Enhancement Bug 8716679*/
	  if(r_pel.reinstate_cd = 'VALIDATE_EXPLICIT_ENRT') then
	   if( call_defaults(p_per_in_ler_id,p_bckdt_per_in_ler_id,p_effective_date,p_person_id) = 'Y' ) then
	       hr_utility.set_location(' Calling defaults second part '||r_pel.reinstate_cd,1999);
	       default_comp_obj
		  (p_validate           => p_validate
		  ,p_per_in_ler_id      => p_per_in_ler_id
		  ,p_person_id          => p_person_id
		  ,p_business_group_id  => p_business_group_id
		  ,p_effective_date     => p_effective_date
		  ,p_pgm_id             => r_pel.pgm_id
		  ,p_pl_nip_id          => r_pel.pl_id
		  ,p_susp_flag          => l_susp_flag
		  ,p_batch_flag         => l_batch_flag
		  ,p_cls_enrt_flag      => FALSE
		  ,p_called_frm_ss      => FALSE
		 );
		 return;
	   end if;
	  end if;
	  /* End Enhancement Bug 8716679*/
          --
          for l_bckdt_epe in 1..l_bckdt_epe_count loop
            --Get the current per_in_ler info
            --
            l_bckdt_pilepe_inst_row := l_bckdt_pilepe_table(l_bckdt_epe);
            --
            hr_utility.set_location(' Calling ben_reinstate_epe_cache.get_pilcobjepe_dets '||l_bckdt_pen_table(l_bckdt_epe).pgm_id
                                      ||' PLN '||l_bckdt_pen_table(l_bckdt_epe).pl_id||' OIPL '
                                      ||l_bckdt_pen_table(l_bckdt_epe).oipl_id,175);
            --
            ben_reinstate_epe_cache.get_pilcobjepe_dets(
                            p_per_in_ler_id => p_per_in_ler_id
                           ,p_pgm_id        => l_bckdt_pen_table(l_bckdt_epe).pgm_id
                           ,p_pl_id         => l_bckdt_pen_table(l_bckdt_epe).pl_id
                           ,p_oipl_id       => l_bckdt_pen_table(l_bckdt_epe).oipl_id
                           ,p_inst_row      => l_pilepe_inst_row
                            );
            --
            --if epe record found in the latest PIL then go ahead and compare the results
            --otherwise go to next backedout epe.. but at the same time record the non-backed out
            --epe records
            if l_pilepe_inst_row.elig_per_elctbl_chc_id is not null then
               --Lucky Guy found a choice ... You are going be reinstated.
               --for l_pilepe_inst_row record
               l_valid_count := l_valid_count + 1 ;
               l_valid_epe_table(l_valid_count) := l_pilepe_inst_row ;
               l_valid_pen_table(l_valid_count) := l_bckdt_pen_table(l_bckdt_epe);
               --
            else
              --
              l_invalid_count := l_invalid_count + 1 ;
              l_invalid_epe_table(l_invalid_count) := l_pilepe_inst_row ;
              l_invalid_pen_table(l_invalid_count) := l_bckdt_pen_table(l_bckdt_epe);
              --
              hr_utility.set_location('NO EPE '||l_bckdt_pilepe_inst_row.elig_per_elctbl_chc_id,250);
              --
            end if ;
            --
          end loop;
          hr_utility.set_location(' l_invalid_count '||l_invalid_count,260);
          hr_utility.set_location(' l_valid_count '||l_valid_count,260);
          --
        end if;
        --
      end if;  -- Else for VALIDATE_ALL
      --This is the right place call reinstate results for the valid epe table
      --

    /* commented against bug 7679297

    -- Bug 6328780 -- First we need to end date the enrollments end dated by Open
    open c_unres_per_in_ler;
    fetch c_unres_per_in_ler into l_unres_per_in_ler;
    if c_unres_per_in_ler%NOTFOUND then

     open c_en_dtd_pen_bckdt_pil;
      loop
	 fetch c_en_dtd_pen_bckdt_pil into l_en_dtd_pen_bckdt_pil;
	 exit when c_en_dtd_pen_bckdt_pil%NOTFOUND;
	--
        hr_utility.set_location('PEN'||l_en_dtd_pen_bckdt_pil.bkup_tbl_id,234234);
        --
	ben_prtt_enrt_result_api.delete_enrollment(
             p_validate              => false,
             p_per_in_ler_id         => p_per_in_ler_id,
             p_prtt_enrt_rslt_id     => l_en_dtd_pen_bckdt_pil.bkup_tbl_id,
             p_effective_start_date  => l_effective_start_date,
             p_effective_end_date    => l_effective_end_date,
             p_object_version_number => l_en_dtd_pen_bckdt_pil.object_version_number,
             p_business_group_id     => p_business_group_id,
             p_effective_date        => p_effective_date,
             p_datetrack_mode        => 'DELETE',
             p_multi_row_validate    => false);
      --
      end loop;
      --
     close c_en_dtd_pen_bckdt_pil;
     --
    end if;
    close c_unres_per_in_ler;

    */

      if l_valid_pen_table.COUNT > 0 and l_valid_epe_table.COUNT > 0 then
        hr_utility.set_location('Calling reinstate_prev_enrt_for_popl '
                                   ||r_pel.pgm_id||' PLN '||r_pel.pl_id,300);
        --
           reinstate_prev_enrt_for_popl(
             p_bckdt_pen_table          => l_valid_pen_table
            ,p_epe_table                => l_valid_epe_table
            ,p_pgm_table                => l_pgm_table
            ,p_pl_table                 => l_pl_table
            ,p_enrt_table               => l_enrt_table
            ,p_person_id                => p_person_id
            ,p_pgm_id                   => r_pel.pgm_id
            ,p_pl_id                    => r_pel.pl_id
            ,p_business_group_id        => p_business_group_id
            ,p_effective_date           => p_effective_date
            ,p_per_in_ler_id            => p_per_in_ler_id
            ,p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id
            ,p_enrt_perd_strt_dt        => r_pel.enrt_perd_strt_dt
            ,p_max_enrt_esd             => l_max_enrt_esd_out
        );
        --
        hr_utility.set_location('Done reinstate_prev_enrt_for_popl',310);
        --
      else
        --
        hr_utility.set_location('Not Calling reinstate_prev_enrt_for_popl ',310);
        --
      end if;
      --
      if l_max_enrt_esd_out >= nvl(l_max_enrt_esd,l_max_enrt_esd_out) then
        --
        l_max_enrt_esd := l_max_enrt_esd_out ;
        --
      end if;
      --
    end if;
    --
  end loop;
  --
  --Now for the new enrollments, we need to reinstate rates, flex credits and overrides.
  --Also we will make the multirow edits for plans not in process and process post enrollment
  --
  --
  hr_utility.set_location('Reinstate  ',610.2);
  hr_utility.set_location('prev stad cd  '||  l_bckdt_pil.prvs_stat_cd ,610.2);
  /* Bug 8900007: Fetch the carry forwarded enrollments from the backedout LE. First reinstate is called and
 then carry forward logic. After carry forwarding the enrollments, then the action items and certifications
 will be restored.*/
 if(l_int_rslts_exist_flag = 'N' and l_enrt_table.COUNT is not null and l_enrt_table.COUNT = 0) then
         hr_utility.set_location('Populating g_bckdt_sspndd_pen_list',310);

	 open g_bckdt_pen_sspnd_rslt(p_bckdt_per_in_ler_id,
	                             p_person_id,
				     p_effective_date);
	 fetch g_bckdt_pen_sspnd_rslt BULK COLLECT into g_bckdt_sspndd_pen_list;
         close g_bckdt_pen_sspnd_rslt;
	 hr_utility.set_location('g_bckdt_sspndd_pen_list.count'||g_bckdt_sspndd_pen_list.count,310);
 end if;
 /* End Bug 8900007*/

  /* Added for Enhancement Bug :8716679 */
  /* Message after reinstating the explicit elections for the Reinstatement code VALIDATE_EXPLICIT_ENRT*/
   if(l_reinstate_def = 'Y' and l_def_plus_reinsate_flag = 'N') then
           if fnd_global.conc_request_id in (0,-1) then
		--if called from benauthe
		g_bckdt_pil_restored_cd := 'DEFAULT_PART' ;
		g_bckdt_pil_restored_flag := 'Y';
		--
	      else
		--if called from batch concurrent program
		  fnd_message.set_name('BEN','BEN_94907_RSTRD_EXPL_ELCT');
	          benutils.write(p_text => fnd_message.get);
		--
	      end if;

	 hr_utility.set_location('Entered the cond ',810);
   end if;
   /* End of Enhancement Bug :8716679 */

  /* Bug 9006088: If previous state of the backedout life event is 'PROCD', on reprocessing the
  LE, life event should be closed */
  /* Bug 9710653: Modified conditions for the fix done for Bug 9006088*/
  if( l_bckdt_pil.prvs_stat_cd = 'PROCD' and (l_def_plus_reinsate_flag = 'Y' or l_def_applied = 'Y')
                        and l_reinstate_def = 'Y' ) then

      hr_utility.set_location('Calling close_single_enrollment ',609);
      --
      ben_close_enrollment.close_single_enrollment
                      (p_per_in_ler_id        => p_per_in_ler_id
                      ,p_effective_date       => nvl(l_max_enrt_esd,p_effective_date)
                      ,p_business_group_id    => p_business_group_id
                      ,p_close_cd             => 'FORCE'
                      ,p_validate             => FALSE
                      ,p_close_uneai_flag     => NULL
                      ,p_uneai_effective_date => NULL);
      --
      hr_utility.set_location('Done close_single_enrollment ',609);
  end if;
  /*End Bug 9006088 */

  if ( ( l_int_rslts_exist_flag = 'N' or l_def_plus_reinsate_flag = 'Y' ) and l_enrt_table.COUNT > 0) then
    --
    open c_bckdt_pil ;
      fetch c_bckdt_pil into l_bckdt_pil ;
    close c_bckdt_pil ;
    --
    hr_utility.set_location('Calling reinstate_post_enrt ',400);
    reinstate_post_enrt(
            p_pgm_table               => l_pgm_table
           ,p_pl_table                => l_pl_table
           ,p_enrt_table              => l_enrt_table
           ,p_max_enrt_esd            => l_max_enrt_esd
           ,p_person_id               => p_person_id
           ,p_business_group_id       => p_business_group_id
           ,p_effective_date          => p_effective_date
           ,p_per_in_ler_id           => p_per_in_ler_id
           ,p_bckdt_per_in_ler_id     => p_bckdt_per_in_ler_id
           ,p_cls_enrt_flag           => false --999
           );
    --
    hr_utility.set_location('Done reinstate_post_enrt ',410);
    --
    -- This needs to be handled for new codes
    --
    hr_utility.set_location('Calling reinstate_override ',500);
    --
    reinstate_override(
            p_pgm_table               => l_pgm_table
           ,p_pl_table                => l_pl_table
           ,p_enrt_table              => l_enrt_table
           ,p_max_enrt_esd            => l_max_enrt_esd
           ,p_person_id               => p_person_id
           ,p_business_group_id       => p_business_group_id
           ,p_effective_date          => p_effective_date
           ,p_per_in_ler_id           => p_per_in_ler_id
           ,p_bckdt_per_in_ler_id     => p_bckdt_per_in_ler_id
           ,p_cls_enrt_flag           => false --999
           );
    --
    hr_utility.set_location('Done reinstate_override ',510);
    --
    --
    --Now Determine the logic for close enrollment process.
    --to call close enrollment all of the following conditions must satisfy
    --backedout enrollment must be in closed status
    --all the enrollments should be reinstated
    --
    if l_bckdt_pil.prvs_stat_cd = 'PROCD' and l_reinstate_def = 'N' and ( nvl(l_invalid_pen_table.COUNT,0) = 0 )  then
      --
      hr_utility.set_location('Calling close_single_enrollment ',610);
      --
      ben_close_enrollment.close_single_enrollment
                      (p_per_in_ler_id        => p_per_in_ler_id
                      ,p_effective_date       => nvl(l_max_enrt_esd,p_effective_date)
                      ,p_business_group_id    => p_business_group_id
                      ,p_close_cd             => 'FORCE'
                      ,p_validate             => FALSE
                      ,p_close_uneai_flag     => NULL
                      ,p_uneai_effective_date => NULL);
      --
      hr_utility.set_location('Done close_single_enrollment ',610);
      --
    end if;
    --
    --
    /*
    hr_utility.set_location('Calling Void update_person_life_event' ,700);
    --
    ben_Person_Life_Event_api.update_person_life_event
             (p_per_in_ler_id         => p_bckdt_per_in_ler_id
             ,p_per_in_ler_stat_cd    => 'VOIDD'
             ,p_object_version_number => l_bckdt_pil.object_version_number
             ,p_effective_date        => nvl(l_max_enrt_esd,p_effective_date)
             ,P_PROCD_DT              => l_procd_dt  -- outputs
             ,P_STRTD_DT              => l_strtd_dt
             ,P_VOIDD_DT              => l_voidd_dt  );
    */
    --
    hr_utility.set_location('Done update_person_life_event',710);
    --
    /* Added for Enhancement Bug :8716679. Added If..Else condition */
    /* Message after reinstating the explicit elections for the Reinstatement code VALIDATE_EXPLICIT_ENRT*/
    if(l_reinstate_def = 'Y') then
          if fnd_global.conc_request_id in (0,-1) then
		--if called from benauthe
		g_bckdt_pil_restored_cd := 'DEFAULT_PART' ;
		g_bckdt_pil_restored_flag := 'Y';
		--
	    else
		--if called from batch concurrent program
		  fnd_message.set_name('BEN','BEN_94907_RSTRD_EXPL_ELCT');
	          benutils.write(p_text => fnd_message.get);
		--
	  end if;
       /* End of Enhancement Bug :8716679. */
    else
	    if l_invalid_pen_table.COUNT > 0 then
	      --
	      if fnd_global.conc_request_id in (0,-1) then
		--if called from benauthe
		g_bckdt_pil_restored_cd := 'PART' ;
		g_bckdt_pil_restored_flag := 'Y';
		--
	      else
		--if called from batch concurrent program
		fnd_message.set_name('BEN','BEN_94225_PARTIAL_REINSTATE');
		fnd_message.set_token('LER_NAME',l_bckdt_pil.name);
		benutils.write(p_text => fnd_message.get);
		--
	      end if;
	      --
	    else
	      --
	      if fnd_global.conc_request_id in (0,-1) then
		--if called from benauthe
		g_bckdt_pil_restored_cd := 'ALL' ;
		g_bckdt_pil_restored_flag := 'Y';
		--
	      else
		--if called from batch concurrent program
		fnd_message.set_name('BEN','BEN_92256_BCKDT_PIL_RSTRD');
		fnd_message.set_token('LER_NAME',l_bckdt_pil.name);
		benutils.write(p_text => fnd_message.get);
		--
	      end if;
	      --
	    end if;
    end if;

    -- Void the communications created to new per_in ler.
    --
    hr_utility.set_location('Calling void_literature ',800);
    --
    void_literature(p_person_id         => p_person_id
                 ,p_business_group_id   => p_business_group_id
                 ,p_effective_date      => nvl(l_max_enrt_esd,p_effective_date)
                 ,p_ler_id              => null
                 ,p_per_in_ler_id       => p_per_in_ler_id
                 );
    --
    hr_utility.set_location('Done void_literature ',810);
    --
  end if;
  --
  --
  hr_utility.set_location('Calling Void update_person_life_event' ,700);
  --
  open c_bckdt_pil ;
    fetch c_bckdt_pil into l_bckdt_pil ;
  close c_bckdt_pil ;
  --
  ben_Person_Life_Event_api.update_person_life_event
             (p_per_in_ler_id         => p_bckdt_per_in_ler_id
             ,p_per_in_ler_stat_cd    => 'VOIDD'
             ,p_object_version_number => l_bckdt_pil.object_version_number
             ,p_effective_date        => nvl(l_max_enrt_esd,p_effective_date)
             ,P_PROCD_DT              => l_procd_dt  -- outputs
             ,P_STRTD_DT              => l_strtd_dt
             ,P_VOIDD_DT              => l_voidd_dt  );
  --
  if (l_int_rslts_exist_flag = 'N' or l_def_plus_reinsate_flag = 'Y')  and
     ( l_enrt_table.COUNT = 0 or l_not_reinstate  = 2 ) then
    --
    hr_utility.set_location(' Inside l_int_rslts_exist_flag pad_cmnt_to_rsnd_lit '||l_not_reinstate,820);
    hr_utility.set_location(' l_invalid_count '||l_invalid_count,820);
    hr_utility.set_location(' l_int_rslts_exist_flag '||l_int_rslts_exist_flag,820);
    --
    if l_rslt_exist_flag = 'Y' then
      -- Add comments to new literature sent out
      -- Comment Ex: Because you have experienced another enrollment, your
      -- originlal elections have been voided. You must call benefits centre
      -- to re-elect.
      --
      fnd_message.set_name('BEN','BEN_91283_ORI_ELE_VOID_CMNT');
      fnd_message.set_token('LER_NAME', ben_lf_evt_clps_restore.g_ler_name_cs_bckdt);
      l_resnd_cmnt_txt :=  fnd_message.get;
      --
      pad_cmnt_to_rsnd_lit(
                          p_person_id            => p_person_id
                          ,p_business_group_id   => p_business_group_id
                          ,p_effective_date      => p_effective_date
                          ,p_ler_id              => null
                          ,p_per_in_ler_id       => p_per_in_ler_id
                          ,p_cmnt_txt            => l_resnd_cmnt_txt
                         );
    else
      --
      -- Add comments to new literature sent out
      -- Comment Ex: This is a replacement PFS generated as a result of the
      --    { name of the new event }
      --
      fnd_message.set_name('BEN','BEN_92284_RESND_LIT_CMNT');
      fnd_message.set_token('LER_NAME', ben_lf_evt_clps_restore.g_ler_name_cs_bckdt);
      l_resnd_cmnt_txt :=  fnd_message.get;
      --
      pad_cmnt_to_rsnd_lit(
                          p_person_id            => p_person_id
                          ,p_business_group_id   => p_business_group_id
                          ,p_effective_date      => p_effective_date
                          ,p_ler_id              => null
                          ,p_per_in_ler_id       => p_per_in_ler_id
                          ,p_cmnt_txt            => l_resnd_cmnt_txt
                         );
      --
    end if;
    --
    --we need to log the enrollments which were not being reinstated into the log file here
    --from l_invalid_pen_table table
    --
    hr_utility.set_location('Done calls to pad_cmnt_to_rsnd_lit ',850);
    --
  end if;
  --
  hr_utility.set_location('Completed all PEL records',90);
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end p_lf_evt_clps_restore;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ptnl_per_for_ler >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is called from the BENAUTHE to void the potential by the
-- user.
procedure update_ptnl_per_for_ler(p_ptnl_ler_for_per_id       in number
                          ,p_business_group_id        in number
                          ,p_ptnl_ler_for_per_stat_cd in varchar2
                          ,p_effective_date           in date) is
  --
  l_proc                    varchar2(72) := g_package||'.update_ptnl_per_for_ler';
  --
  cursor c_ptnl is
    select *
    from   ben_ptnl_ler_for_per ptn
    where  ptn.ptnl_ler_for_per_id = p_ptnl_ler_for_per_id
      and  ptn.business_group_id   = p_business_group_id;
  --
  l_ptnl_rec          c_ptnl%rowtype;
  l_mnl_dt            date;
  l_dtctd_dt          date;
  l_procd_dt          date;
  l_unprocd_dt        date;
  l_voidd_dt          date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if p_ptnl_ler_for_per_stat_cd = 'MNL' then
     --
     l_mnl_dt := p_effective_date;
     --
  end if;
  --
  open  c_ptnl;
  fetch c_ptnl into l_ptnl_rec;
  if c_ptnl%found then
     --
     hr_utility.set_location('Voiding  '||p_ptnl_ler_for_per_id,10);
     --
     ben_ptnl_ler_for_per_api.update_ptnl_ler_for_per
           (p_validate                 => false
           ,p_ptnl_ler_for_per_id      => l_ptnl_rec.ptnl_ler_for_per_id
           ,p_ptnl_ler_for_per_stat_cd => nvl(p_ptnl_ler_for_per_stat_cd,'VOIDD')
           ,p_object_version_number    => l_ptnl_rec.object_version_number
           ,p_effective_date           => p_effective_date
           ,p_mnl_dt                   => l_mnl_dt
           ,p_program_application_id   => null
           ,p_program_id               => null
           ,p_request_id               => null
           ,p_program_update_date      => sysdate
           ,p_voidd_dt                 => p_effective_date);
     --
  end if;
  close c_ptnl;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end update_ptnl_per_for_ler;
--
procedure p_reinstate_info_to_form (
                           p_pil_restored_flag out nocopy varchar2,
                           p_pil_restored_cd   out nocopy varchar2,
                           p_bckdt_ler_name    out nocopy varchar2) is
begin
   --
   p_pil_restored_flag := g_bckdt_pil_restored_flag;
   p_pil_restored_cd   := g_bckdt_pil_restored_cd;
   p_bckdt_ler_name    := g_bckdt_ler_name;
   --
end p_reinstate_info_to_form;
--

procedure reinstate_the_prev_enrt_rslt(
                             p_person_id            in number
                            ,p_business_group_id   in number
                            ,p_ler_id              in number
                            ,p_effective_date      in date
                            ,p_per_in_ler_id       in number
                            ,p_bckdt_per_in_ler_id in number
                           ) is
  --
  l_proc                    varchar2(72) := g_package||'.reinstate_the_prev_enrt_rslt';
  --
  l_bckt_csd_per_in_ler_id  number;
  l_bckdt_pil_prev_stat_cd  varchar2(80);
  l_bckdt_pil_ovn           number;
  l_bckdt_lf_evt_ocrd_dt    date ;
  l_date                    date;
  l_procd_dt                date;
  l_strtd_dt                date;
  l_voidd_dt                date;

  --
  cursor c_bckdt_pil is
    select pil.PER_IN_LER_STAT_CD, pil.object_version_number,
           pil.lf_evt_ocrd_dt
    from ben_per_in_ler pil
    where pil.per_in_ler_id = p_bckdt_per_in_ler_id
      and pil.business_group_id = p_business_group_id;


  -- Get the enrollment results from the backup table for backed out pil.
  --
  -- 9999 need to union to pen to get the results which are backed out status.
  -- 9999 should not select PLANFC, PLANIMP
  cursor c_bckdt_pen is
   select
          pen.EFFECTIVE_END_DATE,
          pen.ASSIGNMENT_ID,
          pen.BNFT_AMT,
          pen.BNFT_NNMNTRY_UOM,
          pen.BNFT_ORDR_NUM,
          pen.BNFT_TYP_CD,
          pen.BUSINESS_GROUP_ID,
          pen.COMP_LVL_CD,
          pen.CREATED_BY,
          pen.CREATION_DATE,
          pen.EFFECTIVE_START_DATE,
          pen.ENRT_CVG_STRT_DT,
          pen.ENRT_CVG_THRU_DT,
          pen.ENRT_MTHD_CD,
          pen.ENRT_OVRIDN_FLAG,
          pen.ENRT_OVRID_RSN_CD,
          pen.ENRT_OVRID_THRU_DT,
          pen.ERLST_DEENRT_DT,
          pen.LAST_UPDATED_BY,
          pen.LAST_UPDATE_DATE,
          pen.LAST_UPDATE_LOGIN,
          pen.LER_ID,
          pen.NO_LNGR_ELIG_FLAG,
          pen.OBJECT_VERSION_NUMBER,
          pen.OIPL_ID,
          pen.OIPL_ORDR_NUM,
          pen.ORGNL_ENRT_DT,
          pen.LCR_ATTRIBUTE1,
          pen.LCR_ATTRIBUTE10,
          pen.LCR_ATTRIBUTE11,
          pen.LCR_ATTRIBUTE12,
          pen.LCR_ATTRIBUTE13,
          pen.LCR_ATTRIBUTE14,
          pen.LCR_ATTRIBUTE15,
          pen.LCR_ATTRIBUTE16,
          pen.LCR_ATTRIBUTE17,
          pen.LCR_ATTRIBUTE18,
          pen.LCR_ATTRIBUTE19,
          pen.LCR_ATTRIBUTE2,
          pen.LCR_ATTRIBUTE20,
          pen.LCR_ATTRIBUTE21,
          pen.LCR_ATTRIBUTE22,
          pen.LCR_ATTRIBUTE23,
          pen.LCR_ATTRIBUTE24,
          pen.LCR_ATTRIBUTE25,
          pen.LCR_ATTRIBUTE26,
          pen.LCR_ATTRIBUTE27,
          pen.LCR_ATTRIBUTE28,
          pen.LCR_ATTRIBUTE29,
          pen.LCR_ATTRIBUTE3,
          pen.LCR_ATTRIBUTE30,
          pen.LCR_ATTRIBUTE4,
          pen.LCR_ATTRIBUTE5,
          pen.LCR_ATTRIBUTE6,
          pen.LCR_ATTRIBUTE7,
          pen.LCR_ATTRIBUTE8,
          pen.LCR_ATTRIBUTE9,
          pen.LCR_ATTRIBUTE_CATEGORY,
          pen.PERSON_ID,
          pen.PER_IN_LER_ID,
          pen.PGM_ID,
          pen.PLIP_ORDR_NUM,
          pen.PL_ID,
          pen.PL_ORDR_NUM,
          pen.PL_TYP_ID,
          pen.PROGRAM_APPLICATION_ID,
          pen.PROGRAM_ID,
          pen.PROGRAM_UPDATE_DATE,
          pen.bkup_tbl_id  PRTT_ENRT_RSLT_ID,
          pen.PRTT_ENRT_RSLT_STAT_CD,
          pen.PRTT_IS_CVRD_FLAG,
          pen.PTIP_ID,
          pen.PTIP_ORDR_NUM,
          pen.REQUEST_ID,
          pen.RPLCS_SSPNDD_RSLT_ID,
          pen.SSPNDD_FLAG,
          pen.UOM
    from  ben_le_clsn_n_rstr  pen,
           ben_per_in_ler pil
    where  pil.per_in_ler_id       = p_bckdt_per_in_ler_id
    and    pil.person_id           = p_person_id
    and    pil.business_group_id   = p_business_group_id
    AND    pil.per_in_ler_id       = pen.per_in_ler_id
    and    pen.bkup_tbl_typ_cd     = 'BEN_PRTT_ENRT_RSLT_F'
    and    ((pen.enrt_cvg_thru_dt is null or
            pen.enrt_cvg_thru_dt    = hr_api.g_eot)  and
--bug#2604375 - added to control updated result rows for the same per_in_ler
            pen.effective_end_date  = hr_api.g_eot
           )
    and    pen.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
    and pen.bkup_tbl_id not in (
         select nvl(pen_inner.RPLCS_SSPNDD_RSLT_ID, -1)
           from   ben_prtt_enrt_rslt_f pen_inner,
                  ben_per_in_ler pil_inner
           where  pil_inner.per_in_ler_id       = p_bckdt_per_in_ler_id
           and    pil_inner.person_id           = p_person_id
           and    pil_inner.business_group_id = p_business_group_id
           and    pil_inner.per_in_ler_id       = pen_inner.per_in_ler_id
           and    (pen_inner.enrt_cvg_thru_dt is null or
                   pen_inner.enrt_cvg_thru_dt    = hr_api.g_eot
                  )
           and    pen_inner.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
         union
         select nvl(pen_inner.RPLCS_SSPNDD_RSLT_ID, -1)
             from  ben_le_clsn_n_rstr  pen_inner,
                    ben_per_in_ler pil_inner
             where  pil_inner.per_in_ler_id       = p_bckdt_per_in_ler_id
             and    pil_inner.person_id           = p_person_id
             and    pil_inner.business_group_id   = p_business_group_id
             AND    pil_inner.per_in_ler_id       = pen_inner.per_in_ler_id
             and    pen_inner.bkup_tbl_typ_cd     = 'BEN_PRTT_ENRT_RSLT_F'
           and    (pen_inner.enrt_cvg_thru_dt is null or
                   pen_inner.enrt_cvg_thru_dt    = hr_api.g_eot
                  )
           and    pen_inner.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
       )
    order by 1; -- pen.effective_end_date; -- Low to High
  --
  -- Get the electable choice data.
  --
  cursor c_epe_pen(cp_pl_id in number,
                   cp_pgm_id in number,
                   cp_oipl_id in number,
                   cp_per_in_ler_id in number ) is
    select epe.*,
           pel.enrt_typ_cycl_cd,
           pel.enrt_perd_end_dt,
           pel.enrt_perd_strt_dt,
           to_date('31-12-4712','DD-MM-YYYY') enrt_cvg_end_dt,
           pel.dflt_enrt_dt
    from   ben_elig_per_elctbl_chc epe,
           ben_per_in_ler pil,
           ben_pil_elctbl_chc_popl pel
    where  epe.per_in_ler_id     = cp_per_in_ler_id
      and  epe.business_group_id = p_business_group_id
      and  epe.pl_id             = cp_pl_id
      and  nvl(epe.pgm_id, -1)   = nvl(cp_pgm_id, -1)
      and  nvl(epe.oipl_id, -1)  = nvl(cp_oipl_id, -1)
      and  pil.business_group_id = p_business_group_id
      and  pel.business_group_id = epe.business_group_id
      and  pil.person_id = p_person_id
      and  epe.per_in_ler_id = pil.per_in_ler_id
      and  pel.per_in_ler_id = epe.per_in_ler_id
      and  pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id;
  --
  l_epe_pen_rec c_epe_pen%rowtype;
  --
  cursor c_bnft(cp_elig_per_elctbl_chc_id in number,cp_ordr_num number ) is
     select enb.enrt_bnft_id,
            enb.entr_val_at_enrt_flag,
            enb.dflt_val,
            enb.val,
            enb.dflt_flag,
            enb.object_version_number,
            enb.prtt_enrt_rslt_id,
            enb.cvg_mlt_cd          --Bug 3315323
      from  ben_enrt_bnft enb
      where enb.elig_per_elctbl_chc_id = cp_elig_per_elctbl_chc_id
  -- Bug  2526994 we need take the right one
  --    and   nvl(enb.mx_wo_ctfn_flag,'N') = 'N' ;
        and enb.ordr_num = cp_ordr_num ; --This is more accurate
  --
  l_bnft_rec            c_bnft%rowtype;
  l_bnft_rec_reset      c_bnft%rowtype;
  l_bnft_entr_val_found boolean;
  l_num_bnft_recs       number := 0;
  --
  --
  cursor c_rt(cp_elig_per_elctbl_chc_id number,
              cp_enrt_bnft_id           number) is
      select ecr.enrt_rt_id,
             ecr.dflt_val,
             ecr.val,
             ecr.entr_val_at_enrt_flag,
             ecr.acty_base_rt_id
      from   ben_enrt_rt ecr
      where  ecr.elig_per_elctbl_chc_id = cp_elig_per_elctbl_chc_id
      and    ecr.business_group_id = p_business_group_id
      and    ecr.entr_val_at_enrt_flag = 'Y'
      and    ecr.spcl_rt_enrt_rt_id is null
  --    and    ecr.prtt_rt_val_id is null
      union
      select ecr.enrt_rt_id,
             ecr.dflt_val,
             ecr.val,
             ecr.entr_val_at_enrt_flag,
             ecr.acty_base_rt_id
      from   ben_enrt_rt ecr
      where  ecr.enrt_bnft_id = cp_enrt_bnft_id
      and    ecr.business_group_id = p_business_group_id
      and    ecr.entr_val_at_enrt_flag = 'Y'
      and    ecr.spcl_rt_enrt_rt_id is null;
  --    and    ecr.prtt_rt_val_id is null;
  --
  l_rt c_rt%rowtype;
  --
  type g_rt_rec is record
      (enrt_rt_id ben_enrt_rt.enrt_rt_id%type,
       dflt_val   ben_enrt_rt.dflt_val%type,
       calc_val   ben_enrt_rt.dflt_val%type,
       cmcd_rt_val number,
       ann_rt_val  number);
  --
  type g_rt_table is table of g_rt_rec index by binary_integer;
  --
  --
  l_rt_table g_rt_table;
  l_count    number;
  --
  type pgm_rec is record
       (pgm_id        ben_pgm_f.pgm_id%type,
        enrt_mthd_cd  ben_prtt_enrt_rslt_f.enrt_mthd_cd%type,
        multi_row_edit_done boolean,
        non_automatics_flag boolean,
        max_enrt_esd  date);
  --
  type pl_rec is record
       (pl_id         ben_pl_f.pl_id%type,
        enrt_mthd_cd  ben_prtt_enrt_rslt_f.enrt_mthd_cd%type,
        multi_row_edit_done boolean,
        max_enrt_esd  date);
  --
  type enrt_rec is record
       (prtt_enrt_rslt_id        ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%type,
        bckdt_prtt_enrt_rslt_id  ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%type,
        bckdt_enrt_ovridn_flag    varchar2(1),
        bckdt_enrt_cvg_strt_dt   date,
        bckdt_enrt_cvg_thru_dt   date,
        g_sys_date               date,
        pen_ovn_number           ben_prtt_enrt_rslt_f.object_version_number%type,
        old_pl_id                ben_prtt_enrt_rslt_f.pl_id%type,
        new_pl_id                ben_prtt_enrt_rslt_f.pl_id%type,
        old_oipl_id              ben_prtt_enrt_rslt_f.oipl_id%type,
        new_oipl_id              ben_prtt_enrt_rslt_f.oipl_id%type,
        old_pl_typ_id            ben_prtt_enrt_rslt_f.pl_typ_id%type,
        new_pl_typ_id            ben_prtt_enrt_rslt_f.pl_typ_id%type,
        pgm_id                   ben_prtt_enrt_rslt_f.pgm_id%type,
        ler_id                   ben_ler_f.ler_id%type,
        elig_per_elctbl_chc_id   ben_elig_per_elctbl_chc.elig_per_elctbl_chc_id%type,
        dpnt_cvg_strt_dt_cd      ben_elig_per_elctbl_chc.dpnt_cvg_strt_dt_cd%type,
        dpnt_cvg_strt_dt_rl      ben_elig_per_elctbl_chc.dpnt_cvg_strt_dt_rl%type,
        effective_start_date     ben_prtt_enrt_rslt_f.effective_start_date%type
        );
  --
  --
  type t_pgm_table is table of pgm_rec index by binary_integer;
  type t_pl_table is table of pl_rec index by binary_integer;
  type t_enrt_table is table of enrt_rec index by binary_integer;
  type t_prtt_rt_val_table is table of number index by binary_integer;
  l_pgm_table     t_pgm_table;
  l_pl_table      t_pl_table;
  l_enrt_table    t_enrt_table;
  l_pgm_count     number;
  l_pl_count      number;
  l_enrt_count    number;
  l_prtt_rt_val_table t_prtt_rt_val_table;
  --
  cursor c_prv(cv_prtt_enrt_rslt_id in number,
               cv_acty_base_rt_id   in number) is
         select  prv.*
         from ben_prtt_rt_val prv
         where prv.prtt_enrt_rslt_id      = cv_prtt_enrt_rslt_id
           and prv.per_in_ler_id     = p_bckdt_per_in_ler_id
           and prv.business_group_id = p_business_group_id
           and prv.acty_base_rt_id   = cv_acty_base_rt_id;
  --
  -- 9999 do I need to use rt_strt_dt or rt_end_date etc.,
  --
  l_prv_rec c_prv%rowtype;
  l_prv_rec_nulls c_prv%rowtype;
  --
  cursor c_bckt_csd_pen(cv_per_in_ler_id in number) is
         select pen.*, pil.lf_evt_ocrd_dt
         from ben_prtt_enrt_rslt_f pen,
              ben_per_in_ler pil
         where pen.per_in_ler_id = cv_per_in_ler_id
           and pen.per_in_ler_id = pil.per_in_ler_id
           and pen.business_group_id = p_business_group_id
           and pil.business_group_id = p_business_group_id
           and pen.prtt_enrt_rslt_stat_cd is null
           and pen.effective_end_date = hr_api.g_eot
           and pen.comp_lvl_cd         not in ('PLANFC', 'PLANIMP')
           and (pen.enrt_cvg_thru_dt is null or
                pen.enrt_cvg_thru_dt    = hr_api.g_eot
               );
  type t_bckt_csd_pen_table is table of c_bckt_csd_pen%rowtype index by binary_integer;
  l_bckt_csd_pil_enrt_table t_bckt_csd_pen_table;
  l_bckt_csd_pen_esd        date;
  l_bckt_csd_pil_leod       date;
  -- Bug 2677804 Added new parameter to see the thru date
  cursor c_ovridn_rt(v_bckdt_pen_id number
                    ,v_new_pen_id   number ) is
  select prv2.prtt_rt_val_id new_prv_id,
         prv2.object_version_number new_prv_ovn,
         prv1.*
    from ben_prtt_rt_val prv1, ben_prtt_rt_val prv2
   where prv1.prtt_enrt_rslt_id = v_bckdt_pen_id
     and prv2.prtt_enrt_rslt_id = v_new_pen_id
     and prv1.acty_base_rt_id = prv2.acty_base_rt_id
     and prv1.rt_ovridn_flag = 'Y'
     and prv1.rt_end_dt <> hr_api.g_eot
     and prv1.rt_ovridn_thru_dt >= prv2.rt_strt_dt
--     and prv1.prtt_rt_val_stat_cd is null
     and prv2.prtt_rt_val_stat_cd is null
     and prv2.per_in_ler_id = p_per_in_ler_id ;
  --
  cursor c_ovridn_dpnt(v_bckdt_pen_id number
                      ,v_new_pen_id   number
                      ,v_effective_date date) is
  select pdp2.elig_cvrd_dpnt_id new_pdp_id,
         pdp2.object_version_number new_pdp_ovn,
         pdp1.*
    from ben_elig_cvrd_dpnt_f pdp1,
         ben_elig_cvrd_dpnt_f pdp2
   where pdp1.prtt_enrt_rslt_id = v_bckdt_pen_id
     and pdp2.prtt_enrt_rslt_id = v_new_pen_id
     and pdp1.dpnt_person_id = pdp2.dpnt_person_id
     and pdp1.ovrdn_flag = 'Y'
     and v_effective_date between pdp1.effective_start_date
                            and pdp1.effective_end_date
     and v_effective_date between pdp2.effective_start_date
                            and pdp2.effective_end_date;
  --
  cursor c_ovn(v_prtt_enrt_rslt_id number) is
  select object_version_number
    from ben_prtt_enrt_rslt_f
   where prtt_enrt_rslt_id = v_prtt_enrt_rslt_id
     and effective_end_date = hr_api.g_eot;
  --
  cursor c_prv_ovn (v_prtt_rt_val_id number) is
    select prv.*
          ,abr.input_value_id
          ,abr.element_type_id
    from   ben_prtt_rt_val  prv,
           ben_acty_base_rt_f abr
    where  prtt_rt_val_id = v_prtt_rt_val_id
       and abr.acty_base_rt_id=prv.acty_base_rt_id
       and abr.business_group_id = p_business_group_id
       and p_effective_date between
             abr.effective_start_date and abr.effective_end_date;
  --
   cursor c_rslt_exists (p_person_id number,
                        p_pl_id     number,
                        p_oipl_id   number,
                        p_per_in_ler_id number)  is -- 8626297
    select 'Y'
    from ben_prtt_enrt_rslt_f pen
    where pen.person_id = p_person_id
    and   pen.pl_id     = p_pl_id
    and   nvl(pen.oipl_id,-9999)   = nvl(p_oipl_id,-9999)  --5287988
     and   pen.per_in_ler_id = p_per_in_ler_id -- 8626297
    and   pen.prtt_enrt_rslt_stat_cd is null
    and   pen.enrt_cvg_thru_dt = hr_api.g_eot
    and   pen.effective_end_date = hr_api.g_eot;

  /* Bug 8863079: Added cursor c_get_epe_id to determine the interim epe record */
  cursor c_get_epe_id(c_prtt_enrt_rslt_id number,c_per_in_ler_id number) is
    select elig_per_elctbl_chc_id from ben_elig_per_elctbl_chc epe,
		ben_prtt_enrt_rslt_f pen
		where pen.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
		and epe.per_in_ler_id = c_per_in_ler_id
		and epe.pl_id = pen.pl_id
                and epe.pl_typ_id = pen.pl_typ_id
		and nvl(epe.pgm_id,-1) = nvl(pen.pgm_id,-1)
		and nvl(epe.oipl_id,-1) = nvl(pen.oipl_id,-1);
   l_interim_epe_id number;
  --
  l_rslt_exists    varchar2(30);
  --
  l_upd_rt_val            boolean;
  l_prv_ovn               c_prv_ovn%rowtype;
  l_suspend_flag          varchar2(30);
  l_prtt_rt_val_id1       number;
  l_prtt_rt_val_id2       number;
  l_prtt_rt_val_id3       number;
  l_prtt_rt_val_id4       number;
  l_prtt_rt_val_id5       number;
  l_prtt_rt_val_id6       number;
  l_prtt_rt_val_id7       number;
  l_prtt_rt_val_id8       number;
  l_prtt_rt_val_id9       number;
  l_prtt_rt_val_id10      number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_dpnt_actn_warning     boolean;
  l_bnf_actn_warning      boolean;
  l_ctfn_actn_warning     boolean;
  l_prtt_enrt_interim_id  number;
  l_prtt_enrt_rslt_id     number;
  l_object_version_number number;
  l_cls_enrt_flag         boolean := FALSE;
  l_prev_pgm_id           number := NULL; -- Do not change it
  l_enrt_mthd_cd          varchar2(30);
  l_found                 boolean;
  l_enrt_cnt              number := 1;
  l_max_enrt_esd          date;
  l_esd_out               date;
  l_eed_out               date;
  l_ovn                   number(15);
  --RCHASE - ensure automatics are handled differently than
  --         form enrollments by process_post_enrollment
  l_proc_cd               varchar2(30);
  --
  l_found_non_automatics  boolean;
  l_dummy_number          number;
  --
  l_enrt_cvg_strt_dt      date;
  --
begin
  --
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  open c_bckdt_pil;
  fetch c_bckdt_pil into l_bckdt_pil_prev_stat_cd, l_bckdt_pil_ovn, l_bckdt_lf_evt_ocrd_dt ;
  close c_bckdt_pil;
  l_bckt_csd_per_in_ler_id   := p_bckdt_per_in_ler_id ;

  hr_utility.set_location( ' p_bckdt_per_in_ler_id'||p_bckdt_per_in_ler_id,99) ;
  hr_utility.set_location( ' l_bckt_csd_per_in_ler_id ' || l_bckt_csd_per_in_ler_id, 99 );

  ben_close_enrollment.reopen_single_life_event
      (p_per_in_ler_id         =>  p_bckdt_per_in_ler_id
      ,p_person_id             =>  p_person_id
      ,p_lf_evt_ocrd_dt        =>  l_bckdt_lf_evt_ocrd_dt
      ,p_effective_date        =>  p_effective_date
      ,p_business_group_id     =>  p_business_group_id
      ,p_object_version_number =>  l_bckdt_pil_ovn
      ,p_source                =>  'backout'  --Bug 5929635 Call reopen_single_life_event in backout routine
      ) ;


  --
  l_cls_enrt_flag := TRUE;
  ---
  l_pgm_table.delete;
  l_pl_table.delete;
  l_enrt_table.delete;
  l_bckt_csd_pil_enrt_table.delete;
  --
  -- Get the enrollment results attached to per in ler which
  -- caused the back out of currenlty backed out per in ler.
  --
  if l_bckt_csd_per_in_ler_id is not null then
     --
     for l_bckt_csd_pen_rec in c_bckt_csd_pen(l_bckt_csd_per_in_ler_id) loop
         --
         l_bckt_csd_pil_enrt_table(l_enrt_cnt) := l_bckt_csd_pen_rec;
         l_enrt_cnt := l_enrt_cnt + 1;
         --
     end loop;
     --
  end if;
  --
  -- For each of the enrollment result in back up table, create
  -- a enrollment.
  --
  FOR l_bckdt_pen_rec in c_bckdt_pen loop
    --
    -- If the enrollment record is valid for the current
    -- effective_date then recreate the enrollment.
    --
    hr_utility.set_location('Inside BCKDT pen loop ' || l_proc,20);
    hr_utility.set_location('prtt rslt id ' || l_bckdt_pen_rec.prtt_enrt_rslt_id,20);
    --
    -- 9999 modify the if clause to look at effective_end_date
    -- Why this condition? Is it to look at only the enrollments
    -- which are valid as of benmngle run date? If so then should it
    -- be sysdate as the results are reinstated as of sysdate.
    -- or should it be l_bckdt_pen_rec.effective_end_date = EOT
    --
    -- if p_effective_date <= l_bckdt_pen_rec.effective_end_date
    --
    l_rslt_exists := 'N';
    open c_rslt_exists (l_bckdt_pen_rec.person_id,
                        l_bckdt_pen_rec.pl_id,
                        l_bckdt_pen_rec.oipl_id,
                        l_bckdt_pen_rec.per_in_ler_id); -- 8626297
    fetch c_rslt_exists into l_rslt_exists;
    close c_rslt_exists;
    --
    if l_rslt_exists = 'N' then
      l_bckt_csd_pen_esd  := null;
      l_bckt_csd_pil_leod := null;
      if nvl(l_bckt_csd_pil_enrt_table.last,0) > 0 then
         --
         for l_cnt in 1..l_bckt_csd_pil_enrt_table.LAST loop
             --
             if nvl(l_bckt_csd_pil_enrt_table(l_cnt).pl_id, -1) = nvl(l_bckdt_pen_rec.pl_id, -1) and
                nvl(l_bckt_csd_pil_enrt_table(l_cnt).pgm_id, -1) = nvl(l_bckdt_pen_rec.pgm_id, -1) and
                nvl(l_bckt_csd_pil_enrt_table(l_cnt).oipl_id, -1) = nvl(l_bckdt_pen_rec.oipl_id, -1)
             then
                   l_bckt_csd_pen_esd := l_bckt_csd_pil_enrt_table(l_cnt).effective_start_date;
                   l_bckt_csd_pil_leod := l_bckt_csd_pil_enrt_table(l_cnt).lf_evt_ocrd_dt;
                   exit;
             end if;
             --
         end loop;
         --
      end if;
      --
      g_sys_date := greatest(trunc(sysdate),
                      nvl(nvl(l_bckt_csd_pen_esd, g_bckt_csd_lf_evt_ocrd_dt), hr_api.g_sot) + 1,
                      l_bckdt_pen_rec.effective_start_date);
      --
      l_max_enrt_esd := greatest(g_sys_date, nvl(l_max_enrt_esd, hr_api.g_sot));
      --
      hr_utility.set_location('Date used to reinstate the enrollment = ' || g_sys_date, 333);
      if g_sys_date <= l_bckdt_pen_rec.effective_end_date
      then
         --
         -- Get the electable choice data to create enrollment row.
         --
         hr_utility.set_location('epe fetch pl ' || l_bckdt_pen_rec.pl_id,30);
         hr_utility.set_location('epe fetch  pgm ' || l_bckdt_pen_rec.pgm_id,30);
         hr_utility.set_location('epe fetch oipl ' || l_bckdt_pen_rec.oipl_id,30);
         hr_utility.set_location('epe fetch pil ' || l_bckt_csd_per_in_ler_id,30);
         open c_epe_pen(l_bckdt_pen_rec.pl_id,
                        l_bckdt_pen_rec.pgm_id,
                        l_bckdt_pen_rec.oipl_id,
                        l_bckt_csd_per_in_ler_id);
         fetch c_epe_pen into l_epe_pen_rec;
         close c_epe_pen;
         hr_utility.set_location('After epe fetch ' || l_proc,30);
         hr_utility.set_location('After epe epe ' || l_epe_pen_rec.elig_per_elctbl_chc_id,30);
         --
         --
         l_num_bnft_recs := 0;
         l_bnft_entr_val_found := FALSE;
         l_bnft_rec := l_bnft_rec_reset;
         --
         open c_bnft(l_epe_pen_rec.elig_per_elctbl_chc_id,l_bckdt_pen_rec.bnft_ordr_num );
         loop
           --
           hr_utility.set_location('Inside bnft loop ' || l_proc,40);
           -- BUG 3315323
           --
           fetch c_bnft into l_bnft_rec;
           exit when c_bnft%notfound;
           if l_bnft_rec.entr_val_at_enrt_flag = 'Y' OR l_bnft_rec.cvg_mlt_cd = 'SAAEAR' then
              l_bnft_entr_val_found := TRUE;
           end if;
           l_num_bnft_recs := l_num_bnft_recs + 1;
           --
           if l_bckdt_pen_rec.BNFT_AMT = l_bnft_rec.VAL then
              --
              -- Found the benefit we are looking for, so exit.
              --
              exit;
              --
           end if;
           --
         end loop;
         --
         -- Bug 5282 :  When a backed out life event is repeocessed
         -- plans with enter 'enter val at enrollment' coverage amount
         -- previous amount is not used when enrollments reinstated.
         --
         if l_bnft_entr_val_found
         then
           if l_num_bnft_recs =  0 then
              null;
              -- This is a error condition, so rollback all the reinstate process.
           else
              --
             l_bnft_rec.val := l_bckdt_pen_rec.BNFT_AMT;
              --
           end if;
         end if;
         hr_utility.set_location(l_proc,50);
         close c_bnft;
         --
         for l_count in 1..10 loop
            --
            -- Initialise array to null
            --
            l_rt_table(l_count).enrt_rt_id := null;
            l_rt_table(l_count).dflt_val := null;
            --
         end loop;
         --
         -- Now get the rates.
         --
         l_count:= 0;
         --
         for l_rec in c_rt(l_epe_pen_rec.elig_per_elctbl_chc_id,
                           l_bnft_rec.enrt_bnft_id)
         loop
            --
            hr_utility.set_location('Inside rate loop ' ||l_proc,50);
            --
            -- Get the prtt rate val for this enrollment result.
            -- Use to pass to the enrollment process.
            --
            -- Bug : 1634870 : If the user not selected the rate before backout
            -- then do not pass it to the reinstate process.
            --
            hr_utility.set_location('enrt_rt_id : dflt_val : val : entr_val' ||
                                    '_at_enrt_flag : acty_base_rt_id : ' , 501);
            hr_utility.set_location(l_rec.enrt_rt_id || ' : ' || l_rec.dflt_val || ' : ' || l_rec.val || '
  : '
                                    || l_rec.entr_val_at_enrt_flag || ' : ' ||
                                    l_rec.acty_base_rt_id, 501);
           --
            l_prv_rec := l_prv_rec_nulls;
            open c_prv(l_bckdt_pen_rec.prtt_enrt_rslt_id ,
                       l_rec.acty_base_rt_id);
            fetch c_prv into l_prv_rec;
            if c_prv%found then -- l_prv_rec.prtt_rt_val_id is not null then
               --
               l_count := l_count+1;
               hr_utility.set_location('prtt_rt_val_id : rt_val : ' ||
                       l_prv_rec.prtt_rt_val_id ||  ' : ' || l_prv_rec.rt_val
                       || ' : ' || l_prv_rec.acty_base_rt_id , 502);
               l_rt_table(l_count).enrt_rt_id := l_rec.enrt_rt_id;
               if l_prv_rec.mlt_cd in ('CL','CVG','AP','PRNT','CLANDCVG','APANDCVG','PRNTANDCVG') then
                  l_rt_table(l_count).dflt_val := l_rec.dflt_val;
                  l_rt_table(l_count).calc_val := l_prv_rec.rt_val;
                  l_rt_table(l_count).cmcd_rt_val := l_prv_rec.cmcd_rt_val;
                  l_rt_table(l_count).ann_rt_val  := l_prv_rec.ann_rt_val;
               else
                  l_rt_table(l_count).dflt_val   := l_prv_rec.rt_val;
                  l_rt_table(l_count).calc_val   := l_prv_rec.rt_val;
                  l_rt_table(l_count).cmcd_rt_val := l_prv_rec.cmcd_rt_val;
                  l_rt_table(l_count).ann_rt_val  := l_prv_rec.ann_rt_val;
               end if;
               --
            end if;
            close c_prv;
            --
         end loop;
         --
         -- Call election information batch process
         --
         -- 99999 Study all the parameters passed.
         --
         -- initialize all the out parameters.
         l_suspend_flag          := null;
         l_prtt_rt_val_id1       := null;
         l_prtt_rt_val_id2       := null;
         l_prtt_rt_val_id3       := null;
         l_prtt_rt_val_id4       := null;
         l_prtt_rt_val_id5       := null;
         l_prtt_rt_val_id6       := null;
         l_prtt_rt_val_id7       := null;
         l_prtt_rt_val_id8       := null;
         l_prtt_rt_val_id9       := null;
         l_prtt_rt_val_id10      := null;
         l_effective_start_date  := null;
         l_effective_end_date    := null;
         l_dpnt_actn_warning     := null;
         l_bnf_actn_warning      := null;
         l_ctfn_actn_warning     := null;
         l_prtt_enrt_interim_id  := null;
         l_prtt_enrt_rslt_id     := null;
         l_object_version_number := null;
	 l_enrt_cvg_strt_dt      := null;

       -- if cvg_st_dt_cd is enterable then copy the l_bckdt_pen_rec.enrt_cvg_strt_dt
       -- 5746429 starts

       if  l_epe_pen_rec.enrt_cvg_strt_dt_cd = 'ENTRBL'
        then
	      l_enrt_cvg_strt_dt := l_bckdt_pen_rec.enrt_cvg_strt_dt ;
       end if ;
       -- 5746429 ends

         hr_utility.set_location('Calling ben_election_information ' ||l_proc,60);
         hr_utility.set_location('Calling l_bnft_rec.val ' ||l_bnft_rec.val,60);
         hr_utility.set_location('Calling l_epe_pen_rec.prtt_enrt_rslt_id ' ||l_epe_pen_rec.prtt_enrt_rslt_id,60);
         hr_utility.set_location('Calling l_bnft_rec.prtt_enrt_rslt_id ' ||l_bnft_rec.prtt_enrt_rslt_id,60);
	     hr_utility.set_location('Calling l_enrt_cvg_strt_dt ' ||l_enrt_cvg_strt_dt,60);

         -- since it is the result  level backout  the result id are nullified so
         -- Election information wont look for the result id to get the old result information

         if l_epe_pen_rec.prtt_enrt_rslt_id is not null  then

            l_object_version_number := l_epe_pen_rec.object_version_number ;
            ben_ELIG_PER_ELC_CHC_api.update_ELIG_PER_ELC_CHC
                       (p_validate                => FALSE
                       ,p_elig_per_elctbl_chc_id  => l_epe_pen_rec.elig_per_elctbl_chc_id
                       ,p_prtt_enrt_rslt_id       => NULL
                       ,p_object_version_number   => l_object_version_number
                       ,p_effective_date          => p_effective_date
                       );
            l_object_version_number := null;

        end if ;

        if l_bnft_rec.prtt_enrt_rslt_id is not null then
              l_object_version_number := l_bnft_rec.object_version_number ;
              ben_enrt_bnft_api.update_enrt_bnft
                  (p_enrt_bnft_id           => l_bnft_rec.enrt_bnft_id
                  ,p_effective_date         => p_effective_date
                  ,p_object_version_number  => l_object_version_number
                  ,p_business_group_id      => p_business_group_id
                  ,p_prtt_enrt_rslt_id      => NULL
                  );
        end if ;
        --
        --

       /* Bug 8863079: When a Life Event is backedout,while reopening the results of the previous enrollment and
	   if the life event has no electability, do not determine the interim again. Instead use the old interim
	   pen id(from backed out result) record and then determine the interim epe record. Interim record fetched by cursor c_get_epe_id
	   assign to g_reinstate_interim_chc_id which will be used in bensuenr.pkb to determine the interim*/
             g_reinstate_interim_flag := false;
             g_reinstate_interim_chc_id := null;
	     hr_utility.set_location('Suspended Flag  ' ||l_bckdt_pen_rec.SSPNDD_FLAG,60);
             hr_utility.set_location('Interim Rslt Id  ' ||l_bckdt_pen_rec.RPLCS_SSPNDD_RSLT_ID,60);
             hr_utility.set_location('P_per_in_ler_id  ' ||p_per_in_ler_id,60);
	     hr_utility.set_location('p_bckdt_per_in_ler_id  ' ||p_bckdt_per_in_ler_id,60);
             if(l_bckdt_pen_rec.SSPNDD_FLAG = 'Y' and l_bckdt_pen_rec.RPLCS_SSPNDD_RSLT_ID is not NULL) then
	        if(l_epe_pen_rec.elctbl_flag = 'N') then
		 open c_get_epe_id(l_bckdt_pen_rec.RPLCS_SSPNDD_RSLT_ID,p_bckdt_per_in_ler_id);
	         fetch c_get_epe_id into l_interim_epe_id;
	         close c_get_epe_id;
	         hr_utility.set_location('Interim epe id '||l_interim_epe_id,9995);
		 g_reinstate_interim_flag := true;
		 g_reinstate_interim_chc_id := l_interim_epe_id;
		end if;
	     end if;
         /* End of Bug 8863079 */

       ben_election_information.election_information
            (p_elig_per_elctbl_chc_id => l_epe_pen_rec.elig_per_elctbl_chc_id,
             p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id,-- l_epe_pen_rec.prtt_enrt_rslt_id,
             p_effective_date         => g_sys_date,
             p_enrt_mthd_cd           => l_bckdt_pen_rec.enrt_mthd_cd,
             p_business_group_id      => p_business_group_id,
             p_enrt_bnft_id           => l_bnft_rec.enrt_bnft_id,
             p_bnft_val               => l_bnft_rec.val,
	         p_enrt_cvg_strt_dt       => l_enrt_cvg_strt_dt, -- 5746429
             p_enrt_rt_id1            => l_rt_table(1).enrt_rt_id,
             p_rt_val1                => l_rt_table(1).dflt_val,
             p_ann_rt_val1            => l_rt_table(1).ann_rt_val,
             p_enrt_rt_id2            => l_rt_table(2).enrt_rt_id,
             p_rt_val2                => l_rt_table(2).dflt_val,
             p_ann_rt_val2            => l_rt_table(2).ann_rt_val,
             p_enrt_rt_id3            => l_rt_table(3).enrt_rt_id,
             p_rt_val3                => l_rt_table(3).dflt_val,
             p_ann_rt_val3            => l_rt_table(3).ann_rt_val,
             p_enrt_rt_id4            => l_rt_table(4).enrt_rt_id,
             p_rt_val4                => l_rt_table(4).dflt_val,
             p_ann_rt_val4            => l_rt_table(4).ann_rt_val,
             p_enrt_rt_id5            => l_rt_table(5).enrt_rt_id,
             p_rt_val5                => l_rt_table(5).dflt_val,
             p_ann_rt_val5            => l_rt_table(5).ann_rt_val,
             p_enrt_rt_id6            => l_rt_table(6).enrt_rt_id,
             p_rt_val6                => l_rt_table(6).dflt_val,
             p_ann_rt_val6            => l_rt_table(6).ann_rt_val,
             p_enrt_rt_id7            => l_rt_table(7).enrt_rt_id,
             p_rt_val7                => l_rt_table(7).dflt_val,
             p_ann_rt_val7            => l_rt_table(7).ann_rt_val,
             p_enrt_rt_id8            => l_rt_table(8).enrt_rt_id,
             p_rt_val8                => l_rt_table(8).dflt_val,
             p_ann_rt_val8            => l_rt_table(8).ann_rt_val,
             p_enrt_rt_id9            => l_rt_table(9).enrt_rt_id,
             p_rt_val9                => l_rt_table(9).dflt_val,
             p_ann_rt_val9            => l_rt_table(9).ann_rt_val,
             p_enrt_rt_id10           => l_rt_table(10).enrt_rt_id,
             p_rt_val10               => l_rt_table(10).dflt_val,
             p_ann_rt_val10           => l_rt_table(10).ann_rt_val,
             p_datetrack_mode         => hr_api.g_insert, -- 99999 l_datetrack_mode,
             p_suspend_flag           => l_suspend_flag,
             p_called_from_sspnd      => 'N',
             p_prtt_enrt_interim_id   => l_prtt_enrt_interim_id,
             p_prtt_rt_val_id1        => l_prtt_rt_val_id1,
             p_prtt_rt_val_id2        => l_prtt_rt_val_id2,
             p_prtt_rt_val_id3        => l_prtt_rt_val_id3,
             p_prtt_rt_val_id4        => l_prtt_rt_val_id4,
             p_prtt_rt_val_id5        => l_prtt_rt_val_id5,
             p_prtt_rt_val_id6        => l_prtt_rt_val_id6,
             p_prtt_rt_val_id7        => l_prtt_rt_val_id7,
             p_prtt_rt_val_id8        => l_prtt_rt_val_id8,
             p_prtt_rt_val_id9        => l_prtt_rt_val_id9,
             p_prtt_rt_val_id10       => l_prtt_rt_val_id10,
           -- 6131609 : reinstate DFF values
            p_pen_attribute_category => l_bckdt_pen_rec.lcr_attribute_category,
            p_pen_attribute1  => l_bckdt_pen_rec.lcr_attribute1,
            p_pen_attribute2  => l_bckdt_pen_rec.lcr_attribute2,
            p_pen_attribute3  => l_bckdt_pen_rec.lcr_attribute3,
            p_pen_attribute4  => l_bckdt_pen_rec.lcr_attribute4,
            p_pen_attribute5  => l_bckdt_pen_rec.lcr_attribute5,
            p_pen_attribute6  => l_bckdt_pen_rec.lcr_attribute6,
            p_pen_attribute7  => l_bckdt_pen_rec.lcr_attribute7,
            p_pen_attribute8  => l_bckdt_pen_rec.lcr_attribute8,
            p_pen_attribute9  => l_bckdt_pen_rec.lcr_attribute9,
            p_pen_attribute10 => l_bckdt_pen_rec.lcr_attribute10,
            p_pen_attribute11 => l_bckdt_pen_rec.lcr_attribute11,
            p_pen_attribute12 => l_bckdt_pen_rec.lcr_attribute12,
            p_pen_attribute13 => l_bckdt_pen_rec.lcr_attribute13,
            p_pen_attribute14 => l_bckdt_pen_rec.lcr_attribute14,
            p_pen_attribute15 => l_bckdt_pen_rec.lcr_attribute15,
            p_pen_attribute16 => l_bckdt_pen_rec.lcr_attribute16,
            p_pen_attribute17 => l_bckdt_pen_rec.lcr_attribute17,
            p_pen_attribute18 => l_bckdt_pen_rec.lcr_attribute18,
            p_pen_attribute19 => l_bckdt_pen_rec.lcr_attribute19,
            p_pen_attribute20 => l_bckdt_pen_rec.lcr_attribute20,
            p_pen_attribute21 => l_bckdt_pen_rec.lcr_attribute21,
            p_pen_attribute22 => l_bckdt_pen_rec.lcr_attribute22,
            p_pen_attribute23 => l_bckdt_pen_rec.lcr_attribute23,
            p_pen_attribute24 => l_bckdt_pen_rec.lcr_attribute24,
            p_pen_attribute25 => l_bckdt_pen_rec.lcr_attribute25,
            p_pen_attribute26 => l_bckdt_pen_rec.lcr_attribute26,
            p_pen_attribute27 => l_bckdt_pen_rec.lcr_attribute27,
            p_pen_attribute28 => l_bckdt_pen_rec.lcr_attribute28,
            p_pen_attribute29 => l_bckdt_pen_rec.lcr_attribute29,
            p_pen_attribute30 => l_bckdt_pen_rec.lcr_attribute30,
            --
             p_object_version_number  => l_object_version_number,
             p_effective_start_date   => l_effective_start_date,
             p_effective_end_date     => l_effective_end_date,
             p_dpnt_actn_warning      => l_dpnt_actn_warning,
             p_bnf_actn_warning       => l_bnf_actn_warning,
             p_ctfn_actn_warning      => l_ctfn_actn_warning);
         --

         l_prtt_rt_val_table(1)       := l_prtt_rt_val_id1;
         l_prtt_rt_val_table(2)       := l_prtt_rt_val_id2;
         l_prtt_rt_val_table(3)       := l_prtt_rt_val_id3;
         l_prtt_rt_val_table(4)       := l_prtt_rt_val_id4;
         l_prtt_rt_val_table(5)       := l_prtt_rt_val_id5;
         l_prtt_rt_val_table(6)       := l_prtt_rt_val_id6;
         l_prtt_rt_val_table(7)       := l_prtt_rt_val_id7;
         l_prtt_rt_val_table(8)       := l_prtt_rt_val_id8;
         l_prtt_rt_val_table(9)       := l_prtt_rt_val_id9;
         l_prtt_rt_val_table(10)      := l_prtt_rt_val_id10;

         -- if rate is enter value at enrollment and calculation method is like multiple and
         -- calculate flag is on, first the prtt_rt_val is created with default value and
         -- subsequently the calculated value is updated by taking values from backedout rows
         for i  in 1..l_count loop
            l_upd_rt_val  := FALSE;
            open c_prv_ovn (l_prtt_rt_val_table(i));
            fetch c_prv_ovn into l_prv_ovn;
            if c_prv_ovn%found then
                if l_prv_ovn.rt_val <>l_rt_table(i).calc_val  then
                   l_upd_rt_val := TRUE;
                end if;
            end if;
            close c_prv_ovn;
            if l_upd_rt_val then
                ben_prtt_rt_val_api.update_prtt_rt_val
                  (p_prtt_rt_val_id        => l_prtt_rt_val_table(i)
                  ,p_person_id             => p_person_id
                  ,p_rt_val                => l_rt_table(i).calc_val
                  ,p_acty_ref_perd_cd      => l_prv_ovn.acty_ref_perd_cd
                  ,p_cmcd_rt_val           => l_rt_table(i).cmcd_rt_val
                  ,p_cmcd_ref_perd_cd      => l_prv_ovn.cmcd_ref_perd_cd
                  ,p_ann_rt_val            => l_rt_table(i).ann_rt_val
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => l_prv_ovn.object_version_number
                  ,p_effective_date        => g_sys_date);
                --
            end if;
         end loop;



         -- Populate the enrollment results electble choice data
         -- to be used for dependents and beneficiaries restoration.
         -- the reinstate beneficiaries and dependents processes
         -- from hare as multi row edit process may create
         -- these records as part of recycle. So reinstate beneficiaries
         -- and dependents processes should be called after multi row edits.
         --
         --
         l_found := FALSE;
         if nvl(l_enrt_table.LAST, 0) > 0 then
            for l_cnt in 1..l_enrt_table.LAST loop
                --
                if l_enrt_table(l_cnt).prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
                then
                   l_found := TRUE;
                   exit;
                end if;
                --
             end loop;
         end if;
         --
         if not l_found then
            --
            --
            l_enrt_count := nvl(l_enrt_table.LAST, 0) + 1;
            l_enrt_table(l_enrt_count).prtt_enrt_rslt_id := l_prtt_enrt_rslt_id;
            l_enrt_table(l_enrt_count).effective_start_date := l_effective_start_date;
            l_enrt_table(l_enrt_count).bckdt_prtt_enrt_rslt_id
                                             := l_bckdt_pen_rec.prtt_enrt_rslt_id;
            l_enrt_table(l_enrt_count).bckdt_enrt_ovridn_flag
                                             := l_bckdt_pen_rec.enrt_ovridn_flag;
            l_enrt_table(l_enrt_count).bckdt_enrt_cvg_strt_dt
                                             := l_bckdt_pen_rec.enrt_cvg_strt_dt;
            l_enrt_table(l_enrt_count).bckdt_enrt_cvg_thru_dt
                                             := l_bckdt_pen_rec.enrt_cvg_thru_dt;
            l_enrt_table(l_enrt_count).g_sys_date := g_sys_date;
            l_enrt_table(l_enrt_count).pen_ovn_number := l_object_version_number;
            l_enrt_table(l_enrt_count).old_pl_id := l_bckdt_pen_rec.pl_id;
            l_enrt_table(l_enrt_count).new_pl_id := l_bckdt_pen_rec.pl_id;
            l_enrt_table(l_enrt_count).old_oipl_id := l_bckdt_pen_rec.oipl_id;
            l_enrt_table(l_enrt_count).new_oipl_id := l_bckdt_pen_rec.oipl_id;
            l_enrt_table(l_enrt_count).old_pl_typ_id := l_bckdt_pen_rec.pl_typ_id;
            l_enrt_table(l_enrt_count).new_pl_typ_id := l_bckdt_pen_rec.pl_typ_id;
            l_enrt_table(l_enrt_count).pgm_id := l_bckdt_pen_rec.pgm_id;
            l_enrt_table(l_enrt_count).ler_id := null;
            l_enrt_table(l_enrt_count).elig_per_elctbl_chc_id
                                             := l_epe_pen_rec.elig_per_elctbl_chc_id;
           l_enrt_table(l_enrt_count).dpnt_cvg_strt_dt_cd
                                             := l_epe_pen_rec.dpnt_cvg_strt_dt_cd;
            l_enrt_table(l_enrt_count).dpnt_cvg_strt_dt_rl
                                             := l_epe_pen_rec.dpnt_cvg_strt_dt_rl;
            /* Trace messages for the enrollments, uncomment for tracing bugs */
            hr_utility.set_location('prtt_enrt_rslt_id = ' ||
                       l_enrt_table(l_enrt_count).prtt_enrt_rslt_id, 9999);
            hr_utility.set_location('bckdt_prtt_enrt_rslt_id = ' ||
                       l_enrt_table(l_enrt_count).bckdt_prtt_enrt_rslt_id, 9999);
            hr_utility.set_location('bckdt_enrt_ovridn_flag = ' ||
                       l_enrt_table(l_enrt_count).bckdt_enrt_ovridn_flag, 72);
            hr_utility.set_location('bckdt_enrt_cvg_strt_dt = ' ||
                       l_enrt_table(l_enrt_count).bckdt_enrt_cvg_strt_dt, 72);
            hr_utility.set_location('pen_ovn_number = ' ||
                       l_enrt_table(l_enrt_count).pen_ovn_number, 9999);
            hr_utility.set_location('old_pl_id = ' ||
                       l_enrt_table(l_enrt_count).old_pl_id, 9999);
            hr_utility.set_location('new_pl_id = ' ||
                       l_enrt_table(l_enrt_count).new_pl_id, 9999);
            hr_utility.set_location('old_oipl_id = ' ||
                       l_enrt_table(l_enrt_count).old_oipl_id, 9999);
            hr_utility.set_location('new_oipl_id = ' ||
                       l_enrt_table(l_enrt_count).new_oipl_id, 9999);
            hr_utility.set_location('old_pl_typ_id = ' ||
                       l_enrt_table(l_enrt_count).old_pl_typ_id, 9999);
            hr_utility.set_location('new_pl_typ_id = ' ||
                       l_enrt_table(l_enrt_count).new_pl_typ_id, 9999);
            hr_utility.set_location('pgm_id = ' ||
                       l_enrt_table(l_enrt_count).pgm_id, 9999);
            hr_utility.set_location('elig_per_elctbl_chc_id = ' ||
                       l_enrt_table(l_enrt_count).elig_per_elctbl_chc_id, 9999);
            /**/
            --
         end if;
         --
         -- Populate the pgm and pl tables, to pocess post results.
         --
         if l_epe_pen_rec.pgm_id is null then
            --
            l_found := FALSE;
            if nvl(l_pl_table.LAST, 0) > 0 then
               for l_cnt in 1..l_pl_table.LAST loop
                   --
                   if l_pl_table(l_cnt).pl_id = l_epe_pen_rec.pl_id and
                      l_pl_table(l_cnt).enrt_mthd_cd = l_bckdt_pen_rec.enrt_mthd_cd
                   then
                      l_found := TRUE;
                      l_pl_table(l_cnt).max_enrt_esd := greatest(l_pl_table(l_cnt).max_enrt_esd,
                                                                 g_sys_date);
                      exit;
                   end if;
                   --
               end loop;
            end if;
            --
            if not l_found then
               --
               --
               l_pl_count := nvl(l_pl_table.LAST, 0) + 1;
               l_pl_table(l_pl_count).pl_id            := l_epe_pen_rec.pl_id;
               l_pl_table(l_pl_count).enrt_mthd_cd     := l_bckdt_pen_rec.enrt_mthd_cd;
               l_pl_table(l_pl_count).multi_row_edit_done := FALSE;
               l_pl_table(l_pl_count).max_enrt_esd := g_sys_date;
               --
            end if;
         else
            --
            --
            l_found := FALSE;
            if nvl(l_pgm_table.LAST, 0) > 0 then
               for l_cnt in 1..l_pgm_table.LAST loop
                   --
                   if l_pgm_table(l_cnt).pgm_id = l_epe_pen_rec.pgm_id and
                      l_pgm_table(l_cnt).enrt_mthd_cd = l_bckdt_pen_rec.enrt_mthd_cd
                   then
                      l_found := TRUE;
                      l_pgm_table(l_cnt).max_enrt_esd := greatest(l_pgm_table(l_cnt).max_enrt_esd,
                                                                 g_sys_date);
                      exit;
                   end if;
                   --
               end loop;
            end if;
            --
            if not l_found then
               --
               --
               l_pgm_count := nvl(l_pgm_table.LAST, 0) + 1;
               l_pgm_table(l_pgm_count).pgm_id         := l_epe_pen_rec.pgm_id;
               l_pgm_table(l_pgm_count).enrt_mthd_cd   := l_bckdt_pen_rec.enrt_mthd_cd;
               l_pgm_table(l_pgm_count).multi_row_edit_done := FALSE;
               l_pgm_table(l_pgm_count).max_enrt_esd := g_sys_date;
               --
            end if;
            --
         end if;
         --
      end if;
      --
    end if;  -- l rstl exists
      --
  end loop;
  --
  -- Apply the multi row edits.
  --
  --
  if nvl(l_pgm_table.LAST, 0) > 0 then
     for l_cnt in 1..l_pgm_table.LAST loop
        --
        -- First see multi row edits are already checked.
        --
        l_found  := FALSE;
        for l_inn_cnt in 1..l_cnt loop
          if l_pgm_table(l_inn_cnt).pgm_id = l_pgm_table(l_cnt).pgm_id and
             l_pgm_table(l_inn_cnt).multi_row_edit_done
          then
             l_found  := TRUE;
             exit;
          end if;
        end loop;
        --
        if not l_found then
           --
           --
           -- Now see if there are non automatic enrollments
           --
           if l_bckdt_pil_prev_stat_cd='STRTD' then
             l_found_non_automatics:=FALSE;
             for l_inn_cnt in 1..l_pgm_table.last loop
               if l_pgm_table(l_inn_cnt).pgm_id = l_pgm_table(l_cnt).pgm_id and
                  l_pgm_table(l_inn_cnt).enrt_mthd_cd<>'A'
               then
                  l_found_non_automatics  := TRUE;
                  exit;
               end if;
             end loop;
           end if;
           --
           if l_bckdt_pil_prev_stat_cd<>'STRTD' or
              l_found_non_automatics then
             hr_utility.set_location('Date for multi row edits = ' ||
                                      l_pgm_table(l_cnt).max_enrt_esd || '  ' || ' pgm = ' ||

                                      l_pgm_table(l_cnt).pgm_id, 333);
             ben_prtt_enrt_result_api.multi_rows_edit
              (p_person_id         => p_person_id,
               p_effective_date    => l_pgm_table(l_cnt).max_enrt_esd,
               p_business_group_id => p_business_group_id,
               p_per_in_ler_id     => p_per_in_ler_id,
               p_pgm_id            => l_pgm_table(l_cnt).pgm_id);
             --
           end if;
           l_pgm_table(l_cnt).multi_row_edit_done := TRUE;
           --
        end if;
        --
     end loop;
  end if;
  --
  -- Call multi_rows_edit, process_post_results, reinstate_bpl_per_pen
  -- Only if the enrollments are reinstated.
  --
  if nvl(l_enrt_table.LAST, 0) > 0 then
     --
     -- Call multi row edits and post results only if enrollments are
     -- created.
     --
     -- Call multi row edits just as miscellanious form calls.
     --
     hr_utility.set_location('Date for multi row edits = ' ||
                              l_max_enrt_esd , 333);
     ben_prtt_enrt_result_api.multi_rows_edit
      (p_person_id         => p_person_id,
       p_effective_date    => l_max_enrt_esd,
       p_business_group_id => p_business_group_id,
       p_per_in_ler_id     => p_per_in_ler_id,
       p_pgm_id            => null);
     --
     -- Invoke post result process once for Explicit/Automatic/ Default.
     --
     ben_proc_common_enrt_rslt.process_post_results
      (p_person_id          => p_person_id,
       p_enrt_mthd_cd       => 'E',
       p_effective_date     => l_max_enrt_esd,
       p_business_group_id  => p_business_group_id,
       p_per_in_ler_id      => p_per_in_ler_id);
     --
     ben_proc_common_enrt_rslt.process_post_results
      (p_person_id          => p_person_id,
       p_enrt_mthd_cd       => 'D',
       p_effective_date     => l_max_enrt_esd,
       p_business_group_id  => p_business_group_id,
       p_per_in_ler_id      => p_per_in_ler_id);
     --
     ben_proc_common_enrt_rslt.process_post_results
      (p_person_id          => p_person_id,
       p_enrt_mthd_cd       => 'A',
       p_effective_date     => l_max_enrt_esd,
       p_business_group_id  => p_business_group_id,
       p_per_in_ler_id      => p_per_in_ler_id);
     --
  end if;
  --
  -- Apply process post enrollments once for each program.
  --
 -- Apply process post enrollments once for each program.
  --
  if nvl(l_pgm_table.LAST, 0) > 0 then
     for l_cnt in 1..l_pgm_table.LAST loop
        --
        --RCHASE - ensure automatics are handled differently than
        --         form enrollments by process_post_enrollment
        -- Bug 5623259.
        --
        if l_pgm_table(l_cnt).enrt_mthd_cd = 'E' then
           l_proc_cd := 'FORMENRT';
        elsif l_pgm_table(l_cnt).enrt_mthd_cd = 'D' then
           l_proc_cd := 'DFLTENRT';
        else
           l_proc_cd := NULL;
        end if;
        ben_proc_common_enrt_rslt.process_post_enrollment
          (p_per_in_ler_id     => p_per_in_ler_id,
           p_pgm_id            => l_pgm_table(l_cnt).pgm_id,
           p_pl_id             => null,
           p_enrt_mthd_cd      => l_pgm_table(l_cnt).enrt_mthd_cd,
           p_cls_enrt_flag     => FALSE,
           --RCHASE
           p_proc_cd           => l_proc_cd,--'FORMENRT',
           p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => l_pgm_table(l_cnt).max_enrt_esd );
        --
      end loop;
  end if;
  --
  -- Apply process post enrollments once for each program.
  --
  --
  if nvl(l_pl_table.LAST, 0) > 0 then
     for l_cnt in 1..l_pl_table.LAST loop
        --
        -- Invoke post result process
        --
        hr_utility.set_location('Date = ' || l_pl_table(l_cnt).max_enrt_esd, 333);
        hr_utility.set_location('PL = ' || l_pl_table(l_cnt).pl_id, 333);
        --RCHASE - ensure automatics are handled differently than
        --         form enrollments by process_post_enrollment
        -- Bug 5623259.
        --
        if l_pl_table(l_cnt).enrt_mthd_cd = 'E' then
           l_proc_cd := 'FORMENRT';
        elsif l_pl_table(l_cnt).enrt_mthd_cd = 'D' then
           l_proc_cd := 'DFLTENRT';
        else
           l_proc_cd := NULL;
        end if;
        ben_proc_common_enrt_rslt.process_post_enrollment
          (p_per_in_ler_id     => p_per_in_ler_id,
           p_pgm_id            => null,
           p_pl_id             => l_pl_table(l_cnt).pl_id,
           p_enrt_mthd_cd      => l_pl_table(l_cnt).enrt_mthd_cd,
           p_cls_enrt_flag     => FALSE,
           --RCHASE
           p_proc_cd           => l_proc_cd,--'FORMENRT',
           p_person_id         => p_person_id,
           p_business_group_id => p_business_group_id,
           p_effective_date    => l_pl_table(l_cnt).max_enrt_esd );
        --
      end loop;
  end if;
  if nvl(l_enrt_table.LAST, 0) > 0 then
     --
     -- Reinstate the ledgers if any created.
     --
     reinstate_bpl_per_pen(
         p_person_id              => p_person_id
         ,p_business_group_id      => p_business_group_id
         ,p_effective_date         => p_effective_date
         ,p_per_in_ler_id          => p_per_in_ler_id
         ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
         );
     --
     for l_cnt in 1..l_enrt_table.LAST loop
       --
       -- Reinstate the enrollment beneficiary rows.
       --
       hr_utility.set_location('Enrt Date = ' ||
                                l_enrt_table(l_cnt).effective_start_date, 333);
hr_utility.set_location('Reinstate the enrollment beneficiary rows',14);
       reinstate_pbn_per_pen(
         p_person_id                => p_person_id
         ,p_bckdt_prtt_enrt_rslt_id
                                    => l_enrt_table(l_cnt).bckdt_prtt_enrt_rslt_id
         ,p_prtt_enrt_rslt_id       => l_enrt_table(l_cnt).prtt_enrt_rslt_id
         ,p_rslt_object_version_number => l_enrt_table(l_cnt).pen_ovn_number
         ,p_business_group_id        => p_business_group_id
         ,p_per_in_ler_id            => p_per_in_ler_id
         ,p_effective_date           => l_enrt_table(l_cnt).effective_start_date
         ,p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id
         );
       --
       -- Reinstate the covered dependents.
       --
       reinstate_dpnts_per_pen(
               p_person_id                 => p_person_id
               ,p_bckdt_prtt_enrt_rslt_id  => l_enrt_table(l_cnt).bckdt_prtt_enrt_rslt_id
               ,p_prtt_enrt_rslt_id        => l_enrt_table(l_cnt).prtt_enrt_rslt_id
               ,p_pen_ovn_number           => l_enrt_table(l_cnt).pen_ovn_number
               ,p_old_pl_id                => l_enrt_table(l_cnt).old_pl_id
               ,p_new_pl_id                => l_enrt_table(l_cnt).new_pl_id
               ,p_old_oipl_id              => l_enrt_table(l_cnt).old_oipl_id
               ,p_new_oipl_id              => l_enrt_table(l_cnt).new_oipl_id
               ,p_old_pl_typ_id            => l_enrt_table(l_cnt).old_pl_typ_id
               ,p_new_pl_typ_id            => l_enrt_table(l_cnt).new_pl_typ_id
               ,p_pgm_id                   => l_enrt_table(l_cnt).pgm_id
               ,p_ler_id                   => l_enrt_table(l_cnt).ler_id
               ,p_elig_per_elctbl_chc_id   => l_enrt_table(l_cnt).elig_per_elctbl_chc_id
               ,p_business_group_id        => p_business_group_id
               -- # 2508745
               ,p_effective_date           => nvl(l_enrt_table(l_cnt).effective_start_date,
                                                    p_effective_date)
               ,p_per_in_ler_id            => p_per_in_ler_id
               ,p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id
               ,p_dpnt_cvg_strt_dt_cd      => l_enrt_table(l_cnt).dpnt_cvg_strt_dt_cd
               ,p_dpnt_cvg_strt_dt_rl      => l_enrt_table(l_cnt).dpnt_cvg_strt_dt_rl
               ,p_enrt_cvg_strt_dt         => null -- 9999 this should be fetched from base table
               );
        --
        -- Reinstate the enrollment certifications.
        --
       -- Reinstate the enrollment certifications.
        --
        reinstate_pcs_per_pen(
               p_person_id                 => p_person_id
               ,p_bckdt_prtt_enrt_rslt_id  => l_enrt_table(l_cnt).bckdt_prtt_enrt_rslt_id
               ,p_prtt_enrt_rslt_id        => l_enrt_table(l_cnt).prtt_enrt_rslt_id
               ,p_rslt_object_version_number => l_enrt_table(l_cnt).prtt_enrt_rslt_id
               ,p_business_group_id        => p_business_group_id
               ,p_prtt_enrt_actn_id        => null
               ,p_effective_date           => l_enrt_table(l_cnt).effective_start_date
               ,p_bckdt_prtt_enrt_actn_id  => null
               ,p_per_in_ler_id          => p_per_in_ler_id
               ,p_bckdt_per_in_ler_id    => p_bckdt_per_in_ler_id
               );
       --
       -- Reinstate the action items.
       --
       reinstate_pea_per_pen(
                 p_person_id                => p_person_id
                ,p_bckdt_prtt_enrt_rslt_id  => l_enrt_table(l_cnt).bckdt_prtt_enrt_rslt_id
                ,p_prtt_enrt_rslt_id        => l_enrt_table(l_cnt).pen_ovn_number
                ,p_rslt_object_version_number => l_enrt_table(l_cnt).prtt_enrt_rslt_id
                ,p_business_group_id        => p_business_group_id
                ,p_per_in_ler_id            => p_per_in_ler_id
                ,p_effective_date           => l_enrt_table(l_cnt).effective_start_date
                ,p_bckdt_per_in_ler_id      => p_bckdt_per_in_ler_id
                );
     end loop;
  end if;
 -- If any of the backed out enrt rslts were overriden, then update the new
  -- rslts with the overriden data.
  --
  if nvl(l_enrt_table.last, 0) > 0 then
    --
    for i in 1..l_enrt_table.last loop
      --
      if l_enrt_table(i).bckdt_enrt_ovridn_flag = 'Y' then
        --
        hr_utility.set_location('Restoring the overriden result: ' ||
                                l_enrt_table(i).bckdt_prtt_enrt_rslt_id, 72);
        --
        -- Get the latest object version number as the post enrollment process
        -- may have updated the new enrt result.
        --
        open c_ovn(l_enrt_table(i).prtt_enrt_rslt_id);
        fetch c_ovn into l_ovn;
        close c_ovn;
        --
        ben_prtt_enrt_result_api.update_prtt_enrt_result
          (p_prtt_enrt_rslt_id      => l_enrt_table(i).prtt_enrt_rslt_id
          ,p_effective_start_date   => l_esd_out
          ,p_effective_end_date     => l_eed_out
          ,p_enrt_cvg_strt_dt       => l_enrt_table(i).bckdt_enrt_cvg_strt_dt
          ,p_enrt_cvg_thru_dt       => l_enrt_table(i).bckdt_enrt_cvg_thru_dt
          ,p_enrt_ovridn_flag       => 'Y'
          ,p_object_version_number  => l_ovn
          ,p_effective_date         => l_enrt_table(i).g_sys_date
          ,p_datetrack_mode         => hr_api.g_correction
          ,p_multi_row_validate     => FALSE);
        --
      end if;
      --
    -- Bug 2677804 changed the cursor
      -- We need to see the overriden thru date also.
      for l_rt_rec in c_ovridn_rt(l_enrt_table(i).bckdt_prtt_enrt_rslt_id
                                 ,l_enrt_table(i).prtt_enrt_rslt_id )
      loop
        --
        hr_utility.set_location('Updating new prv: ' || l_rt_rec.new_prv_id ||
                                ' with overriden prv_id: ' ||
                                l_rt_rec.prtt_rt_val_id, 72);
        --
        ben_prtt_rt_val_api.update_prtt_rt_val
          (p_prtt_rt_val_id        => l_rt_rec.new_prv_id
          ,p_person_id             => p_person_id
          ,p_rt_strt_dt            => l_rt_rec.rt_strt_dt
          ,p_rt_val                => l_rt_rec.rt_val
          ,p_acty_ref_perd_cd      => l_rt_rec.acty_ref_perd_cd
          ,p_cmcd_rt_val           => l_rt_rec.cmcd_rt_val
          ,p_cmcd_ref_perd_cd      => l_rt_rec.cmcd_ref_perd_cd
          ,p_ann_rt_val            => l_rt_rec.ann_rt_val
          ,p_rt_ovridn_flag        => l_rt_rec.rt_ovridn_flag
          ,p_rt_ovridn_thru_dt     => l_rt_rec.rt_ovridn_thru_dt
          ,p_business_group_id     => p_business_group_id
          ,p_object_version_number => l_rt_rec.new_prv_ovn
          ,p_effective_date        => l_enrt_table(i).g_sys_date);
        --
      end loop;
    -- Check if there are any dependents that are overriden and update the new
      -- elig_cvrd_dpnt records with the overriden values.
      --
      for l_dpnt_rec in c_ovridn_dpnt(l_enrt_table(i).bckdt_prtt_enrt_rslt_id
                                     ,l_enrt_table(i).prtt_enrt_rslt_id
                                     ,l_enrt_table(i).g_sys_date)
      loop
        --
        hr_utility.set_location('Updating new ecd with overriden ecd_id: ' ||
                                l_dpnt_rec.elig_cvrd_dpnt_id, 72);
        --
        ben_elig_cvrd_dpnt_api.update_elig_cvrd_dpnt
          (p_elig_cvrd_dpnt_id     => l_dpnt_rec.new_pdp_id
          ,p_effective_start_date  => l_esd_out
          ,p_effective_end_date    => l_eed_out
          ,p_cvg_strt_dt           => l_dpnt_rec.cvg_strt_dt
          ,p_cvg_thru_dt           => l_dpnt_rec.cvg_thru_dt
          ,p_ovrdn_flag            => l_dpnt_rec.ovrdn_flag
          ,p_ovrdn_thru_dt         => l_dpnt_rec.ovrdn_thru_dt
          ,p_object_version_number => l_dpnt_rec.new_pdp_ovn
          ,p_datetrack_mode        => hr_api.g_correction
          ,p_effective_date        => l_enrt_table(i).g_sys_date);
        --
      end loop;
      --
    end loop;
    --
  end if;
  --
  -- Call the Close enrollement process if the
  -- backed out pil's status is PROCD.
  -- backed out pil's status is PROCD.
  --
  --if l_cls_enrt_flag then
   /*Bug 8807327: Added 'if' condition. While backing out the LE,if previous LE does not have
   electability and no enrollments results then previous LE status will not be updated to 'STRTD' status.
   So there is no need to force close the previous LE*/
      if ( ben_back_out_life_event.g_no_reopen_flag = 'N') then
        ben_close_enrollment.close_single_enrollment
                      (p_per_in_ler_id      => p_per_in_ler_id
                      ,p_effective_date     => nvl(l_max_enrt_esd,p_effective_date)
                      ,p_business_group_id  => p_business_group_id
                      ,p_close_cd           => 'FORCE'
                      ,p_validate           => FALSE
                      ,p_close_uneai_flag     => NULL
                      ,p_uneai_effective_date => NULL);
     end if;
     --
  --end if;
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
  --
end reinstate_the_prev_enrt_rslt;
--


/*Enhancement Bug No: 8716679:  Added Function
to check whether the enrollment that is being reinstated is already
defaulted or carry forwarded. If function returns 'Y', then the enrollment
will not reinstated*/
function check_pl_typ_defaulted(p_pl_typ_id in number,
                               p_pgm_id in number
			       ) return varchar2 is

 l_proc  varchar2(72) := g_package||'.check_pl_typ_defaulted';
l_flag varchar2(1) := 'N';
cursor c_epe_det(c_elig_per_elctbl_chc_id number) is
select pgm_id,pl_typ_id from
	ben_elig_per_elctbl_chc
	where elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id;
l_epe_rec c_epe_det%rowtype;
begin
    hr_utility.set_location ('Entering '||l_proc,10);
    hr_utility.set_location ('p_pl_typ_id '||p_pl_typ_id,10);
    hr_utility.set_location ('p_pgm_id '||p_pgm_id,10);
    for l_cnt in 1..g_reinstated_defaults.LAST loop
	    open c_epe_det(g_reinstated_defaults(l_cnt));
	    fetch c_epe_det into l_epe_rec;
	    close c_epe_det;

	    if( nvl(l_epe_rec.pgm_id,-1) = nvl(p_pgm_id,-1) and l_epe_rec.pl_typ_id = p_pl_typ_id) then
	     l_flag := 'Y' ;
	     hr_utility.set_location ('Leaving '||l_proc,11);
	     return l_flag;
	     exit;
	    end if;
   end loop;
   hr_utility.set_location ('Leaving '||l_proc,12);
   return l_flag;
end check_pl_typ_defaulted;

/*Enhancement Bug No: 8716679:  Added Function to
determine whether to call defaults of not.
Reprocess the backedout LE. Now backout the LE to Unprocessed state,
backout the intervening LE and now reprocess the backed LE. In this case
defaults should be applied. Reinstating the enrollments doesn't make
sense as it was an election that was reversed/backed out.
*/
function call_defaults(p_per_in_ler_id in number,
                       p_bckdt_per_in_ler_id in number,
		       p_effective_date date,
		       p_person_id number
			       ) return varchar2 is

l_proc  varchar2(72) := g_package||'call_defaults';
l_flag varchar2(1) := 'N';
l_intv_pil_id number;

 cursor c_int_pil_id is
  select pil1.bckt_per_in_ler_id
         from ben_per_in_ler pil,ben_per_in_ler pil1
         where pil.per_in_ler_id = p_bckdt_per_in_ler_id
               and pil.ptnl_ler_for_per_id = pil1.ptnl_ler_for_per_id
               and pil1.bckt_per_in_ler_id is not null
	       order by pil.lf_evt_ocrd_dt asc;

cursor c_bckdt_pil_id is
select pil.bckt_per_in_ler_id
         from ben_per_in_ler pil
         where pil.per_in_ler_id = p_bckdt_per_in_ler_id;

l_bckdt_pil_id number;

cursor c_future_pil is
       select pil.per_in_ler_id
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.per_in_ler_id not in (p_per_in_ler_id,p_bckdt_per_in_ler_id)
    and    pil.person_id     = p_person_id
    and    pil.ler_id        = ler.ler_id
    and    p_effective_date between
           ler.effective_start_date and ler.effective_end_date
    and    ler.typ_cd not in ('IREC', 'SCHEDDU', 'COMP', 'GSP', 'ABS')
    and    pil.per_in_ler_stat_cd not in('BCKDT', 'VOIDD')
    and    pil.lf_evt_ocrd_dt in (select lf_evt_ocrd_dt
				 from ben_per_in_ler pil2,
				      ben_ler_f ler1
				 where pil2.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
				    and pil2.person_id = p_person_id
				    and    pil2.ler_id        = ler1.ler_id
				    and    p_effective_date between
					   ler1.effective_start_date and ler1.effective_end_date
				    and    ler1.typ_cd not in ('IREC', 'SCHEDDU', 'COMP', 'GSP', 'ABS')
				    and pil2.lf_evt_ocrd_dt > (select lf_evt_ocrd_dt from ben_per_in_ler pil3 where
							      per_in_ler_id = l_intv_pil_id)
				    and pil2.lf_evt_ocrd_dt < (select lf_evt_ocrd_dt from ben_per_in_ler pil3 where
							      per_in_ler_id = p_bckdt_per_in_ler_id)
                                )
   order by pil.lf_evt_ocrd_dt desc;

  cursor c_chk_intevent_bckdt(c_pil_id number) is
  select 'Y'
        from ben_per_in_ler pil
	where pil.per_in_ler_id = c_pil_id
	      and pil.per_in_ler_stat_cd in('BCKDT', 'VOIDD');


l_bckdt_flag varchar2(1) default 'N';
l_lt_prev_pil number;
l_dummy varchar2(1);

begin
hr_utility.set_location ('Entering '||l_proc,10);

open c_int_pil_id;
fetch c_int_pil_id into l_intv_pil_id;
close c_int_pil_id;
hr_utility.set_location ('l_intv_pil_id '||l_intv_pil_id,10);

open c_bckdt_pil_id;
fetch c_bckdt_pil_id into l_bckdt_pil_id;
close c_bckdt_pil_id;

if(l_bckdt_pil_id is not null) then
  hr_utility.set_location ('Backedout and reporcessing ',10);
  return 'N';
end if;

if(l_intv_pil_id is null) then
   hr_utility.set_location ('leaving4 '||l_proc,10);
  return 'N';
 else
   open c_future_pil;
   fetch c_future_pil into l_lt_prev_pil;
   hr_utility.set_location ('l_lt_prev_pil '||l_lt_prev_pil,10);
   if(c_future_pil%notfound) then
      close c_future_pil;
      open c_chk_intevent_bckdt(l_intv_pil_id);
      fetch c_chk_intevent_bckdt into l_dummy;
      if(c_chk_intevent_bckdt%notfound) then
        close c_chk_intevent_bckdt;
        l_flag := 'N';
      else
        close c_chk_intevent_bckdt;
	hr_utility.set_location ('leaving2 '||l_proc,10);
        l_flag := 'Y';
      end if;
    else
      close c_future_pil;
      hr_utility.set_location ('leaving3 '||l_proc,10);
      l_flag := 'N';
   end if;
 end if;
hr_utility.set_location ('leaving '||l_proc,10);
return l_flag;
end call_defaults;

end ben_lf_evt_clps_restore;

/

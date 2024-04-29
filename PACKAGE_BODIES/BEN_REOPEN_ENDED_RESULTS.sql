--------------------------------------------------------
--  DDL for Package Body BEN_REOPEN_ENDED_RESULTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_REOPEN_ENDED_RESULTS" as
/* $Header: benreopn.pkb 120.7.12010000.4 2008/09/02 14:28:57 bachakra ship $ */
---
-- Package Variables
--
g_package  varchar2(300) := 'ben_reopen_ended_results.';
g_debug boolean := hr_utility.debug_enabled;
--
-- bug 6127624 added
FUNCTION check_prev_eligible (
   p_person_id           IN   NUMBER,
   p_pgm_id              IN   NUMBER,
   p_pl_id               IN   NUMBER,
   p_oipl_id             IN   NUMBER,
   p_effective_date      IN   DATE,
   p_business_group_id   IN   NUMBER,
   p_per_in_ler_id       IN   NUMBER
)
   RETURN BOOLEAN
IS
   CURSOR csr_opt
   IS
      SELECT opt_id
        FROM ben_oipl_f
       WHERE oipl_id = p_oipl_id
         AND p_effective_date BETWEEN effective_start_date AND effective_end_date;

   l_opt_id                  ben_opt_f.opt_id%TYPE;

   ---
   ---
   CURSOR csr_prev_opt_elig_check (
      c_person_id        IN   NUMBER,
      c_effective_date   IN   DATE,
      c_pl_id            IN   NUMBER,
      c_opt_id           IN   NUMBER,
      c_pgm_id           IN   NUMBER
   )
   IS
      SELECT   epo.elig_flag
          FROM ben_elig_per_opt_f epo, ben_per_in_ler pil, ben_elig_per_f pep
         WHERE pep.person_id = c_person_id
           AND pep.pl_id = c_pl_id
           AND epo.opt_id = c_opt_id
           AND pep.elig_per_id = epo.elig_per_id
					 AND NVL(pep.pgm_id,-1) = NVL(c_pgm_id,-1)
           AND epo.effective_start_date BETWEEN pep.effective_start_date
                                            AND pep.effective_end_date
           AND epo.effective_start_date < c_effective_date
           AND epo.per_in_ler_id <> p_per_in_ler_id
           AND pil.per_in_ler_id = epo.per_in_ler_id
           AND pil.business_group_id = epo.business_group_id
           AND pil.per_in_ler_stat_cd IN ('STRTD', 'PROCD')
      ORDER BY epo.effective_start_date DESC;

   rec_prev_opt_elig_check   csr_prev_opt_elig_check%ROWTYPE;

   ---
   ---
   CURSOR csr_prev_elig_check (
      c_person_id        IN   NUMBER,
      c_pgm_id           IN   NUMBER,
      c_pl_id            IN   NUMBER,
      c_ptip_id          IN   NUMBER,
      c_effective_date   IN   DATE
   )
   IS
      SELECT   pep.elig_flag
          FROM ben_elig_per_f pep, ben_per_in_ler pil
         WHERE pep.person_id = c_person_id
           AND NVL (pep.pgm_id, -1) = NVL (c_pgm_id, -1)
           -- bug 5947036/ bug 6379215
           AND pep.pl_id = c_pl_id
           -- AND NVL (pep.pl_id, -1) = c_pl_id
           --AND pep.plip_id IS NULL
           --AND NVL (pep.ptip_id, -1) = nvl(c_ptip_id,-1)
           AND pep.effective_start_date < c_effective_date
           AND pep.per_in_ler_id <> p_per_in_ler_id
           AND pil.per_in_ler_id = pep.per_in_ler_id
           AND pil.business_group_id = pep.business_group_id
           AND pil.per_in_ler_stat_cd IN ('STRTD', 'PROCD')
      ORDER BY pep.effective_start_date DESC;

   rec_prev_elig_check       csr_prev_elig_check%ROWTYPE;
   ---
   l_return                  BOOLEAN                                  := FALSE;
   l_epo_row                 ben_derive_part_and_rate_facts.g_cache_structure;
   l_pep_row                 ben_derive_part_and_rate_facts.g_cache_structure;
   l_proc                    VARCHAR2 (100)
                                         := g_package || 'check_prev_eligible';
BEGIN
   IF g_debug
   THEN
      hr_utility.set_location ('Entering ' || l_proc, 121);
      hr_utility.set_location ('p_person_id ' || p_person_id, 121);
      hr_utility.set_location ('p_pgm_id ' || p_pgm_id, 121);
      hr_utility.set_location ('p_pl_id ' || p_pl_id, 121);
      hr_utility.set_location ('p_oipl_id ' || p_oipl_id, 121);
      hr_utility.set_location ('p_business_group_id ' || p_business_group_id,
                               121
                              );
      hr_utility.set_location (   'p_effective_date '
                               || TO_CHAR (p_effective_date, 'YYYY/MM/DD'),
                               121
                              );
      hr_utility.set_location ('p_per_in_ler_id ' || p_per_in_ler_id, 121);
   END IF;

   IF p_oipl_id IS NOT NULL
   THEN
      OPEN csr_opt;

      FETCH csr_opt
       INTO l_opt_id;

      CLOSE csr_opt;

      OPEN csr_prev_opt_elig_check (p_person_id,
                                    p_effective_date,
                                    p_pl_id,
                                    l_opt_id,
                                    p_pgm_id
                                   );

      FETCH csr_prev_opt_elig_check
       INTO rec_prev_opt_elig_check;

      CLOSE csr_prev_opt_elig_check;

      IF rec_prev_opt_elig_check.elig_flag = 'Y'
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('oipl elig ', 121);
         END IF;

         l_return := TRUE;
      END IF;
   ELSE
      OPEN csr_prev_elig_check (
                               p_person_id,
                               p_pgm_id,
                               p_pl_id,
                               null,
                               p_effective_date
                               );
      FETCH csr_prev_elig_check
       INTO rec_prev_elig_check;

      CLOSE csr_prev_elig_check;

      IF rec_prev_opt_elig_check.elig_flag = 'Y'
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('pl elig', 121);
         END IF;

         l_return := TRUE;
      END IF;
   END IF;

   hr_utility.set_location ('Leaving ' || l_proc, 121);
   RETURN l_return;
EXCEPTION
   WHEN OTHERS
   THEN
      hr_utility.set_location (SQLERRM, -121);
      hr_utility.set_location ('Leaving ' || l_proc, -121);
      RAISE;
END check_prev_eligible;




PROCEDURE reopen_routine (p_per_in_ler_id  IN number,
                          p_business_group_id IN number,
                          p_lf_evt_ocrd_dt  in date,
                          p_person_id   in number,
                          p_effective_date in date) is
 --

 CURSOR csr_electable_epes
   IS
      SELECT elig_per_elctbl_chc_id,
             pl_id,
             pgm_id,
             oipl_id
        FROM ben_elig_per_elctbl_chc
       WHERE per_in_ler_id = p_per_in_ler_id AND elctbl_flag = 'Y';

  l_rec_electable_epes csr_electable_epes%rowtype;
 --
 cursor c_ended_result (p_per_in_ler_id number,
                        p_business_group_id number) is
   select pen.*
   from ben_prtt_enrt_rslt_f pen,
        ben_elig_per_elctbl_chc epe
   where pen.prtt_enrt_rslt_stat_cd is null
   and   pen.effective_end_date = hr_api.g_eot
   and   pen.enrt_cvg_thru_dt <> hr_api.g_eot
   and   pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id
   and   pen.per_in_ler_id <> p_per_in_ler_id  -- 5365585 . result ended in the same life event will not be picked up .
   and   epe.per_in_ler_id = p_per_in_ler_id
   and   epe.CRNTLY_ENRD_FLAG = 'Y'
-- and   epe.ELCTBL_FLAG = 'Y'
   and   epe.BUSINESS_GROUP_ID = p_business_group_id
   --Bug 5102337. we need to exclude interim enrollments being selected here.
   and not exists ( select 'x'
                  from ben_prtt_enrt_rslt_f susp
                 where susp.RPLCS_SSPNDD_RSLT_ID = pen.prtt_enrt_rslt_id
                   and susp.effective_end_date <> hr_api.g_eot
                   and susp.prtt_enrt_rslt_stat_cd is null
                   and susp.enrt_cvg_thru_dt = hr_api.g_eot ) ;
 -- bug#5345189
 cursor c_future_results (p_person_id in number,
                         p_enrt_cvg_thru_dt  in date,
                         p_pgm_id            in number,
                         p_pl_id             in number,
                         p_oipl_id           in number,
                         p_pl_typ_id         in number,
                         p_business_group_id in number) is

  select  pen.*
  from    ben_prtt_enrt_rslt_f pen,
          ben_per_in_ler       pil
  where   pen.person_id  = p_person_id
  and     pen.effective_end_date = hr_api.g_eot
  and     pen.business_group_id = p_business_group_id
  and     pil.business_group_id = p_business_group_id
  and     pen.enrt_cvg_strt_dt > p_enrt_cvg_thru_dt
  and     pen.per_in_ler_id  = pil.per_in_ler_id
  and     pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
  and     nvl(pen.pgm_id,-1) = nvl(p_pgm_id,-1)
  and     pen.pl_typ_id       = p_pl_typ_id         -- 5376652
  --and     nvl(pen.oipl_id,-1) = nvl(p_oipl_id,-1) -- 5376652
  and     pen.prtt_enrt_rslt_stat_cd is null;


 --
  cursor c_pl_typ (p_per_in_ler_id number) is
    select epe.pgm_id,
           epe.pl_typ_id
    from ben_elig_per_elctbl_chc epe
    where epe.per_in_ler_id = p_per_in_ler_id
    and   epe.pgm_id is not null
    and   epe.business_group_id = p_business_group_id
    group by pgm_id, pl_typ_id;
 --
  cursor c_ended_prv (p_per_in_ler_id number,
                      p_person_id  number,
                      p_pgm_id  number) is
   select prv.*
   from ben_prtt_rt_val prv
   where prv.prtt_enrt_rslt_id in
             (select pen.prtt_enrt_rslt_id
              from ben_prtt_enrt_rslt_f pen
              where pen.effective_end_date = hr_api.g_eot
              and   pen.enrt_cvg_thru_dt <> hr_api.g_eot
              and   pen.person_id = p_person_id
              and   pen.pgm_id <> p_pgm_id
              and   pen.enrt_cvg_thru_dt < p_lf_evt_ocrd_dt
              and   pen.prtt_enrt_rslt_stat_cd is null
              and   pen.per_in_ler_id = p_per_in_ler_id
              and   pen.business_group_id = p_business_group_id
              and   not exists (select null from ben_elig_per_elctbl_chc
                     where per_in_ler_id = p_per_in_ler_id
                     and   pgm_id = pen.pgm_id))
   and prv.prtt_rt_val_stat_cd is null;

  cursor c_ended_result2(p_lf_evt_ocrd_dt date,
                         p_pl_typ_id   number,
                         p_person_id   number,
                         p_business_group_id  number,
                         p_pgm_id  number)  is
   select pen.*
   from ben_prtt_enrt_rslt_f pen
   where pen.effective_end_date = hr_api.g_eot
   and   pen.enrt_cvg_thru_dt <> hr_api.g_eot
   and   pen.person_id = p_person_id
   and   pen.pgm_id <> p_pgm_id
   and   pen.pl_typ_id = p_pl_typ_id
   and   p_lf_evt_ocrd_dt between pen.enrt_cvg_strt_dt  and
         pen.enrt_cvg_thru_dt
   and   pen.prtt_enrt_rslt_stat_cd is null
   and   pen.per_in_ler_id <> p_per_in_ler_id
   and   pen.business_group_id = p_business_group_id
   and   not exists (select null from ben_elig_per_elctbl_chc
                     where per_in_ler_id = p_per_in_ler_id
                     and   pgm_id = pen.pgm_id);
  --
  cursor c_pen (p_prtt_enrt_rslt_id number) is
    select pen.effective_start_date,
           pen.object_version_number
    from ben_prtt_enrt_rslt_f pen
    where pen.effective_end_date = hr_api.g_eot
    and   pen.prtt_enrt_rslt_stat_cd is null
    and   pen.business_group_id = p_business_group_id
    and   pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id;
  --
  cursor c_prv (p_per_in_ler_id  number,
                p_acty_base_rt_id  number,
                p_prtt_enrt_rslt_id  number) is
    select prv.*
    from ben_prtt_rt_val prv
    where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and   prv.ended_per_in_ler_id  = p_per_in_ler_id
    and   prv.acty_base_rt_id  = p_acty_base_rt_id
    and   prv.prtt_rt_val_stat_cd is not null;
  -- 5376652
  cursor c_epe (p_per_in_ler_id number,
                p_prtt_enrt_rslt_id  number) is
   select elig_per_elctbl_chc_id
   from   ben_elig_per_elctbl_chc epe
   where  epe.per_in_ler_id in (select per_in_ler_id
                                from ben_prtt_enrt_rslt_f
                                where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id)
   and    epe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id;
  --
  cursor c_get_prior_per_in_ler is
   select 'Y'
   from   ben_per_in_ler pil
   where  pil.per_in_ler_id <> p_per_in_ler_id
   and trunc(p_lf_evt_ocrd_dt, 'MM') = trunc(pil.lf_evt_ocrd_dt, 'MM')
   and    pil.person_id = p_person_id
   and    pil.business_group_id = p_business_group_id
   and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor c_get_enrt_rslts(p_rt_end_dt date
                         ,p_ptip_id   number
                          ) is
   select prv.*
         ,abr.element_type_id
         ,abr.input_value_id
         ,pen.person_id
   from ben_prtt_enrt_rslt_f pen
       ,ben_prtt_rt_val prv
       ,ben_acty_base_rt_f abr
   where pen.effective_end_date = hr_api.g_eot
   and   pen.enrt_cvg_thru_dt <> hr_api.g_eot
   and   pen.prtt_enrt_rslt_stat_cd is null
   and   pen.person_id =  p_person_id
   and   pen.business_group_id = p_business_group_id
   and   pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
   and   pen.ptip_id = p_ptip_id
   and   prv.prtt_rt_val_stat_cd is null
   and   prv.rt_end_dt >=  p_rt_end_dt
   and   prv.acty_base_rt_id = abr.acty_base_rt_id
   and   p_effective_date between abr.effective_start_date
                  and abr.effective_end_date;
  --
  -- Added for bug 7206471
  --
  cursor c_get_enrt_rslts_for_pen(p_cvg_end_dt date
                         ,p_ptip_id   number
                          ) is
   select pen.*
   from ben_prtt_enrt_rslt_f pen
       ,ben_ptip_f ptip
   where pen.effective_end_date = hr_api.g_eot -- '31-dec-4712'
   and   pen.enrt_cvg_thru_dt <> hr_api.g_eot -- '31-dec-4712'
   and   pen.prtt_enrt_rslt_stat_cd is null
   and   pen.person_id =  p_person_id -- 318321
   and   pen.business_group_id = p_business_group_id -- 81545
   and   pen.ptip_id = p_ptip_id -- 54444
   and   pen.enrt_cvg_thru_dt >=  p_cvg_end_dt -- '20-jan-2008'
   and   pen.ptip_id = ptip.ptip_id
   and   p_effective_date between ptip.effective_start_date
                  and ptip.effective_end_date;
  -- End bug 7206471
  --
  cursor c_get_pgm is
  select distinct epe.pgm_id
  from ben_elig_per_elctbl_chc epe
  where epe.per_in_ler_id = p_per_in_ler_id;
  --
  -- Get program extra info to determine if rates should be adjusted.
  --
  cursor c_get_pgm_extra_info(p_pgm_id number) is
  select pgi_information1
  from ben_pgm_extra_info
  where information_type = 'ADJ_RATE_PREV_LF_EVT'
  and pgm_id = p_pgm_id;
  --
  -- Added for bug 7206471
  --
  cursor c_get_pgm_extra_info_cvg(p_pgm_id number) is
  select pgi_information1
  from ben_pgm_extra_info
  where information_type = 'ADJ_CVG_PREV_LF_EVT'
  and pgm_id = p_pgm_id;
  --
  -- Ended bug 7206471
  --
  cursor c_get_elctbl_chc is
   select min(ecr.rt_strt_dt) rt_strt_dt
         ,epe.ptip_id
   from ben_elig_per_elctbl_chc  epe
       ,ben_enrt_rt ecr
       ,ben_enrt_bnft enb
   where epe.per_in_ler_id = p_per_in_ler_id
   and   epe.business_group_id = p_business_group_id
   and   decode(ecr.enrt_bnft_id, null, ecr.elig_per_elctbl_chc_id,
         enb.elig_per_elctbl_chc_id) = epe.elig_per_elctbl_chc_id
   and   enb.enrt_bnft_id (+) = ecr.enrt_bnft_id
   and   ecr.rt_strt_dt is not null
   and   ecr.business_group_id = p_business_group_id
   group by epe.ptip_id;
  --
  -- Added for bug 7206471
  --
  cursor c_get_elctbl_chc_for_cvg is
   select min(epe.enrt_cvg_strt_dt) enrt_cvg_strt_dt
         ,epe.ptip_id
   from ben_elig_per_elctbl_chc  epe
   where epe.per_in_ler_id = p_per_in_ler_id
   and   epe.business_group_id = p_business_group_id
   group by epe.ptip_id;
   --
   --End bug 7206471
   --
  cursor c_prtt_rt_val_adj (p_per_in_ler_id number,
                            p_prtt_rt_val_id number) is
   select null
   from ben_le_clsn_n_rstr
   where BKUP_TBL_TYP_CD = 'BEN_PRTT_RT_VAL_ADJ'
   AND   BKUP_TBL_ID = p_prtt_rt_val_id
   AND   PER_IN_LER_ID  = p_per_in_ler_id;
  --
  -- Added for bug 7206471
  --
  cursor c_prtt_enrt_rslt_adj (p_per_in_ler_id number,
                            p_prtt_enrt_rslt_id number) is
   select null
   from ben_le_clsn_n_rstr
   where BKUP_TBL_TYP_CD = 'BEN_PRTT_ENRT_RSLT_F_ADJ'
   AND   BKUP_TBL_ID = p_prtt_enrt_rslt_id
   AND   PER_IN_LER_ID  = p_per_in_ler_id;
   --
   -- End bug 7206471
   --
  l_elig_per_elctbl_chc_id  number;
  l_ended_result  c_ended_result%rowtype;
  l_ended_result2  c_ended_result2%rowtype;
  l_pgm_id        number;
  l_pl_typ_id     number;
  l_pen           c_pen%rowtype;
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_ended_prv           c_ended_prv%rowtype;
  l_prv             c_prv%rowtype;
  l_exists          varchar2(1);
  l_adjust          varchar2(1);
  l_cvg_adjust			varchar2(1); -- bug 7206471

begin
  --
  hr_utility.set_location ('Entering '||g_package, 10);
  -- bug 6127624
   OPEN csr_electable_epes;

   FETCH csr_electable_epes
    INTO l_rec_electable_epes;

   IF csr_electable_epes%FOUND
   THEN
      IF g_debug
      THEN
         hr_utility.set_location ('Electable choices found ', 121);
      END IF;
  open c_ended_result (p_per_in_ler_id,p_business_group_id);
  loop
    fetch c_ended_result into l_ended_result;
    if c_ended_result%notfound then
      exit;
    end if;
    -- bug 6127624
    IF check_prev_eligible (p_person_id              => p_person_id,
                           p_pgm_id                 => l_ended_result.pgm_id,
                           p_pl_id                  => l_ended_result.pl_id,
                           p_oipl_id                => l_ended_result.oipl_id,
                           p_effective_date         => p_effective_date,
                           p_business_group_id      => p_business_group_id,
                           p_per_in_ler_id          => p_per_in_ler_id
                          )
    THEN
      IF g_debug
      THEN
         hr_utility.set_location (   'Eligible for pen_id '|| l_ended_result.prtt_enrt_rslt_id,121);
      END IF;

       insert into BEN_LE_CLSN_N_RSTR (
                   BKUP_TBL_TYP_CD,
                   COMP_LVL_CD,
                   LCR_ATTRIBUTE16,
                   LCR_ATTRIBUTE17,
                   LCR_ATTRIBUTE18,
                   LCR_ATTRIBUTE19,
                   LCR_ATTRIBUTE20,
                   LCR_ATTRIBUTE21,
                   LCR_ATTRIBUTE22,
                   LCR_ATTRIBUTE23,
                   LCR_ATTRIBUTE24,
                   LCR_ATTRIBUTE25,
                   LCR_ATTRIBUTE26,
                   LCR_ATTRIBUTE27,
                   LCR_ATTRIBUTE28,
                   LCR_ATTRIBUTE29,
                   LCR_ATTRIBUTE30,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_LOGIN,
                   CREATED_BY,
                   CREATION_DATE,
                   REQUEST_ID,
                   PROGRAM_APPLICATION_ID,
                   PROGRAM_ID,
                   PROGRAM_UPDATE_DATE,
                   OBJECT_VERSION_NUMBER,
                   BKUP_TBL_ID, -- PRTT_ENRT_RSLT_ID,
                   EFFECTIVE_START_DATE,
                   EFFECTIVE_END_DATE,
                   ENRT_CVG_STRT_DT,
                   ENRT_CVG_THRU_DT,
                   SSPNDD_FLAG,
                   PRTT_IS_CVRD_FLAG,
                   BNFT_AMT,
                   BNFT_NNMNTRY_UOM,
                   BNFT_TYP_CD,
                   UOM,
                   ORGNL_ENRT_DT,
                   ENRT_MTHD_CD,
                   ENRT_OVRIDN_FLAG,
                   ENRT_OVRID_RSN_CD,
                   ERLST_DEENRT_DT,
                   ENRT_OVRID_THRU_DT,
                   NO_LNGR_ELIG_FLAG,
                   BNFT_ORDR_NUM,
                   PERSON_ID,
                   ASSIGNMENT_ID,
                   PGM_ID,
                   PRTT_ENRT_RSLT_STAT_CD,
                   PL_ID,
                   OIPL_ID,
                   PTIP_ID,
                   PL_TYP_ID,
                   LER_ID,
                   PER_IN_LER_ID,
                   RPLCS_SSPNDD_RSLT_ID,
                   BUSINESS_GROUP_ID,
                   LCR_ATTRIBUTE_CATEGORY,
                   LCR_ATTRIBUTE1,
                   LCR_ATTRIBUTE2,
                   LCR_ATTRIBUTE3,
                   LCR_ATTRIBUTE4,
                   LCR_ATTRIBUTE5,
                   LCR_ATTRIBUTE6,
                   LCR_ATTRIBUTE7,
                   LCR_ATTRIBUTE8,
                   LCR_ATTRIBUTE9,
                   LCR_ATTRIBUTE10,
                   LCR_ATTRIBUTE11,
                   LCR_ATTRIBUTE12,
                   LCR_ATTRIBUTE13,
                   LCR_ATTRIBUTE14,
                   LCR_ATTRIBUTE15 ,
                   PER_IN_LER_ENDED_ID,
                   PL_ORDR_NUM,
                   PLIP_ORDR_NUM,
                   PTIP_ORDR_NUM,
                   OIPL_ORDR_NUM)
                 values (
                  'BEN_PRTT_ENRT_RSLT_F_DEL',
                  l_ended_result.COMP_LVL_CD,
                  l_ended_result.PEN_ATTRIBUTE16,
                  l_ended_result.PEN_ATTRIBUTE17,
                  l_ended_result.PEN_ATTRIBUTE18,
                  l_ended_result.PEN_ATTRIBUTE19,
                  l_ended_result.PEN_ATTRIBUTE20,
                  l_ended_result.PEN_ATTRIBUTE21,
                  l_ended_result.PEN_ATTRIBUTE22,
                  l_ended_result.PEN_ATTRIBUTE23,
                  l_ended_result.PEN_ATTRIBUTE24,
                  l_ended_result.PEN_ATTRIBUTE25,
                  l_ended_result.PEN_ATTRIBUTE26,
                  l_ended_result.PEN_ATTRIBUTE27,
                  l_ended_result.PEN_ATTRIBUTE28,
                  l_ended_result.PEN_ATTRIBUTE29,
                  l_ended_result.PEN_ATTRIBUTE30,
                  l_ended_result.LAST_UPDATE_DATE,
                  l_ended_result.LAST_UPDATED_BY,
                  l_ended_result.LAST_UPDATE_LOGIN,
                  l_ended_result.CREATED_BY,
                  l_ended_result.CREATION_DATE,
                  l_ended_result.REQUEST_ID,
                  l_ended_result.PROGRAM_APPLICATION_ID,
                  l_ended_result.PROGRAM_ID,
                  l_ended_result.PROGRAM_UPDATE_DATE,
                  l_ended_result.OBJECT_VERSION_NUMBER,
                  l_ended_result.PRTT_ENRT_RSLT_ID,
                  l_ended_result.EFFECTIVE_START_DATE,
                  l_ended_result.EFFECTIVE_END_DATE,
                  l_ended_result.ENRT_CVG_STRT_DT,
                  l_ended_result.ENRT_CVG_THRU_DT,
                  l_ended_result.SSPNDD_FLAG,
                  l_ended_result.PRTT_IS_CVRD_FLAG,
                  l_ended_result.BNFT_AMT,
                  l_ended_result.BNFT_NNMNTRY_UOM,
                  l_ended_result.BNFT_TYP_CD,
                  l_ended_result.UOM,
                  l_ended_result.ORGNL_ENRT_DT,
                  l_ended_result.ENRT_MTHD_CD,
                  l_ended_result.ENRT_OVRIDN_FLAG,
                  l_ended_result.ENRT_OVRID_RSN_CD,
                  l_ended_result.ERLST_DEENRT_DT,
                  l_ended_result.ENRT_OVRID_THRU_DT,
                  l_ended_result.NO_LNGR_ELIG_FLAG,
                  l_ended_result.BNFT_ORDR_NUM,
                  l_ended_result.PERSON_ID,
                  l_ended_result.ASSIGNMENT_ID,
                  l_ended_result.PGM_ID,
                  l_ended_result.PRTT_ENRT_RSLT_STAT_CD,
                  l_ended_result.PL_ID,
                  l_ended_result.OIPL_ID,
                  l_ended_result.PTIP_ID,
                  l_ended_result.PL_TYP_ID,
                  l_ended_result.LER_ID,
                  l_ended_result.PER_IN_LER_ID,
                  l_ended_result.RPLCS_SSPNDD_RSLT_ID,
                  l_ended_result.BUSINESS_GROUP_ID,
                  l_ended_result.PEN_ATTRIBUTE_CATEGORY,
                  l_ended_result.PEN_ATTRIBUTE1,
                  l_ended_result.PEN_ATTRIBUTE2,
                  l_ended_result.PEN_ATTRIBUTE3,
                  l_ended_result.PEN_ATTRIBUTE4,
                  l_ended_result.PEN_ATTRIBUTE5,
                  l_ended_result.PEN_ATTRIBUTE6,
                  l_ended_result.PEN_ATTRIBUTE7,
                  l_ended_result.PEN_ATTRIBUTE8,
                  l_ended_result.PEN_ATTRIBUTE9,
                  l_ended_result.PEN_ATTRIBUTE10,
                  l_ended_result.PEN_ATTRIBUTE11,
                  l_ended_result.PEN_ATTRIBUTE12,
                  l_ended_result.PEN_ATTRIBUTE13,
                  l_ended_result.PEN_ATTRIBUTE14,
                  l_ended_result.PEN_ATTRIBUTE15,
                  p_per_in_ler_id,
                  l_ended_result.PL_ORDR_NUM,
                  l_ended_result.PLIP_ORDR_NUM,
                  l_ended_result.PTIP_ORDR_NUM,
                  l_ended_result.OIPL_ORDR_NUM
              );

     /* bug # 5345189 */
     for l_future_results in c_future_results (p_person_id,
                                      l_ended_result.enrt_cvg_thru_dt,
                                      l_ended_result.pgm_id,
                                      l_ended_result.pl_id,
                                      l_ended_result.oipl_id,
                                      l_ended_result.pl_typ_id,
                                      l_ended_result.business_group_id) loop

      insert into BEN_LE_CLSN_N_RSTR (
                   BKUP_TBL_TYP_CD,
                   COMP_LVL_CD,
                   LCR_ATTRIBUTE16,
                   LCR_ATTRIBUTE17,
                   LCR_ATTRIBUTE18,
                   LCR_ATTRIBUTE19,
                   LCR_ATTRIBUTE20,
                   LCR_ATTRIBUTE21,
                   LCR_ATTRIBUTE22,
                   LCR_ATTRIBUTE23,
                   LCR_ATTRIBUTE24,
                   LCR_ATTRIBUTE25,
                   LCR_ATTRIBUTE26,
                   LCR_ATTRIBUTE27,
                   LCR_ATTRIBUTE28,
                   LCR_ATTRIBUTE29,
                   LCR_ATTRIBUTE30,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_LOGIN,
                   CREATED_BY,
                   CREATION_DATE,
                   REQUEST_ID,
                   PROGRAM_APPLICATION_ID,
                   PROGRAM_ID,
                   PROGRAM_UPDATE_DATE,
                   OBJECT_VERSION_NUMBER,
                   BKUP_TBL_ID, -- PRTT_ENRT_RSLT_ID,
                   EFFECTIVE_START_DATE,
                   EFFECTIVE_END_DATE,
                   ENRT_CVG_STRT_DT,
                   ENRT_CVG_THRU_DT,
                   SSPNDD_FLAG,
                   PRTT_IS_CVRD_FLAG,
                   BNFT_AMT,
                   BNFT_NNMNTRY_UOM,
                   BNFT_TYP_CD,
                   UOM,
                   ORGNL_ENRT_DT,
                   ENRT_MTHD_CD,
                   ENRT_OVRIDN_FLAG,
                   ENRT_OVRID_RSN_CD,
                   ERLST_DEENRT_DT,
                   ENRT_OVRID_THRU_DT,
                   NO_LNGR_ELIG_FLAG,
                   BNFT_ORDR_NUM,
                   PERSON_ID,
                   ASSIGNMENT_ID,
                   PGM_ID,
                   PRTT_ENRT_RSLT_STAT_CD,
                   PL_ID,
                   OIPL_ID,
                   PTIP_ID,
                   PL_TYP_ID,
                   LER_ID,
                   PER_IN_LER_ID,
                   RPLCS_SSPNDD_RSLT_ID,
                   BUSINESS_GROUP_ID,
                   LCR_ATTRIBUTE_CATEGORY,
                   LCR_ATTRIBUTE1,
                   LCR_ATTRIBUTE2,
                   LCR_ATTRIBUTE3,
                   LCR_ATTRIBUTE4,
                   LCR_ATTRIBUTE5,
                   LCR_ATTRIBUTE6,
                   LCR_ATTRIBUTE7,
                   LCR_ATTRIBUTE8,
                   LCR_ATTRIBUTE9,
                   LCR_ATTRIBUTE10,
                   LCR_ATTRIBUTE11,
                   LCR_ATTRIBUTE12,
                   LCR_ATTRIBUTE13,
                   LCR_ATTRIBUTE14,
                   LCR_ATTRIBUTE15 ,
                   PER_IN_LER_ENDED_ID,
                   PL_ORDR_NUM,
                   PLIP_ORDR_NUM,
                   PTIP_ORDR_NUM,
                   OIPL_ORDR_NUM)
                 values (
                  'BEN_PRTT_ENRT_RSLT_F_DEL',
                  l_future_results.COMP_LVL_CD,
                  l_future_results.PEN_ATTRIBUTE16,
                  l_future_results.PEN_ATTRIBUTE17,
                  l_future_results.PEN_ATTRIBUTE18,
                  l_future_results.PEN_ATTRIBUTE19,
                  l_future_results.PEN_ATTRIBUTE20,
                  l_future_results.PEN_ATTRIBUTE21,
                  l_future_results.PEN_ATTRIBUTE22,
                  l_future_results.PEN_ATTRIBUTE23,
                  l_future_results.PEN_ATTRIBUTE24,
                  l_future_results.PEN_ATTRIBUTE25,
                  l_future_results.PEN_ATTRIBUTE26,
                  l_future_results.PEN_ATTRIBUTE27,
                  l_future_results.PEN_ATTRIBUTE28,
                  l_future_results.PEN_ATTRIBUTE29,
                  l_future_results.PEN_ATTRIBUTE30,
                  l_future_results.LAST_UPDATE_DATE,
                  l_future_results.LAST_UPDATED_BY,
                  l_future_results.LAST_UPDATE_LOGIN,
                  l_future_results.CREATED_BY,
                  l_future_results.CREATION_DATE,
                  l_future_results.REQUEST_ID,
                  l_future_results.PROGRAM_APPLICATION_ID,
                  l_future_results.PROGRAM_ID,
                  l_future_results.PROGRAM_UPDATE_DATE,
                  l_future_results.OBJECT_VERSION_NUMBER,
                  l_future_results.PRTT_ENRT_RSLT_ID,
                  l_future_results.EFFECTIVE_START_DATE,
                  l_future_results.EFFECTIVE_END_DATE,
                  l_future_results.ENRT_CVG_STRT_DT,
                  l_future_results.ENRT_CVG_THRU_DT,
                  l_future_results.SSPNDD_FLAG,
                  l_future_results.PRTT_IS_CVRD_FLAG,
                  l_future_results.BNFT_AMT,
                  l_future_results.BNFT_NNMNTRY_UOM,
                  l_future_results.BNFT_TYP_CD,
                  l_future_results.UOM,
                  l_future_results.ORGNL_ENRT_DT,
                  l_future_results.ENRT_MTHD_CD,
                  l_future_results.ENRT_OVRIDN_FLAG,
                  l_future_results.ENRT_OVRID_RSN_CD,
                  l_future_results.ERLST_DEENRT_DT,
                  l_future_results.ENRT_OVRID_THRU_DT,
                  l_future_results.NO_LNGR_ELIG_FLAG,
                  l_future_results.BNFT_ORDR_NUM,
                  l_future_results.PERSON_ID,
                  l_future_results.ASSIGNMENT_ID,
                  l_future_results.PGM_ID,
                  l_future_results.PRTT_ENRT_RSLT_STAT_CD,
                  l_future_results.PL_ID,
                  l_future_results.OIPL_ID,
                  l_future_results.PTIP_ID,
                  l_future_results.PL_TYP_ID,
                  l_future_results.LER_ID,
                  l_future_results.PER_IN_LER_ID,
                  l_future_results.RPLCS_SSPNDD_RSLT_ID,
                  l_future_results.BUSINESS_GROUP_ID,
                  l_future_results.PEN_ATTRIBUTE_CATEGORY,
                  l_future_results.PEN_ATTRIBUTE1,
                  l_future_results.PEN_ATTRIBUTE2,
                  l_future_results.PEN_ATTRIBUTE3,
                  l_future_results.PEN_ATTRIBUTE4,
                  l_future_results.PEN_ATTRIBUTE5,
                  l_future_results.PEN_ATTRIBUTE6,
                  l_future_results.PEN_ATTRIBUTE7,
                  l_future_results.PEN_ATTRIBUTE8,
                  l_future_results.PEN_ATTRIBUTE9,
                  l_future_results.PEN_ATTRIBUTE10,
                  l_future_results.PEN_ATTRIBUTE11,
                  l_future_results.PEN_ATTRIBUTE12,
                  l_future_results.PEN_ATTRIBUTE13,
                  l_future_results.PEN_ATTRIBUTE14,
                  l_future_results.PEN_ATTRIBUTE15,
                  p_per_in_ler_id,
                  l_future_results.PL_ORDR_NUM,
                  l_future_results.PLIP_ORDR_NUM,
                  l_future_results.PTIP_ORDR_NUM,
                  l_future_results.OIPL_ORDR_NUM
              );
         hr_utility.set_location('DDD 33 Backingout l_future_results.prtt_enrt_rslt_id'||l_future_results.prtt_enrt_rslt_id,999);

       ben_back_out_life_event.back_out_life_events
      (p_per_in_ler_id           => l_future_results.per_in_ler_id,
       p_business_group_id       => p_business_group_id,
       p_bckdt_prtt_enrt_rslt_id => l_future_results.prtt_enrt_rslt_id,
       p_effective_date          => p_effective_date);
       -- strt 5376652: to avoid 91203 error the prtt_rt_val_id needs to be updated
       open c_epe(p_per_in_ler_id,
                  l_future_results.prtt_enrt_rslt_id);
       loop
         fetch c_epe into l_elig_per_elctbl_chc_id;
         if c_epe%notfound then
           exit;
         end if;
         --
         update ben_enrt_rt set prtt_rt_val_id = null
          where elig_per_elctbl_chc_id = l_elig_per_elctbl_chc_id;
       end loop;
       close c_epe;

       -- update to avoid 91711 error
         update ben_elig_per_elctbl_chc set prtt_enrt_rslt_id = null,
              CRNTLY_ENRD_FLAG = 'N'
           where prtt_enrt_rslt_id = l_future_results.prtt_enrt_rslt_id
           and   per_in_ler_id = p_per_in_ler_id;

      -- end 5376652

        end loop;
     /* bug#5345189 */
    --
    ben_back_out_life_event.back_out_life_events
      (p_per_in_ler_id           => l_ended_result.per_in_ler_id,
       p_business_group_id       => p_business_group_id,
       p_bckdt_prtt_enrt_rslt_id => l_ended_result.prtt_enrt_rslt_id,
       p_effective_date          => p_effective_date);
   --
  end if; -- check_prev_eligible
  end loop;
  close c_ended_result;
  hr_utility.set_location ('Leaving'||g_package, 20);
  -- Reopen ended result in other ineligible program and deenroll
  open c_pl_typ (p_per_in_ler_id);
  loop
    fetch c_pl_typ into l_pgm_id, l_pl_typ_id;
    if c_pl_typ%notfound then
       exit;
    end if;
    -- to backout the rate attached to the closed result
    open c_ended_prv (p_per_in_ler_id => p_per_in_ler_id,
                      p_person_id  => p_person_id,
                      p_pgm_id  => l_pgm_id);
    loop
      fetch c_ended_prv into l_ended_prv;
      if c_ended_prv%notfound then
        exit;
      end if;
      --
      open c_prv (p_per_in_ler_id  => p_per_in_ler_id,
                p_acty_base_rt_id  => l_ended_prv.acty_base_rt_id,
                p_prtt_enrt_rslt_id => l_ended_prv.prtt_enrt_rslt_id);
      fetch c_prv into l_prv;
      if c_prv%found then
        --
        hr_utility.set_location('Update prtt rt val'||l_ended_prv.prtt_rt_val_id,100);
        if l_prv.rt_end_dt < l_ended_prv.rt_end_dt then -- 5947036

          hr_utility.set_location('l_prv.rt_end_dt ' || l_prv.rt_end_dt ,121);
          hr_utility.set_location('l_ended_prv.rt_end_dt ' || l_ended_prv.rt_end_dt ,121);
          hr_utility.set_location('Rate should be ended with lesser date ',121);

          ben_prtt_rt_val_api.update_prtt_rt_val
          (P_VALIDATE                => FALSE
          ,P_PRTT_RT_VAL_ID          => l_ended_prv.prtt_rt_val_id
          ,P_RT_END_DT               => l_prv.rt_end_dt
          ,p_person_id               => p_person_id
          ,p_ended_per_in_ler_id     => p_per_in_ler_id
          ,p_business_group_id       => p_business_group_id
          ,P_OBJECT_VERSION_NUMBER   => l_ended_prv.object_version_number
          ,P_EFFECTIVE_DATE          => p_effective_date
          );
       else
          hr_utility.set_location('l_prv.rt_end_dt ' || l_prv.rt_end_dt ,121);
          hr_utility.set_location('l_ended_prv.rt_end_dt ' || l_ended_prv.rt_end_dt ,121);
          hr_utility.set_location('Rate is ended with a lesser date already ',121);
       end if;
       -- end 5947036
      end if;
      close c_prv;

    end loop;
    close c_ended_prv;
    --

    open c_ended_result2(p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
                         p_pl_typ_id   => l_pl_typ_id,
                         p_person_id   => p_person_id,
                         p_business_group_id  => p_business_group_id,
                         p_pgm_id  => l_pgm_id);
    loop
      fetch c_ended_result2 into l_ended_result2;
      if c_ended_result2%notfound then
         exit;
      end if;
      --
      hr_utility.set_location ('ENdedn result 2',100);
      insert into BEN_LE_CLSN_N_RSTR (
                   BKUP_TBL_TYP_CD,
                   COMP_LVL_CD,
                   LCR_ATTRIBUTE16,
                   LCR_ATTRIBUTE17,
                   LCR_ATTRIBUTE18,
                   LCR_ATTRIBUTE19,
                   LCR_ATTRIBUTE20,
                   LCR_ATTRIBUTE21,
                   LCR_ATTRIBUTE22,
                   LCR_ATTRIBUTE23,
                   LCR_ATTRIBUTE24,
                   LCR_ATTRIBUTE25,
                   LCR_ATTRIBUTE26,
                   LCR_ATTRIBUTE27,
                   LCR_ATTRIBUTE28,
                   LCR_ATTRIBUTE29,
                   LCR_ATTRIBUTE30,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_LOGIN,
                   CREATED_BY,
                   CREATION_DATE,
                   REQUEST_ID,
                   PROGRAM_APPLICATION_ID,
                   PROGRAM_ID,
                   PROGRAM_UPDATE_DATE,
                   OBJECT_VERSION_NUMBER,
                   BKUP_TBL_ID, -- PRTT_ENRT_RSLT_ID,
                   EFFECTIVE_START_DATE,
                   EFFECTIVE_END_DATE,
                   ENRT_CVG_STRT_DT,
                   ENRT_CVG_THRU_DT,
                   SSPNDD_FLAG,
                   PRTT_IS_CVRD_FLAG,
                   BNFT_AMT,
                   BNFT_NNMNTRY_UOM,
                   BNFT_TYP_CD,
                   UOM,
                   ORGNL_ENRT_DT,
                   ENRT_MTHD_CD,
                   ENRT_OVRIDN_FLAG,
                   ENRT_OVRID_RSN_CD,
                   ERLST_DEENRT_DT,
                   ENRT_OVRID_THRU_DT,
                   NO_LNGR_ELIG_FLAG,
                   BNFT_ORDR_NUM,
                   PERSON_ID,
                   ASSIGNMENT_ID,
                   PGM_ID,
                   PRTT_ENRT_RSLT_STAT_CD,
                   PL_ID,
                   OIPL_ID,
                   PTIP_ID,
                   PL_TYP_ID,
                   LER_ID,
                   PER_IN_LER_ID,
                   RPLCS_SSPNDD_RSLT_ID,
                   BUSINESS_GROUP_ID,
                   LCR_ATTRIBUTE_CATEGORY,
                   LCR_ATTRIBUTE1,
                   LCR_ATTRIBUTE2,
                   LCR_ATTRIBUTE3,
                   LCR_ATTRIBUTE4,
                   LCR_ATTRIBUTE5,
                   LCR_ATTRIBUTE6,
                   LCR_ATTRIBUTE7,
                   LCR_ATTRIBUTE8,
                   LCR_ATTRIBUTE9,
                   LCR_ATTRIBUTE10,
                   LCR_ATTRIBUTE11,
                   LCR_ATTRIBUTE12,
                   LCR_ATTRIBUTE13,
                   LCR_ATTRIBUTE14,
                   LCR_ATTRIBUTE15 ,
                   PER_IN_LER_ENDED_ID,
                   PL_ORDR_NUM,
                   PLIP_ORDR_NUM,
                   PTIP_ORDR_NUM,
                   OIPL_ORDR_NUM)
                 values (
                  'BEN_PRTT_ENRT_RSLT_F_DEL',
                  l_ended_result2.COMP_LVL_CD,
                  l_ended_result2.PEN_ATTRIBUTE16,
                  l_ended_result2.PEN_ATTRIBUTE17,
                  l_ended_result2.PEN_ATTRIBUTE18,
                  l_ended_result2.PEN_ATTRIBUTE19,
                  l_ended_result2.PEN_ATTRIBUTE20,
                  l_ended_result2.PEN_ATTRIBUTE21,
                  l_ended_result2.PEN_ATTRIBUTE22,
                  l_ended_result2.PEN_ATTRIBUTE23,
                  l_ended_result2.PEN_ATTRIBUTE24,
                  l_ended_result2.PEN_ATTRIBUTE25,
                  l_ended_result2.PEN_ATTRIBUTE26,
                  l_ended_result2.PEN_ATTRIBUTE27,
                  l_ended_result2.PEN_ATTRIBUTE28,
                  l_ended_result2.PEN_ATTRIBUTE29,
                  l_ended_result2.PEN_ATTRIBUTE30,
                  l_ended_result2.LAST_UPDATE_DATE,
                  l_ended_result2.LAST_UPDATED_BY,
                  l_ended_result2.LAST_UPDATE_LOGIN,
                  l_ended_result2.CREATED_BY,
                  l_ended_result2.CREATION_DATE,
                  l_ended_result2.REQUEST_ID,
                  l_ended_result2.PROGRAM_APPLICATION_ID,
                  l_ended_result2.PROGRAM_ID,
                  l_ended_result2.PROGRAM_UPDATE_DATE,
                  l_ended_result2.OBJECT_VERSION_NUMBER,
                  l_ended_result2.PRTT_ENRT_RSLT_ID,
                  l_ended_result2.EFFECTIVE_START_DATE,
                  l_ended_result2.EFFECTIVE_END_DATE,
                  l_ended_result2.ENRT_CVG_STRT_DT,
                  l_ended_result2.ENRT_CVG_THRU_DT,
                  l_ended_result2.SSPNDD_FLAG,
                  l_ended_result2.PRTT_IS_CVRD_FLAG,
                  l_ended_result2.BNFT_AMT,
                  l_ended_result2.BNFT_NNMNTRY_UOM,
                  l_ended_result2.BNFT_TYP_CD,
                  l_ended_result2.UOM,
                  l_ended_result2.ORGNL_ENRT_DT,
                  l_ended_result2.ENRT_MTHD_CD,
                  l_ended_result2.ENRT_OVRIDN_FLAG,
                  l_ended_result2.ENRT_OVRID_RSN_CD,
                  l_ended_result2.ERLST_DEENRT_DT,
                  l_ended_result2.ENRT_OVRID_THRU_DT,
                  l_ended_result2.NO_LNGR_ELIG_FLAG,
                  l_ended_result2.BNFT_ORDR_NUM,
                  l_ended_result2.PERSON_ID,
                  l_ended_result2.ASSIGNMENT_ID,
                  l_ended_result2.PGM_ID,
                  l_ended_result2.PRTT_ENRT_RSLT_STAT_CD,
                  l_ended_result2.PL_ID,
                  l_ended_result2.OIPL_ID,
                  l_ended_result2.PTIP_ID,
                  l_ended_result2.PL_TYP_ID,
                  l_ended_result2.LER_ID,
                  l_ended_result2.PER_IN_LER_ID,
                  l_ended_result2.RPLCS_SSPNDD_RSLT_ID,
                  l_ended_result2.BUSINESS_GROUP_ID,
                  l_ended_result2.PEN_ATTRIBUTE_CATEGORY,
                  l_ended_result2.PEN_ATTRIBUTE1,
                  l_ended_result2.PEN_ATTRIBUTE2,
                  l_ended_result2.PEN_ATTRIBUTE3,
                  l_ended_result2.PEN_ATTRIBUTE4,
                  l_ended_result2.PEN_ATTRIBUTE5,
                  l_ended_result2.PEN_ATTRIBUTE6,
                  l_ended_result2.PEN_ATTRIBUTE7,
                  l_ended_result2.PEN_ATTRIBUTE8,
                  l_ended_result2.PEN_ATTRIBUTE9,
                  l_ended_result2.PEN_ATTRIBUTE10,
                  l_ended_result2.PEN_ATTRIBUTE11,
                  l_ended_result2.PEN_ATTRIBUTE12,
                  l_ended_result2.PEN_ATTRIBUTE13,
                  l_ended_result2.PEN_ATTRIBUTE14,
                  l_ended_result2.PEN_ATTRIBUTE15,
                  p_per_in_ler_id,
                  l_ended_result2.PL_ORDR_NUM,
                  l_ended_result2.PLIP_ORDR_NUM,
                  l_ended_result2.PTIP_ORDR_NUM,
                  l_ended_result2.OIPL_ORDR_NUM
              );
      --
      ben_back_out_life_event.back_out_life_events
      (p_per_in_ler_id           => l_ended_result2.per_in_ler_id,
       p_business_group_id       => p_business_group_id,
       p_bckdt_prtt_enrt_rslt_id => l_ended_result2.prtt_enrt_rslt_id,
       p_effective_date          => p_effective_date);
      --
      l_pen.effective_start_date :=  null;
      open c_pen(l_ended_result2.prtt_enrt_rslt_id);
      fetch c_pen into l_pen;
      close c_pen;
      --
      hr_utility.set_location ('Delete enrollment ',101);
      if l_pen.effective_start_date is not null then
        ben_prtt_enrt_result_api.delete_enrollment
           (p_validate              => false ,
           p_prtt_enrt_rslt_id     => l_ended_result2.prtt_enrt_rslt_id,
           p_per_in_ler_id         => p_per_in_ler_id,
           p_business_group_id     => p_business_group_id ,
           p_effective_start_date  => l_effective_start_date,
           p_effective_end_date    => l_effective_end_date,
           p_object_version_number => l_pen.object_version_number,
           p_effective_date        => l_pen.effective_start_date,
           p_datetrack_mode        => 'DELETE',
           p_multi_row_validate    => false);

      end if;
      --
    end loop;
    close c_ended_result2;
  end loop;
  close c_pl_typ;
  /*
  --
  --  Bug 5391554. Check if the rates should be adjusted.
  --
  --
  --  Check if there is a life event in the same month.
  --
  open c_get_prior_per_in_ler;
  fetch c_get_prior_per_in_ler into l_exists;
  if c_get_prior_per_in_ler%found then
    --
    for l_pgm in c_get_pgm loop
      --
      open c_get_pgm_extra_info(l_pgm.pgm_id);
      fetch c_get_pgm_extra_info into l_adjust;
      if c_get_pgm_extra_info%found then
        --
        if l_adjust = 'Y' then
          --
          --  Get rt end dt
          --
          for l_epe in c_get_elctbl_chc loop
            --
            --  Get all results that were de-enrolled for the event.
            --
            for l_pen in c_get_enrt_rslts(l_epe.rt_strt_dt
                                       ,l_epe.ptip_id ) loop
              hr_utility.set_location('Adjusting rate '||l_epe.rt_strt_dt,111);
              --
              open c_prtt_rt_val_adj(p_per_in_ler_id,l_pen.prtt_rt_val_id);
              fetch c_prtt_rt_val_adj into l_exists;
              if c_prtt_rt_val_adj%notfound then
                insert into BEN_LE_CLSN_N_RSTR (
                        BKUP_TBL_TYP_CD,
                        BKUP_TBL_ID,
                        per_in_ler_id,
                        person_id,
                        RT_END_DT,
                        business_group_id,
                        object_version_number)
                      values (
                        'BEN_PRTT_RT_VAL_ADJ',
                        l_pen.prtt_rt_val_id,
                        p_per_in_ler_id,
                        l_pen.person_id,
                        l_pen.rt_end_dt,
                        p_business_group_id,
                        l_pen.object_version_number
                      );
              end if;
              close c_prtt_rt_val_adj;
               --
              ben_prtt_rt_val_api.update_prtt_rt_val
               (P_VALIDATE                => FALSE
               ,P_PRTT_RT_VAL_ID          => l_pen.prtt_rt_val_id
               ,P_RT_END_DT               => l_epe.rt_strt_dt - 1
               ,p_person_id               => l_pen.person_id
               ,p_input_value_id          => l_pen.input_value_id
               ,p_element_type_id         => l_pen.element_type_id
               ,p_business_group_id       => p_business_group_id
               ,P_OBJECT_VERSION_NUMBER   => l_pen.object_version_number
               ,P_EFFECTIVE_DATE          => p_effective_date
               );
            end loop;  -- c_get_enrt_rslts
          end loop; -- c_get_elctbl_chc
        end if;  -- l_adjust = 'Y'
      end if;  -- c_get_pgm_extra_info
      close c_get_pgm_extra_info;
    end loop; -- c_get_pgm
    --
    --  Bug 7206471. Check if the coverage should be adjusted.
    --
     for l_pgm in c_get_pgm loop
      --
      open c_get_pgm_extra_info_cvg(l_pgm.pgm_id);
      fetch c_get_pgm_extra_info_cvg into l_cvg_adjust;
      if c_get_pgm_extra_info_cvg%found then
        --
        if l_cvg_adjust = 'Y' then
          --
	  hr_utility.set_location('l_cvg_adjust '||l_cvg_adjust,44333);
	  --
          --  Get cvg end dt
	  --
	  for l_get_elctbl_chc_for_cvg in c_get_elctbl_chc_for_cvg loop
	  --
          --  Get all results that were de-enrolled for the event.
	  --
          for l_get_enrt_rslts_for_pen in c_get_enrt_rslts_for_pen(l_get_elctbl_chc_for_cvg.enrt_cvg_strt_dt
                                       ,l_get_elctbl_chc_for_cvg.ptip_id ) loop
              hr_utility.set_location('Adjusting Coverage for '||l_get_elctbl_chc_for_cvg.enrt_cvg_strt_dt,44333);
              --
	      open c_prtt_enrt_rslt_adj(p_per_in_ler_id,l_get_enrt_rslts_for_pen.prtt_enrt_rslt_id);
              fetch c_prtt_enrt_rslt_adj into l_exists;
              if c_prtt_enrt_rslt_adj%notfound then
                insert into BEN_LE_CLSN_N_RSTR (
                        BKUP_TBL_TYP_CD,
                        BKUP_TBL_ID,
                        per_in_ler_id,
                        person_id,
                        ENRT_CVG_THRU_DT,
                        business_group_id,
                        object_version_number)
                      values (
                        'BEN_PRTT_ENRT_RSLT_F_ADJ',
                        l_get_enrt_rslts_for_pen.prtt_enrt_rslt_id,
                        p_per_in_ler_id,
                        l_get_enrt_rslts_for_pen.person_id,
                        l_get_enrt_rslts_for_pen.enrt_cvg_thru_dt,
                        p_business_group_id,
                        l_get_enrt_rslts_for_pen.object_version_number
                      );
              end if;
              close c_prtt_enrt_rslt_adj;
               --
	        ben_prtt_enrt_result_api.update_prtt_enrt_result
               (p_validate                 => FALSE,
               p_prtt_enrt_rslt_id        => l_get_enrt_rslts_for_pen.prtt_enrt_rslt_id,
               p_effective_start_date     => l_effective_start_date,
               p_effective_end_date       => l_effective_end_date,
               p_business_group_id        => p_business_group_id,
               p_object_version_number    => l_get_enrt_rslts_for_pen.object_version_number,
               p_effective_date           => p_effective_date,
               p_datetrack_mode           => hr_api.g_correction,
               p_multi_row_validate       => FALSE,
	       p_enrt_cvg_thru_dt         => l_get_elctbl_chc_for_cvg.enrt_cvg_strt_dt - 1
               );
            end loop;  -- c_get_enrt_rslts_for_pen
          end loop; -- c_get_elctbl_chc_for_cvg
        end if;  -- l_cvg_adjust = 'Y'
      end if;  -- c_get_pgm_extra_info_cvg
      close c_get_pgm_extra_info_cvg;
    end loop; -- c_get_pgm
    --
    -- End bug 7206471
  end if;
  close c_get_prior_per_in_ler;*/
    --
  -- bug 6127624
  end if; -- end if csr_electable_epe
  close csr_electable_epes;
  hr_utility.set_location ('Leaving '||g_package, 10);
end;
--
end ben_reopen_ended_results;

/

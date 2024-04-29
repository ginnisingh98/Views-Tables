--------------------------------------------------------
--  DDL for Package Body BEN_COMP_OBJECT_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COMP_OBJECT_LIST" AS
/* $Header: bebmbcol.pkb 120.3.12010000.2 2009/06/11 12:45:54 sagnanas ship $ */
--
  g_package             VARCHAR2(50) := 'ben_comp_object_list.';
--
  g_prev_lf_evt_ocrd_dt DATE;
  g_prev_per_org_id     NUMBER;
--
  PROCEDURE init_comp_object_list_globals IS
    --
    l_package VARCHAR2(80) := g_package || '.init_comp_object_list_globals';
  --
  BEGIN
    hr_utility.set_location('Entering ' || l_package, 10);
    --
    g_prev_lf_evt_ocrd_dt  := NULL;
    g_prev_per_org_id      := NULL;
    --
    hr_utility.set_location('Leaving ' || l_package, 10);
  END init_comp_object_list_globals;
--
  FUNCTION set_flag_bit_val(
    p_business_group_id         IN NUMBER
   ,p_effective_date            IN DATE
   ,p_drvbl_fctr_prtn_elig_flag IN VARCHAR2
   ,p_drvbl_fctr_apls_rts_flag  IN VARCHAR2
   ,p_pgm_id                    IN NUMBER DEFAULT NULL
   ,p_pl_id                     IN NUMBER DEFAULT NULL
   ,p_oipl_id                   IN NUMBER DEFAULT NULL
   ,p_plip_id                   IN NUMBER DEFAULT NULL
   ,p_ptip_id                   IN NUMBER DEFAULT NULL
   ,p_oiplip_id                 IN NUMBER DEFAULT NULL)
    RETURN BINARY_INTEGER IS
    --
    l_package          VARCHAR2(80)        := g_package || '.set_flag_bit_val';
    l_inst_count       NUMBER;
    l_eligprof_dets    ben_elp_cache.g_cobcep_cache;
    l_age_flag         BOOLEAN                      := FALSE;
    l_los_flag         BOOLEAN                      := FALSE;
    l_cmp_flag         BOOLEAN                      := FALSE;
    l_pft_flag         BOOLEAN                      := FALSE;
    l_hrw_flag         BOOLEAN                      := FALSE;
    l_cal_flag         BOOLEAN                      := FALSE;
    l_age_rt_flag      NUMBER                       := 0;
    l_los_rt_flag      NUMBER                       := 0;
    l_cmp_rt_flag      NUMBER                       := 0;
    l_pft_rt_flag      NUMBER                       := 0;
    l_hrw_rt_flag      NUMBER                       := 0;
    l_cal_rt_flag      NUMBER                       := 0;
    l_prem_age_rt_flag NUMBER                       := 0;
    l_prem_los_rt_flag NUMBER                       := 0;
    l_prem_cmp_rt_flag NUMBER                       := 0;
    l_prem_pft_rt_flag NUMBER                       := 0;
    l_prem_hrw_rt_flag NUMBER                       := 0;
    l_prem_cal_rt_flag NUMBER                       := 0;
    l_cvg_age_rt_flag  NUMBER                       := 0;
    l_cvg_los_rt_flag  NUMBER                       := 0;
    l_cvg_cmp_rt_flag  NUMBER                       := 0;
    l_cvg_pft_rt_flag  NUMBER                       := 0;
    l_cvg_hrw_rt_flag  NUMBER                       := 0;
    l_cvg_cal_rt_flag  NUMBER                       := 0;
    l_flag_bit_val     BINARY_INTEGER               := 0;
    l_cobj_id          number;
    --START Option Level Rates
    l_oipl_abr_count   number;
    l_opt_id           number;
    --END Option Level Rates
    --
    l_sql              VARCHAR2(32000)
      := 'select count(*), sum(decode(vpf.rt_age_flag,''Y'',1,0)),
            sum(decode(vpf.rt_los_flag,''Y'',1,0)),
            sum(decode(vpf.rt_comp_lvl_flag,''Y'',1,0)),
            sum(decode(vpf.rt_pct_fl_tm_flag,''Y'',1,0)),
            sum(decode(vpf.rt_hrs_wkd_flag,''Y'',1,0)),
            sum(decode(vpf.rt_cmbn_age_los_flag,''Y'',1,0))
     from   ben_vrbl_rt_prfl_f vpf,
            ben_acty_vrbl_rt_f avr,
            ben_acty_base_rt_f abr
     where  abr.{OBJECT} = :cobj_id
     and    abr.business_group_id = :business_group_id
     and    :abr_effective_date
            between abr.effective_start_date
            and     abr.effective_end_date
     and    abr.acty_base_rt_id = avr.acty_base_rt_id
     and    avr.business_group_id = abr.business_group_id
     and    :avr_effective_date
            between avr.effective_start_date
            and     avr.effective_end_date
     and    avr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
     and    vpf.business_group_id = avr.business_group_id
     and    :vpf_effective_date
            between vpf.effective_start_date
            and     vpf.effective_end_date';
    --
    l_prem_sql         VARCHAR2(2000)
      := 'select sum(decode(vpf.rt_age_flag,''Y'',1,0)),
            sum(decode(vpf.rt_los_flag,''Y'',1,0)),
            sum(decode(vpf.rt_comp_lvl_flag,''Y'',1,0)),
            sum(decode(vpf.rt_pct_fl_tm_flag,''Y'',1,0)),
            sum(decode(vpf.rt_hrs_wkd_flag,''Y'',1,0)),
            sum(decode(vpf.rt_cmbn_age_los_flag,''Y'',1,0))
     from   ben_vrbl_rt_prfl_f vpf,
            ben_actl_prem_vrbl_rt_f apv,
            ben_actl_prem_f apr
     where  apr.{OBJECT} = :cobj_id
     and    apr.business_group_id = :business_group_id
     and    :apr_effective_date
            between apr.effective_start_date
            and     apr.effective_end_date
     and    apr.actl_prem_id = apv.actl_prem_id
     and    apv.business_group_id = apr.business_group_id
     and    :apv_effective_date
            between apv.effective_start_date
            and     apv.effective_end_date
     and    apv.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
     and    vpf.business_group_id = apr.business_group_id
     and    :vpf_effective_date
            between vpf.effective_start_date
            and     vpf.effective_end_date';
    --
    l_cvg_sql          VARCHAR2(2000)
      := 'select sum(decode(vpf.rt_age_flag,''Y'',1,0)),
            sum(decode(vpf.rt_los_flag,''Y'',1,0)),
            sum(decode(vpf.rt_comp_lvl_flag,''Y'',1,0)),
            sum(decode(vpf.rt_pct_fl_tm_flag,''Y'',1,0)),
            sum(decode(vpf.rt_hrs_wkd_flag,''Y'',1,0)),
            sum(decode(vpf.rt_cmbn_age_los_flag,''Y'',1,0))
     from   ben_vrbl_rt_prfl_f vpf,
            ben_bnft_vrbl_rt_f bvr,
            ben_cvg_amt_calc_mthd_f ccm
     where  ccm.{OBJECT} = :cobj_id
     and    ccm.business_group_id = :business_group_id
     and    :ccm_effective_date
            between ccm.effective_start_date
            and     ccm.effective_end_date
     and    ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
     and    bvr.business_group_id = ccm.business_group_id
     and    :bvr_effective_date
            between bvr.effective_start_date
            and     bvr.effective_end_date
     and    bvr.vrbl_rt_prfl_id = vpf.vrbl_rt_prfl_id
     and    vpf.business_group_id = bvr.business_group_id
     and    :vpf_effective_date
            between vpf.effective_start_date
            and     vpf.effective_end_date';
    --
    l_opt_sql         VARCHAR2(2000)
      := 'select opt_id
      from  ben_oipl_f otp
      where otp.oipl_id = :otp_oipl_id
      and   :otp_effective_date
            between otp.effective_start_date
            and     otp.effective_end_date
      and   otp.business_group_id = :business_group_id' ;
    --
  BEGIN
    --
    hr_utility.set_location('Entering ' || l_package, 10);
    --
    IF p_drvbl_fctr_prtn_elig_flag = 'Y' THEN
      --
      ben_elp_cache.cobcep_getdets(p_business_group_id=> p_business_group_id
       ,p_effective_date    => p_effective_date
       ,p_pgm_id            => p_pgm_id
       ,p_pl_id             => p_pl_id
       ,p_oipl_id           => p_oipl_id
       ,p_plip_id           => p_plip_id
       ,p_ptip_id           => p_ptip_id
       ,p_inst_set          => l_eligprof_dets
       ,p_inst_count        => l_inst_count);
      --
      -- Loop through all profiles and set the boolean expressions on if the flag
      -- is set.
      --
      IF l_inst_count > 0 THEN
        --
        FOR l_count IN l_eligprof_dets.FIRST .. l_eligprof_dets.LAST LOOP
          --
          IF     l_eligprof_dets(l_count).elig_age_flag = 'Y'
             AND NOT l_age_flag THEN
            --
            l_age_flag  := TRUE;
          --
          END IF;
          --
          IF     l_eligprof_dets(l_count).elig_los_flag = 'Y'
             AND NOT l_los_flag THEN
            --
            l_los_flag  := TRUE;
          --
          END IF;
          --
          IF     l_eligprof_dets(l_count).elig_comp_lvl_flag = 'Y'
             AND NOT l_cmp_flag THEN
            --
            l_cmp_flag  := TRUE;
          --
          END IF;
          --
          IF     l_eligprof_dets(l_count).elig_pct_fl_tm_flag = 'Y'
             AND NOT l_pft_flag THEN
            --
            l_pft_flag  := TRUE;
          --
          END IF;
          --
          IF     l_eligprof_dets(l_count).elig_hrs_wkd_flag = 'Y'
             AND NOT l_hrw_flag THEN
            --
            l_hrw_flag  := TRUE;
          --
          END IF;
          --
          IF     l_eligprof_dets(l_count).elig_cmbn_age_los_flag = 'Y'
             AND NOT l_cal_flag THEN
            --
            l_cal_flag  := TRUE;
          --
          END IF;
        --
        END LOOP;
        --
        IF l_age_flag THEN
          --
          l_flag_bit_val  :=
                           l_flag_bit_val + ben_manage_life_events.g_age_flag;
        --
        END IF;
        --
        IF l_los_flag THEN
          --
          l_flag_bit_val  :=
                           l_flag_bit_val + ben_manage_life_events.g_los_flag;
        --
        END IF;
        --
        IF l_cmp_flag THEN
          --
          l_flag_bit_val  :=
                           l_flag_bit_val + ben_manage_life_events.g_cmp_flag;
        --
        END IF;
        --
        IF l_pft_flag THEN
          --
          l_flag_bit_val  :=
                           l_flag_bit_val + ben_manage_life_events.g_pft_flag;
        --
        END IF;
        --
        IF l_hrw_flag THEN
          --
          l_flag_bit_val  :=
                           l_flag_bit_val + ben_manage_life_events.g_hrw_flag;
        --
        END IF;
        --
        IF l_cal_flag THEN
          --
          l_flag_bit_val  :=
                           l_flag_bit_val + ben_manage_life_events.g_cal_flag;
        --
        END IF;
      --
      END IF;
    --
    END IF;
    --
    hr_utility.set_location('Attempting to set drvbl_fctr_apls_rts_flag ' ||
                              l_package
     ,10);
    --
    -- OIPLIP are special cases so we have to check if there are rates attached
    --
    IF    p_drvbl_fctr_apls_rts_flag = 'Y'
       OR p_oiplip_id IS NOT NULL THEN
      --
      -- BUILD SQL statement, we have to bind just the column name
      --
      IF p_pgm_id IS NOT NULL THEN
        --
        l_sql     := REPLACE(l_sql, '{OBJECT}', 'pgm_id');
/*
        l_sql     := REPLACE(l_sql, '{OBJECT_VALUE}', p_pgm_id);
*/
        l_cobj_id := p_pgm_id;
        --
      ELSIF p_pl_id IS NOT NULL THEN
        --
        l_sql      := REPLACE(l_sql, '{OBJECT}', 'pl_id');
/*
        l_sql      := REPLACE(l_sql, '{OBJECT_VALUE}', p_pl_id);
*/
        l_prem_sql := REPLACE(l_prem_sql, '{OBJECT}', 'pl_id');
/*
        l_prem_sql := REPLACE(l_prem_sql, '{OBJECT_VALUE}', p_pl_id);
*/
        l_cvg_sql  := REPLACE(l_cvg_sql, '{OBJECT}', 'pl_id');
/*
        l_cvg_sql  := REPLACE(l_cvg_sql, '{OBJECT_VALUE}', p_pl_id);
*/
        l_cobj_id  := p_pl_id;
        --
      ELSIF p_oipl_id IS NOT NULL THEN
        --
        l_sql      := REPLACE(l_sql, '{OBJECT}', 'oipl_id');
/*
        l_sql      := REPLACE(l_sql, '{OBJECT_VALUE}', p_oipl_id);
*/
        l_prem_sql := REPLACE(l_prem_sql, '{OBJECT}', 'oipl_id');
/*
        l_prem_sql := REPLACE(l_prem_sql, '{OBJECT_VALUE}', p_oipl_id);
*/
        l_cvg_sql  := REPLACE(l_cvg_sql, '{OBJECT}', 'oipl_id');
/*
        l_cvg_sql  := REPLACE(l_cvg_sql, '{OBJECT_VALUE}', p_oipl_id);
*/
        l_cobj_id  := p_oipl_id;
        --
      ELSIF p_plip_id IS NOT NULL THEN
        --
        l_sql     := REPLACE(l_sql, '{OBJECT}', 'plip_id');
/*
        l_sql     := REPLACE(l_sql, '{OBJECT_VALUE}', p_plip_id);
*/
        l_cvg_sql := REPLACE(l_cvg_sql, '{OBJECT}', 'plip_id');
/*
        l_cvg_sql := REPLACE(l_cvg_sql, '{OBJECT_VALUE}', p_plip_id);
*/
        l_cobj_id := p_plip_id;
        --
      ELSIF p_ptip_id IS NOT NULL THEN
        --
        l_sql  := REPLACE(l_sql, '{OBJECT}', 'ptip_id');
/*
        l_sql  := REPLACE(l_sql, '{OBJECT_VALUE}', p_ptip_id);
*/
        l_cobj_id := p_ptip_id;
      --
      ELSIF p_oiplip_id IS NOT NULL THEN
        --
        l_sql  := REPLACE(l_sql, '{OBJECT}', 'oiplip_id');
/*
        l_sql  := REPLACE(l_sql, '{OBJECT_VALUE}', p_oiplip_id);
*/
        l_cobj_id := p_oiplip_id;
      --
      END IF;
      --
      -- Dynamically bind the rest of the variables
      --
      IF    p_pl_id IS NOT NULL
         OR p_oipl_id IS NOT NULL THEN
        --
        EXECUTE IMMEDIATE l_sql
          INTO l_oipl_abr_count, l_age_rt_flag, l_los_rt_flag, l_cmp_rt_flag, l_pft_rt_flag, l_hrw_rt_flag, l_cal_rt_flag
          USING l_cobj_id
           ,p_business_group_id
           ,p_effective_date
           ,p_effective_date
           ,p_effective_date;
        --
        --START Option Level Rates
        if l_oipl_abr_count = 0 and p_oipl_id is not null then
          --
          EXECUTE IMMEDIATE l_opt_sql
            INTO l_opt_id
            USING p_oipl_id
                 ,p_effective_date
                 ,p_business_group_id ;
          --
          if l_opt_id is not null then
            --
            l_sql      := REPLACE(l_sql, '{OBJECT}', 'opt_id');
            --
            EXECUTE IMMEDIATE l_sql
              INTO l_oipl_abr_count, l_age_rt_flag, l_los_rt_flag, l_cmp_rt_flag,
                   l_pft_rt_flag, l_hrw_rt_flag, l_cal_rt_flag
              USING l_opt_id
                   ,p_business_group_id
                   ,p_effective_date
                   ,p_effective_date
                   ,p_effective_date;
            --
          end if;
          --
        end if;
        --END Option Level Rates
        --
        EXECUTE IMMEDIATE l_prem_sql
          INTO l_prem_age_rt_flag, l_prem_los_rt_flag, l_prem_cmp_rt_flag, l_prem_pft_rt_flag, l_prem_hrw_rt_flag, l_prem_cal_rt_flag
          USING l_cobj_id
           ,p_business_group_id
           ,p_effective_date
           ,p_effective_date
           ,p_effective_date;
        EXECUTE IMMEDIATE l_cvg_sql
          INTO l_cvg_age_rt_flag, l_cvg_los_rt_flag, l_cvg_cmp_rt_flag, l_cvg_pft_rt_flag, l_cvg_hrw_rt_flag, l_cvg_cal_rt_flag
          USING l_cobj_id
           ,p_business_group_id
           ,p_effective_date
           ,p_effective_date
           ,p_effective_date;
        --
        l_age_rt_flag  :=
          NVL(l_age_rt_flag, 0) + NVL(l_prem_age_rt_flag, 0) +
            NVL(l_cvg_age_rt_flag, 0);
        --
        l_los_rt_flag  :=
          NVL(l_los_rt_flag, 0) + NVL(l_prem_los_rt_flag, 0) +
            NVL(l_cvg_los_rt_flag, 0);
        --
        l_cmp_rt_flag  :=
          NVL(l_cmp_rt_flag, 0) + NVL(l_prem_cmp_rt_flag, 0) +
            NVL(l_cvg_cmp_rt_flag, 0);
        --
        l_pft_rt_flag  :=
          NVL(l_pft_rt_flag, 0) + NVL(l_prem_pft_rt_flag, 0) +
            NVL(l_cvg_pft_rt_flag, 0);
        --
        l_hrw_rt_flag  :=
          NVL(l_hrw_rt_flag, 0) + NVL(l_prem_hrw_rt_flag, 0) +
            NVL(l_cvg_hrw_rt_flag, 0);
        --
        l_cal_rt_flag  :=
          NVL(l_cal_rt_flag, 0) + NVL(l_prem_cal_rt_flag, 0) +
            NVL(l_cvg_cal_rt_flag, 0);
      --
      ELSIF p_plip_id IS NOT NULL THEN
        --
        EXECUTE IMMEDIATE l_sql
          INTO l_oipl_abr_count,l_age_rt_flag, l_los_rt_flag, l_cmp_rt_flag, l_pft_rt_flag, l_hrw_rt_flag, l_cal_rt_flag
          USING l_cobj_id
           ,p_business_group_id
           ,p_effective_date
           ,p_effective_date
           ,p_effective_date;
        EXECUTE IMMEDIATE l_cvg_sql
          INTO l_cvg_age_rt_flag, l_cvg_los_rt_flag, l_cvg_cmp_rt_flag, l_cvg_pft_rt_flag, l_cvg_hrw_rt_flag, l_cvg_cal_rt_flag
          USING l_cobj_id
           ,p_business_group_id
           ,p_effective_date
           ,p_effective_date
           ,p_effective_date;
        --
        l_age_rt_flag  := NVL(l_age_rt_flag, 0) + NVL(l_cvg_age_rt_flag, 0);
        --
        l_los_rt_flag  := NVL(l_los_rt_flag, 0) + NVL(l_cvg_los_rt_flag, 0);
        --
        l_cmp_rt_flag  := NVL(l_cmp_rt_flag, 0) + NVL(l_cvg_cmp_rt_flag, 0);
        --
        l_pft_rt_flag  := NVL(l_pft_rt_flag, 0) + NVL(l_cvg_pft_rt_flag, 0);
        --
        l_hrw_rt_flag  := NVL(l_hrw_rt_flag, 0) + NVL(l_cvg_hrw_rt_flag, 0);
        --
        l_cal_rt_flag  := NVL(l_cal_rt_flag, 0) + NVL(l_cvg_cal_rt_flag, 0);
      --
      ELSE
        --
        EXECUTE IMMEDIATE l_sql
          INTO l_oipl_abr_count, l_age_rt_flag, l_los_rt_flag, l_cmp_rt_flag, l_pft_rt_flag, l_hrw_rt_flag, l_cal_rt_flag
          USING l_cobj_id
           ,p_business_group_id
           ,p_effective_date
           ,p_effective_date
           ,p_effective_date;
      --
      END IF;
      --
      IF l_age_rt_flag > 0 THEN
        --
        l_flag_bit_val  :=
                        l_flag_bit_val + ben_manage_life_events.g_age_rt_flag;
      --
      END IF;
--
      IF l_los_rt_flag > 0 THEN
        --
        l_flag_bit_val  :=
                        l_flag_bit_val + ben_manage_life_events.g_los_rt_flag;
      --
      END IF;
--
      IF l_cmp_rt_flag > 0 THEN
        --
        l_flag_bit_val  :=
                        l_flag_bit_val + ben_manage_life_events.g_cmp_rt_flag;
      --
      END IF;
--
      IF l_pft_rt_flag > 0 THEN
        --
        l_flag_bit_val  :=
                        l_flag_bit_val + ben_manage_life_events.g_pft_rt_flag;
      --
      END IF;
--
      IF l_hrw_rt_flag > 0 THEN
        --
        l_flag_bit_val  :=
                        l_flag_bit_val + ben_manage_life_events.g_hrw_rt_flag;
      --
      END IF;
--
      IF l_cal_rt_flag > 0 THEN
        --
        l_flag_bit_val  :=
                        l_flag_bit_val + ben_manage_life_events.g_cal_rt_flag;
      --
      END IF;
    --
    END IF;
      hr_utility.set_location('l_flag_bit_val '|| l_flag_bit_val, 10);
    --
    -- If there is a derived factor attached to a comp object and the
    -- derivable factor parameter is 'NONE', set the derivable factor
    -- parameter to 'ASC' so the derived factor is evaluated.
    -- Bug 2894200.
    --
    if (l_flag_bit_val <> 0) AND (ben_manage_life_events.g_derivable_factors = 'NONE') then
      hr_utility.set_location('g_derivable_factors '|| ben_manage_life_events.g_derivable_factors, 10);
      ben_manage_life_events.g_derivable_factors := 'ASC';
      fnd_message.set_name('BEN','BEN_93605_RESET_DRVD_FCTR_PARM');
      benutils.write(p_text => fnd_message.get);
    end if;
    --
    RETURN l_flag_bit_val;
    --
    hr_utility.set_location('Leaving ' || l_package, 10);
  --
  END set_flag_bit_val;
--
  PROCEDURE load_cache(
    p_pl_id               IN NUMBER DEFAULT NULL
   ,p_pgm_id              IN NUMBER DEFAULT NULL
   ,p_oipl_id             IN NUMBER DEFAULT NULL
   ,p_plip_id             IN NUMBER DEFAULT NULL
   ,p_ptip_id             IN NUMBER DEFAULT NULL
   ,p_oiplip_id           IN NUMBER DEFAULT NULL
   ,p_pl_nip              IN VARCHAR2 DEFAULT 'N'
   ,p_trk_inelig_per_flag IN VARCHAR2 DEFAULT 'N'
   ,p_par_pgm_id          IN NUMBER DEFAULT NULL
   ,p_par_ptip_id         IN NUMBER DEFAULT NULL
   ,p_par_plip_id         IN NUMBER DEFAULT NULL
   ,p_par_pl_id           IN NUMBER DEFAULT NULL
   ,p_par_opt_id          IN NUMBER DEFAULT NULL
   ,p_flag_bit_val        IN BINARY_INTEGER DEFAULT NULL
   ,p_oiplip_flag_bit_val IN BINARY_INTEGER DEFAULT NULL) IS
    --
    l_package VARCHAR2(80) := g_package || '.load_cache';
    l_count   NUMBER;
  --
  BEGIN
    --
    hr_utility.set_location('Entering ' || l_package, 10);
    --
    -- Load cache with comp object details
    --
    IF NOT ben_manage_life_events.g_cache_proc_object.EXISTS(1) THEN
      --
      l_count  := 1;
    --
    ELSE
      --
      l_count  := ben_manage_life_events.g_cache_proc_object.LAST + 1;
    --
    END IF;
    --
    ben_manage_life_events.g_cache_proc_object(l_count).pl_id                :=
                                                                       p_pl_id;
    ben_manage_life_events.g_cache_proc_object(l_count).pgm_id               :=
                                                                      p_pgm_id;
    ben_manage_life_events.g_cache_proc_object(l_count).oipl_id              :=
                                                                     p_oipl_id;
    ben_manage_life_events.g_cache_proc_object(l_count).plip_id              :=
                                                                     p_plip_id;
    ben_manage_life_events.g_cache_proc_object(l_count).ptip_id              :=
                                                                     p_ptip_id;
    ben_manage_life_events.g_cache_proc_object(l_count).oiplip_id            :=
                                                                   p_oiplip_id;
    ben_manage_life_events.g_cache_proc_object(l_count).pl_nip               :=
                                                                      p_pl_nip;
    ben_manage_life_events.g_cache_proc_object(l_count).trk_inelig_per_flag  :=
                                                         p_trk_inelig_per_flag;
    ben_manage_life_events.g_cache_proc_object(l_count).par_pgm_id           :=
                                                                  p_par_pgm_id;
    ben_manage_life_events.g_cache_proc_object(l_count).par_ptip_id          :=
                                                                 p_par_ptip_id;
    ben_manage_life_events.g_cache_proc_object(l_count).par_plip_id          :=
                                                                 p_par_plip_id;
    ben_manage_life_events.g_cache_proc_object(l_count).par_pl_id            :=
                                                                   p_par_pl_id;
    ben_manage_life_events.g_cache_proc_object(l_count).par_opt_id           :=
                                                                  p_par_opt_id;
    ben_manage_life_events.g_cache_proc_object(l_count).flag_bit_val         :=
                                                                p_flag_bit_val;
    ben_manage_life_events.g_cache_proc_object(l_count).oiplip_flag_bit_val  :=
                                                         p_oiplip_flag_bit_val;
    --
    hr_utility.set_location('Leaving ' || l_package, 10);
  --
  END load_cache;
--
  PROCEDURE cache_working_data(
    p_business_group_id IN NUMBER
   ,p_effective_date    IN DATE) IS
    --
    l_package     VARCHAR2(80)           := g_package || '.cache_working_data';
    l_meaning     hr_lookups.meaning%TYPE;
    l_lookup_code hr_lookups.lookup_code%TYPE;
    l_ler_id      ben_ler_f.ler_id%TYPE;
    --
    CURSOR c_comp_object_meanings IS
      SELECT   hr.meaning
              ,hr.lookup_code
      FROM     hr_lookups hr
      WHERE    hr.lookup_type = 'BEN_COMP_OBJ'
      AND      hr.enabled_flag = 'Y'
      AND      p_effective_date BETWEEN NVL(hr.start_date_active
                                         ,p_effective_date)
                   AND NVL(hr.end_date_active, p_effective_date)
      AND      hr.lookup_code IN ('PLIP', 'PGM', 'PLTYP', 'PTIP', 'PL', 'OIPL');
  --
  BEGIN
    --
    hr_utility.set_location('Entering ' || l_package, 10);
    --
    -- Set up cache details for all comp object types
    --
    OPEN c_comp_object_meanings;
    --
    LOOP
      --
      -- Fetch all values from the cursor and cache depending on code
      --
      FETCH c_comp_object_meanings INTO l_meaning, l_lookup_code;
      EXIT WHEN c_comp_object_meanings%NOTFOUND;
      --
      IF l_lookup_code = 'PLIP' THEN
        --
        ben_manage_life_events.g_cache_comp_objects.plip  := l_meaning;
      --
      ELSIF l_lookup_code = 'PGM' THEN
        --
        ben_manage_life_events.g_cache_comp_objects.pgm  := l_meaning;
      --
      ELSIF l_lookup_code = 'PLTYP' THEN
        --
        ben_manage_life_events.g_cache_comp_objects.pltyp  := l_meaning;
      --
      ELSIF l_lookup_code = 'PTIP' THEN
        --
        ben_manage_life_events.g_cache_comp_objects.ptip  := l_meaning;
      --
      ELSIF l_lookup_code = 'PL' THEN
        --
        ben_manage_life_events.g_cache_comp_objects.pl  := l_meaning;
      --
      ELSIF l_lookup_code = 'OIPL' THEN
        --
        ben_manage_life_events.g_cache_comp_objects.oipl  := l_meaning;
      --
      END IF;
    --
    END LOOP;
    --
    CLOSE c_comp_object_meanings;
    --
    ben_manage_life_events.g_cached_objects  := TRUE;
    --
    hr_utility.set_location('Leaving ' || l_package, 10);
  --
  END cache_working_data;
--
  PROCEDURE write_multi_session_cache(
    p_effective_date    IN     DATE
   ,p_business_group_id IN     NUMBER
   ,p_mode              in     varchar2
   ,p_pgm_id            IN     NUMBER
   ,p_pl_id             IN     NUMBER
   ,p_no_programs       in     varchar2
   ,p_no_plans          in     varchar2
   ,p_pl_typ_id         IN     NUMBER
   --
   ,p_comp_obj_cache_id OUT NOCOPY    NUMBER
   )
  IS
    --
    PRAGMA AUTONOMOUS_TRANSACTION;
    --
    l_package           VARCHAR2(80)
                                  := g_package || '.write_multi_session_cache';
    --
    l_comp_obj_cache_row_id_va benutils.g_number_table := benutils.g_number_table();
    l_comp_obj_cache_id_va     benutils.g_number_table := benutils.g_number_table();
    l_pl_id_va                 benutils.g_number_table := benutils.g_number_table();
    l_pgm_id_va                benutils.g_number_table := benutils.g_number_table();
    l_oipl_id_va               benutils.g_number_table := benutils.g_number_table();
    l_ptip_id_va               benutils.g_number_table := benutils.g_number_table();
    l_plip_id_va               benutils.g_number_table := benutils.g_number_table();
    l_pl_nip_va                benutils.g_v2_30_table  := benutils.g_v2_30_table();
    l_elig_tran_state_va       benutils.g_v2_30_table  := benutils.g_v2_30_table();
    l_trk_inelig_per_flag_va   benutils.g_v2_30_table  := benutils.g_v2_30_table();
    l_par_pgm_id_va            benutils.g_number_table := benutils.g_number_table();
    l_par_ptip_id_va           benutils.g_number_table := benutils.g_number_table();
    l_par_plip_id_va           benutils.g_number_table := benutils.g_number_table();
    l_par_pl_id_va             benutils.g_number_table := benutils.g_number_table();
    l_par_opt_id_va            benutils.g_number_table := benutils.g_number_table();
    l_flag_bit_val_va          benutils.g_number_table := benutils.g_number_table();
    l_oiplip_flag_bit_val_va   benutils.g_number_table := benutils.g_number_table();
    l_oiplip_id_va             benutils.g_number_table := benutils.g_number_table();
    --
    l_comp_obj_cache_id NUMBER;
    l_count number;
    l_seqnextval number;
    --
    cursor c_getseq
    is
      select ben_comp_obj_cache_row_s.nextval
      from sys.dual;

    --
  BEGIN
    --
    INSERT INTO ben_comp_obj_cache
                (
                  comp_obj_cache_id
                 ,effective_date
                 ,business_group_id
                 ,timestamp
                 ,mode_cd
                 ,pgm_id
                 ,pl_id
                 ,no_programs
                 ,no_plans
                 ,pl_typ_id)
         VALUES(
           ben_comp_obj_cache_s.nextval
          ,p_effective_date
          ,p_business_group_id
          ,SYSDATE
          ,p_mode
          ,p_pgm_id
          ,p_pl_id
          ,p_no_programs
          ,p_no_plans
          ,p_pl_typ_id
          )
      RETURNING comp_obj_cache_id
      INTO l_comp_obj_cache_id;
    --
    COMMIT;
    --
    select count(*) into l_count
    from ben_comp_obj_cache
    where business_group_id = p_business_group_id
    and effective_date = p_effective_date;

    IF ben_manage_life_events.g_cache_proc_object.COUNT > 0 THEN
      --
      -- Add details to varray
      --
      FOR ele_num IN
        ben_manage_life_events.g_cache_proc_object.FIRST
        .. ben_manage_life_events.g_cache_proc_object.LAST
      LOOP
        --
        open c_getseq;
        fetch c_getseq into l_seqnextval;
        close c_getseq;
        --
        l_comp_obj_cache_row_id_va.extend(1);
        l_comp_obj_cache_row_id_va(ele_num) := l_seqnextval;
        --
        l_comp_obj_cache_id_va.extend(1);
        l_comp_obj_cache_id_va(ele_num) := l_comp_obj_cache_id;
        --
        l_pl_id_va.extend(1);
        l_pl_id_va(ele_num) := ben_manage_life_events.g_cache_proc_object(ele_num).pl_id;
        --
        l_pgm_id_va.extend(1);
        l_pgm_id_va(ele_num) := ben_manage_life_events.g_cache_proc_object(ele_num).pgm_id;
        --
        l_oipl_id_va.extend(1);
        l_oipl_id_va(ele_num) := ben_manage_life_events.g_cache_proc_object(ele_num).oipl_id;
        --
        l_ptip_id_va.extend(1);
        l_ptip_id_va(ele_num) := ben_manage_life_events.g_cache_proc_object(ele_num).ptip_id;
        --
        l_plip_id_va.extend(1);
        l_plip_id_va(ele_num) := ben_manage_life_events.g_cache_proc_object(ele_num).plip_id;
        --
        l_pl_nip_va.extend(1);
        l_pl_nip_va(ele_num) := ben_manage_life_events.g_cache_proc_object(ele_num).pl_nip;
        --
        l_elig_tran_state_va.extend(1);
        l_elig_tran_state_va(ele_num) := ben_manage_life_events.g_cache_proc_object(ele_num).elig_tran_state;
        --
        l_trk_inelig_per_flag_va.extend(1);
        l_trk_inelig_per_flag_va(ele_num) := ben_manage_life_events.g_cache_proc_object(ele_num).trk_inelig_per_flag;
        --
        l_par_pgm_id_va.extend(1);
        l_par_pgm_id_va(ele_num) := ben_manage_life_events.g_cache_proc_object(ele_num).par_pgm_id;
        --
        l_par_ptip_id_va.extend(1);
        l_par_ptip_id_va(ele_num) := ben_manage_life_events.g_cache_proc_object(ele_num).par_ptip_id;
        --
        l_par_plip_id_va.extend(1);
        l_par_plip_id_va(ele_num) := ben_manage_life_events.g_cache_proc_object(ele_num).par_plip_id;
        --
        l_par_pl_id_va.extend(1);
        l_par_pl_id_va(ele_num) := ben_manage_life_events.g_cache_proc_object(ele_num).par_pl_id;
        --
        l_par_opt_id_va.extend(1);
        l_par_opt_id_va(ele_num) := ben_manage_life_events.g_cache_proc_object(ele_num).par_opt_id;
        --
        l_flag_bit_val_va.extend(1);
        l_flag_bit_val_va(ele_num) := ben_manage_life_events.g_cache_proc_object(ele_num).flag_bit_val;
        --
        l_oiplip_flag_bit_val_va.extend(1);
        l_oiplip_flag_bit_val_va(ele_num) := ben_manage_life_events.g_cache_proc_object(ele_num).oiplip_flag_bit_val;
        --
        l_oiplip_id_va.extend(1);
        l_oiplip_id_va(ele_num) := ben_manage_life_events.g_cache_proc_object(ele_num).oiplip_id;
        --
      END LOOP;
      --
      if l_comp_obj_cache_row_id_va.count > 0 then
        --
        FORALL i IN l_comp_obj_cache_row_id_va.FIRST .. l_comp_obj_cache_row_id_va.LAST
          INSERT INTO ben_comp_obj_cache_row
            (comp_obj_cache_row_id
            ,comp_obj_cache_id
            ,pl_id
            ,pgm_id
            ,oipl_id
            ,ptip_id
            ,plip_id
            ,pl_nip
            ,elig_tran_state
            ,trk_inelig_per_flag
            ,par_pgm_id
            ,par_ptip_id
            ,par_plip_id
            ,par_pl_id
            ,par_opt_id
            ,flag_bit_val
            ,oiplip_flag_bit_val
            ,oiplip_id
            )
          VALUES
            (l_comp_obj_cache_row_id_va(i)
            ,l_comp_obj_cache_id_va(i)
            ,l_pl_id_va(i)
            ,l_pgm_id_va(i)
            ,l_oipl_id_va(i)
            ,l_ptip_id_va(i)
            ,l_plip_id_va(i)
            ,l_pl_nip_va(i)
            ,l_elig_tran_state_va(i)
            ,l_trk_inelig_per_flag_va(i)
            ,l_par_pgm_id_va(i)
            ,l_par_ptip_id_va(i)
            ,l_par_plip_id_va(i)
            ,l_par_pl_id_va(i)
            ,l_par_opt_id_va(i)
            ,l_flag_bit_val_va(i)
            ,l_oiplip_flag_bit_val_va(i)
            ,l_oiplip_id_va(i)
            );
      --
      end if;
      --
    end if;
    --
    COMMIT;
    p_comp_obj_cache_id := l_comp_obj_cache_id;
  END write_multi_session_cache;
--
  PROCEDURE flush_multi_session_cache(
    p_effective_date    IN DATE DEFAULT NULL
   ,p_business_group_id  IN NUMBER DEFAULT NULL
   ,p_mode              IN varchar2) IS
    --bug 7700173, added p_mode parameter to flush_multi_session_cache

    --
    PRAGMA AUTONOMOUS_TRANSACTION;
    --
    l_package VARCHAR2(80) := g_package || '.flush_multi_session_cache';
    --
    l_coc_id_va benutils.g_number_table := benutils.g_number_table();
    --
    cursor c_flushcocs
      (c_bgp_id   number
      ,c_eff_date date
      )
    is
      select coc.comp_obj_cache_id
      from   ben_comp_obj_cache coc
      where  coc.business_group_id = c_bgp_id
      and    coc.effective_date = c_eff_date
      and    coc.mode_cd = p_mode;        --bug 7700173
    --
  BEGIN
    --
    IF p_business_group_id IS NOT NULL
      and p_effective_date IS NOT NULL
    THEN
      --
      open c_flushcocs
        (c_bgp_id   => p_business_group_id
        ,c_eff_date => p_effective_date
        );
      fetch c_flushcocs BULK COLLECT INTO l_coc_id_va;
      close c_flushcocs;
      --
      if l_coc_id_va.count > 0
      then
        --
        forall ccrelenum in l_coc_id_va.first..l_coc_id_va.last
          delete from ben_comp_obj_cache_row ccr
          where ccr.comp_obj_cache_id = l_coc_id_va(ccrelenum);
        --
      end if;
      --

/*
      DELETE
        FROM ben_comp_obj_cache_row cjr
       WHERE EXISTS(SELECT   NULL
                    FROM     ben_comp_obj_cache cjc
                    WHERE    cjc.comp_obj_cache_id = cjr.comp_obj_cache_id
                    AND      cjc.business_group_id = p_business_group_id
                    AND      cjc.effective_date = p_effective_date
                    );
      --
*/
      DELETE
        FROM ben_comp_obj_cache
       WHERE business_group_id = p_business_group_id
       AND   effective_date = p_effective_date
       AND   mode_cd = p_mode ;     --bug 7700173
    --
    ELSE
      --
      DELETE
        FROM ben_comp_obj_cache_row cjr;
      --
      DELETE
        FROM ben_comp_obj_cache;
    --
    END IF;
    --
    COMMIT;
  --
  END flush_multi_session_cache;
--
  PROCEDURE build_comp_object_list(
    p_benefit_action_id      IN NUMBER DEFAULT -1
   ,p_comp_selection_rule_id IN NUMBER DEFAULT NULL
   ,p_effective_date         IN DATE
   ,p_pgm_id                 IN NUMBER DEFAULT NULL
   ,p_business_group_id      IN NUMBER DEFAULT NULL
   ,p_pl_id                  IN NUMBER DEFAULT NULL
   ,p_oipl_id                IN NUMBER DEFAULT NULL
   --
   -- PB : 5422 :
   -- Pass on the asnd_lf_evt_dt
   --
   ,p_asnd_lf_evt_dt         IN DATE DEFAULT NULL
   -- ,p_popl_enrt_typ_cycl_id  IN NUMBER DEFAULT NULL
   ,p_no_programs            IN VARCHAR2 DEFAULT 'N'
   ,p_no_plans               IN VARCHAR2 DEFAULT 'N'
   ,p_rptg_grp_id            IN NUMBER DEFAULT NULL
   ,p_pl_typ_id              IN NUMBER DEFAULT NULL
   ,p_opt_id                 IN NUMBER DEFAULT NULL
   ,p_eligy_prfl_id          IN NUMBER DEFAULT NULL
   ,p_vrbl_rt_prfl_id        IN NUMBER DEFAULT NULL
   ,p_thread_id              IN NUMBER DEFAULT NULL
   ,p_mode                   IN VARCHAR2
   --
   -- PB : Helathnet change
   --
   ,p_person_id              in number default null
   ,p_lmt_prpnip_by_org_flag in varchar2 default 'N') IS
    --
    l_package               VARCHAR2(80)
                                     := g_package || '.build_comp_object_list';
    --
    l_per_org_id           NUMBER;
    --
    TYPE cur_type IS REF CURSOR;
    c_chgdata               cur_type;
    --
    TYPE v2_set IS TABLE OF VARCHAR2(30)
      INDEX BY BINARY_INTEGER;
    --
    type pgm_rec is record
      (pgm_id                    ben_pgm_f.pgm_id%type
      ,drvbl_fctr_prtn_elig_flag ben_pgm_f.drvbl_fctr_prtn_elig_flag%type
      ,drvbl_fctr_apls_rts_flag  ben_pgm_f.drvbl_fctr_apls_rts_flag%type
      ,trk_inelig_per_flag       ben_pgm_f.trk_inelig_per_flag%type
      );
    --
    l_plninst_set           ben_pln_cache.g_bgppln_cache;
    l_copinst_set           ben_cop_cache.g_bgpcop_cache;
    --
    l_oipl_id               ben_oipl_f.oipl_id%TYPE;
    l_pl_id                 ben_pl_f.pl_id%TYPE;
    l_pgm_id                ben_pgm_f.pgm_id%TYPE;
    l_pgm                   pgm_rec;
    l_pln                   ben_pln_cache.g_bgppln_rec;
    l_cop                   ben_cop_cache.g_bgpcop_rec;
    l_plip                  ben_plip_f%ROWTYPE;
    l_ptip                  ben_ptip_f%ROWTYPE;
    l_opt                   ben_opt_f%ROWTYPE;
    l_oiplip                ben_oiplip_f%ROWTYPE;
    l_epa                   ben_prtn_elig_f%ROWTYPE;
    l_plnnip_set            ben_pln_cache.g_nipplnpln_cache;
    l_inst_count            NUMBER;
    l_plnrow_num            BINARY_INTEGER;
    --
    l_ptp_opt_typ_cd        varchar2(30);
    --
    CURSOR c_pgm
    IS
      select pgm.pgm_id,
             pgm.drvbl_fctr_prtn_elig_flag,
             pgm.drvbl_fctr_apls_rts_flag,
             pgm.trk_inelig_per_flag
      FROM   --  ben_popl_yr_perd cpy
              ben_pgm_f pgm
             -- ,ben_yr_perd yrp
      WHERE    pgm.business_group_id = p_business_group_id
      AND      pgm.pgm_id = NVL(p_pgm_id, pgm.pgm_id)
      AND      pgm.pgm_stat_cd = 'A'
      AND      (
                    pgm.pgm_typ_cd NOT IN ('COBRANFLX', 'COBRAFLX')
                 OR p_mode NOT IN ('L', 'U'))
      -- GRADE/STEP
      AND      ( (p_mode in('T', 'G') and pgm.pgm_typ_cd = 'GSP') OR
                 (p_mode <> 'G' and pgm.pgm_typ_cd <> 'GSP')
               )
      AND      p_effective_date BETWEEN pgm.effective_start_date
                   AND pgm.effective_end_date
      AND  p_mode not in ('D','I')
      AND (p_mode = 'G' or
           exists (select null
                   from   ben_yr_perd yrp,
                          ben_popl_yr_perd cpy
                   where  cpy.pgm_id = pgm.pgm_id
                   AND    cpy.yr_perd_id = yrp.yr_perd_id
                   AND    cpy.business_group_id = pgm.business_group_id
                   AND    p_effective_date BETWEEN yrp.start_date AND yrp.end_date))

      AND      pgm.alws_unrstrctd_enrt_flag =
                         DECODE(p_mode, 'U', 'Y', pgm.alws_unrstrctd_enrt_flag)
      /* Make sure that program being linked to covers all the
         plan types that may or may not have been stated by the
         user. (PTIP)*/
      AND      (
                    EXISTS
                    (SELECT   NULL
                     FROM     ben_ptip_f ctp
                     WHERE    ctp.pgm_id = pgm.pgm_id
                     AND      ctp.pl_typ_id = NVL(p_pl_typ_id, ctp.pl_typ_id)
                     AND      ctp.business_group_id = pgm.business_group_id
                     AND      p_effective_date BETWEEN ctp.effective_start_date
                                  AND ctp.effective_end_date
/* Make sure that the plan type in program is of the
   variable rate profile that has been specified by
   the user. */
                     AND      (
                                   EXISTS
                                   (SELECT   NULL
                                    FROM     ben_acty_base_rt_f abr
                                            ,ben_acty_vrbl_rt_f avr
                                            ,ben_vrbl_rt_prfl_f vpf
                                    WHERE    abr.ptip_id = ctp.ptip_id
                                    AND      abr.business_group_id =
                                                        ctp.business_group_id
                                    AND      p_effective_date BETWEEN abr.effective_start_date
                                                 AND abr.effective_end_date
                                    AND      avr.acty_base_rt_id =
                                                          abr.acty_base_rt_id
                                    AND      avr.business_group_id =
                                                        abr.business_group_id
                                    AND      p_effective_date BETWEEN avr.effective_start_date
                                                 AND avr.effective_end_date
                                    AND      vpf.vrbl_rt_prfl_id =
                                                          avr.vrbl_rt_prfl_id
                                    AND      vpf.business_group_id =
                                                        avr.business_group_id
                                    AND      vpf.vrbl_rt_prfl_id =
                                                            p_vrbl_rt_prfl_id
                                    AND      p_effective_date BETWEEN vpf.effective_start_date
                                                 AND vpf.effective_end_date)
                                OR p_vrbl_rt_prfl_id IS NULL))
                 OR p_pl_typ_id IS NULL)
      /* Make sure that program being linked to covers all the
         plans that may or may not have been stated by the
         user. (PLIP)*/
      AND      (
                    EXISTS
                    (SELECT   NULL
                     FROM     ben_plip_f cpp
                     WHERE    cpp.pgm_id = pgm.pgm_id
                     AND      cpp.pl_id = NVL(p_pl_id, cpp.pl_id)
                     AND      cpp.business_group_id = pgm.business_group_id
                     AND      cpp.plip_stat_cd = 'A'
                     AND      p_effective_date BETWEEN cpp.effective_start_date
                                  AND cpp.effective_end_date
/* Make sure that plan being linked to is of the
   eligibility profile that has been specified by
   the user. */
                     AND      (
                                   EXISTS
                                   (SELECT   NULL
                                    FROM     ben_prtn_elig_f epa2
                                            ,ben_prtn_elig_prfl_f cep
                                            ,ben_eligy_prfl_f elp
                                    WHERE    epa2.pl_id = cpp.pl_id
                                    AND      epa2.business_group_id =
                                                        cpp.business_group_id
                                    AND      p_effective_date BETWEEN epa2.effective_start_date
                                                 AND epa2.effective_end_date
                                    AND      cep.prtn_elig_id =
                                                            epa2.prtn_elig_id
                                    AND      cep.business_group_id =
                                                       epa2.business_group_id
                                    AND      p_effective_date BETWEEN cep.effective_start_date
                                                 AND cep.effective_end_date
                                    AND      elp.eligy_prfl_id =
                                                            cep.eligy_prfl_id
                                    AND      elp.business_group_id =
                                                        cep.business_group_id
                                    AND      elp.eligy_prfl_id =
                                                              p_eligy_prfl_id
                                    AND      p_effective_date BETWEEN elp.effective_start_date
                                                 AND elp.effective_end_date)
                                OR p_eligy_prfl_id IS NULL)
/* Make sure that plan being linked to is of the
   reporting group that has been specified by
   the user. */
                     AND      (
                                   EXISTS
                                   (SELECT   NULL
                                    FROM     ben_rptg_grp bnr
                                            ,ben_popl_rptg_grp_f rgr
                                    WHERE    bnr.rptg_grp_id = p_rptg_grp_id
                                    AND      nvl(bnr.business_group_id,cpp.business_group_id) =
                                                        cpp.business_group_id
                                    AND      rgr.rptg_grp_id = bnr.rptg_grp_id
                                    AND      p_effective_date BETWEEN rgr.effective_start_date
                                                 AND rgr.effective_end_date
                                    AND      rgr.business_group_id =
                                                nvl(bnr.business_group_id,rgr.business_group_id)
                                    AND      rgr.pl_id = cpp.pl_id)
                                OR p_rptg_grp_id IS NULL)
/* Make sure that plan being linked to is of the
   variable rate profile that has been specified
   by the user. */
                     AND      (
                                   EXISTS
                                   (SELECT   NULL
                                    FROM     ben_acty_base_rt_f abr
                                            ,ben_acty_vrbl_rt_f avr
                                            ,ben_vrbl_rt_prfl_f vpf
                                    WHERE    abr.pl_id = cpp.pl_id
                                    AND      abr.business_group_id =
                                                        pgm.business_group_id
                                    AND      p_effective_date BETWEEN abr.effective_start_date
                                                 AND abr.effective_end_date
                                    AND      avr.acty_base_rt_id =
                                                          abr.acty_base_rt_id
                                    AND      avr.business_group_id =
                                                        abr.business_group_id
                                    AND      p_effective_date BETWEEN avr.effective_start_date
                                                 AND avr.effective_end_date
                                    AND      vpf.vrbl_rt_prfl_id =
                                                          avr.vrbl_rt_prfl_id
                                    AND      vpf.business_group_id =
                                                        avr.business_group_id
                                    AND      vpf.vrbl_rt_prfl_id =
                                                            p_vrbl_rt_prfl_id
                                    AND      p_effective_date BETWEEN vpf.effective_start_date
                                                 AND vpf.effective_end_date)
                                OR p_vrbl_rt_prfl_id IS NULL))
                 OR p_pl_id IS NULL)
      /* Make sure that program being linked to covers all the
         options that may or may not have been stated by the
         user. (OIPL) */
      AND      (
                    EXISTS
                    (SELECT   NULL
                     FROM     ben_oipl_f cop, ben_opt_f opt
                     WHERE    cop.pl_id = NVL(p_pl_id, cop.pl_id)
                     AND      cop.opt_id = p_opt_id
                     AND      cop.oipl_stat_cd = 'A'
                     AND      cop.business_group_id = pgm.business_group_id
                     AND      p_effective_date BETWEEN cop.effective_start_date
                                  AND cop.effective_end_date
                     AND      opt.opt_id = cop.opt_id
                     AND      opt.business_group_id = cop.business_group_id
                     AND      p_effective_date BETWEEN opt.effective_start_date
                                  AND opt.effective_end_date
/* Make sure that the option in the plan
   being linked to is of the eligibility
   profile that has been specified by the user. */
                     AND      (
                                   EXISTS
                                   (SELECT   NULL
                                    FROM     ben_prtn_elig_f epa2
                                            ,ben_prtn_elig_prfl_f cep
                                            ,ben_eligy_prfl_f elp
                                    WHERE    epa2.oipl_id = cop.oipl_id
                                    AND      epa2.business_group_id =
                                                        cop.business_group_id
                                    AND      p_effective_date BETWEEN epa2.effective_start_date
                                                 AND epa2.effective_end_date
                                    AND      cep.prtn_elig_id =
                                                            epa2.prtn_elig_id
                                    AND      cep.business_group_id =
                                                       epa2.business_group_id
                                    AND      p_effective_date BETWEEN cep.effective_start_date
                                                 AND cep.effective_end_date
                                    AND      elp.eligy_prfl_id =
                                                            cep.eligy_prfl_id
                                    AND      elp.business_group_id =
                                                        cep.business_group_id
                                    AND      elp.eligy_prfl_id =
                                                              p_eligy_prfl_id
                                    AND      p_effective_date BETWEEN elp.effective_start_date
                                                 AND elp.effective_end_date)
                                OR p_eligy_prfl_id IS NULL)
/* Make sure that the options in plan being
   linked to is of the variable rate profile
   that has been specified by the user. */
                     AND      (
                                   EXISTS
                                   (SELECT   NULL
                                    FROM     ben_acty_base_rt_f abr
                                            ,ben_acty_vrbl_rt_f avr
                                            ,ben_vrbl_rt_prfl_f vpf
                                    WHERE    abr.oipl_id = cop.oipl_id
                                    AND      abr.business_group_id =
                                                        cop.business_group_id
                                    AND      p_effective_date BETWEEN abr.effective_start_date
                                                 AND abr.effective_end_date
                                    AND      avr.acty_base_rt_id =
                                                          abr.acty_base_rt_id
                                    AND      avr.business_group_id =
                                                        abr.business_group_id
                                    AND      p_effective_date BETWEEN avr.effective_start_date
                                                 AND avr.effective_end_date
                                    AND      vpf.vrbl_rt_prfl_id =
                                                          avr.vrbl_rt_prfl_id
                                    AND      vpf.business_group_id =
                                                        avr.business_group_id
                                    AND      vpf.vrbl_rt_prfl_id =
                                                            p_vrbl_rt_prfl_id
                                    AND      p_effective_date BETWEEN vpf.effective_start_date
                                                 AND vpf.effective_end_date)
                                OR p_vrbl_rt_prfl_id IS NULL))
                 OR p_opt_id IS NULL)
      /* Make sure that program being linked to is of the
         variable rate profile that has been specified by the user. */
      AND      (
                    EXISTS
                    (SELECT   NULL
                     FROM     ben_acty_base_rt_f abr
                             ,ben_acty_vrbl_rt_f avr
                             ,ben_vrbl_rt_prfl_f vpf
                     WHERE    abr.pgm_id = pgm.pgm_id
                     AND      abr.business_group_id = pgm.business_group_id
                     AND      p_effective_date BETWEEN abr.effective_start_date
                                  AND abr.effective_end_date
                     AND      avr.acty_base_rt_id = abr.acty_base_rt_id
                     AND      avr.business_group_id = abr.business_group_id
                     AND      p_effective_date BETWEEN avr.effective_start_date
                                  AND avr.effective_end_date
                     AND      vpf.vrbl_rt_prfl_id = avr.vrbl_rt_prfl_id
                     AND      vpf.business_group_id = avr.business_group_id
                     AND      vpf.vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
                     AND      p_effective_date BETWEEN vpf.effective_start_date
                                  AND vpf.effective_end_date)
                 OR p_vrbl_rt_prfl_id IS NULL)
      /* Make sure that program being linked to is of the
         reporting group that has been specified by the user. */
      AND      (
                    EXISTS
                    (SELECT   NULL
                     FROM     ben_rptg_grp bnr, ben_popl_rptg_grp_f rgr
                     WHERE    bnr.rptg_grp_id = p_rptg_grp_id
                     AND      nvl(bnr.business_group_id,pgm.business_group_id)
                                              = pgm.business_group_id
                     AND      rgr.rptg_grp_id = bnr.rptg_grp_id
                     AND      p_effective_date BETWEEN rgr.effective_start_date
                                  AND rgr.effective_end_date
                     AND      rgr.business_group_id =
                                            nvl(bnr.business_group_id,rgr.business_group_id)
                     AND      rgr.pgm_id = pgm.pgm_id)
                 OR p_rptg_grp_id IS NULL)
      /* Make sure that program being linked to is of the
         eligibility profile that has been specified by the user. */
      AND      (
                    EXISTS
                    (SELECT   NULL
                     FROM     ben_prtn_elig_f epa2
                             ,ben_prtn_elig_prfl_f cep
                             ,ben_eligy_prfl_f elp
                     WHERE    epa2.pgm_id = pgm.pgm_id
                     AND      epa2.business_group_id = pgm.business_group_id
                     AND      p_effective_date BETWEEN epa2.effective_start_date
                                  AND epa2.effective_end_date
                     AND      cep.prtn_elig_id = epa2.prtn_elig_id
                     AND      cep.business_group_id = epa2.business_group_id
                     AND      p_effective_date BETWEEN cep.effective_start_date
                                  AND cep.effective_end_date
                     AND      elp.eligy_prfl_id = cep.eligy_prfl_id
                     AND      elp.business_group_id = cep.business_group_id
                     AND      elp.eligy_prfl_id = p_eligy_prfl_id
                     AND      p_effective_date BETWEEN elp.effective_start_date
                                  AND elp.effective_end_date)
                 OR p_eligy_prfl_id IS NULL)
      /* Make sure that program being linked to is of the
         enrollment type cycle that has been specified by the user. */
      AND      (
                    EXISTS
                    (SELECT   NULL
                     FROM     ben_popl_enrt_typ_cycl_f pet,
                              ben_enrt_perd enp
                     WHERE    pet.pgm_id = pgm.pgm_id
                     AND      p_effective_date BETWEEN pet.effective_start_date
                                  AND pet.effective_end_date
                     AND      pet.popl_enrt_typ_cycl_id =
                                                    enp.popl_enrt_typ_cycl_id
                     AND      enp.asnd_lf_evt_dt = p_asnd_lf_evt_dt
                     /* PB : 5422 AND      enp.strt_dt =
                              (SELECT   enp1.strt_dt
                               FROM     ben_enrt_perd enp1
                               WHERE    enp1.enrt_perd_id =
                                                      p_popl_enrt_typ_cycl_id) */
                     AND      enp.business_group_id = pet.business_group_id)
                  OR p_asnd_lf_evt_dt IS NULL)
      /* Make sure that program being linked to org id of the person
         if the program selection is limited based on person's org id. */
      AND      (
                    EXISTS
                    (SELECT   NULL
                     FROM     ben_popl_org_f cpo,
                              ben_popl_org_role_f cpr
                     WHERE    cpo.pgm_id = pgm.pgm_id
                     AND      p_effective_date BETWEEN cpo.effective_start_date
                                  AND cpo.effective_end_date
                     AND      cpo.popl_org_id = cpr.popl_org_id
                     AND      p_effective_date BETWEEN cpr.effective_start_date
                                  AND cpr.effective_end_date
                     AND      cpo.business_group_id = cpr.business_group_id
                     AND      cpr.org_role_typ_cd   = 'POPLOWNR'
                     AND      cpo.organization_id   = l_per_org_id)
                  OR p_lmt_prpnip_by_org_flag = 'N'
                  OR l_per_org_id IS NULL)
                 -- PB 5422 OR p_popl_enrt_typ_cycl_id IS NULL)
       ORDER BY pgm.name;
    --
    CURSOR c_pgm2 IS
      select pgm.pgm_id,
             pgm.drvbl_fctr_prtn_elig_flag,
             pgm.drvbl_fctr_apls_rts_flag,
             pgm.trk_inelig_per_flag
      FROM     ben_popl_yr_perd cpy
              ,ben_pgm_f pgm
              ,ben_yr_perd yrp
      WHERE    pgm.business_group_id = p_business_group_id
      AND      pgm.pgm_stat_cd = 'A'
      AND      pgm.pgm_typ_cd LIKE 'COBRA%'
      AND      p_effective_date BETWEEN pgm.effective_start_date
                   AND pgm.effective_end_date
      AND      cpy.pgm_id = pgm.pgm_id
      AND      cpy.yr_perd_id = yrp.yr_perd_id
      AND      cpy.business_group_id = pgm.business_group_id
      AND      p_effective_date BETWEEN yrp.start_date AND yrp.end_date
      AND      pgm.alws_unrstrctd_enrt_flag =
                         DECODE(p_mode, 'U', 'Y', pgm.alws_unrstrctd_enrt_flag)
      /* Make sure that program being linked to org id of the person
         if the program selection is limited based on person's org id. */
      AND      (
                    EXISTS
                    (SELECT   NULL
                     FROM     ben_popl_org_f cpo,
                              ben_popl_org_role_f cpr
                     WHERE    cpo.pgm_id = pgm.pgm_id
                     AND      p_effective_date BETWEEN cpo.effective_start_date
                                  AND cpo.effective_end_date
                     AND      cpo.popl_org_id = cpr.popl_org_id
                     AND      p_effective_date BETWEEN cpr.effective_start_date
                                  AND cpr.effective_end_date
                     AND      cpo.business_group_id = cpr.business_group_id
                     AND      cpr.org_role_typ_cd   = 'POPLOWNR'
                     AND      cpo.organization_id   = l_per_org_id)
                  OR p_lmt_prpnip_by_org_flag = 'N'
                  OR l_per_org_id IS NULL)
       ORDER BY pgm.name;
    --
   CURSOR c_pln_nip
    is
      select pln.pl_id,
             pln.pl_typ_id,
             ptp.opt_typ_cd,
             pln.drvbl_fctr_prtn_elig_flag,
             pln.drvbl_fctr_apls_rts_flag,
             pln.trk_inelig_per_flag
      FROM   ben_pl_f pln,
             ben_pl_typ_f ptp
       --      ben_yr_perd yrp,
       --      ben_popl_yr_perd cpy
      WHERE  pln.business_group_id = p_business_group_id
      AND    p_effective_date BETWEEN pln.effective_start_date
                   AND pln.effective_end_date
     /* Bug No 4402873  Added condition to retrieve plans with code as
        'May Not be in Program' so that the plans with code as
	'Must be in Program' and not included in the program
	shall not get picked up*/
      and    pln.pl_cd = 'MYNTBPGM'
      and    pln.pl_typ_id = ptp.pl_typ_id
      and    p_effective_date
        between ptp.effective_start_date and ptp.effective_end_date
      /* Make sure that the plan is not in the plip table.
         or may not have been stated by the user. */
      AND (p_mode IN ('P','G','D') or  -- ICM
           exists (select null
                   from   ben_yr_perd yrp,
                          ben_popl_yr_perd cpy
                   where  cpy.pl_id = pln.pl_id
                   AND    cpy.yr_perd_id = yrp.yr_perd_id
                   AND      cpy.business_group_id = pln.business_group_id
                   AND      p_effective_date BETWEEN yrp.start_date AND yrp.end_date))
      AND      pln.pl_stat_cd = 'A'
      AND      pln.alws_unrstrctd_enrt_flag =
                         DECODE(p_mode, 'U', 'Y','D','Y', pln.alws_unrstrctd_enrt_flag) -- ICM
      -- CWB changes
      -- ABSENCES : pickup only absence plans
      AND      ((p_mode = 'W' and ptp.opt_typ_cd = 'CWB') or
                (p_mode = 'M' and ptp.opt_typ_cd = 'ABS') or
                (p_mode = 'P' and ptp.opt_typ_cd = 'PERACT') or
                (p_mode = 'I' and ptp.opt_typ_cd = 'COMP') or -- iREC changes
                (p_mode = 'D' and ptp.opt_typ_cd = 'ICM') or
                (p_mode not in ('W','M', 'P','D') and ptp.opt_typ_cd not in ('CWB','ABS', 'PERACT','ICM')) -- ICM
               )
      AND      ptp.opt_typ_cd <> 'GDRLDR'
      AND      NOT EXISTS(SELECT   NULL
                          FROM     ben_plip_f cpp
                          WHERE    cpp.pl_id = pln.pl_id)
      /* We only want to report on these plans when pgm_id is null */
      AND      p_pgm_id IS NULL
      AND      pln.pl_id = NVL(p_pl_id, pln.pl_id)
	/* Make sure that plan being linked to covers all the options that may
         or may not have been stated by the user. */

      AND      (
                    EXISTS
                    (SELECT   NULL
                     FROM     ben_oipl_f cop
                     WHERE    cop.opt_id = p_opt_id
                     AND      cop.pl_id = pln.pl_id
                     AND      cop.oipl_stat_cd = 'A'
                     AND      cop.business_group_id = pln.business_group_id
                     AND      p_effective_date BETWEEN cop.effective_start_date
                                  AND cop.effective_end_date)
                 OR p_opt_id IS NULL)
	/* Make sure that plan being linked to is in the correct benefit group */
      AND      (
                    EXISTS
                    (SELECT   NULL
                     FROM     ben_rptg_grp bnr, ben_popl_rptg_grp_f rgr
                     WHERE    bnr.rptg_grp_id = nvl(p_rptg_grp_id, bnr.rptg_grp_id) --irec
                     AND      nvl(bnr.business_group_id,pln.business_group_id)
                                               = pln.business_group_id
                     AND      rgr.rptg_grp_id = bnr.rptg_grp_id
                     AND      p_effective_date BETWEEN rgr.effective_start_date
                                  AND rgr.effective_end_date
                     AND      rgr.business_group_id   =
                                       nvl(bnr.business_group_id,rgr.business_group_id)
                     AND      rgr.pl_id = pln.pl_id
                     AND      nvl(bnr.rptg_prps_cd, 'X') = decode (p_mode, 'I', 'IREC',nvl(bnr.rptg_prps_cd, 'X')) -- irec
                     )
                 OR
                  (p_rptg_grp_id IS NULL
                  and p_mode <>'I' -- iRec
                  )
                 )
	/* Make sure that plan being linked to is of the variable rate profile
         that has been specified by the user. */
      AND      (
                    EXISTS
                    (SELECT   NULL
                     FROM     ben_acty_base_rt_f abr
                             ,ben_acty_vrbl_rt_f avr
                             ,ben_vrbl_rt_prfl_f vpf
                     WHERE    abr.pl_id = pln.pl_id
                     AND      abr.business_group_id = pln.business_group_id
                     AND      p_effective_date BETWEEN abr.effective_start_date
                                  AND abr.effective_end_date
                     AND      avr.acty_base_rt_id = abr.acty_base_rt_id
                     AND      avr.business_group_id = abr.business_group_id
                     AND      p_effective_date BETWEEN avr.effective_start_date
                                  AND avr.effective_end_date
                     AND      vpf.vrbl_rt_prfl_id = avr.vrbl_rt_prfl_id
                     AND      vpf.business_group_id = avr.business_group_id
                     AND      vpf.vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
                     AND      p_effective_date BETWEEN vpf.effective_start_date
                                  AND vpf.effective_end_date)
                 OR p_vrbl_rt_prfl_id IS NULL)
      AND      (
                    EXISTS
                    (SELECT   NULL
                     FROM     ben_prtn_elig_f epa2
                             ,ben_prtn_elig_prfl_f cep
                             ,ben_eligy_prfl_f elp
                     WHERE    epa2.pl_id = pln.pl_id
                     AND      epa2.business_group_id = pln.business_group_id
                     AND      p_effective_date BETWEEN epa2.effective_start_date
                                  AND epa2.effective_end_date
                     AND      cep.prtn_elig_id = epa2.prtn_elig_id
                     AND      cep.business_group_id = epa2.business_group_id
                     AND      p_effective_date BETWEEN cep.effective_start_date
                                  AND cep.effective_end_date
                     AND      elp.eligy_prfl_id = cep.eligy_prfl_id
                     AND      elp.business_group_id = cep.business_group_id
                     AND      elp.eligy_prfl_id = p_eligy_prfl_id
                     AND      p_effective_date BETWEEN elp.effective_start_date
                                  AND elp.effective_end_date)
                 OR p_eligy_prfl_id IS NULL)
      AND      (
                    EXISTS
                    (SELECT   NULL
                     FROM     ben_popl_enrt_typ_cycl_f pet, ben_enrt_perd enp
                     WHERE    pet.pl_id = pln.pl_id
                     AND      p_effective_date BETWEEN pet.effective_start_date
                                  AND pet.effective_end_date
                     AND      pet.popl_enrt_typ_cycl_id =
                                                    enp.popl_enrt_typ_cycl_id
                     AND      enp.asnd_lf_evt_dt = p_asnd_lf_evt_dt

                     AND      enp.business_group_id = pet.business_group_id)
                  OR p_asnd_lf_evt_dt IS NULL)
      AND      (
                    EXISTS
                    (SELECT   NULL
                     FROM     ben_popl_org_f cpo,
                              ben_popl_org_role_f cpr
                     WHERE    cpo.pl_id = pln.pl_id
                     AND      p_effective_date BETWEEN cpo.effective_start_date
                                  AND cpo.effective_end_date
                     AND      cpo.popl_org_id = cpr.popl_org_id
                     AND      p_effective_date BETWEEN cpr.effective_start_date
                                  AND cpr.effective_end_date
                     AND      cpo.business_group_id = cpr.business_group_id
                     AND      cpr.org_role_typ_cd   = 'POPLOWNR'
                     AND      cpo.organization_id   = l_per_org_id)
                  OR p_lmt_prpnip_by_org_flag = 'N'
                  OR l_per_org_id IS NULL)
       ORDER BY nvl(pln.ordr_num,999999999999999),pln.name;
    --
    CURSOR c_pln2
    IS
      select pln.pl_id,
             pln.pl_typ_id,
             ptp.opt_typ_cd,
             pln.drvbl_fctr_prtn_elig_flag,
             pln.drvbl_fctr_apls_rts_flag,
             pln.trk_inelig_per_flag
      FROM   ben_pl_f pln,
             ben_pl_typ_f ptp,
             -- ben_popl_yr_perd cpy,
             -- ben_yr_perd yrp,
             ben_plip_f plp,
             ben_ptip_f ctp
      WHERE    pln.business_group_id = p_business_group_id
      AND      pln.pl_id = plp.pl_id
      AND      p_effective_date BETWEEN pln.effective_start_date
                   AND pln.effective_end_date
      and    pln.pl_typ_id = ptp.pl_typ_id
      and    p_effective_date
        between ptp.effective_start_date and ptp.effective_end_date
      AND      plp.pgm_id = l_pgm_id
      AND      plp.business_group_id = pln.business_group_id
      AND      plp.plip_stat_cd = 'A'
      AND      pln.pl_stat_cd = 'A'
      AND      plp.alws_unrstrctd_enrt_flag =
                         DECODE(p_mode, 'U', 'Y', plp.alws_unrstrctd_enrt_flag)
      AND      p_effective_date BETWEEN plp.effective_start_date
                   AND plp.effective_end_date

      AND (p_mode = 'G' or
           exists (select null
                   from   ben_yr_perd yrp,
                          ben_popl_yr_perd cpy
                   where  cpy.pl_id = pln.pl_id
                   AND    cpy.yr_perd_id = yrp.yr_perd_id
                   AND    cpy.business_group_id = pln.business_group_id
                   AND    p_effective_date BETWEEN yrp.start_date AND yrp.end_date))

      AND      ctp.pl_typ_id = pln.pl_typ_id
      AND      ctp.pgm_id = l_pgm_id
      AND      ctp.business_group_id = pln.business_group_id
      AND      ctp.ptip_stat_cd = 'A'
      AND      p_effective_date BETWEEN ctp.effective_start_date
                   AND ctp.effective_end_date
       ORDER BY pln.name;
    --
    CURSOR c_oipl2
    IS
      select cop.oipl_id,
             cop.opt_id,
             cop.drvbl_fctr_prtn_elig_flag,
             cop.drvbl_fctr_apls_rts_flag,
             cop.trk_inelig_per_flag
      FROM     ben_oipl_f cop
              ,ben_opt_f opt
              -- ,ben_popl_yr_perd cpy
              -- ,ben_yr_perd yrp
              ,ben_pl_f pln
      WHERE    cop.business_group_id = p_business_group_id
      AND      p_effective_date BETWEEN cop.effective_start_date
                   AND cop.effective_end_date
      AND      cop.pl_id = pln.pl_id
      AND      cop.oipl_stat_cd = 'A'
      AND      pln.pl_id = l_pl_id
      AND      pln.business_group_id = cop.business_group_id
      AND      pln.pl_stat_cd = 'A'
      AND      p_effective_date BETWEEN pln.effective_start_date
                   AND pln.effective_end_date
      AND      cop.opt_id = opt.opt_id
      AND      opt.business_group_id = cop.business_group_id
      AND      p_effective_date BETWEEN opt.effective_start_date
                   AND opt.effective_end_date

      AND (p_mode in ('G','D') or
           exists (select null
                   from   ben_yr_perd yrp,
                          ben_popl_yr_perd cpy
                   where  cpy.pl_id = cop.pl_id
                   AND    cpy.yr_perd_id = yrp.yr_perd_id
                   AND    cpy.business_group_id = cop.business_group_id
                   AND    p_effective_date BETWEEN yrp.start_date AND yrp.end_date))
       ORDER BY cop.ordr_num;
    --
    CURSOR c_plip IS
      SELECT   cpp.*
      FROM     ben_plip_f cpp
      WHERE    cpp.business_group_id = p_business_group_id
      AND      cpp.pl_id = l_pl_id
      AND      cpp.pgm_id = l_pgm_id
      AND      cpp.plip_stat_cd = 'A'
      AND      p_effective_date BETWEEN cpp.effective_start_date
                   AND cpp.effective_end_date;
    --
    CURSOR c_ptip IS
      SELECT   ctp.*
      FROM     ben_ptip_f ctp
      WHERE    ctp.business_group_id = p_business_group_id
      AND      ctp.pgm_id = l_pgm_id
      AND      ctp.pl_typ_id = l_pln.pl_typ_id
      AND      ctp.ptip_stat_cd = 'A'
      AND      p_effective_date BETWEEN ctp.effective_start_date
                   AND ctp.effective_end_date;
    --
    CURSOR c_oiplip IS
      SELECT   opp.*
      FROM     ben_oiplip_f opp
      WHERE    opp.business_group_id = p_business_group_id
      AND      opp.plip_id = l_plip.plip_id
      AND      opp.oipl_id = l_cop.oipl_id
      AND      p_effective_date BETWEEN opp.effective_start_date
                   AND opp.effective_end_date;
    --
    CURSOR c_multisesscache(
      c_effective_date    IN DATE
     ,c_business_group_id IN NUMBER
     ,p_mode varchar2) IS
      SELECT   comp_obj_cache_id
              ,timestamp
              ,mode_cd
              ,pgm_id
              ,pl_id
              ,no_programs
              ,no_plans
              ,pl_typ_id
      FROM    ben_comp_obj_cache
      WHERE    business_group_id = c_business_group_id
      AND      effective_date = c_effective_date
      AND      mode_cd = p_mode;                --bug 7700173
    --
    CURSOR c_chgpgm(
      c_timestamp IN DATE) IS
      SELECT   NULL
      FROM     ben_pgm_f
      WHERE    c_timestamp < last_update_date;
    --
    l_tabname_set           v2_set;
    --
    l_flag_bit_val          BINARY_INTEGER                  := 0;
    l_oiplip_flag_bit_val   BINARY_INTEGER                  := 0;
    --
    l_rebuild_list          BOOLEAN;
    l_bypass_cache          BOOLEAN;
    --
    l_comp_obj_cache_id     NUMBER;
    l_comp_obj_cache_row_id NUMBER;
    l_rule_pass_pgm_id      NUMBER;
    --
    l_timestamp             DATE;
    l_v2dummy               NUMBER(1);
    --
    l_query_str             LONG;
    --
    l_per_rec               per_all_people_f%rowtype;
    l_ass_rec               per_all_assignments_f%rowtype;
    l_date_changed          boolean := FALSE;
    l_org_changed           boolean := FALSE;
  --
  -- Added for # 3330283
    cursor c_unres_cache_only IS
          select distinct  alws_unrstrctd_enrt_flag
          from ben_pgm_f
          where pgm_id in ( SELECT   distinct bcocr.pgm_id
                            FROM     ben_comp_obj_cache_row bcocr
                            WHERE    bcocr.comp_obj_cache_id = l_comp_obj_cache_id )
          order by 1;
  --
   l_unres_cache_only varchar2(1) ;
  -- # 3330283
    cursor c_unres_cache_plnip_only IS
          select distinct  alws_unrstrctd_enrt_flag
          from ben_pl_f
          where pl_id in ( SELECT   distinct bcocr.pl_id
                            FROM     ben_comp_obj_cache_row bcocr
                            WHERE    bcocr.comp_obj_cache_id = l_comp_obj_cache_id
                            and      bcocr.pl_nip = 'Y' )
          order by 1;
  --
   l_unres_cache_plnip_only varchar2(1) ;
   l_mode_cd                varchar2(30);
   l_pgm_id2                 number;
   l_pl_id2                  number;
   l_no_programs            varchar2(30);
   l_no_plans               varchar2(30);
   l_pl_typ_id              number;

  --
  BEGIN
    --
    hr_utility.set_location('Entering ' || l_package, 10);
    hr_utility.set_location('date ' || p_effective_date, 10);
    --
    -- PB : Helathnet change :
    -- Get the person organization id, if it changes then
    -- comp object list needs to be rebuilt.
    --
    l_per_org_id := null;
    --
    IF p_lmt_prpnip_by_org_flag = 'Y' then
       --
       -- Get the organization id.
       --
       ben_person_object.get_object(p_person_id => p_person_id,
                                    p_rec       => l_ass_rec);
       --
       hr_utility.set_location('l_ass.assignment_id ' || l_ass_rec.assignment_id, 111);
       l_per_org_id := l_ass_rec.organization_id;
       --
       -- Check if the organization id for the comp object
       -- cache has changed since the previous call to build
       -- comp object. If there is no change then we do not need
       -- to refresh the comp object cache.
       --
       IF g_prev_per_org_id IS NULL THEN
         --
         g_prev_per_org_id  := l_ass_rec.organization_id;
         l_org_changed := TRUE;
         --
       ELSIF     g_prev_per_org_id = l_ass_rec.organization_id
             AND ben_manage_life_events.g_cache_proc_object.COUNT > 0 THEN
         --
         l_org_changed := FALSE;
         --
       ELSE
         --
         g_prev_per_org_id  := l_ass_rec.organization_id;
         l_org_changed := TRUE;
         --
       END IF;
      --
    END IF;
    hr_utility.set_location('g_prev_per_org_id ' || l_ass_rec.assignment_id, 111);
    --
    -- Check if the effective date for the comp object
    -- cache has changed since the previous call to build
    -- comp object. If there is no change then we do not need
    -- to refresh the comp object cache.
    --
    IF g_prev_lf_evt_ocrd_dt IS NULL THEN
      --
      g_prev_lf_evt_ocrd_dt  := p_effective_date;
      l_date_changed         := TRUE;
      --
    ELSIF     g_prev_lf_evt_ocrd_dt = p_effective_date
          AND ben_manage_life_events.g_cache_proc_object.COUNT > 0 THEN
      --
      if p_lmt_prpnip_by_org_flag = 'N' then
         --
         RETURN;
         --
      else
         --
         if not l_org_changed then
            --
            return;
            --
         end if;
         --
      end if;
    --
    ELSE
      --
      g_prev_lf_evt_ocrd_dt  := p_effective_date;
      l_date_changed         := TRUE;
      --
    END IF;
    --
    -- Copy benefit action id to global in benutils package
    --
    benutils.g_benefit_action_id  := p_benefit_action_id;
    benutils.g_thread_id          := p_thread_id;
    --
    -- Clear cache structures
    --
    -- PB : Healthnet change.
    -- if only org_id changed then need not remove the caching.
    --
    if l_date_changed or
       p_lmt_prpnip_by_org_flag = 'N'
    then
       --
       hr_utility.set_location('Clear caches ' || l_package, 10);
       --
       ben_comp_object_list1.refresh_eff_date_caches;
       --
       hr_utility.set_location('Done Clear caches ' || l_package, 10);
       --
    end if;
    --
    -- Check if the comp object list exists in the multi session cache
    --
    --   Clear the comp object list
    --
    ben_manage_life_events.g_cache_proc_object.delete;
    --
    l_rebuild_list                := TRUE;
    l_bypass_cache                := TRUE;
    --
    -- When parameters are set or collective agreement mode
    -- we must do a force build
    --
    IF p_pgm_id IS NOT NULL
      OR p_pl_id IS NOT NULL
      OR p_opt_id IS NOT NULL
      OR p_rptg_grp_id IS NOT NULL
      OR p_vrbl_rt_prfl_id IS NOT NULL
      OR p_eligy_prfl_id IS NOT NULL
      --OR p_asnd_lf_evt_dt IS NOT NULL
      OR p_lmt_prpnip_by_org_flag = 'Y'
      -- CWB Changes .
      -- ABSENCES rebuild cache as multiple life events are processed.
      OR p_mode in ( 'A', 'W', 'M', 'G')

    THEN
      --
      l_bypass_cache  := TRUE;
      --
    ELSE
      --
      l_bypass_cache  := FALSE;
      --
      -- Check if a multi sessiob comp object list exists in the cache
      -- tables
      --
      OPEN c_multisesscache(c_effective_date=> p_effective_date
                            ,c_business_group_id => p_business_group_id
                            ,p_mode              => p_mode);         --bug 7700173
      FETCH c_multisesscache INTO  l_comp_obj_cache_id
                                  ,l_timestamp
                                  ,l_mode_cd
                                  ,l_pgm_id2
                                  ,l_pl_id2
                                  ,l_no_programs
                                  ,l_no_plans
                                  ,l_pl_typ_id;
      IF c_multisesscache%FOUND THEN
        --
        --check the parameters first
        if l_mode_cd = p_mode and nvl(l_pgm_id2,-1) = nvl(p_pgm_id, -1) and
           nvl(l_pl_id2,-1) =  nvl(p_pl_id,-1) and l_no_programs = p_no_programs
           and l_no_plans = p_no_plans and nvl(l_pl_typ_id,-1) = nvl(p_pl_typ_id,-1)
              then
         -- Check if the multi session cache information is in sync
         -- with the database
         --
         -- - Check comp object level changes
         --
         l_tabname_set(0)   := 'ben_pgm_f';
         l_tabname_set(1)   := 'ben_ptip_f';
         l_tabname_set(2)   := 'ben_plip_f';
         l_tabname_set(3)   := 'ben_pl_f';
         l_tabname_set(4)   := 'ben_opt_f';
         l_tabname_set(5)   := 'ben_oipl_f';
         l_tabname_set(6)   := 'ben_oiplip_f';
         --
         l_tabname_set(7)   := 'ben_prtn_elig_f';
         l_tabname_set(8)   := 'ben_prtn_elig_prfl_f';
         l_tabname_set(9)   := 'ben_eligy_prfl_f';
         --
         l_tabname_set(10)  := 'ben_popl_yr_perd';
         l_tabname_set(11)  := 'ben_yr_perd';
         l_tabname_set(12)  := 'ben_rptg_grp';
         l_tabname_set(13)  := 'ben_popl_rptg_grp_f';
         --
         l_tabname_set(10)  := 'ben_popl_yr_perd';
         l_tabname_set(11)  := 'ben_yr_perd';
         l_tabname_set(12)  := 'ben_rptg_grp';
         l_tabname_set(13)  := 'ben_popl_rptg_grp';
         --
         l_tabname_set(14)  := 'ben_enrt_perd_for_pl_f';
         l_tabname_set(15)  := 'ben_enrt_perd';
         l_tabname_set(16)  := 'ben_popl_enrt_typ_cycl_f';                  --
         --
         l_tabname_set(17)  := 'ben_vrbl_rt_prfl_f';
         l_tabname_set(18)  := 'ben_acty_vrbl_rt_f';
         l_tabname_set(19)  := 'ben_acty_base_rt_f';
         l_tabname_set(20)  := 'ben_actl_prem_vrbl_rt_f';
         l_tabname_set(21)  := 'ben_actl_prem_f';
         l_tabname_set(22)  := 'ben_bnft_vrbl_rt_f';
         l_tabname_set(23)  := 'ben_cvg_amt_calc_mthd_f';
         --
         FOR tabele_num IN l_tabname_set.FIRST .. l_tabname_set.LAST LOOP
           --
           l_query_str  :=
             ' select 1 ' || ' from sys.dual' || ' where  exists(select null' ||
               '               from       ' ||
               l_tabname_set(tabele_num) ||
               ' where  :timestamp < last_update_date)';
           --
           --
           -- Strage but if a table has no rows PLSQL lets %found be successful
           -- for dynamic SQL. My workaround is to use a number assignment.
           --
           l_v2dummy    := 0;
           OPEN c_chgdata FOR l_query_str USING l_timestamp;
           FETCH c_chgdata INTO l_v2dummy;
           --
           -- Following on from MH above
           -- Actually put the test in for it not returning rows
           -- by using the var setup
           -- line was IF c_chgdata%FOUND THEN
           -- tm 01-Mar-2001
           --
           IF (c_chgdata%FOUND AND l_v2dummy >0 ) THEN
             --
             -- Clear all cache information for all effective dates
             --
             flush_multi_session_cache
               (p_business_group_id => p_business_group_id
               ,p_effective_date    => p_effective_date
               ,p_mode              => p_mode
               );
             --
             l_rebuild_list  := TRUE;
             --
             CLOSE c_chgdata;
             EXIT;
           --
           ELSE
             --
             l_rebuild_list  := FALSE;
           --
           END IF;
           CLOSE c_chgdata;
         --
         END LOOP;
         --
        else
         --
         flush_multi_session_cache
               (p_business_group_id => p_business_group_id
               ,p_effective_date    => p_effective_date
               ,p_mode              => p_mode
               );
             --
         l_rebuild_list  := TRUE;
          --
        end if; -- parameter check
      --
      END IF;
      CLOSE c_multisesscache;
    --
    END IF;
    --
    -- Check if the comp object list should be re-built
    --
    --
    -- Start # bug 3330283
    --
    /*
    IF  l_rebuild_list = FALSE and l_bypass_cache = FALSE THEN
    --
       If p_mode = 'L' then
          -- check whether multi cache exists
          --
          OPEN c_multisesscache(c_effective_date=> p_effective_date
                               ,c_business_group_id => p_business_group_id);
          FETCH c_multisesscache INTO l_comp_obj_cache_id, l_timestamp;
          --
          hr_utility.set_location('fetched multi cache '  , 111);
          IF c_multisesscache%FOUND THEN
             -- cache exists
             -- check if cache has only unrestricted programs
             --
             hr_utility.set_location('found multi cache '  , 111);
             open  c_unres_cache_only ;
             fetch c_unres_cache_only into l_unres_cache_only ;
             if c_unres_cache_only%FOUND then
             --
                if  l_unres_cache_only = 'N' then
                   -- then non- unrestricted pgms also exist so continue
	           null ;
                else
                   -- only unrst pgms exist
                   -- reset l_rebuild_list to TRUE
                   hr_utility.set_location(' reset rebuild list pgms '  , 111);
                   l_rebuild_list  := TRUE;
                end if;
             --
             else
                 -- as multisesscache exists and is not for pgm
                 -- chk if it is for plnip
                 -- 3889987
                 open  c_unres_cache_plnip_only ;
                 fetch c_unres_cache_plnip_only into l_unres_cache_plnip_only ;
                 if c_unres_cache_plnip_only%FOUND then
                 --
                   if  l_unres_cache_plnip_only = 'N' then
                      -- then non- unrestricted plns also exist so continue
	              null ;
                   else
                      -- only unrst plns exist
                      -- reset l_rebuild_list to TRUE
                      hr_utility.set_location(' reset rebuild list plans '  , 112);
                      l_rebuild_list  := TRUE;
                   end if;
                   --
                end if ;
                close c_unres_cache_plnip_only ;
             end if;
             close c_unres_cache_only ;
          ELSE
              -- cache doesnt exist ?? continue
              null;

          END IF;
          --
          CLOSE c_multisesscache ;
          --
       end if;
    --
    END IF;
    --
    -- End # bug 3330283
    */
    --
    hr_utility.set_location('rebuild cache ' || l_package, 111);
    IF    l_rebuild_list
       OR l_bypass_cache THEN
      --
      -- Flush all existing multi session cache information
      -- for the effective date
      --
      if p_lmt_prpnip_by_org_flag = 'N'
        and l_rebuild_list
      then
         --
         flush_multi_session_cache(p_business_group_id => p_business_group_id

                                  ,p_effective_date => p_effective_date
                                  ,p_mode              => p_mode
                                  );
         --
      end if;
      --
      IF p_no_programs = 'N' and p_mode not in ('I','D') THEN -- irec -- ICM
        --
        hr_utility.set_location(l_package || ' Opening c_pgm loop ', 11);
        OPEN c_pgm;
        hr_utility.set_location(l_package || ' Opened c_pgm loop ', 11);
        --
        LOOP
          --
          hr_utility.set_location(l_package || ' Start c_pgm loop ', 12);
          FETCH c_pgm INTO l_pgm;
          hr_utility.set_location(l_package || ' Fetch c_pgm loop ', 14);
          EXIT WHEN c_pgm%NOTFOUND;
          --
          l_pgm_id  := l_pgm.pgm_id;
          --
          hr_utility.set_location(l_package || ' c_pgm LC ', 16);
          --
          -- Only set the flag bit if we have rates or profiles attached
          --
          IF    l_pgm.drvbl_fctr_prtn_elig_flag = 'Y'
             OR l_pgm.drvbl_fctr_apls_rts_flag = 'Y' THEN
            --
            l_flag_bit_val  :=
              set_flag_bit_val(p_business_group_id=> p_business_group_id
               ,p_effective_date            => p_effective_date
               ,p_drvbl_fctr_prtn_elig_flag => l_pgm.drvbl_fctr_prtn_elig_flag
               ,p_drvbl_fctr_apls_rts_flag  => l_pgm.drvbl_fctr_apls_rts_flag
               ,p_pgm_id                    => l_pgm.pgm_id
               ,p_pl_id                     => NULL
               ,p_oipl_id                   => NULL
               ,p_oiplip_id                 => NULL
               ,p_plip_id                   => NULL
               ,p_ptip_id                   => NULL);
          --
          ELSE
            --
            l_flag_bit_val  := 0;
          --
          END IF;
          --
          load_cache(p_pgm_id     => l_pgm_id
           ,p_par_pgm_id          => l_pgm_id
           ,p_flag_bit_val        => l_flag_bit_val
           ,p_oiplip_flag_bit_val => 0
           ,p_trk_inelig_per_flag => l_pgm.trk_inelig_per_flag);
          --
          hr_utility.set_location(l_package || ' Start c_pln loop ', 20);
          ben_pln_cache.bgpcpp_getdets(p_business_group_id=> p_business_group_id
           ,p_effective_date        => p_effective_date
           ,p_mode                  => p_mode
           ,p_pgm_id                => l_pgm_id
           ,p_pl_id                 => p_pl_id
           ,p_opt_id                => p_opt_id
           ,p_rptg_grp_id           => p_rptg_grp_id
           ,p_vrbl_rt_prfl_id       => p_vrbl_rt_prfl_id
           ,p_eligy_prfl_id         => p_eligy_prfl_id
           -- 5422 : PB
           ,p_asnd_lf_evt_dt        => p_asnd_lf_evt_dt
           -- ,p_popl_enrt_typ_cycl_id => p_popl_enrt_typ_cycl_id
           --
           ,p_inst_set              => l_plninst_set
           );
          hr_utility.set_location(l_package || ' Fetch c_pln loop ', 22);
          --
          IF l_plninst_set.COUNT > 0 THEN
            --
            FOR plnelenum IN l_plninst_set.FIRST .. l_plninst_set.LAST LOOP
              --
              l_pln            := l_plninst_set(plnelenum);
              l_pl_id          := l_plninst_set(plnelenum).pl_id;
              l_ptp_opt_typ_cd := l_plninst_set(plnelenum).ptp_opt_typ_cd;
              --
              hr_utility.set_location(l_package || ' Dn PLN OSR ', 16);
              --
              -- In collective agreement mode only process CAGR opt types
              --
              if l_ptp_opt_typ_cd <> 'CAGR'
                and p_mode = 'A'
              then
                --
                null;
                --
              else
                --
                -- We have to work out the PLIP and PTIP ids for the
                -- plan in program we are dealing with
                -- There will ALWAYS be a PLIP_ID but we cannot guarantee
                -- a PTIP id.
                --
                hr_utility.set_location(l_package || ' open c_ptip ', 16);
                OPEN c_ptip;
                --
                FETCH c_ptip INTO l_ptip;
                --
                CLOSE c_ptip;
                --
                -- Only set the flag bit if we have rates or profiles attached
                --
                IF    l_ptip.drvbl_fctr_prtn_elig_flag = 'Y'
                   OR l_ptip.drvbl_fctr_apls_rts_flag = 'Y' THEN
                  --
                  l_flag_bit_val  :=
                    set_flag_bit_val(p_business_group_id=> p_business_group_id
                     ,p_effective_date            => p_effective_date
                     ,p_drvbl_fctr_prtn_elig_flag => l_ptip.drvbl_fctr_prtn_elig_flag
                     ,p_drvbl_fctr_apls_rts_flag  => l_ptip.drvbl_fctr_apls_rts_flag
                     ,p_pgm_id                    => NULL
                     ,p_pl_id                     => NULL
                     ,p_oipl_id                   => NULL
                     ,p_oiplip_id                 => NULL
                     ,p_plip_id                   => NULL
                     ,p_ptip_id                   => l_ptip.ptip_id);
                --
                ELSE
                  --
                  l_flag_bit_val  := 0;
                --
                END IF;
                --
                load_cache(p_ptip_id    => l_ptip.ptip_id
                 ,p_par_pgm_id          => l_pgm_id
                 ,p_par_ptip_id         => l_ptip.ptip_id
                 ,p_flag_bit_val        => l_flag_bit_val
                 ,p_oiplip_flag_bit_val => 0
                 ,p_trk_inelig_per_flag => l_ptip.trk_inelig_per_flag);
                --
                hr_utility.set_location(l_package || ' open c_plip ', 16);
                OPEN c_plip;
                --
                FETCH c_plip INTO l_plip;
                --
                CLOSE c_plip;
                --
                -- Only set the flag bit if we have rates or profiles attached
                --
                IF    l_plip.drvbl_fctr_prtn_elig_flag = 'Y'
                   OR l_plip.drvbl_fctr_apls_rts_flag = 'Y' THEN
                  --
                  l_flag_bit_val  :=
                    set_flag_bit_val(p_business_group_id=> p_business_group_id
                     ,p_effective_date            => p_effective_date
                     ,p_drvbl_fctr_prtn_elig_flag => l_plip.drvbl_fctr_prtn_elig_flag
                     ,p_drvbl_fctr_apls_rts_flag  => l_plip.drvbl_fctr_apls_rts_flag
                     ,p_pgm_id                    => NULL
                     ,p_pl_id                     => NULL
                     ,p_oipl_id                   => NULL
                     ,p_oiplip_id                 => NULL
                     ,p_plip_id                   => l_plip.plip_id
                     ,p_ptip_id                   => NULL);
                --
                ELSE
                  --
                  l_flag_bit_val  := 0;
                --
                END IF;
                --
                load_cache(p_plip_id    => l_plip.plip_id
                 ,p_par_pgm_id          => l_pgm_id
                 ,p_par_ptip_id         => l_ptip.ptip_id
                 ,p_par_plip_id         => l_plip.plip_id
                 --RCHASE
                 ,p_par_pl_id         => l_pl_id
                 ,p_flag_bit_val        => l_flag_bit_val
                 ,p_oiplip_flag_bit_val => 0
                 ,p_trk_inelig_per_flag => l_plip.trk_inelig_per_flag);
                --
                -- Only set the flag bit if we have rates or profiles attached
                --
                IF    l_pln.drvbl_fctr_prtn_elig_flag = 'Y'
                   OR l_pln.drvbl_fctr_apls_rts_flag = 'Y' THEN
                  --
                  l_flag_bit_val  :=
                    set_flag_bit_val(p_business_group_id=> p_business_group_id
                     ,p_effective_date            => p_effective_date
                     ,p_drvbl_fctr_prtn_elig_flag => l_pln.drvbl_fctr_prtn_elig_flag
                     ,p_drvbl_fctr_apls_rts_flag  => l_pln.drvbl_fctr_apls_rts_flag
                     ,p_pgm_id                    => NULL
                     ,p_pl_id                     => l_pln.pl_id
                     ,p_oipl_id                   => NULL
                     ,p_oiplip_id                 => NULL
                     ,p_plip_id                   => NULL
                     ,p_ptip_id                   => NULL);
                --
                ELSE
                  --
                  l_flag_bit_val  := 0;
                --
                END IF;
                --
                load_cache(p_pl_id      => l_pl_id
                 ,p_par_pgm_id          => l_pgm_id
                 ,p_par_ptip_id         => l_ptip.ptip_id
                 ,p_par_plip_id         => l_plip.plip_id
                 ,p_par_pl_id           => l_pl_id
                 ,p_flag_bit_val        => l_flag_bit_val
                 ,p_oiplip_flag_bit_val => 0
                 ,p_trk_inelig_per_flag => l_pln.trk_inelig_per_flag);
                --
                ben_cop_cache.bgpcop_getdets(p_effective_date=> p_effective_date
                 ,p_business_group_id => p_business_group_id
                 ,p_pl_id             => l_pl_id
                 ,p_opt_id            => p_opt_id
                 ,p_eligy_prfl_id     => p_eligy_prfl_id
                 ,p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
                 ,p_mode              => p_mode
                 --
                 ,p_inst_set          => l_copinst_set);
                --
                IF l_copinst_set.COUNT > 0 THEN
                  --
                  FOR copelenum IN l_copinst_set.FIRST .. l_copinst_set.LAST LOOP
                    --
                    l_cop                  := l_copinst_set(copelenum);
                    l_oipl_id              := l_copinst_set(copelenum).oipl_id;
                    --
                    hr_utility.set_location(l_package || ' c_oipl load_cache '
                     ,15);
                    --
                    -- Only set the flag bit if we have rates or profiles attached
                    --
                    IF    l_cop.drvbl_fctr_prtn_elig_flag = 'Y'
                       OR l_cop.drvbl_fctr_apls_rts_flag = 'Y' THEN
                      --
                      l_flag_bit_val  :=
                        set_flag_bit_val(p_business_group_id=> p_business_group_id
                         ,p_effective_date            => p_effective_date
                         ,p_drvbl_fctr_prtn_elig_flag => l_cop.drvbl_fctr_prtn_elig_flag
                         ,p_drvbl_fctr_apls_rts_flag  => l_cop.drvbl_fctr_apls_rts_flag
                         ,p_pgm_id                    => NULL
                         ,p_pl_id                     => NULL
                         ,p_oipl_id                   => l_cop.oipl_id
                         ,p_oiplip_id                 => NULL
                         ,p_plip_id                   => NULL
                         ,p_ptip_id                   => NULL);
                    --
                    ELSE
                      --
                      l_flag_bit_val  := 0;
                    --
                    END IF;
                    --
                    -- Handle oiplip case
                    --
                    -- If oiplip does not exist then set flag to 0
                    --
                    l_oiplip_flag_bit_val  := 0;
                    --
                    OPEN c_oiplip;
                    --
                    FETCH c_oiplip INTO l_oiplip;
                    --
                    IF c_oiplip%FOUND THEN
                      --
                      -- Try and derive bit value for oiplip record
                      --
                      l_oiplip_flag_bit_val  :=
                        set_flag_bit_val(p_business_group_id=> p_business_group_id
                         ,p_effective_date            => p_effective_date
                         ,p_drvbl_fctr_prtn_elig_flag => 'N'
                         ,p_drvbl_fctr_apls_rts_flag  => 'N'
                         ,p_pgm_id                    => NULL
                         ,p_pl_id                     => NULL
                         ,p_oipl_id                   => NULL
                         ,p_oiplip_id                 => l_oiplip.oiplip_id
                         ,p_plip_id                   => NULL
                         ,p_ptip_id                   => NULL);
                    --
                    END IF;
                    --
                    CLOSE c_oiplip;
                    --
                    load_cache(p_oipl_id    => l_oipl_id
                     ,p_oiplip_id           => l_oiplip.oiplip_id
                     ,p_par_pgm_id          => l_pgm_id
                     ,p_par_ptip_id         => l_ptip.ptip_id
                     ,p_par_plip_id         => l_plip.plip_id
                     ,p_par_pl_id           => l_pl_id
                     ,p_par_opt_id          => l_cop.opt_id
                     ,p_flag_bit_val        => l_flag_bit_val
                     ,p_oiplip_flag_bit_val => l_oiplip_flag_bit_val
                     ,p_trk_inelig_per_flag => l_cop.trk_inelig_per_flag);
                    --
                    hr_utility.set_location(l_package || ' End c_oipl loop ', 20);
                  END LOOP;
                --
                END IF;
                --
              END IF;
              --
              hr_utility.set_location(l_package || ' End c_pln loop ', 20);
            END LOOP;
          --
          END IF;
          --
          hr_utility.set_location(l_package || ' End c_pgm loop ', 15);
        END LOOP;
        --
        CLOSE c_pgm;
      --
      END IF;
      hr_utility.set_location(l_package || ' Done c_pgm ', 20);
      --
      -- get the stragglers, the plans that aren't in a program
      -- added p_no_programs = N so that if only programs, plnip are not included
      IF (p_mode  <> 'G') and
         ((  p_no_plans = 'N' AND p_pgm_id IS NULL and p_no_programs = 'Y') or
          ( p_no_plans = 'N' and p_no_programs = 'N' and p_pgm_id is null)
         )
       THEN
        --
        OPEN c_pln_nip;
        --
        LOOP
          --
          hr_utility.set_location(l_package || ' Start c_pln_nip ', 30);
          FETCH c_pln_nip INTO l_pln;
          hr_utility.set_location(l_package || ' Fetch c_pln_nip = '||
                                 l_pln.pl_id, 32);
          EXIT WHEN c_pln_nip%NOTFOUND;
          l_pl_id  := l_pln.pl_id;
          l_ptp_opt_typ_cd := l_pln.ptp_opt_typ_cd;
          --
          hr_utility.set_location(l_package || ' PLNNIP LC ', 16);
          --
          -- In collective agreement mode only process CAGR opt types
          --
          if l_ptp_opt_typ_cd <> 'CAGR'
            and p_mode = 'A'
          then
            --
            null;
            --
          else
            --
            -- Only set the flag bit if we have rates or profiles attached
            --
            IF    l_pln.drvbl_fctr_prtn_elig_flag = 'Y'
               OR l_pln.drvbl_fctr_apls_rts_flag = 'Y' THEN
              --
              l_flag_bit_val  :=
                set_flag_bit_val(p_business_group_id=> p_business_group_id
                 ,p_effective_date            => p_effective_date
                 ,p_drvbl_fctr_prtn_elig_flag => l_pln.drvbl_fctr_prtn_elig_flag
                 ,p_drvbl_fctr_apls_rts_flag  => l_pln.drvbl_fctr_apls_rts_flag
                 ,p_pgm_id                    => NULL
                 ,p_pl_id                     => l_pln.pl_id
                 ,p_oipl_id                   => NULL
                 ,p_oiplip_id                 => NULL
                 ,p_plip_id                   => NULL
                 ,p_ptip_id                   => NULL);
            --
            ELSE
              --
              l_flag_bit_val  := 0;
            --
            END IF;
            --
            load_cache(p_pl_id      => l_pl_id
             ,p_pl_nip              => 'Y'
             ,p_par_pl_id           => l_pl_id
             ,p_flag_bit_val        => l_flag_bit_val
             ,p_oiplip_flag_bit_val => 0
             ,p_trk_inelig_per_flag => l_pln.trk_inelig_per_flag);
            --
            hr_utility.set_location(l_package || ' fetch c_oipl 1', 20);
            ben_cop_cache.bgpcop_getdets(p_effective_date=> p_effective_date
             ,p_business_group_id => p_business_group_id
             ,p_pl_id             => l_pl_id
             ,p_opt_id            => p_opt_id
             ,p_eligy_prfl_id     => p_eligy_prfl_id
             ,p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
             ,p_mode              => p_mode
             --
             ,p_inst_set          => l_copinst_set);
            hr_utility.set_location(l_package || ' Dn fetch c_oipl 1', 20);
            hr_utility.set_location(' Number of oipls' || l_copinst_set.COUNT
             ,20);
            --
            IF l_copinst_set.COUNT > 0 THEN
              --
              FOR copelenum IN l_copinst_set.FIRST .. l_copinst_set.LAST LOOP
                --
                l_cop      := l_copinst_set(copelenum);
                l_oipl_id  := l_copinst_set(copelenum).oipl_id;
                --
                hr_utility.set_location(l_package || ' OIPL2 LC ', 16);
                --
                -- Only set the flag bit if we have rates or profiles attached
                --
                IF    l_cop.drvbl_fctr_prtn_elig_flag = 'Y'
                   OR l_cop.drvbl_fctr_apls_rts_flag = 'Y' THEN
                  --
                  l_flag_bit_val  :=
                    set_flag_bit_val(p_business_group_id=> p_business_group_id
                     ,p_effective_date            => p_effective_date
                     ,p_drvbl_fctr_prtn_elig_flag => l_cop.drvbl_fctr_prtn_elig_flag
                     ,p_drvbl_fctr_apls_rts_flag  => l_cop.drvbl_fctr_apls_rts_flag
                     ,p_pgm_id                    => NULL
                     ,p_pl_id                     => NULL
                     ,p_oipl_id                   => l_cop.oipl_id
                     ,p_oiplip_id                 => NULL
                     ,p_plip_id                   => NULL
                     ,p_ptip_id                   => NULL);
                --
                ELSE
                  --
                  l_flag_bit_val  := 0;
                --
                END IF;
                --
                load_cache(p_oipl_id    => l_oipl_id
                 ,p_pl_nip              => 'N'
                 ,p_par_pl_id           => l_pl_id
                 ,p_par_opt_id          => l_cop.opt_id
                 ,p_flag_bit_val        => l_flag_bit_val
                 ,p_oiplip_flag_bit_val => 0
                 ,p_trk_inelig_per_flag => l_cop.trk_inelig_per_flag);
              --
              END LOOP;
              --
              hr_utility.set_location(l_package || ' close c_oipl: ', 34);
            END IF;
            --
          END IF;
          --
        END LOOP;
        --
        CLOSE c_pln_nip;
      --
      END IF;
      hr_utility.set_location(l_package || ' Done c_pln_nip ', 30);
      --
      -- Always check for cobra programs last if mode is unrestricted or
      -- life event
      --
      IF p_mode IN ('L', 'U') THEN
        OPEN c_pgm2;
        --
        LOOP
          --
          hr_utility.set_location(l_package || ' fetch c_pgm2 ', 30);
          FETCH c_pgm2 INTO l_pgm;
          hr_utility.set_location(l_package || ' fetched c_pgm2 ', 30);
          EXIT WHEN c_pgm2%NOTFOUND;
          --
          l_pgm_id  := l_pgm.pgm_id;
          --
          --
          hr_utility.set_location(l_package || ' PGM2 LC ', 16);
          --
          -- Only set the flag bit if we have rates or profiles attached
          --
          IF    l_pgm.drvbl_fctr_prtn_elig_flag = 'Y'
             OR l_pgm.drvbl_fctr_apls_rts_flag = 'Y' THEN
            --
            l_flag_bit_val  :=
              set_flag_bit_val(p_business_group_id=> p_business_group_id
               ,p_effective_date            => p_effective_date
               ,p_drvbl_fctr_prtn_elig_flag => l_pgm.drvbl_fctr_prtn_elig_flag
               ,p_drvbl_fctr_apls_rts_flag  => l_pgm.drvbl_fctr_apls_rts_flag
               ,p_pgm_id                    => l_pgm.pgm_id
               ,p_pl_id                     => NULL
               ,p_oipl_id                   => NULL
               ,p_oiplip_id                 => NULL
               ,p_plip_id                   => NULL
               ,p_ptip_id                   => NULL);
          --
          ELSE
            --
            l_flag_bit_val  := 0;
          --
          END IF;
          --
          load_cache(p_pgm_id     => l_pgm_id
           ,p_par_pgm_id          => l_pgm_id
           ,p_flag_bit_val        => l_flag_bit_val
           ,p_oiplip_flag_bit_val => 0
           ,p_trk_inelig_per_flag => l_pgm.trk_inelig_per_flag);
          --
          IF p_no_plans = 'N' THEN
            --
            OPEN c_pln2;
            --
            LOOP
              --
              FETCH c_pln2 INTO l_pln;
              EXIT WHEN c_pln2%NOTFOUND;
              l_pl_id  := l_pln.pl_id;
              l_ptp_opt_typ_cd := l_pln.ptp_opt_typ_cd;
              --
              if l_ptp_opt_typ_cd <> 'CAGR'
                and p_mode = 'A'
              then
                --
                null;
                --
              else
                --
                -- We have to work out the PLIP and PTIP ids for the
                -- plan in program we are dealing with
                -- There will ALWAYS be a PLIP_ID but we cannot guarantee
                -- a PTIP id.
                --
                OPEN c_ptip;
                --
                FETCH c_ptip INTO l_ptip;
                --
                CLOSE c_ptip;
                --
                hr_utility.set_location('PTIP being cached ' || l_ptip.ptip_id
                 ,10);
                --
                -- Only set the flag bit if we have rates or profiles attached
                --
                IF    l_ptip.drvbl_fctr_prtn_elig_flag = 'Y'
                   OR l_ptip.drvbl_fctr_apls_rts_flag = 'Y' THEN
                  --
                  l_flag_bit_val  :=
                    set_flag_bit_val(p_business_group_id=> p_business_group_id
                     ,p_effective_date            => p_effective_date
                     ,p_drvbl_fctr_prtn_elig_flag => l_ptip.drvbl_fctr_prtn_elig_flag
                     ,p_drvbl_fctr_apls_rts_flag  => l_ptip.drvbl_fctr_apls_rts_flag
                     ,p_pgm_id                    => NULL
                     ,p_pl_id                     => NULL
                     ,p_oipl_id                   => NULL
                     ,p_oiplip_id                 => NULL
                     ,p_plip_id                   => NULL
                     ,p_ptip_id                   => l_ptip.ptip_id);
                --
                ELSE
                  --
                  l_flag_bit_val  := 0;
                --
                END IF;
                --
                load_cache(p_ptip_id    => l_ptip.ptip_id
                 ,p_par_pgm_id          => l_pgm_id
                 ,p_par_ptip_id         => l_ptip.ptip_id
                 ,p_flag_bit_val        => l_flag_bit_val
                 ,p_oiplip_flag_bit_val => 0
                 ,p_trk_inelig_per_flag => l_ptip.trk_inelig_per_flag);
                --
                OPEN c_plip;
                --
                FETCH c_plip INTO l_plip;
                --
                CLOSE c_plip;
                --
                -- Only set the flag bit if we have rates or profiles attached
                --
                IF    l_plip.drvbl_fctr_prtn_elig_flag = 'Y'
                   OR l_plip.drvbl_fctr_apls_rts_flag = 'Y' THEN
                  --
                  l_flag_bit_val  :=
                    set_flag_bit_val(p_business_group_id=> p_business_group_id
                     ,p_effective_date            => p_effective_date
                     ,p_drvbl_fctr_prtn_elig_flag => l_plip.drvbl_fctr_prtn_elig_flag
                     ,p_drvbl_fctr_apls_rts_flag  => l_plip.drvbl_fctr_apls_rts_flag
                     ,p_pgm_id                    => NULL
                     ,p_pl_id                     => NULL
                     ,p_oipl_id                   => NULL
                     ,p_oiplip_id                 => NULL
                     ,p_plip_id                   => l_plip.plip_id
                     ,p_ptip_id                   => NULL);
                --
                ELSE
                  --
                  l_flag_bit_val  := 0;
                --
                END IF;
                --
                load_cache(p_plip_id    => l_plip.plip_id
                 ,p_par_pgm_id          => l_pgm_id
                 ,p_par_ptip_id         => l_ptip.ptip_id
                 ,p_par_plip_id         => l_plip.plip_id
                 --RCHASE
                 ,p_par_pl_id         =>   l_pl_id
                 ,p_flag_bit_val        => l_flag_bit_val
                 ,p_oiplip_flag_bit_val => 0
                 ,p_trk_inelig_per_flag => l_plip.trk_inelig_per_flag);
                --
                hr_utility.set_location(l_package || ' PLN2 LC ', 16);
                --
                -- Only set the flag bit if we have rates or profiles attached
                --
                IF    l_pln.drvbl_fctr_prtn_elig_flag = 'Y'
                   OR l_pln.drvbl_fctr_apls_rts_flag = 'Y' THEN
                  --
                  l_flag_bit_val  :=
                    set_flag_bit_val(p_business_group_id=> p_business_group_id
                     ,p_effective_date            => p_effective_date
                     ,p_drvbl_fctr_prtn_elig_flag => l_pln.drvbl_fctr_prtn_elig_flag
                     ,p_drvbl_fctr_apls_rts_flag  => l_pln.drvbl_fctr_apls_rts_flag
                     ,p_pgm_id                    => NULL
                     ,p_pl_id                     => l_pln.pl_id
                     ,p_oipl_id                   => NULL
                     ,p_oiplip_id                 => NULL
                     ,p_plip_id                   => NULL
                     ,p_ptip_id                   => NULL);
                --
                ELSE
                  --
                  l_flag_bit_val  := 0;
                --
                END IF;
                load_cache(p_pl_id      => l_pl_id
                 ,p_par_pgm_id          => l_pgm_id
                 ,p_par_ptip_id         => l_ptip.ptip_id
                 ,p_par_plip_id         => l_plip.plip_id
                 ,p_par_pl_id           => l_pl_id
                 ,p_flag_bit_val        => l_flag_bit_val
                 ,p_oiplip_flag_bit_val => 0
                 ,p_trk_inelig_per_flag => l_pln.trk_inelig_per_flag);
                --
                OPEN c_oipl2;
                --
                LOOP
                  --
                  FETCH c_oipl2 INTO l_cop;
                  EXIT WHEN c_oipl2%NOTFOUND;
                  l_oipl_id  := l_cop.oipl_id;
                  --
                  hr_utility.set_location(l_package || ' c_oipl2 LC ', 30);
                  --
                  -- Only set the flag bit if we have rates or profiles attached
                  --
                  IF    l_cop.drvbl_fctr_prtn_elig_flag = 'Y'
                     OR l_cop.drvbl_fctr_apls_rts_flag = 'Y' THEN
                    --
                    l_flag_bit_val  :=
                      set_flag_bit_val(p_business_group_id=> p_business_group_id
                       ,p_effective_date            => p_effective_date
                       ,p_drvbl_fctr_prtn_elig_flag => l_cop.drvbl_fctr_prtn_elig_flag
                       ,p_drvbl_fctr_apls_rts_flag  => l_cop.drvbl_fctr_apls_rts_flag
                       ,p_pgm_id                    => NULL
                       ,p_pl_id                     => NULL
                       ,p_oipl_id                   => l_cop.oipl_id
                       ,p_oiplip_id                 => NULL
                       ,p_plip_id                   => NULL
                       ,p_ptip_id                   => NULL);
                  --
                  ELSE
                    --
                    l_flag_bit_val  := 0;
                  --
                  END IF;
                  --RCHASE Add for bug 1531030.  Was not getting oiplip info.
                    l_oiplip_flag_bit_val  := 0;
                    --
                    OPEN c_oiplip;
                    --hr_utility.set_location('l_plip.plip_id:'||to_char(l_plip.plip_id), 1999);
                    --hr_utility.set_location('l_cop.oipl_id:'||to_char(l_cop.oipl_id), 1999);
                    --hr_utility.set_location('l_oipl_id:'||to_char(l_oipl_id), 1999);
                    --
                    FETCH c_oiplip INTO l_oiplip;
                    --
                    IF c_oiplip%FOUND THEN
                      --hr_utility.set_location('OIPLIP_ID:'||to_char(l_oiplip.oiplip_id), 1999);
                      --
                      -- Try and derive bit value for oiplip record
                      --
                      l_oiplip_flag_bit_val  :=
                        set_flag_bit_val(p_business_group_id=> p_business_group_id
                         ,p_effective_date            => p_effective_date
                         ,p_drvbl_fctr_prtn_elig_flag => 'N'
                         ,p_drvbl_fctr_apls_rts_flag  => 'N'
                         ,p_pgm_id                    => NULL
                         ,p_pl_id                     => NULL
                         ,p_oipl_id                   => NULL
                         ,p_oiplip_id                 => l_oiplip.oiplip_id
                         ,p_plip_id                   => NULL
                         ,p_ptip_id                   => NULL);
                       --hr_utility.set_location('l_oiplip_flag_bit_val:'||l_oiplip_flag_bit_val, 1999);
                    --
                    END IF;
                    --
                    CLOSE c_oiplip;
                    --
                    --hr_utility.set_location('Loading Cache:', 1999);
                    load_cache(p_oipl_id    => l_oipl_id
                     ,p_oiplip_id           => l_oiplip.oiplip_id
                     ,p_par_pgm_id          => l_pgm_id
                     ,p_par_ptip_id         => l_ptip.ptip_id
                     ,p_par_plip_id         => l_plip.plip_id
                     ,p_par_pl_id           => l_pl_id
                     ,p_par_opt_id          => l_cop.opt_id
                     ,p_flag_bit_val        => l_flag_bit_val
                     ,p_oiplip_flag_bit_val => l_oiplip_flag_bit_val
                     ,p_trk_inelig_per_flag => l_cop.trk_inelig_per_flag);
                    --
                    --hr_utility.set_location(l_package || ' End c_oipl loop ', 20);
                  --
                  --RCHASE End Add
                  --RCHASE
                  --load_cache(p_oipl_id    => l_oipl_id
                  -- ,p_par_pgm_id          => l_pgm_id
                  -- ,p_par_ptip_id         => l_ptip.ptip_id
                  -- ,p_par_plip_id         => l_plip.plip_id
                  -- ,p_par_pl_id           => l_pl_id
                  -- ,p_par_opt_id          => l_opt_rec.opt_id
                  -- ,p_flag_bit_val        => l_flag_bit_val
                  -- ,p_oiplip_flag_bit_val => 0
                  -- ,p_trk_inelig_per_flag => l_cop.trk_inelig_per_flag);
                  --RCHASE End
                --
                END LOOP;
                --
                CLOSE c_oipl2;
                --
              end if;
              --
            END LOOP;
            --
            CLOSE c_pln2;
          --
          END IF;
        --
        END LOOP;
        --
        CLOSE c_pgm2;
      --
      END IF;
      --
      -- Do not write cache for a bypass cache
      --
      IF NOT l_bypass_cache THEN
        --
        -- Write comp object list to the multi session cache
        --
        write_multi_session_cache(p_effective_date=> p_effective_date
         ,p_business_group_id => p_business_group_id
         ,p_mode              => p_mode
         ,p_pgm_id            => p_pgm_id
         ,p_pl_id             => p_pl_id
         ,p_no_programs       => p_no_programs
         ,p_no_plans          => p_no_plans
         ,p_pl_typ_id         => p_pl_typ_id
         ,p_comp_obj_cache_id => l_comp_obj_cache_id);
      --
      END IF;
    --
    END IF;
    --
    -- Check if to bypass the cache
    --
    IF NOT l_bypass_cache THEN
      --
      -- Populate the local comp object list from the database version
      --
      ben_comp_object_list1.populate_comp_object_list
        (p_comp_obj_cache_id      => l_comp_obj_cache_id
        ,p_business_group_id      => p_business_group_id
        ,p_comp_selection_rule_id => p_comp_selection_rule_id
        ,p_effective_date         => p_effective_date
        );
      --
    end if;
    --
    hr_utility.set_location(l_package || ' Done c_pgm2 ', 40);
    IF NOT ben_manage_life_events.g_cache_proc_object.EXISTS(1) THEN
      --
      -- Different exceptions for different modes, if selection then this is
      -- a critical error, if anything else then its not a critical error
      --
      fnd_message.set_name('BEN', 'BEN_91664_BENMNGLE_NO_OBJECTS');
      --
      IF p_mode IN ('S', 'T') THEN
        --
        fnd_message.raise_error;
      --
      ELSE
        --
        RAISE ben_manage_life_events.g_record_error;
      --
      END IF;
    --
    END IF;
    --
    hr_utility.set_location(l_package || ' cache_working_data ', 60);
    cache_working_data(p_business_group_id=> p_business_group_id
     ,p_effective_date    => p_effective_date);
    --
    hr_utility.set_location('Leaving ' || l_package, 100);
  --
  END build_comp_object_list;
--
/* GSP Rate Sync */
procedure build_gsp_rate_sync_coobj_list
   (p_effective_date         IN DATE
   ,p_business_group_id      IN NUMBER DEFAULT NULL
   ,p_pgm_id                 IN NUMBER DEFAULT NULL
   ,p_pl_id                  IN NUMBER DEFAULT NULL
   ,p_opt_id                 IN NUMBER DEFAULT NULL
   ,p_plip_id                IN NUMBER DEFAULT NULL
   ,p_ptip_id                IN NUMBER DEFAULT NULL
   ,p_oipl_id                IN NUMBER DEFAULT NULL
   ,p_oiplip_id              IN NUMBER DEFAULT NULL
   ,p_person_id              in number default null
   ) is
  --
  l_proc                                varchar2(80);
  l_drvbl_fctr_prtn_elig_flag           varchar2(30);
  l_drvbl_fctr_apls_rts_flag            varchar2(30);
  l_trk_inelig_per_flag                 varchar2(30);
  l_flag_bit_val                        BINARY_INTEGER := 0;
  l_oiplip_flag_bit_val                 BINARY_INTEGER := 0;
  --
  cursor c_pgm (cv_pgm_id number) is
  select pgm.drvbl_fctr_prtn_elig_flag, pgm.drvbl_fctr_apls_rts_flag, pgm.trk_inelig_per_flag
    from ben_pgm_f pgm
   where pgm.pgm_id = cv_pgm_id
     and pgm.pgm_stat_cd = 'A'
     and p_effective_date between pgm.effective_start_date and pgm.effective_end_date;
  --
  CURSOR c_ptip (cv_ptip_id number) IS
  SELECT ctp.drvbl_fctr_prtn_elig_flag, ctp.drvbl_fctr_apls_rts_flag, ctp.trk_inelig_per_flag
    FROM ben_ptip_f ctp
   WHERE ctp.ptip_id = cv_ptip_id
     AND ctp.ptip_stat_cd = 'A'
     AND p_effective_date BETWEEN ctp.effective_start_date AND ctp.effective_end_date;
  --
  CURSOR c_pln (cv_pl_id number) IS
  SELECT pln.drvbl_fctr_prtn_elig_flag, pln.drvbl_fctr_apls_rts_flag, pln.trk_inelig_per_flag
    FROM ben_pl_f pln
   WHERE pln.pl_id = cv_pl_id
     AND pln.pl_stat_cd = 'A'
     AND p_effective_date BETWEEN pln.effective_start_date AND pln.effective_end_date;
  --
  CURSOR c_plip (cv_plip_id number) IS
  SELECT cpp.drvbl_fctr_prtn_elig_flag, cpp.drvbl_fctr_apls_rts_flag, cpp.trk_inelig_per_flag
    FROM ben_plip_f cpp
   WHERE cpp.plip_id = cv_plip_id
     AND cpp.plip_stat_cd = 'A'
     AND p_effective_date BETWEEN cpp.effective_start_date AND cpp.effective_end_date;
  --
  CURSOR c_oipl (cv_oipl_id number) IS
  SELECT cop.drvbl_fctr_prtn_elig_flag, cop.drvbl_fctr_apls_rts_flag, cop.trk_inelig_per_flag
    FROM ben_oipl_f cop
   WHERE cop.oipl_id = cv_oipl_id
     AND cop.oipl_stat_cd = 'A'
     AND p_effective_date BETWEEN cop.effective_start_date AND cop.effective_end_date;
  --
begin
  --
  l_proc := g_package || '.build_gsp_rate_sync_coobj_list';
  --
  hr_utility.set_location('Entering ' || l_proc, 10);
  --
  if p_plip_id is not null
  then
    --
    hr_utility.set_location('Populate g_cache_proc_object for PGM_ID = ' || p_pgm_id, 15);
    --
    --   Clear the comp object list
    --
    ben_manage_life_events.g_cache_proc_object.delete;
    --
    open c_pgm (p_pgm_id);
      --
      fetch c_pgm into l_drvbl_fctr_prtn_elig_flag, l_drvbl_fctr_apls_rts_flag, l_trk_inelig_per_flag;
      --
      if c_pgm%found
      then
         --
         if l_drvbl_fctr_prtn_elig_flag = 'Y' or l_drvbl_fctr_apls_rts_flag = 'Y'
         then
           --
           l_flag_bit_val  := set_flag_bit_val(p_business_group_id         => p_business_group_id
                                              ,p_effective_date            => p_effective_date
                                              ,p_drvbl_fctr_prtn_elig_flag => l_drvbl_fctr_prtn_elig_flag
                                              ,p_drvbl_fctr_apls_rts_flag  => l_drvbl_fctr_apls_rts_flag
                                              ,p_pgm_id                    => p_pgm_id
                                              ,p_pl_id                     => NULL
                                              ,p_oipl_id                   => NULL
                                              ,p_oiplip_id                 => NULL
                                              ,p_plip_id                   => NULL
                                              ,p_ptip_id                   => NULL);
        --
        else
        --
        l_flag_bit_val  := 0;
        --
        end if;
        --
        load_cache(p_pgm_id              => p_pgm_id
                  ,p_par_pgm_id          => p_pgm_id
                  ,p_flag_bit_val        => l_flag_bit_val
                  ,p_oiplip_flag_bit_val => 0
                  ,p_trk_inelig_per_flag => l_trk_inelig_per_flag);
        --
      end if;
      --
    close c_pgm;
    --
    hr_utility.set_location('Populate g_cache_proc_object for PLIP_ID = ' || p_plip_id, 15);
    --
    open c_plip (p_plip_id);
      --
      fetch c_plip into l_drvbl_fctr_prtn_elig_flag, l_drvbl_fctr_apls_rts_flag, l_trk_inelig_per_flag;
      --
      if c_plip%found
      then
        --
        if l_drvbl_fctr_prtn_elig_flag = 'Y'  OR l_drvbl_fctr_apls_rts_flag = 'Y'
        then
           --
           l_flag_bit_val := set_flag_bit_val(p_business_group_id         => p_business_group_id
                                             ,p_effective_date            => p_effective_date
                                             ,p_drvbl_fctr_prtn_elig_flag => l_drvbl_fctr_prtn_elig_flag
                                             ,p_drvbl_fctr_apls_rts_flag  => l_drvbl_fctr_apls_rts_flag
                                             ,p_pgm_id                    => NULL
                                             ,p_pl_id                     => NULL
                                             ,p_oipl_id                   => NULL
                                             ,p_oiplip_id                 => NULL
                                             ,p_plip_id                   => p_plip_id
                                             ,p_ptip_id                   => NULL);
          --
        else
          --
          l_flag_bit_val  := 0;
          --
        end if;
        --
        load_cache (p_plip_id             => p_plip_id
                   ,p_par_pgm_id          => p_pgm_id
                   ,p_par_ptip_id         => p_ptip_id
                   ,p_par_plip_id         => p_plip_id
                   ,p_par_pl_id           => p_pl_id
                   ,p_flag_bit_val        => l_flag_bit_val
                   ,p_oiplip_flag_bit_val => 0
                   ,p_trk_inelig_per_flag => l_trk_inelig_per_flag);
        --
      end if;     /* c_plip%found */
      --
    close c_plip;
    --
    hr_utility.set_location('Populate g_cache_proc_object for PL_ID = ' || p_pl_id, 15);
    --
    open c_pln (p_pl_id);
      --
      fetch c_pln into l_drvbl_fctr_prtn_elig_flag, l_drvbl_fctr_apls_rts_flag, l_trk_inelig_per_flag;
      --
      if c_pln%found
      then
        --
         if l_drvbl_fctr_prtn_elig_flag = 'Y' or l_drvbl_fctr_apls_rts_flag = 'Y'
         then
           --
           l_flag_bit_val  := set_flag_bit_val(p_business_group_id=> p_business_group_id
                                              ,p_effective_date            => p_effective_date
                                              ,p_drvbl_fctr_prtn_elig_flag => l_drvbl_fctr_prtn_elig_flag
                                              ,p_drvbl_fctr_apls_rts_flag  => l_drvbl_fctr_apls_rts_flag
                                              ,p_pgm_id                    => NULL
                                              ,p_pl_id                     => NULL
                                              ,p_oipl_id                   => NULL
                                              ,p_oiplip_id                 => NULL
                                              ,p_plip_id                   => p_plip_id
                                              ,p_ptip_id                   => NULL);
           --
         else
           --
           l_flag_bit_val  := 0;
           --
        end if;
        --
        load_cache(p_pl_id               => p_pl_id
                  ,p_par_pgm_id          => p_pgm_id
                  ,p_par_ptip_id         => p_ptip_id
                  ,p_par_plip_id         => p_plip_id
                  ,p_par_pl_id           => p_pl_id
                  ,p_flag_bit_val        => l_flag_bit_val
                  ,p_oiplip_flag_bit_val => 0
                  ,p_trk_inelig_per_flag => l_trk_inelig_per_flag);
        --
      end if;
      --
    close c_pln;
     --
     if p_oipl_id is not null
     then
        --
        hr_utility.set_location('Populate g_cache_proc_object for OIPL_ID = ' || p_oipl_id, 25);
        --
        open c_oipl (p_oipl_id);
          --
          fetch c_oipl into l_drvbl_fctr_prtn_elig_flag, l_drvbl_fctr_apls_rts_flag, l_trk_inelig_per_flag;
          --
          if c_oipl%found
          then
            --
            if l_drvbl_fctr_prtn_elig_flag = 'Y'  OR l_drvbl_fctr_apls_rts_flag = 'Y'
            then
               --
               l_flag_bit_val := set_flag_bit_val(p_business_group_id         => p_business_group_id
                                                 ,p_effective_date            => p_effective_date
                                                 ,p_drvbl_fctr_prtn_elig_flag => l_drvbl_fctr_prtn_elig_flag
                                                 ,p_drvbl_fctr_apls_rts_flag  => l_drvbl_fctr_apls_rts_flag
                                                 ,p_pgm_id                    => NULL
                                                 ,p_pl_id                     => NULL
                                                 ,p_oipl_id                   => NULL
                                                 ,p_oiplip_id                 => p_oipl_id
                                                 ,p_plip_id                   => NULL
                                                 ,p_ptip_id                   => NULL);
              --
            else
              --
              l_flag_bit_val  := 0;
              --
            end if;
            --
            l_oiplip_flag_bit_val  :=  set_flag_bit_val(p_business_group_id=> p_business_group_id
                                                       ,p_effective_date            => p_effective_date
                                                       ,p_drvbl_fctr_prtn_elig_flag => 'N'
                                                       ,p_drvbl_fctr_apls_rts_flag  => 'N'
                                                       ,p_pgm_id                    => NULL
                                                       ,p_pl_id                     => NULL
                                                       ,p_oipl_id                   => NULL
                                                       ,p_oiplip_id                 => p_oiplip_id
                                                       ,p_plip_id                   => NULL
                                                       ,p_ptip_id                   => NULL);
            --
            load_cache (p_oipl_id             => p_oipl_id
                       ,p_oiplip_id           => p_oiplip_id
                       ,p_par_pgm_id          => p_pgm_id
                       ,p_par_ptip_id         => p_ptip_id
                       ,p_par_plip_id         => p_plip_id
                       ,p_par_pl_id           => p_pl_id
                       ,p_par_opt_id          => p_opt_id
                       ,p_flag_bit_val        => l_flag_bit_val
                       ,p_oiplip_flag_bit_val => l_oiplip_flag_bit_val
                       ,p_trk_inelig_per_flag => l_trk_inelig_per_flag);
             --
           end if;     /* c_oipl%found */
           --
         close c_oipl;
         --

     end if;    /* p_oipl_id is not null */
   end if;  /* p_plip_id is not null */

  --
  hr_utility.set_location('Leaving ' || l_proc, 20);
  --
end build_gsp_rate_sync_coobj_list;
END ben_comp_object_list;

/

--------------------------------------------------------
--  DDL for Package Body BEN_ICM_LIFE_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ICM_LIFE_EVENTS" AS
/* $Header: benicmle.pkb 120.6 2008/01/07 15:47:08 rtagarra noship $ */
/*
+==============================================================================+
|        Copyright (c) 1997 Oracle Corporation                  |
|           Redwood Shores, California, USA                     |
|                All rights reserved.                         |
+==============================================================================+
Name:
    Determine Rates.
Purpose:
    This process is a wrapper procedure for ICD Life Event.
History:
 Date             Who        Version    What?
 ----             ---        -------    -----
 10-Feb-07        rtagarra   120.0      Created.
 28-Mar-07        rtagarra   120.1      GSCC checks.
 29-Apr-07        rtagarra   120.2      Added code to so tht ICD Team can show proper message.
 12-Jun-07        rtagarra   120.4      Bug 6038232
 07-Jan-08        rtagarra   120.5      Changed the message number
----------------------------------------------------------------------------------------------*/
--
   g_benefit_action_id   NUMBER;
   g_package             VARCHAR2 (80) := 'ben_icm_life_events';
   g_debug               BOOLEAN       := hr_utility.debug_enabled;

----------------------------------------------------------------------------------------------
   --
   PROCEDURE insert_into_icd (
      l_icd_chc_rates_tab   icd_chc_rates_tab,
      p_effective_date      DATE,
      p_person_id           NUMBER,
      p_business_group_id   NUMBER,
      p_rt_strt_dt          DATE,
      p_rt_strt_dt_cd       VARCHAR2,
      p_rt_strt_dt_rl       NUMBER,
      p_rt_end_dt           DATE,
      p_rt_end_dt_cd        VARCHAR2,
      p_rt_end_dt_rl        NUMBER,
      j_count               NUMBER
   )
   IS
--
      CURSOR c_pl_info (p_pl_id NUMBER)
      IS
         SELECT pln.rt_strt_dt_cd, pln.rt_strt_dt_rl, pln.rt_end_dt_cd,
                pln.rt_end_dt_rl, pln.bnf_dsgn_cd
           FROM ben_pl_f pln
          WHERE pln.pl_id = p_pl_id
            AND p_effective_date BETWEEN pln.effective_start_date
                                     AND pln.effective_end_date;

--
      l_pl_info        c_pl_info%ROWTYPE;

--
      CURSOR c_abr_info (p_acty_base_rt_id NUMBER)
      IS
         SELECT nnmntry_uom, cost_allocation_keyflex_id
           FROM ben_acty_base_rt_f
          WHERE acty_base_rt_id = p_acty_base_rt_id
            AND p_effective_date BETWEEN effective_start_date
                                     AND effective_end_date;

--
      l_abr_info       c_abr_info%ROWTYPE;

--
      CURSOR c_next_val
      IS
         SELECT ben_icd_chc_rates_s.NEXTVAL
           FROM DUAL;

--
      l_next_val       NUMBER;
      l_bnf_rqd_flag   VARCHAR2 (30)        := 'N';
--
   BEGIN
--
      g_debug := hr_utility.debug_enabled;

--
      IF (g_debug)
      THEN
         hr_utility.set_location ('Entering insert_into_icd ', 213);
      END IF;

--
      OPEN c_next_val;

      FETCH c_next_val
       INTO l_next_val;

      CLOSE c_next_val;

      --
      OPEN c_pl_info (l_icd_chc_rates_tab (j_count).pl_id);

      FETCH c_pl_info
       INTO l_pl_info;

      CLOSE c_pl_info;

--
      IF l_pl_info.bnf_dsgn_cd = 'R'
      THEN
         --
         l_bnf_rqd_flag := 'Y';
      --
      END IF;

      OPEN c_abr_info (l_icd_chc_rates_tab (j_count).acty_base_rt_id);

      FETCH c_abr_info
       INTO l_abr_info;

      CLOSE c_abr_info;

      --
      INSERT INTO ben_icd_chc_rates
                  (icd_chc_rate_id, person_id, business_group_id,
                   assignment_id,
                   effective_date,
                   acty_base_rt_id,
                   pl_id,
                   pl_typ_id,
                   oipl_id,
                   opt_id,
                   pl_ordr_num,
                   oipl_ordr_num,
                   nnmntry_uom, rt_strt_dt_cd,
                   rt_strt_dt, rt_strt_dt_rl, rt_end_dt_cd,
                   rt_end_dt, rt_end_dt_rl, bnf_rqd_flag,
                   input_value_id1,
                   input_value1,
                   input_value_id2,
                   input_value2,
                   input_value_id3,
                   input_value3,
                   input_value_id4,
                   input_value4,
                   input_value_id5,
                   input_value5,
                   input_value_id6,
                   input_value6,
                   input_value_id7,
                   input_value7,
                   input_value_id8,
                   input_value8,
                   input_value_id9,
                   input_value9,
                   input_value_id10,
                   input_value10,
                   input_value_id11,
                   input_value11,
                   input_value_id12,
                   input_value12,
                   input_value_id13,
                   input_value13,
                   input_value_id14,
                   input_value14,
                   input_value_id15,
                   input_value15,
                   element_type_id,
                   element_link_id, object_version_number, last_update_date,
                   last_updated_by, creation_date, created_by,
                   cost_allocation_keyflex_id, elig_flag
                  )
           VALUES (l_next_val, p_person_id, p_business_group_id,
                   l_icd_chc_rates_tab (j_count).l_assignment_id,
                   p_effective_date,
                   l_icd_chc_rates_tab (j_count).acty_base_rt_id,
                   l_icd_chc_rates_tab (j_count).pl_id,
                   l_icd_chc_rates_tab (j_count).pl_typ_id,
                   l_icd_chc_rates_tab (j_count).oipl_id,
                   l_icd_chc_rates_tab (j_count).opt_id,
                   l_icd_chc_rates_tab (j_count).pl_ordr_num,
                   l_icd_chc_rates_tab (j_count).oipl_ordr_num,
                   l_abr_info.nnmntry_uom, l_pl_info.rt_strt_dt_cd,
                   p_rt_strt_dt, p_rt_strt_dt_rl, l_pl_info.rt_end_dt_cd,
                   hr_api.g_eot, p_rt_end_dt_rl, l_bnf_rqd_flag,
                   l_icd_chc_rates_tab (j_count).input_value_id1,
                   l_icd_chc_rates_tab (j_count).input_value1,
                   l_icd_chc_rates_tab (j_count).input_value_id2,
                   l_icd_chc_rates_tab (j_count).input_value2,
                   l_icd_chc_rates_tab (j_count).input_value_id3,
                   l_icd_chc_rates_tab (j_count).input_value3,
                   l_icd_chc_rates_tab (j_count).input_value_id4,
                   l_icd_chc_rates_tab (j_count).input_value4,
                   l_icd_chc_rates_tab (j_count).input_value_id5,
                   l_icd_chc_rates_tab (j_count).input_value5,
                   l_icd_chc_rates_tab (j_count).input_value_id6,
                   l_icd_chc_rates_tab (j_count).input_value6,
                   l_icd_chc_rates_tab (j_count).input_value_id7,
                   l_icd_chc_rates_tab (j_count).input_value7,
                   l_icd_chc_rates_tab (j_count).input_value_id8,
                   l_icd_chc_rates_tab (j_count).input_value8,
                   l_icd_chc_rates_tab (j_count).input_value_id9,
                   l_icd_chc_rates_tab (j_count).input_value9,
                   l_icd_chc_rates_tab (j_count).input_value_id10,
                   l_icd_chc_rates_tab (j_count).input_value10,
                   l_icd_chc_rates_tab (j_count).input_value_id11,
                   l_icd_chc_rates_tab (j_count).input_value11,
                   l_icd_chc_rates_tab (j_count).input_value_id12,
                   l_icd_chc_rates_tab (j_count).input_value12,
                   l_icd_chc_rates_tab (j_count).input_value_id13,
                   l_icd_chc_rates_tab (j_count).input_value13,
                   l_icd_chc_rates_tab (j_count).input_value_id14,
                   l_icd_chc_rates_tab (j_count).input_value14,
                   l_icd_chc_rates_tab (j_count).input_value_id15,
                   l_icd_chc_rates_tab (j_count).input_value15,
                   l_icd_chc_rates_tab (j_count).element_type_id,
                   l_icd_chc_rates_tab (j_count).element_link_id, 1, SYSDATE,
                   fnd_global.user_id, SYSDATE, fnd_global.user_id,
                   l_abr_info.cost_allocation_keyflex_id, 'Y'
                  );

      --
      IF (g_debug)
      THEN
         hr_utility.set_location ('Leaving Insert_Into_Icd ', 213);
      END IF;
   --
   EXCEPTION
      --
      WHEN OTHERS
      THEN
         --
         IF (g_debug)
         THEN
            hr_utility.set_location ('SQLERRM' || SUBSTR (SQLERRM, 1, 50),
                                     121
                                    );
            hr_utility.set_location ('SQLERRM' || SUBSTR (SQLERRM, 51, 100),
                                     121
                                    );
         END IF;

         fnd_message.set_name ('PER', 'FFU10_GENERAL_ORACLE_ERROR');
         fnd_message.set_token ('2', SUBSTR (SQLERRM, 1, 200));
         ben_icm_life_events.g_cache_pep_object.DELETE;
         ben_icm_life_events.g_cache_epo_object.DELETE;
         ben_determine_activity_base_rt.l_icd_chc_rates_tab.DELETE;
         ROLLBACK TO elig_per_cache_savepont;
   --
   END insert_into_icd;
   --
   PROCEDURE create_icd_rates (
      p_person_id           NUMBER,
      p_effective_date      DATE,
      p_business_group_id   NUMBER
   )
   IS
      --
      l_icd_count            NUMBER;
      cache1                 NUMBER;
      j                      NUMBER             := 1;
      cache11                NUMBER             := 1;
      cache22                NUMBER             := 1;
      cache2                 NUMBER;
      l_rt_strt_dt           DATE;
      l_rt_strt_dt_cd        VARCHAR2 (30);
      l_rt_strt_dt_rl        NUMBER;
      l_enrt_cvg_end_dt      DATE;
      l_enrt_cvg_end_dt_cd   VARCHAR2 (30);
      l_enrt_cvg_end_dt_rl   NUMBER;
      l_rt_end_dt            DATE;
      l_rt_end_dt_cd         VARCHAR2 (30);
      l_rt_end_dt_rl         NUMBER;
      l_dummy_date           DATE;
      l_dummy_char           VARCHAR2 (30);
      l_dummy_num            NUMBER;
      j_count                NUMBER;

      --
      CURSOR c_opt_id (p_oipl_id NUMBER)
      IS
         SELECT opt_id, pl_id
           FROM ben_oipl_f
          WHERE oipl_id = p_oipl_id;

      --
      l_opt_id               c_opt_id%ROWTYPE;
   --
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         hr_utility.set_location ('Entering create_icd_rates ', 213);
      END IF;

      l_icd_count := ben_determine_activity_base_rt.l_icd_chc_rates_tab.COUNT;

      IF g_debug
      THEN
         hr_utility.set_location ('l_icd_count' || l_icd_count, 31);
      END IF;

      --
--For Plan Level Rates
      WHILE l_icd_count > 0
      LOOP
         --
         IF ben_determine_activity_base_rt.l_icd_chc_rates_tab (l_icd_count).l_level =
                                                                          'P'
         THEN
            --
            cache1 := ben_icm_life_events.g_cache_pep_object.COUNT;

            IF g_debug
            THEN
               hr_utility.set_location ('cache1' || cache1, 111);
            END IF;

            --
            cache11 := 1;

            WHILE cache1 > 0
            LOOP
               --
               IF g_debug
               THEN
                  hr_utility.set_location ('cache1' || cache1, 112);
                  hr_utility.set_location
                     (   'ben_determine_activity_base_rt.l_icd_chc_rates_tab(l_icd_count).pl_id'
                      || TO_CHAR
                            (ben_determine_activity_base_rt.l_icd_chc_rates_tab
                                                                  (l_icd_count).pl_id
                            ),
                      12
                     );
                  hr_utility.set_location
                     (   'ben_icm_life_events.g_cache_pep_object (cache11).pl_id'
                      || TO_CHAR
                            (ben_icm_life_events.g_cache_pep_object (cache11).pl_id
                            ),
                      12
                     );
               END IF;

               --
               IF ben_determine_activity_base_rt.l_icd_chc_rates_tab
                                                                  (l_icd_count).pl_id =
                        ben_icm_life_events.g_cache_pep_object (cache11).pl_id
               THEN
                  --
                  IF    ben_icm_life_events.g_cache_pep_object (cache11).p_first_elig
                     OR ben_icm_life_events.g_cache_pep_object (cache11).p_newly_elig
                     OR ben_icm_life_events.g_cache_pep_object (cache11).p_still_elig
                  THEN
                     --
                     ben_determine_date.rate_and_coverage_dates
                        (p_cache_mode               => TRUE,
                         p_par_ptip_id              => ben_icm_life_events.g_cache_pep_object
                                                                      (cache11).ptip_id,
                         p_par_plip_id              => ben_icm_life_events.g_cache_pep_object
                                                                      (cache11).plip_id,
                         p_person_id                => p_person_id,
                         p_per_in_ler_id            => NULL,
                         p_pgm_id                   => NULL,
                         p_pl_id                    => ben_icm_life_events.g_cache_pep_object
                                                                      (cache11).pl_id,
                         p_oipl_id                  => ben_determine_activity_base_rt.l_icd_chc_rates_tab
                                                                  (l_icd_count).oipl_id,
                         p_enrt_perd_id             => NULL,
                         p_lee_rsn_id               => NULL,
                         p_which_dates_cd           => 'R',
                         p_date_mandatory_flag      => 'N',
                         p_compute_dates_flag       => 'Y',
                         p_business_group_id        => p_business_group_id,
                         p_acty_base_rt_id          => ben_determine_activity_base_rt.l_icd_chc_rates_tab
                                                                  (l_icd_count).acty_base_rt_id,
                         p_effective_date           => p_effective_date,
                         p_lf_evt_ocrd_dt           => NULL,
                         p_rt_strt_dt               => l_rt_strt_dt,
                         p_rt_strt_dt_cd            => l_rt_strt_dt_cd,
                         p_rt_strt_dt_rl            => l_rt_strt_dt_rl,
                         p_enrt_cvg_strt_dt         => l_dummy_date,
                         p_enrt_cvg_strt_dt_cd      => l_dummy_char,
                         p_enrt_cvg_strt_dt_rl      => l_dummy_num,
                         p_enrt_cvg_end_dt          => l_dummy_date,
                         p_enrt_cvg_end_dt_cd       => l_dummy_char,
                         p_enrt_cvg_end_dt_rl       => l_dummy_num,
                         p_rt_end_dt                => l_dummy_date,
                         p_rt_end_dt_cd             => l_dummy_char,
                         p_rt_end_dt_rl             => l_dummy_num
                        );
--
                     ben_determine_activity_base_rt.l_icd_chc_rates_tab
                                                                  (l_icd_count).oipl_id :=
                                                                          NULL;
                     ben_determine_activity_base_rt.l_icd_chc_rates_tab
                                                                  (l_icd_count).opt_id :=
                                                                          NULL;
                     insert_into_icd
                        (l_icd_chc_rates_tab      => ben_determine_activity_base_rt.l_icd_chc_rates_tab,
                         p_effective_date         => p_effective_date,
                         p_person_id              => p_person_id,
                         p_business_group_id      => p_business_group_id,
                         p_rt_strt_dt             => l_rt_strt_dt,
                         p_rt_strt_dt_cd          => l_rt_strt_dt_cd,
                         p_rt_strt_dt_rl          => l_rt_strt_dt_rl,
                         p_rt_end_dt              => l_dummy_date,
                         p_rt_end_dt_cd           => l_dummy_char,
                         p_rt_end_dt_rl           => l_dummy_num,
                         j_count                  => l_icd_count
                        );
--
               --
                  ELSIF ben_icm_life_events.g_cache_pep_object (cache11).p_newly_inelig
                  THEN
                     --
                     DELETE FROM ben_icd_chc_rates
                           WHERE person_id = p_person_id
                             AND pl_id =
                                    ben_icm_life_events.g_cache_pep_object
                                                                      (cache11).pl_id;
                  --
                  END IF;
               --
               END IF;

               cache11 := cache11 + 1;
               --
               cache1 := cache1 - 1;

               --
               IF g_debug
               THEN
                  hr_utility.set_location ('cache1 ' || cache1, 333);
                  hr_utility.set_location ('cache11 ' || cache11, 333);
               END IF;
            END LOOP;
         --
         END IF;

         j := j + 1;
         l_icd_count := l_icd_count - 1;

         IF g_debug
         THEN
            hr_utility.set_location ('l_icd_count ' || l_icd_count, 333);
         END IF;
      --
      END LOOP;

--End For Plan Level Rates

      --For OIPL Level Rates
      l_icd_count := ben_determine_activity_base_rt.l_icd_chc_rates_tab.COUNT;

      IF g_debug
      THEN
         hr_utility.set_location ('l_icd_count' || l_icd_count, 33);
      END IF;

      j := 1;

--      cache11 := 1;
      --
--For OIPL Level Rates
      WHILE l_icd_count > 0
      LOOP
         --
         IF ben_determine_activity_base_rt.l_icd_chc_rates_tab (l_icd_count).l_level =
                                                                          'O'
         THEN
            cache1 := ben_icm_life_events.g_cache_epo_object.COUNT;

            IF g_debug
            THEN
               hr_utility.set_location ('rtagarra cache1' || cache1, 115);
            END IF;

            cache11 := 1;

            WHILE cache1 > 0
            LOOP
               --
               IF g_debug
               THEN
                  hr_utility.set_location
                     (   'l_icd_chc_rates_tab(l_icd_count).opt_id'
                      || ben_determine_activity_base_rt.l_icd_chc_rates_tab
                                                                  (l_icd_count).opt_id,
                      12
                     );
                  hr_utility.set_location
                      (   'g_cache_epo_object (cache11).opt_id'
                       || ben_icm_life_events.g_cache_epo_object (cache11).opt_id,
                       12
                      );
                  hr_utility.set_location
                     (   'l_icd_chc_rates_tab(l_icd_count).opt_id'
                      || ben_determine_activity_base_rt.l_icd_chc_rates_tab
                                                                  (l_icd_count).oipl_id,
                      12
                     );
                  --
                  hr_utility.set_location
                     (   'g_cache_epo_pl_id'
                      || ben_icm_life_events.g_cache_epo_object (cache11).p_pl_id,
                      431234
                     );
               END IF;

               OPEN c_opt_id
                      (ben_determine_activity_base_rt.l_icd_chc_rates_tab
                                                                  (l_icd_count).oipl_id
                      );

               FETCH c_opt_id
                INTO l_opt_id;
               CLOSE c_opt_id;

--
               IF g_debug
               THEN
                  hr_utility.set_location ('l_opt_id.pl_id' || l_opt_id.pl_id,
                                           13
                                          );
               END IF;
               IF     l_opt_id.opt_id =
                         ben_icm_life_events.g_cache_epo_object (cache11).opt_id
                  AND l_opt_id.pl_id =
                         ben_icm_life_events.g_cache_epo_object (cache11).p_pl_id
               THEN
                       --
                  --ben_determine_activity_base_rt.l_icd_chc_rates_tab(l_icd_count).pl_id := l_opt_id.pl_id;
                  IF    ben_icm_life_events.g_cache_epo_object (cache11).p_first_elig
                     OR ben_icm_life_events.g_cache_epo_object (cache11).p_newly_elig
                     OR ben_icm_life_events.g_cache_epo_object (cache11).p_still_elig
                  THEN
--

                   ben_determine_date.rate_and_coverage_dates
                        (p_cache_mode               => TRUE,
/*                         p_par_ptip_id              => ben_icm_life_events.g_cache_pep_object
                                                                      (cache11).ptip_id,
                         p_par_plip_id              => ben_icm_life_events.g_cache_pep_object
                                                                      (cache11).plip_id,*/
                         p_person_id                => p_person_id,
                         p_per_in_ler_id            => NULL,
                         p_pgm_id                   => NULL,
                         p_pl_id                    => ben_icm_life_events.g_cache_epo_object
                                                                      (cache11).p_pl_id,
                         p_oipl_id                  => ben_determine_activity_base_rt.l_icd_chc_rates_tab
                                                                  (l_icd_count).oipl_id,
                         p_enrt_perd_id             => NULL,
                         p_lee_rsn_id               => NULL,
                         p_which_dates_cd           => 'R',
                         p_date_mandatory_flag      => 'N',
                         p_compute_dates_flag       => 'Y',
                         p_business_group_id        => p_business_group_id,
                         p_acty_base_rt_id          => ben_determine_activity_base_rt.l_icd_chc_rates_tab
                                                                  (l_icd_count).acty_base_rt_id,
                         p_effective_date           => p_effective_date,
                         p_lf_evt_ocrd_dt           => NULL,
                         p_rt_strt_dt               => l_rt_strt_dt,
                         p_rt_strt_dt_cd            => l_rt_strt_dt_cd,
                         p_rt_strt_dt_rl            => l_rt_strt_dt_rl,
                         p_enrt_cvg_strt_dt         => l_dummy_date,
                         p_enrt_cvg_strt_dt_cd      => l_dummy_char,
                         p_enrt_cvg_strt_dt_rl      => l_dummy_num,
                         p_enrt_cvg_end_dt          => l_dummy_date,
                         p_enrt_cvg_end_dt_cd       => l_dummy_char,
                         p_enrt_cvg_end_dt_rl       => l_dummy_num,
                         p_rt_end_dt                => l_dummy_date,
                         p_rt_end_dt_cd             => l_dummy_char,
                         p_rt_end_dt_rl             => l_dummy_num
                        );
                     --
                     insert_into_icd
                        (l_icd_chc_rates_tab      => ben_determine_activity_base_rt.l_icd_chc_rates_tab,
                         p_effective_date         => p_effective_date,
                         p_person_id              => p_person_id,
                         p_business_group_id      => p_business_group_id,
                         p_rt_strt_dt             => l_rt_strt_dt,
                         p_rt_strt_dt_cd          => l_rt_strt_dt_cd,
                         p_rt_strt_dt_rl          => l_rt_strt_dt_rl,
                         p_rt_end_dt              => l_dummy_date,
                         p_rt_end_dt_cd           => l_dummy_char,
                         p_rt_end_dt_rl           => l_dummy_num,
                         j_count                  => l_icd_count
                        );
--
               --
                  ELSIF ben_icm_life_events.g_cache_epo_object (cache11).p_newly_inelig
                  THEN
                     --
                     IF g_debug
                     THEN
                        hr_utility.set_location ('Deleting ICD Rates', 321);
                     END IF;

                     DELETE FROM ben_icd_chc_rates
                           WHERE person_id = p_person_id
                             AND opt_id =
                                    ben_icm_life_events.g_cache_epo_object
                                                                      (cache11).opt_id;
                  --
                  END IF;
               --
               END IF;

               cache11 := cache11 + 1;
               --
               cache1 := cache1 - 1;
            END LOOP;
         --
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location ('cache1 ' || cache1, 333);
            hr_utility.set_location ('cache11 ' || cache11, 333);
         END IF;

         j := j + 1;
         l_icd_count := l_icd_count - 1;
      --
      END LOOP;

      --
      IF g_debug
      THEN
         hr_utility.set_location ('Leaving create_icd_rates ', 213);
      END IF;
   EXCEPTION
      --
      WHEN OTHERS
      THEN
         --
         IF g_debug
         THEN
            hr_utility.set_location ('SQLERRM' || SUBSTR (SQLERRM, 1, 50),
                                     121
                                    );
         END IF;

         fnd_message.set_name ('PER', 'FFU10_GENERAL_ORACLE_ERROR');
         fnd_message.set_token ('2', SUBSTR (SQLERRM, 1, 200));
         ben_icm_life_events.g_cache_pep_object.DELETE;
         ben_icm_life_events.g_cache_epo_object.DELETE;
         ben_determine_activity_base_rt.l_icd_chc_rates_tab.DELETE;
         ROLLBACK TO elig_per_cache_savepont;
   END create_icd_rates;
   --
   PROCEDURE create_pep_epo_rec (p_person_id NUMBER)
   IS
      --
      l_pep_count               NUMBER;
      l_count2                  NUMBER;
      l_effective_start_date    DATE;
      l_effective_end_date      DATE;
      l_count                   NUMBER                                := 1;
      l_icd_count               NUMBER;
      v_count                   NUMBER                                := 1;
      l_object_version_number   NUMBER;

      --
     /* CURSOR c_trk_inelig_per_flag (p_opt_id NUMBER)
      IS
         SELECT trk_inelig_per_flag
           FROM ben_oipl_f
          WHERE opt_id = p_opt_id;

      --
      l_trk_inelig_per_flag     ben_oipl_f.trk_inelig_per_flag%TYPE;

      --
      CURSOR c_pep_ovn (p_elig_per_id IN NUMBER)
      IS
         SELECT object_version_number
           FROM ben_elig_per_f pep
          WHERE pep.elig_per_id = p_elig_per_id;

      --
      l_pep_ovn                 NUMBER;

      --
      CURSOR c_epo_ovn (p_elig_per_opt_id IN NUMBER)
      IS
         SELECT object_version_number
           FROM ben_elig_per_opt_f epo
          WHERE epo.elig_per_opt_id = p_elig_per_opt_id;

      --
      l_epo_ovn                 NUMBER;*/
   --
   BEGIN
--
      g_debug := hr_utility.debug_enabled;
      IF g_debug
      THEN
         hr_utility.set_location ('RTAGARRA: Entering CREATE_PEP_EPO_REC',
                                  12121
                                 );
      END IF;

--
      l_pep_count := ben_icm_life_events.g_cache_pep_object.COUNT;
      l_count2 := ben_icm_life_events.g_cache_epo_object.COUNT;

      --
      IF g_debug
      THEN
         hr_utility.set_location ('l_pep_count ' || l_pep_count, 12121);
         hr_utility.set_location ('l_count2 ' || l_count2, 12121);
      END IF;

      WHILE l_pep_count > 0
      LOOP
--
/*         OPEN c_pep_ovn
                 (ben_icm_life_events.g_cache_pep_object (l_count).elig_per_id
                 );

         FETCH c_pep_ovn
          INTO l_pep_ovn;

         CLOSE c_pep_ovn;*/

--
         IF    --ben_icm_life_events.g_cache_pep_object (l_count).p_still_inelig OR
	       ben_icm_life_events.g_cache_pep_object (l_count).p_still_elig
         THEN
--
            IF g_debug
            THEN
               hr_utility.set_location ('Still ELig or Still Inelig', 31);
            END IF;
--
 ben_eligible_person_perf_api.update_perf_eligible_person
               (p_validate                          => FALSE,
                p_elig_per_id                       => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).elig_per_id,
                p_per_in_ler_id                     => NULL,
                p_effective_start_date              => l_effective_start_date,
                p_effective_end_date                => l_effective_end_date,
                p_elig_flag                         => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).elig_flag,
                p_prtn_strt_dt                      => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).prtn_strt_dt,
                p_rt_comp_ref_amt                   => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_comp_ref_amt,
                p_rt_cmbn_age_n_los_val             => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_cmbn_age_n_los_val,
                p_rt_comp_ref_uom                   => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_comp_ref_uom,
                p_rt_age_val                        => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_age_val,
                p_rt_los_val                        => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_los_val,
                p_rt_hrs_wkd_val                    => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_hrs_wkd_val,
                p_rt_hrs_wkd_bndry_perd_cd          => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_hrs_wkd_bndry_perd_cd,
                p_rt_age_uom                        => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_age_uom,
                p_rt_los_uom                        => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_los_uom,
                p_rt_pct_fl_tm_val                  => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_pct_fl_tm_val,
                p_rt_frz_los_flag                   => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_frz_los_flag,
                p_rt_frz_age_flag                   => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_frz_age_flag,
                p_rt_frz_cmp_lvl_flag               => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_frz_cmp_lvl_flag,
                p_rt_frz_pct_fl_tm_flag             => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_frz_pct_fl_tm_flag,
                p_rt_frz_hrs_wkd_flag               => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_frz_hrs_wkd_flag,
                p_rt_frz_comb_age_and_los_flag      => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_frz_comb_age_and_los_flag,
                p_once_r_cntug_cd                   => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).once_r_cntug_cd,
                p_comp_ref_amt                      => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).comp_ref_amt,
                p_cmbn_age_n_los_val                => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).cmbn_age_n_los_val,
                p_comp_ref_uom                      => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).comp_ref_uom,
                p_age_val                           => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).age_val,
                p_los_val                           => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).los_val,
                p_hrs_wkd_val                       => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).hrs_wkd_val,
                p_hrs_wkd_bndry_perd_cd             => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).hrs_wkd_bndry_perd_cd,
                p_age_uom                           => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).age_uom,
                p_los_uom                           => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).los_uom,
                p_pct_fl_tm_val                     => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).pct_fl_tm_val,
                p_frz_los_flag                      => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).frz_los_flag,
                p_frz_age_flag                      => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).frz_age_flag,
                p_frz_cmp_lvl_flag                  => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).frz_cmp_lvl_flag,
                p_frz_pct_fl_tm_flag                => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).frz_pct_fl_tm_flag,
                p_frz_hrs_wkd_flag                  => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).frz_hrs_wkd_flag,
                p_frz_comb_age_and_los_flag         => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).frz_comb_age_and_los_flag,
                p_wait_perd_cmpltn_dt               => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).wait_perd_cmpltn_dt,
                p_wait_perd_strt_dt                 => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).wait_perd_strt_dt,
                p_object_version_number             => ben_icm_life_events.g_cache_pep_object(l_count).object_version_number,
                p_effective_date                    => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).p_effective_date,
                p_datetrack_mode                    => ben_icm_life_events.g_cache_pep_object(l_count).p_datetrack_mode,
                p_program_application_id            => fnd_global.prog_appl_id,
                p_program_id                        => fnd_global.conc_program_id,
                p_request_id                        => fnd_global.conc_request_id,
                p_program_update_date               => SYSDATE
               );
--
         ELSIF    ben_icm_life_events.g_cache_pep_object (l_count).p_first_elig
               OR ben_icm_life_events.g_cache_pep_object (l_count).p_first_inelig
         --note track inelig flag condition always true for icm
         THEN
--
            IF g_debug
            THEN
               hr_utility.set_location ('Insert Mode for PEP' ||ben_icm_life_events.g_cache_pep_object (l_count).object_version_number, 1234);
            END IF;

--
            INSERT INTO ben_elig_per_f
                        (elig_per_id,
                         effective_start_date,
                         effective_end_date,
                         business_group_id,
                         pl_id,
                         plip_id,
                         ptip_id,
                         pgm_id,
                         ler_id,
                         person_id, per_in_ler_id,
                         dpnt_othr_pl_cvrd_rl_flag,
                         pl_key_ee_flag,
                         pl_hghly_compd_flag,
                         prtn_ovridn_flag,
                         prtn_ovridn_thru_dt,
                         no_mx_prtn_ovrid_thru_flag,
                         prtn_strt_dt,
                         dstr_rstcn_flag,
                         pl_wvd_flag,
                         wait_perd_cmpltn_dt,
                         wait_perd_strt_dt,
                         elig_flag,
                         comp_ref_amt,
                         cmbn_age_n_los_val,
                         comp_ref_uom,
                         age_val,
                         age_uom,
                         los_val,
                         los_uom,
                         hrs_wkd_val,
                         hrs_wkd_bndry_perd_cd,
                         pct_fl_tm_val,
                         frz_los_flag,
                         frz_age_flag,
                         frz_cmp_lvl_flag,
                         frz_pct_fl_tm_flag,
                         frz_hrs_wkd_flag,
                         frz_comb_age_and_los_flag,
                         rt_comp_ref_amt,
                         rt_cmbn_age_n_los_val,
                         rt_comp_ref_uom,
                         rt_age_val,
                         rt_age_uom,
                         rt_los_val,
                         rt_los_uom,
                         rt_hrs_wkd_val,
                         rt_hrs_wkd_bndry_perd_cd,
                         rt_pct_fl_tm_val,
                         rt_frz_los_flag,
                         rt_frz_age_flag,
                         rt_frz_cmp_lvl_flag,
                         rt_frz_pct_fl_tm_flag,
                         rt_frz_hrs_wkd_flag,
                         rt_frz_comb_age_and_los_flag,
                         once_r_cntug_cd,
                         pl_ordr_num,
                         plip_ordr_num,
                         ptip_ordr_num,
                         object_version_number,
                         program_application_id,
                         program_id,
                         request_id,
                         program_update_date
                        )
                 VALUES (ben_icm_life_events.g_cache_pep_object (l_count).elig_per_id,
                         ben_icm_life_events.g_cache_pep_object (l_count).effective_start_date,
                         ben_icm_life_events.g_cache_pep_object (l_count).effective_end_date,
                         ben_icm_life_events.g_cache_pep_object (l_count).business_group_id,
                         ben_icm_life_events.g_cache_pep_object (l_count).pl_id,
                         ben_icm_life_events.g_cache_pep_object (l_count).plip_id,
                         ben_icm_life_events.g_cache_pep_object (l_count).ptip_id,
                         ben_icm_life_events.g_cache_pep_object (l_count).pgm_id,
                         ben_icm_life_events.g_cache_pep_object (l_count).ler_id,
                         p_person_id, NULL,
                         ben_icm_life_events.g_cache_pep_object (l_count).dpnt_othr_pl_cvrd_rl_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).pl_key_ee_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).pl_hghly_compd_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).prtn_ovridn_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).prtn_ovridn_thru_dt,
                         ben_icm_life_events.g_cache_pep_object (l_count).no_mx_prtn_ovrid_thru_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).prtn_strt_dt,
                         ben_icm_life_events.g_cache_pep_object (l_count).dstr_rstcn_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).pl_wvd_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).wait_perd_cmpltn_dt,
                         ben_icm_life_events.g_cache_pep_object (l_count).wait_perd_strt_dt,
                         ben_icm_life_events.g_cache_pep_object (l_count).elig_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).comp_ref_amt,
                         ben_icm_life_events.g_cache_pep_object (l_count).cmbn_age_n_los_val,
                         ben_icm_life_events.g_cache_pep_object (l_count).comp_ref_uom,
                         ben_icm_life_events.g_cache_pep_object (l_count).age_val,
                         ben_icm_life_events.g_cache_pep_object (l_count).age_uom,
                         ben_icm_life_events.g_cache_pep_object (l_count).los_val,
                         ben_icm_life_events.g_cache_pep_object (l_count).los_uom,
                         ben_icm_life_events.g_cache_pep_object (l_count).hrs_wkd_val,
                         ben_icm_life_events.g_cache_pep_object (l_count).hrs_wkd_bndry_perd_cd,
                         ben_icm_life_events.g_cache_pep_object (l_count).pct_fl_tm_val,
                         ben_icm_life_events.g_cache_pep_object (l_count).frz_los_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).frz_age_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).frz_cmp_lvl_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).frz_pct_fl_tm_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).frz_hrs_wkd_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).frz_comb_age_and_los_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).rt_comp_ref_amt,
                         ben_icm_life_events.g_cache_pep_object (l_count).rt_cmbn_age_n_los_val,
                         ben_icm_life_events.g_cache_pep_object (l_count).rt_comp_ref_uom,
                         ben_icm_life_events.g_cache_pep_object (l_count).rt_age_val,
                         ben_icm_life_events.g_cache_pep_object (l_count).rt_age_uom,
                         ben_icm_life_events.g_cache_pep_object (l_count).rt_los_val,
                         ben_icm_life_events.g_cache_pep_object (l_count).rt_los_uom,
                         ben_icm_life_events.g_cache_pep_object (l_count).rt_hrs_wkd_val,
                         ben_icm_life_events.g_cache_pep_object (l_count).rt_hrs_wkd_bndry_perd_cd,
                         ben_icm_life_events.g_cache_pep_object (l_count).rt_pct_fl_tm_val,
                         ben_icm_life_events.g_cache_pep_object (l_count).rt_frz_los_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).rt_frz_age_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).rt_frz_cmp_lvl_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).rt_frz_pct_fl_tm_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).rt_frz_hrs_wkd_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).rt_frz_comb_age_and_los_flag,
                         ben_icm_life_events.g_cache_pep_object (l_count).once_r_cntug_cd,
                         ben_icm_life_events.g_cache_pep_object (l_count).pl_ordr_num,
                         ben_icm_life_events.g_cache_pep_object (l_count).plip_ordr_num,
                         ben_icm_life_events.g_cache_pep_object (l_count).ptip_ordr_num,
			 ben_icm_life_events.g_cache_pep_object (l_count).object_version_number,
                         ben_icm_life_events.g_cache_pep_object (l_count).program_application_id,
                         ben_icm_life_events.g_cache_pep_object (l_count).program_id,
                         ben_icm_life_events.g_cache_pep_object (l_count).request_id,
                         ben_icm_life_events.g_cache_pep_object (l_count).program_update_date
                        );
         --
         --
         ELSIF ben_icm_life_events.g_cache_pep_object (l_count).p_newly_inelig
         THEN
--
            IF g_debug
            THEN
               hr_utility.set_location ('Newly Ineligible', 123);
            END IF;

            --
            ben_eligible_person_perf_api.update_perf_eligible_person
               (p_validate                          => FALSE,
                p_elig_per_id                       => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).elig_per_id,
                p_per_in_ler_id                     => NULL,
                p_effective_start_date              => l_effective_start_date,
                p_effective_end_date                => l_effective_end_date,
                p_elig_flag                         => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).elig_flag,
                p_prtn_strt_dt                      => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).prtn_strt_dt,
                p_rt_comp_ref_amt                   => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_comp_ref_amt,
                p_rt_cmbn_age_n_los_val             => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_cmbn_age_n_los_val,
                p_rt_comp_ref_uom                   => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_comp_ref_uom,
                p_rt_age_val                        => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_age_val,
                p_rt_los_val                        => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_los_val,
                p_rt_hrs_wkd_val                    => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_hrs_wkd_val,
                p_rt_hrs_wkd_bndry_perd_cd          => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_hrs_wkd_bndry_perd_cd,
                p_rt_age_uom                        => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_age_uom,
                p_rt_los_uom                        => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_los_uom,
                p_rt_pct_fl_tm_val                  => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_pct_fl_tm_val,
                p_rt_frz_los_flag                   => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_frz_los_flag,
                p_rt_frz_age_flag                   => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_frz_age_flag,
                p_rt_frz_cmp_lvl_flag               => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_frz_cmp_lvl_flag,
                p_rt_frz_pct_fl_tm_flag             => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_frz_pct_fl_tm_flag,
                p_rt_frz_hrs_wkd_flag               => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_frz_hrs_wkd_flag,
                p_rt_frz_comb_age_and_los_flag      => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_frz_comb_age_and_los_flag,
                p_once_r_cntug_cd                   => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).once_r_cntug_cd,
                p_comp_ref_amt                      => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).comp_ref_amt,
                p_cmbn_age_n_los_val                => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).cmbn_age_n_los_val,
                p_comp_ref_uom                      => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).comp_ref_uom,
                p_age_val                           => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).age_val,
                p_los_val                           => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).los_val,
                p_hrs_wkd_val                       => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).hrs_wkd_val,
                p_hrs_wkd_bndry_perd_cd             => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).hrs_wkd_bndry_perd_cd,
                p_age_uom                           => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).age_uom,
                p_los_uom                           => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).los_uom,
                p_pct_fl_tm_val                     => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).pct_fl_tm_val,
                p_frz_los_flag                      => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).frz_los_flag,
                p_frz_age_flag                      => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).frz_age_flag,
                p_frz_cmp_lvl_flag                  => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).frz_cmp_lvl_flag,
                p_frz_pct_fl_tm_flag                => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).frz_pct_fl_tm_flag,
                p_frz_hrs_wkd_flag                  => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).frz_hrs_wkd_flag,
                p_frz_comb_age_and_los_flag         => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).frz_comb_age_and_los_flag,
                p_wait_perd_cmpltn_dt               => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).wait_perd_cmpltn_dt,
                p_wait_perd_strt_dt                 => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).wait_perd_strt_dt,
                p_object_version_number             => ben_icm_life_events.g_cache_pep_object(l_count).object_version_number,
                p_effective_date                    => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).p_effective_date,
                p_datetrack_mode                    => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).p_datetrack_mode,
                p_program_application_id            => fnd_global.prog_appl_id,
                p_program_id                        => fnd_global.conc_program_id,
                p_request_id                        => fnd_global.conc_request_id,
                p_program_update_date               => SYSDATE
               );
         --
         ELSIF ben_icm_life_events.g_cache_pep_object (l_count).p_newly_elig
                                                --ie prev inelig but since for
         --icm track flag is always 'Y' so we have record just need to update it
         THEN
            --
            IF g_debug
            THEN
               hr_utility.set_location ('Newly Eligible', 121);
            END IF;

            --
            ben_eligible_person_perf_api.update_perf_eligible_person
               (p_validate                          => FALSE,
                p_elig_per_id                       => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).elig_per_id,
                p_per_in_ler_id                     => NULL,
                p_effective_start_date              => l_effective_start_date,
                p_effective_end_date                => l_effective_end_date,
                p_elig_flag                         => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).elig_flag,
                p_prtn_strt_dt                      => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).prtn_strt_dt,
                p_rt_comp_ref_amt                   => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_comp_ref_amt,
                p_rt_cmbn_age_n_los_val             => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_cmbn_age_n_los_val,
                p_rt_comp_ref_uom                   => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_comp_ref_uom,
                p_rt_age_val                        => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_age_val,
                p_rt_los_val                        => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_los_val,
                p_rt_hrs_wkd_val                    => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_hrs_wkd_val,
                p_rt_hrs_wkd_bndry_perd_cd          => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_hrs_wkd_bndry_perd_cd,
                p_rt_age_uom                        => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_age_uom,
                p_rt_los_uom                        => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_los_uom,
                p_rt_pct_fl_tm_val                  => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_pct_fl_tm_val,
                p_rt_frz_los_flag                   => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_frz_los_flag,
                p_rt_frz_age_flag                   => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_frz_age_flag,
                p_rt_frz_cmp_lvl_flag               => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_frz_cmp_lvl_flag,
                p_rt_frz_pct_fl_tm_flag             => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_frz_pct_fl_tm_flag,
                p_rt_frz_hrs_wkd_flag               => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_frz_hrs_wkd_flag,
                p_rt_frz_comb_age_and_los_flag      => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).rt_frz_comb_age_and_los_flag,
                p_once_r_cntug_cd                   => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).once_r_cntug_cd,
                p_comp_ref_amt                      => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).comp_ref_amt,
                p_cmbn_age_n_los_val                => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).cmbn_age_n_los_val,
                p_comp_ref_uom                      => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).comp_ref_uom,
                p_age_val                           => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).age_val,
                p_los_val                           => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).los_val,
                p_hrs_wkd_val                       => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).hrs_wkd_val,
                p_hrs_wkd_bndry_perd_cd             => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).hrs_wkd_bndry_perd_cd,
                p_age_uom                           => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).age_uom,
                p_los_uom                           => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).los_uom,
                p_pct_fl_tm_val                     => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).pct_fl_tm_val,
                p_frz_los_flag                      => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).frz_los_flag,
                p_frz_age_flag                      => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).frz_age_flag,
                p_frz_cmp_lvl_flag                  => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).frz_cmp_lvl_flag,
                p_frz_pct_fl_tm_flag                => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).frz_pct_fl_tm_flag,
                p_frz_hrs_wkd_flag                  => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).frz_hrs_wkd_flag,
                p_frz_comb_age_and_los_flag         => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).frz_comb_age_and_los_flag,
                p_wait_perd_cmpltn_dt               => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).wait_perd_cmpltn_dt,
                p_wait_perd_strt_dt                 => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).wait_perd_strt_dt,
                p_object_version_number             => ben_icm_life_events.g_cache_pep_object(l_count).object_version_number,
                p_effective_date                    => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).p_effective_date,
                p_datetrack_mode                    => ben_icm_life_events.g_cache_pep_object
                                                                      (l_count).p_datetrack_mode,
                p_program_application_id            => fnd_global.prog_appl_id,
                p_program_id                        => fnd_global.conc_program_id,
                p_request_id                        => fnd_global.conc_request_id,
                p_program_update_date               => SYSDATE
               );
--
         END IF;

         --
         l_count := l_count + 1;
         l_pep_count := l_pep_count - 1;
      --
      END LOOP;

      --
      WHILE l_count2 > 0
      LOOP
         --
/*         OPEN c_trk_inelig_per_flag
                     (ben_icm_life_events.g_cache_epo_object (l_count2).opt_id
                     );

         FETCH c_trk_inelig_per_flag
          INTO l_trk_inelig_per_flag;

         CLOSE c_trk_inelig_per_flag;

	OPEN c_epo_ovn
                 (ben_icm_life_events.g_cache_epo_object (v_count).elig_per_opt_id
                 );

         FETCH c_epo_ovn
          INTO l_epo_ovn;

         CLOSE c_epo_ovn;*/
-- Now for ICD Option also we ll make trk_inelig_per_flag 'Y' so need of this cursor.
         --
         IF    --(ben_icm_life_events.g_cache_epo_object (v_count).p_still_inelig  OR
	        ben_icm_life_events.g_cache_epo_object (v_count).p_still_elig
	    AND ben_icm_life_events.g_cache_epo_object(v_count).p_datetrack_mode is not null
         THEN
--
            IF g_debug
            THEN
               hr_utility.set_location ('Still ELig or Still Inelig'|| ben_icm_life_events.g_cache_epo_object(v_count).elig_per_opt_id, 125);
            END IF;
 --
 ben_eligible_person_perf_api.update_perf_elig_person_option
               (p_validate                          => FALSE,
                p_elig_per_opt_id                   => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).elig_per_opt_id,
                p_elig_per_id                       => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).elig_per_id,
                p_effective_start_date              => l_effective_start_date,
                p_effective_end_date                => l_effective_end_date,
                p_prtn_ovridn_flag                  => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).prtn_ovridn_flag,
                p_prtn_ovridn_thru_dt               => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).prtn_ovridn_thru_dt,
                p_no_mx_prtn_ovrid_thru_flag        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).no_mx_prtn_ovrid_thru_flag,
                p_elig_flag                         => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).elig_flag,
                p_prtn_strt_dt                      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).prtn_strt_dt,
                p_prtn_end_dt                       => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).prtn_end_dt,
                p_wait_perd_cmpltn_date             => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).wait_perd_cmpltn_date,
                p_wait_perd_strt_dt                 => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).wait_perd_strt_dt
--  ,p_prtn_ovridn_rsn_cd        =>ben_icm_life_events.g_cache_epo_object(v_count).prtn_ovridn_rsn_cd
            ,
                p_pct_fl_tm_val                     => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).pct_fl_tm_val,
                p_opt_id                            => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).opt_id,
                p_per_in_ler_id                     => NULL,
                p_rt_comp_ref_amt                   => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_comp_ref_amt,
                p_rt_cmbn_age_n_los_val             => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_cmbn_age_n_los_val,
                p_rt_comp_ref_uom                   => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_comp_ref_uom,
                p_rt_age_val                        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_age_val,
                p_rt_los_val                        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_los_val,
                p_rt_hrs_wkd_val                    => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_hrs_wkd_val,
                p_rt_hrs_wkd_bndry_perd_cd          => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_hrs_wkd_bndry_perd_cd,
                p_rt_age_uom                        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_age_uom,
                p_rt_los_uom                        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_los_uom,
                p_rt_pct_fl_tm_val                  => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_pct_fl_tm_val,
                p_rt_frz_los_flag                   => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_frz_los_flag,
                p_rt_frz_age_flag                   => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_frz_age_flag,
                p_rt_frz_cmp_lvl_flag               => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_frz_cmp_lvl_flag,
                p_rt_frz_pct_fl_tm_flag             => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_frz_pct_fl_tm_flag,
                p_rt_frz_hrs_wkd_flag               => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_frz_hrs_wkd_flag,
                p_rt_frz_comb_age_and_los_flag      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_frz_comb_age_and_los_flag,
                p_comp_ref_amt                      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).comp_ref_amt,
                p_cmbn_age_n_los_val                => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).cmbn_age_n_los_val,
                p_comp_ref_uom                      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).comp_ref_uom,
                p_age_val                           => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).age_val,
                p_los_val                           => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).los_val,
                p_hrs_wkd_val                       => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).hrs_wkd_val,
                p_hrs_wkd_bndry_perd_cd             => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).hrs_wkd_bndry_perd_cd,
                p_age_uom                           => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).age_uom,
                p_los_uom                           => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).los_uom,
                p_frz_los_flag                      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).frz_los_flag,
                p_frz_age_flag                      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).frz_age_flag,
                p_frz_cmp_lvl_flag                  => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).frz_cmp_lvl_flag,
                p_frz_pct_fl_tm_flag                => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).frz_pct_fl_tm_flag,
                p_frz_hrs_wkd_flag                  => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).frz_hrs_wkd_flag,
                p_frz_comb_age_and_los_flag         => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).frz_comb_age_and_los_flag
--  ,p_ovrid_svc_dt              =>ben_icm_life_events.g_cache_epo_object(v_count).ovrid_svc_dt
            ,
                p_inelg_rsn_cd                      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).inelg_rsn_cd,
                p_once_r_cntug_cd                   => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).once_r_cntug_cd,
                p_oipl_ordr_num                     => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).oipl_ordr_num,
                p_business_group_id                 => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).business_group_id,
                p_request_id                        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).request_id,
                p_program_application_id            => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).program_application_id,
                p_program_id                        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).program_id,
                p_program_update_date               => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).program_update_date,
                p_object_version_number             => ben_icm_life_events.g_cache_epo_object(v_count).object_version_number,
                p_effective_date                    => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).p_effective_date,
                p_datetrack_mode                    => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).p_datetrack_mode
               );
  --
         ELSIF    ben_icm_life_events.g_cache_epo_object (v_count).p_first_elig
               OR     ben_icm_life_events.g_cache_epo_object (v_count).p_first_inelig
                  -- AND l_trk_inelig_per_flag = 'Y'
         THEN
            IF g_debug
            THEN
            hr_utility.set_location ('Insert Mode for EPO' || ben_icm_life_events.g_cache_epo_object (v_count).elig_per_opt_id, 1234);
            END IF;

            INSERT INTO ben_elig_per_opt_f
                        (elig_per_opt_id,
                         elig_per_id,
                         effective_start_date,
                         effective_end_date,
                         prtn_ovridn_flag,
                         prtn_ovridn_thru_dt,
                         no_mx_prtn_ovrid_thru_flag,
                         elig_flag,
                         prtn_strt_dt,
                         pct_fl_tm_val,
                         opt_id,
                         business_group_id,
                         request_id,
                         program_application_id,
                         program_id,
                         program_update_date,
                         age_uom,
                         age_val,
                         cmbn_age_n_los_val,
                         comp_ref_amt,
                         comp_ref_uom,
                         frz_age_flag,
                         frz_cmp_lvl_flag,
                         frz_comb_age_and_los_flag,
                         frz_hrs_wkd_flag,
                         frz_los_flag,
                         frz_pct_fl_tm_flag,
                         hrs_wkd_bndry_perd_cd,
                         hrs_wkd_val,
                         los_uom,
                         los_val,
                         rt_comp_ref_amt,
                         rt_cmbn_age_n_los_val,
                         rt_comp_ref_uom,
                         rt_age_val,
                         rt_los_val,
                         rt_hrs_wkd_val,
                         rt_hrs_wkd_bndry_perd_cd,
                         rt_age_uom,
                         rt_los_uom,
                         rt_pct_fl_tm_val,
                         rt_frz_los_flag,
                         rt_frz_age_flag,
                         rt_frz_cmp_lvl_flag,
                         rt_frz_pct_fl_tm_flag,
                         rt_frz_hrs_wkd_flag,
                         rt_frz_comb_age_and_los_flag,
                         once_r_cntug_cd,
                         wait_perd_cmpltn_dt,
                         per_in_ler_id,
                         wait_perd_strt_dt,
                         wait_perd_cmpltn_date,
                         object_version_number
                        )
                 VALUES (ben_icm_life_events.g_cache_epo_object (v_count).elig_per_opt_id,
                         ben_icm_life_events.g_cache_epo_object (v_count).elig_per_id,
                         ben_icm_life_events.g_cache_epo_object (v_count).effective_start_date,
                         ben_icm_life_events.g_cache_epo_object (v_count).effective_end_date,
                         ben_icm_life_events.g_cache_epo_object (v_count).prtn_ovridn_flag,
                         ben_icm_life_events.g_cache_epo_object (v_count).prtn_ovridn_thru_dt,
                         ben_icm_life_events.g_cache_epo_object (v_count).no_mx_prtn_ovrid_thru_flag,
                         ben_icm_life_events.g_cache_epo_object (v_count).elig_flag,
                         ben_icm_life_events.g_cache_epo_object (v_count).prtn_strt_dt,
                         ben_icm_life_events.g_cache_epo_object (v_count).pct_fl_tm_val,
                         ben_icm_life_events.g_cache_epo_object (v_count).opt_id,
                         ben_icm_life_events.g_cache_epo_object (v_count).business_group_id,
                         ben_icm_life_events.g_cache_epo_object (v_count).request_id,
                         ben_icm_life_events.g_cache_epo_object (v_count).program_application_id,
                         ben_icm_life_events.g_cache_epo_object (v_count).program_id,
                         ben_icm_life_events.g_cache_epo_object (v_count).program_update_date,
                         ben_icm_life_events.g_cache_epo_object (v_count).age_uom,
                         ben_icm_life_events.g_cache_epo_object (v_count).age_val,
                         ben_icm_life_events.g_cache_epo_object (v_count).cmbn_age_n_los_val,
                         ben_icm_life_events.g_cache_epo_object (v_count).comp_ref_amt,
                         ben_icm_life_events.g_cache_epo_object (v_count).comp_ref_uom,
                         ben_icm_life_events.g_cache_epo_object (v_count).frz_age_flag,
                         ben_icm_life_events.g_cache_epo_object (v_count).frz_cmp_lvl_flag,
                         ben_icm_life_events.g_cache_epo_object (v_count).frz_comb_age_and_los_flag,
                         ben_icm_life_events.g_cache_epo_object (v_count).frz_hrs_wkd_flag,
                         ben_icm_life_events.g_cache_epo_object (v_count).frz_los_flag,
                         ben_icm_life_events.g_cache_epo_object (v_count).frz_pct_fl_tm_flag,
                         ben_icm_life_events.g_cache_epo_object (v_count).hrs_wkd_bndry_perd_cd,
                         ben_icm_life_events.g_cache_epo_object (v_count).hrs_wkd_val,
                         ben_icm_life_events.g_cache_epo_object (v_count).los_uom,
                         ben_icm_life_events.g_cache_epo_object (v_count).los_val,
                         ben_icm_life_events.g_cache_epo_object (v_count).rt_comp_ref_amt,
                         ben_icm_life_events.g_cache_epo_object (v_count).rt_cmbn_age_n_los_val,
                         ben_icm_life_events.g_cache_epo_object (v_count).rt_comp_ref_uom,
                         ben_icm_life_events.g_cache_epo_object (v_count).rt_age_val,
                         ben_icm_life_events.g_cache_epo_object (v_count).rt_los_val,
                         ben_icm_life_events.g_cache_epo_object (v_count).rt_hrs_wkd_val,
                         ben_icm_life_events.g_cache_epo_object (v_count).rt_hrs_wkd_bndry_perd_cd,
                         ben_icm_life_events.g_cache_epo_object (v_count).rt_age_uom,
                         ben_icm_life_events.g_cache_epo_object (v_count).rt_los_uom,
                         ben_icm_life_events.g_cache_epo_object (v_count).rt_pct_fl_tm_val,
                         ben_icm_life_events.g_cache_epo_object (v_count).rt_frz_los_flag,
                         ben_icm_life_events.g_cache_epo_object (v_count).rt_frz_age_flag,
                         ben_icm_life_events.g_cache_epo_object (v_count).rt_frz_cmp_lvl_flag,
                         ben_icm_life_events.g_cache_epo_object (v_count).rt_frz_pct_fl_tm_flag,
                         ben_icm_life_events.g_cache_epo_object (v_count).rt_frz_hrs_wkd_flag,
                         ben_icm_life_events.g_cache_epo_object (v_count).rt_frz_comb_age_and_los_flag,
                         ben_icm_life_events.g_cache_epo_object (v_count).once_r_cntug_cd,
                         ben_icm_life_events.g_cache_epo_object (v_count).wait_perd_cmpltn_dt,
                         NULL,
                         ben_icm_life_events.g_cache_epo_object (v_count).wait_perd_strt_dt,
                         ben_icm_life_events.g_cache_epo_object (v_count).wait_perd_cmpltn_date,
			 ben_icm_life_events.g_cache_epo_object (v_count).object_version_number
                        );
--
         ELSIF ben_icm_life_events.g_cache_epo_object (v_count).p_newly_inelig
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('Newly Ineligible', 125);
            END IF;

--
            ben_eligible_person_perf_api.update_perf_elig_person_option
               (p_validate                          => FALSE,
                p_elig_per_opt_id                   => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).elig_per_opt_id,
                p_elig_per_id                       => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).elig_per_id,
                p_effective_start_date              => l_effective_start_date,
                p_effective_end_date                => l_effective_end_date,
                p_prtn_ovridn_flag                  => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).prtn_ovridn_flag,
                p_prtn_ovridn_thru_dt               => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).prtn_ovridn_thru_dt,
                p_no_mx_prtn_ovrid_thru_flag        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).no_mx_prtn_ovrid_thru_flag,
                p_elig_flag                         => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).elig_flag,
                p_prtn_strt_dt                      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).prtn_strt_dt,
                p_prtn_end_dt                       => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).prtn_end_dt,
                p_wait_perd_cmpltn_date             => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).wait_perd_cmpltn_date,
                p_wait_perd_strt_dt                 => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).wait_perd_strt_dt
--  ,p_prtn_ovridn_rsn_cd        =>ben_icm_life_events.g_cache_epo_object(v_count).prtn_ovridn_rsn_cd
            ,
                p_pct_fl_tm_val                     => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).pct_fl_tm_val,
                p_opt_id                            => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).opt_id,
                p_per_in_ler_id                     => NULL,
                p_rt_comp_ref_amt                   => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_comp_ref_amt,
                p_rt_cmbn_age_n_los_val             => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_cmbn_age_n_los_val,
                p_rt_comp_ref_uom                   => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_comp_ref_uom,
                p_rt_age_val                        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_age_val,
                p_rt_los_val                        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_los_val,
                p_rt_hrs_wkd_val                    => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_hrs_wkd_val,
                p_rt_hrs_wkd_bndry_perd_cd          => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_hrs_wkd_bndry_perd_cd,
                p_rt_age_uom                        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_age_uom,
                p_rt_los_uom                        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_los_uom,
                p_rt_pct_fl_tm_val                  => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_pct_fl_tm_val,
                p_rt_frz_los_flag                   => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_frz_los_flag,
                p_rt_frz_age_flag                   => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_frz_age_flag,
                p_rt_frz_cmp_lvl_flag               => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_frz_cmp_lvl_flag,
                p_rt_frz_pct_fl_tm_flag             => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_frz_pct_fl_tm_flag,
                p_rt_frz_hrs_wkd_flag               => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_frz_hrs_wkd_flag,
                p_rt_frz_comb_age_and_los_flag      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_frz_comb_age_and_los_flag,
                p_comp_ref_amt                      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).comp_ref_amt,
                p_cmbn_age_n_los_val                => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).cmbn_age_n_los_val,
                p_comp_ref_uom                      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).comp_ref_uom,
                p_age_val                           => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).age_val,
                p_los_val                           => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).los_val,
                p_hrs_wkd_val                       => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).hrs_wkd_val,
                p_hrs_wkd_bndry_perd_cd             => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).hrs_wkd_bndry_perd_cd,
                p_age_uom                           => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).age_uom,
                p_los_uom                           => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).los_uom,
                p_frz_los_flag                      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).frz_los_flag,
                p_frz_age_flag                      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).frz_age_flag,
                p_frz_cmp_lvl_flag                  => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).frz_cmp_lvl_flag,
                p_frz_pct_fl_tm_flag                => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).frz_pct_fl_tm_flag,
                p_frz_hrs_wkd_flag                  => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).frz_hrs_wkd_flag,
                p_frz_comb_age_and_los_flag         => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).frz_comb_age_and_los_flag
--  ,p_ovrid_svc_dt              =>ben_icm_life_events.g_cache_epo_object(v_count).ovrid_svc_dt
            ,
                p_inelg_rsn_cd                      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).inelg_rsn_cd,
                p_once_r_cntug_cd                   => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).once_r_cntug_cd,
                p_oipl_ordr_num                     => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).oipl_ordr_num,
                p_business_group_id                 => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).business_group_id,
                p_request_id                        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).request_id,
                p_program_application_id            => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).program_application_id,
                p_program_id                        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).program_id,
                p_program_update_date               => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).program_update_date,
                p_object_version_number             => ben_icm_life_events.g_cache_epo_object(v_count).object_version_number,
                p_effective_date                    => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).p_effective_date,
                p_datetrack_mode                    => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).p_datetrack_mode
               );
--
         ELSIF ben_icm_life_events.g_cache_epo_object (v_count).p_newly_elig
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('Newly Eligible', 125);
            END IF;

            --
/*            IF l_trk_inelig_per_flag <> 'Y'
            THEN                              --ie no record was there in epo
               --
               INSERT INTO ben_elig_per_opt_f
                           (elig_per_opt_id,
                            elig_per_id,
                            effective_start_date,
                            effective_end_date,
                            prtn_ovridn_flag,
                            prtn_ovridn_thru_dt,
                            no_mx_prtn_ovrid_thru_flag,
                            elig_flag,
                            prtn_strt_dt,
                            pct_fl_tm_val,
                            opt_id,
                            business_group_id,
                            request_id,
                            program_application_id,
                            program_id,
                            program_update_date,
                            age_uom,
                            age_val,
                            cmbn_age_n_los_val,
                            comp_ref_amt,
                            comp_ref_uom,
                            frz_age_flag,
                            frz_cmp_lvl_flag,
                            frz_comb_age_and_los_flag,
                            frz_hrs_wkd_flag,
                            frz_los_flag,
                            frz_pct_fl_tm_flag,
                            hrs_wkd_bndry_perd_cd,
                            hrs_wkd_val,
                            los_uom,
                            los_val,
                            rt_comp_ref_amt,
                            rt_cmbn_age_n_los_val,
                            rt_comp_ref_uom,
                            rt_age_val,
                            rt_los_val,
                            rt_hrs_wkd_val,
                            rt_hrs_wkd_bndry_perd_cd,
                            rt_age_uom,
                            rt_los_uom,
                            rt_pct_fl_tm_val,
                            rt_frz_los_flag,
                            rt_frz_age_flag,
                            rt_frz_cmp_lvl_flag,
                            rt_frz_pct_fl_tm_flag,
                            rt_frz_hrs_wkd_flag,
                            rt_frz_comb_age_and_los_flag,
                            once_r_cntug_cd,
                            wait_perd_cmpltn_dt,
                            per_in_ler_id,
                            wait_perd_strt_dt,
                            wait_perd_cmpltn_date,
                            object_version_number
                           )
                    VALUES (ben_icm_life_events.g_cache_epo_object (v_count).elig_per_opt_id,
                            ben_icm_life_events.g_cache_epo_object (v_count).elig_per_id,
                            ben_icm_life_events.g_cache_epo_object (v_count).effective_start_date,
                            ben_icm_life_events.g_cache_epo_object (v_count).effective_end_date,
                            ben_icm_life_events.g_cache_epo_object (v_count).prtn_ovridn_flag,
                            ben_icm_life_events.g_cache_epo_object (v_count).prtn_ovridn_thru_dt,
                            ben_icm_life_events.g_cache_epo_object (v_count).no_mx_prtn_ovrid_thru_flag,
                            ben_icm_life_events.g_cache_epo_object (v_count).elig_flag,
                            ben_icm_life_events.g_cache_epo_object (v_count).prtn_strt_dt,
                            ben_icm_life_events.g_cache_epo_object (v_count).pct_fl_tm_val,
                            ben_icm_life_events.g_cache_epo_object (v_count).opt_id,
                            ben_icm_life_events.g_cache_epo_object (v_count).business_group_id,
                            ben_icm_life_events.g_cache_epo_object (v_count).request_id,
                            ben_icm_life_events.g_cache_epo_object (v_count).program_application_id,
                            ben_icm_life_events.g_cache_epo_object (v_count).program_id,
                            ben_icm_life_events.g_cache_epo_object (v_count).program_update_date,
                            ben_icm_life_events.g_cache_epo_object (v_count).age_uom,
                            ben_icm_life_events.g_cache_epo_object (v_count).age_val,
                            ben_icm_life_events.g_cache_epo_object (v_count).cmbn_age_n_los_val,
                            ben_icm_life_events.g_cache_epo_object (v_count).comp_ref_amt,
                            ben_icm_life_events.g_cache_epo_object (v_count).comp_ref_uom,
                            ben_icm_life_events.g_cache_epo_object (v_count).frz_age_flag,
                            ben_icm_life_events.g_cache_epo_object (v_count).frz_cmp_lvl_flag,
                            ben_icm_life_events.g_cache_epo_object (v_count).frz_comb_age_and_los_flag,
                            ben_icm_life_events.g_cache_epo_object (v_count).frz_hrs_wkd_flag,
                            ben_icm_life_events.g_cache_epo_object (v_count).frz_los_flag,
                            ben_icm_life_events.g_cache_epo_object (v_count).frz_pct_fl_tm_flag,
                            ben_icm_life_events.g_cache_epo_object (v_count).hrs_wkd_bndry_perd_cd,
                            ben_icm_life_events.g_cache_epo_object (v_count).hrs_wkd_val,
                            ben_icm_life_events.g_cache_epo_object (v_count).los_uom,
                            ben_icm_life_events.g_cache_epo_object (v_count).los_val,
                            ben_icm_life_events.g_cache_epo_object (v_count).rt_comp_ref_amt,
                            ben_icm_life_events.g_cache_epo_object (v_count).rt_cmbn_age_n_los_val,
                            ben_icm_life_events.g_cache_epo_object (v_count).rt_comp_ref_uom,
                            ben_icm_life_events.g_cache_epo_object (v_count).rt_age_val,
                            ben_icm_life_events.g_cache_epo_object (v_count).rt_los_val,
                            ben_icm_life_events.g_cache_epo_object (v_count).rt_hrs_wkd_val,
                            ben_icm_life_events.g_cache_epo_object (v_count).rt_hrs_wkd_bndry_perd_cd,
                            ben_icm_life_events.g_cache_epo_object (v_count).rt_age_uom,
                            ben_icm_life_events.g_cache_epo_object (v_count).rt_los_uom,
                            ben_icm_life_events.g_cache_epo_object (v_count).rt_pct_fl_tm_val,
                            ben_icm_life_events.g_cache_epo_object (v_count).rt_frz_los_flag,
                            ben_icm_life_events.g_cache_epo_object (v_count).rt_frz_age_flag,
                            ben_icm_life_events.g_cache_epo_object (v_count).rt_frz_cmp_lvl_flag,
                            ben_icm_life_events.g_cache_epo_object (v_count).rt_frz_pct_fl_tm_flag,
                            ben_icm_life_events.g_cache_epo_object (v_count).rt_frz_hrs_wkd_flag,
                            ben_icm_life_events.g_cache_epo_object (v_count).rt_frz_comb_age_and_los_flag,
                            ben_icm_life_events.g_cache_epo_object (v_count).once_r_cntug_cd,
                            ben_icm_life_events.g_cache_epo_object (v_count).wait_perd_cmpltn_dt,
                            NULL,
                            ben_icm_life_events.g_cache_epo_object (v_count).wait_perd_strt_dt,
                            ben_icm_life_events.g_cache_epo_object (v_count).wait_perd_cmpltn_date,
                            ben_icm_life_events.g_cache_epo_object (v_count).object_version_number
                           );
            ELSE*/
            -- ie already record is there with flag = 'N' so need to update it
               --
            ben_eligible_person_perf_api.update_perf_elig_person_option
               (p_validate                          => FALSE,
                p_elig_per_opt_id                   => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).elig_per_opt_id,
                p_elig_per_id                       => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).elig_per_id,
                p_effective_start_date              => l_effective_start_date,
                p_effective_end_date                => l_effective_end_date,
                p_prtn_ovridn_flag                  => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).prtn_ovridn_flag,
                p_prtn_ovridn_thru_dt               => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).prtn_ovridn_thru_dt,
                p_no_mx_prtn_ovrid_thru_flag        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).no_mx_prtn_ovrid_thru_flag,
                p_elig_flag                         => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).elig_flag,
                p_prtn_strt_dt                      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).prtn_strt_dt,
                p_prtn_end_dt                       => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).prtn_end_dt,
                p_wait_perd_cmpltn_date             => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).wait_perd_cmpltn_date,
                p_wait_perd_strt_dt                 => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).wait_perd_strt_dt
--  ,p_prtn_ovridn_rsn_cd        =>ben_icm_life_events.g_cache_epo_object(v_count).prtn_ovridn_rsn_cd
            ,
                p_pct_fl_tm_val                     => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).pct_fl_tm_val,
                p_opt_id                            => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).opt_id,
                p_per_in_ler_id                     => NULL,
                p_rt_comp_ref_amt                   => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_comp_ref_amt,
                p_rt_cmbn_age_n_los_val             => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_cmbn_age_n_los_val,
                p_rt_comp_ref_uom                   => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_comp_ref_uom,
                p_rt_age_val                        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_age_val,
                p_rt_los_val                        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_los_val,
                p_rt_hrs_wkd_val                    => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_hrs_wkd_val,
                p_rt_hrs_wkd_bndry_perd_cd          => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_hrs_wkd_bndry_perd_cd,
                p_rt_age_uom                        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_age_uom,
                p_rt_los_uom                        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_los_uom,
                p_rt_pct_fl_tm_val                  => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_pct_fl_tm_val,
                p_rt_frz_los_flag                   => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_frz_los_flag,
                p_rt_frz_age_flag                   => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_frz_age_flag,
                p_rt_frz_cmp_lvl_flag               => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_frz_cmp_lvl_flag,
                p_rt_frz_pct_fl_tm_flag             => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_frz_pct_fl_tm_flag,
                p_rt_frz_hrs_wkd_flag               => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_frz_hrs_wkd_flag,
                p_rt_frz_comb_age_and_los_flag      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).rt_frz_comb_age_and_los_flag,
                p_comp_ref_amt                      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).comp_ref_amt,
                p_cmbn_age_n_los_val                => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).cmbn_age_n_los_val,
                p_comp_ref_uom                      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).comp_ref_uom,
                p_age_val                           => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).age_val,
                p_los_val                           => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).los_val,
                p_hrs_wkd_val                       => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).hrs_wkd_val,
                p_hrs_wkd_bndry_perd_cd             => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).hrs_wkd_bndry_perd_cd,
                p_age_uom                           => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).age_uom,
                p_los_uom                           => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).los_uom,
                p_frz_los_flag                      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).frz_los_flag,
                p_frz_age_flag                      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).frz_age_flag,
                p_frz_cmp_lvl_flag                  => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).frz_cmp_lvl_flag,
                p_frz_pct_fl_tm_flag                => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).frz_pct_fl_tm_flag,
                p_frz_hrs_wkd_flag                  => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).frz_hrs_wkd_flag,
                p_frz_comb_age_and_los_flag         => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).frz_comb_age_and_los_flag,
                p_inelg_rsn_cd                      => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).inelg_rsn_cd,
                p_once_r_cntug_cd                   => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).once_r_cntug_cd,
                p_oipl_ordr_num                     => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).oipl_ordr_num,
                p_business_group_id                 => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).business_group_id,
                p_request_id                        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).request_id,
                p_program_application_id            => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).program_application_id,
                p_program_id                        => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).program_id,
                p_program_update_date               => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).program_update_date,
                p_object_version_number             => ben_icm_life_events.g_cache_epo_object(v_count).object_version_number,
                p_effective_date                    => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).p_effective_date,
                p_datetrack_mode                    => ben_icm_life_events.g_cache_epo_object
                                                                      (v_count).p_datetrack_mode
               );
            --
--            END IF;
         END IF;

         v_count := v_count + 1;
         l_count2 := l_count2 - 1;

         IF g_debug
         THEN
            hr_utility.set_location ('l_count2' || l_count2, 12);
         END IF;
      END LOOP;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving CREATE_PEP_EPO_REC', 123);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('SQLERRM' || substr(SQLERRM,1,30), 123);
            hr_utility.set_location ('SQLERRM' || substr(SQLERRM,31,60), 1234);
         END IF;
         RAISE;
         ROLLBACK TO elig_per_cache_savepont;
         ben_icm_life_events.g_cache_pep_object.DELETE;
         ben_icm_life_events.g_cache_epo_object.DELETE;
         ben_determine_activity_base_rt.l_icd_chc_rates_tab.DELETE;
   --
   END create_pep_epo_rec;

   --

   --
   PROCEDURE p_manage_icm_life_events (
      p_person_id           IN   NUMBER,
      p_effective_date      IN   DATE,
      p_business_group_id   IN   NUMBER,
      p_lf_evt_ocrd_dt      IN   DATE DEFAULT NULL
   )
   IS
      --
      l_proc                    VARCHAR2 (72)
                                  := g_package || '.p_manage_icm_life_events';
      l_errbuf                  VARCHAR2 (2000);
      l_retcode                 NUMBER;
      l_effective_date          VARCHAR2 (30);
      --
      l_encoded_message         VARCHAR2 (2000);
      l_app_short_name          VARCHAR2 (2000);
      l_message_name            VARCHAR2 (2000);
      l_threads                 NUMBER                       := 0;
      p_ler_id                  NUMBER;
      --
      l_bft_id                  NUMBER;
      l_lf_evt_ocrd_dt          DATE;
      l_chunk_size              NUMBER                       := 0;
      l_rec                     benutils.g_active_life_event;
      l_max_errors_allowed      NUMBER;
      l_object_version_number   NUMBER;
      p_person_count            NUMBER;
      l_count2                  NUMBER;
      l_count3                  NUMBER                       := 1;
      l_pep_count               NUMBER;
      cache1                    NUMBER;
      cache11                   NUMBER                       := 1;
      l_count_icm1              NUMBER;
      l_prev_eligibility        BOOLEAN;
      --
      l_elig_per_id             NUMBER;
      l_elig_per_elig_flag      VARCHAR2 (1000);
      l_prev_prtn_strt_dt       DATE;
      l_prev_prtn_end_dt        DATE;
      l_per_in_ler_id           NUMBER;
      l_old_age_val             NUMBER;
      l_old_los_val             NUMBER;
      --
      j                         NUMBER                       := 1;
      temp1                     NUMBER;
      temp2                     NUMBER;
      l_msg                     VARCHAR2(2000);
   --
   BEGIN
      --
      g_debug := hr_utility.debug_enabled;
--      hr_utility.trace_on(null,'rtagarra');
      IF g_debug
      THEN
         hr_utility.set_location ('Entering ' || l_proc, 10);
      END IF;

      --
      DELETE FROM ben_icd_chc_rates
            WHERE person_id = p_person_id;
      --
      COMMIT;
      --
      SAVEPOINT icm_life_events_savepoint;
      fnd_msg_pub.initialize;
      ben_icm_life_events.g_cache_pep_object.DELETE;
      ben_icm_life_events.g_cache_epo_object.DELETE;
      --
      l_effective_date := fnd_date.date_to_canonical (p_effective_date);
      --
      l_bft_id := NULL;
      --
      ben_manage_life_events.g_modified_mode := NULL;
      --
      ben_comp_object_list1.refresh_eff_date_caches;
      --
      ben_manage_life_events.process
                                  (errbuf                          => l_errbuf,
                                   retcode                         => l_retcode,
                                   p_benefit_action_id             => l_bft_id,
                                   p_effective_date                => l_effective_date,
                                   p_mode                          => 'D',
                                   p_derivable_factors             => 'ASC',
                                   p_validate                      => 'N',
                                   p_person_id                     => p_person_id,
                                   p_person_type_id                => NULL,
                                   p_pgm_id                        => NULL,
                                   p_business_group_id             => p_business_group_id,
                                   p_pl_id                         => NULL,
                                   p_popl_enrt_typ_cycl_id         => NULL,
                                   p_no_programs                   => 'N',
                                   p_no_plans                      => 'N',
                                   p_comp_selection_rule_id        => NULL,
                                   p_person_selection_rule_id      => NULL,
                                   p_ler_id                        => NULL,
                                   p_organization_id               => NULL,
                                   p_benfts_grp_id                 => NULL,
                                   p_location_id                   => NULL,
                                   p_pstl_zip_rng_id               => NULL,
                                   p_rptg_grp_id                   => NULL,
                                   p_pl_typ_id                     => NULL,
                                   p_opt_id                        => NULL,
                                   p_eligy_prfl_id                 => NULL,
                                   p_vrbl_rt_prfl_id               => NULL,
                                   p_legal_entity_id               => NULL,
                                   p_payroll_id                    => NULL,
                                   p_commit_data                   => 'N',
                                   p_lf_evt_ocrd_dt                => l_lf_evt_ocrd_dt
                                  );

      --
      IF g_debug
      THEN
         hr_utility.set_location ('After process', 10);
         hr_utility.set_location ('Before get_parameter', 21);
      END IF;

      --
      benutils.get_parameter (p_business_group_id      => p_business_group_id,
                              p_batch_exe_cd           => 'BENMNGLE',
                              p_threads                => l_threads,
                              p_chunk_size             => l_chunk_size,
                              p_max_errors             => l_max_errors_allowed
                             );

      --
      -- Set up benefits environment
      --
      IF g_debug
      THEN
         hr_utility.set_location ('After get_parameter', 22);
         hr_utility.set_location ('Before clear_init_benmngle_caches', 23);
      END IF;

      --
      --
      ben_manage_life_events.clear_init_benmngle_caches
                         (p_business_group_id      => p_business_group_id,
                          p_effective_date         => p_effective_date,
                          p_threads                => l_threads,
                          p_chunk_size             => l_chunk_size,
                          p_max_errors             => l_max_errors_allowed,
                          p_benefit_action_id      => benutils.g_benefit_action_id,
                          p_thread_id              => 1
                         );

      --
      IF g_debug
      THEN
         hr_utility.set_location ('After clear_init_benmngle_caches', 24);
         hr_utility.set_location ('Before Build Comp Object List', 30);
      END IF;

      --
      ben_comp_object_list.flush_multi_session_cache
                                  (p_business_group_id      => p_business_group_id,
                                   p_effective_date         => p_effective_date
                                  );
      --
      ben_comp_object_list.build_comp_object_list
                         (p_benefit_action_id           => benutils.g_benefit_action_id,
                          p_comp_selection_rule_id      => NULL,
                          p_effective_date              => p_effective_date,
                          p_pgm_id                      => NULL,
                          p_business_group_id           => p_business_group_id,
                          p_pl_id                       => NULL,
                          p_oipl_id                     => NULL,
                          p_asnd_lf_evt_dt              => NULL,
                          p_no_programs                 => 'N',
                          p_no_plans                    => 'N',
                          p_rptg_grp_id                 => NULL,
                          p_pl_typ_id                   => NULL,
                          p_opt_id                      => NULL,
                          p_eligy_prfl_id               => NULL,
                          p_vrbl_rt_prfl_id             => NULL,
                          p_thread_id                   => 1,
                          p_mode                        => 'D'
                         );

      --
      IF g_debug
      THEN
         hr_utility.set_location ('After build comp object', 32);
         --
         hr_utility.set_location ('Before evaluate life events', 45);
      --
      END IF;

      ben_manage_life_events.evaluate_life_events
                                  (p_person_id              => p_person_id,
                                   p_business_group_id      => p_business_group_id,
                                   p_mode                   => 'D',
                                   p_ler_id                 => p_ler_id,
                                   p_lf_evt_ocrd_dt         => NVL
                                                                  (p_lf_evt_ocrd_dt,
                                                                   p_effective_date
                                                                  ),
                                   p_effective_date         => p_effective_date
                                  );

      --
      IF g_debug
      THEN
         hr_utility.set_location ('After evaluate life events', 50);
      END IF;

      --
      g_benefit_action_id := benutils.g_benefit_action_id;
      --
      benutils.get_active_life_event
                                  (p_person_id              => p_person_id,
                                   p_business_group_id      => p_business_group_id,
                                   p_effective_date         => p_effective_date,
                                   p_lf_event_mode          => 'D',
                                   p_rec                    => l_rec
                                  );

      --
      IF g_debug
      THEN
         hr_utility.set_location ('Before Person Header', 52);
      END IF;

      --
      ben_manage_life_events.person_header
                               (p_person_id              => p_person_id,
                                p_business_group_id      => p_business_group_id,
                                p_effective_date         => NVL
                                                               (l_rec.lf_evt_ocrd_dt,
                                                                p_effective_date
                                                               )
                               );

      --
      IF g_debug
      THEN
         hr_utility.set_location ('After Person Header', 52);
         --
         hr_utility.set_location ('Before process comp objects', 55);
      --
      END IF;

      ben_manage_life_events.process_comp_objects
                          (p_person_id                  => p_person_id,
                           p_person_action_id           => NULL,
                           p_object_version_number      => l_object_version_number,
                           p_business_group_id          => p_business_group_id,
                           p_mode                       => 'D',
                           p_ler_id                     => p_ler_id,
                           p_derivable_factors          => 'ASC',
                           p_person_count               => p_person_count,
                           p_effective_date             => p_effective_date,
                           p_lf_evt_ocrd_dt             => NVL
                                                              (l_rec.lf_evt_ocrd_dt,
                                                               p_effective_date
                                                              )
                          );
      temp1 := ben_icm_life_events.g_cache_pep_object.COUNT;
      temp2 := ben_icm_life_events.g_cache_epo_object.COUNT;

      IF g_debug
      THEN
         hr_utility.set_location (temp1 || '-->' || temp2 || '<--', 124);
      END IF;

      --
      ROLLBACK TO icm_life_events_savepoint;
      --
--POST PROCESS STARTS FROM HERE FOR ICM
      SAVEPOINT elig_per_cache_savepont;
      --
      --Create PEP AND EPO Records
      create_pep_epo_rec (p_person_id => p_person_id);
      --
      --Create ICD Records
      create_icd_rates (p_person_id              => p_person_id,
                        p_effective_date         => p_effective_date,
                        p_business_group_id      => p_business_group_id
                       );
      ben_icm_life_events.g_cache_pep_object.DELETE;
      ben_icm_life_events.g_cache_epo_object.DELETE;
      ben_determine_activity_base_rt.l_icd_chc_rates_tab.DELETE;

      --
      IF g_debug
      THEN
      --
         hr_utility.set_location ('Leaving ' || l_proc, 30);
      --
      END IF;
   --
   EXCEPTION
--
      WHEN app_exception.application_exception
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('Leaving ' || l_proc, 31);
         END IF;
--
	 l_msg := fnd_message.get;
         fnd_message.set_name('BEN','BEN_94875_ICD_BENMNGLE_ERROR');
	 fnd_message.set_token('BENMNGLE_ERROR',l_msg);
         fnd_msg_pub.add;
         ben_icm_life_events.g_cache_pep_object.DELETE;
         ben_icm_life_events.g_cache_epo_object.DELETE;
         ben_determine_activity_base_rt.l_icd_chc_rates_tab.DELETE;
         ROLLBACK TO icm_life_events_savepoint;
--
      WHEN OTHERS
      THEN
         --
         IF g_debug
         THEN
            hr_utility.set_location ('Leaving ' || SUBSTR (SQLERRM, 1, 50),
                                     32
                                    );
            hr_utility.set_location ('Leaving ' || SUBSTR (SQLERRM, 51, 100),
                                     32
                                    );
         END IF;
	 l_msg := fnd_message.get;
         fnd_message.set_name('BEN','BEN_94875_ICD_BENMNGLE_ERROR');
	 fnd_message.set_token('BENMNGLE_ERROR',l_msg);
         fnd_msg_pub.add;
         ben_icm_life_events.g_cache_pep_object.DELETE;
         ben_icm_life_events.g_cache_epo_object.DELETE;
         ben_determine_activity_base_rt.l_icd_chc_rates_tab.DELETE;
         ROLLBACK TO icm_life_events_savepoint;
      --
--
   END p_manage_icm_life_events;
--
END ben_icm_life_events;
--

/

--------------------------------------------------------
--  DDL for Package Body BEN_IREC_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_IREC_PROCESS" AS
/* $Header: benirecp.pkb 120.7 2008/01/07 15:52:13 rtagarra noship $ */
--
/*
+========================================================================+
|             Copyright (c) 1997 Oracle Corporation                      |
|                Redwood Shores, California, USA                         |
|                      All rights reserved.                              |
+========================================================================+
Name
    Manage iRecruitement processes.
Purpose
        This package contains all the procedures used in iRec flow.
History
     Date             Who        Version    What?
     ----             ---        -------    -----
     23 Sep 04        pbodla     115.0      Created.
     29 Sep 04        pabodla    115.1      Added create_enrollment_for_irec
     05-Apr-05        vvprabhu   115.2      Bug 4254792 - p_return_status added to manage_life_events_w
     11-Jul-07        rtagarra   115.3      Bug 6079424 - Added nvl condition for oipl case,
                                                          Rate condtion,added some more conditions.
     19-Jul-07        rtagarra   115.4      Bug 6236847 - Passed correct enrt_rt_id and values to election_information_w,
                                                          added exception handling and proper validations.
     24-Jul-07        rtagarra   115.6      Bug 6271595 - Passed correct arguments to election_information_w.
     27-jul-07        nhunur     115.7      removed savepoint and corrected exception handling
     30-jul-07        nhunur     115.8      Flat amount rates need to be handled.
     07-Jan-08        rtagarra   115.9      Changed the message number
*/
   g_package   VARCHAR2 (80) := 'ben_irec_process';
--
PROCEDURE p_transfer_bckdt_data (
      p_business_group_id    IN   NUMBER,
      p_effective_date       IN   DATE,
      p_assignment_id        IN   NUMBER,
      p_irec_per_in_ler_id   IN   NUMBER
   )
   IS
      --
      l_proc                    VARCHAR2 (80)      := 'p_transfer_bckdt_data';
      --
      -- Cursor to find the irec backed out per in ler.
      --
      CURSOR c_bckdt_pil (p_assignment_id NUMBER)
      IS
         SELECT   pil.per_in_ler_id, pil.per_in_ler_stat_cd
             FROM ben_per_in_ler pil
            WHERE pil.per_in_ler_id <> p_irec_per_in_ler_id
              AND pil.assignment_id = p_assignment_id
         ORDER BY pil.per_in_ler_id;

      --
      CURSOR c_bckdt_bnft (cp_per_in_ler_id IN NUMBER)
      IS
         SELECT enb.enrt_bnft_id, enb.entr_val_at_enrt_flag, enb.dflt_val,
                enb.val, enb.dflt_flag, enb.object_version_number,
                enb.prtt_enrt_rslt_id, enb.cvg_mlt_cd, epe.pl_id, epe.pgm_id,
                epe.oipl_id, enb.ordr_num
           FROM ben_enrt_bnft enb, ben_elig_per_elctbl_chc epe
          WHERE enb.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
            AND epe.per_in_ler_id = cp_per_in_ler_id;

      --
      CURSOR c_active_bnft (
         cp_irec_per_in_ler_id   IN   NUMBER,
         cp_pgm_id               IN   NUMBER,
         cp_pl_id                IN   NUMBER,
         cp_oipl_id              IN   NUMBER,
         cp_ordr_num             IN   NUMBER
      )
      IS
         SELECT enb.enrt_bnft_id, enb.entr_val_at_enrt_flag, enb.dflt_val,
                enb.val, enb.dflt_flag, enb.object_version_number,
                enb.prtt_enrt_rslt_id, enb.cvg_mlt_cd, epe.pl_id, epe.pgm_id,
                epe.oipl_id, enb.ordr_num
           FROM ben_enrt_bnft enb, ben_elig_per_elctbl_chc epe
          WHERE enb.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
            AND epe.per_in_ler_id = cp_irec_per_in_ler_id
            AND NVL (epe.pgm_id, -1) = NVL (cp_pgm_id, -1)
            AND NVL (epe.pl_id, -1) = NVL (cp_pl_id, -1)
            AND NVL (epe.oipl_id, -1) = NVL (cp_oipl_id, -1)
            AND enb.ordr_num = cp_ordr_num;

      --
      l_bckdt_bnft_rec          c_bckdt_bnft%ROWTYPE;
      l_bnft_rec_reset          c_bckdt_bnft%ROWTYPE;
      l_bnft_entr_val_found     BOOLEAN;
      l_num_bnft_recs           NUMBER                  := 0;
      l_active_bnft_rec         c_active_bnft%ROWTYPE;
      l_active_bnft_rec_reset   c_active_bnft%ROWTYPE;

      --
      CURSOR c_bckdt_rt (cp_bckdt_per_in_ler_id NUMBER)
      IS
         SELECT ecr.enrt_rt_id, ecr.dflt_val, ecr.val,
                ecr.entr_val_at_enrt_flag, epe.pl_id, epe.pgm_id, epe.oipl_id,
                ecr.acty_base_rt_id, ecr.ann_val
           FROM ben_enrt_rt ecr, ben_elig_per_elctbl_chc epe
          WHERE epe.per_in_ler_id = cp_bckdt_per_in_ler_id
            AND ecr.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
            AND ecr.entr_val_at_enrt_flag = 'Y'
            AND ecr.spcl_rt_enrt_rt_id IS NULL
         UNION
         SELECT ecr.enrt_rt_id, ecr.dflt_val, ecr.val,
                ecr.entr_val_at_enrt_flag, epe.pl_id, epe.pgm_id, epe.oipl_id,
                ecr.acty_base_rt_id, ecr.ann_val
           FROM ben_enrt_rt ecr,
                ben_elig_per_elctbl_chc epe,
                ben_enrt_bnft enb
          WHERE ecr.enrt_bnft_id = enb.enrt_bnft_id
            AND epe.per_in_ler_id = cp_bckdt_per_in_ler_id
            AND enb.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
            AND ecr.entr_val_at_enrt_flag = 'Y'
            AND ecr.spcl_rt_enrt_rt_id IS NULL;

      --
      CURSOR c_active_rt (
         cp_irec_per_in_ler_id        NUMBER,
         cp_pgm_id               IN   NUMBER,
         cp_pl_id                IN   NUMBER,
         cp_oipl_id              IN   NUMBER,
         cp_acty_base_rt_id      IN   NUMBER,
         cp_ordr_num             IN   NUMBER
      )
      IS
         SELECT ecr.enrt_rt_id, ecr.dflt_val, ecr.val,
                ecr.entr_val_at_enrt_flag, ecr.acty_base_rt_id, ecr.ann_val,
                ecr.object_version_number, ecr.entr_ann_val_flag
           FROM ben_enrt_rt ecr, ben_elig_per_elctbl_chc epe
          WHERE epe.per_in_ler_id = cp_irec_per_in_ler_id
            AND ecr.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
            AND ecr.entr_val_at_enrt_flag = 'Y'
            AND ecr.spcl_rt_enrt_rt_id IS NULL
            AND NVL (epe.pgm_id, -1) = NVL (cp_pgm_id, -1)
            AND NVL (epe.pl_id, -1) = NVL (cp_pl_id, -1)
            AND NVL (epe.oipl_id, -1) = NVL (cp_oipl_id, -1)
            AND ecr.acty_base_rt_id = cp_acty_base_rt_id
         UNION
         SELECT ecr.enrt_rt_id, ecr.dflt_val, ecr.val,
                ecr.entr_val_at_enrt_flag, ecr.acty_base_rt_id, ecr.ann_val,
                ecr.object_version_number, ecr.entr_ann_val_flag
           FROM ben_enrt_rt ecr,
                ben_elig_per_elctbl_chc epe,
                ben_enrt_bnft enb
          WHERE ecr.enrt_bnft_id = enb.enrt_bnft_id
            AND epe.per_in_ler_id = cp_irec_per_in_ler_id
            AND enb.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
            AND ecr.entr_val_at_enrt_flag = 'Y'
            AND NVL (epe.pgm_id, -1) = NVL (cp_pgm_id, -1)
            AND NVL (epe.pl_id, -1) = NVL (cp_pl_id, -1)
            AND NVL (epe.oipl_id, -1) = NVL (cp_oipl_id, -1)
            AND ecr.acty_base_rt_id = cp_acty_base_rt_id
            AND ecr.spcl_rt_enrt_rt_id IS NULL;

      --
      l_active_rt_rec           c_active_rt%ROWTYPE;
      l_rt_rec_reset            c_active_rt%ROWTYPE;
      l_bckdt_per_in_ler_id     NUMBER;
      l_per_in_ler_stat_cd      VARCHAR2 (30);
      --
      g_debug                   BOOLEAN                 := FALSE;
   BEGIN
      --
      g_debug := hr_utility.debug_enabled;

      --
      IF g_debug
      THEN
         hr_utility.set_location ('Entering : ' || g_package || '.' || l_proc,
                                  35
                                 );
      END IF;

      --
      /*
         *   Step 1 : Get the latest backed out pil which is linked to irec assignment.
         *   Step 2 : If it is in voided state then return.
         *   Step 3 : If in backed out state then copy the data for enter
         *            val at enrollment cases.
         *
      */
      OPEN c_bckdt_pil (p_assignment_id);

      FETCH c_bckdt_pil
       INTO l_bckdt_per_in_ler_id, l_per_in_ler_stat_cd;

      CLOSE c_bckdt_pil;

      --
      IF NVL (l_per_in_ler_stat_cd, 'ZZZ') = 'BCKDT'
      THEN
         --
         -- Get all the epe's attached to backed out pil and are enter val at enrollment
         --
         --
         l_num_bnft_recs := 0;
         l_bnft_entr_val_found := FALSE;
         l_bckdt_bnft_rec := l_bnft_rec_reset;

         --
         OPEN c_bckdt_bnft (l_bckdt_per_in_ler_id);

         LOOP
            --
            hr_utility.set_location ('Inside bnft loop ' || l_proc, 20);

            --
            FETCH c_bckdt_bnft
             INTO l_bckdt_bnft_rec;

            EXIT WHEN c_bckdt_bnft%NOTFOUND;

            IF    l_bckdt_bnft_rec.entr_val_at_enrt_flag = 'Y'
               OR l_bckdt_bnft_rec.cvg_mlt_cd = 'SAAEAR'
            THEN
               l_bnft_entr_val_found := TRUE;

               --
               -- Now find the equivalent benefit row attached to the active
               -- irec event and update it.
               --
               OPEN c_active_bnft (p_irec_per_in_ler_id,
                                   l_bckdt_bnft_rec.pgm_id,
                                   l_bckdt_bnft_rec.pl_id,
                                   l_bckdt_bnft_rec.oipl_id,
                                   l_bckdt_bnft_rec.ordr_num
                                  );

               FETCH c_active_bnft
                INTO l_active_bnft_rec;

               CLOSE c_active_bnft;

               --
               -- Now update the active benefit row.
               --
               IF     (   l_active_bnft_rec.entr_val_at_enrt_flag = 'Y'
                       OR l_active_bnft_rec.cvg_mlt_cd = 'SAAEAR'
                      )
                  AND l_active_bnft_rec.val <> l_bckdt_bnft_rec.val
               THEN
                  --
                  ben_enrt_bnft_api.update_enrt_bnft
                     (p_enrt_bnft_id               => l_active_bnft_rec.enrt_bnft_id,
                      p_val                        => l_bckdt_bnft_rec.val,
                      p_object_version_number      => l_active_bnft_rec.object_version_number,
                      p_effective_date             => p_effective_date
                     );
               --
               END IF;
            --
            END IF;
         --
         END LOOP;

         CLOSE c_bckdt_bnft;

         --
         -- Now copy the rates if they are enter val at enrollment.
         -- ENTR_VAL_AT_ENRT_FLAG, ENTR_ANN_VAL_FLAG, ORDR_NUM
         --
         FOR l_bckdt_rt_rec IN c_bckdt_rt (l_bckdt_per_in_ler_id)
         LOOP
            --
            -- Now find the equivalent benefit row attached to the active
            -- irec event and update it.
            --
            OPEN c_active_rt (p_irec_per_in_ler_id,
                              l_bckdt_rt_rec.pgm_id,
                              l_bckdt_rt_rec.pl_id,
                              l_bckdt_rt_rec.oipl_id,
                              l_bckdt_rt_rec.acty_base_rt_id,
                              NULL
                             );

            FETCH c_active_rt
             INTO l_active_rt_rec;

            CLOSE c_active_rt;

            --
            IF     (   l_active_rt_rec.entr_val_at_enrt_flag = 'Y'
                    OR l_active_rt_rec.entr_ann_val_flag = 'Y'
                   )
               AND (   l_active_rt_rec.val <> l_bckdt_rt_rec.val
                    OR l_bckdt_rt_rec.ann_val <> l_bckdt_rt_rec.ann_val
                   )
            THEN
               --
               ben_enrollment_rate_api.update_enrollment_rate
                  (p_enrt_rt_id                 => l_active_rt_rec.enrt_rt_id,
                   p_val                        => l_bckdt_rt_rec.val,
                   p_ann_val                    => l_bckdt_rt_rec.ann_val,
                   p_object_version_number      => l_active_rt_rec.object_version_number,
                   p_effective_date             => p_effective_date
                  );
            --
            END IF;
         END LOOP;
      --
      END IF;

      --
      IF g_debug
      THEN
         hr_utility.set_location ('Leaving : ' || g_package || '.' || l_proc,
                                  35
                                 );
      END IF;
   --
END p_transfer_bckdt_data;
--
--
PROCEDURE create_enrollment_for_irec (
      p_irec_per_in_ler_id   IN   NUMBER,
      p_person_id            IN   NUMBER,
      p_business_group_id    IN   NUMBER,
      p_effective_date       IN   DATE
   )
   IS
      --
      l_dummy                  VARCHAR2 (30);
      l_api_error              BOOLEAN;
      l_benmngle_called        BOOLEAN                := FALSE;
      --
      CURSOR c_elig_per_electbl (p_irec_per_in_ler_id NUMBER)
      IS
         SELECT *
           FROM ben_elig_per_elctbl_chc irec_epe
          WHERE irec_epe.per_in_ler_id = p_irec_per_in_ler_id
            AND irec_epe.approval_status_cd = 'IRC_BEN_A';      -- Bug 6079424
      --
      CURSOR c_unrstr_epe (
         p_unrstr_per_in_ler_id   NUMBER,
         p_pgm_id                 NUMBER,
         p_pl_id                  NUMBER,
         p_oipl_id                NUMBER
      )
      IS
         SELECT *
           FROM ben_elig_per_elctbl_chc irec_epe
          WHERE per_in_ler_id = p_unrstr_per_in_ler_id
            AND NVL (pgm_id, -1) = NVL (p_pgm_id, -1)
            AND pl_id = p_pl_id
            AND NVL (oipl_id, -1) = NVL (p_oipl_id, -1);

      l_unrstr_epe             c_unrstr_epe%ROWTYPE;
      --
      CURSOR c_dflt_enb (p_elig_per_elctbl_chc_id NUMBER)
      IS
         SELECT enb.*
           FROM ben_enrt_bnft enb
          WHERE enb.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
      --
      l_dflt_enb               c_dflt_enb%ROWTYPE;
      l_unres_dflt_enb         c_dflt_enb%ROWTYPE;
      --
      --
      CURSOR c_rt (cp_elig_per_elctbl_chc_id NUMBER, cp_enrt_bnft_id NUMBER)
      IS
         SELECT ecr.enrt_rt_id, ecr.dflt_val, ecr.val,
                ecr.entr_val_at_enrt_flag, ecr.acty_base_rt_id
           FROM ben_enrt_rt ecr
          WHERE ecr.elig_per_elctbl_chc_id = cp_elig_per_elctbl_chc_id
            AND ecr.business_group_id = p_business_group_id
            -- AND ecr.entr_val_at_enrt_flag = 'Y'
            AND ecr.spcl_rt_enrt_rt_id IS NULL
         UNION
         SELECT ecr.enrt_rt_id, ecr.dflt_val, ecr.val,
                ecr.entr_val_at_enrt_flag, ecr.acty_base_rt_id
           FROM ben_enrt_rt ecr
          WHERE ecr.enrt_bnft_id = cp_enrt_bnft_id
            AND ecr.business_group_id = p_business_group_id
            -- AND ecr.entr_val_at_enrt_flag = 'Y'
            AND ecr.spcl_rt_enrt_rt_id IS NULL;
      --
      l_rt                     c_rt%ROWTYPE;
      --
      --
      --
      l_temp_pen_ovn           NUMBER;
      l_unrstr_per_in_ler_id   NUMBER;
      l_prtt_rt_val_id1        NUMBER;
      l_prtt_rt_val_id2        NUMBER;
      l_prtt_rt_val_id3        NUMBER;
      l_prtt_rt_val_id4        NUMBER;
      l_prtt_rt_val_id5        NUMBER;
      l_prtt_rt_val_id6        NUMBER;
      l_prtt_rt_val_id7        NUMBER;
      l_prtt_rt_val_id8        NUMBER;
      l_prtt_rt_val_id9        NUMBER;
      l_prtt_rt_val_id10       NUMBER;
      l_proc                   VARCHAR2 (72) := g_package || '.create_enrollment_for_irec';
      --
      TYPE g_rt_rec IS RECORD (
         enrt_rt_id    ben_enrt_rt.enrt_rt_id%TYPE,
         val           ben_enrt_rt.val%TYPE,
         dflt_val      ben_enrt_rt.dflt_val%TYPE,
         calc_val      ben_enrt_rt.dflt_val%TYPE,
         rt_strt_dt    DATE,
         rt_end_dt     DATE,
         cmcd_rt_val   NUMBER,
         ann_rt_val    NUMBER
      );
      --
      TYPE g_rt_table IS TABLE OF g_rt_rec
         INDEX BY BINARY_INTEGER;
      --
      TYPE g_unres_rec IS RECORD (
         enrt_rt_id    ben_enrt_rt.enrt_rt_id%TYPE,
         val           ben_enrt_rt.val%TYPE,
         dflt_val      ben_enrt_rt.dflt_val%TYPE,
         calc_val      ben_enrt_rt.dflt_val%TYPE,
         rt_strt_dt    DATE,
         rt_end_dt     DATE,
         cmcd_rt_val   NUMBER,
         ann_rt_val    NUMBER
      );
      --
      TYPE g_unres_rt_table IS TABLE OF g_unres_rec
         INDEX BY BINARY_INTEGER;

      --
      l_unres_rt_table         g_unres_rt_table;
      l_unres_count            NUMBER;
      l_msg                    VARCHAR2 (2000);
      l_rt_table               g_rt_table;
      l_count                  NUMBER;
      l_return_status          VARCHAR2 (20);
--
BEGIN
      --
      hr_utility.set_location ('Entering ' || l_proc, 332);
      --
      --
      FOR l_rec IN c_elig_per_electbl (p_irec_per_in_ler_id)
      LOOP
         --
         IF NOT l_benmngle_called
         THEN
            ben_on_line_lf_evt.p_manage_life_events_w
                             (p_person_id              => p_person_id,
                              p_effective_date         => p_effective_date,
                              p_business_group_id      => l_rec.business_group_id,
                              p_mode                   => 'U',
                              p_return_status          => l_return_status
                             );
            l_benmngle_called := TRUE;
            --
            -- Get un restricted pil
            --
            l_unrstr_per_in_ler_id :=
               benutils.get_per_in_ler_id
                                  (p_person_id              => p_person_id,
                                   p_business_group_id      => p_business_group_id,
                                   p_ler_id                 => NULL,
                                   p_lf_event_mode          => NULL,
                                   p_effective_date         => p_effective_date
                                  );
         END IF;

         --
         OPEN c_unrstr_epe (l_unrstr_per_in_ler_id,
                            l_rec.pgm_id,
                            l_rec.pl_id,
                            l_rec.oipl_id
                           );

         FETCH c_unrstr_epe  INTO l_unrstr_epe;
	 -- If condition is added for say some comp obj may be inelig for 'U' Mode then the cursor will fail
         IF c_unrstr_epe%FOUND
         THEN
            --
            CLOSE c_unrstr_epe;
            OPEN c_dflt_enb (l_rec.elig_per_elctbl_chc_id);
            FETCH c_dflt_enb INTO l_dflt_enb;
            CLOSE c_dflt_enb;

            /* Rates */
            FOR l_count IN 1..10
            LOOP
               --
               -- Initialise array to null
               --
               l_rt_table (l_count).enrt_rt_id := NULL;
               l_rt_table (l_count).val := NULL;
            --
            END LOOP;
            --
            -- Now get the rates.
            --
            l_count := 0;
            --
            FOR l_ecr_rec IN c_rt (l_rec.elig_per_elctbl_chc_id,
                                   l_dflt_enb.enrt_bnft_id
                                  )
            LOOP
               --
               -- Get the prtt rate val for this choice
               -- Use to pass to the enrollment process.
               --
               l_count := l_count + 1;
               l_rt_table (l_count).enrt_rt_id := l_ecr_rec.enrt_rt_id;
               l_rt_table (l_count).val := l_ecr_rec.val;
               l_rt_table (l_count).dflt_val := l_ecr_rec.dflt_val;
               --
               hr_utility.set_location ('Irec enrt_rt_id ' || l_rt_table (l_count).enrt_rt_id,53);
               hr_utility.set_location ('Irec val ' || l_rt_table (l_count).val,53);
               hr_utility.set_location ('Irec Enrt_bnft_id ' || l_dflt_enb.enrt_bnft_id,53);
            --
            END LOOP;
            --
            OPEN c_dflt_enb (l_unrstr_epe.elig_per_elctbl_chc_id);
            FETCH c_dflt_enb INTO l_unres_dflt_enb;
            CLOSE c_dflt_enb;
            --
            FOR l_unres_count IN 1..10
            LOOP
               --
               -- Initialise array to null
               --
               l_unres_rt_table (l_unres_count).enrt_rt_id := NULL;
               l_unres_rt_table (l_unres_count).val := NULL;
               l_unres_rt_table (l_unres_count).dflt_val := NULL;
            --
            END LOOP;
            --
            -- Now get the unrst rates.
            --
            l_unres_count := 0;
            --
            FOR l_ecr_rec IN c_rt (l_unrstr_epe.elig_per_elctbl_chc_id,
                                   l_unres_dflt_enb.enrt_bnft_id
                                  )
            LOOP
               --
               -- Get the rate val for this choice.
               -- Use to pass to the enrollment process.
               --
               l_unres_count := l_unres_count + 1;
               l_unres_rt_table (l_unres_count).enrt_rt_id :=  l_ecr_rec.enrt_rt_id;
               l_unres_rt_table (l_unres_count).val := l_ecr_rec.val;
               l_unres_rt_table (l_unres_count).dflt_val := l_ecr_rec.dflt_val;
               --
               hr_utility.set_location('Unrst Enrt_rt_id' || l_unres_rt_table (l_unres_count).enrt_rt_id,96);
               hr_utility.set_location('Unrst Val' || l_unres_rt_table (l_unres_count).val,96);
               hr_utility.set_location('Unrst Enrt_bnft_id' || l_unres_dflt_enb.enrt_bnft_id,96);
            --
            END LOOP;
            --
            hr_utility.set_location('Enter election information',96);
	    --
	    --
            ben_election_information.election_information_w
               (p_validate                    => 'N',
                p_elig_per_elctbl_chc_id      => l_unrstr_epe.elig_per_elctbl_chc_id,
                p_prtt_enrt_rslt_id           => l_unrstr_epe.prtt_enrt_rslt_id,
                p_effective_date              => p_effective_date,
                p_person_id                   => p_person_id,
                p_enrt_mthd_cd                => 'E',
                p_enrt_bnft_id                => l_unres_dflt_enb.enrt_bnft_id ,
                p_bnft_val                    => NVL(l_dflt_enb.val,l_dflt_enb.dflt_val) ,
                p_enrt_rt_id1                 => l_unres_rt_table (1).enrt_rt_id,
                p_prtt_rt_val_id1             => NULL,
                p_rt_val1                     => NVL (l_rt_table (1).val, l_rt_table (1).dflt_val),
                p_ann_rt_val1                 => l_rt_table (1).ann_rt_val,
                p_rt_strt_dt1                 => l_rt_table (1).rt_strt_dt,
                p_rt_end_dt1                  => l_rt_table (1).rt_end_dt,
                p_rt_strt_dt_cd1              => NULL,
                p_enrt_rt_id2                 => l_unres_rt_table (2).enrt_rt_id,
                p_prtt_rt_val_id2             => NULL,
                p_rt_val2                     => NVL (l_rt_table (2).val, l_rt_table (2).dflt_val ),
                p_ann_rt_val2                 => l_rt_table (2).ann_rt_val,
                p_rt_strt_dt2                 => l_rt_table (2).rt_strt_dt,
                p_rt_end_dt2                  => l_rt_table (2).rt_end_dt,
                p_enrt_rt_id3                 => l_unres_rt_table (3).enrt_rt_id ,
                p_prtt_rt_val_id3             => NULL,
                p_rt_val3                     => NVL (l_rt_table (3).val,l_rt_table (3).dflt_val),
                p_ann_rt_val3                 => l_rt_table (3).ann_rt_val,
                p_rt_strt_dt3                 => l_rt_table (3).rt_strt_dt,
                p_rt_end_dt3                  => l_rt_table (3).rt_end_dt,
                p_datetrack_mode              => hr_api.g_correction,
                p_suspend_flag                => 'N' ,
                p_effective_start_date        => p_effective_date,
                p_object_version_number       => l_temp_pen_ovn,
                p_business_group_id           => l_unrstr_epe.business_group_id,
                p_enrt_cvg_strt_dt            => l_unrstr_epe.enrt_cvg_strt_dt,
                p_enrt_cvg_thru_dt            => NULL,
                p_api_error                   => l_api_error
               );
            hr_utility.set_location('Completed election information',96);
	    --
            ben_proc_common_enrt_rslt.process_post_enrollment_w
                               (p_per_in_ler_id          => l_unrstr_epe.per_in_ler_id,
                                p_pgm_id                 => l_rec.pgm_id,
                                p_pl_id                  => l_rec.pl_id,
                                p_enrt_mthd_cd           => 'E',
                                p_cls_enrt_flag          => 'N',
                                p_proc_cd                => NULL,
                                p_person_id              => p_person_id,
                                p_business_group_id      => p_business_group_id,
                                p_effective_date         => p_effective_date,
                                p_validate               => 'FALSE'
                               );
            hr_utility.set_location('Completed post enrollment',96);
         --
	 ELSE
	     CLOSE c_unrstr_epe;
         END IF;
         --
      END LOOP;
      --
      hr_utility.set_location ('Leaving ' || l_proc, 332);
   --
EXCEPTION
      --
      WHEN app_exception.application_exception
      THEN
         --
         IF c_unrstr_epe%ISOPEN
         THEN
            CLOSE c_unrstr_epe;
         --
         ELSIF c_rt%ISOPEN
         THEN
            CLOSE c_rt;
         --
         ELSIF c_dflt_enb%ISOPEN
         THEN
            CLOSE c_dflt_enb;
         --
         END IF;

         l_msg := fnd_message.get;
         fnd_message.set_name ('BEN', 'BEN_94875_ICD_BENMNGLE_ERROR');
         fnd_message.set_token ('BENMNGLE_ERROR', l_msg || substr(SQLERRM,1,50));
         ROLLBACK;
	 RAISE;
      --
      WHEN OTHERS
      THEN
         --
         IF c_unrstr_epe%ISOPEN
         THEN
            CLOSE c_unrstr_epe;
         --
         ELSIF c_rt%ISOPEN
         THEN
            CLOSE c_rt;
         --
         ELSIF c_dflt_enb%ISOPEN
         THEN
            CLOSE c_dflt_enb;
         --
         END IF;
         --
         l_msg := fnd_message.get;
         fnd_message.set_name ('BEN', 'BEN_94875_ICD_BENMNGLE_ERROR');
         fnd_message.set_token ('BENMNGLE_ERROR', l_msg || substr(SQLERRM,1,50));
	 --
         ROLLBACK;
	 RAISE;
     --
   --
   END create_enrollment_for_irec;
--
END ben_irec_process;

/

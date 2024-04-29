--------------------------------------------------------
--  DDL for Package Body HRI_OPL_BEN_ELCTN_EVNTS_EQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_BEN_ELCTN_EVNTS_EQ" AS
/* $Header: hrieqele.pkb 120.0 2005/09/21 01:26:58 anmajumd noship $ */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   Name  :  HRI_OPL_BEN_ELCTN_EVNTS_EQ
--    Purpose  :  Populate Benefits Election events queue
--
-- PROCEDURE insert_event
--     insert_event
--     ==============
--
-- PROCEDURE update_event
--     update_event
--     ==============
--
-- PROCEDURE delete_event
--     delete_event
--     ==============
--
-- ------------------------------------------------------------------------------
-- History
-- -------
-- Version Date       Author           Comment
-- -------+----------+----------------+------------------------------------------
-- 12.0    30-JUN-05   nhunur          Initial Version
-- -------------------------------------------------------------------------------
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
--
   PROCEDURE insert_event (
      p_rec              IN   ben_pel_shd.g_rec_type,
      p_pil_rec          IN   ben_pil_shd.g_rec_type,
      p_called_from      IN   VARCHAR2,
      p_effective_date   IN   DATE,
      p_datetrack_mode   IN   VARCHAR2
   )
   IS
      CURSOR c_date
      IS
         SELECT person_id, lf_evt_ocrd_dt
           FROM ben_per_in_ler
          WHERE per_in_ler_id = p_rec.per_in_ler_id;

--
      l_date   c_date%ROWTYPE;
--
   BEGIN
--

      IF p_called_from = 'PEL'
      THEN
         OPEN c_date;
         FETCH c_date INTO l_date;

         IF c_date%NOTFOUND
         THEN
            CLOSE c_date;
            RETURN;
         END IF;

         CLOSE c_date;

         INSERT INTO hri_eq_ben_elctn_evts
                     ( person_id,
                       per_in_ler_id,
                       pil_elctbl_chc_popl_id,
                       lf_evt_ocrd_dt,
                       business_group_id,
                       pgm_id,
                       pl_id,
                       fnd_concurrent_request_id,
                       event_date,
                       event_cd,
                       dflt_enrt_dt,
                       dflt_asnd_dt,
                       elcns_made_dt,
                       enrt_typ_cycl_cd,
                       enrt_perd_end_dt,
                       enrt_perd_strt_dt,
                       procg_end_dt,
                       pil_elctbl_popl_stat_cd,
                       auto_asnd_dt, enrt_perd_id,
                       assignment_id,
                       elig_ind,
                       enrt_ind,
                       dflt_ind,
                       last_update_date,
                       last_updated_by,
                       last_update_login,
                       created_by,
                       creation_date
                     )
              VALUES ( l_date.person_id,
                       p_rec.per_in_ler_id,
                       p_rec.pil_elctbl_chc_popl_id,
                       l_date.lf_evt_ocrd_dt,
                       p_rec.business_group_id,
                       p_rec.pgm_id,
                       p_rec.pl_id,
                       -1,
                       p_effective_date,
                       DECODE (p_datetrack_mode, 'INSERT', 'INSERT', 'UPDATE'),
                       p_rec.dflt_enrt_dt,
                       p_rec.dflt_asnd_dt,
                       p_rec.elcns_made_dt,
                       p_rec.enrt_typ_cycl_cd,
                       p_rec.enrt_perd_end_dt,
                       p_rec.enrt_perd_strt_dt,
                       p_rec.procg_end_dt,
                       p_rec.pil_elctbl_popl_stat_cd,
                       p_rec.auto_asnd_dt,
                       p_rec.enrt_perd_id,
                       p_rec.assignment_id,
                       DECODE (p_rec.pil_elctbl_popl_stat_cd, NULL, 1, 0),
                       DECODE (p_rec.elcns_made_dt, NULL, 0, 1),
                       DECODE (p_rec.dflt_enrt_dt, NULL, 0, 1),
                       SYSDATE,
                       fnd_global.user_id,
                       fnd_global.login_id,
                       fnd_global.user_id,
                       SYSDATE
                     );
      END IF;

      IF p_called_from = 'PIL'
      THEN
         IF p_pil_rec.per_in_ler_stat_cd IN ('VOIDD')
         THEN
            FOR pel_rec IN (SELECT *
                              FROM ben_pil_elctbl_chc_popl pel
                             WHERE per_in_ler_id = p_pil_rec.per_in_ler_id
                               AND pel.pgm_id IS NOT NULL)
            LOOP
               INSERT INTO hri_eq_ben_elctn_evts
                           ( person_id,
                             per_in_ler_id,
                             pil_elctbl_chc_popl_id,
                             lf_evt_ocrd_dt,
                             business_group_id,
                             pgm_id,
                             pl_id,
                             fnd_concurrent_request_id,
                             event_date,
                             event_cd,
                             dflt_enrt_dt,
                             dflt_asnd_dt,
                             elcns_made_dt,
                             enrt_typ_cycl_cd,
                             enrt_perd_end_dt,
                             enrt_perd_strt_dt,
                             procg_end_dt,
                             pil_elctbl_popl_stat_cd,
                             auto_asnd_dt,
                             enrt_perd_id,
                             assignment_id,
                             elig_ind,
                             enrt_ind,
                             dflt_ind,
                             last_update_date,
                             last_updated_by,
                             last_update_login,
                             created_by,
                             creation_date
                           )
                    VALUES ( l_date.person_id,
                             pel_rec.per_in_ler_id,
                             pel_rec.pil_elctbl_chc_popl_id,
                             p_pil_rec.lf_evt_ocrd_dt,
                             pel_rec.business_group_id,
                             pel_rec.pgm_id,
                             pel_rec.pl_id,
                             -1,
                             p_effective_date,
                             'UPDATE',
                             pel_rec.dflt_enrt_dt,
                             pel_rec.dflt_asnd_dt,
                             pel_rec.elcns_made_dt,
                             pel_rec.enrt_typ_cycl_cd,
                             pel_rec.enrt_perd_end_dt,
                             pel_rec.enrt_perd_strt_dt,
                             pel_rec.procg_end_dt,
                             pel_rec.pil_elctbl_popl_stat_cd,
                             pel_rec.auto_asnd_dt,
                             pel_rec.enrt_perd_id,
                             pel_rec.assignment_id,
                             DECODE (pel_rec.pil_elctbl_popl_stat_cd,
                                     NULL, 1,
                                     0
                                    ),
                             DECODE (pel_rec.elcns_made_dt, NULL, 0, 1),
                             DECODE (pel_rec.dflt_enrt_dt, NULL, 0, 1),
                             SYSDATE,
                             fnd_global.user_id,
                             fnd_global.login_id,
                             fnd_global.user_id,
                             SYSDATE
                           );
            END LOOP;
         END IF;

         --
         IF p_pil_rec.per_in_ler_stat_cd IN ('BCKDT')
         THEN
            --
            INSERT INTO hri_eq_ben_enrlactn_evts
                        ( person_id,
                          per_in_ler_id,
                          lf_evt_ocrd_dt,
                          business_group_id,
                          fnd_concurrent_request_id,
                          event_date,
                          event_cd,
                          last_update_date,
                          last_updated_by,
                          last_update_login,
                          created_by,
                          creation_date
                        )
                 VALUES ( p_pil_rec.person_id,
                          p_pil_rec.per_in_ler_id,
                          p_pil_rec.lf_evt_ocrd_dt,
                          p_pil_rec.business_group_id, -1,
                          p_effective_date,
                          'ZAP',
                          SYSDATE,
                          fnd_global.user_id,
                          fnd_global.login_id,
                          fnd_global.user_id,
                          SYSDATE
                        );
         END IF;
      END IF;
   END;

--
   PROCEDURE update_event (
      p_rec              IN   ben_pel_shd.g_rec_type,
      p_pil_rec          IN   ben_pil_shd.g_rec_type,
      p_called_from      IN   VARCHAR2,
      p_effective_date   IN   DATE,
      p_datetrack_mode   IN   VARCHAR2
   )
   IS
   BEGIN
      insert_event (p_rec                 => p_rec,
                    p_pil_rec             => p_pil_rec,
                    p_called_from         => p_called_from,
                    p_effective_date      => p_effective_date,
                    p_datetrack_mode      => p_datetrack_mode
                   );
   END;

--
   PROCEDURE delete_event (
      p_rec              IN   ben_pel_shd.g_rec_type,
      p_effective_date   IN   DATE,
      p_datetrack_mode   IN   VARCHAR2
   )
   IS
   BEGIN
      insert_event (p_rec                 => p_rec,
                    p_pil_rec             => NULL,
                    p_called_from         => NULL,
                    p_effective_date      => p_effective_date,
                    p_datetrack_mode      => p_datetrack_mode
                   );
   END;
--
END hri_opl_ben_elctn_evnts_eq;

/

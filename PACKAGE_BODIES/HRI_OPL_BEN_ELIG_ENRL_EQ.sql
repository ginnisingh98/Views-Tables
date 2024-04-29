--------------------------------------------------------
--  DDL for Package Body HRI_OPL_BEN_ELIG_ENRL_EQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_BEN_ELIG_ENRL_EQ" AS
/* $Header: hrieqeec.pkb 120.2 2005/11/15 01:10:53 bmanyam noship $ */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   Name  :  HRI_EQ_BEN_ELIGENRL_EVTS
--    Purpose  :  Populate event queue table
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
-- 115.0    30-JUN-05   nhunur          Initial Version
-- 115.1    14-Nov-05   bmanyam         4714512 - Suspended Enrollments also need
--                                      to be counted as enrolled
-- 115.2    15-Nov-05   bmanyam         Fixed GSCC Errors.
-- -------------------------------------------------------------------------------
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION get_plip_id (
      p_pl_id            IN   NUMBER,
      p_pgm_id           IN   NUMBER,
      p_effective_date   IN   DATE
   )
      RETURN NUMBER
   AS
--
      CURSOR c_plip
      IS
         SELECT plip_id
           FROM ben_plip_f
          WHERE pl_id = p_pl_id
            AND pgm_id = p_pgm_id
            AND p_effective_date BETWEEN effective_start_date
                                     AND effective_end_date;

--
      l_plip   c_plip%ROWTYPE;
--
   BEGIN
--
      OPEN c_plip;
      FETCH c_plip INTO l_plip;
      CLOSE c_plip;
      RETURN NVL (l_plip.plip_id, -1);
--
   END;

--
   FUNCTION get_lf_evt_dt (p_per_in_ler_id IN NUMBER)
      RETURN DATE
   AS
--
      CURSOR c_date
      IS
         SELECT lf_evt_ocrd_dt
           FROM ben_per_in_ler
          WHERE per_in_ler_id = p_per_in_ler_id;

--
      l_date   DATE;
--
   BEGIN
--
      OPEN c_date;
      FETCH c_date INTO l_date;
      CLOSE c_date;
      RETURN l_date;
--
   END;

--
   PROCEDURE insert_event (
      p_rec              IN   ben_pen_shd.g_rec_type,
      p_effective_date   IN   DATE,
      p_datetrack_mode   IN   VARCHAR2
   )
   IS
   BEGIN
      INSERT INTO hri_eq_ben_eligenrl_evts
                  (person_id,
                   per_in_ler_id,
                   prtt_enrt_rslt_id,
                   interim_enrt_rslt_id,
                   lf_evt_ocrd_dt,
                   business_group_id,
                   pgm_id,
                   pl_id,
                   ptip_id,
                   pl_typ_id,
                   plip_id,
                   oipl_id,
                   fnd_concurrent_request_id,
                   event_date,
                   event_cd,
                   enrt_ind,
                   dflt_ind,
                   waive_expl_ind,
                   last_update_date,
                   last_updated_by,
                   last_update_login,
                   created_by,
                   creation_date
                  )
           VALUES (p_rec.person_id,
                   p_rec.per_in_ler_id,
                   p_rec.prtt_enrt_rslt_id,
                   p_rec.rplcs_sspndd_rslt_id,
                   get_lf_evt_dt (p_rec.per_in_ler_id),
                   p_rec.business_group_id,
                   p_rec.pgm_id,
                   p_rec.pl_id,
                   p_rec.ptip_id,
                   p_rec.pl_typ_id,
                   get_plip_id (p_rec.pl_id, p_rec.pgm_id, p_effective_date),
                   p_rec.oipl_id,
                   -1,
                   p_effective_date,
                   'ENRD',
                   1,
                   DECODE (fnd_global.conc_request_id, -1, 0, 1),
                   0,
                   SYSDATE,
                   fnd_global.user_id,
                   fnd_global.login_id,
                   fnd_global.user_id,
                   SYSDATE
                  );
   END;

--
   PROCEDURE update_event (
      p_rec              IN   ben_pen_shd.g_rec_type,
      p_effective_date   IN   DATE,
      p_datetrack_mode   IN   VARCHAR2
   )
   IS
   BEGIN
      --
      IF (p_rec.effective_end_date <> hr_api.g_eot
          OR p_rec.enrt_cvg_thru_dt <> hr_api.g_eot) THEN
      -- 4714512 : Suspended Enrollments also need to be counted as enrolled
      --
      INSERT INTO hri_eq_ben_eligenrl_evts
                  (person_id,
                   per_in_ler_id,
                   prtt_enrt_rslt_id,
                   interim_enrt_rslt_id,
                   lf_evt_ocrd_dt,
                   business_group_id,
                   pgm_id,
                   pl_id,
                   ptip_id,
                   pl_typ_id,
                   plip_id,
                   oipl_id,
                   fnd_concurrent_request_id,
                   event_date,
                   event_cd,
                   enrt_ind,
                   dflt_ind,
                   waive_expl_ind,
                   last_update_date,
                   last_updated_by,
                   last_update_login,
                   created_by,
                   creation_date
                  )
           VALUES (p_rec.person_id,
                   p_rec.per_in_ler_id,
                   p_rec.prtt_enrt_rslt_id,
                   p_rec.rplcs_sspndd_rslt_id,
                   get_lf_evt_dt (p_rec.per_in_ler_id),
                   p_rec.business_group_id,
                   p_rec.pgm_id,
                   p_rec.pl_id,
                   p_rec.ptip_id,
                   p_rec.pl_typ_id,
                   get_plip_id (p_rec.pl_id, p_rec.pgm_id, p_effective_date),
                   p_rec.oipl_id,
                   -1,
                   p_effective_date,
                   'DE-ENRD',
                   0,
                   DECODE (fnd_global.conc_request_id, -1, 0, 0),
                   0,
                   SYSDATE,
                   fnd_global.user_id,
                   fnd_global.login_id,
                   fnd_global.user_id,
                   SYSDATE
                  );
      END IF;
   END;

--
   PROCEDURE delete_event (
      p_rec              IN   ben_pen_shd.g_rec_type,
      p_effective_date   IN   DATE,
      p_datetrack_mode   IN   VARCHAR2
   )
   IS
   BEGIN
      INSERT INTO hri_eq_ben_eligenrl_evts
                  (person_id,
                   per_in_ler_id,
                   prtt_enrt_rslt_id,
                   interim_enrt_rslt_id,
                   lf_evt_ocrd_dt,
                   business_group_id,
                   pgm_id,
                   pl_id,
                   ptip_id,
                   pl_typ_id,
                   plip_id,
                   oipl_id,
                   fnd_concurrent_request_id,
                   event_date,
                   event_cd,
                   enrt_ind,
                   dflt_ind,
                   waive_expl_ind,
                   last_update_date,
                   last_updated_by,
                   last_update_login,
                   created_by,
                   creation_date
                  )
           VALUES (p_rec.person_id,
                   p_rec.per_in_ler_id,
                   p_rec.prtt_enrt_rslt_id,
                   p_rec.rplcs_sspndd_rslt_id,
                   get_lf_evt_dt (p_rec.per_in_ler_id),
                   p_rec.business_group_id,
                   p_rec.pgm_id,
                   p_rec.pl_id,
                   p_rec.ptip_id,
                   p_rec.pl_typ_id,
                   get_plip_id (p_rec.pl_id, p_rec.pgm_id, p_effective_date),
                   p_rec.oipl_id,
                   -1,
                   p_effective_date,
                   DECODE (p_datetrack_mode, 'ZAP', 'ZAP', 'DE-ENRD'),
                   0,
                   DECODE (fnd_global.conc_request_id, -1, 0, 0),
                   0,
                   SYSDATE,
                   fnd_global.user_id,
                   fnd_global.login_id,
                   fnd_global.user_id,
                   SYSDATE
                  );
   END;
--
END hri_opl_ben_elig_enrl_eq;

/

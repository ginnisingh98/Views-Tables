--------------------------------------------------------
--  DDL for Package Body HRI_OPL_BEN_ENRLACTN_EQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_BEN_ENRLACTN_EQ" AS
/* $Header: hrieqeea.pkb 120.0 2005/09/21 01:26:15 anmajumd noship $ */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   Name  :  HRI_OPL_BEN_ENRLACTN_EQ
   Purpose  :  Populate Benefits Enrollment Action event queue
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
-- 12.0    30-JUN-05   abparekh        Initial Version
-- -------------------------------------------------------------------------------
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
--
--
  -- ----------------------------------------------------------------------------
  -- |-----------------------------< GET_LF_EVT_DT >----------------------------|
  -- ----------------------------------------------------------------------------
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
      --
      FETCH c_date INTO l_date;
      --
      CLOSE c_date;
      --
      RETURN l_date;
   --
   END;

--
  -- ----------------------------------------------------------------------------
  -- |------------------------------< INSERT_EVENT >----------------------------|
  -- ----------------------------------------------------------------------------
   PROCEDURE insert_event (
      p_rec              IN   ben_pea_shd.g_rec_type,
      p_effective_date   IN   DATE,
      p_datetrack_mode   IN   VARCHAR2
   )
   IS
      --
      CURSOR c_act_typ
      IS
         SELECT type_cd
           FROM ben_actn_typ
          WHERE actn_typ_id = p_rec.actn_typ_id;

      --
      CURSOR c_pen
      IS
         SELECT pil.person_id, pen.pgm_id, pen.pl_id, pen.oipl_id,
                pen.sspndd_flag, pil.lf_evt_ocrd_dt
           FROM ben_prtt_enrt_rslt_f pen, ben_per_in_ler pil
          WHERE pil.per_in_ler_id = p_rec.per_in_ler_id
            AND pen.prtt_enrt_rslt_id = p_rec.prtt_enrt_rslt_id
            AND p_effective_date BETWEEN pen.effective_start_date
                                     AND pen.effective_end_date;

      --
      l_pen_row       c_pen%ROWTYPE;
      l_actn_typ_cd   VARCHAR2 (30);
   --
   BEGIN
      --
      OPEN c_pen;
      --
      FETCH c_pen INTO l_pen_row;

      --

      IF c_pen%NOTFOUND
      THEN
         --
         CLOSE c_pen;
         RETURN;
      --
      ELSE
         --
         OPEN c_act_typ;
         --
         FETCH c_act_typ INTO l_actn_typ_cd;

         --
         IF c_act_typ%NOTFOUND
         THEN
            --
            CLOSE c_act_typ;
            RETURN;
         --
         END IF;
      --
      END IF;

      --
      CLOSE c_pen;
      CLOSE c_act_typ;

      --
      INSERT INTO hri_eq_ben_enrlactn_evts
                  ( person_id,
                    per_in_ler_id,
                    prtt_enrt_rslt_id,
                    pgm_id,
                    pl_id,
                    oipl_id,
                    lf_evt_ocrd_dt,
                    sspndd_flag,
                    actn_typ_cd,
                    actn_typ_id,
                    prtt_enrt_actn_id,
                    elig_cvrd_dpnt_id,
                    pl_bnf_id,
                    due_dt,
                    cmpltd_dt,
                    rqd_flag,
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
           VALUES ( l_pen_row.person_id,
                    p_rec.per_in_ler_id,
                    p_rec.prtt_enrt_rslt_id,
                    l_pen_row.pgm_id,
                    l_pen_row.pl_id,
                    l_pen_row.oipl_id,
                    l_pen_row.lf_evt_ocrd_dt,
                    l_pen_row.sspndd_flag,
                    l_actn_typ_cd,
                    p_rec.actn_typ_id,
                    p_rec.prtt_enrt_actn_id,
                    p_rec.elig_cvrd_dpnt_id,
                    p_rec.pl_bnf_id,
                    p_rec.due_dt,
                    p_rec.cmpltd_dt,
                    p_rec.rqd_flag,
                    p_rec.business_group_id,
                    1,
                    p_effective_date,
                    DECODE (p_datetrack_mode,
                            'INSERT', 'INSERTED',
                            'ZAP', 'ZAP',
                            'COMPLETED'
                           ),
                    SYSDATE,
                    fnd_global.user_id,
                    fnd_global.login_id,
                    fnd_global.user_id,
                    SYSDATE
                  );
   END;

  -- ----------------------------------------------------------------------------
  -- |------------------------------< UPDATE_EVENT >----------------------------|
  -- ----------------------------------------------------------------------------
   PROCEDURE update_event (
      p_rec              IN   ben_pea_shd.g_rec_type,
      p_effective_date   IN   DATE,
      p_datetrack_mode   IN   VARCHAR2
   )
   IS
   BEGIN
      insert_event (p_rec, p_effective_date, p_datetrack_mode);
   END;

  -- ----------------------------------------------------------------------------
  -- |------------------------------< DELETE_EVENT >----------------------------|
  -- ----------------------------------------------------------------------------
   PROCEDURE delete_event (
      p_rec              IN   ben_pea_shd.g_rec_type,
      p_effective_date   IN   DATE,
      p_datetrack_mode   IN   VARCHAR2
   )
   IS
   BEGIN
      insert_event (p_rec, p_effective_date, p_datetrack_mode);
   END;
--
--
END hri_opl_ben_enrlactn_eq;

/

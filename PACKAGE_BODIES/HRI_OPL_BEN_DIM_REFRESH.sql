--------------------------------------------------------
--  DDL for Package Body HRI_OPL_BEN_DIM_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_BEN_DIM_REFRESH" as
/* $Header: hripbdrf.pkb 120.0 2005/09/21 01:27:42 anmajumd noship $ */

  --
  -- Holds the range for which the collection is to be run.
  --
  g_full_refresh                VARCHAR2(10);
  g_business_group_id           NUMBER(15);
  --
  -- The HRI schema
  --
  g_schema                  VARCHAR2(400);
  --
  -- Set to true to output to a concurrent log file
  --
  g_conc_request_flag       BOOLEAN := FALSE;
  --
  --
  -- CONSTANTS
  -- =========
  --
  -- @@ Code specific to this view/table below
  -- @@ in the call to hri_bpl_conc_log.get_last_collect_to_date
  -- @@ change param1/2 to be the concurrent program short name,
  -- @@ and the target table name respectively.
  --
  g_cncrnt_prgrm_shrtnm   VARCHAR2(30) DEFAULT 'HRI_CS_COMP_OBJ_ENRT_PERD';
  --
  -- @@ Code specific to this view/table below ENDS
  --
  -- constants that hold the value that indicates to full refresh or not.
  --
  g_is_full_refresh    VARCHAR2(5) DEFAULT 'Y';
  g_not_full_refresh   VARCHAR2(5) DEFAULT 'N';
  --
  -- -----------------------------------------------------------------------------
  -- Inserts row into concurrent program log if debugging is enabled
  -- -----------------------------------------------------------------------------
  PROCEDURE dbg(p_text  VARCHAR2) IS
  BEGIN
      --
         HRI_BPL_CONC_LOG.dbg(p_text);
      --   DBMS_OUTPUT.PUT_LINE(p_text);
      --
  END dbg;
  --
  -- ----------------------------------------------------------------------------
  -- |-------------------------------< OUTPUT >----------------------------------|
  -- ----------------------------------------------------------------------------
  -- Inserts row into concurrent program log when the g_conc_request_flag has
  -- been set to TRUE, otherwise does nothing
  --
  PROCEDURE output(p_text  VARCHAR2)
    IS
    --
  BEGIN
    --
    -- Write to the concurrent request log if called from a concurrent request
    --
    IF (g_conc_request_flag = TRUE) THEN
      --
      -- Put text to log file
      --
      fnd_file.put_line(FND_FILE.log, p_text);
      --
    ELSE
      --
      hr_utility.set_location(p_text, 999);
      --dbms_output.put_line(p_text);
      --
    END IF;
    --
  END output;
  --
  -- ----------------------------------------------------------------------------
  -- |--------------------------< RUN_SQL_STMT_NOERR >--------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Runs given sql statement dynamically without raising an error
  --
  PROCEDURE run_sql_stmt_noerr( p_sql_stmt   VARCHAR2 )
  IS
  --
  BEGIN
    --
    EXECUTE IMMEDIATE p_sql_stmt;
    --
  EXCEPTION WHEN OTHERS THEN
    --
    output('Error running sql:');
    output(SUBSTR(p_sql_stmt,1,230));
    --
  END run_sql_stmt_noerr;
  --
  --
  -- ----------------------------------------------------------------------------
  -- |--------------------------< INCREMENTAL_UPDATE >--------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Loops through table and collects into table structure.
  --
  PROCEDURE Incremental_Update IS
    --
    l_sql_stmt                  VARCHAR2(2000);
    l_current_time              DATE            := SYSDATE;
    l_user_id                   NUMBER          := fnd_global.user_id;
    l_effective_date            DATE            := TRUNC(SYSDATE);
    l_business_group_id         NUMBER(15)      := g_business_group_id;
    l_login_id                  NUMBER          := fnd_global.login_id;
    --
    CURSOR c_pgm IS
       SELECT pgm.pgm_id pgm_id
         FROM ben_pgm_f pgm
        WHERE l_effective_date BETWEEN pgm.effective_start_date
                                   AND pgm.effective_end_date
          AND pgm.pgm_typ_cd IN ('CORE', 'FLEX', 'FPC', 'OTHER')
          AND EXISTS (
                 SELECT 'x'
                   FROM ben_popl_enrt_typ_cycl_f pet, ben_enrt_perd enp
                  WHERE pet.pgm_id = pgm.pgm_id
                    AND pet.enrt_typ_cycl_cd = 'O'
                    AND l_effective_date BETWEEN pet.effective_start_date
                                              AND pet.effective_end_date
                    AND pet.popl_enrt_typ_cycl_id = enp.popl_enrt_typ_cycl_id)
          AND NOT EXISTS (SELECT 'x'
                            FROM HRI_CS_CO_PGM_CT pgmd
                           WHERE pgmd.pgm_id = pgm.pgm_id);
    --
    CURSOR c_ptip IS
      SELECT ctp.ptip_id ptip_id, ctp.pl_typ_id pl_typ_id, ctp.pgm_id pgm_id,
             ctp.ordr_num ptip_ordr_num
        FROM ben_ptip_f ctp, ben_pl_typ_f ptp
       WHERE ctp.pl_typ_id = ptp.pl_typ_id
         AND l_effective_date BETWEEN ctp.effective_start_date
                                  AND ctp.effective_end_date
         AND l_effective_date BETWEEN ptp.effective_start_date
                                  AND ptp.effective_end_date
         AND ptp.opt_typ_cd <> 'SPDGACCT'
         AND EXISTS (SELECT 'x'
                       FROM hri_cs_co_pgm_ct pgmd
                      WHERE pgmd.pgm_id = ctp.pgm_id)
         AND NOT EXISTS (SELECT 'x'
                           FROM hri_cs_co_pgmh_ptip_ct ctpd
                          WHERE ctpd.ptip_id = ctp.ptip_id);

    --
    CURSOR c_plip IS
      SELECT cpp.plip_id plip_id, cpp.pl_id pl_id, cpp.pgm_id pgm_id,
             ctpd.ptip_id ptip_id, ctpd.pl_typ_id pl_typ_id, cpp.ordr_num plip_ordr_num
        FROM ben_plip_f cpp, ben_pl_f pln, hri_cs_co_pgmh_ptip_ct ctpd
       WHERE cpp.pl_id = pln.pl_id
         AND pln.pl_typ_id = ctpd.pl_typ_id
         AND cpp.pgm_id = ctpd.pgm_id
         AND pln.invk_flx_cr_pl_flag = 'N'
         AND pln.imptd_incm_calc_cd IS NULL
         AND l_effective_date BETWEEN cpp.effective_start_date
                                  AND cpp.effective_end_date
         AND l_effective_date BETWEEN pln.effective_start_date
                                  AND pln.effective_end_date
         AND NOT EXISTS (SELECT 'x'
                           FROM HRI_CS_CO_PGMH_PLIP_CT cppd
                          WHERE cppd.plip_id = cpp.plip_id);
    --
    CURSOR c_plip_ernt_pl IS
      SELECT cpp.plip_id plip_id, cpp.pl_id pl_id, cpp.pgm_id pgm_id,
             ctpd.ptip_id ptip_id, ctpd.pl_typ_id pl_typ_id
        FROM ben_plip_f cpp, ben_pl_f pln, hri_cs_co_pgmh_ptip_ct ctpd
       WHERE cpp.pl_id = pln.pl_id
         AND pln.pl_typ_id = ctpd.pl_typ_id
         AND cpp.pgm_id = ctpd.pgm_id
         AND (   pln.enrt_pl_opt_flag = 'Y'
              OR NOT EXISTS (
                    SELECT 'x'
                      FROM ben_oipl_f cop
                     WHERE cop.pl_id = pln.pl_id
                       AND l_effective_date BETWEEN cop.effective_start_date
                                                AND cop.effective_end_date)
             )
         AND l_effective_date BETWEEN cpp.effective_start_date
                                  AND cpp.effective_end_date
         AND l_effective_date BETWEEN pln.effective_start_date
                                  AND pln.effective_end_date
         AND pln.invk_flx_cr_pl_flag = 'N'
         AND pln.imptd_incm_calc_cd IS NULL
         AND NOT EXISTS (SELECT 'x'
                           FROM HRI_CS_COMPOBJ_CT oppd
                          WHERE oppd.plip_id = cpp.plip_id
                            AND oppd.oiplip_id = -1);
    --
    CURSOR c_oiplip IS
      SELECT opp.oiplip_id oiplip_id, opp.oipl_id oipl_id, cop.opt_id opt_id,
             opp.plip_id plip_id, cppd.pl_typ_id pl_typ_id,
             cppd.ptip_id ptip_id, cppd.pl_id pl_id, cppd.pgm_id pgm_id, cop.ordr_num oipl_ordr_num
        FROM ben_oiplip_f opp, ben_oipl_f cop, hri_cs_co_pgmh_plip_ct cppd
       WHERE opp.plip_id = cppd.plip_id
         AND cop.oipl_id = opp.oipl_id
         AND l_effective_date BETWEEN opp.effective_start_date
                                  AND opp.effective_end_date
         AND l_effective_date BETWEEN cop.effective_start_date
                                  AND cop.effective_end_date
         AND NOT EXISTS (SELECT 'x'
                           FROM HRI_CS_COMPOBJ_CT oppd
                          WHERE oppd.oiplip_id = opp.oiplip_id);

    --

    CURSOR c_popl_rptg_grp
    IS
      SELECT rgr.popl_rptg_grp_id, rgr.rptg_grp_id, rgr.pgm_id
        FROM ben_popl_rptg_grp_f rgr, hri_cs_co_pgm_ct pgmd
       WHERE rgr.pgm_id IS NOT NULL
         AND rgr.pgm_id = pgmd.pgm_id
         AND l_effective_date BETWEEN rgr.effective_start_date
                                  AND rgr.effective_end_date
         AND NOT EXISTS (SELECT 'x'
                           FROM HRI_CS_CO_RPGH_PIRG_CT rgrd
                          WHERE rgrd.RPTGTYP_ID = rgr.rptg_grp_id
                            AND rgrd.pgm_id = rgr.pgm_id);
    --
    CURSOR c_pgm_enrt_perd
    IS
      SELECT enp.enrt_perd_id, pgmd.pgm_id, enp.strt_dt, enp.end_dt, enp.ASND_LF_EVT_DT ASND_LF_EVT_DT
        FROM hri_cs_co_pgm_ct pgmd,
             ben_popl_enrt_typ_cycl_f pet,
             ben_enrt_perd enp
       WHERE pgmd.pgm_id = pet.pgm_id
         AND pet.popl_enrt_typ_cycl_id = enp.popl_enrt_typ_cycl_id
         AND l_effective_date BETWEEN pet.effective_start_date
                                  AND pet.effective_end_date
         AND NOT EXISTS (SELECT 'x'
                           FROM HRI_CS_TIME_BENRL_PRD_CT enpd
                          WHERE enpd.enrt_perd_id = enp.enrt_perd_id);
    --
    CURSOR c_pl_enrt_perd
    IS
       SELECT enp.enrt_perd_id, enpd.pgm_id, enp.strt_dt, enp.end_dt,
              enp.asnd_lf_evt_dt ASND_LF_EVT_DT
         FROM hri_cs_time_benrl_prd_ct enpd,
              ben_plip_f cpp,
              ben_popl_enrt_typ_cycl_f pet,
              ben_enrt_perd enp
        WHERE enpd.pgm_id = cpp.pgm_id
          AND pet.pl_id = cpp.pl_id
          AND pet.popl_enrt_typ_cycl_id = enp.popl_enrt_typ_cycl_id
          AND enpd.ASND_LF_EVT_DT = enp.asnd_lf_evt_dt
          AND l_effective_date BETWEEN cpp.effective_start_date
                                   AND cpp.effective_end_date
          AND l_effective_date BETWEEN pet.effective_start_date
                                   AND pet.effective_end_date
          AND NOT EXISTS (SELECT 'x'
                            FROM HRI_CS_TIME_BENRL_PRD_CT enpd
                           WHERE enpd.enrt_perd_id = enp.enrt_perd_id);
    --
  BEGIN
    --
    output('Inside Incremental Update');
    --
    --   (1) Populate dimension table HRI_CS_CO_PGM_CT
    --
    FOR l_pgm_row in c_pgm LOOP
      --
      INSERT INTO HRI_CS_CO_PGM_CT
          (  PGM_id
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN
           , CREATED_BY
           , CREATION_DATE
          )
      VALUES
          (  l_pgm_row.pgm_id
           , l_current_time
           , l_user_id
           , l_login_id
           , l_user_id
           , l_current_time
          );
      --
    END LOOP;
    --
    output('Populated Program Dimension:   '  || to_char(sysdate,'HH24:MI:SS'));
    --
    --   (2) Populate dimension table HRI_CS_CO_PGMH_PTIP_CT
    --
    FOR l_ptip_row in c_ptip LOOP
      --
      INSERT INTO HRI_CS_CO_PGMH_PTIP_CT
          (  ptip_id
           , pl_typ_id
           , PGM_ID
           , ptip_ordr_num
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN
           , CREATED_BY
           , CREATION_DATE
          )
      VALUES
          (  l_ptip_row.ptip_id
           , l_ptip_row.pl_typ_id
           , l_ptip_row.PGM_ID
           , l_ptip_row.ptip_ordr_num
           , l_current_time
           , l_user_id
           , l_login_id
           , l_user_id
           , l_current_time
          );
      --
    END LOOP;
    --
    output('Populated Plan Type In Program Dimension:   '  || to_char(sysdate,'HH24:MI:SS'));
    --
    --
    --   (3) Populate dimension table HRI_CS_CO_PGMH_PLIP_CT
    --
    FOR l_plip_row in c_plip LOOP
      --
      INSERT INTO HRI_CS_CO_PGMH_PLIP_CT
          (  plip_id
           , pl_id
           , PGM_ID
           , ptip_id
           , pl_typ_id
           , plip_ordr_num
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN
           , CREATED_BY
           , CREATION_DATE
          )
      VALUES
          (  l_plip_row.plip_id
           , l_plip_row.pl_id
           , l_plip_row.PGM_ID
           , l_plip_row.ptip_id
           , l_plip_row.pl_typ_id
           , l_plip_row.plip_ordr_num
           , l_current_time
           , l_user_id
           , l_login_id
           , l_user_id
           , l_current_time
          );
      --
    END LOOP;
    --
    output('Populated Plan In Program Dimension:   '  || to_char(sysdate,'HH24:MI:SS'));
    --
    --   (4) Populate dimension table HRI_CS_COMPOBJ_CT
    --
    FOR l_oiplip_row in c_oiplip LOOP
      --
      INSERT INTO HRI_CS_COMPOBJ_CT
          (  compobj_sk_pk
           , oiplip_id
           , oipl_id
           , opt_id
           , pl_id
           , plip_id
           , PGM_ID
           , ptip_id
           , pl_typ_id
           , oipl_ordr_num
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN
           , CREATED_BY
           , CREATION_DATE
          )
      VALUES
          (  HRI_CS_COMPOBJ_CT_s.nextval
           , l_oiplip_row.oiplip_id
           , l_oiplip_row.oipl_id
           , l_oiplip_row.opt_id
           , l_oiplip_row.pl_id
           , l_oiplip_row.plip_id
           , l_oiplip_row.PGM_ID
           , l_oiplip_row.ptip_id
           , l_oiplip_row.pl_typ_id
           , l_oiplip_row.oipl_ordr_num
           , l_current_time
           , l_user_id
           , l_login_id
           , l_user_id
           , l_current_time
           );
      --
    END LOOP;
    --
    --   (5) Populate dimension table HRI_CS_COMPOBJ_CT for Enrollments at Plan Level
    --
    FOR l_plip_ernt_pl_row in c_plip_ernt_pl LOOP
      --
      INSERT INTO HRI_CS_COMPOBJ_CT
          (  compobj_sk_pk
           , oiplip_id
           , oipl_id
           , opt_id
           , pl_id
           , plip_id
           , PGM_ID
           , ptip_id
           , pl_typ_id
           , oipl_ordr_num
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN
           , CREATED_BY
           , CREATION_DATE
          )
      VALUES
          (  HRI_CS_COMPOBJ_CT_s.nextval
           , -1
           , -1
           , NULL
           , l_plip_ernt_pl_row.pl_id
           , l_plip_ernt_pl_row.plip_id
           , l_plip_ernt_pl_row.PGM_ID
           , l_plip_ernt_pl_row.ptip_id
           , l_plip_ernt_pl_row.pl_typ_id
           , NULL
           , l_current_time
           , l_user_id
           , l_login_id
           , l_user_id
           , l_current_time
           );
      --
    END LOOP;
    --
    output('Populated Compensation Object Dimension:   '  || to_char(sysdate,'HH24:MI:SS'));
    --
    --   (6) Populate dimension table HRI_CS_CO_RPGH_PIRG_CT for Reporting Group Information
    --
    FOR l_popl_rptg_grp_row in c_popl_rptg_grp LOOP
      --
      INSERT INTO HRI_CS_CO_RPGH_PIRG_CT
          (  PIRG_SK_PK
           , RPTGTYP_ID
           , pgm_id
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN
           , CREATED_BY
           , CREATION_DATE
          )
      VALUES
          (  HRI_CS_CO_RPGH_PIRG_CT_S.nextval
           , l_popl_rptg_grp_row.rptg_grp_id
           , l_popl_rptg_grp_row.pgm_id
           , l_current_time
           , l_user_id
           , l_login_id
           , l_user_id
           , l_current_time
           );
      --
    END LOOP;
    --
    output('Populated Reporting Group Dimension:   '  || to_char(sysdate,'HH24:MI:SS'));
    --
    --   (7) Populate dimension table HRI_CS_TIME_BENRL_PRD_CT for Program Enrollment Periods
    --
    FOR l_enrt_perd_row in c_pgm_enrt_perd LOOP
      --
      INSERT INTO HRI_CS_TIME_BENRL_PRD_CT
          (  enrt_perd_id
           , pgm_id
           , enrt_strt_dt
           , enrt_thru_dt
           , ASND_LF_EVT_DT
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN
           , CREATED_BY
           , CREATION_DATE
          )
      VALUES
          (  l_enrt_perd_row.enrt_perd_id
           , l_enrt_perd_row.pgm_id
           , l_enrt_perd_row.strt_dt
           , l_enrt_perd_row.end_dt
           , l_enrt_perd_row.ASND_LF_EVT_DT
           , l_current_time
           , l_user_id
           , l_login_id
           , l_user_id
           , l_current_time
           );
      --
    END LOOP;
    --
    --   (8) Populate dimension table HRI_CS_TIME_BENRL_PRD_CT for Plan Enrollment Periods
    --
    FOR l_pl_enrt_perd_row in c_pl_enrt_perd LOOP
      --
      INSERT INTO HRI_CS_TIME_BENRL_PRD_CT
          (  enrt_perd_id
           , pgm_id
           , enrt_strt_dt
           , enrt_thru_dt
           , ASND_LF_EVT_DT
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN
           , CREATED_BY
           , CREATION_DATE
          )
      VALUES
          (  l_pl_enrt_perd_row.enrt_perd_id
           , l_pl_enrt_perd_row.pgm_id
           , l_pl_enrt_perd_row.strt_dt
           , l_pl_enrt_perd_row.end_dt
           , l_pl_enrt_perd_row.ASND_LF_EVT_DT
           , l_current_time
           , l_user_id
           , l_login_id
           , l_user_id
           , l_current_time
           );
      --
    END LOOP;
    --
    output('Populated Enrollment Period Dimension:   '  || to_char(sysdate,'HH24:MI:SS'));
    --
    -- Delete rows that no longer exist in the source tables
    --
    -- Program Dimension
    --
    DELETE FROM HRI_CS_CO_PGM_CT pgmd
          WHERE NOT EXISTS (SELECT 'x'
                              FROM ben_pgm_f pgm
                             WHERE pgm.pgm_id = pgmd.pgm_id);
    --
    -- Plan Type In Program Dimension
    --
    DELETE FROM HRI_CS_CO_PGMH_PTIP_CT ctpd
          WHERE NOT EXISTS (SELECT 'x'
                              FROM ben_ptip_f ctp
                             WHERE ctp.ptip_id = ctpd.ptip_id);
    --
    -- Plan In Program Dimension
    --
    DELETE FROM HRI_CS_CO_PGMH_PLIP_CT cppd
          WHERE NOT EXISTS (SELECT 'x'
                              FROM ben_plip_f cpp
                             WHERE cpp.plip_id = cppd.plip_id);
    --
    -- Option In Plan In Program Dimension
    --
    DELETE FROM HRI_CS_COMPOBJ_CT oppd
          WHERE oppd.oiplip_id <> -1
            AND NOT EXISTS (SELECT 'x'
                              FROM ben_oiplip_f opp
                             WHERE opp.oiplip_id = oppd.oiplip_id);
    --
    -- Plan In Program Dimension (Enrol In Plan And Option - Checked)
    --
    DELETE FROM hri_cs_compobj_ct oppd
          WHERE oppd.oiplip_id = -1
            AND oppd.plip_id IS NOT NULL
            AND (   NOT EXISTS (
                       SELECT 'x'
                         FROM ben_pl_f pln
                        WHERE pln.pl_id = oppd.pl_id
                          AND l_effective_date BETWEEN pln.effective_start_date
                                                   AND pln.effective_end_date)
                 OR EXISTS (
                       SELECT 'x'
                         FROM ben_oipl_f cop, ben_pl_f pln
                        WHERE cop.pl_id = oppd.pl_id
                          AND cop.pl_id = pln.pl_id
                          AND l_effective_date BETWEEN pln.effective_start_date
                                                   AND pln.effective_end_date
                          AND pln.enrt_pl_opt_flag = 'N'
                          AND l_effective_date BETWEEN cop.effective_start_date
                                                   AND cop.effective_end_date)
                );
    --
    -- Enrollment Period Dimension
    --
    DELETE FROM HRI_CS_TIME_BENRL_PRD_CT enpd
          WHERE NOT EXISTS (SELECT 'x'
                              FROM ben_enrt_perd enp
                             WHERE enp.enrt_perd_id = enpd.enrt_perd_id);
    --
    -- Reporting Group Dimension
    --
    DELETE FROM HRI_CS_CO_RPGH_PIRG_CT rgrd
          WHERE NOT EXISTS (SELECT 'x'
                              FROM ben_popl_rptg_grp_F rgr
                             WHERE rgr.rptg_grp_id = rgrd.RPTGTYP_ID
                               AND rgr.pgm_id = rgrd.pgm_id);
    --
    output('Removed Deleted Data:   '  || to_char(sysdate,'HH24:MI:SS'));
    --
    COMMIT;
    --
  EXCEPTION
    --
    WHEN OTHERS THEN
      --
      RAISE;
      --
    --
  END Incremental_Update;
  --
  -- ----------------------------------------------------------------------------
  -- |-----------------------------< FULL_REFRESH >-----------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Loops through table and collects into table structure.
  --
  PROCEDURE Full_Refresh IS
    --
    l_sql_stmt                  VARCHAR2(2000);
    l_current_time              DATE            := SYSDATE;
    l_effective_date            DATE            := TRUNC(SYSDATE);
    l_business_group_id         NUMBER(15)      := g_business_group_id;
    l_user_id                   NUMBER          := fnd_global.user_id;
    l_login_id                  NUMBER          := fnd_global.login_id;
    --
    CURSOR c_pgm IS
       SELECT   pgm.pgm_id                           PGM_ID
           FROM ben_pgm_f pgm
          WHERE l_effective_date BETWEEN pgm.effective_start_date
                                     AND pgm.effective_end_date
            AND pgm.pgm_typ_cd in ('CORE', 'FLEX', 'FPC', 'OTHER')
            AND EXISTS (
                   SELECT 'x'
                     FROM ben_popl_enrt_typ_cycl_f pet, ben_enrt_perd enp
                    WHERE pet.pgm_id = pgm.pgm_id
                      AND pet.enrt_typ_cycl_cd = 'O'
                      AND l_effective_date BETWEEN pet.effective_start_date
                                                AND pet.effective_end_date
                      AND pet.popl_enrt_typ_cycl_id = enp.popl_enrt_typ_cycl_id);
    --
   CURSOR c_ptip
   IS
      SELECT ctp.ptip_id ptip_id, ctp.pl_typ_id pl_typ_id, ctp.pgm_id pgm_id,
             ctp.ordr_num ptip_ordr_num
        FROM ben_ptip_f ctp, ben_pl_typ_f ptp
       WHERE ctp.pl_typ_id = ptp.pl_typ_id
         AND l_effective_date BETWEEN ctp.effective_start_date
                                  AND ctp.effective_end_date
         AND l_effective_date BETWEEN ptp.effective_start_date
                                  AND ptp.effective_end_date
         AND ptp.opt_typ_cd <> 'SPDGACCT'
         AND EXISTS (SELECT 'x'
                       FROM hri_cs_co_pgm_ct pgmd
                      WHERE pgmd.pgm_id = ctp.pgm_id);
    --
   CURSOR c_plip
   IS
      SELECT cpp.plip_id plip_id, cpp.pl_id pl_id, cpp.pgm_id pgm_id,
             ctpd.ptip_id ptip_id, ctpd.pl_typ_id pl_typ_id, cpp.ordr_num plip_ordr_num
        FROM ben_plip_f cpp, ben_pl_f pln, hri_cs_co_pgmh_ptip_ct ctpd
       WHERE cpp.pl_id = pln.pl_id
         AND pln.pl_typ_id = ctpd.pl_typ_id
         AND cpp.pgm_id = ctpd.pgm_id
         AND pln.invk_flx_cr_pl_flag = 'N'
         AND pln.imptd_incm_calc_cd IS NULL
         AND l_effective_date BETWEEN cpp.effective_start_date
                                  AND cpp.effective_end_date
         AND l_effective_date BETWEEN pln.effective_start_date
                                  AND pln.effective_end_date;

    --
   CURSOR c_plip_ernt_pl
   IS
      SELECT cpp.plip_id plip_id, cpp.pl_id pl_id, cpp.pgm_id pgm_id,
             ctpd.ptip_id ptip_id, ctpd.pl_typ_id pl_typ_id
        FROM ben_plip_f cpp, ben_pl_f pln, hri_cs_co_pgmh_ptip_ct ctpd
       WHERE cpp.pl_id = pln.pl_id
         AND pln.pl_typ_id = ctpd.pl_typ_id
         AND cpp.pgm_id = ctpd.pgm_id
         AND (   pln.enrt_pl_opt_flag = 'Y'
              OR NOT EXISTS (
                    SELECT 'x'
                      FROM ben_oipl_f cop
                     WHERE cop.pl_id = pln.pl_id
                       AND l_effective_date BETWEEN cop.effective_start_date
                                                AND cop.effective_end_date)
             )
         AND l_effective_date BETWEEN cpp.effective_start_date
                                  AND cpp.effective_end_date
         AND l_effective_date BETWEEN pln.effective_start_date
                                  AND pln.effective_end_date
         AND pln.invk_flx_cr_pl_flag = 'N'
         AND pln.imptd_incm_calc_cd IS NULL;
    --
   CURSOR c_oiplip
   IS
      SELECT opp.oiplip_id oiplip_id, opp.oipl_id oipl_id, cop.opt_id opt_id,
             opp.plip_id plip_id, cppd.pl_typ_id pl_typ_id,
             cppd.ptip_id ptip_id, cppd.pl_id pl_id, cppd.pgm_id pgm_id, cop.ordr_num oipl_ordr_num
        FROM ben_oiplip_f opp, ben_oipl_f cop, hri_cs_co_pgmh_plip_ct cppd
       WHERE opp.plip_id = cppd.plip_id
         AND cop.oipl_id = opp.oipl_id
         AND l_effective_date BETWEEN opp.effective_start_date
                                  AND opp.effective_end_date
         AND l_effective_date BETWEEN cop.effective_start_date
                                  AND cop.effective_end_date;

    --
   CURSOR c_popl_rptg_grp
   IS
      SELECT rgr.popl_rptg_grp_id, rgr.rptg_grp_id, rgr.pgm_id
        FROM ben_popl_rptg_grp_f rgr, hri_cs_co_pgm_ct pgmd
       WHERE rgr.pgm_id IS NOT NULL
         AND rgr.pgm_id = pgmd.pgm_id
         AND l_effective_date BETWEEN rgr.effective_start_date
                                  AND rgr.effective_end_date;
    --
    CURSOR c_pgm_enrt_perd
    IS
      SELECT enp.enrt_perd_id, pgmd.pgm_id, enp.strt_dt, enp.end_dt, enp.ASND_LF_EVT_DT ASND_LF_EVT_DT
        FROM hri_cs_co_pgm_ct pgmd,
             ben_popl_enrt_typ_cycl_f pet,
             ben_enrt_perd enp
       WHERE pgmd.pgm_id = pet.pgm_id
         AND pet.popl_enrt_typ_cycl_id = enp.popl_enrt_typ_cycl_id
         AND l_effective_date BETWEEN pet.effective_start_date
                                  AND pet.effective_end_date;
    --
    CURSOR c_pl_enrt_perd
    IS
       SELECT enp.enrt_perd_id, enpd.pgm_id, enp.strt_dt, enp.end_dt,
              enp.asnd_lf_evt_dt ASND_LF_EVT_DT
         FROM hri_cs_time_benrl_prd_ct enpd,
              ben_plip_f cpp,
              ben_popl_enrt_typ_cycl_f pet,
              ben_enrt_perd enp
        WHERE enpd.pgm_id = cpp.pgm_id
          AND pet.pl_id = cpp.pl_id
          AND pet.popl_enrt_typ_cycl_id = enp.popl_enrt_typ_cycl_id
          AND enpd.ASND_LF_EVT_DT = enp.asnd_lf_evt_dt
          AND l_effective_date BETWEEN cpp.effective_start_date
                                   AND cpp.effective_end_date
          AND l_effective_date BETWEEN pet.effective_start_date
                                   AND pet.effective_end_date;
    --
  BEGIN
    --
    output('Start Of Full Refresh');
    --
    -- Disable the WHO Triggers
    --
    run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_CO_PGM_CT_WHO DISABLE');
    run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_CO_PGMH_PTIP_CT_WHO DISABLE');
    run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_CO_PGMH_PLIP_CT_WHO DISABLE');
    run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_CO_RPGH_PIRG_CT_WHO DISABLE');
    run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_COMPOBJ_CT_WHO DISABLE');
    run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_TIME_BENRL_PRD_CT_WHO DISABLE');
    --
    -- Truncate the target table prior to full refresh.
    --
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_schema || '.HRI_CS_CO_PGM_CT';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_schema || '.HRI_CS_CO_PGMH_PTIP_CT';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_schema || '.HRI_CS_CO_PGMH_PLIP_CT';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_schema || '.HRI_CS_COMPOBJ_CT';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_schema || '.HRI_CS_CO_RPGH_PIRG_CT';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_schema || '.HRI_CS_TIME_BENRL_PRD_CT';
    --
    -- Write timing information to log
    --
    output('Truncated the tables:   '  || to_char(sysdate,'HH24:MI:SS'));
    --
    --
    --   (1) Populate dimension table HRI_CS_CO_PGM_CT
    --
    FOR l_pgm_row in c_pgm LOOP
      --
      INSERT INTO HRI_CS_CO_PGM_CT
          (  PGM_id
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN
           , CREATED_BY
           , CREATION_DATE
          )
      VALUES
          (  l_pgm_row.pgm_id
           , l_current_time
           , l_user_id
           , l_login_id
           , l_user_id
           , l_current_time
          );
      --
    END LOOP;
    --
    output('Populated Program Dimension:   '  || to_char(sysdate,'HH24:MI:SS'));
    --
    --   (2) Populate dimension table HRI_CS_CO_PGMH_PTIP_CT
    --
    FOR l_ptip_row in c_ptip LOOP
      --
      INSERT INTO HRI_CS_CO_PGMH_PTIP_CT
          (  ptip_id
           , pl_typ_id
           , PGM_ID
           , ptip_ordr_num
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN
           , CREATED_BY
           , CREATION_DATE
          )
      VALUES
          (  l_ptip_row.ptip_id
           , l_ptip_row.pl_typ_id
           , l_ptip_row.PGM_ID
           , l_ptip_row.ptip_ordr_num
           , l_current_time
           , l_user_id
           , l_login_id
           , l_user_id
           , l_current_time
          );
      --
    END LOOP;
    --
    output('Populated Plan Type In Program Dimension:   '  || to_char(sysdate,'HH24:MI:SS'));
    --
    --   (3) Populate dimension table HRI_CS_CO_PGMH_PLIP_CT
    --
    FOR l_plip_row in c_plip LOOP
      --
      INSERT INTO HRI_CS_CO_PGMH_PLIP_CT
          (  plip_id
           , pl_id
           , PGM_ID
           , ptip_id
           , pl_typ_id
           , plip_ordr_num
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN
           , CREATED_BY
           , CREATION_DATE
          )
      VALUES
          (  l_plip_row.plip_id
           , l_plip_row.pl_id
           , l_plip_row.PGM_ID
           , l_plip_row.ptip_id
           , l_plip_row.pl_typ_id
           , l_plip_row.plip_ordr_num
           , l_current_time
           , l_user_id
           , l_login_id
           , l_user_id
           , l_current_time
          );
      --
    END LOOP;
    --
    output('Populated Plan In Program Dimension:   '  || to_char(sysdate,'HH24:MI:SS'));
    --
    --   (4) Populate dimension table HRI_CS_COMPOBJ_CT
    --
    FOR l_oiplip_row in c_oiplip LOOP
      --
      INSERT INTO HRI_CS_COMPOBJ_CT
          (  compobj_sk_pk
           , oiplip_id
           , oipl_id
           , opt_id
           , pl_id
           , plip_id
           , PGM_ID
           , ptip_id
           , pl_typ_id
           , oipl_ordr_num
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN
           , CREATED_BY
           , CREATION_DATE
          )
      VALUES
          (  HRI_CS_COMPOBJ_CT_s.nextval
           , l_oiplip_row.oiplip_id
           , l_oiplip_row.oipl_id
           , l_oiplip_row.opt_id
           , l_oiplip_row.pl_id
           , l_oiplip_row.plip_id
           , l_oiplip_row.PGM_ID
           , l_oiplip_row.ptip_id
           , l_oiplip_row.pl_typ_id
           , l_oiplip_row.oipl_ordr_num
           , l_current_time
           , l_user_id
           , l_login_id
           , l_user_id
           , l_current_time
           );
      --
    END LOOP;
    --
    --   (5) Populate dimension table HRI_CS_COMPOBJ_CT for Enrollments at Plan Level
    --
    FOR l_plip_ernt_pl_row in c_plip_ernt_pl LOOP
      --
      INSERT INTO HRI_CS_COMPOBJ_CT
          (  compobj_sk_pk
           , oiplip_id
           , oipl_id
           , opt_id
           , pl_id
           , plip_id
           , PGM_ID
           , ptip_id
           , pl_typ_id
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN
           , CREATED_BY
           , CREATION_DATE
          )
      VALUES
          (  HRI_CS_COMPOBJ_CT_s.nextval
           , -1
           , -1
           , NULL
           , l_plip_ernt_pl_row.pl_id
           , l_plip_ernt_pl_row.plip_id
           , l_plip_ernt_pl_row.PGM_ID
           , l_plip_ernt_pl_row.ptip_id
           , l_plip_ernt_pl_row.pl_typ_id
           , l_current_time
           , l_user_id
           , l_login_id
           , l_user_id
           , l_current_time
           );
      --
    END LOOP;
    --
    output('Populated Compensation Object Dimension:   '  || to_char(sysdate,'HH24:MI:SS'));
    --
    --   (6) Populate dimension table HRI_CS_CO_RPGH_PIRG_CT for Reporting Group Information
    --
    FOR l_popl_rptg_grp_row in c_popl_rptg_grp LOOP
      --
      INSERT INTO HRI_CS_CO_RPGH_PIRG_CT
          (  PIRG_SK_PK
           , RPTGTYP_ID
           , pgm_id
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN
           , CREATED_BY
           , CREATION_DATE
          )
      VALUES
          (  HRI_CS_CO_RPGH_PIRG_CT_S.nextval
           , l_popl_rptg_grp_row.rptg_grp_id
           , l_popl_rptg_grp_row.pgm_id
           , l_current_time
           , l_user_id
           , l_login_id
           , l_user_id
           , l_current_time
          );
      --
    END LOOP;
    --
    output('Populated Reporting Group Dimension:   '  || to_char(sysdate,'HH24:MI:SS'));
    --
    --   (7) Populate dimension table HRI_CS_TIME_BENRL_PRD_CT for Program Enrollment Periods
    --
    FOR l_enrt_perd_row in c_pgm_enrt_perd LOOP
      --
      INSERT INTO HRI_CS_TIME_BENRL_PRD_CT
          (  enrt_perd_id
           , pgm_id
           , enrt_strt_dt
           , enrt_thru_dt
           , ASND_LF_EVT_DT
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN
           , CREATED_BY
           , CREATION_DATE
          )
      VALUES
          (  l_enrt_perd_row.enrt_perd_id
           , l_enrt_perd_row.pgm_id
           , l_enrt_perd_row.strt_dt
           , l_enrt_perd_row.end_dt
           , l_enrt_perd_row.ASND_LF_EVT_DT
           , l_current_time
           , l_user_id
           , l_login_id
           , l_user_id
           , l_current_time
           );
      --
    END LOOP;
    --
    --   (8) Populate dimension table HRI_CS_TIME_BENRL_PRD_CT for Plan Enrollment Periods
    --
    FOR l_pl_enrt_perd_row in c_pl_enrt_perd LOOP
      --
      INSERT INTO HRI_CS_TIME_BENRL_PRD_CT
          (  enrt_perd_id
           , pgm_id
           , enrt_strt_dt
           , enrt_thru_dt
           , ASND_LF_EVT_DT
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN
           , CREATED_BY
           , CREATION_DATE
          )
      VALUES
          (  l_pl_enrt_perd_row.enrt_perd_id
           , l_pl_enrt_perd_row.pgm_id
           , l_pl_enrt_perd_row.strt_dt
           , l_pl_enrt_perd_row.end_dt
           , l_pl_enrt_perd_row.ASND_LF_EVT_DT
           , l_current_time
           , l_user_id
           , l_login_id
           , l_user_id
           , l_current_time
           );
      --
    END LOOP;
    --
    output('Populated Enrollment Period Dimension:   '  || to_char(sysdate,'HH24:MI:SS'));
    --
    COMMIT;
    --
    -- Enable the WHO triggers
    --
    run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_CO_PGM_CT_WHO ENABLE');
    run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_CO_PGMH_PTIP_CT_WHO ENABLE');
    run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_CO_PGMH_PLIP_CT_WHO ENABLE');
    run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_CO_RPGH_PIRG_CT_WHO ENABLE');
    run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_COMPOBJ_CT_WHO ENABLE');
    run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_TIME_BENRL_PRD_CT_WHO ENABLE');
    --
  EXCEPTION
    --
    WHEN OTHERS THEN
      --
      RAISE;
      --
    --
  END Full_Refresh;
  --
  -- ----------------------------------------------------------------------------
  -- |--------------------------------< COLLECT >-------------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Checks what mode you are running in, and if g_full_refresh =
  -- g_is_full_refresh calls
  -- Full_Refresh procedure, otherwise Incremental_Update is called.
  --
  PROCEDURE Collect IS
    --
  BEGIN
    --
    -- If in full refresh mode change the dates so that the collection history
    -- is correctly maintained.
    --
    IF g_full_refresh = g_is_full_refresh THEN
      --
      Full_Refresh;
      --
    ELSE
      --
      --
      -- If the passed in date range is NULL default it.
      --
      Incremental_Update;
      --
    END IF;
    --
  EXCEPTION
    --
    WHEN OTHERS THEN
      --
      OUTPUT('Exception: ' || SQLERRM);
      RAISE;
      --
    --
  END Collect;
  --
  -- ----------------------------------------------------------------------------
  -- |----------------------------------< LOAD >--------------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Main entry point to load the table.
  --
  PROCEDURE Load(p_full_refresh         IN VARCHAR2) IS
    --
    -- Variables required for table truncation.
    --
    l_dummy1        VARCHAR2(2000);
    l_dummy2        VARCHAR2(2000);
    --
  BEGIN
    --
    output('Start:   ' || to_char(sysdate,'HH24:MI:SS'));
    --
    -- Set globals
    --
    -- g_business_group_id := p_business_group_id;
    --
    IF p_full_refresh IS NULL
    THEN
      --
      g_full_refresh := g_not_full_refresh;
      --
    ELSE
      --
      g_full_refresh := p_full_refresh;
      --
    END IF;
    --
    -- Find the schema we are running in.
    --
    IF NOT fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, g_schema)
    THEN
      --
      -- Could not find the schema raising exception.
      --
      output('Could not find schema to run in.');
      --
      -- log('Could not find schema.');
      RAISE NO_DATA_FOUND;
      --
    END IF;
    --
    -- Update information about collection
    --
    -- log('Record process start.');
    hri_bpl_conc_log.record_process_start(g_cncrnt_prgrm_shrtnm);
    --
    -- Time at start
    --
    -- log('collect.');
    --
    -- Get HRI schema name - get_app_info populates l_schema
    --
    -- Insert new records
    --
    collect;
    -- log('collectED.');
    --
    -- Write timing information to log
    --
    output('Finished changes to the table:  '  || to_char(sysdate,'HH24:MI:SS'));
    --
    -- Gather index stats
    --
    fnd_stats.gather_table_stats(g_schema, 'HRI_CS_CO_PGM_CT');
    fnd_stats.gather_table_stats(g_schema, 'HRI_CS_CO_PGMH_PTIP_CT');
    fnd_stats.gather_table_stats(g_schema, 'HRI_CS_CO_PGMH_PLIP_CT');
    fnd_stats.gather_table_stats(g_schema, 'HRI_CS_CO_RPGH_PIRG_CT');
    fnd_stats.gather_table_stats(g_schema, 'HRI_CS_TIME_BENRL_PRD_CT');
    fnd_stats.gather_table_stats(g_schema, 'HRI_CS_CO_PGM_CT');
    --
    -- Write timing information to log
    --
    -- output('Gathered stats:   '  || to_char(sysdate,'HH24:MI:SS'));
    --
    -- Call to HRI_BPL_CONC_LOG.LOG_PROCESS_END inserts record into BIS_REFRESH_LOG
    -- corresponding to concurrent request with start and end times
    --
    hri_bpl_conc_log.log_process_end(
          p_status         => TRUE,
          p_period_from    => TRUNC(to_date('01-01-0001', 'DD-MM-YYYY')),
          p_period_to      => TRUNC(sysdate),
          p_attribute1     => p_full_refresh);
    --
  EXCEPTION
    --
    WHEN OTHERS
    THEN
      --
      ROLLBACK;
      RAISE;
      --
    --
  END Load;
  --
  --
  -- ----------------------------------------------------------------------------
  -- |---------------------------------< LOAD >---------------------------------|
  -- ----------------------------------------------------------------------------
  --
  -- Entry point to be called from the concurrent manager
  --
  PROCEDURE Load(errbuf                 OUT NOCOPY VARCHAR2,
                 retcode                OUT NOCOPY VARCHAR2,
                 p_full_refresh         IN VARCHAR2)
  IS
    --
  BEGIN
    --
    -- Enable output to concurrent request log
    --
    g_conc_request_flag := TRUE;
    --
    load( p_full_refresh         => p_full_refresh);
    --
  EXCEPTION
    --
    WHEN OTHERS THEN
      --
      errbuf  := SQLERRM;
      retcode := SQLCODE;
      --
    --
  END load;
  --
end hri_opl_ben_dim_refresh ;

/

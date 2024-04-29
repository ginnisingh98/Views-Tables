--------------------------------------------------------
--  DDL for Package Body HRI_APL_DGNSTC_OPEN_ENRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_APL_DGNSTC_OPEN_ENRT" AS
/* $Header: hriadgoe.pkb 120.1 2005/11/16 08:53:45 nhunur noship $ */
--
   FUNCTION get_pgm_for_open_le
      RETURN VARCHAR2
   IS
      --
      l_sql_stmt   VARCHAR2 (32000);
      --
   BEGIN
      --
      l_sql_stmt :=
         '
         SELECT pgm.NAME,
                pgm.effective_start_date,
                pgm.effective_end_date,
                meaning status,
                NULL col5
           FROM ben_pgm_f pgm, hr_lookups hl
          WHERE hl.lookup_code = pgm.pgm_stat_cd
            AND hl.lookup_type = ''BEN_STAT''
            AND :p_end_date BETWEEN pgm.effective_start_date
                                AND pgm.effective_end_date
            AND pgm.pgm_typ_cd IN (''CORE'', ''FLEX'', ''FPC'', ''OTHER'')
            AND EXISTS (
                   SELECT 1
                     FROM ben_popl_enrt_typ_cycl_f pet, ben_enrt_perd enp
                    WHERE pet.pgm_id = pgm.pgm_id
                      AND pet.enrt_typ_cycl_cd = ''O''
                      AND :p_end_date BETWEEN pet.effective_start_date
                                          AND pet.effective_end_date
                      AND pet.popl_enrt_typ_cycl_id = enp.popl_enrt_typ_cycl_id)
         ORDER BY pgm.name
         ';
      --
      RETURN l_sql_stmt;
      --
   END get_pgm_for_open_le;
--
   FUNCTION get_actn_itm_for_open_le
      RETURN VARCHAR2
   IS
      --
      l_sql_stmt   VARCHAR2 (32000);
      --
   BEGIN
      --
      l_sql_stmt :=
         '
         SELECT pgm.NAME pgm_name,
                pgm.effective_start_date,
                pgm.effective_end_date,
                eat.NAME, NULL col5
           FROM ben_pgm_f pgm, ben_popl_actn_typ_f pat, ben_actn_typ_tl eat
          WHERE pgm.pgm_id = pat.pgm_id
            AND eat.actn_typ_id = pat.actn_typ_id
            AND eat.LANGUAGE = USERENV (''LANG'')
            AND :p_end_date BETWEEN pgm.effective_start_date
                                AND pgm.effective_end_date
            AND :p_end_date BETWEEN pat.effective_start_date
                                AND pat.effective_end_date
            AND EXISTS (
                   SELECT 1
                     FROM ben_popl_enrt_typ_cycl_f pet, ben_enrt_perd enp
                    WHERE pet.pgm_id = pgm.pgm_id
                      AND pet.enrt_typ_cycl_cd = ''O''
                      AND :p_end_date BETWEEN pet.effective_start_date
                                          AND pet.effective_end_date
                      AND pet.popl_enrt_typ_cycl_id = enp.popl_enrt_typ_cycl_id)
         UNION
         SELECT pgm.NAME pgm_name,
                pgm.effective_start_date,
                pgm.effective_end_date,
                eat.NAME,
                NULL col5
           FROM ben_pgm_f pgm,
                ben_popl_actn_typ_f pat,
                ben_actn_typ_tl eat,
                ben_plip_f cpp
          WHERE pgm.pgm_id = cpp.pgm_id
            AND cpp.pl_id = pat.pl_id
            AND eat.actn_typ_id = pat.actn_typ_id
            AND :p_end_date BETWEEN pgm.effective_start_date
                                AND pgm.effective_end_date
            AND :p_end_date BETWEEN pat.effective_start_date
                                AND pat.effective_end_date
            AND eat.LANGUAGE = USERENV (''LANG'')
            AND EXISTS (
                   SELECT 1
                     FROM ben_popl_enrt_typ_cycl_f pet, ben_enrt_perd enp
                    WHERE pet.pgm_id = pgm.pgm_id
                      AND pet.enrt_typ_cycl_cd = ''O''
                      AND :p_end_date BETWEEN pet.effective_start_date
                                          AND pet.effective_end_date
                      AND pet.popl_enrt_typ_cycl_id = enp.popl_enrt_typ_cycl_id)
         ';
      --
      RETURN l_sql_stmt;
      --
   END get_actn_itm_for_open_le;
--
   FUNCTION get_ben_user_valid_setup
      RETURN VARCHAR2
   IS
      --
      l_sql_stmt   VARCHAR2 (32000);
      --
   BEGIN
      --
      l_sql_stmt :=
         '
         SELECT   usr.user_name,
                  usr.start_date,
                  NULL col3,
                  NULL col4,
                  NULL col5
             FROM fnd_user usr,
                  wf_user_role_assignments waur,
                  wf_local_roles wlr,
                  fnd_responsibility resp
            WHERE resp.responsibility_id = wlr.orig_system_id
              AND resp.responsibility_key = ''HRI_BEN_BENEFITS_MANAGER''
              AND wlr.orig_system = ''FND_RESP''
              AND usr.user_name = waur.user_name
              AND waur.role_name = wlr.NAME
              AND :p_end_date BETWEEN usr.start_date and nvl(usr.end_date,:p_end_date)
         ORDER BY 1
          ';
      --
      RETURN l_sql_stmt;
      --
   END get_ben_user_valid_setup;
--
   FUNCTION get_pgm_witn_no_elctbl_chc
      RETURN VARCHAR2
   IS
      --
      l_sql_stmt   VARCHAR2 (32000);
      --
   BEGIN
      --
      l_sql_stmt :=
         '
         SELECT pgm.name,
                pgm.effective_start_Date,
                pgm.effective_end_date,
                NULL col4,
                NULL col5
           FROM ben_pgm_f pgm, ben_popl_enrt_typ_cycl_f pet, ben_enrt_perd enp
          WHERE pgm.pgm_id = pet.pgm_id
            AND pgm.pgm_typ_cd IN (''CORE'', ''FLEX'', ''FPC'', ''OTHER'')
            AND pet.popl_enrt_typ_cycl_id = enp.popl_enrt_typ_cycl_id
            AND pet.enrt_typ_cycl_cd = ''O''
            AND (enp.enrt_perd_id, enp.asnd_lf_evt_dt, enp.asnd_lf_evt_dt) IN (
                   SELECT enp_inn.enrt_perd_id, enp_inn.asnd_lf_evt_dt,
                          MAX (asnd_lf_evt_dt) OVER ()
                     FROM ben_enrt_perd enp_inn
                    WHERE enp_inn.strt_dt <= :p_end_date
                      AND enp_inn.popl_enrt_typ_cycl_id = pet.popl_enrt_typ_cycl_id)
            AND :p_end_date BETWEEN pgm.effective_start_date
                                AND pgm.effective_end_date
            AND :p_end_date BETWEEN pet.effective_start_date
                                AND pet.effective_end_date
            AND NOT EXISTS (
                   SELECT 1
                     FROM ben_pil_elctbl_chc_popl pel, ben_elig_per_elctbl_chc epe
                    WHERE pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
                      AND epe.elctbl_flag = ''Y''
                      AND pel.PIL_ELCTBL_POPL_STAT_CD <> ''BCKDT''
                      AND pel.pgm_id = pgm.pgm_id
                      AND pel.enrt_perd_id = enp.enrt_perd_id)
         ORDER BY PGM.NAME
                    ';
      --
      RETURN l_sql_stmt;
      --
   END get_pgm_witn_no_elctbl_chc;
--
--
   FUNCTION get_pgm_with_no_actn_item
      RETURN VARCHAR2
   IS
      l_sql_stmt   VARCHAR2 (32000);
   BEGIN
      l_sql_stmt :=
         '
         SELECT pgm.name,
                pgm.effective_start_Date,
                pgm.effective_end_date,
                NULL col4,
                NULL col5
           FROM ben_pgm_f pgm
          WHERE NOT EXISTS (
                   SELECT 1
                     FROM ben_popl_actn_typ_f pat
                    WHERE pat.pgm_id = pgm.pgm_id
                      AND :p_end_date BETWEEN pat.effective_start_date
                                          AND pat.effective_end_date)
            AND NOT EXISTS (
                   SELECT 1
                     FROM ben_popl_actn_typ_f pat, ben_plip_f cpp
                    WHERE cpp.pgm_id = pgm.pgm_id
                      AND pat.pl_id = cpp.pl_id
                      AND :p_end_date BETWEEN pat.effective_start_date
                                          AND pat.effective_end_date
                      AND :p_end_date BETWEEN cpp.effective_start_date
                                          AND cpp.effective_end_date)
            AND EXISTS (
                   SELECT 1
                     FROM ben_popl_enrt_typ_cycl_f pet, ben_enrt_perd enp
                    WHERE pet.pgm_id = pgm.pgm_id
                      AND pet.enrt_typ_cycl_cd = ''O''
                      AND :p_end_date BETWEEN pet.effective_start_date
                                          AND pet.effective_end_date
                      AND pet.popl_enrt_typ_cycl_id = enp.popl_enrt_typ_cycl_id)
            AND pgm.pgm_typ_cd IN (''CORE'', ''FLEX'', ''FPC'', ''OTHER'')
            AND :p_end_date BETWEEN pgm.effective_start_date
                                AND pgm.effective_end_Date
         ORDER BY pgm.name
         ';
      --
      RETURN l_sql_stmt;
      --
   END get_pgm_with_no_actn_item;

--
   FUNCTION get_emp_with_open_mnl_ler
      RETURN VARCHAR2
   IS
      l_sql_stmt   VARCHAR2 (32000);
   BEGIN
      l_sql_stmt :=
         '
         SELECT per.full_name,
                per.employee_number,
                ppl.lf_evt_ocrd_dt,
                NULL col4,
                NULL col5
           FROM per_all_people_f per, ben_ptnl_ler_for_per ppl, ben_ler_f ler
          WHERE per.person_id = ppl.person_id
            AND ppl.ptnl_ler_for_per_stat_cd IN (''MNL'', ''MNLO'')
            AND ppl.ler_id = ler.ler_id
            AND ler.typ_cd = ''SCHEDDO''
            AND :p_end_date BETWEEN ler.effective_start_date
                                AND ler.effective_end_date
            AND :p_end_date BETWEEN per.effective_start_date
                                AND per.effective_end_date
         ORDER BY per.full_name
         ';
      --
      RETURN l_sql_stmt;
      --
   END get_emp_with_open_mnl_ler;

--
   FUNCTION get_pln_with_no_opt
      RETURN VARCHAR2
   IS
      l_sql_stmt   VARCHAR2 (32000);
   BEGIN
      l_sql_stmt :=
         '
         SELECT pgm.NAME PGM_NAME,
                pln.NAME PLN_NAME,
                NULL col3,
                NULL col4,
                NULL col5
           FROM ben_pgm_f pgm, ben_plip_f cpp, ben_pl_f pln
          WHERE pgm.pgm_id = cpp.pgm_id
            AND cpp.pl_id = pln.pl_id
            AND pgm.pgm_typ_cd IN (''CORE'', ''FLEX'', ''FPC'', ''OTHER'')
            AND pln.invk_flx_cr_pl_flag = ''N''
            AND pln.imptd_incm_calc_cd IS NULL
            AND EXISTS (
                   SELECT 1
                     FROM ben_popl_enrt_typ_cycl_f pet, ben_enrt_perd enp
                    WHERE pet.pgm_id = pgm.pgm_id
                      AND pet.enrt_typ_cycl_cd = ''O''
                      AND :p_end_date BETWEEN pet.effective_start_date
                                          AND pet.effective_end_date
                      AND pet.popl_enrt_typ_cycl_id = enp.popl_enrt_typ_cycl_id)
            AND NOT EXISTS (
                   SELECT 1
                     FROM ben_oipl_f cop
                    WHERE cop.pl_id = cpp.pl_id
                      AND :p_end_date BETWEEN cop.effective_start_date
                                          AND cop.effective_end_date)
            AND :p_end_date BETWEEN pgm.effective_start_date
                                AND pgm.effective_end_date
            AND :p_end_date BETWEEN pln.effective_start_date
                                AND pln.effective_end_date
            AND :p_end_date BETWEEN cpp.effective_start_date
                                AND cpp.effective_end_date
         ORDER BY PGM.NAME, PLN.NAME
         ';
      --
      RETURN l_sql_stmt;
      --
   END get_pln_with_no_opt;

--
   FUNCTION pgm_has_pln_with_rqd_actn_item (cv_pgm_id                   number,
                                            cv_end_date                 date,
                                            cv_dpnt_dsgn_lvl_cd         varchar2
                                            )
      RETURN VARCHAR2
   IS
      --
      l_plan_found   VARCHAR2 (32000);
      l_dummy        VARCHAR2 (1);
      --
      CURSOR c_pln
      IS
         SELECT null
           FROM ben_plip_f cpp, ben_pl_f pln
          WHERE cpp.pgm_id = cv_pgm_id
            AND cpp.pl_id = pln.pl_id
            AND pln.invk_flx_cr_pl_flag = 'N'
            AND pln.imptd_incm_calc_cd IS NULL
            AND cv_end_date BETWEEN pln.effective_start_date
                            AND pln.effective_end_date
            AND cv_end_date BETWEEN cpp.effective_start_date
                            AND cpp.effective_end_date
            AND (   pln.bnf_dsgn_cd = 'R'               /* Designate Beneficiary  */
                 OR pln.bnf_adrs_rqd_flag = 'Y'         /* Beneficiary Requires Address */
                 OR pln.bnf_dob_rqd_flag = 'Y'          /* Beneficiary Requires Date of Birth */
                 OR pln.bnf_legv_id_rqd_flag = 'Y'      /* Beneficiary Requires Legislative Identifier */
                 OR pln.bnf_dsge_mnr_ttee_rqd_flag = 'Y'/* Beneficiary requires a Trustee */
                 OR (    pln.bnf_ctfn_rqd_flag = 'N'    /* Beneficiary Requires Certification */
                     AND EXISTS (
                            SELECT 1
                              FROM ben_pl_bnf_ctfn_f pcx
                             WHERE pcx.pl_id = pln.pl_id
                               AND cv_end_date BETWEEN pcx.effective_start_date
                                               AND pcx.effective_end_date)
                    )
                 OR EXISTS  /* Participant / Dependent  Requires Primary Care Physician */
                          (
                       SELECT 1
                         FROM ben_pl_pcp pcp
                        WHERE pcp.pl_id = pln.pl_id
                          AND (   pcp.pcp_dsgn_cd = 'R'
                               OR pcp.pcp_dpnt_dsgn_cd = 'R'
                              ))
                 OR EXISTS /* Enrollment Certification Required - Plan */
                          (
                       SELECT 1
                         FROM ben_enrt_ctfn_f ecf
                        WHERE ecf.pl_id = pln.pl_id
                          AND cv_end_date BETWEEN ecf.effective_start_date
                                          AND ecf.effective_end_date)
                 OR EXISTS /* Enrollment Certification Required - Plan Life Event */
                          (
                       SELECT 1
                         FROM ben_ler_rqrs_enrt_ctfn_f lre,
                              ben_ler_enrt_ctfn_f lnc
                        WHERE lnc.ler_rqrs_enrt_ctfn_id =
                                                lre.ler_rqrs_enrt_ctfn_id
                          AND cv_end_date BETWEEN lnc.effective_start_date
                                          AND lnc.effective_end_date
                          AND cv_end_date BETWEEN lre.effective_start_date
                                          AND lre.effective_end_date
                          AND lre.pl_id = pln.pl_id)
                 OR EXISTS /*       Enrollment Certification Required - Option in Plan*/
                          (
                       SELECT 1
                         FROM ben_oipl_f cop, ben_enrt_ctfn_f ecf
                        WHERE ecf.oipl_id = cop.oipl_id
                          AND cv_end_date BETWEEN ecf.effective_start_date
                                          AND ecf.effective_end_date
                          AND cv_end_date BETWEEN cop.effective_start_date
                                          AND cop.effective_end_date
                          AND cop.pl_id = pln.pl_id)
                 OR EXISTS /* Enrollment Certification Required - Option In Plan Life Event */
                          (
                       SELECT 1
                         FROM ben_oipl_f cop,
                              ben_ler_rqrs_enrt_ctfn_f lre,
                              ben_ler_enrt_ctfn_f lnc
                        WHERE cop.pl_id = pln.pl_id
                          AND cop.oipl_id = lre.oipl_id
                          AND lnc.ler_rqrs_enrt_ctfn_id =
                                                lre.ler_rqrs_enrt_ctfn_id
                          AND cv_end_date BETWEEN lnc.effective_start_date
                                          AND lnc.effective_end_date
                          AND cv_end_date BETWEEN lre.effective_start_date
                                          AND lre.effective_end_date
                          AND cv_end_date BETWEEN cop.effective_start_date
                                          AND cop.effective_end_date)
                 OR (    cv_dpnt_dsgn_lvl_cd = 'PL'
                     AND (   pln.dpnt_dsgn_cd = 'R'             /* Designate Dependent */
                          OR pln.dpnt_leg_id_rqd_flag = 'Y'     /* Dependent Requires Legislative Identifier */
                          OR pln.dpnt_dob_rqd_flag = 'Y'        /* Dependent requires Date of Birth */
                          OR pln.dpnt_adrs_rqd_flag = 'Y'       /* Dependent Requires Address */
                          OR (    pln.dpnt_no_ctfn_rqd_flag = 'N'  /* Dependent Requires Certification */
                              AND EXISTS (
                                     SELECT 1
                                       FROM ben_pl_dpnt_cvg_ctfn_f pnd
                                      WHERE pnd.pl_id = pln.pl_id
                                        AND cv_end_date
                                               BETWEEN pnd.effective_start_date
                                                   AND pnd.effective_end_date)
                             )
                         )
                    )
                );
      --
   BEGIN
      --
      l_plan_found := 'N';
      --
      OPEN c_pln;
        --
        FETCH c_pln INTO L_DUMMY;
        --
        IF c_pln%found
        THEN
           --
           l_plan_found := 'Y';
           --
        ELSE
           --
           l_plan_found := 'N';
           --
        END IF;
        --
      CLOSE c_pln;
      --
      RETURN l_plan_found;
      --
   END pgm_has_pln_with_rqd_actn_item;

--
   FUNCTION get_pgm_with_rqd_actn_item
      RETURN VARCHAR2
   IS
      l_sql_stmt   VARCHAR2 (32000);
   BEGIN
      l_sql_stmt :=
         '
         SELECT name,
                effective_start_Date,
                effective_end_date,
                NULL col4,
                NULL col5
           FROM ben_pgm_f pgm
          WHERE pgm.pgm_typ_cd IN (''CORE'', ''FLEX'', ''FPC'', ''OTHER'')
            AND :p_end_date BETWEEN pgm.effective_start_date AND pgm.effective_end_date
            AND EXISTS (
                   SELECT 1
                     FROM ben_popl_enrt_typ_cycl_f pet, ben_enrt_perd enp
                    WHERE pet.pgm_id = pgm.pgm_id
                      AND pet.enrt_typ_cycl_cd = ''O''
                      AND :p_end_date BETWEEN pet.effective_start_date
                                      AND pet.effective_end_date
                      AND pet.popl_enrt_typ_cycl_id = enp.popl_enrt_typ_cycl_id)
            AND (   (    pgm.dpnt_dsgn_lvl_cd = ''PGM''
                     AND (   pgm.dpnt_dsgn_cd = ''R''                   /* Designate Dependent */
                          OR pgm.dpnt_legv_id_rqd_flag = ''Y''          /* Dependent Requires Legislative Identifier */
                          OR pgm.dpnt_dob_rqd_flag = ''Y''              /* Dependent requires Date of Birth */
                          OR pgm.dpnt_adrs_rqd_flag = ''Y''             /* Dependent Requires Address */
                          OR (    pgm.dpnt_dsgn_no_ctfn_rqd_flag = ''N''/* Dependent Requires Certification */
                              AND EXISTS (
                                     SELECT 1
                                       FROM ben_pgm_dpnt_cvg_ctfn_f pgc
                                      WHERE pgc.pgm_id = pgm.pgm_id
                                        AND :p_end_date BETWEEN pgc.effective_start_date
                                                        AND pgc.effective_end_date)
                             )
                         )
                    )
                 OR hri_apl_dgnstc_open_enrt.pgm_has_pln_with_rqd_actn_item (pgm.pgm_id,
                                                                             :p_end_date ,
                                                                             pgm.dpnt_dsgn_lvl_cd) = ''Y''
                 OR EXISTS (
                       SELECT 1
                         FROM ben_ptip_f ctp
                        WHERE ctp.pgm_id = pgm.pgm_id
                          AND :p_end_date BETWEEN ctp.effective_start_date
                                          AND ctp.effective_end_date
                          AND pgm.dpnt_dsgn_lvl_cd = ''PTIP''
                          AND (   ctp.dpnt_dsgn_cd = ''R''                /* Designate Dependent */
                               OR ctp.dpnt_legv_id_rqd_flag = ''Y''       /* Dependent Requires Legislative Identifier */
                               OR ctp.dpnt_dob_rqd_flag = ''Y''           /* Dependent requires Date of Birth */
                               OR ctp.dpnt_adrs_rqd_flag = ''Y''          /* Dependent Requires Address */
                               OR (    ctp.dpnt_cvg_no_ctfn_rqd_flag = ''N'' /* Dependent Requires Certification */
                                   AND EXISTS (
                                          SELECT 1
                                            FROM ben_ptip_dpnt_cvg_ctfn_f pyd
                                           WHERE pyd.ptip_id = ctp.ptip_id
                                             AND :p_end_date BETWEEN pyd.effective_start_date
                                                             AND pyd.effective_end_date)
                                  )
                              ))
                )
         ORDER BY PGM.NAME
         ';
      --
      RETURN l_sql_stmt;
      --
   END get_pgm_with_rqd_actn_item;

--
   FUNCTION get_pgm_with_inactive_status
      RETURN VARCHAR2
   IS
      l_sql_stmt   VARCHAR2 (32000);
   BEGIN
      l_sql_stmt :=
         '
         SELECT pgm.NAME,
                hl.meaning status,
                NULL col3,
                NULL col4,
                NULL col5
           FROM ben_pgm_f pgm, ben_popl_enrt_typ_cycl_f pet, ben_enrt_perd enp, hr_lookups hl
          WHERE pgm.pgm_id = pet.pgm_id
            AND pgm.pgm_typ_cd IN (''CORE'', ''FLEX'', ''FPC'', ''OTHER'')
            AND pet.popl_enrt_typ_cycl_id = enp.popl_enrt_typ_cycl_id
            AND pet.enrt_typ_cycl_cd = ''O''
            AND (enp.enrt_perd_id, enp.asnd_lf_evt_dt, enp.asnd_lf_evt_dt) IN (
                   SELECT enp_inn.enrt_perd_id, enp_inn.asnd_lf_evt_dt,
                          MAX (asnd_lf_evt_dt) OVER ()
                     FROM ben_enrt_perd enp_inn
                    WHERE enp_inn.strt_dt <= :p_end_date
                      AND enp_inn.popl_enrt_typ_cycl_id = pet.popl_enrt_typ_cycl_id)
            AND enp.strt_dt BETWEEN pgm.effective_start_date AND pgm.effective_end_date
            AND pgm.pgm_stat_cd IN (''I'', ''P'', ''C'')
            AND :p_end_date BETWEEN pet.effective_start_date AND pet.effective_end_date
            and hl.lookup_type = ''BEN_STAT''
            and hl.lookup_code = pgm.pgm_stat_Cd
         ORDER BY PGM.NAME
         ';
      --
      RETURN l_sql_stmt;
      --
   END get_pgm_with_inactive_status;
--
END hri_apl_dgnstc_open_enrt;

/

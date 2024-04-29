--------------------------------------------------------
--  DDL for Package Body BEN_ENROLMENT_REQUIREMENTS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENROLMENT_REQUIREMENTS1" AS
/* $Header: bendenr1.pkb 120.2.12010000.2 2008/08/05 14:38:34 ubhat ship $ */
-------------------------------------------------------------------------------
/*
+=============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                 |
|                          Redwood Shores, California, USA                    |
|                               All rights reserved.                          |
+=============================================================================+
--
History
     Date       Who          Version   What?
     ----       ---          -------   -----
     24 Jan 06  mhoyes       115.0     Created.
     13-Feb-05  mhoyes       115.4   - bug5031107. Moved locally defined procedures
                                       to ben_enrolment_requirements1.
     28-Apr-05  mhoyes       115.5   - bug5152911. Added GetPenPerIDMxESD.
                                       Re-wrote cursor c_getpenesd in plsql.
*/
-------------------------------------------------------------------------------
PROCEDURE determine_ben_settings(
  p_pl_id                     IN     ben_ler_chg_pl_nip_enrt_f.pl_id%TYPE,
  p_ler_id                    IN     ben_ler_chg_pl_nip_enrt_f.ler_id%TYPE,
  p_lf_evt_ocrd_dt            IN     DATE,
  p_ptip_id                   IN     ben_ler_chg_ptip_enrt_f.ptip_id%TYPE,
  p_pgm_id                    IN     ben_ler_chg_pgm_enrt_f.pgm_id%TYPE,
  p_plip_id                   IN     ben_ler_chg_plip_enrt_f.plip_id%TYPE,
  p_oipl_id                   IN     ben_ler_chg_oipl_enrt_f.oipl_id%TYPE,
  p_just_prclds_chg_flag      IN     BOOLEAN DEFAULT FALSE,
  p_enrt_cd                   OUT NOCOPY    ben_ler_chg_oipl_enrt_f.enrt_cd%TYPE,
  p_enrt_rl                   OUT NOCOPY    ben_ler_chg_oipl_enrt_f.enrt_rl%TYPE,
  p_auto_enrt_mthd_rl         OUT NOCOPY    ben_ler_chg_oipl_enrt_f.auto_enrt_mthd_rl%TYPE,
  p_crnt_enrt_prclds_chg_flag OUT NOCOPY    ben_ler_chg_oipl_enrt_f.crnt_enrt_prclds_chg_flag%TYPE,
  p_dflt_flag                 OUT NOCOPY    ben_ler_chg_oipl_enrt_f.dflt_flag%TYPE,
  p_enrt_mthd_cd              OUT NOCOPY    ben_ler_chg_pgm_enrt_f.enrt_mthd_cd%TYPE,
  p_stl_elig_cant_chg_flag    OUT NOCOPY    ben_ler_chg_oipl_enrt_f.stl_elig_cant_chg_flag%TYPE,
  p_tco_chg_enrt_cd           OUT NOCOPY    ben_ler_chg_ptip_enrt_f.tco_chg_enrt_cd%TYPE,
  p_ler_chg_oipl_found_flag   OUT NOCOPY    VARCHAR2,
  p_ler_chg_found_flag        OUT NOCOPY    VARCHAR2,
  p_enrt_cd_level             OUT NOCOPY    VARCHAR2 ) IS
  -- ========================
  -- define the local cursors
  -- ========================
  CURSOR csr_oipl IS
    SELECT   oipl.auto_enrt_flag,
             oipl.auto_enrt_mthd_rl,
             oipl.crnt_enrt_prclds_chg_flag,
             oipl.dflt_flag,
             oipl.enrt_cd,
             oipl.enrt_rl,
             oipl.ler_chg_oipl_enrt_id,
             oipl.stl_elig_cant_chg_flag
    FROM     ben_ler_chg_oipl_enrt_f oipl
    WHERE    oipl.oipl_id = p_oipl_id
    AND      oipl.ler_id = p_ler_id
    AND      p_lf_evt_ocrd_dt BETWEEN oipl.effective_start_date
                 AND oipl.effective_end_date;
  --
  CURSOR csr_pgm IS
    SELECT   pgm.auto_enrt_mthd_rl,
             pgm.crnt_enrt_prclds_chg_flag,
             pgm.enrt_cd,
             pgm.enrt_mthd_cd,
             pgm.enrt_rl,
             pgm.ler_chg_pgm_enrt_id,
             pgm.stl_elig_cant_chg_flag
    FROM     ben_ler_chg_pgm_enrt_f pgm
    WHERE    pgm.pgm_id = p_pgm_id
    AND      pgm.ler_id = p_ler_id
    AND      p_lf_evt_ocrd_dt BETWEEN pgm.effective_start_date
                 AND pgm.effective_end_date;
  --
  CURSOR csr_ptip IS
    SELECT   ptip.crnt_enrt_prclds_chg_flag,
             ptip.enrt_cd,
             ptip.enrt_mthd_cd,
             ptip.enrt_rl,
             ptip.ler_chg_ptip_enrt_id,
             ptip.stl_elig_cant_chg_flag,
             ptip.tco_chg_enrt_cd
    FROM     ben_ler_chg_ptip_enrt_f ptip
    WHERE    ptip.ptip_id = p_ptip_id
    AND      ptip.ler_id = p_ler_id
    AND      p_lf_evt_ocrd_dt BETWEEN ptip.effective_start_date
                 AND ptip.effective_end_date;
  --
  CURSOR csr_plip IS
    SELECT   plip.auto_enrt_mthd_rl,
             plip.crnt_enrt_prclds_chg_flag,
             plip.dflt_flag,
             plip.enrt_cd,
             plip.enrt_mthd_cd,
             plip.enrt_rl,
             plip.ler_chg_plip_enrt_id,
             plip.stl_elig_cant_chg_flag,
             plip.tco_chg_enrt_cd
    FROM     ben_ler_chg_plip_enrt_f plip
    WHERE    plip.plip_id = p_plip_id
    AND      plip.ler_id = p_ler_id
    AND      p_lf_evt_ocrd_dt BETWEEN plip.effective_start_date
                 AND plip.effective_end_date;
  --
  CURSOR csr_pl_nip IS
    SELECT   pl_nip.auto_enrt_mthd_rl,
             pl_nip.crnt_enrt_prclds_chg_flag,
             pl_nip.dflt_flag,
             pl_nip.enrt_cd,
             pl_nip.enrt_mthd_cd,
             pl_nip.enrt_rl,
             pl_nip.ler_chg_pl_nip_enrt_id,
             pl_nip.stl_elig_cant_chg_flag,
             pl_nip.tco_chg_enrt_cd
    FROM     ben_ler_chg_pl_nip_enrt_f pl_nip
    WHERE    pl_nip.pl_id = p_pl_id
    AND      pl_nip.ler_id = p_ler_id
    AND      p_lf_evt_ocrd_dt BETWEEN pl_nip.effective_start_date
                 AND pl_nip.effective_end_date;
  -- ======================
  -- define local variables
  -- ======================
  oipl_auto_enrt_flag            ben_ler_chg_oipl_enrt_f.auto_enrt_flag%TYPE;
  oipl_auto_enrt_mthd_rl         ben_ler_chg_oipl_enrt_f.auto_enrt_mthd_rl%TYPE;
  oipl_crnt_enrt_prclds_chg_flag ben_ler_chg_oipl_enrt_f.crnt_enrt_prclds_chg_flag%TYPE;
  oipl_dflt_flag                 ben_ler_chg_oipl_enrt_f.dflt_flag%TYPE;
  oipl_enrt_cd                   ben_ler_chg_oipl_enrt_f.enrt_cd%TYPE;
  oipl_enrt_rl                   ben_ler_chg_oipl_enrt_f.enrt_rl%TYPE;
  oipl_ler_chg_oipl_enrt_id      ben_ler_chg_oipl_enrt_f.ler_chg_oipl_enrt_id%TYPE;
  oipl_stl_elig_cant_chg_flag    ben_ler_chg_oipl_enrt_f.stl_elig_cant_chg_flag%TYPE;
  pgm_auto_enrt_mthd_rl          ben_ler_chg_pgm_enrt_f.auto_enrt_mthd_rl%TYPE;
  pgm_crnt_enrt_prclds_chg_flag  ben_ler_chg_pgm_enrt_f.crnt_enrt_prclds_chg_flag%TYPE;
  pgm_enrt_cd                    ben_ler_chg_pgm_enrt_f.enrt_cd%TYPE;
  pgm_enrt_mthd_cd               ben_ler_chg_pgm_enrt_f.enrt_mthd_cd%TYPE;
  pgm_enrt_rl                    ben_ler_chg_pgm_enrt_f.enrt_rl%TYPE;
  pgm_ler_chg_pgm_enrt_id        ben_ler_chg_pgm_enrt_f.ler_chg_pgm_enrt_id%TYPE;
  pgm_stl_elig_cant_chg_flag     ben_ler_chg_pgm_enrt_f.stl_elig_cant_chg_flag%TYPE;
  pnip_auto_enrt_mthd_rl         ben_ler_chg_pl_nip_enrt_f.auto_enrt_mthd_rl%TYPE;
  pnip_crnt_enrt_prclds_chg_flag ben_ler_chg_pl_nip_enrt_f.crnt_enrt_prclds_chg_flag%TYPE;
  pnip_dflt_flag                 ben_ler_chg_pl_nip_enrt_f.dflt_flag%TYPE;
  pnip_enrt_cd                   ben_ler_chg_pl_nip_enrt_f.enrt_cd%TYPE;
  pnip_enrt_mthd_cd              ben_ler_chg_pl_nip_enrt_f.enrt_mthd_cd%TYPE;
  pnip_enrt_rl                   ben_ler_chg_pl_nip_enrt_f.enrt_rl%TYPE;
  pnip_ler_chg_pnip_enrt_id      ben_ler_chg_pl_nip_enrt_f.ler_chg_pl_nip_enrt_id%TYPE;
  pnip_stl_elig_cant_chg_flag    ben_ler_chg_pl_nip_enrt_f.stl_elig_cant_chg_flag%TYPE;
  pnip_tco_chg_enrt_cd           ben_ler_chg_pl_nip_enrt_f.tco_chg_enrt_cd%TYPE;
  plip_auto_enrt_mthd_rl         ben_ler_chg_plip_enrt_f.auto_enrt_mthd_rl%TYPE;
  plip_crnt_enrt_prclds_chg_flag ben_ler_chg_plip_enrt_f.crnt_enrt_prclds_chg_flag%TYPE;
  plip_dflt_flag                 ben_ler_chg_plip_enrt_f.dflt_flag%TYPE;
  plip_enrt_cd                   ben_ler_chg_plip_enrt_f.enrt_cd%TYPE;
  plip_enrt_mthd_cd              ben_ler_chg_plip_enrt_f.enrt_mthd_cd%TYPE;
  plip_enrt_rl                   ben_ler_chg_plip_enrt_f.enrt_rl%TYPE;
  plip_ler_chg_plip_enrt_id      ben_ler_chg_plip_enrt_f.ler_chg_plip_enrt_id%TYPE;
  plip_stl_elig_cant_chg_flag    ben_ler_chg_plip_enrt_f.stl_elig_cant_chg_flag%TYPE;
  plip_tco_chg_enrt_cd           ben_ler_chg_plip_enrt_f.tco_chg_enrt_cd%TYPE;
  ptip_crnt_enrt_prclds_chg_flag ben_ler_chg_ptip_enrt_f.crnt_enrt_prclds_chg_flag%TYPE;
  ptip_enrt_cd                   ben_ler_chg_ptip_enrt_f.enrt_cd%TYPE;
  ptip_enrt_mthd_cd              ben_ler_chg_ptip_enrt_f.enrt_mthd_cd%TYPE;
  ptip_enrt_rl                   ben_ler_chg_ptip_enrt_f.enrt_rl%TYPE;
  ptip_ler_chg_ptip_enrt_id      ben_ler_chg_ptip_enrt_f.ler_chg_ptip_enrt_id%TYPE;
  ptip_stl_elig_cant_chg_flag    ben_ler_chg_ptip_enrt_f.stl_elig_cant_chg_flag%TYPE;
  ptip_tco_chg_enrt_cd           ben_ler_chg_ptip_enrt_f.tco_chg_enrt_cd%TYPE;
BEGIN
  --
  g_debug := hr_utility.debug_enabled;
  --
-- ============================================
-- open,fetch and close each cursor if required
-- ============================================
  IF p_ler_id IS NOT NULL THEN
    IF p_oipl_id IS NOT NULL THEN
      OPEN csr_oipl;
      FETCH csr_oipl INTO oipl_auto_enrt_flag,
                          oipl_auto_enrt_mthd_rl,
                          oipl_crnt_enrt_prclds_chg_flag,
                          oipl_dflt_flag,
                          oipl_enrt_cd,
                          oipl_enrt_rl,
                          oipl_ler_chg_oipl_enrt_id,
                          oipl_stl_elig_cant_chg_flag;
      CLOSE csr_oipl;
    END IF;
    IF p_pl_id IS NOT NULL THEN
      OPEN csr_pl_nip;
      FETCH csr_pl_nip INTO pnip_auto_enrt_mthd_rl,
                            pnip_crnt_enrt_prclds_chg_flag,
                            pnip_dflt_flag,
                            pnip_enrt_cd,
                            pnip_enrt_mthd_cd,
                            pnip_enrt_rl,
                            pnip_ler_chg_pnip_enrt_id,
                            pnip_stl_elig_cant_chg_flag,
                            pnip_tco_chg_enrt_cd;
      CLOSE csr_pl_nip;
    END IF;
    IF p_plip_id IS NOT NULL THEN
      OPEN csr_plip;
      FETCH csr_plip INTO plip_auto_enrt_mthd_rl,
                          plip_crnt_enrt_prclds_chg_flag,
                          plip_dflt_flag,
                          plip_enrt_cd,
                          plip_enrt_mthd_cd,
                          plip_enrt_rl,
                          plip_ler_chg_plip_enrt_id,
                          plip_stl_elig_cant_chg_flag,
                          plip_tco_chg_enrt_cd;
      CLOSE csr_plip;
    END IF;
    IF p_ptip_id IS NOT NULL THEN
      OPEN csr_ptip;
      FETCH csr_ptip INTO ptip_crnt_enrt_prclds_chg_flag,
                          ptip_enrt_cd,
                          ptip_enrt_mthd_cd,
                          ptip_enrt_rl,
                          ptip_ler_chg_ptip_enrt_id,
                          ptip_stl_elig_cant_chg_flag,
                          ptip_tco_chg_enrt_cd;
      CLOSE csr_ptip;
    END IF;
    IF p_pgm_id IS NOT NULL THEN
      OPEN csr_pgm;
      FETCH csr_pgm INTO pgm_auto_enrt_mthd_rl,
                         pgm_crnt_enrt_prclds_chg_flag,
                         pgm_enrt_cd,
                         pgm_enrt_mthd_cd,
                         pgm_enrt_rl,
                         pgm_ler_chg_pgm_enrt_id,
                         pgm_stl_elig_cant_chg_flag;
      CLOSE csr_pgm;
    END IF;
    -- ==========================================
    -- determine and SET the OUT parameter values
    -- ==========================================
    -- --------------------------------
    -- set: p_crnt_enrt_prclds_chg_flag
    -- --------------------------------
    IF oipl_crnt_enrt_prclds_chg_flag IS NULL THEN
      IF pnip_crnt_enrt_prclds_chg_flag IS NULL THEN
        IF plip_crnt_enrt_prclds_chg_flag IS NULL THEN
          IF ptip_crnt_enrt_prclds_chg_flag IS NULL THEN
            p_crnt_enrt_prclds_chg_flag :=  pgm_crnt_enrt_prclds_chg_flag;
          ELSE
            p_crnt_enrt_prclds_chg_flag :=  ptip_crnt_enrt_prclds_chg_flag;
          END IF;
        ELSE
          p_crnt_enrt_prclds_chg_flag :=  plip_crnt_enrt_prclds_chg_flag;
        END IF;
      ELSE
        p_crnt_enrt_prclds_chg_flag :=  pnip_crnt_enrt_prclds_chg_flag;
      END IF;
    ELSE
      p_crnt_enrt_prclds_chg_flag :=  oipl_crnt_enrt_prclds_chg_flag;
    END IF;
    -- test to see if only the p_crnt_enrt_prclds_chg_flag is required
    --IF p_just_prclds_chg_flag THEN
    --  RETURN;
    --END IF;
    -- ----------------------------
    -- set: p_enrt_cd and p_enrt_rl
    -- ----------------------------
    --
   if g_debug then
     hr_utility.set_location( 'oipl' || oipl_enrt_cd , 10) ;
     hr_utility.set_location( 'pl' || pnip_enrt_cd , 10) ;
     hr_utility.set_location( 'plip' || plip_enrt_cd , 10);
     hr_utility.set_location( 'ptip' || ptip_enrt_cd , 10) ;
     hr_utility.set_location( 'oipl id ' || p_oipl_id , 10) ;
     hr_utility.set_location( 'ptip id ' || p_ptip_id , 10) ;
     hr_utility.set_location( 'plip id ' || p_plip_id , 10) ;
   end if;
   --
      IF oipl_enrt_cd IS NULL THEN
      IF pnip_enrt_cd IS NULL THEN
        IF plip_enrt_cd IS NULL THEN
          IF ptip_enrt_cd IS NULL THEN
            p_enrt_cd      :=  pgm_enrt_cd;
            p_enrt_rl      :=  pgm_enrt_rl;
            p_enrt_cd_level:= 'PGM' ;
          ELSE
            p_enrt_cd :=  ptip_enrt_cd;
            p_enrt_rl :=  ptip_enrt_rl;
            p_enrt_cd_level := 'PTIP' ;
          END IF;
        ELSE
          p_enrt_cd :=  plip_enrt_cd;
          p_enrt_rl :=  plip_enrt_rl;
          p_enrt_cd_level := 'PLIP' ;
        END IF;
      ELSE
        p_enrt_cd :=  pnip_enrt_cd;
        p_enrt_rl :=  pnip_enrt_rl;
        p_enrt_cd_level := 'PL' ;
      END IF;
    ELSE
      p_enrt_cd :=  oipl_enrt_cd;
      p_enrt_rl :=  oipl_enrt_rl;
      p_enrt_cd_level := 'OIPL' ;
    END IF;
    --
    if g_debug then
      hr_utility.set_location( 'p_enrt_cd_level  ' || p_enrt_cd_level , 10) ;
    end if;
    --
     IF p_just_prclds_chg_flag THEN
      RETURN;
    END IF;

    -- ------------------------
    -- set: p_auto_enrt_mthd_rl
    -- ------------------------
    IF oipl_auto_enrt_mthd_rl IS NULL THEN
      IF pnip_auto_enrt_mthd_rl IS NULL THEN
        IF plip_auto_enrt_mthd_rl IS NULL THEN
          p_auto_enrt_mthd_rl :=  pgm_auto_enrt_mthd_rl;
        ELSE
          p_auto_enrt_mthd_rl :=  plip_auto_enrt_mthd_rl;
        END IF;
      ELSE
        p_auto_enrt_mthd_rl :=  pnip_auto_enrt_mthd_rl;
      END IF;
    ELSE
      p_auto_enrt_mthd_rl :=  oipl_auto_enrt_mthd_rl;
    END IF;
    -- ----------------
    -- set: p_dflt_flag
    -- ----------------
    IF oipl_dflt_flag IS NULL THEN
      IF pnip_dflt_flag IS NULL THEN
        p_dflt_flag :=  plip_dflt_flag;
      ELSE
        p_dflt_flag :=  pnip_dflt_flag;
      END IF;
    ELSE
      p_dflt_flag :=  oipl_dflt_flag;
    END IF;
    -- -------------------
    -- set: p_enrt_mthd_cd
    -- -------------------
    IF oipl_auto_enrt_flag = 'Y' THEN
      p_enrt_mthd_cd :=  'A';
    ELSIF oipl_auto_enrt_flag = 'N' THEN
      p_enrt_mthd_cd :=  'E';
    ELSE
      IF pnip_enrt_mthd_cd IS NULL THEN
        IF plip_enrt_mthd_cd IS NULL THEN
          IF ptip_enrt_mthd_cd IS NULL THEN
            p_enrt_mthd_cd :=  pgm_enrt_mthd_cd;
          ELSE
            p_enrt_mthd_cd :=  ptip_enrt_mthd_cd;
          END IF;
        ELSE
          p_enrt_mthd_cd :=  plip_enrt_mthd_cd;
        END IF;
      ELSE
        p_enrt_mthd_cd :=  pnip_enrt_mthd_cd;
      END IF;
    END IF;
    -- -----------------------------
    -- set: p_stl_elig_cant_chg_flag
    -- -----------------------------
    IF oipl_stl_elig_cant_chg_flag IS NULL THEN
      IF pnip_stl_elig_cant_chg_flag IS NULL THEN
        IF plip_stl_elig_cant_chg_flag IS NULL THEN
          IF ptip_stl_elig_cant_chg_flag IS NULL THEN
            p_stl_elig_cant_chg_flag :=  pgm_stl_elig_cant_chg_flag;
          ELSE
            p_stl_elig_cant_chg_flag :=  ptip_stl_elig_cant_chg_flag;
          END IF;
        ELSE
          p_stl_elig_cant_chg_flag :=  plip_stl_elig_cant_chg_flag;
        END IF;
      ELSE
        p_stl_elig_cant_chg_flag :=  pnip_stl_elig_cant_chg_flag;
      END IF;
    ELSE
      p_stl_elig_cant_chg_flag :=  oipl_stl_elig_cant_chg_flag;
    END IF;
    -- ----------------------
    -- set: p_tco_chg_enrt_cd
    -- ----------------------
    IF pnip_tco_chg_enrt_cd IS NULL THEN
      IF plip_tco_chg_enrt_cd IS NULL THEN
        p_tco_chg_enrt_cd :=  ptip_tco_chg_enrt_cd;
      ELSE
        p_tco_chg_enrt_cd :=  plip_tco_chg_enrt_cd;
      END IF;
    ELSE
      p_tco_chg_enrt_cd :=  pnip_tco_chg_enrt_cd;
    END IF;
    -- -------------------------------------------------------
    -- set: p_ler_chg_oipl_found_flag and p_ler_chg_found_flag
    -- -------------------------------------------------------
    IF oipl_ler_chg_oipl_enrt_id IS NULL THEN
      p_ler_chg_oipl_found_flag :=  'N';
      IF     plip_ler_chg_plip_enrt_id IS NULL
         AND ptip_ler_chg_ptip_enrt_id IS NULL
         AND pnip_ler_chg_pnip_enrt_id IS NULL
         AND pgm_ler_chg_pgm_enrt_id IS NULL THEN
        p_ler_chg_found_flag :=  'N';
      ELSE
        p_ler_chg_found_flag :=  'Y';
      END IF;
    ELSE
      p_ler_chg_oipl_found_flag :=  'Y';
      p_ler_chg_found_flag :=       'Y';
    END IF;
  END IF;
  --
  if g_debug then
    hr_utility.set_location( 'p_enrt_cd_level  ' || p_enrt_cd_level , 10) ;
  end if;
  --
exception
  --
  when others then
    --
    p_enrt_cd                   := null;
    p_enrt_rl                   := null;
    p_auto_enrt_mthd_rl         := null;
    p_crnt_enrt_prclds_chg_flag := null;
    p_dflt_flag                 := null;
    p_enrt_mthd_cd              := null;
    p_stl_elig_cant_chg_flag    := null;
    p_tco_chg_enrt_cd           := null;
    p_ler_chg_oipl_found_flag   := null;
    p_ler_chg_found_flag        := null;
    raise;
    --
END determine_ben_settings;
--
procedure GetPenPerIDMxESD
  (p_person_id             number
  ,p_business_group_id     number
  --
  ,p_penmxesd          out nocopy date
  )
is
  --
  type g_date_table is varray(10000) of date;
  --
  l_penesd_va    g_date_table     := g_date_table();
  l_penectdt_va  g_date_table     := g_date_table();
  --
  cursor c_getpenesd
    (c_bgp_id  number
    ,c_per_id  number
    )
  is
    select /*+ c_getpenesd ben_enrolment_requirements1 */
           rslt.effective_start_date,
           rslt.enrt_cvg_thru_dt
    from   ben_prtt_enrt_rslt_f rslt,ben_ler_f ler
    where  rslt.person_id = c_per_id
    and ler.ler_id=rslt.ler_id
    and rslt.prtt_enrt_rslt_stat_cd is null
    and   ler.typ_cd   not in ('COMP','ABS', 'GSP', 'IREC','SCHEDDU' )
    and    rslt.business_group_id = c_bgp_id;
  --
  l_mxpenesd  date;
  l_lertyp_cd varchar2(100);
  l_match     boolean;
  --
begin
  --
  open c_getpenesd
    (c_bgp_id => p_business_group_id
    ,c_per_id => p_person_id
    );
  fetch c_getpenesd BULK COLLECT INTO l_penesd_va, l_penectdt_va;
  close c_getpenesd;
  --
  if l_penesd_va.count > 0
  then
    --
    l_mxpenesd := hr_api.g_sot;
    --
    for vaen in l_penesd_va.first..l_penesd_va.last
    loop
      --
      if nvl(l_penectdt_va(vaen),hr_api.g_sot) = hr_api.g_eot
      then
        --
        if nvl(l_penesd_va(vaen),hr_api.g_sot) > l_mxpenesd
        then
          --
          l_mxpenesd := l_penesd_va(vaen);
          --
        end if;
        --
      end if;
      --
    end loop;
    --
  else
    --
    l_mxpenesd := null;
    --
  end if;
  --
  p_penmxesd := l_mxpenesd;
  --
end GetPenPerIDMxESD;
--
procedure enrt_perd_strt_dt
  (p_person_id 				in 	number
   ,p_lf_evt_ocrd_dt 			in 	date
   ,p_enrt_perd_det_ovrlp_bckdt_cd 	in 	varchar2
   ,p_business_group_id                 in      number
   ,p_ler_id                            in      number
   ,p_effective_date                    in      date
   ,p_rec_enrt_perd_strt_dt 		in out 	nocopy date
   )
IS
  -- local variables
  l_proc             varchar2 (72) := 'ben_enrolment_requirements1.enrt_perd_strt_dt';
  l_latest_procd_dt  date;
  l_backed_out_date  date;
  l_latest_enrt_dt   date;
  l_lf_evt_ocrd_dt   date := NVL(p_lf_evt_ocrd_dt, p_effective_date);
  -- store sysdate sans the time component into a local variable for once
  l_sysdate          date := trunc(sysdate);
  -- define cursors
  CURSOR c_get_latest_procd_dt IS
    SELECT   MAX(pil.procd_dt)
    FROM     ben_per_in_ler pil
            -- CWB changes
            ,ben_ler_f      ler
    WHERE    pil.person_id = p_person_id
    AND      pil.ler_id    = ler.ler_id
    and      ler.typ_cd   not in ('COMP','ABS', 'GSP', 'IREC','SCHEDDU')
    and      l_lf_evt_ocrd_dt between
             ler.effective_start_date and ler.effective_end_date
    AND      pil.business_group_id = p_business_group_id
    AND      pil.per_in_ler_stat_cd NOT IN ('BCKDT', 'VOIDD')
    AND      pil.procd_dt IS NOT NULL;
  --
  CURSOR c_backed_out_ler IS
    SELECT   MAX(pil.bckt_dt)
    FROM     ben_per_in_ler pil
            -- CWB changes
            ,ben_ler_f      ler
            ,ben_ptnl_ler_for_per  plr
    WHERE    pil.person_id = p_person_id
    AND      pil.ler_id    = ler.ler_id
    and      ler.typ_cd   not in ('COMP','ABS', 'GSP', 'IREC','SCHEDDU')
    and      l_lf_evt_ocrd_dt between
             ler.effective_start_date and ler.effective_end_date
    AND      pil.business_group_id = p_business_group_id
    AND      pil.ler_id = p_ler_id
    AND      pil.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
    AND      pil.bckt_dt IS NOT NULL
    and      pil.per_in_ler_stat_cd = 'BCKDT' -- 3063867
    and      pil.ptnl_ler_for_per_id   = plr.ptnl_ler_for_per_id  --3248770
    and      plr.ptnl_ler_for_per_stat_cd <> 'VOIDD' ;
  --

  -- 2746865
  -- cursor to select a person's maximum enrollment start date
  -- Changed the following cursor for bug 3137519 to exclude GSP/ABS/COMP ler types.
  -- Also included status no in backdt/voidd clause
  --bug#3697378 - discussed with Phil why we add + 1 to the latest enrollment
  --however he wanted this to be removed so that self service open enrollment
  --will not be impacted and asked find ways to show history on enrollment results later
  cursor c_get_latest_enrt_dt is
    select max(rslt.effective_start_date)
    from   ben_prtt_enrt_rslt_f rslt,ben_ler_f ler
     where  rslt.person_id = p_person_id
    and ler.ler_id=rslt.ler_id
  --  and rslt.prtt_enrt_rslt_stat_cd NOT IN ('BCKDT', 'VOIDD')
    and rslt.prtt_enrt_rslt_stat_cd is null
    and   ler.typ_cd   not in ('COMP','ABS', 'GSP', 'IREC','SCHEDDU' )
    and    rslt.business_group_id = p_business_group_id
    and rslt.enrt_cvg_thru_dt = hr_api.g_eot; -- Bug 4388226 - End-dated suspended enrl shudn't be picked up.

  --

  begin

  -- following are the 4 codes used for enrt. period determination
  -------------------------------------------------------------------------
  -- L_EPSD_PEPD 	- Later of Enrollment period start date and
  --		 	  prior event processed date
  -- L_EPSD_PEESD 	- Later of Enrollment period start date and
  --		 	  One day after prior event elections start date
  -- L_EPSD_PEESD_BCKDT - Later of Enrollment period start date and One
  --			  day after prior event elections start date and
  --			  current events backed out date
  -- L_EPSD_PEESD_SYSDT - Later of Enrollment period start date and One
  --			  day after prior event elections start date
  --			  and system date
  -------------------------------------------------------------------------
  -- if cd is L_EPSD_PEPD, use the old logic
  --
  if g_debug then
    hr_utility.set_location(' Entering '||l_proc, 10);
    --
    -- remove all these debug messages
    hr_utility.set_location(' p_enrt_perd_det_ovrlp_bckdt_cd is  '||p_enrt_perd_det_ovrlp_bckdt_cd, 987);
    hr_utility.set_location(' p_person_id '||p_person_id, 10);
    hr_utility.set_location(' p_lf_evt_ocrd_dt '||p_lf_evt_ocrd_dt, 10);
    hr_utility.set_location(' p_ler_id '||p_ler_id, 10);
    hr_utility.set_location(' p_effective_date '||p_effective_date, 10);
    hr_utility.set_location(' p_rec_enrt_perd_strt_dt '||p_rec_enrt_perd_strt_dt, 10);
  end if;
  --

  IF nvl(p_enrt_perd_det_ovrlp_bckdt_cd, 'L_EPSD_PEPD') = 'L_EPSD_PEPD' THEN
    --
    hr_utility.set_location(' L_EPSD_PEPD', 987);
    OPEN c_get_latest_procd_dt;
    FETCH c_get_latest_procd_dt INTO l_latest_procd_dt;
    -- new epsd is greater of epsd or latest_procd_dt
    -- IF c_get_latest_procd_dt%FOUND THEN
    IF l_latest_procd_dt IS NOT NULL THEN
      hr_utility.set_location(' c_get_latest_procd_dt%found', 987);
      hr_utility.set_location('l_latest_procd_dt is '||l_latest_procd_dt, 987);
      -- jcarpent 1/4/2001 bug 1568555, removed +1 from line below
      IF p_rec_enrt_perd_strt_dt < l_latest_procd_dt THEN
        hr_utility.set_location('l_latest_procd_dt made enrt strt dt ', 987);
        -- jcarpent 1/4/2001 bug 1568555, removed +1 from line below
        p_rec_enrt_perd_strt_dt :=  l_latest_procd_dt;
        -- if the enrollment  exist for the previous LE
        -- start the window latest_procd_dt + 1
        -- or the previous enrollment will be updated in correction mode
        -- and backout of this LE will remove the previous LE results
        --the  changes are backedout  3086161
        --
        --Bugs 3972973 and 3978745 fixes.
        --If the enrollment starts after the processed date we need to consider the
        --latest enrollment date.
        --
      End IF;
      --bug#4478186 - enrl start date should always be equal or greater to latest
      --enrt dt
      --
      -- 5152911
      --
      ben_enrolment_requirements1.GetPenPerIDMxESD
        (p_person_id         => p_person_id
        ,p_business_group_id => p_business_group_id
        --
        ,p_penmxesd          => l_latest_enrt_dt
        );
/* 5152911
      OPEN c_get_latest_enrt_dt;
      FETCH c_get_latest_enrt_dt into l_latest_enrt_dt;
      close c_get_latest_enrt_dt ;
*/
      --
      if l_latest_enrt_dt is not null and  l_latest_enrt_dt > p_rec_enrt_perd_strt_dt then
         p_rec_enrt_perd_strt_dt := l_latest_enrt_dt ;
      end if ;
        --
    END IF;
    CLOSE c_get_latest_procd_dt;
    -- 4 is new epsd <= p_lf_evt_ocrd_dt?
    IF p_rec_enrt_perd_strt_dt <= p_lf_evt_ocrd_dt THEN
      -- 5 is there a backed out le for the current ler and ...
      OPEN c_backed_out_ler;
      FETCH c_backed_out_ler INTO l_backed_out_date;
      --IF c_backed_out_ler%FOUND THEN
      IF l_backed_out_date is NOT NULL THEN
        hr_utility.set_location(' c_backed_out_ler%found', 987);
        hr_utility.set_location('l_backed_out_date is '||l_backed_out_date, 987);
        -- 5a ... and is the backed-out date > than the new epsd?
        IF l_backed_out_date > p_rec_enrt_perd_strt_dt THEN
          hr_utility.set_location('l_backed_out_date made enrt strt dt ', 987);
          -- 6 it is the new epsd.
          p_rec_enrt_perd_strt_dt :=  l_backed_out_date;
        END IF;
      END IF;
      CLOSE c_backed_out_ler;
    END IF;
    -- 2746865
    -- if cd is L_EPSD_PEESD%, use the new logic
  ELSIF p_enrt_perd_det_ovrlp_bckdt_cd like  'L_EPSD_PEESD%' THEN
    hr_utility.set_location('  L_EPSD_PEESD%', 987);
    -- get the person's latest enrollment start date +1
    OPEN c_get_latest_enrt_dt;
      FETCH c_get_latest_enrt_dt into l_latest_enrt_dt;
      -- IF c_get_latest_enrt_dt%FOUND THEN --changed as its always found
      IF l_latest_enrt_dt is not null THEN
        hr_utility.set_location(' c_get_latest_enrt_dt%FOUND', 987);
        hr_utility.set_location('l_latest_enrt_dt is '||l_latest_enrt_dt, 987);
        -- if latest enrt dt is greater than epsd, make it the epsd
        IF l_latest_enrt_dt > p_rec_enrt_perd_strt_dt THEN
          p_rec_enrt_perd_strt_dt := l_latest_enrt_dt;
          hr_utility.set_location('l_latest_enrt_dt substituted', 987);
        END IF;
      END IF;
      CLOSE c_get_latest_enrt_dt;
      -- cd is 2 find the bckdt out dt
      IF p_enrt_perd_det_ovrlp_bckdt_cd = 'L_EPSD_PEESD_BCKDT' THEN
        hr_utility.set_location('L_EPSD_PEESD_BCKDT entered', 987);
        -- get the backed out date
        OPEN c_backed_out_ler;
        FETCH c_backed_out_ler INTO l_backed_out_date;
        hr_utility.set_location('l_backed_out_date is '||l_backed_out_date, 987);
        --IF c_backed_out_ler%FOUND THEN -- changed as its of no use
        IF l_backed_out_date is not null THEN
          hr_utility.set_location('bckdt%found', 987);
          -- if bckdt out dt is greater than epsd, make it the epsd
          IF l_backed_out_date > p_rec_enrt_perd_strt_dt THEN
            p_rec_enrt_perd_strt_dt := l_backed_out_date;
            hr_utility.set_location('l_backed_out_date substituted', 987);
          END IF;
        END IF;
        CLOSE c_backed_out_ler;
      -- if cd is 4, compare epsd with sysdate
      ELSIF p_enrt_perd_det_ovrlp_bckdt_cd = 'L_EPSD_PEESD_SYSDT' THEN
        hr_utility.set_location('L_EPSD_PEESD_SYSDT entered', 987);
        -- if sysdate is lis greater than epsd, make it the epsd
        IF l_sysdate > p_rec_enrt_perd_strt_dt THEN
          p_rec_enrt_perd_strt_dt := l_sysdate;
          --
          if g_debug then
            hr_utility.set_location('sysdate substituted', 987);
          end if;
        END IF;
      END IF;
    -- end 2746865
  END IF;
end enrt_perd_strt_dt;
END ben_enrolment_requirements1;

/

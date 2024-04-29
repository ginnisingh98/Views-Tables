--------------------------------------------------------
--  DDL for Package BEN_ENROLMENT_REQUIREMENTS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENROLMENT_REQUIREMENTS1" AUTHID CURRENT_USER as
/* $Header: bendenr1.pkh 120.2.12010000.2 2008/08/05 14:38:45 ubhat ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
History
     Date       Who          Version   What?
     ----       ---          -------   -----
     24 Jan 06  mhoyes       115.0     Created.
     13-Feb-05  mhoyes       115.2   - bug5031107. Moved locally defined procedures
                                       to ben_enrolment_requirements1.
     28-Apr-05  mhoyes       115.3   - bug5152911. Added GetPenPerIDMxESD.
*/
-----------------------------------------------------------------------------
  --
  g_debug boolean := hr_utility.debug_enabled;
  --
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
  p_enrt_cd_level             OUT NOCOPY    VARCHAR2
  );
--
procedure GetPenPerIDMxESD
  (p_person_id         in    number
  ,p_business_group_id in    number
  --
  ,p_penmxesd          out nocopy date
  );
--
procedure enrt_perd_strt_dt
  (p_person_id 				in 	number
   ,p_lf_evt_ocrd_dt 			in 	date
   ,p_enrt_perd_det_ovrlp_bckdt_cd 	in 	varchar2
   ,p_business_group_id                 in      number
   ,p_ler_id                            in      number
   ,p_effective_date                    in      date
   ,p_rec_enrt_perd_strt_dt 		in out 	nocopy date
  );
--
end ben_enrolment_requirements1;

/

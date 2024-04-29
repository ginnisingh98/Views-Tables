--------------------------------------------------------
--  DDL for Package BEN_ENROLMENT_REQUIREMENTS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENROLMENT_REQUIREMENTS2" AUTHID CURRENT_USER as
/* $Header: bendenr2.pkh 120.0 2006/02/16 12:19:41 kmahendr noship $ */
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
*/
-----------------------------------------------------------------------------
  --
  g_debug boolean := hr_utility.debug_enabled;
  --
PROCEDURE get_asg_dets
  (p_person_id IN            number
  ,p_run_mode  IN            varchar2
  ,p_leodt     IN            date
  ,p_effdt     IN            date
  --
  ,p_asg_id       out nocopy number
  ,p_org_id       out nocopy number
  );
--
PROCEDURE get_perpiller_dets
  (p_person_id  IN     number
  ,p_bgp_id     IN     number
  ,p_ler_id     IN     number
  ,p_run_mode   IN     varchar2
  ,p_effdt      IN     date
  ,p_irecasg_id IN     number
  --
  ,p_pil_id        out nocopy number
  ,p_lertyp_cd     out nocopy varchar2
  ,p_lernm         out nocopy varchar2
  ,p_pil_leodt     out nocopy date
  ,p_ler_esd       out nocopy date
  ,p_ler_eed       out nocopy date
  );
--
PROCEDURE get_latest_enrtdt
  (p_person_id  IN     number
  ,p_bgp_id     IN     number
  --
  ,p_pen_mxesd     out nocopy date
  );
--
PROCEDURE bckdout_ler
  (p_person_id  IN     number
  ,p_effdt      IN     date
  ,p_bgp_id     IN     number
  ,p_ler_id     IN     number
  ,p_leodt      IN     date
  --
  ,p_pil_bcktdt    out nocopy date
  );
--
PROCEDURE ptipenrt_info
  (p_person_id   IN     number
  ,p_effdt       IN     date
  ,p_bgp_id      IN     number
  ,p_ptip_id     IN     number
  ,p_cvgthrudt   IN     date
  --
  ,p_pen_pl_id      out nocopy number
  ,p_pen_oipl_id    out nocopy number
  ,p_pen_plip_id    out nocopy number
  );
--
PROCEDURE get_lerplipdfltcd
  (p_plip_id  IN     number
  ,p_ler_id   IN     number
  ,p_effdt    IN     date
  --
  ,p_lep_dflt_enrt_cd out nocopy varchar2
  ,p_lep_dflt_enrt_rl out nocopy varchar2
  );
--
end ben_enrolment_requirements2;

 

/

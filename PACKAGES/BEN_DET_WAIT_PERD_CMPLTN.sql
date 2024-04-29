--------------------------------------------------------
--  DDL for Package BEN_DET_WAIT_PERD_CMPLTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DET_WAIT_PERD_CMPLTN" AUTHID CURRENT_USER AS
/* $Header: benwtprc.pkh 115.6 2002/12/23 11:37:16 rpgupta ship $ */
/*
--------------------------------------------------------------------------------
Name
  Determine Waiting Period Completed Date
Purpose
  This package is used compute when the waiting period for a plan ends
--------------------------------------------------------------------------------
History
-------
  Version Date       Author     Comment
  -------+----------+----------+------------------------------------------------
  115.0   14-May-99  bbulusu    Created.
  115.1   14-May-99  bbulusu    Same as before. Forgot to add date in comments.
  115.2   03-Mar-99  mhoyes   - Added p_comp_obj_tree_row parameter
                                to main.
  115.3   20-Jun-99  mhoyes   - Added current ben_prtn_elig_f,ben_elig_to_prte_rsn_f
                                and ben_pl_f row parameters.
  115.4   13-Jul-99  mhoyes   - Removed context parameters.
  115.5   24-sep-01  tilak    - wait_perd_start_date parameter added
  115.6   23-Dec-02  rpgupta  - Nocopy changes
--------------------------------------------------------------------------------
*/
--
-- -----------------------------------------------------------------------------
-- |------------------------------< main >-------------------------------------|
-- -----------------------------------------------------------------------------
--
-- This is the main procedure that is called to compute the waiting period end
-- date.
--
procedure main
  (p_comp_obj_tree_row in     ben_manage_life_events.g_cache_proc_objects_rec
  ,p_person_id         in     number
  ,p_effective_date    in     date
  ,p_business_group_id in     number
  ,p_ler_id            in     number
  ,p_oipl_id           in     number
  ,p_pl_id             in     number
  ,p_pgm_id            in     number
  ,p_plip_id           in     number
  ,p_ptip_id           in     number
  ,p_lf_evt_ocrd_dt    in     date
  ,p_ntfn_dt           in     date
  ,p_return_date          out nocopy date
  ,p_wait_perd_Strt_dt    out nocopy date
  );
--
end ben_det_wait_perd_cmpltn;
--

 

/

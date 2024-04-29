--------------------------------------------------------
--  DDL for Package BEN_DETERMINE_COMMUNICATIONS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DETERMINE_COMMUNICATIONS1" AUTHID CURRENT_USER as
/*$Header: bentmpc1.pkh 120.0 2007/11/23 13:07:11 sallumwa noship $*/
--
/*
History
  Version Date       Author     Comment
  -------+----------+----------+---------------------------------------------
  115.0   19-Dec-06  mhoyes     Created. Bug5598664.
  ----------------------------------------------------------------------------
*/

procedure get_mssmlg_perids
  (p_per_id           number
  ,p_effdt            date
  ,p_bgp_id           number
  ,p_pet_id           number
  ,p_elig_enrol_cd    varchar2
  ,p_pgm_id           number
  ,p_pl_nip_id        number
  ,p_plan_in_pgm_flag varchar2
  ,p_org_id           number
  ,p_loc_id           number
  --
  ,p_perid_va         out nocopy benutils.g_number_table
  );
end ben_determine_communications1;

/

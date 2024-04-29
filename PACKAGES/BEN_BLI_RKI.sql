--------------------------------------------------------
--  DDL for Package BEN_BLI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BLI_RKI" AUTHID CURRENT_USER as
/* $Header: beblirhi.pkh 120.0 2005/05/28 00:41:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_batch_ler_id                   in number
 ,p_benefit_action_id              in number
 ,p_person_id                      in number
 ,p_ler_id                         in number
 ,p_lf_evt_ocrd_dt                 in date
 ,p_replcd_flag                    in varchar2
 ,p_crtd_flag                      in varchar2
 ,p_tmprl_flag                     in varchar2
 ,p_dltd_flag                      in varchar2
 ,p_open_and_clsd_flag             in varchar2
 ,p_clsd_flag                      in varchar2
 ,p_not_crtd_flag                  in varchar2
 ,p_stl_actv_flag                  in varchar2
 ,p_clpsd_flag                     in varchar2
 ,p_clsn_flag                      in varchar2
 ,p_no_effect_flag                 in varchar2
 ,p_cvrge_rt_prem_flag             in varchar2
 ,p_per_in_ler_id                  in number
 ,p_business_group_id              in number
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end ben_bli_rki;

 

/

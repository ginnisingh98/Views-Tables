--------------------------------------------------------
--  DDL for Package BEN_BLI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BLI_RKD" AUTHID CURRENT_USER as
/* $Header: beblirhi.pkh 120.0 2005/05/28 00:41:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_batch_ler_id                   in number
 ,p_benefit_action_id_o            in number
 ,p_person_id_o                    in number
 ,p_ler_id_o                       in number
 ,p_lf_evt_ocrd_dt_o               in date
 ,p_replcd_flag_o                  in varchar2
 ,p_crtd_flag_o                    in varchar2
 ,p_tmprl_flag_o                   in varchar2
 ,p_dltd_flag_o                    in varchar2
 ,p_open_and_clsd_flag_o           in varchar2
 ,p_clsd_flag_o                    in varchar2
 ,p_not_crtd_flag_o                in varchar2
 ,p_stl_actv_flag_o                in varchar2
 ,p_clpsd_flag_o                   in varchar2
 ,p_clsn_flag_o                    in varchar2
 ,p_no_effect_flag_o               in varchar2
 ,p_cvrge_rt_prem_flag_o           in varchar2
 ,p_per_in_ler_id_o                in number
 ,p_business_group_id_o            in number
 ,p_object_version_number_o        in number
  );
--
end ben_bli_rkd;

 

/

--------------------------------------------------------
--  DDL for Package BEN_PPL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PPL_RKD" AUTHID CURRENT_USER as
/* $Header: bepplrhi.pkh 120.0.12000000.1 2007/01/19 21:49:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ptnl_ler_for_per_id            in number
 ,p_csd_by_ptnl_ler_for_per_id_o   in number
 ,p_lf_evt_ocrd_dt_o               in date
 ,p_trgr_table_pk_id_o             in number
 ,p_ptnl_ler_for_per_stat_cd_o     in varchar2
 ,p_ptnl_ler_for_per_src_cd_o      in varchar2
 ,p_mnl_dt_o                       in date
 ,p_enrt_perd_id_o                 in number
 ,p_ntfn_dt_o                      in date
 ,p_dtctd_dt_o                     in date
 ,p_procd_dt_o                     in date
 ,p_unprocd_dt_o                   in date
 ,p_voidd_dt_o                     in date
 ,p_mnlo_dt_o                      in date
 ,p_ler_id_o                       in number
 ,p_person_id_o                    in number
 ,p_business_group_id_o            in number
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_object_version_number_o        in number
  );
--
end ben_ppl_rkd;

 

/

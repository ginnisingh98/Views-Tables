--------------------------------------------------------
--  DDL for Package BEN_BEC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BEC_RKU" AUTHID CURRENT_USER as
/* $Header: bebecrhi.pkh 120.0 2005/05/28 00:37:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_batch_elctbl_id                in number
 ,p_benefit_action_id              in number
 ,p_person_id                      in number
 ,p_pgm_id                         in number
 ,p_pl_id                          in number
 ,p_oipl_id                        in number
 ,p_enrt_cvg_strt_dt               in date
 ,p_enrt_perd_strt_dt              in date
 ,p_enrt_perd_end_dt               in date
 ,p_erlst_deenrt_dt                in date
 ,p_dflt_enrt_dt                   in date
 ,p_enrt_typ_cycl_cd               in varchar2
 ,p_comp_lvl_cd                    in varchar2
 ,p_mndtry_flag                    in varchar2
 ,p_dflt_flag                      in varchar2
 ,p_business_group_id              in number
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_benefit_action_id_o            in number
 ,p_person_id_o                    in number
 ,p_pgm_id_o                       in number
 ,p_pl_id_o                        in number
 ,p_oipl_id_o                      in number
 ,p_enrt_cvg_strt_dt_o             in date
 ,p_enrt_perd_strt_dt_o            in date
 ,p_enrt_perd_end_dt_o             in date
 ,p_erlst_deenrt_dt_o              in date
 ,p_dflt_enrt_dt_o                 in date
 ,p_enrt_typ_cycl_cd_o             in varchar2
 ,p_comp_lvl_cd_o                  in varchar2
 ,p_mndtry_flag_o                  in varchar2
 ,p_dflt_flag_o                    in varchar2
 ,p_business_group_id_o            in number
 ,p_object_version_number_o        in number
  );
--
end ben_bec_rku;

 

/
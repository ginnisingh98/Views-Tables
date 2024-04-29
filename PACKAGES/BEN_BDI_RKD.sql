--------------------------------------------------------
--  DDL for Package BEN_BDI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BDI_RKD" AUTHID CURRENT_USER as
/* $Header: bebdirhi.pkh 120.0.12000000.1 2007/01/19 00:50:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_batch_dpnt_id                  in number
 ,p_benefit_action_id_o            in number
 ,p_person_id_o                    in number
 ,p_pgm_id_o                       in number
 ,p_pl_id_o                        in number
 ,p_oipl_id_o                      in number
 ,p_contact_typ_cd_o               in varchar2
 ,p_dpnt_person_id_o               in number
 ,p_business_group_id_o            in number
 ,p_object_version_number_o        in varchar2
 ,p_enrt_cvg_strt_dt_o             in date
 ,p_enrt_cvg_thru_dt_o             in date
 ,p_actn_cd_o                      in varchar2
  );
--
end ben_bdi_rkd;

 

/
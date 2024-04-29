--------------------------------------------------------
--  DDL for Package BEN_BRI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BRI_RKU" AUTHID CURRENT_USER as
/* $Header: bebrirhi.pkh 120.0 2005/05/28 00:51:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_batch_rt_id                    in number
 ,p_benefit_action_id              in number
 ,p_person_id                      in number
 ,p_pgm_id                         in number
 ,p_pl_id                          in number
 ,p_oipl_id                        in number
 ,p_bnft_rt_typ_cd                 in varchar2
 ,p_dflt_flag                      in varchar2
 ,p_val                            in number
 ,p_old_val                        in number
 ,p_tx_typ_cd                      in varchar2
 ,p_acty_typ_cd                    in varchar2
 ,p_mn_elcn_val                    in number
 ,p_mx_elcn_val                    in number
 ,p_incrmt_elcn_val                in number
 ,p_dflt_val                       in number
 ,p_rt_strt_dt                     in date
 ,p_business_group_id              in number
 ,p_object_version_number          in number
 ,p_enrt_cvg_strt_dt               in date
 ,p_enrt_cvg_thru_dt               in date
 ,p_actn_cd                        in varchar2
 ,p_close_actn_itm_dt              in date
 ,p_effective_date                 in date
 ,p_benefit_action_id_o            in number
 ,p_person_id_o                    in number
 ,p_pgm_id_o                       in number
 ,p_pl_id_o                        in number
 ,p_oipl_id_o                      in number
 ,p_bnft_rt_typ_cd_o               in varchar2
 ,p_dflt_flag_o                    in varchar2
 ,p_val_o                          in number
 ,p_old_val_o                      in number
 ,p_tx_typ_cd_o                    in varchar2
 ,p_acty_typ_cd_o                  in varchar2
 ,p_mn_elcn_val_o                  in number
 ,p_mx_elcn_val_o                  in number
 ,p_incrmt_elcn_val_o              in number
 ,p_dflt_val_o                     in number
 ,p_rt_strt_dt_o                   in date
 ,p_business_group_id_o            in number
 ,p_object_version_number_o        in number
 ,p_enrt_cvg_strt_dt_o             in date
 ,p_enrt_cvg_thru_dt_o             in date
 ,p_actn_cd_o                      in varchar2
 ,p_close_actn_itm_dt_o            in date
  );
--
end ben_bri_rku;

 

/

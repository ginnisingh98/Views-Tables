--------------------------------------------------------
--  DDL for Package BEN_AUD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_AUD_RKD" AUTHID CURRENT_USER as
/* $Header: beaudrhi.pkh 120.0 2005/05/28 00:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_cwb_audit_id                 in number
  ,p_group_per_in_ler_id_o        in number
  ,p_group_pl_id_o                in number
  ,p_lf_evt_ocrd_dt_o             in date
  ,p_pl_id_o                      in number
  ,p_group_oipl_id_o              in number
  ,p_audit_type_cd_o              in varchar2
  ,p_old_val_varchar_o            in varchar2
  ,p_new_val_varchar_o            in varchar2
  ,p_old_val_number_o             in number
  ,p_new_val_number_o             in number
  ,p_old_val_date_o               in date
  ,p_new_val_date_o               in date
  ,p_date_stamp_o                 in date
  ,p_change_made_by_person_id_o   in number
  ,p_supporting_information_o     in varchar2
  ,p_request_id_o                 in number
  ,p_object_version_number_o      in number
  );
--
end ben_aud_rkd;

 

/

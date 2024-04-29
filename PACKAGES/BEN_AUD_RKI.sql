--------------------------------------------------------
--  DDL for Package BEN_AUD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_AUD_RKI" AUTHID CURRENT_USER as
/* $Header: beaudrhi.pkh 120.0 2005/05/28 00:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_cwb_audit_id                 in number
  ,p_group_per_in_ler_id          in number
  ,p_group_pl_id                  in number
  ,p_lf_evt_ocrd_dt               in date
  ,p_pl_id                        in number
  ,p_group_oipl_id                in number
  ,p_audit_type_cd                in varchar2
  ,p_old_val_varchar              in varchar2
  ,p_new_val_varchar              in varchar2
  ,p_old_val_number               in number
  ,p_new_val_number               in number
  ,p_old_val_date                 in date
  ,p_new_val_date                 in date
  ,p_date_stamp                   in date
  ,p_change_made_by_person_id     in number
  ,p_supporting_information       in varchar2
  ,p_request_id                   in number
  ,p_object_version_number        in number
  );
end ben_aud_rki;

 

/

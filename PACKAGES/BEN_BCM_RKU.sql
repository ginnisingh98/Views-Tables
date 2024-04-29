--------------------------------------------------------
--  DDL for Package BEN_BCM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BCM_RKU" AUTHID CURRENT_USER as
/* $Header: bebcmrhi.pkh 120.0.12010000.1 2008/07/29 10:53:52 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_cwb_matrix_id                in number
  ,p_name                         in varchar2
  ,p_date_saved                   in date
  ,p_plan_id                      in number
  ,p_matrix_typ_cd                in varchar2
  ,p_person_id                    in number
  ,p_row_crit_cd                  in varchar2
  ,p_col_crit_cd                  in varchar2
  ,p_alct_by_cd                   in varchar2
  ,p_business_group_id            in number
  ,p_object_version_number        in number
  ,p_name_o                       in varchar2
  ,p_date_saved_o                 in date
  ,p_plan_id_o                    in number
  ,p_matrix_typ_cd_o              in varchar2
  ,p_person_id_o                  in number
  ,p_row_crit_cd_o                in varchar2
  ,p_col_crit_cd_o                in varchar2
  ,p_alct_by_cd_o                 in varchar2
  ,p_business_group_id_o          in number
  ,p_object_version_number_o      in number
  );
--
end ben_bcm_rku;

/

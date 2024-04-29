--------------------------------------------------------
--  DDL for Package PQH_VER_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_VER_RKU" AUTHID CURRENT_USER as
/* $Header: pqverrhi.pkh 120.0 2005/05/29 02:53:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_wrkplc_vldtn_ver_id          in number
  ,p_wrkplc_vldtn_id              in number
  ,p_version_number               in number
  ,p_business_group_id            in number
  ,p_tariff_contract_code         in varchar2
  ,p_tariff_group_code            in varchar2
  ,p_remuneration_job_description in varchar2
  ,p_job_group_id                 in number
  ,p_remuneration_job_id          in number
  ,p_derived_grade_id             in number
  ,p_derived_case_group_id        in number
  ,p_derived_subcasgrp_id         in number
  ,p_user_enterable_grade_id      in number
  ,p_user_enterable_case_group_id in number
  ,p_user_enterable_subcasgrp_id  in number
  ,p_freeze                       in varchar2
  ,p_object_version_number        in number
  ,p_wrkplc_vldtn_id_o            in number
  ,p_version_number_o             in number
  ,p_business_group_id_o          in number
  ,p_tariff_contract_code_o       in varchar2
  ,p_tariff_group_code_o          in varchar2
  ,p_remuneration_job_descripti_o in varchar2
  ,p_job_group_id_o               in number
  ,p_remuneration_job_id_o        in number
  ,p_derived_grade_id_o           in number
  ,p_derived_case_group_id_o      in number
  ,p_derived_subcasgrp_id_o       in number
  ,p_user_enterable_grade_id_o    in number
  ,p_user_enterable_case_group__o in number
  ,p_user_enterable_subcasgrp_i_o in number
  ,p_freeze_o                     in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_ver_rku;

 

/

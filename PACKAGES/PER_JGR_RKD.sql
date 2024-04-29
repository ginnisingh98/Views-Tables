--------------------------------------------------------
--  DDL for Package PER_JGR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JGR_RKD" AUTHID CURRENT_USER as
/* $Header: pejgrrhi.pkh 120.0 2005/05/31 10:40:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_job_group_id                 in number
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_internal_name_o              in varchar2
  ,p_displayed_name_o             in varchar2
  ,p_id_flex_num_o                in number
  ,p_master_flag_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_jgr_rkd;

 

/

--------------------------------------------------------
--  DDL for Package PQH_DEF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DEF_RKD" AUTHID CURRENT_USER as
/* $Header: pqdefrhi.pkh 120.0 2005/05/29 01:46:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_wrkplc_vldtn_id              in number
  ,p_validation_name_o            in varchar2
  ,p_business_group_id_o          in number
  ,p_employment_type_o            in varchar2
  ,p_remuneration_regulation_o    in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_def_rkd;

 

/

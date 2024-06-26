--------------------------------------------------------
--  DDL for Package PQH_PRE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PRE_RKD" AUTHID CURRENT_USER as
/* $Header: pqprerhi.pkh 120.0 2005/05/29 02:17:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_ins_end_reason_id            in number
  ,p_business_group_id_o          in number
  ,p_provider_organization_id_o   in number
  ,p_end_reason_number_o          in varchar2
  ,p_end_reason_short_name_o      in varchar2
  ,p_end_reason_description_o     in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_pre_rkd;

 

/

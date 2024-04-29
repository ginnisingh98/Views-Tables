--------------------------------------------------------
--  DDL for Package PQH_PRE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PRE_RKI" AUTHID CURRENT_USER as
/* $Header: pqprerhi.pkh 120.0 2005/05/29 02:17:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_ins_end_reason_id            in number
  ,p_business_group_id            in number
  ,p_provider_organization_id     in number
  ,p_end_reason_number            in varchar2
  ,p_end_reason_short_name        in varchar2
  ,p_end_reason_description       in varchar2
  ,p_object_version_number        in number
  );
end pqh_pre_rki;

 

/

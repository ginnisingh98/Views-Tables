--------------------------------------------------------
--  DDL for Package PQH_DE_INS_END_REASONS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_INS_END_REASONS_BK2" AUTHID CURRENT_USER as
/* $Header: pqpreapi.pkh 120.0 2005/05/29 02:17:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <Update_PENSION_END_REASONS_b >-------------------------|
-- ----------------------------------------------------------------------------
--

procedure Update_PENSION_END_REASONS_b
( p_effective_date                in     date
  ,p_ins_end_reason_id        in     number
  ,p_object_version_number        in      number
  ,p_business_group_id            in     number
  ,p_provider_organization_id     in     number
  ,p_end_reason_number            in     varchar2
  ,p_end_reason_short_name        in     varchar2
  ,p_end_reason_description       in     varchar2
  );



procedure Update_PENSION_END_REASONS_a
   ( p_effective_date             in     date
  ,p_ins_end_reason_id        in     number
  ,p_object_version_number        in     number
  ,p_business_group_id            in     number
  ,p_provider_organization_id     in     number
  ,p_end_reason_number            in     varchar2
  ,p_end_reason_short_name        in     varchar2
  ,p_end_reason_description       in     varchar2
  );


end PQH_DE_iNs_END_REASONS_BK2;

 

/

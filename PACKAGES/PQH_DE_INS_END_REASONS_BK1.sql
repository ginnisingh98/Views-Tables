--------------------------------------------------------
--  DDL for Package PQH_DE_INS_END_REASONS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_INS_END_REASONS_BK1" AUTHID CURRENT_USER as
/* $Header: pqpreapi.pkh 120.0 2005/05/29 02:17:39 appldev noship $ */

  Procedure Insert_PENSION_END_REASONS_b
( p_effective_date                  in     date
  ,p_business_group_id              in     number
  ,p_provider_organization_id       in     number
  ,p_end_reason_number              in     varchar2
  ,p_end_reason_short_name          in     varchar2
  ,p_end_reason_description         in     varchar2
  ) ;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< Insert_PENSION_END_REASONS_a >-------------------------|
-- ----------------------------------------------------------------------------
--

procedure Insert_PENSION_END_REASONS_a
 ( p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_provider_organization_id       in     number
  ,p_end_reason_number              in     varchar2
  ,p_end_reason_short_name          in     varchar2
  ,p_end_reason_description         in     varchar2
  ,p_ins_end_reason_id          in    number
  ,p_object_version_number          in    number
  ) ;



 --
end PQH_DE_iNs_END_REASONS_BK1;

 

/

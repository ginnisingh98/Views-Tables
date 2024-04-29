--------------------------------------------------------
--  DDL for Package PQH_DE_INS_END_REASONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_INS_END_REASONS_API" AUTHID CURRENT_USER as
/* $Header: pqpreapi.pkh 120.0 2005/05/29 02:17:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <PQH_DE_ins_END_REASONS_API> >----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This API Creates the the master definition of PENSION_END_REASONS
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

procedure Insert_PENSION_END_REASONS
 ( p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_provider_organization_id       in     number
  ,p_end_reason_number              in     varchar2
  ,p_end_reason_short_name          in     varchar2
  ,p_end_reason_description         in     varchar2
  ,p_ins_end_reason_id          out nocopy    number
  ,p_object_version_number          out nocopy    number
  ) ;

procedure Update_PENSION_END_REASONS
( p_validate                      in     boolean  default false
  ,p_effective_date               in     date
  ,p_ins_end_reason_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_provider_organization_id     in     number    default hr_api.g_number
  ,p_end_reason_number            in     varchar2  default hr_api.g_varchar2
  ,p_end_reason_short_name        in     varchar2  default hr_api.g_varchar2
  ,p_end_reason_description       in     varchar2  default hr_api.g_varchar2
  );

procedure delete_PENSION_END_REASONS
  (p_validate                      in     boolean  default false
  ,p_ins_end_reason_id       In     Number
  ,p_object_version_number         In     number);
--
end  PQH_DE_ins_END_REASONS_API;

 

/

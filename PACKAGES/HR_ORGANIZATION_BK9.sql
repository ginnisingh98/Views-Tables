--------------------------------------------------------
--  DDL for Package HR_ORGANIZATION_BK9
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORGANIZATION_BK9" AUTHID CURRENT_USER as
/* $Header: hrorgapi.pkh 120.13.12010000.4 2009/04/14 09:46:26 sathkris ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_hr_organization_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_hr_organization_b
  (p_effective_date                 IN  DATE
  ,p_business_group_id              IN  NUMBER
  ,p_name                           IN  VARCHAR2
  ,p_date_from                      IN  DATE
  ,p_language_code                  IN  VARCHAR2
  ,p_location_id                    IN  NUMBER
  ,p_date_to                        IN  DATE
  ,p_internal_external_flag         IN  VARCHAR2
  ,p_internal_address_line          IN  VARCHAR2
  ,p_type                           IN  VARCHAR2
  ,p_enabled_flag                   IN  VARCHAR2
  ,p_segment1                       IN  VARCHAR2
  ,p_segment2                       IN  VARCHAR2
  ,p_segment3                       IN  VARCHAR2
  ,p_segment4                       IN  VARCHAR2
  ,p_segment5                       IN  VARCHAR2
  ,p_segment6                       IN  VARCHAR2
  ,p_segment7                       IN  VARCHAR2
  ,p_segment8                       IN  VARCHAR2
  ,p_segment9                       IN  VARCHAR2
  ,p_segment10                      IN  VARCHAR2
  ,p_segment11                      IN  VARCHAR2
  ,p_segment12                      IN  VARCHAR2
  ,p_segment13                      IN  VARCHAR2
  ,p_segment14                      IN  VARCHAR2
  ,p_segment15                      IN  VARCHAR2
  ,p_segment16                      IN  VARCHAR2
  ,p_segment17                      IN  VARCHAR2
  ,p_segment18                      IN  VARCHAR2
  ,p_segment19                      IN  VARCHAR2
  ,p_segment20                      IN  VARCHAR2
  ,p_segment21                      IN  VARCHAR2
  ,p_segment22                      IN  VARCHAR2
  ,p_segment23                      IN  VARCHAR2
  ,p_segment24                      IN  VARCHAR2
  ,p_segment25                      IN  VARCHAR2
  ,p_segment26                      IN  VARCHAR2
  ,p_segment27                      IN  VARCHAR2
  ,p_segment28                      IN  VARCHAR2
  ,p_segment29                      IN  VARCHAR2
  ,p_segment30                      IN  VARCHAR2
  ,p_concat_segments                IN  VARCHAR2);
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_hr_organization_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_hr_organization_a
  (p_effective_date                 IN  DATE
  ,p_business_group_id              IN  NUMBER
  ,p_name                           IN  VARCHAR2
  ,p_date_from                      IN  DATE
  ,p_language_code                  IN  VARCHAR2
  ,p_location_id                    IN  NUMBER
  ,p_date_to                        IN  DATE
  ,p_internal_external_flag         IN  VARCHAR2
  ,p_internal_address_line          IN  VARCHAR2
  ,p_type                           IN  VARCHAR2
  ,p_enabled_flag                   IN  VARCHAR2
  ,p_segment1                       IN  VARCHAR2
  ,p_segment2                       IN  VARCHAR2
  ,p_segment3                       IN  VARCHAR2
  ,p_segment4                       IN  VARCHAR2
  ,p_segment5                       IN  VARCHAR2
  ,p_segment6                       IN  VARCHAR2
  ,p_segment7                       IN  VARCHAR2
  ,p_segment8                       IN  VARCHAR2
  ,p_segment9                       IN  VARCHAR2
  ,p_segment10                      IN  VARCHAR2
  ,p_segment11                      IN  VARCHAR2
  ,p_segment12                      IN  VARCHAR2
  ,p_segment13                      IN  VARCHAR2
  ,p_segment14                      IN  VARCHAR2
  ,p_segment15                      IN  VARCHAR2
  ,p_segment16                      IN  VARCHAR2
  ,p_segment17                      IN  VARCHAR2
  ,p_segment18                      IN  VARCHAR2
  ,p_segment19                      IN  VARCHAR2
  ,p_segment20                      IN  VARCHAR2
  ,p_segment21                      IN  VARCHAR2
  ,p_segment22                      IN  VARCHAR2
  ,p_segment23                      IN  VARCHAR2
  ,p_segment24                      IN  VARCHAR2
  ,p_segment25                      IN  VARCHAR2
  ,p_segment26                      IN  VARCHAR2
  ,p_segment27                      IN  VARCHAR2
  ,p_segment28                      IN  VARCHAR2
  ,p_segment29                      IN  VARCHAR2
  ,p_segment30                      IN  VARCHAR2
  ,p_concat_segments                IN  VARCHAR2
  ,p_object_version_number_inf      IN  NUMBER
  ,p_object_version_number_org      IN  NUMBER
  ,p_organization_id                IN  NUMBER
  ,p_org_information_id             IN  NUMBER
  ,p_duplicate_org_warning          IN  BOOLEAN);
--
end hr_organization_bk9;

/

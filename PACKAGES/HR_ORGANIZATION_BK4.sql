--------------------------------------------------------
--  DDL for Package HR_ORGANIZATION_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORGANIZATION_BK4" AUTHID CURRENT_USER as
/* $Header: hrorgapi.pkh 120.13.12010000.4 2009/04/14 09:46:26 sathkris ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_organization >-----------------------|
-- ----------------------------------------------------------------------------
--

PROCEDURE update_organization_a
     (p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2
     ,p_name                           IN  VARCHAR2
     ,p_organization_id                IN  NUMBER
     ,p_cost_allocation_keyflex_id     IN  NUMBER
     ,p_location_id                    IN  NUMBER
     -- Bug 3040119
     --,p_soft_coding_keyflex_id         IN  NUMBER
     ,p_date_from                      IN  DATE
     ,p_date_to                        IN  DATE
     ,p_internal_external_flag         IN  VARCHAR2
     ,p_internal_address_line          IN  VARCHAR2
     ,p_type                           IN  VARCHAR2
     ,p_attribute_category             IN  VARCHAR2
     ,p_attribute1                     IN  VARCHAR2
     ,p_attribute2                     IN  VARCHAR2
     ,p_attribute3                     IN  VARCHAR2
     ,p_attribute4                     IN  VARCHAR2
     ,p_attribute5                     IN  VARCHAR2
     ,p_attribute6                     IN  VARCHAR2
     ,p_attribute7                     IN  VARCHAR2
     ,p_attribute8                     IN  VARCHAR2
     ,p_attribute9                     IN  VARCHAR2
     ,p_attribute10                    IN  VARCHAR2
     ,p_attribute11                    IN  VARCHAR2
     ,p_attribute12                    IN  VARCHAR2
     ,p_attribute13                    IN  VARCHAR2
     ,p_attribute14                    IN  VARCHAR2
     ,p_attribute15                    IN  VARCHAR2
     ,p_attribute16                    IN  VARCHAR2
     ,p_attribute17                    IN  VARCHAR2
     ,p_attribute18                    IN  VARCHAR2
     ,p_attribute19                    IN  VARCHAR2
     ,p_attribute20                    IN  VARCHAR2
     -- Enhancement 4040086
     ,p_attribute21                    IN  VARCHAR2
     ,p_attribute22                    IN  VARCHAR2
     ,p_attribute23                    IN  VARCHAR2
     ,p_attribute24                    IN  VARCHAR2
     ,p_attribute25                    IN  VARCHAR2
     ,p_attribute26                    IN  VARCHAR2
     ,p_attribute27                    IN  VARCHAR2
     ,p_attribute28                    IN  VARCHAR2
     ,p_attribute29                    IN  VARCHAR2
     ,p_attribute30                    IN  VARCHAR2
     --End Enhancement 4040086
     -- Bug 3039046
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
     ,p_cost_name                      IN  VARCHAR2
     --
     ,p_object_version_number          IN NUMBER
     ,p_duplicate_org_warning          in boolean
  );

PROCEDURE update_organization_b
     (p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2
     ,p_name                           IN  VARCHAR2
     ,p_organization_id                IN  NUMBER
     ,p_cost_allocation_keyflex_id     IN  NUMBER
     ,p_location_id                    IN  NUMBER
     -- Bug 3040119
     --,p_soft_coding_keyflex_id         IN  NUMBER
     ,p_date_from                      IN  DATE
     ,p_date_to                        IN  DATE
     ,p_internal_external_flag         IN  VARCHAR2
     ,p_internal_address_line          IN  VARCHAR2
     ,p_type                           IN  VARCHAR2
     ,p_attribute_category             IN  VARCHAR2
     ,p_attribute1                     IN  VARCHAR2
     ,p_attribute2                     IN  VARCHAR2
     ,p_attribute3                     IN  VARCHAR2
     ,p_attribute4                     IN  VARCHAR2
     ,p_attribute5                     IN  VARCHAR2
     ,p_attribute6                     IN  VARCHAR2
     ,p_attribute7                     IN  VARCHAR2
     ,p_attribute8                     IN  VARCHAR2
     ,p_attribute9                     IN  VARCHAR2
     ,p_attribute10                    IN  VARCHAR2
     ,p_attribute11                    IN  VARCHAR2
     ,p_attribute12                    IN  VARCHAR2
     ,p_attribute13                    IN  VARCHAR2
     ,p_attribute14                    IN  VARCHAR2
     ,p_attribute15                    IN  VARCHAR2
     ,p_attribute16                    IN  VARCHAR2
     ,p_attribute17                    IN  VARCHAR2
     ,p_attribute18                    IN  VARCHAR2
     ,p_attribute19                    IN  VARCHAR2
     ,p_attribute20                    IN  VARCHAR2
     -- Enhancement 4040086
     ,p_attribute21                    IN  VARCHAR2
     ,p_attribute22                    IN  VARCHAR2
     ,p_attribute23                    IN  VARCHAR2
     ,p_attribute24                    IN  VARCHAR2
     ,p_attribute25                    IN  VARCHAR2
     ,p_attribute26                    IN  VARCHAR2
     ,p_attribute27                    IN  VARCHAR2
     ,p_attribute28                    IN  VARCHAR2
     ,p_attribute29                    IN  VARCHAR2
     ,p_attribute30                    IN  VARCHAR2
     --End Enhancement 4040086
     -- Bug 3039046
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
     --
     ,p_object_version_number          IN NUMBER
  );
end hr_organization_bk4;

/

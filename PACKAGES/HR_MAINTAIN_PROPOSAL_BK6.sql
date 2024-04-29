--------------------------------------------------------
--  DDL for Package HR_MAINTAIN_PROPOSAL_BK6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MAINTAIN_PROPOSAL_BK6" AUTHID CURRENT_USER as
/* $Header: hrpypapi.pkh 120.11.12010000.3 2008/12/05 14:33:06 vkodedal ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< update_proposal_components_b >-----------------------|
-- ----------------------------------------------------------------------------

Procedure update_proposal_component_b
  (
  p_component_id                 in number,
  p_approved                     in varchar2,
  p_component_reason             in varchar2,
  p_change_amount_n              in number,
  p_change_percentage            in number,
  p_comments                     in varchar2,
  p_attribute_category           in varchar2,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_attribute11                  in varchar2,
  p_attribute12                  in varchar2,
  p_attribute13                  in varchar2,
  p_attribute14                  in varchar2,
  p_attribute15                  in varchar2,
  p_attribute16                  in varchar2,
  p_attribute17                  in varchar2,
  p_attribute18                  in varchar2,
  p_attribute19                  in varchar2,
  p_attribute20                  in varchar2,
  p_validation_strength          in varchar2,
  p_object_version_number        in number
  );

-- ----------------------------------------------------------------------------
-- |-------------------< update_proposal_components_a >-----------------------|
-- ----------------------------------------------------------------------------
Procedure update_proposal_component_a
  (
  p_component_id                 in number,
  p_approved                     in varchar2,
  p_component_reason             in varchar2,
  p_change_amount_n              in number,
  p_change_percentage            in number,
  p_comments                     in varchar2,
  p_attribute_category           in varchar2,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_attribute11                  in varchar2,
  p_attribute12                  in varchar2,
  p_attribute13                  in varchar2,
  p_attribute14                  in varchar2,
  p_attribute15                  in varchar2,
  p_attribute16                  in varchar2,
  p_attribute17                  in varchar2,
  p_attribute18                  in varchar2,
  p_attribute19                  in varchar2,
  p_attribute20                  in varchar2,
  p_validation_strength          in varchar2,
  p_object_version_number        in number
  );

end hr_maintain_proposal_bk6;

/

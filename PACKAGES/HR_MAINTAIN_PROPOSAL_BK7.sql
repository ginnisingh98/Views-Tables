--------------------------------------------------------
--  DDL for Package HR_MAINTAIN_PROPOSAL_BK7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MAINTAIN_PROPOSAL_BK7" AUTHID CURRENT_USER as
/* $Header: hrpypapi.pkh 120.11.12010000.3 2008/12/05 14:33:06 vkodedal ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_proposal_components_b >-----------------------|
-- ----------------------------------------------------------------------------
Procedure delete_proposal_component_b
  (
  p_component_id                       in number,
  p_validation_strength                in varchar2,
  p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_proposal_components_a >-----------------------|
-- ----------------------------------------------------------------------------
Procedure delete_proposal_component_a
  (
  p_component_id                       in number,
  p_validation_strength                in varchar2,
  p_object_version_number              in number
  );
--
end hr_maintain_proposal_bk7;

/

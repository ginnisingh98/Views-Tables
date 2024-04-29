--------------------------------------------------------
--  DDL for Package HR_PER_DEPLYMT_CONTACT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PER_DEPLYMT_CONTACT_BK1" AUTHID CURRENT_USER as
/* $Header: hrpdcapi.pkh 120.1.12010000.2 2008/08/06 08:46:38 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_per_deplymt_contact_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_per_deplymt_contact_b
  (p_person_deployment_id          in     number
  ,p_contact_relationship_id          in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_per_deplymt_contact_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_per_deplymt_contact_a
  (p_person_deployment_id          in     number
  ,p_contact_relationship_id       in     number
  ,p_per_deplymt_contact_id        in     number
  ,p_object_version_number         in     number
  );
--
end HR_PER_DEPLYMT_CONTACT_BK1;

/

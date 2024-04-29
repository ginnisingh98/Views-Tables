--------------------------------------------------------
--  DDL for Package HR_PER_DEPLYMT_CONTACT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PER_DEPLYMT_CONTACT_BK2" AUTHID CURRENT_USER as
/* $Header: hrpdcapi.pkh 120.1.12010000.2 2008/08/06 08:46:38 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_per_deplymt_contact_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_per_deplymt_contact_b
  (p_per_deplymt_contact_id        in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_per_deplymt_contact_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_per_deplymt_contact_a
  (p_per_deplymt_contact_id        in     number
  ,p_object_version_number         in     number
  );
--
end HR_PER_DEPLYMT_CONTACT_BK2;

/

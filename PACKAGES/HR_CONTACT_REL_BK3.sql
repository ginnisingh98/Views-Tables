--------------------------------------------------------
--  DDL for Package HR_CONTACT_REL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CONTACT_REL_BK3" AUTHID CURRENT_USER as
/* $Header: pecrlapi.pkh 120.1 2005/10/02 02:14:06 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_contact_relationship_b >-------------|
-- ----------------------------------------------------------------------------
--
procedure delete_contact_relationship_b
  (p_contact_relationship_id           in        number
  ,p_object_version_number             in        number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_contact_relationship_a >---------------|
-- ----------------------------------------------------------------------------
--
procedure delete_contact_relationship_a
  (p_contact_relationship_id           in        number
  ,p_object_version_number             in        number
  );
--
end hr_contact_rel_bk3;

 

/

--------------------------------------------------------
--  DDL for Package HR_DE_ORGANIZATION_LINKS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_ORGANIZATION_LINKS_BK3" AUTHID CURRENT_USER as
/* $Header: hrordapi.pkh 120.1 2005/10/02 02:04:52 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_link_b >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_link_b
  (p_organization_link_id           in     number
  ,p_object_version_number          in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_link_a >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_link_a
  (p_organization_link_id           in     number
  ,p_object_version_number          in     varchar2
  );
--
end hr_de_organization_links_bk3;

 

/

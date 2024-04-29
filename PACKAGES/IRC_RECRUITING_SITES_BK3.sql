--------------------------------------------------------
--  DDL for Package IRC_RECRUITING_SITES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_RECRUITING_SITES_BK3" AUTHID CURRENT_USER as
/* $Header: irrseapi.pkh 120.2.12010000.3 2010/03/05 12:49:51 sbadiger ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< delete_recruiting_site_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_recruiting_site_b
  (p_recruiting_site_id            in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------< delete_recruiting_site_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_recruiting_site_a
  (p_recruiting_site_id            in     number
  ,p_object_version_number         in     number
  );
--
end IRC_RECRUITING_SITES_BK3;

/

--------------------------------------------------------
--  DDL for Package PER_CONTACT_EXTRA_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CONTACT_EXTRA_INFO_PKG" AUTHID CURRENT_USER AS
/* $Header: pecei01t.pkh 115.1 2002/02/15 01:13:28 pkm ship        $ */
-- ---------------------------------------------------------------------------
-- |-------------------------< populate_info_exists >------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Accepts contact_relationship_id and information_type, and returns 'Y' if
--   if a per_contact_extra_info record exists.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                      	Reqd    Type	        Description
--   x_contact_relationship_id	Yes     NUMBER          Contact Relationship ID.
--   x_information_type        	Yes     VARCHAR2        Contact Information
-- 							Type.
--
-- Out Parameters:
--   None.
--
-- Post Success:
--   The function returns 'Y' or 'N'.
--
-- Post Failure:
--   None.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
 FUNCTION populate_info_exists(
  x_contact_relationship_id	IN 	per_contact_extra_info_f.contact_relationship_id%TYPE,
  x_information_type 		IN 	per_contact_extra_info_f.information_type%TYPE)
  RETURN VARCHAR2;
END per_contact_extra_info_pkg;

 

/

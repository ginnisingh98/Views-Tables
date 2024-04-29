--------------------------------------------------------
--  DDL for Package Body PER_CONTACT_EXTRA_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CONTACT_EXTRA_INFO_PKG" AS
/* $Header: pecei01t.pkb 115.3 2002/03/19 18:05:16 pkm ship        $ */
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
--   x_contact_relationship_id	Yes     VARCHAR2        Contact Relationship ID.
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
  RETURN VARCHAR2 IS
  --
  CURSOR c_cei IS
   SELECT 'Y'
   FROM per_contact_extra_info cei
   WHERE cei.contact_relationship_id = x_contact_relationship_id
   AND cei.information_type = x_information_type;
  --
  l_return	VARCHAR2(1) := 'N';
 BEGIN
   OPEN c_cei;
   FETCH c_cei INTO l_return;
   CLOSE c_cei;
   RETURN l_return;
 END populate_info_exists;
--
END per_contact_extra_info_pkg;

/

--------------------------------------------------------
--  DDL for Package Body PER_JP_CONTACT_RELATIONSHIPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JP_CONTACT_RELATIONSHIPS" AS
/* $Header: pejpcrlh.pkb 115.2 2002/05/30 23:09:00 pkm ship        $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_si_itax_flag >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure verifies there is only 1 row that has 'Y' in si_itax_flag
--   for a person and a contact person.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_contact_relationship_id      Yes  NUMBER   Contact Releationship ID.
--   p_person_id                    Yes  NUMBER   Person ID.
--   p_contact_person_id            Yes  NUMBER   Contact Person ID.
--   p_cont_information1            Yes  VARCHAR2 Social Insurance and Income
--						  Tax.
--
-- Post Success:
--   Process continues.
--
-- Post Failure:
--   An application error will be raised and process is terminated.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
--
 PROCEDURE chk_si_itax_flag(
  p_contact_relationship_id     NUMBER		DEFAULT NULL,
  p_person_id                   NUMBER,
  p_contact_person_id           NUMBER,
  p_cont_information1           VARCHAR2) IS
  --
  CURSOR cel_parent_row_exists(
   p_contact_relationship_id  	NUMBER,
   p_person_id			NUMBER,
   p_contact_person_id		NUMBER) IS
   --
   SELECT 'Y' FROM per_contact_relationships
   WHERE person_id = p_person_id
   AND contact_person_id = p_contact_person_id
   AND (p_contact_relationship_id IS NULL
    OR (p_contact_relationship_id IS NOT NULL
    AND contact_relationship_id <> p_contact_relationship_id))
   AND cont_information1 = 'Y';
   --
  l_dummy			VARCHAR2(1);
  --
 BEGIN
  --
  IF p_cont_information1 = 'Y' THEN
   --
   OPEN cel_parent_row_exists(p_contact_relationship_id, p_person_id, p_contact_person_id);
   FETCH cel_parent_row_exists INTO l_dummy;
   --
   IF cel_parent_row_exists%FOUND THEN
    --
    CLOSE cel_parent_row_exists;
    --
    fnd_message.set_name(
     application => 'PER',
     name        => 'PER_JP_CON_DUP_SI_ITAX_FLAG');
    --
    fnd_message.raise_error;
    --
   END IF;
   --
   CLOSE cel_parent_row_exists;
   --
  END IF;
  --
 END chk_si_itax_flag;
--
END  per_jp_contact_relationships;

/

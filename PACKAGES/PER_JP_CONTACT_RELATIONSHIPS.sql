--------------------------------------------------------
--  DDL for Package PER_JP_CONTACT_RELATIONSHIPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JP_CONTACT_RELATIONSHIPS" AUTHID CURRENT_USER AS
/* $Header: pejpcrlh.pkh 120.0 2005/05/31 10:50:19 appldev noship $ */
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
--   p_contact_relationship_id	    Yes  NUMBER   Contact Releationship ID.
--   p_person_id		    Yes  NUMBER	  Person ID.
--   p_contact_person_id	    Yes  NUMBER   Contact Person ID.
--   p_cont_information1	    Yes  VARCHAR2 Social Insurance and Income
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
  p_person_id     		NUMBER,
  p_contact_person_id		NUMBER,
  p_cont_information1           VARCHAR2);
--
END  per_jp_contact_relationships;

 

/

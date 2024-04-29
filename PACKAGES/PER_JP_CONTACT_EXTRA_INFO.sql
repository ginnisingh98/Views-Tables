--------------------------------------------------------
--  DDL for Package PER_JP_CONTACT_EXTRA_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JP_CONTACT_EXTRA_INFO" AUTHID CURRENT_USER AS
/* $Header: pejpreih.pkh 120.0 2005/05/31 10:57:17 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_information_type >------------------------|
-- ----------------------------------------------------------------------------
procedure chk_information_type(
	p_contact_extra_info_id		in number,
	p_information_type		in varchar2,
	p_contact_relationship_id	in number,
	p_validation_start_date		in date,
	p_validation_end_date		in date);
-- ----------------------------------------------------------------------------
-- |------------------------< chk_information_type_rkd >----------------------|
-- ----------------------------------------------------------------------------
procedure chk_information_type_rkd(
	p_datetrack_mode		in varchar2,
	p_contact_extra_info_id		in number,
	p_information_type_o		in varchar2,
	p_contact_relationship_id_o	in number,
	p_validation_start_date		in date,
	p_validation_end_date		in date);
/*
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_information_type >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure verifies information types that stores the same kind of
--   information are mutually exclusive on arbitorary date.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  DATE     Date the insert is effectively
--                                                made on.  Used for validation
--                                                purpose.
--   p_contact_relationship_id      Yes  NUMBER   Contact relationship for which
--                                                the extra info applies.
--   p_information_type             Yes  VARCHAR2 Information type the extra info
--                                                applies to.
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
 PROCEDURE chk_information_type(
  p_effective_date		DATE,
  p_contact_relationship_id	NUMBER,
  p_information_type		VARCHAR2);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_future_record >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure verifies information types that stores the same kind of
--   information are mutually exclusive on arbitorary date.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  DATE     Date the insert is effectively
--                                                made on.  Used for validation
--                                                purpose.
--   p_contact_relationship_id      Yes  NUMBER   Contact relationship for which
--                                                the extra info applies.
--   p_information_type             Yes  VARCHAR2 Information type the extra info
--                                                applies to.
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
 PROCEDURE chk_future_record(
  p_effective_date		DATE,
  p_contact_relationship_id	NUMBER,
  p_information_type		VARCHAR2);
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_future_record_before_del >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure verifies information types that stores the same kind of
--   information are mutually exclusive on arbitorary date.  This procedure
--   should be called before delete.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  DATE     Date the delete is effectively
--                                                made on.  Used for validation
--                                                purpose.
--   p_contact_extra_info_id        Yes  NUMBER   Contact extra info ID.
--   p_datetrack_delete_mode	    Yes  VARCHAR2 DateTrack mode the delete uses.
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
 PROCEDURE chk_future_record_before_del(
  p_effective_date              DATE,
  p_contact_extra_info_id       NUMBER,
  p_datetrack_delete_mode       VARCHAR2);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_si_itax_flag >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure verifies si_itax_flag of the parent relationship is set to
--   'Y'.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_contact_relationship_id      Yes  NUMBER   Contact relationship for which
--                                                the extra info applies.
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
  p_contact_relationship_id	NUMBER);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_aged_parent >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure verifies aged parent living with employee is over 70 years
--   old.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  DATE     Date the insert is
--                                                effectively made on.  Used
--                                                for age culculation and
--                                                validation purpose.
--   p_contact_relationship_id      Yes  NUMBER   Contact relationship for
--                                                which the extra info applies.
--   p_information_type             Yes  VARCHAR2 Information type the extra
--                                                info applies to.
--   p_cei_information1             Yes  VARCHAR2 Entry value for aged parent
--                                                living with employee.
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
 PROCEDURE chk_aged_parent(
  p_effective_date		DATE,
  p_contact_relationship_id     NUMBER,
  p_information_type		VARCHAR2,
  p_cei_information1		VARCHAR2);
 --
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_aged_parent_before_upd >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure verifies aged parent living with employee is over 70 years
--   old and contact type is not spouse before update.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  DATE     Date the update is
--                                                effectively made on.  Used
--                                                for age culculation and
--                                                validation purpose.
--   p_datetrack_update_mode	    Yes  VARCHAR2 Datetrack update mode.
--   p_contact_relationship_id      Yes  NUMBER   Contact relationship for
--                                                which the extra info applies.
--   p_information_type             Yes  VARCHAR2 Information type the extra
--                                                info applies to.
--   p_cei_information1             Yes  VARCHAR2 Entry value for aged parent
--                                                living with employee.
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
 PROCEDURE chk_aged_parent_before_upd(
  p_effective_date              DATE,
  p_datetrack_update_mode	VARCHAR2,
  p_contact_relationship_id     NUMBER,
  p_information_type            VARCHAR2,
  p_cei_information1            VARCHAR2);
 --
*/
END per_jp_contact_extra_info;

 

/

--------------------------------------------------------
--  DDL for Package PER_CONTACT_INFO_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CONTACT_INFO_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: pecit01t.pkh 115.5 2002/12/04 12:18:11 pkakar noship $ */
-- ---------------------------------------------------------------------------
-- |-----------------------< chk_active_inactive_flag >----------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that active_inactive_flag is 'Y' or 'N'.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                       Reqd    Type            Description
--   x_active_inactive_flag     Yes     VARCHAR2        Active or Inactive
--                                                      Flag.
--
-- Out Parameters:
--   None.
--
-- Post Success:
--   The process succeeds.
--
-- Post Failure:
--   The process will be terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
 PROCEDURE chk_active_inactive_flag(
  x_active_inactive_flag        IN      per_contact_info_types.active_inactive_flag%TYPE);
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_multiple_occurences_flag >--------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that multiple_occurences_flag is 'Y' or 'N'.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                       Reqd    Type            Description
--   x_multiple_occurences_flag Yes     VARCHAR2        Multiple Occurrences
--                                                      Flag.
--
-- Out Parameters:
--   None.
--
-- Post Success:
--   The process succeeds.
--
-- Post Failure:
--   The process will be terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
 PROCEDURE chk_multiple_occurences_flag(
  x_multiple_occurences_flag    IN      per_contact_info_types.multiple_occurences_flag%TYPE);
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_update_mltpl_occrncs_flg >--------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Error when multiple_occurences_flag is updated to 'Y' from 'N'.
--
-- Prerequisites:
--   This procedure must be called after chk_multiple_occurences_flag.
--
-- In Parameters:
--   Name                       Reqd    Type            Description
--   x_information_type         Yes     VARCHAR2        Information Type.
--   x_multiple_occurences_flag Yes     VARCHAR2        Multiple Occurrences
--                                                      Flag.
--
-- Out Parameters:
--   None.
--
-- Post Success:
--   The process succeeds.
--
-- Post Failure:
--   The process will be terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
 PROCEDURE chk_update_mltpl_occrncs_flg(
  x_information_type		IN	per_contact_info_types.information_type%TYPE,
  x_multiple_occurences_flag    IN      per_contact_info_types.multiple_occurences_flag%TYPE);
--
-- ---------------------------------------------------------------------------
-- |------------------------------< insert_row >-----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Create a contact information type.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                      	Reqd    Type	        Description
--   x_rowid       		Yes     VARCHAR2        Row ID.
--   x_information_type        	Yes     VARCHAR2        Contact Information
-- 							Type.
--   x_active_inactive_flag	Yes	VARCHAR2	Active or Inactive
--							Flag.
--   x_multiple_occurences_flag	Yes	VARCHAR2	Multiple Occurrences
--							Flag.
--   x_legislation_code		Yes	VARCHAR2	Legislation Code.
--   x_description		Yes	VARCHAR2	Description.
--   x_last_update_date		Yes	DATE		Last Update Date.
--   x_last_updated_by		Yes	NUMBER		User ID who last
--							updates the row.
--   x_last_update_login	Yes	NUMBER		Login ID who last
--							updates the row.
--   x_created_by		Yes	NUMBER		User ID who creates
--							the row.
--   x_creation_date		Yes	DATE		Creation Date.
--   x_request_id		Yes	NUMBER		Request ID that
--							updates the row.
--   x_program_application_id	Yes	NUMBER		Application ID to which
--							the concurrent program
--							that updates the row
--							belongs.
--   x_program_id		Yes	NUMBER		Concurrent Program ID
--							that updates the row.
--   x_program_update_date	Yes	DATE		Date concurrent program
--							updates the row.
--   x_object_version_number	Yes	NUMBER		Version number of the
--							row.
--
-- Out Parameters:
--   Name				Type		Description
--   x_row_id				VARCHAR2	Row ID.
--
-- Post Success:
--   The process succeeds.
--
-- Post Failure:
--   The process will be terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
 PROCEDURE insert_row(
  x_rowid			IN OUT NOCOPY VARCHAR2,
  x_information_type 		IN 	VARCHAR2,
  x_active_inactive_flag	IN 	VARCHAR2,
  x_multiple_occurences_flag	IN 	VARCHAR2,
  x_legislation_code 		IN 	VARCHAR2,
  x_description			IN 	VARCHAR2,
  x_last_update_date		IN	DATE,
  x_last_updated_by		IN	NUMBER,
  x_last_update_login		IN	NUMBER,
  x_created_by			IN	NUMBER,
  x_creation_date 		IN 	DATE,
  x_request_id			IN	NUMBER,
  x_program_application_id	IN	NUMBER,
  x_program_id			IN	NUMBER,
  x_program_update_date		IN	DATE,
  x_object_version_number	IN	NUMBER);
-- ---------------------------------------------------------------------------
-- |-------------------------------< lock_row >------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Lock a contact information type.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                      	Reqd    Type	        Description
--   x_information_type        	Yes     VARCHAR2        Contact Information
-- 							Type.
--   x_active_inactive_flag	Yes	VARCHAR2	Active or Inactive
--							Flag.
--   x_multiple_occurences_flag	Yes	VARCHAR2	Multiple Occurrences
--							Flag.
--   x_legislation_code		Yes	VARCHAR2	Legislation Code.
--   x_description		Yes	VARCHAR2	Description.
--   x_object_version_number	Yes	NUMBER		Version number of the
--							row.
--
-- Out Parameters:
--   None.
--
-- Post Success:
--   The process succeeds.
--
-- Post Failure:
--   The process will be terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
 PROCEDURE lock_row(
  x_information_type		IN	VARCHAR2,
  x_active_inactive_flag	IN 	VARCHAR2,
  x_multiple_occurences_flag 	IN 	VARCHAR2,
  x_legislation_code 		IN 	VARCHAR2,
  x_description 		IN 	VARCHAR2,
  x_object_version_number	IN	NUMBER);
-- ---------------------------------------------------------------------------
-- |------------------------------< update_row >-----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Update a contact information type.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                      	Reqd    Type	        Description
--   x_information_type        	Yes     VARCHAR2        Contact Information
-- 							Type.
--   x_active_inactive_flag	Yes	VARCHAR2	Active or Inactive
--							Flag.
--   x_multiple_occurences_flag	Yes	VARCHAR2	Multiple Occurrences
--							Flag.
--   x_legislation_code		Yes	VARCHAR2	Legislation Code.
--   x_description		Yes	VARCHAR2	Description.
--   x_last_update_date		Yes	DATE		Last Update Date.
--   x_last_updated_by		Yes	NUMBER		User ID who last
--							updates the row.
--   x_last_update_login	Yes	NUMBER		Login ID who last
--							updates the row.
--   x_request_id		Yes	NUMBER		Request ID that
--							updates the row.
--   x_program_application_id	Yes	NUMBER		Application ID to which
--							the concurrent program
--							that updates the row
--							belongs.
--   x_program_id		Yes	NUMBER		Concurrent Program ID
--							that updates the row.
--   x_program_update_date	Yes	DATE		Date concurrent program
--							updates the row.
--   x_object_version_number	Yes	NUMBER		Version number of the
--							row.
--
-- Out Parameters:
--   Name                           Type     Description
--   x_object_version_number        NUMBER   Set to the version number of this
--                                           contact information type.
--
-- Post Success:
--   The process succeeds.
--
-- Post Failure:
--   The process will be terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
 PROCEDURE update_row(
  x_information_type		IN	VARCHAR2,
  x_active_inactive_flag 	IN 	VARCHAR2,
  x_multiple_occurences_flag 	IN 	VARCHAR2,
  x_legislation_code 		IN 	VARCHAR2,
  x_description 		IN 	VARCHAR2,
  x_last_update_date 		IN 	DATE,
  x_last_updated_by 		IN 	NUMBER,
  x_last_update_login 		IN 	NUMBER,
  x_request_id			IN	NUMBER,
  x_program_application_id	IN	NUMBER,
  x_program_id			IN	NUMBER,
  x_program_update_date		IN	DATE,
  x_object_version_number 	IN OUT NOCOPY NUMBER);
-- ---------------------------------------------------------------------------
-- |------------------------------< delete_row >-----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Delete a contact information type.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                       Reqd    Type            Description
--   x_information_type         Yes     VARCHAR2        Contact Information
--                                                      Type.
--
-- Out Parameters:
--   None.
--
-- Post Success:
--   The process succeeds.
--
-- Post Failure:
--   The process will be terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
 PROCEDURE delete_row(
  x_information_type 	IN 	VARCHAR2);
-- ---------------------------------------------------------------------------
-- |-------------------------------< load_row >------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Update or insert row as appropriate.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                       Reqd    Type            Description
--   x_information_type		Yes     VARCHAR2	Contact Information
--						 	Type.
--   x_active_inactive_flag     Yes	VARCHAR2        Active or Inactive
--                                                      Flag.
--   x_multiple_occurences_flag Yes	VARCHAR2	Multiple Occurrences
--                                                      Flag.
--   x_description		Yes	VARCHAR2	Description.
--   x_legislation_code		Yes	VARCHAR2	Legislation Code.
--   x_object_version_number	Yes	NUMBER		Version number of the
--                                                      row.
--   x_owner			Yes	VARCHAR2	'SEED' or 'CUSTOM'.
--
-- Out Parameters:
--   None.
--
-- Post Success:
--   The process succeeds.  No parameters are returned.
--
-- Post Failure:
--   None.
--
-- Developer Implementation Notes:
--   This procedure is called from percit.lct.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
 PROCEDURE load_row(
  x_information_type		IN	VARCHAR2,
  x_active_inactive_flag	IN	VARCHAR2,
  x_multiple_occurences_flag	IN	VARCHAR2,
  x_description			IN	VARCHAR2,
  x_legislation_code		IN	VARCHAR2,
  x_object_version_number	IN	NUMBER,
  x_owner			IN	VARCHAR2);
-- ---------------------------------------------------------------------------
-- |----------------------------< traslate_row >-----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Update translatable column.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                       Reqd    Type            Description
--   x_information_type		Yes	VARCHAR2	Contact Information
--						 	Type.
--   x_description		Yes	VARCHAR2	Description.
--   x_owner			Yes	VARCHAR2	'SEED' or 'CUSTOM'.
--
-- Out Parameters:
--   None.
--
-- Post Success:
--   The process succeeds.  No parameters are returned.
--
-- Post Failure:
--   None.
--
-- Developer Implementation Notes:
--   This procedure is called from pecit.lct.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
 PROCEDURE translate_row(
  x_information_type	IN	VARCHAR2,
  x_description		IN	VARCHAR2,
  x_owner		IN	VARCHAR2);
-- ---------------------------------------------------------------------------
-- |----------------------------< add_language >-----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Update translation table for all languages.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   None.
--
-- Out Parameters:
--   None.
--
-- Post Success:
--   The process succeeds.  No parameters are returned.
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
 PROCEDURE add_language;
-- ---------------------------------------------------------------------------
-- |-----------------------< set_translation_globals >-----------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Set global variables used in MLS validation.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name			Reqd	Type		Description
--   p_business_group_id 	Yes	NUMBER		Business Group ID.
--   p_legislation_code  	Yes	VARCHAR2	Legislation Code.
--
-- Out Parameters:
--   None.
--
-- Post Success:
--   The process succeeds.  No parameters are returned.
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
 PROCEDURE set_translation_globals(
  p_business_group_id	IN	NUMBER,
  p_legislation_code	IN	VARCHAR2);
-- ---------------------------------------------------------------------------
-- |-------------------------< validate_translation >------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validate if the translation of specified language for contact information
--   type description is unique.
--
-- Prerequisites:
--   Global variable g_dummy must be set before executing this procedure.
--
-- In Parameters:
--   Name			Reqd	Type		Description
--   information_type		Yes     VARCHAR2        Contact Information Type.
--   language			Yes	VARCHAR2	Language.
--   description		Yes	VARCHAR2	Description for Contact
--							Information Type.
-- Out Parameters:
--   None.
--
-- Post Success:
--   The process succeeds.  No parameters are returned.
--
-- Post Failure:
--   The process will be terminated.
--
-- Developer Implementation Notes:
--   This procedure is called in user-named trigger 'TRANSLATIONS' of Enter
--   Contact Relationship Extra Information form.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
 PROCEDURE validate_translation(
  information_type	IN	VARCHAR2,
  language 		IN      VARCHAR2,
  description 		IN  	VARCHAR2);
END per_contact_info_types_pkg;

 

/

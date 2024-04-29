--------------------------------------------------------
--  DDL for Package Body PER_CONTACT_INFO_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CONTACT_INFO_TYPES_PKG" AS
/* $Header: pecit01t.pkb 115.6 2002/12/04 12:18:16 pkakar noship $ */
-- +-------------------------------------------------------------------------+
-- |                          Global variables                               |
-- +-------------------------------------------------------------------------+
 g_business_group_id		NUMBER(15);
 g_legislation_code 		VARCHAR2(150);
 g_dummy 			NUMBER(1);
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
  x_active_inactive_flag	IN	per_contact_info_types.active_inactive_flag%TYPE) IS
 BEGIN

   -- = Raise an error when specified active_inactive_flag is not 'Y' or 'N'.
   IF x_active_inactive_flag NOT IN ('Y','N') THEN
     --
     hr_utility.set_message(
      applid         => 800,
      l_message_name => 'PER_52500_INV_YES_NO_FLAG');
     --
     hr_utility.set_message_token(
      l_token_name  => 'YES_NO_FLAG',
      l_token_value => 'active_inactive_flag');
     --
     hr_utility.raise_error;
   END IF;
   -- =

 END chk_active_inactive_flag;
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
  x_multiple_occurences_flag	IN	per_contact_info_types.multiple_occurences_flag%TYPE) IS
 BEGIN

   -- = Raise an error when specified multiple_occurences_flag is not 'Y' or 'N'.
   IF x_multiple_occurences_flag NOT IN ('Y','N') THEN
     --
     hr_utility.set_message(
      applid         => 800,
      l_message_name => 'PER_52500_INV_YES_NO_FLAG');
     --
     hr_utility.set_message_token(
      l_token_name  => 'YES_NO_FLAG',
      l_token_value => 'multiple_occurences_flag');
     --
     hr_utility.raise_error;
   END IF;
   -- =

 END chk_multiple_occurences_flag;
-- ---------------------------------------------------------------------------
-- |---------------------< chk_update_mltpl_occrncs_flg >--------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Error when multiple_occurences_flag is updated to 'Y' from 'N'.
--
-- Prerequisites:
--   This procedure must be called after chk_multiple_occurences_flag before
--   the update DML.
--
-- In Parameters:
--   Name                       Reqd    Type            Description
--   x_information_type         Yes     VARCHAR2	Information Type.
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
  x_information_type            IN      per_contact_info_types.information_type%TYPE,
  x_multiple_occurences_flag    IN      per_contact_info_types.multiple_occurences_flag%TYPE) IS
  --
  CURSOR cel_old_value(
   p_information_type	IN	per_contact_info_types.information_type%TYPE) IS
  SELECT multiple_occurences_flag
  FROM per_contact_info_types
  WHERE information_type = p_information_type;
  --
  l_old_value	per_contact_info_types.multiple_occurences_flag%TYPE;
  --
 BEGIN

  -- = Validate only when multiple_occurences_flag is updated to 'Y'.
  IF x_multiple_occurences_flag = 'Y' THEN
   --
   OPEN cel_old_value(x_information_type);
   FETCH cel_old_value INTO l_old_value;

   -- == Raise error when the original multiple_occurences_flag value is 'N'.
   IF l_old_value = 'N' THEN
    --
    CLOSE cel_old_value;
    --
    hr_utility.set_message(
     applid         => 800,
     l_message_name => 'PER_50048_UPD_MULTI_OCCRNCS_NO');
    --
    hr_utility.raise_error;
    --
   END IF;
   -- ==

   CLOSE cel_old_value;
   --
  END IF;
  -- =

 END chk_update_mltpl_occrncs_flg;
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
--   Name                       Reqd    Type            Description
--   x_rowid                    Yes     VARCHAR2        Row ID.
--   x_information_type         Yes     VARCHAR2        Contact Information
--                                                      Type.
--   x_active_inactive_flag     Yes     VARCHAR2        Active or Inactive
--                                                      Flag.
--   x_multiple_occurences_flag Yes     VARCHAR2        Multiple Occurrences
--                                                      Flag.
--   x_legislation_code         Yes     VARCHAR2        Legislation Code.
--   x_description              Yes     VARCHAR2        Description.
--   x_last_update_date         Yes     DATE            Last Update Date.
--   x_last_updated_by          Yes     NUMBER          User ID who last
--                                                      updates the row.
--   x_last_update_login        Yes     NUMBER          Login ID who last
--                                                      updates the row.
--   x_created_by               Yes     NUMBER          User ID who creates
--                                                      the row.
--   x_creation_date            Yes     DATE            Creation Date.
--   x_request_id               Yes     NUMBER          Request ID that
--                                                      updates the row.
--   x_program_application_id   Yes     NUMBER          Application ID to which
--                                                      the concurrent program
--                                                      that updates the row
--                                                      belongs.
--   x_program_id               Yes     NUMBER          Concurrent Program ID
--                                                      that updates the row.
--   x_program_update_date      Yes     DATE            Date concurrent program
--                                                      updates the row.
--   x_object_version_number    Yes     NUMBER          Version number of the
--                                                      row.
--
-- Out Parameters:
--   Name                               Type            Description
--   p_row_id                           VARCHAR2        Row ID.
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
  x_rowid                       IN OUT NOCOPY  VARCHAR2,
  x_information_type            IN      VARCHAR2,
  x_active_inactive_flag        IN      VARCHAR2,
  x_multiple_occurences_flag    IN      VARCHAR2,
  x_legislation_code            IN      VARCHAR2,
  x_description                 IN      VARCHAR2,
  x_last_update_date            IN      DATE,
  x_last_updated_by             IN      NUMBER,
  x_last_update_login           IN      NUMBER,
  x_created_by                  IN      NUMBER,
  x_creation_date               IN      DATE,
  x_request_id                  IN      NUMBER,
  x_program_application_id      IN      NUMBER,
  x_program_id                  IN      NUMBER,
  x_program_update_date         IN      DATE,
  x_object_version_number       IN      NUMBER) IS
  --
  CURSOR c IS
   SELECT ROWID
   FROM per_contact_info_types
   WHERE information_type = x_information_type;
  --
 BEGIN
   --
   chk_active_inactive_flag(
    x_active_inactive_flag => x_active_inactive_flag);
   --
   chk_multiple_occurences_flag(
    x_multiple_occurences_flag => x_multiple_occurences_flag);
   --
   INSERT INTO per_contact_info_types(
    information_type,
    active_inactive_flag,
    multiple_occurences_flag,
    legislation_code,
--    last_update_date,
--    last_updated_by,
--    last_update_login,
--    created_by,
--    creation_date,
--    request_id,
--    program_application_id,
--    program_id,
--    program_update_date,
    object_version_number)
   VALUES(
    x_information_type,
    x_active_inactive_flag,
    x_multiple_occurences_flag,
    x_legislation_code,
--    x_last_update_date,
--    x_last_updated_by,
--    x_last_update_login,
--    x_created_by,
--    x_creation_date,
--    x_request_id,
--    x_program_application_id,
--    x_program_id,
--    x_program_update_date,
    x_object_version_number);
   --
   INSERT INTO per_contact_info_types_tl(
    information_type,
    language,
    source_lang,
    description,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date)
   SELECT
    x_information_type,
    l.language_code,
    USERENV('LANG'),
    x_description,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_login,
    x_created_by,
    x_creation_date
   FROM fnd_languages l
   WHERE l.installed_flag IN ('I','B')
   AND NOT EXISTS(
    SELECT NULL
     FROM per_contact_info_types_tl t
     WHERE t.information_type = x_information_type
     AND t.language = l.language_code);
   --
   OPEN c;
   FETCH c INTO x_rowid;

   -- = Raise error if the insert to the base table fails.
   IF c%NOTFOUND THEN
      close c;
      RAISE NO_DATA_FOUND;
   END IF;
   -- =

   CLOSE c;
 END insert_row;
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
--   Name                       Reqd    Type            Description
--   x_information_type         Yes     VARCHAR2        Contact Information
--                                                      Type.
--   x_active_inactive_flag     Yes     VARCHAR2        Active or Inactive
--                                                      Flag.
--   x_multiple_occurences_flag Yes     VARCHAR2        Multiple Occurrences
--                                                      Flag.
--   x_legislation_code         Yes     VARCHAR2        Legislation Code.
--   x_description              Yes     VARCHAR2        Description.
--   x_object_version_number    Yes     NUMBER          Version number of the
--                                                      row.
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
  x_information_type            IN      VARCHAR2,
  x_active_inactive_flag        IN      VARCHAR2,
  x_multiple_occurences_flag    IN      VARCHAR2,
  x_legislation_code            IN      VARCHAR2,
  x_description                 IN      VARCHAR2,
  x_object_version_number	IN	NUMBER) IS
  --
  CURSOR c IS
   SELECT
    active_inactive_flag,
    multiple_occurences_flag,
    legislation_code,
    object_version_number
   FROM per_contact_info_types
   WHERE information_type = x_information_type
   FOR UPDATE OF information_type NOWAIT;
  --
  recinfo	c%ROWTYPE;
  --
  CURSOR c1 IS
   SELECT
    description,
    DECODE(language,USERENV('LANG'),'Y',
                                    'N') baselang
   FROM per_contact_info_types_tl
   WHERE information_type = x_information_type
   AND USERENV('LANG') IN (language,source_lang)
   FOR UPDATE OF information_type NOWAIT;
  --
 BEGIN
   OPEN c;
   FETCH c INTO recinfo;

   -- = Raise error when specified information type does not exist in the base table.
   IF c%NOTFOUND THEN
     CLOSE c;
     --
     fnd_message.set_name(
      application => 'FND',
      name        => 'FORM_RECORD_DELETED');
     --
     app_exception.raise_exception;
   END IF;
   -- =

   CLOSE c;

   -- = Raise error when record is updated by validating object version number.
   IF x_object_version_number <> recinfo.object_version_number THEN
     --
     fnd_message.set_name(
      application => 'PAY',
      name        => 'HR_7155_OBJECT_INVALID');
     --
     fnd_message.raise_error;
   END IF;
   -- =

   -- = Raise error when at least one of active_inactive_flag, multiple_occurences_flag,
   -- = object_version_number, legislation_code is updated.
   IF recinfo.active_inactive_flag = x_active_inactive_flag
    AND recinfo.multiple_occurences_flag = x_multiple_occurences_flag
    AND NVL(recinfo.legislation_code,'x') = NVL(x_legislation_code,'x')
    AND NVL(recinfo.object_version_number,0) = NVL(x_object_version_number,0) THEN
     --
     NULL;
   ELSE
     --
     fnd_message.set_name(
      application => 'FND',
      name        => 'FORM_RECORD_CHANGED');
     --
     app_exception.raise_exception;
   END IF;
   -- =

   FOR tlinfo IN c1 LOOP

     -- = Check if description is updated for base language.
     IF tlinfo.baselang = 'Y' THEN

       -- == Raise error when description is updated.
       IF tlinfo.description = x_description
        OR (tlinfo.description IS NULL
         AND x_description IS NULL) THEN
         --
         NULL;
       ELSE
         --
         fnd_message.set_name(
          application => 'FND',
          name        =>  'FORM_RECORD_CHANGED');
         --
         app_exception.raise_exception;
       END IF;
       -- ==

     END IF;
     -- =

   END LOOP;
   RETURN;
 END lock_row;
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
--   Name                       Reqd    Type            Description
--   x_information_type         Yes     VARCHAR2        Contact Information
--                                                      Type.
--   x_active_inactive_flag     Yes     VARCHAR2        Active or Inactive
--                                                      Flag.
--   x_multiple_occurences_flag Yes     VARCHAR2        Multiple Occurrences
--                                                      Flag.
--   x_legislation_code         Yes     VARCHAR2        Legislation Code.
--   x_description              Yes     VARCHAR2        Description.
--   x_last_update_date         Yes     DATE            Last Update Date.
--   x_last_updated_by          Yes     NUMBER          User ID who last
--                                                      updates the row.
--   x_last_update_login        Yes     NUMBER          Login ID who last
--                                                      updates the row.
--   x_request_id               Yes     NUMBER          Request ID that
--                                                      updates the row.
--   x_program_application_id   Yes     NUMBER          Application ID to which
--                                                      the concurrent program
--                                                      that updates the row
--                                                      belongs.
--   x_program_id               Yes     NUMBER          Concurrent Program ID
--                                                      that updates the row.
--   x_program_update_date      Yes     DATE            Date concurrent program
--                                                      updates the row.
--   x_object_version_number    Yes     NUMBER          Version number of the
--                                                      row.
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
  x_information_type		IN 	VARCHAR2,
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
  x_object_version_number 	IN OUT NOCOPY NUMBER) IS
  --
  CURSOR get_object_version_number IS
   SELECT NVL(MAX(object_version_number),0)+1
   FROM per_contact_info_types
   WHERE information_type = x_information_type;
  --
  l_ovn		NUMBER;
 BEGIN
   --
   chk_active_inactive_flag(
    x_active_inactive_flag => x_active_inactive_flag);
   --
   chk_multiple_occurences_flag(
    x_multiple_occurences_flag => x_multiple_occurences_flag);
   --
   chk_update_mltpl_occrncs_flg(
    x_information_type         => x_information_type,
    x_multiple_occurences_flag => x_multiple_occurences_flag);
   --
   OPEN get_object_version_number;
   FETCH get_object_version_number INTO l_ovn;
   CLOSE get_object_version_number;
   --
   UPDATE per_contact_info_types
   SET
    active_inactive_flag = x_active_inactive_flag,
    multiple_occurences_flag = x_multiple_occurences_flag,
    legislation_code = x_legislation_code,
    object_version_number = l_ovn
--    last_update_date = x_last_update_date,
--    last_updated_by = x_last_updated_by,
--    last_update_login = x_last_update_login,
--    request_id = x_request_id,
--    program_application_id = x_program_application_id,
--    program_id = x_program_id,
--    program_update_date = x_program_update_date
   WHERE information_type = x_information_type;
   --

   -- = Raise error when the specified information type does not exist.
   IF SQL%NOTFOUND THEN
     RAISE NO_DATA_FOUND;
   END IF;
   -- =

   --
   UPDATE per_contact_info_types_tl
   SET
    description = x_description,
    last_update_date = x_last_update_date,
    last_updated_by = x_last_updated_by,
    last_update_login = x_last_update_login,
    source_lang = USERENV('LANG')
   WHERE information_type = x_information_type
   AND USERENV('LANG') IN (language,source_lang);
   --

   -- = Raise error when the row for the language of user's environment does
   -- = not exist.
   IF SQL%NOTFOUND THEN
     RAISE NO_DATA_FOUND;
   END IF;
   -- =

   x_object_version_number := l_ovn;
 END update_row;
--
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
  x_information_type	IN 	VARCHAR2) IS
 BEGIN
  --
  DELETE FROM per_contact_extra_info_f
  WHERE information_type = x_information_type;
  --
  DELETE FROM per_contact_info_types_tl
  WHERE information_type = x_information_type;
  --

  -- = Raise error when the specified information type does not exist.
  IF SQL%NOTFOUND THEN
    RAISE NO_DATA_FOUND;
  END IF;
  -- =

  --
  DELETE FROM per_contact_info_types
  WHERE information_type = x_information_type;
  --

  -- = Raise error when the row for the language of user's environment does
  -- = not exist.
  IF SQL%NOTFOUND THEN
    RAISE NO_DATA_FOUND;
  END IF;
  -- =

 END delete_row;
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
--   x_information_type         Yes     VARCHAR2        Contact Information
--                                                      Type.
--   x_active_inactive_flag     Yes     VARCHAR2        Active or Inactive
--                                                      Flag.
--   x_multiple_occurences_flag Yes     VARCHAR2        Multiple Occurrences
--                                                      Flag.
--   x_description              Yes     VARCHAR2        Description.
--   x_legislation_code         Yes     VARCHAR2        Legislation Code.
--   x_object_version_number    Yes     NUMBER          Version number of the
--                                                      row.
--   x_owner                    Yes     VARCHAR2        'SEED' or 'CUSTOM'.
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
  x_information_type            IN      VARCHAR2,
  x_active_inactive_flag        IN      VARCHAR2,
  x_multiple_occurences_flag    IN      VARCHAR2,
  x_description                 IN      VARCHAR2,
  x_legislation_code            IN      VARCHAR2,
  x_object_version_number       IN      NUMBER,
  x_owner                       IN      VARCHAR2) IS
  --
  l_proc			VARCHAR2(61) := 'PER_CONTACT_INFO_TYPES_PKG.LOAD_ROW';
  l_rowid			ROWID;
  l_request_id			per_contact_info_types.request_id%TYPE;
  l_program_application_id	per_contact_info_types.program_application_id%TYPE;
  l_program_id			per_contact_info_types.program_id%TYPE;
  l_program_update_date		per_contact_info_types.program_update_date%TYPE;
  l_created_by			per_contact_info_types.created_by%TYPE := 0;
  l_creation_date		per_contact_info_types.creation_date%TYPE := SYSDATE;
  l_last_update_date		per_contact_info_types.last_update_date%TYPE := SYSDATE;
  l_last_updated_by		per_contact_info_types.last_updated_by%TYPE := 0;
  l_last_update_login		per_contact_info_types.last_update_login%TYPE := 0;
  l_object_version_number	per_contact_info_types.object_version_number%TYPE;
  --
 BEGIN
  --
  -- Translate developer keys to internal parameters.
  --
  IF x_owner = 'SEED' THEN
   --
   l_created_by := 1;
   l_last_updated_by := 1;
   --
  END IF;
  --
  -- Update or insert row as appropriate.
  --
  BEGIN
   --
   l_object_version_number := x_object_version_number;
   --
   update_row(
    x_information_type         => x_information_type,
    x_active_inactive_flag     => x_active_inactive_flag,
    x_multiple_occurences_flag => x_multiple_occurences_flag,
    x_legislation_code         => x_legislation_code,
    x_description              => x_description,
    x_last_update_date         => l_last_update_date,
    x_last_updated_by          => l_last_updated_by,
    x_last_update_login        => l_last_update_login,
    x_request_id               => l_request_id,
    x_program_application_id   => l_program_application_id,
    x_program_id               => l_program_id,
    x_program_update_date      => l_program_update_date,
    x_object_version_number    => l_object_version_number);
   --
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
    --
    insert_row(
     x_rowid                    => l_rowid,
     x_information_type         => x_information_type,
     x_active_inactive_flag     => x_active_inactive_flag,
     x_multiple_occurences_flag => x_multiple_occurences_flag,
     x_legislation_code         => x_legislation_code,
     x_description              => x_description,
     x_last_update_date         => l_last_update_date,
     x_last_updated_by          => l_last_updated_by,
     x_last_update_login        => l_last_update_login,
     x_created_by               => l_created_by,
     x_creation_date            => l_creation_date,
     x_request_id               => l_request_id,
     x_program_application_id   => l_program_application_id,
     x_program_id               => l_program_id,
     x_program_update_date      => l_program_update_date,
     x_object_version_number    => x_object_version_number);
    --
  END;
 END load_row;
-- ---------------------------------------------------------------------------
-- |---------------------------< translate_row >-----------------------------|
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
--   x_information_type         Yes     VARCHAR2        Contact Information
--                                                      Type.
--   x_description              Yes     VARCHAR2        Description.
--   x_owner                    Yes     VARCHAR2        'SEED' or 'CUSTOM'.
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
  x_information_type    IN      VARCHAR2,
  x_description         IN      VARCHAR2,
  x_owner               IN      VARCHAR2) IS
 BEGIN
  --
  UPDATE per_contact_info_types_tl SET
   description = x_description,
   last_update_date = SYSDATE,
   last_updated_by = DECODE(x_owner,'SEED',1,0),
   last_update_login = 0,
   source_lang = USERENV('lang')
  WHERE userenv('lang') IN (language,source_lang)
  AND information_type = x_information_type;
  --
 END translate_row;
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
 PROCEDURE add_language IS
 BEGIN
  --
  DELETE FROM per_contact_info_types_tl pcitt
  WHERE NOT EXISTS(
   SELECT NULL FROM per_contact_info_types pcit
   WHERE pcit.information_type = pcitt.information_type);
  --
  UPDATE per_contact_info_types_tl pcitt_t SET
   description = (SELECT pcitt_b.description
                  FROM per_contact_info_types_tl pcitt_b
                  WHERE pcitt_b.information_type = pcitt_t.information_type
                  AND pcitt_b.language = pcitt_t.source_lang)
  WHERE (pcitt_t.information_type, pcitt_t.language) IN
                 (SELECT pcitt_sub_t.information_type, pcitt_sub_t.language
                  FROM per_contact_info_types_tl pcitt_sub_b, per_contact_info_types_tl pcitt_sub_t
                  WHERE pcitt_sub_b.information_type = pcitt_sub_t.information_type
                  AND pcitt_sub_b.language = pcitt_sub_t.source_lang
                  AND (pcitt_sub_b.description <> pcitt_sub_t.description
                   OR (pcitt_sub_b.description IS NULL AND pcitt_sub_t.description IS NOT NULL)
                   OR (pcitt_sub_b.description IS NOT NULL AND pcitt_sub_t.description IS NULL)));
  --
  INSERT INTO per_contact_info_types_tl(
   information_type,
   language,
   source_lang,
   description,
   last_update_date,
   last_updated_by,
   last_update_login,
   created_by,
   creation_date)
  SELECT
   pcitt.information_type,
   fl.language_code,
   pcitt.source_lang,
   pcitt.description,
   pcitt.last_update_date,
   pcitt.last_updated_by,
   pcitt.last_update_login,
   pcitt.created_by,
   pcitt.creation_date
  FROM
   per_contact_info_types_tl pcitt,
   fnd_languages fl
  WHERE fl.installed_flag IN ('I', 'B')
  AND pcitt.language = USERENV('LANG')
  AND NOT EXISTS(
   SELECT NULL FROM per_contact_info_types_tl pcitt_t
   WHERE pcitt_t.information_type = pcitt.information_type
   AND pcitt_t.language = fl.language_code);
 --
 END add_language;
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
--   Name                      Reqd    Type            Description
--   p_business_group_id       Yes     NUMBER          Business Group ID.
--   p_legislation_code        Yes     VARCHAR2        Legislation Code.
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
  p_legislation_code	IN 	VARCHAR2) IS
 BEGIN
  g_business_group_id := p_business_group_id;
  g_legislation_code := p_legislation_code;
 END set_translation_globals;
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
--   Name                      Reqd    Type            Description
--   information_type          Yes     VARCHAR2        Contact Information Type.
--   language                  Yes     VARCHAR2        Language.
--   description               Yes     VARCHAR2        Description for Contact
--                                                     Information Type.
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
  information_type	IN 	VARCHAR2,
  language		IN	VARCHAR2,
  description		IN	VARCHAR2) IS
  --
  l_package_name 		VARCHAR2(80) := 'PER_CONTACT_INFO_TYPES_PKG.VALIDATE_TRANSLATION';
  --
  CURSOR c_translation(
   p_language		IN	VARCHAR2,
   p_description 	IN 	VARCHAR2,
   p_information_type 	IN 	VARCHAR2) IS
   SELECT 1 FROM
    per_contact_info_types_tl citt,
    per_contact_info_types cit
    WHERE UPPER(citt.description) = UPPER(p_description)
    AND citt.information_type = cit.information_type
    AND citt.language = p_language
    AND (cit.information_type <> p_information_type
     OR p_information_type IS NULL);
  --
 BEGIN
  --
  hr_utility.set_location(
   procedure_name => l_package_name,
   stage          => 10);
  --
  OPEN c_translation(language, description, information_type);
  --
  hr_utility.set_location(
   procedure_name => l_package_name,
   stage          => 50);
  --
  FETCH c_translation INTO g_dummy;
  -- = fail if a description translation is already present in the table for a
  -- = given language.  Otherwise, no action is performed.
  IF c_translation%NOTFOUND THEN
   --
   hr_utility.set_location(
    procedure_name => l_package_name,
    stage          => 60);
   --
   CLOSE c_translation;
  ELSE
   --
   hr_utility.set_location(
    procedure_name => l_package_name,
    stage          => 70);
   --
   fnd_message.set_name(
    application	=> 'PAY',
    name	=> 'HR_TRANSLATION_EXISTS');
   --
   fnd_message.raise_error;
  END IF;
  -- =
  --
  hr_utility.set_location(
   procedure_name => 'Leaving:' || l_package_name,
   stage	  => 80);
  --
 END validate_translation;
END per_contact_info_types_pkg;

/

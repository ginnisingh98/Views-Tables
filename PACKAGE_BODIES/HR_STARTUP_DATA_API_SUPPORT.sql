--------------------------------------------------------
--  DDL for Package Body HR_STARTUP_DATA_API_SUPPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_STARTUP_DATA_API_SUPPORT" AS
/* $Header: hrsdasup.pkb 120.0 2005/05/31 02:37:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< enable_startup_mode >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE enable_startup_mode
                 (p_mode IN varchar2
                 ,p_startup_session_id IN number default null) IS
--
BEGIN
  --
  hr_startup_data_api_support.g_startup_mode := p_mode;
  hr_startup_data_api_support.g_startup_session_id := p_startup_session_id;
  hr_utility.trace('enable_startup_mode');
  hr_utility.trace('mode is: ' || hr_startup_data_api_support.g_startup_mode);
  hr_utility.trace('sessionid is: '||to_char(hr_startup_data_api_support.g_startup_session_id));
  --
END enable_startup_mode;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< return_startup_mode >----------------------------|
-- ----------------------------------------------------------------------------
FUNCTION return_startup_mode RETURN varchar2 IS
--
BEGIN
  hr_utility.trace('entering return_startup_mode');
  hr_utility.trace('return val : ' || hr_startup_data_api_support.g_startup_mode);
  RETURN (hr_startup_data_api_support.g_startup_mode);
END return_startup_mode;
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_owner_definition >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_owner_definition(p_product_shortname IN varchar2
                                 ,p_validate IN boolean) IS
--
-- Cursor to determine session_id.
CURSOR csr_get_session_id IS
  SELECT userenv('sessionid') from dual;
--
BEGIN
  --
  -- Issue savepoint
  SAVEPOINT ins_owner_def;
  --
  -- Fetch session_id
  IF hr_startup_data_api_support.g_session_id IS NULL THEN
    if hr_startup_data_api_support.g_startup_session_id is null then
      OPEN csr_get_session_id;
      FETCH csr_get_session_id INTO hr_startup_data_api_support.g_session_id;
      CLOSE csr_get_session_id;
    else
      hr_startup_data_api_support.g_session_id :=
                          hr_startup_data_api_support.g_startup_session_id;
    end if;
  END IF;
  --
  hr_utility.trace('create_owner_definition');
  hr_utility.trace('session id: ' || to_char(hr_startup_data_api_support.g_session_id));
  hr_utility.trace('product_short_name: ' || p_product_shortname);
  INSERT INTO hr_owner_definitions
    (session_id
    ,product_short_name)
  VALUES
    (hr_startup_data_api_support.g_session_id
    ,p_product_shortname);
  --
  -- When in validation mode, raise validation enabled exception
  IF p_validate THEN
     hr_utility.trace('p_validate is TRUE');
     raise hr_api.validate_enabled;
  END IF;
  --
EXCEPTION
  WHEN hr_api.validate_enabled THEN
     -- As validate_enabled exception raised, roll back to savepoint
     hr_utility.trace('raising hr_api.validate_enabled');
     ROLLBACK TO ins_owner_def;
  WHEN others THEN
     -- Unexpected error
     hr_utility.trace('raising unknown error');
     ROLLBACK TO ins_owner_def;
     raise;
END create_owner_definition;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_owner_definitions >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_owner_definitions(p_validate IN boolean) IS
--
CURSOR csr_get_sessionid IS
  SELECT userenv('sessionid')
    FROM dual;
--
BEGIN
  --
  hr_utility.trace('delete_owner_definitions');
  -- Issue savepoint
  SAVEPOINT del_owner_defs;
  --
  -- Delete rows for current session
  DELETE FROM hr_owner_definitions
  WHERE session_id = userenv('sessionid');
  --
  -- When in validation mode, raise validation enabled exception
  IF p_validate THEN
     hr_utility.trace('p_validate is TRUE');
     RAISE hr_api.validate_enabled;
  END IF;
  --
EXCEPTION
  WHEN hr_api.validate_enabled THEN
    --
    -- Rollback to savepoint, as validate_enabled trigger has been raised
    hr_utility.trace('raising hr_api.validate_enabled');
    ROLLBACK TO del_owner_defs;
    --
  WHEN OTHERS THEN
    -- Unexpected error
    hr_utility.trace('raising unknown error');
    ROLLBACK TO del_owner_defs;
    RAISE;
END delete_owner_definitions;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< mode_allowed >--------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE mode_allowed(p_generic IN boolean
                      ,p_startup IN boolean
                      ,p_user    IN boolean) IS
--
BEGIN
  hr_startup_data_api_support.g_generic_allowed := p_generic;
  hr_startup_data_api_support.g_startup_allowed := p_startup;
  hr_startup_data_api_support.g_user_allowed    := p_user;
  hr_utility.trace('mode_allowed');
  if p_generic then hr_utility.trace('p_generic : TRUE'); else hr_utility.trace('p_generic : FALSE'); end if;
  if p_startup then hr_utility.trace('p_startup : TRUE'); else hr_utility.trace('p_startup : FALSE'); end if;
  if p_user then hr_utility.trace('p_user : TRUE'); else hr_utility.trace('p_user : FALSE'); end if;
END mode_allowed;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_startup_action >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according to
--  the current startup mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_startup_action
  (p_generic_allowed   IN boolean
  ,p_startup_allowed   IN boolean
  ,p_user_allowed      IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2
  ) IS
--
CURSOR csr_check_exists (p_session_id number) IS
  SELECT 'Y'
    FROM hr_owner_definitions def
   WHERE def.session_id = p_session_id;
--
l_exists  varchar2(1);
l_mode    varchar2(10);
l_proc    varchar2(72) := 'chk_startup_action';
l_session_id number;
--
BEGIN
  -- fetch startup mode
  l_mode := hr_startup_data_api_support.return_startup_mode;
  l_session_id := nvl(hr_startup_data_api_support.g_startup_session_id
                     , userenv('sessionid'));
  --
  hr_utility.trace('chk_startup_action');
  hr_utility.trace('l_session_id : ' || to_char(l_session_id));
  hr_utility.trace('hr_startup_data_api_support.g_startup_session_id : ' || to_char(hr_startup_data_api_support.g_startup_session_id));
  hr_utility.trace('l_mode : ' || l_mode);
  hr_utility.trace('p_business_group_id : ' || nvl(to_char(p_business_group_id), 'NULL'));
  hr_utility.trace('p_legislation_code : ' || nvl(p_legislation_code, 'NULL'));
  hr_utility.trace('p_legislation_subgroup : ' || nvl(p_legislation_subgroup, 'NULL'));

  -- Only perform checks is API is not being called by SDM
  IF (l_mode <> 'DELIVERY') THEN
     IF ((p_business_group_id IS NULL) AND
         (p_legislation_code IS NULL) AND
         (p_legislation_subgroup IS NULL)) THEN
        IF ((l_mode <> 'GENERIC') OR (NOT p_generic_allowed)) THEN
           -- Generic rows being inserted, yet shouldnt be
           fnd_message.set_name('PER', 'PER_289140_STARTUP_GEN_MOD_ERR');
           fnd_message.raise_error;
        ELSE
           hr_utility.trace('Entering PER_289141_STARTUP_OWN_DEF_ERR else stmt');
           hr_utility.trace('l_session_id : ' || to_char(l_session_id));
           OPEN csr_check_exists(l_session_id);
           FETCH csr_check_exists INTO l_exists;
           IF csr_check_exists%NOTFOUND THEN
              hr_utility.trace('didnt find the id');
              CLOSE csr_check_exists;
              fnd_message.set_name('PER', 'PER_289141_STARTUP_OWN_DEF_ERR');
              fnd_message.raise_error;
           END IF;
           CLOSE csr_check_exists;
        END IF;
     ELSIF ((p_business_group_id IS NULL) AND
            (p_legislation_code IS NOT NULL)) THEN
        IF ((l_mode <> 'STARTUP') OR (NOT p_startup_allowed)) THEN
           -- Startup row being inserted, but shouldnt be
           fnd_message.set_name('PER', 'PER_289142_STARTUP_ST_MODE_ERR');
           fnd_message.raise_error;
        ELSE
           OPEN csr_check_exists(l_session_id);
           FETCH csr_check_exists INTO l_exists;
           IF csr_check_exists%NOTFOUND THEN
              CLOSE csr_check_exists;
              fnd_message.set_name('PER', 'PER_289141_STARTUP_OWN_DEF_ERR');
              fnd_message.raise_error;
           END IF;
           CLOSE csr_check_exists;
        END IF;
     ELSE
        IF ((l_mode <> 'USER') OR (NOT p_user_allowed)) THEN
           fnd_message.set_name('PER', 'PER_289143_STARTUP_USR_MOD_ERR');
           fnd_message.raise_error;
        END IF;
     END IF;
  END IF;
END chk_startup_action;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_upd_del_startup_action >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_upd_del_startup_action
  (p_generic_allowed   IN boolean
  ,p_startup_allowed   IN boolean
  ,p_user_allowed      IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2
  ) IS
--
l_mode    varchar2(10);
l_proc    varchar2(72) := 'chk_startup_action';
--
BEGIN
  -- fetch startup mode
  l_mode := hr_startup_data_api_support.return_startup_mode;
  -- Only perform checks if API is not being called by SDM
  IF (l_mode <> 'DELIVERY') THEN
     IF ((p_business_group_id IS NULL) AND
         (p_legislation_code IS NULL) AND
         (p_legislation_subgroup IS NULL)) THEN
        IF ((l_mode <> 'GENERIC') OR (NOT p_generic_allowed)) THEN
           -- Generic rows being inserted, yet shouldnt be
           fnd_message.set_name('PER', 'PER_289140_STARTUP_GEN_MOD_ERR');
           fnd_message.raise_error;
        END IF;
     ELSIF ((p_business_group_id IS NULL) AND
            (p_legislation_code IS NOT NULL)) THEN
        IF ((l_mode <> 'STARTUP') OR (NOT p_startup_allowed)) THEN
           -- Startup row being inserted, but shouldnt be
           fnd_message.set_name('PER', 'PER_289142_STARTUP_ST_MODE_ERR');
           fnd_message.raise_error;
        END IF;
     ELSE
        IF ((l_mode <> 'USER') OR (NOT p_user_allowed)) THEN
           fnd_message.set_name('PER', 'PER_289143_STARTUP_USR_MOD_ERR');
           fnd_message.raise_error;
        END IF;
     END IF;
  END IF;
END chk_upd_del_startup_action;
--
END hr_startup_data_api_support;

/

--------------------------------------------------------
--  DDL for Package HR_STARTUP_DATA_API_SUPPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_STARTUP_DATA_API_SUPPORT" AUTHID CURRENT_USER AS
/* $Header: hrsdasup.pkh 115.1 2002/08/16 21:45:22 tjesumic noship $ */
--
g_startup_mode varchar2(10) := 'USER';
g_session_id   number := NULL;
g_startup_allowed boolean := TRUE;
g_generic_allowed boolean := TRUE;
g_user_allowed boolean := TRUE;
g_startup_session_id number := NULL;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< enable_startup_mode >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure is called prior to calling an API for a startup data entity,
--  and is used to set the global variable which will indicate the mode which
--  is to be used for thr startup data entity.
--
-- Post Success:
--  The global variable will be set which determines the mode for startup
--  data entities.
--
-- For Oracle Internal Use Only.
--
-- ----------------------------------------------------------------------------
PROCEDURE enable_startup_mode
                (p_mode               IN VARCHAR2
                ,p_startup_session_id IN NUMBER DEFAULT null);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< return_startup_mode >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This function is called to return the value of the global variable which
--  holds the startup data mode.
--
-- ----------------------------------------------------------------------------
FUNCTION return_startup_mode RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_owner_definition >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure is called prior to calling the API to insert/update/delete
--  startup data.  It will perform the same function as the PAYWSDOP form, and
--  will insert one row into the HR_OWNER_DEFINITIONS table.
--
-- Post success:
--  A row will be inserted into the HR_OWNER_DEFINITIONS table for the current
--  session.
-- ----------------------------------------------------------------------------
PROCEDURE create_owner_definition(p_product_shortname IN varchar2
                                 ,p_validate          IN boolean default false);
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_owner_definitions >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure, when called, will clear the rows from the
--  HR_OWNER_DEFINITIONS table, for the current session.
--
-- Post success:
--  For the current session, all rows will be removed from the
--  HR_OWNER_DEFINITIONS table.
-- ----------------------------------------------------------------------------
PROCEDURE delete_owner_definitions(p_validate IN boolean default false);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_startup_action >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according to
--  the current startup mode, when called from insert_validate procedure.  Will
--  check that a row exists in the hr_owner_definitions table also.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_startup_action
  (p_generic_allowed   IN boolean
  ,p_startup_allowed   IN boolean
  ,p_user_allowed      IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_upd_del_startup_action >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according to
--  the current startup mode, when called from update_validate or
--  delete_validate procedures.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_upd_del_startup_action
  (p_generic_allowed   IN boolean
  ,p_startup_allowed   IN boolean
  ,p_user_allowed      IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2
  );
--
END hr_startup_data_api_support;

 

/

--------------------------------------------------------
--  DDL for Package HR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_API" AUTHID CURRENT_USER As
/* $Header: hrapiapi.pkh 120.0.12010000.1 2008/07/27 21:42:36 appldev ship $ */
--
  --
  -- Exception Handlers
  --
  Object_Locked			Exception;
  Validate_Enabled		Exception;
  Argument_Changed		Exception;
  Check_Integrity_Violated	Exception;
  Parent_Integrity_Violated	Exception;
  Child_Integrity_Violated	Exception;
  Unique_Integrity_Violated     Exception;
  Cannot_Find_Prog_Unit         Exception;
  --
  -- Pragmas
  --
  Pragma Exception_Init(Object_Locked, -0054);
  Pragma Exception_Init(Check_Integrity_Violated, -2290);
  Pragma Exception_Init(Parent_Integrity_Violated, -2291);
  Pragma Exception_Init(Child_Integrity_Violated, -2292);
  Pragma Exception_Init(Unique_Integrity_Violated, -0001);
  Pragma Exception_Init(Cannot_Find_Prog_Unit, -6508);
  --
  -- API constant system defaults
  --
  g_varchar2	constant varchar2(9) := '$Sys_Def$';
  g_number	constant number      := -987123654;
  g_date	constant date	     := to_date('01-01--4712', 'DD-MM-SYYYY');
  --
  -- API constant boolean values
  g_true_num    constant number      := 1;
  g_false_num   constant number      := 0;
  --
  g_insert                constant varchar2(30) := 'INSERT';
  g_correction            constant varchar2(30) := 'CORRECTION';
  g_update                constant varchar2(30) := 'UPDATE';
  g_update_override       constant varchar2(30) := 'UPDATE_OVERRIDE';
  g_update_change_insert  constant varchar2(30) := 'UPDATE_CHANGE_INSERT';
  g_zap                   constant varchar2(30) := 'ZAP';
  g_delete                constant varchar2(30) := 'DELETE';
  g_future_change         constant varchar2(30) := 'FUTURE_CHANGE';
  g_delete_next_change    constant varchar2(30) := 'DELETE_NEXT_CHANGE';
  --
  -- Generic constant global date defaults
  --
  -- NOTE: If any of these defaults should have to be changed then
  --       please change the forms4 library keeping the default values in
  --       sync:
  --       Forms 4 Lib: HR_GEN
  --        F4 Package: HR_API
  --
  g_eot constant date := to_date('31-12-4712', 'DD-MM-YYYY'); -- End Of Time
  g_sot	constant date := to_date('01-01-0001', 'DD-MM-YYYY'); -- Start Of Time
  g_sys	constant date := trunc(sysdate);                      -- System Date.
  --
  -- Internal hr_api globals
  --
  g_package constant varchar2(33) := '  hr_api.';
  --
  --
--
  Procedure mandatory_arg_error
            (p_api_name         in      varchar2,
             p_argument         in      varchar2,
             p_argument_value   in      varchar2);
--
  Procedure mandatory_arg_error
            (p_api_name         in      varchar2,
             p_argument         in      varchar2,
             p_argument_value   in      date);
--
  Procedure mandatory_arg_error
            (p_api_name         in      varchar2,
             p_argument         in      varchar2,
             p_argument_value   in      number);
--
  Procedure argument_changed_error
            (p_api_name         in      varchar2,
             p_argument         in      varchar2,
             p_base_table       in      varchar2 default null);
--
  Function hr_installed Return Boolean;
--
  Function return_business_group_id
         (p_name in      per_organization_units.name%TYPE)
          Return per_organization_units.business_group_id%TYPE;
--
  Function return_lookup_code
         (p_meaning     in      fnd_common_lookups.meaning%TYPE default null,
          p_lookup_type in      fnd_common_lookups.lookup_type%TYPE)
         Return fnd_common_lookups.lookup_code%TYPE;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_security_group_id >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Sets the given security_group_id in CLIENT_INFO. This procedure must
--   be called when hr_api.validate_bus_grp_id has not been called and
--   where the security_group value affects data validation. For example,
--   this procedure must be called before using the HR_LOOKUPS view or
--   referencing a view which joins to HR_LOOKUPS.
--
-- Prerequisites:
--   Security_group_id is known to exist and corresponds to the current
--   business group context. This procedure will not validate the
--   security_group_id exists.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_security_group_id            Yes  Number   Current security group id.
--                                                Ususally derived from the
--                                                current business group
--                                                context.
--
-- Post Success:
--   The security_group_id will be set in client_info.
--
-- Post Failure:
--   An error is raised if the value is not suitable for client_info.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure set_security_group_id
(p_security_group_id             in     number
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< validate_bus_grp_id >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the given business_group_id exists. When the ID is valid
--   CLIENT_INFO will also be set with the given security_group_id.
--
--   If this procedure is called before performing any lookup validation
--   or referencing a view which joins to HR_LOOKUPS then it is not
--   necessary to call hr_api.set_security_group_id as well.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_business_group_id            Yes  Number   Business group id to
--                                                validate and use for
--                                                setting CLIENT_INFO.
--
-- Post Success:
--   The business_group_id is validate and CLIENT_INFO has been set
--   with the corresponding security_group_id.
--
-- Post Failure:
--   An applicantion error is raised if the business_group_id is
--   invalid or CLIENT_INFO cannot be set.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure validate_bus_grp_id
          (p_business_group_id in per_business_groups.business_group_id%TYPE
          ,p_associated_column1 in varchar2 default null);
--
Function strip_constraint_name(p_errmsg in varchar2)
         Return varchar2;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< return_concat_kf_segments >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns the display concatenated string for the segments1..30.
--   The function works by selecting all defined segments from the aol fnd
--   tables and determining if they have a value or if they are null. if null
--   then the concatenated segment delimiter is used.
--
-- Pre-conditions:
--   The id_flex_num and segments have been fully validated.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function return_concat_kf_segments
           (p_id_flex_num    in number,
            p_application_id in number,
            p_id_flex_code   in varchar2,
            p_segment1       in varchar2 default null,
            p_segment2       in varchar2 default null,
            p_segment3       in varchar2 default null,
            p_segment4       in varchar2 default null,
            p_segment5       in varchar2 default null,
            p_segment6       in varchar2 default null,
            p_segment7       in varchar2 default null,
            p_segment8       in varchar2 default null,
            p_segment9       in varchar2 default null,
            p_segment10      in varchar2 default null,
            p_segment11      in varchar2 default null,
            p_segment12      in varchar2 default null,
            p_segment13      in varchar2 default null,
            p_segment14      in varchar2 default null,
            p_segment15      in varchar2 default null,
            p_segment16      in varchar2 default null,
            p_segment17      in varchar2 default null,
            p_segment18      in varchar2 default null,
            p_segment19      in varchar2 default null,
            p_segment20      in varchar2 default null,
            p_segment21      in varchar2 default null,
            p_segment22      in varchar2 default null,
            p_segment23      in varchar2 default null,
            p_segment24      in varchar2 default null,
            p_segment25      in varchar2 default null,
            p_segment26      in varchar2 default null,
            p_segment27      in varchar2 default null,
            p_segment28      in varchar2 default null,
            p_segment29      in varchar2 default null,
            p_segment30      in varchar2 default null)
         return varchar2;
--
-- ----------------------------------------------------------------------------
-- |----------------------< not_exists_in_hr_lookups >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   A supporting function for row handler lookup validation. Used to validate
--   that a non-DateTracked entity lookup code exists in hr_lookups. This
--   function must be used where data is within a business group context.
--   Returns TRUE if the lookup code does not exist at all, or it is not
--   enabled or it does not exist as the effective date.
--
-- Prerequisites:
--   client_info must be set with the security_group_id context.
--   lookup_type (p_lookup_type) is valid.
--
-- In Arguments:
--   p_effective_date
--   p_lookup_type
--   p_lookup_code
--
-- Post Success:
--   Returns FALSE when the lookup_code is valid.
--   Returns TRUE when the lookup_code is invalid. i.e. The row handler needs
--   to raise a specific error message.
--
-- Post Failure:
--   An unexpected error has occurred.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function not_exists_in_hr_lookups
  (p_effective_date        in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return boolean;
--
-- ----------------------------------------------------------------------------
-- |----------------------< not_exists_in_leg_lookups >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   A supporting function for row handler lookup validation. Used to validate
--   that a non-DateTracked entity lookup code exists in hr_leg_lookups. This
--   function must be used where data is within a business group context and the
--   lookup_type has core plus or core minus lookup_values defined (i.e. has
--   legislation specific lookup values).
--   Returns TRUE if the lookup code does not exist at all, or it is not
--   enabled or it does not exist as the effective date.
--
-- Prerequisites:
--   client_info must be set with the security_group_id context.
--   legislation code should be set in the hr_session_data application context
--   for the session (by calling hr_api.set_application_context).
--   lookup_type (p_lookup_type) is valid.
--
-- In Arguments:
--   p_effective_date
--   p_lookup_type
--   p_lookup_code
--
-- Post Success:
--   Returns FALSE when the lookup_code is valid.
--   Returns TRUE when the lookup_code is invalid. i.e. The row handler needs
--   to raise a specific error message.
--
-- Post Failure:
--   An unexpected error has occurred.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function not_exists_in_leg_lookups
  (p_effective_date        in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------< not_exists_in_hrstanlookups >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   A supporting function for row handler lookup validation. Used to validate
--   that a non-DateTracked entity lookup code exists in hr_standard_lookups.
--   This function must be used where data is outside of a business group
--   context. Returns TRUE if the lookup code does not exist at all, or it is
--   not enabled or it does not exist as the effective date.
--
-- Prerequisites:
--   lookup_type (p_lookup_type) is valid.
--
-- In Arguments:
--   p_effective_date
--   p_lookup_type
--   p_lookup_code
--
-- Post Success:
--   Returns FALSE when the lookup_code is valid.
--   Returns TRUE when the lookup_code is invalid. i.e. The row handler needs
--   to raise a specific error message.
--
-- Post Failure:
--   An unexpected error has occurred.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function not_exists_in_hrstanlookups
  (p_effective_date        in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------< not_exists_in_fnd_lookups >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   A supporting function for row handler lookup validation. Used to validate
--   that a non-DateTracked entity lookup code exists in fnd_lookups. Returns
--   TRUE if the lookup code does not exist at all, or it is not enabled or it
--   does not exist as the effective date.
--
-- Prerequisites:
--   lookup_type (p_lookup_type) is valid.
--
-- In Arguments:
--   p_effective_date
--   p_lookup_type
--   p_lookup_code
--
-- Post Success:
--   Returns FALSE when the lookup_code is valid.
--   Returns TRUE when the lookup_code is invalid. i.e. The row handler needs
--   to raise a specific error message.
--
-- Post Failure:
--   An unexpected error has occurred.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function not_exists_in_fnd_lookups
  (p_effective_date        in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return boolean;
--
-- ----------------------------------------------------------------------------
-- |--------------------< not_exists_in_dt_hr_lookups >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   A supporting function for row handler lookup validation. Used to validate
--   that a DateTracked entity lookup code exists in hr_lookups. This function
--   must be used where data is within a business group context. Returns
--   TRUE if the lookup code does not exist at all, or it is not enabled or it
--   does not exist as the effective date.
--
-- Prerequisites:
--   client_info must be set with the security_group_id context.
--   lookup_type (p_lookup_type) is valid.
--
-- In Arguments:
--   p_effective_date
--   p_validation_start_date
--   p_validation_end_date
--   p_lookup_type
--   p_lookup_code
--
-- Post Success:
--   Returns FALSE when the lookup_code is valid.
--   Returns TRUE when the lookup_code is invalid. i.e. The row handler needs
--   to raise a specific error message.
--
-- Post Failure:
--   An unexpected error has occurred.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function not_exists_in_dt_hr_lookups
  (p_effective_date        in     date
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return boolean;
--
-- ----------------------------------------------------------------------------
-- |--------------------- not_exists_in_dt_leg_lookups >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   A supporting function for row handler lookup validation. Used to validate
--   that a DateTracked entity lookup code exists in hr_leg_lookups. This
--   function must be used where data is within a business group context and the
--   lookup_type has core plus or core minus lookup_values defined (i.e. has
--   legislation specific lookup values).
--   Returns TRUE if the lookup code does not exist at all, or it is not enabled or it
--   does not exist as the effective date.
--
-- Prerequisites:
--   client_info must be set with the security_group_id context.
--   legislation code should be set in the hr_session_data application context
--   for the session (by calling hr_api.set_application_context).
--   lookup_type (p_lookup_type) is valid.
--
-- In Arguments:
--   p_effective_date
--   p_validation_start_date
--   p_validation_end_date
--   p_lookup_type
--   p_lookup_code
--
-- Post Success:
--   Returns FALSE when the lookup_code is valid.
--   Returns TRUE when the lookup_code is invalid. i.e. The row handler needs
--   to raise a specific error message.
--
-- Post Failure:
--   An unexpected error has occurred.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function not_exists_in_dt_leg_lookups
  (p_effective_date        in     date
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return boolean;
--
-- ----------------------------------------------------------------------------
-- |-------------------< not_exists_in_dt_hrstanlookups >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   A supporting function for row handler lookup validation. Used to validate
--   that a DateTracked entity lookup code exists in hr_standard_lookups.
--   This function must be used where data is outside a business group
--   context. Returns TRUE if the lookup code does not exist at all, or it is
--   not enabled or it does not exist as the effective date.
--
-- Prerequisites:
--   lookup_type (p_lookup_type) is valid.
--
-- In Arguments:
--   p_effective_date
--   p_validation_start_date
--   p_validation_end_date
--   p_lookup_type
--   p_lookup_code
--
-- Post Success:
--   Returns FALSE when the lookup_code is valid.
--   Returns TRUE when the lookup_code is invalid. i.e. The row handler needs
--   to raise a specific error message.
--
-- Post Failure:
--   An unexpected error has occurred.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function not_exists_in_dt_hrstanlookups
  (p_effective_date        in     date
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return boolean;
--
-- ----------------------------------------------------------------------------
-- |--------------------< not_exists_in_dt_fnd_lookups >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   A supporting function for row handler lookup validation. Used to validate
--   that a DateTracked entity lookup code exists in fnd_lookups. Returns
--   TRUE if the lookup code does not exist at all, or it is not enabled or it
--   does not exist as the effective date.
--
-- Prerequisites:
--   lookup_type (p_lookup_type) is valid.
--
-- In Arguments:
--   p_effective_date
--   p_validation_start_date
--   p_validation_end_date
--   p_lookup_type
--   p_lookup_code
--
-- Post Success:
--   Returns FALSE when the lookup_code is valid.
--   Returns TRUE when the lookup_code is invalid. i.e. The row handler needs
--   to raise a specific error message.
--
-- Post Failure:
--   An unexpected error has occurred.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function not_exists_in_dt_fnd_lookups
  (p_effective_date        in     date
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return boolean;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< cannot_find_prog_unit_error >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure should be called when the "hr_api.Cannot_Find_Prog_Unit"
--   exception has been raised by a call to an API user hook package
--   procedure. This procedure will raise a more specific application error
--   message.
--
-- Prerequisites:
--   The "hr_api.Cannot_Find_Prog_Unit" exception has been raised.
--   The p_module_name parameter should be set to the same module_name value
--   as the corresponding row in the HR_API_MODULES table.
--   The p_hook_type parameter should be set to the same api_hook_type value
--   as the corresponding row in the HR_API_HOOKS table.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_module_name                  Yes  varchar2 Name of the API module to be
--                                                included in the error text.
--   p_hook_type                    Yes  varchar2 Internal code for the type
--                                                of API hook.
--
-- Post Success:
--   Raises a PL/SQL exception with an application specific error message.
--
-- Post Failure:
--   Raises a PL/SQL exception with an application specific error message.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure cannot_find_prog_unit_error
  (p_module_name                   in     varchar2
  ,p_hook_type                     in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< return_commit_unit >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Assigns and returns a number which is used to used to represent the
--   current commit unit. This function is used in conjunction with the
--   validate_commit_unit procedure to detect when a commit or full rollback
--   has been issued as part of legislation / vertical market or customer
--   specific API user hook logic.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   None
--
-- Post Success:
--   Assigns and returns a number which represents the current commit unit.
--
-- Post Failure:
--   A PL/SQL exception is raised. The function will abort without returning
--   a number value.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function return_commit_unit return number;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< validate_commit_unit >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used in conjunction with the return_commit_unit
--   function to detect when a commit or full rollback has been issued as
--   part of legislation / vertical market or customer specific API user hook
--   logic.
--
-- Prerequisites:
--   The return_commit_unit function should have been called at least once for
--   the current database session.
--   The p_module_name parameter should be set to the same module_name value
--   as the corresponding row in the HR_API_MODULES table.
--   The p_hook_type parameter should be set to the same api_hook_type value
--   as the corresponding row in the HR_API_HOOKS table.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_commit_unit_number           Yes  number   The value which was returned
--                                                by the last call to the
--                                                return_commit_unit function.
--                                                i.e. What the hook package
--                                                thinks is the current commit
--                                                unit number.
--   p_module_name                  Yes  varchar2 Name of the API module to be
--                                                included in the error text.
--   p_hook_type                    Yes  varchar2 Internal code for the type
--                                                of API hook.
--
-- Post Success:
--   When the current commit unit number matches p_commit_unit_number this
--   procedure ends normally.
--
-- Post Failure:
--   When the current commit unit number does not match p_commit_unit_number
--   a commit or full rollback must have been issued since the
--   return_commit_unit function was called. An PL/SQL exception is raised
--   with an application error message.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure validate_commit_unit
  (p_commit_unit_number            in     number
  ,p_module_name                   in     varchar2
  ,p_hook_type                     in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< customer_hooks >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Allows Oracle applications support and the HR Development group to switch
--   off all customer specific API user hook logic for the current database
--   session. Customers must not call this procedure without authorisation
--   from Oracle.
--
-- Prerequisites:
--   The p_mode parameter must be set to 'DISABLE' or 'ENABLE'.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_mode                         Yes  varchar2 Indicates if customer
--                                                specific API user hook logic
--                                                should be called.
--
-- Post Success:
--   Customer specific API user hook logic is either disabled or enabled.
--
-- Post Failure:
--   A PL/SQL exception with an application error message is raised if p_mode
--   is not set to a valid value.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure customer_hooks
  (p_mode                          in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< legislation_hooks >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Allows Oracle applications support and the HR Development group to switch
--   off all legislation and vertical market specific API user hook logic.
--   Only the current database session is affected. Customers must not call
--   this procedure without authorisation from Oracle.
--
-- Prerequisites:
--   The p_mode parameter must be set to 'DISABLE' or 'ENABLE'.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_mode                         Yes  varchar2 Indicates if legislation and
--                                                vertical market specific API
--                                                user hook logic should be
--                                                called.
--
-- Post Success:
--   Legislation and vertical market specific API user hook logic is either
--   disabled or enabled.
--
-- Post Failure:
--   A PL/SQL exception with an application error message is raised if p_mode
--   is not set to a valid value.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure legislation_hooks
  (p_mode                          in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< application_hooks >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Allows Oracle applications support and the HR Development group to switch
--   off all Application specific API user hook logic.
--   Only the current database session is affected. Customers must not call
--   this procedure without authorisation from Oracle.
--
-- Prerequisites:
--   The p_mode parameter must be set to 'DISABLE' or 'ENABLE'.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_mode                         Yes  varchar2 Indicates if application
--                                                specific API user hook logic
--                                                should be called.
--
-- Post Success:
--   Application specific user hook logic is either disabled or enabled.
--
-- Post Failure:
--   A PL/SQL exception with an application error message is raised if p_mode
--   is not set to a valid value.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure application_hooks
  (p_mode                          in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< call_cus_hooks >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Indicates if customer specific API user hook logic will be executed.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   None
--
-- Post Success:
--   Returns TRUE when custom specific API user hook logic will be executed.
--   Otherwise FALSE is returned.
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function call_cus_hooks return boolean;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< call_leg_hooks >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Indicates if legislation and vertical market specific API user hook logic
--   will be executed.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   None
--
-- Post Success:
--   Returns TRUE when legislation and vertical market specific API user hook
--   logic will be executed. Otherwise FALSE is returned.
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function call_leg_hooks return boolean;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< call_app_hooks >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Indicates if Application specific API user hook logic will be executed.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   None
--
-- Post Success:
--   Returns TRUE when Application specific API user hook
--   logic will be executed. Otherwise FALSE is returned.
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function call_app_hooks return boolean;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< return_legislation_code >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns the legislation_code for a specific business group. If the
--   business_group_id is the same as the last call to this function the
--   legislation_code is returned without selecting a value from the database.
--
-- Prerequisites:
--   p_business_group_id should represent a business group which is known to
--   exist in the system.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_business_group_id            Yes  Number   Identifies a specific
--                                                business group.
--
-- Post Success:
--   When p_business_group_id is not null returns the legislation_code which
--   corresponds to the business_group_id.
--   When p_business_group_id is null returns null.
--
-- Post Failure:
--   An application error message is raised if the business_group_id does not
--   exist.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function return_legislation_code
  (p_business_group_id             in     number
  ) return varchar2;
--
--pragma restrict_references(return_legislation_code, WNDS);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< userenv_lang >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns the value obtained by select userenv('LANG') from dual;
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   None.
--
-- Post Success:
--   The value from userenv('LANG') is returned.
--
-- Post Failure:
--   An application error is raised when the select statement fails.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
function userenv_lang return varchar2;
--
-- ----------------------------------------------------------------------------
-- |------------------------< validate_language_code >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the specified language_code is the application base language or
--   an installed language. A null or hr_api.g_varchar2 value will be
--   ignored and userenv('LANG') will be used instead.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_language_code                No   Varchar2 Current language for
--                                                translated data.
--
-- Post Success:
--   The language is the application base language or an installed
--   language. If p_language_code parameter IN value was null or
--   hr_api.g_varchar2 the OUT value will be set to userenv('LANG').
--
-- Post Failure:
--   An application error is raised when the language is not valid.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure validate_language_code
(p_language_code                 in out nocopy varchar2
);
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< set_legislation_context >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Accepts legislation code and writes it into the LEG_CODE namespace of the
--   SESSION_DATA application context. This is used to enable legislation sensitive
--   switching of the lookup vales within the HR_LOOKUPS view for the current forms
--   and/or API session. No validation of the legislation_code supplied is
--   performed here.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_legislation_code             Yes  Varchar2 Current session's
--                                                legislation code.
--
-- Post Success:
--   The current session's legislation code is stored in the application
--   context 'SESSION_DATA', within the namespace 'LEG_CODE'.
--
-- Post Failure:
--   An application error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure set_legislation_context
(p_legislation_code        in varchar2
);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_legislation_context >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns the legislation code for the current API/forms session as stored
--   in SESSION_DATA application context within the LEG_CODE namespace.
--   (This context is used by HR_LOOKUPS view to provide legsilation sensitive
--   switching of lookup values.)
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_legislation_code             Yes  Varchar2 Current session's
--                                                legislation code.
--
-- Post Success:
--   The current session's legislation code is returned. (This may be null).
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function get_legislation_context return varchar2;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< boolean_to_constant >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Used in the Self Service API wrappers to convert constant values to the
--  appropriate boolean ones.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_constant_value               yes  boolean  Boolean value to be converted
--
-- Post Success:
--   Function returns boolean value represented as a number.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
FUNCTION boolean_to_constant(p_boolean_value IN boolean) RETURN number;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< constant_to_boolean >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Used in the Self Service API wrappers to convert constant values to the
--  appropriate boolean ones.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_constant_value               yes  number   Number value to be converted
--
-- Post Success:
--   Function returns number value represented as a boolean.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
FUNCTION constant_to_boolean(p_constant_value IN number) RETURN boolean;
--
End Hr_Api;

/

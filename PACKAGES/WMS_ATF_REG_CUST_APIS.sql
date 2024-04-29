--------------------------------------------------------
--  DDL for Package WMS_ATF_REG_CUST_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_ATF_REG_CUST_APIS" AUTHID CURRENT_USER as
 /* $Header: WMSARCAS.pls 115.2 2004/05/04 00:27:24 joabraha noship $ */
-- Package Variables
--
g_package  varchar2(33) := '  wms_atf_reg_cust_apis.';
--
--
-- ----------------------------------------------------------------------------
-- |--------------<Table type definition for Signature information>------------|
-- ----------------------------------------------------------------------------
--
type hook_parameter_rec_type is record(
   parameter_name     varchar2(240)
,  parameter_type     varchar2(240)
,  parameter_in_out   varchar2(10)
,  parameter_flag     varchar2(1)
);

type hook_parameter_table_type is table of hook_parameter_rec_type index by binary_integer;
--
-- ---------------------------------------------------------------------------
-- |--------------------------< trace utility >-------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Wrapper around the tracing utility.
--
-- Prerequisites:
-- None
--
-- In Parameters:
--   Name       Reqd  Type     Description
--   ---------  ----- -------- --------------------------------------------
--   p_message  Yes   varchar2 Message to be displayed in the log file.
--   p_level    No    number   Level default to the lowest if not specified.
--
-- Post Success:
--   None.
--
-- Post Failure:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure trace(
   p_message  in varchar2
,  p_level    in number default 4
);
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< validate_call_signature >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates if the call package-procedure signature matches the parent hook's
--   signature.
--
-- Prerequisites:
--
--
--
-- In Parameters:
--   Name                    Reqd Type      Description
--   ---------------------   ---- --------  ---------------------------
--   p_module_hook_id        Yes  number    ID of the module/hook call.
--   p_call_package_name     Yes  varchar2  Name of the package to call.
--   p_call_procedure_name   Yes  varchar2  Name of the procedure within
--                                          p_call_package_name to call.
--   x_signature_valid       No   boolean   True when signature matches
--                                          false for all other cases.
--                                          if invalid code should be
--   x_return_status         Yes  number    Return Status
--   x_msg_count             Yes  number    Message Stack Count.
--   x_msg_data              Yes  number    Message Stack Data.
--
-- Post Success:
--   Validates and returns true .Creates source code for one package procedure call.
--
-- Post Failure:
--   Returns false.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure validate_call_signature(
   p_module_hook_id        in number
,  p_call_package_name     in varchar2
,  p_call_procedure_name   in varchar2
,  x_signature_valid       out nocopy boolean
,  x_retcode               out nocopy number
,  x_errbuf                out nocopy varchar2
);
--
--
-- ---------------------------------------------------------------------------------
-- |-------------------------<create_wms_system_objects >---------------------------|
-- ---------------------------------------------------------------------------------
-- API name    : Create WMS Objects.
-- Type        : Private
-- Function    : Returns Sub/Loc, LPN or Validation Status.
-- Input Parameters  :
--             None. This API reads the Custom API Architecture tables to generate
--             the system files.
-- Output Parameters:
--             This API is responsible for populating/deleting records in the
--             wms_api_hook_calls table based on the mode in which its called.
-- Version     :
-- Current version 1.0
--
-- Notes       :
-- Date           Modification       Author
-- ------------   ------------       ------------------
--
--
Procedure create_wms_system_objects(
   x_retcode           out nocopy number
,  x_errbuf            out nocopy varchar2
);
--
--
-- ----------------------------------------------------------------------------------
-- |----------------------------< create_delete_api_call >--------------------------|
-- ----------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Populate the global PL/SQL structure(hook_parameter_table_type) with the
--   parameters of the signature for the Parent Module/Business Process/ PL/SQL
--   Package-Procedure combination
--
-- Prerequisites:
--   p_module_hook_id is set with the proper value.
--
--
-- In Parameters:
--   Name                   Reqd Type      Description
--   --------------------   ---- --------  -------------------------------------
--   p_hook_short_name_id   Yes  varchar2  Short name for parent Module/Business
--                     	                   Process/ PL/SQL Package-Procedure
--                                         combination.
--   p_call_package         Yes  varchar2  Call package to be registered                                                                              --   p_call_procedure       Yes  varchar2  Call procedure to be registered
--   p_effective_to_date    Yes  varchar2  Effective To Date.
--   p_mode 		    Yes  varchar2  Valid Modes are Insert, Update and
--                                         Disable.
-- Post Success:
--   Returns true. Returns a PL/SQL of type hook_parameter_table_type.
--
-- Post Failure:
--   Details of the error are added to the AOL message stack. When this
--   function returns false the error has not been raised. It is up to the
--   calling logic to raise or process the error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
-- Inserting should check for the following :
-- 1. Check to make sure that the combination does not already exist.
-- 2. If the combination does not exist, then make sure that the application_id
--    matches the one on the parent record.
-- 3. Make sure that the effective date is not less that the system date when
--    the registrtaion program is run.
-- 4. Make sure that
--
Procedure create_delete_api_call(
   p_hook_short_name_id   in  number
,  p_call_package         in  varchar2
,  p_call_procedure       in  varchar2
,  p_call_description     in  varchar2
,  p_effective_to_date    in  date
,  p_mode                 in  varchar2
,  x_retcode              out nocopy number
,  x_errbuf               out nocopy varchar2
);
--
--
end wms_atf_reg_cust_apis;

 

/

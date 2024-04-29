--------------------------------------------------------
--  DDL for Package HR_PUMP_META_MAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PUMP_META_MAPPER" AUTHID CURRENT_USER as
/* $Header: hrpumpmm.pkh 120.2.12010000.1 2008/07/28 03:43:22 appldev ship $ */
--
-- ------------------- get_parameter_info ---------------------------------
-- Description:
-- Get information about a parameter to an API for use in the Pump Station
-- user interface. Caches the information about the whole API so that
-- subsequent calls to the same API are efficient. Returns 1 in the
-- p_success parameter if the fetch was succesful, i.e. if the p_index
-- passed was not out of the range of parameters available for this API.
-- ------------------------------------------------------------------------
procedure get_parameter_info
(
  p_api_id               in  number,
  p_index                in  number,
  p_batch_lines_seqno    out nocopy number,
  p_batch_lines_column   out nocopy varchar2,
  p_parameter_name       out nocopy varchar2,
  p_success              out nocopy number
);
-- -------------------------- purge ---------------------------------------
-- Description:
-- Purges all data created by a generate call for the API.
-- ------------------------------------------------------------------------
procedure purge
(
  p_module_package in varchar2,
  p_module_name    in varchar2
);
-- ---------------------------- purgeall ----------------------------------
-- Description:
-- Calls purge on all supported APIs.
-- ------------------------------------------------------------------------
procedure purgeall;
-- -------------------------- generate ------------------------------------
-- Description:
-- Generates a package containing the following:
-- - A wrapper procedure to call the API.
-- - A procedure to insert data for this API in HR_PUMP_BATCH_LINES.
-- Generates a view on HR_PUMP_BATCH_LINES to allow a user an alternative
-- mechanism to insert or update data.
-- Passing p_standard_generate = false, generates data pump wrappers to
-- a basic API call (no user keys, mapping functions, lookup meanings).
-- The generated code assumes that create_ APIs have NULL defaults and
-- other APIs have HR_API defaults. This is useful for the case where
-- data pump API support has not been seeded.
-- ------------------------------------------------------------------------
procedure generate
(
  p_module_package in varchar2,
  p_module_name    in varchar2
 ,p_standard_generate in boolean default true
);
-- ------------------------- generateall ----------------------------------
-- Description:
-- Calls generate on all supported APIs.
-- ------------------------------------------------------------------------
procedure generateall;
-- ---------------------------- help --------------------------------------
-- Description:
-- Displays the following help text for the API specified by p_module_name
-- and p_module_package:
-- - The generated package and view name.
-- - Batch lines parameter information.
-- - p_standard_generate = false, generates help text for wrappers generated
--   with p_standard_generate = false.
-- ------------------------------------------------------------------------
procedure help
(
  p_module_package in varchar2,
  p_module_name    in varchar2
 ,p_standard_generate in boolean default true
);
--
end hr_pump_meta_mapper;

/

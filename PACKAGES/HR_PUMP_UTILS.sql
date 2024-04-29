--------------------------------------------------------
--  DDL for Package HR_PUMP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PUMP_UTILS" AUTHID CURRENT_USER as
/* $Header: hrdputil.pkh 120.1 2006/01/11 08:24:19 arashid noship $ */
/*
  Notes:
    These declarations are for various user utility functions related
    to the Data Pump engine.
*/

----------------------------- create_batch_header -----------------------------
/*
  NAME
    create_batch_header
  DESCRIPTION
    Create a row in batch headers table.
  NOTES
    This is the public interface to be used to create
    a batch header row.  The user should not insert
    directly into the table.
  PARAMETERS
    p_batch_name          : this batch name must be unique.
    p_business_group_name : the business group can be null.
    p_reference           : (non unique) user reference.
    p_atomic_linked_calls : 'Y' means that, for a set of linked API calls
                            within this batch Data Pump only COMMITs the
                            results if all API calls in the set were
                            successful.  If an API call within a linked set
                            fails then Data Pump will ROLLBACK the whole set
                            of linked API calls.
                            For values other than 'Y', Data Pump will COMMIT
                            all successful API calls.
  RETURNS
    The batch_id for this batch header.  This is needed for making
    insert_batch_lines procedure calls.
*/

function create_batch_header
(
   p_batch_name          in varchar2,
   p_business_group_name in varchar2  default null,
   p_reference           in varchar2  default null,
   p_atomic_linked_calls in varchar2  default 'N'
) return number;

-------------------------------- add_user_key ---------------------------------
/*
  NAME
    add_user_key
  DESCRIPTION
    Create a user key value in the user keys table.
  NOTES
    This is the public interface to be used to create a
    user key for use with the data pump API calls. The user
    should not insert directly into the table.
  PARAMETERS
    p_user_key_value : unique character string identifying the user key.
                       p_user_key must be non-null.
    p_unique_key_id  : id associated with the user key. p_unique_key must be
                       non-null.

*/
procedure add_user_key
(
   p_user_key_value in varchar2,
   p_unique_key_id  in number
);

------------------------------ modify_user_key --------------------------------
/*
  NAME
     modify_user_key
  DESCRIPTION
    Modify a user key value in the user keys table.
  NOTES
    This is the public interface to be used to modify a
    user key for use with the data pump API calls. The user
    should not insert directly into the table.
  PARAMETERS
    p_user_key_value     : unique character string identifying the user key to
                           be changed. p_user_key must be non-null.
    p_new_user_key_value : modified user key value (no change if null).
    p_unique_key_id      : modified id associated with the user key (no change
                           if null).
*/
procedure modify_user_key
(
   p_user_key_value     in varchar2,
   p_new_user_key_value in varchar2,
   p_unique_key_id      in number
);

---------------------------------- name --------------------------------------
/*
  NAME
     name
  DESCRIPTION
     Returns the names for the view and package that would be created by a
     generate call for an API.
  PARAMETERS
    p_module_package     : name of the PL/SQL package for the API.
    p_module_name        : name of the API procedure within p_module_package.
    p_package_name       : name of the generated package.
    p_view_name          : name of the generated view.
*/
procedure name
( p_module_package in  varchar2,
  p_module_name    in  varchar2,
  p_package_name   out nocopy varchar2,
  p_view_name      out nocopy varchar2
);
pragma restrict_references( name, WNDS );

-------------------------------- SEED_ZAP -------------------------------------
/*
  NAME
    SEED_ZAP
  DESCRIPTION
    Deletes seed data rows for the API specified by P_MODULE_NAME and
    API_MODULE_TYPE. Does not delete rows from HR_API_MODULES.
*/
PROCEDURE SEED_ZAP
(P_MODULE_NAME     IN     VARCHAR2
,P_API_MODULE_TYPE IN     VARCHAR2
);

-------------------------------- SEED_API -------------------------------------
/*
  NAME
    SEED_API
  DESCRIPTION
    Creates a row for the API specified by P_MODULE_NAME and API_MODULE_TYPE
    in HR_API_MODULES.
*/
PROCEDURE SEED_API
(P_MODULE_NAME                IN     VARCHAR2
,P_API_MODULE_TYPE            IN     VARCHAR2
,P_MODULE_PACKAGE             IN     VARCHAR2
,P_DATA_WITHIN_BUSINESS_GROUP IN     VARCHAR2 DEFAULT 'Y'
,P_LEGISLATION_CODE           IN     VARCHAR2 DEFAULT NULL
);

--------------------------- SEED_DFLT_EXC -------------------------------------
/*
  NAME
    SEED_DFLT_EXC
  DESCRIPTION
    Creates a row for the API specified by P_MODULE_NAME and API_MODULE_TYPE
    in HR_PUMP_DEFAULT_EXCEPTIONS.
*/
PROCEDURE SEED_DFLT_EXC
(P_MODULE_NAME     IN     VARCHAR2
,P_API_MODULE_TYPE IN     VARCHAR2
);

------------------------------- SEED_PARM -------------------------------------
/*
  NAME
    SEED_PARM
  DESCRIPTION
    Creates a row for parameter P_PARAMETER_NAME of the API specified by
    P_MODULE_NAME and API_MODULE_TYPE in HR_PUMP_MODULE_PARAMETERS.
*/
PROCEDURE SEED_PARM
(P_MODULE_NAME        IN     VARCHAR2
,P_API_MODULE_TYPE    IN     VARCHAR2
,P_PARAMETER_NAME     IN     VARCHAR2
,P_MAPPING_TYPE       IN     VARCHAR2 DEFAULT 'FUNCTION'
,P_MAPPING_DEFINITION IN     VARCHAR2 DEFAULT NULL
,P_DEFAULT_VALUE      IN     VARCHAR2 DEFAULT NULL
);

------------------------------- SEED_MAP_PKGS ---------------------------------
/*
  NAME
    SEED_MAP_PKGS
  DESCRIPTION
    Creates a row for the mapping function package specified by
    P_MAPPING_PACKAGE in HR_PUMP_MAPPING_PACKAGES.
*/
PROCEDURE SEED_MAP_PKGS
(P_MAPPING_PACKAGE    IN     VARCHAR2
,P_MODULE_NAME        IN     VARCHAR2 DEFAULT NULL
,P_API_MODULE_TYPE    IN     VARCHAR2 DEFAULT NULL
,P_MODULE_PACKAGE     IN     VARCHAR2 DEFAULT NULL
,P_CHECKING_ORDER     IN     NUMBER
);

------------------------- set_current_session_running ------------------------
/*
  NAME
    set_current_session_running

  DESCRIPTION
    Set an indicator to specify whether or not this session is running Data
    Pump.

  NOTES
    Part of the Date-Track locking solution. This procedure may only be
    called by Data Pump.
*/
procedure set_current_session_running(p_running in boolean);

----------------------- set_dt_enforce_foreign_locks ------------------------
/*
  NAME
    set_dt_enforce_foreign_locks

  DESCRIPTION
    Set an indicator to specify that this session is running Data Pump.

  NOTES
    Part of the Date-Track locking solution. This procedure may only be
    called by Data Pump.
*/
procedure set_dt_enforce_foreign_locks(p_enforce in boolean);

------------------------------- any_session_running --------------------------
/*
  NAME
    any_session_running

  DESCRIPTION
    Returns a boolean value that indicates whether or not a Data Pump session
    is running without foreign key locking.

  NOTES
    Part of the Date-Track locking solution.
*/
function any_session_running return boolean;

--------------------------- current_session_running --------------------------
/*
  NAME
    current_session_running

  DESCRIPTION
    Returns a boolean value that indicates whether or not a this database
    session is currently running Data Pump.

  NOTES
    Part of the Date-Track locking solution.
*/
function current_session_running return boolean;

------------------------- dt_enforce_foreign_locks ---------------------------
/*
  NAME
    dt_enforce_foreign_locks

  DESCRIPTION
    Provides a boolean version of the PAY_ACTION_PARAMETERS table
    PUMP_DT_ENFORCE_FOREIGN_LOCKS parameter value.

  NOTES
    Part of the Date-Track locking solution.
*/
function dt_enforce_foreign_locks return boolean;

------------------------- set_multi_msg_error_flag ---------------------------
/*
  NAME
    set_multi_msg_error_flag

  DESCRIPTION
    Sets the value of the multi-message indicator flag.

  NOTES
    Not intended for use outside of data pump.
*/
procedure set_multi_msg_error_flag(p_value in boolean);

--------------------------- multi_msg_errors_exist ----------------------------
/*
  NAME
    multi_msg_errors_exist

  DESCRIPTION
    Gets the value of the multi-message indicator flag.

  NOTES
    Not intended for use outside of data pump.
*/
function multi_msg_errors_exist return boolean;

------------------------- populate_spread_loaders_tab ------------------------
/*
  NAME
    populate_spread_loaders_tab

  DESCRIPTION
    Populate hr_pump_spread_loader table with spreadsheet interface enabled
    data pump entities.

  NOTES
    This procedure will be called from Data Pump script for User Tables.
*/
procedure populate_spread_loaders_tab
(
 p_module_name               in varchar2
,p_integrator_code           in varchar2
,p_entity_name               in varchar2 default null
,p_module_mode               in varchar2
,p_entity_sql_column_name    in varchar2 default null
,p_entity_sql_column_id      in varchar2 default null
,p_entity_sql_addl_column    in varchar2 default null
,p_entity_sql_object_name    in varchar2 default null
,p_entity_sql_where_clause   in varchar2 default null
,p_entity_sql_parameters     in varchar2 default null
,p_entity_sql_order_by       in varchar2 default null
,p_integrator_parameters     in varchar2
);



end hr_pump_utils;

 

/

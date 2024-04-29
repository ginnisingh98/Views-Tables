--------------------------------------------------------
--  DDL for Package FFDICT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FFDICT" AUTHID CURRENT_USER as
/* $Header: ffdict.pkh 120.3 2006/04/30 07:47:14 arashid noship $ */
--
------------------------------ get_context_level ------------------------------
--
--  NAME
--    get_context_level
--  DESCRIPTION
--    Contexts are allocated a power of 2 number so that database item context
--    dependencies can be calculated efficiently in FastFormula using bit masks
--    This function returns the next available context level.
--
-------------------------------------------------------------------------------
--
function get_context_level return number;
--
----------------------------- is_used_in_formula ------------------------------
--
--  NAME
--    is_used_in_formula
--
--  DESCRIPTION
--    Returns TRUE if named item is used within a formula (ie is referenced in
--    the FDIU table) visible from the current business group and legislation.
--    Otherwise returns FALSE.
--
--  NOTES
--    The purpose of this interface is to prevent compilation / run-time issues
--    because of different items with clashing names.
--
--    Example 1:
--    A compiled formula with local variable "L1" has a compilation failure
--    because a database item "L1" was created in the mean time. This is
--    because local variables must be assigned values but database items
--    cannot be assigned values, and a formula item is treated as a database
--    item when its name is found in FF_DATABASE_ITEMS or FF_DATABASE_ITEMS_TL.
--
--    Example 2:
--    A database item that was referenced from a compiled formula is deleted.
--    The next formula compilation fails because the name is treated as a
--    local variable name, and that variable is unitialised.
--
--    Example 3:
--    A new formula context is given the same name as an input variable. This
--    leads to problems in existing code that executes a formula, searching
--    for contexts and inputs by name.
--
-------------------------------------------------------------------------------
--
function is_used_in_formula (p_item_name in varchar2,
                             p_bus_grp in number,
                             p_leg_code in varchar2) return boolean;
--
---------------------------- dbitl_used_in_formula ----------------------------
--
--  NAME
--    dbitl_used_in_formula
--
--  DESCRIPTION
--    Returns TRUE if a translated database item name is used in a formula
--    (ie is referenced in the FDIU table) visible from the current business
--    group and legislation.
--
--  NOTES
--    The purpose of this interface is to avoid a formula becoming invalid
--    upon the update or deletion of a translated database item name.
-------------------------------------------------------------------------------
--
function dbitl_used_in_formula (p_tl_user_name   in varchar2
                               ,p_user_name      in varchar2
                               ,p_user_entity_id in number
                               ,p_language       in varchar2
                               ) return boolean;
--
----------------------------- dbi_used_in_formula -----------------------------
--
--  NAME
--    dbi_used_in_formula
--
--  DESCRIPTION
--    Returns TRUE if a base database item name is used in a formula
--    (ie is referenced in the FDIU table) visible from the current business
--    group and legislation.
--
--  NOTES
--    The purpose of this interface is to avoid a formula becoming invalid
--    upon the update or deletion of a database item.
--
-------------------------------------------------------------------------------
--
function dbi_used_in_formula (p_user_name in varchar2
                             ,p_user_entity_id in number
                             ) return boolean;
--
------------------------------ validate_formula -------------------------------
--
--  NAME
--    validate_formula
--  DESCRIPTION
--    Procedure which succeeds if name supplied will make a valid formula
--    name. Fails with exception and error if name is invalid.
--
-------------------------------------------------------------------------------
--
procedure validate_formula(p_formula_name in out nocopy varchar2,
                           p_formula_type_id in number,
                           p_bus_grp in number,
                           p_leg_code in varchar2);
--
------------------------------ validate_formula -------------------------------
--
--  NAME
--    validate_formula - Overload
--  DESCRIPTION
--    Procedure which succeeds if name supplied will make a valid formula
--    name. Fails with exception and error if name is invalid.
--    Overloaded to allow date effective formula creation.
--
-------------------------------------------------------------------------------
--
procedure validate_formula(p_formula_name         in out nocopy varchar2,
                           p_formula_type_id      in     number,
                           p_bus_grp              in     number,
                           p_leg_code             in     varchar2,
                           p_effective_start_date in     date,
                           p_effective_end_date   in out nocopy date);
--
------------------------------ validate_dbitem -------------------------------
--
--  NAME
--    validate_dbitem
--  DESCRIPTION
--    Procedure which succeeds if name supplied will make a valid database
--    item name. Fails with exception and error if name is invalid.
--  NOTES
--    This procedure is required for inserting a new database item.
--
------------------------------------------------------------------------------
--
procedure validate_dbitem(p_dbi_name in out nocopy varchar2,
                          p_user_entity_id in number);
--
-------------------------- core_validate_tl_dbitem ---------------------------
--
--  NAME
--    core_validate_tl_dbitem
--  DESCRIPTION
--    Core procedure for testing whether or not a new translated database
--    item name is valid.
--
--    Parameters:
--    USER_NAME:         Base DBI name.
--    USER_ENTITY_ID:    USER_ENTITY_ID for this DBI.
--    TL_USER_NAME:      The translated name - it is converted to valid
--                       DBI format.
--
--    Returns a status code in p_outcome:
--    S - Success
--    C - Failure: name clashes with Formula Context name.
--    D - Failure: name clashes with a DBI name.
--    F - Failure: name used in a compiled Formula other than for a DBI
--                 or Context.
--
--  NOTES
--    For FF and Core Pay private use only.
--
------------------------------------------------------------------------------
--
procedure core_validate_tl_dbitem
(p_user_name      in varchar2
,p_user_entity_id in number
,p_tl_user_name   in out nocopy varchar2
,p_outcome           out nocopy varchar2
);
--
------------------------------ validate_tl_dbi -------------------------------
--
--  NAME
--    validate_tl_dbi
--
--  DESCRIPTION
--    Procedure which succeeds if name supplied will make a valid translated
--    database item name. Fails with exception and error if name is invalid.
--
--  NOTES
--    This procedure is required for updating a translated database item
--    name. It is possible that p_tl_user_name will be modified - if the
--    name is not in database item name format, it will be modified.
--
------------------------------------------------------------------------------
--
procedure validate_tl_dbi(p_user_name      in varchar2
                         ,p_user_entity_id in number
                         ,p_tl_user_name   in out nocopy varchar2
                         );
--
------------------------------ validate_context -------------------------------
--
--  NAME
--    validate_context
--  DESCRIPTION
--    Procedure which succeeds if name supplied will make a valid context
--    name. Fails with exception and error if name is invalid.
--
-------------------------------------------------------------------------------
--
procedure validate_context(p_ctx_name in out nocopy varchar2);
--
---------------------------- validate_user_entity -----------------------------
--
--  NAME
--    validate_user_entity
--  DESCRIPTION
--    Procedure which succeeds if name supplied will make a valid user
--    entity name. Fails with exception and error if name is invalid.
--
-------------------------------------------------------------------------------
--
procedure validate_user_entity(p_ue_name in out nocopy varchar2,
                               p_bus_grp in number,
                               p_leg_code in varchar2);
--
----------------------------- validate_function ------------------------------
--
--  NAME
--    validate_function
--  DESCRIPTION
--    Procedure which succeeds if name supplied will make a valid function
--    name. Fails with exception and error if name is invalid.
--
------------------------------------------------------------------------------
--
procedure validate_function(p_func_name in out nocopy varchar2,
                            p_class in varchar2,
                            p_alias in varchar2,
                            p_bus_grp in number,
                            p_leg_code in varchar2);
--
------------------------------ validate_global -------------------------------
--
--  NAME
--    validate_global
--  DESCRIPTION
--    Procedure which succeeds if name supplied will make a valid global
--    variable name. Fails with exception and error if name is invalid.
--
------------------------------------------------------------------------------
--
procedure validate_global(p_glob_name in out nocopy varchar2,
                          p_bus_grp in number,
                          p_leg_code in varchar2);
--
---------------------------- validate_tl_global ------------------------------
--
--  NAME
--    validate_tl_global
--  DESCRIPTION
--    Procedure which succeeds if name supplied will make a valid global
--    variable name. Fails with exception and error if name is invalid.
--
------------------------------------------------------------------------------
--
procedure validate_tl_global(p_global_id in number,
                             p_glob_name in varchar2,
                             p_bus_grp in number,
                             p_leg_code in varchar2);
--
-------------------------------- validate_rcu ---------------------------------
--
--  NAME
--    validate_rcu
--  DESCRIPTION
--    Check adding route context usage does not make any compiled formulae
--    invalid. Returns TRUE if OK, FALSE if not OK
--
-------------------------------------------------------------------------------
--
procedure validate_rcu(p_route_id in number);
--
-------------------------------- validate_rpv ---------------------------------
--
--  NAME
--    validate_rpv
--  DESCRIPTION
--    Check adding route parameter value does not make any compiled formulae
--    invalid.  Returns TRUE if OK, FALSE if not OK
--
-------------------------------------------------------------------------------
--
procedure validate_rpv(p_user_entity_id in number);
--
---------------------------- create_global_dbitem -----------------------------
--
--  NAME
--    create_global_dbitem
--  DESCRIPTION
--    Does third party inserts to create a database item which is used within
--    formulae to access the global variable value
--
-------------------------------------------------------------------------------
--
procedure create_global_dbitem(p_name in varchar2,
                               p_data_type in varchar2,
                               p_global_id in number,
                               p_business_group_id in number,
                               p_legislation_code in varchar2,
                               p_created_by in number,
                               p_creation_date in date);
--
---------------------------- delete_global_dbitem -----------------------------
--
--  NAME
--    delete_global_dbitem
--  DESCRIPTION
--    Does third party deletes to remove a database item which is used within
--    formulae to access the global variable value
--
-------------------------------------------------------------------------------
--
procedure delete_global_dbitem(p_global_id in number);
--
----------------------------- delete_ftcu_check ------------------------------
--
--  NAME
--    delete_ftcu_check
--  DESCRIPTION
--    Check deleting formula type context usage does not make any compiled
--    formulae invalid. Returns TRUE if OK, FALSE if not OK
--
------------------------------------------------------------------------------
--
procedure delete_ftcu_check(p_ftype_id in number,
                            p_context_id in number);
--
---------------------------- delete_dbitem_check -----------------------------
--
--  NAME
--    delete_dbitem_check
--  DESCRIPTION
--    Procedure which succeeds if it is OK to delete named DB item.
--
------------------------------------------------------------------------------
--
procedure delete_dbitem_check(p_item_name in varchar2,
                              p_user_entity_id in number);
--
---------------------------- delete_dbitem_check -----------------------------
--
--  NAME
--    delete_dbitem_check
--  DESCRIPTION
--    Procedure which succeeds if it is OK to delete named DB item.
--    Overloaded because sometimes business group and legislation are known
--
------------------------------------------------------------------------------
--
procedure delete_dbitem_check(p_item_name in varchar2,
                              p_business_group_id in number,
                              p_legislation_code in varchar2);
--
------------------------------- set_ue_details --------------------------------
--
--  NAME
--    set_ue_details
--  DESCRIPTION
--    Stores details of UE pending a delete (for use by delete_dbitem_check)
--
-------------------------------------------------------------------------------
--
procedure set_ue_details (user_entity_id in number,
                          business_group_id in number,
                          legislation_code in varchar2);
--
------------------------------ clear_ue_details -------------------------------
--
--  NAME
--    clear_ue_details
--  DESCRIPTION
--    Clears details of UE following a delete
--
-------------------------------------------------------------------------------
--
procedure clear_ue_details;
--
---------------------------- update_global_dbitem -----------------------------
--
--  NAME
--    update_global_dbitem
--  DESCRIPTION
--    Updates FF_DATABASE_ITEMS_TL to create a translated database item name.
--
-------------------------------------------------------------------------------
--
procedure update_global_dbitem(p_global_id    in number,
                               p_new_name     in varchar2,
                               p_description  in varchar2,
                               p_source_lang  in varchar2,
                               p_language     in varchar2);
--
------------------------- fetch_referencing_formulas --------------------------
--
--  NAME
--    fetch_referencing_formulas
--  DESCRIPTION
--    Fetches information about Formulas that reference a particular
--    translated Database Item name.
--  NOTES
--    For Core Pay and Formula team internal use.
--
-------------------------------------------------------------------------------
--
procedure fetch_referencing_formulas
(p_tl_user_name   in varchar2
,p_user_name      in varchar2
,p_user_entity_id in number
,p_language       in varchar2
,p_formula_ids       out nocopy dbms_sql.number_table
,p_formula_names     out nocopy dbms_sql.varchar2s
,p_eff_start_dates   out nocopy dbms_sql.date_table
,p_eff_end_dates     out nocopy dbms_sql.date_table
,p_bus_group_ids     out nocopy dbms_sql.number_table
,p_leg_codes         out nocopy dbms_sql.varchar2s
);
--
-------------------------------------------------------------------------------
--
end ffdict;

 

/

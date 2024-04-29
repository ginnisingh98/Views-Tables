--------------------------------------------------------
--  DDL for Package HRDYNDBI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRDYNDBI" AUTHID CURRENT_USER as
/* $Header: pydyndbi.pkh 120.6.12010000.2 2009/08/22 07:07:13 pgongada ship $ */
--
--
/* Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved */
/*
PRODUCT
    Oracle*Payroll
--
   NAME
      pydyndbi.pkh
--
   DESCRIPTION
      Package headers for the procedures used to create and delete database
      items in the data dictionary.
--
MODIFIED (DD-MON-YYYY)
    pgongada   21-AUG-2009   Added procedure create_ppm_devdff_flex_dict()
                             to create DB Items for Further Personal Payment
                             Method Info DFF. (US IAT Enhancement : 8717589)
    divicker   01-JUN-2006   Merge 11511 branch
    arashid    11-MAY-2006   Added p_localization parameter to
                             process_pay_dyndbi_changes.
    arashid    27-JAN-2006   Changed  process_pay_dyndbi_changes to a
                             concurrent processing interface with VARCHAR2
                             parameters.
    arashid    01-NOV-2005   Made process_pay_dyndbi_changes multi-threaded.
    arashid    24-OCT-2005   Added new interfaces for translated dynamic
                             database items:
                             * process_pay_dyndbi_changes
                             * update_defined_balance
                             * update_element_type
                             * update_input_value
                             Note: updates to FP.K and earlier should be
                             made on branches to 115.18.
    divicker   15-MAR-2005   Need insert_mthread_pps public so can call
                             from hrrbdeib
    divicker   01-FEB-2004   Add proc reib_all
    divicker   18-NOV-2004   Mthread support
    divicker   09-DEC-2003   Same as 115.10 and 115.12 (no mthread)
    divicker   24-SEP-2003   Same as 115.10 (no mthread routines)
    scchakra   30-APR-2003   Created procedure recreate_defined_balance.
                             Bug - 2450195.
    alogue     18-DEC-2002 - NOCOPY changes. Bug 2692195.
    RThirlby   17-OCT-2002   Added new global g_trigger_dfb_ari boolean. Used
                             in new_defined_balance to determine whether to
                             call code to set save_run_balance flag. Prevents
                             mutating table error.
    divicker   19-JUL-2002   Leg code striping support
    rthirlby   06-MAR-2002   Added dbdrv commands.
    divicker   30-OCT-2000   Added global for saying we have disabled some
                             trigger validation and that this validation is
                             moved inside pydyndbi.pkb
    divicker   04-OCT-2000   Added disable/enable trigger procedures for
                             performance enhancements in rebuild_ele_input_bal
    tbattoo    24-FEB-2000   Bug 1207273, if a user entity alredy exists when
			     you insert the db item use the id for the
			     existing entity and not the currval in the seq
    alogue     09-MAR-1998 - Change insert_user_entity to
                             insert_user_entity_main
                             to overload insert_user_entity by 2 calls -
                             one with p_record_inserted and one without.
    amyers     13-JAN-1998      Amended procedure insert_user_entitiy to:
                                i.  only insert data if it doesn't already exist
                                ii. return a value in a new parameter indicating
                                    whether the insert has happened to determine
                                    the creation of underlying parameter values
                                    and database items.
                                This change comes from bug 602851, where in an
                                R11 upgrade database items and entities were not
                                created, so in driver hr11gn.drv we need to run
                                refresh_grade_spine_rates to ensure this doesn't
                                happen. New version is 110.2.
    alogue     13-AUG-1997 - Business_group_id passed to delete_keyflex_dict
                             to fix bug 513364.
    mwcallag   26-APR-1995 - Entity name passed to delete_keyflex_dict to
                             fix bug 278064.
    mwcallag   28-JUL-1994 - Optional commit parameter added to procedure
                             rebuild_ele_input_bal.
    mwcallag   13-JUN-1994 - G916 Procedure 'rebuild_ele_input_bal' added.
    mwcallag   20-JAN-1994 - Legislation code passed to delete_keyflex_dict,
                             procedure delete_compiled_formula added (G516).
    mwcallag   08-DEC-1993 - G323 Context parameter passed to the procedure
                             delete_flexfield_dict.
    mwcallag   23-NOV-1993 - G161 Simplified the calls to generate DB items for
                             external use.
    mwcallag   28-SEP-1993 - legislation code parameter removed from procedure
                             'insert_database_item'
    mwcallag   01-SEP-1993 - Procedure for converting element DB items from the
                             context of date earned to date paid added.
    mwcallag   23-AUG-1993 - Organization payment methods, external
                             accounts and legal company SCL DB items added.
    mwcallag   03-AUG-1993 - Developer Descriptive flexfield and SCL flexfield
                             procedures added.
    mwcallag   14-JUN-1993 - application id removed from both
                             delete_flexfield_dict and create_flexfield_dict
    mwcallag   03-JUN-1993 - application id passed to delete_flexfield_dict
    mwcallag   07-MAY-1993 - spine DB creation added to grade procedure.
                             DB creation procedure for key flexfield.
    mwcallag   30-APR-1993 - grade rates extended, descriptive flexs and
                             absence types added.
    mwcallag   26-APR-1993 - procedures for input values, element types
                             and grade rate database items added.
    Abraae     06-APR-1993 - created
*/
--
-- first declare general routines that are called from within the database
-- item creation procedures.  These should only be called by these procedures.
--
-- Holder for whether we have come thru rebuild_ele_input_bal()
g_triggers_altered BOOLEAN := FALSE;
g_debug_cnt number;
--
-- Holder for whether we have come through trigger pay_defined_balances_ari
--
g_trigger_dfb_ari boolean := false;
--
PROCEDURE insert_mthread_pps (p_stage     in number,
                              p_worker_id in number,
                              p_leg_code  in varchar2 default 'ZZ');
--
------------------------- insert_parameter_value -------------------------
--
procedure insert_parameter_value
(
    p_value         in varchar2,
    p_sequence_no   in number
);
--
------------------------- insert_database_item -------------------------
--
procedure insert_database_item
(
    p_entity_name          in  varchar2,
    p_item_name            in  varchar2,
    p_data_type            in  varchar2,
    p_definition_text      in  varchar2,
    p_null_allowed_flag    in  varchar2,
    p_description          in  varchar2,
    p_user_entity_id       in  number DEFAULT NULL
);
--
------------------------- insert_user_entity -------------------------
--
procedure insert_user_entity
(
    p_route_name           in  varchar2,
    p_user_entity_name     in  varchar2,
    p_entity_description   in  varchar2,
    p_not_found_flag       in  varchar2,
    p_creator_type         in  varchar2,
    p_creator_id           in  number,
    p_business_group_id    in  number,
    p_legislation_code     in  varchar2,
    p_created_by           in  number,
    p_last_login           in  number,
    p_record_inserted      out nocopy boolean
);
--
procedure insert_user_entity
(
    p_route_name           in  varchar2,
    p_user_entity_name     in  varchar2,
    p_entity_description   in  varchar2,
    p_not_found_flag       in  varchar2,
    p_creator_type         in  varchar2,
    p_creator_id           in  number,
    p_business_group_id    in  number,
    p_legislation_code     in  varchar2,
    p_created_by           in  number,
    p_last_login           in  number
);
--
procedure insert_user_entity_main
(
    p_route_name           in  varchar2,
    p_user_entity_name     in  varchar2,
    p_entity_description   in  varchar2,
    p_not_found_flag       in  varchar2,
    p_creator_type         in  varchar2,
    p_creator_id           in  number,
    p_business_group_id    in  number,
    p_legislation_code     in  varchar2,
    p_created_by           in  number,
    p_last_login           in  number,
    p_record_inserted      out nocopy boolean
);
--
------------------------- delete_compiled_formula -------------------------
--
procedure delete_compiled_formula
(
    p_creator_id            in number,
    p_creator_type          in varchar2,
    p_user_entity_name      in varchar2,
    p_leg_code              in varchar2
);
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                          +
-- The following routines create / delete database items:   +
--                                                          +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
procedure new_defined_balance (p_defined_balance_id in number,
                               p_balance_dimension_id in number,
                               p_balance_type_id in number,
                               p_business_group_id in number,
                               p_legislation_code in varchar2);
--
procedure refresh_defined_balances(p_worker_id in number default 0,
                                   p_maxworkers in number default 1);
procedure refresh_defined_balances(p_leg_code in varchar2,
                                   p_worker_id in number default 0,
                                   p_maxworkers in number default 1);
procedure recreate_defined_balance(p_defined_balance_id   in number,
                                   p_balance_dimension_id in number,
                                   p_balance_type_id      in number,
                                   p_business_group_id    in number,
                                   p_legislation_code     in varchar2);
--
------------------------- delete_element_type_dict -------------------------
--
-- delete database items for a given element type
--
procedure delete_element_type_dict
(
    p_element_type_id       in number
);
--
------------------------- create_element_type -------------------------
--
-- create Database items with a context of either date earned or date paid.
--
procedure create_element_type
(
    p_element_type_id       in number,
    p_effective_date        in date,
    p_date_p                in varchar2
);
--
------------------------- create_element_type_dict -------------------------
--
-- create database items for a given element type, with a context of date
-- earned.  This procedure calls 'create_element_type'.
--
procedure create_element_type_dict
(
    p_element_type_id       in number,
    p_effective_date        in date
);
--
------------------------- create_element_type_dp_dict -------------------------
--
-- create database items for a given element type, with a context of date
-- paid.  This procedure calls 'create_element_type'.
--
procedure create_element_type_dp_dict
(
    p_element_type_id       in number
);
--
------------------------- delete_input_value_dict -------------------------
--
-- delete database items for a given input value
--
procedure delete_input_value_dict
(
    p_input_value_id       in number
);
--
------------------------- create_input_value -------------------------
--
-- create database items for a given input value with a context of either
-- date earned or date paid.
--
procedure create_input_value
(
    p_input_value_id       in number,
    p_effective_date       in date,
    p_date_p               in varchar2
);
--
------------------------- create_input_value_dict -------------------------
--
-- create database items for a given input value
--
procedure create_input_value_dict
(
    p_input_value_id       in number,
    p_effective_date       in date
);
--
------------------------- refresh_element_types -------------------------
--
-- create all the element type and input value database items
--
procedure refresh_element_types(p_worker_id in number default 0,
                                p_maxworkers in number default 1);
--
------------------------- delete_element_types -------------------------
--
-- delete all the element type and input value database items
--
procedure delete_element_types(p_worker_id in number default 0,
                               p_maxworkers in number default 1);
--
------------------------- rebuild_ele_input_bal -------------------------
--
-- delete and re-create element, input value and balance DB items
--
procedure rebuild_ele_input_bal
(
    p_commit in varchar2 default 'N',
    p_worker_id in number default 0,
    p_maxworkers in number default 1
);
procedure rebuild_ele_input_bal
(
    p_commit in varchar2 default 'N',
    p_leg_code in varchar2,
    p_worker_id in number default 0,
    p_maxworkers in number default 1
);
procedure reib_all;
--
------------------------- delete_grade_spine_dict -------------------------
--
-- delete database items for a given grade / spine rate
--
procedure delete_grade_spine_dict
(
    p_rate_id       in number
);
--
------------------------- create_grade_spine_dict -------------------------
--
-- create database items for a given grade/ spine rate
--
procedure create_grade_spine_dict
(
    p_rate_id       in number
);
--
------------------------- refresh_grade_spine_rates ------------------------
--
-- create all the grade rate and spine rate database items
--
procedure refresh_grade_spine_rates;
--
------------------------- delete_grade_spine_rates -------------------------
--
-- delete all the grade and spine rate database items
--
procedure delete_grade_spine_rates;
--
------------------------- create_desc_flex -------------------------
--
-- General routine to create Descriptive flexfields.
--
procedure create_desc_flex
(
    p_title       in varchar2,
    p_table_name  in varchar2,
    p_route_name  in varchar2,
    p_entity_name in varchar2,
    p_context     in varchar2,
    p_global_flag in varchar2,
    p_param_value in varchar2,
    p_leg_code    in varchar2
);
------------------------- create_flexfield_dict -------------------------
--
-- create the flexfield database items for a given title. Note that title
-- may be set to '%' in order to create all flexfield database items
--
procedure create_flexfield_dict
(
    p_title       in varchar2
);
--
------------------------- create_dev_desc_flex_dict -------------------------
--
-- create the developer descriptive flexfield database items for a given title
-- and context.  This will be used by either the Person Developer DF report
-- or the Organization Developer DF report.
--
procedure create_dev_desc_flex_dict
(
    p_title       in varchar2,
    p_context     in varchar2
);
--
------------------------- create_org_pay_flex_dict -------------------------
--
-- Create Organization Payment descriptive flexfield database items for a
-- given payment id.
--
procedure create_org_pay_flex_dict
(
    p_payment_id  in number
);
------------------------- create_ppm_devdff_flex_dict -------------------------
--
-- Create Further Personal Payment Method Info descriptive flexfield database
-- items for a given payment type.
--
procedure create_ppm_devdff_flex_dict
(
    p_payment_id in number
);
--
------------------------- delete_flexfield_dict -------------------------
--
-- delete the specified descriptive flexfield database items depending on their
-- title, context and legislation code
--
procedure delete_flexfield_dict
(
    p_title       in varchar2,
    p_context     in varchar2,
    p_leg_code    in varchar2
);
--
------------------------- create_absence_dict -------------------------
--
-- create database items for a given absence type
--
procedure create_absence_dict
(
    p_absence_type_id   in number
);
--
------------------------- delete_absence_dict -------------------------
--
-- delete database items for a given absence type
--
procedure delete_absence_dict
(
    p_absence_type_id  in number
);
--
------------------------- refresh_absence_types -------------------------
--
-- create all the absence type database items
--
procedure refresh_absence_types;
--
------------------------- delete_absence_types -------------------------
--
-- delete all the absence type database items
--
procedure delete_absence_types;
--
------------------------- create_key_flex -------------------------
--
-- General routine to create Key flexfield Database items
--
procedure create_key_flex
(
    p_applic_id       in number,
    p_business_group  in number,
    p_id_flex_num     in number,
    p_id_flex_code    in varchar2,
    p_entity_name     in varchar2,
    p_leg_code        in varchar2,
    p_route_name      in varchar2,
    p_table_name      in varchar2
);
--
------------------------- create_keyflex_dict -------------------------
--
-- create the key flexfield database items for a given business group id.
-- Note that the name may be set to '%' in order to create all key flexfield
-- database items (see body documentation for more details).
--
procedure create_keyflex_dict
(
    p_business_group_id  in number,
    p_keyflex_name       in varchar2
);
--
------------------------- delete_keyflex_dict -------------------------
--
-- delete the key flexfield database items for a given business group id.
-- Note that the name may be set to '%' in order to delete all key flexfield
-- database items (see body documentation for more details).
--
procedure delete_keyflex_dict
(
    p_creator_id    in number,
    p_entity_name   in varchar2,
    p_leg_code      in varchar2,
    p_business_group_id in number
);
--
---------------------- create_ext_acc_keyflex_dict -----------------------
--
-- Create Personal and Organization External Account Keyflexs
--
procedure create_ext_acc_keyflex_dict
(
    p_id_flex_num  in number
);
--
------------------------- create_scl_flex_dict -------------------------
--
-- create the SCL key flexfield database items for a given id flex number.
--
procedure create_scl_flex_dict
(
    p_id_flex_num in number
);
--
------------------------- disable_ffue_cascade_trig -------------------------
--
-- disables the triggers fired off when delete from ff_user_entities which
-- gives a performance enhancement. As we have cleared ff_fdi_usages_f
-- previously, the validation here is unnecessary
--
procedure disable_ffue_cascade_trig;
--
------------------------- enable_ffue_cascade_trig -------------------------
--
-- re-enables the same triggers above to allow for validation processing
--
procedure enable_ffue_cascade_trig;
--
------------------------- disable_refbal_trig -------------------------
--
-- disables the triggers fired off when delete from ff_user_entities which
-- gives a performance enhancement. As we have cleared ff_fdi_usages_f
-- previously, the validation here is unnecessary
--
procedure disable_refbal_trig;
--
------------------------- enable_refbal_trig -------------------------
--
-- re-enables the same triggers above to allow for validation processing
--
procedure enable_refbal_trig;
--
------------------------- truncate_fcomp_info -------------------------
--
-- deletes all formula compilation info
--
procedure truncate_fcomp_info;
--
----------------------- update_defined_balance -----------------------
--
-- Update a defined balance's database items for a set of languages.
-- The P_LANGUAGES list's indexes must start at 1 and go up in
-- increments of 1.
--
-- Notes: This is unsuitable for PAY_BALANCE_TYPES_F_TL or
-- PAY_BALANCE_DIMENSIONS_TL trigger calls because it builds the
-- database item names by fetching from these tables.
--
procedure update_defined_balance
(p_defined_balance_id in number
,p_languages          in dbms_sql.varchar2s
);
--
------------------------- update_element_type ------------------------
--
-- Update an element type's database items for a set of languages.
-- The P_LANGUAGES list's indexes must start at 1 and go up in
-- increments of 1.
--
-- Notes: This is unsuitable for PAY_ELEMENT_TYPES_F_TL trigger call
-- because it builds names by fetching from PAY_ELEMENT_TYPES_F_TL.
--
procedure update_element_type
(p_element_type_id in number
,p_effective_date  in date
,p_languages       in dbms_sql.varchar2s
);
--
------------------------- update_input_value -------------------------
--
-- Update an input value's database items for a set of languages.
-- The P_LANGUAGES list's indexes must start at 1 and go up in
-- increments of 1.
--
-- Notes: This is unsuitable for PAY_INPUT_VALUES_F_TL trigger call
-- because it builds names by fetching from PAY_INPUT_VALUES_F_TL.
--
procedure update_input_value
(p_input_value_id in number
,p_effective_date in date
,p_languages      in dbms_sql.varchar2s
);
--------------------- process_pay_dyndbi_changes -------------------------
--
-- Process rows in PAY_DYNDBI_CHANGES to generate new translated
-- dynamic database item names at the end of translation patch
-- application.
--
--
procedure process_pay_dyndbi_changes
(errbuf                out nocopy varchar2
,retcode               out nocopy number
,p_element_types    in     varchar2
,p_input_values     in     varchar2
,p_defined_balances in     varchar2
,p_localization     in     varchar2
);
--
end hrdyndbi;

/

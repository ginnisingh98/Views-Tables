--------------------------------------------------------
--  DDL for Package Body HRDYNDBI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDYNDBI" as
/* $Header: pydyndbi.pkb 120.27.12010000.4 2009/08/22 07:13:16 pgongada ship $ */
--
/*
--
-- Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
/*
PRODUCT
    Oracle*Payroll
--
NAME
    pydyndbi.pkb  - procedures for creating/ deleting DYNamic DataBase Items.
--
DESCRIPTION
    This package contains a collection of routines for generating and
    deleting dynamic database item.  The routes must already be in the
    database for these routines to work.
    The following database items are created/ deleted using procedures in
    this file:
    balances
    element types
    input values
    grade rates
    descriptive flexs
    key flexs
    absence types
NOTES
    User Defined Data:
    -----------------
    User defined data may either be owned by a          ---------------------
    business group OR by a legislation. Since           | User Defined Data |
    a business group belongs to a legislation,          ---------------------
    the legislation code for data that has a                Y         Y
    business group id may always be derived.                |         |
                                                         \  |         |   /
                                                          \ |         |  /
    The effect on the entity horizon is that               \------------/
    either the legislation code OR the                      |         |
    business group id may be specified.  The           ------------   |
    columns on the table ff_user_entities should       | Business |   |
    not BOTH be populated.                             |  group   |   |
                                                       ------------   |
    The allowed combinations for these 2 columns            Y         |
    are shown in the table below.  This is now the          |         |
    same model for Payroll and Formula.                     |         |
                                                            |         |
                                                          ---------------
                                                          | Legislation |
                                                          ---------------
    --
      --------------------------------------------------------------------
      |                              Legislation            Business     |
      |                                 Code                Group id     |
      |                                                                  |
      | Generic Startup Data     :      null                  null       |
      |                                                                  |
      | Legislation Specific     :    not null                null       |
      | Startup Data                                                     |
      |                                                                  |
      | User Defined Data        :      null                not null     |
      |                                                                  |
      --------------------------------------------------------------------
    --
    (Previously Formula used the same model, EXCEPT that User Defined Data had
     both columns as not null).
    --
    --
    Creating DB Items:
    -----------------
    The main procedures that create/ delete database items are named xxx_dict.
    These procedures share some general purpose routines to simplify the
    process of creating DB items.  These procedures are called:
    --
    insert_user_entity
    insert_parameter_value
    insert_database_item
    --
    Since they are declared in the package header, other routines that may
    be written in the future to generate DB items may also reference them.
    Each of the database creation procedures follow a similar layout:
    --
    The procedure (xxx_dict) is called with the relevent parameters (for
    example the procedure to generate Element DB items is passed an element
    type id and an effective date).  The procedure may then retrieve further
    information from the database.  Then the entity is created with a call
    to: 'insert_user_entity'.  This defines what route the database items will
    be attached to.  If the route uses any where clause fillers (written as
    (Ux in the route) then the procedure 'insert_parameter_value' is called
    next.  (If the route does not use any where clause fillers, this call is
    omitted).  Finally the procedure calls 'insert_database_item' for every
    datbase item that is to be attached to the entity (and hence the route).
    When several database items are to be created each with a different route,
    then the main procedure (xxx_dict) calls the 3 routines in order, ie:
    --
    procedure xxx_dict (..)   -- create some DB items
    begin
      -- get some information from the database
      insert_user_entity (..);
      insert_parameter_value (..);    -- if the route uses where clause fillers
      --
      -- now create all the DB items for the above entity (and hence route)
      --
      insert_database_item (..);
      insert_database_item (..);
      insert_database_item (..);
      --
      -- another route is required, so declare a new user entity:
      --
      insert_user_entity (..);
      insert_parameter_value (..);
      --
      -- now create all the DB items for the above entity (and hence route)
      --
      insert_database_item (..);
      insert_database_item (..);
      insert_database_item (..);
    end;
    --
    Refer to the procedure headers for more information on each procedure.
--
   Name   Ver    DD-MON-YYYY BugNo. and text
   -----------------------------------------
   pgongada 115.150 22-Aug-2009    Bug#8717589.Creating database items for
                                   'Further Personal Payment Method Info' DFF.
   priupadh 115.149 15-May-2009    Bug 8512762 Added commit in process_pay_dyndbi_changes.
   ckesanap 115.148 25-Apr-2008    Bug 6955080. In delete_keyflex_dict, chaged the
                                   where condition clause for deleting the
                                   existing user_entity from ff_user_entities.
   ckesanap 115.147 07-Aug-2007    Bug 5930272. Added fnd_message.retrieve() in
                                   insert_user_entity_main() to clear the message
				   in the FND message queue as the error raised
				   in checkformat() is being handled.
   ckesanap 115.146 18-Jul-2007    Bug 6215173. Passed null for l_legislation_code
                                   parameter to create_key_flex() in
				   create_keyflex_dict() procedure.
   divicker 115.145 22-MAY-2007    Merge exists for check_for_(tl)_dbi_clash
   divicker 115.144 16-MAY-2007    Optimizer hints added for procedures
                                   check_for_(tl)_dbi_clash
   arashid  115.143 24-NOV-2006    Make dbi2ueid error message give out
                                   more information. Also, catch
                                   exceptions from update_xxx calls
                                   in pay_process_dyndbi_changes and
                                   log the errors.
                                   Set the g_security_group_id for the
                                   NAME_TRANSLATIONS lookup in
                                   pay_process_dyndbi_changes, otherwise
                                   the meaning is not translated.
                                   Only delete PAY_DYNDBI_CHANGES row if
                                   no errors occurred.
   arashid  115.142 10-NOV-2006    Bug5464970 fix for changed
                                   pay_dbitl_update_errors_pkg.fetch_all_rows
                                   interface. Also, use dbms_sql.varchar_table
                                   in process_leg_translations.
   arashid  115.141 22-SEP-2006    Bug 5556728: in the MLS dbi case,
                                   'Pay Value' was passed into
                                   replace_code_name so the replacement was
                                   not taking place.
   divicker 115.140 01-JUN-2006    11511 branch merge
   arashid  115.139 11-MAY-2006    Add code for running legislation-specific
                                   database item translation from
                                   process_pay_dyndbi_changes.
   arashid  115.138 09-MAY-2006    Don't disable ff_user_entities delete
                                   triggers as thay are required to delete
                                   ff_database_items_tl rows (other child
                                   rows are cascade deleted).
   arashid  115.137 05-MAY-2006    Use substr to restrict names to 80
                                   characters in routines that generate base
                                   dbi names  - this is to match the main
                                   dynamic dbi name generation code. The
                                   changes are in:
                                   GEN_ET_BASE_DBI_NAME
                                   GEN_DB_BASE_DBI_NAME
                                   GEN_EIV_BASE_DBI_NAME
   arashid  115.136 04-MAY-2006    Fixed infinitely looping code for
                                   translating DATE_PAID and non-DATE_PAID
                                   ELEMENT TYPE / INPUT VALUE database items.
                                   Put debug into PROCESS_PAY_DYNDBI_CHANGES,
                                   and tidied up the update error logging
                                   code therein.
   arashid  115.135 27-APR-2006    The following changes were made:
                                   - process date-paid and non-date-paid
                                     database items when updating _TL names.
                                   - process_pay_dyndbi_changes code now calls
                                     FF_DATABASE_ITEMS_PKG.UPDATE_SEEDED_TL_ROWS
                                     and writes messages to the concurrent
                                     processing log file.
   arashid  115.134 31-MAR-2006    Changed  process_pay_dyndbi_changes to not
                                   raise assertions when entities are missing.
                                   Instead, the condition is traced and the
                                   PAY_DYNDBI_CHANGES row deleted.
   arashid  115.133 27-JAN-2006    Changed  process_pay_dyndbi_changes to a
                                   concurrent processing interface with VARCHAR2
                                   parameters.
   arashid  115.132 11-NOV-2005    Fixed bug in new_defined_balance whereby
                                   p_defined_balance_id was being passed
                                   as p_balance_type_id in GEN_DB_TL_DBI_NAME.
   arashid  115.131 01-NOV-2005    Made process_pay_dyndbi_changes multi-threaded.
   arashid  115.130 31-OCT-2005    Changed PROCESS_PAY_DYNDBI_CHANGES to COMMIT
                                   every 50 rows.
   arashid  115.129 19-OCT-2005    Added support for fully translated dynamic
                                   database items.
                                   1. Added internal insert_database_item
                                      interface with extra parameters to
                                      help with fully translated database
                                      items.
                                   2. Tightened up validation for 'SEED'
                                      condition to check against business
                                      groups with the same legislation code.
                                   3. Extracted code into functions for reuse:
                                      check_for_dbi_clash
                                      replace_code_name
                                      uom_requires_dbis
                                   4. Changed insert_database_item to handle
                                      full MLS and pseudo-MLS as separate
                                      cases. For full MLS, only a single
                                      base DBI in ff_database_items is
                                      generated.
                                   5. Changed code for generating element,
                                      input, and defined balance DBIs to
                                      handle full MLS where it is supported.
                                   6. Added update_xxx calls for MLS updates
                                      to FF_DATABASE_ITEMS_TL.
                                   Updates to FP.K and earlier should be
                                   branched on 115.28.
   alogue   115.128 07-OCT-2005    Performance fix to sel_ffci in
                                   create_alternative_dbis. Bug 4658377.
   nbristow 115.126 01-AUG-2005    Added support for OTL balances.
   divicker 115.125 27-JUL-2005    add sleep for all workers bar first when
                                   altering trigger states to prevent ora 4061
   divicker 115.124 27-JUN-2005    add delimiting quotes to a text type
                                   route parameter value 4431372
   divicker 115.123 23-JUN-2005    hint update
   divicker 115.122 22-JUN-2005    Add ordered hints for 2 stmts that speed up
                                   fresh installs of hrglobal
   divicker 115.121 09-JUN-2005    4363933 Add sleep to prevent too many
                                   executions of worker complete loop
   arashid  115.120 25-MAY-2005    4387272
                                   Fixed FF_COMPILED_INFO_F delete code so
                                   that all the affected FF_COMPILED_INFO_F
                                   rows are deleted. The changes are made
                                   for the partial delete cases:
                                   delete_compiled_formula
                                   delete_compiled_formula_priv
                                   legislative rebuild_ele_input_bal
   divicker 115.119 17-MAY-2005    Pre delete formula usages compiled info
                                   by legislation or all if core
   divicker 115.118 13-MAY-2005    Add commit points per 100 rows
                                   Trace the worker for each main loop
   divicker 115.117 12-MAY-2005    Regress back to fail and quit mode
   divicker 115.116 11-MAY-2005    Fix duplicate RB user entity creation
   divicker 115.115 05-MAY-2005    Add name delete for RB ue as well
   divicker 115.114 21-APR-2005    add hint to del_comp_form_priv cursor
   divicker 115.113 21-APR-2005    make internal calls to del_comp_form
                                   call a more performant del_comp_form_priv
                                   version instead when we can guarantee internal
                                   calls will have a non-null creator id so we
                                   can exploit the index by removing the nvl
   divicker 115.112 20-APR-2005    fix issue with RB only def bal creation
   divicker 115.111 31-MAR-2005    refresh def bal cursor addition and
                                   and get_alt_route addition for 4273939
   divicker 115.110 29-MAR-2005    fix to delete_compiled_formula when passed
                                   leg_code is null even though formulae
                                   may not be null 4262658
   divicker 115.109 10-MAR-2005    fix an incorrect trace stmt
   divicker 115.108 10-MAR-2005    dont eenable triggers in exception blk of
                                   reib in order to avoid red herring mutation
                                   erros in other drivers. instead do it in
                                   hrrbdeib caller. Do it at beginning so both
                                   are initially enabled if calling reib
                                   manually
   divicker 115.107 24-FEB-2005    comment change
   divicker 115.106 23-FEB-2005    trace each main ID being processed
                                   allows for much faster tracing
                                   format is:
                                   RDB:B,RB:leg_code.bg.defbalid,baldimid,baltype,srunbal
                                   RELE:element_type_id.date
                                   RELI:input_value_id.date
                                   To rerun hrrbdeib for just one piece of data call the following
                                   call disable trigger procs
                                   set boolean hrdyndbi.g_triggers_altered true
                                   for RDB: hrdyndbi.refresh_defined_balances(defbalid, 1);
                                   for RELE: hrdyndbi.create_element_type_dict(element_type_id,dt);
                                   for RELI: hrdyndbi.create_input_value_dict(input_value_id,dt);
                                   <dt is to_date(<date>,'DD-MM-YYYY')> or null
   divicker 115.105 23-FEB-2005    deliver better restricted tracing data
   divicker 115.104 17-FEB-2005    mod to dcf
   divicker 115.103 15-FEB-2005    decompile formula on leg code
   divicker 115.102 10-FEB-2005    Add applied date to see when each worker is
                                   started
   divicker 115.101 09-FEB-2005    mthread fix
   divicker 115.100 01-FEB-2005    Add proc reib_all
   divicker 115.99 28-JAN-2005     form id pick fix and perf improvements
   divicker 115.98 26-JAN-2005     del_comp_form E takes null leg_code not %
                                   use l_entity_name in del_c_f KF
   divicker 115.97 24-JAN-2005     Put back mod for refresh_element_types
   divicker 115.96 21-JAN-2005     Be more selective on the formulae to
                                   uncompile so FFXBPC can run faster
   divicker 115.95 21-JAN-2005     Remove sho err
   divicker 115.94 19-JAN-2005     Performance improvements
   divicker 115.93 18-NOV-2004     Multithread
   alogue   115.92 28-JUL-2004     Ensure quoted dbitems front last change
                                   do not exceed 80 characters.  Bug 3797888.
   alogue   115.88 06-JUL-2004     Quote dbitem names that would have failed
                                   with illegal characters. Bug 3723715.
   divicker 115.87 24-JUN-2004     More mods to debug for insert route param
   divicker 115.86 12-MAY-2004     Fix for 8i
   divicker 115.84 06-MAY-2004     More debug info for input value
   divicker 115.83                 Add a load of additional debug info.
                                   PYUPIP apps/apps HRDYNDBI
   divicker 115.81 09-DEC-2003     No multi-thread
                                   Merge changes in 115.79
                                   Merge changes in 115.80
   divicker 115.76 24-SEP-2003     Same as 115.74 (back out mthread routines)
   alogue   115.74 31-JUL-2003     Bug 3073514. Replace hyphens with underscores
                                   from flex segment names before creating
                                   their dbitems.  Change to dflex_c2.
   alogue   115.73 28-MAY-2003     Bug 2977644. Fix delete_compiled_formula
                                   to correctlt delete formula.
   alogue   115.72 02-MAY-2003     Bug 2936561. Remove full stops from input
                                   value names before ue and dbi creation.
                                   GUI should have avoided full stops being in
                                   input value names, but transpires accrual
                                   code creates elements and input values
                                   without running checkformat check. This is
                                   really a workaround to that issue.
   alogue   115.71 02-MAY-2003     Bug 2936750. Remove full stops from flex
                                   segment names before creating their dbitems.
                                   Change to dflex_c2;
   scchakra 115.70 30-APR-2003     Created procedure recreate_defined_balance.
                                   Bug - 2450195.
   alogue   115.69 28-MAR-2003     Bug 2865665. Change behaviour for
                                   so always set to Y if on db less than 9i.
   divicker 115.68 17-MAR-2003     Modify leg code specific version of
                                   refresh_element_types to only pick up
                                   IVs that are deemed for dbi generation
   alogue   115.67 10-MAR-2003     Bug 2836076. Change LOW_VOLUME behaviour
                                   so defaults to TRUE for dbs earlier
                                   than 9i.
   alogue   115.66 06-MAR-2003     Bug 2835806. Fix to legislative
                                   rebuild_ele_input_bal to ensure only
                                   Balance user entities get deleted.
   scchakra 115.65 20-FEB-2003     Bug 2813405. Removed code to raise error
                                   PAY_34166_DF_DBI_MULTI_OCCUR from procedures
				   create_dev_desc_flex_dict and
				   get_legislation_code.
   scchakra 115.64 11-FEB-2003     Bug 2637573. Modified
                                   create_dev_desc_flex_dict to create DB items
                                   for routes defined in table
                                   pay_route_to_descr_flexs. Created a new
                                   function get_legislation_code.
   divicker 115.63 03-FEB-2003     bugfix 2782128
   divicker 115.62 31-JAN-2003     Ensure BG items related to legcode are also picked
                                   up for processing in legislative striping mode
   alogue   115.61 18-DEC-2002     NOCOPY changes. Bug 2692195.
                                   Support of Competencies dbitem creation in
                                   create_keyflex_dict.
   alogue   115.60 15-NOV-2002     Changed balance dbitem definition strategy so
                                   now only use RULE hint when LOW_VOLUME
                                   pay_action_parameter is set to Y.  Thus default
                                   behaviour is now that balances won't have this hint.
   RThirlby 115.59 15-OCT-2002     Changed new_defined_balance to default the
                                   save_run_balance flag is it is not alreaady
                                   set, and if a default is available.
   nbristow 115.58 03-OCT-2002     Changed new_defined_balance to allow calls to
                                   get_value.
   mkandasa 115.57 03-OCT-2002     Removed the error which is raised if p_record_inserted
                                   returns false in insert_user_entity.
   mkandasa 115.56 01-OCT-2002     Substr'd user entity name to 80 chars.Raised
                                   Error in case of duplication of user entity name.
                                   Bug no 2073022.
   divicker 115.55 24-SEP-2002     H_ instead of H_DEC
   divicker 115.54 20-SEP-2002     Slight fix to change in 115.53
   divicker 115.53 19-SEP-2002     Change UOM H_ support to use H_DEC%. Tidy up of string
   alogue   115.51 11-SEP-2002     Remove full stops from potential dbitems. Bug 2557062.
   alogue   115.50 22-AUG-2002     Remove brackets from potential dbitems. Bug 2377726.
   divicker 115.49 29-JUL-2002     Leg code striping for formula
   mreid    115.48 18-JUL-2002     Modify creation of rpv for Entry DDF
   alogue   115.47 16-JUL-2002     Handle user entities owned by old
                                   values of SCL legislation rule
                                   in create_scl_flex_dict.
   divicker 115.46 26-JUN-2002     Added call in create_desc_flex_main to
                                   insert rpv for ENTRY_DESC_FLEX_ROUTE
   divicker 115.45 17-JUN-2002     Added back H_% UOM support
                                   Added route parameter for ENTRY_DESC_FLEX
                                   route
   mreid    115.44 11-JUN-2002     Added support for Entry DDF
   divicker 115.43 22-MAY-2002     Back out 115.41 change until July MP
   rthirlby 115.42 13-MAY-2002     Corrected delete of SRB user entities to
                                   delete of RB user entities.
   divicker 115.41 01-MAY-2002     Added H_% UOM to generate fffunc.cn calls
   rthirlby 115.40 01-MAR-2002     Added procedure create_alternative_dbis, to
                                   create user entites for run balances. NB, no
                                   dbi is created, to avoid the possibility of
                                   people using the wrong dbi in formulas.
                                   Added delete of SRB balances to rebuild_ele_
                                   input_bal procedure.
   alogue          08-MAR-2001     Fix insert_database_item when passed in
                                   user_entity_id.
   alogue           12-DEC-2000    Suport of creation of dbitems in
                                   create_dev_desc_flex_dict for Extra Location Info
                                   DDF, Extra Position Info DDF and Extra Person Info
                                   DDF.
   alogue           23-NOV-2000    Always RULE hint for balace dbitems. Bug 1513266.
   divicker 115.35  30-OCT-2000    trigger enabled check for new_defined_balance
                                   procedure added.
   divicker 115.34  30-OCT-2000    Exception handler for reenabling triggers.
                                   Check on derived codename value and whether triggers
                                   are disabled or not, keeping original logic if
                                   insert_database_item, insert_user_entity not called
                                   via rebuild_ele_input_bal.
   jarthurt 115.33  28-OCT-2000    Remove enabling and disabling of triggers in
                                   rebuild_ele_input_bal. These are being transfered
                                   to hrrbdeib.sql.
   divicker         04-OCT-2000    Perf. enhancements to rebuild_ele_input_bal
   alogue           07-AUG-2000    Fix to bug fix 1271588.
   alogue           28-JUN-2000    Support of BALANCE_DBITEM_TYPE for flexible
                                   balance dbitem definition text approach.
                                   Includes Rule Hint.
   alogue           20-APR-2000    Fix issue in descriptive flex dflex_c1 cursor
                                   to handle titles that have been passed that
                                   contain full-stops.  Bug 1271588.
   alogue           16-MAR-2000    Fix issue in insert_database_item to handle
                                   NAME_TRANSLATIONS lokkup meanings that
                                   contain apostrophes.  Bug 1210117.
   tbattoo          24-FEB-2000    Bug 1207273, if a user entity alredy exists when
                                   you insert the db item use the id for the
                                   existing entity and not the currval in the seq
   alogue           22-FEB-2000    Translated Pay Value Database Item issue.
                                   Bug 1110849.
   alogue           14-FEB-2000    Utf8 support.
   alogue           28-JAN-2000    Performance fix to create_element_type.
   alogue           10-NOV-1999    Fix issue in descriptive flex dflex_c1 cursor
                                   to handle titles that have been passed that
                                   contain apostrophes.  Bug 1061472.
   jmoyano          03-NOV-1999    generator for Payroll DDF added to procedure
                                   create_dev_desc_flex_dict.
   alogue           02-NOV-1999    Fix issue in delete_flexfield_dict to handle
                                   titles that have been passed that contain
                                   apostrophes. Bug 1058676.
   alogue           05-OCT-1999    Fix issue in create_input_value to handle
                                   scenario where some user entities already exist,
                                   but others don't. Bug 1018544.
   alogue           23-SEP-1999    Support application_ids for SSP (804),
                                   OAD (805), HXT (808), Federal HR (8301).
   alogue           22-SEP-1999    Change to reflect desc flex titles now being
                                   stripped of apostrophes prior to being passed
                                   in.
   kkawol           14-SEP-1999    Changed create_input_value, now checking date
                                   UOM is set to 'D' instead of 'D_%'.
   alogue           04-AUG-1999    Canoncial Number fix for absence dbitems.
   alogue           01-JUL-1999    Fix to exc_acc and scl dbitem creations so
                                   that now process several legislations using
                                   the same passed in flexfield.
   alogue           09-JUN-1999    Now handles descriptive flexfields titles
                                   that contain apostrophes ie Add'l Org Unit Details.
                                   Bug 874129.
   alogue           24-MAY-1999    Support for Cananda in creation of Org
                                   dev flex dbis.
   alogue           27-APR-1999    Change in create_input_value support
                                   of canonical numbers.
   alogue           26-APR-1999    Fixes in create_input_value to support
                                   canonical dates and canonical numbers.
   alogue           09-APR-1999    Change in new_defined_balance to support
                                   canonical numbers in balances database items.
   cborrett         04-DEC-1998    Added generation of context sensitive
                                   dbitems in procedure CREATE_FLEXFIELD_DICT().
                                   Replaced hardcoded routes in CREATE_FLEXFIELD_DICT()
                                   with cursor against new table pay_route_to_descr_flexs.
   alogue           08-JAN-1999    Change in create_desc_flex to create
                                   CURRENCY_CODE dbitem for  Org Pay Method
                                   descriptive flex.
   arundell         06-JAN-1999    Changes in insert_database_item to support
                                   MLS.
   alogue           02-DEC-1998    Removed application_id check on hr_lookups
                                   within insert_database_item.
   alogue           05-OCT-1998    Fix insert_user_entity check of whether entity
                                   exists to also check it is in current bus grp
                                   or legislation.
   alogue           09-MAR-1998    Creation of overloading of insert_user_entity
                                   so 'old' style call is supported ie called
                                   without p_record_inserted out parameter
                                   added by 13-JAN-1998 change.
   mfender          10-FEB-1998    Bug 610203 - removed count(*) from
                                   insert_database_item.
   amills   110.11  23-JAN-1998    Bug 523343. Changed insert_database_item procedure.
                                   Added cursor get_codename which takes the
                                   parameter item name and splits into constituent
                                   items where necessary for matching onto hr_lookups,
                                   so that translation of each part can be effective.
                                   After retrieving the translatable 'meaning',
                                   the constituent parts are then concatenated back
                                   to form a fully translated db item.
    amyers          13-JAN-1998    Amended procedure insert_user_entitiy to:
                                   i.  only insert data if it doesn't exist,
                                   ii. return a value in a new parameter indicating
                                       whether the insert has happened to determine
                                       the creation of underlying parameter values
                                       and database items.
                                   This change comes from bug 602851, where in an
                                   R11 upgrade database items and entities were not
                                   created and formulae would then not compile, so
                                   in driver hr11gn.drv we need to run procedure
                                   refresh_grade_spine_rates to ensure this doesn't
                                   happen.
                                   New version is 110.10.
    amills          24-DEC-1997    Added rtrim to same select to remove full stop,
                                   a temporary workaround for bug 603256 to
                                   ensure no reserved words or characters are in desc
                                   flex creation.
    amills          09-DEC-1997    changed l_title to select from fnd_descriptive_
                                   flexs_vl rather than take a hardcoded value
                                   in create_org_pay_flex_dict
    alogue          28-OCT-1997    legislation_code used in delete from ff_user_entities
                                   in delete_keyflex_dict. Fix to bug 513364.
    mreid           24-SEP-1997    Changed table_names for release 11 security.
    dsaxby          15-SEP-1997    Changed substr to substrb to avoid problems with
                                   generating NLS database items.
    alogue          13-AUG-1997    Business_group_id passed to delete_keyflex_dict
                                   to fix bug 513364.
    nbristow        25-JUL-1997    Changed all references of fn_descriptive_flexs
                                   to fnd_descriptive_flexs_vl.
    mwcallag        26-APR-1995    Entity name passed to delete_keyflex_dict to
                                   fix bug 278064.
    rfine           24-NOV-1994    Suppressed index on business_group_id
    mwcallag        13-OCT-1994    Route PAYROLL_ACTION_FLEXFIELD_ROUTE deleted.
    rfine           05-OCT-1994    Changed call to renamed package: was us_contr_dbi,
                                   now pay_us_contr_dbi.
    mwcallag        28-JUL-1994    Optional commit points added to procedure
                                   rebuild_ele_input_bal.
    mwcallag        20-JUL-1994    It has been decided to convert the formula model
                                   to the payroll model for User Defined Data,
                                   thereby being consistent for Payroll and Formula.
                                   This means that for User Defined Data only the
                                   business group id should be populated on
                                   ff_user_entities, not legislation code as well.
                                   (previously both columns were populated).  Refer
                                   to the Notes above for more information. The
                                   change dated 15-JUL-1994 is undone.
    mwcallag        15-JUL-1994    procedure 'new_defined_balance' altered to
                                   populate leg_code in ff_user_entity if the
                                   business group id is null. (ie. payroll to
                                   Formula startup data interface). <- temp. change.
    mwcallag        13-JUN-1994    G916 Procedure 'rebuild_ele_input_bal' added.
    mwcallag        07-JUN-1994    G890 Entity name for DF Element Type corrected.
    mwcallag        06-JUN-1994    G867 The user entity id is no longer appended to
                                   the user entity name when the entity is created.
                                   This eases the startup delivery for DB items.
    mwcallag        25-MAY-1994    G795 The new where clause filler of element type
                                   id was missing from the input value route
                                   'INPUT_VALUE_ENTRY_LEVEL'  for multiple
                                   entries allowed input values.
    mwcallag        29-APR-1994    Element type id context added for the route:
                                   INPUT_VALUE_ENTRY_LEVEL to improve performance.
    mwcallag        28-FEB-1994    Database names changed from '%ASS_%' to '%ASG_%'.
    mwcallag        20-JAN-1994    Legislation code passed to delete_keyflex_dict,
                                   procedure delete_compiled_formula added (G516).
    mwcallag        11-JAN-1994    The title of the Element DF changed from 'Element
                                   Developer DF' to 'Further Element Information'.
    mwcallag        09-DEC-1993    G334 For element or input values DB items, if the
                                   legislation code is null on the base table it
                                   is derived from per_business_groups.
    mwcallag        08-DEC-1993    G323 Context name is now used in the entity name
                                   (together with the title) for all descriptive
                                   flex DB items.
    mwcallag        07-DEC-1993    G291 Change to Legal Company DB items.
    mwcallag        30-NOV-1993    G259 procedure insert_parameter_value corrected to
                                   properly handle multiple where clause fillers.
    mwcallag        29-NOV-1993    G221 Improved handling for long database item
                                   names.
    mwcallag        23-NOV-1993    G161 Simplified the calls to generate DB items for
                                   external use.  Element DDF DB item now gets the
                                   legislation code from per_business_groups if the
                                   legislation code is null and business_group_id
                                   is present on the element type table.  (The
                                   legislation code concatenated with the element
                                   classification is used as the context code in the
                                   AOL descriptive flex tables).
    mwcallag        03-NOV-1993    Assignment Developer Descriptive flex DB items
                                   added.
    mwcallag        02-NOV-1993    ********************************
                                   * DIVERGENCE FROM FROZEN CODE  *
                                   ********************************
                                   Input Value DB item creation now tests the
                                   multiple entries allowed flag, rather than the
                                   recurring flag.  Developer descriptive flex
                                   DB items for elements and jobs added.
                                   Benefit classification DB items added.
    mwcallag        26-OCT-1993    Sum function in definition text for non-recurring
                                   input values moved to outer parenthesis to stop
                                   sql retrival error.
    mwcallag        28-SEP-1993    pay_name_translations reference replaced with
                                   hr_lookups in insert_database_item procedure,
                                   also passed parameter of legislation code removed
                                   since it is no longer used.
    abraae          09-SEP-1993    strip blanks from DB Item defn text to fit into
                                   ff_database_items.definition_text (char(240))
    mwcallag        08-SEP-1993    Input value definition text modified to include a
                                   decode on the UOM to avoid problem in formula when
                                   several DB items of different user definable
                                   data types are retrieved in 1 formula cursor.
    mwcallag        01-SEP-1993    Procedure for converting element DB items from the
                                   context of date earned to date paid added. Enable
                                   checks added to cursors in SCL and descriptive
                                   flex routines.
    mwcallag        23-AUG-1993    More DB items for Descriptive flexfields added,
                                   plus Organization payment methods, external
                                   accounts and legal company SCL DB items.
    mwcallag        03-AUG-1993    Developer Descriptive flexfield and SCL flexfield
                                   procedures added.
    mwcallag        27-JUL-1993    Passed parameter name to Key flexfield DB items
                                   now use the short names of GRP, GRD, POS JOB.
    mwcallag        20-JUL-1993    Not found flags set to yes, this stops quickpaint
                                   error on an assignment with minimal information.
                                   Dummy group function added to recurring input
                                   values to stop formula error (see input value
                                   code below for more information).
    mwcallag        18-JUN-1993    Descriptive and key flex deletion routines now
                                   delete compilied DB items from ff_fdi_usages_f
    mwcallag        14-JUN-1993    Application id removed from both
                                   delete_flexfield_dict and create_flexfield_dict
    mwcallag        03-JUN-1993    Create descriptive and key flexfield routines
                                   delete old flexfields before creation attempted.
    mwcallag        26-MAY-1993    Creator types changed to reflect database change.
    mwcallag        24-MAY-1993    'rate_type' DB item removed from grade rate
                                   creation. (Bug 160305 rejected for rel. 10).
    mwcallag        07-MAY-1993    Spine DB creation added to grade procedure.
                                   DB creation procedure for key flexfield.
    mwcallag        30-APR-1993    Grade rates extended, descriptive flexs and
                                   absence types added.
    mwcallag        26-APR-1993    Procedures for input values, element types
                                   and grade rate database items added.
    Abraae          06-APR-1993    Created.
*/
--
-- Translations Data Structures
--
type r_dbi_prefix is record
(language varchar2(30)
,found    boolean
,prefix   varchar2(240)
);

type t_dbi_prefixes is table of r_dbi_prefix index by binary_integer;
--
-- Flags for PROCESS_PAY_DYNDBI_CHANGES procedure.
--
g_dyndbi_changes boolean := false;
g_dyndbi_changes_ok boolean;
--
-- Cursors for descriptive flexs, used by more than one procedure:
--
-- declare cursor 1 for retrieving the context level of the descriptive flex:
--
cursor dflex_c1 (p_table_name   varchar2,
                 p_title        varchar2,
                 p_global_flag  varchar2,
                 p_context      varchar2) is
SELECT DFC.descriptive_flexfield_name c_flex_name,
       replace (replace (replace (ltrim(rtrim(upper(DF.title))),
                                 ' ','_'),'''',''),'.','_') c_title,
       DFC.created_by c_created_by,
       DFC.last_update_login c_last_login
FROM   fnd_descriptive_flexs_vl             DF,
       fnd_descr_flex_contexts              DFC
WHERE  DF.application_table_name          = p_table_name
AND    replace (ltrim (rtrim(DF.title)), '''','') = replace(p_title,'''','')
AND    DF.application_id                 IN (800, 801, 804, 805, 808, 8301)
AND    DF.descriptive_flexfield_name      = DFC.descriptive_flexfield_name
AND    DFC.enabled_flag                   = 'Y'
AND    DFC.global_flag                    = p_global_flag
AND    DFC.application_id                IN (800, 801, 804, 805, 808, 8301)
AND    DFC.descriptive_flex_context_code  = p_context;
--
-- declare cursor 2 for retrieving the actual column names:
--
cursor dflex_c2 (p_descr_flex varchar2,
                 p_context    varchar2) is
SELECT DFCU.application_column_name  c_def_text,
     replace(replace(replace (ltrim(rtrim(upper(DFCU.end_user_column_name))),
                     ' ','_'),'.',''),'-','_') c_db_name
FROM   fnd_descr_flex_column_usages         DFCU
WHERE  DFCU.descriptive_flexfield_name    = p_descr_flex
AND    DFCU.application_id               IN (800, 801, 804, 805, 808, 8301)
AND    DFCU.descriptive_flex_context_code = p_context
AND    DFCU.enabled_flag                  = 'Y';
--
-- Cache parameters for new_defined_balance
--
cached       boolean  := FALSE;
g_low_volume pay_action_parameters.parameter_value%type := 'N';
--
-- Cache value for security group ID
--
g_security_group_id number;
g_sess_date         date;
--
-- Multithread support procedure
--
PROCEDURE insert_mthread_pps (p_stage     number,
                              p_worker_id number,
                              p_leg_code  varchar2 default 'ZZ')
IS
 PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

        insert into PAY_PATCH_STATUS(id,
                                     patch_number,
                                     patch_name,
                                     process_type,
                                     applied_date)
        values (
            pay_patch_status_s.nextval,
            to_char(p_worker_id),
            'HRRBDEIB INTERNAL PROC S' || to_char(p_stage),
            p_leg_code,
            sysdate);
        commit;
END insert_mthread_pps;
--
PROCEDURE insert_mthread_pps_err (p_worker_id number,
                                  p_leg_code  varchar2 default 'ZZ')
IS
 PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

        insert into PAY_PATCH_STATUS(id,
                                     patch_number,
                                     patch_name,
                                     process_type,
                                     applied_date)
        values (
            pay_patch_status_s.nextval,
            to_char(p_worker_id),
            'HRRBDEIB INTERNAL PROC ERR' || to_char(p_worker_id),
            p_leg_code,
            sysdate);
        commit;
END insert_mthread_pps_err;
--
PROCEDURE hrrbdeib_trace_on IS
BEGIN
  if g_debug_cnt > 0 then
    hr_utility.trace_on(null, 'HRRBDEIB');
  end if;
END;

PROCEDURE hrrbdeib_trace_off is
BEGIN
  if g_debug_cnt > 0 then
    hr_utility.trace_off;
  end if;
END;
--
-- Function/Procedure declarations.
--
procedure check_for_dbi_clash
(p_user_name      in varchar2
,p_ue_id          in number
,p_leg_code       in varchar2
,p_bg_id          in number
,p_startup_mode   in varchar2
,p_clash          out nocopy boolean
);
--
procedure replace_code_name
(p_language_code in            varchar2
,p_item_name     in out nocopy varchar2
);
--
-- Assert a condition in the code.
--
procedure assert
(p_condition  in boolean
,p_location   in varchar2
,p_extra_info in varchar2
);
--
procedure gen_db_tl_dbi_name
(p_balance_type_id      in            number
,p_balance_dimension_id in            number
,p_language             in            varchar2
,p_tl_name                 out nocopy varchar2
,p_found                   out nocopy boolean
);
--
procedure gen_et_dbi_prefixes
(p_element_type_id in            number
,p_languages       in            dbms_sql.varchar2s
,p_prefixes        in out nocopy t_dbi_prefixes
);
--
procedure gen_eiv_dbi_prefixes
(p_input_value_id in number
,p_effective_date in date
,p_languages      in dbms_sql.varchar2s
,p_prefixes       in out nocopy t_dbi_prefixes
);
--
procedure update_tl_dbi_name
(p_user_name      in varchar2
,p_user_entity_id in number
,p_leg_code       in varchar2
,p_bg_id          in number
,p_startup_mode   in varchar2
,p_language       in varchar2
,p_tl_user_name   in varchar2
);
--
procedure update_et_tl_dbi_names
(p_leg_code       in varchar2
,p_bg_id          in number
,p_startup_mode   in varchar2
,p_user_name      in varchar2
,p_user_entity_id in number
,p_prefixes       in t_dbi_prefixes
,p_suffix         in varchar2
,p_date_p         in varchar2
);
--
function uom_requires_dbis
(p_uom in varchar2
) return boolean;
--
-- New private procedure called by overloaded create_desc_flex()
--
procedure create_desc_flex_main
(
    p_title             in varchar2,
    p_table_name        in varchar2,
    p_route_name        in varchar2,
    p_entity_name       in varchar2,
    p_context           in varchar2,
    p_global_flag       in varchar2,
    p_param_value       in varchar2,
    p_leg_code          in varchar2,
    p_business_group_id in varchar2
);
--
procedure delete_compiled_formula_priv
(
    p_creator_id            in number,
    p_creator_type          in varchar2,
    p_user_entity_name      in varchar2,
    p_leg_code              in varchar2
);
--
procedure ff_compiled_info_del
(p_formula_ids in dbms_sql.number_table
,p_start_dates in dbms_sql.date_table
);
--
procedure create_user_entity
                            (p_db_item_name       in out nocopy varchar2,
                             p_business_group_id  in     number,
                             p_legislation_code   in     varchar2,
                             p_route_id           in     number,
                             p_notfound_flag      in     varchar2,
                             p_defined_balance_id in     number,
                             p_creator_type       in     varchar2,
                             p_description        in     varchar2,
                             p_startup_mode       in     varchar2,
                             p_user_entity_id     in out nocopy number
                            )
is
   rgeflg varchar2(1);
begin
   IF (g_triggers_altered) THEN
     -- validate the name is OK. This was originally called as part of
     -- the FF_USER_ENTITIES_BRI trigger so we add it here.
     begin
       -- Check if name legal format eg no spaces, or special characters
       hr_chkfmt.checkformat (p_db_item_name, 'DB_ITEM_NAME', p_db_item_name,
                              null,null,'Y',rgeflg,null);
     exception
       when hr_utility.hr_error then
         hr_utility.set_message (802, 'FFHR_6016_ALL_RES_WORDS');
         hr_utility.set_message_token(802,'VALUE_NAME','FF94_USER_ENTITY');
         hrrbdeib_trace_on;
         hr_utility.trace('checkformat create_user_entity');
         hr_utility.trace('ue name:' || p_db_item_name);
         hrrbdeib_trace_off;
         hr_utility.raise_error;
     end;
     --
     --  create user entity
     select ff_user_entities_s.nextval
     into p_user_entity_id
     from sys.dual;

    BEGIN
     insert into ff_user_entities
     (user_entity_id,
      business_group_id,
      legislation_code,
      route_id,
      notfound_allowed_flag,
      user_entity_name,
      creator_id,
      creator_type,
      entity_description)
     select
      p_user_entity_id,
      p_business_group_id,
      p_legislation_code,
      p_route_id,
      p_notfound_flag,
      p_db_item_name,
      p_defined_balance_id,
      p_creator_type,
      p_description
     from dual
     where not exists (
       select null
       from ff_user_entities a
       where a.user_entity_name = p_db_item_name
       and
       ( p_startup_mode = 'MASTER'
         or
         ( p_startup_mode = 'SEED'
           and
           ( a.legislation_code = p_legislation_code
            or
           (a.legislation_code is null and a.business_group_id is null)
            or
            p_legislation_code =
            (
              select b.legislation_code
              from   per_business_groups_perf b
              where  b.business_group_id = a.business_group_id
            )
          )
        )
        or
        ( p_startup_mode = 'NON-SEED'
          and
          ( a.business_group_id = p_business_group_id
            or
            (a.legislation_code is null and a.business_group_id is null)
            or
            (a.business_group_id is null and a.legislation_code = p_legislation_code)
          )
        )
       ));
      EXCEPTION WHEN OTHERS THEN
       hrrbdeib_trace_on;
       hr_utility.trace('hrrbdeib ins user entity: ');
       hr_utility.trace(p_db_item_name || ' :routeid:');
       hr_utility.trace(to_char(p_route_id) || ' :legcode:');
       hr_utility.trace(p_legislation_code || ' :bgid:');
       hr_utility.trace(to_char(p_business_group_id));
       hrrbdeib_trace_off;
       raise;
      END;
   ELSE -- g_triggers_altered is FALSE so use existing trigger validation
--
     select ff_user_entities_s.nextval
       into p_user_entity_id
       from sys.dual;
--
     insert into ff_user_entities
     (user_entity_id,
      business_group_id,
      legislation_code,
      route_id,
      notfound_allowed_flag,
      user_entity_name,
      creator_id,
      creator_type,
      entity_description)
     values (
      p_user_entity_id,
      p_business_group_id,
      p_legislation_code,
      p_route_id,
      p_notfound_flag,
      p_db_item_name,
      p_defined_balance_id,
      p_creator_type,
      p_description
     );
   END IF; -- g_triggers_altered
--
--
end create_user_entity;
--
procedure create_dbi
                    (
                     p_db_item_name       in varchar2,
                     p_user_entity_id     in number,
                     p_datatype           in varchar2,
                     p_definition         in varchar2,
                     p_null_allowed       in varchar2,
                     p_description        in varchar2,
                     p_startup_mode       in varchar2,
                     p_legislation_code   in varchar2,
                     p_business_group_id  in number
                    )
is
l_exists varchar2(2);
l_clash  boolean;
begin
   --  Insert a Database Item to hold balance value.
   check_for_dbi_clash
   (p_user_name      => p_db_item_name
   ,p_ue_id          => p_user_entity_id
   ,p_leg_code       => p_legislation_code
   ,p_bg_id          => p_business_group_id
   ,p_startup_mode   => p_startup_mode
   ,p_clash          => l_clash
   );
   if not l_clash then
     insert into ff_database_items
     (user_name
     ,user_entity_id
     ,data_type
     ,definition_text
     ,null_allowed_flag
     ,description
     )
     values
     (p_db_item_name
     ,p_user_entity_id
     ,p_datatype
     ,p_definition
     ,p_null_allowed
     ,p_description
     );
   end if;
exception
  when others then
    hrrbdeib_trace_on;
    hr_utility.trace('hrrbdeib ins dbi: ');
    hr_utility.trace(p_db_item_name || ' :ue id:');
    hr_utility.trace(to_char(p_user_entity_id) || ' :legcode:');
    hr_utility.trace(p_legislation_code || ' :bgid:');
    hr_utility.trace(to_char(p_business_group_id));
    hrrbdeib_trace_off;
    raise;
end;
---------------------------------------------------------------------------
-- procedure create_alternative_dbis
---------------------------------------------------------------------------
procedure create_alternative_dbis(p_defined_balance_id    in     number,
                                  p_balance_dimension_id  in     number,
                                  p_balance_type_id       in     number,
                                  p_business_group_id     in     number,
                                  p_legislation_code      in     varchar2,
                                  p_db_item_name          in     varchar2,
                                  p_startup_mode          in     varchar2
                                 )
is
cursor get_alt_routes (p_bal_dim in  number)
is
select pdr.route_id,
       pdr.route_type,
       pdr.run_dimension_id,
       pdr.priority
from pay_dimension_routes pdr
where pdr.balance_dimension_id = p_bal_dim
and   not exists (select null
                  from   ff_user_entities u
                  where  u.creator_id = p_defined_balance_id
                  and    u.creator_type = 'RB'
                  and    u.route_id = pdr.route_id)
order by pdr.balance_dimension_id, pdr.priority;
--
cursor sel_ffci(p_dbi_item_name in varchar2,
                p_legislation_code in varchar2,
                p_business_group_id in number,
                p_startup_mode in varchar2)
is
select /*+ ORDERED
           INDEX(a FF_USER_ENTITIES_N50)
           INDEX(fdbi FF_DATABASE_ITEMS_FK1)
           INDEX(fdi FF_USER_ENTITIES_N50)
           USE_NL(a fdbi fdi) */
         formula_id
    from
          ff_user_entities a,
          ff_database_items fdbi,
          ff_fdi_usages_f fdi
     where  fdi.usage = 'D'
     and    fdi.item_name = fdbi.user_name
     and    fdbi.user_entity_id = a.user_entity_id
     and    a.user_entity_name = p_dbi_item_name
     and
       ( p_startup_mode = 'MASTER'
         or
         ( p_startup_mode = 'SEED'
           and
           ( a.legislation_code = p_legislation_code
            or
           (a.legislation_code is null and a.business_group_id is null)
            or
            p_legislation_code =
            (
              select b.legislation_code
              from   per_business_groups_perf b
              where  b.business_group_id = a.business_group_id
            )
          )
        )
        or
        ( p_startup_mode = 'NON-SEED'
          and
          ( a.business_group_id = p_business_group_id
            or
            (a.legislation_code is null and a.business_group_id is null)
            or
            (a.business_group_id is null and a.legislation_code = p_legislation_code)
          )
        )
      );

l_db_item_name ff_database_items.user_name%type;
usr_ent_id     number;
l_dbitem_def_text ff_database_items.definition_text%type;
--
begin
    --
    for rrrec in get_alt_routes(p_balance_dimension_id) loop
        --
        l_db_item_name := p_db_item_name||'_'||to_char(rrrec.priority);
        --
        -- delete the UE so we ensure that we recreate it
        for r_sel_ffci in sel_ffci(l_db_item_name,
                                   p_legislation_code,
                                   p_business_group_id,
                                   p_startup_mode) loop

          delete ff_fdi_usages_f where formula_id = r_sel_ffci.formula_id;
          delete ff_compiled_info_f where formula_id = r_sel_ffci.formula_id;

        end loop;

        delete ff_user_entities a
        where  a.user_entity_name = l_db_item_name
        and
       ( p_startup_mode = 'MASTER'
         or
         ( p_startup_mode = 'SEED'
           and
           ( a.legislation_code = p_legislation_code
            or
           (a.legislation_code is null and a.business_group_id is null)
            or
            p_legislation_code =
            (
              select b.legislation_code
              from   per_business_groups_perf b
              where  b.business_group_id = a.business_group_id
            )
          )
        )
        or
        ( p_startup_mode = 'NON-SEED'
          and
          ( a.business_group_id = p_business_group_id
            or
            (a.legislation_code is null and a.business_group_id is null)
            or
            (a.business_group_id is null and a.legislation_code = p_legislation_code)
          )
        )
       );

        create_user_entity
                 (l_db_item_name,
                  p_business_group_id,
                  p_legislation_code,
                  rrrec.route_id,
                  'N',
                  p_defined_balance_id,
                  'RB',
                  'To hold database items for the Balance '
                     || l_db_item_name || ' (automatically generated)',
                  p_startup_mode,
                  usr_ent_id
                 );
--
        --  add Route Parameter values which contains the
        --  balance type ID and balance Dimension id to make
        --  the route work (we know sequence is 1 and 2)

        insert into ff_route_parameter_values
        (route_parameter_id,
         user_entity_id,
         value)
        select RP.route_parameter_id,
               usr_ent_id,
               to_char(p_balance_type_id)
        from   ff_route_parameters RP
        where  RP.route_id = rrrec.route_id
        and    RP.sequence_no = 1;
        if sql%rowcount <> 1 then
           hr_utility.set_message(801, 'HR_ERROR');
           hrrbdeib_trace_on;
           hr_utility.trace('missing seq 1 route param for route : ' || to_char(rrrec.route_id) || ' :user ent id:' || to_char(usr_ent_id));
           hrrbdeib_trace_off;
           hr_utility.raise_error;
        end if;
--
    if rrrec.route_type = 'SRB' then
    --
    -- RR routes will only have route parameters for Balance type_id
    --

        insert into ff_route_parameter_values
        (route_parameter_id,
         user_entity_id,
         value)
        select RP.route_parameter_id,
               usr_ent_id,
               to_char(rrrec.run_dimension_id)
        from   ff_route_parameters RP
        where  RP.route_id = rrrec.route_id
        and    RP.sequence_no = 2;
        if sql%rowcount <> 1 then
           hr_utility.set_message(801, 'HR_ERROR');
           hrrbdeib_trace_on;
           hr_utility.trace('missing seq 2 route param for route : ' || to_char(rrrec.route_id) || ' :user ent id:' || to_char(usr_ent_id));
           hrrbdeib_trace_off;
           hr_utility.raise_error;
        end if;
     end if;
     --

     -- For run balances we are not creating database items, just user entities,
     -- in order to avoid the incorrect use of dbis in formulas, so call to
     -- create_dbi has been removed.
     --
     --
    end loop;
    --
end create_alternative_dbis;
--
/*------------------- new_defined_balance  -----------------------------*/
--
/*
 *  This routine creates the database item and supporting information
 *  for a single defined balance. It is normally called from the
 *  trigger on insert of defined balance, or from the refresh routine.
 */
procedure new_defined_balance (p_defined_balance_id in number,
                               p_balance_dimension_id in number,
                               p_balance_type_id in number,
                               p_business_group_id in number,
                               p_legislation_code in varchar2) is
--
cursor c_language is
select language_code
from   fnd_languages
where  installed_flag in ('I','B');
--
cursor chk_flag_set(p_def_bal number)
is
select count(*)
from   pay_defined_balances
where  defined_balance_id = p_def_bal
and    save_run_balance is null;
--
cursor get_cat_id(p_bal_type number)
is
select balance_category_id
from   pay_balance_types
where  balance_type_id = p_bal_type;
--
cursor get_sess_date
is
select effective_date
from   fnd_sessions
where  session_id = userenv('sessionid');
--
   l_route_id ff_routes.route_id%type;
   l_db_item_name ff_database_items.user_name%type;
   l_dbitem_def_text ff_database_items.definition_text%type;
   l_dbi_function pay_balance_dimensions.database_item_function%type;

   startup_mode varchar2(10);
   rgeflg varchar2(1);
   usr_ent_id number;
   route_param_value number;
   l_flag_set     number;
   l_bal_cat_id   pay_balance_types.balance_category_id%type;
   l_run_bal_flag pay_defined_balances.save_run_balance%type;
   l_sess_date    date;
   l_ora_db_vers  number; -- db version number for LOW_VOLUME

   l_legislation_code varchar2(30);
   l_full_mls boolean;
   l_found    boolean;
   l_tl_name  ff_database_items_tl.translated_user_name%type;
   --
begin
--
   IF (g_triggers_altered) THEN
     -- Get the startup mode
     startup_mode := ffstup.get_mode (p_business_group_id,
                                      p_legislation_code);
   END IF;
   --
   l_legislation_code := p_legislation_code;
   if l_legislation_code is null then
     select bg.legislation_code
     into   l_legislation_code
     from   per_business_groups_perf bg
     where  bg.business_group_id = p_business_group_id
     ;
   end if;
   l_full_mls := ff_dbi_utils_pkg.translations_supported(l_legislation_code);

   --
   -- First check if the save_run_balance flag has been set on the defined
   -- balance. If not update the column if required.
   --
   -- if this procedure has been called from the trigger pay_defined_bal_ari,
   -- then the save run balance flag will have been set if it can be set, so
   -- don't do the following check as it will cause a mutating table error.
   --
   if not g_trigger_dfb_ari then
     open  chk_flag_set(p_defined_balance_id);
     fetch chk_flag_set into l_flag_set;
     close chk_flag_set;
     --
     if l_flag_set <> 0 then -- flag not set, attempt to set it
       open get_cat_id(p_balance_type_id);
       fetch get_cat_id into l_bal_cat_id;
       close get_cat_id;
       --
       -- get the session date or default sysdate
       --
       open  get_sess_date;
       fetch get_sess_date into l_sess_date;
       if get_sess_date%notfound then
         close get_sess_date;
         l_sess_date := trunc(sysdate);
       end if;
       --
       l_run_bal_flag := pay_defined_balances_pkg.set_save_run_bals_flag
                            (p_balance_category_id  => l_bal_cat_id
                            ,p_effective_date       => l_sess_date
                            ,p_balance_dimension_id => p_balance_dimension_id);        --
       if l_run_bal_flag is not null then
       --
       -- update the defined balance
       --
       begin
         update pay_defined_balances
         set    save_run_balance = l_run_bal_flag
         where  defined_balance_id = p_defined_balance_id;
       exception
         when others then
           hrrbdeib_trace_on;
           hr_utility.trace('update pay_def_bal.save_run_balance:def_bal_id:' || to_char(p_defined_balance_id) ||
                             'to save_run_balance:' || nvl(l_run_bal_flag, 'NULL') || ':');
           hrrbdeib_trace_off;
           raise;
       end;
         --
       end if; -- flag is null, so dont both to update
       --
     end if; -- flag is set so dont do anything
   end if; -- global is true, so code skipped.
   --
   --  get details from balance dimension and type
   BEGIN
   select BALDIM.route_id,
          nvl(database_item_function, 'N'),
          upper(replace(BALTYPE.balance_name || BALDIM.database_item_suffix,
                   ' ','_'))
   into   l_route_id,
          l_dbi_function,
          l_db_item_name
   from   pay_balance_dimensions BALDIM,
          pay_balance_types BALTYPE
   where  BALDIM.balance_dimension_id = p_balance_dimension_id
   and    BALTYPE.balance_type_id = p_balance_type_id;
   EXCEPTION WHEN OTHERS THEN
           hrrbdeib_trace_on;
           hr_utility.trace('missing baldim type info : baldim: ' || to_char(p_balance_dimension_id) ||
                            ' bal type: ' || to_char(p_balance_type_id));
           hrrbdeib_trace_off;
   END;
   --
   create_user_entity
                     (l_db_item_name,
                      p_business_group_id,
                      p_legislation_code,
                      l_route_id,
                      'N',
                      p_defined_balance_id,
                      'B',
                      'To hold database items for the Balance '
                         || l_db_item_name || ' (automatically generated)',
                      startup_mode,
                      usr_ent_id
                     );
--
   --  add a Route Parameter value which contains the balance type ID
   --  to make the route work (we know sequence is 1)
   if (l_dbi_function = 'N') then
     route_param_value := p_balance_type_id;
   else
     route_param_value := p_defined_balance_id;
   end if;
   insert into ff_route_parameter_values
   (route_parameter_id,
    user_entity_id,
    value)
   select RP.route_parameter_id,
          usr_ent_id,
          to_char(route_param_value)
   from   ff_route_parameters RP
   where  RP.route_id = l_route_id
   and    RP.sequence_no = 1;
   if sql%rowcount <> 1 then
      hr_utility.set_message(801, 'HR_ERROR');
      hrrbdeib_trace_on;
      hr_utility.trace('missing seq 1 route param for route : ' || to_char(l_route_id));
      hrrbdeib_trace_off;
      hr_utility.raise_error;
   end if;
--
   --
   -- Use Rule hint on balances if LOW_VOLUME pay_action_paremeter set
   --
   -- use caching to avoid repeated finding parameter_value
   --
   if (cached = FALSE) then
      cached := TRUE;
      l_ora_db_vers := hr_general2.get_oracle_db_version;
      if (nvl(l_ora_db_vers, 0) < 9.0) then
         g_low_volume := 'Y';
      else
         begin
            select parameter_value
            into g_low_volume
            from pay_action_parameters
            where parameter_name = 'LOW_VOLUME';
         exception
            when others then
                 g_low_volume := 'N';
         end;
      end if;
   end if;

   if (l_dbi_function = 'N') then
      if (g_low_volume = 'Y') then
         l_dbitem_def_text := '/*+'||' RULE*/ nvl(sum(fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale),0) ';
      else
         l_dbitem_def_text := 'nvl(sum(fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale),0) ';
      end if;
--
   elsif (l_dbi_function = 'Y') then
      l_dbitem_def_text := '1';
   else
      l_dbitem_def_text := l_dbi_function;
   end if;

   --  insert a Database Item to hold balance value
   create_dbi
             (
              l_db_item_name,
              usr_ent_id,
              'N',
              l_dbitem_def_text,
              'N',
              'Current value for balance ' || l_db_item_name || ' (automatically generated)',
              startup_mode,
              p_legislation_code,
              p_business_group_id
             );
   --
   if l_full_mls then
     for l in c_language loop
       gen_db_tl_dbi_name
       (p_balance_type_id      => p_balance_type_id
       ,p_balance_dimension_id => p_balance_dimension_id
       ,p_language             => l.language_code
       ,p_tl_name              => l_tl_name
       ,p_found                => l_found
       );
       --
       -- Update the translated database item.
       --
       if l_found then
         update_tl_dbi_name
         (p_user_name      => l_db_item_name
         ,p_user_entity_id => usr_ent_id
         ,p_leg_code       => p_legislation_code
         ,p_bg_id          => p_business_group_id
         ,p_startup_mode   => startup_mode
         ,p_language       => l.language_code
         ,p_tl_user_name   => l_tl_name
         );
       end if;
     end loop;
   end if;
   --
--
   create_alternative_dbis(p_defined_balance_id,
                           p_balance_dimension_id,
                           p_balance_type_id,
                           p_business_group_id,
                           p_legislation_code,
                           l_db_item_name,
                           startup_mode
                          );
--
end new_defined_balance;
--
/*------------------- refresh_defined_balances  ---------------------------*/
/*
 *  This routine creates all database items based on defined balances
 *  in the system. The routine assumes that no such database items currently
 *  exist.
 */
procedure refresh_defined_balances(p_worker_id in number default 0,
                                   p_maxworkers in number default 1) is
   cursor c1 is select defined_balance_id,
                       balance_dimension_id,
                       balance_type_id,
                       business_group_id,
                       legislation_code,
                       save_run_balance
                from   pay_defined_balances b
                where  not exists (
                  select null from ff_user_entities u
                  where  b.defined_balance_id = u.creator_id
                  and    u.creator_type = 'B')
                and    mod(defined_balance_id, p_maxworkers) = p_worker_id
                order by b.defined_balance_id;

   cursor c2 is select defined_balance_id,
                       balance_dimension_id,
                       balance_type_id,
                       business_group_id,
                       legislation_code,
                       save_run_balance
                from   pay_defined_balances b
                where  /* def bal ue simply doesn't exist but has an associated pdr */
                ((
                  not exists (
                  select null from ff_user_entities u
                  where  b.defined_balance_id = u.creator_id
                  and    u.creator_type = 'RB')
                  and exists
                    (select null
                     from pay_dimension_routes pdr
                     where pdr.balance_dimension_id = b.balance_dimension_id)
                )
                OR /* def bal ue does exists but has a missing ue pdr */
                (
                   exists (
                   select pdr.balance_dimension_id
                   from   pay_dimension_routes pdr
                   where  pdr.balance_dimension_id = b.balance_dimension_id
                   and    not exists (select null
                            from   ff_user_entities ue
                            where  ue.creator_id = b.defined_balance_id
                            and    ue.route_id = pdr.route_id
                            and    ue.creator_type = 'RB'))
                ))
                and    mod(defined_balance_id, p_maxworkers) = p_worker_id
                order by b.defined_balance_id;

   l_db_item_name ff_database_items.user_name%type;
   startup_mode varchar2(10);
   l_loop_cnt number;

begin

hrrbdeib_trace_on;
hr_utility.trace('entering refresh_defined_balances all' ||
                 ' worker: ' || to_char(p_worker_id + 1) || '/' ||
                 to_char(p_maxworkers));
hrrbdeib_trace_off;

l_loop_cnt := 0;

-- create missing B and RB data

   for c1rec in c1 loop
      hrrbdeib_trace_on;
      hr_utility.trace('RDB:B :' || to_char(p_worker_id + 1) || ':' ||
                       c1rec.legislation_code || '.' ||
                       to_char(c1rec.business_group_id) || '.' ||
                       to_char(c1rec.defined_balance_id) || '.' ||
                       to_char(c1rec.balance_dimension_id) || '.' ||
                       to_char(c1rec.balance_type_id) || '.' ||
                       c1rec.save_run_balance);
      hrrbdeib_trace_off;

      recreate_defined_balance
           (p_defined_balance_id   => c1rec.defined_balance_id,
            p_balance_dimension_id => c1rec.balance_dimension_id,
            p_balance_type_id      => c1rec.balance_type_id,
            p_business_group_id    => c1rec.business_group_id,
            p_legislation_code     => c1rec.legislation_code);

   l_loop_cnt := l_loop_cnt + 1;
   if l_loop_cnt > 100 then
     l_loop_cnt := 0;
     commit;
   end if;

   end loop;

-- create missing RB data which can happen if we had some or all B entities
-- before running the c1 loop
-- already created but no associated RB row as in this case the c1 cursor would -- not note it needs to create the missing RB row for an already existing B row
-- however, as we only want to recreate the RB row we will create a new proc

   for c2rec in c2 loop

      hrrbdeib_trace_on;
      hr_utility.trace('RDB:RB:' ||  to_char(p_worker_id + 1) || ':' ||
                       c2rec.legislation_code || '.' ||
                       to_char(c2rec.business_group_id) || '.' ||
                       to_char(c2rec.defined_balance_id) || '.' ||
                       to_char(c2rec.balance_dimension_id) || '.' ||
                       to_char(c2rec.balance_type_id) || '.' ||
                       c2rec.save_run_balance);
      hrrbdeib_trace_off;

      BEGIN
        select upper(replace(BALTYPE.balance_name ||
                             BALDIM.database_item_suffix,
                      ' ','_'))
        into   l_db_item_name
        from   pay_balance_dimensions BALDIM,
               pay_balance_types BALTYPE
        where  BALDIM.balance_dimension_id = c2rec.balance_dimension_id
        and    BALTYPE.balance_type_id = c2rec.balance_type_id;
      EXCEPTION WHEN OTHERS THEN
        hrrbdeib_trace_on;
        hr_utility.trace('missing baldim type2 info : baldim: ' ||
                          to_char(c2rec.balance_dimension_id) ||
                          ' bal type: ' || to_char(c2rec.balance_type_id));
        hrrbdeib_trace_off;
      END;

      IF (g_triggers_altered) THEN
        -- Get the startup mode
        startup_mode := ffstup.get_mode (c2rec.business_group_id,
                                         c2rec.legislation_code);
      END IF;

--      delete_compiled_formula_priv(c2rec.defined_balance_id , 'RB', '%',
--                                   c2rec.legislation_code);

      delete ff_user_entities
      where  creator_id = c2rec.defined_balance_id
      and    creator_type = 'RB';

      create_alternative_dbis(c2rec.defined_balance_id,
                           c2rec.balance_dimension_id,
                           c2rec.balance_type_id,
                           c2rec.business_group_id,
                           c2rec.legislation_code,
                           l_db_item_name,
                           startup_mode
                          );

   l_loop_cnt := l_loop_cnt + 1;
   if l_loop_cnt > 100 then
     l_loop_cnt := 0;
     commit;
   end if;

   end loop;

hrrbdeib_trace_on;
hr_utility.trace('leaving refresh_defined_balances all' ||
                 ' worker: ' || to_char(p_worker_id + 1) || '/' ||
                 to_char(p_maxworkers));
hrrbdeib_trace_off;

end refresh_defined_balances;
--
/*------------------- refresh_defined_balances  ---------------------------*/
/*
 *  This routine creates all database items based on defined balances
 *  in the system. The routine assumes that no such database items currently
 *  exist.
 */
procedure refresh_defined_balances(p_leg_code in varchar2,
                                   p_worker_id in number default 0,
                                   p_maxworkers in number default 1) is

   cursor c1 is select defined_balance_id,
                       balance_dimension_id,
                       balance_type_id,
                       business_group_id,
                       legislation_code,
                       save_run_balance
                from   pay_defined_balances a
                where not exists (
                  select null from ff_user_entities u
                  where  a.defined_balance_id = u.creator_id
                  and    u.creator_type = 'B')
                and  mod(defined_balance_id, p_maxworkers) = p_worker_id
                and    (a.legislation_code = p_leg_code
                    or exists (select null
                     from   per_business_groups_perf b
                     where  a.business_group_id = b.business_group_id
                     and    nvl(b.legislation_code, p_leg_code) = p_leg_code))
                order by a.defined_balance_id;

   cursor c2 is select defined_balance_id,
                       balance_dimension_id,
                       balance_type_id,
                       business_group_id,
                       legislation_code,
                       save_run_balance
                from   pay_defined_balances a
                where  /* def bal ue simply doesn't exist but has an associated pdr */
                ((
                  not exists (
                  select null from ff_user_entities u
                  where  a.defined_balance_id = u.creator_id
                  and    u.creator_type = 'RB')
                  and exists
                    (select null
                     from pay_dimension_routes pdr
                     where pdr.balance_dimension_id = a.balance_dimension_id)
                )
                OR /* def bal ue does exists but has a missing ue pdr */
                (
                   exists (
                   select pdr.balance_dimension_id
                   from   pay_dimension_routes pdr
                   where  pdr.balance_dimension_id = a.balance_dimension_id
                   and    not exists (select null
                            from   ff_user_entities ue
                            where  ue.creator_id = a.defined_balance_id
                            and    ue.route_id = pdr.route_id
                            and    ue.creator_type = 'RB'))
                ))
                and  mod(defined_balance_id, p_maxworkers) = p_worker_id
                and    (a.legislation_code = p_leg_code
                    or exists (select null
                     from   per_business_groups_perf b
                     where  a.business_group_id = b.business_group_id
                     and    nvl(b.legislation_code, p_leg_code) = p_leg_code))
                order by a.defined_balance_id;

   l_db_item_name ff_database_items.user_name%type;
   startup_mode varchar2(10);
   l_loop_cnt number;

begin

hrrbdeib_trace_on;
hr_utility.trace('entering refresh_defined_balances ' || p_leg_code ||
                 ' worker: ' || to_char(p_worker_id + 1) || '/' ||
                 to_char(p_maxworkers));
hrrbdeib_trace_off;

l_loop_cnt := 0;

-- create missing B and RB data

   for c1rec in c1 loop

hrrbdeib_trace_on;
      hr_utility.trace('RDB:B :' || to_char(p_worker_id + 1) || ':' ||
                       c1rec.legislation_code || '.' ||
                       to_char(c1rec.business_group_id) || '.' ||
                       to_char(c1rec.defined_balance_id) || '.' ||
                       to_char(c1rec.balance_dimension_id) || '.' ||
                       to_char(c1rec.balance_type_id) || '.' ||
                       c1rec.save_run_balance);
hrrbdeib_trace_off;

      recreate_defined_balance
           (p_defined_balance_id   => c1rec.defined_balance_id,
            p_balance_dimension_id => c1rec.balance_dimension_id,
            p_balance_type_id      => c1rec.balance_type_id,
            p_business_group_id    => c1rec.business_group_id,
            p_legislation_code     => c1rec.legislation_code);

   l_loop_cnt := l_loop_cnt + 1;
   if l_loop_cnt > 100 then
     l_loop_cnt := 0;
     commit;
   end if;

   end loop;

-- create missing RB data which can happen if we had some or all B entities
-- before running the c1 loop
-- already created but no associated RB row as in this case the c1 cursor would -- not note it needs to create the missing RB row for an already existing B row
-- however, as we only want to recreate the RB row we will create a new proc

   for c2rec in c2 loop

      hrrbdeib_trace_on;
      hr_utility.trace('RDB:RB:' || to_char(p_worker_id + 1) || ':' ||
                       c2rec.legislation_code || '.' ||
                       to_char(c2rec.business_group_id) || '.' ||
                       to_char(c2rec.defined_balance_id) || '.' ||
                       to_char(c2rec.balance_dimension_id) || '.' ||
                       to_char(c2rec.balance_type_id) || '.' ||
                       c2rec.save_run_balance);
      hrrbdeib_trace_off;

      BEGIN
        select upper(replace(BALTYPE.balance_name ||
                             BALDIM.database_item_suffix,
                      ' ','_'))
        into l_db_item_name
        from   pay_balance_dimensions BALDIM,
               pay_balance_types BALTYPE
        where  BALDIM.balance_dimension_id = c2rec.balance_dimension_id
        and    BALTYPE.balance_type_id = c2rec.balance_type_id;
      EXCEPTION WHEN OTHERS THEN
        hrrbdeib_trace_on;
        hr_utility.trace('missing baldim type2 info : baldim: ' ||
                          to_char(c2rec.balance_dimension_id) ||
                          ' bal type: ' || to_char(c2rec.balance_type_id));
        hrrbdeib_trace_off;
      END;

      IF (g_triggers_altered) THEN
        -- Get the startup mode
        startup_mode := ffstup.get_mode (c2rec.business_group_id,
                                         c2rec.legislation_code);
      END IF;

--      delete_compiled_formula_priv(c2rec.defined_balance_id , 'RB', '%',
--                                   c2rec.legislation_code);

      delete ff_user_entities
      where  creator_id = c2rec.defined_balance_id
      and    creator_type = 'RB';

      create_alternative_dbis(c2rec.defined_balance_id,
                           c2rec.balance_dimension_id,
                           c2rec.balance_type_id,
                           c2rec.business_group_id,
                           c2rec.legislation_code,
                           l_db_item_name,
                           startup_mode
                          );

   l_loop_cnt := l_loop_cnt + 1;
   if l_loop_cnt > 100 then
     l_loop_cnt := 0;
     commit;
   end if;

   end loop;

hrrbdeib_trace_on;
hr_utility.trace('leaving refresh_defined_balances ' || p_leg_code ||
                 ' worker: ' || to_char(p_worker_id + 1) || '/' ||
                 to_char(p_maxworkers));
hrrbdeib_trace_off;

end refresh_defined_balances;
--
/*------------------- recreate_defined_balance  ---------------------------*/
/*
 *  This routine deletes and creates database items based on a given
 *  defined balance in the system.
 */
procedure recreate_defined_balance(p_defined_balance_id   in number,
                                   p_balance_dimension_id in number,
                                   p_balance_type_id      in number,
                                   p_business_group_id    in number,
                                   p_legislation_code     in varchar2)
is
begin
--
--  delete_compiled_formula_priv(p_defined_balance_id, 'B',  '%', p_legislation_code);
--  delete_compiled_formula_priv(p_defined_balance_id, 'RB', '%', p_legislation_code);

  delete from ff_user_entities
   where creator_id = p_defined_balance_id
     and creator_type = 'B';
  --
  delete from ff_user_entities
   where creator_id = p_defined_balance_id
     and creator_type = 'RB';
  --
  hrdyndbi.new_defined_balance
    (p_defined_balance_id   => p_defined_balance_id,
     p_balance_dimension_id => p_balance_dimension_id,
     p_balance_type_id      => p_balance_type_id,
     p_business_group_id    => p_business_group_id,
     p_legislation_code     => p_legislation_code);
  --
end;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                       insert_parameter_value                           +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME
    insert_parameter_value - insert the entity value into the route parameter
                             table
DESCRIPTION
    This routine is called if the routes contains where clause fillers (Ux).
    Get the route parameter id from the ff_route_parameters table and insert
    the actual entity value into the ff_route_parameter_values table.  For
    example, when an  element type is created, the value inserted into the
    ff_route_parameter_values table is the element type id.
    The parameters passed are:
    p_value        - the actual where clause filler value
    p_sequence_no  - the number of the where clause filler, eg. 1 for U1.
*/
procedure insert_parameter_value
(
    p_value         in varchar2,
    p_sequence_no   in number
) is
l_route_parameter_id  number;
l_route_id            number;
l_user_entity_id      number;
l_created_by          ff_user_entities.created_by%type;
l_last_login          ff_user_entities.last_update_login%type;
l_user_entity_name    ff_user_entities.user_entity_name%type;
l_ent_bg_id           ff_user_entities.BUSINESS_GROUP_ID%type;
l_ent_lc              ff_user_entities.LEGISLATION_CODE%type;
l_route_name          ff_routes.route_name%type;
l_route_cd            varchar2(60);
l_route_lud           varchar2(60);
l_route_lub           number;
BEGIN
    --
    -- get the user entity id to be used:
    --
    select  ff_user_entities_s.currval
    into    l_user_entity_id
    from    dual;
    --
    -- get the relevant information for the user entity we are using
    --
    BEGIN
    select RPARAM.route_parameter_id,
           ENTITY.created_by,
           ENTITY.last_update_login,
           ENTITY.user_entity_name
    into   l_route_parameter_id,
           l_created_by,
           l_last_login,
           l_user_entity_name
    from   ff_user_entities          ENTITY
    ,      ff_route_parameters       RPARAM
    where  ENTITY.user_entity_id   = l_user_entity_id
    and    RPARAM.route_id         = ENTITY.route_id
    and    RPARAM.sequence_no      = p_sequence_no;
    EXCEPTION WHEN OTHERS THEN
     hrrbdeib_trace_on;
     hr_utility.trace(SQLCODE || '-' || SQLERRM);
     hr_utility.trace('insert param val');
     hr_utility.trace(' seqno: ' || to_char(p_sequence_no));
     hr_utility.trace('Checking for user entity ' || to_char(l_user_entity_id)
                        || ' details');
     BEGIN
       select ENTITY.user_entity_name,
              ENTITY.route_id,
              ENTITY.BUSINESS_GROUP_ID,
              ENTITY. LEGISLATION_CODE
       into   l_user_entity_name,
              l_route_id,
              l_ent_bg_id,
              l_ent_lc
       from   ff_user_entities          ENTITY
       where  ENTITY.user_entity_id   = l_user_entity_id;

      hr_utility.trace('entity_name: ' || l_user_entity_name);
      hr_utility.trace('entity route id: ' || to_char(l_route_id));
      hr_utility.trace('entity BG id: ' || to_char(l_ent_bg_id));
      hr_utility.trace('entity LC: ' || l_ent_lc);

       IF l_route_id is not null THEN
         select route_name,
                to_char(CREATION_DATE, 'DD-MM-YYYY'),
                to_char(LAST_UPDATE_DATE, 'DD-MM-YYYY'),
                LAST_UPDATED_BY
         into   l_route_name,
                l_route_cd,
                l_route_lud,
                l_route_lub
         from   ff_routes
         where  route_id = l_route_id;

        hr_utility.trace('route_name: ' || l_route_name);
        hr_utility.trace('route creation date: ' || l_route_cd);
        hr_utility.trace('route LUD: ' || l_route_lud);
        hr_utility.trace('route LUB: ' || to_char(l_route_lub));
        hrrbdeib_trace_off;

       END IF;
      EXCEPTION WHEN OTHERS THEN NULL;
     END;

      raise;

    END;
    --
    -- populate the route parameter value table with the entity value
    --
    insert into ff_route_parameter_values (
            user_entity_id,
            route_parameter_id,
            value,
            last_update_date,
            last_updated_by,
            last_update_login,
            created_by,
            creation_date)
    --
    values (l_user_entity_id,
            l_route_parameter_id,
            p_value,
            sysdate,
            l_created_by,
            l_last_login,
            l_created_by,
            sysdate);
    --
END insert_parameter_value;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                        insert_database_item                            +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME
      insert_database_item - load the database item.
--
DESCRIPTION
      Internal interface for insert_database_item.

      This is the external insert_database_item but with extra parameters
      extra parameters so that only a single base database item is
      created.

      If P_FULL_MLS is true then this call just creates a single base
      database item whose name is returned in P_BASE_DBI_NAME. If
      P_FULL_MLS is false then this call performs the old pseudo-MLS
      generation of multiple database items in FF_DATABASE_ITEMS, and
      P_BASE_DBI_NAME is ignored.
*/
procedure insert_database_item
(
    p_entity_name          in  varchar2,
    p_item_name            in  varchar2,
    p_data_type            in  varchar2,
    p_definition_text      in  varchar2,
    p_null_allowed_flag    in  varchar2,
    p_description          in  varchar2,
    p_user_entity_id       in  number,
    p_full_mls             in  boolean,
    p_base_dbi_name        out nocopy varchar2
) is
l_item_name           ff_database_items.user_name%type;
l_user_name           ff_database_items.user_name%type;
l_user_entity_id      number;
l_created_by          ff_user_entities.created_by%type;
l_last_login          ff_user_entities.last_update_login%type;
l_db                  number;
l_exists              VARCHAR2(2);
l_clash               boolean;
--
startup_mode varchar2(10);
rgeflg       varchar2(1);
bg_id        number;
leg_code     varchar2(30);
--
cursor c_language is
  select language_code
  from   fnd_languages
  where  installed_flag in ('I','B');
--
cursor c_dbi_exists(c_user_name IN VARCHAR2,
  c_user_entity_id IN VARCHAR2) IS
  SELECT  'Y'
  FROM    ff_database_items
  WHERE   user_name = c_user_name
  AND     user_entity_id = c_user_entity_id;
--
BEGIN
--
  --
  -- get the user entity id to be used:
  --
  if (p_user_entity_id is not NULL) then
    l_user_entity_id:=p_user_entity_id;
  else
    select  ff_user_entities_s.currval
    into    l_user_entity_id
    from    dual;
  end if;

  --
  -- get the relevant information for the user entity we are using
  --
  select created_by,
         last_update_login,
         business_group_id,
         legislation_code
  into   l_created_by,
         l_last_login,
         bg_id,
         leg_code
  from   ff_user_entities
  where  user_entity_id    = l_user_entity_id;
  --
  IF (g_triggers_altered) THEN
    -- Get the startup mode
    startup_mode := ffstup.get_mode (bg_id, leg_code);
  ELSE
    -- get the security group id which won't have been populated yet.
    g_security_group_id := fnd_global.lookup_security_group('NAME_TRANSLATIONS', 3);
  END IF;

  if not p_full_mls then
    --
    -- This is the pseudo-MLS process where the base table values are
    -- appended with lookup meanings for all languages.
    --
    for c_lang_rec in c_language loop
      --
      -- This used to be a cursor for-loop.
      --
      l_item_name := p_item_name;
      replace_code_name
      (p_language_code => c_lang_rec.language_code
      ,p_item_name     => l_item_name
      );

      --
      -- If the Database item name is greater than 80, then we have no choice
      -- but to truncate the trailing characters. This may lead to the insert
      -- failing due to duplicate DB item names.
      -- Note the use of substrb.
      --
      -- For utf8 support we now substr 80 so :
      --    (a). for singlebyte environments get same sa previous versions of
      --         this package and thus data integrity.
      --    (b). for multibyte environments get 80 multibyte characters ... using
      --         upto 240 bytes.


      l_user_name := substr ((p_entity_name || '_' || l_item_name), 1, 80);

      --
      -- str2dbiname does all the checks performed here before including
      -- checkformat and, if necessary, quoting (see bug 3723715).
      --
      l_user_name := ff_dbi_utils_pkg.str2dbiname(p_str => l_user_name);

      --
      -- load the database name into the database item table
      -- As this is now done for each installed language, we should
      -- check that the user_name, user_entitiy_id doesn't already
      -- exist.
      --
      OPEN c_dbi_exists(l_user_name, l_user_entity_id);
      FETCH c_dbi_exists INTO l_exists;
      IF c_dbi_exists%NOTFOUND then
        BEGIN
          --
          -- Make sure that the name does not clash with FF_DATABASE_ITEMS,
          -- FF_DATABASE_ITEMS_TL, or FF_CONTEXT rows.
          --
          check_for_dbi_clash
          (p_user_name      => l_user_name
          ,p_ue_id          => l_user_entity_id
          ,p_leg_code       => leg_code
          ,p_bg_id          => bg_id
          ,p_startup_mode   => startup_mode
          ,p_clash          => l_clash
          );
          if not l_clash then
            insert into ff_database_items
            (user_name
            ,user_entity_id
            ,data_type
            ,definition_text
            ,null_allowed_flag
            ,description
            ,last_update_date
            ,last_updated_by
            ,last_update_login
            ,created_by
            ,creation_date
            )
            values
            (l_user_name
            ,l_user_entity_id
            ,p_data_type
            ,p_definition_text
            ,p_null_allowed_flag
            ,p_description
            ,sysdate
            ,l_created_by
            ,l_last_login
            ,l_created_by
            ,sysdate
            );
          else
            --
            -- For the pseudo-MLS process it is possible to get name
            -- clashes because translation patches may not have been
            -- applied.
            --
            null;
          end if;
        EXCEPTION
          WHEN OTHERS THEN
            hrrbdeib_trace_on;
            IF (g_triggers_altered) THEN
              hr_utility.trace('ins dbi: g_trigger TRUE');
            ELSE
              hr_utility.trace('ins dbi: g_trigger FALSE');
            END IF;
            hr_utility.trace('ins dbi: dbi: ' || l_user_name);
            hr_utility.trace('ins dbi: ue: ' || p_entity_name);
            hr_utility.trace('ins dbi: item: ' || l_item_name);
            hr_utility.trace('ins dbi: ueid: ' || to_char(l_user_entity_id));
            hr_utility.trace('ins dbi: lang: ' || c_lang_rec.language_code);
            hrrbdeib_trace_off;

            if c_dbi_exists%isopen then
              close c_dbi_exists;
            end if;
            raise;
        END;
      END IF;
      CLOSE c_dbi_exists;
      --
      -- Repeat the process for the next language
      --
    end loop;
  --
  -- For the full MLS process, this code only generates a single base
  -- table database item based upon the supplied item name.
  --
  else
    --
    -- The translations will be done in other code to be reused elsewhere.
    --
    l_user_name := substr ((p_entity_name || '_' || p_item_name), 1, 80);

    --
    -- str2dbiname does all the checks performed here before including
    -- checkformat and, if necessary, quoting (see bug 3723715).
    --
    l_user_name := ff_dbi_utils_pkg.str2dbiname(p_str => l_user_name);

    OPEN c_dbi_exists(l_user_name, l_user_entity_id);
    FETCH c_dbi_exists INTO l_exists;
    IF c_dbi_exists%NOTFOUND then
      BEGIN
        --
        -- Make sure that the name does not clash with FF_DATABASE_ITEMS,
        -- FF_DATABASE_ITEMS_TL, or FF_CONTEXT rows.
        --
        check_for_dbi_clash
        (p_user_name      => l_user_name
        ,p_ue_id          => l_user_entity_id
        ,p_leg_code       => leg_code
        ,p_bg_id          => bg_id
        ,p_startup_mode   => startup_mode
        ,p_clash          => l_clash
        );
        if not l_clash then
          insert into ff_database_items
          (user_name
          ,user_entity_id
          ,data_type
          ,definition_text
          ,null_allowed_flag
          ,description
          ,last_update_date
          ,last_updated_by
          ,last_update_login
          ,created_by
          ,creation_date
          )
          values
          (l_user_name
          ,l_user_entity_id
          ,p_data_type
          ,p_definition_text
          ,p_null_allowed_flag
          ,p_description
          ,sysdate
          ,l_created_by
          ,l_last_login
          ,l_created_by
          ,sysdate
          );
        else
          --
          -- For the full MLS process, a name clash is a fatal error.
          --
          hr_utility.set_message (801, 'PAY_33916_DYN_DBI_NAME_CLASH');
          hr_utility.set_message_token('1', l_user_name);
          hr_utility.raise_error;
        end if;
      EXCEPTION
        WHEN OTHERS THEN
          hrrbdeib_trace_on;
          IF (g_triggers_altered) THEN
            hr_utility.trace('ins dbi: g_trigger TRUE');
          ELSE
            hr_utility.trace('ins dbi: g_trigger FALSE');
          END IF;
          hr_utility.trace('ins dbi: dbi: ' || l_user_name);
          hr_utility.trace('ins dbi: ue: ' || p_entity_name);
          hr_utility.trace('ins dbi: item: ' || l_item_name);
          hr_utility.trace('ins dbi: ueid: ' || to_char(l_user_entity_id));
          hr_utility.trace('ins dbi: base name' );
          hrrbdeib_trace_off;

          if c_dbi_exists%isopen then
            close c_dbi_exists;
          end if;
          raise;
      END;
    END IF;
    CLOSE c_dbi_exists;

    p_base_dbi_name := l_user_name;
  end if;
END insert_database_item;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                        insert_database_item                            +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME
      insert_database_item - load the database item.
--
DESCRIPTION
      Insert a new row into the database_items table.  The actual database
      name is a concatenation of the supplied entity name and the database
      name as:
      --
                <ENTITY_NAME>_<ITEM_NAME>
      --
      The <ITEM_NAME> parameter is checked to see if its name translation is
      to be used.  This is now done for each installed language (the c_language
      cursor loop), to maintain the current Japanese functionality of using
      the name translations lookup to translation JP-specific elements into
      Japanese.  This functionality leads to pseudo-translated multilingual
      DEH DBIs, and currently does nothing with the translation table.  For
      this multilanguage translation to
      work, we can not access the data through the single language views,
      either HR_LOOKUPS or FND_LOOKUPS, but instead have to access the base table
      directly, filtering by the required language.

      The parameters passed are:
      p_entity_name         - The first half of the database name
      p_item_name           - The second half of the database name
      p_data_type           - Data type T = text, N = number, D = date.
      p_definition_text     - The text after the 'select' statment and before
                              the 'from' that is used to retrieve the data.
      p_null_allowed_flag   - Y or N, can the database item be null.
      p_description         - The description of the database item
*/
procedure insert_database_item
(
    p_entity_name          in  varchar2,
    p_item_name            in  varchar2,
    p_data_type            in  varchar2,
    p_definition_text      in  varchar2,
    p_null_allowed_flag    in  varchar2,
    p_description          in  varchar2,
    p_user_entity_id       in  number
) is
l_base_dbi_name varchar2(2000);
begin
  --
  -- This call must generate the old-style pseudo-MLS database items
  -- so P_FULL_MLS is FALSE.
  --
  insert_database_item
  (
    p_entity_name        => p_entity_name,
    p_item_name          => p_item_name,
    p_data_type          => p_data_type,
    p_definition_text    => p_definition_text,
    p_null_allowed_flag  => p_null_allowed_flag,
    p_description        => p_description,
    p_user_entity_id     => p_user_entity_id,
    p_full_mls           => false,
    p_base_dbi_name      => l_base_dbi_name
  );
end insert_database_item;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                          insert_user_entity                            +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      insert_user_entity - load the element type information into user
                           entity and route parameter value tables
--
   DESCRIPTION
      This is the first general purpose routine that should be called by the
      main procedures (xxx_dict).  It defines an entity, that the other
      procedures ('insert_parameter_value' and 'insert_database_item')
      reference.
      NB insert_user_entity_main is overloaded by 2 insert_user_entity
      procedures: one that is passed the out parameter p_record_inserted
      and one that uses its own local p_record_inserted paramter (whose
      values is subsequently ignored).
      The parameters passed are:
      p_route_name        - the route name to be used, this must already be
                            seeded in the table ff_routes.
      p_user_entity_name  - The name of the user entity.
      p_entity_description- The description of the entity.
      p_not_found_flag    - Y/ N, Y= the database item may not be found in
                            some cases, N= it will ALWAYS return a value.
      p_creator_type      - Indicates which type of DB items are to be
                            created, eg. E = element type.
      p_creator_id        - Further defines who created the DB items, for
                            example, element type id.
      p_business_group_id - If this is null, the item may be seen by all
                            business groups.
      p_legislation_code  - The legisaltion code, null = generic.
      p_created_by        - Used in the AOL columns of the database.
      p_last_login        - Used in the AOL columns of the database.
      p_record_inserted   - Boolean indicating whether insertion happened
*/
--
--  insert_user_entity called with p_record_inserted
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
) is
l_user_entity_name    ff_user_entities.user_entity_name%type;
BEGIN
   --
   -- simply call insert_user_entity_main
   --
   -- mkandasa substr'd user entity name to 80. Bug fix 2073022.
   l_user_entity_name := substr(p_user_entity_name,1,80);

   insert_user_entity_main( p_route_name,
                            l_user_entity_name,
                            p_entity_description,
                            p_not_found_flag,
                            p_creator_type,
                            p_creator_id,
                            p_business_group_id,
                            p_legislation_code,
                            p_created_by,
                            p_last_login,
                            p_record_inserted);
END insert_user_entity;
--
--  insert_user_entity called without p_record_inserted
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
) is
l_record_inserted      boolean;
BEGIN
   --
   -- call insert_user_entity_main with l_record_inserted
   --
   insert_user_entity_main( p_route_name,
                            p_user_entity_name,
                            p_entity_description,
                            p_not_found_flag,
                            p_creator_type,
                            p_creator_id,
                            p_business_group_id,
                            p_legislation_code,
                            p_created_by,
                            p_last_login,
                            l_record_inserted);
END insert_user_entity;
--
-- main insert user entity procedure
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
) is
l_route_id            number;
l_user_entities_seq   number;
l_dummy_fetch_var     number;
l_user_entity_name    ff_database_items.user_name%type;
startup_mode varchar2(10);
rgeflg varchar2(1);
l_message varchar2(255);

BEGIN
    --
    -- get the user entity id from its sequence
    --
    begin
        SELECT ff_user_entities_s.nextval
        INTO   l_user_entities_seq
        FROM   dual;
    end;
--
   l_user_entity_name := p_user_entity_name;
--
   --
   -- Check if name legal format eg no spaces, or special characters
   -- If not add quotes : Bug 3723715
   --
   begin
     hr_chkfmt.checkformat (l_user_entity_name, 'DB_ITEM_NAME', l_user_entity_name,
                              null,null,'Y',rgeflg,null);
   exception
     when hr_utility.hr_error then
       -- FFHR_6016_ALL_RES_WORDS error condition
       -- so add quotes
       --Bug 5930272
       fnd_message.retrieve(l_message);
       l_user_entity_name := '"' || substr(l_user_entity_name, 1, 78) || '"';
   end;
--
-- If we are running this via rebuild_ele_input_bal
   IF (g_triggers_altered) THEN
   -- Get the startup mode
     startup_mode := ffstup.get_mode (p_business_group_id,
                                      p_legislation_code);
   --
   -- Check the name is OK
   --
   -- validate the name is OK. This was originally called as part of
   -- the FF_USER_ENTITIES_BRI trigger so we add it here.

     begin
       -- Check if name legal format eg no spaces, or special characters
       hr_chkfmt.checkformat (l_user_entity_name, 'DB_ITEM_NAME', l_user_entity_name,
                              null,null,'Y',rgeflg,null);
     exception
       when hr_utility.hr_error then
         hr_utility.set_message (802, 'FFHR_6016_ALL_RES_WORDS');
         hr_utility.set_message_token(802,'VALUE_NAME','FF94_USER_ENTITY');
         hrrbdeib_trace_on;
         hr_utility.trace('chkfmt DB_ITEM_NAME');
         hr_utility.trace('ue: ' || l_user_entity_name);
         hr_utility.trace('route_name: ' || p_route_name);
         hr_utility.trace('creator_id: ' || to_char(p_creator_id));
         hr_utility.trace('creator_type: ' || p_creator_type);
         hr_utility.trace('rgeflg: ' || rgeflg);
         hrrbdeib_trace_off;
         raise;
     end;
   END IF; -- g_triggers_altered
--
-- Check if entity already exists before inserting it

    select count(*)
    into   l_dummy_fetch_var
    from   ff_user_entities
    where  user_entity_name = l_user_entity_name
    and    nvl (legislation_code, ' ') = nvl (p_legislation_code, ' ')
    and    nvl (business_group_id, -1) = nvl (p_business_group_id, -1);

    IF l_dummy_fetch_var = 0
    THEN
    --
    -- get the route id
    --
    BEGIN

    SELECT route_id
    INTO   l_route_id
    FROM   ff_routes
    WHERE  route_name         = p_route_name;

    EXCEPTION WHEN OTHERS THEN
         hrrbdeib_trace_on;
         hr_utility.trace('insert_user_entity_main : missing route : ' ||
                           p_route_name);
         hrrbdeib_trace_off;
         raise;
    END;
    --
    -- populate the ff_user_entities table :
    --
    BEGIN

    IF (g_triggers_altered) THEN
      insert into ff_user_entities (
              user_entity_id,
              business_group_id,
              legislation_code,
              route_id,
              notfound_allowed_flag,
              user_entity_name,
              creator_id,
              creator_type,
              entity_description,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      select  l_user_entities_seq,
              p_business_group_id,
              p_legislation_code,
              l_route_id,
              p_not_found_flag,
              l_user_entity_name,
              p_creator_id,
              p_creator_type,
              p_entity_description,
              sysdate,
              p_created_by,
              p_last_login,
              p_created_by,
              sysdate
      from dual
      where not exists (
       select null
       from ff_user_entities a
       where a.user_entity_name = l_user_entity_name
       and
       ( startup_mode = 'MASTER'
         or
         ( startup_mode = 'SEED'
           and
           ( a.legislation_code = p_legislation_code
            or
           (a.legislation_code is null and a.business_group_id is null)
            or
            p_legislation_code =
            (
              select b.legislation_code
              from   per_business_groups_perf b
              where  b.business_group_id = a.business_group_id
            )
          )
        )
        or
        ( startup_mode = 'NON-SEED'
          and
          ( a.business_group_id = p_business_group_id
            or
            (a.legislation_code is null and a.business_group_id is null)
            or
            (a.business_group_id is null and a.legislation_code = p_legislation_code)
          )
        )
        ));
      ELSE
        insert into ff_user_entities (
                user_entity_id,
                business_group_id,
                legislation_code,
                route_id,
                notfound_allowed_flag,
                user_entity_name,
                creator_id,
                creator_type,
                entity_description,
                last_update_date,
                last_updated_by,
                last_update_login,
                created_by,
                creation_date)
        values (l_user_entities_seq,
                p_business_group_id,
                p_legislation_code,
                l_route_id,
                p_not_found_flag,
                l_user_entity_name,
                p_creator_id,
                p_creator_type,
                p_entity_description,
                sysdate,
                p_created_by,
                p_last_login,
                p_created_by,
                sysdate);
      END IF;
        p_record_inserted := TRUE;
   EXCEPTION WHEN OTHERS THEN
    hrrbdeib_trace_on;
    hr_utility.trace('insert ff_user_entities: ue: ' || l_user_entity_name);
    hr_utility.trace('insert ff_user_entities: route_name: ' || p_route_name);
    hrrbdeib_trace_off;
    raise;
   END;

    ELSE
        p_record_inserted := FALSE;
    END IF;
END insert_user_entity_main;
--
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                   delete_compiled_formula                              +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME
      delete_compiled_formula  - Delete any compiled formula references
                                 based on a user entity.
--    this version is for when we can't guarantee that the creator id passed
--    in is not null and as such will use a less efficient index. It also
--    ensures that we don't destabailise outside APIs calling into this proc
--    with a potentially null creator_id
--    For internal calls from this package where we know the creator id is
--    not null we will call into a _priv version of this routine.

DESCRIPTION
      This routine is called before certain database items are deleted to
      remove all compiled references to them (eg. Descriptive flexs).  Since
      the user creates Descriptive flex database items from a concurrent
      program which could be run several times, it is necessary to delete them
      before the re-creation.
*/
procedure delete_compiled_formula
(
    p_creator_id            in number,
    p_creator_type          in varchar2,
    p_user_entity_name      in varchar2,
    p_leg_code              in varchar2
) is
--
cursor get_formula_ids
is
select /* INDEX(fdi FF_FDI_USAGES_F_N50)*/
       distinct fdi.formula_id,
       fdi.effective_start_date
from
      ff_user_entities ent,
      ff_database_items dbi,
      ff_fdi_usages_f   fdi
where fdi.item_name  = dbi.user_name
and   fdi.usage = 'D'
and   ent.user_entity_id = dbi.user_entity_id
and   ent.creator_type = p_creator_type
and   ent.user_entity_name like p_user_entity_name
and     (nvl (ent.legislation_code, ' ') = nvl (p_leg_code, ' ')
   or exists (select null from per_business_groups_perf b
              where  ent.business_group_id = b.business_group_id
              and nvl(b.legislation_code, p_leg_code) = p_leg_code))
and   nvl(ent.creator_id, -1) = nvl(nvl(p_creator_id, ent.creator_id), -1);
--
num   number;
begin

for form in get_formula_ids loop

   select count(*)
   into   num
   from ff_formulas_f f
   where form.formula_id = f.formula_id
   and   form.effective_start_date = f.effective_start_date
   and     (nvl (f.legislation_code, ' ') = nvl (p_leg_code, nvl (f.legislation_code, ' '))
      or exists (select null from per_business_groups_perf b
                 where  f.business_group_id = b.business_group_id
                 and nvl(b.legislation_code, p_leg_code) = p_leg_code));

   if num > 0 then

      delete from ff_fdi_usages_f fdi
      where fdi.formula_id = form.formula_id
      and   form.effective_start_date = fdi.effective_start_date;

      delete from ff_compiled_info_f fci
      where fci.formula_id = form.formula_id
      and   form.effective_start_date = fci.effective_start_date;

   end if;

end loop;

END delete_compiled_formula;
--
-- Private version
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                   delete_compiled_formula_priv                         +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME
      delete_compiled_formula_priv  - Delete any compiled formula references
                                      based on a user entity. Performant version
--
DESCRIPTION
      This routine is called before certain database items are deleted to
      remove all compiled references to them (eg. Descriptive flexs).  Since
      the user creates Descriptive flex database items from a concurrent
      program which could be run several times, it is necessary to delete them
      before the re-creation.
      Private version for performance. See note on del_comp_form for more info
*/
procedure delete_compiled_formula_priv
(
    p_creator_id            in number,
    p_creator_type          in varchar2,
    p_user_entity_name      in varchar2,
    p_leg_code              in varchar2
) is
--
l_formula_ids dbms_sql.number_table;
l_start_dates dbms_sql.date_table;
begin

delete ff_fdi_usages_f fdi
where  FDI.usage = 'D'
and exists (select null
            from ff_formulas_f f
            where fdi.formula_id = f.formula_id
            and     (nvl (f.legislation_code, ' ') = nvl (p_leg_code, nvl (f.legislation_code, ' '))
                             or exists (select null from per_business_groups_perf b
                                        where  f.business_group_id = b.business_group_id
                                        and nvl(b.legislation_code, p_leg_code) = p_leg_code)))
and exists (select null from
              ff_database_items dbi
              where fdi.item_name  = dbi.user_name
              and exists (select /*+ INDEX(ent FF_USER_ENTITIES_N51)*/ null from
                          ff_user_entities ent
                          where   ent.user_entity_id = dbi.user_entity_id
                          and     ent.creator_id = p_creator_id
                          and     ent.creator_type = p_creator_type
                          and     ent.user_entity_name like p_user_entity_name
                          and     (nvl (ent.legislation_code, ' ') = nvl (p_leg_code, ' ')
                             or exists (select null from per_business_groups_perf b
                                        where  ent.business_group_id = b.business_group_id
                                        and nvl(b.legislation_code, p_leg_code) = p_leg_code))
                          ))
returning fdi.formula_id, fdi.effective_start_date
bulk collect into l_formula_ids, l_start_dates
;

ff_compiled_info_del
(p_formula_ids => l_formula_ids
,p_start_dates => l_start_dates
);

END delete_compiled_formula_priv;
--
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                   ff_compiled_info_del                                 +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
  NAME
    ff_compiled_info_del

  DESCRIPTION
    Bulk delete FF_COMPILED_INFO_F using FORMULA_ID and
    EFFECTIVE_START_DATE from FF_FDI_USAGES_F.
*/
procedure ff_compiled_info_del
(p_formula_ids dbms_sql.number_table
,p_start_dates dbms_sql.date_table
) is
l_iterations  number;
l_chunksize   binary_integer := 250;
l_upper_limit binary_integer;
l_lower_limit binary_integer;
begin
  --
  -- Code will delete l_chunksize rows at most per iteration.
  --
  l_iterations := trunc(p_formula_ids.count / l_chunksize);
  if l_iterations * l_chunksize < p_formula_ids.count then
    l_iterations := 1 + l_iterations;
  end if;

  l_lower_limit := 1;
  l_upper_limit := l_chunksize;
  for i in 1 .. l_iterations loop

    if l_upper_limit > p_formula_ids.count then
      l_upper_limit := p_formula_ids.count;
    end if;

    forall j in l_lower_limit .. l_upper_limit
      delete
      from   ff_compiled_info_f
      where  formula_id = p_formula_ids(j)
      and    effective_start_date = p_start_dates(j)
      ;

    l_lower_limit := l_upper_limit + 1;
    l_upper_limit := l_upper_limit + l_chunksize;
  end loop;
end ff_compiled_info_del;
--
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                   delete_element_type_dict                             +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME
      delete_element_type_dict - delete an element type from the data
                                 dictionary
--
DESCRIPTION
*/
procedure delete_element_type_dict
(
    p_element_type_id       in number
) is
--
BEGIN

--    delete_compiled_formula_priv(p_element_type_id, 'E', '%', null);

    DELETE FROM ff_user_entities
    WHERE  creator_id    = p_element_type_id
    AND    creator_type  = 'E';
END delete_element_type_dict;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                     create_element_type                                +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      create_element_type      - create an element type in the data
                                 dictionary, with a context of either date
                                 earned or date paid.
--
   DESCRIPTION
      This procedure creates element type database items for a given element
      type id, with a context of either date earned or date paid.  Date paid
      database items have '_DP' appended to the database name. To create date
      earned DB items, set the paramater 'p_date_p' to null.  To create date
      paid DB items, set it to '_DP'.
      The routes must have already been defined in the
      database (in table ff_routes).  The procedure will search for the
      routes in this table by using the route name, which is hard coded below.
      The procedure processes each route in turn, creating a user entity and
      route parameter values, and then inserting each database items for that
      particular route.
      The database items created use the element type name. This routine
      generates the following database items:
      --
      <NAME>_REPORTING_NAME
      <NAME>_PRIMARY_CLASSIFICATION
      <NAME>_INPUT_CURRENCY_CODE
      <NAME>_OUTPUT_CURRENCY_CODE
      <NAME>_PROCESSING_PRIORITY
      <NAME>_CLOSED_FOR_ENTRY
      <NAME>_CLOSED_FOR_ENTRY_CODE
      <NAME>_END_DATE
      <NAME>_QUALIFYING_LENGTH_OF_SERVICE
      <NAME>_QUALIFYING_UNITS
      <NAME>_QUALIFYING_UNITS_CODE
      <NAME>_QUALIFYING_AGE
      <NAME>_STANDARD_LINK
      <NAME>_STANDARD_LINK_CODE
      <NAME>_COSTABLE_TYPE
      <NAME>_COSTABLE_TYPE_CODE
      <NAME>_COUNT
*/
procedure create_element_type
(
    p_element_type_id       in number,
    p_effective_date        in date,
    p_date_p                in varchar2
) is
cursor get_title is
   select title from fnd_descriptive_flexs_vl
   where descriptive_flexfield_name = 'Element Developer DF'
   and   application_id             = 801;
--
cursor c_language is
  select language_code
  from   fnd_languages
  where  installed_flag in ('I','B');
--
l_title               varchar2(80);
l_route1_name varchar2(50):= 'ELEMENT_TYPE_AT_TYPE_LEVEL' || p_date_p;
l_route2_name varchar2(50):= 'ELEMENT_TYPE_AT_ASSIGNMENT_LEVEL' || p_date_p;
l_route3_name varchar2(50):= 'ELEMENT_TYPE_COUNT_OF_ELEMENT_ENTRIES'||p_date_p;
l_created_by          number;
l_last_login          number;
l_dbitem_found        boolean;
l_record_inserted     boolean;

l_benefit_class_id    number;
l_class_name          pay_element_classifications.classification_name%type;
l_business_group_id   number;
l_element_name        pay_element_types_f.element_name%type;
l_legislation_code    pay_element_types_f.legislation_code%type;
l_leg_code_class      pay_element_types_f.legislation_code%type;
l_full_mls            boolean;
l_base_dbi_name       varchar2(2000);
l_user_entity_id      number;
l_dbi_prefixes        t_dbi_prefixes;
l_languages           dbms_sql.varchar2s;
l_startup_mode        varchar2(100);
l_legislation_code1   pay_element_types_f.legislation_code%type;
--
------------------------- create_element_type -------------------------
--
BEGIN
    --
    -- get the element type information
    --
    begin
        select replace (ltrim (rtrim (upper (ETYPE.element_name))), ' ', '_'),
               ETYPE.business_group_id,
               ltrim(rtrim(ETYPE.legislation_code)),
               ETYPE.benefit_classification_id,
               upper (CLASS.classification_name),
               ETYPE.created_by,
               ETYPE.last_update_login
        into   l_element_name,
               l_business_group_id,
               l_legislation_code,
               l_benefit_class_id,
               l_class_name,
               l_created_by,
               l_last_login
        from   pay_element_types_f             ETYPE
        ,      pay_element_classifications     CLASS
        where  ETYPE.element_type_id         = p_element_type_id
        and    p_effective_date        between ETYPE.effective_start_date
                                           and ETYPE.effective_end_date
        and    CLASS.classification_id       = ETYPE.classification_id;
    end;
    --
    if (g_triggers_altered) then
      -- Get the startup mode
      l_startup_mode :=
      ffstup.get_mode (l_business_group_id, l_legislation_code);
    else
      -- Get the security group id which won't have been populated yet.
      g_security_group_id :=
      fnd_global.lookup_security_group('NAME_TRANSLATIONS', 3);
    end if;
    --
    -- Are the database items to be fully translated ?
    --
    l_legislation_code1 := l_legislation_code;
    if l_legislation_code1 is null and l_business_group_id is not null then
      select bg.legislation_code
      into   l_legislation_code1
      from   per_business_groups_perf bg
      where  bg.business_group_id = l_business_group_id
      ;
    end if;
    l_full_mls := ff_dbi_utils_pkg.translations_supported(l_legislation_code1);

    --
    -- Set up the data for the full MLS case.
    --
    if l_full_mls then
      open c_language;
      fetch c_language bulk collect
      into l_languages;
      close c_language;

      gen_et_dbi_prefixes
      (p_element_type_id => p_element_type_id
      ,p_languages       => l_languages
      ,p_prefixes        => l_dbi_prefixes
      );
    end if;
    --
    -- create the user entity for the first route
    --
    insert_user_entity (l_route1_name,
                        l_element_name || '_E1' || p_date_p,
                        'entity for '|| l_route1_name,
                        'Y',                         -- not found allowed flag
                        'E',
                        p_element_type_id,
                        l_business_group_id,
                        l_legislation_code,
                        l_created_by,
                        l_last_login,
                        l_record_inserted);
    --
    -- only insert parameter values/database items if an entity was inserted
    --
    IF l_record_inserted THEN
        --
        -- Fetch the user_entity_id.
        --
        select  ff_user_entities_s.currval
        into    l_user_entity_id
        from    dual;
        --
        -- insert the element type id for the where clause filler
        --
        insert_parameter_value (p_element_type_id, 1);
        --
        -- load up the database items for the first route:
        --
        insert_database_item (l_element_name,
                              'REPORTING_NAME' || p_date_p,
                              'T',                           -- data type
                              'ETYPE.reporting_name',
                              'Y',                           -- null allowed
                              'reporting name for element type',
                              l_user_entity_id,
                              l_full_mls,
                              l_base_dbi_name);
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'REPORTING_NAME'
          ,p_date_p         => p_date_p
          );
        end if;
        --
        insert_database_item (l_element_name,
                              'CLASSIFICATION' || p_date_p,
                              'T',                           -- data type
                              'ECLASS.classification_name',
                              'N',                           -- null allowed
                              'primary classification name for element type',
                              l_user_entity_id,
                              l_full_mls,
                              l_base_dbi_name);
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'CLASSIFICATION'
          ,p_date_p         => p_date_p
          );
        end if;
        --
        insert_database_item (l_element_name,
                              'INPUT_CURRENCY_CODE' || p_date_p,
                              'T',                           -- data type
                              'ETYPE.input_currency_code',
                              'Y',                           -- null allowed
                              'input currency code for element type',
                              l_user_entity_id,
                              l_full_mls,
                              l_base_dbi_name);
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'INPUT_CURRENCY_CODE'
          ,p_date_p         => p_date_p
          );
        end if;
        --
        insert_database_item (l_element_name,
                              'OUTPUT_CURRENCY_CODE' || p_date_p,
                              'T',                           -- data type
                              'ETYPE.output_currency_code',
                              'Y',                           -- null allowed
                              'output currency code for element type',
                              l_user_entity_id,
                              l_full_mls,
                              l_base_dbi_name);
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'OUTPUT_CURRENCY_CODE'
          ,p_date_p         => p_date_p
          );
        end if;
        --
        insert_database_item (l_element_name,
                              'PROCESSING_PRIORITY' || p_date_p,
                              'N',                           -- data type
                              'ETYPE.processing_priority',
                              'N',                           -- null allowed
                              'processing priority for element type',
                              l_user_entity_id,
                              l_full_mls,
                              l_base_dbi_name);
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'PROCESSING_PRIORITY'
          ,p_date_p         => p_date_p
          );
        end if;
        --
        insert_database_item (l_element_name,
                              'CLOSED_FOR_ENTRY' || p_date_p,
                              'T',                           -- data type
                              'CELOOK.meaning',
                              'N',                           -- null allowed
           'closed for entry flag meaning from the lookup table for element type',
                              l_user_entity_id,
                              l_full_mls,
                              l_base_dbi_name);
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'CLOSED_FOR_ENTRY'
          ,p_date_p         => p_date_p
          );
        end if;
        --
        insert_database_item (l_element_name,
                              'CLOSED_FOR_ENTRY_CODE' || p_date_p,
                              'T',                           -- data type
                              'ETYPE.closed_for_entry_flag',
                              'N',                           -- null allowed
                              'closed for entry flag - Y or N,  for element type',
                              l_user_entity_id,
                              l_full_mls,
                              l_base_dbi_name);
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'CLOSED_FOR_ENTRY_CODE'
          ,p_date_p         => p_date_p
          );
        end if;
        --
        insert_database_item (l_element_name,
                              'END_DATE' || p_date_p,
                              'D',                           -- data type
                              'ETYPE.effective_end_date',
                              'N',                           -- null allowed
                              'effective end date for element type',
                              l_user_entity_id,
                              l_full_mls,
                              l_base_dbi_name);
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'END_DATE'
          ,p_date_p         => p_date_p
          );
        end if;
        --
        -- see if there is a benefit classification for this element, and if
        -- so generate a DB item for it.
        --
        if (l_benefit_class_id is not null) then
            insert_database_item (l_element_name,
                                  'BEN_CLASS' || p_date_p,
                                  'T',                           -- data type
                                  'BCLASS.benefit_classification_name',
                                  'N',                           -- null allowed
                                  'The element''s benefit classification',
                                  l_user_entity_id,
                                  l_full_mls,
                                  l_base_dbi_name);
          if l_full_mls then
            update_et_tl_dbi_names
            (p_leg_code       => l_legislation_code
            ,p_bg_id          => l_business_group_id
            ,p_startup_mode   => l_startup_mode
            ,p_user_name      => l_base_dbi_name
            ,p_user_entity_id => l_user_entity_id
            ,p_prefixes       => l_dbi_prefixes
            ,p_suffix         => 'BEN_CLASS'
            ,p_date_p         => p_date_p
            );
          end if;
        end if;
    END IF;
    --
    -- create the user entity for the second route
    --
    insert_user_entity (l_route2_name,
                        l_element_name  || '_E2' || p_date_p,
                        'entity for '|| l_route2_name,
                        'Y',                         -- not found allowed flag
                        'E',
                        p_element_type_id,
                        l_business_group_id,
                        l_legislation_code,
                        l_created_by,
                        l_last_login,
                        l_record_inserted);
    --
    -- only insert parameter values/database items if an entity was inserted
    --
    IF l_record_inserted THEN
        --
        -- Fetch the user_entity_id.
        --
        select  ff_user_entities_s.currval
        into    l_user_entity_id
        from    dual;
        --
        -- insert the element type id for the where clause filler
        --
        insert_parameter_value (p_element_type_id, 1);
        --
        -- load up the database items for the second route:
        --
        insert_database_item
                        (l_element_name,
                         'LENGTH_OF_SERVICE' || p_date_p,
                         'N',                           -- data type
    'nvl (ELINK.qualifying_length_of_service, ETYPE.qualifying_length_of_service)',
                         'Y',                           -- null allowed
                         'qualifying length of service for element type',
                          l_user_entity_id,
                          l_full_mls,
                          l_base_dbi_name);
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'LENGTH_OF_SERVICE'
          ,p_date_p         => p_date_p
          );
        end if;
        --
        insert_database_item
                        (l_element_name,
                         'QUALIFYING_UNITS' || p_date_p,
                         'T',                           -- data type
                         'nvl(hr_general.decode_lookup(''QUALIFYING_UNITS'',ELINK.QUALIFYING_UNITS),hr_general.decode_lookup(''QUALIFYING_UNITS'',ETYPE.QUALIFYING_UNITS))',
                         'Y',                           -- null allowed
                         'qualifying units from lookup table for element type',
                          l_user_entity_id,
                          l_full_mls,
                          l_base_dbi_name);
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'QUALIFYING_UNITS'
          ,p_date_p         => p_date_p
          );
        end if;
        --
        insert_database_item (l_element_name,
                          'QUALIFYING_UNITS_CODE' || p_date_p,
                          'T',                           -- data type
                          'nvl(ELINK.qualifying_units, ETYPE.qualifying_units)',
                          'Y',                           -- null allowed
                          'qualifying units from database for element type',
                          l_user_entity_id,
                          l_full_mls,
                          l_base_dbi_name);
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'QUALIFYING_UNITS_CODE'
          ,p_date_p         => p_date_p
          );
        end if;
        --
        insert_database_item (l_element_name,
                          'QUALIFYING_AGE' || p_date_p,
                          'N',                           -- data type
                          'nvl (ELINK.qualifying_age, ETYPE.qualifying_age)',
                          'Y',                           -- null allowed
                          'qualifying age for element type',
                          l_user_entity_id,
                          l_full_mls,
                          l_base_dbi_name);
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'QUALIFYING_AGE'
          ,p_date_p         => p_date_p
          );
        end if;
        --
        insert_database_item (l_element_name,
                          'STANDARD_LINK' || p_date_p,
                          'T',                           -- data type
                         'nvl(hr_general.decode_lookup(''YES_NO'',ELINK.STANDARD_LINK_FLAG),hr_general.decode_lookup(''YES_NO'',ETYPE.STANDARD_LINK_FLAG))',
                          'N',                           -- null allowed
 'standard link meaning from lookup table Yes = standard, No = discretionary',
                          l_user_entity_id,
                          l_full_mls,
                          l_base_dbi_name);
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'STANDARD_LINK'
          ,p_date_p         => p_date_p
          );
        end if;
         --
        insert_database_item (l_element_name,
                          'STANDARD_LINK_CODE' || p_date_p,
                          'T',                           -- data type
                    'nvl (ELINK.standard_link_flag, ETYPE.standard_link_flag)',
                          'N',                           -- null allowed
   'standard link value held on the database Y = standard, N = discretionary',
                          l_user_entity_id,
                          l_full_mls,
                          l_base_dbi_name);
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'STANDARD_LINK_CODE'
          ,p_date_p         => p_date_p
          );
        end if;
        --
        insert_database_item (l_element_name,
                          'COSTABLE_TYPE' || p_date_p,
                          'T',                           -- data type
                          'CTLOOK.meaning',
                          'N',                           -- null allowed
                  'costable type meaning from lookup table for element type',
                          l_user_entity_id,
                          l_full_mls,
                          l_base_dbi_name);
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'COSTABLE_TYPE'
          ,p_date_p         => p_date_p
          );
        end if;
    --
        insert_database_item (l_element_name,
                          'COSTABLE_TYPE_CODE' || p_date_p,
                          'T',                           -- data type
                          'ELINK.costable_type',
                          'N',                           -- null allowed
                  'costable type value held on the database for element type',
                          l_user_entity_id,
                          l_full_mls,
                          l_base_dbi_name);
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'COSTABLE_TYPE_CODE'
          ,p_date_p         => p_date_p
          );
        end if;
    end if;
    --
    -- create the user entity for the third route
    --
    insert_user_entity (l_route3_name,
                        l_element_name || '_E3' || p_date_p,
                        'entity for '|| l_route3_name,
                        'Y',                         -- not found allowed flag
                        'E',
                        p_element_type_id,
                        l_business_group_id,
                        l_legislation_code,
                        l_created_by,
                        l_last_login,
                        l_record_inserted);
    --
    -- only insert parameter values/database items if an entity was inserted
    --
    IF l_record_inserted THEN
        --
        -- Fetch the user_entity_id.
        --
        select  ff_user_entities_s.currval
        into    l_user_entity_id
        from    dual;
        --
        -- insert the element type id for the where clause filler
        --
        insert_parameter_value (p_element_type_id, 1);
        --
        -- load up the database items for the third route:
        --
        insert_database_item (l_element_name,
                          'COUNT' || p_date_p,
                          'N',                           -- data type
                          'count(0)',
                          'Y',                           -- null allowed
            'count of element types for given assignment and element type',
                          l_user_entity_id,
                          l_full_mls,
                          l_base_dbi_name);
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'COUNT'
          ,p_date_p         => p_date_p
          );
        end if;
    END IF;

    --
    -- Now see if any Element Descriptive flexs are to be created:
    -- First get a value for the legislation code:
    --
    select nvl (ltrim(rtrim(ETYPE.legislation_code)),
                ltrim(rtrim(BUSGP.legislation_code)))
    into   l_leg_code_class
    from   pay_element_types_f             ETYPE
    ,      per_business_groups_perf        BUSGP
    where  ETYPE.element_type_id         = p_element_type_id
    and    p_effective_date        between ETYPE.effective_start_date
                                           and ETYPE.effective_end_date
    and    BUSGP.business_group_id (+) = ETYPE.business_group_id;
    --
    l_class_name := l_leg_code_class ||'_'|| l_class_name;
    --
    --
    open get_title;
    fetch get_title into l_title;
    close get_title;
    --
    for c1rec in dflex_c1 ('PAY_ELEMENT_TYPES_F',       -- table name
                                l_title,      -- title of desc. flex
                                'N',                         -- global flag
                                l_class_name) loop  -- context code
        l_dbitem_found := FALSE;
        --
        -- now create the database items
        --

        for c2rec in dflex_c2 (c1rec.c_flex_name, l_class_name) loop
           --
           -- only create a user entity if database items are to be created.
           --
           if (l_dbitem_found = FALSE) then
               l_dbitem_found := TRUE;
               --
               -- create a user entity.
               --
               l_created_by := c1rec.c_created_by;
               l_last_login := c1rec.c_last_login;
               --
               insert_user_entity (l_route1_name,
                                   l_element_name || '_DF_E3' || p_date_p,
                                   'Element DDF entity for '|| l_route1_name,
                                   'Y',
                                   'E',
                                   p_element_type_id,
                                   l_business_group_id,
                                   l_legislation_code,
                                   l_created_by,
                                   l_last_login,
                                   l_record_inserted);
               --
               -- insert the element type id for the where clause filler
               --
               IF l_record_inserted
               THEN
                  insert_parameter_value (p_element_type_id, 1);
               END IF;
               --
           END IF;
           --
           IF l_record_inserted
           THEN
               insert_database_item (l_element_name,
                                 c2rec.c_db_name || p_date_p,
                                 'T',                           -- data type
                                 'ETYPE.' || c2rec.c_def_text,
                                 'Y',                           -- null allowed
                    'Element Descriptive flex DB item for ' || l_element_name);
           END IF;
        END LOOP;  -- dflex_c2 loop
    END LOOP;  -- dflex_c1 loop
--
END create_element_type;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                   create_element_type_dict                             +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      create_element_type_dict - create an element type in the data
                                 dictionary
--
   DESCRIPTION
      This procedure is the main entry point for creating database items for
      a given element type, where the context is date earned.  It calls the
      element type creation procedure : create_element_type.
*/
procedure create_element_type_dict
(
    p_element_type_id       in number,
    p_effective_date        in date
) is
--
begin
    create_element_type (p_element_type_id,
                         p_effective_date,
                         null);
end create_element_type_dict;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                   create_element_type_dp_dict                          +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      create_element_type_dp_dict  - create an element type in the data
                                     dictionary of context date paid,
--
   DESCRIPTION
      This procedure is the main entry point for creating database items for
      a given element type, where the context is date paid.  It first
      deletes all the old DB items for the given element type id, as these DB
      items would have been set up to use the context of date earned. It then
      calls the element type creation procedure : create_element_type, with the
      parameters to create date paid DB items.  This includes deleting and
      re-creating input value database items for the given element type.
*/
procedure create_element_type_dp_dict
(
    p_element_type_id       in number
) is
--
-- cursor c1 : select input values to be deleted:
--
cursor c1 is
select   input_value_id
from     pay_input_values_f
where    element_type_id   = p_element_type_id;
--
-- cursor c2 : select input values to be used for database items:
--
cursor c2 is
select   input_value_id,
         max(effective_end_date) c_date
from     pay_input_values_f
where    generate_db_items_flag = 'Y'
and      element_type_id        = p_element_type_id
group by input_value_id;
--
l_date         date;
l_element_type  number;
begin
    --
    -- first delete the old element type DB items which use the context of
    -- date earned
    --
    delete_element_type_dict (p_element_type_id);
    --
    -- create the new DB items with the context of date paid
    --
    select  element_type_id,
            max(effective_end_date)
    into    l_element_type,
            l_date
    from    pay_element_types_f
    where   element_type_id = p_element_type_id
    group by element_type_id;
    --
    create_element_type (p_element_type_id,
                         l_date,
                         '_DP');
    --
    -- go through and delete any old input values
    --
    for c1rec in c1 loop
        delete_input_value_dict (c1rec.input_value_id);
    end loop;   -- c1 loop
    --
    -- create the new input values with the context of date paid
    --
    for c2rec in c2 loop
        create_input_value (c2rec.input_value_id,
                            c2rec.c_date,
                            '_DP');
    end loop;   -- c2 loop
    --
end create_element_type_dp_dict;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                    delete_input_value_dict                             +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME
      delete_input_value_dict - delete an input value from the data
                                dictionary
--
DESCRIPTION
*/
procedure delete_input_value_dict
(
    p_input_value_id       in number
) is
--
BEGIN

--    delete_compiled_formula_priv(p_input_value_id, 'I', '%', null);

    DELETE FROM ff_user_entities
    WHERE  creator_id    = p_input_value_id
    AND    creator_type  = 'I';
END delete_input_value_dict;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                       create_input_value                               +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      create_input_value       - create an element type in the data
                                 dictionary, with a context of either date
                                 earned or date paid.
--
   DESCRIPTION
      This procedure creates input value database items for a given input value
      id, with a context of either date earned or date paid.  Date paid
      database items have '_DP' appended to the database name. To create date
      earned DB items, set the paramater 'p_date_p' to null.  To create date
      paid DB items, set it to '_DP'.
      The routes must have already been defined in the
      database (in table ff_routes).  The procedure will search for the
      routes in this table by using the route name, which is hard coded below.
      The procedure processes each route in turn, creating a user entity and
      route parameter values, and then inserting each database items for that
      particular route.
      The database items created use the input value name. This routine
      generates the following database items:
      --
      <NAME>_UNIT_OF_MEASURE
      <NAME>_UNIT_OF_MEASURE_CODE
      <NAME>_DEFAULT
      <NAME>_MINIMUM
      <NAME>_MAXIMUM
      --
      The following database items are created if multiple entries are NOT
      allowed:
      --
      <NAME>_ENTRY_VALUE
      <NAME>_USER_ENTERED_CODE
      <NAME>_START_DATE
      <NAME>_END_DATE
      --
      The following database item is created if the multiple entries are
      allowed:
      --
      <NAME>_ENTRY_VALUE             (sum of all non recurring values)
*/
procedure create_input_value
(
    p_input_value_id       in number,
    p_effective_date       in date,
    p_date_p               in varchar2
) is
l_route1_name  varchar2(50) := 'INPUT_VALUE_FROM_INPUT_VALUE_TABLE' ||p_date_p;
l_route2_name  varchar2(50) := 'INPUT_VALUE_USING_PARTIAL_MATCHING' ||p_date_p;
l_entry_route  varchar2(50) := 'INPUT_VALUE_ENTRY_LEVEL' || p_date_p;
l_override_entry_route  varchar2(50) := 'INPUT_VALUE_ENTRY_LEVEL_OVERRIDE' || p_date_p;
l_input_name          pay_input_values_f.name%type;
l_entity_name         ff_user_entities.user_entity_name%type;
l_element_type_id     pay_element_types_f.element_type_id%type;
l_element_name        pay_element_types_f.element_name%type;
l_multiple_entries    pay_element_types_f.multiple_entries_allowed_flag%type;
l_legislation_code    pay_element_types_f.legislation_code%type;
l_leg_code_ben        pay_element_types_f.legislation_code%type;
l_uom                 varchar2(30);  -- unit of measure
l_business_group_id   number;
l_start_string        varchar2(240);
l_end_string          varchar2(240);
l_data_type           varchar2(1);
l_created_by          number;
l_last_login          number;
l_record_inserted     boolean;
l_full_mls            boolean;
l_base_dbi_name       varchar2(2000);
l_user_entity_id      number;
l_legislation_code1   pay_element_types_f.legislation_code%type;
l_startup_mode        varchar2(30);
l_languages           dbms_sql.varchar2s;
l_dbi_prefixes        t_dbi_prefixes;
--
-- debug info
l_iv_eltypeid number;

--
cursor c_language is
  select language_code
  from   fnd_languages
  where  installed_flag in ('I','B');

cursor c_list_ivs(p_iv_id in number) is
  select name,
         element_type_id,
         to_char(effective_start_date, 'DD-MM-YYYY') esd,
         to_char(effective_end_date, 'DD-MM-YYYY') eed,
         legislation_code,
         business_group_id
  from   pay_input_values_f
  where  input_value_id = p_iv_id;

cursor c_list_elements(p_el_id in number) is
  select element_name,
         to_char(effective_start_date, 'DD-MM-YYYY') esd,
         to_char(effective_end_date, 'DD-MM-YYYY') eed,
         legislation_code,
         business_group_id
  from   pay_element_types_f
  where  element_type_id = p_el_id;

-- This procedure is used to translate hardcoded "Pay Value"
-- for each language installed.
--
PROCEDURE local_insert_database_item (
    p_item_name            in  varchar2,
    p_data_type            in  varchar2,
    p_definition_text      in  varchar2,
    p_null_allowed_flag    in  varchar2,
    p_description          in  varchar2,
    p_user_entity_id       in  number,
    p_full_mls             in  boolean,
    p_base_dbi_name        out nocopy varchar2)
IS
BEGIN
    --
    -- NB attention spaces ' ' of l_input_name are not replaced with underscore '_'.
    --
    --    call to insert_database_item to handle Pay_Value issue : Bug 1110849
    --    where if the input value found is Pay Value get dbitem created
    --    to contain the translated value for Pay Value by passing the input value
    --    name within the second parameter which goes through translation
    --    lookup in insert_database_item.
    --
    if l_input_name = 'PAY VALUE' and not p_full_mls then
       insert_database_item (l_element_name,
                             l_input_name || '_' || p_item_name || p_date_p,
                             p_data_type,
                             p_definition_text,
                             p_null_allowed_flag,
                             p_description,
                             p_user_entity_id,
                             p_full_mls,
                             p_base_dbi_name);
    else
       insert_database_item (l_entity_name,
                             p_item_name || p_date_p,
                             p_data_type,
                             p_definition_text,
                             p_null_allowed_flag,
                             p_description,
                             p_user_entity_id,
                             p_full_mls,
                             p_base_dbi_name);
    end if;
END local_insert_database_item;
--
-- NOTE:  The variable 'l_entity_name' is used to hold both the element type
-- name concatenated with the input value name.  This exceeds the maximum
-- length of the database item name.  On attempting to create the associated
-- db item, it is possible that the constructed name will exceed this maximum.
-- We rely on this being trapped by the insert statement failing.
--
------------------------- create_input_value -----------------------------
--
BEGIN
    --
    -- get the input and element type information
    --
    BEGIN
    select ltrim (rtrim (upper (INPUTV.name))),
           INPUTV.uom,
           INPUTV.business_group_id,
           ltrim(rtrim(INPUTV.legislation_code)),
           INPUTV.created_by,
           INPUTV.last_update_login,
           ET.element_type_id,
           replace (ltrim (rtrim (upper (ET.element_name))), ' ', '_'),
           ET.multiple_entries_allowed_flag
    into   l_input_name,
           l_uom,
           l_business_group_id,
           l_legislation_code,
           l_created_by,
           l_last_login,
           l_element_type_id,
           l_element_name,
           l_multiple_entries
    from   pay_input_values_f              INPUTV
    ,      pay_element_types_f             ET
    where  INPUTV.input_value_id         = p_input_value_id
    and    p_effective_date        between INPUTV.effective_start_date
                                       and INPUTV.effective_end_date
    and    ET.element_type_id            = INPUTV.element_type_id
    and    p_effective_date        between ET.effective_start_date
                                       and ET.effective_end_date;
    EXCEPTION WHEN OTHERS THEN
     BEGIN
      hrrbdeib_trace_on;
      hr_utility.trace('create_input_value select');
      hr_utility.trace('effective_date: ' ||
        to_char(p_effective_date, 'DD-MM-YYYY'));
      hr_utility.trace('input_value_id : ' || to_char(p_input_value_id));

      FOR iv IN c_list_ivs(p_input_value_id) LOOP
        hr_utility.trace('input name: ' || iv.name);
        hr_utility.trace('input el_type_id: ' ||
          to_char(iv.element_type_id));
        hr_utility.trace('input leg_code: ' || iv.legislation_code);
        hr_utility.trace('input BG id: ' || to_char(iv.business_group_id));
        hr_utility.trace('input ESD: ' || iv.esd);
        hr_utility.trace('input EED: ' || iv.eed);
      END LOOP;

      select distinct element_type_id
      into   l_iv_eltypeid
      from   pay_input_values_f
      where  input_value_id = p_input_value_id
      and    rownum = 1;

      FOR el in c_list_elements(l_iv_eltypeid) LOOP
        hr_utility.trace('element name: ' || el.element_name);
        hr_utility.trace('element ESD: ' || el.esd);
        hr_utility.trace('element EED: ' || el.eed);
        hr_utility.trace('element leg_code: ' || el.legislation_code);
        hr_utility.trace('element BG id: ' || to_char(el.business_group_id));
      END LOOP;
      hrrbdeib_trace_off;
      raise;
      END;
    END;
    --
    if (g_triggers_altered) then
      -- Get the startup mode
      l_startup_mode :=
      ffstup.get_mode (l_business_group_id, l_legislation_code);
    else
      -- Get the security group id which won't have been populated yet.
      g_security_group_id :=
      fnd_global.lookup_security_group('NAME_TRANSLATIONS', 3);
    end if;
    --
    -- Are the database items to be fully translated ?
    --
    l_legislation_code1 := l_legislation_code;
    if l_legislation_code1 is null and l_business_group_id is not null then
      select bg.legislation_code
      into   l_legislation_code1
      from   per_business_groups_perf bg
      where  bg.business_group_id = l_business_group_id
      ;
    end if;
    l_full_mls := ff_dbi_utils_pkg.translations_supported(l_legislation_code1);

    --
    -- Set up the data for the full MLS case.
    --
    if l_full_mls then
      open c_language;
      fetch c_language bulk collect
      into l_languages;
      close c_language;

      gen_eiv_dbi_prefixes
      (p_input_value_id => p_input_value_id
      ,p_effective_date => p_effective_date
      ,p_languages      => l_languages
      ,p_prefixes       => l_dbi_prefixes
      );
    end if;
    --
    -- assemble the entity name:
    -- nb spaces ' ' of l_input_name are not replaced with underscore '_'.
    --    now pass l_entity_name to insert_user_entity and
    --    use local_insert_database_item instead of direct call to
    --    insert_database_item to handle Pay_Value issue : Bug 1110849
    --    where if the input value found is Pay value get dbitem created
    --    to contain the translated value for Pay Value.
    --
    -- Bug 2936561. Remove full stops from input value nams prior to
    -- ue and dbi creation.
    --
    l_entity_name := l_element_name || '_' || replace(replace(l_input_name,' ','_'),
                                                      '.','');
    --
    -- create the user entity for the first route
    --
    insert_user_entity (l_route1_name,
                        l_entity_name || '_I1' || p_date_p,
                        'entity for '|| l_route1_name,
                        'Y',                        -- not found allowed flag
                        'I',
                        p_input_value_id,
                        l_business_group_id,
                        l_legislation_code,
                        l_created_by,
                        l_last_login,
                        l_record_inserted);
    --
    -- only insert parameter values/database items if an entity was inserted
    --
    IF l_record_inserted THEN
        --
        -- Fetch the user_entity_id.
        --
        select  ff_user_entities_s.currval
        into    l_user_entity_id
        from    dual;
        --
        -- insert the input value id for the where clause filler
        --
        insert_parameter_value (p_input_value_id, 1);
        --
        -- load up the database items for the first route:
        --
        local_insert_database_item (
                          'UNIT_OF_MEASURE',
                          'T',                           -- data type
                          'UMLOOK.meaning',
                          'N',                           -- null allowed
                          'unit of measure from lookup table for input value',
                          l_user_entity_id,
                          l_full_mls,
                          l_base_dbi_name);
        --
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'UNIT_OF_MEASURE'
          ,p_date_p         => p_date_p
          );
        end if;
        --
        local_insert_database_item (
                          'UNIT_OF_MEASURE_CODE',
                          'T',                           -- data type
                          'INPUTV.uom',
                          'N',                           -- null allowed
                       'unit of measure held on the database for input value',
                          l_user_entity_id,
                          l_full_mls,
                          l_base_dbi_name);
        --
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'UNIT_OF_MEASURE_CODE'
          ,p_date_p         => p_date_p
          );
        end if;
    END IF;
    --
    -- create the user entity for the second route
    --
    insert_user_entity (l_route2_name,
                        l_entity_name || '_I2' || p_date_p,
                        'entity for '|| l_route2_name,
                        'Y',                        -- not found allowed flag
                        'I',
                        p_input_value_id,
                        l_business_group_id,
                        l_legislation_code,
                        l_created_by,
                        l_last_login,
                        l_record_inserted);
    --
    l_start_string := null;
    l_end_string   := null;
    --
    -- note : If several input values that use the same route are created in
    -- a formula, then formula will fetch them all at once in one cursor. A
    -- problem arises when the database item has a user definable data type,
    -- for example input values.  If several items are used within the same
    -- formula and the data types are different, formula will fetch them all
    -- in one cursor and get confused about which data types belong to which
    -- items.  To avoid this the decode statment is added to the definition
    -- text for the DB item.
    --
    if (l_uom = 'D') then   -- a date, all formula dates to be in cannonical format
        l_start_string := 'fnd_date.canonical_to_date(decode(substr(INPUTV.uom,1,1),''D'',';
        l_end_string   := ',null))';
        l_data_type    := 'D';
    elsif (l_uom = 'M') or (l_uom = 'N') or (l_uom = 'I') then
        l_start_string := 'fffunc.cn(decode(
    decode(INPUTV.uom,''M'',''N'',''N'',''N'',''I'',''N'',null),''N'',';
        l_end_string   := ',null))';
        l_data_type    := 'N';
    elsif (l_uom like 'H_%') then
        l_start_string := 'fffunc.cn(decode(
    decode(substr(INPUTV.uom,1,2),''H_'',''N'',null),''N'',';
        l_end_string   := ',null))';
        l_data_type    := 'N';
    else
        l_data_type    := 'T';
    end if;
    --
    -- only insert parameter values/database items if an entity was inserted
    --
    IF l_record_inserted THEN
        --
        -- Fetch the user_entity_id.
        --
        select  ff_user_entities_s.currval
        into    l_user_entity_id
        from    dual;
        --
        -- insert the input value id for the where clause filler
        --
        insert_parameter_value (p_input_value_id, 1);
        --
        -- load up the database items for the second route:
        --
        -- arrange the values to be displayed in the format specified by the UOM
        local_insert_database_item (
                          'DEFAULT',
                          l_data_type,                 -- data type
l_start_string||'nvl(LIV.default_value,INPUTV.default_value)'|| l_end_string,
                          'Y',                           -- null allowed
                          'default value for input value',
                          l_user_entity_id,
                          l_full_mls,
                          l_base_dbi_name);
        --
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'DEFAULT'
          ,p_date_p         => p_date_p
          );
        end if;
        --
        local_insert_database_item (
                          'MIN',
                          l_data_type,                 -- data type
 l_start_string || 'nvl(LIV.min_value,INPUTV.min_value)' || l_end_string,
                          'Y',                           -- null allowed
                          'minimum value for input value',
                          l_user_entity_id,
                          l_full_mls,
                          l_base_dbi_name);
        --
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'MIN'
          ,p_date_p         => p_date_p
          );
        end if;
        --
        local_insert_database_item (
                          'MAX',
                          l_data_type,                 -- data type
 l_start_string || 'nvl(LIV.max_value,INPUTV.max_value)' || l_end_string,
                          'Y',                           -- null allowed
                          'maximum value for input value',
                          l_user_entity_id,
                          l_full_mls,
                          l_base_dbi_name);
        --
        if l_full_mls then
          update_et_tl_dbi_names
          (p_leg_code       => l_legislation_code
          ,p_bg_id          => l_business_group_id
          ,p_startup_mode   => l_startup_mode
          ,p_user_name      => l_base_dbi_name
          ,p_user_entity_id => l_user_entity_id
          ,p_prefixes       => l_dbi_prefixes
          ,p_suffix         => 'MAX'
          ,p_date_p         => p_date_p
          );
        end if;
    END IF;
    --
    -- now create database items depending whether the element is recurring
    -- or non-recurring
    --
    if (l_multiple_entries = 'N') then    -- multiple entries not allowed
        begin
            -- note: These non multi entry database items share the same route
            -- as the multi entry DB item which has a group function (a 'sum'
            -- function) as part of its definition text. Therefore these DB
            -- items must also have a dummy group function ('min') as part
            -- of their definition text even though they will only return one
            -- row.
            -- This is to allow for the case when a formula has both
            -- types of these DB items, as it will use the same
            -- cursor for both sets of DB items.  This would result in an
            -- illegal SQL statement, where it was missing a 'group by'
            -- clause. Since the 'group by' clause cannot be part of the route,
            -- all of the following DB items must contain a dummy group
            -- function.  Also, since null is returned for a group function
            -- with no rows, the null allowed flag must be set to 'yes'.
            --
            -- The only other solution to this problem would be to have 2
            -- identical routes, one for multi entry allowed, the other for
            -- non multi entry allowed.  Since we wanted to minimise the
            -- number of routes, this solution was not implemented.
            --
            --
            -- create the user entity for the non multiple entry types
            --
            insert_user_entity (l_entry_route,
                                l_entity_name || '_I3' || p_date_p,
                             'non multiple entry entity for '|| l_entry_route,
                                'Y',                 -- not found allowed flag
                                'I',
                                p_input_value_id,
                                l_business_group_id,
                                l_legislation_code,
                                l_created_by,
                                l_last_login,
                                l_record_inserted);
            --
            -- only insert parameter values/database items if entity
            -- was inserted
            --
            IF l_record_inserted THEN
                --
                -- Fetch the user_entity_id.
                --
                select  ff_user_entities_s.currval
                into    l_user_entity_id
                from    dual;
                --
                -- insert the input value id for the where clause filler
                --
                insert_parameter_value (p_input_value_id, 1);
                --
                -- insert the element type id for the 2nd where clause filler
                --
                IF p_date_p IS NULL THEN
                  insert_parameter_value (l_element_type_id, 2);
                END IF;
                --
                -- load up the database items for the non multiple entry types:
                --
                local_insert_database_item (
                                  'ENTRY_VALUE',
                                  l_data_type,              -- data type
                                  'min (' || l_start_string ||
'decode(INPUTV.hot_default_flag,''Y'',nvl(EEV.screen_entry_value,
nvl(LIV.default_value,INPUTV.default_value)),''N'',EEV.screen_entry_value)'
                                  || l_end_string || ')',
                                  'Y',                        -- null allowed
                                  'the recurring value',
                                  l_user_entity_id,
                                  l_full_mls,
                                  l_base_dbi_name);
                --
                if l_full_mls then
                  update_et_tl_dbi_names
                  (p_leg_code       => l_legislation_code
                  ,p_bg_id          => l_business_group_id
                  ,p_startup_mode   => l_startup_mode
                  ,p_user_name      => l_base_dbi_name
                  ,p_user_entity_id => l_user_entity_id
                  ,p_prefixes       => l_dbi_prefixes
                  ,p_suffix         => 'ENTRY_VALUE'
                  ,p_date_p         => p_date_p
                  );
                end if;
                --
                local_insert_database_item (
                                  'USER_ENTERED_CODE',
                                  'T',                        -- data type
                  'min(decode(EEV.screen_entry_value,null,''N'',''Y''))',
                                  'Y',                        -- null allowed
                    'indicates if a value exists at the element entry level',
                          l_user_entity_id,
                          l_full_mls,
                          l_base_dbi_name);
                --
                if l_full_mls then
                  update_et_tl_dbi_names
                  (p_leg_code       => l_legislation_code
                  ,p_bg_id          => l_business_group_id
                  ,p_startup_mode   => l_startup_mode
                  ,p_user_name      => l_base_dbi_name
                  ,p_user_entity_id => l_user_entity_id
                  ,p_prefixes       => l_dbi_prefixes
                  ,p_suffix         => 'USER_ENTERED_CODE'
                  ,p_date_p         => p_date_p
                  );
                end if;
                --
                local_insert_database_item (
                                  'START_DATE',
                                  'D',                        -- data type
                                  'min(EE.effective_start_date)',
                                  'Y',                        -- null allowed
                                  'start date of element',
                                  l_user_entity_id,
                                  l_full_mls,
                                  l_base_dbi_name);
                --
                if l_full_mls then
                  update_et_tl_dbi_names
                  (p_leg_code       => l_legislation_code
                  ,p_bg_id          => l_business_group_id
                  ,p_startup_mode   => l_startup_mode
                  ,p_user_name      => l_base_dbi_name
                  ,p_user_entity_id => l_user_entity_id
                  ,p_prefixes       => l_dbi_prefixes
                  ,p_suffix         => 'START_DATE'
                  ,p_date_p         => p_date_p
                  );
                end if;
                --
                local_insert_database_item (
                                  'END_DATE',
                                  'D',                        -- data type
                                  'min(EE.effective_end_date)',
                                  'Y',                        -- null allowed
                                  'end date of element',
                                  l_user_entity_id,
                                  l_full_mls,
                                  l_base_dbi_name);
                --
                if l_full_mls then
                  update_et_tl_dbi_names
                  (p_leg_code       => l_legislation_code
                  ,p_bg_id          => l_business_group_id
                  ,p_startup_mode   => l_startup_mode
                  ,p_user_name      => l_base_dbi_name
                  ,p_user_entity_id => l_user_entity_id
                  ,p_prefixes       => l_dbi_prefixes
                  ,p_suffix         => 'END_DATE'
                  ,p_date_p         => p_date_p
                  );
                end if;
            END IF;
            --
            -- Override Entry dbitems
            --
            insert_user_entity (l_override_entry_route,
                                l_entity_name || '_I4' || p_date_p,
                             'non multiple entry entity for '|| l_override_entry_route,
                                'Y',                 -- not found allowed flag
                                'I',
                                p_input_value_id,
                                l_business_group_id,
                                l_legislation_code,
                                l_created_by,
                                l_last_login,
                                l_record_inserted);
            --
            -- only insert parameter values/database items if entity
            -- was inserted
            --
            IF l_record_inserted THEN
                --
                -- Fetch the user_entity_id.
                --
                select  ff_user_entities_s.currval
                into    l_user_entity_id
                from    dual;
                --
                -- insert the input value id for the where clause filler
                --
                insert_parameter_value (p_input_value_id, 1);
                --
                -- insert the element type id for the 2nd where clause filler
                --
                IF p_date_p IS NULL THEN
                  insert_parameter_value (l_element_type_id, 2);
                END IF;
                --
                -- load up the database items for the non multiple entry types:
                --
                local_insert_database_item (
                                  'OVERRIDE_ENTRY_VALUE',
                                  l_data_type,              -- data type
                                  'min (' || l_start_string ||
'decode(INPUTV.hot_default_flag,''Y'',nvl(EEV.screen_entry_value,
nvl(LIV.default_value,INPUTV.default_value)),''N'',EEV.screen_entry_value)'
                                  || l_end_string || ')',
                                  'Y',                        -- null allowed
                                  'the recurring value',
                                  l_user_entity_id,
                                  l_full_mls,
                                  l_base_dbi_name);
                --
                if l_full_mls then
                  update_et_tl_dbi_names
                  (p_leg_code       => l_legislation_code
                  ,p_bg_id          => l_business_group_id
                  ,p_startup_mode   => l_startup_mode
                  ,p_user_name      => l_base_dbi_name
                  ,p_user_entity_id => l_user_entity_id
                  ,p_prefixes       => l_dbi_prefixes
                  ,p_suffix         => 'OVERRIDE_ENTRY_VALUE'
                  ,p_date_p         => p_date_p
                  );
                end if;
                --
                local_insert_database_item (
                                  'OVERRIDE_USER_ENTERED_CODE',
                                  'T',                        -- data type
                  'min(decode(EEV.screen_entry_value,null,''N'',''Y''))',
                                  'Y',                        -- null allowed
                    'indicates if a value exists at the element entry level',
                                  l_user_entity_id,
                                  l_full_mls,
                                  l_base_dbi_name);
                --
                if l_full_mls then
                  update_et_tl_dbi_names
                  (p_leg_code       => l_legislation_code
                  ,p_bg_id          => l_business_group_id
                  ,p_startup_mode   => l_startup_mode
                  ,p_user_name      => l_base_dbi_name
                  ,p_user_entity_id => l_user_entity_id
                  ,p_prefixes       => l_dbi_prefixes
                  ,p_suffix         => 'OVERRIDE_USER_ENTERED_CODE'
                  ,p_date_p         => p_date_p
                  );
                end if;
                --
                local_insert_database_item (
                                  'OVERRIDE_START_DATE',
                                  'D',                        -- data type
                                  'min(EE.effective_start_date)',
                                  'Y',                        -- null allowed
                                  'start date of element',
                                  l_user_entity_id,
                                  l_full_mls,
                                  l_base_dbi_name);
                --
                if l_full_mls then
                  update_et_tl_dbi_names
                  (p_leg_code       => l_legislation_code
                  ,p_bg_id          => l_business_group_id
                  ,p_startup_mode   => l_startup_mode
                  ,p_user_name      => l_base_dbi_name
                  ,p_user_entity_id => l_user_entity_id
                  ,p_prefixes       => l_dbi_prefixes
                  ,p_suffix         => 'OVERRIDE_START_DATE'
                  ,p_date_p         => p_date_p
                  );
                end if;
                --
                local_insert_database_item (
                                  'OVERRIDE_END_DATE',
                                  'D',                        -- data type
                                  'min(EE.effective_end_date)',
                                  'Y',                        -- null allowed
                                  'end date of element',
                                  l_user_entity_id,
                                  l_full_mls,
                                  l_base_dbi_name);
                --
                if l_full_mls then
                  update_et_tl_dbi_names
                  (p_leg_code       => l_legislation_code
                  ,p_bg_id          => l_business_group_id
                  ,p_startup_mode   => l_startup_mode
                  ,p_user_name      => l_base_dbi_name
                  ,p_user_entity_id => l_user_entity_id
                  ,p_prefixes       => l_dbi_prefixes
                  ,p_suffix         => 'OVERRIDE_END_DATE'
                  ,p_date_p         => p_date_p
                  );
                end if;
            END IF;
        end;
    else                                    -- multiple entries allowed
        --
        -- for multiple entries allowed, UOM must be hours, money or number,
        -- as it is summed in the definition text
        --
        if uom_requires_dbis(p_uom => l_uom) then
        begin
            --
            -- create the user entity for the multiple entries element
            --
            insert_user_entity (l_entry_route,
                                l_entity_name || '_I3' || p_date_p,
                                'multiple entry entity for '|| l_entry_route,
                                'Y',
                                'I',
                                p_input_value_id,
                                l_business_group_id,
                                l_legislation_code,
                                l_created_by,
                                l_last_login,
                                l_record_inserted);
            --
            -- only insert parameter values/database items if entity
            -- was inserted
            --
            IF l_record_inserted THEN
                --
                -- Fetch the user_entity_id.
                --
                select  ff_user_entities_s.currval
                into    l_user_entity_id
                from    dual;
                --
                -- insert the input value id for the where clause filler
                --
                insert_parameter_value (p_input_value_id, 1);
                --
                -- insert the element type id for the 2nd where clause filler
                --
                IF p_date_p IS NULL THEN
                  insert_parameter_value (l_element_type_id, 2);
                END IF;
                --
                -- load up the database items for the multiple entry items:
                --
                local_insert_database_item (
                                  'ENTRY_VALUE',
                                 l_data_type,             -- data type
 'sum(' || l_start_string || 'decode(INPUTV.hot_default_flag,
''Y'',nvl(EEV.screen_entry_value,
nvl(LIV.default_value,INPUTV.default_value)),
''N'',EEV.screen_entry_value)' || l_end_string || ')',
                                  'Y',                        -- null allowed
                                 'the summed multiple entry element values',
                                  l_user_entity_id,
                                  l_full_mls,
                                  l_base_dbi_name);
                --
                if l_full_mls then
                  update_et_tl_dbi_names
                  (p_leg_code       => l_legislation_code
                  ,p_bg_id          => l_business_group_id
                  ,p_startup_mode   => l_startup_mode
                  ,p_user_name      => l_base_dbi_name
                  ,p_user_entity_id => l_user_entity_id
                  ,p_prefixes       => l_dbi_prefixes
                  ,p_suffix         => 'ENTRY_VALUE'
                  ,p_date_p         => p_date_p
                  );
                end if;
            END IF;
           --
            -- Override Entry dbitems
            --
            insert_user_entity (l_override_entry_route,
                                l_entity_name || '_I4' || p_date_p,
                                'multiple entry entity for '|| l_override_entry_route,
                                'Y',
                                'I',
                                p_input_value_id,
                                l_business_group_id,
                                l_legislation_code,
                                l_created_by,
                                l_last_login,
                                l_record_inserted);
            --
            -- only insert parameter values/database items if entity
            -- was inserted
            --
            IF l_record_inserted THEN
                --
                -- Fetch the user_entity_id.
                --
                select  ff_user_entities_s.currval
                into    l_user_entity_id
                from    dual;
                --
                -- insert the input value id for the where clause filler
                --
                insert_parameter_value (p_input_value_id, 1);
                --
                -- insert the element type id for the 2nd where clause filler
                --
                IF p_date_p IS NULL THEN
                  insert_parameter_value (l_element_type_id, 2);
                END IF;
                --
                -- load up the database items for the multiple entry items:
                --
                local_insert_database_item (
                                  'OVERRIDE_ENTRY_VALUE',
                                 l_data_type,             -- data type
 'sum(' || l_start_string || 'decode(INPUTV.hot_default_flag,
''Y'',nvl(EEV.screen_entry_value,
nvl(LIV.default_value,INPUTV.default_value)),
''N'',EEV.screen_entry_value)' || l_end_string || ')',
                                  'Y',                        -- null allowed
                                 'the summed multiple entry element values',
                                  l_user_entity_id,
                                  l_full_mls,
                                  l_base_dbi_name);
                --
                if l_full_mls then
                  update_et_tl_dbi_names
                  (p_leg_code       => l_legislation_code
                  ,p_bg_id          => l_business_group_id
                  ,p_startup_mode   => l_startup_mode
                  ,p_user_name      => l_base_dbi_name
                  ,p_user_entity_id => l_user_entity_id
                  ,p_prefixes       => l_dbi_prefixes
                  ,p_suffix         => 'OVERRIDE_ENTRY_VALUE'
                  ,p_date_p         => p_date_p
                  );
                end if;
            END IF;
        end;
        end if;
    end if;
    --
    -- create the benefit input values if legislation = US.
    --

    select nvl (ltrim(rtrim(INPUTV.legislation_code)),
                ltrim(rtrim(BUSGP.legislation_code)))
    into   l_leg_code_ben
    from   pay_input_values_f              INPUTV
    ,      per_business_groups_perf        BUSGP
    where  INPUTV.input_value_id         = p_input_value_id
    and    p_effective_date        between INPUTV.effective_start_date
                                       and INPUTV.effective_end_date
    and    BUSGP.business_group_id (+) = INPUTV.business_group_id;

    --
    if (l_leg_code_ben = 'US') then
        pay_us_contr_dbi.create_contr_items (p_input_value_id,
                                         p_effective_date,
                                         l_start_string,
                                         l_end_string,
                                         l_data_type);
    end if;
END create_input_value;
--
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                       create_input_value_dict                          +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      create_input_value_dict - create an input value in the data
                                 dictionary
--
   DESCRIPTION
      This procedure is the main entry point for creating database items for
      a given input value, where the context is date earned. It calls the
      input value creation procedure : create_input_value.
*/
procedure create_input_value_dict
(
    p_input_value_id       in number,
    p_effective_date       in date
) is
begin
    create_input_value (p_input_value_id,
                        p_effective_date,
                        null);
end create_input_value_dict;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                       refresh_element_types                            +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME
    refresh_element_types -   create all DB items for element type and input
                              values
--
DESCRIPTION
    This routine creates all database items based on element types
    in the system. The routine assumes that no such database items currently
    exist.
*/
procedure refresh_element_types(p_worker_id in number default 0,
                                p_maxworkers in number default 1) is
   cursor c1 is select   element_type_id,
                         max(effective_end_date)
                from     pay_element_types_f e
                where    not exists (
                 select null
                 from ff_user_entities u
                 where u.creator_id = e.element_type_id
                 and u.creator_type = 'E')
                 and mod(element_type_id, p_maxworkers) = p_worker_id
                group by element_type_id
                order by element_type_id;
   --
   cursor c2 is select   input_value_id,
                         max(effective_end_date)
                from     pay_input_values_f i
                where    generate_db_items_flag = 'Y'
                and      not exists (
                 select null
                 from ff_user_entities u
                 where u.creator_id = i.input_value_id
                 and u.creator_type = 'I')
                 and mod(input_value_id, p_maxworkers) = p_worker_id
                group by input_value_id
                order by input_value_id;

l_input_value_id  number;
l_element_type_id number;
l_date            date;
l_loop_cnt number;

begin
   --
   -- create element types
   --
hrrbdeib_trace_on;
hr_utility.trace('entering refresh_el types elements all' ||
                 ' worker: ' || to_char(p_worker_id + 1) || '/' ||
                 to_char(p_maxworkers));
hrrbdeib_trace_off;

l_loop_cnt := 0;

   open c1;
   loop
       fetch c1 into l_element_type_id,
                     l_date;
       EXIT when c1%notfound;
       hrrbdeib_trace_on;
       hr_utility.trace('RELE:'|| to_char(p_worker_id + 1) || ':' ||
                        to_char(l_element_type_id) || '.' ||
                        to_char(l_date,'DD-MM-YYYY'));
       hrrbdeib_trace_off;
       create_element_type_dict (l_element_type_id, l_date);

       l_loop_cnt := l_loop_cnt + 1;
       if l_loop_cnt > 100 then
         l_loop_cnt := 0;
         commit;
       end if;

   end loop;
   close c1;
   --
   -- create input values
   --
hrrbdeib_trace_on;
hr_utility.trace('leaving refresh_el types elements all' ||
                 ' worker: ' || to_char(p_worker_id + 1) || '/' ||
                 to_char(p_maxworkers));

hr_utility.trace('entering refresh_el types ivs all' ||
                 ' worker: ' || to_char(p_worker_id + 1) || '/' ||
                 to_char(p_maxworkers));
hrrbdeib_trace_off;

l_loop_cnt := 0;

   open c2;
   loop
       fetch c2 into l_input_value_id,
                     l_date;
       EXIT when c2%notfound;
       hrrbdeib_trace_on;
       hr_utility.trace('RELI:'|| to_char(p_worker_id + 1) || ':' ||
                        to_char(l_input_value_id) || '.' ||
                        to_char(l_date,'DD-MM-YYYY'));
       hrrbdeib_trace_off;
       create_input_value_dict (l_input_value_id, l_date);

       l_loop_cnt := l_loop_cnt + 1;
       if l_loop_cnt > 100 then
         l_loop_cnt := 0;
         commit;
       end if;

   end loop;
   close c2;

hrrbdeib_trace_on;
hr_utility.trace('leaving refresh_el types ivs all' ||
                 ' worker: ' || to_char(p_worker_id + 1) || '/' ||
                 to_char(p_maxworkers));
hrrbdeib_trace_off;

end refresh_element_types;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                       refresh_element_types                            +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME
    refresh_element_types -   create all DB items for element type and input
                              values
--
DESCRIPTION
    This routine creates all database items based on element types
    in the system. The routine assumes that no such database items currently
    exist.
*/
procedure refresh_element_types(p_leg_code in varchar2,
                                p_worker_id in number default 0,
                                p_maxworkers in number default 1) is
   cursor c1 is select   element_type_id,
                         max(effective_end_date)
                from     pay_element_types_f a
                where    not exists (
                 select null
                 from ff_user_entities u
                 where u.creator_id = a.element_type_id
                 and u.creator_type = 'E')
                 and mod(element_type_id, p_maxworkers) = p_worker_id
                and      (a.legislation_code = p_leg_code
                          or exists (select null
                                 from   per_business_groups_perf b
                                 where  a.business_group_id = b.business_group_id
                                 and    nvl(b.legislation_code, p_leg_code) = p_leg_code))
                group by element_type_id
                order by element_type_id;
   --
   cursor c2 is select   input_value_id,
                         max(effective_end_date)
                from     pay_input_values_f a
                where    generate_db_items_flag = 'Y'
                and      not exists (
                 select null
                 from ff_user_entities u
                 where u.creator_id = a.input_value_id
                 and u.creator_type = 'I')
                 and      mod(input_value_id, p_maxworkers) = p_worker_id
                and      (a.legislation_code = p_leg_code
                          or exists (select null
                                 from   per_business_groups_perf b
                                 where  a.business_group_id = b.business_group_id
                                 and    nvl(b.legislation_code, p_leg_code) = p_leg_code))
                group by input_value_id
                order by input_value_id;

l_input_value_id  number;
l_element_type_id number;
l_date            date;
l_loop_cnt number;

begin
   --
   -- create element types
   --
hrrbdeib_trace_on;
hr_utility.trace('entering refresh_el types elements ' || p_leg_code ||
                 ' worker: ' || to_char(p_worker_id + 1) || '/' ||
                 to_char(p_maxworkers));
hrrbdeib_trace_off;

l_loop_cnt := 0;

   open c1;
   loop
       fetch c1 into l_element_type_id,
                     l_date;
       EXIT when c1%notfound;
       hrrbdeib_trace_on;
       hr_utility.trace('RELE:'|| to_char(p_worker_id + 1) || ':' ||
                        to_char(l_element_type_id) || '.' ||
                        to_char(l_date,'DD-MM-YYYY'));
       hrrbdeib_trace_off;
       create_element_type_dict (l_element_type_id, l_date);

       l_loop_cnt := l_loop_cnt + 1;
       if l_loop_cnt > 100 then
         l_loop_cnt := 0;
         commit;
       end if;

   end loop;
   close c1;
   --
hrrbdeib_trace_on;
hr_utility.trace('leaving refresh_el types elements ' || p_leg_code ||
                 ' worker: ' || to_char(p_worker_id + 1) || '/' ||
                 to_char(p_maxworkers));

   -- create input values
   --
hr_utility.trace('entering refresh_el types ivs ' || p_leg_code ||
                 ' worker: ' || to_char(p_worker_id + 1) || '/' ||
                 to_char(p_maxworkers));
hrrbdeib_trace_off;

l_loop_cnt := 0;

   open c2;
   loop
       fetch c2 into l_input_value_id,
                     l_date;
       EXIT when c2%notfound;
       hrrbdeib_trace_on;
       hr_utility.trace('RELI:'|| to_char(p_worker_id + 1) || ':' ||
                        to_char(l_input_value_id) || '.' ||
                        to_char(l_date,'DD-MM-YYYY'));
       hrrbdeib_trace_off;
       create_input_value_dict (l_input_value_id, l_date);

       l_loop_cnt := l_loop_cnt + 1;
       if l_loop_cnt > 100 then
         l_loop_cnt := 0;
         commit;
       end if;

   end loop;
   close c2;

hrrbdeib_trace_on;
hr_utility.trace('leaving refresh_el types ivs ' || p_leg_code ||
                 ' worker: ' || to_char(p_worker_id + 1) || '/' ||
                 to_char(p_maxworkers));
hrrbdeib_trace_off;

end refresh_element_types;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                        delete_element_types                            +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME
    delete_element_types -   delete all DB itms for element type and input
                             values
--
DESCRIPTION
   This routine deletes all database items based on element types
   in the system. The routine assumes that no such database items currently
   exist.
*/
procedure delete_element_types(p_worker_id in number default 0,
                               p_maxworkers in number default 1) is
begin
   --
   delete ff_user_entities u
   where  u.creator_type = 'I'
   and exists (
     select null
     from   pay_input_values_f a
     where  u.creator_id  = a.input_value_id);

   delete ff_user_entities u
   where  u.creator_type = 'E'
   and exists (
     select null
     from   pay_element_types_f x
     where  u.creator_id  = x.element_type_id);
end;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                        delete_element_types                            +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME
    delete_element_types -   delete all DB itms for element type and input
                             values
--
DESCRIPTION
   This routine deletes all database items based on element types
   in the system. The routine assumes that no such database items currently
   exist.
*/
procedure delete_element_types(p_leg_code in varchar2,
                               p_worker_id in number default 0,
                               p_maxworkers in number default 1) is
begin
   --
   -- delete the input values
   --
   delete ff_user_entities u
   where  u.creator_type = 'I'
   and exists (
     select null
     from   pay_input_values_f a
     where  u.creator_id  = a.input_value_id
     and    (a.legislation_code = p_leg_code
          or exists
              (select null
               from   per_business_groups_perf b
               where  a.business_group_id = b.business_group_id
               and    nvl(b.legislation_code, p_leg_code) = p_leg_code)));

   delete ff_user_entities u
   where  u.creator_type = 'E'
   and exists (
     select null
     from   pay_element_types_f x
     where  u.creator_id  = x.element_type_id
     and    (x.legislation_code = p_leg_code
          or exists
              (select null
               from   per_business_groups_perf y
               where  x.business_group_id = y.business_group_id
               and    nvl(y.legislation_code, p_leg_code) = p_leg_code)));

end delete_element_types;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                      rebuild_ele_input_bal                             +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
/*
NAME
    rebuild_ele_input_bal -  Delete and then re-create Db items for elements,
                             input values and balances.
--
DESCRIPTION
   This routine deletes all database items for element, input values and
   balances in the database.  It then re-creates them.
   This routine would typically be called after a startup delivery.
   If the parameter 'p_commit' is set to 'Y' then the routine will commit
   after the procedure calls to delete/re-create the DB items.  This helps
   the installation process when there is many DB items, or if the rollback
   segment space is limited.
*/
procedure rebuild_ele_input_bal
(
    p_commit in varchar2 default 'N',
    p_worker_id in number default 0,
    p_maxworkers in number default 1
)
is

   workers_complete number;
   worker_err       number;

begin
   --
   g_debug_cnt := 0;

   select count(*)
   into g_debug_cnt
   from pay_patch_status
   where patch_name = 'HRGLOBAL_DEBUG2';

   hrrbdeib_trace_on;
   hr_utility.trace('entering rebuild_ele_input_bal all' ||
                 ' worker: ' || to_char(p_worker_id + 1) || '/' ||
                 to_char(p_maxworkers));
   hrrbdeib_trace_off;

   -- First set global to say we are disabling triggers.
   -- Loop thru each worker
  if p_worker_id = 0 then
   enable_ffue_cascade_trig;
   enable_refbal_trig;

   -- Running Core so delete all compiled info and usages
   hrrbdeib_trace_on;
   hr_utility.trace('entering truncate_fcomp_info');
   hrrbdeib_trace_off;

--   truncate_fcomp_info;

   hrrbdeib_trace_on;
   hr_utility.trace('leaving truncate_fcomp_info');
   hrrbdeib_trace_off;

  else
   dbms_lock.sleep(5);
  end if;

   g_triggers_altered := TRUE;
   --
   if (p_commit = 'Y') then
     commit;
   end if;
   --
   -- Delete ALL balance DB items:
   --
   -- disable delete triggers for these entities for performance.
  if p_worker_id = 0 then
   disable_ffue_cascade_trig;
  else
   dbms_lock.sleep(5);
  end if;

   --
   if (p_commit = 'Y') then
     commit;
   end if;
   --
   -- INSERT A COMPLETION STEP AND
   -- LOOP HERE UNTIL ALL WORKERS HAVE COMPLETED INITIAL SET UP
   -- SO THAT WORKER 2 WONT BE DELETING WHILST WORKER 1 IS CREATING
   -- FOR EXAMPLE
   insert_mthread_pps(1, p_worker_id, 'ZZ');
   --
   if (p_commit = 'Y') then
     commit;
   end if;
   --
   loop

     select count(*)
     into   worker_err
     from   pay_patch_status
     where  patch_name like 'HRRBDEIB INTERNAL PROC ERR%';

     if worker_err > 0 then
       raise_application_error(-20106, 'A hrrbdeib worker has failed, terminating all workers.');
     end if;

     select count(*)
     into   workers_complete
     from   pay_patch_status
     where  patch_name = 'HRRBDEIB INTERNAL PROC S1'
     and    process_type = 'ZZ';

     exit when workers_complete = p_maxworkers;

     dbms_lock.sleep(5);

   end loop;

   if (p_commit = 'Y') then
     commit;
   end if;

   -- re-enable delete triggers
  if p_worker_id = 0 then
   enable_ffue_cascade_trig;
   disable_refbal_trig;
  else
   dbms_lock.sleep(5);
  end if;

   --
   hrdyndbi.refresh_defined_balances(p_worker_id,
                                     p_maxworkers);

   --
   -- INSERT A COMPLETION STEP AND
   -- LOOP HERE UNTIL ALL WORKERS HAVE COMPLETED INITIAL SET UP
   -- SO THAT WORKER 2 WONT BE DELETING WHILST WORKER 1 IS CREATING
   -- FOR EXAMPLE
   insert_mthread_pps(2, p_worker_id, 'ZZ');

   if (p_commit = 'Y') then
     commit;
   end if;


   loop

     select count(*)
     into   worker_err
     from   pay_patch_status
     where  patch_name like 'HRRBDEIB INTERNAL PROC ERR%';

     if worker_err > 0 then
       raise_application_error(-20106, 'A hrrbdeib worker has failed, terminating all workers.');
     end if;

     select count(*)
     into   workers_complete
     from   pay_patch_status
     where  patch_name = 'HRRBDEIB INTERNAL PROC S2'
     and    process_type = 'ZZ';

     exit when workers_complete = p_maxworkers;

     dbms_lock.sleep(5);

   end loop;
   --
   if (p_commit = 'Y') then
     commit;
   end if;
   --
   -- re-enable insert triggers
  if p_worker_id = 0 then
   enable_refbal_trig;
   disable_ffue_cascade_trig;
  else
   dbms_lock.sleep(5);
  end if;

   --
   --
   -- INSERT A COMPLETION STEP AND
   -- LOOP HERE UNTIL ALL WORKERS HAVE COMPLETED INITIAL SET UP
   -- SO THAT WORKER 2 WONT BE DELETING WHILST WORKER 1 IS CREATING
   -- FOR EXAMPLE
   insert_mthread_pps(3, p_worker_id, 'ZZ');

   if (p_commit = 'Y') then
     commit;
   end if;


   loop

     select count(*)
     into   worker_err
     from   pay_patch_status
     where  patch_name like 'HRRBDEIB INTERNAL PROC ERR%';

     if worker_err > 0 then
       raise_application_error(-20106, 'A hrrbdeib worker has failed, terminating all workers.');
     end if;

     select count(*)
     into   workers_complete
     from   pay_patch_status
     where  patch_name = 'HRRBDEIB INTERNAL PROC S3'
     and    process_type = 'ZZ';

     exit when workers_complete = p_maxworkers;

     dbms_lock.sleep(5);

   end loop;

   if (p_commit = 'Y') then
     commit;
   end if;
   --
   -- re-enable delete triggers
  if p_worker_id = 0 then
   enable_ffue_cascade_trig;
  else
   dbms_lock.sleep(5);
  end if;

   --
   -- Create all input and element DB items:
   --
   -- Get the security ID for the codename cursor
   g_security_group_id := fnd_global.lookup_security_group('NAME_TRANSLATIONS', 3);
   --
   --
   -- disable insert triggers for these entities for performance.
  if p_worker_id = 0 then
   disable_refbal_trig;
  else
   dbms_lock.sleep(5);
  end if;

   --
   hrdyndbi.refresh_element_types(p_worker_id,
                                  p_maxworkers);
   -- INSERT A COMPLETION STEP AND
   -- LOOP HERE UNTIL ALL WORKERS HAVE COMPLETED INITIAL SET UP
   -- SO THAT WORKER 2 WONT BE DELETING WHILST WORKER 1 IS CREATING
   -- FOR EXAMPLE
   insert_mthread_pps(4, p_worker_id, 'ZZ');

   if (p_commit = 'Y') then
     commit;
   end if;


   loop

     select count(*)
     into   worker_err
     from   pay_patch_status
     where  patch_name like 'HRRBDEIB INTERNAL PROC ERR%';

     if worker_err > 0 then
       raise_application_error(-20106, 'A hrrbdeib worker has failed, terminating all workers.');
     end if;

     select count(*)
     into   workers_complete
     from   pay_patch_status
     where  patch_name = 'HRRBDEIB INTERNAL PROC S4'
     and    process_type = 'ZZ';

     exit when workers_complete = p_maxworkers;

     dbms_lock.sleep(5);

   end loop;
   --
   -- Important. In order not to hang when we have selected more than
   -- 1 non Core legislation for install, we must of course delete the
   -- tracking pay_patch_status rows so that the next leg loop of hrrbdeib
   -- starts afresh. We  take care of this now by not trashing history and
   -- tag a legislation code to the pps rows
   --
   if (p_commit = 'Y') then
     commit;
   end if;
   --
   -- re-enable insert triggers
  if p_worker_id = 0 then
   enable_refbal_trig;
  else
   dbms_lock.sleep(5);
  end if;

   --
   -- reset global
   g_triggers_altered := FALSE;
   --
   hrrbdeib_trace_on;
   hr_utility.trace('leaving rebuild_ele_input_bal all' ||
                 ' worker: ' || to_char(p_worker_id + 1) || '/' ||
                 to_char(p_maxworkers));
   hrrbdeib_trace_off;
   --
exception
   when others then
     -- re-enable any disabled triggers
     hrrbdeib_trace_on;
     hr_utility.trace('exception raised in rebuild_ele_input_bal all' ||
                   ' worker: ' || to_char(p_worker_id + 1) || '/' ||
                   to_char(p_maxworkers));
     hrrbdeib_trace_off;
     insert_mthread_pps_err(p_worker_id, 'ZZ');
     enable_ffue_cascade_trig;
     enable_refbal_trig;
     raise; -- reraise the exception
--
end rebuild_ele_input_bal;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                      rebuild_ele_input_bal                             +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
/*
NAME
    rebuild_ele_input_bal -  Delete and then re-create Db items for elements,
                             input values and balances.
--
DESCRIPTION
   This routine deletes all database items for element, input values and
   balances in the database.  It then re-creates them.
   This routine would typically be called after a startup delivery.
   If the parameter 'p_commit' is set to 'Y' then the routine will commit
   after the procedure calls to delete/re-create the DB items.  This helps
   the installation process when there is many DB items, or if the rollback
   segment space is limited.
*/
procedure rebuild_ele_input_bal
(
    p_commit in varchar2 default 'N',
    p_leg_code in varchar2,
    p_worker_id in number default 0,
    p_maxworkers in number default 1
)
is

   workers_complete number;
   worker_err       number;
   l_formula_ids dbms_sql.number_table;
   l_start_dates dbms_sql.date_table;
   l_rowids      dbms_sql.varchar2s;
   form_name varchar2(80);

--
-- Cursor to fetch FDIU row information for rows affected by the EIB
-- database item recreation.
--
cursor csr_affected_fdiu_rows
(p_leg_code in varchar2
) is
select fdi.rowid
,      fdi.formula_id
,      fdi.effective_start_date
from   ff_fdi_usages_f fdi
where exists
  (select null
   from   ff_database_items dbi
   where  fdi.item_name = dbi.user_name
   and exists
     (select null
      from   ff_user_entities ent
      where  ent.user_entity_id = dbi.user_entity_id
      and    ent.creator_type in ('B','RB','E','I')
      -- MERGE B RB E I main cursors
      --
      -- B
      and (
        not exists (
          select null
          from   pay_defined_balances b
          where  b.defined_balance_id = ent.creator_id
          and    ent.creator_type = 'B'
        )
        OR
        -- RB
        (not exists (
          select null
          from   pay_defined_balances b
          where  b.defined_balance_id = ent.creator_id
          and    ent.creator_type = 'RB'
          and exists
                    (select null
                     from pay_dimension_routes pdr
                     where pdr.balance_dimension_id = b.balance_dimension_id)
          )
          OR
          (exists (
            select pdr.balance_dimension_id
            from   pay_dimension_routes pdr,
                   pay_defined_balances b
            where  pdr.balance_dimension_id = b.balance_dimension_id
            and    not exists (select null
                               from   ff_user_entities ue
                               where  ue.creator_id = b.defined_balance_id
                               and    ue.route_id = pdr.route_id
                               and    ue.creator_type = 'RB'))
          )
         ) -- end RB
         OR
         -- E
         (not exists (
          select null
          from   pay_element_types_f et
          where ent.creator_id = et.element_type_id
          and   ent.creator_type = 'E'))
         OR
         -- I
         (not exists (
          select null
          from   pay_input_values_f i
          where  ent.creator_id = i.input_value_id
          and    i.generate_db_items_flag = 'Y'
          and    ent.creator_type = 'I'))
        ) -- end B RB E I
      and
        (nvl (ent.legislation_code, ' ') = nvl (p_leg_code, ' ')
         or exists
           (select null
            from   per_business_groups_perf b
            where  ent.business_group_id = b.business_group_id
            and nvl(b.legislation_code, p_leg_code) = p_leg_code
           )
        )
     )
  )
;
begin
   --
   g_debug_cnt := 0;

   select count(*)
   into g_debug_cnt
   from pay_patch_status
   where patch_name = 'HRGLOBAL_DEBUG2';

   hrrbdeib_trace_on;
   hr_utility.trace('entering rebuild_ele_input_bal ' || p_leg_code ||
                 ' worker: ' || to_char(p_worker_id + 1) || '/' ||
                 to_char(p_maxworkers));
   hrrbdeib_trace_off;
   --
   -- First set global to say we are disabling triggers.
  if p_worker_id = 0 then
   enable_ffue_cascade_trig;
   enable_refbal_trig;

   g_triggers_altered := TRUE;
   --
   -- delete legislative formulae usages and compiled info
   --
   hrrbdeib_trace_on;
   hr_utility.trace('entering delete fcomp info: LC: ' || p_leg_code);
   hrrbdeib_trace_off;

/*
   open csr_affected_fdiu_rows(p_leg_code => p_leg_code);

   loop
     --
     -- Delete in chunks to avoid potential memory issues with bulk
     -- collecting many thousands of rows.
     --
     fetch csr_affected_fdiu_rows bulk collect
     into  l_rowids
     ,     l_formula_ids
     ,     l_start_dates
     limit 500;

     exit when csr_affected_fdiu_rows%notfound;

     forall i in 1 .. l_rowids.count
       delete
       from   ff_fdi_usages_f fdi
       where  fdi.rowid = l_rowids(i)
       ;

     forall i in 1 .. l_rowids.count
       delete
       from   ff_compiled_info_f fci
       where  fci.formula_id = l_formula_ids(i)
       and    fci.effective_start_date = l_start_dates(i)
       ;

   end loop;

   close csr_affected_fdiu_rows;
*/

   hrrbdeib_trace_on;
   hr_utility.trace('leaving delete fcomp info: LC: ' || p_leg_code);
   hrrbdeib_trace_off;

   end if;
   --
   if (p_commit = 'Y') then
     commit;
   end if;
   --
   -- INSERT A COMPLETION STEP AND
   -- LOOP HERE UNTIL ALL WORKERS HAVE COMPLETED INITIAL SET UP
   -- SO THAT WORKER 2 WONT BE DELETING WHILST WORKER 1 IS CREATING
   -- FOR EXAMPLE
   insert_mthread_pps(1, p_worker_id, p_leg_code);

   if (p_commit = 'Y') then
     commit;
   end if;


   loop

     select count(*)
     into   worker_err
     from   pay_patch_status
     where  patch_name like 'HRRBDEIB INTERNAL PROC ERR%';

     if worker_err > 0 then
       raise_application_error(-20106, 'A hrrbdeib worker has failed, terminating all workers.');
     end if;

     select count(*)
     into   workers_complete
     from   pay_patch_status
     where  patch_name = 'HRRBDEIB INTERNAL PROC S1'
     and    process_type = p_leg_code;

     exit when workers_complete = p_maxworkers;

     dbms_lock.sleep(5);

   end loop;
   --
   -- Create ALL DB items for defined balances in the account:
   --
   -- disable insert triggers for these entities for performance.
  if p_worker_id = 0 then
   disable_refbal_trig;
  else
   dbms_lock.sleep(5);
  end if;

   --
   hrdyndbi.refresh_defined_balances(p_leg_code,
                                     p_worker_id,
                                     p_maxworkers);
   --
   -- INSERT A COMPLETION STEP AND
   -- LOOP HERE UNTIL ALL WORKERS HAVE COMPLETED INITIAL SET UP
   -- SO THAT WORKER 2 WONT BE DELETING WHILST WORKER 1 IS CREATING
   -- FOR EXAMPLE
   insert_mthread_pps(2, p_worker_id, p_leg_code);
   --
   if (p_commit = 'Y') then
     commit;
   end if;


   loop

     select count(*)
     into   worker_err
     from   pay_patch_status
     where  patch_name like 'HRRBDEIB INTERNAL PROC ERR%';

     if worker_err > 0 then
       raise_application_error(-20106, 'A hrrbdeib worker has failed, terminating all workers.');
     end if;

     select count(*)
     into   workers_complete
     from   pay_patch_status
     where  patch_name = 'HRRBDEIB INTERNAL PROC S2'
     and    process_type = p_leg_code;

     exit when workers_complete = p_maxworkers;

     dbms_lock.sleep(5);

   end loop;

   if (p_commit = 'Y') then
     commit;
   end if;
   --
   -- re-enable insert triggers
  if p_worker_id = 0 then
   enable_refbal_trig;
   disable_ffue_cascade_trig;
  else
   dbms_lock.sleep(5);
  end if;

   --
   --
   -- INSERT A COMPLETION STEP AND
   -- LOOP HERE UNTIL ALL WORKERS HAVE COMPLETED INITIAL SET UP
   -- SO THAT WORKER 2 WONT BE DELETING WHILST WORKER 1 IS CREATING
   -- FOR EXAMPLE
   insert_mthread_pps(3, p_worker_id, p_leg_code);

   if (p_commit = 'Y') then
     commit;
   end if;


   loop

     select count(*)
     into   worker_err
     from   pay_patch_status
     where  patch_name like 'HRRBDEIB INTERNAL PROC ERR%';

     if worker_err > 0 then
       raise_application_error(-20106, 'A hrrbdeib worker has failed, terminating all workers.');
     end if;

     select count(*)
     into   workers_complete
     from   pay_patch_status
     where  patch_name = 'HRRBDEIB INTERNAL PROC S3'
     and    process_type = p_leg_code;

     exit when workers_complete = p_maxworkers;

     dbms_lock.sleep(5);

   end loop;

   if (p_commit = 'Y') then
     commit;
   end if;
   --
   -- re-enable delete triggers
  if p_worker_id = 0 then
   enable_ffue_cascade_trig;
  else
   dbms_lock.sleep(5);
  end if;

   --
   -- Create all input and element DB items:
   --
   -- Get the security ID for the codename cursor
   g_security_group_id := fnd_global.lookup_security_group('NAME_TRANSLATIONS',
3);
   --
   --
   -- disable insert triggers for these entities for performance.
  if p_worker_id = 0 then
   disable_refbal_trig;
  else
   dbms_lock.sleep(5);
  end if;

   --
   hrdyndbi.refresh_element_types(p_leg_code,
                                  p_worker_id,
                                  p_maxworkers);
   --
   --
   -- INSERT A COMPLETION STEP AND
   -- LOOP HERE UNTIL ALL WORKERS HAVE COMPLETED INITIAL SET UP
   -- SO THAT WORKER 2 WONT BE DELETING WHILST WORKER 1 IS CREATING
   -- FOR EXAMPLE
   insert_mthread_pps(4, p_worker_id, p_leg_code);

   if (p_commit = 'Y') then
     commit;
   end if;


   loop

     select count(*)
     into   worker_err
     from   pay_patch_status
     where  patch_name like 'HRRBDEIB INTERNAL PROC ERR%';

     if worker_err > 0 then
       raise_application_error(-20106, 'A hrrbdeib worker has failed, terminating all workers.');
     end if;

     select count(*)
     into   workers_complete
     from   pay_patch_status
     where  patch_name = 'HRRBDEIB INTERNAL PROC S4'
     and    process_type = p_leg_code;

     exit when workers_complete = p_maxworkers;

     dbms_lock.sleep(5);

   end loop;
   --
   -- Important. In order not to hang when we have selected more than
   -- 1 non Core legislation for install, we must of course delete the
   -- tracking pay_patch_status rows so that the next leg loop of hrrbdeib
   -- starts afresh. We  take care of this now by not trashing history and
   -- tag a legislation code to the pps rows
   --
   if (p_commit = 'Y') then
     commit;
   end if;
   --
   -- re-enable insert triggers
  if p_worker_id = 0 then
   enable_refbal_trig;
  else
   dbms_lock.sleep(5);
  end if;

   --
   -- reset global
   g_triggers_altered := FALSE;
   --
   hrrbdeib_trace_on;
   hr_utility.trace('leaving rebuild_ele_input_bal ' || p_leg_code ||
                 ' worker: ' || to_char(p_worker_id + 1) || '/' ||
                 to_char(p_maxworkers));
   hrrbdeib_trace_off;
   --
exception
   when others then
     hrrbdeib_trace_on;
     hr_utility.trace('exception in rebuild_ele_input_bal ' || p_leg_code ||
                 ' worker: ' || to_char(p_worker_id + 1) || '/' ||
                 to_char(p_maxworkers));
     hrrbdeib_trace_off;
     --
     if csr_affected_fdiu_rows%isopen then
       close  csr_affected_fdiu_rows;
     end if;
     --
     insert_mthread_pps_err(p_worker_id, p_leg_code);
     -- re-enable any disabled triggers
     enable_ffue_cascade_trig;
     enable_refbal_trig;
     raise; -- reraise the exception
--
end rebuild_ele_input_bal;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                     delete_grade_spine_dict                            +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME
      delete_grade_spine_dict - delete the grade rate items from the data
                                dictionary
--
DESCRIPTION
*/
procedure delete_grade_spine_dict
(
    p_rate_id       in number
) is
--
BEGIN
    DELETE FROM ff_user_entities
    WHERE  creator_id    = p_rate_id
    AND    creator_type  = 'G';
end delete_grade_spine_dict;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                      create_grade_spine_dict                           +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
/*
   NAME
      create_grade_spine_dict - create grade/ spine rate database items
--
   DESCRIPTION
      This procedure is the main entry point for creating database items for
      either grades or spines. The routes must have already been defined in the
      database (in table ff_routes).  The procedure will search for the
      routes in this table by using the route name, which is hard coded below.
      The procedure processes each route in turn, creating a user entity and
      route parameter values, and then inserting each database items for that
      particular route.
      The database items created use the rate name. This routine
      generates the following database items for grades:
      --
      GRADE_<NAME>_VALUE
      GRADE_<NAME>_MINIMUM
      GRADE_<NAME>_MAXIMUM
      --
      For spines the following database item is generated:
      --
      SPINE_<NAME>_VALUE
*/
procedure create_grade_spine_dict
(
    p_rate_id       in number
) is
l_grade_route_name    varchar2(50) := 'GRADE_RATE_ROUTE';
l_spine_route_name    varchar2(50) := 'SPINE_RATE_ROUTE';
l_rate_type           pay_rates.rate_type%type;
l_name                pay_rates.name%type;
l_business_group_id   number;
l_created_by          number;
l_last_login          number;
l_record_inserted     boolean;
--
------------------------- create_grade_spine_dict -------------------------
--
BEGIN
    --
    -- find out if its a grade or spine that needs to be created:
    --
    select rate_type,
           replace (ltrim (rtrim (upper (name))), ' ', '_'),
           business_group_id,
           created_by,
           last_update_login
    into   l_rate_type,
           l_name,
           l_business_group_id,
           l_created_by,
           l_last_login
    from   pay_rates
    where  rate_id = p_rate_id;
    --
    if (l_rate_type = 'G') then          -- grade
        --
        -- create the user entity for the grade rate route
        --
        insert_user_entity (l_grade_route_name,
                            'GRADE_' || l_name,
                            'entity for '|| l_grade_route_name,
                            'Y',                -- not found allowed flag
                            'G',
                            p_rate_id,
                            l_business_group_id,
                            null,               -- null legislation code
                            l_created_by,
                            l_last_login,
                            l_record_inserted);
        --
        -- only insert parameter values/database items if entity was inserted
        --
        IF l_record_inserted THEN
            --
            -- insert the rate id for the where clause filler
            --
            insert_parameter_value (p_rate_id, 1);
            --
            l_name := 'GRADE_' || l_name;
            --
            -- load up the database items for the grade rate route:
            --
            insert_database_item (l_name,
                              'VALUE',
                              'T',                       -- data type
                              'GRULE.value',
                              'Y',                       -- null allowed
                              'value for grade rates');
            --
            insert_database_item (l_name,
                              'MINIMUM',
                              'T',                       -- data type
                              'GRULE.minimum',
                              'Y',                       -- null allowed
                              'minimum value for grade rates');
            --
            insert_database_item (l_name,
                              'MAXIMUM',
                              'T',                       -- data type
                              'GRULE.maximum',
                              'Y',                       -- null allowed
                              'maximum value for grade rates');
        END IF;
    else                                  -- a spine rate
        --
        -- create the user entity for the spine rate route
        --
        insert_user_entity (l_spine_route_name,
                            'SPINE_' || l_name,
                            'entity for '|| l_spine_route_name,
                            'Y',                -- not found allowed flag
                            'G',
                            p_rate_id,
                            l_business_group_id,
                            null,               -- null legislation code
                            l_created_by,
                            l_last_login,
                            l_record_inserted);
        --
        -- only insert parameter values/database items if entity was inserted
        --
        IF l_record_inserted THEN
            --
            -- insert the rate id for the where clause filler
            --
            insert_parameter_value (p_rate_id, 1);
            --
            l_name := 'SPINE_' || l_name;
            --
            -- load up the database items for the grade rate route:
            --
            insert_database_item (l_name,
                              'VALUE',
                              'T',                       -- data type
                              'target.value',
                              'Y',                       -- null allowed
                              'value for spine rates');
        END IF;
    end if;
end create_grade_spine_dict;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                     refresh_grade_spine_rates                          +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME
    refresh_grade_spine_rates  - create DB items for grade and spine rates
--
DESCRIPTION
    This routine creates all database items based on grade and spine rates
    in the system. The routine assumes that no such database items currently
    exist.
*/
procedure refresh_grade_spine_rates is
   cursor c1 is select rate_id
                from   pay_rates r
                where not exists (select null from ff_user_entities u
                   where u.creator_id = r.rate_id
                   and   u.creator_type = 'G');
begin
   for c1rec in c1 loop
       hrrbdeib_trace_on;
       hr_utility.trace ('creating database item grade/ spine rate id: '||
                                          to_char (c1rec.rate_id));
       hrrbdeib_trace_off;
       create_grade_spine_dict (c1rec.rate_id);
   end loop;
end refresh_grade_spine_rates;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                        delete_grade_spine_rates                        +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME
    delete_grade_spine_rates  - delete DB items for grade and spine rates
--
DESCRIPTION
    This routine deletes all database items based on grade or spine rates
    in the system. The routine assumes that no such database items currently
    exist.
*/
procedure delete_grade_spine_rates is
   cursor c1 is select rate_id
                from   pay_rates;
begin
   --
   -- delete the grade/ spine rates
   --
   for c1rec in c1 loop
       hrrbdeib_trace_on;
       hr_utility.trace ('deleting database item grade/ spine rate id: '||
                                          to_char (c1rec.rate_id));
       hrrbdeib_trace_off;
       delete_grade_spine_dict (c1rec.rate_id);
   end loop;
end delete_grade_spine_rates;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                     delete_flexfield_dict                              +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME
      delete_flexfield_dict - delete a descriptive flexfield in the
                              data dictionary
--
DESCRIPTION
      This procedure is the main entry point for deleting descriptive
      flexfield database items.  To delete all the descriptive flexfield
      database items for a given legislation code, pass the title parameter
      as '%'. To delete an individual  descriptive flexfield pass the title
      of the flexfield.
NOTES
      Since the legislation code for a descriptive flexfield could be null
      a nvl function is required as part of the SQL statement.
*/
procedure delete_flexfield_dict
(
    p_title       in varchar2,
    p_context     in varchar2,
    p_leg_code    in varchar2
) is
l_entity_name     ff_user_entities.user_entity_name%type;
BEGIN
    if (p_title   = '%') and
       (p_context = '%') then  -- delete all descriptive flexfield DB items
        --
        -- first delete any complied formula references
        --
        delete_compiled_formula (null,
                                 'DF',
                                 '%',
                                 p_leg_code);
        --
        -- now delete the actual database items
        --
        delete from ff_user_entities
        where  creator_type                 = 'DF'
        and    nvl (legislation_code, ' ')  = nvl (p_leg_code, ' ');
        --
    else                    -- delete selected DB items
        --
        -- assemble the entity name:
        --
        l_entity_name := replace (replace (ltrim(rtrim(upper(p_title))),' ','_'),'''','')
                         ||'_'|| replace (ltrim(rtrim(upper(p_context))),' ','_');
        l_entity_name := l_entity_name || '_DF%';
        --
        -- first delete any complied formula references
        --
        delete_compiled_formula (null,
                                 'DF',
                                 l_entity_name,
                                 p_leg_code);
        --
        -- now delete the actual database items
        --
        delete from ff_user_entities
        where  creator_type             = 'DF'
        and    user_entity_name      like l_entity_name
        and    nvl (legislation_code, ' ')  = nvl (p_leg_code, ' ');
    end if;
end delete_flexfield_dict;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                         create_desc_flex                               +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      create_desc_flex - General routine to create Descriptive flexs.  Called
                         from the main Descriptive flexfield DB item generation
                         procedures.
--
   DESCRIPTION
      This procedure creates Descriptive flexfield DB items, and is responsible
      for creating the user entities for a particular flexfield.  For the
      given flexfield there could be several contexts that apply to several
      flexfield segment names.  Hence two cursor loops are used to generate
      the database items, the outer one to select the context
      and the inner one to select the column names.
*/
--
-- This create_desc_flex() does not accept business_group_id for context
-- sensitive db_item generation.
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
) is
BEGIN
   create_desc_flex_main( p_title,
                          p_table_name,
                          p_route_name,
                          p_entity_name,
                          p_context,
                          p_global_flag,
                          p_param_value,
                          p_leg_code,
                          p_business_group_id => NULL );
END create_desc_flex;
--
-- This create_desc_flex() accepts business_group_id for context
-- sensitive db_item generation.
--
procedure create_desc_flex
(
    p_title             in varchar2,
    p_table_name        in varchar2,
    p_route_name        in varchar2,
    p_entity_name       in varchar2,
    p_context           in varchar2,
    p_global_flag       in varchar2,
    p_param_value       in varchar2,
    p_leg_code          in varchar2,
    p_business_group_id in varchar2
) is
BEGIN
   create_desc_flex_main( p_title,
                          p_table_name,
                          p_route_name,
                          p_entity_name,
                          p_context,
                          p_global_flag,
                          p_param_value,
                          p_leg_code,
                          p_business_group_id );
END create_desc_flex;
--
-- Main create_desc_flex() procedure
--
procedure create_desc_flex_main
(
    p_title             in varchar2,
    p_table_name        in varchar2,
    p_route_name        in varchar2,
    p_entity_name       in varchar2,
    p_context           in varchar2,
    p_global_flag       in varchar2,
    p_param_value       in varchar2,
    p_leg_code          in varchar2,
    p_business_group_id in varchar2
) is
l_param_value         ff_route_parameter_values.value%type;
l_dbitem_found        boolean;
l_entity_name         ff_user_entities.user_entity_name%type;
l_created_by          number;
l_last_login          number;
l_record_inserted     boolean;
l_user_entity_id      number;
--
--
begin
   for c1rec in dflex_c1 (p_table_name,
                          p_title,
                          p_global_flag,
                          p_context) loop

       l_dbitem_found := FALSE;
       --
       -- now create the database items
       --
       for c2rec in dflex_c2 (c1rec.c_flex_name,
                              p_context) loop
           --
           -- only create a user entity if database items are to be created.
           --
           if (l_dbitem_found = FALSE) then
               l_dbitem_found := TRUE;
               --
               -- delete any old descriptive flex DB items of the same name:
               --
               delete_flexfield_dict (p_title,
                                      p_context,
                                      p_leg_code);
               --
               -- create a user entity, first construct the entity name:
               -- (note: the c1 cursor perform the upper functions, etc. for
               -- the title name).
               --
               l_entity_name := c1rec.c_title || '_' ||
                              replace (ltrim(rtrim(upper(p_context))),' ','_');
               --
               l_created_by := c1rec.c_created_by;
               l_last_login := c1rec.c_last_login;
               --
               insert_user_entity (p_route_name,
                                   l_entity_name || '_DF',
                                   'entity for '|| p_route_name,
                                   'Y',
                                   'DF',
                                   null,        -- null creator id
                                   p_business_group_id,
                                   p_leg_code,
                                   l_created_by,
                                   l_last_login,
                                   l_record_inserted);
               --
               -- only insert parameter values/database items if entity
               -- was inserted
               --
               IF l_record_inserted THEN
                  --
                  -- if we are creating certain Developer DF DB items then we
                  -- need to insert the type context into the route parameter
                  -- value table.
                  --
                  if (p_route_name = 'DEVELOPER_ORG_DESC_FLEX_ROUTE') OR
                     (p_route_name = 'LEGAL_CO_DESC_FLEX_ROUTE')      OR
                     (p_route_name = 'DEVELOPER_ASS_DESC_FLEX_ROUTE') OR
                     (p_route_name = 'DEVELOPER_LOC_DESC_FLEX_ROUTE') OR
                     (p_route_name = 'DEVELOPER_POS_DESC_FLEX_ROUTE') OR
                     (p_route_name = 'DEVELOPER_PER_DESC_FLEX_ROUTE') then
                      --
                      -- note: fast formula requires the quotes for a text
                      -- string to be in the parameter value table, as opposed
                      -- to in the route.
                         --
                      l_param_value := '''' ||
                        replace (ltrim(rtrim(p_param_value)),' ','_') || '''';
                      insert_parameter_value (l_param_value, 1);
                      --
                  elsif (p_route_name = 'ENTRY_DESC_FLEX_ROUTE') then
                      -- Different insert for the Entry DDF as the
                      -- space replacement is not required
                      l_param_value := '''' ||
                                          ltrim(rtrim(p_param_value)) || '''';
                      insert_parameter_value (l_param_value, 1);

                  elsif (p_route_name = 'ORG_PAY_METHOD_DESC_FLEX_ROUTE') then
                      insert_parameter_value (p_param_value, 1);
                      --
                      --  We create the CURRENCY_CODE database item here
                      --  as the above delete_flexfield_dict will have
                      --  removed it if it had been delivered earlier.
                      --
                      insert_database_item (p_entity_name,
                                            'CURRENCY_CODE',
                                            'T',                -- data type
                                            'target.currency_code',
                                            'N',                -- null allowed
                                            'database item for : ' ||
                                                       p_entity_name);
                  elsif (p_route_name = 'PAY_FURTHER_PPM_DESC_FLEX_ROUTE') then
                      insert_database_item (p_entity_name,
                                            'CURRENCY_CODE',
                                            'T',                -- data type
                                            'target.currency_code',
                                            'N',                -- null allowed
                                            'database item for : ' ||
                                                       p_entity_name);
		  elsif (p_route_name is not null
                         and p_param_value is not null) then
                      --
                      -- create a parameter value if a route uses a parameter.
                      --
                      insert_parameter_value (p_param_value, 1);
                      --
		  end if;
               ELSE
                select user_entity_id
                into l_user_entity_id
                from ff_user_entities
                where  user_entity_name=l_entity_name || '_DF'
                and nvl(legislation_code,'X')=nvl(p_leg_code,'X')
                and nvl(business_group_id,-1)=nvl(p_business_group_id,-1);
               END IF;
           end if;
           --
           insert_database_item (p_entity_name,
                                 c2rec.c_db_name,
                                 'T',                           -- data type
                                 'target.' || c2rec.c_def_text,
                                 'Y',                           -- null allowed
                                 'database item for : ' || p_entity_name,
                                 l_user_entity_id);
       end loop;  -- dflex_c2 loop
   end loop;  -- dflex_c1 loop
end create_desc_flex_main;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                       get_legislation_code                             +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--
-- This private function is used to get the legislation code for the Developer
-- Descriptive flex context as specified in the Information type tables.
-- This function returns 'M' if the flex context allows multiple occurrences.
--
function get_legislation_code
  (p_flexfield_name in varchar2
  ,p_context        in varchar2)
  return varchar2 is
--
l_legislation_code    hr_org_information_types.legislation_code%type;
l_navigation_method   hr_org_information_types.navigation_method%type;
l_multi_occur_flag    per_assignment_info_types.multiple_occurences_flag%type;
--
begin
    --
    --
    if (p_flexfield_name in  ('Person Developer DF',
                              'Payroll Developer DF',
                              'Element Entry Developer DF',
                              'Job Developer DF')) then
        --
        l_legislation_code := p_context;
        --
    elsif (p_flexfield_name = 'Org Developer DF') then -- Organization DF
        --
        -- get the legislation code
        --
        select legislation_code,
               navigation_method
        into   l_legislation_code,
               l_navigation_method
        from   hr_org_information_types
        where  org_information_type = p_context;
        --
        -- The database item generated can only return one row. So if the
        -- navigation method is not 'GS' then raise an error.
        --
        if (l_navigation_method <> 'GS') then
            --
            return 'M';
            --
        end if;
        --
    elsif (p_flexfield_name = 'Assignment Developer DF') then
        --
        -- get the legislation code
        --
        select legislation_code,
               multiple_occurences_flag
        into   l_legislation_code,
               l_multi_occur_flag
        from   per_assignment_info_types
        where  information_type           = p_context;
        --
        -- The database item generated can only return one row. So if the
        -- multiple occurrences flag is not 'N' then raise an error.
        --
        if (l_multi_occur_flag <> 'N') then
            --
            return 'M';
            --
        end if;
        --
    elsif (p_flexfield_name = 'Extra Location Info DDF') then
        --
        -- get the legislation code:
        --
        select legislation_code,
               multiple_occurences_flag
        into   l_legislation_code,
               l_multi_occur_flag
        from   hr_location_info_types
        where  information_type           = p_context;
        --
        -- The database item generated can only return one row. So if the
        -- multiple occurrences flag is not 'N' then raise an error.
        --
        if (l_multi_occur_flag <> 'N') then
            --
            return 'M';
            --
        end if;
        --
    elsif (p_flexfield_name = 'Extra Position Info DDF') then
        --
        -- get the legislation code:
        --
        select legislation_code,
               multiple_occurences_flag
        into   l_legislation_code,
               l_multi_occur_flag
        from   per_position_info_types
        where  information_type           = p_context;
        --
        -- The database item generated can only return one row. So if the
        -- multiple occurrences flag is not 'N' then raise an error.
        --
        if (l_multi_occur_flag <> 'N') then
            --
            return 'M';
            --
        end if;
        --
    elsif (p_flexfield_name = 'Extra Person Info DDF') then
        --
        -- get the legislation code:
        --
        select legislation_code,
               multiple_occurences_flag
        into   l_legislation_code,
               l_multi_occur_flag
        from   per_people_info_types
        where  information_type           = p_context;
        --
        -- The database item generated can only return one row. So if the
        -- multiple occurrences flag is not 'N' then raise an error.
        --
        if (l_multi_occur_flag <> 'N') then
            --
            return 'M';
            --
        end if;
        --
    end if;
    --
    --
    return l_legislation_code;
    --
end get_legislation_code;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                       create_flexfield_dict                            +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      create_flexfield_dict - create descriptive flexfield database items
--
   DESCRIPTION
      This procedure is the main entry point for creating descriptive
      flexfield database items.  The title of the descriptive flex is passed to
      this routine as a parameter.  To create all the descriptive flexfield
      database items for a particular application pass the title parameter
      as '%'
      --
      The database items created use the name as defined in the column
      'end_user_column_name' from the foundation table
      'fnd_descr_flex_column_usages'.  For a given descriptive flexfield there
      could be several database items.
      --
   NOTES
      Since there is no desciptive flex id to identify an individual row in
      the ff_user_entities table, the title of the descriptive flex is used
      instead, holding it in the user_entity_name column.
      --
      It is intended that this flexfield creation procedure be run from the
      Standard Report Submission (SRS) form.
*/
procedure create_flexfield_dict
(
    p_title       in varchar2
) is
-- declare a cursor to determine the routes to a descriptive flexfields'
-- tables and an entity name for each of these tables.
--
cursor routes_c is
    select df.application_table_name,
           rtd.route_name,
           rtd.user_key
    from   fnd_descriptive_flexs_vl    df,
           pay_route_to_descr_flexs   rtd
    where  df.application_id = rtd.application_id
    and    df.descriptive_flexfield_name = rtd.descriptive_flexfield_name
    and    replace (ltrim (rtrim(df.title)), '''','') = p_title;
--
-- declare a cursor to determine all the business_group_id's that any
-- context descriptive flexfield elements are sensitive to.
--
cursor bgrp_c (p_table_name varchar2) is
    select dfc.descriptive_flex_context_code bus_grp_id
    from   fnd_descr_flex_contexts  dfc,
           fnd_descriptive_flexs_vl df
    where  dfc.application_id = df.application_id
    and    dfc.descriptive_flexfield_name = df.descriptive_flexfield_name
    and    df.application_table_name = p_table_name
    and    replace (ltrim (rtrim(df.title)), '''','') = p_title
    and    df.default_context_field_name = 'BUSINESS_GROUP_ID'
    and    dfc.enabled_flag = 'Y'
    and    dfc.global_flag = 'N';
--
BEGIN
    for routes_crec in routes_c loop

        create_desc_flex (p_title,
                          routes_crec.application_table_name,
                          routes_crec.route_name,
                          routes_crec.user_key,
                          'Global Data Elements', -- context
                          'Y',                    -- global flag
                          null,                   -- no route parameters
                          null);                  -- legislation code
        --
        -- Now create business_group_id context dbitems
        --
        for bgrp_crec in bgrp_c(routes_crec.application_table_name) loop
            create_desc_flex (p_title,
                              routes_crec.application_table_name,
                              routes_crec.route_name,
                              routes_crec.user_key,
                              bgrp_crec.bus_grp_id,   -- context
                              'N',                    -- global flag
                              null,                   -- no route params
                              null,                   -- legislation code
                              bgrp_crec.bus_grp_id);  -- business group id
        end loop; -- bgrp_c loop

    end loop; -- routes_crec
end create_flexfield_dict;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                   create_dev_desc_flex_dict                            +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      create_dev_desc_flex_dict - create developer descriptive flexfield
                                  database items
--
   DESCRIPTION
      This procedure is the main entry point for creating developer descriptive
      flexfield database items.  The parameters passed in are the
      title of the descriptive flex and the context.
      --
      The database items created use the name as defined in the column
      'end_user_column_name' from the foundation table
      'fnd_descr_flex_column_usages'.  For a given descriptive flexfield there
      could be several database items.
      --
      This same procedure is called by different reports:
      --
      Create Organization Developer Descriptive Flexfield
      Create Person Developer Descriptive Flexfield
      Create Job Developer Descriptive Flexfield
      --
      The differences that affect this procedure are outlined below:
      --
      For the Organization DF report, the passed in context is a valid
      organization information type.  In order to create a unique name the
      database item is named:
      --
      <CONTEXT>_ORG_<SEGMENT_NAME>
      --
      where <CONTEXT> is the passed in value, upper cased and spaces removed.
      --
      For the Person DF and the Job Developer Descriptive Flexfield
      report, the passed in context is the legislation code.
      In order to create a unique name the database item for the Person
      developer DF is:
      --
      PEOPLE_<LEGISLATION_CODE>_<SEGMENT_NAME>
      --
      and for the Job developer DF, it is name:
      --
      JOB_<LEGISLATION_CODE>_<SEGMENT_NAME>
      --
      where <LEGISLATION_CODE> is the passed in value of 'p_context'.
      --
      Code added to create dbitems for Extra Location Info DDF,
      Extra Position Info DDF and Extra Person Info DDF.  The
      context passed for these 3 flexfields is the appropriate
      information type.
   NOTES
      Since there is no desciptive flex id to identify an individual row in
      the ff_user_entities table, the title of the descriptive flex is used
      instead, holding it in the user_entity_name column.
      --
      It is intended that this flexfield creation procedure be run from the
      Standard Report Submission (SRS) form.
*/
procedure create_dev_desc_flex_dict
(
    p_title       in varchar2,
    p_context     in varchar2
) is
l_flexfield_name      fnd_descriptive_flexs_vl.descriptive_flexfield_name%type;
l_legislation_code    hr_org_information_types.legislation_code%type;
l_context             hr_org_information_types.org_information_type%type;
l_navigation_method   hr_org_information_types.navigation_method%type;
l_multi_occur_flag    per_assignment_info_types.multiple_occurences_flag%type;
--
-- declare a cursor to determine the routes to a descriptive flexfield's
-- tables and an entity name for each of these tables.
--
cursor c_routes is
    select df.application_table_name,
           rtd.route_name,
           rtd.user_key
    from   fnd_descriptive_flexs_vl df,
           pay_route_to_descr_flexs rtd
    where  df.application_id = rtd.application_id
    and    df.descriptive_flexfield_name = rtd.descriptive_flexfield_name
    and    replace (ltrim (rtrim(df.title)), '''','') = p_title
    and    rtd.descriptive_flex_context_code = p_context;
--
-- declare a cursor to check whether the route uses a parameter
--
cursor c_chk_route_parameter (p_route_name varchar2) is
    select data_type
    from   ff_route_parameters rpm, ff_routes rt
    where  rt.route_name = p_route_name
    and    rpm.route_id  = rt.route_id;

l_routes            c_routes%rowtype;
l_routes_count      number := 0;
l_parameter_type    varchar2(1);
l_entity_name       varchar2(80);
l_parameter_value   ff_route_parameter_values.value%type;
--
---------------------- create_dev_desc_flex_dict  -------------------------
--
BEGIN
  --
  select descriptive_flexfield_name
  into   l_flexfield_name
  from   fnd_descriptive_flexs_vl
  where  title           = p_title
  and    application_id  between 800 and 801;
  --
  l_legislation_code := get_legislation_code(l_flexfield_name, p_context);
  --
  -- Create the DB items only if the context allows single occurrence
  --
  if nvl(l_legislation_code,'N') <> 'M' then
  --
  -- Bug 2637573 - Code added to check if any Developer DF contexts are
  -- seeded. If yes, then the DB items are created using the routes in
  -- table pay_route_to_descr_flexs.
  --
    open c_routes;
    loop
      --
      fetch c_routes into l_routes;
      l_routes_count := c_routes%rowcount;
      --
      exit when c_routes%notfound;
      --
      open c_chk_route_parameter(l_routes.route_name);
      fetch c_chk_route_parameter into l_parameter_type;
      --
      if c_chk_route_parameter%found then
        if (l_parameter_type = 'T') then
          l_parameter_value := '''' || p_context || '''';
        else
          l_parameter_value := p_context;
        end if;
      end if;
      --
      close c_chk_route_parameter;
      --
      l_entity_name := replace (ltrim(rtrim(upper(l_flexfield_name))),' ','_')
                       ||'_'||l_routes.user_key;
      --
      create_desc_flex (p_title,
                        l_routes.application_table_name,
                        l_routes.route_name,
                        l_entity_name,
                        p_context,                      -- context
                        'N',                            -- global flag
                        l_parameter_value,              -- route parameter
                        l_legislation_code);            -- legislation_code
      --
    end Loop;
    close c_routes;
    --
  end if;
  --
  -- If no Developer DF contexts are seeded then DB items areccreated using the
  -- regular method.
  --
  If l_routes_count = 0 then
    --
    -- find out which report called this routine, either the Organization
    -- DF, the person developer DF or the job developer DF.
    --
    if (l_flexfield_name = 'Person Developer DF') then
        create_desc_flex (p_title,
                          'PER_ALL_PEOPLE_F',
                          'PEOPLE_FLEXFIELD_ROUTE',
                          'PEOPLE_' || p_context,
                          p_context,                 -- the context name
                          'N',                       -- global flag
                          null,                      -- no route parameters
                          p_context);                -- legislation code
        --
    elsif (l_flexfield_name = 'Org Developer DF') then -- Organization DF
        --
        -- get the legislation code
        --
        select legislation_code,
               navigation_method
        into   l_legislation_code,
               l_navigation_method
        from   hr_org_information_types
        where  org_information_type = p_context;
        --
        -- this check to see if the navigation_method is 'GS' is also
        -- performed in the concurrent program.  It has been added here as
        -- well, in case this procedure is called directly, and to ensure that
        -- the database item generated can only return one row.
        --
        if (l_navigation_method = 'GS') then
            l_context := replace (ltrim (rtrim (upper (p_context))), ' ', '_');
            --
            create_desc_flex (p_title,
                              'HR_ORGANIZATION_INFORMATION',
                              'DEVELOPER_ORG_DESC_FLEX_ROUTE',
                              l_context || '_ORG',
                              p_context,            -- the context name
                              'N',                  -- global flag
                              p_context,            -- used for route parameter
                              l_legislation_code);  -- legislation code
            --
            -- see if any Legal Company Descriptive Flexs are to be created:
            --
            if ((l_legislation_code is null)
                or (l_legislation_code ='US')
                or (l_legislation_code ='CA')) then
                create_desc_flex (p_title,
                                  'HR_ORGANIZATION_INFORMATION',
                                  'LEGAL_CO_DESC_FLEX_ROUTE',
                                  'LC_' || l_context || '_ORG',
                                   p_context,            -- the context name
                                  'N',                   -- global flag
                                  p_context,        -- used for route parameter
                                  l_legislation_code);  -- legislation code
            end if;
	    --
        end if;
        --
    elsif (l_flexfield_name = 'Assignment Developer DF') then
        --
        -- get the legislation code:
        --
        select legislation_code,
               multiple_occurences_flag
        into   l_legislation_code,
               l_multi_occur_flag
        from   per_assignment_info_types
        where  information_type           = p_context;
        --
        -- this check to see if the multiple_occurences_flag is 'N' is also
        -- performed in the concurrent program.  It has been added here as
        -- well in case this procedure is called directly, and to ensure that
        -- the database item generated can only return one row.
        --
        if (l_multi_occur_flag = 'N') then
            l_context := replace (ltrim (rtrim (upper (p_context))), ' ', '_');
            --
            create_desc_flex (p_title,
                              'PER_ASSIGNMENT_EXTRA_INFO',
                              'DEVELOPER_ASS_DESC_FLEX_ROUTE',
                              l_context || '_ASG',
                              p_context,            -- the context name
                              'N',                  -- global flag
                              p_context,            -- used for route parameter
                              l_legislation_code);  -- legislation code
        end if;
--
    elsif (l_flexfield_name = 'Payroll Developer DF') then -- Payroll DDF
        create_desc_flex (p_title,
                          'PAY_ALL_PAYROLLS_F',
                          'PAYROLL_FLEXFIELD_ROUTE',
                          'PAY_' || p_context,
                          p_context,                 -- the context name
                          'N',                       -- global flag
                          null,                      -- no route parameters
                          p_context);                -- legislation code
--
    elsif (l_flexfield_name = 'Extra Location Info DDF') then
        --
        -- get the legislation code:
        --
        select legislation_code,
               multiple_occurences_flag
        into   l_legislation_code,
               l_multi_occur_flag
        from   hr_location_info_types
        where  information_type           = p_context;
        --
        -- this check to see if the multiple_occurences_flag is 'N' is also
        -- performed in the concurrent program.  It has been added here as
        -- well in case this procedure is called directly, and to ensure that
        -- the database item generated can only return one row.
        --
        if (l_multi_occur_flag = 'N') then
            l_context := replace (ltrim (rtrim (upper (p_context))), ' ', '_');
            --
            create_desc_flex (p_title,
                              'HR_LOCATION_EXTRA_INFO',
                              'DEVELOPER_LOC_DESC_FLEX_ROUTE',
                              l_context || '_LOC',
                              p_context,            -- the context name
                              'N',                  -- global flag
                              p_context,            -- used for route parameter
                              l_legislation_code);  -- legislation code
	end if;
--
    elsif (l_flexfield_name = 'Extra Position Info DDF') then
        --
        -- get the legislation code:
        --
        select legislation_code,
               multiple_occurences_flag
        into   l_legislation_code,
               l_multi_occur_flag
        from   per_position_info_types
        where  information_type           = p_context;
        --
        -- this check to see if the multiple_occurences_flag is 'N' is also
        -- performed in the concurrent program.  It has been added here as
        -- well in case this procedure is called directly, and to ensure that
        -- the database item generated can only return one row.
        --
        if (l_multi_occur_flag = 'N') then
            l_context := replace (ltrim (rtrim (upper (p_context))), ' ', '_');
            --
            create_desc_flex (p_title,
                              'PER_POSITION_EXTRA_INFO',
                              'DEVELOPER_POS_DESC_FLEX_ROUTE',
                              l_context || '_POS',
                              p_context,            -- the context name
                              'N',                  -- global flag
                              p_context,            -- used for route parameter
                              l_legislation_code);  -- legislation code
	end if;
--
    elsif (l_flexfield_name = 'Extra Person Info DDF') then
        --
        -- get the legislation code:
        --
        select legislation_code,
               multiple_occurences_flag
        into   l_legislation_code,
               l_multi_occur_flag
        from   per_people_info_types
        where  information_type           = p_context;
        --
        -- this check to see if the multiple_occurences_flag is 'N' is also
        -- performed in the concurrent program.  It has been added here as
        -- well in case this procedure is called directly, and to ensure that
        -- the database item generated can only return one row.
        --
        if (l_multi_occur_flag = 'N') then
            l_context := replace (ltrim (rtrim (upper (p_context))), ' ', '_');
            --
            create_desc_flex (p_title,
                              'PER_PEOPLE_EXTRA_INFO',
                              'DEVELOPER_PER_DESC_FLEX_ROUTE',
                              l_context || '_PER',
                              p_context,            -- the context name
                              'N',                  -- global flag
                              p_context,            -- used for route parameter
                              l_legislation_code);  -- legislation code
	end if;
--
    elsif (l_flexfield_name = 'Element Entry Developer DF') then
        create_desc_flex (p_title,
                          'PAY_ELEMENT_ENTRIES_F',
                          'ENTRY_DESC_FLEX_ROUTE',
                          'ENTRY_'|| replace(ltrim(rtrim(p_context)),' ','_'),
                          p_context,              -- the context name
                          'N',                    -- global flag
                          p_context,              -- used for route parameter
                          substrb(p_context,1,2));   -- legislation code
    else                       -- a job developer DF
        --
        -- A Job developer descriptive flex.  The 'p_context' parameter is a
        -- legislation code, which is used as the context code in the
        -- descriptive flex tables, and as part of the DB item name.
        --
        create_desc_flex (p_title,
                          'PER_JOBS',
                          'JOBS_DESC_FLEX_ROUTE',
                          'JOBS_' || p_context,
                          p_context,
                          'N',                        -- global flag
                          null,                       -- no route parameters
                          p_context);                 -- legislation code
    end if;
  --
  end if;
  --
end create_dev_desc_flex_dict;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                   create_org_pay_flex_dict                             +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      create_org_pay_flex_dict - Create Organization Payment descriptive
                                 flexfield database items
--
   DESCRIPTION
      This procedure is the main entry point for creating Organization
      Payment descriptive flexfield database items.  The parameters passed
      in are the payment type id.
      --
      The database items created use the name as defined in the column
      'end_user_column_name' from the foundation table
      'fnd_descr_flex_column_usages'.  For a given descriptive flexfield there
      could be several database items.
   NOTES
      Since there is no desciptive flex id to identify an individual row in
      the ff_user_entities table, the title of the descriptive flex is used
      instead, holding it in the user_entity_name column.

      Added rtrim to title select below, due to Reserved word problem, ie
      the title, in creating descriptive flex cannot contain full stops,
      eg 'Further Payment Info.' - this is a temporary measure.
*/
procedure create_org_pay_flex_dict
(
    p_payment_id  in number
) is
cursor get_title is
   select rtrim(title,'.') from fnd_descriptive_flexs_vl
   where descriptive_flexfield_name = 'Paymeth Developer DF';
--
l_context        pay_payment_types.payment_type_name%type;
l_context_upper  pay_payment_types.payment_type_name%type;
l_title          varchar2(80);
--
---------------------- create_org_pay_flex_dict  -------------------------
--
BEGIN
    --
    -- get the context
    --
    select payment_type_name
    into   l_context
    from   pay_payment_types
    where  payment_type_id   = p_payment_id;
    --
    open get_title;
    fetch get_title into l_title;
    close get_title;
    --
    l_context_upper := replace (ltrim (rtrim (upper (l_context))), ' ', '_');
    create_desc_flex (l_title,
                      'PAY_ORG_PAYMENT_METHODS_F',
                      'ORG_PAY_METHOD_DESC_FLEX_ROUTE',
                      l_context_upper,            -- used for entity name
                      l_context,                  -- the context name
                      'N',                        -- global flag
                      p_payment_id,               -- the route parameter
                      null);                      -- legislation code
end create_org_pay_flex_dict;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                   create_ppm_devdff_flex_dict                          +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      create_ppm_devdff_flex_dict - Create Further Personal Payment Method
                                    Info DFF database items
--
   DESCRIPTION
      This procedure is the main entry point for creating Further Personal
      Payment Method Info descriptive flexfield database items.  The parameters
      passed  in are the payment type id. Data base items will be created for
      the DFF with the payment type name as prefix.
      --
      The database items created use the name as defined in the column
      'end_user_column_name' from the foundation table
      'fnd_descr_flex_column_usages'.  For a given descriptive flexfield there
      could be several database items.
      DB Item Format : <Leg Code>_<Payment Type>_<end_user_column_name>
   NOTES
      Since there is no desciptive flex id to identify an individual row in
      the ff_user_entities table, the title of the descriptive flex is used
      instead, holding it in the user_entity_name column.

      Added rtrim to title select below, due to Reserved word problem, ie
      the title, in creating descriptive flex cannot contain full stops,
      eg 'Further Payment Info.' - this is a temporary measure.
      Added legislation code as well at the starting to figure the database
      items properly.
*/
--
procedure create_ppm_devdff_flex_dict
(
    p_payment_id in number
) is
  cursor get_title is
  select rtrim(title,'.') from fnd_descriptive_flexs_vl
   where descriptive_flexfield_name = 'Personal PayMeth Developer DF';

  l_context        pay_payment_types.payment_type_name%type;
  l_context_upper  pay_payment_types.payment_type_name%type;
  l_title          varchar2(80);

begin
    select nvl(territory_code, 'ZZ')||'_'||payment_type_name
    into   l_context
    from   pay_payment_types
    where  payment_type_id   = p_payment_id;
    --
    open get_title;
    fetch get_title into l_title;
    close get_title;
    --
    l_context_upper := replace (ltrim (rtrim (upper (l_context))), ' ', '_');
    create_desc_flex (l_title,
                      'PAY_PERSONAL_PAYMENT_METHODS_F',
                      'PAY_FURTHER_PPM_DESC_FLEX_ROUTE',
                      l_context_upper,            -- used for entity name
                      l_context,                  -- the context name
                      'N',                        -- global flag
                      p_payment_id,               -- the route parameter
                      null);                      -- legislation code
end create_ppm_devdff_flex_dict;
--
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                       create_absence_dict                              +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      create_absence_dict - create an absence database item in the dictionary
--
   DESCRIPTION
      This procedure is the main entry point for creating absence type
      database items.  The routes must have already been defined in the
      database (in table ff_routes).  The procedure will search for the
      routes in this table by using the route name, which is hard coded below.
      The database items use the absence type name.  The following
      database item is created:
      --
      <NAME>_CUM_BALANCE        -- sum of entry values for that absence type
*/
procedure create_absence_dict
(
    p_absence_type_id   in number
) is
l_route_name          varchar2(50) := 'ABSENCE_SUM_OF_ELEMENT_ENTRY_VALUES';
l_absence_name        per_absence_attendance_types.name%type;
l_business_group_id   number;
l_created_by          number;
l_last_login          number;
l_record_inserted     boolean;
--
------------------------- create_absence_dict -------------------------
--
BEGIN
    --
    -- get the absence type information
    --
    select replace (ltrim (rtrim (upper (name))), ' ', '_'),
           business_group_id,
           created_by,
           last_update_login
    into   l_absence_name,
           l_business_group_id,
           l_created_by,
           l_last_login
    from   per_absence_attendance_types
    where  absence_attendance_type_id    = p_absence_type_id;
    --
    -- create the user entity for the route
    --
    insert_user_entity (l_route_name,
                        l_absence_name,
                        'entity for '|| l_route_name,
                        'Y',                         -- not found allowed flag
                        'A',
                        p_absence_type_id,
                        l_business_group_id,
                        null,                        -- null legislation code
                        l_created_by,
                        l_last_login,
                        l_record_inserted);
    --
    -- only insert parameter values/database items if entity was inserted
    --
    IF l_record_inserted THEN
        --
        -- insert the absence type id for the where clause filler
        --
        insert_parameter_value (p_absence_type_id, 1);
        --
        -- load up the database item for the route:
        --
        insert_database_item (l_absence_name,
                          'CUM_BALANCE',
                          'N',                           -- data type
                          'sum (fnd_number.canonical_to_number(target.screen_entry_value))',
                          'Y',                           -- null allowed
              'cumulative balance of an absence type for a given assignment');
    END IF;
end create_absence_dict;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                        delete_absence_dict                             +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME
      delete_absence_dict - delete the absence DB items from the data
                            dictionary
--
DESCRIPTION
*/
procedure delete_absence_dict
(
    p_absence_type_id  in number
) is
--
BEGIN
    DELETE FROM ff_user_entities
    WHERE  creator_id    = p_absence_type_id
    AND    creator_type  = 'A';
end delete_absence_dict;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                        refresh_absence_types                           *
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME
    refresh_absence_types  - create DB items for all absence types
--
DESCRIPTION
    This routine creates all database items based on absence types
    in the system. The routine assumes that no such database items currently
    exist.
*/
procedure refresh_absence_types is
   cursor c1 is select absence_attendance_type_id type_id
                from   per_absence_attendance_types;
begin
   for c1rec in c1 loop
       hrrbdeib_trace_on;
       hr_utility.trace ('creating database item absence type id: '||
                                          to_char (c1rec.type_id));
       hrrbdeib_trace_off;
       create_absence_dict (c1rec.type_id);
   end loop;
end refresh_absence_types;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                        delete_absence_types                            +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
NAME
    delete_absence_types  - delete DB items for absence types
--
DESCRIPTION
    This routine deletes all database items based on absence types
    in the system. The routine assumes that no such database items currently
    exist.
*/
procedure delete_absence_types is
   cursor c1 is select absence_attendance_type_id type_id
                from   per_absence_attendance_types;
begin
   --
   -- delete the absence types
   --
   for c1rec in c1 loop
       hrrbdeib_trace_on;
       hr_utility.trace ('deleting database item absence type id: '||
                                          to_char (c1rec.type_id));
       hrrbdeib_trace_off;
       delete_absence_dict (c1rec.type_id);
   end loop;
end delete_absence_types;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                     delete_keyflex_dict                                +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      delete_keyflex_dict - delete a key flexfield in the data dictionary
--
   DESCRIPTION
      This procedure is the main entry point for deleting key
      flexfield database items.  The parameters passed in are the id flex num
      and the name of the key flexfield.
--
   NOTES
*/
procedure delete_keyflex_dict
(
    p_creator_id    in number,
    p_entity_name   in varchar2,
    p_leg_code      in varchar2,
    p_business_group_id in number
) is
l_entity_name     ff_user_entities.user_entity_name%type;
BEGIN
    l_entity_name := p_entity_name || '%';
    --
    -- delete any complied formula references
    --
   delete_compiled_formula (p_creator_id,
                            'KF',
                            l_entity_name,
                            p_leg_code);
    --
    -- now delete the actual database items
    --
    delete from ff_user_entities
    where creator_type        = 'KF'
    and   creator_id          = p_creator_id
    and   user_entity_name like l_entity_name
    and  ( nvl (legislation_code, ' ') = nvl (p_leg_code, ' ')        -- 6955080
        OR nvl (business_group_id, -1) = nvl (p_business_group_id, -1));
end delete_keyflex_dict;
--
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                         create_key_flex                                +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      create_key_flex - General procedure for creating Key flexfield DB items
--
   DESCRIPTION
      This procedure is responsible for creating the database items for a
      particular key flexfield.
--
   NOTES
      The parameter 'p_table_name' is the name of the table as referred to in
      the table alias of the route.
*/
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
) is
--
-- declare cursor for retrieving the actual column names:
--
cursor c1 is
SELECT  application_column_name c_def_text,
        replace (ltrim(rtrim(upper(segment_name))),' ','_') c_db_name
FROM    fnd_id_flex_segments
WHERE   application_id                = p_applic_id
AND     id_flex_num                   = p_id_flex_num
AND     id_flex_code                  = p_id_flex_code;
--
l_dbitem_found        boolean;
l_record_inserted     boolean;
l_user_entity_id      number;
l_created_by          number := 0;
l_last_login          number := 0;
--
------------------------- create_key_flex -------------------------
--
begin
   l_dbitem_found := FALSE;
   --
   for c1rec in c1 loop
       if (l_dbitem_found = FALSE) then
           l_dbitem_found := TRUE;
           --
           -- create a user entity only if database items exist.
           --
           insert_user_entity (p_route_name,
                               p_entity_name || '_KEY_FLEX_ENTITY',
                               'route for key flexfield : '|| p_route_name,
                               'Y',
                               'KF',
                               p_id_flex_num,
                               p_business_group,
                               p_leg_code,
                               l_created_by,
                               l_last_login,
                        l_record_inserted);
       end if;
       insert_database_item (p_entity_name,
                             c1rec.c_db_name,
                             'T',                           -- data type
                             p_table_name || '.' || c1rec.c_def_text,
                             'Y',                           -- null allowed
                             'database item for : ' || p_entity_name);
   end loop;  -- c1 loop
end create_key_flex;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                       create_keyflex_dict                              +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      create_keyflex_dict - create a key flexfield in the data dictionary
--
   DESCRIPTION
      This procedure is the main entry point for creating key
      flexfield database items.  The routes must have already been defined
      in the database (in table ff_routes).  The procedure will search for the
      routes in this table by using the route name, which is hard coded below.
      The parameters passed in are the business group id and the name of the
      key flexfield.  To create all the key flexfield database items for a
      particular business group pass the name parameter as '%'. To create an
      individual key flexfield the following key flexfields are supported:
      --
      JOB         for 'p_keyflex_name' pass in : 'JOB'
      POSITION    for 'p_keyflex_name' pass in : 'POS'
      GRADE       for 'p_keyflex_name' pass in : 'GRD'
      GROUP       for 'p_keyflex_name' pass in : 'GRP'
      --
      The database items use the segment name column from the foundation
      table 'fnd_id_flex_segments'.  For a given key flexfield there
      could be several database items.
      The following database items are created:
      --
      GRADE_KF_<NAME>
      JOB_KF_<NAME>
      POS_KF_<NAME>
      GROUP_KF_<NAME>
      --
      It is intended that this flexfield creation procedure be run from the
      Standard Report Submission (SRS) form.
*/
procedure create_keyflex_dict
(
    p_business_group_id  in number,
    p_keyflex_name       in varchar2
) is
l_legislation_code    varchar2(30);
l_grade_flex_num      number;
l_group_flex_num      number;
l_job_flex_num        number;
l_position_flex_num   number;
l_competence_flex_num number;
l_route_name          varchar2(50)  := 'KEY_FLEXFIELD_ROUTE';
--
------------------------- create_keyflex_dict -------------------------
--
BEGIN
    --
    -- select the id flex numbers for each of the key flexfields
    --
    select  grade_structure,
            people_group_structure,
            job_structure,
            position_structure,
            competence_structure,
            legislation_code
    into    l_grade_flex_num,
            l_group_flex_num,
            l_job_flex_num,
            l_position_flex_num,
            l_competence_flex_num,
            l_legislation_code
    from    per_business_groups_perf
    where   business_group_id     = p_business_group_id;
    --
    -- create each of the flexfields
    --
    if ('GRD' like p_keyflex_name) then     -- create grade keyflex
        --
        -- first delete key flexfields that were previously created
        --
        delete_keyflex_dict (l_grade_flex_num,
                             'GRADE_KF',
                             l_legislation_code,
                             p_business_group_id);
        --
        create_key_flex (800,
                         p_business_group_id,
                         l_grade_flex_num,
                         'GRD',
                         'GRADE_KF',
                         null,
                         l_route_name,
                         'GRADEF');           -- target table name
    end if;
    --
    if ('JOB' like p_keyflex_name) then       -- create job keyflex
        --
        -- first delete key flexfields that were previously created
        --
        delete_keyflex_dict (l_job_flex_num,
                             'JOB_KF',
                             l_legislation_code,
                             p_business_group_id);
        --
        create_key_flex (800,
                         p_business_group_id,
                         l_job_flex_num,
                         'JOB',
                         'JOB_KF',
                         null,
                         l_route_name,
                         'JOBDEF');           -- target table name
    end if;
    --
    if ('POS' like p_keyflex_name) then  -- create position keyflex
        --
        -- first delete key flexfields that were previously created
        --
        delete_keyflex_dict (l_position_flex_num,
                             'POS_KF',
                             l_legislation_code,
                             p_business_group_id);
        --
        create_key_flex (800,
                         p_business_group_id,
                         l_position_flex_num,
                         'POS',
                         'POS_KF',
                         null,
                         l_route_name,
                         'POSDEF');           -- target table name
    end if;
    --
    if ('GRP' like p_keyflex_name) then     -- create group keyflex
        --
        -- first delete key flexfields that were previously created
        --
        delete_keyflex_dict (l_group_flex_num,
                             'GROUP_KF',
                             l_legislation_code,
                             p_business_group_id);
        --
        create_key_flex (801,
                         p_business_group_id,
                         l_group_flex_num,
                         'GRP',
                         'GROUP_KF',
                         null,
                         l_route_name,
                         'PGROUP');           -- target table name
    end if;
    --
    if ('CMP' like p_keyflex_name) then     -- create group keyflex
        --
        -- first delete key flexfields that were previously created
        --
        delete_keyflex_dict (l_competence_flex_num,
                             'COMP_KF',
                             l_legislation_code,
                             p_business_group_id);
        --
        create_key_flex (800,
                         p_business_group_id,
                         l_competence_flex_num,
                         'CMP',
                         'COMP_KF',
                         null,
                         l_route_name,
                         'COMP');           -- target table name
    end if;
end create_keyflex_dict;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                    create_ext_acc_keyflex_dict                         +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      create_ext_acc_keyflex_dict - create a key flexfield for an External
                                    Account in the data dictionary
--
   DESCRIPTION
      This procedure is the main entry point for creating External Account Key
      flexfield database items.  The routes must have already been defined
      in the database (in table ff_routes).  The procedure will search for the
      routes in this table by using the route name, which is hard coded below.
      The parameter passed in is the id_flex_num of the keyflex.
      --
      The database items use the segment name column from the foundation
      table 'fnd_id_flex_segments'.  For a given key flexfield there
      could be several database items.
      --
      The routine has been enhanced to loop around to create dbitems
      for each of the legislations which use the flex_num passed in.
*/
procedure create_ext_acc_keyflex_dict
(
    p_id_flex_num  in number
) is
--
-- declare cursor 1 for retrieving each legislation using this flex num
--
cursor c1 is
select legislation_code
from   pay_legislation_rules
where  rule_type = 'E'
and    rule_mode = to_char (p_id_flex_num);
--
l_legislation_code    pay_legislation_rules.legislation_code%type;
l_route_name          varchar2(50)  := 'EXT_ACCOUNT_ORG_KEYFLEX_ROUTE';
--
----------------------- create_ext_acc_keyflex_dict -------------------------
--
BEGIN
    --
    -- get each legislation code
    --
    --
    for c1rec in c1 loop
       --
       l_legislation_code := c1rec.legislation_code;
       --
       -- delete key flexfields that were previously created
       --
       delete_keyflex_dict (p_id_flex_num,
                            'ORG_' || l_legislation_code,
                            l_legislation_code,
                            null);
       --
       -- create the Organization External Account Keyflex
       --
       create_key_flex (801,
                        null,                       -- business group id
                        p_id_flex_num,
                        'BANK',
                        'ORG_' || l_legislation_code,
                        l_legislation_code,
                        l_route_name,
                        'target');                  -- target table name
       --
       -- delete key flexfields that were previously created
       --
       delete_keyflex_dict (p_id_flex_num,
                            'PER_' || l_legislation_code,
                            l_legislation_code,
                            null);
       --
       -- create the Personal External Account Keyflex
       --
       l_route_name := 'EXT_ACCOUNT_PER_KEYFLEX_ROUTE';
       --
       create_key_flex (801,
                        null,                       -- business group id
                        p_id_flex_num,
                        'BANK',
                        'PER_' || l_legislation_code,
                        l_legislation_code,
                        l_route_name,
                        'target');                  -- target table name
       --
    end loop; -- c1 loop
end create_ext_acc_keyflex_dict;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                   create_scl_flex_dict                                 +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      create_scl_flex_dict - create Soft Coded Legislation Keyflex DB items
--
   DESCRIPTION
      This procedure is the main entry point for creating Soft Coded
      Legislation Keyflex database items.  The parameter passed is is the
      id flex number.
      --
      The database items created use the name as defined in the column
      'segment_name' from the foundation table 'fnd_id_flex_segments'.
      There are 3 levels of SCL keyflex:
      --
      ASSIGNMENT
      PAYROLL
      ORGANIZATION
      --
      The routine loops through and generates DB items for each level.
      For a given SCL flexfield there could be several database items.
      --
      The routine has been enhanced to loop around to create dbitems
      for each of the legislations which use the flex_num passed in.
   NOTES
      It is intended that this  creation procedure be run from the
      Standard Report Submission (SRS) form.
*/
procedure create_scl_flex_dict
(
    p_id_flex_num in number
) is
--
-- declare cursor 0 for retrieving each legislation using this flex num
--
cursor c0 is
select legislation_code
from   pay_legislation_rules
where  rule_type = 'S'
and    rule_mode = to_char (p_id_flex_num);
l_created_by          number;
l_last_login          number;
l_legislation_code    pay_legislation_rules.legislation_code%type;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                         create_scl_flex                                +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      create_scl_flex - called from procedure create_scl_flex_dict
--
   DESCRIPTION
      This procedure is called from create_scl_flex_dict, and is responsible
      for creating the user entity and database items for a particular SCL
      flexfield.
*/
procedure create_scl_flex
(
    p_id_flex_num     in number,
    p_leg_code        in varchar2,
    p_route_name      in varchar2,
    p_entity_name     in varchar2,
    p_attribute_type  in varchar2
) is
--
-- declare cursor 1 for retrieving the segment names and target columns
--
cursor c1 is
select SEG.application_column_name     c_def_text,
       replace (ltrim(rtrim(upper(SEG.segment_name))),' ','_') c_db_name,
       SEG.created_by                  c_created_by,
       SEG.last_update_login           c_last_login
from   fnd_id_flex_segments            SEG
,      fnd_segment_attribute_values    VALUE
where  SEG.application_id            = 800
and    SEG.id_flex_code              = 'SCL'
and    SEG.id_flex_num               = p_id_flex_num
and    SEG.enabled_flag              = 'Y'
and    VALUE.application_column_name = SEG.application_column_name
and    VALUE.id_flex_code            = 'SCL'
and    VALUE.id_flex_num             = p_id_flex_num
and    VALUE.segment_attribute_type  = p_attribute_type
and    VALUE.attribute_value         = 'Y';
--
l_user_entity_id   number;
l_db_item_exist    boolean;
l_record_inserted     boolean;
begin
    l_db_item_exist := false;
    for c1rec in c1 loop
        if (l_db_item_exist = false) then  -- first time through loop
            --
            -- create a user entity
            --
            l_created_by := c1rec.c_created_by;
            l_last_login := c1rec.c_last_login;
            --
            hrrbdeib_trace_on;
            hr_utility.trace ('creating SCL flex entity for '|| p_entity_name);
            hrrbdeib_trace_off;
            insert_user_entity (p_route_name,
                                p_entity_name,
                                'route for SCL level : '|| p_attribute_type,
                                'Y',
                                'KF',
                                p_id_flex_num,
                                null,               -- null business group id
                                p_leg_code,
                                l_created_by,
                                l_last_login,
                                l_record_inserted);
            --
            -- only insert parameter values/database items if entity
            -- was inserted
            --
            IF l_record_inserted THEN
                --
                -- insert the id flex num for the where clause filler
                --
                insert_parameter_value (p_id_flex_num, 1);
                l_db_item_exist := true;
            END IF;
        end if;
        --
        -- now create the database item
        --
        insert_database_item (p_entity_name,
                              c1rec.c_db_name,
                              'T',                           -- data type
                              'target.' || c1rec.c_def_text,
                              'Y',                           -- null allowed
                              'database item for : ' || p_entity_name);
    end loop;  -- c1 loop
end create_scl_flex;
--
---------------------- create_scl_flex_dict  -------------------------
--
BEGIN
    --
    -- get each legislation code
    --
    --
    for c0rec in c0 loop
        --
        l_legislation_code := c0rec.legislation_code;
        --
        -- delete any old SCL keyflex DB items that were created with the same id
        --
        delete_keyflex_dict (p_id_flex_num,
                             'SCL',
                             l_legislation_code,
                             null);

        --
        -- delete user entities (and dbitems) owned by a user entity
        -- for an old value of the S leg rule
        --
        delete from ff_user_entities
        where creator_type        = 'KF'
        and   creator_id          <> p_id_flex_num
        and   user_entity_name like 'SCL%'
        and   nvl (legislation_code, ' ') = nvl (l_legislation_code, ' ')
        and   business_group_id is null;

        --
        -- generate DB items for the 3 levels of SCL:
        --
        create_scl_flex (p_id_flex_num,
                         l_legislation_code,
                         'SCL_ASS_FLEX_ROUTE',
                         'SCL_ASG_' || l_legislation_code,
                         'ASSIGNMENT');
        --
        create_scl_flex (p_id_flex_num,
                         l_legislation_code,
                         'SCL_PAY_FLEX_ROUTE',
                         'SCL_PAY_' || l_legislation_code,
                         'PAYROLL');
        --
        create_scl_flex (p_id_flex_num,
                         l_legislation_code,
                         'SCL_ORG_FLEX_ROUTE',
                         'SCL_ORG_' || l_legislation_code,
                         'ORGANIZATION');
        --
    end loop; -- c0 loop
end create_scl_flex_dict;
--
procedure truncate_fcomp_info is
  statem varchar2(256);
  sql_cur number;
  ignore number;
  l_status    varchar2(50);
  l_industry  varchar2(50);
  l_per_owner varchar2(30);
  l_ret_per   boolean;
begin

  -- Get FF table owner
  l_ret_per  := FND_INSTALLATION.GET_APP_INFO ('PER', l_status,
                                               l_industry, l_per_owner);

  statem := 'truncate table ' ||  l_per_owner || '.' || 'ff_fdi_usages_f';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
  statem := 'truncate table ' ||  l_per_owner || '.' || 'ff_compiled_info_f';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
end truncate_fcomp_info;
--

procedure disable_ffue_cascade_trig is
  statem varchar2(256);
  sql_cur number;
  ignore number;
begin
  statem := 'alter trigger ff_database_items_brd disable';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
  statem := 'alter trigger ff_rpv_brud disable';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
end disable_ffue_cascade_trig;
--
procedure enable_ffue_cascade_trig is
  statem varchar2(256);
  sql_cur number;
  ignore number;
begin
  statem := 'alter trigger ff_database_items_brd enable';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
  statem := 'alter trigger ff_rpv_brud enable';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
end enable_ffue_cascade_trig;
--
procedure disable_refbal_trig is
  statem varchar2(256);
  sql_cur number;
  ignore number;
begin
  statem := 'alter trigger ff_user_entities_bri disable';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
  statem := 'alter trigger ff_database_items_bri disable';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
  statem := 'alter trigger ff_rpv_bri disable';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
end disable_refbal_trig;
--
procedure enable_refbal_trig is
  statem varchar2(256);
  sql_cur number;
  ignore number;
begin
  statem := 'alter trigger ff_user_entities_bri enable';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
  statem := 'alter trigger ff_database_items_bri enable';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
  statem := 'alter trigger ff_rpv_bri enable';
  sql_cur := dbms_sql.open_cursor;
  dbms_sql.parse(sql_cur,
                 statem,
                 dbms_sql.v7);
  ignore := dbms_sql.execute(sql_cur);
  dbms_sql.close_cursor(sql_cur);
end enable_refbal_trig;
--
-- The following procedure recreates ALL dbis and UEs for all
-- existing elements input values and balances. It is not intended to
-- be used outside of Oracle development
--
procedure reib_all is
begin
   --
   -- First set global to say we are disabling triggers.
   g_triggers_altered := TRUE;
   --
   delete pay_patch_status
   where  patch_name like 'HRRBDEIB%';
   --
   commit;
   --
   disable_ffue_cascade_trig;
   --
   delete from ff_user_entities
   where  creator_type in ('B', 'RB');
   --
   enable_ffue_cascade_trig;
   disable_refbal_trig;
   --
   hrdyndbi.refresh_defined_balances(0, 1);
   --
   commit;
   --
   enable_refbal_trig;
   disable_ffue_cascade_trig;
   --
   hrdyndbi.delete_element_types(0,1);
   --
   enable_ffue_cascade_trig;
   disable_refbal_trig;
   --
   hrdyndbi.refresh_element_types(0, 1);
   --
   delete pay_patch_status
   where  patch_name like 'HRRBDEIB%';
   --
   enable_refbal_trig;
   --
   g_triggers_altered := FALSE;
   --
   exception when others then
     enable_ffue_cascade_trig;
     enable_refbal_trig;
     raise; -- reraise the exception
end reib_all;
--
-- check_for_dbi_clash
--
-- This keeps the database item clash checking code in one place.
-- This is for additions to FF_DATABASE_ITEMS.
-- It also checks G_TRIGGERS_ALTERED.
-- The code does not bother with FF_GLOBALS_F as that's the
-- same as checking against database items.
--
procedure check_for_dbi_clash
(p_user_name      in varchar2
,p_ue_id          in number
,p_leg_code       in varchar2
,p_bg_id          in number
,p_startup_mode   in varchar2
,p_clash          out nocopy boolean
) is
l_exists varchar2(1);
begin
  p_clash := true;

  --
  -- For NOT G_TRIGGERS_ALTERED, the code will defer the checking to
  -- to database item trigger code.
  --
  if not g_triggers_altered then
    p_clash := false;
    return;
  end if;

  select null
  into   l_exists
  from   dual
  where exists
  (
     select /*+ INDEX(a FF_DATABASE_ITEMS_PK)
                INDEX(b FF_USER_ENTITIES_PK) */ null
     from   ff_database_items a,
            ff_user_entities b
     where  a.user_name = p_user_name
     and    a.user_entity_id = b.user_entity_id
     and
        (
           p_startup_mode = 'MASTER'
           or
           (
              p_startup_mode = 'SEED'
              and
              (
                 b.legislation_code = p_leg_code
                 or
                 (
                    b.legislation_code is null and b.business_group_id is null
                 )
                 or
                 p_leg_code =
                 (
                    select c.legislation_code
                    from   per_business_groups_perf c
                    where  c.business_group_id = b.business_group_id
                 )
              )
           )
           or
           (
              p_startup_mode = 'NON-SEED'
              and
              (
                 b.business_group_id = p_bg_id
                 or
                 (
                    b.legislation_code is null and b.business_group_id is null
                 )
                 or
                 (
                    b.business_group_id is null and b.legislation_code = p_leg_code
                 )
              )
           )
        )
  )
  or    exists
  (
     select /*+ ORDERED INDEX(a FF_DATABASE_ITEMS_TL_N2)
                INDEX(b FF_USER_ENTITIES_PK) */ null
     from   ff_database_items_tl a,
            ff_user_entities b
     where  a.translated_user_name = p_user_name
     and    (a.user_name <> p_user_name or a.user_entity_id <> p_ue_id)
     and    a.user_entity_id = b.user_entity_id
     and
        (
           p_startup_mode = 'MASTER'
           or
           (
              p_startup_mode = 'SEED'
              and
              (
                 b.legislation_code = p_leg_code
                 or
                 (
                    b.legislation_code is null and b.business_group_id is null
                 )
                 or
                 p_leg_code =
                 (
                    select c.legislation_code
                    from   per_business_groups_perf c
                    where  c.business_group_id = b.business_group_id
                 )
              )
           )
           or
           (
              p_startup_mode = 'NON-SEED'
              and
              (
                 b.business_group_id = p_bg_id
                 or
                 (
                    b.legislation_code is null and b.business_group_id is null
                 )
                 or
                 (
                    b.business_group_id is null and b.legislation_code = p_leg_code
                 )
              )
           )
        )
  )
  or    exists
  (
     select null
     from   ff_contexts
     where  context_name = p_user_name
  );

  hrrbdeib_trace_on;
  hr_utility.trace('DBI name clash in (' || p_leg_code || ',' || p_bg_id ||
                   ') for ' ||  p_user_name);
  hrrbdeib_trace_off;

exception
  when no_data_found then
    p_clash := false;
end check_for_dbi_clash;
--
-- replace_code_name
--
-- This takes the NAME_TRANSLATIONS lookup search-and-replace code from
-- insert_database_item so that it can be used in many places.
--
procedure replace_code_name
(p_language_code in            varchar2
,p_item_name     in out nocopy varchar2
) is
--
-- Get codename cursor now accesses FND table directly, since we
-- need all language values, not just the ones for the current
-- language.
--
-- As bugfix 1210117 we replace apostrophes with underscores.
--
cursor get_codename (c_lookup_code       in varchar2,
                     c_language          in varchar2) is
  select    lookup_code,
            replace(replace(replace(replace(replace(ltrim(rtrim(upper(meaning))),' ','_'),'''','_'),'(',''),')',''),'.','') meaning2
  from      fnd_lookup_values
  where     instr(c_lookup_code,lookup_code) > 0
  and       lookup_type         = 'NAME_TRANSLATIONS'
  and       language = c_language
  and       view_application_id = 3
  and       security_group_id = g_security_group_id
  order by  length(lookup_code) desc;
--
l_item_name ff_database_items.user_name%type;
begin
  --
  -- 523343. if the item name consists of more than one lookup_code,
  -- split into its constituent parts and translate separately, then
  -- concat back together to form the entirely translated item name.
  --
  l_item_name := p_item_name;
  for c1_rec in get_codename(p_item_name, p_language_code) loop
     l_item_name := replace(l_item_name,c1_rec.lookup_code,
                            lower(c1_rec.meaning2));
  end loop;
  p_item_name := upper(l_item_name);
end replace_code_name;
--
-- =================================== --
-- DBI Base name generation procedures --
-- =================================== --

-- Defined Balance
procedure gen_db_base_dbi_name
(p_defined_balance_id in number
,p_leg_code              out nocopy varchar2
,p_bg_id                 out nocopy number
,p_base_name             out nocopy varchar2
,p_balance_type_id       out nocopy number
,p_balance_dimension_id  out nocopy number
) is
cursor csr_balance_dbi_name
(p_defined_balance_id in number
) is
select b.balance_name || d.database_item_suffix
,      db.legislation_code
,      db.business_group_id
,      db.balance_type_id
,      db.balance_dimension_id
from   pay_defined_balances db
,      pay_balance_types b
,      pay_balance_dimensions d
where  db.defined_balance_id = p_defined_balance_id
and    b.balance_type_id = db.balance_type_id
and    d.balance_dimension_id = db.balance_dimension_id
;
--
l_found boolean;
l_base_name ff_database_items.user_name%type;
l_leg_code  pay_defined_balances.legislation_code%type;
l_bg_id     pay_defined_balances.business_group_id%type;
l_bal_id    pay_defined_balances.balance_type_id%type;
l_baldim_id pay_defined_balances.balance_dimension_id%type;
begin
  open csr_balance_dbi_name
       (p_defined_balance_id => p_defined_balance_id
       );
  fetch csr_balance_dbi_name
  into  l_base_name
  ,     l_leg_code
  ,     l_bg_id
  ,     l_bal_id
  ,     l_baldim_id
  ;
  l_found := csr_balance_dbi_name%found;
  close csr_balance_dbi_name;

  assert(l_found, 'gen_db_base_dbi_name:1', p_defined_balance_id);

  -- Set output values.
  p_leg_code := l_leg_code;
  p_bg_id := l_bg_id;
  p_balance_type_id := l_bal_id;
  p_balance_dimension_id := l_baldim_id;

  --
  -- Convert to a valid database item name.
  --
  p_base_name := ff_dbi_utils_pkg.str2dbiname(substr(l_base_name, 1, 80));
end gen_db_base_dbi_name;

--
-- gen_et_base_dbi_name
--
-- p_prefix is the element name and is taken from the database
-- if null, otherwise it is reused.
--
procedure gen_et_base_dbi_name
(p_element_type_id in            number
,p_leg_code        in out nocopy varchar2
,p_bg_id           in out nocopy number
,p_prefix          in out nocopy varchar2
,p_suffix          in            varchar2
,p_date_p          in            varchar2
,p_base_name          out nocopy varchar2
) is
cursor csr_prefix
(p_element_type_id in number
) is
select et.element_name
,      et.legislation_code
,      et.business_group_id
from   pay_element_types_f et
where  et.element_type_id = p_element_type_id
;
--
l_prefix    varchar2(240);
l_ele_name  pay_element_types_f.element_name%type;
l_found     boolean;
l_leg_code  pay_element_types_f.legislation_code%type;
l_bg_id     pay_element_types_f.business_group_id%type;
begin
  --
  -- Fetch the element name if necessary.
  --
  if p_prefix is null then
    open csr_prefix
         (p_element_type_id => p_element_type_id
         );
    fetch csr_prefix
    into  l_ele_name
    ,     l_leg_code
    ,     l_bg_id
    ;
    l_found := csr_prefix%found;
    close csr_prefix;

    assert(l_found, 'gen_et_base_dbi_name:1', p_element_type_id);

    p_prefix := l_ele_name;
    p_leg_code := l_leg_code;
    p_bg_id := l_bg_id;
  end if;

  --
  -- Convert to a valid database item name.
  --
  p_base_name :=
  ff_dbi_utils_pkg.str2dbiname(substr(p_prefix || '_' || p_suffix || p_date_p, 1, 80));
end gen_et_base_dbi_name;

--
-- gen_eiv_base_dbi_name
--
-- p_prefix is the element name and input value name, and is taken from
-- the database if null, otherwise it is reused. There is special
-- processing for PAY VALUE so that the lookup meaning from the
-- NAME_TRANSLATIONS lookup is substituted in.
--
procedure gen_eiv_base_dbi_name
(p_input_value_id in            number
,p_leg_code       in out nocopy varchar2
,p_bg_id          in out nocopy number
,p_prefix         in out nocopy varchar2
,p_suffix         in            varchar2
,p_date_p         in            varchar2
,p_base_name         out nocopy varchar2
) is
cursor csr_prefix
(p_input_value_id in number
) is
select et.element_name || '_' || iv.name
,      et.legislation_code
,      et.business_group_id
from   pay_element_types_f et
,      pay_input_values_f iv
where  iv.input_value_id = p_input_value_id
and    et.element_type_id = iv.element_type_id
;
--
l_prefix   ff_database_items.user_name%type;
l_leg_code pay_input_values_f.legislation_code%type;
l_bg_id    pay_input_values_f.business_group_id%type;
l_found    boolean;
begin
  --
  -- Fetch the prefix if necessary.
  --
  if p_prefix is null then
    open csr_prefix
         (p_input_value_id => p_input_value_id
         );
    fetch csr_prefix
    into  l_prefix
    ,     l_leg_code
    ,     l_bg_id
    ;
    l_found := csr_prefix%found;
    close csr_prefix;

    assert(l_found, 'gen_eiv_base_dbi_name:1', p_input_value_id);

    p_prefix := l_prefix;
    p_leg_code := l_leg_code;
    p_bg_id := l_bg_id;
  end if;

  --
  -- Convert to a valid database item name.
  --
  p_base_name :=
  ff_dbi_utils_pkg.str2dbiname(substr(p_prefix || '_' || p_suffix || p_date_p, 1, 80));
end gen_eiv_base_dbi_name;

-- ========================================= --
-- DBI translated name generation procedures --
-- ========================================= --

-- =============== --
-- Defined Balance --
-- =============== --
procedure gen_db_tl_dbi_name
(p_balance_type_id      in            number
,p_balance_dimension_id in            number
,p_language             in            varchar2
,p_tl_name                 out nocopy varchar2
,p_found                   out nocopy boolean
) is
cursor csr_balance_name
(p_balance_type_id in number
,p_language        in varchar2
) is
select b.balance_name
from   pay_balance_types_tl b
where  b.balance_type_id = p_balance_type_id
and    b.language = p_language
;
cursor csr_dbi_suffix
(p_balance_dimension_id in number
,p_language             in varchar2
) is
select bd.database_item_suffix
from   pay_balance_dimensions_tl bd
where  bd.balance_dimension_id = p_balance_dimension_id
and    bd.language = p_language
;
--
l_balance_name pay_balance_types_tl.balance_name%type;
l_dbi_suffix   pay_balance_dimensions_tl.database_item_suffix%type;
l_debug        boolean := hr_utility.debug_enabled;
l_found        boolean;
begin
  open csr_balance_name
       (p_balance_type_id => p_balance_type_id
       ,p_language        => p_language
       );
  fetch csr_balance_name
  into  l_balance_name
  ;
  l_found := csr_balance_name%found;
  close csr_balance_name;

  if l_found then
    open csr_dbi_suffix
       (p_balance_dimension_id => p_balance_dimension_id
       ,p_language             => p_language
       );
    fetch csr_dbi_suffix
    into  l_dbi_suffix
    ;
    l_found := csr_dbi_suffix%found;
    close csr_dbi_suffix;
  end if;

  if l_found then
    --
    -- Check name, converting if necessary. STR2DBINAME will be called
    -- later in the processing.
    --
    p_tl_name := l_balance_name || l_dbi_suffix;
  elsif l_debug then
    hr_utility.trace('Could not generate _TL DBI for defined balance (' ||
                     p_balance_type_id || ',' || p_balance_dimension_id ||
                     ')');
  end if;

  p_found := l_found;
end gen_db_tl_dbi_name;

-- =================== --
-- Element Type Prefix --
-- =================== --
procedure gen_et_tl_dbi_prefix
(p_element_type_id in            number
,p_language        in            varchar2
,p_prefix          in out nocopy varchar2
,p_found              out nocopy boolean
) is
cursor csr_prefix
(p_element_type_id in number
,p_language        in varchar2
) is
select ettl.element_name
from   pay_element_types_f_tl ettl
where  ettl.element_type_id = p_element_type_id
and    ettl.language = p_language
;
--
l_found  boolean := true;
l_debug  boolean := hr_utility.debug_enabled;
begin
  open csr_prefix
       (p_element_type_id => p_element_type_id
       ,p_language        => p_language
       );
  fetch csr_prefix
  into  p_prefix;
  l_found := csr_prefix%found;
  close csr_prefix;

  if not l_found then
    if l_debug then
      hr_utility.trace('Could not generate _TL DBI for element type ' ||
                       p_element_type_id);
    end if;
  end if;

  p_found := l_found;
end gen_et_tl_dbi_prefix;

-- ========================== --
-- Element Input Value Prefix --
-- ========================== --
procedure gen_eiv_tl_dbi_prefix
(p_input_value_id in            number
,p_effective_date in            date
,p_language       in            varchar2
,p_prefix         in out nocopy varchar2
,p_found             out nocopy boolean
) is
cursor csr_base_name
(p_input_value_id in number
) is
select iv.name
from   pay_input_values_f iv
where  iv.input_value_id = p_input_value_id
and    p_effective_date between
       iv.effective_start_date and iv.effective_end_date
;
--
cursor csr_prefix
(p_input_value_id in number
,p_language       in varchar2
) is
select ivtl.name
,      ettl.element_name
from   pay_input_values_f iv
,      pay_element_types_f_tl ettl
,      pay_input_values_f_tl ivtl
where  iv.input_value_id = p_input_value_id
and    p_effective_date between
       iv.effective_start_date and iv.effective_end_date
and    ettl.element_type_id = iv.element_type_id
and    ettl.language = p_language
and    ivtl.input_value_id = iv.input_value_id
and    ivtl.language = p_language
;
--
l_pay_value pay_input_values_f.name%type := null;
l_ipv_name  pay_input_values_f_tl.name%type;
l_ele_name  pay_element_types_f_tl.element_name%type;
l_found     boolean := true;
l_debug     boolean := hr_utility.debug_enabled;
begin
  --
  -- Check if the input is PAY VALUE.
  --
  open csr_base_name
       (p_input_value_id => p_input_value_id
       );
  fetch csr_base_name
  into  l_pay_value
  ;
  l_found := csr_base_name%found;
  close csr_base_name;

  --
  -- Whatever happens the base name must exist.
  --
  assert(l_found, 'gen_eiv_tl_dbi_name:1', p_input_value_id);

  if upper(l_pay_value) = 'PAY VALUE' then
    l_pay_value := 'PAY VALUE';
    replace_code_name
    (p_language_code => p_language
    ,p_item_name     => l_pay_value
    );
  else
    l_pay_value := null;
  end if;

  open csr_prefix
       (p_input_value_id => p_input_value_id
       ,p_language       => p_language
       );
  fetch csr_prefix
  into  l_ipv_name
  ,     l_ele_name
  ;
  l_found := csr_prefix%found;
  close csr_prefix;

  if l_found then
    p_prefix := l_ele_name || '_' || nvl(l_pay_value, l_ipv_name);
  else
    if l_debug then
      hr_utility.trace('Could not generate _TL DBI for element input value ' ||
                       p_input_value_id);
    end if;
  end if;

  p_found := l_found;
end gen_eiv_tl_dbi_prefix;

procedure gen_et_dbi_prefixes
(p_element_type_id in number
,p_languages       in            dbms_sql.varchar2s
,p_prefixes        in out nocopy t_dbi_prefixes
) is
l_prefix r_dbi_prefix;
begin
  if p_prefixes.count = 0 then
    for i in 1 .. p_languages.count loop
      gen_et_tl_dbi_prefix
      (p_element_type_id => p_element_type_id
      ,p_language        => p_languages(i)
      ,p_prefix          => l_prefix.prefix
      ,p_found           => l_prefix.found
      );
      p_prefixes(i) := l_prefix;
      p_prefixes(i).language := p_languages(i);
    end loop;
  end if;
end gen_et_dbi_prefixes;

procedure gen_eiv_dbi_prefixes
(p_input_value_id in number
,p_effective_date in            date
,p_languages      in            dbms_sql.varchar2s
,p_prefixes       in out nocopy t_dbi_prefixes
) is
l_prefix r_dbi_prefix;
begin
  if p_prefixes.count = 0 then
    for i in 1 .. p_languages.count loop
      gen_eiv_tl_dbi_prefix
      (p_input_value_id => p_input_value_id
      ,p_effective_date => p_effective_date
      ,p_language       => p_languages(i)
      ,p_prefix         => l_prefix.prefix
      ,p_found          => l_prefix.found
      );
      p_prefixes(i) := l_prefix;
      p_prefixes(i).language := p_languages(i);
    end loop;
  end if;
end gen_eiv_dbi_prefixes;

-- =================================== --
-- Element Type / Input Value DBI Name --
-- =================================== --
procedure gen_et_tl_dbi_name
(p_prefix   in            varchar2
,p_suffix   in            varchar2
,p_date_p   in            varchar2
,p_language in            varchar2
,p_tl_name     out nocopy varchar2
) is
l_suffix varchar2(240);
begin
  -- Translate the suffix.
  l_suffix := p_suffix || p_date_p;
  replace_code_name
  (p_language_code => p_language
  ,p_item_name     => l_suffix
  );

  --
  -- Convert to a valid database item name. STR2DBINAME will be
  -- called later in the processing.
  --
  p_tl_name := p_prefix || '_' || l_suffix;
end gen_et_tl_dbi_name;

-- ====================================== --
-- Utility procedures for translated DBIs --
-- ====================================== --

--
-- dbi2ueid
--
-- Takes a database item name and entity information to retrieve the
-- corresponding user_entity_id.
--
function dbi2ueid
(p_creator_id   in number
,p_creator_type in varchar2
,p_user_name    in varchar2
) return number is
cursor csr_user_entity_id
(p_creator_id   in number
,p_creator_type in varchar2
,p_user_name    in varchar2
) is
select u.user_entity_id
from   ff_database_items d
,      ff_user_entities u
where  d.user_name = p_user_name
and    u.user_entity_id = d.user_entity_id
and    u.creator_id = p_creator_id
and    u.creator_type = p_creator_type
;
--
l_found boolean;
l_ueid      number;
begin
  open csr_user_entity_id
       (p_creator_id   => p_creator_id
       ,p_creator_type => p_creator_type
       ,p_user_name    => p_user_name
       );
  fetch csr_user_entity_id
  into  l_ueid
  ;
  l_found := csr_user_entity_id%found;
  close csr_user_entity_id;

  assert(l_found, 'dbi2ueid:1',
         p_user_name || ':' || p_creator_type || ':' || p_creator_id);

  return l_ueid;
end dbi2ueid;

--
-- check_for_tl_dbi_clash
--
-- This keeps the database item clash checking code in one place.
-- This is for additions to FF_DATABASE_ITEMS_TL.
-- It also checks G_TRIGGERS_ALTERED.
-- The code does not bother with FF_GLOBALS_F as that's the
-- same as checking against database items.
--
procedure check_for_tl_dbi_clash
(p_user_name      in varchar2
,p_user_entity_id in number
,p_tl_user_name   in varchar2
,p_leg_code       in varchar2
,p_bg_id          in number
,p_startup_mode   in varchar2
,p_clash          out nocopy boolean
) is
l_exists varchar2(1);
begin
  p_clash := true;

  --
  -- For NOT G_TRIGGERS_ALTERED, the code will defer the checking to
  -- to database item trigger code.
  --
  if not g_triggers_altered then
    p_clash := false;
    return;
  end if;

  select null
  into   l_exists
  from   dual
  where exists
  (
     select /*+ INDEX(a FF_DATABASE_ITEMS_PK)
                INDEX(b FF_USER_ENTITIES_PK) */ null
     from   ff_database_items a,
            ff_user_entities b
     where  a.user_name = p_tl_user_name
     and    (p_user_name <> p_tl_user_name or a.user_entity_id <> p_user_entity_id)
     and    a.user_entity_id = b.user_entity_id
     and
     (
           p_startup_mode = 'MASTER'
           or
           (
              p_startup_mode = 'SEED'
              and
              (
                 b.legislation_code = p_leg_code
                 or
                 (
                    b.legislation_code is null and b.business_group_id is null
                 )
                 or
                 p_leg_code =
                 (
                    select c.legislation_code
                    from   per_business_groups_perf c
                    where  c.business_group_id = b.business_group_id
                 )
              )
           )
           or
           (
              p_startup_mode = 'NON-SEED'
              and
              (
                 b.business_group_id = p_bg_id
                 or
                 (
                    b.legislation_code is null and b.business_group_id is null
                 )
                 or
                 (
                    b.business_group_id is null and b.legislation_code = p_leg_code
                 )
              )
           )
     )
  )
  or    exists
  (
     select /*+ ORDERED INDEX(a FF_DATABASE_ITEMS_TL_N2)
                INDEX(b FF_USER_ENTITIES_PK) */ null
     from   ff_database_items_tl a,
            ff_user_entities b
     where  a.translated_user_name = p_tl_user_name
     and    (a.user_name <> p_user_name or a.user_entity_id <> p_user_entity_id)
     and    a.user_entity_id = b.user_entity_id
     and
     (
           p_startup_mode = 'MASTER'
           or
           (
              p_startup_mode = 'SEED'
              and
              (
                 b.legislation_code = p_leg_code
                 or
                 (
                    b.legislation_code is null and b.business_group_id is null
                 )
                 or
                 p_leg_code =
                 (
                    select c.legislation_code
                    from   per_business_groups_perf c
                    where  c.business_group_id = b.business_group_id
                 )
              )
           )
           or
           (
              p_startup_mode = 'NON-SEED'
              and
              (
                 b.business_group_id = p_bg_id
                 or
                 (
                    b.legislation_code is null and b.business_group_id is null
                 )
                 or
                 (
                    b.business_group_id is null and b.legislation_code = p_leg_code
                 )
              )
           )
     )
  )
  or    exists
  (
     select null
     from   ff_contexts
     where  context_name = p_tl_user_name
  );

  hrrbdeib_trace_on;
  hr_utility.trace('TL DBI name clash in (' || p_leg_code || ',' || p_bg_id ||
                   ') for ' ||  p_user_name);
  hrrbdeib_trace_off;

exception
  when no_data_found then
    p_clash := false;
end check_for_tl_dbi_clash;

-- Assert a condition in the code.
procedure assert
(p_condition  in boolean
,p_location   in varchar2
,p_extra_info in varchar2
) is
l_debug_cnt number;
begin
  if not p_condition then
    hr_utility.set_message(801, 'FFPLU01_ASSERTION_FAILED');
    hr_utility.set_message_token('1', p_location || ':[' || p_extra_info || ']');
    hr_utility.raise_error;
  end if;
end assert;

-- Check for DATE_PAID database items.
function has_date_paid_dbis
(p_creator_type in varchar2
,p_creator_id   in number
) return boolean is
l_count number;
begin
  select count(*)
  into   l_count
  from   ff_user_entities ue
  where  ue.creator_id = p_creator_id
  and    ue.creator_type = p_creator_type
  and    ue.user_entity_name like '%_DP'
  ;

  return l_count > 0;
end has_date_paid_dbis;

-- Check for non-DATE_PAID database items.
function has_non_date_paid_dbis
(p_creator_type in varchar2
,p_creator_id   in number
) return boolean is
l_count number;
begin
  select count(*)
  into   l_count
  from   ff_user_entities ue
  where  ue.creator_id = p_creator_id
  and    ue.creator_type = p_creator_type
  and    ue.user_entity_name not like '%_DP'
  ;

  return l_count > 0;
end has_non_date_paid_dbis;

--
-- Update the _TL database item name.
--
procedure update_tl_dbi_name
(p_user_name      in varchar2
,p_user_entity_id in number
,p_leg_code       in varchar2
,p_bg_id          in number
,p_startup_mode   in varchar2
,p_language       in varchar2
,p_tl_user_name   in varchar2
) is
l_clash        boolean;
l_tl_user_name ff_database_items_tl.translated_user_name%type;
l_got_error    boolean;
begin
  --
  -- G_TRIGGERS_ALTERED is true for the bulk generation of balance,
  -- element, and input value names in HRDYNDBI. The validation assumes
  -- that FF_FDI_USAGES_F rows have been deleted.
  --
  if g_triggers_altered then
    --
    -- Format the translated name.
    --
    l_tl_user_name :=
    ff_dbi_utils_pkg.str2dbiname(p_str => p_tl_user_name);

    check_for_tl_dbi_clash
    (p_user_name      => p_user_name
    ,p_user_entity_id => p_user_entity_id
    ,p_tl_user_name   => l_tl_user_name
    ,p_leg_code       => p_leg_code
    ,p_bg_id          => p_bg_id
    ,p_startup_mode   => p_startup_mode
    ,p_clash          => l_clash
    );

    if not l_clash then
      update ff_database_items_tl dbitl
      set    dbitl.translated_user_name = l_tl_user_name
      ,      dbitl.source_lang = p_language
      where  dbitl.language = p_language
      and    dbitl.user_name = p_user_name
      and    dbitl.user_entity_id = p_user_entity_id
      ;

      --
      -- Put in an assertion to check for missing database items.
      -- However, the US deduction form creates the element type
      -- before updating the benefit_classification_id causing this
      -- assertion to fail, because the database items are created
      -- before the benefit_classification_id is made NOT NULL.
      --
      if not p_user_name like '%BEN_CLASS' then
        assert(SQL%rowcount > 0, 'update_tl_dbi_name:1',
               p_user_name || ':' || p_user_entity_id);
      end if;
    else
      --
      -- For the MLS process, a name clash is a fatal error.
      --
      hr_utility.set_message (801, 'PAY_33916_DYN_DBI_NAME_CLASH');
      hr_utility.set_message_token('1', l_tl_user_name);
      hr_utility.raise_error;
    end if;
  elsif g_dyndbi_changes then
     l_tl_user_name := p_tl_user_name;
     ff_database_items_pkg.update_seeded_tl_rows
     (x_user_name            => p_user_name
     ,x_user_entity_id       => p_user_entity_id
     ,x_language             => p_language
     ,x_translated_user_name => l_tl_user_name
     ,x_description          => null
     ,x_got_error            => l_got_error
     );

     if l_got_error then
       g_dyndbi_changes_ok := false;
     end if;

  --
  -- One-off update for a single element type, input value, or balance.
  -- In the FF_DATABASE_ITEMS case, the FF_DATABASE_ITEMS trigger would
  -- handle this validation. Unfortunately, an update trigger cannot
  -- perform this because of ORA-04091 errors.
  --
  else
    --
    -- Note: UPDATE_TL_ROW calls STR2DBINAME so passing p_tl_user_name
    -- unmodified to UPDATE_TL_ROW.
    --
    ff_database_items_pkg.update_tl_row
    (x_user_name            => p_user_name
    ,x_user_entity_id       => p_user_entity_id
    ,x_language             => p_language
    ,x_source_lang          => p_language
    ,x_translated_user_name => p_tl_user_name
    ,x_description          => null
    );
  end if;
end update_tl_dbi_name;

-- =================================================== --
-- Element Type/Input Value DBI name update procedure --
-- =================================================== --
procedure update_et_tl_dbi_names
(p_leg_code       in varchar2
,p_bg_id          in number
,p_startup_mode   in varchar2
,p_user_name      in varchar2
,p_user_entity_id in number
,p_prefixes       in t_dbi_prefixes
,p_suffix         in varchar2
,p_date_p         in varchar2
) is
--
l_tl_name ff_database_items_tl.translated_user_name%type;
begin
  for i in 1 .. p_prefixes.count loop
    if p_prefixes(i).found then
      --
      -- Generate the translated DBI name.
      --
      gen_et_tl_dbi_name
      (p_prefix          => p_prefixes(i).prefix
      ,p_suffix          => p_suffix
      ,p_date_p          => p_date_p
      ,p_language        => p_prefixes(i).language
      ,p_tl_name         => l_tl_name
      );

      --
      -- Update the translated database item.
      --
      update_tl_dbi_name
      (p_user_name      => p_user_name
      ,p_user_entity_id => p_user_entity_id
      ,p_leg_code       => p_leg_code
      ,p_bg_id          => p_bg_id
      ,p_startup_mode   => p_startup_mode
      ,p_language       => p_prefixes(i).language
      ,p_tl_user_name   => l_tl_name
      );
    end if;
  end loop;
end update_et_tl_dbi_names;

-- ========================================= --
-- Update all the dbis for a defined balance --
-- ========================================= --
procedure update_defined_balance
(p_defined_balance_id in number
,p_languages          in dbms_sql.varchar2s
) is
l_leg_code     varchar2(30);
l_bg_id        number;
l_bal_id       pay_defined_balances.balance_type_id%type;
l_baldim_id    pay_defined_balances.balance_dimension_id%type;
l_base_name    ff_database_items.user_name%type;
l_ueid         number;
l_tl_name      ff_database_items_tl.translated_user_name%type;
l_found        boolean;
l_startup_mode varchar2(30);
begin
  --
  -- Generate the base database item information.
  --
  gen_db_base_dbi_name
  (p_defined_balance_id   => p_defined_balance_id
  ,p_leg_code             => l_leg_code
  ,p_bg_id                => l_bg_id
  ,p_base_name            => l_base_name
  ,p_balance_type_id      => l_bal_id
  ,p_balance_dimension_id => l_baldim_id
  );
  l_ueid :=
  dbi2ueid
  (p_creator_id   => p_defined_balance_id
  ,p_creator_type => 'B'
  ,p_user_name    => l_base_name
  );

  --
  -- Get the startup mode.
  --
  if g_triggers_altered then
    l_startup_mode := ffstup.get_mode(l_bg_id, l_leg_code);
  end if;

  --
  -- Generate the translated name and create the database item
  -- for each language
  --
  for i in 1 .. p_languages.count loop
    gen_db_tl_dbi_name
    (p_balance_type_id      => l_bal_id
    ,p_balance_dimension_id => l_baldim_id
    ,p_language             => p_languages(i)
    ,p_tl_name              => l_tl_name
    ,p_found                => l_found
    );

    --
    -- Update the translated database item.
    --
    if l_found then
      update_tl_dbi_name
      (p_user_name      => l_base_name
      ,p_user_entity_id => l_ueid
      ,p_leg_code       => l_leg_code
      ,p_bg_id          => l_bg_id
      ,p_startup_mode   => l_startup_mode
      ,p_language       => p_languages(i)
      ,p_tl_user_name   => l_tl_name
      );
    end if;
  end loop;
end update_defined_balance;

-- =============================== --
-- Update dbis for an element type --
-- =============================== --

--
-- Interface 1: does not reference PAY_ELEMENT_TYPES_F_TL - the core
-- interface.
--
procedure update_element_type
(p_element_type_id in number
,p_effective_date  in date
,p_languages       in dbms_sql.varchar2s
,p_dbi_prefixes    in t_dbi_prefixes
) is
l_date_p        varchar2(16);
l_do_date_p     boolean;
l_do_non_date_p boolean;
l_leg_code      varchar2(30);
l_bg_id         number;
l_ueid          number;
l_prefix        varchar2(240);
l_found         boolean;
l_startup_mode  varchar2(30);
l_ben_class_id  number;

--
-- Cursor to fetch element type information.
--
cursor csr_element_type_info
(p_element_type_id in number
,p_effective_date  in date
) is
select et.benefit_classification_id
,      et.legislation_code
,      et.business_group_id
from   pay_element_types_f et
where  et.element_type_id = p_element_type_id
and    p_effective_date between
       et.effective_start_date and et.effective_end_date
;
--
procedure update_dbis
(p_element_type_id in number
,p_leg_code        in out nocopy varchar2
,p_bg_id           in out nocopy number
,p_prefix          in out nocopy varchar2
,p_dbi_prefixes    in t_dbi_prefixes
,p_date_p          in varchar2
,p_startup_mode    in varchar2
,p_languages       in dbms_sql.varchar2s
,p_user_entity_id  in out nocopy number
,p_suffix          in varchar2
) is
l_base_name ff_database_items.user_name%type;
begin
  gen_et_base_dbi_name
  (p_element_type_id => p_element_type_id
  ,p_leg_code        => p_leg_code
  ,p_bg_id           => p_bg_id
  ,p_prefix          => p_prefix
  ,p_suffix          => p_suffix
  ,p_date_p          => p_date_p
  ,p_base_name       => l_base_name
  );

  if p_user_entity_id is null then
    p_user_entity_id :=
    dbi2ueid
    (p_creator_id   => p_element_type_id
    ,p_creator_type => 'E'
    ,p_user_name    => l_base_name
    );
  end if;

  update_et_tl_dbi_names
  (p_leg_code       => p_leg_code
  ,p_bg_id          => p_bg_id
  ,p_startup_mode   => p_startup_mode
  ,p_user_name      => l_base_name
  ,p_user_entity_id => p_user_entity_id
  ,p_prefixes       => p_dbi_prefixes
  ,p_suffix         => p_suffix
  ,p_date_p         => p_date_p
  );
end update_dbis;

begin
  -- ==================================================== --
  -- Are there DATE_PAID / non-DATE_PAID database items ? --
  -- ==================================================== --
  l_do_date_p :=
  has_date_paid_dbis
  (p_creator_type => 'E'
  ,p_creator_id   => p_element_type_id
  );

  l_do_non_date_p :=
  has_non_date_paid_dbis
  (p_creator_type => 'E'
  ,p_creator_id   => p_element_type_id
  );

  -- ============================= --
  -- Get element type information. --
  -- ============================= --
  open csr_element_type_info
       (p_element_type_id => p_element_type_id
       ,p_effective_date  => p_effective_date
       );
  fetch csr_element_type_info
  into  l_ben_class_id
  ,     l_leg_code
  ,     l_bg_id
  ;
  l_found := csr_element_type_info%found;
  close csr_element_type_info;

  assert(l_found, 'update_element_type:1', p_element_type_id);

  --
  -- Get the startup mode. This only needs to be done at this
  -- stage as l_bg_id and l_leg_code should not change.
  --
  if g_triggers_altered then
    l_startup_mode := ffstup.get_mode(l_bg_id, l_leg_code);
  end if;

  -- Force fetch of element type information.
  l_prefix := null;

  -- ============================== --
  -- Database item processing code. --
  -- ============================== --
  loop

    --
    -- Loop control based upon processing DATE PAID and non-DATE PAID
    -- database items.
    --
    if l_do_non_date_p then
      l_date_p := null;
      l_do_non_date_p := false;
    elsif l_do_date_p then
      l_date_p := '_DP';
      l_do_date_p := false;
    else
      exit;
    end if;

    -- ========================================= --
    -- Process the dbis for the _E1 user entity. --
    -- ========================================= --

    --
    -- This must be done for the first dbi in each user entity.
    --
    l_ueid := null;

    -- REPORTING_NAME --
    update_dbis
    (p_element_type_id => p_element_type_id
    ,p_leg_code        => l_leg_code
    ,p_bg_id           => l_bg_id
    ,p_prefix          => l_prefix
    ,p_dbi_prefixes    => p_dbi_prefixes
    ,p_date_p          => l_date_p
    ,p_startup_mode    => l_startup_mode
    ,p_languages       => p_languages
    ,p_user_entity_id  => l_ueid
    ,p_suffix          => 'REPORTING_NAME'
    );

    -- CLASSIFICATION --
    update_dbis
    (p_element_type_id => p_element_type_id
    ,p_leg_code        => l_leg_code
    ,p_bg_id           => l_bg_id
    ,p_prefix          => l_prefix
    ,p_dbi_prefixes    => p_dbi_prefixes
    ,p_date_p          => l_date_p
    ,p_startup_mode    => l_startup_mode
    ,p_languages       => p_languages
    ,p_user_entity_id  => l_ueid
    ,p_suffix          => 'CLASSIFICATION'
    );

    -- INPUT_CURRENCY_CODE --
    update_dbis
    (p_element_type_id => p_element_type_id
    ,p_leg_code        => l_leg_code
    ,p_bg_id           => l_bg_id
    ,p_prefix          => l_prefix
    ,p_dbi_prefixes    => p_dbi_prefixes
    ,p_date_p          => l_date_p
    ,p_startup_mode    => l_startup_mode
    ,p_languages       => p_languages
    ,p_user_entity_id  => l_ueid
    ,p_suffix          => 'INPUT_CURRENCY_CODE'
    );

    -- OUTPUT_CURRENCY_CODE --
    update_dbis
    (p_element_type_id => p_element_type_id
    ,p_leg_code        => l_leg_code
    ,p_bg_id           => l_bg_id
    ,p_prefix          => l_prefix
    ,p_dbi_prefixes    => p_dbi_prefixes
    ,p_date_p          => l_date_p
    ,p_startup_mode    => l_startup_mode
    ,p_languages       => p_languages
    ,p_user_entity_id  => l_ueid
    ,p_suffix          => 'OUTPUT_CURRENCY_CODE'
    );

    -- PROCESSING_PRIORITY --
    update_dbis
    (p_element_type_id => p_element_type_id
    ,p_leg_code        => l_leg_code
    ,p_bg_id           => l_bg_id
    ,p_prefix          => l_prefix
    ,p_dbi_prefixes    => p_dbi_prefixes
    ,p_date_p          => l_date_p
    ,p_startup_mode    => l_startup_mode
    ,p_languages       => p_languages
    ,p_user_entity_id  => l_ueid
    ,p_suffix          => 'PROCESSING_PRIORITY'
    );

    -- CLOSED_FOR_ENTRY --
    update_dbis
    (p_element_type_id => p_element_type_id
    ,p_leg_code        => l_leg_code
    ,p_bg_id           => l_bg_id
    ,p_prefix          => l_prefix
    ,p_dbi_prefixes    => p_dbi_prefixes
    ,p_date_p          => l_date_p
    ,p_startup_mode    => l_startup_mode
    ,p_languages       => p_languages
    ,p_user_entity_id  => l_ueid
    ,p_suffix          => 'CLOSED_FOR_ENTRY'
    );

    -- CLOSED_FOR_ENTRY_CODE --
    update_dbis
    (p_element_type_id => p_element_type_id
    ,p_leg_code        => l_leg_code
    ,p_bg_id           => l_bg_id
    ,p_prefix          => l_prefix
    ,p_dbi_prefixes    => p_dbi_prefixes
    ,p_date_p          => l_date_p
    ,p_startup_mode    => l_startup_mode
    ,p_languages       => p_languages
    ,p_user_entity_id  => l_ueid
    ,p_suffix          => 'CLOSED_FOR_ENTRY_CODE'
    );

    -- END_DATE --
    update_dbis
    (p_element_type_id => p_element_type_id
    ,p_leg_code        => l_leg_code
    ,p_bg_id           => l_bg_id
    ,p_prefix          => l_prefix
    ,p_dbi_prefixes    => p_dbi_prefixes
    ,p_date_p          => l_date_p
    ,p_startup_mode    => l_startup_mode
    ,p_languages       => p_languages
    ,p_user_entity_id  => l_ueid
    ,p_suffix          => 'END_DATE'
    );

    --
    -- BEN_CLASS
    --
    -- Database item is only generated when the BENEFIT_CLASSIFICATION_ID
    -- is NOT NULL.
    --
    if l_ben_class_id is not null then
      update_dbis
      (p_element_type_id => p_element_type_id
      ,p_leg_code        => l_leg_code
      ,p_bg_id           => l_bg_id
      ,p_prefix          => l_prefix
      ,p_dbi_prefixes    => p_dbi_prefixes
      ,p_date_p          => l_date_p
      ,p_startup_mode    => l_startup_mode
      ,p_languages       => p_languages
      ,p_user_entity_id  => l_ueid
      ,p_suffix          => 'BEN_CLASS'
      );
    end if;

    -- ========================================= --
    -- Process the dbis for the _E2 user entity. --
    -- ========================================= --

    --
    -- This must be done for the first dbi in each user entity.
    --
    l_ueid := null;

    -- LENGTH_OF_SERVICE --
    update_dbis
    (p_element_type_id => p_element_type_id
    ,p_leg_code        => l_leg_code
    ,p_bg_id           => l_bg_id
    ,p_prefix          => l_prefix
    ,p_dbi_prefixes    => p_dbi_prefixes
    ,p_date_p          => l_date_p
    ,p_startup_mode    => l_startup_mode
    ,p_languages       => p_languages
    ,p_user_entity_id  => l_ueid
    ,p_suffix          => 'LENGTH_OF_SERVICE'
    );

    -- QUALIFYING_UNITS --
    update_dbis
    (p_element_type_id => p_element_type_id
    ,p_leg_code        => l_leg_code
    ,p_bg_id           => l_bg_id
    ,p_prefix          => l_prefix
    ,p_dbi_prefixes    => p_dbi_prefixes
    ,p_date_p          => l_date_p
    ,p_startup_mode    => l_startup_mode
    ,p_languages       => p_languages
    ,p_user_entity_id  => l_ueid
    ,p_suffix          => 'QUALIFYING_UNITS'
    );

    -- QUALIFYING_UNITS_CODE --
    update_dbis
    (p_element_type_id => p_element_type_id
    ,p_leg_code        => l_leg_code
    ,p_bg_id           => l_bg_id
    ,p_prefix          => l_prefix
    ,p_dbi_prefixes    => p_dbi_prefixes
    ,p_date_p          => l_date_p
    ,p_startup_mode    => l_startup_mode
    ,p_languages       => p_languages
    ,p_user_entity_id  => l_ueid
    ,p_suffix          => 'QUALIFYING_UNITS_CODE'
    );

    -- QUALIFYING_AGE --
    update_dbis
    (p_element_type_id => p_element_type_id
    ,p_leg_code        => l_leg_code
    ,p_bg_id           => l_bg_id
    ,p_prefix          => l_prefix
    ,p_dbi_prefixes    => p_dbi_prefixes
    ,p_date_p          => l_date_p
    ,p_startup_mode    => l_startup_mode
    ,p_languages       => p_languages
    ,p_user_entity_id  => l_ueid
    ,p_suffix          => 'QUALIFYING_AGE'
    );

    -- STANDARD_LINK --
    update_dbis
    (p_element_type_id => p_element_type_id
    ,p_leg_code        => l_leg_code
    ,p_bg_id           => l_bg_id
    ,p_prefix          => l_prefix
    ,p_dbi_prefixes    => p_dbi_prefixes
    ,p_date_p          => l_date_p
    ,p_startup_mode    => l_startup_mode
    ,p_languages       => p_languages
    ,p_user_entity_id  => l_ueid
    ,p_suffix          => 'STANDARD_LINK'
    );

    -- STANDARD_LINK_CODE --
    update_dbis
    (p_element_type_id => p_element_type_id
    ,p_leg_code        => l_leg_code
    ,p_bg_id           => l_bg_id
    ,p_prefix          => l_prefix
    ,p_dbi_prefixes    => p_dbi_prefixes
    ,p_date_p          => l_date_p
    ,p_startup_mode    => l_startup_mode
    ,p_languages       => p_languages
    ,p_user_entity_id  => l_ueid
    ,p_suffix          => 'STANDARD_LINK_CODE'
    );

    -- COSTABLE_TYPE --
    update_dbis
    (p_element_type_id => p_element_type_id
    ,p_leg_code        => l_leg_code
    ,p_bg_id           => l_bg_id
    ,p_prefix          => l_prefix
    ,p_dbi_prefixes    => p_dbi_prefixes
    ,p_date_p          => l_date_p
    ,p_startup_mode    => l_startup_mode
    ,p_languages       => p_languages
    ,p_user_entity_id  => l_ueid
    ,p_suffix          => 'COSTABLE_TYPE'
    );

    -- COSTABLE_TYPE_CODE --
    update_dbis
    (p_element_type_id => p_element_type_id
    ,p_leg_code        => l_leg_code
    ,p_bg_id           => l_bg_id
    ,p_prefix          => l_prefix
    ,p_dbi_prefixes    => p_dbi_prefixes
    ,p_date_p          => l_date_p
    ,p_startup_mode    => l_startup_mode
    ,p_languages       => p_languages
    ,p_user_entity_id  => l_ueid
    ,p_suffix          => 'COSTABLE_TYPE_CODE'
    );

    -- ========================================= --
    -- Process the dbis for the _E3 user entity. --
    -- ========================================= --

    --
    -- This must be done for the first dbi in each user entity.
    --
    l_ueid := null;

    -- COUNT --
    update_dbis
    (p_element_type_id => p_element_type_id
    ,p_leg_code        => l_leg_code
    ,p_bg_id           => l_bg_id
    ,p_prefix          => l_prefix
    ,p_dbi_prefixes    => p_dbi_prefixes
    ,p_date_p          => l_date_p
    ,p_startup_mode    => l_startup_mode
    ,p_languages       => p_languages
    ,p_user_entity_id  => l_ueid
    ,p_suffix          => 'COUNT'
    );
  end loop;

end update_element_type;

--
-- Interface 2: references PAY_ELEMENT_TYPES_F_TL.
--
procedure update_element_type
(p_element_type_id in number
,p_effective_date  in date
,p_languages       in dbms_sql.varchar2s
) is
l_prefixes     t_dbi_prefixes;
begin
  -- ========================== --
  -- Generate the _TL prefixes. --
  -- ========================== --
  gen_et_dbi_prefixes
  (p_element_type_id => p_element_type_id
  ,p_languages       => p_languages
  ,p_prefixes        => l_prefixes
  );

  -- ========================================== --
  -- Call the overloaded version with prefixes. --
  -- ========================================== --
  update_element_type
  (p_element_type_id => p_element_type_id
  ,p_effective_date  => p_effective_date
  ,p_languages       => p_languages
  ,p_dbi_prefixes    => l_prefixes
  );
end update_element_type;

-- ====================================== --
-- Update all the dbis for an input value --
-- ====================================== --

--
-- Interface 1: does not reference PAY_INPUT_VALUES_F_TL - the core
-- interface.
--
procedure update_input_value
(p_input_value_id in number
,p_effective_date in date
,p_languages      in dbms_sql.varchar2s
,p_dbi_prefixes   in t_dbi_prefixes
) is
--
-- Cursor to get input value information.
--
cursor csr_input_value_info
(p_input_value_id in number
,p_effective_date in date
) is
select et.multiple_entries_allowed_flag
,      iv.legislation_code
,      iv.business_group_id
,      iv.uom
,      iv.generate_db_items_flag
from   pay_input_values_f iv
,      pay_element_types_f et
where  iv.input_value_id = p_input_value_id
and    p_effective_date between
       iv.effective_start_date and iv.effective_end_date
and    et.element_type_id = iv.element_type_id
and    p_effective_date between
       et.effective_start_date and et.effective_end_date
;
--
l_multi_entries pay_element_types_f.multiple_entries_allowed_flag%type;
l_uom           pay_input_values_f.uom%type;
l_generate_dbis pay_input_values_f.generate_db_items_flag%type;
l_do_date_p     boolean;
l_do_non_date_p boolean;
l_date_p        varchar2(16);
l_leg_code      varchar2(30);
l_bg_id         number;
l_ueid          number;
l_prefix        varchar2(240);
l_found         boolean;
l_startup_mode  varchar2(30);
--
procedure update_dbis
(p_input_value_id in number
,p_leg_code       in out nocopy varchar2
,p_bg_id          in out nocopy number
,p_prefix         in out nocopy varchar2
,p_dbi_prefixes   in t_dbi_prefixes
,p_date_p         in varchar2
,p_startup_mode   in varchar2
,p_languages      in dbms_sql.varchar2s
,p_user_entity_id in out nocopy number
,p_suffix         in varchar2
) is
l_base_name ff_database_items.user_name%type;
begin
  gen_eiv_base_dbi_name
  (p_input_value_id => p_input_value_id
  ,p_leg_code       => p_leg_code
  ,p_bg_id          => p_bg_id
  ,p_prefix         => p_prefix
  ,p_suffix         => p_suffix
  ,p_date_p         => p_date_p
  ,p_base_name      => l_base_name
  );

  if p_user_entity_id is null then
    p_user_entity_id :=
    dbi2ueid
    (p_creator_id   => p_input_value_id
    ,p_creator_type => 'I'
    ,p_user_name    => l_base_name
    );
  end if;

  update_et_tl_dbi_names
  (p_leg_code       => p_leg_code
  ,p_bg_id          => p_bg_id
  ,p_startup_mode   => p_startup_mode
  ,p_user_name      => l_base_name
  ,p_user_entity_id => p_user_entity_id
  ,p_prefixes       => p_dbi_prefixes
  ,p_suffix         => p_suffix
  ,p_date_p         => p_date_p
  );

end update_dbis;

begin

  -- ============================== --
  -- Fetch input value information. --
  -- ============================== --
  open csr_input_value_info
       (p_input_value_id => p_input_value_id
       ,p_effective_date => p_effective_date
       );
  fetch csr_input_value_info
  into  l_multi_entries
  ,     l_leg_code
  ,     l_bg_id
  ,     l_uom
  ,     l_generate_dbis
  ;
  l_found := csr_input_value_info%found;
  close csr_input_value_info;

  assert(l_found, 'update_input_value:1', p_input_value_id);

  if l_generate_dbis <> 'Y' then
    --
    -- No need to do anything.
    --
    return;
  end if;

  --
  -- Get the startup mode. This only needs to be done at this
  -- stage as l_bg_id and l_leg_code should not change.
  --
  if g_triggers_altered then
    l_startup_mode := ffstup.get_mode(l_bg_id, l_leg_code);
  end if;

  -- Force fetch of element type information.
  l_prefix := null;

  -- ==================================================== --
  -- Are there DATE_PAID / non-DATE_PAID database items ? --
  -- ==================================================== --
  l_do_date_p :=
  has_date_paid_dbis
  (p_creator_type => 'I'
  ,p_creator_id   => p_input_value_id
  );

  l_do_non_date_p :=
  has_non_date_paid_dbis
  (p_creator_type => 'I'
  ,p_creator_id   => p_input_value_id
  );

  -- ============================== --
  -- Database item processing code. --
  -- ============================== --
  loop

    --
    -- Loop control based upon processing DATE PAID and non-DATE PAID
    -- database items.
    --
    if l_do_non_date_p then
      l_date_p := null;
      l_do_non_date_p := false;
    elsif l_do_date_p then
      l_date_p := '_DP';
      l_do_date_p := false;
    else
      exit;
    end if;

    -- ========================================= --
    -- Process the dbis for the _I1 user entity. --
    -- ========================================= --

    --
    -- This must be done for the first dbi in each user entity.
    --
    l_ueid := null;

    -- UNIT_OF_MEASURE --
    update_dbis
    (p_input_value_id => p_input_value_id
    ,p_leg_code       => l_leg_code
    ,p_bg_id          => l_bg_id
    ,p_prefix         => l_prefix
    ,p_dbi_prefixes   => p_dbi_prefixes
    ,p_date_p         => l_date_p
    ,p_startup_mode   => l_startup_mode
    ,p_languages      => p_languages
    ,p_user_entity_id => l_ueid
    ,p_suffix         => 'UNIT_OF_MEASURE'
    );

    -- UNIT_OF_MEASURE_CODE --
    update_dbis
    (p_input_value_id => p_input_value_id
    ,p_leg_code       => l_leg_code
    ,p_bg_id          => l_bg_id
    ,p_prefix         => l_prefix
    ,p_dbi_prefixes   => p_dbi_prefixes
    ,p_date_p         => l_date_p
    ,p_startup_mode   => l_startup_mode
    ,p_languages      => p_languages
    ,p_user_entity_id => l_ueid
    ,p_suffix         => 'UNIT_OF_MEASURE_CODE'
    );

    -- ========================================= --
    -- Process the dbis for the _I2 user entity. --
    -- ========================================= --

    --
    -- This must be done for the first dbi in each user entity.
    --
    l_ueid := null;

    -- DEFAULT --
    update_dbis
    (p_input_value_id => p_input_value_id
    ,p_leg_code       => l_leg_code
    ,p_bg_id          => l_bg_id
    ,p_prefix         => l_prefix
    ,p_dbi_prefixes   => p_dbi_prefixes
    ,p_date_p         => l_date_p
    ,p_startup_mode   => l_startup_mode
    ,p_languages      => p_languages
    ,p_user_entity_id => l_ueid
    ,p_suffix         => 'DEFAULT'
    );

    -- MIN --
    update_dbis
    (p_input_value_id => p_input_value_id
    ,p_leg_code       => l_leg_code
    ,p_bg_id          => l_bg_id
    ,p_prefix         => l_prefix
    ,p_dbi_prefixes   => p_dbi_prefixes
    ,p_date_p         => l_date_p
    ,p_startup_mode   => l_startup_mode
    ,p_languages      => p_languages
    ,p_user_entity_id => l_ueid
    ,p_suffix         => 'MIN'
    );

    -- MAX --
    update_dbis
    (p_input_value_id => p_input_value_id
    ,p_leg_code       => l_leg_code
    ,p_bg_id          => l_bg_id
    ,p_prefix         => l_prefix
    ,p_dbi_prefixes   => p_dbi_prefixes
    ,p_date_p         => l_date_p
    ,p_startup_mode   => l_startup_mode
    ,p_languages      => p_languages
    ,p_user_entity_id => l_ueid
    ,p_suffix         => 'MAX'
    );

    -- ================================= --
    -- Multiple Entries are not allowed. --
    -- ================================= --
    if l_multi_entries = 'N' then
      -- ========================================= --
      -- Process the dbis for the _I3 user entity. --
      -- ========================================= --

      --
      -- This must be done for the first dbi in each user entity.
      --
      l_ueid := null;

      -- ENTRY_VALUE --
      update_dbis
      (p_input_value_id => p_input_value_id
      ,p_leg_code       => l_leg_code
      ,p_bg_id          => l_bg_id
      ,p_prefix         => l_prefix
      ,p_dbi_prefixes   => p_dbi_prefixes
      ,p_date_p         => l_date_p
      ,p_startup_mode   => l_startup_mode
      ,p_languages      => p_languages
      ,p_user_entity_id => l_ueid
      ,p_suffix         => 'ENTRY_VALUE'
      );

      -- USER_ENTERED_CODE --
      update_dbis
      (p_input_value_id => p_input_value_id
      ,p_leg_code       => l_leg_code
      ,p_bg_id          => l_bg_id
      ,p_prefix         => l_prefix
      ,p_dbi_prefixes   => p_dbi_prefixes
      ,p_date_p         => l_date_p
      ,p_startup_mode   => l_startup_mode
      ,p_languages      => p_languages
      ,p_user_entity_id => l_ueid
      ,p_suffix         => 'USER_ENTERED_CODE'
      );

      -- START_DATE --
      update_dbis
      (p_input_value_id => p_input_value_id
      ,p_leg_code       => l_leg_code
      ,p_bg_id          => l_bg_id
      ,p_prefix         => l_prefix
      ,p_dbi_prefixes   => p_dbi_prefixes
      ,p_date_p         => l_date_p
      ,p_startup_mode   => l_startup_mode
      ,p_languages      => p_languages
      ,p_user_entity_id => l_ueid
      ,p_suffix         => 'START_DATE'
      );

      -- END_DATE --
      update_dbis
      (p_input_value_id => p_input_value_id
      ,p_leg_code       => l_leg_code
      ,p_bg_id          => l_bg_id
      ,p_prefix         => l_prefix
      ,p_dbi_prefixes   => p_dbi_prefixes
      ,p_date_p         => l_date_p
      ,p_startup_mode   => l_startup_mode
      ,p_languages      => p_languages
      ,p_user_entity_id => l_ueid
      ,p_suffix         => 'END_DATE'
      );

      -- ========================================= --
      -- Process the dbis for the _I4 user entity. --
      -- ========================================= --

      --
      -- This must be done for the first dbi in each user entity.
      --
      l_ueid := null;

      -- OVERRIDE_ENTRY_VALUE --
      update_dbis
      (p_input_value_id => p_input_value_id
      ,p_leg_code       => l_leg_code
      ,p_bg_id          => l_bg_id
      ,p_prefix         => l_prefix
      ,p_dbi_prefixes   => p_dbi_prefixes
      ,p_date_p         => l_date_p
      ,p_startup_mode   => l_startup_mode
      ,p_languages      => p_languages
      ,p_user_entity_id => l_ueid
      ,p_suffix         => 'OVERRIDE_ENTRY_VALUE'
      );

      -- OVERRIDE_USER_ENTERED_CODE --
      update_dbis
      (p_input_value_id => p_input_value_id
      ,p_leg_code       => l_leg_code
      ,p_bg_id          => l_bg_id
      ,p_prefix         => l_prefix
      ,p_dbi_prefixes   => p_dbi_prefixes
      ,p_date_p         => l_date_p
      ,p_startup_mode   => l_startup_mode
      ,p_languages      => p_languages
      ,p_user_entity_id => l_ueid
      ,p_suffix         => 'OVERRIDE_USER_ENTERED_CODE'
      );

      -- OVERRIDE_START_DATE --
      update_dbis
      (p_input_value_id => p_input_value_id
      ,p_leg_code       => l_leg_code
      ,p_bg_id          => l_bg_id
      ,p_prefix         => l_prefix
      ,p_dbi_prefixes   => p_dbi_prefixes
      ,p_date_p         => l_date_p
      ,p_startup_mode   => l_startup_mode
      ,p_languages      => p_languages
      ,p_user_entity_id => l_ueid
      ,p_suffix         => 'OVERRIDE_START_DATE'
      );

      -- OVERRIDE_END_DATE --
      update_dbis
      (p_input_value_id => p_input_value_id
      ,p_leg_code       => l_leg_code
      ,p_bg_id          => l_bg_id
      ,p_prefix         => l_prefix
      ,p_dbi_prefixes   => p_dbi_prefixes
      ,p_date_p         => l_date_p
      ,p_startup_mode   => l_startup_mode
      ,p_languages      => p_languages
      ,p_user_entity_id => l_ueid
      ,p_suffix         => 'OVERRIDE_END_DATE'
      );

    -- ============================= --
    -- Multiple Entries are allowed. --
    -- ============================= --
    else
      if uom_requires_dbis(p_uom => l_uom) then
        -- ========================================= --
        -- Process the dbis for the _I3 user entity. --
        -- ========================================= --

        --
        -- This must be done for the first dbi in each user entity.
        --
        l_ueid := null;

        -- ENTRY_VALUE --
        update_dbis
        (p_input_value_id => p_input_value_id
        ,p_leg_code       => l_leg_code
        ,p_bg_id          => l_bg_id
        ,p_prefix         => l_prefix
        ,p_dbi_prefixes   => p_dbi_prefixes
        ,p_date_p         => l_date_p
        ,p_startup_mode   => l_startup_mode
        ,p_languages      => p_languages
        ,p_user_entity_id => l_ueid
        ,p_suffix         => 'ENTRY_VALUE'
        );

        -- ========================================= --
        -- Process the dbis for the _I4 user entity. --
        -- ========================================= --

        --
        -- This must be done for the first dbi in each user entity.
        --
        l_ueid := null;

        -- OVERRIDE_ENTRY_VALUE --
        update_dbis
        (p_input_value_id => p_input_value_id
        ,p_leg_code       => l_leg_code
        ,p_bg_id          => l_bg_id
        ,p_prefix         => l_prefix
        ,p_dbi_prefixes   => p_dbi_prefixes
        ,p_date_p         => l_date_p
        ,p_startup_mode   => l_startup_mode
        ,p_languages      => p_languages
        ,p_user_entity_id => l_ueid
        ,p_suffix         => 'OVERRIDE_ENTRY_VALUE'
        );

      end if;
    end if;
  end loop;

end update_input_value;

--
-- Interface 2: references PAY_INPUT_VALUES_F_TL.
--
procedure update_input_value
(p_input_value_id in number
,p_effective_date in date
,p_languages      in dbms_sql.varchar2s
) is
l_prefixes t_dbi_prefixes;
begin
  -- ========================== --
  -- Generate the _TL prefixes. --
  -- ========================== --
  gen_eiv_dbi_prefixes
  (p_input_value_id => p_input_value_id
  ,p_effective_date => p_effective_date
  ,p_languages      => p_languages
  ,p_prefixes       => l_prefixes
  );

  -- ========================================== --
  -- Call the overloaded version with prefixes. --
  -- ========================================== --
  update_input_value
  (p_input_value_id => p_input_value_id
  ,p_effective_date => p_effective_date
  ,p_languages      => p_languages
  ,p_dbi_prefixes   => l_prefixes
  );
end update_input_value;

--
-- Is it necessary to generate database items for the UOM if multiple
-- entries are allowed ?
--
-- Code extracted as it is used in more than one place.
--
function uom_requires_dbis
(p_uom in varchar2
) return boolean is
begin
  return p_uom like 'H_%' -- Hours
      or p_uom = 'I'      -- Integer
      or p_uom = 'M'      -- Money
      or p_uom = 'N'      -- Number
      ;
end uom_requires_dbis;

--
-- Run legislation-specific translation procedure.
--
-- P_ERRORS collects errors in this procedure.
--
procedure process_leg_translations
(p_errors in out nocopy dbms_sql.varchar2_table
) is
l_dummy        varchar2(1);
l_package_name varchar2(1000);
l_debug        boolean := hr_utility.debug_enabled;
--
-- Cursor to fetch information on legislations that support translations.
--
cursor csr_fetch_legs is
select plr.legislation_code
from   pay_legislation_rules plr
where  rule_type = 'FF_TRANSLATE_DATABASE_ITEMS'
and    rule_mode = 'Y'
;
--
-- Cursor to check validity of a package.
--
cursor csr_package_exists(p_package_name in varchar2) is
select null
from   user_objects uo
where  uo.object_name = p_package_name
and    uo.object_type = 'PACKAGE BODY'
and    uo.status ='VALID'
;
begin
  if l_debug then
    hr_utility.set_location('PROCESS_LEG_TRANSLATIONS', 5);
  end if;

  --
  -- Loop through the available legislations.
  --
  for crec in csr_fetch_legs loop

    if l_debug then
      hr_utility.set_location('PROCESS_LEG_TRANSLATIONS:' || crec.legislation_code, 15);
    end if;
    --
    -- Build the package name, PAY_<LEG_CODE>_DBI_PKG, and only execute <PKG>.TRANSLATE
    -- if it exists.
    --
    begin
      l_package_name := upper('PAY_' || crec.legislation_code || '_DBI_PKG');
      open csr_package_exists(p_package_name => l_package_name);
      fetch csr_package_exists
      into  l_dummy
      ;
      if csr_package_exists%found then
        if l_debug then
          hr_utility.set_location('PROCESS_LEG_TRANSLATIONS:' || l_package_name || '.TRANSLATE', 25);
        end if;

        execute immediate
        'begin  '|| l_package_name || '.TRANSLATE; end;';
      end if;

      close csr_package_exists;
    exception
      when others then
        if csr_package_exists%isopen then
          close csr_package_exists;
        end if;

        if l_debug then
          hr_utility.set_location('PROCESS_LEG_TRANSLATIONS:' || sqlerrm, 30);
        end if;

        p_errors(p_errors.count + 1) := sqlerrm;
    end;

  end loop;

  if l_debug then
    hr_utility.set_location('PROCESS_LEG_TRANSLATIONS', 35);
  end if;

exception
  when others then

    if l_debug then
      hr_utility.set_location('PROCESS_LEG_TRANSLATIONS', 45);
    end if;

    p_errors(p_errors.count + 1) := sqlerrm;
end process_leg_translations;

-- ================================ --
-- Process PAY_DYNDBI_CHANGES rows. --
-- ================================ --

--
-- Procedure to fetch changes for a particular entity type.
--
procedure fetch_dyndbi_changes
(p_type      in            varchar2
,p_ids          out nocopy dbms_sql.number_table
,p_languages    out nocopy dbms_sql.varchar2s
) is
cursor csr_dyndbi_changes
(p_type in varchar2
) is
select pdc.id
,      pdc.language
from   pay_dyndbi_changes pdc
where  pdc.type = p_type
order  by 1, 2
;
begin
  open csr_dyndbi_changes(p_type => p_type);
  fetch csr_dyndbi_changes bulk collect
  into  p_ids
  ,     p_languages
  ;
  close csr_dyndbi_changes;
end fetch_dyndbi_changes;

--
-- From the lists returned from FETCH_DYNDBI_CHANGES, return the
-- _id to process, the list of languages, and the next index
-- to start from.
--
procedure next_dyndbi_change
(p_ids       in            dbms_sql.number_table
,p_languages in            dbms_sql.varchar2s
,p_start     in out nocopy binary_integer
,p_id           out nocopy number
,p_id_langs     out nocopy dbms_sql.varchar2s
) is
i    binary_integer;
j    binary_integer;
l_id number;
begin
  --
  -- Perform initialisations.
  --
  l_id := p_ids(p_start);
  p_id := l_id;

  i := p_start;
  j := 1;

  while p_ids.exists(i) and p_ids(i) = l_id loop
    p_id_langs(j) := p_languages(i);
    j := j + 1;
    i := i + 1;
  end loop;

  --
  -- Set the next start point.
  --
  p_start := i;
end next_dyndbi_change;

procedure process_pay_dyndbi_changes
(errbuf                out nocopy varchar2
,retcode               out nocopy number
,p_element_types    in     varchar2
,p_input_values     in     varchar2
,p_defined_balances in     varchar2
,p_localization     in     varchar2
) is
l_proc      varchar2(2000) := 'PROCESS_PAY_DYNDBI_CHANGES:';
l_ids       dbms_sql.number_table;
l_languages dbms_sql.varchar2s;
l_id        number;
l_id_langs  dbms_sql.varchar2s;
i           binary_integer;
l_eff_date  date;
l_found     boolean;
l_cnt       binary_integer;
l_dummy     varchar2(1);
l_rowids    dbms_sql.varchar2s;
l_messages  dbms_sql.varchar2_table;
l_errors    dbms_sql.varchar2_table;
l_debug     boolean := hr_utility.debug_enabled;
l_newline   varchar2(10) := '
';
l_separator varchar2(100);
--
cursor csr_ele_eff_date
(p_element_type_id in number
) is
select et.effective_end_date
from   pay_element_types_f et
where  et.element_type_id = p_element_type_id
order  by 1 desc
;
--
cursor csr_ipv_eff_date
(p_input_value_id in number
) is
select iv.effective_end_date
from   pay_input_values_f iv
where  iv.input_value_id = p_input_value_id
order  by 1 desc
;
--
cursor csr_def_balance
(p_defined_balance_id in number
) is
select to_char(null)
from   pay_defined_balances db
where  db.defined_balance_id = p_defined_balance_id
;
--
procedure init_cnt(p_cnt in out nocopy binary_integer) is
begin
  p_cnt := 1;
end init_cnt;
--
procedure incr_cnt(p_cnt in out nocopy binary_integer) is
begin
  if mod(p_cnt, 50) = 0 then
    commit;
    init_cnt(p_cnt => p_cnt);
  else
    p_cnt := p_cnt + 1;
  end if;
end incr_cnt;

begin
  -- Assume success.
  retcode := 0;
  errbuf := null;

  g_dyndbi_changes := true;
  g_security_group_id :=
  fnd_global.lookup_security_group('NAME_TRANSLATIONS', 3);

  if l_debug then
    hr_utility.set_location('process_pay_dyndbi_changes', 0);
  end if;

  --
  -- Set log file message separator.
  --
  l_separator := l_newline || '--------------------------------' || l_newline;

  -- ============== --
  -- Element Types. --
  -- ============== --
  if upper(p_element_types) = 'Y' then

    if l_debug then
      hr_utility.set_location('process_pay_dyndbi_changes', 10);
    end if;

    --
    -- Initialise everything.
    --
    l_ids.delete;
    l_languages.delete;
    i := 1;

    --
    -- Fetch the PAY_DYNDBI_CHANGES rows.
    --
    fetch_dyndbi_changes
    (p_type      => pay_dyndbi_changes_pkg.c_element_type
    ,p_ids       => l_ids
    ,p_languages => l_languages
    );

    if l_debug then
      hr_utility.set_location('process_pay_dyndbi_changes', 20);
    end if;

    --
    -- Do the updates.
    --
    init_cnt(p_cnt => l_cnt);

    while l_ids.exists(i) loop

      if l_debug then
        hr_utility.set_location('process_pay_dyndbi_changes', 30);
      end if;

      l_id_langs.delete;
      next_dyndbi_change
      (p_ids       => l_ids
      ,p_languages => l_languages
      ,p_start     => i
      ,p_id        => l_id
      ,p_id_langs  => l_id_langs
      );

      --
      -- Fetch the effective date.
      --
      open csr_ele_eff_date(p_element_type_id => l_id);
      fetch csr_ele_eff_date
      into  l_eff_date
      ;
      l_found := csr_ele_eff_date%found;
      close csr_ele_eff_date;

      if l_debug then
        hr_utility.set_location('process_pay_dyndbi_changes', 40);
      end if;

      g_dyndbi_changes_ok := true;
      if l_found then

        if l_debug then
          hr_utility.set_location('process_pay_dyndbi_changes', 50);
        end if;

        begin
          update_element_type
          (p_element_type_id => l_id
          ,p_effective_date  => l_eff_date
          ,p_languages       => l_id_langs
          );
        exception
          when others then
            g_dyndbi_changes_ok := false;
            fnd_file.put(fnd_file.log, l_separator);
            fnd_file.put(fnd_file.log, sqlerrm);
            errbuf := sqlerrm;
            retcode := 2;
        end;

        if l_debug then
          hr_utility.set_location('process_pay_dyndbi_changes', 60);
        end if;
      else
        hr_utility.trace(l_proc||'no such element '||l_id);
      end if;

      if l_debug then
        hr_utility.set_location('process_pay_dyndbi_changes', 70);
      end if;

      --
      -- Delete the PAY_DYNDBI_CHANGES rows.
      --
      if g_dyndbi_changes_ok then
        pay_dyndbi_changes_pkg.delete_rows
        (p_id   => l_id
        ,p_type => pay_dyndbi_changes_pkg.c_element_type
        );
      end if;

      if l_debug then
        hr_utility.set_location('process_pay_dyndbi_changes', 80);
      end if;

      incr_cnt(p_cnt => l_cnt);
    end loop;

    --
    -- COMMIT the last lot of changes.
    --
    commit;
  end if;

  if l_debug then
    hr_utility.set_location('process_pay_dyndbi_changes', 90);
  end if;

  -- ============= --
  -- Input Values. --
  -- ============= --
  if upper(p_input_values) = 'Y' then

    if l_debug then
      hr_utility.set_location('process_pay_dyndbi_changes', 100);
    end if;

    --
    -- Initialise everything.
    --
    l_ids.delete;
    l_languages.delete;
    i := 1;

    --
    -- Fetch the PAY_DYNDBI_CHANGES rows.
    --
    fetch_dyndbi_changes
    (p_type      => pay_dyndbi_changes_pkg.c_input_value
    ,p_ids       => l_ids
    ,p_languages => l_languages
    );

    if l_debug then
      hr_utility.set_location('process_pay_dyndbi_changes', 110);
    end if;

    --
    -- Do the updates.
    --
    init_cnt(p_cnt => l_cnt);

    while l_ids.exists(i) loop

      if l_debug then
        hr_utility.set_location('process_pay_dyndbi_changes', 120);
      end if;

      l_id_langs.delete;
      next_dyndbi_change
      (p_ids       => l_ids
      ,p_languages => l_languages
      ,p_start     => i
      ,p_id        => l_id
      ,p_id_langs  => l_id_langs
      );

      --
      -- Fetch the effective date.
      --
      open csr_ipv_eff_date(p_input_value_id => l_id);
      fetch csr_ipv_eff_date
      into  l_eff_date
      ;
      l_found := csr_ipv_eff_date%found;
      close csr_ipv_eff_date;

      if l_debug then
        hr_utility.set_location('process_pay_dyndbi_changes', 130);
      end if;

      g_dyndbi_changes_ok := true;
      if l_found then
        begin
          update_input_value
          (p_input_value_id => l_id
          ,p_effective_date => l_eff_date
          ,p_languages      => l_id_langs
          );
        exception
          when others then
            g_dyndbi_changes_ok := false;
            fnd_file.put(fnd_file.log, l_separator);
            fnd_file.put(fnd_file.log, sqlerrm);
            errbuf := sqlerrm;
            retcode := 2;
        end;
      else
        hr_utility.trace(l_proc||'no such input value '||l_id);
      end if;

      if l_debug then
        hr_utility.set_location('process_pay_dyndbi_changes', 140);
      end if;

      --
      -- Delete the PAY_DYNDBI_CHANGES rows.
      --
      if g_dyndbi_changes_ok then
        pay_dyndbi_changes_pkg.delete_rows
        (p_id   => l_id
        ,p_type => pay_dyndbi_changes_pkg.c_input_value
        );
      end if;

      if l_debug then
        hr_utility.set_location('process_pay_dyndbi_changes', 150);
      end if;

      incr_cnt(p_cnt => l_cnt);
    end loop;

    --
    -- COMMIT the last lot of changes.
    --
    commit;
  end if;

  if l_debug then
    hr_utility.set_location('process_pay_dyndbi_changes', 160);
  end if;

  -- ================= --
  -- Defined Balances. --
  -- ================= --
  if upper(p_defined_balances) = 'Y' then

    if l_debug then
      hr_utility.set_location('process_pay_dyndbi_changes', 170);
    end if;

    --
    -- Initialise everything.
    --
    l_ids.delete;
    l_languages.delete;
    i := 1;

    --
    -- Fetch the PAY_DYNDBI_CHANGES rows.
    --
    fetch_dyndbi_changes
    (p_type      => pay_dyndbi_changes_pkg.c_defined_balance
    ,p_ids       => l_ids
    ,p_languages => l_languages
    );

    if l_debug then
      hr_utility.set_location('process_pay_dyndbi_changes', 180);
    end if;

    --
    -- Do the updates.
    --
    init_cnt(p_cnt => l_cnt);

    while l_ids.exists(i) loop

      if l_debug then
        hr_utility.set_location('process_pay_dyndbi_changes', 190);
      end if;

      l_id_langs.delete;
      next_dyndbi_change
      (p_ids       => l_ids
      ,p_languages => l_languages
      ,p_start     => i
      ,p_id        => l_id
      ,p_id_langs  => l_id_langs
      );

      open csr_def_balance(p_defined_balance_id => l_id);
      fetch csr_def_balance
      into  l_dummy
      ;
      l_found := csr_def_balance%found;
      close csr_def_balance;

      if l_debug then
        hr_utility.set_location('process_pay_dyndbi_changes', 200);
      end if;

      g_dyndbi_changes_ok := true;
      if l_found then

        if l_debug then
          hr_utility.set_location('process_pay_dyndbi_changes', 210);
        end if;

        begin
          update_defined_balance
          (p_defined_balance_id => l_id
          ,p_languages          => l_id_langs
          );
        exception
          when others then
            g_dyndbi_changes_ok := false;
            fnd_file.put(fnd_file.log, l_separator);
            fnd_file.put(fnd_file.log, sqlerrm);
            errbuf := sqlerrm;
            retcode := 2;
        end;
      else
        hr_utility.trace(l_proc||'no defined balance '||l_id);
      end if;

      --
      -- Delete the PAY_DYNDBI_CHANGES rows.
      --
      if g_dyndbi_changes_ok then
        pay_dyndbi_changes_pkg.delete_rows
        (p_id   => l_id
        ,p_type => pay_dyndbi_changes_pkg.c_defined_balance
        );
      end if;

      if l_debug then
        hr_utility.set_location('process_pay_dyndbi_changes', 220);
      end if;

      incr_cnt(p_cnt => l_cnt);
    end loop;

    --
    -- COMMIT the last lot of changes.
    --
    commit;
  end if;

  if l_debug then
    hr_utility.set_location('process_pay_dyndbi_changes', 230);
  end if;

  --
  -- Do the legislation-specfic changes.
  --
  if upper(p_localization) = 'Y' then

    if l_debug then
      hr_utility.set_location('process_pay_dyndbi_changes', 235);
    end if;

    process_leg_translations(p_errors => l_errors);
    for i in 1 .. l_errors.count loop
      fnd_file.put(fnd_file.log, l_separator);
      fnd_file.put(fnd_file.log, l_errors(i));
    end loop;
  end if;

  --
  -- Fetch any error log messages for this process.
  --
  pay_dbitl_update_errors_pkg.fetch_all_rows
  (p_rowids   => l_rowids
  ,p_messages => l_messages
  );

  if l_debug then
    hr_utility.set_location('process_pay_dyndbi_changes', 240);
  end if;

  --
  -- Set error status if there are any error messages.
  --
  if l_messages.count <> 0 then
    errbuf := l_messages(1);
    retcode := 2;
  elsif l_errors.count <> 0 then
    errbuf := l_errors(1);
    retcode := 2;
  end if;

  --
  -- Write messages to the log.
  --
  for i in 1 .. l_messages.count loop
    fnd_file.put(fnd_file.log, l_separator);
    fnd_message.set_encoded(l_messages(i));
    fnd_file.put(fnd_file.log, fnd_message.get);
  end loop;

  --
  -- Delete the messages.
  --
  pay_dbitl_update_errors_pkg.delete_rows
  (p_rowids => l_rowids
  );

  g_dyndbi_changes := false;

  if l_debug then
    hr_utility.set_location('process_pay_dyndbi_changes', 250);
  end if;

commit; /*Bug 8512762 Added commit as FND is not commiting if status is error (retcode =2 )*/

exception
  when others then
    g_dyndbi_changes := false;
    errbuf := sqlerrm;
    retcode := 2;

    if l_debug then
      hr_utility.set_location('process_pay_dyndbi_changes', 300);
    end if;
end process_pay_dyndbi_changes;

end hrdyndbi;

/

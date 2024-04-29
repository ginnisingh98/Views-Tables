--------------------------------------------------------
--  DDL for Package PAYWSDYG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAYWSDYG_PKG" AUTHID CURRENT_USER AS
-- $Header: pydygpkg.pkh 120.0 2005/05/29 04:25:40 appldev noship $
--
--
-- +---------------------------------------------------------------------------+
-- | Global Constants                                                          |
-- +---------------------------------------------------------------------------+
  type t_varchar2_32k_tbl is table of varchar2(32767) index by binary_integer;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : insert_parameters                                            |
-- | DESCRIPTION: Helper procedure to maintain parameters                      |
-- |            Inserts new rows if none exist, otherwise updates the          |
-- |            existing row if it's 'automatic' flag is 'not 'N' ('Y'or null) |
-- | PARAMETERS : p_usage_type     - Value for the usage_type column           |
-- |              p_usage_id       - Value for the usage_id column             |
-- |              p_parameter_type - Value for the parameter_type column       |
-- |              p_parameter_name - Value for the parameter_name column       |
-- |              p_value_name     - Value for the value_name column           |
-- |              p_automatic      - Value for the automatic column            |
-- | RETURNS    : The primary key of the new or existing row                   |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
  FUNCTION insert_parameters(
    p_usage_type      IN VARCHAR2 DEFAULT NULL,
    p_usage_id        IN NUMBER   DEFAULT NULL,
    p_parameter_type  IN VARCHAR2 DEFAULT NULL,
    p_parameter_name  IN VARCHAR2 DEFAULT NULL,
    p_value_name      IN VARCHAR2 DEFAULT NULL,
    p_automatic       IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;


-- +---------------------------------------------------------------------------+
-- | NAME       : drop_trigger                                                 |
-- | DESCRIPTION: Drops the database trigger with the name specified. First    |
-- |              checks that the trigger specified exists, then uses the AOL  |
-- |              procedure ad_ddl.do_ddl to execute a DROP TRIGGER command.   |
-- |              This will drop any trigger (assuming that the executing user |
-- |              has the correct permissions) not just those created by the   |
-- |              Dynamic Trigger Generation system.                           |
-- | PARAMETERS : p_name - The name of the trigger to drop, case insensitive   |
-- | RETURNS    : None                                                         |
-- | RAISES     : None - The AOL routine traps and suppresses any exceptions   |
-- +---------------------------------------------------------------------------+
  PROCEDURE drop_trigger(p_name IN VARCHAR2);
--
-- +---------------------------------------------------------------------------+
-- | NAME       : drop_trigger_indirect                                        |
-- | DESCRIPTION: Drops the database trigger based only on it's primary key.   |
-- | PARAMETERS : p_id - The primary key of the trigger to drop.               |
-- | RETURNS    : None                                                         |
-- | RAISES     : None - The AOL routine traps and suppresses any exceptions   |
-- +---------------------------------------------------------------------------+
  PROCEDURE drop_trigger_indirect(p_id IN NUMBER);
--
-- +---------------------------------------------------------------------------+
-- | NAME       : create_trigger                                               |
-- | DESCRIPTION: Creates (or replaces) the trigger with the specified name    |
-- |              on the required table.                                       |
-- |              The trigger is always created as an 'After each row' type    |
-- |              trigger, the triggering action is specified via the          |
-- |              abbreviation I, U or D.                                      |
-- |              The trigger is created using the supplied PL/SQL block which |
-- |              must not contain the CREATE TRIGGER clause (or the CREATE    |
-- |              statement will raise an exception since this procedure adds  |
-- |              that code itself). The trigger name                          |
-- |              should have been obtained via a call to "get_trigger_name"   |
-- |              so that it is in the standard format for Dynamically         |
-- |              Generated triggers, but that isn't vaildated here.           |
-- | PARAMETERS : p_trigger - Name of the trigger to create                    |
-- |              p_table   - Table to add the trigger to                      |
-- |              p_action  - Triggering action, I U or D for Insert Update or |
-- |                          Delete respectively                              |
-- |              p_sql     - PL/SQL block to use for the trigger body         |
-- | RETURNS    : None                                                         |
-- | RAISES     : Standard - Any errors encountered by the trigger creation DDL|
-- +---------------------------------------------------------------------------+
  PROCEDURE create_trigger(
    p_trigger IN VARCHAR2,
    p_table   IN VARCHAR2,
    p_action  IN VARCHAR2,
    p_sql     IN VARCHAR2
  );
-- +---------------------------------------------------------------------------+
-- | NAME       : get_trigger_name                                             |
-- | DESCRIPTION: Generates the trigger name so that they're always created    |
-- |              in the same format                                           |
-- | PARAMETERS : p_id     - Primary key of the event that owns the trigger    |
-- |              p_table  - Table that the trigger will be created against    |
-- |              p_action - The triggering action I, U or D for Insert, Update|
-- |                         or Delete                                         |
-- | RETURNS    : The generated trigger name                                   |
-- | RAISES     : Nothing - n/a                                                |
-- +---------------------------------------------------------------------------+
  FUNCTION get_trigger_name(
    p_id IN NUMBER,
    p_table IN VARCHAR2,
    p_action IN VARCHAR2
  ) RETURN VARCHAR2;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : enable_trigger                                               |
-- | DESCRIPTION: Enables or disables the specified trigger. Uses the standard |
-- |              DDL 'ALTER TRIGGER ... ENABLE/DISABLE' command (executed     |
-- |              using the AOL do_ddl procedure). Any trigger can be enabled  |
-- |              or disabled, if the user has correct permissions, not just   |
-- |              those generated dynamically.                                 |
-- | PARAMETERS : p_trigger - Trigger name                                     |
-- |              p_enabled - TRUE to enable the trigger, FALSE to disable     |
-- | RETURNS    : None                                                         |
-- | RAISES     : Standard - Any errors encountered by the ALTER TRIGGER       |
-- |              statement DDL                                                |
-- +---------------------------------------------------------------------------+
  PROCEDURE enable_trigger(p_trigger IN VARCHAR2,p_enabled IN BOOLEAN);
--
-- +---------------------------------------------------------------------------+
-- | NAME       : map_parameter_list                                           |
-- | DESCRIPTION: Describes the PL/SQL stored module (packaged procedure,      |
-- |              function or standalone module) and attempts to create        |
-- |              mappings between the module parameters and the trigger code. |
-- |              Also checks that the module is valid for the type of         |
-- |              operation it is being included in.                           |
-- |              Will not create the parameters if p_validate_only is TRUE,   |
-- |              only the validation operations are carried out.              |
-- |              This procedure could be used during seed data creation by;   |
-- |              creating an event record, creating a component child of this |
-- |              event, calling this routine passing the details of the new   |
-- |              component record. Default mappings for the parameters will   |
-- |              be created but this DOES NOT MEAN that the trigger can be    |
-- |              generated and compiled successfully. The AutoMapper may (in  |
-- |              it's current state) create mappings to local variables that  |
-- |              do not exist. It is the developer's responsibility (just as  |
-- |              it is the user's when using the Forms front end) to create   |
-- |              the necessary local declaration records before attempting to |
-- |              generate and enable the trigger.                             |
-- | PARAMETERS : p_id            - The primary key of the associated component|
-- |              p_module        - Name of module to be called                |
-- |              p_type          - Type of module F or P for Function or      |
-- |                                Procedure, C type usages can only be of    |
-- |                                type P, although this is not enforced here |
-- |              p_usage         - The way in which the module will be used,  |
-- |                                I for initialisation or C for component    |
-- |              p_validate_only - Set to TRUE to stop parameters being       |
-- |                                created but still raise any errors that    |
-- |                                occur, used during Forms validation.       |
-- |                                Defaulted to FALSE so that, by default the |
-- |                                parameter mappings will be created.        |
-- | RETURNS    : None                                                         |
-- | RAISES     : could_not_describe_module   - Usually because the module     |
-- |                                            does not exist                 |
-- |              module_is_overloaded        - The Dynamic Trigger Generator  |
-- |                                            cannot use overloaded modules  |
-- |              unsupported_parameter_type  - Only VARCHAR2, NUMBER and DATE |
-- |                                            type parameters can be used    |
-- |              incompatible_parameter_mode - The IN/OUT mode of one or more |
-- |                                            parameters is not compatible   |
-- |                                            with the way in which the      |
-- |                                            module is being used           |
-- +---------------------------------------------------------------------------+
  PROCEDURE map_parameter_list(
    p_id            IN NUMBER,
    p_module        IN VARCHAR2,
    p_type          IN VARCHAR2,
    p_usage         IN VARCHAR2,
    p_validate_only IN BOOLEAN DEFAULT FALSE
  );
--
-- +---------------------------------------------------------------------------+
-- | NAME       : automap_parameters                                           |
-- | DESCRIPTION: Automatically map the parameters for the modules used        |
-- |              by the supplied event. An optional component (or             |
-- |              initialisation) ID can be specified so that only the         |
-- |              parameters of this module are mapped. Just a helper routine  |
-- |              really to wrap up the complexities of mapping the parameters |
-- |              for different types of initialisation or component. Can be   |
-- |              used instead of 'map_parameter_list' if you know the event   |
-- |              primary key and the component or initialisation primary key  |
-- |              and want to auto map the parameters but don't know (or can't |
-- |              be bothered to find out) it's name or type. Can also be used |
-- |              during dataload/seeding type operations to automap the       |
-- |              parameters for SQL select or assignment type initialisations.|
-- | PARAMETERS : p_id      - The primary key of the event to process          |
-- |              p_usage   - The type of usages to process, I for             |
-- |                          initialisations or C for components              |
-- |              p_comp_id - The specific component (or initialisation) to    |
-- |                          process, defaults to NULL for all components     |
-- | RETURNS    : None                                                         |
-- | RAISES     : Standard - Anything that is raised by modules it calls, e.g. |
-- |              custom errors raised by map_parameter_list.                  |
-- +---------------------------------------------------------------------------+
  PROCEDURE automap_parameters(
    p_id      IN NUMBER,
    p_usage   IN VARCHAR2,
    p_comp_id IN NUMBER DEFAULT NULL
  );
--
-- +---------------------------------------------------------------------------+
-- | NAME       : replace_placeholders                                         |
-- | DESCRIPTION: Replace the placeholders (e.g. $NEW_PERSON_ID$) with the     |
-- |              correct variable name or bind variable as specified in the   |
-- |              parameter mappings table. Should never need to call this     |
-- |              directly but used by the Form (and internally) so needs to be|
-- |              declared public.
-- | PARAMETERS : p_sql   - The PL/SQL or SQL code to which contains the       |
-- |                        placeholders to be replaced                        |
-- |              p_id    - The ID of the initialisation which this SQL is     |
-- |                        associated with                                    |
-- |              p_extra - Any extra text to place before the replaced name,  |
-- |                        used by the SQL select statement verifier to       |
-- |                        "fool" the parser into correctly processing the    |
-- |                        statement by pretending that local (to the trigger)|
-- |                        variables are bind variables.                      |
-- | RETURNS    : The modified SQL statement via the IN/OUT parameter          |
-- | RAISES     : None - Should never :-) raise any exceptions                 |
-- +---------------------------------------------------------------------------+
  PROCEDURE replace_placeholders(
    p_sql IN OUT NOCOPY VARCHAR2,
    p_id IN NUMBER,
    p_extra IN VARCHAR2 DEFAULT NULL
  );
--
-- +---------------------------------------------------------------------------+
-- | NAME       : lob_to_varchar2                                              |
-- | DESCRIPTION: Converts a character large object (CLOB) into a VARCHAR2 so  |
-- |              that it can be more easily processed.                        |
-- |              N.B. This means that the largest piece of code (which is     |
-- |              what is stored in these CLOBS) that can be handled by the    |
-- |              trigger generation module is 32Kb even though the CLOB itself|
-- |              can hold something like 2Gb.                                 |
-- | PARAMETERS : return - The CLOB converted to a VARCHAR2                    |
-- |              p_clob - The CLOB to be converted                            |
-- | RETURNS    : The CLOB converted to a VARCHAR2                             |
-- | RAISES     : Standard - May raise errors if the data in the CLOB will not |
-- |                         fit into the VARCHAR2. Should only happen if data |
-- |                         has been populated other than through the front   |
-- |                         end Form. The Form will prevent more than 32Kb    |
-- |                         being entered by the user.                        |
-- +---------------------------------------------------------------------------+
  FUNCTION lob_to_varchar2(p_clob IN OUT NOCOPY CLOB) RETURN VARCHAR2;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : get_reverted                                                 |
-- | DESCRIPTION: Retrieves the last saved version of a supporting package's   |
-- |              code, to provide a kind of primitive 'Undo' functionality.   |
-- |              In the support package maintenance portion of the Dynamic    |
-- |              Trigger generation form, when the user attempts to save the  |
-- |              record the Form tries to compile the code, if it fails and   |
-- |              the user Cancels the error message list box then the code    |
-- |              will not be saved. They could then press the Revert button to|
-- |              retrieve the last saved version of the code which is (or     |
-- |              should be) valid. It is this procedure that supports that    |
-- |              functionality.                                               |
-- | PARAMETERS : p_id   - Primary key of the supporting package to retrieve   |
-- |              p_head - Populated with the last saved package header        |
-- |              p_body - Populated with the last saved package body code     |
-- | RETURNS    : Package header and body source code via the OUT parameters   |
-- | RAISES     : None - n/a                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE get_reverted(
    p_id    IN     NUMBER,
    p_head     OUT NOCOPY VARCHAR2,
    p_body     OUT NOCOPY VARCHAR2
  );
--
-- +---------------------------------------------------------------------------+
-- | NAME       : compile_package                                              |
-- | DESCRIPTION: Compile the supporting package for the specified event using |
-- |              the AOL create_package procedure to ensure that it is created|
-- |              in the 'proper' way. The package is named according to the   |
-- |              standard format <TABLE_NAME>_<ID>_DYG where; <TABLE_NAME> is |
-- |              the name of the table that the owning event's trigger will be|
-- |              created against, with underscores removed and truncated so   |
-- |              that the package name does not exceed 30 characters and <ID> |
-- |              is the primary key of the owning event.                      |
-- | PARAMETERS : p_event   - The primary key of the event that the supporting |
-- |                          package belongs to                               |
-- |              p_table   - The table that the event's trigger will be       |
-- |                          created on                                       |
-- |              p_header  - The package header code without the CREATE clause|
-- |                          or the final END statement                       |
-- |              p_body    - The package body code without the CREATE clause  |
-- |                          or the final END statement                       |
-- |              p_name    - Populated with the generated package name, any   |
-- |                          value that is present in this variable on input  |
-- |                          is ignored.                                      |
-- |              p_head_ok - Populated with a flag to indicate whether or not |
-- |                          the package header was compiled without errors   |
-- |              p_body_ok - Populated with a flag indicating whether the     |
-- |                          package body was successfully compiled or not    |
-- | RETURNS    : The package name and compilation success flags via IN/OUT    |
-- |              parameters.                                                  |
-- | RAISES     : None - All errors are trapped, the caller should examine the |
-- |              p_head_ok and p_body_ok flags to determine whether or not the|
-- |              package compiled successfully.                               |
-- +---------------------------------------------------------------------------+
  PROCEDURE compile_package(
    p_event   IN     NUMBER,
    p_table   IN     VARCHAR2,
    p_header  IN     VARCHAR2,
    p_body    IN     VARCHAR2,
    p_name    IN OUT NOCOPY VARCHAR2,
    p_head_ok IN OUT NOCOPY BOOLEAN,
    p_body_ok IN OUT NOCOPY BOOLEAN
  );
--
-- +---------------------------------------------------------------------------+
-- | NAME       : compile_package_indirect                                     |
-- | DESCRIPTION: Silently compiles the specified supporting package. Only the |
-- |              primary key of the supporting package is required. Calls the |
-- |              compile_package procedure but wraps it in a simpler interface|
-- |              so that the developer does not need to determine the         |
-- |              information required themselves. All errors are trapped so   |
-- |              the developer is responsible for determining whether or not  |
-- |              the package compiled, if this is required.                   |
-- | PARAMETERS : p_id - The primary key of the supporting package to compile  |
-- | RETURNS    : None                                                         |
-- | RAISES     : None - All exceptions are trapped and a diagnostic message is|
-- |                     written to the hr_utility trace pipe before returning |
-- |                     to the caller normally.                               |
-- +---------------------------------------------------------------------------+
  PROCEDURE compile_package_indirect(p_id IN NUMBER);
--
-- +---------------------------------------------------------------------------+
-- | NAME       : create_defaults                                              |
-- | DESCRIPTION: Create the default declarations and initialisations that are |
-- |              required in triggers created against tables with business    |
-- |              group or payroll IDs. This procedure is used by the front end|
-- |              Form when a new event record is created to populate some     |
-- |              defaults into the child tables.\nAny dataload/seeding process|
-- |              could utilise this in the same way, i.e. create a record in  |
-- |              the pay_trigger_events table, then call this routine passing |
-- |              the primary key of the record you just created.\nIf the table|
-- |              on which the event's trigger will be created contains a      |
-- |              mandatory business_group_id column then declaration records  |
-- |              will be created for local variables l_business_group_id and  |
-- |              l_legislation_code. Initialisations will be created to       |
-- |              populate l_business_group_id from the old or new table record|
-- |              (an assignment type initialisation) and to populate the      |
-- |              legislation code by selecting it's value from the business   |
-- |              groups table.\nIf the table contains a mandatory payroll_id  |
-- |              column then a declaration record is created or the local     |
-- |              variable l_payroll_id and an initialisation record is created|
-- |              (assignment type) to populate this variable from the old or  |
-- |              new table row record.\n                                      |
-- |              These defaults are created so that components can be created |
-- |              which are only executed in specific circumstances, i.e. if   |
-- |              the payroll_id, legislation_code or business_group of the    |
-- |              record causing the trigger to fire matches the criteria      |
-- |              defined against the component.                               |
-- | PARAMETERS : p_id - The primary key of the event                          |
-- | RETURNS    : None                                                         |
-- | RAISES     : None - All error trapping and handling is done by the various|
-- |                     modules that this procedure calls.                    |
-- +---------------------------------------------------------------------------+
  PROCEDURE create_defaults(p_id IN NUMBER);
--
-- +---------------------------------------------------------------------------+
-- | NAME       : generate_trigger                                             |
-- | DESCRIPTION: Generates the database trigger for the specified event. The  |
-- |              event definition record, it's declarations, initialisations  |
-- |              components and all relevant parameter mappings must be       |
-- |              defined. One call to this procedure with the correct event   |
-- |              primary key ID will generate the code for the trigger, create|
-- |              the trigger based on the trigger definition and the generated|
-- |              code, and enable the trigger if required by the event        |
-- |              definition. The name of the generated trigger and a flag to  |
-- |              indicate success or failure are returned via out parameters. |
-- |              The generated trigger code is passed to the 'create_trigger' |
-- |              procedure which uses the AOL routines to 'properly' create   |
-- |              the required database trigger.                               |
-- | PARAMETERS : p_id   - The primary key of the event                        |
-- |              p_name - Populated with the name of the generated trigger    |
-- |              p_ok   - Populated with a flag to indicated whether or not   |
-- |                       the trigger was compiled successfully               |
-- | RETURNS    : The trigger name and success flag via the OUT parameters     |
-- | RAISES     : None - All errors are trapped, the p_ok flag should be       |
-- |              examined when the procedure returns in order to determine    |
-- |              whether or not the trigger was created successfully.         |
-- +---------------------------------------------------------------------------+
  PROCEDURE generate_trigger(
    p_id   IN     NUMBER,
    p_name IN OUT NOCOPY VARCHAR2,
    p_ok      OUT NOCOPY BOOLEAN
  );
--
-- +---------------------------------------------------------------------------+
-- | NAME       : generate_code                                                |
-- | DESCRIPTION: Creates the PL/SQL code that will be used to generate the    |
-- |              trigger, without the CREATE TRIGGER clause.                  |
-- |              Used internally (by generate_trigger) and by the client-side |
-- |              Form (so that the user can view the source of the trigger)   |
-- |              this procedure uses the definitions stored in the            |
-- |              declarations, initialisations, components and parameters     |
-- |              tables to build PL/SQL code.\n                               |
-- |              First the declarations are added                             |
-- |              to define local variables, then the initialisations which    |
-- |              populate these variables are added.\n                        |
-- |              Within the initialisations block (immediately after the      |
-- |              automatic initialisations for business group, payroll and    |
-- |              legislation code and before any user-defined initialisations)|
-- |              a call is made to paywsfat_pkg.i_am_disabled to determine    |
-- |              whether or not the trigger should be executing for the       |
-- |              triggering row's context.\n                                  |
-- |              Global components are                                        |
-- |              added, procedures which are always executed, whenever the    |
-- |              trigger fires. These are followed by legislation, business   |
-- |              group, and finally payroll specific components. These are    |
-- |              placed in IF...THEN conditions, components with the same     |
-- |              criteria are all placed in one IF statement (so, for example |
-- |              there won't be lots of IF l_legislation_code = 'GB' THEN     |
-- |              statements, there will be only one containing all the UK     |
-- |              specific components).\nComments and an exception handler are |
-- |              also added to make the code more readable and robust.        |
-- | PARAMETERS : p_id  - The primary key of the event                         |
-- |              p_sql - Will be populated with the trigger source code       |
-- | RETURNS    : The generated code via the IN OUT parameter                  |
-- | RAISES     : None - Shouldn't really raise errors, it will just create    |
-- |              invalid code, i.e. code that won't compile.                  |
-- +---------------------------------------------------------------------------+
  PROCEDURE generate_code(p_id IN NUMBER,p_sql IN OUT NOCOPY VARCHAR2);
--
-- +---------------------------------------------------------------------------+
-- | NAME       : delete_event_children                                        |
-- | DESCRIPTION: Deletes the children (e.g. support package, declarations)    |
-- |              of the specified event and drops any associated database     |
-- |              objects like packages and triggers. Doesn't delete the       |
-- |              actual event definition                                      |
-- | PARAMETERS : p_id - The primary key of the event                          |
-- | RETURNS    : None                                                         |
-- | RAISES     : Standard - Any Database (e.g. constraint) errors raised by   |
-- |              the RDBMS.                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE delete_event_children(p_id IN NUMBER);
--
-- +---------------------------------------------------------------------------+
-- | NAME       : delete_initialisation_children                               |
-- | DESCRIPTION: Deletes the children of the specified initialisation (i.e.   |
-- |              the parameter mappings that the initialisation uses)         |
-- | PARAMETERS : p_id - The initialisation primary key                        |
-- | RETURNS    : None                                                         |
-- | RAISES     : Standard - Any Database (e.g. constraint) errors raised by   |
-- |              the RDBMS.                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE delete_initialisation_children(p_id IN NUMBER);
--
-- +---------------------------------------------------------------------------+
-- | NAME       : delete_component_children                                    |
-- | DESCRIPTION: Deletes the children of the specified component (i.e. the    |
-- |              parameter mappings that the component uses)                  |
-- | PARAMETERS : p_id - The component primary key                             |
-- | RETURNS    : None                                                         |
-- | RAISES     : Standard - Any Database (e.g. constraint) errors raised by   |
-- |              the RDBMS.                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE delete_component_children(p_id IN NUMBER);

-- +---------------------------------------------------------------------------+
-- | NAME       : delete_parameters_directly                                   |
-- | DESCRIPTION: Deletes an individual parameter given its ID.                |
-- |              used by table event updates form where user delets individual|
-- | PARAMETERS : p_id - The component primary key                             |
-- | RETURNS    : None                                                         |
-- | RAISES     : Standard - Any Database (e.g. constraint) errors raised by   |
-- |              the RDBMS.                                                   |
-- +---------------------------------------------------------------------------+
  PROCEDURE delete_parameters_directly(p_param_id IN NUMBER);

--
-- +---------------------------------------------------------------------------+
-- | NAME       : table_has_business_group                                     |
-- | DESCRIPTION: Checks to see if the specified table has a mandatory         |
-- |              business_group_id column                                     |
-- | PARAMETERS : return  - TRUE if table has manadatory business group ID     |
-- |              p_table - The name of the table to check                     |
-- | RETURNS    : A boolean value indicating if the table has a business group |
-- | RAISES     : None - No errors should be raised.                           |
-- +---------------------------------------------------------------------------+

  FUNCTION table_has_business_group(p_table IN VARCHAR2) RETURN BOOLEAN;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : table_has_payroll                                            |
-- | DESCRIPTION: Checks to see if the specified table has a mandatory         |
-- |              payroll_id column                                            |
-- | PARAMETERS : return  - TRUE if table has manadatory payroll ID            |
-- |              p_table - The name of the table to check                     |
-- | RETURNS    : A boolean value indicating if the table has a payroll        |
-- | RAISES     : None - No errors should be raised.                           |
-- +---------------------------------------------------------------------------+
  FUNCTION table_has_payroll(p_table IN VARCHAR2) RETURN BOOLEAN;
--
-- +---------------------------------------------------------------------------+
-- | NAME       : validate_select                                              |
-- | DESCRIPTION: Checks that the SQL select statement is valid for the way    |
-- |              in which it is being used. This should only really be used   |
-- |              internally by the front-end Form to validate user input.     |
-- |              Any seed data or dataload information should be correct and  |
-- |              hence should not need validating.                            |
-- | PARAMETERS : p_id   - The primary key of the event which owns the code    |
-- |              p_code - The SQL select statement to validate                |
-- |              p_type - The type of usage, should always be 'S'             |
-- | RETURNS    : None                                                         |
-- | RAISES     : could_not_analyse_query - If the select statement could not  |
-- |                                        be 'described'                     |
-- +---------------------------------------------------------------------------+
  PROCEDURE validate_select(
    p_id      IN NUMBER,
    p_code    IN VARCHAR2,
    p_type    IN VARCHAR2
  );
--
  FUNCTION no_business_context(p_table IN VARCHAR2,p_id IN NUMBER) RETURN BOOLEAN;
  FUNCTION no_legislation_context(p_table IN VARCHAR2,p_id IN NUMBER) RETURN BOOLEAN;
  FUNCTION no_payroll_context(p_table IN VARCHAR2,p_id IN NUMBER) RETURN BOOLEAN;
--
--
-- +---------------------------------------------------------------------------+
-- | NAME       : g_param_rec_type                                             |
-- | DESCRIPTION: Useful to store the entire set of parameters associated with |
-- |              a table in a standard format, so future code generation can  |
-- |              simply loop through this table.                              |
-- +---------------------------------------------------------------------------+
TYPE g_param_rec_type is RECORD
          (local_form    pay_trigger_parameters.parameter_name%type,
           usage_type    pay_trigger_parameters.usage_type%type,
           param_form    pay_trigger_parameters.parameter_name%type,
           value_name    pay_trigger_parameters.value_name%type,
           data_type     all_tab_columns.data_type%type);
--
TYPE g_params_tab_type is TABLE of g_param_rec_type
         index by binary_integer;

--
-- +---------------------------------------------------------------------------+
-- | NAME       : gen_dyt_pkg_full_code                                        |
-- | DESCRIPTION: This is the main entry point for generating the dynamic code |
-- |      that represents ALL of the dynamic triggers on a table INTO PACKAGE  |
-- |      format.   This dynamic trigger package (dyt_pkg) contains a procedure|
-- |      representing each dyt, and also three standard interfaces for the API|
-- |      strategy, (namely after_update, after_insert, after_delete) which    |
-- |      call the former types as required.                                   |
-- |                                                                           |
-- |      For each dated table, the users preference of dyt storage type is    |
-- |      noted, T =  dbms triggers and therefore this procedure should never  |
-- |      be called.  P= package, so dyt's should reside in a pkg, built by    |
-- |      this pkg.  B = Both, this means the pkg will be created and dbms     |
-- |      triggers will also be created calling this pkg code.  This procedure |
-- |      will create pkg and dbms triggers if required.  (These latter dbms   |
-- |      triggers are not the same as those created by the existing methods as|
-- |      mentioned when preference = T.)                                      |
-- | PARAMETERS : p_tab_id - Primary key of the table on which the dyt's exist |
-- |              p_ok     - Boolean indicating overall success of generation  |
-- | RETURNS    : p_ok     - The resulting value                               |
-- | RAISES     : Standard sql errors.                                         |
-- +---------------------------------------------------------------------------+
PROCEDURE gen_dyt_pkg_full_code(p_tab_id IN NUMBER,p_ok IN OUT NOCOPY BOOLEAN);
--
-- +---------------------------------------------------------------------------+
-- | NAME       : gen_dyt_pkg_proc                                             |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: This procedure creates the single procedure representing a   |
-- |      single dyt.                                                          |
-- | PARAMETERS : p_dyt_id    - Primary key of the dynamic trigger             |
-- |              p_dyt_name  - Dynamic Trigger Name                           |
-- |              p_tab_name  - Table on which dyt exists                      |
-- |              p_dyt_act   - Triggering action of dyt, I U or D             |
-- |              p_dyt_desc  - Description of dyt                             |
-- |              p_dyt_info  - Full version of trig act, eg INSERT            |
-- |              p_dyn_pkg_params     - Tbl containing all parameter details  |
-- |              p_hs     - Placeholder for header code                       |
-- |              p_bs     - Placeholder for body code, passed in and returned |
-- | RETURNS    : p_hs     - The resulting header code                         |
-- |              p_bs     - The resulting body code                           |
-- | RAISES     : Standard sql errors.                                         |
-- +---------------------------------------------------------------------------+
PROCEDURE gen_dyt_pkg_proc(p_dyt_id IN NUMBER,p_dyt_name IN VARCHAR2
                          ,p_tab_name IN VARCHAR2, p_dyt_act IN VARCHAR2
                          ,p_dyt_desc IN VARCHAR2,p_dyt_info IN VARCHAR2
                          ,p_dyn_pkg_params IN g_params_tab_type
                          ,p_hs IN OUT NOCOPY VARCHAR2
                          ,p_bs IN OUT NOCOPY VARCHAR2);
--
-- +---------------------------------------------------------------------------+
-- | NAME       : gen_dyt_pkg_rhi_proc                                         |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: This procedure creates a single procedure representing either|
-- |      after_insert,after_update or ater_delete as decided by the p_dyt_act |
-- |      parameter.  This generated code contains calls to all dyt procedures |
-- |      of the same action type.                                             |
-- | PARAMETERS : p_tab_name  - Table on which dyt exists                      |
-- |              p_dyt_act   - Triggering action of dyt, I U or D             |
-- |              p_dyt_info  - Full version of trig act, eg INSERT            |
-- |              p_hok_params   - Tbl containing all hook parameter details   |
-- |              p_hs     - Placeholder for header code                       |
-- |              p_bs     - Placeholder for body code, passed in and returned |
-- |              p_dyt_params  - Tbl containing all dyt    parameter details  |
-- |              p_datetracked_table  - Y or N is the table dated             |
-- | RETURNS    : p_hs     - The resulting header code                         |
-- |              p_bs     - The resulting body code                           |
-- |              p_dyt_pkg_head_tbl - Table 32k header code                   |
-- |              p_dyt_pkg_body_tbl - Table 32k body code                     |
-- | RAISES     : Standard sql errors.                                         |
-- +---------------------------------------------------------------------------+
PROCEDURE gen_dyt_pkg_rhi_proc(p_tab_name IN VARCHAR2
                              ,p_dyt_act IN VARCHAR2 ,p_dyt_info IN VARCHAR2
                              ,p_hok_params IN g_params_tab_type
                              ,p_hs IN OUT NOCOPY VARCHAR2
                              ,p_bs IN OUT NOCOPY VARCHAR2
                              ,p_dyt_params IN g_params_tab_type
                              ,p_dyt_pkg_head_tbl IN OUT NOCOPY t_varchar2_32k_tbl
                              ,p_dyt_pkg_body_tbl IN OUT NOCOPY t_varchar2_32k_tbl
                              ,p_datetracked_table in VARCHAR2);
--
-- +---------------------------------------------------------------------------+
-- | NAME       : gen_dyt_db_trig                                              |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: This procedure generates the dbms triggers that accompany the|
-- |      dyt package.  Code for a single dyt is created and the db trigger is |
-- |      created on the database.  The trigger contains calls to the newly    |
-- |      created procedures representing dyt within the dyt pkg.              |
-- | PARAMETERS : p_dyt_id    - Primary key of the dynamic trigger             |
-- |              p_dyt_name  - Dynamic Trigger Name                           |
-- |              p_tab_name  - Table on which dyt exists                      |
-- |              p_dyt_act   - Triggering action of dyt, I U or D             |
-- |              p_dyt_desc  - Description of dyt                             |
-- |              p_dyt_info  - Full version of trig act, eg INSERT            |
-- |              p_dyn_pkg_params    - Tbl containing all parameter details   |
-- |              p_tab_dyt_pkg_name  - Name of the dyt pkg                    |
-- | RETURNS    : none                                                         |
-- | RAISES     : Standard sql errors.                                         |
-- +---------------------------------------------------------------------------+
PROCEDURE gen_dyt_db_trig(p_dyt_id IN NUMBER,p_dyt_name IN VARCHAR2
                         ,p_tab_name IN VARCHAR2, p_dyt_act IN VARCHAR2
                         ,p_dyt_desc IN VARCHAR2,p_dyt_info IN VARCHAR2
                         ,p_dyn_pkg_params IN g_params_tab_type
                         ,p_tab_dyt_pkg_name IN VARCHAR2);
--
-- +---------------------------------------------------------------------------+
-- | NAME       : trigger_enabled                                              |
-- | SCOPE      : PUBLIC                                                       |
-- | DESCRIPTION: Simply returns boolean to see if dyn trigger is enabled.     |
-- |              Called by dynamically created rhi proc in dynamic package    |
-- | PARAMETERS : p_dyt      - The dynamic trigger name                        |
-- | RETURNS    : TRUE if trigger is enabled, FALSE otherwise                  |
-- | RAISES     : None                                                         |
-- +---------------------------------------------------------------------------+
FUNCTION trigger_enabled(p_dyt varchar2) return BOOLEAN;
--
-- +---------------------------------------------------------------------------+
-- | name       : convert_tab_style                                            |
-- | scope      : public                                                       |
-- | description: there are times when the seeded behaviour needs to be altered|
-- |  usually as a result of release issues.  this procedure provides a quick  |
-- |  wrapper utility to change a dated table from dbms_dyt to dyt_pkg and vice|
-- |  versa.
-- | parameters : p_table_name  - the dated table name                         |
-- |            : p_dyt_type    - eg t<dbms trigger> p<ackage> b<oth>          |
-- | returns    : none
-- | raises     : none                                                         |
-- +---------------------------------------------------------------------------+
PROCEDURE convert_tab_style(p_table_name in varchar2,p_dyt_type in varchar2);
--
-- +---------------------------------------------------------------------------+
-- | name       : confirm_dyt_data                                            |
-- | scope      : public                                                       |
-- | description: there are times when the seeded behaviour needs to be altered|
-- |  usually as a result of release issues.  this procedure checks the data
-- | for a given table and depending on the main switch (hook calls to DYT_PKG)
-- | rebuilds the data for DYT_PKG behaviour (if calls existed) or DBMS dynamic
-- | triggers (if no calls existed)
-- | parameters : p_table_name  - the dated table name                         |
-- | returns    : none
-- | raises     : none                                                         |
-- +---------------------------------------------------------------------------+
PROCEDURE confirm_dyt_data(p_table_name in varchar2);
--
-- +---------------------------------------------------------------------------+
-- | NAME       : ins, upd, del, lck                                           |
-- | DESCRIPTION: Insert, Update, Delete and Lock rows in pay_trigger_events,  |
-- |              this is to emulate the API row handler behaviour, even though|
-- |              there isn't actually a proper API for this table.            |
-- | PARAMETERS : Same as the columns in the table for Insert and Update. Just |
-- |              the primary key for Delete and Lock.                         |
-- | RETURNS    : None                                                         |
-- | RAISES     : HR_7220_INVALID_PRIMARY_KEY                                  |
-- |              HR_7165_OBJECT_LOCKED                                        |
-- +---------------------------------------------------------------------------+
PROCEDURE ins(
        p_event_id           IN NUMBER,
        p_table_name         IN VARCHAR2,
        p_short_name         IN VARCHAR2,
        p_description        IN VARCHAR2,
        p_generated_flag     IN VARCHAR2,
        p_enabled_flag       IN VARCHAR2,
        p_protected_flag     IN VARCHAR2,
        p_triggering_action  IN VARCHAR2,
        p_last_update_date   IN DATE,
        p_last_updated_by    IN NUMBER,
        p_last_update_login  IN NUMBER,
        p_created_by         IN NUMBER,
        p_creation_date      IN DATE
);
--
PROCEDURE upd(
        p_event_id           IN NUMBER,
        p_table_name         IN VARCHAR2,
        p_short_name         IN VARCHAR2,
        p_description        IN VARCHAR2,
        p_generated_flag     IN VARCHAR2,
        p_enabled_flag       IN VARCHAR2,
        p_protected_flag     IN VARCHAR2,
        p_triggering_action  IN VARCHAR2,
        p_last_update_date   IN DATE,
        p_last_updated_by    IN NUMBER,
        p_last_update_login  IN NUMBER,
        p_created_by         IN NUMBER,
        p_creation_date      IN DATE
);
--
PROCEDURE del(
        p_event_id           IN NUMBER
);
--
PROCEDURE lck(
        p_event_id           IN NUMBER
);
--
-- +---------------------------------------------------------------------------+
-- | NAME       : is_table_valid                                               |
-- |              is_table_column_valid                                        |
-- |              is_table_owner_valid                                         |
-- |              get_table_owner                                              |
-- | DESCRIPTION: Helper functions to extend the use of the dynamic triggers   |
-- |              so that they can be used on tables which aren't in the PAY   |
-- |              schema.                                                      |
-- | PARAMETERS : The table name, column name, table owner, variously.         |
-- | RETURNS    : 'Y', 'N', or the name of the owner of a table.               |
-- | RAISES     : None.                                                        |
-- +---------------------------------------------------------------------------+
FUNCTION is_table_valid(p_table IN VARCHAR2) RETURN VARCHAR2;
FUNCTION is_table_column_valid(p_table IN VARCHAR2
                              ,p_column IN VARCHAR2) RETURN VARCHAR2;
FUNCTION is_table_owner_valid(p_table IN VARCHAR2
                             ,p_owner IN VARCHAR2) RETURN VARCHAR2;
--
FUNCTION get_table_owner(p_table IN VARCHAR2) RETURN VARCHAR2;
--
END paywsdyg_pkg;

 

/

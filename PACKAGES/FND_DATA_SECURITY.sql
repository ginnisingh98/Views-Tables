--------------------------------------------------------
--  DDL for Package FND_DATA_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DATA_SECURITY" AUTHID CURRENT_USER AS
/* $Header: AFSCDSCS.pls 120.5.12000000.1 2007/01/18 13:26:00 appldev ship $ */

/* This flag will be hardcoded to 'Y' in release 12 and beyond, but 'N' for */
/* release 11.5.  When it is 'Y', deprecated APIs such as */
/* passing a p_user_name will raise a runtime error exception immediately */
/* instead of working as they did in relase 11.5 */
DISALLOW_DEPRECATED constant varchar(1) :=  'Y';

FUNCTION check_function
  (
   p_api_version       IN  NUMBER,
   p_function         IN  VARCHAR2,
   p_object_name       IN  VARCHAR2,
   p_instance_pk1_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk2_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value   IN  VARCHAR2 DEFAULT NULL,
   p_user_name            in varchar2  default null  /* DEPRECATED */
 )
 RETURN VARCHAR2;
    -- Start OF comments
    -- API name  : check_function
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Determines whether user is granted a particular
    --             function for a particular object instance.
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure (currently 1.0)
    --
    --             p_function         IN  VARCHAR2 (required)
    --             name of the function
    --
    --             p_object_name      IN  VARCHAR2 (required)
    --             object on which the grant should be checked
    --             from fnd_objects table.
    --
    --             p_instance_pk[1..5]_value     IN  NUMBER (required)
    --             Primary key values for the object instance, with order
    --             corresponding to the order of the PKs in the
    --             FND_OBJECTS table.  Most objects will only have a
    --             few primary key columns so just let the higher,
    --             unused column values default to NULL.
    --             NOTE: Caller must pass an actual primary key, and it
    --             must be the primary key of an actual instance (row).
    --
    --             p_user_name IN VARCHAR2 (optional) DEPRECATED
    --             DEPRECATED.  DO NOT USE IN NEW CODE. P_USER_NAME
    --             cannot be implemented correctly because
    --             instance set clauses may refer to the user_name
    --             context directly or indirectly and that context
    --             won't have this value, causing inconsistencies.
    --             Let this default to null which means current user.
    --             DEPRECATED. DEPRECATED. DEPRECATED. DEPRECATED.
    --             User to check grant for, from FND_USER or another
    --             table (like HZ_PARTIES) that the view column
    --             WF_ROLES.NAME is based on.  Pass the same value stored
    --             in the GRANTEE_KEY column in FND_GRANTS.
    --             Examples of values that might be passed: 'SYSADMIN',
    --             'HZ_PARTIES:1234'
    --             Note: If passed, this user_name must refer to an
    --             actual user, already existing in the WF_USER_ROLES
    --             table/view.
    --             Defaults to current FND user if null.
    --
    --     OUT
    --             RETURNs 1 byte result code:
    --                   'T'  function is granted.
    --                   'F'  not granted.
    --                   'E'  Error
    --                   'U'  Unexpected Error
    --
    --                If 'E' or 'U' is returned, there will be an error
    --                message on the FND_MESSAGE stack which
    --                can be retrieved with FND_MESSAGE.GET_ENCODED()
    --                If that message is not used, it must be cleared.
    --

    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  ----------------------------------------------------------------

  -- modified for bug#5395351
  TYPE FND_PRIVILEGE_NAME_TABLE_TYPE IS TABLE OF fnd_form_functions.function_name%type
  INDEX BY BINARY_INTEGER;

   PROCEDURE get_functions
  (
   p_api_version         IN  NUMBER,
   p_object_name         IN  VARCHAR2,
   p_instance_pk1_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk2_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value  IN  VARCHAR2 DEFAULT NULL,
   p_user_name           IN  varchar2 default null,  /* DEPRECATED */
   x_return_status       OUT NOCOPY VARCHAR2,
   x_privilege_tbl       OUT NOCOPY FND_PRIVILEGE_NAME_TABLE_TYPE
  ) ;
    -- Start OF comments
    -- API name  : get_functions
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : get the list of functions user has on the
    --             object instance
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure (currently 1.0)
    --
    --             p_object_name      IN  VARCHAR2 (required)
    --             object on which the grant should be checked
    --             from fnd_objects table.
    --
    --             p_instance_pk[1..5]_value   IN  NUMBER (required)
    --             Primary keys values to an object instance, corresponding
    --             to the order in the FND_OBJECTS table.  Most objects will
    --             only have a few primary key columns so just pass
    --             NULL for the unused higher columns.
    --
    --             p_user_name IN VARCHAR2 (optional) DEPRECATED
    --             DEPRECATED.  DO NOT USE IN NEW CODE. P_USER_NAME
    --             cannot be implemented correctly because
    --             instance set clauses may refer to the user_name
    --             context directly or indirectly and that context
    --             won't have this value, causing inconsistencies.
    --             Let this default to null which means current user.
    --             DEPRECATED. DEPRECATED. DEPRECATED. DEPRECATED.
    --             User to check grant for, from FND_USER or another
    --             table (like HZ_PARTIES) that the view column
    --             WF_ROLES.NAME is based on.  Pass the same value stored
    --             in the GRANTEE_KEY column in FND_GRANTS.
    --             Examples of values that might be passed: 'SYSADMIN',
    --             'HZ_PARTIES:1234'
    --             Note: If passed, this user_name must refer to an
    --             actual user, already existing in the WF_USER_ROLES
    --             table/view.
    --             Defaults to current FND user if null.
    --
    --     OUT  :
    --             X_return_status    OUT VARCHAR2(1)
    --             Result of all the operations
    --                   'T'  Successfully got list of functions
    --                   'F'  No functions granted
    --                   'E'  Error
    --                   'U'  Unexpected Error
    --
    --                If 'E' or 'U' is returned, there will be an error
    --                message on the FND_MESSAGE stack which
    --                can be retrieved with FND_MESSAGE.GET_ENCODED()
    --                If that message is not used, it must be cleared.
    --
    --             x_functions_tbl        OUT TABLE
    --                list of functions  available
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  ----------------------------------------------------------------



------Procedure GET_MENUS-------------
/* INTERNAL ATG USE ONLY.  NOT FOR PUBLIC USE.  This is primarily */
/* by the ATG java code where it will return a list of the menuids */
PROCEDURE get_menus
  (
   p_api_version         IN  NUMBER,
   p_object_name         IN  VARCHAR2,
   p_instance_pk1_value  IN  VARCHAR2 DEFAULT NULL, /* NULL= only chk global gnts*/
   p_instance_pk2_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value  IN  VARCHAR2 DEFAULT NULL,
   p_user_name           IN  VARCHAR2 default null,   /* DEPRECATED */
   x_return_status       OUT NOCOPY VARCHAR2,
   x_menu_tbl            OUT NOCOPY FND_TABLE_OF_NUMBER
 );


  -- DEPRECATED.  DO NOT CALL THIS. CALL THE OTHER OVERLOADED VERSION INSTEAD.
  -- This version of get_security_predicate is no longer supported because
  -- the pk aliases that it takes in the params do not work in our new
  -- SQL which now puts the object name in the SQL for parameterized
  -- instance sets.  It is being left in the API simply for patching
  -- reasons but should NEVER be called from new code.  The pk aliases
  -- will be ignored.  In some upcoming release this may be dropped
  -- from the API.
  -- New code should call the overloaded get_security_predicate without
  -- the pk aliases, below.
    --            p_pk[1..5]_alias  IN  VARCHAR2 (optional)
    --            Normally the caller wouldn't pass any values for these.
    --            Column aliases for primary keys.  Pass column names
    --            (optionally including table aliases) of the relevant
    --            columns, if they are different from the base column names
    --            as defined in FND_OBJECTS.  For example 'MY_VIEW.MY_APP_ID'
    --            might be passed in as a column alias for the first PK, which
    --            was defined in FND_OBJECTS as 'APPLICATION_ID'.
    --            Column aliases are not allowed for p_statement_type='BASE',
    --            or for p_grant_instance_type ='SET'.
    --
  PROCEDURE get_security_predicate /* DEPRECATED DEPRECATED DEPRECATED*/
  (
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2 default null,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2 DEFAULT 'UNIVERSAL',/* SET, INSTANCE*/
    p_user_name        IN  VARCHAR2 default null,   /* DEPRECATED */
    /* statement_type: 'OTHER', 'BASE'=VPD, 'EXISTS'= to check existence*/
    p_statement_type   IN  VARCHAR2 DEFAULT 'OTHER',
    p_pk1_alias        IN  VARCHAR2,
    p_pk2_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk3_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk4_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk5_alias        IN  VARCHAR2 DEFAULT NULL,
    x_predicate        out NOCOPY varchar2,
    x_return_status    out NOCOPY varchar2
  );


  /* The non-deprecated version of get_security_predicate.  Use this.*/
  PROCEDURE get_security_predicate
  (
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2 default null,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2 DEFAULT 'UNIVERSAL',/* SET, INSTANCE*/
    p_user_name        IN  VARCHAR2 default null,  /* DEPRECATED */
    /* statement_type: 'OTHER', 'BASE'=VPD, 'EXISTS'= to check existence*/
    p_statement_type   IN  VARCHAR2 DEFAULT 'OTHER',
    x_predicate        out NOCOPY varchar2,
    x_return_status    out NOCOPY varchar2,
    p_table_alias      IN  VARCHAR2 DEFAULT NULL
  )  ;
    -- Start OF comments
    -- API name  : get_security_predicate
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : get Union of all predicates for user on a function
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure (currently 1.0)
    --
    --             p_function         IN  VARCHAR2 (optional)
    --             name of the function
    --             NULL means all functions, so the predicate will not
    --             take the function into account.
    --
    --             p_object_name      IN  VARCHAR2 (required)
    --             object on which the predicate should be checked.
    --             from fnd_objects table.
    --
    --             p_grant_instance_type      IN  VARCHAR2 (optional)
    --             Can take on one of the following values:
    --                'INSTANCE'- returns predicate for grants with
    --                            instance_type = 'INSTANCE' or 'GLOBAL'
    --                'SET'- returns predicate for grants with
    --                            instance_type = 'SET'
    --                'UNIVERSAL'(default)- returns predicate for
    --                            grants with any instance_type.
    --                'GRANTS_ONLY'- a special mode that returns a predicate
    --                            for the FND_GRANTS table.  This would
    --                            be used in constructing UIs over the
    --                            grants table, or for debugging to
    --                            see which grants are "in play".
    --                            The predicate will assume that the G
    --                            alias is used for FND_GRANTS, so use
    --                            it like this:
    --                               'SELECT some_columns
    --                                  FROM FND_GRANTS GNT
    --                                 WHERE '|| x_predicate
    --             Note: 'SET' mode does not support aliases.
    --
    --             p_user_name IN VARCHAR2 (optional)  DEPRECATED
    --             DEPRECATED.  DO NOT USE IN NEW CODE. P_USER_NAME
    --             cannot be implemented correctly because
    --             instance set clauses may refer to the user_name
    --             context directly or indirectly and that context
    --             won't have this value, causing inconsistencies.
    --             Let this default to null which means current user.
    --             DEPRECATED. DEPRECATED. DEPRECATED. DEPRECATED.
    --             User to check grant for, from FND_USER or another
    --             table (like HZ_PARTIES) that the view column
    --             WF_ROLES.NAME is based on.  Pass the same value stored
    --             in the GRANTEE_KEY column in FND_GRANTS.
    --             Examples of values that might be passed: 'SYSADMIN',
    --             'HZ_PARTIES:1234'
    --             Note: If passed, this user_name must refer to an
    --             actual user, already existing in the WF_USER_ROLES
    --             table/view.
    --             Defaults to current FND user if null.
    --
    --            p_table_alias  IN VARCHAR2 DEFAULT NULL (optional)
    --            Optional table alias.  This table alias
    --            will be appended in front of the column references
    --            in the returned x_predicate.  Normally used when two
    --            security predicates are going to be ANDed together to
    --            use with a select that joins two secured tables.
    --            The value passed here should correspond to the table
    --            alias that the statement will use for the p_object_name
    --            passed to this routine.  The default, NULL, means
    --            there is no table alias so none will be appended.
    --
    --             p_statement_type   IN  VARCHAR2 DEFAULT 'OTHER' (optional)
    --             Can take one of the following values:
    --                'OTHER'- This is the default.  This means the predicate
    --                         returned will not be attached by policy
    --                         to the base table ala VPD.  In practice this
    --                         allows the predicate to have a subselect against
    --                         the base table, which allows aliases and may
    --                         improve performance.
    --                'BASE'-  Pass this type if the predicate will be attached
    --                         by policy to the base table.  Use 'BASE' when
    --                         VPD will use the returned predicate to control
    --                         access.  In practice this means the predicate
    --                         cannot have subselects against the base table,
    --                         prevents aliases and may lower performance.
    --                         'BASE' mode is currently unsupported but may
    --                         be supported in the future.
    --                'EXISTS'-  Pass this type if the predicate will be
    --                         simply used to determine if there are any rows
    --                         at all that are available.  The predicate
    --                         returned will be of the format like 'EXISTS ...'
    --
    --     OUT  :
    --             X_return_status    OUT VARCHAR2(1)
    --             Result of all the operations
    --                   'T'  Successfully got predicate
    --                   'E'  Error
    --                   'U'  Unexpected Error
    --                   'L'  Value too long- predicate too large for
    --                        database VPD.
    --
    --                If 'E', 'U, or 'L' is returned, there will be an error
    --                message on the FND_MESSAGE stack which
    --                should be retrieved and displayed with
    --                FND_MESSAGE.GET_ENCODED() or FND_MESSAGE.GET()
    --                If that message is not used, it must be cleared by
    --                the caller with FND_MESSAGE.CLEAR().
    --                In other words, if one of those values
    --                is returned, the caller MUST either retrieve
    --                the message or clear it.
    --
    --             Return Value:
    --                All the available predicates from the grants on
    --                this function for this user, ORed together to form
    --                a big gob of SQL that can be dropped into the where
    --                clause, to limit rows returned to those that are
    --                allowed by the security.  Does not include 'WHERE'.
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments



  PROCEDURE get_security_predicate_w_binds
  (
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2 default null,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2 DEFAULT 'UNIVERSAL',/* SET, INSTANCE*/
    p_user_name        IN  VARCHAR2 default null,  /* DEPRECATED */
    /* statement_type: 'OTHER', 'BASE'=VPD, 'EXISTS'= to check existence*/
    p_statement_type   IN  VARCHAR2 DEFAULT 'OTHER',
    p_table_alias      IN  VARCHAR2 DEFAULT NULL,
    x_predicate        out NOCOPY varchar2,
    x_return_status    out NOCOPY varchar2,
    x_function_id      out NOCOPY NUMBER,
    x_object_id        out NOCOPY NUMBER,
    x_bind_order       out NOCOPY VARCHAR2
  )  ;
    -- Start OF comments
    -- API name  : get_security_predicate_w_binds
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : get Union of all predicates for user on a function,
    --             with binds inline.  This routine functions like
    --             get_security_predicate(), so see the documentation
    --             for that routine for descriptions of most of the
    --             parameters.  The only difference in parameters is
    --             that this routine has two additional output parameters
    --             listed below, x_function_id and x_object_id.
    --
    --             Note on binds:  The predicate returned from this statement
    --             is designed for PL/SQL binds by name; the format of the
    --             binds is ":FUNCTION_ID_BIND" and ":OBJECT_ID_BIND".
    --             If the caller wants to use this with java style "?" binds,
    --             the caller will be responsible for replacing the strings
    --             ":FUNCTION_ID_BIND" and ":OBJECT_ID_BIND" with the "?".
    --
    -- Parameters: (see header for get_security_predicate() for docs on
    --              other parameters)
    --
    --     OUT  :  x_function_id OUT NUMBER
    --             if the value is NULL then the predicate
    --             returned does not have a function id bind, so
    --             the caller must not bind this value.
    --             if the value is non-null, then the predicate has one
    --             or more instances of the bind ":FUNCTION_ID_BIND"
    --             in the statement.  The caller should bind by name
    --             the value of the number x_function_id before executing
    --             the SQL statement.
    --
    --             x_object_id  OUT NUMBER
    --             if the value is NULL then the predicate
    --             returned does not have a object id bind, so
    --             the caller must not bind this value.
    --             if the value is non-null, then the predicate has one
    --             or more instances of the bind ":OBJECT_ID_BIND"
    --             in the statement.  The caller should bind by name
    --             the value of the number x_function_id before executing
    --             the SQL statement.
    --
    --             x_bind_order OUT VARCHAR2(256)
    --             This returns a string that is designed to help callers
    --             who want to do bind by position instead of bind by name.
    --             It will contain the
    --             letter 'F' for function id binds, and the letter 'O'
    --             for object_id binds, in the order in which they appear
    --             in the returned predicate.
    --             For instance if it returned the string 'FOOF', that would
    --             mean that the caller should bind:
    --                  1. FUNCTION_ID_BIND
    --                  2. OBJECT_ID_BIND
    --                  3. OBJECT_ID_BIND
    --                  4. FUNCTION_ID_BIND
    --             The caller can loop through this string a character at
    --             a time, doing the appropriate binds for each.
    --             Just to be safe, the caller should allow for up to 256
    --             characters of possible return value, although in practice
    --             there should never be that many binds.
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments


TYPE FND_INSTANCE_PK_RECORD is record
              (PK1_VALUE    varchar2(256),
               PK2_VALUE    varchar2(256),
               PK3_VALUE    varchar2(256),
               PK4_VALUE    varchar2(256),
               PK5_VALUE    varchar2(256));

TYPE FND_INSTANCE_TABLE_TYPE IS TABLE OF FND_INSTANCE_PK_RECORD
   INDEX BY BINARY_INTEGER;



  -- DEPRECATED.  DO NOT CALL GET_INSTANCES.
PROCEDURE get_instances   -- DEPRECATED.  DO NOT CALL GET_INSTANCES.
(
    p_api_version    IN  NUMBER,
    p_function       IN  VARCHAR2 DEFAULT NULL,
    p_object_name    IN  VARCHAR2,
    p_user_name      IN  VARCHAR2 DEFAULT NULL,   /* DEPRECATED */
    x_return_status  OUT NOCOPY VARCHAR2,
    x_object_key_tbl OUT NOCOPY FND_INSTANCE_TABLE_TYPE
);
    -- Start OF comments
    -- API name  : get_instances
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : get list of all instances granted to a particular user
    --              on a particular function.
    --
    -- DEPRECATED.  DO NOT CALL GET_INSTANCES.
    -- This routine is left around as a legacy from the original API
    -- but is no longer supported.  The reason is that we do not support
    -- doing full table selects with data security predicate.  We require
    -- that a main where clause limits the number of rows that data security
    -- gets to see.  There is no way to limit the number of rows that would
    -- be processed by data security, so this routine is not supported.
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure (currently 1.0)
    --
    --             p_function         IN  VARCHAR2 (optional)
    --             name of the function
    --             If null, return union of predicates for all functions
    --             granted on this object type.
    --
    --             p_object_name      IN  VARCHAR2 (required)
    --             object on which the predicate should be checked.
    --             from fnd_objects table.
    --
    --             p_user_name IN VARCHAR2 (optional)  DEPRECATED
    --             DEPRECATED.  DO NOT USE IN NEW CODE. P_USER_NAME
    --             cannot be implemented correctly because
    --             instance set clauses may refer to the user_name
    --             context directly or indirectly and that context
    --             won't have this value, causing inconsistencies.
    --             Let this default to null which means current user.
    --             DEPRECATED. DEPRECATED. DEPRECATED. DEPRECATED.
    --             User to check grant for, from FND_USER or another
    --             table (like HZ_PARTIES) that the view column
    --             WF_ROLES.NAME is based on.  Pass the same value stored
    --             in the GRANTEE_KEY column in FND_GRANTS.
    --             Examples of values that might be passed: 'SYSADMIN',
    --             'HZ_PARTIES:1234'
    --             Defaults to current FND user if null.
    --
    --     OUT  :
    --             X_return_status    OUT VARCHAR2(1)
    --             Result of all the operations
    --                   'T'  Successfully got instances
    --                   'F'  No instances accessible
    --                   'E'  Error
    --                   'U'  Unexpected Error
    --
    --                If 'E', or 'U' is returned, there will be an error
    --                message on the FND_MESSAGE stack which
    --                can be retrieved with FND_MESSAGE.GET_ENCODED()
    --                If that message is not used, it must be cleared.
    --
    --             Return Value:
    --                Table of primary keys of all the available instances
    --                from the grants on this function for this user.
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments



/* CHECK_INSTANCE_IN_SET IS DESUPPORTED.  DO NOT CALL THIS FUNCTION. */
/* FUNCTIONALITY HAS BEEN STRIPPED OUT.  */
/* This nonfunctional stub is left in the API just to prevent compilation */
/* problems with old code from old patches. */
FUNCTION check_instance_in_set
 (
  p_api_version          IN  NUMBER,
  p_instance_set_name    IN  VARCHAR2,
  p_instance_pk1_value   IN  VARCHAR2,
  p_instance_pk2_value   IN  VARCHAR2 DEFAULT NULL,
  p_instance_pk3_value   IN  VARCHAR2 DEFAULT NULL,
  p_instance_pk4_value   IN  VARCHAR2 DEFAULT NULL,
  p_instance_pk5_value   IN  VARCHAR2 DEFAULT NULL
 ) return VARCHAR2;



 ---This is an internal procedure. Not for general use.
 --   Gets the orig_system_id and orig_system from wf_roles,
 --   given the user_name.
 --   This is around mostly for backward compatibility with our
 --   grants loader, but we may eliminate even that use and this
 --   routine may disappear entirely, so outside code should
 --   not call it or their code will break in the future.
 -----------------------------------------------
-- DEPRECATED    DEPRECATED     DEPRECATED     DEPRECATED     DEPRECATED
-- Release 11 only, not in Release 12.
procedure get_orig_key(p_user_name in VARCHAR2,  /* DEPRECATED */
                      x_orig_system    out NOCOPY varchar2,
                      x_orig_system_id out NOCOPY NUMBER);


-- check_global_object_type_grant- Internal procedure not for general use.
-- Is a particular function granted globally to all objects in
-- the current context.
-- If you are thinking of calling this you should probably call
-- FND_FUNCTION.TEST_INSTANCE instead, because that calls this and more.
FUNCTION check_global_object_type_grant
  (
   p_api_version         IN  NUMBER,
   p_function            IN  VARCHAR2,
   p_user_name           in varchar2 default null  /* DEPRECATED */
 )
 RETURN VARCHAR2;


/*
** upgrade_predicate-
** an internal-only routine that upgrades the predicate
** from the 11.5.8 style predicate "X.column_name = G.parameter1"  format
** to the new "[Amp]TABLE_ALIAS.column_name = [Amp]GRANT_ALIAS.parameter1"
** format where [Amp] represents an ampersand.
**
*/
FUNCTION upgrade_predicate(in_pred in varchar2) return VARCHAR2;


/*
** upgrade_column_type-
** an internal-only routine that upgrades the FND_OBJECT column types
** from the obsolete NUMBER type to INTEGER type (leaving other types
** alone)
**
*/
FUNCTION upgrade_column_type(in_col_type in varchar2) return VARCHAR2;

/*
** upgrade_grantee_key-
** an internal-only routine that upgrades the GRANTEE_KEY to 'GLOBAL'
** in any case where the GRANTEE_TYPE is 'GLOBAL'.  This will go in 11.5.10.
**
*/
FUNCTION upgrade_grantee_key(in_grantee_type in varchar2,
                             in_grantee_key  in varchar2) return VARCHAR2;


/*
** substitute_pred-
**
** an internal-only routine that substitutes in the object table alias
** and the grant table alias in the fnd_grants table.
**
*/
FUNCTION substitute_predicate(in_pred in varchar2,
                             in_table_alias in varchar2) return VARCHAR2;

/*
** to_int-  DEPRECATED DEPRECATED DEPRECATED DEPRECATED
** Convert an integer (no decimal) canonical format VARCHAR2 into NUMBER.
**
** Note that this routine is now deprecated because it is best to
** use the inline logic described one paragraph below.
**
** Here's what this routine does, for understanding old code:
** This should be used with id type numbers that don't have decimals
** because it performs better than to_decimal().
** If due to the SQL statement being evaluated in an unanticipated order,
** this is being called on non-numerical data, just returns -11111.
** The reason that it is essential that this is called instead of to_number()
** on grant parameters is that this routine will not cause an exception if
** the generated predicate ends up being evaluated such that the grant
** rows are not filtered before going through the fnd_data_security.to_int()
** routine.  Some grant rows may have non-numeric data if they are for other
** object instance sets.  We need to make sure that the data security
** clause will not generate an exception no matter what order the database
** decides to evaluate the statement in.
**
** Note: The performance team has come up with a better solution than
** calling this routine.  Instead of calling this routine, your predicate
** should use the following logic:
**
** TO_NUMBER(DECODE(RTRIM(TRANSLATE(([AMP]GRANT_ALIAS.PARAMETER1,
**     '0123456789',' ')), [AMP]GRANT_ALIAS.PARAMETER1, :b1, -11111))
**   (where [AMP] represents and ampersand character)
**
** This serves the same purpose as
**
** to_int([AMP]GRANT_ALIAS.PARAMETER1)
**   (where [AMP] represents and ampersand character)
**
** but without the function call overhead, so it will perform better.
**
*/
FUNCTION to_int(inval in varchar2) return NUMBER; /* DEPRECATED */

/*
** to_decimal-
** Convert a canonical format VARCHAR2 with a decimal into a NUMBER.
** If due to the SQL statement being evaluated in an unanticipated order,
** this is being called on non-numerical data, and just
** returns -11111.
*/
FUNCTION to_decimal(inval in varchar2) return NUMBER;

/*
** to_date-
** Convert a canonical format date VARCHAR2 into a DATE.
** If due to the SQL statement being evaluated in an unanticipated order,
** this is being called on non-date data, just returns 11-JAN-1970.
*/
FUNCTION to_date (inval in varchar2 /* format 'YYYY/MM/DD' */ ) return DATE;
/* GSSC note: the above line may errantly cause File.Date.5 but this file */
/* AFSCDSCS.pls is grandfathered in so it will still build */

---This is an internal procedure. Not for general use.
--   Gets returns a result indicating whether the user has a role.
function CHECK_USER_ROLE(P_USER_NAME      in         varchar2)
                       return  varchar2 /* T/F */;

END FND_DATA_SECURITY;

 

/

--------------------------------------------------------
--  DDL for Package EGO_DATA_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_DATA_SECURITY" AUTHID CURRENT_USER AS
/* $Header: EGOPFDSS.pls 120.2.12010000.4 2009/02/06 06:06:56 bparthas ship $ */

FUNCTION check_function
  (
   p_api_version       IN  NUMBER,
   p_function         IN  VARCHAR2,
   p_object_name       IN  VARCHAR2,
   p_instance_pk1_value   IN  VARCHAR2,
   p_instance_pk2_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value   IN  VARCHAR2 DEFAULT NULL,
   p_user_name            in varchar2  default null
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
    --
    --             p_user_name IN VARCHAR2 (optional)
    --             User to check grant for, from FND_USER or another
    --             table (like HZ_PARTIES) that the view column
    --             WF_ROLES.NAME is based on.  Pass the same value stored
    --             in the GRANTEE_KEY column in FND_GRANTS.
    --             Examples of values that might be passed: 'SYSADMIN',
    --             'HZ_PARTIES:1234'
    --             Defaults to current FND user if null.
    --
    --     OUT  :
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
 FUNCTION check_inherited_function
  (
   p_api_version       IN  NUMBER,
   p_function         IN  VARCHAR2,
   p_object_name       IN  VARCHAR2,
   p_instance_pk1_value   IN  VARCHAR2,
   p_instance_pk2_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value   IN  VARCHAR2 DEFAULT NULL,
   p_user_name            IN  varchar2  default null,
   p_object_type          IN  VARCHAR2 default null,
   p_parent_object_name   IN  VARCHAR2,
   p_parent_instance_pk1_value   IN  VARCHAR2,
   p_parent_instance_pk2_value   IN  VARCHAR2 DEFAULT NULL,
   p_parent_instance_pk3_value   IN  VARCHAR2 DEFAULT NULL,
   p_parent_instance_pk4_value   IN  VARCHAR2 DEFAULT NULL,
   p_parent_instance_pk5_value   IN  VARCHAR2 DEFAULT NULL
 )
 RETURN VARCHAR2;

  ----------------------------------------------------------------
  TYPE EGO_PRIVILEGE_NAME_TABLE_TYPE IS TABLE OF VARCHAR2(480)
  INDEX BY BINARY_INTEGER;

   PROCEDURE get_functions
  (
   p_api_version         IN  NUMBER,
   p_object_name         IN  VARCHAR2,
   p_instance_pk1_value   IN  VARCHAR2,
   p_instance_pk2_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value  IN  VARCHAR2 DEFAULT NULL,
   p_user_name           IN  varchar2 default null,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_privilege_tbl       OUT NOCOPY EGO_PRIVILEGE_NAME_TABLE_TYPE
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
    --             p_user_name IN VARCHAR2 (optional)
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

   PROCEDURE get_inherited_functions
  (
   p_api_version         IN  NUMBER,
   p_object_name         IN  VARCHAR2,
   p_instance_pk1_value   IN  VARCHAR2,
   p_instance_pk2_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value  IN  VARCHAR2 DEFAULT NULL,
   p_user_name           IN  varchar2 default null,
   p_object_type          IN  VARCHAR2 default null,
   p_parent_object_name   IN  VARCHAR2,
   p_parent_instance_pk1_value   IN  VARCHAR2,
   p_parent_instance_pk2_value   IN  VARCHAR2 DEFAULT NULL,
   p_parent_instance_pk3_value   IN  VARCHAR2 DEFAULT NULL,
   p_parent_instance_pk4_value   IN  VARCHAR2 DEFAULT NULL,
   p_parent_instance_pk5_value   IN  VARCHAR2 DEFAULT NULL,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_privilege_tbl       OUT NOCOPY EGO_VARCHAR_TBL_TYPE
  ) ;

  ----------------------------------------------------------------
  PROCEDURE get_security_predicate
  (
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2 default null,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2 DEFAULT 'UNIVERSAL',/* SET, INSTANCE*/
    p_user_name        IN  VARCHAR2 default null,
    /* statement_type: 'OTHER', 'BASE'=VPD, 'EXISTS'= to check existence*/
    p_statement_type   IN  VARCHAR2 DEFAULT 'OTHER',
    p_pk1_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk2_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk3_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk4_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk5_alias        IN  VARCHAR2 DEFAULT NULL,
    x_predicate        OUT NOCOPY VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2
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
    --             If null, return union of predicates for all functions
    --             granted on this object type.
    --
    --             p_object_name      IN  VARCHAR2 (required)
    --             object on which the predicate should be checked.
    --             from fnd_objects table.
    --
    --             p_grant_instance_type      IN  VARCHAR2 (optional)
    --             Can take on one of the following values:
    --                'INSTANCE'- returns predicate for grants with
    --                            instance_type = 'INSTANCE'
    --                'SET'- returns predicate for grants with
    --                            instance_type = 'SET'
    --                'UNIVERSAL'(default)- returns predicate for
    --                            grants with any instance_type.
    --             Note: 'SET' mode does not support aliases.
    --
    --             p_user_name IN VARCHAR2 (optional)
    --             User to check grant for, from FND_USER or another
    --             table (like HZ_PARTIES) that the view column
    --             WF_ROLES.NAME is based on.  Pass the same value stored
    --             in the GRANTEE_KEY column in FND_GRANTS.
    --             Examples of values that might be passed: 'SYSADMIN',
    --             'HZ_PARTIES:1234'
    --             Defaults to current FND user if null.
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
    --                'EXISTS'-  Pass this type if the predicate will be
    --                         simply used to determine if there are any rows
    --                         at all that are available.  The predicate
    --                         returned will be of the format 'EXISTS ...'
    --
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
    --     OUT  :
    --             X_return_status    OUT VARCHAR2(1)
    --             Result of all the operations
    --                   'T'  Successfully got predicate
    --                   'F'  No predicates granted
    --                   'E'  Error
    --                   'U'  Unexpected Error
    --                   'L'  Value too long- predicate too large for
    --                        database VPD.
    --
    --                If 'E', 'U, or 'L' is returned, there will be an error
    --                message on the FND_MESSAGE stack which
    --                can be retrieved with FND_MESSAGE.GET_ENCODED()
    --                If that message is not used, it must be cleared.
    --
    --             Return Value:
    --                All the available predicates from the grants on
    --                this function for this user, ORed together to form
    --                a big gob of SQL that can be dropped into the where
    --                clause.  Does not include 'WHERE'.
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
-------------------------------------------------------------------------
  PROCEDURE get_security_predicate_clob
  (
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2 default null,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2 DEFAULT 'UNIVERSAL',/* SET, INSTANCE*/
    p_user_name        IN  VARCHAR2 default null,
    /* statement_type: 'OTHER', 'BASE'=VPD, 'EXISTS'= to check existence*/
    p_statement_type   IN  VARCHAR2 DEFAULT 'OTHER',
    p_pk1_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk2_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk3_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk4_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk5_alias        IN  VARCHAR2 DEFAULT NULL,
    x_predicate        OUT NOCOPY CLOB,
    x_return_status    OUT NOCOPY VARCHAR2
  )  ;
-------------------------------------------------------------------------
PROCEDURE get_sec_predicate_with_exists
  (
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2 default null,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2 DEFAULT 'UNIVERSAL',/* SET, INSTANCE*/
    p_party_id         IN NUMBER,
    /* stmnt_type: 'OTHER', 'BASE'=VPD, 'EXISTS'= for checking existence. */
    p_statement_type   IN  VARCHAR2 DEFAULT 'OTHER',
    p_pk1_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk2_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk3_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk4_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk5_alias        IN  VARCHAR2 DEFAULT NULL,
    x_predicate        OUT NOCOPY VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2
  );
--------------------------------------------------------------------------

PROCEDURE get_sec_predicate_with_clause
  (
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2 default null,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2 DEFAULT 'UNIVERSAL',/* SET, INSTANCE*/
    p_party_id         IN  NUMBER,
    p_append_inst_set_predicate  IN  VARCHAR2 default null,
    /* stmnt_type: 'OTHER', 'BASE'=VPD, 'EXISTS'= for checking existence. */
    p_statement_type   IN  VARCHAR2 DEFAULT 'OTHER',
    p_pk1_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk2_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk3_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk4_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk5_alias        IN  VARCHAR2 DEFAULT NULL,
    x_predicate        OUT NOCOPY VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2
  );
----------------------------------------------------------------------------
  TYPE PARENT_OBJECT_TABLE_TYPE IS TABLE OF VARCHAR2(30)
  INDEX BY BINARY_INTEGER;

  TYPE RELATIONSHIP_SQL_TABLE_TYPE IS TABLE OF VARCHAR2(300)
  INDEX BY BINARY_INTEGER;

    PROCEDURE get_inherited_predicate
  (
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2 default null,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2 DEFAULT 'UNIVERSAL',/* SET, INSTANCE*/
    p_user_name        IN  VARCHAR2 default null,
    /* statement_type: 'OTHER', 'BASE'=VPD, 'EXISTS'= to check existence*/
    p_statement_type   IN  VARCHAR2 DEFAULT 'OTHER',
    p_pk1_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk2_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk3_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk4_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk5_alias        IN  VARCHAR2 DEFAULT NULL,
    p_object_type      IN  VARCHAR2 default null,
    p_parent_object_tbl   IN EGO_VARCHAR_TBL_TYPE,
    p_relationship_sql_tbl   IN EGO_VARCHAR_TBL_TYPE,
    p_parent_obj_alias_tbl   IN EGO_VARCHAR_TBL_TYPE,
    x_predicate        OUT NOCOPY VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2
  )  ;

--------------------------------------------------------------------------

   PROCEDURE get_inherited_predicate
  (
    p_api_version      IN  NUMBER,
    p_function         IN  VARCHAR2 default null,
    p_object_name      IN  VARCHAR2,
    p_grant_instance_type  IN  VARCHAR2 DEFAULT 'UNIVERSAL',/* SET, INSTANCE*/
    p_user_name        IN  VARCHAR2 default null,
    /* statement_type: 'OTHER', 'BASE'=VPD, 'EXISTS'= to check existence*/
    p_statement_type   IN  VARCHAR2 DEFAULT 'OTHER',
    p_pk1_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk2_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk3_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk4_alias        IN  VARCHAR2 DEFAULT NULL,
    p_pk5_alias        IN  VARCHAR2 DEFAULT NULL,
    p_object_type      IN  VARCHAR2 default null,
    p_parent_object_tbl   IN EGO_VARCHAR_TBL_TYPE,
    p_relationship_sql_tbl   IN EGO_VARCHAR_TBL_TYPE,
    p_parent_obj_pk1alias_tbl   IN EGO_VARCHAR_TBL_TYPE,
    p_parent_obj_pk2alias_tbl   IN EGO_VARCHAR_TBL_TYPE,
    x_predicate        OUT NOCOPY VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2
  )  ;

--------------------------------------------------------------------------

 PROCEDURE get_inherited_predicate
  (
    p_api_version                    IN  NUMBER,
    p_function                       IN  VARCHAR2 default null,
    p_object_name                    IN  VARCHAR2,
    p_grant_instance_type            IN  VARCHAR2 DEFAULT 'UNIVERSAL',/* SET, INSTANCE*/
    p_user_name                      IN  VARCHAR2 default null,
    /* statement_type: 'OTHER', 'BASE'=VPD, 'EXISTS'= to check existence*/
    p_statement_type                 IN  VARCHAR2 DEFAULT 'OTHER',
    p_pk1_alias                      IN  VARCHAR2 DEFAULT NULL,
    p_pk2_alias                      IN  VARCHAR2 DEFAULT NULL,
    p_pk3_alias                      IN  VARCHAR2 DEFAULT NULL,
    p_pk4_alias                      IN  VARCHAR2 DEFAULT NULL,
    p_pk5_alias                      IN  VARCHAR2 DEFAULT NULL,
    p_object_type                    IN VARCHAR2 default null,
    p_parent_object_tbl              IN EGO_VARCHAR_TBL_TYPE,
    p_relationship_sql_tbl           IN EGO_VARCHAR_TBL_TYPE,
    p_parent_obj_pk1alias_tbl        IN EGO_VARCHAR_TBL_TYPE,
    p_parent_obj_pk2alias_tbl        IN EGO_VARCHAR_TBL_TYPE,
    x_predicate                      OUT NOCOPY varchar2,
    x_clob_predicate                 OUT NOCOPY CLOB,
    x_return_status                  OUT NOCOPY varchar2
  );

----------------------------------------------------------------------------

TYPE EGO_INSTANCE_PK_RECORD is record
              (PK1_VALUE    varchar2(256),
               PK2_VALUE    varchar2(256),
               PK3_VALUE    varchar2(256),
               PK4_VALUE    varchar2(256),
               PK5_VALUE    varchar2(256));

TYPE EGO_INSTANCE_TABLE_TYPE IS TABLE OF EGO_INSTANCE_PK_RECORD
   INDEX BY BINARY_INTEGER;

PROCEDURE get_instances
(
    p_api_version    IN  NUMBER,
    p_function       IN  VARCHAR2 DEFAULT NULL,
    p_object_name    IN  VARCHAR2,
    p_user_name      IN  VARCHAR2 DEFAULT NULL,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_object_key_tbl OUT NOCOPY EGO_INSTANCE_TABLE_TYPE
);
    -- Start OF comments
    -- API name  : get_instances
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : get list of all instances granted to a particular user
    --              on a particular function.
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
    --             p_user_name IN VARCHAR2 (optional)
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
    -- Start OF comments
    -- API name  : check_instance_in_set
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Check whether a particular object instance is part of an
    --             instance set.
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure (currently 1.0)
    --
    --             p_instance_set_name in varchar2
    --             the instance set name for the instance set to be checked.
    --
    --             p_instance_pk[1..5]_value     IN  NUMBER (required)
    --             Primary key values for the object instance, with order
    --             corresponding to the order of the PKs in the
    --             FND_OBJECTS table.  Most objects will only have a
    --             few primary key columns so just let the higher,
    --             unused column values default to NULL.
    --
    --     OUT  :
    --             RETURNs 1 byte result code:
    --                   'T'  instance is part of instance set.
    --                   'F'  instance is not part of instance set.
    --                   'E'  Error
    --                   'U'  Unexpected Error
    --
    --                If 'E' or 'U' is returned, there will be an error
    --                message on the FND_MESSAGE stack which
    --                can be retrieved with FND_MESSAGE.GET_ENCODED()
    --                If that message is not used, it must be cleared.
    --
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments

-- signature to use if caller wants to specify OWNER
PROCEDURE Create_Role_Mapping(
         p_api_version                  IN   NUMBER
        ,p_parent_obj_name              IN   VARCHAR2
        ,p_parent_role_name             IN   VARCHAR2
        ,p_child_obj_name               IN   VARCHAR2
        ,p_child_object_type            IN   VARCHAR2
        ,p_child_role_name              IN   VARCHAR2
        ,p_owner                        IN   NUMBER
        ,p_init_msg_list                IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,p_commit                       IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,x_return_status                OUT  NOCOPY VARCHAR2
        ,x_errorcode                    OUT  NOCOPY NUMBER
        ,x_msg_count                    OUT  NOCOPY NUMBER
        ,x_msg_data                     OUT  NOCOPY VARCHAR2
) ;

-- signature to use if caller does not want to specify OWNER
PROCEDURE Create_Role_Mapping(
         p_api_version                  IN   NUMBER
        ,p_parent_obj_name              IN   VARCHAR2
        ,p_parent_role_name             IN   VARCHAR2
        ,p_child_obj_name               IN   VARCHAR2
        ,p_child_object_type            IN   VARCHAR2
        ,p_child_role_name              IN   VARCHAR2
        ,p_init_msg_list                IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,p_commit                       IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,x_return_status                OUT  NOCOPY VARCHAR2
        ,x_errorcode                    OUT  NOCOPY NUMBER
        ,x_msg_count                    OUT  NOCOPY NUMBER
        ,x_msg_data                     OUT  NOCOPY VARCHAR2
) ;

-- signature to use if caller wants to specify OWNER
PROCEDURE Update_Role_Mapping(
         p_api_version                  IN   NUMBER
        ,p_parent_obj_name              IN   VARCHAR2
        ,p_parent_role_name             IN   VARCHAR2
        ,p_child_obj_name               IN   VARCHAR2
        ,p_child_object_type            IN   VARCHAR2
        ,p_child_role_name              IN   VARCHAR2
        ,p_owner                        IN   NUMBER
        ,p_init_msg_list                IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,p_commit                       IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,x_return_status                OUT  NOCOPY VARCHAR2
        ,x_errorcode                    OUT  NOCOPY NUMBER
        ,x_msg_count                    OUT  NOCOPY NUMBER
        ,x_msg_data                     OUT  NOCOPY VARCHAR2
) ;

-- signature to use if caller does not want to specify OWNER
PROCEDURE Update_Role_Mapping(
         p_api_version                  IN   NUMBER
        ,p_parent_obj_name              IN   VARCHAR2
        ,p_parent_role_name             IN   VARCHAR2
        ,p_child_obj_name               IN   VARCHAR2
        ,p_child_object_type            IN   VARCHAR2
        ,p_child_role_name              IN   VARCHAR2
        ,p_init_msg_list                IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,p_commit                       IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,x_return_status                OUT  NOCOPY VARCHAR2
        ,x_errorcode                    OUT  NOCOPY NUMBER
        ,x_msg_count                    OUT  NOCOPY NUMBER
        ,x_msg_data                     OUT  NOCOPY VARCHAR2
) ;

PROCEDURE Delete_Role_Mapping(
         p_api_version                  IN   NUMBER
        ,p_parent_obj_name              IN   VARCHAR2
        ,p_parent_role_name             IN   VARCHAR2
        ,p_child_obj_name               IN   VARCHAR2
        ,p_child_object_type            IN   VARCHAR2
        ,p_init_msg_list                IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,p_commit                       IN   VARCHAR2   :=  fnd_api.g_FALSE
        ,x_return_status                OUT  NOCOPY VARCHAR2
        ,x_errorcode                    OUT  NOCOPY NUMBER
        ,x_msg_count                    OUT  NOCOPY NUMBER
        ,x_msg_data                     OUT  NOCOPY VARCHAR2
) ;

 ----------------------------------------------------------------

   PROCEDURE get_role_functions
  (
   p_api_version         IN  NUMBER,
   p_role_name           IN  VARCHAR2,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_privilege_tbl       OUT NOCOPY EGO_VARCHAR_TBL_TYPE
  ) ;

  ----------------------------------------------------------------

    PROCEDURE get_inherited_functions
  (
   p_api_version                 IN  NUMBER,
   p_object_name                 IN  VARCHAR2,
   p_instance_pk1_value          IN  VARCHAR2,
   p_instance_pk2_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value          IN  VARCHAR2 DEFAULT NULL,
   p_user_name                   IN  VARCHAR2 DEFAULT NULL,
   p_object_type                 IN  VARCHAR2 DEFAULT NULL,
   p_parent_object_name_tbl      IN  EGO_VARCHAR_TBL_TYPE,
   p_parent_object_sql_tbl       IN  EGO_VARCHAR_TBL_TYPE,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_privilege_tbl               OUT NOCOPY EGO_VARCHAR_TBL_TYPE
  ) ;


FUNCTION check_inherited_function
  (
   p_api_version                 IN  NUMBER,
   p_function                    IN  VARCHAR2,
   p_object_name                 IN  VARCHAR2,
   p_instance_pk1_value          IN  VARCHAR2,
   p_instance_pk2_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value          IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value          IN  VARCHAR2 DEFAULT NULL,
   p_parent_object_name_tbl      IN  EGO_VARCHAR_TBL_TYPE,
   p_parent_object_sql_tbl       IN  EGO_VARCHAR_TBL_TYPE,
   p_user_name                   IN  VARCHAR2 DEFAULT NULL,
   p_object_type                 IN  VARCHAR2 DEFAULT NULL
 )
  RETURN VARCHAR2;

END EGO_DATA_SECURITY;

/

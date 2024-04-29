--------------------------------------------------------
--  DDL for Package BOM_SECURITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_SECURITY_PUB" AUTHID CURRENT_USER AS
/* $Header: BOMSECPS.pls 120.2 2005/07/27 08:59:10 earumuga noship $ */
/*#
* This API  contains methods to ensure BOM security
* @rep:scope public
* @rep:product BOM
* @rep:displayname BOM Security Policy Package
* @rep:lifecycle active
* @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
*/

--This is for temporary testing in systemtest has to remove this
--Prior to releasing as all the internal users have EGO_VIEW_ITEM Privelege
FUNCTION_NAME_TO_CHECK VARCHAR2(30) := 'EGO_VIEW_ITEM';
EDIT_ITEM_PREVILEGE VARCHAR2(30) := 'EGO_EDIT_ITEM';

    -- Start OF comments
    -- API name  : CHECK_USER_PRIVILEGE
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

/*#
* Determines whether user is granted a particular function for a particular object instance
* @param p_api_version API Version of this procedure (currently 1.0)
* @param p_function name of the function
* @param p_object_name object on which the grant should be checked from fnd_objects table.
* @param p_instance_pk1_value [1...5] Primary key values for the object instance, with order
* corresponding to the order of the PKs in the FND_OBJECTS table. Most objects will only have
* a few primary key columns so just let the higher,unused column values default to NULL
* @param p_user_name User to check grant for, from FND_USER or another table (like HZ_PARTIES)
* that the view column WF_ROLES.NAME is based on.Pass the same value stored in the GRANTEE_KEY
* column in FND_GRANTS.Examples of values that might be passed: 'SYSADMIN','HZ_PARTIES:1234'
* Defaults to current FND user if null.
* @return 1 byte result code: 'T'  function is granted, 'F'  not granted , 'E'  Error,
* 'U' Unexpected Error . If 'E' or 'U' is returned, there will be an error message on the
* FND_MESSAGE stack which can be retrieved with FND_MESSAGE.GET_ENCODED() If that message is not used,
* it must be cleared.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Check User Privilege
*/
FUNCTION CHECK_USER_PRIVILEGE
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
    -- API name  : CHECK_ITEM_PRIVILEGE
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Determines whether user is granted a particular
    --             function for a particular object instance.
    --
    -- Parameters:
    --     IN    : p_function         IN  VARCHAR2 (required)
    --             name of the function
    --             p_inventory_item_id IN VARCHAR2
    --               item id of the inventory item
    --             p_organization_id IN VARCHAR2
    --               organization in which the  inventory item
    --               is defined.
    --             p_user_name IN VARCHAR2
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

/*#
* Determines whether user is granted a particular function for a particular object instance
* @param p_function name of the function
* @param p_inventory_item_id item id of the inventory item
* @param p_organization_id organization in which the  inventory item is defined
* @param p_user_name user name
* @return 1 byte result code: 'T'  function is granted, 'F'  not granted , 'E'  Error,
* 'U' Unexpected Error . If 'E' or 'U' is returned, there will be an error message on the
* FND_MESSAGE stack which can be retrieved with FND_MESSAGE.GET_ENCODED() If that message is not used,
* it must be cleared
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Check Item Privilege
*/

FUNCTION CHECK_ITEM_PRIVILEGE
  (
   p_function         IN  VARCHAR2,
   p_inventory_item_id IN  VARCHAR2,
   p_organization_id IN    VARCHAR2,
   p_user_name            in varchar2  default null
 )
 RETURN VARCHAR2;


/* Function that return the Logged in EGO USER */

/*#
* Method that return the Logged in EGO USER
* @return the user name of the logged in EGO user
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Get EGO User
*/
FUNCTION  GET_EGO_USER
RETURN VARCHAR2;

FUNCTION  GET_FUNCTION_NAME_TO_CHECK RETURN VARCHAR2;

END BOM_SECURITY_PUB; -- Package spec

 

/

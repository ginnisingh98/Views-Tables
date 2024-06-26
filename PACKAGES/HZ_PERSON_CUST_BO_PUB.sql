--------------------------------------------------------
--  DDL for Package HZ_PERSON_CUST_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PERSON_CUST_BO_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHBPABS.pls 120.8 2008/02/06 11:23:42 vsegu ship $ */
/*#
 * Person Customer Business Object API
 * Public API that allows users to manage Person Customer business objects in the Trading Community Architecture.
 * Several operations are supported, including the creation and update of the business object.
 *
 * @rep:scope public
 * @rep:product HZ
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY HZ_PERSON
 * @rep:displayname Person Customer Business Object API
 * @rep:doccd 120hztig.pdf Person Customer Business Object API, Oracle Trading Community Architecture Technical Implementation Guide
 */


  -- PROCEDURE create_person_cust_bo
  --
  -- DESCRIPTION
  --     Create person customer account.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list       Initialize message stack if it is set to
  --                           FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag    If it is set to FND_API.G_TRUE, validate
  --                           the completeness of business object.
  --     p_person_cust_obj     Logical person customer account object.
  --     p_created_by_module   Created by module.
  --   OUT:
  --     x_return_status       Return status after the call. The status can
  --                           be fnd_api.g_ret_sts_success (success),
  --                           fnd_api.g_ret_sts_error (error),
  --                           FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count           Number of messages in message stack.
  --     x_msg_data            Message text if x_msg_count is 1.
  --     x_person_id           Person ID.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.


  PROCEDURE create_person_cust_bo(
    p_init_msg_list        IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag     IN            VARCHAR2 := fnd_api.g_true,
    p_person_cust_obj      IN            HZ_PERSON_CUST_BO,
    p_created_by_module    IN            VARCHAR2,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_msg_count            OUT NOCOPY    NUMBER,
    x_msg_data             OUT NOCOPY    VARCHAR2,
    x_person_id            OUT NOCOPY    NUMBER
  );

/*#
 * Create Person Customer Business Object (create_person_cust_bo)
 * Creates a Person Customer business object. You pass object data to the procedure, packaged within an object type defined
 * specifically for the API. The object type is HZ_PERSON_CUST_BO for the Person Customer business object. In addition to
 * the object's business object attributes, the object type also includes lower-level embedded child entities or objects
 * that can be simultaneously created.
 *
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_person_cust_obj The Person Customer business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the creation of the business object
 * @param x_return_obj The Person Customer business object that was created, returned as an output parameter
 * @param x_person_id TCA identifier for the Person Customer business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Person Customer Business Object
 * @rep:doccd 120hztig.pdf Create Person Customer Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */

  PROCEDURE create_person_cust_bo(
    p_validate_bo_flag     IN            VARCHAR2 := fnd_api.g_true,
    p_person_cust_obj      IN            HZ_PERSON_CUST_BO,
    p_created_by_module    IN            VARCHAR2,
    p_obj_source           IN            VARCHAR2 := null,
    p_return_obj_flag          IN            VARCHAR2 := fnd_api.g_true,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj           OUT NOCOPY    HZ_PERSON_CUST_BO,
    x_person_id            OUT NOCOPY    NUMBER
  );

  -- PROCEDURE update_person_cust_bo
  --
  -- DESCRIPTION
  --     Update person customer account.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list       Initialize message stack if it is set to
  --                           FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_person_cust_obj     Logical person customer account object.
  --     p_created_by_module   Created by module.
  --   OUT:
  --     x_return_status       Return status after the call. The status can
  --                           be fnd_api.g_ret_sts_success (success),
  --                           fnd_api.g_ret_sts_error (error),
  --                           FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count           Number of messages in message stack.
  --     x_msg_data            Message text if x_msg_count is 1.
  --     x_person_id           Person ID.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.


  PROCEDURE update_person_cust_bo(
    p_init_msg_list        IN            VARCHAR2 := fnd_api.g_false,
    p_person_cust_obj      IN            HZ_PERSON_CUST_BO,
    p_created_by_module    IN            VARCHAR2,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_msg_count            OUT NOCOPY    NUMBER,
    x_msg_data             OUT NOCOPY    VARCHAR2,
    x_person_id            OUT NOCOPY    NUMBER
  );

/*#
 * Update Person Customer Business Object (update_person_cust_bo)
 * Updates a Person Customer business object. You pass any modified object data to the procedure, packaged within an object
 * type defined specifically for the API. The object type is HZ_PERSON_CUST_BO for the Person Customer business object.
 * In addition to the object's business object attributes, the object type also includes embedded child business entities
 * or objects that can be simultaneously created or updated.
 *
 * @param p_person_cust_obj The Person Customer business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the update of the business object
 * @param x_return_obj The Person Customer business object that was updated, returned as an output parameter
 * @param x_person_id TCA identifier for the Person Customer business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Person Customer Business Object
 * @rep:doccd 120hztig.pdf Update Person Customer Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */


  PROCEDURE update_person_cust_bo(
    p_person_cust_obj      IN            HZ_PERSON_CUST_BO,
    p_created_by_module    IN            VARCHAR2,
    p_obj_source           IN            VARCHAR2 := null,
    p_return_obj_flag      IN            VARCHAR2 := fnd_api.g_true,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj           OUT NOCOPY    HZ_PERSON_CUST_BO,
    x_person_id            OUT NOCOPY    NUMBER
  );

  -- PROCEDURE save_person_cust_bo
  --
  -- DESCRIPTION
  --     Create or update person customer account.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list       Initialize message stack if it is set to
  --                           FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag    If it is set to FND_API.G_TRUE, validate
  --                           the completeness of business object.
  --     p_person_cust_obj     Logical person customer account object.
  --     p_created_by_module   Created by module.
  --   OUT:
  --     x_return_status       Return status after the call. The status can
  --                           be fnd_api.g_ret_sts_success (success),
  --                           fnd_api.g_ret_sts_error (error),
  --                           FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count           Number of messages in message stack.
  --     x_msg_data            Message text if x_msg_count is 1.
  --     x_person_id           Person ID.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.


  PROCEDURE save_person_cust_bo(
    p_init_msg_list        IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag     IN            VARCHAR2 := fnd_api.g_true,
    p_person_cust_obj      IN            HZ_PERSON_CUST_BO,
    p_created_by_module    IN            VARCHAR2,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_msg_count            OUT NOCOPY    NUMBER,
    x_msg_data             OUT NOCOPY    VARCHAR2,
    x_person_id            OUT NOCOPY    NUMBER
  );

/*#
 * Save Person Customer Business Object (save_person_cust_bo)
 * Saves a Person Customer business object. You pass new or modified object data to the procedure, packaged within an object
 * type defined specifically for the API. The API then determines if the object exists in TCA, based upon the provided
 * identification information, and creates or updates the object. The object type is HZ_PERSON_CUST_BO for the Person Customer
 * business object. For either case, the object type that you provide will be processed as if the respective API procedure
 * is being called (create_person_cust_bo or update_person_cust_bo). Please see those procedures for more details.
 * In addition to the object's business object attributes, the object type also includes embedded child business entities
 * or objects that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_person_cust_obj The Person Customer business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Person Customer business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_person_id TCA identifier for the Person Customer business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save Person Customer Business Object
 * @rep:doccd 120hztig.pdf Save Person Customer Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */


  PROCEDURE save_person_cust_bo(
    p_validate_bo_flag     IN            VARCHAR2 := fnd_api.g_true,
    p_person_cust_obj      IN            HZ_PERSON_CUST_BO,
    p_created_by_module    IN            VARCHAR2,
    p_obj_source           IN            VARCHAR2 := null,
    p_return_obj_flag          IN            VARCHAR2 := fnd_api.g_true,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj           OUT NOCOPY    HZ_PERSON_CUST_BO,
    x_person_id            OUT NOCOPY    NUMBER
  );

  --------------------------------------
  --
  -- PROCEDURE get_person_cust_bo
  --
  -- DESCRIPTION
  --     Get a logical person customer.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
--       p_person_id          Person ID.
 --     p_person_os           Person orig system.
  --     p_person_osr         Person orig system reference.

  --   OUT:
  --     x_person_cust_obj         Logical person customer record.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --
  --   10-JUN-2005   AWU                Created.
  --

/*
The Get Person Customer API Procedure is a retrieval service that returns a full Person Customer business object.
The user identifies a particular Person Customer business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full Person Customer business object is returned. The object consists of all data included within
the Person Customer business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the Person Customer business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments

Person			Y	N	get_person_bo
Customer Account	Y	Y	get_cust_acct_bo	Called for each Customer Account object for the Person Customer

*/


 PROCEDURE get_person_cust_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_person_id           IN            NUMBER,
    p_person_os		IN	VARCHAR2,
    p_person_osr		IN	VARCHAR2,
    x_person_cust_obj     OUT NOCOPY    HZ_PERSON_CUST_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Get Person Customer Business Object (get_person_cust_bo)
 * Extracts a particular Person Customer business object from TCA. You pass the object's identification information to the
 * procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_person_id TCA identifier for the Person Customer business object
 * @param p_person_os Person Customer original system name
 * @param p_person_osr Person Customer original system reference
 * @param x_person_cust_obj The retrieved Person Customer business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Person Customer Business Object
 * @rep:doccd 120hztig.pdf Get Person Customer Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */


 PROCEDURE get_person_cust_bo(
    p_person_id           IN            NUMBER,
    p_person_os         IN      VARCHAR2,
    p_person_osr                IN      VARCHAR2,
    x_person_cust_obj     OUT NOCOPY    HZ_PERSON_CUST_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );

 --------------------------------------
  --
  -- PROCEDURE get_person_custs_created
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Person Customers created business event and
  --the procedure returns database objects of the type HZ_PERSON CUSTOMER_BO for all of
  --the Person Customer business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_objs   One or more created logical person customer.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   10-JUN-2005    AWU                Created.
  --



/*
The Get Person customers Created procedure is a service to retrieve all of the Person Customer business objects
whose creations have been captured by a logical business event. Each Person Customers Created
business event signifies that one or more Person Customer business objects have been created.
The caller provides an identifier for the Person Customers Created business event and the procedure
returns all of the Person Customer business objects from the business event. For each business object
creation captured in the business event, the procedure calls the generic Get operation:
HZ_PERSON_BO_PVT.get_person_bo

Gathering all of the returned business objects from those API calls, the procedure packages
them in a table structure and returns them to the caller.
*/

PROCEDURE get_person_custs_created(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_cust_objs         OUT NOCOPY    HZ_PERSON_CUST_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Get Created Person Customer Business Objects (get_person_custs_created)
 * Extracts the Person Customer business objects from TCA based upon an event identifier (event_id) for a
 * Person Customer(s) Created Business Object Event. You provide the event_id value to the procedure, and the
 * procedure returns the set of Person Customer business objects that were updated as part of the event. The
 * event identifer value must be valid for a Person Customer(s) Created Business Object Event.
 *
 * @param p_event_id TCA Business Object Event identifier for the 'Person Customer(s) Created' event
 * @param x_person_cust_objs Person Customer business objects created as part of the 'Person Customer(s) Created' Business Object event
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business objects
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Created Person Customer Business Objects
 * @rep:doccd 120hztig.pdf Get Business Object API Procedures, Oracle Trading Community Architecture Technical Implementation Guide
 */

PROCEDURE get_person_custs_created(
    p_event_id            IN            NUMBER,
    x_person_cust_objs         OUT NOCOPY    HZ_PERSON_CUST_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );


--------------------------------------
  --
  -- PROCEDURE get_person_custs_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Person Customers update business event and
  --the procedure returns database objects of the type HZ_PERSON_CUST_BO for all of
  --the Person Customer business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_objs   One or more created logical person.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   10-JUN-2005     AWU                Created.
  --



/*
The Get Person Customers Updated procedure is a service to retrieve all of the Person Customer business objects whose updates
have been captured by the logical business event. Each Person Customers Updated business event signifies that one or more Person
Customer business objects have been updated.
The caller provides an identifier for the Person Customers Update business event and the procedure returns database objects of
the type HZ_PERSON_CUST_BO for all of the Person Customer business objects from the business event.
Gathering all of the returned database objects from those API calls, the procedure packages them in a table structure and returns
them to the caller.
*/

 PROCEDURE get_person_custs_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_cust_objs         OUT NOCOPY    HZ_PERSON_CUST_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Get Updated Person Customer Business Objects (get_person_custs_updated)
 * Extracts the Person Customer business objects from TCA based upon an event identifier (event_id) for a Person Customer(s)
 * Updated Business Object Event. You provide the event_id value to the procedure, and the procedure returns the set of
 * Person Customer business objects that were updated as part of the event. The event identifer value must be valid for a
 * Person Customer(s) Updated Business Object Event.
 *
 * Provided within the returned business objects are Action Flags that designate how the data, at a particular level of
 * an object, has changed as a result of the update to the Person Customer business object. Each business object, structure,
 * and entity has the attribute action_type that provides this type of update. Possible values for the Action Type are
 * 'CREATED', 'UPDATED', 'CHILD_UPDATED', or 'UNCHANGED':
 *
 * Action Type Value: Created
 * An action type value of 'CREATED' indicates, for a business object or structure, that the root attributes of the object
 * were created and any number of embedded objects, structures, or entities were also created as part of this update.
 * For a business entity, the value 'CREATED' indicates that its root attributes were created as part of this update.
 *
 * Action Type: Updated
 * An action type value of 'UPDATED' indicates, for a business object or structure, that the root attributes of the object
 * were updated and any number of embedded objects, structure, or entities were created or updated as part of this update.
 * For a business entity, the value 'UPDATED' indicates that its root attributes were updated as part of this update.
 *
 * Action Type: Child Updated
 * An action type value of 'CHILD_UPDATED' indicates, for a business object or structure, that the root attributes of the
 * object were untouched, but at least one child embedded object, structure, or entity was created or updated as part of
 * this update. For a business entity, this value is not valid as it has no children.
 *
 * Action Type: Unchanged
 * An action type value of 'UNCHANGED' indicates, for a business object, structure, or entity, that there has been no
 * change to its root attributes or any of its child objects, structures, or entities.
 *
 * @param p_event_id TCA Business Object Event identifier for the 'Person Customer(s) Updated' event
 * @param x_person_cust_objs Person Customer business objects updated as part of the 'Person Customer(s) Updated' Business Object event
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business objects
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Updated Person Customer Business Objects
 * @rep:doccd 120hztig.pdf Get Updated Business Object Procedures, Oracle Trading Community Architecture Technical Implementation Guide
 */

 PROCEDURE get_person_custs_updated(
    p_event_id            IN            NUMBER,
    x_person_cust_objs         OUT NOCOPY    HZ_PERSON_CUST_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );

--------------------------------------
  --
  -- PROCEDURE get_person_cust_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Person customer update business event and person id
  --the procedure returns one database object of the type HZ_PERSON_CUST_BO
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --     p_person_cust_id        Person customer identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_obj       One updated logical person.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   06-JUN-2005     AWU                Created.
  --

 PROCEDURE get_person_cust_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    p_person_cust_id           IN           NUMBER,
    x_person_cust_obj         OUT NOCOPY    HZ_PERSON_CUST_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Get Updated Person Customer Business Object (get_person_cust_updated)
 * Extracts an updated Person Customer business object from TCA based upon the object identifier (person_cust_id) and event
 * identifier (event_id). You provide values for the two identifiers to the procedure, and the procedure returns the
 * identified business object. The event identifier value must be valid for a Person Customer(s) Updated Business Object Event.
 *
 * Provided within the returned business object are Action Flags that designate how the data, at a particular level of the
 * object, has changed as a result of the update to the Person Customer business object. Each business object, structure, and
 * entity has the attribute action_type that provides this type of update. Possible values for the Action Type are
 * 'CREATED', 'UPDATED', 'CHILD_UPDATED', or 'UNCHANGED' as described
 *
 * Action Type Value: Created
 * An action type value of 'CREATED' indicates, for a business object or structure, that the root attributes of the object
 * were created and any number of embedded objects, structures, or entities were also created as part of this update. For
 * a business entity, the value 'CREATED' indicates that its root attributes were created as part of this update.
 *
 * Action Type: Updated
 * An action type value of 'UPDATED' indicates, for a business object or structure, that the root attributes of the object
 * were updated and any number of embedded objects, structure, or entities were created or updated as part of this update.
 * For a business entity, the value 'UPDATED' indicates that its root attributes were updated as part of this update.
 *
 * Action Type: Child Updated
 * An action type value of 'CHILD_UPDATED' indicates, for a business object or structure, that the root attributes of the
 * object were untouched, but at least one child embedded object, structure, or entity was created or updated as part of
 * this update. For a business entity, this value is not valid as it has no children.
 *
 * Action Type: Unchanged
 * An action type value of 'UNCHANGED' indicates, for a business object, structure, or entity, that there has been no change
 * to its root attributes or any of its child objects, structures, or entities.
 *
 * @param p_event_id TCA Business Object Event identifier for the 'Person Customer(s) Updated' event
 * @param p_person_cust_id TCA identifier for the updated Person Customer business object
 * @param x_person_cust_obj Person Customer business object updated as part of the 'Person Customer(s) Updated' Business Object event
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Updated Person Customer Business Objects
 * @rep:doccd 120hztig.pdf Get Updated Business Object Procedures, Oracle Trading Community Architecture Technical Implementation Guide
 */

 PROCEDURE get_person_cust_updated(
    p_event_id            IN            NUMBER,
    p_person_cust_id           IN           NUMBER,
    x_person_cust_obj         OUT NOCOPY    HZ_PERSON_CUST_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );

/*#
 * Get Identifiers for Created Person Customer Business Objects (get_ids_person_custs_created)
 * Retrieves identification values for the Person Customer business objects created in the Person Customer(s) Created Business
 * Object Event. You pass an event identifier to the procedure (event_id), and the procedure returns an array of object
 * identifier (person_cust_id) values that designate all of the Person Customer business objects that were created as part
 * of this event.
 *
 * @param p_init_msg_list Initiailize FND message stack.
 * @param p_event_id TCA Business Object Event identifier for the 'Person Customer(s) Created' event
 * @param x_person_cust_ids TCA identifiers for the created Person Customer business objects
 * @param x_return_status Return status after the call
 * @param x_msg_count Number of messages in message stack.
 * @param x_msg_data Messages returned from the operation
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Identifiers for Created Person Customer Business Objects
 * @rep:doccd 120hztig.pdf Get Business Object API Procedures, Oracle Trading Community Architecture Technical Implementation Guide
 */

-- get TCA identifiers for create event
PROCEDURE get_ids_person_custs_created (
	p_init_msg_list		IN	VARCHAR2 := fnd_api.g_false,
	p_event_id		IN	NUMBER,
	x_person_cust_ids		OUT NOCOPY	HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL,
  	x_return_status       OUT NOCOPY    VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2

);

/*#
 * Get Identifiers for Updated Person Customer Business Objects (get_ids_person_custs_updated)
 * Retrieves identification values for the Person Customer business objects updated in the "Person Customer(s) Updated" Business
 * Object Event. You pass an event identifier to the procedure (event_id), and the procedure returns an array of object
 * identifier (person_cust_id) values that designate all of the Person Customer business objects that were updated as part
 * of this event.
 *
 * @param p_init_msg_list Initiailize FND message stack.
 * @param p_event_id TCA Business Object Event identifier for the 'Person Customer(s) Updated' event.
 * @param x_person_cust_ids TCA identifiers for the updated Person Customer business objects
 * @param x_return_status Return status after the call
 * @param x_msg_count Number of messages in message stack.
 * @param x_msg_data Messages returned from the operation
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Identifiers for Updated Person Customer Business Objects
 * @rep:doccd 120hztig.pdf Get Updated Business Object Procedures, Oracle Trading Community Architecture Technical Implementation Guide
 */
-- get TCA identifiers for update event
PROCEDURE get_ids_person_custs_updated (
	p_init_msg_list		IN	VARCHAR2 := fnd_api.g_false,
	p_event_id		IN	NUMBER,
	x_person_cust_ids		OUT NOCOPY	HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL,
  	x_return_status       OUT NOCOPY    VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
);


/*#
 * Create Person Customer Business Object (create_person_cust_v2_bo)
 * Creates a Person Customer business object. You pass object data to the procedure, packaged within an object type defined
 * specifically for the API. The object type is HZ_PERSON_CUST_V2_BO for the Person Customer business object. In addition to
 * the object's business object attributes, the object type also includes lower-level embedded child entities or objects
 * that can be simultaneously created.
 *
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_person_cust_v2_obj The Person Customer business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the creation of the business object
 * @param x_return_obj The Person Customer business object that was created, returned as an output parameter
 * @param x_person_id TCA identifier for the Person Customer business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Person Customer Business Object
 * @rep:doccd 120hztig.pdf Create Person Customer Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */

  PROCEDURE create_person_cust_v2_bo(
    p_validate_bo_flag     IN            VARCHAR2 := fnd_api.g_true,
    p_person_cust_v2_obj      IN            HZ_PERSON_CUST_V2_BO,
    p_created_by_module    IN            VARCHAR2,
    p_obj_source           IN            VARCHAR2 := null,
    p_return_obj_flag          IN            VARCHAR2 := fnd_api.g_true,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj           OUT NOCOPY    HZ_PERSON_CUST_V2_BO,
    x_person_id            OUT NOCOPY    NUMBER
  );

/*#
 * Update Person Customer Business Object (update_person_cust_v2_bo)
 * Updates a Person Customer business object. You pass any modified object data to the procedure, packaged within an object
 * type defined specifically for the API. The object type is HZ_PERSON_CUST_V2_BO for the Person Customer business object.
 * In addition to the object's business object attributes, the object type also includes embedded child business entities
 * or objects that can be simultaneously created or updated.
 *
 * @param p_person_cust_v2_obj The Person Customer business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the update of the business object
 * @param x_return_obj The Person Customer business object that was updated, returned as an output parameter
 * @param x_person_id TCA identifier for the Person Customer business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Person Customer Business Object
 * @rep:doccd 120hztig.pdf Update Person Customer Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */


  PROCEDURE update_person_cust_v2_bo(
    p_person_cust_v2_obj      IN            HZ_PERSON_CUST_V2_BO,
    p_created_by_module    IN            VARCHAR2,
    p_obj_source           IN            VARCHAR2 := null,
    p_return_obj_flag      IN            VARCHAR2 := fnd_api.g_true,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj           OUT NOCOPY    HZ_PERSON_CUST_V2_BO,
    x_person_id            OUT NOCOPY    NUMBER
  );

/*#
 * Save Person Customer Business Object (save_person_cust_v2_bo)
 * Saves a Person Customer business object. You pass new or modified object data to the procedure, packaged within an object
 * type defined specifically for the API. The API then determines if the object exists in TCA, based upon the provided
 * identification information, and creates or updates the object. The object type is HZ_PERSON_CUST_V2_BO for the Person Customer
 * business object. For either case, the object type that you provide will be processed as if the respective API procedure
 * is being called (create_person_cust_v2_bo or update_person_cust_v2_bo). Please see those procedures for more details.
 * In addition to the object's business object attributes, the object type also includes embedded child business entities
 * or objects that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_person_cust_v2_obj The Person Customer business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Person Customer business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_person_id TCA identifier for the Person Customer business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save Person Customer Business Object
 * @rep:doccd 120hztig.pdf Save Person Customer Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */


  PROCEDURE save_person_cust_v2_bo(
    p_validate_bo_flag     IN            VARCHAR2 := fnd_api.g_true,
    p_person_cust_v2_obj      IN            HZ_PERSON_CUST_V2_BO,
    p_created_by_module    IN            VARCHAR2,
    p_obj_source           IN            VARCHAR2 := null,
    p_return_obj_flag          IN            VARCHAR2 := fnd_api.g_true,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj           OUT NOCOPY    HZ_PERSON_CUST_V2_BO,
    x_person_id            OUT NOCOPY    NUMBER
  );

  --------------------------------------
  --
  -- PROCEDURE get_person_cust_v2_bo
  --
  -- DESCRIPTION
  --     Get a logical person customer.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
--       p_person_id          Person ID.
 --     p_person_os           Person orig system.
  --     p_person_osr         Person orig system reference.

  --   OUT:
  --     x_person_cust_v2_obj         Logical person customer record.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --
  --   1-FEB-2008   VSEGU                Created.
  --

/*
The Get Person Customer API Procedure is a retrieval service that returns a full Person Customer business object.
The user identifies a particular Person Customer business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full Person Customer business object is returned. The object consists of all data included within
the Person Customer business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the Person Customer business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments

Person			Y	N	get_person_bo
Customer Account	Y	Y	get_cust_acct_v2_bo	Called for each Customer Account object for the Person Customer

*/


 PROCEDURE get_person_cust_v2_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_person_id           IN            NUMBER,
    p_person_os		IN	VARCHAR2,
    p_person_osr		IN	VARCHAR2,
    x_person_cust_v2_obj     OUT NOCOPY    HZ_PERSON_CUST_V2_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Get Person Customer Business Object (get_person_cust_v2_bo)
 * Extracts a particular Person Customer business object from TCA. You pass the object's identification information to the
 * procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_person_id TCA identifier for the Person Customer business object
 * @param p_person_os Person Customer original system name
 * @param p_person_osr Person Customer original system reference
 * @param x_person_cust_v2_obj The retrieved Person Customer business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Person Customer Business Object
 * @rep:doccd 120hztig.pdf Get Person Customer Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */


 PROCEDURE get_person_cust_v2_bo(
    p_person_id           IN            NUMBER,
    p_person_os         IN      VARCHAR2,
    p_person_osr                IN      VARCHAR2,
    x_person_cust_v2_obj     OUT NOCOPY    HZ_PERSON_CUST_V2_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );



 --------------------------------------
  --
  -- PROCEDURE get_v2_person_custs_created
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Person Customers created business event and
  --the procedure returns database objects of the type HZ_PERSON CUSTOMER_BO for all of
  --the Person Customer business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_v2_objs   One or more created logical person customer.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   04-FEB-2008    VSEGU                Created.
  --



/*
The Get Person customers Created procedure is a service to retrieve all of the Person Customer business objects
whose creations have been captured by a logical business event. Each Person Customers Created
business event signifies that one or more Person Customer business objects have been created.
The caller provides an identifier for the Person Customers Created business event and the procedure
returns all of the Person Customer business objects from the business event. For each business object
creation captured in the business event, the procedure calls the generic Get operation:
HZ_PERSON_BO_PVT.get_person_bo

Gathering all of the returned business objects from those API calls, the procedure packages
them in a table structure and returns them to the caller.
*/

PROCEDURE get_v2_person_custs_created(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_cust_v2_objs         OUT NOCOPY    HZ_PERSON_CUST_V2_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Get Created Person Customer Business Objects (get_v2_person_custs_created)
 * Extracts the Person Customer business objects from TCA based upon an event identifier (event_id) for a
 * Person Customer(s) Created Business Object Event. You provide the event_id value to the procedure, and the
 * procedure returns the set of Person Customer business objects that were updated as part of the event. The
 * event identifer value must be valid for a Person Customer(s) Created Business Object Event.
 *
 * @param p_event_id TCA Business Object Event identifier for the 'Person Customer(s) Created' event
 * @param x_person_cust_v2_objs Person Customer business objects created as part of the 'Person Customer(s) Created' Business Object event
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business objects
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Created Person Customer Business Objects
 * @rep:doccd 120hztig.pdf Get Business Object API Procedures, Oracle Trading Community Architecture Technical Implementation Guide
 */

PROCEDURE get_v2_person_custs_created(
    p_event_id            IN            NUMBER,
    x_person_cust_v2_objs         OUT NOCOPY    HZ_PERSON_CUST_V2_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );


--------------------------------------
  --
  -- PROCEDURE get_v2_person_custs_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Person Customers update business event and
  --the procedure returns database objects of the type HZ_PERSON_CUST_V2_BO for all of
  --the Person Customer business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_v2_objs   One or more created logical person.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.

  --     x_msg_data           Message text if x_msg_count is 1.
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   04-FEB-2008     VSEGU                Created.
  --



/*
The Get Person Customers Updated procedure is a service to retrieve all of the Person Customer business objects whose updates
have been captured by the logical business event. Each Person Customers Updated business event signifies that one or more Person
Customer business objects have been updated.
The caller provides an identifier for the Person Customers Update business event and the procedure returns database objects of
the type HZ_PERSON_CUST_V2_BO for all of the Person Customer business objects from the business event.
Gathering all of the returned database objects from those API calls, the procedure packages them in a table structure and returns
them to the caller.
*/

 PROCEDURE get_v2_person_custs_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_cust_v2_objs         OUT NOCOPY    HZ_PERSON_CUST_V2_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );


/*#
 * Get Updated Person Customer Business Objects (get_v2_person_custs_updated)
 * Extracts the Person Customer business objects from TCA based upon an event identifier (event_id) for a Person Customer(s)
 * Updated Business Object Event. You provide the event_id value to the procedure, and the procedure returns the set of
 * Person Customer business objects that were updated as part of the event. The event identifer value must be valid for a
 * Person Customer(s) Updated Business Object Event.
 *
 * Provided within the returned business objects are Action Flags that designate how the data, at a particular level of
 * an object, has changed as a result of the update to the Person Customer business object. Each business object, structure,
 * and entity has the attribute action_type that provides this type of update. Possible values for the Action Type are
 * 'CREATED', 'UPDATED', 'CHILD_UPDATED', or 'UNCHANGED':
 *
 * Action Type Value: Created
 * An action type value of 'CREATED' indicates, for a business object or structure, that the root attributes of the object
 * were created and any number of embedded objects, structures, or entities were also created as part of this update.
 * For a business entity, the value 'CREATED' indicates that its root attributes were created as part of this update.
 *
 * Action Type: Updated
 * An action type value of 'UPDATED' indicates, for a business object or structure, that the root attributes of the object
 * were updated and any number of embedded objects, structure, or entities were created or updated as part of this update.
 * For a business entity, the value 'UPDATED' indicates that its root attributes were updated as part of this update.
 *
 * Action Type: Child Updated
 * An action type value of 'CHILD_UPDATED' indicates, for a business object or structure, that the root attributes of the
 * object were untouched, but at least one child embedded object, structure, or entity was created or updated as part of
 * this update. For a business entity, this value is not valid as it has no children.
 *
 * Action Type: Unchanged
 * An action type value of 'UNCHANGED' indicates, for a business object, structure, or entity, that there has been no
 * change to its root attributes or any of its child objects, structures, or entities.
 *
 * @param p_event_id TCA Business Object Event identifier for the 'Person Customer(s) Updated' event
 * @param x_person_cust_v2_objs Person Customer business objects updated as part of the 'Person Customer(s) Updated' Business Object event
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business objects
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Updated Person Customer Business Objects
 * @rep:doccd 120hztig.pdf Get Updated Business Object Procedures, Oracle Trading Community Architecture Technical Implementation Guide
 */

 PROCEDURE get_v2_person_custs_updated(
    p_event_id            IN            NUMBER,
    x_person_cust_v2_objs         OUT NOCOPY    HZ_PERSON_CUST_V2_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );

--------------------------------------
  --
  -- PROCEDURE get_v2_person_cust_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Person customer update business event and person id
  --the procedure returns one database object of the type HZ_PERSON_CUST_V2_BO
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --     p_person_cust_id        Person customer identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_v2_obj       One updated logical person.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   04-FEB-2008     VSEGU                Created.
  --

 PROCEDURE get_v2_person_cust_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    p_person_cust_id           IN           NUMBER,
    x_person_cust_v2_obj         OUT NOCOPY    HZ_PERSON_CUST_V2_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Get Updated Person Customer Business Object (get_v2_person_cust_updated)
 * Extracts an updated Person Customer business object from TCA based upon the object identifier (person_cust_id) and event
 * identifier (event_id). You provide values for the two identifiers to the procedure, and the procedure returns the
 * identified business object. The event identifier value must be valid for a Person Customer(s) Updated Business Object Event.
 *
 * Provided within the returned business object are Action Flags that designate how the data, at a particular level of the
 * object, has changed as a result of the update to the Person Customer business object. Each business object, structure, and
 * entity has the attribute action_type that provides this type of update. Possible values for the Action Type are
 * 'CREATED', 'UPDATED', 'CHILD_UPDATED', or 'UNCHANGED' as described
 *
 * Action Type Value: Created
 * An action type value of 'CREATED' indicates, for a business object or structure, that the root attributes of the object
 * were created and any number of embedded objects, structures, or entities were also created as part of this update. For
 * a business entity, the value 'CREATED' indicates that its root attributes were created as part of this update.
 *
 * Action Type: Updated
 * An action type value of 'UPDATED' indicates, for a business object or structure, that the root attributes of the object
 * were updated and any number of embedded objects, structure, or entities were created or updated as part of this update.
 * For a business entity, the value 'UPDATED' indicates that its root attributes were updated as part of this update.
 *
 * Action Type: Child Updated
 * An action type value of 'CHILD_UPDATED' indicates, for a business object or structure, that the root attributes of the
 * object were untouched, but at least one child embedded object, structure, or entity was created or updated as part of
 * this update. For a business entity, this value is not valid as it has no children.
 *
 * Action Type: Unchanged
 * An action type value of 'UNCHANGED' indicates, for a business object, structure, or entity, that there has been no change
 * to its root attributes or any of its child objects, structures, or entities.
 *
 * @param p_event_id TCA Business Object Event identifier for the 'Person Customer(s) Updated' event
 * @param p_person_cust_id TCA identifier for the updated Person Customer business object
 * @param x_person_cust_v2_obj Person Customer business object updated as part of the 'Person Customer(s) Updated' Business Object event
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Updated Person Customer Business Objects
 * @rep:doccd 120hztig.pdf Get Updated Business Object Procedures, Oracle Trading Community Architecture Technical Implementation Guide
 */

 PROCEDURE get_v2_person_cust_updated(
    p_event_id            IN            NUMBER,
    p_person_cust_id           IN           NUMBER,
    x_person_cust_v2_obj         OUT NOCOPY    HZ_PERSON_CUST_V2_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );



END HZ_PERSON_CUST_BO_PUB;

/

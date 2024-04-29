--------------------------------------------------------
--  DDL for Package HZ_ORGANIZATION_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ORGANIZATION_BO_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHBPOBS.pls 120.7 2006/09/21 18:02:30 acng noship $ */
/*#
 * Organization Business Object API
 * Public API that allows users to manage Organization business objects in the Trading Community Architecture.
 * Several operations are supported, including the creation and update of the business object.
 *
 * @rep:scope public
 * @rep:product HZ
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY HZ_ORGANIZATION
 * @rep:displayname Organization Business Object API
 * @rep:doccd 120hztig.pdf Organization Business Object API, Oracle Trading Community Architecture Technical Implementation Guide
 */

  -- PROCEDURE create_organization_bo
  --
  -- DESCRIPTION
  --     Create organization business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_organization_obj   Organization object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_organization_id    Organization ID.
  --     x_organization_os    Organization orig system.
  --     x_organization_osr   Organization orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   02-MAR-2005    Arnold Ng          Created.
  --

  PROCEDURE create_organization_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_organization_obj    IN            HZ_ORGANIZATION_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_organization_id     OUT NOCOPY    NUMBER,
    x_organization_os     OUT NOCOPY    VARCHAR2,
    x_organization_osr    OUT NOCOPY    VARCHAR2
  );

/*#
 * Create Organization Business Object (create_organization_bo)
 * Creates a Organization business object. You pass object data to the procedure, packaged within an object type defined
 * specifically for the API. The object type is HZ_ORGANIZATION_BO for the Organization business object. In addition to
 * the object's business object attributes, the object type also includes lower-level embedded child entities or objects
 * that can be simultaneously created.
 *
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_organization_obj The Organization business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the creation of the business object
 * @param x_return_obj The Organization business object that was created, returned as an output parameter
 * @param x_organization_id TCA identifier for the Organization business object
 * @param x_organization_os Organization original system name
 * @param x_organization_osr Organization original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Organization Business Object
 * @rep:doccd 120hztig.pdf Create Organization Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */

  PROCEDURE create_organization_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_organization_obj    IN            HZ_ORGANIZATION_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_ORGANIZATION_BO,
    x_organization_id     OUT NOCOPY    NUMBER,
    x_organization_os     OUT NOCOPY    VARCHAR2,
    x_organization_osr    OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE update_organization_bo
  --
  -- DESCRIPTION
  --     Update organization business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_organization_obj   Organization object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_organization_id    Organization ID.
  --     x_organization_os    Organization orig system.
  --     x_organization_osr   Organization orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   02-MAR-2005    Arnold Ng          Created.

  PROCEDURE update_organization_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_organization_obj    IN            HZ_ORGANIZATION_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_organization_id     OUT NOCOPY    NUMBER,
    x_organization_os     OUT NOCOPY    VARCHAR2,
    x_organization_osr    OUT NOCOPY    VARCHAR2
  );

/*#
 * Update Organization Business Object (update_organization_bo)
 * Updates a Organization business object. You pass any modified object data to the procedure, packaged within an object
 * type defined specifically for the API. The object type is HZ_ORGANIZATION_BO for the Organization business object.
 * In addition to the object's business object attributes, the object type also includes embedded child business entities
 * or objects that can be simultaneously created or updated.
 *
 * @param p_organization_obj The Organization business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the update of the business object
 * @param x_return_obj The Organization business object that was updated, returned as an output parameter
 * @param x_organization_id TCA identifier for the Organization business object
 * @param x_organization_os Organization original system name
 * @param x_organization_osr Organization original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Organization Business Object
 * @rep:doccd 120hztig.pdf Update Organization Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */

  PROCEDURE update_organization_bo(
    p_organization_obj    IN            HZ_ORGANIZATION_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag     IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_ORGANIZATION_BO,
    x_organization_id     OUT NOCOPY    NUMBER,
    x_organization_os     OUT NOCOPY    VARCHAR2,
    x_organization_osr    OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_organization_bo
  --
  -- DESCRIPTION
  --     Create or update organization business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_organization_obj   Organization object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_organization_id    Organization ID.
  --     x_organization_os    Organization orig system.
  --     x_organization_osr   Organization orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   02-MAR-2005    Arnold Ng          Created.

  PROCEDURE save_organization_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_organization_obj    IN            HZ_ORGANIZATION_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_organization_id     OUT NOCOPY    NUMBER,
    x_organization_os     OUT NOCOPY    VARCHAR2,
    x_organization_osr    OUT NOCOPY    VARCHAR2
  );

/*#
 * Save Organization Business Object (save_organization_bo)
 * Saves a Organization business object. You pass new or modified object data to the procedure, packaged within an object
 * type defined specifically for the API. The API then determines if the object exists in TCA, based upon the provided
 * identification information, and creates or updates the object. The object type is HZ_ORGANIZATION_BO for the Organization
 * business object. For either case, the object type that you provide will be processed as if the respective API procedure
 * is being called (create_organization_bo or update_organization_bo). Please see those procedures for more details.
 * In addition to the object's business object attributes, the object type also includes embedded child business entities
 * or objects that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_organization_obj The Organization business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Organization business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_organization_id TCA identifier for the Organization business object
 * @param x_organization_os Organization original system name
 * @param x_organization_osr Organization original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save Organization Business Object
 * @rep:doccd 120hztig.pdf Save Organization Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */

  PROCEDURE save_organization_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_organization_obj    IN            HZ_ORGANIZATION_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_ORGANIZATION_BO,
    x_organization_id     OUT NOCOPY    NUMBER,
    x_organization_os     OUT NOCOPY    VARCHAR2,
    x_organization_osr    OUT NOCOPY    VARCHAR2
  );

 --------------------------------------
  --
  -- PROCEDURE get_organization_bo
  --
  -- DESCRIPTION
  --     Get a logical organization.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to   FND_API.G_TRUE. Default is FND_API.G_FALSE.
--       p_organization_id          Organization ID.
 --     p_organization_os           Org orig system.
  --     p_organization_osr         Org orig system reference.
  --   OUT:
  --     x_organization_obj         Logical organization record.
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
  --   06-JUN-2005   AWU                Created.
  --

/*
The Get Organization API Procedure is a retrieval service that returns a full Organization business object.
The user identifies a particular Organization business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full Organization business object is returned. The object consists of all data included within
the Organization business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the Organization business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments
Org Contact	N	Y	get_contact_bo
Party Site	N	Y	get_party_site_bo
Phone	N	Y	get_phone_bo
Telex	N	Y	get_telex_bo
Email	N	Y	get_email_bo
Web	N	Y	get_web_bo
EDI	N	Y	get_edi_bo
EFT	N	Y	get_eft_bo
Financial Report	N	Y		Business Structure. Included entities: HZ_FINANCIAL_REPORTS, HZ_FINANCIAL_NUMBERS


To retrieve the appropriate embedded entities within the Organization business object,
the Get procedure returns all records for the particular organization from these TCA entity tables:

Embedded TCA Entity	Mandatory    Multiple	TCA Table Entities

Party, Org Profile	Y		N	HZ_PARTIES, HZ_ORGANIZATION_PROFILES
Org Preference		N		Y	HZ_PARTY_PREFERENCES
Relationship		N		Y	HZ_RELATIONSHIPS
Classification		N		Y	HZ_CODE_ASSIGNMENTS
Credit Rating		N		Y	HZ_CREDIT_RATINGS
Certification		N		Y	HZ_CERTIFICATIONS
Financial Profile	N		Y	HZ_FINANCIAL_PROFILE

*/


 PROCEDURE get_organization_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_organization_id           IN            NUMBER,
    p_organization_os		IN	VARCHAR2,
    p_organization_osr		IN	VARCHAR2,
    x_organization_obj          OUT NOCOPY    HZ_ORGANIZATION_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Get Organization Business Object (get_organization_bo)
 * Extracts a particular Organization business object from TCA. You pass the object's identification information to the
 * procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_organization_id TCA identifier for the Organization business object
 * @param p_organization_os Organization original system name
 * @param p_organization_osr Organization original system reference
 * @param x_organization_obj The retrieved Organization business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Organization Business Object
 * @rep:doccd 120hztig.pdf Get Organization Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */

 PROCEDURE get_organization_bo(
    p_organization_id           IN            NUMBER,
    p_organization_os           IN      VARCHAR2,
    p_organization_osr          IN      VARCHAR2,
    x_organization_obj          OUT NOCOPY    HZ_ORGANIZATION_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );

 --------------------------------------
  --
  -- PROCEDURE get_organizations_created
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Organizations created business event and
  --the procedure returns database objects of the type HZ_ORGANIZATION_BO for all of
  --the Organization business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_organization_objs        One or more created logical organization.
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
  --   06-JUN-2005    AWU                Created.
  --



/*
The Get Organizations Created procedure is a service to retrieve all of the Organization business objects
whose creations have been captured by a logical business event. Each Organizations Created
business event signifies that one or more Organization business objects have been created.
The caller provides an identifier for the Organizations Created business event and the procedure
returns all of the Organization business objects from the business event. For each business object
creation captured in the business event, the procedure calls the generic Get operation:
HZ_ORGANIZATION_BO_PVT.get_organization_bo

Gathering all of the returned business objects from those API calls, the procedure packages
them in a table structure and returns them to the caller.
*/


PROCEDURE get_organizations_created(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_organization_objs         OUT NOCOPY    HZ_ORGANIZATION_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Get Created Organization Business Objects (get_organizations_created)
 * Extracts the Organization business objects from TCA based upon an event identifier (event_id) for a Organization(s)
 * Created Business Object Event. You provide the event_id value to the procedure, and the procedure returns the set of
 * Organization business objects that were updated as part of the event. The event identifer value must be valid for a
 * Organization(s) Created Business Object Event.
 *
 * @param p_event_id TCA Business Object Event identifier for the 'Organization(s) Created' event
 * @param x_organization_objs Organization business objects created as part of the 'Organization(s) Created' Business Object event
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business objects
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Created Organization Business Objects
 * @rep:doccd 120hztig.pdf Get Business Object API Procedures, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_organizations_created(
    p_event_id            IN            NUMBER,
    x_organization_objs         OUT NOCOPY    HZ_ORGANIZATION_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );

--------------------------------------
  --
  -- PROCEDURE get_organizations_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Organizations update business event and
  --the procedure returns database objects of the type HZ_ORGANIZATION_BO for all of
  --the Organization business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_organization_objs        One or more created logical organization.
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



/*
The Get Organizations Updated procedure is a service to retrieve all of the Organization business objects whose updates
have been captured by the logical business event. Each Organizations Updated business event signifies that one or more
Organization business objects have been updated.
The caller provides an identifier for the Organizations Update business event and the procedure returns database objects
of the type HZ_ORGANIZATION_BO for all of the Organization business objects from the business event.
Gathering all of the returned database objects from those API calls, the procedure packages them in a table structure and
returns them to the caller.
*/

 PROCEDURE get_organizations_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_organization_objs         OUT NOCOPY    HZ_ORGANIZATION_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Get Updated Organization Business Objects (get_organizations_updated)
 * Extracts the Organization business objects from TCA based upon an event identifier (event_id) for a Organization(s)
 * Updated Business Object Event. You provide the event_id value to the procedure, and the procedure returns the set of
 * Organization business objects that were updated as part of the event. The event identifer value must be valid for a
 * Organization(s) Updated Business Object Event.
 *
 * Provided within the returned business objects are Action Flags that designate how the data, at a particular level of
 * an object, has changed as a result of the update to the Organization business object. Each business object, structure,
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
 * @param p_event_id TCA Business Object Event identifier for the 'Organization(s) Updated' event
 * @param x_organization_objs Organization business objects updated as part of the 'Organization(s) Updated' Business Object event
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business objects
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Updated Organization Business Objects
 * @rep:doccd 120hztig.pdf Get Updated Business Object Procedures, Oracle Trading Community Architecture Technical Implementation Guide
 */
 PROCEDURE get_organizations_updated(
    p_event_id            IN            NUMBER,
    x_organization_objs         OUT NOCOPY    HZ_ORGANIZATION_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );

--------------------------------------
  --
  -- PROCEDURE get_organization_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Organizations update business event and organization id
  --the procedure returns one database object of the type HZ_ORGANIZATION_BO
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_organization_objs        One or more created logical organization.
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

PROCEDURE get_organization_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    p_organization_id     IN           NUMBER,
    x_organization_obj    OUT NOCOPY   HZ_ORGANIZATION_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Get Updated Organization Business Object (get_organization_updated)
 * Extracts an updated Organization business object from TCA based upon the object identifier (organization_id) and event
 * identifier (event_id). You provide values for the two identifiers to the procedure, and the procedure returns the
 * identified business object. The event identifier value must be valid for a Organization(s) Updated Business Object Event.
 *
 * Provided within the returned business object are Action Flags that designate how the data, at a particular level of the
 * object, has changed as a result of the update to the Organization business object. Each business object, structure, and
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
 * @param p_event_id TCA Business Object Event identifier for the 'Organization(s) Updated' event
 * @param p_organization_id TCA identifier for the updated Organization business object
 * @param x_organization_obj Organization business object updated as part of the 'Organization(s) Updated' Business Object event
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Updated Organization Business Objects
 * @rep:doccd 120hztig.pdf Get Updated Business Object Procedures, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_organization_updated(
    p_event_id            IN            NUMBER,
    p_organization_id     IN           NUMBER,
    x_organization_obj    OUT NOCOPY   HZ_ORGANIZATION_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );

/*#
 * Get Identifiers for Created Organization Business Objects (get_ids_organizations_created)
 * Retrieves identification values for the Organization business objects created in the Organization(s) Created Business
 * Object Event. You pass an event identifier to the procedure (event_id), and the procedure returns an array of object
 * identifier (organization_id) values that designate all of the Organization business objects that were created as part
 * of this event.
 *
 * @param p_init_msg_list Initiailize FND message stack.
 * @param p_event_id TCA Business Object Event identifier for the 'Organization(s) Created' event
 * @param x_organization_ids TCA identifiers for the created Organization business objects
 * @param x_return_status Return status after the call
 * @param x_msg_count Number of messages in message stack.
 * @param x_msg_data Messages returned from the operation
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Identifiers for Created Organization Business Objects
 * @rep:doccd 120hztig.pdf Get Business Object API Procedures, Oracle Trading Community Architecture Technical Implementation Guide
 */
-- get TCA identifiers for create event
PROCEDURE get_ids_organizations_created (
	p_init_msg_list		IN	VARCHAR2 := fnd_api.g_false,
	p_event_id		IN	NUMBER,
	x_organization_ids		OUT NOCOPY	HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL,
  	x_return_status       OUT NOCOPY    VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2

);

-- get TCA identifiers for update event
/*#
 * Get Identifiers for Updated Organization Business Objects (get_ids_organizations_updated)
 * Retrieves identification values for the Organization business objects updated in the "Organization(s) Updated" Business
 * Object Event. You pass an event identifier to the procedure (event_id), and the procedure returns an array of object
 * identifier (organization_id) values that designate all of the Organization business objects that were updated as part
 * of this event.
 *
 * @param p_init_msg_list Initiailize FND message stack.
 * @param p_event_id TCA Business Object Event identifier for the 'Organization(s) Updated' event.
 * @param x_organization_ids TCA identifiers for the updated Organization business objects
 * @param x_return_status Return status after the call
 * @param x_msg_count Number of messages in message stack.
 * @param x_msg_data Messages returned from the operation
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Identifiers for Updated Organization Business Objects
 * @rep:doccd 120hztig.pdf Get Updated Business Object Procedures, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_ids_organizations_updated (
	p_init_msg_list		IN	VARCHAR2 := fnd_api.g_false,
	p_event_id		IN	NUMBER,
	x_organization_ids		OUT NOCOPY	HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL,
  	x_return_status       OUT NOCOPY    VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
);

  PROCEDURE do_create_organization_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_organization_obj    IN OUT NOCOPY HZ_ORGANIZATION_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_organization_id     OUT NOCOPY    NUMBER,
    x_organization_os     OUT NOCOPY    VARCHAR2,
    x_organization_osr    OUT NOCOPY    VARCHAR2
  );

  PROCEDURE do_update_organization_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_organization_obj    IN OUT NOCOPY HZ_ORGANIZATION_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_organization_id     OUT NOCOPY    NUMBER,
    x_organization_os     OUT NOCOPY    VARCHAR2,
    x_organization_osr    OUT NOCOPY    VARCHAR2
  );

  PROCEDURE do_save_organization_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_organization_obj    IN OUT NOCOPY HZ_ORGANIZATION_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_organization_id     OUT NOCOPY    NUMBER,
    x_organization_os     OUT NOCOPY    VARCHAR2,
    x_organization_osr    OUT NOCOPY    VARCHAR2
  );

END HZ_ORGANIZATION_BO_PUB;

 

/

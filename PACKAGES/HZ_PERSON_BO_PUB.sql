--------------------------------------------------------
--  DDL for Package HZ_PERSON_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PERSON_BO_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHBPPBS.pls 120.7 2006/09/21 22:01:27 awu noship $ */
/*#
 * Person Business Object API
 * Public API that allows users to manage Person business objects in the Trading Community Architecture.
 * Several operations are supported, including the creation and update of the business object.
 *
 * @rep:scope public
 * @rep:product HZ
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY HZ_PERSON
 * @rep:displayname Person Business Object API
 * @rep:doccd 120hztig.pdf Person Business Object API, Oracle Trading Community Architecture Technical Implementation Guide
 */

  -- PROCEDURE create_person_bo
  --
  -- DESCRIPTION
  --     Create a person business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_person_obj         Person business object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_person_id          Person ID.
  --     x_person_os          Person orig system.
  --     x_person_osr         Person orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE create_person_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_obj          IN            HZ_PERSON_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER,
    x_person_os           OUT NOCOPY    VARCHAR2,
    x_person_osr          OUT NOCOPY    VARCHAR2
  );
/*#
 * Create Person Business Object (create_person_bo)
 * Creates a Person business object. You pass object data to the procedure, packaged within an object type defined
 * specifically for the API. The object type is HZ_PERSON_BO for the Person business object. In addition to
 * the object's business object attributes, the object type also includes lower-level embedded child entities or objects
 * that can be simultaneously created.
 *
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_person_obj The Person business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the creation of the business object
 * @param x_return_obj The Person business object that was created, returned as an output parameter
 * @param x_person_id TCA identifier for the Person business object
 * @param x_person_os Person original system name
 * @param x_person_osr Person original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Person Business Object
 * @rep:doccd 120hztig.pdf Create Person Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */

  PROCEDURE create_person_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_obj          IN            HZ_PERSON_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := NULL,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PERSON_BO,
    x_person_id           OUT NOCOPY    NUMBER,
    x_person_os           OUT NOCOPY    VARCHAR2,
    x_person_osr          OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE update_person_bo
  --
  -- DESCRIPTION
  --     Update a person business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_person_obj         Person business object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_person_id          Person ID.
  --     x_person_os          Person orig system.
  --     x_person_osr         Person orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --


  PROCEDURE update_person_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_person_obj          IN            HZ_PERSON_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER,
    x_person_os           OUT NOCOPY    VARCHAR2,
    x_person_osr          OUT NOCOPY    VARCHAR2
  );

/*#
 * Update Person Business Object (update_person_bo)
 * Updates a Person business object. You pass any modified object data to the procedure, packaged within an object
 * type defined specifically for the API. The object type is HZ_PERSON_BO for the Person business object.
 * In addition to the object's business object attributes, the object type also includes embedded child business entities
 * or objects that can be simultaneously created or updated.
 *
 * @param p_person_obj The Person business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the update of the business object
 * @param x_return_obj The Person business object that was updated, returned as an output parameter
 * @param x_person_id TCA identifier for the Person business object
 * @param x_person_os Person original system name
 * @param x_person_osr Person original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Person Business Object
 * @rep:doccd 120hztig.pdf Update Person Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */

  PROCEDURE update_person_bo(
    p_person_obj          IN            HZ_PERSON_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := NULL,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PERSON_BO,
    x_person_id           OUT NOCOPY    NUMBER,
    x_person_os           OUT NOCOPY    VARCHAR2,
    x_person_osr          OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_person_bo
  --
  -- DESCRIPTION
  --     Create or update a person business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_person_obj         Person business object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_person_id          Person ID.
  --     x_person_os          Person orig system.
  --     x_person_osr         Person orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE save_person_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_obj          IN            HZ_PERSON_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER,
    x_person_os           OUT NOCOPY    VARCHAR2,
    x_person_osr          OUT NOCOPY    VARCHAR2
  );

/*#
 * Save Person Business Object (save_person_bo)
 * Saves a Person business object. You pass new or modified object data to the procedure, packaged within an object
 * type defined specifically for the API. The API then determines if the object exists in TCA, based upon the provided
 * identification information, and creates or updates the object. The object type is HZ_PERSON_BO for the Person
 * business object. For either case, the object type that you provide will be processed as if the respective API procedure
 * is being called (create_person_bo or update_person_bo). Please see those procedures for more details.
 * In addition to the object's business object attributes, the object type also includes embedded child business entities
 * or objects that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_person_obj The Person business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Person business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_person_id TCA identifier for the Person business object
 * @param x_person_os Person original system name
 * @param x_person_osr Person original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save Person Business Object
 * @rep:doccd 120hztig.pdf Save Person Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */


  PROCEDURE save_person_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_obj          IN            HZ_PERSON_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := NULL,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PERSON_BO,
    x_person_id           OUT NOCOPY    NUMBER,
    x_person_os           OUT NOCOPY    VARCHAR2,
    x_person_osr          OUT NOCOPY    VARCHAR2
  );

  --------------------------------------
  --
  -- PROCEDURE get_person_bo
  --
  -- DESCRIPTION
  --     Get a logical person.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to  FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_person_id          Person ID.
  --     p_person_os          Person orig system.
  --     p_person_osr         Person orig system reference.
  --   OUT:
  --     x_person_obj         Logical person record.
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
The Get Person API Procedure is a retrieval service that returns a full Person business object.
The user identifies a particular Person business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full Person business object is returned. The object consists of all data included within
the Person business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the Person business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments
Party Site		N	Y		get_party_site_bo
Phone			N	Y		get_phone_bo
Email			N	Y		get_email_bo
Web			N	Y		get_web_bo
SMS			N	Y		get_sms_bo
Employment History	N	Y	Business Structure. Included entities:HZ_EMPLOYMENT_HISTORY, HZ_WORK_CLASS


To retrieve the appropriate embedded entities within the Person business object,
the Get procedure returns all records for the particular person from these TCA entity tables:

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Party,Person Profile	Y		N	HZ_PARTIES, HZ_PERSON_PROFILES
Person Preference	N		Y	HZ_PARTY_PREFERENCES
Relationship		N		Y	HZ_RELATIONSHIPS
Classification		N		Y	HZ_CODE_ASSIGNMENTS
Language		N		Y	HZ_PERSON_LANGUAGE
Education		N		Y	HZ_EDUCATION
Citizenship		N		Y	HZ_CITIZENSHIP
Interest		N		Y	HZ_PERSON_INTEREST
Certification		N		Y	HZ_CERTIFICATIONS
Financial Profile	N		Y	HZ_FINANCIAL_PROFILE
*/

PROCEDURE get_person_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_person_id		IN	NUMBER,
	p_person_os		IN	VARCHAR2,
	p_person_osr		IN	VARCHAR2,
	x_person_obj	  	OUT NOCOPY	HZ_PERSON_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
);

/*#
 * Get Person Business Object (get_person_bo)
 * Extracts a particular Person business object from TCA. You pass the object's identification information to the
 * procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_person_id TCA identifier for the Person business object
 * @param p_person_os Person original system name
 * @param p_person_osr Person original system reference
 * @param x_person_obj The retrieved Person business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Person Business Object
 * @rep:doccd 120hztig.pdf Get Person Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */


PROCEDURE get_person_bo (
        p_person_id             IN      NUMBER,
        p_person_os             IN      VARCHAR2,
        p_person_osr            IN      VARCHAR2,
        x_person_obj            OUT NOCOPY      HZ_PERSON_BO,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_messages              OUT NOCOPY      HZ_MESSAGE_OBJ_TBL
);

 --------------------------------------
  --
  -- PROCEDURE get_persons_created
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Persons created business event and
  --the procedure returns database objects of the type HZ_PERSON_BO for all of
  --the Person business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_obj        One or more created logical person.
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
The Get Persons Created procedure is a service to retrieve all of the Person business objects
whose creations have been captured by a logical business event. Each Persons Created
business event signifies that one or more Person business objects have been created.
The caller provides an identifier for the Persons Created business event and the procedure
returns all of the Person business objects from the business event. For each business object
creation captured in the business event, the procedure calls the generic Get operation:
HZ_PERSON_BO_PVT.get_person_bo

Gathering all of the returned business objects from those API calls, the procedure packages
them in a table structure and returns them to the caller.
*/


PROCEDURE get_persons_created(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_objs         OUT NOCOPY    HZ_PERSON_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );


/*#
 * Get Created Person Business Objects (get_persons_created)
 * Extracts the Person business objects from TCA based upon an event identifier (event_id) for a Person(s)
 * Created Business Object Event. You provide the event_id value to the procedure, and the procedure returns the set of
 * Person business objects that were updated as part of the event. The event identifer value must be valid for a
 * Person(s) Created Business Object Event.
 *
 * @param p_event_id TCA Business Object Event identifier for the 'Person(s) Created' event
 * @param x_person_objs Person business objects created as part of the 'Person(s) Created' Business Object event
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business objects
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Created Person Business Objects
 * @rep:doccd 120hztig.pdf Get Business Object API Procedures, Oracle Trading Community Architecture Technical Implementation Guide
 */

PROCEDURE get_persons_created(
    p_event_id            IN            NUMBER,
    x_person_objs         OUT NOCOPY    HZ_PERSON_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );

--------------------------------------
  --
  -- PROCEDURE get_persons_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Persons update business event and
  --the procedure returns database objects of the type HZ_PERSON_BO for all of
  --the Person business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_objs        One or more created logical person.
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
The Get Persons Updated procedure is a service to retrieve all of the Person business objects whose updates have been captured
by the logical business event. Each Persons Updated business event signifies that one or more Person business objects have been
updated.
The caller provides an identifier for the Persons Update business event and the procedure returns database objects of the type
HZ_PERSON_BO for all of the Person business objects from the business event.
Gathering all of the returned database objects from those API calls, the procedure packages them in a table structure and returns
them to the caller.
*/

 PROCEDURE get_persons_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_objs         OUT NOCOPY    HZ_PERSON_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Get Updated Person Business Objects (get_persons_updated)
 * Extracts the Person business objects from TCA based upon an event identifier (event_id) for a Person(s)
 * Updated Business Object Event. You provide the event_id value to the procedure, and the procedure returns the set of
 * Person business objects that were updated as part of the event. The event identifer value must be valid for a
 * Person(s) Updated Business Object Event.
 *
 * Provided within the returned business objects are Action Flags that designate how the data, at a particular level of
 * an object, has changed as a result of the update to the Person business object. Each business object, structure,
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
 * @param p_event_id TCA Business Object Event identifier for the 'Person(s) Updated' event
 * @param x_person_objs Person business objects updated as part of the 'Person(s) Updated' Business Object event
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business objects
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Updated Person Business Objects
 * @rep:doccd 120hztig.pdf Get Updated Business Object Procedures, Oracle Trading Community Architecture Technical Implementation Guide
 */

 PROCEDURE get_persons_updated(
    p_event_id            IN            NUMBER,
    x_person_objs         OUT NOCOPY    HZ_PERSON_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );

--------------------------------------
  --
  -- PROCEDURE get_person_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Persons update business event and person_id
  --the procedure returns one database object of the type HZ_PERSON_BO

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --     p_person_id          Person identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_objs        One or more created logical person.
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



-- Get only one person object based on p_person_id and event_id

PROCEDURE get_person_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    p_person_id           IN           NUMBER,
    x_person_obj          OUT NOCOPY    HZ_PERSON_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Get Updated Person Business Object (get_person_updated)
 * Extracts an updated Person business object from TCA based upon the object identifier (person_id) and event
 * identifier (event_id). You provide values for the two identifiers to the procedure, and the procedure returns the
 * identified business object. The event identifier value must be valid for a Person(s) Updated Business Object Event.
 *
 * Provided within the returned business object are Action Flags that designate how the data, at a particular level of the
 * object, has changed as a result of the update to the Person business object. Each business object, structure, and
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
 * @param p_event_id TCA Business Object Event identifier for the 'Person(s) Updated' event
 * @param p_person_id TCA identifier for the updated Person business object
 * @param x_person_obj Person business object updated as part of the 'Person(s) Updated' Business Object event
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Updated Person Business Objects
 * @rep:doccd 120hztig.pdf Get Updated Business Object Procedures, Oracle Trading Community Architecture Technical Implementation Guide
 */

PROCEDURE get_person_updated(
    p_event_id            IN            NUMBER,
    p_person_id           IN           NUMBER,
    x_person_obj          OUT NOCOPY    HZ_PERSON_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );

/*#
 * Get Identifiers for Created Person Business Objects (get_ids_persons_created)
 * Retrieves identification values for the Person business objects created in the Person(s) Created Business
 * Object Event. You pass an event identifier to the procedure (event_id), and the procedure returns an array of object
 * identifier (person_id) values that designate all of the Person business objects that were created as part
 * of this event.
 *
 * @param p_init_msg_list Initiailize FND message stack.
 * @param p_event_id TCA Business Object Event identifier for the 'Person(s) Created' event
 * @param x_person_ids TCA identifiers for the created Person business objects
 * @param x_return_status Return status after the call
 * @param x_msg_count Number of messages in message stack.
 * @param x_msg_data Messages returned from the operation
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Identifiers for Created Person Business Objects
 * @rep:doccd 120hztig.pdf Get Business Object API Procedures, Oracle Trading Community Architecture Technical Implementation Guide
 */

-- get TCA identifiers for create event
PROCEDURE get_ids_persons_created (
	p_init_msg_list		IN	VARCHAR2 := fnd_api.g_false,
	p_event_id		IN	NUMBER,
	x_person_ids		OUT NOCOPY	HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL,
  	x_return_status       OUT NOCOPY    VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2

);

/*#
 * Get Identifiers for Updated Person Business Objects (get_ids_persons_updated)
 * Retrieves identification values for the Person business objects updated in the "Person(s) Updated" Business
 * Object Event. You pass an event identifier to the procedure (event_id), and the procedure returns an array of object
 * identifier (person_id) values that designate all of the Person business objects that were updated as part
 * of this event.
 *
 * @param p_init_msg_list Initiailize FND message stack.
 * @param p_event_id TCA Business Object Event identifier for the 'Person(s) Updated' event.
 * @param x_person_ids TCA identifiers for the updated Person business objects
 * @param x_return_status Return status after the call
 * @param x_msg_count Number of messages in message stack.
 * @param x_msg_data Messages returned from the operation
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Identifiers for Updated Person Business Objects
 * @rep:doccd 120hztig.pdf Get Updated Business Object Procedures, Oracle Trading Community Architecture Technical Implementation Guide
 */

-- get TCA identifiers for update event
PROCEDURE get_ids_persons_updated (
	p_init_msg_list		IN	VARCHAR2 := fnd_api.g_false,
	p_event_id		IN	NUMBER,
	x_person_ids		OUT NOCOPY	HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL,
  	x_return_status       OUT NOCOPY    VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
);

  PROCEDURE do_create_person_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_obj          IN OUT NOCOPY HZ_PERSON_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER,
    x_person_os           OUT NOCOPY    VARCHAR2,
    x_person_osr          OUT NOCOPY    VARCHAR2
  );

  PROCEDURE do_update_person_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_person_obj          IN OUT NOCOPY HZ_PERSON_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := NULL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER,
    x_person_os           OUT NOCOPY    VARCHAR2,
    x_person_osr          OUT NOCOPY    VARCHAR2
  );

  PROCEDURE do_save_person_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_obj          IN OUT NOCOPY HZ_PERSON_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER,
    x_person_os           OUT NOCOPY    VARCHAR2,
    x_person_osr          OUT NOCOPY    VARCHAR2
  );

END HZ_PERSON_BO_PUB;

 

/

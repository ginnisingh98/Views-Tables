--------------------------------------------------------
--  DDL for Package HZ_PARTY_SITE_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_SITE_BO_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHBPSBS.pls 120.10 2006/09/22 00:43:05 acng noship $ */
/*#
 * Party Site Business Object API
 * Public API that allows users to manage Party Site business objects in the Trading Community Architecture.
 * Several operations are supported, including the creation and update of the business object.
 *
 * @rep:scope public
 * @rep:product HZ
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY HZ_ADDRESS
 * @rep:displayname Party Site Business Object API
 * @rep:doccd 120hztig.pdf Party Site Business Object API, Oracle Trading Community Architecture Technical Implementation Guide
 */

  -- PROCEDURE create_party_site_bo
  --
  -- DESCRIPTION
  --     Create a party site business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_party_site_obj     Party site business object.
  --     p_created_by_module  Created by module.
  --   IN/OUT:
  --     px_parent_id         Parent record ID.
  --     px_parent_os         Parent orig system.
  --     px_parent_osr        Parent orig system reference.
  --     px_parent_obj_type   Parent object type.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_party_site_id      Party Site ID.
  --     x_party_site_os      Party Site orig system.
  --     x_party_site_osr     Party Site orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE create_party_site_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_party_site_obj      IN            HZ_PARTY_SITE_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_party_site_id       OUT NOCOPY    NUMBER,
    x_party_site_os       OUT NOCOPY    VARCHAR2,
    x_party_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

/*#
 * Create Party Site Business Object (create_party_site_bo)
 * Creates a Party Site business object. You pass object data to the procedure, packaged within an object type
 * defined specifically for the API. The object type is HZ_PARTY_SITE_BO for the Party Site business object.
 * In addition to the object's business object attributes, the object type also includes lower-level embedded
 * child entities or objects that can be simultaneously created.
 *
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_party_site_obj The Party Site business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Party Site business object that was created, returned as an output parameter
 * @param x_messages Messages returned from the creation of the business object
 * @param x_party_site_id TCA identifier for the Party Site business object
 * @param x_party_site_os Party Site original system name
 * @param x_party_site_osr Party Site original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter or both the px_parent_os and px_parent_osr parameters must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Party Site Business Object
 * @rep:doccd 120hztig.pdf Create Party Site Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE create_party_site_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_party_site_obj      IN            HZ_PARTY_SITE_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PARTY_SITE_BO,
    x_party_site_id       OUT NOCOPY    NUMBER,
    x_party_site_os       OUT NOCOPY    VARCHAR2,
    x_party_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE update_party_site_bo
  --
  -- DESCRIPTION
  --     Update a party site business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_party_site_obj     Party site business object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_party_site_id      Party Site ID.
  --     x_party_site_os      Party Site orig system.
  --     x_party_site_osr     Party Site orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE update_party_site_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_party_site_obj      IN            HZ_PARTY_SITE_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_party_site_id       OUT NOCOPY    NUMBER,
    x_party_site_os       OUT NOCOPY    VARCHAR2,
    x_party_site_osr      OUT NOCOPY    VARCHAR2
  );

/*#
 * Update Party Site Business Object (update_party_site_bo)
 * Updates a Party Site business object. You pass any modified object data to the procedure, packaged within an
 * object type defined specifically for the API. The object type is HZ_PARTY_SITE_BO for the Party Site business object.
 * In addition to the object's business object attributes, the object type also includes embedded child business entities
 * or objects that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param p_party_site_obj The Party Site business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Party Site business object that was updated, returned as an output parameter
 * @param x_messages Messages returned from the update of the business object
 * @param x_party_site_id TCA identifier for the Party Site business object
 * @param x_party_site_os Party Site original system name
 * @param x_party_site_osr Party Site original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Party Site Business Object
 * @rep:doccd 120hztig.pdf Update Party Site Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE update_party_site_bo(
    p_party_site_obj      IN            HZ_PARTY_SITE_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PARTY_SITE_BO,
    x_party_site_id       OUT NOCOPY    NUMBER,
    x_party_site_os       OUT NOCOPY    VARCHAR2,
    x_party_site_osr      OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_party_site_bo
  --
  -- DESCRIPTION
  --     Create or update a party site business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_party_site_obj     Party site business object.
  --     p_created_by_module  Created by module.
  --   IN/OUT:
  --     px_parent_id         Parent record ID.
  --     px_parent_os         Parent orig system.
  --     px_parent_osr        Parent orig system reference.
  --     px_parent_obj_type   Parent object type.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_party_site_id      Party Site ID.
  --     x_party_site_os      Party Site orig system.
  --     x_party_site_osr     Party Site orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE save_party_site_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_party_site_obj      IN            HZ_PARTY_SITE_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_party_site_id       OUT NOCOPY    NUMBER,
    x_party_site_os       OUT NOCOPY    VARCHAR2,
    x_party_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

/*#
 * Save Party Site Business Object (save_party_site_bo)
 * Saves a Party Site business object. You pass new or modified object data to the procedure, packaged within an
 * object type defined specifically for the API. The API then determines if the object exists in TCA, based upon
 * the provided identification information, and creates or updates the object. The object type is HZ_PARTY_SITE_BO
 * for the Party Site business object. For either case, the object type that you provide will be processed as if
 * the respective API procedure is being called (create_party_site_bo or update_party_site_bo). Please see those
 * procedures for more details. In addition to the object's business object attributes, the object type also includes
 * embedded child business entities or objects that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_party_site_obj The Party Site business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Party Site business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_party_site_id TCA identifier for the Party Site business object
 * @param x_party_site_os Party Site original system name
 * @param x_party_site_osr Party Site original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter, or both the px_parent_os and px_parent_osr parameters, must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save Party Site Business Object
 * @rep:doccd 120hztig.pdf Save Party Site Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE save_party_site_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_party_site_obj      IN            HZ_PARTY_SITE_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PARTY_SITE_BO,
    x_party_site_id       OUT NOCOPY    NUMBER,
    x_party_site_os       OUT NOCOPY    VARCHAR2,
    x_party_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

 --------------------------------------
  --
  -- PROCEDURE get_party_site_bo
  --
  -- DESCRIPTION
  --     Get a logical party site.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to  FND_API.G_TRUE. Default is FND_API.G_FALSE.
 --       p_party_id          party ID.
 --       p_party_site_id     party site ID. If this id is not passed in, multiple site objects will be returned.
  --     p_party_site_os          party site orig system.
  --     p_party_site_osr         party site orig system reference.
  --
  --   OUT:
  --     x_party_site_objs         Logical party site records.
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
  --   1-JUNE-2005   AWU                Created.
  --

/*
The Get party site API Procedure is a retrieval service that returns a full party site business object.
The user identifies a particular party site business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full party site business object is returned. The object consists of all data included within
the party site business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the party site business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments
Phone			N	Y		get_phone_bos
Telex			N	Y		get_telex_bos
Email			N	Y		get_email_bos
Web			N	Y		get_web_bos

To retrieve the appropriate embedded entities within the party site business object,
the Get procedure returns all records for the particular party site from these TCA entity tables:

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Location		Y		N	HZ_LOCATIONS
Party Site		Y		N	HZ_PARTY_SITES
Party Site Use		N		Y	HZ_PARTY_SITE_USES
Contact Preference	N		Y	HZ_CONTACT_PREFERENCES
*/


PROCEDURE get_party_site_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_party_site_id		IN	NUMBER,
	p_party_site_os		IN	VARCHAR2,
	p_party_site_osr	IN	VARCHAR2,
	x_party_site_obj  	OUT NOCOPY	HZ_PARTY_SITE_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
);

/*#
 * Get Party Site Business Object (get_party_site_bo)
 * Extracts a particular Party Site business object from TCA. You pass the object's identification information to the
 * procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_party_site_id TCA identifier for the Party Site business object
 * @param p_party_site_os Party Site original system name
 * @param p_party_site_osr Party Site original system reference
 * @param x_party_site_obj The retrieved Party Site business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Party Site Business Object
 * @rep:doccd 120hztig.pdf Get Party Site Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_party_site_bo (
        p_party_site_id         IN      NUMBER,
        p_party_site_os         IN      VARCHAR2,
        p_party_site_osr        IN      VARCHAR2,
        x_party_site_obj        OUT NOCOPY      HZ_PARTY_SITE_BO,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_messages              OUT NOCOPY      HZ_MESSAGE_OBJ_TBL
);

  PROCEDURE do_create_party_site_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_party_site_obj      IN OUT NOCOPY HZ_PARTY_SITE_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_party_site_id       OUT NOCOPY    NUMBER,
    x_party_site_os       OUT NOCOPY    VARCHAR2,
    x_party_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

  -- PRIVATE PROCEDURE do_update_party_site_bo
  PROCEDURE do_update_party_site_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_party_site_obj      IN OUT NOCOPY HZ_PARTY_SITE_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_party_site_id       OUT NOCOPY    NUMBER,
    x_party_site_os       OUT NOCOPY    VARCHAR2,
    x_party_site_osr      OUT NOCOPY    VARCHAR2,
    p_parent_os           IN            VARCHAR2
  );

  -- PRIVATE PROCEDURE do_save_party_site_bo
  PROCEDURE do_save_party_site_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_party_site_obj      IN OUT NOCOPY HZ_PARTY_SITE_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_party_site_id       OUT NOCOPY    NUMBER,
    x_party_site_os       OUT NOCOPY    VARCHAR2,
    x_party_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

END HZ_PARTY_SITE_BO_PUB;

 

/
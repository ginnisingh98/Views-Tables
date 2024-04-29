--------------------------------------------------------
--  DDL for Package HZ_ORG_CONTACT_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ORG_CONTACT_BO_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHBOCBS.pls 120.10 2006/09/22 00:40:57 acng noship $ */
/*#
 * Organization Contact Business Object API
 * Public API that allows users to manage Organization Contact business objects in the Trading Community Architecture.
 * Several operations are supported, including the creation and update of the business object.
 *
 * @rep:scope public
 * @rep:product HZ
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY HZ_CONTACT
 * @rep:displayname Organization Contact Business Object API
 * @rep:doccd 120hztig.pdf Organization Contact Business Object API, Oracle Trading Community Architecture Technical Implementation Guide
 */

  -- PROCEDURE create_org_contact_bo
  --
  -- DESCRIPTION
  --     Creates org contact business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_org_contact_obj    Logical org contact object.
  --     p_created_by_module  Created by module.
  --   IN OUT:
  --     px_parent_org_id     Parent organization id
  --     px_parent_org_os     Parent organization os
  --     px_parent_org_osr    Parent organization osr
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_org_contact_id     Org Contact ID.
  --     x_org_contact_os     Org Contact orig system.
  --     x_org_contact_osr    Org Contact orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE create_org_contact_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_org_contact_obj     IN            HZ_ORG_CONTACT_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_org_contact_id      OUT NOCOPY    NUMBER,
    x_org_contact_os      OUT NOCOPY    VARCHAR2,
    x_org_contact_osr     OUT NOCOPY    VARCHAR2,
    px_parent_org_id      IN OUT NOCOPY NUMBER,
    px_parent_org_os      IN OUT NOCOPY VARCHAR2,
    px_parent_org_osr     IN OUT NOCOPY VARCHAR2
  );

/*#
 * Create Organization Contact Business Object (create_org_contact_bo)
 * Creates a Organization Contact business object. You pass object data to the procedure, packaged within an
 * object type defined specifically for the API. The object type is HZ_ORG_CONTACT_BO for the Organization Contact
 * business object. In addition to the object's business object attributes, the object type also includes lower-level
 * embedded child entities or objects that can be simultaneously created.
 *
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_org_contact_obj The Organization Contact business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Organization Contact business object that was created, returned as an output parameter
 * @param x_messages Messages returned from the creation of the business object
 * @param x_org_contact_id TCA identifier for the Organization Contact business object
 * @param x_org_contact_os Organization Contact original system name
 * @param x_org_contact_osr Organization Contact original system reference
 * @param px_parent_org_id TCA identifier for parent object. Either this parameter or both the px_parent_os and px_parent_osr parameters must be given
 * @param px_parent_org_os Parent object original system name
 * @param px_parent_org_osr Parent object original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Organization Contact Business Object
 * @rep:doccd 120hztig.pdf Create Organization Contact Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE create_org_contact_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_org_contact_obj     IN            HZ_ORG_CONTACT_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_ORG_CONTACT_BO,
    x_org_contact_id      OUT NOCOPY    NUMBER,
    x_org_contact_os      OUT NOCOPY    VARCHAR2,
    x_org_contact_osr     OUT NOCOPY    VARCHAR2,
    px_parent_org_id      IN OUT NOCOPY NUMBER,
    px_parent_org_os      IN OUT NOCOPY VARCHAR2,
    px_parent_org_osr     IN OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE update_org_contact_bo
  --
  -- DESCRIPTION
  --     Update org contact business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_org_contact_obj    Logical org contact object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_org_contact_id     Org Contact ID.
  --     x_org_contact_os     Org Contact orig system.
  --     x_org_contact_osr    Org Contact orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE update_org_contact_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_org_contact_obj     IN            HZ_ORG_CONTACT_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_org_contact_id      OUT NOCOPY    NUMBER,
    x_org_contact_os      OUT NOCOPY    VARCHAR2,
    x_org_contact_osr     OUT NOCOPY    VARCHAR2
  );

/*#
 * Update Organization Contact Business Object (update_org_contact_bo)
 * Updates a Organization Contact business object. You pass any modified object data to the procedure, packaged
 * within an object type defined specifically for the API. The object type is HZ_ORG_CONTACT_BO for the
 * Organization Contact business object. In addition to the object's business object attributes, the object type
 * also includes embedded child business entities or objects that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param p_org_contact_obj The Organization Contact business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Organization Contact business object that was updated, returned as an output parameter
 * @param x_messages Messages returned from the update of the business object
 * @param x_org_contact_id TCA identifier for the Organization Contact business object
 * @param x_org_contact_os Organization Contact original system name
 * @param x_org_contact_osr Organization Contact original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Organization Contact Business Object
 * @rep:doccd 120hztig.pdf Update Organization Contact Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE update_org_contact_bo(
    p_org_contact_obj     IN            HZ_ORG_CONTACT_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_ORG_CONTACT_BO,
    x_org_contact_id      OUT NOCOPY    NUMBER,
    x_org_contact_os      OUT NOCOPY    VARCHAR2,
    x_org_contact_osr     OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_org_contact_bo
  --
  -- DESCRIPTION
  --     Creates or update org contact business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_org_contact_obj    Logical org contact object.
  --     p_created_by_module  Created by module.
  --   IN OUT:
  --     px_parent_org_id     Parent organization id
  --     px_parent_org_os     Parent organization os
  --     px_parent_org_osr    Parent organization osr
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_org_contact_id     Org Contact ID.
  --     x_org_contact_os     Org Contact orig system.
  --     x_org_contact_osr    Org Contact orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_org_contact_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_org_contact_obj     IN            HZ_ORG_CONTACT_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_org_contact_id      OUT NOCOPY    NUMBER,
    x_org_contact_os      OUT NOCOPY    VARCHAR2,
    x_org_contact_osr     OUT NOCOPY    VARCHAR2,
    px_parent_org_id      IN OUT NOCOPY NUMBER,
    px_parent_org_os      IN OUT NOCOPY VARCHAR2,
    px_parent_org_osr     IN OUT NOCOPY VARCHAR2
  );

/*#
 * Save Organization Contact Business Object (save_org_contact_bo)
 * Saves a Organization Contact business object. You pass new or modified object data to the procedure, packaged
 * within an object type defined specifically for the API. The API then determines if the object exists in TCA,
 * based upon the provided identification information, and creates or updates the object. The object type is
 * HZ_ORG_CONTACT_BO for the Organization Contact business object. For either case, the object type that you provide
 * will be processed as if the respective API procedure is being called (create_org_contact_bo or update_org_contact_bo).
 * Please see those procedures for more details. In addition to the object's business object attributes, the object
 * type also includes embedded child business entities or objects that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_org_contact_obj The Organization Contact business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Organization Contact business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_org_contact_id TCA identifier for the Organization Contact business object
 * @param x_org_contact_os Organization Contact original system name
 * @param x_org_contact_osr Organization Contact original system reference
 * @param px_parent_org_id TCA identifier for parent object. Either this parameter, or both the px_parent_os and px_parent_osr parameters, must be given
 * @param px_parent_org_os Parent object original system name
 * @param px_parent_org_osr Parent object original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save Organization Contact Business Object
 * @rep:doccd 120hztig.pdf Save Organization Contact Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE save_org_contact_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_org_contact_obj     IN            HZ_ORG_CONTACT_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_ORG_CONTACT_BO,
    x_org_contact_id      OUT NOCOPY    NUMBER,
    x_org_contact_os      OUT NOCOPY    VARCHAR2,
    x_org_contact_osr     OUT NOCOPY    VARCHAR2,
    px_parent_org_id      IN OUT NOCOPY NUMBER,
    px_parent_org_os      IN OUT NOCOPY VARCHAR2,
    px_parent_org_osr     IN OUT NOCOPY VARCHAR2
  );

 --------------------------------------
  --
  -- PROCEDURE get_org_contact_bo
  --
  -- DESCRIPTION
  --     Get org contact information.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --       p_org_contact_id       Org Contact id.
 --     p_org_contact_os           Org contact orig system.
  --     p_org_contact_osr         Org contact orig system reference.
  --
  --   OUT:
  --     x_org contact_objs  Table of org contact objects.
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
  --   15-June-2005   AWU                Created.
  --


 PROCEDURE get_org_contact_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_org_contact_id		IN	NUMBER,
    p_org_contact_os		IN	VARCHAR2,
    p_org_contact_osr		IN	VARCHAR2,
    x_org_contact_obj    OUT NOCOPY    HZ_ORG_CONTACT_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Get Organization Contact Business Object (get_org_contact_bo)
 * Extracts a particular Organization Contact business object from TCA. You pass the object's identification
 * information to the procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_org_contact_id TCA identifier for the Organization Contact business object
 * @param p_org_contact_os Organization Contact original system name
 * @param p_org_contact_osr Organization Contact original system reference
 * @param x_org_contact_obj The retrieved Organization Contact business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Organization Contact Business Object
 * @rep:doccd 120hztig.pdf Get Organization Contact Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
 PROCEDURE get_org_contact_bo(
    p_org_contact_id            IN      NUMBER,
    p_org_contact_os            IN      VARCHAR2,
    p_org_contact_osr           IN      VARCHAR2,
    x_org_contact_obj    OUT NOCOPY    HZ_ORG_CONTACT_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );

  PROCEDURE do_create_org_contact_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_org_contact_obj     IN OUT NOCOPY HZ_ORG_CONTACT_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_org_contact_id      OUT NOCOPY    NUMBER,
    x_org_contact_os      OUT NOCOPY    VARCHAR2,
    x_org_contact_osr     OUT NOCOPY    VARCHAR2,
    px_parent_org_id      IN OUT NOCOPY NUMBER,
    px_parent_org_os      IN OUT NOCOPY VARCHAR2,
    px_parent_org_osr     IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE do_update_org_contact_bo(
    p_init_msg_list       IN         VARCHAR2 := fnd_api.g_false,
    p_org_contact_obj     IN OUT NOCOPY HZ_ORG_CONTACT_BO,
    p_created_by_module   IN         VARCHAR2,
    p_obj_source          IN         VARCHAR2 := null,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    x_org_contact_id      OUT NOCOPY NUMBER,
    x_org_contact_os      OUT NOCOPY VARCHAR2,
    x_org_contact_osr     OUT NOCOPY VARCHAR2,
    p_parent_os           IN         VARCHAR2
  );

  PROCEDURE do_save_org_contact_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_org_contact_obj     IN OUT NOCOPY HZ_ORG_CONTACT_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_org_contact_id      OUT NOCOPY    NUMBER,
    x_org_contact_os      OUT NOCOPY    VARCHAR2,
    x_org_contact_osr     OUT NOCOPY    VARCHAR2,
    px_parent_org_id      IN OUT NOCOPY NUMBER,
    px_parent_org_os      IN OUT NOCOPY VARCHAR2,
    px_parent_org_osr     IN OUT NOCOPY VARCHAR2
  );

END HZ_ORG_CONTACT_BO_PUB;

 

/

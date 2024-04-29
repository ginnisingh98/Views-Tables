--------------------------------------------------------
--  DDL for Package HZ_CUST_ACCT_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CUST_ACCT_BO_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHBCABS.pls 120.8 2008/02/06 09:45:36 vsegu ship $ */
/*#
 * Customer Account Business Object API
 * Public API that allows users to manage Customer Account business objects in the Trading Community Architecture.
 * Several operations are supported, including the creation and update of the business object.
 *
 * @rep:scope public
 * @rep:product HZ
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY HZ_CUSTOMER_ACCOUNT
 * @rep:displayname Customer Account Business Object API
 * @rep:doccd 120hztig.pdf Customer Account Business Object API, Oracle Trading Community Architecture Technical Implementation Guide
 */

  -- PROCEDURE create_cust_acct_bo
  --
  -- DESCRIPTION
  --     Create customer account business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_cust_acct_obj_     Customer account object.
  --     p_created_by_module  Created by module.
  --   IN OUT:
  --     px_parent_acct_id    Parent id.
  --     px_parent_acct_os    Parent original system.
  --     px_parent_acct_osr   Parent original system reference.
  --     px_parent_obj_type   Parent object type.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_cust_acct_id       Customer Account ID.
  --     x_cust_acct_os       Customer Account orig system.
  --     x_cust_acct_osr      Customer Account orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE create_cust_acct_bo(
    p_init_msg_list        IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag     IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_obj        IN            HZ_CUST_ACCT_BO,
    p_created_by_module    IN            VARCHAR2,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_msg_count            OUT NOCOPY    NUMBER,
    x_msg_data             OUT NOCOPY    VARCHAR2,
    x_cust_acct_id         OUT NOCOPY    NUMBER,
    x_cust_acct_os         OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr        OUT NOCOPY    VARCHAR2,
    px_parent_id           IN OUT NOCOPY NUMBER,
    px_parent_os           IN OUT NOCOPY VARCHAR2,
    px_parent_osr          IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type     IN OUT NOCOPY VARCHAR2
  );

/*#
 * Create Customer Account Business Object (create_cust_acct_bo)
 * Creates a Customer Account business object. You pass object data to the procedure, packaged within an object type
 * defined specifically for the API. The object type is HZ_CUST_ACCT_BO for the Customer Account business object.
 * In addition to the object's business object attributes, the object type also includes lower-level embedded child
 * entities or objects that can be simultaneously created.
 *
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_cust_acct_obj The Customer Account business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Customer Account business object that was created, returned as an output parameter
 * @param x_messages Messages returned from the creation of the business object
 * @param x_cust_acct_id TCA identifier for the Customer Account business object
 * @param x_cust_acct_os Customer Account original system name
 * @param x_cust_acct_osr Customer Account original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter or both the px_parent_os and px_parent_osr parameters must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Customer Account Business Object
 * @rep:doccd 120hztig.pdf Create Customer Account Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE create_cust_acct_bo(
    p_validate_bo_flag     IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_obj        IN            HZ_CUST_ACCT_BO,
    p_created_by_module    IN            VARCHAR2,
    p_obj_source           IN            VARCHAR2 := null,
    p_return_obj_flag      IN            VARCHAR2 := fnd_api.g_true,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj           OUT NOCOPY    HZ_CUST_ACCT_BO,
    x_cust_acct_id         OUT NOCOPY    NUMBER,
    x_cust_acct_os         OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr        OUT NOCOPY    VARCHAR2,
    px_parent_id           IN OUT NOCOPY NUMBER,
    px_parent_os           IN OUT NOCOPY VARCHAR2,
    px_parent_osr          IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type     IN OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE update_cust_acct_bo
  --
  -- DESCRIPTION
  --     Update customer account business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_cust_acct_obj_     Customer account object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_cust_acct_id       Customer Account ID.
  --     x_cust_acct_os       Customer Account orig system.
  --     x_cust_acct_osr      Customer Account orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE update_cust_acct_bo(
    p_init_msg_list        IN            VARCHAR2 := fnd_api.g_false,
    p_cust_acct_obj        IN            HZ_CUST_ACCT_BO,
    p_created_by_module    IN            VARCHAR2,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_msg_count            OUT NOCOPY    NUMBER,
    x_msg_data             OUT NOCOPY    VARCHAR2,
    x_cust_acct_id         OUT NOCOPY    NUMBER,
    x_cust_acct_os         OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr        OUT NOCOPY    VARCHAR2
  );

/*#
 * Update Customer Account Business Object (update_cust_acct_bo)
 * Updates a Customer Account business object. You pass any modified object data to the procedure, packaged within an
 * object type defined specifically for the API. The object type is HZ_CUST_ACCT_BO for the Customer Account business
 * object. In addition to the object's business object attributes, the object type also includes embedded child business
 * entities or objects that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param p_cust_acct_obj The Customer Account business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Customer Account business object that was updated, returned as an output parameter
 * @param x_messages Messages returned from the update of the business object
 * @param x_cust_acct_id TCA identifier for the Customer Account business object
 * @param x_cust_acct_os Customer Account original system name
 * @param x_cust_acct_osr Customer Account original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Customer Account Business Object
 * @rep:doccd 120hztig.pdf Update Customer Account Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE update_cust_acct_bo(
    p_cust_acct_obj        IN            HZ_CUST_ACCT_BO,
    p_created_by_module    IN            VARCHAR2,
    p_obj_source           IN            VARCHAR2 := null,
    p_return_obj_flag      IN            VARCHAR2 := fnd_api.g_true,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj           OUT NOCOPY    HZ_CUST_ACCT_BO,
    x_cust_acct_id         OUT NOCOPY    NUMBER,
    x_cust_acct_os         OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr        OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_cust_acct_bo
  --
  -- DESCRIPTION
  --     Create or update customer account business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_cust_acct_obj_     Customer account object.
  --     p_created_by_module  Created by module.
  --   IN OUT:
  --     px_parent_acct_id    Parent id.
  --     px_parent_acct_os    Parent original system.
  --     px_parent_acct_osr   Parent original system reference.
  --     px_parent_obj_type   Parent object type.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_cust_acct_id       Customer Account ID.
  --     x_cust_acct_os       Customer Account orig system.
  --     x_cust_acct_osr      Customer Account orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_cust_acct_bo(
    p_init_msg_list        IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag     IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_obj        IN            HZ_CUST_ACCT_BO,
    p_created_by_module    IN            VARCHAR2,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_msg_count            OUT NOCOPY    NUMBER,
    x_msg_data             OUT NOCOPY    VARCHAR2,
    x_cust_acct_id         OUT NOCOPY    NUMBER,
    x_cust_acct_os         OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr        OUT NOCOPY    VARCHAR2,
    px_parent_id           IN OUT NOCOPY NUMBER,
    px_parent_os           IN OUT NOCOPY VARCHAR2,
    px_parent_osr          IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type     IN OUT NOCOPY VARCHAR2
  );

/*#
 * Save Customer Account Business Object (save_cust_acct_bo)
 * Saves a Customer Account business object. You pass new or modified object data to the procedure, packaged within
 * an object type defined specifically for the API. The API then determines if the object exists in TCA, based upon
 * the provided identification information, and creates or updates the object. The object type is HZ_CUST_ACCT_BO
 * for the Customer Account business object. For either case, the object type that you provide will be processed as if
 * the respective API procedure is being called (create_cust_acct_bo or update_cust_acct_bo). Please see those procedures
 * for more details. In addition to the object's business object attributes, the object type also includes embedded
 * child business entities or objects that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_cust_acct_obj The Customer Account business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Customer Account business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_cust_acct_id TCA identifier for the Customer Account business object
 * @param x_cust_acct_os Customer Account original system name
 * @param x_cust_acct_osr Customer Account original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter, or both the px_parent_os and px_parent_osr parameters, must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save Customer Account Business Object
 * @rep:doccd 120hztig.pdf Save Customer Account Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE save_cust_acct_bo(
    p_validate_bo_flag     IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_obj        IN            HZ_CUST_ACCT_BO,
    p_created_by_module    IN            VARCHAR2,
    p_obj_source           IN            VARCHAR2 := null,
    p_return_obj_flag      IN            VARCHAR2 := fnd_api.g_true,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj           OUT NOCOPY    HZ_CUST_ACCT_BO,
    x_cust_acct_id         OUT NOCOPY    NUMBER,
    x_cust_acct_os         OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr        OUT NOCOPY    VARCHAR2,
    px_parent_id           IN OUT NOCOPY NUMBER,
    px_parent_os           IN OUT NOCOPY VARCHAR2,
    px_parent_osr          IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type     IN OUT NOCOPY VARCHAR2
  );

 --------------------------------------
  --
  -- PROCEDURE get_cust_acct_bo
  --
  -- DESCRIPTION
  --     Get a logical customer account.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_cust_acct_id          customer account ID.
  --       p_parent_id	      Parent Id.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_cust_acct_obj         Logical customer account record.
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
  --   8-JUN-2005  AWU                Created.
  --

/*

The Get customer account API Procedure is a retrieval service that returns full customer account business objects.
The user identifies a particular Organization Contact business object using the TCA identifier and/or the object's
Source System information. Upon proper validation of the object, the full Organization Contact business object is returned.
The object consists of all data included within the Organization Contact business object, at all embedded levels.
This includes the set of all data stored in the TCA tables for each embedded entity.


Embedded BO	    	Mandatory	Multiple Logical API Procedure		Comments
Customer Account Site		N	Y	get_cust_acct_site_bo
Customer Account Contact	N	Y	get_cust_acct_contact_bo
Customer Profile		Y	N	Business Structure. Included entities:
                                                HZ_CUSTOMER_PROFILES, HZ_CUST_PROFILE_AMTS

To retrieve the appropriate embedded entities within the 'Organization Contact' business object, the Get procedure returns all records for the particular contact from these TCA entity tables.

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Customer Account	Y		N	HZ_CUST_ACCOUNTS
Account Relationship	N		Y	HZ_CUST_ACCT_RELATE
Bank Account Use	N		Y	Owned by Payments team
Payment Method		N		N	Owned by AR team

*/



 PROCEDURE get_cust_acct_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_cust_acct_id        IN            NUMBER,
    p_cust_acct_os		IN	VARCHAR2,
    p_cust_acct_osr		IN	VARCHAR2,
    x_cust_acct_obj          OUT NOCOPY    HZ_CUST_ACCT_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Get Customer Account Business Object (get_cust_acct_bo)
 * Extracts a particular Customer Account business object from TCA. You pass the object's identification information
 * to the procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_cust_acct_id TCA identifier for the Customer Account business object
 * @param p_cust_acct_os Customer Account original system name
 * @param p_cust_acct_osr Customer Account original system reference
 * @param x_cust_acct_obj The retrieved Customer Account business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Customer Account Business Object
 * @rep:doccd 120hztig.pdf Get Customer Account Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
 PROCEDURE get_cust_acct_bo(
    p_cust_acct_id        IN            NUMBER,
    p_cust_acct_os              IN      VARCHAR2,
    p_cust_acct_osr             IN      VARCHAR2,
    x_cust_acct_obj          OUT NOCOPY    HZ_CUST_ACCT_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );

  PROCEDURE do_create_cust_acct_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_obj           IN OUT NOCOPY HZ_CUST_ACCT_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_id            OUT NOCOPY    NUMBER,
    x_cust_acct_os            OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE do_update_cust_acct_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_obj           IN OUT NOCOPY HZ_CUST_ACCT_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_id            OUT NOCOPY    NUMBER,
    x_cust_acct_os            OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr           OUT NOCOPY    VARCHAR2,
    p_parent_os               IN            VARCHAR2
  );

  PROCEDURE do_save_cust_acct_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_obj           IN OUT NOCOPY HZ_CUST_ACCT_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_id            OUT NOCOPY    NUMBER,
    x_cust_acct_os            OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  );

 -- PROCEDURE create_cust_acct_v2_bo
  --
  -- DESCRIPTION
  --     Create customer account business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_cust_acct_v2_obj     Customer account object.
  --     p_created_by_module  Created by module.
  --   IN OUT:
  --     px_parent_acct_id    Parent id.
  --     px_parent_acct_os    Parent original system.
  --     px_parent_acct_osr   Parent original system reference.
  --     px_parent_obj_type   Parent object type.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_messages           Messages in Message stack
  --     x_cust_acct_id       Customer Account ID.
  --     x_cust_acct_os       Customer Account orig system.
  --     x_cust_acct_osr      Customer Account orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   1-FEB-2008    vsegu          Created.

/*#
 * Create Customer Account Business Object (create_cust_acct_v2_bo)
 * Creates a Customer Account business object. You pass object data to the procedure, packaged within an object type
 * defined specifically for the API. The object type is HZ_CUST_ACCT_V2_BO for the Customer Account business object.
 * In addition to the object's business object attributes, the object type also includes lower-level embedded child
 * entities or objects that can be simultaneously created.
 *
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_cust_acct_v2_obj The Customer Account business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Customer Account business object that was created, returned as an output parameter
 * @param x_messages Messages returned from the creation of the business object
 * @param x_cust_acct_id TCA identifier for the Customer Account business object
 * @param x_cust_acct_os Customer Account original system name
 * @param x_cust_acct_osr Customer Account original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter or both the px_parent_os and px_parent_osr parameters must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Customer Account Business Object
 * @rep:doccd 120hztig.pdf Create Customer Account Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE create_cust_acct_v2_bo(
    p_validate_bo_flag     IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_v2_obj        IN            HZ_CUST_ACCT_V2_BO,
    p_created_by_module    IN            VARCHAR2,
    p_obj_source           IN            VARCHAR2 := null,
    p_return_obj_flag      IN            VARCHAR2 := fnd_api.g_true,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj           OUT NOCOPY    HZ_CUST_ACCT_V2_BO,
    x_cust_acct_id         OUT NOCOPY    NUMBER,
    x_cust_acct_os         OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr        OUT NOCOPY    VARCHAR2,
    px_parent_id           IN OUT NOCOPY NUMBER,
    px_parent_os           IN OUT NOCOPY VARCHAR2,
    px_parent_osr          IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type     IN OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE update_cust_acct_v2_bo
  --
  -- DESCRIPTION
  --     Update customer account business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_cust_acct_v2_obj     Customer account object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_messages           Messages in Message stack
  --     x_cust_acct_id       Customer Account ID.
  --     x_cust_acct_os       Customer Account orig system.
  --     x_cust_acct_osr      Customer Account orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

 /*#
 * Update Customer Account Business Object (update_cust_acct_v2_bo)
 * Updates a Customer Account business object. You pass any modified object data to the procedure, packaged within an
 * object type defined specifically for the API. The object type is HZ_CUST_ACCT_V2_BO for the Customer Account business
 * object. In addition to the object's business object attributes, the object type also includes embedded child business
 * entities or objects that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param p_cust_acct_v2_obj The Customer Account business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Customer Account business object that was updated, returned as an output parameter
 * @param x_messages Messages returned from the update of the business object
 * @param x_cust_acct_id TCA identifier for the Customer Account business object
 * @param x_cust_acct_os Customer Account original system name
 * @param x_cust_acct_osr Customer Account original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Customer Account Business Object
 * @rep:doccd 120hztig.pdf Update Customer Account Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE update_cust_acct_v2_bo(
    p_cust_acct_v2_obj        IN            HZ_CUST_ACCT_V2_BO,
    p_created_by_module    IN            VARCHAR2,
    p_obj_source           IN            VARCHAR2 := null,
    p_return_obj_flag      IN            VARCHAR2 := fnd_api.g_true,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj           OUT NOCOPY    HZ_CUST_ACCT_V2_BO,
    x_cust_acct_id         OUT NOCOPY    NUMBER,
    x_cust_acct_os         OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr        OUT NOCOPY    VARCHAR2
  );

 -- PROCEDURE save_cust_acct_v2_bo
  --
  -- DESCRIPTION
  --     Create or update customer account business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_cust_acct_v2_obj     Customer account object.
  --     p_created_by_module  Created by module.
  --   IN OUT:
  --     px_parent_acct_id    Parent id.
  --     px_parent_acct_os    Parent original system.
  --     px_parent_acct_osr   Parent original system reference.
  --     px_parent_obj_type   Parent object type.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_messages           Messages in Message stack
  --     x_cust_acct_id       Customer Account ID.
  --     x_cust_acct_os       Customer Account orig system.
  --     x_cust_acct_osr      Customer Account orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   1-FEB-2008    vsegu          Created.

/*#
 * Save Customer Account Business Object (save_cust_acct_v2_bo)
 * Saves a Customer Account business object. You pass new or modified object data to the procedure, packaged within
 * an object type defined specifically for the API. The API then determines if the object exists in TCA, based upon
 * the provided identification information, and creates or updates the object. The object type is HZ_CUST_ACCT_V2_BO
 * for the Customer Account business object. For either case, the object type that you provide will be processed as if
 * the respective API procedure is being called (create_cust_acct_v2_bo or update_cust_acct_v2_bo). Please see those procedures
 * for more details. In addition to the object's business object attributes, the object type also includes embedded
 * child business entities or objects that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_cust_acct_v2_obj The Customer Account business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Customer Account business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_cust_acct_id TCA identifier for the Customer Account business object
 * @param x_cust_acct_os Customer Account original system name
 * @param x_cust_acct_osr Customer Account original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter, or both the px_parent_os and px_parent_osr parameters, must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save Customer Account Business Object
 * @rep:doccd 120hztig.pdf Save Customer Account Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE save_cust_acct_v2_bo(
    p_validate_bo_flag     IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_v2_obj        IN            HZ_CUST_ACCT_V2_BO,
    p_created_by_module    IN            VARCHAR2,
    p_obj_source           IN            VARCHAR2 := null,
    p_return_obj_flag      IN            VARCHAR2 := fnd_api.g_true,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj           OUT NOCOPY    HZ_CUST_ACCT_V2_BO,
    x_cust_acct_id         OUT NOCOPY    NUMBER,
    x_cust_acct_os         OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr        OUT NOCOPY    VARCHAR2,
    px_parent_id           IN OUT NOCOPY NUMBER,
    px_parent_os           IN OUT NOCOPY VARCHAR2,
    px_parent_osr          IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type     IN OUT NOCOPY VARCHAR2
  );

 --------------------------------------
  --
  -- PROCEDURE get_cust_acct_v2_bo
  --
  -- DESCRIPTION
  --     Get a logical customer account.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_cust_acct_id          customer account ID.
  --       p_parent_id	      Parent Id.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_cust_acct_v2_obj         Logical customer account record.
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
  --   1-FEB-2008  VSEGU                Created.
  --

/*

The Get customer account API Procedure is a retrieval service that returns full customer account business objects.
The user identifies a particular Organization Contact business object using the TCA identifier and/or the object's
Source System information. Upon proper validation of the object, the full Organization Contact business object is returned.
The object consists of all data included within the Organization Contact business object, at all embedded levels.
This includes the set of all data stored in the TCA tables for each embedded entity.


Embedded BO	    	Mandatory	Multiple Logical API Procedure		Comments
Customer Account Site		N	Y	get_cust_acct_site_v2_bo
Customer Account Contact	N	Y	get_cust_acct_contact_bo
Customer Profile		Y	N	Business Structure. Included entities:
                                                HZ_CUSTOMER_PROFILES, HZ_CUST_PROFILE_AMTS

To retrieve the appropriate embedded entities within the 'Organization Contact' business object, the Get procedure returns all records for the particular contact from these TCA entity tables.

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Customer Account	Y		N	HZ_CUST_ACCOUNTS
Account Relationship	N		Y	HZ_CUST_ACCT_RELATE
Bank Account Use	N		Y	Owned by Payments team
Payment Method		N		N	Owned by AR team

*/



 PROCEDURE get_cust_acct_v2_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_cust_acct_id        IN            NUMBER,
    p_cust_acct_os		IN	VARCHAR2,
    p_cust_acct_osr		IN	VARCHAR2,
    x_cust_acct_v2_obj          OUT NOCOPY    HZ_CUST_ACCT_V2_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Get Customer Account Business Object (get_cust_acct_v2_bo)
 * Extracts a particular Customer Account business object from TCA. You pass the object's identification information
 * to the procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_cust_acct_id TCA identifier for the Customer Account business object
 * @param p_cust_acct_os Customer Account original system name
 * @param p_cust_acct_osr Customer Account original system reference
 * @param x_cust_acct_v2_obj The retrieved Customer Account business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Customer Account Business Object
 * @rep:doccd 120hztig.pdf Get Customer Account Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
 PROCEDURE get_cust_acct_v2_bo(
    p_cust_acct_id        IN            NUMBER,
    p_cust_acct_os              IN      VARCHAR2,
    p_cust_acct_osr             IN      VARCHAR2,
    x_cust_acct_v2_obj          OUT NOCOPY    HZ_CUST_ACCT_V2_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );

  PROCEDURE do_create_cust_acct_v2_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_v2_obj           IN OUT NOCOPY HZ_CUST_ACCT_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_id            OUT NOCOPY    NUMBER,
    x_cust_acct_os            OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE do_update_cust_acct_v2_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_v2_obj           IN OUT NOCOPY HZ_CUST_ACCT_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_id            OUT NOCOPY    NUMBER,
    x_cust_acct_os            OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr           OUT NOCOPY    VARCHAR2,
    p_parent_os               IN            VARCHAR2
  );

  PROCEDURE do_save_cust_acct_v2_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_v2_obj           IN OUT NOCOPY HZ_CUST_ACCT_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_id            OUT NOCOPY    NUMBER,
    x_cust_acct_os            OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  );


END HZ_CUST_ACCT_BO_PUB;

/

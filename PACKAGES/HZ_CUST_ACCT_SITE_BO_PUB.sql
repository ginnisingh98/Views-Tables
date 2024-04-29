--------------------------------------------------------
--  DDL for Package HZ_CUST_ACCT_SITE_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CUST_ACCT_SITE_BO_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHBCSBS.pls 120.10 2008/02/06 11:20:32 vsegu ship $ */
/*#
 * Customer Account Site Business Object API
 * Public API that allows users to manage Customer Account Site business objects in the Trading Community Architecture.
 * Several operations are supported, including the creation and update of the business object.
 *
 * @rep:scope public
 * @rep:product HZ
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY HZ_ADDRESS
 * @rep:displayname Customer Account Site Business Object API
 * @rep:doccd 120hztig.pdf Customer Account Site Business Object API, Oracle Trading Community Architecture Technical Implementation Guide
 */

  -- PROCEDURE create_cust_acct_site_bo
  --
  -- DESCRIPTION
  --     Create customer account site business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_cust_acct_site_obj Customer account site object.
  --     p_created_by_module  Created by module.
  --   IN OUT:
  --     px_parent_acct_id    Parent customer account id
  --     px_parent_acct_os    Parent customer account os
  --     px_parent_acct_osr   Parent customer account osr
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_cust_acct_site_id  Customer Account Site ID.
  --     x_cust_acct_site_os  Customer Account Site orig system.
  --     x_cust_acct_site_osr Customer Account Site orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE create_cust_acct_site_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_obj      IN            HZ_CUST_ACCT_SITE_BO,
    p_created_by_module       IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_acct_id         IN OUT NOCOPY NUMBER,
    px_parent_acct_os         IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr        IN OUT NOCOPY VARCHAR2
  );

/*#
 * Create Customer Account Site Business Object (create_cust_acct_site_bo)
 * Creates a Customer Account Site business object. You pass object data to the procedure, packaged within an object type
 * defined specifically for the API. The object type is HZ_CUST_ACCT_SITE_BO for the Customer Account Site business object.
 * In addition to the object's business object attributes, the object type also includes lower-level embedded child entities
 * or objects that can be simultaneously created.
 *
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_cust_acct_site_obj The Customer Account Site business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Customer Account Site business object that was created, returned as an output parameter
 * @param x_messages Messages returned from the creation of the business object
 * @param x_cust_acct_site_id TCA identifier for the Customer Account Site business object
 * @param x_cust_acct_site_os Customer Account Site original system name
 * @param x_cust_acct_site_osr Customer Account Site original system reference
 * @param px_parent_acct_id TCA identifier for parent object. Either this parameter or both the px_parent_os and px_parent_osr parameters must be given
 * @param px_parent_acct_os Parent object original system name
 * @param px_parent_acct_osr Parent object original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Customer Account Site Business Object
 * @rep:doccd 120hztig.pdf Create Customer Account Site Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE create_cust_acct_site_bo(
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_obj      IN            HZ_CUST_ACCT_SITE_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_SITE_BO,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_acct_id         IN OUT NOCOPY NUMBER,
    px_parent_acct_os         IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr        IN OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE update_cust_acct_site_bo
  --
  -- DESCRIPTION
  --     Update customer account site business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_cust_acct_site_obj Customer account site object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_cust_acct_site_id  Customer Account Site ID.
  --     x_cust_acct_site_os  Customer Account Site orig system.
  --     x_cust_acct_site_osr Customer Account Site orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE update_cust_acct_site_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_cust_acct_site_obj      IN            HZ_CUST_ACCT_SITE_BO,
    p_created_by_module       IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2
  );

/*#
 * Update Customer Account Site Business Object (update_cust_acct_site_bo)
 * Updates a Customer Account Site business object. You pass any modified object data to the procedure, packaged within an
 * object type defined specifically for the API. The object type is HZ_CUST_ACCT_SITE_BO for the Customer Account Site
 * business object. In addition to the object's business object attributes, the object type also includes embedded child
 * business entities or objects that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param p_cust_acct_site_obj The Customer Account Site business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Customer Account Site business object that was updated, returned as an output parameter
 * @param x_messages Messages returned from the update of the business object
 * @param x_cust_acct_site_id TCA identifier for the Customer Account Site business object
 * @param x_cust_acct_site_os Customer Account Site original system name
 * @param x_cust_acct_site_osr Customer Account Site original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Customer Account Site Business Object
 * @rep:doccd 120hztig.pdf Update Customer Account Site Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE update_cust_acct_site_bo(
    p_cust_acct_site_obj      IN            HZ_CUST_ACCT_SITE_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_SITE_BO,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_cust_acct_site_bo
  --
  -- DESCRIPTION
  --     Create or update customer account site business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_cust_acct_site_obj Customer account site object.
  --     p_created_by_module  Created by module.
  --   IN OUT:
  --     px_parent_acct_id    Parent customer account id
  --     px_parent_acct_os    Parent customer account os
  --     px_parent_acct_osr   Parent customer account osr
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_cust_acct_site_id  Customer Account Site ID.
  --     x_cust_acct_site_os  Customer Account Site orig system.
  --     x_cust_acct_site_osr Customer Account Site orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE save_cust_acct_site_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_obj      IN            HZ_CUST_ACCT_SITE_BO,
    p_created_by_module       IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_acct_id         IN OUT NOCOPY NUMBER,
    px_parent_acct_os         IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr        IN OUT NOCOPY VARCHAR2
  );

/*#
 * Save Customer Account Site Business Object (save_cust_acct_site_bo)
 * Saves a Customer Account Site business object. You pass new or modified object data to the procedure, packaged within
 * an object type defined specifically for the API. The API then determines if the object exists in TCA, based upon the
 * provided identification information, and creates or updates the object. The object type is HZ_CUST_ACCT_SITE_BO for
 * the Customer Account Site business object. For either case, the object type that you provide will be processed as if
 * the respective API procedure is being called (create_cust_acct_site_bo or update_cust_acct_site_bo). Please see those
 * procedures for more details. In addition to the object's business object attributes, the object type also includes
 * embedded child business entities or objects that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_cust_acct_site_obj The Customer Account Site business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Customer Account Site business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_cust_acct_site_id TCA identifier for the Customer Account Site business object
 * @param x_cust_acct_site_os Customer Account Site original system name
 * @param x_cust_acct_site_osr Customer Account Site original system reference
 * @param px_parent_acct_id TCA identifier for parent object. Either this parameter or both the px_parent_os and px_parent_osr parameters must be given
 * @param px_parent_acct_os Parent object original system name
 * @param px_parent_acct_osr Parent object original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save Customer Account Site Business Object
 * @rep:doccd 120hztig.pdf Save Customer Account Site Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE save_cust_acct_site_bo(
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_obj      IN            HZ_CUST_ACCT_SITE_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_SITE_BO,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_acct_id         IN OUT NOCOPY NUMBER,
    px_parent_acct_os         IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr        IN OUT NOCOPY VARCHAR2
  );

  --------------------------------------
  --
  -- PROCEDURE get_cust_acct_site_bo
  --
  -- DESCRIPTION
  --     Get logical customer account site.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_parent_id          parent id.
--       p_cust_acct_site_id          customer account site ID.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_cust_acct_site_obj         Logical customer account site record.
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
  --   8-JUN-2005   AWU                Created.
  --

/*

The Get customer account site API Procedure is a retrieval service that returns a full customer account site business object.
The user identifies a particular Organization Contact business object using the TCA identifier and/or the object's Source System
information. Upon proper validation of the object, the full Organization Contact business object is returned.
The object consists of all data included within the Organization Contact business object, at all embedded levels. This includes the
set of all data stored in the TCA tables for each embedded entity.


Embedded BO	    	Mandatory	Multiple Logical API Procedure		Comments

Party Site			Y	N	get_party_site_bo
Customer Account Site Contact	N	Y	get_cust_acct_contact_bo
Customer Account Site Use	N	Y	Business Structure. Included entities and
						structures:HZ_CUST_SITE_USES_ALL,Customer
						Profile (Business Structure)


To retrieve the appropriate embedded entities within the 'Organization Contact' business object, the Get procedure returns all
records for the particular contact from these TCA entity tables.

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Customer account site	Y		N	HZ_CUST_ACCOUNTS
Bank account site Use	N		Y	Owned by Payments team
Payment Method		N		N	Owned by AR team

*/

PROCEDURE get_cust_acct_site_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_cust_acct_site_id	IN	NUMBER,
	p_cust_acct_site_os	IN	VARCHAR2,
	p_cust_acct_site_osr	IN	VARCHAR2,
	x_cust_acct_site_obj	OUT NOCOPY	HZ_CUST_ACCT_SITE_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
);

/*#
 * Get Customer Account Site Business Object (get_cust_acct_site_bo)
 * Extracts a particular Customer Account Site business object from TCA. You pass the object's identification information
 * to the procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_cust_acct_site_id TCA identifier for the Customer Account Site business object
 * @param p_cust_acct_site_os Customer Account Site original system name
 * @param p_cust_acct_site_osr Customer Account Site original system reference
 * @param x_cust_acct_site_obj The retrieved Customer Account Site business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Customer Account Site Business Object
 * @rep:doccd 120hztig.pdf Get Customer Account Site Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_cust_acct_site_bo (
        p_cust_acct_site_id     IN      NUMBER,
        p_cust_acct_site_os     IN      VARCHAR2,
        p_cust_acct_site_osr    IN      VARCHAR2,
        x_cust_acct_site_obj    OUT NOCOPY      HZ_CUST_ACCT_SITE_BO,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_messages              OUT NOCOPY      HZ_MESSAGE_OBJ_TBL
);

  PROCEDURE do_create_cust_acct_site_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_obj      IN OUT NOCOPY HZ_CUST_ACCT_SITE_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_acct_id         IN OUT NOCOPY NUMBER,
    px_parent_acct_os         IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr        IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE do_update_cust_acct_site_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_obj      IN OUT NOCOPY HZ_CUST_ACCT_SITE_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    p_parent_os               IN            VARCHAR2
  );

  PROCEDURE do_save_cust_acct_site_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_obj      IN OUT NOCOPY HZ_CUST_ACCT_SITE_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_acct_id         IN OUT NOCOPY NUMBER,
    px_parent_acct_os         IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr        IN OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE create_cust_acct_site_v2_bo
  --
  -- DESCRIPTION
  --     Create customer account site business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_cust_acct_site_v2_obj Customer account site object.
  --     p_created_by_module  Created by module.
  --   IN OUT:
  --     px_parent_acct_id    Parent customer account id
  --     px_parent_acct_os    Parent customer account os
  --     px_parent_acct_osr   Parent customer account osr
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_messages           Messages in message stack
  --     x_cust_acct_site_id  Customer Account Site ID.
  --     x_cust_acct_site_os  Customer Account Site orig system.
  --     x_cust_acct_site_osr Customer Account Site orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   31-JAN-2008    vsegu          Created.
  --

/*#
 * Create Customer Account Site Business Object (create_cust_acct_site_v2_bo)
 * Creates a Customer Account Site business object. You pass object data to the procedure, packaged within an object type
 * defined specifically for the API. The object type is HZ_CUST_ACCT_SITE_V2_BO for the Customer Account Site business object.
 * In addition to the object's business object attributes, the object type also includes lower-level embedded child entities
 * or objects that can be simultaneously created.
 *
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_cust_acct_site_v2_obj The Customer Account Site business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Customer Account Site business object that was created, returned as an output parameter
 * @param x_messages Messages returned from the creation of the business object
 * @param x_cust_acct_site_id TCA identifier for the Customer Account Site business object
 * @param x_cust_acct_site_os Customer Account Site original system name
 * @param x_cust_acct_site_osr Customer Account Site original system reference
 * @param px_parent_acct_id TCA identifier for parent object. Either this parameter or both the px_parent_os and px_parent_osr parameters must be given
 * @param px_parent_acct_os Parent object original system name
 * @param px_parent_acct_osr Parent object original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Customer Account Site Business Object
 * @rep:doccd 120hztig.pdf Create Customer Account Site Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE create_cust_acct_site_v2_bo(
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_v2_obj      IN            HZ_CUST_ACCT_SITE_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_SITE_V2_BO,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_acct_id         IN OUT NOCOPY NUMBER,
    px_parent_acct_os         IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr        IN OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE update_cust_acct_site_v2_bo
  --
  -- DESCRIPTION
  --     Update customer account site business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_cust_acct_site_v2_obj Customer account site object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_messages           Messages in message stack
  --     x_cust_acct_site_id  Customer Account Site ID.
  --     x_cust_acct_site_os  Customer Account Site orig system.
  --     x_cust_acct_site_osr Customer Account Site orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   31-JAN-2008    vsegu          Created.
  --

/*#
 * Update Customer Account Site Business Object (update_cust_acct_site_v2_bo)
 * Updates a Customer Account Site business object. You pass any modified object data to the procedure, packaged within an
 * object type defined specifically for the API. The object type is HZ_CUST_ACCT_SITE_V2_BO for the Customer Account Site
 * business object. In addition to the object's business object attributes, the object type also includes embedded child
 * business entities or objects that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param p_cust_acct_site_v2_obj The Customer Account Site business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Customer Account Site business object that was updated, returned as an output parameter
 * @param x_messages Messages returned from the update of the business object
 * @param x_cust_acct_site_id TCA identifier for the Customer Account Site business object
 * @param x_cust_acct_site_os Customer Account Site original system name
 * @param x_cust_acct_site_osr Customer Account Site original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Customer Account Site Business Object
 * @rep:doccd 120hztig.pdf Update Customer Account Site Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE update_cust_acct_site_v2_bo(
    p_cust_acct_site_v2_obj      IN            HZ_CUST_ACCT_SITE_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_SITE_V2_BO,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_cust_acct_site_v2_bo
  --
  -- DESCRIPTION
  --     Create or update customer account site business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_cust_acct_site_v2_obj Customer account site object.
  --     p_created_by_module  Created by module.
  --   IN OUT:
  --     px_parent_acct_id    Parent customer account id
  --     px_parent_acct_os    Parent customer account os
  --     px_parent_acct_osr   Parent customer account osr
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_messages           Messages in message stack
  --     x_cust_acct_site_id  Customer Account Site ID.
  --     x_cust_acct_site_os  Customer Account Site orig system.
  --     x_cust_acct_site_osr Customer Account Site orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   31-JAN-2008    vsegu          Created.
  --

/*#
 * Save Customer Account Site Business Object (save_cust_acct_site_v2_bo)
 * Saves a Customer Account Site business object. You pass new or modified object data to the procedure, packaged within
 * an object type defined specifically for the API. The API then determines if the object exists in TCA, based upon the
 * provided identification information, and creates or updates the object. The object type is HZ_CUST_ACCT_SITE_V2_BO for
 * the Customer Account Site business object. For either case, the object type that you provide will be processed as if
 * the respective API procedure is being called (create_cust_acct_site_v2_bo or update_cust_acct_site_v2_bo). Please see those
 * procedures for more details. In addition to the object's business object attributes, the object type also includes
 * embedded child business entities or objects that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_cust_acct_site_v2_obj The Customer Account Site business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Customer Account Site business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_cust_acct_site_id TCA identifier for the Customer Account Site business object
 * @param x_cust_acct_site_os Customer Account Site original system name
 * @param x_cust_acct_site_osr Customer Account Site original system reference
 * @param px_parent_acct_id TCA identifier for parent object. Either this parameter or both the px_parent_os and px_parent_osr parameters must be given
 * @param px_parent_acct_os Parent object original system name
 * @param px_parent_acct_osr Parent object original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save Customer Account Site Business Object
 * @rep:doccd 120hztig.pdf Save Customer Account Site Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE save_cust_acct_site_v2_bo(
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_v2_obj      IN            HZ_CUST_ACCT_SITE_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_SITE_V2_BO,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_acct_id         IN OUT NOCOPY NUMBER,
    px_parent_acct_os         IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr        IN OUT NOCOPY VARCHAR2
  );

  --------------------------------------
  --
  -- PROCEDURE get_cust_acct_site_v2_bo
  --
  -- DESCRIPTION
  --     Get logical customer account site.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_parent_id          parent id.
--       p_cust_acct_site_id          customer account site ID.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_cust_acct_site_v2_obj         Logical customer account site record.
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
  --   31-JAN-2008   VSEGU                Created.
  --

/*

The Get customer account site API Procedure is a retrieval service that returns a full customer account site business object.
The user identifies a particular Organization Contact business object using the TCA identifier and/or the object's Source System
information. Upon proper validation of the object, the full Organization Contact business object is returned.
The object consists of all data included within the Organization Contact business object, at all embedded levels. This includes the
set of all data stored in the TCA tables for each embedded entity.


Embedded BO	    	Mandatory	Multiple Logical API Procedure		Comments

Party Site			Y	N	get_party_site_bo
Customer Account Site Contact	N	Y	get_cust_acct_contact_bo
Customer Account Site Use	N	Y	Business Structure. Included entities and
						structures:HZ_CUST_SITE_USES_ALL,Customer
						Profile (Business Structure)


To retrieve the appropriate embedded entities within the 'Organization Contact' business object, the Get procedure returns all
records for the particular contact from these TCA entity tables.

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Customer account site	Y		N	HZ_CUST_ACCOUNTS
Bank account site Use	N		Y	Owned by Payments team
Payment Method		N		N	Owned by AR team

*/

PROCEDURE get_cust_acct_site_v2_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_cust_acct_site_id	IN	NUMBER,
	p_cust_acct_site_os	IN	VARCHAR2,
	p_cust_acct_site_osr	IN	VARCHAR2,
	x_cust_acct_site_v2_obj	OUT NOCOPY	HZ_CUST_ACCT_SITE_V2_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
);

/*#
 * Get Customer Account Site Business Object (get_cust_acct_site_v2_bo)
 * Extracts a particular Customer Account Site business object from TCA. You pass the object's identification information
 * to the procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_cust_acct_site_id TCA identifier for the Customer Account Site business object
 * @param p_cust_acct_site_os Customer Account Site original system name
 * @param p_cust_acct_site_osr Customer Account Site original system reference
 * @param x_cust_acct_site_v2_obj The retrieved Customer Account Site business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Customer Account Site Business Object
 * @rep:doccd 120hztig.pdf Get Customer Account Site Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_cust_acct_site_v2_bo (
        p_cust_acct_site_id     IN      NUMBER,
        p_cust_acct_site_os     IN      VARCHAR2,
        p_cust_acct_site_osr    IN      VARCHAR2,
        x_cust_acct_site_v2_obj    OUT NOCOPY      HZ_CUST_ACCT_SITE_V2_BO,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_messages              OUT NOCOPY      HZ_MESSAGE_OBJ_TBL
);

  PROCEDURE do_create_cust_acct_site_v2_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_v2_obj      IN OUT NOCOPY HZ_CUST_ACCT_SITE_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_acct_id         IN OUT NOCOPY NUMBER,
    px_parent_acct_os         IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr        IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE do_update_cust_acct_site_v2_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_v2_obj      IN OUT NOCOPY HZ_CUST_ACCT_SITE_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    p_parent_os               IN            VARCHAR2
  );

  PROCEDURE do_save_cust_acct_site_v2_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_v2_obj      IN OUT NOCOPY HZ_CUST_ACCT_SITE_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_acct_id         IN OUT NOCOPY NUMBER,
    px_parent_acct_os         IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr        IN OUT NOCOPY VARCHAR2
  );

END HZ_CUST_ACCT_SITE_BO_PUB;

/

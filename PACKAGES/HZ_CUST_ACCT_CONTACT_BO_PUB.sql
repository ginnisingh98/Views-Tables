--------------------------------------------------------
--  DDL for Package HZ_CUST_ACCT_CONTACT_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CUST_ACCT_CONTACT_BO_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHBCRBS.pls 120.7 2006/09/21 17:59:01 acng noship $ */
/*#
 * Customer Account Contact Business Object API
 * Public API that allows users to manage Customer Account Contact business objects in the Trading Community Architecture.
 * Several operations are supported, including the creation and update of the business object.
 *
 * @rep:scope public
 * @rep:product HZ
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY HZ_ACCOUNT_CONTACT
 * @rep:displayname Customer Account Contact Business Object API
 * @rep:doccd 120hztig.pdf Customer Account Contact Business Object API, Oracle Trading Community Architecture Technical Implementation Guide
 */

  -- PROCEDURE create_cust_acct_contact_bo
  --
  -- DESCRIPTION
  --     Create customer account contact business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_cust_acct_contact_obj  Customer account contact object.
  --     p_created_by_module  Created by module.
  --   IN OUT:
  --     px_parent_id         Parent id
  --     px_parent_os         Parent os
  --     px_parent_osr        Parent osr
  --     px_parent_obj_type   Parent object type
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_cust_acct_contact_id   Customer Account Contact ID.
  --     x_cust_acct_contact_os   Customer Account Contact orig system.
  --     x_cust_acct_contact_osr  Customer Account Contact orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE create_cust_acct_contact_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_contact_obj   IN            HZ_CUST_ACCT_CONTACT_BO,
    p_created_by_module       IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_id    OUT NOCOPY    NUMBER,
    x_cust_acct_contact_os    OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_osr   OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  );

/*#
 * Create Customer Account Contact Business Object (create_cust_acct_contact_bo)
 * Creates a Customer Account Contact business object. You pass object data to the procedure, packaged within an object
 * type defined specifically for the API. The object type is HZ_CUST_ACCT_CONTACT_BO for the Customer Account Contact
 * business object. In addition to the object's business object attributes, the object type also includes lower-level
 * embedded child entities or objects that can be simultaneously created.
 *
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_cust_acct_contact_obj The Customer Account Contact business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Customer Account Contact business object that was created, returned as an output parameter
 * @param x_messages Messages returned from the creation of the business object
 * @param x_cust_acct_contact_id TCA identifier for the Customer Account Contact business object
 * @param x_cust_acct_contact_os Customer Account Contact original system name
 * @param x_cust_acct_contact_osr Customer Account Contact original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter or both the px_parent_os and px_parent_osr parameters must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Customer Account Contact Business Object
 * @rep:doccd 120hztig.pdf Create Customer Account Contact Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE create_cust_acct_contact_bo(
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_contact_obj   IN            HZ_CUST_ACCT_CONTACT_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_CONTACT_BO,
    x_cust_acct_contact_id    OUT NOCOPY    NUMBER,
    x_cust_acct_contact_os    OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_osr   OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE update_cust_acct_contact_bo
  --
  -- DESCRIPTION
  --     Update customer account contact business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_cust_acct_contact_obj  Customer account contact object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_cust_acct_contact_id   Customer Account Contact ID.
  --     x_cust_acct_contact_os   Customer Account Contact orig system.
  --     x_cust_acct_contact_osr  Customer Account Contact orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE update_cust_acct_contact_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_cust_acct_contact_obj   IN            HZ_CUST_ACCT_CONTACT_BO,
    p_created_by_module       IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_id    OUT NOCOPY    NUMBER,
    x_cust_acct_contact_os    OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_osr   OUT NOCOPY    VARCHAR2
  );

/*#
 * Update Customer Account Contact Business Object (update_cust_acct_contact_bo)
 * Updates a Customer Account Contact business object. You pass any modified object data to the procedure, packaged within
 * an object type defined specifically for the API. The object type is HZ_CUST_ACCT_CONTACT_BO for the Customer Account
 * Contact business object. In addition to the object's business object attributes, the object type also includes embedded
 * child business entities or objects that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param p_cust_acct_contact_obj The Customer Account Contact business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Customer Account Contact business object that was updated, returned as an output parameter
 * @param x_messages Messages returned from the update of the business object
 * @param x_cust_acct_contact_id TCA identifier for the Customer Account Contact business object
 * @param x_cust_acct_contact_os Customer Account Contact original system name
 * @param x_cust_acct_contact_osr Customer Account Contact original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Customer Account Contact Business Object
 * @rep:doccd 120hztig.pdf Update Customer Account Contact Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE update_cust_acct_contact_bo(
    p_cust_acct_contact_obj   IN            HZ_CUST_ACCT_CONTACT_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_CONTACT_BO,
    x_cust_acct_contact_id    OUT NOCOPY    NUMBER,
    x_cust_acct_contact_os    OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_osr   OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_cust_acct_contact_bo
  --
  -- DESCRIPTION
  --     Create or update customer account contact business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_cust_acct_contact_obj  Customer account contact object.
  --     p_created_by_module  Created by module.
  --   IN OUT:
  --     px_parent_id         Parent id
  --     px_parent_os         Parent os
  --     px_parent_osr        Parent osr
  --     px_parent_obj_type   Parent object type
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_cust_acct_contact_id   Customer Account Contact ID.
  --     x_cust_acct_contact_os   Customer Account Contact orig system.
  --     x_cust_acct_contact_osr  Customer Account Contact orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE save_cust_acct_contact_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_contact_obj   IN            HZ_CUST_ACCT_CONTACT_BO,
    p_created_by_module       IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_id    OUT NOCOPY    NUMBER,
    x_cust_acct_contact_os    OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_osr   OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  );

/*#
 * Save Customer Account Contact Business Object (save_cust_acct_contact_bo)
 * Saves a Customer Account Contact business object. You pass new or modified object data to the procedure, packaged within
 * an object type defined specifically for the API. The API then determines if the object exists in TCA, based upon the
 * provided identification information, and creates or updates the object. The object type is HZ_CUST_ACCT_CONTACT_BO for
 * the Customer Account Contact business object. For either case, the object type that you provide will be processed as if
 * the respective API procedure is being called (create_cust_acct_contact_bo or update_cust_acct_contact_bo). Please see
 * those procedures for more details. In addition to the object's business object attributes, the object type also includes
 * embedded child business entities or objects that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_cust_acct_contact_obj The Customer Account Contact business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Customer Account Contact business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_cust_acct_contact_id TCA identifier for the Customer Account Contact business object
 * @param x_cust_acct_contact_os Customer Account Contact original system name
 * @param x_cust_acct_contact_osr Customer Account Contact original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter, or both the px_parent_os and px_parent_osr parameters, must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save Customer Account Contact Business Object
 * @rep:doccd 120hztig.pdf Save Customer Account Contact Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE save_cust_acct_contact_bo(
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_contact_obj   IN            HZ_CUST_ACCT_CONTACT_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_CONTACT_BO,
    x_cust_acct_contact_id    OUT NOCOPY    NUMBER,
    x_cust_acct_contact_os    OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_osr   OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  );

 --------------------------------------
  --
  -- PROCEDURE get_cust_acct_contact_bos
  --
  -- DESCRIPTION
  --     Get logical customer account contacts.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
 --      p_parent_id          parent id.
--       p_cust_acct_contact_id          customer account contact ID.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_cust_acct_contact_objs         Logical customer account contact records.
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

The Get customer account contact API Procedure is a retrieval service that returns a full customer account contact business object.
The user identifies a particular Organization Contact business object using the TCA identifier and/or the object's Source System
information. Upon proper validation of the object, the full Organization Contact business object is returned.
The object consists of all data included within the Organization Contact business object, at all embedded levels. This includes the
set of all data stored in the TCA tables for each embedded entity.


Embedded BO	    	Mandatory	Multiple Logical API Procedure		Comments

Org Contact		Y		N	get_org_contact_bo


To retrieve the appropriate embedded entities within the 'Customer Account Contact' business object, the Get procedure returns all
records for the particular contact from these TCA entity tables.

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Customer Account Role	N	N	HZ_CUST_ACCOUNT_ROLES
Role Responsibility	N	Y	HZ_ROLE_RESPONSIBILITY

*/

PROCEDURE get_cust_acct_contact_bo (
	p_init_msg_list		IN	VARCHAR2:=FND_API.G_FALSE,
	p_cust_acct_contact_id	IN	NUMBER,
	p_cust_acct_contact_os	IN	VARCHAR2,
	p_cust_acct_contact_osr	IN	VARCHAR2,
	x_cust_acct_contact_obj	OUT NOCOPY	HZ_CUST_ACCT_CONTACT_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2
);

/*#
 * Get Customer Account Contact Business Object (get_cust_acct_contact_bo)
 * Extracts a particular Customer Account Contact business object from TCA. You pass the object's identification information
 * to the procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_cust_acct_contact_id TCA identifier for the Customer Account Contact business object
 * @param p_cust_acct_contact_os Customer Account Contact original system name
 * @param p_cust_acct_contact_osr Customer Account Contact original system reference
 * @param x_cust_acct_contact_obj The retrieved Customer Account Contact business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Customer Account Contact Business Object
 * @rep:doccd 120hztig.pdf Get Customer Account Contact Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_cust_acct_contact_bo (
        p_cust_acct_contact_id  IN      NUMBER,
        p_cust_acct_contact_os  IN      VARCHAR2,
        p_cust_acct_contact_osr IN      VARCHAR2,
        x_cust_acct_contact_obj OUT NOCOPY      HZ_CUST_ACCT_CONTACT_BO,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_messages                      OUT NOCOPY      HZ_MESSAGE_OBJ_TBL
);

  PROCEDURE do_create_cac_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_contact_obj   IN OUT NOCOPY HZ_CUST_ACCT_CONTACT_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_id    OUT NOCOPY    NUMBER,
    x_cust_acct_contact_os    OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_osr   OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE do_update_cac_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_cust_acct_contact_obj   IN OUT NOCOPY HZ_CUST_ACCT_CONTACT_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_id    OUT NOCOPY    NUMBER,
    x_cust_acct_contact_os    OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_osr   OUT NOCOPY    VARCHAR2,
    p_parent_os               IN            VARCHAR2
  );

  PROCEDURE do_save_cac_bo(
    p_init_msg_list            IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag         IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_contact_obj    IN OUT NOCOPY HZ_CUST_ACCT_CONTACT_BO,
    p_created_by_module        IN            VARCHAR2,
    p_obj_source               IN            VARCHAR2 := null,
    x_return_status            OUT NOCOPY    VARCHAR2,
    x_msg_count                OUT NOCOPY    NUMBER,
    x_msg_data                 OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_id     OUT NOCOPY    NUMBER,
    x_cust_acct_contact_os     OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_osr    OUT NOCOPY    VARCHAR2,
    px_parent_id               IN OUT NOCOPY NUMBER,
    px_parent_os               IN OUT NOCOPY VARCHAR2,
    px_parent_osr              IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type         IN OUT NOCOPY VARCHAR2
  );

END HZ_CUST_ACCT_CONTACT_BO_PUB;

 

/

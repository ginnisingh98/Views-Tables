--------------------------------------------------------
--  DDL for Package HZ_CONTACT_POINT_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CONTACT_POINT_BO_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHBCPBS.pls 120.9 2006/09/22 00:33:57 acng noship $ */
/*#
 * Contact Point Business Object API
 * Public API that allows users to manage Phone, Email, Web, SMS, Telex, EDI and EFT business objects in the
 * Trading Community Architecture. Several operations are supported, including the creation and update of the
 * business object.
 *
 * @rep:scope public
 * @rep:product HZ
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY HZ_CONTACT_POINT
 * @rep:displayname Contact Point Business Object API
 * @rep:doccd 120hztig.pdf Phone Business Object API, Oracle Trading Community Architecture Technical Implementation Guide
 */

  -- PROCEDURE create_phone_bo
  --
  -- DESCRIPTION
  --     Create a logical phone contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_phone_obj          Phone business object.
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
  --     x_phone_id           Contact point ID.
  --     x_phone_os           Contact point orig system.
  --     x_phone_osr          Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE create_phone_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_phone_obj           IN            HZ_PHONE_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_phone_id            OUT NOCOPY    NUMBER,
    x_phone_os            OUT NOCOPY    VARCHAR2,
    x_phone_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY            VARCHAR2
  );

/*#
 * Create Phone Business Object (create_phone_cp_bo)
 * Creates a Phone business object. You pass object data to the procedure, packaged within an object type defined
 * specifically for the API. The object type is HZ_PHONE_CP_BO for the Phone business object. In addition to the
 * object's business object attributes, the object type also includes lower-level embedded child entities or objects
 * that can be simultaneously created.
 *
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_phone_obj The Phone business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Phone business object that was created, returned as an output parameter
 * @param x_messages Messages returned from the creation of the business object
 * @param x_phone_id TCA identifier for the Phone business object
 * @param x_phone_os Phone original system name
 * @param x_phone_osr Phone original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter or both the px_parent_os and px_parent_osr parameters must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Phone Business Object
 * @rep:doccd 120hztig.pdf Create Phone Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE create_phone_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_phone_obj           IN            HZ_PHONE_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PHONE_CP_BO,
    x_phone_id            OUT NOCOPY    NUMBER,
    x_phone_os            OUT NOCOPY    VARCHAR2,
    x_phone_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY            VARCHAR2
  );

  -- PROCEDURE create_telex_bo
  --
  -- DESCRIPTION
  --     Create a logical telex contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_telex_obj          Telex business object.
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
  --     x_telex_id           Contact point ID.
  --     x_telex_os           Contact point orig system.
  --     x_telex_osr          Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE create_telex_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_telex_obj           IN            HZ_TELEX_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_telex_id            OUT NOCOPY    NUMBER,
    x_telex_os            OUT NOCOPY    VARCHAR2,
    x_telex_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY            VARCHAR2
  );

/*#
 * Create Telex Business Object (create_telex_bo)
 * Creates a Telex business object. You pass object data to the procedure, packaged within an object type defined
 * specifically for the API. The object type is HZ_TELEX_CP_BO for the Telex business object. In addition to the
 * object's business object attributes, the object type also includes lower-level embedded child entities or objects
 * that can be simultaneously created.
 *
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_telex_obj The Telex business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Telex business object that was created, returned as an output parameter
 * @param x_messages Messages returned from the creation of the business object
 * @param x_telex_id TCA identifier for the Telex business object
 * @param x_telex_os Telex original system name
 * @param x_telex_osr Telex original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter or both the px_parent_os and px_parent_osr parameters must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Telex Business Object
 * @rep:doccd 120hztig.pdf Create Telex Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE create_telex_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_telex_obj           IN            HZ_TELEX_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_TELEX_CP_BO,
    x_telex_id            OUT NOCOPY    NUMBER,
    x_telex_os            OUT NOCOPY    VARCHAR2,
    x_telex_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY            VARCHAR2
  );

  -- PROCEDURE create_email_bo
  --
  -- DESCRIPTION
  --     Create a logical email contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_email_obj          Email business object.
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
  --     x_email_id           Contact point ID.
  --     x_email_os           Contact point orig system.
  --     x_email_osr          Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE create_email_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_email_obj           IN            HZ_EMAIL_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_email_id            OUT NOCOPY    NUMBER,
    x_email_os            OUT NOCOPY    VARCHAR2,
    x_email_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY            VARCHAR2
  );

/*#
 * Create Email Business Object (create_email_bo)
 * Creates a Email business object. You pass object data to the procedure, packaged within an object type defined
 * specifically for the API. The object type is HZ_EMIAL_CP_BO for the Email business object. In addition to the
 * object's business object attributes, the object type also includes lower-level embedded child entities or objects
 * that can be simultaneously created.
 *
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_email_obj The Email business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Email business object that was created, returned as an output parameter
 * @param x_messages Messages returned from the creation of the business object
 * @param x_email_id TCA identifier for the Email business object
 * @param x_email_os Email original system name
 * @param x_email_osr Email original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter or both the px_parent_os and px_parent_osr parameters must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Email Business Object
 * @rep:doccd 120hztig.pdf Create Email Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE create_email_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_email_obj           IN            HZ_EMAIL_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_EMAIL_CP_BO,
    x_email_id            OUT NOCOPY    NUMBER,
    x_email_os            OUT NOCOPY    VARCHAR2,
    x_email_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY            VARCHAR2
  );

  -- PROCEDURE create_web_bo
  --
  -- DESCRIPTION
  --     Create a logical web contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_web_obj            Web business object.
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
  --     x_web_id             Contact point ID.
  --     x_web_os             Contact point orig system.
  --     x_web_osr            Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE create_web_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_web_obj             IN            HZ_WEB_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_web_id              OUT NOCOPY    NUMBER,
    x_web_os              OUT NOCOPY    VARCHAR2,
    x_web_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY            VARCHAR2
  );

/*#
 * Create Web Business Object (create_web_bo)
 * Creates a Web business object. You pass object data to the procedure, packaged within an object type defined
 * specifically for the API. The object type is HZ_WEB_CP_BO for the Web business object. In addition to the object's
 * business object attributes, the object type also includes lower-level embedded child entities or objects that can
 * be simultaneously created.
 *
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_web_obj The Web business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Web business object that was created, returned as an output parameter
 * @param x_messages Messages returned from the creation of the business object
 * @param x_web_id TCA identifier for the Web business object
 * @param x_web_os Web original system name
 * @param x_web_osr Web original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter or both the px_parent_os and px_parent_osr parameters must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Web Business Object
 * @rep:doccd 120hztig.pdf Create Web Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE create_web_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_web_obj             IN            HZ_WEB_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_WEB_CP_BO,
    x_web_id              OUT NOCOPY    NUMBER,
    x_web_os              OUT NOCOPY    VARCHAR2,
    x_web_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY            VARCHAR2
  );

  -- PROCEDURE create_edi_bo
  --
  -- DESCRIPTION
  --     Create a logical edi contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_edi_obj            EDI business object.
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
  --     x_edi_id             Contact point ID.
  --     x_edi_os             Contact point orig system.
  --     x_edi_osr            Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE create_edi_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_edi_obj             IN            HZ_EDI_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_edi_id              OUT NOCOPY    NUMBER,
    x_edi_os              OUT NOCOPY    VARCHAR2,
    x_edi_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY            VARCHAR2
  );

/*#
 * Create EDI Business Object (create_edi_bo)
 * Creates a EDI business object. You pass object data to the procedure, packaged within an object type defined
 * specifically for the API. The object type is HZ_EDI_CP_BO for the EDI business object. In addition to the object's
 * business object attributes, the object type also includes lower-level embedded child entities or objects that can
 * be simultaneously created.
 *
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_edi_obj The EDI business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The EDI business object that was created, returned as an output parameter
 * @param x_messages Messages returned from the creation of the business object
 * @param x_edi_id TCA identifier for the EDI business object
 * @param x_edi_os EDI original system name
 * @param x_edi_osr EDI original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter or both the px_parent_os and px_parent_osr parameters must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create EDI Business Object
 * @rep:doccd 120hztig.pdf Create EDI Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE create_edi_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_edi_obj             IN            HZ_EDI_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_EDI_CP_BO,
    x_edi_id              OUT NOCOPY    NUMBER,
    x_edi_os              OUT NOCOPY    VARCHAR2,
    x_edi_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY            VARCHAR2
  );

  -- PROCEDURE create_eft_bo
  --
  -- DESCRIPTION
  --     Create a logical eft contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_eft_obj            EFT business object.
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
  --     x_eft_id             Contact point ID.
  --     x_eft_os             Contact point orig system.
  --     x_eft_osr            Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE create_eft_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_eft_obj             IN            HZ_EFT_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_eft_id              OUT NOCOPY    NUMBER,
    x_eft_os              OUT NOCOPY    VARCHAR2,
    x_eft_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY            VARCHAR2
  );

/*#
 * Create EFT Business Object (create_eft_bo)
 * Creates a EFT business object. You pass object data to the procedure, packaged within an object type defined
 * specifically for the API. The object type is HZ_EFT_CP_BO for the EFT business object. In addition to the object's
 * business object attributes, the object type also includes lower-level embedded child entities or objects that can
 * be simultaneously created.
 *
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_eft_obj The EFT business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The EFT business object that was created, returned as an output parameter
 * @param x_messages Messages returned from the creation of the business object
 * @param x_eft_id TCA identifier for the EFT business object
 * @param x_eft_os EFT original system name
 * @param x_eft_osr EFT original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter or both the px_parent_os and px_parent_osr parameters must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create EFT Business Object
 * @rep:doccd 120hztig.pdf Create EFT Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE create_eft_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_eft_obj             IN            HZ_EFT_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_EFT_CP_BO,
    x_eft_id              OUT NOCOPY    NUMBER,
    x_eft_os              OUT NOCOPY    VARCHAR2,
    x_eft_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY            VARCHAR2
  );

  -- PROCEDURE create_sms_bo
  --
  -- DESCRIPTION
  --     Create a logical sms contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_sms_obj            SMS business object.
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
  --     x_sms_id             Contact point ID.
  --     x_sms_os             Contact point orig system.
  --     x_sms_osr            Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE create_sms_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_sms_obj             IN            HZ_SMS_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_sms_id              OUT NOCOPY    NUMBER,
    x_sms_os              OUT NOCOPY    VARCHAR2,
    x_sms_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY            VARCHAR2
  );

/*#
 * Create SMS Business Object (create_sms_bo)
 * Creates a SMS business object. You pass object data to the procedure, packaged within an object type defined
 * specifically for the API. The object type is HZ_SMS_CP_BO for the SMS business object. In addition to the object's
 * business object attributes, the object type also includes lower-level embedded child entities or objects that can
 * be simultaneously created.
 *
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_sms_obj The SMS business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The SMS business object that was created, returned as an output parameter
 * @param x_messages Messages returned from the creation of the business object
 * @param x_sms_id TCA identifier for the SMS business object
 * @param x_sms_os SMS original system name
 * @param x_sms_osr SMS original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter or both the px_parent_os and px_parent_osr parameters must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create SMS Business Object
 * @rep:doccd 120hztig.pdf Create SMS Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE create_sms_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_sms_obj             IN            HZ_SMS_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_SMS_CP_BO,
    x_sms_id              OUT NOCOPY    NUMBER,
    x_sms_os              OUT NOCOPY    VARCHAR2,
    x_sms_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY            VARCHAR2
  );

  -- PROCEDURE update_phone_bo
  --
  -- DESCRIPTION
  --     Update a logical phone contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_phone_obj          Phone business object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_phone_id           Contact point ID.
  --     x_phone_os           Contact point orig system.
  --     x_phone_osr          Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE update_phone_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_phone_obj           IN            HZ_PHONE_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_phone_id            OUT NOCOPY    NUMBER,
    x_phone_os            OUT NOCOPY    VARCHAR2,
    x_phone_osr           OUT NOCOPY    VARCHAR2
  );

/*#
 * Update Phone Business Object (update_phone_cp_bo)
 * Updates a Phone business object. You pass any modified object data to the procedure, packaged within an object type
 * defined specifically for the API. The object type is HZ_PHONE_CP_BO for the Phone business object. In addition to
 * the object's business object attributes, the object type also includes embedded child business entities or objects
 * that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param p_phone_obj The Phone business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Phone business object that was updated, returned as an output parameter
 * @param x_messages Messages returned from the update of the business object
 * @param x_phone_id TCA identifier for the Phone business object
 * @param x_phone_os Phone original system name
 * @param x_phone_osr Phone original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Phone Business Object
 * @rep:doccd 120hztig.pdf Update Phone Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE update_phone_bo(
    p_phone_obj           IN            HZ_PHONE_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PHONE_CP_BO,
    x_phone_id            OUT NOCOPY    NUMBER,
    x_phone_os            OUT NOCOPY    VARCHAR2,
    x_phone_osr           OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE update_telex_bo
  --
  -- DESCRIPTION
  --     Update a logical telex contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_telex_obj          Telex business object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_telex_id           Contact point ID.
  --     x_telex_os           Contact point orig system.
  --     x_telex_osr          Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE update_telex_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_telex_obj           IN            HZ_TELEX_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_telex_id            OUT NOCOPY    NUMBER,
    x_telex_os            OUT NOCOPY    VARCHAR2,
    x_telex_osr           OUT NOCOPY    VARCHAR2
  );

/*#
 * Update Telex Business Object (update_telex_bo)
 * Updates a Telex business object. You pass any modified object data to the procedure, packaged within an object type
 * defined specifically for the API. The object type is HZ_TELEX_CP_BO for the Telex business object. In addition to
 * the object's business object attributes, the object type also includes embedded child business entities or objects
 * that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param p_telex_obj The Telex business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Telex business object that was updated, returned as an output parameter
 * @param x_messages Messages returned from the update of the business object
 * @param x_telex_id TCA identifier for the Telex business object
 * @param x_telex_os Telex original system name
 * @param x_telex_osr Telex original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Telex Business Object
 * @rep:doccd 120hztig.pdf Update Telex Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE update_telex_bo(
    p_telex_obj           IN            HZ_TELEX_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_TELEX_CP_BO,
    x_telex_id            OUT NOCOPY    NUMBER,
    x_telex_os            OUT NOCOPY    VARCHAR2,
    x_telex_osr           OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE update_email_bo
  --
  -- DESCRIPTION
  --     Update a logical email contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_email_obj          Email business object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_email_id           Contact point ID.
  --     x_email_os           Contact point orig system.
  --     x_email_osr          Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE update_email_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_email_obj           IN            HZ_EMAIL_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_email_id            OUT NOCOPY    NUMBER,
    x_email_os            OUT NOCOPY    VARCHAR2,
    x_email_osr           OUT NOCOPY    VARCHAR2
  );

/*#
 * Update Email Business Object (update_email_bo)
 * Updates a Email business object. You pass any modified object data to the procedure, packaged within an object type
 * defined specifically for the API. The object type is HZ_EMIAL_CP_BO for the Email business object. In addition to the
 * object's business object attributes, the object type also includes embedded child business entities or objects that
 * can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param p_email_obj The Email business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Email business object that was updated, returned as an output parameter
 * @param x_messages Messages returned from the update of the business object
 * @param x_email_id TCA identifier for the Email business object
 * @param x_email_os Email original system name
 * @param x_email_osr Email original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Email Business Object
 * @rep:doccd 120hztig.pdf Update Email Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE update_email_bo(
    p_email_obj           IN            HZ_EMAIL_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_EMAIL_CP_BO,
    x_email_id            OUT NOCOPY    NUMBER,
    x_email_os            OUT NOCOPY    VARCHAR2,
    x_email_osr           OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE update_web_bo
  --
  -- DESCRIPTION
  --     Update a logical web contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_web_obj            Web business object.
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
  --     x_web_id             Contact point ID.
  --     x_web_os             Contact point orig system.
  --     x_web_osr            Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE update_web_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_web_obj             IN            HZ_WEB_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_web_id              OUT NOCOPY    NUMBER,
    x_web_os              OUT NOCOPY    VARCHAR2,
    x_web_osr             OUT NOCOPY    VARCHAR2
  );

/*#
 * Update Web Business Object (update_web_bo)
 * Updates a Web business object. You pass any modified object data to the procedure, packaged within an object type
 * defined specifically for the API. The object type is HZ_WEB_CP_BO for the Web business object. In addition to the
 * object's business object attributes, the object type also includes embedded child business entities or objects that
 * can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param p_web_obj The Web business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Web business object that was updated, returned as an output parameter
 * @param x_messages Messages returned from the update of the business object
 * @param x_web_id TCA identifier for the Web business object
 * @param x_web_os Web original system name
 * @param x_web_osr Web original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Web Business Object
 * @rep:doccd 120hztig.pdf Update Web Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE update_web_bo(
    p_web_obj             IN            HZ_WEB_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_WEB_CP_BO,
    x_web_id              OUT NOCOPY    NUMBER,
    x_web_os              OUT NOCOPY    VARCHAR2,
    x_web_osr             OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE update_edi_bo
  --
  -- DESCRIPTION
  --     Update a logical edi contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_edi_obj            EDI business object.
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
  --     x_edi_id             Contact point ID.
  --     x_edi_os             Contact point orig system.
  --     x_edi_osr            Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE update_edi_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_edi_obj             IN            HZ_EDI_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_edi_id              OUT NOCOPY    NUMBER,
    x_edi_os              OUT NOCOPY    VARCHAR2,
    x_edi_osr             OUT NOCOPY    VARCHAR2
  );

/*#
 * Update EDI Business Object (update_edi_bo)
 * Updates a EDI business object. You pass any modified object data to the procedure, packaged within an object type
 * defined specifically for the API. The object type is HZ_EDI_CP_BO for the EDI business object. In addition to the
 * object's business object attributes, the object type also includes embedded child business entities or objects that
 * can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param p_edi_obj The EDI business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The EDI business object that was updated, returned as an output parameter
 * @param x_messages Messages returned from the update of the business object
 * @param x_edi_id TCA identifier for the EDI business object
 * @param x_edi_os EDI original system name
 * @param x_edi_osr EDI original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update EDI Business Object
 * @rep:doccd 120hztig.pdf Update EDI Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE update_edi_bo(
    p_edi_obj             IN            HZ_EDI_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_EDI_CP_BO,
    x_edi_id              OUT NOCOPY    NUMBER,
    x_edi_os              OUT NOCOPY    VARCHAR2,
    x_edi_osr             OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE update_eft_bo
  --
  -- DESCRIPTION
  --     Update a logical eft contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_eft_obj            EFT business object.
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
  --     x_eft_id             Contact point ID.
  --     x_eft_os             Contact point orig system.
  --     x_eft_osr            Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE update_eft_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_eft_obj             IN            HZ_EFT_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_eft_id              OUT NOCOPY    NUMBER,
    x_eft_os              OUT NOCOPY    VARCHAR2,
    x_eft_osr             OUT NOCOPY    VARCHAR2
  );

/*#
 * Update EFT Business Object (update_eft_bo)
 * Updates a EFT business object. You pass any modified object data to the procedure, packaged within an object type
 * defined specifically for the API. The object type is HZ_EFT_CP_BO for the EFT business object. In addition to the
 * object's business object attributes, the object type also includes embedded child business entities or objects that
 * can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param p_eft_obj The EFT business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The EFT business object that was updated, returned as an output parameter
 * @param x_messages Messages returned from the update of the business object
 * @param x_eft_id TCA identifier for the EFT business object
 * @param x_eft_os EFT original system name
 * @param x_eft_osr EFT original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update EFT Business Object
 * @rep:doccd 120hztig.pdf Update EFT Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE update_eft_bo(
    p_eft_obj             IN            HZ_EFT_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_EFT_CP_BO,
    x_eft_id              OUT NOCOPY    NUMBER,
    x_eft_os              OUT NOCOPY    VARCHAR2,
    x_eft_osr             OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE update_sms_bo
  --
  -- DESCRIPTION
  --     Update a logical sms contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_sms_obj            SMS business object.
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
  --     x_sms_id             Contact point ID.
  --     x_sms_os             Contact point orig system.
  --     x_sms_osr            Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE update_sms_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_sms_obj             IN            HZ_SMS_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_sms_id              OUT NOCOPY    NUMBER,
    x_sms_os              OUT NOCOPY    VARCHAR2,
    x_sms_osr             OUT NOCOPY    VARCHAR2
  );

/*#
 * Update SMS Business Object (update_sms_bo)
 * Updates a SMS business object. You pass any modified object data to the procedure, packaged within an object type
 * defined specifically for the API. The object type is HZ_SMS_CP_BO for the SMS business object. In addition to the
 * object's business object attributes, the object type also includes embedded child business entities or objects that
 * can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param p_sms_obj The SMS business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The SMS business object that was updated, returned as an output parameter
 * @param x_messages Messages returned from the update of the business object
 * @param x_sms_id TCA identifier for the SMS business object
 * @param x_sms_os SMS original system name
 * @param x_sms_osr SMS original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update SMS Business Object
 * @rep:doccd 120hztig.pdf Update SMS Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE update_sms_bo(
    p_sms_obj             IN            HZ_SMS_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_SMS_CP_BO,
    x_sms_id              OUT NOCOPY    NUMBER,
    x_sms_os              OUT NOCOPY    VARCHAR2,
    x_sms_osr             OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_phone_bo
  --
  -- DESCRIPTION
  --     Create or update a logical phone contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_phone_obj          Phone business object.
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
  --     x_phone_id           Contact point ID.
  --     x_phone_os           Contact point orig system.
  --     x_phone_osr          Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_phone_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_phone_obj           IN            HZ_PHONE_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_phone_id            OUT NOCOPY    NUMBER,
    x_phone_os            OUT NOCOPY    VARCHAR2,
    x_phone_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

/*#
 * Save Phone Business Object (save_phone_cp_bo)
 * Saves a Phone business object. You pass new or modified object data to the procedure, packaged within an object type
 * defined specifically for the API. The API then determines if the object exists in TCA, based upon the provided
 * identification information, and creates or updates the object. The object type is HZ_PHONE_CP_BO for the Phone
 * business object. For either case, the object type that you provide will be processed as if the respective API procedure
 * is being called (create_phone_cp_bo or update_phone_cp_bo). Please see those procedures for more details. In addition to
 * the object's business object attributes, the object type also includes embedded child business entities or objects that
 * can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_phone_obj The Phone business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Phone business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_phone_id TCA identifier for the Phone business object
 * @param x_phone_os Phone original system name
 * @param x_phone_osr Phone original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter, or both the px_parent_os and px_parent_osr parameters, must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save Phone Business Object
 * @rep:doccd 120hztig.pdf Save Phone Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE save_phone_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_phone_obj           IN            HZ_PHONE_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PHONE_CP_BO,
    x_phone_id            OUT NOCOPY    NUMBER,
    x_phone_os            OUT NOCOPY    VARCHAR2,
    x_phone_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

  -- DESCRIPTION
  -- PROCEDURE save_telex_bo
  --
  -- DESCRIPTION
  --     Create or update a logical telex contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_telex_obj          Telex business object.
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
  --     x_telex_id           Contact point ID.
  --     x_telex_os           Contact point orig system.
  --     x_telex_osr          Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_telex_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_telex_obj           IN            HZ_TELEX_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_telex_id            OUT NOCOPY    NUMBER,
    x_telex_os            OUT NOCOPY    VARCHAR2,
    x_telex_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

/*#
 * Save Telex Business Object (save_telex_bo)
 * Saves a Telex business object. You pass new or modified object data to the procedure, packaged within an object type
 * defined specifically for the API. The API then determines if the object exists in TCA, based upon the provided
 * identification information, and creates or updates the object. The object type is HZ_TELEX_CP_BO for the Telex
 * business object. For either case, the object type that you provide will be processed as if the respective API procedure
 * is being called (create_telex_bo or update_telex_bo). Please see those procedures for more details. In addition to
 * the object's business object attributes, the object type also includes embedded child business entities or objects
 * that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_telex_obj The Telex business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Telex business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_telex_id TCA identifier for the Telex business object
 * @param x_telex_os Telex original system name
 * @param x_telex_osr Telex original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter, or both the px_parent_os and px_parent_osr parameters, must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save Telex Business Object
 * @rep:doccd 120hztig.pdf Save Telex Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE save_telex_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_telex_obj           IN            HZ_TELEX_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_TELEX_CP_BO,
    x_telex_id            OUT NOCOPY    NUMBER,
    x_telex_os            OUT NOCOPY    VARCHAR2,
    x_telex_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE save_email_bo
  --
  -- DESCRIPTION
  --     Create or update a logical email contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_email_obj          Email business object.
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
  --     x_email_id           Contact point ID.
  --     x_email_os           Contact point orig system.
  --     x_email_osr          Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_email_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_email_obj           IN            HZ_EMAIL_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_email_id            OUT NOCOPY    NUMBER,
    x_email_os            OUT NOCOPY    VARCHAR2,
    x_email_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

/*#
 * Save Email Business Object (save_email_bo)
 * Saves a Email business object. You pass new or modified object data to the procedure, packaged within an object type
 * defined specifically for the API. The API then determines if the object exists in TCA, based upon the provided
 * identification information, and creates or updates the object. The object type is HZ_EMIAL_CP_BO for the Email
 * business object. For either case, the object type that you provide will be processed as if the respective API procedure
 * is being called (create_email_bo or update_email_bo). Please see those procedures for more details. In addition to
 * the object's business object attributes, the object type also includes embedded child business entities or objects
 * that can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_email_obj The Email business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Email business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_email_id TCA identifier for the Email business object
 * @param x_email_os Email original system name
 * @param x_email_osr Email original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter, or both the px_parent_os and px_parent_osr parameters, must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save Email Business Object
 * @rep:doccd 120hztig.pdf Save Email Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE save_email_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_email_obj           IN            HZ_EMAIL_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_EMAIL_CP_BO,
    x_email_id            OUT NOCOPY    NUMBER,
    x_email_os            OUT NOCOPY    VARCHAR2,
    x_email_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE save_web_bo
  --
  -- DESCRIPTION
  --     Create or update a logical web contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_web_obj            Web business object.
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
  --     x_web_id             Contact point ID.
  --     x_web_os             Contact point orig system.
  --     x_web_osr            Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_web_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_web_obj             IN            HZ_WEB_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_web_id              OUT NOCOPY    NUMBER,
    x_web_os              OUT NOCOPY    VARCHAR2,
    x_web_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

/*#
 * Save Web Business Object (save_web_bo)
 * Saves a Web business object. You pass new or modified object data to the procedure, packaged within an object type
 * defined specifically for the API. The API then determines if the object exists in TCA, based upon the provided
 * identification information, and creates or updates the object. The object type is HZ_WEB_CP_BO for the Web business
 * object. For either case, the object type that you provide will be processed as if the respective API procedure is
 * being called (create_web_bo or update_web_bo). Please see those procedures for more details. In addition to the
 * object's business object attributes, the object type also includes embedded child business entities or objects that
 * can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_web_obj The Web business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Web business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_web_id TCA identifier for the Web business object
 * @param x_web_os Web original system name
 * @param x_web_osr Web original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter, or both the px_parent_os and px_parent_osr parameters, must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save Web Business Object
 * @rep:doccd 120hztig.pdf Save Web Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE save_web_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_web_obj             IN            HZ_WEB_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_WEB_CP_BO,
    x_web_id              OUT NOCOPY    NUMBER,
    x_web_os              OUT NOCOPY    VARCHAR2,
    x_web_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE save_edi_bo
  --
  -- DESCRIPTION
  --     Create or update a logical edi contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_edi_obj            EDI business object.
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
  --     x_edi_id             Contact point ID.
  --     x_edi_os             Contact point orig system.
  --     x_edi_osr            Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_edi_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_edi_obj             IN            HZ_EDI_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_edi_id              OUT NOCOPY    NUMBER,
    x_edi_os              OUT NOCOPY    VARCHAR2,
    x_edi_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

/*#
 * Save EDI Business Object (save_edi_bo)
 * Saves a EDI business object. You pass new or modified object data to the procedure, packaged within an object type
 * defined specifically for the API. The API then determines if the object exists in TCA, based upon the provided
 * identification information, and creates or updates the object. The object type is HZ_EDI_CP_BO for the EDI business
 * object. For either case, the object type that you provide will be processed as if the respective API procedure is
 * being called (create_edi_bo or update_edi_bo). Please see those procedures for more details. In addition to the
 * object's business object attributes, the object type also includes embedded child business entities or objects that
 * can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_edi_obj The EDI business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The EDI business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_edi_id TCA identifier for the EDI business object
 * @param x_edi_os EDI original system name
 * @param x_edi_osr EDI original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter, or both the px_parent_os and px_parent_osr parameters, must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save EDI Business Object
 * @rep:doccd 120hztig.pdf Save EDI Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE save_edi_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_edi_obj             IN            HZ_EDI_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_EDI_CP_BO,
    x_edi_id              OUT NOCOPY    NUMBER,
    x_edi_os              OUT NOCOPY    VARCHAR2,
    x_edi_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE save_eft_bo
  --
  -- DESCRIPTION
  --     Create or update a logical eft contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_eft_obj            EFT business object.
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
  --     x_eft_id             Contact point ID.
  --     x_eft_os             Contact point orig system.
  --     x_eft_osr            Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_eft_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_eft_obj             IN            HZ_EFT_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_eft_id              OUT NOCOPY    NUMBER,
    x_eft_os              OUT NOCOPY    VARCHAR2,
    x_eft_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

/*#
 * Save EFT Business Object (save_eft_bo)
 * Saves a EFT business object. You pass new or modified object data to the procedure, packaged within an object type
 * defined specifically for the API. The API then determines if the object exists in TCA, based upon the provided
 * identification information, and creates or updates the object. The object type is HZ_EFT_CP_BO for the EFT business
 * object. For either case, the object type that you provide will be processed as if the respective API procedure is
 * being called (create_eft_bo or update_eft_bo). Please see those procedures for more details. In addition to the
 * object's business object attributes, the object type also includes embedded child business entities or objects that
 * can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_eft_obj The EFT business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The EFT business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_eft_id TCA identifier for the EFT business object
 * @param x_eft_os EFT original system name
 * @param x_eft_osr EFT original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter, or both the px_parent_os and px_parent_osr parameters, must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save EFT Business Object
 * @rep:doccd 120hztig.pdf Save EFT Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE save_eft_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_eft_obj             IN            HZ_EFT_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_EFT_CP_BO,
    x_eft_id              OUT NOCOPY    NUMBER,
    x_eft_os              OUT NOCOPY    VARCHAR2,
    x_eft_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE save_sms_bo
  --
  -- DESCRIPTION
  --     Create or update a logical sms contact point.
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_sms_obj            SMS business object.
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
  --     x_sms_id             Contact point ID.
  --     x_sms_os             Contact point orig system.
  --     x_sms_osr            Contact point orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_sms_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_sms_obj             IN            HZ_SMS_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_sms_id              OUT NOCOPY    NUMBER,
    x_sms_os              OUT NOCOPY    VARCHAR2,
    x_sms_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

/*#
 * Save SMS Business Object (save_sms_bo)
 * Saves a SMS business object. You pass new or modified object data to the procedure, packaged within an object type
 * defined specifically for the API. The API then determines if the object exists in TCA, based upon the provided
 * identification information, and creates or updates the object. The object type is HZ_SMS_CP_BO for the SMS business
 * object. For either case, the object type that you provide will be processed as if the respective API procedure is
 * being called (create_sms_bo or update_sms_bo). Please see those procedures for more details. In addition to the
 * object's business object attributes, the object type also includes embedded child business entities or objects that
 * can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_sms_obj The SMS business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The SMS business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_sms_id TCA identifier for the SMS business object
 * @param x_sms_os SMS original system name
 * @param x_sms_osr SMS original system reference
 * @param px_parent_id TCA identifier for parent object. Either this parameter, or both the px_parent_os and px_parent_osr parameters, must be given
 * @param px_parent_os Parent object original system name
 * @param px_parent_osr Parent object original system reference
 * @param px_parent_obj_type Parent object type. Validated against HZ_BUSINESS_OBJECTS lookup type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save SMS Business Object
 * @rep:doccd 120hztig.pdf Save SMS Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE save_sms_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_sms_obj             IN            HZ_SMS_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_SMS_CP_BO,
    x_sms_id              OUT NOCOPY    NUMBER,
    x_sms_os              OUT NOCOPY    VARCHAR2,
    x_sms_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  );

/*
The Get Contact Point API Procedures are retrieval services that return a full Contact Point business object of the type specified.
The user identifies a particular Contact Point business object using the TCA identifier and/or the objects Source System information.
Upon proper validation of the object, the full Contact Point business object is returned. The object consists of all data included
within the Contact Point business object, at all embedded levels. This includes the set of all data stored in the TCA tables for each
embedded entity.

To retrieve the appropriate embedded entities within the Contact Point business objects, the Get procedure returns all records for the
particular object from these TCA entity tables.

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments

Contact Point		Y	N	HZ_CONTACT_POINTS
Contact Preference	N	Y	HZ_CONTACT_PREFERENCES

*/


  --------------------------------------
  --
  -- PROCEDURE get_phone_bo
  --
  -- DESCRIPTION
  --     Get a logical phone.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_phone_id         phone ID.If this id passed in, return only one phone obj.
  --     p_phone_os           phone orig system.
  --     p_phone_osr          phone orig system reference.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_phone_obj         Logical phone record.
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
  --   30-May-2005   AWU                Created.
  --


PROCEDURE get_phone_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_phone_id			IN	NUMBER,
	p_phone_os			IN	VARCHAR2,
	p_phone_osr			IN	VARCHAR2,
	x_phone_obj			OUT NOCOPY	HZ_PHONE_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2
);

/*#
 * Get Phone Business Object (get_phone_cp_bo)
 * Extracts a particular Phone business object from TCA. You pass the object's identification information to the procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_phone_id TCA identifier for the Phone business object
 * @param p_phone_os Phone original system name
 * @param p_phone_osr Phone original system reference
 * @param x_phone_obj The retrieved Phone business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Phone Business Object
 * @rep:doccd 120hztig.pdf Get Phone Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_phone_bo (
        p_phone_id                      IN      NUMBER,
        p_phone_os                      IN      VARCHAR2,
        p_phone_osr                     IN      VARCHAR2,
        x_phone_obj                     OUT NOCOPY      HZ_PHONE_CP_BO,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_messages                      OUT NOCOPY      HZ_MESSAGE_OBJ_TBL
);

 --------------------------------------
  --
  -- PROCEDURE get_telex_bo
  --
  -- DESCRIPTION
  --     Get a logical telex.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_telex_id         telex ID.If this id passed in, return only one telex obj.
  --     p_telex_os           telex orig system.
  --     p_telex_osr          telex orig system reference.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_telex_obj         Logical telex record.
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
  --   30-May-2005   AWU                Created.
  --


PROCEDURE get_telex_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_telex_id			IN	NUMBER,
	p_telex_os			IN	VARCHAR2,
	p_telex_osr			IN	VARCHAR2,
	x_telex_obj			OUT NOCOPY	HZ_TELEX_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2
);

/*#
 * Get Telex Business Object (get_telex_bo)
 * Extracts a particular Telex business object from TCA. You pass the object's identification information to the procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_telex_id TCA identifier for the Telex business object
 * @param p_telex_os Telex original system name
 * @param p_telex_osr Telex original system reference
 * @param x_telex_obj The retrieved Telex business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Telex Business Object
 * @rep:doccd 120hztig.pdf Get Telex Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_telex_bo (
        p_telex_id                      IN      NUMBER,
        p_telex_os                      IN      VARCHAR2,
        p_telex_osr                     IN      VARCHAR2,
        x_telex_obj                     OUT NOCOPY      HZ_TELEX_CP_BO,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_messages                      OUT NOCOPY      HZ_MESSAGE_OBJ_TBL
);

 --------------------------------------
  --
  -- PROCEDURE get_email_bo
  --
  -- DESCRIPTION
  --     Get a logical email.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_email_id         email ID.If this id passed in, return only one email obj.
  --     p_email_os           email orig system.
  --     p_email_osr          email orig system reference.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_email_obj         Logical email record.
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
  --   30-May-2005   AWU                Created.
  --


PROCEDURE get_email_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_email_id			IN	NUMBER,
	p_email_os			IN	VARCHAR2,
	p_email_osr			IN	VARCHAR2,
	x_email_obj			OUT NOCOPY	HZ_EMAIL_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2
);

/*#
 * Get Email Business Object (get_email_bo)
 * Extracts a particular Email business object from TCA. You pass the object's identification information to the procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_email_id TCA identifier for the Email business object
 * @param p_email_os Email original system name
 * @param p_email_osr Email original system reference
 * @param x_email_obj The retrieved Email business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Email Business Object
 * @rep:doccd 120hztig.pdf Get Email Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_email_bo (
        p_email_id                      IN      NUMBER,
        p_email_os                      IN      VARCHAR2,
        p_email_osr                     IN      VARCHAR2,
        x_email_obj                     OUT NOCOPY      HZ_EMAIL_CP_BO,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_messages                      OUT NOCOPY      HZ_MESSAGE_OBJ_TBL
);

 --------------------------------------
  --
  -- PROCEDURE get_web_bo
  --
  -- DESCRIPTION
  --     Get a logical web.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_web_id         web ID.If this id passed in, return only one web obj.
  --     p_web_os           web orig system.
  --     p_web_osr          web orig system reference.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_web_obj         Logical web record.
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
  --   30-May-2005   AWU                Created.
  --


PROCEDURE get_web_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_web_id			IN	NUMBER,
	p_web_os			IN	VARCHAR2,
	p_web_osr			IN	VARCHAR2,
	x_web_obj			OUT NOCOPY	HZ_WEB_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2
);

/*#
 * Get Web Business Object (get_web_bo)
 * Extracts a particular Web business object from TCA. You pass the object's identification information to the procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_web_id TCA identifier for the Web business object
 * @param p_web_os Web original system name
 * @param p_web_osr Web original system reference
 * @param x_web_obj The retrieved Web business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Web Business Object
 * @rep:doccd 120hztig.pdf Get Web Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_web_bo (
        p_web_id                        IN      NUMBER,
        p_web_os                        IN      VARCHAR2,
        p_web_osr                       IN      VARCHAR2,
        x_web_obj                       OUT NOCOPY      HZ_WEB_CP_BO,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_messages                      OUT NOCOPY      HZ_MESSAGE_OBJ_TBL
);

 --------------------------------------
  --
  -- PROCEDURE get_edi_bo
  --
  -- DESCRIPTION
  --     Get a logical edi.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_edi_id         edi ID.If this id passed in, return only one edi obj.
  --     p_edi_os           edi orig system.
  --     p_edi_osr          edi orig system reference.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_edi_obj         Logical edi record.
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
  --   30-May-2005   AWU                Created.
  --


PROCEDURE get_edi_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_edi_id			IN	NUMBER,
	p_edi_os			IN	VARCHAR2,
	p_edi_osr			IN	VARCHAR2,
	x_edi_obj			OUT NOCOPY	HZ_EDI_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2
);

/*#
 * Get EDI Business Object (get_edi_bo)
 * Extracts a particular EDI business object from TCA. You pass the object's identification information to the procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_edi_id TCA identifier for the EDI business object
 * @param p_edi_os EDI original system name
 * @param p_edi_osr EDI original system reference
 * @param x_edi_obj The retrieved EDI business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get EDI Business Object
 * @rep:doccd 120hztig.pdf Get EDI Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_edi_bo (
        p_edi_id                        IN      NUMBER,
        p_edi_os                        IN      VARCHAR2,
        p_edi_osr                       IN      VARCHAR2,
        x_edi_obj                       OUT NOCOPY      HZ_EDI_CP_BO,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_messages                      OUT NOCOPY      HZ_MESSAGE_OBJ_TBL
);

 --------------------------------------
  --
  -- PROCEDURE get_eft_bo
  --
  -- DESCRIPTION
  --     Get a logical eft.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_eft_id         eft ID.If this id passed in, return only one eft obj.
  --     p_eft_os           eft orig system.
  --     p_eft_osr          eft orig system reference.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_eft_obj         Logical eft record.
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
  --   30-May-2005   AWU                Created.
  --


PROCEDURE get_eft_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_eft_id			IN	NUMBER,
	p_eft_os			IN	VARCHAR2,
	p_eft_osr			IN	VARCHAR2,
	x_eft_obj			OUT NOCOPY	HZ_EFT_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2
);

/*#
 * Get EFT Business Object (get_eft_bo)
 * Extracts a particular EFT business object from TCA. You pass the object's identification information to the procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_eft_id TCA identifier for the EFT business object
 * @param p_eft_os EFT original system name
 * @param p_eft_osr EFT original system reference
 * @param x_eft_obj The retrieved EFT business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get EFT Business Object
 * @rep:doccd 120hztig.pdf Get EFT Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_eft_bo (
        p_eft_id                        IN      NUMBER,
        p_eft_os                        IN      VARCHAR2,
        p_eft_osr                       IN      VARCHAR2,
        x_eft_obj                       OUT NOCOPY      HZ_EFT_CP_BO,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_messages                      OUT NOCOPY      HZ_MESSAGE_OBJ_TBL
);

 --------------------------------------
  --
  -- PROCEDURE get_sms_bo
  --
  -- DESCRIPTION
  --     Get a logical sms.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_sms_id         sms ID.If this id passed in, return only one sms obj.
  --     p_sms_os           sms orig system.
  --     p_sms_osr          sms orig system reference.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_sms_objs         Logical sms records.
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
  --   30-May-2005   AWU                Created.
  --


PROCEDURE get_sms_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_sms_id			IN	NUMBER,
	p_sms_os			IN	VARCHAR2,
	p_sms_osr			IN	VARCHAR2,
	x_sms_obj			OUT NOCOPY	HZ_SMS_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2
);

/*#
 * Get SMS Business Object (get_sms_bo)
 * Extracts a particular SMS business object from TCA. You pass the object's identification information to the procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_sms_id TCA identifier for the SMS business object
 * @param p_sms_os SMS original system name
 * @param p_sms_osr SMS original system reference
 * @param x_sms_obj The retrieved SMS business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get SMS Business Object
 * @rep:doccd 120hztig.pdf Get SMS Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_sms_bo (
        p_sms_id                        IN      NUMBER,
        p_sms_os                        IN      VARCHAR2,
        p_sms_osr                       IN      VARCHAR2,
        x_sms_obj                       OUT NOCOPY      HZ_SMS_CP_BO,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_messages                      OUT NOCOPY      HZ_MESSAGE_OBJ_TBL
);

  PROCEDURE do_create_contact_point(
    p_init_msg_list                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_validate_bo_flag                IN     VARCHAR2 := FND_API.G_TRUE,
    p_cp_id                           IN     NUMBER,
    p_cp_os                           IN     VARCHAR2,
    p_cp_osr                          IN     VARCHAR2,
    p_phone_obj                       IN HZ_PHONE_CP_BO,
    p_email_obj                       IN HZ_EMAIL_CP_BO,
    p_telex_obj                       IN HZ_TELEX_CP_BO,
    p_web_obj                         IN HZ_WEB_CP_BO,
    p_edi_obj                         IN HZ_EDI_CP_BO,
    p_eft_obj                         IN HZ_EFT_CP_BO,
    p_sms_obj                         IN HZ_SMS_CP_BO,
    p_cp_pref_objs                    IN OUT NOCOPY    HZ_CONTACT_PREF_OBJ_TBL,
    p_cp_type                         IN     VARCHAR2,
    p_created_by_module               IN     VARCHAR2,
    p_obj_source                      IN     VARCHAR2 := null,
    x_return_status                   OUT    NOCOPY VARCHAR2,
    x_msg_count                       OUT    NOCOPY NUMBER,
    x_msg_data                        OUT    NOCOPY VARCHAR2,
    x_cp_id                           OUT    NOCOPY NUMBER,
    x_cp_os                           OUT    NOCOPY VARCHAR2,
    x_cp_osr                          OUT    NOCOPY VARCHAR2,
    px_parent_id                      IN OUT NOCOPY NUMBER,
    px_parent_os                      IN OUT NOCOPY VARCHAR2,
    px_parent_osr                     IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type                IN OUT NOCOPY VARCHAR2
  );

 PROCEDURE do_update_contact_point (
    p_init_msg_list                   IN     VARCHAR2:= FND_API.G_FALSE,
    p_cp_id                           IN     NUMBER,
    p_cp_os                           IN     VARCHAR2,
    p_cp_osr                          IN     VARCHAR2,
    p_phone_obj                       IN HZ_PHONE_CP_BO,
    p_email_obj                       IN HZ_EMAIL_CP_BO,
    p_telex_obj                       IN HZ_TELEX_CP_BO,
    p_web_obj                         IN HZ_WEB_CP_BO,
    p_edi_obj                         IN HZ_EDI_CP_BO,
    p_eft_obj                         IN HZ_EFT_CP_BO,
    p_sms_obj                         IN HZ_SMS_CP_BO,
    p_cp_pref_objs                    IN OUT NOCOPY    HZ_CONTACT_PREF_OBJ_TBL,
    p_cp_type                         IN     VARCHAR2,
    p_created_by_module               IN     VARCHAR2,
    p_obj_source                      IN     VARCHAR2 := null,
    x_return_status                   OUT    NOCOPY VARCHAR2,
    x_msg_count                       OUT    NOCOPY NUMBER,
    x_msg_data                        OUT    NOCOPY VARCHAR2,
    x_cp_id                           OUT    NOCOPY NUMBER,
    x_cp_os                           OUT    NOCOPY VARCHAR2,
    x_cp_osr                          OUT    NOCOPY VARCHAR2,
    p_parent_os                       IN     VARCHAR2
  );

  PROCEDURE do_save_contact_point (
    p_init_msg_list              IN     VARCHAR2:= FND_API.G_FALSE,
    p_validate_bo_flag           IN     VARCHAR2 := fnd_api.g_true,
    p_cp_id                      IN     NUMBER,
    p_cp_os                      IN     VARCHAR2,
    p_cp_osr                     IN     VARCHAR2,
    p_phone_obj                  IN HZ_PHONE_CP_BO,
    p_email_obj                  IN HZ_EMAIL_CP_BO,
    p_telex_obj                  IN HZ_TELEX_CP_BO,
    p_web_obj                    IN HZ_WEB_CP_BO,
    p_edi_obj                    IN HZ_EDI_CP_BO,
    p_eft_obj                    IN HZ_EFT_CP_BO,
    p_sms_obj                    IN HZ_SMS_CP_BO,
    p_cp_pref_objs               IN OUT NOCOPY    HZ_CONTACT_PREF_OBJ_TBL,
    p_cp_type                    IN     VARCHAR2,
    p_created_by_module          IN     VARCHAR2,
    p_obj_source                      IN     VARCHAR2 := null,
    x_return_status              OUT    NOCOPY VARCHAR2,
    x_msg_count                  OUT    NOCOPY NUMBER,
    x_msg_data                   OUT    NOCOPY VARCHAR2,
    x_cp_id                      OUT    NOCOPY NUMBER,
    x_cp_os                      OUT    NOCOPY VARCHAR2,
    x_cp_osr                     OUT    NOCOPY VARCHAR2,
    px_parent_id                 IN OUT NOCOPY NUMBER,
    px_parent_os                 IN OUT NOCOPY VARCHAR2,
    px_parent_osr                IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type           IN OUT NOCOPY VARCHAR2
  );

END HZ_CONTACT_POINT_BO_PUB;

 

/

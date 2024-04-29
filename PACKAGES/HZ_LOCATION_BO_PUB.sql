--------------------------------------------------------
--  DDL for Package HZ_LOCATION_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_LOCATION_BO_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHBLCBS.pls 120.4 2006/09/21 17:59:56 acng noship $ */
/*#
 * Location Business Object API
 * Public API that allows users to manage Location business objects in the Trading Community Architecture. Several
 * operations are supported, including the creation and update of the business object.
 *
 * @rep:scope public
 * @rep:product HZ
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY HZ_ADDRESS
 * @rep:displayname Location Business Object API
 * @rep:doccd 120hztig.pdf Location Business Object API, Oracle Trading Community Architecture Technical Implementation Guide
 */

  -- PROCEDURE create_location_bo
  --
  -- DESCRIPTION
  --     Create a location business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_validate_bo_flag   If it is set to FND_API.G_TRUE, validate
  --                          the completeness of business object.
  --     p_location_obj       Location business object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_location_id        Location ID.
  --     x_location_os        Location orig system.
  --     x_location_osr       Location orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE create_location_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_location_obj        IN            HZ_LOCATION_OBJ,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_location_id         OUT NOCOPY    NUMBER,
    x_location_os         OUT NOCOPY    VARCHAR2,
    x_location_osr        OUT NOCOPY    VARCHAR2
  );

/*#
 * Create Location Business Object (create_location_bo)
 * Creates a Location business object. You pass object data to the procedure, packaged within an object type defined
 * specifically for the API. The object type is HZ_LOCATION_OBJ for the Location business object. In addition to the
 * object's business object attributes, the object type also includes lower-level embedded child entities or objects
 * that can be simultaneously created.
 *
 * @param p_return_obj_flag Indicates if the created object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness. Default value: true
 * @param p_location_obj The Location business object to be created in its entirety
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Location business object that was created, returned as an output parameter
 * @param x_messages Messages returned from the creation of the business object
 * @param x_location_id TCA identifier for the Location business object
 * @param x_location_os Location original system name
 * @param x_location_osr Location original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Location Business Object
 * @rep:doccd 120hztig.pdf Create Location Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE create_location_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_location_obj        IN            HZ_LOCATION_OBJ,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag     IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_LOCATION_OBJ,
    x_location_id         OUT NOCOPY    NUMBER,
    x_location_os         OUT NOCOPY    VARCHAR2,
    x_location_osr        OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE update_location_bo
  --
  -- DESCRIPTION
  --     Update a location business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_location_obj       Location business object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_location_id        Location ID.
  --     x_location_os        Location orig system.
  --     x_location_osr       Location orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE update_location_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_location_obj        IN            HZ_LOCATION_OBJ,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_location_id         OUT NOCOPY    NUMBER,
    x_location_os         OUT NOCOPY    VARCHAR2,
    x_location_osr        OUT NOCOPY    VARCHAR2
  );

/*#
 * Update Location Business Object (update_location_bo)
 * Updates a Location business object. You pass any modified object data to the procedure, packaged within an object type
 * defined specifically for the API. The object type is HZ_LOCATION_OBJ for the Location business object. In addition to
 * the object's business object attributes, the object type also includes embedded child business entities or objects that
 * can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the updated object is to be returned to the caller as an output parameter. Default value: false
 * @param p_location_obj The Location business object to be updated
 * @param p_created_by_module The module updating this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Location business object that was updated, returned as an output parameter
 * @param x_messages Messages returned from the update of the business object
 * @param x_location_id TCA identifier for the Location business object
 * @param x_location_os Location original system name
 * @param x_location_osr Location original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Location Business Object
 * @rep:doccd 120hztig.pdf Update Location Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE update_location_bo(
    p_location_obj        IN            HZ_LOCATION_OBJ,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag     IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_LOCATION_OBJ,
    x_location_id         OUT NOCOPY    NUMBER,
    x_location_os         OUT NOCOPY    VARCHAR2,
    x_location_osr        OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_location_bo
  --
  -- DESCRIPTION
  --     Create or update a location business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_location_obj       Location business object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_location_id        Location ID.
  --     x_location_os        Location orig system.
  --     x_location_osr       Location orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE save_location_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_location_obj        IN            HZ_LOCATION_OBJ,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_location_id         OUT NOCOPY    NUMBER,
    x_location_os         OUT NOCOPY    VARCHAR2,
    x_location_osr        OUT NOCOPY    VARCHAR2
  );

/*#
 * Save Location Business Object (save_location_bo)
 * Saves a Location business object. You pass new or modified object data to the procedure, packaged within an object type
 * defined specifically for the API. The API then determines if the object exists in TCA, based upon the provided
 * identification information, and creates or updates the object. The object type is HZ_LOCATION_OBJ for the Location
 * business object. For either case, the object type that you provide will be processed as if the respective API procedure
 * is being called (create_location_bo or update_location_bo). Please see those procedures for more details. In addition to
 * the object's business object attributes, the object type also includes embedded child business entities or objects that
 * can be simultaneously created or updated.
 *
 * @param p_return_obj_flag Indicates if the saved object is to be returned to the caller as an output parameter. Default value: false
 * @param p_validate_bo_flag Indicates if the passed business object is to be validated for completeness if it is being created
 * @param p_location_obj The Location business object to be saved
 * @param p_created_by_module The module saving this business object
 * @param p_obj_source The source of this business object
 * @param x_return_status Return status after the call
 * @param x_return_obj The Location business object that was saved, returned as an output parameter
 * @param x_messages Messages returned from the save of the business object
 * @param x_location_id TCA identifier for the Location business object
 * @param x_location_os Location original system name
 * @param x_location_osr Location original system reference
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Save Location Business Object
 * @rep:doccd 120hztig.pdf Save Location Business Object, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE save_location_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_location_obj        IN            HZ_LOCATION_OBJ,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag     IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_LOCATION_OBJ,
    x_location_id         OUT NOCOPY    NUMBER,
    x_location_os         OUT NOCOPY    VARCHAR2,
    x_location_osr        OUT NOCOPY    VARCHAR2
  );

 --------------------------------------
  --
  -- PROCEDURE get_location_bo
  --
  -- DESCRIPTION
  --     Get a logical location.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to  FND_API.G_TRUE. Default is FND_API.G_FALSE.
 --      p_location_id        location ID. If this id is not passed in, multiple site objects will be returned.
  --     p_location_os        location orig system.
  --     p_location_osr       location orig system reference.
  --   OUT:
  --     x_location_objs         Logical location records.
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
  --   2-NOV-2005   Arnold Ng          Created.
  --

/*
The Get location API Procedure is a retrieval service that returns a full location business object.
The user identifies a particular location business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full location business object is returned. The object consists of all data included within
the location business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the location business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

To retrieve the appropriate embedded entities within the location business object,
the Get procedure returns all records for the particular location from these TCA entity tables:

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Location		Y		N	HZ_LOCATIONS
*/

PROCEDURE get_location_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_location_id		IN	NUMBER,
	p_location_os		IN	VARCHAR2,
	p_location_osr	        IN      VARCHAR2,
	x_location_obj  	OUT NOCOPY	HZ_LOCATION_OBJ,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
);

/*#
 * Get Location Business Object (get_location_bo)
 * Extracts a particular Location business object from TCA. You pass the object's identification information to the
 * procedure, and the procedure returns the identified business object as it exists in TCA.
 *
 * @param p_location_id TCA identifier for the Location business object
 * @param p_location_os Location original system name
 * @param p_location_osr Location original system reference
 * @param x_location_obj The retrieved Location business object
 * @param x_return_status Return status after the call
 * @param x_messages Messages returned from the retrieval of the business object
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Location Business Object
 */
PROCEDURE get_location_bo (
        p_location_id           IN      NUMBER,
        p_location_os           IN      VARCHAR2,
        p_location_osr          IN      VARCHAR2,
        x_location_obj          OUT NOCOPY      HZ_LOCATION_OBJ,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_messages              OUT NOCOPY      HZ_MESSAGE_OBJ_TBL
);

  -- PUBLIC PROCEDURE assign_location_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from location object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_location_obj       Location object.
  --     p_loc_os             Location original system.
  --     p_loc_osr            Location original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN/OUT:
  --     px_location_rec      Location plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   02-NOV-2005    Arnold Ng          Created.
  --

  PROCEDURE assign_location_rec(
    p_location_obj               IN            HZ_LOCATION_OBJ,
    p_loc_os                     IN            VARCHAR2,
    p_loc_osr                    IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_location_rec              IN OUT NOCOPY HZ_LOCATION_V2PUB.LOCATION_REC_TYPE
  );

END HZ_LOCATION_BO_PUB;

 

/

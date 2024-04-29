--------------------------------------------------------
--  DDL for Package HZ_LOCATION_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_LOCATION_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2LOSS.pls 120.10 2006/08/17 10:14:08 idali noship $ */
/*#
 * This package contains the public APIs for locations.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Location
 * @rep:category BUSINESS_ENTITY HZ_ADDRESS
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Location APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */

--------------------------------------
-- declaration of record type
--------------------------------------

  hz_geometry_default            CONSTANT mdsys.sdo_geometry :=
                            mdsys.sdo_geometry(fnd_api.g_miss_num,
                                               fnd_api.g_miss_num, NULL, NULL, NULL);
  geometry_status_code_default   CONSTANT VARCHAR2(30) := 'DIRTY';

  -- Bug 2197181:: Added the constant for Mix-N-Match project to reduce the dependencies.

  g_miss_content_source_type     CONSTANT VARCHAR2(30) := 'USER_ENTERED';

  TYPE location_rec_type IS RECORD(
    location_id                  NUMBER,
    orig_system_reference        VARCHAR2(240),
    orig_system			 VARCHAR2(30),
    country                      VARCHAR2(60),
    address1                     VARCHAR2(240),
    address2                     VARCHAR2(240),
    address3                     VARCHAR2(240),
    address4                     VARCHAR2(240),
    city                         VARCHAR2(60),
    postal_code                  VARCHAR2(60),
    state                        VARCHAR2(60),
    province                     VARCHAR2(60),
    county                       VARCHAR2(60),
    address_key                  VARCHAR2(500),
    address_style                VARCHAR2(30),
    validated_flag               VARCHAR2(1),
    address_lines_phonetic       VARCHAR2(560),
    po_box_number                VARCHAR2(50),
    house_number                 VARCHAR2(50),
    street_suffix                VARCHAR2(50),
    street                       VARCHAR2(50),
    street_number                VARCHAR2(50),
    floor                        VARCHAR2(50),
    suite                        VARCHAR2(50),
    postal_plus4_code            VARCHAR2(10),
    position                     VARCHAR2(50),
    location_directions          VARCHAR2(640),
    address_effective_date       DATE,
    address_expiration_date      DATE,
    clli_code                    VARCHAR2(60),
    language                     VARCHAR2(4) ,
    short_description            VARCHAR2(240),
    description                  VARCHAR2(2000),
    geometry                     mdsys.sdo_geometry := hz_geometry_default,
    geometry_status_code         VARCHAR2(30) := geometry_status_code_default,
    loc_hierarchy_id             NUMBER,
    sales_tax_geocode            VARCHAR2(30),
    sales_tax_inside_city_limits VARCHAR2(30),
    fa_location_id               NUMBER,
    content_source_type          VARCHAR2(30) := g_miss_content_source_type,
    attribute_category           VARCHAR2(30) ,
    attribute1                   VARCHAR2(150),
    attribute2                   VARCHAR2(150),
    attribute3                   VARCHAR2(150),
    attribute4                   VARCHAR2(150),
    attribute5                   VARCHAR2(150),
    attribute6                   VARCHAR2(150),
    attribute7                   VARCHAR2(150),
    attribute8                   VARCHAR2(150),
    attribute9                   VARCHAR2(150),
    attribute10                  VARCHAR2(150),
    attribute11                  VARCHAR2(150),
    attribute12                  VARCHAR2(150),
    attribute13                  VARCHAR2(150),
    attribute14                  VARCHAR2(150),
    attribute15                  VARCHAR2(150),
    attribute16                  VARCHAR2(150),
    attribute17                  VARCHAR2(150),
    attribute18                  VARCHAR2(150),
    attribute19                  VARCHAR2(150),
    attribute20                  VARCHAR2(150),
    timezone_id                  NUMBER,
    created_by_module            VARCHAR2(150),
    application_id               NUMBER,
    actual_content_source        VARCHAR2(30),
    -- Bug 2670546
    delivery_point_code          VARCHAR2(50)
  );

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_location
 *
 * DESCRIPTION
 *     Creates location.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_location_rec                 Location record.
 *   IN/OUT:
 *   OUT:
 *     x_location_id                  Location ID.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

/*#
 * Use this routine to create an address location. This API creates a record
 * in the HZ_LOCATIONS table. The API also creates a record in the
 * HZ_LOCATIONS_PROFILES table that stores address-specific information about the location.
 * The location created by this API is a physical location that you can use to create a
 * party site or customer account site. If orig_system is passed in, then the API also
 * creates a record in the HZ_ORIG_SYS_REFERENCES table to store the mapping between the
 * source system reference and the TCA primary key. If timezone_id is not passed in, then
 * the API generates a time zone value, based on the address components and time zone
 * setup. However, if the user passes in the time zone, then the API keeps the time
 * zone value that the user chose.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Location
 * @rep:businessevent oracle.apps.ar.hz.Location.create
 * @rep:doccd 120hztig.pdf Location APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_location (
    p_init_msg_list                    IN      VARCHAR2 := FND_API.G_FALSE,
    p_location_rec                     IN      LOCATION_REC_TYPE,
    x_location_id                      OUT NOCOPY     NUMBER,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE create_location
 *
 * DESCRIPTION
 *     Creates location(overloaded procedure with address validation).
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_location_rec                 Location record.
 *     p_do_addr_val                  Do address validation if 'Y'
 *   IN/OUT:
 *   OUT:
 *     x_location_id                  Location ID.
 *     x_addr_val_status              Address validation status based on address validation level.
 *     x_addr_warn_msg                Warning message if x_addr_val_status is 'W'
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   10-04-2005    Baiju Nair        o Created.
 *
 */

/*#
 * This is an overloaded procedure for create location API.
 * The only difference is that this will call Address validation API to save GNR results if p_do_addr_val is 'Y'.
 * If the Address validation is success it will call the old create location API.
 * OUT parameter, x_addr_val_status will return the address validation status based on address validation level.
 * If x_addr_val_status is 'W', x_addr_warn_msg will have the warning message.
 * Use this routine to create an address location. This API creates a record
 * in the HZ_LOCATIONS table. The API also creates a record in the
 * HZ_LOCATIONS_PROFILES table that stores address-specific information about the location.
 * The location created by this API is a physical location that you can use to create a
 * party site or customer account site. If orig_system is passed in, then the API also
 * creates a record in the HZ_ORIG_SYS_REFERENCES table to store the mapping between the
 * source system reference and the TCA primary key. If timezone_id is not passed in, then
 * the API generates a time zone value, based on the address components and time zone
 * setup. However, if the user passes in the time zone, then the API keeps the time
 * zone value that the user chose.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Location
 * @rep:businessevent oracle.apps.ar.hz.Location.create
 */
PROCEDURE create_location (
    p_init_msg_list                    IN      VARCHAR2 := FND_API.G_FALSE,
    p_location_rec                     IN      LOCATION_REC_TYPE,
    p_do_addr_val                      IN             VARCHAR2,
    x_location_id                      OUT NOCOPY     NUMBER,
    x_addr_val_status                  OUT NOCOPY     VARCHAR2,
    x_addr_warn_msg                    OUT NOCOPY     VARCHAR2,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE update_location
 *
 * DESCRIPTION
 *     Updates location.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_location_rec                 Location record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

/*#
 * Use this routine to update an address location. The API updates a record
 * in the HZ_LOCATIONS table. The API also creates or updates a record in the
 * HZ_LOCATIONS_PROFILES table. Whether to create or update a location profile
 * record depends on the value of the HZ:Maintain Location History and HZ: Allow
 * to Update Standardized Address profile options. If the primary key is not
 * passed in, then get the primary key from the HZ_ORIG_SYS_REFERENCES table, based on
 * orig_system and orig_system_reference that must be unique and not null. If timezone_id
 * is not passed in, then the API generates a time zone value, based on the changes of the
 * address components and the time zone setup, even if a time zone already exists in the
 * database. However, if the user passes in the time zone, then the API keeps the time zone
 * value that the user chose.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Location
 * @rep:businessevent oracle.apps.ar.hz.Location.update
 * @rep:doccd 120hztig.pdf Location APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_location (
    p_init_msg_list                    IN      VARCHAR2 :=FND_API.G_FALSE,
    p_location_rec                     IN      LOCATION_REC_TYPE,
    p_object_version_number            IN OUT NOCOPY  NUMBER,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE update_location
 *
 * DESCRIPTION
 *     Updates location(overloaded procedure with address validation).
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_location_rec                 Location record.
 *     p_do_addr_val                  Do address validation if 'Y'
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_addr_val_status              Address validation status based on address validation level.
 *     x_addr_warn_msg                Warning message if x_addr_val_status is 'W'
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   10-04-2005    Baiju Nair        o Created.
 *
 */

/*#
 * This is an overloaded procedure for update location API.
 * The only difference is that this will call Address validation API to save GNR results if p_do_addr_val is 'Y'.
 * If the Address validation is success it will call the old update location API.
 * OUT parameter, x_addr_val_status will return the address validation status based on address validation level.
 * If x_addr_val_status is 'W', x_addr_warn_msg will have the warning message.
 * Use this routine to update an address location. The API updates a record
 * in the HZ_LOCATIONS table. The API also creates or updates a record in the
 * HZ_LOCATIONS_PROFILES table. Whether to create or update a location profile
 * record depends on the value of the HZ:Maintain Location History and HZ: Allow
 * to Update Standardized Address profile options. If the primary key is not
 * passed in, then get the primary key from the HZ_ORIG_SYS_REFERENCES table, based on
 * orig_system and orig_system_reference that must be unique and not null. If timezone_id
 * is not passed in, then the API generates a time zone value, based on the changes of the
 * address components and the time zone setup, even if a time zone already exists in the
 * database. However, if the user passes in the time zone, then the API keeps the time zone
 * value that the user chose.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Location
 * @rep:businessevent oracle.apps.ar.hz.Location.update
 */

PROCEDURE update_location (
    p_init_msg_list                    IN      VARCHAR2 :=FND_API.G_FALSE,
    p_location_rec                     IN      LOCATION_REC_TYPE,
    p_do_addr_val                      IN             VARCHAR2,
    p_object_version_number            IN OUT NOCOPY  NUMBER,
    x_addr_val_status                  OUT NOCOPY     VARCHAR2,
    x_addr_warn_msg                    OUT NOCOPY     VARCHAR2,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE get_location_rec
 *
 * DESCRIPTION
 *     Gets location record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_location_id                  Location ID.
 *   IN/OUT:
 *   OUT:
 *     x_location_rec                 Location record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE get_location_rec(
    p_init_msg_list                    IN      VARCHAR2:= FND_API.G_FALSE,
    p_location_id                      IN      NUMBER,
    x_location_rec                     OUT     NOCOPY LOCATION_REC_TYPE,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE fill_geometry_for_locations
 *
 * DESCRIPTION
 *     Concurrent program to fill geometry column in hz_locations.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   OUT:
 *     p_errbuf                       Error buffer.
 *     p_retcode                      Return code.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE fill_geometry_for_locations(
    p_errbuf                           OUT NOCOPY  VARCHAR2,
    p_retcode                          OUT NOCOPY  NUMBER
);

END HZ_LOCATION_V2PUB;

 

/

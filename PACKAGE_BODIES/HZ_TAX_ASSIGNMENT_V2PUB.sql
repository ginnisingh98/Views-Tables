--------------------------------------------------------
--  DDL for Package Body HZ_TAX_ASSIGNMENT_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_TAX_ASSIGNMENT_V2PUB" AS
/* $Header: ARH2TASB.pls 120.20 2005/11/18 18:13:42 baianand noship $ */

--------------------------------------
-- declaration of private global varibles
--------------------------------------

--G_DEBUG             BOOLEAN := FALSE;

--------------------------------------
-- declaration of private procedures and functions
--------------------------------------

/*PROCEDURE enable_debug;

PROCEDURE disable_debug;
*/

PROCEDURE do_create_loc_assignment(
        p_location_id                  IN      NUMBER,
        x_loc_id                       OUT NOCOPY     NUMBER,
        x_return_status                IN OUT NOCOPY  VARCHAR2,  /* Changed from OUT NOCOPY to IN OUT*/
        p_lock_flag                    IN      VARCHAR2 :=  FND_API.G_FALSE,
        p_created_by_module            IN      VARCHAR2,
        p_application_id               IN      NUMBER
);

-- Removed following parameters since it id not used in the procedure
-- x_loc_id, p_created_by_module, p_application_id, x_org_id
-- Added p_do_addr_val, x_addr_val_status and x_addr_warn_msg for address validation.
PROCEDURE do_update_loc_assignment(
        p_location_id                  IN      NUMBER,
        p_do_addr_val                  IN      VARCHAR2,
        x_addr_val_status              OUT NOCOPY     VARCHAR2,
        x_addr_warn_msg                OUT NOCOPY     VARCHAR2,
        x_return_status                IN OUT NOCOPY  VARCHAR2,  /* Changed from OUT NOCOPY to IN OUT*/
        p_lock_flag                    IN      VARCHAR2 :=  FND_API.G_TRUE
);

--------------------------------------
-- private procedures and functions
--------------------------------------

/**
 * PRIVATE PROCEDURE enable_debug
 *
 * DESCRIPTION
 *     Turn on debug mode.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_UTILITY_V2PUB.enable_debug
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

/*PROCEDURE enable_debug IS

BEGIN

    IF FND_PROFILE.value( 'HZ_API_FILE_DEBUG_ON' ) = 'Y' OR
       FND_PROFILE.value( 'HZ_API_DBMS_DEBUG_ON' ) = 'Y'
    THEN
        HZ_UTILITY_V2PUB.enable_debug;
        G_DEBUG := TRUE;
    END IF;

END enable_debug;
*/

/**
 * PRIVATE PROCEDURE disable_debug
 *
 * DESCRIPTION
 *     Turn off debug mode.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_UTILITY_V2PUB.disable_debug
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

/*PROCEDURE disable_debug IS

BEGIN

    IF G_DEBUG THEN
        HZ_UTILITY_V2PUB.disable_debug;
        G_DEBUG := FALSE;
    END IF;

END disable_debug;
*/

/**==========================================================================+
 | PROCEDURE
 |              do_create_loc_assignment
 |
 | DESCRIPTION
 |              Creates loc assignments
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_location_id
 |                    p_lock_flag
 |              OUT:
 |                    x_loc_id
 |          IN/ OUT:
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 *   05-29-2003    Ramesh Ch	       o Bug 2800555.Initialized arp_standard.sysparm with
 *					 ar_system_parameters row values.
 *   01-30-2004    Rajib Ranjan Borah  o Bug 3395521.
 *                                     o Modified IF clause to handle NULL
 *                                     o Passed address1 to address4 to update_profile_pvt
 *
 +===========================================================================**/

PROCEDURE do_create_loc_assignment(
    p_location_id                  IN      NUMBER,
    x_loc_id                       OUT NOCOPY     NUMBER,
    x_return_status                IN OUT NOCOPY  VARCHAR2,  /* Changed from OUT NOCOPY to IN OUT*/
    p_lock_flag                    IN      VARCHAR2 :=  FND_API.G_FALSE,
    p_created_by_module            IN      VARCHAR2,
    p_application_id               IN      NUMBER
) IS

    l_org_id                     NUMBER;
    l_count                      NUMBER;
    l_rowid                      ROWID  := NULL;

    l_is_remit_to_location       VARCHAR2(1) := 'N';
    l_return_status         VARCHAR2(30);
    l_addr_val_status       VARCHAR2(30);
    l_addr_warn_msg         VARCHAR2(2000);
    l_addr_val_level        VARCHAR2(30);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

    CURSOR c_loc (p_location_id in number) IS
    SELECT
      LOCATION_ID,
      ADDRESS_STYLE,
      COUNTRY,
      STATE,
      PROVINCE,
      COUNTY,
      CITY,
      POSTAL_CODE,
      POSTAL_PLUS4_CODE,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10
    FROM HZ_LOCATIONS WHERE LOCATION_ID = p_location_id;


BEGIN

    -- check the required fields:
    IF p_location_id IS NULL
       OR
       p_location_id = FND_API.G_MISS_NUM
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'p_location_id');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- checking whether this location is for Remit-To Address or not
    BEGIN
        SELECT  'Y'
        INTO    l_is_remit_to_location
        FROM    DUAL
        WHERE   EXISTS ( SELECT  1
                         FROM    HZ_PARTY_SITES PS
                         WHERE   PS.LOCATION_ID = p_location_id
                         AND     PS.PARTY_ID = -1);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;

    IF l_is_remit_to_location <> 'Y' THEN
    FOR l_c_loc in c_loc(p_location_id) LOOP
      HZ_GNR_PKG.validateLoc(
        P_LOCATION_ID               => l_c_loc.LOCATION_ID,
        P_USAGE_CODE                => 'GEOGRAPHY',
        P_ADDRESS_STYLE             => l_c_loc.ADDRESS_STYLE,
        P_COUNTRY                   => l_c_loc.COUNTRY,
        P_STATE                     => l_c_loc.STATE,
        P_PROVINCE                  => l_c_loc.PROVINCE,
        P_COUNTY                    => l_c_loc.COUNTY,
        P_CITY                      => l_c_loc.CITY,
        P_POSTAL_CODE               => l_c_loc.POSTAL_CODE,
        P_POSTAL_PLUS4_CODE         => l_c_loc.POSTAL_PLUS4_CODE,
        P_ATTRIBUTE1                => l_c_loc.ATTRIBUTE1,
        P_ATTRIBUTE2                => l_c_loc.ATTRIBUTE2,
        P_ATTRIBUTE3                => l_c_loc.ATTRIBUTE3,
        P_ATTRIBUTE4                => l_c_loc.ATTRIBUTE4,
        P_ATTRIBUTE5                => l_c_loc.ATTRIBUTE5,
        P_ATTRIBUTE6                => l_c_loc.ATTRIBUTE6,
        P_ATTRIBUTE7                => l_c_loc.ATTRIBUTE7,
        P_ATTRIBUTE8                => l_c_loc.ATTRIBUTE8,
        P_ATTRIBUTE9                => l_c_loc.ATTRIBUTE9,
        P_ATTRIBUTE10               => l_c_loc.ATTRIBUTE10,
        P_LOCK_FLAG                 => p_lock_flag,
        P_CALLED_FROM               => 'VALIDATE',
        X_ADDR_VAL_LEVEL            => l_addr_val_level,
        X_ADDR_WARN_MSG             => l_addr_warn_msg,
        X_ADDR_VAL_STATUS           => l_addr_val_status,
        X_STATUS                    => x_return_status);
     END LOOP;
    END IF;

END do_create_loc_assignment;


/**==========================================================================+
 | PROCEDURE
 |              do_update_loc_assignment
 |
 | DESCRIPTION
 |              Updates loc assignments
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_location_id
 |                    p_lock_flag
 |              OUT:
 |                    x_loc_id
 |          IN/ OUT:
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 *   05-29-2003    Ramesh Ch	       o Bug 2800555.Initialized arp_standard.sysparm with
 *					 ar_system_parameters row values.
 *   01-30-2004    Rajib Ranjan Borah  o Bug 3395521.
 *                                     o Modified IF clause to handle NULL
 *                                     o Passed address1 to address4 to update_profile_pvt
 *                                     o Moved the call to update_location_pvt to outside
 *                                       the loop.
 *                                     o Updated the db_* variables to prevent unnecessary
 *                                       additional updates to HZ_LOCATIONS.
 *
 +===========================================================================**/
-- Removed following parameters since it id not used in the procedure
-- x_loc_id, p_created_by_module, p_application_id, x_org_id
-- Added p_do_addr_val, x_addr_val_status and x_addr_warn_msg for address validation.
PROCEDURE do_update_loc_assignment(
        p_location_id                  IN      NUMBER,
        p_do_addr_val                  IN      VARCHAR2,
        x_addr_val_status              OUT NOCOPY     VARCHAR2,
        x_addr_warn_msg                OUT NOCOPY     VARCHAR2,
        x_return_status                IN OUT NOCOPY  VARCHAR2,  /* Changed from OUT NOCOPY to IN OUT*/
        p_lock_flag                    IN      VARCHAR2 :=  FND_API.G_TRUE
) IS

    l_is_remit_to_location    VARCHAR2(1) := 'N';
    l_loc_assg_exists         VARCHAR2(1) := 'N';
    l_return_status         VARCHAR2(30);
    l_addr_val_level        VARCHAR2(30);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_allow_update_std        VARCHAR2(1);
    l_date_validated          DATE;
    l_validation_status_code  VARCHAR2(30);

    l_msg_count_gnr             NUMBER;
    l_msg_data_gnr              VARCHAR2(2000);

    CURSOR c_loc (p_location_id in number) IS
    SELECT
      LOCATION_ID,
      ADDRESS_STYLE,
      COUNTRY,
      STATE,
      PROVINCE,
      COUNTY,
      CITY,
      POSTAL_CODE,
      POSTAL_PLUS4_CODE,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10
    FROM HZ_LOCATIONS WHERE LOCATION_ID = p_location_id;

BEGIN

    -- check the required fields:
    IF p_location_id IS NULL
       OR
       p_location_id = FND_API.G_MISS_NUM
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'p_location_id');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    BEGIN
        SELECT DATE_VALIDATED, VALIDATION_STATUS_CODE
        INTO l_date_validated, l_validation_status_code
        FROM   HZ_LOCATIONS
        WHERE  LOCATION_ID = p_location_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
            FND_MESSAGE.SET_TOKEN('RECORD', 'hz_locations');
            FND_MESSAGE.SET_TOKEN('VALUE', to_char(p_location_id));
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
    END;

    -- raise error if the update location profile option is turned off and
    -- the address has been validated before
    l_allow_update_std := nvl(fnd_profile.value('HZ_UPDATE_STD_ADDRESS'), 'Y');
    IF(l_allow_update_std = 'N' AND
       l_date_validated IS NOT NULL AND
       l_validation_status_code IS NOT NULL)
    THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_LOC_NO_UPDATE');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- checking whether this location is for Remit-To Address or not
    BEGIN
        SELECT  'Y'
        INTO    l_is_remit_to_location
        FROM    DUAL
        WHERE   EXISTS ( SELECT  1
                         FROM    HZ_PARTY_SITES PS
                         WHERE   PS.LOCATION_ID = p_location_id
                         AND     PS.PARTY_ID = -1);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;

    -- checking whether this location is already validated
    BEGIN
        SELECT  'Y'
        INTO    l_loc_assg_exists
        FROM    DUAL
        WHERE   EXISTS ( SELECT  1
                         FROM    HZ_LOC_ASSIGNMENTS
                         WHERE   LOCATION_ID = p_location_id);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;

    IF l_is_remit_to_location <> 'Y' OR p_do_addr_val = 'Y' THEN
      FOR l_c_loc in c_loc(p_location_id) LOOP
        IF l_loc_assg_exists = 'Y' OR p_do_addr_val = 'Y' THEN

          HZ_GNR_PKG.delete_gnr(
             p_locId                    => p_location_id,
             p_locTbl                   => 'HZ_LOCATIONS',
             x_status                   => x_return_status);

          HZ_GNR_PKG.validateLoc(
            P_LOCATION_ID               => l_c_loc.LOCATION_ID,
            P_USAGE_CODE                => 'GEOGRAPHY',
            P_ADDRESS_STYLE             => l_c_loc.ADDRESS_STYLE,
            P_COUNTRY                   => l_c_loc.COUNTRY,
            P_STATE                     => l_c_loc.STATE,
            P_PROVINCE                  => l_c_loc.PROVINCE,
            P_COUNTY                    => l_c_loc.COUNTY,
            P_CITY                      => l_c_loc.CITY,
            P_POSTAL_CODE               => l_c_loc.POSTAL_CODE,
            P_POSTAL_PLUS4_CODE         => l_c_loc.POSTAL_PLUS4_CODE,
            P_ATTRIBUTE1                => l_c_loc.ATTRIBUTE1,
            P_ATTRIBUTE2                => l_c_loc.ATTRIBUTE2,
            P_ATTRIBUTE3                => l_c_loc.ATTRIBUTE3,
            P_ATTRIBUTE4                => l_c_loc.ATTRIBUTE4,
            P_ATTRIBUTE5                => l_c_loc.ATTRIBUTE5,
            P_ATTRIBUTE6                => l_c_loc.ATTRIBUTE6,
            P_ATTRIBUTE7                => l_c_loc.ATTRIBUTE7,
            P_ATTRIBUTE8                => l_c_loc.ATTRIBUTE8,
            P_ATTRIBUTE9                => l_c_loc.ATTRIBUTE9,
            P_ATTRIBUTE10               => l_c_loc.ATTRIBUTE10,
            P_LOCK_FLAG                 => p_lock_flag,
            P_CALLED_FROM               => 'VALIDATE',
            X_ADDR_VAL_LEVEL            => l_addr_val_level,
            X_ADDR_WARN_MSG             => x_addr_warn_msg,
            X_ADDR_VAL_STATUS           => x_addr_val_status,
            X_STATUS                    => x_return_status);
        ELSE
          -- Below code will execute only if there is no record in hz_loc_assignments table
          -- process_gnr will process the GNR and return success even if there is an error
          -- in the validation.
          HZ_GNR_PUB.process_gnr (
            p_location_table_name       => 'HZ_LOCATIONS',
            p_location_id               => p_location_id,
            p_call_type                 => 'U',
            p_init_msg_list             => 'F',
            x_return_status             => x_return_status,
            x_msg_count                 => l_msg_count_gnr,
            x_msg_data                  => l_msg_data_gnr);

        END IF;
      END LOOP;
    END IF;

END do_update_loc_assignment;

--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_loc_assignment
 *
 * DESCRIPTION
 *     Creates location assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_location_id                  Location ID.
 *     p_lock_flag                    Lock record or not. Default is FND_API.G_FALSE.
 *     p_created_by_module            Module name which creates this record.
 *     p_application_id               Application ID which creates this record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *     x_loc_id                       Location assignment ID.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE create_loc_assignment(
    p_init_msg_list                IN          VARCHAR2 := FND_API.G_FALSE,
    p_location_id                  IN          NUMBER,
    p_lock_flag                    IN          VARCHAR2 :=FND_API.G_FALSE,
    p_created_by_module            IN          VARCHAR2,
    p_application_id               IN          NUMBER,
    x_return_status                IN OUT NOCOPY      VARCHAR2,
    x_msg_count                    OUT NOCOPY         NUMBER,
    x_msg_data                     OUT NOCOPY         VARCHAR2,
    x_loc_id                       OUT NOCOPY         NUMBER
) IS

    l_location_id                              NUMBER := p_location_id;
    APP_EXCEPTION                              EXCEPTION;
    PRAGMA EXCEPTION_INIT(APP_EXCEPTION, -20000);

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_loc_assignment;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic.
    -- populate loc_id by calling tax package.
    do_create_loc_assignment( p_location_id,
                              x_loc_id,
                              x_return_status,
                              p_lock_flag,
                              p_created_by_module,
                              p_application_id);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_loc_assignment;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_loc_assignment;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN APP_EXCEPTION THEN
        ROLLBACK TO create_loc_assignment;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO create_loc_assignment;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END create_loc_assignment;

/**
 * PROCEDURE update_loc_assignment
 *
 * DESCRIPTION
 *     Updates location assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_location_id                  Location ID.
 *     p_lock_flag                    Lock record or not. Default is FND_API.G_TRUE.
 *     p_created_by_module            Module name which creates this record.
 *     p_application_id               Application ID which creates this record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *     x_loc_id                       Location assignment ID.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE update_loc_assignment(
    p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE,
    p_location_id                  IN      NUMBER,
    p_lock_flag                    IN      VARCHAR2 :=FND_API.G_TRUE,
    p_created_by_module            IN      VARCHAR2,
    p_application_id               IN      NUMBER,
    x_return_status                IN OUT NOCOPY  VARCHAR2,
    x_msg_count                    OUT NOCOPY     NUMBER,
    x_msg_data                     OUT NOCOPY     VARCHAR2,
    x_loc_id                       OUT NOCOPY     NUMBER
) IS

    l_org_id      VARCHAR2(2000);
BEGIN
     update_loc_assignment(
                           p_init_msg_list,
                           p_location_id  ,
                           p_lock_flag,
                           p_created_by_module,
                           p_application_id,
                           x_return_status,
                           x_msg_count,
                           x_msg_data ,
                           x_loc_id,
                           l_org_id
                         );

END update_loc_assignment;

/**
 * PROCEDURE update_loc_assignment
 *
 * DESCRIPTION
 *     Updates location assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_location_id                  Location ID.
 *     p_lock_flag                    Lock record or not. Default is FND_API.G_TRUE.
 *     p_created_by_module            Module name which creates this record.
 *     p_application_id               Application ID which creates this record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *     x_loc_id                       Location assignment ID.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   09-18-2003    P.Suresh        o Created.
 *
 */

PROCEDURE update_loc_assignment(
    p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE,
    p_location_id                  IN      NUMBER,
    p_lock_flag                    IN      VARCHAR2 :=FND_API.G_TRUE,
    p_created_by_module            IN      VARCHAR2,
    p_application_id               IN      NUMBER,
    x_return_status                IN OUT NOCOPY  VARCHAR2,
    x_msg_count                    OUT NOCOPY     NUMBER,
    x_msg_data                     OUT NOCOPY     VARCHAR2,
    x_loc_id                       OUT NOCOPY     NUMBER ,
    x_org_id                       OUT NOCOPY     VARCHAR2
) IS

    l_location_id                          NUMBER := p_location_id;
    APP_EXCEPTION                          EXCEPTION;
    PRAGMA EXCEPTION_INIT(APP_EXCEPTION, -20000);

    l_addr_val_status  VARCHAR2(30);
    l_addr_warn_msg    VARCHAR2(2000);
BEGIN

    -- standard start of API savepoint
    SAVEPOINT update_loc_assignment;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic.
    -- populate loc_id by calling tax package.
    do_update_loc_assignment( l_location_id,
                              'N',
                              l_addr_val_status,
                              l_addr_warn_msg,
                              x_return_status,
                              p_lock_flag);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_loc_assignment;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_loc_assignment;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN APP_EXCEPTION THEN
        ROLLBACK TO update_loc_assignment;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_loc_assignment;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END update_loc_assignment;

/**
 * PROCEDURE update_loc_assignment
 *
 * DESCRIPTION
 *     Updates location assignment(overloaded procedure with address validation).
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_location_id                  Location ID.
 *     p_lock_flag                    Lock record or not. Default is FND_API.G_TRUE.
 *     p_created_by_module            Module name which creates this record.
 *     p_application_id               Application ID which creates this record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *     x_loc_id                       Location assignment ID.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   09-18-2003    P.Suresh        o Created.
 *
 */

PROCEDURE update_loc_assignment(
        p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE,
        p_location_id                  IN      NUMBER,
        p_lock_flag                    IN      VARCHAR2 := FND_API.G_TRUE,
        p_do_addr_val                  IN      VARCHAR2,
        x_addr_val_status              OUT NOCOPY     VARCHAR2,
        x_addr_warn_msg                OUT NOCOPY     VARCHAR2,
        x_return_status                IN OUT NOCOPY  VARCHAR2,
        x_msg_count                    OUT NOCOPY     NUMBER,
        x_msg_data                     OUT NOCOPY     VARCHAR2
) IS
    l_location_id                          NUMBER := p_location_id;
    APP_EXCEPTION                          EXCEPTION;
    PRAGMA EXCEPTION_INIT(APP_EXCEPTION, -20000);

BEGIN

    -- standard start of API savepoint
    SAVEPOINT update_loc_assignment;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic.
    -- populate loc_id by calling tax package.
    do_update_loc_assignment( l_location_id,
                              p_do_addr_val,
                              x_addr_val_status,
                              x_addr_warn_msg,
                              x_return_status,
                              p_lock_flag);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_loc_assignment;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_loc_assignment;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN APP_EXCEPTION THEN
        ROLLBACK TO update_loc_assignment;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_loc_assignment;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END update_loc_assignment;

END HZ_TAX_ASSIGNMENT_V2PUB;

/

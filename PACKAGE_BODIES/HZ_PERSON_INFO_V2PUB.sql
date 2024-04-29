--------------------------------------------------------
--  DDL for Package Body HZ_PERSON_INFO_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PERSON_INFO_V2PUB" AS
/* $Header: ARH2PISB.pls 120.12 2005/12/07 19:31:14 acng noship $ */

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


PROCEDURE do_create_person_language(
    p_person_language_rec               IN OUT  NOCOPY PERSON_LANGUAGE_REC_TYPE,
    x_language_use_reference_id         OUT NOCOPY     NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_update_person_language(
    p_person_language_rec               IN OUT  NOCOPY PERSON_LANGUAGE_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_create_citizenship(
    p_citizenship_rec                   IN OUT  NOCOPY CITIZENSHIP_REC_TYPE,
    x_citizenship_id                    OUT NOCOPY     NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_update_citizenship(
    p_citizenship_rec                   IN OUT  NOCOPY CITIZENSHIP_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_create_education(
    p_education_rec                     IN OUT  NOCOPY EDUCATION_REC_TYPE,
    x_education_id                      OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_update_education(
    p_education_rec                     IN OUT  NOCOPY EDUCATION_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_create_employment_history(
    p_employment_history_rec            IN OUT  NOCOPY EMPLOYMENT_HISTORY_REC_TYPE,
    x_employment_history_id             OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_update_employment_history(
    p_employment_history_rec            IN OUT  NOCOPY EMPLOYMENT_HISTORY_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_create_work_class(
    p_work_class_rec                    IN OUT  NOCOPY WORK_CLASS_REC_TYPE,
    x_work_class_id                     OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_update_work_class(
    p_work_class_rec                    IN OUT  NOCOPY WORK_CLASS_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_create_person_interest(
    p_person_interest_rec               IN OUT  NOCOPY PERSON_INTEREST_REC_TYPE,
    x_person_interest_id                OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_update_person_interest(
    p_person_interest_rec               IN OUT  NOCOPY PERSON_INTEREST_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
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

/*===========================================================================+
 | PROCEDURE
 |              do_create_person_language
 |
 | DESCRIPTION
 |              Creates person language
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_language_use_reference_id
 |          IN/ OUT:
 |                    p_person_language_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   19-March-2003    Porkodi C      o 2820135, Validation for primary lanugage
 |				       and native language has been added here
 +===========================================================================*/

PROCEDURE do_create_person_language(
    p_person_language_rec               IN OUT  NOCOPY PERSON_LANGUAGE_REC_TYPE,
    x_language_use_reference_id         OUT NOCOPY     NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
) IS

    l_dummy                             VARCHAR2(1);
    l_rowid                             ROWID;
    l_debug_prefix                      VARCHAR2(30) := '';
    l_language_use_reference_id         NUMBER;

BEGIN

    -- if primary key value is passed, check for uniqueness.

    IF p_person_language_rec.language_use_reference_id IS NOT NULL AND
        p_person_language_rec.language_use_reference_id <> FND_API.G_MISS_NUM
    THEN
        BEGIN
            SELECT 'Y' INTO l_dummy
            FROM   HZ_PERSON_LANGUAGE
            WHERE  LANGUAGE_USE_REFERENCE_ID = p_person_language_rec.language_use_reference_id;

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'language_use_reference_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;

    -- 2820135, Added this new feature. Actually this should have been party of hzk
    -- a party can have only one primary language
    IF p_person_language_rec.primary_language_indicator = 'Y' THEN
         BEGIN
           SELECT LANGUAGE_USE_REFERENCE_ID
         	  INTO   l_language_use_reference_id
		  FROM   HZ_PERSON_LANGUAGE
		  WHERE  PARTY_ID = p_person_language_rec.party_id
		  AND    PRIMARY_LANGUAGE_INDICATOR = 'Y'
		  AND    LANGUAGE_USE_REFERENCE_ID <> NVL(p_person_language_rec.language_use_reference_id, fnd_api.g_miss_num);

	   UPDATE HZ_PERSON_LANGUAGE
		  SET primary_language_indicator='N'
		  WHERE PARTY_ID = p_person_language_rec.party_id AND
		  PRIMARY_LANGUAGE_INDICATOR ='Y' AND
		  LANGUAGE_USE_REFERENCE_ID = l_language_use_reference_id;

           EXCEPTION
	     WHEN NO_DATA_FOUND THEN
	     NULL;
         END;

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'a party can have only one primary language. ' ||
	      'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;


    -- 2820135, Added this new feature. Actually this should have been party of hzk
    -- a party can have only one native language
    IF p_person_language_rec.native_language = 'Y' THEN
         BEGIN
           SELECT LANGUAGE_USE_REFERENCE_ID
         	  INTO   l_language_use_reference_id
		  FROM   HZ_PERSON_LANGUAGE
		  WHERE  PARTY_ID = p_person_language_rec.party_id
		  AND    NATIVE_LANGUAGE = 'Y'
		  AND    LANGUAGE_USE_REFERENCE_ID <> NVL(p_person_language_rec.language_use_reference_id, fnd_api.g_miss_num);

	   UPDATE HZ_PERSON_LANGUAGE
		  SET native_language='N'
		  WHERE PARTY_ID = p_person_language_rec.party_id AND
		  NATIVE_LANGUAGE ='Y' AND
		  LANGUAGE_USE_REFERENCE_ID = l_language_use_reference_id;

           EXCEPTION
	     WHEN NO_DATA_FOUND THEN
	     NULL;
         END;

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'a party can have only one native language. ' ||
	      'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;


    -- validate person language  record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_person_language(
        'C',
        p_person_language_rec,
        l_rowid,
        x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call table handler to insert a row
    HZ_PERSON_LANGUAGE_PKG.Insert_Row (
        X_LANGUAGE_USE_REFERENCE_ID             => p_person_language_rec.language_use_reference_id,
        X_LANGUAGE_NAME                         => p_person_language_rec.language_name,
        X_PARTY_ID                              => p_person_language_rec.party_id,
        X_NATIVE_LANGUAGE                       => p_person_language_rec.native_language,
        X_PRIMARY_LANGUAGE_INDICATOR            => p_person_language_rec.primary_language_indicator,
        X_READS_LEVEL                           => p_person_language_rec.reads_level,
        X_SPEAKS_LEVEL                          => p_person_language_rec.speaks_level,
        X_WRITES_LEVEL                          => p_person_language_rec.writes_level,
        X_SPOKEN_COMPREHENSION_LEVEL            => p_person_language_rec.spoken_comprehension_level,
        X_STATUS                                => p_person_language_rec.status,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_person_language_rec.created_by_module,
        X_APPLICATION_ID                        => p_person_language_rec.application_id
    );

    -- assign the primary key back
    x_language_use_reference_id := p_person_language_rec.language_use_reference_id;

    -- update the language_name in hz_parties based on native_language.
    IF p_person_language_rec.NATIVE_LANGUAGE = 'Y'
        AND nvl(p_person_language_rec.status,'A') = 'A'
 THEN
        UPDATE hz_parties
        SET    language_name = p_person_language_rec.language_name
        WHERE  party_id = p_person_language_rec.party_id;
    END IF;

END do_create_person_language;


/*===========================================================================+
 | PROCEDURE
 |              do_update_person_language
 |
 | DESCRIPTION
 |              Updates person language
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_person_language_rec
 |                    p_object_version_number
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   19-March-2003    Porkodi C      o 2820135, Validation for primary lanugage
 |				       and native language has been added here
 |
 +===========================================================================*/

PROCEDURE do_update_person_language(
    p_person_language_rec               IN OUT  NOCOPY PERSON_LANGUAGE_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
) IS

    l_rowid                                     ROWID  := NULL;
    l_object_version_number                     NUMBER;
    l_party_id                                  NUMBER;
    l_native_language                           VARCHAR2(1);
    l_language_name                             VARCHAR2(4);
    l_debug_prefix                              VARCHAR2(30) := '';
    l_language_use_reference_id                 NUMBER;
    l_status                                    VARCHAR2(1);
    l_orig_language_name                        VARCHAR2(4);
BEGIN

    -- check whether record has been updated by another user
    BEGIN
        -- check object_version_number
        SELECT rowid, object_version_number, party_id,
               native_language, language_name,status
        INTO l_rowid, l_object_version_number, l_party_id,
             l_native_language, l_language_name,l_status
        FROM HZ_PERSON_LANGUAGE
        WHERE language_use_reference_id = p_person_language_rec.language_use_reference_id
        FOR UPDATE NOWAIT;

        IF NOT
             (
              ( p_object_version_number IS NULL AND l_object_version_number IS NULL )
              OR
              ( p_object_version_number IS NOT NULL AND
                l_object_version_number IS NOT NULL AND
                p_object_version_number = l_object_version_number
              )
             )
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_PERSON_LANGUAGE');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
            FND_MESSAGE.SET_TOKEN('RECORD', 'HZ_PERSON_LANGUAGE');
            FND_MESSAGE.SET_TOKEN('VALUE', NVL( TO_CHAR( p_person_language_rec.language_use_reference_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    -- 2820135, Added this new feature. Actually this should have been party of hzk
    -- a party can have only one primary language
    IF p_person_language_rec.primary_language_indicator = 'Y' THEN
         BEGIN
           SELECT LANGUAGE_USE_REFERENCE_ID
         	  INTO   l_language_use_reference_id
		  FROM   HZ_PERSON_LANGUAGE
		  WHERE  PARTY_ID = l_party_id
		  AND    PRIMARY_LANGUAGE_INDICATOR = 'Y'
		  AND    LANGUAGE_USE_REFERENCE_ID <> NVL(p_person_language_rec.language_use_reference_id, fnd_api.g_miss_num);

	   UPDATE HZ_PERSON_LANGUAGE
		  SET primary_language_indicator='N'
		  WHERE PARTY_ID = l_party_id AND
		  PRIMARY_LANGUAGE_INDICATOR ='Y' AND
		  LANGUAGE_USE_REFERENCE_ID = l_language_use_reference_id;

           EXCEPTION
	     WHEN NO_DATA_FOUND THEN
	     NULL;
         END;

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'a party can have only one primary language. ' ||
	      'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;

    END IF;

    -- 2820135, Added this new feature. Actually this should have been party of hzk
    -- a party can have only one native language
    IF p_person_language_rec.native_language = 'Y' THEN
         BEGIN
           SELECT LANGUAGE_USE_REFERENCE_ID
         	  INTO   l_language_use_reference_id
		  FROM   HZ_PERSON_LANGUAGE
		  WHERE  PARTY_ID = l_party_id
		  AND    NATIVE_LANGUAGE = 'Y'
		  AND    LANGUAGE_USE_REFERENCE_ID <> NVL(p_person_language_rec.language_use_reference_id, fnd_api.g_miss_num);

	   UPDATE HZ_PERSON_LANGUAGE
		  SET native_language='N'
		  WHERE PARTY_ID = l_party_id AND
		  NATIVE_LANGUAGE ='Y' AND
		  LANGUAGE_USE_REFERENCE_ID = l_language_use_reference_id;

           EXCEPTION
	     WHEN NO_DATA_FOUND THEN
	     NULL;
         END;

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'a party can have only one native language. ' ||
	      'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;


    -- validate person interest record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_person_language(
        'U',
        p_person_language_rec,
        l_rowid,
        x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call table handler to update a row
    HZ_PERSON_LANGUAGE_PKG.Update_Row (
        X_Rowid                                 => l_rowid,
        X_LANGUAGE_USE_REFERENCE_ID             => p_person_language_rec.language_use_reference_id,
        X_LANGUAGE_NAME                         => p_person_language_rec.language_name,
        X_PARTY_ID                              => p_person_language_rec.party_id,
        X_NATIVE_LANGUAGE                       => p_person_language_rec.native_language,
        X_PRIMARY_LANGUAGE_INDICATOR            => p_person_language_rec.primary_language_indicator,
        X_READS_LEVEL                           => p_person_language_rec.reads_level,
        X_SPEAKS_LEVEL                          => p_person_language_rec.speaks_level,
        X_WRITES_LEVEL                          => p_person_language_rec.writes_level,
        X_SPOKEN_COMPREHENSION_LEVEL            => p_person_language_rec.spoken_comprehension_level,
        X_STATUS                                => p_person_language_rec.status,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_person_language_rec.created_by_module,
        X_APPLICATION_ID                        => p_person_language_rec.application_id
    );


    -- To update the language_name in hz_parties.
------------------Bug No. 4095604
IF nvl(p_person_language_rec.native_language,l_native_language)='Y' AND nvl(p_person_language_rec.status,l_status)='A' AND
 (nvl(p_person_language_rec.native_language,l_native_language)<>l_native_language OR nvl(p_person_language_rec.status,l_status)<>l_status)
THEN   UPDATE hz_parties
SET language_name= nvl(p_person_language_rec.language_name,l_language_name)
WHERE party_id=l_party_id;
ELSIF  l_native_language='Y' AND l_status='A'
AND ((p_person_language_rec.native_language is not null AND  p_person_language_rec.native_language <> l_native_language) OR
(p_person_language_rec.status is not null AND p_person_language_rec.status <> l_status)) THEN
UPDATE hz_parties
  SET language_name=NULL
  WHERE party_id=l_party_id;
END IF;
-------------------------Bug No. 4095604


END do_update_person_language;


/*===========================================================================+
 | PROCEDURE
 |              do_create_citizenship
 |
 | DESCRIPTION
 |              Creates citizenship
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_citizenship_id
 |          IN/ OUT:
 |                    p_citizenship_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_create_citizenship(
    p_citizenship_rec               IN OUT  NOCOPY CITIZENSHIP_REC_TYPE,
    x_citizenship_id                OUT NOCOPY     NUMBER,
    x_return_status                 IN OUT NOCOPY  VARCHAR2
) IS

    l_dummy                             VARCHAR2(1);
    l_rowid                             ROWID;

BEGIN

    -- if primary key value is passed, check for uniqueness.
    IF p_citizenship_rec.citizenship_id IS NOT NULL AND
        p_citizenship_rec.citizenship_id <> FND_API.G_MISS_NUM
    THEN
        BEGIN
            SELECT 'Y' INTO l_dummy
            FROM   HZ_CITIZENSHIP
            WHERE  CITIZENSHIP_ID = p_citizenship_rec.citizenship_id;

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'citizenship_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;

    -- validate citizenship  record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_citizenship(
        'C',
        p_citizenship_rec,
        l_rowid,
        x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call table handler to insert a row
    HZ_CITIZENSHIP_PKG.INSERT_ROW(
             X_CITIZENSHIP_ID 		=> p_citizenship_rec.citizenship_id,
             X_BIRTH_OR_SELECTED 	=> p_citizenship_rec.BIRTH_OR_SELECTED,
             X_PARTY_ID 		=> p_citizenship_rec.PARTY_ID,
             X_COUNTRY_CODE 		=> p_citizenship_rec.COUNTRY_CODE,
             X_DATE_DISOWNED		=> p_citizenship_rec.DATE_DISOWNED,
             X_DATE_RECOGNIZED 		=> p_citizenship_rec.DATE_RECOGNIZED,
             X_DOCUMENT_REFERENCE 	=> p_citizenship_rec.DOCUMENT_REFERENCE,
             X_DOCUMENT_TYPE 		=> p_citizenship_rec.DOCUMENT_TYPE,
             X_END_DATE 		=> p_citizenship_rec.END_DATE,
             X_STATUS  			=> p_citizenship_rec.STATUS,
             X_OBJECT_VERSION_NUMBER    => 1,
             X_CREATED_BY_MODULE        => p_citizenship_rec.created_by_module,
             X_APPLICATION_ID           => p_citizenship_rec.application_id
        );


    -- assign the primary key back
    x_citizenship_id := p_citizenship_rec.citizenship_id;

END do_create_citizenship;


/*===========================================================================+
 | PROCEDURE
 |              do_update_citizenship
 |
 | DESCRIPTION
 |              Updates citizenship
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_citizenship_rec
 |                    p_object_version_number
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_update_citizenship(
    p_citizenship_rec               IN OUT  NOCOPY citizenship_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
) IS

    l_rowid                                     ROWID  := NULL;
    l_object_version_number                     NUMBER;
    l_party_id                                  NUMBER;


BEGIN

    -- check whether record has been updated by another user
    BEGIN
        -- check object_version_number
        SELECT rowid, object_version_number, party_id
        INTO l_rowid, l_object_version_number, l_party_id
        FROM HZ_citizenship
        WHERE citizenship_id = p_citizenship_rec.citizenship_id
        FOR UPDATE NOWAIT;

        IF NOT
             (
              ( p_object_version_number IS NULL AND l_object_version_number IS NULL )
              OR
              ( p_object_version_number IS NOT NULL AND
                l_object_version_number IS NOT NULL AND
                p_object_version_number = l_object_version_number
              )
             )
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_CITIZENSHIP');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
            FND_MESSAGE.SET_TOKEN('RECORD', 'HZ_CITIZENSHIP');
            FND_MESSAGE.SET_TOKEN('VALUE', NVL( TO_CHAR( p_citizenship_rec.citizenship_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    -- validate person interest record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_citizenship(
        'U',
        p_citizenship_rec,
        l_rowid,
        x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call table handler to update a row
        HZ_CITIZENSHIP_PKG.UPDATE_ROW(
		  X_Rowid 			=> l_rowid,
		  X_CITIZENSHIP_ID 		=> p_citizenship_rec.CITIZENSHIP_ID,
		  X_BIRTH_OR_SELECTED 		=> p_citizenship_rec.BIRTH_OR_SELECTED,
		  X_PARTY_ID 			=> p_citizenship_rec.PARTY_ID,
		  X_COUNTRY_CODE 		=> p_citizenship_rec.COUNTRY_CODE,
		  X_DATE_DISOWNED 		=> p_citizenship_rec.DATE_DISOWNED,
		  X_DATE_RECOGNIZED 		=> p_citizenship_rec.DATE_RECOGNIZED,
		  X_DOCUMENT_REFERENCE  	=> p_citizenship_rec.DOCUMENT_REFERENCE,
		  X_DOCUMENT_TYPE 		=> p_citizenship_rec.DOCUMENT_TYPE,
		  X_END_DATE 			=> p_citizenship_rec.END_DATE,
		  X_STATUS  			=> p_citizenship_rec.STATUS,
		  X_OBJECT_VERSION_NUMBER       => p_object_version_number,
		  X_CREATED_BY_MODULE           => p_citizenship_rec.created_by_module,
		  X_APPLICATION_ID              => p_citizenship_rec.application_id

         );


END do_update_citizenship;


/*===========================================================================+
 | PROCEDURE
 |              do_create_education
 |
 | DESCRIPTION
 |              Creates education
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_education_id
 |          IN/ OUT:
 |                    p_education_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/



PROCEDURE do_create_education(
    p_education_rec               IN OUT  NOCOPY  EDUCATION_REC_TYPE,
    x_education_id                OUT     NOCOPY  NUMBER,
    x_return_status               IN OUT  NOCOPY  VARCHAR2
) IS

    l_dummy                             VARCHAR2(1);
    l_rowid                             ROWID;

BEGIN

    -- if primary key value is passed, check for uniqueness.
    IF p_education_rec.education_id IS NOT NULL AND
        p_education_rec.education_id <> FND_API.G_MISS_NUM
    THEN
        BEGIN
            SELECT 'Y' INTO l_dummy
            FROM   HZ_EDUCATION
            WHERE  EDUCATION_ID = p_education_rec.education_id;

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'education_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;

    -- validate education  record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_education(
        'C',
        p_education_rec,
        l_rowid,
        x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call table handler to insert a row
    HZ_EDUCATION_PKG.Insert_Row (
	x_EDUCATION_ID               =>   p_education_rec.education_id,
	x_COURSE_MAJOR               =>   p_education_rec.course_major,
	x_PARTY_ID                   =>   p_education_rec.party_id,
        x_SCHOOL_PARTY_ID            =>   p_education_rec.school_party_id,
	x_DEGREE_RECEIVED            =>   p_education_rec.degree_received,
	x_LAST_DATE_ATTENDED         =>   p_education_rec.last_date_attended,
	x_SCHOOL_ATTENDED_NAME       =>   p_education_rec.school_attended_name,
	x_TYPE_OF_SCHOOL             =>   p_education_rec.type_of_school,
	x_START_DATE_ATTENDED        =>   p_education_rec.start_date_attended,
	x_STATUS                     =>   p_education_rec.status,
	X_OBJECT_VERSION_NUMBER      =>   1,
	X_CREATED_BY_MODULE          =>   p_education_rec.created_by_module,
	X_APPLICATION_ID             =>   p_education_rec.application_id

    );

    -- assign the primary key back
    x_education_id := p_education_rec.education_id;

END do_create_education;


/*===========================================================================+
 | PROCEDURE
 |              do_update_education
 |
 | DESCRIPTION
 |              Updates education
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_education_rec
 |                    p_object_version_number
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_update_education(
    p_education_rec                     IN OUT NOCOPY  EDUCATION_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
) IS

    l_rowid                                     ROWID  := NULL;
    l_object_version_number                     NUMBER;
    l_party_id                                  NUMBER;

BEGIN

    -- check whether record has been updated by another user
    BEGIN
        -- check object_version_number
        SELECT rowid, object_version_number, party_id
        INTO l_rowid, l_object_version_number, l_party_id
        FROM HZ_EDUCATION
        WHERE education_id = p_education_rec.education_id
        FOR UPDATE NOWAIT;

        IF NOT
             (
              ( p_object_version_number IS NULL AND l_object_version_number IS NULL )
              OR
              ( p_object_version_number IS NOT NULL AND
                l_object_version_number IS NOT NULL AND
                p_object_version_number = l_object_version_number
              )
             )
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_EDUCATION');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
            FND_MESSAGE.SET_TOKEN('RECORD', 'HZ_EDUCATION');
            FND_MESSAGE.SET_TOKEN('VALUE', NVL( TO_CHAR( p_education_rec.education_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    -- validate person interest record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_education(
        'U',
        p_education_rec,
        l_rowid,
        x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call table handler to update a row
    HZ_EDUCATION_PKG.Update_Row (
        x_Rowid                      =>   l_rowid,
	x_EDUCATION_ID               =>   p_education_rec.education_id,
	x_COURSE_MAJOR               =>   p_education_rec.course_major,
	x_PARTY_ID                   =>   p_education_rec.party_id,
	X_SCHOOL_PARTY_ID            =>   p_education_rec.school_party_id,
	x_DEGREE_RECEIVED            =>   p_education_rec.degree_received,
	x_LAST_DATE_ATTENDED         =>   p_education_rec.last_date_attended,
	x_SCHOOL_ATTENDED_NAME       =>   p_education_rec.school_attended_name,
	x_TYPE_OF_SCHOOL             =>   p_education_rec.type_of_school,
	x_START_DATE_ATTENDED        =>   p_education_rec.start_date_attended,
	x_STATUS                     =>   p_education_rec.status,
	x_CREATED_BY_MODULE          =>   p_education_rec.created_by_module,
        x_OBJECT_VERSION_NUMBER      =>   p_object_version_number,
        x_APPLICATION_ID             =>   p_education_rec.application_id

    );


END do_update_education;


/*===========================================================================+
 | PROCEDURE
 |              do_create_employment_history
 |
 | DESCRIPTION
 |              Creates Employment history
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_employment_history_id
 |          IN/ OUT:
 |                    p_employment_history_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_create_employment_history(
    p_employment_history_rec      IN OUT  NOCOPY  EMPLOYMENT_HISTORY_REC_TYPE,
    x_employment_history_id       OUT     NOCOPY  NUMBER,
    x_return_status               IN OUT  NOCOPY  VARCHAR2
) IS

    l_dummy                             VARCHAR2(1);
    l_rowid                             ROWID;

BEGIN

    -- if primary key value is passed, check for uniqueness.
    IF p_employment_history_rec.employment_history_id IS NOT NULL AND
        p_employment_history_rec.employment_history_id <> FND_API.G_MISS_NUM
    THEN
        BEGIN
            SELECT 'Y' INTO l_dummy
            FROM   HZ_EMPLOYMENT_HISTORY
            WHERE  EMPLOYMENT_HISTORY_ID = p_employment_history_rec.employment_history_id;

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'employment_history_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;

    -- validate employment_history  record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_employment_history(
        'C',
        p_employment_history_rec,
        l_rowid,
        x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call table handler to insert a row
    HZ_EMPLOYMENT_HISTORY_PKG.Insert_Row (

       x_EMPLOYMENT_HISTORY_ID          =>   p_employment_history_rec.employment_history_id,
       x_BEGIN_DATE                  	=>   p_employment_history_rec.begin_date,
       x_PARTY_ID                    	=>   p_employment_history_rec.party_id,
       x_EMPLOYED_AS_TITLE           	=>   p_employment_history_rec.employed_as_title,
       x_EMPLOYED_BY_DIVISION_NAME   	=>   p_employment_history_rec.employed_by_division_name,
       x_EMPLOYED_BY_NAME_COMPANY    	=>   p_employment_history_rec.employed_by_name_company,
       x_END_DATE                    	=>   p_employment_history_rec.end_date,
       x_SUPERVISOR_NAME             	=>   p_employment_history_rec.supervisor_name,
       x_BRANCH                      	=>   p_employment_history_rec.branch,
       x_MILITARY_RANK               	=>   p_employment_history_rec.military_rank,
       x_SERVED                      	=>   p_employment_history_rec.served,
       x_STATION                     	=>   p_employment_history_rec.station,
       x_RESPONSIBILITY              	=>   p_employment_history_rec.responsibility,
       x_STATUS                         =>   p_employment_history_rec.status,
       x_OBJECT_VERSION_NUMBER       	=>   1,
       x_CREATED_BY_MODULE           	=>   p_employment_history_rec.created_by_module,
       x_EMPLOYED_BY_PARTY_ID           =>   p_employment_history_rec.EMPLOYED_BY_PARTY_ID,
       x_REASON_FOR_LEAVING             =>   p_employment_history_rec.REASON_FOR_LEAVING,
       x_FACULTY_POSITION_FLAG          =>   p_employment_history_rec.FACULTY_POSITION_FLAG,
       x_TENURE_CODE                    =>   p_employment_history_rec.TENURE_CODE,
       x_FRACTION_OF_TENURE             =>   p_employment_history_rec.FRACTION_OF_TENURE,
       x_EMPLOYMENT_TYPE_CODE           =>   p_employment_history_rec.EMPLOYMENT_TYPE_CODE,
       x_EMPLOYED_AS_TITLE_CODE         =>   p_employment_history_rec.EMPLOYED_AS_TITLE_CODE,
       x_WEEKLY_WORK_HOURS              =>   p_employment_history_rec.WEEKLY_WORK_HOURS,
       x_COMMENTS                       =>   p_employment_history_rec.COMMENTS,
       x_APPLICATION_ID                 =>   p_employment_history_rec.APPLICATION_ID

    );

    -- assign the primary key back
    x_employment_history_id := p_employment_history_rec.employment_history_id;

END do_create_employment_history;


/*===========================================================================+
 | PROCEDURE
 |              do_update_employment_history
 |
 | DESCRIPTION
 |              Updates Employment history
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_employment_history_rec
 |                    p_object_version_number
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_update_employment_history(
    p_employment_history_rec                     IN OUT NOCOPY  EMPLOYMENT_HISTORY_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
) IS

    l_rowid                                     ROWID  := NULL;
    l_object_version_number                     NUMBER;
    l_party_id                                  NUMBER;
    l_native_language                           VARCHAR2(1);
    l_language_name                             VARCHAR2(4);

BEGIN

    -- check whether record has been updated by another user
    BEGIN
        -- check object_version_number
        SELECT rowid, object_version_number, party_id
        INTO l_rowid, l_object_version_number, l_party_id
        FROM HZ_EMPLOYMENT_HISTORY
        WHERE employment_history_id = p_employment_history_rec.employment_history_id
        FOR UPDATE NOWAIT;

        IF NOT
             (
              ( p_object_version_number IS NULL AND l_object_version_number IS NULL )
              OR
              ( p_object_version_number IS NOT NULL AND
                l_object_version_number IS NOT NULL AND
                p_object_version_number = l_object_version_number
              )
             )
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_EMPLOYMENT_HISTORY');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
            FND_MESSAGE.SET_TOKEN('RECORD', 'HZ_EMPLOYMENT_HISTORY');
            FND_MESSAGE.SET_TOKEN('VALUE', NVL( TO_CHAR( p_employment_history_rec.employment_history_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    -- validate person employement_history record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_employment_history(
        'U',
        p_employment_history_rec,
        l_rowid,
        x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call table handler to update a row
    HZ_employment_history_PKG.Update_Row (

           x_Rowid      			=>   l_rowid,
           x_EMPLOYMENT_HISTORY_ID              =>   p_employment_history_rec.employment_history_id,
           x_BEGIN_DATE                  	=>   p_employment_history_rec.begin_date,
           x_PARTY_ID                    	=>   p_employment_history_rec.party_id,
           x_EMPLOYED_AS_TITLE           	=>   p_employment_history_rec.employed_as_title,
           x_EMPLOYED_BY_DIVISION_NAME   	=>   p_employment_history_rec.employed_by_division_name,
           x_EMPLOYED_BY_NAME_COMPANY    	=>   p_employment_history_rec.employed_by_name_company,
           x_END_DATE                    	=>   p_employment_history_rec.end_date,
           x_SUPERVISOR_NAME             	=>   p_employment_history_rec.supervisor_name,
           x_BRANCH                      	=>   p_employment_history_rec.branch,
           x_MILITARY_RANK               	=>   p_employment_history_rec.military_rank,
           x_SERVED                      	=>   p_employment_history_rec.served,
           x_STATION                     	=>   p_employment_history_rec.station,
           x_RESPONSIBILITY              	=>   p_employment_history_rec.responsibility,
           x_STATUS                             =>   p_employment_history_rec.status,
           x_CREATED_BY_MODULE           	=>   p_employment_history_rec.created_by_module,
           X_OBJECT_VERSION_NUMBER              =>   p_object_version_number,
           x_EMPLOYED_BY_PARTY_ID               =>   p_employment_history_rec.EMPLOYED_BY_PARTY_ID,
	   x_REASON_FOR_LEAVING                 =>   p_employment_history_rec.REASON_FOR_LEAVING,
	   x_FACULTY_POSITION_FLAG              =>   p_employment_history_rec.FACULTY_POSITION_FLAG,
	   x_TENURE_CODE                        =>   p_employment_history_rec.TENURE_CODE,
	   x_FRACTION_OF_TENURE                 =>   p_employment_history_rec.FRACTION_OF_TENURE,
	   x_EMPLOYMENT_TYPE_CODE               =>   p_employment_history_rec.EMPLOYMENT_TYPE_CODE,
	   x_EMPLOYED_AS_TITLE_CODE             =>   p_employment_history_rec.EMPLOYED_AS_TITLE_CODE,
	   x_WEEKLY_WORK_HOURS                  =>   p_employment_history_rec.WEEKLY_WORK_HOURS,
           x_COMMENTS                           =>   p_employment_history_rec.COMMENTS,
           x_APPLICATION_ID                     =>   p_employment_history_rec.APPLICATION_ID

          );


END do_update_employment_history;


/*===========================================================================+
 | PROCEDURE
 |              do_create_work_class
 |
 | DESCRIPTION
 |              Creates Work Class
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_work_class_id
 |          IN/ OUT:
 |                    p_work_class_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_create_work_class(
    p_work_class_rec              IN OUT  NOCOPY  WORK_CLASS_REC_TYPE,
    x_work_class_id               OUT     NOCOPY  NUMBER,
    x_return_status               IN OUT  NOCOPY  VARCHAR2
) IS

    l_dummy                             VARCHAR2(1);
    l_rowid                             ROWID;

BEGIN

    -- if primary key value is passed, check for uniqueness.
    IF p_work_class_rec.work_class_id IS NOT NULL AND
        p_work_class_rec.work_class_id <> FND_API.G_MISS_NUM
    THEN
        BEGIN
            SELECT 'Y' INTO l_dummy
            FROM   HZ_WORK_CLASS
            WHERE  WORK_CLASS_ID = p_work_class_rec.work_class_id;

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'work_class_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;

    -- validate work_class  record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_work_class(
        'C',
        p_work_class_rec,
        l_rowid,
        x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call table handler to insert a row

    HZ_WORK_CLASS_PKG.Insert_Row (

       x_WORK_CLASS_ID               =>   p_work_class_rec.work_class_id,
       x_LEVEL_OF_EXPERIENCE         =>   p_work_class_rec.LEVEL_OF_EXPERIENCE,
       x_WORK_CLASS_NAME             =>   p_work_class_rec.WORK_CLASS_NAME,
       x_EMPLOYMENT_HISTORY_ID       =>   p_work_class_rec.EMPLOYMENT_HISTORY_ID,
       x_STATUS                      =>   p_work_class_rec.STATUS,
       x_OBJECT_VERSION_NUMBER       =>   1,
       x_CREATED_BY_MODULE           =>   p_work_class_rec.CREATED_BY_MODULE,
       x_application_id              =>   p_work_class_rec.application_id

    );

    -- assign the primary key back
    x_work_class_id := p_work_class_rec.work_class_id;

END do_create_work_class;


/*===========================================================================+
 | PROCEDURE
 |              do_update_work_class
 |
 | DESCRIPTION
 |              Updates Employment history
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_work_class_rec
 |                    p_object_version_number
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_update_work_class(
    p_work_class_rec                     IN OUT NOCOPY  WORK_CLASS_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
) IS

    l_rowid                                     ROWID  := NULL;
    l_object_version_number                     NUMBER;
    l_party_id                                  NUMBER;
    l_native_language                           VARCHAR2(1);
    l_language_name                             VARCHAR2(4);

BEGIN

    -- check whether record has been updated by another user
    BEGIN
        -- check object_version_number
        SELECT rowid, object_version_number
        INTO l_rowid, l_object_version_number
        FROM HZ_WORK_CLASS
        WHERE work_class_id = p_work_class_rec.work_class_id
        FOR UPDATE NOWAIT;

        IF NOT
             (
              ( p_object_version_number IS NULL AND l_object_version_number IS NULL )
              OR
              ( p_object_version_number IS NOT NULL AND
                l_object_version_number IS NOT NULL AND
                p_object_version_number = l_object_version_number
              )
             )
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_WORK_CLASS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
            FND_MESSAGE.SET_TOKEN('RECORD', 'HZ_WORK_CLASS');
            FND_MESSAGE.SET_TOKEN('VALUE', NVL( TO_CHAR( p_work_class_rec.work_class_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    -- validate work class record
        HZ_REGISTRY_VALIDATE_V2PUB.validate_work_class(
            'U',
            p_work_class_rec,
            l_rowid,
            x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call table handler to update a row
    HZ_WORK_CLASS_PKG.Update_Row (

           x_Rowid                       =>   l_rowid,
           x_WORK_CLASS_ID               =>   p_work_class_rec.work_class_id,
           x_LEVEL_OF_EXPERIENCE         =>   p_work_class_rec.LEVEL_OF_EXPERIENCE,
           x_WORK_CLASS_NAME             =>   p_work_class_rec.WORK_CLASS_NAME,
           x_EMPLOYMENT_HISTORY_ID       =>   p_work_class_rec.EMPLOYMENT_HISTORY_ID,
           x_STATUS                      =>   p_work_class_rec.STATUS,
           x_OBJECT_VERSION_NUMBER       =>   p_OBJECT_VERSION_NUMBER,
           x_CREATED_BY_MODULE           =>   p_work_class_rec.CREATED_BY_MODULE,
           x_application_id              =>   p_work_class_rec.application_id

          );


END do_update_work_class;


/*===========================================================================+
 | PROCEDURE
 |              do_create_person_interest
 |
 | DESCRIPTION
 |              Creates Person Interest
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_person_interest_id
 |          IN/ OUT:
 |                    p_person_interest_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_create_person_interest(
    p_person_interest_rec              IN OUT  NOCOPY  PERSON_INTEREST_REC_TYPE,
    x_person_interest_id               OUT     NOCOPY  NUMBER,
    x_return_status               IN OUT  NOCOPY  VARCHAR2
) IS

    l_dummy                             VARCHAR2(1);
    l_rowid                             ROWID;

BEGIN

    -- if primary key value is passed, check for uniqueness.
    IF p_person_interest_rec.person_interest_id IS NOT NULL AND
        p_person_interest_rec.person_interest_id <> FND_API.G_MISS_NUM
    THEN
        BEGIN
            SELECT 'Y' INTO l_dummy
            FROM   HZ_person_interest
            WHERE  person_interest_ID = p_person_interest_rec.person_interest_id;

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'person_interest_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;

    -- validate person_interest  record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_person_interest(
        'C',
        p_person_interest_rec,
        l_rowid,
        x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call table handler to insert a row
    HZ_person_interest_PKG.Insert_Row (

       x_person_interest_ID 		=>   p_person_interest_rec.person_interest_id,
       x_LEVEL_OF_INTEREST  		=>   p_person_interest_rec.LEVEL_OF_INTEREST,
       x_PARTY_ID           		=>   p_person_interest_rec.PARTY_ID,
       x_LEVEL_OF_PARTICIPATION         =>   p_person_interest_rec.LEVEL_OF_PARTICIPATION,
       x_INTEREST_TYPE_CODE 		=>   p_person_interest_rec.INTEREST_TYPE_CODE,
       x_SPORT_INDICATOR       	        =>   p_person_interest_rec.SPORT_INDICATOR,
       x_INTEREST_NAME         		=>   p_person_interest_rec.INTEREST_NAME,
       x_COMMENTS            		=>   p_person_interest_rec.COMMENTS,
       x_SUB_INTEREST_TYPE_CODE         =>   p_person_interest_rec.SUB_INTEREST_TYPE_CODE,
       x_TEAM   			=>   p_person_interest_rec.TEAM,
       x_SINCE  	                =>   p_person_interest_rec.SINCE,
       x_OBJECT_VERSION_NUMBER 	        =>   1,
       x_STATUS                		=>   p_person_interest_rec.STATUS,
       x_CREATED_BY_MODULE     		=>   p_person_interest_rec.CREATED_BY_MODULE,
       x_APPLICATION_ID        		=>   p_person_interest_rec.APPLICATION_ID

    );

    -- assign the primary key back
    x_person_interest_id := p_person_interest_rec.person_interest_id;

END do_create_person_interest;


/*===========================================================================+
 | PROCEDURE
 |              do_update_person_interest
 |
 | DESCRIPTION
 |              Updates Employment history
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_person_interest_rec
 |                    p_object_version_number
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_update_person_interest(
    p_person_interest_rec                     IN OUT NOCOPY  person_interest_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
) IS

    l_rowid                                     ROWID  := NULL;
    l_object_version_number                     NUMBER;
    l_party_id                                  NUMBER;
    l_native_language                           VARCHAR2(1);
    l_language_name                             VARCHAR2(4);

BEGIN

    -- check whether record has been updated by another user
    BEGIN
        -- check object_version_number
        SELECT rowid, object_version_number
        INTO l_rowid, l_object_version_number
        FROM HZ_person_interest
        WHERE person_interest_id = p_person_interest_rec.person_interest_id
        FOR UPDATE NOWAIT;

        IF NOT
             (
              ( p_object_version_number IS NULL AND l_object_version_number IS NULL )
              OR
              ( p_object_version_number IS NOT NULL AND
                l_object_version_number IS NOT NULL AND
                p_object_version_number = l_object_version_number
              )
             )
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_person_interest');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
            FND_MESSAGE.SET_TOKEN('RECORD', 'HZ_person_interest');
            FND_MESSAGE.SET_TOKEN('VALUE', NVL( TO_CHAR( p_person_interest_rec.person_interest_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    -- validate work class record
        HZ_REGISTRY_VALIDATE_V2PUB.validate_person_interest(
            'U',
            p_person_interest_rec,
            l_rowid,
            x_return_status);


    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call table handler to update a row
    HZ_person_interest_PKG.Update_Row (

       x_Rowid                       	=>   l_rowid,
       x_person_interest_ID 		=>   p_person_interest_rec.person_interest_id,
       x_LEVEL_OF_INTEREST  		=>   p_person_interest_rec.LEVEL_OF_INTEREST,
       x_PARTY_ID           		=>   p_person_interest_rec.PARTY_ID,
       x_LEVEL_OF_PARTICIPATION         =>   p_person_interest_rec.LEVEL_OF_PARTICIPATION,
       x_INTEREST_TYPE_CODE 		=>   p_person_interest_rec.INTEREST_TYPE_CODE,
       x_SPORT_INDICATOR       	        =>   p_person_interest_rec.SPORT_INDICATOR,
       x_INTEREST_NAME         		=>   p_person_interest_rec.INTEREST_NAME,
       x_COMMENTS            		=>   p_person_interest_rec.COMMENTS,
       x_SUB_INTEREST_TYPE_CODE         =>   p_person_interest_rec.SUB_INTEREST_TYPE_CODE,
       x_TEAM   			=>   p_person_interest_rec.TEAM,
       x_SINCE  	                =>   p_person_interest_rec.SINCE,
       x_OBJECT_VERSION_NUMBER 	        =>   p_OBJECT_VERSION_NUMBER,
       x_STATUS                		=>   p_person_interest_rec.STATUS,
       x_CREATED_BY_MODULE     		=>   p_person_interest_rec.CREATED_BY_MODULE,
       x_APPLICATION_ID        		=>   p_person_interest_rec.APPLICATION_ID

          );


END do_update_person_interest;


--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_person_language
 *
 * DESCRIPTION
 *     Creates person language.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_person_language_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_person_language_rec          Person language record.
 *   IN/OUT:
 *   OUT:
 *     x_language_use_reference_id    Language use reference ID.
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

PROCEDURE create_person_language(
    p_init_msg_list                         IN      VARCHAR2:= FND_API.G_FALSE,
    p_person_language_rec                   IN      PERSON_LANGUAGE_REC_TYPE,
    x_language_use_reference_id             OUT NOCOPY     NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
) IS

    l_api_name                       CONSTANT       VARCHAR2(30) := 'create_person_language';
    l_person_language_rec                           PERSON_LANGUAGE_REC_TYPE := p_person_language_rec;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT create_person_language;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_create_person_language(
        l_person_language_rec,
        x_language_use_reference_id,
        x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.create_person_language_event (
         l_person_language_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_person_language(
         p_operation                 => 'I',
         p_language_use_reference_id => x_language_use_reference_id);
     END IF;
   END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_person_language;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_person_language;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_person_language;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END create_person_language;

/**
 * PROCEDURE update_person_language
 *
 * DESCRIPTION
 *     Updates person language.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_person_language_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_person_language_rec          Person language record.
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

PROCEDURE  update_person_language(
    p_init_msg_list                         IN      VARCHAR2:= FND_API.G_FALSE,
    p_person_language_rec                   IN      PERSON_LANGUAGE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY  NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
) IS

    l_api_name                       CONSTANT       VARCHAR2(30) := 'update_person_language';
    l_person_language_rec                           PERSON_LANGUAGE_REC_TYPE := p_person_language_rec;
    l_old_person_language_rec                       PERSON_LANGUAGE_REC_TYPE;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT update_person_language;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   get_person_language_rec (
     p_language_use_reference_id  => p_person_language_rec.language_use_reference_id,
     p_person_language_rec        => l_old_person_language_rec,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call to business logic.
    do_update_person_language(
        l_person_language_rec,
        p_object_version_number,
        x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.update_person_language_event (
         l_person_language_rec,
         l_old_person_language_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_person_language(
         p_operation                 => 'U',
         p_language_use_reference_id => l_person_language_rec.language_use_reference_id);
     END IF;
   END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_person_language;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_person_language;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_person_language;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END update_person_language;

/**
 * PROCEDURE get_class_category_rec
 *
 * DESCRIPTION
 *     Gets class category record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_PERSON_LANGUAGE_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_language_use_reference_id    Language use reference ID.
 *   IN/OUT:
 *   OUT:
 *     x_person_language_rec          Returned person language record.
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
 *   0s-23-2001    Indrajit Sen        o Created.
 *   MAY-15-2002   Herve Yu            o Update the x_person_language_rec.language_use_reference_id
 *                                       must be initiated to p_language_use_reference_id
 *
 */

PROCEDURE get_person_language_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_language_use_reference_id             IN     NUMBER,
    p_person_language_rec                   OUT    NOCOPY PERSON_LANGUAGE_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_api_name                              CONSTANT VARCHAR2(30) := 'get_person_language_rec';

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_language_use_reference_id IS NULL OR
       p_language_use_reference_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'language_use_reference_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- The x_person_language_rec.language_use_reference_id must be initiated to p_language_use_reference_id
    p_person_language_rec.language_use_reference_id := p_language_use_reference_id;

    HZ_PERSON_LANGUAGE_PKG.Select_Row (
        X_LANGUAGE_USE_REFERENCE_ID             => p_person_language_rec.language_use_reference_id,
        X_LANGUAGE_NAME                         => p_person_language_rec.language_name,
        X_PARTY_ID                              => p_person_language_rec.party_id,
        X_NATIVE_LANGUAGE                       => p_person_language_rec.native_language,
        X_PRIMARY_LANGUAGE_INDICATOR            => p_person_language_rec.primary_language_indicator,
        X_READS_LEVEL                           => p_person_language_rec.reads_level,
        X_SPEAKS_LEVEL                          => p_person_language_rec.speaks_level,
        X_WRITES_LEVEL                          => p_person_language_rec.writes_level,
        X_SPOKEN_COMPREHENSION_LEVEL            => p_person_language_rec.spoken_comprehension_level,
        X_STATUS                                => p_person_language_rec.status,
        X_CREATED_BY_MODULE                     => p_person_language_rec.created_by_module,
        X_APPLICATION_ID                        => p_person_language_rec.application_id
    );

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

END get_person_language_rec;

/**
 * PROCEDURE create_citizenship
 *
 * DESCRIPTION
 *     Creates citizenship.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_citizenship_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_citizenship_rec              Citizenship record.
 *   IN/OUT:
 *   OUT:
 *     x_citizenship_id               Citizenship ID.
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
 *   13-Jan-2003  Porkodi Chinnandar  o Created.
 *
 */

PROCEDURE create_citizenship(
    p_init_msg_list                         IN      VARCHAR2:= FND_API.G_FALSE,
    p_citizenship_rec                       IN      CITIZENSHIP_REC_TYPE,
    x_citizenship_id                        OUT NOCOPY     NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
) IS

    l_api_name                       CONSTANT       VARCHAR2(30) := 'create_citizenship';
    l_citizenship_rec                               CITIZENSHIP_REC_TYPE := p_citizenship_rec;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT create_citizenship;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_create_citizenship(
        l_citizenship_rec,
        x_citizenship_id,
        x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.create_citizenship_event (
         l_citizenship_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_citizenship(
         p_operation      => 'I',
         p_citizenship_id => x_citizenship_id);
     END IF;
   END IF;


    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_citizenship;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_citizenship;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_citizenship;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END create_citizenship;

/**
 * PROCEDURE update_citizenship
 *
 * DESCRIPTION
 *     Updates citizenship.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_citizenship_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_citizenship_rec              Citizenship record.
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
 *   13-Jan-2001  Porkodi Chinnandar   o Created.
 *
 */

PROCEDURE  update_citizenship(
    p_init_msg_list                         IN     VARCHAR2:= FND_API.G_FALSE,
    p_citizenship_rec                       IN     CITIZENSHIP_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY  NUMBER,
    x_return_status                         OUT    NOCOPY  VARCHAR2,
    x_msg_count                             OUT    NOCOPY  NUMBER,
    x_msg_data                              OUT    NOCOPY  VARCHAR2
) IS

    l_api_name                       CONSTANT   VARCHAR2(30) := 'update_citizenship';
    l_citizenship_rec                           CITIZENSHIP_REC_TYPE := p_citizenship_rec;
    l_old_citizenship_rec                       CITIZENSHIP_REC_TYPE;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT update_citizenship;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   get_citizenship_rec (
     p_init_msg_list              => FND_API.G_FALSE,
     p_citizenship_id             => p_citizenship_rec.citizenship_id,
     x_citizenship_rec            => l_old_citizenship_rec,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call to business logic.
    do_update_citizenship(
        l_citizenship_rec,
        p_object_version_number,
        x_return_status);

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
        -- Invoke business event system.
        HZ_BUSINESS_EVENT_V2PVT.update_citizenship_event (
          l_citizenship_rec,
          l_old_citizenship_rec );
      END IF;

      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
        HZ_POPULATE_BOT_PKG.pop_hz_citizenship(
          p_operation      => 'U',
          p_citizenship_id => l_citizenship_rec.citizenship_id);
      END IF;
   END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_citizenship;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_citizenship;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_citizenship;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END update_citizenship;

/**
 * PROCEDURE get_citizenship_rec
 *
 * DESCRIPTION
 *     Gets class citizenship record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_CITIZENSHIP_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_citizenship_id               Citizenship ID.
 *   IN/OUT:
 *   OUT:
 *     x_citizenship_rec              Returned citizenship record.
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
 *   13-Jan-2003   Porkodi Chinnandar  o Created.
 *
 */

PROCEDURE get_citizenship_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_citizenship_id                        IN     NUMBER,
    x_citizenship_rec                       OUT NOCOPY    CITIZENSHIP_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2

) IS

    l_api_name                              CONSTANT VARCHAR2(30) := 'get_citizenship_rec';

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_citizenship_id IS NULL OR
       p_citizenship_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'citizenship_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- The x_citizenship_rec.citizenship_id must be initiated to x_citizenship_id
    x_citizenship_rec.citizenship_id := p_citizenship_id;

    HZ_CITIZENSHIP_PKG.Select_Row (
	X_CITIZENSHIP_ID     	 =>   x_citizenship_rec.citizenship_id,
	X_BIRTH_OR_SELECTED  	 =>   x_citizenship_rec.birth_or_selected,
	X_PARTY_ID           	 =>   x_citizenship_rec.party_id,
	X_COUNTRY_CODE       	 =>   x_citizenship_rec.country_code,
	X_DATE_DISOWNED      	 =>   x_citizenship_rec.date_disowned,
	X_DATE_RECOGNIZED    	 =>   x_citizenship_rec.date_recognized,
	X_DOCUMENT_REFERENCE 	 =>   x_citizenship_rec.document_reference,
	X_DOCUMENT_TYPE      	 =>   x_citizenship_rec.document_type,
	X_END_DATE           	 =>   x_citizenship_rec.end_date,
	X_STATUS             	 =>   x_citizenship_rec.status,
	X_APPLICATION_ID         =>   x_citizenship_rec.application_id,
	X_CREATED_BY_MODULE      =>   x_citizenship_rec.created_by_module

    );

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

END get_citizenship_rec;


/**
 * PROCEDURE create_education
 *
 * DESCRIPTION
 *     Creates education.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  *     HZ_BUSINESS_EVENT_V2PVT.create_education_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_education_rec                Education record.
 *   IN/OUT:
 *   OUT:
 *     x_education_id                 Education ID.
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
 *   13-Jan-2003  Porkodi Chinnandar  o Created.
 *
 */

PROCEDURE create_education(
    p_init_msg_list                         IN      VARCHAR2:= FND_API.G_FALSE,
    p_education_rec                       IN      EDUCATION_REC_TYPE,
    x_education_id                        OUT NOCOPY     NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
) IS

    l_api_name                       CONSTANT       VARCHAR2(30) := 'create_education';
    l_education_rec                               EDUCATION_REC_TYPE := p_education_rec;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT create_education;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.

    do_create_education(
        l_education_rec,
        x_education_id,
        x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.create_education_event (
         l_education_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_education(
         p_operation    => 'I',
         p_EDUCATION_ID => x_education_id);
     END IF;
   END IF;


    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_education;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_education;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_education;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END create_education;

/**
 * PROCEDURE update_education
 *
 * DESCRIPTION
 *     Updates education.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_education_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_education_rec                Education record.
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
 *   13-Jan-2001  Porkodi Chinnandar   o Created.
 *
 */

PROCEDURE  update_education(
    p_init_msg_list                         IN     VARCHAR2:= FND_API.G_FALSE,
    p_education_rec                       IN     EDUCATION_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY  NUMBER,
    x_return_status                         OUT    NOCOPY  VARCHAR2,
    x_msg_count                             OUT    NOCOPY  NUMBER,
    x_msg_data                              OUT    NOCOPY  VARCHAR2
) IS

    l_api_name                       CONSTANT   VARCHAR2(30) := 'update_education';
    l_education_rec                           EDUCATION_REC_TYPE := p_education_rec;
    l_old_education_rec                       EDUCATION_REC_TYPE;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT update_education;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   get_education_rec (
     p_education_id             => p_education_rec.education_id,
     x_education_rec            => l_old_education_rec,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call to business logic.
    do_update_education(
        l_education_rec,
        p_object_version_number,
        x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.update_education_event (
         l_education_rec,
         l_old_education_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_education(
         p_operation    => 'U',
         p_EDUCATION_ID => l_education_rec.education_id);
     END IF;
   END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_education;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_education;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_education;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END update_education;

/**
 * PROCEDURE get_education_rec
 *
 * DESCRIPTION
 *     Gets class education record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_EDUCATION_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_education_id                 Education ID.
 *   IN/OUT:
 *   OUT:
 *     x_education_rec              Returned education record.
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
 *   13-Jan-2003   Porkodi Chinnandar  o Created.
 *
 */


 PROCEDURE get_education_rec (
     p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
     p_education_id                          IN     NUMBER,
     x_education_rec                         OUT NOCOPY     EDUCATION_REC_TYPE,
     x_return_status                            OUT NOCOPY    VARCHAR2,
     x_msg_count                                OUT NOCOPY    NUMBER,
     x_msg_data                                 OUT NOCOPY    VARCHAR2

) IS

    l_api_name                              CONSTANT VARCHAR2(30) := 'get_education_rec';

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_education_id IS NULL OR
       p_education_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'education_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- The x_education_rec.education_id must be initiated to p_education_id
    x_education_rec.education_id := p_education_id;


    HZ_EDUCATION_PKG.Select_Row (
	X_EDUCATION_ID     	 =>   x_education_rec.education_id,
	X_PARTY_ID           	 =>   x_education_rec.party_id,
        X_COURSE_MAJOR           =>   x_education_rec.course_major,
	X_DEGREE_RECEIVED      	 =>   x_education_rec.degree_received,
	X_START_DATE_ATTENDED  	 =>   x_education_rec.start_date_attended,
	X_LAST_DATE_ATTENDED   	 =>   x_education_rec.last_date_attended,
	X_SCHOOL_ATTENDED_NAME 	 =>   x_education_rec.school_attended_name,
	X_SCHOOL_PARTY_ID      	 =>   x_education_rec.school_party_id,
	X_TYPE_OF_SCHOOL       	 =>   x_education_rec.type_of_school,
	X_STATUS             	 =>   x_education_rec.status,
	X_APPLICATION_ID         =>   x_education_rec.application_id,
	X_CREATED_BY_MODULE      =>   x_education_rec.created_by_module

    );

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

END get_education_rec;

/**
 * PROCEDURE create_employment_history
 *
 * DESCRIPTION
 *     Creates Employment history.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
*     HZ_BUSINESS_EVENT_V2PVT.create_emp_history_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_employment_history_rec       Employment_history record.
 *   IN/OUT:
 *   OUT:
 *     x_employment_history_id        Employment history ID.
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
 *   13-Jan-2003  Porkodi Chinnandar  o Created.
 *
 */

PROCEDURE create_employment_history(
    p_init_msg_list                         IN      VARCHAR2:= FND_API.G_FALSE,
    p_employment_history_rec                IN      EMPLOYMENT_HISTORY_REC_TYPE,
    x_employment_history_id                          OUT NOCOPY     NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
) IS

    l_api_name                       CONSTANT       VARCHAR2(30) := 'create_employment_history';
    l_employment_history_rec                        EMPLOYMENT_HISTORY_REC_TYPE := p_employment_history_rec;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT create_employment_history;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_create_employment_history(
        l_employment_history_rec,
        x_employment_history_id,
        x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.create_emp_history_event (
         l_employment_history_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_employment_history(
         p_operation             => 'I',
         p_EMPLOYMENT_HISTORY_ID => x_employment_history_id);
     END IF;
   END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_employment_history;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_employment_history;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_employment_history;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END create_employment_history;

/**
 * PROCEDURE update_employment_history
 *
 * DESCRIPTION
 *     Updates Employment_history.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_emp_history_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_employment_history_rec       Employment history record.
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
 *   13-Jan-2001  Porkodi Chinnandar   o Created.
 *
 */

PROCEDURE  update_employment_history(
    p_init_msg_list                         IN     VARCHAR2:= FND_API.G_FALSE,
    p_employment_history_rec                IN     EMPLOYMENT_HISTORY_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY  NUMBER,
    x_return_status                         OUT    NOCOPY  VARCHAR2,
    x_msg_count                             OUT    NOCOPY  NUMBER,
    x_msg_data                              OUT    NOCOPY  VARCHAR2
) IS

    l_api_name                                         CONSTANT   VARCHAR2(30) := 'update_employment_history';
    l_employment_history_rec                           EMPLOYMENT_HISTORY_REC_TYPE := p_employment_history_rec;
    l_old_employment_history_rec                       EMPLOYMENT_HISTORY_REC_TYPE;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT update_employment_history;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   get_employment_history_rec (
     p_employment_history_id      => p_employment_history_rec.employment_history_id,
     x_employment_history_rec     => l_old_employment_history_rec,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call to business logic.
    do_update_employment_history(
        l_employment_history_rec,
        p_object_version_number,
        x_return_status);

     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
         -- Invoke business event system.
         HZ_BUSINESS_EVENT_V2PVT.update_emp_history_event (
           l_employment_history_rec,
           l_old_employment_history_rec );
       END IF;

       IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
         HZ_POPULATE_BOT_PKG.pop_hz_employment_history(
           p_operation             => 'U',
           p_EMPLOYMENT_HISTORY_ID => l_employment_history_rec.employment_history_id);
       END IF;
     END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_employment_history;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_employment_history;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_employment_history;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END update_employment_history;

/**
 * PROCEDURE get_employment_history_rec
 *
 * DESCRIPTION
 *     Gets class employment_history record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_EMPLOYMENT_HISTORY_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_employment_history_id        Employment history ID.
 *   IN/OUT:
 *   OUT:
 *     x_employment_history_rec       Returned employment_history record.
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
 *   13-Jan-2003   Porkodi Chinnandar  o Created.
 *
 */

PROCEDURE get_employment_history_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_employment_history_id                 IN     NUMBER,
    x_employment_history_rec                   OUT NOCOPY EMPLOYMENT_HISTORY_REC_TYPE,
    x_return_status                            OUT NOCOPY    VARCHAR2,
    x_msg_count                                OUT NOCOPY    NUMBER,
    x_msg_data                                 OUT NOCOPY    VARCHAR2
)
 IS

    l_api_name                              CONSTANT VARCHAR2(30) := 'get_employment_history_rec';

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_employment_history_id IS NULL OR
       p_employment_history_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'employment_history_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- The x_employment_history_rec.employment_history_id must be initiated to p_employment_history_id
    x_employment_history_rec.employment_history_id := p_employment_history_id;

    HZ_EMPLOYMENT_HISTORY_PKG.Select_Row (

	X_EMPLOYMENT_HISTORY_ID         =>      x_employment_history_rec.employment_history_id,
	X_BEGIN_DATE            	=>      x_employment_history_rec.begin_date,
	X_PARTY_ID              	=>      x_employment_history_rec.party_id,
	X_EMPLOYED_AS_TITLE     	=>      x_employment_history_rec.employed_as_title,
	X_EMPLOYED_BY_DIVISION_NAME 	=>      x_employment_history_rec.employed_by_division_name,
	X_EMPLOYED_BY_NAME_COMPANY   	=>      x_employment_history_rec.employed_by_name_company,
	X_END_DATE                  	=>      x_employment_history_rec.end_date,
	X_SUPERVISOR_NAME           	=>      x_employment_history_rec.supervisor_name,
	X_BRANCH                    	=>      x_employment_history_rec.branch,
	X_MILITARY_RANK             	=>      x_employment_history_rec.military_rank,
	X_SERVED                    	=>      x_employment_history_rec.served,
	X_STATION                   	=>      x_employment_history_rec.station,
	X_RESPONSIBILITY            	=>      x_employment_history_rec.responsibility,
	X_STATUS                    	=>      x_employment_history_rec.status,
	X_APPLICATION_ID            	=>      x_employment_history_rec.application_id,
	X_CREATED_BY_MODULE         	=>      x_employment_history_rec.created_by_module,
	X_REASON_FOR_LEAVING        	=>      x_employment_history_rec.reason_for_leaving,
	X_FACULTY_POSITION_FLAG      	=>      x_employment_history_rec.faculty_position_flag,
	X_TENURE_CODE               	=>      x_employment_history_rec.tenure_code,
	X_FRACTION_OF_TENURE        	=>      x_employment_history_rec.fraction_of_tenure,
	X_EMPLOYMENT_TYPE_CODE      	=>      x_employment_history_rec.employment_type_code,
	X_EMPLOYED_AS_TITLE_CODE    	=>      x_employment_history_rec.employed_as_title_code,
	X_WEEKLY_WORK_HOURS         	=>      x_employment_history_rec.weekly_work_hours,
	X_COMMENTS                  	=>      x_employment_history_rec.comments
    );

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

END get_employment_history_rec;

/**
 * PROCEDURE create_work_class
 *
 * DESCRIPTION
 *     Creates work class.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_work_class_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_work_class_rec               Work_class record.
 *   IN/OUT:
 *   OUT:
 *     x_work_class_id                Work class ID.
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
 *   13-Jan-2003  Porkodi Chinnandar  o Created.
 *
 */

PROCEDURE create_work_class(
    p_init_msg_list                         IN      VARCHAR2:= FND_API.G_FALSE,
    p_work_class_rec                        IN      WORK_CLASS_REC_TYPE,
    x_work_class_id                         OUT NOCOPY     NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
) IS

    l_api_name                       CONSTANT       VARCHAR2(30) := 'create_work_class';
    l_work_class_rec                                WORK_CLASS_REC_TYPE := p_work_class_rec;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT create_work_class;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.

    do_create_work_class(
        l_work_class_rec,
        x_work_class_id,
        x_return_status);

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
        -- Invoke business event system.
        HZ_BUSINESS_EVENT_V2PVT.create_work_class_event (
          l_work_class_rec );
      END IF;

      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
        HZ_POPULATE_BOT_PKG.pop_hz_work_class(
          p_operation     => 'I',
          p_work_class_id => x_work_class_id);
      END IF;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_work_class;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_work_class;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_work_class;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END create_work_class;

/**
 * PROCEDURE update_work_class
 *
 * DESCRIPTION
 *     Updates work_class.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_work_class_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_work_class_rec               Work class record.
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
 *   13-Jan-2001  Porkodi Chinnandar   o Created.
 *
 */

PROCEDURE  update_work_class(
    p_init_msg_list                         IN     VARCHAR2:= FND_API.G_FALSE,
    p_work_class_rec                        IN     WORK_CLASS_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY  NUMBER,
    x_return_status                         OUT    NOCOPY  VARCHAR2,
    x_msg_count                             OUT    NOCOPY  NUMBER,
    x_msg_data                              OUT    NOCOPY  VARCHAR2
) IS

    l_api_name                       CONSTANT   VARCHAR2(30) := 'update_work_class';
    l_work_class_rec                                   WORK_CLASS_REC_TYPE := p_work_class_rec;
    l_old_work_class_rec                               WORK_CLASS_REC_TYPE;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT update_work_class;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   get_work_class_rec (
     p_work_class_id      => p_work_class_rec.work_class_id,
     x_work_class_rec     => l_old_work_class_rec,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call to business logic.
    do_update_work_class(
        l_work_class_rec,
        p_object_version_number,
        x_return_status);

     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
         -- Invoke business event system.
         HZ_BUSINESS_EVENT_V2PVT.update_work_class_event (
           l_work_class_rec,
           l_old_work_class_rec );
       END IF;

       IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
         HZ_POPULATE_BOT_PKG.pop_hz_work_class(
           p_operation     => 'U',
           p_work_class_id => l_work_class_rec.work_class_id);
       END IF;
     END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_work_class;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_work_class;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_work_class;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END update_work_class;

/**
 * PROCEDURE get_work_class_rec
 *
 * DESCRIPTION
 *     Gets class work_class record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_WORK_CLASS_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_work_class_id                Work class ID.
 *   IN/OUT:
 *   OUT:
 *     x_work_class_rec               Returned work_class record.
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
 *   13-Jan-2003   Porkodi Chinnandar  o Created.
 *
 */

PROCEDURE get_work_class_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_work_class_id                         IN     NUMBER,
    x_work_class_rec                           OUT NOCOPY WORK_CLASS_REC_TYPE,
    x_return_status                            OUT NOCOPY    VARCHAR2,
    x_msg_count                                OUT NOCOPY    NUMBER,
    x_msg_data                                 OUT NOCOPY    VARCHAR2
)
 IS

    l_api_name                              CONSTANT VARCHAR2(30) := 'get_work_class_rec';

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_work_class_id IS NULL OR
       p_work_class_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'work_class_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- The x_work_class_rec.work_class_id must be initiated to p_work_class_id
    x_work_class_rec.work_class_id := p_work_class_id;

    HZ_WORK_CLASS_PKG.Select_Row (

	x_work_class_id                 =>      x_work_class_rec.work_class_id,
	x_level_of_experience           =>      x_work_class_rec.level_of_experience,
	x_work_class_name               =>      x_work_class_rec.work_class_name,
	x_employment_history_id         =>      x_work_class_rec.employment_history_id,
	x_status                        =>      x_work_class_rec.status,
	x_application_id                =>      x_work_class_rec.application_id,
        x_created_by_module             =>      x_work_class_rec.created_by_module
    );

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

END get_work_class_rec;

/**
 * PROCEDURE create_person_interest
 *
 * DESCRIPTION
 *     Creates Person interest.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_per_interest_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_person_interest_rec          Person Interest record.
 *   IN/OUT:
 *   OUT:
 *     x_person_interest_id           Person Interest ID.
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
 *   13-Jan-2003  Porkodi Chinnandar  o Created.
 *
 */

PROCEDURE create_person_interest(
    p_init_msg_list                         IN      VARCHAR2:= FND_API.G_FALSE,
    p_person_interest_rec                   IN      PERSON_INTEREST_REC_TYPE,
    x_person_interest_id                         OUT NOCOPY     NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
) IS

    l_api_name                       CONSTANT       VARCHAR2(30) := 'create_person_interest';
    l_person_interest_rec                                PERSON_INTEREST_REC_TYPE := p_person_interest_rec;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT create_person_interest;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_create_person_interest(
        l_person_interest_rec,
        x_person_interest_id,
        x_return_status);

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
        -- Invoke business event system.
        HZ_BUSINESS_EVENT_V2PVT.create_person_interest_event (
          l_person_interest_rec );
      END IF;

      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
        HZ_POPULATE_BOT_PKG.pop_hz_person_interest(
          p_operation          => 'I',
          p_person_interest_id => x_person_interest_id);
      END IF;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_person_interest;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_person_interest;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_person_interest;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END create_person_interest;

/**
 * PROCEDURE update_person_interest
 *
 * DESCRIPTION
 *     Updates person_interest.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_per_interest_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_person_interest_rec          Person Interest record.
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
 *   13-Jan-2001  Porkodi Chinnandar   o Created.
 *
 */

PROCEDURE  update_person_interest(
    p_init_msg_list                         IN     VARCHAR2:= FND_API.G_FALSE,
    p_person_interest_rec                   IN     PERSON_INTEREST_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY  NUMBER,
    x_return_status                         OUT    NOCOPY  VARCHAR2,
    x_msg_count                             OUT    NOCOPY  NUMBER,
    x_msg_data                              OUT    NOCOPY  VARCHAR2
) IS

    l_api_name                       CONSTANT   VARCHAR2(30) := 'update_person_interest';
    l_person_interest_rec                                   PERSON_INTEREST_REC_TYPE := p_person_interest_rec;
    l_old_person_interest_rec                               PERSON_INTEREST_REC_TYPE;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT update_person_interest;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   get_person_interest_rec (
     p_person_interest_id      => p_person_interest_rec.person_interest_id,
     x_person_interest_rec     => l_old_person_interest_rec,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call to business logic.
    do_update_person_interest(
        l_person_interest_rec,
        p_object_version_number,
        x_return_status);

     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
         -- Invoke business event system.
         HZ_BUSINESS_EVENT_V2PVT.update_person_interest_event (
           l_person_interest_rec,
           l_old_person_interest_rec );
       END IF;

       IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
         HZ_POPULATE_BOT_PKG.pop_hz_person_interest(
           p_operation          => 'U',
           p_person_interest_id => l_person_interest_rec.person_interest_id);
       END IF;
     END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_person_interest;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_person_interest;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_person_interest;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

END update_person_interest;

/**
 * PROCEDURE get_person_interest_rec
 *
 * DESCRIPTION
 *     Gets class person_interest record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_PERSON_INTEREST_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_person_interest_id           Person Interest ID.
 *   IN/OUT:
 *   OUT:
 *     x_person_interest_rec          Returned person_interest record.
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
 *   13-Jan-2003   Porkodi Chinnandar  o Created.
 *
 */

PROCEDURE get_person_interest_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_person_interest_id                    IN     NUMBER,
    x_person_interest_rec                      OUT NOCOPY PERSON_INTEREST_REC_TYPE,
    x_return_status                            OUT NOCOPY    VARCHAR2,
    x_msg_count                                OUT NOCOPY    NUMBER,
    x_msg_data                                 OUT NOCOPY    VARCHAR2
)
 IS

    l_api_name                              CONSTANT VARCHAR2(30) := 'get_person_interest_rec';

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_person_interest_id IS NULL OR
       p_person_interest_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'person_interest_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- The x_person_interest_rec.person_interest_id must be initiated to p_person_interest_id
    x_person_interest_rec.person_interest_id := p_person_interest_id;

    HZ_PERSON_INTEREST_PKG.Select_Row (

	  x_person_interest_id               => x_person_interest_rec.person_interest_id,
	  x_level_of_interest                => x_person_interest_rec.level_of_interest,
	  x_party_id                         => x_person_interest_rec.party_id,
	  x_level_of_participation           => x_person_interest_rec.level_of_participation,
	  x_interest_type_code               => x_person_interest_rec.interest_type_code,
	  x_comments                         => x_person_interest_rec.comments,
	  x_sport_indicator                  => x_person_interest_rec.sport_indicator,
	  x_sub_interest_type_code           => x_person_interest_rec.sub_interest_type_code,
	  x_interest_name                    => x_person_interest_rec.interest_name,
	  x_team                             => x_person_interest_rec.team,
	  x_since                            => x_person_interest_rec.since,
	  x_status                           => x_person_interest_rec.status,
	  x_application_id                   => x_person_interest_rec.application_id,
	  x_created_by_module                => x_person_interest_rec.created_by_module
    );

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

END get_person_interest_rec;

END HZ_PERSON_INFO_V2PUB;

/

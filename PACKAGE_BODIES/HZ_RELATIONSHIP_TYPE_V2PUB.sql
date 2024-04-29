--------------------------------------------------------
--  DDL for Package Body HZ_RELATIONSHIP_TYPE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_RELATIONSHIP_TYPE_V2PUB" AS
/*$Header: ARH2RTSB.pls 120.11 2005/10/28 10:12:54 nkanbapu noship $ */

----------------------------------
-- declaration of global variables
----------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30) := 'HZ_RELATIONSHIP_TYPE_V2PUB';

g_str               VARCHAR2(2000) := ' ';

------------------------------------
-- declaration of private procedures
------------------------------------

PROCEDURE do_create_relationship_type(
    p_relationship_type_rec         IN OUT  NOCOPY RELATIONSHIP_TYPE_REC_TYPE,
    x_relationship_type_id          OUT NOCOPY     NUMBER,
    x_return_status                 IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_update_relationship_type(
    p_relationship_type_rec         IN OUT  NOCOPY RELATIONSHIP_TYPE_REC_TYPE,
    p_object_version_number         IN OUT NOCOPY  NUMBER,
    x_return_status                 IN OUT NOCOPY  VARCHAR2
);

/* Added for bug 3831950 */

FUNCTION validate_fnd_lookup
( p_lookup_type   IN     VARCHAR2,
  p_column_value  IN     VARCHAR2,
  p_meaning       IN     VARCHAR2 /*bug: 4218352*/
)RETURN VARCHAR2
IS
	CURSOR c1 IS
	SELECT 'Y'
	FROM   ar_lookups
	WHERE  lookup_type = p_lookup_type
	AND    ( lookup_code = p_column_value or
	         meaning     = p_meaning )
	AND rownum = 1;
	l_exist VARCHAR2(1);
BEGIN
	IF (    p_column_value IS NOT NULL
		AND p_column_value <> fnd_api.g_miss_char ) THEN
		OPEN c1;
		FETCH c1 INTO l_exist;
		IF c1%NOTFOUND THEN
			RETURN 'N';
		END IF;
		CLOSE c1;
	END IF;
	IF (l_exist = 'Y')THEN
		RETURN 'Y';
	END IF;
	RETURN 'N';
END validate_fnd_lookup;


----------------------------
-- body of public procedures
----------------------------

/*===========================================================================+
 | PROCEDURE
 |              do_create_relationship_type
 |
 | DESCRIPTION
 |              Creates a relation type.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_relationship_type_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_create_relationship_type(
    p_relationship_type_rec         IN OUT  NOCOPY RELATIONSHIP_TYPE_REC_TYPE,
    x_relationship_type_id          OUT NOCOPY     NUMBER,
    x_return_status                 IN OUT NOCOPY  VARCHAR2
) IS

    l_relationship_type_rec             RELATIONSHIP_TYPE_REC_TYPE := p_relationship_type_rec;
    l_relationship_type                 HZ_RELATIONSHIP_TYPES.RELATIONSHIP_TYPE%TYPE;
    l_direction_code                    HZ_RELATIONSHIP_TYPES.DIRECTION_CODE%TYPE;
    l_relationship_type_id              NUMBER := p_relationship_type_rec.relationship_type_id;
    l_forward_role      		VARCHAR2(30):=p_relationship_type_rec.forward_role;
    l_backward_role                     VARCHAR2(30):=p_relationship_type_rec.backward_role;
    l_forward_rel_code                  VARCHAR2(30):=p_relationship_type_rec.forward_rel_code;
    l_relationship_type_id2             NUMBER;

    l_hierarchical_flag                 VARCHAR2(1) := NVL(p_relationship_type_rec.hierarchical_flag, 'N');
    l_create_party_flag                 VARCHAR2(1) := NVL(p_relationship_type_rec.create_party_flag, 'N');
    l_allow_relate_to_self_flag         VARCHAR2(1) := NVL(p_relationship_type_rec.allow_relate_to_self_flag, 'N');
    l_allow_circular_relationships      VARCHAR2(1) := NVL(p_relationship_type_rec.allow_circular_relationships, 'Y');
    l_incl_unrelated_entities           VARCHAR2(1) := NVL(p_relationship_type_rec.incl_unrelated_entities, 'N');
    l_multiple_parent_allowed           VARCHAR2(1) := NVL(p_relationship_type_rec.multiple_parent_allowed, 'N');
    l_status                            VARCHAR2(1) := p_relationship_type_rec.status;
    l_code                              VARCHAR2(30);
    l_count                             NUMBER;
    l_rowid                             ROWID;
    l_dummy                             VARCHAR2(1);
    l_role                              VARCHAR2(30);
    l_lookup_rowid                      rowid;
    l_temp_var                          NUMBER;

BEGIN

    --If primary key value is passed, check for uniqueness.
    IF l_relationship_type_id <> FND_API.G_MISS_NUM
       AND
       l_relationship_type_id IS NOT NULL
    THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   HZ_RELATIONSHIP_TYPES
            WHERE  RELATIONSHIP_TYPE_ID = l_relationship_type_id;

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'relationship_type_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

    END IF;



    -- validate the record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_relationship_type(
        p_create_update_flag                    => 'C',
        p_relationship_type_rec                 => p_relationship_type_rec,
        p_rowid                                 => l_rowid,
        x_return_status                         => x_return_status);

    --if validation failed at any point, then raise an exception to stop processing
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_relationship_type := p_relationship_type_rec.relationship_type;


    -- set proper value for multiple_parent_allowed for
    -- hierarchical relationship type
    IF p_relationship_type_rec.multiple_parent_allowed IS NULL
       OR
       p_relationship_type_rec.multiple_parent_allowed = FND_API.G_MISS_CHAR
    THEN
        IF l_hierarchical_flag = 'N' THEN
            l_multiple_parent_allowed := 'Y';
        ELSE
            l_multiple_parent_allowed := 'N';
        END IF;
    END IF;

    -- set proper value for allow_circular_relationships for
    -- hierarchical relationship type
    IF p_relationship_type_rec.allow_circular_relationships IS NULL
       OR
       p_relationship_type_rec.allow_circular_relationships = FND_API.G_MISS_CHAR
    THEN
        IF l_hierarchical_flag = 'N' THEN
            l_allow_circular_relationships := 'Y';
        ELSE
            l_allow_circular_relationships := 'N';
        END IF;
    END IF;

    /* Bug Fix : 2644154 */
    IF p_relationship_type_rec.subject_type IN ('ORGANIZATION','PERSON','GROUP') AND
       p_relationship_type_rec.object_type  IN ('ORGANIZATION','PERSON','GROUP')
    THEN
       l_create_party_flag := 'Y';
    END IF;


    -- make call to table handler to create forward record
    HZ_RELATIONSHIP_TYPES_PKG.Insert_Row (
        X_RELATIONSHIP_TYPE_ID                  => l_relationship_type_id,
        X_RELATIONSHIP_TYPE                     => l_relationship_type,
        X_FORWARD_REL_CODE                      => p_relationship_type_rec.forward_rel_code,
        X_BACKWARD_REL_CODE                     => p_relationship_type_rec.backward_rel_code,
        X_DIRECTION_CODE                        => p_relationship_type_rec.direction_code,
        X_HIERARCHICAL_FLAG                     => l_hierarchical_flag,
        X_CREATE_PARTY_FLAG                     => l_create_party_flag,
        X_ALLOW_RELATE_TO_SELF_FLAG             => p_relationship_type_rec.allow_relate_to_self_flag,
        X_SUBJECT_TYPE                          => p_relationship_type_rec.subject_type,
        X_OBJECT_TYPE                           => p_relationship_type_rec.object_type,
        X_STATUS                                => p_relationship_type_rec.status,
        X_ALLOW_CIRCULAR_RELATIONSHIPS          => l_allow_circular_relationships,
        X_MULTIPLE_PARENT_ALLOWED               => l_multiple_parent_allowed,
        X_INCL_UNRELATED_ENTITIES               => l_incl_unrelated_entities,
        X_ROLE                                  => p_relationship_type_rec.forward_role,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_relationship_type_rec.created_by_module,
        X_APPLICATION_ID                        => p_relationship_type_rec.application_id
    );

    x_relationship_type_id := l_relationship_type_id;
    l_relationship_type_id := null;

    -- create the lookups for relationship role if
    -- that is not already created. this is needed because
    -- these lookups were introduced later and for backward
    -- compatibility purposes, we cannot make those mandatory.
    BEGIN
        -- get the role value since it might have been created by table handler
        SELECT ROLE INTO l_role
        FROM   HZ_RELATIONSHIP_TYPES
        WHERE  RELATIONSHIP_TYPE_ID = x_relationship_type_id;

        -- check if the lookup value is already present for the role
-- Bug 3831950 : Use functino validate_fnd_lookup to check available lookup code
-- Bug 4218352 : Added 'meaning' param for function validate_fnd_lookup
        IF(validate_fnd_lookup('HZ_RELATIONSHIP_ROLE', l_role, l_role) = 'N') then
            BEGIN
            -- so the lookup is not present, we need to create it
            FND_LOOKUP_VALUES_PKG.INSERT_ROW (
            X_ROWID => l_lookup_rowid,
            X_LOOKUP_TYPE => 'HZ_RELATIONSHIP_ROLE',
            X_SECURITY_GROUP_ID => 0,
            X_VIEW_APPLICATION_ID => 222,
            X_LOOKUP_CODE => l_role,
            X_TAG => null,
            X_ATTRIBUTE_CATEGORY => null,
            X_ATTRIBUTE1 => null,
            X_ATTRIBUTE2 => null,
            X_ATTRIBUTE3 => null,
            X_ATTRIBUTE4 => null,
            X_ENABLED_FLAG => 'Y',
            X_START_DATE_ACTIVE => SYSDATE,
            X_END_DATE_ACTIVE => null,
            X_TERRITORY_CODE => null,
            X_ATTRIBUTE5 => null,
            X_ATTRIBUTE6 => null,
            X_ATTRIBUTE7 => null,
            X_ATTRIBUTE8 => null,
            X_ATTRIBUTE9 => null,
            X_ATTRIBUTE10 => null,
            X_ATTRIBUTE11 => null,
            X_ATTRIBUTE12 => null,
            X_ATTRIBUTE13 => null,
            X_ATTRIBUTE14 => null,
            X_ATTRIBUTE15 => null,
            X_MEANING => l_role,
            X_DESCRIPTION => l_role,
            X_CREATION_DATE => SYSDATE,
            X_CREATED_BY => HZ_UTILITY_V2PUB.CREATED_BY,
            X_LAST_UPDATE_DATE => SYSDATE,
            X_LAST_UPDATED_BY => HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
            X_LAST_UPDATE_LOGIN => null);
            EXCEPTION
            WHEN OTHERS THEN
            RAISE FND_API.G_EXC_ERROR;
            END;
        END IF;

    END;


    -- make another call to table handler to create backward record
    -- if FORWARD_REL_CODE <> BACKWARD_REL_CODE
    IF p_relationship_type_rec.forward_rel_code <> p_relationship_type_rec.backward_rel_code
    THEN
        IF p_relationship_type_rec.direction_code = 'P'
        THEN
            l_direction_code := 'C';
        ELSE
            l_direction_code := 'P';
        END IF;

        -- make call to table handler to create backward record
        HZ_RELATIONSHIP_TYPES_PKG.Insert_Row (
            X_RELATIONSHIP_TYPE_ID                  => l_relationship_type_id,
            X_RELATIONSHIP_TYPE                     => l_relationship_type,
            X_FORWARD_REL_CODE                      => p_relationship_type_rec.backward_rel_code,
            X_BACKWARD_REL_CODE                     => p_relationship_type_rec.forward_rel_code,
            X_DIRECTION_CODE                        => l_direction_code,
            X_HIERARCHICAL_FLAG                     => l_hierarchical_flag,
            X_CREATE_PARTY_FLAG                     => l_create_party_flag,
            X_ALLOW_RELATE_TO_SELF_FLAG             => p_relationship_type_rec.allow_relate_to_self_flag,
            X_SUBJECT_TYPE                          => p_relationship_type_rec.object_type,
            X_OBJECT_TYPE                           => p_relationship_type_rec.subject_type,
            X_STATUS                                => p_relationship_type_rec.status,
            X_ALLOW_CIRCULAR_RELATIONSHIPS          => l_allow_circular_relationships,
            X_MULTIPLE_PARENT_ALLOWED               => l_multiple_parent_allowed,
            X_INCL_UNRELATED_ENTITIES               => l_incl_unrelated_entities,
            X_ROLE                                  => p_relationship_type_rec.backward_role,
            X_OBJECT_VERSION_NUMBER                 => 1,
            X_CREATED_BY_MODULE                     => p_relationship_type_rec.created_by_module,
            X_APPLICATION_ID                        => p_relationship_type_rec.application_id
        );

        -- create the lookup for relationship role if
        -- that is not already created. this is needed because
        -- these lookups were introduced later and for backward
        -- compatibility purposes, we cannot make those mandatory.
        BEGIN
            -- get the role value since it might have been created by table handler
            SELECT ROLE INTO l_role
            FROM   HZ_RELATIONSHIP_TYPES
            WHERE  RELATIONSHIP_TYPE_ID = l_relationship_type_id;

            -- check if the lookup value is already present for the role
-- Bug 3831950 : Use functino validate_fnd_lookup to check available lookup code
-- Bug 4218352 : Added 'meaning' param for function validate_fnd_lookup
        IF(validate_fnd_lookup('HZ_RELATIONSHIP_ROLE', l_role, l_role) = 'N') then
                BEGIN
                -- so the lookup is not present, we need to create it
                FND_LOOKUP_VALUES_PKG.INSERT_ROW (
                X_ROWID => l_lookup_rowid,
                X_LOOKUP_TYPE => 'HZ_RELATIONSHIP_ROLE',
                X_SECURITY_GROUP_ID => 0,
                X_VIEW_APPLICATION_ID => 222,
                X_LOOKUP_CODE => l_role,
                X_TAG => null,
                X_ATTRIBUTE_CATEGORY => null,
                X_ATTRIBUTE1 => null,
                X_ATTRIBUTE2 => null,
                X_ATTRIBUTE3 => null,
                X_ATTRIBUTE4 => null,
                X_ENABLED_FLAG => 'Y',
                X_START_DATE_ACTIVE => SYSDATE,
                X_END_DATE_ACTIVE => null,
                X_TERRITORY_CODE => null,
                X_ATTRIBUTE5 => null,
                X_ATTRIBUTE6 => null,
                X_ATTRIBUTE7 => null,
                X_ATTRIBUTE8 => null,
                X_ATTRIBUTE9 => null,
                X_ATTRIBUTE10 => null,
                X_ATTRIBUTE11 => null,
                X_ATTRIBUTE12 => null,
                X_ATTRIBUTE13 => null,
                X_ATTRIBUTE14 => null,
                X_ATTRIBUTE15 => null,
                X_MEANING => l_role,
                X_DESCRIPTION => l_role,
                X_CREATION_DATE => SYSDATE,
                X_CREATED_BY => HZ_UTILITY_V2PUB.CREATED_BY,
                X_LAST_UPDATE_DATE => SYSDATE,
                X_LAST_UPDATED_BY => HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
                X_LAST_UPDATE_LOGIN => null);
                EXCEPTION
                WHEN OTHERS THEN
                RAISE FND_API.G_EXC_ERROR;
                END;

            END IF;

        END;

    END IF;

    -- create lookup for the relationship type if it is not
    -- already created
    BEGIN
        -- check if the lookup value is already present for the relationship type
-- Bug 3831950 : Use functino validate_fnd_lookup to check available lookup code
-- Bug 4218352 : Added 'meaning' param for function validate_fnd_lookup
        IF(validate_fnd_lookup('HZ_RELATIONSHIP_TYPE', l_relationship_type, l_relationship_type) = 'N') then
        /* commented for bug 3831950
 	BEGIN
            SELECT 1 INTO l_temp_var
            FROM   AR_LOOKUPS
            WHERE  LOOKUP_TYPE = 'HZ_RELATIONSHIP_TYPE'
            AND    LOOKUP_CODE = l_relationship_type;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
*/
            BEGIN
            -- so the lookup is not present, we need to create it
            FND_LOOKUP_VALUES_PKG.INSERT_ROW (
            X_ROWID => l_lookup_rowid,
            X_LOOKUP_TYPE => 'HZ_RELATIONSHIP_TYPE',
            X_SECURITY_GROUP_ID => 0,
            X_VIEW_APPLICATION_ID => 222,
            X_LOOKUP_CODE => l_relationship_type,
            X_TAG => null,
            X_ATTRIBUTE_CATEGORY => null,
            X_ATTRIBUTE1 => null,
            X_ATTRIBUTE2 => null,
            X_ATTRIBUTE3 => null,
            X_ATTRIBUTE4 => null,
            X_ENABLED_FLAG => 'Y',
            X_START_DATE_ACTIVE => SYSDATE,
            X_END_DATE_ACTIVE => null,
            X_TERRITORY_CODE => null,
            X_ATTRIBUTE5 => null,
            X_ATTRIBUTE6 => null,
            X_ATTRIBUTE7 => null,
            X_ATTRIBUTE8 => null,
            X_ATTRIBUTE9 => null,
            X_ATTRIBUTE10 => null,
            X_ATTRIBUTE11 => null,
            X_ATTRIBUTE12 => null,
            X_ATTRIBUTE13 => null,
            X_ATTRIBUTE14 => null,
            X_ATTRIBUTE15 => null,
            X_MEANING => l_relationship_type,
            X_DESCRIPTION => l_relationship_type,
            X_CREATION_DATE => SYSDATE,
            X_CREATED_BY => HZ_UTILITY_V2PUB.CREATED_BY,
            X_LAST_UPDATE_DATE => SYSDATE,
            X_LAST_UPDATED_BY => HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
            X_LAST_UPDATE_LOGIN => null);
            EXCEPTION
            WHEN OTHERS THEN
            RAISE FND_API.G_EXC_ERROR;
            END;
/* Commented for bug 3831950
	WHEN OTHERS THEN
               RAISE FND_API.G_EXC_ERROR;

        END;
*/
        END IF;

    END;

END do_create_relationship_type;


/*===========================================================================+
 | PROCEDURE
 |              do_update_relationship_type
 |
 | DESCRIPTION
 |              Updates a relation type.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_relationship_type_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_update_relationship_type(
    p_relationship_type_rec         IN OUT  NOCOPY RELATIONSHIP_TYPE_REC_TYPE,
    p_object_version_number         IN OUT NOCOPY  NUMBER,
    x_return_status                 IN OUT NOCOPY  VARCHAR2
) IS

    l_object_version_number                 NUMBER;
    l_rowid                                 ROWID;
    l_relationship_type                     HZ_RELATIONSHIP_TYPES.RELATIONSHIP_TYPE%TYPE;
    l_direction_code                        HZ_RELATIONSHIP_TYPES.DIRECTION_CODE%TYPE;
    l_forward_rel_code                      HZ_RELATIONSHIP_TYPES.FORWARD_REL_CODE%TYPE;
    l_backward_rel_code                     HZ_RELATIONSHIP_TYPES.BACKWARD_REL_CODE%TYPE;
    l_subject_type                          HZ_RELATIONSHIP_TYPES.SUBJECT_TYPE%TYPE;
    l_object_type                           HZ_RELATIONSHIP_TYPES.OBJECT_TYPE%TYPE;
    l_relationship_type_id                  NUMBER := p_relationship_type_rec.relationship_type_id;
    l_relationship_type_id2                 NUMBER;
    l_hierarchical_flag                     VARCHAR2(1) := 'N';
    l_create_party_flag                     VARCHAR2(1) := p_relationship_type_rec.create_party_flag;
    l_allow_relate_to_self_flag             VARCHAR2(1) := p_relationship_type_rec.allow_relate_to_self_flag;
    l_allow_circular_relationships          VARCHAR2(1) := p_relationship_type_rec.allow_circular_relationships;
    l_status                                VARCHAR2(1) := p_relationship_type_rec.status;


BEGIN

    -- check whether record has been updated by another user
    BEGIN

        SELECT OBJECT_VERSION_NUMBER,
               ROWID,
               RELATIONSHIP_TYPE,
               FORWARD_REL_CODE,
               BACKWARD_REL_CODE,
               SUBJECT_TYPE,
               OBJECT_TYPE
        INTO   l_object_version_number,
               l_rowid,
               l_relationship_type,
               l_forward_rel_code,
               l_backward_rel_code,
               l_subject_type,
               l_object_type
        FROM   HZ_RELATIONSHIP_TYPES
        WHERE  RELATIONSHIP_TYPE_ID  = p_relationship_type_rec.relationship_type_id
        FOR UPDATE OF RELATIONSHIP_TYPE_ID NOWAIT;

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
            FND_MESSAGE.SET_TOKEN('TABLE', 'relationship_type_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := NVL(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'relationship_type');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(p_relationship_type_rec.relationship_type_id),'null'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    /* Bug Fix : 2644154. Making the create_party_flag = 'Y' for the
       party relationship type because API should not allow the allow
       the user to update the create_party_flag from Y to N . */

    IF l_subject_type IN ('ORGANIZATION','PERSON','GROUP') AND
       l_object_type  IN ('ORGANIZATION','PERSON','GROUP')
    THEN
       p_relationship_type_rec.create_party_flag := 'Y';
    END IF;

    -- validate the record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_relationship_type(
        p_create_update_flag                    => 'U',
        p_relationship_type_rec                 => p_relationship_type_rec,
        p_rowid                                 => l_rowid,
        x_return_status                         => x_return_status);

    --if validation failed at any point, then raise an exception to stop processing
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    HZ_RELATIONSHIP_TYPES_PKG.Update_Row (
        X_Rowid                                 => l_rowid,
        X_RELATIONSHIP_TYPE_ID                  => NULL,
        X_RELATIONSHIP_TYPE                     => NULL,
        X_FORWARD_REL_CODE                      => NULL,
        X_BACKWARD_REL_CODE                     => NULL,
        X_DIRECTION_CODE                        => NULL,
        X_HIERARCHICAL_FLAG                     => p_relationship_type_rec.hierarchical_flag,
        X_CREATE_PARTY_FLAG                     => p_relationship_type_rec.create_party_flag,
        X_ALLOW_RELATE_TO_SELF_FLAG             => NULL,
        X_SUBJECT_TYPE                          => NULL,
        X_OBJECT_TYPE                           => NULL,
        X_STATUS                                => p_relationship_type_rec.status,
        X_ALLOW_CIRCULAR_RELATIONSHIPS          => NULL,
        X_MULTIPLE_PARENT_ALLOWED               => NULL,
        X_INCL_UNRELATED_ENTITIES               => p_relationship_type_rec.incl_unrelated_entities,
        X_ROLE                                  => p_relationship_type_rec.forward_role,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_relationship_type_rec.created_by_module,
        X_APPLICATION_ID                        => p_relationship_type_rec.application_id
    );

    -- now we want to find out the backward record and
    -- we want to update that as well to maintain consistency
    -- if if update request is for forward_rel_code, then
    -- we need to find the backward record and if request is
    -- for backward_rel_code, then we need to find the forward record.
    -- however, the logic is same.
    BEGIN
        SELECT ROWID
        INTO   l_rowid
        FROM   HZ_RELATIONSHIP_TYPES
        WHERE  RELATIONSHIP_TYPE = l_relationship_type
        AND    FORWARD_REL_CODE = l_backward_rel_code
        AND    BACKWARD_REL_CODE = l_forward_rel_code
        AND    SUBJECT_TYPE = l_object_type
        AND    OBJECT_TYPE = l_subject_type;

        --now update the backward record
        HZ_RELATIONSHIP_TYPES_PKG.Update_Row (
            X_Rowid                                 => l_rowid,
            X_RELATIONSHIP_TYPE_ID                  => NULL,
            X_RELATIONSHIP_TYPE                     => NULL,
            X_FORWARD_REL_CODE                      => NULL,
            X_BACKWARD_REL_CODE                     => NULL,
            X_DIRECTION_CODE                        => NULL,
            X_HIERARCHICAL_FLAG                     => p_relationship_type_rec.hierarchical_flag,
            X_CREATE_PARTY_FLAG                     => p_relationship_type_rec.create_party_flag,
            X_ALLOW_RELATE_TO_SELF_FLAG             => NULL,
            X_SUBJECT_TYPE                          => NULL,
            X_OBJECT_TYPE                           => NULL,
            X_STATUS                                => p_relationship_type_rec.status,
            X_ALLOW_CIRCULAR_RELATIONSHIPS          => NULL,
            X_MULTIPLE_PARENT_ALLOWED               => NULL,
            X_INCL_UNRELATED_ENTITIES               => p_relationship_type_rec.incl_unrelated_entities,
            X_ROLE                                  => p_relationship_type_rec.backward_role,
            X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
            X_CREATED_BY_MODULE                     => p_relationship_type_rec.created_by_module,
            X_APPLICATION_ID                        => p_relationship_type_rec.application_id
        );
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;

END do_update_relationship_type;


----------------------------
-- body of public procedures
----------------------------

/*===========================================================================+
 | PROCEDURE
 |              create_relationship_type
 |
 | DESCRIPTION
 |              Creates a relation type.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_relationship_type_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE create_relationship_type (
    p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE,
    p_relationship_type_rec     IN      RELATIONSHIP_TYPE_REC_TYPE,
    x_relationship_type_id      OUT NOCOPY     NUMBER,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
) IS

    l_api_name                CONSTANT  VARCHAR2(30) := 'create_relationship_type';
    l_api_version             CONSTANT  NUMBER       := 1.0;
    l_rowid                             ROWID        := NULL;
    l_count                             NUMBER       := 0;
    l_relationship_type_rec             RELATIONSHIP_TYPE_REC_TYPE := p_relationship_type_rec;


BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_relationship_type;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_create_relationship_type(
        p_relationship_type_rec         => l_relationship_type_rec,
        x_relationship_type_id          => x_relationship_type_id,
        x_return_status                 => x_return_status
       );

   --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_relationship_type;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_relationship_type;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_relationship_type;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

END create_relationship_type;


/*===========================================================================+
 | PROCEDURE
 |              update_relationship_type
 |
 | DESCRIPTION
 |              Updates a party relation type.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_person_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/
PROCEDURE update_relationship_type (
    p_init_msg_list             IN      VARCHAR2:= FND_API.G_FALSE,
    p_relationship_type_rec     IN      RELATIONSHIP_TYPE_REC_TYPE,
    p_object_version_number     IN OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
) IS

    l_api_name                CONSTANT  VARCHAR2(30) := 'update_relationship_type';
    l_api_version             CONSTANT  NUMBER       := 1.0;
    l_count                             NUMBER;
    l_rowid                             ROWID;
    l_relationship_type_rec             RELATIONSHIP_TYPE_REC_TYPE := p_relationship_type_rec;

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT update_relationship_type;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic
    do_update_relationship_type(
                                l_relationship_type_rec,
                                p_object_version_number,
                                x_return_status);

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_relationship_type;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_relationship_type;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO update_relationship_type;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END update_relationship_type;


/*===========================================================================+
 | FUNCTION
 |              in_instance_sets
 |
 | DESCRIPTION
 |              checks whether an instance id belongs to an instance
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_instance_set_name
 |                    p_instance_id
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : VARCHAR2 (Y/N)
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/
FUNCTION in_instance_sets (
    p_instance_set_name         IN      VARCHAR2,
    p_instance_id               IN      VARCHAR2
) RETURN  VARCHAR2
IS

    TYPE CurType IS REF CURSOR;
    cur CurType;
    l_ret            VARCHAR2(1) := 'N';
    l_object_name    VARCHAR2(80);
    l_column_name    VARCHAR2(80);
--    l_predicate      VARCHAR2(80);
--Bug fix 2700936

    l_predicate  FND_OBJECT_INSTANCE_SETS.predicate%TYPE;
    l_str            VARCHAR2(5000);
    rows             NUMBER;
    c                NUMBER;
    result           VARCHAR2(1) := 'N';

    CURSOR c_obj_inst
    IS
    SELECT OBJ_NAME,
           PK1_COLUMN_NAME,
           PREDICATE
    FROM   FND_OBJECTS FO,
           FND_OBJECT_INSTANCE_SETS FOIS
    WHERE  FOIS.INSTANCE_SET_NAME = p_instance_set_name
    AND    FOIS.OBJECT_ID = FO.OBJECT_ID;

    CURSOR c_parties(p_party_id IN NUMBER, p_party_type IN VARCHAR2)
    IS
    SELECT 'Y' RESULT
    FROM   HZ_PARTIES
    WHERE  PARTY_ID = p_party_id
    AND    PARTY_TYPE = p_party_type;
    r_parties c_parties%ROWTYPE;

BEGIN
    -- implementation using execute immediate
    /*
    open c_obj_inst;
    fetch c_obj_inst into l_object_name, l_column_name, l_predicate;
    close c_obj_inst;

    l_str := 'select ''Y'' from '||l_object_name||' where '||l_column_name||' = :pid and '||l_predicate;

    execute immediate l_str into result using p_instance_id;

    return result;  */

    -- implementation using dbms_sql
    /*
    open c_obj_inst;
    fetch c_obj_inst into l_object_name, l_column_name, l_predicate;
    close c_obj_inst;

    l_str := 'select ''Y'' from '||l_object_name||' where '||l_column_name||' = :pid and '||l_predicate;
    c := dbms_sql.open_cursor;
    if l_str <> g_str then
      dbms_sql.parse(c, l_str, dbms_sql.native);
      g_str := l_str;
    end if;
    dbms_sql.define_column(c, 1, result, 1);
    dbms_sql.bind_variable(c, ':pid', p_instance_id);
    rows := dbms_sql.execute(c);
    if dbms_sql.fetch_rows(c) > 0 then
      dbms_sql.column_value(c, 1, result);
    end if;
    dbms_sql.close_cursor(c);
    return result;
    */


    -- implementation using cursor for parties and ref cursor
    -- if the instance_set_name belongs to hz_parties then
    -- we do not use the dynamic sql formation
    IF p_instance_set_name in ('PERSON', 'ORGANIZATION', 'GROUP') THEN
        OPEN c_parties(p_instance_id, p_instance_set_name);
        FETCH c_parties INTO l_ret;
        CLOSE c_parties;
        RETURN l_ret;
    ELSE

        OPEN c_obj_inst;
        FETCH c_obj_inst INTO l_object_name, l_column_name, l_predicate;
        CLOSE c_obj_inst;

        -- if l_predicate is not null then the query should include that, otherwise not.
        IF l_predicate IS NOT NULL THEN
            l_str := 'select ''Y'' from '||l_object_name||' where '||l_column_name||' = :pid and '||l_predicate;
        ELSE
            l_str := 'select ''Y'' from '||l_object_name||' where '||l_column_name||' = :pid';
        END IF;

        EXECUTE IMMEDIATE l_str INTO l_ret USING p_instance_id;

        RETURN l_ret;

    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'N';
    WHEN OTHERS THEN
        RETURN 'N';
END in_instance_sets;

END HZ_RELATIONSHIP_TYPE_V2PUB;

/

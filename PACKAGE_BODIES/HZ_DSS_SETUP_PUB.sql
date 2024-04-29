--------------------------------------------------------
--  DDL for Package Body HZ_DSS_SETUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DSS_SETUP_PUB" AS
/*$Header: ARHPDSTB.pls 115.6 2003/01/08 07:39:03 jypandey noship $ */

----------------------------------
-- declaration of global variables
----------------------------------

-------------------------------------------------
-- private procedures and functions
-------------------------------------------------


--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_entity_profile
 *
 * DESCRIPTION
 *     Creates entity profile.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-06 -2002    Colathur Vijayan ("VJN")        o Created.
 *
 */

PROCEDURE create_entity_profile(
    p_init_msg_list           IN        VARCHAR2,
    p_dss_entity_profile      IN        DSS_ENTITY_PROFILE_TYPE,
    x_entity_id               OUT NOCOPY       NUMBER,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
) IS
    row_id varchar2(64);
BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_entity_profile;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- VALIDATION
    IF p_dss_entity_profile.object_id IS NOT NULL AND p_dss_entity_profile.instance_set_id IS NOT NULL
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OB_AND_INS_NON_NULL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    ELSIF p_dss_entity_profile.object_id IS NULL AND p_dss_entity_profile.instance_set_id IS NULL
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OB_AND_INS_BOTH_NULL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_dss_entity_profile.object_id IS NOT NULL
        THEN
          IF HZ_DSS_VALIDATE_PKG.exist_fnd_object_id(p_dss_entity_profile.object_id)= 'N'
              THEN
                  FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OBJ_ID_INVALID');
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;
           END IF;
    END IF;

    IF p_dss_entity_profile.instance_set_id IS NOT NULL
       THEN
          IF HZ_DSS_VALIDATE_PKG.exist_fnd_instance_set_id(p_dss_entity_profile.instance_set_id) = 'N'
              THEN
                  FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_INS_SET_ID_INVALID');
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;
          END IF;
    END IF;

    IF p_dss_entity_profile.parent_entity_id IS NOT NULL
       THEN
          IF HZ_DSS_VALIDATE_PKG.exist_entity_id(p_dss_entity_profile.parent_entity_id) = 'N'
              THEN
                  FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_PAR_ENT_ID_INVALID');
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;
           END IF;
     END IF;

    -- STATUS VALIDATION
    IF p_dss_entity_profile.status is not null then
      IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(
      p_dss_entity_profile.status, 'REGISTRY_STATUS')= 'N'
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_STATUS_VAL_INVALID');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

    ---validate group_assignment_level have a valid value
    IF (p_dss_entity_profile.group_assignment_level is null OR
        p_dss_entity_profile.group_assignment_level = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'group_assignment_level' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    ELSE

      IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(p_dss_entity_profile.
         group_assignment_level, 'HZ_DSS_GROUP_ASSIGN_LEVELS') = 'N'
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_ASS_LEVEL_INVALID');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- Call the low level table handler default status to A
    HZ_DSS_ENTITIES_PKG.Insert_Row (
        x_rowid                 => row_id,
        x_entity_id             => x_entity_id,
        x_status                => nvl(p_dss_entity_profile.status,'A') ,
        x_object_id             => p_dss_entity_profile.object_id,
        x_instance_set_id       => p_dss_entity_profile.instance_set_id,
        x_parent_entity_id      => p_dss_entity_profile.parent_entity_id,
        x_parent_fk_column1     => p_dss_entity_profile.parent_fk_column1,
        x_parent_fk_column2     => p_dss_entity_profile.parent_fk_column2,
        x_parent_fk_column3     => p_dss_entity_profile.parent_fk_column3,
        x_parent_fk_column4     => p_dss_entity_profile.parent_fk_column4,
        x_parent_fk_column5     => p_dss_entity_profile.parent_fk_column5,
        x_group_assignment_level=> p_dss_entity_profile.group_assignment_level ,
        x_object_version_number  => 1
    );


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_entity_profile;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_entity_profile;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_entity_profile;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END create_entity_profile ;





/**
 * PROCEDURE update_entity_profile
 *
 * DESCRIPTION
 *     Updates entity profile.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-06 -2002    Colathur Vijayan ("VJN")        o Created.
 *
 */

PROCEDURE update_entity_profile(
    p_init_msg_list           IN        VARCHAR2,
    p_dss_entity_profile      IN        DSS_ENTITY_PROFILE_TYPE,
    x_object_version_number   IN OUT NOCOPY    NUMBER,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
) IS
    l_object_version_number           NUMBER;
    l_rowid                           ROWID;
    l_object_id               HZ_DSS_ENTITIES.OBJECT_ID%TYPE;
    l_instance_set_id         HZ_DSS_ENTITIES.INSTANCE_SET_ID%TYPE;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT update_entity_profile;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- check whether record has been updated by another user. If not, lock it.

    BEGIN
        SELECT object_version_number, rowid , object_id, instance_set_id
        INTO   l_object_version_number, l_rowid , l_object_id , l_instance_set_id
        FROM   HZ_DSS_ENTITIES
        WHERE  entity_id = p_dss_entity_profile.entity_id
        FOR UPDATE NOWAIT;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_ENT_ID_INVALID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

        IF NOT ((x_object_version_number is null and l_object_version_number is null)
                OR (x_object_version_number = l_object_version_number))
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_DSS_ENTITIES');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        x_object_version_number := nvl(l_object_version_number, 1) + 1;


     -- VALIDATION

     -- Bug: 2620112 VALIDATION parent Entity ID is valid
    IF p_dss_entity_profile.parent_entity_id IS NOT NULL
       THEN
          IF HZ_DSS_VALIDATE_PKG.exist_entity_id(
             p_dss_entity_profile.parent_entity_id) = 'N'
              THEN
                  FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_PAR_ENT_ID_INVALID');
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;
           END IF;
     END IF;

     -- Bug: 2620112 VALIDATION group_assignment_level  is valid
    if p_dss_entity_profile.group_assignment_level = FND_API.G_MISS_CHAR then
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_TO_NULL');
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'GROUP_ASSIGNMENT_LEVEL' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    end if;

    if p_dss_entity_profile.group_assignment_level is not null  then
       IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(
          p_dss_entity_profile.group_assignment_level,
          'HZ_DSS_GROUP_ASSIGN_LEVELS') = 'N'
       THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_ASS_LEVEL_INVALID');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       END IF;
    end if;

     --Bug: 2620112 Validation that object_id or instance_set_id are
     --NON updateable
     IF  ( p_dss_entity_profile.object_id <> FND_API.G_MISS_NUM OR
           l_object_id IS NOT NULL )
       AND ( l_object_id IS NULL OR
             p_dss_entity_profile.object_id <> l_object_id ) THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'OBJECT_ID' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF  ( p_dss_entity_profile.instance_set_id <> FND_API.G_MISS_NUM OR
           l_instance_set_id IS NOT NULL )
       AND ( l_instance_set_id IS NULL OR
             p_dss_entity_profile.instance_set_id <> l_instance_set_id ) THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'INSTANCE_SET_ID' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- STATUS VALIDATION only if not null
    IF p_dss_entity_profile.status is not null then
      IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(
        p_dss_entity_profile.status, 'REGISTRY_STATUS')= 'N'
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_STATUS_VAL_INVALID');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;


    -- Call the low level table handler
    HZ_DSS_ENTITIES_PKG.Update_Row (
        x_rowid                 => l_rowid,
        x_status                => p_dss_entity_profile.status,
        x_object_id             => p_dss_entity_profile.object_id,
        x_instance_set_id       => p_dss_entity_profile.instance_set_id,
        x_parent_entity_id      => p_dss_entity_profile.parent_entity_id,
        x_parent_fk_column1     => p_dss_entity_profile.parent_fk_column1,
        x_parent_fk_column2     => p_dss_entity_profile.parent_fk_column2,
        x_parent_fk_column3     => p_dss_entity_profile.parent_fk_column3,
        x_parent_fk_column4     => p_dss_entity_profile.parent_fk_column4,
        x_parent_fk_column5     => p_dss_entity_profile.parent_fk_column5,
        x_group_assignment_level=> p_dss_entity_profile.group_assignment_level ,
        x_object_version_number => x_object_version_number );


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_entity_profile;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_entity_profile;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_entity_profile;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END update_entity_profile ;



--------------------------------------
-- create_scheme_function
--------------------------------------

/**
 * PROCEDURE create_scheme_function
 *
 * DESCRIPTION
 *     Creates a Function association for a particular Security Scheme.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-06 -2002    Colathur Vijayan ("VJN")        o Created.
 *
 */

PROCEDURE create_scheme_function (
 	p_init_msg_list			    IN  VARCHAR2,
 	p_dss_scheme_function		IN  dss_scheme_function_type,
 	x_return_status			    OUT NOCOPY VARCHAR2,
    x_msg_count				    OUT NOCOPY NUMBER,
    x_msg_data				    OUT NOCOPY VARCHAR2
)
IS
    row_id varchar2(64);
    l_duplicate_count NUMBER := 0;
BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_scheme_function ;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- VALIDATION

     --Bug 2645639 check if there already is a function defined
     --for combination of security_scheme_code and data operation

     select count(*) into l_duplicate_count
     from HZ_DSS_SCHEME_FUNCTIONS
     where security_scheme_code = p_dss_scheme_function.security_scheme_code
     and   data_operation_code  = p_dss_scheme_function.data_operation_code;

     IF l_duplicate_count >= 1 then
       FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_DUP_SCHEME_FUNCTION');
       FND_MESSAGE.SET_TOKEN('SCHEME' ,p_dss_scheme_function.security_scheme_code);
       FND_MESSAGE.SET_TOKEN('OPERATION' ,p_dss_scheme_function.data_operation_code);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

    ---Validate that security_scheme code is not null and is valid
    IF (p_dss_scheme_function.security_scheme_code is null OR
        p_dss_scheme_function.security_scheme_code = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'security_scheme_code' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    ELSE

      IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(p_dss_scheme_function.
         security_scheme_code,'HZ_SECURITY_SCHEMES')= 'N' THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_SEC_SCH_CODE_INVALID');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;


     ---Validate that data_operation_code is not null and is valid
    IF (p_dss_scheme_function.data_operation_code is null OR
        p_dss_scheme_function.data_operation_code = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'data_operation_code' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    ELSE
      IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(p_dss_scheme_function.
         data_operation_code, 'HZ_DATA_OPERATIONS')= 'N' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_DAT_OP_CODE_INVALID');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

     ---Validate that function_id is not null and is valid
    IF (p_dss_scheme_function.function_id is null OR
        p_dss_scheme_function.function_id = FND_API.G_MISS_NUM) THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'function_id' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    ELSE
      IF HZ_DSS_VALIDATE_PKG.exist_function_id(p_dss_scheme_function.
         function_id)= 'N' THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_FUN_ID_INVALID');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- STATUS VALIDATION
    IF p_dss_scheme_function.status is not null then
      IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(p_dss_scheme_function.status,
         'REGISTRY_STATUS')= 'N' THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_STATUS_VAL_INVALID');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;


    -- Call the low level table handler
    --default status to A
    HZ_DSS_SCHEME_FUNCTIONS_PKG.Insert_Row (
           x_rowid => row_id,
           x_security_scheme_code => p_dss_scheme_function.security_scheme_code,
           x_data_operation_code => p_dss_scheme_function.data_operation_code,
           x_function_id => p_dss_scheme_function.function_id,
           x_status => nvl(p_dss_scheme_function.status, 'A'),
           x_object_version_number => 1 );


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_scheme_function ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_scheme_function ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_scheme_function ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END create_scheme_function ;




/**
 * PROCEDURE update_scheme_function
 *
 * DESCRIPTION
 *     Updates Security Scheme.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-06 -2002    Colathur Vijayan ("VJN")        o Created.
 *
 */
PROCEDURE update_scheme_function (
  p_init_msg_list          IN  VARCHAR2,
  p_dss_scheme_function    IN  dss_scheme_function_type,
  x_object_version_number  IN OUT NOCOPY NUMBER,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2
)
 IS
    l_object_version_number           NUMBER;
    l_rowid                           ROWID;
BEGIN

    -- standard start of API savepoint
    SAVEPOINT update_scheme_function ;

     -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- check whether record has been updated by another user. If not, lock it.

    BEGIN
        SELECT object_version_number, rowid
        INTO   l_object_version_number, l_rowid
        FROM   HZ_DSS_SCHEME_FUNCTIONS
        WHERE  security_scheme_code = p_dss_scheme_function.security_scheme_code and
               data_operation_code  = p_dss_scheme_function.data_operation_code and
               function_id = p_dss_scheme_function.function_id
        FOR UPDATE NOWAIT;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_SCHEME_NOT_FOUND');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

        IF NOT ((x_object_version_number is null and l_object_version_number is null)
                OR (x_object_version_number = l_object_version_number))
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_DSS_SCHEME_FUNCTIONS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        x_object_version_number := nvl(l_object_version_number, 1) + 1;


    -- STATUS VALIDATION
    IF p_dss_scheme_function.status is not null then
      IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(
       p_dss_scheme_function.status, 'REGISTRY_STATUS')= 'N'
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_STATUS_VAL_INVALID');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;


    -- Call the low level table handler
    HZ_DSS_SCHEME_FUNCTIONS_PKG.Update_Row (
            x_rowid                      => l_rowid,
            x_status                     => p_dss_scheme_function.status,
            x_object_version_number      => x_object_version_number
) ;


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_scheme_function ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_scheme_function ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_scheme_function ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END update_scheme_function ;



END HZ_DSS_SETUP_PUB;

/

--------------------------------------------------------
--  DDL for Package Body HZ_DSS_GRANTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DSS_GRANTS_PUB" AS
/*$Header: ARHPDSXB.pls 120.4 2006/02/02 22:22:39 jhuang noship $ */

----------------------------------
-- declaration of global variables
----------------------------------

G_API_NAME                   VARCHAR2(30)    := 'HZ_DSS_GRANTS_PUB';
G_DSS_RESPONSIBILITY_ID      NUMBER(15);

-------------------------------------------------
-- private procedures and functions
-------------------------------------------------

/**
 * FUNCTION obtain_dss_instance_set_id
 *
 * DESCRIPTION
 *
 *     Obtains the Instance Set ID corresponding to the Object Instance Set
 *     for the given Data Sharing Group, against object HZ_DSS_GROUPS.
 *     This is a "special" Object Instance Sets meant to record the general
 *     grants to a Data Sharing Group, irrespective of the actual table being
 *     protected.
 *
 *     If such an Object Instance Set cannot be found, one is created.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   09-03-2002    Chris Saulit       o Created.
 */

FUNCTION obtain_dss_instance_set_id (
    p_dss_group_code              IN     VARCHAR2
) RETURN NUMBER IS

    l_instance_set_id               NUMBER;
    l_object_id                     NUMBER;
    l_rowid                         VARCHAR2(64);
    l_obj_name                      VARCHAR2(30) := 'HZ_DSS_GROUPS';

    CURSOR c_dss_ois (
      p_dss_group_code              IN VARCHAR2
    ) IS
    SELECT fois.instance_set_id
    FROM   fnd_object_instance_sets fois,
           fnd_objects fo
    WHERE  fo.obj_name = l_obj_name
    AND    fo.object_id = fois.object_id
    AND    fois.predicate LIKE '%''' || p_dss_group_code || '''%';

    CURSOR c_obj (
      p_obj_name                    IN VARCHAR2
    ) IS
    SELECT object_id
    FROM   fnd_objects
    WHERE  obj_name = p_obj_name;

BEGIN

    OPEN c_dss_ois(p_dss_group_code);
    FETCH c_dss_ois INTO l_instance_set_id;
    IF c_dss_ois%NOTFOUND THEN
      CLOSE c_dss_ois;

      --
      -- Object Instance Set not found ... create it!
      --
      OPEN c_obj(l_obj_name);
      FETCH c_obj INTO l_object_id;
      IF c_obj%NOTFOUND THEN
        CLOSE c_obj;
        -- Base Object not found!!!  This means seed data is not found.
      ELSE
        CLOSE c_obj;
        --
        --  Create the Object Instance Set!
        --
        SELECT fnd_object_instance_sets_s.NEXTVAL INTO l_instance_set_id FROM DUAL;

        fnd_object_instance_sets_pkg.insert_row(
          x_rowid                 => l_rowid,
          x_instance_set_id       => l_instance_set_id,
          x_instance_set_name     => 'HZ_DSS_BASE_' || l_instance_set_id,
          x_object_id             => l_object_id,
          x_predicate             => 'DSS_GROUP_CODE = ''' || p_dss_group_code ||'''',
          x_display_name          => 'HZ_DSS_BASE_' || l_instance_set_id,
          x_description           => 'HZ_DSS_BASE_' || l_instance_set_id,
          x_creation_date         => hz_utility_v2pub.creation_date,
          x_created_by            => hz_utility_v2pub.created_by,
          x_last_update_date      => hz_utility_v2pub.last_update_date,
          x_last_updated_by       => hz_utility_v2pub.last_updated_by,
          x_last_update_login     => hz_utility_v2pub.last_update_login
        );

      END IF;
    ELSE
      CLOSE c_dss_ois;
    END IF;

    RETURN l_instance_set_id;

EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;

END obtain_dss_instance_set_id;


/**
 * PROCEDURE do_create_fnd_grant
 *
 * DESCRIPTION
 *
 *     Creates a Grant to a Data Sharing Group for a particular data operation.
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
 *   08-13-2002    Chris Saulit       o Created.
 *
 */

PROCEDURE do_create_fnd_grant (
    p_dss_group_code              IN     VARCHAR2,
    p_data_operation_code         IN     VARCHAR2,
    p_dss_grantee_type            IN     VARCHAR2,
    p_dss_grantee_key             IN     VARCHAR2,
    p_grant_start_date            IN     DATE DEFAULT NULL,
    p_grant_end_date              IN     DATE DEFAULT NULL
) IS

    g_procedure_name              VARCHAR2(30) := 'DO_CREATE_FND_GRANT';
    l_fnd_grant_guid              RAW(100);
    l_fnd_success                 VARCHAR2(1);
    l_fnd_errorcode               NUMBER;
    l_base_instance_set_id        NUMBER;
    l_fnd_grantee_type            VARCHAR2(8);
    l_fnd_grantee_key             VARCHAR2(240);
    l_menu_name                   VARCHAR2(30);
    l_grantee_key_cnt             NUMBER;
    l_end_date                    DATE;

    CURSOR c_secured_entities(
      p_dss_group_code            IN VARCHAR2
    ) IS
    SELECT dse.dss_instance_set_id,
           fo.obj_name,
           dse.status
    FROM   hz_dss_secured_entities dse,
           fnd_object_instance_sets fois,
           fnd_objects fo
    WHERE  dse.dss_group_code = p_dss_group_code
    AND    fois.instance_set_id = dse.dss_instance_set_id
    AND    fo.object_id = fois.object_id ;

BEGIN

    -- Given a  Data Operation Code, determine to which Menu we should be granting
    l_menu_name := 'HZ_DSS_' || p_data_operation_code;

    --
    --  Validate the grantee information
    --

    IF p_dss_grantee_type NOT IN ('GROUP','USER','GLOBAL') THEN
      FND_MESSAGE.SET_NAME('FND','FND_GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE','Grantee type must be one of: GROUP, USER, GLOBAL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --
    --  Translate the "DSS" Grantee information into appropriate value for FND
    --

    l_fnd_grantee_type := SUBSTRB(p_dss_grantee_type,1,8);
    l_fnd_grantee_key  := SUBSTRB(p_dss_grantee_key,1,240);

    --
    --  Validate grantee key information
    --
/*
    IF l_fnd_grantee_type = 'USER' THEN
      -- Validate against FND_USER
      BEGIN
        SELECT 1
        INTO   l_grantee_key_cnt
        FROM   fnd_user
        WHERE  user_name = l_fnd_grantee_key
        AND    (start_date IS NULL OR start_date < SYSDATE)
        AND    (end_date IS NULL OR end_date > SYSDATE)
        AND    ROWNUM = 1;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('FND','FND_INVALID_USER');
          FND_MESSAGE.SET_TOKEN('USER_NAME',p_dss_grantee_key);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END;
    ELSIF l_fnd_grantee_type = 'GROUP' THEN
      -- validate against WF_ROLES
      BEGIN
        SELECT 1
        INTO   l_grantee_key_cnt
        FROM   wf_roles
        WHERE  name = l_fnd_grantee_key
        AND    orig_system LIKE 'FND_RESP%'
        AND    ROWNUM = 1;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('AR','HZ_DSS_INVALID_RESP');
          FND_MESSAGE.SET_TOKEN('RESP',p_dss_grantee_key);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END;

    END IF;
*/
    --
    --
    --  Create a "base" grant to represent the user's privilege on the Data Sharing Group
    --

    l_base_instance_set_id := obtain_dss_instance_set_id (p_dss_group_code);

    fnd_grants_pkg.grant_function (
      p_api_version                => 1,
      p_menu_name                  => l_menu_name,
      p_object_name                => 'HZ_DSS_GROUPS',
      p_instance_type              => 'SET',
      p_instance_set_id            => l_base_instance_set_id,
      p_grantee_type               => l_fnd_grantee_type, -- e.g. USER GROUP
      p_grantee_key                => l_fnd_grantee_key,
      p_start_date                 => SYSDATE,
      p_end_date                   => NULL,
      p_program_name               => G_API_NAME,
      -- The Data Sharing Group is stored in the grant TAG!
      p_program_tag                => p_dss_group_code,
      x_grant_guid                 => l_fnd_grant_guid,
      x_success                    => l_fnd_success,
      x_errorcode                  => l_fnd_errorcode
    );

    IF l_fnd_success <> FND_API.G_TRUE THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --
    -- Replicate the same grant to any entities secured by this Data Sharing Group
    --

    FOR l_secured_entity IN c_secured_entities(p_dss_group_code) LOOP

      IF l_secured_entity.status = 'A' THEN
        l_end_date := p_grant_end_date;
      ELSE
        l_end_date := SYSDATE;
      END IF;

      fnd_grants_pkg.grant_function (
        p_api_version             => 1,
        p_menu_name               => l_menu_name,
        p_object_name             => l_secured_entity.obj_name,
        p_instance_type           => 'SET',
        p_instance_set_id         => l_secured_entity.dss_instance_set_id,
        p_grantee_type            => l_fnd_grantee_type, -- e.g. USER GROUP
        p_grantee_key             => l_fnd_grantee_key,
        p_start_date              => NVL(p_grant_start_date, SYSDATE),
        p_end_date                => l_end_date,
        p_program_name            => G_API_NAME,
        -- The Data Sharing Group is stored in the grant TAG!
        p_program_tag             => p_dss_group_code,
        x_grant_guid              => l_fnd_grant_guid,
        x_success                 => l_fnd_success,
        x_errorcode               => l_fnd_errorcode
      );

      IF l_fnd_success <> FND_API.G_TRUE THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;

END do_create_fnd_grant;


/**
 * PROCEDURE do_revoke_fnd_grant
 *
 * DESCRIPTION
 *
 *     Revokes a Grant to a Data Sharing Group for a particular data operation.
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
 *   09-26-2002    Chris Saulit       o Created.
 *
 */

PROCEDURE do_revoke_fnd_grant (
    p_dss_group_code              IN     VARCHAR2,
    p_data_operation_code         IN     VARCHAR2,
    p_dss_grantee_type            IN     VARCHAR2,
    p_dss_grantee_key             IN     VARCHAR2
) IS

    g_procedure_name              VARCHAR2(30)    := 'DO_REVOKE_FND_GRANT';

    CURSOR c_fnd_grant IS
    SELECT grant_guid
    FROM   fnd_grants grants,
           fnd_menus menu
    WHERE  grants.menu_id = menu.menu_id
    AND    menu.menu_name = 'HZ_DSS_'||p_data_operation_code
    AND    program_tag = p_dss_group_code
    AND    grantee_type = p_dss_grantee_type
    AND    (p_dss_grantee_type = 'GLOBAL' OR
            p_dss_grantee_type <> 'GLOBAL' AND
            grantee_key = p_dss_grantee_key);

    l_fnd_grant_guid              RAW(100);
    l_fnd_success                 VARCHAR2(1);
    l_fnd_errorcode               NUMBER;

BEGIN

    --
    --  Get the guids of the grant that we wish to revoke, then
    --  call the FND function to revoke the grant.
    --

    OPEN c_fnd_grant;
    LOOP
      FETCH c_fnd_grant INTO l_fnd_grant_guid;
      IF c_fnd_grant%NOTFOUND THEN
        EXIT;
      END IF;

      fnd_grants_pkg.revoke_grant(
        p_api_version             => 1,
        p_grant_guid              => l_fnd_grant_guid,
        x_success                 => l_fnd_success,
        x_errorcode               => l_fnd_errorcode
      );

      IF l_fnd_success <> FND_API.G_TRUE THEN
        CLOSE c_fnd_grant;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
    CLOSE c_fnd_grant;

END do_revoke_fnd_grant;


--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_grant
 *
 * DESCRIPTION
 *
 *     Creates a set of Grants to a Data Sharing Group.
 *     This signature matches the UI and corresponds to a "UI Grant Create".
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   09-03-2002    Chris Saulit       o Created.
 *
 */

PROCEDURE create_grant (
    p_init_msg_list               IN     VARCHAR2,
    p_dss_group_code              IN     VARCHAR2,
    p_dss_grantee_type            IN     VARCHAR2,
    p_dss_grantee_key             IN     VARCHAR2,
    p_view_flag                   IN     VARCHAR2,
    p_insert_flag                 IN     VARCHAR2,
    p_update_flag                 IN     VARCHAR2,
    p_delete_flag                 IN     VARCHAR2,
    p_admin_flag                  IN     VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

    G_PROCEDURE_NAME              VARCHAR2(30)    := 'CREATE_GRANT';

    CURSOR c_dss_groups IS
    SELECT status
    FROM   hz_dss_groups_b
    WHERE  dss_group_code = p_dss_group_code;

    l_dsg_status                  VARCHAR2(1);
    l_end_date                    DATE;

BEGIN

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF p_init_msg_list IS NOT NULL AND
       FND_API.to_Boolean(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- standard start of API savepoint
    SAVEPOINT create_grant;

    OPEN c_dss_groups;
    FETCH c_dss_groups INTO l_dsg_status;
    CLOSE c_dss_groups;

    IF l_dsg_status IS NULL THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_CODE_INVALID');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_dsg_status <> 'A' THEN
      l_end_date := SYSDATE;
    END IF;

    IF p_view_flag = 'Y' THEN
      do_create_fnd_grant (
        p_dss_group_code          => p_dss_group_code,
        p_data_operation_code     => 'SELECT',
        p_dss_grantee_type        => p_dss_grantee_type,
        p_dss_grantee_key         => p_dss_grantee_key,
        p_grant_start_date        => SYSDATE,
        p_grant_end_date          => l_end_date
      );
    END IF;

    IF p_insert_flag = 'Y' THEN
      do_create_fnd_grant (
        p_dss_group_code          => p_dss_group_code,
        p_data_operation_code     => 'INSERT',
        p_dss_grantee_type        => p_dss_grantee_type,
        p_dss_grantee_key         => p_dss_grantee_key,
        p_grant_start_date        => SYSDATE,
        p_grant_end_date          => l_end_date
      );
    END IF;

    IF p_update_flag = 'Y' THEN
      do_create_fnd_grant (
        p_dss_group_code          => p_dss_group_code,
        p_data_operation_code     => 'UPDATE',
        p_dss_grantee_type        => p_dss_grantee_type,
        p_dss_grantee_key         => p_dss_grantee_key,
        p_grant_start_date        => SYSDATE,
        p_grant_end_date          => l_end_date
      );
    END IF;

    IF p_delete_flag = 'Y' THEN
      do_create_fnd_grant (
        p_dss_group_code          => p_dss_group_code,
        p_data_operation_code     => 'DELETE',
        p_dss_grantee_type        => p_dss_grantee_type,
        p_dss_grantee_key         => p_dss_grantee_key,
        p_grant_start_date        => SYSDATE,
        p_grant_end_date          => l_end_date
      );
    END IF;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_FALSE,
                  p_count => x_msg_count,
                  p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_grant ;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_grant ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO create_grant ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);


END create_grant;

/**
 * PROCEDURE create_grant
 *
 * DESCRIPTION
 *
 *     Creates a set of Grants to a Data Sharing Group.
 *     The procedure is called when a new secured entity is
 *     added to a dss group.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-30-2004    Jianying Huang       o Created.
 *
 */

PROCEDURE create_grant (
    p_init_msg_list               IN     VARCHAR2 DEFAULT NULL,
    p_dss_group_code              IN     VARCHAR2,
    p_dss_instance_set_id         IN     NUMBER,
    p_secured_entity_status       IN     VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

    CURSOR c_grant_exists IS
    SELECT dsg.status
    FROM   hz_dss_grants_v grants,
           hz_dss_groups_b dsg
    WHERE  dsg.dss_group_code = p_dss_group_code
    AND    grants.dss_group_code = p_dss_group_code
    AND    ROWNUM = 1;

    CURSOR c_objects IS
    SELECT obj_name
    FROM   fnd_objects obj,
           fnd_object_instance_sets ins
    WHERE  instance_set_id = p_dss_instance_set_id
    AND    ins.object_id = obj.object_id;

    CURSOR c_grants IS
    SELECT *
    FROM   hz_dss_grants_v
    WHERE  dss_group_code = p_dss_group_code;

    l_dsg_status                  VARCHAR2(1);
    l_obj_name                    VARCHAR2(30);
    l_end_date                    DATE;
    l_menu_name                   VARCHAR2(30);
    l_fnd_grant_guid              RAW(100);
    l_fnd_success                 VARCHAR2(1);
    l_fnd_errorcode               NUMBER;

BEGIN

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF p_init_msg_list IS NOT NULL AND
       FND_API.to_Boolean(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- return when no grants exists for this dss group.
    OPEN c_grant_exists;
    FETCH c_grant_exists INTO l_dsg_status;
    CLOSE c_grant_exists;

    IF l_dsg_status IS NULL THEN
      RETURN;
    END IF;

    -- standard start of API savepoint
    SAVEPOINT create_grant;

    --
    -- get object name
    --
    OPEN c_objects;
    FETCH c_objects INTO l_obj_name;
    CLOSE c_objects;

    IF l_obj_name IS NULL THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --
    -- set the end date to null when the dss group and the secured
    -- entity are active.
    -- set the end date to sysdate when the dss group or the secured
    -- entity are inactive.
    --
    IF l_dsg_status <> 'A' OR
       p_secured_entity_status <> 'A'
    THEN
      l_end_date := SYSDATE;
    END IF;

    FOR c_grants_rec IN c_grants LOOP EXIT WHEN c_grants%NOTFOUND;

      FOR i IN 1..4 LOOP

        l_menu_name := NULL;

        -- Given a  Data Operation Code, determine to which Menu we should be granting

        IF i = 1 AND c_grants_rec.view_flag = 'Y' THEN
          l_menu_name := 'SELECT';
        ELSIF i = 2 AND c_grants_rec.insert_flag = 'Y' THEN
          l_menu_name := 'INSERT';
        ELSIF i = 3 AND c_grants_rec.update_flag = 'Y' THEN
          l_menu_name := 'UPDATE';
        ELSIF i = 4 AND c_grants_rec.delete_flag = 'Y' THEN
          l_menu_name := 'DELETE';
        END IF;

        IF l_menu_name IS NOT NULL THEN
          l_menu_name := 'HZ_DSS_' || l_menu_name;

          fnd_grants_pkg.grant_function (
            p_api_version             => 1,
            p_menu_name               => l_menu_name,
            p_object_name             => l_obj_name,
            p_instance_type           => 'SET',
            p_instance_set_id         => p_dss_instance_set_id,
            p_grantee_type            => SUBSTRB(c_grants_rec.dss_grantee_type, 1, 8),
            p_grantee_key             => SUBSTRB(c_grants_rec.dss_grantee_key, 1, 240),
            p_start_date              => SYSDATE,
            p_end_date                => l_end_date,
            p_program_name            => G_API_NAME,
            -- The Data Sharing Group is stored in the grant TAG!
            p_program_tag             => p_dss_group_code,
            x_grant_guid              => l_fnd_grant_guid,
            x_success                 => l_fnd_success,
            x_errorcode               => l_fnd_errorcode
          );

          IF l_fnd_success <> FND_API.G_TRUE THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;

      END LOOP;

    END LOOP;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_FALSE,
                  p_count => x_msg_count,
                  p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_grant ;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_grant ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO create_grant ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

END create_grant;

/**
 * PROCEDURE update_grant
 *
 * DESCRIPTION
 *
 *     Updates a set of Grants against a Data Sharing Group.
 *     This signature matches the UI and corresponds to a "UI Grant Update".
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   09-03-2002    Chris Saulit       o Created.
 *
 */

PROCEDURE update_grant (
    p_init_msg_list               IN     VARCHAR2,
    p_dss_group_code              IN     VARCHAR2,
    p_dss_grantee_type            IN     VARCHAR2,
    p_dss_grantee_key             IN     VARCHAR2,
    p_view_flag                   IN     VARCHAR2,
    p_insert_flag                 IN     VARCHAR2,
    p_update_flag                 IN     VARCHAR2,
    p_delete_flag                 IN     VARCHAR2,
    p_admin_flag                  IN     VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

    CURSOR c_grant IS
    SELECT NVL(view_flag,'N'), NVL(insert_flag,'N'),
           NVL(update_flag,'N'), NVL(delete_flag,'N'),
           dsg.status
    FROM   hz_dss_grants_v grants, hz_dss_groups_b dsg
    WHERE  grants.dss_group_code = p_dss_group_code
    AND    dss_grantee_type   = p_dss_grantee_type
    AND    (p_dss_grantee_type = 'GLOBAL' OR
           p_dss_grantee_type <> 'GLOBAL' AND dss_grantee_key = p_dss_grantee_key)
    AND    dsg.dss_group_code = p_dss_group_code;

    l_db_view_flag                VARCHAR2(1);
    l_db_insert_flag              VARCHAR2(1);
    l_db_update_flag              VARCHAR2(1);
    l_db_delete_flag              VARCHAR2(1);
    l_dsg_status                  VARCHAR2(1);
    l_end_date                    DATE;

BEGIN

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF p_init_msg_list IS NOT NULL AND
       FND_API.to_Boolean(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- standard start of API savepoint
    SAVEPOINT update_grant;

    --
    -- Get the current state of the grants for this grantee/dsg
    --

    OPEN c_grant;

    FETCH c_grant INTO
      l_db_view_flag, l_db_insert_flag,
      l_db_update_flag, l_db_delete_flag,
      l_dsg_status;

    -- we don't care if not found (flags will be null, that is ok)

    CLOSE c_grant;

    IF l_dsg_status <> 'A' THEN
      l_end_date := SYSDATE;
    END IF;

    -- Process the actions one by one

    --
    --  View Flag
    --

    IF NVL(p_view_flag, 'N') = 'Y' AND NVL(l_db_view_flag, 'N') = 'N' THEN
      --
      -- create grant
      --
      do_create_fnd_grant (
        p_dss_group_code          => p_dss_group_code,
        p_data_operation_code     => 'SELECT',
        p_dss_grantee_type        => p_dss_grantee_type,
        p_dss_grantee_key         => p_dss_grantee_key,
        p_grant_start_date        => SYSDATE,
        p_grant_end_date          => l_end_date
      );
    ELSIF NVL(p_view_flag, 'N') = 'N' AND NVL(l_db_view_flag, 'N') = 'Y' THEN
      --
      -- revoke grant
      --
      do_revoke_fnd_grant (
        p_dss_group_code          => p_dss_group_code,
        p_data_operation_code     => 'SELECT',
        p_dss_grantee_type        => p_dss_grantee_type,
        p_dss_grantee_key         => p_dss_grantee_key
      );
    END IF;

    --
    --  Insert Flag
    --

    IF NVL(p_insert_flag, 'N') = 'Y' AND NVL(l_db_insert_flag, 'N') = 'N' THEN
      --
      -- create grant
      --
      do_create_fnd_grant (
        p_dss_group_code          => p_dss_group_code,
        p_data_operation_code     => 'INSERT',
        p_dss_grantee_type        => p_dss_grantee_type,
        p_dss_grantee_key         => p_dss_grantee_key,
        p_grant_start_date        => SYSDATE,
        p_grant_end_date          => l_end_date
      );
    ELSIF NVL(p_insert_flag, 'N') = 'N' AND NVL(l_db_insert_flag, 'N') = 'Y' THEN
      --
      -- revoke grant
      --
      do_revoke_fnd_grant (
        p_dss_group_code          => p_dss_group_code,
        p_data_operation_code     => 'INSERT',
        p_dss_grantee_type        => p_dss_grantee_type,
        p_dss_grantee_key         => p_dss_grantee_key
      );
    END IF;

    --
    --  Update Flag
    --

    IF NVL(p_update_flag, 'N') = 'Y' AND NVL(l_db_update_flag, 'N') = 'N' THEN
      --
      -- create grant
      --
      do_create_fnd_grant (
        p_dss_group_code          => p_dss_group_code,
        p_data_operation_code     => 'UPDATE',
        p_dss_grantee_type        => p_dss_grantee_type,
        p_dss_grantee_key         => p_dss_grantee_key,
        p_grant_start_date        => SYSDATE,
        p_grant_end_date          => l_end_date
      );
    ELSIF NVL(p_update_flag, 'N') = 'N' AND NVL(l_db_update_flag, 'N') = 'Y' THEN
      --
      -- revoke grant
      --
      do_revoke_fnd_grant (
        p_dss_group_code          => p_dss_group_code,
        p_data_operation_code     => 'UPDATE',
        p_dss_grantee_type        => p_dss_grantee_type,
        p_dss_grantee_key         => p_dss_grantee_key
      );
    END IF;

    --
    --  Delete Flag
    --

    IF NVL(p_delete_flag, 'N') = 'Y' AND NVL(l_db_delete_flag, 'N') = 'N' THEN
      --
      -- create grant
      --
      do_create_fnd_grant (
        p_dss_group_code          => p_dss_group_code,
        p_data_operation_code     => 'DELETE',
        p_dss_grantee_type        => p_dss_grantee_type,
        p_dss_grantee_key         => p_dss_grantee_key,
        p_grant_start_date        => SYSDATE,
        p_grant_end_date          => l_end_date
      );
    ELSIF NVL(p_delete_flag, 'N') = 'N' AND NVL(l_db_delete_flag, 'N') = 'Y' THEN
      --
      -- revoke grant
      --
      do_revoke_fnd_grant (
        p_dss_group_code          => p_dss_group_code,
        p_data_operation_code     => 'DELETE',
        p_dss_grantee_type        => p_dss_grantee_type,
        p_dss_grantee_key         => p_dss_grantee_key
      );
    END IF;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_FALSE,
                  p_count => x_msg_count,
                  p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_grant ;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_grant ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO update_grant ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

END update_grant;


/**
 * PROCEDURE update_grant
 *
 * DESCRIPTION
 *
 *     Updates a set of Grants against a Data Sharing Group.
 *     This procedure is called when a whole DSS group is
 *     disabled/enabled.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-29-2004    Jianying Huang       o Created.
 *
 */

PROCEDURE update_grant (
    p_init_msg_list               IN     VARCHAR2,
    p_dss_group_code              IN     VARCHAR2,
    p_dss_group_status            IN     VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

    CURSOR c_grants IS
    SELECT grants.grant_guid,
           grants.start_date,
           dse.status
    FROM   fnd_grants grants,
           fnd_object_instance_sets ins,
           hz_dss_secured_entities dse
    WHERE  grants.program_name = G_API_NAME
    AND    grants.program_tag = p_dss_group_code
    AND    grants.instance_set_id = ins.instance_set_id
    AND    ins.instance_set_name NOT LIKE 'HZ_DSS_BASE_%'
    AND    ins.instance_set_id = dse.dss_instance_set_id;

    l_fnd_grant_guid              RAW(100);
    l_fnd_success                 VARCHAR2(1);
    l_start_date                  DATE;
    l_dse_status                  VARCHAR2(1);
    l_end_date                    DATE;

BEGIN

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF p_init_msg_list IS NOT NULL AND
       FND_API.to_Boolean(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- standard start of API savepoint
    SAVEPOINT update_grant;

    OPEN c_grants;
    LOOP

      FETCH c_grants INTO l_fnd_grant_guid, l_start_date, l_dse_status;
      IF c_grants%NOTFOUND THEN
        EXIT;
      END IF;

      --
      -- set the end date to null when the dss group and the secured
      -- entity are active.
      -- set the end date to sysdate when the dss group or the secured
      -- entity are inactive.
      --
      IF p_dss_group_status <> 'A' OR
         l_dse_status <> 'A'
      THEN
        l_end_date := SYSDATE;
      ELSE
        l_end_date := NULL;
      END IF;

      fnd_grants_pkg.update_grant (
        p_api_version             => 1,
        p_grant_guid              => l_fnd_grant_guid,
        p_start_date              => l_start_date,
        p_end_date                => l_end_date,
        x_success                 => l_fnd_success
      );

      IF l_fnd_success <> FND_API.G_TRUE THEN
        CLOSE c_grants;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;
    CLOSE c_grants;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_grant ;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_grant ;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_grant ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END update_grant;


/**
 * PROCEDURE update_grant
 *
 * DESCRIPTION
 *
 *     Updates a set of Grants against a Data Sharing Group.
 *     This procedure is called when an entity inside a DSS group
 *     is disabled/enabled.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-29-2004    Jianying Huang       o Created.
 *
 */

PROCEDURE update_grant (
    p_init_msg_list               IN     VARCHAR2,
    p_dss_group_code              IN     VARCHAR2,
    p_dss_instance_set_id         IN     NUMBER,
    p_secured_entity_status       IN     VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

    CURSOR c_dss_groups IS
    SELECT status
    FROM   hz_dss_groups_b
    WHERE  dss_group_code = p_dss_group_code;

    CURSOR c_grants IS
    SELECT grants.grant_guid,
           grants.start_date
    FROM   fnd_grants grants
    WHERE  grants.program_name = G_API_NAME
    AND    grants.program_tag = p_dss_group_code
    AND    grants.instance_set_id = p_dss_instance_set_id;

    l_fnd_grant_guid              RAW(100);
    l_fnd_success                 VARCHAR2(1);
    l_start_date                  DATE;
    l_dsg_status                  VARCHAR2(1);
    l_end_date                    DATE;

BEGIN

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF p_init_msg_list IS NOT NULL AND
       FND_API.to_Boolean(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- standard start of API savepoint
    SAVEPOINT update_grant;

    --
    -- set the end date to null when the dss group and the secured
    -- entity are active.
    -- set the end date to sysdate when the dss group or the secured
    -- entity are inactive.
    --
    OPEN c_dss_groups;
    FETCH c_dss_groups INTO l_dsg_status;
    CLOSE c_dss_groups;

    IF l_dsg_status <> 'A' OR
       p_secured_entity_status <> 'A'
    THEN
      l_end_date := SYSDATE;
    END IF;

    OPEN c_grants;
    LOOP
      FETCH c_grants INTO l_fnd_grant_guid, l_start_date;
      IF c_grants%NOTFOUND THEN
        EXIT;
      END IF;

      fnd_grants_pkg.update_grant (
        p_api_version             => 1,
        p_grant_guid              => l_fnd_grant_guid,
        p_start_date              => l_start_date,
        p_end_date                => l_end_date,
        x_success                 => l_fnd_success
      );

      IF l_fnd_success <> FND_API.G_TRUE THEN
        CLOSE c_grants;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;
    CLOSE c_grants;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_grant ;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_grant ;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_grant ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END update_grant;


/**
 * PROCEDURE check_admin_priv
 *
 * DESCRIPTION
 *
 *     Checks whether the current user has sufficient privilege to maintain
 *     a Data Sharing Group.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   09-18-2002    Chris Saulit       o Created.
 *
 */

PROCEDURE check_admin_priv (
    p_init_msg_list               IN     VARCHAR2,
    p_dss_group_code              IN     VARCHAR2,
    p_dss_admin_func_code         IN     VARCHAR2,
    x_pass_fail_flag              OUT    NOCOPY VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

    l_resp_cnt                    NUMBER;

BEGIN

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF p_init_msg_list IS NOT NULL AND
       FND_API.to_Boolean(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success and security answer to FALSE
    x_return_status  := FND_API.G_RET_STS_SUCCESS;
    x_pass_fail_flag := FND_API.G_FALSE;

    --
    --  Validations
    --

    IF p_dss_admin_func_code NOT IN
        (g_dss_admin_create, g_dss_admin_update, g_dss_admin_grant)
    THEN
      FND_MESSAGE.SET_NAME('FND','FND_GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN(
        'MESSAGE','p_dss_admin_func_code must be one of: ' ||
        g_dss_admin_create ||', '|| g_dss_admin_update||', '||g_dss_admin_grant
      );   -- this is a developer error, not a user-facing error
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --
    --  Check privilege
    --
    -- Bug 4956762: performance fix. split the original
    -- query into 2 and cached responsibility id.
    --

    IF G_DSS_RESPONSIBILITY_ID IS NULL THEN
    BEGIN
      SELECT responsibility_id INTO G_DSS_RESPONSIBILITY_ID
      FROM   fnd_responsibility r
      WHERE  r.responsibility_key = 'HZ_DSS_ADMIN'
      AND    r.application_id = 222;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    END IF;

    BEGIN
      SELECT 1
      INTO   l_resp_cnt
      FROM   fnd_user_resp_groups rg
      WHERE  rg.user_id = fnd_global.user_id
      AND    rg.responsibility_id = G_DSS_RESPONSIBILITY_ID
      AND    rg.responsibility_application_id = 222
      AND    (rg.end_date IS NULL OR rg.end_date > SYSDATE)
      AND    (rg.start_date IS NULL OR rg.start_date < SYSDATE);

      x_pass_fail_flag := FND_API.G_TRUE;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END check_admin_priv;


/**
 * PROCEDURE check_admin_priv
 *
 * DESCRIPTION
 *
 *     Checks whether the current user has sufficient privilege to maintain
 *     a Data Sharing Group.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   09-18-2002    Chris Saulit       o Created.
 *
 */

FUNCTION check_admin_priv (
    p_dss_group_code              IN     VARCHAR2,
    p_dss_admin_func_code         IN     VARCHAR2
) RETURN VARCHAR2 IS

    l_pass_fail_flag              VARCHAR2(1);
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);

BEGIN

    --
    --  Call the PL/SQL version
    --
    check_admin_priv (
      p_init_msg_list             => FND_API.G_TRUE,
      p_dss_group_code            => p_dss_group_code,
      p_dss_admin_func_code       => p_dss_admin_func_code,
      x_pass_fail_flag            => l_pass_fail_flag,
      x_return_status             => l_return_status,
      x_msg_count                 => l_msg_count,
      x_msg_data                  => l_msg_data
    );


    RETURN l_pass_fail_flag;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FND_API.G_FALSE;

END check_admin_priv;

END HZ_DSS_GRANTS_PUB;

/

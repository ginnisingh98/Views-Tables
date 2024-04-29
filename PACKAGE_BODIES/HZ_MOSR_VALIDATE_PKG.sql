--------------------------------------------------------
--  DDL for Package Body HZ_MOSR_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MOSR_VALIDATE_PKG" AS
/* $Header: ARHOSRVB.pls 120.19 2006/04/18 11:19:22 svemuri noship $ */

function orig_sys_entity_map_exist(p_orig_system in varchar2,
                p_owner_table_name in varchar2/*,p_status in varchar2*/) return varchar2 is

        cursor orig_sys_entity_map_exist_csr is
                select 'Y'
                from hz_orig_sys_mapping
                where orig_system = p_orig_system
                and owner_table_name = p_owner_table_name/*
                and status = nvl(p_status,status)*/;

l_exist varchar2(1);
begin
        open orig_sys_entity_map_exist_csr;
        fetch orig_sys_entity_map_exist_csr into l_exist;
        close orig_sys_entity_map_exist_csr;
        if l_exist = 'Y'
        then return 'Y';
        else return 'N';
        end if;
end orig_sys_entity_map_exist;

function get_orig_system_ref_count(p_orig_system in varchar2,p_orig_system_reference in varchar2, p_owner_table_name in varchar2) return varchar2
is
        cursor get_orig_sys_ref_count_csr is
        SELECT count(*)
        FROM   HZ_ORIG_SYS_REFERENCES
        WHERE  ORIG_SYSTEM = p_orig_system
        and ORIG_SYSTEM_REFERENCE = p_orig_system_reference
        and owner_table_name = p_owner_table_name
        and status = 'A';
l_count number := 0;
begin
        open get_orig_sys_ref_count_csr;
        fetch get_orig_sys_ref_count_csr into l_count;
        close get_orig_sys_ref_count_csr;
        return l_count;
end get_orig_system_ref_count;

function orig_sys_reference_exist_cre(p_orig_system in varchar2,
                p_orig_system_ref in varchar2, p_owner_table_name in
varchar2) return varchar2 is

        cursor orig_sys_reference_exist_csr is
                select 'Y'
                from hz_orig_sys_references
                where orig_system = p_orig_system
                and orig_system_reference = p_orig_system_ref
                and owner_table_name = p_owner_table_name
                and status = 'A'
                and rownum = 1;

l_exist varchar2(1);
begin
        open orig_sys_reference_exist_csr;
        fetch orig_sys_reference_exist_csr into l_exist;
        close orig_sys_reference_exist_csr;
        if l_exist = 'Y'
        then return 'Y';
        else return 'N';
        end if;
end orig_sys_reference_exist_cre;

function orig_sys_reference_exist(p_orig_system in varchar2,
                p_orig_system_ref in varchar2, p_owner_table_name in
varchar2) return varchar2 is

        cursor orig_sys_reference_exist_csr is
                select 'Y'
                from hz_orig_sys_references
                where orig_system = p_orig_system
                and orig_system_reference = p_orig_system_ref
                and owner_table_name = p_owner_table_name
                and rownum = 1; -- allow update case: update status from 'I' to 'A'

l_exist varchar2(1);
begin
        open orig_sys_reference_exist_csr;
        fetch orig_sys_reference_exist_csr into l_exist;
        close orig_sys_reference_exist_csr;
        if l_exist = 'Y'
        then return 'Y';
        else return 'N';
        end if;
end orig_sys_reference_exist;

PROCEDURE VALIDATE_ORIG_SYS_ENTITY_MAP (
    p_create_update_flag                IN      VARCHAR2,
    p_orig_sys_entity_map_rec           IN      HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_ENTITY_MAP_REC_TYPE,
    x_return_status                     IN OUT NOCOPY VARCHAR2

) is
-- Added multi_osr_flag in cursor get_orig_sys_entity_map_csr

        cursor get_orig_sys_entity_map_csr is
                select multiple_flag, multi_osr_flag,created_by_module, application_id
                from hz_orig_sys_mapping
                where orig_system = p_orig_sys_entity_map_rec.orig_system
                and owner_table_name = p_orig_sys_entity_map_rec.owner_table_name
                /*and status = 'A'*/;

        cursor  seed_orig_system_exist_csr is
                select 'Y'
                from hz_orig_sys_mapping
                where created_by = 1
                and orig_system = p_orig_sys_entity_map_rec.orig_system
                and owner_table_name = p_orig_sys_entity_map_rec.owner_table_name
                /*and status = 'A'*/
                and rownum=1;

--MOSR phase 2 modifications
        cursor mosr_rec_exists is
               select 'Y'
               from hz_orig_sys_references
               where orig_system = p_orig_sys_entity_map_rec.orig_system
               and owner_table_name = p_orig_sys_entity_map_rec.owner_table_name
--  Bug 4956761 : Corrected to get result if there are multiple MOSR for single entity
               and status = 'A'
               group by owner_table_id
               having count(1) > 1;

--  SST SSM Integration and Extension
--  Cursor to validate orig_system against table hz_orig_systems_b
        cursor orig_system_exist is
                select 'Y'
                from hz_orig_systems_b
                where orig_system = p_orig_sys_entity_map_rec.orig_system
/*              and status= 'A'*/;
l_orig_sys VARCHAR2(1);

l_multiple_flag varchar2(1);
l_multi_osr_flag VARCHAR2(1);
l_created_by_module varchar2(150);
l_application_id number;
l_exist varchar2(1);
l_dummy VARCHAR2(1);

begin
                if orig_sys_entity_map_exist(p_orig_sys_entity_map_rec.orig_system,
                        p_orig_sys_entity_map_rec.owner_table_name/*,null*/) = 'Y'
        then
                if  p_create_update_flag = 'C'
                then
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
                        FND_MESSAGE.SET_TOKEN('COLUMN', 'orig_system+owner_table_name');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                end if;
        else
                if p_create_update_flag = 'U'
                then
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_DATA_FOUND');
                        FND_MESSAGE.SET_TOKEN('COLUMN','orig_system+owner_table_name');
                        FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_ORIG_SYS_MAPPING');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                end if;
        end if;

--  SST SSM Integration and Extension
--  Validate p_orig_sys_entity_map_rec.orig_system against
--  table HZ_ORIG_SYSTEMS_B instead of lookup ORIG_SYSTEM
/*
        HZ_UTILITY_V2PUB.validate_lookup (
            p_column                                => 'orig_system',
            p_lookup_type                           => 'ORIG_SYSTEM',
            p_column_value                          => p_orig_sys_entity_map_rec.orig_system,
            x_return_status                         => x_return_status );
*/
        open orig_system_exist;
        fetch orig_system_exist into l_orig_sys;
        if orig_system_exist%notfound then
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
                FND_MESSAGE.SET_TOKEN('FK','orig_system');
                FND_MESSAGE.SET_TOKEN('COLUMN','orig_system');
                FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_ORIG_SYSTEMS_B');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
        end if;

        HZ_UTILITY_V2PUB.validate_lookup (
            p_column                                => 'status',
            p_lookup_type                           => 'MOSR_STATUS',
            p_column_value                          => p_orig_sys_entity_map_rec.status,
            x_return_status                         => x_return_status );

        HZ_UTILITY_V2PUB.validate_lookup (
            p_column                                => 'owner_table_name',
            p_lookup_type                           => 'TCA_OWNER_TABLE',
            p_column_value                          => p_orig_sys_entity_map_rec.owner_table_name,
            x_return_status                         => x_return_status );

        HZ_UTILITY_V2PUB.validate_lookup (
            p_column                                => 'multiple_flag',
            p_lookup_type                           => 'YES/NO',
            p_column_value                          => p_orig_sys_entity_map_rec.multiple_flag,
            x_return_status                         => x_return_status );

        IF p_create_update_flag = 'C' THEN
            If  p_orig_sys_entity_map_rec.owner_table_name in ('HZ_CUST_ACCT_SITES_ALL',
                                        'HZ_CUST_ACCOUNT_ROLES', 'HZ_CUST_SITE_USES_ALL')
            then
                if p_orig_sys_entity_map_rec.multiple_flag = 'N'
                then
                        fnd_message.set_name('AR', 'HZ_API_VAL_DEP_FIELDS');
                        fnd_message.set_token('COLUMN1', 'multiple_flag');
                        fnd_message.set_token('VALUE1', 'N(No)');
                        fnd_message.set_token('COLUMN2', 'multiple_flag');
                        fnd_message.set_token('VALUE2', 'Y(Yes)');
                        fnd_msg_pub.add;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                end if;
           else -- other tables
                open seed_orig_system_exist_csr;
                fetch seed_orig_system_exist_csr into l_exist;
                close seed_orig_system_exist_csr;
                if l_exist <> 'Y' and p_orig_sys_entity_map_rec.multiple_flag = 'Y'
                then
                        fnd_message.set_name('AR', 'HZ_API_VAL_DEP_FIELDS');
                        fnd_message.set_token('COLUMN1', 'multiple_flag');
                        fnd_message.set_token('VALUE1', 'Y(Yes)');
                        fnd_message.set_token('COLUMN2', 'multiple_flag');
                        fnd_message.set_token('VALUE2', 'N(No)');
                        fnd_msg_pub.add;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                end if;
          end if;

       END IF;

    IF p_create_update_flag = 'U'
    THEN
        open get_orig_sys_entity_map_csr;
        fetch get_orig_sys_entity_map_csr into l_multiple_flag,l_multi_osr_flag,
                        l_created_by_module, l_application_id;
        close get_orig_sys_entity_map_csr;

    END IF;

    IF p_create_update_flag = 'U' AND
      p_orig_sys_entity_map_rec.multiple_flag IS NOT NULL
    THEN
        HZ_UTILITY_V2PUB.validate_nonupdateable (
            p_column                                => 'multiple_flag',
            p_column_value                          => p_orig_sys_entity_map_rec.multiple_flag,
            p_old_column_value                      => l_multiple_flag,
            p_restricted                            => 'N',
            x_return_status                         => x_return_status );
    END IF;

-- Added  validation for MOSR flag
     IF p_create_update_flag = 'U' AND
        p_orig_sys_entity_map_rec.multi_osr_flag IS NOT NULL
     THEN
        IF (p_orig_sys_entity_map_rec.multi_osr_flag = 'N' and
            nvl(l_multi_osr_flag,'Y') = 'Y' )
        THEN
           OPEN mosr_rec_exists;
           FETCH mosr_rec_exists INTO l_dummy;

          IF mosr_rec_exists%FOUND then
              FND_MESSAGE.SET_NAME('AR', 'HZ_SSM_INVALID_MULTIPLE_FLAG');
              FND_MESSAGE.SET_TOKEN('ENTITY', p_orig_sys_entity_map_rec.owner_table_name);
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
   CLOSE mosr_rec_exists;
        END IF;
     END IF;

    --------------------------------------
    -- validate created_by_module
    --------------------------------------

    hz_utility_v2pub.validate_created_by_module(
      p_create_update_flag     => p_create_update_flag,
      p_created_by_module      => p_orig_sys_entity_map_rec.created_by_module,
      p_old_created_by_module  => l_created_by_module,
      x_return_status          => x_return_status);

    --------------------------------------
    -- validate application_id
    --------------------------------------

    hz_utility_v2pub.validate_application_id(
      p_create_update_flag     => p_create_update_flag,
      p_application_id         => p_orig_sys_entity_map_rec.application_id,
      p_old_application_id     => l_application_id,
      x_return_status          => x_return_status);

end VALIDATE_ORIG_SYS_ENTITY_MAP;

function get_multiple_flag(p_orig_system in varchar2, p_owner_table_name in
varchar2) return varchar2 is
        cursor get_multiple_flag_csr is
                select multiple_flag
                from hz_orig_sys_mapping
                where orig_system = p_orig_system
                and owner_table_name = p_owner_table_name
        /*      and status = 'A'*/;
l_multiple_flag varchar2(1);
begin
        open get_multiple_flag_csr;
        fetch get_multiple_flag_csr into l_multiple_flag;
        close get_multiple_flag_csr;
        return l_multiple_flag;
end get_multiple_flag;

PROCEDURE VALIDATE_ORIG_SYS_REFERENCE (
    p_create_update_flag                    IN     VARCHAR2,
    p_orig_sys_reference_rec               IN     HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE,
    x_return_status                         IN OUT NOCOPY VARCHAR2

) is
        cursor get_orig_sys_reference_csr is
                select start_date_active,end_date_active
                from hz_orig_sys_references
                where orig_system = p_orig_sys_reference_rec.orig_system
                and orig_system_reference =nvl(p_orig_sys_reference_rec.old_orig_system_reference,
                                                p_orig_sys_reference_rec.orig_system_reference)
                and owner_table_name = p_orig_sys_reference_rec.owner_table_name
                and rownum = 1; -- start/end_date_active only used in update and
                                -- only if unique, we allow update.

        cursor get_dup_orig_sys_ref_csr is
                select 'Y'
                from hz_orig_sys_references
                where orig_system = p_orig_sys_reference_rec.orig_system
                and orig_system_reference = p_orig_sys_reference_rec.orig_system_reference
                and owner_table_name = p_orig_sys_reference_rec.owner_table_name
                and owner_table_id = p_orig_sys_reference_rec.owner_table_id
                and status = 'A';

        cursor get_nonupdateable_columns1 is
                select created_by_module, application_id
                from   hz_orig_sys_references
                where  orig_system = p_orig_sys_reference_rec.orig_system
                and    orig_system_reference = p_orig_sys_reference_rec.orig_system_reference
                and    owner_table_name = p_orig_sys_reference_rec.owner_table_name
                and    owner_table_id = p_orig_sys_reference_rec.owner_table_id
                and    status = 'A';
        /* Bug Fix: 4869208 */
        cursor get_nonupdateable_columns2 is
                select created_by_module, application_id
                from   hz_orig_sys_references
                where  orig_system_ref_id = p_orig_sys_reference_rec.orig_system_ref_id;

l_multiple_flag varchar2(1);
l_created_by_module varchar2(150);
l_application_id number;
l_start_date date;
l_end_date date;
l_exist varchar2(1);
l_dup_exist varchar2(1);
l_dummy    VARCHAR2(1);
l_debug_prefix  VARCHAR2(30) ;

-- SSM SST Integration and Extension
CURSOR c_active_orig_system_exists IS
    SELECT 'Y'
    FROM   HZ_ORIG_SYSTEMS_B
    WHERE  orig_system = p_orig_sys_reference_rec.orig_system
      AND  status = 'A';
l_temp VARCHAR2(1);

begin
        l_debug_prefix := '';
        IF p_create_update_flag = 'C'
           and
          (p_orig_sys_reference_rec.orig_system_reference is null or
          p_orig_sys_reference_rec.orig_system_reference = fnd_api.g_miss_char)
        THEN
           HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'orig_system_reference',
            p_column_value                          => p_orig_sys_reference_rec.orig_system_reference,
            x_return_status                         => x_return_status );

         END IF;


-- SSM SST Integration and Extension
-- Instead of checking if the combination of orig_system and owner_table_name
-- exists in HZ_ORIG_SYS_MAPPING, check if the orig_system is a valid value from
-- HZ_ORIG_SYSTEMS_B and owner_table_name is a valid value from lookup TCA_OWNER_TABLE.
-- If these validations are satisfied, then an record will be there in HZ_ORIG_SYS_MAPPING
-- anyway.
-- Logic behind this change: The status field in HZ_ORIG_SYS_MAPPING should not be considered.
-- However the status in HZ_ORIG_SYSTEMS_B has to be checked.

/*      -- Make sure passing in orig_system and owner_table_name are validate
        if orig_sys_entity_map_exist(p_orig_sys_reference_rec.orig_system,
                        p_orig_sys_reference_rec.owner_table_name/*,'A'*//*) = 'N'
        then
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_DATA_FOUND');
                        FND_MESSAGE.SET_TOKEN('COLUMN','orig_system+owner_table_name');
                        FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_ORIG_SYS_MAPPING');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
        end if;
*/

        -- Validate orig_system

        OPEN c_active_orig_system_exists;
        FETCH c_active_orig_system_exists INTO l_temp;
        IF c_active_orig_system_exists%notFOUND THEN
            FND_MESSAGE.SET_NAME('AR','HZ_API_INVALID_FK');
            FND_MESSAGE.SET_TOKEN('FK','orig_system');
            FND_MESSAGE.SET_TOKEN('COLUMN','orig_system');
            FND_MESSAGE.SET_TOKEN('TABLE','HZ_ORIG_SYSTEMS_B');
            FND_MSG_PUB.ADD;
	    -- Bug 5104024
	    x_return_status := fnd_api.g_ret_sts_error;
        END IF;
        CLOSE c_active_orig_system_exists;

        -- validate owner_table_name.
        HZ_UTILITY_V2PUB.validate_lookup (
            p_column               => 'owner_table_name',
            p_column_value         => p_orig_sys_reference_rec.owner_table_name,
            p_lookup_type          => 'TCA_OWNER_TABLE',
            x_return_status        => x_return_status
        );

        -- owner_table_id is mandatory
        -- do not need to check orig_system, owner_table_name mandatory
        -- because they are already checked in orig_sys_entity_map_exist()

        IF p_create_update_flag = 'C'
           and
          (p_orig_sys_reference_rec.owner_table_id is null or
          p_orig_sys_reference_rec.owner_table_id = fnd_api.g_miss_num)
        THEN
           HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'owner_table_id',
            p_column_value                          => p_orig_sys_reference_rec.owner_table_id,
            x_return_status                         => x_return_status );

        END IF;

         -- foreign key validation

         -- validate HZ_PARTIES and party_id
         IF p_orig_sys_reference_rec.owner_table_name = 'HZ_PARTIES' THEN
         -- party_id is foreign key of hz_parties
         -- Do not need to check during update because party_id is
         -- non-updateable.
             IF p_create_update_flag = 'C'
                AND p_orig_sys_reference_rec.owner_table_id IS NOT NULL
                AND p_orig_sys_reference_rec.owner_table_id <> fnd_api.g_miss_num
                AND p_orig_sys_reference_rec.owner_table_id <> -1
             THEN
               BEGIN
                 SELECT 'Y'
                 INTO   l_dummy
                 FROM   HZ_PARTIES
                 WHERE  PARTY_ID = p_orig_sys_reference_rec.owner_table_id;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'owner_table_id');
                  fnd_message.set_token('COLUMN', 'party_id');
                  fnd_message.set_token('TABLE', 'hz_parties');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
               END;
               IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                                             p_message=>'owner_table_id is foreign key of hz_parties. ' ||
                                             'x_return_status = ' ||  x_return_status,
                                             p_msg_level=>fnd_log.level_statement);
               END IF;

             END IF;

         -- validate HZ_PARTY_SITES, party_site_id
         ELSIF p_orig_sys_reference_rec.owner_table_name = 'HZ_PARTY_SITES' THEN

         -- party_site_id is foreign key of HZ_PARTY_SITES
         -- Do not need to check during update because party_site_id is
         -- non-updateable.
             IF p_create_update_flag = 'C'
                AND p_orig_sys_reference_rec.owner_table_id IS NOT NULL
                AND p_orig_sys_reference_rec.owner_table_id <> fnd_api.g_miss_num
                AND p_orig_sys_reference_rec.owner_table_id <> -1
             THEN
               BEGIN
                 SELECT 'Y'
                 INTO   l_dummy
                 FROM   HZ_PARTY_SITES
                 WHERE  party_site_id = p_orig_sys_reference_rec.owner_table_id;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'owner_table_id');
                  fnd_message.set_token('COLUMN', 'party_site_id');
                  fnd_message.set_token('TABLE', 'HZ_PARTY_SITES');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
               END;
               IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                                             p_message=>'owner_table_id is foreign key of HZ_PARTY_SITES. ' ||
                                             'x_return_status = ' ||  x_return_status,
                                             p_msg_level=>fnd_log.level_statement);
               END IF;

             END IF;


         -- validate HZ_CONTACT_POINTS, contact_point_id
         ELSIF p_orig_sys_reference_rec.owner_table_name = 'HZ_CONTACT_POINTS' THEN

         -- contact_point_id is foreign key of HZ_CONTACT_POINTS
         -- Do not need to check during update because contact_point_id is
         -- non-updateable.
             IF p_create_update_flag = 'C'
                AND p_orig_sys_reference_rec.owner_table_id IS NOT NULL
                AND p_orig_sys_reference_rec.owner_table_id <> fnd_api.g_miss_num
                AND p_orig_sys_reference_rec.owner_table_id <> -1
             THEN
               BEGIN
                 SELECT 'Y'
                 INTO   l_dummy
                 FROM   HZ_CONTACT_POINTS
                 WHERE  contact_point_id = p_orig_sys_reference_rec.owner_table_id;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'owner_table_id');
                  fnd_message.set_token('COLUMN', 'contact_point_id');
                  fnd_message.set_token('TABLE', 'HZ_CONTACT_POINTS');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
               END;
               IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                                             p_message=>'owner_table_id is foreign key of HZ_CONTACT_POINTS. ' ||
                                             'x_return_status = ' ||  x_return_status,
                                             p_msg_level=>fnd_log.level_statement);
               END IF;

             END IF;

         -- validate HZ_CUST_ACCOUNTS,  cust_account_id
         ELSIF p_orig_sys_reference_rec.owner_table_name = 'HZ_CUST_ACCOUNTS' THEN
         -- cust_account_id is foreign key of HZ_CUST_ACCOUNTS
         -- Do not need to check during update because cust_account_id is
         -- non-updateable.
             IF p_create_update_flag = 'C'
                AND p_orig_sys_reference_rec.owner_table_id IS NOT NULL
                AND p_orig_sys_reference_rec.owner_table_id <> fnd_api.g_miss_num
                AND p_orig_sys_reference_rec.owner_table_id <> -1
             THEN
               BEGIN
                 SELECT 'Y'
                 INTO   l_dummy
                 FROM   HZ_CUST_ACCOUNTS
                 WHERE  cust_account_id = p_orig_sys_reference_rec.owner_table_id;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'owner_table_id');
                  fnd_message.set_token('COLUMN', 'cust_account_id');
                  fnd_message.set_token('TABLE', 'HZ_CUST_ACCOUNTS');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
               END;
               IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                                             p_message=>'owner_table_id is foreign key of HZ_CUST_ACCOUNTS. ' ||
                                             'x_return_status = ' ||  x_return_status,
                                             p_msg_level=>fnd_log.level_statement);
               END IF;

             END IF;

         -- validate HZ_CUST_ACCOUNT_ROLES, cust_account_role_id
         ELSIF p_orig_sys_reference_rec.owner_table_name = 'HZ_CUST_ACCOUNT_ROLES' THEN
         -- cust_account_role_id is foreign key of HZ_CUST_ACCOUNT_ROLES
         -- Do not need to check during update because cust_account_role_id is
         -- non-updateable.
             IF p_create_update_flag = 'C'
                AND p_orig_sys_reference_rec.owner_table_id IS NOT NULL
                AND p_orig_sys_reference_rec.owner_table_id <> fnd_api.g_miss_num
                AND p_orig_sys_reference_rec.owner_table_id <> -1
             THEN
               BEGIN
                 SELECT 'Y'
                 INTO   l_dummy
                 FROM   HZ_CUST_ACCOUNT_ROLES
                 WHERE  cust_account_role_id = p_orig_sys_reference_rec.owner_table_id;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'owner_table_id');
                  fnd_message.set_token('COLUMN', 'cust_account_role_id');
                  fnd_message.set_token('TABLE', 'HZ_CUST_ACCOUNT_ROLES');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
               END;
               IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                                             p_message=>'owner_table_id is foreign key of HZ_CUST_ACCOUNT_ROLES. ' ||
                                             'x_return_status = ' ||  x_return_status,
                                             p_msg_level=>fnd_log.level_statement);
               END IF;

             END IF;

         -- validate HZ_CUST_ACCT_SITES_ALL, cust_acct_site_id
         ELSIF p_orig_sys_reference_rec.owner_table_name = 'HZ_CUST_ACCT_SITES_ALL' THEN

         -- cust_acct_site_id is foreign key of HZ_CUST_ACCT_SITES_ALL
         -- Do not need to check during update because cust_acct_site_id is
         -- non-updateable.
             IF p_create_update_flag = 'C'
                AND p_orig_sys_reference_rec.owner_table_id IS NOT NULL
                AND p_orig_sys_reference_rec.owner_table_id <> fnd_api.g_miss_num
                AND p_orig_sys_reference_rec.owner_table_id <> -1
             THEN
               BEGIN
                 SELECT 'Y'
                 INTO   l_dummy
                 FROM   HZ_CUST_ACCT_SITES_ALL  -- Bug 3730175
                 WHERE  cust_acct_site_id = p_orig_sys_reference_rec.owner_table_id;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'owner_table_id');
                  fnd_message.set_token('COLUMN', 'cust_acct_site_id');
                  fnd_message.set_token('TABLE', 'HZ_CUST_ACCT_SITES_ALL');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
               END;
               IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                                             p_message=>'owner_table_id is foreign key of HZ_CUST_ACCT_SITES_ALL. ' ||
                                             'x_return_status = ' ||  x_return_status,
                                             p_msg_level=>fnd_log.level_statement);
               END IF;

             END IF;

         -- validate HZ_CUST_SITE_USES_ALL, site_use_id
         ELSIF p_orig_sys_reference_rec.owner_table_name = 'HZ_CUST_SITE_USES_ALL' THEN

         -- site_use_id is foreign key of HZ_CUST_SITE_USES_ALL
         -- Do not need to check during update because site_use_id is
         -- non-updateable.
             IF p_create_update_flag = 'C'
                AND p_orig_sys_reference_rec.owner_table_id IS NOT NULL
                AND p_orig_sys_reference_rec.owner_table_id <> fnd_api.g_miss_num
                AND p_orig_sys_reference_rec.owner_table_id <> -1
             THEN
               BEGIN
                 SELECT 'Y'
                 INTO   l_dummy
                 FROM   HZ_CUST_SITE_USES_ALL
                 WHERE  site_use_id = p_orig_sys_reference_rec.owner_table_id;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'owner_table_id');
                  fnd_message.set_token('COLUMN', 'site_use_id');
                  fnd_message.set_token('TABLE', 'HZ_CUST_SITE_USES_ALL');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
               END;
               IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                                             p_message=>'owner_table_id is foreign key of HZ_CUST_SITE_USES_ALL. ' ||
                                             'x_return_status = ' ||  x_return_status,
                                             p_msg_level=>fnd_log.level_statement);
               END IF;

             END IF;

         -- validate HZ_LOCATIONS  , location_id
         ELSIF p_orig_sys_reference_rec.owner_table_name = 'HZ_LOCATIONS' THEN

         -- location_id is foreign key of HZ_LOCATIONS
         -- Do not need to check during update because location_id is
         -- non-updateable.
             IF p_create_update_flag = 'C'
                AND p_orig_sys_reference_rec.owner_table_id IS NOT NULL
                AND p_orig_sys_reference_rec.owner_table_id <> fnd_api.g_miss_num
                AND p_orig_sys_reference_rec.owner_table_id <> -1
             THEN
               BEGIN
                 SELECT 'Y'
                 INTO   l_dummy
                 FROM   HZ_LOCATIONS
                 WHERE  location_id = p_orig_sys_reference_rec.owner_table_id;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'owner_table_id');
                  fnd_message.set_token('COLUMN', 'location_id');
                  fnd_message.set_token('TABLE', 'HZ_LOCATIONS');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
               END;
               IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                                             p_message=>'owner_table_id is foreign key of HZ_LOCATIONS. ' ||
                                             'x_return_status = ' ||  x_return_status,
                                             p_msg_level=>fnd_log.level_statement);
               END IF;

             END IF;

         -- validate HZ_ORG_CONTACTS, org_contact_id
         ELSIF p_orig_sys_reference_rec.owner_table_name = 'HZ_ORG_CONTACTS' THEN

         -- org_contact_id is foreign key of HZ_ORG_CONTACTS
         -- Do not need to check during update because org_contact_id is
         -- non-updateable.
             IF p_create_update_flag = 'C'
                AND p_orig_sys_reference_rec.owner_table_id IS NOT NULL
                AND p_orig_sys_reference_rec.owner_table_id <> fnd_api.g_miss_num
                AND p_orig_sys_reference_rec.owner_table_id <> -1
             THEN
               BEGIN
                 SELECT 'Y'
                 INTO   l_dummy
                 FROM   HZ_ORG_CONTACTS
                 WHERE  org_contact_id = p_orig_sys_reference_rec.owner_table_id;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'owner_table_id');
                  fnd_message.set_token('COLUMN', 'org_contact_id');
                  fnd_message.set_token('TABLE', 'HZ_ORG_CONTACTS');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
               END;
               IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                                             p_message=>'owner_table_id is foreign key of HZ_ORG_CONTACTS. ' ||
                                             'x_return_status = ' ||  x_return_status,
                                             p_msg_level=>fnd_log.level_statement);
               END IF;

             END IF;

         -- validate HZ_ORG_CONTACT_ROLES, org_contact_role_id
         ELSIF p_orig_sys_reference_rec.owner_table_name = 'HZ_ORG_CONTACT_ROLES' THEN

         -- org_contact_role_id is foreign key of HZ_ORG_CONTACT_ROLES
         -- Do not need to check during update because org_contact_role_id is
         -- non-updateable.
             IF p_create_update_flag = 'C'
                AND p_orig_sys_reference_rec.owner_table_id IS NOT NULL
                AND p_orig_sys_reference_rec.owner_table_id <> fnd_api.g_miss_num
                AND p_orig_sys_reference_rec.owner_table_id <> -1
             THEN
               BEGIN
                 SELECT 'Y'
                 INTO   l_dummy
                 FROM   HZ_ORG_CONTACT_ROLES
                 WHERE  org_contact_role_id = p_orig_sys_reference_rec.owner_table_id;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'owner_table_id');
                  fnd_message.set_token('COLUMN', 'org_contact_role_id');
                  fnd_message.set_token('TABLE', 'HZ_ORG_CONTACT_ROLES');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
               END;
               IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                      hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,
                                             p_message=>'owner_table_id is foreign key of HZ_ORG_CONTACT_ROLES. ' ||
                                             'x_return_status = ' ||  x_return_status,
                                             p_msg_level=>fnd_log.level_statement);
               END IF;

             END IF;

         END IF;


        l_multiple_flag := get_multiple_flag(p_orig_sys_reference_rec.orig_system,
                                p_orig_sys_reference_rec.owner_table_name);
        if l_multiple_flag = 'Y' and p_create_update_flag = 'C'
        then
                open get_dup_orig_sys_ref_csr;
                fetch get_dup_orig_sys_ref_csr into l_exist;
                close get_dup_orig_sys_ref_csr;
                if l_exist = 'Y'
                then
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
                        FND_MESSAGE.SET_TOKEN('COLUMN', 'orig_system+orig_system_reference+owner_table_name+owner_table_id');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                end if;
        end if;

        l_dup_exist := orig_sys_reference_exist_cre(p_orig_sys_reference_rec.orig_system,
                        p_orig_sys_reference_rec.orig_system_reference,
                        p_orig_sys_reference_rec.owner_table_name);

        if  p_create_update_flag = 'C' and l_multiple_flag = 'N' and l_dup_exist = 'Y'

        then
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
                FND_MESSAGE.SET_TOKEN('COLUMN', 'orig_system+orig_system_reference+owner_table_name');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
        end if;

        if p_create_update_flag = 'U'
           and orig_sys_reference_exist(p_orig_sys_reference_rec.orig_system,
                        p_orig_sys_reference_rec.orig_system_reference,
                        p_orig_sys_reference_rec.owner_table_name) = 'N'
           and
                (p_orig_sys_reference_rec.old_orig_system_reference is null
                        or p_orig_sys_reference_rec.old_orig_system_reference = fnd_api.g_miss_char)
        then
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_DATA_FOUND');
                FND_MESSAGE.SET_TOKEN('COLUMN','orig_system+orig_system_reference+owner_table_name');                     FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_ORIG_SYS_REFERENCES');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
        end if;

        if (p_orig_sys_reference_rec.old_orig_system_reference is not null
                and p_orig_sys_reference_rec.old_orig_system_reference<> fnd_api.g_miss_char)
        then
                if orig_sys_reference_exist(p_orig_sys_reference_rec.orig_system,
                        p_orig_sys_reference_rec.old_orig_system_reference,
                        p_orig_sys_reference_rec.owner_table_name) = 'N'
                then
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_DATA_FOUND');
                        FND_MESSAGE.SET_TOKEN('COLUMN','orig_system+old_orig_system_reference+owner_table_name');             FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_ORIG_SYS_REFERENCES');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                end if;
        end if;

        if (p_orig_sys_reference_rec.start_date_active is not null
                and p_orig_sys_reference_rec.start_date_active <>fnd_api.g_miss_date
                and trunc(p_orig_sys_reference_rec.start_date_active) > trunc(sysdate))  /* Bug 3298896 */
        then
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_FUTURE_DATE_ALLOWED');
                        FND_MESSAGE.SET_TOKEN('COLUMN','start_date_active');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
        end if;

        if (p_orig_sys_reference_rec.end_date_active is not null
                and p_orig_sys_reference_rec.end_date_active <>fnd_api.g_miss_date
                and trunc(p_orig_sys_reference_rec.end_date_active) > trunc(sysdate))  /* Bug 3298896 */
        then
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_FUTURE_DATE_ALLOWED');
                        FND_MESSAGE.SET_TOKEN('COLUMN','end_date_active');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
        end if;


        HZ_UTILITY_V2PUB.validate_lookup (
            p_column                                => 'status',
            p_lookup_type                           => 'MOSR_STATUS',
            p_column_value                          => p_orig_sys_reference_rec.status,
            x_return_status                         => x_return_status );

        HZ_UTILITY_V2PUB.validate_lookup (
            p_column                                => 'reason_code',
            p_lookup_type                           => 'MOSR_REASON',
            p_column_value                          => p_orig_sys_reference_rec.reason_code,
            x_return_status                         => x_return_status );

    IF p_create_update_flag = 'U'
    THEN
        open get_orig_sys_reference_csr;
        fetch get_orig_sys_reference_csr into l_start_date,l_end_date;
        close get_orig_sys_reference_csr;

        if (p_orig_sys_reference_rec.owner_table_id is not null and
            p_orig_sys_reference_rec.owner_table_id<>fnd_api.g_miss_num)
        then
          open get_nonupdateable_columns1;
          fetch get_nonupdateable_columns1 into l_created_by_module, l_application_id;
          close get_nonupdateable_columns1;
        elsif (p_orig_sys_reference_rec.orig_system_ref_id is not null and
                 p_orig_sys_reference_rec.orig_system_ref_id<>fnd_api.g_miss_num)
        then
          open get_nonupdateable_columns2;
          fetch get_nonupdateable_columns2 into l_created_by_module, l_application_id;
          close get_nonupdateable_columns2;
        end if;
    END IF;

    -- Bug 4964046 : Validate start date and end date for 'Create' as well as 'Update'
    -- if  p_create_update_flag = 'U'
    -- then
         HZ_UTILITY_V2PUB.validate_start_end_date (
        p_create_update_flag                    => p_create_update_flag,
        p_start_date_column_name                => 'start_date_active',
        p_start_date                            => trunc(p_orig_sys_reference_rec.start_date_active),  /* Bug 3298896 */
        p_old_start_date                        => trunc(l_start_date),  /* Bug 3298896 */
        p_end_date_column_name                  => 'end_date_active',
        p_end_date                              => trunc(p_orig_sys_reference_rec.end_date_active),  /* Bug 3298896 */
        p_old_end_date                          => trunc(l_end_date),  /* Bug 3298896 */
        x_return_status                         => x_return_status );
     -- end if;

    --------------------------------------
    -- validate created_by_module
    --------------------------------------

    hz_utility_v2pub.validate_created_by_module(
      p_create_update_flag     => p_create_update_flag,
      p_created_by_module      => p_orig_sys_reference_rec.created_by_module,
      p_old_created_by_module  => l_created_by_module,
      x_return_status          => x_return_status);

    --------------------------------------
    -- validate application_id
    --------------------------------------

    hz_utility_v2pub.validate_application_id(
      p_create_update_flag     => p_create_update_flag,
      p_application_id         => p_orig_sys_reference_rec.application_id,
      p_old_application_id     => l_application_id,
      x_return_status          => x_return_status);

end  VALIDATE_ORIG_SYS_REFERENCE;

--  SSM SST Integration and Extension Project

PROCEDURE VALIDATE_ORIG_SYSTEM (
    p_create_update_flag                    IN     VARCHAR2,
    p_orig_sys_rec               IN     HZ_ORIG_SYSTEM_REF_PVT.ORIG_SYS_REC_TYPE,
    x_return_status                         IN OUT NOCOPY VARCHAR2

)IS
cursor source_system_exist is
        select  sst_flag,
                created_by_module,
                orig_system,
                orig_system_type
        from hz_orig_systems_b
        where orig_system = p_orig_sys_rec.orig_system;

l_sst_flag VARCHAR2(1);
l_created_by_module VARCHAR2(150);
l_orig_system VARCHAR2(30);
l_orig_system_type VARCHAR2(30);
l_check_orig_system VARCHAR2(30);

BEGIN
	--Bug 5021733
	--No non-alphanumeric characters (other than '_') are acceptable.
	select trim(translate(upper(p_orig_sys_rec.orig_system),
	            ' ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_',
		    '1                                     '))
	into l_check_orig_system
	from dual;
	if l_check_orig_system is not null then
        	FND_MESSAGE.SET_NAME('AR', 'HZ_SSM_INVALID_SOURCE_SYSTEM');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
	end if;

        IF p_create_update_flag = 'C' THEN
                open source_system_exist;
                fetch source_system_exist
                into l_sst_flag, l_created_by_module, l_orig_system, l_orig_system_type;
                if source_system_exist%FOUND then
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
                        FND_MESSAGE.SET_TOKEN('COLUMN', 'orig_system');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                end if;

                HZ_UTILITY_V2PUB.validate_mandatory (
                        p_create_update_flag                    => p_create_update_flag,
                        p_column                                => 'orig_system',
                        p_column_value                          => p_orig_sys_rec.orig_system,
                        x_return_status                         => x_return_status );

                HZ_UTILITY_V2PUB.validate_mandatory (
                        p_create_update_flag                    => p_create_update_flag,
                        p_column                                => 'sst_flag',
                        p_column_value                          => p_orig_sys_rec.sst_flag,
                        x_return_status                         => x_return_status );

                HZ_UTILITY_V2PUB.validate_mandatory (
                        p_create_update_flag                    => p_create_update_flag,
                        p_column                                => 'orig_system_name',
                        p_column_value                          => p_orig_sys_rec.orig_system_name,
                        x_return_status                         => x_return_status );


                HZ_UTILITY_V2PUB.validate_mandatory (
                        p_create_update_flag                    => p_create_update_flag,
                        p_column                                => 'orig_system_type',
                        p_column_value                          => p_orig_sys_rec.orig_system_type,
                        x_return_status                         => x_return_status );

                HZ_UTILITY_V2PUB.validate_mandatory (
                        p_create_update_flag                    => p_create_update_flag,
                        p_column                                => 'status',
                        p_column_value                          => p_orig_sys_rec.status,
                        x_return_status                         => x_return_status );
        end if;

        IF p_create_update_flag = 'U' THEN
                open source_system_exist;
                fetch source_system_exist
                into l_sst_flag, l_created_by_module, l_orig_system, l_orig_system_type;

                HZ_UTILITY_V2PUB.validate_mandatory (
                        p_create_update_flag                    => p_create_update_flag,
                        p_column                                => 'orig_system_id',
                        p_column_value                          => p_orig_sys_rec.orig_system_id,
                        x_return_status                         => x_return_status );

        /*      IF p_orig_sys_rec.created_by_module IS NOT NULL THEN
                        HZ_UTILITY_V2PUB.validate_nonupdateable (
                                p_column                                => 'sst_flag',
                                p_column_value                          => p_orig_sys_rec.sst_flag,
                                p_old_column_value                      => l_sst_flag,
                                p_restricted                            => 'N',
                                x_return_status                         => x_return_status );
                END IF; */
                IF l_sst_flag = 'Y' and p_orig_sys_rec.sst_flag = 'N' THEN
                    FND_MESSAGE.SET_NAME('AR','HZ_SST_N_TO_Y_ONLY');
                    FND_MSG_PUB.ADD;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

                IF p_orig_sys_rec.orig_system IS NOT NULL THEN
                        HZ_UTILITY_V2PUB.validate_nonupdateable (
                                p_column                                => 'orig_system',
                                p_column_value                          => p_orig_sys_rec.orig_system,
                                p_old_column_value                      => l_orig_system,
                                p_restricted                            => 'N',
                                x_return_status                         => x_return_status );
                END IF;

                IF p_orig_sys_rec.orig_system_type IS NOT NULL THEN
                        HZ_UTILITY_V2PUB.validate_nonupdateable (
                                p_column                                => 'orig_system_type',
                                p_column_value                          => p_orig_sys_rec.orig_system_type,
                                p_old_column_value                      => l_orig_system_type,
                                p_restricted                            => 'N',
                                x_return_status                         => x_return_status );
                END IF;
        end if;

        HZ_UTILITY_V2PUB.validate_lookup (
            p_column                                => 'orig_system_type',
            p_lookup_type                           => 'HZ_ORIG_SYSTEM_TYPE',
            p_column_value                          => p_orig_sys_rec.orig_system_type,
            x_return_status                         => x_return_status );

        HZ_UTILITY_V2PUB.validate_lookup (
            p_column                                => 'status',
            p_lookup_type                           => 'MOSR_STATUS',
            p_column_value                          => p_orig_sys_rec.status,
            x_return_status                         => x_return_status );

        HZ_UTILITY_V2PUB.validate_lookup (
            p_column                                => 'sst_flag',
            p_lookup_type                           => 'YES/NO',
            p_column_value                          => p_orig_sys_rec.sst_flag,
            x_return_status                         => x_return_status );

        --------------------------------------
        -- validate created_by_module
        --------------------------------------

        hz_utility_v2pub.validate_created_by_module(
          p_create_update_flag     => p_create_update_flag,
          p_created_by_module      => p_orig_sys_rec.created_by_module,
          p_old_created_by_module  => l_created_by_module,
          x_return_status          => x_return_status);

END VALIDATE_ORIG_SYSTEM;

END HZ_MOSR_VALIDATE_PKG;

/

--------------------------------------------------------
--  DDL for Package Body FUN_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_SECURITY" AS
/* $Header: FUNSECAB.pls 120.13 2006/09/15 10:04:10 bsilveir noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30) := 'FUN_SECURITY';
g_debug_level       NUMBER   := FND_LOG.G_CURRENT_RUNTIME_LEVEL;



/*-----------------------------------------------------
 * PRIVATE PROCEDURE get_instance_set_ids
 * ----------------------------------------------------
 * Gets the instance set ids of the instances sets
 * names specified in the cursor.
 * ---------------------------------------------------*/
PROCEDURE get_instance_set_ids(
  p_trx_batches_id    OUT NOCOPY  NUMBER,
  p_trx_headers_id    OUT NOCOPY  NUMBER,
  p_dist_lines_id    OUT NOCOPY  NUMBER)
IS
   CURSOR c_get_instance_set_id
    IS
      SELECT instance_set_id, instance_set_name
      FROM fnd_object_instance_sets
      WHERE instance_set_name IN ('FUN_TRX_BATCHES_SET','FUN_TRX_HEADERS_SET','FUN_DIST_LINES_SET');
BEGIN

 IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
 THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'fun.plsql.fun_security.get_instance_set_ids','begin');
 END IF;

  FOR c_record IN c_get_instance_set_id
  LOOP
     IF (c_record.instance_set_name = 'FUN_TRX_BATCHES_SET') THEN
        p_trx_batches_id := c_record.instance_set_id;
     ELSIF (c_record.instance_set_name = 'FUN_TRX_HEADERS_SET') THEN
        p_trx_headers_id := c_record.instance_set_id;
     ELSIF (c_record.instance_set_name = 'FUN_DIST_LINES_SET') THEN
        p_dist_lines_id := c_record.instance_set_id;
     END IF;
  END LOOP;

 IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
 THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'fun.plsql.fun_security.get_instance_set_ids','end');
 END IF;

END get_instance_set_ids;



/*-----------------------------------------------------
 * PROCEDURE create_assign
 * ----------------------------------------------------
 * Create grants for the specified person to the
 * specified organization.
 * ---------------------------------------------------*/
 PROCEDURE create_assign (
   p_api_version    IN          NUMBER,
   p_init_msg_list  IN          VARCHAR2  ,
   p_commit         IN          VARCHAR2,
   x_return_status  OUT NOCOPY  VARCHAR2,
   x_msg_count      OUT NOCOPY  NUMBER,
   x_msg_data       OUT NOCOPY  VARCHAR2,
   p_org_id         IN          NUMBER DEFAULT NULL,
   p_person_id      IN          NUMBER,
   p_create_all     IN          VARCHAR2,
   p_create_contact IN          VARCHAR2,
   p_enabled_flag   IN          VARCHAR2
   )
 IS
   l_fnd_grant_guid          fnd_grants.grant_guid%TYPE;
   l_fnd_errorcode           NUMBER;
   l_menu_name               VARCHAR2(30);
   l_grant_enabled_flag      VARCHAR2(5);
   l_instance_set_batches    fnd_object_instance_sets.instance_set_id%TYPE;
   l_instance_set_headers    fnd_object_instance_sets.instance_set_id%TYPE;
   l_instance_set_dist       fnd_object_instance_sets.instance_set_id%TYPE;
   l_api_version  CONSTANT   NUMBER    :=  1.0;
   l_api_name    CONSTANT    VARCHAR2(30)  :=  'create_assign';
   l_end_date                DATE    :=  NULL;
   l_module                  VARCHAR2(100);

   CURSOR c_get_ice_orgs
   IS
          select * from (SELECT  hzp.party_id AS partyid,
            DECODE(xfi.party_id,NULL,'REMOTE','LOCAL') AS local
          FROM   HZ_PARTIES HZP,
           XLE_ENTITY_PROFILES XFI,
           HZ_PARTY_USG_ASSIGNMENTS HUA
          WHERE      HZP.PARTY_TYPE='ORGANIZATION'
          AND FUN_TCA_PKG.GET_LE_ID(HZP.PARTY_ID)=XFI.PARTY_ID
          AND HUA.PARTY_ID=HZP.PARTY_ID
          AND HUA.PARTY_USAGE_CODE ='INTERCOMPANY_ORG'
          AND  XFI.TRANSACTING_ENTITY_FLAG = 'Y') QRSLT
          WHERE (PARTYID not in ( select object_id
          from  hz_relationships where subject_id = -999
          and subject_table_name like 'HZ_PARTIES'
          and relationship_code like 'CONTACT_OF'
          and Directional_flag = 'F'
          and start_date < sysdate and end_date  > sysdate ));

 BEGIN

  l_module := 'fun.plsql.fun_security.create_assign';

  IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
  THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      l_module,'begin');
  END IF;

  --Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(
                                     l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   SAVEPOINT create_fun_grant;


  -- initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;


  -- initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  IF nvl(p_enabled_flag,'Y')='N' THEN
    l_end_date := SYSDATE-1;
  END IF;


  l_menu_name := 'FUN_DATA_ACCESS' ;

  get_instance_set_ids( l_instance_set_batches,
        l_instance_set_headers,
        l_instance_set_dist);


  IF p_create_all = 'Y' THEN
    FOR v_org_record IN c_get_ice_orgs
    LOOP
       IF v_org_record.local = 'LOCAL' THEN
       -- Check if grant previously exists.
           IF (is_access_allow(
             p_person_id,
             v_org_record.partyid) = 'Y') THEN
             IF(is_access_valid(
                    p_person_id,
                    v_org_record.partyid) = 'N') THEN
                -- Grant has been disabled
                -- Need to update grant
                update_assign(
                       p_api_version,
                       nvl(p_init_msg_list, FND_API.G_FALSE),
                       p_commit,
                       x_return_status,
                       x_msg_count,
                       x_msg_data,
                       v_org_record.partyid,
                       p_person_id,
                       'Y');
                 -- Section of code which updates the TCA relationship
                 -- TCA relationship needs to be updated only for the Assign All Local Organizations
                 -- Relationship updation in update_assign done in the JAVA code.

                DECLARE
                  l_relationship_id              NUMBER(15);
                  l_object_version_number        hz_relationships.object_version_number%TYPE;
                  l_party_object_version_number  hz_relationships.object_version_number%TYPE := NULL;
                  l_cont_object_version_number   hz_relationships.object_version_number%TYPE;
                  l_rel_object_version_number    hz_relationships.object_version_number%TYPE;
                  l_tca_relationship_record      HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
                  l_tca_contact_role_record      HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_ROLE_REC_TYPE;
                  l_tca_contact_record           HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;
                  l_org_contact_role_id          NUMBER;
                  l_org_contact_id               NUMBER;
                  l_primary_flag                 VARCHAR2(1);
                  l_status                       VARCHAR2(1);

                  CURSOR get_relationship_id_c(p_cursor_personid NUMBER,
                                               p_cursor_orgid    NUMBER)
                  IS
                    SELECT relationship_id
                    FROM hz_relationships hzr
                    WHERE hzr.subject_id=p_cursor_personid
                    AND hzr.object_id=p_cursor_orgid
                    AND hzr.relationship_code='CONTACT_OF'
                    AND hzr.relationship_type='CONTACT'
                    AND hzr.directional_flag='F'
                    AND hzr.subject_type='PERSON' ;

                  CURSOR get_object_version_num_c (p_rel_id NUMBER)
                  IS
                    SELECT object_version_number
                    FROM hz_relationships
                    WHERE relationship_id=p_rel_id ;

                BEGIN

                  OPEN get_relationship_id_c(p_person_id,v_org_record.partyid);
                    FETCH get_relationship_id_c INTO l_relationship_id;
                  CLOSE get_relationship_id_c;

                  l_tca_relationship_record.relationship_id  := l_relationship_id;
                  l_tca_relationship_record.relationship_type:= 'CONTACT';
                  l_tca_relationship_record.status            := 'A';
                  l_tca_relationship_record.comments          :=  'Updated from Oracle Intercompany';

                  OPEN get_object_version_num_c(l_relationship_id);
                    FETCH get_object_version_num_c INTO l_object_version_number;
                  CLOSE get_object_version_num_c;

--bug 4228791, added call to update org contact and contact role

                    l_tca_contact_record.party_rel_rec.relationship_id := l_relationship_id;
                    l_tca_contact_record.party_rel_rec.relationship_type := 'CONTACT';
                    l_tca_contact_record.party_rel_rec.status            := 'A';

                    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
                    THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                      l_module,'calling HZ_PARTY_CONTACT_V2PUB.update_org_contact');
                    END IF;

                    HZ_PARTY_CONTACT_V2PUB.update_org_contact(
                            p_init_msg_list                => nvl(p_init_msg_list, FND_API.G_FALSE),
                            p_org_contact_rec              => l_tca_contact_record,
                            p_cont_object_version_number   => l_cont_object_version_number,
                            p_rel_object_version_number    => l_rel_object_version_number,
                            p_party_object_version_number  => l_party_object_version_number,
                            x_return_status                => x_return_status,
                            x_msg_count                    => x_msg_count,
                            x_msg_data                     => x_msg_data
                            );
                    --dbms_output.put_line('1 : '||x_return_status||x_msg_count||x_msg_data);

                    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
                    THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                      l_module, 'completed call to HZ_PARTY_CONTACT_V2PUB.update_org_contact'
                                      || ' Status ' || x_return_status);
                    END IF;

                    IF x_return_status <> 'S'
                    THEN
                         RAISE FND_API.G_EXC_ERROR;
                    END IF;

                    SELECT hcr.org_contact_role_id, hcr.org_contact_id, hcr.primary_flag, hcr.status
                    INTO l_org_contact_role_id, l_org_contact_id, l_primary_flag, l_status
                    FROM hz_relationships hzr, hz_org_contacts hc, hz_org_contact_roles hcr
                    WHERE hzr.subject_id=p_person_id
                    AND hzr.object_id=v_org_record.partyid
                    AND hzr.relationship_code='CONTACT_OF'
                    AND hzr.relationship_type='CONTACT'
                    AND hzr.directional_flag='F'
                    AND hzr.subject_type='PERSON'
                    AND hzr.relationship_id = hc.party_relationship_id
                    AND hc.org_contact_id = hcr.org_contact_id;

                  l_tca_contact_role_record.org_contact_role_id := l_org_contact_role_id;
                  l_tca_contact_role_record.role_type := 'INTERCOMPANY_CONTACT_FOR';
                  l_tca_contact_role_record.primary_flag := l_primary_flag;
                  l_tca_contact_role_record.org_contact_id := l_org_contact_id;
                  l_tca_contact_role_record.status := l_status;
                  l_tca_contact_role_record.created_by_module := 'FUN_AGIS';

                  IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
                  THEN
                      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                      l_module,'calling HZ_PARTY_CONTACT_V2PUB.update_org_contact_role');
                  END IF;

                  HZ_PARTY_CONTACT_V2PUB.update_org_contact_role(
                            p_init_msg_list          => nvl(p_init_msg_list, FND_API.G_FALSE),
                            p_org_contact_role_rec   => l_tca_contact_role_record,
                            p_object_version_number  => l_object_version_number,
                            x_return_status          => x_return_status,
                            x_msg_count              => x_msg_count,
                            x_msg_data               => x_msg_data
                            );
                    --dbms_output.put_line('2 : '||x_return_status||x_msg_count||x_msg_data);

                    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
                    THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                      l_module, 'completed call to HZ_PARTY_CONTACT_V2PUB.update_org_contact_role'
                                      || ' Status ' || x_return_status);
                    END IF;

                    IF x_return_status <> 'S'
                    THEN
                         RAISE FND_API.G_EXC_ERROR;
                    END IF;

                END;
             END IF; -- is_access_valid = 'N'
           ELSE

            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
            THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                l_module,'calling fnd_grants_pkg.grant_function for FUN_TRX_BATCHES');
            END IF;

            fnd_grants_pkg.grant_function (
                  p_api_version       => 1,
                  p_menu_name         => l_menu_name,
                  p_object_name       => 'FUN_TRX_BATCHES',
                  p_instance_type     => 'SET',
                  p_instance_set_id   => l_instance_set_batches,
                  p_grantee_type      => 'USER',
                  p_grantee_key       => 'HZ_PARTY:'||p_person_id,
                  p_start_date        => SYSDATE,
                  p_end_date          => l_end_date,
                  x_grant_guid        => l_fnd_grant_guid,
                  x_success           => x_return_status,
                  x_errorcode         => l_fnd_errorcode,
                  p_parameter1        => v_org_record.partyid
                );

            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
            THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                               l_module, 'completed call to fnd_grants_pkg.grant_function for FUN_TRX_BATCHES'
                               || ' Status ' || x_return_status);
            END IF;

            IF x_return_status <> 'T'
            THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
            THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                l_module,'calling fnd_grants_pkg.grant_function for FUN_TRX_HEADERS');
            END IF;
            fnd_grants_pkg.grant_function (
                  p_api_version       => 1,
                  p_menu_name         => l_menu_name,
                  p_object_name       => 'FUN_TRX_HEADERS',
                  p_instance_type     => 'SET',
                  p_instance_set_id   => l_instance_set_headers,
                  p_grantee_type      => 'USER',
                  p_grantee_key       => 'HZ_PARTY:'||p_person_id,
                  p_start_date        => SYSDATE,
                  p_end_date          => l_end_date,
                  x_grant_guid        => l_fnd_grant_guid,
                  x_success           => x_return_status,
                  x_errorcode         => l_fnd_errorcode,
                  p_parameter1        => v_org_record.partyid
                );

            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
            THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                               l_module, 'completed call to fnd_grants_pkg.grant_function for FUN_TRX_HEADERS'
                               || ' Status ' || x_return_status);
            END IF;

            IF x_return_status <> 'T'
            THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
            THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                l_module,'calling fnd_grants_pkg.grant_function for FUN_DIST_LINES');
            END IF;
            fnd_grants_pkg.grant_function (
                  p_api_version       => 1,
                  p_menu_name         => l_menu_name,
                  p_object_name       => 'FUN_DIST_LINES',
                  p_instance_type     => 'SET',
                  p_instance_set_id   => l_instance_set_dist,
                  p_grantee_type      => 'USER',
                  p_grantee_key       => 'HZ_PARTY:'||p_person_id,
                  p_start_date        => SYSDATE,
                  p_end_date          => l_end_date,
                  x_grant_guid        => l_fnd_grant_guid,
                  x_success           => x_return_status,
                  x_errorcode         => l_fnd_errorcode,
                  p_parameter1        => v_org_record.partyid
                );


            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
            THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                               l_module, 'completed call to fnd_grants_pkg.grant_function for FUN_DIST_LINES'
                               || ' Status ' || x_return_status);
            END IF;

            IF x_return_status <> 'T'
            THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            --Creating the TCA relationship between the person and the organization
            -- with the check for if TCA relationship reqd
           IF (nvl(p_create_contact,'N')= 'Y') THEN
              DECLARE
                   l_relationship_id          NUMBER(15);
                   l_party_id                 NUMBER(15);
                   l_party_number             VARCHAR2(30);
                   l_tca_relationship_record  HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
                   l_tca_contact_role_record  HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_ROLE_REC_TYPE;
                   l_tca_contact_record       HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;
                   l_org_contact_role_id      NUMBER;
                   l_org_contact_id           NUMBER;
                   l_party_rel_id             NUMBER;


              BEGIN
                   l_tca_relationship_record.subject_id         := p_person_id;
                   l_tca_relationship_record.subject_type       := 'PERSON';
                   l_tca_relationship_record.subject_table_name := 'HZ_PARTIES';
                   l_tca_relationship_record.object_id          := v_org_record.partyid;
                   l_tca_relationship_record.object_type        := 'ORGANIZATION';
                   l_tca_relationship_record.object_table_name  := 'HZ_PARTIES';
                   l_tca_relationship_record.relationship_code  := 'CONTACT_OF';
                   l_tca_relationship_record.relationship_type  := 'CONTACT';
                   l_tca_relationship_record.start_date         := SYSDATE;
                   l_tca_relationship_record.created_by_module  := 'FUN_AGIS';

--bug 4228791, added call to create org contact and contact role

                  l_tca_contact_record.created_by_module := 'FUN_AGIS';
                  l_tca_contact_record.party_rel_rec.subject_id         := p_person_id;
                  l_tca_contact_record.party_rel_rec.subject_type       := 'PERSON';
                  l_tca_contact_record.party_rel_rec.subject_table_name := 'HZ_PARTIES';
                  l_tca_contact_record.party_rel_rec.object_id          := v_org_record.partyid;
                  l_tca_contact_record.party_rel_rec.object_type        := 'ORGANIZATION';
                  l_tca_contact_record.party_rel_rec.object_table_name  := 'HZ_PARTIES';
                  l_tca_contact_record.party_rel_rec.relationship_code  := 'CONTACT_OF';
                  l_tca_contact_record.party_rel_rec.relationship_type  := 'CONTACT';
                  l_tca_contact_record.party_rel_rec.start_date         := SYSDATE;
                  l_tca_contact_record.party_rel_rec.created_by_module  := 'FUN_AGIS';
                  l_tca_contact_record.party_rel_rec.status             := 'A';

                  IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
                  THEN
                      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                      l_module,'calling HZ_PARTY_CONTACT_V2PUB.create_org_contact');
                  END IF;

                  HZ_PARTY_CONTACT_V2PUB.create_org_contact(
                            p_init_msg_list         => nvl(p_init_msg_list, FND_API.G_FALSE),
                            p_org_contact_rec       => l_tca_contact_record,
                            x_org_contact_id        => l_org_contact_id,
                            x_party_rel_id          => l_party_rel_id,
                            x_party_id              => l_party_id,
                            x_party_number          => l_party_number,
                            x_return_status         => x_return_status,
                            x_msg_count             => x_msg_count,
                            x_msg_data              => x_msg_data
                            );

                    --dbms_output.put_line('3 : '||x_return_status||x_msg_count||x_msg_data);
                 IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
                 THEN
                      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                    l_module, 'completed call to HZ_PARTY_CONTACT_V2PUB.create_org_contact'
                                    || ' Status ' || x_return_status);
                 END IF;

                 IF x_return_status <> 'S'
                 THEN
                     RAISE FND_API.G_EXC_ERROR;
                 END IF;

                  l_tca_contact_role_record.role_type := 'INTERCOMPANY_CONTACT_FOR';
                  l_tca_contact_role_record.status := 'A';
                  l_tca_contact_role_record.org_contact_id := l_org_contact_id;
                  l_tca_contact_role_record.created_by_module := 'FUN_AGIS';

                  IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
                  THEN
                      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                      l_module,'calling  HZ_PARTY_CONTACT_V2PUB.create_org_contact_role');
                  END IF;

                  HZ_PARTY_CONTACT_V2PUB.create_org_contact_role(
                            p_init_msg_list         => nvl(p_init_msg_list, FND_API.G_FALSE),
                            p_org_contact_role_rec  => l_tca_contact_role_record,
                            x_org_contact_role_id   => l_org_contact_role_id,
                            x_return_status         => x_return_status,
                            x_msg_count             => x_msg_count,
                            x_msg_data              => x_msg_data
                            );

                    --dbms_output.put_line('4 : '||x_return_status||x_msg_count||x_msg_data);
                IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
                 THEN
                      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                    l_module, 'completed call to HZ_PARTY_CONTACT_V2PUB.create_org_contact_role'
                                    || ' Status ' || x_return_status);
                 END IF;

                 IF x_return_status <> 'S'
                 THEN
                     RAISE FND_API.G_EXC_ERROR;
                 END IF;


              END;
           END IF; -- p_create_contact ='y'
           END IF; -- is_access_allow= 'y'
        END IF; -- is local
    END LOOP;
  ELSIF p_create_all = 'N' THEN
    IF p_org_id IS NULL THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSE
        IF (is_access_allow(
            p_person_id,
            p_org_id) = 'Y') THEN
          IF(is_access_valid(
                 p_person_id,
                 p_org_id) = 'N') THEN
            -- Grant has been disabled
            -- Need to update grant
            update_assign(
                   p_api_version,
                   nvl(p_init_msg_list, FND_API.G_FALSE),
                   p_commit,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   p_org_id,
                   p_person_id,
                   'Y');
          END IF;
        ELSE
        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                            l_module,'calling fnd_grants_pkg.grant_function for FUN_TRX_BATCHES');
        END IF;
        --Grant does not exist
        fnd_grants_pkg.grant_function (
              p_api_version       => 1,
              p_menu_name         => l_menu_name,
              p_object_name       => 'FUN_TRX_BATCHES',
              p_instance_type     => 'SET',
              p_instance_set_id   => l_instance_set_batches,
              p_grantee_type      => 'USER',
              p_grantee_key       => 'HZ_PARTY:'||p_person_id,
              p_start_date        => SYSDATE,
              p_end_date          => l_end_date,
              x_grant_guid        => l_fnd_grant_guid,
              x_success           => x_return_status,
              x_errorcode         => l_fnd_errorcode,
              p_parameter1        => p_org_id
            );

        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
        THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           l_module, 'completed call to fnd_grants_pkg.grant_function for FUN_TRX_BATCHES'
                           || ' Status ' || x_return_status);
        END IF;

        IF x_return_status <> 'T'
        THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                            l_module,'calling fnd_grants_pkg.grant_function for FUN_TRX_HEADERS');
        END IF;

        fnd_grants_pkg.grant_function (
              p_api_version       => 1,
              p_menu_name         => l_menu_name,
              p_object_name       => 'FUN_TRX_HEADERS',
              p_instance_type     => 'SET',
              p_instance_set_id   => l_instance_set_headers,
              p_grantee_type      => 'USER',
              p_grantee_key       => 'HZ_PARTY:'||p_person_id,
              p_start_date        => SYSDATE,
              p_end_date          => l_end_date,
              x_grant_guid        => l_fnd_grant_guid,
              x_success           => x_return_status,
              x_errorcode         => l_fnd_errorcode,
              p_parameter1        => p_org_id
            );


        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
        THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           l_module, 'completed call to fnd_grants_pkg.grant_function for FUN_TRX_HEADERS'
                           || ' Status ' || x_return_status);
        END IF;

        IF x_return_status <> 'T'
        THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                            l_module,'calling fnd_grants_pkg.grant_function for FUN_DIST_LINES');
        END IF;

        fnd_grants_pkg.grant_function (
              p_api_version       => 1,
              p_menu_name         => l_menu_name,
              p_object_name       => 'FUN_DIST_LINES',
              p_instance_type     => 'SET',
              p_instance_set_id   => l_instance_set_dist,
              p_grantee_type      => 'USER',
              p_grantee_key       => 'HZ_PARTY:'||p_person_id,
              p_start_date        => SYSDATE,
              p_end_date          => l_end_date,
              x_grant_guid        => l_fnd_grant_guid,
              x_success           => x_return_status,
              x_errorcode         => l_fnd_errorcode,
              p_parameter1        => p_org_id
            );


        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
        THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           l_module, 'completed call to fnd_grants_pkg.grant_function for FUN_DIST_LINES'
                           || ' Status ' || x_return_status);
        END IF;

        IF x_return_status <> 'T'
        THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        --Creating the TCA relationship between the person and the organization
        -- with the check for if TCA relationship reqd


        IF (nvl(p_create_contact,'N')= 'Y') THEN
         DECLARE
            l_relationship_id         NUMBER(15);
            l_party_id                NUMBER(15);
            l_party_number            VARCHAR2(30);
            l_tca_relationship_record HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
            l_tca_contact_role_record HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_ROLE_REC_TYPE;
            l_tca_contact_record      HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;
            l_org_contact_role_id     NUMBER;
            l_org_contact_id          NUMBER;
            l_party_rel_id            NUMBER;


         BEGIN
            l_tca_relationship_record.subject_id        := p_person_id;
            l_tca_relationship_record.subject_type      := 'PERSON';
            l_tca_relationship_record.subject_table_name:= 'HZ_PARTIES';
            l_tca_relationship_record.object_id         := p_org_id;
            l_tca_relationship_record.object_type       := 'ORGANIZATION';
            l_tca_relationship_record.object_table_name := 'HZ_PARTIES';
            l_tca_relationship_record.relationship_code := 'CONTACT_OF';
            l_tca_relationship_record.relationship_type := 'CONTACT';
            l_tca_relationship_record.start_date        := SYSDATE;
            l_tca_relationship_record.created_by_module := 'FUN_AGIS';


--bug 4228791, added call to create org contact and contact role

                  l_tca_contact_record.created_by_module := 'FUN_AGIS';
                  l_tca_contact_record.party_rel_rec.subject_id         := p_person_id;
                  l_tca_contact_record.party_rel_rec.subject_type       := 'PERSON';
                  l_tca_contact_record.party_rel_rec.subject_table_name := 'HZ_PARTIES';
                  l_tca_contact_record.party_rel_rec.object_id          := p_org_id;
                  l_tca_contact_record.party_rel_rec.object_type        := 'ORGANIZATION';
                  l_tca_contact_record.party_rel_rec.object_table_name  := 'HZ_PARTIES';
                  l_tca_contact_record.party_rel_rec.relationship_code  := 'CONTACT_OF';
                  l_tca_contact_record.party_rel_rec.relationship_type  := 'CONTACT';
                  l_tca_contact_record.party_rel_rec.start_date         := SYSDATE;
                  l_tca_contact_record.party_rel_rec.created_by_module  := 'FUN_AGIS';
                  l_tca_contact_record.party_rel_rec.status             := 'A';

            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
            THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                l_module,'calling HZ_PARTY_CONTACT_V2PUB.create_org_contact');
            END IF;

                  HZ_PARTY_CONTACT_V2PUB.create_org_contact(
                            p_init_msg_list         => nvl(p_init_msg_list, FND_API.G_FALSE),
                            p_org_contact_rec       => l_tca_contact_record,
                            x_org_contact_id        => l_org_contact_id,
                            x_party_rel_id          => l_party_rel_id,
                            x_party_id              => l_party_id,
                            x_party_number          => l_party_number,
                            x_return_status         => x_return_status,
                            x_msg_count             => x_msg_count,
                            x_msg_data              => x_msg_data
                            );
                    --dbms_output.put_line('5 : '||x_return_status||x_msg_count||x_msg_data);

            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
            THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                               l_module, 'completed call to HZ_PARTY_CONTACT_V2PUB.create_org_contact'
                               || ' Status ' || x_return_status);
            END IF;

            IF x_return_status <> 'S'
            THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            l_tca_contact_role_record.role_type := 'INTERCOMPANY_CONTACT_FOR';
            l_tca_contact_role_record.status := 'A';
            l_tca_contact_role_record.org_contact_id := l_org_contact_id;
            l_tca_contact_role_record.created_by_module := 'FUN_AGIS';

            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
            THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                                l_module,'calling HZ_PARTY_CONTACT_V2PUB.create_org_contact_role');
            END IF;


            HZ_PARTY_CONTACT_V2PUB.create_org_contact_role(
                      p_init_msg_list         => nvl(p_init_msg_list, FND_API.G_FALSE),
                      p_org_contact_role_rec  => l_tca_contact_role_record,
                      x_org_contact_role_id   => l_org_contact_role_id,
                      x_return_status         => x_return_status,
                      x_msg_count             => x_msg_count,
                      x_msg_data              => x_msg_data
                      );
                    --dbms_output.put_line('6 : '||x_return_status||x_msg_count||x_msg_data);
            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
            THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                               l_module, 'completed call to HZ_PARTY_CONTACT_V2PUB.create_org_contact_role'
                               || ' Status ' || x_return_status);
            END IF;

            IF x_return_status <> 'S'
            THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;


         END;
        END IF; -- p_create_contact='y'
          END IF; -- is_access_allow='y'
    END IF;-- p_org_id IS NULL

  END IF;    --p_create_all='n'

    IF FND_API.To_Boolean( p_commit )
    THEN
      COMMIT WORK;
    END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
  THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      l_module,'end');
  END IF;

-- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_fun_grant;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

     IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
     THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      l_module,'Execution exception raised');
     END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_fun_grant;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

     IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level)
     THEN
         FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                      l_module,'Unexpected exception raised - ' || SQLERRM);
     END IF;

    WHEN OTHERS THEN
        ROLLBACK TO create_fun_grant;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

     IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level)
     THEN
         FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                      l_module,'Unexpected exception raised - ' || SQLERRM);
     END IF;
END create_assign;






/*-----------------------------------------------------
 * PROCEDURE update_assign
 * ----------------------------------------------------
 * Updates grants for the specified person to the
 * specified organization.
 * ---------------------------------------------------*/

 PROCEDURE update_assign (
   p_api_version    IN    NUMBER,
   p_init_msg_list  IN    VARCHAR2 ,
   p_commit         IN    VARCHAR2,
   x_return_status  OUT NOCOPY  VARCHAR2,
   x_msg_count      OUT NOCOPY  NUMBER,
   x_msg_data       OUT NOCOPY  VARCHAR2,
   p_org_id         IN    NUMBER,
   p_person_id      IN    NUMBER,
   p_status         IN    VARCHAR2
   )
 IS
   l_fnd_grant_guid        fnd_grants.grant_guid%TYPE;
   l_fnd_errorcode         NUMBER;
   l_menu_name             VARCHAR2(30);
   l_start_date            DATE;
   l_instance_set_batches  fnd_object_instance_sets.instance_set_id%TYPE;
   l_instance_set_headers  fnd_object_instance_sets.instance_set_id%TYPE;
   l_instance_set_dist     fnd_object_instance_sets.instance_set_id%TYPE;
   l_grant_guid            fnd_grants.grant_guid%TYPE;
   l_api_version           CONSTANT  NUMBER    :=  1.0;
   l_api_name              CONSTANT  VARCHAR2(30)  :=  'create_assign';
   l_module                VARCHAR2(100) := 'fun.plsql.fun_security.update_assign';

   CURSOR c_grant_info(
      p_person_id    NUMBER,
      p_org_id    NUMBER,
      p_instance_set_id  NUMBER)
   IS
     SELECT grant_guid,start_date
     FROM fnd_grants fg
     WHERE  instance_set_id = p_instance_set_id
     AND  parameter1  = p_org_id
     AND  grantee_key  = 'HZ_PARTY:'||p_person_id ;

 BEGIN

 IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
 THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      l_module,'begin');
  END IF;

  --Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(
                                     l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  SAVEPOINT update_fun_grant;
  --initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_Boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;


  -- initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_menu_name := 'FUN_DATA_ACCESS' ;

  get_instance_set_ids(
             l_instance_set_batches,
             l_instance_set_headers,
             l_instance_set_dist);


  OPEN c_grant_info(
          p_person_id,
          p_org_id,
          l_instance_set_batches);

  IF c_grant_info%NOTFOUND THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FETCH c_grant_info INTO l_grant_guid,l_start_date ;
  CLOSE c_grant_info ;

  IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
  THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     l_module, 'callinge fnd_grants_pkg.update_grant');
  END IF;

  IF p_status = 'Y' THEN
      fnd_grants_pkg.update_grant (
      p_api_version    => 1,
      p_grant_guid     => l_grant_guid,
      p_start_date     => l_start_date,
      p_end_date       => NULL,
      x_success        => x_return_status
      );
  ELSIF p_status ='N' THEN
      fnd_grants_pkg.update_grant (
      p_api_version     => 1,
      p_grant_guid      => l_grant_guid,
      p_start_date      => l_start_date,
      p_end_date        => SYSDATE-1,
      x_success         => x_return_status
      );
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
  THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     l_module, 'completed call to fnd_grants_pkg.update_grant '
                     || ' Status ' || x_return_status);
  END IF;

  IF x_return_status <> 'T'
  THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  OPEN c_grant_info(
        p_person_id,
        p_org_id,
        l_instance_set_headers);
     FETCH c_grant_info INTO l_grant_guid,l_start_date ;
  CLOSE c_grant_info ;

  IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
  THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     l_module, 'callinge fnd_grants_pkg.update_grant for headers');
  END IF;

  IF p_status = 'Y' THEN
       fnd_grants_pkg.update_grant (
         p_api_version     => 1,
         p_grant_guid      => l_grant_guid,
         p_start_date      => l_start_date,
         p_end_date        => NULL,
         x_success         => x_return_status
       );
  ELSIF p_status ='N' THEN
      fnd_grants_pkg.update_grant (
        p_api_version       => 1,
        p_grant_guid        => l_grant_guid,
        p_start_date        => l_start_date,
        p_end_date          => SYSDATE-1,
        x_success           => x_return_status
        );
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
  THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     l_module, 'completed call to fnd_grants_pkg.update_grant for headers'
                     || ' Status ' || x_return_status);
  END IF;

  IF x_return_status <> 'T'
  THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  OPEN c_grant_info(
        p_person_id,
        p_org_id,
        l_instance_set_dist);
     FETCH c_grant_info INTO l_grant_guid,l_start_date ;
  CLOSE c_grant_info ;

  IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
  THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     l_module, 'calling fnd_grants_pkg.update_grant for dists');
  END IF;

  IF p_status = 'Y' THEN
      fnd_grants_pkg.update_grant (
        p_api_version  => 1,
        p_grant_guid   => l_grant_guid,
        p_start_date   => l_start_date,
        p_end_date     => NULL,
        x_success      => x_return_status
        );
  ELSIF p_status='N' THEN
      fnd_grants_pkg.update_grant (
         p_api_version  => 1,
         p_grant_guid   => l_grant_guid,
         p_start_date   => l_start_date,
         p_end_date     => SYSDATE-1,
         x_success      => x_return_status
         );
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
  THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     l_module, 'completed call to fnd_grants_pkg.update_grant for dists'
                     || ' Status ' || x_return_status);
  END IF;

  IF x_return_status <> 'T'
  THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF FND_API.To_Boolean( p_commit )
      THEN
        COMMIT WORK;
  END IF;

  -- standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

  IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
  THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      l_module,'end');
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_fun_grant;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

     IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
     THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      l_module,'Execution exception raised');
     END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_fun_grant;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

     IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level)
     THEN
         FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                      l_module,'Unexpected exception raised - ' || SQLERRM);
     END IF;

    WHEN OTHERS THEN
        ROLLBACK TO update_fun_grant;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

     IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level)
     THEN
         FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                      l_module,'Unexpected exception raised - ' || SQLERRM);
     END IF;

END update_assign;


/*-----------------------------------------------------
 * PROCEDURE is_access_allow
 * ----------------------------------------------------
 * Checks whether an FND grant on intercompany objects
 * exists for the person.
 * ---------------------------------------------------*/

 FUNCTION is_access_allow (
    p_person_id    IN    NUMBER,
    p_org_id       IN    NUMBER)
 RETURN VARCHAR2
 IS
    l_exists        NUMBER;
 BEGIN
   IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
   THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     'fun.plsql.fun_security.is_access_allow','begin');
   END IF;

   SELECT 1
   INTO l_exists
   from DUAL
   where exists (select 1
     FROM  fnd_grants fg,
          fnd_object_instance_sets fis,
          fnd_menus fm,
          fnd_objects fo
     WHERE  fm.menu_name='FUN_DATA_ACCESS'
     AND  fo.obj_name IN ('FUN_TRX_BATCHES','FUN_TRX_HEADERS','FUN_DIST_LINES')
     AND  fis.instance_set_name IN ('FUN_TRX_BATCHES_SET','FUN_TRX_HEADERS_SET','FUN_DIST_LINES_SET')
     AND  fg.object_id=fo.object_id
     AND  fg.instance_set_id=fis.instance_set_id
     AND  fg.menu_id=fm.menu_id
     AND  fg.grantee_type='USER'
     AND  fg.grantee_key='HZ_PARTY:'||p_person_id
     AND  fg.parameter1=p_org_id)  ;

  IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
  THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'fun.plsql.fun_security.is_access_allow','end');
  END IF;

  IF l_exists > 0 THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;


 EXCEPTION
  WHEN NO_DATA_FOUND THEN
  IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
  THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'fun.plsql.fun_security.is_access_allow','end');
  END IF;
  RETURN 'N';
 END is_access_allow;



/*-----------------------------------------------------
 * PROCEDURE is_access_valid
 * ----------------------------------------------------
 * Checks whether an FND grant on intercompany objects
 * is valid or not.
 * ---------------------------------------------------*/

 FUNCTION is_access_valid (
   p_person_id    IN    NUMBER,
   p_org_id       IN    NUMBER
   ) RETURN VARCHAR2
 IS
   l_start_date        DATE;
   l_end_date          DATE;
   BEGIN


 IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
 THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'fun.plsql.fun_security.is_access_valid','begin');
 END IF;

       SELECT start_date,end_date
      INTO l_start_date,l_end_date
      FROM fnd_grants fg,
           fnd_object_instance_sets fis,
           fnd_menus fm,
           fnd_objects fo
      WHERE  fm.menu_name    = 'FUN_DATA_ACCESS'
      AND  fo.obj_name    = 'FUN_TRX_BATCHES'
      AND  fis.instance_set_name  = 'FUN_TRX_BATCHES_SET'
      AND  fg.object_id    = fo.object_id
      AND  fg.instance_set_id  = fis.instance_set_id
      AND  fg.menu_id    = fm.menu_id
      AND  fg.grantee_type    = 'USER'
      AND  fg.grantee_key    = 'HZ_PARTY:'||p_person_id
      AND  fg.parameter1    = p_org_id
      AND  ROWNUM      = 1;

 IF (FND_LOG.LEVEL_STATEMENT >= g_debug_level)
 THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'fun.plsql.fun_security.is_access_valid','end');
 END IF;

  IF ( (l_start_date IS NULL OR l_start_date <= SYSDATE)
       AND
       (l_end_date IS NULL OR l_end_date >=SYSDATE) ) THEN
       RETURN 'Y';
   ELSE
       RETURN 'N';
   END IF;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
    RETURN 'N';

   END is_access_valid;

END FUN_SECURITY;

/

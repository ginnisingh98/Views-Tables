--------------------------------------------------------
--  DDL for Package Body HZ_MIXNM_REGISTRY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MIXNM_REGISTRY_PUB" AS
/*$Header: ARHXREGB.pls 120.9 2006/02/08 12:48:00 dmmehta noship $ */

--------------------------------------
-- declaration of private global varibles
--------------------------------------

TYPE VARCHARList IS TABLE OF VARCHAR2(30);
TYPE INDEXIDList IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;

G_DEBUG_COUNT                               NUMBER := 0;
--G_DEBUG                                     BOOLEAN := FALSE;

-- org attribute name and type list

G_ORG_ATTRIBUTE_NAME_TAB                    VARCHARList;
G_ORG_ATTRIBUTE_TYPE_TAB                    VARCHARList;
G_ORG_DEN_ATTRIBUTE_NAME_TAB                VARCHARList;

-- person attribute name and type list

G_PER_ATTRIBUTE_NAME_TAB                    VARCHARList;
G_PER_ATTRIBUTE_TYPE_TAB                    VARCHARList;
G_PER_DEN_ATTRIBUTE_NAME_TAB                VARCHARList;

-- attribute grouping. The attribute name MUST be in alphanumeric order

G_PERSON_NAME_GROUP                         VARCHARList := VARCHARList(
  'MIDDLE_NAME_PHONETIC', 'PERSON_FIRST_NAME', 'PERSON_FIRST_NAME_PHONETIC',
  'PERSON_LAST_NAME', 'PERSON_LAST_NAME_PHONETIC', 'PERSON_MIDDLE_NAME', 'PERSON_INITIALS');
G_PERSON_NAME_ID_GROUP                      INDEXIDList;

G_PERSON_IDENTIFIER_GROUP                   VARCHARList := VARCHARList(
  'PERSON_IDENTIFIER', 'PERSON_IDEN_TYPE');
G_PERSON_IDENTIFIER_ID_GROUP                INDEXIDList;

G_HQ_BRANCH_IND_GROUP                       VARCHARList := VARCHARList(
  'BRANCH_FLAG', 'HQ_BRANCH_IND');
G_HQ_BRANCH_IND_ID_GROUP                    INDEXIDList;

G_ORGANIZATION_NAME_GROUP                   VARCHARList := VARCHARList(
  'ORGANIZATION_NAME', 'ORGANIZATION_NAME_PHONETIC');
G_ORGANIZATION_NAME_ID_GROUP                INDEXIDList;

G_LOCAL_ACTIVITY_CODE_GROUP                 VARCHARList := VARCHARList(
  'LOCAL_ACTIVITY_CODE', 'LOCAL_ACTIVITY_CODE_TYPE');
G_LOCAL_ACTIVITY_CODE_ID_GROUP              INDEXIDList;

G_LOCAL_BUS_IDEN_GROUP                      VARCHARList := VARCHARList(
  'LOCAL_BUS_IDENTIFIER', 'LOCAL_BUS_IDEN_TYPE');
G_LOCAL_BUS_IDEN_ID_GROUP                   INDEXIDList;

G_SIC_CODE_GROUP                            VARCHARList := VARCHARList(
  'SIC_CODE', 'SIC_CODE_TYPE');
G_SIC_CODE_ID_GROUP                         INDEXIDList;

G_DUNS_NUMBER_GROUP                         VARCHARList := VARCHARList(
  'DISPLAYED_DUNS_PARTY_ID', 'DUNS_NUMBER_C', 'ENQUIRY_DUNS');
G_DUNS_NUMBER_ID_GROUP                      INDEXIDList;

G_CEO_GROUP                                 VARCHARList := VARCHARList(
  'CEO_NAME', 'CEO_TITLE');
G_CEO_ID_GROUP                              INDEXIDList;

G_PRINCIPAL_GROUP                           VARCHARList := VARCHARList(
  'PRINCIPAL_NAME', 'PRINCIPAL_TITLE');
G_PRINCIPAL_ID_GROUP                        INDEXIDList;

G_MINORITY_OWNED_GROUP                      VARCHARList := VARCHARList(
  'MINORITY_OWNED_IND', 'MINORITY_OWNED_TYPE');
G_MINORITY_OWNED_ID_GROUP                   INDEXIDList;

G_PERSON_ENTITY                             CONSTANT VARCHAR2(30) := 'HZ_PERSON_PROFILES';
G_ORG_ENTITY                                CONSTANT VARCHAR2(30) := 'HZ_ORGANIZATION_PROFILES';

--------------------------------------
-- declaration of private procedures and functions
--------------------------------------

/*PROCEDURE enable_debug;

PROCEDURE disable_debug;
*/

PROCEDURE do_AddEntityAttribute (
    p_entity_attribute_rec                  IN     ENTITY_ATTRIBUTE_REC_TYPE,
    p_data_source_tab                       IN     DATA_SOURCE_TBL,
    x_entity_attr_id                        OUT    NOCOPY NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE Find_NameListInAGroup (
    p_create_update_flag                    IN     VARCHAR2 := NULL,
    p_entity_name                           IN     VARCHAR2,
    p_attribute_name                        IN     VARCHAR2,
    x_group_name                            OUT    NOCOPY VARCHAR2,
    x_group                                 OUT    NOCOPY VARCHARList,
    x_group_id                              OUT    NOCOPY INDEXIDList
);

PROCEDURE Set_EntityAttrIdInAGroup (
    p_group_name                            IN    VARCHAR2,
    p_index                                 IN    NUMBER,
    p_entity_attr_id                        IN    NUMBER
);

PROCEDURE Validate_EntityAttribute (
    p_entity_attribute_rec                  IN     ENTITY_ATTRIBUTE_REC_TYPE,
    p_data_source_tab                       IN     DATA_SOURCE_TBL,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_Attribute (
    p_entity_name                           IN     VARCHAR2,
    p_attribute_name                        IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

FUNCTION getIndex (
    p_list                                  IN     VARCHARList,
    p_value                                 IN     VARCHAR2
) RETURN NUMBER;

PROCEDURE db_InsertEntityAttribute (
    p_entity_attribute_rec                  IN     ENTITY_ATTRIBUTE_REC_TYPE,
    p_group_name                            IN     VARCHAR2,
    x_entity_attr_id                        OUT    NOCOPY NUMBER
);

PROCEDURE db_InsertDataSource (
    p_new_item_flag                         IN     VARCHAR2,
    p_entity_attr_id                        IN     NUMBER,
    p_data_source_tab                       IN     DATA_SOURCE_TBL
);

PROCEDURE LoadGroupId (
    p_entity_name                           IN     VARCHAR2,
    p_name_group                            IN     VARCHARList,
    p_id_group                              IN OUT NOCOPY INDEXIDList
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
    G_DEBUG_COUNT := G_DEBUG_COUNT + 1;

    IF G_DEBUG_COUNT = 1 THEN
      IF FND_PROFILE.value( 'HZ_API_FILE_DEBUG_ON' ) = 'Y' OR
         FND_PROFILE.value( 'HZ_API_DBMS_DEBUG_ON' ) = 'Y'
      THEN
         HZ_UTILITY_V2PUB.enable_debug;
         G_DEBUG := TRUE;
      END IF;
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
      G_DEBUG_COUNT := G_DEBUG_COUNT - 1;

      IF G_DEBUG_COUNT = 0 THEN
          HZ_UTILITY_V2PUB.disable_debug;
          G_DEBUG := FALSE;
      END IF;
    END IF;
END disable_debug;
*/

/**
 * PRIVATE PROCEDURE LoadGroupId
 *
 * DESCRIPTION
 *     Private procedure to load Ids for the attributes in a group.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_name                  Entity name.
 *     p_attribute_name               Attribute name.
 *   IN OUT:
 *     p_id_group                     Attribute id list in a group.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2004    Jianying Huang      o Created.
 *
 */

PROCEDURE LoadGroupId (
    p_entity_name                           IN     VARCHAR2,
    p_name_group                            IN     VARCHARList,
    p_id_group                              IN OUT NOCOPY INDEXIDList
) IS

    CURSOR c_entity (
        p_entity_name      VARCHAR2,
        p_attribute_name   VARCHAR2
    ) IS
    SELECT entity_attr_id
    FROM hz_entity_attributes
    WHERE entity_name = p_entity_name
    AND attribute_name = p_attribute_name;

    l_entity_attr_id                        NUMBER;

BEGIN

    FOR i IN 1..p_name_group.COUNT LOOP
      OPEN c_entity(p_entity_name, p_name_group(i));
      FETCH c_entity INTO l_entity_attr_id;
      IF c_entity%FOUND THEN
        p_id_group(i) := l_entity_attr_id;
      END IF;
      CLOSE c_entity;
    END LOOP;

END LoadGroupId;

/**
 * PRIVATE PROCEDURE do_AddEntityAttribute
 *
 * DESCRIPTION
 *     Private procedure to add entity / attribute into the dictionary.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_attribute_rec         Entity Attribute record.
 *     p_data_source_tab              PL/SQL table for data source setup.
 *   IN/OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *   OUT:
 *     x_entity_attr_id               Dictionary ID.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *   12-12-2004    Rajib Ranjan Borah  o SSM SST Integration and Extension.
 *                                       For other entities pass 'O' as p_new_item_flag.
 *
 */

PROCEDURE do_AddEntityAttribute (
    p_entity_attribute_rec                  IN     ENTITY_ATTRIBUTE_REC_TYPE,
    p_data_source_tab                       IN     DATA_SOURCE_TBL,
    x_entity_attr_id                        OUT    NOCOPY NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_group_name                            VARCHAR2(30) := NULL;
    l_group                                 VARCHARList;
    l_group_id                              INDEXIDList;
    l_entity_attribute_rec                  ENTITY_ATTRIBUTE_REC_TYPE := p_entity_attribute_rec;
    l_entity_attr_id                        NUMBER;
    l_total                                 NUMBER := 1;
    l_create_update_flag                    VARCHAR2(1) := 'U';
    l_debug_prefix                          VARCHAR2(30) := '';
    l_new_item_flag                         VARCHAR2(1);
    CURSOR c_entity (
        p_entity_name      VARCHAR2,
        p_attribute_name   VARCHAR2
    ) IS
    SELECT entity_attr_id
    FROM hz_entity_attributes
    WHERE entity_name = p_entity_name
    AND ((attribute_name IS NULL AND
         (p_attribute_name IS NULL OR
          p_attribute_name = FND_API.G_MISS_CHAR)) OR
        (attribute_name = p_attribute_name));

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=> 'do_AddEntityAttribute (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- add the entity and / or attribute into the dictionary
    OPEN c_entity(
      p_entity_attribute_rec.entity_name,
      p_entity_attribute_rec.attribute_name);
    FETCH c_entity INTO x_entity_attr_id;

    IF c_entity%NOTFOUND THEN
      l_create_update_flag := 'C';
    END IF;
    CLOSE c_entity;

    -- find the group the attribute belongs to.

    IF p_entity_attribute_rec.entity_name IS NOT NULL AND
       p_entity_attribute_rec.entity_name <> FND_API.G_MISS_CHAR AND
       p_entity_attribute_rec.attribute_name IS NOT NULL AND
       p_entity_attribute_rec.attribute_name <> FND_API.G_MISS_CHAR
    THEN
      Find_NameListInAGroup (
          p_create_update_flag    => l_create_update_flag,
          p_entity_name           => p_entity_attribute_rec.entity_name,
          p_attribute_name        => p_entity_attribute_rec.attribute_name,
          x_group_name            => l_group_name,
          x_group                 => l_group,
          x_group_id              => l_group_id);

      l_total := l_group.COUNT;
    END IF;

    IF l_create_update_flag = 'C' THEN
      FOR i IN 1..l_total LOOP
        l_entity_attribute_rec.attribute_name := l_group(i);

        -- validate inputs
        Validate_EntityAttribute (
            p_entity_attribute_rec          => l_entity_attribute_rec,
            p_data_source_tab               => p_data_source_tab,
            x_return_status                 => x_return_status);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        db_InsertEntityAttribute (
            p_entity_attribute_rec          => l_entity_attribute_rec,
            p_group_name                    => l_group_name,
            x_entity_attr_id                => x_entity_attr_id);

        IF l_total > 1 THEN
          Set_EntityAttrIdInAGroup (
              p_group_name                  => l_group_name,
              p_index                       => i,
              p_entity_attr_id              => x_entity_attr_id);
        END IF;

        IF p_entity_attribute_rec.attribute_name IS NULL THEN
            l_new_item_flag := 'O';
        ELSE
            l_new_item_flag := 'Y';
        END IF;

        -- add the data source.
        db_InsertDataSource (
            p_new_item_flag                 => l_new_item_flag,
            p_entity_attr_id                => x_entity_attr_id,
            p_data_source_tab               => p_data_source_tab);
      END LOOP;
    ELSE
      FOR i IN 1..l_total LOOP
        IF l_total > 1 THEN
          l_entity_attr_id := l_group_id(i);
        ELSE
          l_entity_attr_id := x_entity_attr_id;
        END IF;

        IF p_entity_attribute_rec.attribute_name IS NULL THEN
            l_new_item_flag := 'O';
        ELSE
            l_new_item_flag := 'N';
        END IF;
        -- add the data source.
        db_InsertDataSource (
            p_new_item_flag                 => l_new_item_flag,
            p_entity_attr_id                => l_entity_attr_id,
            p_data_source_tab               => p_data_source_tab);
      END LOOP;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_AddEntityAttribute (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_AddEntityAttribute;

/**
 * PRIVATE PROCEDURE Find_NameListInAGroup
 *
 * DESCRIPTION
 *     Private procedure to return the attribute list in a given group.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag                  'C' is for create.
 *     p_entity_name                  Entity name.
 *     p_attribute_name               Attribute name.
 *   OUT:
 *     x_group_name                   Group name.
 *     x_group                        Attribute name list in a group.
 *     x_group_id                     Attribute id list in a group.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE Find_NameListInAGroup (
    p_create_update_flag                    IN     VARCHAR2 := NULL,
    p_entity_name                           IN     VARCHAR2,
    p_attribute_name                        IN     VARCHAR2,
    x_group_name                            OUT    NOCOPY VARCHAR2,
    x_group                                 OUT    NOCOPY VARCHARList,
    x_group_id                              OUT    NOCOPY INDEXIDList
) IS
BEGIN

    IF p_entity_name = G_PERSON_ENTITY THEN

      IF p_attribute_name = 'PERSON_NAME' OR
         getIndex(G_PERSON_NAME_GROUP, p_attribute_name) > 0
      THEN
        x_group_name := 'PERSON_NAME';
        x_group := G_PERSON_NAME_GROUP;
        IF p_create_update_flag = 'U' THEN
          IF G_PERSON_NAME_GROUP.COUNT > G_PERSON_NAME_ID_GROUP.COUNT THEN
            LoadGroupId(G_PERSON_ENTITY, x_group, G_PERSON_NAME_ID_GROUP);
          END IF;
          x_group_id := G_PERSON_NAME_ID_GROUP;
        END IF;

      ELSIF getIndex(G_PERSON_IDENTIFIER_GROUP, p_attribute_name) > 0 THEN
        x_group_name := 'PERSON_IDENTIFIER';
        x_group := G_PERSON_IDENTIFIER_GROUP;
        IF p_create_update_flag = 'U' THEN
          IF G_PERSON_IDENTIFIER_GROUP.COUNT > G_PERSON_IDENTIFIER_ID_GROUP.COUNT THEN
            LoadGroupId(G_PERSON_ENTITY, x_group, G_PERSON_IDENTIFIER_ID_GROUP);
          END IF;
          x_group_id := G_PERSON_IDENTIFIER_ID_GROUP;
        END IF;

      ELSE
        x_group_name := p_attribute_name;
        x_group := VARCHARList();
        x_group.EXTEND(1);
        x_group(1) := p_attribute_name;
      END IF;

    ELSIF p_entity_name = G_ORG_ENTITY THEN

      IF getIndex(G_HQ_BRANCH_IND_GROUP, p_attribute_name) > 0 THEN
        x_group_name := 'HQ_BRANCH_IND';
        x_group := G_HQ_BRANCH_IND_GROUP;
        IF p_create_update_flag = 'U' THEN
          IF G_HQ_BRANCH_IND_GROUP.COUNT > G_HQ_BRANCH_IND_ID_GROUP.COUNT THEN
            LoadGroupId(G_ORG_ENTITY, x_group, G_HQ_BRANCH_IND_ID_GROUP);
          END IF;
          x_group_id := G_HQ_BRANCH_IND_ID_GROUP;
        END IF;

      ELSIF getIndex(G_ORGANIZATION_NAME_GROUP, p_attribute_name) > 0 THEN
        x_group_name := 'ORGANIZATION_NAME';
        x_group := G_ORGANIZATION_NAME_GROUP;
        IF p_create_update_flag = 'U' THEN
          IF G_ORGANIZATION_NAME_GROUP.COUNT > G_ORGANIZATION_NAME_ID_GROUP.COUNT THEN
            LoadGroupId(G_ORG_ENTITY, x_group, G_ORGANIZATION_NAME_ID_GROUP);
          END IF;
          x_group_id := G_ORGANIZATION_NAME_ID_GROUP;
        END IF;

      ELSIF getIndex(G_LOCAL_ACTIVITY_CODE_GROUP, p_attribute_name) > 0 THEN
        x_group_name := 'LOCAL_ACTIVITY_CODE';
        x_group := G_LOCAL_ACTIVITY_CODE_GROUP;
        IF p_create_update_flag = 'U' THEN
          IF G_LOCAL_ACTIVITY_CODE_GROUP.COUNT > G_LOCAL_ACTIVITY_CODE_ID_GROUP.COUNT THEN
            LoadGroupId(G_ORG_ENTITY, x_group, G_LOCAL_ACTIVITY_CODE_ID_GROUP);
          END IF;
          x_group_id := G_LOCAL_ACTIVITY_CODE_ID_GROUP;
        END IF;

      ELSIF getIndex(G_LOCAL_BUS_IDEN_GROUP, p_attribute_name) > 0 THEN
        x_group_name := 'LOCAL_BUS_IDENTIFIER';
        x_group := G_LOCAL_BUS_IDEN_GROUP;
        IF p_create_update_flag = 'U' THEN
          IF G_LOCAL_BUS_IDEN_GROUP.COUNT > G_LOCAL_BUS_IDEN_ID_GROUP.COUNT THEN
            LoadGroupId(G_ORG_ENTITY, x_group, G_LOCAL_BUS_IDEN_ID_GROUP);
          END IF;
          x_group_id := G_LOCAL_BUS_IDEN_ID_GROUP;
        END IF;

      ELSIF getIndex(G_SIC_CODE_GROUP, p_attribute_name) > 0 THEN
        x_group_name := 'SIC_CODE';
        x_group := G_SIC_CODE_GROUP;
        IF p_create_update_flag = 'U' THEN
          IF G_SIC_CODE_GROUP.COUNT > G_SIC_CODE_ID_GROUP.COUNT THEN
            LoadGroupId(G_ORG_ENTITY, x_group, G_SIC_CODE_ID_GROUP);
          END IF;
          x_group_id := G_SIC_CODE_ID_GROUP;
        END IF;

      ELSIF getIndex(G_DUNS_NUMBER_GROUP, p_attribute_name) > 0 THEN
        x_group_name := 'DUNS_NUMBER_C';
        x_group := G_DUNS_NUMBER_GROUP;
        IF p_create_update_flag = 'U' THEN
          IF G_DUNS_NUMBER_GROUP.COUNT > G_DUNS_NUMBER_ID_GROUP.COUNT THEN
            LoadGroupId(G_ORG_ENTITY, x_group, G_DUNS_NUMBER_ID_GROUP);
          END IF;
          x_group_id := G_DUNS_NUMBER_ID_GROUP;
        END IF;

      ELSIF getIndex(G_CEO_GROUP, p_attribute_name) > 0 THEN
        x_group_name := 'CEO_NAME';
        x_group := G_CEO_GROUP;
        IF p_create_update_flag = 'U' THEN
          IF G_CEO_GROUP.COUNT > G_CEO_ID_GROUP.COUNT THEN
            LoadGroupId(G_ORG_ENTITY, x_group, G_CEO_ID_GROUP);
          END IF;
          x_group_id := G_CEO_ID_GROUP;
        END IF;

      ELSIF getIndex(G_PRINCIPAL_GROUP, p_attribute_name) > 0 THEN
        x_group_name := 'PRINCIPAL_NAME';
        x_group := G_PRINCIPAL_GROUP;
        IF p_create_update_flag = 'U' THEN
          IF G_PRINCIPAL_GROUP.COUNT > G_PRINCIPAL_ID_GROUP.COUNT THEN
            LoadGroupId(G_ORG_ENTITY, x_group, G_PRINCIPAL_ID_GROUP);
          END IF;
          x_group_id := G_PRINCIPAL_ID_GROUP;
        END IF;

      ELSIF getIndex(G_MINORITY_OWNED_GROUP, p_attribute_name) > 0 THEN
        x_group_name := 'MINORITY_OWNED_IND';
        x_group := G_MINORITY_OWNED_GROUP;
        IF p_create_update_flag = 'U' THEN
          IF G_MINORITY_OWNED_GROUP.COUNT > G_MINORITY_OWNED_ID_GROUP.COUNT THEN
            LoadGroupId(G_ORG_ENTITY, x_group, G_MINORITY_OWNED_ID_GROUP);
          END IF;
          x_group_id := G_MINORITY_OWNED_ID_GROUP;
        END IF;

      ELSE
        x_group_name := p_attribute_name;
        x_group := VARCHARList();
        x_group.EXTEND(1);
        x_group(1) := p_attribute_name;
      END IF;

    END IF;

END Find_NameListInAGroup;

/**
 * PRIVATE PROCEDURE Set_EntityAttrIdInAGroup
 *
 * DESCRIPTION
 *     Private procedure to set the attribute id in a group.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_group_name                   Group name.
 *     p_index                        Index.
 *     p_entity_attr_id               Attribute id.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE Set_EntityAttrIdInAGroup (
    p_group_name                            IN    VARCHAR2,
    p_index                                 IN    NUMBER,
    p_entity_attr_id                        IN    NUMBER
) IS
BEGIN

    IF p_group_name = 'PERSON_NAME' THEN
      G_PERSON_NAME_ID_GROUP(p_index) := p_entity_attr_id;
    ELSIF p_group_name = 'PERSON_IDENTIFIER' THEN
      G_PERSON_IDENTIFIER_ID_GROUP(p_index) := p_entity_attr_id;
    ELSIF p_group_name = 'HQ_BRANCH_IND' THEN
      G_HQ_BRANCH_IND_ID_GROUP(p_index) := p_entity_attr_id;
    ELSIF p_group_name = 'ORGANIZATION_NAME' THEN
      G_ORGANIZATION_NAME_ID_GROUP(p_index) := p_entity_attr_id;
    ELSIF p_group_name = 'LOCAL_ACTIVITY_CODE' THEN
      G_LOCAL_ACTIVITY_CODE_ID_GROUP(p_index) := p_entity_attr_id;
    ELSIF p_group_name = 'LOCAL_BUS_IDENTIFIER' THEN
      G_LOCAL_BUS_IDEN_ID_GROUP(p_index) := p_entity_attr_id;
    ELSIF p_group_name = 'SIC_CODE' THEN
      G_SIC_CODE_ID_GROUP(p_index) := p_entity_attr_id;
    ELSIF p_group_name = 'DUNS_NUMBER_C' THEN
      G_DUNS_NUMBER_ID_GROUP(p_index) := p_entity_attr_id;
    ELSIF p_group_name = 'CEO_NAME' THEN
      G_CEO_ID_GROUP(p_index) := p_entity_attr_id;
    ELSIF p_group_name = 'PRINCIPAL_NAME' THEN
      G_PRINCIPAL_ID_GROUP(p_index) := p_entity_attr_id;
    ELSIF p_group_name = 'MINORITY_OWNED_IND' THEN
      G_MINORITY_OWNED_ID_GROUP(p_index) := p_entity_attr_id;
    END IF;

END Set_EntityAttrIdInAGroup;

/**
 * PRIVATE PROCEDURE Validate_EntityAttribute
 *
 * DESCRIPTION
 *     Private procedure to validate entity / attribute.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_attribute_rec         Entity Attribute record.
 *     p_data_source_tab              PL/SQL table for data source setup.
 *   IN/OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *   11-24-2004    Rajib Ranjan Borah  o SSM SST Integration and Extension.
 *                                     Data Source will not be validated against lookup
 *                                     type CONTENT_SOURCE_TYPE.
 */

PROCEDURE Validate_EntityAttribute (
    p_entity_attribute_rec                  IN     ENTITY_ATTRIBUTE_REC_TYPE,
    p_data_source_tab                       IN     DATA_SOURCE_TBL,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS
l_debug_prefix                 VARCHAR2(30) := '';
BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Validate_EntityAttribute (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    --------------------------------------
    -- validate entity_name
    --------------------------------------

    -- entity_name is mandatory field.

    hz_utility_v2pub.validate_mandatory (
        p_create_update_flag                => 'C',
        p_column                            => 'entity_name',
        p_column_value                      => p_entity_attribute_rec.entity_name,
        x_return_status                     => x_return_status );

    -- entity_name is lookup code in lookup type ENTITY_NAME

    IF p_entity_attribute_rec.entity_name IS NOT NULL AND
       p_entity_attribute_rec.entity_name <> FND_API.G_MISS_CHAR
    THEN
      hz_utility_v2pub.validate_lookup (
          p_column                    => 'entity_name',
          p_lookup_type               => 'ENTITY_NAME',
          p_column_value              => p_entity_attribute_rec.entity_name,
          x_return_status             => x_return_status );
    END IF;

    -- the validation for attribute_name only makes sense when the entity_name
    -- has a valid value.

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

      --------------------------------------
      -- validate attribute_name
      --------------------------------------

      -- attribute_name must be null when entity_name is for other
      -- entities. attribute_name is mandatory if entity_name is
      -- for party profiles.

      IF p_entity_attribute_rec.entity_name NOT IN
         (G_ORG_ENTITY, G_PERSON_ENTITY) AND
         p_entity_attribute_rec.attribute_name IS NOT NULL AND
         p_entity_attribute_rec.attribute_name <> FND_API.G_MISS_CHAR
      THEN
        fnd_message.set_name('AR','HZ_API_COLUMN_SHOULD_BE_NULL');
        fnd_message.set_token('COLUMN','attribute_name');
        fnd_message.set_token('TABLE','hz_entity_attributes');
        fnd_msg_pub.add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      ELSIF p_entity_attribute_rec.entity_name IN
           (G_ORG_ENTITY, G_PERSON_ENTITY)
      THEN
        -- attribute_name is mandatory field.

        hz_utility_v2pub.validate_mandatory (
            p_create_update_flag         => 'C',
            p_column                     => 'attribute_name',
            p_column_value               => p_entity_attribute_rec.attribute_name,
            x_return_status              => x_return_status );

        -- attribute must be a valid attribute in the
        -- corresponding api record type.

        Validate_Attribute (
            p_entity_name                => p_entity_attribute_rec.entity_name,
            p_attribute_name             => p_entity_attribute_rec.attribute_name,
            x_return_status              => x_return_status );
/*
        -- attribute must be a valid lookup code

        hz_utility_v2pub.validate_lookup (
          p_column                    => 'attribute name',
          p_lookup_type               => p_entity_attribute_rec.entity_name,
          p_column_value              => p_entity_attribute_rec.attribute_name,
          x_return_status             => x_return_status );
*/
      END IF;
    END IF;

    --------------------------------------
    -- validate created_by_module
    --------------------------------------

    hz_utility_v2pub.validate_created_by_module(
      p_create_update_flag     => 'C',
      p_created_by_module      => p_entity_attribute_rec.created_by_module,
      p_old_created_by_module  => null,
      x_return_status          => x_return_status);

    --------------------------------------
    -- validate data sources
    --------------------------------------

    -- p_data_source_tab can not be empty.
    -- Every data source must be a valid lookup code under
    -- CONTENT_SOURCE_TYPE excluding SST.

    -- SSM SST Integration and Extension: data source will be a foreign key in hz_orig_systems_b
    -- and will not be a lookup of type CONTENT_SOURCE_TYPE.
    IF p_data_source_tab.COUNT = 0 THEN
      fnd_message.set_name('AR', 'HZ_API_NO_DATA_SOURCE');
      fnd_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
      FOR i IN 1..p_data_source_tab.COUNT LOOP
        IF p_data_source_tab(i) IS NULL OR
           p_data_source_tab(i) = 'SST'
        THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_DATA_SOURCE');
          fnd_msg_pub.add;
          x_return_status := FND_API.G_RET_STS_ERROR;
        ELSE
        /*
          hz_utility_v2pub.validate_lookup (
              p_column            => 'data source',
              p_lookup_type       => 'CONTENT_SOURCE_TYPE',
              p_column_value      => p_data_source_tab(i),
              x_return_status     => x_return_status );
        */
        DECLARE
            CURSOR c_valid_data_source IS
                SELECT '1'
                FROM   HZ_ORIG_SYSTEMS_B
                WHERE  orig_system = p_data_source_tab(i)
                  AND  sst_flag = 'Y';
            l_dummy  VARCHAR2(1);
        BEGIN
            OPEN  c_valid_data_source;
            LOOP
                FETCH c_valid_data_source
                INTO  l_dummy;

                IF c_valid_data_source%NOTFOUND THEN
                    FND_MESSAGE.SET_NAME('AR','HZ_API_INVALID_FK');
                    FND_MESSAGE.SET_TOKEN('TABLE','HZ_ORIG_SYSTEM_B');
                    FND_MESSAGE.SET_TOKEN('COLUMN','ORIG_SYSTEM');
                    FND_MESSAGE.SET_TOKEN('FK','DATA SOURCE');
                    FND_MSG_PUB.ADD;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
            END LOOP;
            CLOSE c_valid_data_source;
        EXCEPTION
            WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END;

        END IF;
      END LOOP;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Validate_EntityAttribute (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END Validate_EntityAttribute;

/**
 * PRIVATE PROCEDURE Validate_Attribute
 *
 * DESCRIPTION
 *     Validate attribute name against V2 API rec type.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_name                  Entity Name
 *     p_attribute_name               Attribute Name
 *   IN/OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   02-12-2002    Jianying Huang      o Created.
 */

PROCEDURE Validate_Attribute (
    p_entity_name                           IN     VARCHAR2,
    p_attribute_name                        IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    CURSOR c_attribute_name (
      p_name             VARCHAR2,
      p_apps_schema      VARCHAR2,
      p_ar_schema        VARCHAR2
    ) IS
   --  Bug 4956769 : Modify for perf
   select aa.argument_name, aa.data_type, party.column_name
     from sys.all_arguments aa, (
          select min(a.sequence) id
            from sys.all_arguments a
           where a.object_name = 'GET_' ||upper (p_name)||'_REC'
             and a.type_subname = upper (p_name) || '_REC_TYPE'
             and a.data_level = 0
             and a.object_id in (
                 select b.object_id
                   from sys.all_objects b
                  where b.object_name = 'HZ_PARTY_V2PUB'
                    and b.owner = p_apps_schema
                    and b.object_type = 'PACKAGE')) temp1, (
          select column_name
            from sys.all_tab_columns c
           where c.table_name = 'HZ_PARTIES'
             and c.owner = p_ar_schema
             and exists (
                 select null
                   from sys.all_tab_columns c2
                  where c2.owner = p_ar_schema
                    and c2.column_name = c.column_name
                    and c2.table_name = 'HZ_' ||upper (p_name) || '_PROFILES')
             and c.column_name not like 'ATTRIBUTE%'
             and c.column_name not like 'GLOBAL_ATTRIBUTE%'
             and c.column_name not in ('APPLICATION_ID')) party
    where aa.object_name = 'GET_' ||upper (p_name)||'_REC'
      and aa.data_level = 1
      and aa.data_type <> 'PL/SQL RECORD'
      and aa.argument_name not in ('CONTENT_SOURCE_TYPE',
          'ACTUAL_CONTENT_SOURCE', 'APPLICATION_ID')
      and aa.sequence > temp1.id
      and aa.object_id in (
          select b.object_id
            from sys.all_objects b
           where b.object_name = 'HZ_PARTY_V2PUB'
             and b.owner = p_apps_schema
             and b.object_type = 'PACKAGE')
      and aa.argument_name = party.column_name (+)
      order by argument_name;

    l_name                                  VARCHAR2(30);
    i                                       NUMBER;
    l_raise_error                           BOOLEAN := FALSE;
    l_debug_prefix                          VARCHAR2(30) := '';
    l_bool                                  BOOLEAN;
    l_status                                VARCHAR2(255);
    l_apps_schema                           VARCHAR2(255);
    l_ar_schema                             VARCHAR2(255);
    l_tmp                                   VARCHAR2(2000);

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Validate_Attribute (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_apps_schema := hz_utility_v2pub.Get_AppsSchemaName;
    l_ar_schema := hz_utility_v2pub.Get_SchemaName('AR');

    IF p_entity_name = G_ORG_ENTITY THEN
      l_name := 'ORGANIZATION';

      IF G_ORG_ATTRIBUTE_NAME_TAB IS NULL OR
         G_ORG_ATTRIBUTE_TYPE_TAB.COUNT = 0
      THEN
        OPEN c_attribute_name(l_name, l_apps_schema, l_ar_schema);
        FETCH c_attribute_name BULK COLLECT INTO
          G_ORG_ATTRIBUTE_NAME_TAB, G_ORG_ATTRIBUTE_TYPE_TAB,
          G_ORG_DEN_ATTRIBUTE_NAME_TAB;
        CLOSE c_attribute_name;

      END IF;

      i := getIndex(G_ORG_ATTRIBUTE_NAME_TAB, p_attribute_name);
      IF i = 0 THEN
        l_raise_error := TRUE;
      END IF;
    ELSE
      l_name := 'PERSON';

      IF G_PER_ATTRIBUTE_NAME_TAB IS NULL OR
         G_PER_ATTRIBUTE_TYPE_TAB.COUNT = 0
      THEN
        OPEN c_attribute_name(l_name, l_apps_schema, l_ar_schema);
        FETCH c_attribute_name BULK COLLECT INTO
          G_PER_ATTRIBUTE_NAME_TAB, G_PER_ATTRIBUTE_TYPE_TAB,
          G_PER_DEN_ATTRIBUTE_NAME_TAB;
        CLOSE c_attribute_name;
      END IF;

      i := getIndex(G_PER_ATTRIBUTE_NAME_TAB, p_attribute_name);
      IF i = 0 THEN
        l_raise_error := TRUE;
      END IF;
    END IF;

    IF l_raise_error THEN
      fnd_message.set_name('AR', 'HZ_API_INVALID_ATTRIBUTE');
      fnd_message.set_token('ATTRIBUTE', p_attribute_name);
      fnd_message.set_token('ENTITY', l_name);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Validate_Attribute (-)' ,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END Validate_Attribute;

/**
 * PRIVATE FUNCTION getIndex
 *
 * DESCRIPTION
 *     Returns the index of an element in an ordered varchar2 list.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_list                         VARCHAR2 List
 *     p_value                        Element Value
 *   IN/OUT:
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   02-12-2002    Jianying Huang      o Created.
 */

FUNCTION getIndex (
    p_list                                  IN     VARCHARList,
    p_value                                 IN     VARCHAR2
) RETURN NUMBER IS

    l_start                                 NUMBER;
    l_end                                   NUMBER;
    l_middle                                NUMBER;
    l_debug_prefix                          VARCHAR2(30) := '';

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'getIndex (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_start := 1;  l_end := p_list.COUNT;
    WHILE l_start <= l_end LOOP
      l_middle := ROUND((l_end+l_start)/2);
      IF p_value = p_list(l_middle) THEN
        RETURN l_middle;
      ELSIF p_value > p_list(l_middle) THEN
        l_start := l_middle+1;
      ELSE
        l_end := l_middle-1;
      END IF;
    END LOOP;

    RETURN 0;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'getIndex (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END getIndex;

/**
 * PRIVATE PROCEDURE db_InsertEntityAttribute
 *
 * DESCRIPTION
 *     Private procedure to insert entity / attribute into the table.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_attribute_rec         Entity Attribute record.
 *   OUT:
 *     x_entity_attr_id               Dictionary ID.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   02-12-2002    Jianying Huang      o Created.
 *   11-24-2004    Rajib Ranjan Borah  o SSM SST Integration and Extension.
 *                                       User Overwrite rule and Third Party Rule
 *                                       are orig_system specific. No default
 *                                       records will be created in these tables
 *                                       and records with overwrite_flag = 'N' will
 *                                       not be stored.
 *
 */

PROCEDURE db_InsertEntityAttribute (
    p_entity_attribute_rec                  IN     ENTITY_ATTRIBUTE_REC_TYPE,
    p_group_name                            IN     VARCHAR2,
    x_entity_attr_id                        OUT    NOCOPY NUMBER
) IS
/*
    CURSOR c_user_overwrite_rule IS
      SELECT UNIQUE rule_id
      FROM hz_user_overwrite_rules;

    i_rule_id                               INDEXIDList;

    CURSOR c_third_party_rule IS
      SELECT 'Y'
      FROM hz_thirdparty_rule
      WHERE ROWNUM = 1;

    l_dummy                                 VARCHAR2(1);
*/
    l_debug_prefix                          VARCHAR2(30) := '';

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'db_InsertEntityAttribute (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    INSERT INTO hz_entity_attributes (
        entity_attr_id,
        entity_name,
        attribute_name,
        attribute_group_name,
        created_by_module,
        application_id,
        created_by,
        creation_date,
        last_update_login,
        last_update_date,
        last_updated_by
    ) VALUES (
        --
        -- entity_attr_id
        hz_entity_attributes_s.NEXTVAL,
        DECODE(p_entity_attribute_rec.entity_name,
               FND_API.G_MISS_CHAR, NULL, p_entity_attribute_rec.entity_name),
        DECODE(p_entity_attribute_rec.attribute_name,
               FND_API.G_MISS_CHAR, NULL, p_entity_attribute_rec.attribute_name),
        p_group_name,
        DECODE(p_entity_attribute_rec.created_by_module,
               FND_API.G_MISS_CHAR, NULL, p_entity_attribute_rec.created_by_module),
        DECODE(p_entity_attribute_rec.application_id,
               FND_API.G_MISS_NUM, NULL, p_entity_attribute_rec.application_id),
        hz_utility_v2pub.created_by,
        SYSDATE,
        hz_utility_v2pub.last_update_login,
        SYSDATE,
        hz_utility_v2pub.last_updated_by )
    RETURNING entity_attr_id INTO x_entity_attr_id;

/*
    OPEN c_user_overwrite_rule;
    FETCH c_user_overwrite_rule BULK COLLECT INTO i_rule_id;
    CLOSE c_user_overwrite_rule;

    FORALL i IN 1..i_rule_id.COUNT
      INSERT INTO hz_user_overwrite_rules (
          rule_id,
          entity_attr_id,
          overwrite_flag,
          created_by,
          creation_date,
          last_update_login,
          last_update_date,
          last_updated_by
      ) VALUES (
          i_rule_id(i),
          x_entity_attr_id,
          -- by default, user can overwrite third party data.
          'Y',
          hz_utility_v2pub.created_by,
          SYSDATE,
          hz_utility_v2pub.last_update_login,
          SYSDATE,
          hz_utility_v2pub.last_updated_by );
*/
/*
    OPEN c_third_party_rule;
    FETCH c_third_party_rule INTO l_dummy;
    IF c_third_party_rule%NOTFOUND THEN
      l_dummy := 'N';
    END IF;
    CLOSE c_third_party_rule;

    IF l_dummy = 'Y' THEN
      INSERT INTO hz_thirdparty_rule (
          entity_attr_id,
          overwrite_flag,
          created_by,
          creation_date,
          last_update_login,
          last_update_date,
          last_updated_by
      )
      VALUES (
          x_entity_attr_id,
          -- by default, third party can not overwrite user data.
          'N',
          hz_utility_v2pub.created_by,
          SYSDATE,
          hz_utility_v2pub.last_update_login,
          SYSDATE,
          hz_utility_v2pub.last_updated_by
      );
    END IF;
*/
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'db_InsertEntityAttribute (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END db_InsertEntityAttribute;

/**
 * PRIVATE PROCEDURE db_InsertDataSource
 *
 * DESCRIPTION
 *     Private procedure to insert data source setup into the table.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_attr_id               Dictionary ID.
 *     p_data_source_tab              PL/SQL table for data source setup.
 *   IN/OUT:
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   02-12-2002    Jianying Huang      o Created.
 *   12-12-2004    Rajib Ranjan Borah  o SSM SST Integration and Extension.
 *                                       If p_new_item_flag = 'O'(i.e. other entity),
 *                                       set ranking to 1.
 *
 */

PROCEDURE db_InsertDataSource (
    p_new_item_flag                         IN     VARCHAR2,
    p_entity_attr_id                        IN     NUMBER,
    p_data_source_tab                       IN     DATA_SOURCE_TBL
) IS
l_debug_prefix                      VARCHAR2(30) := '';
BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'db_InsertDataSource (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    FORALL i IN 1..p_data_source_tab.COUNT
      INSERT INTO hz_select_data_sources (
          entity_attr_id,
          content_source_type,
          ranking,
          created_by,
          creation_date,
          last_update_login,
          last_update_date,
          last_updated_by
      )
      SELECT
          p_entity_attr_id,
          p_data_source_tab(i),
          --
          -- ranking
          DECODE(p_new_item_flag,
                 'Y', DECODE(p_data_source_tab(i), 'USER_ENTERED', 1, 0),
                 'O',1, -- For other entities.
                 0),
          hz_utility_v2pub.created_by,
          SYSDATE,
          hz_utility_v2pub.last_update_login,
          SYSDATE,
          hz_utility_v2pub.last_updated_by
      FROM dual
      WHERE NOT EXISTS (
        SELECT 'Y'
        FROM hz_select_data_sources source2
        WHERE source2.entity_attr_id = p_entity_attr_id
        AND source2.content_source_type = p_data_source_tab(i));

    -- Debug info.

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'db_InsertDataSource (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END db_InsertDataSource;

--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE Add_EntityAttribute
 *
 * DESCRIPTION
 *     Add the new entity and / or attribute into the dictionary.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_entity_attribute_rec         Entity Attribute record.
 *     p_data_source_tbl              PL/SQL Table for Data Source Setup.
 *   IN/OUT:
 *   OUT:
 *     x_entity_attr_id               Dictionary ID.
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
 *   02-12-2002    Jianying Huang      o Created.
 */

PROCEDURE Add_EntityAttribute (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_entity_attribute_rec                  IN     ENTITY_ATTRIBUTE_REC_TYPE,
    p_data_source_tab                       IN     DATA_SOURCE_TBL,
    x_entity_attr_id                        OUT    NOCOPY NUMBER,
    x_return_status                         OUT    NOCOPY VARCHAR2,
    x_msg_count                             OUT    NOCOPY NUMBER,
    x_msg_data                              OUT    NOCOPY VARCHAR2
) IS
l_debug_prefix                      VARCHAR2(30) := '';
BEGIN

    -- Standard start of API savepoint
    SAVEPOINT Add_EntityAttribute;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Add_EntityAttribute (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_Boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call business logic.
    do_AddEntityAttribute (
        p_entity_attribute_rec,
        p_data_source_tab,
        x_entity_attr_id,
        x_return_status );

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data );

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Add_EntityAttribute (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Add_EntityAttribute;
        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Add_EntityAttribute (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Add_EntityAttribute;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        fnd_msg_pub.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Add_EntityAttribute (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO Add_EntityAttribute;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
        fnd_message.set_token('ERROR',SQLERRM);
        fnd_msg_pub.add;

        fnd_msg_pub.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Add_EntityAttribute (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END Add_EntityAttribute;

/**
 * PROCEDURE Get_EntityAttribute
 *
 * DESCRIPTION
 *     Get the entity / attribute from the dictionary.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_entity_name                  Entity Name
 *     p_attribute_name               Attribute Name
 *   IN/OUT:
 *   OUT:
 *     x_data_source_tbl              PL/SQL Table for Data Source Setup.
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
 *   02-12-2002    Jianying Huang      o Created.
 */

PROCEDURE Get_EntityAttribute (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_entity_name                           IN     VARCHAR2,
    p_attribute_name                        IN     VARCHAR2,
    x_data_source_tbl                       OUT    NOCOPY DATA_SOURCE_TBL,
    x_return_status                         OUT    NOCOPY VARCHAR2,
    x_msg_count                             OUT    NOCOPY NUMBER,
    x_msg_data                              OUT    NOCOPY VARCHAR2
) IS

    l_entity_attr_id                        NUMBER;
    l_data_source_tbl                       DATA_SOURCE_TBL;
    l_debug_prefix                          VARCHAR2(30) := '';

    CURSOR c_entity IS
        SELECT entity_attr_id
        FROM hz_entity_attributes
        WHERE entity_name = p_entity_name
        AND ((attribute_name IS NULL AND
              (p_attribute_name IS NULL OR
               p_attribute_name = FND_API.G_MISS_CHAR)) OR
             (attribute_name = p_attribute_name));

    CURSOR c_data_sources (
        p_entity_attr_id     NUMBER
    ) IS
        SELECT content_source_type
        FROM hz_select_data_sources
        WHERE entity_attr_id = p_entity_attr_id;

BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Get_EntityAttribute (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_Boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- find the entity and / or attribute in the dictionary
    OPEN c_entity;
    FETCH c_entity INTO l_entity_attr_id;

    IF c_entity%NOTFOUND THEN
      fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
      fnd_message.set_token('RECORD', 'entity attribute');
      fnd_message.set_token('VALUE', '<'||p_entity_name||','||
                            NVL(p_attribute_name,'null'||'>'));
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_entity;

    -- select data sources.
    OPEN c_data_sources(l_entity_attr_id);
    FETCH c_data_sources BULK COLLECT INTO l_data_source_tbl;
    CLOSE c_data_sources;

    x_data_source_tbl := l_data_source_tbl;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data );

    -- Debug info.

    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Get_EntityAttribute (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Get_EntityAttribute (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;


        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        fnd_msg_pub.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Get_EntityAttribute (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
        fnd_message.set_token('ERROR',SQLERRM);
        fnd_msg_pub.add;

        fnd_msg_pub.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=> 'Get_EntityAttribute (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END Get_EntityAttribute;

/**
 * PROCEDURE Remove_EntityAttribute
 *
 * DESCRIPTION
 *     Remove the entity / attribute from the dictionary.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_entity_name                  Entity Name
 *     p_attribute_name               Attribute Name
 *   IN/OUT:
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
 *   02-12-2002    Jianying Huang      o Created.
 */

PROCEDURE Remove_EntityAttribute (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_entity_name                           IN     VARCHAR2,
    p_attribute_name                        IN     VARCHAR2,
    x_return_status                         OUT    NOCOPY VARCHAR2,
    x_msg_count                             OUT    NOCOPY NUMBER,
    x_msg_data                              OUT    NOCOPY VARCHAR2
) IS

    l_entity_attr_id                        NUMBER;
    l_dummy                                 VARCHAR2(1);
    l_group_name                            VARCHAR2(30);
    l_group                                 VARCHARList;
    l_group_id                              INDEXIDList;
    l_total                                 NUMBER := 1;
    l_debug_prefix                          VARCHAR2(30) := '';

    CURSOR c_entity IS
        SELECT entity_attr_id
        FROM hz_entity_attributes
        WHERE entity_name = p_entity_name
        AND ((attribute_name IS NULL AND
              (p_attribute_name IS NULL OR
               p_attribute_name = FND_API.G_MISS_CHAR)) OR
             (attribute_name = p_attribute_name));

    CURSOR c_selected_data_source (
        p_entity_attr_id     NUMBER
    ) IS
        SELECT 'Y'
        FROM hz_select_data_sources
        WHERE entity_attr_id = p_entity_attr_id
        AND ranking > 0
        AND content_source_type <> 'USER_ENTERED'
        AND ROWNUM = 1;

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT Remove_EntityAttribute;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Remove_EntityAttribute (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_Boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- find the entity and / or attribute in the dictionary
    OPEN c_entity;
    FETCH c_entity INTO l_entity_attr_id;

    IF c_entity%NOTFOUND THEN
      fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
      fnd_message.set_token('RECORD', 'entity attribute');
      fnd_message.set_token('VALUE', '<'||p_entity_name||','||
                            NVL(p_attribute_name,'null'||'>'));
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_entity;

    -- find the group the attribute belongs to

    IF p_attribute_name IS NOT NULL AND
       p_attribute_name <> FND_API.G_MISS_CHAR
    THEN
      Find_NameListInAGroup (
          p_entity_name           => p_entity_name,
          p_attribute_name        => p_attribute_name,
          x_group_name            => l_group_name,
          x_group                 => l_group,
          x_group_id              => l_group_id);
      l_total := l_group.COUNT;
    END IF;

    FOR i IN 1..l_total LOOP
      IF l_total > 1 THEN
        l_entity_attr_id := l_group_id(i);
      END IF;

      -- find the data source. delete the entity and / or attribute
      -- if there is no selected data source for it.

      OPEN c_selected_data_source(l_entity_attr_id);
      FETCH c_selected_data_source INTO l_dummy;

      IF c_selected_data_source%NOTFOUND THEN
        -- delete the data sources.
        DELETE hz_select_data_sources
        WHERE entity_attr_id = l_entity_attr_id;

        -- delete the entity and / or attribute.
        DELETE hz_entity_attributes
        WHERE entity_attr_id = l_entity_attr_id;

        -- delete corresponding rules
        DELETE hz_user_overwrite_rules
        WHERE entity_attr_id = l_entity_attr_id;

        DELETE hz_thirdparty_rule
        WHERE entity_attr_id = l_entity_attr_id;

      ELSE
        fnd_message.set_name('AR', 'HZ_API_CANNOT_DELETE_ENTITY');
        fnd_message.set_token('ENTITY_ATTRIBUTE', '<'||p_entity_name||','||
                              NVL(p_attribute_name,'null'||'>'));
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_selected_data_source;
    END LOOP;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data );

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Remove_EntityAttribute (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Remove_EntityAttribute;
        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Remove_EntityAttribute (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Remove_EntityAttribute;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        fnd_msg_pub.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Remove_EntityAttribute (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO Remove_EntityAttribute;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
        fnd_message.set_token('ERROR',SQLERRM);
        fnd_msg_pub.add;

        fnd_msg_pub.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Remove_EntityAttribute (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END Remove_EntityAttribute;

/**
 * PROCEDURE Remove_EntityAttrDataSource
 *
 * DESCRIPTION
 *     Remove the entity / attribute's data sources from the dictionary.
 *     The data sources must be un-selected.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_entity_name                  Entity Name
 *     p_attribute_name               Attribute Name
 *   IN/OUT:
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
 *   02-12-2002    Jianying Huang      o Created.
 */

PROCEDURE Remove_EntityAttrDataSource (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_entity_name                           IN     VARCHAR2,
    p_attribute_name                        IN     VARCHAR2,
    p_data_source_tbl                       IN     DATA_SOURCE_TBL,
    x_return_status                         OUT    NOCOPY VARCHAR2,
    x_msg_count                             OUT    NOCOPY NUMBER,
    x_msg_data                              OUT    NOCOPY VARCHAR2
) IS

    l_entity_attr_id                        NUMBER;
    l_dummy                                 VARCHAR2(1);
    l_group_name                            VARCHAR2(30);
    l_group                                 VARCHARList;
    l_group_id                              INDEXIDList;
    l_total                                 NUMBER := 1;

    CURSOR c_entity IS
        SELECT entity_attr_id
        FROM hz_entity_attributes
        WHERE entity_name = p_entity_name
        AND ((attribute_name IS NULL AND
              (p_attribute_name IS NULL OR
               p_attribute_name = FND_API.G_MISS_CHAR)) OR
             (attribute_name = p_attribute_name));

    CURSOR c_data_source (
        p_entity_attr_id    NUMBER,
        p_data_source       VARCHAR2
    ) IS
        SELECT 'Y'
        FROM hz_select_data_sources
        WHERE entity_attr_id = p_entity_attr_id
        AND content_source_type = p_data_source
        AND ranking > 0;

    i_entity_attr_id                        INDEXIDList;
    l_debug_prefix                          VARCHAR2(30) := '';

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT Remove_EntityAttrDataSource;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Remove_EntityAttrDataSource (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_Boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- find the entity and / or attribute in the dictionary
    OPEN c_entity;
    FETCH c_entity INTO l_entity_attr_id;

    IF c_entity%NOTFOUND THEN
      fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
      fnd_message.set_token('RECORD', 'entity attribute');
      fnd_message.set_token('VALUE', '<'||p_entity_name||','||
                            NVL(p_attribute_name,'null'||'>'));
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_entity;

    -- find the group the attribute belongs to

    IF p_attribute_name IS NOT NULL AND
       p_attribute_name <> FND_API.G_MISS_CHAR
    THEN
      Find_NameListInAGroup (
          p_entity_name           => p_entity_name,
          p_attribute_name        => p_attribute_name,
          x_group_name            => l_group_name,
          x_group                 => l_group,
          x_group_id              => l_group_id);
      l_total := l_group.COUNT;
    END IF;

    FOR i IN 1..l_total LOOP
      IF l_total > 1 THEN
        l_entity_attr_id := l_group_id(i);
      END IF;

      -- for each data source in the plsql table, delete it from dictionary
      -- if the data source has not been selected.

      FOR i IN 1..p_data_source_tbl.COUNT LOOP
        OPEN c_data_source(l_entity_attr_id, p_data_source_tbl(i));
        FETCH c_data_source INTO l_dummy;

        IF c_data_source%NOTFOUND THEN
          -- delete the data sources.
          DELETE hz_select_data_sources
          WHERE entity_attr_id = l_entity_attr_id
          AND content_source_type = p_data_source_tbl(i);
        ELSE
          fnd_message.set_name('AR', 'HZ_CANNOT_DELETE_ENTITY_SOURCE');
          fnd_message.set_token('ENTITY_ATTRIBUTE', '<'||p_entity_name||','||
                                NVL(p_attribute_name,'null'||'>'));
          fnd_message.set_token('SOURCE', p_data_source_tbl(i));
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE c_data_source;
      END LOOP;

      -- delete the entity and / or attribute if there is no selected data
      -- source for it.

      DELETE hz_entity_attributes
      WHERE entity_attr_id = l_entity_attr_id
      AND NOT EXISTS (
        SELECT 'Y'
        FROM hz_select_data_sources
        WHERE entity_attr_id = l_entity_attr_id)
      RETURNING entity_attr_id BULK COLLECT INTO i_entity_attr_id;

      -- delete corresponding rules
      FORALL i IN 1..i_entity_attr_id.COUNT
        DELETE hz_user_overwrite_rules
        WHERE entity_attr_id = i_entity_attr_id(i);

      FORALL i IN 1..i_entity_attr_id.COUNT
        DELETE hz_thirdparty_rule
        WHERE entity_attr_id = i_entity_attr_id(i);

    END LOOP;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data );

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Remove_EntityAttrDataSource (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Remove_EntityAttrDataSource;
        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Remove_EntityAttrDataSource (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Remove_EntityAttrDataSource;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        fnd_msg_pub.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Remove_EntityAttrDataSource (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO Remove_EntityAttrDataSource;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
        fnd_message.set_token('ERROR',SQLERRM);
        fnd_msg_pub.add;

        fnd_msg_pub.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Remove_EntityAttrDataSource (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END Remove_EntityAttrDataSource;

END HZ_MIXNM_REGISTRY_PUB;

/

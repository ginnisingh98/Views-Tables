--------------------------------------------------------
--  DDL for Package Body HZ_MIXNM_WEBUI_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MIXNM_WEBUI_UTILITY" AS
/*$Header: ARHXWUTB.pls 120.3 2005/01/20 16:05:40 dmmehta noship $ */

--------------------------------------
-- private global constants
--------------------------------------

-- rule type

G_USER_CREATE_RULE_TYPE                CONSTANT VARCHAR2(30) := 'USER_CREATE_RULE';
G_USER_OVERWRITE_RULE_TYPE             CONSTANT VARCHAR2(30) := 'USER_OVERWRITE_RULE';

G_ATTRIBUTE_GROUP_NAME_TAB             VARCHARList;
G_ATTRIBUTE_GROUP_ISTART_TAB           IDList;
G_ATTRIBUTE_GROUP_IEND_TAB             IDList;
G_ATTRIBUTE_GROUP_ID_TAB               IDList;
G_ATTRIBUTE_GROUP_LOADED               VARCHAR2(1) := 'N';

--------------------------------------
-- private procedures and functions
--------------------------------------

/**
 * PRIVATE FUNCTION Get_Index
 *
 * DESCRIPTION
 *    Linear search on a given list for given value. Return the
 *    l_index if the value is in the list. Otherwise, return 0.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_list                       VARCHAR2 list.
 *     p_value                      Value wants to search for.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

FUNCTION Get_Index (
    p_list                             IN     VARCHARList,
    p_value                            IN     VARCHAR2
) RETURN NUMBER IS
BEGIN

    FOR i IN 1..p_list.COUNT LOOP
      IF p_value = p_list(i) THEN
        RETURN i;
      END IF;
    END LOOP;
    RETURN 0;

END Get_Index;

/**
 * PRIVATE PROCEDURE Load_Group
 *
 * DESCRIPTION
 *    Load attribute grouping
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Load_Group (p_entity IN VARCHAR2) IS

    CURSOR c_group IS
      SELECT attribute_group_name, entity_attr_id
      FROM hz_entity_attributes
      WHERE attribute_name IS NOT NULL
      AND entity_name = p_entity
      ORDER BY attribute_group_name;

    l_group                            VARCHARList;
    l_group_id                         IDList;
    j                                  NUMBER := 1;
    total                              NUMBER := 0;

BEGIN

    IF G_ATTRIBUTE_GROUP_LOADED = 'Y' THEN
      RETURN;
    END IF;

    OPEN c_group;
    FETCH c_group BULK COLLECT INTO l_group, G_ATTRIBUTE_GROUP_ID_TAB;
    CLOSE c_group;

    FOR i IN 1..l_group.COUNT+1 LOOP
      IF i = l_group.COUNT+1 OR
         (i > 1 AND
          l_group(i-1) <> l_group(i))
      THEN
        IF total > 1 THEN
          G_ATTRIBUTE_GROUP_NAME_TAB(j) := l_group(i-1);
          G_ATTRIBUTE_GROUP_ISTART_TAB(j) := i-total;
          G_ATTRIBUTE_GROUP_IEND_TAB(j) := i-1;
          j := j + 1;
        END IF;

        IF i = l_group.COUNT+1 THEN
          EXIT;
        END IF;

        total := 0;
      END IF;
      total := total + 1;
    END LOOP;

    IF (p_entity = 'HZ_ORGANIZATION_PROFILES') THEN
	G_ATTRIBUTE_GROUP_LOADED := 'O';
    ELSIF (p_entity = 'HZ_PERSON_PROFILES') THEN
    	G_ATTRIBUTE_GROUP_LOADED := 'P';
    END IF;

END Load_Group;

/**
 * PROCEDURE Get_NameListInAGroup
 *
 * DESCRIPTION
 *     Return the attribute list in a given group.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_group_name                   Group name.
 *   OUT:
 *     x_group_id                     Attribute id list in a group.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE Get_NameListInAGroup (
    p_group_name                       IN     VARCHAR2,
    x_group_id                         OUT    NOCOPY IDList,
    p_entity_attr_id			IN NUMBER
) IS

    l_index                            NUMBER;
    j                                  NUMBER := 1;
    l_entity VARCHAR2(30);

CURSOR entity_name IS
	SELECT entity_name
	FROM hz_entity_attributes
	WHERE entity_attr_id = p_entity_attr_id;

BEGIN

    OPEN entity_name;
    FETCH entity_name into l_entity;
    CLOSE entity_name;

    IF G_ATTRIBUTE_GROUP_LOADED = 'N' THEN
      Load_Group(l_entity);
    ELSIF (l_entity = 'HZ_ORGANIZATION_PROFILES' and G_ATTRIBUTE_GROUP_LOADED <> 'O') THEN
      Load_Group(l_entity);
    ELSIF (l_entity = 'HZ_PERSON_PROFILES' and G_ATTRIBUTE_GROUP_LOADED <> 'P') THEN
      Load_Group(l_entity);
    END IF;

    IF p_group_name IS NULL THEN
      RETURN;
    END IF;

    l_index := Get_Index(G_ATTRIBUTE_GROUP_NAME_TAB, p_group_name);
    IF  l_index > 0 THEN
      FOR i IN G_ATTRIBUTE_GROUP_ISTART_TAB(l_index)..G_ATTRIBUTE_GROUP_IEND_TAB(l_index) LOOP
        x_group_id(j) := G_ATTRIBUTE_GROUP_ID_TAB(i);
        j := j + 1;
      END LOOP;
    END IF;

END Get_NameListInAGroup;

/**
 * PRIVATE PROCEDURE Process_Group
 *
 * DESCRIPTION
 *    Processing attribute group.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_attr_id_tab         Entity / attribute id list.
 *     p_attribute_group_name_tab   A list of attribute group name.
 *     p_flag_tab                   A list of creation / overwrite flags for each
 *                                  entity / attribute.
 *   OUT:
 *     x_entity_attr_id_tab         Entity / attribute id list.
 *     x_flag_tab                   A list of creation / overwrite flags for each
 *                                  entity / attribute.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Process_Group (
    p_entity_attr_id_tab               IN     IDList,
    p_attribute_group_name_tab         IN     VARCHARList,
    p_flag_tab                         IN     VARCHARList,
    p_os_tab                         IN     VARCHARList,
    x_entity_attr_id_tab               OUT    NOCOPY IDList,
    x_flag_tab                         OUT    NOCOPY VARCHARList,
    x_os_tab                         OUT    NOCOPY VARCHARList
) IS

    l_group_id                         IDList;
    l_entity_attr_id                   NUMBER;
    l_flag                             VARCHAR2(1);
    l_start                            NUMBER;
    k                                  NUMBER := 1;
    l_os			       VARCHAR2(30);

BEGIN

    x_entity_attr_id_tab := p_entity_attr_id_tab;
    x_flag_tab := p_flag_tab;
    x_os_tab := p_os_tab;

    FOR i IN 1..p_attribute_group_name_tab.COUNT LOOP
      Get_NameListInAGroup (
        p_group_name                 => p_attribute_group_name_tab(i),
        x_group_id                   => l_group_id ,
	p_entity_attr_id	     => p_entity_attr_id_tab(i));

      IF l_group_id.COUNT <> 0 THEN
        l_entity_attr_id := p_entity_attr_id_tab(i);
        l_flag := p_flag_tab(i);
        l_start := x_entity_attr_id_tab.COUNT;
	l_os := p_os_tab(i);
        k := 1;

        FOR j IN 1..l_group_id.COUNT LOOP
          IF l_group_id(j) <> l_entity_attr_id THEN
            x_entity_attr_id_tab(l_start+k) := l_group_id(j);
            x_flag_tab(l_start+k) := l_flag;
	    x_os_tab(l_start+k) := l_os;
            k := k + 1;
          END IF;
        END LOOP;
      END IF;
    END LOOP;

END Process_Group;

/**
 * PRIVATE PROCEDURE Get_Group
 *
 * DESCRIPTION
 *    Get grouping info.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_attribute_group_name       Attribute group name.
 *   OUT:
 *     x_entity_attr_id_tab         Entity / attribute id list.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */
/*
PROCEDURE Get_Group (
    p_attribute_group_name             IN     VARCHAR2,
    x_entity_attr_id_tab               OUT    NOCOPY IDList
) IS

    l_group_id                         IDList;

BEGIN

    Get_NameListInAGroup (
      p_group_name                 => p_attribute_group_name,
      x_group_id                   => l_group_id );

    IF l_group_id.COUNT <> 0 THEN
      FOR i IN 1..l_group_id.COUNT LOOP
        x_entity_attr_id_tab(i) := l_group_id(i);
      END LOOP;
    END IF;

END Get_Group;
*/
/**
 * PRIVATE PROCEDURE Get_Group
 *
 * DESCRIPTION
 *    Get grouping info.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_attr_id_tab         Entity / attribute id list.
 *     p_attribute_group_name_tab   A list of attribute group name.
 *                                  entity / attribute.
 *   OUT:
 *     x_entity_attr_id_tab         Entity / attribute id list.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Get_Group (
    p_entity_attr_id_tab               IN     IDList,
    p_attribute_group_name_tab         IN     VARCHARList,
    x_entity_attr_id_tab               OUT    NOCOPY IDList
) IS

    l_group_id                         IDList;
    l_entity_attr_id                   NUMBER;
    l_start                            NUMBER;
    k                                  NUMBER := 1;

BEGIN

    x_entity_attr_id_tab := p_entity_attr_id_tab;

    FOR i IN 1..p_attribute_group_name_tab.COUNT LOOP
      Get_NameListInAGroup (
        p_group_name                 => p_attribute_group_name_tab(i),
        x_group_id                   => l_group_id,
	p_entity_attr_id	     => p_entity_attr_id_tab(i));

      IF l_group_id.COUNT <> 0 THEN
        l_entity_attr_id := p_entity_attr_id_tab(i);
        l_start := x_entity_attr_id_tab.COUNT;
        k := 1;

        FOR j IN 1..l_group_id.COUNT LOOP
          IF l_group_id(j) <> l_entity_attr_id THEN
            x_entity_attr_id_tab(l_start+k) := l_group_id(j);
            k := k + 1;
          END IF;
        END LOOP;
      END IF;
    END LOOP;

END Get_Group;

--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE Create_Rule
 *
 * DESCRIPTION
 *    Create an user creation / overwrite rule.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_rule_type                  Rule type. 'USER_CREATE_RULE' is for user create rule.
 *                                  'USER_OVERWRITE_RULE is for user overwrite rule.
 *     p_rule_name                  Rule name.
 *     p_entity_attr_id_tab         Entity / attribute id list.
 *     p_attribute_group_name_tab   A list of attribute group name.
 *     p_flag_tab                   A list of creation / overwrite flags for each
 *                                  entity / attribute.
 *   IN/OUT:
 *     p_rule_id                    Rule id.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Create_Rule (
    p_rule_type                        IN     VARCHAR2,
    p_rule_id                          IN OUT NOCOPY NUMBER,
    p_rule_name                        IN     VARCHAR2,
    p_entity_attr_id_tab               IN     IDList,
    p_attribute_group_name_tab         IN     VARCHARList,
    p_flag_tab                         IN     VARCHARList,
    p_os_tab                         IN     VARCHARList
) IS

    l_entity_attr_id_tab               IDList;
    l_flag_tab                         VARCHARList;
    l_os_tab                         VARCHARList;

BEGIN

    -- create a new rule if rule_id is not passed in.

    IF p_rule_id IS NULL THEN
      SELECT hz_ext_data_rules_tl_s.NEXTVAL
      INTO p_rule_id
      FROM DUAL;

      HZ_EXT_DATA_RULES_PKG.INSERT_ROW (
        p_rule_id, p_rule_type, p_rule_name );
    END IF;

    IF p_rule_type = G_USER_CREATE_RULE_TYPE THEN

      -- create user create rule.

      FORALL i IN 1..p_entity_attr_id_tab.COUNT
        INSERT INTO hz_user_create_rules (
          rule_id,
          entity_attr_id,
          creation_flag,
          created_by,
          creation_date,
          last_update_login,
          last_update_date,
          last_updated_by
        ) VALUES (
          p_rule_id,
          p_entity_attr_id_tab(i),
          p_flag_tab(i),
          hz_utility_v2pub.created_by,
          SYSDATE,
          hz_utility_v2pub.last_update_login,
          SYSDATE,
          hz_utility_v2pub.last_updated_by
        );

    ELSIF p_rule_type = G_USER_OVERWRITE_RULE_TYPE THEN

      -- process attribute group

      Process_Group (
        p_entity_attr_id_tab               => p_entity_attr_id_tab,
        p_attribute_group_name_tab         => p_attribute_group_name_tab,
        p_flag_tab                         => p_flag_tab,
	p_os_tab                           => p_os_tab,
        x_entity_attr_id_tab               => l_entity_attr_id_tab,
        x_flag_tab                         => l_flag_tab,
	x_os_tab                           => l_os_tab  );

      -- create user overwrite rule.

      FORALL i IN 1..l_entity_attr_id_tab.COUNT
        INSERT INTO hz_user_overwrite_rules (
          rule_id,
          entity_attr_id,
          overwrite_flag,
          created_by,
          creation_date,
          last_update_login,
          last_update_date,
          last_updated_by,
	  orig_system
        ) VALUES (
          p_rule_id,
          l_entity_attr_id_tab(i),
          l_flag_tab(i),
          hz_utility_v2pub.created_by,
          SYSDATE,
          hz_utility_v2pub.last_update_login,
          SYSDATE,
          hz_utility_v2pub.last_updated_by,
	  l_os_tab(i)
        );

    END IF;

END Create_Rule;

/**
 * PROCEDURE Update_Rule
 *
 * DESCRIPTION
 *    Update an user creation / overwrite rule.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_rule_type                  Rule type. 'USER_CREATE_RULE' is for user create rule.
 *                                  'USER_OVERWRITE_RULE is for user overwrite rule.
 *     p_rule_id                    Rule id.
 *     p_rule_name                  Rule name.
 *     p_entity_attr_id_tab         Entity / attribute id list.
 *     p_attribute_group_name_tab   A list of attribute group name.
 *     p_flag_tab                   A list of creation / overwrite flags for each
 *                                  entity / attribute.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Update_Rule (
    p_rule_type                        IN     VARCHAR2,
    p_rule_id                          IN     NUMBER,
    p_rule_name                        IN     VARCHAR2,
    p_entity_attr_id_tab               IN     IDList,
    p_attribute_group_name_tab         IN     VARCHARList,
    p_flag_tab                         IN     VARCHARList,
    p_os_tab                         IN     VARCHARList
) IS

    l_entity_attr_id_tab               IDList;
    l_flag_tab                         VARCHARList;
    l_os_tab                         VARCHARList;

BEGIN

    -- update an existing rule. Only rule name is updateable.

    IF p_rule_name IS NOT NULL THEN
      HZ_EXT_DATA_RULES_PKG.UPDATE_ROW (
        p_rule_id, p_rule_name );
    END IF;

    IF p_rule_type = G_USER_CREATE_RULE_TYPE THEN

      -- update user create rule.

      FORALL i IN 1..p_entity_attr_id_tab.COUNT
        UPDATE hz_user_create_rules
        SET creation_flag = p_flag_tab(i),
            last_update_login = hz_utility_v2pub.last_update_login,
            last_update_date = SYSDATE,
            last_updated_by = hz_utility_v2pub.last_updated_by
        WHERE rule_id = p_rule_id
	AND creation_flag <> p_flag_tab(i)
        AND entity_attr_id = p_entity_attr_id_tab(i);

    ELSIF p_rule_type = G_USER_OVERWRITE_RULE_TYPE THEN

      -- process attribute group
      Process_Group (
        p_entity_attr_id_tab               => p_entity_attr_id_tab,
        p_attribute_group_name_tab         => p_attribute_group_name_tab,
        p_flag_tab                         => p_flag_tab,
	p_os_tab                           => p_os_tab,
        x_entity_attr_id_tab               => l_entity_attr_id_tab,
        x_flag_tab                         => l_flag_tab,
	x_os_tab                           => l_os_tab  );

      -- update user overwrite rule.

      FOR i IN 1..l_entity_attr_id_tab.COUNT LOOP
        IF l_flag_tab(i) = 'N' THEN
            DELETE hz_user_overwrite_rules
            WHERE entity_attr_id = l_entity_attr_id_tab(i)
            AND orig_system = l_os_tab(i)
            AND rule_id = p_rule_id;

	    UPDATE hz_user_overwrite_rules
	    SET last_update_date = SYSDATE
            WHERE entity_attr_id = l_entity_attr_id_tab(i)
            AND rule_id = p_rule_id
	    AND ROWNUM = 1;

        ELSIF  l_flag_tab(i) = 'Y' THEN
          INSERT INTO hz_user_overwrite_rules (
          rule_id,
          entity_attr_id,
          overwrite_flag,
          created_by,
          creation_date,
          last_update_login,
          last_update_date,
          last_updated_by,
          orig_system
        ) VALUES (
          p_rule_id,
          l_entity_attr_id_tab(i),
          l_flag_tab(i),
          hz_utility_v2pub.created_by,
          SYSDATE,
          hz_utility_v2pub.last_update_login,
          SYSDATE,
          hz_utility_v2pub.last_updated_by,
          l_os_tab(i)
        );
        END IF;
      END LOOP;
/*
      FORALL i IN 1..l_entity_attr_id_tab.COUNT
        UPDATE hz_user_overwrite_rules
        SET overwrite_flag = l_flag_tab(i),
            last_update_login = hz_utility_v2pub.last_update_login,
            last_update_date = SYSDATE,
            last_updated_by = hz_utility_v2pub.last_updated_by
        WHERE rule_id = p_rule_id
        AND entity_attr_id = l_entity_attr_id_tab(i);
*/
    END IF;

END Update_Rule;

/**
 * PROCEDURE Copy_Rule
 *
 * DESCRIPTION
 *    Copy an user creation / overwrite rule.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_rule_type                  Rule type. 'USER_CREATE_RULE' is for user create rule.
 *                                  'USER_OVERWRITE_RULE is for user overwrite rule.
 *     p_rule_id                    Rule id.
 *     p_rule_name                  Rule name.
 *   OUT:
 *     x_new_rule_id                New rule id.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Copy_Rule (
    p_rule_type                        IN     VARCHAR2,
    p_rule_id                          IN     NUMBER,
    p_rule_name                        IN     VARCHAR2,
    x_new_rule_id                      OUT    NOCOPY NUMBER
) IS
BEGIN

    -- create a new rule.

    SELECT hz_ext_data_rules_tl_s.NEXTVAL
    INTO x_new_rule_id
    FROM DUAL;

    HZ_EXT_DATA_RULES_PKG.INSERT_ROW (
      x_new_rule_id, p_rule_type, p_rule_name );

    IF p_rule_type = G_USER_CREATE_RULE_TYPE THEN

      -- copy user create rule.

      INSERT INTO hz_user_create_rules (
        rule_id,
        entity_attr_id,
        creation_flag,
        created_by,
        creation_date,
        last_update_login,
        last_update_date,
        last_updated_by
      )
      SELECT
        x_new_rule_id,
        entity_attr_id,
        creation_flag,
        hz_utility_v2pub.created_by,
        SYSDATE,
        hz_utility_v2pub.last_update_login,
        SYSDATE,
        hz_utility_v2pub.last_updated_by
      FROM hz_user_create_rules
      WHERE rule_id = p_rule_id;

      INSERT INTO hz_user_overwrite_rules (
        rule_id,
        entity_attr_id,
        overwrite_flag,
        created_by,
        creation_date,
        last_update_login,
        last_update_date,
        last_updated_by,
        orig_system
      )
      SELECT
        x_new_rule_id,
        entity_attr_id,
        overwrite_flag,
        hz_utility_v2pub.created_by,
        SYSDATE,
        hz_utility_v2pub.last_update_login,
        SYSDATE,
        hz_utility_v2pub.last_updated_by,
        orig_system
      FROM hz_user_overwrite_rules
      WHERE rule_id = p_rule_id;


    ELSIF p_rule_type = G_USER_OVERWRITE_RULE_TYPE THEN

      -- copy user overwrite rule.

      INSERT INTO hz_user_overwrite_rules (
        rule_id,
        entity_attr_id,
        overwrite_flag,
        created_by,
        creation_date,
        last_update_login,
        last_update_date,
        last_updated_by,
	orig_system
      )
      SELECT
        x_new_rule_id,
        entity_attr_id,
        overwrite_flag,
        hz_utility_v2pub.created_by,
        SYSDATE,
        hz_utility_v2pub.last_update_login,
        SYSDATE,
        hz_utility_v2pub.last_updated_by,
	orig_system
      FROM hz_user_overwrite_rules
      WHERE rule_id = p_rule_id;

    END IF;

END Copy_Rule;

/**
 * PROCEDURE Delete_Rule
 *
 * DESCRIPTION
 *    Delete an user creation / overwrite rule.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_rule_type                  Rule type. 'USER_CREATE_RULE' is for user create rule.
 *                                  'USER_OVERWRITE_RULE is for user overwrite rule.
 *     p_rule_id                    Rule id.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Delete_Rule (
    p_rule_type                        IN     VARCHAR2,
    p_rule_id                          IN     NUMBER
) IS

    l_profile_option_name              VARCHAR(300);

BEGIN

    IF p_rule_type = G_USER_CREATE_RULE_TYPE THEN

      DELETE hz_user_create_rules
      WHERE rule_id = p_rule_id;

      DELETE hz_user_overwrite_rules
      WHERE rule_id = p_rule_id;

      l_profile_option_name := 'HZ_USER_DATA_CREATION_RULE';

    ELSIF p_rule_type = G_USER_OVERWRITE_RULE_TYPE THEN

      DELETE hz_user_overwrite_rules
      WHERE rule_id = p_rule_id;

      l_profile_option_name := 'HZ_USER_OVERWRITE_RULE';

    END IF;

    DELETE fnd_profile_option_values
    WHERE profile_option_id = (
      SELECT profile_option_id
      FROM fnd_profile_options
      WHERE profile_option_name = l_profile_option_name )
    AND profile_option_value = to_char(p_rule_id);

    -- delete the rule.

    HZ_EXT_DATA_RULES_PKG.DELETE_ROW(p_rule_id);

END Delete_Rule;

/**
 * PROCEDURE Update_ThirdPartyRule
 *
 * DESCRIPTION
 *    Update the third party rule.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_rule_exists                'Y'/'N' indicator to indicate if the rule
 *                                  for certain profile exists.
 *     p_entity_attr_id_tab         Entity / attribute id list.
 *     p_attribute_group_name_tab   A list of attribute group name.
 *     p_flag_tab                   A list of overwrite flags for each attribute.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Update_ThirdPartyRule (
    p_rule_exists                      IN     VARCHAR2,
    p_entity_attr_id_tab               IN     IDList,
    p_attribute_group_name_tab         IN     VARCHARList,
    p_flag_tab                         IN     VARCHARList,
    p_os_tab                         IN     VARCHARList
) IS

    l_entity_attr_id_tab               IDList;
    l_flag_tab                         VARCHARList;
    l_os_tab                         VARCHARList;

BEGIN

    -- process attribute group

    Process_Group (
      p_entity_attr_id_tab               => p_entity_attr_id_tab,
      p_attribute_group_name_tab         => p_attribute_group_name_tab,
      p_flag_tab                         => p_flag_tab,
      p_os_tab                           => p_os_tab,
      x_entity_attr_id_tab               => l_entity_attr_id_tab,
      x_flag_tab                         => l_flag_tab,
      x_os_tab                           => l_os_tab );

    IF p_rule_exists = 'N' THEN

      -- new rule. Insert.
      FORALL i IN 1..l_entity_attr_id_tab.COUNT
        INSERT INTO hz_thirdparty_rule (
          entity_attr_id,
          overwrite_flag,
          created_by,
          creation_date,
          last_update_login,
          last_update_date,
          last_updated_by,
	  orig_system
        )
        VALUES (
          l_entity_attr_id_tab(i),
          l_flag_tab(i),
          hz_utility_v2pub.created_by,
          SYSDATE,
          hz_utility_v2pub.last_update_login,
          SYSDATE,
          hz_utility_v2pub.last_updated_by,
	  l_os_tab(i)
        );

    ELSE

      -- old rule. Update.
      FOR i IN 1..l_entity_attr_id_tab.COUNT LOOP
	IF l_flag_tab(i) = 'N' THEN
	    DELETE hz_thirdparty_rule
	    WHERE entity_attr_id = l_entity_attr_id_tab(i)
	    AND orig_system = l_os_tab(i);
	ELSIF  l_flag_tab(i) = 'Y' THEN
	 INSERT INTO hz_thirdparty_rule (
          entity_attr_id,
          overwrite_flag,
          created_by,
          creation_date,
          last_update_login,
          last_update_date,
          last_updated_by,
          orig_system
        )
        VALUES (
          l_entity_attr_id_tab(i),
          l_flag_tab(i),
          hz_utility_v2pub.created_by,
          SYSDATE,
          hz_utility_v2pub.last_update_login,
          SYSDATE,
          hz_utility_v2pub.last_updated_by,
          l_os_tab(i)
        );
	END IF;
      END LOOP;
/*
        UPDATE hz_thirdparty_rule
        SET overwrite_flag = l_flag_tab(i),
            last_update_login = hz_utility_v2pub.last_update_login,
            last_update_date = SYSDATE,
            last_updated_by = hz_utility_v2pub.last_updated_by
        WHERE entity_attr_id = l_entity_attr_id_tab(i);
*/
    END IF;

END Update_ThirdPartyRule;

/**
 * PROCEDURE Set_DataSources
 *
 * DESCRIPTION
 *    Set the data sources for a list of attributes.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_attr_id_tab         Entity / attribute id list.
 *     p_attribute_group_name_tab   A list of attribute group name.
 *     p_range_tab                  The l_index range of each attribute.
 *     p_data_sources_tab           The list of data sources for each attributes.
 *     p_ranking_tab                The list of data sources ranking for each attributes.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Set_DataSources (
    p_entity_attr_id_tab               IN     IDList,
    p_attribute_group_name_tab         IN     VARCHARList,
    p_range_tab                        IN     IDList,
    p_data_sources_tab                 IN     VARCHARList,
    p_ranking_tab                      IN     IDList
) IS

    l_start                            NUMBER := 1;
    l_end                              NUMBER;
    l_entity_attr_id_tab               IDList;

BEGIN

    FOR i IN 1..p_entity_attr_id_tab.COUNT LOOP

      -- process attribute group

      Get_NameListInAGroup (
        p_group_name             => p_attribute_group_name_tab(i),
        x_group_id                   => l_entity_attr_id_tab,
	p_entity_attr_id	     => p_entity_attr_id_tab(i));

      IF l_entity_attr_id_tab.COUNT = 0 THEN
        l_entity_attr_id_tab(1) := p_entity_attr_id_tab(i);
      END IF;

      FOR j IN 1..l_entity_attr_id_tab.COUNT LOOP
        l_end := p_range_tab(i);

        -- set data sources and ranking.

        FOR k IN l_start..l_end LOOP
          UPDATE hz_select_data_sources
          SET ranking = p_ranking_tab(k),
              last_update_login = hz_utility_v2pub.last_update_login,
              last_update_date = SYSDATE,
              last_updated_by = hz_utility_v2pub.last_updated_by
          WHERE entity_attr_id = l_entity_attr_id_tab(j)
          AND content_source_type = p_data_sources_tab(k);
        END LOOP;

        -- mark the attribute as been updated.

        UPDATE hz_entity_attributes
        SET updated_flag = 'Y',
            last_update_login = hz_utility_v2pub.last_update_login,
            last_update_date = SYSDATE,
            last_updated_by = hz_utility_v2pub.last_updated_by
        WHERE entity_attr_id = l_entity_attr_id_tab(j);

      END LOOP;

      l_start := l_end + 1;
      l_entity_attr_id_tab.DELETE;
    END LOOP;

END Set_DataSources;

/**
 * PROCEDURE Get_DataSourcesForAGroup
 *
 * DESCRIPTION
 *    Get the data source setup for a group of attributes.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_type                Entity type.
 *     p_entity_attr_id_tab         Entity / attribute id list.
 *     x_has_same_setup             'Y'/'N' indicator for if the attributes have
 *                                  the same data source setup.
 *     x_data_sources_tab           The list of data sources meaning for all of the attributes.
 *     x_meaning_tab                The list of data sources for all of the attributes.
 *     x_ranking_tab                The list of data sources ranking for all of the attributes.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Get_DataSourcesForAGroup (
    p_entity_type                      IN     VARCHAR2,
    p_entity_attr_id_tab               IN     IDList,
    x_has_same_setup                   OUT    NOCOPY VARCHAR2,
    x_data_sources_tab                 OUT    NOCOPY VARCHARList,
    x_meaning_tab                      OUT    NOCOPY VARCHARList,
    x_ranking_tab                      OUT    NOCOPY IDList
) IS

    CURSOR c_common_data_sources (
      p_entity_attr_id              NUMBER
    ) IS
      SELECT s.content_source_type, s.ranking,
               o.orig_system_name meaning
      FROM hz_select_data_sources s, hz_orig_systems_vl o
      WHERE s.entity_attr_id = p_entity_attr_id
	and o.orig_system = s.content_source_type
      ORDER BY ranking;

    j                                       NUMBER;
    c                                       NUMBER;
    l_count                                 NUMBER;
    l_different                             VARCHAR2(1) := 'N';
    str                                     VARCHAR2(255);
    l_sql                                   VARCHAR2(1000);
    l_data_sources_old                      VARCHARList;
    l_meaning_old                           VARCHARList;
    l_data_sources_tab                      dbms_sql.Varchar2_Table;
    l_meaning_tab                           dbms_sql.Varchar2_Table;
    l_id_tab                                dbms_sql.Number_Table;

BEGIN

    -- find the data sources for all of the attributes in the given group.

    j := 0; str := '';
/*
    FOR i IN 1..p_entity_attr_id_tab.COUNT LOOP
      j := j + 1;   str := str||TO_CHAR(p_entity_attr_id_tab(i))||',';
      IF j = 15 OR i = p_entity_attr_id_tab.COUNT
      THEN
        BEGIN
          str := SUBSTR(str, 1, LENGTH(str)-1);

          l_sql := 'SELECT ''Y'' '||
                   'FROM ( '||
                   '  SELECT COUNT(*) total '||
                   '  FROM hz_select_data_sources '||
                   '  WHERE entity_attr_id IN ('||str||') '||
                   '  GROUP BY content_source_type';
          --IF p_entity_type = 'profile' THEN
          l_sql := l_sql||', ranking';
          --END IF;
          l_sql := l_sql||
                   ') '||
                   'WHERE total <> '||j||' '||
                   'AND ROWNUM = 1';
          EXECUTE IMMEDIATE l_sql INTO l_different;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_different := 'N';
        END;

        IF l_different = 'Y' THEN
          EXIT;
        END IF;

        j := 1; str := TO_CHAR(p_entity_attr_id_tab(i))||',';
      END IF;
    END LOOP;

    -- if the attributes have different setup, return all of them.

    IF l_different = 'Y' THEN
      j := 0; str := '';
      FOR i IN 1..p_entity_attr_id_tab.COUNT LOOP
        j := j + 1;   str := str||TO_CHAR(p_entity_attr_id_tab(i))||',';
        IF j = 15 OR i = p_entity_attr_id_tab.COUNT
        THEN
          str := SUBSTR(str, 1, LENGTH(str)-1);

          c := dbms_sql.open_cursor;
          l_sql := 'SELECT UNIQUE content_source_type,  '||
                   '       hz_utility_v2pub.Get_LookupMeaning( '||
                   '        ''AR_LOOKUPS'', ''CONTENT_SOURCE_TYPE'', '||
                   '        content_source_type ) meaning '||
                   'FROM hz_select_data_sources '||
                   'WHERE entity_attr_id IN ('||str||') ';
          dbms_sql.parse(c, l_sql, dbms_sql.native);
          dbms_sql.define_array(c, 1, l_data_sources_tab, 30, 1);
          dbms_sql.define_array(c, 2, l_meaning_tab, 30, 1);
          l_count := dbms_sql.execute(c);
          l_count := dbms_sql.fetch_rows(c);
          dbms_sql.column_value(c, 1, l_data_sources_tab);
          dbms_sql.column_value(c, 2, l_meaning_tab);
          dbms_sql.close_cursor(c);

          IF l_data_sources_old.COUNT = 0 THEN
            FOR i IN 1..l_data_sources_tab.COUNT LOOP
              l_data_sources_old(i) := l_data_sources_tab(i);
              l_meaning_old(i) := l_meaning_tab(i);
            END LOOP;
          ELSE
            FOR k IN 1..l_data_sources_tab.COUNT LOOP
              IF Get_Index(l_data_sources_old, l_data_sources_tab(k)) = 0 THEN
                l_data_sources_old(l_data_sources_old.COUNT+1) := l_data_sources_tab(k);
                l_meaning_old(l_data_sources_old.COUNT+1) := l_meaning_tab(k);
              END IF;
            END LOOP;
          END IF;

          j := 1; str := TO_CHAR(p_entity_attr_id_tab(i))||',';
        END IF;

      END LOOP;

      x_data_sources_tab := l_data_sources_old;
      x_meaning_tab := l_meaning_old;
      x_has_same_setup := 'N';

    ELSE
*/
      -- if attributes have the same setup, we can use the setup of one attribute.

      OPEN c_common_data_sources(p_entity_attr_id_tab(1));
      FETCH c_common_data_sources BULK COLLECT INTO
        x_data_sources_tab, x_ranking_tab, x_meaning_tab;
      CLOSE c_common_data_sources;
 --   END IF;
if p_entity_attr_id_tab.COUNT > 1 then
      x_has_same_setup := 'N';
else
      x_has_same_setup := 'Y';
end if;

END Get_DataSourcesForAGroup;

/**
 * PROCEDURE Set_DataSourcesForAGroup
 *
 * DESCRIPTION
 *    Set the data sources for a list of attributes.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_attr_id_tab         Entity / attribute id list.
 *     p_attribute_group_name_tab   A list of attribute group name.
 *     p_data_sources_tab           The list of data sources for each attributes.
 *     p_ranking_tab                The list of data sources ranking for each attributes.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Set_DataSourcesForAGroup (
    p_entity_attr_id_tab               IN     IDList,
    p_attribute_group_name_tab         IN     VARCHARList,
    p_data_sources_tab                 IN     VARCHARList,
    p_ranking_tab                      IN     IDList
) IS

    l_entity_attr_id_tab               IDList;

BEGIN

    -- process attribute group

    Get_Group (
      p_entity_attr_id_tab               => p_entity_attr_id_tab,
      p_attribute_group_name_tab         => p_attribute_group_name_tab,
      x_entity_attr_id_tab               => l_entity_attr_id_tab );

    FOR i IN 1..l_entity_attr_id_tab.COUNT LOOP

      -- set the data source for all of the attributes in the given group.

      FORALL j IN 1..p_data_sources_tab.COUNT
        UPDATE hz_select_data_sources
        SET ranking = p_ranking_tab(j),
            last_update_login = hz_utility_v2pub.last_update_login,
            last_update_date = SYSDATE,
            last_updated_by = hz_utility_v2pub.last_updated_by
        WHERE entity_attr_id = l_entity_attr_id_tab(i)
        AND content_source_type = p_data_sources_tab(j);

      -- mark the attribute as been updated.

      UPDATE hz_entity_attributes
      SET updated_flag = 'Y',
          last_update_login = hz_utility_v2pub.last_update_login,
          last_update_date = SYSDATE,
          last_updated_by = hz_utility_v2pub.last_updated_by
      WHERE entity_attr_id = l_entity_attr_id_tab(i);

    END LOOP;

END Set_DataSourcesForAGroup;

END HZ_MIXNM_WEBUI_UTILITY;

/

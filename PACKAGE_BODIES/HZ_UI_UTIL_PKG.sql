--------------------------------------------------------
--  DDL for Package Body HZ_UI_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_UI_UTIL_PKG" AS
/* $Header: ARHPUISB.pls 120.19 2006/05/24 13:28:17 idali noship $ */

-------------------------------------
-- CHECK_ENTITY_CREATION - Signature
-------------------------------------

PROCEDURE check_entity_creation (
   p_entity_name        IN VARCHAR2,  -- table name
   p_data_source        IN VARCHAR2,  -- if applicable
   p_party_id           IN NUMBER,    -- only pass if available
   p_parent_entity_name IN VARCHAR2,  -- if applicable
   p_parent_entity_pk1  IN VARCHAR2,  -- if applicable
   p_parent_entity_pk2  IN VARCHAR2,  -- if applicable
   p_function_name      IN VARCHAR2,  -- FND function name
   x_create_flag        OUT NOCOPY VARCHAR2  -- can we create?
) IS
  l_entity_attr_id NUMBER;
  l_return_status  VARCHAR2(1);
BEGIN

  /*
   *  Call the Third Party Data Integration routine to see if the user can
   *  create instances of the entity.
   */

  IF p_entity_name IN ('HZ_ORGANIZATION_PROFILES','HZ_PERSON_PROFILES') THEN
    x_create_flag := 'Y';
  ELSE
    HZ_MIXNM_UTILITY.CheckUserCreationPrivilege(
      p_entity_name           => p_entity_name,
      p_entity_attr_id        => l_entity_attr_id,
      p_mixnmatch_enabled     => NULL,
      p_actual_content_source => 'USER_ENTERED',
      x_return_status         => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      x_create_flag := 'N';
    ELSE
      x_create_flag := 'Y';
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_create_flag := 'N';
END check_entity_creation;

-------------------------------------
-- GET_VIEW_PREDICATE
-------------------------------------

FUNCTION get_view_predicate (
  p_entity_name       IN VARCHAR2,  -- entity/table you wish to filter
  p_entity_alias      IN VARCHAR2,  -- alias for entity as used in SELECT
  p_function_name     IN VARCHAR2   -- FND function name
) RETURN VARCHAR2
IS
  l_alias  VARCHAR2(30);
BEGIN

  IF p_entity_name = 'HZ_PARTIES' THEN
    IF p_entity_alias IS NOT NULL THEN
      l_alias := p_entity_alias;
    ELSE
      l_alias := p_entity_name;
    END IF;

    RETURN ' (' || l_alias || '.' || 'ORIG_SYSTEM_REF NOT LIKE ''PER%'') ';

  ELSE
    RETURN ' (1=1) ';
  END IF;
END get_view_predicate;


-------------------------------------
-- CHECK_ROW_ACCESS
-------------------------------------

/*
PROCEDURE check_row_access (
   p_entity_name      IN VARCHAR2,               -- table name
   p_data_source      IN VARCHAR2 DEFAULT NULL,  -- if applicable
   p_entity_pk1       IN VARCHAR2,               -- primary key
   p_entity_pk2       IN VARCHAR2 DEFAULT NULL,  -- primary key pt. 2
   p_party_id         IN NUMBER   DEFAULT NULL,  -- only pass if available
   x_viewable_flag    OUT NOCOPY VARCHAR2,       -- can we see it?
   x_updateable_flag  OUT NOCOPY VARCHAR2,       -- can we mess with it?
   x_deleteable_flag  OUT NOCOPY VARCHAR2        -- can we get rid of it?
) IS
BEGIN

  --
  -- This is for those cases where the caller wants to check all the access
  -- at once.  Merely a wrapper for the individual operation-level checks.
  --

  -- Check view access

  x_viewable_flag := check_row_viewable (
     p_entity_name      => p_entity_name,
     p_data_source      => p_data_source,
     p_entity_pk1       => p_entity_pk1,
     p_entity_pk2       => p_entity_pk2,
     p_party_id         => p_party_id
  );

  -- Check update access

  x_updateable_flag := check_row_updateable (
     p_entity_name      => p_entity_name,
     p_data_source      => p_data_source,
     p_entity_pk1       => p_entity_pk1,
     p_entity_pk2       => p_entity_pk2,
     p_party_id         => p_party_id
  );

  -- Check delete access

  x_deleteable_flag := check_row_deleteable (
     p_entity_name      => p_entity_name,
     p_data_source      => p_data_source,
     p_entity_pk1       => p_entity_pk1,
     p_entity_pk2       => p_entity_pk2,
     p_party_id         => p_party_id
  );

END check_row_access;
*/

-- "Pure" Function versions, that can be used directly in SELECT statements

FUNCTION check_row_viewable (
   p_entity_name      IN VARCHAR2, -- table name
   p_data_source      IN VARCHAR2, -- if applicable
   p_entity_pk1       IN VARCHAR2, -- primary key
   p_entity_pk2       IN VARCHAR2, -- primary key pt. 2
   p_party_id         IN NUMBER,   -- only pass if available
   p_function_name    IN VARCHAR2  -- FND function name
) RETURN VARCHAR2  -- "Y" or "N" if we can view the row
IS
  l_viewable_flag   VARCHAR2(1);
  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
BEGIN
  /*
   *  Call the Data Sharing and Security API to check DSS security rules.
   *  The DSS function returns "T" or "F".
   */

  l_viewable_flag := HZ_DSS_UTIL_PUB.TEST_INSTANCE (
    p_operation_code       => 'SELECT',
    p_db_object_name       => p_entity_name,
    p_instance_pk1_value   => p_entity_pk1,
    p_instance_pk2_value   => p_entity_pk2,
    x_return_status        => l_return_status,
    x_msg_count            => l_msg_count,
    x_msg_data             => l_msg_data
  );

  -- Default security to N if API fails
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    l_viewable_flag := 'N';
  ELSIF l_viewable_flag = 'T' THEN -- Will return FND_API.G_TRUE from HZ_DSS_UTIL_PUB
    l_viewable_flag := 'Y';
  ELSE
    l_viewable_flag := 'N';
  END IF;

  RETURN l_viewable_flag;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END check_row_viewable;




FUNCTION check_row_updateable (
   p_entity_name      IN VARCHAR2, -- table name
   p_data_source      IN VARCHAR2, -- if applicable
   p_entity_pk1       IN VARCHAR2, -- primary key
   p_entity_pk2       IN VARCHAR2, -- primary key pt. 2
   p_party_id         IN NUMBER,   -- only pass if available
   p_function_name    IN VARCHAR2  -- FND function name
) RETURN VARCHAR2  -- "Y" or "N" if we can update the row
IS
  l_updateable_flag VARCHAR2(1) := 'N';
  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
BEGIN
  /*
   *  Special code added to support MOSR update functionality BASED ON PROFILE
   */
  IF p_entity_name = 'HZ_ORIG_SYS_REFERENCES' THEN
    IF HZ_UTILITY_V2PUB.is_purchased_content_source(p_data_source) = 'Y' THEN
        l_updateable_flag := 'N';
    ELSE
       IF NVL(FND_PROFILE.value('HZ_SSM_VIEW_UPDATE_STATE'), 'VIEW_ONLY') = 'CREATE_AND_UPDATE' THEN
          l_updateable_flag := 'Y';
       END IF;
    END IF;
    return l_updateable_flag;
  END IF;

  /*
   *  Call the Data Sharing and Security API to check DSS security rules.
   *  The DSS function returns "T" or "F".
   */

  l_updateable_flag := HZ_DSS_UTIL_PUB.TEST_INSTANCE (
    p_operation_code       => 'UPDATE',
    p_db_object_name       => p_entity_name,
    p_instance_pk1_value   => p_entity_pk1,
    p_instance_pk2_value   => p_entity_pk2,
    p_user_name            => FND_GLOBAL.User_Name,
    x_return_status        => l_return_status,
    x_msg_count            => l_msg_count,
    x_msg_data             => l_msg_data
  );

  -- Default security to N if API fails
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    l_updateable_flag := 'N';
  ELSIF l_updateable_flag = 'T' THEN -- Will return FND_API.G_TRUE from HZ_DSS_UTIL_PUB
    l_updateable_flag := 'Y';
  ELSE
    l_updateable_flag := 'N';
  END IF;

  -- If DSS check fails,then no need to check any further security.

  IF l_updateable_flag = 'N' THEN
    RETURN l_updateable_flag;
  END IF;

  /*
   *  Call the Third Party Data Integration security rules.
   */
-- Bug 4203937 : check Mix-N-Match security only for
-- other entities supported by Mix-N-Match
/* Bug 4693719 : Do not call CheckUserUpdatePrivilege from CPUI
 * CPUI should display update enabled icon in the UI so that
 * primary_flag, start_date, status etc columns can be updated.
 * Error will be raised from API if the rules are violated
 *
If p_entity_name in ('HZ_RELATIONSHIPS', 'HZ_CODE_ASSIGNMENTS',
'HZ_CONTACT_POINTS', 'HZ_CREDIT_RATINGS', 'HZ_FINANCIAL_REPORTS',
'HZ_LOCATIONS', 'HZ_PARTY_SITES', 'HZ_FINANCIAL_NUMBERS') then

  HZ_MIXNM_UTILITY.CheckUserUpdatePrivilege (
    p_actual_content_source         => p_data_source,
    p_new_actual_content_source         => 'USER_ENTERED',
    p_entity_name =>  p_entity_name,
    x_return_status                 => l_return_status
  );

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    l_updateable_flag := 'N';
  ELSE
    l_updateable_flag := 'Y';
  END IF;
end if;
*/
  RETURN l_updateable_flag;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END check_row_updateable;



FUNCTION check_row_deleteable (
   p_entity_name      IN VARCHAR2,  -- table name
   p_data_source      IN VARCHAR2,  -- if applicable
   p_entity_pk1       IN VARCHAR2,  -- primary key
   p_entity_pk2       IN VARCHAR2,  -- primary key pt. 2
   p_party_id         IN NUMBER,    -- only pass if available
   p_function_name    IN VARCHAR2   -- FND function name
) RETURN VARCHAR2  -- "Y" or "N" if we can delete the row
IS
  l_deleteable_flag VARCHAR2(1) := 'N';
  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
BEGIN
  /*
   *  Special code added to support MOSR update functionality BASED ON PROFILE
   */
  IF p_entity_name = 'HZ_ORIG_SYS_REFERENCES' THEN
     IF NVL(FND_PROFILE.value('HZ_SSM_VIEW_UPDATE_STATE'), 'VIEW_ONLY') = 'CREATE_AND_UPDATE' THEN
         l_deleteable_flag := 'Y';
     END IF;
     return l_deleteable_flag;
  END IF;

  /*
   *  Call the Data Sharing and Security API to check DSS security rules.
   *  The DSS function returns "T" or "F".
   */

  l_deleteable_flag := HZ_DSS_UTIL_PUB.TEST_INSTANCE (
    p_operation_code       => 'DELETE',
    p_db_object_name       => p_entity_name,
    p_instance_pk1_value   => p_entity_pk1,
    p_instance_pk2_value   => p_entity_pk2,
    p_user_name            => FND_GLOBAL.User_Name,
    x_return_status        => l_return_status,
    x_msg_count            => l_msg_count,
    x_msg_data             => l_msg_data
  );

  -- Default security to N if API fails
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    l_deleteable_flag := 'N';
  ELSIF l_deleteable_flag = 'T' THEN -- Will return FND_API.G_TRUE from HZ_DSS_UTIL_PUB
    l_deleteable_flag := 'Y';
  ELSE
    l_deleteable_flag := 'N';
  END IF;

  RETURN l_deleteable_flag;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END check_row_deleteable;

-------------------------------------
-- CHECK_COLUMNS
-------------------------------------


PROCEDURE check_columns(
  p_entity_name     IN VARCHAR2, -- table name
  p_data_source     IN VARCHAR2, -- if applicable
  p_entity_pk1      IN VARCHAR2, -- primary key
  p_entity_pk2      IN VARCHAR2, -- primary key pt. 2
  p_party_id        IN NUMBER ,  -- only pass if available
  p_function_name   IN VARCHAR2, -- function name
  p_attribute_list  IN          HZ_MIXNM_UTILITY.INDEXVARCHAR30List, -- pl/sql table of attribute names
  p_value_is_null_list IN       HZ_MIXNM_UTILITY.INDEXVARCHAR1List,  -- pl/sql table of flags
  x_viewable_list   OUT NOCOPY  HZ_MIXNM_UTILITY.INDEXVARCHAR1List,  -- pl/sql table of flags
  x_updateable_list OUT NOCOPY  HZ_MIXNM_UTILITY.INDEXVARCHAR1List   -- pl/sql table of flags
) IS
  l_return_status VARCHAR2(1);
  i               NUMBER;
BEGIN

  /*
   * Call the Third Party Data Integration column checking routine.
   */

   HZ_MIXNM_UTILITY.areSSTColumnsUpdeable (
     p_party_id                 => p_party_id,
     p_entity_name              => p_entity_name,
     p_attribute_name_list      => p_attribute_list,
     p_value_is_null_list       => p_value_is_null_list,
     p_data_source_type         => p_data_source,
     x_updatable_flag_list      => x_updateable_list,
     x_return_status            => l_return_status
   );

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      FOR i IN p_attribute_list.FIRST .. p_attribute_list.LAST
      LOOP
        x_updateable_list(i) := 'N';
      END LOOP;
   END IF;

  /*
   * We do not currently have view security at the attribute level, so
   * all attributes are viewable.
   */

  FOR i IN p_attribute_list.FIRST .. p_attribute_list.LAST
  LOOP
    x_viewable_list(i) := 'Y';
  END LOOP;

END check_columns;

/**
 * PROCEDURE get_value
 *
 * DESCRIPTION
 *    used by common party UI .
 *    will return various value
 * ARGUMENTS
 *   IN:
 *     p_org_contact_id          org contact id. If passed in, will return
 *                               org contact roles.
 *     p_phone_country_code      phone country code
 *     p_phone_area_code         phone area_code
 *     p_phone_number            phone number. If passed in, will return
 *                               formatted phone number.
 *     p_phone_extension         phone extension.
 *     p_phone_line_type         phone_line_type
 *     p_location_id             location id. If passed in, will return
 *                               formatted address.
 *     p_cust_acct_id            Cust account ID, returns the formatted bill_to address
 *     p_cust_acct_site_id       Cust account site ID, returns the formatted bill_to address
 */

 PROCEDURE get_value (
     p_org_contact_id              IN     VARCHAR2,
     p_phone_country_code          IN     VARCHAR2,
     p_phone_area_code             IN     VARCHAR2,
     p_phone_number                IN     VARCHAR2,
     p_phone_extension             IN     VARCHAR2,
     p_phone_line_type             IN     VARCHAR2,
     p_location_id                 IN     VARCHAR2,
     x_org_contact_roles           OUT    NOCOPY VARCHAR2,
     x_formatted_phone             OUT    NOCOPY VARCHAR2,
     x_formatted_address           OUT    NOCOPY VARCHAR2,
     p_act_cont_role_id            IN     VARCHAR2,
     x_act_contact_roles           OUT    NOCOPY VARCHAR2,
     p_primary_phone_contact_pt_id IN     NUMBER,
     x_has_contact_restriction     OUT    NOCOPY VARCHAR2,
     p_relationship_type_id        IN     NUMBER,
     p_relationship_group_code     IN     VARCHAR2,
     x_is_in_relationship_group    OUT    NOCOPY VARCHAR2,
     p_cust_acct_id                IN     VARCHAR2,
     x_billto_address              OUT    NOCOPY VARCHAR2,
     p_cust_acct_site_id           IN     VARCHAR2
 ) IS

 BEGIN

     IF p_cust_acct_id IS NOT NULL  THEN
     BEGIN
      SELECT hz_format_pub.format_address ( hps.LOCATION_ID , null , null ,' , ' , null , null , null , null )
             INTO x_billto_address
             FROM HZ_PARTY_SITES hps , HZ_CUST_ACCT_SITES_ALL hcas
             WHERE hcas.BILL_TO_FLAG='P'
             AND hcas.CUST_ACCOUNT_ID = p_cust_acct_id
             AND hcas.PARTY_SITE_ID = hps.PARTY_SITE_ID;
      EXCEPTION
         WHEN OTHERS THEN
             x_billto_address:=NULL;
     END;
     END IF;

     IF p_org_contact_id IS NOT NULL THEN
       x_org_contact_roles := hz_utility_v2pub.get_org_contact_role(p_org_contact_id);
     END IF;

     IF p_phone_number IS NOT NULL THEN
       x_formatted_phone :=
         hz_format_phone_v2pub.get_formatted_phone (
           p_phone_country_code, p_phone_area_code, p_phone_number,
           p_phone_extension, p_phone_line_type);
     END IF;

     IF p_location_id IS NOT NULL THEN
       x_formatted_address :=
         hz_format_pub.format_address(p_location_id, null, null, ', ');
     END IF;

     IF p_act_cont_role_id IS NOT NULL THEN
       x_act_contact_roles := hz_act_util_pub.get_act_contact_roles(p_act_cont_role_id);
     END IF;

     IF p_primary_phone_contact_pt_id IS NOT NULL THEN
       x_has_contact_restriction :=
               hz_utility_v2pub.is_restriction_exist(
                      'HZ_CONTACT_POINTS',
                      p_primary_phone_contact_pt_id,
                      'DO_NOT');
     END IF;

     IF p_relationship_type_id IS NOT NULL AND
        p_relationship_group_code IS NOT NULL
     THEN
       x_is_in_relationship_group :=
               hz_utility_v2pub.is_role_in_relationship_group(
                      p_relationship_type_id,
                      p_relationship_group_code);
     END IF;

     IF p_cust_acct_site_id IS NOT NULL
     THEN
       BEGIN
        SELECT HZ_FORMAT_PUB.format_address(party_site.location_id, null, null, ', ')
               ||decode(acct.PARTY_ID,
                   party_site.PARTY_ID,'',
                   ' ('||(select party.PARTY_NAME
                          from HZ_PARTIES party, HZ_RELATIONSHIPS reln
                          where party_site.PARTY_ID = reln.PARTY_ID
                          AND reln.SUBJECT_TYPE = 'PERSON'
                          AND reln.SUBJECT_ID = party.PARTY_ID)||')')
          INTO x_formatted_address
          FROM HZ_CUST_ACCT_SITES_ALL site,
               HZ_CUST_ACCOUNTS acct,
               HZ_PARTY_SITES party_site
         WHERE site.CUST_ACCT_SITE_ID = p_cust_acct_site_id
           AND party_site.PARTY_SITE_ID = site.PARTY_SITE_ID
           AND acct.CUST_ACCOUNT_ID = site.CUST_ACCOUNT_ID;
       EXCEPTION
         WHEN OTHERS THEN
             x_formatted_address:=NULL;
       END;
     END IF;


END get_value;

END HZ_UI_UTIL_PKG;

/

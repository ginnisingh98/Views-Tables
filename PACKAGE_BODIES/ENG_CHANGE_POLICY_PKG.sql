--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_POLICY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_POLICY_PKG" AS
/* $Header: ENGUCHPB.pls 120.1 2005/06/12 21:57:20 appldev  $ */

G_PKG_NAME        CONSTANT VARCHAR2(30) := 'ENG_CHANGE_POLICY_PKG';

PROCEDURE GetChangePolicy
(   p_policy_object_name         IN  VARCHAR2
 ,  p_policy_code                IN  VARCHAR2
 ,  p_policy_pk1_value           IN  VARCHAR2
 ,  p_policy_pk2_value           IN  VARCHAR2
 ,  p_policy_pk3_value           IN  VARCHAR2
 ,  p_policy_pk4_value           IN  VARCHAR2
 ,  p_policy_pk5_value           IN  VARCHAR2
 ,  p_attribute_object_name      IN  VARCHAR2
 ,  p_attribute_code             IN  VARCHAR2
 ,  p_attribute_value            IN  VARCHAR2
 ,  x_policy_value               OUT NOCOPY VARCHAR2
)
IS
BEGIN

      SELECT pv.policy_char_value
       INTO x_policy_value
from eng_change_rule_attributes_vl ra,
       eng_change_rules r,
       eng_change_policy_values pv,
       eng_change_policies p
where
       p.policy_object_name = p_policy_object_name
       and p.policy_code= p_policy_code
       and p.policy_object_pk1_value = p_policy_pk1_value
       and p.policy_object_pk2_value = p_policy_pk2_value
       and p.policy_object_pk3_value = p_policy_pk3_value
       and ra.attribute_object_name = p_attribute_object_name
       and ra.attribute_code = p_attribute_code
       and nvl(r.attribute_number_value,'') = nvl(p_attribute_value,'')
       and p.change_policy_id = pv.change_policy_id
       and pv.change_rule_id = r.change_rule_id
       and r.attribute_object_name = ra.attribute_object_name
       and r.attribute_code = ra.attribute_code;
    EXCEPTION
      WHEN no_data_found THEN
        x_policy_value := 'ALLOWED';

END GetChangePolicy ;

PROCEDURE GET_OPATTR_CHANGEPOLICY
(   p_api_version                IN NUMBER
 ,  x_return_status              OUT NOCOPY VARCHAR2
 ,  p_catalog_category_id        IN  VARCHAR2
 ,  p_item_lifecycle_id          IN  VARCHAR2
 ,  p_lifecycle_phase_id         IN  VARCHAR2
 ,  p_attribute_grp_ids          IN  VARCHAR2
 ,  x_policy_value               OUT NOCOPY VARCHAR2
)
IS
  l_dynamic_sql      VARCHAR2(32767);
  l_api_name         CONSTANT VARCHAR2(30) := 'GET_OPATTR_CHANGEPOLICY';
  l_api_version      CONSTANT NUMBER       := 1.0;
BEGIN
  IF NOT FND_API.Compatible_API_Call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_dynamic_sql := q'!
    select decode (max(restrict_id), 30, 'NOT_ALLOWED',
                                 20, 'CHANGE_ORDER_REQUIRED',
                                 10, 'ALLOWED')
    from
    ( select decode( pv.policy_char_value, 'NOT_ALLOWED', 30,
                                       'CHANGE_ORDER_REQUIRED', 20,
                                       10) restrict_id
    from eng_change_rule_attributes_vl ra,
       eng_change_rules r,
       eng_change_policy_values pv,
       eng_change_policies p
    where
       p.policy_object_name = 'CATALOG_LIFECYCLE_PHASE'
       and p.policy_code= 'CHANGE_POLICY'
       and p.policy_object_pk1_value = !' || p_catalog_category_id || q'!
       and p.policy_object_pk2_value = !' || p_item_lifecycle_id || q'!
       and p.policy_object_pk3_value = !' || p_lifecycle_phase_id || q'!
       and ra.attribute_object_name = 'EGO_CATALOG_GROUP'
       and ra.attribute_code = 'ATTRIBUTE_GROUP'
       and r.attribute_number_value in !'
       || '('|| p_attribute_grp_ids|| ')' || q'!
       and p.change_policy_id = pv.change_policy_id
       and pv.change_rule_id = r.change_rule_id
       and r.attribute_object_name = ra.attribute_object_name
       and r.attribute_code = ra.attribute_code)!';

  EXECUTE IMMEDIATE l_dynamic_sql
  INTO x_policy_value;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN no_data_found
    THEN
      x_policy_value := 'ALLOWED';
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    WHEN OTHERS
    THEN
      x_policy_value := 'NOT_ALLOWED';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END GET_OPATTR_CHANGEPOLICY;

END ENG_CHANGE_POLICY_PKG ;

/

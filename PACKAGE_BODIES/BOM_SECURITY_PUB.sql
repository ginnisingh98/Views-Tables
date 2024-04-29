--------------------------------------------------------
--  DDL for Package Body BOM_SECURITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_SECURITY_PUB" AS
/* $Header: BOMSECPB.pls 120.2 2005/07/27 09:00:01 earumuga noship $ */

FUNCTION CHECK_USER_PRIVILEGE
  (
   p_api_version       IN  NUMBER,
   p_function         IN  VARCHAR2,
   p_object_name       IN  VARCHAR2,
   p_instance_pk1_value   IN  VARCHAR2,
   p_instance_pk2_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value   IN  VARCHAR2 DEFAULT NULL,
   p_user_name            in varchar2  default null
 )
 RETURN VARCHAR2
 IS
 BEGIN
  IF p_user_name IS NULL
  THEN
    return 'T';
  END IF;
  return EGO_DATA_SECURITY.Check_Function(
                                   p_api_version                   => p_api_version
                                  ,p_function                      => p_function
                                  ,p_object_name                   => p_object_name
                                  ,p_instance_pk1_value            => p_instance_pk1_value
                                  ,p_instance_pk2_value            => p_instance_pk2_value
                                  ,p_instance_pk3_value            => p_instance_pk3_value
                                  ,p_instance_pk4_value            => p_instance_pk4_value
                                  ,p_instance_pk5_value            => p_instance_pk5_value
                                  ,p_user_name                     => p_user_name
                               );
 END CHECK_USER_PRIVILEGE;



FUNCTION CHECK_ITEM_PRIVILEGE
  (
   p_function         IN  VARCHAR2,
   p_inventory_item_id IN  VARCHAR2,
   p_organization_id  IN  VARCHAR2,
   p_user_name            in varchar2  default null
 )
 RETURN VARCHAR2
 IS
 l_user_name fnd_grants.grantee_key%type;
 BEGIN
  IF p_user_name is null THEN
     l_user_name := bom_security_pub.get_ego_user;
  ELSE
     l_user_name := p_user_name;
  END IF;
  return EGO_DATA_SECURITY.Check_Function(
                                   p_api_version                   => 1
                                  ,p_function                      => p_function
                                  ,p_object_name                   => 'EGO_ITEM'
                                  ,p_instance_pk1_value            => p_inventory_item_id
                                  ,p_instance_pk2_value            =>p_organization_id
                                  ,p_instance_pk3_value            => NULL
                                  ,p_instance_pk4_value            => NULL
                                  ,p_instance_pk5_value            => NULL
                                  ,p_user_name                     => l_user_name
                               );
 END CHECK_ITEM_PRIVILEGE;


FUNCTION  GET_EGO_USER
RETURN VARCHAR2
is
  L_FNDUSER NUMBER;
  G_EGOUSER VARCHAR2(100);
BEGIN
  L_FNDUSER := FND_GLOBAL.USER_ID ;
    IF (L_FNDUSER IS NOT NULL) THEN
       SELECT
          'HZ_PARTY:' || PARTY_ID
       INTO
           G_EgoUser
       FROM EGO_USER_V
       WHERE
          USER_ID = L_FNDUSER;

      RETURN G_EGOUSER;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END GET_EGO_USER;

FUNCTION  GET_FUNCTION_NAME_TO_CHECK RETURN VARCHAR2
IS
BEGIN
  Return BOM_SECURITY_PUB.FUNCTION_NAME_TO_CHECK;
END;

END BOM_SECURITY_PUB;

/

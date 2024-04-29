--------------------------------------------------------
--  DDL for Package Body DOM_COMMON_ATTACHMENT_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DOM_COMMON_ATTACHMENT_SECURITY" AS
/* $Header: DOMSECPB.pls 120.4.12010000.4 2009/04/09 10:09:22 chechand ship $ */
/*---------------------------------------------------------------------------+
 | This package contains APIs to reslove docuemnt security mappings          |
 | based on fnd data security                                                |
 +---------------------------------------------------------------------------*/
FUNCTION GET_ATTACHMENT_PRIVILAGES
(
p_entity_name IN VARCHAR2,
p_pk1_value IN VARCHAR2,
p_pk2_value IN VARCHAR2,
p_pk3_value IN VARCHAR2,
p_pk4_value IN VARCHAR2,
p_pk5_value IN VARCHAR2,
p_user_id IN VARCHAR2,
p_attachment_id IN NUMBER DEFAULT NULL
) RETURN VARCHAR2
IS
l_function_name VARCHAR2(100);
l_function_returned VARCHAR2(300) default null;
BEGIN

SELECT GET_ATTACH_ACCESS_PLSQL_API INTO l_function_name FROM dom_attachment_entities WHERE entity_name = p_entity_name;
 EXECUTE IMMEDIATE      'select   '|| l_function_name  || '( :1 , :2 ,:3 ,:4 ,:5 ,:6 ,:7 ,:8) from dual' INTO l_function_returned USING IN p_entity_name,
 IN p_pk1_value , IN p_pk2_value ,IN p_pk3_value ,IN p_pk4_value ,IN p_pk5_value , IN p_user_id ,IN p_attachment_id;

RETURN l_function_returned;
EXCEPTION
WHEN OTHERS then
RETURN NULL;

END get_attachment_privilages;


------------------------------------------------------


FUNCTION GET_DOC_ATTACHMENT_PRIVILEGES
(
p_entity_name IN VARCHAR2,
p_pk1_value IN VARCHAR2,
p_pk2_value IN VARCHAR2,
p_pk3_value IN VARCHAR2,
p_pk4_value IN VARCHAR2,
p_pk5_value IN VARCHAR2,
p_user_id IN VARCHAR2,
p_attachment_id IN NUMBER DEFAULT NULL
) RETURN VARCHAR2
IS
  l_policy_value VARCHAR2(30);
  l_item_catalog_group_id VARCHAR2(30);
  l_lifecycle_id VARCHAR2(30);
  l_current_phase_id VARCHAR2(30);
  l_viewPriv       VARCHAR2(30) DEFAULT NULL;
  l_editPriv       VARCHAR2(30) DEFAULT NULL;
  l_result          VARCHAR2(30);
  l_party_id       VARCHAR2(30);
  l_category_id    VARCHAR2(30);
  BEGIN

  SELECT PARTY_ID INTO l_party_id FROM EGO_USER_V WHERE user_id = p_user_id;

  l_viewPriv := EGO_DATA_SECURITY.CHECK_FUNCTION (
        1.0,
        'DOM_DOC_VIEW_FILE_LIST',
        'DOM_DOCUMENT_REVISION',
        p_pk1_value,
        p_pk2_value,
        NULL,NULL,NULL,
        'HZ_PARTY:'||l_party_id);
  l_editPriv := EGO_DATA_SECURITY.CHECK_FUNCTION (
        1.0,
        'DOM_DOC_EDIT_FILE_LIST',
        'DOM_DOCUMENT_REVISION',
        p_pk1_value,
        p_pk2_value,
        NULL,NULL,NULL,
        'HZ_PARTY:'||l_party_id);

  IF (l_editPriv = 'T') THEN
    RETURN 'Update' ;
  END IF;

  IF (l_viewPriv = 'T') THEN
    RETURN 'View' ;
  END IF;

  EXCEPTION
  WHEN OTHERS then
    RETURN null;
 END GET_DOC_ATTACHMENT_PRIVILEGES;

 -------------------------------


END DOM_COMMON_ATTACHMENT_SECURITY;

/

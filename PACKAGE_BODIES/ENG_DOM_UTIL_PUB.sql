--------------------------------------------------------
--  DDL for Package Body ENG_DOM_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_DOM_UTIL_PUB" AS
/* $Header: ENGPDUTB.pls 120.1 2006/04/27 03:23:21 prgopala noship $ */

G_SUCCESS            CONSTANT  NUMBER  :=  0;
G_WARNING            CONSTANT  NUMBER  :=  1;
G_ERROR              CONSTANT  NUMBER  :=  2;

G_PKG_NAME           CONSTANT  VARCHAR2(30)  := 'ENG_DOM_UTIL_PUB';
G_APP_NAME           CONSTANT  VARCHAR2(3)   := 'ENG';
G_PKG_NAME_TOKEN     CONSTANT  VARCHAR2(8)   := 'PKG_NAME';
G_API_NAME_TOKEN     CONSTANT  VARCHAR2(8)   := 'API_NAME';
G_SQL_ERR_MSG_TOKEN  CONSTANT  VARCHAR2(11)  := 'SQL_ERR_MSG';
G_PLSQL_ERR          CONSTANT  VARCHAR2(17)  := 'EGO_PLSQL_ERR';

PROCEDURE code_debug (p_msg  IN  VARCHAR2) IS
BEGIN
   --sri_debug (' ENGPDUTB - ENG_DOM_UTIL_PUB   '||p_msg);
  RETURN;
EXCEPTION
  WHEN OTHERS THEN
  NULL;
END;


FUNCTION check_floating_attachments (
                                        p_inventory_item_id     IN NUMBER
                                       ,p_revision_id           IN NUMBER
                                       ,p_organization_id       IN NUMBER
                                       ,p_lifecycle_id          IN NUMBER
                                       ,p_new_phase_id          IN NUMBER
) RETURN VARCHAR2 IS
l_catalog_id NUMBER;
l_lifecycle_id NUMBER;
l_current_phase_id NUMBER;
l_catalog_group_ids VARCHAR2(150);
l_att_cat_ids VARCHAR2(150);
l_row_count NUMBER;
attach_query VARCHAR2(2000);
pk_value NUMBER;
cat_index INTEGER;
l_flag BOOLEAN;
t_parent_cat_id NUMBER;


CURSOR policy_cursor (
        cp_pol_obj_name IN VARCHAR2,
        cp_pol_code IN VARCHAR2,
        cp_pol_pk1 IN NUMBER,
        cp_pol_pk2 IN NUMBER,
        cp_pol_pk3 IN NUMBER,
        cp_attr_obj_name IN VARCHAR2,
        cp_attr_code IN VARCHAR2) IS
SELECT r.attribute_code,
       ra.attribute_column_type,
       r.attribute_number_value,
       r.attribute_char_value,
       p.policy_column_type,
       pv.policy_char_value,
       pv.policy_number_value,
       ra.attribute_object_name
from
       eng_change_rule_attributes_vl ra,
       eng_change_rules r,
       eng_change_policy_values pv,
       eng_change_policies p
where
       p.policy_object_name = cp_pol_obj_name
       and p.policy_code= cp_pol_code
       and p.policy_object_pk1_value = cp_pol_pk1
       and p.policy_object_pk2_value = cp_pol_pk2
       and p.policy_object_pk3_value = cp_pol_pk3
       and ra.attribute_object_name = cp_attr_obj_name
       and ra.attribute_code = cp_attr_code
       and p.change_policy_id = pv.change_policy_id
       and pv.change_rule_id = r.change_rule_id
       and r.attribute_object_name = ra.attribute_object_name
       and r.attribute_code = ra.attribute_code
       and r.attribute_number_value IS NOT NULL;

CURSOR c_get_assoc_category_id (cp_catalog_category_id  IN  NUMBER
                                 ,cp_lifecycle_id         IN  NUMBER
                                 ) IS
     SELECT ic.item_catalog_group_id
       FROM MTL_ITEM_CATALOG_GROUPS_B ic
      WHERE EXISTS (
              SELECT olc.object_classification_code CatalogId
                FROM  ego_obj_type_lifecycles olc, fnd_objects o
               WHERE o.obj_name =  'EGO_ITEM'
                 AND olc.object_id = o.object_id
                 AND olc.lifecycle_id = cp_lifecycle_id
                 AND olc.object_classification_code = item_catalog_group_id
                   )
     CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
     START WITH item_catalog_group_id = cp_catalog_category_id;

BEGIN
code_debug( 'ENG_DOM_UTIL ' )  ;



IF p_revision_id IS NULL OR p_revision_id = -1 THEN
  SELECT lifecycle_id,
         current_phase_id,
         item_catalog_group_id
  INTO
         l_lifecycle_id,
         l_current_phase_id,
         l_catalog_id
  FROM MTL_SYSTEM_ITEMS
  WHERE inventory_item_id = p_inventory_item_id
  AND organization_id = p_organization_id;
ELSE
  SELECT REV.lifecycle_id,
         REV.current_phase_id,
         IT.item_catalog_group_id
  INTO
         l_lifecycle_id,
         l_current_phase_id,
         l_catalog_id
  FROM MTL_ITEM_REVISIONS REV, MTL_SYSTEM_ITEMS IT
  WHERE
        REV.inventory_item_id = IT.inventory_item_id
  AND   REV.inventory_item_id = p_inventory_item_id
  AND   REV.organization_id = p_organization_id
  AND   REV.revision_id = p_revision_id;
END IF;

code_debug('vals  ' || p_inventory_item_id || ' ' || p_revision_id || ' ' || p_lifecycle_id || ' ' || p_new_phase_id || ' ' || l_catalog_id );
IF  p_lifecycle_id IS NOT NULL THEN
        l_lifecycle_id := p_lifecycle_id;
END IF;

--Check which catalog category actually has the lifecycle associated with it
OPEN c_get_assoc_category_id (cp_lifecycle_id => l_lifecycle_id
                                 ,cp_catalog_category_id => l_catalog_id
                                 );
FETCH c_get_assoc_category_id INTO t_parent_cat_id;
CLOSE c_get_assoc_category_id;


code_debug('CATALOG_ID' || t_parent_cat_id );


l_att_cat_ids := '';
code_debug ('vals ' || pk_value || ' ' || l_lifecycle_id || ' ' || p_new_phase_id);
FOR pol_rec1 IN policy_cursor (
                                cp_pol_obj_name  => 'CATALOG_LIFECYCLE_PHASE',
                                cp_pol_code      => 'CHANGE_POLICY',
                                cp_pol_pk1       => t_parent_cat_id,
                                cp_pol_pk2       => l_lifecycle_id,
                                cp_pol_pk3       => p_new_phase_id,
                                cp_attr_obj_name => 'EGO_CATALOG_GROUP',
                                cp_attr_code     => 'ATTACHMENT'
                             ) LOOP
        IF pol_rec1.ATTRIBUTE_NUMBER_VALUE IS NOT NULL THEN
               IF pol_rec1.POLICY_CHAR_VALUE = 'CHANGE_ORDER_REQUIRED' THEN
                        l_att_cat_ids :=  l_att_cat_ids || pol_rec1.ATTRIBUTE_NUMBER_VALUE || ',';
               END IF;
        END IF;
END LOOP;

IF (LENGTH(l_att_cat_ids) > 0) THEN
      l_att_cat_ids := SUBSTR(l_att_cat_ids, 1, LENGTH(l_att_cat_ids) - LENGTH(','));
END IF;

code_debug( 'ATT CATS ' || l_att_cat_ids );

IF l_att_cat_ids IS NULL THEN
        RETURN 'N';
END IF;

attach_query := 'select count(*) from  (SELECT a.ATTACHED_DOCUMENT_ID,
       a.DOCUMENT_ID,
       a.ENTITY_NAME,
       a.PK1_VALUE,
       a.PK2_VALUE,
       a.PK3_VALUE,
       a.PK4_VALUE,
       a.PK5_VALUE,
       nvl(a.CATEGORY_ID, d.CATEGORY_ID) AS CATEGORY_ID,
       d.DOCUMENT_ID AS DOCUMENT_ID1,
       dt.DESCRIPTION,
       dt.FILE_NAME FILE_NAME,
       dt.MEDIA_ID,
       d.DM_DOCUMENT_ID,
       d.DM_VERSION_NUMBER,
       pr.PROTOCOL
FROM FND_ATTACHED_DOCUMENTS a,
     FND_DOCUMENTS d,
     FND_DOCUMENTS_TL dt,
     FND_DOCUMENT_CATEGORIES_TL ct,
     FND_DM_NODES n,
     FND_LOOKUP_VALUES_VL lkp,
     DOM_FOLDER_ATTACHMENTS df,
     FND_DM_NODES dn,
     FND_DM_PRODUCTS pr
WHERE a.DOCUMENT_ID = d.DOCUMENT_ID and
      d.DOCUMENT_ID = dt.DOCUMENT_ID and
      dt.LANGUAGE = USERENV(''LANG'') and
      ct.CATEGORY_ID = nvl(a.CATEGORY_ID, d.CATEGORY_ID) and
      ct.LANGUAGE = USERENV(''LANG'') and
      d.DM_NODE = n.NODE_ID (+)
      and lkp.LOOKUP_TYPE(+) = ''FND_DM_ATTACHED_DOC_STATUS''
      and lkp.LOOKUP_CODE(+) = nvl(a.STATUS,''UNAPPROVED'')
      and df.attachment_id(+)=a.attached_document_id
      and d.dm_node = dn.node_id
      and dn.PRODUCT_ID = pr.product_id)';

      IF p_revision_id IS NULL THEN
        attach_query := attach_query || ' where entity_name = ''MTL_SYSTEM_ITEMS''';
      ELSE
        attach_query := attach_query || ' where entity_name = ''MTL_ITEM_REVISIONS''';
      END IF;

      attach_query := attach_query || ' and pk1_value = :1 and pk2_value = :2 and dm_document_id = 0 and protocol = ''WEBSERVICES'' and category_id in ('||  l_att_cat_ids  || ')';

code_debug (attach_query);

EXECUTE IMMEDIATE attach_query INTO l_row_count using p_organization_id, p_inventory_item_id;

code_debug ('Row count ' || l_row_count);

IF l_row_count = 0 THEN
        RETURN 'N';
ELSE
        RETURN 'Y';
END IF;
RETURN 'N';
EXCEPTION
  WHEN OTHERS THEN
  RETURN 'N';

END check_floating_attachments;


END ENG_DOM_UTIL_PUB;

/

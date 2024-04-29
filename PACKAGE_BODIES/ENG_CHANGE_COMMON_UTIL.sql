--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_COMMON_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_COMMON_UTIL" AS
/* $Header: ENGUCMNB.pls 120.3 2006/09/08 12:13:09 ksathupa noship $ */

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'Eng_Change_Common_Util';


--  Get_User_Party_Id
/*****************************************************************************
* Function      : Get_User_Party_Id
* Returns       : The party id for a user idenitfied by fnd user name
*                 NULL if no matching party is found
* Purpose       : Convert the user name into a party id.
*
* Bug No: 4327218
* Changing all reference to FND_USER.customer_id as FND_USER.person_party_id
* Changing the variable name also to avoid confusion.
*****************************************************************************/
FUNCTION Get_User_Party_Id
( p_user_name      IN VARCHAR2
, x_err_text       OUT NOCOPY VARCHAR2
)

RETURN NUMBER
IS
l_employee_id                  NUMBER;
--l_customer_id                  NUMBER;
l_person_party_id              NUMBER;
l_supplier_id                  NUMBER;
l_user_party_id                NUMBER;
BEGIN

    SELECT employee_id, person_party_id, supplier_id
    INTO l_employee_id, l_person_party_id, l_supplier_id
    FROM fnd_user
    WHERE user_name = upper(p_user_name);--Bug No 3463516
    -- Since the internal value of user_name is always upper case
    -- removed the upper fn from the column, to fix perfoemance bug
    -- 4950315

    IF l_employee_id IS NULL THEN
        l_user_party_id := nvl(l_person_party_id, l_supplier_id);
    ELSE
        SELECT party_id INTO l_user_party_id
        FROM per_all_people_f
        WHERE person_id = l_employee_id and rownum = 1;

        --SELECT party_id INTO l_user_party_id
        --FROM hz_parties
        --WHERE person_identifier = l_employee_id;
    END IF;

    RETURN l_user_party_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_err_text := NULL;
        RETURN NULL;

    WHEN OTHERS THEN
        x_err_text := G_PKG_NAME || ' : (User to Party id conversion) '
                        || substrb(SQLERRM,1,200);
        RETURN  FND_API.G_MISS_NUM;

END Get_User_Party_Id;

FUNCTION Get_New_Ref_Designators(p_component_seq_id IN NUMBER)
RETURN VARCHAR2
IS
  CURSOR c_new_ref_designators IS
  SELECT COMPONENT_REFERENCE_DESIGNATOR
  FROM bom_reference_designators
  WHERE acd_type = 1
  AND COMPONENT_SEQUENCE_ID = p_component_seq_id;

  l_new_ref_desig VARCHAR2(4000);

BEGIN

  FOR cnrd IN c_new_ref_designators
  LOOP
    IF(l_new_ref_desig IS NOT NULL)
    THEN
      l_new_ref_desig := l_new_ref_desig || ', ';
    END IF;
    l_new_ref_desig := l_new_ref_desig || cnrd.COMPONENT_REFERENCE_DESIGNATOR;
  END LOOP;
  RETURN l_new_ref_desig;
END Get_New_Ref_Designators;

-- Added for 11.5.10E changes
FUNCTION GET_COMP_REVISION_FN(
  p_organization_id       IN NUMBER
, p_component_item_id     IN NUMBER
, p_item_revision_id      IN NUMBER)
RETURN VARCHAR2
IS

  CURSOR c_get_item_revision(cp_revision_id NUMBER) IS
  SELECT revision
  FROM mtl_item_revisions
  WHERE revision_id = cp_revision_id;

  l_revision_id NUMBER;
  l_revision VARCHAR2(3);

BEGIN

  l_revision_id := p_item_revision_id;
  IF l_revision_id IS NULL
  THEN
    l_revision_id := BOM_REVISIONS.GET_ITEM_REVISION_ID_FN('ALL', 'IMPL_ONLY', p_organization_id, p_component_item_id, SYSDATE);
  END IF;

  OPEN c_get_item_revision(l_revision_id);
  FETCH c_get_item_revision INTO l_revision;
  CLOSE c_get_item_revision;
  RETURN l_revision;

EXCEPTION
WHEN OTHERS THEN
  IF c_get_item_revision%ISOPEN
  THEN
    CLOSE c_get_item_revision;
  END IF;
  RETURN l_revision;

END GET_COMP_REVISION_FN;

PROCEDURE process_attribute_defaulting(p_change_attr_def_tab   IN OUT NOCOPY ENG_CHANGE_ATTR_DEFAULT_TABLE
                                       ,p_commit              IN         VARCHAR2
                                       ,p_pk_val_name         IN        VARCHAR2
                                       ,p_pk_class_val_name   IN        VARCHAR2
                                       ,x_return_status       OUT NOCOPY VARCHAR2
                                       ,x_msg_data            OUT NOCOPY VARCHAR2
                                       ,x_msg_count           OUT NOCOPY  NUMBER)

IS

l_error_code VARCHAR2(2000);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_failed_row_id_list  VARCHAR2(2000);


l_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
l_class_code_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
l_data_level_values EGO_COL_NAME_VALUE_PAIR_ARRAY;

l_entity_id  NUMBER;
l_object_name VARCHAR2(30);
l_application_id NUMBER;
l_change_type_id NUMBER;
l_additional_class_Code_list VARCHAR2(32000);
l_attribute_group_type VARCHAR2(20);
l_record_first NUMBER;
l_record_last  NUMBER;
l_return_status VARCHAR2(10);
l_commit VARCHAR2(2);
l_attr_groups_to_exclude VARCHAR2(2000);

CURSOR attr_default_recs IS
     SELECT A.ENTITY_ID          ENTITY_ID
           ,A.APPLICATION_ID           APPLICATION_ID
           ,A.OBJECT_NAME              OBJECT_NAME
           ,A.ATTRIBUTE_GROUP_TYPE     ATTRIBUTE_GROUP_TYPE
           ,A.CHANGE_TYPE_ID     CHANGE_TYPE_ID
     FROM THE (SELECT CAST(
           p_change_attr_def_tab AS ENG_CHANGE_ATTR_DEFAULT_TABLE)
                FROM dual) A
     ORDER BY ENTITY_ID ;


BEGIN
 x_return_status := l_return_status;
 x_msg_count     := 0;
 l_record_first := p_change_attr_def_tab.FIRST;
 l_record_last  := p_change_attr_def_tab.LAST;

 FOR attr_default_rec IN attr_default_recs LOOP
    l_entity_id  := attr_default_rec.ENTITY_ID;
    l_object_name := attr_default_rec.OBJECT_NAME;
    l_application_id := attr_default_rec.APPLICATION_ID;
    l_change_type_id := attr_default_rec.CHANGE_TYPE_ID;
    l_attribute_group_type := attr_default_rec.ATTRIBUTE_GROUP_TYPE;
    l_commit := p_commit;



    l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY
          ( EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk_val_name , TO_CHAR(attr_default_rec.ENTITY_ID)));
          -- get this as param
    l_class_code_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY
          (EGO_COL_NAME_VALUE_PAIR_OBJ(p_pk_class_val_name, to_char(attr_default_rec.CHANGE_TYPE_ID)));

    l_data_level_values := NULL;

    EGO_USER_ATTRS_DATA_PVT.Apply_Default_Vals_For_Entity
                                          ( p_object_name                   => l_object_name
                                           ,p_application_id                => l_application_id
                                           ,p_attr_group_type               => l_attribute_group_type
                                           ,p_pk_column_name_value_pairs    => l_pk_column_name_value_pairs
                                           ,p_class_code_name_value_pairs   => l_class_code_name_value_pairs
                                           ,p_data_level_values             => l_data_level_values
					   ,p_init_error_handler            => 'T'
					   ,p_init_fnd_msg_list             => 'T'
					   ,p_log_errors                    => 'T'
					   ,p_add_errors_to_fnd_stack       => 'T'
					   ,P_commit                        => l_commit
					   ,x_failed_row_id_list            => l_failed_row_id_list
                                           ,x_return_status                 => l_return_status
                                           ,x_errorcode                     => l_error_code
                                           ,x_msg_count                     => l_msg_count
                                           ,x_msg_data                      => l_msg_data
                                          );

    x_return_status := l_return_status ;
 END LOOP;
EXCEPTION
WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := SQLERRM;
END;

END ENG_CHANGE_COMMON_UTIL;

/

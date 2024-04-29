--------------------------------------------------------
--  DDL for Package Body INV_EBI_CHANGE_ORDER_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_EBI_CHANGE_ORDER_HELPER" AS
/* $Header: INVEIHCOB.pls 120.32.12010000.16 2010/04/06 13:22:04 smukka ship $ */

/************************************************************************************
 --      API name        : set_assign_item
 --      Type            : Private
 --      Function        :
 ************************************************************************************/
 PROCEDURE set_assign_item(
   p_assign_item IN VARCHAR2
 ) IS
 BEGIN
   G_ASSIGN_ITEM := p_assign_item;
 END set_assign_item;

/************************************************************************************
  --      API name        : get_assign_item
  --      Type            : Private
  --      Function        :
  ************************************************************************************/
  FUNCTION get_assign_item RETURN VARCHAR2
   IS
  BEGIN
    RETURN G_ASSIGN_ITEM ;
 END get_assign_item;

/************************************************************************************
  --      API name        : get_change_order_uda
  --      Type            : Private
  --      Function        :
  --      Bug 7240247
************************************************************************************/
PROCEDURE  get_change_order_uda(
  p_change_id       IN NUMBER ,
  x_change_uda      OUT NOCOPY      inv_ebi_uda_input_obj,
  x_return_status   OUT NOCOPY      VARCHAR2,
  x_msg_count       OUT NOCOPY      NUMBER,
  x_msg_data        OUT NOCOPY      VARCHAR2
) IS
l_count                  NUMBER :=0;
l_attr_group_count       NUMBER :=0;
l_change_order_type_id   NUMBER;
l_application_id         NUMBER;
l_attr_group_id_tbl      FND_TABLE_OF_NUMBER;
l_pkdata                 EGO_COL_NAME_VALUE_PAIR_ARRAY;
l_uda_output_obj         inv_ebi_eco_output_obj;
l_output_status          inv_ebi_output_status;

CURSOR c_attr_group_id IS

  SELECT DISTINCT attr_group_id
  FROM ENG_CHANGES_EXT_B
  WHERE change_id = p_change_id;

BEGIN
  INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.get_change_order_uda ');
  INV_EBI_UTIL.debug_line('STEP 20: ECO NUMBER: '|| p_change_id);
  x_return_status   :=  FND_API.g_ret_sts_success;
  l_output_status   := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
  l_uda_output_obj  := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);

  IF(p_change_id IS NOT NULL ) THEN

    IF c_attr_group_id%ISOPEN THEN
      CLOSE c_attr_group_id;
    END IF;

    OPEN c_attr_group_id ;
      FETCH c_attr_group_id  BULK COLLECT INTO l_attr_group_id_tbl ;
    CLOSE c_attr_group_id;

    IF(l_attr_group_id_tbl IS NOT NULL AND l_attr_group_id_tbl.COUNT > 0) THEN
      l_pkdata := EGO_COL_NAME_VALUE_PAIR_ARRAY();
      l_pkdata.extend(1);
      l_pkdata(1) := EGO_COL_NAME_VALUE_PAIR_OBJ('CHANGE_ID',p_change_id);

      SELECT change_order_type_id INTO l_change_order_type_id
      FROM eng_engineering_changes
      WHERE change_id = p_change_id;

      l_application_id:= INV_EBI_UTIL.get_application_id(
                            p_application_short_name => 'ENG'
                         );

      IF(l_application_id IS NULL ) THEN
        FND_MESSAGE.set_name('INV','INV_EBI_APP_INVALID');
        FND_MESSAGE.set_token('COL_VALUE', 'ENG');
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
      END IF;
      INV_EBI_UTIL.debug_line('STEP 30: BEFORE CALLING INV_EBI_ITEM_HELPER.get_uda_attributes');
      INV_EBI_ITEM_HELPER.get_uda_attributes(
         p_classification_id  =>  l_change_order_type_id,
         p_attr_group_type    =>  INV_EBI_UTIL.G_ENG_CHANGEMGMT_GROUP,
         p_application_id     =>  l_application_id,
         p_attr_grp_id_tbl    =>  l_attr_group_id_tbl,
         p_data_level         =>  INV_EBI_UTIL.G_CHANGE_LEVEL,
         p_revision_id        =>  NULL,
         p_object_name        =>  INV_EBI_UTIL.G_CHANGE_OBJ_NAME,
         p_pk_data            =>  l_pkdata,
         x_uda_obj            =>  x_change_uda,
         x_uda_output_obj     =>  l_uda_output_obj );
      INV_EBI_UTIL.debug_line('STEP 40: END CALLING INV_EBI_ITEM_HELPER.get_uda_attributes STATUS: '|| l_uda_output_obj.output_status.return_status);
      IF(l_uda_output_obj.output_status.return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        x_msg_data      := l_uda_output_obj.output_status.msg_data ;
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
    END IF;
  END IF;
  INV_EBI_UTIL.debug_line('STEP 50: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.get_change_order_uda ');
  EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN

      IF c_attr_group_id%ISOPEN THEN
        CLOSE c_attr_group_id;
      END IF;

      x_return_status :=  FND_API.g_ret_sts_unexp_error;
      IF(x_msg_data IS NULL) THEN
        fnd_msg_pub.count_and_get(
          p_encoded => FND_API.g_false
         ,p_count   => x_msg_count
         ,p_data    => x_msg_data
       );
      END IF;
    WHEN OTHERS THEN

      IF c_attr_group_id%ISOPEN THEN
        CLOSE c_attr_group_id;
      END IF;

      x_return_status :=  FND_API.g_ret_sts_unexp_error;
      IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' ->INV_EBI_CHANGE_ORDER_HELPER.get_change_order_uda ';
      ELSE
        x_msg_data      :=  SQLERRM||'INV_EBI_CHANGE_ORDER_HELPER.get_change_order_uda ';
    END IF;
 END get_change_order_uda;

/************************************************************************************
   --      API name        : get_structure_header_uda
   --      Type            : Private
   --      Function        :
   --      Bug 7240247
************************************************************************************/

PROCEDURE get_structure_header_uda(
   p_assembly_item_id       IN  NUMBER ,
   p_alternate_bom_code     IN  VARCHAR2,
   p_organization_id        IN  NUMBER,
   x_structure_header_uda   OUT NOCOPY  inv_ebi_uda_input_obj,
   x_return_status          OUT NOCOPY  VARCHAR2,
   x_msg_count              OUT NOCOPY  NUMBER,
   x_msg_data               OUT NOCOPY  VARCHAR2
 ) IS

 l_bom_count              NUMBER :=0;
 l_uda_count              NUMBER :=0;
 l_attr_group_count       NUMBER :=0;

 l_application_id         NUMBER;
 l_attr_group_id_tbl      FND_TABLE_OF_NUMBER;
 l_pkdata                 EGO_COL_NAME_VALUE_PAIR_ARRAY;
 l_uda_output_obj         inv_ebi_eco_output_obj;
 l_output_status          inv_ebi_output_status;
 l_structure_type_id      NUMBER;
 l_bill_sequence_id       NUMBER;

 CURSOR c_attr_group_id(
           p_bill_sequence_id   NUMBER,
           p_structure_type_id  NUMBER
 ) IS
   SELECT DISTINCT attr_group_id
   FROM bom_structures_ext_b
   WHERE
     bill_sequence_id  = p_bill_sequence_id AND
     structure_type_id = p_structure_type_id;

  CURSOR c_bom_count
  IS

     SELECT bill_sequence_id,structure_type_id
     FROM bom_bill_of_materials
     WHERE
       assembly_item_id = p_assembly_item_id
       AND organization_id = p_organization_id
       AND NVL(alternate_bom_designator, 'NONE') = DECODE(p_alternate_bom_code,FND_API.G_MISS_CHAR,'NONE',NULL,'NONE',p_alternate_bom_code) ;


 BEGIN
   INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.get_structure_header_uda');
   INV_EBI_UTIL.debug_line('STEP 20: ASSY ITEM ID :' || p_assembly_item_id || 'ORG ID: '|| p_organization_id );
   x_return_status   :=  FND_API.g_ret_sts_success;
   l_output_status   := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
   l_uda_output_obj  := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);

   IF( p_assembly_item_id IS NOT NULL AND
       p_organization_id IS NOT NULL) THEN

     IF c_bom_count%ISOPEN THEN
       CLOSE c_bom_count;
     END IF;

     OPEN c_bom_count;
     FETCH c_bom_count INTO l_bill_sequence_id,l_structure_type_id;

     IF(c_bom_count % ROWCOUNT > 0) THEN

       IF c_attr_group_id%ISOPEN THEN
         CLOSE c_attr_group_id;
       END IF;

       OPEN c_attr_group_id(l_bill_sequence_id,l_structure_type_id) ;
       FETCH c_attr_group_id BULK COLLECT INTO l_attr_group_id_tbl ;

       IF(c_attr_group_id % ROWCOUNT > 0) THEN


         l_pkdata := EGO_COL_NAME_VALUE_PAIR_ARRAY();
         l_pkdata.extend(1);
         l_pkdata(1) := EGO_COL_NAME_VALUE_PAIR_OBJ('BILL_SEQUENCE_ID',l_bill_sequence_id);

         l_application_id:= INV_EBI_UTIL.get_application_id(
                                p_application_short_name => 'BOM'
                            );
         IF(l_application_id IS NULL ) THEN

           FND_MESSAGE.set_name('INV','INV_EBI_APP_INVALID');
           FND_MESSAGE.set_token('COL_VALUE', 'BOM');
           FND_MSG_PUB.add;
           RAISE FND_API.g_exc_error;
         END IF;
         INV_EBI_UTIL.debug_line('STEP 30: BEFORE CALLING INV_EBI_ITEM_HELPER.get_uda_attributes');
         INV_EBI_ITEM_HELPER.get_uda_attributes(
            p_classification_id  =>  l_structure_type_id,
            p_attr_group_type    =>  INV_EBI_UTIL.G_BOM_STRUCTUREMGMT_GROUP,
            p_application_id     =>  l_application_id,
            p_attr_grp_id_tbl    =>  l_attr_group_id_tbl,
            p_data_level         =>  INV_EBI_UTIL.G_STRUCTURES_LEVEL,
            p_revision_id        =>  NULL,
            p_object_name        =>  INV_EBI_UTIL.G_BOM_STRUCTURE_OBJ_NAME,
            p_pk_data            =>  l_pkdata,
            x_uda_obj            =>  x_structure_header_uda,
            x_uda_output_obj     =>  l_uda_output_obj
         );
         INV_EBI_UTIL.debug_line('STEP 40: END CALLING INV_EBI_ITEM_HELPER.get_uda_attributes STATUS:  ' || l_uda_output_obj.output_status.return_status );
         IF(l_uda_output_obj.output_status.return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
           x_msg_data      := l_uda_output_obj.output_status.msg_data ;
           RAISE FND_API.g_exc_unexpected_error;
         END IF;
       END IF;
       CLOSE c_attr_group_id;
     END IF;
     CLOSE c_bom_count;
   END IF;
   INV_EBI_UTIL.debug_line('STEP 50: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.get_structure_header_uda');
   EXCEPTION
     WHEN FND_API.g_exc_unexpected_error THEN

       IF c_attr_group_id%ISOPEN THEN
         CLOSE c_attr_group_id;
       END IF;

       IF c_bom_count%ISOPEN THEN
          CLOSE c_bom_count;
       END IF;

       x_return_status :=  FND_API.g_ret_sts_unexp_error;
       IF(x_msg_data IS NULL) THEN
         fnd_msg_pub.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
        );
       END IF;
     WHEN OTHERS THEN

       IF c_attr_group_id%ISOPEN THEN
         CLOSE c_attr_group_id;
       END IF;

       IF c_bom_count%ISOPEN THEN
         CLOSE c_bom_count;
       END IF;

       x_return_status :=  FND_API.g_ret_sts_unexp_error;
       IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' ->INV_EBI_CHANGE_ORDER_HELPER.get_structure_header_uda ';
       ELSE
         x_msg_data      :=  SQLERRM||'INV_EBI_CHANGE_ORDER_HELPER.get_structure_header_uda ';
     END IF;
  END get_structure_header_uda;

/************************************************************************************
   --      API name        : get_component_item_uda
   --      Type            : Private
   --      Function        :
   --      Bug 7240247
************************************************************************************/

PROCEDURE get_component_item_uda(
  p_eco_name              IN    VARCHAR2,
  p_revised_item_id       IN    NUMBER,
  p_component_item_name   IN    VARCHAR2,
  p_alternate_bom_code    IN    VARCHAR2,
  p_organization_id       IN    NUMBER,
  x_comp_item_uda         OUT   NOCOPY  inv_ebi_uda_input_obj,
  x_return_status         OUT   NOCOPY  VARCHAR2,
  x_msg_count             OUT   NOCOPY  NUMBER,
  x_msg_data              OUT   NOCOPY  VARCHAR2
) IS

 l_bom_count              NUMBER :=0;
 l_uda_count              NUMBER :=0;
 l_attr_group_count       NUMBER :=0;
 l_application_id         NUMBER;
 l_attr_group_id_tbl      FND_TABLE_OF_NUMBER;
 l_pkdata                 EGO_COL_NAME_VALUE_PAIR_ARRAY;
 l_uda_output_obj         inv_ebi_eco_output_obj;
 l_output_status          inv_ebi_output_status;
 l_structure_type_id      NUMBER;
 l_bill_sequence_id       NUMBER;
 l_component_item_id      NUMBER;
 l_component_sequence_id  NUMBER;
 l_component_count        NUMBER := 0;


 CURSOR c_attr_group_id(
           p_bill_sequence_id   NUMBER,
           p_structure_type_id  NUMBER
 ) IS
   SELECT DISTINCT attr_group_id
   FROM bom_components_ext_b
   WHERE bill_sequence_id  = p_bill_sequence_id
   AND   structure_type_id = p_structure_type_id;

 CURSOR c_bom_count
 IS

   SELECT bill_sequence_id,structure_type_id
   FROM bom_bill_of_materials
   WHERE
     assembly_item_id = p_revised_item_id
     AND organization_id = p_organization_id
     AND NVL(alternate_bom_designator, 'NONE') = DECODE(p_alternate_bom_code,FND_API.G_MISS_CHAR,'NONE',NULL,'NONE',p_alternate_bom_code) ;

 CURSOR c_comp_count(
          p_bill_sequence_id   NUMBER,
          p_component_item_id  NUMBER
 ) IS
   SELECT component_sequence_id
   FROM bom_components_b
   WHERE
     bill_sequence_id   = p_bill_sequence_id AND
     component_item_id  = p_component_item_id AND
     change_notice      = p_eco_name;

 BEGIN
   INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.get_component_item_uda');
   INV_EBI_UTIL.debug_line('STEP 20: ECO NAME: '|| p_eco_name || 'REVISED ITEM ID: '|| p_revised_item_id ||
                             'COMPONENT NAME: '|| p_component_item_name  ||'ORG ID: ' || p_organization_id);
   x_return_status   :=  FND_API.g_ret_sts_success;
   l_output_status   := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
   l_uda_output_obj  := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);

   IF( p_revised_item_id IS NOT NULL AND
     p_organization_id IS NOT NULL) THEN

     IF c_bom_count%ISOPEN THEN
       CLOSE c_bom_count;
     END IF;

     OPEN c_bom_count;
     FETCH c_bom_count INTO l_bill_sequence_id,l_structure_type_id;

     IF(c_bom_count % ROWCOUNT > 0) THEN

       l_component_item_id := INV_EBI_ITEM_HELPER.get_inventory_item_id (
                                p_organization_id => p_organization_id
                                ,p_item_number     => p_component_item_name
                              );
       INV_EBI_UTIL.debug_line('STEP 30: COMPONENT ITEM ID: '|| l_component_item_id );
       IF c_comp_count%ISOPEN THEN
         CLOSE c_comp_count;
       END IF;

       OPEN c_comp_count(l_bill_sequence_id,l_component_item_id);
       FETCH c_comp_count INTO l_component_sequence_id;

       IF(c_comp_count % ROWCOUNT > 0) THEN

         IF c_attr_group_id%ISOPEN THEN
           CLOSE c_attr_group_id;
         END IF;

         OPEN c_attr_group_id(l_bill_sequence_id,l_structure_type_id) ;
         FETCH c_attr_group_id BULK COLLECT INTO l_attr_group_id_tbl ;

         IF(c_attr_group_id % ROWCOUNT > 0) THEN

           l_pkdata := EGO_COL_NAME_VALUE_PAIR_ARRAY();
           l_pkdata.extend(2);
           l_pkdata(1) := EGO_COL_NAME_VALUE_PAIR_OBJ('BILL_SEQUENCE_ID',l_bill_sequence_id);
           l_pkdata(2) := EGO_COL_NAME_VALUE_PAIR_OBJ('COMPONENT_SEQUENCE_ID',l_component_sequence_id);

           l_application_id:= INV_EBI_UTIL.get_application_id(
                                  p_application_short_name => 'BOM'
                              );

           IF(l_application_id IS NULL ) THEN
             FND_MESSAGE.set_name('INV','INV_EBI_APP_INVALID');
             FND_MESSAGE.set_token('COL_VALUE', 'BOM');
             FND_MSG_PUB.add;
             RAISE FND_API.g_exc_error;
           END IF;
           INV_EBI_UTIL.debug_line('STEP 40: BEFORE CALLING INV_EBI_ITEM_HELPER.get_uda_attributes');
           INV_EBI_ITEM_HELPER.get_uda_attributes(
              p_classification_id  =>  l_structure_type_id,
              p_attr_group_type    =>  INV_EBI_UTIL.G_BOM_COMPONENTMGMT_GROUP,
              p_application_id     =>  l_application_id,
              p_attr_grp_id_tbl    =>  l_attr_group_id_tbl,
              p_data_level         =>  INV_EBI_UTIL.G_COMPONENTS_LEVEL,
              p_revision_id        =>  NULL,
              p_object_name        =>  INV_EBI_UTIL.G_BOM_COMPONENTS_OBJ_NAME,
              p_pk_data            =>  l_pkdata,
              x_uda_obj            =>  x_comp_item_uda,
              x_uda_output_obj     =>  l_uda_output_obj
           );
	   INV_EBI_UTIL.debug_line('STEP 50: END CALLING INV_EBI_ITEM_HELPER.get_uda_attributes STATUS: '|| l_uda_output_obj.output_status.return_status);
           IF(l_uda_output_obj.output_status.return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
             x_msg_data      := l_uda_output_obj.output_status.msg_data ;
             RAISE FND_API.g_exc_unexpected_error;
           END IF;
         END IF;
         CLOSE c_attr_group_id;
       END IF;
       CLOSE c_comp_count;
    END IF;
    CLOSE c_bom_count;
 END IF;
 INV_EBI_UTIL.debug_line('STEP 60: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.get_component_item_uda');
 EXCEPTION
   WHEN FND_API.g_exc_unexpected_error THEN

     IF c_attr_group_id%ISOPEN THEN
       CLOSE c_attr_group_id;
     END IF;

     IF c_bom_count%ISOPEN THEN
       CLOSE c_bom_count;
     END IF;

     IF c_comp_count%ISOPEN THEN
       CLOSE c_comp_count;
     END IF;

     x_return_status :=  FND_API.g_ret_sts_unexp_error;
     IF(x_msg_data IS NULL) THEN
       fnd_msg_pub.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data
      );
     END IF;
   WHEN OTHERS THEN

     IF c_attr_group_id%ISOPEN THEN
       CLOSE c_attr_group_id;
     END IF;

     IF c_bom_count%ISOPEN THEN
       CLOSE c_bom_count;
     END IF;

     IF c_comp_count%ISOPEN THEN
       CLOSE c_comp_count;
     END IF;

     x_return_status :=  FND_API.g_ret_sts_unexp_error;
     IF (x_msg_data IS NOT NULL) THEN
       x_msg_data      :=  x_msg_data||' ->INV_EBI_CHANGE_ORDER_HELPER.get_component_item_uda ';
     ELSE
       x_msg_data      :=  SQLERRM||'INV_EBI_CHANGE_ORDER_HELPER.get_component_item_uda ';
   END IF;
  END get_component_item_uda;

 /************************************************************************************
   --     API name        : get_latest_effectivity_date
   --     Type            : Private
   --     Function        :
   --     This API is used to return effectivity date of the lastest created revision
   -- Bug 7197943
  ************************************************************************************/
  FUNCTION get_latest_effectivity_date(
    p_inventory_item_id  IN NUMBER,
    p_organization_id    IN NUMBER
  ) RETURN DATE IS

  l_effectivity_date DATE;

  CURSOR c_efectivity_date IS
  SELECT
    effectivity_date
  FROM
    mtl_item_revisions_b
  WHERE
    inventory_item_id = p_inventory_item_id AND
    organization_id   = p_organization_id
  ORDER BY
    effectivity_date DESC, revision DESC;

  BEGIN
    IF c_efectivity_date%ISOPEN THEN
      CLOSE c_efectivity_date;
    END IF;

    OPEN c_efectivity_date;
    FETCH c_efectivity_date INTO l_effectivity_date;
    CLOSE c_efectivity_date;
    RETURN l_effectivity_date;
  EXCEPTION
   WHEN OTHERS THEN
     IF c_efectivity_date%ISOPEN THEN
       CLOSE c_efectivity_date;
     END IF;
     NULL;
 END get_latest_effectivity_date;

/************************************************************************************
   --      API name        : transform_substitute_comp_info
   --      Type            : Public
   --      procedure       : Prepare component,substitute components
   --                        for Replicate bom
   --  Added this API for Bug 8397083
 ************************************************************************************/
 PROCEDURE transform_substitute_comp_info(
    p_sub_component_tbl    IN  inv_ebi_sub_comp_tbl
   ,p_component_item       IN  inv_ebi_rev_comp_obj
   ,x_component_item       OUT NOCOPY inv_ebi_rev_comp_obj
   ,x_out                  OUT NOCOPY inv_ebi_eco_output_obj
  ) IS

   l_sub_comp_tbl          inv_ebi_sub_comp_tbl;
   l_component_item        inv_ebi_rev_comp_obj;
   l_sub_comp_count        NUMBER := 0;
   l_output_status         inv_ebi_output_status;

  BEGIN

     l_output_status  := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
     x_out            := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);

     INV_EBI_UTIL.debug_line('STEP 10: INSIDE INV_EBI_CHANGE_ORDER_HELPER.transform_substitute_comp_info');
     l_component_item := p_component_item;
     IF(p_sub_component_tbl IS NOT NULL AND p_sub_component_tbl.COUNT > 0 ) THEN

       l_sub_comp_tbl  := inv_ebi_sub_comp_tbl();

       FOR i IN 1..p_sub_component_tbl.COUNT LOOP

         IF(p_sub_component_tbl(i).acd_type = 1) THEN

           l_sub_comp_count := l_sub_comp_count + 1;
           l_sub_comp_tbl.EXTEND(1);
           l_sub_comp_tbl(l_sub_comp_count) := p_sub_component_tbl(i);

         ELSIF(p_sub_component_tbl(i).acd_type = 2) THEN

           l_sub_comp_count := l_sub_comp_count + 1;
           l_sub_comp_tbl.EXTEND(1);
           l_sub_comp_tbl(l_sub_comp_count) := p_sub_component_tbl(i);
           l_sub_comp_tbl(l_sub_comp_count).acd_type := 1;

         END IF;

       END LOOP;

       IF(l_sub_comp_tbl IS NOT NULL AND l_sub_comp_tbl.COUNT > 0) THEN
         l_component_item.substitute_component_tbl := l_sub_comp_tbl;
       END IF;

     END IF;
     INV_EBI_UTIL.debug_line('STEP 20: END INV_EBI_CHANGE_ORDER_HELPER.transform_substitute_comp_info STATUS: ' || x_out.output_status.return_status);
     x_component_item  := l_component_item;
   EXCEPTION
     WHEN OTHERS THEN

          x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
          IF (x_out.output_status.msg_data IS NOT NULL) THEN
            x_out.output_status.msg_data      :=  x_out.output_status.msg_data||' ->INV_EBI_CHANGE_ORDER_HELPER.transform_substitute_comp_info ';
          ELSE
            x_out.output_status.msg_data      :=  SQLERRM||'INV_EBI_CHANGE_ORDER_HELPER.transform_substitute_comp_info ';
     END IF;

  END transform_substitute_comp_info;

 /************************************************************************************
  --      API name        : transform_reference_designators
  --      Type            : Private
  --      procedure       : Prepare Reference Designators for Replicate bom
  --      Added this API for Bug 8397083
 ************************************************************************************/

 PROCEDURE transform_ref_desg(
    p_ref_desg_tbl      IN  inv_ebi_ref_desg_tbl
   ,p_component_item    IN  inv_ebi_rev_comp_obj
   ,x_component_item    OUT NOCOPY inv_ebi_rev_comp_obj
   ,x_out               OUT NOCOPY inv_ebi_eco_output_obj
   ) IS
   l_output_status      inv_ebi_output_status;
   l_ref_desg_tbl       inv_ebi_ref_desg_tbl;
   l_component_item     inv_ebi_rev_comp_obj;
   l_ref_desg_count     NUMBER := 0;
 BEGIN

   l_output_status  := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
   x_out            := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);
   INV_EBI_UTIL.debug_line('STEP 10: INSIDE INV_EBI_CHANGE_ORDER_HELPER.transform_ref_desg');
   l_component_item := p_component_item;

   IF(p_ref_desg_tbl IS NOT NULL AND p_ref_desg_tbl.COUNT > 0 ) THEN

     l_ref_desg_tbl  := inv_ebi_ref_desg_tbl();

     FOR i IN 1..p_ref_desg_tbl.COUNT LOOP

       IF(p_ref_desg_tbl(i).acd_type = 1) THEN

         l_ref_desg_count := l_ref_desg_count + 1;
         l_ref_desg_tbl.EXTEND(1);
         l_ref_desg_tbl(l_ref_desg_count) := p_ref_desg_tbl(i);

       ELSIF(p_ref_desg_tbl(i).acd_type = 2) THEN

         l_ref_desg_count  := l_ref_desg_count + 1;
         l_ref_desg_tbl.EXTEND(1);
         l_ref_desg_tbl(l_ref_desg_count) := p_ref_desg_tbl(i);
         l_ref_desg_tbl(l_ref_desg_count).acd_type := 1;

       END IF;

     END LOOP;

     IF(l_ref_desg_tbl IS NOT NULL AND l_ref_desg_tbl.COUNT > 0) THEN
       l_component_item.reference_designator_tbl := l_ref_desg_tbl;
     END IF;

   END IF;
   INV_EBI_UTIL.debug_line('STEP 20: END INV_EBI_CHANGE_ORDER_HELPER.transform_ref_desg STATUS: ' || x_out.output_status.return_status);
   x_component_item  := l_component_item;
  EXCEPTION
    WHEN OTHERS THEN

         x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
         IF (x_out.output_status.msg_data IS NOT NULL) THEN
           x_out.output_status.msg_data      :=  x_out.output_status.msg_data||' ->INV_EBI_CHANGE_ORDER_HELPER.transform_ref_desg ';
         ELSE
           x_out.output_status.msg_data      :=  SQLERRM||'INV_EBI_CHANGE_ORDER_HELPER.transform_ref_desg ';
    END IF;

  END transform_ref_desg;

 /************************************************************************************
   --      API name        : merge_subcomp_refdesg_info
   --      Type            : private
   --      procedure       : Merge substitute components,Reference Designators
   --                        for Replicate bom
   --   Added this API for Bug 8397083
 ************************************************************************************/
 PROCEDURE  merge_subcomp_refdesg_info(
   p_src_component_item   IN  inv_ebi_rev_comp_obj
  ,p_dest_component_item  IN  inv_ebi_rev_comp_obj
  ,x_dest_component_item  OUT NOCOPY inv_ebi_rev_comp_obj
  ,x_out                  OUT NOCOPY inv_ebi_eco_output_obj
  ) IS

    l_output_status         inv_ebi_output_status;
    l_src_ref_desg_tbl      inv_ebi_ref_desg_tbl;
    l_dest_ref_desg_tbl     inv_ebi_ref_desg_tbl;
    l_dest_sub_comp_tbl     inv_ebi_sub_comp_tbl;
    l_src_sub_comp_tbl      inv_ebi_sub_comp_tbl;
    l_src_component_item    inv_ebi_rev_comp_obj;
    l_dest_component_item   inv_ebi_rev_comp_obj;
    l_ref_desg_count        NUMBER := 0;
    l_sub_comp_exists       BOOLEAN;
    l_sub_comp_count        NUMBER :=0;
    l_ref_desg_exists       BOOLEAN;
    l_is_sub_comp_tbl_new   BOOLEAN := FALSE;
    l_is_ref_desg_tbl_new   BOOLEAN := FALSE;

  BEGIN
  l_output_status  := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
  x_out            := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);

  INV_EBI_UTIL.debug_line('STEP 10: INSIDE INV_EBI_CHANGE_ORDER_HELPER.merge_subcomp_refdesg_info');
  l_dest_component_item  := p_dest_component_item;
  l_src_sub_comp_tbl     := p_src_component_item.substitute_component_tbl;
  l_src_ref_desg_tbl     := p_src_component_item.reference_designator_tbl;
  l_dest_sub_comp_tbl    := l_dest_component_item.substitute_component_tbl;
  l_dest_ref_desg_tbl    := l_dest_component_item.reference_designator_tbl;

  IF(l_src_sub_comp_tbl IS NOT NULL AND l_src_sub_comp_tbl.COUNT > 0) THEN
    FOR i IN 1..l_src_sub_comp_tbl.COUNT LOOP
      IF(l_src_sub_comp_tbl(i).acd_type <> 3) THEN

        IF(l_dest_component_item.substitute_component_tbl IS NULL) THEN
          l_dest_sub_comp_tbl :=   inv_ebi_sub_comp_tbl();
          l_dest_sub_comp_tbl.EXTEND(1);
          l_is_sub_comp_tbl_new := TRUE;
        END IF;

        l_sub_comp_exists  := FALSE;

        FOR j IN 1..l_dest_sub_comp_tbl.COUNT LOOP
          IF NOT l_sub_comp_exists THEN
            IF( l_src_sub_comp_tbl(i).substitute_component_name =
                l_dest_sub_comp_tbl(j).substitute_component_name ) THEN

               l_sub_comp_exists  := TRUE;

            END IF;
          END IF;
        END LOOP;

        IF NOT l_sub_comp_exists THEN

          IF NOT l_is_sub_comp_tbl_new THEN
             l_sub_comp_count := l_dest_sub_comp_tbl.COUNT;
             l_sub_comp_count := l_sub_comp_count +1;
             l_dest_sub_comp_tbl.EXTEND(1);
          ELSE
            l_sub_comp_count := l_dest_sub_comp_tbl.COUNT;
            l_is_sub_comp_tbl_new := FALSE;
          END IF;

          l_dest_sub_comp_tbl(l_sub_comp_count) := l_src_sub_comp_tbl(i);
          l_sub_comp_exists := TRUE;

        END IF;
      END IF;
    END LOOP;
  END IF;

  INV_EBI_UTIL.debug_line('STEP 20: AFTER Merging Substitute Components');
  l_dest_component_item.substitute_component_tbl :=  l_dest_sub_comp_tbl;

  IF( l_src_ref_desg_tbl IS NOT NULL AND l_src_ref_desg_tbl.COUNT > 0) THEN
    FOR i IN 1..l_src_ref_desg_tbl.COUNT LOOP
      IF(l_src_ref_desg_tbl(i).acd_type <> 3) THEN

        IF(l_dest_component_item.reference_designator_tbl IS NULL) THEN
          l_dest_ref_desg_tbl :=   inv_ebi_ref_desg_tbl();
          l_dest_ref_desg_tbl.EXTEND(1);
          l_is_ref_desg_tbl_new := TRUE;
        END IF;

        l_ref_desg_exists := FALSE;

        FOR j IN 1..l_dest_ref_desg_tbl.COUNT LOOP
          IF NOT l_ref_desg_exists THEN
            IF( l_dest_ref_desg_tbl(j).reference_designator_name =
                l_src_ref_desg_tbl(i).reference_designator_name ) THEN

               l_ref_desg_exists  := TRUE;
            END IF;
          END IF;
        END LOOP;

        IF NOT l_ref_desg_exists THEN

          IF NOT l_is_ref_desg_tbl_new THEN
            l_ref_desg_count := l_dest_ref_desg_tbl.COUNT;
            l_ref_desg_count := l_ref_desg_count +1 ;
            l_dest_ref_desg_tbl.EXTEND(1);
          ELSE
            l_ref_desg_count := l_dest_ref_desg_tbl.COUNT;
            l_is_ref_desg_tbl_new := FALSE;
          END IF;

          l_dest_ref_desg_tbl(l_ref_desg_count) := l_src_ref_desg_tbl(i);
          l_ref_desg_exists := TRUE;

        END IF;
      END IF;
    END LOOP;
  END IF;
  INV_EBI_UTIL.debug_line('STEP 30: AFTER Merging Reference Designators');
  l_dest_component_item.reference_designator_tbl :=  l_dest_ref_desg_tbl;
  INV_EBI_UTIL.debug_line('STEP 40: END  merge_subcomp_refdesg_info STATUS: ' || x_out.output_status.return_status);
  x_dest_component_item := l_dest_component_item;
 EXCEPTION

   WHEN OTHERS THEN
        x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
        IF (x_out.output_status.msg_data IS NOT NULL) THEN
          x_out.output_status.msg_data      :=  x_out.output_status.msg_data||' ->INV_EBI_CHANGE_ORDER_HELPER.merge_subcomp_refdesg_info ';
        ELSE
          x_out.output_status.msg_data      :=  SQLERRM||'INV_EBI_CHANGE_ORDER_HELPER.merge_subcomp_refdesg_info ';
  END IF;
  END merge_subcomp_refdesg_info;


 /************************************************************************************
  --      API name        : transform_replicate_bom_info
  --      Type            : Public
  --      procedure       : Prepare component,substitute components,Reference Designators
  --                        for Replicate bom
  -- Added this API for Bug 8397083
 ************************************************************************************/
 PROCEDURE transform_replicate_bom_info(
     p_eco_obj_list      IN  inv_ebi_eco_obj_tbl
    ,p_revised_item_obj  IN  inv_ebi_revised_item_obj
    ,x_revised_item_obj  OUT NOCOPY inv_ebi_revised_item_obj
    ,x_out               OUT NOCOPY inv_ebi_eco_output_obj
    ) IS

    l_output_status         inv_ebi_output_status;
    l_comp_item_tbl         inv_ebi_rev_comp_tbl;
    l_revised_item_obj      inv_ebi_revised_item_obj;
    l_comp_exists           BOOLEAN;
    l_comp_count            NUMBER := 0;
    l_config_view_scope     VARCHAR2(30) := 'ALL';
    l_config_impl_scope     VARCHAR2(30) := 'ALL';
    l_as_of_date            DATE;
    l_effectivity_date      DATE;
    l_inventory_item_id     NUMBER;
    l_organization_id       NUMBER;
    l_rev_item_eff_date     DATE;
    l_is_comp_tbl_new       BOOLEAN := FALSE;

  BEGIN

   l_output_status  := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
   x_out            := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);

   l_revised_item_obj := p_revised_item_obj;
   l_comp_item_tbl    := inv_ebi_rev_comp_tbl();
   INV_EBI_UTIL.debug_line('STEP 10: INSIDE INV_EBI_CHANGE_ORDER_HELPER.transform_replicate_bom_info');
   FOR i IN 1..p_eco_obj_list.COUNT LOOP
     IF(p_eco_obj_list(i).eco_revised_item_type IS NOT NULL AND p_eco_obj_list(i).eco_revised_item_type.COUNT > 0) THEN

       FOR j IN 1..p_eco_obj_list(i).eco_revised_item_type.COUNT LOOP
         INV_EBI_UTIL.debug_line('STEP 20: ITEM NAME: '|| l_revised_item_obj.orignal_bom_reference.item_name ||
	                                  'ORG CODE:  '|| l_revised_item_obj.orignal_bom_reference.ORGANIZATION_CODE);
         IF( p_eco_obj_list(i).eco_revised_item_type(j).revised_item_name = l_revised_item_obj.orignal_bom_reference.item_name
           AND p_eco_obj_list(i).eco_change_order_type.organization_code  = l_revised_item_obj.orignal_bom_reference.ORGANIZATION_CODE) THEN
           IF(p_eco_obj_list(i).eco_revised_item_type(j).component_item_tbl IS NOT NULL AND p_eco_obj_list(i).eco_revised_item_type(j).component_item_tbl.COUNT > 0) THEN


             l_comp_item_tbl := p_eco_obj_list(i).eco_revised_item_type(j).component_item_tbl;


             l_config_view_scope := INV_EBI_UTIL.get_config_param_value (
                                       p_config_tbl         =>  p_eco_obj_list(i).name_value_tbl
                                      ,p_config_param_name  => 'REPLICATE_BOM_VIEW_SCOPE'
                                    );


             l_config_impl_scope := INV_EBI_UTIL.get_config_param_value (
                                        p_config_tbl         => p_eco_obj_list(i).name_value_tbl
                                       ,p_config_param_name  => 'REPLICATE_BOM_IMPLEMENTATION_SCOPE'
                                    );
             l_as_of_date := l_revised_item_obj.orignal_bom_reference.as_of_date;

             l_organization_id    := INV_EBI_ITEM_HELPER.get_organization_id (
                                        p_organization_code => p_eco_obj_list(i).eco_change_order_type.organization_code
                                     );

             l_inventory_item_id  := INV_EBI_ITEM_HELPER.get_inventory_item_id(
                                        p_organization_id  => l_organization_id
                                       ,p_item_number      => p_eco_obj_list(i).eco_revised_item_type(j).revised_item_name
                                     ) ;

             l_effectivity_date  :=  get_latest_effectivity_date(
                                       p_inventory_item_id  =>  l_inventory_item_id,
                                       p_organization_id    =>  l_organization_id
                                     );
             INV_EBI_UTIL.debug_line('STEP 30: ORG ID: '|| l_organization_id || 'INV ITEM ID: ' || l_inventory_item_id || 'EFFECTIVITY DATE: '|| l_effectivity_date);
             IF(l_effectivity_date < SYSDATE ) THEN
               l_effectivity_date := SYSDATE;
             END IF;

             IF( p_eco_obj_list(i).eco_revised_item_type(j).start_effective_date IS NULL
                 OR p_eco_obj_list(i).eco_revised_item_type(j).start_effective_date = fnd_api.g_miss_date
                 OR p_eco_obj_list(i).eco_revised_item_type(j).start_effective_date < l_effectivity_date)
             THEN
               l_rev_item_eff_date  :=  l_effectivity_date;
             ELSE
               l_rev_item_eff_date  :=  p_eco_obj_list(i).eco_revised_item_type(j).start_effective_date;
             END IF;

             IF (l_as_of_date IS NULL OR l_as_of_date = fnd_api.g_miss_date) THEN
               l_as_of_date := SYSDATE;
             END IF;

           END IF;
         END IF;
       END LOOP;
     END IF;
   END LOOP;

   IF(l_comp_item_tbl IS NOT NULL AND l_comp_item_tbl.COUNT > 0) THEN
     FOR i IN 1..l_comp_item_tbl.COUNT LOOP
        IF(l_comp_item_tbl(i).acd_type <> 3) THEN

          IF(l_revised_item_obj.component_item_tbl IS NULL) THEN
            l_revised_item_obj.component_item_tbl := inv_ebi_rev_comp_tbl();
            l_revised_item_obj.component_item_tbl.EXTEND(1);
            l_is_comp_tbl_new := TRUE;
          END IF;

          l_comp_exists := FALSE;

          FOR j IN 1..l_revised_item_obj.component_item_tbl.COUNT LOOP

            IF NOT l_comp_exists THEN

              IF( l_revised_item_obj.component_item_tbl(j).component_item_name  = l_comp_item_tbl(i).component_item_name
                  AND l_revised_item_obj.component_item_tbl(j).operation_sequence_number = l_comp_item_tbl(i).operation_sequence_number
                ) THEN

                l_comp_exists := TRUE;

                INV_EBI_UTIL.debug_line('STEP 40: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.merge_subcomp_refdesg_info');
		INV_EBI_UTIL.debug_line('STEP 50: COMPONENT ITEM NAME '|| l_comp_item_tbl(i).component_item_name);
                merge_subcomp_refdesg_info(
                  p_src_component_item   =>  l_comp_item_tbl(i)
                 ,p_dest_component_item  =>  l_revised_item_obj.component_item_tbl(j)
                 ,x_dest_component_item  =>  l_revised_item_obj.component_item_tbl(j)
                 ,x_out                  =>  x_out
                );
                INV_EBI_UTIL.debug_line('STEP 60: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.merge_subcomp_refdesg_info STATUS: '|| x_out.output_status.return_status);

                IF(x_out.output_status.return_status <> fnd_api.g_ret_sts_success) THEN
                  RAISE FND_API.g_exc_unexpected_error;
                END IF;
              END IF;
            END IF;
          END LOOP;

          IF NOT l_comp_exists THEN
            IF(l_config_impl_scope = G_IMPLEMENT_SCOPE_UNIMPLEMENT OR l_config_impl_scope = G_VIEW_SCOPE_ALL) THEN

              IF( (     l_config_view_scope = G_VIEW_SCOPE_CURRENT
                    AND l_rev_item_eff_date   <= l_as_of_date
                    AND (    l_comp_item_tbl(i).disable_date  > l_as_of_date
                          OR l_comp_item_tbl(i).disable_date  IS NULL
                          OR l_comp_item_tbl(i).disable_date = fnd_api.g_miss_date
                        )
                   )
                   OR ( l_config_view_scope = G_VIEW_SCOPE_CURR_FUTURE
                        AND (    l_comp_item_tbl(i).disable_date    > l_as_of_date
                              OR l_comp_item_tbl(i).disable_date IS NULL
                              OR l_comp_item_tbl(i).disable_date = fnd_api.g_miss_date
                            )
                      )
                   OR( l_config_view_scope = G_VIEW_SCOPE_ALL )

                ) THEN


                IF(l_comp_item_tbl(i).acd_type = 1 ) THEN

                  IF NOT l_is_comp_tbl_new THEN
                    l_comp_count := l_revised_item_obj.component_item_tbl.COUNT;
                    l_revised_item_obj.component_item_tbl.EXTEND(1);
                    l_comp_count := l_comp_count + 1;

                   ELSE
                    l_comp_count := l_revised_item_obj.component_item_tbl.COUNT;
                    l_is_comp_tbl_new := FALSE;
                   END IF;

                   l_revised_item_obj.component_item_tbl(l_comp_count) := l_comp_item_tbl(i);
                   l_comp_exists := TRUE;


                ELSIF(l_comp_item_tbl(i).acd_type = 2) THEN

                  IF NOT l_is_comp_tbl_new THEN
                    l_comp_count := l_revised_item_obj.component_item_tbl.COUNT;
                    l_revised_item_obj.component_item_tbl.EXTEND(1);
                    l_comp_count := l_comp_count + 1;

                  ELSE
                    l_comp_count := l_revised_item_obj.component_item_tbl.COUNT;
                    l_is_comp_tbl_new := FALSE;
                  END IF;

                  l_revised_item_obj.component_item_tbl(l_comp_count) := l_comp_item_tbl(i);
                  l_revised_item_obj.component_item_tbl(l_comp_count).acd_type := 1;
                  l_revised_item_obj.component_item_tbl(l_comp_count).substitute_component_tbl := NULL;
                  l_revised_item_obj.component_item_tbl(l_comp_count).reference_designator_tbl := NULL;
                  INV_EBI_UTIL.debug_line('STEP 70: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.transform_substitute_comp_info');
                  transform_substitute_comp_info(
                     p_sub_component_tbl    => l_comp_item_tbl(i).substitute_component_tbl
                    ,p_component_item       => l_revised_item_obj.component_item_tbl(l_comp_count)
                    ,x_component_item       => l_revised_item_obj.component_item_tbl(l_comp_count)
                    ,x_out                  => x_out
                  );
                  INV_EBI_UTIL.debug_line('STEP 80: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.transform_substitute_comp_info STATUS: ' || x_out.output_status.return_status);
                  IF(x_out.output_status.return_status <> fnd_api.g_ret_sts_success) THEN
                    RAISE FND_API.g_exc_unexpected_error;
                  END IF;
                  INV_EBI_UTIL.debug_line('STEP 90: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.transform_ref_desg');
                  transform_ref_desg(
                     p_ref_desg_tbl      => l_comp_item_tbl(i).reference_designator_tbl
                    ,p_component_item    => l_revised_item_obj.component_item_tbl(i)
                    ,x_component_item    => l_revised_item_obj.component_item_tbl(i)
                    ,x_out               => x_out
                   );
                  INV_EBI_UTIL.debug_line('STEP 100: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.transform_ref_desg STATUS: '|| x_out.output_status.return_status);
                  IF(x_out.output_status.return_status <> fnd_api.g_ret_sts_success) THEN
                    RAISE FND_API.g_exc_unexpected_error;
                  END IF;
                  l_comp_exists := TRUE;
                END IF;
              END IF;
            END IF;
          END IF;
       END IF;
     END LOOP;
   END IF;
   x_revised_item_obj := l_revised_item_obj;
   INV_EBI_UTIL.debug_line('STEP 110: END INV_EBI_CHANGE_ORDER_HELPER.transform_replicate_bom_info STATUS:  '|| x_out.output_status.return_status);
 EXCEPTION
   WHEN FND_API.g_exc_unexpected_error THEN
     x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;

     IF(x_out.output_status.msg_data IS NULL) THEN
       fnd_msg_pub.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count   => x_out.output_status.msg_count
        ,p_data    => x_out.output_status.msg_data
      );
     END IF;
   WHEN OTHERS THEN

     x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
     IF (x_out.output_status.msg_data IS NOT NULL) THEN
       x_out.output_status.msg_data      :=  x_out.output_status.msg_data||' ->INV_EBI_CHANGE_ORDER_HELPER.transform_replicate_bom_info ';
     ELSE
       x_out.output_status.msg_data      :=  SQLERRM||'INV_EBI_CHANGE_ORDER_HELPER.transform_replicate_bom_info ';
     END IF;
 END transform_replicate_bom_info;
/************************************************************************************
 --      API name        : prepare_substitute_components
 --      Type            : Private
 --      Function        : Prepare substitute components for Replicate bom
 ************************************************************************************/
 PROCEDURE prepare_substitute_components(
    p_component_item       IN  inv_ebi_rev_comp_obj
   ,p_from_sequence_id     IN  NUMBER
   ,p_reference_org_id     IN  NUMBER
   ,x_component_item       OUT NOCOPY  inv_ebi_rev_comp_obj
   ,x_out                  OUT NOCOPY  inv_ebi_eco_output_obj
 ) IS

   CURSOR c_comp_sequence_id
   IS
   SELECT
     bic.component_sequence_id
   FROM
     bom_inventory_components bic,
     mtl_system_items_kfv it
   WHERE
     bic.bill_sequence_id = p_from_sequence_id
     AND bic.component_item_id = it.inventory_item_id
     AND it.organization_id = p_reference_org_id
     AND it.concatenated_segments = p_component_item.component_item_name;

    CURSOR c_copied_substitute_comps (p_component_sequence_id IN NUMBER)
    IS
      SELECT
        sc.substitute_component_id,
        it.concatenated_segments substitute_component_name
      FROM
        bom_substitute_components sc,
        mtl_system_items_kfv it
      WHERE
        sc.substitute_component_id = it.inventory_item_id
        AND it.organization_id = p_reference_org_id
        AND sc.component_sequence_id = p_component_sequence_id
        AND NVL(sc.acd_type,1) = 1; --Only added components are taken

    l_copied_substitute_comp c_copied_substitute_comps%ROWTYPE;

   CURSOR c_merged_substitute_comp (
     p_new_substitute_comp       IN  inv_ebi_sub_comp_obj
    ,p_component_sequence_id     IN NUMBER
    ,p_substitute_component_name IN VARCHAR2
   ) IS
     SELECT
       DECODE(p_new_substitute_comp ,NULL ,NVL(sc.acd_type,1)           ,DECODE(p_new_substitute_comp.acd_type
              ,fnd_api.g_miss_num  ,NVL(sc.acd_type,1)           ,p_new_substitute_comp.acd_type))                  acd_type
      ,DECODE(p_new_substitute_comp ,NULL ,sc.substitute_item_quantity  ,DECODE(p_new_substitute_comp.substitute_item_quantity
              ,fnd_api.g_miss_num  ,sc.substitute_item_quantity  ,p_new_substitute_comp.substitute_item_quantity))  substitute_item_quantity
      ,DECODE(p_new_substitute_comp ,NULL ,sc.attribute_category        ,DECODE(p_new_substitute_comp.attribute_category
              ,fnd_api.g_miss_char ,sc.attribute_category        ,p_new_substitute_comp.attribute_category ))       attribute_category
      ,DECODE(p_new_substitute_comp ,NULL ,sc.attribute1                ,DECODE(p_new_substitute_comp.attribute1
              ,fnd_api.g_miss_char ,sc.attribute1                ,p_new_substitute_comp.attribute1  ))              attribute1
      ,DECODE(p_new_substitute_comp ,NULL ,sc.attribute2                ,DECODE(p_new_substitute_comp.attribute2
              ,fnd_api.g_miss_char ,sc.attribute2                ,p_new_substitute_comp.attribute2  ))              attribute2
      ,DECODE(p_new_substitute_comp ,NULL ,sc.attribute3                ,DECODE(p_new_substitute_comp.attribute3
              ,fnd_api.g_miss_char ,sc.attribute3                ,p_new_substitute_comp.attribute3  ))              attribute3
      ,DECODE(p_new_substitute_comp ,NULL ,sc.attribute4                ,DECODE(p_new_substitute_comp.attribute4
              ,fnd_api.g_miss_char ,sc.attribute4                ,p_new_substitute_comp.attribute4  ))              attribute4
      ,DECODE(p_new_substitute_comp ,NULL ,sc.attribute5                ,DECODE(p_new_substitute_comp.attribute5
              ,fnd_api.g_miss_char ,sc.attribute5                ,p_new_substitute_comp.attribute5  ))              attribute5
      ,DECODE(p_new_substitute_comp ,NULL ,sc.attribute6                ,DECODE(p_new_substitute_comp.attribute6
              ,fnd_api.g_miss_char ,sc.attribute6                ,p_new_substitute_comp.attribute6  ))              attribute6
      ,DECODE(p_new_substitute_comp ,NULL ,sc.attribute7                ,DECODE(p_new_substitute_comp.attribute7
              ,fnd_api.g_miss_char ,sc.attribute7                ,p_new_substitute_comp.attribute7  ))              attribute7
      ,DECODE(p_new_substitute_comp ,NULL ,sc.attribute8                ,DECODE(p_new_substitute_comp.attribute8
              ,fnd_api.g_miss_char ,sc.attribute8                ,p_new_substitute_comp.attribute8  ))              attribute8
      ,DECODE(p_new_substitute_comp ,NULL ,sc.attribute9                ,DECODE(p_new_substitute_comp.attribute9
              ,fnd_api.g_miss_char ,sc.attribute9                ,p_new_substitute_comp.attribute9  ))              attribute9
      ,DECODE(p_new_substitute_comp ,NULL ,sc.attribute10               ,DECODE(p_new_substitute_comp.attribute10
              ,fnd_api.g_miss_char ,sc.attribute10               ,p_new_substitute_comp.attribute10 ))              attribute10
      ,DECODE(p_new_substitute_comp ,NULL ,sc.attribute11               ,DECODE(p_new_substitute_comp.attribute11
              ,fnd_api.g_miss_char ,sc.attribute11               ,p_new_substitute_comp.attribute11 ))              attribute11
      ,DECODE(p_new_substitute_comp ,NULL ,sc.attribute12               ,DECODE(p_new_substitute_comp.attribute12
              ,fnd_api.g_miss_char ,sc.attribute12               ,p_new_substitute_comp.attribute12 ))              attribute12
      ,DECODE(p_new_substitute_comp ,NULL ,sc.attribute13               ,DECODE(p_new_substitute_comp.attribute13
              ,fnd_api.g_miss_char ,sc.attribute13               ,p_new_substitute_comp.attribute13 ))              attribute13
      ,DECODE(p_new_substitute_comp ,NULL ,sc.attribute14               ,DECODE(p_new_substitute_comp.attribute14
              ,fnd_api.g_miss_char ,sc.attribute14               ,p_new_substitute_comp.attribute14 ))              attribute14
      ,DECODE(p_new_substitute_comp ,NULL ,sc.attribute15               ,DECODE(p_new_substitute_comp.attribute15
              ,fnd_api.g_miss_char ,sc.attribute15               ,p_new_substitute_comp.attribute15 ))              attribute15
      ,DECODE(p_new_substitute_comp ,NULL ,sc.original_system_reference ,DECODE(p_new_substitute_comp.original_system_reference
              ,fnd_api.g_miss_char ,sc.original_system_reference ,p_new_substitute_comp.original_system_reference)) original_system_reference
      ,DECODE(p_new_substitute_comp ,NULL ,sc.enforce_int_requirements  ,DECODE(p_new_substitute_comp.enforce_int_requirements
              ,fnd_api.g_miss_num  ,sc.enforce_int_requirements  ,p_new_substitute_comp.enforce_int_requirements))  enforce_int_requirements
      ,DECODE(p_new_substitute_comp ,NULL ,NULL                         ,p_new_substitute_comp.start_effective_date)            start_effective_date
      ,DECODE(p_new_substitute_comp ,NULL ,NULL                         ,p_new_substitute_comp.new_substitute_component_name )  new_substitute_component_name
      ,DECODE(p_new_substitute_comp ,NULL ,NULL                         ,p_new_substitute_comp.from_end_item_unit_number)       from_end_item_unit_number
      ,DECODE(p_new_substitute_comp ,NULL ,NULL                         ,p_new_substitute_comp.new_routing_revision)            new_routing_revision
      ,DECODE(p_new_substitute_comp ,NULL ,NULL                         ,p_new_substitute_comp.return_status)                   return_status
      ,DECODE(p_new_substitute_comp ,NULL ,NULL                         ,p_new_substitute_comp.inverse_quantity)                inverse_quantity
      ,DECODE(p_new_substitute_comp ,NULL ,NULL                         ,p_new_substitute_comp.row_identifier )                 row_identifier
      ,DECODE(p_new_substitute_comp ,NULL ,NULL                         ,p_new_substitute_comp.program_id)                      program_id
     FROM
       bom_substitute_components sc,
       mtl_system_items_kfv it
     WHERE
       sc.substitute_component_id = it.inventory_item_id AND
       it.organization_id       = p_reference_org_id AND
       it.concatenated_segments = p_substitute_component_name AND
       sc.component_sequence_id = p_component_sequence_id;

     l_component_sequence_id NUMBER;
     i                       NUMBER := 0;
     l_component_item        inv_ebi_rev_comp_obj;
     l_Found                 BOOLEAN;
     l_merged_subst_comp     c_Merged_Substitute_Comp%ROWTYPE;
     l_substitute_comp_tbl   inv_ebi_sub_comp_tbl;
     l_sub_comp_count        NUMBER := 1;
     l_output_status         inv_ebi_output_status;
 BEGIN
   l_output_status := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
   x_out           := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);
   INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.prepare_substitute_components');
   OPEN c_comp_sequence_id;
   FETCH c_comp_sequence_id INTO l_component_sequence_id;
   CLOSE c_comp_sequence_id;

   l_component_item := p_component_item;

   IF p_component_item.substitute_component_tbl IS NOT NULL THEN
     l_substitute_comp_tbl := inv_ebi_sub_comp_tbl();
     FOR i IN 1..p_component_item.substitute_component_tbl.COUNT LOOP
       IF p_component_item.substitute_component_tbl(i).transaction_type <> ENG_GLOBALS.g_opr_delete THEN
         l_substitute_comp_tbl.EXTEND(1);
         l_substitute_comp_tbl(l_sub_comp_count) := p_component_item.substitute_component_tbl(i);
         l_sub_comp_count := l_sub_comp_count + 1;
       END IF;
     END LOOP;
     l_component_item.substitute_component_tbl := l_Substitute_Comp_Tbl;
   END IF;


   OPEN c_copied_substitute_comps(l_Component_Sequence_Id);
   LOOP
     FETCH c_copied_substitute_comps INTO l_copied_substitute_comp;
     EXIT WHEN c_copied_substitute_comps%NOTFOUND;
       l_Found := FALSE;
       IF p_component_item.substitute_component_tbl IS NOT NULL THEN
         FOR i IN 1..p_component_item.substitute_component_tbl.COUNT LOOP
	 INV_EBI_UTIL.debug_line('STEP 20: SUBSTITUTE COMPONENT NAME: '|| p_component_item.substitute_component_tbl(i).substitute_component_name);
           IF l_copied_substitute_comp.substitute_component_name = p_component_item.substitute_component_tbl(i).substitute_component_name THEN
             l_Found := TRUE;
           END IF;
         END LOOP;
       END IF;

       IF NOT l_Found THEN
         OPEN c_merged_substitute_comp(p_new_substitute_comp       => NULL
                                      ,p_substitute_component_name => l_copied_substitute_comp.substitute_component_name
                                      ,p_component_sequence_id     => l_Component_Sequence_Id
                                      );
         FETCH  c_merged_substitute_comp INTO l_merged_subst_comp;
         IF l_component_item.substitute_component_tbl IS NULL THEN
           l_component_item.substitute_component_tbl := inv_ebi_sub_comp_tbl();
         END IF;

         l_component_item.substitute_component_tbl.EXTEND(1);
         l_component_item.substitute_component_tbl(l_component_item.substitute_component_tbl.COUNT) := inv_ebi_sub_comp_obj(
                                                           l_component_item.start_effective_date
                                                          ,l_copied_substitute_comp.substitute_component_name
                                                          ,l_merged_subst_comp.new_substitute_component_name
                                                          ,l_merged_subst_comp.acd_type
                                                          ,l_merged_subst_comp.substitute_item_quantity
                                                          ,l_merged_subst_comp.attribute_category
                                                          ,l_merged_subst_comp.attribute1
                                                          ,l_merged_subst_comp.attribute2
                                                          ,l_merged_subst_comp.attribute3
                                                          ,l_merged_subst_comp.attribute4
                                                          ,l_merged_subst_comp.attribute5
                                                          ,l_merged_subst_comp.attribute6
                                                          ,l_merged_subst_comp.attribute7
                                                          ,l_merged_subst_comp.attribute8
                                                          ,l_merged_subst_comp.attribute9
                                                          ,l_merged_subst_comp.attribute10
                                                          ,l_merged_subst_comp.attribute11
                                                          ,l_merged_subst_comp.attribute12
                                                          ,l_merged_subst_comp.attribute13
                                                          ,l_merged_subst_comp.attribute14
                                                          ,l_merged_subst_comp.attribute15
                                                          ,l_merged_subst_comp.original_system_reference
                                                          ,l_merged_subst_comp.from_end_item_unit_number
                                                          ,l_merged_subst_comp.new_routing_revision
                                                          ,l_merged_subst_comp.enforce_int_requirements
                                                          ,l_merged_subst_comp.return_status
                                                          ,ENG_GLOBALS.g_opr_create
                                                          ,l_merged_subst_comp.row_identifier
                                                          ,l_merged_subst_comp.inverse_quantity
                                                          ,l_Merged_Subst_Comp.program_id
                                                          ,NULL);
           CLOSE c_merged_substitute_comp;
       END IF;
   END LOOP;
   CLOSE c_copied_substitute_comps;


   IF l_component_item.substitute_component_tbl IS NOT NULL THEN
     FOR i IN 1..l_component_item.substitute_component_tbl.COUNT LOOP
       IF l_component_item.substitute_component_tbl(i).transaction_type = ENG_GLOBALS.g_opr_update THEN
         OPEN c_merged_substitute_comp(p_new_substitute_comp       => l_component_item.substitute_component_tbl(i)
                                      ,p_substitute_component_name => l_component_item.substitute_component_tbl(i).substitute_component_name
                                      ,p_Component_Sequence_Id     => l_Component_Sequence_Id);
         FETCH  c_merged_substitute_comp INTO l_Merged_Subst_Comp;
         IF c_merged_substitute_comp%FOUND THEN
           l_component_item.substitute_component_tbl(i) := inv_ebi_sub_comp_obj(
                                                           l_merged_subst_comp.start_effective_date
                                                          ,l_component_item.substitute_component_tbl(i).substitute_component_name
                                                          ,l_merged_subst_comp.new_substitute_component_name
                                                          ,l_merged_subst_comp.acd_type
                                                          ,l_merged_subst_comp.substitute_item_quantity
                                                          ,l_merged_subst_comp.attribute_category
                                                          ,l_merged_subst_comp.attribute1
                                                          ,l_merged_subst_comp.attribute2
                                                          ,l_merged_subst_comp.attribute3
                                                          ,l_merged_subst_comp.attribute4
                                                          ,l_merged_subst_comp.attribute5
                                                          ,l_merged_subst_comp.attribute6
                                                          ,l_merged_subst_comp.attribute7
                                                          ,l_merged_subst_comp.attribute8
                                                          ,l_merged_subst_comp.attribute9
                                                          ,l_merged_subst_comp.attribute10
                                                          ,l_merged_subst_comp.attribute11
                                                          ,l_merged_subst_comp.attribute12
                                                          ,l_merged_subst_comp.attribute13
                                                          ,l_merged_subst_comp.attribute14
                                                          ,l_merged_subst_comp.attribute15
                                                          ,l_merged_subst_comp.original_system_reference
                                                          ,l_merged_subst_comp.from_end_item_unit_number
                                                          ,l_merged_subst_comp.new_routing_revision
                                                          ,l_merged_subst_comp.enforce_int_requirements
                                                          ,l_merged_subst_comp.return_status
                                                          ,ENG_GLOBALS.g_opr_create
                                                          ,l_merged_subst_comp.row_identifier
                                                          ,l_merged_subst_comp.inverse_quantity
                                                          ,l_merged_subst_comp.program_id
                                                          ,NULL);
        END IF;
           CLOSE c_merged_substitute_comp;
       END IF;
     END LOOP;
   END IF;

   x_component_item := l_component_item;
   INV_EBI_UTIL.debug_line('STEP 30: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.prepare_substitute_components STATUS :  '|| x_out.output_status.return_status );

 EXCEPTION
   WHEN FND_API.g_exc_unexpected_error THEN
     IF c_Merged_Substitute_Comp%ISOPEN THEN
       CLOSE c_merged_substitute_comp;
     END IF;
     IF c_copied_substitute_comps%ISOPEN THEN
       CLOSE c_copied_substitute_comps;
     END IF;
     x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;
     IF(x_out.output_status.msg_data IS NULL) THEN
       fnd_msg_pub.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count   => x_out.output_status.msg_count
        ,p_data    => x_out.output_status.msg_data
      );
     END IF;
   WHEN OTHERS THEN
     IF c_merged_substitute_comp%ISOPEN THEN
       CLOSE c_merged_substitute_comp;
     END IF;
     IF c_copied_substitute_comps%ISOPEN THEN
       CLOSE c_copied_substitute_comps;
     END IF;
     x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
     IF (x_out.output_status.msg_data IS NOT NULL) THEN
       x_out.output_status.msg_data      :=  x_out.output_status.msg_data||' ->INV_EBI_CHANGE_ORDER_HELPER.prepare_substitute_components ';
     ELSE
       x_out.output_status.msg_data      :=  SQLERRM||'INV_EBI_CHANGE_ORDER_HELPER.prepare_substitute_components ';
     END IF;
 END prepare_substitute_components;

/************************************************************************************
 --      API name        : prepare_reference_designators
 --      Type            : Private
 --      Function        : Prepare reference_designators for Replicate bom
 ************************************************************************************/
 PROCEDURE prepare_reference_designators(
    p_component_item       IN  inv_ebi_rev_comp_obj
   ,p_from_sequence_id     IN  NUMBER
   ,p_reference_org_id     IN  NUMBER
   ,x_component_item       OUT NOCOPY  inv_ebi_rev_comp_obj
   ,x_out                  OUT NOCOPY  inv_ebi_eco_output_obj
 ) IS

   CURSOR c_comp_sequence_id
   IS
   SELECT
     bic.component_sequence_id
   FROM
     bom_inventory_components bic,
     mtl_system_items_kfv it
   WHERE
     bic.bill_sequence_id = p_from_sequence_id
     AND bic.component_item_id = it.inventory_item_id
     AND it.organization_id = p_reference_org_id
     AND it.concatenated_segments = p_component_item.component_item_name;

    CURSOR c_copied_ref_designators (p_component_sequence_id IN NUMBER)
    IS
      SELECT
        component_reference_designator reference_designator_name
      FROM
        bom_reference_designators
      WHERE
        component_sequence_id = p_component_sequence_id
        AND NVL(acd_type,1) = 1; --Only added components are taken


   CURSOR c_merged_ref_designators (
     p_new_ref_designator             IN  inv_ebi_ref_desg_obj
    ,p_component_sequence_id          IN  NUMBER
    ,p_ref_designator_name            IN  VARCHAR2
   ) IS
     SELECT
       DECODE(p_new_ref_designator ,NULL ,NVL(acd_type,1)           ,DECODE(p_new_ref_designator.acd_type
              ,fnd_api.g_miss_num  ,NVL(acd_type,1)           ,p_new_ref_designator.acd_type))                  acd_type
      ,DECODE(p_new_ref_designator ,NULL ,attribute_category        ,DECODE(p_new_ref_designator.attribute_category
              ,fnd_api.g_miss_char ,attribute_category        ,p_new_ref_designator.attribute_category ))       attribute_category
      ,DECODE(p_new_ref_designator ,NULL ,attribute1                ,DECODE(p_new_ref_designator.attribute1
              ,fnd_api.g_miss_char ,attribute1                ,p_new_ref_designator.attribute1  ))              attribute1
      ,DECODE(p_new_ref_designator ,NULL ,attribute2                ,DECODE(p_new_ref_designator.attribute2
              ,fnd_api.g_miss_char ,attribute2                ,p_new_ref_designator.attribute2  ))              attribute2
      ,DECODE(p_new_ref_designator ,NULL ,attribute3                ,DECODE(p_new_ref_designator.attribute3
              ,fnd_api.g_miss_char ,attribute3                ,p_new_ref_designator.attribute3  ))              attribute3
      ,DECODE(p_new_ref_designator ,NULL ,attribute4                ,DECODE(p_new_ref_designator.attribute4
              ,fnd_api.g_miss_char ,attribute4                ,p_new_ref_designator.attribute4  ))              attribute4
      ,DECODE(p_new_ref_designator ,NULL ,attribute5                ,DECODE(p_new_ref_designator.attribute5
              ,fnd_api.g_miss_char ,attribute5                ,p_new_ref_designator.attribute5  ))              attribute5
      ,DECODE(p_new_ref_designator ,NULL ,attribute6                ,DECODE(p_new_ref_designator.attribute6
              ,fnd_api.g_miss_char ,attribute6                ,p_new_ref_designator.attribute6  ))              attribute6
      ,DECODE(p_new_ref_designator ,NULL ,attribute7                ,DECODE(p_new_ref_designator.attribute7
              ,fnd_api.g_miss_char ,attribute7                ,p_new_ref_designator.attribute7  ))              attribute7
      ,DECODE(p_new_ref_designator ,NULL ,attribute8                ,DECODE(p_new_ref_designator.attribute8
              ,fnd_api.g_miss_char ,attribute8                ,p_new_ref_designator.attribute8  ))              attribute8
      ,DECODE(p_new_ref_designator ,NULL ,attribute9                ,DECODE(p_new_ref_designator.attribute9
              ,fnd_api.g_miss_char ,attribute9                ,p_new_ref_designator.attribute9  ))              attribute9
      ,DECODE(p_new_ref_designator ,NULL ,attribute10               ,DECODE(p_new_ref_designator.attribute10
              ,fnd_api.g_miss_char ,attribute10               ,p_new_ref_designator.attribute10 ))              attribute10
      ,DECODE(p_new_ref_designator ,NULL ,attribute11               ,DECODE(p_new_ref_designator.attribute11
              ,fnd_api.g_miss_char ,attribute11               ,p_new_ref_designator.attribute11 ))              attribute11
      ,DECODE(p_new_ref_designator ,NULL ,attribute12               ,DECODE(p_new_ref_designator.attribute12
              ,fnd_api.g_miss_char ,attribute12               ,p_new_ref_designator.attribute12 ))              attribute12
      ,DECODE(p_new_ref_designator ,NULL ,attribute13               ,DECODE(p_new_ref_designator.attribute13
              ,fnd_api.g_miss_char ,attribute13               ,p_new_ref_designator.attribute13 ))              attribute13
      ,DECODE(p_new_ref_designator ,NULL ,attribute14               ,DECODE(p_new_ref_designator.attribute14
              ,fnd_api.g_miss_char ,attribute14               ,p_new_ref_designator.attribute14 ))              attribute14
      ,DECODE(p_new_ref_designator ,NULL ,attribute15               ,DECODE(p_new_ref_designator.attribute15
              ,fnd_api.g_miss_char ,attribute15               ,p_new_ref_designator.attribute15 ))              attribute15
      ,DECODE(p_new_ref_designator ,NULL ,original_system_reference ,DECODE(p_new_ref_designator.original_system_reference
              ,fnd_api.g_miss_char ,original_system_reference ,p_new_ref_designator.original_system_reference)) original_system_reference
      ,DECODE(p_new_ref_designator ,NULL ,ref_designator_comment    ,DECODE(p_new_ref_designator.ref_designator_comment
              ,fnd_api.g_miss_char ,ref_designator_comment    ,p_new_ref_designator.ref_designator_comment ))   ref_designator_comment
      ,DECODE(p_new_ref_designator ,NULL ,NULL                      ,p_new_ref_designator.start_effective_date)            start_effective_date
      ,DECODE(p_new_ref_designator ,NULL ,NULL                      ,p_new_ref_designator.new_reference_designator )       new_reference_designator
      ,DECODE(p_new_ref_designator ,NULL ,NULL                      ,p_new_ref_designator.from_end_item_unit_number)       from_end_item_unit_number
      ,DECODE(p_new_ref_designator ,NULL ,NULL                      ,p_new_ref_designator.new_routing_revision)            new_routing_revision
      ,DECODE(p_new_ref_designator ,NULL ,NULL                      ,p_new_ref_designator.return_status)                   return_status
      ,DECODE(p_new_ref_designator ,NULL ,NULL                      ,p_new_ref_designator.row_identifier )                 row_identifier
     FROM
       bom_reference_designators
     WHERE
       component_reference_designator = p_ref_designator_name AND
       component_sequence_id = p_component_sequence_id;

     i                           NUMBER := 0;
     l_merged_ref_designator     c_merged_ref_designators%ROWTYPE;
     l_copied_ref_designator     c_copied_ref_designators%ROWTYPE;
     l_component_sequence_id     NUMBER;
     l_component_item            inv_ebi_rev_comp_obj;
     l_Found                     BOOLEAN;
     l_ref_designator_tbl        inv_ebi_ref_desg_tbl;
     l_ref_dsgn_count            NUMBER := 1;
     l_output_status             inv_ebi_output_status;

 BEGIN
   l_output_status := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
   x_out           := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);
   INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.prepare_reference_designators');
   OPEN c_comp_sequence_id;
   FETCH c_comp_sequence_id INTO l_component_sequence_id;
   CLOSE c_comp_sequence_id;

   l_component_item := p_component_item;

   IF p_component_item.reference_designator_tbl IS NOT NULL THEN
     l_ref_designator_tbl := inv_ebi_ref_desg_tbl();
     FOR i IN 1..p_component_item.reference_designator_tbl.COUNT LOOP
       IF p_component_item.reference_designator_tbl(i).transaction_type <> ENG_GLOBALS.g_opr_delete THEN
         l_ref_designator_tbl.EXTEND(1);
         l_ref_designator_tbl(l_ref_dsgn_count) := p_component_item.reference_designator_tbl(i);
         l_ref_dsgn_count := l_ref_dsgn_count + 1;
       END IF;
     END LOOP;
     l_component_item.reference_designator_tbl := l_ref_designator_tbl;
   END IF;

   OPEN c_copied_ref_designators(l_Component_Sequence_Id);
   LOOP
     FETCH c_copied_ref_designators INTO l_copied_ref_designator;
     EXIT WHEN c_copied_ref_designators%NOTFOUND;
     l_Found := FALSE;
     IF p_component_item.reference_designator_tbl IS NOT NULL THEN
       FOR i IN 1..p_component_item.reference_designator_tbl.COUNT LOOP
         IF l_copied_ref_designator.reference_designator_name = p_component_item.reference_designator_tbl(i).reference_designator_name THEN
           l_Found := TRUE;
         END IF;
       END LOOP;
     END IF;

     IF NOT l_Found THEN
       OPEN c_merged_ref_designators(p_New_Ref_Designator        => NULL
                                    ,p_ref_designator_name       => l_copied_ref_designator.reference_designator_name
                                    ,p_component_sequence_id     => l_component_sequence_id
                                    );
       FETCH  c_merged_ref_designators INTO l_merged_ref_designator;
       IF l_component_item.reference_designator_tbl IS NULL THEN
         l_component_item.reference_designator_tbl := inv_ebi_ref_desg_tbl();
       END IF;
       l_component_item.reference_designator_tbl.EXTEND(1);

       l_component_item.reference_designator_tbl(l_component_item.reference_designator_tbl.COUNT) := inv_ebi_ref_desg_obj(
                                                         l_component_item.start_effective_date
                                                        ,l_copied_ref_designator.reference_designator_name
                                                        ,l_merged_ref_designator.acd_type
                                                        ,l_merged_ref_designator.ref_designator_comment
                                                        ,l_merged_ref_designator.attribute_category
                                                        ,l_merged_ref_designator.attribute1
                                                        ,l_merged_ref_designator.attribute2
                                                        ,l_merged_ref_designator.attribute3
                                                        ,l_merged_ref_designator.attribute4
                                                        ,l_merged_ref_designator.attribute5
                                                        ,l_merged_ref_designator.attribute6
                                                        ,l_merged_ref_designator.attribute7
                                                        ,l_merged_ref_designator.attribute8
                                                        ,l_merged_ref_designator.attribute9
                                                        ,l_merged_ref_designator.attribute10
                                                        ,l_merged_ref_designator.attribute11
                                                        ,l_merged_ref_designator.attribute12
                                                        ,l_merged_ref_designator.attribute13
                                                        ,l_merged_ref_designator.attribute14
                                                        ,l_merged_ref_designator.attribute15
                                                        ,l_merged_ref_designator.original_system_reference
                                                        ,l_merged_ref_designator.new_reference_designator
                                                        ,l_merged_ref_designator.from_end_item_unit_number
                                                        ,l_merged_ref_designator.new_routing_revision
                                                        ,l_merged_ref_designator.return_status
                                                        ,ENG_GLOBALS.g_opr_create
                                                        ,l_merged_ref_designator.row_identifier
                                                        ,NULL);
         CLOSE c_merged_ref_designators;
     END IF;
   END LOOP;
   CLOSE c_copied_ref_designators;

   IF l_component_item.reference_designator_tbl IS NOT NULL THEN

     FOR i IN 1..l_component_item.reference_designator_tbl.COUNT LOOP
       IF l_component_item.reference_designator_tbl(i).transaction_type = ENG_GLOBALS.g_opr_update THEN
         OPEN c_merged_ref_designators(p_new_ref_designator        => l_component_item.reference_designator_tbl(i)
                                      ,p_ref_designator_name       => l_component_item.reference_designator_tbl(i).reference_designator_name
                                      ,p_component_sequence_id     => l_Component_Sequence_Id);
         FETCH  c_merged_ref_designators INTO l_merged_ref_designator;
         l_component_item.reference_designator_tbl(i) := inv_ebi_ref_desg_obj(
                                                           l_merged_ref_designator.start_effective_date
                                                          ,l_component_item.reference_designator_tbl(i).reference_designator_name
                                                          ,l_merged_ref_designator.acd_type
                                                          ,l_merged_ref_designator.ref_designator_comment
                                                          ,l_merged_ref_designator.attribute_category
                                                          ,l_merged_ref_designator.attribute1
                                                          ,l_merged_ref_designator.attribute2
                                                          ,l_merged_ref_designator.attribute3
                                                          ,l_merged_ref_designator.attribute4
                                                          ,l_merged_ref_designator.attribute5
                                                          ,l_merged_ref_designator.attribute6
                                                          ,l_merged_ref_designator.attribute7
                                                          ,l_merged_ref_designator.attribute8
                                                          ,l_merged_ref_designator.attribute9
                                                          ,l_merged_ref_designator.attribute10
                                                          ,l_merged_ref_designator.attribute11
                                                          ,l_merged_ref_designator.attribute12
                                                          ,l_merged_ref_designator.attribute13
                                                          ,l_merged_ref_designator.attribute14
                                                          ,l_merged_ref_designator.attribute15
                                                          ,l_merged_ref_designator.original_system_reference
                                                          ,l_merged_ref_designator.new_reference_designator
                                                          ,l_merged_ref_designator.from_end_item_unit_number
                                                          ,l_merged_ref_designator.new_routing_revision
                                                          ,l_merged_ref_designator.return_status
                                                          ,ENG_GLOBALS.g_opr_create
                                                          ,l_merged_ref_designator.row_identifier
                                                          ,NULL);
           CLOSE c_merged_ref_designators;
       END IF;
     END LOOP;
   END IF;

   x_component_item := l_component_item;
   INV_EBI_UTIL.debug_line('STEP 20: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.prepare_reference_designators STATUS:  ' || x_out.output_status.return_status);

 EXCEPTION
   WHEN FND_API.g_exc_unexpected_error THEN
     IF c_merged_ref_designators%ISOPEN THEN
       CLOSE c_merged_ref_designators;
     END IF;
     IF c_copied_ref_designators%ISOPEN THEN
       CLOSE c_copied_ref_designators;
     END IF;
     x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;
     IF(x_out.output_status.msg_data IS NULL) THEN
       fnd_msg_pub.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count   => x_out.output_status.msg_count
        ,p_data    => x_out.output_status.msg_data
      );
     END IF;
   WHEN OTHERS THEN
     IF c_merged_ref_designators%ISOPEN THEN
       CLOSE c_merged_ref_designators;
     END IF;
     IF c_copied_ref_designators%ISOPEN THEN
       CLOSE c_copied_ref_designators;
     END IF;
     x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
     IF (x_out.output_status.msg_data IS NOT NULL) THEN
       x_out.output_status.msg_data      :=  x_out.output_status.msg_data||' ->INV_EBI_CHANGE_ORDER_HELPER.prepare_reference_designators ';
     ELSE
       x_out.output_status.msg_data      :=  SQLERRM||'INV_EBI_CHANGE_ORDER_HELPER.prepare_reference_designators ';
     END IF;
 END prepare_reference_designators;


/************************************************************************************
 --      API name        : prepare_component_items
 --      Type            : Private
 --      Function        : Prepare component_items for Replicate bom
 ************************************************************************************/
 PROCEDURE prepare_component_items(
    p_revised_item         IN  inv_ebi_revised_item_obj
   ,p_from_item_id         IN  NUMBER
   ,p_to_item_id           IN  NUMBER
   ,p_from_sequence_id     IN  NUMBER
   ,p_reference_org_id     IN  NUMBER
   ,p_view_scope           IN  VARCHAR2 := 'ALL'
   ,p_implementation_scope IN  VARCHAR2 := 'ALL'
   ,p_as_of_date           IN  DATE
   ,x_revised_item         OUT NOCOPY  inv_ebi_revised_item_obj
   ,x_out                  OUT NOCOPY  inv_ebi_eco_output_obj
 ) IS
    l_unit_assembly        VARCHAR2(1);
    l_bom_item_type        NUMBER;
    l_base_item_flag       NUMBER;
    i                      NUMBER := 0;

    CURSOR c_copied_comps (
       p_unit_assembly      IN VARCHAR2,
       p_itm_type           IN NUMBER,
       p_base_item_flag     IN NUMBER,
       p_unit_number        IN VARCHAR2
    )
    IS
      SELECT
        msi.concatenated_segments component_item_name,
        bic.component_item_id,
        bic.operation_seq_num
      FROM bom_inventory_components bic,
        mtl_system_items_kfv msi
      WHERE bic.bill_sequence_id = p_from_sequence_id
        AND bic.component_item_id = msi.inventory_item_id
        AND bic.component_item_id <> p_to_item_id
        AND NVL (bic.eco_for_production, 2) = 2
        AND msi.organization_id = p_reference_org_id
        AND ((p_unit_assembly = 'N'
              AND ((UPPER(p_view_scope) = G_VIEW_SCOPE_ALL)                           -- ALL
                   OR (UPPER(p_view_scope) = G_VIEW_SCOPE_CURRENT
                       AND (effectivity_date <= p_as_of_date
                            AND
                            (    (disable_date > p_as_of_date
                                  AND disable_date > SYSDATE
                                 )
                                 OR disable_date IS NULL
                                )
                           )
                      )
                   OR                                           -- CURRENT
                     (UPPER(p_view_scope ) = G_VIEW_SCOPE_CURR_FUTURE
                      AND
                      (    (disable_date > p_as_of_date
                            AND disable_date > SYSDATE
                           )
                           OR disable_date IS NULL
                          )
                     )
                  )                                    -- CURRENT + FUTURE
             )
             OR (p_unit_assembly = 'Y'
                 AND ((UPPER(p_view_scope) = G_VIEW_SCOPE_ALL)                        -- ALL
                      OR (UPPER(p_view_scope) = G_VIEW_SCOPE_CURRENT
                          AND disable_date IS NULL
                          AND (from_end_item_unit_number <= p_unit_number
                               AND (to_end_item_unit_number >=
                                                             p_unit_number
                                    OR to_end_item_unit_number IS NULL
                                   )
                              )
                         )
                      OR                                        -- CURRENT
                        (UPPER(p_view_scope) = G_VIEW_SCOPE_CURR_FUTURE
                         AND disable_date IS NULL
                         AND (to_end_item_unit_number >= p_unit_number
                              OR to_end_item_unit_number IS NULL
                             )
                        )
                     )                                 -- CURRENT + FUTURE
                )
            )
        AND ((p_base_item_flag = -1
              AND p_itm_type = 4
              AND msi.bom_item_type = 4
             )
             OR p_base_item_flag <> -1
             OR p_itm_type <> 4
            )
          AND (UPPER(p_implementation_scope) = G_VIEW_SCOPE_ALL OR
               (UPPER(p_implementation_scope) = G_IMPLEMENT_SCOPE_IMPLEMENT AND implementation_date IS NOT NULL) OR
               (UPPER(p_implementation_scope) = G_IMPLEMENT_SCOPE_UNIMPLEMENT AND implementation_date IS NULL));

   CURSOR c_merged_component (
     p_new_comp_item       IN inv_ebi_rev_comp_obj
    ,p_component_item_name IN VARCHAR2
    ,p_operation_sequence_number IN NUMBER
    ,p_bill_sequence_id  IN NUMBER
   ) IS
     SELECT
       DECODE(p_new_comp_item ,NULL ,bic.disable_date               ,DECODE(p_new_comp_item.disable_date
              ,fnd_api.g_miss_date ,bic.disable_date               ,p_new_comp_item.disable_date))              disable_date
      ,DECODE(p_new_comp_item ,NULL ,NVL(bic.acd_type,1)            ,DECODE(p_new_comp_item.acd_type
              ,fnd_api.g_miss_char ,NVL(bic.acd_type,1)            ,p_new_comp_item.acd_type))                  acd_type
      ,DECODE(p_new_comp_item ,NULL ,bic.basis_type                 ,DECODE(p_new_comp_item.basis_type
              ,fnd_api.g_miss_num  ,bic.basis_type                 ,p_new_comp_item.basis_type))                basis_type
      ,DECODE(p_new_comp_item ,NULL ,bic.component_quantity         ,DECODE(p_new_comp_item.quantity_per_assembly
              ,fnd_api.g_miss_num  ,bic.component_quantity         ,p_new_comp_item.quantity_per_assembly ))    quantity_per_assembly
      ,DECODE(p_new_comp_item ,NULL ,bic.component_quantity         ,DECODE(p_new_comp_item.inverse_quantity
              ,fnd_api.g_miss_num  ,bic.component_quantity         ,p_new_comp_item.inverse_quantity  ))        inverse_quantity
      ,DECODE(p_new_comp_item ,NULL ,bic.include_in_cost_rollup     ,DECODE(p_new_comp_item.include_in_cost_rollup
              ,fnd_api.g_miss_num  ,bic.include_in_cost_rollup     ,p_new_comp_item.include_in_cost_rollup))    include_in_cost_rollup
      ,DECODE(p_new_comp_item ,NULL ,bic.wip_supply_type            ,DECODE(p_new_comp_item.wip_supply_type
              ,fnd_api.g_miss_num  ,bic.wip_supply_type            ,p_new_comp_item.wip_supply_type))           wip_supply_type
      ,DECODE(p_new_comp_item ,NULL ,bic.so_basis                   ,DECODE(p_new_comp_item.so_basis
              ,fnd_api.g_miss_num  ,bic.so_basis                   ,p_new_comp_item.so_basis))                  so_basis
      ,DECODE(p_new_comp_item ,NULL ,bic.optional                   ,DECODE(p_new_comp_item.optional
              ,fnd_api.g_miss_num  ,bic.optional                   ,p_new_comp_item.optional))                  optional
      ,DECODE(p_new_comp_item ,NULL ,bic.mutually_exclusive_options ,DECODE(p_new_comp_item.mutually_exclusive
              ,fnd_api.g_miss_num  ,bic.mutually_exclusive_options ,p_new_comp_item.mutually_exclusive))        mutually_exclusive
      ,DECODE(p_new_comp_item ,NULL ,bic.check_atp                  ,DECODE(p_new_comp_item.check_atp
              ,fnd_api.g_miss_num  ,bic.check_atp                  ,p_new_comp_item.check_atp))                 check_atp
      ,DECODE(p_new_comp_item ,NULL ,bic.shipping_allowed           ,DECODE(p_new_comp_item.shipping_allowed
              ,fnd_api.g_miss_num  ,bic.shipping_allowed           ,p_new_comp_item.shipping_allowed))          shipping_allowed
      ,DECODE(p_new_comp_item ,NULL ,bic.required_to_ship           ,DECODE(p_new_comp_item.required_to_ship
              ,fnd_api.g_miss_num  ,bic.required_to_ship           ,p_new_comp_item.required_to_ship))          required_to_ship
      ,DECODE(p_new_comp_item ,NULL ,bic.required_for_revenue       ,DECODE(p_new_comp_item.required_for_revenue
              ,fnd_api.g_miss_num  ,bic.required_for_revenue       ,p_new_comp_item.required_for_revenue))      required_for_revenue
      ,DECODE(p_new_comp_item ,NULL ,bic.include_on_ship_docs       ,DECODE(p_new_comp_item.include_on_ship_docs
              ,fnd_api.g_miss_num  ,bic.include_on_ship_docs       ,p_new_comp_item.include_on_ship_docs))      include_on_ship_docs
      ,DECODE(p_new_comp_item ,NULL ,bic.quantity_related           ,DECODE(p_new_comp_item.quantity_related
              ,fnd_api.g_miss_num  ,bic.quantity_related           ,p_new_comp_item.quantity_related))          quantity_related
      ,DECODE(p_new_comp_item ,NULL ,bic.supply_subinventory        ,DECODE(p_new_comp_item.supply_subinventory
              ,fnd_api.g_miss_char ,bic.supply_subinventory        ,p_new_comp_item.supply_subinventory))       supply_subinventory
      ,DECODE(p_new_comp_item ,NULL ,bic.attribute_category         ,DECODE(p_new_comp_item.attribute_category
              ,fnd_api.g_miss_char ,bic.attribute_category         ,p_new_comp_item.attribute_category))        attribute_category
      ,DECODE(p_new_comp_item ,NULL ,bic.attribute1                 ,DECODE(p_new_comp_item.attribute1
              ,fnd_api.g_miss_char ,bic.attribute1                 ,p_new_comp_item.attribute1))                attribute1
      ,DECODE(p_new_comp_item ,NULL ,bic.attribute2                 ,DECODE(p_new_comp_item.attribute2
              ,fnd_api.g_miss_char ,bic.attribute2                 ,p_new_comp_item.attribute2))                attribute2
      ,DECODE(p_new_comp_item ,NULL ,bic.attribute3                 ,DECODE(p_new_comp_item.attribute3
              ,fnd_api.g_miss_char ,bic.attribute3                 ,p_new_comp_item.attribute3))                attribute3
      ,DECODE(p_new_comp_item ,NULL ,bic.attribute4                 ,DECODE(p_new_comp_item.attribute4
              ,fnd_api.g_miss_char ,bic.attribute4                 ,p_new_comp_item.attribute4))                attribute4
      ,DECODE(p_new_comp_item ,NULL ,bic.attribute5                 ,DECODE(p_new_comp_item.attribute5
              ,fnd_api.g_miss_char ,bic.attribute5                 ,p_new_comp_item.attribute5))                attribute5
      ,DECODE(p_new_comp_item ,NULL ,bic.attribute6                 ,DECODE(p_new_comp_item.attribute6
              ,fnd_api.g_miss_char ,bic.attribute6                 ,p_new_comp_item.attribute6))                attribute6
      ,DECODE(p_new_comp_item ,NULL ,bic.attribute7                 ,DECODE(p_new_comp_item.attribute7
              ,fnd_api.g_miss_char ,bic.attribute7                 ,p_new_comp_item.attribute7))                attribute7
      ,DECODE(p_new_comp_item ,NULL ,bic.attribute8                 ,DECODE(p_new_comp_item.attribute8
              ,fnd_api.g_miss_char ,bic.attribute8                 ,p_new_comp_item.attribute8))                attribute8
      ,DECODE(p_new_comp_item ,NULL ,bic.attribute9                 ,DECODE(p_new_comp_item.attribute9
              ,fnd_api.g_miss_char ,bic.attribute9                 ,p_new_comp_item.attribute9))                attribute9
      ,DECODE(p_new_comp_item ,NULL ,bic.attribute10                ,DECODE(p_new_comp_item.attribute10
              ,fnd_api.g_miss_char ,bic.attribute10                ,p_new_comp_item.attribute10))               attribute10
      ,DECODE(p_new_comp_item ,NULL ,bic.attribute11                ,DECODE(p_new_comp_item.attribute11
              ,fnd_api.g_miss_char ,bic.attribute11                ,p_new_comp_item.attribute11))               attribute11
      ,DECODE(p_new_comp_item ,NULL ,bic.attribute12                ,DECODE(p_new_comp_item.attribute12
              ,fnd_api.g_miss_char ,bic.attribute12                ,p_new_comp_item.attribute12))               attribute12
      ,DECODE(p_new_comp_item ,NULL ,bic.attribute13                ,DECODE(p_new_comp_item.attribute13
              ,fnd_api.g_miss_char ,bic.attribute13                ,p_new_comp_item.attribute13))               attribute13
      ,DECODE(p_new_comp_item ,NULL ,bic.attribute14                ,DECODE(p_new_comp_item.attribute14
              ,fnd_api.g_miss_char ,bic.attribute14                ,p_new_comp_item.attribute14))               attribute14
      ,DECODE(p_new_comp_item ,NULL ,bic.attribute15                ,DECODE(p_new_comp_item.attribute15
              ,fnd_api.g_miss_char ,bic.attribute15                ,p_new_comp_item.attribute15))               attribute15
      ,DECODE(p_new_comp_item ,NULL ,bic.from_end_item_unit_number  ,DECODE(p_new_comp_item.from_end_item_unit_number
              ,fnd_api.g_miss_char ,bic.from_end_item_unit_number  ,p_new_comp_item.from_end_item_unit_number)) from_end_item_unit_number
      ,DECODE(p_new_comp_item ,NULL ,bic.to_end_item_unit_number    ,DECODE(p_new_comp_item.to_end_item_unit_number
              ,fnd_api.g_miss_char ,bic.to_end_item_unit_number    ,p_new_comp_item.to_end_item_unit_number))   to_end_item_unit_number
      ,DECODE(p_new_comp_item ,NULL ,bic.enforce_int_requirements   ,DECODE(p_new_comp_item.enforce_int_requirements
              ,fnd_api.g_miss_char ,bic.enforce_int_requirements   ,p_new_comp_item.enforce_int_requirements))  enforce_int_requirements
      ,DECODE(p_new_comp_item ,NULL ,bic.auto_request_material      ,DECODE(p_new_comp_item.auto_request_material
              ,fnd_api.g_miss_char ,bic.auto_request_material      ,p_new_comp_item.auto_request_material))     auto_request_material
      ,DECODE(p_new_comp_item ,NULL ,bic.suggested_vendor_name      ,DECODE(p_new_comp_item.suggested_vendor_name
              ,fnd_api.g_miss_char ,bic.suggested_vendor_name      ,p_new_comp_item.suggested_vendor_name))     suggested_vendor_name
      ,DECODE(p_new_comp_item ,NULL ,bic.unit_price                 ,DECODE(p_new_comp_item.unit_price
              ,fnd_api.g_miss_num  ,bic.unit_price                 ,p_new_comp_item.unit_price))                unit_price
      ,DECODE(p_new_comp_item ,NULL ,bic.original_system_reference  ,DECODE(p_new_comp_item.original_system_reference
              ,fnd_api.g_miss_num  ,bic.original_system_reference  ,p_new_comp_item.original_system_reference)) original_system_reference
      ,DECODE(p_new_comp_item ,NULL ,SYSDATE                        ,DECODE(p_new_comp_item.start_effective_date
              ,fnd_api.g_miss_date ,bic.effectivity_date           ,p_new_comp_item.start_effective_date))      start_effective_date
      ,DECODE(p_new_comp_item ,NULL ,bic.item_num                   ,DECODE(p_new_comp_item.item_sequence_number
              ,fnd_api.g_miss_num  ,bic.item_num                   ,p_new_comp_item.item_sequence_number))      item_sequence_number
      ,DECODE(p_new_comp_item ,NULL ,bic.planning_factor            ,DECODE(p_new_comp_item.planning_percent
              ,fnd_api.g_miss_num  ,bic.planning_factor            ,p_new_comp_item.planning_percent))          planning_percent
      ,DECODE(p_new_comp_item ,NULL ,bic.component_yield_factor     ,DECODE(p_new_comp_item.projected_yield
              ,fnd_api.g_miss_num  ,bic.component_yield_factor     ,p_new_comp_item.projected_yield))           projected_yield
      ,DECODE(p_new_comp_item ,NULL ,bic.high_quantity              ,DECODE(p_new_comp_item.maximum_allowed_quantity
              ,fnd_api.g_miss_num  ,bic.high_quantity              ,p_new_comp_item.maximum_allowed_quantity))  maximum_allowed_quantity
      ,DECODE(p_new_comp_item ,NULL ,bic.low_quantity               ,DECODE(p_new_comp_item.minimum_allowed_quantity
              ,fnd_api.g_miss_num  ,bic.low_quantity               ,p_new_comp_item.minimum_allowed_quantity))  minimum_allowed_quantity
      ,DECODE(p_new_comp_item ,NULL ,bic.component_remarks          ,DECODE(p_new_comp_item.comments
              ,fnd_api.g_miss_char ,component_remarks              ,p_new_comp_item.comments))                  comments
      ,DECODE(p_new_comp_item ,NULL ,NULL                           ,p_new_comp_item.new_effectivity_date)          new_effectivity_date
      ,DECODE(p_new_comp_item ,NULL ,NULL                           ,p_new_comp_item.old_effectivity_date)          old_effectivity_date
      ,DECODE(p_new_comp_item ,NULL ,1                              ,p_new_comp_item.old_operation_sequence_number) old_operation_sequence_number
      ,DECODE(p_new_comp_item ,NULL ,1                              ,p_new_comp_item.new_operation_sequence_number) new_operation_sequence_number
      ,DECODE(p_new_comp_item ,NULL ,NULL                           ,p_new_comp_item.location_name)                 location_name
      ,DECODE(p_new_comp_item ,NULL ,NULL                           ,p_new_comp_item.cancel_comments)               cancel_comments
      ,DECODE(p_new_comp_item ,NULL ,NULL                           ,p_new_comp_item.old_from_end_item_unit_number) old_from_end_item_unit_number
      ,DECODE(p_new_comp_item ,NULL ,NULL                           ,p_new_comp_item.new_from_end_item_unit_number) new_from_end_item_unit_number
      ,DECODE(p_new_comp_item ,NULL ,NULL                           ,p_new_comp_item.new_routing_revision)          new_routing_revision
      ,DECODE(p_new_comp_item ,NULL ,NULL                           ,p_new_comp_item.return_status)                 return_status
     FROM
       bom_inventory_components bic,
       mtl_system_items_kfv it
     WHERE
       bic.component_item_id = it.inventory_item_id AND
       it.organization_id    = p_reference_org_id AND
       it.concatenated_segments = p_component_item_name AND
       bic.operation_seq_num = nvl(p_operation_sequence_number,1)  AND
       bic.bill_sequence_id  = p_bill_sequence_id;

   l_merged_comp  c_merged_component%ROWTYPE;
   l_copied_comp  c_copied_comps%ROWTYPE;
   l_revised_item inv_ebi_revised_item_obj;
   l_found        BOOLEAN;
   l_revised_comp_tbl      inv_ebi_rev_comp_tbl;
   l_revised_comp_count    NUMBER := 1;
   l_output_status         inv_ebi_output_status;
 BEGIN
   l_output_status := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
   x_out           := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);
   INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.prepare_component_items');
   IF (bom_eamutil.enabled = 'Y'
         AND bom_eamutil.serial_effective_item (item_id      => p_from_item_id,
                                                org_id       => p_reference_org_id
                                               ) = 'Y'
      )
      OR (pjm_unit_eff.enabled = 'Y'
            AND pjm_unit_eff.unit_effective_item
                                          (x_item_id              => p_from_item_id,
                                           x_organization_id      => p_reference_org_id
                                          ) = 'Y'
           )
     THEN
        l_unit_assembly := 'Y';
     ELSE
        l_unit_assembly := 'N';
   END IF;


   SELECT
     bom_item_type
    ,DECODE (base_item_id, NULL, -1, 0) base_item_id
   INTO
     l_bom_item_type
    ,l_base_item_flag
   FROM
     mtl_system_items_b
   WHERE
     inventory_item_id = p_from_item_id AND
     organization_id = p_reference_org_id;

   l_revised_item := p_revised_item;
   IF p_revised_item.component_item_tbl IS NOT NULL THEN
     l_revised_comp_tbl := inv_ebi_rev_comp_tbl();
     FOR i IN 1..p_revised_item.component_item_tbl.COUNT LOOP
       IF p_revised_item.component_item_tbl(i).transaction_type <> ENG_GLOBALS.g_opr_delete THEN
         l_revised_comp_tbl.EXTEND(1);
         l_revised_comp_tbl(l_revised_comp_count) := p_revised_item.component_item_tbl(i);
         l_revised_comp_count := l_revised_comp_count + 1;
       END IF;
     END LOOP;
     l_revised_item.component_item_tbl := l_revised_comp_tbl;
   END IF;


   OPEN c_copied_comps(p_itm_type       => l_bom_item_type
                      ,p_base_item_flag => l_base_item_flag
                      ,p_unit_number    => NULL
                      ,p_unit_assembly  => l_unit_assembly) ;
   LOOP
     FETCH c_copied_comps INTO l_copied_comp;
     EXIT WHEN c_copied_comps%NOTFOUND;
     l_Found := FALSE;
     IF p_revised_item.component_item_tbl IS NOT NULL THEN
       FOR i IN 1..p_revised_item.component_item_tbl.COUNT LOOP
       INV_EBI_UTIL.debug_line('STEP 20: COMPONENT ITEM NAME: '|| p_revised_item.component_item_tbl(i).component_item_name);
         IF l_copied_comp.component_item_name = p_revised_item.component_item_tbl(i).component_item_name
           AND l_copied_comp.operation_seq_num = p_revised_item.component_item_tbl(i).operation_sequence_number THEN
           l_Found := TRUE;
         END IF;
       END LOOP;
     END IF;

     IF NOT l_Found THEN
       OPEN c_merged_component(p_new_comp_item             => NULL
                              ,p_component_item_name       => l_copied_comp.component_item_name
                              ,p_operation_sequence_number => l_copied_comp.operation_seq_num
                              ,p_bill_sequence_id          => p_from_sequence_id);
       FETCH  c_merged_component INTO l_Merged_Comp;
       IF l_revised_item.component_item_tbl IS NULL THEN
          l_revised_item.component_item_tbl := inv_ebi_rev_comp_tbl();
       END IF;
       l_revised_item.component_item_tbl.EXTEND(1);

       l_revised_item.component_item_tbl(l_revised_item.component_item_tbl.COUNT) := inv_ebi_rev_comp_obj(
                                    p_revised_item.start_effective_date
                                   ,p_revised_item.start_effective_date
                                   ,l_merged_comp.disable_date
                                   ,l_copied_comp.operation_seq_num
                                   ,l_copied_comp.component_item_name
                                   ,NULL
                                   ,NULL
                                   ,l_merged_comp.acd_type
                                   ,l_merged_comp.old_effectivity_date
                                   ,l_merged_comp.old_operation_sequence_number
                                   ,l_merged_comp.new_operation_sequence_number
                                   ,NULL
                                   ,l_merged_comp.basis_type
                                   ,l_merged_comp.quantity_per_assembly
                                   ,l_merged_comp.inverse_quantity
                                   ,l_merged_comp.planning_percent
                                   ,l_merged_comp.projected_yield
                                   ,l_merged_comp.include_in_cost_rollup
                                   ,l_merged_comp.wip_supply_type
                                   ,l_merged_comp.so_basis
                                   ,l_merged_comp.optional
                                   ,l_merged_comp.mutually_exclusive
                                   ,l_merged_comp.check_atp
                                   ,l_merged_comp.shipping_allowed
                                   ,l_merged_comp.required_to_ship
                                   ,l_merged_comp.required_for_revenue
                                   ,l_merged_comp.include_on_ship_docs
                                   ,l_merged_comp.quantity_related
                                   ,l_merged_comp.supply_subinventory
                                   ,l_merged_comp.location_name
                                   ,l_merged_comp.minimum_allowed_quantity
                                   ,l_merged_comp.maximum_allowed_quantity
                                   ,l_merged_comp.comments
                                   ,l_merged_comp.cancel_comments
                                   ,l_merged_comp.attribute_category
                                   ,l_merged_comp.attribute1
                                   ,l_merged_comp.attribute2
                                   ,l_merged_comp.attribute3
                                   ,l_merged_comp.attribute4
                                   ,l_merged_comp.attribute5
                                   ,l_merged_comp.attribute6
                                   ,l_merged_comp.attribute7
                                   ,l_merged_comp.attribute8
                                   ,l_merged_comp.attribute9
                                   ,l_merged_comp.attribute10
                                   ,l_merged_comp.attribute11
                                   ,l_merged_comp.attribute12
                                   ,l_merged_comp.attribute13
                                   ,l_merged_comp.attribute14
                                   ,l_merged_comp.attribute15
                                   ,l_merged_comp.from_end_item_unit_number
                                   ,l_merged_comp.old_from_end_item_unit_number
                                   ,l_merged_comp.new_from_end_item_unit_number
                                   ,l_merged_comp.to_end_item_unit_number
                                   ,l_merged_comp.new_routing_revision
                                   ,l_merged_comp.enforce_int_requirements
                                   ,l_merged_comp.auto_request_material
                                   ,l_merged_comp.suggested_vendor_name
                                   ,l_merged_comp.unit_price
                                   ,l_merged_comp.original_system_reference
                                   ,l_merged_comp.return_status
                                   ,ENG_GLOBALS.g_opr_create
                                   ,NULL
                                   ,NULL
                                   ,NULL
                                   ,NULL
                                   ,NULL
                                   ,NULL);

         CLOSE c_merged_component;
     END IF;
   END LOOP;
   CLOSE c_copied_comps;

   IF l_revised_item.component_item_tbl IS NOT NULL THEN
     FOR i IN 1..l_revised_item.component_item_tbl.COUNT LOOP
       IF l_revised_item.component_item_tbl(i).transaction_type = ENG_GLOBALS.g_opr_update THEN
         OPEN c_merged_component(p_new_comp_item             => l_revised_item.component_item_tbl(i)
                                ,p_component_item_name       => l_revised_item.component_item_tbl(i).component_item_name
                                ,p_operation_sequence_number => l_revised_item.component_item_tbl(i).operation_sequence_number
                                ,p_bill_sequence_id          => p_from_sequence_id);
         FETCH  c_merged_component INTO l_Merged_Comp;
         l_revised_item.component_item_tbl(i) := inv_ebi_rev_comp_obj(
                                      l_merged_comp.start_effective_date
                                     ,l_merged_comp.new_effectivity_date
                                     ,l_merged_comp.disable_date
                                     ,l_revised_item.component_item_tbl(i).operation_sequence_number
                                     ,l_revised_item.component_item_tbl(i).component_item_name
                                     ,l_revised_item.component_item_tbl(i).substitute_component_tbl
                                     ,l_revised_item.component_item_tbl(i).reference_designator_tbl
                                     ,l_merged_comp.acd_type
                                     ,l_merged_comp.old_effectivity_date
                                     ,l_merged_comp.old_operation_sequence_number
                                     ,l_merged_comp.new_operation_sequence_number
                                     ,l_merged_comp.item_sequence_number
                                     ,l_merged_comp.basis_type
                                     ,l_merged_comp.quantity_per_assembly
                                     ,l_merged_comp.inverse_quantity
                                     ,l_merged_comp.planning_percent
                                     ,l_merged_comp.projected_yield
                                     ,l_merged_comp.include_in_cost_rollup
                                     ,l_merged_comp.wip_supply_type
                                     ,l_merged_comp.so_basis
                                     ,l_merged_comp.optional
                                     ,l_merged_comp.mutually_exclusive
                                     ,l_merged_comp.check_atp
                                     ,l_merged_comp.shipping_allowed
                                     ,l_merged_comp.required_to_ship
                                     ,l_merged_comp.required_for_revenue
                                     ,l_merged_comp.include_on_ship_docs
                                     ,l_merged_comp.quantity_related
                                     ,l_merged_comp.supply_subinventory
                                     ,l_merged_comp.location_name
                                     ,l_merged_comp.minimum_allowed_quantity
                                     ,l_merged_comp.maximum_allowed_quantity
                                     ,l_merged_comp.comments
                                     ,l_merged_comp.cancel_comments
                                     ,l_merged_comp.attribute_category
                                     ,l_merged_comp.attribute1
                                     ,l_merged_comp.attribute2
                                     ,l_merged_comp.attribute3
                                     ,l_merged_comp.attribute4
                                     ,l_merged_comp.attribute5
                                     ,l_merged_comp.attribute6
                                     ,l_merged_comp.attribute7
                                     ,l_merged_comp.attribute8
                                     ,l_merged_comp.attribute9
                                     ,l_merged_comp.attribute10
                                     ,l_merged_comp.attribute11
                                     ,l_merged_comp.attribute12
                                     ,l_merged_comp.attribute13
                                     ,l_merged_comp.attribute14
                                     ,l_merged_comp.attribute15
                                     ,l_merged_comp.from_end_item_unit_number
                                     ,l_merged_comp.old_from_end_item_unit_number
                                     ,l_merged_comp.new_from_end_item_unit_number
                                     ,l_merged_comp.to_end_item_unit_number
                                     ,l_merged_comp.new_routing_revision
                                     ,l_merged_comp.enforce_int_requirements
                                     ,l_merged_comp.auto_request_material
                                     ,l_merged_comp.suggested_vendor_name
                                     ,l_merged_comp.unit_price
                                     ,l_merged_comp.original_system_reference
                                     ,l_merged_comp.return_status
                                     ,ENG_GLOBALS.g_opr_create
                                     ,NULL
                                     ,l_revised_item.component_item_tbl(i).component_revision_uda
                                     ,NULL
                                     ,NULL
                                     ,NULL
                                     ,NULL);
           CLOSE c_merged_component;
       END IF;
     END LOOP;
   END IF;
   INV_EBI_UTIL.debug_line('STEP 30: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.prepare_component_items'|| ' OUTPUT STATUS:  '|| x_out.output_status.return_status);
   x_revised_item := l_revised_item;


 EXCEPTION
   WHEN FND_API.g_exc_unexpected_error THEN
     IF c_copied_comps%ISOPEN THEN
       CLOSE c_copied_comps;
     END IF;
     IF c_merged_component%ISOPEN THEN
       CLOSE c_merged_component;
     END IF;
     x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;
     IF(x_out.output_status.msg_data IS NULL) THEN
       fnd_msg_pub.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count   => x_out.output_status.msg_count
        ,p_data    => x_out.output_status.msg_data
      );
     END IF;
   WHEN OTHERS THEN
     IF c_copied_comps%ISOPEN THEN
       CLOSE c_copied_comps;
     END IF;
     IF c_merged_component%ISOPEN THEN
       CLOSE c_merged_component;
     END IF;
     x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
     IF (x_out.output_status.msg_data IS NOT NULL) THEN
       x_out.output_status.msg_data      :=  x_out.output_status.msg_data||' ->INV_EBI_CHANGE_ORDER_HELPER.prepare_component_items ';
     ELSE
       x_out.output_status.msg_data      :=  SQLERRM||'INV_EBI_CHANGE_ORDER_HELPER.prepare_component_items ';
     END IF;
 END prepare_component_items;

/************************************************************************************
 --      API name        : Is_BOM_Exists
 --      Type            : Private
 --      Function     :
 ************************************************************************************/

  FUNCTION Is_BOM_Exists(
    p_Item_Number         IN  VARCHAR2
   ,p_Organization_Code   IN  VARCHAR2
   ,p_alternate_bom_code  IN  VARCHAR2
  ) RETURN VARCHAR2 IS
    l_Count NUMBER := 0;
  BEGIN
    INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.Is_BOM_Exists');
    INV_EBI_UTIL.debug_line('STEP 20: ITEM NUMBER: '|| p_Item_Number || ' ORG CODE:  '|| p_Organization_Code);
    SELECT
      COUNT(1)
    INTO
      l_Count
    FROM
      bom_bill_of_materials bb,
      mtl_system_items_kfv it,
      mtl_parameters mp
    WHERE
      bb.assembly_item_id = it.inventory_item_id AND
      it.organization_id = bb.organization_id AND
      bb.organization_id = mp.organization_id AND
      mp.organization_code = p_Organization_Code AND
      it.concatenated_segments = p_Item_Number AND
      ((p_alternate_bom_code IS NULL AND bb.alternate_bom_designator IS NULL) OR
      (bb.alternate_bom_designator = p_alternate_bom_code));

    IF l_Count = 1 THEN
       INV_EBI_UTIL.debug_line('STEP 30: RETURN STATUS '|| FND_API.g_true);
      RETURN FND_API.g_true;
    END IF;
    INV_EBI_UTIL.debug_line('STEP 40: RETURN STATUS ' || FND_API.g_false);
    INV_EBI_UTIL.debug_line('STEP 50: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.Is_BOM_Exists');
    RETURN FND_API.g_false;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN FND_API.g_false;
  END Is_BOM_Exists;

/************************************************************************************
 --      API name        : is_new_revision_exists
 --      Type            : Private
 --      Function        : This api is used to find if a change already exists for the
 --                        revsied items revision.
 -- Bug 7119898
 ************************************************************************************/

 FUNCTION is_new_revision_exists(
    p_item_number   IN  VARCHAR2
   ,p_revision      IN  VARCHAR2
   ,p_org_code      IN  VARCHAR2
  ) RETURN VARCHAR2 IS

  l_Count NUMBER := 0;

  BEGIN
    INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.is_new_revision_exists');
    INV_EBI_UTIL.debug_line('STEP 20: ITEM NUMBER: '|| p_Item_Number || ' REVISION: '|| p_revision || ' ORG CODE: '|| p_org_code);
    SELECT COUNT(1) INTO l_Count
    FROM
      eng_revised_items eri,
      mtl_system_items_kfv  msi,
      mtl_parameters  mp
    WHERE
      eri.revised_item_id  = msi.inventory_item_id AND
      msi.organization_id  = eri.organization_id  AND
      eri.organization_id  = mp.organization_id  AND
      mp.organization_code = p_org_code AND
      msi.concatenated_segments = p_item_number AND
      eri.new_item_revision = p_revision ;

  IF l_Count >=1 THEN
    INV_EBI_UTIL.debug_line('STEP 30: RETURN STATUS '|| FND_API.g_true);
    RETURN FND_API.g_true;
  END IF;
  INV_EBI_UTIL.debug_line('STEP 40: RETURN STATUS '|| FND_API.g_false);
  INV_EBI_UTIL.debug_line('STEP 50: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.is_new_revision_exists');
  RETURN FND_API.g_false;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN FND_API.g_false;
  END is_new_revision_exists;

/*******************************************************************************
 API name        : is_child_org
 Type            : Private
 Purpose         : Checks if the organization is master org or child org.
 --Bug 7197943
 ********************************************************************************/
 FUNCTION is_child_org (
   p_organization_id  IN NUMBER
 ) RETURN VARCHAR2 IS

 l_master_org   NUMBER;

 BEGIN

   SELECT master_organization_id INTO l_master_org
   FROM mtl_parameters
   WHERE organization_id= p_organization_id;

   IF(l_master_org <> p_organization_id) THEN
     RETURN FND_API.g_true;
   ELSE
     RETURN FND_API.g_false;
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
     RETURN NULL;
 END is_child_org;

/************************************************************************************
  --      API name        : get_bill_sequence_id
  --      Type            : Private
  --      Function        : This function returns the bill sequence id corresponding to
  --                         the given assembly item id,org id and alternate bom code.
  ************************************************************************************/

 FUNCTION get_bill_sequence_id(
   p_assembly_item_id     IN NUMBER ,
   p_organization_id      IN NUMBER,
   p_alternate_bom_code   IN VARCHAR2
  )  RETURN NUMBER IS

  l_bill_sequence_id   NUMBER;

  BEGIN

    SELECT bill_sequence_id INTO l_bill_sequence_id
    FROM
      bom_bill_of_materials
    WHERE
      assembly_item_id   =  p_assembly_item_id AND
      organization_id    =  p_organization_id AND
      NVL(alternate_bom_designator, 'NONE') =
      decode(p_alternate_bom_code,FND_API.G_MISS_CHAR,'NONE',NULL,'NONE',p_alternate_bom_code);

   RETURN l_bill_sequence_id;

 EXCEPTION
 WHEN OTHERS THEN
   RETURN NULL;
 END get_bill_sequence_id;

/************************************************************************************
 --      API name        : process_replicate_bom
 --      Type            : Public
 --      Function        :
 --      The following processing is done in this API
 --      1. Check if the item has a BOM defined in the currentcontext organization
 --      2. Also check that the reference org has a BOM defined.
 --      3. Modify the component tbl as per the following logic
            * Remove the components which have transaction type as 'DELETE'
            * Find the components which are present only in the reference organization
              and add them to the list with transaction type as 'CREATE'
            * Modify the transaction type of the components which have 'UPDATE' as the
              transaction type to 'CREATE'
 --      4. For each component item the above processing will be done for substitute
            components and reference designators
 ************************************************************************************/
 PROCEDURE process_replicate_bom(
   p_organization_code   IN  VARCHAR2
  ,p_revised_item_obj    IN  inv_ebi_revised_item_obj
  ,p_name_value_tbl      IN  inv_ebi_name_value_tbl
  ,x_revised_item_obj    OUT NOCOPY  inv_ebi_revised_item_obj
  ,x_out                 OUT NOCOPY  inv_ebi_eco_output_obj
 ) IS
   l_revised_item               inv_ebi_revised_item_obj;
   l_revised_item1              inv_ebi_revised_item_obj;
   l_context_org_bom_exists     VARCHAR2(1) := FND_API.g_false;
   l_ref_org_bom_exists         VARCHAR2(1) := FND_API.g_false;
   l_context_org_code           mtl_parameters.organization_code%TYPE;
   l_pk_col_name_val_pairs      INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl;
   l_component_item             inv_ebi_rev_comp_obj;
   l_component_item1            inv_ebi_rev_comp_obj;
   l_eco_obj                    inv_ebi_eco_obj;
   l_from_item_id               NUMBER;
   l_to_item_id                 NUMBER;
   l_from_sequence_id           NUMBER;
   l_from_org_id                NUMBER;
   l_to_org_id                  NUMBER;
   l_view_scope                 VARCHAR2(30) ;
   l_impl_scope                 VARCHAR2(30) ;
   l_config_view_scope          VARCHAR2(30) := 'ALL';
   l_config_impl_scope          VARCHAR2(30) := 'ALL';
   l_return_status              VARCHAR2(10);
   l_msg_Count                  NUMBER;
   l_reference_item_num         mtl_system_items_kfv.concatenated_segments%TYPE;
   l_reference_org_code         mtl_parameters.organization_code%TYPE;
   l_as_of_date                 DATE;
   l_alternate_bom_code         bom_bill_of_materials.alternate_bom_designator%TYPE;
   l_output_status              inv_ebi_output_status;

 BEGIN
   SAVEPOINT process_replicate_bom_save_pnt;
   l_output_status := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
   x_out           := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);
   INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.process_replicate_bom');
   INV_EBI_UTIL.debug_line('STEP 20: ORG_CODE: '|| p_organization_code || ' REVISED ITEM NAME:  '|| p_revised_item_obj.revised_item_name);
   l_context_org_code:= p_organization_code;


   l_config_view_scope := INV_EBI_UTIL.get_config_param_value (
                              p_config_tbl        => p_name_value_tbl
                             ,p_config_param_name => 'REPLICATE_BOM_VIEW_SCOPE'
                          );


   l_config_impl_scope := INV_EBI_UTIL.get_config_param_value (
                               p_config_tbl        => p_name_value_tbl
                              ,p_config_param_name => 'REPLICATE_BOM_IMPLEMENTATION_SCOPE'
                          );

   --IF l_eco_obj.eco_revised_item_type IS NOT NULL THEN
     --FOR i IN 1..l_eco_obj.eco_revised_item_type.COUNT LOOP
       l_revised_item := p_revised_item_obj;

       IF (l_revised_item.orignal_bom_reference IS NOT NULL AND
       (l_revised_item.orignal_bom_reference.organization_id IS NOT NULL OR
        l_revised_item.orignal_bom_reference.organization_code IS NOT NULL )) THEN

         l_from_org_id    := l_revised_item.orignal_bom_reference.organization_id;
         l_reference_org_code := l_revised_item.orignal_bom_reference.organization_code;
         IF l_from_org_id IS NULL OR l_from_org_id = fnd_api.g_miss_num THEN
           l_from_org_id    := INV_EBI_ITEM_HELPER.get_organization_id(  p_organization_code => l_reference_org_code);
         ELSIF l_reference_org_code IS NULL OR l_reference_org_code = fnd_api.g_miss_char THEN
           SELECT
             organization_code
           INTO
             l_reference_org_code
           FROM
             mtl_parameters
           WHERE
             organization_id = l_from_org_id;
         END IF;

         l_reference_item_num := l_revised_item.revised_item_name;
         IF l_revised_item.orignal_bom_reference.item_name IS NOT NULL THEN
           l_reference_item_num := l_revised_item.orignal_bom_reference.item_name;
         ELSIF l_revised_item.orignal_bom_reference.inventory_item_id IS NOT NULL THEN
           l_from_item_id := l_revised_item.orignal_bom_reference.inventory_item_id;
           SELECT
             concatenated_segments
           INTO
             l_reference_item_num
           FROM
            mtl_system_items_kfv
           WHERE
             inventory_item_id =  l_from_item_id AND
             organization_id = l_from_org_id;
         END IF;

         IF l_from_item_id IS NULL THEN
           l_from_item_id   := INV_EBI_ITEM_HELPER.get_inventory_item_id ( p_organization_id => l_from_org_id
                                                                          ,p_item_number   => l_reference_item_num);
           INV_EBI_UTIL.debug_line('STEP 30: FROM ITEM ID: '|| l_from_item_id);
         END IF;

         l_to_org_id      := INV_EBI_ITEM_HELPER.get_organization_id ( p_organization_code => l_context_org_code);
         l_to_item_id     := INV_EBI_ITEM_HELPER.get_inventory_item_id ( p_organization_id => l_to_org_id
                                                                        ,p_item_number     => l_revised_item.revised_item_name) ;
         INV_EBI_UTIL.debug_line('STEP 40: TO ORG ID: '|| l_to_org_id || ' TO ITEM ID: '|| l_to_item_id);
         l_context_org_bom_exists :=  Is_BOM_Exists(
                                        p_item_number        => l_revised_item.revised_item_name
                                       ,p_organization_code  => l_context_org_code
                                       ,p_alternate_bom_code => l_revised_item.orignal_bom_reference.alternate_bom_code
                                      );

         l_ref_org_bom_exists :=  Is_BOM_Exists(
                                    p_item_number        => l_reference_item_num
                                   ,p_organization_code  => l_reference_org_code
                                   ,p_alternate_bom_code => l_revised_item.orignal_bom_reference.alternate_bom_code
                                  );
         IF (NOT FND_API.To_Boolean(l_context_org_bom_exists)) AND FND_API.To_Boolean(l_ref_org_bom_exists) THEN
           SELECT
             bill_sequence_id
           INTO
             l_from_sequence_id
           FROM
             bom_bill_of_materials
           WHERE
            assembly_item_id = l_from_item_id AND
            organization_id = l_from_org_id AND
            ((l_revised_item.alternate_bom_code IS NULL AND alternate_bom_designator IS NULL) OR
            (alternate_bom_designator = l_revised_item.alternate_bom_code));
           l_view_scope := l_revised_item.orignal_bom_reference.view_scope;
           IF l_view_scope IS NULL OR l_view_scope = fnd_api.g_miss_char THEN
             l_view_scope := l_config_view_scope;
           END IF;

           l_impl_scope := l_revised_item.orignal_bom_reference.implementation_scope;
           IF l_impl_scope IS NULL OR l_impl_scope = fnd_api.g_miss_char THEN
             l_impl_scope := l_config_impl_scope;
           END IF;

           l_as_of_date := l_revised_item.orignal_bom_reference.as_of_date;
           IF l_as_of_date IS NULL OR l_as_of_date = fnd_api.g_miss_date THEN
             l_as_of_date := SYSDATE;
           END IF;
           l_revised_item1 := l_revised_item;
           INV_EBI_UTIL.debug_line('STEP 50: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.prepare_component_items ');
           prepare_component_items (
             p_revised_item         => l_revised_item1
            ,p_from_item_id         => l_from_item_id
            ,p_to_item_id           => l_to_item_id
            ,p_from_sequence_id     => l_from_sequence_id
            ,p_reference_org_id     => l_from_org_id
            ,p_view_scope           => l_view_scope
            ,p_implementation_scope => l_impl_scope
            ,p_as_of_date           => l_as_of_date
            ,x_revised_item         => l_revised_item
            ,x_out                  => x_out
           );
           INV_EBI_UTIL.debug_line('STEP 60: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.prepare_component_items STATUS: ' || x_out.output_status.return_status);
           IF (x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
             RAISE  FND_API.g_exc_unexpected_error;
           END IF;

           IF l_revised_item.component_item_tbl IS NOT NULL THEN
             FOR j IN 1..l_revised_item.component_item_tbl.COUNT LOOP
	       INV_EBI_UTIL.debug_line('STEP 70: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.prepare_substitute_components ');
               prepare_substitute_components (
                 p_component_item       => l_revised_item.component_item_tbl(j)
                ,p_from_sequence_id     => l_from_sequence_id
                ,p_reference_org_id     => l_from_org_id
                ,x_component_item       => l_component_item
                ,x_out                  => x_out
               );
	       INV_EBI_UTIL.debug_line('STEP 80: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.prepare_substitute_components STATUS:  '|| x_out.output_status.return_status);
               IF (x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
                 RAISE  FND_API.g_exc_unexpected_error;
               END IF;
               INV_EBI_UTIL.debug_line('STEP 90: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.prepare_reference_designators'||'COMP ITEM NAME: '||l_component_item.component_item_name);
               prepare_reference_designators (
                  p_component_item       => l_component_item
                 ,p_from_sequence_id     => l_from_sequence_id
                 ,p_reference_org_id     => l_from_org_id
                 ,x_component_item       => l_component_item1
                 ,x_out                  => x_out
                );
		INV_EBI_UTIL.debug_line('STEP 100: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.prepare_reference_designators STATUS:  '|| x_out.output_status.return_status);
                IF (x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
                  RAISE  FND_API.g_exc_unexpected_error;
                END IF;

                l_revised_item.component_item_tbl(j) := l_component_item1;
             END LOOP;
           END IF;
           --l_eco_obj.eco_revised_item_type(i) := l_revised_item;
         END IF;
       END IF;
     --END LOOP;
   --END IF;
   x_revised_item_obj := l_revised_item;
   INV_EBI_UTIL.debug_line('STEP 110: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.process_replicate_bom ');
 EXCEPTION
   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO process_replicate_bom_save_pnt;
     x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;
     IF(x_out.output_status.msg_data IS NULL) THEN
       fnd_msg_pub.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count   => x_out.output_status.msg_count
        ,p_data    => x_out.output_status.msg_data
      );
     END IF;
   WHEN OTHERS THEN
     ROLLBACK TO process_replicate_bom_save_pnt;
     x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
     IF (x_out.output_status.msg_data IS NOT NULL) THEN
       x_out.output_status.msg_data      :=  x_out.output_status.msg_data||' ->INV_EBI_CHANGE_ORDER_HELPER.process_replicate_bom ';
     ELSE
       x_out.output_status.msg_data      :=  SQLERRM||'INV_EBI_CHANGE_ORDER_HELPER.process_replicate_bom ';
     END IF;
 END process_replicate_bom;

/************************************************************************************
--      API name        : process_uda
--      Type            : Public
--      Function        :
--
************************************************************************************/
PROCEDURE process_uda (
  p_commit                      IN     VARCHAR2 := FND_API.g_false
 ,p_api_version                 IN     NUMBER DEFAULT 1.0
 ,p_uda_input_obj               IN     inv_ebi_uda_input_obj
 ,p_object_name                 IN     VARCHAR2
 ,p_data_level                  IN     VARCHAR2
 ,p_pk_column_name_value_pairs  IN     EGO_COL_NAME_VALUE_PAIR_ARRAY
 ,p_class_code_name_value_pairs IN     EGO_COL_NAME_VALUE_PAIR_ARRAY
 ,x_uda_output_obj              OUT    NOCOPY inv_ebi_eco_output_obj
)
IS
  l_attributes_row_table   ego_user_attr_row_table;
  l_attributes_data_table  ego_user_attr_data_table;
  l_attributes_row_obj     ego_user_attr_row_obj;
  l_transaction_type       VARCHAR2(20);
  l_uda_out                inv_ebi_uda_output_obj;
  l_output_status          inv_ebi_output_status;
BEGIN
  SAVEPOINT inv_ebi_process_uda_save_pnt;
  INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.process_uda');
  l_uda_out       := inv_ebi_uda_output_obj(NULL,NULL);
  l_output_status := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
  x_uda_output_obj           := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,l_uda_out);
  INV_EBI_UTIL.debug_line('STEP 20: BEFORE CALLING INV_EBI_UTIL.transform_uda');
  --To convert inv_ebi uda objects to ego uda compatible objects
  INV_EBI_UTIL.transform_uda (
    p_uda_input_obj          => p_uda_input_obj
   ,x_attributes_row_table   => l_attributes_row_table
   ,x_attributes_data_table  => l_attributes_data_table
   ,x_return_status          => x_uda_output_obj.output_status.return_status
   ,x_msg_count              => x_uda_output_obj.output_status.msg_count
   ,x_msg_data               => x_uda_output_obj.output_status.msg_data
  );
  INV_EBI_UTIL.debug_line('STEP 30: AFTER CALLING INV_EBI_UTIL.transform_uda STATUS: '|| x_uda_output_obj.output_status.return_status);
  IF (x_uda_output_obj.output_status.return_status <> FND_API.g_ret_sts_success) THEN
      RAISE  FND_API.g_exc_unexpected_error;
  END IF;

  FOR i in 1..l_attributes_row_table.COUNT
  LOOP
    l_attributes_row_obj    :=  l_attributes_row_table(i);
    IF(l_attributes_row_table(i).transaction_type IS NULL) THEN
       l_transaction_type   :=  ego_user_attrs_data_pvt.g_sync_mode;
    ELSE
      l_transaction_type    := l_attributes_row_table(i).transaction_type;
    END IF;
    l_attributes_row_obj := EGO_USER_ATTRS_DATA_PUB.build_attr_group_row_object(
                              p_row_identifier      => i
                             ,p_attr_group_id       => l_attributes_row_obj.attr_group_id
                             ,p_attr_group_app_id   => l_attributes_row_obj.attr_group_app_id
                             ,p_attr_group_type     => l_attributes_row_obj.attr_group_type
                             ,p_attr_group_name     => l_attributes_row_obj.attr_group_name
                             ,p_data_level          => p_data_level
                             ,p_data_level_1        => l_attributes_row_obj.data_level_1
                             ,p_data_level_2        => l_attributes_row_obj.data_level_2
                             ,p_data_level_3        => l_attributes_row_obj.data_level_3
                             ,p_data_level_4        => l_attributes_row_obj.data_level_4
                             ,p_data_level_5        => l_attributes_row_obj.data_level_5
                             ,p_transaction_type    => l_attributes_row_obj.transaction_type
                            );

    l_attributes_row_table(i)  := l_attributes_row_obj;
  END LOOP;
  INV_EBI_UTIL.debug_line('STEP 40: BEFORE CALLING ego_user_attrs_data_pub.process_user_attrs_data');
  --To process uda
  ego_user_attrs_data_pub.process_user_attrs_data(
    p_api_version                 => p_api_version
   ,p_object_name                 => p_object_name
   ,p_attributes_row_table        => l_attributes_row_table
   ,p_attributes_data_table       => l_attributes_data_table
   ,p_pk_column_name_value_pairs  => p_pk_column_name_value_pairs
   ,p_class_code_name_value_pairs => p_class_code_name_value_pairs
   ,p_user_privileges_on_object   => p_uda_input_obj.user_privileges_on_object
   ,p_entity_id                   => p_uda_input_obj.entity_id
   ,p_entity_index                => p_uda_input_obj.entity_index
   ,p_entity_code                 => p_uda_input_obj.entity_code
   ,p_debug_level                 => p_uda_input_obj.debug_level
   ,p_init_error_handler          => p_uda_input_obj.init_error_handler
   ,p_write_to_concurrent_log     => p_uda_input_obj.write_to_concurrent_log
   ,p_init_fnd_msg_list           => p_uda_input_obj.init_fnd_msg_list
   ,p_log_errors                  => p_uda_input_obj.log_errors
   ,p_add_errors_to_fnd_stack     => p_uda_input_obj.add_errors_to_fnd_stack
   ,p_commit                      => p_commit
   ,x_failed_row_id_list          => x_uda_output_obj.uda_output.failed_row_id_list
   ,x_return_status               => x_uda_output_obj.output_status.return_status
   ,x_errorcode                   => x_uda_output_obj.uda_output.errorcode
   ,x_msg_count                   => x_uda_output_obj.output_status.msg_count
   ,x_msg_data                    => x_uda_output_obj.output_status.msg_data
  );
  INV_EBI_UTIL.debug_line('STEP 50: AFTER CALLING ego_user_attrs_data_pub.process_user_attrs_data STATUS: ' || x_uda_output_obj.output_status.return_status);
  IF (x_uda_output_obj.output_status.return_status <> FND_API.g_ret_sts_success) THEN
    RAISE  FND_API.g_exc_unexpected_error;
  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT;
  END IF;
  INV_EBI_UTIL.debug_line('STEP 60: END CALLING INV_EBI_CHANGE_ORDER_HELPER.process_uda');
EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO inv_ebi_process_uda_save_pnt;
    x_uda_output_obj.output_status.return_status :=  FND_API.g_ret_sts_error;

    IF(x_uda_output_obj.output_status.msg_data IS NULL) THEN
      fnd_msg_pub.count_and_get(
        p_encoded => FND_API.g_false
       ,p_count   => x_uda_output_obj.output_status.msg_count
       ,p_data    => x_uda_output_obj.output_status.msg_data
     );
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO inv_ebi_process_uda_save_pnt;
    x_uda_output_obj.output_status.return_status := FND_API.g_ret_sts_unexp_error;
    IF (x_uda_output_obj.output_status.msg_data IS NOT NULL) THEN
       x_uda_output_obj.output_status.msg_data := x_uda_output_obj.output_status.msg_data ||' -> INV_EBI_CHANGE_ORDER_HELPER.process_uda ';
    ELSE
       x_uda_output_obj.output_status.msg_data      :=  SQLERRM||' at INV_EBI_CHANGE_ORDER_HELPER.process_uda ';
    END IF;
END process_uda;
 /************************************************************************************
 --     API name        : process_change_order_uda
 --     Type            : Private
 --     Function        :
 --     This API is used to process Component Level and Structure header udas
 --
 ************************************************************************************/
 PROCEDURE process_change_order_uda(
    p_commit                  IN  VARCHAR2
   ,p_organization_code       IN  VARCHAR2
   ,p_eco_name                IN  VARCHAR2
   ,p_alternate_bom_code      IN  VARCHAR2
   ,p_revised_item_name       IN  VARCHAR2
   ,p_component_tbl           IN  inv_ebi_rev_comp_tbl
   ,p_structure_header        IN  inv_ebi_structure_header_obj
   ,x_out                     OUT NOCOPY inv_ebi_eco_output_obj
 )IS
    l_pkdata ego_col_name_value_pair_array;
    l_pkcode ego_col_name_value_pair_array;
    l_bill_sequence_id          NUMBER;
    l_component_sequence_id     NUMBER;
    l_assembly_item_id          NUMBER;
    l_organization_id           NUMBER;
    l_structure_type_id         NUMBER;
    l_revised_item_sequence_id  NUMBER;
    l_component_item_id         NUMBER;
    l_msg_data                  VARCHAR2(32000);
    l_return_status             VARCHAR2(3);
    l_Error_Table Error_Handler.Error_Tbl_Type;
    l_count                     NUMBER:=0;
    l_uda_out                   inv_ebi_uda_output_obj;
    l_output_status             inv_ebi_output_status;
 BEGIN
   SAVEPOINT inv_ebi_chg_order_uda_save_pnt;
   INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.process_change_order_uda');
   INV_EBI_UTIL.debug_line('STEP 20: ORG CODE: '|| p_organization_code || ' ECO NAME: '|| p_eco_name || ' REVISED ITEM NAME:  '|| p_revised_item_name);
   l_uda_out       := inv_ebi_uda_output_obj(NULL,NULL);
   l_output_status := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
   x_out           := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);

   Error_Handler.initialize;
   IF(p_organization_code IS NOT NULL) THEN

     l_organization_id := INV_EBI_ITEM_HELPER.get_organization_id(
                             p_organization_code  => p_organization_code
                           );
   END IF;
   IF (p_revised_item_name IS NOT NULL) THEN
     l_assembly_item_id := INV_EBI_ITEM_HELPER.get_inventory_item_id (
                             p_organization_id => l_organization_id
                            ,p_item_number     => p_revised_item_name
                           );

   END IF;
   INV_EBI_UTIL.debug_line('STEP 30: ORG ID: '|| l_organization_id || ' ASSY ITEM ID: '|| l_assembly_item_id);
   IF (p_component_tbl IS NOT NULL AND p_component_tbl.COUNT > 0) THEN
     FOR i in 1..p_component_tbl.COUNT
     LOOP
       IF(p_component_tbl(i).component_revision_uda  IS NOT NULL AND p_component_tbl(i).component_revision_uda.attribute_group_tbl.COUNT > 0) THEN
         IF(p_component_tbl(i).component_item_name IS NOT NULL) THEN
           INV_EBI_UTIL.debug_line('STEP 40: COMPONENT ITEM NAME: '|| p_component_tbl(i).component_item_name);
           l_component_item_id := INV_EBI_ITEM_HELPER.get_inventory_item_id (
                                    p_organization_id => l_organization_id
                                   ,p_item_number    => p_component_tbl(i).component_item_name
                                  );

         END IF;

         SELECT bill_sequence_id,structure_type_id INTO l_bill_sequence_id,l_structure_type_id
         FROM bom_bill_of_materials
         WHERE assembly_item_id = l_assembly_item_id
         AND organization_id = l_organization_id
         AND NVL(alternate_bom_designator, 'NONE') = DECODE(p_alternate_bom_code,FND_API.G_MISS_CHAR,'NONE',NULL,'NONE',p_alternate_bom_code) ;

         SELECT component_sequence_id INTO l_component_sequence_id
         FROM bom_components_b
         WHERE bill_sequence_id = l_bill_sequence_id
         AND component_item_id  = l_component_item_id
         AND change_notice = p_eco_name;

         l_pkdata := ego_col_name_value_pair_array();
         l_pkdata.extend(2);
         l_pkdata(1) := ego_col_name_value_pair_obj('COMPONENT_SEQUENCE_ID',l_component_sequence_id);
         l_pkdata(2) := ego_col_name_value_pair_obj('BILL_SEQUENCE_ID',l_bill_sequence_id);
         l_pkcode    := ego_col_name_value_pair_array();
         l_pkcode.extend();
         l_pkcode(1) := ego_col_name_value_pair_obj('STRUCTURE_TYPE_ID',l_structure_type_id);
         INV_EBI_UTIL.debug_line('STEP 50: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.process_uda');
         process_uda(
           p_commit                        =>  p_commit
          ,p_uda_input_obj                 =>  p_component_tbl(i).component_revision_uda
          ,p_object_name                   =>  'BOM_COMPONENTS'
          ,p_data_level                    =>  'COMPONENTS_LEVEL'
          ,p_pk_column_name_value_pairs    =>  l_pkdata
          ,p_class_code_name_value_pairs   =>  l_pkcode
          ,x_uda_output_obj                =>  x_out
         );
         INV_EBI_UTIL.debug_line('STEP 60: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.process_uda STATUS:  '|| x_out.output_status.return_status);
         IF(x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
           RAISE  FND_API.g_exc_unexpected_error;
         END IF;
       END IF;
     END LOOP;
   END IF;

   IF(p_structure_header IS NOT NULL AND p_structure_header.structure_header_uda IS NOT NULL AND p_structure_header.structure_header_uda.attribute_group_tbl.COUNT > 0) THEN

     SELECT bill_sequence_id,structure_type_id INTO l_bill_sequence_id,l_structure_type_id
     FROM bom_bill_of_materials
     WHERE assembly_item_id = l_assembly_item_id
     AND organization_id = l_organization_id
     AND NVL(alternate_bom_designator, 'NONE') = DECODE(p_alternate_bom_code,FND_API.G_MISS_CHAR,'NONE',NULL,'NONE',p_alternate_bom_code) ;

     l_pkdata := ego_col_name_value_pair_array();
     l_pkdata.extend();
     l_pkdata(1) := ego_col_name_value_pair_obj('BILL_SEQUENCE_ID',l_bill_sequence_id);
     l_pkcode    := ego_col_name_value_pair_array();
     l_pkcode.extend();
     l_pkcode(1) := ego_col_name_value_pair_obj('STRUCTURE_TYPE_ID',l_structure_type_id);
     INV_EBI_UTIL.debug_line('STEP 70: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.process_uda FOR STRUCTURE HEADER');
     process_uda(
       p_uda_input_obj                  =>  p_structure_header.structure_header_uda
      ,p_commit                         =>  p_commit
      ,p_object_name                    =>  'BOM_STRUCTURE'
      ,p_data_level                     =>  'STRUCTURES_LEVEL'
      ,p_pk_column_name_value_pairs     =>  l_pkdata
      ,p_class_code_name_value_pairs    =>  l_pkcode
      ,x_uda_output_obj                 =>  x_out
       );
       INV_EBI_UTIL.debug_line('STEP 80: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.process_uda STATUS: '|| x_out.output_status.return_status);
     IF(x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
       RAISE  FND_API.g_exc_unexpected_error;
     END IF;
   END IF;

   IF FND_API.To_Boolean(p_commit) THEN
     COMMIT;
   END IF;
   INV_EBI_UTIL.debug_line('STEP 90: END CALLING INV_EBI_CHANGE_ORDER_HELPER.process_change_order_uda');
EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO inv_ebi_chg_order_uda_save_pnt;
    x_out.output_status.return_status :=  FND_API.g_ret_sts_error;
    IF(x_out.output_status.msg_data IS NULL) THEN
      fnd_msg_pub.count_and_get(
        p_encoded => FND_API.g_false
       ,p_count   => x_out.output_status.msg_count
       ,p_data    => x_out.output_status.msg_data
     );
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO inv_ebi_chg_order_uda_save_pnt;
    x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
    IF (x_out.output_status.msg_data IS NOT NULL) THEN
      x_out.output_status.msg_data := x_out.output_status.msg_data ||' -> INV_EBI_CHANGE_ORDER_HELPER.process_change_order_uda';
    ELSE
      x_out.output_status.msg_data      :=  SQLERRM||' at INV_EBI_CHANGE_ORDER_HELPER.process_change_order_uda';
    END IF;
 END process_change_order_uda;

  /*******************************************************************************
  API name        : Check_Workflow_Process
  Type            : Private
  Purpose         : Checks if there is worflow process for the ECO.
  ********************************************************************************/
  FUNCTION Check_Workflow_Process(
    p_change_order_type_id       IN NUMBER
   ,p_priority_code              IN VARCHAR2 ) RETURN BOOLEAN
  IS
    l_count NUMBER;
  BEGIN
    SELECT count(1)
    INTO   l_count
    FROM  eng_change_type_processes
    WHERE change_order_type_id = p_change_order_type_id
    AND NVL(eng_change_priority_code,'X') = NVL(p_priority_code, 'X');

    IF (l_count > 0) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END Check_Workflow_Process;
 /*******************************************************************************
  API name        : is_task_template_set
  Type            : Public
  Purpose         : Checks if there is task template associated .
  Bug 7218542
 ********************************************************************************/

 FUNCTION is_task_template_set(
      p_change_order_type_id  IN NUMBER
     ,p_organization_id       IN NUMBER
     ,p_status_code           IN NUMBER
   )  RETURN BOOLEAN
 IS
   l_count NUMBER;
 BEGIN
    SELECT COUNT(1) INTO l_count
    FROM
      eng_change_tasks_vl tsk,
      eng_change_type_org_tasks typtsk
    WHERE
      tsk.organization_id = typtsk.organization_id AND
      typtsk.organization_id = p_organization_id AND
      tsk.change_template_id = typtsk.change_template_or_task_id  AND
      typtsk.template_or_task_flag ='E' AND
      typtsk.change_type_id = p_change_order_type_id AND
      typtsk.complete_before_status_code = p_status_code;

    IF (l_count > 0) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

 EXCEPTION
   WHEN OTHERS THEN
     RETURN FALSE;
 END is_task_template_set;

 /*******************************************************************************
  API name        : get_status_name
  Type            : Private
  Purpose         : Get the status name based on look up type and lookup code.
  ********************************************************************************/
  FUNCTION  get_status_name(
    p_lookup_type IN VARCHAR2
   ,p_lookup_code IN VARCHAR2 ) RETURN VARCHAR2
  IS
    l_meaning varchar2(240);
    CURSOR c_lkp IS
    SELECT  meaning
    FROM    FND_LOOKUP_VALUES_VL
    WHERE   lookup_type = p_lookup_type
    AND     lookup_code = p_lookup_code;
  BEGIN
    IF (c_lkp%ISOPEN) THEN
      CLOSE c_lkp;
    END IF;
    OPEN c_lkp;
    FETCH c_lkp INTO l_meaning;
    CLOSE c_lkp;
    RETURN l_meaning;
  EXCEPTION
     WHEN OTHERS THEN
       IF (c_lkp%ISOPEN) THEN
         CLOSE c_lkp;
       END IF;
       NULL;
  END get_status_name;
 /*******************************************************************************
  API name        : GET_EXISTING_COMPONENT_ATTR
  Type            : Private
  Purpose         : Get the ATTRIBUTE OF EXISTING COMPONENT IN CASE OF ACD TYPE(2,3).
  ********************************************************************************/

PROCEDURE get_existing_component_attr(
  p_organization_id        IN  NUMBER
, p_revised_item_name      IN  VARCHAR2
, p_component_item_name    IN  VARCHAR2
, p_op_sequence_number     IN  VARCHAR2
, p_alternate_bom_code     IN  VARCHAR2
, p_bom_update_without_eco IN  VARCHAR2
, p_effectivity_date       IN  DATE
, x_old_effectivity_date   OUT NOCOPY DATE
, x_old_op_sequence_num    OUT NOCOPY VARCHAR2
, x_old_fm_end_item_unit   OUT NOCOPY VARCHAR2
)
IS
  CURSOR C_Bill_seq (p_assembly_item_id NUMBER) IS
    SELECT bill_sequence_id
    FROM bom_bill_of_materials
    WHERE assembly_item_id = p_assembly_item_id
    AND organization_id = p_organization_id
    AND nvl(alternate_bom_designator,'x') = nvl(p_alternate_bom_code,'x');

  --This cursor for redlining of BOM Components.
Cursor c_component(p_rev_item_id NUMBER, p_component_item_id NUMBER, p_bill_sequence_id NUMBER) IS
  SELECT bic.effectivity_date, bic.operation_seq_num, bic.from_end_item_unit_number
  FROM   bom_inventory_components bic
        ,eng_revised_items eri
  WHERE  eri.revised_item_id   = p_rev_item_id
  AND    eri.organization_id   = p_organization_id
  AND    eri.bill_sequence_id  = p_bill_sequence_id
  AND    bic.component_item_id = p_component_item_id
  AND    bic.operation_seq_num = p_op_sequence_number
  AND    bic.bill_sequence_id  = eri.bill_sequence_id
  AND    bic.revised_item_sequence_id = eri.revised_item_sequence_id
  AND    eri.implementation_date = (SELECT MAX(erj.implementation_date)
                                    FROM   bom_inventory_components bcc
                                          ,eng_revised_items erj
                                    WHERE  erj.revised_item_id   = p_rev_item_id
                                    AND    erj.organization_id   = p_organization_id
                                    AND    erj.bill_sequence_id  = p_bill_sequence_id
                                    AND    bcc.component_item_id = p_component_item_id
                                    AND    bcc.operation_seq_num = p_op_sequence_number
                                    AND    bcc.bill_sequence_id  = erj.bill_sequence_id
                                    AND    bcc.revised_item_sequence_id = erj.revised_item_sequence_id
                                    AND    erj.implementation_date IS NOT NULL);
  --Bug 8340804
  CURSOR c_bom_components(  p_component_item_id NUMBER,
                            p_bill_sequence_id  NUMBER) IS

    SELECT bic.effectivity_date, bic.operation_seq_num, bic.from_end_item_unit_number
    FROM bom_inventory_components bic
    WHERE bic.component_item_id =   p_component_item_id
    AND   bic.bill_sequence_id  =   p_bill_sequence_id
    AND   bic.operation_seq_num =   p_op_sequence_number;
    --Start of Bug 9527466
    --AND  ( bic.disable_date     >   p_effectivity_date OR bic.disable_date IS NULL)
    --AND   bic.effectivity_date  <=  p_effectivity_date ;
    --End of Bug 9527466

  l_bill_sequence_id    NUMBER;
  l_assembly_item_id    NUMBER;
  l_organization_id     NUMBER;
  l_component_item_id   NUMBER;
  l_component_cur       c_component%ROWTYPE;
  l_count  NUMBER;

BEGIN
  INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.get_existing_component_attr');
  -- To Retrive revisied item id
  l_assembly_item_id   := INV_EBI_ITEM_HELPER.get_inventory_item_id
                          (p_organization_id => p_organization_id
                          ,p_item_number   => p_revised_item_name);
  INV_EBI_UTIL.debug_line('STEP 20: ASSY ITEM ID: ' || l_assembly_item_id);
  -- Cursor to retrive the bill sequence id
  FOR i in C_Bill_seq(l_assembly_item_id) LOOP
    l_bill_sequence_id := i.bill_sequence_id;
    INV_EBI_UTIL.debug_line('STEP 30: BILL SEQ ID: '|| l_bill_sequence_id);
    EXIT;
  END LOOP;

  --To Retrive Component Item Id
  l_component_item_id   := INV_EBI_ITEM_HELPER.get_inventory_item_id
    ( p_organization_id => p_organization_id
     ,p_item_number     => p_component_item_name);

   INV_EBI_UTIL.debug_line('STEP 40: COMP ITEM ID: '|| l_component_item_id);
   --To Retrive old effectivity date if BOM Components are implemented
   IF c_component%ISOPEN THEN
     CLOSE c_component;
   END IF;
   OPEN c_component(l_assembly_item_id, l_component_item_id, l_bill_sequence_id) ;
   FETCH c_component INTO l_component_cur;
   IF(c_component % ROWCOUNT > 0) THEN

     x_old_effectivity_date := l_component_cur.effectivity_date;
     x_old_op_sequence_num  := l_component_cur.operation_seq_num;
     x_old_fm_end_item_unit := l_component_cur.from_end_item_unit_number;

   ELSE

   /*Start of Bug :8340804 If Item has BOM and no Change Order then retrieve old values from
   bom_inventory_components table */

    IF(p_bom_update_without_eco = FND_API.G_TRUE) THEN

     /*SELECT COUNT(1) INTO l_count
     FROM eng_revised_items
     WHERE revised_item_id = l_assembly_item_id
     AND organization_id = p_organization_id;*/ --  Commented this query for Bug 9527466

     /*Above query was returning a row if item has Change Order associated,but we need
     to check if the BOM component is associated with the CO,if not query the required
     data from bom_inventory_components.So below query is incorporated*/


     --Start of Bug 9527466
     SELECT COUNT(1) INTO l_count
     FROM eng_revised_items eri,
          bom_inventory_components bic
     WHERE eri.revised_item_id   = l_assembly_item_id
     AND   eri.organization_id   = p_organization_id
     AND   eri.bill_sequence_id  = l_bill_sequence_id
     AND   bic.component_item_id = l_component_item_id
     AND   bic.operation_seq_num = p_op_sequence_number
     AND   bic.bill_sequence_id  = eri.bill_sequence_id
     AND   bic.revised_item_sequence_id = eri.revised_item_sequence_id
     AND   bic.change_notice IS NOT NULL;
     --End of Bug 9527466

     IF (l_count = 0) THEN
       FOR l_bom_comps IN c_bom_components(l_component_item_id,l_bill_sequence_id)
       LOOP

         x_old_effectivity_date := l_bom_comps.effectivity_date;
         x_old_op_sequence_num  := l_bom_comps.operation_seq_num;
         x_old_fm_end_item_unit := l_bom_comps.from_end_item_unit_number;
         EXIT;

       END LOOP;
     END IF;
  END IF;
  END IF;
 CLOSE c_component; -- END of Bug 8340804
INV_EBI_UTIL.debug_line('STEP 50: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.get_existing_component_attr');
EXCEPTION
  WHEN OTHERS THEN
    IF c_component%ISOPEN THEN
       CLOSE c_component;
    END IF;
    NULL;
END get_existing_component_attr;

/************************************************************************************
  --     API name        : get_current_item_revision
  --     Type            : Private
  --     Function        :
  --     This API is used to return Current revision record of an item
  -- Bug 7197943
************************************************************************************/
FUNCTION get_current_item_revision(
  p_inventory_item_id  IN NUMBER,
  p_organization_id    IN NUMBER,
  p_date               IN DATE
 ) RETURN VARCHAR2 IS
 l_revision VARCHAR2(3);
  CURSOR c_item_rev(
    p_inventory_item_id  IN NUMBER,
    p_organization_id    IN NUMBER,
    p_revision_date      IN DATE
  ) IS
    SELECT
      revision
    FROM
      mtl_item_revisions_b
    WHERE
      inventory_item_id = p_inventory_item_id  AND
      organization_id = p_organization_id AND
      effectivity_date <= p_revision_date AND
      implementation_date IS NOT NULL
    ORDER BY
      effectivity_date DESC, revision DESC;

    l_item_rev c_item_rev%ROWTYPE;

 BEGIN
   INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.get_current_item_revision');
   INV_EBI_UTIL.debug_line('STEP 20: INV ITEM ID: '|| p_inventory_item_id || ' ORG ID: '|| p_organization_id);
   IF c_item_rev%ISOPEN THEN
     CLOSE c_item_rev;
   END IF;

   OPEN c_item_rev(
           p_inventory_item_id  =>  p_inventory_item_id,
           p_organization_id    =>  p_organization_id,
           p_revision_date      =>  sysdate
        );
   FETCH c_item_rev INTO l_revision;
   CLOSE c_item_rev;
   INV_EBI_UTIL.debug_line('STEP 30: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.get_current_item_revision RETURN VALUE: '|| l_revision);
   RETURN  l_revision;
 EXCEPTION
  WHEN OTHERS THEN
    IF c_item_rev%ISOPEN THEN
      CLOSE c_item_rev;
    END IF;
    NULL;
END get_current_item_revision;

/************************************************************************************
  --     API name        : process_assign_items
  --     Type            : Private
  --     Function        :
  --     This API is used to Assign items to child org if it exists in master org
  --     Other wise raises an exception
  __     BUG 7143083
 ************************************************************************************/

 PROCEDURE process_assign_items(
   p_organization_id       IN  NUMBER ,
   p_item_name             IN  VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2 ,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER
 ) IS
  l_is_item_exists         VARCHAR2(3);
  l_master_org             NUMBER;
  l_approval_status        VARCHAR2(30);
  l_inventory_item_id      NUMBER;
  l_count                  NUMBER  := 0;
  l_item_catalog_group_id  NUMBER;
  l_effectivity_date       DATE;
   CURSOR c_master_item_rev(
          p_inventory_item_id  IN NUMBER,
          p_organization_id    IN NUMBER,
          p_revision_date      IN DATE
       ) IS
  SELECT
    revision,
    revision_id ,
    revision_label,
    revision_reason,
    description,
    attribute_category,
    attribute1 ,
    attribute2 ,
    attribute3 ,
    attribute4 ,
    attribute5 ,
    attribute6 ,
    attribute7 ,
    attribute8 ,
    attribute9 ,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15
  FROM
     mtl_item_revisions_b
  WHERE
    inventory_item_id = p_inventory_item_id  AND
    organization_id = p_organization_id AND
    effectivity_date <= p_revision_date AND
    implementation_date IS NOT NULL
  ORDER BY
    effectivity_date DESC, revision DESC;

   l_master_item_rev c_master_item_rev%ROWTYPE;

 BEGIN
   SAVEPOINT inv_ebi_assign_item_save_pnt;
   INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.process_assign_items');
   INV_EBI_UTIL.debug_line('STEP 20: ORG ID : '|| p_organization_id || ' ITEM NAME:  '|| p_item_name);

   x_return_status         := FND_API.G_RET_STS_SUCCESS;
   l_is_item_exists := INV_EBI_ITEM_HELPER.is_item_exists(
                                    p_organization_id  => p_organization_id
                                   ,p_item_number      => p_item_name
                                 );
   IF (l_is_item_exists = FND_API.g_false) THEN

     l_master_org := INV_EBI_UTIL.get_master_organization(
                        p_organization_id  => p_organization_id
                     );
     l_is_item_exists := INV_EBI_ITEM_HELPER.is_item_exists(
                                    p_organization_id  =>  l_master_org
                                   ,p_item_number      =>  p_item_name
                                   );

     /* If Item does not exist in context org(child org) and it exists in master org
        and if it approved in master org and ASSIGN_ITEM_TO_CHILD_ORG is set
        to true then item should be assigned to context org */

     IF(l_is_item_exists = FND_API.g_true ) THEN
       IF(get_assign_item = FND_API.g_true ) THEN
         IF(INV_EBI_UTIL.is_pim_installed) THEN
           SELECT item_catalog_group_id,  approval_status
           INTO   l_item_catalog_group_id, l_approval_status
           FROM   mtl_system_items_kfv
           WHERE  organization_id = l_master_org
           AND    concatenated_segments = p_item_name;
           IF (INV_EBI_ITEM_HELPER.is_new_item_request_reqd( l_item_catalog_group_id ) = FND_API.g_true) AND l_approval_status <> 'A'
           THEN
             FND_MSG_PUB.initialize();
             FND_MESSAGE.set_name('INV','INV_EBI_INVALID_APROVAL_STS');
             FND_MESSAGE.set_token('ITEM_NUMBER',p_item_name);
             FND_MESSAGE.set_token('ORGANIZATION_ID',l_master_org);
             FND_MESSAGE.set_token('CHILD_ORGANIZATION_ID',p_organization_id);
             FND_MSG_PUB.add;
             RAISE FND_API.g_exc_unexpected_error;
           END IF;
         END IF;
	 INV_EBI_UTIL.debug_line('STEP 30: BEFORE CALLING EGO_ITEM_PUB.assign_item_to_org');
         EGO_ITEM_PUB.assign_item_to_org(
           p_api_version          => 1.0
          ,p_commit               => FND_API.g_false
          ,p_Item_Number          => p_item_name
          ,p_Organization_Id      => p_organization_id
          ,x_return_status        => x_return_status
          ,x_msg_count            => x_msg_count
         );
	 INV_EBI_UTIL.debug_line('STEP 40: AFTER CALLING EGO_ITEM_PUB.assign_item_to_org STATUS:  ' || x_return_status);
         IF (x_return_status <> FND_API.g_ret_sts_success) THEN
           RAISE  FND_API.g_exc_unexpected_error;
         END IF;
         l_inventory_item_id := INV_EBI_ITEM_HELPER.get_inventory_item_id (
                                   p_organization_id => l_master_org
                                  ,p_item_number     => p_item_name
                                );
	 INV_EBI_UTIL.debug_line('STEP 50: INV ITEM ID: '||l_inventory_item_id);
         --To get effectivity date of recently created revision in context org
         l_effectivity_date  := get_latest_effectivity_date(
                                  p_inventory_item_id  =>  l_inventory_item_id,
                                  p_organization_id    =>  p_organization_id
                                );

         --To get current revision from master org
         IF c_master_item_rev%ISOPEN THEN
           CLOSE c_master_item_rev;
         END IF;

         OPEN c_master_item_rev(
                 p_inventory_item_id  =>  l_inventory_item_id,
                 p_organization_id    =>  l_master_org,
                 p_revision_date      =>  sysdate
              );
         FETCH c_master_item_rev INTO l_master_item_rev;
         CLOSE c_master_item_rev;

         --To check if master orgs current reviison is already there in context org
         SELECT COUNT(1) INTO l_count
         FROM
           mtl_item_revisions_b mir,
           mtl_system_items_kfv msi
         WHERE
           mir.organization_id = msi.organization_id AND
           msi.organization_id = p_organization_id AND
           mir.inventory_item_id = msi.inventory_item_id AND
           msi.concatenated_segments = p_item_name AND
           mir.revision = l_master_item_rev.revision;

         --If master orgs current revision is not there in context org,create it
         IF(l_count = 0) THEN
           l_effectivity_date  := l_effectivity_date + 1/86400; -- To keep efectivity date of next rev 1 sec higher than earlier rev
           INV_EBI_UTIL.debug_line('STEP 60: BEFORE CALLING EGO_ITEM_PUB.Process_Item_Revision');
           EGO_ITEM_PUB.Process_Item_Revision(
             p_api_version              => 1.0
            ,p_init_msg_list            => FND_API.g_false
            ,p_commit                   => FND_API.g_false
            ,p_transaction_type         => INV_EBI_ITEM_PUB.g_otype_create
            ,p_inventory_item_id        => NULL
            ,p_item_number              => p_item_name
            ,p_organization_id          => p_organization_id
            ,p_Organization_Code        => NULL
            ,p_revision                 => l_master_item_rev.revision
            ,p_description              => l_master_item_rev.description
            ,p_effectivity_date         => l_effectivity_date
            ,p_revision_label           => l_master_item_rev.revision_label
            ,p_revision_reason          => l_master_item_rev.revision_reason
            ,p_lifecycle_id             => NULL
            ,p_current_phase_id         => NULL
            ,p_attribute_category       => l_master_item_rev.attribute_category
            ,p_attribute1               => l_master_item_rev.attribute1
            ,p_attribute2               => l_master_item_rev.attribute2
            ,p_attribute3               => l_master_item_rev.attribute3
            ,p_attribute4               => l_master_item_rev.attribute4
            ,p_attribute5               => l_master_item_rev.attribute5
            ,p_attribute6               => l_master_item_rev.attribute6
            ,p_attribute7               => l_master_item_rev.attribute7
            ,p_attribute8               => l_master_item_rev.attribute8
            ,p_attribute9               => l_master_item_rev.attribute9
            ,p_attribute10              => l_master_item_rev.attribute10
            ,p_attribute11              => l_master_item_rev.attribute11
            ,p_attribute12              => l_master_item_rev.attribute12
            ,p_attribute13              => l_master_item_rev.attribute13
            ,p_attribute14              => l_master_item_rev.attribute14
            ,p_attribute15              => l_master_item_rev.attribute15
            ,x_return_status            => x_return_status
            ,x_msg_count                => x_msg_data
            ,x_msg_data                 => x_msg_count
           ) ;
           INV_EBI_UTIL.debug_line('STEP 70: AFTER CALLING EGO_ITEM_PUB.Process_Item_Revision STATUS:  '|| x_return_status);
           IF (x_return_status <> FND_API.g_ret_sts_success) THEN
             RAISE  FND_API.g_exc_unexpected_error;
           END IF;
         END IF;
       END IF;
     ELSE
       FND_MESSAGE.set_name('INV','INV_EBI_ITEM_NO_MASTER_ORG');
       FND_MESSAGE.set_token('ITEM', p_item_name);
       FND_MSG_PUB.add;
       RAISE  FND_API.g_exc_error;
     END IF;
   END IF;
   INV_EBI_UTIL.debug_line('STEP 80: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.process_assign_items ');
   EXCEPTION
   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO inv_ebi_assign_item_save_pnt;
     x_return_status :=  FND_API.g_ret_sts_unexp_error;

     IF c_master_item_rev%ISOPEN THEN
       CLOSE c_master_item_rev;
     END IF;
     IF(x_msg_data IS NULL) THEN
       fnd_msg_pub.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data
      );
    END IF;
    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO inv_ebi_assign_item_save_pnt;
      x_return_status :=  FND_API.g_ret_sts_error;

      IF c_master_item_rev%ISOPEN THEN
        CLOSE c_master_item_rev;
      END IF;
      IF(x_msg_data IS NULL) THEN
        FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false
         ,p_count   => x_msg_count
         ,p_data    => x_msg_data
       );
    END IF;
    WHEN OTHERS THEN
      ROLLBACK TO inv_ebi_assign_item_save_pnt;
      x_return_status := FND_API.g_ret_sts_unexp_error;

      IF c_master_item_rev%ISOPEN THEN
        CLOSE c_master_item_rev;
      END IF;
      IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> INV_EBI_CHANGE_ORDER_HELPER.process_assign_items ';
      ELSE
        x_msg_data      :=  SQLERRM||' INV_EBI_CHANGE_ORDER_HELPER.process_assign_items ';
      END IF;
 END process_assign_items;

 /************************************************************************************
 --     API name        : get_change_type_code
 --     Type            : Public
 --     Function        :
 --     This API is used to return change_type_code based on change_order_type_id
 --     From DVM
 ************************************************************************************/
 FUNCTION get_change_type_code(p_change_type_id   IN  NUMBER )
 RETURN VARCHAR2
 IS
   l_change_type_code VARCHAR2(80);
 BEGIN

   SELECT  type_name
   INTO    l_change_type_code
   FROM    eng_change_order_types_vl
   WHERE   change_order_type_id = p_change_type_id
   AND     change_mgmt_type_code = 'CHANGE_ORDER'
   AND     type_classification='HEADER';

   RETURN l_change_type_code;
 EXCEPTION
   WHEN OTHERS THEN
     RETURN NULL;
 END get_change_type_code;

  /************************************************************************************
  --     API name        : get_eco_status_name
  --     Type            : Public
  --     Function        :
  --     This API is used to return ECO status_name based on status_CODE
  --     From DVM
  ************************************************************************************/

 FUNCTION get_eco_status_name(p_status_code IN NUMBER)
 RETURN VARCHAR2
 IS
   l_status_name VARCHAR2(30);
 BEGIN

   SELECT status_name
   INTO   l_status_name
   FROM   eng_change_statuses_vl
   WHERE  status_code = p_status_code;

   RETURN l_status_name;
 EXCEPTION
   WHEN OTHERS THEN
     NULL;
 END get_eco_status_name;

  /************************************************************************************
     --     API name        : process_common_comps
     --     Type            : Private
     --     Function        :
     --     This API is used to find the components and substitute comps attached to the
     --     common bom. Bug 7127027
   ************************************************************************************/

  PROCEDURE process_common_comps(
    p_assembly_item_id        IN NUMBER,
    p_organization_id         IN NUMBER,
    p_src_organization_id     IN NUMBER,
    p_src_bill_sequence_id    IN NUMBER,
    x_return_status           OUT NOCOPY VARCHAR2 ,
    x_msg_data                OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER
  ) IS

    l_bom_item_type            NUMBER;
    l_base_item_flag           NUMBER;
    l_replenish_to_order_flag  VARCHAR2(1);
    l_pick_components_flag     VARCHAR2(1);
    l_assm_type                NUMBER;
    l_master_org               NUMBER;

    CURSOR c_common_comps (
         p_assy_type                   IN NUMBER,
         p_item_type                   IN NUMBER,
         p_base_item_flag              IN NUMBER,
         p_pick_components_flag        IN VARCHAR2,
         p_replenish_to_order_flag     IN VARCHAR2
    ) IS

    SELECT
      msi.concatenated_segments component_item_name ,
      bic.component_item_id
    FROM
      bom_inventory_components bic,
      mtl_system_items_kfv   msi
    WHERE
     bic.bill_sequence_id = p_src_bill_sequence_id AND
     bic.component_item_id = msi.inventory_item_id AND
     msi.organization_id = p_src_organization_id AND
     NVL(bic.disable_date, sysdate + 1) >= sysdate AND
     NOT EXISTS
     (  SELECT 'x'
        FROM mtl_system_items_kfv s
        WHERE s.organization_id = p_organization_id
        AND s.inventory_item_id = bic.component_item_id
        AND ((p_assy_type = 1 AND s.eng_item_flag = 'N')
              OR (p_assy_type = 2)
            )
        AND s.inventory_item_id <> p_assembly_item_id
        AND ((p_item_type = 1 AND s.bom_item_type <> 3)
           OR (p_item_type = 2 AND s.bom_item_type <> 3)
           OR (p_item_type = 3)
           OR (p_item_type = 4
               AND (s.bom_item_type = 4
                    OR(
                       s.bom_item_type IN (2, 1)
                       AND s.replenish_to_order_flag = 'Y'
                       AND p_base_item_flag IS NOT NULL
                       AND p_replenish_to_order_flag = 'Y'
                      )
                   )
              )
          )
          AND (p_item_type = 3
           OR
             p_pick_components_flag = 'Y'
           OR
            s.pick_components_flag = 'N'
          )
          AND (p_item_type = 3
               OR
               NVL(s.bom_item_type, 4) <> 2
                  OR
              (s.bom_item_type = 2
              AND (( p_pick_components_flag = 'Y'
                     AND s.pick_components_flag = 'Y'
                    )
                    OR ( p_replenish_to_order_flag = 'Y'
                         AND s.replenish_to_order_flag = 'Y'
                        )
                   )
              )
             )
         AND NOT( p_item_type = 4
              AND p_pick_components_flag = 'Y'
              AND s.bom_item_type = 4
              AND s.replenish_to_order_flag = 'Y'
                                            )
         );
    l_common_comps  c_common_comps%ROWTYPE;

    CURSOR c_common_sub_comps(
      p_assy_type                   IN NUMBER,
      p_item_type                   IN NUMBER,
      p_base_item_flag              IN NUMBER,
      p_pick_components_flag        IN VARCHAR2,
      p_replenish_to_order_flag     IN VARCHAR2
   ) IS

    SELECT
      msi.concatenated_segments sub_comp_item_name ,
      bsc.substitute_component_id
    FROM bom_inventory_components bic,
      bom_substitute_components bsc,
      mtl_system_items_kfv msi
    WHERE bic.bill_sequence_id = p_src_bill_sequence_id
      AND bic.component_sequence_id = bsc.component_sequence_id
      AND bsc.substitute_component_id = msi.inventory_item_id
      AND msi.organization_id = p_src_organization_id
      AND bsc.substitute_component_id NOT IN
          (SELECT msi1.inventory_item_id
           FROM mtl_system_items msi1, mtl_system_items msi2
           WHERE msi1.organization_id = p_organization_id
             AND msi1.inventory_item_id = bsc.substitute_component_id
             AND msi2.organization_id = p_src_organization_id
             AND msi2.inventory_item_id = msi1.inventory_item_id
             AND ((p_assy_type = 1 AND msi1.eng_item_flag = 'N')
                   OR (p_assy_type = 2)
                 )
             AND msi1.inventory_item_id <> p_assembly_item_id
             AND ( (p_item_type = 1 AND msi1.bom_item_type <> 3)
                   OR (p_item_type = 2 AND msi1.bom_item_type <> 3)
                   OR (p_item_type = 3)
                   OR ( p_item_type = 4
                        AND ( msi1.bom_item_type = 4
                             OR ( msi1.bom_item_type IN (2, 1)
                                  AND msi1.replenish_to_order_flag = 'Y'
                                  AND p_base_item_flag IS NOT NULL
                                  AND p_replenish_to_order_flag = 'Y'
                                )
                            )
                      )
               )
             AND (p_item_type = 3
                  OR
                  p_pick_components_flag = 'Y'
                  OR
                 msi1.pick_components_flag = 'N'
                 )
             AND (p_item_type = 3
                  OR
                  NVL(msi1.bom_item_type, 4) <> 2
                     OR
                     (msi1.bom_item_type = 2
                      AND (( p_pick_components_flag = 'Y'
                            AND msi1.pick_components_flag = 'Y'
                            )
                        OR ( p_replenish_to_order_flag = 'Y'
                            AND msi1.replenish_to_order_flag = 'Y'
                           )
                          )
                     )
                 )
             AND NOT( p_item_type = 4
                 AND p_pick_components_flag = 'Y'
                 AND msi1.bom_item_type = 4
                 AND msi1.replenish_to_order_flag = 'Y'
                )
          );

    l_common_sub_comps c_common_sub_comps%ROWTYPE;
  BEGIN
     INV_EBI_UTIL.DEBUG_LINE('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.process_common_comps');
     INV_EBI_UTIL.DEBUG_LINE('STEP 20: ASSY ITEM ID: '|| p_assembly_item_id  || ' ORG ID:  '|| p_organization_id || ' SRC ORG ID: '|| p_src_organization_id);
     SAVEPOINT inv_ebi_comm_comp_save_pnt;
     x_return_status         := FND_API.G_RET_STS_SUCCESS;

     SELECT
       bom_item_type,
       base_item_id,
       replenish_to_order_flag,
       pick_components_flag ,
       DECODE(eng_item_flag, 'Y', 2, 1)
      INTO
        l_bom_item_type,
        l_base_item_flag,
        l_replenish_to_order_flag,
        l_pick_components_flag,
        l_assm_type
      FROM
        mtl_system_items
     WHERE
       inventory_item_id = p_assembly_item_id AND
       organization_id = p_organization_id;

     OPEN c_common_comps(
            p_assy_type                =>   l_assm_type ,
            p_item_type                =>   l_bom_item_type,
            p_base_item_flag           =>   l_base_item_flag,
            p_pick_components_flag     =>   l_pick_components_flag,
            p_replenish_to_order_flag  =>   l_replenish_to_order_flag
          );
     LOOP

       FETCH c_common_comps INTO l_common_comps;
       EXIT WHEN c_common_comps%NOTFOUND;
       INV_EBI_UTIL.DEBUG_LINE('STEP 30: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.process_assign_items ');
       INV_EBI_UTIL.DEBUG_LINE('STEP 40: COMPONENT ITEM NAME: '|| l_common_comps.component_item_name);
       process_assign_items(
         p_organization_id        =>  p_organization_id,
         p_item_name              =>  l_common_comps.component_item_name,
         x_return_status          =>  x_return_status ,
         x_msg_data               =>  x_msg_data ,
         x_msg_count              =>  x_msg_count
       );
       INV_EBI_UTIL.debug_line('STEP 50: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.process_assign_items STATUS: '|| x_return_status);
       IF (x_return_status <> FND_API.g_ret_sts_success) THEN
         RAISE  FND_API.g_exc_unexpected_error;
       END IF;
     END LOOP;
     CLOSE c_common_comps;

     OPEN c_common_sub_comps(
        p_assy_type                =>   l_assm_type  ,
        p_item_type                =>   l_bom_item_type,
        p_base_item_flag           =>   l_base_item_flag,
        p_pick_components_flag     =>   l_pick_components_flag,
        p_replenish_to_order_flag  =>   l_replenish_to_order_flag
     );
     LOOP

       FETCH c_common_sub_comps INTO l_common_sub_comps;
       EXIT WHEN c_common_sub_comps%NOTFOUND;
       INV_EBI_UTIL.DEBUG_LINE('STEP 60: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.process_assign_items for substitute components');
       INV_EBI_UTIL.DEBUG_LINE('STEP 70: SUBSTITUTE COMP NAME:  '|| l_common_sub_comps.sub_comp_item_name);
       process_assign_items(
         p_organization_id        =>  p_organization_id,
         p_item_name              =>  l_common_sub_comps.sub_comp_item_name,
         x_return_status          =>  x_return_status ,
         x_msg_data               =>  x_msg_data ,
         x_msg_count              =>  x_msg_count
       );
       INV_EBI_UTIL.DEBUG_LINE('STEP 80: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.process_assign_items for substitute components STATUS :' || x_return_status);

       IF (x_return_status <> FND_API.g_ret_sts_success) THEN
         RAISE  FND_API.g_exc_unexpected_error;
       END IF;
     END LOOP;
     CLOSE c_common_sub_comps ;
     INV_EBI_UTIL.debug_line('STEP 90: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.process_common_comps');
     EXCEPTION
     WHEN FND_API.g_exc_unexpected_error THEN
       ROLLBACK TO inv_ebi_comm_comp_save_pnt;
       IF (c_common_comps%ISOPEN) THEN
         CLOSE c_common_comps;
       END IF;
       IF (c_common_sub_comps%ISOPEN) THEN
         CLOSE c_common_sub_comps;
       END IF;
       x_return_status :=  FND_API.g_ret_sts_error;
       IF(x_msg_data IS NULL) THEN
         fnd_msg_pub.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
        );
     END IF;
     WHEN OTHERS THEN
       ROLLBACK TO inv_ebi_comm_comp_save_pnt;
       IF (c_common_comps%ISOPEN) THEN
         CLOSE c_common_comps;
       END IF;
       IF (c_common_sub_comps%ISOPEN) THEN
         CLOSE c_common_sub_comps;
       END IF;
       x_return_status := FND_API.g_ret_sts_unexp_error;
       IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> INV_EBI_CHANGE_ORDER_HELPER.process_common_comps ';
       ELSE
         x_msg_data      :=  SQLERRM||' INV_EBI_CHANGE_ORDER_HELPER.process_common_comps ';
       END IF;
   END process_common_comps;


  /************************************************************************************
    --     API name        : process_common_bom
    --     Type            : Private
    --     Function        :
    --     This API is used to determine the coomon bill sequence id and detremine the
    --     Common comps and common susbstitute comps.
    -- Bug 7127027
   ************************************************************************************/

  PROCEDURE process_common_bom(
     p_organization_code          IN  VARCHAR2
    ,p_assembly_item_name         IN  VARCHAR2
    ,p_alternate_bom_code         IN  VARCHAR2
    ,p_common_assembly_item_name  IN  VARCHAR2
    ,p_common_organization_code   IN  VARCHAR2
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
  )
   IS
    l_src_bill_sequence_id     NUMBER;
    l_src_assembly_item_id     NUMBER;
    l_src_organization_id      NUMBER;
    l_assembly_item_id         NUMBER;
    l_organization_id          NUMBER;


   BEGIN
     SAVEPOINT inv_ebi_comm_bom_save_pnt;
     x_return_status         := FND_API.G_RET_STS_SUCCESS;
     INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.process_common_bom');
     INV_EBI_UTIL.debug_line('STEP 20: ORG CODE : '|| p_organization_code || ' ASSY ITEM NAME: '|| p_assembly_item_name ||
                                      ' COMMON ASSY ITEM NAME: '|| p_common_assembly_item_name || ' COMMON ORG CODE: '|| p_common_organization_code);
     l_src_organization_id   := INV_EBI_ITEM_HELPER.get_organization_id(
                                   p_organization_code => p_common_organization_code
                                );
     l_src_assembly_item_id  := INV_EBI_ITEM_HELPER.get_inventory_item_id (
                                  p_organization_id => l_src_organization_id
                                 ,p_item_number     => p_common_assembly_item_name
                                );
     l_src_bill_sequence_id  := get_bill_sequence_id(
                                  p_assembly_item_id    =>  l_src_assembly_item_id,
                                  p_organization_id     =>  l_src_organization_id,
                                  p_alternate_bom_code  =>  p_alternate_bom_code
                                );
     INV_EBI_UTIL.debug_line('STEP 30: ORG ID '|| l_src_organization_id || ' ASSY ITEM ID:  '|| l_src_assembly_item_id ||
                                       'BILL SEQUENCE ID: '|| l_src_bill_sequence_id);
     IF(l_src_bill_sequence_id IS NULL ) THEN
       FND_MESSAGE.set_name('INV','INV_EBI_COMMON_BILL_NOT_FOUND');
       FND_MESSAGE.set_token('ASSY_ITEM', p_common_assembly_item_name);
       FND_MSG_PUB.add;
       RAISE FND_API.g_exc_error;
     END IF;

     l_organization_id   := INV_EBI_ITEM_HELPER.get_organization_id(
                              p_organization_code => p_organization_code
                            );

     l_assembly_item_id  := INV_EBI_ITEM_HELPER.get_inventory_item_id (
                              p_organization_id => l_organization_id
                             ,p_item_number     => p_assembly_item_name
                       );
     INV_EBI_UTIL.debug_line('STEP 40: ASST ITEM ID: '|| l_assembly_item_id || 'ORG ID: '|| l_organization_id );
     INV_EBI_UTIL.debug_line('STEP 50: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.process_common_comps ');
     process_common_comps(
       p_assembly_item_id        => l_assembly_item_id,
       p_organization_id         => l_organization_id,
       p_src_organization_id     => l_src_organization_id,
       p_src_bill_sequence_id    => l_src_bill_sequence_id,
       x_return_status           => x_return_status,
       x_msg_data                => x_msg_data,
       x_msg_count               => x_msg_count
     );
     INV_EBI_UTIL.debug_line('STEP 60: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.process_common_comps STATUS: '|| x_return_status);
     IF (x_return_status <> FND_API.g_ret_sts_success) THEN
       RAISE  FND_API.g_exc_unexpected_error;
     END IF;
    INV_EBI_UTIL.debug_line('STEP 70: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.process_common_bom ');
    EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO inv_ebi_comm_bom_save_pnt;
      x_return_status :=  FND_API.g_ret_sts_unexp_error;
      IF(x_msg_data IS NULL) THEN
        fnd_msg_pub.count_and_get(
          p_encoded => FND_API.g_false
         ,p_count   => x_msg_count
         ,p_data    => x_msg_data
       );
    END IF;
    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO inv_ebi_comm_bom_save_pnt;
      x_return_status :=  FND_API.g_ret_sts_error;
      IF(x_msg_data IS NULL) THEN
        FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false
         ,p_count   => x_msg_count
         ,p_data    => x_msg_data
       );
    END IF;
    WHEN OTHERS THEN
      ROLLBACK TO inv_ebi_comm_bom_save_pnt;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data ||' -> INV_EBI_CHANGE_ORDER_HELPER.process_common_bom ';
      ELSE
        x_msg_data      :=  SQLERRM||' INV_EBI_CHANGE_ORDER_HELPER.process_common_bom ';
      END IF;
   END process_common_bom;

  /************************************************************************************
     --     API name        : get_common_bom_orgs
     --     Type            : Private
     --     Function        :
     --     This API is used to get orgs list to which a bom is commoned
     --     Bug 7196996
  ************************************************************************************/
   PROCEDURE  get_common_bom_orgs(
     p_assembly_item_name    IN  VARCHAR2,
     p_organization_code     IN  VARCHAR2,
     p_alternate_bom_code    IN  VARCHAR2,
     x_common_orgs           OUT NOCOPY inv_ebi_org_tbl,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_data              OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER
   ) IS
     l_bill_sequence_id   NUMBER;
     l_organization_id    NUMBER;
     l_assembly_item_id   NUMBER;
     l_org_count          NUMBER := 0;

     CURSOR c_common_orgs(
               p_bill_sequence_id     IN NUMBER,
               p_common_assy_item_id  IN NUMBER,
               p_common_org_id        IN NUMBER
            ) IS

       SELECT organization_id
       FROM bom_bill_of_materials
       WHERE
         common_bill_sequence_id = p_bill_sequence_id AND
         common_assembly_item_id = p_common_assy_item_id AND
         common_organization_id  = p_common_org_id;

   BEGIN
     INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.get_common_bom_orgs');
     INV_EBI_UTIL.debug_line('STEP 20: ASSY ITEM NAME: '|| p_assembly_item_name ||' ORG CODE: '|| p_organization_code);

     x_return_status         := FND_API.G_RET_STS_SUCCESS;
     l_organization_id  := INV_EBI_ITEM_HELPER.get_organization_id(
                                  p_organization_code => p_organization_code
                           );

     l_assembly_item_id :=  INV_EBI_ITEM_HELPER.get_inventory_item_id (
                                p_organization_id => l_organization_id
                               ,p_item_number     => p_assembly_item_name);

     l_bill_sequence_id := get_bill_sequence_id(
                             p_assembly_item_id    =>  l_assembly_item_id,
                             p_organization_id     =>  l_organization_id,
                             p_alternate_bom_code  =>  p_alternate_bom_code
                           );
     INV_EBI_UTIL.debug_line('STEP 30: ORG ID '|| l_organization_id || ' ASSY ITEM ID: '|| l_assembly_item_id || ' BILL SEQ ID:  '|| l_bill_sequence_id);
    x_common_orgs := inv_ebi_org_tbl();
    FOR l_common_orgs IN  c_common_orgs(
                             p_bill_sequence_id     => l_bill_sequence_id,
                             p_common_assy_item_id  => l_assembly_item_id,
                             p_common_org_id        => l_organization_id
                          )
    LOOP
      IF(l_common_orgs.organization_id <> l_organization_id) THEN
        l_org_count := l_org_count + 1;
        x_common_orgs.extend();
        x_common_orgs(l_org_count) := inv_ebi_org_obj(NULL,NULL);
        x_common_orgs(l_org_count).org_id := l_common_orgs.organization_id;
      END IF;
    END LOOP;
    INV_EBI_UTIL.debug_line('STEP 40: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.get_common_bom_orgs STATUS:  '|| x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data ||' -> INV_EBI_CHANGE_ORDER_HELPER.get_common_bom_orgs ';
      ELSE
       x_msg_data      :=  SQLERRM||' INV_EBI_CHANGE_ORDER_HELPER.get_common_bom_orgs ';
      END IF;
   END get_common_bom_orgs;

   /************************************************************************************
     --     API name        : process_common_bom_orgs
     --     Type            : Private
     --     Function        :
     --     This API is used to Process bom and common bom.
     --     Bug 7196996
   ************************************************************************************/
   PROCEDURE process_common_bom_orgs(
     p_assembly_item_name    IN VARCHAR2,
     p_organization_code     IN VARCHAR2,
     p_alternate_bom_code    IN VARCHAR2,
     p_component_item_tbl    IN inv_ebi_rev_comp_tbl,
     x_out                   OUT NOCOPY inv_ebi_eco_output_obj
   ) IS
     l_common_orgs           inv_ebi_org_tbl;
     l_output_status         inv_ebi_output_status;
     l_count                 NUMBER;
   BEGIN
     SAVEPOINT inv_ebi_common_orgs_save_pnt;
     INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.process_common_bom_orgs');
     INV_EBI_UTIL.debug_line('STEP 20: ASSY ITEM NAME: '|| p_assembly_item_name || ' ORG CODE: '|| p_organization_code);

     l_output_status    := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
     x_out              := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);
     l_common_orgs := inv_ebi_org_tbl();

     --Get the list of orgs to which particular bom is commoned
     INV_EBI_UTIL.debug_line('STEP 30: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.get_common_bom_orgs');
     get_common_bom_orgs(
        p_assembly_item_name    =>  p_assembly_item_name,
        p_organization_code     =>  p_organization_code,
        p_alternate_bom_code    =>  p_alternate_bom_code,
        x_common_orgs           =>  l_common_orgs,
        x_return_status         =>  x_out.output_status.return_status ,
        x_msg_data              =>  x_out.output_status.msg_data ,
        x_msg_count             =>  x_out.output_status.msg_count
     ) ;
     INV_EBI_UTIL.debug_line('STEP 40: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.get_common_bom_orgs STATUS: '|| x_out.output_status.return_status);
     IF (x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
       RAISE  FND_API.g_exc_unexpected_error;
     END IF;

     FOR i IN 1..l_common_orgs.COUNT LOOP
       IF(p_component_item_tbl IS NOT NULL AND p_component_item_tbl.COUNT > 0) THEN
         FOR j IN 1..p_component_item_tbl.COUNT LOOP
           IF( p_component_item_tbl(j).acd_type = 1 ) THEN

             /*After commoning a bom to other orgs if components or sub com are added
               to source ensure that those comps and sub comps exists in all the commoned orgs */
	     INV_EBI_UTIL.debug_line('STEP 50: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.process_assign_items');
	     INV_EBI_UTIL.debug_line('STEP 60: ORG ID: '|| l_common_orgs(i).org_id || 'COMP ITEM NAME:   '|| p_component_item_tbl(j).component_item_name);
             process_assign_items(
               p_organization_id        =>  l_common_orgs(i).org_id,
               p_item_name              =>  p_component_item_tbl(j).component_item_name,
               x_return_status          =>  x_out.output_status.return_status ,
               x_msg_data               =>  x_out.output_status.msg_data ,
               x_msg_count              =>  x_out.output_status.msg_count
             );
	     INV_EBI_UTIL.debug_line('STEP 70: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.process_assign_items STATUS:  '|| x_out.output_status.return_status);
             IF (x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
               RAISE  FND_API.g_exc_unexpected_error;
             END IF;
           END IF;

           IF( p_component_item_tbl(j).substitute_component_tbl IS NOT NULL AND
               p_component_item_tbl(j).substitute_component_tbl .COUNT > 0) THEN
             FOR k IN 1..p_component_item_tbl(j).substitute_component_tbl.COUNT LOOP

               IF(p_component_item_tbl(j).substitute_component_tbl(k).acd_type = 1) THEN
	         INV_EBI_UTIL.debug_line('STEP 80: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.process_assign_items FOR SUBSTITUTE COMPONENTS');
		 INV_EBI_UTIL.debug_line('STEP 90: SUBS COMP ITEM NAME:  '|| p_component_item_tbl(j).substitute_component_tbl(k).substitute_component_name);
                 process_assign_items(
                   p_organization_id        =>  l_common_orgs(i).org_id,
                   p_item_name              =>  p_component_item_tbl(j).substitute_component_tbl(k).substitute_component_name,
                   x_return_status          =>  x_out.output_status.return_status ,
                   x_msg_data               =>  x_out.output_status.msg_data ,
                   x_msg_count              =>  x_out.output_status.msg_count
                 );
		 INV_EBI_UTIL.debug_line('STEP 100: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.process_assign_items STATUS:  '|| x_out.output_status.return_status);
                 IF (x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
                    RAISE  FND_API.g_exc_unexpected_error;
                 END IF;
               END IF;
             END LOOP;
           END IF;
         END LOOP;
       END IF;
     END LOOP;
   INV_EBI_UTIL.debug_line('STEP 110: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.process_common_bom_orgs ');
   EXCEPTION
     WHEN FND_API.g_exc_unexpected_error THEN
       ROLLBACK TO inv_ebi_common_orgs_save_pnt;
       x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;
       IF(x_out.output_status.msg_data IS NULL) THEN
         fnd_msg_pub.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_out.output_status.msg_count
          ,p_data    => x_out.output_status.msg_data
        );
       END IF;
     WHEN OTHERS THEN
        ROLLBACK TO inv_ebi_common_orgs_save_pnt;
        x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
        IF (x_out.output_status.msg_data IS NOT NULL) THEN
          x_out.output_status.msg_data      :=  x_out.output_status.msg_data||' -> INV_EBI_CHANGE_ORDER_HELPER.process_common_bom_orgs ';
        ELSE
          x_out.output_status.msg_data      :=  SQLERRM||' INV_EBI_CHANGE_ORDER_HELPER.process_common_bom_orgs ';
     END IF;
  END process_common_bom_orgs;

/************************************************************************************
 --     API name        : process_eco
 --     Type            : Private
 --     Function        :
 --     This API is used to create the  change order.
 --
 ************************************************************************************/
 PROCEDURE process_eco(
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE
  ,p_change_order             IN  inv_ebi_change_order_obj
  ,p_revision_type_tbl        IN  inv_ebi_eco_revision_tbl
  ,p_revised_item_type_tbl    IN  inv_ebi_revised_item_tbl
  ,p_name_val_list            IN  inv_ebi_name_value_list
  ,x_out                      OUT NOCOPY   inv_ebi_eco_output_obj
  ) IS
  l_eco_rec                     ENG_ECO_PUB.eco_rec_type;
  l_eco_revision_tbl            ENG_ECO_PUB.eco_revision_tbl_type;
  l_revised_item_tbl            ENG_ECO_PUB.revised_item_tbl_type;
  l_revised_item_tbl_count      NUMBER := 1;
  l_rev_component_tbl           BOM_BO_PUB.rev_component_tbl_type;
  l_rev_component_tbl_count     NUMBER :=1;
  l_ref_designator_tbl          BOM_BO_PUB.ref_designator_tbl_type;
  l_ref_designator_tbl_count    NUMBER :=1;
  l_sub_component_tbl           BOM_BO_PUB.sub_component_tbl_type;
  l_sub_component_tbl_count     NUMBER :=1;
  l_rev_operation_tbl           BOM_RTG_PUB.rev_operation_tbl_type;
  l_rev_operation_tbl_count     NUMBER :=1;
  l_rev_op_resource_tbl         BOM_RTG_PUB.rev_op_resource_tbl_type;
  l_rev_op_resource_tbl_count   NUMBER  :=1;
  l_rev_sub_resource_tbl        BOM_RTG_PUB.rev_sub_resource_tbl_type;
  l_rev_sub_resource_tbl_count  NUMBER  :=1;
  l_change_line_tbl             ENG_ECO_PUB.change_line_tbl_type;
  l_revision                    VARCHAR2(3);
  l_is_component_item_exists    VARCHAR2(3);
  l_api_version                 NUMBER:=1.0;
  l_item_org_assignment_rec     EGO_ITEM_PUB.item_org_assignment_rec_type;
  l_item_org_assignment_tbl     EGO_ITEM_PUB.item_org_assignment_tbl_type;
  l_inventory_item_id           NUMBER;
  l_organization_id             NUMBER;
  l_component_item_name         VARCHAR2(240);
  l_master_org                  NUMBER;
  l_pk_col_name_val_pairs       INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl;
  l_subst_comp_name             mtl_system_items_kfv.concatenated_segments%TYPE;
  l_return_status               VARCHAR2(10);
  l_msg_count                   NUMBER;
  l_output_status               inv_ebi_output_status;
  l_status_type                 NUMBER;
  l_priority_code               VARCHAR2(10);
  l_is_wf_Set                   BOOLEAN;
  l_approval_status             NUMBER :=0;
  l_plm_or_erp                  VARCHAR2(1):=FND_API.G_TRUE;
  l_old_effectivity_date        DATE;
  l_old_op_sequence_num         NUMBER;
  l_old_fm_end_item_unit        NUMBER;
  l_acd_update                  CONSTANT NUMBER :=2;
  l_acd_delete                  CONSTANT NUMBER :=3;
  l_revised_item_id             NUMBER;
  l_effectivity_date            DATE;
  l_change_type_code            VARCHAR2(80);
  l_status_name                 VARCHAR2(30);
  l_bom_update_without_eco      VARCHAR2(1) := FND_API.G_TRUE;

  BEGIN
     SAVEPOINT inv_ebi_proc_eco_save_pnt;
     INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.process_eco');
     INV_EBI_UTIL.debug_line('STEP 20: ECO NUMBER: '|| p_change_order.eco_name || ' ORG CODE: '|| p_change_order.organization_code);

     l_output_status    := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
     x_out              := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);

     l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
     l_pk_col_name_val_pairs.EXTEND(1);
     l_pk_col_name_val_pairs(1).name  := 'organization_code';
     l_pk_col_name_val_pairs(1).value := p_change_order.organization_code;

     l_organization_id  := INV_EBI_ITEM_HELPER.value_to_id(
                             p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                            ,p_entity_name            => INV_EBI_ITEM_HELPER.G_ORGANIZATION
                           );
     l_pk_col_name_val_pairs.TRIM(1);

     IF (l_organization_id IS NULL) THEN
       FND_MESSAGE.set_name('INV','INV_EBI_ORG_CODE_INVALID');
       FND_MESSAGE.set_token('COL_VALUE', p_change_order.organization_code);
       FND_MSG_PUB.add;
       RAISE FND_API.g_exc_unexpected_error;
     END IF;

     -- Code to incorporate the DVM changes
     -- ECO_TYPECODE
     l_change_type_code  := p_change_order.change_type_code;

     IF( p_change_order.change_type_id IS NOT NULL AND
         p_change_order.change_type_id <> fnd_api.g_miss_num) THEN
       l_change_type_code := get_change_type_code(p_change_type_id   => p_change_order.change_type_id);
     END IF;

      -- ECO_STATUS_CODE

      l_status_name := p_change_order.status_name;

      IF( p_change_order.status_code IS NOT NULL AND
          p_change_order.status_code <> fnd_api.g_miss_num) THEN
         l_status_name := get_eco_status_name(p_status_code => p_change_order.status_code);
      END IF;

     IF p_name_val_list.name_value_table IS NOT NULL THEN
       FOR i in p_name_val_list.name_value_table.FIRST..p_name_val_list.name_value_table.LAST LOOP

         IF (UPPER(p_name_val_list.name_value_table(i).param_name) = G_PLM_OR_ERP_CHANGE) THEN

           l_plm_or_erp := p_name_val_list.name_value_table(i).param_value;

         --Bug 8340804
         ELSIF(UPPER(p_name_val_list.name_value_table(i).param_name) = G_BOM_UPDATES_ALLOWED) THEN

           l_bom_update_without_eco := p_name_val_list.name_value_table(i).param_value;

         END IF;
       END LOOP;
     END IF;

     l_is_wf_Set := Check_Workflow_Process(p_change_order_type_id  => p_change_order.change_type_id
                                          ,p_priority_code         => p_change_order.priority_code
                                           );
     IF (p_change_order IS NOT NULL) THEN
       l_eco_rec.eco_name                  := p_change_order.eco_name;
       l_eco_rec.change_notice_prefix      := p_change_order.change_notice_prefix;
       l_eco_rec.change_notice_number      := p_change_order.change_notice_number;
       l_eco_rec.organization_code         := p_change_order.organization_code ;
       l_eco_rec.change_name               := p_change_order.change_name;
       l_eco_rec.description               := p_change_order.description;
       l_eco_rec.cancellation_comments     := p_change_order.cancellation_comments ;
     BEGIN
       IF (l_is_wf_Set) THEN
         SELECT status_name, status_type
         INTO   l_eco_rec.status_name, l_status_type
         FROM   eng_change_statuses_vl
         WHERE  status_code = 1;                                                  -- ECO Status Set to 'Open';
         l_eco_rec.approval_status_name := get_status_name(p_lookup_type => 'ENG_ECN_APPROVAL_STATUS'
                                                          ,p_lookup_code => 1  ); -- Not submitted for approval
       ELSE
         l_eco_rec.status_name          := l_status_name;
         IF (l_eco_rec.status_name = 'Implemented' ) THEN
           SELECT status_name, status_type
           INTO   l_eco_rec.status_name, l_status_type
           FROM   eng_change_statuses_vl
           WHERE  status_code = 4;                                                -- Scheduled
         END IF;
         l_eco_rec.approval_status_name := get_status_name(p_lookup_type => 'ENG_ECN_APPROVAL_STATUS'
                                                          ,p_lookup_code => 5  ); -- Approved
       END IF;
     EXCEPTION
       WHEN OTHERS THEN
         NULL;
     END;
       l_eco_rec.priority_code             := p_change_order.priority_code ;
       l_eco_rec.reason_code               := p_change_order.reason_code;
       l_eco_rec.eng_implementation_cost   := p_change_order.eng_implementation_cost;
       l_eco_rec.mfg_implementation_cost   := p_change_order.mfg_implementation_cost;
       l_eco_rec.requestor                 := p_change_order.requestor;
       l_eco_rec.attribute_category        := p_change_order.attribute_category ;
       l_eco_rec.attribute1                := p_change_order.attribute1 ;
       l_eco_rec.attribute2                := p_change_order.attribute2 ;
       l_eco_rec.attribute3                := p_change_order.attribute3 ;
       l_eco_rec.attribute4                := p_change_order.attribute4 ;
       l_eco_rec.attribute5                := p_change_order.attribute5 ;
       l_eco_rec.attribute6                := p_change_order.attribute6 ;
       l_eco_rec.attribute7                := p_change_order.attribute7 ;
       l_eco_rec.attribute8                := p_change_order.attribute8 ;
       l_eco_rec.attribute9                := p_change_order.attribute9 ;
       l_eco_rec.attribute10               := p_change_order.attribute10;
       l_eco_rec.attribute11               := p_change_order.attribute11 ;
       l_eco_rec.attribute12               := p_change_order.attribute12;
       l_eco_rec.attribute13               := p_change_order.attribute13;
       l_eco_rec.attribute14               := p_change_order.attribute14;
       l_eco_rec.attribute15               := p_change_order.attribute15;
       l_eco_rec.ddf_context               := p_change_order.ddf_context ;
       l_eco_rec.approval_list_name        := p_change_order.approval_list_name ;
       l_eco_rec.approval_date             := p_change_order.approval_date;
       l_eco_rec.approval_request_date     := p_change_order.approval_request_date ;
       l_eco_rec.change_type_code          := l_change_type_code  ;
       l_eco_rec.change_management_type    := p_change_order.change_management_type ;
       l_eco_rec.original_system_reference := p_change_order.original_system_reference;
       l_eco_rec.organization_hierarchy    := p_change_order.organization_hierarchy;
       l_eco_rec.assignee                  := p_change_order.assignee ;
       l_eco_rec.project_name              := p_change_order.project_name ;
       l_eco_rec.task_number               := p_change_order.task_number;
       l_eco_rec.source_type               := p_change_order.source_type;
       l_eco_rec.source_name               := p_change_order.source_name ;
       l_eco_rec.need_by_date              := p_change_order.need_by_date ;
       l_eco_rec.effort                    := p_change_order.effort;
       l_eco_rec.eco_department_name       := p_change_order.eco_department_name;
       l_eco_rec.transaction_id            := p_change_order.transaction_id;
       l_eco_rec.transaction_type          := p_change_order.transaction_type ;
       l_eco_rec.internal_use_only         := p_change_order.internal_use_only ;
       l_eco_rec.return_status             := p_change_order.return_status ;
       IF (p_change_order.plm_or_erp_change IS NOT NULL AND p_change_order.plm_or_erp_change <> fnd_api.g_miss_char ) THEN
         l_eco_rec.plm_or_erp_change         := p_change_order.plm_or_erp_change ;
       ELSE
         IF (l_plm_or_erp = FND_API.G_FALSE) THEN
           l_eco_rec.plm_or_erp_change     := 'PLM';
         ELSE
           l_eco_rec.plm_or_erp_change     := 'ERP';
         END IF;
       END IF;
       l_eco_rec.pk1_name                  := p_change_order.pk1_name ;
       l_eco_rec.pk2_name                  := p_change_order.pk2_name;
       l_eco_rec.pk3_name                  := p_change_order.pk3_name;
       l_eco_rec.employee_number           := p_change_order.employee_number;
     END IF;
     IF(p_revision_type_tbl IS NOT NULL AND p_revision_type_tbl.COUNT > 0) THEN
       FOR i IN 1..p_revision_type_tbl.COUNT
       LOOP

         l_eco_revision_tbl(i).eco_name                   := p_change_order.eco_name ;
         l_eco_revision_tbl(i).organization_code          := p_change_order.organization_code ;
         l_eco_revision_tbl(i).revision                   := p_revision_type_tbl(i).revision  ;
         l_eco_revision_tbl(i).new_revision               := p_revision_type_tbl(i).new_revision ;
         l_eco_revision_tbl(i).comments                   := p_revision_type_tbl(i).comments;
         l_eco_revision_tbl(i).attribute_category         := p_revision_type_tbl(i).attribute_category ;
         l_eco_revision_tbl(i).attribute1                 := p_revision_type_tbl(i).attribute1 ;
         l_eco_revision_tbl(i).attribute2                 := p_revision_type_tbl(i).attribute2 ;
         l_eco_revision_tbl(i).attribute3                 := p_revision_type_tbl(i).attribute3 ;
         l_eco_revision_tbl(i).attribute4                 := p_revision_type_tbl(i).attribute4 ;
         l_eco_revision_tbl(i).attribute5                 := p_revision_type_tbl(i).attribute5 ;
         l_eco_revision_tbl(i).attribute6                 := p_revision_type_tbl(i).attribute6 ;
         l_eco_revision_tbl(i).attribute7                 := p_revision_type_tbl(i).attribute7 ;
         l_eco_revision_tbl(i).attribute8                 := p_revision_type_tbl(i).attribute8 ;
         l_eco_revision_tbl(i).attribute9                 := p_revision_type_tbl(i).attribute9 ;
         l_eco_revision_tbl(i).attribute10                := p_revision_type_tbl(i).attribute10;
         l_eco_revision_tbl(i).attribute11                := p_revision_type_tbl(i).attribute11 ;
         l_eco_revision_tbl(i).attribute12                := p_revision_type_tbl(i).attribute12 ;
         l_eco_revision_tbl(i).attribute13                := p_revision_type_tbl(i).attribute13 ;
         l_eco_revision_tbl(i).attribute14                := p_revision_type_tbl(i).attribute14 ;
         l_eco_revision_tbl(i).attribute15                := p_revision_type_tbl(i).attribute15 ;
         l_eco_revision_tbl(i).change_management_type     := p_revision_type_tbl(i).change_management_type ;
         l_eco_revision_tbl(i).original_system_reference  := p_revision_type_tbl(i).original_system_reference ;
         l_eco_revision_tbl(i).return_status              := p_revision_type_tbl(i).return_status ;
         l_eco_revision_tbl(i).transaction_type           := p_revision_type_tbl(i).transaction_type ;
         l_eco_revision_tbl(i).transaction_id             := p_revision_type_tbl(i).transaction_id ;
       END LOOP;
     END IF;
     IF(p_revised_item_type_tbl IS NOT NULL AND p_revised_item_type_tbl.COUNT > 0) THEN
       FOR i IN p_revised_item_type_tbl.FIRST..p_revised_item_type_tbl.LAST
       LOOP
         l_inventory_item_id  := INV_EBI_ITEM_HELPER.get_inventory_item_id (
                                   p_organization_id => l_organization_id
                                  ,p_item_number     => p_revised_item_type_tbl(i).revised_item_name
                                 );
         -- To get effectivty date of recently created revision Bug 7197943

         l_effectivity_date  := get_latest_effectivity_date(
                                  p_inventory_item_id  =>  l_inventory_item_id,
                                  p_organization_id    =>  l_organization_id );

         -- Bug# 7662420
         -- If the effective date that we get from the DB is less then the sysdate
         -- If the incomming date from end system is null or miss date
         -- Then take the max of sysdate or effective date.

         IF(l_effectivity_date < SYSDATE ) THEN
           l_effectivity_date := SYSDATE ;
         END IF;

         l_revised_item_tbl(l_revised_item_tbl_count).eco_name                         := p_change_order.eco_name ;
         l_revised_item_tbl(l_revised_item_tbl_count).organization_code                := p_change_order.organization_code ;
         l_revised_item_tbl(l_revised_item_tbl_count).revised_item_name                := p_revised_item_type_tbl(i).revised_item_name ;

         IF(p_revised_item_type_tbl(i).new_revised_item_revision = p_revised_item_type_tbl(i).from_item_revision) THEN
           --Bug 7119898 If a change order already exists for the revision being sent in, set the revision to NULL
           IF (is_new_revision_exists(
                                      p_item_number    => l_revised_item_tbl(l_revised_item_tbl_count).revised_item_name,
                                      p_revision       => p_revised_item_type_tbl(i).new_revised_item_revision,
                                      p_org_code       => l_revised_item_tbl(l_revised_item_tbl_count).organization_code
                                    ) = FND_API.g_true )  THEN
             l_revised_item_tbl(l_revised_item_tbl_count).new_revised_item_revision  := NULL;
             l_revised_item_tbl(l_revised_item_tbl_count).from_item_revision         := p_revised_item_type_tbl(i).from_item_revision ;
           ELSE
             l_revised_item_tbl(l_revised_item_tbl_count).new_revised_item_revision  := p_revised_item_type_tbl(i).new_revised_item_revision;
             l_revised_item_tbl(l_revised_item_tbl_count).from_item_revision         := NULL ;
           END IF;
         ELSE
           l_revised_item_tbl(l_revised_item_tbl_count).new_revised_item_revision  := p_revised_item_type_tbl(i).new_revised_item_revision;
           l_revised_item_tbl(l_revised_item_tbl_count).from_item_revision         := p_revised_item_type_tbl(i).from_item_revision ;
         END IF;

         l_revised_item_tbl(l_revised_item_tbl_count).new_revised_item_rev_desc        := p_revised_item_type_tbl(i).new_revised_item_rev_desc;
         l_revised_item_tbl(l_revised_item_tbl_count).updated_revised_item_revision    := p_revised_item_type_tbl(i).upd_revised_item_revision;
         IF (p_revised_item_type_tbl(i).start_effective_date < l_effectivity_date
         OR p_revised_item_type_tbl(i).start_effective_date IS NULL
         OR p_revised_item_type_tbl(i).start_effective_date = fnd_api.g_miss_date) THEN
           l_revised_item_tbl(l_revised_item_tbl_count).start_effective_date           := l_effectivity_date + 1/86400; -- BUG 7197943 To keep efectivity date of next rev 1 sec higher than earlier rev
         ELSE
           l_revised_item_tbl(l_revised_item_tbl_count).start_effective_date           := p_revised_item_type_tbl(i).start_effective_date;
         END IF;
         IF (p_revised_item_type_tbl(i).new_effective_date < l_effectivity_date
         OR p_revised_item_type_tbl(i).new_effective_date IS NULL
         OR p_revised_item_type_tbl(i).new_effective_date = fnd_api.g_miss_date) THEN
           l_revised_item_tbl(l_revised_item_tbl_count).new_effective_date             := l_effectivity_date + 1/86400; --BUG 7197943 To keep efectivity date of next rev 1 sec higher than earlier rev
         ELSE
           l_revised_item_tbl(l_revised_item_tbl_count).new_effective_date             := p_revised_item_type_tbl(i).new_effective_date ;
         END IF;
         l_revised_item_tbl(l_revised_item_tbl_count).alternate_bom_code               := p_revised_item_type_tbl(i).alternate_bom_code ;

         -- To set the status of revisied Item based on the ECO status:
         l_revised_item_tbl(l_revised_item_tbl_count).status_type                      := l_status_type;

         l_revised_item_tbl(l_revised_item_tbl_count).mrp_active                       := p_revised_item_type_tbl(i).mrp_active  ;
         l_revised_item_tbl(l_revised_item_tbl_count).earliest_effective_date          := p_revised_item_type_tbl(i).earliest_effective_date ;
         l_revised_item_tbl(l_revised_item_tbl_count).use_up_item_name                 := p_revised_item_type_tbl(i).use_up_item_name;
         l_revised_item_tbl(l_revised_item_tbl_count).use_up_plan_name                 := p_revised_item_type_tbl(i).use_up_plan_name ;
         l_revised_item_tbl(l_revised_item_tbl_count).requestor                        := p_revised_item_type_tbl(i).requestor ;
         l_revised_item_tbl(l_revised_item_tbl_count).disposition_type                 := p_revised_item_type_tbl(i).disposition_type  ;
         l_revised_item_tbl(l_revised_item_tbl_count).update_wip                       := p_revised_item_type_tbl(i).up_wip ;
         l_revised_item_tbl(l_revised_item_tbl_count).cancel_comments                  := p_revised_item_type_tbl(i).cancel_comments  ;
         l_revised_item_tbl(l_revised_item_tbl_count).change_description               := p_revised_item_type_tbl(i).change_description;
         l_revised_item_tbl(l_revised_item_tbl_count).attribute_category               := p_revised_item_type_tbl(i).attribute_category;
         l_revised_item_tbl(l_revised_item_tbl_count).attribute1                       := p_revised_item_type_tbl(i).attribute1;
         l_revised_item_tbl(l_revised_item_tbl_count).attribute2                       := p_revised_item_type_tbl(i).attribute2 ;
         l_revised_item_tbl(l_revised_item_tbl_count).attribute3                       := p_revised_item_type_tbl(i).attribute3 ;
         l_revised_item_tbl(l_revised_item_tbl_count).attribute4                       := p_revised_item_type_tbl(i).attribute4;
         l_revised_item_tbl(l_revised_item_tbl_count).attribute5                       := p_revised_item_type_tbl(i).attribute5;
         l_revised_item_tbl(l_revised_item_tbl_count).attribute6                       := p_revised_item_type_tbl(i).attribute6;
         l_revised_item_tbl(l_revised_item_tbl_count).attribute7                       := p_revised_item_type_tbl(i).attribute7;
         l_revised_item_tbl(l_revised_item_tbl_count).attribute8                       := p_revised_item_type_tbl(i).attribute8;
         l_revised_item_tbl(l_revised_item_tbl_count).attribute9                       := p_revised_item_type_tbl(i).attribute9 ;
         l_revised_item_tbl(l_revised_item_tbl_count).attribute10                      := p_revised_item_type_tbl(i).attribute10;
         l_revised_item_tbl(l_revised_item_tbl_count).attribute11                      := p_revised_item_type_tbl(i).attribute11;
         l_revised_item_tbl(l_revised_item_tbl_count).attribute12                      := p_revised_item_type_tbl(i).attribute12;
         l_revised_item_tbl(l_revised_item_tbl_count).attribute13                      := p_revised_item_type_tbl(i).attribute13;
         l_revised_item_tbl(l_revised_item_tbl_count).attribute14                      := p_revised_item_type_tbl(i).attribute14;
         l_revised_item_tbl(l_revised_item_tbl_count).attribute15                      := p_revised_item_type_tbl(i).attribute15 ;
         l_revised_item_tbl(l_revised_item_tbl_count).from_end_item_unit_number        := p_revised_item_type_tbl(i).from_end_item_unit_number;
         l_revised_item_tbl(l_revised_item_tbl_count).new_from_end_item_unit_number    := p_revised_item_type_tbl(i).new_from_end_item_unit_number ;
         l_revised_item_tbl(l_revised_item_tbl_count).original_system_reference        := p_revised_item_type_tbl(i).original_system_reference ;
         l_revised_item_tbl(l_revised_item_tbl_count).return_status                    := p_revised_item_type_tbl(i).return_status ;
         l_revised_item_tbl(l_revised_item_tbl_count).transaction_type                 := p_revised_item_type_tbl(i).transaction_type ;
         l_revised_item_tbl(l_revised_item_tbl_count).transaction_id                   := p_revised_item_type_tbl(i).transaction_id ;
         l_revised_item_tbl(l_revised_item_tbl_count).from_work_order                  := p_revised_item_type_tbl(i).from_work_order ;
         l_revised_item_tbl(l_revised_item_tbl_count).to_work_order                    := p_revised_item_type_tbl(i).to_work_order;
         l_revised_item_tbl(l_revised_item_tbl_count).from_cumulative_quantity         := p_revised_item_type_tbl(i).from_cumulative_quantity ;
         l_revised_item_tbl(l_revised_item_tbl_count).lot_number                       := p_revised_item_type_tbl(i).lot_number ;
         l_revised_item_tbl(l_revised_item_tbl_count).completion_subinventory          := p_revised_item_type_tbl(i).completion_subinventory  ;
         l_revised_item_tbl(l_revised_item_tbl_count).completion_location_name         := p_revised_item_type_tbl(i).completion_location_name;
         l_revised_item_tbl(l_revised_item_tbl_count).priority                         := p_revised_item_type_tbl(i).priority ;
         l_revised_item_tbl(l_revised_item_tbl_count).ctp_flag                         := p_revised_item_type_tbl(i).ctp_flag;
         l_revised_item_tbl(l_revised_item_tbl_count).new_routing_revision             := p_revised_item_type_tbl(i).new_routing_revision ;
         l_revised_item_tbl(l_revised_item_tbl_count).updated_routing_revision         := p_revised_item_type_tbl(i).upd_routing_revision ;
         l_revised_item_tbl(l_revised_item_tbl_count).routing_comment                  := p_revised_item_type_tbl(i).routing_comment ;
         l_revised_item_tbl(l_revised_item_tbl_count).eco_for_production               := p_revised_item_type_tbl(i).eco_for_production;
         l_revised_item_tbl(l_revised_item_tbl_count).change_management_type           := p_revised_item_type_tbl(i).change_management_type;
         l_revised_item_tbl(l_revised_item_tbl_count).transfer_or_copy                 := p_revised_item_type_tbl(i).transfer_or_copy;
         l_revised_item_tbl(l_revised_item_tbl_count).transfer_or_copy_item            := p_revised_item_type_tbl(i).transfer_or_copy_item ;
         l_revised_item_tbl(l_revised_item_tbl_count).transfer_or_copy_bill            := p_revised_item_type_tbl(i).transfer_or_copy_bill ;
         l_revised_item_tbl(l_revised_item_tbl_count).transfer_or_copy_routing         := p_revised_item_type_tbl(i).transfer_or_copy_routing;
         l_revised_item_tbl(l_revised_item_tbl_count).copy_to_item                     := p_revised_item_type_tbl(i).copy_to_item ;
         l_revised_item_tbl(l_revised_item_tbl_count).copy_to_item_desc                := p_revised_item_type_tbl(i).copy_to_item_desc ;
         l_revised_item_tbl(l_revised_item_tbl_count).parent_revised_item_name         := p_revised_item_type_tbl(i).parent_revised_item_name;
         l_revised_item_tbl(l_revised_item_tbl_count).parent_alternate_name            := p_revised_item_type_tbl(i).parent_alternate_name;
         l_revised_item_tbl(l_revised_item_tbl_count).selection_option                 := p_revised_item_type_tbl(i).selection_option ;
         l_revised_item_tbl(l_revised_item_tbl_count).selection_date                   := p_revised_item_type_tbl(i).selection_date ;
         l_revised_item_tbl(l_revised_item_tbl_count).selection_unit_number            := p_revised_item_type_tbl(i).selection_unit_number;
         l_revised_item_tbl(l_revised_item_tbl_count).current_lifecycle_phase_name     := p_revised_item_type_tbl(i).current_lifecycle_phase_name ;
         l_revised_item_tbl(l_revised_item_tbl_count).new_lifecycle_phase_name         := p_revised_item_type_tbl(i).new_lifecycle_phase_name ;
         l_revised_item_tbl(l_revised_item_tbl_count).from_end_item_revision           := p_revised_item_type_tbl(i).from_end_item_revision;
         l_revised_item_tbl(l_revised_item_tbl_count).from_end_item_strc_rev           := p_revised_item_type_tbl(i).from_end_item_strc_rev ;
         l_revised_item_tbl(l_revised_item_tbl_count).enable_item_in_local_org         := p_revised_item_type_tbl(i).enable_item_in_local_org ;
         l_revised_item_tbl(l_revised_item_tbl_count).create_bom_in_local_org          := p_revised_item_type_tbl(i).create_bom_in_local_org ;
         l_revised_item_tbl(l_revised_item_tbl_count).new_structure_revision           := p_revised_item_type_tbl(i).new_structure_revision ;
         l_revised_item_tbl(l_revised_item_tbl_count).plan_level                       := p_revised_item_type_tbl(i).plan_level  ;
         l_revised_item_tbl(l_revised_item_tbl_count).from_end_item_name               := p_revised_item_type_tbl(i).from_end_item_name   ;
         l_revised_item_tbl(l_revised_item_tbl_count).from_end_item_alternate          := p_revised_item_type_tbl(i).from_end_item_alternate ;
         l_revised_item_tbl(l_revised_item_tbl_count).current_structure_rev_name       := p_revised_item_type_tbl(i).current_structure_rev_name;
         l_revised_item_tbl(l_revised_item_tbl_count).reschedule_comments              := p_revised_item_type_tbl(i).reschedule_comments ;

         l_revised_item_tbl(l_revised_item_tbl_count).new_revision_label               := p_revised_item_type_tbl(i).new_revision_label ;
         l_revised_item_tbl(l_revised_item_tbl_count).new_revision_reason              := p_revised_item_type_tbl(i).new_revision_reason;
         l_revised_item_tbl(l_revised_item_tbl_count).structure_type_name              := p_revised_item_type_tbl(i).structure_type_name ;


         IF(p_revised_item_type_tbl(i).component_item_tbl IS NOT NULL AND p_revised_item_type_tbl(i).component_item_tbl.COUNT > 0) THEN

           -- If BOM already commoned create component in all commoned orgs
	   INV_EBI_UTIL.debug_line('STEP 30: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.process_common_bom_orgs '||
	                                     'REVISED ITEM NAME: '|| l_revised_item_tbl(l_revised_item_tbl_count).revised_item_name  ||
					     'ORG CODE: '|| l_revised_item_tbl(l_revised_item_tbl_count).organization_code);
           process_common_bom_orgs(
             p_assembly_item_name    => l_revised_item_tbl(l_revised_item_tbl_count).revised_item_name,
             p_organization_code     => l_revised_item_tbl(l_revised_item_tbl_count).organization_code,
             p_alternate_bom_code    => l_revised_item_tbl(l_revised_item_tbl_count).alternate_bom_code,
             p_component_item_tbl    => p_revised_item_type_tbl(i).component_item_tbl,
             x_out                   => x_out
           );
	   INV_EBI_UTIL.debug_line('STEP 40: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.process_common_bom_orgs STATUS: '|| x_out.output_status.return_status);
           IF (x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
             RAISE  FND_API.g_exc_unexpected_error;
           END IF;

           FOR j IN p_revised_item_type_tbl(i).component_item_tbl.FIRST..p_revised_item_type_tbl(i).component_item_tbl.LAST
           LOOP
             --If context org is child org and components does not exist,item assignment should be done
	     INV_EBI_UTIL.debug_line('STEP 50: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.process_assign_items '||
	                                     ' ORG ID: '|| l_organization_id || ' COMP ITEM NAME:  '|| p_revised_item_type_tbl(i).component_item_tbl(j).component_item_name);
             process_assign_items(
               p_organization_id        =>  l_organization_id,
               p_item_name              =>  p_revised_item_type_tbl(i).component_item_tbl(j).component_item_name,
               x_return_status          =>  x_out.output_status.return_status ,
               x_msg_data               =>  x_out.output_status.msg_data ,
               x_msg_count              =>  x_out.output_status.msg_count
             );
	     INV_EBI_UTIL.debug_line('STEP 60: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.process_assign_items STATUS:  '|| x_out.output_status.return_status);
             IF (x_out.output_status.return_status  <> FND_API.g_ret_sts_success) THEN
               RAISE  FND_API.g_exc_unexpected_error;
             END IF;

             l_rev_component_tbl(l_rev_component_tbl_count).eco_name                      := p_change_order.eco_name;
             l_rev_component_tbl(l_rev_component_tbl_count).organization_code             := p_change_order.organization_code ;
             l_rev_component_tbl(l_rev_component_tbl_count).revised_item_name             := p_revised_item_type_tbl(i).revised_item_name;
             l_rev_component_tbl(l_rev_component_tbl_count).new_revised_item_revision     := l_revised_item_tbl(l_revised_item_tbl_count).new_revised_item_revision;
             IF (p_revised_item_type_tbl(i).component_item_tbl(j).start_effective_date < l_effectivity_date
             OR p_revised_item_type_tbl(i).component_item_tbl(j).start_effective_date IS NULL
             OR p_revised_item_type_tbl(i).component_item_tbl(j).start_effective_date = fnd_api.g_miss_date) THEN
               l_rev_component_tbl(l_rev_component_tbl_count).start_effective_date        := l_effectivity_date + 1/86400 ; --BUG 7197943 To keep efectivity date of next rev 1 sec higher than earlier rev
             ELSE
               l_rev_component_tbl(l_rev_component_tbl_count).start_effective_date        := p_revised_item_type_tbl(i).component_item_tbl(j).start_effective_date;
             END IF;
             IF (p_revised_item_type_tbl(i).component_item_tbl(j).new_effectivity_date < l_effectivity_date
             OR p_revised_item_type_tbl(i).component_item_tbl(j).new_effectivity_date IS NULL
             OR p_revised_item_type_tbl(i).component_item_tbl(j).new_effectivity_date = fnd_api.g_miss_date) THEN
               l_rev_component_tbl(l_rev_component_tbl_count).new_effectivity_date        := l_effectivity_date + 1/86400; --BUG 7197943 To keep efectivity date of next rev 1 sec higher than earlier rev
             ELSE
               l_rev_component_tbl(l_rev_component_tbl_count).new_effectivity_date        := p_revised_item_type_tbl(i).component_item_tbl(j).new_effectivity_date ;
             END IF;
             l_rev_component_tbl(l_rev_component_tbl_count).disable_date                  := p_revised_item_type_tbl(i).component_item_tbl(j).disable_date;
             l_rev_component_tbl(l_rev_component_tbl_count).operation_sequence_number     := p_revised_item_type_tbl(i).component_item_tbl(j).operation_sequence_number ;
             l_rev_component_tbl(l_rev_component_tbl_count).component_item_name           := p_revised_item_type_tbl(i).component_item_tbl(j).component_item_name  ;
             l_rev_component_tbl(l_rev_component_tbl_count).alternate_bom_code            := p_revised_item_type_tbl(i).alternate_bom_code ;
             l_rev_component_tbl(l_rev_component_tbl_count).acd_type                      := p_revised_item_type_tbl(i).component_item_tbl(j).acd_type ;
             l_rev_component_tbl(l_rev_component_tbl_count).old_effectivity_date          := p_revised_item_type_tbl(i).component_item_tbl(j).old_effectivity_date ;
             l_rev_component_tbl(l_rev_component_tbl_count).old_operation_sequence_number := p_revised_item_type_tbl(i).component_item_tbl(j).old_operation_sequence_number;
             l_rev_component_tbl(l_rev_component_tbl_count).new_operation_sequence_number := p_revised_item_type_tbl(i).component_item_tbl(j).new_operation_sequence_number;
             l_rev_component_tbl(l_rev_component_tbl_count).item_sequence_number          := p_revised_item_type_tbl(i).component_item_tbl(j).item_sequence_number ;
             l_rev_component_tbl(l_rev_component_tbl_count).basis_type                    := p_revised_item_type_tbl(i).component_item_tbl(j).basis_type  ;
             l_rev_component_tbl(l_rev_component_tbl_count).quantity_per_assembly         := p_revised_item_type_tbl(i).component_item_tbl(j).quantity_per_assembly ;
             l_rev_component_tbl(l_rev_component_tbl_count).inverse_quantity              := p_revised_item_type_tbl(i).component_item_tbl(j).inverse_quantity ;
             l_rev_component_tbl(l_rev_component_tbl_count).planning_percent              := p_revised_item_type_tbl(i).component_item_tbl(j).planning_percent ;
             l_rev_component_tbl(l_rev_component_tbl_count).projected_yield               := p_revised_item_type_tbl(i).component_item_tbl(j).projected_yield ;
             l_rev_component_tbl(l_rev_component_tbl_count).include_in_cost_rollup        := p_revised_item_type_tbl(i).component_item_tbl(j).include_in_cost_rollup ;
             l_rev_component_tbl(l_rev_component_tbl_count).wip_supply_type               := p_revised_item_type_tbl(i).component_item_tbl(j).wip_supply_type ;
             l_rev_component_tbl(l_rev_component_tbl_count).so_basis                      := p_revised_item_type_tbl(i).component_item_tbl(j).so_basis  ;
             l_rev_component_tbl(l_rev_component_tbl_count).optional                      := p_revised_item_type_tbl(i).component_item_tbl(j).optional ;
             l_rev_component_tbl(l_rev_component_tbl_count).mutually_exclusive            := p_revised_item_type_tbl(i).component_item_tbl(j).mutually_exclusive  ;
             l_rev_component_tbl(l_rev_component_tbl_count).check_atp                     := p_revised_item_type_tbl(i).component_item_tbl(j).check_atp  ;
             l_rev_component_tbl(l_rev_component_tbl_count).shipping_allowed              := p_revised_item_type_tbl(i).component_item_tbl(j).shipping_allowed ;
             l_rev_component_tbl(l_rev_component_tbl_count).required_to_ship              := p_revised_item_type_tbl(i).component_item_tbl(j).required_to_ship ;
             l_rev_component_tbl(l_rev_component_tbl_count).required_for_revenue          := p_revised_item_type_tbl(i).component_item_tbl(j).required_for_revenue;
             l_rev_component_tbl(l_rev_component_tbl_count).include_on_ship_docs          := p_revised_item_type_tbl(i).component_item_tbl(j).include_on_ship_docs;
             l_rev_component_tbl(l_rev_component_tbl_count).quantity_related              := p_revised_item_type_tbl(i).component_item_tbl(j).quantity_related;
             l_rev_component_tbl(l_rev_component_tbl_count).supply_subinventory           := p_revised_item_type_tbl(i).component_item_tbl(j).supply_subinventory;
             l_rev_component_tbl(l_rev_component_tbl_count).location_name                 := p_revised_item_type_tbl(i).component_item_tbl(j).location_name ;
             l_rev_component_tbl(l_rev_component_tbl_count).minimum_allowed_quantity      := p_revised_item_type_tbl(i).component_item_tbl(j).minimum_allowed_quantity ;
             l_rev_component_tbl(l_rev_component_tbl_count).maximum_allowed_quantity      := p_revised_item_type_tbl(i).component_item_tbl(j).maximum_allowed_quantity;
             l_rev_component_tbl(l_rev_component_tbl_count).comments                      := p_revised_item_type_tbl(i).component_item_tbl(j).comments ;
             l_rev_component_tbl(l_rev_component_tbl_count).cancel_comments               := p_revised_item_type_tbl(i).component_item_tbl(j).cancel_comments;
             l_rev_component_tbl(l_rev_component_tbl_count).attribute_category            := p_revised_item_type_tbl(i).component_item_tbl(j).attribute_category;
             l_rev_component_tbl(l_rev_component_tbl_count).attribute1                    := p_revised_item_type_tbl(i).component_item_tbl(j).attribute1 ;
             l_rev_component_tbl(l_rev_component_tbl_count).attribute2                    := p_revised_item_type_tbl(i).component_item_tbl(j).attribute2 ;
             l_rev_component_tbl(l_rev_component_tbl_count).attribute3                    := p_revised_item_type_tbl(i).component_item_tbl(j).attribute3 ;
             l_rev_component_tbl(l_rev_component_tbl_count).attribute4                    := p_revised_item_type_tbl(i).component_item_tbl(j).attribute4 ;
             l_rev_component_tbl(l_rev_component_tbl_count).attribute5                    := p_revised_item_type_tbl(i).component_item_tbl(j).attribute5 ;
             l_rev_component_tbl(l_rev_component_tbl_count).attribute6                    := p_revised_item_type_tbl(i).component_item_tbl(j).attribute6 ;
             l_rev_component_tbl(l_rev_component_tbl_count).attribute7                    := p_revised_item_type_tbl(i).component_item_tbl(j).attribute7 ;
             l_rev_component_tbl(l_rev_component_tbl_count).attribute8                    := p_revised_item_type_tbl(i).component_item_tbl(j).attribute8 ;
             l_rev_component_tbl(l_rev_component_tbl_count).attribute9                    := p_revised_item_type_tbl(i).component_item_tbl(j).attribute9 ;
             l_rev_component_tbl(l_rev_component_tbl_count).attribute10                   := p_revised_item_type_tbl(i).component_item_tbl(j).attribute10;
             l_rev_component_tbl(l_rev_component_tbl_count).attribute11                   := p_revised_item_type_tbl(i).component_item_tbl(j).attribute11;
             l_rev_component_tbl(l_rev_component_tbl_count).attribute12                   := p_revised_item_type_tbl(i).component_item_tbl(j).attribute12;
             l_rev_component_tbl(l_rev_component_tbl_count).attribute13                   := p_revised_item_type_tbl(i).component_item_tbl(j).attribute13;
             l_rev_component_tbl(l_rev_component_tbl_count).attribute14                   := p_revised_item_type_tbl(i).component_item_tbl(j).attribute14;
             l_rev_component_tbl(l_rev_component_tbl_count).attribute15                   := p_revised_item_type_tbl(i).component_item_tbl(j).attribute15;
             l_rev_component_tbl(l_rev_component_tbl_count).from_end_item_unit_number     := p_revised_item_type_tbl(i).component_item_tbl(j).from_end_item_unit_number;
             l_rev_component_tbl(l_rev_component_tbl_count).old_from_end_item_unit_number := p_revised_item_type_tbl(i).component_item_tbl(j).old_from_end_item_unit_number ;
             l_rev_component_tbl(l_rev_component_tbl_count).new_from_end_item_unit_number := p_revised_item_type_tbl(i).component_item_tbl(j).new_from_end_item_unit_number;
             l_rev_component_tbl(l_rev_component_tbl_count).to_end_item_unit_number       := p_revised_item_type_tbl(i).component_item_tbl(j).to_end_item_unit_number;
             l_rev_component_tbl(l_rev_component_tbl_count).new_routing_revision          := p_revised_item_type_tbl(i).component_item_tbl(j).new_routing_revision ;
             l_rev_component_tbl(l_rev_component_tbl_count).enforce_int_requirements      := p_revised_item_type_tbl(i).component_item_tbl(j).enforce_int_requirements;
             l_rev_component_tbl(l_rev_component_tbl_count).auto_request_material         := p_revised_item_type_tbl(i).component_item_tbl(j).auto_request_material;
             l_rev_component_tbl(l_rev_component_tbl_count).suggested_vendor_name         := p_revised_item_type_tbl(i).component_item_tbl(j).suggested_vendor_name;
             l_rev_component_tbl(l_rev_component_tbl_count).unit_price                    := p_revised_item_type_tbl(i).component_item_tbl(j).unit_price;
             l_rev_component_tbl(l_rev_component_tbl_count).original_system_reference     := p_revised_item_type_tbl(i).component_item_tbl(j).original_system_reference;
             l_rev_component_tbl(l_rev_component_tbl_count).return_status                 := p_revised_item_type_tbl(i).component_item_tbl(j).return_status ;
             l_rev_component_tbl(l_rev_component_tbl_count).transaction_type              := p_revised_item_type_tbl(i).component_item_tbl(j).transaction_type;
             l_rev_component_tbl(l_rev_component_tbl_count).row_identifier                := p_revised_item_type_tbl(i).component_item_tbl(j).row_identifier ;
             IF l_rev_component_tbl(l_rev_component_tbl_count).acd_type IN (l_acd_update,l_acd_delete)
             THEN
	       INV_EBI_UTIL.debug_line('STEP 70: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.get_existing_component_attr '|| ' ORG ID: '|| l_organization_id ||
	                                        ' REVISED ITEM NAME: '|| l_rev_component_tbl(l_rev_component_tbl_count).revised_item_name  ||
						' COMPONENT ITEM NAME: '|| l_rev_component_tbl(l_rev_component_tbl_count).component_item_name);
               get_existing_component_attr(
                 p_organization_id      => l_organization_id
                ,p_revised_item_name    => l_rev_component_tbl(l_rev_component_tbl_count).revised_item_name
                ,p_component_item_name  => l_rev_component_tbl(l_rev_component_tbl_count).component_item_name
                ,p_op_sequence_number  => l_rev_component_tbl(l_rev_component_tbl_count).operation_sequence_number
                ,p_alternate_bom_code   => l_rev_component_tbl(l_rev_component_tbl_count).alternate_bom_code
                ,p_bom_update_without_eco => l_bom_update_without_eco  -- Bug 8340804
                ,p_effectivity_date       => l_rev_component_tbl(l_rev_component_tbl_count).start_effective_date -- Bug 8340804
                ,x_old_effectivity_date => l_old_effectivity_date
                ,x_old_op_sequence_num  => l_old_op_sequence_num
                ,x_old_fm_end_item_unit => l_old_fm_end_item_unit
               );
               INV_EBI_UTIL.debug_line('STEP 80: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.get_existing_component_attr');
               IF l_rev_component_tbl(l_rev_component_tbl_count).old_effectivity_date IS NULL
               THEN
                 l_rev_component_tbl(l_rev_component_tbl_count).old_effectivity_date := l_old_effectivity_date;
               END IF;
               IF l_rev_component_tbl(l_rev_component_tbl_count).old_operation_sequence_number IS NULL
               THEN
                 l_rev_component_tbl(l_rev_component_tbl_count).old_operation_sequence_number := l_old_op_sequence_num;
               END IF;
               IF l_rev_component_tbl(l_rev_component_tbl_count).old_from_end_item_unit_number IS NULL
               THEN
                 l_rev_component_tbl(l_rev_component_tbl_count).old_from_end_item_unit_number := l_old_fm_end_item_unit;
               END IF;
             END IF;

             IF(p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl IS NOT NULL AND p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl.COUNT > 0) THEN
               FOR k IN 1..p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl.COUNT
               LOOP
                 l_ref_designator_tbl(l_ref_designator_tbl_count).eco_name                  := p_change_order.eco_name;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).organization_code         := p_change_order.organization_code ;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).revised_item_name         := p_revised_item_type_tbl(i).revised_item_name;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).new_revised_item_revision := l_revised_item_tbl(l_revised_item_tbl_count).new_revised_item_revision;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).operation_sequence_number := p_revised_item_type_tbl(i).component_item_tbl(j).operation_sequence_number;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).component_item_name       := p_revised_item_type_tbl(i).component_item_tbl(j).component_item_name ;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).alternate_bom_code        := p_revised_item_type_tbl(i).alternate_bom_code;
                 IF (p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).start_effective_date < l_effectivity_date
                 OR p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).start_effective_date IS NULL
                 OR p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).start_effective_date =fnd_api.g_miss_date) THEN
                   l_ref_designator_tbl(l_ref_designator_tbl_count).start_effective_date    := l_effectivity_date + 1/86400; --BUG 7197943 To keep efectivity date of next rev 1 sec higher than earlier rev
                 ELSE
                   l_ref_designator_tbl(l_ref_designator_tbl_count).start_effective_date    := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).start_effective_date;
                 END IF;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).reference_designator_name := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).reference_designator_name;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).acd_type                  := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).acd_type ;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).ref_designator_comment    := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).ref_designator_comment ;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).attribute_category        := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).attribute_category;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).attribute1                := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).attribute1 ;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).attribute2                := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).attribute2 ;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).attribute3                := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).attribute3 ;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).attribute4                := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).attribute4;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).attribute5                := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).attribute5;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).attribute6                := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).attribute6;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).attribute7                := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).attribute7;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).attribute8                := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).attribute8;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).attribute9                := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).attribute9;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).attribute10               := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).attribute10 ;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).attribute11               := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).attribute11;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).attribute12               := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).attribute12;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).attribute13               := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).attribute13;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).attribute14               := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).attribute14;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).attribute15               := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).attribute15;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).original_system_reference := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).original_system_reference;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).new_reference_designator  := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).new_reference_designator;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).from_end_item_unit_number := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).from_end_item_unit_number;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).new_routing_revision      := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).new_routing_revision;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).return_status             := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).return_status;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).transaction_type          := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).transaction_type ;
                 l_ref_designator_tbl(l_ref_designator_tbl_count).row_identifier            := p_revised_item_type_tbl(i).component_item_tbl(j).reference_designator_tbl(k).row_identifier ;
                 l_ref_designator_tbl_count  :=  l_ref_designator_tbl_count +1;
               END LOOP;
             END IF;

             IF(p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl IS NOT NULL AND p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl.COUNT > 0) THEN
               FOR k IN 1..p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl.COUNT
               LOOP
                 --If context org is child org and components does not exist,item assignment should be done
                 INV_EBI_UTIL.debug_line('STEP 90: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.process_assign_items FOR SUBSTITUTE COMPONENTS '||
		                                 ' COMPONENT NAME : '||p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).substitute_component_name);
                 process_assign_items(
                   p_organization_id        =>  l_organization_id,
                   p_item_name              =>  p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).substitute_component_name,
                   x_return_status          =>  x_out.output_status.return_status  ,
                   x_msg_data               =>  x_out.output_status.msg_data  ,
                   x_msg_count              =>  x_out.output_status.msg_count
                   );
		 INV_EBI_UTIL.debug_line('STEP 100: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.process_assign_items STATUS: '|| x_out.output_status.return_status);
                 IF (x_out.output_status.return_status  <> FND_API.g_ret_sts_success) THEN
                     RAISE  FND_API.g_exc_unexpected_error;
                   END IF;

                 l_sub_component_tbl(l_sub_component_tbl_count).eco_name                       := p_change_order.eco_name;
                 l_sub_component_tbl(l_sub_component_tbl_count).organization_code              := p_change_order.organization_code ;
                 l_sub_component_tbl(l_sub_component_tbl_count).revised_item_name              := p_revised_item_type_tbl(i).revised_item_name;
                 l_sub_component_tbl(l_sub_component_tbl_count).new_revised_item_revision      := l_revised_item_tbl(l_revised_item_tbl_count).new_revised_item_revision;
                 l_sub_component_tbl(l_sub_component_tbl_count).operation_sequence_number      := p_revised_item_type_tbl(i).component_item_tbl(j).operation_sequence_number;
                 l_sub_component_tbl(l_sub_component_tbl_count).component_item_name            := p_revised_item_type_tbl(i).component_item_tbl(j).component_item_name ;
                 l_sub_component_tbl(l_sub_component_tbl_count).alternate_bom_code             := p_revised_item_type_tbl(i).alternate_bom_code;
                 IF (p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).start_effective_date < l_effectivity_date
                 OR p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).start_effective_date IS NULL
                 OR p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).start_effective_date =fnd_api.g_miss_date) THEN
                   l_sub_component_tbl(l_sub_component_tbl_count).start_effective_date         := l_effectivity_date + 1/86400;
                 ELSE
                   l_sub_component_tbl(l_sub_component_tbl_count).start_effective_date         := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).start_effective_date;
                 END IF;
                 l_sub_component_tbl(l_sub_component_tbl_count).substitute_component_name      := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).substitute_component_name;
                 l_sub_component_tbl(l_sub_component_tbl_count).new_substitute_component_name  := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).new_substitute_component_name ;
                 l_sub_component_tbl(l_sub_component_tbl_count).acd_type                       := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).acd_type  ;
                 l_sub_component_tbl(l_sub_component_tbl_count).substitute_item_quantity       := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).substitute_item_quantity ;
                 l_sub_component_tbl(l_sub_component_tbl_count).attribute_category             := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).attribute_category;
                 l_sub_component_tbl(l_sub_component_tbl_count).attribute1                     := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).attribute1;
                 l_sub_component_tbl(l_sub_component_tbl_count).attribute2                     := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).attribute2 ;
                 l_sub_component_tbl(l_sub_component_tbl_count).attribute3                     := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).attribute3;
                 l_sub_component_tbl(l_sub_component_tbl_count).attribute4                     := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).attribute4 ;
                 l_sub_component_tbl(l_sub_component_tbl_count).attribute5                     := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).attribute5 ;
                 l_sub_component_tbl(l_sub_component_tbl_count).attribute6                     := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).attribute6 ;
                 l_sub_component_tbl(l_sub_component_tbl_count).attribute7                     := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).attribute7 ;
                 l_sub_component_tbl(l_sub_component_tbl_count).attribute8                     := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).attribute8 ;
                 l_sub_component_tbl(l_sub_component_tbl_count).attribute9                     := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).attribute9 ;
                 l_sub_component_tbl(l_sub_component_tbl_count).attribute10                    := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).attribute10 ;
                 l_sub_component_tbl(l_sub_component_tbl_count).attribute11                    := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).attribute11 ;
                 l_sub_component_tbl(l_sub_component_tbl_count).attribute12                    := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).attribute12 ;
                 l_sub_component_tbl(l_sub_component_tbl_count).attribute13                    := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).attribute13 ;
                 l_sub_component_tbl(l_sub_component_tbl_count).attribute14                    := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).attribute14 ;
                 l_sub_component_tbl(l_sub_component_tbl_count).attribute15                    := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).attribute15 ;
                 l_sub_component_tbl(l_sub_component_tbl_count).original_system_reference      := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).original_system_reference ;
                 l_sub_component_tbl(l_sub_component_tbl_count).from_end_item_unit_number      := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).from_end_item_unit_number;
                 l_sub_component_tbl(l_sub_component_tbl_count).new_routing_revision           := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).new_routing_revision ;
                 l_sub_component_tbl(l_sub_component_tbl_count).enforce_int_requirements       := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).enforce_int_requirements ;
                 l_sub_component_tbl(l_sub_component_tbl_count).return_status                  := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).return_status ;
                 l_sub_component_tbl(l_sub_component_tbl_count).transaction_type               := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).transaction_type  ;
                 l_sub_component_tbl(l_sub_component_tbl_count).row_identifier                 := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).row_identifier ;
                 l_sub_component_tbl(l_sub_component_tbl_count).inverse_quantity               := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).inverse_quantity ;
                 l_sub_component_tbl(l_sub_component_tbl_count).program_id                     := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).program_id ;
                 l_sub_component_tbl_count  := l_sub_component_tbl_count + 1;
               END LOOP;
             END IF;
             l_rev_component_tbl_count := l_rev_component_tbl_count +1;
           END LOOP;
         END IF;
         l_revised_item_tbl_count := l_revised_item_tbl_count + 1;
       END LOOP;
     END IF;
     INV_EBI_UTIL.debug_line('STEP 110: BEFORE CALLING ENG_ECO_PUB.process_eco');

     --To create ECO
     ENG_ECO_PUB.process_eco (
       p_api_version_number    => 1.0
      ,p_eco_rec               => l_eco_rec
      ,p_eco_revision_tbl      => l_eco_revision_tbl
      ,p_revised_item_tbl      => l_revised_item_tbl
      ,p_rev_component_tbl     => l_rev_component_tbl
      ,p_sub_component_tbl     => l_sub_component_tbl
      ,p_ref_designator_tbl    => l_ref_designator_tbl
      ,p_change_line_tbl       => l_change_line_tbl
      ,p_rev_operation_tbl     => l_rev_operation_tbl
      ,p_rev_op_resource_tbl   => l_rev_op_resource_tbl
      ,p_rev_sub_resource_tbl  => l_rev_sub_resource_tbl
      ,x_eco_rec               => l_eco_rec
      ,x_eco_revision_tbl      => l_eco_revision_tbl
      ,x_revised_item_tbl      => l_revised_item_tbl
      ,x_rev_component_tbl     => l_rev_component_tbl
      ,x_sub_component_tbl     => l_sub_component_tbl
      ,x_ref_designator_tbl    => l_ref_designator_tbl
      ,x_change_line_tbl       => l_change_line_tbl
      ,x_rev_operation_tbl     => l_rev_operation_tbl
      ,x_rev_op_resource_tbl   => l_rev_op_resource_tbl
      ,x_rev_sub_resource_tbl  => l_rev_sub_resource_tbl
      ,x_return_status         => x_out.output_status.return_status
      ,x_msg_count             => x_out.output_status.msg_count
   );


   INV_EBI_UTIL.debug_line('STEP 120: AFTER CALLING ENG_ECO_PUB.process_eco STATUS: '|| x_out.output_status.return_status);
   IF (x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
     RAISE  FND_API.g_exc_unexpected_error;
   END IF;

   SELECT change_id ,change_notice  INTO x_out.change_id,x_out.change_notice
   FROM eng_engineering_changes
   WHERE change_notice = l_eco_rec.eco_name
   AND organization_id = l_organization_id;

   x_out.organization_code := p_change_order.organization_code;
   x_out.organization_id := l_organization_id;

   IF FND_API.to_boolean( p_commit ) THEN
     COMMIT;
   END IF;
   INV_EBI_UTIL.debug_line('STEP 130: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.process_eco STATUS: '|| x_out.output_status.return_status);
   EXCEPTION
     WHEN FND_API.g_exc_unexpected_error THEN
       ROLLBACK TO inv_ebi_proc_eco_save_pnt;
       x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;
       IF(x_out.output_status.msg_data IS NULL) THEN
         fnd_msg_pub.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_out.output_status.msg_count
          ,p_data    => x_out.output_status.msg_data
        );
      END IF;
      WHEN OTHERS THEN
        ROLLBACK TO inv_ebi_proc_eco_save_pnt;
        x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
        IF (x_out.output_status.msg_data IS NOT NULL) THEN
          x_out.output_status.msg_data      :=  x_out.output_status.msg_data||' -> INV_EBI_CHANGE_ORDER_HELPER.process_eco ';
        ELSE
          x_out.output_status.msg_data      :=  SQLERRM||' INV_EBI_CHANGE_ORDER_HELPER.process_eco ';
        END IF;
END process_eco;

/************************************************************************************
 --     API name        : process_structure_header
 --     Type            : Private
 --     Function        :
 --     This API is used to Process bom and common bom.
 --
 ************************************************************************************/
 PROCEDURE process_structure_header(
    p_commit                   IN  VARCHAR2 := FND_API.G_FALSE
   ,p_organization_code        IN  VARCHAR2
   ,p_assembly_item_name       IN  VARCHAR2
   ,p_alternate_bom_code       IN  VARCHAR2
   ,p_structure_header         IN  inv_ebi_structure_header_obj
   ,p_component_item_tbl       IN  inv_ebi_rev_comp_tbl
   ,p_name_val_list            IN  inv_ebi_name_value_list
   ,x_out                      OUT NOCOPY   inv_ebi_eco_output_obj
   )
   IS
     l_bom_header_rec           bom_bo_pub.bom_head_rec_type;
     l_bom_revision_tbl         bom_bo_pub.bom_revision_tbl_type;
     l_bom_component_tbl        bom_bo_pub.bom_comps_tbl_type;
     l_bom_ref_designator_tbl   bom_bo_pub.bom_ref_designator_tbl_type;
     l_bom_sub_component_tbl    bom_bo_pub.bom_sub_component_tbl_type;
     l_output_status            inv_ebi_output_status;
     l_is_bom_exists            VARCHAR2(3);
     l_transaction_type         VARCHAR2(20);

   BEGIN
   SAVEPOINT inv_ebi_proc_bom_save_pnt;
   l_output_status   := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
   x_out             := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);
   INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.process_structure_header');

   l_is_bom_exists   := is_bom_exists(
                           p_item_number         => p_assembly_item_name,
                           p_organization_code   => p_organization_code,
                           p_alternate_bom_code  => p_alternate_bom_code
                        );

   IF(l_is_bom_exists = fnd_api.g_false ) THEN
     l_transaction_type  := INV_EBI_ITEM_PUB.g_otype_create ;
   ELSE
     l_transaction_type  := INV_EBI_ITEM_PUB.g_otype_update;

     --Bug 7196996
    /* process_common_bom_orgs(
       p_assembly_item_name    => p_assembly_item_name,
       p_organization_code     => p_organization_code,
       p_alternate_bom_code    => p_alternate_bom_code,
       p_component_item_tbl    => p_component_item_tbl,
       x_out                   => x_out
     );
     IF (x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
       RAISE  FND_API.g_exc_unexpected_error;
     END IF; */
   END IF;

   IF(p_structure_header.common_assembly_item_name IS NOT NULL AND
      p_structure_header.common_assembly_item_name <> fnd_api.g_miss_char AND
      p_structure_header.common_organization_code IS NOT NULL AND
      p_structure_header.common_organization_code <> fnd_api.g_miss_char
     ) THEN
     --Bug 7127027
     INV_EBI_UTIL.debug_line('STEP 20: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.process_common_bom '||' ORG CODE : '|| p_organization_code ||
                                      ' ASSY ITEM NAME  : '|| p_assembly_item_name ||' COMMON ASSY ITEM NAME: '|| p_structure_header.common_assembly_item_name ||
				      ' COMMON ORG CODE : '|| p_structure_header.common_organization_code);
     process_common_bom(
       p_organization_code          =>  p_organization_code
      ,p_assembly_item_name         =>  p_assembly_item_name
      ,p_alternate_bom_code         =>  p_alternate_bom_code
      ,p_common_assembly_item_name  =>  p_structure_header.common_assembly_item_name
      ,p_common_organization_code   =>  p_structure_header.common_organization_code
      ,x_return_status              =>  x_out.output_status.return_status
      ,x_msg_data                   =>  x_out.output_status.msg_data
      ,x_msg_count                  =>  x_out.output_status.msg_count
     );
     INV_EBI_UTIL.debug_line('STEP 30: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.process_common_bom STATUS : '|| x_out.output_status.return_status);
     IF (x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
       RAISE  FND_API.g_exc_unexpected_error;
     END IF;
   END IF;

   l_bom_header_rec.assembly_item_name           :=  p_assembly_item_name ;
   l_bom_header_rec.organization_code            :=  p_organization_code;
   l_bom_header_rec.alternate_bom_code           :=  p_alternate_bom_code  ;
   l_bom_header_rec.common_assembly_item_name    :=  p_structure_header.common_assembly_item_name ;
   l_bom_header_rec.common_organization_code     :=  p_structure_header.common_organization_code ;
   l_bom_header_rec.assembly_comment             :=  p_structure_header.assembly_comment;
   l_bom_header_rec.assembly_type                :=  p_structure_header.assembly_type ;
   l_bom_header_rec.transaction_type             :=  l_transaction_type ;
   l_bom_header_rec.return_status                :=  p_structure_header.return_status ;
   l_bom_header_rec.attribute_category           :=  p_structure_header.attribute_category ;
   l_bom_header_rec.attribute1                   :=  p_structure_header.attribute1 ;
   l_bom_header_rec.attribute2                   :=  p_structure_header.attribute2 ;
   l_bom_header_rec.attribute3                   :=  p_structure_header.attribute3 ;
   l_bom_header_rec.attribute4                   :=  p_structure_header.attribute4 ;
   l_bom_header_rec.attribute5                   :=  p_structure_header.attribute5 ;
   l_bom_header_rec.attribute6                   :=  p_structure_header.attribute6 ;
   l_bom_header_rec.attribute7                   :=  p_structure_header.attribute7 ;
   l_bom_header_rec.attribute8                   :=  p_structure_header.attribute8 ;
   l_bom_header_rec.attribute9                   :=  p_structure_header.attribute9 ;
   l_bom_header_rec.attribute10                  :=  p_structure_header.attribute10;
   l_bom_header_rec.attribute11                  :=  p_structure_header.attribute11;
   l_bom_header_rec.attribute12                  :=  p_structure_header.attribute12;
   l_bom_header_rec.attribute13                  :=  p_structure_header.attribute13;
   l_bom_header_rec.attribute14                  :=  p_structure_header.attribute14;
   l_bom_header_rec.attribute15                  :=  p_structure_header.attribute15;
   l_bom_header_rec.original_system_reference    :=  p_structure_header.original_system_reference;
   l_bom_header_rec.delete_group_name            :=  p_structure_header.delete_group_name ;
   l_bom_header_rec.dg_description               :=  p_structure_header.dg_description ;
   l_bom_header_rec.row_identifier               :=  p_structure_header.row_identifier ;
   l_bom_header_rec.bom_implementation_date      :=  p_structure_header.bom_implementation_date ;
   l_bom_header_rec.enable_attrs_update          :=  p_structure_header.enable_attrs_update ;
   l_bom_header_rec.structure_type_name          :=  p_structure_header.structure_type_name ;

   IF(l_bom_header_rec.structure_type_name IS NULL OR
     l_bom_header_rec.structure_type_name = fnd_api.g_miss_char )
     AND (INV_EBI_UTIL.is_pim_installed) THEN
     IF p_name_val_list.name_value_table IS NOT NULL THEN
       FOR i in p_name_val_list.name_value_table.FIRST..p_name_val_list.name_value_table.LAST LOOP
         IF UPPER(p_name_val_list.name_value_table(i).param_name) = G_DEFAULT_STRUCTURE_TYPE THEN
           l_bom_header_rec.structure_type_name := p_name_val_list.name_value_table(i).param_value;
         END IF;
       END LOOP;
     END IF;
   END IF;
   INV_EBI_UTIL.debug_line('STEP 40: BEFORE CALLING BOM_BO_PUB.process_bom');

   BOM_BO_PUB.process_bom
     (
       p_bom_header_rec         =>  l_bom_header_rec
      ,p_bom_revision_tbl       =>  l_bom_revision_tbl
      ,p_bom_component_tbl      =>  l_bom_component_tbl
      ,p_bom_ref_designator_tbl =>  l_bom_ref_designator_tbl
      ,p_bom_sub_component_tbl  =>  l_bom_sub_component_tbl
      ,x_bom_header_rec         =>  l_bom_header_rec
      ,x_bom_revision_tbl       =>  l_bom_revision_tbl
      ,x_bom_component_tbl      =>  l_bom_component_tbl
      ,x_bom_ref_designator_tbl =>  l_bom_ref_designator_tbl
      ,x_bom_sub_component_tbl  =>  l_bom_sub_component_tbl
      ,x_return_status          =>  x_out.output_status.return_status
      ,x_msg_count              =>  x_out.output_status.msg_count
    );
    INV_EBI_UTIL.debug_line('STEP 50: AFTER CALLING BOM_BO_PUB.process_bom '||' RETURN STATUS: '|| x_out.output_status.return_status);
    IF (x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
      RAISE  FND_API.g_exc_unexpected_error;
    END IF;
    IF FND_API.to_boolean( p_commit ) THEN
      COMMIT;
    END IF;
       INV_EBI_UTIL.debug_line('STEP 60: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.process_structure_header STATUS: '|| x_out.output_status.return_status);
    EXCEPTION
      WHEN FND_API.g_exc_unexpected_error THEN
        ROLLBACK TO inv_ebi_proc_bom_save_pnt;
        x_out.output_status.return_status :=  FND_API.g_ret_sts_error;
        IF(x_out.output_status.msg_data IS NULL) THEN
          fnd_msg_pub.count_and_get(
            p_encoded => FND_API.g_false
           ,p_count   => x_out.output_status.msg_count
           ,p_data    => x_out.output_status.msg_data
         );
      END IF;
      WHEN OTHERS THEN
        ROLLBACK TO inv_ebi_proc_bom_save_pnt;
        x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
        IF (x_out.output_status.msg_data IS NOT NULL) THEN
          x_out.output_status.msg_data      :=  x_out.output_status.msg_data||' -> INV_EBI_CHANGE_ORDER_HELPER.process_structure_header ';
        ELSE
          x_out.output_status.msg_data      :=  SQLERRM||' INV_EBI_CHANGE_ORDER_HELPER.process_structure_header ';
        END IF;
  END process_structure_header;

/************************************************************************************
 --     API name        : get_eco
 --     Type            : Public
 --     Function        :
 --     This API is used to retrieve all the change order attributes
************************************************************************************/
PROCEDURE get_eco (
    p_change_id                 IN              NUMBER
   ,p_last_update_status        IN              VARCHAR2
   ,p_revised_item_sequence_id  IN              NUMBER
   ,p_name_val_list             IN              inv_ebi_name_value_list
   ,x_eco_obj                   OUT NOCOPY      inv_ebi_eco_obj
   ,x_return_status             OUT NOCOPY      VARCHAR2
   ,x_msg_count                 OUT NOCOPY      NUMBER
   ,x_msg_data                  OUT NOCOPY      VARCHAR2
  )
IS
  l_eco_change_order_obj     inv_ebi_change_order_obj;
  l_eco_revision_tbl         inv_ebi_eco_revision_tbl;
  l_eco_revision_obj         inv_ebi_eco_revision_obj;
  l_substitute_component_tbl inv_ebi_sub_comp_tbl;
  l_substitute_component_obj inv_ebi_sub_comp_obj;
  l_reference_designator_tbl inv_ebi_ref_desg_tbl;
  l_reference_designator_obj inv_ebi_ref_desg_obj;
  l_revision_component_tbl   inv_ebi_rev_comp_tbl;
  l_revision_component_obj   inv_ebi_rev_comp_obj;
  l_revised_item_tbl         inv_ebi_revised_item_tbl;
  l_revised_item_obj         inv_ebi_revised_item_obj;
  l_structure_header_obj     inv_ebi_structure_header_obj;
  l_current_index            NUMBER;
  l_reviseditem_index        NUMBER;
  l_comp_index               NUMBER;
  l_sub_index                NUMBER;
  l_ref_index                NUMBER;
  l_change_id                NUMBER := NULL;
  l_revised_item_sequence_id NUMBER := NULL;
  l_include_rev_items        VARCHAR2(1):= fnd_api.g_true;
  l_include_comp_items       VARCHAR2(1):= fnd_api.g_true;
  l_include_sub_comp         VARCHAR2(1):= fnd_api.g_true;
  l_include_ref_designators  VARCHAR2(1):= fnd_api.g_true;
  l_item_obj                 inv_ebi_item_obj;

  CURSOR c_change_order_type(p_change_id IN VARCHAR2) IS
  SELECT
    eec.change_notice
   ,eec.change_order_type_id
   ,eec.change_notice_prefix
   ,eec.change_notice_number
   ,mp.organization_code
   ,mp.organization_id
   ,eec.change_name
   ,eec.description
   ,eec.cancellation_comments
   ,eec.status_code
   ,ecsv.status_name
   ,eec.priority_code
   ,eec.reason_code
   ,eec.estimated_eng_cost
   ,eec.estimated_mfg_cost
   ,eec.attribute_category
   ,eec.attribute1
   ,eec.attribute2
   ,eec.attribute3
   ,eec.attribute4
   ,eec.attribute5
   ,eec.attribute6
   ,eec.attribute7
   ,eec.attribute8
   ,eec.attribute9
   ,eec.attribute10
   ,eec.attribute11
   ,eec.attribute12
   ,eec.attribute13
   ,eec.attribute14
   ,eec.attribute15
   ,eec.ddf_context
   ,eeal.approval_list_name
   ,eec.approval_date
   ,eec.approval_request_date
   ,eec.change_mgmt_type_code
   ,eec.original_system_reference
   ,eec.organization_hierarchy
   ,hp.party_name   assignee
   ,ppa.name  project_name
   ,ppe.name  task_number
   ,eec.source_type_code
   ,eec.source_name
   ,eec.need_by_date
   ,eec.effort
   ,haou.name  eco_department_name
   ,eec.internal_use_only
   ,eec.plm_or_erp_change
   ,eec.status_type
   ,eec.implementation_date
   ,eec.cancellation_date
   ,ecot.type_name
  FROM
    eng_engineering_changes eec
   ,mtl_parameters mp
   ,eng_change_statuses_vl ecsv
   ,eng_ecn_approval_lists eeal
   ,hz_parties hp
   ,pa_projects_all ppa
   ,pa_proj_elements ppe
   ,hr_all_organization_units_vl haou
   ,eng_change_order_types_vl ecot
  WHERE
    eec.change_id             = p_change_id AND
    eec.change_order_type_id  =ecot.change_order_type_id AND
    mp.organization_id        = eec.organization_id AND
    ecsv.status_code(+)       = eec.status_code AND
    eeal.approval_list_id(+)  = eec.approval_list_id AND
    hp.party_id(+)            = eec.assignee_id AND
    ppa.project_id(+)         = eec.project_id AND
    ppe.proj_element_id(+)    = eec.task_id AND
    haou.organization_id(+)   = eec.responsible_organization_id;

  c_eco_header               c_change_order_type%ROWTYPE;

  CURSOR c_eco_revision(p_change_id IN VARCHAR2) IS
  SELECT
    ecor.revision
   ,ecor.comments
   ,ecor.attribute_category
   ,ecor.attribute1
   ,ecor.attribute2
   ,ecor.attribute3
   ,ecor.attribute4
   ,ecor.attribute5
   ,ecor.attribute6
   ,ecor.attribute7
   ,ecor.attribute8
   ,ecor.attribute9
   ,ecor.attribute10
   ,ecor.attribute11
   ,ecor.attribute12
   ,ecor.attribute13
   ,ecor.attribute14
   ,ecor.attribute15
   ,eec.change_mgmt_type_code
   ,ecor.original_system_reference
  FROM
    eng_change_order_revisions ecor
   ,eng_engineering_changes eec
  WHERE
    ecor.change_id = eec.change_id AND
    ecor.change_id = p_change_id;

  CURSOR c_substitute_component(p_change_id IN VARCHAR2,p_revised_item_id IN NUMBER,p_component_id IN NUMBER) IS
  SELECT
    mif.item_number substitute_component_name
   ,bsc.acd_type
   ,bsc.substitute_item_quantity
   ,bsc.attribute_category
   ,bsc.attribute1
   ,bsc.attribute2
   ,bsc.attribute3
   ,bsc.attribute4
   ,bsc.attribute5
   ,bsc.attribute6
   ,bsc.attribute7
   ,bsc.attribute8
   ,bsc.attribute9
   ,bsc.attribute10
   ,bsc.attribute11
   ,bsc.attribute12
   ,bsc.attribute13
   ,bsc.attribute14
   ,bsc.attribute15
   ,bsc.original_system_reference
   ,bsc.enforce_int_requirements
   ,bsc.program_id
  FROM
    bom_inventory_components bic
   ,eng_revised_items eri
   ,mtl_item_flexfields mif
   ,bom_substitute_components bsc
  WHERE
    eri.change_id         = p_change_id AND
    eri.revised_item_id   = p_revised_item_id AND
    bic.component_item_id = p_component_id AND
    bic.revised_item_sequence_id(+) = eri.revised_item_sequence_id AND
    bsc.component_sequence_id = bic.component_sequence_id AND
    mif.inventory_item_id = bsc.substitute_component_id  AND
    mif.organization_id = eri.organization_id;

  CURSOR c_reference_designator(p_change_id IN VARCHAR2,p_revised_item_id IN NUMBER,p_component_id IN NUMBER) IS
  SELECT
    brd.component_reference_designator reference_designator_name
   ,brd.acd_type
   ,brd.ref_designator_comment
   ,brd.attribute_category
   ,brd.attribute1
   ,brd.attribute2
   ,brd.attribute3
   ,brd.attribute4
   ,brd.attribute5
   ,brd.attribute6
   ,brd.attribute7
   ,brd.attribute8
   ,brd.attribute9
   ,brd.attribute10
   ,brd.attribute11
   ,brd.attribute12
   ,brd.attribute13
   ,brd.attribute14
   ,brd.attribute15
   ,brd.original_system_reference
  FROM
    bom_inventory_components bic
   ,eng_revised_items eri
   ,bom_reference_designators brd
  WHERE
    eri.change_id = p_change_id AND
    eri.revised_item_id = p_revised_item_id AND
    bic.component_item_id = p_component_id AND
    bic.revised_item_sequence_id(+)=eri.revised_item_sequence_id AND
    brd.component_sequence_id(+)=bic.component_sequence_id;

  CURSOR c_revision_component(p_change_id IN VARCHAR2,p_revised_item_id IN NUMBER) IS
  SELECT
    bic.component_item_id
   ,bic.disable_date
   ,bic.operation_seq_num
   ,mif.item_number component_item_name
   ,bic.acd_type
   ,bic.basis_type
   ,bic.component_quantity
   ,bic.component_quantity inverse_quantity
   ,bic.include_in_cost_rollup
   ,bic.wip_supply_type
   ,bic.so_basis
   ,bic.optional
   ,bic.mutually_exclusive_options
   ,bic.check_atp
   ,bic.shipping_allowed
   ,bic.required_to_ship
   ,bic.required_for_revenue
   ,bic.include_on_ship_docs
   ,bic.quantity_related
   ,bic.supply_subinventory
   ,bic.attribute_category
   ,bic.attribute1
   ,bic.attribute2
   ,bic.attribute3
   ,bic.attribute4
   ,bic.attribute5
   ,bic.attribute6
   ,bic.attribute7
   ,bic.attribute8
   ,bic.attribute9
   ,bic.attribute10
   ,bic.attribute11
   ,bic.attribute12
   ,bic.attribute13
   ,bic.attribute14
   ,bic.attribute15
   ,bic.from_end_item_unit_number
   ,bic.to_end_item_unit_number
   ,bic.enforce_int_requirements
   ,bic.auto_request_material
   ,bic.suggested_vendor_name
   ,bic.unit_price
   ,bic.original_system_reference
  FROM
    bom_inventory_components bic
   ,eng_revised_items eri
   ,mtl_item_flexfields mif
  WHERE
    eri.change_id = p_change_id AND
    eri.revised_item_id = p_revised_item_id AND
    bic.revised_item_sequence_id(+)=eri.revised_item_sequence_id AND
    mif.inventory_item_id=bic.component_item_id  AND
    mif.organization_id=eri.organization_id;

  CURSOR c_revised_item(p_change_id IN VARCHAR2) IS
  SELECT
    eri.revised_item_id
   ,mif.item_number revised_item_name
   ,eri.new_item_revision
   ,eri.alternate_bom_designator
   ,eri.status_code
   ,eri.status_type
   ,eri.mrp_active
   ,mif1.item_number use_up_item_name
   ,eri.use_up_plan_name
   ,eri.disposition_type
   ,eri.update_wip
   ,eri.cancel_comments
   ,eri.attribute_category
   ,eri.attribute1
   ,eri.attribute2
   ,eri.attribute3
   ,eri.attribute4
   ,eri.attribute5
   ,eri.attribute6
   ,eri.attribute7
   ,eri.attribute8
   ,eri.attribute9
   ,eri.attribute10
   ,eri.attribute11
   ,eri.attribute12
   ,eri.attribute13
   ,eri.attribute14
   ,eri.attribute15
   ,eri.scheduled_date
   ,eri.from_end_item_unit_number
   ,eri.original_system_reference
   ,eri.from_cum_qty
   ,eri.lot_number
   ,eri.completion_subinventory
   ,eri.priority
   ,eri.ctp_flag
   ,eri.new_routing_revision
   ,eri.routing_comment
   ,eri.eco_for_production
   ,eri.transfer_or_copy
   ,eri.transfer_or_copy_item
   ,eri.transfer_or_copy_bill
   ,eri.transfer_or_copy_routing
   ,eri.copy_to_item
   ,eri.copy_to_item_desc
   ,eri.selection_option
   ,eri.selection_date
   ,eri.selection_unit_number
   ,eri.enable_item_in_local_org
   ,eri.create_bom_in_local_org
   ,eri.new_structure_revision
   ,eri.plan_level
   ,eri.new_revision_label
   ,eri.new_revision_reason
   ,eri.revised_item_sequence_id
   ,eriv.revised_item_status
   ,eri.organization_id
  FROM
    eng_revised_items   eri
   ,mtl_item_flexfields mif
   ,mtl_item_flexfields mif1
   ,eng_revised_items_v eriv
  WHERE
    eri.change_id = p_change_id AND
    mif.inventory_item_id = eri.revised_item_id AND
    mif.organization_id = eri.organization_id AND
    mif1.inventory_item_id(+) = eri.use_up_item_id AND
    eri.revised_item_sequence_id = eriv.revised_item_sequence_id AND
    mif1.organization_id(+) = eri.organization_id;

  CURSOR c_structure_header(p_change_id IN VARCHAR2,p_revised_item_id IN NUMBER) IS
  SELECT
    msl.concatenated_segments
   ,bev.common_organization_name
   ,bev.assembly_type
   ,bev.attribute1
   ,bev.attribute2
   ,bev.attribute3
   ,bev.attribute4
   ,bev.attribute5
   ,bev.attribute6
   ,bev.attribute7
   ,bev.attribute8
   ,bev.attribute9
   ,bev.attribute10
   ,bev.attribute11
   ,bev.attribute12
   ,bev.attribute13
   ,bev.attribute14
   ,bev.attribute15
   ,bev.bom_implementation_date
   ,bst.structure_type_name
  FROM
    bom_explosions_v bev
   ,eng_revised_items eri
   ,bom_structure_types_vl bst
   ,mtl_system_items_vl msl
  WHERE
    eri.change_id = p_change_id AND
    bev.assembly_item_id = p_revised_item_id AND
    bev.access_flag = 'T' AND
    bev.organization_id = eri.organization_id(+) AND
    bst.structure_type_id = bev.structure_type_id AND
    msl.inventory_item_id(+) = bev.assembly_item_id AND
    msl.organization_id(+) = bev.organization_id;

  c_bom_header        c_structure_header%ROWTYPE;

  CURSOR c_change_id(p_revised_item_sequence_id IN NUMBER) IS
  SELECT
    change_id
  FROM
    eng_Revised_items
  WHERE
    revised_item_sequence_id = p_revised_item_sequence_id;

BEGIN
  INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.get_eco');
  x_return_status := fnd_api.g_ret_sts_success;
  l_change_id := p_change_id ;
  l_revised_item_sequence_id := p_revised_item_sequence_id;

  FND_MSG_PUB.initialize();
  IF (l_change_id IS NULL AND l_revised_item_sequence_id IS NULL) THEN
    FND_MESSAGE.set_name('INV','INV_EBI_CHG_ID_REV_SEQ_NULL');
    FND_MSG_PUB.add;
    RAISE FND_API.g_exc_error;
  END IF;

  IF (l_revised_item_sequence_id IS NOT NULL AND l_change_id IS NULL) THEN
    OPEN c_change_id(l_revised_item_sequence_id);
    FETCH c_change_id INTO l_change_id;
    IF c_change_id%NOTFOUND THEN
      FND_MESSAGE.set_name('INV','INV_EBI_REV_SEQ_ID_INVALID');
      FND_MESSAGE.set_token('REV_SEQ_ID',l_revised_item_sequence_id);
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    END IF;
    CLOSE c_change_id;
  END IF;

  IF p_name_val_list.name_value_table IS NOT NULL THEN
    FOR i in p_name_val_list.name_value_table.FIRST..p_name_val_list.name_value_table.LAST LOOP
      IF UPPER(p_name_val_list.name_value_table(i).param_name) = G_INCLUDE_REV_ITEMS THEN
        l_include_rev_items := p_name_val_list.name_value_table(i).param_value;
      END IF;
      IF UPPER(p_name_val_list.name_value_table(i).param_name) = G_INCLUDE_COMP_ITEMS THEN
        l_include_comp_items := p_name_val_list.name_value_table(i).param_value;
      END IF;
      IF UPPER(p_name_val_list.name_value_table(i).param_name) = G_INCLUDE_SUB_COMP THEN
        l_include_sub_comp := p_name_val_list.name_value_table(i).param_value;
      END IF;
      IF UPPER(p_name_val_list.name_value_table(i).param_name) = G_INCLUDE_REF_DESIGNATORS THEN
        l_include_ref_designators := p_name_val_list.name_value_table(i).param_value;
      END IF;
    END LOOP;
  END IF;

  IF NVL(p_last_update_status,'Y') = 'N' THEN
        l_include_rev_items       := fnd_api.g_false;
        l_include_comp_items      := fnd_api.g_false;
        l_include_sub_comp        := fnd_api.g_false;
        l_include_ref_designators := fnd_api.g_false;
  END IF;
  l_eco_revision_tbl := inv_ebi_eco_revision_tbl();

  OPEN c_change_order_type (l_change_id);
  FETCH c_change_order_type INTO c_eco_header;
  IF c_change_order_type%NOTFOUND THEN
    FND_MESSAGE.set_name('INV','INV_EBI_CHG_ID_INVALID');
    FND_MESSAGE.set_token('CHG_ID',l_change_id);
    FND_MSG_PUB.add;
    RAISE FND_API.g_exc_error;
  END IF;
  l_eco_change_order_obj := inv_ebi_change_order_obj(
                               c_eco_header.change_notice
                              ,l_change_id
                              ,c_eco_header.change_notice_prefix
                              ,c_eco_header.change_notice_number
                              ,c_eco_header.organization_code
                              ,c_eco_header.organization_id
                              ,c_eco_header.change_name
                              ,c_eco_header.description
                              ,c_eco_header.cancellation_comments
                              ,c_eco_header.status_code
                              ,c_eco_header.status_name
                              ,c_eco_header.priority_code
                              ,c_eco_header.reason_code
                              ,c_eco_header.estimated_eng_cost
                              ,c_eco_header.estimated_mfg_cost
                              ,NULL
                              ,c_eco_header.attribute_category
                              ,c_eco_header.attribute1
                              ,c_eco_header.attribute2
                              ,c_eco_header.attribute3
                              ,c_eco_header.attribute4
                              ,c_eco_header.attribute5
                              ,c_eco_header.attribute6
                              ,c_eco_header.attribute7
                              ,c_eco_header.attribute8
                              ,c_eco_header.attribute9
                              ,c_eco_header.attribute10
                              ,c_eco_header.attribute11
                              ,c_eco_header.attribute12
                              ,c_eco_header.attribute13
                              ,c_eco_header.attribute14
                              ,c_eco_header.attribute15
                              ,c_eco_header.ddf_context
                              ,c_eco_header.approval_list_name
                              ,NULL
                              ,c_eco_header.approval_date
                              ,c_eco_header.approval_request_date
                              ,c_eco_header.change_order_type_id
                              ,c_eco_header.type_name
                              ,c_eco_header.change_mgmt_type_code
                              ,c_eco_header.original_system_reference
                              ,c_eco_header.organization_hierarchy
                              ,NULL --c_eco_header.party_name --assignee
                              ,NULL --c_eco_header.name --project_name
                              ,NULL --c_eco_header.name --task_number
                              ,c_eco_header.source_type_code
                              ,c_eco_header.source_name
                              ,c_eco_header.need_by_date
                              ,c_eco_header.effort
                              ,NULL --c_eco_header.name --eco_department_name
                              ,NULL --transaction_id
                              ,NULL --transaction_type
                              ,c_eco_header.internal_use_only
                              ,NULL --return_status
                              ,c_eco_header.plm_or_erp_change
                              ,NULL
                              ,NULL
                              ,NULL
                              ,NULL
                              ,NULL
                              ,c_eco_header.status_type
                              ,c_eco_header.implementation_date
                              ,c_eco_header.cancellation_date
                              ,NULL
                              ,NULL
                              ,NULL
                              ,NULL
                              ,NULL);
  CLOSE c_change_order_type;

  l_revised_item_tbl := inv_ebi_revised_item_tbl();

  l_current_index :=1;
  FOR cer IN c_eco_revision(l_change_id)
  LOOP
    l_eco_revision_tbl.extend();
    l_eco_revision_obj := inv_ebi_eco_revision_obj(
                             cer.revision
                            ,NULL
                            ,cer.comments
                            ,cer.attribute_category
                            ,cer.attribute1
                            ,cer.attribute2
                            ,cer.attribute3
                            ,cer.attribute4
                            ,cer.attribute5
                            ,cer.attribute6
                            ,cer.attribute7
                            ,cer.attribute8
                            ,cer.attribute9
                            ,cer.attribute10
                            ,cer.attribute11
                            ,cer.attribute12
                            ,cer.attribute13
                            ,cer.attribute14
                            ,cer.attribute15
                            ,cer.change_mgmt_type_code
                            ,cer.original_system_reference
                            ,NULL
                            ,NULL
                            ,NULL
                           );
    l_eco_revision_tbl(l_current_index) := l_eco_revision_obj;
    l_current_index := l_current_index + 1;
  END LOOP;

  IF (l_include_rev_items = fnd_api.g_true) THEN
    l_reviseditem_index := 1;
    FOR ri IN c_revised_item(l_change_id)
    LOOP
      OPEN c_structure_header(l_change_id,ri.revised_item_id);
      FETCH c_structure_header INTO c_bom_header;
      l_structure_header_obj := inv_ebi_structure_header_obj(
                                  c_bom_header.concatenated_segments
                                 ,c_bom_header.common_organization_name
                                 ,NULL
                                 ,c_bom_header.assembly_type
                                 ,NULL
                                 ,NULL
                                 ,NULL
                                 ,c_bom_header.attribute1
                                 ,c_bom_header.attribute2
                                 ,c_bom_header.attribute3
                                 ,c_bom_header.attribute4
                                 ,c_bom_header.attribute5
                                 ,c_bom_header.attribute6
                                 ,c_bom_header.attribute7
                                 ,c_bom_header.attribute8
                                 ,c_bom_header.attribute9
                                 ,c_bom_header.attribute10
                                 ,c_bom_header.attribute11
                                 ,c_bom_header.attribute12
                                 ,c_bom_header.attribute13
                                 ,c_bom_header.attribute14
                                 ,c_bom_header.attribute15
                                 ,NULL
                                 ,NULL
                                 ,NULL
                                 ,NULL
                                 ,c_bom_header.bom_implementation_date
                                 ,NULL
                                 ,c_bom_header.structure_type_name
                                 ,NULL
                                   );
      CLOSE c_structure_header;
      l_comp_index := 1;
      l_revision_component_tbl := inv_ebi_rev_comp_tbl();
      IF (l_include_comp_items = fnd_api.g_true) THEN
        FOR rc IN c_revision_component(l_change_id,ri.revised_item_id)
        LOOP
          l_ref_index := 1;
          l_reference_designator_tbl := inv_ebi_ref_desg_tbl();
          IF (l_include_ref_designators = fnd_api.g_true) THEN
            FOR rd IN c_reference_designator(l_change_id,ri.revised_item_id,rc.component_item_id)
            LOOP
              l_reference_designator_tbl.extend();
              l_reference_designator_obj := inv_ebi_ref_desg_obj(
                                                NULL
                                               ,rd.reference_designator_name
                                               ,rd.acd_type
                                               ,rd.ref_designator_comment
                                               ,rd.attribute_category
                                               ,rd.attribute1
                                               ,rd.attribute2
                                               ,rd.attribute3
                                               ,rd.attribute4
                                               ,rd.attribute5
                                               ,rd.attribute6
                                               ,rd.attribute7
                                               ,rd.attribute8
                                               ,rd.attribute9
                                               ,rd.attribute10
                                               ,rd.attribute11
                                               ,rd.attribute12
                                               ,rd.attribute13
                                               ,rd.attribute14
                                               ,rd.attribute15
                                               ,rd.original_system_reference
                                               ,NULL
                                               ,NULL
                                               ,NULL
                                               ,NULL
                                               ,NULL
                                               ,NULL
                                               ,NULL);
              l_reference_designator_tbl(l_ref_index) := l_reference_designator_obj;
              l_ref_index := l_ref_index + 1;
            END LOOP;
          END IF; -- IF (l_include_ref_designators = fnd_api.g_true) THEN

          l_sub_index :=1;
          l_substitute_component_tbl := inv_ebi_sub_comp_tbl();
          IF (l_include_sub_comp = fnd_api.g_true) THEN
            FOR sc IN c_substitute_component(l_change_id,ri.revised_item_id,rc.component_item_id)
            LOOP
              l_substitute_component_tbl.extend();
              l_substitute_component_obj := inv_ebi_sub_comp_obj(
                                           NULL
                                          ,sc.substitute_component_name
                                          ,NULL
                                          ,sc.acd_type
                                          ,sc.substitute_item_quantity
                                          ,sc.attribute_category
                                          ,sc.attribute1
                                          ,sc.attribute2
                                          ,sc.attribute3
                                          ,sc.attribute4
                                          ,sc.attribute5
                                          ,sc.attribute6
                                          ,sc.attribute7
                                          ,sc.attribute8
                                          ,sc.attribute9
                                          ,sc.attribute10
                                          ,sc.attribute11
                                          ,sc.attribute12
                                          ,sc.attribute13
                                          ,sc.attribute14
                                          ,sc.attribute15
                                          ,sc.original_system_reference
                                          ,NULL
                                          ,NULL
                                          ,sc.enforce_int_requirements
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,sc.program_id
                                          ,NULL);
              l_substitute_component_tbl(l_sub_index) := l_substitute_component_obj;
              l_sub_index := l_sub_index + 1;
            END LOOP;
          END IF; -- IF (l_include_sub_comp = fnd_api.g_true) THEN

          l_revision_component_tbl.extend();
          l_revision_component_obj := inv_ebi_rev_comp_obj(
                                       NULL
                                      ,NULL
                                      ,rc.disable_date
                                      ,rc.operation_seq_num
                                      ,rc.component_item_name
                                      ,l_substitute_component_tbl
                                      ,l_reference_designator_tbl
                                      ,rc.acd_type
                                      ,NULL
                                      ,NULL
                                      ,NULL
                                      ,NULL
                                      ,rc.basis_type
                                      ,rc.component_quantity
                                      ,rc.inverse_quantity
                                      ,NULL
                                      ,NULL
                                      ,rc.include_in_cost_rollup
                                      ,rc.wip_supply_type
                                      ,rc.so_basis
                                      ,rc.optional
                                      ,rc.mutually_exclusive_options
                                      ,rc.check_atp
                                      ,rc.shipping_allowed
                                      ,rc.required_to_ship
                                      ,rc.required_for_revenue
                                      ,rc.include_on_ship_docs
                                      ,rc.quantity_related
                                      ,rc.supply_subinventory
                                      ,NULL
                                      ,NULL
                                      ,NULL
                                      ,NULL
                                      ,NULL
                                      ,rc.attribute_category
                                      ,rc.attribute1
                                      ,rc.attribute2
                                      ,rc.attribute3
                                      ,rc.attribute4
                                      ,rc.attribute5
                                      ,rc.attribute6
                                      ,rc.attribute7
                                      ,rc.attribute8
                                      ,rc.attribute9
                                      ,rc.attribute10
                                      ,rc.attribute11
                                      ,rc.attribute12
                                      ,rc.attribute13
                                      ,rc.attribute14
                                      ,rc.attribute15
                                      ,rc.from_end_item_unit_number
                                      ,NULL
                                      ,NULL
                                      ,rc.to_end_item_unit_number
                                      ,NULL
                                      ,rc.enforce_int_requirements
                                      ,rc.auto_request_material
                                      ,rc.suggested_vendor_name
                                      ,rc.unit_price
                                      ,rc.original_system_reference
                                      ,NULL
                                      ,NULL
                                      ,NULL
                                      ,NULL
                                      ,NULL
                                      ,NULL
                                      ,NULL
                                      ,NULL);
          l_revision_component_tbl(l_comp_index) := l_revision_component_obj;
          l_comp_index := l_comp_index + 1;
        END LOOP;
      END IF; -- IF (l_include_comp_items = fnd_api.g_true) THEN


      IF (l_revised_item_sequence_id IS NULL
          OR ri.revised_item_sequence_id = l_revised_item_sequence_id) THEN

        l_revised_item_tbl.extend();
        l_item_obj :=inv_ebi_item_obj(NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                     );
        INV_EBI_ITEM_HELPER.get_Operating_unit
        (p_oranization_id => ri.organization_id
        ,x_operating_unit => l_item_obj.operating_unit
        ,x_ouid      => l_item_obj.operating_unit_id
        );
        l_revised_item_obj := inv_ebi_revised_item_obj(
                                   ri.revised_item_name
                                  ,ri.revised_item_id
                                  ,ri.new_item_revision
                                  ,NULL
                                  ,NULL
                                  ,NULL
                                  ,l_item_obj
                                  ,l_structure_header_obj
                                  ,l_revision_component_tbl
                                  ,NULL
                                  ,NULL
                                  ,NULL
                                  ,ri.scheduled_date
                                  ,ri.alternate_bom_designator
                                  ,ri.status_type
                                  ,ri.status_code
                                  ,ri.revised_item_status
                                  ,ri.mrp_active
                                  ,NULL
                                  ,ri.use_up_item_name
                                  ,ri.use_up_plan_name
                                  ,NULL
                                  ,ri.disposition_type
                                  ,ri.update_wip
                                  ,ri.cancel_comments
                                  ,NULL
                                  ,ri.attribute_category
                                  ,ri.attribute1
                                  ,ri.attribute2
                                  ,ri.attribute3
                                  ,ri.attribute4
                                  ,ri.attribute5
                                  ,ri.attribute6
                                  ,ri.attribute7
                                  ,ri.attribute8
                                  ,ri.attribute9
                                  ,ri.attribute10
                                  ,ri.attribute11
                                  ,ri.attribute12
                                  ,ri.attribute13
                                  ,ri.attribute14
                                  ,ri.attribute15
                                  ,ri.from_end_item_unit_number
                                  ,NULL
                                  ,ri.original_system_reference
                                  ,NULL
                                  ,NULL
                                  ,NULL
                                  ,NULL
                                  ,NULL
                                  ,ri.from_cum_qty
                                  ,ri.lot_number
                                  ,ri.completion_subinventory
                                  ,NULL
                                  ,ri.priority
                                  ,ri.ctp_flag
                                  ,ri.new_routing_revision
                                  ,NULL
                                  ,ri.routing_comment
                                  ,ri.eco_for_production
                                  ,NULL
                                  ,ri.transfer_or_copy
                                  ,ri.transfer_or_copy_item
                                  ,ri.transfer_or_copy_bill
                                  ,ri.transfer_or_copy_routing
                                  ,ri.copy_to_item
                                  ,ri.copy_to_item_desc
                                  ,NULL
                                  ,NULL
                                  ,ri.selection_option
                                  ,ri.selection_date
                                  ,ri.selection_unit_number
                                  ,NULL
                                  ,NULL
                                  ,NULL
                                  ,NULL
                                  ,ri.enable_item_in_local_org
                                  ,ri.create_bom_in_local_org
                                  ,ri.new_structure_revision
                                  ,ri.plan_level
                                  ,NULL
                                  ,NULL
                                  ,NULL
                                  ,NULL
                                  ,NULL
                                  ,ri.new_revision_label
                                  ,ri.new_revision_reason
                                  ,NULL
                                  ,NULL
                                  ,NULL
                                  ,NULL
                                  ,NULL
                                  ,NULL
                                  ,NULL);

        l_revised_item_tbl(l_reviseditem_index) := l_revised_item_obj;
        l_reviseditem_index := l_reviseditem_index + 1;
      END IF;
    END LOOP;
  END IF; -- IF (l_include_rev_items = fnd_api.g_true) THEN

 IF (INV_EBI_UTIL.is_pim_installed) THEN --Bug 8369900 To check is_pim_installed for reverse flow
  --Bug 7240247 To Retrieve Change order Header level Udas if any exists for this change_id
  INV_EBI_UTIL.debug_line('STEP 20: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.get_change_order_uda');
  get_change_order_uda(
      p_change_id       => p_change_id,
      x_change_uda      => l_eco_change_order_obj.change_order_uda,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data
   );
   INV_EBI_UTIL.debug_line('STEP 30: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.get_change_order_uda STATUS: '||x_return_status);
   IF(x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE FND_API.g_exc_unexpected_error;
   END IF;

  --Bug 7240247 To Retrieve Structure Header level Udas if any exists for this change_id
  FOR i IN 1..l_revised_item_tbl.COUNT LOOP
    INV_EBI_UTIL.debug_line('STEP 40: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.get_structure_header_uda');
    get_structure_header_uda(
      p_assembly_item_id       => l_revised_item_tbl(i).revised_item_id,
      p_alternate_bom_code     => l_revised_item_tbl(i).alternate_bom_code,
      p_organization_id        => l_eco_change_order_obj.organization_id,
      x_structure_header_uda   => l_revised_item_tbl(i).structure_header.structure_header_uda,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data
     );
    INV_EBI_UTIL.debug_line('STEP 50: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.get_structure_header_uda STATUS: '||x_return_status);
    IF(x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    --Bug 7240247
    FOR j IN 1..l_revised_item_tbl(i).component_item_tbl.COUNT LOOP
       INV_EBI_UTIL.debug_line('STEP 60: BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.get_component_item_uda');
       get_component_item_uda(
         p_eco_name              => l_eco_change_order_obj.eco_name,
         p_revised_item_id       => l_revised_item_tbl(i).revised_item_id,
         p_component_item_name   => l_revised_item_tbl(i).component_item_tbl(j).component_item_name,
         p_alternate_bom_code    => l_revised_item_tbl(i).alternate_bom_code,
         p_organization_id       => l_eco_change_order_obj.organization_id,
         x_comp_item_uda         => l_revised_item_tbl(i).component_item_tbl(j).component_revision_uda,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data
       );
      INV_EBI_UTIL.debug_line('STEP 70: AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.get_component_item_uda STATUS: '||x_return_status);
      IF(x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
    END LOOP;

  END LOOP;
  END IF;-- Bug 8369900 end
  x_eco_obj := inv_ebi_eco_obj(l_eco_change_order_obj,l_eco_revision_tbl,l_revised_item_tbl,NULL);
  INV_EBI_UTIL.debug_line('STEP 80: END CALLING INV_EBI_CHANGE_ORDER_HELPER.get_eco');
EXCEPTION
  WHEN FND_API.g_exc_error THEN
      x_return_status :=  FND_API.g_ret_sts_error;
      IF(x_msg_data IS NULL) THEN
        FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false
         ,p_count => x_msg_count
         ,p_data => x_msg_data
        );
      END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_error;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data ||' -> at INV_EBI_CHANGE_ORDER_HELPER.get_eco';
    ELSE
      x_msg_data  :=  SQLERRM||' at INV_EBI_CHANGE_ORDER_HELPER.get_eco ';
    END IF;
END get_eco;

/************************************************************************************
--      API name        : filter_ecos_based_on_org
--      Type            : Public
--      Function        : To filter eco's based on the given organization
************************************************************************************/

PROCEDURE filter_ecos_based_on_org(
  p_org_codes              IN         VARCHAR2
 ,p_eco_tbl               IN          inv_ebi_change_id_obj_tbl
 ,x_eco_tbl                OUT NOCOPY inv_ebi_change_id_obj_tbl
 ,x_return_status          OUT NOCOPY VARCHAR2
 ,x_msg_count              OUT NOCOPY NUMBER
 ,x_msg_data               OUT NOCOPY VARCHAR2)
IS
  l_org_tbl                  FND_TABLE_OF_VARCHAR2_255;
  l_eco_output_tbl           inv_ebi_change_id_obj_tbl;
  l_counter                  NUMBER:=0;
  l_org_code                   VARCHAR2(10);
BEGIN
  x_return_status := FND_API.g_ret_sts_success;
  INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.filter_ecos_based_on_org');
  INV_EBI_UTIL.debug_line('STEP 20: ORG CODES'||p_org_codes);
  l_eco_output_tbl       := inv_ebi_change_id_obj_tbl();

  IF p_org_codes IS NOT NULL THEN
    l_org_tbl := INV_EBI_ITEM_HELPER.parse_input_string(p_org_codes);
  END IF;

  IF p_eco_tbl IS NOT NULL AND p_eco_tbl.COUNT>0 THEN
    FOR i in p_eco_tbl.FIRST..p_eco_tbl.LAST LOOP
      l_org_code := NULL;
      SELECT mp.organization_code INTO l_org_code
      FROM eng_engineering_changes ec, mtl_parameters mp
      WHERE ec.change_id = p_eco_tbl(i).change_id
      AND   ec.organization_id = mp.organization_id;
      IF l_org_tbl IS NOT NULL AND l_org_tbl.COUNT>0 THEN
        FOR j in l_org_tbl.FIRST..l_org_tbl.LAST LOOP
          IF (l_org_code = l_org_tbl(j)) THEN
            l_counter := l_counter + 1;
            l_eco_output_tbl.EXTEND(1);
            l_eco_output_tbl(l_counter) := p_eco_tbl(i);
            EXIT;
          END IF;
        END LOOP;
      END IF;
    END LOOP;
  END IF;

  x_eco_tbl := l_eco_output_tbl;
  IF (x_eco_tbl.count > 0 ) THEN
    FOR i IN 1 .. x_eco_tbl.count
    LOOP
      INV_EBI_UTIL.debug_line('STEP 30: CHANGE ID NUMBER IS '|| x_eco_tbl(i).change_id);
      INV_EBI_UTIL.debug_line('STEP 40: LAST UPDATE STATUS '|| x_eco_tbl(i).last_update_status);
    END LOOP;
  END IF;
  INV_EBI_UTIL.debug_line('STEP 50: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.filter_ecos_based_on_org STATUS: '|| x_return_status);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    x_msg_data := SQLERRM ||' at INV_EBI_ITEM_HELPER.filter_ecos_based_on_org';
END filter_ecos_based_on_org;

/***************************************************************************************************
--      API name        : parse_and_get_eco
--      Type            : Private For Internal Use Only
--      Purpose         : To parse the input string and get lis of eco
*****************************************************************************************************/
PROCEDURE parse_and_get_eco(
  p_eco_names               IN        VARCHAR2
 ,p_org_codes               IN        VARCHAR2
 ,x_eco_tbl                OUT NOCOPY inv_ebi_change_id_obj_tbl
 ,x_return_status          OUT NOCOPY VARCHAR2
 ,x_msg_count              OUT NOCOPY NUMBER
 ,x_msg_data               OUT NOCOPY VARCHAR2)
IS
  l_return_status            VARCHAR2(2);
  l_msg_data                 VARCHAR2(2000);
  l_chg_id                   NUMBER;
  l_org_id                   NUMBER;
  l_count                    NUMBER:=0;
  l_counter                  NUMBER := 0;
  l_entity_exist             NUMBER :=0;
  l_entity_count             NUMBER :=0;
  l_eco_obj                  inv_ebi_change_id_obj;
  l_eco_output_tbl           inv_ebi_change_id_obj_tbl;
  l_eco_tbl                  FND_TABLE_OF_VARCHAR2_255;
  l_org_tbl                  FND_TABLE_OF_VARCHAR2_255;
  l_valid_eco_tbl            FND_TABLE_OF_VARCHAR2_255;
  l_valid_org_tbl            FND_TABLE_OF_VARCHAR2_255;
  l_pk_col_name_val_pairs    INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl ;
  CURSOR c_get_all_orgs( p_chg_notice VARCHAR2) IS
      SELECT change_id
      FROM eng_engineering_changes
    WHERE change_notice = p_chg_notice;
BEGIN
  x_return_status := FND_API.g_ret_sts_success;
  INV_EBI_UTIL.debug_line('STEP 10: START INSIDE INV_EBI_CHANGE_ORDER_HELPER.parse_and_get_eco');
  INV_EBI_UTIL.debug_line('STEP 20: CHANGE ORDER NAMES '|| p_eco_names);
  INV_EBI_UTIL.debug_line('STEP 30: ORG CODE NAMES '|| p_org_codes);
  l_eco_output_tbl :=inv_ebi_change_id_obj_tbl();

  IF p_eco_names IS NOT NULL THEN
    l_eco_tbl := INV_EBI_ITEM_HELPER.parse_input_string(p_eco_names);
  END IF;

  IF p_org_codes IS NOT NULL THEN
    l_org_tbl := INV_EBI_ITEM_HELPER.parse_input_string(p_org_codes);
  END IF;

  IF l_eco_tbl IS NOT NULL AND l_eco_tbl.COUNT > 0 THEN
    l_valid_eco_tbl := FND_TABLE_OF_VARCHAR2_255();
    l_entity_count :=0;
    FOR i in l_eco_tbl.FIRST..l_eco_tbl.LAST LOOP
      BEGIN
        FND_MSG_PUB.initialize();
         SELECT COUNT(1) into l_entity_exist
         FROM eng_engineering_changes
         WHERE change_notice = l_eco_tbl(i);
         IF l_entity_exist>0 THEN
           l_entity_count := l_entity_count +1;
           l_valid_eco_tbl.EXTEND();
           l_valid_eco_tbl(l_entity_count) := l_eco_tbl(i);
        ELSE
          FND_MESSAGE.set_name('INV','INV_EBI_ITEM_INVALID');
          FND_MESSAGE.set_token('COL_VALUE', l_eco_tbl(i));
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.g_ret_sts_error;
          FND_MSG_PUB.count_and_get( p_encoded => FND_API.g_false
                                     ,p_count   => x_msg_count
                                     ,p_data    => l_msg_data
                                   );
          x_msg_data :=  x_msg_data || l_msg_data ||' , ' ;
        WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_error;
          x_msg_data := SQLERRM ||' at INV_EBI_CHANGE_ORDER_HELPER.parse_and_get_eco';
      END;
    END LOOP;
  END IF;

  IF l_org_tbl IS NOT NULL AND l_org_tbl.COUNT > 0 THEN
    l_valid_org_tbl := FND_TABLE_OF_VARCHAR2_255();
    l_entity_count :=0;
    FOR i in l_org_tbl.FIRST..l_org_tbl.LAST LOOP
      BEGIN
        FND_MSG_PUB.initialize();
        SELECT COUNT(1) into l_entity_exist
          FROM mtl_parameters
        WHERE organization_code = l_org_tbl(i);
        IF l_entity_exist>0 THEN
          l_entity_count := l_entity_count +1;
          l_valid_org_tbl.EXTEND();
          l_valid_org_tbl(l_entity_count) := l_org_tbl(i);
        ELSE
          FND_MESSAGE.set_name('INV','INV_EBI_ORG_CODE_INVALID');
          FND_MESSAGE.set_token('COL_VALUE', l_org_tbl(i));
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.g_ret_sts_error;
          FND_MSG_PUB.count_and_get( p_encoded => FND_API.g_false
                                     ,p_count   => x_msg_count
                                     ,p_data    => l_msg_data
                                   );
          x_msg_data :=  x_msg_data || l_msg_data ||' , ' ;
        WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_error;
          x_msg_data := SQLERRM ||' at INV_EBI_CHANGE_ORDER_HELPER.parse_and_get_eco';
      END;
    END LOOP;
  END IF;

  IF l_valid_eco_tbl IS NOT NULL AND l_valid_eco_tbl.COUNT > 0 THEN
    FOR i in l_valid_eco_tbl.FIRST..l_valid_eco_tbl.LAST LOOP
      BEGIN
        FND_MSG_PUB.initialize();
        l_count :=0;
        IF l_valid_org_tbl IS NOT NULL AND l_valid_org_tbl.COUNT > 0 THEN
          FOR j in l_valid_org_tbl.FIRST..l_valid_org_tbl.LAST LOOP
            l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
            l_pk_col_name_val_pairs.EXTEND();
            l_pk_col_name_val_pairs(1).name  := 'organization_code';
            l_pk_col_name_val_pairs(1).value := l_valid_org_tbl(j);
            l_org_id                         := INV_EBI_ITEM_HELPER.value_to_id( p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                                                 ,p_entity_name            => INV_EBI_ITEM_HELPER.G_ORGANIZATION
                                                                               );
            l_pk_col_name_val_pairs.TRIM(1);

            l_chg_id := NULL;
            BEGIN
              SELECT change_id
              INTO l_chg_id
              FROM eng_engineering_changes
              WHERE change_notice   = l_valid_eco_tbl(i)
              AND   organization_id = l_org_id;
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;

            IF l_chg_id IS NOT NULL THEN
              l_counter := l_counter + 1;
              l_eco_obj  :=  inv_ebi_change_id_obj( l_chg_id, 'Y');
              l_eco_output_tbl.EXTEND(1);
              l_eco_output_tbl(l_counter) := l_eco_obj;
              l_count := 1;
            END IF;

          END LOOP;
        ELSE
          FOR cur IN c_get_all_orgs(l_valid_eco_tbl(i)) LOOP
            l_counter := l_counter + 1;
            l_eco_obj  :=  inv_ebi_change_id_obj( cur.change_id, 'Y');
            l_eco_output_tbl.EXTEND(1);
            l_eco_output_tbl(l_counter) := l_eco_obj;
            l_count := 1;
          END LOOP;
        END IF;

        IF l_count = 0 THEN
          FND_MESSAGE.set_name('INV','INV_EBI_INVALID_USER_INPUT');
          FND_MESSAGE.set_token('USER_INPUT', l_valid_eco_tbl(i));
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.g_ret_sts_error;
          FND_MSG_PUB.count_and_get( p_encoded => FND_API.g_false
                                  ,p_count   => x_msg_count
                                  ,p_data    => l_msg_data
                                 );
          x_msg_data := x_msg_data || l_msg_data  ;
        WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_unexp_error;
          x_msg_data := SQLERRM ||' at INV_EBI_CHANGE_ORDER_HELPER.parse_and_get_eco';
      END;
    END LOOP;
  END IF;
  x_eco_tbl := l_eco_output_tbl;
  IF (x_eco_tbl.count > 0) THEN
    FOR i IN 1 .. x_eco_tbl.count
    LOOP
      INV_EBI_UTIL.debug_line('STEP 40: CHANGE ID NUMBER  '|| x_eco_tbl(i).CHANGE_ID);
      INV_EBI_UTIL.debug_line('STEP 50: LAST UPDATE STATUS '|| x_eco_tbl(i).LAST_UPDATE_STATUS);
    END LOOP;
  END IF;
  INV_EBI_UTIL.debug_line('STEP 60: END INSIDE INV_EBI_CHANGE_ORDER_HELPER.parse_and_get_eco STATUS: '|| x_return_status);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    x_msg_data := SQLERRM ||' at INV_EBI_CHANGE_ORDER_HELPER.parse_and_get_eco';
END parse_and_get_eco;

/************************************************************************************
--      API name        : get_eco_list
--      Type            : Public
--      Function        :
--      Comments       : This API to return list of change ids, prepatel
************************************************************************************/
PROCEDURE get_eco_list(
  p_name_value_list         IN             inv_ebi_name_value_tbl
 ,p_prog_id                 IN             NUMBER
 ,p_appl_id                 IN             NUMBER
 ,x_eco                    OUT NOCOPY      inv_ebi_change_id_obj_tbl
 ,x_return_status          OUT NOCOPY      VARCHAR2
 ,x_msg_count              OUT NOCOPY      NUMBER
 ,x_msg_data               OUT NOCOPY      VARCHAR2
)
IS
  l_eco                      inv_ebi_change_id_obj_tbl;
  l_eco_output_tbl           inv_ebi_change_id_obj_tbl;
  l_eco_org_output_tbl       inv_ebi_change_id_obj_tbl;
  l_eco_tbl                  inv_ebi_change_id_obj_tbl;
  l_eco_string               VARCHAR2(32000);
  l_org_string               VARCHAR2(2000);
  l_from_date_str            VARCHAR2(30);
  l_to_date_str              VARCHAR2(30);
  l_from_date                DATE := NULL;
  l_to_date                  DATE := NULL;
  l_last_x_hrs               NUMBER;
  l_return_status            VARCHAR2(2);
  l_msg_data                 VARCHAR2(2000);
  l_msg_count                NUMBER;

  CURSOR c_get_eco_chgid IS
    SELECT inv_ebi_change_id_obj(eci.change_id, 'Y')
    FROM(
         SELECT eec.change_id
         FROM eng_engineering_changes eec
         WHERE  eec.last_update_date <> eec.creation_date
         AND    eec.last_update_date >= l_from_date
         AND    eec.last_update_date <= l_to_date
         UNION
         SELECT eri.change_id
         FROM eng_revised_items eri
         WHERE eri.last_update_date <> eri.creation_date
         AND    eri.last_update_date >= l_from_date
         AND    eri.last_update_date <= l_to_date ) eci;

  CURSOR c_get_final_eco_list  IS
    SELECT inv_ebi_change_id_obj(geco.change_id,geco.last_update_status)
    FROM (SELECT b.change_id,b.last_update_status
          FROM THE (SELECT CAST( l_eco as inv_ebi_change_id_obj_tbl)
                     FROM dual ) b
          INTERSECT
          SELECT c.change_id,c.last_update_status
          FROM THE (SELECT CAST( l_eco_output_tbl as inv_ebi_change_id_obj_tbl)
                     FROM dual ) c  ) geco;
  l_ind_val NUMBER :=1;
BEGIN
  FND_MSG_PUB.initialize();
  INV_EBI_UTIL.setup();
  INV_EBI_UTIL.debug_line('Step 10: START CALLING INV_EBI_CHANGE_ORDER_HELPER.GET_ECO_LIST');
  x_return_status         := FND_API.G_RET_STS_SUCCESS;

  IF (p_name_value_list IS NOT NULL AND  p_name_value_list.COUNT > 0) THEN
    l_eco_string    := INV_EBI_UTIL.get_config_param_value(p_name_value_list,'Change Order Name');
    l_org_string    := INV_EBI_UTIL.get_config_param_value(p_name_value_list,'Organization Code');
    l_from_date_str := INV_EBI_UTIL.get_config_param_value(p_name_value_list,'From Date');
    l_to_date_str   := INV_EBI_UTIL.get_config_param_value(p_name_value_list,'To Date');
    l_last_x_hrs    := INV_EBI_UTIL.get_config_param_value(p_name_value_list,'Updated in the last X Hrs');

    INV_EBI_UTIL.debug_line('STEP 20: INPUT PARAMETER FOR ECO IS ' || l_eco_string);
    INV_EBI_UTIL.debug_line('STEP 30: INPUT PARAMETER FOR ORG IS ' || l_org_string);
    INV_EBI_UTIL.debug_line('STEP 40: INPUT PARAMETER FOR FROM DATE IS ' || l_from_date_str);
    INV_EBI_UTIL.debug_line('STEP 50: INPUT PARAMETER FOR TO DATE IS  ' || l_to_date_str);
    INV_EBI_UTIL.debug_line('STEP 60: INPUT PARAMETER FOR LAST UPDATED HRS IS '|| l_last_x_hrs);

    IF l_from_date_str IS NOT NULL THEN
      l_from_date   := TO_DATE(l_from_date_str,'YYYY/MM/DD HH24:MI:SS');
      INV_EBI_UTIL.debug_line('STEP 70: FROM DATE CONVERSION IF IT IS NOT NULL ' || l_from_date);
    END IF;
    IF l_to_date_str IS NOT NULL THEN
      l_to_date     := TO_DATE(l_to_date_str,'YYYY/MM/DD HH24:MI:SS');
      INV_EBI_UTIL.debug_line('STEP 80: TO DATE CONVERSION IF IT IS NOT NULL ' || l_to_date);
    END IF;
    IF l_last_x_hrs IS NOT NULL THEN
      l_from_date   := SYSDATE-( l_last_x_hrs/24);
      l_to_date     := SYSDATE ;
      INV_EBI_UTIL.debug_line('STEP 90: FROM DATE IF THE LAST X HRS PARAMATER IS GIVEN ' || l_from_date);
      INV_EBI_UTIL.debug_line('STEP 100: TO DATE IF THE LAST X HRS PARAMATER IS GIVEN ' || l_to_date);
    END IF;
  END IF;

  IF (l_eco_string IS NULL AND l_from_date IS NULL AND l_to_date IS NULL AND l_last_x_hrs IS NULL) THEN
    l_from_date :=INV_EBI_ITEM_HELPER.get_last_run_date( p_conc_prog_id => p_prog_id
                                                        ,p_appl_id      => p_appl_id
                                                        );
    INV_EBI_UTIL.debug_line('STEP 110: FROM DATE IF ALL THE PARAMETERS ARE NULL'|| l_from_date);
    l_to_date := SYSDATE;
    INV_EBI_UTIL.debug_line('STEP 120: TO DATE IF ALL THE PARAMETERS ARE NULL '|| l_to_date);
  END IF;

  IF l_from_date IS NOT NULL AND l_to_date IS NULL THEN
    l_to_date := SYSDATE;
    INV_EBI_UTIL.debug_line('STEP 130: TO DATE IF FROM DATE IS NOT NULL AND TODATE IS NULL '|| l_to_date);
  END IF;
  INV_EBI_UTIL.debug_line('STEP 140: BEFORE CALLING PARSE_AND_GET_ECO');
  IF ( l_eco_string IS NOT NULL  ) THEN
    parse_and_get_eco(  p_eco_names         => l_eco_string
                        ,p_org_codes        => l_org_string
                        ,x_eco_tbl          => l_eco_output_tbl
                        ,x_return_status    => l_return_status
                        ,x_msg_count        => l_msg_count
                        ,x_msg_data         => l_msg_data);
  END IF;
  INV_EBI_UTIL.debug_line('STEP 150: AFTER CALLING PARSE_AND_GET_ECO STATUS: '|| x_return_status);
  IF (l_return_status  <> FND_API.g_ret_sts_success) THEN
    x_return_status := l_return_status;
    IF  l_msg_data IS NOT NULL THEN
      x_msg_data := l_msg_data;
    END IF;
  END IF;

  x_eco := l_eco_output_tbl;
  l_eco := inv_ebi_change_id_obj_tbl();

  IF (l_from_date IS NOT NULL AND l_to_date IS NOT NULL) THEN
    IF (c_get_eco_chgid%ISOPEN) THEN
      CLOSE c_get_eco_chgid;
    END IF;
    OPEN c_get_eco_chgid ;
    FETCH c_get_eco_chgid  BULK COLLECT INTO l_eco ;
    CLOSE c_get_eco_chgid;
    IF (l_eco.COUNT > 0) THEN
      FOR i IN 1 .. l_eco.COUNT
      LOOP
        INV_EBI_UTIL.debug_line('STEP 160: CHANGE ID IF FROM DATE AND TO DATE PARAMETER IS NOT NULL '|| l_eco(i).CHANGE_ID);
      END LOOP;
    END IF;
    IF( l_eco_string IS NOT NULL  ) THEN
      IF(c_get_final_eco_list%ISOPEN) THEN
        CLOSE c_get_final_eco_list;
      END IF;
      OPEN c_get_final_eco_list ;
      FETCH c_get_final_eco_list  BULK COLLECT INTO l_eco_tbl ;
      CLOSE c_get_final_eco_list;
      x_eco:=l_eco_tbl;
    ELSIF (l_org_string IS NOT NULL) THEN
      INV_EBI_UTIL.debug_line('STEP 170: BEFORE CALLING FILTER ECOS BASED ON ORG');
      filter_ecos_based_on_org( p_org_codes            => l_org_string
                                ,p_eco_tbl              => l_eco
                                ,x_eco_tbl              => l_eco_org_output_tbl
                                ,x_return_status        => l_return_status
                                ,x_msg_count            => l_msg_count
                                ,x_msg_data             => l_msg_data);
      INV_EBI_UTIL.debug_line('STEP 180: AFTER CALLING FILTER ECOS BASED ON ORG STATUS: '|| x_return_status);
      IF (l_return_status  = FND_API.g_ret_sts_success) THEN
        x_eco := l_eco_org_output_tbl;
      ELSE
        x_return_status := l_return_status;
        IF  x_msg_data IS NOT NULL THEN
          x_msg_data := x_msg_data || l_msg_data;
        ELSE
          x_msg_data := l_msg_data;
        END IF;
      END IF;
    ELSE
      x_eco:=l_eco;
    END IF;
  END IF;
  IF (x_eco.COUNT >0 ) THEN
    FOR i IN 1 .. x_eco.COUNT
    LOOP
      INV_EBI_UTIL.debug_line('STEP 190: CHANGE ID  '|| x_eco(i).CHANGE_ID || ' LAST UPDATE STATUS ' ||x_eco(i).LAST_UPDATE_STATUS);
    END LOOP;
  END IF;
  INV_EBI_UTIL.debug_line('STEP 200: END CALLING INV_EBI_CHANGE_ORDER_HELPER.get_eco_list STATUS: '||x_return_status);
  INV_EBI_UTIL.wrapup;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    x_msg_data := SQLERRM ||' at INV_EBI_CHANGE_ORDER_HELPER.get_eco_list';
    IF (c_get_final_eco_list%ISOPEN) THEN
      CLOSE c_get_final_eco_list;
    END IF;

END get_eco_list;

END INV_EBI_CHANGE_ORDER_HELPER;

/

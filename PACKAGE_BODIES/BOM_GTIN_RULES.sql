--------------------------------------------------------
--  DDL for Package Body BOM_GTIN_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_GTIN_RULES" AS
/* $Header: BOMLGTNB.pls 120.11.12010000.3 2009/11/02 13:26:15 yjain ship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLGTNB.pls
--
--  DESCRIPTION
--
--      Package body: BOM Validations for GTIN
--
--  NOTES
--
--  HISTORY
--
--  18-MAY-04   Refai Farook    Initial Creation
--
--
****************************************************************************/

  FUNCTION Get_Message
  (   p_application_short_name      IN VARCHAR2 := NULL
    , p_message_name              IN VARCHAR2 := NULL
    , p_message_text              IN VARCHAR2 := NULL
    , p_api_name                  IN VARCHAR2 := NULL
  ) RETURN VARCHAR2 IS

  BEGIN

    IF p_message_text IS NULL THEN
      FND_MESSAGE.Set_Name (p_application_short_name, p_message_name);
      --FND_MSG_PUB.Add;
    ELSE
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg
        (  p_pkg_name         =>  'BOM_GTIN_Rules'
        ,  p_procedure_name   =>  p_api_name
        ,  p_error_text       =>  p_message_text
        );
      END IF;
    END IF;

    Return FND_MESSAGE.Get;

  END;

  FUNCTION Pack_Check(p_item_id IN NUMBER,p_org_id IN NUMBER)
  RETURN VARCHAR2 IS

   CURSOR Pack_Exist IS
   SELECT bill_sequence_id
   FROM bom_structures_b
   WHERE assembly_item_id = p_item_id
   AND organization_id = p_org_id
   AND alternate_bom_designator = 'PIM_PBOM_S';

   CURSOR Pack_Comp_Exist(l_bill_seq_id IN NUMBER) IS
   SELECT 'Exist'
   FROM bom_components_b
   WHERE bill_sequence_id = l_bill_seq_id
   AND (disable_date IS NULL OR disable_date > sysdate);

   TYPE var_type IS TABLE OF VARCHAR2(20);
   l_temp NUMBER;
   l_exist VARCHAR2(5) := 'Y';
   l_comp_exist var_type;

   BEGIN

   OPEN Pack_Exist;
   FETCH Pack_Exist INTO l_temp;
   IF l_temp IS NULL THEN
    l_exist := 'N';
   ELSE
    OPEN Pack_Comp_Exist(l_temp);
    FETCH Pack_Comp_Exist BULK COLLECT INTO l_comp_exist;
    IF l_comp_exist.COUNT = 0 THEN
      l_exist := 'N';
    END IF;
    CLOSE Pack_Comp_Exist;
   END IF;
   CLOSE Pack_Exist;

  RETURN l_exist;

  END;

  /* Overloaded method with out ignore published status flag
   * This will be the procedure called by all routines except for the rollup
   * and will invoke the overloaded method with p_ignore_published as 'N'
   */

  PROCEDURE Check_GTIN_Attributes ( p_bill_sequence_id IN NUMBER := NULL,
                                    p_assembly_item_id NUMBER,
                                    p_organization_id IN NUMBER,
                                    p_alternate_bom_code IN VARCHAR2 := NULL,
                                    p_component_item_id IN NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_error_message  OUT NOCOPY VARCHAR2) IS
  BEGIN
    Check_GTIN_Attributes (   p_bill_sequence_id => p_bill_sequence_id
                            , p_assembly_item_id => p_assembly_item_id
                            , p_organization_id => p_organization_id
                            , p_alternate_bom_code => p_alternate_bom_code
                            , p_component_item_id => p_component_item_id
                            , p_ignore_published => 'N'
                            , x_return_status => x_return_status
                            , x_error_message  => x_error_message );
  END Check_GTIN_Attributes;


  /* Overloaded method with ignore published status flag
   * this will be called by the rollup with 'Y' as the p_ignore_published flag
   * other calls will be routed through the overloaded procedure w.o.
   * this flag, and will be passed as 'N'
   */

  PROCEDURE Check_GTIN_Attributes ( p_bill_sequence_id IN NUMBER := NULL,
                                    p_assembly_item_id NUMBER,
                                    p_organization_id IN NUMBER,
                                    p_alternate_bom_code IN VARCHAR2 := NULL,
                                    p_component_item_id IN NUMBER,
                                    p_ignore_published IN VARCHAR2,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_error_message  OUT NOCOPY VARCHAR2) IS

    l_parent_tid VARCHAR2(35);
    l_publication_status VARCHAR2(1);
    l_top_gtin VARCHAR2(15);
    l_parent_gtin VARCHAR2(25);
    l_parent_uom_code VARCHAR2(3);
    l_child_uom_code VARCHAR2(3);

    l_component_tid VARCHAR2(35);
    l_component_gtin VARCHAR2(25);

    l_bill_sequence_id NUMBER;
    l_compatible VARCHAR2(1);

    CURSOR c_gtin_count(p_bill_sequence_id IN NUMBER) IS
     SELECT count(DISTINCT egi.trade_item_descriptor) distinct_trade_count, count(DISTINCT egi.gtin) gtin_count,
     count(egi.trade_item_descriptor) total_trade_count
     FROM bom_components_b bic, ego_items_v egi
     WHERE  bic.bill_sequence_id =  p_bill_sequence_id AND
        bic.pk1_value = egi.inventory_item_id  AND
        bic.pk2_value = egi.organization_id  AND
        bic.effectivity_date <= SYSDATE AND
        nvl(bic.disable_date, SYSDATE+1) > SYSDATE AND
        egi.trade_item_descriptor IS NOT NULL AND
/* Code added for bug 7435503*/
	bic.IMPLEMENTATION_DATE IS NOT null;
/* Code added for bug 7435503*/
        --egi.gtin IS NOT NULL AND egi.cross_reference_type = 'GTIN';

  BEGIN

    x_return_status := 'S';

    IF p_assembly_item_id IS NULL OR p_organization_id IS NULL OR p_component_item_id IS NULL
    THEN
      x_return_status := 'E';
      x_error_message := 'Parameter error';
      Return;
    END IF;


    /* Get the parent gtin, parent tid, published status, top_gtin flag value for the parent */

    SELECT gtin,trade_item_descriptor,publication_status, top_gtin, primary_uom_code
      INTO l_parent_gtin, l_parent_tid, l_publication_status, l_top_gtin, l_parent_uom_code
      FROM ego_items_v
      WHERE inventory_item_id = p_assembly_item_id AND
            organization_id = p_organization_id;

    /* Get the componet gtin, component tid value for the component */

    SELECT gtin, trade_item_descriptor, primary_uom_code
      INTO l_component_gtin, l_component_tid, l_child_uom_code
      FROM ego_items_v
      WHERE inventory_item_id = p_component_item_id AND
            organization_id = p_organization_id;


    /* Published GTINs cannot allow any changes on the GTIN
       Once published the publication status will have some value other than null */

    IF l_publication_status IS NOT NULL
    THEN
      IF l_component_gtin IS NOT NULL
      THEN
        IF (p_ignore_published is null OR p_ignore_published = 'N') THEN
          x_return_status := 'E';
          x_error_message := Get_Message('BOM','BOM_GTIN_BOM_PUBLISHED');
          Return;
        END IF;
      END IF;
    END IF;

    /* Apply the validation rules */

    /* Parent and child must belong to the same UOM class */

/* commented our bug 5639158 */
/*      GET_UOM_CLASS_COMPATIBILITY(p_src_uom_code => l_parent_uom_code,
                                p_dest_uom_code => l_child_uom_code,
                                x_compatibility_status => l_compatible);
      IF l_compatible = 'N'
      THEN
        x_return_status := 'E';
        x_error_message := Get_Message('BOM','BOM_UOM_CLASS_DIFF');
      END IF;
*/

    /* Get the parent bill seq */
    IF p_bill_sequence_id IS NULL
    THEN
      IF (p_alternate_bom_code is NULL)
      THEN
        SELECT
          bill_sequence_id INTO l_bill_sequence_id
        FROM
          bom_structures_b bsb, bom_structure_types_b bstb
        WHERE
            assembly_item_id = p_assembly_item_id
          AND organization_id = p_organization_id
          AND bsb.structure_type_id = bstb.structure_type_id
          AND bstb.structure_type_name = 'Packaging Hierarchy'
          AND bsb.is_preferred = 'Y';
      ELSE
          SELECT bill_sequence_id INTO l_bill_sequence_id FROM bom_structures_b WHERE
            assembly_item_id = p_assembly_item_id AND
            organization_id = p_organization_id AND
            alternate_bom_designator = p_alternate_bom_code ;
      END IF;
    ELSE
      l_bill_sequence_id := p_bill_sequence_id;
    END IF;


    /* Check for trade item unit descriptor compatibility between parent and child*/

    /* Feb 03, 2006: Implemented the validation rules as per UCCNET 3.0*/

    IF (l_parent_tid IS NULL OR l_component_tid IS NULL)
    THEN
      null;
    ELSIF l_parent_tid IN ('MIXED_MODULE','PALLET')
    THEN
      IF l_component_tid NOT IN ('DISPLAY_SHIPPER','CASE','PACK_OR_INNER_PACK','BASE_UNIT_OR_EACH','SETPACK','MULTIPACK')
      THEN
        x_return_status := 'E';
        x_error_message := Get_Message('BOM','BOM_GTIN_PL_CONFIG_INVALID');
      END IF;
    ELSIF l_parent_tid IN ('DISPLAY_SHIPPER')
    THEN
      IF l_component_tid NOT IN ('CASE','BASE_UNIT_OR_EACH','SETPACK','MULTIPACK')
      THEN
        x_return_status := 'E';
        x_error_message := Get_Message('BOM','BOM_GTIN_DS_CONFIG_INVALID');
      END IF;
    ELSIF l_parent_tid IN ('CASE')
    THEN  --Bug 8279011 , Added support for 'DISPLAY_SHIPPER'and 'CASE' Also.
      IF l_component_tid NOT IN ('BASE_UNIT_OR_EACH','PACK_OR_INNER_PACK','SETPACK','MULTIPACK','DISPLAY_SHIPPER','CASE')
      THEN
        x_return_status := 'E';
        x_error_message := Get_Message('BOM','BOM_GTIN_CA_CONFIG_INVALID');
      END IF;
    ELSIF l_parent_tid IN ('PACK_OR_INNER_PACK')
    THEN
      IF l_component_tid NOT IN ('BASE_UNIT_OR_EACH','SETPACK','PACK_OR_INNER_PACK')  --Bug 8279011 , Added support for 'PACK_OR_INNER_PACK' Also.
      THEN
        x_return_status := 'E';
        x_error_message := Get_Message('BOM','BOM_GTIN_PK_CONFIG_INVALID');
      END IF;

    ELSIF l_parent_tid IN ('PREPACK_ASSORTMENT')
    THEN
      IF l_component_tid NOT IN ('PREPACK','SETPACK','MULTIPACK')
      THEN
        x_return_status := 'E';
        x_error_message := Get_Message('BOM','BOM_GTIN_PPKA_CONFIG_INVALID');
      END IF;
    ELSIF l_parent_tid IN ('PREPACK')
    THEN
      IF l_component_tid NOT IN ('BASE_UNIT_OR_EACH')
      THEN
        x_return_status := 'E';
        x_error_message := Get_Message('BOM','BOM_GTIN_PPK_CONFIG_INVALID');
      END IF;
    ELSIF l_parent_tid IN ('SETPACK')
    THEN
      IF l_component_tid NOT IN ('BASE_UNIT_OR_EACH')
      THEN
        x_return_status := 'E';
        x_error_message := Get_Message('BOM','BOM_GTIN_SPK_CONFIG_INVALID');
      END IF;
    ELSIF l_parent_tid IN ('MULTIPACK')
    THEN
      IF l_component_tid NOT IN ('PACK_OR_INNER_PACK','BASE_UNIT_OR_EACH')
      THEN
        x_return_status := 'E';
        x_error_message := Get_Message('BOM','BOM_GTIN_MPK_CONFIG_INVALID');
      END IF;
    END IF;

    IF x_return_status = 'E'
    THEN
      Return;
    END IF;

    /* Check for validity of multiple childrens */

    IF (l_parent_tid IS NULL OR l_component_tid IS NULL)
    THEN
      null;
    ELSIF l_parent_tid IN ('PALLET','CASE', 'PACK_OR_INNER_PACK')
    THEN
      /* PALLET: A pallet can have only one type of children instance.
         It all could be DS or CA or PK or EA but not a mixture of these.
         CASE: A case cannot have multiple gtins.
         PACK_OR_INNER_PACK: Cannot have multiple gtins
      */

      FOR r1 IN c_gtin_count (l_bill_sequence_id)
      LOOP
        IF r1.total_trade_count > 1
        THEN
          x_return_status := 'E';
          IF l_parent_tid = 'CASE'
          THEN
            x_error_message := Get_Message('BOM','BOM_GTIN_CA_MULTI_GTINS');
          ELSIF l_parent_tid = 'PALLET'
          THEN
            x_error_message := Get_Message('BOM','BOM_GTIN_PL_MULTI_GTINS');
          --bug:  4516894
          ELSIF l_parent_tid = 'PACK_OR_INNER_PACK'
          THEN
            x_error_message := Get_Message('BOM','BOM_GTIN_PK_MULTI_GTINS');
          END IF;
        END IF;
        /*
        IF r1.distinct_trade_count > 1 AND l_parent_tid = 'PALLET'
        THEN
          x_return_status := 'E';
          x_error_message := Get_Message('BOM','BOM_GTIN_PL_MULTI_TRADES');
        ELSIF r1.total_trade_count > 1 AND l_parent_tid = 'CASE'
        --ELSIF r1.gtin_count > 1 AND l_parent_tid = 'CASE'
        THEN
          x_return_status := 'E';
          x_error_message := Get_Message('BOM','BOM_GTIN_CA_MULTI_GTINS');
        END IF;
        */
      END LOOP;
    ELSIF nvl(l_parent_tid,'-1') = 'BASE_UNIT_OR_EACH'
    THEN
      /* Each cannot have a BOM */
      x_return_status := 'E';
      x_error_message := Get_Message('BOM','BOM_GTIN_EACH_NO_BOM');
    END IF;

  END;

  PROCEDURE Update_Top_GTIN( p_organization_id IN NUMBER,
                             p_component_item_id IN NUMBER,
                             p_parent_item_id in NUMBER := NULL,
                             p_structure_name in VARCHAR2 := NULL) IS
    is_preferred_flag BOOLEAN := FALSE;
    CURSOR c_Preferred_Structure(p_assembly_item_id in varchar2,
                                 p_organization_id in varchar2,
                                 p_structure_name in varchar2)
    IS
    SELECT
      alternate_bom_designator
    FROM
      bom_structures_b
    WHERE
          assembly_item_id = p_assembly_item_id
      AND organization_id = p_organization_id
      AND alternate_bom_designator = p_structure_name
      AND is_Preferred = 'Y';

  BEGIN

    IF ( p_structure_name IS NOT NULL) THEN
      for c1 in c_Preferred_Structure(p_assembly_item_id => p_parent_item_id,
                                   p_organization_id => p_organization_id,
                                   p_structure_name => p_structure_name)
      LOOP
        is_preferred_flag := TRUE;
      END LOOP;
    END IF;
      IF (is_preferred_flag) THEN
        UPDATE EGO_ITEM_GTN_ATTRS_B
        SET top_gtin = null
        WHERE inventory_item_id = p_component_item_id AND
              organization_id = p_organization_id;
      END IF;
  END;

  /* Returns the uom conversion rate
     Returns -99999 when any error occurs */

  FUNCTION Get_Suggested_Quantity ( p_component_item_id IN NUMBER,
                                    p_component_uom  IN VARCHAR2,
                                    p_assembly_uom  IN VARCHAR2) RETURN NUMBER IS

    l_uom_rate  NUMBER;

  BEGIN

    l_uom_rate := INV_CONVERT.Inv_Um_Convert (p_component_item_id,
                                             null, null,
                                             p_assembly_uom,
                                             p_component_uom,
                                             null, null);
    IF l_uom_rate = -99999
    THEN
      Return 0;
    ELSE
      Return l_uom_rate;
    END IF;

  END;

  /*
  FUNCTION Get_Suggested_Quantity ( p_component_item_id   IN NUMBER,
                                    p_component_uom_name  IN VARCHAR2,
                                    p_assembly_uom_name   IN VARCHAR2) RETURN NUMBER IS
  BEGIN

    Return INV_CONVERT.Inv_Um_Convert (p_component_item_id,
                                       null, null,
                                       null, null,
                                       p_component_uom_name,
                                       p_assembly_uom_name);
  END;
  */

  FUNCTION Get_Suggested_Quantity ( p_organization_id IN NUMBER,
                                    p_assembly_item_id NUMBER,
                                    p_component_item_id IN NUMBER ) RETURN NUMBER IS
    l_component_uom VARCHAR2(3);
    l_assembly_uom  VARCHAR2(3);
    l_uom_rate  NUMBER;

  BEGIN

    SELECT primary_uom_code INTO l_component_uom FROM mtl_system_items_b WHERE
      inventory_item_id = p_component_item_id AND
      organization_id = p_organization_id;

    SELECT primary_uom_code INTO l_assembly_uom FROM mtl_system_items_b WHERE
      inventory_item_id = p_assembly_item_id AND
      organization_id = p_organization_id;

    l_uom_rate := INV_CONVERT.Inv_Um_Convert (p_component_item_id,
                                             null, null,
                                             l_assembly_uom,
                                             l_component_uom,
                                             null, null);
    IF l_uom_rate = -99999
    THEN
      Return 0;
    ELSE
      Return l_uom_rate;
    END IF;

    EXCEPTION WHEN OTHERS THEN
      Return 0;

  END;

  PROCEDURE Perform_Rollup
        (  p_item_id            IN  NUMBER
         , p_organization_id    IN  NUMBER
         , p_parent_item_id     IN  NUMBER
         , p_structure_type_name  IN  VARCHAR2
         , p_transaction_type   IN  VARCHAR2
         , p_validate           IN  VARCHAR2 /*DEFAULT 'N'*/
         , p_halt_on_error      IN  VARCHAR2 /*DEFAULT 'N'*/
         , p_structure_name     IN  VARCHAR2 := NULL
         , x_error_message      OUT NOCOPY VARCHAR2
        )  IS

    l_rollup_map  Bom_Rollup_Pub.Rollup_Action_Map := Bom_Rollup_Pub.G_EMPTY_ACTION_MAP;
    l_return_status varchar2(1) := 'S';
    l_msg_count number := 0;
    l_msg_data varchar2(3000) := null;

  BEGIN
-- We are not considering the p_structure_name anymore to calculate the preferred structure
-- as items are also calling the same api and the callee doesn't have a structure name
    IF p_transaction_type IN ('CREATE','DELETE')
    THEN
      IF (Bom_Rollup_Pub.Is_UCCNet_Enabled(p_item_id, p_organization_id) =  'Y')
      THEN
        Bom_Rollup_Pub.Add_Rollup_Function
        ( p_Object_Name         => 'EGO_ITEM'
        , p_Rollup_Action       => Bom_Rollup_Pub.G_COMPUTE_NET_WEIGHT
        , p_DML_Function        => 'Bom_Compute_Functions.Set_Net_Weight'
        , p_DML_Delayed_Write   => 'N'
        , x_Rollup_Action_Map   => l_rollup_map
        );

        Bom_Rollup_Pub.Add_Rollup_Function
        ( p_Object_Name         => 'EGO_ITEM'
        , p_Rollup_Action       => Bom_Rollup_Pub.G_PROPOGATE_BRAND_INFO
        , p_DML_Function        => 'Bom_Compute_Functions.Set_Brand_Info'
        , p_DML_Delayed_Write   => 'N'
        , x_Rollup_Action_Map   => l_rollup_map
        );
        Bom_Rollup_Pub.Add_Rollup_Function
        ( p_Object_Name         => 'EGO_ITEM'
        , p_Rollup_Action       => Bom_Rollup_Pub.G_COMPUTE_TOP_GTIN_FLAG
        , p_DML_Function        => 'Bom_Compute_Functions.Set_Top_GTIN_Flag'
        , p_DML_Delayed_Write   => 'N'
        , x_Rollup_Action_Map   => l_rollup_map
        );

        Bom_Rollup_Pub.Add_Rollup_Function
        ( p_Object_Name         => 'EGO_ITEM'
        , p_Rollup_Action       => Bom_Rollup_Pub.G_COMPUTE_MULTI_ROW_ATTRS
        , p_DML_Function        => 'Bom_Compute_Functions.Set_Multirow_Attributes'
        , p_DML_Delayed_Write   => 'N'
        , x_Rollup_Action_Map   => l_rollup_map
        );

        Bom_Rollup_Pub.Add_Rollup_Function
        ( p_Object_Name         => 'EGO_ITEM'
        , p_Rollup_Action       => Bom_Rollup_Pub.G_PROPAGATE_SH_TEMPS
        , p_DML_Function        => 'Bom_Compute_Functions.Set_SH_Temps'
        , p_DML_Delayed_Write   => 'N'
        , x_Rollup_Action_Map   => l_rollup_map
        );
      ELSIF (Bom_Rollup_Pub.Is_Pack_Item(p_item_id, p_organization_id) = 'Y')
      THEN
        Bom_Rollup_Pub.Add_Rollup_Function
        ( p_Object_Name         => 'EGO_ITEM'
        , p_Rollup_Action       => Bom_Rollup_Pub.G_COMPUTE_NET_WEIGHT
        , p_DML_Function        => 'Bom_Compute_Functions.Set_Net_Weight'
        , p_DML_Delayed_Write   => 'N'
        , x_Rollup_Action_Map   => l_rollup_map
        );
      ELSE
        RETURN;
      END IF;
    END IF;

    IF p_transaction_type IN ('UPDATE')
    THEN
      Bom_Rollup_Pub.Add_Rollup_Function
      ( p_Object_Name         => 'EGO_ITEM'
      , p_Rollup_Action       => Bom_Rollup_Pub.G_COMPUTE_NET_WEIGHT
      , p_DML_Function        => 'Bom_Compute_Functions.Set_Net_Weight'
      , p_DML_Delayed_Write   => 'N'
      , x_Rollup_Action_Map   => l_rollup_map
      );
    END IF;

    IF p_transaction_type = 'DELETE' AND
       p_parent_item_id IS NOT NULL
    THEN
      Bom_Rollup_Pub.g_attr_diffs := null;
      Bom_Rollup_Pub.Perform_Rollup( p_item_id => p_parent_item_id
                                     , p_organization_id   =>  p_organization_id
                                     , p_structure_type_name => p_structure_type_name
                                     , p_action_map     =>  l_rollup_map
                                     , p_validate       => p_validate
                                     , p_halt_on_error  => p_halt_on_error
                                     , x_error_message  => x_error_message );
      -- note: because of the Items flow, we want to store attr_diffs
      --  between calls to Perform_Rollup; however, in this case we want to clear them
      Bom_Rollup_Pub.g_attr_diffs := null;
      Bom_Rollup_Pub.Perform_Rollup( p_item_id => p_item_id
                                   , p_organization_id   =>  p_organization_id
                                   , p_structure_type_name => p_structure_type_name
                                   , p_action_map     =>  l_rollup_map
                                   , p_validate       => p_validate
                                   , p_halt_on_error  => p_halt_on_error
                                   , x_error_message  => x_error_message );
      Bom_Rollup_Pub.g_attr_diffs := null;

    ELSE
      Bom_Rollup_Pub.g_attr_diffs := null;
      Bom_Rollup_Pub.Perform_Rollup( p_item_id => p_item_id
                                     , p_organization_id   =>  p_organization_id
                                     , p_parent_item_id    =>  p_parent_item_id
                                     , p_structure_type_name => p_structure_type_name
                                     , p_action_map     =>  l_rollup_map
                                     , p_validate       => p_validate
                                     , p_halt_on_error  => p_halt_on_error
                                     , x_error_message  => x_error_message );
      Bom_Rollup_Pub.g_attr_diffs := null;
    END IF;
  END;

--added by dikrishn for bug3938873
PROCEDURE UPDATE_REG_PUB_UPDATE_DATES (p_inventory_item_id  IN NUMBER,
                                        p_organization_id   IN NUMBER,
                                        p_update_reg        IN VARCHAR2 := 'N',
                                        p_commit            IN VARCHAR2 :=  FND_API.G_FALSE,
                                        x_return_status     OUT NOCOPY VARCHAR2,
                                        x_msg_count         OUT NOCOPY NUMBER,
                                        x_msg_data          OUT NOCOPY VARCHAR2
                                        )
IS
BEGIN

   EGO_GTIN_PVT.UPDATE_REG_PUB_UPDATE_DATES (p_inventory_item_id => p_inventory_item_id,
                                             p_organization_id  => p_organization_id,
                                             p_update_reg       => p_update_reg,
                                             p_commit           => p_commit,
                                             x_return_status    => x_return_status,
                                             x_msg_count        => x_msg_count,
                                             x_msg_data         => x_msg_data
                                             );
END;

PROCEDURE GET_UOM_CLASS_COMPATIBILITY(p_source_item_id IN NUMBER,
                                      p_destn_item_id IN NUMBER,
                                      p_src_org_id IN NUMBER,
                                      p_dest_org_id IN NUMBER,
                                      x_compatibility_status OUT NOCOPY VARCHAR2
                                      )
IS
  l_src_uom_code VARCHAR2(3);
  l_dest_uom_code VARCHAR2(3);
BEGIN

  SELECT primary_uom_code
  INTO l_src_uom_code
  FROM MTL_SYSTEM_ITEMS_B
  WHERE inventory_item_id = p_source_item_id
  and organization_id = p_src_org_id;

  SELECT primary_uom_code
  INTO l_dest_uom_code
  FROM MTL_SYSTEM_ITEMS_B
  WHERE inventory_item_id = p_destn_item_id
  and organization_id = p_dest_org_id;

  GET_UOM_CLASS_COMPATIBILITY(p_src_uom_code => l_src_uom_code,
                              p_dest_uom_code => l_dest_uom_code,
                              x_compatibility_status => x_compatibility_status);

END;


PROCEDURE GET_UOM_CLASS_COMPATIBILITY(p_src_uom_code IN VARCHAR2,
                                      p_dest_uom_code IN VARCHAR2,
                                      x_compatibility_status OUT NOCOPY VARCHAR2)
IS
  l_total NUMBER;

BEGIN

  SELECT count(DISTINCT uom_class)
  into l_total
  FROM mtl_units_of_measure_vl
  WHERE uom_code = p_src_uom_code OR uom_code = p_dest_uom_code;

  IF l_total > 1
  THEN
    x_compatibility_status := 'N';
  ELSE
    x_compatibility_status := 'Y';
  END IF;

END GET_UOM_CLASS_COMPATIBILITY;


  /* Validate the rollup atributes within the hierarchy. They all should have the same values
      within a hierarchy.We need to validate this, in order to extend the support for heterogeneous
      hierarchies as part of UCCNET3.0 compliance
  */

  PROCEDURE Validate_Hierarchy_Attrs ( p_group_id IN NUMBER,
                                       x_return_status OUT NOCOPY VARCHAR2,
                                       x_error_message  OUT NOCOPY VARCHAR2) IS

    CURSOR c_unique_count IS
      SELECT count(DISTINCT ega.storage_handling_temp_max) storage_temp_max_cnt,
        count(DISTINCT ega.storage_handling_temp_min) storage_temp_min_cnt,
        count(DISTINCT ega.uom_storage_handling_temp_max) uom_storage_temp_max_cnt,
        count(DISTINCT ega.uom_storage_handling_temp_min) uom_storage_temp_min_cnt,
        count(DISTINCT ega.brand_owner_gln) brand_owner_gln_cnt,
        count(DISTINCT ega.brand_owner_name) brand_owner_name_cnt,
        count(DISTINCT ega.sub_brand) sub_brand_cnt,
        count(DISTINCT egal.functional_name) functional_name_cnt,
        count(DISTINCT msi.weight_uom_code) weight_uom_code_cnt
      FROM bom_explosions_all be,
        ego_item_gtn_attrs_b ega,
        ego_item_gtn_attrs_tl egal,
        mtl_system_items_b msi
      WHERE be.group_id = p_group_id
        AND be.trade_item_descriptor = 'BASE_UNIT_OR_EACH'
        AND be.component_item_id = msi.inventory_item_id
        AND be.common_organization_id = msi.organization_id
        AND msi.inventory_item_id = ega.inventory_item_id
        AND msi.organization_id = ega.organization_id
        AND ega.extension_id = egal.extension_id
        AND egal.language = userenv('LANG');

    TYPE MFR_TBL_TYPE IS TABLE OF VARCHAR2(1000)
    INDEX BY BINARY_INTEGER;

    l_mfg_table MFR_TBL_TYPE;

    l_where_clause VARCHAR2(32000);
    l_total_mfrs NUMBER := 0;
    l_result NUMBER;

  BEGIN

    x_return_status := 'S';

    /* Validate attributes */

    FOR r1 IN c_unique_count
    LOOP
      IF r1.storage_temp_max_cnt > 1 OR r1.uom_storage_temp_max_cnt > 1
      THEN
        x_return_status := 'E';
        x_error_message := Get_Message('BOM','BOM_GTIN_MULTI_STORAGE_MAX');
      ELSIF r1.storage_temp_min_cnt > 1 OR r1.uom_storage_temp_min_cnt > 1
      THEN
        x_return_status := 'E';
        x_error_message := Get_Message('BOM','BOM_GTIN_MULTI_STORAGE_MIN');
      ELSIF r1.brand_owner_gln_cnt > 1
      THEN
        x_return_status := 'E';
        x_error_message := Get_Message('BOM','BOM_GTIN_MULTI_BRAND_GLN');
      ELSIF r1.brand_owner_name_cnt > 1
      THEN
        x_return_status := 'E';
        x_error_message := Get_Message('BOM','BOM_GTIN_MULTI_BRAND_NAME');
      ELSIF r1.sub_brand_cnt > 1
      THEN
        x_return_status := 'E';
        x_error_message := Get_Message('BOM','BOM_GTIN_MULTI_SUB_BRAND');
      ELSIF r1.functional_name_cnt > 1
      THEN
        x_return_status := 'E';
        x_error_message := Get_Message('BOM','BOM_GTIN_MULTI_FUNC_NAME');
      ELSIF r1.weight_uom_code_cnt > 1
      THEN
        x_return_status := 'E';
        x_error_message := Get_Message('BOM','BOM_GTIN_MULTI_WEIGHT_UOM');
      END IF;
    END LOOP;

    IF x_return_status <> 'S'
    THEN
      Return;
    END IF;

    /* Validation for the multi row attributes Manufacturer name and
       Manufacturer GLN
    */

    SELECT DISTINCT concat(ega.manufacturer,ega.name_of_manufacturer)
      BULK COLLECT INTO l_mfg_table
    FROM bom_explosions_all be,
      ego_gtin_mfg_attrs_v ega
    WHERE be.group_id = p_group_id
      AND be.trade_item_descriptor = 'BASE_UNIT_OR_EACH'
      AND be.component_item_id = ega.inventory_item_id
      AND be.common_organization_id = ega.organization_id;

    l_total_mfrs := l_mfg_table.COUNT;

    IF l_total_mfrs = 0
    THEN
      Return;
    END IF;

    FOR i in 1..l_total_mfrs
    LOOP
      l_where_clause := l_where_clause||','||''''||l_mfg_table(i)||'''';
    END LOOP;

    l_where_clause := substr(l_where_clause,2);

    /*
    dbms_output.put_line(substr('SELECT 1 INTO l_result FROM dual WHERE EXISTS
      (SELECT null FROM bom_explosions_all be, ego_gtin_mfg_attrs_v ega
      WHERE be.group_id = '||p_group_id||' AND be.trade_item_descriptor = '||''''||'BASE_UNIT_OR_EACH'||''''||
      ' AND be.component_item_id = ega.inventory_item_id AND be.common_organization_id = ega.organization_id
      AND concat(ega.manufacturer,ega.name_of_manufacturer) IN ('||l_where_clause||')'||
      ' GROUP BY be.component_item_id HAVING count(*) <>'||l_total_mfrs||')',1,250));
    */

    BEGIN

      EXECUTE IMMEDIATE 'SELECT 1 FROM dual WHERE EXISTS
        (SELECT null FROM bom_explosions_all be, ego_gtin_mfg_attrs_v ega
        WHERE be.group_id = '||p_group_id||' AND be.trade_item_descriptor = '||''''||'BASE_UNIT_OR_EACH'||''''||
        ' AND be.component_item_id = ega.inventory_item_id AND be.common_organization_id = ega.organization_id
        AND concat(ega.manufacturer,ega.name_of_manufacturer) IN ('||l_where_clause||')'||
        ' GROUP BY be.component_item_id HAVING count(*) <> '||l_total_mfrs||' )' INTO l_result;

      EXCEPTION WHEN NO_DATA_FOUND
      THEN
        l_result := 0;
    END;

    --dbms_output.put_line('l_result is '||l_result);

    IF l_result <> 0
    THEN
      x_return_status := 'E';
      x_error_message := Get_Message('BOM','BOM_GTIN_MFG_DATA_NOT_SYNC');
    END IF;

  END;

END BOM_GTIN_Rules;




/

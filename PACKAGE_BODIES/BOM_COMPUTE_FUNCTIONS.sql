--------------------------------------------------------
--  DDL for Package Body BOM_COMPUTE_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_COMPUTE_FUNCTIONS" AS
/* $Header: BOMCMPFB.pls 120.5 2007/02/26 12:29:34 vhymavat ship $ */
/*# This package defines the atttribute Compute functions and Rollup compute functions
 * Whenever an item attribute needs to have computation based on related attributes
 * a computation function can be added and registered in the Attribute Map. Only
 * function per attribute is permitted.
 * Similarly, Rollup functions help in computing the value of a Parent in a Parent
 * Child relationship.
 * For eg. Container's wt = Wt. of Container item + 1..n[Sum(qty of child * unit wt of child)]
 * A rollup function is expected to impact atmost 1 attribute of the parent.
 * When rollup functions are registered, it is not required for them to always belong to this
 * package, but are expected to conform to the input/output parameter restrictions.
 * All rollup functions and compute functions have access to the attributes of the object at that level
 * @rep:scope private
 * @rep:product BOM
 * @rep:displayname Rollup Functions
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
*/

  /**********************************************************************
  ** The attribute compute functions affect attributes at the component level and
  ** will compute the data for a single component sequence_id
  **
  ** The Rollup functions will affect attributes of the header and will
  ** affect a single header row. When the rollup function is done, it is
  ** expected to write the attribute_name, computed_value to the header attribute
  ** map. This is required for the further process to correctly perform the
  ** rollup and updates of the header item.
  ** Some Rollup functions like Top GTIN affect only the Top Item
  ***********************************************************************/

  /*#
  * This method will be used for computing the net_weight attributes value
  * The method does not have any parameters, but it will have access to the
  * attribute map or the current item in process.
  * This should not be confused with the actual rollup function. This function
  * helps the derivation of the net_weight attribute for that particulat item
  * whereas rollup function of net_weight would take into consideration all the
  * child components of the current item.
  *
  * @rep:scope private
  * @rep:lifecycle active
  * @rep:displayname Compute Net weight
  */
  PROCEDURE Compute_Net_Weight(x_attribute_value  IN OUT NOCOPY VARCHAR2
      ,p_component_sequence_id IN OUT NOCOPY NUMBER)
  IS
  BEGIN
    --
    -- for an item the net wt is whatever is there in the table entry
    -- until it is over-written by a rollup function
    -- at the parent level, but there is no special rule of
    -- deriving the unit weight of a component
    --
    null;
  END Compute_Net_Weight;

  /*#
  * This method will be used for computing the net_weight attributes value
  * The method does not have any parameters, but it will have access to the
  * attribute map or the current item in process.
  * This should not be confused with the actual rollup function. This function
  * helps the derivation of the net_weight attribute for that particulat item
  * whereas rollup function of net_weight would take into consideration all the
  * child components of the current item.
  *
  * @rep:scope private
  * @rep:lifecycle active
  * @rep:displayname Compute Net weight
  */
  PROCEDURE Compute_Gross_Weight(x_attribute_value  IN OUT NOCOPY VARCHAR2
        ,p_component_sequence_id IN OUT NOCOPY NUMBER)
  IS
    CURSOR c_parent_or_leaf IS
    SELECT 'Parent'
      FROM bom_components_b comp
          ,bom_structures_b parent
     WHERE comp.component_sequence_id = p_component_sequence_id
       AND comp.bill_sequence_id = parent.bill_sequence_id
       AND EXISTS (SELECT bill_sequence_id
         FROM bom_structures_b comp_struct
        WHERE comp_struct.pk1_value = comp.pk1_value
          AND nvl(comp_struct.pk2_value, 'xxxxxxxxxxxxxxx') = nvl(comp.pk2_value,'xxxxxxxxxxxxxxx')
          AND comp_struct.obj_name = comp.obj_name
          AND comp_struct.alternate_bom_designator = parent.alternate_bom_designator
            );
  BEGIN
    --
    -- Gross Weight will include packaging material.
    -- but for the gross weight itself there is not special computation
    --
    null;

  END Compute_Gross_Weight;

/*#
* This method will be used for computing the net_weight attributes value
* The method does not have any parameters, but it will have access to the
* attribute map or the current item in process.
* This should not be confused with the actual rollup function. This function
* helps the derivation of the net_weight attribute for that particulat item
* whereas rollup function of net_weight would take into consideration all the
* child components of the current item.
*
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Rollup Net weight
*/
  PROCEDURE Rollup_Net_Weight
                  (p_header_item_id    IN NUMBER DEFAULT NULL
                  ,p_organization_id   IN NUMBER DEFAULT NULL
                  ,p_validate          IN VARCHAR2
                  ,p_halt_on_error     IN VARCHAR2
                  ,x_return_status     OUT NOCOPY VARCHAR2
                  ,x_error_message     OUT NOCOPY VARCHAR2
                  )
  IS
    l_net_weight  NUMBER := null;
    l_unit_weight NUMBER := null;
    l_qty         NUMBER := 0;
    l_net_weight_uom varchar2(30) := null;
    l_net_wt_uom varchar2(30);
    l_Comp_Attrs Bom_Rollup_Pub.Attribute_Map;
    l_CAttrs_Map Bom_Rollup_Pub.Component_Seq_Attrs_Tbl;
  BEGIN
    --
    -- Net Weight rollup happens as the following equation:
    -- assembly item wt = 1..n[sum(all gtin components)]
    --
    IF (Bom_Rollup_Pub.l_Component_Seq_Tbl.COUNT = 0)
    THEN
      -- If it is not an each, reset weight attributes
      IF (Bom_Rollup_Pub.Get_Trade_Item_Unit_Descriptor(p_header_item_id, p_organization_id) <> 'BASE_UNIT_OR_EACH') THEN

        Bom_Rollup_Pub.Set_Parent_Attribute('UNIT_WEIGHT',null);
        Bom_Rollup_Pub.Set_Parent_Attribute('NET_WEIGHT_UOM',null);

      END IF;

      RETURN;
    END IF;

    -- Ensure that this item is UCCNet enabled
    IF (Bom_Rollup_Pub.Is_Pack_Item(p_header_item_id, p_organization_id) <> 'Y')
    THEN
      RETURN;
    END IF;

    FOR cmp_index IN Bom_Rollup_Pub.l_Component_Seq_Tbl.FIRST..Bom_Rollup_Pub.l_Component_Seq_Tbl.LAST
    LOOP
      IF Bom_Rollup_Pub.l_Component_Seq_Tbl.EXISTS(cmp_index)
      THEN
        Bom_Rollup_Pub.Write_Debug_Log(Bom_Rollup_Pub.G_BO_IDENTIFIER, 'Entering GDSN Check');
        -- Only GDSN Items should be accounted bug # 4359090
        IF (Bom_Rollup_Pub.Is_UCCNet_Enabled(
              Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_item_id,
              p_organization_id)
            = 'Y')
        THEN
          IF p_validate = 'Y' THEN
          Bom_Gtin_Rules.Check_GTIN_Attributes
            ( p_assembly_item_id => p_header_item_id
            , p_organization_id => p_organization_id
            , p_component_item_id => Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_item_id
            , p_ignore_published => 'Y'
            , x_return_status => x_return_status
            , x_error_message => x_error_message
            );
          Bom_Rollup_Pub.WRITE_DEBUG_LOG(Bom_Rollup_Pub.G_BO_IDENTIFIER,
            'Check gtin attribs called for parent '||p_header_item_id||
            ' child '||Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_item_id||', returned '||
            x_return_status||':'||x_error_message);

          IF p_halt_on_error = 'Y' AND
             x_return_status IS NOT NULL AND
             x_return_status <> 'S'
          THEN

            -- error is passed up call stack in x_error_message
            RETURN;

            END IF;
          END IF;


        l_unit_weight := to_number(Bom_Rollup_Pub.Get_Attribute_Value
            (  p_component_sequence_id=> Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_sequence_id
            , p_attribute_name     => 'UNIT_WEIGHT'
            )
          );

        l_qty := to_number(Bom_Rollup_Pub.Get_Attribute_Value
            (  p_component_sequence_id=> Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_sequence_id
            , p_attribute_name       => 'COMPONENT_QUANTITY'
            )
          );

        l_net_wt_uom := Bom_Rollup_Pub.Get_Attribute_Value
          (  p_component_sequence_id=> Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_sequence_id
          , p_attribute_name       => 'NET_WEIGHT_UOM'
          );

        --l_net_weight := l_net_weight + (l_qty * l_unit_weight);

        IF l_unit_weight IS NOT NULL THEN
           IF l_net_weight IS NULL THEN
             l_net_weight := l_qty * l_unit_weight;
           ELSE
             l_net_weight := l_net_weight + (l_qty * l_unit_weight);
           END IF;
        END IF;
        IF l_net_wt_uom IS NOT NULL THEN
          l_net_weight_uom := l_net_wt_uom;
        END IF;

        END IF; --GDSN CHECK
      END IF; -- make sure to retrieve the collection only if exists a row.
    END LOOP;

    Bom_Rollup_Pub.Set_Parent_Attribute('UNIT_WEIGHT',l_net_weight);
    Bom_Rollup_Pub.Set_Parent_Attribute('NET_WEIGHT_UOM',l_net_weight_uom);

  END Rollup_Net_Weight;


        /*#
        * This method will be used for computing the gross-weight attributes value
        * The method does not have any parameters, but it will have access to the
        * attribute map or the current item in process.
        * This should not be confused with the actual rollup function. This function
        * helps the derivation of the net_weight attribute for that particulat item
        * whereas rollup function of net_weight would take into consideration all the
        * child components of the current item.
        *
        * @rep:scope private
        * @rep:lifecycle active
        * @rep:displayname Rollup Gross weight
        */
  PROCEDURE Rollup_Gross_Weight
                  (p_header_item_id    IN NUMBER DEFAULT NULL
                  ,p_organization_id   IN NUMBER DEFAULT NULL
                  ,p_validate          IN VARCHAR2
                  ,p_halt_on_error     IN VARCHAR2
                  ,x_return_status     OUT NOCOPY VARCHAR2
                  ,x_error_message     OUT NOCOPY VARCHAR2
                  )
  IS
    l_unit_weight NUMBER := null;
                l_qty         NUMBER :=0;
          l_gross_weight NUMBER := null;
          l_gross_wt NUMBER := null;
          l_gross_nwt_uom varchar2(30);
          l_gross_gwt_uom varchar2(30);
  BEGIN
    --
    -- Gross weight computations does not exclude the packaging material
    -- When registered as a function of a packaging structure, this can be modified
    -- to care for any specific requirement. but for now this does not seem to be the case.
    --

    --
    -- once we migrate some of the rollup computation to the middle tier
    -- we should be able to efficiently use the attribute name itself
    -- as the key. Currently the kep for the map is a sequence, which will
    -- require us to iterate through the map to find an attribute.
    --

    --
                -- assembly item wt = 1..n[sum(of all components)]
                --
    IF (Bom_Rollup_Pub.l_Component_Seq_Tbl.COUNT = 0)
    THEN
      -- If it is not an each, reset weight attributes
      IF (Bom_Rollup_Pub.Get_Trade_Item_Unit_Descriptor(p_header_item_id, p_organization_id) <> 'BASE_UNIT_OR_EACH') THEN

        Bom_Rollup_Pub.Set_Parent_Attribute('GROSS_WEIGHT',null);
        Bom_Rollup_Pub.Set_Parent_Attribute('GROSS_WEIGHT_UOM',null);

      END IF;

      RETURN;
    END IF;

    -- Ensure that this item is UCCNet enabled
    IF (Bom_Rollup_Pub.Is_UCCNet_Enabled(p_header_item_id, p_organization_id) <> 'Y')
    THEN
      RETURN;
    END IF;

    FOR cmp_index IN Bom_Rollup_Pub.l_Component_Seq_Tbl.FIRST..Bom_Rollup_Pub.l_Component_Seq_Tbl.LAST
    LOOP
      IF Bom_Rollup_Pub.l_Component_Seq_Tbl.EXISTS(cmp_index)
      THEN

        IF p_validate = 'Y' THEN

          Bom_Gtin_Rules.Check_GTIN_Attributes
            ( p_assembly_item_id => p_header_item_id
            , p_organization_id => p_organization_id
            , p_component_item_id => Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_item_id
            , p_ignore_published => 'Y'
            , x_return_status => x_return_status
            , x_error_message => x_error_message
            );
          Bom_Rollup_Pub.WRITE_DEBUG_LOG(Bom_Rollup_Pub.G_BO_IDENTIFIER,
            'Check gtin attribs called for parent '||p_header_item_id||
            ' child '||Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_item_id||', returned '||
            x_return_status||':'||x_error_message);

          IF p_halt_on_error = 'Y' AND
             x_return_status IS NOT NULL AND
             x_return_status <> 'S'
          THEN

            -- error is passed up call stack in x_error_message
            RETURN;

          END IF;

        END IF;


        l_unit_weight :=
        to_number(Bom_Rollup_Pub.Get_Attribute_Value
                  (  p_component_sequence_id=> Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_sequence_id
                   , p_attribute_name       => 'UNIT_WEIGHT'
                   )
                  );
         l_gross_wt :=
        to_number(Bom_Rollup_Pub.Get_Attribute_Value
                  (  p_component_sequence_id=> Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_sequence_id
                   , p_attribute_name       => 'GROSS_WEIGHT'
                   )
                  );
         l_qty :=
         to_number(Bom_Rollup_Pub.Get_Attribute_Value
                   (  p_component_sequence_id=> Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_sequence_id
                    , p_attribute_name       => 'COMPONENT_QUANTITY'
                   )
                  );
         l_gross_nwt_uom := Bom_Rollup_Pub.Get_Attribute_Value
                          (  p_component_sequence_id=> Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_sequence_id
                           , p_attribute_name       => 'NET_WEIGHT_UOM'
                           );
         l_gross_gwt_uom := Bom_Rollup_Pub.Get_Attribute_Value
                          (  p_component_sequence_id=> Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_sequence_id
                           , p_attribute_name       => 'GROSS_WEIGHT_UOM'
                           );
         /*
         if ( (l_gross_wt is not null) and (l_gross_wt > 0) ) then
                 l_gross_weight := l_gross_weight + (l_qty * l_gross_wt);
         else
                 l_gross_weight := l_gross_weight + (l_qty * l_unit_weight);
                 l_gross_gwt_uom := l_gross_nwt_uom;
         end if;
         */
         IF (l_gross_wt is not null) and (l_gross_wt > 0) THEN
            IF l_gross_weight IS NULL THEN
              l_gross_weight := l_qty * l_gross_wt;
            ELSE
              l_gross_weight := l_gross_weight + (l_qty * l_gross_wt);
            END IF;
         ELSE
            IF l_unit_weight IS NOT NULL THEN
              IF l_gross_weight IS NULL THEN
                l_gross_weight := l_qty * l_unit_weight;
              ELSE
                l_gross_weight := l_gross_weight + (l_qty * l_unit_weight);
              END IF;
            END IF;
            l_gross_gwt_uom := l_gross_nwt_uom;
         END IF;
      END IF; -- fetch a collection row only if one exists.
    END LOOP;



    Bom_Rollup_Pub.Set_Parent_Attribute('GROSS_WEIGHT',l_gross_weight);
    Bom_Rollup_Pub.Set_Parent_Attribute('GROSS_WEIGHT_UOM',l_gross_gwt_uom);

  END Rollup_Gross_Weight;

        /*#
        * This method will help propogate the Private Flag.
        * Private flag propogation has one rule. If a component is Private = Y, then the parent
  * has to be Private.
  * A Private child cannot have a non-private Parent.
        *
        * @rep:scope private
        * @rep:lifecycle active
        * @rep:displayname Rollup Private Flag
        */

  PROCEDURE Propogate_Private_Flag
                  (p_header_item_id    IN NUMBER DEFAULT NULL
                  ,p_organization_id   IN NUMBER DEFAULT NULL
                  ,p_validate          IN VARCHAR2
                  ,p_halt_on_error     IN VARCHAR2
                  ,x_return_status     OUT NOCOPY VARCHAR2
                  ,x_error_message     OUT NOCOPY VARCHAR2
                  )
  IS
    l_private_flag VARCHAR2(1) := 'N';
  BEGIN

    IF (Bom_Rollup_Pub.l_Component_Seq_Tbl.COUNT = 0)
    THEN
      -- If it is not an each, reset weight attributes
      IF (Bom_Rollup_Pub.Get_Trade_Item_Unit_Descriptor(p_header_item_id, p_organization_id) <> 'BASE_UNIT_OR_EACH') THEN

        Bom_Rollup_Pub.Set_Parent_Attribute('IS_TRADE_ITEM_INFO_PRIVATE',null);

      END IF;

      RETURN;
    END IF;

    -- Ensure that this item is UCCNet enabled
    IF (Bom_Rollup_Pub.Is_UCCNet_Enabled(p_header_item_id, p_organization_id) <> 'Y')
    THEN
      RETURN;
    END IF;

    FOR cmp_index IN Bom_Rollup_Pub.l_Component_Seq_Tbl.FIRST..Bom_Rollup_Pub.l_Component_Seq_Tbl.LAST
    LOOP
      IF Bom_Rollup_Pub.l_Component_Seq_Tbl.EXISTS(cmp_index) AND
          l_private_flag = 'N'
      THEN
        IF p_validate = 'Y' THEN

          Bom_Gtin_Rules.Check_GTIN_Attributes
            ( p_assembly_item_id => p_header_item_id
            , p_organization_id => p_organization_id
            , p_component_item_id => Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_item_id
            , p_ignore_published => 'Y'
            , x_return_status => x_return_status
            , x_error_message => x_error_message
            );
          Bom_Rollup_Pub.WRITE_DEBUG_LOG(Bom_Rollup_Pub.G_BO_IDENTIFIER,
            'Check gtin attribs called for parent '||p_header_item_id||
            ' child '||Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_item_id||', returned '||
            x_return_status||':'||x_error_message);

          IF p_halt_on_error = 'Y' AND
             x_return_status IS NOT NULL AND
             x_return_status <> 'S'
          THEN

            -- error is passed up call stack in x_error_message
            RETURN;

          END IF;

        END IF;

        IF Bom_Rollup_Pub.Get_Attribute_Value
             ( p_attribute_name    => 'IS_TRADE_ITEM_INFO_PRIVATE'
             , p_component_sequence_id => Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_sequence_id
             )  = 'Y'
        THEN
          l_private_flag := 'Y';

        END IF;
      END IF; -- fetch a collection row only if one exists.
    END LOOP;


    --
    -- set the private flag only if atleast 1 component is Private.
    --
    IF l_private_flag = 'Y'
    THEN
      Bom_Rollup_Pub.Set_Parent_Attribute('IS_TRADE_ITEM_INFO_PRIVATE',l_private_flag);
    END IF;

  END Propogate_Private_Flag;

  PROCEDURE Propogate_Brand_Info
    (p_header_item_id    IN NUMBER DEFAULT NULL
    ,p_organization_id   IN NUMBER DEFAULT NULL
    ,p_validate          IN VARCHAR2
    ,p_halt_on_error     IN VARCHAR2
    ,x_return_status     OUT NOCOPY VARCHAR2
    ,x_error_message     OUT NOCOPY VARCHAR2
    )
    IS
      l_brand_owner_name VARCHAR2(35) := '';
      l_brand_owner_gln  VARCHAR2(35) := '';
      l_functional_name  VARCHAR2(35) := '';
      l_sub_brand        VARCHAR2(35) := '';

    BEGIN

    IF (Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl.COUNT = 0)
    THEN
      -- If it is not an each, reset weight attributes
      IF (Bom_Rollup_Pub.Get_Trade_Item_Unit_Descriptor(p_header_item_id, p_organization_id) <> 'BASE_UNIT_OR_EACH') THEN

        Bom_Rollup_Pub.Set_Parent_Attribute('BRAND_OWNER_NAME',null);
        Bom_Rollup_Pub.Set_Parent_Attribute('BRAND_OWNER_GLN',null);
        Bom_Rollup_Pub.Set_Parent_Attribute('FUNCTIONAL_NAME',null);
        Bom_Rollup_Pub.Set_Parent_Attribute('SUB_BRAND',null);

      END IF;

      RETURN;
    END IF;

    -- Ensure that this item is UCCNet enabled
    IF (Bom_Rollup_Pub.Is_UCCNet_Enabled(p_header_item_id, p_organization_id) <> 'Y')
    THEN
      RETURN;
    END IF;

    IF p_validate = 'Y' THEN

      FOR cmp_index IN Bom_Rollup_Pub.l_Component_Seq_Tbl.FIRST..Bom_Rollup_Pub.l_Component_Seq_Tbl.LAST
      LOOP

        IF Bom_Rollup_Pub.l_Component_Seq_Tbl.EXISTS(cmp_index)
        THEN

          Bom_Gtin_Rules.Check_GTIN_Attributes
            ( p_assembly_item_id => p_header_item_id
            , p_organization_id => p_organization_id
            , p_component_item_id => Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_item_id
            , p_ignore_published => 'Y'
            , x_return_status => x_return_status
            , x_error_message => x_error_message
            );
          Bom_Rollup_Pub.WRITE_DEBUG_LOG(Bom_Rollup_Pub.G_BO_IDENTIFIER,
            'Check gtin attribs called for parent '||p_header_item_id||
            ' child '||Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_item_id||', returned '||
            x_return_status||':'||x_error_message);

          IF p_halt_on_error = 'Y' AND
             x_return_status IS NOT NULL AND
             x_return_status <> 'S'
          THEN

            -- error is passed up call stack in x_error_message
            RETURN;

          END IF;

        END IF;

      END LOOP;

    END IF;


    FOR cmp_index IN Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl.FIRST..Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl.LAST
    LOOP
      IF Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl.EXISTS(cmp_index)
      THEN
        IF Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl(cmp_index).attribute_name =
                         'BRAND_OWNER_NAME'
        THEN
          l_brand_owner_name :=
            Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl(cmp_index).attribute_value;
          Bom_Rollup_Pub.Set_Parent_Attribute('BRAND_OWNER_NAME',l_brand_owner_name);
        ELSIF Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl(cmp_index).attribute_name =
                         'BRAND_OWNER_GLN'
        THEN
          l_brand_owner_gln :=
            Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl(cmp_index).attribute_value;
          Bom_Rollup_Pub.Set_Parent_Attribute('BRAND_OWNER_GLN',l_brand_owner_gln);
        ELSIF Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl(cmp_index).attribute_name =
                         'FUNCTIONAL_NAME'
        THEN
          l_functional_name :=
            Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl(cmp_index).attribute_value;
          Bom_Rollup_Pub.Set_Parent_Attribute('FUNCTIONAL_NAME',l_functional_name);
        ELSIF Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl(cmp_index).attribute_name =
                         'SUB_BRAND'
        THEN
          l_sub_brand :=
            Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl(cmp_index).attribute_value;
          Bom_Rollup_Pub.Set_Parent_Attribute('SUB_BRAND',l_sub_brand);
        END IF;
      END IF; -- fetch a collection row only if one exists.
    END LOOP;

    --
    -- Set the attributes
    -- Open Design Issue: What happens in the case of a Hetrogenous Pack ?
    -- possible solution is that the user assigns the attribute value for the parent
    -- which hold the hierarchy. Propogation can start from that level above.
    --

  END Propogate_Brand_Info;


/*#
* This method will compute the TOP GTIN flag.
* Computation of TOP GTIN is based on 2 flags, Consumable and Orderable other than the fact
* that both the Parent Item and Component Item have to be GTINs.
* At any time there are atmost 2 rows that will be affected, one is the current row
* and second is the top item.
        * Following matrix explains which combination evaluates to a Top GTIN flag of Yes:
  * All other conditions evaluate to a Top GTIN flag = No.
  * ---------------------------------------------------
  * | Top Item Flag | Consumable     | Orderable      |
  * ---------------------------------------------------
  * | Yes           | Component Item | Component Item |
  * | -------------------------------------------------
  * | Yes           | Component Item | Top Item       |
  * | -------------------------------------------------
  * | Yes           | Top Item       | Component Item |
  * | -------------------------------------------------
  * | Yes           | Top Item       | Top Item       |
  * | -------------------------------------------------
  *
        * @rep:scope public
        * @rep:lifecycle active
        * @rep:displayname Compute Top GTIN Flag
        */
  PROCEDURE Propogate_Top_GTIN_Flag
                  (p_header_item_id    IN NUMBER DEFAULT NULL
                  ,p_organization_id   IN NUMBER DEFAULT NULL
                  ,p_validate          IN VARCHAR2
                  ,p_halt_on_error     IN VARCHAR2
                  ,x_return_status     OUT NOCOPY VARCHAR2
                  ,x_error_message     OUT NOCOPY VARCHAR2
                  )
  IS
    CURSOR c_cons_ord_flag(p_item_id  NUMBER) IS
    SELECT is_trade_item_a_consumer_unit
         , customer_order_enabled_flag
         , Bom_Rollup_Pub.Is_UCCNet_Enabled(p_item_id, p_organization_id) is_uccnet
      FROM ego_items_v
     WHERE inventory_item_id = p_item_id
       AND organization_id = p_organization_id;

    CURSOR c_comp_cons_ord_flag(p_component_sequence_id NUMBER) IS
    SELECT is_trade_item_a_consumer_unit
         , customer_order_enabled_flag
         , Bom_Rollup_Pub.Is_UCCNet_Enabled(bic.component_item_id, p_organization_id) is_uccnet
     FROM ego_items_v
         , bom_components_b bic
     WHERE inventory_item_id = bic.component_item_id
       AND organization_id = p_organization_id
       AND bic.component_sequence_id = p_component_sequence_id;

    l_top_gtin_flag   VARCHAR2(1) := null;
    l_top_gtin_in_map VARCHAR2(1);
    l_top_consumable  VARCHAR2(1);
    l_top_orderable   VARCHAR2(1);
    is_top_uccnet     VARCHAR2(1);
    l_comp_consumable VARCHAR2(1);
    l_comp_orderable  VARCHAR2(1);
    is_comp_uccnet    VARCHAR2(1);
    l_found_consumable VARCHAR2(1);
    l_found_orderable  VARCHAR2(1);
  BEGIN

    Bom_Rollup_Pub.WRITE_DEBUG_LOG ( p_bo_identifier   => Bom_Rollup_Pub.G_BO_IDENTIFIER
                                   , p_message         => 'Inside TOP GTIN');

    -- Ensure that this item is UCCNet enabled
    IF (Bom_Rollup_Pub.Is_UCCNet_Enabled(p_header_item_id, p_organization_id) <> 'Y')
    THEN
      RETURN;
    END IF;

    l_top_gtin_in_map := Bom_Rollup_Pub.Get_Top_Item_Attribute_Value('TOP_GTIN');
    IF l_top_gtin_in_map IS NOT NULL AND
       l_top_gtin_in_map = 'Y'
    THEN
      RETURN;
      -- if a prior level set the Top_Gtin to Y, then
      -- simply return.
    END IF;

    --
    -- Check if top item is a GTIN
    --

    FOR cons_or_ord_flag IN c_cons_ord_flag(p_item_id => Bom_Rollup_Pub.Get_Top_Item_Id)
    LOOP
      l_top_consumable := cons_or_ord_flag.is_trade_item_a_consumer_unit;
      l_top_orderable := cons_or_ord_flag.customer_order_enabled_flag;
      is_top_uccnet := cons_or_ord_flag.is_uccnet;
    END LOOP;


    Bom_Rollup_Pub.WRITE_DEBUG_LOG ( p_bo_identifier => Bom_Rollup_Pub.G_BO_IDENTIFIER
                                   , p_message       => 'l_top_consumable ' || l_top_consumable
                                                     || ' and l_top_orderable ' || l_top_orderable
                                                     || ' is_top_uccnet ' || is_top_uccnet);

    -- bug 4043371: need to check if consumable and orderable are set anywhere in the hierarchy
    --  use FOUND_CONSUMABLE and FOUND_ORDERABLE dummy flags to store these
    l_found_consumable := Bom_Rollup_Pub.Get_Top_Item_Attribute_Value('FOUND_CONSUMABLE');
    l_found_orderable := Bom_Rollup_Pub.Get_Top_Item_Attribute_Value('FOUND_ORDERABLE');
    IF l_found_consumable IS NOT NULL THEN
      l_top_consumable := l_found_consumable;
    END IF;
    IF l_found_orderable IS NOT NULL THEN
      l_top_orderable := l_found_orderable;
    END IF;

    IF l_top_consumable = 'Y' AND
       l_top_orderable  = 'Y'
    THEN
      l_top_gtin_flag := 'Y';
      --
      -- This check and assignment will prevent any unnecessary
      -- processing of the components
      -- since the above satisfies the requirement for a TOP GTIN criteria
      --
    END IF;
    --
    -- Check if one of the above conditions in the
    -- TOP GTIN matrix is true.
    --

/*                IF (Bom_Rollup_Pub.l_Component_Seq_Tbl.COUNT = 0)
                THEN
                        return;
                END IF;*/

  Bom_Rollup_Pub.WRITE_DEBUG_LOG (Bom_Rollup_Pub.G_BO_IDENTIFIER, 'header item: '||p_header_item_id||
                    ' components: '||Bom_Rollup_Pub.l_Component_Seq_Tbl.COUNT || ' TOP_GTIN_FLAG ' || l_top_gtin_flag );

  IF (Bom_Rollup_Pub.l_Component_Seq_Tbl.COUNT > 0) THEN
    FOR cmp_index IN Bom_Rollup_Pub.l_Component_Seq_Tbl.FIRST..Bom_Rollup_Pub.l_Component_Seq_Tbl.LAST
    LOOP
      IF l_top_gtin_flag = 'Y'
      THEN
        exit;
      END IF;

      IF Bom_Rollup_Pub.l_Component_Seq_Tbl.EXISTS(cmp_index)
      THEN

        IF p_validate = 'Y' THEN

          Bom_Gtin_Rules.Check_GTIN_Attributes
            ( p_assembly_item_id => p_header_item_id
            , p_organization_id => p_organization_id
            , p_component_item_id => Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_item_id
            , p_ignore_published => 'Y'
            , x_return_status => x_return_status
            , x_error_message => x_error_message
            );
          Bom_Rollup_Pub.WRITE_DEBUG_LOG(Bom_Rollup_Pub.G_BO_IDENTIFIER,
            'Check gtin attribs called for parent '||p_header_item_id||
            ' child '||Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_item_id||', returned '||
            x_return_status||':'||x_error_message);

          IF p_halt_on_error = 'Y' AND
             x_return_status IS NOT NULL AND
             x_return_status <> 'S'
          THEN

            -- error is passed up call stack in x_error_message
            RETURN;

          END IF;

        END IF;

        FOR comp_cons_or_ord_flag IN c_comp_cons_ord_flag(p_component_sequence_id       =>
        Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_sequence_id
           )
        LOOP
          -- if consumable or orderable are already 'Y', don't look any further
          is_comp_uccnet   := comp_cons_or_ord_flag.is_uccnet;
          IF is_comp_uccnet = 'Y' AND
             (l_comp_consumable IS NULL OR l_comp_consumable <> 'Y') THEN
            l_comp_consumable := comp_cons_or_ord_flag.is_trade_item_a_consumer_unit;
          END IF;
          IF is_comp_uccnet = 'Y' AND
             (l_comp_orderable IS NULL OR l_comp_orderable <> 'Y') THEN
            l_comp_orderable  := comp_cons_or_ord_flag.customer_order_enabled_flag;
          END IF;
          Bom_Rollup_Pub.WRITE_DEBUG_LOG (Bom_Rollup_Pub.G_BO_IDENTIFIER,
             'Within loop for compseq('||Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_sequence_id||
             ') top: cons='||l_top_consumable||'/ord='||l_top_orderable||' comp: cons='||l_comp_consumable||'/ord='||
             l_comp_orderable||'/ucc='||is_comp_uccnet);
        END LOOP;
      END IF; -- fetch a collection row only if one exists.

      -- bug 4043371: if consumable and orderable are found anywhere in the hierarchy
      --  store this in the top item's map
      IF (l_comp_consumable = 'Y') THEN
        Bom_Rollup_Pub.Set_Top_Item_Attribute('FOUND_CONSUMABLE',l_comp_consumable);
      END IF;
      IF (l_comp_orderable = 'Y') THEN
        Bom_Rollup_Pub.Set_Top_Item_Attribute('FOUND_ORDERABLE',l_comp_orderable);
      END IF;

        --
        -- We have the Component flags and the Top Item flags required for the matrix check
        --
      IF is_comp_uccnet = 'Y'
      THEN
        IF ( (l_comp_consumable = 'Y' AND
            l_comp_orderable  = 'Y'
           ) OR
           (l_comp_consumable = 'Y' AND
            l_top_orderable   = 'Y'
           ) OR
           (l_top_consumable  = 'Y' AND
            l_comp_orderable  = 'Y'
           ) OR
           (l_top_consumable  = 'Y' AND
            l_top_orderable   = 'Y'
           )
           )
        THEN
          l_top_gtin_flag := 'Y';
            exit;
            -- if the top level gtin is set, then the rest of the components can be
            -- ignored.
        END IF;
      END IF;
    END LOOP;
  END IF;

    --
    -- Set the TOP GTIN attribute. Now, this function does not choose to set the attribute
    -- in the central store, since the updates here do not affect the component or the parent
    -- but only impacts the top level. So the value will be stored in the Top Attribute Map
    --
    --
    -- If the Top_Item_Attribute Map is empty then store the value, otherwise write only if N since
    -- a value of Y would mean that some level already evaluated the top item to be top_gtin Y.
    -- This process will continue till the top and if none of the levels are able to evaluate the
    -- condition to True, then the current top_item is not a GTIN.
    --

    IF l_top_gtin_in_map IS NULL
    THEN
      --
      -- which means that this is the first subtree of the last level in the Tree
      -- so create the row either Y or NULL, whatever is the value of l_top_gtin_flag
      --
      Bom_Rollup_Pub.Set_Top_Item_Attribute('TOP_GTIN',l_top_gtin_flag);

    ELSIF l_top_gtin_in_map IS NOT NULL AND
          l_top_gtin_in_map = 'N' AND
          l_top_gtin_flag = 'Y'
    THEN
      Bom_Rollup_Pub.Set_Top_Item_Attribute('TOP_GTIN',l_top_gtin_flag);
    END IF;

    Bom_Rollup_Pub.WRITE_DEBUG_LOG (
                                  p_bo_identifier   => Bom_Rollup_Pub.G_BO_IDENTIFIER
                    , p_message         => 'End TOP GTIN');
  EXCEPTION
    WHEN OTHERS THEN
      Bom_Rollup_Pub.WRITE_DEBUG_LOG (Bom_Rollup_Pub.G_BO_IDENTIFIER, 'Exception in Top GTIN: '||sqlerrm);

  END Propogate_Top_GTIN_Flag;


/*#
* This method will be used for computing the multirow attributes value
* The method does not have any parameters, but it will have access to the
* attr_diff_object or the current item in process.
* This at present will do the update of the multirow attrs
* Fixme once this is working
*
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Rollup Net weight
*/
  PROCEDURE Compute_Multi_Row_Attrs
    (p_header_item_id    IN NUMBER DEFAULT NULL
    ,p_organization_id   IN NUMBER DEFAULT NULL
    ,p_validate          IN VARCHAR2
    ,p_halt_on_error     IN VARCHAR2
    ,x_return_status     OUT NOCOPY VARCHAR2
    ,x_error_message     OUT NOCOPY VARCHAR2
    )
  IS
    l_pk_column_values       EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_pk_column_value        EGO_COL_NAME_VALUE_PAIR_OBJ;
    l_error_message          VARCHAR2(2000);
    l_item_catalog_group_id  NUMBER;
    l_extension_ids          EGO_NUMBER_TBL_TYPE;
    l_cur_attr_diff_tbl      EGO_USER_ATTR_DIFF_TABLE;
    l_transaction_type       VARCHAR2(10) := 'SYNC';
    l_found_ext_id           BOOLEAN := FALSE;

    --Cursor for creating the classification code
    Cursor get_classification_code
    is
        SELECT
            item_catalog_group_id
        FROM
            mtl_system_items_b
        WHERE
            inventory_item_id = p_header_item_id
        AND organization_id = p_organization_id;

    CURSOR updatable_gtin_mulrow is
          SELECT DISTINCT ATTR_GROUP_TYPE
                  , ATTR_GROUP_NAME
          FROM
                  EGO_ATTRS_V A
          WHERE
		  A.APPLICATION_ID = 431 --PERF BUG 4932131
                  AND A.ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_MULTI_ATTRS'
                  AND A.EDIT_IN_HIERARCHY_CODE IN ('LP');

    CURSOR get_attr_group_id(p_attr_id NUMBER) IS
          SELECT DISTINCT AG.ATTR_GROUP_ID
          FROM
                  EGO_ATTRS_V A, EGO_ATTR_GROUPS_V AG
          WHERE
                  A.APPLICATION_ID = AG.APPLICATION_ID
                  AND A.ATTR_GROUP_TYPE = AG.ATTR_GROUP_TYPE
                  AND A.ATTR_GROUP_NAME = AG.ATTR_GROUP_NAME
                  AND A.ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_MULTI_ATTRS'
                  AND A.EDIT_IN_HIERARCHY_CODE IN ('LP')
                  AND A.ATTR_ID = p_attr_id;
  BEGIN

    -- Ensure that this item is UCCNet enabled
    IF (Bom_Rollup_Pub.Is_UCCNet_Enabled(p_header_item_id, p_organization_id) <> 'Y')
    THEN
      RETURN;
    END IF;

    IF (Bom_Rollup_Pub.l_Component_Seq_Tbl.COUNT = 0)
    THEN
      -- If it is not an each, reset weight attributes
      IF (Bom_Rollup_Pub.Get_Trade_Item_Unit_Descriptor(p_header_item_id, p_organization_id) <> 'BASE_UNIT_OR_EACH') THEN

        -- Handle resetting of multirow attributes in update_attributes
        l_transaction_type := 'DELETE';

      END IF;

    END IF;

    l_pk_column_values := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                          EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', p_header_item_id)
                         ,EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', p_organization_id)
                         );

    --
    -- When there is a change to the packaging hierarchy
    -- the attr_diff object will not be passed
    -- Hence if the count is zero we have to query the attr_diff object
    --
    IF (Bom_Rollup_Pub.g_attr_diffs IS NULL OR Bom_Rollup_Pub.g_attr_diffs.count <= 0)
    THEN

      Bom_Rollup_Pub.WRITE_DEBUG_LOG
        ( p_bo_identifier   => Bom_Rollup_Pub.G_BO_IDENTIFIER
        , p_message         => 'INSIDE Multi-Row Component Call tt='||l_transaction_type);
      --Query the ATTR_DIFF object
      --This will also give the l_class_code_name_value_pairs
      -- and l_data_level_name_value_pairs

      /*********FIX ME **************/
      --  This has to be per attr_group basis, as the Update
      --  can only handle one attr_group at a time
      /*********FIX ME **************/
      FOR c1 IN updatable_gtin_mulrow
      LOOP
          EGO_GTIN_PVT.Get_Attr_Diffs
          (
              p_inventory_item_id  => p_header_item_id
            , p_org_id             => p_organization_id
            , p_application_id     => 431
            , p_attr_group_type    => c1.ATTR_GROUP_TYPE
            , p_attr_group_name    => c1.ATTR_GROUP_NAME
            , px_attr_diffs        => Bom_Rollup_Pub.g_attr_diffs
            , px_pk_column_name_value_pairs => Bom_Rollup_Pub.g_pk_column_name_value_pairs
            , px_class_code_name_value_pairs => Bom_Rollup_Pub.g_class_code_name_value_pairs
            , px_data_level_name_value_pairs => Bom_Rollup_Pub.g_data_level_name_value_pairs
            , x_error_message      => l_error_message
          );
          -- for now just copy attr_diff.old to attr_diff.new, so calling update_attrs has no effect
         --Make sure we call the update api only when multirow attrs are updated
         -- bug: 4037735
        IF (l_transaction_type <> 'DELETE'
            AND Bom_Rollup_Pub.g_attr_diffs IS NOT NULL
            AND Bom_Rollup_Pub.g_attr_diffs.count > 0) THEN
          FOR i IN Bom_Rollup_Pub.g_attr_diffs.FIRST .. Bom_Rollup_Pub.g_attr_diffs.LAST
          LOOP

            Bom_Rollup_Pub.g_attr_diffs(i).NEW_ATTR_VALUE_STR :=
              Bom_Rollup_Pub.g_attr_diffs(i).OLD_ATTR_VALUE_STR;
            Bom_Rollup_Pub.g_attr_diffs(i).NEW_ATTR_VALUE_NUM :=
              Bom_Rollup_Pub.g_attr_diffs(i).OLD_ATTR_VALUE_NUM;
            Bom_Rollup_Pub.g_attr_diffs(i).NEW_ATTR_VALUE_DATE :=
              Bom_Rollup_Pub.g_attr_diffs(i).OLD_ATTR_VALUE_DATE;
            Bom_Rollup_Pub.g_attr_diffs(i).NEW_ATTR_UOM :=
              Bom_Rollup_Pub.g_attr_diffs(i).OLD_ATTR_UOM;

          END LOOP;
        END IF;--if Bom_Rollup_Pub.g_attr_diffs is not null
      END LOOP;
    ELSE
      --
      -- Get the classification code, this could be different as components
      --  in one hierarchy can be of different classification
      --
      FOR c1 IN get_classification_code
      LOOP
          l_item_catalog_group_id := c1.item_catalog_group_id;
      END LOOP;

      Bom_Rollup_Pub.g_class_code_name_value_pairs :=
        EGO_COL_NAME_VALUE_PAIR_ARRAY
          (EGO_COL_NAME_VALUE_PAIR_OBJ('ITEM_CATALOG_GROUP_ID', to_char(l_item_catalog_group_id)));

    END IF;
    --Call the update api only if Bom_Rollup_Pub.g_attr_diffs is not null.
    --bug: 4037735.

    IF (Bom_Rollup_Pub.g_attr_diffs IS NOT NULL
         AND Bom_Rollup_Pub.g_attr_diffs.count > 0) THEN

      -- Group diff objects by extension_id
      FOR i IN Bom_Rollup_Pub.g_attr_diffs.FIRST .. Bom_Rollup_Pub.g_attr_diffs.LAST
      LOOP

        l_found_ext_id := FALSE;

        IF l_extension_ids IS NOT NULL THEN

          FOR j IN l_extension_ids.FIRST .. l_extension_ids.LAST
          LOOP

            IF l_found_ext_id = FALSE AND
               l_extension_ids(j) = Bom_Rollup_Pub.g_attr_diffs(i).EXTENSION_ID
            THEN

              l_found_ext_id := TRUE;

            END IF;

          END LOOP;

        ELSE

          l_extension_ids := EGO_NUMBER_TBL_TYPE();

        END IF;

        IF l_found_ext_id = FALSE
        THEN

          l_extension_ids.EXTEND();
          l_extension_ids(l_extension_ids.LAST) := Bom_Rollup_Pub.g_attr_diffs(i).EXTENSION_ID;

        END IF;

      END LOOP;

      -- Now iterate through the distinct ext ids, construct diff tables, and issue update_attrs call
      FOR i IN l_extension_ids.FIRST .. l_extension_ids.LAST
      LOOP

        l_cur_attr_diff_tbl := EGO_USER_ATTR_DIFF_TABLE();

        FOR j IN Bom_Rollup_Pub.g_attr_diffs.FIRST .. Bom_Rollup_Pub.g_attr_diffs.LAST
        LOOP

          IF (l_extension_ids(i) IS NULL AND Bom_Rollup_Pub.g_attr_diffs(j).EXTENSION_ID IS NULL)
             OR l_extension_ids(i) = Bom_Rollup_Pub.g_attr_diffs(j).EXTENSION_ID THEN

            l_cur_attr_diff_tbl.EXTEND();
            l_cur_attr_diff_tbl(l_cur_attr_diff_tbl.LAST) := Bom_Rollup_Pub.g_attr_diffs(j);

          END IF;

        END LOOP;

        IF l_cur_attr_diff_tbl.COUNT > 0 THEN

          FOR c1 IN get_attr_group_id(l_cur_attr_diff_tbl(l_cur_attr_diff_tbl.FIRST).ATTR_ID)
          LOOP

            Bom_Rollup_Pub.WRITE_DEBUG_LOG (
                    p_bo_identifier   => Bom_Rollup_Pub.G_BO_IDENTIFIER
                  , p_message         => 'Calling Update Attributes');
            EGO_GTIN_PVT.Update_Attributes
                  ( p_pk_column_name_value_pairs    => l_pk_column_values
                  , p_class_code_name_value_pairs   => Bom_Rollup_Pub.g_class_code_name_value_pairs
                  , p_data_level_name_value_pairs   => Bom_Rollup_Pub.g_data_level_name_value_pairs
                  , p_attr_diffs                    => l_cur_attr_diff_tbl
                  , p_transaction_type              => l_transaction_type
                  , p_attr_group_id                 => c1.attr_group_id
                  , x_error_message                 => l_error_message);

            Bom_Rollup_Pub.WRITE_DEBUG_LOG (
                    p_bo_identifier   => Bom_Rollup_Pub.G_BO_IDENTIFIER
                  , p_message         => 'After Calling Update Attributes' || l_error_message);

          END LOOP;

        END IF;

      END LOOP;

    END IF;
  END Compute_Multi_Row_Attrs;

  PROCEDURE Propagate_SH_Temps
                  (p_header_item_id    IN NUMBER DEFAULT NULL
                  ,p_organization_id   IN NUMBER DEFAULT NULL
                  ,p_validate          IN VARCHAR2
                  ,p_halt_on_error     IN VARCHAR2
                  ,x_return_status     OUT NOCOPY VARCHAR2
                  ,x_error_message     OUT NOCOPY VARCHAR2
                  )
    IS
      l_sh_temp_min NUMBER;
      l_sh_temp_max NUMBER;
      l_uom_sh_temp_min VARCHAR2(30);
      l_uom_sh_temp_max VARCHAR2(30);

    BEGIN
      Bom_Rollup_Pub.WRITE_DEBUG_LOG (
          p_bo_identifier   => Bom_Rollup_Pub.G_BO_IDENTIFIER
        , p_message         => 'Propagate_SH_Temps called for Item '||p_header_item_id||'-'||p_organization_id||
                               ' with l_comp_attrs_map.count = '||Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl.COUNT);

      IF (Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl.COUNT = 0)
      THEN
        -- If it is not an each, reset weight attributes
        IF (Bom_Rollup_Pub.Get_Trade_Item_Unit_Descriptor(p_header_item_id, p_organization_id) <> 'BASE_UNIT_OR_EACH') THEN

          Bom_Rollup_Pub.Set_Parent_Attribute('STORAGE_HANDLING_TEMP_MIN',null);
          Bom_Rollup_Pub.Set_Parent_Attribute('STORAGE_HANDLING_TEMP_MAX',null);
          Bom_Rollup_Pub.Set_Parent_Attribute('UOM_STORAGE_HANDLING_TEMP_MIN',null);
          Bom_Rollup_Pub.Set_Parent_Attribute('UOM_STORAGE_HANDLING_TEMP_MAX',null);

        END IF;

        RETURN;
      END IF;

      -- Ensure that this item is UCCNet enabled
      IF (Bom_Rollup_Pub.Is_UCCNet_Enabled(p_header_item_id, p_organization_id) <> 'Y')
      THEN
        RETURN;
      END IF;

      IF p_validate = 'Y' THEN

        FOR cmp_index IN Bom_Rollup_Pub.l_Component_Seq_Tbl.FIRST..Bom_Rollup_Pub.l_Component_Seq_Tbl.LAST
        LOOP

          IF Bom_Rollup_Pub.l_Component_Seq_Tbl.EXISTS(cmp_index)
          THEN

            Bom_Gtin_Rules.Check_GTIN_Attributes
              ( p_assembly_item_id => p_header_item_id
              , p_organization_id => p_organization_id
              , p_component_item_id => Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_item_id
              , p_ignore_published => 'Y'
              , x_return_status => x_return_status
              , x_error_message => x_error_message
              );
            Bom_Rollup_Pub.WRITE_DEBUG_LOG(Bom_Rollup_Pub.G_BO_IDENTIFIER,
              'Check gtin attribs called for parent '||p_header_item_id||
              ' child '||Bom_Rollup_Pub.l_Component_Seq_Tbl(cmp_index).component_item_id||', returned '||
              x_return_status||':'||x_error_message);

            IF p_halt_on_error = 'Y' AND
               x_return_status IS NOT NULL AND
               x_return_status <> 'S'
            THEN

              -- error is passed up call stack in x_error_message
              RETURN;

            END IF;

          END IF;

        END LOOP;

      END IF;

      FOR cmp_index IN Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl.FIRST..Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl.LAST
      LOOP
        IF Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl.EXISTS(cmp_index)
        THEN
            IF Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl(cmp_index).attribute_name =
                 'STORAGE_HANDLING_TEMP_MIN'
            THEN
              l_sh_temp_min :=
                Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl(cmp_index).attribute_value;
              Bom_Rollup_Pub.Set_Parent_Attribute('STORAGE_HANDLING_TEMP_MIN',l_sh_temp_min);
            ELSIF Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl(cmp_index).attribute_name =
                    'STORAGE_HANDLING_TEMP_MAX'
            THEN
              l_sh_temp_max :=
                Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl(cmp_index).attribute_value;
              Bom_Rollup_Pub.Set_Parent_Attribute('STORAGE_HANDLING_TEMP_MAX',l_sh_temp_max);
            ELSIF Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl(cmp_index).attribute_name =
                    'UOM_STORAGE_HANDLING_TEMP_MIN'
            THEN
              l_uom_sh_temp_min :=
                Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl(cmp_index).attribute_value;
              Bom_Rollup_Pub.Set_Parent_Attribute('UOM_STORAGE_HANDLING_TEMP_MIN',l_uom_sh_temp_min);
            ELSIF Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl(cmp_index).attribute_name =
                    'UOM_STORAGE_HANDLING_TEMP_MAX'
            THEN
              l_uom_sh_temp_max :=
                Bom_Rollup_Pub.l_Component_Seq_Attrs_Tbl(cmp_index).attribute_value;
              Bom_Rollup_Pub.Set_Parent_Attribute('UOM_STORAGE_HANDLING_TEMP_MAX',l_uom_sh_temp_max);
            END IF;
        END IF; -- fetch a collection row only if one exists.
      END LOOP;

      --
      -- Set the attributes
      --
      Bom_Rollup_Pub.WRITE_DEBUG_LOG (
          p_bo_identifier   => Bom_Rollup_Pub.G_BO_IDENTIFIER
        , p_message         => 'Propagate_SH_Temps: setting temps to '||l_sh_temp_min||'('||l_uom_sh_temp_min||'), '||l_sh_temp_max||'('||l_uom_sh_temp_max||')');

/* Moved the setting of attributes for Heterogenous pack for null check
   the null check is being done while getting the attribute */

  EXCEPTION
    WHEN OTHERS THEN
      Bom_Rollup_Pub.WRITE_DEBUG_LOG (
          p_bo_identifier   => Bom_Rollup_Pub.G_BO_IDENTIFIER
        , p_message         => 'Propagate_SH_Temps: exception: '||sqlerrm);

  END Propagate_SH_Temps;

  PROCEDURE Set_User_Attributes
      ( p_item_id               IN NUMBER
      , p_organization_id       IN NUMBER
      , p_object_name           IN VARCHAR2
      , p_application_id        IN NUMBER
      , p_attr_group_type       IN VARCHAR2
      , p_attr_group_name       IN VARCHAR2
      , p_attr_name_value_pairs IN EGO_USER_ATTR_DATA_TABLE
      , x_return_status         OUT NOCOPY VARCHAR2
      , x_msg_count             OUT NOCOPY VARCHAR2
      , x_msg_data              OUT NOCOPY VARCHAR2
      )
  IS
    l_pk_columns EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_class_code EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_data_level EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_item_catalog_group_id  NUMBER;
    l_error_code NUMBER;

    --Cursor for creating the classification code
    CURSOR get_classification_code
    IS
        SELECT
            item_catalog_group_id
        FROM
            mtl_system_items_b
        WHERE
            inventory_item_id = p_item_id
        AND organization_id = p_organization_id;

  BEGIN

    l_pk_columns := EGO_COL_NAME_VALUE_PAIR_ARRAY
      ( EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', p_item_id)
      , EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', p_organization_id)
      );

    FOR c1 IN get_classification_code
    LOOP
        l_item_catalog_group_id := c1.item_catalog_group_id;
    END LOOP;

    l_class_code := EGO_COL_NAME_VALUE_PAIR_ARRAY
        (EGO_COL_NAME_VALUE_PAIR_OBJ('ITEM_CATALOG_GROUP_ID', to_char(l_item_catalog_group_id)));

    l_data_level := EGO_COL_NAME_VALUE_PAIR_ARRAY
        (EGO_COL_NAME_VALUE_PAIR_OBJ('DATA_LEVEL', 'EGO_ITEM'));

    EGO_USER_ATTRS_DATA_PVT.Perform_DML_On_Row(
        p_api_version => 1.0
      , p_object_name => 'EGO_ITEM'
      , p_application_id => p_application_id
      , p_attr_group_type => p_attr_group_type
      , p_attr_group_name => p_attr_group_name
      , p_pk_column_name_value_pairs => l_pk_columns
      , p_class_code_name_value_pairs => l_class_code
--      , p_data_level_name_value_pairs => l_data_level
      , p_data_level_name_value_pairs => Bom_Rollup_Pub.g_data_level_name_value_pairs
      , p_attr_name_value_pairs => p_attr_name_value_pairs
 -- this is very important, because otherwise, updates would trigger rollups, creating an infinite loop
      , p_bulkload_flag => FND_API.G_TRUE
      , x_return_status => x_return_status
      , x_errorcode => l_error_code
      , x_msg_count => x_msg_count
      , x_msg_data => x_msg_data
      );

    Bom_Rollup_Pub.WRITE_DEBUG_LOG (
        p_bo_identifier   => Bom_Rollup_Pub.G_BO_IDENTIFIER
      , p_message         => 'Set_User_Attribute: returned with '||x_return_status||' code '||l_error_code||' cnt '||x_msg_count||' data '||x_msg_data);

  EXCEPTION
    WHEN OTHERS THEN

      Bom_Rollup_Pub.WRITE_DEBUG_LOG (
          p_bo_identifier   => Bom_Rollup_Pub.G_BO_IDENTIFIER
        , p_message         => 'Set_User_Attribute: exception: '||sqlerrm);

  END Set_User_Attributes;

  PROCEDURE Get_Attribute_Value
      ( p_attr_name    IN VARCHAR2
      , x_attr_value   OUT NOCOPY VARCHAR2
      , x_found        OUT NOCOPY BOOLEAN
      , p_header_item_map IN BOOLEAN := TRUE
      )
  IS
    l_attrs_map Bom_Rollup_Pub.Attribute_Map;
    l_attr_value varchar2(1000) := null;
  BEGIN
    x_found := FALSE;

    IF p_header_item_map THEN
      l_attrs_map := Bom_Rollup_Pub.l_Header_Attrs_Map;
    ELSE
      l_attrs_map := Bom_Rollup_Pub.l_Top_Item_Attrs_Map;
    END IF;

    IF l_attrs_map IS NULL OR
       NOT l_attrs_map.COUNT > 0
    THEN
      Bom_Rollup_Pub.WRITE_DEBUG_LOG(Bom_Rollup_Pub.G_BO_IDENTIFIER,'Get_Attribute_Value: map is null/empty, returning...');
      RETURN;
    END IF;

    FOR i IN l_attrs_map.FIRST .. l_attrs_map.LAST
    LOOP
      IF l_attrs_map.EXISTS(i) THEN
        IF (l_attrs_map(i).attribute_name = p_attr_name)
        THEN
          if (l_attrs_map(i).attribute_value is not null) then
            l_attr_value := l_attrs_map(i).attribute_value;
          end if;
          x_found := TRUE;
    /* Storing the attrbute value in a local variable so that
       heterogenous packs are supported for null value
       If we have to do an average between values this is where we should be doing
       as it is a single change for all attributes
     */

          --x_attr_value := l_attrs_map(i).attribute_value;
          --RETURN;
          Bom_Rollup_Pub.WRITE_DEBUG_LOG(Bom_Rollup_Pub.G_BO_IDENTIFIER,
            'The attribute value for ' || p_attr_name || ' is ' || l_attr_value );
        END IF;
      END IF;
    END LOOP;

    /*if the attribute was found we will set it here */
    if (x_found) then
      x_attr_value := l_attr_value;
    end if;

  END Get_Attribute_Value;

  PROCEDURE Get_Top_Item_Attribute_Value
      ( p_attr_name  IN  VARCHAR2
      , x_attr_value OUT NOCOPY VARCHAR2
      , x_found      OUT NOCOPY BOOLEAN
      )
  IS
  BEGIN
    Get_Attribute_Value(p_attr_name, x_attr_value, x_found, TRUE);
  END Get_Top_Item_Attribute_Value;

  PROCEDURE Set_Net_Weight
      ( p_Header_Item_Id    IN  NUMBER
      , p_Organization_Id   IN  NUMBER
      , p_Header_Attrs_Flag IN  VARCHAR2
      , x_return_status     OUT NOCOPY VARCHAR2
      , x_msg_count         OUT NOCOPY NUMBER
      , x_msg_data          OUT NOCOPY VARCHAR2
      )
  IS
    l_unit_weight VARCHAR2(100) := NULL;
    l_net_weight_uom VARCHAR2(30) := NULL;
    l_unit_weight_found BOOLEAN;
    l_net_weight_uom_found BOOLEAN;
    l_use_header_attrs_map BOOLEAN := TRUE;

    l_attr_name VARCHAR2(30);
    l_errorcode NUMBER;
  BEGIN
    Bom_Rollup_Pub.WRITE_DEBUG_LOG(Bom_Rollup_Pub.G_BO_IDENTIFIER,'Set_Net_Weight: starting '||p_header_attrs_flag);

    IF p_header_attrs_flag <> 'Y' THEN
      l_use_header_attrs_map := FALSE;
    END IF;

    Get_Attribute_Value('UNIT_WEIGHT', l_unit_weight, l_unit_weight_found, l_use_header_attrs_map);
    Get_Attribute_Value('NET_WEIGHT_UOM', l_net_weight_uom, l_net_weight_uom_found, l_use_header_attrs_map);

    IF l_unit_weight_found THEN

      l_attr_name := 'Unit_Weight';

    ELSIF l_net_weight_uom_found THEN

      l_attr_name := 'Weight_Uom_Code';

    END IF;

    IF l_unit_weight_found OR l_net_weight_uom_found THEN

      EGO_GTIN_PVT.Update_Attribute
        ( p_inventory_item_id  => p_header_item_id
        , p_organization_id    => p_organization_id
        , p_attr_name          => l_attr_name
        , p_attr_new_value_num => to_number(l_unit_weight)
        , p_attr_new_value_uom => l_net_weight_uom
        , x_return_status      => x_return_status
        , x_errorcode          => l_errorcode
        , x_msg_count          => x_msg_count
        , x_msg_data           => x_msg_data
        );

    END IF;

  EXCEPTION
    WHEN OTHERS THEN

      Bom_Rollup_Pub.WRITE_DEBUG_LOG (
          p_bo_identifier   => Bom_Rollup_Pub.G_BO_IDENTIFIER
        , p_message         => 'Set_Net_Weight: exception: '||sqlerrm);

  END Set_Net_Weight;

  PROCEDURE Set_Private_Flag
      ( p_Header_Item_Id    IN  NUMBER
      , p_Organization_Id   IN  NUMBER
      , p_Header_Attrs_Flag IN  VARCHAR2
      , x_return_status     OUT NOCOPY VARCHAR2
      , x_msg_count         OUT NOCOPY NUMBER
      , x_msg_data          OUT NOCOPY VARCHAR2
      )
  IS
    l_private_flag VARCHAR2(1);
    l_private_flag_found BOOLEAN;
    l_attr_values EGO_USER_ATTR_DATA_TABLE := NULL;
    l_use_header_attrs_map BOOLEAN := TRUE;
    l_errorcode NUMBER;
  BEGIN

    Bom_Rollup_Pub.WRITE_DEBUG_LOG(Bom_Rollup_Pub.G_BO_IDENTIFIER,'Set_Private_Flag: starting '||p_header_attrs_flag);

    IF p_header_attrs_flag <> 'Y' THEN
      l_use_header_attrs_map := FALSE;
    END IF;

    Get_Attribute_Value('IS_TRADE_ITEM_INFO_PRIVATE', l_private_flag, l_private_flag_found, l_use_header_attrs_map);

    IF l_private_flag_found THEN

      EGO_GTIN_PVT.Update_Attribute
        ( p_inventory_item_id  => p_header_item_id
        , p_organization_id    => p_organization_id
        , p_attr_name          => 'Is_Trade_Item_Info_Private'
        , p_attr_group_type    => 'EGO_ITEM_GTIN_ATTRS'
        , p_attr_group_name    => 'Gtin_Unit_Indicator'
        , p_attr_new_value_str => l_private_flag
        , x_return_status      => x_return_status
        , x_errorcode          => l_errorcode
        , x_msg_count          => x_msg_count
        , x_msg_data           => x_msg_data
        );

    END IF;

    Bom_Rollup_Pub.WRITE_DEBUG_LOG(Bom_Rollup_Pub.G_BO_IDENTIFIER,'Set_Private_Flag: done with ret '||x_return_status);

  EXCEPTION
    WHEN OTHERS THEN

      Bom_Rollup_Pub.WRITE_DEBUG_LOG (
          p_bo_identifier   => Bom_Rollup_Pub.G_BO_IDENTIFIER
        , p_message         => 'Set_Net_Weight: exception: '||sqlerrm);

  END Set_Private_Flag;

  PROCEDURE Set_Brand_Info
      ( p_Header_Item_Id    IN  NUMBER
      , p_Organization_Id   IN  NUMBER
      , p_Header_Attrs_Flag IN  VARCHAR2
      , x_return_status     OUT NOCOPY VARCHAR2
      , x_msg_count         OUT NOCOPY NUMBER
      , x_msg_data          OUT NOCOPY VARCHAR2
      )
  IS
    l_brand_owner_name VARCHAR2(35);
    l_brand_owner_gln  VARCHAR2(35);
    l_functional_name  VARCHAR2(35);
    l_sub_brand        VARCHAR2(35);
    l_found_bon BOOLEAN := FALSE;
    l_found_bog BOOLEAN := FALSE;
    l_found_fn  BOOLEAN := FALSE;
    l_found_sb  BOOLEAN := FALSE;
    l_use_header_attrs_map BOOLEAN := TRUE;
    l_errorcode NUMBER;
  BEGIN

    Bom_Rollup_Pub.WRITE_DEBUG_LOG(Bom_Rollup_Pub.G_BO_IDENTIFIER,'Set_Brand_Info: starting '||p_header_attrs_flag);

    IF p_header_attrs_flag <> 'Y' THEN
      l_use_header_attrs_map := FALSE;
    END IF;

    -- for performance, we might want to expand this loop,
    --  especially if the map is long
    Get_Attribute_Value('BRAND_OWNER_NAME', l_brand_owner_name, l_found_bon, l_use_header_attrs_map);
    Get_Attribute_Value('BRAND_OWNER_GLN', l_brand_owner_gln, l_found_bog, l_use_header_attrs_map);
    Get_Attribute_Value('FUNCTIONAL_NAME', l_functional_name, l_found_fn, l_use_header_attrs_map);
    Get_Attribute_Value('SUB_BRAND', l_sub_brand, l_found_sb, l_use_header_attrs_map);

    IF l_found_bon OR l_found_bog OR l_found_fn OR l_found_sb THEN

      IF l_found_bon THEN

        EGO_GTIN_PVT.Update_Attribute
          ( p_inventory_item_id  => p_header_item_id
          , p_organization_id    => p_organization_id
          , p_attr_name          => 'Retail_Brand_Owner_Name'
          , p_attr_group_type    => 'EGO_ITEM_GTIN_ATTRS'
          , p_attr_group_name    => 'Trade_Item_Description'
          , p_attr_new_value_str => l_brand_owner_name
          , x_return_status      => x_return_status
          , x_errorcode          => l_errorcode
          , x_msg_count          => x_msg_count
          , x_msg_data           => x_msg_data
          );

      END IF;

      IF l_found_bog THEN

        EGO_GTIN_PVT.Update_Attribute
          ( p_inventory_item_id  => p_header_item_id
          , p_organization_id    => p_organization_id
          , p_attr_name          => 'Retail_Brand_Owner_Gln'
          , p_attr_group_type    => 'EGO_ITEM_GTIN_ATTRS'
          , p_attr_group_name    => 'Trade_Item_Description'
          , p_attr_new_value_str => l_brand_owner_gln
          , x_return_status      => x_return_status
          , x_errorcode          => l_errorcode
          , x_msg_count          => x_msg_count
          , x_msg_data           => x_msg_data
          );

      END IF;

      IF l_found_fn THEN

        EGO_GTIN_PVT.Update_Attribute
          ( p_inventory_item_id  => p_header_item_id
          , p_organization_id    => p_organization_id
          , p_attr_name          => 'Functional_Name'
          , p_attr_group_type    => 'EGO_ITEM_GTIN_ATTRS'
          , p_attr_group_name    => 'Trade_Item_Description'
          , p_attr_new_value_str => l_functional_name
          , x_return_status      => x_return_status
          , x_errorcode          => l_errorcode
          , x_msg_count          => x_msg_count
          , x_msg_data           => x_msg_data
          );

      END IF;

      IF l_found_sb THEN

        EGO_GTIN_PVT.Update_Attribute
          ( p_inventory_item_id  => p_header_item_id
          , p_organization_id    => p_organization_id
          , p_attr_name          => 'Sub_Brand'
          , p_attr_group_type    => 'EGO_ITEM_GTIN_ATTRS'
          , p_attr_group_name    => 'Trade_Item_Description'
          , p_attr_new_value_str => l_sub_brand
          , x_return_status      => x_return_status
          , x_errorcode          => l_errorcode
          , x_msg_count          => x_msg_count
          , x_msg_data           => x_msg_data
          );

      END IF;

    END IF;

    Bom_Rollup_Pub.WRITE_DEBUG_LOG(Bom_Rollup_Pub.G_BO_IDENTIFIER,'Set_Brand_Info: done with ret '||x_return_status);

  EXCEPTION
    WHEN OTHERS THEN

      Bom_Rollup_Pub.WRITE_DEBUG_LOG (
          p_bo_identifier   => Bom_Rollup_Pub.G_BO_IDENTIFIER
        , p_message         => 'Set_Brand_Info: exception: '||sqlerrm);

  END Set_Brand_Info;

  PROCEDURE Set_Top_GTIN_Flag
      ( p_Header_Item_Id    IN  NUMBER
      , p_Organization_Id   IN  NUMBER
      , p_Header_Attrs_Flag IN  VARCHAR2
      , x_return_status     OUT NOCOPY VARCHAR2
      , x_msg_count         OUT NOCOPY NUMBER
      , x_msg_data          OUT NOCOPY VARCHAR2
      )
  IS
    l_top_gtin_flag VARCHAR2(1) := '';
    l_top_gtin_flag_found BOOLEAN;
    l_use_header_attrs_map BOOLEAN := TRUE;
    l_errorcode NUMBER;
  BEGIN
    -- TODO: check with deena

    Bom_Rollup_Pub.WRITE_DEBUG_LOG(Bom_Rollup_Pub.G_BO_IDENTIFIER,'Set_Top_gtin_Flag: starting '||p_header_attrs_flag);

    IF p_header_attrs_flag <> 'Y' THEN
      l_use_header_attrs_map := FALSE;
    END IF;

    IF Bom_Rollup_Pub.Get_Top_Item_Id = p_header_item_id AND
       Bom_Rollup_Pub.Get_Top_Organization_Id = p_organization_id
    THEN

      Get_Attribute_Value(
          'TOP_GTIN'
        , l_top_gtin_flag
        , l_top_gtin_flag_found
        , l_use_header_attrs_map);

      IF l_top_gtin_flag_found THEN

        Bom_Rollup_Pub.WRITE_DEBUG_LOG(Bom_Rollup_Pub.G_BO_IDENTIFIER,'Set_Top_gtin_Flag: calling EGO');

        EGO_GTIN_PVT.Update_Attribute
          ( p_inventory_item_id  => p_header_item_id
          , p_organization_id    => p_organization_id
          , p_attr_name          => 'Top_Gtin'
          , p_attr_new_value_str => l_top_gtin_flag
          , x_return_status      => x_return_status
          , x_errorcode          => l_errorcode
          , x_msg_count          => x_msg_count
          , x_msg_data           => x_msg_data
          );

      END IF;

    END IF;

    Bom_Rollup_Pub.WRITE_DEBUG_LOG(Bom_Rollup_Pub.G_BO_IDENTIFIER,'Set_Top_Gtin_Flag: done with ret '||x_return_status);

  EXCEPTION
    WHEN OTHERS THEN

      Bom_Rollup_Pub.WRITE_DEBUG_LOG (
          p_bo_identifier   => Bom_Rollup_Pub.G_BO_IDENTIFIER
        , p_message         => 'Set_Top_Gtin_Flag: exception: '||sqlerrm);

  END Set_Top_GTIN_Flag;

  PROCEDURE Set_Multirow_Attributes
      ( p_Header_Item_Id    IN  NUMBER
      , p_Organization_Id   IN  NUMBER
      , p_Header_Attrs_Flag IN  VARCHAR2
      , x_return_status     OUT NOCOPY VARCHAR2
      , x_msg_count         OUT NOCOPY NUMBER
      , x_msg_data          OUT NOCOPY VARCHAR2
      )
  IS
  BEGIN
    NULL;
  END Set_Multirow_Attributes;

  PROCEDURE Set_SH_Temps
      ( p_Header_Item_Id    IN  NUMBER
      , p_Organization_Id   IN  NUMBER
      , p_Header_Attrs_Flag IN  VARCHAR2
      , x_return_status     OUT NOCOPY VARCHAR2
      , x_msg_count         OUT NOCOPY NUMBER
      , x_msg_data          OUT NOCOPY VARCHAR2
      )
  IS
    l_sh_temp_min NUMBER(3);
    l_sh_temp_max NUMBER(3);
    l_sh_temp_min_str VARCHAR2(100);
    l_sh_temp_max_str VARCHAR2(100);
    l_sh_temp_min_uom VARCHAR2(3);
    l_sh_temp_max_uom VARCHAR2(3);
    l_found_sh_temp_min BOOLEAN := FALSE;
    l_found_sh_temp_max BOOLEAN := FALSE;
    l_found_sh_temp_min_uom BOOLEAN := FALSE;
    l_found_sh_temp_max_uom BOOLEAN := FALSE;
    l_use_header_attrs_map BOOLEAN := TRUE;
    l_errorcode NUMBER;
  BEGIN

    Bom_Rollup_Pub.WRITE_DEBUG_LOG(Bom_Rollup_Pub.G_BO_IDENTIFIER,'Set_SH_Temps: starting '||p_header_attrs_flag);

    IF p_header_attrs_flag <> 'Y' THEN
      l_use_header_attrs_map := FALSE;
    END IF;

    -- for performance, we might want to expand this loop,
    --  especially if the map is long
    Get_Attribute_Value('STORAGE_HANDLING_TEMP_MIN', l_sh_temp_min_str, l_found_sh_temp_min, l_use_header_attrs_map);
    Get_Attribute_Value('STORAGE_HANDLING_TEMP_MAX', l_sh_temp_max_str, l_found_sh_temp_max, l_use_header_attrs_map);
    Get_Attribute_Value('UOM_STORAGE_HANDLING_TEMP_MIN', l_sh_temp_min_uom, l_found_sh_temp_min_uom, l_use_header_attrs_map);
    Get_Attribute_Value('UOM_STORAGE_HANDLING_TEMP_MAX', l_sh_temp_max_uom, l_found_sh_temp_max_uom, l_use_header_attrs_map);

    IF l_found_sh_temp_min
      OR l_found_sh_temp_max
      OR l_found_sh_temp_min_uom
      OR l_found_sh_temp_max_uom
    THEN

      IF l_found_sh_temp_min THEN

        l_sh_temp_min := to_number(l_sh_temp_min_str);

        EGO_GTIN_PVT.Update_Attribute
          ( p_inventory_item_id  => p_header_item_id
          , p_organization_id    => p_organization_id
          , p_attr_name          => 'Uccnet_Storage_Temp_Min'
          , p_attr_group_type    => 'EGO_ITEM_GTIN_ATTRS'
          , p_attr_group_name    => 'Temperature_Information'
          , p_attr_new_value_num => l_sh_temp_min
          , x_return_status      => x_return_status
          , x_errorcode          => l_errorcode
          , x_msg_count          => x_msg_count
          , x_msg_data           => x_msg_data
          );

      END IF;

      IF l_found_sh_temp_max THEN

        l_sh_temp_max := to_number(l_sh_temp_max_str);

        EGO_GTIN_PVT.Update_Attribute
          ( p_inventory_item_id  => p_header_item_id
          , p_organization_id    => p_organization_id
          , p_attr_name          => 'Uccnet_Storage_Temp_Max'
          , p_attr_group_type    => 'EGO_ITEM_GTIN_ATTRS'
          , p_attr_group_name    => 'Temperature_Information'
          , p_attr_new_value_num => l_sh_temp_max
          , x_return_status      => x_return_status
          , x_errorcode          => l_errorcode
          , x_msg_count          => x_msg_count
          , x_msg_data           => x_msg_data
          );

      END IF;

      IF l_found_sh_temp_min_uom THEN

        EGO_GTIN_PVT.Update_Attribute
          ( p_inventory_item_id  => p_header_item_id
          , p_organization_id    => p_organization_id
          , p_attr_name          => 'Uom_Storage_Handling_Temp_Min'
          , p_attr_group_type    => 'EGO_ITEM_GTIN_ATTRS'
          , p_attr_group_name    => 'Temperature_Information'
          , p_attr_new_value_str => l_sh_temp_min_uom
          , x_return_status      => x_return_status
          , x_errorcode          => l_errorcode
          , x_msg_count          => x_msg_count
          , x_msg_data           => x_msg_data
          );

      END IF;

      IF l_found_sh_temp_max_uom THEN

        EGO_GTIN_PVT.Update_Attribute
          ( p_inventory_item_id  => p_header_item_id
          , p_organization_id    => p_organization_id
          , p_attr_name          => 'Uom_Storage_Handling_Temp_Max'
          , p_attr_group_type    => 'EGO_ITEM_GTIN_ATTRS'
          , p_attr_group_name    => 'Temperature_Information'
          , p_attr_new_value_str => l_sh_temp_max_uom
          , x_return_status      => x_return_status
          , x_errorcode          => l_errorcode
          , x_msg_count          => x_msg_count
          , x_msg_data           => x_msg_data
          );

      END IF;

    END IF;

    Bom_Rollup_Pub.WRITE_DEBUG_LOG(Bom_Rollup_Pub.G_BO_IDENTIFIER,'Set_SH_Temps: done with ret '||x_return_status);

  END Set_SH_Temps;

END Bom_Compute_Functions;

/

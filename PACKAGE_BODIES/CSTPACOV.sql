--------------------------------------------------------
--  DDL for Package Body CSTPACOV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPACOV" AS
/* $Header: CSTACOVB.pls 120.0.12010000.3 2008/11/13 12:17:35 smsasidh ship $ */

PROCEDURE ins_overhead(
   I_INVENTORY_ITEM_ID    IN  NUMBER,
   I_ORGANIZATION_ID      IN  NUMBER,
   I_LAST_UPDATED_BY      IN  NUMBER,
   I_COST_TYPE_ID         IN  NUMBER,
   I_ITEM_TYPE            IN  NUMBER,
   I_LOT_SIZE             IN  NUMBER,
   I_SHRINKAGE_RATE       IN  NUMBER,

   O_RETURN_CODE          OUT NOCOPY NUMBER,
   O_RETURN_ERR           OUT NOCOPY VARCHAR2) IS

   p_location             NUMBER;
   p_dummy                NUMBER;
   p_category_set_id      NUMBER;
   p_category_id          NUMBER;

BEGIN

          O_RETURN_ERR := ' ';

          BEGIN
             SELECT d.category_set_id, c.category_id
             INTO   p_category_set_id,
                    p_category_id
             FROM   mtl_default_category_sets d,
                    mtl_item_categories c
             WHERE  d.functional_area_id = 5
             AND    c.category_set_id = d.category_set_id
             AND    c.inventory_item_id = I_INVENTORY_ITEM_ID
             AND    c.organization_id = I_ORGANIZATION_ID;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
               O_RETURN_CODE := SQLCODE;
               O_RETURN_ERR := 'CSTPACOV(1):' || substrb(SQLERRM,1,68);
               RETURN;
             WHEN OTHERS THEN
               O_RETURN_CODE := SQLCODE;
               O_RETURN_ERR := 'CSTPACOV(1):' || substrb(SQLERRM,1,68);
               RETURN;
          END;

          p_location := 10;

          /*  Added for bug 7237799 */
          IF I_COST_TYPE_ID <> 1 THEN

             p_location := 12;

             DELETE FROM cst_item_cost_details
             WHERE inventory_item_id = I_INVENTORY_ITEM_ID
             AND   organization_id   = I_ORGANIZATION_ID
             AND   cost_type_id      = I_COST_TYPE_ID;

             DELETE FROM cst_item_costs
             WHERE inventory_item_id = I_INVENTORY_ITEM_ID
             AND   organization_id   = I_ORGANIZATION_ID
             AND   cost_type_id      = I_COST_TYPE_ID;

          END IF;

          p_location := 15;

          INSERT INTO cst_item_cost_details
          (inventory_item_id,
           organization_id,
           cost_type_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           level_type,
           resource_id,
           resource_rate,
           activity_id,
           basis_type,
           item_units,
           activity_units,
           usage_rate_or_amount,
           basis_factor,
           net_yield_or_shrinkage_factor,
           item_cost,
           rollup_source_type,
           cost_element_id
          )
      SELECT
           I_INVENTORY_ITEM_ID,
           I_ORGANIZATION_ID,
           I_COST_TYPE_ID,
           SYSDATE,
           I_LAST_UPDATED_BY,
           SYSDATE,
           I_LAST_UPDATED_BY,
           1,
           material_overhead_id,
           1,
           activity_id,
           basis_type,
           item_units,
           activity_units,
           usage_rate_or_amount,
           DECODE(basis_type, 1,1,
                          2,1 / NVL(I_LOT_SIZE,1),
                          3,0,
                          4,0,
                          5,0,
                          6,NVL(activity_units,0)/NVL(item_units,1),
                                0),
           DECODE(NVL(I_SHRINKAGE_RATE,-9),-9,1,
                            1 / (1 - I_SHRINKAGE_RATE)),
           usage_rate_or_amount *
             DECODE(basis_type, 1,1,
                          2,1 / NVL(I_LOT_SIZE,1),
                          3,0,
                          4,0,
                          5,0,
                          6,NVL(activity_units,0)/NVL(item_units,1),
                               0) *
           DECODE(NVL(I_SHRINKAGE_RATE,-9),-9,1,
                            1 / (1 - I_SHRINKAGE_RATE)),
           1,  /* rollup soure type = user defined */
           br.cost_element_id
      FROM  cst_item_overhead_defaults ciod,
          bom_resources br
      WHERE NOT EXISTS           /* Don't insert if item already exists */
           (SELECT /*+ INDEX(cicd CST_ITEM_COST_DETAILS_N1) */ -- Added for bug 6908147
           'X'
            FROM  cst_item_cost_details cicd
            WHERE inventory_item_id = I_INVENTORY_ITEM_ID
            AND   organization_id   = I_ORGANIZATION_ID
            AND   cost_type_id      = I_COST_TYPE_ID)
      AND ciod.organization_id = I_ORGANIZATION_ID
      and br.resource_id = material_overhead_id
      AND   (
         (    category_id is NULL
          AND item_type = 3 /* all items */
          AND NOT EXISTS
          (SELECT 'X'
           FROM   cst_item_overhead_defaults ciod2
           WHERE  category_set_id = p_category_set_id
           AND    organization_id = I_ORGANIZATION_ID
           AND    category_id = p_category_id
           AND    ciod2.material_overhead_id = ciod.material_overhead_id
           AND    item_type = I_ITEM_TYPE)
          AND NOT EXISTS
          (SELECT 'X'
           FROM   cst_item_overhead_defaults ciod2
           WHERE  category_set_id = p_category_set_id
           AND    organization_id = I_ORGANIZATION_ID
           AND    category_id = p_category_id
           AND    ciod2.material_overhead_id = ciod.material_overhead_id
           AND    item_type = 3)
          AND NOT EXISTS
          (SELECT 'X'
           FROM   cst_item_overhead_defaults ciod2
           WHERE  category_id is NULL
           AND    organization_id = I_ORGANIZATION_ID
           AND    ciod2.material_overhead_id = ciod.material_overhead_id
           AND    item_type = I_ITEM_TYPE)
         )
         OR
         (    category_id is NULL
          AND item_type = I_ITEM_TYPE
          AND NOT EXISTS
          (SELECT 'X'
           FROM   cst_item_overhead_defaults ciod2
           WHERE  category_set_id = p_category_set_id
           AND    organization_id = I_ORGANIZATION_ID
           AND    category_id = p_category_id
           AND    ciod2.material_overhead_id = ciod.material_overhead_id
           AND    item_type = I_ITEM_TYPE)
          AND NOT EXISTS
          (SELECT 'X'
           FROM   cst_item_overhead_defaults ciod2
           WHERE  category_set_id = p_category_set_id
           AND    organization_id = I_ORGANIZATION_ID
           AND    category_id = p_category_id
           AND    ciod2.material_overhead_id = ciod.material_overhead_id
           AND    item_type = 3) /* all items */
         )
         OR
         (    category_set_id = p_category_set_id
          AND category_id = p_category_id
          AND item_type = 3 /* all items */
          AND NOT EXISTS
          (SELECT 'X'
           FROM   cst_item_overhead_defaults ciod2
           WHERE  category_set_id = p_category_set_id
           AND    organization_id = I_ORGANIZATION_ID
           AND    category_id = p_category_id
           AND    ciod2.material_overhead_id = ciod.material_overhead_id
           AND    item_type = I_ITEM_TYPE)
         )
         OR
         (    category_set_id = p_category_set_id
          AND category_id = p_category_id
          AND item_type = I_ITEM_TYPE
         )
     );

     /* Update CIC only if the item exists in CICD. */
     p_location := 20;

     select /*+ INDEX (CICD CST_ITEM_COST_DETAILS_N1) */ -- Added for bug 6908147
     count(1)
     into p_dummy
     from cst_item_cost_details  cicd
     where inventory_item_id = I_INVENTORY_ITEM_ID
     AND   organization_id   = I_ORGANIZATION_ID
     AND   cost_type_id      = I_COST_TYPE_ID
     AND   rownum <2; -- Added for bug 6908147

     IF p_dummy > 0 THEN

        p_location := 30;

       IF I_COST_TYPE_ID <> 1 THEN

          p_location := 40;

          INSERT INTO cst_item_costs
             (
                inventory_item_id,
                organization_id,
                cost_type_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                defaulted_flag,
                shrinkage_rate,
                lot_size,
                based_on_rollup_flag,
                inventory_asset_flag)
          VALUES (I_INVENTORY_ITEM_ID,
                I_ORGANIZATION_ID,
                I_COST_TYPE_ID,
                sysdate,
                I_LAST_UPDATED_BY,
                sysdate,
                I_LAST_UPDATED_BY,
                2,
                0,
                I_LOT_SIZE,
                I_ITEM_TYPE,
                1);

        END IF;

        UPDATE cst_item_costs
        SET (
              tl_material, tl_material_overhead,
              tl_resource, tl_outside_processing,
              tl_overhead,
              material_cost, material_overhead_cost,
              resource_cost, outside_processing_cost,
              overhead_cost,
              tl_item_cost,
              item_cost,
              unburdened_cost,
              burden_cost,
              last_update_date,
              last_updated_by
        ) = (
            SELECT tl_material, tl_material_overhead,
                   tl_resource, tl_outside_processing,
                   tl_overhead,
                   material_cost, material_overhead_cost,
                   resource_cost, outside_processing_cost,
                   overhead_cost,
                   tl_item_cost,
                   item_cost,
                   unburdened_cost,
                   burden_cost,
                   sysdate,
                   I_LAST_UPDATED_BY
            FROM   cst_item_costs_view
            WHERE  inventory_item_id = I_INVENTORY_ITEM_ID
            AND    organization_id = I_ORGANIZATION_ID
            AND    cost_type_id = I_COST_TYPE_ID
        )
        WHERE inventory_item_id = I_INVENTORY_ITEM_ID
        AND   organization_id = I_ORGANIZATION_ID
        AND   cost_type_id = I_COST_TYPE_ID;

    END IF;

    O_RETURN_CODE := 0;
    RETURN;

END ins_overhead;

END CSTPACOV;


/

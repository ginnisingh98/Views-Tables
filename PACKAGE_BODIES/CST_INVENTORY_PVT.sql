--------------------------------------------------------
--  DDL for Package Body CST_INVENTORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_INVENTORY_PVT" AS
/* $Header: CSTVIVTB.pls 120.20.12010000.5 2009/05/12 02:00:29 ipineda ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'CST_Inventory_PVT';

  g_mrp_debug VARCHAR2(1) := NVL(FND_PROFILE.Value('MRP_DEBUG'),'N');


  PROCEDURE log(
    message       IN VARCHAR2,
    newline       IN BOOLEAN DEFAULT TRUE) IS
  BEGIN
    IF  g_mrp_debug = 'N' THEN
      RETURN;
    END IF;
    IF  g_mrp_debug = 'Y' THEN
      IF (newline) THEN
        FND_FILE.put_line(fnd_file.log,message);
      ELSE
        FND_FILE.put(fnd_file.log,message);
      END IF;
    END IF;
  END log;

  PROCEDURE ins_cst_inv_cost_temp(p_rec   IN cst_inv_cost_temp%ROWTYPE) IS
  BEGIN
       INSERT INTO cst_inv_cost_temp(
                     organization_id,
                     inventory_item_id,
                     cost_type_id,
                     cost_source,
                     inventory_asset_flag,
                     item_cost,
                     material_cost,
                     material_overhead_cost,
                     resource_cost,
                     outside_processing_cost,
                     overhead_cost
                   ) VALUES (
                     p_rec.organization_id,
                     p_rec.inventory_item_id,
                     p_rec.cost_type_id,
                     p_rec.cost_source,
                     p_rec.inventory_asset_flag,
                     p_rec.item_cost,
                     p_rec.material_cost,
                     p_rec.material_overhead_cost,
                     p_rec.resource_cost,
                     p_rec.outside_processing_cost,
                     p_rec.overhead_cost);
   END ins_cst_inv_cost_temp;


  PROCEDURE Populate_ItemList(
    p_api_version          IN         NUMBER,
    p_organization_id      IN         NUMBER,
    p_cost_type_id         IN         NUMBER,
    p_item_from            IN         VARCHAR2,
    p_item_to              IN         VARCHAR2,
    p_category_set_id      IN         NUMBER,
    p_category_from        IN         VARCHAR2,
    p_category_to          IN         VARCHAR2,
    p_zero_cost_only       IN         NUMBER,
    p_expense_item         IN         NUMBER,
    p_cost_enabled_only    IN         NUMBER,
    p_one_time_item        IN         NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2
  )
  IS
    l_api_name CONSTANT VARCHAR2(30) := 'Populate_ItemList';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_level_threshold NUMBER;
    l_stmt_num NUMBER := 0;
    l_def_cost_type_id NUMBER;
    l_cost_org_id NUMBER;
    l_primary_cost_method NUMBER;
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Populate_ItemList_PVT;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call(
             p_current_version_number => l_api_version,
             p_caller_version_number => p_api_version,
             p_api_name => l_api_name,
             p_pkg_name => G_PKG_NAME
           )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check for message level threshold
    l_msg_level_threshold := FND_PROFILE.Value('FND_AS_MSG_LEVEL_THRESHOLD');

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => SUBSTR(
                          l_stmt_num||':'||
                          p_organization_id||','||
                          p_cost_type_id||','||
                          p_item_from||','||
                          p_item_to||','||
                          p_category_set_id||','||
                          p_category_from||','||
                          p_category_to||','||
                          p_zero_cost_only||','||
                          p_expense_item||','||
        p_cost_enabled_only||','||
        p_one_time_item,
                          1,
                          240
                        )
      );
    END IF;

    -- Get the cost organization and the primary cost method
    l_stmt_num := 10;
    SELECT cost_organization_id,
           primary_cost_method
    INTO   l_cost_org_id,
           l_primary_cost_method
    FROM   mtl_parameters
    WHERE  organization_id = p_organization_id;

    -- Get the default cost type
    l_stmt_num := 15;
    SELECT default_cost_type_id
    INTO   l_def_cost_type_id
    FROM   cst_cost_types
    WHERE  cost_type_id = NVL(p_cost_type_id, l_primary_cost_method);

    -- Populate item list
    -- Key flexfield are not compared at the segment level.
    -- Doing so would require dynamic SQL, which is hard to tune and
    -- maintain. Instead, concatenated segment level comparison is
    -- used. This approach is commonly used across APPS.
IF (p_cost_enabled_only = 1) then
      -- Populate items for Inventory reports
      -- (All Inv Value, Inv Value, Elem Inv Value, etc.)
      -- Only costing-enabled items are included.

    l_stmt_num := 17;

    /* Split the query into two for performance gain */
    IF (p_category_from IS NULL AND p_category_to IS NULL ) THEN

    --BUG#6740678
      IF l_cost_org_id      = p_organization_id AND
         p_item_from        IS NULL             AND
         p_item_to          IS NULL             AND
	     p_cost_type_id     IS NULL             AND
	     l_def_cost_type_id = l_primary_cost_method
	  THEN

      INSERT INTO   cst_item_list_temp(
             inventory_item_id,
             category_id,
             cost_type_id
      )
        SELECT MSI.inventory_item_id,
                MIC.category_id,
                CIC.cost_type_id
         FROM   mtl_item_categories MIC,
                mtl_system_items_kfv MSI,
                cst_item_costs CIC
--              cst_item_costs CIC1,
--              cst_item_costs CIC2
         WHERE  MIC.category_set_id = p_category_set_id
         AND    MIC.organization_id = p_organization_id
         AND    MSI.organization_id = p_organization_id
         AND    MSI.inventory_item_id = MIC.inventory_item_id
--{
--         AND    MSI.concatenated_segments
--                  BETWEEN NVL(p_item_from,MSI.concatenated_segments)
--                  AND     NVL(p_item_to,MSI.concatenated_segments)
--         AND    CIC1.organization_id (+) = l_cost_org_id
--         AND    CIC2.organization_id (+) = l_cost_org_id
--         AND    CIC1.inventory_item_id (+) = MSI.inventory_item_id
--         AND    CIC2.inventory_item_id (+) = MSI.inventory_item_id
--         AND    CIC1.cost_type_id (+) = NVL(p_cost_type_id,l_primary_cost_method)
--         AND    CIC2.cost_type_id (+) = l_def_cost_type_id
--         AND    CIC.rowid = NVL(CIC1.rowid,CIC2.rowid)
         AND CIC.organization_id    = p_organization_id
         AND CIC.inventory_item_id  = MSI.inventory_item_id
         AND CIC.cost_type_id       = l_primary_cost_method
--}
         AND CIC.inventory_asset_flag =
             DECODE(p_expense_item,1,CIC.inventory_asset_flag,1)
         AND NVL(CIC.item_cost,0) = DECODE(p_zero_cost_only,
                                         1,0,
                                         NVL(CIC.item_cost,0)
                                  );
     ELSE
--}
    	  log( 'Herve s call2') ;

    INSERT INTO   cst_item_list_temp(
             inventory_item_id,
             category_id,
             cost_type_id
           )
    SELECT MSI.inventory_item_id,
           MIC.category_id,
           CIC.cost_type_id
    FROM   mtl_item_categories MIC,
           mtl_system_items_kfv MSI,
           cst_item_costs CIC,
           cst_item_costs CIC1,
           cst_item_costs CIC2
    WHERE  MIC.category_set_id = p_category_set_id
    AND    MIC.organization_id = p_organization_id
    AND    MSI.organization_id = p_organization_id
    AND    MSI.inventory_item_id = MIC.inventory_item_id
    AND    MSI.concatenated_segments
             BETWEEN NVL(p_item_from,MSI.concatenated_segments)
             AND     NVL(p_item_to,MSI.concatenated_segments)
    AND    CIC1.organization_id (+) = l_cost_org_id
    AND    CIC2.organization_id (+) = l_cost_org_id
    AND    CIC1.inventory_item_id (+) = MSI.inventory_item_id
    AND    CIC2.inventory_item_id (+) = MSI.inventory_item_id
    AND    CIC1.cost_type_id (+) = NVL(p_cost_type_id,l_primary_cost_method)
    AND    CIC2.cost_type_id (+) = l_def_cost_type_id
    AND    CIC.rowid = NVL(CIC1.rowid,CIC2.rowid)
    AND    CIC.inventory_asset_flag =
           DECODE(p_expense_item,1,CIC.inventory_asset_flag,1)
    AND    NVL(CIC.item_cost,0) = DECODE(p_zero_cost_only,
                                         1,0,
                                         NVL(CIC.item_cost,0)
                                  );
   END IF;
--}
ELSE

    l_stmt_num := 20;

    --BUG#6740678
      IF l_cost_org_id      = p_organization_id AND
	     p_cost_type_id     IS NULL             AND
	     l_def_cost_type_id = l_primary_cost_method
	  THEN

	  log( 'Herve s call3') ;


      INSERT
      INTO   cst_item_list_temp(
               inventory_item_id,
               category_id,
               cost_type_id
             )
      SELECT MSI.inventory_item_id,
             MIC.category_id,
             CIC.cost_type_id
      FROM   mtl_item_categories MIC,
             mtl_categories_kfv MC,
             mtl_system_items_kfv MSI,
             cst_item_costs CIC
--             cst_item_costs CIC1,
--             cst_item_costs CIC2
      WHERE  MC.concatenated_segments
             BETWEEN NVL(p_category_from,MC.concatenated_segments)
             AND     NVL(p_category_to,MC.concatenated_segments)
      AND    MC.structure_id = (SELECT structure_id FROM mtl_category_sets WHERE category_set_id = p_category_set_id)
      AND    MIC.category_id = MC.category_id
      AND    MIC.category_set_id = p_category_set_id
      AND    MIC.organization_id = p_organization_id
      AND    MSI.organization_id = p_organization_id
      AND    MSI.inventory_item_id = MIC.inventory_item_id
      AND    MSI.concatenated_segments
             BETWEEN NVL(p_item_from,MSI.concatenated_segments)
             AND     NVL(p_item_to,MSI.concatenated_segments)
             -- The join to CIC implies that the item is
             -- MSI.costing_enabled
--{
--      AND    CIC1.organization_id (+) = l_cost_org_id
--      AND    CIC2.organization_id (+) = l_cost_org_id
--      AND    CIC1.inventory_item_id (+) = MSI.inventory_item_id
--      AND    CIC2.inventory_item_id (+) = MSI.inventory_item_id
--      AND    CIC1.cost_type_id (+) = NVL(p_cost_type_id,l_primary_cost_method)
--      AND    CIC2.cost_type_id (+) = l_def_cost_type_id
--      AND    CIC.rowid = NVL(CIC1.rowid,CIC2.rowid)
         AND CIC.organization_id    = p_organization_id
         AND CIC.inventory_item_id  = MSI.inventory_item_id
         AND CIC.cost_type_id       = l_primary_cost_method
--}
      AND    CIC.inventory_asset_flag =
             DECODE(p_expense_item,1,CIC.inventory_asset_flag,1)
      AND    NVL(CIC.item_cost,0) = DECODE(p_zero_cost_only,
                                      1,0,
                                      NVL(CIC.item_cost,0)
                                    );


    ELSE

      INSERT
      INTO   cst_item_list_temp(
               inventory_item_id,
               category_id,
               cost_type_id
             )
      SELECT MSI.inventory_item_id,
             MIC.category_id,
             CIC.cost_type_id
      FROM   mtl_item_categories MIC,
             mtl_categories_kfv MC,
             mtl_system_items_kfv MSI,
             cst_item_costs CIC,
             cst_item_costs CIC1,
             cst_item_costs CIC2
      WHERE  MC.concatenated_segments
             BETWEEN NVL(p_category_from,MC.concatenated_segments)
             AND     NVL(p_category_to,MC.concatenated_segments)
      AND    MC.structure_id = (SELECT structure_id FROM mtl_category_sets WHERE category_set_id = p_category_set_id)
      AND    MIC.category_id = MC.category_id
      AND    MIC.category_set_id = p_category_set_id
      AND    MIC.organization_id = p_organization_id
      AND    MSI.organization_id = p_organization_id
      AND    MSI.inventory_item_id = MIC.inventory_item_id
      AND    MSI.concatenated_segments
             BETWEEN NVL(p_item_from,MSI.concatenated_segments)
             AND     NVL(p_item_to,MSI.concatenated_segments)
             -- The join to CIC implies that the item is
             -- MSI.costing_enabled
      AND    CIC1.organization_id (+) = l_cost_org_id
      AND    CIC2.organization_id (+) = l_cost_org_id
      AND    CIC1.inventory_item_id (+) = MSI.inventory_item_id
      AND    CIC2.inventory_item_id (+) = MSI.inventory_item_id
      AND    CIC1.cost_type_id (+) = NVL(p_cost_type_id,l_primary_cost_method)
      AND    CIC2.cost_type_id (+) = l_def_cost_type_id
      AND    CIC.rowid = NVL(CIC1.rowid,CIC2.rowid)
      AND    CIC.inventory_asset_flag =
             DECODE(p_expense_item,1,CIC.inventory_asset_flag,1)
      AND    NVL(CIC.item_cost,0) = DECODE(p_zero_cost_only,
                                      1,0,
                                      NVL(CIC.item_cost,0)
                                    );
  END IF;

END IF;


      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Inserted '||SQL%ROWCOUNT||
                          ' items into CILT'||
                          ' - include costing_enabled items only'
        );
      END IF;

    ELSE -- p_cost_enabled <> 1
    -- Receiving reports do not require joining to CIC
    -- because non-costing-enabled items are not excluded from the report.
    -- The p_zero_cost_only and p_expense_item parameters are also ignored.
      l_stmt_num := 30;
      INSERT
      INTO   cst_item_list_temp(
               inventory_item_id,
               category_id,
               cost_type_id
             )
      SELECT MSI.inventory_item_id,
             MIC.category_id,
             l_def_cost_type_id
      FROM   mtl_item_categories MIC,
             mtl_categories_kfv MC,
             mtl_system_items_kfv MSI
      WHERE  MC.concatenated_segments
             BETWEEN NVL(p_category_from,MC.concatenated_segments)
             AND     NVL(p_category_to,MC.concatenated_segments)
      AND    MC.structure_id = (SELECT structure_id FROM mtl_category_sets WHERE category_set_id = p_category_set_id)
      AND    MIC.category_id = MC.category_id
      AND    MIC.category_set_id = p_category_set_id
      AND    MIC.organization_id = p_organization_id
      AND    MSI.organization_id = p_organization_id
      AND    MSI.inventory_item_id = MIC.inventory_item_id
      AND    MSI.concatenated_segments
             BETWEEN NVL(p_item_from,MSI.concatenated_segments)
             AND     NVL(p_item_to,MSI.concatenated_segments);

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Inserted '||SQL%ROWCOUNT||
                          ' items into CILT'||
                          ' - include non-costing-enabled items'
        );
      END IF;

    IF p_one_time_item = 1 THEN
      INSERT
      INTO   cst_item_list_temp(
               inventory_item_id,
               category_id,
               cost_type_id
             )
      VALUES
      (
               NULL,
               NULL,
               l_def_cost_type_id
      );

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Inserted '||SQL%ROWCOUNT||
                         ' items into CILT'||
                         ' - for one-time items'
        );
      END IF;
    END IF;

  END IF; -- end if p_cost_enabled_only = 1

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Populate_ItemList_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      ROLLBACK TO Populate_ItemList_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => SUBSTR(l_stmt_num||SQLERRM,1,240)
        );
      END IF;
  END Populate_ItemList;

  PROCEDURE Populate_CostGroupList(
    p_api_version          IN         NUMBER,
    p_organization_id      IN         NUMBER,
    p_cost_group_from      IN         VARCHAR2,
    p_cost_group_to        IN         VARCHAR2,
    p_own                  IN         NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2
   )
  IS
    l_api_name CONSTANT VARCHAR2(30) := 'Populate_CostGroupList';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_level_threshold NUMBER;
    l_stmt_num NUMBER := 0;
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Populate_CostGroupList_PVT;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call(
             p_current_version_number => l_api_version,
             p_caller_version_number => p_api_version,
             p_api_name => l_api_name,
             p_pkg_name => G_PKG_NAME
           )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check for message level threshold
    l_msg_level_threshold := FND_PROFILE.Value('FND_AS_MSG_LEVEL_THRESHOLD');

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => SUBSTR(
                          l_stmt_num||':'||
                          p_organization_id||','||
                          p_cost_group_from||','||
                          p_cost_group_to||','||
                          p_own,
                          1,
                          240
                        )
      );
    END IF;

    -- Populate cost group list for the current organization
    l_stmt_num := 10;
    INSERT
    INTO   cst_cg_list_temp(
             cost_group_id
           )
    SELECT CCG.cost_group_id
    FROM   cst_cost_groups CCG,
           (SELECT organization_id,
                   cost_group_id
            FROM   cst_cost_group_accounts
            UNION
            /* This is required for cases where default
               cost group id is 1 and it doesn't exist
               in cst_cost_group_accounts */
            SELECT organization_id,
                   default_cost_group_id cost_group_id
            FROM   mtl_parameters
               /* Bug: 7705930
                  This is required for cases when the default
                  cost group id was changed  from 1 but there
                  are transactions that belong to this common
                  cost group (1)  which is not covered in the
                  above query
               */
               UNION
               SELECT p_organization_id,
                      1
               FROM   dual
           ) CCGA
    WHERE  CCGA.organization_id = p_organization_id
    AND    CCG.cost_group_id = CCGA.cost_group_id
    AND    NVL(CCG.disable_date, sysdate+1) > sysdate
    AND    CCG.cost_group
           BETWEEN NVL(p_cost_group_from, CCG.cost_group)
           AND     NVL(p_cost_group_to, CCG.cost_group)
    AND NOT EXISTS( SELECT 'Cost Group already exists'
                       FROM   cst_cg_list_temp CGLT
                       where CGLT.cost_group_id = CCG.cost_group_id
                  );


    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => l_stmt_num||': Inserted '||SQL%ROWCOUNT||
                        ' cost groups from organization '||p_organization_id||
                        ' into CCLT'
      );
    END IF;

    -- Populate cost group list for the transfer organizations
    IF NVL(p_own, -1) <> 1
    THEN
      l_stmt_num := 20;
      INSERT
      INTO   cst_cg_list_temp(
               cost_group_id
             )
     (SELECT DISTINCT
             CCG.cost_group_id
      FROM   cst_cost_groups CCG,
             (SELECT organization_id,
                     cost_group_id
              FROM   cst_cost_group_accounts
              UNION
              /* This is required for cases where default
                 cost group id is 1 and it doesn't exist
                 in cst_cost_group_accounts */
              SELECT organization_id,
                     default_cost_group_id cost_group_id
              FROM   mtl_parameters
                 /* Bug: 7705930
                     This is required for cases when the default
                     cost group id  was changed from 1 but there
                     are transactions that belong to this common
                     cost group (1) which  is not covered in the
                     above query
                  */
                  UNION
                  SELECT p_organization_id,
                         1
                  FROM   dual
             ) CCGA,
             mtl_interorg_parameters MIP
      WHERE  CCG.cost_group_id = CCGA.cost_group_id
      AND    NVL(CCG.disable_date, sysdate+1) > sysdate
      AND    CCG.cost_group
             BETWEEN NVL(p_cost_group_from, CCG.cost_group)
             AND     NVL(p_cost_group_to, CCG.cost_group)
      AND    (  (    MIP.from_organization_id = p_organization_id
                 AND MIP.to_organization_id = CCGA.organization_id)
              OR
                (    MIP.to_organization_id = p_organization_id
                 AND MIP.from_organization_id = CCGA.organization_id)
             )
      MINUS
      SELECT cost_group_id
      FROM   cst_cg_list_temp);

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Inserted '||SQL%ROWCOUNT||
                           ' cost groups from other organizations '||
                           ' into CCLT'
        );
      END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Populate_CostGroupList_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      ROLLBACK TO Populate_CostGroupList_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => SUBSTR(l_stmt_num||SQLERRM,1,240)
        );
      END IF;
  END Populate_CostGroupList;

  PROCEDURE Populate_SubinventoryList(
    p_api_version          IN         NUMBER,
    p_organization_id      IN         NUMBER,
    p_subinventory_from    IN         VARCHAR2,
    p_subinventory_to      IN         VARCHAR2,
    p_expense_sub          IN         NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2
  )
  IS
    l_api_name CONSTANT VARCHAR2(30) := 'Populate_SubinventoryList';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_level_threshold NUMBER;
    l_stmt_num NUMBER := 0;
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Populate_SubinventoryList_PVT;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call(
             p_current_version_number => l_api_version,
             p_caller_version_number => p_api_version,
             p_api_name => l_api_name,
             p_pkg_name => G_PKG_NAME
           )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check for message level threshold
    l_msg_level_threshold := FND_PROFILE.Value('FND_AS_MSG_LEVEL_THRESHOLD');

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => SUBSTR(
                          l_stmt_num||':'||
                          p_organization_id||','||
                          p_subinventory_from||','||
                          p_subinventory_to||','||
                          p_expense_sub,
                          1,
                          240
                        )
      );
    END IF;

    -- Populate subinventory list
    l_stmt_num := 10;
    INSERT
    INTO   cst_sub_list_temp(
             subinventory_code
           )
    SELECT SUB.secondary_inventory_name
    FROM   mtl_secondary_inventories SUB
    WHERE  SUB.organization_id = p_organization_id
    AND    SUB.asset_inventory = DECODE(p_expense_sub,1,SUB.asset_inventory,1)
           -- Non-quantity tracked subinventories do not appear in MOQ.
    AND    SUB.quantity_tracked = 1
    AND    SUB.secondary_inventory_name
           BETWEEN NVL(p_subinventory_from, SUB.secondary_inventory_name)
           AND     NVL(p_subinventory_to, SUB.secondary_inventory_name)
    AND NOT EXISTS ( SELECT 'Subinventory Already Exists'
                         FROM cst_sub_list_temp CSLT
                         where CSLT.subinventory_code = SUB.secondary_inventory_name
                    );


    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => l_stmt_num||': Inserted '||SQL%ROWCOUNT||
                        ' subinventories into CSLT'
      );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Populate_SubinventoryList_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      ROLLBACK TO Populate_SubinventoryList_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => SUBSTR(l_stmt_num||SQLERRM,1,240)
        );
      END IF;
  END Populate_SubinventoryList;

  PROCEDURE Calculate_OnhandQty(
    p_api_version          IN         NUMBER,
    p_organization_id      IN         NUMBER,
    p_valuation_date       IN         DATE,
    p_qty_by_revision      IN         NUMBER,
    p_zero_qty             IN         NUMBER,
    p_unvalued_txns        IN         NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2
  )
  IS
    l_api_name CONSTANT VARCHAR2(30) := 'Calculate_OnhandQty';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_level_threshold NUMBER;
    l_stmt_num NUMBER := 0;
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Calculate_OnhandQty_PVT;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call(
             p_current_version_number => l_api_version,
             p_caller_version_number => p_api_version,
             p_api_name => l_api_name,
             p_pkg_name => G_PKG_NAME
           )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check for message level threshold
    l_msg_level_threshold := FND_PROFILE.Value('FND_AS_MSG_LEVEL_THRESHOLD');

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => SUBSTR(
                          l_stmt_num||':'||
                          p_organization_id||','||
                          to_char(p_valuation_date,'DD-MON-YYYY HH24:MI:SS')||','||
                          p_qty_by_revision||','||
                          p_zero_qty||','||
                          p_unvalued_txns,
                          1,
                          240
                        )
      );
    END IF;

    -- Calculate Current Onhand Quantity
    l_stmt_num := 10;
    INSERT
    INTO   cst_inv_qty_temp(
             organization_id,
             cost_group_id,
             subinventory_code,
             inventory_item_id,
             rollback_qty,
             qty_source,
             revision,
             category_id,
             cost_type_id
           )
    SELECT p_organization_id,
           MOQ.cost_group_id,
           MOQ.subinventory_code,
           MOQ.inventory_item_id,
           SUM(MOQ.transaction_quantity),
           3, -- CURRENT_ONHAND
           DECODE(p_qty_by_revision,1,moq.revision,NULL),
           CILT.category_id,
           CILT.cost_type_id
    FROM   mtl_onhand_quantities MOQ,
           cst_item_list_temp CILT,
           cst_cg_list_temp CCLT,
           cst_sub_list_temp CSLT
    WHERE  MOQ.organization_id  = p_organization_id
    AND    CILT.inventory_item_id = MOQ.inventory_item_id
    AND    CCLT.cost_group_id = MOQ.cost_group_id
    AND    CSLT.subinventory_code = MOQ.subinventory_code
    GROUP
    BY     MOQ.cost_group_id,
           MOQ.subinventory_code,
           MOQ.inventory_item_id,
           DECODE(p_qty_by_revision,1,moq.revision,NULL),
           CILT.category_id,
           CILT.cost_type_id;

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                        ' current onhand quantities'
      );
    END IF;

    -- Rollback Uncosted Onhand
    l_stmt_num := 20;
    IF NVL(p_unvalued_txns,-1) <> 1
    THEN
      INSERT
      INTO   cst_inv_qty_temp(
               organization_id,
               cost_group_id,
               subinventory_code,
               inventory_item_id,
               rollback_qty,
               qty_source,
               revision,
               txn_source_type_id,
               category_id,
               cost_type_id
              )
      SELECT /*+ LEADING (MMT)*/
             p_organization_id,
             MMT.cost_group_id,
             MMT.subinventory_code,
             MMT.inventory_item_id,
             -1*SUM(MMT.primary_quantity),
             -- Sum is used to reduce the number of rows in CIQT
             4, -- UNCOSTED_ONHAND
             DECODE(p_qty_by_revision, 1, MMT.revision, NULL),
             MMT.transaction_source_type_id,
             CILT.category_id,
             CILT.cost_type_id
      FROM   mtl_material_transactions MMT,
             cst_item_list_temp CILT,
             cst_cg_list_temp CCLT,
             cst_sub_list_temp CSLT
      WHERE  MMT.organization_id  = p_organization_id
      AND    CILT.inventory_item_id = MMT.inventory_item_id
      AND    CCLT.cost_group_id = MMT.cost_group_id
      AND    CSLT.subinventory_code = MMT.subinventory_code
      AND    MMT.costed_flag in ('N','E')
             -- Ignore consigned transactions
      AND    MMT.organization_id =
             NVL(MMT.owning_organization_id, MMT.organization_id)
      AND    NVL(MMT.owning_tp_type,2) = 2
             -- Ignore logical transactions corresponding to drop shipments
             -- and global procurement transactions
      AND    NVL(MMT.logical_transaction,-1) <> 1
             -- Ignore WMS/OSFM transactions, cost updates including periodic cost
             -- updates that do not affect onhand quantity
      AND    MMT.transaction_action_id NOT IN (24,40,41,50,51,52)
      GROUP
      BY     MMT.cost_group_id,
             MMT.subinventory_code,
             MMT.inventory_item_id,
             DECODE(p_qty_by_revision, 1, MMT.revision, NULL),
             MMT.transaction_source_type_id,
             CILT.category_id,
             CILT.cost_type_id;

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                          ' uncosted onhand quantities'
        );
      END IF;

    END IF;


    -- Rollback Onhand Quantity to the Valuation Date
    l_stmt_num := 30;
    IF p_valuation_date IS NOT NULL
    THEN
      INSERT
      INTO   cst_inv_qty_temp
             ( organization_id,
               cost_group_id,
               subinventory_code,
               inventory_item_id,
               rollback_qty,
               qty_source,
               rollback_value,
               revision,
               txn_source_type_id,
               category_id,
               cost_type_id
             )
      SELECT p_organization_id,
             MMT.cost_group_id,
             MMT.subinventory_code,
             MMT.inventory_item_id,
             -- There is a bug on Average Cost Update, where primary_quantity
             -- is populated in addition to quantity_adjusted
             SUM(-1*DECODE(MMT.transaction_action_id,24,0,MMT.primary_quantity)),
             -- Sum is used to reduce the number of rows in CIQT
             5, -- ROLLBACK_ONHAND
             SUM(
               DECODE(
                 MMT.transaction_action_id,
                 24, MMT.quantity_adjusted*(MMT.new_cost - MMT.prior_cost),
                 MMT.primary_quantity*MMT.actual_cost - NVL(MMT.variance_amount,0)
               )
             ),
             -- Rollback value is used in the Transaction Value Historical
             -- Summary - Average Costing report
             DECODE(p_qty_by_revision, 1, MMT.revision, NULL),
             MMT.transaction_source_type_id,
             CILT.category_id,
             CILT.cost_type_id
      FROM   mtl_material_transactions MMT,
             cst_item_list_temp CILT
      WHERE  MMT.organization_id = p_organization_id
      AND    CILT.inventory_item_id = MMT.inventory_item_id
      AND    MMT.costed_flag IS NULL
      AND    MMT.transaction_date > p_valuation_date
             -- Ignore Consigned transactions
      AND    MMT.organization_id = NVL(MMT.owning_organization_id,
             MMT.organization_id)
      AND    NVL(MMT.owning_tp_type,2) = 2
             -- Ignore logical transactions corresponding to drop shipments
             -- and global procurement transactions
      AND    NVL(MMT.logical_transaction,-1) <> 1
             -- Ignore WMS and OSFM transactions that do not affect onhand
             -- quantity and inventory valuation
      AND    MMT.transaction_action_id NOT IN (40,41,50,51,52)
             -- Ignore periodic cost updates
      AND    MMT.transaction_source_type_id <> 14
             -- The only transactions other than the ones ignored above that
             -- affect inventory valuation and have null cost_group_id are
             -- standard cost updates (non-PJM/WMS)
      AND    (   (    MMT.transaction_type_id = 24
                  AND MMT.cost_group_id IS NULL
                 )
              OR EXISTS (
                   SELECT 1
                   FROM   cst_cg_list_temp CCLT
                   WHERE  CCLT.cost_group_id = MMT.cost_group_id)
             )
             -- The only transactions other than the ones ignored above that
             -- affect inventory valuation and have null subinventory_code are
             -- actual cost updates and std cost updates for PJM/WMS orgs
      AND    (   (    MMT.transaction_action_id = 24
                  AND MMT.subinventory_code IS NULL
                 )
              OR EXISTS (
                   SELECT 1
                   FROM   cst_sub_list_temp CSLT
                   WHERE  CSLT.subinventory_code = MMT.subinventory_code)
             )
      GROUP
      BY     MMT.cost_group_id,
             MMT.subinventory_code,
             MMT.inventory_item_id,
             DECODE(p_qty_by_revision, 1, MMT.revision, NULL),
             MMT.transaction_source_type_id,
             CILT.category_id,
             CILT.cost_type_id;

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                          ' rolled back onhand quantities'
        );
      END IF;
    END IF;

    -- Include zero quantity items
    IF p_zero_qty = 1
    THEN
      l_stmt_num := 40;
      INSERT
      INTO   cst_inv_qty_temp(
               organization_id,
               inventory_item_id,
               rollback_qty,
               qty_source,
               category_id,
               cost_group_id,
               cost_type_id
             )
      SELECT p_organization_id,
             TEMP.inventory_item_id,
             0,
             3, -- CURRENT_ONHAND
             TEMP.category_id,
             MP.default_cost_group_id,
             TEMP.cost_type_id
      FROM   (
               SELECT inventory_item_id,
                      category_id,
                      cost_type_id
               FROM   cst_item_list_temp
               MINUS
               SELECT DISTINCT
                      inventory_item_id,
                      category_id,
                      cost_type_id
               FROM   cst_inv_qty_temp
               WHERE  organization_id = p_organization_id
             ) TEMP,
             mtl_parameters MP
      WHERE  MP.organization_id = p_organization_id;

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                          ' zero quantities'
        );
      END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Calculate_OnhandQty_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      ROLLBACK TO Calculate_OnhandQty_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => SUBSTR(l_stmt_num||SQLERRM,1,240)
        );
      END IF;
  END Calculate_OnhandQty;

  PROCEDURE Calculate_IntransitQty(
    p_api_version          IN         NUMBER,
    p_organization_id      IN         NUMBER,
    p_valuation_date       IN         DATE,
    p_receipt              IN         NUMBER,
    p_shipment             IN         NUMBER,
    p_detail               IN         NUMBER,
    p_own                  IN         NUMBER,
    p_unvalued_txns        IN         NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2
   )
   IS
    l_api_name CONSTANT VARCHAR2(30) := 'Calculate_IntransitQty';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_level_threshold NUMBER;
    --BUG#6109468-FPBUG5606455
    l_uncosted_txn_count  NUMBER;
    l_stmt_num NUMBER := 0;
   BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Calculate_IntransitQty_PVT;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call(
             p_current_version_number => l_api_version,
             p_caller_version_number => p_api_version,
             p_api_name => l_api_name,
             p_pkg_name => G_PKG_NAME
           )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check for message level threshold
    l_msg_level_threshold := FND_PROFILE.Value('FND_AS_MSG_LEVEL_THRESHOLD');

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => SUBSTR(
                          l_stmt_num||':'||
                          p_organization_id||','||
                          to_char(p_valuation_date,'DD-MON-YYYY HH24:MI:SS')||','||
                          p_receipt||','||
                          p_shipment||','||
                          p_detail||','||
                          p_own||','||
                          p_unvalued_txns,
                          1,
                          240
                        )
      );
    END IF;


    --BUG#6109468-FOBUG5606455
    IF (p_unvalued_txns IS NOT NULL) AND (p_unvalued_txns <> -1) THEN
      l_stmt_num := 5;

      DECLARE
        CURSOR c IS
         SELECT /*+ INDEX (MMT MTL_MATERIAL_TRANSACTIONS_N10) */ 1
           FROM mtl_material_transactions MMT
          WHERE mmt.costed_flag IN ('N','E')
            AND (    mmt.organization_id = p_organization_id
			      OR mmt.transfer_organization_id = p_organization_id)
            AND (    mmt.transaction_action_id = 12
                  OR mmt.transaction_action_id = 21)
            AND ROWNUM <2;
      BEGIN
        OPEN c;
        FETCH c INTO l_uncosted_txn_count;
        IF c%NOTFOUND THEN
           l_uncosted_txn_count := 0;
        END IF;
        CLOSE c;
      END;

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS THEN
        FND_MSG_PUB.Add_Exc_Msg(
           p_pkg_name => G_PKG_NAME,
           p_procedure_name => l_api_name,
           p_error_text => l_stmt_num||': Calculated '||l_uncosted_txn_count||
                         ' uncosted shipment/receipt transactions in the '||
                         ' current organization'  );
      END IF;

    END IF;



    -- Check if the intransit quantity needs to be calculated at the shipment
    -- line level OR just the item/from_org/to_org/cost_group combination
    IF p_detail = 1
    THEN
      -- All intransit calculations are for quantities that are related
      -- to p_organization_id, but not neccessarily owned by it. This is
      -- necessary for the Intransit Valuation Report.

      -- Calculate intransit quantity coming into this organization

      IF p_receipt = 1
      THEN
        -- Calculate current intransit quantity coming into this organization
        l_stmt_num := 10;
        INSERT
        INTO   cst_inv_qty_temp(
                 qty_source,
                 organization_id,
                 inventory_item_id,
                 category_id,
                 revision,
                 cost_type_id,
                 cost_group_id,
                 from_organization_id,
                 to_organization_id,
                 rollback_qty,
                 intransit_inv_account,
                 shipment_line_id
               )
        SELECT 6,-- CURRENT_INTRANSIT
               MS.intransit_owning_org_id,
               ITEMS.inventory_item_id,
               ITEMS.category_id,
               MS.item_revision,
               ITEMS.cost_type_id,
               CGS.cost_group_id,
               MS.from_organization_id,
               MS.to_organization_id,
               -- quantity is always expressed in the primary unit of measure
               -- of the intransit owning organization
               SUM(
                 DECODE(
                   MS.intransit_owning_org_id,
                   MS.from_organization_id,
                   inv_convert.inv_um_convert(
                     MS.item_id,NULL,MS.quantity,NULL,NULL,
                     MS.unit_of_measure,MSI_FROM.primary_unit_of_measure
                   ),
                   MS.to_org_primary_quantity
                 )
               ),
               NVL(
                 MMT.intransit_account,
                 NVL(MIP.intransit_inv_account,MP.intransit_inv_account)
               ),
               MS.shipment_line_id
        FROM   mtl_supply MS,
               cst_item_list_temp ITEMS,
               cst_cg_list_temp CGS,
               mtl_parameters MP,
               mtl_interorg_parameters MIP,
               mtl_material_transactions MMT,
               rcv_shipment_lines RSL,
               mtl_system_items MSI_FROM
        WHERE  MS.to_organization_id = p_organization_id
      /*  AND    MS.intransit_owning_org_id = p_organization_id */ /* Bug 5664736 */
      	AND    MS.intransit_owning_org_id = DECODE(NVL(p_own,-1),1,p_organization_id,MS.intransit_owning_org_id)
        AND    MS.item_id = ITEMS.inventory_item_id
        AND    MS.supply_type_code IN ('SHIPMENT','RECEIVING')
        AND    MS.destination_type_code = 'INVENTORY'
        AND    NVL(MS.cost_group_id,MP.default_cost_group_id) = CGS.cost_group_id
        AND    MP.organization_id = MS.intransit_owning_org_id
        AND    RSL.shipment_line_id = MS.shipment_line_id
        AND    MMT.transaction_id (+) = RSL.mmt_transaction_id
        AND    MIP.from_organization_id (+) = MS.from_organization_id
        AND    MIP.to_organization_id (+) = MS.to_organization_id
        AND    MIP.fob_point (+) =
               DECODE(
                 MS.intransit_owning_org_id,
                 MS.from_organization_id, 2,
                 MS.to_organization_id, 1
               )
        AND    MSI_FROM.inventory_item_id = MS.item_id
        AND    MSI_FROM.organization_id = MS.from_organization_id
        GROUP
        BY     MS.intransit_owning_org_id,
               ITEMS.inventory_item_id,
               ITEMS.category_id,
               MS.item_revision,
               ITEMS.cost_type_id,
               CGS.cost_group_id,
               MS.from_organization_id,
               MS.to_organization_id,
               NVL(
                 MMT.intransit_account,
                 NVL(MIP.intransit_inv_account,MP.intransit_inv_account)
               ),
               MS.shipment_line_id;

        IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
        THEN
          FND_MSG_PUB.Add_Exc_Msg(
            p_pkg_name => G_PKG_NAME,
            p_procedure_name => l_api_name,
            p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                            ' current intransit quantities coming into the'||
                            ' current organization'
          );
        END IF;

        -- Calculate uncosted intransit shipment quantities coming into this
        -- organization
        IF NVL(p_unvalued_txns,-1) <> 1 THEN

          IF l_uncosted_txn_count > 0 THEN --BUG6109468-FP5606455

          l_stmt_num := 20;
          INSERT
          INTO   cst_inv_qty_temp(
                   qty_source,
                   organization_id,
                   inventory_item_id,
                   category_id,
                   revision,
                   cost_type_id,
                   cost_group_id,
                   from_organization_id,
                   to_organization_id,
                   rollback_qty,
                   intransit_inv_account,
                   shipment_line_id
                 )
          SELECT 7, -- UNCOSTED_INTRANSIT
                 DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_organization_id,
                   2,MMT.organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 SUM(
                   DECODE(
                     NVL(MMT.fob_point,MIP.fob_point),
                     1,
                     inv_convert.inv_um_convert(
                       MMT.inventory_item_id,NULL,MMT.transaction_quantity,
                       MMT.transaction_uom,MSI_TO.primary_uom_code,NULL,NULL
                     ),
                     2,
                     MMT.primary_quantity
                   )
                 ),
                 NVL(MMT.intransit_account,MIP.intransit_inv_account),
                 RSL.shipment_line_id
          FROM   mtl_material_transactions MMT,
                 cst_item_list_temp ITEMS,
                 cst_cg_list_temp CGS,
                 mtl_interorg_parameters MIP,
                 mtl_system_items MSI_TO,
                 rcv_shipment_headers RSH,
                 rcv_shipment_lines RSL
          WHERE  MMT.transfer_organization_id = p_organization_id
          AND    MMT.transaction_action_id = 21
          AND    MMT.costed_flag IN ('N','E')
          AND    MMT.inventory_item_id = ITEMS.inventory_item_id
          AND    DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_cost_group_id,
                   2,MMT.cost_group_id
                 ) =
                 CGS.cost_group_id
          AND    MIP.to_organization_id = MMT.transfer_organization_id
          AND    MIP.from_organization_id = MMT.organization_id
          AND    MSI_TO.organization_id = MMT.transfer_organization_id
          AND    MSI_TO.inventory_item_id = MMT.inventory_item_id
          AND    RSH.shipment_num = MMT.shipment_number
          AND    RSL.shipment_header_id = RSH.shipment_header_id
          AND    RSL.mmt_transaction_id = MMT.transaction_id
          GROUP
          BY     DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_organization_id,
                   2,MMT.organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 NVL(MMT.intransit_account,MIP.intransit_inv_account),
                 RSL.shipment_line_id;

          IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
          THEN
            FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => G_PKG_NAME,
              p_procedure_name => l_api_name,
              p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                              ' uncosted intransit shipment quantities coming'||
                              ' into the current organization'
            );
          END IF;

          -- Calculate uncosted intransit receipt quantities coming into this
          -- organization
          l_stmt_num := 30;
          INSERT
          INTO   cst_inv_qty_temp(
                   qty_source,
                   organization_id,
                   inventory_item_id,
                   category_id,
                   revision,
                   cost_type_id,
                   cost_group_id,
                   from_organization_id,
                   to_organization_id,
                   rollback_qty,
                   intransit_inv_account,
                   shipment_line_id
                 )
          SELECT 7, -- UNCOSTED_INTRANSIT
                 DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.organization_id,
                   2,MMT.transfer_organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.transfer_organization_id,
                 MMT.organization_id,
                 SUM(
                   DECODE(
                     NVL(MMT.fob_point,MIP.fob_point),
                     1,
                     MMT.primary_quantity,
                     2,
                     inv_convert.inv_um_convert(
                       MMT.inventory_item_id,NULL,MMT.transaction_quantity,
                       MMT.transaction_uom,MSI_FROM.primary_uom_code,NULL,NULL
                     )
                   )
                 ),
                 NVL(MMT.intransit_account, MIP.intransit_inv_account),
                 RT.shipment_line_id
          FROM   mtl_material_transactions MMT,
                 cst_item_list_temp ITEMS,
                 cst_cg_list_temp CGS,
                 mtl_interorg_parameters MIP,
                 mtl_system_items MSI_FROM,
                 rcv_transactions RT
          WHERE  MMT.organization_id = p_organization_id
          AND    MMT.transaction_action_id = 12
          AND    MMT.costed_flag IN ('N', 'E')
          AND    MMT.inventory_item_id = ITEMS.inventory_item_id
          AND    DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.cost_group_id,
                   2,MMT.transfer_cost_group_id
                 ) =
                 CGS.cost_group_id
          AND    MIP.to_organization_id = MMT.organization_id
          AND    MIP.from_organization_id = MMT.transfer_organization_id
          AND    MSI_FROM.organization_id = MMT.transfer_organization_id
          AND    MSI_FROM.inventory_item_id = MMT.inventory_item_id
          AND    RT.transaction_id = MMT.rcv_transaction_id
          GROUP
          BY     DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.organization_id,
                   2,MMT.transfer_organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 NVL(MMT.intransit_account, MIP.intransit_inv_account),
                 RT.shipment_line_id;

          IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
          THEN
            FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => G_PKG_NAME,
              p_procedure_name => l_api_name,
              p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                              ' uncosted intransit receipt quantities coming'||
                              ' into the current org'
            );
          END IF;
         END IF;  --BUG6109468-FPBUG5606455 --l_uncosted_txn_count>0
        END IF; -- NVL(p_unvalued_txns,-1) <> 1

        IF p_valuation_date IS NOT NULL
        THEN
          -- Calculate rollback intransit shipment quantities coming into this
          -- organization. The code for this calculation is similar to the one used
          -- to calculate uncosted intransit shipment quantities coming into this
          -- organization. The only difference is instead of checking for
          -- costed_flag in ('N','E'), we check for costed_flag is NULL and
          -- transaction_date > p_valuation_date
          l_stmt_num := 40;
          INSERT
          INTO   cst_inv_qty_temp(
                   qty_source,
                   organization_id,
                   inventory_item_id,
                   category_id,
                   revision,
                   cost_type_id,
                   cost_group_id,
                   from_organization_id,
                   to_organization_id,
                   rollback_qty,
                   intransit_inv_account,
                   shipment_line_id
                 )
          SELECT 8, -- ROLLBACK_INTRANSIT
                 DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_organization_id,
                   2,MMT.organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 SUM(
                   DECODE(
                     NVL(MMT.fob_point,MIP.fob_point),
                     1,
                     inv_convert.inv_um_convert(
                       MMT.inventory_item_id,NULL,MMT.transaction_quantity,
                       MMT.transaction_uom,MSI_TO.primary_uom_code,NULL,NULL
                     ),
                     2,
                     MMT.primary_quantity
                   )
                 ),
                 NVL(MMT.intransit_account,MIP.intransit_inv_account),
                 RSL.shipment_line_id
          FROM   mtl_material_transactions MMT,
                 cst_item_list_temp ITEMS,
                 cst_cg_list_temp CGS,
                 mtl_interorg_parameters MIP,
                 mtl_system_items MSI_TO,
                 rcv_shipment_headers RSH,
                 rcv_shipment_lines RSL
          WHERE  MMT.transfer_organization_id = p_organization_id
          AND    MMT.transaction_action_id = 21
          AND    MMT.costed_flag IS NULL
          AND    MMT.transaction_date > p_valuation_date
          AND    MMT.inventory_item_id = ITEMS.inventory_item_id
          AND    DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_cost_group_id,
                   2,MMT.cost_group_id
                 ) =
                 CGS.cost_group_id
          AND    MIP.to_organization_id = MMT.transfer_organization_id
          AND    MIP.from_organization_id = MMT.organization_id
          AND    MSI_TO.organization_id = MMT.transfer_organization_id
          AND    MSI_TO.inventory_item_id = MMT.inventory_item_id
          AND    RSH.shipment_num = MMT.shipment_number
          AND    RSL.shipment_header_id = RSH.shipment_header_id
          AND    RSL.mmt_transaction_id = MMT.transaction_id
          GROUP
          BY     DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_organization_id,
                   2,MMT.organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 NVL(MMT.intransit_account,MIP.intransit_inv_account),
                 RSL.shipment_line_id;

          IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
          THEN
            FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => G_PKG_NAME,
              p_procedure_name => l_api_name,
              p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                              ' rolled back intransit shipment quantities'||
                              ' coming into the current org'
            );
          END IF;

          -- Calculate rollback intransit receipt quantities coming into this
          -- organization. The code for this calculation is similar to the one
          -- used to calculate uncosted intransit receipt quantities coming into
          -- this organization. The only difference is instead of checking for
          -- costed_flag in ('N','E'), we check for costed_flag is NULL and
          -- transaction_date > p_valuation_date
          l_stmt_num := 50;
          INSERT
          INTO   cst_inv_qty_temp(
                   qty_source,
                   organization_id,
                   inventory_item_id,
                   category_id,
                   revision,
                   cost_type_id,
                   cost_group_id,
                   from_organization_id,
                   to_organization_id,
                   rollback_qty,
                   intransit_inv_account,
                   shipment_line_id
                 )
          SELECT 8, -- ROLLBACK_INTRANSIT
                 DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.organization_id,
                   2,MMT.transfer_organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.transfer_organization_id,
                 MMT.organization_id,
                 SUM(
                   DECODE(
                     NVL(MMT.fob_point,MIP.fob_point),
                     1,
                     MMT.primary_quantity,
                     2,
                     inv_convert.inv_um_convert(
                       MMT.inventory_item_id,NULL,MMT.transaction_quantity,
                       MMT.transaction_uom,MSI_FROM.primary_uom_code,NULL,NULL
                     )
                   )
                 ),
                 NVL(MMT.intransit_account, MIP.intransit_inv_account),
                 RT.shipment_line_id
          FROM   mtl_material_transactions MMT,
                 cst_item_list_temp ITEMS,
                 cst_cg_list_temp CGS,
                 mtl_interorg_parameters MIP,
                 mtl_system_items MSI_FROM,
                 rcv_transactions RT
          WHERE  MMT.organization_id = p_organization_id
          AND    MMT.transaction_action_id = 12
          AND    MMT.costed_flag IS NULL
          AND    MMT.transaction_date > p_valuation_date
          AND    MMT.inventory_item_id = ITEMS.inventory_item_id
          AND    DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.cost_group_id,
                   2,MMT.transfer_cost_group_id
                 ) =
                 CGS.cost_group_id
          AND    MIP.to_organization_id = MMT.organization_id
          AND    MIP.from_organization_id = MMT.transfer_organization_id
          AND    MSI_FROM.organization_id = MMT.transfer_organization_id
          AND    MSI_FROM.inventory_item_id = MMT.inventory_item_id
          AND    RT.transaction_id = MMT.rcv_transaction_id
          GROUP
          BY     DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.organization_id,
                   2,MMT.transfer_organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 NVL(MMT.intransit_account, MIP.intransit_inv_account),
                 RT.shipment_line_id;

          IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
          THEN
            FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => G_PKG_NAME,
              p_procedure_name => l_api_name,
              p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                              ' rolled back intransit shipment quantities'||
                              ' coming into the current organization'
            );
          END IF;
        END IF; -- p_valuation_date IS NOT NULL
      END IF; -- p_receipt = 1

      IF p_shipment = 1 THEN
        -- Calculate current intransit quantity going out of this organization
        -- The code for this calculation is similar to the one used to calculate
        -- current intransit quantities coming into this organization. The only
        -- difference is instead of checking for MS.to_organization_id =
        -- p_organization_id, we check for MS.from_organization_id =
        -- p_organization_id
        l_stmt_num := 60;
        INSERT
        INTO   cst_inv_qty_temp(
                 qty_source,
                 organization_id,
                 inventory_item_id,
                 category_id,
                 revision,
                 cost_type_id,
                 cost_group_id,
                 from_organization_id,
                 to_organization_id,
                 rollback_qty,
                 intransit_inv_account,
                 shipment_line_id
               )
        SELECT 6,-- CURRENT_INTRANSIT
               MS.intransit_owning_org_id,
               ITEMS.inventory_item_id,
               ITEMS.category_id,
               MS.item_revision,
               ITEMS.cost_type_id,
               CGS.cost_group_id,
               MS.from_organization_id,
               MS.to_organization_id,
               SUM(
                 DECODE(
                   MS.intransit_owning_org_id,
                   MS.from_organization_id,
                   inv_convert.inv_um_convert(
                     MS.item_id,NULL,MS.quantity,NULL,NULL,
                     MS.unit_of_measure,MSI_FROM.primary_unit_of_measure
                   ),
                   MS.to_org_primary_quantity
                 )
               ),
               NVL(
                 MMT.intransit_account,
                 NVL(MIP.intransit_inv_account,MP.intransit_inv_account)
               ),
               MS.shipment_line_id
        FROM   mtl_supply MS,
               cst_item_list_temp ITEMS,
               cst_cg_list_temp CGS,
               mtl_parameters MP,
               mtl_interorg_parameters MIP,
               mtl_material_transactions MMT,
               rcv_shipment_lines RSL,
               mtl_system_items MSI_FROM
        WHERE  MS.from_organization_id = p_organization_id
      /*  AND    MS.intransit_owning_org_id = p_organization_id */ /* Bug 5664736 */
      	AND    MS.intransit_owning_org_id = DECODE(NVL(p_own,-1),1,p_organization_id,MS.intransit_owning_org_id)
        AND    MS.item_id = ITEMS.inventory_item_id
        AND    MS.supply_type_code IN ('SHIPMENT','RECEIVING')
        AND    MS.destination_type_code = 'INVENTORY'
        AND    NVL(MS.cost_group_id,MP.default_cost_group_id) = CGS.cost_group_id
        AND    MP.organization_id = MS.intransit_owning_org_id
        AND    RSL.shipment_line_id = MS.shipment_line_id
        AND    MMT.transaction_id (+) = RSL.mmt_transaction_id
        AND    MIP.from_organization_id (+) = MS.from_organization_id
        AND    MIP.to_organization_id (+) = MS.to_organization_id
        AND    MIP.fob_point (+) =
               DECODE(
                 MS.intransit_owning_org_id,
                 MS.from_organization_id, 2,
                 MS.to_organization_id, 1)
        AND    MSI_FROM.inventory_item_id = MS.item_id
        AND    MSI_FROM.organization_id = MS.from_organization_id
        GROUP
        BY     MS.intransit_owning_org_id,
               ITEMS.inventory_item_id,
               ITEMS.category_id,
               MS.item_revision,
               ITEMS.cost_type_id,
               CGS.cost_group_id,
               MS.from_organization_id,
               MS.to_organization_id,
               NVL(
                 MMT.intransit_account,
                 NVL(MIP.intransit_inv_account,MP.intransit_inv_account)
               ),
               MS.shipment_line_id;

        IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
        THEN
          FND_MSG_PUB.Add_Exc_Msg(
            p_pkg_name => G_PKG_NAME,
            p_procedure_name => l_api_name,
            p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                            ' current intransit quantities going out of the'||
                            ' current organization'
          );
        END IF;

        IF NVL(p_unvalued_txns,-1) <> 1 THEN

          IF l_uncosted_txn_count > 0 THEN --BUG#6109468-FPBUG5606455

          -- Calculate uncosted intransit shipment quantities going out of this
          -- organization. The code for this calculation is similar to the one used
          -- to calculate uncosted intransit shipment quantities coming into this
          -- organization. The only difference is instead of checking for
          -- MMT.transfer_organization_id = p_organization_id, we check for
          -- MMT.organization_id = p_organization_id
          l_stmt_num := 70;
          INSERT
          INTO   cst_inv_qty_temp(
                   qty_source,
                   organization_id,
                   inventory_item_id,
                   category_id,
                   revision,
                   cost_type_id,
                   cost_group_id,
                   from_organization_id,
                   to_organization_id,
                   rollback_qty,
                   intransit_inv_account,
                   shipment_line_id
                 )
          SELECT 7, -- UNCOSTED_INTRANSIT
                 DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_organization_id,
                   2,MMT.organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 SUM(
                   DECODE(
                     NVL(MMT.fob_point,MIP.fob_point),
                     1,
                     inv_convert.inv_um_convert(
                       MMT.inventory_item_id,NULL,MMT.transaction_quantity,
                       MMT.transaction_uom,MSI_TO.primary_uom_code,NULL,NULL
                     ),
                     2,
                     MMT.primary_quantity
                   )
                 ),
                 NVL(MMT.intransit_account,MIP.intransit_inv_account),
                 RSL.shipment_line_id
          FROM   mtl_material_transactions MMT,
                 cst_item_list_temp ITEMS,
                 cst_cg_list_temp CGS,
                 mtl_interorg_parameters MIP,
                 mtl_system_items MSI_TO,
                 rcv_shipment_headers RSH,
                 rcv_shipment_lines RSL
          WHERE  MMT.organization_id = p_organization_id
          AND    MMT.transaction_action_id = 21
          AND    MMT.costed_flag IN ('N','E')
          AND    MMT.inventory_item_id = ITEMS.inventory_item_id
          AND    DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_cost_group_id,
                   2,MMT.cost_group_id
                 ) =
                 CGS.cost_group_id
          AND    MIP.to_organization_id = MMT.transfer_organization_id
          AND    MIP.from_organization_id = MMT.organization_id
          AND    MSI_TO.organization_id = MMT.transfer_organization_id
          AND    MSI_TO.inventory_item_id = MMT.inventory_item_id
          AND    RSH.shipment_num = MMT.shipment_number
          AND    RSL.shipment_header_id = RSH.shipment_header_id
          AND    RSL.mmt_transaction_id = MMT.transaction_id
          GROUP
          BY     DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_organization_id,
                   2,MMT.organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 NVL(MMT.intransit_account,MIP.intransit_inv_account),
                 RSL.shipment_line_id;

          IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
          THEN
            FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => G_PKG_NAME,
              p_procedure_name => l_api_name,
              p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                              ' uncosted intransit shipment quantities going out'||
                              ' of the current organization'
            );
          END IF;

          -- Calculate uncosted intransit receipt quantities going out of this
          -- organization. The code for this calculation is similar to the one used
          -- to calculate uncosted intransit receipt quantities going out of this
          -- organization. The only difference is instead of checking for
          -- MMT.organization_id = p_organization_id, we check for
          -- MMT.organization_id = p_organization_id
          l_stmt_num := 80;
          INSERT
          INTO   cst_inv_qty_temp(
                   qty_source,
                   organization_id,
                   inventory_item_id,
                   category_id,
                   revision,
                   cost_type_id,
                   cost_group_id,
                   from_organization_id,
                   to_organization_id,
                   rollback_qty,
                   intransit_inv_account,
                   shipment_line_id
                 )
          SELECT 7, -- UNCOSTED_INTRANSIT
                 DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.organization_id,
                   2,MMT.transfer_organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.transfer_organization_id,
                 MMT.organization_id,
                 SUM(
                   DECODE(
                     NVL(MMT.fob_point,MIP.fob_point),
                     1,
                     MMT.primary_quantity,
                     2,
                     inv_convert.inv_um_convert(
                       MMT.inventory_item_id,NULL,MMT.transaction_quantity,
                       MMT.transaction_uom,MSI_FROM.primary_uom_code,NULL,NULL
                     )
                   )
                 ),
                 NVL(MMT.intransit_account, MIP.intransit_inv_account),
                 RT.shipment_line_id
          FROM   mtl_material_transactions MMT,
                 cst_item_list_temp ITEMS,
                 cst_cg_list_temp CGS,
                 mtl_interorg_parameters MIP,
                 mtl_system_items MSI_FROM,
                 rcv_transactions RT
          WHERE  MMT.transfer_organization_id = p_organization_id
          AND    MMT.transaction_action_id = 12
          AND    MMT.costed_flag IN ('N', 'E')
          AND    MMT.inventory_item_id = ITEMS.inventory_item_id
          AND    DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.cost_group_id,
                   2,MMT.transfer_cost_group_id
                 ) =
                 CGS.cost_group_id
          AND    MIP.to_organization_id = MMT.organization_id
          AND    MIP.from_organization_id = MMT.transfer_organization_id
          AND    MSI_FROM.organization_id = MMT.transfer_organization_id
          AND    MSI_FROM.inventory_item_id = MMT.inventory_item_id
          AND    RT.transaction_id = MMT.rcv_transaction_id
          GROUP
          BY     DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.organization_id,
                   2,MMT.transfer_organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 NVL(MMT.intransit_account, MIP.intransit_inv_account),
                 RT.shipment_line_id;

          IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
          THEN
            FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => G_PKG_NAME,
              p_procedure_name => l_api_name,
              p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                              ' uncosted intransit receipt quantities going out'||
                              ' of the current organization'
            );
          END IF;
         END IF; -- l_uncosted_txn_count >0
        END IF; -- NVL(p_unvalued_txns,-1) <> 1

        -- Calculate rollback intransit shipment quantities going out of this
        -- organization. The code for this calculation is similar to the one
        -- used to calculate uncosted intransit shipment quantities going out
        -- of this organization. The only difference is instead of checking for
        -- costed_flag in ('N','E'), we check for costed_flag is NULL and
        -- transaction_date > p_valuation_date
        IF p_valuation_date IS NOT NULL
        THEN
          l_stmt_num := 90;
          INSERT
          INTO   cst_inv_qty_temp(
                   qty_source,
                   organization_id,
                   inventory_item_id,
                   category_id,
                   revision,
                   cost_type_id,
                   cost_group_id,
                   from_organization_id,
                   to_organization_id,
                   rollback_qty,
                   intransit_inv_account,
                   shipment_line_id
                 )
          SELECT 8, -- ROLLBACK_INTRANSIT
                 DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_organization_id,
                   2,MMT.organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 SUM(
                   DECODE(
                     NVL(MMT.fob_point,MIP.fob_point),
                     1,
                     inv_convert.inv_um_convert(
                       MMT.inventory_item_id,NULL,MMT.transaction_quantity,
                       MMT.transaction_uom,MSI_TO.primary_uom_code,NULL,NULL
                     ),
                     2,
                     MMT.primary_quantity
                   )
                 ),
                 NVL(MMT.intransit_account,MIP.intransit_inv_account),
                 RSL.shipment_line_id
          FROM   mtl_material_transactions MMT,
                 cst_item_list_temp ITEMS,
                 cst_cg_list_temp CGS,
                 mtl_interorg_parameters MIP,
                 mtl_system_items MSI_TO,
                 rcv_shipment_headers RSH,
                 rcv_shipment_lines RSL
          WHERE  MMT.organization_id = p_organization_id
          AND    MMT.transaction_action_id = 21
          AND    MMT.costed_flag IS NULL
          AND    MMT.transaction_date > p_valuation_date
          AND    MMT.inventory_item_id = ITEMS.inventory_item_id
          AND    DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_cost_group_id,
                   2,MMT.cost_group_id
                 ) =
                 CGS.cost_group_id
          AND    MIP.to_organization_id = MMT.transfer_organization_id
          AND    MIP.from_organization_id = MMT.organization_id
          AND    MSI_TO.organization_id = MMT.transfer_organization_id
          AND    MSI_TO.inventory_item_id = MMT.inventory_item_id
          AND    RSH.shipment_num = MMT.shipment_number
          AND    RSL.shipment_header_id = RSH.shipment_header_id
          AND    RSL.mmt_transaction_id = MMT.transaction_id
          GROUP
          BY     DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_organization_id,
                   2,MMT.organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 NVL(MMT.intransit_account,MIP.intransit_inv_account),
                 RSL.shipment_line_id;

          IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
          THEN
            FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => G_PKG_NAME,
              p_procedure_name => l_api_name,
              p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                              ' rolled back intransit shipment quantities'||
                              ' going out of the current organization'
            );
          END IF;

          -- Calculate rollback intransit receipt quantities going out of this
          -- organization. The code for this calculation is similar to the one
          -- used to calculate uncosted intransit receipt quantities going out of
          -- this organization. The only difference is instead of checking for
          -- costed_flag in ('N','E'), we check for costed_flag is NULL and
          -- transaction_date > p_valuation_date
          l_stmt_num := 100;
          INSERT
          INTO   cst_inv_qty_temp(
                   qty_source,
                   organization_id,
                   inventory_item_id,
                   category_id,
                   revision,
                   cost_type_id,
                   cost_group_id,
                   from_organization_id,
                   to_organization_id,
                   rollback_qty,
                   intransit_inv_account,
                   shipment_line_id
                 )
          SELECT 8, -- ROLLBACK_INTRANSIT
                 DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.organization_id,
                   2,MMT.transfer_organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.transfer_organization_id,
                 MMT.organization_id,
                 SUM(
                   DECODE(
                     NVL(MMT.fob_point,MIP.fob_point),
                     1,
                     MMT.primary_quantity,
                     2,
                     inv_convert.inv_um_convert(
                       MMT.inventory_item_id,NULL,MMT.transaction_quantity,
                       MMT.transaction_uom,MSI_FROM.primary_uom_code,NULL,NULL
                     )
                   )
                 ),
                 NVL(MMT.intransit_account, MIP.intransit_inv_account),
                 RT.shipment_line_id
          FROM   mtl_material_transactions MMT,
                 cst_item_list_temp ITEMS,
                 cst_cg_list_temp CGS,
                 mtl_interorg_parameters MIP,
                 mtl_system_items MSI_FROM,
                 rcv_transactions RT
          WHERE  MMT.transfer_organization_id = p_organization_id
          AND    MMT.transaction_action_id = 12
          AND    MMT.costed_flag IS NULL
          AND    MMT.transaction_date > p_valuation_date
          AND    MMT.inventory_item_id = ITEMS.inventory_item_id
          AND    DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.cost_group_id,
                   2,MMT.transfer_cost_group_id
                 ) =
                 CGS.cost_group_id
          AND    MIP.to_organization_id = MMT.organization_id
          AND    MIP.from_organization_id = MMT.transfer_organization_id
          AND    MSI_FROM.organization_id = MMT.transfer_organization_id
          AND    MSI_FROM.inventory_item_id = MMT.inventory_item_id
          AND    RT.transaction_id = MMT.rcv_transaction_id
          GROUP
          BY     DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.organization_id,
                   2,MMT.transfer_organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 NVL(MMT.intransit_account, MIP.intransit_inv_account),
                 RT.shipment_line_id;

          IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
          THEN
            FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => G_PKG_NAME,
              p_procedure_name => l_api_name,
              p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                              ' rolled back intransit shipment quantities'||
                              ' going out of the current organization'
            );
          END IF;
        END IF; -- p_valuation_date IS NOT NULL
      END IF; -- p_shipment = 1
    ELSE -- p_detail <> 1
      -- This calculation is very similar to the shipment line level calculation
      -- (stmt 10-100). The difference is that the join to RSL, RSH and RT is
      -- avoided when possible, resulting in a better performance

      -- All intransit calculations are for quantities that are related
      -- to p_organization_id, but not neccessarily owned by it. This is
      -- necessary for the Intransit Valuation Report.

      -- Calculate intransit quantity coming into this organization
      IF p_receipt = 1
      THEN
        -- Calculate current intransit quantity coming into this organization
        l_stmt_num := 110;
        INSERT
        INTO   cst_inv_qty_temp(
                 qty_source,
                 organization_id,
                 inventory_item_id,
                 category_id,
                 revision,
                 cost_type_id,
                 cost_group_id,
                 from_organization_id,
                 to_organization_id,
                 rollback_qty,
                 intransit_inv_account
               )
        SELECT 6,-- CURRENT_INTRANSIT
               MS.intransit_owning_org_id,
               ITEMS.inventory_item_id,
               ITEMS.category_id,
               MS.item_revision,
               ITEMS.cost_type_id,
               CGS.cost_group_id,
               MS.from_organization_id,
               MS.to_organization_id,
               -- quantity is always expressed in the primary unit of measure
               -- of the intransit owning organization
               SUM(
                 DECODE(
                   MS.intransit_owning_org_id,
                   MS.from_organization_id,
                   inv_convert.inv_um_convert(
                     MS.item_id,NULL,MS.quantity,NULL,NULL,
                     MS.unit_of_measure,MSI_FROM.primary_unit_of_measure
                   ),
                   MS.to_org_primary_quantity
                 )
               ),
               NVL(
                 MMT.intransit_account,
                 NVL(MIP.intransit_inv_account,MP.intransit_inv_account)
               )
        FROM   mtl_supply MS,
               cst_item_list_temp ITEMS,
               cst_cg_list_temp CGS,
               mtl_parameters MP,
               mtl_interorg_parameters MIP,
               mtl_material_transactions MMT,
               rcv_shipment_lines RSL,
               mtl_system_items MSI_FROM
        WHERE  MS.to_organization_id = p_organization_id
      /*  AND    MS.intransit_owning_org_id = p_organization_id */ /* Bug 5664736 */
      	AND    MS.intransit_owning_org_id = DECODE(NVL(p_own,-1),1,p_organization_id,MS.intransit_owning_org_id)
        AND    MS.item_id = ITEMS.inventory_item_id
        AND    MS.supply_type_code IN ('SHIPMENT','RECEIVING')
        AND    MS.destination_type_code = 'INVENTORY'
        AND    NVL(MS.cost_group_id,MP.default_cost_group_id) = CGS.cost_group_id
        AND    MP.organization_id = MS.intransit_owning_org_id
        AND    RSL.shipment_line_id = MS.shipment_line_id
        AND    MMT.transaction_id (+) = RSL.mmt_transaction_id
        AND    MIP.from_organization_id (+) = MS.from_organization_id
        AND    MIP.to_organization_id (+) = MS.to_organization_id
        AND    MIP.fob_point (+) =
               DECODE(
                 MS.intransit_owning_org_id,
                 MS.from_organization_id, 2,
                 MS.to_organization_id, 1
               )
        AND    MSI_FROM.inventory_item_id = MS.item_id
        AND    MSI_FROM.organization_id = MS.from_organization_id
        GROUP
        BY     MS.intransit_owning_org_id,
               ITEMS.inventory_item_id,
               ITEMS.category_id,
               MS.item_revision,
               ITEMS.cost_type_id,
               CGS.cost_group_id,
               MS.from_organization_id,
               MS.to_organization_id,
               NVL(
                 MMT.intransit_account,
                 NVL(MIP.intransit_inv_account,MP.intransit_inv_account)
               );

        IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
        THEN
          FND_MSG_PUB.Add_Exc_Msg(
            p_pkg_name => G_PKG_NAME,
            p_procedure_name => l_api_name,
            p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                            ' current intransit quantities coming into the'||
                            ' current organization'
          );
        END IF;

        -- Calculate uncosted intransit shipment quantities coming into this
        -- organization
        IF NVL(p_unvalued_txns,-1) <> 1 THEN
         IF l_uncosted_txn_count > 0 THEN --BUG#6109468-FPBUG5606455
          l_stmt_num := 120;
          INSERT
          INTO   cst_inv_qty_temp(
                   qty_source,
                   organization_id,
                   inventory_item_id,
                   category_id,
                   revision,
                   cost_type_id,
                   cost_group_id,
                   from_organization_id,
                   to_organization_id,
                   rollback_qty,
                   intransit_inv_account
                 )
          SELECT 7, -- UNCOSTED_INTRANSIT
                 DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_organization_id,
                   2,MMT.organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 SUM(
                   DECODE(
                     NVL(MMT.fob_point,MIP.fob_point),
                     1,
                     inv_convert.inv_um_convert(
                       MMT.inventory_item_id,NULL,MMT.transaction_quantity,
                       MMT.transaction_uom,MSI_TO.primary_uom_code,NULL,NULL
                     ),
                     2,
                     MMT.primary_quantity
                   )
                 ),
                 NVL(MMT.intransit_account,MIP.intransit_inv_account)
          FROM   mtl_material_transactions MMT,
                 cst_item_list_temp ITEMS,
                 cst_cg_list_temp CGS,
                 mtl_interorg_parameters MIP,
                 mtl_system_items MSI_TO
          WHERE  MMT.transfer_organization_id = p_organization_id
          AND    MMT.transaction_action_id = 21
          AND    MMT.costed_flag IN ('N','E')
          AND    MMT.inventory_item_id = ITEMS.inventory_item_id
          AND    DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_cost_group_id,
                   2,MMT.cost_group_id
                 ) =
                 CGS.cost_group_id
          AND    MIP.to_organization_id = MMT.transfer_organization_id
          AND    MIP.from_organization_id = MMT.organization_id
          AND    MSI_TO.organization_id = MMT.transfer_organization_id
          AND    MSI_TO.inventory_item_id = MMT.inventory_item_id
          GROUP
          BY     DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_organization_id,
                   2,MMT.organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 NVL(MMT.intransit_account,MIP.intransit_inv_account);

          IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
          THEN
            FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => G_PKG_NAME,
              p_procedure_name => l_api_name,
              p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                              ' uncosted intransit shipment quantities coming'||
                              ' into the current organization'
            );
          END IF;

          -- Calculate uncosted intransit receipt quantities coming into this
          -- organization
          l_stmt_num := 130;
          INSERT
          INTO   cst_inv_qty_temp(
                   qty_source,
                   organization_id,
                   inventory_item_id,
                   category_id,
                   revision,
                   cost_type_id,
                   cost_group_id,
                   from_organization_id,
                   to_organization_id,
                   rollback_qty,
                   intransit_inv_account
                 )
          SELECT 7, -- UNCOSTED_INTRANSIT
                 DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.organization_id,
                   2,MMT.transfer_organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.transfer_organization_id,
                 MMT.organization_id,
                 SUM(
                   DECODE(
                     NVL(MMT.fob_point,MIP.fob_point),
                     1,
                     MMT.primary_quantity,
                     2,
                     inv_convert.inv_um_convert(
                       MMT.inventory_item_id,NULL,MMT.transaction_quantity,
                       MMT.transaction_uom,MSI_FROM.primary_uom_code,NULL,NULL
                     )
                   )
                 ),
                 NVL(MMT.intransit_account, MIP.intransit_inv_account)
          FROM   mtl_material_transactions MMT,
                 cst_item_list_temp ITEMS,
                 cst_cg_list_temp CGS,
                 mtl_interorg_parameters MIP,
                 mtl_system_items MSI_FROM
          WHERE  MMT.organization_id = p_organization_id
          AND    MMT.transaction_action_id = 12
          AND    MMT.costed_flag IN ('N', 'E')
          AND    MMT.inventory_item_id = ITEMS.inventory_item_id
          AND    DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.cost_group_id,
                   2,MMT.transfer_cost_group_id
                 ) =
                 CGS.cost_group_id
          AND    MIP.to_organization_id = MMT.organization_id
          AND    MIP.from_organization_id = MMT.transfer_organization_id
          AND    MSI_FROM.organization_id = MMT.transfer_organization_id
          AND    MSI_FROM.inventory_item_id = MMT.inventory_item_id
          GROUP
          BY     DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.organization_id,
                   2,MMT.transfer_organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 NVL(MMT.intransit_account, MIP.intransit_inv_account);

          IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
          THEN
            FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => G_PKG_NAME,
              p_procedure_name => l_api_name,
              p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                              ' uncosted intransit receipt quantities coming'||
                              ' into the current org'
            );
          END IF;
         END IF; --l_uncosted_txn_count>0
        END IF; -- NVL(p_unvalued_txns,-1) <> 1

        IF p_valuation_date IS NOT NULL
        THEN
          -- Calculate rollback intransit shipment quantities coming into this
          -- organization. The code for this calculation is similar to the one used
          -- to calculate uncosted intransit shipment quantities coming into this
          -- organization. The only difference is instead of checking for
          -- costed_flag in ('N','E'), we check for costed_flag is NULL and
          -- transaction_date > p_valuation_date
          l_stmt_num := 140;
          INSERT
          INTO   cst_inv_qty_temp(
                   qty_source,
                   organization_id,
                   inventory_item_id,
                   category_id,
                   revision,
                   cost_type_id,
                   cost_group_id,
                   from_organization_id,
                   to_organization_id,
                   rollback_qty,
                   intransit_inv_account
                 )
          SELECT 8, -- ROLLBACK_INTRANSIT
                 DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_organization_id,
                   2,MMT.organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 SUM(
                   DECODE(
                     NVL(MMT.fob_point,MIP.fob_point),
                     1,
                     inv_convert.inv_um_convert(
                       MMT.inventory_item_id,NULL,MMT.transaction_quantity,
                       MMT.transaction_uom,MSI_TO.primary_uom_code,NULL,NULL
                     ),
                     2,
                     MMT.primary_quantity
                   )
                 ),
                 NVL(MMT.intransit_account,MIP.intransit_inv_account)
          FROM   mtl_material_transactions MMT,
                 cst_item_list_temp ITEMS,
                 cst_cg_list_temp CGS,
                 mtl_interorg_parameters MIP,
                 mtl_system_items MSI_TO,
		  mtl_transaction_types MTT
          WHERE  MMT.transfer_organization_id = p_organization_id
          AND    MMT.transaction_action_id = 21
          AND    MMT.costed_flag IS NULL
          AND    MMT.transaction_date > p_valuation_date
          AND    MMT.inventory_item_id = ITEMS.inventory_item_id
          AND    DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_cost_group_id,
                   2,MMT.cost_group_id
                 ) =
                 CGS.cost_group_id
          AND    MIP.to_organization_id = MMT.transfer_organization_id
          AND    MIP.from_organization_id = MMT.organization_id
          AND    MSI_TO.organization_id = MMT.transfer_organization_id
          AND    MSI_TO.inventory_item_id = MMT.inventory_item_id
	  AND    MTT.transaction_action_id = MMT.transaction_action_id
 	  AND    MTT.transaction_source_type_id = MMT.transaction_source_type_id
 	  AND    MTT.transaction_type_id = MMT.transaction_type_id
          GROUP
          BY     DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_organization_id,
                   2,MMT.organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 NVL(MMT.intransit_account,MIP.intransit_inv_account);

          IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
          THEN
            FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => G_PKG_NAME,
              p_procedure_name => l_api_name,
              p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                              ' rolled back intransit shipment quantities'||
                              ' coming into the current org'
            );
          END IF;

          -- Calculate rollback intransit receipt quantities coming into this
          -- organization. The code for this calculation is similar to the one
          -- used to calculate uncosted intransit receipt quantities coming into
          -- this organization. The only difference is instead of checking for
          -- costed_flag in ('N','E'), we check for costed_flag is NULL and
          -- transaction_date > p_valuation_date
          l_stmt_num := 150;
          INSERT
          INTO   cst_inv_qty_temp(
                   qty_source,
                   organization_id,
                   inventory_item_id,
                   category_id,
                   revision,
                   cost_type_id,
                   cost_group_id,
                   from_organization_id,
                   to_organization_id,
                   rollback_qty,
                   intransit_inv_account
                 )
          SELECT 8, -- ROLLBACK_INTRANSIT
                 DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.organization_id,
                   2,MMT.transfer_organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.transfer_organization_id,
                 MMT.organization_id,
                 SUM(
                   DECODE(
                     NVL(MMT.fob_point,MIP.fob_point),
                     1,
                     MMT.primary_quantity,
                     2,
                     inv_convert.inv_um_convert(
                       MMT.inventory_item_id,NULL,MMT.transaction_quantity,
                       MMT.transaction_uom,MSI_FROM.primary_uom_code,NULL,NULL
                     )
                   )
                 ),
                 NVL(MMT.intransit_account, MIP.intransit_inv_account)
          FROM   mtl_material_transactions MMT,
                 cst_item_list_temp ITEMS,
                 cst_cg_list_temp CGS,
                 mtl_interorg_parameters MIP,
                 mtl_system_items MSI_FROM,
		  mtl_transaction_types MTT
          WHERE  MMT.organization_id = p_organization_id
          AND    MMT.transaction_action_id = 12
          AND    MMT.costed_flag IS NULL
          AND    MMT.transaction_date > p_valuation_date
          AND    MMT.inventory_item_id = ITEMS.inventory_item_id
          AND    DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.cost_group_id,
                   2,MMT.transfer_cost_group_id
                 ) =
                 CGS.cost_group_id
          AND    MIP.to_organization_id = MMT.organization_id
          AND    MIP.from_organization_id = MMT.transfer_organization_id
          AND    MSI_FROM.organization_id = MMT.transfer_organization_id
          AND    MSI_FROM.inventory_item_id = MMT.inventory_item_id
	  AND    MTT.transaction_action_id = MMT.transaction_action_id
          AND    MTT.transaction_source_type_id = MMT.transaction_source_type_id
          AND    MTT.transaction_type_id = MMT.transaction_type_id
          GROUP
          BY     DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.organization_id,
                   2,MMT.transfer_organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 NVL(MMT.intransit_account, MIP.intransit_inv_account);

          IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
          THEN
            FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => G_PKG_NAME,
              p_procedure_name => l_api_name,
              p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                              ' rolled back intransit shipment quantities'||
                              ' coming into the current organization'
            );
          END IF;
        END IF; -- p_valuation_date IS NOT NULL
      END IF; -- p_receipt = 1

      IF p_shipment = 1 THEN
        -- Calculate current intransit quantity going out of this organization
        -- The code for this calculation is similar to the one used to calculate
        -- current intransit quantities coming into this organization. The only
        -- difference is instead of checking for MS.to_organization_id =
        -- p_organization_id, we check for MS.from_organization_id =
        -- p_organization_id
        l_stmt_num := 60;
        INSERT
        INTO   cst_inv_qty_temp(
                 qty_source,
                 organization_id,
                 inventory_item_id,
                 category_id,
                 revision,
                 cost_type_id,
                 cost_group_id,
                 from_organization_id,
                 to_organization_id,
                 rollback_qty,
                 intransit_inv_account
               )
        SELECT 6,-- CURRENT_INTRANSIT
               MS.intransit_owning_org_id,
               ITEMS.inventory_item_id,
               ITEMS.category_id,
               MS.item_revision,
               ITEMS.cost_type_id,
               CGS.cost_group_id,
               MS.from_organization_id,
               MS.to_organization_id,
               SUM(
                 DECODE(
                   MS.intransit_owning_org_id,
                   MS.from_organization_id,
                   inv_convert.inv_um_convert(
                     MS.item_id,NULL,MS.quantity,NULL,NULL,
                     MS.unit_of_measure,MSI_FROM.primary_unit_of_measure
                   ),
                   MS.to_org_primary_quantity
                 )
               ),
               NVL(
                 MMT.intransit_account,
                 NVL(MIP.intransit_inv_account,MP.intransit_inv_account)
               )
        FROM   mtl_supply MS,
               cst_item_list_temp ITEMS,
               cst_cg_list_temp CGS,
               mtl_parameters MP,
               mtl_interorg_parameters MIP,
               mtl_material_transactions MMT,
               rcv_shipment_lines RSL,
               mtl_system_items MSI_FROM
        WHERE  MS.from_organization_id = p_organization_id
      /*  AND    MS.intransit_owning_org_id = p_organization_id */ /* Bug 5664736 */
      	AND    MS.intransit_owning_org_id = DECODE(NVL(p_own,-1),1,p_organization_id,MS.intransit_owning_org_id)
        AND    MS.item_id = ITEMS.inventory_item_id
        AND    MS.supply_type_code IN ('SHIPMENT','RECEIVING')
        AND    MS.destination_type_code = 'INVENTORY'
        AND    NVL(MS.cost_group_id,MP.default_cost_group_id) = CGS.cost_group_id
        AND    MP.organization_id = MS.intransit_owning_org_id
        AND    RSL.shipment_line_id = MS.shipment_line_id
        AND    MMT.transaction_id (+) = RSL.mmt_transaction_id
        AND    MIP.from_organization_id (+) = MS.from_organization_id
        AND    MIP.to_organization_id (+) = MS.to_organization_id
        AND    MIP.fob_point (+) =
               DECODE(
                 MS.intransit_owning_org_id,
                 MS.from_organization_id, 2,
                 MS.to_organization_id, 1)
        AND    MSI_FROM.inventory_item_id = MS.item_id
        AND    MSI_FROM.organization_id = MS.from_organization_id
        GROUP
        BY     MS.intransit_owning_org_id,
               ITEMS.inventory_item_id,
               ITEMS.category_id,
               MS.item_revision,
               ITEMS.cost_type_id,
               CGS.cost_group_id,
               MS.from_organization_id,
               MS.to_organization_id,
               NVL(
                 MMT.intransit_account,
                 NVL(MIP.intransit_inv_account,MP.intransit_inv_account)
               );

        IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
        THEN
          FND_MSG_PUB.Add_Exc_Msg(
            p_pkg_name => G_PKG_NAME,
            p_procedure_name => l_api_name,
            p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                            ' current intransit quantities going out of the'||
                            ' current organization'
          );
        END IF;

        IF NVL(p_unvalued_txns,-1) <> 1 THEN
          -- Calculate uncosted intransit shipment quantities going out of this
          -- organization. The code for this calculation is similar to the one used
          -- to calculate uncosted intransit shipment quantities coming into this
          -- organization. The only difference is instead of checking for
          -- MMT.transfer_organization_id = p_organization_id, we check for
          -- MMT.organization_id = p_organization_id
         IF l_uncosted_txn_count >0 THEN --BUG6109468-FPBUG5606455
          l_stmt_num := 70;
          INSERT
          INTO   cst_inv_qty_temp(
                   qty_source,
                   organization_id,
                   inventory_item_id,
                   category_id,
                   revision,
                   cost_type_id,
                   cost_group_id,
                   from_organization_id,
                   to_organization_id,
                   rollback_qty,
                   intransit_inv_account
                 )
          SELECT 7, -- UNCOSTED_INTRANSIT
                 DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_organization_id,
                   2,MMT.organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 SUM(
                   DECODE(
                     NVL(MMT.fob_point,MIP.fob_point),
                     1,
                     inv_convert.inv_um_convert(
                       MMT.inventory_item_id,NULL,MMT.transaction_quantity,
                       MMT.transaction_uom,MSI_TO.primary_uom_code,NULL,NULL
                     ),
                     2,
                     MMT.primary_quantity
                   )
                 ),
                 NVL(MMT.intransit_account,MIP.intransit_inv_account)
          FROM   mtl_material_transactions MMT,
                 cst_item_list_temp ITEMS,
                 cst_cg_list_temp CGS,
                 mtl_interorg_parameters MIP,
                 mtl_system_items MSI_TO
          WHERE  MMT.organization_id = p_organization_id
          AND    MMT.transaction_action_id = 21
          AND    MMT.costed_flag IN ('N','E')
          AND    MMT.inventory_item_id = ITEMS.inventory_item_id
          AND    DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_cost_group_id,
                   2,MMT.cost_group_id
                 ) =
                 CGS.cost_group_id
          AND    MIP.to_organization_id = MMT.transfer_organization_id
          AND    MIP.from_organization_id = MMT.organization_id
          AND    MSI_TO.organization_id = MMT.transfer_organization_id
          AND    MSI_TO.inventory_item_id = MMT.inventory_item_id
          GROUP
          BY     DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_organization_id,
                   2,MMT.organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 NVL(MMT.intransit_account,MIP.intransit_inv_account);

          IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
          THEN
            FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => G_PKG_NAME,
              p_procedure_name => l_api_name,
              p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                              ' uncosted intransit shipment quantities going out'||
                              ' of the current organization'
            );
          END IF;

          -- Calculate uncosted intransit receipt quantities going out of this
          -- organization. The code for this calculation is similar to the one used
          -- to calculate uncosted intransit receipt quantities going out of this
          -- organization. The only difference is instead of checking for
          -- MMT.organization_id = p_organization_id, we check for
          -- MMT.organization_id = p_organization_id
          l_stmt_num := 80;
          INSERT
          INTO   cst_inv_qty_temp(
                   qty_source,
                   organization_id,
                   inventory_item_id,
                   category_id,
                   revision,
                   cost_type_id,
                   cost_group_id,
                   from_organization_id,
                   to_organization_id,
                   rollback_qty,
                   intransit_inv_account
                 )
          SELECT 7, -- UNCOSTED_INTRANSIT
                 DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.organization_id,
                   2,MMT.transfer_organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.transfer_organization_id,
                 MMT.organization_id,
                 SUM(
                   DECODE(
                     NVL(MMT.fob_point,MIP.fob_point),
                     1,
                     MMT.primary_quantity,
                     2,
                     inv_convert.inv_um_convert(
                       MMT.inventory_item_id,NULL,MMT.transaction_quantity,
                       MMT.transaction_uom,MSI_FROM.primary_uom_code,NULL,NULL
                     )
                   )
                 ),
                 NVL(MMT.intransit_account, MIP.intransit_inv_account)
          FROM   mtl_material_transactions MMT,
                 cst_item_list_temp ITEMS,
                 cst_cg_list_temp CGS,
                 mtl_interorg_parameters MIP,
                 mtl_system_items MSI_FROM
          WHERE  MMT.transfer_organization_id = p_organization_id
          AND    MMT.transaction_action_id = 12
          AND    MMT.costed_flag IN ('N', 'E')
          AND    MMT.inventory_item_id = ITEMS.inventory_item_id
          AND    DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.cost_group_id,
                   2,MMT.transfer_cost_group_id
                 ) =
                 CGS.cost_group_id
          AND    MIP.to_organization_id = MMT.organization_id
          AND    MIP.from_organization_id = MMT.transfer_organization_id
          AND    MSI_FROM.organization_id = MMT.transfer_organization_id
          AND    MSI_FROM.inventory_item_id = MMT.inventory_item_id
          GROUP
          BY     DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.organization_id,
                   2,MMT.transfer_organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 NVL(MMT.intransit_account, MIP.intransit_inv_account);

          IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
          THEN
            FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => G_PKG_NAME,
              p_procedure_name => l_api_name,
              p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                              ' uncosted intransit receipt quantities going out'||
                              ' of the current organization'
            );
          END IF;
         END IF; --l_uncosted_txn_count > 0
        END IF; -- NVL(p_unvalued_txns,-1) <> 1

        -- Calculate rollback intransit shipment quantities going out of this
        -- organization. The code for this calculation is similar to the one
        -- used to calculate uncosted intransit shipment quantities going out
        -- of this organization. The only difference is instead of checking for
        -- costed_flag in ('N','E'), we check for costed_flag is NULL and
        -- transaction_date > p_valuation_date
        IF p_valuation_date IS NOT NULL
        THEN
          l_stmt_num := 90;
          INSERT
          INTO   cst_inv_qty_temp(
                   qty_source,
                   organization_id,
                   inventory_item_id,
                   category_id,
                   revision,
                   cost_type_id,
                   cost_group_id,
                   from_organization_id,
                   to_organization_id,
                   rollback_qty,
                   intransit_inv_account
                 )
          SELECT 8, -- ROLLBACK_INTRANSIT
                 DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_organization_id,
                   2,MMT.organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 SUM(
                   DECODE(
                     NVL(MMT.fob_point,MIP.fob_point),
                     1,
                     inv_convert.inv_um_convert(
                       MMT.inventory_item_id,NULL,MMT.transaction_quantity,
                       MMT.transaction_uom,MSI_TO.primary_uom_code,NULL,NULL
                     ),
                     2,
                     MMT.primary_quantity
                   )
                 ),
                 NVL(MMT.intransit_account,MIP.intransit_inv_account)
          FROM   mtl_material_transactions MMT,
                 cst_item_list_temp ITEMS,
                 cst_cg_list_temp CGS,
                 mtl_interorg_parameters MIP,
                 mtl_system_items MSI_TO,
                 mtl_transaction_types MTT
          WHERE  MMT.organization_id = p_organization_id
          AND    MMT.transaction_action_id = 21
          AND    MMT.costed_flag IS NULL
          AND    MMT.transaction_date > p_valuation_date
          AND    MMT.inventory_item_id = ITEMS.inventory_item_id
          AND    DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_cost_group_id,
                   2,MMT.cost_group_id
                 ) =
                 CGS.cost_group_id
          AND    MIP.to_organization_id = MMT.transfer_organization_id
          AND    MIP.from_organization_id = MMT.organization_id
          AND    MSI_TO.organization_id = MMT.transfer_organization_id
          AND    MSI_TO.inventory_item_id = MMT.inventory_item_id
	   AND    MTT.transaction_action_id = MMT.transaction_action_id
           AND    MTT.transaction_source_type_id = MMT.transaction_source_type_id
           AND    MTT.transaction_type_id = MMT.transaction_type_id
          GROUP
          BY     DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.transfer_organization_id,
                   2,MMT.organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 NVL(MMT.intransit_account,MIP.intransit_inv_account);

          IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
          THEN
            FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => G_PKG_NAME,
              p_procedure_name => l_api_name,
              p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                              ' rolled back intransit shipment quantities'||
                              ' going out of the current organization'
            );
          END IF;

          -- Calculate rollback intransit receipt quantities going out of this
          -- organization. The code for this calculation is similar to the one
          -- used to calculate uncosted intransit receipt quantities going out of
          -- this organization. The only difference is instead of checking for
          -- costed_flag in ('N','E'), we check for costed_flag is NULL and
          -- transaction_date > p_valuation_date
          l_stmt_num := 200;
          INSERT
          INTO   cst_inv_qty_temp(
                   qty_source,
                   organization_id,
                   inventory_item_id,
                   category_id,
                   revision,
                   cost_type_id,
                   cost_group_id,
                   from_organization_id,
                   to_organization_id,
                   rollback_qty,
                   intransit_inv_account
                 )
          SELECT 8, -- ROLLBACK_INTRANSIT
                 DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.organization_id,
                   2,MMT.transfer_organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.transfer_organization_id,
                 MMT.organization_id,
                 SUM(
                   DECODE(
                     NVL(MMT.fob_point,MIP.fob_point),
                     1,
                     MMT.primary_quantity,
                     2,
                     inv_convert.inv_um_convert(
                       MMT.inventory_item_id,NULL,MMT.transaction_quantity,
                       MMT.transaction_uom,MSI_FROM.primary_uom_code,NULL,NULL
                     )
                   )
                 ),
                 NVL(MMT.intransit_account, MIP.intransit_inv_account)
          FROM   mtl_material_transactions MMT,
                 cst_item_list_temp ITEMS,
                 cst_cg_list_temp CGS,
                 mtl_interorg_parameters MIP,
                 mtl_system_items MSI_FROM,
                 mtl_transaction_types MTT
          WHERE  MMT.transfer_organization_id = p_organization_id
          AND    MMT.transaction_action_id = 12
          AND    MMT.costed_flag IS NULL
          AND    MMT.transaction_date > p_valuation_date
          AND    MMT.inventory_item_id = ITEMS.inventory_item_id
          AND    DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.cost_group_id,
                   2,MMT.transfer_cost_group_id
                 ) =
                 CGS.cost_group_id
          AND    MIP.to_organization_id = MMT.organization_id
          AND    MIP.from_organization_id = MMT.transfer_organization_id
          AND    MSI_FROM.organization_id = MMT.transfer_organization_id
          AND    MSI_FROM.inventory_item_id = MMT.inventory_item_id
          AND    MTT.transaction_action_id = MMT.transaction_action_id
 	  AND    MTT.transaction_source_type_id = MMT.transaction_source_type_id
 	  AND    MTT.transaction_type_id = MMT.transaction_type_id
          GROUP
          BY     DECODE(
                   NVL(MMT.fob_point,MIP.fob_point),
                   1,MMT.organization_id,
                   2,MMT.transfer_organization_id
                 ),
                 ITEMS.inventory_item_id,
                 ITEMS.category_id,
                 MMT.revision,
                 ITEMS.cost_type_id,
                 CGS.cost_group_id,
                 MMT.organization_id,
                 MMT.transfer_organization_id,
                 NVL(MMT.intransit_account, MIP.intransit_inv_account);

          IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
          THEN
            FND_MSG_PUB.Add_Exc_Msg(
              p_pkg_name => G_PKG_NAME,
              p_procedure_name => l_api_name,
              p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                              ' rolled back intransit shipment quantities'||
                              ' going out of the current organization'
            );
          END IF;
        END IF; -- p_valuation_date IS NOT NULL
      END IF; -- p_shipment = 1
    END IF; -- p_detail = 1

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Calculate_IntransitQty_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      ROLLBACK TO Calculate_IntransitQty_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => SUBSTR(l_stmt_num||SQLERRM,1,240)
        );
      END IF;

  END Calculate_IntransitQty;

  PROCEDURE Calculate_ReceivingQty(
    p_api_version          IN         NUMBER,
    p_organization_id      IN         NUMBER,
    p_valuation_date       IN         DATE,
    p_qty_by_revision      IN         NUMBER,
    p_include_period_end IN  NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'Calculate_ReceivingQty';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_level_threshold NUMBER;
    l_stmt_num NUMBER := 0;
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Calculate_ReceivingQty_PVT;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call(
             p_current_version_number => l_api_version,
             p_caller_version_number => p_api_version,
             p_api_name => l_api_name,
             p_pkg_name => G_PKG_NAME
           )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check for message level threshold
    l_msg_level_threshold := FND_PROFILE.Value('FND_AS_MSG_LEVEL_THRESHOLD');

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => SUBSTR(
                          l_stmt_num||':'||
                          p_organization_id||','||
                          p_valuation_date||','||
                          p_qty_by_revision||','||
                          p_include_period_end,
                          1,
                          240
                        )
      );
    END IF;

    -- Calculate current receiving quantity with qty_source = 9
    -- Release 12i: Modified to store quantities always by the parent
    -- RECEIVE or MATCH transaction.  Prior to 12i, quantity was always
    -- stored by the rcv_transaction_id stored in MTL_SUPPLY, which was
    -- the parent RECEIVE or MATCH with the exception of cases in which
    -- there was an Accept/Reject/Transfer transaction.
    l_stmt_num := 10;
    INSERT
    INTO   cst_inv_qty_temp(
             qty_source,
             organization_id,
             inventory_item_id,
             category_id,
             cost_type_id,
             rcv_transaction_id,
             revision,
             rollback_qty
           )
    SELECT 9, -- RECEIVED
           MS.to_organization_id,
           CILT.inventory_item_id,
           DECODE(MS.item_id, NULL, POL.category_id, CILT.category_id),
           CILT.cost_type_id,
           DECODE(RT.transaction_type,
            'ACCEPT', Get_ParentReceiveTxn(MS.rcv_transaction_id),
            'REJECT', Get_ParentReceiveTxn(MS.rcv_transaction_id),
            'TRANSFER', Get_ParentReceiveTxn(MS.rcv_transaction_id),
            (MS.rcv_transaction_id)),
            -- MTL_SUPPLY stores parent Match/Receive except for Accept/Reject/Transfers
           DECODE(p_qty_by_revision, 1, POL.item_revision, NULL),
           SUM(MS.to_org_primary_quantity) -- sum across po distributions
    FROM   cst_item_list_temp CILT,
           cst_cg_list_temp CCLT,
           mtl_supply MS,
           rcv_transactions RT,
           mtl_parameters MP,
           po_lines_all POL,
           po_line_locations_all POLL,
           pjm_project_parameters PPP
    WHERE  NVL(CILT.inventory_item_id, -1) = NVL(MS.item_id, -1)
    AND    MP.organization_id = MS.to_organization_id
    AND    MS.to_organization_id = p_organization_id
    AND    NVL(
             MS.cost_group_id,
             NVL(PPP.costing_group_id,MP.default_cost_group_id)
           ) = CCLT.cost_group_id
    AND    MS.supply_type_code = 'RECEIVING'
    AND    RT.transaction_id = MS.rcv_transaction_id
           -- Joining to MS eliminates consigned and drop ship receipts
    AND    NVL(RT.consigned_flag, 'N') = 'N' -- eliminate consigned
    AND    RT.source_document_code = 'PO'
    AND    POL.po_line_id = RT.po_line_id
    AND    PPP.project_id (+) = POL.project_id
    AND    POLL.line_location_id = RT.po_line_location_id
    AND    POLL.shipment_type <> 'PREPAYMENT'
    AND    POLL.matching_basis = 'QUANTITY'  -- eliminate service line types
    AND    POLL.accrue_on_receipt_flag = DECODE(p_include_period_end, 1, POLL.accrue_on_receipt_flag, 'Y')
    GROUP
    BY     MS.to_organization_id,
           CILT.inventory_item_id,
           DECODE(MS.item_id, NULL, POL.category_id, CILT.category_id),
           CILT.cost_type_id,
           DECODE(RT.transaction_type,
            'ACCEPT', Get_ParentReceiveTxn(MS.rcv_transaction_id),
            'REJECT', Get_ParentReceiveTxn(MS.rcv_transaction_id),
            'TRANSFER', Get_ParentReceiveTxn(MS.rcv_transaction_id),
            (MS.rcv_transaction_id)),
     DECODE(p_qty_by_revision, 1, POL.item_revision, NULL);

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                        ' current receiving quantities'
      );
    END IF;

    -- if p_valuation_date is called with a date in the past,
    -- calculate receiving quantity with qty_source = 10
    --
    -- Method: find all transactions in RT that impact quantity and occurred
    -- after the valuation date.  Rollback this quantity and insert the sum of
    -- the quantity by parent Receive or Match transaction.  When summed with
    -- the current quantity row with qty_source = 9 inserted in the previous step,
    -- this will give the valuation as of the date passed in.

    IF (p_valuation_date is not null) THEN
      l_stmt_num := 30;
      INSERT
      INTO   cst_inv_qty_temp(
               qty_source,
               organization_id,
               inventory_item_id,
               category_id,
               cost_type_id,
               rcv_transaction_id,
               revision,
               rollback_qty
             )
      SELECT 10                   qty_source, -- ROLLBACK RECEIVING
             RT.organization_id,
             CILT.inventory_item_id,
             DECODE(POL.item_id, NULL, POL.category_id, CILT.category_id),
             CILT.cost_type_id,
             DECODE(RT.transaction_type,
                    'RECEIVE', RT.transaction_id,
                    'MATCH', RT.transaction_id,
                    Get_ParentReceiveTxn(RT.transaction_id)) rcv_transaction_id,
             DECODE(p_qty_by_revision, 1, POL.item_revision, NULL),
             SUM(DECODE(RT.transaction_type,
                        'RECEIVE', -1 * RT.primary_quantity,
                        'DELIVER', 1 * RT.primary_quantity,
                        'RETURN TO RECEIVING', -1 * RT.primary_quantity,
                        'RETURN TO VENDOR', DECODE(PARENT_RT.transaction_type,
                                                   'UNORDERED', 0,
                                                   1 * RT.primary_quantity),
                        'MATCH', -1 * RT.primary_quantity,
                        'CORRECT', DECODE(PARENT_RT.transaction_type,
                                          'UNORDERED', 0,
                                          'RECEIVE', -1 * RT.primary_quantity,
                                          'DELIVER', 1 * RT.primary_quantity,
                                          'RETURN TO RECEIVING', -1 * RT.primary_quantity,
                                          'RETURN TO VENDOR', DECODE(GRPARENT_RT.transaction_type,
                                                                     'UNORDERED', 0,
                                                                     1 * RT.primary_quantity),
                                          'MATCH', -1 * RT.primary_quantity,
                                          0),
                        0)
             ) rollback_qty
     FROM    cst_item_list_temp CILT,
             cst_cg_list_temp CCLT,
             rcv_transactions RT,
             rcv_transactions PARENT_RT,
             rcv_transactions GRPARENT_RT,
             mtl_parameters MP,
             po_lines_all POL,
             po_line_locations_all POLL,
             pjm_project_parameters PPP
     WHERE   NVL(CILT.inventory_item_id, -1) = NVL(POL.item_id, -1)
     AND     MP.organization_id = RT.organization_id
     AND     RT.organization_id = p_organization_id
     AND     NVL(PPP.costing_group_id,MP.default_cost_group_id) = CCLT.cost_group_id
     AND     NVL(RT.consigned_flag, 'N') = 'N' -- eliminate consigned
     AND     NVL(RT.dropship_type_code, 3) = 3 -- eliminate drop ship
     AND     RT.transaction_date > p_valuation_date
     AND     RT.transaction_type in
               ('RECEIVE', 'DELIVER', 'RETURN TO RECEIVING', 'RETURN TO VENDOR', 'CORRECT', 'MATCH')
     AND    RT.source_document_code = 'PO'
     AND    DECODE(RT.parent_transaction_id,
                   -1, NULL,
                   0, NULL,
                   RT.parent_transaction_id) = PARENT_RT.transaction_id(+)
     AND    DECODE(PARENT_RT.parent_transaction_id,
                   -1, NULL,
                   0, NULL,
                   PARENT_RT.parent_transaction_id) = GRPARENT_RT.transaction_id(+)
     AND    POL.po_line_id = RT.po_line_id
     AND    PPP.project_id (+) = POL.project_id
     AND    POLL.line_location_id = RT.po_line_location_id
     AND    POLL.shipment_type <> 'PREPAYMENT'
     AND    POLL.matching_basis = 'QUANTITY' -- eliminate service line types
     AND    POLL.accrue_on_receipt_flag = DECODE(p_include_period_end, 1, POLL.accrue_on_receipt_flag, 'Y')
     GROUP
     BY     RT.organization_id,
            CILT.inventory_item_id,
            DECODE(POL.item_id, NULL, POL.category_id, CILT.category_id),
            CILT.cost_type_id,
            DECODE(RT.transaction_type,
                   'RECEIVE', RT.transaction_id,
                   'MATCH', RT.transaction_id,
                   Get_ParentReceiveTxn(RT.transaction_id)),
            DECODE(p_qty_by_revision, 1, POL.item_revision, NULL)
     HAVING SUM(DECODE(RT.transaction_type,
                       'RECEIVE', -1 * RT.primary_quantity,
                       'DELIVER', 1 * RT.primary_quantity,
                       'RETURN TO RECEIVING', -1 * RT.primary_quantity,
                       'RETURN TO VENDOR', DECODE(PARENT_RT.transaction_type,
                                                  'UNORDERED', 0,
                                                  1 * RT.primary_quantity),
                       'MATCH', -1 * RT.primary_quantity,
                       'CORRECT', DECODE(PARENT_RT.transaction_type,
                                         'UNORDERED', 0,
                                         'RECEIVE', -1 * RT.primary_quantity,
                                         'DELIVER', 1 * RT.primary_quantity,
                                         'RETURN TO RECEIVING', -1 * RT.primary_quantity,
                                         'RETURN TO VENDOR', DECODE(GRPARENT_RT.transaction_type,
                                                                    'UNORDERED', 0,
                                                                    1 * RT.primary_quantity),
                                         'MATCH', -1 * RT.primary_quantity,
                                         0),
                       0)
               ) <> 0;

     IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
     THEN
       FND_MSG_PUB.Add_Exc_Msg(
         p_pkg_name => G_PKG_NAME,
         p_procedure_name => l_api_name,
         p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                        ' rollback receiving quantities'
       );
     END IF;

 END IF; /* end if p_valuation_date is not null */

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Calculate_ReceivingQty_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      ROLLBACK TO Calculate_ReceivingQty_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => SUBSTR(l_stmt_num||SQLERRM,1,240)
        );
      END IF;
  END Calculate_ReceivingQty;

  FUNCTION Get_ParentReceiveTxn (
   p_rcv_transaction_id IN NUMBER
  )
  RETURN NUMBER
  IS
    l_parent_transaction_id NUMBER;
  BEGIN
    SELECT transaction_id
    INTO   l_parent_transaction_id
    FROM (
        SELECT  RT.transaction_id transaction_id,
                RT.parent_transaction_id parent_transaction_id,
                RT.transaction_type
        FROM    rcv_transactions RT
     START WITH transaction_id  = p_rcv_transaction_id
     CONNECT BY transaction_id  = PRIOR parent_transaction_id)
    WHERE ((transaction_type = 'RECEIVE' and parent_transaction_id=-1)
    OR    transaction_type = 'MATCH');
    return l_parent_transaction_id;
  END Get_ParentReceiveTxn;


  PROCEDURE Calculate_InventoryCost(
    p_api_version          IN         NUMBER,
    p_valuation_date       IN         DATE,
    p_organization_id      IN         NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2
  )
  IS
    l_api_name CONSTANT VARCHAR2(30) := 'Calculate_InventoryCost';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_level_threshold NUMBER;
    l_stmt_num NUMBER := 0;

    l_organization_id NUMBER(15);
    l_inventory_item_id NUMBER(15);
    l_cost_type_id NUMBER(15);
    l_min_cost_update_id NUMBER(15);
    l_max_cost_update_id NUMBER(15);
    l_rcv_transaction_id NUMBER(15);
    l_cost_method NUMBER;
    l_receiving_cost NUMBER;

    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);

    l_rcv_cost_source NUMBER; -- added in 12i for as of date changes
    l_exp_item_flag           NUMBER;
    l_rec    cst_inv_cost_temp%ROWTYPE;

    CURSOR c_standard IS
      SELECT DISTINCT
             CIQT.organization_id,
             CIQT.inventory_item_id,
             CIQT.cost_type_id
      FROM   cst_inv_qty_temp CIQT,
             mtl_parameters MP
      WHERE  CIQT.organization_id = p_organization_id
      AND    MP.organization_id = p_organization_id
      AND    MP.primary_cost_method = 1
      AND    CIQT.qty_source NOT IN (1,2,9,10) -- PRIOR SUMMARY, CURRENT SUMMARY,
                                               -- RECEIVING, PAST RECEIVING
      AND    CIQT.cost_type_id IS NOT NULL;  -- bug 6893581
--{BUG#6631966
-- Commented oout the check on the valuation cost type will be done in the loop
--      AND    CIQT.cost_type_id =
--             DECODE(
--               p_valuation_date,
--               NULL,CIQT.cost_type_id,
--               MP.primary_cost_method
--             );
--}
             -- Past cost is calculated only for valuation cost type

    CURSOR c_receiving IS
      SELECT DISTINCT
             CIQT.organization_id,
             CIQT.inventory_item_id,
             CIQT.rcv_transaction_id
      FROM   cst_inv_qty_temp CIQT
      WHERE  CIQT.qty_source in (9,10);

  PROCEDURE use_transactional_cost(p_organization_id       IN     NUMBER,
                                 p_valuation_date        IN     DATE,
                                 p_inventory_item_id     IN     NUMBER)
  IS
   CURSOR cur_get_new_mcacd_cost(
      p_organization_id       IN     NUMBER,
      p_valuation_date        IN     DATE,
      p_inventory_item_id     IN     NUMBER)
   IS
   SELECT mcacd_txn,
          mmt_txn,
          mmt_cost,
          mcacd_cost,
          TXN_DATE,
          prior_COST ,
          act,
          material_cost,
          material_overhead_cost,
          resource_cost,
          outside_processing_cost,
          overhead_cost
     FROM
          (SELECT MCACD.TRANSACTION_ID                                             mcacd_txn,
                  MMT.transaction_id                                               mmt_txn,
                  NVL(MMT.actual_cost,0)                                           mmt_cost,
                  MMT.transaction_action_id                                        act,
                  NVL(MMT.prior_COST,0)                                            prior_cost,
                  SUM(NVL(mcacd.actual_cost,0))
				               OVER (PARTITION BY MMT.transaction_id)              mcacd_cost,
                  SUM(DECODE(mcacd.cost_element_id,1,NVL(mcacd.actual_cost,0),0))
                               OVER (PARTITION BY MMT.transaction_id)              material_cost,
                  SUM(DECODE(mcacd.cost_element_id,2,NVL(mcacd.actual_cost,0),0))
                               OVER (PARTITION BY MMT.transaction_id)              material_overhead_cost,
                  SUM(DECODE(mcacd.cost_element_id,3,NVL(mcacd.actual_cost,0),0))
                               OVER (PARTITION BY MMT.transaction_id)              resource_cost,
                  SUM(DECODE(mcacd.cost_element_id,4,nvl(mcacd.actual_cost,0),0))
                               OVER (PARTITION BY MMT.transaction_id)              outside_processing_cost,
                  SUM(DECODE(mcacd.cost_element_id,5,nvl(mcacd.actual_cost,0),0))
                               OVER (PARTITION BY MMT.transaction_id)              overhead_cost,
                  NVL(MCACD.creation_date,MMT.creation_date)                       txn_date
           FROM   MTL_CST_ACTUAL_COST_DETAILS MCACD,
                  mtl_material_transactions   mmt
           WHERE  MCACD.ORGANIZATION_ID(+)   = p_organization_id
             AND  MCACD.inventory_item_id(+) = p_inventory_item_id
             AND  MMT.transaction_date       > p_valuation_date
             AND  mmt.transaction_action_id  NOT IN  (5,30,40,41,42,43,50,51,52,15,22,11,17,10,13,9,14,7,26,36,25,56,57)
             AND  NOT (mmt.transaction_action_id IN (2,28,55,3) AND mmt.primary_quantity > 0)
                  --
                  -- Standard update only originated by standard cost update avoid PAC cost update
                  --
             AND  NOT (mmt.transaction_action_id = 24 AND mmt.transaction_source_type_id <> 11)
             AND  MMT.inventory_item_id      = p_inventory_item_id
             AND  MMT.organization_id        = p_organization_id
             AND  mmt.transaction_id         = mcacd.transaction_id (+) )
          ORDER BY   TXN_DATE asc,
                     mmt_txn asc;

     l_mcacd_txn               NUMBER;
     l_mmt_txn                 NUMBER;
     l_mmt_cost                NUMBER;
     l_mcacd_cost              NUMBER;
     l_txn_date                DATE;
     l_prior_cost              NUMBER;
     l_act                     NUMBER;
     l_material_cost           NUMBER;
     l_material_overhead_cost  NUMBER;
     l_resource_cost           NUMBER;
     l_outside_processing_cost NUMBER;
     l_overhead_cost           NUMBER;
     l_rec    cst_inv_cost_temp%ROWTYPE;

   BEGIN
     log('use_transactional_cost+ : p_organization_id:'||p_organization_id||
                                  ' p_valuation_date:'||p_valuation_date||
                                  ' p_inventory_item_id'||p_inventory_item_id);
   	   OPEN cur_get_new_mcacd_cost(
                  p_organization_id ,
                  p_valuation_date  ,
                  p_inventory_item_id );

       FETCH cur_get_new_mcacd_cost
        INTO  l_mcacd_txn  ,
              l_mmt_txn    ,
              l_mmt_cost   ,
              l_mcacd_cost ,
              l_txn_date   ,
              l_prior_cost ,
              l_act        ,
              l_material_cost ,
              l_material_overhead_cost ,
              l_resource_cost ,
              l_outside_processing_cost ,
              l_overhead_cost ;

	   IF (cur_get_new_mcacd_cost%NOTFOUND) THEN
	     /*No Txn in future use present cost */
          log('  cur_get_new_mcacd_cost not found');

           INSERT INTO   cst_inv_cost_temp(
                     organization_id,
                     inventory_item_id,
                     cost_type_id,
                     cost_source,
                     inventory_asset_flag,
                     item_cost,
                     material_cost,
                     material_overhead_cost,
                     resource_cost,
                     outside_processing_cost,
                     overhead_cost
                   )
            SELECT p_organization_id,
                   p_inventory_item_id,
                   1,
                   2, -- PAST
                   CIC.inventory_asset_flag,
                   SUM(NVL(CIC.item_cost,0)),
                   SUM(NVL(CIC.material_cost,0)),
                   SUM(NVL(CIC.material_overhead_cost,0)),
                   SUM(NVL(CIC.resource_cost,0)),
                   SUM(NVL(CIC.outside_processing_cost,0)),
                   SUM(NVL(CIC.overhead_cost,0))
            FROM   cst_item_costs CIC,
                   mtl_parameters MP
            WHERE  CIC.cost_type_id      = 1
            AND    MP.organization_id    = p_organization_id
            AND    CIC.organization_id   = MP.cost_organization_id
            AND    CIC.inventory_item_id = p_inventory_item_id
            GROUP BY CIC.inventory_asset_flag;

       ELSE
             -- Got transaction use cost from the transaction
             l_rec.organization_id         := p_organization_id;
             l_rec.inventory_item_id       := p_inventory_item_id;
             l_rec.cost_type_id            := 1;
             l_rec.cost_source             := 2; --PAST
             l_rec.inventory_asset_flag    := 1; --Standard cost update is only done for asset items

             IF( l_mcacd_txn IS NOT null) THEN
                 log('  MCACD TXN FOUND');

                 l_rec.item_cost               := l_mcacd_cost;
                 l_rec.material_cost           := l_material_cost;
                 l_rec.material_overhead_cost  := l_material_overhead_cost;
                 l_rec.resource_cost           := l_resource_cost;
                 l_rec.outside_processing_cost := l_outside_processing_cost;
                 l_rec.overhead_cost           := l_overhead_cost;

             ELSE
               IF(l_act = 24) THEN
                  log('  case 24');

                  l_rec.item_cost               := l_prior_cost;
                  l_rec.material_cost           := l_prior_cost;
                  l_rec.material_overhead_cost  := 0;
                  l_rec.resource_cost           := 0;
                  l_rec.outside_processing_cost := 0;
                  l_rec.overhead_cost           := 0;

               ELSE
                  log('  case <> 24');

                  l_rec.item_cost              := l_mmt_cost;
                  l_rec.material_cost          := l_mmt_cost;
                  l_rec.material_overhead_cost := 0;
                  l_rec.resource_cost          := 0;
                  l_rec.outside_processing_cost:= 0;
                  l_rec.overhead_cost          := 0;
               END IF;
	        END IF;
          ins_cst_inv_cost_temp(p_rec => l_rec);

       END IF;
       CLOSE cur_get_new_mcacd_cost;
     log('use_transactional_cost-');

   END use_transactional_cost;

  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Calculate_InventoryCost_PVT;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call(
             p_current_version_number => l_api_version,
             p_caller_version_number => p_api_version,
             p_api_name => l_api_name,
             p_pkg_name => G_PKG_NAME
           )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check for message level threshold
    l_msg_level_threshold := FND_PROFILE.Value('FND_AS_MSG_LEVEL_THRESHOLD');

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => SUBSTR(
                          l_stmt_num||':'||
                          to_char(p_valuation_date,'DD-MON-YYYY HH24:MI:SS'),
                          1,
                          240
                        )
      );
    END IF;

    IF p_valuation_date IS NULL
    THEN
      -- Calculate the costs for CIQT records that belongs to Standard costing
      -- organizations
      OPEN c_standard;
      l_stmt_num := 10;
      LOOP
        FETCH  c_standard
        INTO   l_organization_id,
               l_inventory_item_id,
               l_cost_type_id;

        EXIT
        WHEN   c_standard%NOTFOUND;

        INSERT
        INTO   cst_inv_cost_temp(
                 organization_id,
                 inventory_item_id,
                 cost_type_id,
                 cost_source,
                 inventory_asset_flag,
                 item_cost,
                 material_cost,
                 material_overhead_cost,
                 resource_cost,
                 outside_processing_cost,
                 overhead_cost
               )
        SELECT l_organization_id,
               l_inventory_item_id,
               l_cost_type_id,
               1, -- CURRENT
               CIC.inventory_asset_flag,
               NVL(CIC.item_cost,0),
               NVL(CIC.material_cost,0),
               NVL(CIC.material_overhead_cost,0),
               NVL(CIC.resource_cost,0),
               NVL(CIC.outside_processing_cost,0),
               NVL(CIC.overhead_cost,0)
        FROM   mtl_parameters MP,
               cst_item_costs CIC
        WHERE  MP.organization_id = l_organization_id
        AND    CIC.organization_id = MP.cost_organization_id
        AND    CIC.inventory_item_id = l_inventory_item_id
        AND    CIC.cost_type_id = l_cost_type_id;
      END LOOP;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Calculated '||c_standard%ROWCOUNT||
                          ' current standard costs'
        );
      END IF;
      CLOSE c_standard;



      -- Calculate the costs for CIQT records that belong to Actual costing
      -- organizations
      -- Note HYU: For layer the as of date has no effect, always null
      --
      l_stmt_num := 20;
      INSERT
      INTO   cst_inv_cost_temp(
               organization_id,
               inventory_item_id,
               cost_group_id,
               cost_type_id,
               cost_source,
               inventory_asset_flag,
               item_cost,
               material_cost,
               material_overhead_cost,
               resource_cost,
               outside_processing_cost,
               overhead_cost
             )
      SELECT CIQT.organization_id,
             CIQT.inventory_item_id,
             CIQT.cost_group_id,
             CIQT.cost_type_id,
             1, -- CURRENT
             CIC.inventory_asset_flag,
             DECODE(
               CIQT.cost_type_id,
               MP.primary_cost_method,
               NVL(CQL.item_cost,0),
               NVL(CIC.item_cost,0)
             ),
             DECODE(
               CIQT.cost_type_id,
               MP.primary_cost_method,
               NVL(CQL.material_cost,0),
               NVL(CIC.material_cost,0)
             ),
             DECODE(
               CIQT.cost_type_id,
               MP.primary_cost_method,
               NVL(CQL.material_overhead_cost,0),
               NVL(CIC.material_overhead_cost,0)
             ),
             DECODE(
               CIQT.cost_type_id,
               MP.primary_cost_method,
               NVL(CQL.resource_cost,0),
               NVL(CIC.resource_cost,0)
             ),
             DECODE(
               CIQT.cost_type_id,
               MP.primary_cost_method,
               NVL(CQL.outside_processing_cost,0),
               NVL(CIC.outside_processing_cost,0)
             ),
             DECODE(
               CIQT.cost_type_id,
               MP.primary_cost_method,
               NVL(CQL.overhead_cost,0),
               NVL(CIC.overhead_cost,0)
             )
      FROM   (
               SELECT DISTINCT
                      organization_id,
                      inventory_item_id,
                      cost_group_id,
                      cost_type_id
               FROM   cst_inv_qty_temp
               WHERE  qty_source NOT IN (1,2,9,10)
             ) CIQT,
             cst_quantity_layers CQL,
             cst_item_costs CIC,
             mtl_parameters MP
      WHERE  CIC.organization_id = CIQT.organization_id
      AND    CIC.inventory_item_id = CIQT.inventory_item_id
      AND    CIC.cost_type_id = CIQT.cost_type_id
      AND    MP.organization_id = CIQT.organization_id
      AND    MP.primary_cost_method <> 1
      AND    CQL.organization_id (+) = CIQT.organization_id
      AND    CQL.inventory_item_id (+) = CIQT.inventory_item_id
      AND    CQL.cost_group_id (+) = CIQT.cost_group_id
             -- Outer join on CQL to insert zero costs for expense
             -- items and asset items that do not have a layer
      AND    CIQT.organization_id = p_organization_id;

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                          ' current actual costs'
        );
      END IF;

      l_stmt_num := 30;
      /* Set rcv_cost_source to 3 for Current Receiving Cost */
      l_rcv_cost_source := 3;

    ELSE /* p_valuation_date is not null: Calculate Past Costs */
      OPEN c_standard;
      l_stmt_num := 40;

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Calculating '||
                          'past standard costs'
        );
     END IF;


     LOOP
        FETCH  c_standard
        INTO   l_organization_id,
               l_inventory_item_id,
               l_cost_type_id;

        EXIT
        WHEN   c_standard%NOTFOUND;

        l_min_cost_update_id := NULL;
        l_max_cost_update_id := NULL;

        --{BUG#6631966
        IF l_cost_type_id <> 1 THEN

           l_stmt_num := 45;

           IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW
           THEN
              FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name => G_PKG_NAME,
                p_procedure_name => l_api_name,
                p_error_text => l_stmt_num||': Item ID '|| l_inventory_item_id ||
				                ' Cost type '|| l_cost_type_id
              );
           END IF;

           -- As the cost type is not the valuation cost type insert the current cost
           INSERT  INTO   cst_inv_cost_temp
	  	          ( organization_id,
                  inventory_item_id,
                  cost_type_id,
                  cost_source,
                  inventory_asset_flag,
                  item_cost,
                  material_cost,
                  material_overhead_cost,
                  resource_cost,
                  outside_processing_cost,
                  overhead_cost
                )
           SELECT l_organization_id,
                  l_inventory_item_id,
                  l_cost_type_id,
                  1, -- CURRENT
                  CIC.inventory_asset_flag,
                  NVL(CIC.item_cost,0),
                  NVL(CIC.material_cost,0),
                  NVL(CIC.material_overhead_cost,0),
                  NVL(CIC.resource_cost,0),
                  NVL(CIC.outside_processing_cost,0),
                  NVL(CIC.overhead_cost,0)
           FROM   mtl_parameters MP,
                  cst_item_costs CIC
           WHERE  MP.organization_id    = l_organization_id
           AND    CIC.organization_id   = MP.cost_organization_id
           AND    CIC.inventory_item_id = l_inventory_item_id
           AND    CIC.cost_type_id      = l_cost_type_id;

       ELSE
           --BUG#6631966: From this point the current behaviour
           -- l_cost_type_id = 1
           l_stmt_num := 46;

           IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW
           THEN
              FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name => G_PKG_NAME,
                p_procedure_name => l_api_name,
                p_error_text => l_stmt_num||': Item ID '|| l_inventory_item_id ||
				                ' Cost type '|| l_cost_type_id
              );
           END IF;


           --{BUG#7484428
           SELECT nvl(CIC.inventory_asset_flag,2)
             INTO l_exp_item_flag
             FROM mtl_parameters MP,
                  cst_item_costs CIC
            WHERE MP.organization_id    = l_organization_id
              AND CIC.organization_id   = MP.cost_organization_id
              AND CIC.inventory_item_id = l_inventory_item_id
              AND CIC.cost_type_id      = 1;

	          IF  (l_exp_item_flag = 2) THEN
               l_rec.organization_id        := l_organization_id;
               l_rec.inventory_item_id      := l_inventory_item_id;
               l_rec.cost_type_id           := 1;
               l_rec.cost_source            := 2; --PAST
               l_rec.inventory_asset_flag   := 2;
               l_rec.item_cost              := 0;
               l_rec.material_cost          := 0;
               l_rec.material_overhead_cost := 0;
               l_rec.resource_cost          := 0;
               l_rec.outside_processing_cost:= 0;
               l_rec.overhead_cost          := 0;
               ins_cst_inv_cost_temp(p_rec => l_rec);

             ELSE

                --get the cost update history ID after the end period call

                SELECT MIN(CSC.cost_update_id)
                  INTO l_min_cost_update_id
                  FROM  cst_standard_costs CSC,
                        mtl_parameters MP
                 WHERE  MP.organization_id = l_organization_id
                   AND  CSC.organization_id = MP.cost_organization_id
                   AND  CSC.inventory_item_id = l_inventory_item_id
                   AND  CSC.standard_cost_revision_date > p_valuation_date;
               -- This logic will only work if the CSC records with
               -- standard_cost_revision_date > p_valuation_date have not
               -- been purged. Although CSC is populated for cost child
               -- organizations, CEC is not. We join through MP to be
               -- consistent.

               -- If the cost update history after the p_valuation_date found for
               -- the l_inventory_item_id in that l_organization_id
               -- need to determine the cost history prior that p_valuation_date
               IF l_min_cost_update_id IS NOT NULL  THEN
                  -- Yes. Figure out the prior cost update
                  SELECT MAX(CSC.cost_update_id)
                    INTO l_max_cost_update_id
                    FROM cst_standard_costs CSC,
                         mtl_parameters MP
                   WHERE MP.organization_id = l_organization_id
                     AND CSC.organization_id = MP.cost_organization_id
                     AND CSC.inventory_item_id = l_inventory_item_id
                     AND CSC.standard_cost_revision_date <= p_valuation_date;

                  -- if cost history prior that p_valuation_date found prior the p_valuation_date
                  -- the l_inventory_item_id in that l_organization_id
                  IF l_max_cost_update_id IS NOT NULL THEN
                    -- Use the cost in cst_elemental_costs of that cost history
                    INSERT
                    INTO   cst_inv_cost_temp(
                        organization_id,
                        inventory_item_id,
                        cost_type_id,
                        cost_source,
                        inventory_asset_flag,
                        item_cost,
                        material_cost,
                        material_overhead_cost,
                        resource_cost,
                        outside_processing_cost,
                        overhead_cost
                      )
                   SELECT l_organization_id,
                         l_inventory_item_id,
                         1,
                         2, -- PAST
                         1, -- Standard cost update is only done for asset items
                         SUM(NVL(CEC.standard_cost,0)),
                         SUM(DECODE(CEC.cost_element_id,1,NVL(CEC.standard_cost,0),0)),
                         SUM(DECODE(CEC.cost_element_id,2,NVL(CEC.standard_cost,0),0)),
                         SUM(DECODE(CEC.cost_element_id,3,NVL(CEC.standard_cost,0),0)),
                         SUM(DECODE(CEC.cost_element_id,4,NVL(CEC.standard_cost,0),0)),
                         SUM(DECODE(CEC.cost_element_id,5,NVL(CEC.standard_cost,0),0))
                   FROM   cst_elemental_costs CEC,
                          mtl_parameters MP
                   WHERE  CEC.cost_update_id = l_max_cost_update_id
                   AND    MP.organization_id = l_organization_id
                   AND    CEC.organization_id = MP.cost_organization_id
                   AND    CEC.inventory_item_id = l_inventory_item_id;

                   IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW
                   THEN
                       FND_MSG_PUB.Add_Exc_Msg(
                         p_pkg_name => G_PKG_NAME,
                         p_procedure_name => l_api_name,
                         p_error_text => l_stmt_num||': Item ID '||
                                l_inventory_item_id || ' Cost Update ID '||
                                l_max_cost_update_id
                       );
                   END IF;

                 ELSE
                  -- Cost update history not found for the item in that organization
                  -- prior the p_valuation_date
                  -- This situation is either the cost history is purged or item cost is zero
                  -- or CTO item corruption created with cost history
                  -- In all cases Costing should help to prevent this situation
                  -- calling use transactional cost
                  use_transactional_cost
                                  (p_organization_id   => l_organization_id,
                                   p_valuation_date    => p_valuation_date,
                                   p_inventory_item_id => l_inventory_item_id);

--            INSERT
--            INTO   cst_inv_cost_temp(
--                     organization_id,
--                     inventory_item_id,
--                     cost_type_id,
--                     cost_source,
--                     inventory_asset_flag,
--                     item_cost,
--                     material_cost,
--                     material_overhead_cost,
--                     resource_cost,
---                    outside_processing_cost,
--                     overhead_cost                  )
--            SELECT l_organization_id,
--                   l_inventory_item_id,
--                   1,
--                   2, -- PAST
--                   1, -- Standard cost update is only done for asset items
--                   0,
--                   0,
--                   0,
--                   0,
--                   0,
--                   0
--            FROM   dual;

                    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW  THEN
                      FND_MSG_PUB.Add_Exc_Msg(
                        p_pkg_name => G_PKG_NAME,
                        p_procedure_name => l_api_name,
                         p_error_text => l_stmt_num||': Item ID '||l_inventory_item_id||
--                                ' zero cost'
                                ' use_transactional_cost'
                       );
                    END IF;
                 END IF; --l_max_cost_update_id

              ELSE
                 -- No. Use current cost
                 INSERT
                 INTO   cst_inv_cost_temp(
                   organization_id,
                   inventory_item_id,
                   cost_type_id,
                   cost_source,
                   inventory_asset_flag,
                   item_cost,
                   material_cost,
                   material_overhead_cost,
                   resource_cost,
                   outside_processing_cost,
                   overhead_cost
                 )
                 SELECT
                 l_organization_id,
                 l_inventory_item_id,
                 1,
                 2, -- PAST
                 CIC.inventory_asset_flag,
                 NVL(CIC.item_cost,0),
                 NVL(CIC.material_cost,0),
                 NVL(CIC.material_overhead_cost,0),
                 NVL(CIC.resource_cost,0),
                 NVL(CIC.outside_processing_cost,0),
                 NVL(CIC.overhead_cost,0)
                 FROM   mtl_parameters MP,
                        cst_item_costs CIC
                 WHERE  MP.organization_id = l_organization_id
                 AND    CIC.organization_id = MP.cost_organization_id
                 AND    CIC.inventory_item_id = l_inventory_item_id
                 AND    CIC.cost_type_id = 1;

                 IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW  THEN
                   FND_MSG_PUB.Add_Exc_Msg(
                       p_pkg_name => G_PKG_NAME,
                       p_procedure_name => l_api_name,
                       p_error_text => l_stmt_num||': Item ID '||l_inventory_item_id||
                              ' cost from CIC'
                    );
                 END IF;

               END IF;      --l_min_cost_update_id

            END IF; --expense/asset items
         END IF; --l_cost_type_id <> 1
            --} BUG#6631966
      END LOOP;

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Calculated '||c_standard%ROWCOUNT||
                          ' past standard costs'
        );
      END IF;
      CLOSE c_standard;

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Calculating '||
                          'past actual costs'
        );
      END IF;

      --Actual Cost processing
      l_stmt_num := 50;
      INSERT
      INTO   cst_inv_cost_temp(
               organization_id,
               inventory_item_id,
               cost_group_id,
               cost_type_id,
               cost_source,
               inventory_asset_flag,
               item_cost,
               material_cost,
               material_overhead_cost,
               resource_cost,
               outside_processing_cost,
               overhead_cost
             )
      SELECT DISTINCT
             CIQT.organization_id,
             CIQT.inventory_item_id,
             CIQT.cost_group_id,
             CIQT.cost_type_id,
             2, -- PAST
             2, -- EXPENSE
             0,
             0,
             0,
             0,
             0,
             0
      FROM   cst_inv_qty_temp CIQT,
             mtl_parameters MP,
             cst_item_costs CIC
      WHERE  MP.organization_id = CIQT.organization_id
      AND    MP.primary_cost_method <> 1
      AND    CIC.organization_id = CIQT.organization_id
      AND    CIC.inventory_item_id = CIQT.inventory_item_id
      AND    CIC.cost_type_id = CIQT.cost_type_id
      AND    CIC.inventory_asset_flag <> 1
      AND    CIQT.qty_source NOT IN (1,2,9,10) -- PRIOR SUMMARY, CURRENT SUMMARY, RECEIVING, PAST RECEIVING
      AND    CIQT.organization_id = p_organization_id;

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                          ' expense items'
        );
      END IF;

      l_stmt_num := 55;
      SELECT primary_cost_method
      INTO   l_cost_method
      FROM   mtl_parameters
      WHERE  organization_id = p_organization_id;

      l_stmt_num := 60;
      INSERT
      INTO   cst_inv_cost_temp(
               organization_id,
               inventory_item_id,
               cost_group_id,
               cost_type_id,
               cost_source,
               inventory_asset_flag,
               item_cost,
               material_cost,
               material_overhead_cost,
               resource_cost,
               outside_processing_cost,
               overhead_cost
             )
      SELECT /*+ ORDERED use_nl(CQL,MCACD) use_hash(TFR_TXN,OWN_TXN) */
             CIQT.organization_id,
             CIQT.inventory_item_id,
             CIQT.cost_group_id,
             CIQT.primary_cost_method,
             2, -- PAST
             1, -- ASSET
             SUM(NVL(MCACD.prior_cost,0)),
             SUM(
               DECODE(MCACD.cost_element_id,1,NVL(MCACD.prior_cost,0),0)
             ),
             SUM(
               DECODE(MCACD.cost_element_id,2,NVL(MCACD.prior_cost,0),0)
             ),
             SUM(
               DECODE(MCACD.cost_element_id,3,NVL(MCACD.prior_cost,0),0)
             ),
             SUM(
               DECODE(MCACD.cost_element_id,4,NVL(MCACD.prior_cost,0),0)
             ),
             SUM(
               DECODE(MCACD.cost_element_id,5,NVL(MCACD.prior_cost,0),0)
             )
      FROM   (
               SELECT /*+ no_merge */ DISTINCT
                      CIQT.organization_id,
                      CIQT.inventory_item_id,
                      CIQT.cost_group_id,
                      MP.primary_cost_method
               FROM   cst_inv_qty_temp CIQT,
                      mtl_parameters MP
               WHERE  MP.organization_id = CIQT.organization_id
               AND    MP.primary_cost_method <> 1
               AND    CIQT.qty_source NOT IN (1,2,9,10)
                      -- PRIOR SUMMARY, CURRENT SUMMARY, RECEIVING, PAST RECEIVING
               AND    NOT EXISTS (
                        SELECT 1
                        FROM   cst_inv_cost_temp CICT
                        WHERE  CICT.organization_id = CIQT.organization_id
                        AND    CICT.inventory_item_id = CIQT.inventory_item_id
                        AND    CICT.cost_source = 2
                      )
               AND    CIQT.organization_id = p_organization_id
             ) CIQT,
             cst_quantity_layers CQL,
             (
               SELECT /*+ ORDERED use_hash(MMT,MIP) swap_join_inputs(MIP) */
                      MIN(MMT.transaction_id) transaction_id,
                      MMT.transaction_date,
                      MMT.transfer_organization_id,
                      MMT.inventory_item_id,
                      MMT.transfer_cost_group_id,
                      'N' restrict_mcacd
               FROM
                      (
                        SELECT /*+ no_merge leading(MIP) use_hash(MMT)*/
                               MIN(MMT.transaction_date) transaction_date,
                               MMT.transfer_organization_id,
                               MMT.inventory_item_id,
                               MMT.transfer_cost_group_id
                        FROM   mtl_material_transactions MMT,
                               mtl_interorg_parameters MIP
                        WHERE  MMT.transaction_action_id = 21
                        AND    MIP.from_organization_id = MMT.organization_id
                        AND    MIP.to_organization_id = MMT.transfer_organization_id
                        AND    NVL(MMT.fob_point,MIP.fob_point)=1
                        AND    MMT.costed_flag IS NULL
                        AND    MMT.transaction_date > p_valuation_date
                        AND    MMT.transfer_organization_id = p_organization_id
                        GROUP
                        BY     MMT.transfer_organization_id,
                               MMT.inventory_item_id,
                               MMT.transfer_cost_group_id
                      ) MINDATE,
                      mtl_material_transactions MMT,
                      mtl_interorg_parameters MIP
               WHERE  MMT.transfer_organization_id = MINDATE.transfer_organization_id
               AND    MMT.inventory_item_id = MINDATE.inventory_item_id
               AND    MMT.transfer_cost_group_id = MINDATE.transfer_cost_group_id
               AND    MMT.transaction_date = MINDATE.transaction_date
               AND    MMT.transaction_action_id = 21
               AND    MIP.from_organization_id = MMT.organization_id
               AND    MIP.to_organization_id = MMT.transfer_organization_id
               AND    NVL(MMT.fob_point,MIP.fob_point)=1
               AND    MMT.costed_flag IS NULL
               AND    MMT.transaction_date > p_valuation_date
               AND    MMT.transfer_organization_id = p_organization_id
               GROUP
               BY     MMT.transaction_date,
                      MMT.transfer_organization_id,
                      MMT.inventory_item_id,
                      MMT.transfer_cost_group_id
             ) TFR_TXN,
             (
               SELECT /*+ leading(MINDATE) use_nl(MMT) index(MMT,MTL_MATERIAL_TRANSACTIONS_N1) */
                      MIN(MMT.transaction_id) transaction_id,
                      MMT.transaction_date,
                      MMT.organization_id,
                      MMT.inventory_item_id,
                      /* In average costing organizations, common issue to WIP
                         results in reaveraging of the item cost in the transfer
                         cost group */
                      DECODE(
                        l_cost_method,
                        2,
                        DECODE(
                          MMT.transaction_action_id,
                          1,
                          DECODE(
                            MMT.transaction_source_type_id,
                            5,
                            NVL(MMT.TRANSFER_COST_GROUP_ID, MMT.cost_group_id),
                            MMT.cost_group_id
                          ),
                          MMT.cost_group_id
                        ),
                        MMT.cost_group_id
                      ) cost_group_id,
                      /* For common issue to WIP transactions in average costing
                         organizations, we insert rows both for the cost group
                         transfer and issue to WIP. We are only interested in the
                         rows corresponding to the cost group transfer. The
                         restrict_mcacd flag is used to determine if we need to
                         check on MCACD.transaction_action_id */
                      DECODE(
                        l_cost_method,
                        2,
                        DECODE(
                          MMT.transaction_action_id,
                          1,
                          DECODE(
                            MMT.transaction_source_type_id,
                            5,
                            DECODE(
                              MMT.transfer_cost_group_id,
                              NULL,
                              'N',
                              /* Bug 3500534
                              It is possible to have normal issue to WIP transactions in
                              average costing organizations with transfer_cost_group_id
                              = cost_group_id.  Adding the following condition for
                              cost_group_id ensures such cases are handled as normal issue
                              to WIP rather than common. */
                              MMT.cost_group_id,
                              'N',
                              'Y'
                            ),
                            'N'
                          ),
                          'N'
                        ),
                        'N'
                      ) restrict_mcacd
               FROM   mtl_material_transactions MMT,
                      (
                        SELECT /*+ no_merge */ MIN(MMT.transaction_date) transaction_date,
                               MMT.organization_id,
                               MMT.inventory_item_id,
                               DECODE(
                                 l_cost_method,
                                 2,
                                 DECODE(
                                   MMT.transaction_action_id,
                                   1,
                                   DECODE(
                                     MMT.transaction_source_type_id,
                                     5,
                                     NVL(MMT.TRANSFER_COST_GROUP_ID, MMT.cost_group_id),
                                     MMT.cost_group_id
                                   ),
                                   MMT.cost_group_id
                                 ),
                                 MMT.cost_group_id
                               ) cost_group_id
                        FROM   mtl_material_transactions MMT
                        WHERE  MMT.transaction_action_id <> 30
                        AND    MMT.prior_cost IS NOT NULL
                        AND    MMT.costed_flag IS NULL
                               -- Ignore consigned transactions
                        AND    MMT.organization_id =
                               NVL(MMT.owning_organization_id, MMT.organization_id)
                        AND    NVL(MMT.owning_tp_type,2) = 2
                        AND    NVL(MMT.logical_transaction,-1) <> 1
                        AND    MMT.transaction_date > p_valuation_date
                        AND    MMT.organization_id = p_organization_id
                        GROUP
                        BY     MMT.organization_id,
                               MMT.inventory_item_id,
                               DECODE(
                                 l_cost_method,
                                 2,
                                 DECODE(
                                   MMT.transaction_action_id,
                                   1,
                                   DECODE(
                                     MMT.transaction_source_type_id,
                                     5,
                                     NVL(MMT.TRANSFER_COST_GROUP_ID, MMT.cost_group_id),
                                     MMT.cost_group_id
                                   ),
                                   MMT.cost_group_id
                                 ),
                                 MMT.cost_group_id
                               )
                      ) MINDATE
               WHERE  MMT.organization_id = MINDATE.organization_id
               AND    MMT.inventory_item_id = MINDATE.inventory_item_id
               AND    DECODE(
                        l_cost_method,
                        2,
                        DECODE(
                          MMT.transaction_action_id,
                          1,
                          DECODE(
                            MMT.transaction_source_type_id,
                            5,
                            NVL(MMT.transfer_cost_group_id, MMT.cost_group_id),
                            MMT.cost_group_id
                          ),
                          MMT.cost_group_id
                        ),
                        MMT.cost_group_id
                      ) = MINDATE.cost_group_id
               AND    MMT.transaction_date = MINDATE.transaction_date
               AND    MMT.transaction_action_id <> 30
               AND    MMT.prior_cost IS NOT NULL
               AND    MMT.costed_flag IS NULL
                      -- Ignore consigned transactions
               AND    MMT.organization_id =
                      NVL(MMT.owning_organization_id, MMT.organization_id)
               AND    NVL(MMT.owning_tp_type,2) = 2
               AND    NVL(MMT.logical_transaction,-1) <> 1
               AND    MMT.organization_id = p_organization_id
               GROUP
               BY     MMT.transaction_date,
                      MMT.organization_id,
                      MMT.inventory_item_id,
                      DECODE(
                        l_cost_method,
                        2,
                        DECODE(
                          MMT.transaction_action_id,
                          1,
                          DECODE(
                            MMT.transaction_source_type_id,
                            5,
                            NVL(MMT.transfer_cost_group_id, MMT.cost_group_id),
                            MMT.cost_group_id
                          ),
                          MMT.cost_group_id
                        ),
                        MMT.cost_group_id
                      ),
                      DECODE(
                        l_cost_method,
                        2,
                        DECODE(
                          MMT.transaction_action_id,
                          1,
                          DECODE(
                            MMT.transaction_source_type_id,
                            5,
                            DECODE(
                              MMT.transfer_cost_group_id,
                              NULL,
                              'N',
                              /* Bug 3500534
                              It is possible to have normal issue to WIP transactions in
                              average costing organizations with transfer_cost_group_id
                              = cost_group_id.  Adding the following condition for
                              cost_group_id ensures such cases are handled as normal issue
                              to WIP rather than common. */
                              MMT.cost_group_id,
                              'N',
                              'Y'
                            ),
                            'N'
                          ),
                          'N'
                        ),
                        'N'
                      )
             ) OWN_TXN,
             mtl_cst_actual_cost_details MCACD
      WHERE  MCACD.transaction_id = DECODE(
                                      NVL(TFR_TXN.transaction_id,-1),
                                      -1,
                                      OWN_TXN.transaction_id,
                                      DECODE(
                                        NVL(OWN_TXN.transaction_id,-1),
                                        -1,
                                        TFR_TXN.transaction_id,
                                        DECODE(
                                          TFR_TXN.transaction_date,
                                          OWN_TXN.transaction_date,
                                          LEAST(
                                            TFR_TXN.transaction_id,
                                            OWN_TXN.transaction_id
                                          ),
                                          DECODE(
                                            LEAST(
                                              TFR_TXN.transaction_date,
                                              OWN_TXN.transaction_date
                                            ),
                                            TFR_TXN.transaction_date,
                                            TFR_TXN.transaction_id,
                                            OWN_TXN.transaction_id
                                          )
                                        )
                                      )
                                    )
      AND    MCACD.layer_id = CQL.layer_id
      AND    MCACD.organization_id = p_organization_id
      AND    MCACD.transaction_action_id =
             DECODE(
               MCACD.transaction_id,
               OWN_TXN.transaction_id,
               DECODE(OWN_TXN.restrict_mcacd, 'Y', 2, MCACD.transaction_action_id),
               MCACD.transaction_action_id
             )
      AND    CQL.organization_id = CIQT.organization_id
      AND    CQL.cost_group_id = CIQT.cost_group_id
      AND    CQL.inventory_item_id = CIQT.inventory_item_id
      AND    TFR_TXN.transfer_organization_id (+) = CIQT.organization_id
      AND    TFR_TXN.transfer_cost_group_id (+) = CIQT.cost_group_id
      AND    TFR_TXN.inventory_item_id (+) = CIQT.inventory_item_id
      AND    OWN_TXN.organization_id (+) = CIQT.organization_id
      AND    OWN_TXN.cost_group_id (+) = CIQT.cost_group_id
      AND    OWN_TXN.inventory_item_id (+) = CIQT.inventory_item_id
      GROUP
      BY     CIQT.organization_id,
             CIQT.inventory_item_id,
             CIQT.cost_group_id,
             CIQT.primary_cost_method;

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                          ' past actual costs from MCACD'
        );
      END IF;

      l_stmt_num := 70;
      INSERT
      INTO   cst_inv_cost_temp(
               organization_id,
               inventory_item_id,
               cost_group_id,
               cost_type_id,
               cost_source,
               inventory_asset_flag,
               item_cost,
               material_cost,
               material_overhead_cost,
               resource_cost,
               outside_processing_cost,
               overhead_cost
             )
      SELECT CIQT.organization_id,
             CIQT.inventory_item_id,
             CIQT.cost_group_id,
             CIQT.primary_cost_method,
             2, -- PAST
             1, -- ASSET
             NVL(CQL.item_cost,0),
             NVL(CQL.material_cost,0),
             NVL(CQL.material_overhead_cost,0),
             NVL(CQL.resource_cost,0),
             NVL(CQL.outside_processing_cost,0),
             NVL(CQL.overhead_cost,0)
      FROM   cst_quantity_layers CQL,
             (
               SELECT DISTINCT
                      CIQT.organization_id,
                      CIQT.inventory_item_id,
                      CIQT.cost_group_id,
                      MP.primary_cost_method
               FROM   cst_inv_qty_temp CIQT,
                      mtl_parameters MP
               WHERE  MP.organization_id = CIQT.organization_id
               AND    MP.primary_cost_method <> 1
               AND    CIQT.qty_source NOT IN (1,2,9,10)
                      -- PRIOR SUMMARY, CURRENT SUMMARY, RECEIVING, PAST RECEIVING
               AND    CIQT.organization_id = p_organization_id
             ) CIQT
      WHERE  CQL.organization_id (+) = CIQT.organization_id
      AND    CQL.inventory_item_id (+) = CIQT.inventory_item_id
      AND    CQL.cost_group_id (+) = CIQT.cost_group_id
      /* The outer join above is for asset items that do not have a layer */
      AND    NOT EXISTS (
               SELECT 1
               FROM   cst_inv_cost_temp CICT
               WHERE  CICT.organization_id = CIQT.organization_id
               AND    CICT.inventory_item_id = CIQT.inventory_item_id
               AND    CICT.cost_group_id = CIQT.cost_group_id
               AND    CICT.cost_source = 2
             );

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Calculated '||SQL%ROWCOUNT||
                          ' actual costs from CQL'
        );
      END IF;

      l_stmt_num := 80;
      /* Set rcv_cost_source to 4 for Past Receiving Cost */
      l_rcv_cost_source := 4;

    END IF; /* End if p_valuation_date is null/else */


    /* In all cases, regardless of whether p_valuation_date is null or not,
    Calculate Receiving Cost. */
 l_stmt_num := 90;

 IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW
 THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Calculating '||
                          'receiving cost'
        );
    END IF;

 OPEN   c_receiving;
 LOOP
        FETCH  c_receiving
        INTO   l_organization_id,
               l_inventory_item_id,
               l_rcv_transaction_id;
        EXIT
        WHEN   c_receiving%NOTFOUND;

        RCV_AccrualUtilities_GRP.Get_ReceivingUnitPrice(
          p_api_version => 1.0,
          p_rcv_transaction_id => l_rcv_transaction_id,
          p_valuation_date => p_valuation_date, /* added for 12i: as of date */
          x_unit_price => l_receiving_cost,
          x_return_status => x_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        INSERT
        INTO   cst_inv_cost_temp(
                 cost_source,
                 organization_id,
                 inventory_item_id,
                 rcv_transaction_id,
                 item_cost
               )
        SELECT l_rcv_cost_source,
               l_organization_id,
               l_inventory_item_id,
               l_rcv_transaction_id,
               l_receiving_cost
        FROM   dual;
 END LOOP;

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
    THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Calculated '||c_receiving%ROWCOUNT||
                          ' receiving costs'
        );
    END IF;
    CLOSE  c_receiving;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Calculate_InventoryCost_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      ROLLBACK TO Calculate_InventoryCost_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => SUBSTR(l_stmt_num||SQLERRM,1,240)
        );
      END IF;
  END Calculate_InventoryCost;

END CST_Inventory_PVT;

/

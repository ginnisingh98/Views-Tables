--------------------------------------------------------
--  DDL for Package Body GMF_LC_ADJ_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_LC_ADJ_TRANSACTIONS_PKG" AS
/*  $Header: GMFLCATB.pls 120.0.12010000.4 2009/10/15 18:09:45 pmarada noship $ */

   /* define the structure, can be used in global */
    TYPE transaction_type  IS RECORD (
            parent_ship_line_id       NUMBER,
            adjustment_num            NUMBER,
            ship_header_id            NUMBER,
            org_id                    NUMBER,
            ship_line_group_id        NUMBER,
            ship_line_id              NUMBER,
            organization_id           NUMBER,
            inventory_item_id         NUMBER,
            prior_landed_cost         NUMBER,
            new_landed_cost           NUMBER,
            allocation_percent        NUMBER,
            charge_line_type_id       NUMBER,
            charge_line_type_code     VARCHAR2(30),
            cost_acquisition_flag     VARCHAR2(1),
            component_type            VARCHAR2(30),
            component_name            VARCHAR2(30),
            parent_table_name         VARCHAR2(30),
            parent_table_id           NUMBER,
            cost_cmpntcls_id          NUMBER,
            cost_analysis_code        VARCHAR2(4),
            transaction_date          DATE,
            transaction_quantity      NUMBER,
            transaction_uom_code      VARCHAR2(25),
            primary_quantity          NUMBER,
            primary_uom_code          VARCHAR2(25),
            lc_adjustment_flag        NUMBER,
            rcv_transaction_id        NUMBER,
            rcv_transaction_type      VARCHAR2(25),
            currency_code             VARCHAR2(15),
            lc_ship_num               VARCHAR2(25),
            lc_ship_line_num          NUMBER,
            event_type                NUMBER,
            event_source              VARCHAR2(25),
            event_source_id           NUMBER,
            lc_var_account_id         NUMBER,
            lc_absorption_account_id  NUMBER);

    TYPE lc_adjustments_type IS REF CURSOR RETURN transaction_type;

    adjustments_row transaction_type;

    l_debug_level        PLS_INTEGER;
    l_debug_level_none   PLS_INTEGER;
    l_debug_level_low    PLS_INTEGER;
    l_debug_level_medium PLS_INTEGER;
    l_debug_level_high   PLS_INTEGER;

/************************************************************************
NAME
        Validate_Adjustments

SYNOPSIS
        Type       : Private
        Function   : Validate LCM adjustments before inserting in
                     gmf_lc_adj_transactions table

         Pre-reqs   : None
         Parameters :
                 IN : p_le_id     IN NUMBER

                OUT : p_adjustment_row    IN OUT transaction_type
                      p_validation_status IN OUT VARCHAR2
                      p_return_status        OUT VARCHAR2


DESCRIPTION
               Validate LC adjustments before insert into OPM tables
AUTHOR
  LCM-OPM dev  04-Aug-2009, LCM-OPM Integration, bug 8889977
  Prasadmarada 15-oct-2009 added code for prorate return to vendor, correction
               transactions, bug 8933738, 8925152

HISTORY
*************************************************************************/

PROCEDURE Validate_Adjustments(p_le_id             IN NUMBER,
                               p_adjustment_row    IN OUT NOCOPY transaction_type,
                               p_validation_status IN OUT NOCOPY VARCHAR2,
                               x_return_status        OUT NOCOPY VARCHAR2) IS

       -- Get the lcm flag and item id
    CURSOR check_lcm_flag IS
    SELECT NVL(pll.lcm_flag,'N'), NVL(pl.item_id,0)
      FROM
            po_line_locations_all pll,
            po_lines_all pl,
            rcv_transactions rt
     WHERE
            pll.line_location_id = rt.po_line_location_id
       AND  pl.po_line_id        = rt.po_line_id
       AND  pl.po_line_id        = pll.po_line_id
       AND  rt.transaction_id    = p_adjustment_row.rcv_transaction_id;

        -- check cost component class id exists in component master table
    CURSOR cur_costcptcls_exists(cp_cost_cmpntcls_id  NUMBER) IS
    SELECT 1
      FROM cm_cmpt_mst
     WHERE cost_cmpntcls_id = cp_cost_cmpntcls_id;

      -- check analysis code exists in analysis table
    CURSOR cur_analysis_cd_exists (cp_cost_analysis_code cm_alys_mst.cost_analysis_code%TYPE) IS
    SELECT 1
      FROM CM_ALYS_MST
     WHERE cost_analysis_code = cp_cost_analysis_code;

    -- get the material cost component class id and analysis code from
    -- material cost component table and fiscal policies table
    CURSOR cur_get_costcptcls ( cp_le_id             NUMBER,
                                cp_inventory_item_id NUMBER,
                                cp_organization_id   NUMBER,
                                cp_date              DATE )  IS
    SELECT  ccm.mtl_cmpntcls_id,
            ccm.mtl_analysis_code,
            1
      FROM  cm_cmpt_mtl ccm
     WHERE  ccm.legal_entity_id   = NVL(cp_le_id,ccm.legal_entity_id)
       AND  ccm.inventory_item_id = NVL(cp_inventory_item_id,ccm.inventory_item_id)
       AND  ccm.organization_id   = NVL(cp_organization_id,ccm.organization_id)
       AND  cp_date BETWEEN ccm.eff_start_date AND ccm.eff_end_date
       AND  ccm.delete_mark      = 0
   UNION
    SELECT  cm.mtl_cmpntcls_id,
            cm.mtl_analysis_code,
            2
      FROM  cm_cmpt_mtl cm
     WHERE  cm.legal_entity_id = NVL(cp_le_id, cm.legal_entity_id)
       AND  cm.organization_id = NVL(cp_organization_id, cm.organization_id)
       AND  cp_date BETWEEN cm.eff_start_date AND cm.eff_end_date
       AND  cm.delete_mark     = 0
       AND  cm.cost_category_id IN
                    ( SELECT  category_id
                        FROM  mtl_item_categories mic
                       WHERE  mic.inventory_item_id = NVL(cp_inventory_item_id, mic.inventory_item_id)
                         AND  mic.organization_id   = NVL(cp_organization_id, mic.organization_id)
                     )
   UNION
    SELECT  gfp.mtl_cmpntcls_id,
            gfp.mtl_analysis_code,
            3
      FROM  gmf_fiscal_policies gfp
     WHERE  gfp.legal_entity_id = cp_le_id
       AND  gfp.delete_mark = 0
      ORDER BY 3;

     -- Get sub inventory type
    CURSOR  cur_asset_inventory(cp_rcv_transaction_id NUMBER ) IS
    SELECT  asset_inventory
      FROM  mtl_secondary_inventories subinv,
            mtl_material_transactions mmt,
            rcv_transactions rt
     WHERE  subinv.secondary_inventory_name = mmt.subinventory_code
       AND  subinv.organization_id          = mmt.organization_id
       AND  rt.transaction_id               = mmt.rcv_transaction_id
       AND  rt.transaction_id               = cp_rcv_transaction_id;

    -- Get functional currency code
    CURSOR  cur_func_curr_code (cp_org_id NUMBER ) IS
    SELECT gl.currency_code
    FROM gl_sets_of_books gl,
        financials_system_parameters fsp
    WHERE gl.set_of_books_id = fsp.set_of_books_id
    AND   org_id = cp_org_id;

/*    -- Get PRIOR landed cost
    CURSOR c_prior_landed_cost (
        p_parent_ship_line_id   NUMBER,
        p_ship_header_id        NUMBER,
        p_ship_line_group_id    NUMBER,
        p_component_type        VARCHAR2,
        p_component_name        VARCHAR2,
        p_inventory_item_id     NUMBER,
        p_rcv_transaction_id    NUMBER,
        p_previous_adj_num      NUMBER)
    IS
    SELECT NVL(SUM(landed_cost),0) landed_cost
    FROM gmf_lc_adj_headers_v glah
    WHERE glah.parent_ship_line_id  = p_parent_ship_line_id
    AND   glah.ship_header_id       = p_ship_header_id
    AND   glah.ship_line_group_id   = p_ship_line_group_id
    AND   glah.component_type       = p_component_type
    AND   glah.component_name       = p_component_name
    AND   glah.inventory_item_id    = p_inventory_item_id
    AND   glah.rcv_transaction_id   = p_rcv_transaction_id
    AND   glah.adjustment_num       = p_previous_adj_num;
*/

   CURSOR get_rcv_trans(cp_transaction_id NUMBER)  IS
   SELECT parent_transaction_id, primary_quantity, destination_type_code
     FROM rcv_transactions
    WHERE transaction_id = cp_transaction_id;

   l_parent_rt_id       NUMBER;
   l_rcv_primary_qty    NUMBER;
   l_new_landed_cost    NUMBER;
   l_prorated_prior_lc  NUMBER;

   l_proc_name          CONSTANT VARCHAR2(100) := 'Validate_Adjustments';
   l_lcm_flag           VARCHAR2(1);
   l_inventory_item_id  NUMBER;
   l_cost_cmpntcls_id   NUMBER;
   l_analysis_code      VARCHAR2(4);
   l_asset_inventory    NUMBER;
   l_dummy              NUMBER;
   l_dummy1             VARCHAR2(100);
   l_destination_type_code  VARCHAR2(100);
   l_exists             NUMBER;
   l_previous_adj_num NUMBER := 0;

BEGIN

    IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line(fnd_file.log,'Entered Procedure: '||l_proc_name);
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    p_validation_status:='S';

    IF l_debug_level >= l_debug_level_high THEN
       fnd_file.put_line(fnd_file.log,'Validating Rcv Ttransaction ID: ' ||p_adjustment_row.rcv_transaction_id ||
                                               ' Adjustment Num: '||p_adjustment_row.adjustment_num ||
                                               ' Shipment Header ID: ' ||p_adjustment_row.ship_header_id ||
                                               ' Shipment Line ID: ' ||p_adjustment_row.ship_line_id);
     END IF;

    -- Get functional currency code
    OPEN cur_func_curr_code(p_adjustment_row.org_id);
    FETCH cur_func_curr_code INTO p_adjustment_row.currency_code;
    CLOSE cur_func_curr_code;

   /*  -- Get previous landed cost for actual adjustment lines
    IF (p_adjustment_row.lc_adjustment_flag = 1 OR
        p_adjustment_row.adjustment_num >0) THEN

        -- Get the previous adj_number for the current line
        SELECT MAX(adjustment_num)
        INTO  l_previous_adj_num
        FROM  inl_allocations ia
        WHERE ia.ship_header_id = p_adjustment_row.ship_header_id
          AND ia.ship_line_id   = p_adjustment_row.ship_line_id
          AND ia.adjustment_num < p_adjustment_row.adjustment_num;

        IF l_debug_level >= l_debug_level_low THEN
            fnd_file.put_line(fnd_file.log,'Previous adj_num for the current line: ' || l_previous_adj_num);
        END IF;

        -- Get the prior landed cost for the current line
        OPEN c_prior_landed_cost(
            p_adjustment_row.parent_ship_line_id,
            p_adjustment_row.ship_header_id,
            p_adjustment_row.ship_line_group_id,
            p_adjustment_row.component_type,
            p_adjustment_row.component_name,
            p_adjustment_row.inventory_item_id,
            p_adjustment_row.rcv_transaction_id,
            l_previous_adj_num
        );

        FETCH  c_prior_landed_cost INTO p_adjustment_row.prior_landed_cost;

        CLOSE c_prior_landed_cost;

        IF l_debug_level >= l_debug_level_low THEN
            fnd_file.put_line(fnd_file.log,'Prior landed cost for current line: ' || p_adjustment_row.prior_landed_cost);
        END IF;
    END IF;  */

    IF p_adjustment_row.component_type = 'CHARGE' THEN
          -- populate cost component class id and analysis code
        IF p_adjustment_row.cost_cmpntcls_id IS NULL THEN
            fnd_file.put_line(fnd_file.log,'Cost component class ID null for Charge type component');
            p_validation_status:='F';
            /* exit from the loop --change pmarada */
        ELSIF p_adjustment_row.cost_analysis_code IS NULL THEN
            fnd_file.put_line(fnd_file.log,'Cost Analysis code is null for Charge type component');
            p_validation_status:='F'; /* exit from the loop --change pmarada */
        END IF;

       /* IF (p_adjustment_row.lc_adjustment_flag = 0 OR
            p_adjustment_row.adjustment_num = 0) THEN

            p_adjustment_row.prior_landed_cost := 0;

            IF l_debug_level >= l_debug_level_low THEN
                fnd_file.put_line(fnd_file.log,'Prior Landed Cost for Estimated Charge: ' || p_adjustment_row.prior_landed_cost);
            END IF;
        END IF;  */
    ELSIF p_adjustment_row.component_type = 'ITEM PRICE' THEN
        IF (p_adjustment_row.cost_cmpntcls_id IS NULL OR
            p_adjustment_row.cost_analysis_code IS NULL) THEN

            IF l_debug_level >= l_debug_level_medium THEN
                fnd_file.put_line(fnd_file.log,'Open cursor to get Componet Class Id and Analysis Code from item materials');
            END IF;
           -- get cost componet class id and analysis code
           OPEN cur_get_costcptcls(p_le_id,
                                   p_adjustment_row.inventory_item_id,
                                   p_adjustment_row.organization_id,
                                   p_adjustment_row.transaction_date);
           FETCH cur_get_costcptcls INTO l_cost_cmpntcls_id, l_analysis_code, l_dummy;
           CLOSE cur_get_costcptcls;

            IF l_debug_level >= l_debug_level_medium THEN
                fnd_file.put_line(fnd_file.log,'Open cursor to get Cost Componet Class Id and Analysis Code from default fiscal policies');
            END IF;

            IF p_adjustment_row.cost_cmpntcls_id IS NULL THEN
                p_adjustment_row.cost_cmpntcls_id := l_cost_cmpntcls_id;
            END IF;

            IF p_adjustment_row.cost_analysis_code IS NULL THEN
               p_adjustment_row.cost_analysis_code := l_analysis_code;
            END IF;

            IF l_debug_level >= l_debug_level_low THEN
               fnd_file.put_line(fnd_file.log,'Populate Cost component class ID for item Charge '||p_adjustment_row.cost_cmpntcls_id);
              fnd_file.put_line(fnd_file.log,'Populate Cost analysis code for item Charge '||p_adjustment_row.cost_analysis_code);
             END IF;

        END IF; /* end for cost component class */

        -- For ITEM PRICE, cost acquisition flag = I
        IF p_adjustment_row.cost_acquisition_flag IS NULL THEN
            p_adjustment_row.cost_acquisition_flag := 'I';
        END IF;

        -- For ITEM PRICE, Get the Prior Landed Cost from PO
        IF (p_adjustment_row.lc_adjustment_flag = 0 OR
            p_adjustment_row.adjustment_num = 0) THEN
            SELECT ABS(DECODE(p_adjustment_row.currency_code,rt.currency_code,
                   NVL(rt.po_unit_price,0) * NVL(rt.source_doc_quantity,0) ,
                   NVL(rt.po_unit_price,0) * NVL(rt.source_doc_quantity,0) * rt.currency_conversion_rate))
            INTO  p_adjustment_row.prior_landed_cost
            FROM  rcv_transactions rt
            WHERE rt.transaction_id = p_adjustment_row.rcv_transaction_id;

            IF l_debug_level >= l_debug_level_low THEN
                fnd_file.put_line(fnd_file.log,'Prior Landed Cost for Estimated: ' || p_adjustment_row.prior_landed_cost);
            END IF;
        END IF;
    END IF;  /* end for item price component type */

    IF l_debug_level >= l_debug_level_low THEN
        fnd_file.put_line(fnd_file.log,'Start validation');
    END IF;

    IF p_adjustment_row.new_landed_cost < 0 THEN
       fnd_file.put_line(fnd_file.log,'New landed cost is less than zero. Then skipping to insert in transactions table');
       p_validation_status:='F';
    ELSIF p_adjustment_row.prior_landed_cost <0 THEN
       fnd_file.put_line(fnd_file.log,'Prior landed cost amount is less than zero. Then skipping to insert in transactions table');
       p_validation_status:='F';
    ELSIF ((p_adjustment_row.new_landed_cost - p_adjustment_row.prior_landed_cost) = 0) THEN
       fnd_file.put_line(fnd_file.log,'Adjustment amount is zero. Then skipping to insert in transactions table');
       p_validation_status:='F';
    ELSIF  p_adjustment_row.rcv_transaction_id <=0 THEN
       fnd_file.put_line(fnd_file.log,'Invalid Rcv Transaction. Then skipping to insert in transactions table');
       p_validation_status:='F';
    ELSIF  p_adjustment_row.rcv_transaction_id > 0 THEN

        IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line(fnd_file.log,'Checking lcm flag');
        END IF;

        OPEN check_lcm_flag ;
        FETCH check_lcm_flag INTO l_lcm_flag, l_inventory_item_id;
        CLOSE check_lcm_flag;

        IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line(fnd_file.log,'LCM Flag: ' || l_lcm_flag || 'Inventory Item Id' ||l_inventory_item_id);
        END IF;

        IF l_lcm_flag = 'N' THEN
            fnd_file.put_line(fnd_file.log,'PO Shipment is not LCM Enabled. then skipping to insert in transactions table');
            p_validation_status:='F';
        ELSIF  p_adjustment_row.inventory_item_id <> l_inventory_item_id THEN
           fnd_file.put_line(fnd_file.log,'Not matched Item. then skipping to insert in transactions table');
           p_validation_status:='F';
        END IF;
    END IF;

    IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line(fnd_file.log,'Component Type: ' || p_adjustment_row.component_type);
    END IF;

    IF (p_adjustment_row.cost_cmpntcls_id IS NOT NULL OR
        p_adjustment_row.cost_analysis_code IS NOT NULL) THEN

        IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line(fnd_file.log,'Validate Cost Component Class');
        END IF;

         -- validate cost component class id, should exists in CM_CMPT_MST table
        OPEN cur_costcptcls_exists(p_adjustment_row.cost_cmpntcls_id);
        FETCH cur_costcptcls_exists INTO l_exists;
            IF cur_costcptcls_exists%NOTFOUND THEN
                fnd_file.put_line(fnd_file.log,'Cost component class ID is not valid, not exists in cost components table');
                p_validation_status:='F';
            END IF;
        CLOSE cur_costcptcls_exists;

        IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line(fnd_file.log,'Open cursor to validate Cost Analysis Code');
        END IF;

        -- Validate cost analysis code, cost analysis code should exists in CM_ALYS_MST  table
        OPEN cur_analysis_cd_exists (p_adjustment_row.cost_analysis_code);
        FETCH cur_analysis_cd_exists INTO l_exists;
            IF cur_analysis_cd_exists%NOTFOUND THEN
                fnd_file.put_line(fnd_file.log,'Cost Analysis code is not valid, not exists in cost components table');
                p_validation_status:='F';
            END IF;
        CLOSE cur_analysis_cd_exists;
    END IF;

    IF l_debug_level >= l_debug_level_low THEN
        fnd_file.put_line(fnd_file.log,'Transaction Type: ' || p_adjustment_row.rcv_transaction_type);
    END IF;

    -- populate Event columns
    IF l_debug_level >= l_debug_level_low THEN
        fnd_file.put_line(fnd_file.log,'Define Event Types');
    END IF;

    IF p_adjustment_row.rcv_transaction_type = 'DELIVER' THEN

         OPEN cur_asset_inventory (p_adjustment_row.rcv_transaction_id);
         FETCH cur_asset_inventory INTO l_asset_inventory;
         CLOSE cur_asset_inventory;

        IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line(fnd_file.log,'Asset Inventory:' || l_asset_inventory);
        END IF;
            /* assest inventory is means assest sub inventory else expanse sub inventory */
        IF l_asset_inventory  = 1 THEN
            p_adjustment_row.event_type := 16;
            p_adjustment_row.event_source := 'LC_ADJUST_DELIVER';
        ELSE
            p_adjustment_row.event_type := 17;
            p_adjustment_row.event_source := 'LC_ADJUST_EXP_DELIVER';
        END IF;

         /* prorate charges for deliver transaction, charges in lc_adj_headers view for the deliver trabsaction
            are for the entire receive qty. these charges need to be prorated for each deliver transactions for parent
            receipt transaction */
             -- get the parent transaction id for deliver transaction
            OPEN  get_rcv_trans(p_adjustment_row.rcv_transaction_id);
            FETCH get_rcv_trans INTO l_parent_rt_id, l_dummy, l_dummy1;
            CLOSE get_rcv_trans;

             -- get parent transaction primary qty
            OPEN  get_rcv_trans(l_parent_rt_id);
            FETCH get_rcv_trans INTO l_dummy, l_rcv_primary_qty, l_dummy1;
            CLOSE get_rcv_trans;

             -- deliver transactions qty and receive transaction qty are not same then
            IF (l_rcv_primary_qty <> p_adjustment_row.primary_quantity) THEN

              l_new_landed_cost := (p_adjustment_row.primary_quantity * p_adjustment_row.new_landed_cost)/nvl(l_rcv_primary_qty,1);

              IF l_debug_level >= l_debug_level_low THEN
                fnd_file.put_line(fnd_file.log,'Prorated deliver transaction prorated new landed cost: '||l_new_landed_cost ||
                  'new landed cost: '||p_adjustment_row.new_landed_cost||'deliver trans qty: '||p_adjustment_row.primary_quantity||
                  'parent trans qty: '||l_rcv_primary_qty);
              END IF;
              p_adjustment_row.new_landed_cost   := l_new_landed_cost;

               --prorate prior landed cost for deliver trans for actual LC adjustments
              IF (p_adjustment_row.lc_adjustment_flag = 1 OR
                  p_adjustment_row.adjustment_num > 0) THEN

                l_prorated_prior_lc := (p_adjustment_row.primary_quantity * p_adjustment_row.prior_landed_cost)/nvl(l_rcv_primary_qty,1);

                IF l_debug_level >= l_debug_level_low THEN
                  fnd_file.put_line(fnd_file.log,'Prorated deliver transaction prorated prior landed cost: '||l_prorated_prior_lc ||
                    'prior landed cost: '||p_adjustment_row.prior_landed_cost||'deliver trans qty: '||p_adjustment_row.primary_quantity||
                    'parent trans qty: '||l_rcv_primary_qty);
                END IF;
                p_adjustment_row.prior_landed_cost := l_prorated_prior_lc;
              END IF;

            END IF; -- end for deliver qty and receive qty not matched

        p_adjustment_row.event_source_id := p_adjustment_row.rcv_transaction_id;

    ELSIF (p_adjustment_row.rcv_transaction_type = 'RETURN TO VENDOR') THEN

        IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line(fnd_file.log,'RCV Transaction type:' || p_adjustment_row.rcv_transaction_type);
        END IF;
            /* for Return to vendor transaction destination type is receiving */
          p_adjustment_row.event_type := 15;
          p_adjustment_row.event_source := 'LC_ADJUST_RECEIPT';
          p_adjustment_row.event_source_id := p_adjustment_row.rcv_transaction_id;

         /* prorate charges for return to vendor transaction based on the parent transaction,
            charges in lc_adj_headers view for the entire receive qty.
            these return to vendor charges need to be prorated based on parent receipt transaction */

             -- get the parent transaction id for the return to vendor transaction
            OPEN  get_rcv_trans(p_adjustment_row.rcv_transaction_id);
            FETCH get_rcv_trans INTO l_parent_rt_id, l_dummy, l_dummy1;
            CLOSE get_rcv_trans;

             -- get parent transaction primary qty
            OPEN  get_rcv_trans(l_parent_rt_id);
            FETCH get_rcv_trans INTO l_dummy, l_rcv_primary_qty, l_dummy1;
            CLOSE get_rcv_trans;

             -- return to vendor transactions qty and parent receive transaction qty are not same then
            IF (l_rcv_primary_qty <> p_adjustment_row.primary_quantity) THEN

              l_new_landed_cost := (p_adjustment_row.primary_quantity * p_adjustment_row.new_landed_cost)/nvl(l_rcv_primary_qty,1);

              IF l_debug_level >= l_debug_level_low THEN
                fnd_file.put_line(fnd_file.log,'Prorated return to vendor transaction. prorated new landed cost: '||l_new_landed_cost ||
                  'new landed cost: '||p_adjustment_row.new_landed_cost||'return to vendor trans qty: '||p_adjustment_row.primary_quantity||
                  'parent receive trans qty: '||l_rcv_primary_qty);
              END IF;
              p_adjustment_row.new_landed_cost   := l_new_landed_cost;

               --prorate prior landed cost for return to vendor trans for actual LC adjustments
              IF (p_adjustment_row.lc_adjustment_flag = 1 OR
                  p_adjustment_row.adjustment_num > 0) THEN

                l_prorated_prior_lc := (p_adjustment_row.primary_quantity * p_adjustment_row.prior_landed_cost)/nvl(l_rcv_primary_qty,1);

                IF l_debug_level >= l_debug_level_low THEN
                  fnd_file.put_line(fnd_file.log,'Prorated return to vendor transaction. prorated prior landed cost: '||l_prorated_prior_lc ||
                    'prior landed cost: '||p_adjustment_row.prior_landed_cost||'return to vendor trans qty: '||p_adjustment_row.primary_quantity||
                    'parent receive trans qty: '||l_rcv_primary_qty);
                END IF;
                p_adjustment_row.prior_landed_cost := l_prorated_prior_lc;
              END IF;

            END IF; -- end for return to vendor qty and receive qty not matched

    ELSIF p_adjustment_row.rcv_transaction_type = 'RETURN TO RECEIVING' THEN

         IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line(fnd_file.log,'RCV Transaction type:' || p_adjustment_row.rcv_transaction_type);
         END IF;
         OPEN cur_asset_inventory (p_adjustment_row.rcv_transaction_id);
         FETCH cur_asset_inventory INTO l_asset_inventory;
         CLOSE cur_asset_inventory;

          IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line(fnd_file.log,'Asset Inventory:' || l_asset_inventory);
          END IF;
              /* Return to receiving transaction destination type is deliver */
              /* assest inventory is means assest sub inventory else expanse sub inventory */
          IF l_asset_inventory  = 1 THEN
             p_adjustment_row.event_type := 16;
             p_adjustment_row.event_source := 'LC_ADJUST_DELIVER';
          ELSE
             p_adjustment_row.event_type := 17;
             p_adjustment_row.event_source := 'LC_ADJUST_EXP_DELIVER';
           END IF;

         /* prorate charges for Return to receiving transaction based on the parent deliver transaction,
            charges in lc_adj_headers view for the entire deliver qty.
            these Return to receiving transaction charges need to be prorated based on parent deliver transaction */

             -- get the parent transaction id for the return to receiving transaction
            OPEN  get_rcv_trans(p_adjustment_row.rcv_transaction_id);
            FETCH get_rcv_trans INTO l_parent_rt_id, l_dummy, l_dummy1;
            CLOSE get_rcv_trans;

             -- get parent transaction primary qty
            OPEN  get_rcv_trans(l_parent_rt_id);
            FETCH get_rcv_trans INTO l_dummy, l_rcv_primary_qty, l_dummy1;
            CLOSE get_rcv_trans;

             -- return to receiving transactions qty and parent deliver transaction qty are not same then
            IF (l_rcv_primary_qty <> p_adjustment_row.primary_quantity) THEN

              l_new_landed_cost := (p_adjustment_row.primary_quantity * p_adjustment_row.new_landed_cost)/nvl(l_rcv_primary_qty,1);

              IF l_debug_level >= l_debug_level_low THEN
                fnd_file.put_line(fnd_file.log,'Prorated return to receiving transaction. prorated new landed cost: '||l_new_landed_cost ||
                  'new landed cost: '||p_adjustment_row.new_landed_cost||'return to receiving trans qty: '||p_adjustment_row.primary_quantity||
                  'parent deliver trans qty: '||l_rcv_primary_qty);
              END IF;
              p_adjustment_row.new_landed_cost   := l_new_landed_cost;

               --prorate prior landed cost for return to receiving trans for actual LC adjustments
              IF (p_adjustment_row.lc_adjustment_flag = 1 OR
                  p_adjustment_row.adjustment_num > 0) THEN

                l_prorated_prior_lc := (p_adjustment_row.primary_quantity * p_adjustment_row.prior_landed_cost)/nvl(l_rcv_primary_qty,1);

                IF l_debug_level >= l_debug_level_low THEN
                  fnd_file.put_line(fnd_file.log,'Prorated return to receiving transaction. prorated prior landed cost: '||l_prorated_prior_lc ||
                    'prior landed cost: '||p_adjustment_row.prior_landed_cost||'return to receiving trans qty: '||p_adjustment_row.primary_quantity||
                    'parent deliver trans qty: '||l_rcv_primary_qty);
                END IF;
                p_adjustment_row.prior_landed_cost := l_prorated_prior_lc;
              END IF;

            END IF; -- end for return to receiving qty and receive qty not matched

        p_adjustment_row.event_source_id := p_adjustment_row.rcv_transaction_id;

    ELSIF p_adjustment_row.rcv_transaction_type = 'CORRECT' THEN

         --get the parent transaction id, destination type for the correct transaction
         OPEN  get_rcv_trans(p_adjustment_row.rcv_transaction_id);
         FETCH get_rcv_trans INTO l_parent_rt_id, l_dummy, l_destination_type_code;
         CLOSE get_rcv_trans;
         IF l_destination_type_code = 'INVENTORY' THEN

            IF l_debug_level >= l_debug_level_medium THEN
              fnd_file.put_line(fnd_file.log,'RCV Transaction type:' || p_adjustment_row.rcv_transaction_type
                                           ||'Destination type: '||l_destination_type_code);
            END IF;
            OPEN cur_asset_inventory (p_adjustment_row.rcv_transaction_id);
            FETCH cur_asset_inventory INTO l_asset_inventory;
            CLOSE cur_asset_inventory;

              IF l_debug_level >= l_debug_level_medium THEN
                 fnd_file.put_line(fnd_file.log,'Asset Inventory:' || l_asset_inventory);
              END IF;
               /* Correct transaction destination type is inventory */
               /* assest inventory is means assest sub inventory else expanse sub inventory */
              IF l_asset_inventory  = 1 THEN
                 p_adjustment_row.event_type := 16;
                 p_adjustment_row.event_source := 'LC_ADJUST_DELIVER';
              ELSE
                 p_adjustment_row.event_type := 17;
                 p_adjustment_row.event_source := 'LC_ADJUST_EXP_DELIVER';
              END IF;
         ELSE  -- destination type receive
             IF l_debug_level >= l_debug_level_medium THEN
               fnd_file.put_line(fnd_file.log,'RCV Transaction type:' || p_adjustment_row.rcv_transaction_type
                                           ||'Destination type: '||l_destination_type_code);
             END IF;
               p_adjustment_row.event_type := 15;
               p_adjustment_row.event_source := 'LC_ADJUST_RECEIPT';
         END IF;

         /* prorate charges for correct transaction based on the parent transaction,
            charges in lc_adj_headers view for the entire parent transaction qty.
            these correct transaction charges need to be prorated based on parent transaction qty */

             -- get parent transaction primary qty
            OPEN  get_rcv_trans(l_parent_rt_id);
            FETCH get_rcv_trans INTO l_dummy, l_rcv_primary_qty, l_dummy1;
            CLOSE get_rcv_trans;

             -- Correct transactions qty and parent transaction qty are not same then
            IF (l_rcv_primary_qty <> p_adjustment_row.primary_quantity) THEN

              l_new_landed_cost := (p_adjustment_row.primary_quantity * p_adjustment_row.new_landed_cost)/nvl(l_rcv_primary_qty,1);

              IF l_debug_level >= l_debug_level_low THEN
                fnd_file.put_line(fnd_file.log,'Prorated Correct transaction. prorated new landed cost: '||l_new_landed_cost ||
                  'new landed cost: '||p_adjustment_row.new_landed_cost||'correct trans qty: '||p_adjustment_row.primary_quantity||
                  'parent trans qty: '||l_rcv_primary_qty);
              END IF;
              p_adjustment_row.new_landed_cost   := l_new_landed_cost;

               --prorate prior landed cost for correct trans for actual LC adjustments
              IF (p_adjustment_row.lc_adjustment_flag = 1 OR
                  p_adjustment_row.adjustment_num > 0) THEN

                l_prorated_prior_lc := (p_adjustment_row.primary_quantity * p_adjustment_row.prior_landed_cost)/nvl(l_rcv_primary_qty,1);

                IF l_debug_level >= l_debug_level_low THEN
                  fnd_file.put_line(fnd_file.log,'Prorated correct transaction. prorated prior landed cost: '||l_prorated_prior_lc ||
                    'prior landed cost: '||p_adjustment_row.prior_landed_cost||'correct trans qty: '||p_adjustment_row.primary_quantity||
                    'parent trans qty: '||l_rcv_primary_qty);
                END IF;
                p_adjustment_row.prior_landed_cost := l_prorated_prior_lc;
              END IF;

            END IF; -- end for qty not matched

         p_adjustment_row.event_source_id := p_adjustment_row.rcv_transaction_id;

    ELSE
        IF l_debug_level >= l_debug_level_low THEN
            fnd_file.put_line(fnd_file.log,'RCV Transaction Type:'|| p_adjustment_row.rcv_transaction_type);
        END IF;
        p_adjustment_row.event_type := 15;
        p_adjustment_row.event_source := 'LC_ADJUST_RECEIPT';
        p_adjustment_row.event_source_id := p_adjustment_row.rcv_transaction_id;
    END IF;

    IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line(fnd_file.log,'Event Type:' || p_adjustment_row.event_type);
        fnd_file.put_line(fnd_file.log,'Event Source:' || p_adjustment_row.event_source);
        fnd_file.put_line(fnd_file.log,'Event Source Id:' || p_adjustment_row.event_source_id);
    END IF;

    IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line(fnd_file.log,'Leaving Procedure: '||l_proc_name);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line(fnd_file.log,'Error: '||SQLERRM);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        p_validation_status := 'F';

END validate_adjustments;

/************************************************************************
NAME
        Create_AdjTrxLines

SYNOPSIS
        Type       : Private
        Function   : Create landed cost adjustment transactions line
                     in gmf_lc_adj_transactions table after validation

         Pre-reqs   : None
         Parameters :
                 IN : p_le_id     IN NUMBER
                      p_ledger_id IN NUMBER
                      p_adj_line  IN transaction_type

                OUT : x_return_status  OUT NOCOPY VARCHAR2


DESCRIPTION
              Insert Landed cost adjustment transaction in gmf_lc_adj_transactions
              table
AUTHOR
  LCM-OPM dev 04-Aug-2009, LCM-OPM Integration, bug

HISTORY
*************************************************************************/

PROCEDURE Create_AdjTrxLines(p_le_id          IN NUMBER,
                             p_ledger_id      IN NUMBER,
                             p_adjustment_row IN transaction_type,
                             x_return_status  OUT NOCOPY VARCHAR2) IS

l_proc_name VARCHAR2(40) := 'Process_Lc_Adjustments';

BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line(fnd_file.log,'Entered Procedure: '||l_proc_name);
    END IF;

    INSERT INTO gmf_lc_adj_transactions
                         (adj_transaction_id,     -- 01
                          rcv_transaction_id,     -- 02
                          event_type,             -- 03
                          event_source,           -- 04
                          event_source_id,        -- 05
                          ledger_id,              -- 06
                          org_id,                 -- 07
                          inventory_item_id,      -- 08
                          organization_id,        -- 09
                          legal_entity_id,        -- 10
                          parent_ship_line_id,    -- 11
                          ship_header_id,         -- 12
                          ship_line_group_id,     -- 13
                          ship_line_id,           -- 14
                          adjustment_num,         -- 15
                          parent_table_name,      -- 16
                          parent_table_id,        -- 17
                          prior_landed_cost,      -- 18
                          new_landed_cost,        -- 19
                          charge_line_type_id,    -- 20
                          charge_line_type_code,  -- 21
                          cost_acquisition_flag,  -- 22
                          component_type,         -- 23
                          component_name,         -- 24
                          cost_cmpntcls_id,       -- 25
                          cost_analysis_code,     -- 26
                          lc_adjustment_flag,     -- 27
                          transaction_date,       -- 28
                          transaction_quantity,   -- 29
                          transaction_uom_code,   -- 30
                          primary_quantity,       -- 31
                          primary_uom_code,       -- 32
                          currency_code,          -- 33
                          /*currency_conversion_type, -- 34
                          currency_conversion_rate, -- 35
                          currency_conversion_date, -- 36
                          */
                          lc_ship_num,              -- 37
                          lc_ship_line_num,         -- 38
                          lc_var_account_id,        -- 39
                          lc_absorption_account_id, -- 40
                          accounted_flag,           -- 41
                          final_posting_date,       -- 42
                          creation_date,            -- 43
                          created_by,               -- 44
                          last_update_date,         -- 45
                          last_updated_by,          -- 46
                          last_update_login,        -- 47
                          request_id,               -- 48
                          program_application_id,   -- 49
                          program_id,               -- 50
                          program_udpate_date)      -- 51
                          VALUES
                          (gmf_lc_adj_transactions_s.NEXTVAL,        -- 01
                           p_adjustment_row.rcv_transaction_id,      -- 02
                           p_adjustment_row.event_type,              -- 03
                           p_adjustment_row.event_source,            -- 04
                           p_adjustment_row.event_source_id,         -- 05
                           p_ledger_id,                              -- 06
                           p_adjustment_row.org_id,                  -- 07
                           p_adjustment_row.inventory_item_id,       -- 08
                           p_adjustment_row.organization_id,         -- 09
                           p_le_id,                                  -- 10
                           p_adjustment_row.parent_ship_line_id,     -- 11
                           p_adjustment_row.ship_header_id,          -- 12
                           p_adjustment_row.ship_line_group_id,      -- 13
                           p_adjustment_row.ship_line_id,            -- 14
                           p_adjustment_row.adjustment_num,          -- 15
                           p_adjustment_row.parent_table_name,       -- 16
                           p_adjustment_row.parent_table_id,         -- 17
                           p_adjustment_row.prior_landed_cost,       -- 18
                           p_adjustment_row.new_landed_cost,         -- 19
                           p_adjustment_row.charge_line_type_id,     -- 20
                           p_adjustment_row.charge_line_type_code,   -- 21
                           p_adjustment_row.cost_acquisition_flag,   -- 22
                           p_adjustment_row.component_type,          -- 23
                           p_adjustment_row.component_name,          -- 24
                           p_adjustment_row.cost_cmpntcls_id,        -- 25
                           p_adjustment_row.cost_analysis_code,      -- 26
                           p_adjustment_row.lc_adjustment_flag,      -- 27
                           p_adjustment_row.transaction_date,        -- 28
                           p_adjustment_row.transaction_quantity,    -- 29
                           p_adjustment_row.transaction_uom_code,    -- 30
                           p_adjustment_row.primary_quantity,        -- 31
                           p_adjustment_row.primary_uom_code,        -- 32
                           p_adjustment_row.currency_code,             -- 33
                           /*
                           p_adjustment_row.currency_conversion_type,  -- 34
                           p_adjustment_row.currency_conversion_rate,  -- 35
                           p_adjustment_row.currency_conversion_date,  -- 36
                           */
                           p_adjustment_row.lc_ship_num,               -- 37
                           p_adjustment_row.lc_ship_line_num,          -- 38
                           p_adjustment_row.lc_var_account_id,         -- 39
                           p_adjustment_row.lc_absorption_account_id ,  -- 40
                           'N',                                        -- 41
                           NULL,                                       -- 42
                           SYSDATE,                                    -- 43
                           fnd_global.user_id,                         -- 44
                           SYSDATE,                                    -- 45
                           fnd_global.user_id,                         -- 46
                           0,                                          -- 47
                           fnd_global.conc_request_id,                 -- 48
                           fnd_global.conc_program_id,                 -- 49
                           fnd_global.prog_appl_id,                    -- 50
                           SYSDATE                                     -- 51
                          );

    IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line(fnd_file.log,'Leaving Procedure: '||l_proc_name);
    END IF;
--
EXCEPTION
    WHEN OTHERS THEN
        IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line(fnd_file.log,'Error: '||SQLERRM);
            fnd_file.put_line(fnd_file.log,'Failed to insert into adjsutment transactions table in '||l_proc_name);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Create_AdjTrxLines;

/************************************************************************
NAME
        Process_Lc_Adjustments

SYNOPSIS
        Type       : Public
        Function   : This is called by a concurrent program
                     to import LCM adjustments into OPM tables

         Pre-reqs   : None
         Parameters :
                 IN   p_le_id                  IN NUMBER
                      p_from_organization_id   IN NUMBER
                      p_to_organization_id     IN NUMBER
                      p_from_inventory_item_id IN NUMBER
                      p_to_inventory_item_id   IN NUMBER
                      p_start_date             IN DATE
                      p_end_date               IN DATE
                OUT   errbuf          OUT NOCOPY VARCHAR2
                      retcode         OUT NOCOPY VARCHAR2

DESCRIPTION
            Use this program to import LCM adjustments into OPM tables
AUTHOR
  LCM-OPM dev 04-Aug-2009, LCM-OPM Integration, bug 8642337

HISTORY
*************************************************************************/

PROCEDURE Process_Lc_Adjustments
        ( errbuf                    OUT NOCOPY VARCHAR2,
          retcode                   OUT NOCOPY VARCHAR2,
          p_le_id                    IN NUMBER,
          p_from_organization_id     IN NUMBER,
          p_to_organization_id       IN NUMBER,
          p_from_inventory_item_id   IN NUMBER,
          p_to_inventory_item_id     IN NUMBER,
          p_start_date               IN VARCHAR2 ,
          p_end_date                 IN VARCHAR2) IS


        -- Load LC adjustments
    CURSOR lc_adjustments_cur (cp_le_id        NUMBER,
                               cp_from_org_cd  mtl_parameters.organization_code%TYPE,
                               cp_to_org_cd    mtl_parameters.organization_code%TYPE,
                               cp_from_item    mtl_item_flexfields.item_number%TYPE,
                               cp_to_item      mtl_item_flexfields.item_number%TYPE,
                               cp_start_dt     DATE,
                               cp_end_dt       DATE) IS
    SELECT  glah.parent_ship_line_id,
            glah.adjustment_num,
            glah.ship_header_id,
            glah.org_id,
            glah.ship_line_group_id,
            glah.ship_line_id,
            glah.organization_id,
            glah.inventory_item_id,
            NVL(glah.prior_landed_cost,0) AS prior_landed_cost,
            NVL(glah.landed_cost,0) AS new_landed_cost,
            glah.allocation_percent,
            glah.charge_line_type_id,
            glah.charge_line_type_code,
            glah.cost_acquisition_flag,
            glah.component_type,
            glah.component_name,
            glah.parent_table_name,
            glah.parent_table_id,
            glah.cost_cmpntcls_id,
            glah.cost_analysis_code,
            glah.transaction_date,
            NVL(glah.transaction_quantity,0) AS transaction_quantity,
            glah.transaction_uom_code,
            NVL(glah.primary_quantity,0) AS primary_quantity,
            glah.primary_uom_code,
            glah.lc_adjustment_flag,
            glah.rcv_transaction_id,
            glah.rcv_transaction_type,
            glah.lc_ship_num       lc_ship_num,
            glah.lc_ship_line_num  lc_ship_line_num,
            mp.lcm_enabled_flag,
            mp.lcm_var_account      lc_var_account_id,
            rp.lcm_account_id       lc_absorption_account_id
      FROM
            gmf_lc_adj_headers_v  glah,
            org_organization_definitions ood,
            mtl_parameters mp,
            rcv_parameters rp,
            mtl_item_flexfields mif
     WHERE
            mp.organization_id      =  glah.organization_id
       AND  ood.legal_entity        =  cp_le_id
       AND  mp.process_enabled_flag =  'Y'
       AND  mp.lcm_enabled_flag     =  'Y'
       AND  ood.organization_id     =  glah.organization_id
       AND  mp.organization_id      =  glah.organization_id
       AND  rp.organization_id      =  glah.organization_id
       AND  mp.organization_code   >=  NVL(cp_from_org_cd, mp.organization_code)
       AND  mp.organization_code   <=  NVL(cp_to_org_cd, mp.organization_code)
       AND  glah.inventory_item_id  =  mif.inventory_item_id
       AND  glah.organization_id    =  mif.organization_id
       AND  mif.item_number        >=  NVL(cp_from_item, mif.item_number)
       AND  mif.item_number        <=  NVL(cp_to_item, mif.item_number)
       AND  TRUNC(glah.transaction_date) >= TRUNC(NVL(cp_start_dt, glah.transaction_date))
       AND  TRUNC(glah.transaction_date) <= TRUNC(NVL(cp_end_dt, glah.transaction_date))
       AND  glah.component_type IN ('ITEM PRICE','CHARGE')
     --  AND  NVL(glah.new_landed_cost,0) - NVL(glah.prior_landed_cost,0) <> 0
       AND  NOT EXISTS (SELECT 1 FROM gmf_lc_adj_transactions lat
                         WHERE lat.adjustment_num     = glah.adjustment_num
                           AND lat.ship_header_id     = glah.ship_header_id
                           AND lat.ship_line_id       = glah.ship_line_id
                           AND lat.rcv_transaction_id = glah.rcv_transaction_id
                           AND lat.component_type     = glah.component_type
                           AND lat.component_name     = glah.component_name
                           AND lat.legal_entity_id    = cp_le_id)
       ORDER BY glah.rcv_transaction_id, glah.adjustment_num;

     -- get legal entity name
     CURSOR  cur_get_le IS
     SELECT  legal_entity_name
       FROM  gmf_legal_entities
      WHERE  legal_entity_id = p_le_id;

        -- Get organization code
     CURSOR  cur_get_org_cd (cp_organization_id NUMBER) IS
     SELECT  organization_code
       FROM  mtl_parameters
      WHERE  organization_id = cp_organization_id ;

        -- Get item number
     CURSOR  cur_get_item (cp_inventory_item_id  NUMBER) IS
     SELECT  item_number
       FROM  mtl_item_flexfields
      WHERE  inventory_item_id = cp_inventory_item_id
        AND  rownum < 2;

     lc_adjustments lc_adjustments_type;

     l_proc_name VARCHAR2(40) := 'Process_Lc_Adjustments';
     l_return_status VARCHAR2(1) ;

     l_from_org_code  mtl_parameters.organization_code%TYPE := NULL;
     l_to_org_code    mtl_parameters.organization_code%TYPE := NULL;

     l_from_item      mtl_item_flexfields.item_number%TYPE := NULL;
     l_to_item        mtl_item_flexfields.item_number%TYPE := NULL;

     l_le_id                 NUMBER;
     l_le_name               gmf_legal_entities.legal_entity_name%TYPE;
     l_from_organization_id  NUMBER;
     l_to_organization_id    NUMBER;
     l_from_item_id          NUMBER;
     l_to_item_id            NUMBER;
     l_start_date            DATE := NULL;
     l_end_date              DATE := NULL;
     l_ledger_id             NUMBER;

     l_tmp  BOOLEAN;

     l_ret_status       VARCHAR2(1);
     l_adjustment_row   transaction_type;
     l_total_lines      NUMBER := 0;
     l_total_adj        NUMBER := 0;
     l_total_ln_error   NUMBER := 0;

BEGIN

    l_debug_level_none     := 0;
    l_debug_level_low      := 1;
    l_debug_level_medium   := 2;
    l_debug_level_high     := 3;

    l_tmp := TRUE;
    l_debug_level := TO_NUMBER(FND_PROFILE.VALUE( 'GMF_CONC_DEBUG' ));
    l_ret_status :='S';

     -- copy parameters into local variables
    l_le_id                := p_le_id;
    l_from_organization_id := p_from_organization_id;
    l_to_organization_id   := p_to_organization_id;
    l_from_item_id         := p_from_inventory_item_id;
    l_to_item_id           := p_to_inventory_item_id;

     fnd_file.put_line(fnd_file.log,'GMF_CONC_DEBUG Profile value : '||l_debug_level);
    IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line(fnd_file.log,'Entered Procedure: '||l_proc_name);
    END IF;

    fnd_file.put_line(fnd_File.LOG,'Landed Cost Adjustment Import Process started on '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

    IF l_debug_level >= l_debug_level_high THEN
        fnd_file.put_line(fnd_file.log,'Verify Legal Entity');
    END IF;

    -- verify LE
    IF l_le_id IS NOT NULL THEN
      OPEN cur_get_le;
      FETCH cur_get_le INTO l_le_name;
      CLOSE cur_get_le;
    ELSE
      fnd_file.put_line(fnd_File.LOG,'Insufficient Input parameters' );
      retcode := 3;
      RETURN ;  /* exist from the process */
    END IF;
      fnd_file.put_line(fnd_File.LOG,'Input parameters Legal entity / Id '|| l_le_name ||'/'||l_le_id);

    IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line(fnd_file.log,'Get organization code');
    END IF;

    -- Get from organization code
    IF l_from_organization_id IS NOT NULL THEN
        OPEN cur_get_org_cd ( l_from_organization_id) ;
        FETCH cur_get_org_cd INTO l_from_org_code;
        CLOSE cur_get_org_cd;
    END IF;
        -- Get to organization code
    IF l_to_organization_id IS NOT NULL THEN
        OPEN cur_get_org_cd ( l_to_organization_id );
        FETCH cur_get_org_cd INTO l_to_org_code;
        CLOSE cur_get_org_cd;
    END IF;

    IF l_debug_level >= l_debug_level_low THEN
        fnd_file.put_line(fnd_File.LOG,'Input parameters From OrgId/Code '||l_from_organization_id ||'/'||l_from_org_code);
        fnd_file.put_line(fnd_File.LOG,'Input parameters To OrgId/Code '||l_to_organization_id ||'/'||l_to_org_code);
    END IF;

    IF l_debug_level >= l_debug_level_high THEN
        fnd_file.put_line(fnd_file.log,'Get item number');
    END IF;

        -- Get from Item number
    IF l_from_item_id IS NOT NULL THEN
        OPEN cur_get_item (l_from_item_id);
        FETCH cur_get_item INTO l_from_item;
        CLOSE cur_get_item;
    END IF;
        -- Get to Item number
    IF l_to_item_id IS NOT NULL THEN
        OPEN cur_get_item (l_to_item_id);
        FETCH cur_get_item INTO l_to_item;
        CLOSE cur_get_item;
    END IF;

    IF l_debug_level >= l_debug_level_low THEN
       fnd_file.put_line(fnd_File.LOG,'Input parameters From ItemId/Item Number '||l_from_item_id ||'/'||l_from_item);
       fnd_file.put_line(fnd_File.LOG,'Input parameters To ItemId/Item Number '||l_to_item_id ||'/'||l_to_item);
    END IF;

    IF p_start_date IS NOT NULL THEN
        l_start_date := fnd_date.canonical_to_date(p_start_date);
    END IF;

    IF p_end_date IS NOT NULL THEN
        l_end_date := fnd_date.canonical_to_date(p_end_date);
    END IF;
    IF l_debug_level >= l_debug_level_low THEN
       fnd_file.put_line(fnd_File.LOG,'Input parameters Start date '||l_start_date );
       fnd_file.put_line(fnd_File.LOG,'Input parameters End date '||l_end_date);
    END IF;

    IF l_debug_level >= l_debug_level_low THEN
        fnd_file.put_line(fnd_file.log,'Get ledger ID');
    END IF;

    -- Get the ledger_id for the legal entity parameter
    SELECT primary_ledger_id
      INTO   l_ledger_id
      FROM gmf_legal_entities
     WHERE legal_entity_id = p_le_id;

    IF l_debug_level >= l_debug_level_low THEN
        fnd_file.put_line(fnd_file.log,'Open Cursor');
    END IF;

    FOR adjustments_row IN lc_adjustments_cur (l_le_id,
                            l_from_org_code,
                            l_to_org_code,
                            l_from_item,
                            l_to_item,
                            l_start_date,
                            l_end_date)  LOOP

    IF l_debug_level >= l_debug_level_high THEN
        fnd_file.put_line(fnd_file.log,'');
        fnd_file.put_line(fnd_file.log,'Line to be processed:');
        fnd_file.put_line(fnd_file.log,'Rcv Ttransaction ID' ||adjustments_row.rcv_transaction_id ||
                                       ' Ship Num: '||adjustments_row.lc_ship_num ||
                                       ' Ship Line Num: '||adjustments_row.lc_ship_line_num ||
                                       ' Item ID: '||adjustments_row.inventory_item_id ||
                                       ' Organization ID: '||adjustments_row.organization_id ||
                                       ' Adjustment Num: '||adjustments_row.adjustment_num ||
                                       ' Component Type: '||adjustments_row.component_type ||
                                       ' New Landed Cost: '||adjustments_row.new_landed_cost);
     END IF;

        l_total_lines := l_total_lines + 1;

        l_adjustment_row.parent_ship_line_id   := adjustments_row.parent_ship_line_id;
        l_adjustment_row.adjustment_num        := adjustments_row.adjustment_num;
        l_adjustment_row.ship_header_id        := adjustments_row.ship_header_id;
        l_adjustment_row.org_id                := adjustments_row.org_id;
        l_adjustment_row.ship_line_group_id    := adjustments_row.ship_line_group_id;
        l_adjustment_row.ship_line_id          := adjustments_row.ship_line_id;
        l_adjustment_row.organization_id       := adjustments_row.organization_id;
        l_adjustment_row.inventory_item_id     := adjustments_row.inventory_item_id;
        l_adjustment_row.prior_landed_cost     := adjustments_row.prior_landed_cost;
        l_adjustment_row.new_landed_cost       := adjustments_row.new_landed_cost;
        l_adjustment_row.allocation_percent    := adjustments_row.allocation_percent;
        l_adjustment_row.charge_line_type_id   := adjustments_row.charge_line_type_id;
        l_adjustment_row.charge_line_type_code := adjustments_row.charge_line_type_code;
        l_adjustment_row.cost_acquisition_flag := adjustments_row.cost_acquisition_flag;
        l_adjustment_row.component_type        := adjustments_row.component_type;
        l_adjustment_row.component_name        := adjustments_row.component_name;
        l_adjustment_row.parent_table_name     := adjustments_row.parent_table_name;
        l_adjustment_row.parent_table_id       := adjustments_row.parent_table_id;
        l_adjustment_row.cost_cmpntcls_id      := adjustments_row.cost_cmpntcls_id;
        l_adjustment_row.cost_analysis_code    := adjustments_row.cost_analysis_code;
        IF adjustments_row.adjustment_num = 0 THEN
            l_adjustment_row.transaction_date      := adjustments_row.transaction_date;
        ELSE  --
            SELECT max(m.adj_group_date) adj_group_date
            INTO l_adjustment_row.transaction_date
            FROM inl_matches m
            WHERE m.ship_header_id = adjustments_row.ship_header_id
            AND   m.adjustment_num = adjustments_row.adjustment_num;
        END IF;
        l_adjustment_row.transaction_quantity  := adjustments_row.transaction_quantity;
        l_adjustment_row.transaction_uom_code  := adjustments_row.transaction_uom_code;
        l_adjustment_row.primary_quantity      := adjustments_row.primary_quantity;
        l_adjustment_row.primary_uom_code      := adjustments_row.primary_uom_code;
        l_adjustment_row.lc_adjustment_flag    := adjustments_row.lc_adjustment_flag;
        l_adjustment_row.rcv_transaction_type  := adjustments_row.rcv_transaction_type;
        l_adjustment_row.rcv_transaction_id    := adjustments_row.rcv_transaction_id;
        l_adjustment_row.lc_ship_num              := adjustments_row.lc_ship_num;
        l_adjustment_row.lc_ship_line_num         := adjustments_row.lc_ship_line_num;
        l_adjustment_row.lc_var_account_id        := adjustments_row.lc_var_account_id;
        l_adjustment_row.lc_absorption_account_id := adjustments_row.lc_absorption_account_id;

        IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line(fnd_file.log,'Call Validate_Adjustments');
        END IF;

        Validate_Adjustments(p_le_id => p_le_id,
                             p_adjustment_row => l_adjustment_row,
                             p_validation_status => l_ret_status,
                             x_return_status => l_return_status);

         -- If any errors happen abort the process.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line(fnd_file.log,'Validate Adjustments Return Status: ' || l_ret_status);
        END IF;

        IF l_ret_status = 'S' THEN
            IF l_debug_level >= l_debug_level_medium THEN
                fnd_file.put_line(fnd_file.log,'Call Create_AdjTrxLines');
            END IF;
            -- Insert Into GMF_LC_ADJ_TRANSACTIONS
            Create_AdjTrxLines(p_le_id => p_le_id,
                               p_ledger_id => l_ledger_id,
                               p_adjustment_row => l_adjustment_row,
                               x_return_status => l_return_status);
            -- If any errors happen abort the process.
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            l_total_adj := l_total_adj + 1;
        ELSE
           l_total_ln_error := l_total_ln_error + 1;
           retcode := 1;
           fnd_file.put_line(fnd_file.log,'The line was not processed');
           fnd_file.put_line(fnd_file.log,'Rcv Ttransaction ID: ' ||l_adjustment_row.rcv_transaction_id ||
                                             ' Ship Num: '||l_adjustment_row.lc_ship_num ||
                                             ' Ship Line Num: '||l_adjustment_row.lc_ship_line_num ||
                                             ' Item ID: '||l_adjustment_row.inventory_item_id ||
                                             ' Organization ID: '||l_adjustment_row.organization_id ||
                                             ' Adjustment Num: '||l_adjustment_row.adjustment_num);
        END IF;
    END LOOP;

    fnd_file.put_line(fnd_file.log, 'Landed Cost Adjustments Import Processor finished at '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log,' Total of LC Adjustment(s): ' || l_total_lines||
                                   ' LC Adjustment(s) created in gmf_lc_adj_transactions table : '|| l_total_adj ||
                                   ' LC Adjustment(s) with errors: '|| l_total_ln_error);
    COMMIT;

    IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line(fnd_file.log,'Leaving Procedure: '||l_proc_name);
    END IF;

    EXCEPTION
----
  WHEN utl_file.invalid_path THEN
    retcode := 3;
    errbuf := 'Invalid path - '||to_char(SQLCODE) || ' ' || SQLERRM;
     l_tmp := fnd_concurrent.set_completion_status('ERROR',sqlerrm || ' in ' || l_proc_name);
  WHEN utl_file.invalid_mode THEN
    retcode := 3;
    errbuf := 'Invalid Mode - '||to_char(SQLCODE) || ' ' || SQLERRM;
    l_tmp := fnd_concurrent.set_completion_status('ERROR',sqlerrm || ' in ' || l_proc_name);
  WHEN utl_file.invalid_filehandle then
    retcode := 3;
    errbuf := 'Invalid filehandle - '||to_char(SQLCODE) || ' ' || SQLERRM;
    l_tmp := fnd_concurrent.set_completion_status('ERROR',sqlerrm || ' in ' || l_proc_name);
  WHEN utl_file.invalid_operation then
    retcode := 3;
    errbuf := 'Invalid operation - '||to_char(SQLCODE) || ' ' || SQLERRM;
    l_tmp := fnd_concurrent.set_completion_status('ERROR',sqlerrm || ' in ' || l_proc_name);
  WHEN utl_file.write_error then
    retcode := 3;
    errbuf := 'Write error - '||to_char(SQLCODE) || ' ' || SQLERRM;
    l_tmp := fnd_concurrent.set_completion_status('ERROR',sqlerrm || ' in ' || l_proc_name);
  WHEN FND_API.G_EXC_ERROR THEN
    retcode := 3;
    errbuf := 'An error has ocurred:  ' || SQLERRM;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    retcode := 3;
    errbuf := 'An unexpected error has ocurred: ' || SQLERRM;
  WHEN others THEN
    retcode := 3;
      errbuf := to_char(SQLCODE) || ' ' || SQLERRM;
    l_tmp := fnd_concurrent.set_completion_status('ERROR',sqlerrm || ' in ' || l_proc_name);

END Process_Lc_Adjustments;

END GMF_LC_ADJ_TRANSACTIONS_PKG;

/

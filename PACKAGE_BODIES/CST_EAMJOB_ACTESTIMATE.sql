--------------------------------------------------------
--  DDL for Package Body CST_EAMJOB_ACTESTIMATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_EAMJOB_ACTESTIMATE" AS
/* $Header: CSTPJACB.pls 115.3 2003/11/25 02:30:10 lsoo ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CST_EAMJOB_ACTESTIMATE';

/* ============================================================== */
-- FUNCTION
-- Get_eamCostElement()
--
-- DESCRIPTION
-- Function to return the correct eAM cost element, based on
-- the transaction mode and the resource id of a transaction.
--
-- PARAMETERS
-- p_txn_mode (1=material, 2=resource)
-- p_org_id
-- p_resource_id (optional; to be passed only for a resource tranx)
--
/* ================================================================= */

FUNCTION Get_eamCostElement(
          p_txn_mode             IN  NUMBER,
          p_org_id               IN  NUMBER,
          p_resource_id          IN  NUMBER := NULL)
   RETURN number  IS

   l_eam_cost_element          NUMBER;
   l_resource_type             NUMBER;
l_stmt_num                  NUMBER;
   l_debug                     VARCHAR2(80);

   BEGIN
   -------------------------------------------------------------------
   -- Determine eAM cost element.
   --   1 (equipment) ==> resource type 1 'machine'
   --   2 (labor)     ==> resource type 2 'person'
   --   3 (material)  ==> inventory or direct item
   --   For other resource types, use the default eAM cost element
   --   from eAM parameters
   --------------------------------------------------------------------

     l_debug := fnd_profile.value('MRP_DEBUG');

     if (l_debug = 'Y') THEN
       fnd_file.put_line(fnd_file.log, 'In Get_eamCostElement');
     end if;


      IF p_txn_mode = 1 THEN    -- material
         l_eam_cost_element := 3;
      ELSE                     -- resource
IF p_resource_id IS NOT NULL THEN
            l_stmt_num := 200;
            SELECT resource_type
               INTO l_resource_type
            FROM bom_resources
            WHERE organization_id = p_org_id
              AND resource_id = p_resource_id;
         END IF;      -- end checking resource id

         IF l_resource_type in (1,2) THEN
            l_eam_cost_element := l_resource_type;
         ELSE
            l_stmt_num := 210;
            SELECT def_eam_cost_element_id
               into l_eam_cost_element
            FROM wip_eam_parameters
            WHERE organization_id = p_org_id;
         END IF;      -- end checking resource type
      END IF;         -- end checking txn mode

     if (l_debug = 'Y') THEN
fnd_file.put_line(fnd_file.log, 'l_eam_cost_element: '|| to_char(l_eam_cost_element));
        fnd_file.put_line(fnd_file.log, 'resource id: '|| to_char(p_resource_id));
     end if;

      RETURN l_eam_cost_element;

   EXCEPTION
      WHEN OTHERS THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Get_eamCostElement - statement '
                           || l_stmt_num || ': '
                           || substr(SQLERRM,1,200));

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
               FND_MSG_PUB.add_exc_msg
                 (  'CST_EAMJOB_ACTESTIMATE'
                  , '.Get_eamCostElement : Statement -'||to_char(l_stmt_num)
                 );
         END IF;

         RETURN 0;
END Get_eamCostElement;


---------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   Get_DeptCostCatg                                                     --
--                                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API returns the cost category of the department                 --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.9                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    08/7/02     Hemant Gosain       Created                             --
----------------------------------------------------------------------------
PROCEDURE Get_DeptCostCatg (
                            p_api_version        IN   NUMBER,
                            p_init_msg_list      IN   VARCHAR2
                                                  := FND_API.G_FALSE,
                            p_commit             IN   VARCHAR2
                                                  := FND_API.G_FALSE,
                            p_validation_level   IN   NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,                            p_debug              IN   VARCHAR2 := 'N',

                            p_department_id      IN   NUMBER := NULL,
                            p_organization_id    IN   NUMBER := NULL,

                            p_user_id            IN   NUMBER,
                            p_request_id         IN   NUMBER,
                            p_prog_id            IN   NUMBER,
                            p_prog_app_id        IN   NUMBER,
                            p_login_id           IN   NUMBER,

                            x_dept_cost_catg     OUT NOCOPY  NUMBER,
                           x_return_status      OUT NOCOPY  VARCHAR2,
                            x_msg_count          OUT NOCOPY  NUMBER,
                            x_msg_data           OUT NOCOPY  VARCHAR2 ) IS

    l_api_name    CONSTANT      VARCHAR2(30) := 'Get_DeptCostCatg';
    l_api_version CONSTANT       NUMBER       := 1.0;
    l_api_message               VARCHAR2(10000);
    l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_organization_id           NUMBER;

    l_msg_count                 NUMBER := 0;
    l_msg_data                  VARCHAR2(8000) := '';
    l_dept_cost_catg            NUMBER := NULL;
    l_stmt_num                  NUMBER;

BEGIN

    -------------------------------------------------------------------------
    -- standard start of API savepoint
    -------------------------------------------------------------------------
    SAVEPOINT Get_DeptCostCatg;

    l_stmt_num := 5;

    -------------------------------------------------------------------------
    -- standard call to check for call compatibility
    -------------------------------------------------------------------------
    IF NOT fnd_api.compatible_api_call (
                              l_api_version,
                              p_api_version,
                              l_api_name,
                              G_PKG_NAME ) then

         RAISE fnd_api.g_exc_unexpected_error;

    END IF;
    -------------------------------------------------------------------------
    -- Initialize message list if p_init_msg_list is set to TRUE
    -------------------------------------------------------------------------

    l_stmt_num := 10;

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;


    -------------------------------------------------------------------------
    -- initialize api return status to success
    -------------------------------------------------------------------------
    x_return_status := fnd_api.g_ret_sts_success;

    -- assign to local variables

    l_stmt_num := 15;
    l_dept_cost_catg := NULL;



    IF p_department_id IS NOT NULL THEN

      l_stmt_num := 20;

      SELECT maint_cost_category,
             organization_id
      INTO   l_dept_cost_catg,
             l_organization_id
      FROM   bom_departments
      WHERE  department_id = p_department_id;

    ELSE
      l_stmt_num := 25;

      l_organization_id := p_organization_id;

    END IF;

    IF l_dept_cost_catg IS NULL THEN
      l_stmt_num := 30;

      SELECT def_maint_cost_category
      INTO l_dept_cost_catg
      FROM wip_eam_parameters
      WHERE organization_id = l_organization_id;

    END IF;

    l_stmt_num := 35;

    IF l_dept_cost_catg IS NOT NULL THEN

      l_stmt_num := 40;

      x_dept_cost_catg := l_dept_cost_catg;

    ELSE

      l_stmt_num := 45;

      l_api_message := 'Could not obtain Cost Category for Dept: '
                       ||TO_CHAR(p_department_id);
      FND_MSG_PUB.ADD_EXC_MSG('CST_EAMJOB_ACTESTIMATE', 'Get_DeptCostCatg('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
      RAISE FND_API.g_exc_error;

    END IF;

    l_stmt_num := 50;

    ---------------------------------------------------------------------------
    -- Standard check of p_commit
    ---------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    ---------------------------------------------------------------------------
    -- Standard Call to get message count and if count = 1, get message info
    ---------------------------------------------------------------------------

    FND_MSG_PUB.Count_And_Get (
        p_count     => x_msg_count,
        p_data      => x_msg_data );


 EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
       fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_EAMJOB_ACTESTIMATE'
              , 'Get_DeptCostCatg : l_stmt_num - '||to_char(l_stmt_num)
              );

        END IF;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );

END Get_DeptCostCatg;

--------------------------------------------------------------------------n
-- PROCEDURE                                                              --
--   Compute_Activity_Estimate                                            --
--                                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API Computes the estimate for an asset activity                 --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.9                                        --
--                                                                        --
--                                                                        --

--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    08/07/02     Hemant G       Created                                 --
----------------------------------------------------------------------------
PROCEDURE Compute_Activity_Estimate (
                            p_api_version           IN   NUMBER,
                            p_init_msg_list         IN   VARCHAR2
                                                      := FND_API.G_FALSE,
                            p_commit                IN   VARCHAR2
                                                      := FND_API.G_FALSE,
                            p_validation_level      IN   NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,
                            p_debug                 IN   VARCHAR2 := 'N',

                            p_activity_item_id      IN   NUMBER,
                            p_organization_id       IN   NUMBER,
                            p_alt_bom_designator    IN   VARCHAR2 := NULL,
                            p_alt_rtg_designator    IN   VARCHAR2 := NULL,
                            p_cost_group_id         IN   NUMBER   := NULL,
                            p_effective_datetime    IN   VARCHAR2 :=
                                                           fnd_date.date_to_canonical(SYSDATE),

                            p_user_id               IN   NUMBER,
                            p_request_id            IN   NUMBER,
                            p_prog_id               IN   NUMBER,
                            p_prog_app_id           IN   NUMBER,
                            p_login_id              IN   NUMBER,

                            x_ActivityEstimateTable OUT NOCOPY  ActivityEstimateTable,
                            x_return_status         OUT NOCOPY  VARCHAR2,
                            x_msg_count             OUT NOCOPY  NUMBER,
                            x_msg_data              OUT NOCOPY  VARCHAR2 ) IS

    l_api_name    CONSTANT     VARCHAR2(30) := 'Compute_Activity_Estimate';
    l_api_version CONSTANT     NUMBER       := 1.0;

    l_msg_count                NUMBER := 0;
    l_msg_data                 VARCHAR2(8000) := '';

    l_effective_datetime       DATE   :=
                               fnd_date.canonical_to_date(p_effective_datetime);
    l_eam_item_type            NUMBER := 0;
    l_rates_ct                 NUMBER := 0;
    l_lot_size                 NUMBER := 0;
    l_round_unit               NUMBER := 0;
    l_precision                NUMBER := 0;
    l_ext_precision            NUMBER := 0;
    l_cost_group_id            NUMBER := 0;
    l_primary_cost_method      NUMBER := 0;
    l_maint_cost_category      NUMBER := 0;
    l_eam_cost_element         NUMBER := 0;
    l_return_status            VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_api_message              VARCHAR2(10000);
    l_stmt_num                 NUMBER;
    l_dept_id                  NUMBER := 0;
    l_dummy                    NUMBER := 0;
    l_asset_group_item_id      NUMBER := 0;
    l_asset_number             VARCHAR2(80) := '';
    l_department_id            NUMBER := 0;
    l_ActivityEstimateTable    ActivityEstimateTable := ActivityEstimateTable();

    CURSOR c_bor IS
      SELECT bos.operation_seq_num operation_seq_num,
             decode(br.functional_currency_flag,
                            1, 1,
                            NVL(crc.resource_rate,0))
                   * bomres.usage_rate_or_amount
                   * decode(bomres.basis_type,
                             1, l_lot_size,
                             2, 1,
                            1) raw_resource_value,


             ROUND(decode(br.functional_currency_flag,
                            1, 1,
                            NVL(crc.resource_rate,0))
                   * bomres.usage_rate_or_amount
                   * decode(bomres.basis_type,
                             1, l_lot_size,
                             2, 1,
                            1) ,l_ext_precision) resource_value,

             bomres.resource_id resource_id,
             bomres.resource_seq_num resource_seq_num,
             bomres.basis_type basis_type,
             bomres.usage_rate_or_amount
                   * decode(bomres.basis_type,
                             1, l_lot_size,
                             2, 1,
                            1) usage_rate_or_amount,
             bomres.standard_rate_flag standard_flag,
             bos.department_id department_id,
             br.functional_currency_flag functional_currency_flag,
             br.cost_element_id cost_element_id,
             br.resource_type resource_type
      FROM   bom_operational_routings bor,
             bom_operation_resources bomres,
             bom_operation_sequences bos,
             bom_resources br,
             cst_resource_costs crc
      WHERE
             bor.assembly_item_id = p_activity_item_id
      AND    bor.organization_id  = p_organization_id
      AND    bor.pending_from_ecn IS NULL
      AND    bor.routing_type = 1
      AND    (  NVL(bor.alternate_routing_designator, 'none')
                  =NVL(p_alt_rtg_designator, 'none')
              OR (
                      (p_alt_rtg_designator IS NOT NULL)
                  AND (bor.alternate_routing_designator IS NULL)
                  AND NOT EXISTS
                         (SELECT 'X'
                          FROM bom_operational_routings bor1
                          WHERE bor1.assembly_item_id = bor.assembly_item_id
                          AND   bor1.organization_id  = p_organization_id
                          AND   bor1.pending_from_ecn is NULL
                          AND   bor1.alternate_routing_designator =
                                p_alt_rtg_designator
                          AND   bor1.routing_type = 1
                         )
                   )
                 )
      AND    bos.implementation_date IS NOT NULL
      AND    bos.routing_sequence_id =
                               bor.common_routing_sequence_id

      AND    bos.effectivity_date <= l_effective_datetime
      AND    NVL( bos.disable_date, l_effective_datetime  + 1)
                   > l_effective_datetime

      AND    NVL( bos.eco_for_production, 2 ) = 2
      AND    bomres.operation_sequence_id     = bos.operation_sequence_id
      AND    NVL( bomres.acd_type, 1 )        <> 3
      AND    br.resource_id                   = bomres.resource_id
      AND    br.organization_id               = p_organization_id
      AND    br.allow_costs_flag              = 1
      AND    crc.resource_id                  = bomres.resource_id
      AND    crc.cost_type_id                 = l_rates_ct;

    CURSOR c_rbo (  p_resource_id   NUMBER,
                    p_dept_id       NUMBER,
                    p_org_id        NUMBER,
                    p_res_units     NUMBER,
                    p_res_value     NUMBER) IS

      SELECT  cdo.overhead_id ovhd_id,
             cdo.rate_or_amount actual_cost,
              cdo.basis_type basis_type,
              ROUND(cdo.rate_or_amount *
                        decode(cdo.basis_type,
                                3, p_res_units,
                                p_res_value), l_ext_precision) rbo_value,
              cdo.department_id
      FROM    cst_resource_overheads cro,
              cst_department_overheads cdo
      WHERE   cdo.department_id    = p_dept_id
      AND     cdo.organization_id  = p_org_id
      AND     cdo.cost_type_id     = l_rates_ct
      AND     cdo.basis_type IN (3,4)
      AND     cro.cost_type_id     = cdo.cost_type_id
      AND     cro.resource_id      = p_resource_id
      AND     cro.overhead_id      = cdo.overhead_id
      AND     cro.organization_id  = cdo.organization_id;


      CURSOR c_bbom IS
      SELECT bic.operation_seq_num operation_seq_num,
             bos.department_id department_id,
             ROUND (SUM(NVL(component_quantity,0) *
		DECODE(msi.stock_enabled_flag,
		 	 'N',decode(msi.eam_item_type,
				      3,decode(wep.issue_zero_cost_flag,
						 'Y', 0,
						 NVL(bic.unit_price,0)),
				      NVL(bic.unit_price,0)),
			 decode(msi.eam_item_type,
				  3,decode(wep.issue_zero_cost_flag,
					     'Y', 0,
					     NVL(ccicv.item_cost,0)),
                                  NVL(ccicv.item_cost,0))
		      )
		   ), l_ext_precision
		) mat_value
      FROM   bom_bill_of_materials bbom,
             bom_inventory_components bic,
             cst_cg_item_costs_view ccicv,
	     bom_operational_routings bor,
             bom_operation_sequences bos,
             mtl_system_items_b msi,
             wip_eam_parameters wep
      WHERE  bbom.organization_id = p_organization_id
      AND    bbom.assembly_item_id = p_activity_item_id
      AND    bbom.assembly_type = 1
      AND    (  (bbom.Alternate_bom_designator IS NULL
                 AND p_alt_bom_designator IS NULL)
              OR
                (p_alt_bom_designator IS NOT NULL
                 AND
                 bbom.alternate_bom_designator = p_alt_bom_designator)
              OR ((p_alt_bom_designator IS NOT NULL)
                   AND (bbom.alternate_bom_designator IS NULL)
                   AND NOT EXISTS
                     (SELECT 'X'
                      FROM bom_bill_of_materials bbom1
                      WHERE bbom1.assembly_item_id = bbom.assembly_item_id
                      AND   bbom1.organization_id = bbom.organization_id
                      AND   bbom1.alternate_bom_designator
                                       = p_alt_bom_designator)
                 )
             )
      AND    bor.organization_id = p_organization_id
      AND    bor.assembly_item_id = p_activity_item_id
      AND    bor.pending_from_ecn IS NULL
      AND    bor.routing_type = 1
      AND    (  NVL(bor.alternate_routing_designator, 'none')
                  =NVL(p_alt_rtg_designator, 'none')
              OR (
                      (p_alt_rtg_designator IS NOT NULL)
                  AND (bor.alternate_routing_designator IS NULL)
                  AND NOT EXISTS
                         (SELECT 'X'
                          FROM bom_operational_routings bor1
                          WHERE bor1.assembly_item_id = bor.assembly_item_id
                          AND   bor1.organization_id  = p_organization_id
                          AND   bor1.pending_from_ecn is NULL
                          AND   bor1.alternate_routing_designator =
                                p_alt_rtg_designator
                          AND   bor1.routing_type = 1
                         )
                   )
                 )
      AND    bos.implementation_date IS NOT NULL
      AND    bos.routing_sequence_id =
                               bor.common_routing_sequence_id

      AND    bos.effectivity_date <= l_effective_datetime
      AND    NVL( bos.disable_date, l_effective_datetime  + 1)
                   > l_effective_datetime
      AND    NVL( bos.eco_for_production, 2 ) = 2
      AND    bos.operation_seq_num = bic.operation_seq_num
      AND    bic.bill_sequence_id = bbom.common_bill_sequence_id
      AND    NVL(bic.acd_type,1) <> 3
      AND    NVL(bic.eco_for_production,2) = 2
      AND    bic.wip_supply_type IN (1,4)
      AND    (bic.effectivity_date  <=
                      fnd_date.canonical_to_date(p_effective_datetime))
      AND    NVL(bic.disable_date,
                        fnd_date.canonical_to_date(p_effective_datetime)+1) >
                        fnd_date.canonical_to_date(p_effective_datetime)
      AND    ccicv.inventory_item_id(+) = bic.component_item_id
      AND    ccicv.organization_id(+) = p_organization_id
      AND    ccicv.cost_group_id(+) = decode(l_primary_cost_method,1,1,
                                                l_cost_group_id)
      AND    msi.inventory_item_id = bic.component_item_id
      AND    msi.organization_id = p_organization_id
      AND    wep.organization_id = p_organization_id
      GROUP BY bic.operation_seq_num, bos.department_id;

BEGIN

    -------------------------------------------------------------------------
    -- standard start of API savepoint
    -------------------------------------------------------------------------
    SAVEPOINT Compute_Activity_Estimate;

    -------------------------------------------------------------------------
    -- standard call to check for call compatibility
    -------------------------------------------------------------------------
    l_stmt_num := 5;

    IF NOT fnd_api.compatible_api_call (
                              l_api_version,
                              p_api_version,
                              l_api_name,
                              G_PKG_NAME ) then

         RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    -------------------------------------------------------------------------
    -- Initialize message list if p_init_msg_list is set to TRUE
    -------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;


    -------------------------------------------------------------------------
    -- initialize api return status to success
    -------------------------------------------------------------------------
    x_return_status := fnd_api.g_ret_sts_success;

    -- assign to local variables

    -------------------------------------------------------------------------
    -- Check Item Type is Activity
    -------------------------------------------------------------------------

    l_stmt_num := 10;

    SELECT  NVL(eam_item_type,-1)
    INTO    l_eam_item_type
    FROM    mtl_system_items msi
    WHERE   msi.organization_id = p_organization_id
    AND     msi.inventory_item_id = p_activity_item_id;

    IF  l_eam_item_type <> 2  THEN

        l_api_message := 'The following Item is not of type Activity: '
                         ||TO_CHAR(p_activity_item_id);

        FND_MSG_PUB.ADD_EXC_MSG('CST_EAMJOB_ACTESTIMATE', 'COMPUTE_ACTIVITY_EST('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
        RAISE FND_API.g_exc_error;

    END IF;

    -------------------------------------------------------------------------
    -- Get the Org's default cost group
    -------------------------------------------------------------------------

    IF (p_cost_group_id IS NULL) THEN

      l_stmt_num := 15;

      SELECT NVL(default_cost_group_id,-1)
      INTO l_cost_group_id
      FROM mtl_parameters
      WHERE organization_id = p_organization_id;

    ELSE

      l_stmt_num := 20;

      l_cost_group_id := p_cost_group_id;

    END IF;

    -------------------------------------------------------------------------
    -- Derive the currency extended precision for the organization
    -------------------------------------------------------------------------
    l_stmt_num := 25;

    CSTPUTIL.CSTPUGCI(p_organization_id,
                      l_round_unit,
                      l_precision,
                      l_ext_precision);


    -------------------------------------------------------------------------
    -- Derive valuation rates cost type based on organization's cost method
    -------------------------------------------------------------------------

    l_stmt_num := 30;

    SELECT  decode (mp.primary_cost_method,
                      1, mp.primary_cost_method,
                      NVL(mp.avg_rates_cost_type_id,-1)),
            mp.primary_cost_method
    INTO    l_rates_ct,
            l_primary_cost_method
    FROM    mtl_parameters mp
    WHERE   mp.organization_id = p_organization_id;

    IF (l_rates_ct = -1) THEN
        l_api_message := 'Rates Type not defined for Org: '
                         ||TO_CHAR(p_organization_id);

        FND_MSG_PUB.ADD_EXC_MSG('CST_EAMJOB_ACTESTIMATE', 'COMPUTE_ACTIVITY_EST('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
        RAISE FND_API.g_exc_error;

    ELSE

        l_stmt_num := 35;

        BEGIN

        SELECT  lot_size
        INTO    l_lot_size
        FROM    cst_item_costs cic
        WHERE   cic.organization_id    = p_organization_id
        AND     cic.inventory_item_id  = p_activity_item_id
        AND     cic.cost_type_id       = l_rates_ct;

        EXCEPTION
        WHEN others then
          l_lot_size := 1;
        END;

    END IF;

    IF (p_debug = 'Y') THEN
      l_api_message := l_api_message||' Rates Ct: '||TO_CHAR(l_rates_ct);
      l_api_message := l_api_message||' Lot Size: '||TO_CHAR(l_lot_size);
      l_api_message := l_api_message||' Ext Precision: '
                                         ||TO_CHAR(l_ext_precision);
      l_api_message := l_api_message||' Activity Item Id: '
                                         ||TO_CHAR(p_activity_item_id);
      l_api_message := l_api_message||' Cg Id: '||TO_CHAR(l_cost_group_id);
      l_api_message := l_api_message||' Cost Method: '
                                         ||TO_CHAR(l_primary_cost_method);

      FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
      FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
      FND_MSG_PUB.add;


    END IF;

    -------------------------------------------------------------------------
    -- Compute Resource Costs (BOR)
    -------------------------------------------------------------------------
  l_stmt_num := 40;

    FOR c_bor_rec IN c_bor LOOP

      IF (p_debug = 'Y') THEN

        l_api_message :=' Op: ';
        l_api_message :=l_api_message||TO_CHAR(c_bor_rec.operation_seq_num);
        l_api_message :=l_api_message||' Department Id: ';
        l_api_message :=l_api_message||TO_CHAR(c_bor_rec.department_id);
        l_api_message :=l_api_message||' Resource Type: ';
        l_api_message :=l_api_message||TO_CHAR(c_bor_rec.resource_type);
        l_api_message :=l_api_message||' BOR,Value: '
                                     ||TO_CHAR(c_bor_rec.resource_value);

        FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
        FND_MSG_PUB.add;

      END IF;

      l_stmt_num := 45;

      Get_DeptCostCatg (
                          p_api_version        =>   1.0,
                          p_department_id      =>   c_bor_rec.department_id,

                          p_user_id            =>   p_user_id,
                          p_request_id         =>   p_request_id,
                          p_prog_id            =>   p_prog_id,
                          p_prog_app_id        =>   p_prog_app_id,
                          p_login_id           =>   p_login_id,

                          x_dept_cost_catg     =>  l_maint_cost_category,
                          x_return_status      =>  l_return_status,

                         x_msg_count          =>  l_msg_count,
                          x_msg_data           =>  l_msg_data );

      IF l_return_status <> FND_API.g_ret_sts_success THEN

          l_api_message := 'Get_DeptCostCatg returned error';
          FND_MSG_PUB.ADD_EXC_MSG('CST_EAMJOB_ACTESTIMATE', 'COMPUTE_Activty_Estimate('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;

      END IF;

      l_stmt_num := 50;

      l_eam_cost_element :=
                   Get_eamCostElement(p_txn_mode    => 2,
                                      p_org_id      => p_organization_id,
                                      p_resource_id => c_bor_rec.resource_id);

      IF l_eam_cost_element = 0 THEN

         l_api_message := 'Get_eamCostElement returned error';
         FND_MSG_PUB.ADD_EXC_MSG('CST_EAMJOB_ACTESTIMATE', 'COMPUTE_JOB_ESTIMATES('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
         RAISE FND_API.g_exc_error;

      END IF;

      IF (p_debug = 'Y') THEN

        l_api_message :=' MCC: ';
        l_api_message :=l_api_message||TO_CHAR(l_maint_cost_category);
        l_api_message :=l_api_message||' CE: '||TO_CHAR(l_eam_cost_element);
        FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);

        FND_MSG_PUB.add;

      END IF;

      l_stmt_num := 55;

      l_ActivityEstimateTable.EXTEND;
      l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).record_type := 1;
      l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).organization_id :=
                                           p_organization_id;
      l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).activity_item_id :=
                                           p_activity_item_id;
      l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).resource_id :=
                                           c_bor_rec.resource_id;
      l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).op_seq_num :=
                                           c_bor_rec.operation_seq_num;
      l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).maint_cost_catg :=
                                           l_maint_cost_category;
      l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).eam_cost_element :=
                                           l_eam_cost_element;
      l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).cost_value :=
                                           c_bor_rec.resource_value;

      -----------------------------------------------------------------------
      -- Compute Resource Based Overheads Costs (RBO)
      -----------------------------------------------------------------------

      l_stmt_num := 60;

      FOR c_rbo_rec IN c_rbo(c_bor_rec.resource_id,
                             c_bor_rec.department_id,
                             p_organization_id,
                             c_bor_rec.usage_rate_or_amount,
                             c_bor_rec.raw_resource_value)
      LOOP

        IF (p_debug = 'Y') THEN

          l_api_message :=' Op: ';
          l_api_message :=l_api_message||TO_CHAR(c_bor_rec.operation_seq_num);
          l_api_message :=l_api_message||' RBO,Value: '||TO_CHAR(c_rbo_rec.rbo_value);
          l_api_message :=l_api_message||' MCC: ';
          l_api_message :=l_api_message||TO_CHAR(l_maint_cost_category);
          l_api_message :=l_api_message||' CE: '||TO_CHAR(l_eam_cost_element);
          FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
          FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
          FND_MSG_PUB.add;

        END IF;

        l_stmt_num := 65;

        l_ActivityEstimateTable.EXTEND;
        l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).record_type := 2;
        l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).organization_id :=
                                           p_organization_id;
        l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).activity_item_id :=
                                           p_activity_item_id;
        l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).op_seq_num :=
                                           c_bor_rec.operation_seq_num;
        l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).resource_id :=
                                           c_bor_rec.resource_id;
        l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).overhead_id :=
                                           c_rbo_rec.ovhd_id;
        l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).maint_cost_catg :=
                                           l_maint_cost_category;
        l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).eam_cost_element:=
                                           l_eam_cost_element;
        l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).cost_value :=
                                           c_rbo_rec.rbo_value;

      END LOOP; -- c_rbo_rec

    END LOOP; --c_bor_rec

   -------------------------------------------------------------------------
    -- Compute Material Costs
    -------------------------------------------------------------------------

    l_stmt_num := 70;

    FOR c_bbom_rec IN c_bbom LOOP

      l_stmt_num := 75;

      IF (p_debug = 'Y') THEN

        l_api_message :=' Op: ';
        l_api_message :=l_api_message||TO_CHAR(c_bbom_rec.operation_seq_num);
        l_api_message :=l_api_message||' Department Id: ' ;
        l_api_message :=l_api_message||TO_CHAR(c_bbom_rec.department_id);
        l_api_message :=l_api_message||' WRO,Value: '
                                     ||TO_CHAR(c_bbom_rec.mat_value);
        FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
        FND_MSG_PUB.add;

      END IF;

      l_stmt_num := 80;

      Get_DeptCostCatg (
                          p_api_version        =>   1.0,
                          p_organization_id    =>   p_organization_id,
                          p_department_id      =>   c_bbom_rec.department_id,

                          p_user_id            =>   p_user_id,
                          p_request_id         =>   p_request_id,
                          p_prog_id            =>   p_prog_id,
                          p_prog_app_id        =>   p_prog_app_id,
                          p_login_id           =>   p_login_id,

                        x_dept_cost_catg     =>  l_maint_cost_category,
                          x_return_status      =>  l_return_status,
                          x_msg_count          =>  l_msg_count,
                          x_msg_data           =>  l_msg_data );

       IF l_return_status <> FND_API.g_ret_sts_success THEN

          l_api_message := 'Get_DeptCostCatg returned error';

          FND_MSG_PUB.ADD_EXC_MSG('CST_EAMJOAB_ACTESTIMATE', 'COMPUTE_ACTIVITY_EST('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;

       END IF;

      l_stmt_num := 85;

      l_eam_cost_element :=
                   Get_eamCostElement(p_txn_mode    => 1,
                                      p_org_id      => p_organization_id);

      IF l_eam_cost_element = 0 THEN

         l_api_message := 'Get_eamCostElement returned error';

         FND_MSG_PUB.ADD_EXC_MSG('CST_EAMJOB_ACTESTIMATE', 'COMPUTE_ACTIVITY_ESTIMATE('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
         RAISE FND_API.g_exc_error;

      END IF;

      IF (p_debug = 'Y') THEN

        l_api_message :=' MCC: ';

        l_api_message :=l_api_message||TO_CHAR(l_maint_cost_category);
        l_api_message :=l_api_message||' CE: '||TO_CHAR(l_eam_cost_element);
        FND_MESSAGE.SET_NAME ('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.SET_TOKEN ('TEXT', l_api_message);
        FND_MSG_PUB.add;

      END IF;

      l_stmt_num := 90;

      l_ActivityEstimateTable.EXTEND;
      l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).record_type := 3;
      l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).organization_id :=
                                         p_organization_id;
      l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).activity_item_id :=
                                           p_activity_item_id;
      l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).op_seq_num :=
                                         c_bbom_rec.operation_seq_num;
      l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).maint_cost_catg :=
                                         l_maint_cost_category;
      l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).eam_cost_element :=
                                         l_eam_cost_element;
      l_ActivityEstimateTable(l_ActivityEstimateTable.LAST).cost_value :=
                                         c_bbom_rec.mat_value;

    END LOOP;

    l_stmt_num := 95;

    x_ActivityEstimateTable := l_ActivityEstimateTable;

    ---------------------------------------------------------------------------
    -- Standard check of p_commit
    ---------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

    ---------------------------------------------------------------------------
    -- Standard Call to get message count and if count = 1, get message info
    ---------------------------------------------------------------------------

    FND_MSG_PUB.Count_And_Get (
        p_count     => x_msg_count,
        p_data      => x_msg_data );

 EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_EAMJOB_ACTESTIMATE'

              , 'Compute_Activity_Estimate: l_stmt_num - '||to_char(l_stmt_num)
              );

        END IF;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );

END Compute_Activity_Estimate;

--------------------------------------------------------------------------n
-- PROCEDURE                                                              --
--   Get_Activity_Estimate                                            --
--                                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API Computes the estimate for an asset activity                 --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.9                                        --
--                                                                        --
--                                                                        --

--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    08/07/02     Hemant G       Created                                 --
----------------------------------------------------------------------------
PROCEDURE Get_Activity_Estimate (
                            p_api_version           IN   NUMBER,
                            p_init_msg_list         IN   VARCHAR2
                                                      := FND_API.G_FALSE,
                            p_commit                IN   VARCHAR2
                                                      := FND_API.G_FALSE,
                            p_validation_level      IN   NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,
                            p_debug                 IN   VARCHAR2 := 'N',

                            p_activity_item_id      IN   NUMBER,
                            p_organization_id       IN   NUMBER,
                            p_alt_bom_designator    IN   VARCHAR2 := NULL,
                            p_alt_rtg_designator    IN   VARCHAR2 := NULL,
                            p_cost_group_id         IN   NUMBER   := NULL,
                            p_effective_datetime    IN   VARCHAR2 :=
                                                           fnd_date.date_to_canonical(SYSDATE),

                            p_user_id               IN   NUMBER,
                            p_request_id            IN   NUMBER,
                            p_prog_id               IN   NUMBER,
                            p_prog_app_id           IN   NUMBER,
                            p_login_id              IN   NUMBER,

                            x_activity_estimate_record_id    OUT NOCOPY  NUMBER,
                            x_return_status         OUT NOCOPY  VARCHAR2,
                            x_msg_count             OUT NOCOPY  NUMBER,
                            x_msg_data              OUT NOCOPY  VARCHAR2 ) IS

    l_api_name    CONSTANT     VARCHAR2(30) := 'Compute_Activity_Estimate';
    l_api_version CONSTANT     NUMBER       := 1.0;
    l_api_message              VARCHAR2(10000);
    l_return_status            VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_stmt_num                 NUMBER;
    l_msg_count                NUMBER := 0;
    l_msg_data                 VARCHAR2(8000) := '';

    l_activity_estimate_record_id NUMBER := -1;

    l_ActivityEstimateTable    ActivityEstimateTable := ActivityEstimateTable();

BEGIN

    -------------------------------------------------------------------------
    -- standard start of API savepoint
    -------------------------------------------------------------------------
    SAVEPOINT Compute_Activity_Estimate;

    -------------------------------------------------------------------------
    -- standard call to check for call compatibility
    -------------------------------------------------------------------------
    l_stmt_num := 5;

    IF NOT fnd_api.compatible_api_call (
                              l_api_version,
                              p_api_version,
                              l_api_name,
                              G_PKG_NAME ) then

         RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    -------------------------------------------------------------------------
    -- Initialize message list if p_init_msg_list is set to TRUE
    -------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;


    -------------------------------------------------------------------------
    -- initialize api return status to success
    -------------------------------------------------------------------------
    x_return_status := fnd_api.g_ret_sts_success;

    -- assign to local variables

    Compute_Activity_Estimate (
                            p_api_version           =>   1.0,

                            p_activity_item_id      =>   p_activity_item_id,
                            p_organization_id       =>   p_organization_id,
                            p_alt_bom_designator    =>   p_alt_bom_designator,
                            p_alt_rtg_designator    =>   p_alt_rtg_designator,
                            p_cost_group_id         =>   p_cost_group_id,
                            p_effective_datetime    =>   p_effective_datetime,

                            p_user_id               =>   p_user_id,
                            p_request_id            =>   p_request_id,
                            p_prog_id               =>   p_prog_id,
                            p_prog_app_id           =>   p_prog_app_id,
                            p_login_id              =>   p_login_id,

                            x_ActivityEstimateTable =>  l_ActivityEstimateTable,
                            x_return_status         =>  l_return_status,
                            x_msg_count             =>  l_msg_count,
                            x_msg_data              =>  l_msg_data ) ;

    IF (l_return_status <> FND_API.g_ret_sts_success) THEN

      l_api_message := 'Compute_Activity_Estimate returned error';

      FND_MSG_PUB.ADD_EXC_MSG('CST_EAMJOB_ACTESTIMATE', 'GET_ACTIVITY_EST('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
      RAISE FND_API.g_exc_error;

    END IF;

    IF l_ActivityEstimateTable.EXISTS(1) THEN

      SELECT  cst_eam_activity_estimates_s.nextval
      INTO    l_activity_estimate_record_id
      FROM    DUAL;


      FOR j IN l_ActivityEstimateTable.FIRST .. l_ActivityEstimateTable.LAST LOOP

         INSERT INTO cst_eam_activity_estimates (
              activity_estimate_record_id,
              record_type,
              organization_id,
              activity_item_id,
              eam_cost_element,
              maint_cost_category,
              cost_value)

         VALUES (
              l_activity_estimate_record_id,
              'D',
              l_ActivityEstimateTable(j).organization_id,
              l_ActivityEstimateTable(j).activity_item_id,
              l_ActivityEstimateTable(j).eam_cost_element,
              l_ActivityEstimateTable(j).maint_cost_catg,
              l_ActivityEstimateTable(j).cost_value
            );

       END LOOP;

         INSERT INTO cst_eam_activity_estimates (
              activity_estimate_record_id,
              record_type,
              organization_id,
              activity_item_id,
              eam_cost_element,
              maint_cost_category,
              cost_value)

          SELECT l_activity_estimate_record_id,
                 'S' record_type,
                 organization_id organization_id,
                 activity_item_id activity_item_id,
                 eam_cost_element eam_cost_element,
                 maint_cost_category maint_cost_category,
                 SUM(cost_value) cost_value
          FROM   cst_eam_activity_estimates caet
          GROUP  BY l_activity_estimate_record_id,
                 record_type,
                 organization_id,
                 activity_item_id,
                 eam_cost_element,
                 maint_cost_category;

    END IF;

    x_activity_estimate_record_id := l_activity_estimate_record_id;

    ---------------------------------------------------------------------------
    -- Standard check of p_commit
    ---------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

    ---------------------------------------------------------------------------
    -- Standard Call to get message count and if count = 1, get message info
    ---------------------------------------------------------------------------

    FND_MSG_PUB.Count_And_Get (
        p_count     => x_msg_count,
        p_data      => x_msg_data );


 EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_EAMJOB_ACTESTIMATE'

              , 'Get_Activity_Estimate: l_stmt_num - '||to_char(l_stmt_num)
              );

        END IF;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );


END Get_Activity_Estimate;


END CST_EAMJOB_ACTESTIMATE;


/

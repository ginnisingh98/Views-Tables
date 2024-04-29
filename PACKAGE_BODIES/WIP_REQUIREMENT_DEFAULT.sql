--------------------------------------------------------
--  DDL for Package Body WIP_REQUIREMENT_DEFAULT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_REQUIREMENT_DEFAULT" as
/* $Header: wiprqdfb.pls 120.7 2006/05/10 03:36:14 panagara noship $ */

Procedure Default_Requirement(
                p_group_id              in  number,
                p_wip_entity_id         in  number,
                p_organization_id       in  number,
                p_substitution_type     in  number,
                p_operation_seq_num     in  number,
                p_inventory_item_id_old in  number,
                p_inventory_item_id_new in  number,
                p_quantity_per_assembly in  number,
                -- p_required_quantity     in  number, /* LBM Project not required */
                p_basis_type            in  number, /* LBM Project */
                p_component_yield_factor in number,/*Component Yield Enhancement(Bug 4369064)*/
                p_err_code              out nocopy varchar2,
                p_err_msg               out nocopy varchar2) IS

        x_department_id           NUMBER;
        x_wip_supply_type         NUMBER;
        x_date_required           DATE;
        x_required_quantity       NUMBER;
        x_quantity_issued         NUMBER;
        x_supply_subinventory     VARCHAR2(10);
        x_supply_locator_id       NUMBER;
        x_mrp_net_flag            NUMBER;
        x_mps_required_quantity   NUMBER;
        x_mps_date_required       DATE;
	x_scheduled_start_date    DATE;  /* Fix for bug 4318495 */

        X_temp_wip_supply_type  number;
        X_start_quantity        number;
        X_job_type              number; /* standard 1, non-std: 3 */
        X_entity_type           number;

        /* Added for Bug#3080103 */
        X_comp_seq_id           number ;
        X_quantity_per_assembly number ;
        X_substitute_item_quantity number ;

        x_state_num     number := 0;

BEGIN

    IF (p_inventory_item_id_new IS NULL or p_inventory_item_id_new = p_inventory_item_id_old) THEN /*Component Yield Enhancement(Bug 4369064)*/
       RETURN;

    END IF;
         begin
        /* derive p_required_quantity,  p_MPS_required_quantity */
        SELECT start_quantity, scheduled_start_date
          INTO X_start_quantity, x_scheduled_start_date
          FROM WIP_DISCRETE_JOBS
         WHERE wip_entity_id = p_wip_entity_id
           AND organization_id = p_organization_id;

        x_state_num := x_state_num + 1;

        /* begin LBM Project */
        if( p_basis_type = WIP_CONSTANTS.LOT_BASED_MTL) then
            x_required_quantity := round(p_quantity_per_assembly, 6);
            x_MPS_required_quantity := x_required_quantity;
        else
            x_required_quantity :=
              round(p_quantity_per_assembly * X_start_quantity/nvl(p_component_yield_factor,1), 6);/*Component Yield Enhancement(Bug 4369064)*/
            x_MPS_required_quantity := x_required_quantity;

        end if;
        /* end LBM Project */

        /* Derive department_id, date_required and MPS_date_required */
        begin
         SELECT department_Id, first_unit_start_date, first_unit_start_date
           INTO x_department_id, x_date_required, x_MPS_date_required
           FROM WIP_OPERATIONS
          WHERE wip_entity_id = p_wip_entity_id
            AND organization_id = p_organization_id
            AND operation_seq_num = p_operation_seq_num;
        exception
         when no_data_found then
           x_department_id := null;
           x_date_required := x_scheduled_start_date;  /* Fix for bug 4318495 */
           x_MPS_date_required := x_scheduled_start_date;  /* Fix for bug 4318495 */
        end;

        x_state_num := x_state_num + 1;

        /* Derive supply info */
         SELECT wip_supply_type, wip_supply_subinventory, wip_supply_locator_id
           INTO  x_wip_supply_type, x_supply_subinventory, x_supply_locator_id
           FROM MTL_SYSTEM_ITEMS
          WHERE inventory_item_id = p_inventory_item_id_new
            AND organization_id = p_organization_id;

        /* fix for bug 5206375. While adding a pull component,
	   if supply subinv/locator is not present at item level,
	   copy from org parameters as they are mandatory */
	SELECT  wip_supply_type
	INTO    X_temp_wip_supply_type
	FROM    WIP_JOB_DTLS_INTERFACE
	WHERE   group_id = p_group_id
        AND     wip_entity_id = p_wip_entity_id
        AND     organization_id = p_organization_id
        AND     load_type = WIP_JOB_DETAILS.WIP_MTL_REQUIREMENT
        AND     substitution_type = p_substitution_type
        AND     operation_seq_num = p_operation_seq_num
        AND     inventory_item_id_new = p_inventory_item_id_new;

	if( (nvl(X_temp_wip_supply_type, x_wip_supply_type) = 2 or
	     nvl(X_temp_wip_supply_type, x_wip_supply_type) = 3) and
            x_supply_subinventory IS NULL) then
	   SELECT default_pull_supply_subinv, default_pull_supply_locator_id
	     INTO x_supply_subinventory, x_supply_locator_id
	     FROM WIP_PARAMETERS
	    WHERE organization_id = p_organization_id;
	end if;
	/* end of fix for bug 5206375 */

        x_state_num := x_state_num + 1;

        /* MRP_net_flag */
        select wdj.wip_supply_type, wdj.job_type, we.entity_type
        into   X_temp_wip_supply_type, X_job_type, X_entity_type
        from wip_entities we,
           wip_discrete_jobs wdj
        where  wdj.wip_entity_id = p_wip_entity_id
        and    wdj.organization_id = p_organization_id
        and wdj.wip_entity_id = we.wip_entity_id
        and wdj.organization_id = we.organization_id ;

        /* bug#2811687 */
        if (X_entity_type = wip_constants.eam) then
          x_wip_supply_type := wip_constants.push;
        end if;

        x_state_num := x_state_num + 1;

        x_mrp_net_flag := 1;  /* by default */

        IF (X_temp_wip_supply_type = 5) THEN   /* vendor */
           x_mrp_net_flag := 2;
        END IF;

        IF ((x_required_quantity < 0) AND (X_job_type = 1)) THEN
           x_mrp_net_flag := 2;
        END IF;

/* Fix for Bug#3430727 */
        X_quantity_per_assembly := p_quantity_per_assembly;
/* Fix for Bug#3080103 */
        if (p_inventory_item_id_new is not null and p_quantity_per_assembly is null ) then
           begin

            SELECT component_sequence_id
            into   X_comp_seq_id
            FROM   wip_requirement_operations
            WHERE  wip_entity_id            = p_wip_entity_id
            AND    organization_id          = p_organization_id
            AND    operation_seq_num        = p_operation_seq_num
            AND    inventory_item_id        = p_inventory_item_id_old;

            select substitute_item_quantity
            into   X_substitute_item_quantity
            from   bom_substitute_components
            where  substitute_component_id = p_inventory_item_id_new
            and    component_sequence_id = X_comp_seq_id
            and    acd_type is null ;

            X_quantity_per_assembly := X_substitute_item_quantity ;

           exception
               when others then
                p_err_msg := 'WIPRQDFB(' || x_state_num || '): ' || SQLERRM;
                p_err_code := SQLCODE;
           end ;

       end if ;

        UPDATE WIP_JOB_DTLS_INTERFACE
        SET     quantity_issued         = Decode(p_substitution_type,WIP_JOB_DETAILS.WIP_ADD,0,quantity_issued),
                quantity_per_assembly   = round(X_quantity_per_assembly, 6),
                department_id           = x_department_id,
                wip_supply_type         = nvl(wip_supply_type,x_wip_supply_type),
                date_required           = nvl(date_required,x_date_required),
                required_quantity       = nvl(required_quantity,x_required_quantity),
                supply_subinventory     = nvl(supply_subinventory,x_supply_subinventory),
/* Fix for bug 3138448. Added Decode to default supply locator id only when supply
   subinventory is null.
                supply_locator_id       = nvl(supply_locator_id,x_supply_locator_id),
*/
                supply_locator_id       = Decode(nvl(supply_subinventory,'@@@'),
                                                  '@@@',x_supply_locator_id,
                                                   supply_locator_id),
                mrp_net_flag            = nvl(mrp_net_flag,x_mrp_net_flag),
                mps_required_quantity   = nvl(required_quantity,x_mps_required_quantity), /*Bug 4369064 */
                mps_date_required       = nvl(mps_date_required,x_mps_date_required),
                component_yield_factor  = round(x_quantity_per_assembly * decode(p_basis_type,
                                                                                 wip_constants.lot_based_mtl,
                                                                                 1,
                                                                                 X_start_quantity) /
                                          nvl(required_quantity,x_required_quantity),6)
                             /*Component Yield Enhancement(Bug 4369064)->default component yield factor based on
                               required quantity and qpa */
        WHERE   group_id = p_group_id
        AND     wip_entity_id = p_wip_entity_id
        AND     organization_id = p_organization_id
        AND     load_type = WIP_JOB_DETAILS.WIP_MTL_REQUIREMENT
        AND     substitution_type = p_substitution_type
        AND     operation_seq_num = p_operation_seq_num
        AND     inventory_item_id_new = p_inventory_item_id_new;

        x_state_num := x_state_num + 1;

        exception
           when others then
              p_err_msg := 'WIPRQDFB(' || x_state_num || '): ' || SQLERRM;
              p_err_code := SQLCODE;
        end;

END Default_Requirement;

END WIP_REQUIREMENT_DEFAULT;

/

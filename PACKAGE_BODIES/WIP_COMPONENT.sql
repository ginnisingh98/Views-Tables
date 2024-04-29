--------------------------------------------------------
--  DDL for Package Body WIP_COMPONENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_COMPONENT" as
/* $Header: wipfnmtb.pls 120.2 2005/06/17 13:07:49 appldev  $ */

/* Returns 1 if a component should be picked up in
   populate temp based on the action, supply type, and quantities required
   and issued.
   Otherwise returns 2
*/
FUNCTION IS_VALID
(p_transaction_action_id NUMBER,
 p_wip_supply_type NUMBER,
 p_required_quantity NUMBER,
 p_quantity_issued NUMBER,
 p_assembly_quantity NUMBER,
 p_entity_type NUMBER) RETURN NUMBER IS
BEGIN

    -- Apply to discrete and repetitive

    -- No negative components for issue or replenish sub
    IF p_transaction_action_id IN (1,2)
       AND p_required_quantity <= 0 THEN
	    return(2);
    END IF;

    -- No positive components for negative issue, neg return
    IF p_transaction_action_id in (33,34)
       AND p_required_quantity >= 0 THEN
	    return(2);
    END IF;

    -- Only return positive components
    -- We allow if it = 0 so you can return components added on
    -- the fly.
    IF p_transaction_action_id = 27
      AND p_required_quantity < 0 THEN
	    return(2);
    END IF;

    -- For sub transfers, looking for pull components
    IF p_wip_supply_type NOT IN (2,3)
       AND p_transaction_action_id = 2 THEN
	    return(2);
    END IF;

    -- For everything else looking for push components
    IF p_wip_supply_type <> 1
       AND p_transaction_action_id <> 2 THEN
	    return(2);
    END IF;

    -- Discrete and lot based Only
    /* Fix for bug 3115507: The following checks are to be applied for
       EAM work orders also. */

    IF p_entity_type in (1,5,6) THEN
	-- Don't allow overissue for components
	IF p_transaction_action_id = 1 AND p_assembly_quantity IS NULL
	   AND p_required_quantity <= p_quantity_issued THEN
		return(2);
	END IF;

	-- Don't allow overissue for negative components
	IF p_transaction_action_id = 33 AND p_assembly_quantity IS NULL
	   AND p_required_quantity >= p_quantity_issued THEN
		return(2);
	END IF;

	-- Only return components that were issued
	IF p_transaction_action_id = 27
	  AND p_quantity_issued <= 0 THEN
		return(2);
	END IF;

	-- Only return negative components that were issued
	-- Only return negative components that were issued
	IF p_transaction_action_id = 34
	  AND p_quantity_issued >= 0 THEN
		return(2);
        END IF;

   END IF;

   return(1);

END IS_VALID;

FUNCTION MEETS_CRITERIA
(req_op_seq NUMBER,
 crit_op_seq NUMBER,
 req_dept_id NUMBER,
 crit_dept_id NUMBER,
 req_sub VARCHAR2,
 crit_sub VARCHAR2) RETURN NUMBER IS
BEGIN
	IF crit_op_seq IS NOT NULL AND
	   req_op_seq <> crit_op_seq THEN
		return(2);

	ELSIF crit_dept_id IS NOT NULL AND
	   nvl(req_dept_id, -1) <> crit_dept_id THEN
		return(2);

	ELSIF crit_sub IS NOT NULL AND
	   nvl(req_sub, '@@@@') <> crit_sub THEN
		return(2);

	END IF;

	return(1);

END MEETS_CRITERIA;

/* ER 4369064: Component Yield Enhancement */
/* Added two new paramters include_yield and component_yield_factor. These will
   be used to compute transaction quantity based on yield consideration */
FUNCTION Determine_Txn_Quantity
                (transaction_action_id IN NUMBER,
                 qty_per_assembly IN NUMBER,
                 required_qty IN NUMBER,
                 qty_issued IN NUMBER,
                 assembly_qty IN NUMBER,
                 include_yield IN NUMBER,
                 component_yield_factor IN NUMBER,
                 basis_type IN NUMBER DEFAULT NULL ) RETURN NUMBER IS   /* LBM Project */
    l_effective_yield NUMBER; /* ER 4369064 */
    l_remove_yield_effect NUMBER;
BEGIN

        if (include_yield = 2) then
           /* This means that the paramter is set such that yield is NOT considered for
              transaction. Then, setting effective_yield to 1 for calculating
              quantity to be transacted. When calculation is based on required_quantity,
              we use remove_yield_effect because required_quantity already includes yield */
           l_remove_yield_effect := component_yield_factor;
           l_effective_yield := 1;
        else
           /* Do not strip the required quantity off its yield factor and when
              calculating transaction quantity based on QPA, include yield */
           l_remove_yield_effect := 1;
           l_effective_yield := component_yield_factor;
        end if;

        IF transaction_action_id in (   1,
                                        2,
                                        33) THEN
                IF assembly_qty IS NOT NULL THEN
                   if basis_type = WIP_CONSTANTS.LOT_BASED_MTL then  /* LBM Project */
                        return (-1 * qty_per_assembly / l_effective_yield);
                   else
                        return(-1 * qty_per_assembly * assembly_qty / l_effective_yield);
                   end if;
                ELSIF transaction_action_id = 33 THEN
                        return(GREATEST(qty_issued - required_qty * l_remove_yield_effect,0));
                ELSE
                        return(LEAST(qty_issued - required_qty * l_remove_yield_effect,0));
                END IF;

        ELSIF assembly_qty IS NOT NULL THEN
                IF transaction_action_id = 34 THEN
                        return(GREATEST(LEAST(qty_issued,0),
                                (qty_per_assembly * assembly_qty / l_effective_yield)));
                ELSE
                        return(LEAST(GREATEST(qty_issued,0),
                                (qty_per_assembly * assembly_qty / l_effective_yield)));
                END IF;
        ELSIF transaction_action_id = 34 THEN
                return(LEAST(qty_issued,0));
        ELSE
                return(GREATEST(qty_issued,0));
        END IF;

END Determine_Txn_Quantity;

FUNCTION Valid_Subinventory
                (p_subinventory IN VARCHAR2,
                 p_item_id IN NUMBER,
                 p_org_id IN NUMBER) RETURN VARCHAR2 IS
valid_flag VARCHAR2(2) := 'Y';
BEGIN

	IF p_subinventory IS NULL THEN
		valid_flag := 'N';
	END IF;

        -- If restricted sub, non-asset item, must be in MTL_ITEM_SUB_VAL_V

	SELECT decode(count(*),0,valid_flag,'N')
	INTO VALID_FLAG
	FROM DUAL
	WHERE
	(EXISTS
		 (SELECT 1
		  FROM MTL_SYSTEM_ITEMS MSI
		  WHERE MSI.INVENTORY_ITEM_ID = p_item_id
		  AND   MSI.ORGANIZATION_ID = p_org_id
		  AND   MSI.RESTRICT_SUBINVENTORIES_CODE = 1
		  AND   MSI.INVENTORY_ASSET_FLAG = 'N')
	       AND NOT EXISTS
		  (SELECT 1
		   FROM  MTL_ITEM_SUB_VAL_V MSVV
		   WHERE MSVV.ORGANIZATION_ID = p_org_id
		   AND   MSVV.INVENTORY_ITEM_ID = p_item_id
		   AND   MSVV.SECONDARY_INVENTORY_NAME = p_subinventory));

        -- If restricted sub, asset item, must be in MTL_ITEM_AST_TRK_SUB_VAL_V

	SELECT decode(count(*),0,valid_flag,'N')
        INTO VALID_FLAG
	FROM DUAL
        WHERE
	(EXISTS
		 (SELECT 1
		  FROM MTL_SYSTEM_ITEMS MSI
		  WHERE MSI.INVENTORY_ITEM_ID = p_item_id
		  AND   MSI.ORGANIZATION_ID = p_org_id
		  AND   MSI.RESTRICT_SUBINVENTORIES_CODE = 1
		  AND   MSI.INVENTORY_ASSET_FLAG = 'Y')
	       AND NOT EXISTS
		  (SELECT 1
		   FROM  MTL_ITEM_SUB_AST_TRK_VAL_V MSVV
		   WHERE MSVV.ORGANIZATION_ID = p_org_id
		   AND   MSVV.INVENTORY_ITEM_ID = p_item_id
                   AND   MSVV.SECONDARY_INVENTORY_NAME = p_subinventory));

	-- Test non-restricted items

	SELECT decode(count(*),0,valid_flag,'N')
        INTO VALID_FLAG
	FROM DUAL
        WHERE
	NOT EXISTS
		  (SELECT 1
		   FROM  MTL_SUBINVENTORIES_VAL_V MSVV,
			 MTL_SYSTEM_ITEMS MSI
		   WHERE MSVV.ORGANIZATION_ID = p_org_id
		   AND   MSVV.SECONDARY_INVENTORY_NAME = p_subinventory
		   AND   MSI.INVENTORY_ITEM_ID = p_item_id
		   AND   MSI.ORGANIZATION_ID = p_org_id
		   AND   MSI.INVENTORY_ASSET_FLAG = 'N'
		   UNION
		   SELECT 1
		   FROM  MTL_SUB_AST_TRK_VAL_V MSVV,
			 MTL_SYSTEM_ITEMS MSI
		   WHERE MSVV.ORGANIZATION_ID = p_org_id
		   AND   MSVV.SECONDARY_INVENTORY_NAME = p_subinventory
		   AND   MSI.INVENTORY_ITEM_ID = p_item_id
		   AND   MSI.ORGANIZATION_ID = p_org_id
		   AND   MSI.INVENTORY_ASSET_FLAG = 'Y');

	return(VALID_FLAG);

END Valid_Subinventory;

FUNCTION Valid_Locator
                (p_locator_id IN OUT NOCOPY NUMBER,
                 p_item_id IN NUMBER,
                 p_org_id IN NUMBER,
		 p_org_control IN NUMBER,
		 p_sub_control IN NUMBER,
		 p_item_control IN NUMBER,
		 p_restrict_locators_code IN NUMBER,
		 p_loc_disable_date IN DATE,
		 p_locator_control OUT NOCOPY NUMBER) RETURN VARCHAR2 IS
valid_flag VARCHAR2(2) := 'Y';
x_locator_control NUMBER;
BEGIN

	x_locator_control := QLTINVCB.Control
				(p_org_control,
				 p_sub_control,
				 p_item_control);
	p_locator_control := x_locator_control;

	IF p_locator_id IS NOT NULL AND x_locator_control = 1 THEN
		p_locator_id := NULL;
		return('Y');
	END IF;

	IF p_locator_id IS NULL THEN
		IF x_locator_control <> 1 THEN
			return('N');
		ELSE
			return('Y');
		END IF;
	END IF;

	IF nvl(p_loc_disable_date, SYSDATE+1) < SYSDATE THEN
		return('N');
	END IF;

	IF p_restrict_locators_code = 1 THEN
		SELECT decode(count(*),0,valid_flag,'N') INTO valid_flag
		FROM DUAL
		WHERE NOT EXISTS
		(SELECT 1
		 FROM   MTL_SECONDARY_LOCATORS msl
		 WHERE  msl.inventory_item_id = p_item_id
		 AND	msl.secondary_locator = p_locator_id
		 AND    msl.organization_id = p_org_id);
	END IF;

	return(valid_flag);

END Valid_Locator;

END WIP_COMPONENT;

/

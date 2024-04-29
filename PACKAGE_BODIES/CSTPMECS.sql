--------------------------------------------------------
--  DDL for Package Body CSTPMECS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPMECS" AS
/* $Header: CSTMECSB.pls 120.6.12010000.3 2010/04/25 21:18:31 smsasidh ship $ */

PROCEDURE CSTPALAR (

    I_LIST_ID                   IN      NUMBER,
    I_ORG_ID                    IN      NUMBER,
    I_ACTIVITY_ID               IN      NUMBER,
    I_FROM_DATE                 IN      DATE,
    I_TO_DATE                   IN      DATE,
    I_ACCOUNT_ID                IN      NUMBER,
    I_BASIS_TYPE                IN      NUMBER,
    I_FIXED_RATE                IN      NUMBER,
    I_PER_INC                   IN      NUMBER,
    I_AMT_INC                   IN      NUMBER,
    I_COST_TYPE_ID              IN      NUMBER,
    I_COPY_COST_TYPE            IN      NUMBER,
    I_RESOURCE_ID               IN      NUMBER,

    I_USER_ID                   IN      NUMBER,
    I_REQUEST_ID                IN      NUMBER,
    I_PROGRAM_ID                IN      NUMBER,
    I_PROGRAM_APPL_ID           IN      NUMBER,
    O_RETURN_CODE               OUT NOCOPY     NUMBER) IS

   ROUND_UNIT   NUMBER;
   PRECISION    NUMBER;
   EXT_PREC     NUMBER;

BEGIN

   O_RETURN_CODE := 9999;

   CSTPUTIL.CSTPUGCI(I_ORG_ID, ROUND_UNIT, PRECISION, EXT_PREC);

   UPDATE cst_item_cost_details CICD
   SET  (
        usage_rate_or_amount,
        item_cost,
        last_update_date,
        last_updated_by,
        request_id,
        program_application_id,
        program_id,
        program_update_date
        ) = (
        SELECT  unit_cost,
                ROUND((unit_cost * CICD.basis_factor *
                      CICD.net_yield_or_shrinkage_factor), EXT_PREC),
                SYSDATE,
                I_USER_ID,
                I_REQUEST_ID,
                I_PROGRAM_ID,
                I_PROGRAM_APPL_ID,
                SYSDATE
        FROM    cst_activity_costs
        WHERE   activity_id = CICD.activity_id
        AND     organization_id = CICD.organization_id
        AND     cost_type_id = CICD.cost_type_id
        )
   WHERE organization_id = I_ORG_ID
   AND   cost_type_id = I_COST_TYPE_ID
   AND   activity_id = DECODE(I_ACTIVITY_ID, 0, activity_id, I_ACTIVITY_ID)
   AND   cost_element_id = 2     /* Material Overhead */
   AND   basis_type = 6          /* Activity Units */
   AND   level_type = 1          /* This Level */
   AND   rollup_source_type = 1  /* User Defined */
   AND EXISTS
        (
        SELECT  'x'
        FROM    cst_lists CL,
                cst_activity_costs CAC
        WHERE   CL.list_id = I_LIST_ID
        AND     CL.entity_id = CICD.inventory_item_id
        AND     CAC.organization_id = CICD.organization_id
        AND     CAC.cost_type_id = CICD.cost_type_id
        AND     CAC.activity_id = CICD.activity_id
        AND     CAC.unit_cost IS NOT NULL
	)
   ;

   O_RETURN_CODE := 0;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        O_RETURN_CODE := SQLCODE;
   WHEN OTHERS THEN
        O_RETURN_CODE := SQLCODE;
        raise_application_error(-20001, SQLERRM);

END CSTPALAR;


PROCEDURE CSTPAPOR (

    I_LIST_ID                   IN        NUMBER,
    I_ORG_ID                    IN        NUMBER,
    I_ACTIVITY_ID               IN        NUMBER,
    I_FROM_DATE                 IN        DATE,
    I_TO_DATE                   IN        DATE,
    I_ACCOUNT_ID                IN        NUMBER,
    I_BASIS_TYPE                IN        NUMBER,
    I_FIXED_RATE                IN        NUMBER,
    I_PER_INC                   IN        NUMBER,
    I_AMT_INC                   IN        NUMBER,
    I_COST_TYPE_ID              IN        NUMBER,
    I_COPY_COST_TYPE            IN        NUMBER,
    I_RESOURCE_ID               IN        NUMBER,

    I_USER_ID                   IN        NUMBER,
    I_REQUEST_ID                IN        NUMBER,
    I_PROGRAM_ID                IN        NUMBER,
    I_PROGRAM_APPL_ID           IN        NUMBER,
    O_RETURN_CODE               IN OUT NOCOPY    NUMBER) IS

    ROUND_UNIT   NUMBER;
    PRECISION    NUMBER;
    EXT_PREC     NUMBER;

BEGIN

    O_RETURN_CODE := 9999;

    CSTPUTIL.CSTPUGCI(I_ORG_ID, ROUND_UNIT, PRECISION, EXT_PREC);

    /*===============================================================*/
    /*  Removed any item from the list where there is no PO receipt  */
    /*===============================================================*/
    DELETE FROM cst_lists L
    WHERE L.list_id = I_LIST_ID
    AND NOT EXISTS (
         SELECT /*+ NO_UNNEST */ 'X'
         FROM   mtl_material_transactions M
         ,      mtl_parameters MP
         WHERE  MP.cost_organization_id         = I_ORG_ID
         AND    M.organization_id               = MP.organization_id
         AND    M.inventory_item_id             = L.ENTITY_ID
         AND    (
                  (   M.transaction_source_type_id  = 1
                  AND M.transaction_action_id       = 27
                  AND M.transaction_type_id         = 18
                  )
                  OR
                  (   M.transaction_source_type_id  = 1
                  AND M.transaction_action_id       = 6
                  AND M.transaction_type_id         = 74
                  )
                  OR
                  (   M.transaction_source_type_id = 13
                  AND M.transaction_action_id      = 6
                  AND M.transaction_type_id        = 75
                  )
                )
         AND    M.owning_tp_type                = 2
         AND    M.transaction_date  BETWEEN NVL(I_FROM_DATE, M.transaction_date-1) AND NVL(I_TO_DATE, M.transaction_date+1)
         AND    M.costed_flag IS NULL
        );

    /*==================================================================*/
    /*  insert item cost where there is PO receipt but no pending cost  */
    /*  information                                                     */
    /*==================================================================*/
    CSTPUMEC.CSTPEIIC(I_ORG_ID,
                      I_COST_TYPE_ID,
                      I_LIST_ID,
                      I_RESOURCE_ID,
                      I_USER_ID,
                      I_REQUEST_ID,
                      I_PROGRAM_ID,
                      I_PROGRAM_APPL_ID,
                      O_RETURN_CODE);

    IF O_RETURN_CODE <> 0 THEN
        raise_application_error(-20001, 'CSTPAPOR->CSTPEIIC: '||SQLERRM);
    END IF;

    UPDATE cst_item_cost_details CICD
    SET (
        usage_rate_or_amount
    ,   item_cost
    ,   last_update_date
    ,   last_updated_by
    ,   request_id
    ,   program_application_id
    ,   program_id
    ,   program_update_date
    ) = (
        SELECT /*+ NO_UNNEST */
              ((SUM(MMT.primary_quantity * NVL(MMT.transaction_cost,0) ) *
                        (1 + I_PER_INC/100)) /
                        SUM(MMT.primary_quantity)) + I_AMT_INC
        ,       ROUND(((((SUM(MMT.primary_quantity * nvl(MMT.transaction_cost,0) ) *
                               (1 + I_PER_INC/100)) /
                               SUM(MMT.primary_quantity)) + I_AMT_INC) *
                        NVL(CICD.basis_factor,0) *
                        NVL(CICD.net_yield_or_shrinkage_factor,0) *
                        NVL(CICD.resource_rate,1)
                ), EXT_PREC)
        ,       SYSDATE
        ,       I_USER_ID
        ,       I_REQUEST_ID
        ,       I_PROGRAM_APPL_ID
        ,       I_PROGRAM_ID
        ,       SYSDATE
        FROM    mtl_material_transactions MMT
        ,       mtl_parameters MP
        WHERE   MP.cost_organization_id        = I_ORG_ID
        AND     MMT.organization_id            = MP.organization_id
        AND     MMT.OWNING_TP_TYPE             = 2
        AND     MMT.inventory_item_id          = CICD.inventory_item_id
         AND    (
                  (   MMT.transaction_source_type_id  = 1
                  AND MMT.transaction_action_id       = 27
                  AND MMT.transaction_type_id         = 18
                  )
                  OR
                  (   MMT.transaction_source_type_id  = 1
                  AND MMT.transaction_action_id       = 6
                  AND MMT.transaction_type_id         = 74
                  )
                  OR
                  (   MMT.transaction_source_type_id = 13
                  AND MMT.transaction_action_id      = 6
                  AND MMT.transaction_type_id        = 75
                  )
                )
        AND     MMT.transaction_date BETWEEN NVL(I_FROM_DATE, MMT.transaction_date-1) AND NVL(I_TO_DATE, MMT.transaction_date+1)
        AND     MMT.costed_flag IS NULL
        )
    WHERE organization_id   = I_ORG_ID
    AND cost_type_id        = I_COST_TYPE_ID
    AND level_type          = 1
    AND cost_element_id     = 1
    AND resource_id         = I_RESOURCE_ID
    AND NVL(activity_id,-1) = DECODE(I_ACTIVITY_ID,
                                     0, NVL(activity_id,-1),
                                     I_ACTIVITY_ID)
    AND NVL(basis_type,-1)  = DECODE(I_BASIS_TYPE,
                                     0, NVL(basis_type,-1),
                                     I_BASIS_TYPE)
    AND rollup_source_type  = 1  /* User Defined */
    AND EXISTS
        (
         SELECT  'X'
         FROM    cst_lists L
         WHERE   L.list_id = I_LIST_ID
         AND     L.entity_id = CICD.inventory_item_id
        )
    ;
    O_RETURN_CODE := 0;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        O_RETURN_CODE := SQLCODE;
    WHEN OTHERS THEN
        O_RETURN_CODE := SQLCODE;
        raise_application_error(-20001, 'CSTPAPOR: '||SQLERRM);

END CSTPAPOR;

PROCEDURE CSTPAWAC (

    I_LIST_ID                   IN        NUMBER,
    I_ORG_ID                    IN        NUMBER,
    I_ACTIVITY_ID               IN        NUMBER,
    I_FROM_DATE                 IN        DATE,
    I_TO_DATE                   IN        DATE,
    I_ACCOUNT_ID                IN        NUMBER,
    I_BASIS_TYPE                IN        NUMBER,
    I_FIXED_RATE                IN        NUMBER,
    I_PER_INC                   IN        NUMBER,
    I_AMT_INC                   IN        NUMBER,
    I_COST_TYPE_ID              IN        NUMBER,
    I_COPY_COST_TYPE            IN        NUMBER,
    I_RESOURCE_ID               IN        NUMBER,

    I_USER_ID                   IN        NUMBER,
    I_REQUEST_ID                IN        NUMBER,
    I_PROGRAM_ID                IN        NUMBER,
    I_PROGRAM_APPL_ID           IN        NUMBER,
    O_RETURN_CODE               IN OUT NOCOPY    NUMBER) IS

    ROUND_UNIT   NUMBER;
    PRECISION    NUMBER;
    EXT_PREC     NUMBER;

BEGIN

    O_RETURN_CODE := 9999;

    CSTPUTIL.CSTPUGCI(I_ORG_ID, ROUND_UNIT, PRECISION, EXT_PREC);

    /*===============================================================*/
    /*  Removed any item from the list where there is no PO receipt  */
    /*===============================================================*/
    DELETE FROM cst_lists L
    WHERE L.list_id = I_LIST_ID
    AND NOT EXISTS (
	 SELECT 'X'
	 FROM   mtl_material_transactions M
	 ,      mtl_parameters MP
	 WHERE  MP.cost_organization_id         = I_ORG_ID
	 AND    M.organization_id               = MP.organization_id
	 AND    M.inventory_item_id             = L.ENTITY_ID
         AND    M.transaction_source_type_id    = 1
         AND    M.transaction_action_id         = 27
         AND    M.transaction_type_id           = 18
         AND    (i_from_date IS NULL OR
                (i_from_date IS NOT NULL AND m.transaction_date > i_from_date ))
         AND    (i_to_date IS NULL OR
                (i_to_date IS NOT NULL AND m.transaction_date < i_to_date ))
	 AND    M.costed_flag = 'N'
	)
    ;

    /*==================================================================*/
    /*  insert item cost where there is PO receipt but no pending cost  */
    /*  information                                                     */
    /*==================================================================*/
    CSTPUMEC.CSTPEIIC(I_ORG_ID,
		      I_COST_TYPE_ID,
		      I_LIST_ID,
		      I_RESOURCE_ID,
		      I_USER_ID,
		      I_REQUEST_ID,
		      I_PROGRAM_ID,
		      I_PROGRAM_APPL_ID,
		      O_RETURN_CODE);

    IF O_RETURN_CODE <> 0 THEN
	raise_application_error(-20001, 'CSTPAWAC->CSTPEIIC: '||SQLERRM);
    END IF;









    /*==================================================================*/
    /*  update item cost details                                        */
    /*==================================================================*/
    UPDATE cst_item_cost_details CICD
    SET
    (
	item_cost
    ,   usage_rate_or_amount
    ,   last_update_date
    ,   last_updated_by
    ,   request_id
    ,   program_application_id
    ,   program_id
    ,   program_update_date
    )
    =
    (                   	/* item_cost calculation */
        SELECT			/* applied daily received value */
		(((
		  SUM (
		      DECODE (MMT.costed_flag,NULL,0,MMT.primary_quantity)
		      * MMT.actual_cost
		      )
		  * (1 + I_PER_INC/100)
		  )
		 + 		/* previous day on-hand value */
		  ((
		   SUM (MOH.transaction_quantity)
		   - SUM (
			 DECODE (MMT.costed_flag,NULL,0,MMT.primary_quantity)
   			 )
		   )
		  * CICD.item_cost
		  )
		 )
	        / (SUM (MOH.transaction_quantity) + I_AMT_INC)
	        )
    	,       ROUND                       /* usage_rate_or_amount calcul. */
                 (((((
	    	     SUM (
                         DECODE (MMT.costed_flag,NULL,0,MMT.primary_quantity)
		         * MMT.actual_cost
			 )
		     * (1 + I_PER_INC/100)
		     )
		    +
		     ((
		      SUM (MOH.transaction_quantity)
		      - SUM (
			    DECODE (MMT.costed_flag,NULL,0,MMT.primary_quantity)
			    )
   		      )
		     * CICD.item_cost
		    )
		   )
 		  / (SUM (MOH.transaction_quantity)
	       	   + I_AMT_INC
	           )
		  )
	         / (NVL (CICD.basis_factor,0)
		  * NVL (CICD.net_yield_or_shrinkage_factor,0)
		  * NVL (CICD.resource_rate,1)
	          )
		 )
	        , EXT_PREC
	        )
	,      SYSDATE
    	,      I_USER_ID
    	,      I_REQUEST_ID
    	,      I_PROGRAM_APPL_ID
    	,      I_PROGRAM_ID
    	,      SYSDATE

	FROM                               /* Select and Round FROM clause */
	      mtl_parameters            MP
	,     mtl_secondary_inventories MSI
        ,     mtl_onhand_quantities     MOH
	,     mtl_material_transactions MMT

	WHERE                              /* Select and Round WHERE clause */
	      MP.cost_organization_id        = I_ORG_ID

	AND   MSI.organization_id            = MP.organization_id
	AND   MSI.asset_inventory	     = 1

	AND   MOH.organization_id            = MSI.organization_id
        AND   MOH.subinventory_code          = MSI.secondary_inventory_name
        AND   MOH.inventory_item_id          = CICD.inventory_item_id

	AND   MMT.transaction_id             = MOH.create_transaction_id
	AND   MMT.transaction_type_id        = 18
	AND   MMT.transaction_source_type_id = 1
	AND   MMT.transaction_date           BETWEEN
	      NVL(I_FROM_DATE, MMT.transaction_date-1)
	      AND
	      NVL(I_TO_DATE, MMT.transaction_date+1)

    )                                      /* End of SET */

    WHERE                                  /* Update WHERE clause */
	  organization_id     = I_ORG_ID
    AND   cost_type_id        = I_COST_TYPE_ID
    AND   level_type          = 1
    AND   cost_element_id     = 1
    AND   resource_id         = I_RESOURCE_ID
    AND   NVL(activity_id,-1) = DECODE(I_ACTIVITY_ID,
				       0, NVL(activity_id,-1),
				       I_ACTIVITY_ID)
    AND   NVL(basis_type,-1)  = DECODE(I_BASIS_TYPE,
				       0, NVL(basis_type,-1),
				       I_BASIS_TYPE)
    AND   rollup_source_type  = 1          /* User Defined */

    AND   EXISTS
	    (
	    SELECT  'X'
	    FROM   cst_lists L
	    WHERE L.list_id   = I_LIST_ID
	    AND   L.entity_id = CICD.inventory_item_id
	    )
    ;

    O_RETURN_CODE := 0;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	O_RETURN_CODE := SQLCODE;
    WHEN OTHERS THEN
	O_RETURN_CODE := SQLCODE;
	raise_application_error(-20001, 'CSTPAWAC: '||SQLERRM);

END CSTPAWAC;

PROCEDURE CSTPOPOA (

    I_LIST_ID                   IN      NUMBER,
    I_ORG_ID                    IN      NUMBER,
    I_ACTIVITY_ID               IN      NUMBER,
    I_FROM_DATE                 IN      DATE,
    I_TO_DATE                   IN      DATE,
    I_ACCOUNT_ID                IN      NUMBER,
    I_BASIS_TYPE                IN      NUMBER,
    I_FIXED_RATE                IN      NUMBER,
    I_PER_INC                   IN      NUMBER,
    I_AMT_INC                   IN      NUMBER,
    I_COST_TYPE_ID              IN      NUMBER,
    I_COPY_COST_TYPE            IN      NUMBER,
    I_RESOURCE_ID               IN      NUMBER,

    I_USER_ID                   IN      NUMBER,
    I_REQUEST_ID                IN      NUMBER,
    I_PROGRAM_ID                IN      NUMBER,
    I_PROGRAM_APPL_ID           IN      NUMBER,
    O_RETURN_CODE               IN OUT NOCOPY  NUMBER) IS

   ROUND_UNIT      NUMBER;
   PRECISION       NUMBER;
   EXT_PREC        NUMBER;

BEGIN

   O_RETURN_CODE := 9999;

   CSTPUTIL.CSTPUGCI(I_ORG_ID, ROUND_UNIT, PRECISION, EXT_PREC);

   /*=============================================================================*/
   /* Populate the global temporary table cst_open_pos_temp with all of the items */
   /* in cst_lists that have open POs associated with them.  This data will be    */
   /* used below to update the item cost and usage rate in CICD.                  */
   /*=============================================================================*/

   /* Bug 3589032 - Instead of inserting the open POs directly into the temp
    * table, I split it into an insert, update, and delete.  The reason is that
    * the explain plan for the single insert has a cost in the 10,000 order of
    * magnitude, vs. a 10 order of magnitude cost for the update statement.
    */

    INSERT INTO cst_open_pos_temp (
       usage_rate_or_amount,
       inventory_item_id)
      SELECT
                NULL
        ,       entity_id
        FROM    cst_lists
        WHERE   list_id = I_LIST_ID;


    UPDATE cst_open_pos_temp COPT
       set usage_rate_or_amount =
    (SELECT  (SUM((POD.quantity_ordered - NVL(POD.quantity_delivered,0)) *
              (PLL.price_override + nvl(po_tax_sv.get_tax('PO',pod.po_distribution_id),0)/pod.quantity_ordered) *
                      NVL(POD.rate,1)) /
                 decode(SUM((POD.quantity_ordered - NVL(POD.quantity_delivered,0)) *
                      UOM.conversion_rate), 0, 1,
                      SUM((POD.quantity_ordered - NVL(POD.quantity_delivered,0)) *
                      UOM.conversion_rate))) *
                     (1 + I_PER_INC/100) + I_AMT_INC
        FROM    mtl_parameters            MP
        ,       po_headers_all            POH
        ,       po_lines_all              POL
        ,       po_line_locations_all     PLL
        ,       po_distributions_all      POD
        ,       mtl_uom_conversions_view  UOM
        WHERE   MP.cost_organization_id         = I_ORG_ID
        AND     POD.destination_organization_id = MP.organization_id
        AND     POD.destination_type_code       = 'INVENTORY'
        AND NVL(PLL.closed_code, 'OPEN') not in ('FINALLY CLOSED', 'CLOSED',
                                                      'CLOSED FOR RECEIVING' )
        AND     POD.quantity_ordered            <> NVL(POD.quantity_delivered,0)
        AND NVL(PLL.cancel_flag, 'N') = 'N'
        AND     POL.item_id                     = COPT.inventory_item_id
        AND     POH.po_header_id                = POL.po_header_id
        AND     POD.po_line_id                  = POL.po_line_id
        AND     PLL.line_location_id            = POD.line_location_id
        AND     PLL.approved_flag = 'Y'
        AND     NVL(PLL.promised_date,NVL(PLL.need_by_date,POH.approved_date))
                BETWEEN
                    NVL(I_FROM_DATE, NVL(PLL.promised_date,NVL(PLL.need_by_date,POH.approved_date))-1)
                AND
                    NVL(I_TO_DATE, NVL(PLL.promised_date,NVL(PLL.need_by_date,POH.approved_date))+1)
        AND     UOM.organization_id             = I_ORG_ID
        AND     UOM.inventory_item_id           = POL.item_id
        AND     UOM.unit_of_measure             = POL.unit_meas_lookup_code
        GROUP BY POL.item_id);

    fnd_file.put_line(fnd_file.log,'Inserted '||to_char(SQL%ROWCOUNT)||' rows into temp table.');

    /* Now delete all items from the temp tables where there were no OPEN POs found */
    DELETE FROM cst_open_pos_temp
    WHERE usage_rate_or_amount IS NULL;

    DELETE FROM cst_lists
    WHERE  list_id = I_LIST_ID
    AND    entity_id NOT IN (SELECT inventory_item_id FROM cst_open_pos_temp);

   /*===============================================================*/
   /*  insert item cost where there is open PO but no pending cost  */
   /*  information                                                  */
   /*===============================================================*/
   CSTPUMEC.CSTPEIIC(I_ORG_ID,
                     I_COST_TYPE_ID,
                     I_LIST_ID,
                     I_RESOURCE_ID,
                     I_USER_ID,
                     I_REQUEST_ID,
                     I_PROGRAM_ID,
                     I_PROGRAM_APPL_ID,
                     O_RETURN_CODE);

   IF O_RETURN_CODE <> 0 THEN
       raise_application_error(-20001, 'CSTPOPOA: '||SQLERRM);
   END IF;

   /*=============================================================================*/
   /* Update CICD using the data in the global temporary table cst_open_pos_temp. */
   /*=============================================================================*/
   UPDATE cst_item_cost_details A
   SET  (
        usage_rate_or_amount
   ,    item_cost
   ,    last_update_date
   ,    last_updated_by
   ,    request_id
   ,    program_application_id
   ,    program_id
   ,    program_update_date
   ) = (
        SELECT  COPT.usage_rate_or_amount
        ,       ROUND((COPT.usage_rate_or_amount) *
                   NVL((A.basis_factor * A.net_yield_or_shrinkage_factor *
                        A.resource_rate),1), EXT_PREC)
        ,       SYSDATE
        ,       I_USER_ID
        ,       I_REQUEST_ID
        ,       I_PROGRAM_APPL_ID
        ,       I_PROGRAM_ID
        ,       SYSDATE
        FROM    cst_open_pos_temp COPT
        WHERE   COPT.inventory_item_id       = A.inventory_item_id
        )
   WHERE organization_id     = I_ORG_ID
   AND   cost_type_id        = I_COST_TYPE_ID
   AND   level_type          = 1
   AND   cost_element_id     = 1
   AND   resource_id         = I_RESOURCE_ID
   AND   NVL(activity_id,-1) = DECODE(I_ACTIVITY_ID,
                                  0, NVL(activity_id,-1),
                                  I_ACTIVITY_ID)
   AND   NVL(basis_type,-1)  = DECODE(I_BASIS_TYPE,
                                  0, NVL(basis_type,-1),
                                  I_BASIS_TYPE)
   AND   rollup_source_type  = 1  /* User Defined */
   AND   A.inventory_item_id in
        (
         SELECT inventory_item_id
         FROM   cst_open_pos_temp
        )
   ;

   fnd_file.put_line(fnd_file.log,'Updated '||to_char(SQL%ROWCOUNT)||' rows in cst_item_cost_details.');

   O_RETURN_CODE := 0;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        O_RETURN_CODE := SQLCODE;
   WHEN OTHERS THEN
        O_RETURN_CODE := SQLCODE;
        raise_application_error(-20001, SQLERRM);

END CSTPOPOA;

PROCEDURE CSTPSHRK (

    I_LIST_ID 			IN	NUMBER,
    I_ORG_ID                    IN      NUMBER,
    I_ACTIVITY_ID		IN	NUMBER,
    I_FROM_DATE		        IN	DATE,
    I_TO_DATE		        IN	DATE,
    I_ACCOUNT_ID                IN      NUMBER,
    I_BASIS_TYPE                IN      NUMBER,
    I_FIXED_RATE                IN      NUMBER,
    I_PER_INC                   IN      NUMBER,
    I_AMT_INC                   IN      NUMBER,
    I_COST_TYPE_ID              IN      NUMBER,
    I_COPY_COST_TYPE            IN      NUMBER,
    I_RESOURCE_ID               IN      NUMBER,

    I_LAST_UPDATED_BY           IN      NUMBER,
    I_REQUEST_ID                IN      NUMBER,
    I_PROGRAM_ID                IN      NUMBER,
    I_PROGRAM_APPL_ID           IN      NUMBER,
    O_RETURN_CODE	        OUT NOCOPY 	NUMBER) IS

    ROUND_UNIT   NUMBER;
    PRECISION    NUMBER;
    EXT_PREC     NUMBER;
    L_LOCATION   NUMBER;

BEGIN

   O_RETURN_CODE := 0;

   L_LOCATION := 0;

   CSTPUTIL.CSTPUGCI(I_ORG_ID, ROUND_UNIT, PRECISION, EXT_PREC);

   L_LOCATION := 1;

   UPDATE CST_ITEM_COSTS A
   SET  SHRINKAGE_RATE = DECODE(I_FIXED_RATE,-1,0,I_FIXED_RATE)
   WHERE ORGANIZATION_ID = I_ORG_ID
   AND	COST_TYPE_ID = I_COST_TYPE_ID
   AND EXISTS
	(
	 SELECT 'X'
	 FROM CST_LISTS L
	 WHERE L.LIST_ID = I_LIST_ID
	 AND L.ENTITY_ID = A.INVENTORY_ITEM_ID
	)
   ;

   L_LOCATION := 2;

   UPDATE CST_ITEM_COST_DETAILS A
   SET	NET_YIELD_OR_SHRINKAGE_FACTOR = 1/(1 - DECODE(I_FIXED_RATE,-1,0,I_FIXED_RATE))
   ,    ITEM_COST = ROUND(((USAGE_RATE_OR_AMOUNT * BASIS_FACTOR *
	        NVL(RESOURCE_RATE,1)) / (1 - DECODE(I_FIXED_RATE,-1,0,I_FIXED_RATE))), EXT_PREC)
   ,    LAST_UPDATE_DATE = SYSDATE
   ,    LAST_UPDATED_BY = I_LAST_UPDATED_BY
   ,    REQUEST_ID = I_REQUEST_ID
   ,    PROGRAM_APPLICATION_ID = I_PROGRAM_APPL_ID
   ,    PROGRAM_ID = I_PROGRAM_ID
   ,    PROGRAM_UPDATE_DATE = SYSDATE
   WHERE ORGANIZATION_ID = I_ORG_ID
   AND	COST_TYPE_ID = I_COST_TYPE_ID
   AND EXISTS
	(
	 SELECT 'X'
	 FROM CST_LISTS L
	 WHERE L.LIST_ID = I_LIST_ID
	 AND L.ENTITY_ID = A.INVENTORY_ITEM_ID
	)
   ;

   O_RETURN_CODE := 0;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
	O_RETURN_CODE := SQLCODE;
   WHEN OTHERS THEN
        O_RETURN_CODE := SQLCODE;
	raise_application_error(-20001, 'CSTPSHRK(' || L_LOCATION || '): '
		|| SQLERRM);

END CSTPSHRK;

PROCEDURE CSTPSMOH (

    I_LIST_ID 			IN	NUMBER,
    I_ORG_ID                    IN      NUMBER,
    I_ACTIVITY_ID		IN	NUMBER,
    I_FROM_DATE		        IN	DATE,
    I_TO_DATE		        IN	DATE,
    I_ACCOUNT_ID                IN      NUMBER,
    I_BASIS_TYPE                IN      NUMBER,
    I_FIXED_RATE                IN      NUMBER,
    I_PER_INC                   IN      NUMBER,
    I_AMT_INC                   IN      NUMBER,
    I_COST_TYPE_ID              IN      NUMBER,
    I_COPY_COST_TYPE            IN      NUMBER,
    I_RESOURCE_ID               IN      NUMBER,

    I_LAST_UPDATED_BY           IN      NUMBER,
    I_REQUEST_ID                IN      NUMBER,
    I_PROGRAM_ID                IN      NUMBER,
    I_PROGRAM_APPL_ID           IN      NUMBER,
    O_RETURN_CODE	        OUT NOCOPY 	NUMBER) IS

    ROUND_UNIT   NUMBER;
    PRECISION    NUMBER;
    EXT_PREC     NUMBER;

BEGIN

   CSTPUTIL.CSTPUGCI(I_ORG_ID, ROUND_UNIT, PRECISION, EXT_PREC);

   O_RETURN_CODE := 9999;

   UPDATE CST_ITEM_COST_DETAILS A
   SET  USAGE_RATE_OR_AMOUNT =
         (DECODE(I_FIXED_RATE,-1,USAGE_RATE_OR_AMOUNT,I_FIXED_RATE) *
          (1 + I_PER_INC/100) + I_AMT_INC),
        ITEM_COST =
         ROUND((DECODE(I_FIXED_RATE,-1,USAGE_RATE_OR_AMOUNT,I_FIXED_RATE) *
          (1 + I_PER_INC/100) + I_AMT_INC) *
          NVL(BASIS_FACTOR,1) * NVL(NET_YIELD_OR_SHRINKAGE_FACTOR,1),
         EXT_PREC),
	LAST_UPDATE_DATE = SYSDATE,
	LAST_UPDATED_BY = I_LAST_UPDATED_BY,
	REQUEST_ID = I_REQUEST_ID,
	PROGRAM_APPLICATION_ID = I_PROGRAM_APPL_ID,
	PROGRAM_ID = I_PROGRAM_ID,
	PROGRAM_UPDATE_DATE = SYSDATE
   WHERE ORGANIZATION_ID = I_ORG_ID
   AND	COST_TYPE_ID = I_COST_TYPE_ID
   AND  LEVEL_TYPE = 1
   AND	COST_ELEMENT_ID = 2
   AND  NVL(ACTIVITY_ID,-1) = DECODE(I_ACTIVITY_ID,
			0, NVL(ACTIVITY_ID,-1),
			I_ACTIVITY_ID)
   AND  NVL(BASIS_TYPE,-1) = DECODE(I_BASIS_TYPE,
			0, NVL(BASIS_TYPE,-1),
			I_BASIS_TYPE)
   AND  NVL(RESOURCE_ID,-1) = DECODE(I_RESOURCE_ID,
			0, NVL(RESOURCE_ID,-1),
			I_RESOURCE_ID)
   AND A.INVENTORY_ITEM_ID IN
	(
	 SELECT ENTITY_ID
	 FROM CST_LISTS L
	 WHERE LIST_ID = I_LIST_ID
	)
   ;

   O_RETURN_CODE := 0;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        O_RETURN_CODE := SQLCODE;
   WHEN OTHERS THEN
        O_RETURN_CODE := SQLCODE;
	raise_application_error(-20001, SQLERRM);

END CSTPSMOH;

PROCEDURE CSTPSMTL (

    I_LIST_ID 			IN	NUMBER,
    I_ORG_ID                    IN      NUMBER,
    I_ACTIVITY_ID		IN	NUMBER,
    I_FROM_DATE		        IN	DATE,
    I_TO_DATE		        IN	DATE,
    I_ACCOUNT_ID                IN      NUMBER,
    I_BASIS_TYPE                IN      NUMBER,
    I_FIXED_RATE                IN      NUMBER,
    I_PER_INC                   IN      NUMBER,
    I_AMT_INC                   IN      NUMBER,
    I_COST_TYPE_ID              IN      NUMBER,
    I_COPY_COST_TYPE            IN      NUMBER,
    I_RESOURCE_ID               IN      NUMBER,

    I_LAST_UPDATED_BY           IN      NUMBER,
    I_REQUEST_ID                IN      NUMBER,
    I_PROGRAM_ID                IN      NUMBER,
    I_PROGRAM_APPL_ID           IN      NUMBER,
    O_RETURN_CODE	        OUT NOCOPY 	NUMBER) IS

    ROUND_UNIT   NUMBER;
    PRECISION    NUMBER;
    EXT_PREC     NUMBER;

BEGIN

   O_RETURN_CODE := 9999;

   CSTPUTIL.CSTPUGCI(I_ORG_ID, ROUND_UNIT, PRECISION, EXT_PREC);

   UPDATE CST_ITEM_COST_DETAILS A
   SET  USAGE_RATE_OR_AMOUNT =
         (DECODE(I_FIXED_RATE,-1,USAGE_RATE_OR_AMOUNT,I_FIXED_RATE) *
          (1 + I_PER_INC/100) + I_AMT_INC),
        ITEM_COST =
         ROUND((DECODE(I_FIXED_RATE,-1,USAGE_RATE_OR_AMOUNT,I_FIXED_RATE) *
          (1 + I_PER_INC/100) + I_AMT_INC) *
          NVL(BASIS_FACTOR,1) * NVL(NET_YIELD_OR_SHRINKAGE_FACTOR,1),
         EXT_PREC),
	LAST_UPDATE_DATE = SYSDATE,
	LAST_UPDATED_BY = I_LAST_UPDATED_BY,
	REQUEST_ID = I_REQUEST_ID,
	PROGRAM_APPLICATION_ID = I_PROGRAM_APPL_ID,
	PROGRAM_ID = I_PROGRAM_ID,
	PROGRAM_UPDATE_DATE = SYSDATE
   WHERE ORGANIZATION_ID = I_ORG_ID
   AND	COST_TYPE_ID = I_COST_TYPE_ID
   AND  LEVEL_TYPE = 1
   AND  COST_ELEMENT_ID = 1
   AND  NVL(ACTIVITY_ID,-1) = DECODE(I_ACTIVITY_ID,
			0, NVL(ACTIVITY_ID,-1),
			I_ACTIVITY_ID)
   AND  NVL(BASIS_TYPE,-1) = DECODE(I_BASIS_TYPE,
			0, NVL(BASIS_TYPE,-1),
			I_BASIS_TYPE)
   AND  NVL(RESOURCE_ID,-1) = DECODE(I_RESOURCE_ID,
			0, NVL(RESOURCE_ID,-1),
			I_RESOURCE_ID)
   AND EXISTS
	(
	 SELECT 'X'
	 FROM CST_LISTS L
	 WHERE LIST_ID = I_LIST_ID
	 AND ENTITY_ID = A.INVENTORY_ITEM_ID
	)
   ;

   O_RETURN_CODE := 0;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
	O_RETURN_CODE := SQLCODE;
   WHEN OTHERS THEN
        O_RETURN_CODE := SQLCODE;
	raise_application_error(-20001, SQLERRM);

END CSTPSMTL;


PROCEDURE CSTPSPSR (

    I_LIST_ID 			IN	NUMBER,
    I_ORG_ID                    IN      NUMBER,
    I_ACTIVITY_ID		IN	NUMBER,
    I_FROM_DATE		        IN	DATE,
    I_TO_DATE		        IN	DATE,
    I_ACCOUNT_ID                IN      NUMBER,
    I_BASIS_TYPE                IN      NUMBER,
    I_FIXED_RATE                IN      NUMBER,
    I_PER_INC                   IN      NUMBER,
    I_AMT_INC                   IN      NUMBER,
    I_COST_TYPE_ID              IN      NUMBER,
    I_COPY_COST_TYPE            IN      NUMBER,
    I_RESOURCE_ID               IN      NUMBER,

    I_LAST_UPDATED_BY           IN      NUMBER,
    I_REQUEST_ID                IN      NUMBER,
    I_PROGRAM_ID                IN      NUMBER,
    I_PROGRAM_APPL_ID           IN      NUMBER,
    O_RETURN_CODE	        OUT NOCOPY 	NUMBER) IS

    ROUND_UNIT   NUMBER;
    PRECISION    NUMBER;
    EXT_PREC     NUMBER;

BEGIN

   O_RETURN_CODE := 0;

   CSTPUTIL.CSTPUGCI(I_ORG_ID, ROUND_UNIT, PRECISION, EXT_PREC);

   /* Changes for Bug #1768987. Setting shrinkage rate to 0 if shrinkage
      rate is NULL in MSI. */
   UPDATE CST_ITEM_COSTS A
   SET  SHRINKAGE_RATE = (
		SELECT	NVL(SHRINKAGE_RATE,0)
		FROM	MTL_SYSTEM_ITEMS
		WHERE	ORGANIZATION_ID = I_ORG_ID
		AND	INVENTORY_ITEM_ID = A.INVENTORY_ITEM_ID
   )
   WHERE ORGANIZATION_ID = I_ORG_ID
   AND	COST_TYPE_ID = I_COST_TYPE_ID
   AND EXISTS
	(
	 SELECT 'X'
	 FROM CST_LISTS L
	 WHERE L.LIST_ID = I_LIST_ID
	 AND L.ENTITY_ID = A.INVENTORY_ITEM_ID
	)
   ;

   UPDATE CST_ITEM_COST_DETAILS A
   SET	(NET_YIELD_OR_SHRINKAGE_FACTOR,
	ITEM_COST,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE) = (
		SELECT	1 / (1 - NVL(SHRINKAGE_RATE, 0)),
			ROUND(((A.USAGE_RATE_OR_AMOUNT * A.BASIS_FACTOR *
	        	  NVL(A.RESOURCE_RATE, 1)) / (1 - NVL(SHRINKAGE_RATE, 0))), EXT_PREC),
			SYSDATE,
			I_LAST_UPDATED_BY,
			I_REQUEST_ID,
			I_PROGRAM_APPL_ID,
			I_PROGRAM_ID,
			SYSDATE
		FROM	MTL_SYSTEM_ITEMS
		WHERE	ORGANIZATION_ID = I_ORG_ID
		AND	INVENTORY_ITEM_ID = A.INVENTORY_ITEM_ID
	)
   WHERE ORGANIZATION_ID = I_ORG_ID
   AND	COST_TYPE_ID = I_COST_TYPE_ID
   AND EXISTS
	(
	 SELECT 'X'
	 FROM CST_LISTS L
	 WHERE L.LIST_ID = I_LIST_ID
	 AND L.ENTITY_ID = A.INVENTORY_ITEM_ID
	)
   ;

   O_RETURN_CODE := 0;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
	O_RETURN_CODE := SQLCODE;
   WHEN OTHERS THEN
        O_RETURN_CODE := SQLCODE;
	raise_application_error(-20001, SQLERRM);

END CSTPSPSR;
PROCEDURE CSTPULMC (

    I_LIST_ID                   IN      NUMBER,
    I_ORG_ID                    IN      NUMBER,
    I_ACTIVITY_ID               IN      NUMBER,
    I_FROM_DATE                 IN      DATE,
    I_TO_DATE                   IN      DATE,
    I_ACCOUNT_ID                IN      NUMBER,
    I_BASIS_TYPE                IN      NUMBER,
    I_FIXED_RATE                IN      NUMBER,
    I_PER_INC                   IN      NUMBER,
    I_AMT_INC                   IN      NUMBER,
    I_COST_TYPE_ID              IN      NUMBER,
    I_COPY_COST_TYPE            IN      NUMBER,
    I_RESOURCE_ID               IN      NUMBER,

    I_USER_ID                   IN      NUMBER,
    I_REQUEST_ID                IN      NUMBER,
    I_PROGRAM_ID                IN      NUMBER,
    I_PROGRAM_APPL_ID           IN      NUMBER,
    O_RETURN_CODE               IN OUT NOCOPY  NUMBER) IS

   ROUND_UNIT   NUMBER;
   PRECISION    NUMBER;
   EXT_PREC     NUMBER;

BEGIN

   O_RETURN_CODE := 9999;

   CSTPUTIL.CSTPUGCI(I_ORG_ID, ROUND_UNIT, PRECISION, EXT_PREC);

   /*===============================================================*/
   /*  Removed any item FROM the list WHERE there is no AP invoice  */
   /*===============================================================*/

   /* =============================================================+
      The next delete is to fix bug number 302747. We will not
      update the cost of any item where the sum of the quantities
      invoiced is equal less than or equal to zero. After having done this
      the above statement is redundant. After having done this
      the above statement is redundant
    +==============================================================*/
/*
   DELETE FROM cst_lists L
   WHERE L.list_id = I_LIST_ID
   AND 0 >=
       (SELECT NVL(sum(quantity_invoiced * UCR.conversion_rate),0)
        FROM   mtl_uom_conversions_view UCR
        ,      po_lines_all             PL
        ,      po_distributions_all     PD
        ,      mtl_parameters           MP
        ,      ap_invoice_distributions_all AIP
        WHERE  AIP.posted_flag       = 'Y'
        AND    (I_FROM_DATE IS NULL OR (I_FROM_DATE IS NOT NULL and  AIP.accounting_date >= I_FROM_DATE))
	AND    (I_TO_DATE IS NULL OR (I_TO_DATE IS NOT NULL and AIP.accounting_date <= I_TO_DATE))
        AND    PD.po_distribution_id          = AIP.po_distribution_id
        AND    PD.destination_organization_id = MP.organization_id
        AND    MP.cost_organization_id        = I_ORG_ID
        AND    PL.po_line_id                  = PD.po_line_id
        AND    PL.item_id                     = L.entity_id
        AND    UCR.inventory_item_id          = PL.item_id
        AND    UCR.organization_id            = I_ORG_ID
        AND    UCR.unit_of_measure            = AIP.MATCHED_UOM_LOOKUP_CODE);
*/


--{BUG 5890227 -FPBUG 5705600
   /* =============================================================+
      This delete is to fix bug number 5705600. We will not
      update the cost of any item where the sum of the Invoiced Value or
      Quantity is equal less than or equal to zero. Since this results in
      Zero or negative item Costs.After having done this the above statement
      is redundant
    +==============================================================*/

   DELETE FROM cst_lists L
   WHERE L.list_id = I_LIST_ID
   AND EXISTS
       (SELECT 1
        FROM   mtl_uom_conversions_view UCR
        ,      po_lines_all             PL
        ,      po_distributions_all     PD
        ,      mtl_parameters           MP
        ,      ap_invoice_distributions_all AIP
        WHERE  NVL(AIP.posted_flag,'N')       = 'Y'
        AND    AIP.accounting_date
                 BETWEEN   NVL(I_FROM_DATE, AIP.accounting_date)
                 AND       NVL(I_TO_DATE, AIP.accounting_date)
        AND    PD.po_distribution_id          = AIP.po_distribution_id
        AND    PD.destination_organization_id = MP.organization_id
        AND    MP.cost_organization_id        = I_ORG_ID
        AND    PL.po_line_id                  = PD.po_line_id
        AND    PL.item_id                     = L.entity_id
        AND    UCR.inventory_item_id          = PL.item_id
        AND    UCR.organization_id            = I_ORG_ID
        AND    UCR.unit_of_measure            = AIP.MATCHED_UOM_LOOKUP_CODE
        HAVING ((NVL(sum(quantity_invoiced * UCR.conversion_rate),0) <=0)
                 OR (sum(nvl(AIP.base_amount, AIP.amount)) <0)));

       fnd_file.put_line(fnd_file.log,to_char(SQL%ROWCOUNT)|| ' Items were deleted from list');
       fnd_file.put_line(fnd_file.log,'Since they had negative or zero Invoiced quantity or negative Invoiced value ');
--}






   /*==================================================================*/
   /*  insert item cost WHERE there is AP invoice but no pending cost  */
   /*  information                                                     */
   /*==================================================================*/
   CSTPUMEC.CSTPEIIC(I_ORG_ID,
                     I_COST_TYPE_ID,
                     I_LIST_ID,
                     I_RESOURCE_ID,
                     I_USER_ID,
                     I_REQUEST_ID,
                     I_PROGRAM_ID,
                     I_PROGRAM_APPL_ID,
                     O_RETURN_CODE);

   IF O_RETURN_CODE <> 0 THEN
       raise_application_error(-20001, 'CSTPULMC: '||SQLERRM);
   END IF;

   UPDATE cst_item_cost_details CICD
   SET (
        usage_rate_or_amount
   ,    item_cost
   ,    last_update_date
   ,    last_updated_by
   ,    request_id
   ,    program_application_id
   ,    program_id
   ,    program_update_date
   ) = (
        SELECT sum(nvl(AIP.base_amount, AIP.amount)) /
                   (sum(quantity_invoiced * UCR.conversion_rate))
                   * (1 + i_per_inc/100) + i_amt_inc
        ,      round((sum(nvl(AIP.base_amount, AIP.amount)) /
                   (sum(quantity_invoiced * UCR.conversion_rate))
                   * (1 + i_per_inc/100) + i_amt_inc) *
                   nvl((CICD.basis_factor * CICD.net_yield_or_shrinkage_factor *
                                CICD.resource_rate),1), ext_prec)
        ,      SYSDATE
        ,      I_USER_ID
        ,      I_REQUEST_ID
        ,      I_PROGRAM_APPL_ID
        ,      I_PROGRAM_ID
        ,      SYSDATE
        FROM   mtl_uom_conversions_view UCR
        ,      po_lines_all             PL
        ,      po_distributions_all     PD
        ,      mtl_parameters           MP
        --BUG#8876268
        ,      (SELECT base_amount
                ,      quantity_invoiced
                ,      amount
                ,      posted_flag
                ,      accounting_date
                ,      line_type_lookup_code
                ,      matched_uom_lookup_code
                ,      po_distribution_id
                FROM   ap_invoice_distributions_all
                WHERE  line_type_lookup_code IN ('ITEM','ACCRUAL','NONREC_TAX', 'TIPV')
                UNION ALL
                SELECT i.base_amount
                ,      0     --l.quantity_invoiced because IPV line quantity is included in accrual or item line quantity
                ,      i.amount
                ,      i.posted_flag
                ,      i.accounting_date
                ,      i.line_type_lookup_code
                ,      l.matched_uom_lookup_code
                ,      i.po_distribution_id
                FROM   ap_invoice_distributions_all i
                     , ap_invoice_distributions_all l
                WHERE  i.line_type_lookup_code = 'IPV'
                AND    i.related_id  = l.related_id
                AND    i.invoice_id  = l.invoice_id
                AND    l.line_type_lookup_code <> 'IPV') AIP
--        ,      ap_invoice_distributions_all AIP
        WHERE  AIP.posted_flag       = 'Y'
        AND    (I_FROM_DATE IS NULL OR (I_FROM_DATE IS NOT NULL and  AIP.accounting_date >= I_FROM_DATE))
        AND    (I_TO_DATE IS NULL OR (I_TO_DATE IS NOT NULL and AIP.accounting_date <= I_TO_DATE))
        -- AND    AIP.line_type_lookup_code = 'ITEM'    -- added for bug 1893507
        --AND    AIP.line_type_lookup_code IN ('ITEM','TAX') -- reverting the change for 1893507 (above) for bug 2866660
        /* Invoice Lines Project, as part of eTAX, TAX line type code is
           split into REC_TAX and NONREC_TAX. In addition, the ITEM
           could now be ITEM or ACCRUAL.  These modifications incorporate
           these changes.
        */
--        AND    AIP.line_type_lookup_code IN ('ITEM','ACCRUAL','IPV','NONREC_TAX', 'TIPV')
        AND    PD.po_distribution_id          = AIP.po_distribution_id
        AND    PD.destination_organization_id = MP.organization_id
        AND    MP.cost_organization_id        = I_ORG_ID
        AND    PL.po_line_id                  = PD.po_line_id
        AND    PL.item_id                     = CICD.inventory_item_id
        AND    UCR.inventory_item_id          = CICD.inventory_item_id
        AND    UCR.organization_id            = I_ORG_ID
        AND    UCR.unit_of_measure            = AIP.MATCHED_UOM_LOOKUP_CODE  --BUG#5881736 PL.unit_meas_lookup_code
              )
   WHERE organization_id     = I_ORG_ID
   AND   cost_type_id        = I_COST_TYPE_ID
   AND   cost_element_id     = 1     /* Material */
   AND   resource_id         = I_RESOURCE_ID
   AND   rollup_source_type  = 1    /* User Defined */
   AND   nvl(activity_id,-1) = DECODE(I_ACTIVITY_ID,
                                  0, NVL(activity_id,-1),
                                  I_ACTIVITY_ID)
   AND   NVL(basis_type,-1)  = DECODE(I_BASIS_TYPE,
                                  0, NVL(basis_type,-1),
                                  I_BASIS_TYPE)
   AND   CICD.inventory_item_id IN
          (SELECT  entity_id
           FROM    cst_lists
           WHERE   list_id   = I_LIST_ID);


EXCEPTION
   WHEN NO_DATA_FOUND THEN
        O_RETURN_CODE := SQLCODE;
   WHEN OTHERS THEN
        O_RETURN_CODE := SQLCODE;
        raise_application_error(-20001, SQLERRM);

END CSTPULMC;

END CSTPMECS;

/

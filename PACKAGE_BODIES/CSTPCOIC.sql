--------------------------------------------------------
--  DDL for Package Body CSTPCOIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPCOIC" AS
/* $Header: CSTPCOIB.pls 120.3.12000000.2 2007/05/11 22:49:29 hyu ship $ */

FUNCTION copy_to_interface(
	copy_option 		IN NUMBER,
        from_org_id     	IN NUMBER,
        to_org_id       	IN NUMBER,
        from_cst_type_id   	IN NUMBER,
        to_cst_type_id     	IN NUMBER,
        range_option    	IN NUMBER,
	spec_item_id		IN NUMBER,
	spec_cat_set_id 	IN NUMBER,
        spec_cat_id             IN NUMBER,
	grp_id  		IN NUMBER,
        conv_type		IN VARCHAR2,
        l_last_updated_by       IN NUMBER,
        error_msg       	OUT NOCOPY VARCHAR2
) RETURN INTEGER IS

location NUMBER := 0;
l_from_currency_code VARCHAR2(15);
l_to_currency_code   VARCHAR2(15);
l_conversion_rate    NUMBER := 1;
l_no_of_rows         NUMBER := 0;

/* 11.5.10+ New variables to support UOM conversion */
/* This cursor selects from a global temp table that *
 * was added for 11.5.10+ CST_UOM_CONV_RATES_TEMP.   */
CURSOR cur_uom_conv IS
   SELECT item_name
   FROM cst_uom_conv_rates_temp
   WHERE uom_conversion_rate IS NULL
   OR uom_conversion_rate IN (0, -99999);
c_missing_uom_conv   cur_uom_conv%ROWTYPE; -- cursor variable
uom_exception        EXCEPTION;  -- raised when no UOM conversion defined
CONC_STATUS          BOOLEAN;    -- variable for SET_COMPLETION_STATUS

BEGIN
/* Obtain currency information */
/*
select currency_code
into   l_from_currency_code
from   cst_organization_definitions
where  organization_id = from_org_id;

select currency_code
into   l_to_currency_code
from   cst_organization_definitions
where  organization_id = to_org_id;
*/
--bug5839929
select distinct
     sob_from.currency_code,
     sob_to.currency_code
into l_from_currency_code,
     l_to_currency_code
from org_organization_definitions ood_from,
     gl_sets_of_books sob_from,
     org_organization_definitions ood_to,
     gl_sets_of_books sob_to
where ood_from.organization_id = from_org_id
and   sob_from.set_of_books_id = ood_from.set_of_books_id
and   ood_to.organization_id   = to_org_id
and   sob_to.set_of_books_id   = ood_to.set_of_books_id;

l_conversion_rate  :=  gl_currency_api.get_rate
			   ( l_from_currency_code,
			     l_to_currency_code,
			     sysdate,
			     conv_type );

if (l_conversion_rate IS NULL) then
      l_conversion_rate := 1;
end if;

/* 11.5.10+ Copy Cost UOM Conversion                                           *
/* Populate the global temp table with the UOM conversion rates for any items  *
 * where the from UOM <> to UOM                                                *
 */

INSERT INTO CST_UOM_CONV_RATES_TEMP (INVENTORY_ITEM_ID, UOM_CONVERSION_RATE, ITEM_NAME)
   SELECT src.inventory_item_id,
          inv_convert.inv_um_convert(src.inventory_item_id, 30, NULL, src.primary_uom_code, dst.primary_uom_code, NULL, NULL),
          substr(src.concatenated_segments,1,50)
   FROM mtl_system_items_kfv src, mtl_system_items_b dst, cst_item_costs cic
   WHERE cic.cost_type_id = from_cst_type_id
   AND (
        /* -- ALL ITEMS -- */
        (range_option = 1)
        OR
        /* -- SPECIFIC ITEM -- */
        ( (range_option = 2) AND (
                CIC.INVENTORY_ITEM_ID = spec_item_id
                )
        )
        OR
        /* -- SPECIFIC CATEGORY -- */
        ( (range_option = 5) AND EXISTS
                           (
                            SELECT INVENTORY_ITEM_ID
                            FROM MTL_ITEM_CATEGORIES MIC
                            WHERE MIC.ORGANIZATION_ID = CIC.ORGANIZATION_ID
                            AND MIC.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
                            AND MIC.CATEGORY_SET_ID = spec_cat_set_id
                            AND MIC.CATEGORY_ID = DECODE(spec_cat_id,0,MIC.CATEGORY_ID,spec_cat_id)
                           )
        )
       )
   AND cic.organization_id = from_org_id
   AND src.organization_id = cic.organization_id
   AND dst.organization_id = to_org_id
   AND src.inventory_item_id = cic.inventory_item_id
   AND src.inventory_item_id = dst.inventory_item_id
   AND src.primary_uom_code <> dst.primary_uom_code
   AND (                                          -- This is necessary because you could incorrectly abort the program
       ( (copy_option = 2) AND                    -- for items you're not trying to copy (based on copy option of
         ( NOT EXISTS (                           -- "New Cost Information Only")
           SELECT NULL
           FROM CST_ITEM_COSTS CIC2
           WHERE CIC2.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
           AND CIC2.ORGANIZATION_ID = to_org_id
           AND CIC2.COST_TYPE_ID = to_cst_type_id
           )
         )
       ) OR
       (copy_option in (1,3))
   );

/* Now that the global temp table is populated, check if any UOM rates are undefined.
 * If so, abort the program and print the offending item(s)
 */
OPEN cur_uom_conv;
FETCH cur_uom_conv INTO c_missing_uom_conv;
if (cur_uom_conv%FOUND) then
   raise uom_exception;
else
   CLOSE cur_uom_conv;
end if;

/* end of addition for 11.5.10+ */


/*   Deleteting destination starts here */

if (copy_option = 3) then

	location := 1;

	DELETE FROM CST_ITEM_COSTS CIC
	WHERE CIC.ORGANIZATION_ID = to_org_id
	AND CIC.COST_TYPE_ID = to_cst_type_id
	AND (
        /* -- ALL ITEMS -- */
        (range_option = 1)
        OR
        /* -- SPECIFIC ITEM -- */
        ( (range_option = 2) AND (
                CIC.INVENTORY_ITEM_ID = spec_item_id
                )
        )
        OR
        /* -- SPECIFIC CATEGORY -- */
        ( (range_option = 5) AND EXISTS
                           (
                            SELECT INVENTORY_ITEM_ID
                            FROM MTL_ITEM_CATEGORIES MIC
                            WHERE MIC.ORGANIZATION_ID = to_org_id
                            AND MIC.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
                            AND MIC.CATEGORY_SET_ID = spec_cat_set_id
                            AND MIC.CATEGORY_ID = DECODE(spec_cat_id,0,MIC.CATEGORY_ID,spec_cat_id)
                           )
        )
       );

	location := 2;

        DELETE FROM CST_ITEM_COST_DETAILS CICD
        WHERE CICD.ORGANIZATION_ID = to_org_id
        AND CICD.COST_TYPE_ID = to_cst_type_id
        AND (
        /* -- ALL ITEMS -- */
        (range_option = 1)
        OR
        /* -- SPECIFIC ITEM -- */
        ( (range_option = 2) AND (
                CICD.INVENTORY_ITEM_ID = spec_item_id
                )
        )
        OR
        /* -- SPECIFIC CATEGORY -- */
        ( (range_option = 5) AND EXISTS
                           (
                            SELECT INVENTORY_ITEM_ID
                            FROM MTL_ITEM_CATEGORIES MIC
                            WHERE MIC.ORGANIZATION_ID = to_org_id
                            AND MIC.INVENTORY_ITEM_ID = CICD.INVENTORY_ITEM_ID
                            AND MIC.CATEGORY_SET_ID = spec_cat_set_id
                            AND MIC.CATEGORY_ID =  DECODE(spec_cat_id,0,MIC.CATEGORY_ID,spec_cat_id)
                           )
        )
       );

end if; /* COPY OPTION = 3 DELETE */

if ( copy_option = 1 ) then

	location := 3;

	DELETE FROM CST_ITEM_COSTS CIC
	WHERE EXISTS (
		SELECT 'Item exists in from org'
		FROM CST_ITEM_COST_DETAILS CIC2
		WHERE CIC2.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
		AND CIC2.ORGANIZATION_ID = from_org_id
		AND CIC2.COST_TYPE_ID = from_cst_type_id
		     )
	AND CIC.ORGANIZATION_ID = to_org_id
	AND CIC.COST_TYPE_ID = to_cst_type_id
	AND (
	    /* -- ALL ITEMS -- */
	      (range_option = 1)
	       OR
	    /* -- SPECIFIC ITEM -- */
	      ( (range_option = 2) AND (
		 CIC.INVENTORY_ITEM_ID = spec_item_id
		)
	      )
	       OR
	      /* -- SPECIFIC CATEGORY -- */
	      ( (range_option = 5) AND EXISTS
				   (
				    SELECT INVENTORY_ITEM_ID
				    FROM MTL_ITEM_CATEGORIES MIC
				    WHERE MIC.ORGANIZATION_ID = to_org_id
				    AND MIC.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
				    AND MIC.CATEGORY_SET_ID = spec_cat_set_id
				    AND MIC.CATEGORY_ID =  DECODE(spec_cat_id,0,MIC.CATEGORY_ID,spec_cat_id)
				   )
	      )
	     );


	/*  following delete needs to change */

	location := 4;

	DELETE FROM CST_ITEM_COST_DETAILS CICD
	WHERE EXISTS (
		SELECT 'Item exists in from org'
		FROM CST_ITEM_COST_DETAILS CIC2
		WHERE CIC2.INVENTORY_ITEM_ID = CICD.INVENTORY_ITEM_ID
		AND CIC2.ORGANIZATION_ID = from_org_id
		AND CIC2.COST_TYPE_ID = from_cst_type_id
	)
	AND CICD.ORGANIZATION_ID = to_org_id
	AND CICD.COST_TYPE_ID = to_cst_type_id
	AND (
	    /* -- ALL ITEMS -- */
	      (range_option = 1)
	       OR
	    /* -- SPECIFIC ITEM -- */
	      ( (range_option = 2) AND (
		 CICD.INVENTORY_ITEM_ID = spec_item_id
		)
	      )
	       OR
	      /* -- SPECIFIC CATEGORY -- */
	      ( (range_option = 5) AND EXISTS
				   (
				    SELECT INVENTORY_ITEM_ID
				    FROM MTL_ITEM_CATEGORIES MIC
				    WHERE MIC.ORGANIZATION_ID = to_org_id
				    AND MIC.INVENTORY_ITEM_ID = CICD.INVENTORY_ITEM_ID
				    AND MIC.CATEGORY_SET_ID = spec_cat_set_id
				    AND MIC.CATEGORY_ID =  DECODE(spec_cat_id,0,MIC.CATEGORY_ID,spec_cat_id)
				   )
	      )
	     );


end if;


 /*
  *	Copy over non-code columns into CST_ITEM_COSTS_INTERFACE
  *	from CST_ITEM_COSTS
  *
  *	CST_ITEM_COSTS ==> CST_ITEM_COSTS_INTERFACE
  */

 location := 5;

if (range_option = 1) then

/* ---- All Items ---- */

INSERT INTO CST_ITEM_COSTS_INTERFACE (
	INVENTORY_ITEM_ID,
	ORGANIZATION_ID,
	COST_TYPE_ID,
	INVENTORY_ITEM,
	ORGANIZATION_CODE,
	COST_TYPE,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_LOGIN,
	INVENTORY_ASSET_FLAG,
	LOT_SIZE,
	BASED_ON_ROLLUP_FLAG,
	SHRINKAGE_RATE,
	DEFAULTED_FLAG,
	COST_UPDATE_ID,
	PL_MATERIAL,
	PL_MATERIAL_OVERHEAD,
	PL_RESOURCE,
	PL_OUTSIDE_PROCESSING,
	PL_OVERHEAD,
	TL_MATERIAL,
	TL_MATERIAL_OVERHEAD,
	TL_RESOURCE,
	TL_OUTSIDE_PROCESSING,
	TL_OVERHEAD,
	MATERIAL_COST,
	MATERIAL_OVERHEAD_COST,
	RESOURCE_COST,
	OUTSIDE_PROCESSING_COST,
	OVERHEAD_COST,
	PL_ITEM_COST,
	TL_ITEM_COST,
	ITEM_COST,
	UNBURDENED_COST,
	BURDEN_COST,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	GROUP_ID
) SELECT
	CIC.INVENTORY_ITEM_ID,
	to_org_id,
	to_cst_type_id,
	MIF.ITEM_NUMBER,
	MP.ORGANIZATION_CODE,
	CCT.COST_TYPE,
	SYSDATE,
	l_last_updated_by,
	SYSDATE,
	l_last_updated_by,
	NULL,
	CIC.INVENTORY_ASSET_FLAG,
	CIC.LOT_SIZE,
	CIC.BASED_ON_ROLLUP_FLAG,
	CIC.SHRINKAGE_RATE,
	CIC.DEFAULTED_FLAG,
	CIC.COST_UPDATE_ID,
	CIC.PL_MATERIAL * nvl(l_conversion_rate,1),
	CIC.PL_MATERIAL_OVERHEAD * nvl(l_conversion_rate,1),
	CIC.PL_RESOURCE * nvl(l_conversion_rate,1),
	CIC.PL_OUTSIDE_PROCESSING * nvl(l_conversion_rate,1),
	CIC.PL_OVERHEAD * nvl(l_conversion_rate,1),
	CIC.TL_MATERIAL * nvl(l_conversion_rate,1),
	CIC.TL_MATERIAL_OVERHEAD * nvl(l_conversion_rate,1),
	CIC.TL_RESOURCE * nvl(l_conversion_rate,1),
	CIC.TL_OUTSIDE_PROCESSING * nvl(l_conversion_rate,1),
	CIC.TL_OVERHEAD * nvl(l_conversion_rate,1),
	CIC.MATERIAL_COST * nvl(l_conversion_rate,1),
	CIC.MATERIAL_OVERHEAD_COST * nvl(l_conversion_rate,1),
	CIC.RESOURCE_COST * nvl(l_conversion_rate,1),
	CIC.OUTSIDE_PROCESSING_COST * nvl(l_conversion_rate,1),
	CIC.OVERHEAD_COST * nvl(l_conversion_rate,1),
	CIC.PL_ITEM_COST * nvl(l_conversion_rate,1),
	CIC.TL_ITEM_COST * nvl(l_conversion_rate,1),
	CIC.ITEM_COST * nvl(l_conversion_rate,1),
	CIC.UNBURDENED_COST * nvl(l_conversion_rate,1),
	CIC.BURDEN_COST * nvl(l_conversion_rate,1),
	CIC.ATTRIBUTE_CATEGORY,
	CIC.ATTRIBUTE1,
	CIC.ATTRIBUTE2,
	CIC.ATTRIBUTE3,
	CIC.ATTRIBUTE4,
	CIC.ATTRIBUTE5,
	CIC.ATTRIBUTE6,
	CIC.ATTRIBUTE7,
	CIC.ATTRIBUTE8,
	CIC.ATTRIBUTE9,
	CIC.ATTRIBUTE10,
	CIC.ATTRIBUTE11,
	CIC.ATTRIBUTE12,
	CIC.ATTRIBUTE13,
	CIC.ATTRIBUTE14,
	CIC.ATTRIBUTE15,
	CIC.REQUEST_ID,
	CIC.PROGRAM_APPLICATION_ID,
	CIC.PROGRAM_ID,
	CIC.PROGRAM_UPDATE_DATE,
	grp_id
FROM	CST_ITEM_COSTS CIC,
	MTL_ITEM_FLEXFIELDS MIF,
	CST_COST_TYPES CCT,
	MTL_PARAMETERS MP
WHERE	CIC.ORGANIZATION_ID = from_org_id
AND	CIC.COST_TYPE_ID = from_cst_type_id
AND	MP.ORGANIZATION_ID = to_org_id
AND	NVL( CCT.ORGANIZATION_ID, to_org_id) = to_org_id
AND	CCT.COST_TYPE_ID = to_cst_type_id
AND	MIF.ORGANIZATION_ID = to_org_id
AND	MIF.ITEM_ID = CIC.INVENTORY_ITEM_ID
AND (
	( (copy_option = 2 or copy_option = 1) AND
	  ( NOT EXISTS (
		SELECT NULL
		FROM CST_ITEM_COSTS CIC2
		WHERE CIC2.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
		AND CIC2.ORGANIZATION_ID = to_org_id
		AND CIC2.COST_TYPE_ID = to_cst_type_id
	    )
	  )
	) OR
	(copy_option = 3)
);

elsif (range_option = 2) then

/* ---- Specific Item ---- */

SELECT COUNT(*) INTO l_no_of_rows FROM CST_ITEM_COSTS CIC
WHERE   CIC.ORGANIZATION_ID = from_org_id
AND     CIC.COST_TYPE_ID = from_cst_type_id
AND     CIC.INVENTORY_ITEM_ID = spec_item_id;

if(l_no_of_rows = 0) then
        commit;
        RETURN(2);
end if;

INSERT INTO CST_ITEM_COSTS_INTERFACE (
	INVENTORY_ITEM_ID,
	ORGANIZATION_ID,
	COST_TYPE_ID,
	INVENTORY_ITEM,
	ORGANIZATION_CODE,
	COST_TYPE,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_LOGIN,
	INVENTORY_ASSET_FLAG,
	LOT_SIZE,
	BASED_ON_ROLLUP_FLAG,
	SHRINKAGE_RATE,
	DEFAULTED_FLAG,
	COST_UPDATE_ID,
	PL_MATERIAL,
	PL_MATERIAL_OVERHEAD,
	PL_RESOURCE,
	PL_OUTSIDE_PROCESSING,
	PL_OVERHEAD,
	TL_MATERIAL,
	TL_MATERIAL_OVERHEAD,
	TL_RESOURCE,
	TL_OUTSIDE_PROCESSING,
	TL_OVERHEAD,
	MATERIAL_COST,
	MATERIAL_OVERHEAD_COST,
	RESOURCE_COST,
	OUTSIDE_PROCESSING_COST,
	OVERHEAD_COST,
	PL_ITEM_COST,
	TL_ITEM_COST,
	ITEM_COST,
	UNBURDENED_COST,
	BURDEN_COST,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	GROUP_ID
) SELECT
	CIC.INVENTORY_ITEM_ID,
	to_org_id,
	to_cst_type_id,
	MIF.ITEM_NUMBER,
	MP.ORGANIZATION_CODE,
	CCT.COST_TYPE,
	SYSDATE,
	l_last_updated_by,
	SYSDATE,
	l_last_updated_by,
	NULL,
	CIC.INVENTORY_ASSET_FLAG,
	CIC.LOT_SIZE,
	CIC.BASED_ON_ROLLUP_FLAG,
	CIC.SHRINKAGE_RATE,
	CIC.DEFAULTED_FLAG,
	CIC.COST_UPDATE_ID,
	CIC.PL_MATERIAL * nvl(l_conversion_rate,1),
	CIC.PL_MATERIAL_OVERHEAD * nvl(l_conversion_rate,1),
	CIC.PL_RESOURCE * nvl(l_conversion_rate,1),
	CIC.PL_OUTSIDE_PROCESSING * nvl(l_conversion_rate,1),
	CIC.PL_OVERHEAD * nvl(l_conversion_rate,1),
	CIC.TL_MATERIAL * nvl(l_conversion_rate,1),
	CIC.TL_MATERIAL_OVERHEAD * nvl(l_conversion_rate,1),
	CIC.TL_RESOURCE * nvl(l_conversion_rate,1),
	CIC.TL_OUTSIDE_PROCESSING * nvl(l_conversion_rate,1),
	CIC.TL_OVERHEAD * nvl(l_conversion_rate,1),
	CIC.MATERIAL_COST * nvl(l_conversion_rate,1),
	CIC.MATERIAL_OVERHEAD_COST * nvl(l_conversion_rate,1),
	CIC.RESOURCE_COST * nvl(l_conversion_rate,1),
	CIC.OUTSIDE_PROCESSING_COST * nvl(l_conversion_rate,1),
	CIC.OVERHEAD_COST * nvl(l_conversion_rate,1),
	CIC.PL_ITEM_COST * nvl(l_conversion_rate,1),
	CIC.TL_ITEM_COST * nvl(l_conversion_rate,1),
	CIC.ITEM_COST * nvl(l_conversion_rate,1),
	CIC.UNBURDENED_COST * nvl(l_conversion_rate,1),
	CIC.BURDEN_COST * nvl(l_conversion_rate,1),
	CIC.ATTRIBUTE_CATEGORY,
	CIC.ATTRIBUTE1,
	CIC.ATTRIBUTE2,
	CIC.ATTRIBUTE3,
	CIC.ATTRIBUTE4,
	CIC.ATTRIBUTE5,
	CIC.ATTRIBUTE6,
	CIC.ATTRIBUTE7,
	CIC.ATTRIBUTE8,
	CIC.ATTRIBUTE9,
	CIC.ATTRIBUTE10,
	CIC.ATTRIBUTE11,
	CIC.ATTRIBUTE12,
	CIC.ATTRIBUTE13,
	CIC.ATTRIBUTE14,
	CIC.ATTRIBUTE15,
	CIC.REQUEST_ID,
	CIC.PROGRAM_APPLICATION_ID,
	CIC.PROGRAM_ID,
	CIC.PROGRAM_UPDATE_DATE,
	grp_id
FROM	CST_ITEM_COSTS CIC,
	MTL_ITEM_FLEXFIELDS MIF,
	CST_COST_TYPES CCT,
	MTL_PARAMETERS MP
WHERE	CIC.ORGANIZATION_ID = from_org_id
AND	CIC.COST_TYPE_ID = from_cst_type_id
AND	CIC.INVENTORY_ITEM_ID = spec_item_id
AND	MIF.ITEM_ID = CIC.INVENTORY_ITEM_ID
AND	MIF.ORGANIZATION_ID = to_org_id
AND	MP.ORGANIZATION_ID = to_org_id
AND	NVL( CCT.ORGANIZATION_ID, to_org_id) = to_org_id
AND	CCT.COST_TYPE_ID = to_cst_type_id
AND (
	( (copy_option = 2 or copy_option = 1) AND
	  ( NOT EXISTS (
		SELECT NULL
		FROM CST_ITEM_COSTS CIC2
		WHERE CIC2.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
		AND CIC2.ORGANIZATION_ID = to_org_id
		AND CIC2.COST_TYPE_ID = to_cst_type_id
	    )
	  )
	) OR
	(copy_option = 3)
);

elsif (range_option = 5) then

/* ---- Specific Category ---- */

INSERT INTO CST_ITEM_COSTS_INTERFACE (
	INVENTORY_ITEM_ID,
	ORGANIZATION_ID,
	COST_TYPE_ID,
	INVENTORY_ITEM,
	ORGANIZATION_CODE,
	COST_TYPE,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_LOGIN,
	INVENTORY_ASSET_FLAG,
	LOT_SIZE,
	BASED_ON_ROLLUP_FLAG,
	SHRINKAGE_RATE,
	DEFAULTED_FLAG,
	COST_UPDATE_ID,
	PL_MATERIAL,
	PL_MATERIAL_OVERHEAD,
	PL_RESOURCE,
	PL_OUTSIDE_PROCESSING,
	PL_OVERHEAD,
	TL_MATERIAL,
	TL_MATERIAL_OVERHEAD,
	TL_RESOURCE,
	TL_OUTSIDE_PROCESSING,
	TL_OVERHEAD,
	MATERIAL_COST,
	MATERIAL_OVERHEAD_COST,
	RESOURCE_COST,
	OUTSIDE_PROCESSING_COST,
	OVERHEAD_COST,
	PL_ITEM_COST,
	TL_ITEM_COST,
	ITEM_COST,
	UNBURDENED_COST,
	BURDEN_COST,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	GROUP_ID
) SELECT
	CIC.INVENTORY_ITEM_ID,
	to_org_id,
	to_cst_type_id,
	MIF.ITEM_NUMBER,
	MP.ORGANIZATION_CODE,
	CCT.COST_TYPE,
	SYSDATE,
	l_last_updated_by,
	SYSDATE,
	l_last_updated_by,
	NULL,
	CIC.INVENTORY_ASSET_FLAG,
	CIC.LOT_SIZE,
	CIC.BASED_ON_ROLLUP_FLAG,
	CIC.SHRINKAGE_RATE,
	CIC.DEFAULTED_FLAG,
	CIC.COST_UPDATE_ID,
	CIC.PL_MATERIAL * nvl(l_conversion_rate,1),
	CIC.PL_MATERIAL_OVERHEAD * nvl(l_conversion_rate,1),
	CIC.PL_RESOURCE * nvl(l_conversion_rate,1),
	CIC.PL_OUTSIDE_PROCESSING * nvl(l_conversion_rate,1),
	CIC.PL_OVERHEAD * nvl(l_conversion_rate,1),
	CIC.TL_MATERIAL * nvl(l_conversion_rate,1),
	CIC.TL_MATERIAL_OVERHEAD * nvl(l_conversion_rate,1),
	CIC.TL_RESOURCE * nvl(l_conversion_rate,1),
	CIC.TL_OUTSIDE_PROCESSING * nvl(l_conversion_rate,1),
	CIC.TL_OVERHEAD * nvl(l_conversion_rate,1),
	CIC.MATERIAL_COST * nvl(l_conversion_rate,1),
	CIC.MATERIAL_OVERHEAD_COST * nvl(l_conversion_rate,1),
	CIC.RESOURCE_COST * nvl(l_conversion_rate,1),
	CIC.OUTSIDE_PROCESSING_COST * nvl(l_conversion_rate,1),
	CIC.OVERHEAD_COST * nvl(l_conversion_rate,1),
	CIC.PL_ITEM_COST * nvl(l_conversion_rate,1),
	CIC.TL_ITEM_COST * nvl(l_conversion_rate,1),
	CIC.ITEM_COST * nvl(l_conversion_rate,1),
	CIC.UNBURDENED_COST * nvl(l_conversion_rate,1),
	CIC.BURDEN_COST * nvl(l_conversion_rate,1),
	CIC.ATTRIBUTE_CATEGORY,
	CIC.ATTRIBUTE1,
	CIC.ATTRIBUTE2,
	CIC.ATTRIBUTE3,
	CIC.ATTRIBUTE4,
	CIC.ATTRIBUTE5,
	CIC.ATTRIBUTE6,
	CIC.ATTRIBUTE7,
	CIC.ATTRIBUTE8,
	CIC.ATTRIBUTE9,
	CIC.ATTRIBUTE10,
	CIC.ATTRIBUTE11,
	CIC.ATTRIBUTE12,
	CIC.ATTRIBUTE13,
	CIC.ATTRIBUTE14,
	CIC.ATTRIBUTE15,
	CIC.REQUEST_ID,
	CIC.PROGRAM_APPLICATION_ID,
	CIC.PROGRAM_ID,
	CIC.PROGRAM_UPDATE_DATE,
	grp_id
FROM	CST_ITEM_COSTS CIC,
	MTL_ITEM_FLEXFIELDS MIF,
	CST_COST_TYPES CCT,
	MTL_PARAMETERS MP
WHERE	CIC.ORGANIZATION_ID = from_org_id
AND	CIC.COST_TYPE_ID = from_cst_type_id
AND	MP.ORGANIZATION_ID = to_org_id
AND	NVL( CCT.ORGANIZATION_ID, to_org_id) = to_org_id
AND	CCT.COST_TYPE_ID = to_cst_type_id
AND	MIF.ORGANIZATION_ID = to_org_id
AND	MIF.ITEM_ID = CIC.INVENTORY_ITEM_ID
AND	CIC.INVENTORY_ITEM_ID in (
		     SELECT INVENTORY_ITEM_ID
		     FROM MTL_ITEM_CATEGORIES MIC
		     WHERE MIC.ORGANIZATION_ID = to_org_id
		     AND MIC.CATEGORY_SET_ID = spec_cat_set_id
		     AND MIC.CATEGORY_ID =  DECODE(spec_cat_id,0,MIC.CATEGORY_ID,spec_cat_id)
	)
AND (
	( (copy_option = 2 or copy_option = 1) AND
	  ( NOT EXISTS (
		SELECT NULL
		FROM CST_ITEM_COSTS CIC2
		WHERE CIC2.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
		AND CIC2.ORGANIZATION_ID = to_org_id
		AND CIC2.COST_TYPE_ID = to_cst_type_id
	    )
	  )
	) OR
	(copy_option = 3)
);

end if;


IF SQL%ROWCOUNT = 0 THEN
	RETURN( 1 );
END IF;

/*
 *     Copy over columns into CST_ITEM_CST_DTLS_INTERFACE
 *     from CST_ITEM_COST_DETAILS
 *
 *     CST_ITEM_COST_DETAILS ==> CST_ITEM_CST_DTLS_INTERFACE
 */

location := 6;

INSERT INTO CST_ITEM_CST_DTLS_INTERFACE (
	GROUP_ID,
	INVENTORY_ITEM_ID,
	ORGANIZATION_ID,
	COST_TYPE_ID,
	INVENTORY_ITEM,
	COST_TYPE,
	ORGANIZATION_CODE,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_LOGIN,
	OPERATION_SEQUENCE_ID,
	OPERATION_SEQ_NUM,
	DEPARTMENT_ID,
	DEPARTMENT,
	LEVEL_TYPE,
	ACTIVITY_ID,
	ACTIVITY,
	RESOURCE_SEQ_NUM,
	RESOURCE_ID,
	RESOURCE_CODE,
	RESOURCE_RATE,
	ITEM_UNITS,
	ACTIVITY_UNITS,
	USAGE_RATE_OR_AMOUNT,
	BASIS_TYPE,
	BASIS_RESOURCE_ID,
	BASIS_RESOURCE_CODE,
	BASIS_FACTOR,
	NET_YIELD_OR_SHRINKAGE_FACTOR,
	ITEM_COST,
	COST_ELEMENT_ID,
	COST_ELEMENT,
	ROLLUP_SOURCE_TYPE,
	ACTIVITY_CONTEXT,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
	--bug5839929
	YIELDED_COST
) SELECT  /*+ ORDERED */
	grp_id,
	CICD.INVENTORY_ITEM_ID,
	to_org_id,
	to_cst_type_id,
	CICI.INVENTORY_ITEM,
	CICI.COST_TYPE,
	CICI.ORGANIZATION_CODE,
	SYSDATE,
	l_last_updated_by,
	SYSDATE,
	l_last_updated_by,
	-1,
	NULL,
	CICD.OPERATION_SEQ_NUM,
	NULL,				/* department_id */
	BD.DEPARTMENT_CODE,
	CICD.LEVEL_TYPE,
	NULL,				/* activity_id */
	CA.ACTIVITY,
	CICD.RESOURCE_SEQ_NUM,
	NULL,				/* resource_id */
	BR.RESOURCE_CODE,
	CICD.RESOURCE_RATE,
	CICD.ITEM_UNITS,
	CICD.ACTIVITY_UNITS,
        decode(cicd.cost_element_id,          /* No currency conversion for percentage rates and for some cases of resources and OSP*/
               2,decode(cicd.basis_type,
                        4,CICD.USAGE_RATE_OR_AMOUNT,
                        5,CICD.USAGE_RATE_OR_AMOUNT,
                        CICD.USAGE_RATE_OR_AMOUNT * nvl(l_conversion_rate,1)),
               3,decode(br.functional_currency_flag,
                        1,CICD.USAGE_RATE_OR_AMOUNT * nvl(l_conversion_rate,1),
                        decode(cicd.resource_id,
                               NULL,CICD.USAGE_RATE_OR_AMOUNT * nvl(l_conversion_rate,1),
                               CICD.USAGE_RATE_OR_AMOUNT)),
               4,decode(br.functional_currency_flag,
                        1,CICD.USAGE_RATE_OR_AMOUNT * nvl(l_conversion_rate,1),
                        decode(cicd.resource_id,
                               NULL,CICD.USAGE_RATE_OR_AMOUNT * nvl(l_conversion_rate,1),
                               CICD.USAGE_RATE_OR_AMOUNT)),
               5,decode(cicd.basis_type,
                        4,CICD.USAGE_RATE_OR_AMOUNT,
                        CICD.USAGE_RATE_OR_AMOUNT * nvl(l_conversion_rate,1)),
               CICD.USAGE_RATE_OR_AMOUNT * nvl(l_conversion_rate,1)),
	CICD.BASIS_TYPE,
	NULL,				/* BASIS_RESOURCE_ID */
	BR.RESOURCE_CODE,
	CICD.BASIS_FACTOR,
	CICD.NET_YIELD_OR_SHRINKAGE_FACTOR,
	CICD.ITEM_COST * nvl(l_conversion_rate,1),
	CICD.COST_ELEMENT_ID,		/* COST_ELEMENT_ID */
	CCE.COST_ELEMENT,
	CICD.ROLLUP_SOURCE_TYPE,
	CICD.ACTIVITY_CONTEXT,
	CICD.REQUEST_ID,
	CICD.PROGRAM_APPLICATION_ID,
	CICD.PROGRAM_ID,
	CICD.PROGRAM_UPDATE_DATE,
	CICD.ATTRIBUTE_CATEGORY,
	CICD.ATTRIBUTE1,
	CICD.ATTRIBUTE2,
	CICD.ATTRIBUTE3,
	CICD.ATTRIBUTE4,
	CICD.ATTRIBUTE5,
	CICD.ATTRIBUTE6,
	CICD.ATTRIBUTE7,
	CICD.ATTRIBUTE8,
	CICD.ATTRIBUTE9,
	CICD.ATTRIBUTE10,
	CICD.ATTRIBUTE11,
	CICD.ATTRIBUTE12,
	CICD.ATTRIBUTE13,
	CICD.ATTRIBUTE14,
	CICD.ATTRIBUTE15,
    --bug5839929
    CICD.yielded_cost*NVL(l_conversion_rate,1)
FROM	CST_ITEM_COSTS_INTERFACE CICI,
	BOM_DEPARTMENTS BD,
	CST_ACTIVITIES CA,
	BOM_RESOURCES BR,
	CST_COST_ELEMENTS CCE,
	CST_ITEM_COST_DETAILS CICD
WHERE	CICI.GROUP_ID = grp_id
AND	CICD.INVENTORY_ITEM_ID = CICI.INVENTORY_ITEM_ID
AND	CICD.ORGANIZATION_ID = from_org_id
AND	CICD.COST_TYPE_ID = from_cst_type_id
AND	BD.ORGANIZATION_ID (+) = from_org_id
AND	BD.DEPARTMENT_ID (+) = CICD.DEPARTMENT_ID
AND	NVL(CA.ORGANIZATION_ID,from_org_id) = from_org_id
AND	CA.ACTIVITY_ID (+) = CICD.ACTIVITY_ID
AND	BR.ORGANIZATION_ID (+) = from_org_id
AND	BR.RESOURCE_ID (+) = CICD.RESOURCE_ID
AND	CCE.COST_ELEMENT_ID (+) = CICD.COST_ELEMENT_ID;


/* 11.5.10+ Copy Cost UOM Conversion                  *
 * Multiply the cost columns in the interface tables  *
 * by the UOM conversion rate                         */

location := 7;

UPDATE (
   SELECT PL_MATERIAL,
          PL_MATERIAL_OVERHEAD,
          PL_RESOURCE,
          PL_OUTSIDE_PROCESSING,
          PL_OVERHEAD,
          TL_MATERIAL,
          TL_MATERIAL_OVERHEAD,
          TL_RESOURCE,
          TL_OUTSIDE_PROCESSING,
          TL_OVERHEAD,
          MATERIAL_COST,
          MATERIAL_OVERHEAD_COST,
          RESOURCE_COST,
          OUTSIDE_PROCESSING_COST,
          OVERHEAD_COST,
          PL_ITEM_COST,
          TL_ITEM_COST,
          ITEM_COST,
          UNBURDENED_COST,
          BURDEN_COST,
          LOT_SIZE,
          uom_conversion_rate
   FROM cst_item_costs_interface cici, cst_uom_conv_rates_temp cucr
   WHERE cici.inventory_item_id = cucr.inventory_item_id
   AND cici.group_id = grp_id)
SET PL_MATERIAL = PL_MATERIAL / uom_conversion_rate,
    PL_MATERIAL_OVERHEAD = PL_MATERIAL_OVERHEAD / uom_conversion_rate,
    PL_RESOURCE = PL_RESOURCE / uom_conversion_rate,
    PL_OUTSIDE_PROCESSING = PL_OUTSIDE_PROCESSING / uom_conversion_rate,
    PL_OVERHEAD = PL_OVERHEAD / uom_conversion_rate,
    TL_MATERIAL = TL_MATERIAL / uom_conversion_rate,
    TL_MATERIAL_OVERHEAD = TL_MATERIAL_OVERHEAD / uom_conversion_rate,
    TL_RESOURCE = TL_RESOURCE / uom_conversion_rate,
    TL_OUTSIDE_PROCESSING = TL_OUTSIDE_PROCESSING / uom_conversion_rate,
    TL_OVERHEAD = TL_OVERHEAD / uom_conversion_rate,
    MATERIAL_COST = MATERIAL_COST / uom_conversion_rate,
    MATERIAL_OVERHEAD_COST = MATERIAL_OVERHEAD_COST / uom_conversion_rate,
    RESOURCE_COST = RESOURCE_COST / uom_conversion_rate,
    OUTSIDE_PROCESSING_COST = OUTSIDE_PROCESSING_COST / uom_conversion_rate,
    OVERHEAD_COST = OVERHEAD_COST / uom_conversion_rate,
    PL_ITEM_COST = PL_ITEM_COST / uom_conversion_rate,
    TL_ITEM_COST = TL_ITEM_COST / uom_conversion_rate,
    ITEM_COST = ITEM_COST / uom_conversion_rate,
    UNBURDENED_COST = UNBURDENED_COST / uom_conversion_rate,
    BURDEN_COST = BURDEN_COST / uom_conversion_rate,
    LOT_SIZE = LOT_SIZE * uom_conversion_rate;

location := 8;
/* Update the usage_rate_or_amount in CICD for all rows where the basis type IS 'ITEM' *
 * When the basis type is item there is no basis factor (it's always 1), so you must   *
 * multiply the usage rate of the item by the UOM conversion factor so that usage rate *
 * times net_yield_or_shrinkage equals item_cost.                                      */

UPDATE (
   SELECT USAGE_RATE_OR_AMOUNT,
          ITEM_COST,
          uom_conversion_rate
   FROM cst_item_cst_dtls_interface cicdi, cst_uom_conv_rates_temp cucr
   WHERE cicdi.inventory_item_id = cucr.inventory_item_id
   AND cicdi.basis_type = 1
   AND cicdi.group_id = grp_id)
SET USAGE_RATE_OR_AMOUNT = USAGE_RATE_OR_AMOUNT / uom_conversion_rate,
    ITEM_COST = ITEM_COST / uom_conversion_rate;

location := 9;
/* Update the basis_factor in CICD for all rows where the basis type IS NOT 'ITEM'     *
 * When the basis type is anything other than 'ITEM' (LOT, RESOURCE UNITS, RESOURCE    *
 * VALUE, TOTAL VALUE, ACTIVITY) the basis factor converts between basis and item, so  *
 * we should apply the UOM conversion to the basis factor.                             */

UPDATE (
   SELECT BASIS_FACTOR,
          ITEM_COST,
          uom_conversion_rate
   FROM cst_item_cst_dtls_interface cicdi, cst_uom_conv_rates_temp cucr
   WHERE cicdi.inventory_item_id = cucr.inventory_item_id
   AND cicdi.basis_type <> 1
   AND cicdi.group_id = grp_id)
SET BASIS_FACTOR = BASIS_FACTOR / uom_conversion_rate,
    ITEM_COST = ITEM_COST / uom_conversion_rate;



/* End of 11.5.10+ additions */

RETURN(0); /* No Error */

EXCEPTION
    WHEN uom_exception THEN
       fnd_file.put_line(fnd_file.log,'');
       fnd_message.set_name('BOM', 'CST_NO_UOM_CONV_RATE');
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       LOOP
          fnd_file.put_line(fnd_file.log,c_missing_uom_conv.item_name);
          FETCH cur_uom_conv INTO c_missing_uom_conv;
          EXIT WHEN cur_uom_conv%NOTFOUND;
       END LOOP;
       CLOSE cur_uom_conv;
       error_msg := 'copy_to_interface(): Required Unit of Measure conversion rates are missing.';
       CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',error_msg);
       RETURN(1); -- the calling program will rollback

    WHEN OTHERS THEN
        error_msg         := 'copy_to_interface('||location||'): ' || SQLERRM(100);
	RETURN(SQLCODE);


END copy_to_interface;


END CSTPCOIC; /* end package body */

/

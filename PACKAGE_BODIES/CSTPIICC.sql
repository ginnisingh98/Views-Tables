--------------------------------------------------------
--  DDL for Package Body CSTPIICC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPIICC" AS
/* $Header: CSTIICIB.pls 120.1 2005/06/15 07:53:14 appldev  $ */
PROCEDURE CSTPIICI (

   i_item_id			IN  NUMBER,
   i_org_id			IN  NUMBER,
   i_user_id			IN  NUMBER,

   o_return_code		OUT NOCOPY NUMBER,
   o_return_err			OUT NOCOPY VARCHAR2) AS

   l_planning_make_buy_code	NUMBER;
   l_shrinkage_rate		NUMBER;
   l_costing_method		NUMBER;
   l_cost_org			NUMBER;
   l_std_lot_size		NUMBER;
   l_inv_asset_flag		NUMBER;
   l_def_matl_cost_code_id      NUMBER;

   l_cost_type_id		NUMBER;
   l_item_type			NUMBER;
   l_return_code		NUMBER;
   l_return_err			VARCHAR2(80);

   l_temp			NUMBER;

   -- OPM INVCONV umoogala  Skip inserting into CICD for Process Orgs.
   l_process_enabled_flag    VARCHAR2(1);

BEGIN

    o_return_code := 0;
    o_return_err := ' ';

    /*------------------------------------------------------------+
     | Begin OPM INVCONV sschinch/umoogala Process/discrete Xfer changes.
     | Following query will return:
     | 1 for process/discrete xfer
     | 0 for discrete/discrete xfer
     +------------------------------------------------------------*/
    SELECT NVL(process_enabled_flag, 'N')
      INTO l_process_enabled_flag
      FROM mtl_parameters
     WHERE organization_id = i_org_id;

    -- Skip inserting into CICD for process orgs
    IF l_process_enabled_flag = 'Y'
    THEN
      RETURN;
    END IF;
    -- End OPM INVCONV umoogala


    SELECT
        MP.primary_cost_method,
	MP.cost_organization_id,
        DECODE(DECODE(MSI.planning_make_buy_code,
                      1,MSI.planning_make_buy_code,
                      2,MSI.planning_make_buy_code,
                      2),
               1,NVL(MSI.shrinkage_rate,0),
               0),
        NVL(MSI.std_lot_size,1),
        DECODE(MSI.planning_make_buy_code,
               1,MSI.planning_make_buy_code,
               2,MSI.planning_make_buy_code,
               2),
        DECODE(MSI.inventory_asset_flag,
               'Y', 1,
               2),
        MP.DEFAULT_MATERIAL_COST_ID
     INTO l_costing_method,
	  l_cost_org,
          l_shrinkage_rate,
          l_std_lot_size,
          l_planning_make_buy_code,
          l_inv_asset_flag,
          l_def_matl_cost_code_id
     from mtl_system_items MSI,
          mtl_parameters MP
     WHERE MSI.inventory_item_id = i_item_id
     AND   MSI.organization_id = i_org_id
     AND   MSI.costing_enabled_flag = 'Y'
     AND   MP.organization_id = i_org_id;

    IF l_cost_org = i_org_id THEN

	l_cost_type_id := l_costing_method;

/*---------------------------------------------------------------------+
 |
 |  man: It so happens that for planning_make_buy_code 1 => Make
 |                                                     2 => Buy
 |                           for item_type             1 => Make
 |                                                     2 => Buy
 |                                                     3 => All
 |                          for based_on_rollup        1 => Yes (Make)
 |                                                     2 => No  (Buy)
 |
 +---------------------------------------------------------------------*/
	l_item_type := l_planning_make_buy_code;

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
	     inventory_asset_flag,
             item_cost)
	 VALUES
	    (
	     i_item_id,
	     i_org_id,
	     l_cost_type_id,
	     sysdate,
	     i_user_id,
	     sysdate,
	     i_user_id,
	     2,
	     l_shrinkage_rate,
	     l_std_lot_size,
	     l_planning_make_buy_code,
	     l_inv_asset_flag,
	     0 );

	l_return_code := 0;

	IF l_inv_asset_flag = 1 THEN
              /* insert default material overhead or TL matl cost row
                 in CST_ITEM_COST_DETAILS depending on cost method*/
	      CSTPIDIC.CSTPIDIO(i_item_id,
		       i_org_id,
		       i_user_id,
		       l_cost_type_id,
		       l_item_type,
		       l_std_lot_size,
		       l_shrinkage_rate,
		       l_return_code,
		       l_return_err);
        END IF;

	IF l_return_code <> 0 then
	     o_return_code := l_return_code;
	     o_return_err := l_return_err;
	ELSE
	     o_return_code := 0;
	END IF;

END IF;

EXCEPTION
     WHEN DUP_VAL_ON_INDEX THEN
           o_return_code := 0;
     WHEN NO_DATA_FOUND THEN
         BEGIN
              select 0
              into l_temp
              from mtl_system_items msi
              where msi.inventory_item_id = i_item_id
              and   msi.organization_id = i_org_id
              and   msi.costing_enabled_flag = 'N';

              o_return_code := 0;

         EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 o_return_code := SQLCODE;
                 o_return_err := 'CSTPIICI:' || substrb(SQLERRM,1,70);
              WHEN OTHERS THEN
                 o_return_code := SQLCODE;
                 o_return_err := 'CSTPIICI:' || substrb(SQLERRM,1,70);
         END;
     WHEN OTHERS THEN
           o_return_code := SQLCODE;
           o_return_err := 'CSTPIICI:' || substrb(SQLERRM,1,70);
END;
END CSTPIICC;

/

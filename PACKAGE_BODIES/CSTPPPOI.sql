--------------------------------------------------------
--  DDL for Package Body CSTPPPOI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPPOI" AS
/* $Header: CSTPPOIB.pls 120.1 2005/06/21 14:47:42 appldev ship $ */

PROCEDURE validate_cost_elements (
        x_interface_header_id   IN	NUMBER,
        x_no_of_rows            OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2)
IS

l_stmt_num                      NUMBER;

BEGIN
        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

	l_stmt_num := 1;

	SELECT count(*)
        INTO   x_no_of_rows
        FROM   cst_pc_cost_det_interface cpicdi
        WHERE  cpicdi.interface_header_id = x_interface_header_id
        AND    cpicdi.cost_element_id NOT IN (1,2,3,4,5);




EXCEPTION

        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPPOI.validate_cost_elements('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);
END validate_cost_elements;


PROCEDURE validate_level_types (
        x_interface_header_id   IN    NUMBER,
        x_no_of_rows            OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2)
IS

l_stmt_num                      NUMBER;

BEGIN
        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

        l_stmt_num := 1;

	    SELECT count(*)
            INTO   x_no_of_rows
            FROM   cst_pc_cost_det_interface cpicdi
            WHERE  cpicdi.interface_header_id = x_interface_header_id
            AND    cpicdi.level_type NOT IN (1,2);




EXCEPTION

        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPPOI.validate_level_types('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);

END validate_level_types;


PROCEDURE get_le_cg_id (
        x_interface_header_id   IN      NUMBER,
        x_cost_group_id         OUT NOCOPY     NUMBER,
	x_legal_entity		OUT NOCOPY	NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2)
IS

l_stmt_num                      NUMBER;

BEGIN
        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

        l_stmt_num := 1;



    SELECT DISTINCT ccg.cost_group_id,
                    ccg.legal_entity
             INTO   x_cost_group_id,
                    x_legal_entity
             FROM   cst_cost_groups ccg,
                    cst_cost_group_assignments ccga
             WHERE  ccg.cost_group_id = ccga.cost_group_id
             AND    ccg.cost_group_type = 2
             AND    ccg.cost_group = ( SELECT cpici.cost_group
                                       FROM   cst_pc_item_cost_interface cpici
                                       WHERE  cpici.interface_header_id = x_interface_header_id);


        l_stmt_num := 2;

    UPDATE	cst_pc_item_cost_interface cpici
    SET	 	cpici.cost_group_id = x_cost_group_id
    WHERE	cpici.interface_header_id = x_interface_header_id;

	COMMIT;

EXCEPTION

        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPPOI.get_le_cg_id('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);


END get_le_cg_id;




PROCEDURE get_ct_cm_id (
        x_interface_header_id   IN      NUMBER,
	x_legal_entity		IN	NUMBER,
        x_cost_type_id          OUT NOCOPY     NUMBER,
        x_primary_cost_method   OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2)
IS

l_stmt_num                      NUMBER;

BEGIN
        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

        l_stmt_num := 1;


             SELECT     cct.cost_type_id,
                        clct.primary_cost_method
             INTO       x_cost_type_id,
                        x_primary_cost_method
             FROM       cst_cost_types cct,
                        cst_le_cost_types clct
             WHERE      cct.cost_type_id = clct.cost_type_id
             AND        clct.legal_entity = x_legal_entity
             AND        cct.cost_type = ( SELECT  cpici.cost_type
                                          FROM    cst_pc_item_cost_interface cpici
                                  WHERE   cpici.interface_header_id = x_interface_header_id );



EXCEPTION

        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPPOI.get_ct_cm_id('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);


END get_ct_cm_id;


PROCEDURE get_pac_id (
        x_interface_header_id   IN      NUMBER,
        x_legal_entity          IN      NUMBER,
        x_cost_type_id          IN     NUMBER,
        x_pac_period_id         OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2)
IS

l_stmt_num                      NUMBER;

BEGIN
        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

        l_stmt_num := 1;

             SELECT cpp.pac_period_id
             INTO   x_pac_period_id
             FROM   cst_pac_periods cpp
             WHERE  cpp.period_name  = ( SELECT cpici.period_name
                                         FROM   cst_pc_item_cost_interface cpici
                                         WHERE  cpici.interface_header_id = x_interface_header_id )
             AND    cpp.pac_period_id =( SELECT MAX(cpp1.pac_period_id )
                                         FROM   cst_pac_periods cpp1
                                         WHERE  cpp1.legal_entity = x_legal_entity
                                         AND    cpp1.cost_type_id = x_cost_type_id );


         l_stmt_num := 2;

    UPDATE      cst_pc_item_cost_interface cpici
    SET         cpici.pac_period_id = x_pac_period_id
    WHERE       cpici.interface_header_id = x_interface_header_id;


 	COMMIT;

EXCEPTION

        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPPOI.get_pac_id('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);


END get_pac_id;


PROCEDURE validate_item (
        x_interface_header_id   IN      NUMBER,
        x_cost_group_id         IN      NUMBER,
        x_item_id               OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2)
IS

l_stmt_num                      NUMBER;

BEGIN
        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

        l_stmt_num := 1;


            SELECT DISTINCT msi.inventory_item_id
            INTO   x_item_id
            FROM   mtl_system_items msi,
                   cst_cost_group_assignments ccga
            WHERE  msi.organization_id = ccga.organization_id
            AND    ccga.cost_group_id = x_cost_group_id
            AND    msi.inventory_item_id = ( SELECT  cpici.inventory_item_id
                                             FROM    cst_pc_item_cost_interface cpici
                                     WHERE   cpici.interface_header_id = x_interface_header_id );



EXCEPTION

        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPPOI.validate_item('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);


END validate_item;


PROCEDURE validate_cost (
        x_interface_header_id   IN      NUMBER,
	x_item_id		IN	NUMBER,
	x_pac_period_id		IN	NUMBER,
	x_cost_group_id		IN	NUMBER,
        x_no_of_rows            OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2)
IS

l_stmt_num                      NUMBER;

BEGIN
        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

        l_stmt_num := 1;


            SELECT count(*)
            INTO   x_no_of_rows
            FROM   cst_pac_item_costs cpic
            WHERE  cpic.inventory_item_id = x_item_id
            AND    cpic.pac_period_id = x_pac_period_id
            AND    cpic.cost_group_id = x_cost_group_id;





EXCEPTION

        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPPOI.validate_cost('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);

END validate_cost;


PROCEDURE validate_market_value (
        x_interface_header_id   IN      NUMBER,
        x_no_of_rows            OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2)
IS

l_stmt_num                      NUMBER;

BEGIN
        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

        l_stmt_num := 1;

            SELECT count(*)
            INTO   x_no_of_rows
            FROM   cst_pc_item_cost_interface cpici
            WHERE  cpici.interface_header_id = x_interface_header_id
            AND    cpici.market_value > cpici.item_cost;





EXCEPTION

        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPPOI.validate_market_value('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);

END validate_market_value;

PROCEDURE validate_justification (
        x_interface_header_id   IN      NUMBER,
        x_no_of_rows            OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2)
IS

l_stmt_num                      NUMBER;

BEGIN
        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

        l_stmt_num := 1;

            SELECT count(*)
            INTO   x_no_of_rows
            FROM   cst_pc_item_cost_interface cpici
            WHERE  cpici.interface_header_id = x_interface_header_id
            AND    cpici.market_value  IS NOT NULL
            AND    cpici.justification IS NULL;






EXCEPTION

        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPPOI.validate_justification('
                                || to_char(l_stmt_num)
				|| '): '
                                ||SQLERRM,1,240);


END validate_justification;



PROCEDURE import_costs (
        x_interface_header_id   IN      NUMBER,
	x_user_id		IN 	NUMBER,
	x_login_id		IN	NUMBER,
	x_req_id		IN	NUMBER,
	x_prg_appid		IN	NUMBER,
	x_prg_id		IN	NUMBER,
	x_no_of_rows		OUT NOCOPY	NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2)
IS

l_stmt_num                      NUMBER;
no_rows_exception		EXCEPTION;
l_primary_cost_method		NUMBER;


BEGIN
        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

l_stmt_num := 0;

  SELECT clct.primary_cost_method
  INTO	 l_primary_cost_method
  FROM   cst_cost_types cct,
         cst_le_cost_types clct
  WHERE  cct.cost_type_id = clct.cost_type_id
  AND    cct.cost_type =
             ( SELECT  cpici.cost_type
               FROM    cst_pc_item_cost_interface cpici
               WHERE   cpici.interface_header_id = x_interface_header_id )
  AND    clct.legal_entity =
              (SELECT DISTINCT ccg.legal_entity
        	      FROM   cst_cost_groups ccg,
                 	     cst_cost_group_assignments ccga
             	      WHERE  ccg.cost_group_id = ccga.cost_group_id
             	      AND    ccg.cost_group_type = 2
             	      AND    ccg.cost_group =
                                 (SELECT cpici.cost_group
                                  FROM   cst_pc_item_cost_interface cpici
                                  WHERE  cpici.interface_header_id =
                                               x_interface_header_id));

l_stmt_num := 1;

  INSERT INTO  cst_pac_item_costs (
                                COST_LAYER_ID,
                                PAC_PERIOD_ID,
                                COST_GROUP_ID,
                                INVENTORY_ITEM_ID,
                                BUY_QUANTITY,
                                MAKE_QUANTITY,
                                ISSUE_QUANTITY,
                                TOTAL_LAYER_QUANTITY,
                                ITEM_COST,
                                MARKET_VALUE,
                                JUSTIFICATION,
                                ITEM_BUY_COST,
                                ITEM_MAKE_COST,
                                BEGIN_ITEM_COST,
                                MATERIAL_COST,
                                MATERIAL_OVERHEAD_COST,
                                RESOURCE_COST,
                                OVERHEAD_COST,
                                OUTSIDE_PROCESSING_COST,
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
                                PL_ITEM_COST,
                                TL_ITEM_COST,
                                UNBURDENED_COST,
                                BURDEN_COST,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                CREATION_DATE,
                                CREATED_BY,
                                REQUEST_ID,
                                PROGRAM_APPLICATION_ID,
                                PROGRAM_ID,
                                PROGRAM_UPDATE_DATE,
                                 LAST_UPDATE_LOGIN )
                        SELECT  COST_LAYER_ID,
                                PAC_PERIOD_ID,
                                COST_GROUP_ID,
                                INVENTORY_ITEM_ID,
                                DECODE(l_primary_cost_method,4,1,BUY_QUANTITY),
                                DECODE(l_primary_cost_method,4,0,MAKE_QUANTITY),
                                ISSUE_QUANTITY,
                                DECODE(l_primary_cost_method,4, layer_quantity,NVL(BEGIN_LAYER_QUANTITY,0)),
                                DECODE(l_primary_cost_method,4,0,ITEM_COST),
                                MARKET_VALUE,
                                JUSTIFICATION,
                                DECODE(l_primary_cost_method,4,item_cost,ITEM_BUY_COST),
                                DECODE(l_primary_cost_method,4,0,ITEM_MAKE_COST),
                                BEGIN_ITEM_COST,
                                MATERIAL_COST,
                                MATERIAL_OVERHEAD_COST,
                                RESOURCE_COST,
                                OVERHEAD_COST,
                                OUTSIDE_PROCESSING_COST,
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
                                PL_ITEM_COST,
                                TL_ITEM_COST,
                                UNBURDENED_COST,
                                BURDEN_COST,
                                SYSDATE,
                                x_user_id,
                                SYSDATE,
                                x_user_id,
                                x_req_id,
                                x_prg_appid,
                                x_prg_id,
                                SYSDATE,
                                x_login_id
                        FROM    cst_pc_item_cost_interface cpici
                        WHERE   cpici.interface_header_id = x_interface_header_id ;


x_no_of_rows := SQL%ROWCOUNT;

if(SQL%ROWCOUNT = 0) then
	RAISE no_rows_exception;
end if;

l_stmt_num := 2;

  INSERT INTO cst_pac_item_cost_details (
                                 COST_LAYER_ID,
                                 COST_ELEMENT_ID,
                                 LEVEL_TYPE,
                                 ITEM_COST,
                                 ITEM_BUY_COST,
                                 ITEM_MAKE_COST,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY,
                                 CREATION_DATE,
                                 CREATED_BY,
                                 REQUEST_ID,
                                 PROGRAM_APPLICATION_ID,
                                 PROGRAM_ID,
                                 PROGRAM_UPDATE_DATE,
                                 LAST_UPDATE_LOGIN )
           	    SELECT       COST_LAYER_ID,
                                 COST_ELEMENT_ID,
                                 LEVEL_TYPE,
                                 ITEM_COST,
                                 ITEM_BUY_COST,
                                 ITEM_MAKE_COST,
                                 SYSDATE,
                                 x_user_id,
                                 SYSDATE,
                                 x_user_id,
                                 x_req_id,
                                 x_prg_appid,
                                 x_prg_id,
                                 SYSDATE,
                                 x_login_id
                    FROM         cst_pc_cost_det_interface cpcdi
                    WHERE        cpcdi.interface_header_id = x_interface_header_id ;


if(SQL%ROWCOUNT = 0 AND l_primary_cost_method <> 4) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 3;

  INSERT INTO          CST_PAC_QUANTITY_LAYERS (
                                 QUANTITY_LAYER_ID,
                                 COST_LAYER_ID,
                                 PAC_PERIOD_ID,
                                 COST_GROUP_ID,
                                 INVENTORY_ITEM_ID,
				 BEGIN_LAYER_QUANTITY,
                                 LAYER_QUANTITY,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY,
                                 CREATION_DATE,
                                 CREATED_BY,
                                 REQUEST_ID,
                                 PROGRAM_APPLICATION_ID,
                                 PROGRAM_ID,
                                 PROGRAM_UPDATE_DATE,
                                 LAST_UPDATE_LOGIN )
                SELECT           QUANTITY_LAYER_ID,
                                 COST_LAYER_ID,
                                 PAC_PERIOD_ID,
                                 COST_GROUP_ID,
                                 INVENTORY_ITEM_ID,
				 DECODE(l_primary_cost_method,4,
                                        BEGIN_LAYER_QUANTITY,NULL),
                                 DECODE(l_primary_cost_method,4,
                                        LAYER_QUANTITY-BEGIN_LAYER_QUANTITY,
                                        NVL(BEGIN_LAYER_QUANTITY,0)),
                                 SYSDATE,
                                 x_user_id,
                                 SYSDATE,
                                 x_user_id,
                                 x_req_id,
                                 x_prg_appid,
                                 x_prg_id,
                                 SYSDATE,
                                 x_login_id
                FROM             CST_PC_ITEM_COST_INTERFACE cpici
                WHERE            cpici.interface_header_id = x_interface_header_id ;


if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;

EXCEPTION

	WHEN no_rows_exception THEN
		 ROLLBACK;
                x_err_num := -1;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPPOI.import_costs('
                                || to_char(l_stmt_num)
                                || '): '
                                ||'No rows imported ERROR',1,240);


        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPPOI.import_costs('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);


END import_costs;



PROCEDURE derive_costs (
        x_interface_header_id   IN      NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2)
IS

l_stmt_num                      NUMBER;
no_rows_exception               EXCEPTION;



BEGIN
        ----------------------------------------------------------------------
        -- Initialize Variables
        ----------------------------------------------------------------------

l_stmt_num := 1;


         UPDATE cst_pc_cost_det_interface cpcdi
         SET    cpcdi.item_buy_cost = NVL(cpcdi.item_buy_cost,0),
		cpcdi.item_make_cost = NVL(cpcdi.item_make_cost,0)
	 WHERE  cpcdi.interface_header_id = x_interface_header_id;


if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 2;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          tl_material = ( SELECT  NVL(SUM(item_cost),0)
                                        FROM    cst_pc_cost_det_interface cpcdi
                                        WHERE   cpcdi.interface_header_id = x_interface_header_id
                                        AND     level_type = 1
                                        AND     cost_element_id = 1 )
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 3;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          tl_material_overhead = ( SELECT  NVL(SUM(item_cost),0)
                                                 FROM    cst_pc_cost_det_interface cpcdi
                                         WHERE   cpcdi.interface_header_id = x_interface_header_id
                                                 AND     level_type = 1
                                                 AND     cost_element_id = 2 )
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 4;


	UPDATE       cst_pc_item_cost_interface cpici
           SET          tl_resource = ( SELECT  NVL(SUM(item_cost),0)
                                        FROM    cst_pc_cost_det_interface cpcdi
                                        WHERE   cpcdi.interface_header_id = x_interface_header_id
                                        AND     level_type = 1
                                        AND     cost_element_id = 3 )
           WHERE        cpici.interface_header_id = x_interface_header_id;


if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 5;


	UPDATE       cst_pc_item_cost_interface cpici
           SET          tl_outside_processing = ( SELECT  NVL(SUM(item_cost),0)
                                        FROM    cst_pc_cost_det_interface cpcdi
                                        WHERE   cpcdi.interface_header_id = x_interface_header_id
                                        AND     level_type = 1
                                        AND     cost_element_id = 4 )
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 6;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          tl_overhead = ( SELECT  NVL(SUM(item_cost),0)
                                        FROM    cst_pc_cost_det_interface cpcdi
                                        WHERE   cpcdi.interface_header_id = x_interface_header_id
                                        AND     level_type = 1
                                        AND     cost_element_id = 5 )
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 7;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          pl_material = ( SELECT  NVL(SUM(item_cost),0)
                                        FROM    cst_pc_cost_det_interface cpcdi
                                        WHERE   cpcdi.interface_header_id = x_interface_header_id
                                        AND     level_type = 2
                                        AND     cost_element_id = 1 )
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 8;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          pl_material_overhead
                                = ( SELECT  NVL(SUM(item_cost),0)
                                    FROM    cst_pc_cost_det_interface cpcdi
                               WHERE   cpcdi.interface_header_id = x_interface_header_id
                               AND     level_type = 2
                               AND     cost_element_id = 2 )
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 9;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          pl_resource = ( SELECT  NVL(SUM(item_cost),0)
                                        FROM    cst_pc_cost_det_interface cpcdi
                                        WHERE   cpcdi.interface_header_id = x_interface_header_id
                                        AND     level_type = 2
                                        AND     cost_element_id = 3 )
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 10;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          pl_outside_processing = ( SELECT  NVL(SUM(item_cost),0)
                                        FROM    cst_pc_cost_det_interface cpcdi
                                        WHERE   cpcdi.interface_header_id = x_interface_header_id
                                        AND     level_type = 2
                                        AND     cost_element_id = 4 )
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 11;


	UPDATE       cst_pc_item_cost_interface cpici
           SET          pl_overhead = ( SELECT  NVL(SUM(item_cost),0)
                                        FROM    cst_pc_cost_det_interface cpcdi
                                        WHERE   cpcdi.interface_header_id = x_interface_header_id
                                        AND     level_type = 2
                                        AND     cost_element_id = 5 )
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 12;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          cpici.tl_item_cost = NVL(NVL(cpici.tl_material,0)+NVL(cpici.tl_material_overhead,0)+NVL(cpici.tl_resource,0)+NVL(cpici.tl_outside_processing,0)+NVL(cpici.tl_overhead,0),0)
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 13;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          cpici.pl_item_cost = NVL(NVL(cpici.pl_material,0)+NVL(cpici.pl_material_overhead,0)+NVL(cpici.pl_resource,0)+NVL(cpici.pl_outside_processing,0)+NVL(cpici.pl_overhead,0),0)
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 14;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          cpici.item_cost = NVL(NVL(cpici.tl_item_cost,0) + NVL(cpici.pl_item_cost,0),0)
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 15;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          cpici.material_cost = NVL(NVL(cpici.tl_material,0) + NVL(cpici.pl_material,0),0)
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 16;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          cpici.material_overhead_cost = NVL(NVL(cpici.tl_material_overhead,0) + NVL(cpici.pl_material_overhead,0),0)
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 17;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          cpici.resource_cost = NVL(NVL(cpici.tl_resource,0) + NVL(cpici.pl_resource,0),0)
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 18;


	UPDATE       cst_pc_item_cost_interface cpici
           SET          cpici.outside_processing_cost = NVL(NVL(cpici.tl_outside_processing,0) + NVL(cpici. pl_outside_processing,0),0)
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 19;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          cpici.overhead_cost = NVL(NVL(cpici.tl_overhead,0) + NVL(cpici.pl_overhead,0),0)
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 20;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          cpici.buy_quantity =  0
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 21;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          cpici.make_quantity =  0
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 22;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          cpici.issue_quantity =  0
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 23;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          cpici.unburdened_cost = NVL(NVL(cpici.material_cost,0) + NVL(cpici.resource_cost,0) + NVL(cpici.outside_processing_cost,0),0)
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 24;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          cpici.burden_cost = NVL(NVL(cpici.overhead_cost,0) + NVL(cpici.material_overhead_cost,0),0)
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 25;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          cpici.item_buy_cost = ( SELECT  NVL(SUM(item_buy_cost),0)
          			FROM    cst_pc_cost_det_interface cpcdi
           			WHERE        cpcdi.interface_header_id = x_interface_header_id)
 	   WHERE     cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


l_stmt_num := 26;

	UPDATE       cst_pc_item_cost_interface cpici
           SET          cpici.item_make_cost = ( SELECT  NVL(SUM(item_make_cost),0)
                                        FROM    cst_pc_cost_det_interface cpcdi
                                        WHERE   cpcdi.interface_header_id = x_interface_header_id )
           WHERE        cpici.interface_header_id = x_interface_header_id;

if(SQL%ROWCOUNT = 0) then
        RAISE no_rows_exception;
end if;


EXCEPTION

        WHEN no_rows_exception THEN
                 ROLLBACK;
                x_err_num := -1;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPPOI.derive_costs('
                                || to_char(l_stmt_num)
                                || '): '
                                ||'No rows computed ERROR',1,240);


        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPPOI.derive_costs('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);


END derive_costs;





END CSTPPPOI;


/

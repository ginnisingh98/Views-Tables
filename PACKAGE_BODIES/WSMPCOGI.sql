--------------------------------------------------------
--  DDL for Package Body WSMPCOGI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPCOGI" AS
/* $Header: WSMCOGIB.pls 115.7 2002/11/14 23:02:39 zchen ship $ */
/*===========================================================================

  FUNCTION NAME:	get_alternate_designator

===========================================================================*/

 FUNCTION get_alternate_designator
	(X_co_product_group_id   NUMBER) return varchar2 is

 x_alternate_designator VARCHAR2(10) := NULL;

 BEGIN

	SELECT bbom.alternate_bom_designator
	INTO   x_alternate_designator
	FROM   bom_bill_of_materials bbom,
               bom_inventory_components bic,
               wsm_co_products bcp
	WHERE  bcp.co_product_group_id = x_co_product_group_id
        AND    bcp.component_sequence_id = bic.component_sequence_id
        AND    bic.bill_sequence_id      = bbom.bill_sequence_id
        AND    rownum = 1;

   return(x_alternate_designator);

   EXCEPTION
   WHEN OTHERS THEN
      return(NULL);
   RAISE;

END get_alternate_designator;

/*===========================================================================

  PROCEDURE NAME:   get_coprod_count

===========================================================================*/

PROCEDURE get_coprod_count(x_co_product_group_id   IN     NUMBER,
			 x_count		   IN OUT NOCOPY NUMBER,
                         x_error_code              IN OUT NOCOPY NUMBER,
                         x_error_msg               IN OUT NOCOPY VARCHAR2)
IS

x_progress               VARCHAR2(3) := NULL;

BEGIN

  x_progress := '010';

  SELECT count (*)
  INTO   x_count
  FROM   wsm_co_products
  WHERE  co_product_group_id = x_co_product_group_id
  AND    co_product_id IS NOT NULL;

  x_error_code := 0;

EXCEPTION
 WHEN OTHERS THEN
    x_error_code := sqlcode;
    x_error_msg  := 'WSMPPCPD.get_coprod_count(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);

END get_coprod_count;

/*===========================================================================

  PROCEDURE NAME:   get_bill_comp_sequence

===========================================================================*/

PROCEDURE get_bill_comp_sequence(x_result              IN OUT NOCOPY NUMBER,
                                 x_error_code          IN OUT NOCOPY NUMBER,
                                 x_error_msg           IN OUT NOCOPY VARCHAR2)
IS

x_progress            VARCHAR2(3) := NULL;

BEGIN

  x_progress := '010';

  SELECT bom_inventory_components_s.nextval
  INTO   x_result
  FROM   sys.dual;

  x_error_code := 0;

EXCEPTION
 WHEN OTHERS THEN
    x_error_code := sqlcode;
    x_error_msg  := 'WSMPPCPD.get_bill_comp_sequence(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);

END get_bill_comp_sequence;

/*===========================================================================

  FUNCTION NAME:   get_component_sequence_id

===========================================================================*/

FUNCTION Get_Component_Sequence_Id(p_component_item_id IN NUMBER,
                            p_operation_sequence_num IN VARCHAR2,
                            p_effectivity_date       IN DATE,
                            p_bill_sequence_id       IN NUMBER,
                            x_err_text OUT NOCOPY VARCHAR2 )
RETURN NUMBER
IS
        l_id                          NUMBER;
        ret_code                      NUMBER;
        l_err_text                    VARCHAR2(2000);
BEGIN
	-- commented out by Bala.
	-- June 22nd, 2000.
/*
        select component_sequence_id
        into   l_id
        from   bom_inventory_components
        where  bill_sequence_id = p_bill_sequence_id
        and    component_item_id = p_component_item_id
        and    operation_seq_num = p_operation_sequence_num
        and    effectivity_date = p_effectivity_date;
*/

	/*
	** Bill sequence Id passed is the primary bill sequence id
	** of the co-product(non_primary) which will have the
	** common bill sequence_id (which is the bill sequence Id
	** of the primary co-product ..Remember..Common bill) which
	** only will have the Inventory components.- Bala, June 22nd, 2000.
	*/
        select bic.component_sequence_id
        into   l_id
        from   bom_inventory_components bic,
		bom_bill_of_materials bom
        where  bom.bill_sequence_id = p_bill_sequence_id
	and    bic.bill_sequence_id = bom.common_bill_sequence_id
        and    bic.component_item_id = p_component_item_id
        and    bic.operation_seq_num = p_operation_sequence_num
        and    bic.effectivity_date = p_effectivity_date;

        RETURN l_id;

EXCEPTION

  WHEN OTHERS THEN
    x_err_text := sqlerrm;
    RETURN NULL;

END Get_Component_Sequence_Id;

/*===========================================================================
  FUNCTION NAME:        get_item_name

  DESCRIPTION:          This function does a id to value conversion and
                        returns the item name
===========================================================================*/
FUNCTION Get_Item_Name (p_inventory_item_id     IN NUMBER,
                        p_organization_id       IN NUMBER,
                        x_error_code            IN OUT NOCOPY NUMBER,
                        x_error_msg             IN OUT NOCOPY VARCHAR2)
RETURN VARCHAR2 IS

l_item_name	VARCHAR2(240);

BEGIN

  SELECT concatenated_segments
  INTO l_item_name
  FROM mtl_system_items_kfv
  WHERE inventory_item_id = p_inventory_item_id
  AND   organization_id = p_organization_id;

  x_error_code := 0;
  RETURN l_item_name;

EXCEPTION
  WHEN OTHERS THEN
    x_error_code := sqlcode;
    x_error_msg := sqlerrm;
    RETURN NULL;
END Get_Item_Name;

END;

/

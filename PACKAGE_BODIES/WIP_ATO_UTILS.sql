--------------------------------------------------------
--  DDL for Package Body WIP_ATO_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_ATO_UTILS" as
/* $Header: wipatoub.pls 120.1 2006/03/28 15:58:33 hshu noship $ */

/* *********************************************************************
                        Public Procedures
***********************************************************************/


/***************************************************************************
*  check_wip_supply_type :
*   Description: This function is used to return the type of wip entity that
*                is linked to a given sales order.
*   Input      : Sales order header, line and delivery id.
*   Output     : The output of this function is one of the following
*		 1 = Discrete Job
*                4 = Flow schedule
*                0 = None
*               -1 = Error
***************************************************************************/


PROCEDURE check_wip_supply_type(p_so_header_id    IN NUMBER,
				p_so_line         IN VARCHAR2,
				p_so_delivery     IN VARCHAR2,
				p_org_id          IN NUMBER,
				p_wip_entity_type IN OUT NOCOPY NUMBER,
				p_err_msg         IN OUT NOCOPY VARCHAR2) IS
BEGIN
   p_wip_entity_type := check_wip_supply_type(p_so_header_id,p_so_line,p_so_delivery,p_org_id,-1);
   IF(p_wip_entity_type = -1) THEN
      p_err_msg := 'wipatoub: check_wip_supply_type : SQLERRM: ' || SUBSTR(SQLERRM,1,200);
   END IF;
END check_wip_supply_type;




FUNCTION check_wip_supply_type(p_so_header_id    NUMBER,
			       p_so_line         VARCHAR2,
			       p_so_delivery     VARCHAR2,
			       p_org_id          NUMBER,
			       p_supply_source_id NUMBER := -1)
  RETURN NUMBER IS
x_wip_entity_id NUMBER;
x_wip_entity_type NUMBER;
BEGIN
   x_wip_entity_id := 0;
   x_wip_entity_type := 0;

   /* Check to see if there is a record in mtl_demand corresponding to this
   *  sales order Optionally the supply source id can be provided so that
   *  we don't have to select from MTL_DEMAND.
   */

     IF p_supply_source_id = -1 THEN
	DECLARE
	BEGIN
	   SELECT supply_source_header_id INTO x_wip_entity_id
	     FROM mtl_demand
	     WHERE organization_id = p_org_id
	     AND supply_source_type = 5
	     AND demand_source_header_id = p_so_header_id
	     AND demand_source_line = p_so_line
	     AND Decode(p_so_delivery, NULL, '@@@', demand_source_delivery) = Nvl(p_so_delivery,'@@@')
	     AND demand_source_type = 2
	     AND reservation_type in (2,3)
	     AND ROWNUM = 1;
	EXCEPTION
	   WHEN no_data_found THEN
	      x_wip_entity_id := 0;
	      x_wip_entity_type := 0;
	END;
      ELSE
	      x_wip_entity_id := Nvl(p_supply_source_id,0);
     END IF;

   IF(x_wip_entity_id > 0) THEN
      /* If a row is found in mtl_demand then get its wip entity type. */

      SELECT entity_type INTO x_wip_entity_type
	FROM wip_entities
	WHERE wip_entity_id = x_wip_entity_id;

    ELSE
      /* If no row was found in mtl_demand check interface table for
      *  any flow schedules that haven't been picked up yet
      */

	DECLARE
	BEGIN
	   SELECT transaction_source_id INTO x_wip_entity_id
	     FROM mtl_transactions_interface
	     WHERE organization_id = p_org_id
	     /* Bug fix 4889919 */
	     and transaction_source_type_id = 5
	     /* End of bug fix 4889919 */
	     AND demand_source_header_id = p_so_header_id
	     AND demand_source_line = p_so_line
	     AND Decode(p_so_delivery, NULL, '@@@', demand_source_delivery) = Nvl(p_so_delivery,'@@@')
	     AND flow_schedule = 'Y'
	     AND process_flag = 1
	     AND ROWNUM = 1;
	EXCEPTION
	   WHEN no_data_found THEN
	      x_wip_entity_id := 0;
	      x_wip_entity_type := 0;
	END;

	IF(x_wip_entity_id <> 0) THEN
	   x_wip_entity_type := 4;
	END IF;

   END IF;

   RETURN(x_wip_entity_type);

EXCEPTION
   WHEN OTHERS THEN
      RETURN(-1);
END check_wip_supply_type;



/***************************************************************************
*  get_so_open_qty :
*   Description: This procedure is used to return the quantity in a given
*                sales order that is open for reservation.
*   Input      : Sales order header, line and delivery id.
*   Output     : The output of this function is the quantity open in mtl_demand
*
***************************************************************************/



PROCEDURE get_so_open_qty(p_so_header_id   IN NUMBER,
			  p_so_line        IN VARCHAR2,
			  p_so_delivery    IN VARCHAR2,
			  p_org_id         IN NUMBER,
			  p_qty            IN OUT NOCOPY NUMBER,
			  p_err_msg        IN OUT NOCOPY VARCHAR2) IS
x_qty NUMBER;
BEGIN

   /* get the open quantity from mtl_demand */

   DECLARE
   BEGIN
     SELECT Nvl(primary_uom_quantity,0) INTO x_qty
       FROM mtl_demand
       WHERE organization_id = p_org_id
       AND demand_source_header_id = p_so_header_id
       AND demand_source_line = p_so_line
       AND demand_source_delivery = p_so_delivery
       AND demand_source_type = 2
       AND reservation_type = 1
       AND row_status_flag = 1
       AND parent_demand_id IS NOT null
       AND ((config_status = 20 AND demand_type= 4)
            OR (config_status = 20 AND NVL(demand_type,6) = 6));
   EXCEPTION
      WHEN no_data_found THEN
	 x_qty := 0;
   END;

   p_qty := x_qty;


EXCEPTION
   WHEN OTHERS THEN
      p_qty := 0;
      p_err_msg := 'wipatoub: get_so_open_qty : SQLERRM : ' || SUBSTR(SQLERRM,1,200);
END get_so_open_qty;


END Wip_Ato_Utils;

/

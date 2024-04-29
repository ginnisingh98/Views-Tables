--------------------------------------------------------
--  DDL for Package Body GMO_DISPENSE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_DISPENSE_PVT" AS
/* $Header: GMOVDSPB.pls 120.18.12000000.4 2007/04/19 06:46:45 achawla ship $ */

/* Used in Dispensing BC4J objects to getProduct */
/* Returns batch's primary product number */
FUNCTION GET_PRODUCT_NUMBER(P_BATCH_ID NUMBER) RETURN VARCHAR2
IS
l_return_value Varchar2(240);
CURSOR C_GET_BATCH_PRODUCT IS
SELECT msi.concatenated_segments
  FROM mtl_system_items_vl msi,
       gme_material_details gme
 WHERE gme.organization_id = msi.organization_id
   AND gme.inventory_item_id = msi.inventory_item_id
   AND gme.line_type = 1
   AND gme.line_no = 1
   AND gme.batch_id = p_batch_id;
BEGIN
    OPEN C_GET_BATCH_PRODUCT ;
      FETCH C_GET_BATCH_PRODUCT INTO l_return_value;
    CLOSE C_GET_BATCH_PRODUCT;
    return l_return_value;
END GET_PRODUCT_NUMBER;
/* Returns batch's primary product's description */
FUNCTION GET_PRODUCT_DESCRIPTION(P_BATCH_ID NUMBER) RETURN VARCHAR2
IS
l_return_value Varchar2(240);
CURSOR C_GET_BATCH_PRODUCT IS
SELECT msi.description
  FROM mtl_system_items_vl msi,
       gme_material_details gme
 WHERE gme.organization_id = msi.organization_id
   AND gme.inventory_item_id = msi.inventory_item_id
   AND gme.line_type = 1
   AND gme.line_no = 1
   AND gme.batch_id = p_batch_id;
BEGIN
    OPEN C_GET_BATCH_PRODUCT ;
      FETCH C_GET_BATCH_PRODUCT INTO l_return_value;
    CLOSE C_GET_BATCH_PRODUCT;
    return l_return_value;
END GET_PRODUCT_DESCRIPTION;
/* Used by GET_DISPENSE_DATA  API */
FUNCTION GET_NET_RES_DISPENSED_QTY(P_RESERVATION_ID NUMBER, P_UOM VARCHAR2) RETURN NUMBER
IS
l_return_value NUMBER;
l_total_dispensed_qty NUMBER;
l_total_undispensed_qty NUMBER;
l_undispensed_qty NUMBER;
l_dispensed_qty NUMBER;
CURSOR C_GET_DISPENSES IS
 SELECT inventory_item_id,lot_number, dispensed_qty, dispense_uom, organization_id, dispense_id
   FROM GMO_MATERIAL_DISPENSES
  WHERE MATERIAL_STATUS = 'DISPENSD'
    AND RESERVATION_ID = P_RESERVATION_ID;
CURSOR C_GET_UNDISPENSED_QTY(p_dispense_id NUMBER) IS
  SELECT nvl(sum(nvl(undispensed_qty,0)+ nvl(material_loss,0)),0)
       FROM GMO_MATERIAL_UNDISPENSES
      WHERE dispense_id = p_dispense_id;
 l_dispense_rec C_GET_DISPENSES%ROWTYPE;
BEGIN
  l_total_dispensed_qty := 0;
  l_total_undispensed_qty := 0;
 /* select total dispensed for reservation */
  OPEN C_GET_DISPENSES;
  LOOP
     FETCH C_GET_DISPENSES INTO l_dispense_rec;
     EXIT WHEN C_GET_DISPENSES %NOTFOUND;
     /* get the total of undispensed qty for current dispense id */
     OPEN C_GET_UNDISPENSED_QTY(l_dispense_rec.dispense_id);
       FETCH C_GET_UNDISPENSED_QTY into l_undispensed_qty;
     CLOSE C_GET_UNDISPENSED_QTY;
      IF(l_dispense_rec.dispense_uom <> p_uom) THEN
      /* convert the dispensed qty in p_uom */
      /* It is safe to assume that conversion will not fail because this is an internal
         procedure and will only be called where conversion do exist and p_uom is not null.
         Therefore no need to check the failure (-99999 return value) */
        l_dispensed_qty := inv_convert.inv_um_convert(l_dispense_rec.inventory_item_id,
	                                 l_dispense_rec.lot_number,
	                                 l_dispense_rec.organization_id,
	                                 5,
	                                 l_dispense_rec.dispensed_qty,
	                                 l_dispense_rec.dispense_uom,
	                                 p_uom,
	                                 null,
                                         null);
       /* convert the undispensed qty too */
         IF (l_undispensed_qty > 0) THEN
           l_undispensed_qty := inv_convert.inv_um_convert(l_dispense_rec.inventory_item_id,
                                                           l_dispense_rec.lot_number,
                                                           l_dispense_rec.organization_id,
                                                           5,
                                                           l_undispensed_qty,
                                                           l_dispense_rec.dispense_uom,
                                                           p_uom,
                                                           null,
                                                           null);
         END IF;
      ELSE
         l_dispensed_qty := l_dispense_rec.dispensed_qty;
      END IF;
      l_total_dispensed_qty := l_total_dispensed_qty + l_dispensed_qty;
      l_total_undispensed_qty := l_total_undispensed_qty + l_undispensed_qty;
   END LOOP;
   l_return_value := l_total_dispensed_qty -  l_total_undispensed_qty;
   return l_return_value;
END GET_NET_RES_DISPENSED_QTY;
/* Used by GET_DISPENSE_DATA  API */
FUNCTION GET_NET_MTL_DISPENSED_QTY(P_MATERIAL_DETAIL_ID NUMBER, P_UOM VARCHAR2) RETURN NUMBER
IS
l_return_value NUMBER;
l_mtl_dispensed_quantity NUMBER;
l_mtl_undispensed_quantity NUMBER;
l_undispensed_qty NUMBER;
l_dispensed_qty NUMBER;
CURSOR C_GET_DISPENSES IS
 SELECT inventory_item_id,lot_number, dispensed_qty, dispense_uom, organization_id, dispense_id
   FROM GMO_MATERIAL_DISPENSES
  WHERE MATERIAL_STATUS = 'DISPENSD'
    AND MATERIAL_DETAIL_ID  = P_MATERIAL_DETAIL_ID;
l_dispense_rec C_GET_DISPENSES%ROWTYPE;
CURSOR C_GET_UNDISPENSED_QTY(p_dispense_id NUMBER) IS
  SELECT nvl(sum(nvl(undispensed_qty,0)+ nvl(material_loss,0)),0)
       FROM GMO_MATERIAL_UNDISPENSES
      WHERE dispense_id = p_dispense_id;
BEGIN
 l_mtl_dispensed_quantity := 0;
 l_mtl_undispensed_quantity := 0;
 OPEN C_GET_DISPENSES;
  LOOP
     FETCH C_GET_DISPENSES INTO l_dispense_rec;
     EXIT WHEN C_GET_DISPENSES %NOTFOUND;
       /* get the total of undispensed qty for current dispense id */
       OPEN C_GET_UNDISPENSED_QTY(l_dispense_rec.dispense_id);
        FETCH C_GET_UNDISPENSED_QTY into l_undispensed_qty;
       CLOSE C_GET_UNDISPENSED_QTY;
      /* convert the dispensed qty in p_uom */
       IF(l_dispense_rec.dispense_uom <> p_uom) THEN
      /* It is safe to assume that conversion will not fail because this is an internal
         procedure and will only be called where conversion do exist and p_uom is not null.
         Therefore no need to check the failure (-99999 return value) */
        l_dispensed_qty := inv_convert.inv_um_convert(l_dispense_rec.inventory_item_id,
	                                 l_dispense_rec.lot_number,
	                                 l_dispense_rec.organization_id,
	                                 5,
	                                 l_dispense_rec.dispensed_qty,
	                                 l_dispense_rec.dispense_uom,
	                                 p_uom,
	                                 null,
                                         null);
       /* convert the undispensed qty too */
         IF (l_undispensed_qty > 0) THEN
           l_undispensed_qty := inv_convert.inv_um_convert(l_dispense_rec.inventory_item_id,
                                                           l_dispense_rec.lot_number,
                                                           l_dispense_rec.organization_id,
                                                           5,
                                                           l_undispensed_qty,
                                                           l_dispense_rec.dispense_uom,
                                                           p_uom,
                                                           null,
                                                           null);
         END IF;
      ELSE
         l_dispensed_qty := l_dispense_rec.dispensed_qty;
      END IF;
       l_mtl_dispensed_quantity := l_mtl_dispensed_quantity + l_dispensed_qty;
      l_mtl_undispensed_quantity := l_mtl_undispensed_quantity + l_undispensed_qty;
     END LOOP;
   l_return_value := l_mtl_dispensed_quantity - l_mtl_undispensed_quantity;
   return   l_return_value ;
END GET_NET_MTL_DISPENSED_QTY;
/* Used by GET_DISPENSE_DATA  API */
FUNCTION GET_NET_DISP_DISPENSED_QTY(P_DISPENSE_ID NUMBER) RETURN NUMBER
IS
l_return_value NUMBER;
l_dispensed_qty NUMBER;
l_undispensed_qty NUMBER;
CURSOR C_GET_DISPENSED_QTY IS
  select dispensed_qty l_dispensed_qty
          from gmo_material_dispenses
    where  dispense_id = p_dispense_id
      and material_status = 'DISPENSD';
CURSOR C_GET_UNDISPENSED_QTY IS
  SELECT nvl(sum(nvl(undispensed_qty,0)+ nvl(material_loss,0)),0)
    from gmo_material_undispenses u  , gmo_material_dispenses d
   where d.dispense_id = p_dispense_id
     and d.dispense_id = u.dispense_id(+)
     and d.material_status = 'DISPENSD';
BEGIN
   l_return_value := null;
   l_dispensed_qty := 0;
   l_undispensed_qty :=0;
    OPEN C_GET_DISPENSED_QTY;
    FETCH C_GET_DISPENSED_QTY into l_dispensed_qty;
    CLOSE C_GET_DISPENSED_QTY;
    if(l_dispensed_qty = 0) then
       return l_dispensed_qty;
    end if;
    /* select total undispensed for material line */
    OPEN C_GET_UNDISPENSED_QTY;
    FETCH C_GET_UNDISPENSED_QTY into l_undispensed_qty;
    CLOSE C_GET_UNDISPENSED_QTY;
    if(l_undispensed_qty = 0 ) then
      return l_dispensed_qty ;
    end if;
    l_return_value  := (l_dispensed_qty - l_undispensed_qty);
    return l_return_value;
END GET_NET_DISP_DISPENSED_QTY;
/* Used by Dispensing BC4J objects (MaterialListVORowImpl.java) to get dispensing related information */
-- Kiosk : Start
PROCEDURE GET_DISPENSE_DATA (P_RESERVATION_ID NUMBER,
                             P_INVENTORY_ITEM_ID NUMBER,
                             P_ORGANIZATION_ID NUMBER,
                             P_RECIPE_ID NUMBER ,
          	                 P_MATERIAL_DETAILS_ID NUMBER,
                             P_RESERVATION_UOM VARCHAR2,
                             P_RESERVED_QUANTITY NUMBER,
		             P_PLAN_QUANTITY NUMBER,
		             P_PLAN_UOM VARCHAR2,
		             P_LOT_NUMBER VARCHAR2,
                             P_SHOW_IN_TOLERANCE_DATA VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.YES,
		             X_DISPENSE_UOM OUT NOCOPY VARCHAR2,
		             X_DISPENSE_CONFIG_ID OUT NOCOPY NUMBER,
		             X_RESERVED_QUANTITY OUT NOCOPY NUMBER,
		  	     X_PENDING_DISPENSE_QUANTITY OUT NOCOPY NUMBER,
		  	     X_MAX_ALLOWED_QUANTITY OUT NOCOPY NUMBER,
		  	     X_MIN_ALLOWED_QUANTITY OUT NOCOPY NUMBER,
		  	     X_INSTRUCTION_ENTITY_DEF_KEY OUT NOCOPY VARCHAR2,
		  	     X_PLAN_UOM_CONVERTIBLE OUT NOCOPY VARCHAR2,
		  	     X_RESERVATION_UOM_CONVERTIBLE OUT NOCOPY VARCHAR2,
		  	     X_SECURITY_FLAG OUT NOCOPY VARCHAR2
                            )
IS
l_dispense_config_rec GMO_DISPENSE_CONFIG%ROWTYPE;
l_mtl_dispensed_quantity NUMBER;
l_mtl_undispensed_quantity NUMBER;
l_net_dispensed_quantity NUMBER;
l_net_mtl_dispensed_quantity NUMBER;
l_planned_quantity NUMBER;
l_reservation_quantity NUMBER;
l_mtl_reserved_qty NUMBER;
l_dispense_uom VARCHAR(10);
BEGIN
     -- ER: 4575836 : Ends
   /* Get the applicable dispense configuration data */
       X_INSTRUCTION_ENTITY_DEF_KEY := null;
     /* Bug 4946534 : Starts : Commenting existing code
       GMO_DISPENSE_SETUP_PVT.GET_DISPENSE_CONFIG(P_INVENTORY_ITEM_ID => P_INVENTORY_ITEM_ID,
	                   P_ORGANIZATION_ID => P_ORGANIZATION_ID,
			   P_RECIPE_ID => P_RECIPE_ID,
			   X_DISPENSE_CONFIG =>l_dispense_config_rec,
			   X_INSTRUCTION_DEFINITION_KEY => X_INSTRUCTION_ENTITY_DEF_KEY);
     /* Bug 4946534 : Ends : Commenting existing code */
     /* Bug 4946534 : Starts : New API Call to get instance*/
     -- Get the Dispense Setup Record for the given material line. This API will
     --search in dispense setup instances and return config records if exists otherwise null.
       GMO_DISPENSE_SETUP_PVT.GET_DISPENSE_CONFIG_INST(P_ENTITY_NAME => GMO_DISPENSE_GRP.G_MATERIAL_LINE_ENTITY,
                                                       P_ENTITY_KEY => P_MATERIAL_DETAILS_ID,
                                                       X_DISPENSE_CONFIG => l_dispense_config_rec,
                                                       X_INSTRUCTION_DEFINITION_KEY => X_INSTRUCTION_ENTITY_DEF_KEY);
      IF(l_dispense_config_rec.config_id is null ) THEN
         RETURN;
      END IF;
      X_DISPENSE_UOM := l_dispense_config_rec.dispense_uom;
      l_dispense_uom := x_dispense_uom;

     X_DISPENSE_CONFIG_ID := l_dispense_config_rec.config_id;
  -- change for kiosk : start
      X_SECURITY_FLAG := l_dispense_config_rec.SECURECODE_REQUIRED_FLAG;
        -- change for kiosk : End
      l_mtl_reserved_qty :=  inv_convert.inv_um_convert(p_inventory_item_id,
                                 p_lot_number,
                                 p_organization_id,
                                 5,
                                 P_RESERVED_QUANTITY,
                                 P_reservation_uom,
                                 l_dispense_uom,
                                 null,
                                 null);

    if(l_mtl_reserved_qty = -99999) then
      X_RESERVATION_UOM_CONVERTIBLE := FND_API.G_FALSE;
    else
      X_RESERVATION_UOM_CONVERTIBLE := FND_API.G_TRUE;
    end if ;
    X_RESERVED_QUANTITY :=  l_mtl_reserved_qty;
   l_net_mtl_dispensed_quantity  := GET_NET_MTL_DISPENSED_QTY(P_MATERIAL_DETAILS_ID, l_dispense_uom);
   l_planned_quantity := inv_convert.inv_um_convert(p_inventory_item_id,
                                 p_lot_number,
                                 p_organization_id,
                                 5,
                                 p_plan_quantity,
                                 p_plan_uom,
                                 l_dispense_uom,
                                 null,
                                 null);
   IF (l_planned_quantity = -99999) THEN
      X_PLAN_UOM_CONVERTIBLE := FND_API.G_FALSE;
   else
      X_PLAN_UOM_CONVERTIBLE := FND_API.G_TRUE;
   END IF;
   IF (l_planned_quantity = -99999 OR l_mtl_reserved_qty = -99999) THEN
       X_PENDING_DISPENSE_QUANTITY := -99999; -- Make this row as dispense required
       X_MAX_ALLOWED_QUANTITY := 0;
       X_MIN_ALLOWED_QUANTITY  := 0;
     Return;
   END IF;
  -- Bug 5667543 : Kiosk : Start
 --   X_PENDING_DISPENSE_QUANTITY := least(l_planned_quantity, X_RESERVED_QUANTITY) - l_net_mtl_dispensed_quantity ;
        l_net_dispensed_quantity := GET_NET_RES_DISPENSED_QTY(p_reservation_id, l_dispense_uom);

    	IF ((l_planned_quantity - l_net_mtl_dispensed_quantity) >= (l_mtl_reserved_qty - l_net_dispensed_quantity)) THEN
             X_PENDING_DISPENSE_QUANTITY :=  l_mtl_reserved_qty - l_net_dispensed_quantity;
          ELSE
             X_PENDING_DISPENSE_QUANTITY  := l_planned_quantity - l_net_mtl_dispensed_quantity;
      END IF;


  -- Bug 5667543 : Kiosk : End
   X_MAX_ALLOWED_QUANTITY := X_PENDING_DISPENSE_QUANTITY;
   X_MIN_ALLOWED_QUANTITY  := X_PENDING_DISPENSE_QUANTITY;
   IF(l_dispense_config_rec.Tolerance_type = 'Q') THEN
     IF (l_dispense_config_rec.low_tolerance is not null) then
       X_MIN_ALLOWED_QUANTITY := X_PENDING_DISPENSE_QUANTITY - l_dispense_config_rec.low_tolerance;
     end if;
     if(l_dispense_config_rec.high_tolerance is not null) then
       X_MAX_ALLOWED_QUANTITY := X_PENDING_DISPENSE_QUANTITY + l_dispense_config_rec.high_tolerance;
     end if;
   ELSE
     if(l_dispense_config_rec.low_tolerance is not null) then
        X_MIN_ALLOWED_QUANTITY := X_PENDING_DISPENSE_QUANTITY - ((P_PLAN_QUANTITY/100) * l_dispense_config_rec.low_tolerance);
     end if;
      if(l_dispense_config_rec.high_tolerance is not null) then
       X_MAX_ALLOWED_QUANTITY := X_PENDING_DISPENSE_QUANTITY + ((P_PLAN_QUANTITY/100) * l_dispense_config_rec.high_tolerance);
     end if;
   END IF;
   X_MAX_ALLOWED_QUANTITY  :=  greatest( least(X_MAX_ALLOWED_QUANTITY , (X_RESERVED_QUANTITY - L_NET_DISPENSED_QUANTITY)),0);
   X_MIN_ALLOWED_QUANTITY := greatest(X_MIN_ALLOWED_QUANTITY, 0);
   -- ER 4575836 : Starts
   IF ( P_SHOW_IN_TOLERANCE_DATA = GMO_CONSTANTS_GRP.NO) THEN
       IF (X_MIN_ALLOWED_QUANTITY = 0 OR X_PENDING_DISPENSE_QUANTITY < X_MIN_ALLOWED_QUANTITY) THEN
             X_PENDING_DISPENSE_QUANTITY := 0;
       END IF;
   END IF;
   -- ER 4575836 : Ends
END GET_DISPENSE_DATA;
-- Kiosk : End
/* Used MaterialListVO.xml */
FUNCTION IS_DISPENSE_REQUIRED(P_RESERVATION_ID NUMBER,
                              P_INVENTORY_ITEM_ID NUMBER,
		   	      P_ORGANIZATION_ID   NUMBER,
                              P_RECIPE_ID NUMBER ,
                              P_MATERIAL_DETAILS_ID NUMBER,
                              P_RESERVED_QUANTITY NUMBER,
                              P_RESERVATION_UOM VARCHAR2,
                              P_PLAN_QUANTITY NUMBER,
                              P_PLAN_UOM VARCHAR2,
                              P_LOT_NUMBER VARCHAR2,
                              P_SHOW_IN_TOLERANCE_DATA VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.YES
                             ) RETURN VARCHAR2
IS
l_DISPENSE_UOM VARCHAR2(10);
l_DISPENSE_CONFIG_ID NUMBER;
l_RESERVED_QUANTITY NUMBER;
l_PENDING_DISPENSE_QUANTITY NUMBER;
l_MAX_ALLOWED_QUANTITY NUMBER;
l_MIN_ALLOWED_QUANTITY NUMBER;
l_INSTRUCTION_ENTITY_DEF_KEY VARCHAR2(20);
l_plan_uom_converted VARCHAR2(1);
l_revervation_uom_converted VARCHAR2(1);
l_security_flag varchar2(1);
BEGIN
 -- change for kIosk : start
  GET_DISPENSE_DATA( P_RESERVATION_ID =>P_RESERVATION_ID ,
                     P_INVENTORY_ITEM_ID => P_INVENTORY_ITEM_ID ,
		     P_ORGANIZATION_ID   => P_ORGANIZATION_ID,
                     P_RECIPE_ID => P_RECIPE_ID ,
                     P_MATERIAL_DETAILS_ID => P_MATERIAL_DETAILS_ID ,
                     P_RESERVED_QUANTITY => P_RESERVED_QUANTITY ,
                     P_RESERVATION_UOM => P_RESERVATION_UOM,
                     P_PLAN_QUANTITY => P_PLAN_QUANTITY,
                     P_PLAN_UOM => P_PLAN_UOM,
                     P_LOT_NUMBER  =>  P_LOT_NUMBER,
                     P_SHOW_IN_TOLERANCE_DATA => P_SHOW_IN_TOLERANCE_DATA,
                     X_DISPENSE_UOM => l_DISPENSE_UOM ,
                     X_DISPENSE_CONFIG_ID => l_DISPENSE_CONFIG_ID,
                     X_RESERVED_QUANTITY => l_RESERVED_QUANTITY ,
                     X_PENDING_DISPENSE_QUANTITY => l_PENDING_DISPENSE_QUANTITY ,
                     X_MAX_ALLOWED_QUANTITY => l_MAX_ALLOWED_QUANTITY ,
                     X_MIN_ALLOWED_QUANTITY => l_MIN_ALLOWED_QUANTITY ,
                     X_INSTRUCTION_ENTITY_DEF_KEY=> l_INSTRUCTION_ENTITY_DEF_KEY,
                     X_PLAN_UOM_CONVERTIBLE => l_plan_uom_converted,
                     X_RESERVATION_UOM_CONVERTIBLE => l_revervation_uom_converted,
                     X_SECURITY_FLAG =>l_security_flag);
                      -- change for kIosk : End
  IF ( l_PENDING_DISPENSE_QUANTITY > 0 OR l_PENDING_DISPENSE_QUANTITY = -99999) THEN
    return FND_API.G_TRUE;
  END IF;
  return FND_API.G_FALSE;
END IS_DISPENSE_REQUIRED;
/* Used by Dispesnig Bc4J objects to get reverse dispense related information */
-- Kiosk : Start
PROCEDURE GET_REVERSE_DISPENSE_DATA(P_DISPENSE_ID IN NUMBER,
                                    X_MIN_ALLOWED_QTY OUT NOCOPY NUMBER,
				    X_MAX_ALLOWED_QTY OUT NOCOPY NUMBER,
				    X_CONFIG_ID OUT NOCOPY NUMBER,
				    X_INSTRUCTION_ENTITY_DEF_KEY OUT NOCOPY VARCHAR2,
				    X_SECURITY_FLAG OUT NOCOPY VARCHAR2)
IS
l_inventory_item_id NUMBER;
l_organization_id NUMBER;
l_material_details_id NUMBER;
l_dispense_config_rec GMO_DISPENSE_CONFIG%ROWTYPE;
l_net_dispensed_quantity NUMBER;
CURSOR C_GET_DISP_DETAILS IS
 SELECT GMO.MATERIAL_DETAIL_ID,  GMO.INVENTORY_ITEM_ID, GMO.ORGANIZATION_ID
   FROM GMO_MATERIAL_DISPENSES GMO
  WHERE GMO.DISPENSE_ID = P_DISPENSE_ID;
l_GET_DISP_DETAILS_REC C_GET_DISP_DETAILS%ROWTYPE;
BEGIN
   X_INSTRUCTION_ENTITY_DEF_KEY := null;
   X_CONFIG_ID := null;
   -- Get the recipe id for the given dispense id
   OPEN C_GET_DISP_DETAILS;
   FETCH C_GET_DISP_DETAILS into l_GET_DISP_DETAILS_REC;
      l_inventory_item_id := l_GET_DISP_DETAILS_REC.INVENTORY_ITEM_ID;
      l_organization_id := l_GET_DISP_DETAILS_REC.ORGANIZATION_ID;
      l_material_details_id := l_GET_DISP_DETAILS_REC.MATERIAL_DETAIL_ID;
   CLOSE C_GET_DISP_DETAILS;
   IF(l_inventory_item_id is null) THEN
     return;
   END IF;
   l_net_dispensed_quantity := GET_NET_DISP_DISPENSED_QTY(P_DISPENSE_ID);
   /* Bug 4946534: Starts. Replacing Dispense Seup API with new one to get
      dispense config row based on instance table. */
   GMO_DISPENSE_SETUP_PVT.GET_DISPENSE_CONFIG_INST(P_ENTITY_NAME => GMO_DISPENSE_GRP.G_MATERIAL_LINE_ENTITY,
			   P_ENTITY_KEY => l_material_details_id,
			   X_DISPENSE_CONFIG =>l_dispense_config_rec,
			   X_INSTRUCTION_DEFINITION_KEY => X_INSTRUCTION_ENTITY_DEF_KEY);
    /*  Bug 4946534: Ends */
      IF(l_dispense_config_rec.config_id is null ) THEN
         X_MIN_ALLOWED_QTY := 0;
	 X_MAX_ALLOWED_QTY := l_net_dispensed_quantity;
         RETURN;
      END IF;
      X_CONFIG_ID := l_dispense_config_rec.CONFIG_ID;
     -- change for kiosk : start
      X_SECURITY_FLAG := l_dispense_config_rec.SECURECODE_REQUIRED_FLAG;

   -- no partial reverse dispense check is required as per new requirement so
   -- min qty would always be matching with dispensed qty to mimic 0 tolerance
        X_MIN_ALLOWED_QTY := 0;
        X_MAX_ALLOWED_QTY := l_net_dispensed_quantity;
     /*
      IF(l_dispense_config_rec.Tolerance_type = 'Q') THEN
        X_MIN_ALLOWED_QTY := l_net_dispensed_quantity - l_dispense_config_rec.low_tolerance;
        X_MAX_ALLOWED_QTY := l_net_dispensed_quantity;
     ELSE
        X_MIN_ALLOWED_QTY := l_net_dispensed_quantity - ((l_net_dispensed_quantity/100) * l_dispense_config_rec.low_tolerance);
        X_MAX_ALLOWED_QTY := l_net_dispensed_quantity ;
      END IF;
   X_MIN_ALLOWED_QTY := greatest(X_MIN_ALLOWED_QTY, 0); -- must be a positive quantity
   */
END GET_REVERSE_DISPENSE_DATA;
-- Kiosk : End
/* Used by group API */
PROCEDURE GET_MATERIAL_DISPENSE_DATA(p_material_detail_id IN NUMBER,
                                     x_dispense_data OUT NOCOPY GME_COMMON_PVT.reservations_tab)
IS
CURSOR C_GET_RESERVATIONS IS
 SELECT res.*
   FROM MTL_RESERVATIONS res,
        gme_material_Details gmd,
        gme_batch_header gbh
  WHERE res.demand_source_type_id = 5
   and res.inventory_item_id = gmd.inventory_item_id
   and  GBH.BATCH_ID = GMD.BATCH_ID
   and GBH.BATCH_STATUS in (1,2)
   and  RES.DEMAND_SOURCE_HEADER_ID = GBH.BATCH_ID
   and res.demand_source_line_id = p_material_detail_id
   and gmd.line_type = -1
   and gme_api_grp.IS_RESERVATION_FULLY_SPECIFIED(res.reservation_id) = 1;
CURSOR C_GET_DISPENSES(p_reservation_id NUMBER) IS
  SELECT Dispense_id,
         dispensed_qty,
	 dispense_uom,
	 GMO_DISPENSE_PVT.GET_NET_DISP_DISPENSED_QTY(dispense_id) net_dispensed_qty
  from gmo_material_dispenses
  WHERE reservation_id = p_reservation_id
    and material_status = 'DISPENSD'
    and   GMO_DISPENSE_PVT.GET_NET_DISP_DISPENSED_QTY(dispense_id) > 0;
l_reservation_record mtl_reservations%ROWTYPE;
l_dispense_record C_GET_DISPENSES%ROWTYPE;
l_result_record mtl_reservations%ROWTYPE;
l_Pending_reservations_tab GME_COMMON_PVT.reservations_tab;
CURSOR C_GET_MATERIAL_LINE IS
  SELECT gmd.organization_id
    FROM gme_material_details gmd
   WHERE gmd.material_detail_id = p_material_detail_id;
l_material_line C_GET_MATERIAL_LINE%ROWTYPE;
RES_UOM_CONV_EXCEPTION EXCEPTION;
DISP_NOT_REQ_EXCEPTION EXCEPTION;
NO_MATERIAL_LINE_EXCEPTION  EXCEPTION;
INSTRUNCTION_EXCEPTION EXCEPTION;
l_dispense_uom VARCHAR2(10);
l_dispense_config_row GMO_DISPENSE_CONFIG%ROWTYPE;
l_organization_id NUMBER;
l_RESERVED_QUANTITY NUMBER;
l_DISPENSE_CONFIG_ID NUMBER;
l_MAX_ALLOWED_QUANTITY  NUMBER;
l_MIN_ALLOWED_QUANTITY NUMBER;
l_INSTRUCTION_ENTITY_DEF_KEY VARCHAR2(100);
l_revervation_uom_converted VARCHAR2(1);
l_reserved_qty NUMBER;
l_reserved_qty_in_sec_UOM NUMBER;
l_net_disp_qty_in_prim_UOM NUMBER;
l_instr_def_key VARCHAR2(40);
i integer;
j integer;
k integer;
l_lot_number varchar2(80);
L_TEMP_DISP_QTY NUMBER;
l_entity_type     CONSTANT VARCHAR2(30) :='DISPENSE';
l_entity_name     CONSTANT VARCHAR2(30) :='DISPENSE_ITEM';
l_disp_conf_entity_name CONSTANT VARCHAR2(30) :='MATERIAL_DETAILS_ID';
L_TOTAL_INSTRUCTIONS NUMBER;
L_OPTIONAL_PENDING_INSTR NUMBER;
L_MANDATORY_PENDING_INSTR NUMBER;
L_INSTRUCTION_PENDING VARCHAR2(5);
l_return_status varchar2(10);
l_msg_count NUMBER;
l_msg_data VARCHAR2(4000);
BEGIN
    -- get the material line
    OPEN C_GET_MATERIAL_LINE;
    FETCH C_GET_MATERIAL_LINE INTO l_material_line;
    CLOSE C_GET_MATERIAL_LINE;
    -- raise exception if there is no material line
    IF(l_material_line.organization_id is null) THEN
        RAISE NO_MATERIAL_LINE_EXCEPTION;
    ELSE
      l_organization_id := l_material_line.organization_id;
    END IF;
    -- now that material line is found, get the dispense configuration for the same.
    i := 1;
    j := 1;
    -- Bug 4946534: Starts.   Replaced GET_DISPENSE_CONFIG with GET_DISPENSE_CONFIG_INST
    ---  This API would look into instances table and return the instantiated
    --   configuration.
    GMO_DISPENSE_SETUP_PVT.GET_DISPENSE_CONFIG_INST(P_ENTITY_NAME=> GMO_DISPENSE_GRP.G_MATERIAL_LINE_ENTITY,
                             P_ENTITY_KEY=> p_material_detail_id ,
                             X_DISPENSE_CONFIG => l_dispense_config_row,
                             X_INSTRUCTION_DEFINITION_KEY  => l_instr_def_key);
    -- Bug 4946534: Ends
    if(l_dispense_config_row.config_id is null) then
          RAISE DISP_NOT_REQ_EXCEPTION;
    end if;
    l_dispense_uom := l_dispense_config_row.dispense_uom;
    /* Start with all reservations for the given material line */
    OPEN C_GET_RESERVATIONS;
    LOOP
     FETCH C_GET_RESERVATIONS INTO l_reservation_record;
     EXIT WHEN C_GET_RESERVATIONS%NOTFOUND;
           l_reserved_qty := inv_convert.inv_um_convert(l_reservation_record.inventory_item_id,
                                                        l_reservation_record.lot_number,
                                                        l_organization_id,
                                                        5,
                                                        l_reservation_record.primary_reservation_quantity,
                                                        l_reservation_record.primary_uom_code,
                                                        l_dispense_uom,
                                                        null,
                                                        null
                                                       );
	            /* Check Reservation UOM */
                        IF(l_reserved_qty = -99999) THEN
		              RAISE RES_UOM_CONV_EXCEPTION ;
              		END IF;
           /* Select dispensed rows that can be consumed for the given reservations */
            OPEN 	C_GET_DISPENSES(l_reservation_record.reservation_id) ;
            LOOP
        	    FETCH C_GET_DISPENSES into l_dispense_record;
           	    EXIT WHEN C_GET_DISPENSES%NOTFOUND;
                     l_result_record := l_reservation_record;
			   /* calculate pending consume quantity */
			   -- SP: 12/20/2005  Changed the condition
			   IF(l_dispense_record.dispense_uom = l_reservation_record.reservation_uom_code) THEN
			      l_reserved_qty := l_reserved_qty - l_dispense_record.net_dispensed_qty;
			      l_result_record.reservation_quantity := l_dispense_record.net_dispensed_qty; -- To be consumed for this dispense
			   ELSE
                        -- SP: 12/20/2005
                        -- Following Code was handling UOM change from Dispense row to dispense row with
                        -- Static Setup for a batch functionality implementation this is nolonger need
                        -- following code is modified to address additional Qty filed population
                        -- of reservation record (Bug 4892510)
			      l_temp_disp_qty := inv_convert.inv_um_convert(l_reservation_record.inventory_item_id,
                                                        l_reservation_record.lot_number,
                                                        l_organization_id,
                                                        5,
                                                        l_dispense_record.net_dispensed_qty,
                                                        l_dispense_record.dispense_uom,
                                                        l_reservation_record.reservation_uom_code,
                                                        null,
                                                        null
                                                       );
                         l_reserved_qty := l_reserved_qty - l_dispense_record.net_dispensed_qty;
				 l_result_record.reservation_quantity := l_temp_disp_qty; -- To be consumed for this dispense
			     END IF;
                       -- push the dispensed qty in secondary UOM also
                       If (l_reservation_record.SECONDARY_RESERVATION_QUANTITY is not null AND
                               l_reservation_record.SECONDARY_UOM_CODE is not null) THEN
                            l_reserved_qty_in_sec_UOM := inv_convert.inv_um_convert(l_reservation_record.inventory_item_id,
                                                                   l_reservation_record.lot_number,
                                                                   l_organization_id,
                                                                   5,
                                                                   l_dispense_record.net_dispensed_qty,
                                                                   l_dispense_uom,
                                                                   l_reservation_record.SECONDARY_UOM_CODE,
                                                                   null,
                                                                   null);
                             IF(l_reserved_qty_in_sec_UOM <> -9999 ) THEN
                                -- push secondary reservation quantity
                                l_result_record.SECONDARY_RESERVATION_QUANTITY := l_reserved_qty_in_sec_UOM;
                                -- push secondary detailed quantity
                                l_result_record.secondary_detailed_quantity     := l_reserved_qty_in_sec_UOM;
                             END IF;
                          END IF;
                         -- push primary reservation quantity
                         IF(l_reservation_record.primary_uom_code is not null ) then
                            l_net_disp_qty_in_prim_UOM := inv_convert.inv_um_convert(l_reservation_record.inventory_item_id,
                                                                         l_reservation_record.lot_number,
                                                                         l_organization_id,
                                                                         5,
                                                                         l_dispense_record.net_dispensed_qty,
                                                                         l_dispense_uom,
                                                                         l_reservation_record.primary_uom_code,
                                                                         null,
                                                                         null);
                             IF(l_net_disp_qty_in_prim_UOM <> -9999) THEN
                                  l_result_record.primary_reservation_quantity := l_net_disp_qty_in_prim_UOM;
                             END IF;
                         END IF;
                         -- push detailed quantity
                         l_result_record.detailed_quantity :=  l_result_record.reservation_quantity;
                         -- push serial reservation quantity
                         l_result_record.serial_reservation_quantity := l_result_record.reservation_quantity;
                         -- SP: 12/20/2005
                         -- Following UOM Code assignment code is commented as
                         -- Quantity need to be returned in reservation UOM.
				 --l_result_record.reservation_uom_code := l_dispense_uom;
				 l_result_record.external_source_line_id := l_dispense_record.dispense_id;
                          -- Bug 4959469: Starts
                          -- Make external_source_line_id as -1 if there are any mandatory instruction
                          --- pending for this dispense record.
                             GMO_INSTRUCTION_PVT.HAS_PENDING_INSTRUCTIONS(P_ENTITY_NAME =>l_entity_name,
                                                   P_ENTITY_KEY =>l_dispense_record.dispense_id,
                                                   P_INSTRUCTION_TYPE =>l_entity_type,
                                                   X_INSTRUCTION_PENDING =>L_INSTRUCTION_PENDING,
                                                   X_TOTAL_INSTRUCTIONS => L_TOTAL_INSTRUCTIONS,
                                                   X_OPTIONAL_PENDING_INSTR =>L_OPTIONAL_PENDING_INSTR,
                                                   X_MANDATORY_PENDING_INSTR =>L_MANDATORY_PENDING_INSTR,
                                                   X_RETURN_STATUS =>l_return_status,
                                                   X_MSG_COUNT =>l_msg_count,
                                                  X_MSG_DATA  =>l_msg_data);
                               IF(l_return_status<> FND_API.G_RET_STS_SUCCESS ) THEN
                                RAISE INSTRUNCTION_EXCEPTION;
                               END IF;
                               IF (L_MANDATORY_PENDING_INSTR > 0) THEN
                                    l_result_record.external_source_line_id := -1;
                               END IF;
                           -- Bug 4959469 : Ends
				 x_dispense_data(i) := l_result_record;
				 i:= i+1;
			END LOOP; /* End loop for dispense records */
			CLOSE C_GET_DISPENSES;
                  if(l_reserved_qty > 0) then
		          -- SP: 12/20/2005
                      -- We need convert reservation qty from dispense UOM to reservation UOM
                      -- (Bug 4892510)
			   l_reserved_qty := inv_convert.inv_um_convert(l_reservation_record.inventory_item_id,
                                                   l_reservation_record.lot_number,
                                                   l_organization_id,
                                                   5,
                                                   l_reserved_qty,
                                                   l_dispense_uom,
                                                   l_reservation_record.reservation_uom_code ,
                                                   null,
                                                   null
                                                   );
               	    l_reservation_record.reservation_quantity  :=  l_reserved_qty;
                               -- SP: 12/20/2005
                               -- Following UOM Code assignment code is commented as
                               -- Quantity need to be returned in reservation UOM.
        	         -- l_reservation_record.reservation_uom_code := l_dispense_uom;
                     -- push primary reservation quantity
                          IF (l_reservation_record.primary_uom_code is not null ) then
                             l_net_disp_qty_in_prim_UOM := inv_convert.inv_um_convert(l_reservation_record.inventory_item_id,
                                                           l_reservation_record.lot_number,
                                                           l_organization_id,
                                                           5,
                                                           l_reserved_qty,
                                                           l_dispense_uom,
                                                           l_reservation_record.primary_uom_code,
                                                           null,
                                                           null);
                             IF(l_net_disp_qty_in_prim_UOM <> -9999) THEN
                                  l_reservation_record.primary_reservation_quantity := l_net_disp_qty_in_prim_UOM;
                             END IF;
                          END IF;
                          -- push detailed quantity
                          l_reservation_record.detailed_quantity :=  l_reservation_record.reservation_quantity;
                          -- push serial reservation quantity
                          l_reservation_record.serial_reservation_quantity := l_reservation_record.reservation_quantity;
                          If(l_reservation_record.SECONDARY_RESERVATION_QUANTITY is not null AND
                               l_reservation_record.SECONDARY_UOM_CODE is not null) THEN
                               l_reserved_qty_in_sec_UOM := inv_convert.inv_um_convert(l_reservation_record.inventory_item_id,
                                                                   l_reservation_record.lot_number,
                                                                   l_organization_id,
                                                                   5,
                                                                   l_reserved_qty,
                                                                   l_dispense_uom,
                                                                   l_reservation_record.SECONDARY_UOM_CODE,
                                                                   null,
                                                                   null);
                                IF (l_reserved_qty_in_sec_UOM <> -9999 ) THEN
                                   l_reservation_record.SECONDARY_RESERVATION_QUANTITY := l_reserved_qty_in_sec_UOM;
                                   -- push secondary detailed quantity
                                   l_reservation_record.secondary_detailed_quantity    := l_reserved_qty_in_sec_UOM;
                                END IF;
                          END IF;
                          l_pending_reservations_tab(j) := l_reservation_record;
                          j := j+1;
                  end if;
		END LOOP; /* End loop for reservations records */
		CLOSE C_GET_RESERVATIONS;
                /* Append the pending reservation in the end to x_dispense_data.  */
                IF(j>1) THEN
                    FOR K IN 1..J-1 LOOP
                      x_dispense_data(i) := l_pending_reservations_tab(k);
                      i := i+1;
                    END LOOP;
                END IF;
EXCEPTION
 WHEN INSTRUNCTION_EXCEPTION THEN
     FND_MESSAGE.SET_ENCODED(l_msg_data);
     APP_EXCEPTION.RAISE_EXCEPTION;
 WHEN 	NO_MATERIAL_LINE_EXCEPTION THEN
  FND_MESSAGE.SET_NAME('GMO','GMO_DISP_NO_MTL_LINE_ERR');
    if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                       'gmo.plsql.GMO_DISPENSE_GRP.GET_MATERIAL_DISPENSE_DATA',
                       FALSE
                      );
     end if;
    RAISE;
 WHEN DISP_NOT_REQ_EXCEPTION THEN
 FND_MESSAGE.SET_NAME('GMO','GMO_DISP_DISPENSE_NOT_REQ_ERR');
     if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                        'gmo.plsql.GMO_DISPENSE_GRP.GET_MATERIAL_DISPENSE_DATA',
                        FALSE
                       );
      end if;
    RAISE;
 WHEN 	RES_UOM_CONV_EXCEPTION THEN
 FND_MESSAGE.SET_NAME('GMO','GMO_DISP_RES_CONV_ERR');
     if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                        'gmo.plsql.GMO_DISPENSE_GRP.GET_MATERIAL_DISPENSE_DATA',
                        FALSE
                       );
      end if;
    RAISE;
END GET_MATERIAL_DISPENSE_DATA;
/* Returns last dispense Id, used in dispense instructions checks */
FUNCTION GET_LATEST_DISPENSE_ID (p_batch_id IN NUMBER) RETURN NUMBER
IS
l_return_value NUMBER;
  -- change for kiosk : start
CURSOR C_GET_MAX_DISPENSE_ID IS
   SELECT MAX(dispense_id)
    FROM GMO_MATERIAL_DISPENSES
       WHERE BATCH_ID = p_batch_id;
         -- change for kiosk : End
BEGIN
   l_return_value := null;
   OPEN C_GET_MAX_DISPENSE_ID;
    FETCH C_GET_MAX_DISPENSE_ID into l_return_value;
   CLOSE C_GET_MAX_DISPENSE_ID;
   return l_return_value;
END;
/* Returns last reverse dispense Id, used in dispense instructions checks */
FUNCTION GET_LATEST_REVERSE_DISPENSE_ID (p_dispense_id IN NUMBER) RETURN NUMBER
IS
l_return_value NUMBER;
CURSOR C_GET_LATEST_UNDISPENSE_ID IS
   SELECT MAX(undispense_id)
    FROM GMO_MATERIAL_UNDISPENSES
   WHERE DISPENSE_ID = p_dispense_id;
BEGIN
   l_return_value := null;
   OPEN C_GET_LATEST_UNDISPENSE_ID;
    FETCH C_GET_LATEST_UNDISPENSE_ID into l_return_value;
   CLOSE C_GET_LATEST_UNDISPENSE_ID;
   return l_return_value;
END;
/* Dispese wrapper for label request */
FUNCTION GET_LABEL_REQUEST_ID (p_entity_id NUMBER,
                               p_context_param_names FND_TABLE_OF_VARCHAR2_255,
                               p_context_param_values FND_TABLE_OF_VARCHAR2_255,
                               p_label_string VARCHAR2,
                               p_entity_type VARCHAR2) RETURN NUMBER
IS
l_label_request_id NUMBER;
L_CONTEXT GMO_LABEL_MGMT_GRP.CONTEXT_TABLE;
L_RETURN_STATUS VARCHAR2(1);
L_MSG_COUNT integer;
l_transaction_type VARCHAR2(100);
L_MSG_DATA  VARCHAR2(4000);
l_EXCEPTION  EXCEPTION;
BEGIN
 FOR i IN p_context_param_names.first..p_context_param_names.last LOOP
   L_CONTEXT(i).NAME := p_context_param_names(i);
   L_CONTEXT(i).VALUE := p_context_param_values(i);
   L_CONTEXT(i).DISPLAY_SEQUENCE := i;
 END LOOP;
if(p_entity_type='DISPENSE') then
  l_transaction_type := INV_LABEL.TRX_ID_DIS;
else
  l_transaction_type := INV_LABEL.TRX_ID_UNDIS;
end if;
   GMO_LABEL_MGMT_GRP.PRINT_LABEL
               (P_API_VERSION=>1,
                P_INIT_MSG_LIST=>FND_API.G_TRUE,
                X_RETURN_STATUS=>L_RETURN_STATUS,
                X_MSG_COUNT=>L_MSG_COUNT,
                X_MSG_DATA=>L_MSG_DATA,
                P_ENTITY_NAME=>'GMO_DISPENSING',
                P_ENTITY_KEY=> to_char(p_entity_id),
                P_WMS_BUSINESS_FLOW_CODE => 38,
                P_LABEL_TYPE=>p_label_string,
                P_TRANSACTION_ID=> to_char(p_entity_id),
                P_TRANSACTION_TYPE=>l_transaction_type,
                P_APPLICATION_SHORT_NAME=>'GMO',
                P_REQUESTER=>fnd_global.user_id,
                P_CONTEXT=>L_CONTEXT,
                X_LABEL_ID=> l_label_request_id);
   IF(L_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS ) THEN
        RAISE l_EXCEPTION;
   END IF;
   return l_label_request_id;
EXCEPTION WHEN l_EXCEPTION THEN
   FND_MESSAGE.SET_ENCODED(L_MSG_DATA);
   APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
  raise;
END GET_LABEL_REQUEST_ID;
/* Label wrapper for dispensing */
FUNCTION IS_AUTO_PRINT_ENABLED RETURN VARCHAR2
IS
BEGIN
   IF(GMO_LABEL_MGMT_GRP.AUTO_PRINT_ENABLED ()) THEN
     return FND_API.G_TRUE;
   END IF;
  return FND_API.G_FALSE;
END;
/* Used by dispense dispatch report query*/
FUNCTION GET_PENDING_DISPENSE_QTY(P_RESERVATION_ID NUMBER,
                                  P_INVENTORY_ITEM_ID NUMBER,
          	                  P_ORGANIZATION_ID NUMBER,
                                  P_RECIPE_ID NUMBER ,
          	                  P_MATERIAL_DETAILS_ID NUMBER,
                                  P_RESERVATION_UOM VARCHAR2,
                                  P_RESERVED_QUANTITY NUMBER,
		                  P_PLAN_QUANTITY NUMBER,
		                  P_PLAN_UOM VARCHAR2,
		                  P_LOT_NUMBER VARCHAR2) RETURN NUMBER
IS
l_DISPENSE_UOM VARCHAR2(10);
l_DISPENSE_CONFIG_ID NUMBER;
l_RESERVED_QUANTITY NUMBER;
l_PENDING_DISPENSE_QUANTITY NUMBER;
l_MAX_ALLOWED_QUANTITY NUMBER;
l_MIN_ALLOWED_QUANTITY NUMBER;
l_INSTRUCTION_ENTITY_DEF_KEY VARCHAR2(20);
l_plan_uom_converted VARCHAR2(1);
l_revervation_uom_converted VARCHAR2(1);
l_security_flag varchar2(1);
BEGIN
 -- kiosk : start
  GET_DISPENSE_DATA( P_RESERVATION_ID =>P_RESERVATION_ID ,
                     P_INVENTORY_ITEM_ID => P_INVENTORY_ITEM_ID ,
		     P_ORGANIZATION_ID   => P_ORGANIZATION_ID,
                     P_RECIPE_ID => P_RECIPE_ID ,
                     P_MATERIAL_DETAILS_ID => P_MATERIAL_DETAILS_ID ,
                     P_RESERVED_QUANTITY => P_RESERVED_QUANTITY ,
                     P_RESERVATION_UOM => P_RESERVATION_UOM,
                     P_PLAN_QUANTITY => P_PLAN_QUANTITY,
                     P_PLAN_UOM => P_PLAN_UOM,
                     P_LOT_NUMBER  =>  P_LOT_NUMBER,
                     X_DISPENSE_UOM => l_DISPENSE_UOM ,
                     X_DISPENSE_CONFIG_ID => l_DISPENSE_CONFIG_ID,
                     X_RESERVED_QUANTITY => l_RESERVED_QUANTITY ,
                     X_PENDING_DISPENSE_QUANTITY => l_PENDING_DISPENSE_QUANTITY ,
                     X_MAX_ALLOWED_QUANTITY => l_MAX_ALLOWED_QUANTITY ,
                     X_MIN_ALLOWED_QUANTITY => l_MIN_ALLOWED_QUANTITY ,
                     X_INSTRUCTION_ENTITY_DEF_KEY=> l_INSTRUCTION_ENTITY_DEF_KEY,
                     X_PLAN_UOM_CONVERTIBLE => l_plan_uom_converted,
                     X_RESERVATION_UOM_CONVERTIBLE => l_revervation_uom_converted,
                     X_SECURITY_FLAG=>l_security_flag );
                      -- kiosk : End
  IF ( l_PENDING_DISPENSE_QUANTITY = -99999) THEN
       l_PENDING_DISPENSE_QUANTITY  := 0;
  END IF;
  return l_PENDING_DISPENSE_QUANTITY ;
END;
--This procedure performs the following operations:
--  1. It obtains the process instruction details identified by the instruction process ID
--     in XML FORMAT.
--  2. If P_CURRENT_XML (which is the current transaction XML) is not null then it is merged with the XML data
--     fetched in the previous step.
--  3. The merged XML is encapsulated in the root node <ERecord> with UTF-8 encoding.
PROCEDURE GET_TRANSACTION_XML(P_INSTRUCTION_PROCESS_ID IN  NUMBER,
			      P_CURRENT_XML            IN  CLOB,
			      X_OUTPUT_XML             OUT NOCOPY CLOB)
IS
--This variable hold the return status value returned by the process instructions API.
L_RETURN_STATUS  VARCHAR2(10);
--This variable holds the message count value returned by the process instructions API.
L_MSG_COUNT      NUMBER;
--This variable holds the messsage data returned by the process instructions API.
L_MSG_DATA       VARCHAR2(4000);
--This variable would be used to hold the XML data representing the process instructions data identified
--by the instruction process ID.
L_INSTR_XML      CLOB;
--This exception would be raised if the API to get the XML from process instructions return an error status.
XML_ERROR        EXCEPTION;
BEGIN
  --Set L_INSTR_XML to null.
  L_INSTR_XML := null;
  --Initialize the final XML CLOB holder.
  DBMS_LOB.CREATETEMPORARY(X_OUTPUT_XML, TRUE, DBMS_LOB.SESSION);
  --Write the XML Header into the CLOB.
  DBMS_LOB.WRITEAPPEND(X_OUTPUT_XML,LENGTH(EDR_CONSTANTS_GRP.G_ERECORD_XML_HEADER),EDR_CONSTANTS_GRP.G_ERECORD_XML_HEADER);
  --If the current transaction XML is not null then append the same into the final XML CLOB holder.
  IF P_CURRENT_XML IS NOT NULL AND DBMS_LOB.GETLENGTH(P_CURRENT_XML) > 0 THEN
    DBMS_LOB.APPEND(X_OUTPUT_XML,P_CURRENT_XML);
  END IF;
  --Obtain the process instruction details in XML format for the specified instruction process ID.
  GMO_INSTRUCTION_GRP.GET_INSTR_INSTANCE_XML
  (P_API_VERSION            => 1.0,
   P_INIT_MSG_LIST          => FND_API.G_TRUE,
   P_VALIDATION_LEVEL       => FND_API.G_VALID_LEVEL_NONE,
   P_INSTRUCTION_PROCESS_ID => P_INSTRUCTION_PROCESS_ID,
   X_OUTPUT_XML             => L_INSTR_XML,
   X_RETURN_STATUS          => L_RETURN_STATUS,
   X_MSG_COUNT              => L_MSG_COUNT,
   X_MSG_DATA               => L_MSG_DATA);
  --If the return status is EXCEPTION or UNEXPECTED ERROR then raise an exception.
  IF L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR OR L_RETURN_STATUS = FND_API.G_RET_STS_ERROR  THEN
    RAISE XML_ERROR;
  END IF;
  --If the XML representing the process instruction details is not null then append the same into the final XMl CLOB holder.
  IF L_INSTR_XML IS NOT NULL AND DBMS_LOB.GETLENGTH(L_INSTR_XML) > 0 THEN
    DBMS_LOB.APPEND(X_OUTPUT_XML,L_INSTR_XML);
  END IF;
  --Append the XML Footer into the final XML CLOB holder.
  DBMS_LOB.WRITEAPPEND(X_OUTPUT_XML,LENGTH(EDR_CONSTANTS_GRP.G_ERECORD_XML_FOOTER),EDR_CONSTANTS_GRP.G_ERECORD_XML_FOOTER);
EXCEPTION
  WHEN XML_ERROR THEN
    FND_MESSAGE.SET_ENCODED(L_MSG_DATA);
    --Diagnostics Start
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'gmo.plsql.GMO_DISPENSE_PVT.GET_TRANSACTION_XML',
                      FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','GMO_DISPENSE_PVT');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','GET_TRANSACTION_XML');
    --Diagnostics Start
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'gmo.plsql.GMO_DISPENSE_PVT.GET_TRANSACTION_XML',
                      FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;
END GET_TRANSACTION_XML;
-- Returns Total Reverse Dispensed Quantity for a given dispense id
FUNCTION GET_NET_REVERSE_DISPENSED_QTY (P_DISPENSE_ID IN NUMBER) RETURN NUMBER
IS
CURSOR REV_DISP_CUR IS
 SELECT sum(nvl(undispensed_qty,0))
  FROM GMO_MATERIAL_UNDISPENSES
 WHERE dispense_id = p_dispense_id;
l_return_value NUMBER;
BEGIN
  l_return_value := null;
  OPEN REV_DISP_CUR;
   FETCH REV_DISP_CUR INTO l_return_value;
  CLOSE REV_DISP_CUR;
return l_return_value;
END GET_NET_REVERSE_DISPENSED_QTY;
-- Returns Total Material Loss for a given dispense id
FUNCTION GET_NET_MATERIAL_LOSS (P_DISPENSE_ID IN NUMBER) RETURN NUMBER
IS
CURSOR REV_DISP_CUR IS
 SELECT sum(nvl(material_loss,0))
  FROM GMO_MATERIAL_UNDISPENSES
 WHERE dispense_id = p_dispense_id;
l_return_value NUMBER;
BEGIN
  l_return_value := null;
  OPEN REV_DISP_CUR;
   FETCH REV_DISP_CUR INTO l_return_value;
  CLOSE REV_DISP_CUR;
return l_return_value;
END GET_NET_MATERIAL_LOSS;

Function isDispenseOccuredAtDispBooth(disp_booth_id number) return varchar2
as

countValue number default 0;

begin

select count(dispense_booth_id) into countValue from gmo_material_dispenses
where dispense_booth_id = disp_booth_id;

if(countValue > 0) then
return 'Yes';
else
select count(dispense_booth_id) into countValue from gmo_material_undispenses
where dispense_booth_id = disp_booth_id;
if(countValue > 0) then
return 'Yes';
end if;
end if;
return 'No';
end;

Function isDispenseOccuredAtDispArea(disp_area_id number) return varchar2
as

countValue number default 0;

begin

select count(dispense_area_id) into countValue from gmo_material_dispenses
where dispense_area_id = disp_area_id;

if(countValue > 0) then
    return 'Yes';
else
    select count(dispense_area_id) into countValue from gmo_material_undispenses
    where dispense_area_id = disp_area_id;
    if(countValue > 0) then
        return 'Yes';
    else
        select count(dispense_area_id) into countValue from gmo_dispensing_planning
        where dispense_area_id = disp_area_id;
        if(countValue > 0) then
        return 'Yes';
        end if;
     end if;
end if;
return 'No';
end;


END GMO_DISPENSE_PVT;

/

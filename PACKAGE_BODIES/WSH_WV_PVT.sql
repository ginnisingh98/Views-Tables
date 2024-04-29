--------------------------------------------------------
--  DDL for Package Body WSH_WV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_WV_PVT" as
/*      $Header: WSHUTWVB.pls 115.10 99/07/16 08:24:16 porting ship $ */

  -- Name        departure_weight_volume
  -- Purpose     Validates parameters and invokes dep_weight_volume

  -- Arguments
  --             source            'DPW' or 'SC'
  --             departure_id
  --             organization_id
  --             wv_flag           weight/vol DPW/SC flag ('ALWAYS' or 'NEVER')
  --             update_flag       'Y' or 'N'
  --             menu_flag         'Y' or 'N' (indicates if invoked from
  --                                  the menu by the user or not).
  --             dpw_pack_flag    'Y' or 'N' to automatically pack containers
  --                               (valid only when source = 'DPW')
  --             x_sc_wv_mode     'ALL' or 'ENTERED' shipped quantites to use
  --             master_weight_uom
  --             net_weight        (input/output -- weight of all goods)
  --             tare_weight       (input/output -- weight of all containers)
  --             master_volume_uom
  --             volume            (input/output)
  --             status            (input/output)
  --                               -1 = error; 0 = success; 1 = warning

  -- Dependencies
  --      dep_weight_volume (for functionality)
  --      FND_MESSAGE package

PROCEDURE departure_weight_volume(
                source            IN     VARCHAR2,
                departure_id      IN     NUMBER,
                organization_id      IN     NUMBER,
                wv_flag           IN     VARCHAR2,
                update_flag       IN     VARCHAR2,
                menu_flag         IN     VARCHAR2,
		dpw_pack_flag	  IN	 VARCHAR2,
                x_sc_wv_mode      IN     VARCHAR2 DEFAULT 'ALL',
                master_weight_uom IN     VARCHAR2,
                net_weight        IN OUT NUMBER,
                tare_weight       IN OUT NUMBER,
                master_volume_uom IN     VARCHAR2,
                volume            IN OUT NUMBER,
                status            IN OUT NUMBER)
IS
BEGIN
   status := 0;
   IF   master_weight_uom IS NULL
     OR master_volume_uom IS NULL THEN
      status := -1;
      -- **Message: must specify weight and volume uoms.
      FND_MESSAGE.Set_Name('OE', 'WSH_WV_MISSING_UOMS');
   ELSIF   source           IS NULL
        OR departure_id     IS NULL
        OR organization_id     IS NULL
        OR wv_flag          IS NULL
        OR update_flag      IS NULL
        OR menu_flag IS NULL THEN
      status := -1;
      -- **Message: incomplete parameters
      FND_MESSAGE.Set_Name('OE', 'WSH_WV_INCOMPLETE_PARAMETERS');
   ELSIF   source           NOT IN ('DPW', 'SC')
        OR wv_flag          NOT IN ('ALWAYS', 'NEVER')
        OR update_flag      NOT IN ('Y', 'N')
        OR menu_flag        NOT IN ('Y', 'N')
        OR (dpw_pack_flag   NOT IN ('Y', 'N') AND source = 'DPW')
        OR (x_sc_wv_mode    NOT IN ('ALL', 'ENTERED') AND source = 'SC') THEN
      status := -1;
      -- **Message: invalid parameter values
      FND_MESSAGE.Set_Name('OE', 'WSH_WV_INVALID_VALUES');
   ELSE
      WSH_WV_PVT.dep_weight_volume(
            source, departure_id, organization_id,
            wv_flag, update_flag, menu_flag, dpw_pack_flag, x_sc_wv_mode,
            master_weight_uom, net_weight, tare_weight,
            master_volume_uom, volume,
            status);
   END IF;

EXCEPTION
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','wsh_wv_pvt(1)');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    status := -1;
END departure_weight_volume;


  -- Name        dep_weight_volume
  -- Purpose     Computes departure net weight and volume
  --             and, if update_flag is 'Y', updates the table WSH_DELIVERIES
  -- Called by   departure_weight_volume

  -- Arguments
  --             source            'DPW' or 'SC'
  --             departure_id
  --             organization_id
  --             wv_flag           weight/vol DPW/SC flag ('ALWAYS' or 'NEVER')
  --             update_flag       'Y' or 'N'
  --             menu_flag         'Y' or 'N' (indicates if invoked from
  --                                  the menu by the user or not).
  --             dpw_pack_flag    'Y' or 'N' to automatically pack containers
  --                               (valid only when source = 'DPW')
  --             x_sc_wv_mode      'ALL' or 'ENTERED' shipped quantites to use
  --             master_weight_uom
  --             net_weight        (input/output -- weight of all goods)
  --             tare_weight        (input/output -- weight of all containers)
  --             master_volume_uom
  --             volume            (input/output)
  --             status            (input/output)
  --                               -1 = error; 0 = success; 1 = warning

  -- Dependencies
  --      del_volume, del_weight, convert_uom, dep_loose_weight_volume

PROCEDURE dep_weight_volume(
                source            IN     VARCHAR2,
                departure_id      IN     NUMBER,
                organization_id   IN     NUMBER,
                wv_flag           IN     VARCHAR2,
                update_flag       IN     VARCHAR2,
                menu_flag         IN     VARCHAR2,
		dpw_pack_flag	  IN	 VARCHAR2,
                x_sc_wv_mode      IN     VARCHAR2 DEFAULT 'ALL',
                master_weight_uom IN     VARCHAR2,
                net_weight        IN OUT NUMBER,
                tare_weight       IN OUT NUMBER,
                master_volume_uom IN     VARCHAR2,
                volume            IN OUT NUMBER,
                status            IN OUT NUMBER)
IS
   CURSOR delivery_recs(x_dep_id NUMBER) IS
     SELECT delivery_id,
            gross_weight, weight_uom_code,
            volume, volume_uom_code
       FROM wsh_deliveries
      WHERE actual_departure_id = x_dep_id
        AND status_code <> 'CA';

   -- bug 650601 fix: this cursor added to calculate tare weight
   --                 which will be used to adjust departure's net weight.
   CURSOR del_tare_weight(x_del_id NUMBER, x_o_id NUMBER,
                               x_to_uom VARCHAR2) IS
    SELECT NVL(SUM( wsh_wv_pvt.convert_uom(msi.weight_uom_code, x_to_uom,
                                           NVL(msi.unit_weight, 0))
                    * pc.quantity),
               0) tare_weight
      FROM wsh_packed_containers pc,
           mtl_system_items      msi
     WHERE msi.inventory_item_id = pc.container_inventory_item_id
       AND pc.delivery_id = x_del_id
       AND msi.organization_id = x_o_id;

   x_del_tare           NUMBER;
   x_gross_weight       NUMBER;
   x_volume             NUMBER;
   pack_status		NUMBER;
   overpack_warned	BOOLEAN;

BEGIN
   IF menu_flag = 'N' AND wv_flag = 'NEVER' THEN
      -- In this case, there is no work to do.
      RETURN;
   END IF;

   net_weight  := 0;
   tare_weight := 0;

   volume     := 0;

   overpack_warned := FALSE;	-- not yet issued a warning about overpacking.

   FOR d in delivery_recs(departure_id) LOOP
     x_volume := 0;
     x_gross_weight := 0;

     IF source = 'DPW' AND dpw_pack_flag = 'Y' THEN
	  WSH_WV_PVT.del_autopack(d.delivery_id, organization_id, pack_status);

	  IF pack_status = 1 AND NOT overpack_warned THEN
	     overpack_warned := TRUE;
	      -- Set status to warning only if it was success
	     IF status = 0 then
                status := 1;
             END IF;
             FND_MESSAGE.Set_Name('OE', 'WSH_WV_AUTOPACK_BELOW_MIN_FILL');
          END IF;
     END IF;

     -- bug 650601 fix
     -- calculate delivery's tare weight

     OPEN del_tare_weight(d.delivery_id, organization_id,
                                      master_weight_uom);
     FETCH del_tare_weight INTO x_del_tare;
     IF del_tare_weight%NOTFOUND OR x_del_tare IS NULL THEN
        x_del_tare := 0;
     END IF;
     CLOSE del_tare_weight;

     -- bug 650601 fix
     -- update the departure's tare weight.

     tare_weight := tare_weight + x_del_tare;


     IF menu_flag = 'Y' THEN
        -- Always recalculate

        WSH_WV_PVT.del_weight(source, d.delivery_id, organization_id,
                              menu_flag, x_sc_wv_mode,
                              master_weight_uom, x_gross_weight,
                              status);
        net_weight := net_weight + x_gross_weight;

        WSH_WV_PVT.del_volume(source, d.delivery_id, organization_id,
                              x_sc_wv_mode,
                              master_volume_uom, x_volume,
                              status);
        volume := volume + x_volume;

     ELSIF wv_flag = 'ALWAYS' THEN

        IF d.gross_weight IS NULL THEN
           WSH_WV_PVT.del_weight(source, d.delivery_id, organization_id,
                                 menu_flag, x_sc_wv_mode,
                                 master_weight_uom, x_gross_weight,
                                 status);
           net_weight := net_weight + x_gross_weight;
        ELSE
           net_weight := net_weight + WSH_WV_PVT.convert_uom(d.weight_uom_code,
                                                  master_weight_uom,
                                                  d.gross_weight);
        END IF;

        IF d.volume IS NULL THEN
           WSH_WV_PVT.del_volume(source, d.delivery_id, organization_id,
                                 x_sc_wv_mode,
                                 master_volume_uom, x_volume,
                                 status);
           volume := volume + x_volume;
        ELSE
           volume := volume + WSH_WV_PVT.convert_uom(d.volume_uom_code,
                                          master_volume_uom,
                                          d.volume);
        END IF;
     END IF;

     IF   update_flag = 'Y'
      AND (x_gross_weight > 0 OR x_volume > 0) THEN
       UPDATE wsh_deliveries
          SET gross_weight = decode(x_gross_weight, 0, gross_weight,
                                    x_gross_weight),
              weight_uom_code = decode(x_gross_weight, 0, weight_uom_code,
                                       master_weight_uom),
              volume = decode(x_volume, 0, x_volume,
                              x_volume),
              volume_uom_code = decode(x_volume, 0, volume_uom_code,
                                       master_volume_uom)
        WHERE delivery_id = d.delivery_id;
     END IF;

   END LOOP;

   -- now add weight and volume of items loose in this departure

   WSH_WV_PVT.dep_loose_weight_volume(
		source,
                departure_id,
                organization_id,
                x_sc_wv_mode,
                master_weight_uom,
                x_gross_weight,
                master_volume_uom,
                x_volume,
                status);

   net_weight := net_weight + x_gross_weight;
   volume := volume + x_volume;

   -- bug 650601 fix
   -- adjust departure's net weight to exclude the tare weight

   net_weight := net_weight - tare_weight;

EXCEPTION
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','wsh_wv_pvt(2)');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    IF delivery_recs%ISOPEN THEN
       CLOSE delivery_recs;
    END IF;
    IF del_tare_weight%ISOPEN THEN
       CLOSE del_tare_weight;
    END IF;
    status := -1;
END dep_weight_volume;





  -- Name        dep_loose_weight_volume
  -- Purpose     Computes weight and volume of items loose in this departure
  --             (i.e., these items are not assigned to any delivery)
  -- Called by   dep_weight_volume

  -- Arguments
  --             source            'DPW' or 'SC'
  --             departure_id
  --             organization_id
  --             master_weight_uom
  --             weight            (input/output)
  --             x_sc_wv_mode      'ALL' or 'ENTERED' shipped quantites to use
  --             master_volume_uom
  --             volume            (input/output)
  --             status            (input/output)
  --                               -1 = error; 0 = success; 1 = warning

PROCEDURE dep_loose_weight_volume(
		source		  IN	 VARCHAR2,
                departure_id      IN     NUMBER,
                organization_id   IN     NUMBER,
                x_sc_wv_mode      IN     VARCHAR2 DEFAULT 'ALL',
                master_weight_uom IN     VARCHAR2,
                weight            IN OUT NUMBER,
                master_volume_uom IN     VARCHAR2,
                volume            IN OUT NUMBER,
                status            IN OUT NUMBER)
IS

  CURSOR dpw_loose_weight(x_dep_id NUMBER, x_o_id NUMBER) IS
     SELECT SUM( NVL(msi.unit_weight, 0) *
                 WSH_WV_PVT.convert_uom(sld.unit_code,
                                        msi.primary_uom_code,
                                        sld.quantity,
                                        sld.inventory_item_id) ) weight,
            msi.weight_uom_code  uom
       FROM so_line_details sld,
            mtl_system_items        msi
      WHERE sld.departure_id = x_dep_id
	AND sld.delivery_id IS NULL
        AND msi.inventory_item_id = sld.inventory_item_id
        AND msi.organization_id = x_o_id
      GROUP BY msi.weight_uom_code;

  CURSOR dpw_loose_volume(x_dep_id NUMBER, x_o_id NUMBER) IS
     SELECT SUM( NVL(msi.unit_volume, 0) *
                 WSH_WV_PVT.convert_uom(sld.unit_code,
                                        msi.primary_uom_code,
                                        sld.quantity,
                                        sld.inventory_item_id) ) volume,
            msi.volume_uom_code  uom
       FROM so_line_details sld,
            mtl_system_items        msi
      WHERE sld.departure_id = x_dep_id
	AND sld.delivery_id IS NULL
        AND msi.inventory_item_id = sld.inventory_item_id
        AND msi.organization_id = x_o_id
      GROUP BY msi.volume_uom_code;


  CURSOR dpw_bo_loose_weight(x_dep_id NUMBER, x_o_id NUMBER) IS
     SELECT SUM( NVL(msi.unit_weight, 0) *
                 WSH_WV_PVT.convert_uom(sl.unit_code,
                                        msi.primary_uom_code,
                                        sld.requested_quantity,
                                        sl.inventory_item_id) ) weight,
            msi.weight_uom_code  uom
       FROM so_picking_line_details sld,
            so_picking_lines_all   sl,
            mtl_system_items        msi
      WHERE sld.departure_id = x_dep_id
	AND sld.delivery_id IS NULL
        AND sl.picking_line_id = sld.picking_line_id
	AND sl.picking_header_id = 0	-- backordered
        AND msi.inventory_item_id = sl.inventory_item_id
        AND msi.organization_id = x_o_id
      GROUP BY msi.weight_uom_code;

  CURSOR dpw_bo_loose_volume(x_dep_id NUMBER, x_o_id NUMBER) IS
     SELECT SUM( NVL(msi.unit_volume, 0) *
                 WSH_WV_PVT.convert_uom(sl.unit_code,
                                        msi.primary_uom_code,
                                        sld.requested_quantity,
                                        sl.inventory_item_id) ) volume,
            msi.volume_uom_code  uom
       FROM so_picking_line_details sld,
            so_picking_lines_all    sl,
            mtl_system_items        msi
      WHERE sld.departure_id = x_dep_id
	AND sld.delivery_id IS NULL
        AND sl.picking_line_id = sld.picking_line_id
	AND sl.picking_header_id = 0	-- backordered
        AND msi.inventory_item_id = sl.inventory_item_id
        AND msi.organization_id = x_o_id
      GROUP BY msi.volume_uom_code;

   CURSOR dpw_loose_ato(x_dep_id NUMBER) IS
	SELECT	l.line_id ato_line_id,
		sum(ld.quantity) qty
	FROM	so_line_details ld,
		so_lines_all	l
	WHERE	ld.departure_id = x_dep_id
	AND	ld.delivery_id IS NULL
	AND	ld.included_item_flag = 'N'
	AND	l.line_id = ld.line_id
	AND	l.ato_flag = 'Y'
	AND	l.ato_line_id IS NULL
	GROUP BY l.line_id;

   CURSOR dpw_bo_loose_ato(x_dep_id NUMBER,
			   x_w_uom VARCHAR2, x_v_uom VARCHAR2) IS
	SELECT	l.line_id ato_line_id,
		sum(NVL(pld.requested_quantity, 0)) qty,
		--
		-- for weight and/or volume
		--    add the components only if the UOMs and values are same
		--    for the model its the configuration item.
		--    The WHERE clause only finds models where at least
		--    one physical attribute is the same; there may be two.
		--
		decode(m_msi.weight_uom_code,
		       i_msi.weight_uom_code, decode(m_msi.unit_weight,
						     i_msi.unit_weight, x_w_uom,
					             NULL),
		       NULL)  weight_uom,
		decode(m_msi.volume_uom_code,
		       i_msi.volume_uom_code, decode(m_msi.unit_volume,
						     i_msi.unit_volume, x_v_uom,
					             NULL),
		       NULL)  volume_uom
	FROM	so_picking_line_details pld,
		so_picking_lines_all pl,
		so_line_details ld,
		so_lines_all	l,
		mtl_system_items     i_msi,	-- configuration item
		mtl_system_items     m_msi	-- model
	WHERE	pld.departure_id = x_dep_id
	AND	pld.delivery_id IS NULL
	AND	pl.picking_line_id = pld.picking_line_id
	AND	pl.picking_header_id+0 = 0 -- backordered
	AND	ld.line_detail_id = pl.line_detail_id
	AND	ld.configuration_item_flag = 'Y'
	AND	l.line_id = ld.line_id
	AND	l.ato_flag = 'Y'
	AND	l.ato_line_id IS NULL
	AND	i_msi.inventory_item_id = pl.inventory_item_id
	AND	i_msi.organization_id = pl.warehouse_id
	AND	m_msi.inventory_item_id = l.inventory_item_id
	AND	m_msi.organization_id = pl.warehouse_id
	AND	(
		 -- we will need to calculate only one or both attributes:
		 -- same weight attributes
		    (NVL(m_msi.weight_uom_code, 'EMPTY')
			 =  NVL(i_msi.weight_uom_code, 'EMPTY')
		     AND NVL(m_msi.unit_weight, 0) = NVL(i_msi.unit_weight, 0))
                 OR
		 -- same volume attributes
		    (NVL(m_msi.volume_uom_code, 'EMPTY')
			 =  NVL (i_msi.volume_uom_code, 'EMPTY')
		     AND NVL(m_msi.unit_volume, 0) = NVL(i_msi.unit_volume, 0))

                 )
	GROUP BY l.line_id,
                 m_msi.weight_uom_code, i_msi.weight_uom_code,
                 m_msi.unit_weight,     i_msi.unit_weight,
                 m_msi.volume_uom_code, i_msi.volume_uom_code,
                 m_msi.unit_volume,     i_msi.unit_volume;

  CURSOR sc_loose_weight(x_dep_id NUMBER, x_o_id NUMBER, x_wv_mode NUMBER) IS
     SELECT SUM( NVL(msi.unit_weight, 0) *
                 WSH_WV_PVT.convert_uom(sl.unit_code,
                                        msi.primary_uom_code,
                                        NVL(sld.shipped_quantity,
                                            x_wv_mode*sld.requested_quantity),
                                        sl.inventory_item_id) ) weight,
            msi.weight_uom_code  uom
       FROM so_picking_line_details sld,
            so_picking_lines_all    sl,
            mtl_system_items        msi
      WHERE sld.departure_id = x_dep_id
	AND sld.delivery_id IS NULL
        AND sl.picking_line_id = sld.picking_line_id
	AND sl.picking_header_id+0 > 0 	-- NOT backordered
        AND msi.inventory_item_id = sl.inventory_item_id
        AND msi.organization_id = x_o_id
      GROUP BY msi.weight_uom_code;

  CURSOR sc_loose_volume(x_dep_id NUMBER, x_o_id NUMBER, x_wv_mode NUMBER) IS
     SELECT SUM( NVL(msi.unit_volume, 0) *
                 WSH_WV_PVT.convert_uom(sl.unit_code,
                                        msi.primary_uom_code,
                                        NVL(sld.shipped_quantity,
                                            x_wv_mode*sld.requested_quantity),
                                        sl.inventory_item_id) ) volume,
            msi.volume_uom_code  uom
       FROM so_picking_line_details sld,
            so_picking_lines_all    sl,
            mtl_system_items        msi
      WHERE sld.departure_id = x_dep_id
	AND sld.delivery_id IS NULL
        AND sl.picking_line_id = sld.picking_line_id
	AND sl.picking_header_id+0 > 0 	-- NOT backordered
        AND msi.inventory_item_id = sl.inventory_item_id
        AND msi.organization_id = x_o_id
      GROUP BY msi.volume_uom_code;

   CURSOR sc_loose_ato(x_dep_id NUMBER, x_w_uom VARCHAR2, x_v_uom VARCHAR2,
                       x_wv_mode NUMBER) IS
	SELECT	l.line_id ato_line_id,
		sum(NVL(pld.shipped_quantity,
                        x_wv_mode * pld.requested_quantity)) qty,
		--
		-- for weight and/or volume
		--    add the components only if the UOMs and values are same
		--    for the model and the configuration item.
		--    The WHERE clause only finds models where at least
		--    one physical attribute is the same; there may be two.
		--
		decode(m_msi.weight_uom_code,
		       i_msi.weight_uom_code, decode(m_msi.unit_weight,
						     i_msi.unit_weight, x_w_uom,
					             NULL),
		       NULL)  weight_uom,
		decode(m_msi.volume_uom_code,
		       i_msi.volume_uom_code, decode(m_msi.unit_volume,
						     i_msi.unit_volume, x_v_uom,
					             NULL),
		       NULL)  volume_uom
	FROM	so_picking_line_details pld,
		so_picking_lines_all pl,
		so_line_details ld,
		so_lines_all	l,
		mtl_system_items  i_msi,    -- configuration item
		mtl_system_items  m_msi     -- model
	WHERE	pld.departure_id = x_dep_id
	AND	pld.delivery_id IS NULL
	AND	pl.picking_line_id = pld.picking_line_id
	AND	pl.picking_header_id+0 > 0 -- NOT backordered
	AND	ld.line_detail_id = pl.line_detail_id
	AND	ld.configuration_item_flag = 'Y'
	AND	l.line_id = ld.line_id
	AND	l.ato_flag = 'Y'
	AND	l.ato_line_id IS NULL
	AND	i_msi.inventory_item_id = pl.inventory_item_id
	AND	i_msi.organization_id = pl.warehouse_id
	AND	m_msi.inventory_item_id = l.inventory_item_id
	AND	m_msi.organization_id = pl.warehouse_id
	AND	(
		 -- we will need to calculate only one or both attributes:
		 -- same weight attributes
		    (NVL(m_msi.weight_uom_code, 'EMPTY')
			 =  NVL(i_msi.weight_uom_code, 'EMPTY')
		     AND NVL(m_msi.unit_weight, 0) = NVL(i_msi.unit_weight, 0))
                 OR
		 -- same volume attributes
		    (NVL(m_msi.volume_uom_code, 'EMPTY')
			 =  NVL (i_msi.volume_uom_code, 'EMPTY')
		     AND NVL(m_msi.unit_volume, 0) = NVL(i_msi.unit_volume, 0))

                 )
	GROUP BY l.line_id,
                 m_msi.weight_uom_code, i_msi.weight_uom_code,
                 m_msi.unit_weight,     i_msi.unit_weight,
                 m_msi.volume_uom_code, i_msi.volume_uom_code,
                 m_msi.unit_volume,     i_msi.unit_volume;

	ato_weight NUMBER;
	ato_volume NUMBER;
        WV_MODE    NUMBER := 1;

BEGIN

  weight := 0;
  volume := 0;

  IF source = 'DPW' THEN

    FOR w IN dpw_loose_weight(departure_id, organization_id) LOOP
      weight := weight + WSH_WV_PVT.convert_uom(w.uom, master_weight_uom,
						 w.weight);
    END LOOP;
    FOR w IN dpw_bo_loose_weight(departure_id, organization_id) LOOP
      weight := weight + WSH_WV_PVT.convert_uom(w.uom, master_weight_uom,
						 w.weight);
    END LOOP;

    FOR v IN dpw_loose_volume(departure_id, organization_id) LOOP
      volume := volume + WSH_WV_PVT.convert_uom(v.uom, master_volume_uom,
						 v.volume);
    END LOOP;
    FOR v IN dpw_bo_loose_volume(departure_id, organization_id) LOOP
      volume := volume + WSH_WV_PVT.convert_uom(v.uom, master_volume_uom,
						 v.volume);
    END LOOP;

    FOR a IN dpw_loose_ato(departure_id) LOOP
	wsh_wvx_pvt.ato_weight_volume(source,
				     a.ato_line_id,
				     a.qty,
				     master_weight_uom,
				     ato_weight,
				     master_volume_uom,
				     ato_volume,
				     status);
	weight := weight + ato_weight;
	volume := volume + ato_volume;
    END LOOP;

    FOR a IN dpw_bo_loose_ato(departure_id,
			      master_weight_uom, master_volume_uom) LOOP
	wsh_wvx_pvt.ato_weight_volume('BO',
				     a.ato_line_id,
				     a.qty,
				     a.weight_uom,
				     ato_weight,
				     a.volume_uom,
				     ato_volume,
				     status);
	weight := weight + ato_weight;
	volume := volume + ato_volume;
    END LOOP;

  ELSIF source = 'SC' THEN

    IF UPPER(X_SC_WV_MODE) = 'ENTERED' THEN
       WV_MODE := 0;
    ELSE
       WV_MODE := 1;
    END IF;

    FOR w IN sc_loose_weight(departure_id, organization_id, wv_mode) LOOP
      weight := weight + WSH_WV_PVT.convert_uom(w.uom, master_weight_uom,
						 w.weight);
    END LOOP;
    FOR v IN sc_loose_volume(departure_id, organization_id, wv_mode) LOOP
      volume := volume + WSH_WV_PVT.convert_uom(v.uom, master_volume_uom,
						 v.volume);
    END LOOP;

    FOR a IN sc_loose_ato(departure_id,
			  master_weight_uom, master_volume_uom, wv_mode) LOOP
	wsh_wvx_pvt.ato_weight_volume(source,
				     a.ato_line_id,
				     a.qty,
				     a.weight_uom,
				     ato_weight,
				     a.volume_uom,
				     ato_volume,
				     status);
	weight := weight + ato_weight;
	volume := volume + ato_volume;
    END LOOP;

  END IF;

EXCEPTION
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','wsh_wv_pvt(3)');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    status := -1;
END dep_loose_weight_volume;



  -- Name        dep_fill_percentage
  -- Purpose     Computes percentage of the vehicle (or container) filled.

  -- Arguments
  --             departure_id
  --             organization_id
  --             vehicle_id        (or container)
  --		 vehicle_max_weight
  --		 weight
  --		 vehicle_max_volume
  --		 volume
  --		 vehicle_min_fill
  --             actual_fill       (input/output) in percentage
  --             status            (input/output)
  --                               -1 = error; 0 = success; 1 = warning

  -- Dependencies
  --      FND_MESSAGE package

PROCEDURE dep_fill_percentage(
                departure_id      IN     NUMBER,
                organization_id   IN     NUMBER,
                vehicle_id        IN     NUMBER,
		vehicle_max_weight IN    NUMBER,
		gross_weight	  IN     NUMBER,
		vehicle_max_volume IN    NUMBER,
		volume		  IN	 NUMBER,
		vehicle_min_fill  IN	 NUMBER,
                actual_fill       IN OUT NUMBER,
                status            IN OUT NUMBER)
IS
  CURSOR container_fill(x_dep_id NUMBER, x_o_id NUMBER, x_veh_id NUMBER) IS
    SELECT SUM(pc.quantity / cl.max_load_quantity) * 100
      FROM wsh_container_load    cl,
           wsh_packed_containers pc,
           wsh_deliveries        d
     WHERE d.actual_departure_id          = x_dep_id
       AND d.delivery_id                  = pc.delivery_id
       AND pc.container_inventory_item_id = cl.load_item_id
       AND cl.container_item_id           = x_veh_id
       AND cl.master_organization_id      =
		(SELECT master_organization_id
		 FROM   mtl_parameters
		 WHERE  organization_id = x_o_id)
       AND NVL(cl.max_load_quantity, 0) > 0
       AND (pc.parent_sequence_number IS NULL
	    OR not exists (select sequence_number from wsh_packed_containers
			where delivery_id = pc.delivery_id
			and sequence_number = pc.parent_sequence_number))
     GROUP BY 1;

  basis_flag      VARCHAR2(1);
  fill_percentage NUMBER      := NULL;
  fill_found      BOOLEAN     := FALSE;

BEGIN

  status := 0;

  WSH_PARAMETERS_PVT.get_param_value(organization_id,
				     'PERCENT_FILL_BASIS_FLAG',
				     basis_flag);
  IF basis_flag not in ('Q', 'V', 'W') THEN
     basis_flag := 'W';  -- default to weight as basis.
  END IF;

  IF basis_flag = 'Q' THEN -- use container quantity

     OPEN container_fill(departure_id, organization_id, vehicle_id);

     FETCH container_fill INTO fill_percentage;
     fill_found := container_fill%FOUND;

     CLOSE container_fill;

     IF NOT fill_found THEN
       fill_percentage := NULL;
       status := 0;

       --* Disabled the warning, per bug 590630
       --* status := 1;
       --* -- **Message: Outermost containers not defined (or invalid values).
       --* FND_MESSAGE.Set_Name('OE', 'WSH_WV_UNDEFINED_CONTAINERS');
     END IF;

  ELSIF basis_flag = 'V' THEN -- use volume

    IF vehicle_max_volume > 0 THEN
       fill_percentage := 100 * volume / vehicle_max_volume;
    END IF;

  ELSIF basis_flag = 'W' THEN -- use weight

    IF vehicle_max_weight > 0 THEN
       fill_percentage := 100 * gross_weight / vehicle_max_weight;
    END IF;

  END IF;

  -- overwrite the fill percentage field only if value has been calculated.
  -- and validate the value.
  IF fill_percentage IS NOT NULL THEN
    actual_fill := round(fill_percentage);

    if actual_fill > 100 then
      status := 1;
      -- **Message: fill percentage exceeds 100%.
      FND_MESSAGE.Set_Name('OE', 'WSH_WV_FILL_OVER_100');
    elsif actual_fill < vehicle_min_fill then
      status := 1;
      -- **Message: fill percentage does not meet
      --   the minimum fill percentage required.
      FND_MESSAGE.Set_Name('OE', 'WSH_WV_FILL_BELOW_MIN');
    end if;

  END IF;

  if volume > vehicle_max_volume then
     status := 1;
     -- **Message: volume exceeds the vehicle's maximum volume.
      FND_MESSAGE.Set_Name('OE', 'WSH_WV_VEH_OVER_MAX_VOL');
  end if;

  if gross_weight > vehicle_max_weight then
      status := 1;
      -- **Message: load weight exceeds the vehicle's maximum weight
      FND_MESSAGE.Set_Name('OE', 'WSH_WV_VEH_OVER_MAX_WEIGHT');
  end if;


EXCEPTION
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','wsh_wv_pvt(4)');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    IF container_fill%ISOPEN THEN
       CLOSE container_fill;
    END IF;
    actual_fill := NULL;
    status := -1;
END dep_fill_percentage;




  -- Name        del_weight_volume
  -- Purpose     Computes one delivery's net weight and volume
  --             and, if update_flag is 'Y', updates the table WSH_DELIVERIES

  -- Arguments
  --             source            'DPW' or 'SC'
  --             delivery_id
  --             organization_id
  --             update_flag       'Y' or 'N' (update WSH_DELIVERIES?)
  --             menu_flag         'Y' or 'N' (indicates if invoked from
  --                                  the menu by the user or not).
  --             dpw_pack_flag    'Y' or 'N' to automatically pack containers
  --                               (valid only when source = 'DPW')
  --             master_weight_uom
  --             net_weight        (input/output)
  --             master_volume_uom
  --             volume            (input/output)
  --             status            (input/output)
  --                               -1 = error; 0 = success; 1 = warning
  --             x_sc_wv_mode     'ALL' or 'ENTERED' shipped quantites to use

PROCEDURE del_weight_volume(
                source            IN     VARCHAR2,
                del_id            IN     NUMBER,
                organization_id   IN     NUMBER,
                update_flag       IN     VARCHAR2,
                menu_flag         IN     VARCHAR2,
		dpw_pack_flag	  IN	 VARCHAR2,
                x_sc_wv_mode      IN     VARCHAR2 DEFAULT 'ALL',
                master_weight_uom IN     VARCHAR2,
                gross_weight      IN OUT NUMBER,
                master_volume_uom IN     VARCHAR2,
                volume            IN OUT NUMBER,
                status            IN OUT NUMBER)
IS

pack_status	NUMBER;
x_volume	NUMBER := 0;
x_gross_weight	NUMBER := 0;
x_del_id	NUMBER := del_id;
x_master_weight_uom VARCHAR2(4) := master_weight_uom;
x_master_volume_uom VARCHAR2(4) := master_volume_uom;

BEGIN

     x_del_id := del_id;
     x_master_weight_uom := master_weight_uom;
     x_master_volume_uom := master_volume_uom;

     IF source = 'DPW' AND dpw_pack_flag = 'Y' THEN
	  WSH_WV_PVT.del_autopack(del_id, organization_id, pack_status);
	  IF pack_status = 1 THEN
	     IF status = 0 then  -- don't want to change error into warning.
                status := 1;
             END IF;
             FND_MESSAGE.Set_Name('OE', 'WSH_WV_AUTOPACK_BELOW_MIN_FILL');
	  END IF;
     END IF;

     WSH_WV_PVT.del_weight(source, del_id, organization_id,
                           menu_flag, x_sc_wv_mode,
                           master_weight_uom, x_gross_weight,
                           status);
     gross_weight := x_gross_weight;

     WSH_WV_PVT.del_volume(source, del_id, organization_id,
                           x_sc_wv_mode,
                           master_volume_uom, x_volume,
                           status);
     volume := x_volume;

     IF   update_flag = 'Y'  THEN
	IF x_gross_weight > 0 AND x_volume > 0 THEN

	       UPDATE wsh_deliveries
                  SET gross_weight = x_gross_weight,
                      weight_uom_code = x_master_weight_uom,
                      volume = x_volume,
                      volume_uom_code = x_master_volume_uom
                WHERE delivery_id = x_del_id;

        ELSIF x_gross_weight > 0 THEN

	       UPDATE wsh_deliveries
                  SET gross_weight = x_gross_weight,
                      weight_uom_code = x_master_weight_uom
                WHERE delivery_id = x_del_id;

        ELSIF x_volume > 0 THEN

	       UPDATE wsh_deliveries
                  SET volume = x_volume,
                      volume_uom_code = x_master_volume_uom
                WHERE delivery_id = x_del_id;

        END IF;
     END IF;

EXCEPTION
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','wsh_wv_pvt(5)');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    status := -1;
END;



  -- Name        del_volume
  -- Purpose     Computes the delivery actual volume
  -- Called by   dep_volume_weight

  -- Arguments
  --             source           'DPW' or 'SC'
  --             delivery_id
  --             organization_id
  --             x_sc_wv_mode     'ALL' or 'ENTERED' shipped quantites to use
  --             master_uom
  --             volume            (input/output)
  --             status            (input/output)
  --                               -1 = error; 0 = success; 1 = warning

  -- Dependencies
  --      convert_uom

PROCEDURE del_volume(
		source            IN     VARCHAR2,
                delivery_id       IN     NUMBER,
                organization_id   IN     NUMBER,
                x_sc_wv_mode      IN     VARCHAR2 DEFAULT 'ALL',
                master_uom        IN     VARCHAR2,
                volume            IN OUT NUMBER,
                status            IN OUT NUMBER)
IS
  CURSOR delivery_volumes(x_del_id NUMBER, x_o_id NUMBER) IS
    SELECT SUM(NVL(msi.unit_volume, 0) * pc.quantity) volume,
           msi.volume_uom_code uom
      FROM wsh_packed_containers pc,
           mtl_system_items      msi
     WHERE msi.inventory_item_id = pc.container_inventory_item_id
       AND pc.delivery_id = x_del_id
       AND msi.organization_id = x_o_id
       AND (pc.parent_sequence_number IS NULL
	    OR not exists (select sequence_number from wsh_packed_containers
			where delivery_id = pc.delivery_id
			and sequence_number = pc.parent_sequence_number))
     GROUP BY msi.volume_uom_code;

  CURSOR dpw_unpacked_volume(x_del_id NUMBER, x_o_id NUMBER) IS
     SELECT SUM( NVL(msi.unit_volume, 0) *
                 WSH_WV_PVT.convert_uom(sld.unit_code,
                                        msi.primary_uom_code,
                                        sld.quantity,
                                        sld.inventory_item_id) ) volume,
            msi.volume_uom_code  uom
       FROM so_line_details sld,
            mtl_system_items        msi
      WHERE sld.delivery_id = x_del_id
	AND sld.master_container_item_id IS NULL -- no default containers may
	AND sld.detail_container_item_id IS NULL -- mean that it is unpacked.
        AND msi.inventory_item_id = sld.inventory_item_id
        AND msi.organization_id = x_o_id
      GROUP BY msi.volume_uom_code;

  CURSOR dpw_unpacked_bo_volume(x_del_id NUMBER, x_o_id NUMBER) IS
     SELECT SUM( NVL(msi.unit_volume, 0) *
                 WSH_WV_PVT.convert_uom(sl.unit_code,
                                        msi.primary_uom_code,
                                        sld.requested_quantity,
                                        sl.inventory_item_id) ) volume,
            msi.volume_uom_code  uom
       FROM so_picking_line_details sld,
            so_picking_lines_all    sl,
            mtl_system_items        msi
      WHERE sld.delivery_id = x_del_id
        AND sl.picking_line_id = sld.picking_line_id
	AND sld.master_container_item_id IS NULL -- no default containers may
	AND sld.detail_container_item_id IS NULL -- mean that it is unpacked.
	AND sl.picking_header_id = 0	-- backordered
        AND msi.inventory_item_id = sl.inventory_item_id
        AND msi.organization_id = x_o_id
      GROUP BY msi.volume_uom_code;

   CURSOR dpw_unpacked_ato(x_del_id NUMBER) IS
	SELECT	l.line_id ato_line_id,
		sum(NVL(ld.quantity, 0)) qty
	FROM	so_line_details ld,
		so_lines_all	l
	WHERE	ld.delivery_id = x_del_id
	AND ld.master_container_item_id IS NULL -- no default containers may
	AND ld.detail_container_item_id IS NULL -- mean that it is unpacked.
	AND     ld.included_item_flag = 'N'
	AND	l.line_id = ld.line_id
	AND	l.ato_flag = 'Y'
	AND	l.ato_line_id IS NULL
	GROUP BY l.line_id;

   CURSOR dpw_unpacked_bo_ato(x_del_id NUMBER) IS
	SELECT	l.line_id ato_line_id,
		sum(NVL(pld.requested_quantity, 0)) qty
	FROM	so_picking_line_details pld,
		so_picking_lines_all pl,
		so_line_details ld,
		so_lines_all	l,
		mtl_system_items i_msi,   -- configuration item
		mtl_system_items m_msi    -- model
	WHERE	pld.delivery_id = x_del_id
	AND	pld.container_id IS NULL
	AND	pl.picking_line_id = pld.picking_line_id
	AND	pl.picking_header_id+0 = 0 -- backordered
	AND	ld.line_detail_id = pl.line_detail_id
	AND pld.master_container_item_id IS NULL -- no default containers may
	AND pld.detail_container_item_id IS NULL -- mean that it is unpacked.
	AND	ld.configuration_item_flag = 'Y'
	AND	l.line_id = ld.line_id
	AND	l.ato_flag = 'Y'
	AND	l.ato_line_id IS NULL
	AND	i_msi.inventory_item_id = pl.inventory_item_id
	AND	i_msi.organization_id = pl.warehouse_id
	AND	m_msi.inventory_item_id = l.inventory_item_id
	AND	m_msi.organization_id = pl.warehouse_id
	AND	 -- same volume attributes
		(NVL(m_msi.volume_uom_code, 'EMPTY')
			 =  NVL(i_msi.volume_uom_code, 'EMPTY')
		 AND NVL(m_msi.unit_volume, 0) = NVL(i_msi.unit_volume, 0))
	GROUP BY l.line_id;


  CURSOR sc_unpacked_volume(x_del_id NUMBER, x_o_id NUMBER,
                            x_wv_mode NUMBER) IS
     SELECT SUM( NVL(msi.unit_volume, 0) *
                 WSH_WV_PVT.convert_uom(sl.unit_code,
                                        msi.primary_uom_code,
                                        NVL(sld.shipped_quantity,
                                            x_wv_mode*sld.requested_quantity),
                                        sl.inventory_item_id) ) volume,
            msi.volume_uom_code  uom
       FROM so_picking_line_details sld,
            so_picking_lines_all    sl,
            mtl_system_items        msi
      WHERE sld.delivery_id = x_del_id
        AND sl.picking_line_id = sld.picking_line_id
	AND sld.container_id IS NULL    -- definitely unpacked.
	AND sl.picking_header_id+0 > 0 	-- NOT backordered
        AND msi.inventory_item_id = sl.inventory_item_id
        AND msi.organization_id = x_o_id
      GROUP BY msi.volume_uom_code;

   CURSOR sc_unpacked_ato(x_del_id NUMBER, x_wv_mode NUMBER) IS
	SELECT	l.line_id ato_line_id,
		sum(NVL(pld.shipped_quantity,
                         x_wv_mode * pld.requested_quantity)) qty
	FROM	so_picking_line_details pld,
		so_picking_lines_all pl,
		so_line_details ld,
		so_lines_all	l,
		mtl_system_items i_msi,   -- configuration item
		mtl_system_items m_msi    -- model
	WHERE	pld.delivery_id = x_del_id
	AND	pld.container_id IS NULL
	AND	pl.picking_line_id = pld.picking_line_id
	AND	pl.picking_header_id+0 > 0 -- NOT backordered
	AND	ld.line_detail_id = pl.line_detail_id
	AND	ld.configuration_item_flag = 'Y'
	AND	l.line_id = ld.line_id
	AND	l.ato_flag = 'Y'
	AND	l.ato_line_id IS NULL
	AND	i_msi.inventory_item_id = pl.inventory_item_id
	AND	i_msi.organization_id = pl.warehouse_id
	AND	m_msi.inventory_item_id = l.inventory_item_id
	AND	m_msi.organization_id = pl.warehouse_id
	AND	 -- same volume attributes
		(NVL(m_msi.volume_uom_code, 'EMPTY')
			 =  NVL(i_msi.volume_uom_code, 'EMPTY')
		 AND NVL(m_msi.unit_volume, 0) = NVL(i_msi.unit_volume, 0))
	GROUP BY l.line_id;

  ato_volume NUMBER;
  ato_weight NUMBER;
  WV_MODE    NUMBER := 1;

BEGIN
  volume := 0;
  FOR dv IN delivery_volumes(delivery_id, organization_id) LOOP
    volume := volume + WSH_WV_PVT.convert_uom(dv.uom, master_uom, dv.volume);
  END LOOP;

  -- include volume of unpacked items in this delivery.

  IF source = 'DPW' THEN

    FOR v IN dpw_unpacked_volume(delivery_id, organization_id) LOOP
      volume := volume + WSH_WV_PVT.convert_uom(v.uom, master_uom, v.volume);
    END LOOP;

    FOR v IN dpw_unpacked_bo_volume(delivery_id, organization_id) LOOP
      volume := volume + WSH_WV_PVT.convert_uom(v.uom, master_uom, v.volume);
    END LOOP;

    FOR a IN dpw_unpacked_ato(delivery_id) LOOP
	wsh_wvx_pvt.ato_weight_volume(source,
				     a.ato_line_id,
				     a.qty,
				     NULL,
				     ato_weight,
				     master_uom,
				     ato_volume,
				     status);
	volume := volume + ato_volume;
    END LOOP;

    FOR a IN dpw_unpacked_bo_ato(delivery_id) LOOP
	wsh_wvx_pvt.ato_weight_volume('BO',
				     a.ato_line_id,
				     a.qty,
				     NULL,
				     ato_weight,
				     master_uom,
				     ato_volume,
				     status);
	volume := volume + ato_volume;
    END LOOP;

  ELSIF source = 'SC' THEN

    IF UPPER(X_SC_WV_MODE) = 'ENTERED' THEN
       WV_MODE := 0;
    ELSE
       WV_MODE := 1;
    END IF;

    FOR v IN sc_unpacked_volume(delivery_id, organization_id, wv_mode) LOOP
      volume := volume + WSH_WV_PVT.convert_uom(v.uom, master_uom, v.volume);
    END LOOP;

    FOR a IN sc_unpacked_ato(delivery_id, wv_mode) LOOP
	wsh_wvx_pvt.ato_weight_volume(source,
				     a.ato_line_id,
				     a.qty,
				     NULL,
				     ato_weight,
				     master_uom,
				     ato_volume,
				     status);
	volume := volume + ato_volume;
    END LOOP;

  END IF;

EXCEPTION
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','wsh_wv_pvt(6)');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    status := -1;
END del_volume;


  -- Name        del_weight
  -- Purpose     Computes the delivery actual weight
  -- Called by   dep_volume_weight

  -- Arguments
  --             source            'DPW' or 'SC'
  --             delivery_id
  --             organization_id
  --             menu_flag         'Y' or 'N' (indicates if invoked from
  --                                  the menu by the user or not).
  --             x_sc_wv_mode      'ALL' or 'ENTERED' shipped quantites to use
  --             master_uom
  --             gross_weight      (input/output)
  --             status            (input/output)
  --                               -1 = error; 0 = success; 1 = warning

  -- Dependencies
  --      containers_weight, unpacked_items_weight, convert_uom
  --      FND_MESSAGE package

PROCEDURE del_weight(
                source            IN     VARCHAR2,
                delivery_id       IN     NUMBER,
                organization_id      IN     NUMBER,
                menu_flag         IN     VARCHAR2,
                x_sc_wv_mode      IN     VARCHAR2 DEFAULT 'ALL',
                master_uom        IN     VARCHAR2,
                gross_weight      IN OUT NUMBER,
                status            IN OUT NUMBER)
IS
  CURSOR delivery_weights(x_del_id NUMBER, x_o_id NUMBER) IS
    SELECT SUM(NVL(msi.unit_weight, 0) * pc.quantity) weight,
           msi.weight_uom_code uom
      FROM wsh_packed_containers pc,
           mtl_system_items      msi
     WHERE msi.inventory_item_id = pc.container_inventory_item_id
       AND pc.delivery_id = x_del_id
       AND msi.organization_id = x_o_id
     GROUP BY msi.weight_uom_code;

  -- cursors are for DPW case.

  CURSOR net_weight(x_del_id NUMBER, x_o_id NUMBER) IS
     SELECT SUM( NVL(msi.unit_weight, 0) *
                 WSH_WV_PVT.convert_uom(sld.unit_code,
                                        msi.primary_uom_code,
                                        sld.quantity,
                                        sld.inventory_item_id) ) weight,
            msi.weight_uom_code  uom
       FROM so_line_details sld,
            mtl_system_items        msi
      WHERE sld.delivery_id = x_del_id
        AND msi.inventory_item_id = sld.inventory_item_id
        AND msi.organization_id = x_o_id
      GROUP BY msi.weight_uom_code;

  CURSOR net_bo_weight(x_del_id NUMBER, x_o_id NUMBER) IS
     SELECT SUM( NVL(msi.unit_weight, 0) *
                 WSH_WV_PVT.convert_uom(sl.unit_code,
                                        msi.primary_uom_code,
                                        sld.requested_quantity,
                                        sl.inventory_item_id) ) weight,
            msi.weight_uom_code  uom
       FROM so_picking_line_details sld,
            so_picking_lines_all    sl,
            mtl_system_items        msi
      WHERE sld.delivery_id = x_del_id
        AND sl.picking_line_id = sld.picking_line_id
	AND sl.picking_header_id = 0	-- backordered
        AND msi.inventory_item_id = sl.inventory_item_id
        AND msi.organization_id = x_o_id
      GROUP BY msi.weight_uom_code;

   CURSOR ato(x_del_id NUMBER) IS
	SELECT	l.line_id ato_line_id,
		sum(ld.quantity) qty
	FROM	so_line_details ld,
		so_lines_all	l
	WHERE	ld.delivery_id = x_del_id
	AND     ld.included_item_flag = 'N'
	AND	l.line_id = ld.line_id
	AND	l.ato_flag = 'Y'
	AND	l.ato_line_id IS NULL
	GROUP BY l.line_id;

   CURSOR bo_ato(x_del_id NUMBER) IS
	SELECT	l.line_id ato_line_id,
		sum(NVL(pld.requested_quantity, 0)) qty
	FROM	so_picking_line_details pld,
		so_picking_lines_all pl,
		so_line_details ld,
		so_lines_all	l,
		mtl_system_items i_msi,   -- configuration item
		mtl_system_items m_msi    -- model
	WHERE	pld.delivery_id = x_del_id
	AND	pl.picking_line_id = pld.picking_line_id
	AND	pl.picking_header_id+0 = 0 -- backordered
	AND	ld.line_detail_id = pl.line_detail_id
	AND	ld.configuration_item_flag = 'Y'
	AND	l.line_id = ld.line_id
	AND	l.ato_flag = 'Y'
	AND	l.ato_line_id IS NULL
	AND	i_msi.inventory_item_id = pl.inventory_item_id
	AND	i_msi.organization_id = pl.warehouse_id
	AND	m_msi.inventory_item_id = l.inventory_item_id
	AND	m_msi.organization_id = pl.warehouse_id
	AND	 -- same weight attributes
		(NVL(m_msi.weight_uom_code, 'EMPTY')
			 =  NVL(i_msi.weight_uom_code, 'EMPTY')
		 AND NVL(m_msi.unit_weight, 0) = NVL(i_msi.unit_weight, 0))
	GROUP BY l.line_id;

  -- select other master containers whose parent_sequence_numbers
  -- are not NULL but not assigned to any other containers (or themselves).
  CURSOR sc_other_master_containers(x_del_id NUMBER) IS
    SELECT DISTINCT pc.parent_sequence_number
      FROM wsh_packed_containers pc
     WHERE pc.delivery_id = x_del_id
       AND pc.parent_sequence_number IS NOT NULL
       AND not exists (select sequence_number from wsh_packed_containers
			where delivery_id = pc.delivery_id
			and sequence_number = pc.parent_sequence_number);

  weight_c   NUMBER := 0;
  weight_ui  NUMBER := 0;
  ato_weight NUMBER;
  ato_volume NUMBER;

BEGIN
  gross_weight := 0;

  IF source = 'DPW' THEN
     -- Add the tare weights.
     FOR dw IN delivery_weights(delivery_id, organization_id) LOOP
       gross_weight := gross_weight
                     + WSH_WV_PVT.convert_uom(dw.uom, master_uom, dw.weight);
     END LOOP;

     -- Add the estimated net weight of delivery.
     FOR nw IN net_weight(delivery_id, organization_id) LOOP
       gross_weight := gross_weight
                     + WSH_WV_PVT.convert_uom(nw.uom, master_uom, nw.weight);
     END LOOP;
     FOR nw IN net_bo_weight(delivery_id, organization_id) LOOP
       gross_weight := gross_weight
                     + WSH_WV_PVT.convert_uom(nw.uom, master_uom, nw.weight);
     END LOOP;

    FOR a IN ato(delivery_id) LOOP
	wsh_wvx_pvt.ato_weight_volume(source,
				     a.ato_line_id,
				     a.qty,
				     master_uom,
				     ato_weight,
				     NULL,
				     ato_volume,
				     status);
	gross_weight := gross_weight + ato_weight;
    END LOOP;

    FOR a IN bo_ato(delivery_id) LOOP
	wsh_wvx_pvt.ato_weight_volume('BO',
				     a.ato_line_id,
				     a.qty,
				     master_uom,
				     ato_weight,
				     NULL,
				     ato_volume,
				     status);
	gross_weight := gross_weight + ato_weight;
    END LOOP;

  ELSIF source = 'SC' THEN
     WSH_WV_PVT.containers_weight(delivery_id, organization_id,
                                  NULL,
                                  menu_flag, x_sc_wv_mode,
                                  master_uom, weight_c, status);

     FOR c in sc_other_master_containers(delivery_id) LOOP
	-- weight_c will accumulate, as we weight the other containers
	 WSH_WV_PVT.containers_weight(delivery_id, organization_id,
                                  c.parent_sequence_number,
                                  menu_flag, x_sc_wv_mode,
                                  master_uom, weight_c, status);
     END LOOP;

     -- Add unpacked items,
     -- even if this addition may inflate the gross_weight value.
     WSH_WV_PVT.unpacked_items_weight(delivery_id, organization_id,
                                      x_sc_wv_mode,
                                      master_uom, weight_ui, status);

     gross_weight := weight_c + weight_ui;
  ELSE
    status := -1;
    -- **Message: invalid source value
    FND_MESSAGE.Set_Name('OE', 'WSH_WV_INVALID_SOURCE_VALUE');
  END IF;

EXCEPTION
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','wsh_wv_pvt(7)');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    IF delivery_weights%ISOPEN THEN
       CLOSE delivery_weights;
    END IF;
    IF sc_other_master_containers%ISOPEN THEN
       CLOSE sc_other_master_containers;
    END IF;
    status := -1;
END del_weight;


  -- Name        validate_packed_qty
  -- Purpose     Validates that all items shipped are packed.
  -- Assumption  This function will be called after all items are packed.

  -- Arguments
  --             delivery_id
  --	         pack_mode		specifies what NULL shipped_quantity
  --				        will be:
  --					  'ALL' -- non-zero, shipped
  --					  'ENTERED' -- zero, backordered
  --             status            (input/output)
  --                               -1 = error; 0 = success; 1 = warning
  --             RETURN BOOLEAN (TRUE = everything is packed
  --                             FALSE = not all is packed; warning is also
  --					  set in status)

  -- Dependencies
  --      convert_uom, WSH_UTIL.item_flex_name
  --      FND_MESSAGE package

FUNCTION validate_packed_qty(
                delivery_id       IN     NUMBER,
		pack_mode	  IN     VARCHAR2 DEFAULT 'ALL',
                status            IN OUT NUMBER)
RETURN BOOLEAN
IS
  CURSOR unpacked_items(x_del_id NUMBER, x_ship_all_flag NUMBER) IS
     SELECT spl.inventory_item_id                            id,
            spl.warehouse_id                               o_id
       FROM so_picking_line_details spld,
            so_picking_lines_all    spl
      WHERE spld.delivery_id = x_del_id
	AND spld.container_id IS NULL  -- not packed.
		-- but this item will be shipped...
	AND NVL(spld.shipped_quantity, x_ship_all_flag) > 0
        AND spl.picking_line_id = spld.picking_line_id
	AND spl.picking_header_id+0 > 0
      GROUP BY spl.inventory_item_id, spl.warehouse_id
      ORDER BY spl.inventory_item_id;

  result        BOOLEAN := TRUE;
  ship_all	NUMBER := 0;
  unpacked_list VARCHAR2(2000) := NULL;

BEGIN
  status := 0;

  if pack_mode = 'ALL' then
     ship_all := 1;
  else
     ship_all := 0;
  end if;

  FOR si IN unpacked_items(delivery_id, ship_all) LOOP
        result := FALSE;
        -- pass token to unpacked_list
        IF unpacked_list IS NULL THEN
           unpacked_list := WSH_CORE.item_flex_name(si.id, si.o_id);
        ELSE
           unpacked_list := unpacked_list || ', '
                               || WSH_CORE.item_flex_name(si.id, si.o_id);
        END IF;
  END LOOP;

  IF result = FALSE THEN
     status := 1;  -- warning, not error.
     FND_MESSAGE.Set_Name('OE', 'WSH_WV_UNPACKED');
     FND_MESSAGE.Set_Token('UNPACKED_LIST', unpacked_list);
  END IF;

  RETURN result;

EXCEPTION
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','wsh_wv_pvt(8)');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	if unpacked_items%ISOPEN then
	   close unpacked_items;
	end if;
    status := -1;
    RETURN result;
END validate_packed_qty;



  -- Name        containers_load_check
  -- Purpose     Checks whether any container is overloaded (based on
  --             container load relationships or weight or volume).
  --             Also checks whether the minimum fill percentages are met.
  --
  -- Note        If function returns TRUE and status is 1, it means that
  --             some containers are underpacked, but none is overpacked.
  --
  -- Assumption  This function will be called after all containers' weights
  --             are calculated or input by the user.

  -- Arguments
  --             delivery_id
  --             organization_id
  --	         pack_mode		specifies what NULL shipped_quantity
  --				        will be:
  --					  'ALL' -- non-zero, shipped
  --					  'ENTERED' -- zero, backordered
  --             status            (input/output)
  --                               -1 = error; 0 = success; 1 = warning
  --             RETURN BOOLEAN (TRUE = within maximum load
  --                                    OR with no information found
  --                             FALSE = exceeds maximum load, check warning)

FUNCTION containers_load_check(
                delivery_id       IN     NUMBER,
		pack_mode	  IN     VARCHAR2 DEFAULT 'ALL',
                status            IN OUT NUMBER)
RETURN BOOLEAN
IS
BEGIN
  RETURN wsh_wvx_pvt.x_containers_load_check(
               delivery_id,
               pack_mode,
               status);
END containers_load_check;


  -- Name        containers_weight_check
  -- Purpose     Checks whether any container's weight exceeds max_load_weight.
  -- Assumption  This function will be called after all weights are calculated
  --             or input by the user.

  -- Arguments
  --             delivery_id
  --             organization_id
  --             status            (input/output)
  --                               -1 = error; 0 = success; 1 = warning
  --             RETURN BOOLEAN (TRUE = within maximum load weight
  --                                    OR with no information found
  --                             FALSE = exceeds maximum load weight)

  -- Dependencies
  --      convert_uom
  --      FND_MESSAGE package

FUNCTION containers_weight_check(
                delivery_id       IN     NUMBER,
                organization_id      IN     NUMBER,
                status            IN OUT NUMBER)
RETURN BOOLEAN
IS
  CURSOR containers_info(x_del_id NUMBER, x_o_id NUMBER) IS
    SELECT pc.sequence_number      seq_num,
           pc.sequence_number      name,
           pc.quantity             quantity,
           pc.gross_weight         weight,
           pc.weight_uom_code      w_uom_code,
           msi.maximum_load_weight max_weight,
           msi.weight_uom_code     mw_uom_code
      FROM wsh_packed_containers pc,
           mtl_system_items      msi
     WHERE pc.delivery_id = x_del_id
       AND msi.inventory_item_id = pc.container_inventory_item_id
       AND msi.organization_id = x_o_id
       AND NVL(msi.maximum_load_weight, 0) > 0
       AND (   (    pc.weight_uom_code = msi.weight_uom_code
                AND (pc.gross_weight / pc.quantity) > msi.maximum_load_weight)
            OR (pc.weight_uom_code <> msi.weight_uom_code));
       -- The last AND clause ensures that all cursor rows fetched will
       -- either have excessive weight or have different UOMs which we
       -- must explicitly convert and then check.

  overweight   BOOLEAN := FALSE;
  result       BOOLEAN := TRUE;

  container_seq_list VARCHAR2(2000) := NULL;
BEGIN
  status := 0;

  FOR ci IN containers_info(delivery_id, organization_id) LOOP
     overweight := FALSE;

     IF ci.w_uom_code = ci.mw_uom_code THEN
        overweight := TRUE;
     ELSE
        IF WSH_WV_PVT.convert_uom(ci.w_uom_code, ci.mw_uom_code, ci.weight)
                > ci.max_weight THEN
           overweight := TRUE;
        END IF;
     END IF;

     IF overweight THEN
         result := FALSE;
         -- Build a token to pass to the message string.
         IF container_seq_list IS NULL THEN
            container_seq_list := ci.name;
         ELSE
            container_seq_list := container_seq_list || ', ' || ci.name;
         END IF;
     END IF;
  END LOOP;

  IF container_seq_list IS NOT NULL THEN
     status := 1;
     -- **Message: Max Load is exceeded for container(s) *Container_Seq_List
     FND_MESSAGE.Set_Name('OE', 'WSH_WV_MAX_LOAD_EXCEEDED');
     FND_MESSAGE.Set_Token('Container_Seq_List', container_seq_list);
  END IF;

  RETURN result;

EXCEPTION
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','wsh_wv_pvt(9)');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    IF containers_info%ISOPEN THEN
       CLOSE containers_info;
    END IF;
    status := -1;
    RETURN result;
END containers_weight_check;


  -- Name        containers_weight
  -- Purpose     Calculates the weight of containers (recursively if needed)

  -- Arguments
  --             delivery_id
  --             organization_id
  --             sequence_number
  --             menu_flag         'Y' or 'N' (indicates if invoked from
  --                                  the menu by the user or not).
  --             x_sc_wv_mode      'ALL' or 'ENTERED' shipped quantites to use
  --             master_uom
  --             weight            (input/output)
  --             status            (input/output)
  --                               -1 = error; 0 = success; 1 = warning

  -- Dependencies
  --             convert_uom

PROCEDURE containers_weight(
                delivery_id       IN     NUMBER,
                organization_id      IN     NUMBER,
                sequence_number   IN     NUMBER,
                menu_flag         IN     VARCHAR2,
                x_sc_wv_mode      IN     VARCHAR2 DEFAULT 'ALL',
                master_uom        IN     VARCHAR2,
                weight            IN OUT NUMBER,
                status            IN OUT NUMBER)
IS
  CURSOR container_lookups(x_del_id NUMBER, x_o_id NUMBER, x_seq_num NUMBER) IS
     SELECT pc.container_id                  id,
            pc.sequence_number               sequence_number,
            pc.gross_weight                  gross_weight,
            pc.weight_uom_code               gross_uom_code,
            pc.quantity                      quantity,
            pc.container_inventory_item_id   containter_inventory_item_id,
            pc.rowid                         rid,
            msi.unit_weight                  unit_weight,
            msi.weight_uom_code              uom_code
       FROM wsh_packed_containers pc,
            mtl_system_items      msi
      WHERE pc.delivery_id = x_del_id
        AND pc.container_inventory_item_id = msi.inventory_item_id
        AND msi.organization_id = x_o_id
        AND NVL(pc.parent_sequence_number, -1) = NVL(x_seq_num, -1);

  CURSOR contents_lookups(x_del_id NUMBER, x_o_id NUMBER, x_cont_id NUMBER,
                          x_wv_mode NUMBER) IS
     SELECT pl.inventory_item_id,
            SUM( NVL(msi.unit_weight, 0) *
                 WSH_WV_PVT.convert_uom(pl.unit_code,
                                        msi.primary_uom_code,
                                        NVL(cc.shipped_quantity,
                                            x_wv_mode*cc.requested_quantity),
                                        pl.inventory_item_id) ) weight,
            msi.weight_uom_code uom_code
       FROM so_picking_line_details cc,
            so_picking_lines_all   pl,
            mtl_system_items       msi
      WHERE cc.container_id = x_cont_id
        AND cc.delivery_id = x_del_id
	AND pl.picking_line_id = cc.picking_line_id
	AND pl.picking_header_id+0 > 0
        AND pl.inventory_item_id = msi.inventory_item_id
        AND msi.organization_id = x_o_id
      GROUP BY pl.inventory_item_id, weight_uom_code;

   CURSOR packed_ato(x_del_id NUMBER, x_cont_id NUMBER, x_wv_mode NUMBER) IS
	SELECT	l.line_id ato_line_id,
		sum(NVL(pld.shipped_quantity,
                        x_wv_mode * pld.requested_quantity)) qty
	FROM	so_picking_line_details pld,
		so_picking_lines_all pl,
		so_line_details ld,
		so_lines_all	l,
		mtl_system_items i_msi,   -- configuration item
		mtl_system_items m_msi    -- model
	WHERE	pld.delivery_id = x_del_id
	AND	pld.container_id = x_cont_id
	AND	pl.picking_line_id = pld.picking_line_id
	AND	pl.picking_header_id+0 > 0 -- NOT backordered
	AND	ld.line_detail_id = pl.line_detail_id
	AND	ld.configuration_item_flag = 'Y'
	AND	l.line_id = ld.line_id
	AND	l.ato_flag = 'Y'
	AND	l.ato_line_id IS NULL
	AND	i_msi.inventory_item_id = pl.inventory_item_id
	AND	i_msi.organization_id = pl.warehouse_id
	AND	m_msi.inventory_item_id = l.inventory_item_id
	AND	m_msi.organization_id = pl.warehouse_id
	AND	 -- same weight attributes
		(NVL(m_msi.weight_uom_code, 'EMPTY')
			 =  NVL(i_msi.weight_uom_code, 'EMPTY')
		 AND NVL(m_msi.unit_weight, 0) = NVL(i_msi.unit_weight, 0))
	GROUP BY l.line_id;

  cont_weight NUMBER := 0;
  ato_weight  NUMBER;
  ato_volume  NUMBER;
  x_cont_weight NUMBER := 0;
  x_master_uom VARCHAR2(4);
  WV_MODE    NUMBER := 1;

BEGIN
  IF weight IS NULL THEN
     weight := 0;
  END IF;
  IF status IS NULL THEN
     status := 0;
  END IF;

  IF UPPER(X_SC_WV_MODE) = 'ENTERED' THEN
     WV_MODE := 0;
  ELSE
     WV_MODE := 1;
  END IF;

  FOR container IN container_lookups(delivery_id, organization_id,
                                     sequence_number) LOOP
    cont_weight := 0;

    IF container.gross_weight IS NULL OR menu_flag = 'Y' THEN
      -- Calculate its gross weight and update the table:

      -- 1. Recursively weight the containers inside this container
      --    only if the container has a (non-NULL) sequence number.

      IF container.sequence_number IS NOT NULL THEN
         WSH_WV_PVT.containers_weight(delivery_id, organization_id,
                                      container.sequence_number,
                                      menu_flag, x_sc_wv_mode,
                                      master_uom, cont_weight, status);
      END IF;

      -- 2. Add the weights of items "loose" in this container, including ATO.
      FOR contents IN contents_lookups(delivery_id, organization_id,
                                       container.id, wv_mode) LOOP
        cont_weight := cont_weight
                     + WSH_WV_PVT.convert_uom(contents.uom_code, master_uom,
                                              contents.weight);
      END LOOP;

      FOR a IN packed_ato(delivery_id, container.id, wv_mode) LOOP
	wsh_wvx_pvt.ato_weight_volume('SC',
				     a.ato_line_id,
				     a.qty,
				     master_uom,
				     ato_weight,
				     NULL,
				     ato_volume,
				     status);
	cont_weight := cont_weight + ato_weight;
      END LOOP;

      -- 3. Include the container's tare weight, scaled by its quantity.
      --    (The contents are independent of the container's quantity,
      --    so their weight isn't scaled in step 2.)
      cont_weight := cont_weight
                   + WSH_WV_PVT.convert_uom(container.uom_code, master_uom,
                                            container.unit_weight)
                     * container.quantity;

      -- 4. Now update the table.
      x_cont_weight := cont_weight;
      x_master_uom := master_uom;
      UPDATE wsh_packed_containers
         SET gross_weight    = x_cont_weight,
             weight_uom_code = x_master_uom
       WHERE rowid = container.rid;

    ELSE
      -- Use its aggregate gross weight which has been entered into the table.
      cont_weight := WSH_WV_PVT.convert_uom(container.gross_uom_code,
                                            master_uom,
                                            container.gross_weight);
    END IF;

    weight := weight + cont_weight;
  END LOOP;

EXCEPTION
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','wsh_wv_pvt(10)');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    IF container_lookups%ISOPEN THEN
       CLOSE container_lookups;
    END IF;
    IF contents_lookups%ISOPEN THEN
       CLOSE contents_lookups;
    END IF;
    status := -1;
END containers_weight;


  -- Name        unpacked_items_weight
  -- Purpose     Calculates the weight of unpacked items for del_weight

  -- Arguments
  --             delivery_id
  --             organization_id
  --             x_sc_wv_mode      'ALL' or 'ENTERED' shipped quantites to use
  --             master_uom
  --             weight            (input/output)
  --             status            (input/output)
  --                               -1 = error; 0 = success; 1 = warning

  -- Dependencies
  --      convert_uom
  --      FND_MESSAGE package

PROCEDURE unpacked_items_weight(
                delivery_id       IN     NUMBER,
                organization_id   IN     NUMBER,
                x_sc_wv_mode      IN     VARCHAR2 DEFAULT 'ALL',
                master_uom        IN     VARCHAR2,
                weight            IN OUT NUMBER,
                status            IN OUT NUMBER)
IS
  CURSOR unpacked_items(x_del_id NUMBER, x_o_id NUMBER, x_wv_mode NUMBER) IS
    SELECT SUM(NVL(msi.unit_weight, 0) *
                 WSH_WV_PVT.convert_uom(spl.unit_code,
                                        msi.primary_uom_code,
                                        NVL(spld.shipped_quantity,
                                            x_wv_mode*spld.requested_quantity),
                                        spl.inventory_item_id) ) weight,
           msi.weight_uom_code uom
      FROM so_picking_line_details spld,
           so_picking_lines_all    spl,
           mtl_system_items        msi
     WHERE spld.delivery_id = x_del_id
       AND spld.container_id IS NULL -- not packed in any container
       AND spld.picking_line_id = spl.picking_line_id
       AND spl.picking_header_id+0 > 0
       AND msi.inventory_item_id = spl.inventory_item_id
       AND msi.organization_id = x_o_id
     GROUP BY msi.weight_uom_code;

   CURSOR unpacked_ato(x_del_id NUMBER, x_wv_mode NUMBER) IS
	SELECT	l.line_id ato_line_id,
		sum(NVL(pld.shipped_quantity,
                        x_wv_mode * pld.requested_quantity)) qty
	FROM	so_picking_line_details pld,
		so_picking_lines_all pl,
		so_line_details ld,
		so_lines_all	l,
		mtl_system_items i_msi,   -- configuration item
		mtl_system_items m_msi    -- model
	WHERE	pld.delivery_id = x_del_id
	AND	pld.container_id IS NULL -- not packed in any container
	AND	pl.picking_line_id = pld.picking_line_id
	AND	pl.picking_header_id+0 > 0
	AND	ld.line_detail_id = pl.line_detail_id
	AND	ld.configuration_item_flag = 'Y'
	AND	l.line_id = ld.line_id
	AND	l.ato_flag = 'Y'
	AND	l.ato_line_id IS NULL
	AND	i_msi.inventory_item_id = pl.inventory_item_id
	AND	i_msi.organization_id = pl.warehouse_id
	AND	m_msi.inventory_item_id = l.inventory_item_id
	AND	m_msi.organization_id = pl.warehouse_id
	AND	 -- same weight attributes
		(NVL(m_msi.weight_uom_code, 'EMPTY')
			 =  NVL(i_msi.weight_uom_code, 'EMPTY')
		 AND NVL(m_msi.unit_weight, 0) = NVL(i_msi.unit_weight, 0))
	GROUP BY l.line_id;

  total_weight  NUMBER := 0;
  ato_weight NUMBER;
  ato_volume NUMBER;
  WV_MODE    NUMBER := 1;

BEGIN
  status := 0;

  IF UPPER(X_SC_WV_MODE) = 'ENTERED' THEN
     WV_MODE := 0;
  ELSE
     WV_MODE := 1;
  END IF;

  FOR ti IN unpacked_items(delivery_id, organization_id, wv_mode) LOOP
     total_weight := total_weight
                   + WSH_WV_PVT.convert_uom(ti.uom, master_uom, ti.weight);
  END LOOP;

  FOR a IN unpacked_ato(delivery_id, wv_mode) LOOP
	wsh_wvx_pvt.ato_weight_volume('SC',
				     a.ato_line_id,
				     a.qty,
				     master_uom,
				     ato_weight,
				     NULL,
				     ato_volume,
				     status);
	total_weight := total_weight + ato_weight;
  END LOOP;

  weight := total_weight;

EXCEPTION
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','wsh_wv_pvt(11)');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    status := -1;
END unpacked_items_weight;



  -- Name        del_autopack
  -- Purpose     Computes and pack a number of master containers for each
  --             line detail assigned to this delivery.

  -- Arguments
  --             delivery_id
  --             organization_id
  --             status            (input/output)
  --                               -1 = error; 0 = success; 1 = warning
  --				   (warning means that some containers
  --				    are underpacked for some item(s) because
  --				    of their minimum fill percentages.)

PROCEDURE del_autopack(
                del_id      	 IN     NUMBER,
		organization_id  IN	NUMBER,
                status           IN OUT NUMBER)
IS


 -- Pack enough containers for all items.
 -- Warn the user if minimum_fill_percent is not satisfied.

-- Get all the delivery lines that have a master/detail container assigned:
-- 1. Obtain the number of containers each line needs.
-- 2. Sort them by their loading sequence number and by their containers
--
-- In the code:
-- 1. Break the list into groups by the container,
--    so that we consolidate the items into the same container
--    to ensure efficient use of containers.
-- 2. And each container packed will take the first load_seq_number,
--    but the container may not span from non-NULL load_seq_number to NULL.

 -- dl = delivery line

CURSOR autopack_list(x_del_id NUMBER, x_o_id NUMBER)  IS
	SELECT dl.load_seq_number			  load_seq_number,
	       wcl.container_item_id                      iid,
               WSH_WV_PVT.convert_uom(dl.unit_code,
                                      item_msi.primary_uom_code,
                                      dl.quantity,
                                      dl.inventory_item_id)
                   / wcl.max_load_quantity                  raw_qty,
	       0.01*NVL(cont_msi.minimum_fill_percent, 0)   min_fill,
	       cont_msi.weight_uom_code
	  FROM so_line_details      dl,
	       mtl_system_items     item_msi,
	       wsh_container_load   wcl,
	       mtl_system_items     cont_msi
         WHERE
               dl.delivery_id            = x_del_id
           AND item_msi.inventory_item_id = dl.inventory_item_id
	   AND item_msi.organization_id   = x_o_id
           AND wcl.load_item_id           = dl.inventory_item_id
	   AND wcl.master_organization_id =
		(SELECT master_organization_id
		 FROM   mtl_parameters
		 WHERE  organization_id = x_o_id)
           AND wcl.container_item_id      = NVL(dl.master_container_item_id,
						dl.detail_container_item_id)
           AND wcl.max_load_quantity      > 0
           AND cont_msi.inventory_item_id = wcl.container_item_id
	   AND cont_msi.organization_id   = x_o_id
	UNION ALL
	 -- copied from SELECT above and modified for backordered picking lines
	SELECT dl.load_seq_number			  load_seq_number,
	       wcl.container_item_id                      iid,
               WSH_WV_PVT.convert_uom(spl.unit_code,
                                      item_msi.primary_uom_code,
                                      NVL(dl.shipped_quantity,
                                          dl.requested_quantity),
                                      spl.inventory_item_id)
                   / wcl.max_load_quantity                  raw_qty,
	       0.01*NVL(cont_msi.minimum_fill_percent, 0)   min_fill,
	       cont_msi.weight_uom_code
	  FROM so_picking_line_details      dl,
	       so_picking_lines_all	    spl,
	       mtl_system_items             item_msi,
	       wsh_container_load           wcl,
	       mtl_system_items             cont_msi
         WHERE
	       spl.picking_line_id = dl.picking_line_id
	   AND spl.picking_header_id       = 0	-- backordered
           AND dl.delivery_id             = x_del_id
           AND item_msi.inventory_item_id = spl.inventory_item_id
	   AND item_msi.organization_id   = x_o_id
           AND wcl.load_item_id           = item_msi.inventory_item_id
	   AND wcl.master_organization_id =
		(SELECT master_organization_id
		 FROM   mtl_parameters
		 WHERE  organization_id = x_o_id)
           AND wcl.container_item_id      = NVL(dl.master_container_item_id,
						dl.detail_container_item_id)
           AND wcl.max_load_quantity      > 0
           AND cont_msi.inventory_item_id = wcl.container_item_id
	   AND cont_msi.organization_id   = x_o_id
	ORDER BY 1, 2;

  load_seq_number      SO_LINE_DETAILS.load_seq_number%TYPE	 := NULL;
  current_container_item_id WSH_CONTAINER_LOAD.container_item_id%TYPE := NULL;
  raw_qty	NUMBER	:= 0;
  min_fill	NUMBER  := 0;
  weight_code	MTL_SYSTEM_ITEMS.weight_uom_code%TYPE := '';
  x_del_id	NUMBER  := del_id;

BEGIN

   status := 0;

   SAVEPOINT before_autopack;

   x_del_id := del_id;
   DELETE FROM wsh_packed_containers
	 WHERE delivery_id = x_del_id;

   FOR c IN autopack_list(del_id, organization_id)  LOOP
	IF (c.iid = current_container_item_id)
	   AND NOT (load_seq_number IS NOT NULL and c.load_seq_number IS NULL)						THEN

          -- As long as it's the same container,
	  -- and it does not span from non-NULL load_seq_number to NULL.
	  raw_qty := raw_qty + c.raw_qty;

	ELSE

	  -- record the old container,
	  -- and update variables with the new container's information.
	  IF current_container_item_id IS NOT NULL THEN

                /* Bug 770276 :Increment the sequence number by 10 */
                load_seq_number := nvl(load_seq_number,0) + 10;

		WSH_WV_PVT.del_packcont(del_id,
				organization_id,
				current_container_item_id,
				raw_qty,
				min_fill,
				NULL,
				load_seq_number,
				weight_code,
				status);
		IF status = -1 THEN
		   ROLLBACK TO before_autopack;
		   RETURN;
		END IF;
	  END IF;

          /* Bug 770276 :Do not associate the container sequence number with load
             sequence number. Instead Increment the sequence number by 10 */
--	  load_seq_number := c.load_seq_number;

	  current_container_item_id := c.iid;
	  raw_qty	:= c.raw_qty;
	  min_fill	:= c.min_fill;
	  weight_code	:= c.weight_uom_code;

	END IF;
   END LOOP;

   IF current_container_item_id IS NOT NULL THEN
      -- pack the last container. ("flush")

      /* Bug 770276 :Increment the sequence number by 10 */
      load_seq_number := nvl(load_seq_number,0) + 10;

      WSH_WV_PVT.del_packcont(del_id,
			organization_id,
			current_container_item_id,
			raw_qty,
			min_fill,
			NULL,
			load_seq_number,
			weight_code,
			status);
      IF status = -1 THEN
        ROLLBACK TO before_autopack;
        RETURN;
      END IF;
   END IF;

EXCEPTION
WHEN OTHERS THEN
    ROLLBACK TO before_autopack;
      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','wsh_wv_pvt(12)');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    status := -1;
END del_autopack;



  -- Name        del_packcont
  -- Purpose     Packs the containers (called by del_autopack)

  --             status            (input/output)
  --                               -1 = error; 0 = success; 1 = warning
  --				   (warning means that some containers
  --				    are underpacked for some item(s) because
  --				    of their minimum fill percentages.)

PROCEDURE del_packcont(
		del_id		IN	NUMBER,
		organization_id	IN	NUMBER,
		cont_item_id	IN	NUMBER,
		raw_qty		IN	NUMBER,
		min_fill	IN	NUMBER,	-- range 0.00-1.00 (not 0-100)
		parent_seq	IN	NUMBER,
		load_seq_number	IN	NUMBER,
		weight_uom_code	IN	VARCHAR2,
                status		IN OUT	NUMBER)
IS

qty	NUMBER;
current_user NUMBER;

BEGIN
	IF min_fill = 0 THEN
	   qty := CEIL(raw_qty);
        ELSE
           -- add the padding for minimum fill and then cut the fraction off.
	   -- If the remaining items do not meet the minimum fill,
	   -- warn the user.
	   qty := FLOOR(raw_qty + (1 - min_fill));

	   IF qty < raw_qty THEN
		status := 1;	-- warning: some containers are underpacked.
	   END IF;

	   -- Then round the containers' quantity up to pack all items anyway.
	   qty := CEIL(raw_qty);
        END IF;

	current_user := to_number(FND_PROFILE.VALUE('USER_ID'));
	if current_user is null then
	   current_user := 0;
	end if;

	INSERT INTO wsh_packed_containers
		(container_id, delivery_id,
		 container_inventory_item_id, quantity,
 		 parent_sequence_number, sequence_number,	-- sequences
		 weight_uom_code,				-- weight
		 organization_id,
 		 creation_date, created_by,			-- creation
		 last_update_date, last_updated_by)		-- update
	   VALUES
		(wsh_packed_containers_s.nextval, del_id,
 		 cont_item_id, qty,
 		 parent_seq, load_seq_number,			-- sequences
		 weight_uom_code,				-- weight
		 organization_id,
 		 sysdate, current_user,				-- creation
 		 sysdate, current_user				-- update
		);

EXCEPTION
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','wsh_wv_pvt(13)');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    status := -1;
END del_packcont;



  -- Name        order_net_weight_in_delivery
  -- Purpose     Calculates the net weight of order's items in a delivery.
  --		 SC only.

  -- Arguments
  --             order_number	(if NULL, delivery's net weight is computed)
  --		 order_type_id	(if NULL, ignore this type)
  --             delivery_id
  --             weight_uom
  --             RETURN number

FUNCTION order_net_weight_in_delivery(
		order_number	IN	NUMBER,
		order_type_id	IN	NUMBER,
		delivery_id	IN	NUMBER,
		weight_uom	IN	VARCHAR2)
RETURN NUMBER IS
BEGIN
    return wsh_wvx_pvt.x_order_net_wt_in_delivery(
                    order_number  => order_number,
                    order_type_id => order_type_id,
                    delivery_id   => delivery_id,
                    weight_uom    => weight_uom);
END order_net_weight_in_delivery;


  -- Name        convert_uom
  -- Purpose     Converts one UOM into another; unless item_id is
  --             specified, the UOMs must be in the same class.

  -- Arguments
  --             from_uom
  --             to_uom
  --             quantity
  --             item_id (optional)
  --             RETURN number

  -- Dependencies
  --      inv_convert.inv_um_convert (when item_id is not NULL)

FUNCTION convert_uom(from_uom IN VARCHAR2,
                       to_uom IN VARCHAR2,
                     quantity IN NUMBER,
                      item_id IN NUMBER DEFAULT NULL)
RETURN NUMBER
IS
  this_item     NUMBER;
  to_rate       NUMBER;
  from_rate     NUMBER;
  result        NUMBER;

BEGIN
  IF from_uom = to_uom THEN
     result := quantity;
  ELSIF    from_uom IS NULL
        OR to_uom   IS NULL THEN
     result := 0;
  ELSE
     result := INV_CONVERT.inv_um_convert(item_id,
                                          6, -- precision digits
                                          quantity,
                                          from_uom,
                                          to_uom,
                                          NULL,
                                          NULL);

     -- hard-coded value that means undefined conversion
     --  For example, conversion of FT2 to FT3 doesn't make sense...
     -- Reset the result to 0 to preserve compatibility before
     -- the bug fix made above (namely, always call inv_um_convert).
     if result = -99999 then
        result := 0;
     end if;
  END IF;

  RETURN result;
END convert_uom;


PROCEDURE set_messages(message_string IN     VARCHAR2,
                       message_count  IN OUT NUMBER,
                       message_text1  IN OUT VARCHAR2,
                       message_text2  IN OUT VARCHAR2,
                       message_text3  IN OUT VARCHAR2,
                       message_text4  IN OUT VARCHAR2)
IS
BEGIN

  IF message_count = 0 THEN
     message_count := message_count + 1;
     message_text1 := message_string;

  ELSIF message_count = 1 THEN
     message_count := message_count + 1;
     message_text2 := message_string;

  ELSIF message_count = 2 THEN
     message_count := message_count + 1;
     message_text3 := message_string;

  ELSIF message_count = 3 THEN
     message_count := message_count + 1;
     message_text4 := message_string;
  END IF;

END set_messages;


END WSH_WV_PVT;

/

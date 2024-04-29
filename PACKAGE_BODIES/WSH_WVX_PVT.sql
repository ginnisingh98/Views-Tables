--------------------------------------------------------
--  DDL for Package Body WSH_WVX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_WVX_PVT" as
/* $Header: WSHUTWXB.pls 115.12 99/08/11 19:23:07 porting ship $ */

  -- Name        x_order_net_wt_in_delivery
  -- Purpose     Calculates the net weight of order's items in a delivery.
  --		 SC only.

  -- Arguments
  --             order_number	(if NULL, delivery's net weight is computed)
  --		 order_type_id	(if NULL, ignore this type)
  --             delivery_id
  --             weight_uom
  --             RETURN number

FUNCTION x_order_net_wt_in_delivery(
		order_number	IN	NUMBER,
		order_type_id	IN	NUMBER,
		delivery_id	IN	NUMBER,
		weight_uom	IN	VARCHAR2)
RETURN NUMBER IS

  CURSOR items_weight(x_del_id NUMBER, x_order_n NUMBER, x_order_t NUMBER) IS
     SELECT SUM( NVL(msi.unit_weight, 0) *
                 WSH_WV_PVT.convert_uom(spl.unit_code,
                                        msi.primary_uom_code,
                                        NVL(spld.shipped_quantity,
                                            spld.requested_quantity),
                                        spl.inventory_item_id) ) weight,
            msi.weight_uom_code  uom
       FROM so_picking_line_details spld,
            so_picking_lines_all    spl,
	    so_lines_all            sl,
	    so_headers_all	    sh,
            mtl_system_items        msi,
	    wsh_deliveries	    wd
      WHERE spld.delivery_id = x_del_id
	AND wd.delivery_id = x_del_id
        AND spl.picking_line_id = spld.picking_line_id
	AND spl.picking_header_id+0 > 0 -- NOT backordered
	AND sl.line_id = spl.order_line_id
	AND sh.header_id = sl.header_id
	AND sh.order_number = x_order_n
	AND sh.order_type_id = NVL(x_order_t, sh.order_type_id)
        AND msi.inventory_item_id = spl.inventory_item_id
        AND msi.organization_id = wd.organization_id
      GROUP BY msi.weight_uom_code;

  CURSOR delivery_weight(x_del_id NUMBER) IS
     SELECT SUM( NVL(msi.unit_weight, 0) *
                 WSH_WV_PVT.convert_uom(spl.unit_code,
                                        msi.primary_uom_code,
                                        -- if qty is NULL, it must be 0 here.
                                        NVL(spld.shipped_quantity, 0),
                                        spl.inventory_item_id) ) weight,
            msi.weight_uom_code  uom
       FROM so_picking_line_details spld,
            so_picking_lines_all    spl,
            mtl_system_items        msi,
	    wsh_deliveries	    wd
      WHERE spld.delivery_id = x_del_id
	AND wd.delivery_id = x_del_id
        AND spl.picking_line_id = spld.picking_line_id
	AND spl.picking_header_id+0 > 0	-- NOT backordered
        AND msi.inventory_item_id = spl.inventory_item_id
        AND msi.organization_id = wd.organization_id
      GROUP BY msi.weight_uom_code;

	-- for both delivery and order.
   CURSOR ato(x_del_id NUMBER, x_order_n NUMBER, x_order_t NUMBER) IS
	SELECT	l.line_id ato_line_id,
                -- if qty is NULL, it must be 0 here.
		sum(NVL(pld.shipped_quantity, 0)) qty
	FROM	so_picking_line_details pld,
		so_picking_lines_all pl,
		so_line_details ld,
		so_lines_all	l,
		so_headers_all  h,
		mtl_system_items i_msi,   -- configuration item
		mtl_system_items m_msi    -- model
	WHERE	pld.delivery_id = x_del_id
	AND	pl.picking_line_id = pld.picking_line_id
	AND	pl.picking_header_id+0 > 0 -- NOT backordered
	AND	ld.line_detail_id = pl.line_detail_id
	AND	ld.configuration_item_flag = 'Y'
	AND	l.line_id = ld.line_id
	AND	l.ato_flag = 'Y'
	AND	l.ato_line_id IS NULL
	AND	h.header_id = l.header_id
	AND	h.order_number = NVL(x_order_n, h.order_number)
	AND	h.order_type_id = NVL(x_order_t, h.order_type_id)
	AND	i_msi.inventory_item_id = pl.inventory_item_id
	AND	i_msi.organization_id = pl.warehouse_id
	AND	m_msi.inventory_item_id = l.inventory_item_id
	AND	m_msi.organization_id = pl.warehouse_id
	AND	 -- same weight attributes
		(NVL(m_msi.weight_uom_code, 'EMPTY')
			 =  NVL(i_msi.weight_uom_code, 'EMPTY')
		 AND NVL(m_msi.unit_weight, 0) = NVL(i_msi.unit_weight, 0))
	GROUP BY l.line_id;

net_weight NUMBER;
ato_weight NUMBER;
ato_volume NUMBER;
status	   NUMBER := 0;

BEGIN

   net_weight := 0;

   if order_number is not null then
      for w in items_weight(delivery_id, order_number, order_type_id) loop
         net_weight := net_weight
	   	 + WSH_WV_PVT.convert_uom(w.uom, weight_uom, w.weight);
      end loop;
   else
      for w in delivery_weight(delivery_id) loop
         net_weight := net_weight
	   	 + WSH_WV_PVT.convert_uom(w.uom, weight_uom, w.weight);
      end loop;
   end if;

   FOR a in ato(delivery_id, order_number, order_type_id) LOOP
	WSH_WVX_PVT.ato_weight_volume('SC',
				     a.ato_line_id,
				     a.qty,
				     weight_uom,
				     ato_weight,
				     NULL,
				     ato_volume,
				     status);
	net_weight := net_weight + ato_weight;
   END LOOP;

   return net_weight;


EXCEPTION
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','wsh_wvx_pvt(14)');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    return 0;
END x_order_net_wt_in_delivery;



-- Name		ato_weight_volume
-- Purpose 	calculate the weight/volume of the ATO model's components.
--
--	 	Regardless of the source (DPW, BO or SC), the ATO model's
--		physical attributes are not added because they are already
--		added (as "standard" items)--this is an important assumption.
--		(BO is DPW where the ATO config. item has been backordered.)
--		That is, for BO and SC, this routine would be invoked
--		only if the configuration item's physical attributes
--		match the ATO model's (meaning that BOM has copied them
--		directly).
-- Arguments
--		source	(DPW or SC or BO)
--		ato_line_id
--		quantity
--		weight_uom (if NULL, don't calculate weight)
--		weight 	(OUTPUT)
--		volume_uom (if NULL, don't calculate volume)
--		volume	(OUTPUT)
--		status	(-1 = error, 0 = success, +1 = warning)

PROCEDURE ato_weight_volume(
		source		IN	VARCHAR2,
		ato_line_id	IN	NUMBER,
		quantity	IN	NUMBER,
		weight_uom	IN	VARCHAR2,
		weight		OUT	NUMBER,
		volume_uom	IN	VARCHAR2,
		volume		OUT	NUMBER,
		status		IN OUT	NUMBER)
IS

  CURSOR ato_model(x_a_line_id NUMBER) IS
     SELECT (NVL(sl.ordered_quantity, 0) - NVL(sl.cancelled_quantity, 0)) qty
       FROM so_lines_all    sl
      WHERE sl.line_id = x_a_line_id;


  -- The two cursors ato_weight and ato_volume have the
  -- same WHERE clause. The only difference is weight vs. volume.

  CURSOR ato_weight(x_a_line_id NUMBER) IS
     SELECT SUM( NVL(msi.unit_weight, 0) *
                 WSH_WV_PVT.convert_uom(sld.unit_code,
                                        msi.primary_uom_code,
                                        sld.quantity,
                                        sld.inventory_item_id) ) weight,
            msi.weight_uom_code  uom
       FROM so_line_details 	sld,
	    so_lines_all 	sl,
            mtl_system_items    msi
      WHERE sl.ato_line_id = x_a_line_id
	AND sld.line_id = sl.line_id
	AND sld.included_item_flag = 'N'
	AND NVL(sld.configuration_item_flag, 'N') = 'N'
        AND msi.inventory_item_id = sld.inventory_item_id
        AND msi.organization_id = sld.warehouse_id
      GROUP BY msi.weight_uom_code;

  CURSOR ato_volume(x_a_line_id NUMBER) IS
     SELECT SUM( NVL(msi.unit_volume, 0) *
                 WSH_WV_PVT.convert_uom(sld.unit_code,
                                        msi.primary_uom_code,
                                        sld.quantity,
                                        sld.inventory_item_id) ) volume,
            msi.volume_uom_code  uom
       FROM so_line_details 	sld,
	    so_lines_all 	sl,
            mtl_system_items    msi
      WHERE sl.ato_line_id = x_a_line_id
	AND sld.line_id = sl.line_id
	AND sld.included_item_flag = 'N'
	AND NVL(sld.configuration_item_flag, 'N') = 'N'
        AND msi.inventory_item_id = sld.inventory_item_id
        AND msi.organization_id = sld.warehouse_id
      GROUP BY msi.volume_uom_code;

  model_quantity NUMBER;
  ratio	         NUMBER;
  model_weight   NUMBER := 0;
  model_volume   NUMBER := 0;
  w_uom        MTL_SYSTEM_ITEMS.weight_uom_code%TYPE;
  v_uom        MTL_SYSTEM_ITEMS.volume_uom_code%TYPE;

BEGIN
	weight := 0;
	volume := 0;

	-- If quantity is 0, skip the unnecessary effort.
	IF quantity = 0 THEN
	   RETURN;
	END IF;

	OPEN  ato_model(ato_line_id);
	FETCH ato_model INTO model_quantity;
	IF ato_model%NOTFOUND THEN
	   return;
	END IF;
        CLOSE ato_model;

	-- Compute the ratio, to adjust the weight/volume.
	IF model_quantity <= 0 THEN
	   -- In this singular case, just return.
	   ratio := 0;
	   return;
	ELSE
	   ratio := quantity / model_quantity;
	END IF;

	IF weight_uom IS NOT NULL THEN
	   FOR aw IN ato_weight(ato_line_id) LOOP
		model_weight := model_weight
		 + WSH_WV_PVT.convert_uom(aw.uom, weight_uom, aw.weight);
	   END LOOP;
	   weight := model_weight * ratio;
	END IF;

	IF volume_uom IS NOT NULL THEN
	   FOR av IN ato_volume(ato_line_id) LOOP
		model_volume := model_volume
		 + WSH_WV_PVT.convert_uom(av.uom, volume_uom, av.volume);
	   END LOOP;
	   volume := model_volume * ratio;
	END IF;

EXCEPTION
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','wsh_wvx_pvt(15)');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    status := -1;
END ato_weight_volume;


  -- Name        x_containers_load_check
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

FUNCTION x_containers_load_check(
                delivery_id       IN     NUMBER,
		pack_mode	  IN     VARCHAR2 DEFAULT 'ALL',
                status            IN OUT NUMBER)
RETURN BOOLEAN
IS

cursor delivery_uoms(x_delivery_id NUMBER) is
	select wd.weight_uom_code,
               wd.volume_uom_code,
               wd.organization_id
        from   wsh_deliveries wd
        where  wd.delivery_id = x_delivery_id;

-- Do not NVL the values because NULL means "don't care".
cursor cont_info(x_delivery_id NUMBER) is
    select wpc.sequence_number                              sequence_number,
           wpc.container_id                                 container_id,
           wpc.container_inventory_item_id                  inventory_item_id,
           wpc.quantity                                     quantity,
           -- net_weight = gross_weight - tare_weight
           WSH_WV_PVT.convert_uom(wpc.weight_uom_code,
                                  msi.weight_uom_code,
				  NVL(wpc.gross_weight, 0),
                                  msi.inventory_item_id)
                   - wpc.quantity * NVL(msi.unit_weight,0)  net_weight,
	   msi.maximum_load_weight * wpc.quantity           max_weight,
           msi.weight_uom_code                              weight_uom,
           msi.internal_volume * wpc.quantity               max_volume,
           msi.volume_uom_code                              volume_uom,
           msi.minimum_fill_percent                         min_fill_percent
    from   wsh_packed_containers wpc,
           mtl_system_items      msi
    where  wpc.delivery_id = x_delivery_id
    and    msi.inventory_item_id = wpc.container_inventory_item_id
    and    msi.organization_id = wpc.organization_id
    order by wpc.sequence_number;

overloaded BOOLEAN := FALSE;
underloaded BOOLEAN := FALSE;

-- tolerance_factor to scale the maximum weight/volume,
-- to tolerate any errors in unit conversions and
-- perhaps, measurements.
--  1.001 means tolerance of one part per thousand (.001).
-- Do not use tolernace_factor
-- with fill percentages, as they are truncated (toward 0).

tolerance_factor NUMBER := 1.001;



organization_id NUMBER := NULL;
net_volume NUMBER := 0;
fill_percent NUMBER := 0;
message_name VARCHAR2(30);

message_count NUMBER        := 0;
message_string VARCHAR2(300) := '';
message_text1 VARCHAR2(300) := '';
message_text2 VARCHAR2(300) := '';
message_text3 VARCHAR2(300) := '';
message_text4 VARCHAR2(300) := '';

-- statistical variables
--  count = number of containers that are overloaded
--  net_excess = sum of overload exceess (e.g., sum(weight - max_weight))
--  sequence = identification of the worst container
--  seq_excess = relative amount to beat to become the worst!
--       relative amount = 100% * (net_weight / max_weight)
--
-- Note: excess weight and volume are expressed in w_uom and v_uom.

excess  NUMBER := 0;
w_uom	WSH_DELIVERIES.weight_uom_code%TYPE := NULL;
v_uom	WSH_DELIVERIES.volume_uom_code%TYPE := NULL;

-- Weight
w_count		NUMBER := 0;
w_net_excess	NUMBER := 0;
w_sequence	WSH_PACKED_CONTAINERS.sequence_number%TYPE;
w_seq_excess	NUMBER := 0;

-- Volume
v_count		NUMBER := 0;
v_net_excess	NUMBER := 0;
v_sequence	WSH_PACKED_CONTAINERS.sequence_number%TYPE;
v_seq_excess	NUMBER := 0;

-- Load (based on load relationships)
l_count		NUMBER := 0;
l_sum_excess    NUMBER := 0;
l_avg_excess    NUMBER := 0;
l_sequence	WSH_PACKED_CONTAINERS.sequence_number%TYPE;
l_seq_excess	NUMBER := 0;

-- Underpacked (based on minimum fill percentage and its basis)
fill_basis_flag      VARCHAR2(1);
u_count         NUMBER := 0;
u_sequence      WSH_PACKED_CONTAINERS.sequence_number%TYPE;
u_seq_fill      NUMBER := 0;
u_least_packed  NUMBER := 1;
u_factor        NUMBER := 0; -- temporary result holder

BEGIN
  status := 0;

  OPEN delivery_uoms(delivery_id);
  FETCH delivery_uoms INTO w_uom, v_uom, organization_id;
  CLOSE delivery_uoms;


  WSH_PARAMETERS_PVT.get_param_value(organization_id,
				     'PERCENT_FILL_BASIS_FLAG',
				     fill_basis_flag);
  IF fill_basis_flag not in ('Q', 'V', 'W') THEN
     fill_basis_flag := 'W';  -- default to weight as basis.
  END IF;


  FOR container IN cont_info(delivery_id) LOOP

      -- remember: max_weight and max_volume may be NULL.
      -- remember: comparisons with NULL are always false.
      -- Thus, if max_weight or max_volume is not defined, it's not checked.

      ---
      ---
      --- Check the container's load weight
      ---
      ---

      IF container.net_weight > container.max_weight * tolerance_factor THEN

         overloaded := TRUE;
         w_count := w_count + 1; -- count container sequence, not quantity

	 IF w_uom IS NULL THEN
            -- in case delivery doesn't have one, use a backup uom.
	    w_uom := container.weight_uom;
	 END IF;

         -- calculate the absolute excess
         excess := WSH_WV_PVT.convert_uom(container.weight_uom,
                                          w_uom,
                                          (container.net_weight
                                             - container.max_weight));

         w_net_excess := w_net_excess + excess;

         -- now calculate the relative excess to find the worst container
	 IF container.max_weight = 0 THEN
            -- bizarre case, but can't be the worst.
            excess := NULL;
         ELSE
           excess := container.net_weight / container.max_weight;
         END IF;

         IF (excess > w_seq_excess) THEN
            w_sequence := container.sequence_number;
            w_seq_excess := excess;
         END IF;

      END IF; -- container.net_weight > container.max_weight

      ---
      ---
      --- Check the container's load volume volume
      ---
      ---

      WSH_WVX_PVT.container_net_volume(delivery_id,
                                      organization_id,
                                      container.container_id,
                                      container.sequence_number,
                                      container.volume_uom,
                                      pack_mode,
                                      net_volume);

      IF net_volume > container.max_volume * tolerance_factor THEN

         overloaded := TRUE;
         v_count := v_count + 1; -- count container sequence, not quantity

	 IF v_uom IS NULL THEN
            -- in case delivery doesn't have one, use a backup uom.
	    v_uom := container.volume_uom;
	 END IF;

         -- calculate the absolute excess
         excess := WSH_WV_PVT.convert_uom(container.volume_uom,
                                          v_uom,
                                          (net_volume
                                             - container.max_volume));

         v_net_excess := v_net_excess + excess;

         -- now calculate the relative excess to find the worst container
	 IF container.max_volume = 0 THEN
            -- bizarre case, but can't be the worst.
            excess := NULL;
         ELSE
           excess := net_volume / container.max_volume;
         END IF;

         IF (excess > v_seq_excess) THEN
            v_sequence := container.sequence_number;
            v_seq_excess := excess;
         END IF;

      END IF; -- net_volume > container.max_volume

      ---
      ---
      --- Check the container's load fill percentage doesn't exceed 100%.
      ---
      ---

      WSH_WVX_PVT.container_fill_percent(delivery_id,
                                      organization_id,
                                      container.container_id,
                                      container.inventory_item_id,
                                      container.sequence_number,
                                      container.quantity,
                                      pack_mode,
                                      fill_percent);

      IF fill_percent > 100 THEN

         overloaded := TRUE;
         l_count := l_count + 1; -- count container sequence, not quantity

         excess := fill_percent - 100;

         l_sum_excess := l_sum_excess + excess;

         IF (excess > l_seq_excess) THEN
            l_sequence := container.sequence_number;
            l_seq_excess := excess;
         END IF;

      END IF; -- fill_percent > 100


      ---
      ---
      --- Check the container's minimum fill percentage if it's more than 0%.
      ---
      ---

      IF container.min_fill_percent > 0 THEN

	  -- recalculate fill_percent if necessary.
          -- Note that if any variable is NULL, fill_percent will be NULL, too.
          -- But watch out for division by 0.

          IF fill_basis_flag = 'Q' THEN -- use load quantity (relationships)

              NULL;  -- fill_percent already calculated

          ELSIF fill_basis_flag = 'V' THEN -- use volume

              IF container.max_volume > 0 THEN
                fill_percent := trunc(100 * net_volume
                                          / container.max_volume);
              ELSE
                fill_percent := NULL;
              END IF;

          ELSIF fill_basis_flag = 'W' THEN -- use weight

              IF container.max_weight > 0 THEN
                 fill_percent := trunc(100 * container.net_weight
                                           / container.max_weight);
              ELSE
                fill_percent := NULL;
              END IF;

          END IF;

          IF fill_percent < container.min_fill_percent THEN
             underloaded := TRUE;
             u_count := u_count + 1; -- count container sequence, not quantity

             u_factor := fill_percent / container.min_fill_percent;
             IF u_factor < u_least_packed THEN
                u_sequence := container.sequence_number;
                u_least_packed := u_factor;
             END IF;
          END IF;

      END IF; -- container.min_fill_percent > 0

  END LOOP;


  IF w_count > 0 THEN
     w_net_excess := ceil(w_net_excess * 1000) / 1000;
     FND_MESSAGE.Set_Name('OE', 'WSH_WV_CONT_OVERLOAD_W');
     FND_MESSAGE.Set_Token('W_COUNT', to_char(w_count));
     FND_MESSAGE.Set_Token('WEIGHT_AMOUNT', to_char(w_net_excess));
     FND_MESSAGE.Set_Token('WEIGHT_UOM', w_uom);
     FND_MESSAGE.Set_Token('W_SEQ_NUMBER', to_char(w_sequence));

     message_string := FND_MESSAGE.Get;
     WSH_WVX_PVT.set_messages(message_string,
            message_count,
            message_text1, message_text2, message_text3, message_text4);
  END IF;

  IF v_count > 0 THEN
     v_net_excess := ceil(v_net_excess * 1000) / 1000;
     FND_MESSAGE.Set_Name('OE', 'WSH_WV_CONT_OVERLOAD_V');
     FND_MESSAGE.Set_Token('V_COUNT', to_char(v_count));
     FND_MESSAGE.Set_Token('VOLUME_AMOUNT', to_char(v_net_excess));
     FND_MESSAGE.Set_Token('VOLUME_UOM', v_uom);
     FND_MESSAGE.Set_Token('V_SEQ_NUMBER', to_char(v_sequence));

     message_string := FND_MESSAGE.Get;
     WSH_WVX_PVT.set_messages(message_string,
            message_count,
            message_text1, message_text2, message_text3, message_text4);
  END IF;

  IF l_count > 0 THEN
     -- overload percentage is average of the containers' overload percentage
     l_avg_excess := ceil(l_sum_excess / l_count);
     FND_MESSAGE.Set_Name('OE', 'WSH_WV_CONT_OVERLOAD_L');
     FND_MESSAGE.Set_Token('L_COUNT', to_char(l_count));
     FND_MESSAGE.Set_Token('LOAD_PERCENT', to_char(l_avg_excess));
     FND_MESSAGE.Set_Token('L_SEQ_NUMBER', to_char(l_sequence));

     message_string := FND_MESSAGE.Get;
     WSH_WVX_PVT.set_messages(message_string,
            message_count,
            message_text1, message_text2, message_text3, message_text4);
  END IF;

  IF u_count > 0 THEN
     FND_MESSAGE.Set_Name('OE', 'WSH_WV_CONT_UNDERLOAD');
     FND_MESSAGE.Set_Token('U_COUNT',      to_char(u_count));
     FND_MESSAGE.Set_Token('U_SEQ_NUMBER', to_char(u_sequence));

     message_string := FND_MESSAGE.Get;
     WSH_WVX_PVT.set_messages(message_string,
            message_count,
            message_text1, message_text2, message_text3, message_text4);
  END IF;

  -- underloaded or overloaded will generate the messages above.

  IF message_count > 0 THEN
     status := 1;

     FND_MESSAGE.Set_Name('OE', 'WSH_WV_COMBO');
     FND_MESSAGE.Set_Token('MESSAGE_1', message_text1);
     FND_MESSAGE.Set_Token('MESSAGE_2', message_text2);
     FND_MESSAGE.Set_Token('MESSAGE_3', message_text3);
     FND_MESSAGE.Set_Token('MESSAGE_4', message_text4);
  END IF;

  RETURN NOT overloaded;

EXCEPTION
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','wsh_wvx_pvt(1)');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    IF delivery_uoms%ISOPEN THEN
       CLOSE delivery_uoms;
    END IF;
    IF cont_info%ISOPEN THEN
       CLOSE cont_info;
    END IF;
    status := -1;
    RETURN NOT overloaded;
END x_containers_load_check;


  -- Name        container_net_volume (not recursive, does not update tables!)
  -- Purpose     Calculates the net volume of items and packed containers
  --             in this container

  -- Arguments
  --             delivery_id
  --             organization_id
  --             container_id
  --             sequence_number
  --             master_uom
  --	         pack_mode		specifies what NULL shipped_quantity
  --				        will be:
  --					  'ALL' -- non-zero, shipped
  --					  'ENTERED' -- zero, backordered
  --             volume            (output only)

PROCEDURE container_net_volume(
                delivery_id       IN     NUMBER,
                organization_id   IN     NUMBER,
                container_id      IN     NUMBER,
                sequence_number   IN     NUMBER,
                master_uom        IN     VARCHAR2,
                pack_mode         IN     VARCHAR2,
                volume            OUT    NUMBER) IS

  CURSOR container_volume(x_del_id NUMBER, x_o_id NUMBER, x_seq_num NUMBER) IS
     SELECT pc.container_inventory_item_id           inventory_item_id,
            NVL(msi.unit_volume, 0) * pc.quantity    volume,
            msi.volume_uom_code                      uom_code
       FROM wsh_packed_containers pc,
            mtl_system_items      msi
      WHERE pc.delivery_id = x_del_id
        AND pc.container_inventory_item_id = msi.inventory_item_id
        AND msi.organization_id = x_o_id
        AND NVL(pc.parent_sequence_number, -1) = NVL(x_seq_num, -1);

  CURSOR contents_volume(x_del_id NUMBER, x_o_id NUMBER,
                          x_cont_id NUMBER, x_ship_f NUMBER) IS
     SELECT pl.inventory_item_id,
            SUM( NVL(msi.unit_volume, 0) *
                 WSH_WV_PVT.convert_uom(pl.unit_code,
                                        msi.primary_uom_code,
                                        NVL(cc.shipped_quantity,
                                            x_ship_f*cc.requested_quantity),
                                        pl.inventory_item_id) ) volume,
            msi.volume_uom_code                                 uom_code
       FROM so_picking_line_details cc,
            so_picking_lines_all   pl,
            mtl_system_items       msi
      WHERE cc.container_id = x_cont_id
        AND cc.delivery_id = x_del_id
	AND pl.picking_line_id = cc.picking_line_id
	AND pl.picking_header_id+0 > 0
        AND pl.inventory_item_id = msi.inventory_item_id
        AND msi.organization_id = x_o_id
      GROUP BY pl.inventory_item_id, volume_uom_code;

   CURSOR packed_ato(x_del_id NUMBER, x_cont_id NUMBER, x_ship_f NUMBER) IS
	SELECT	l.line_id ato_line_id,
		sum(NVL(pld.shipped_quantity,
                        x_ship_f*pld.requested_quantity)) qty
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
	AND	 -- same volume attributes
		(NVL(m_msi.volume_uom_code, 'EMPTY')
			 =  NVL(i_msi.volume_uom_code, 'EMPTY')
		 AND NVL(m_msi.unit_volume, 0) = NVL(i_msi.unit_volume, 0))
	GROUP BY l.line_id;

  net_volume NUMBER := 0;
  ato_weight  NUMBER;
  ato_volume  NUMBER;
  ship_factor NUMBER := 0;
  status NUMBER := 0;

BEGIN

  If pack_mode = 'ALL' THEN
     ship_factor := 1;
  ELSE
     ship_factor := 0;
  END IF;

  FOR container IN container_volume(delivery_id, organization_id,
                                     sequence_number) LOOP
        net_volume := net_volume
                     + WSH_WV_PVT.convert_uom(container.uom_code, master_uom,
                                              container.volume,
                                              container.inventory_item_id);
  END LOOP;

  FOR item IN contents_volume(delivery_id, organization_id,
                              container_id, ship_factor) LOOP
        net_volume := net_volume
                     + WSH_WV_PVT.convert_uom(item.uom_code, master_uom,
                                              item.volume,
                                              item.inventory_item_id);
  END LOOP;


  FOR a IN packed_ato(delivery_id, container_id, ship_factor) LOOP
	WSH_WVX_PVT.ato_weight_volume('SC',
				     a.ato_line_id,
				     a.qty,
				     NULL,
				     ato_weight,
				     master_uom,
				     ato_volume,
				     status);

	net_volume := net_volume + ato_volume;
  END LOOP;

  volume := net_volume;

EXCEPTION
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','wsh_wvx_pvt(2)');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    IF container_volume%ISOPEN THEN
       CLOSE container_volume;
    END IF;
    IF contents_volume%ISOPEN THEN
       CLOSE contents_volume;
    END IF;
    IF packed_ato%ISOPEN THEN
       CLOSE packed_ato;
    END IF;
    volume := NULL;
END container_net_volume;


  -- Name        container_fill_percent
  -- Purpose     Calculates the fill percentage of items and packed containers
  --             in this container, based on their load relationships
  --             Note: the fill percentage basis parameter is ignored;
  --             That is, the basis is always Quantity in this procedure.

  -- Arguments
  --             delivery_id
  --             organization_id
  --             container_id
  --             container_item_id
  --             sequence_number
  --             container_qty
  --	         pack_mode		specifies what NULL shipped_quantity
  --				        will be:
  --					  'ALL' -- non-zero, shipped
  --					  'ENTERED' -- zero, backordered
  --             fill_percent           (output only)

PROCEDURE container_fill_percent(
                delivery_id       IN     NUMBER,
                organization_id   IN     NUMBER,
                container_id      IN     NUMBER,
                container_item_id IN     NUMBER,
                sequence_number   IN     NUMBER,
                container_qty     IN     NUMBER,
                pack_mode         IN     VARCHAR2,
                fill_percent      OUT    NUMBER) IS

  CURSOR cont_fill(x_del_id NUMBER, x_o_id NUMBER,
                        x_container_item_id NUMBER, x_seq_num NUMBER) IS
    SELECT SUM(pc.quantity / cl.max_load_quantity) fill
      FROM wsh_container_load    cl,
           wsh_packed_containers pc
     WHERE pc.delivery_id = x_del_id
       AND NVL(pc.parent_sequence_number, -1) = NVL(x_seq_num, -1)
       AND cl.load_item_id = pc.container_inventory_item_id
       AND cl.container_item_id           = x_container_item_id
       AND cl.master_organization_id      =
		(SELECT master_organization_id
		 FROM   mtl_parameters
		 WHERE  organization_id = x_o_id)
       AND NVL(cl.max_load_quantity, 0) > 0
     GROUP BY 1;

  CURSOR contents_fill(x_del_id NUMBER, x_o_id NUMBER,
                       x_container_item_id NUMBER,
                       x_cont_id NUMBER, x_ship_f NUMBER) IS
    SELECT SUM(  WSH_WV_PVT.convert_uom(pl.unit_code,
                                        msi.primary_uom_code,
                                        NVL(pld.shipped_quantity,
                                             x_ship_f*pld.requested_quantity))
                         / cl.max_load_quantity) fill
      FROM wsh_container_load      cl,
           so_picking_line_details pld,
           so_picking_lines_all    pl,
           mtl_system_items        msi
     WHERE pld.delivery_id = x_del_id
       AND pld.container_id = x_cont_id
       AND pl.picking_line_id = pld.picking_line_id
       AND msi.inventory_item_id = pl.inventory_item_id
       AND msi.organization_id = x_o_id
       AND cl.load_item_id = pl.inventory_item_id
       AND cl.container_item_id           = x_container_item_id
       AND cl.master_organization_id      =
		(SELECT master_organization_id
		 FROM   mtl_parameters
		 WHERE  organization_id = x_o_id)
       AND NVL(cl.max_load_quantity, 0) > 0
     GROUP BY 1;

  fill NUMBER := 0;
  ato_weight  NUMBER;
  ato_volume  NUMBER;
  ship_factor NUMBER := 0;

BEGIN

  -- don't want to divide by zero at end of this function.
  IF container_qty = 0 THEN
     -- Besides, there's no container to fill.
     fill_percent := 0;
     return;
  END IF;

  If pack_mode = 'ALL' THEN
     ship_factor := 1;
  ELSE
     ship_factor := 0;
  END IF;

  FOR container IN cont_fill(delivery_id, organization_id,
                             container_item_id,
                             sequence_number) LOOP
      fill := fill + container.fill;
  END LOOP;

  FOR contents IN contents_fill(delivery_id, organization_id,
                                container_item_id,
                                container_id, ship_factor) LOOP
      fill := fill + contents.fill;
  END LOOP;

  -- divide by container_qty to get the average fill percentage per container.
  fill_percent := TRUNC(100 * fill / container_qty);

EXCEPTION
WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','wsh_wvx_pvt(3)');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
    IF cont_fill%ISOPEN THEN
       CLOSE cont_fill;
    END IF;
    IF contents_fill%ISOPEN THEN
       CLOSE contents_fill;
    END IF;
    fill_percent := NULL;
END container_fill_percent;



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


  -- Name        containers_net_weight
  -- Purpose     Calculates the net weight of order's items in this
  --             container, also includes the weight of the items in the
  --             inner containers.
  --
  -- Arguments
  --             container_id
  --             pack_mode
  --             master_uom
  --             net_weight
PROCEDURE containers_net_weight(
   X_container_id    IN     NUMBER,
   X_organization_id IN     NUMBER,
   X_pack_mode       IN     VARCHAR2,
   X_master_uom      IN     VARCHAR2,
   X_net_weight      IN OUT NUMBER)
IS
   CURSOR cont_net_weight(
      P_container_id NUMBER,
      P_organization_id NUMBER,
      P_to_uom VARCHAR2,
      P_pack_flag NUMBER)
   IS
      SELECT NVL(wsh_wv_pvt.convert_uom(msi.weight_uom_code,
                                        P_to_uom,
                                        NVL(msi.unit_weight, 0)) *
                                        NVL(pld.shipped_quantity,
                                            P_pack_flag *
                                            pld.requested_quantity),
                 0) cont_net_weight
      FROM   so_picking_line_details pld,
             so_picking_lines_all    pl,
             mtl_system_items        msi
      WHERE  pl.picking_line_id    = pld.picking_line_id
      AND    msi.inventory_item_id = pl.inventory_item_id
      AND    msi.organization_id   = P_organization_id
      AND    pld.container_id      = P_container_id;

   CURSOR get_container_id(
      P_container_id NUMBER)
   IS
      SELECT           container_id
      FROM             wsh_packed_containers
      START WITH       container_id = P_container_id
      CONNECT BY PRIOR container_id = parent_container_id;

   L_pack_flag        NUMBER;
   L_tmp_container_id NUMBER;
   L_net_weight       NUMBER := 0;
BEGIN
   IF X_pack_mode = 'ENTERED' THEN
      L_pack_flag := 0;
   ELSE
      L_pack_flag := 1;
   END IF;

   X_net_weight := 0;

   OPEN get_container_id(X_container_id);
   LOOP
      FETCH get_container_id INTO L_tmp_container_id;
      EXIT WHEN get_container_id%NOTFOUND;

      OPEN cont_net_weight(L_tmp_container_id, X_organization_id, X_master_uom, L_pack_flag);
      LOOP
         FETCH cont_net_weight INTO L_net_weight;
         EXIT WHEN cont_net_weight%NOTFOUND;
         X_net_weight := X_net_weight + L_net_weight;
      END LOOP;
      CLOSE cont_net_weight;
   END LOOP;
   CLOSE get_container_id;

END containers_net_weight;


  -- Name        containers_tare_weight
  -- Purpose     Calculates the weight of this container
  --             and the weight of the containers inside
  --             of this container.
  --
  -- Arguments
  --             container_id
  --             master_uom
  --             tare_weight
PROCEDURE containers_tare_weight(
				 X_container_id IN     NUMBER,
				 X_master_uom   IN     VARCHAR2,
				 X_tare_weight  IN OUT NUMBER,
				 x_org_id       IN     NUMBER)
IS
   CURSOR cont_tare_weight(
			   P_container_id NUMBER,
			   P_to_uom VARCHAR2,
			   p_org_id NUMBER)
   IS
      SELECT NVL(wsh_wv_pvt.convert_uom(msi.weight_uom_code,
                                        P_to_uom,
                                        NVL(msi.unit_weight, 0)) * pc.quantity,
                 0) cont_tare_weight
      FROM  wsh_packed_containers pc,
            mtl_system_items      msi
	WHERE msi.inventory_item_id = pc.container_inventory_item_id
	AND   container_id          = P_container_id
	AND   msi.organization_id   = p_org_id;

   CURSOR get_container_id(
      P_container_id NUMBER)
   IS
      SELECT           container_id
      FROM             wsh_packed_containers pc
      START WITH       container_id = P_container_id
      CONNECT BY PRIOR container_id = parent_container_id;

   L_tmp_container_id NUMBER;
   L_tare_weight    NUMBER := 0;
BEGIN
   X_tare_weight := 0;
   OPEN get_container_id(X_container_id);
   LOOP
      FETCH get_container_id INTO L_tmp_container_id;
      EXIT WHEN get_container_id%NOTFOUND;

      OPEN cont_tare_weight(L_tmp_container_id, x_master_uom, x_org_id);
      FETCH cont_tare_weight INTO L_tare_weight;

      X_tare_weight := X_tare_weight + L_tare_weight;
      CLOSE cont_tare_weight;
   END LOOP;
   CLOSE get_container_id;

END containers_tare_weight;

PROCEDURE containers_tare_weight_self(
   X_container_id IN     NUMBER,
   X_org_id       IN     NUMBER,
   X_master_uom   IN     VARCHAR2,
   X_tare_weight  IN OUT NUMBER)
IS
   CURSOR cont_tare_weight(
      P_container_id NUMBER,
      P_org_id NUMBER,
      P_to_uom VARCHAR2)
   IS
      SELECT NVL(wsh_wv_pvt.convert_uom(msi.weight_uom_code,
                                        P_to_uom,
                                        NVL(msi.unit_weight, 0)) * pc.quantity,
                 0) cont_tare_weight
      FROM  wsh_packed_containers pc,
            mtl_system_items      msi
      WHERE msi.inventory_item_id = pc.container_inventory_item_id
      AND   container_id          = P_container_id
      AND   msi.organization_id   = P_org_id;

   L_tare_weight    NUMBER := 0;
BEGIN
   OPEN cont_tare_weight(X_container_id, X_org_id, X_master_uom);
   FETCH cont_tare_weight INTO X_tare_weight;
   CLOSE cont_tare_weight;
END containers_tare_weight_self;

PROCEDURE del_containers_tare_weight(
    X_del_id       IN     NUMBER,
    x_org_id       IN     NUMBER,
    X_master_uom   IN     VARCHAR2,
    X_tare_weight  IN OUT NUMBER)
IS
   CURSOR cont_tare_weight(
      P_container_id NUMBER,
      P_org_id NUMBER,
      P_to_uom VARCHAR2)
   IS
      SELECT NVL(wsh_wv_pvt.convert_uom(msi.weight_uom_code,
                                        P_to_uom,
                                        NVL(msi.unit_weight, 0)) * pc.quantity,
                 0) cont_tare_weight
      FROM  wsh_packed_containers pc,
            mtl_system_items      msi
      WHERE msi.inventory_item_id = pc.container_inventory_item_id
      AND   container_id          = P_container_id
      AND   msi.organization_id   = P_org_id;

   CURSOR containers_lookup(
	   p_del_id IN NUMBER)
    IS
	   SELECT container_id
	   FROM   wsh_packed_containers pc
	   WHERE  pc.delivery_id = p_del_id;

   L_tmp_container_id NUMBER;
   L_tare_weight    NUMBER := 0;

BEGIN
   X_tare_weight := 0;
   OPEN containers_lookup(X_del_id);
   LOOP
      FETCH containers_lookup INTO L_tmp_container_id;
      EXIT WHEN containers_lookup%NOTFOUND;

      OPEN cont_tare_weight(L_tmp_container_id, x_org_id, X_master_uom);
      FETCH cont_tare_weight INTO L_tare_weight;

      X_tare_weight := X_tare_weight + L_tare_weight;
      CLOSE cont_tare_weight;
   END LOOP;
   CLOSE containers_lookup;
END del_containers_tare_weight;


PROCEDURE auto_calc_cont(x_del_id    IN NUMBER,
			 x_org_id    IN NUMBER,
			 x_pack_mode IN VARCHAR2,
			 x_fill_base IN VARCHAR2)
  IS
     CURSOR containers_lookup(p_del_id IN NUMBER,
			      p_org_id IN NUMBER)
       IS
	  SELECT pc.container_id id,
	    pc.weight_uom_code              wt_uom,
	    pc.volume_uom_code              v_uom,
	    pc.sequence_number              seq_num,
	    pc.gross_weight                 gross_wt,
	    pc.net_weight                   net_wt,
	    pc.volume                       v,
	    pc.container_inventory_item_id  cont_inv_id,
	    pc.quantity                     quantity,
	    msi.internal_volume             max_v,
	    msi.maximum_load_weight         max_wt,
	    msi.weight_uom_code             msi_wt_uom,
	    msi.volume_uom_code             msi_v_uom,
	    pc.fill_percent                 fill
	    FROM   wsh_packed_containers pc,
	           mtl_system_items      msi
	    WHERE  pc.delivery_id = p_del_id
	    AND    msi.inventory_item_id = pc.container_inventory_item_id
	    AND    msi.organization_id = p_org_id;

     l_gross_wt     NUMBER;
     l_net_wt       NUMBER := -99;
     l_tare_wt      NUMBER := -99;
     l_volume       NUMBER := -99;
     l_fill_percent NUMBER;
     l_tare_wt_self NUMBER;
     l_tmp_wt       NUMBER;
     l_tmp_max_wt   NUMBER;
     l_tmp_max_v    NUMBER;

BEGIN
   FOR container IN containers_lookup(x_del_id, x_org_id) LOOP
      IF container.gross_wt IS NULL THEN
	 containers_net_weight(container.id,
			       x_org_id,
			       x_pack_mode,
			       container.wt_uom,
			       l_net_wt);

	 containers_tare_weight(container.id,
				container.wt_uom,
				l_tare_wt,
				x_org_id);

	 l_gross_wt := l_net_wt + l_tare_wt;

	 IF (l_gross_wt >= 0 AND l_net_wt >= 0 AND l_tare_wt >= 0) THEN
	    UPDATE wsh_packed_containers
	      SET gross_weight = l_gross_wt,
	          net_weight = l_net_wt
	      WHERE container_id = container.id
	      AND delivery_id = x_del_id;
	 END IF;
      END IF;

      IF container.v IS NULL THEN
	 container_net_volume(x_del_id,
			      x_org_id,
			      container.id,
			      container.seq_num,
			      container.v_uom,
			      x_pack_mode,
			      l_volume);

	 IF (l_volume >= 0) THEN
	    UPDATE wsh_packed_containers
	      SET volume = l_volume
	      WHERE container_id = container.id
	      AND delivery_id = x_del_id;
	 END IF;
      END IF;

      IF x_fill_base = 'Q' THEN
	 container_fill_percent(x_del_id,
				x_org_id,
				container.id,
				container.cont_inv_id,
				container.seq_num,
				container.quantity,
				x_pack_mode,
				l_fill_percent);
       ELSIF x_fill_base = 'V' THEN
	 IF (l_volume = -99) THEN
	    l_volume := container.v;
	 END IF;
	 l_tmp_max_v := wsh_wv_pvt.convert_uom(container.msi_v_uom,
					       container.v_uom,
					       container.max_v);
	 l_fill_percent := l_volume /
	   (l_tmp_max_v * container.quantity);
	 l_fill_percent := Round(l_fill_percent * 100, 2);
       ELSIF x_fill_base = 'W' THEN
	 IF (l_net_wt = -99) THEN
	    l_net_wt := container.net_wt;
	 END IF;

	 IF (l_tare_wt = -99) THEN
	   l_tare_wt := container.gross_wt - container.net_wt;
	 END IF;

	 l_tmp_max_wt := wsh_wv_pvt.convert_uom(container.msi_wt_uom,
						container.wt_uom,
						container.max_wt);
	 containers_tare_weight_self(container.id,
				     x_org_id,
				     container.wt_uom,
				     l_tare_wt_self);
	 l_tmp_wt := l_tare_wt - l_tare_wt_self + l_net_wt;
	 l_fill_percent := l_tmp_wt /
	   (l_tmp_max_wt * container.quantity);
	 l_fill_percent := Round(l_fill_percent * 100, 2);
      END IF;

      IF (l_fill_percent >= 0) THEN
	 UPDATE wsh_packed_containers
	   SET fill_percent = l_fill_percent
	   WHERE container_id = container.id
	   AND delivery_id = x_del_id;
      END IF;

      l_volume := -99; -- reset test value
      l_tare_wt := -99;
      l_net_wt := -99;
   END LOOP;
END auto_calc_cont;


END WSH_WVX_PVT;

/

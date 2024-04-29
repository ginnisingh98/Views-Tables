--------------------------------------------------------
--  DDL for Package Body POA_SAVINGS_SAV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_SAVINGS_SAV" AS
/* $Header: poasvp4b.pls 115.20 2004/01/22 12:24:35 sdiwakar ship $ */

  /*
    NAME
     get_lowest_possible_price
    DESCRIPTION
     procedure for calculating lowest amount we could have
     purchased an item in a potential contract for had we
     used a blanket.
  */
  --
  FUNCTION get_lowest_possible_price(p_creation_date IN DATE,
                                     p_quantity IN NUMBER,
                                     p_unit_meas_lookup_code IN VARCHAR2,
                                     p_currency_code IN VARCHAR2,
                                     p_item_id IN NUMBER,
                                     p_item_revision IN VARCHAR2,
                                     p_category_id IN NUMBER,
                                     p_ship_to_location_id IN NUMBER,
                                     p_need_by_date IN DATE,
                                     p_org_id IN NUMBER,
                                     p_ship_to_organization_id IN NUMBER,
                                     p_ship_to_ou IN NUMBER,
                                     p_rate_date IN DATE,
                                     p_edw_global_rate_type IN VARCHAR2,
                                     p_edw_global_currency_code IN VARCHAR2)
                                     RETURN NUMBER

  IS

  v_cum_lowest_price        NUMBER := 0;
  v_ncum_lowest_price       NUMBER := 0;
  v_lowest_price            NUMBER := 0;

  v_buf                     VARCHAR2(240) := NULL;
  BEGIN

    POA_LOG.debug_line('Get_lowest_possible_price: entered');

    v_ncum_lowest_price := get_lowest_ncum_price(p_creation_date,
                          p_quantity,
                          p_unit_meas_lookup_code,
                          p_currency_code,
                          p_item_id,
                          p_item_revision,
                          p_category_id,
                          p_ship_to_location_id,
                          p_need_by_date,
                          p_org_id,
                          p_ship_to_organization_id,
                          p_ship_to_ou,
                          p_rate_date,
                          p_edw_global_rate_type,
                          p_edw_global_currency_code);

    v_cum_lowest_price := get_lowest_cum_price(p_creation_date,
                         p_quantity,
                         p_unit_meas_lookup_code,
                         p_currency_code,
                         p_item_id,
                         p_item_revision,
                         p_category_id,
                         p_ship_to_location_id,
                         p_org_id,
                         p_ship_to_organization_id,
                         p_ship_to_ou,
                         p_rate_date,
                         p_edw_global_rate_type,
                         p_edw_global_currency_code);

   if v_ncum_lowest_price is null and v_cum_lowest_price is null then
     SELECT min(plc.unit_price *
                decode(sign(poa_savings_np.get_currency_conv_rate(phc.currency_code,
                                             p_edw_global_currency_code,
                                             p_rate_date,
                                             p_edw_global_rate_type
                                            )
                           ),-1,null,
                       poa_savings_np.get_currency_conv_rate(phc.currency_code,
                                             p_edw_global_currency_code,
                                             p_rate_date,
                                             p_edw_global_rate_type
                                            )
                      )
               )
     INTO v_lowest_price
     FROM po_headers_all phc
     ,    po_lines_all plc
     WHERE phc.type_lookup_code      = 'BLANKET'
     and   phc.po_header_id          = plc.po_header_id
     and   plc.unit_meas_lookup_code = p_unit_meas_lookup_code
     and   p_creation_date between nvl(phc.start_date, p_creation_date)
           and nvl(phc.end_date, p_creation_date)
     and   plc.item_id              = p_item_id
     and   nvl(plc.item_revision, nvl(p_item_revision, '-1'))
                                    = nvl(p_item_revision, '-1')
     and   trunc(p_creation_date) <= nvl(plc.expiration_date, p_creation_date)
     and (
          (nvl(phc.global_agreement_flag,'N') = 'N'
           and phc.org_id = p_ship_to_ou
          )
          or
          (phc.global_agreement_flag = 'Y'
           and exists
           (select 'enabled'
            from po_ga_org_assignments poga
            where poga.po_header_id = phc.po_header_id
            and poga.enabled_flag = 'Y'
            and ((poga.purchasing_org_id in
                  (select  tfh.start_org_id
                   from mtl_procuring_txn_flow_hdrs_v tfh,
                        financials_system_params_all fsp1,
                        financials_system_params_all fsp2
                   where p_creation_date between nvl(tfh.start_date,p_creation_date)
                                                 and nvl(tfh.end_date,p_creation_date)
                   and fsp1.org_id = tfh.start_org_id
                   and fsp1.purch_encumbrance_flag = 'N'
                   and fsp2.org_id = tfh.end_org_id
                   and fsp2.purch_encumbrance_flag = 'N'
                   and (
                        (tfh.qualifier_code is null) or
                        (tfh.qualifier_code = 1 and tfh.qualifier_value_id = plc.category_id)
                       )
                   and tfh.end_org_id = p_ship_to_ou
                   and (
                        (tfh.organization_id = p_ship_to_organization_id) or
                        (tfh.organization_id is null)
                       )
                  )
                 )
                 or poga.purchasing_org_id = p_ship_to_ou
                )
           )
          )
         );
--     if v_ncum_lowest_price is null then v_ncum_lowest_price := v_lowest_price; end if;
--     if v_cum_lowest_price is null then v_cum_lowest_price := v_lowest_price; end if;
   end if;
/*
    IF (v_ncum_lowest_price < v_cum_lowest_price) THEN
      v_lowest_price := v_ncum_lowest_price;
      POA_LOG.debug_line('  v_ncum_lowest_price: ' || v_ncum_lowest_price);

    ELSE
      v_lowest_price := v_cum_lowest_price;
      POA_LOG.debug_line('  v_cum_lowest_price: ' || v_ncum_lowest_price);
    END IF;
    POA_LOG.debug_line('  v_lowest_price: ' || v_lowest_price);
    POA_LOG.debug_line('  p_item_id: ' || p_item_id);
      */
      IF v_ncum_lowest_price IS NULL AND v_cum_lowest_price IS NOT NULL THEN
	 RETURN v_cum_lowest_price;
       ELSIF v_ncum_lowest_price IS NOT NULL AND v_cum_lowest_price IS NULL THEN
	 RETURN v_ncum_lowest_price;
       ELSIF v_ncum_lowest_price IS NOT NULL AND v_cum_lowest_price IS NOT NULL THEN
	 RETURN Least(v_ncum_lowest_price, v_cum_lowest_price);
      else
	 RETURN v_lowest_price;
      END IF;
  EXCEPTION
    WHEN others THEN
      v_buf := 'Lowest possible price function: internal error';
      ROLLBACK;

      POA_LOG.put_line(v_buf);
      POA_LOG.put_line(' ');

      RAISE;
  END get_lowest_possible_price;


    /* NAME
     get_lowest_ncum_price
    DESCRIPTION
     procedure for calculating lowest amount we could have
     purchased an item in a potential contract for had we
     used a blanket if the item has a non-cumulative price break
  */
  --
  FUNCTION get_lowest_ncum_price(p_creation_date IN DATE,
                                 p_quantity IN NUMBER,
                                 p_unit_meas_lookup_code IN VARCHAR2,
                                 p_currency_code IN VARCHAR2,
                                 p_item_id IN NUMBER,
                                 p_item_revision IN VARCHAR2,
                                 p_category_id IN NUMBER,
                                 p_ship_to_location_id IN NUMBER,
                                 p_need_by_date IN DATE,
                                 p_org_id IN NUMBER,
                                 p_ship_to_organization_id IN NUMBER,
                                 p_ship_to_ou IN NUMBER,
                                 p_rate_date IN DATE,
                                 p_edw_global_rate_type IN VARCHAR2,
                                 p_edw_global_currency_code IN VARCHAR2)
                                 RETURN NUMBER

  IS

  TYPE T_FLEXREF IS REF CURSOR;

  v_lowest_price            NUMBER := -1;
  v_count                   BINARY_INTEGER := 0;

  v_unit_price              NUMBER;
  v_quantity                NUMBER;
  v_price_override          NUMBER;
  v_price_override_null     NUMBER;
  v_lowest_price_null       NUMBER := -1;
  v_ship_to_location_id     NUMBER;
  v_line_id                 NUMBER;

  x_progress                VARCHAR2(3) := NULL;

  v_cursor                  T_FLEXREF;
  v_buf                     VARCHAR2(240) := NULL;
  v_conv_rate               GL_DAILY_RATES.CONVERSION_RATE%TYPE;

   CURSOR cur_line_id IS
      SELECT po_line_id,
             poa_savings_np.get_currency_conv_rate(phc.currency_code,
                                   p_edw_global_currency_code,
                                   p_rate_date,
                                   p_edw_global_rate_type
                                  ) conv_rate
      FROM   po_lines_all plc,
             po_headers_all phc
      WHERE  phc.po_header_id = plc.po_header_id
         and plc.unit_meas_lookup_code = p_unit_meas_lookup_code
         and p_creation_date between nvl(phc.start_date, p_creation_date)
                                 and nvl(phc.end_date, p_creation_date)
         and plc.item_id = p_item_id
         and nvl(plc.item_revision, nvl(p_item_revision, '-1'))
             = nvl(p_item_revision, '-1')
         and plc.price_break_lookup_code = 'NON CUMULATIVE'
         and trunc(p_creation_date) <= nvl(plc.expiration_date, p_creation_date)
         and (
              (nvl(phc.global_agreement_flag,'N') = 'N'
               and phc.org_id = p_ship_to_ou
              )
              or
              (phc.global_agreement_flag = 'Y'
               and exists
               (select 'enabled'
                from po_ga_org_assignments poga
                where poga.po_header_id = phc.po_header_id
                and poga.enabled_flag = 'Y'
                and ((poga.purchasing_org_id in
                      (select  tfh.start_org_id
                       from mtl_procuring_txn_flow_hdrs_v tfh,
                            financials_system_params_all fsp1,
                            financials_system_params_all fsp2
                       where p_creation_date between nvl(tfh.start_date,p_creation_date)
                                                     and nvl(tfh.end_date,p_creation_date)
                       and fsp1.org_id = tfh.start_org_id
                       and fsp1.purch_encumbrance_flag = 'N'
                       and fsp2.org_id = tfh.end_org_id
                       and fsp2.purch_encumbrance_flag = 'N'
                       and (
                            (tfh.qualifier_code is null) or
                            (tfh.qualifier_code = 1 and tfh.qualifier_value_id = plc.category_id)
                           )
                       and tfh.end_org_id = p_ship_to_ou
                       and (
                            (tfh.organization_id = p_ship_to_organization_id) or
                            (tfh.organization_id is null)
                           )
                      )
                     )
                     or poga.purchasing_org_id = p_ship_to_ou
                    )
               )
              )
             );

   BEGIN

   POA_LOG.debug_line('Get_lowest_ncum_price: entered');
   x_progress := '001';

   -- Get all blanket agreements matching ship_to_location that
   -- we could have released this item on.

   OPEN cur_line_id;

   FETCH cur_line_id INTO
           v_line_id, v_conv_rate;

   IF cur_line_id%NOTFOUND THEN
      close cur_line_id;
      return NULL;
   END IF;

   LOOP

   SELECT MIN(price_override) INTO v_price_override FROM (
    SELECT price_override
     FROM   po_line_locations_all psc
     WHERE  psc.shipment_type = 'PRICE BREAK'
     and psc.po_line_id = v_line_id
     and psc.ship_to_location_id = p_ship_to_location_id
     and psc.po_release_id is null
       and Nvl(psc.quantity,0) <= p_quantity
       and nvl(trunc(p_need_by_date), p_creation_date)
       between nvl(psc.start_date, nvl(p_need_by_date, p_creation_date))
       and nvl(psc.end_date, nvl(p_need_by_date, p_creation_date))
     order by Nvl(psc.quantity,0) desc, Trunc(psc.creation_date) desc,
       psc.price_override ASC) WHERE ROWNUM = 1;

   SELECT MIN(price_override) INTO v_price_override_null FROM (
    SELECT price_override
     FROM   po_line_locations_all psc
     WHERE  psc.shipment_type = 'PRICE BREAK'
     and psc.po_line_id = v_line_id
     and psc.ship_to_location_id IS null
     and psc.po_release_id is null
       and Nvl(psc.quantity,0) <= p_quantity
       and nvl(trunc(p_need_by_date), p_creation_date)
       between nvl(psc.start_date, nvl(p_need_by_date, p_creation_date))
       and nvl(psc.end_date, nvl(p_need_by_date, p_creation_date))
     order by Nvl(psc.quantity,0) desc, Trunc(psc.creation_date) desc,
       psc.price_override ASC) WHERE ROWNUM = 1;

    if (v_conv_rate < 0) then
      v_price_override := null;
    else
      v_price_override := v_price_override * v_conv_rate;
    end if;
    IF(v_price_override < v_lowest_price) THEN
      v_lowest_price := v_price_override;
    ELSIF(v_lowest_price < 0) THEN
      v_lowest_price := v_price_override;
    END IF;

    if (v_conv_rate < 0) then
      v_price_override_null := null;
    else
      v_price_override_null := v_price_override_null * v_conv_rate;
    end if;
   IF(v_price_override_null < v_lowest_price_null) THEN
      v_lowest_price_null := v_price_override_null;
   ELSIF(v_lowest_price_null < 0) THEN
      v_lowest_price_null := v_price_override_null;
   END IF;

   FETCH cur_line_id INTO v_line_id, v_conv_rate;

   EXIT WHEN cur_line_id%NOTFOUND;

   END LOOP;

   CLOSE cur_line_id;

   RETURN nvl(v_lowest_price, v_lowest_price_null);

  EXCEPTION
    WHEN others THEN
      v_buf := 'Get lowest cumulative price:  ' || sqlcode || ': ' || sqlerrm || ': ' || x_progress;
      ROLLBACK;
      POA_LOG.put_line(v_buf);
      POA_LOG.put_line(' ');

      RAISE;
  END get_lowest_ncum_price;


  /*
    NAME
     get_lowest_cum_price
    DESCRIPTION
     procedure for calculating lowest amount we could have
     purchased an item in a potential contract for had we
     used a blanket if the item has a cumulative price break
  */
  --

  FUNCTION get_lowest_cum_price(p_creation_date IN DATE,
                p_quantity IN NUMBER,
                p_unit_meas_lookup_code IN VARCHAR2,
                p_currency_code IN VARCHAR2,
                p_item_id IN NUMBER,
                p_item_revision IN VARCHAR2,
                p_category_id IN NUMBER,
                p_ship_to_location_id IN NUMBER,
                p_org_id IN NUMBER,
                p_ship_to_organization_id IN NUMBER,
                p_ship_to_ou IN NUMBER,
                p_rate_date IN DATE,
                p_edw_global_rate_type IN VARCHAR2,
                p_edw_global_currency_code IN VARCHAR2)
            RETURN NUMBER

  IS

  TYPE T_FLEXREF IS REF CURSOR;

  v_cursor_blk          T_FLEXREF;
  v_cursor_po_line      T_FLEXREF;

  v_lowest_price        NUMBER := 0;
  v_min_price           NUMBER := 0;
  v_min_price_global           NUMBER := 0;
  v_count               BINARY_INTEGER := 0;
  v_blanket_id          NUMBER;
  v_total_qty_released  NUMBER := 0;
  v_po_line_id          NUMBER;
  v_cursor_set          BOOLEAN := TRUE;
  v_buf                 VARCHAR2(240) := NULL;

  x_progress            VARCHAR2(3) := NULL;
  x_iteration_outer     NUMBER := 0;
  x_iteration_inner     NUMBER := 0;
  v_conv_rate           NUMBER := 0;

  v_match_location BOOLEAN := true;
  v_currency_code       VARCHAR2(15);
  BEGIN

   open v_cursor_blk for
    SELECT distinct psc.po_header_id, phc.currency_code
      FROM   po_headers_all phc
        ,      po_lines_all plc
        ,      po_line_locations_all psc
        WHERE  psc.shipment_type    = 'PRICE BREAK'
        and    phc.po_header_id     = plc.po_header_id
        and    plc.po_line_id       = psc.po_line_id
        and    psc.po_header_id     = phc.po_header_id
        and    plc.unit_meas_lookup_code = p_unit_meas_lookup_code
        and    p_creation_date between nvl(phc.start_date, p_creation_date)
                and nvl(phc.end_date, p_creation_date)
        and   plc.item_id           = p_item_id
        and   nvl(plc.item_revision, nvl(p_item_revision, '-1'))
			            = nvl(p_item_revision, '-1')
        and    psc.ship_to_location_id  = p_ship_to_location_id
        and    psc.po_release_id    is null
        and    plc.price_break_lookup_code = 'CUMULATIVE'
        and    trunc(p_creation_date) <= nvl(plc.expiration_date, p_creation_date)
        and    nvl(phc.global_agreement_flag, 'N') = 'N'
        and    phc.org_id = p_ship_to_ou;

   fetch v_cursor_blk into v_blanket_id, v_currency_code;
   if v_cursor_blk%NOTFOUND then
     close v_cursor_blk;
     v_match_location := FALSE;

     OPEN v_cursor_blk FOR
     SELECT distinct psc.po_header_id, phc.currency_code
      FROM   po_headers_all phc
        ,      po_lines_all plc
        ,      po_line_locations_all psc
        WHERE  psc.shipment_type    = 'PRICE BREAK'
        and    phc.po_header_id     = plc.po_header_id
        and    plc.po_line_id       = psc.po_line_id
        and    psc.po_header_id     = phc.po_header_id
        and    plc.unit_meas_lookup_code = p_unit_meas_lookup_code
        and    p_creation_date between nvl(phc.start_date, p_creation_date)
                and nvl(phc.end_date, p_creation_date)
        and   nvl(phc.currency_code, nvl(p_currency_code, '-1'))
	   			    = nvl(p_currency_code, '-1')
        and   plc.item_id           = p_item_id
        and   nvl(plc.item_revision, nvl(p_item_revision, '-1'))
			            = nvl(p_item_revision, '-1')
        and    psc.ship_to_location_id is null
        and    psc.po_release_id    is null
        and    plc.price_break_lookup_code = 'CUMULATIVE'
        and    nvl(phc.global_agreement_flag, 'N') = 'N'
        and    phc.org_id = p_ship_to_ou;

     FETCH v_cursor_blk INTO v_blanket_id, v_currency_code;
     if v_cursor_blk%NOTFOUND then
       close v_cursor_blk;
       return NULL;
     end if;
   end if;

      LOOP
--        POA_LOG.debug_line('  fetched v_cursor_blk row no. ' || x_iteration_outer);
--        POA_LOG.debug_line('  v_blanket_id: ' || v_blanket_id);

        -- Get the po_line_id from the blanket agreement that
        -- matches the item.

        x_progress := '070';
        OPEN v_cursor_po_line for
        SELECT plc.po_line_id
        FROM   po_lines_all plc
        WHERE  plc.po_header_id     = v_blanket_id
	  and    plc.item_id          = p_item_id
	  and    plc.price_break_lookup_code = 'CUMULATIVE'
	  and    plc.unit_meas_lookup_code = p_unit_meas_lookup_code
        and    nvl(plc.item_revision, nvl(p_item_revision, '-1')) = nvl(p_item_revision, '-1');

        x_iteration_inner := 0;
        LOOP
          x_iteration_inner := x_iteration_inner + 1;
          FETCH v_cursor_po_line INTO v_po_line_id;
          EXIT WHEN v_cursor_po_line%NOTFOUND;

--          POA_LOG.debug_line('  v_po_line_id: ' || v_po_line_id);

          -- Get the total quantity already released
          x_progress := '080';
          SELECT sum(nvl(pod.quantity_ordered,0)) INTO v_total_qty_released
          FROM po_releases_all por
          ,    po_distributions_all pod
          WHERE por.po_header_id        = v_blanket_id
          and   pod.po_release_id       = por.po_release_id
          and   pod.po_line_id          = v_po_line_id
          and   pod.creation_date       < p_creation_date
          and   nvl(pod.distribution_type,'-99')   <> 'AGREEMENT';

--          POA_LOG.debug_line('  v_total_qty_released: ' || v_total_qty_released);

          x_progress := '090';

          BEGIN
	     IF (v_match_location) then
		SELECT min(psc.price_override) INTO v_lowest_price
		  FROM po_line_locations_all psc
		  WHERE Nvl(psc.quantity,0)       <= Nvl(v_total_qty_released,0) + p_quantity
		  and   psc.po_release_id   is null
		  AND psc.ship_to_location_id  = p_ship_to_location_id
		  and   psc.po_line_id      = v_po_line_id;
	      else
		SELECT min(psc.price_override) INTO v_lowest_price
		  FROM po_line_locations_all psc
		  WHERE Nvl(psc.quantity,0)       <= Nvl(v_total_qty_released,0) + p_quantity
		  and   psc.po_release_id   is null
		  AND psc.ship_to_location_id IS NULL
		  and   psc.po_line_id      = v_po_line_id;
	      END IF;
          EXCEPTION
            WHEN OTHERS THEN  -- should never happen
	       x_progress := '110';
	       v_lowest_price := NULL;
/*
            SELECT min(plc.unit_price) INTO v_lowest_price
            FROM po_lines_all plc
	      WHERE plc.po_line_id      = v_po_line_id;
*/
          END;

          IF ((v_min_price = 0) or (v_lowest_price < v_min_price)) THEN
	     v_min_price := v_lowest_price;
          END IF;
        END LOOP;
        CLOSE v_cursor_po_line;

--        POA_LOG.debug_line('  v_cursor_po_line closed');
       select poa_savings_np.get_currency_conv_rate(v_currency_code,
                                           p_edw_global_currency_code,
                                           p_rate_date,
                                           p_edw_global_rate_type
                                          )
       into v_conv_rate
       from dual;
      if (v_conv_rate < 0) then
        v_min_price := null;
      else
        v_min_price := v_min_price * v_conv_rate;
      end if;
      if (v_min_price is not null) then
        if (v_min_price_global > v_min_price or v_min_price_global = 0) then
          v_min_price_global := v_min_price;
        end if;
      end if;
      v_min_price := 0;
       x_iteration_outer := x_iteration_outer + 1;
        FETCH v_cursor_blk INTO v_blanket_id, v_currency_code;
        EXIT WHEN v_cursor_blk%NOTFOUND;
      END LOOP;
      CLOSE v_cursor_blk;

--      POA_LOG.debug_line('  v_cursor_blk closed');

    RETURN v_min_price_global;
    POA_LOG.debug_line('Get_lowest_cum_price exit');
  EXCEPTION
    WHEN others THEN
      v_buf := 'Get lowest cumulative price: ' || sqlcode || ': ' || sqlerrm || ': ' || x_progress;

      ROLLBACK;

      POA_LOG.put_line(v_buf);
      POA_LOG.put_line(' ');

      RAISE;
  END get_lowest_cum_price;

END poa_savings_sav;

/

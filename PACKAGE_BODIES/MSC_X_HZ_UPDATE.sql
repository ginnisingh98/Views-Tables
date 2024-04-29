--------------------------------------------------------
--  DDL for Package Body MSC_X_HZ_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_HZ_UPDATE" AS
/*  $Header: MSCXHZUB.pls 120.2 2005/07/28 03:38:28 pragarwa noship $ */


   /**
    * The foll procedure has to update msc_sup_dem_entries with the
    *   updated values from the msc_hz_ui_lines table.
    * The proc has to do the foll.
    *   - using the query id - select the rows that have the quantities updated
    *      (where qty_bucket(X) <> old_qty(X) )
    *   - for each of the delta values - select the corresponding
    *      transactionids from msc_sup_dem_entries.
    *      order by quantity and createion date.
    *   - update the delta appropriately
    */

   module CONSTANT VARCHAR2(27) := 'msc.plsql.MSC_X_HZ_UPDATE.' ;
   DECPLACES CONSTANT NUMBER := 6;


   Procedure update_supdem_entries( arg_err_msg      OUT NOCOPY VARCHAR2,
                                    arg_query_id     IN  NUMBER
                                  )
   IS

      -- define the types
      TYPE num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      TYPE string IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
      TYPE big_string IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
      TYPE small_string IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
      TYPE small_string1 IS TABLE OF VARCHAR2(40) INDEX BY BINARY_INTEGER;
      TYPE calendar_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;

      WEEK_BUCKET CONSTANT NUMBER(1) := 2;
      MONTH_BUCKET CONSTANT NUMBER(1) := 3;

      temp NUMBER;


      proceed number(1) := 0;
      insert_rec number(1) := 0;

      -- define the variables needed
      v_pub_id number;
      v_pub_name varchar2(250);
      v_user_id NUMBER;

      v_item_id num;
      v_order_type num;
      v_qty1 num;
      v_qty2 num;
      v_qty3 num;
      v_qty4 num;
      v_qty5 num;
      v_qty6 num;
      v_qty7 num;
      v_qty8 num;
      v_qty9 num;
      v_qty10 num;
      v_qty11 num;
      v_qty12 num;
      v_qty13 num;
      v_qty14 num;
      v_qty15 num;
      v_qty16 num;
      v_qty17 num;
      v_qty18 num;
      v_qty19 num;
      v_qty20 num;
      v_qty21 num;
      v_qty22 num;
      v_qty23 num;
      v_qty24 num;
      v_qty25 num;
      v_qty26 num;
      v_qty27 num;
      v_qty28 num;
      v_qty29 num;
      v_qty30 num;
      v_qty31 num;
      v_qty32 num;
      v_qty33 num;
      v_qty34 num;
      v_qty35 num;
      v_qty36 num;

      v_old_qty1 num;
      v_old_qty2 num;
      v_old_qty3 num;
      v_old_qty4 num;
      v_old_qty5 num;
      v_old_qty6 num;
      v_old_qty7 num;
      v_old_qty8 num;
      v_old_qty9 num;
      v_old_qty10 num;
      v_old_qty11 num;
      v_old_qty12 num;
      v_old_qty13 num;
      v_old_qty14 num;
      v_old_qty15 num;
      v_old_qty16 num;
      v_old_qty17 num;
      v_old_qty18 num;
      v_old_qty19 num;
      v_old_qty20 num;
      v_old_qty21 num;
      v_old_qty22 num;
      v_old_qty23 num;
      v_old_qty24 num;
      v_old_qty25 num;
      v_old_qty26 num;
      v_old_qty27 num;
      v_old_qty28 num;
      v_old_qty29 num;
      v_old_qty30 num;
      v_old_qty31 num;
      v_old_qty32 num;
      v_old_qty33 num;
      v_old_qty34 num;
      v_old_qty35 num;
      v_old_qty36 num;
      v_pub_site_id num;

      v_item_name string;
      v_sup_name string;
      v_cust_name string;
      v_sup_site small_string;
      v_cust_site small_string;
      v_uom small_string;
      v_order_desc small_string;
      v_pub_site string;
      v_bucket_type num;

      v_item_desc string ;
      v_owner_item string;
      v_sup_item string;
      v_cust_item string ;
      v_owner_item_desc string;
      v_sup_item_desc string;
      v_cust_item_desc string;
      v_bucket_desc small_string;

      -- even though the foll are stored in a varchar2 field - for orgs these will be numbers.
      v_sup_id num;
      v_cust_id num;
      v_sup_site_id num;
      v_cust_site_id num;

      v_bkt1 date;
      v_bkt2 date;
      v_bkt3 date;
      v_bkt4 date;
      v_bkt5 date;
      v_bkt6 date;
      v_bkt7 date;
      v_bkt8 date;
      v_bkt9 date;
      v_bkt10 date;
      v_bkt11 date;
      v_bkt12 date;
      v_bkt13 date;
      v_bkt14 date;
      v_bkt15 date;
      v_bkt16 date;
      v_bkt17 date;
      v_bkt18 date;
      v_bkt19 date;
      v_bkt20 date;
      v_bkt21 date;
      v_bkt22 date;
      v_bkt23 date;
      v_bkt24 date;
      v_bkt25 date;
      v_bkt26 date;
      v_bkt27 date;
      v_bkt28 date;
      v_bkt29 date;
      v_bkt30 date;
      v_bkt31 date;
      v_bkt32 date;
      v_bkt33 date;
      v_bkt34 date;
      v_bkt35 date;
      v_bkt36 date;
      v_last_bkt date;

      v_trans_id num;
      v_p_qty num ;
      v_p_uom small_string ;
      v_uom_code small_string;
      v_tp_uom small_string;
      v_item num;

      -- pl/sql tables required for update
      v_upd_trans_id num;
      v_upd_p_qty num ;
      v_upd_qty num ;
      v_upd_tp_qty num;


      -- pl/sql tables required for insert.
      v_i_item_id num;
      v_i_cust_id num;
      v_i_sup_id num;
      v_i_pub_site_id num;
      v_i_cust_site_id num;
      v_i_sup_site_id num;
      v_i_p_qty num;
      v_i_order_type num;
      v_i_bucket num;
      v_i_tp_qty num;
      v_i_qty num;
      v_i_ship_from_id num;
      v_i_ship_from_site_id num;
      v_i_ship_to_id num;
      v_i_ship_to_site_id num;

      v_i_item string;
      v_i_item_desc string;
      v_i_owner_item string;
      v_i_cust_item string;
      v_i_sup_item string;
      v_i_cust string;
      v_i_sup string;
      v_i_cust_site small_string;
      v_i_sup_site small_string;
      v_i_pub_site_name small_string;
      v_i_p_uom small_string;
      v_i_order small_string;
      v_i_bucket_desc small_string;
      v_i_owner_item_desc string;
      v_i_cust_item_desc string;
      v_i_sup_item_desc string;
      v_i_tp_uom small_string;
      v_i_uom_code small_string;
      v_i_ship_from string;
      v_i_ship_to string;
      v_i_ship_from_site small_string;
      v_i_ship_to_site small_string;


      v_i_date calendar_date;

      k number;
      i number;


      -- cursor to fetch the transaction ids from msc_sup_dem_entries;
      -- using primary_quantity for orde by as for publisher we always display the primary qty on the hz view
      -- and only publisher can edit the records on HZ View.
      CURSOR c_transids (arg_item IN NUMBER, arg_order_type IN NUMBER, arg_cust IN VARCHAR2,
                         arg_sup IN VARCHAR2, arg_cust_site IN VARCHAR2, arg_sup_site IN VARCHAR2,
                         arg_start IN DATE, arg_end IN DATE)
      IS
         SELECT transaction_id,primary_quantity,primary_uom,uom_code,tp_uom_code,inventory_item_id
           FROM msc_sup_dem_entries_ui_v
          WHERE inventory_item_id = arg_item
            AND customer_name = arg_cust
            AND supplier_name = arg_sup
            AND customer_site_name= arg_cust_site
            AND supplier_site_name = arg_sup_site
            AND publisher_order_type = arg_order_type
            AND key_date >= arg_start
            AND key_date < arg_end
          ORDER BY primary_quantity, creation_date;

      /**
       * The folowing procedure adds the required updatable columns to the
       * appropriate pl/sql srtuctures.
       */
      PROCEDURE set_for_update(arg_new_qty in number,
                               arg_old_qty in number,
                               arg_start IN DATE,
                               arg_end IN DATE,
                               arg_pos IN NUMBER)
      IS
         k number;
         l number;
         i number := arg_pos;

         v_delta number;
      BEGIN
      --dbms_output.put_line('pkaligot : 89 : in set_for_update with cnt :' || arg_pos );
         insert_rec := 1;
         -- add to update structure the changed qty.
         open c_transids (v_item_id(i), v_order_type(i), v_cust_name(i), v_sup_name(i),
                          v_cust_site(i), v_sup_site(i), arg_start, arg_end) ;

         fetch c_transids bulk collect into
                               v_trans_id,v_p_qty,v_p_uom,v_uom_code,v_tp_uom, v_item ;
         close c_transids;

         IF v_trans_id.COUNT > 0 THEN

            k := v_upd_trans_id.COUNT + 1;
            l := v_trans_id.FIRST ;
            insert_rec := 0;

            v_delta := (arg_new_qty - arg_old_qty) ;
            v_delta := -1 * v_delta ;

            -- loop through the result till the delta = 0.

            for l in v_trans_id.FIRST..v_trans_id.LAST loop

               k := v_upd_trans_id.COUNT + 1;

               v_upd_trans_id(k) := v_trans_id(l);

               IF v_p_qty(l) <  v_delta THEN
                  v_upd_p_qty(k) := 0;
                  v_upd_qty(k) := 0;
                  v_upd_tp_qty(k) := 0;

               ELSE
                  v_upd_p_qty(k) := v_p_qty(l) - v_delta;

                  v_upd_qty(k) := MSC_SCE_LOADS_PKG.get_quantity(v_upd_p_qty(k),
                                                                 v_p_uom(l),
                                                                 v_uom_code(l),
                                                                 v_item(l) );

                  v_upd_tp_qty(k) := MSC_SCE_LOADS_PKG.get_quantity(v_upd_p_qty(k),
                                                                 v_p_uom(l),
                                                                 v_tp_uom(l),
                                                                 v_item(l) );


               END IF;

               v_delta := v_delta - v_p_qty(l) ;

               IF v_delta <= 0 THEN
                  EXIT;
               END IF;

            end loop;

         END IF;

      EXCEPTION
         when others then
            proceed := 1;
	     if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'set_for_update', SQLERRM);
	    end if;

            arg_err_msg := 'MSC_X_HZ_UPDATE@set_for_update ' || SQLERRM;
      END set_for_update;


      /**
       * The folowing procedure adds the required insert new columns to the
       * appropriate pl/sql srtuctures.
       */
      PROCEDURE set_for_insert(arg_pos IN NUMBER, arg_start IN DATE, arg_qty IN NUMBER)
      IS
         cnt number;
         v_date date;
         v_start varchar2(20);
	 l_item_desc VARCHAR2(240);
	 l_primary_uom VARCHAR2(80);
	 l_tp_uom VARCHAR2(80);

	 CURSOR publisher_is_supplier
	   (p_i_item_id NUMBER,
	    p_i_cust_site_id IN NUMBER,
	    p_pub_id IN NUMBER,
	    p_i_pub_site_id IN NUMBER) IS
	       SELECT mis.uom_code
		 FROM msc_item_suppliers mis,
		 msc_trading_partner_maps map,
		 msc_trading_partners mtp,
		 msc_trading_partner_maps map1,
		 msc_company_relationships rel,
		 msc_trading_partner_maps map2
		 WHERE mis.inventory_item_id = p_i_item_id
		 AND mis.plan_id = -1
		 AND mis.organization_id = mtp.sr_tp_id
		 AND mis.sr_instance_id = mtp.sr_instance_id
		 AND mtp.partner_id = map.tp_key
		 AND map.map_type = 2
		 AND map.company_key = p_i_cust_site_id
		 AND mis.supplier_id = map1.tp_key
		 AND map1.company_key = rel.relationship_id
		 AND map1.map_type = 1
		 AND rel.relationship_type = 2
		 AND rel.subject_id = 1
		 AND rel.object_id = p_pub_id
		 AND mis.supplier_site_id = map2.tp_key
		 AND map2.map_type = 3
		 AND map2.company_key = p_i_pub_site_id
		 ORDER BY mis.using_organization_id DESC;

	 CURSOR supplier_item_c
	   (p_item_id NUMBER,
	    p_pub_site_id NUMBER,
	    p_supp_id NUMBER,
	    p_supp_site_id NUMBER) IS
	       SELECT mis.uom_code
		 FROM msc_item_suppliers mis,
		 msc_trading_partner_maps map,
		 msc_trading_partner_maps map1,
		 msc_trading_partner_maps map2,
		 msc_trading_partners mtp,
		 msc_company_relationships r
		 where  mis.inventory_item_id = p_item_id and
		 mis.plan_id = -1 and
		 mis.organization_id = mtp.sr_tp_id and
		 mis.sr_instance_id = mtp.sr_instance_id and
		 mtp.partner_id = map2.tp_key and
		 mtp.partner_type = 3 and
		 map2.company_key =  p_pub_site_id and
		 map2.map_type = 2 and
		 mis.supplier_id = map.tp_key and
		 mis.supplier_site_id = map1.tp_key and
		 map.map_type = 1 and
		 map.company_key = r.relationship_id and
		 r.relationship_type = 2 and
		 r.subject_id = 1 and
		 r.object_id = p_supp_id and
		 map1.map_type = 3 and
		 map1.company_key = p_supp_site_id
		 order by mis.using_organization_id desc;

      BEGIN
         cnt := v_i_item_id.COUNT + 1;
         ----dbms_output.put_line('pkaligot : 90 : in set_for_insert with cnt :' || arg_pos );

         v_start := to_char(arg_start, 'DD/MM/YYYY HH24:MI:SS');

         -- make the calculations for the exact date here
         -- the date should be the first beginning after the start and before the end.

         if v_bucket_type(arg_pos) = WEEK_BUCKET then
            SELECT cal.prior_date
              INTO v_date
              FROM msc_calendar_dates cal, msc_cal_week_start_dates wsd
             WHERE cal.calendar_code = wsd.calendar_code
               AND wsd.calendar_code = 'CP-Mon-70'
               AND wsd.exception_set_id = -1
               AND wsd.sr_instance_id = 0
               AND wsd.next_date > TRUNC(TO_DATE(v_start, 'DD/MM/YYYY HH24:MI:SS'))
               AND wsd.week_start_date <=   TRUNC(TO_DATE(v_start, 'DD/MM/YYYY HH24:MI:SS'))
               AND cal.exception_set_id = wsd.exception_set_id
               AND cal.sr_instance_id = wsd.sr_instance_id
               AND cal.calendar_date = wsd.week_start_date ;

         elsif v_bucket_type(arg_pos) = MONTH_BUCKET then

            SELECT cal.next_date
              INTO v_date
              FROM msc_calendar_dates cal, msc_period_start_dates psd
             WHERE psd.calendar_code = 'CP-Mon-70' AND
                   psd.exception_set_id = -1 AND
                   psd.sr_instance_id = 0 AND
                   psd.next_date > TRUNC(TO_DATE(v_start, 'DD/MM/YYYY HH24:MI:SS')) AND
                   psd.period_start_date <= TRUNC(TO_DATE(v_start, 'DD/MM/YYYY HH24:MI:SS')) AND
                   cal.calendar_code = psd.calendar_code AND
                   cal.exception_set_id = psd.exception_set_id AND
                   cal.sr_instance_id = psd.sr_instance_id AND
                   cal.calendar_date = psd.period_start_date  ;
         else
            v_date := arg_start;

         end if;

         v_i_date(cnt) := v_date;
         v_i_item_id(cnt) := v_item_id(arg_pos);
         v_i_item(cnt) := v_item_name(arg_pos);
         v_i_item_desc(cnt) := v_item_desc(arg_pos);

	 IF v_i_item_desc(cnt) is NULL THEN
	    BEGIN
	       SELECT description
		 INTO l_item_desc
		 FROM msc_items
		 WHERE inventory_item_id = v_i_item_id(cnt);
	    EXCEPTION
	       WHEN OTHERS THEN
		  l_item_desc := NULL;
	    END;
	    v_i_item_desc(cnt) := l_item_desc;
	 END IF;

         v_i_owner_item(cnt) := v_owner_item(arg_pos);
         v_i_owner_item_desc(cnt) := v_owner_item_desc(arg_pos);
         v_i_cust_item(cnt) := v_cust_item(arg_pos);
         v_i_sup_item(cnt) := v_sup_item(arg_pos);
         v_i_cust_item_desc(cnt) := v_cust_item_desc(arg_pos);
         v_i_sup_item_desc(cnt) := v_sup_item_desc(arg_pos);

         v_i_pub_site_name(cnt) := v_pub_site(arg_pos);
         v_i_pub_site_id(cnt) := v_pub_site_id(arg_pos);

         v_i_cust_id(cnt) := v_cust_id(arg_pos);
         v_i_cust(cnt) := v_cust_name(arg_pos);
         v_i_cust_site_id(cnt) := v_cust_site_id(arg_pos);
         v_i_cust_site(cnt) := v_cust_site(arg_pos);

         v_i_sup_id(cnt) := v_sup_id(arg_pos);
         v_i_sup(cnt) := v_sup_name(arg_pos);
         v_i_sup_site_id(cnt) := v_sup_site_id(arg_pos);
         v_i_sup_site(cnt) := v_sup_site(arg_pos);


         v_i_order_type(cnt) := v_order_type(arg_pos);
         v_i_order(cnt) := nvl(MSC_X_HZ_PLAN.get_lookup_name('MSC_X_ORDER_TYPE',v_i_order_type(cnt)),'NA') ;
         v_i_bucket(cnt) := v_bucket_type(arg_pos);
         v_i_bucket_desc(cnt) := nvl(MSC_X_HZ_PLAN.get_lookup_name('MSC_X_BUCKET_TYPE',v_i_bucket(cnt)),'NA');


	 IF v_i_order_type(cnt) IN (2,3) THEN
	    v_i_ship_from_id(cnt) := v_sup_id(arg_pos);
	      v_i_ship_from_site_id(cnt) := v_sup_site_id(arg_pos);
	      v_i_ship_from(cnt) := v_sup_name(arg_pos);
	      v_i_ship_from_site(cnt) := v_sup_site(arg_pos);
	      v_i_ship_to_id(cnt) := v_cust_id(arg_pos);
	      v_i_ship_to_site_id(cnt) := v_cust_site_id(arg_pos);
	      v_i_ship_to(cnt) := v_cust_name(arg_pos);
	      v_i_ship_to_site(cnt) := v_cust_site(arg_pos);
	 ELSE
	    v_i_ship_from_id(cnt) := NULL;
	      v_i_ship_from_site_id(cnt) := NULL;
	      v_i_ship_from(cnt) := NULL;
	      v_i_ship_from_site(cnt) := NULL;
	      v_i_ship_to_id(cnt) := NULL;
	      v_i_ship_to_site_id(cnt) := NULL;
	      v_i_ship_to(cnt) := NULL;
	      v_i_ship_to_site(cnt) := NULL;
	 END IF;


         v_i_p_qty(cnt) := arg_qty;

	 --Set the loaded uom
	 v_i_uom_code(cnt) := v_uom(arg_pos);

	 --Obtain the primary uom
	 IF (v_pub_id = 1) THEN
	    BEGIN
	       SELECT msi.uom_code
		 INTO l_primary_uom
		 FROM msc_system_items msi,
		 msc_trading_partners part,
		 msc_trading_partner_maps map
		 WHERE msi.inventory_item_id = v_i_item_id(cnt)
		 AND msi.organization_id = part.sr_tp_id
		 AND msi.sr_instance_id = part.sr_instance_id
		 AND msi.plan_id = -1
		 AND part.partner_id = map.tp_key
		 AND map.company_key = v_i_pub_site_id(cnt)
		 AND map.map_type = 2
		 AND Nvl(part.company_id,1) = v_pub_id;
	    EXCEPTION
	       WHEN OTHERS THEN
		  l_primary_uom := v_uom(arg_pos);
	    END;
	    -- If publisher is not the OEM and order type is Supply Commit
	    -- Fetch uom from the ASL, since publisher is usually the supplier.
	  ELSIF (v_pub_id <> 1) AND (v_i_order_type(cnt) = 3) THEN
		  OPEN publisher_is_supplier(v_i_item_id(cnt),
					     v_i_cust_site_id(cnt),
					     v_pub_id,
					     v_i_pub_site_id(cnt));
		  FETCH publisher_is_supplier
		    INTO l_primary_uom;

		 IF (publisher_is_supplier%notfound or l_primary_uom is null )THEN
		     CLOSE publisher_is_supplier;
		     --If the ASL is not present, derive the primary uom from the oem
		     BEGIN
			SELECT msi.uom_code
			  INTO l_primary_uom
			  FROM msc_system_items msi,
			  msc_trading_partners part,
			  msc_trading_partner_maps map
			  WHERE msi.inventory_item_id = v_i_item_id(cnt)
			  AND msi.organization_id = part.sr_tp_id
			  AND msi.sr_instance_id = part.sr_instance_id
			  AND msi.plan_id = -1
			  AND part.partner_id = map.tp_key
			  AND map.map_type = 2
			  AND map.company_key = Decode(v_i_sup_id(cnt),
						       v_pub_id, v_i_cust_site_id(cnt),
						       v_i_sup_site_id(cnt))
			  AND Nvl(part.company_id,1) = Decode(v_i_sup_id(cnt),
							      v_pub_id, v_i_cust_id(cnt),
							      v_i_sup_id(cnt));
		     EXCEPTION
			WHEN OTHERS THEN
			   l_primary_uom := v_uom(arg_pos);
		     END;
		  END IF;
		  IF publisher_is_supplier%ISOPEN THEN
		     CLOSE publisher_is_supplier;
		  END IF;
		  --If the publisher is not the OEM and the order type is order forecast
		  --obtain the uom from MSC_ITEM_CUSTOMERS, since the publisher is usually
		  --the customer
	  ELSIF (v_pub_id <> 1) AND (v_i_order_type(cnt) = 2) THEN
            BEGIN
	       SELECT mic.uom_code
		 INTO l_primary_uom
		 FROM msc_item_customers mic,
		 msc_trading_partner_maps map,
		 msc_trading_partner_maps map1,
		 msc_company_relationships r
		 WHERE mic.inventory_item_id = v_i_item_id(cnt)
		 AND mic.plan_id = -1
		 AND mic.customer_id = map.tp_key
		 AND mic.customer_site_id = map1.tp_key
		 AND map.map_type = 1
		 AND map.company_key = r.relationship_id
		 AND r.relationship_type = 1
		 AND r.subject_id = 1
		 AND r.object_id = v_pub_id
		 AND map1.map_type = 3
		 AND map1.company_key = v_i_pub_site_id(cnt);
	    EXCEPTION
	       WHEN OTHERS THEN
		  --If the uom is not available from MIC, derive it from the OEM
	          BEGIN
		     SELECT msi.uom_code
		       INTO l_primary_uom
		       FROM msc_system_items msi,
		       msc_trading_partners part,
		       msc_trading_partner_maps map
		       WHERE msi.inventory_item_id = v_i_item_id(cnt)
		       AND msi.organization_id = part.sr_tp_id
		       AND msi.sr_instance_id = part.sr_instance_id
		       AND msi.plan_id = -1
		       AND part.partner_id = map.tp_key
		       AND map.map_type = 2
		       AND map.company_key = Decode(v_i_sup_id(cnt),
						    v_pub_id, v_i_cust_site_id(cnt),
						    v_i_sup_site_id(cnt))
		       AND Nvl(part.company_id,1) = Decode(v_i_sup_id(cnt),
							   v_pub_id, v_i_cust_id(cnt),
							   v_i_sup_id(cnt));
		  EXCEPTION
		     WHEN OTHERS THEN
			l_primary_uom := v_uom(arg_pos);
		  END;
	    END;
	 END IF;

	 v_i_p_uom(cnt) := l_primary_uom;

	 --Obtain the tp uom
	 IF (v_pub_id = v_i_sup_id(cnt)) THEN
	    --Customer is the tp
	    IF (v_i_cust_id(cnt) = 1) THEN
	       BEGIN
		  SELECT msi.uom_code
		    INTO l_tp_uom
		    FROM msc_system_items msi,
		    msc_trading_partners part,
		    msc_trading_partner_maps map
		    WHERE msi.inventory_item_id = v_i_item_id(cnt)
		    AND msi.organization_id = part.sr_tp_id
		    AND msi.sr_instance_id = part.sr_instance_id
		    AND msi.plan_id = -1
		    AND part.partner_id = map.tp_key
		    AND map.map_type = 2
		    AND map.company_key = v_i_cust_site_id(cnt)
		    AND Nvl(part.company_id,1) = v_i_cust_id(cnt);
	       EXCEPTION
		  WHEN OTHERS THEN
		     l_tp_uom := v_i_p_uom(cnt);
	       END;
	     ELSE
		     BEGIN
			SELECT mic.uom_code
			  INTO l_tp_uom
			  FROM msc_item_customers mic,
			  msc_trading_partner_maps map,
			  msc_trading_partner_maps map1,
			  msc_company_relationships r
			  WHERE mic.inventory_item_id = v_i_item_id(cnt)
			  AND mic.plan_id = -1
			  AND mic.customer_id = map.tp_key
			  AND mic.customer_site_id = map1.tp_key
			  AND map.map_type = 1
			  AND map.company_key = r.relationship_id
			  AND r.relationship_type = 1
			  AND r.subject_id = 1
			  AND r.object_id = v_i_cust_id(cnt)
			  AND map1.map_type = 3
			  AND map1.company_key = v_i_cust_site_id(cnt);
		     EXCEPTION
			WHEN OTHERS THEN
			   l_tp_uom := v_i_p_uom(cnt);
		     END;

	    END IF;

	  ELSIF (v_pub_id = v_i_cust_id(cnt)) THEN
	    --Supplier is the tp
	    IF (v_i_sup_id(cnt) = 1) THEN
	       BEGIN
		  SELECT msi.uom_code
		    INTO l_tp_uom
		    FROM msc_system_items msi,
		    msc_trading_partners part,
		    msc_trading_partner_maps map
		    WHERE msi.inventory_item_id = v_i_item_id(cnt)
		    AND msi.organization_id = part.sr_tp_id
		    AND msi.sr_instance_id = part.sr_instance_id
		    AND msi.plan_id = -1
		    AND part.partner_id = map.tp_key
		    AND map.map_type = 2
		    AND map.company_key = v_i_sup_site_id(cnt)
		    AND Nvl(part.company_id,1) = v_i_sup_id(cnt);
	       EXCEPTION
		  WHEN OTHERS THEN
		     l_tp_uom := v_i_p_uom(cnt);
	       END;
	     ELSE
		     OPEN supplier_item_c(v_i_item_id(cnt),
					  v_i_pub_site_id(cnt),
					  v_i_sup_id(cnt),
					  v_i_sup_site_id(cnt));

		     FETCH supplier_item_c INTO l_tp_uom;

		     IF supplier_item_c%notfound THEN
			l_tp_uom := v_i_p_uom(cnt);
		     END IF;
	    END IF;

	 END IF;

	 v_i_tp_uom(cnt) := l_tp_uom;

         v_i_tp_qty(cnt) := MSC_SCE_LOADS_PKG.get_quantity(v_i_p_qty(cnt),
                                                           v_i_p_uom(cnt),
                                                           v_i_tp_uom(cnt),
                                                           v_i_item_id(cnt) );

         v_i_qty(cnt) := MSC_SCE_LOADS_PKG.get_quantity(v_i_p_qty(cnt),
                                                           v_i_p_uom(cnt),
                                                           v_i_uom_code(cnt),
                                                           v_i_item_id(cnt) );

      EXCEPTION
         when others then
            proceed := 1;
	    if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'set_for_insert', SQLERRM);
	    end if;
            arg_err_msg := 'MSC_X_HZ_UPDATE@set_for_insert ' || SQLERRM;
            --dbms_output.put_line('pkaligot : 50 : arg_err_msg :' || arg_err_msg );

      END set_for_insert;


   BEGIN

      SELECT sys_context('MSC','COMPANY_ID'), sys_context('MSC','COMPANY_NAME')
        INTO v_pub_id, v_pub_name
        FROM DUAL;

      -- select the date bkts .
      SELECT BUCKET1,nvl(BUCKET2,LAST_BUCKET),nvl(BUCKET3,LAST_BUCKET),nvl(BUCKET4,LAST_BUCKET),
             nvl(BUCKET5,LAST_BUCKET),nvl(BUCKET6,LAST_BUCKET),nvl(BUCKET7,LAST_BUCKET),
             nvl(BUCKET8,LAST_BUCKET),nvl(BUCKET9,LAST_BUCKET),nvl(BUCKET10,LAST_BUCKET),
             nvl(BUCKET11,LAST_BUCKET),nvl(BUCKET12,LAST_BUCKET),nvl(BUCKET13,LAST_BUCKET),
             nvl(BUCKET14,LAST_BUCKET),nvl(BUCKET15,LAST_BUCKET),nvl(BUCKET16,LAST_BUCKET),
             nvl(BUCKET17,LAST_BUCKET),nvl(BUCKET18,LAST_BUCKET),nvl(BUCKET19,LAST_BUCKET),
             nvl(BUCKET20,LAST_BUCKET),nvl(BUCKET21,LAST_BUCKET),nvl(BUCKET22,LAST_BUCKET),
             nvl(BUCKET23,LAST_BUCKET),nvl(BUCKET24,LAST_BUCKET),nvl(BUCKET25,LAST_BUCKET),
             nvl(BUCKET26,LAST_BUCKET),nvl(BUCKET27,LAST_BUCKET),nvl(BUCKET28,LAST_BUCKET),
             nvl(BUCKET29,LAST_BUCKET),nvl(BUCKET30,LAST_BUCKET),nvl(BUCKET31,LAST_BUCKET),
             nvl(BUCKET32,LAST_BUCKET),nvl(BUCKET33,LAST_BUCKET),nvl(BUCKET34,LAST_BUCKET),
             nvl(BUCKET35,LAST_BUCKET),nvl(BUCKET36,LAST_BUCKET),LAST_BUCKET
        INTO v_bkt1,v_bkt2,v_bkt3,v_bkt4,v_bkt5,v_bkt6,v_bkt7,v_bkt8,v_bkt9,v_bkt10,
             v_bkt11,v_bkt12,v_bkt13,v_bkt14,v_bkt15,v_bkt16,v_bkt17,v_bkt18,v_bkt19,
             v_bkt20,v_bkt21,v_bkt22,v_bkt23,v_bkt24,v_bkt25,v_bkt26,v_bkt27,v_bkt28,
             v_bkt29,v_bkt30,v_bkt31,v_bkt32,v_bkt33,v_bkt34,v_bkt35,v_bkt36,v_last_bkt
        FROM msc_hz_ui_headers
       WHERE query_id = arg_query_id ;


      -- select the changed quantities.
      SELECT inventory_item_id,item_name,supplier_id,customer_id,supplier_site_id,
             customer_site_id,supplier_name,customer_name,supplier_org_code,customer_org_code,
             order_type,order_type_desc,uom,owner_item,sup_item,cust_item,item_description,
             owner_item_desc,sup_item_desc,cust_item_desc,from_org_code,bucket_type,
             qty_bucket1,qty_bucket2,qty_bucket3,qty_bucket4,qty_bucket5,qty_bucket6,qty_bucket7,
             qty_bucket8,qty_bucket9,qty_bucket10,qty_bucket11,qty_bucket12,qty_bucket13,
             qty_bucket14,qty_bucket15,qty_bucket16,qty_bucket17,qty_bucket18,qty_bucket19,
             qty_bucket20,qty_bucket21,qty_bucket22,qty_bucket23,qty_bucket24,qty_bucket25,
             qty_bucket26,qty_bucket27,qty_bucket28,qty_bucket29,qty_bucket30,qty_bucket31,
             qty_bucket32,qty_bucket33,qty_bucket34,qty_bucket35,qty_bucket36,
             old_qty1,old_qty2,old_qty3,old_qty4,old_qty5,old_qty6,old_qty7,old_qty8,
             old_qty9,old_qty10,old_qty11,old_qty12,old_qty13,old_qty14,old_qty15,
             old_qty16,old_qty17,old_qty18,old_qty19,old_qty20,old_qty21,old_qty22,
             old_qty23,old_qty24,old_qty25,old_qty26,old_qty27,old_qty28,old_qty29,
             old_qty30,old_qty31,old_qty32,old_qty33,old_qty34,old_qty35,old_qty36,
             publisher_site_id
        BULK COLLECT INTO
             v_item_id, v_item_name, v_sup_id, v_cust_id, v_sup_site_id, v_cust_site_id,
             v_sup_name,v_cust_name,v_sup_site,v_cust_site,v_order_type,v_order_desc,v_uom,
             v_owner_item,v_sup_item,v_cust_item,v_item_desc,v_owner_item_desc,v_sup_item_desc,
             v_cust_item_desc,v_pub_site,v_bucket_type,v_qty1,v_qty2,v_qty3,v_qty4,
             v_qty5,v_qty6,v_qty7,v_qty8,v_qty9,v_qty10,v_qty11,v_qty12,v_qty13,v_qty14,v_qty15,
             v_qty16,v_qty17,v_qty18,v_qty19,v_qty20,v_qty21,v_qty22,v_qty23,v_qty24,v_qty25,v_qty26,
             v_qty27,v_qty28,v_qty29,v_qty30,v_qty31,v_qty32,v_qty33,v_qty34,v_qty35,v_qty36,
             v_old_qty1,v_old_qty2,v_old_qty3,v_old_qty4,v_old_qty5,v_old_qty6,v_old_qty7,v_old_qty8,
             v_old_qty9,v_old_qty10,v_old_qty11,v_old_qty12,v_old_qty13,v_old_qty14,v_old_qty15,
             v_old_qty16,v_old_qty17,v_old_qty18,v_old_qty19,v_old_qty20,v_old_qty21,v_old_qty22,
             v_old_qty23,v_old_qty24,v_old_qty25,v_old_qty26,v_old_qty27,v_old_qty28,v_old_qty29,
             v_old_qty30,v_old_qty31,v_old_qty32,v_old_qty33,v_old_qty34,v_old_qty35,v_old_qty36,
             v_pub_site_id
        FROM msc_hz_ui_lines
       WHERE query_id = arg_query_id
         AND editable_flag = 0
         AND ( ((nvl(qty_bucket1,0) - nvl(old_qty1,0)) <> 0 AND qty_bucket1 is not null) OR ((nvl(qty_bucket2,0) - nvl(old_qty2,0)) <> 0 AND qty_bucket2 is not null) OR
               ((nvl(qty_bucket3,0) - nvl(old_qty3,0)) <> 0 AND qty_bucket3 is not null) OR ((nvl(qty_bucket4,0) - nvl(old_qty4,0)) <> 0 AND qty_bucket4 is not null) OR
               ((nvl(qty_bucket5,0) - nvl(old_qty5,0)) <> 0 AND qty_bucket5 is not null) OR ((nvl(qty_bucket6,0) - nvl(old_qty6,0)) <> 0 AND qty_bucket6 is not null) OR
               ((nvl(qty_bucket7,0) - nvl(old_qty7,0)) <> 0 AND qty_bucket7 is not null) OR ((nvl(qty_bucket8,0) - nvl(old_qty8,0)) <> 0 AND qty_bucket8 is not null) OR
               ((nvl(qty_bucket9,0) - nvl(old_qty9,0)) <> 0 AND qty_bucket9 is not null) OR ((nvl(qty_bucket10,0) - nvl(old_qty10,0)) <> 0  AND qty_bucket10 is not null) OR
               ((nvl(qty_bucket11,0) - nvl(old_qty11,0)) <> 0 AND qty_bucket11 is not null) OR ((nvl(qty_bucket12,0) - nvl(old_qty12,0)) <> 0 AND qty_bucket12 is not null) OR
               ((nvl(qty_bucket13,0) - nvl(old_qty13,0)) <> 0 AND qty_bucket13 is not null) OR ((nvl(qty_bucket14,0) - nvl(old_qty14,0)) <> 0 AND qty_bucket14 is not null) OR
               ((nvl(qty_bucket15,0) - nvl(old_qty15,0)) <> 0 AND qty_bucket15 is not null) OR ((nvl(qty_bucket16,0) - nvl(old_qty16,0)) <> 0 AND qty_bucket16 is not null) OR
               ((nvl(qty_bucket17,0) - nvl(old_qty17,0)) <> 0 AND qty_bucket17 is not null) OR ((nvl(qty_bucket18,0) - nvl(old_qty18,0)) <> 0 AND qty_bucket18 is not null) OR
               ((nvl(qty_bucket19,0) - nvl(old_qty19,0)) <> 0 AND qty_bucket19 is not null) OR ((nvl(qty_bucket20,0) - nvl(old_qty20,0)) <> 0 AND qty_bucket20 is not null) OR
               ((nvl(qty_bucket21,0) - nvl(old_qty21,0)) <> 0 AND qty_bucket21 is not null) OR ((nvl(qty_bucket22,0) - nvl(old_qty22,0)) <> 0 AND qty_bucket22 is not null) OR
               ((nvl(qty_bucket23,0) - nvl(old_qty23,0)) <> 0 AND qty_bucket23 is not null) OR ((nvl(qty_bucket24,0) - nvl(old_qty24,0)) <> 0 AND qty_bucket24 is not null) OR
               ((nvl(qty_bucket25,0) - nvl(old_qty25,0)) <> 0 AND qty_bucket25 is not null) OR ((nvl(qty_bucket26,0) - nvl(old_qty26,0)) <> 0 AND qty_bucket26 is not null) OR
               ((nvl(qty_bucket27,0) - nvl(old_qty27,0)) <> 0 AND qty_bucket27 is not null) OR ((nvl(qty_bucket28,0) - nvl(old_qty28,0)) <> 0 AND qty_bucket28 is not null) OR
               ((nvl(qty_bucket29,0) - nvl(old_qty29,0)) <> 0 AND qty_bucket29 is not null) OR ((nvl(qty_bucket30,0) - nvl(old_qty30,0)) <> 0 AND qty_bucket30 is not null) OR
               ((nvl(qty_bucket31,0) - nvl(old_qty31,0)) <> 0 AND qty_bucket31 is not null) OR ((nvl(qty_bucket32,0) - nvl(old_qty32,0)) <> 0 AND qty_bucket32 is not null) OR
               ((nvl(qty_bucket33,0) - nvl(old_qty33,0)) <> 0 AND qty_bucket33 is not null) OR ((nvl(qty_bucket34,0) - nvl(old_qty34,0)) <> 0 AND qty_bucket34 is not null) OR
               ((nvl(qty_bucket35,0) - nvl(old_qty35,0)) <> 0 AND qty_bucket35 is not null) OR ((nvl(qty_bucket36,0) - nvl(old_qty36,0)) <> 0 AND qty_bucket36 is not null)
             ) ;


       --dbms_output.put_line(' pkaligot : before entering the insert/update block' );
       --dbms_output.put_line(' pkaligot : 98 : arg_query_id :' || arg_query_id );
       --dbms_output.put_line(' pkaligot : 99 : v_item_id.COUNT :' || v_item_id.COUNT );

       if v_item_id is not null AND v_item_id.COUNT > 0 then

       --dbms_output.put_line(' pkaligot : output 100' );

         FOR i in v_item_id.FIRST..v_item_id.LAST LOOP
            -- get the corresponding dates - start and end of bucket

            -- here need to go through each and every row in every quantity bucket
            -- and then make the change.
            --  one way to do this
            --    get all the transid (along with key_date) required for that row
            --    while processing the row - check the date of each transaction
            --      to figure if it is in that bucket.
            --  another way is to go row wise and then col wise for each bucket col.
            -- NOTE : if trans id was not found while seting the update array and the old qnty is 0,
            -- then it is a new record.

            --dbms_output.put_line(' pkaligot : output 101' );


            if v_old_qty1(i) IS NOT NULL  AND  v_qty1(i) <> v_old_qty1(i) then
               set_for_update(v_qty1(i), v_old_qty1(i), v_bkt1, v_bkt2, i );
               --dbms_output.put_line(' pkaligot 1 : insert_rec: ' || insert_rec);
               if insert_rec = 1 AND v_old_qty1(i) = 0 then
                  set_for_insert(i,v_bkt1,v_qty1(i)) ;
                  --dbms_output.put_line(' pkaligot : in qty1 : insert_rec');
                  insert_rec := 0;
               end if;
            elsif v_old_qty1(i) IS NULL AND v_qty1(i) IS NOT NULL then -- new record.
               -- the new records for insert added to insert array
               set_for_insert(i,v_bkt1,v_qty1(i)) ;
            end if;

            if v_old_qty2(i) IS NOT NULL  AND  v_qty2(i) <> v_old_qty2(i) then
               set_for_update(v_qty2(i), v_old_qty2(i), v_bkt2, v_bkt3, i );
               if insert_rec = 1 AND v_old_qty2(i) = 0 then
                  set_for_insert(i,v_bkt2,v_qty2(i)) ;
                  insert_rec := 0;
               end if;
               --dbms_output.put_line(' pkaligot : in qty2 update block' );
            elsif v_old_qty2(i) IS NULL AND v_qty2(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt2,v_qty2(i)) ;
               --dbms_output.put_line(' pkaligot : in qty2 insert block' );
            end if;

            if v_old_qty3(i) IS NOT NULL AND  v_qty3(i) <> v_old_qty3(i) then
               set_for_update(v_qty3(i), v_old_qty3(i), v_bkt3, v_bkt4, i );
               if insert_rec = 1 AND v_old_qty3(i) = 0 then
                  set_for_insert(i,v_bkt3,v_qty3(i)) ;
                  insert_rec := 0;
               end if;
               --dbms_output.put_line(' pkaligot : in qty3 update block' );
            elsif v_old_qty3(i) IS NULL  AND v_qty3(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt3,v_qty3(i)) ;
               --dbms_output.put_line(' pkaligot : in qty3 insert block' );
            end if;

            if v_old_qty4(i) IS NOT NULL AND  v_qty4(i) <> v_old_qty4(i) then
               set_for_update(v_qty4(i), v_old_qty4(i),v_bkt4, v_bkt5,i );
               if insert_rec = 1 AND v_old_qty4(i) = 0 then
	          set_for_insert(i,v_bkt4,v_qty4(i)) ;
                  insert_rec := 0;
               end if;
            elsif v_old_qty4(i) IS NULL  AND v_qty4(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt4,v_qty4(i)) ;
            end if;

            if v_old_qty5(i) IS NOT NULL AND  v_qty5(i) <> v_old_qty5(i) then
               set_for_update(v_qty5(i), v_old_qty5(i), v_bkt5, v_bkt6,i );
               if insert_rec = 1 AND v_old_qty5(i) = 0 then
	          set_for_insert(i,v_bkt5,v_qty5(i)) ;
                  insert_rec := 0;
               end if;
            elsif v_old_qty5(i) IS NULL AND v_qty5(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt5,v_qty5(i)) ;
            end if;

            if v_old_qty6(i) IS NOT NULL AND  v_qty6(i) <> v_old_qty6(i) then
               set_for_update(v_qty6(i), v_old_qty6(i), v_bkt6, v_bkt7,i );
               if insert_rec = 1 AND v_old_qty6(i) = 0 then
	          set_for_insert(i,v_bkt6,v_qty6(i)) ;
                  insert_rec := 0;
               end if;
            elsif v_old_qty6(i) IS NULL AND v_qty6(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt6,v_qty6(i)) ;
            end if;

            if v_old_qty7(i) IS NOT NULL AND  v_qty7(i) <> v_old_qty7(i)  then
               set_for_update(v_qty7(i), v_old_qty7(i),v_bkt7, v_bkt8, i );
               if insert_rec = 1 AND v_old_qty7(i) = 0 then
	          set_for_insert(i,v_bkt7,v_qty7(i)) ;
                  insert_rec := 0;
               end if;
            elsif v_old_qty7(i) IS NULL AND v_qty7(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt7,v_qty7(i)) ;
            end if;

            if v_old_qty8(i) IS NOT NULL AND  v_qty8(i) <> v_old_qty8(i)  then
               set_for_update(v_qty8(i), v_old_qty8(i),v_bkt8, v_bkt9, i );
               if insert_rec = 1 AND v_old_qty8(i) = 0 then
	          set_for_insert(i,v_bkt8,v_qty8(i)) ;
                  insert_rec := 0;
               end if;
            elsif v_old_qty8(i) IS NULL AND v_qty8(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt8,v_qty8(i)) ;
            end if;

            if v_old_qty9(i) IS NOT NULL AND  v_qty9(i) <> v_old_qty9(i)  then
               set_for_update(v_qty9(i), v_old_qty9(i),v_bkt9, v_bkt10, i );
               if insert_rec = 1 AND v_old_qty9(i) = 0 then
	          set_for_insert(i,v_bkt9,v_qty9(i)) ;
                  insert_rec := 0;
               end if;
            elsif v_old_qty9(i) IS NULL  AND v_qty9(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt9,v_qty9(i)) ;
            end if;

            if v_old_qty10(i) IS NOT NULL AND  v_qty10(i) <> v_old_qty10(i)  then
               set_for_update(v_qty10(i), v_old_qty10(i),v_bkt10, v_bkt11, i );
               if insert_rec = 1 AND v_old_qty10(i) = 0 then
	          set_for_insert(i,v_bkt10,v_qty10(i)) ;
                  insert_rec := 0;
               end if;
            elsif v_old_qty10(i) IS NULL AND v_qty10(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt10,v_qty10(i)) ;
            end if;

            if v_old_qty11(i) IS NOT NULL AND  v_qty11(i) <> v_old_qty11(i)  then
               set_for_update(v_qty11(i), v_old_qty11(i),v_bkt11, v_bkt12,i );
               if insert_rec = 1 AND v_old_qty11(i) = 0 then
	          set_for_insert(i,v_bkt11,v_qty11(i)) ;
                  insert_rec := 0;
               end if;
            elsif v_old_qty11(i) IS NULL AND v_qty11(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt11,v_qty11(i)) ;
            end if;

            if v_old_qty12(i) IS NOT NULL AND  v_qty12(i) <> v_old_qty12(i)  then
               set_for_update(v_qty12(i), v_old_qty12(i),v_bkt12, v_bkt13,i );
               if insert_rec = 1 AND v_old_qty12(i) = 0 then
	          set_for_insert(i,v_bkt12,v_qty12(i)) ;
                  insert_rec := 0;
               end if;
            elsif v_old_qty12(i) IS NULL AND v_qty12(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt12,v_qty12(i)) ;
            end if;

            if v_old_qty13(i) IS NOT NULL AND  v_qty13(i) <> v_old_qty13(i)   then
               set_for_update(v_qty13(i), v_old_qty13(i),v_bkt13, v_bkt14,i );
               if insert_rec = 1 AND v_old_qty13(i) = 0 then
	          set_for_insert(i,v_bkt13,v_qty13(i)) ;
                  insert_rec := 0;
               end if;
            elsif v_old_qty13(i) IS NULL AND v_qty13(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt13,v_qty13(i)) ;
            end if;

            if v_old_qty14(i) IS NOT NULL AND  v_qty14(i) <> v_old_qty14(i)  then
               set_for_update(v_qty14(i), v_old_qty14(i),v_bkt14, v_bkt15,i );
               if insert_rec = 1 AND v_old_qty14(i) = 0 then
	          set_for_insert(i,v_bkt14,v_qty14(i)) ;
                  insert_rec := 0;
               end if;
            elsif v_old_qty14(i) IS NULL AND v_qty14(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt14,v_qty14(i)) ;
            end if;

            if v_old_qty15(i) IS NOT NULL AND  v_qty15(i) <> v_old_qty15(i)  then
               set_for_update(v_qty15(i), v_old_qty15(i), v_bkt15, v_bkt16, i );
               if insert_rec = 1 AND v_old_qty15(i) = 0 then
	          set_for_insert(i,v_bkt15,v_qty15(i)) ;
                  insert_rec := 0;
               end if;
            elsif v_old_qty15(i) IS NULL AND v_qty15(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt15,v_qty15(i)) ;
            end if;

            if v_old_qty16(i) IS NOT NULL AND  v_qty16(i) <> v_old_qty16(i)  then
               set_for_update(v_qty16(i), v_old_qty16(i), v_bkt16, v_bkt17,i );
               if insert_rec = 1 AND v_old_qty16(i) = 0 then
	          set_for_insert(i,v_bkt16,v_qty16(i)) ;
                  insert_rec := 0;
               end if;
            elsif v_old_qty16(i) IS NULL AND v_qty16(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt16,v_qty16(i)) ;

            end if;

            if v_old_qty17(i) IS NOT NULL AND  v_qty17(i) <> v_old_qty17(i)  then
               set_for_update(v_qty17(i), v_old_qty17(i), v_bkt17, v_bkt18, i );
               if insert_rec = 1 AND v_old_qty17(i) = 0 then
	          set_for_insert(i,v_bkt17,v_qty17(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty17(i) IS NULL AND v_qty17(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt17,v_qty17(i)) ;

            end if;

            if v_old_qty18(i) IS NOT NULL AND  v_qty18(i) <> v_old_qty18(i)  then
               set_for_update(v_qty18(i), v_old_qty18(i), v_bkt18, v_bkt19,i );
               if insert_rec = 1 AND v_old_qty18(i) = 0 then
	          set_for_insert(i,v_bkt18,v_qty18(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty18(i) IS NULL  AND v_qty18(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt18,v_qty18(i)) ;

            end if;

            if v_old_qty19(i) IS NOT NULL AND  v_qty19(i) <> v_old_qty19(i)  then
               set_for_update(v_qty19(i), v_old_qty19(i), v_bkt19, v_bkt20, i );
               if insert_rec = 1 AND v_old_qty19(i) = 0 then
	          set_for_insert(i,v_bkt19,v_qty19(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty19(i) IS NULL AND v_qty19(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt19,v_qty19(i)) ;

            end if;

            if v_old_qty20(i) IS NOT NULL AND  v_qty20(i) <> v_old_qty20(i)  then
               set_for_update(v_qty20(i), v_old_qty20(i), v_bkt20, v_bkt21, i );
               if insert_rec = 1 AND v_old_qty20(i) = 0 then
	          set_for_insert(i,v_bkt20,v_qty20(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty20(i) IS NULL AND v_qty20(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt20,v_qty20(i)) ;

            end if;

            if v_old_qty21(i) IS NOT NULL AND  v_qty21(i) <> v_old_qty21(i)  then
               set_for_update(v_qty21(i), v_old_qty21(i), v_bkt21, v_bkt22, i );
               if insert_rec = 1 AND v_old_qty21(i) = 0 then
	          set_for_insert(i,v_bkt21,v_qty21(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty21(i) IS NULL AND v_qty21(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt21,v_qty21(i)) ;

            end if;

            if v_old_qty22(i) IS NOT NULL AND  v_qty22(i) <> v_old_qty22(i)  then
               set_for_update(v_qty22(i), v_old_qty22(i), v_bkt22, v_bkt23, i  );
               if insert_rec = 1 AND v_old_qty22(i) = 0 then
	          set_for_insert(i,v_bkt22,v_qty22(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty22(i) IS NULL  AND v_qty22(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt22,v_qty22(i)) ;

            end if;

            if v_old_qty23(i) IS NOT NULL AND  v_qty23(i) <> v_old_qty23(i)  then
               set_for_update(v_qty23(i), v_old_qty23(i), v_bkt23, v_bkt24, i );
               if insert_rec = 1 AND v_old_qty23(i) = 0 then
	          set_for_insert(i,v_bkt23,v_qty23(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty23(i) IS NULL  AND v_qty23(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt23,v_qty23(i)) ;

            end if;

            if v_old_qty24(i) IS NOT NULL AND  v_qty24(i) <> v_old_qty24(i)   then
               set_for_update(v_qty24(i), v_old_qty24(i), v_bkt24, v_bkt25, i );
               if insert_rec = 1 AND v_old_qty24(i) = 0 then
	          set_for_insert(i,v_bkt24,v_qty24(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty24(i) IS NULL AND v_qty24(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt24,v_qty24(i)) ;

            end if;

            if v_old_qty25(i) IS NOT NULL AND  v_qty25(i) <> v_old_qty25(i)   then
               set_for_update(v_qty25(i), v_old_qty25(i), v_bkt25, v_bkt26, i );
               if insert_rec = 1 AND v_old_qty25(i) = 0 then
	          set_for_insert(i,v_bkt25,v_qty25(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty25(i) IS NULL  AND v_qty25(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt25,v_qty25(i)) ;

            end if;

            if v_old_qty26(i) IS NOT NULL AND  v_qty26(i) <> v_old_qty26(i)   then
               set_for_update(v_qty26(i), v_old_qty26(i), v_bkt26, v_bkt27, i );
               if insert_rec = 1 AND v_old_qty26(i) = 0 then
	          set_for_insert(i,v_bkt26,v_qty26(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty26(i) IS NULL  AND v_qty26(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt26,v_qty26(i)) ;

            end if;

            if v_old_qty27(i) IS NOT NULL AND  v_qty27(i) <> v_old_qty27(i)   then
               set_for_update(v_qty27(i), v_old_qty27(i), v_bkt27, v_bkt28, i );
               if insert_rec = 1 AND v_old_qty27(i) = 0 then
	          set_for_insert(i,v_bkt27,v_qty27(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty27(i) IS NULL AND v_qty27(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt27,v_qty27(i)) ;

            end if;

            if v_old_qty28(i) IS NOT NULL AND  v_qty28(i) <> v_old_qty28(i)   then
               set_for_update(v_qty28(i), v_old_qty28(i), v_bkt28, v_bkt29, i );
               if insert_rec = 1 AND v_old_qty28(i) = 0 then
	          set_for_insert(i,v_bkt28,v_qty28(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty28(i) IS NULL  AND v_qty28(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt28,v_qty28(i)) ;

            end if;

            if v_old_qty29(i) IS NOT NULL AND  v_qty29(i) <> v_old_qty29(i)   then
               set_for_update(v_qty29(i), v_old_qty29(i), v_bkt29, v_bkt30, i );
               if insert_rec = 1 AND v_old_qty29(i) = 0 then
	          set_for_insert(i,v_bkt29,v_qty29(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty29(i) IS NULL  AND v_qty29(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt29,v_qty29(i)) ;

            end if;

            if v_old_qty30(i) IS NOT NULL AND  v_qty30(i) <> v_old_qty30(i)  then
               set_for_update(v_qty30(i), v_old_qty30(i),v_bkt30, v_bkt31, i );
               if insert_rec = 1 AND v_old_qty30(i) = 0 then
	          set_for_insert(i,v_bkt30,v_qty30(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty30(i) IS NULL AND v_qty30(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt30,v_qty30(i)) ;

            end if;

            if v_old_qty31(i) IS NOT NULL AND  v_qty31(i) <> v_old_qty31(i)   then
               set_for_update(v_qty31(i), v_old_qty31(i),v_bkt31, v_bkt32,i );
               if insert_rec = 1 AND v_old_qty31(i) = 0 then
	          set_for_insert(i,v_bkt31,v_qty31(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty31(i) IS NULL AND v_qty31(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt31,v_qty31(i)) ;

            end if;

            if v_old_qty32(i) IS NOT NULL AND  v_qty32(i) <> v_old_qty32(i)   then
               set_for_update(v_qty32(i), v_old_qty32(i), v_bkt32, v_bkt33,i );
               if insert_rec = 1 AND v_old_qty32(i) = 0 then
	          set_for_insert(i,v_bkt32,v_qty32(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty32(i) IS NULL AND v_qty32(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt32,v_qty32(i)) ;

            end if;

            if v_old_qty33(i) IS NOT NULL AND  v_qty33(i) <> v_old_qty33(i)   then
               set_for_update(v_qty33(i), v_old_qty33(i), v_bkt33, v_bkt34, i );
               if insert_rec = 1 AND v_old_qty33(i) = 0 then
	          set_for_insert(i,v_bkt33,v_qty33(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty33(i) IS NULL AND v_qty33(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt33,v_qty33(i)) ;

            end if;

            if v_old_qty34(i) IS NOT NULL AND  v_qty34(i) <> v_old_qty34(i)   then
               set_for_update(v_qty34(i), v_old_qty34(i), v_bkt34, v_bkt35, i );
               if insert_rec = 1 AND v_old_qty34(i) = 0 then
	          set_for_insert(i,v_bkt34,v_qty34(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty34(i) IS NULL AND v_qty34(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt34,v_qty34(i)) ;

            end if;

            if v_old_qty35(i) IS NOT NULL AND  v_qty35(i) <> v_old_qty35(i)  then
               set_for_update(v_qty35(i), v_old_qty35(i), v_bkt35, v_bkt36, i );
               if insert_rec = 1 AND v_old_qty35(i) = 0 then
	          set_for_insert(i,v_bkt35,v_qty35(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty35(i) IS NULL AND v_qty35(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt35,v_qty35(i)) ;

            end if;

            if v_old_qty36(i) IS NOT NULL AND  v_qty36(i) <> v_old_qty36(i)  then
               set_for_update(v_qty36(i), v_old_qty36(i), v_bkt36, v_last_bkt, i );
               if insert_rec = 1 AND v_old_qty36(i) = 0 then
	          set_for_insert(i,v_bkt36,v_qty36(i)) ;
                  insert_rec := 0;
               end if;

            elsif v_old_qty36(i) IS NULL AND v_qty36(i) IS NOT NULL then -- new record.
               set_for_insert(i,v_bkt36,v_qty36(i)) ;

            end if;
            -- get the transactionids.
            -- if none found then it is a new record.

         END LOOP;

      end if;



      BEGIN
	 SELECT fnd_global.user_id
	   INTO v_user_id
	   FROM dual;
      EXCEPTION
	 WHEN OTHERS THEN
	    v_user_id := -1;
      END;

      --dbms_output.put_line(' pkaligot : 199 : before update sup dem entries block: trans count: ' || v_upd_trans_id.COUNT);
      if v_upd_trans_id is not null AND v_upd_trans_id.COUNT > 0 and proceed = 0 then
      --dbms_output.put_line(' pkaligot : 200 : update sup dem entries block: trans count: ' || v_upd_trans_id.COUNT );
         -- update into msc_sup_dem_entries;
         BEGIN
            FORALL i in v_upd_trans_id.FIRST..v_upd_trans_id.LAST

               update msc_sup_dem_entries
                  set primary_quantity = round(v_upd_p_qty(i),DECPLACES),
                      quantity = round(v_upd_qty(i),DECPLACES),
                      tp_quantity = round(v_upd_tp_qty(i),DECPLACES),
	              last_refresh_number = MSC_CL_REFRESH_S.NEXTVAL,
	              last_updated_by = v_user_id,
	              last_update_date = sysdate
                where transaction_id = v_upd_trans_id(i);

               commit;
         EXCEPTION
            when others then
               proceed := 1;
	       if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'update_supdem_entries', 'update ' || SQLERRM);
	       end if;
               arg_err_msg := 'MSC_X_HZ_UPDATE@update ' || SQLERRM;
         END;
      end if;

      -- insert into msc_sup_dem_entries.

      --dbms_output.put_line(' pkaligot : 200 : v_i_item.COUNT:' || v_i_item.COUNT );
      --dbms_output.put_line(' pkaligot : 201 : proceed :' || proceed );

      if v_i_item is not null AND v_i_item.COUNT > 0  and proceed = 0 then
      --dbms_output.put_line(' pkaligot : 202 : v_i_item.COUNT:' || v_i_item.COUNT );
      ----dbms_output.put_line(' pkaligot : 202 : quantity:' || v_i_qty(0) );

         BEGIN

            FORALL i in v_i_item_id.FIRST..v_i_item_id.LAST

               insert into msc_sup_dem_entries
                      (transaction_id,inventory_item_id,item_name,item_description,
                       owner_item_name,customer_item_name,supplier_item_name,
                       owner_item_description,customer_item_description,supplier_item_description,
                       publisher_id,publisher_name,publisher_site_name,
                       customer_id,customer_site_id,
                       customer_name,customer_site_name,
                       supplier_id,supplier_site_id,
                       supplier_name,supplier_site_name,
                       publisher_order_type,publisher_order_type_desc,
                       bucket_type,bucket_type_desc,primary_uom,tp_uom_code,uom_code,
                       primary_quantity,tp_quantity,quantity,
                       key_date,ship_date,receipt_date,last_refresh_number,plan_id,
                       publisher_site_id,created_by,creation_date,last_updated_by,last_update_date,
		       ship_from_party_name,ship_from_party_id,ship_from_party_site_name,ship_from_party_site_id,
	               ship_to_party_name,ship_to_party_id,ship_to_party_site_name,ship_to_party_site_id,
	               sr_instance_id)
               values
                      (MSC_SUP_DEM_ENTRIES_S.nextval,v_i_item_id(i),v_i_item(i),Nvl(v_i_item_desc(i),v_i_owner_item_desc(i)),
                       v_i_owner_item(i),v_i_cust_item(i),v_i_sup_item(i),
                       v_i_owner_item_desc(i),v_i_cust_item_desc(i),v_i_sup_item_desc(i),
                       v_pub_id,v_pub_name,v_i_pub_site_name(i),
                       v_i_cust_id(i),v_i_cust_site_id(i),
                       v_i_cust(i),v_i_cust_site(i),
                       v_i_sup_id(i),v_i_sup_site_id(i),
                       v_i_sup(i),v_i_sup_site(i),
                       v_i_order_type(i),v_i_order(i),
                       v_i_bucket(i),v_i_bucket_desc(i),v_i_p_uom(i),v_i_tp_uom(i),v_i_p_uom(i),
                       round(v_i_p_qty(i),DECPLACES),round(v_i_tp_qty(i),DECPLACES),round(v_i_qty(i),DECPLACES),
                       v_i_date(i),v_i_date(i),v_i_date(i),MSC_CL_REFRESH_S.nextval,-1,
                       v_i_pub_site_id(i),v_user_id,sysdate,v_user_id,sysdate,
		       v_i_ship_from(i), v_i_ship_from_id(i), v_i_ship_from_site(i), v_i_ship_from_site_id(i),
	               v_i_ship_to(i), v_i_ship_to_id(i), v_i_ship_to_site(i), v_i_ship_to_site_id(i), -1);

         EXCEPTION
            when others then
               proceed := 1;
	       if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'update_supdem_entries', 'insert ' || SQLERRM);
	       end if;
               arg_err_msg := 'MSC_X_HZ_UPDATE@insert ' || SQLERRM;
               --dbms_output.put_line(' pkaligot : 203 : ' || arg_err_msg );

         END;
      end if;

      if proceed = 1 then
         arg_err_msg := 'Error while updating';
      end if;


   EXCEPTION
      WHEN NO_DATA_FOUND THEN
      if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'update_supdem_entries',SQLERRM);
	  end if;
         arg_err_msg := SQLERRM;

      WHEN OTHERS THEN
         if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(FND_LOG.LEVEL_ERROR,module || 'update_supdem_entries',SQLERRM);
	  end if;
         arg_err_msg := SQLERRM;

   END;

END MSC_X_HZ_UPDATE;

/

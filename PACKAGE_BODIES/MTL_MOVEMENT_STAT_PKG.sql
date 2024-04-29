--------------------------------------------------------
--  DDL for Package Body MTL_MOVEMENT_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_MOVEMENT_STAT_PKG" AS
/* $Header: INVMVSTB.pls 120.1 2005/06/11 11:39:03 appldev  $ */

--   ***************************************************************
/* Use forward declaration because procedure
   upd_ins_rcv_movements calls get_uom_code, which is not
   yet declared when the call is made. */

   FUNCTION get_uom_code  (p_transaction_uom_code  VARCHAR2) RETURN VARCHAR2;
--   ***************************************************************
--
-- PUBLIC PROCEDURES
--
-- PUBLIC VARIABLES
--    pseudo_movement_id
--    user_id
--

--   ***************************************************************
  -- Procedure
  --   uom_or_quantity_changes

  -- Purpose
  --   ** PRIVATE PROCEDURE **
  --   Process any changes to UOM or quantity. This is always called by the
  --   PO and INV processors.
  --   If UOM is changed then the unit price and outside unit price are also
  --   changed. If the UOM or quantity is changed then the total columns are
  --   re-calculated.
  --   For weight, if the weight_method is 'MU' then the unit weight was
  --   entered and thus a change of qty will require the total weight
  --   to be changed. If w_m = 'MT' then the total weight was entered
  --   and thus a change to qty will require a change to the unit weight.
  --   If the UOM is changed then if w_m = 'MU' then the unit_weight is
  --   recalculated according to the conversion factor (and thus the
  --   total_weight also). For w_m = 'MT', however, then a change to the UOM
  --   has no effect because the unit weight is just a calculated value
  --   from the total weight.

  -- History
  --     MAY-10-95     Paul Barry    Created

procedure uom_or_quantity_changes (
	p_old_transaction_uom_code	in varchar2,
	p_new_transaction_uom_code	in varchar2,
	p_old_transaction_quantity	in number,
	p_new_transaction_quantity	in number,
	p_inventory_item_id		in number,
	p_organization_id		in number,
	p_currency_code			in varchar2,
	p_document_unit_price	 IN OUT NOCOPY /* file.sql.39 change */ number,
	p_document_line_ext_value IN OUT NOCOPY /* file.sql.39 change */ number,
	p_weight_method			in varchar2,
	p_unit_weight		 IN OUT NOCOPY /* file.sql.39 change */ number,
	p_total_weight		 IN OUT NOCOPY /* file.sql.39 change */ number,
	p_stat_adj_percent		in number,
	p_stat_adj_amount		in number,
	p_stat_ext_value	 IN OUT NOCOPY /* file.sql.39 change */ number,
	p_outside_unit_price	 IN OUT NOCOPY /* file.sql.39 change */ number,
	p_outside_ext_value	 IN OUT NOCOPY /* file.sql.39 change */ number) as
--
	l_conversion_factor	number;
	l_precision		number(1);
	l_mau			number;
--
	--
	--	Private function to format calculated monetary totals
	--	according to the precision and MAU of the currency.
	--
	function format (p_number	number)
	return number
	is
	begin
		if l_mau is null then
			return(round(p_number, l_precision));
		else
			return(round(p_number / l_mau) * l_mau);
		end if;
	end format;
--
begin
	--
	-- First see if the UOM has changed. If it has then convert the
	-- unit price and outside unit price.
	--
	-- e.g. if old UOM is kg and new UOM is grammes (g) then the
	-- conversion factor will be 1000 and so the price will be reduced
	-- by 1000 times now we are dealing in grammes.
	--
	-- If the UOM or quantity changed in the forms then
	-- re-calculate the total values.
	--
	if p_old_transaction_uom_code <> p_new_transaction_uom_code then
		--
		-- Find conversion factor.
		--
		select	c1.conversion_rate / c2.conversion_rate
		into	l_conversion_factor
		from	mtl_uom_conversions_view c1,
			mtl_uom_conversions_view c2
		where	c1.organization_id	= P_ORGANIZATION_ID
		and	c2.organization_id	= P_ORGANIZATION_ID
		and	c1.inventory_item_id	= P_INVENTORY_ITEM_ID
		and	c2.inventory_item_id	= P_INVENTORY_ITEM_ID
		and	c1.uom_code		= P_OLD_TRANSACTION_UOM_CODE
		and	c2.uom_code		= P_NEW_TRANSACTION_UOM_CODE;
		--
		-- Change the unit price and outside unit price if they
		-- already contain values (unit price always will).
		--
		p_document_unit_price := p_document_unit_price /
			l_conversion_factor;
		if p_outside_unit_price is not null then
			p_outside_unit_price := p_outside_unit_price /
				l_conversion_factor;
		end if;
		--
  		-- If w_m = 'MU' then the unit_weight is recalculated and
		-- the total_weight also (just below).
		--
		if p_unit_weight is not null and p_weight_method = 'MU' then
			p_unit_weight := p_unit_weight / l_conversion_factor;
		end if;
	end if;
	--
	-- Re-calculate all totals if the UOM or quantity are changed. Use the
	-- currency minimum accountable unit (MAU) and precision to 'format'
	-- the monetary totals. Also update weight values.
	--
	if p_old_transaction_uom_code <> p_new_transaction_uom_code or
	   p_old_transaction_quantity <> abs(p_new_transaction_quantity) then
		--
		select	c.minimum_accountable_unit,
			c.precision
		into	l_mau,
			l_precision
		from	fnd_currencies c
		where	c.currency_code		= P_CURRENCY_CODE;
		--
		p_document_line_ext_value := format(p_document_unit_price *
			abs(p_new_transaction_quantity));
		--
		-- If w_m = 'MT' then the total weight should remain fixed
		-- and hence we need to update the unit weight. If = 'MU'
		-- then the total weight needs to be re-calculated from the
		-- unit weight.
		--
		if p_unit_weight is not null then
		  if p_weight_method = 'MU' then
			p_total_weight := p_unit_weight *
			        abs(p_new_transaction_quantity);
		  elsif p_weight_method = 'MT' then
			p_unit_weight := p_total_weight /
						abs(p_new_transaction_quantity);
		  end if;
		end if;
		if p_stat_adj_amount is not null then
			p_stat_ext_value := format(p_document_line_ext_value +
				p_stat_adj_amount);
		elsif p_stat_adj_percent is not null then
			p_stat_ext_value := format(p_document_line_ext_value *
				(1 + (p_stat_adj_percent / 100)));
                else    p_stat_ext_value := format(p_document_line_ext_value);
		end if;
		if p_outside_unit_price is not null then
			p_outside_ext_value := format(p_outside_unit_price *
				abs(p_new_transaction_quantity));
		end if;
	end if;
end uom_or_quantity_changes;

--   ***************************************************************
  -- Procedure
  --   upd_inv_movements

  -- Purpose
  --   This procedure is called from the inventory or cost
  --   processor to update either the item unit cost or the
  --   status, item unit cost, primary quantity, transaction
  --   quantity and transaction uom code for movement
  --   records in MTL_MOVEMENT_STATISTICS_TABLE

  -- History
  --     MAR-10-95     Rudolf F. Reichenberger     Created

  -- Arguments
  --   p_movement_id           number
  --   p_transaction_quantity  number
  --   p_primary_quantity      number
  --   p_transaction_uom       varchar2
  --   p_actual_cost           number
  --   p_transaction_date      date
  --   p_call_type             varchar2

  -- Example
  --   mtl_movement_stat_pkg.upd_inv_movements ()

  -- Notes

  PROCEDURE upd_inv_movements  (p_movement_id          IN NUMBER,
                                p_transaction_quantity IN NUMBER,
                                p_primary_quantity     IN NUMBER,
                                p_transaction_uom      IN VARCHAR2,
                                p_actual_cost          IN NUMBER,
                                p_transaction_date     IN DATE,
                                p_call_type            IN VARCHAR2)
   IS

        v_uom_code            		varchar2(3);
	l_old_transaction_uom_code	varchar2(3);
	l_old_transaction_quantity	number;
	l_inventory_item_id		number;
	l_organization_id		number;
	l_currency_code			varchar2(15);
	l_document_unit_price		number;
	l_document_line_ext_value	number;
	l_weight_method			varchar2(2);
	l_unit_weight			number;
	l_total_weight			number;
	l_stat_adj_percent		number;
	l_stat_adj_amount		number;
	l_stat_ext_value		number;
	l_outside_unit_price		number;
	l_outside_ext_value		number;

   BEGIN


--   ** Record Check (exists movement_id ?) and lock Table **
--   **           'mtl_movement_statistics'                **

     SELECT
	movement_id,
	transaction_uom_code,
	transaction_quantity,
	inventory_item_id,
	organization_id,
	currency_code,
	document_unit_price,
	document_line_ext_value,
	weight_method,
	unit_weight,
	total_weight,
	stat_adj_percent,
	stat_adj_amount,
	stat_ext_value,
	outside_unit_price,
	outside_ext_value
     INTO
	pseudo_movement_id,
	l_old_transaction_uom_code,
	l_old_transaction_quantity,
	l_inventory_item_id,
	l_organization_id,
	l_currency_code,
	l_document_unit_price,
	l_document_line_ext_value,
	l_weight_method,
	l_unit_weight,
	l_total_weight,
	l_stat_adj_percent,
	l_stat_adj_amount,
	l_stat_ext_value,
	l_outside_unit_price,
	l_outside_ext_value
     FROM mtl_movement_statistics
     WHERE movement_id = p_movement_id
       AND   movement_status <> 'F' FOR UPDATE NOWAIT;

--   ** Call routine that takes care of any UOM or unit price changes **
--   ** This routine does no database updates but returns the amended **
--   ** values to be used to update the database later on in this     **
--   ** procedure.						      **

     uom_or_quantity_changes (
	l_old_transaction_uom_code,
	v_uom_code,
	l_old_transaction_quantity,
	p_transaction_quantity,
	l_inventory_item_id,
	l_organization_id,
	l_currency_code,
	l_document_unit_price,
	l_document_line_ext_value,
	l_weight_method,
	l_unit_weight,
	l_total_weight,
	l_stat_adj_percent,
	l_stat_adj_amount,
	l_stat_ext_value,
	l_outside_unit_price,
	l_outside_ext_value);

--   ** UPDATE **

     IF p_call_type = 'T' THEN

        UPDATE mtl_movement_statistics
           SET movement_status = 'O',
               primary_quantity = p_primary_quantity,
               transaction_quantity = ABS(p_transaction_quantity),
               transaction_uom_code = p_transaction_uom,
               transaction_date = p_transaction_date,
               item_cost = p_actual_cost,
               last_update_date = sysdate,
               last_updated_by = user_id,
	       document_unit_price = l_document_unit_price,
	       document_line_ext_value = l_document_line_ext_value,
	       unit_weight = l_unit_weight,
	       total_weight = l_total_weight,
	       stat_ext_value = l_stat_ext_value,
	       outside_unit_price = l_outside_unit_price,
	       outside_ext_value = l_outside_ext_value
           WHERE movement_id = p_movement_id;

     ELSIF p_call_type = 'C' THEN

        UPDATE mtl_movement_statistics
           SET item_cost = p_actual_cost,
               last_update_date = sysdate,
               last_updated_by = user_id,
	       document_unit_price = l_document_unit_price,
	       document_line_ext_value = l_document_line_ext_value,
	       unit_weight = l_unit_weight,
	       total_weight = l_total_weight,
	       stat_ext_value = l_stat_ext_value,
	       outside_unit_price = l_outside_unit_price,
	       outside_ext_value = l_outside_ext_value
           WHERE movement_id = p_movement_id;

     END IF;

--   EXCEPTION
--   No exception handling required because all data entered are
--   validated by the Pro C program. Especially the call_type
--   is either 'T' or 'C' and nothing else.

   END upd_inv_movements;

--   *******************************************************************
  -- Procedure
  -- upd_ins_rcv_movements

  -- Purpose
  --  This procedure is called from the receiving processor after the
  --  processor generates the appropriate ids and before the final
  --  commit; the procedure will update the shipment_header_id,
  --  shipment_line_id, quantity, etc.. for adjustment entries, the
  --  procedure will insert a corresponding adjusting movement record.

  -- History
  --     Apr-07-95     Rudolf F. Reichenberger     Created

  -- Arguments
  -- p_movement_id             number
  -- p_parent_movement_id      number
  -- p_shipment_header_id      number
  -- p_shipment_line_id        number
  -- p_transaction_quantity    number
  -- p_transaction_uom_code    varchar2
  -- p_type                    varchar2

  -- Example
  --   mtl_movement_stat_pkg.upd_ins_rcv_movements ()

  -- Notes

  PROCEDURE upd_ins_rcv_movements  (
                  p_movement_id           IN NUMBER,
                  p_parent_movement_id    IN NUMBER,
                  p_shipment_header_id    IN NUMBER,
                  p_shipment_line_id      IN NUMBER,
                  p_transaction_quantity  IN NUMBER,
                  p_transaction_uom_code  IN VARCHAR2,
                  p_type                  IN VARCHAR2,
		  p_transaction_date      IN DATE)
IS
        l_movement_id                     number;
        v_uom_code            		varchar2(3);
	l_old_transaction_uom_code	varchar2(3);
	l_old_transaction_quantity	number;
	l_inventory_item_id		number;
	l_organization_id		number;
	l_currency_code			varchar2(15);
	l_document_unit_price		number;
	l_document_line_ext_value	number;
	l_weight_method			varchar2(2);
	l_unit_weight			number;
	l_total_weight			number;
	l_stat_adj_percent		number;
	l_stat_adj_amount		number;
	l_stat_ext_value		number;
	l_outside_unit_price		number;
	l_outside_ext_value		number;
        l_new_movement_id               number;
	l_movement_type                 varchar2(15);

BEGIN

--     ** get the 3 character conversion code from  **
--     ** the unit_of_measure passed by receiving   **

        v_uom_code := get_uom_code(p_transaction_uom_code);


       IF NOT p_type = 'CORRECT' THEN
              l_movement_id := p_movement_id;
       ELSE
              l_movement_id := p_parent_movement_id;
       END IF;

--     ** Lock Table 'mtl_movement_statistics'      **

      SELECT
 	movement_id,
	transaction_uom_code,
	transaction_quantity,
	inventory_item_id,
	organization_id,
	currency_code,
	document_unit_price,
	document_line_ext_value,
	weight_method,
	unit_weight,
	total_weight,
	stat_adj_percent,
	stat_adj_amount,
	stat_ext_value,
	outside_unit_price,
	outside_ext_value
      INTO
	pseudo_movement_id,
	l_old_transaction_uom_code,
	l_old_transaction_quantity,
	l_inventory_item_id,
	l_organization_id,
	l_currency_code,
	l_document_unit_price,
	l_document_line_ext_value,
	l_weight_method,
	l_unit_weight,
	l_total_weight,
	l_stat_adj_percent,
	l_stat_adj_amount,
	l_stat_ext_value,
	l_outside_unit_price,
	l_outside_ext_value
      FROM mtl_movement_statistics
      WHERE movement_id = l_movement_id
      FOR UPDATE NOWAIT;

--   ** Call routine that takes care of any UOM or unit price changes **
--   ** This routine does no database updates but returns the amended **
--   ** values to be used to update the database later on in this     **
--   ** procedure.						      **

     uom_or_quantity_changes (
	l_old_transaction_uom_code,
	v_uom_code,
	l_old_transaction_quantity,
	p_transaction_quantity,
	l_inventory_item_id,
	l_organization_id,
	l_currency_code,
	l_document_unit_price,
	l_document_line_ext_value,
	l_weight_method,
	l_unit_weight,
	l_total_weight,
	l_stat_adj_percent,
	l_stat_adj_amount,
	l_stat_ext_value,
	l_outside_unit_price,
	l_outside_ext_value);

--     ** Update for not adjustments if type is not **
--     ** an Arrivial Adjustment ('AA')             **

       IF NOT p_type = 'CORRECT' THEN

--     **              UPDATE                       **
          UPDATE mtl_movement_statistics
             SET shipment_header_id = p_shipment_header_id,
                 shipment_line_id   = p_shipment_line_id,
                 transaction_quantity = p_transaction_quantity,
                 transaction_uom_code = v_uom_code,
                 last_update_date = sysdate,
                 last_updated_by = user_id,
                 movement_status = 'O',
	         document_unit_price = l_document_unit_price,
	         document_line_ext_value = l_document_line_ext_value,
	         unit_weight = l_unit_weight,
	         total_weight = l_total_weight,
	         stat_ext_value = l_stat_ext_value,
	         outside_unit_price = l_outside_unit_price,
	         outside_ext_value = l_outside_ext_value
              WHERE movement_id = p_movement_id;

--     **              INSERT                       **
        ELSE

          select mtl_movement_statistics_s.NEXTVAL
          into l_new_movement_id
          from sys.dual;

          INSERT INTO mtl_movement_statistics (
                 movement_id, organization_id,
                 entity_org_id, movement_type,
                 movement_status, transaction_date,
                 last_update_date, last_updated_by,
                 creation_date, created_by,
                 last_update_login, document_source_type,
                 creation_method, document_reference,
                 document_line_reference, document_unit_price,
                 document_line_ext_value,
                 vendor_name, vendor_number,
                 vendor_site, po_header_id,
                 po_line_id, po_line_location_id,
                 shipment_header_id, shipment_line_id,
                 vendor_id, vendor_site_id,
                 parent_movement_id,
                 inventory_item_id, item_description,
                 item_cost, transaction_quantity,
                 transaction_uom_code, outside_code,
                 outside_ext_value, outside_unit_price,
                 currency_code,
                 category_id,
                 weight_method, unit_weight,
                 total_weight, transaction_nature,
                 delivery_terms, transport_mode,
                 dispatch_territory_code,
                 destination_territory_code,
                 origin_territory_code, area,
                 port, stat_type, comments,
		 stat_adj_amount, stat_adj_percent,
                 stat_ext_value
                 )
          SELECT
                 l_new_movement_id,
                 organization_id, entity_org_id,
                 decode(movement_status, 'O', 'A', 'AA'),
                 'O', p_transaction_date,
                 sysdate, user_id,
                 sysdate, created_by,
                 last_update_login, document_source_type,
                 creation_method, document_reference,
                 document_line_reference, L_DOCUMENT_UNIT_PRICE,
                 L_DOCUMENT_LINE_EXT_VALUE,
                 vendor_name, vendor_number,
                 vendor_site, po_header_id,
                 po_line_id, po_line_location_id,
                 P_SHIPMENT_HEADER_ID, P_SHIPMENT_LINE_ID,
                 vendor_id, vendor_site_id,
                 P_PARENT_MOVEMENT_ID,
                 inventory_item_id, item_description,
                 item_cost, P_TRANSACTION_QUANTITY,
                 transaction_uom_code, outside_code,
                 L_OUTSIDE_EXT_VALUE,
                 L_OUTSIDE_UNIT_PRICE,
                 currency_code,
                 category_id,
                 weight_method, L_UNIT_WEIGHT,
                 L_TOTAL_WEIGHT,
                 transaction_nature,
                 delivery_terms, transport_mode,
                 dispatch_territory_code,
                 destination_territory_code,
                 origin_territory_code, area,
                 port, stat_type, comments,
		 stat_adj_amount, stat_adj_percent,
                 decode(stat_adj_percent, NULL, decode(stat_adj_amount,
                 NULL, NULL, stat_ext_value), stat_ext_value)
          FROM   mtl_movement_statistics
          WHERE  movement_id = p_parent_movement_id;

	--fix bug 109662
          select movement_type
          into   l_movement_type
          from   mtl_movement_statistics
          where  movement_id = p_parent_movement_id;



	 IF  (p_type = 'CORRECT') then
    		 if  (l_movement_type = 'A') then
	                 /* correction to receipt */
        	 	update mtl_movement_statistics
         	 	set movement_type = 'AA'
	         	where movement_id = l_new_movement_id;
   		 elsif (l_movement_type = 'D') then

	         	 update mtl_movement_statistics
         	  	 set movement_type = 'DA',
 		  	 transaction_quantity = (-1) *  p_transaction_quantity
	         	 where movement_id = l_new_movement_id;
	    	 end if;
  	 end if;

        END IF;
END upd_ins_rcv_movements;

--   PRIVATE FUNCTION
--   PRIVATE VARIABLES
--   v_uom_code
--   *******************************************************************
  -- FUNCTION
  -- get_uom_code

  -- Purpose
  --   This function is called from the
  --   upd_ins_rcv_movements procedure to get the 3 character
  --   conversion code from the unit_of_measure passed by receiving

  -- History
  --     MAY-10-95           Rudolf F. Reichenberger      Created

  -- Arguments
  -- p_transaction_uom_code   varchar2

  -- Example
  --   get_uom_code ()

       FUNCTION get_uom_code  (p_transaction_uom_code  VARCHAR2)
                RETURN VARCHAR2 IS
            v_uom_code VARCHAR2(3);
         BEGIN
           SELECT  uom_code INTO v_uom_code
           FROM  mtl_units_of_measure
           WHERE unit_of_measure = p_transaction_uom_code;
           RETURN v_uom_code;
         END get_uom_code;

--   *******************************************************************

--     ** initialization part of the package        **  --

--     ** FUNCTION FND_GLOBAL.USER_ID Returns the   **
--     ** user_id for the last_updated_by column    **

BEGIN
       user_id := FND_GLOBAL.USER_ID;
--   *******************************************************************
END mtl_movement_stat_pkg;

/

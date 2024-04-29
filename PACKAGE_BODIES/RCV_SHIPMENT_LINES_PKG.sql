--------------------------------------------------------
--  DDL for Package Body RCV_SHIPMENT_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_SHIPMENT_LINES_PKG" as
/* $Header: RCVTISLB.pls 120.4.12010000.11 2014/01/15 06:05:43 yilali ship $ */

G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'RCV_SHIPMENT_LINES_PKG';
G_FILE_NAME CONSTANT    VARCHAR2(30) := 'RCVTISLB.pls';
g_module_prefix CONSTANT VARCHAR2(50) := 'pos.plsql.' || g_pkg_name || '.';

g_asn_debug         VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
procedure debug_log(p_level in number,
                    p_api_name in varchar2,
                    p_msg in varchar2);

procedure debug_log(p_level in number,
                    p_api_name in varchar2,
                    p_msg in varchar2)
IS
l_module varchar2(2000);
BEGIN
/* Taken from Package FND_LOG
   LEVEL_UNEXPECTED CONSTANT NUMBER  := 6;
   LEVEL_ERROR      CONSTANT NUMBER  := 5;
   LEVEL_EXCEPTION  CONSTANT NUMBER  := 4;
   LEVEL_EVENT      CONSTANT NUMBER  := 3;
   LEVEL_PROCEDURE  CONSTANT NUMBER  := 2;
   LEVEL_STATEMENT  CONSTANT NUMBER  := 1;
*/

l_module := 'pos.plsql.rcv_shipment_lines_pkg.'||p_api_name;
        IF(g_asn_debug = 'Y')THEN
        IF ( p_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.string(LOG_LEVEL => p_level,
                         MODULE => l_module,
                         MESSAGE => p_msg);
        END IF;

    END IF;
END debug_log;


  PROCEDURE Lock_Line_s( X_Rowid                          VARCHAR2,
                       X_Shipment_Line_Id	        NUMBER,
                       X_item_revision              	VARCHAR2,
                       X_stock_locator_id               NUMBER,
                       X_packing_slip                   VARCHAR2,
                       X_comments                  	VARCHAR2,
                       X_routing_header_id              NUMBER,
                       X_Reason_id                      NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
		       X_Request_Id			NUMBER,
		       X_Program_Application_Id		NUMBER,
		       X_Program_Id			NUMBER,
		       X_Program_Update_Date		DATE ,
           x_equipment_id NUMBER  DEFAULT NULL  --add by rcv changed for YMS

  ) IS

X_progress            VARCHAR2(4) := '000';

    CURSOR C IS
        SELECT *
        FROM   RCV_SHIPMENT_LINES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Shipment_Line_Id NOWAIT;
    Recinfo C%ROWTYPE;

  BEGIN

--insert into foo values (1, 'in lock_lines_s');
--commit;

    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then

--insert into foo values (2, 'C not found');
--commit;

      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
           (Recinfo.shipment_line_id = X_Shipment_Line_Id)

           AND (   (Recinfo.item_revision = X_item_revision)
                OR (    (Recinfo.item_revision IS NULL)
                    AND (X_item_revision IS NULL)))

           AND (   (Recinfo.locator_id = X_stock_locator_id)
                OR (    (Recinfo.locator_id IS NULL)
                    AND (X_stock_locator_id IS NULL)))

           AND (   (Recinfo.packing_slip = X_packing_slip)
                OR (    (Recinfo.packing_slip IS NULL)
                    AND (X_packing_slip IS NULL)))

           AND (   (Recinfo.comments = X_comments)
                OR (    (Recinfo.comments IS NULL)
                    AND (X_comments IS NULL)))

           AND (   (Recinfo.routing_header_id = X_routing_header_id)
                OR (    (Recinfo.routing_header_id IS NULL)
                    AND (X_routing_header_id IS NULL)))

           AND (   (Recinfo.Reason_id = X_Reason_id)
                OR (    (Recinfo.Reason_id IS NULL)
                    AND (X_Reason_id IS NULL)))
           AND (   (Recinfo.equipment_id = x_equipment_id)   --add by rcv changed for YMS
                OR (    (Recinfo.equipment_id IS NULL)       --add by rcv changed for YMS
                    AND (x_equipment_id IS NULL)))           --add by rcv changed for YMS
            ) then

--insert into foo values (3, 'then clause');
--commit;

      return;
    else
--insert into foo values (4, 'else clause');
--commit;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('RCV_SHIPMENT_LINES_PKG.Lock_Line_s', x_progress, sqlcode);
   RAISE;

  END Lock_Line_s;


PROCEDURE Update_Line_s(
                    X_Shipment_Line_Id	        NUMBER,
                    X_item_revision              	VARCHAR2,
                    X_stock_locator_id               NUMBER,
                    X_packing_slip                   VARCHAR2,
                    X_comments                  	VARCHAR2,
                    X_routing_header_id              NUMBER,
                       X_Reason_id                      NUMBER
 ) IS
	X_progress            VARCHAR2(4) := '000';
  x_temp                VARCHAR2(25);    --Bug 8899316

 BEGIN

 /* Bug 8899316 */

  SELECT 'Check for records in RSL'
  INTO  x_temp
  FROM rcv_shipment_lines
  where shipment_line_id = x_shipment_line_id;

   /* Bug 8899316 */

  update rcv_shipment_lines
  set item_revision 	 = x_item_revision,
      locator_id 	 = x_stock_locator_id,
      packing_slip 	 = x_packing_slip,
      comments 		 = x_comments,
      routing_header_id  = x_routing_header_id,
      reason_id 	 = x_reason_id
  where shipment_line_id = x_shipment_line_id;

  /* Bug 8899316: Commenting this code as  SQL%NOTFOUND is refering to the
                  last sql of trigger code on RSL
  */

 /*   if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;   */


  EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('RCV_SHIPMENT_LINES_PKG.Update_Line_s', x_progress, sqlcode);
   RAISE;

END Update_Line_s;

PROCEDURE update_wc_line(
                        p_shipment_line_id IN NUMBER,
                        p_requested_amount       IN      NUMBER DEFAULT NULL,
                        p_material_stored_amount IN      NUMBER DEFAULT NULL,
                        p_amount_shipped         IN      NUMBER DEFAULT NULL,
                        p_quantity_shipped       IN      NUMBER DEFAULT NULL
 ) IS
        X_progress            VARCHAR2(4) := '000';
l_shipment_header_id number;
l_api_name varchar2(50);
l_itemkey varchar2(60);
x_temp VARCHAR2(25);  --Bug 8899316
 BEGIN

	select wf_item_key
	into l_itemkey
	from rcv_shipment_headers
	where shipment_header_id =( select shipment_header_id
					from rcv_shipment_lines
				where shipment_line_id= p_shipment_line_id);

	l_api_name := l_itemkey || ' update_wc_line';


	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'Enter update_wc_line');
        END IF;

	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'Before call to update_quantity_amount');
        END IF;

    update_quantity_amount(p_shipment_line_id,p_quantity_shipped,p_amount_shipped);
	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'After call to update_quantity_amount');
        END IF;

         /* Bug 8899316 */

        SELECT 'Check for records in RSL'
        INTO  x_temp
        FROM rcv_shipment_lines
        where shipment_line_id = p_shipment_line_id;

        /* Bug 8899316 */

        update rcv_shipment_lines
        set requested_amount   = p_requested_amount,
                material_stored_amount = p_material_stored_amount,
                amount_shipped     = p_amount_shipped,
                quantity_shipped     = p_quantity_shipped,
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
        where shipment_line_id = p_shipment_line_id;

  /* Bug 8899316: Commenting this code as  SQL%NOTFOUND is refering to the
                  last sql of trigger code on RSL
  */

  /* if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;   */

	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'Leave update_wc_line');
        END IF;

    return;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('RCV_SHIPMENT_LINES_PKG.Update_wc_line', x_progress, sqlcode);
   RAISE;

  END Update_wc_line;

  PROCEDURE update_quantity_amount(
                        p_Shipment_Line_Id      IN      NUMBER,
                        p_quantity_shipped      IN      NUMBER,
                        p_amount_shipped        IN      NUMBER
) IS
        X_progress            VARCHAR2(4) := '000';
        l_orig_qty_shipped    number :=0;
        l_orig_amt_shipped    number :=0;
        l_line_location_id    number;
        l_qty_shipped         number :=0;
        l_amt_shipped         number :=0;
        l_distribution_id       number;
        l_sum_qty               NUMBER :=0;   --bug 8899316
        l_remaining_qty       NUMBER :=0;   --bug 8899316
        l_wc_qty                 NUMBER :=0;   --bug 8899316

        cursor supply_info is
        SELECT QUANTITY,
            UNIT_OF_MEASURE,
            nvl(ITEM_ID, -1),
            FROM_ORGANIZATION_ID,
            TO_ORGANIZATION_ID,
            TO_CHAR(RECEIPT_DATE,'DDMMYYYY'),
            ROWID
        FROM
            MTL_SUPPLY
        WHERE CHANGE_FLAG = 'Y';

        /* Bug 8899316 */

        cursor supply_dist_info(p_po_line_location_id NUMBER, p_shipment_line_id NUMBER) IS
        SELECT quantity,
               po_distribution_id
        FROM   MTL_SUPPLY
        WHERE supply_type_code = 'SHIPMENT'
        AND      po_line_location_id = p_po_line_location_id
        AND      shipment_line_id = p_shipment_line_id;

        /* Bug 8899316 */

        l_supply_qty number;
        l_supply_uom varchar2(26);
        l_supply_item_id number;
        l_supply_from_org number;
        l_supply_to_org number;
        l_supply_receipt_date varchar2(26);
        l_supply_rowid varchar2(26);
        l_primary_uom varchar2(26);
        l_primary_qty number;
        l_lead_time number;

l_shipment_header_id number;
l_api_name varchar2(50);
l_itemkey varchar2(60);

 BEGIN

	select wf_item_key
	into l_itemkey
	from rcv_shipment_headers
	where shipment_header_id =( select shipment_header_id
					from rcv_shipment_lines
				where shipment_line_id= p_shipment_line_id);

	l_api_name := l_itemkey || ' update_quantity_amount';


	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'Enter update_quantity_amount');
        END IF;

        /* Get the original quantity or amount. We need this
         * to update po_line_locations.
        */
        select  nvl(quantity_shipped,0),
                nvl(amount_shipped,0),
                po_line_location_id
        into    l_orig_qty_shipped,
                l_orig_amt_shipped,
                l_line_location_id
        from rcv_shipment_lines
        where shipment_line_id = p_shipment_line_id;

	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'l_orig_qty_shipped ' ||l_orig_qty_shipped);
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'l_orig_amt_shipped ' ||l_orig_amt_shipped);
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'l_line_location_id ' ||l_line_location_id);
        END IF;


    /* Update po_line_location.quantity_shipped */
        l_qty_shipped := p_quantity_shipped - l_orig_qty_shipped;
        l_amt_shipped := p_amount_shipped - l_orig_amt_shipped;

	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'l_qty_shipped ' ||l_qty_shipped);
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'l_amt_shipped ' ||l_amt_shipped);
	end if;

        UPDATE po_line_locations_all poll
        set poll.quantity_shipped = nvl(poll.quantity_shipped,0) +
                                        l_qty_shipped,
            poll.amount_shipped = nvl(poll.amount_shipped,0) +
                                        l_amt_shipped,
            poll.last_update_date = sysdate,
            poll.last_updated_by = fnd_global.user_id,
            poll.last_update_login = fnd_global.login_id
        where poll.line_location_id = l_line_location_id;


	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'After update to poll ' );
	end if;

        If (p_amount_shipped is not  null) then
                return;
        end if;

        /* To update PO supply we need to know the distribution id */
	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'p_shipment_line_id '||p_shipment_line_id );
	end if;

  /* Bug 8899316: Commenting this code as mtl_supply logic is incorrect */

/*
        select po_distribution_id
        into l_distribution_id
        from mtl_supply
        where supply_type_code = 'SHIPMENT'
        and po_line_location_id = l_line_location_id
        and    shipment_line_id = p_shipment_line_id;

	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'l_distribution_id '||l_distribution_id );
	end if;

         update  mtl_supply
         set     quantity = quantity + l_qty_shipped,
                 change_flag = 'Y'
          where  supply_type_code = 'SHIPMENT'
          and    po_line_location_id = l_line_location_id
          and    shipment_line_id = p_shipment_line_id;

	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'After update to shipment supply' );
	end if;

         update  mtl_supply
         set     quantity = quantity + l_qty_shipped,
                 change_flag = 'Y'
          where  supply_type_code = 'PO'
          and    po_distribution_id = l_distribution_id;


	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'After update to PO supply' );
	end if;

  */

  /* Bug 8899316: Logic for updating mtl_supply */

  /* Update last distribution in case of over receipt across the pay item */

        select Sum(quantity), Max(po_distribution_id)
        into   l_sum_qty, l_distribution_id
        from   mtl_supply
        where  supply_type_code = 'SHIPMENT'
        and    po_line_location_id = l_line_location_id
        and    shipment_line_id = p_shipment_line_id;

        IF (p_quantity_shipped > l_sum_qty) THEN

          update  mtl_supply
          set    quantity = quantity + (p_quantity_shipped - l_sum_qty),
                 change_flag = 'Y'
          where  supply_type_code = 'SHIPMENT'
          and    po_distribution_id = l_distribution_id
          and    shipment_line_id = p_shipment_line_id;

	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'l_distribution_id '||l_distribution_id );
	end if;

         l_wc_qty := p_quantity_shipped;

         FOR dist_info IN supply_dist_info(l_line_location_id, p_shipment_line_id)
          LOOP

           l_remaining_qty := l_wc_qty - dist_info.quantity ;

    /* If quantity on Work Confirmation is greater than the distribution quantity, do not update
       mtl_supply for distribution */

           IF ( l_remaining_qty > 0) THEN
            l_wc_qty := l_remaining_qty;

           ELSIF ( l_remaining_qty < 0 ) THEN

	          l_wc_qty := 0;

      /* If quantity on Work Confirmation is less than the distribution quantity, delete 'SHIPMENT' supply
         for the distribution and re-create 'PO' supply. Re-create PO supply for all subsequent distributions */

           UPDATE mtl_supply
           SET   quantity = (quantity + l_remaining_qty),
                 change_flag = 'Y'
          where  supply_type_code = 'SHIPMENT'
          and    po_distribution_id = l_distribution_id;

          insert into mtl_supply
                 (supply_type_code,
                 supply_source_id,
    	          last_updated_by,
     	          last_update_date,
     	          last_update_login,
     	          created_by,
     	          creation_date,
                  po_header_id,
                  po_line_id,
                  po_line_location_id,
                  po_distribution_id,
                  po_release_id,
                  item_id,
                  item_revision,
                  quantity,
                  unit_of_measure,
                  receipt_date,
                  need_by_date,
                  destination_type_code,
                  location_id,
                  to_organization_id,
                  to_subinventory,
                  change_flag)
                  select 'PO',
                   pd.po_distribution_id,
    	           pd.last_updated_by,
     	           pd.last_update_date,
     	           pd.last_update_login,
     	           pd.created_by,
     	           pd.creation_date,
                   pd.po_header_id,
                   pd.po_line_id,
                   pd.line_location_id,
                   pd.po_distribution_id,
                   pd.po_release_id,
                   pl.item_id,
                   pl.item_revision,
                   -(l_remaining_qty),
                   pl.unit_meas_lookup_code,
                   nvl(pll.promised_date,pll.need_by_date),
                   nvl(pll.promised_date,pll.need_by_date),
                   pd.destination_type_code,
                   pd.deliver_to_location_id,
                   pd.destination_organization_id,
                   pd.destination_subinventory,
                   'Y'
                    from   po_distributions_all pd,
                              po_line_locations_all pll,
                              po_lines_all pl
                    where  pd.po_distribution_id = dist_info.po_distribution_id
                    and    pll.line_location_id = pd.line_location_id
                    and    pl.po_line_id = pd.po_line_id
                    and    nvl(pll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
                    and    nvl(pll.closed_code, 'OPEN') <> 'CLOSED'
    		    and    nvl(pll.closed_code, 'OPEN') <> 'CLOSED FOR RECEIVING'
    		    and    nvl(pll.cancel_flag, 'N') = 'N'
    		    and    nvl(pll.approved_flag, 'Y') = 'Y'
                    and    pll.quantity is not NULL
    		            and    not exists
                           (select 'Supply Exists'
                            from   mtl_supply ms1
                            where  ms1.supply_type_code = 'PO'
    			     and    ms1.supply_source_id = pd.po_distribution_id);

     END IF;   --End IF ( l_remaining_qty > 0)

     END LOOP;

   END IF;  --End IF (p_quantity_shipped > l_sum_qty)

  /* End Bug 8899316 */

        open supply_info;
        loop
                fetch supply_info into l_supply_qty,
                        l_supply_uom,
                        l_supply_item_id,
                        l_supply_from_org,
                        l_supply_to_org,
                        l_supply_receipt_date,
                        l_supply_rowid;
                exit when supply_info%notfound;

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
				'l_supply_uom '||l_supply_uom );
		    debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
				'l_supply_item_id '||l_supply_item_id );
		    debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
				'l_supply_from_org '||l_supply_from_org );
		    debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
				'l_supply_to_org '||l_supply_to_org );
		    debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
				'l_supply_receipt_date '||l_supply_receipt_date );
		    debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
				'l_supply_rowid '||l_supply_rowid );
		end if;

                if (l_supply_qty = 0) then --{
			IF (g_asn_debug = 'Y') THEN
			    debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
				'Before Delete' );
			end if;

                        delete from mtl_supply
                        where rowid = l_supply_rowid;
			IF (g_asn_debug = 'Y') THEN
			    debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
				'After Delete' );
			end if;
                        return;
                else --}{
			IF (g_asn_debug = 'Y') THEN
			    debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
				'Supply qty not 0' );
			end if;
                    if l_supply_item_id = -1 then --{
                        SELECT muom.unit_of_measure, NULL
                        INTO   l_primary_uom,
                               l_lead_time
                        FROM   mtl_units_of_measure muom,
                            mtl_units_of_measure tuom
                        WHERE  tuom.unit_of_measure = l_supply_uom
                        AND    tuom.uom_class = muom.uom_class
                        AND    muom.base_uom_flag = 'Y';

                    else --}{
                        SELECT  PRIMARY_UNIT_OF_MEASURE,
                                 POSTPROCESSING_LEAD_TIME
                         INTO    l_primary_uom,
                                 l_lead_time
                         FROM    MTL_SYSTEM_ITEMS
                         WHERE   INVENTORY_ITEM_ID = l_supply_item_id
                         AND     ORGANIZATION_ID = l_supply_to_org;

                    end if; --}

                end if; --}

                po_uom_s.uom_convert(l_supply_qty,
                                 l_supply_uom,
                                 l_supply_item_id,
                                 l_primary_uom,
                                 l_primary_qty
                                );

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
			'Before update to mtl_supply.quantity' );
		end if;
                UPDATE MTL_SUPPLY
                SET  TO_ORG_PRIMARY_QUANTITY = l_primary_qty,
                     TO_ORG_PRIMARY_UOM = l_primary_uom,
                     CHANGE_FLAG = NULL,
                     CHANGE_TYPE = null,
                     EXPECTED_DELIVERY_DATE =
                                decode(l_supply_item_id,
                                     -1, TO_DATE(NULL),
                                     TO_DATE(l_supply_receipt_date,'DDMMYYYY')
                                     + nvl(l_lead_time, 0 ))
                WHERE ROWID = l_supply_rowid;

		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
			'After update to mtl_supply.quantity' );
		end if;


        end loop;

        close supply_info;
		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
			'Leave update_quantity_amount' );
		end if;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('RCV_SHIPMENT_LINES_PKG.Update_quantity_amount', x_progress, sqlcode);
   RAISE;

  END Update_quantity_amount;


  PROCEDURE delete_line_s(
                       p_Shipment_Line_Id       IN      NUMBER) IS
        X_progress            VARCHAR2(4) := '000';
l_shipment_header_id number;
l_api_name varchar2(50);
l_itemkey varchar2(60);

 BEGIN

	select wf_item_key
	into l_itemkey
	from rcv_shipment_headers
	where shipment_header_id =( select shipment_header_id
					from rcv_shipment_lines
				where shipment_line_id= p_shipment_line_id);

	l_api_name := l_itemkey || ' delete_line_s';


	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'Enter delete_line_s');
        END IF;

	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'p_shipment_line_id '||p_shipment_line_id);
        END IF;

        update_quantity_amount(p_shipment_line_id,
                      0,--quantity_shipped
                      0); --amount_shipped

	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'Before Delete '||p_shipment_line_id);
        END IF;

        delete from rcv_shipment_lines
        where shipment_line_id= p_shipment_line_id;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('RCV_SHIPMENT_LINES_PKG.delete_line_s', x_progress, sqlcode);
   RAISE;

  END delete_line_s;

PROCEDURE update_approval_status(p_level IN VARCHAR2,
				p_approval_status IN VARCHAR2,
				p_comments IN VARCHAR2,
				p_document_id IN NUMBER) IS
x_progress varchar2(4) := '000';
l_shipment_header_id number;
l_api_name varchar2(50);
l_itemkey varchar2(60);

 BEGIN

	if (p_level = 'HEADER') then
		select wf_item_key
		into l_itemkey
		from rcv_shipment_headers
		where shipment_header_id = p_document_id;

		l_api_name := l_itemkey || ' update_approval_status';


		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
				'Enter HEADER update_approval_status');
		END IF;

		update rcv_shipment_headers
		set comments 	 = p_comments,
		last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
        where shipment_header_id = p_document_id;

	end if;

	if (p_level = 'LINE') then

		select wf_item_key
		into l_itemkey
		from rcv_shipment_headers
		where shipment_header_id =( select shipment_header_id
						from rcv_shipment_lines
					where shipment_line_id= p_document_id);

		l_api_name := l_itemkey || ' update_approval_status';


		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
				'Enter LINE  update_approval_status');
		END IF;

		update rcv_shipment_lines
		set approval_status = p_approval_status,
		comments = p_comments,
		last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
        where shipment_line_id = p_document_id;

	end if;
		IF (g_asn_debug = 'Y') THEN
		    debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
				'Leave update_approval_status');
		END IF;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('RCV_SHIPMENT_LINES_PKG.update_approval_status', x_progress, sqlcode);
   RAISE;

  END update_approval_status;

/* Bug 9534775 WC -ve correction  */
  PROCEDURE correct_wc_line(
                        p_shipment_line_id IN NUMBER,
                        p_interface_transaction_id IN NUMBER
 ) IS
        X_progress            VARCHAR2(4) := '000';
        l_api_name varchar2(50);
        l_trx_quantity NUMBER;
        l_trx_amount NUMBER;
        l_requested_amount NUMBER;
        l_material_stored_amount NUMBER;

 BEGIN

  l_api_name := 'rcv_shipment_lines_pkg.correct_wc_line';

  SELECT Nvl(quantity,0),
         Nvl(amount,0),
         Nvl(requested_amount,0),
         Nvl(material_stored_amount,0)
   INTO  l_trx_quantity,
         l_trx_amount,
         l_requested_amount,
         l_material_stored_amount
   FROM  rcv_transactions_interface
   WHERE interface_transaction_id = p_interface_transaction_id
   AND shipment_line_id =  p_shipment_line_id;


	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'Enter correct_wc_line');
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'interface_transaction_id : ' || p_interface_transaction_id);
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'shipment_line_id : ' || p_shipment_line_id);
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'quantity : ' || l_trx_quantity);
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'amount : ' || l_trx_amount);
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'requested_amount : ' || l_requested_amount);
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'material_stored_amount : ' || l_material_stored_amount);
        END IF;

        update rcv_shipment_lines
        set  quantity_shipped = quantity_shipped + l_trx_quantity,
             amount_shipped   = amount_shipped   +  l_trx_amount,
             requested_amount = requested_amount +  l_requested_amount,
             material_stored_amount = material_stored_amount + l_material_stored_amount
        WHERE shipment_line_id = p_shipment_line_id;

	IF (g_asn_debug = 'Y') THEN
            debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'Leave correct_wc_line');
        END IF;

    return;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('RCV_SHIPMENT_LINES_PKG.correct_wc_line', x_progress, sqlcode);
   RAISE;

  END correct_wc_line;
/* Bug 9534775 */

/* Bug 9534775 WC -ve correction, get available quantity for correction
   against WC and at Pay Item level receipt */

  PROCEDURE get_wc_correct_quantity(p_correction_type            IN  VARCHAR2,
				  p_parent_transaction_type    IN  VARCHAR2,
				  p_receipt_source_code        IN  VARCHAR2,
				  p_po_line_location_id        IN  NUMBER,
				  p_shipment_header_id         IN  NUMBER,
				  p_available_quantity      IN OUT NOCOPY NUMBER) IS

x_progress 			VARCHAR2(3) := NULL;
l_api_name varchar2(50);
x_available_quantity NUMBER;
x_tolerable_quantity NUMBER;
x_primary_uom VARCHAR2(26);

CURSOR get_dist_line IS
   SELECT transaction_id,Nvl(quantity,0)
   FROM rcv_transactions
   WHERE shipment_header_id = p_shipment_header_id
   AND   po_line_location_id =  p_po_line_location_id
   AND   transaction_type = p_parent_transaction_type;

BEGIN
   x_progress := 10;
   l_api_name := 'rcv_shipment_lines_pkg.get_wc_available_quantity';
   x_progress := 20;
   IF (g_asn_debug = 'Y') THEN
          debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'Enter get_wc_available_quantity');
   END IF;
   x_progress := 30;

   p_available_quantity := 0;
   FOR c_lines IN get_dist_line LOOP
        x_available_quantity := 0;

        rcv_quantities_s.get_available_quantity(p_transaction_type => 'CORRECT',
				 p_parent_id               => c_lines.transaction_id,
				 p_receipt_source_code     => p_receipt_source_code,
				 p_parent_transaction_type => p_parent_transaction_type,
				 p_grand_parent_id         => null,
				 p_correction_type         => p_correction_type,
				 p_available_quantity      => x_available_quantity,
				 p_tolerable_quantity      => x_tolerable_quantity,
				 p_unit_of_measure         => x_primary_uom
        );

        IF (g_asn_debug = 'Y') THEN
          debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'transactions_id : ' || c_lines.transaction_id
                        || ' ,available_quantity : ' || x_available_quantity );
        END IF;

        p_available_quantity := p_available_quantity + x_available_quantity;

   END LOOP;

   IF (g_asn_debug = 'Y') THEN
          debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'p_available_quantity : ' || p_available_quantity);
          debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'Leave get_wc_available_quantity');
   END IF;
   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('RCV_SHIPMENT_LINES_PKG.get_wc_available_quantity', x_progress, sqlcode);
   RAISE;

END get_wc_correct_quantity;


/* Bug 9534775 WC -ve correction, get available amount for correction
   against WC and at Pay Item receipt level */

PROCEDURE get_wc_correct_amount(p_correction_type            IN  VARCHAR2,
				  p_parent_transaction_type    IN  VARCHAR2,
				  p_receipt_source_code        IN  VARCHAR2,
				  p_po_line_location_id        IN  NUMBER,
				  p_shipment_header_id         IN  NUMBER,
				  p_available_amount      IN OUT NOCOPY NUMBER) IS

x_progress 			VARCHAR2(3) := NULL;
l_api_name varchar2(50);
x_available_amount NUMBER;
x_tolerable_amount NUMBER;
x_primary_uom VARCHAR2(26);


CURSOR get_dist_line IS
   SELECT transaction_id,Nvl(amount,0)
   FROM rcv_transactions
   WHERE shipment_header_id = p_shipment_header_id
   AND   po_line_location_id =  p_po_line_location_id
   AND   transaction_type = p_parent_transaction_type;

BEGIN
   x_progress := 10;
   l_api_name := 'rcv_shipment_lines_pkg.get_wc_available_amount';
   x_progress := 20;
   IF (g_asn_debug = 'Y') THEN
          debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'Enter get_wc_available_amount');
   END IF;
   x_progress := 30;
   p_available_amount := 0;
   FOR c_lines IN get_dist_line LOOP
        x_available_amount := 0;
        rcv_quantities_s.get_available_amount(p_transaction_type => 'CORRECT',
				 p_parent_id               => c_lines.transaction_id,
				 p_receipt_source_code     => p_receipt_source_code,
				 p_parent_transaction_type => p_parent_transaction_type,
				 p_grand_parent_id         => null,
				 p_correction_type         => p_correction_type,
				 p_available_amount        => x_available_amount,
         p_tolerable_amount        => x_tolerable_amount);

        IF (g_asn_debug = 'Y') THEN
          debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'transactions_id : ' || c_lines.transaction_id
                        || ' ,available_amount : ' || x_available_amount );
        END IF;

        p_available_amount := p_available_amount + x_available_amount;


   END LOOP;

   IF (g_asn_debug = 'Y') THEN
          debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'p_available_amount : ' || p_available_amount);
          debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'Leave get_wc_available_amount');
   END IF;
   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('RCV_SHIPMENT_LINES_PKG.get_wc_available_amount', x_progress, sqlcode);
   RAISE;

END get_wc_correct_amount;






/* rcv changes for YMS begin*/


/**
check if the x_org_id is yms_enabled
if yes, return true;else return false;
**/

FUNCTION get_yms_enable_flag(x_org_id NUMBER) RETURN BOOLEAN IS
x_yms_flag VARCHAR2(10);
yms_enable_flag BOOLEAN :=FALSE;
x_yard_org_id NUMBER;
BEGIN

    x_yard_org_id :=WMS_YMS_INTEGRATION_PVT.get_yard_org_id(x_org_id);

    IF (inv_cache.set_org_rec(x_yard_org_id)) THEN
        x_yms_flag := inv_cache.org_rec.YARD_MANAGEMENT_ENABLED_FLAG;
   	END IF;


    IF(Nvl(x_yms_flag,'N') = 'Y')  THEN
          yms_enable_flag:= TRUE;
    ELSE
         yms_enable_flag:=FALSE;
    END IF;


   RETURN  yms_enable_flag;

   EXCEPTION
    WHEN OTHERS THEN  RETURN FALSE;
END get_yms_enable_flag;



/**
 ** insert into RSL with insert RSL with the splitting data in the splitting window;
 ** the shipment id should be 1.2, 1.3 ..;
 **/
PROCEDURE insert_rsl_split_line(
             X_Shipment_Line_Id	        IN NUMBER,
             x_user_id                  IN NUMBER,
             x_logon_id                 IN NUMBER,
             x_qty1                     IN NUMBER,
             x_qty2                     IN NUMBER,
             x_line_num                 IN NUMBER,
             x_equipment_id             IN NUMBER
      )IS
    X_progress            VARCHAR2(4) := '000';
    l_shipment_line_id    NUMBER;
    l_api_name varchar2(50);
    x_to_org_primary_qty NUMBER;

    CURSOR C IS
        SELECT *
        FROM   RCV_SHIPMENT_LINES
        WHERE  shipment_line_id = x_shipment_line_id;
    Recinfo C%ROWTYPE;

    CURSOR C_MS IS
      SELECT *
      FROM mtl_supply
      WHERE shipment_line_id = x_shipment_line_id and SUPPLY_TYPE_CODE = 'SHIPMENT';

    MS_Recinfo   C_MS%ROWTYPE;

BEGIN
    l_api_name := 'rcv_shipment_lines_pkg.insert_rsl_split_line';
    IF (g_asn_debug = 'Y') THEN
      debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'enter the procedure !');
    END IF;
    X_progress            := '010';
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

    OPEN C_MS;
    FETCH C_MS INTO MS_Recinfo;
    if (C_MS%NOTFOUND) then
      CLOSE C_MS;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C_MS;
    X_progress             := '020';

    SELECT rcv_shipment_lines_s.nextval
       INTO   l_shipment_line_id
    FROM   sys.dual;

    IF (g_asn_debug = 'Y') THEN
          debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'new shipment_line_id'||l_shipment_line_id);
    END IF;

    INSERT INTO rcv_shipment_lines (
        SHIPMENT_LINE_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        SHIPMENT_HEADER_ID,
        LINE_NUM,
        CATEGORY_ID,
        QUANTITY_SHIPPED,
        QUANTITY_RECEIVED,
        UNIT_OF_MEASURE,
        ITEM_DESCRIPTION,
        ITEM_ID,
        ITEM_REVISION,
        VENDOR_ITEM_NUM,
        VENDOR_LOT_NUM,
        UOM_CONVERSION_RATE,
        SHIPMENT_LINE_STATUS_CODE,
        SOURCE_DOCUMENT_CODE,
        PO_HEADER_ID,
        PO_RELEASE_ID,
        PO_LINE_ID,
        PO_LINE_LOCATION_ID,
        PO_DISTRIBUTION_ID,
        REQUISITION_LINE_ID,
        REQ_DISTRIBUTION_ID,
        ROUTING_HEADER_ID,
        PACKING_SLIP,
        FROM_ORGANIZATION_ID,
        DELIVER_TO_PERSON_ID,
        EMPLOYEE_ID,
        DESTINATION_TYPE_CODE,
        TO_ORGANIZATION_ID,
        TO_SUBINVENTORY,
        LOCATOR_ID,
        DELIVER_TO_LOCATION_ID,
        CHARGE_ACCOUNT_ID,
        TRANSPORTATION_ACCOUNT_ID,
        SHIPMENT_UNIT_PRICE,
        TRANSFER_COST,
        TRANSPORTATION_COST,
        COMMENTS,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        REASON_ID,
        USSGL_TRANSACTION_CODE,
        GOVERNMENT_CONTEXT,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        DESTINATION_CONTEXT,
        PRIMARY_UNIT_OF_MEASURE,
        EXCESS_TRANSPORT_REASON,
        EXCESS_TRANSPORT_RESPONSIBLE,
        EXCESS_TRANSPORT_AUTH_NUM,
        ASN_LINE_FLAG,
        ORIGINAL_ASN_PARENT_LINE_ID,
        ORIGINAL_ASN_LINE_FLAG,
        VENDOR_CUM_SHIPPED_QUANTITY,
        NOTICE_UNIT_PRICE,
        TAX_NAME,
        TAX_AMOUNT,
        INVOICE_STATUS_CODE,
        CUM_COMPARISON_FLAG,
        CONTAINER_NUM,
        TRUCK_NUM,
        BAR_CODE_LABEL,
        TRANSFER_PERCENTAGE,
        MRC_SHIPMENT_UNIT_PRICE,
        MRC_TRANSFER_COST,
        MRC_TRANSPORTATION_COST,
        MRC_NOTICE_UNIT_PRICE,
        SHIP_TO_LOCATION_ID,
        COUNTRY_OF_ORIGIN_CODE,
        OE_ORDER_HEADER_ID,
        OE_ORDER_LINE_ID,
        CUSTOMER_ITEM_NUM,
        COST_GROUP_ID,
        SECONDARY_QUANTITY_SHIPPED,
        SECONDARY_QUANTITY_RECEIVED,
        SECONDARY_UNIT_OF_MEASURE,
        QC_GRADE,
        MMT_TRANSACTION_ID,
        ASN_LPN_ID,
        AMOUNT,
        AMOUNT_RECEIVED,
        JOB_ID,
        TIMECARD_ID,
        TIMECARD_OVN,
        OSA_FLAG,
        REQUESTED_AMOUNT,
        MATERIAL_STORED_AMOUNT,
        APPROVAL_STATUS,
        AMOUNT_SHIPPED,
        LCM_SHIPMENT_LINE_ID,
        UNIT_LANDED_COST,
        EQUIPMENT_ID )
      VALUES (
        l_SHIPMENT_LINE_ID,
        Sysdate,
        x_user_id,
        Sysdate,
        x_user_id,
        x_logon_id,
        Recinfo.SHIPMENT_HEADER_ID,
        x_line_num,
        Recinfo.CATEGORY_ID,
        x_qty1,
        0,
        Recinfo.UNIT_OF_MEASURE,
        Recinfo.ITEM_DESCRIPTION,
        Recinfo.ITEM_ID,
        Recinfo.ITEM_REVISION,
        Recinfo.VENDOR_ITEM_NUM,
        Recinfo.VENDOR_LOT_NUM,
        Recinfo.UOM_CONVERSION_RATE,
        'EXPECTED',
        Recinfo.SOURCE_DOCUMENT_CODE,
        Recinfo.PO_HEADER_ID,
        Recinfo.PO_RELEASE_ID,
        Recinfo.PO_LINE_ID,
        Recinfo.PO_LINE_LOCATION_ID,
        Recinfo.PO_DISTRIBUTION_ID,
        Recinfo.REQUISITION_LINE_ID,
        Recinfo.REQ_DISTRIBUTION_ID,
        Recinfo.ROUTING_HEADER_ID,
        Recinfo.PACKING_SLIP,
        Recinfo.FROM_ORGANIZATION_ID,
        Recinfo.DELIVER_TO_PERSON_ID,
        Recinfo.EMPLOYEE_ID,
        Recinfo.DESTINATION_TYPE_CODE,
        Recinfo.TO_ORGANIZATION_ID,
        Recinfo.TO_SUBINVENTORY,
        Recinfo.LOCATOR_ID,
        Recinfo.DELIVER_TO_LOCATION_ID,
        Recinfo.CHARGE_ACCOUNT_ID,
        Recinfo.TRANSPORTATION_ACCOUNT_ID,
        Recinfo.SHIPMENT_UNIT_PRICE,
        Recinfo.TRANSFER_COST,
        Recinfo.TRANSPORTATION_COST,
        Recinfo.COMMENTS,
        Recinfo.ATTRIBUTE_CATEGORY,
        Recinfo.ATTRIBUTE1,
        Recinfo.ATTRIBUTE2,
        Recinfo.ATTRIBUTE3,
        Recinfo.ATTRIBUTE4,
        Recinfo.ATTRIBUTE5,
        Recinfo.ATTRIBUTE6,
        Recinfo.ATTRIBUTE7,
        Recinfo.ATTRIBUTE8,
        Recinfo.ATTRIBUTE9,
        Recinfo.ATTRIBUTE10,
        Recinfo.ATTRIBUTE11,
        Recinfo.ATTRIBUTE12,
        Recinfo.ATTRIBUTE13,
        Recinfo.ATTRIBUTE14,
        Recinfo.ATTRIBUTE15,
        Recinfo.REASON_ID,
        Recinfo.USSGL_TRANSACTION_CODE,
        Recinfo.GOVERNMENT_CONTEXT,
        Recinfo.REQUEST_ID,
        Recinfo.PROGRAM_APPLICATION_ID,
        Recinfo.PROGRAM_ID,
        Recinfo.PROGRAM_UPDATE_DATE,
        Recinfo.DESTINATION_CONTEXT,
        Recinfo.PRIMARY_UNIT_OF_MEASURE,
        Recinfo.EXCESS_TRANSPORT_REASON,
        Recinfo.EXCESS_TRANSPORT_RESPONSIBLE,
        Recinfo.EXCESS_TRANSPORT_AUTH_NUM,
        Recinfo.ASN_LINE_FLAG,
        Recinfo.ORIGINAL_ASN_PARENT_LINE_ID,
        Recinfo.ORIGINAL_ASN_LINE_FLAG,
        Recinfo.VENDOR_CUM_SHIPPED_QUANTITY,
        Recinfo.NOTICE_UNIT_PRICE,
        Recinfo.TAX_NAME,
        Recinfo.TAX_AMOUNT,
        Recinfo.INVOICE_STATUS_CODE,
        Recinfo.CUM_COMPARISON_FLAG,
        Recinfo.CONTAINER_NUM,
        Recinfo.TRUCK_NUM,
        Recinfo.BAR_CODE_LABEL,
        Recinfo.TRANSFER_PERCENTAGE,
        Recinfo.MRC_SHIPMENT_UNIT_PRICE,
        Recinfo.MRC_TRANSFER_COST,
        Recinfo.MRC_TRANSPORTATION_COST,
        Recinfo.MRC_NOTICE_UNIT_PRICE,
        Recinfo.SHIP_TO_LOCATION_ID,
        Recinfo.COUNTRY_OF_ORIGIN_CODE,
        Recinfo.OE_ORDER_HEADER_ID,
        Recinfo.OE_ORDER_LINE_ID,
        Recinfo.CUSTOMER_ITEM_NUM,
        Recinfo.COST_GROUP_ID,
        x_qty2,
        0,
        Recinfo.SECONDARY_UNIT_OF_MEASURE,
        Recinfo.QC_GRADE,
        Recinfo.MMT_TRANSACTION_ID,
        Recinfo.ASN_LPN_ID,
        Recinfo.AMOUNT,
        Recinfo.AMOUNT_RECEIVED,
        Recinfo.JOB_ID,
        Recinfo.TIMECARD_ID,
        Recinfo.TIMECARD_OVN,
        Recinfo.OSA_FLAG,
        Recinfo.REQUESTED_AMOUNT,
        Recinfo.MATERIAL_STORED_AMOUNT,
        Recinfo.APPROVAL_STATUS,
        Recinfo.AMOUNT_SHIPPED,
        Recinfo.LCM_SHIPMENT_LINE_ID,
        Recinfo.UNIT_LANDED_COST,
        x_equipment_id
        );


         X_progress             := '030';

         x_to_org_primary_qty:=get_primary_qty(x_qty1,Recinfo.UNIT_OF_MEASURE,Recinfo.ITEM_ID,Recinfo.TO_ORGANIZATION_ID);
         INSERT INTO mtl_supply (
                SUPPLY_TYPE_CODE
               ,SUPPLY_SOURCE_ID
               ,LAST_UPDATED_BY
               ,LAST_UPDATE_DATE
               ,LAST_UPDATE_LOGIN
               ,CREATED_BY
               ,CREATION_DATE
               ,PROGRAM_APPLICATION_ID
               ,PROGRAM_ID
               ,PROGRAM_UPDATE_DATE
               ,REQ_HEADER_ID
               ,REQ_LINE_ID
               ,PO_HEADER_ID
               ,PO_RELEASE_ID
               ,PO_LINE_ID
               ,PO_LINE_LOCATION_ID
               ,PO_DISTRIBUTION_ID
               ,SHIPMENT_HEADER_ID
               ,SHIPMENT_LINE_ID
               ,RCV_TRANSACTION_ID
               ,ITEM_ID
               ,ITEM_REVISION
               ,CATEGORY_ID
               ,QUANTITY
               ,UNIT_OF_MEASURE
               ,TO_ORG_PRIMARY_QUANTITY
               ,TO_ORG_PRIMARY_UOM
               ,RECEIPT_DATE
               ,NEED_BY_DATE
               ,EXPECTED_DELIVERY_DATE
               ,DESTINATION_TYPE_CODE
               ,LOCATION_ID
               ,FROM_ORGANIZATION_ID
               ,FROM_SUBINVENTORY
               ,TO_ORGANIZATION_ID
               ,TO_SUBINVENTORY
               ,INTRANSIT_OWNING_ORG_ID
               ,MRP_PRIMARY_QUANTITY
               ,MRP_PRIMARY_UOM
               ,MRP_EXPECTED_DELIVERY_DATE
               ,MRP_DESTINATION_TYPE_CODE
               ,MRP_TO_ORGANIZATION_ID
               ,MRP_TO_SUBINVENTORY
               ,CHANGE_FLAG
               ,CHANGE_TYPE
               ,COST_GROUP_ID
               ,EXCLUDE_FROM_PLANNING)
            values(
                MS_Recinfo.SUPPLY_TYPE_CODE
               ,l_SHIPMENT_LINE_ID
               ,x_user_id
               ,Sysdate
               ,x_logon_id
               ,x_user_id
               ,Sysdate
               ,MS_Recinfo.PROGRAM_APPLICATION_ID
               ,MS_Recinfo.PROGRAM_ID
               ,MS_Recinfo.PROGRAM_UPDATE_DATE
               ,MS_Recinfo.REQ_HEADER_ID
               ,MS_Recinfo.REQ_LINE_ID
               ,MS_Recinfo.PO_HEADER_ID
               ,MS_Recinfo.PO_RELEASE_ID
               ,MS_Recinfo.PO_LINE_ID
               ,MS_Recinfo.PO_LINE_LOCATION_ID
               ,MS_Recinfo.PO_DISTRIBUTION_ID
               ,MS_Recinfo.SHIPMENT_HEADER_ID
               ,l_SHIPMENT_LINE_ID
               ,MS_Recinfo.RCV_TRANSACTION_ID
               ,MS_Recinfo.ITEM_ID
               ,MS_Recinfo.ITEM_REVISION
               ,MS_Recinfo.CATEGORY_ID
               ,x_qty1
               ,MS_Recinfo.UNIT_OF_MEASURE
               ,x_to_org_primary_qty
               ,MS_Recinfo.TO_ORG_PRIMARY_UOM
               ,MS_Recinfo.RECEIPT_DATE
               ,MS_Recinfo.NEED_BY_DATE
               ,MS_Recinfo.EXPECTED_DELIVERY_DATE
               ,MS_Recinfo.DESTINATION_TYPE_CODE
               ,MS_Recinfo.LOCATION_ID
               ,MS_Recinfo.FROM_ORGANIZATION_ID
               ,MS_Recinfo.FROM_SUBINVENTORY
               ,MS_Recinfo.TO_ORGANIZATION_ID
               ,MS_Recinfo.TO_SUBINVENTORY
               ,MS_Recinfo.INTRANSIT_OWNING_ORG_ID
               ,MS_Recinfo.MRP_PRIMARY_QUANTITY
               ,MS_Recinfo.MRP_PRIMARY_UOM
               ,MS_Recinfo.MRP_EXPECTED_DELIVERY_DATE
               ,MS_Recinfo.MRP_DESTINATION_TYPE_CODE
               ,MS_Recinfo.MRP_TO_ORGANIZATION_ID
               ,MS_Recinfo.MRP_TO_SUBINVENTORY
               ,MS_Recinfo.CHANGE_FLAG
               ,MS_Recinfo.CHANGE_TYPE
               ,MS_Recinfo.COST_GROUP_ID
               ,MS_Recinfo.EXCLUDE_FROM_PLANNING);
EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('RCV_SHIPMENT_LINES_PKG.insert_rsl_split_line', x_progress, sqlcode);
      ROLLBACK;
      RAISE;

End insert_rsl_split_line;

/**
** update the original rsl with the shipped quantity = the original quantity- total splitting quantity
** and LINE_NUM to 1.1;
**/
PROCEDURE  update_split_original_line(
             X_Shipment_Line_Id	        IN NUMBER,
             x_user_id                  IN NUMBER,
             x_logon_id                 IN NUMBER,
             X_qty1                      IN NUMBER,
             X_qty2                      IN NUMBER,
             X_linenum                   IN NUMBER
      )IS
    X_progress            VARCHAR2(4) := '000';
    l_api_name varchar2(50);
    x_to_org_primary_quantity NUMBER;
    x_item_id NUMBER;
    x_to_org_id NUMBER;
    x_uom VARCHAR2(50);

BEGIN

    l_api_name := 'rcv_shipment_lines_pkg.update_split_original_line';
    IF (g_asn_debug = 'Y') THEN
      debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'enter the procedure !');
    END IF;
    X_progress            := '010';
    UPDATE rcv_shipment_lines SET line_num=X_linenum,  QUANTITY_SHIPPED = X_qty1,  SECONDARY_QUANTITY_SHIPPED= X_qty2,LAST_UPDATED_BY = x_user_id, LAST_UPDATE_DATE=SYSDATE, LAST_UPDATE_LOGIN=x_logon_id
    WHERE  shipment_line_id = x_shipment_line_id;

    X_progress            := '020';


    SELECT item_id, TO_ORGANIZATION_ID,UNIT_OF_MEASURE
    INTO x_item_id, x_to_org_id,x_uom
    FROM   rcv_shipment_lines  WHERE  shipment_line_id = x_shipment_line_id;

    x_to_org_primary_quantity := get_primary_qty(X_qty1,x_uom,x_item_id,x_to_org_id);


    X_progress            := '030';
    UPDATE mtl_supply
    SET QUANTITY= X_qty1,
        TO_ORG_PRIMARY_QUANTITY=x_to_org_primary_quantity,
        LAST_UPDATED_BY = x_user_id,
        LAST_UPDATE_DATE=SYSDATE,
        LAST_UPDATE_LOGIN=x_logon_id
    WHERE shipment_line_id = x_shipment_line_id AND SUPPLY_TYPE_CODE ='SHIPMENT';

    EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('RCV_SHIPMENT_LINES_PKG.update_split_original_line', x_progress, sqlcode);
      ROLLBACK;
      RAISE;


End update_split_original_line;


/**
** API provide to YMS to return the item value at the equipment_id level
**/
PROCEDURE  get_rsl_value_for_yms (
             p_shipment_header_id   IN NUMBER
            ,p_equipment_id    IN  NUMBER
            ,x_value         OUT NOCOPY NUMBER
            ,x_pending_receipt_qty   OUT NOCOPY BOOLEAN
            ,x_ret_msg        OUT NOCOPY VARCHAR2
            ,x_return_status  OUT NOCOPY VARCHAR2) IS
l_api_name varchar2(50);
primary_qty NUMBER:=0;
total_primary_qty NUMBER:= 0;
item_cost           NUMBER;
item_cost_curr_code VARCHAR2(30);
return_status       VARCHAR2(2);
msg_count           NUMBER;
msg_data            VARCHAR2(1000);
x_progress VARCHAR2(10) := '010';


CURSOR rsl_rec IS
SELECT rsl.*, rsh.shipment_num
FROM   rcv_shipment_lines rsl, rcv_shipment_headers rsh
WHERE  rsh.shipment_header_id = p_shipment_header_id
AND    rsh.shipment_header_id = rsl.shipment_header_id
AND     ((rsh.RECEIPT_SOURCE_CODE = 'VENDOR' AND rsh.ASN_TYPE = 'ASN')
     OR  (rsh.RECEIPT_SOURCE_CODE = 'INTERNAL ORDER') OR (rsh.RECEIPT_SOURCE_CODE = 'INVENTORY'))
AND  rsl.SHIPMENT_LINE_STATUS_CODE IN('EXPECTED','PARTIALLY RECEIVED')
AND  rsl.equipment_id= p_equipment_id;



BEGIN
  l_api_name := 'rcv_shipment_lines_pkg.get_rsl_value_for_yms';
  IF (g_asn_debug = 'Y') THEN
      debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'p_shipment_header_id:' ||p_shipment_header_id||
                        'equipment_id: '||p_equipment_id);
  END IF;
  x_value:=0;

  FOR recinfo IN rsl_rec LOOP
     x_progress := '020';
     primary_qty:= get_primary_qty((recinfo.quantity_shipped - nvl(recinfo.quantity_received,0)),
                                                                  recinfo.UNIT_OF_MEASURE,
                                                                  recinfo.item_id,
                                                                  recinfo.TO_ORGANIZATION_ID);
     IF (g_asn_debug = 'Y') THEN
         debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'primary_qty:' ||primary_qty);
     END IF;

     x_progress := '030';
     WMS_YMS_INTEGRATION_PVT.get_item_cost(recinfo.item_id,                --inventory item id from mtl_system_items
                                           recinfo.TO_ORGANIZATION_ID,     --inventory org id
                                           recinfo.source_document_code,   --like RMA, PO, ASN etc
                                           recinfo.shipment_num,           -- RMA number, ASN number etc
                                           recinfo.shipment_header_id,     --RMA header_id , ASN header_id etc
                                           item_cost,
                                           item_cost_curr_code,
                                           return_status,
                                           msg_count,
                                           msg_data);
      IF (g_asn_debug = 'Y') THEN
         debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'item cost from YMS:' ||item_cost);
      END IF;

     IF(return_status <> FND_API.g_ret_sts_success) THEN
       x_return_status := fnd_api.g_ret_sts_error;
       x_value :=NULL;
       x_ret_msg:= msg_data;
       x_pending_receipt_qty :=FALSE;
       RETURN;
     END IF;
     x_progress := '040';
     total_primary_qty := total_primary_qty + primary_qty;
     x_value :=x_value + primary_qty * item_cost;
  END LOOP;

  IF (g_asn_debug = 'Y') THEN
         debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'rsl value for YMS: '||x_value);
  END IF;
  x_progress := '050';

  x_return_status  :=FND_API.g_ret_sts_success;

  IF(total_primary_qty >0) THEN
    x_pending_receipt_qty :=TRUE;
  ELSE
    x_pending_receipt_qty :=FALSE;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       po_message_s.sql_error('get_rsl_value_for_yms', x_progress, sqlcode);
       x_return_status := fnd_api.g_ret_sts_error;
       x_value :=NULL;
       x_ret_msg:= SQLERRM(sqlcode);
       x_pending_receipt_qty :=FALSE;
END get_rsl_value_for_yms;

/**
** get the primary quantity
**/
FUNCTION get_primary_qty
        (x_current_qty NUMBER,
         x_current_uom VARCHAR2,
         x_item_id NUMBER,
         x_to_org_id NUMBER
         ) RETURN   NUMBER    AS
x_primary_uom VARCHAR2(10);
x_primary_qty NUMBER;
x_progress VARCHAR2(10);

BEGIN
    x_progress:= '010';
    x_primary_uom:= PO_UOM_S.get_primary_uom(x_item_id,x_to_org_id,x_current_uom);
    x_progress:= '020';
    PO_UOM_S.uom_convert(x_current_qty,x_current_uom,x_item_id,x_primary_uom,x_primary_qty);
    RETURN   x_primary_qty;


    EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('uom_convert', x_progress, sqlcode);
      RAISE;
END;

/**
** API provide to YMS to update the equipment_id by shipment_header_id, and return the result status.
**/

PROCEDURE  set_yms_equipment (
             p_shipment_header_id IN  NUMBER ,
             p_equipment_id   IN NUMBER ,
             p_shipment_line_id  IN      NUMBER DEFAULT NULL,
             x_return_status  OUT NOCOPY VARCHAR2,
             x_msg_data OUT NOCOPY VARCHAR2) IS


l_api_name varchar2(50);

x_progress VARCHAR2(10) :='010';
x_shipment_num rcv_shipment_headers.shipment_num%TYPE;


BEGIN
    l_api_name:= 'rcv_shipment_lines_pkg.set_yms_equipment';
    IF (g_asn_debug = 'Y') THEN
          debug_log(FND_LOG.LEVEL_STATEMENT,l_api_name,
                        'equipment_id: '||p_equipment_id);
    END IF;


    SELECT  shipment_num
    INTO   x_shipment_num
    FROM   rcv_shipment_headers
    WHERE  shipment_header_id = p_shipment_header_id;

   IF (p_shipment_line_id IS null)   THEN
    UPDATE  rcv_shipment_lines SET equipment_id = p_equipment_id
    WHERE shipment_header_id = p_shipment_header_id AND
          SHIPMENT_LINE_STATUS_CODE = 'EXPECTED' ;
   ELSE
     UPDATE  rcv_shipment_lines SET equipment_id = p_equipment_id
     WHERE shipment_line_id = p_shipment_line_id AND
          SHIPMENT_LINE_STATUS_CODE = 'EXPECTED' ;
   END IF;

    x_progress :='020';
    IF SQL%ROWCOUNT = 0 THEN
       fnd_message.set_name('PO','RCV_UPDATE_EQUIPMENT_FAIL');
       fnd_message.set_token('Docnum',x_shipment_num);
       x_msg_data:= fnd_message.get;
       fnd_message.set_name('INV','INV_NO_UPDATE');
       fnd_message.set_token('TABLE','rcv_shipment_lines');
       x_msg_data:= x_msg_data || '. '|| fnd_message.get;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
    END IF;
    x_progress :='030';
    x_return_status :=FND_API.g_ret_sts_success;

    EXCEPTION
    WHEN OTHERS THEN
        --po_message_s.sql_error('fail to set yms equipment id', x_progress, sqlcode);
        fnd_message.set_name('PO','RCV_UPDATE_EQUIPMENT_FAIL');
        fnd_message.set_token('DOCNUM',x_shipment_num);
        x_msg_data:= fnd_message.get;
        fnd_message.set_name('INV','INV_SETUP_PLSQL_EXCEPTION');
        fnd_message.SET_token('PLSQL_ERROR_MESSAGE',SQLERRM(sqlcode));
        x_msg_data :=x_msg_data||'. '|| fnd_message.get;
        x_return_status := fnd_api.g_ret_sts_error;

END set_yms_equipment;


PROCEDURE update_yms_content(x_equipment_id NUMBER,
                             x_equipment_id_old NUMBER DEFAULT  NULL ,
                             x_header_id    NUMBER
                             ) IS

x_yms_ycd_record                  WMS_YMS_INTEGRATION_PVT.yms_ycd_record;
x_yms_ycd_record_old              WMS_YMS_INTEGRATION_PVT.yms_ycd_record;
x_yms_eqp_contents_tbl_type       WMS_YMS_INTEGRATION_PVT.yms_eqp_contents_tbl_type;
x_return_status             VARCHAR2(10);
x_msg_count                 NUMBER;
x_msg_data                  VARCHAR2(1000);


BEGIN
      IF(x_equipment_id  IS NOT null) THEN

        x_yms_ycd_record.equipment_id:=x_equipment_id;
        x_yms_ycd_record.document_type:=  'ASN';
        x_yms_ycd_record.document_header_id:= x_header_id;
        x_yms_eqp_contents_tbl_type(1):=x_yms_ycd_record;
      END IF;
      IF(x_equipment_id_old  IS NOT null) THEN
         x_yms_ycd_record_old.equipment_id:=x_equipment_id_old;
         x_yms_ycd_record_old.document_type:=  'ASN';
         x_yms_ycd_record_old.document_header_id:= x_header_id;
         x_yms_eqp_contents_tbl_type(2):=x_yms_ycd_record_old;
      END IF;

      WMS_YMS_INTEGRATION_PVT.update_yms_content_docs(x_yms_eqp_contents_tbl_type,'RCV',x_return_status,x_msg_count,x_msg_data);
      IF(x_return_status <>FND_API.g_ret_sts_success) THEN
        debug_log(FND_LOG.LEVEL_STATEMENT,'RCV_SHIPMENT_LINES_PKG.update_yms_content',
                        ' fail to update the yms content: '||x_msg_data);
      ELSE
        debug_log(FND_LOG.LEVEL_STATEMENT,'RCV_SHIPMENT_LINES_PKG.update_yms_content',
                        ' update the yms content : '||x_msg_count);
      END IF;
      EXCEPTION
      WHEN OTHERS THEN
         debug_log(FND_LOG.LEVEL_STATEMENT,'RCV_SHIPMENT_LINES_PKG.update_yms_content',
                        ' fail to update the yms content');

END update_yms_content;


/**
**     get equipment status of the shipment, if have multiple status, then show 'Multiple'
**/
FUNCTION get_equipment_status( x_header_id    NUMBER )  RETURN   VARCHAR2    AS
l_status_code mfg_lookups.meaning%TYPE;

BEGIN
    SELECT  DISTINCT equipment_status
    INTO    l_status_code
    FROM    wms_yms_equipment_v
    WHERE equipment_id  IN
    (SELECT DISTINCT equipment_id FROM rcv_shipment_lines WHERE shipment_header_id =  x_header_id   AND  equipment_id IS NOT null);
    RETURN   l_status_code;


    EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      select displayed_field
      INTO   l_status_code
      from po_lookup_codes where  lookup_type = 'RCV DESTINATION TYPE' AND lookup_code = 'MULTIPLE';
      RETURN   l_status_code;

    WHEN  NO_DATA_FOUND   THEN
      l_status_code := '';
      RETURN   l_status_code;

    WHEN OTHERS THEN
      l_status_code := '';
      RETURN   l_status_code;
END get_equipment_status;


 /* split line ER End*/

END RCV_SHIPMENT_LINES_PKG;

/

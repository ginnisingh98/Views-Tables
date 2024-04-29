--------------------------------------------------------
--  DDL for Package Body JL_ZZ_RECEIV_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_RECEIV_INTERFACE" AS
/* $Header: jlzzorib.pls 120.21.12010000.5 2009/03/06 21:58:47 pla ship $ */

/*----------------------------------------------------------------------------*
 |   PRIVATE FUNCTIONS/PROCEDURES                                              |
 *----------------------------------------------------------------------------*/

PROCEDURE init_gdf (
        p_line_rec     IN OUT NOCOPY OE_Invoice_PUB.OE_GDF_Rec_Type );

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES             |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    copy_gdff                                    	      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    For each row created in the current submission of OM Invoicing process, |
 |    this procedure copies required global attribute columns to the interface|
 |    table. 				                                      |
 |									      |
 | PARAMETERS                                                                 |
 |   INPUT                                                 		      |
 |      p_interface_line_rec    OE_Invoice_PUB.OE_GDF_Rec_Type                |
 |                              Interface line record declared in OEXPINVS.pls|
 |   OUTPUT                                                		      |
 |      x_interface_line_rec    OE_Invoice_PUB.OE_GDF_Rec_Type                |
 |                              Interface line record declared in OEXPINVS.pls|
 |      x_error_buffer          VARCHAR2 -- Error Message  	              |
 |      x_return_code         	NUMBER   -- Error Code.           	      |
 |                                          0 - Success, 2 - Failure. 	      |
 |                                                                            |
 | HISTORY                                                                    |
 |                                                                            |
 |   24-JAN-2000 Harsh Takle      Created.                                    |
 |   18-FEB-2000 Satyadeep Chandrashekar     Modified to split the SQL into   |
 |                                           two - one for OM and one for     |
 |                                           shipping (bug 1202351)           |
 |    31-AUG-2000  Satyadeep Chandrashekar   Modified Bug 1395885             |
 |    04-OCT-2008  Palaniyandi Kumaresan     Modified for Brazilian SPED      |
 *----------------------------------------------------------------------------*/
PROCEDURE copy_gdff (
        p_interface_line_rec IN     OE_Invoice_PUB.OE_GDF_Rec_Type,
        x_interface_line_rec IN OUT NOCOPY OE_Invoice_PUB.OE_GDF_Rec_Type,
        x_return_code        IN OUT NOCOPY NUMBER,
	x_error_buffer       IN OUT NOCOPY VARCHAR2) IS

  l_so_organization_id 	 NUMBER(15);
  l_country_code 	 VARCHAR2(2);
  l_tax_method           VARCHAR2(30);

  l_header_attr_category VARCHAR2(30);
  l_line_attr_category   VARCHAR2(30);

  l_volume_qty            VARCHAR2(150);
  l_volume_type           VARCHAR2(150);
  l_volume_number         VARCHAR2(150);
  l_vehicle_number        VARCHAR2(150);
  l_gross_weight          NUMBER;
  l_net_weight            NUMBER;
  l_item_origin           VARCHAR2(150);
  l_item_fiscal_type      VARCHAR2(150);
  l_fsc_cls_code          VARCHAR2(30);
  l_trx_cls_code          VARCHAR2(30);
  l_inventory_item_id     NUMBER;
  l_line_id               NUMBER;
  l_order_line_id         NUMBER;
  l_invoice_line_id       NUMBER;
  l_op_fiscal_code        VARCHAR2(5);
  l_fed_trib_situation    VARCHAR2(25);
  l_sta_trib_situation    VARCHAR2(25);

  l_org_id                NUMBER;
  l_jl                    VARCHAR2(2);

  /* Added for Brazilian SPED */
   l_veh_plate_state_code VARCHAR2(5);
   l_veh_antt_inscr       VARCHAR2(50);
   l_tow_veh_plate_num    VARCHAR2(50);
   l_tow_veh_plate_state_code VARCHAR2(5);
   l_tow_veh_antt_inscr   VARCHAR2(50);
   l_seal_number          VARCHAR2(150);
  /*End*/

  CURSOR read_gdffs IS
    SELECT ol.global_attribute1    op_fiscal_code,
           ol.global_attribute2    freight_acc_expense,
           ol.global_attribute3    insurance_acc_expense,
           ol.global_attribute4    other_acc_expense,
           ol.global_attribute5    item_line_fiscal_class,
           ol.global_attribute6    item_line_trx_reason,
           msi.global_attribute3   item_origin,
           msi.global_attribute4   item_fiscal_type,
           msi.global_attribute5   fed_trib_situation,
           msi.global_attribute6   sta_trib_situation
    FROM   oe_order_lines ol,
           mtl_system_items msi
    WHERE  line_id = l_line_id
    AND    msi.inventory_item_id(+) = l_inventory_item_id
    AND    msi.organization_id      = l_so_organization_id;

  read_gdffs_rec  read_gdffs%ROWTYPE;

BEGIN

  x_return_code := 0;
  x_error_buffer := NULL;
  x_interface_line_rec := p_interface_line_rec;
  --Following line is commented as a part of bug 2133665
  --l_country_code := fnd_profile.value('JGZZ_COUNTRY_CODE');
  --
  l_country_code := SUBSTR(x_interface_line_rec.line_gdf_attr_category,4,2);

  l_jl := 'JL';
  --
  OE_DEBUG_PUB.ADD('JL-Country Code is ' || l_country_code);

  IF NVL(l_country_code,'$') IN ('BR','AR','CO') THEN

     l_tax_method := JL_ZZ_AR_TX_LIB_PKG.get_tax_method(l_org_id);
     OE_DEBUG_PUB.ADD('JL-Tax Method is ' || l_tax_method);

     l_so_organization_id:= to_number(oe_profile.value('SO_ORGANIZATION_ID'));
     OE_DEBUG_PUB.ADD('JL-So Organization id is ' || l_so_organization_id);

     IF l_country_code = 'BR' THEN
        l_header_attr_category :=  'JL.BR.ARXTWMAI.Additional Info';
        l_line_attr_category   :=  'JL.BR.ARXTWMAI.Additional Info';
     ELSE
      --  l_header_attr_category :=  'JL'||'.'||l_country_code||'.ARXTWMAI.HEADER';
        l_header_attr_category :=  l_jl||'.'||l_country_code||'.ARXTWMAI.HEADER';
      --  l_line_attr_category   := 'JL'||'.'||l_country_code||'.ARXTWMAI.LINES';
       l_line_attr_category   := l_jl||'.'||l_country_code||'.ARXTWMAI.LINES';
     END IF;

     l_line_id := p_interface_line_rec.interface_line_attribute6;
     l_inventory_item_id := p_interface_line_rec.inventory_item_id;

     OE_DEBUG_PUB.ADD('JL-Line Id '|| l_line_id);
     OE_DEBUG_PUB.ADD('JL-Inventory Item Id '|| l_inventory_item_id);
     OE_DEBUG_PUB.ADD('JL-Line Type '|| p_interface_line_rec.line_type);

     l_invoice_line_id := NULL;
     l_order_line_id := NULL;
     IF l_tax_method = 'LTE' THEN

       --
       -- Bug#5588076- init GDF for LTE
       --
       init_gdf(x_interface_line_rec);

       BEGIN
         SELECT REFERENCE_CUSTOMER_TRX_LINE_ID,
                REFERENCE_LINE_ID
         INTO   l_invoice_line_id,
                l_order_line_id
         FROM   oe_order_lines
         WHERE  line_id = l_line_id;
       EXCEPTION
         WHEN OTHERS THEN
              l_invoice_line_id := NULL;
              l_order_line_id := NULL;
       END;

     END IF;

     OE_DEBUG_PUB.ADD('JL-Invoice Line Id '|| l_invoice_line_id);
     OE_DEBUG_PUB.ADD('JL-Return Id '|| l_order_line_id);

     IF (l_invoice_line_id IS NULL AND
         l_order_line_id IS NULL) THEN

        /* Copy Global DFF columns from OE tables */
        IF l_country_code = 'BR' THEN

           OPEN read_gdffs;
           LOOP

             FETCH read_gdffs INTO read_gdffs_rec;

             EXIT WHEN read_gdffs%NOTFOUND OR
                       read_gdffs%NOTFOUND is NULL;

             IF l_tax_method = 'LTE' THEN
                l_fsc_cls_code := read_gdffs_rec.item_line_fiscal_class;
                l_trx_cls_code := read_gdffs_rec.item_line_trx_reason;
             ELSE
                l_fsc_cls_code := NULL;
                l_trx_cls_code := NULL;
             END IF;

             IF p_interface_line_rec.line_type = 'LINE' THEN

                BEGIN
                  OE_DEBUG_PUB.ADD('JL-Delivery Name '||
                                p_interface_line_rec.interface_line_attribute3);
                  SELECT del.gross_weight,
                         del.net_weight,
                         del.global_attribute3,
                         del.global_attribute1,
                         del.global_attribute2,
                         del.global_attribute4,
                         del.global_attribute5,
                         del.global_attribute6,
                         del.global_attribute7,
                         del.global_attribute8,
                         del.global_attribute9
                  INTO   l_gross_weight,
                         l_net_weight,
                         l_volume_qty,
                         l_volume_type,
                         l_volume_number,
                         l_veh_plate_state_code,
                         l_veh_antt_inscr,
                         l_tow_veh_plate_num,
                         l_tow_veh_plate_state_code,
                         l_tow_veh_antt_inscr,
                         l_seal_number
                  FROM   wsh_new_deliveries del
                  WHERE  del.name =
                                 p_interface_line_rec.interface_line_attribute3;

                EXCEPTION
                  WHEN OTHERS THEN
                       l_gross_weight := NULL;
                       l_net_weight := NULL;
                       l_volume_qty := NULL;
                       l_volume_type := NULL;
                       l_volume_number := NULL;
                       l_veh_plate_state_code := NULL;
                       l_veh_antt_inscr := NULL;
                       l_tow_veh_plate_num := NULL;
                       l_tow_veh_plate_state_code := NULL;
                       l_tow_veh_antt_inscr := NULL;
                       l_seal_number := NULL;
                END;

                BEGIN
                  SELECT t.vehicle_number
                  INTO   l_vehicle_number
                  FROM   wsh_new_deliveries del,
                         wsh_delivery_legs dl,
                         wsh_trip_stops pickup_stop,
                         wsh_trips t
                  WHERE  del.name =
                                 p_interface_line_rec.interface_line_attribute3
                  AND    del.delivery_id = dl.delivery_id
                  AND    dl.pick_up_stop_id = pickup_stop.stop_id
                  AND    pickup_stop.trip_id = t.trip_id
                  AND    pickup_stop.actual_departure_date =
                               (SELECT min(pickup_stop_x.actual_departure_date)
                                FROM  wsh_new_deliveries del_x,
                                      wsh_delivery_legs dl_x,
                                      wsh_trip_stops pickup_stop_x,
                                      wsh_trips tx
                                WHERE del_x.delivery_id = del.delivery_id
                                AND   del_x.delivery_id = dl_x.delivery_id
                                AND   dl_x.pick_up_stop_id =
                                                           pickup_stop_x.stop_id
                                AND   pickup_stop_x.trip_id = tx.trip_id
                                );
                EXCEPTION
                  WHEN OTHERS THEN
                       l_vehicle_number := NULL;
                END;

             END IF;

             x_interface_line_rec.header_gdf_attribute9 :=
                                          read_gdffs_rec.freight_acc_expense;
       	     x_interface_line_rec.header_gdf_attribute10 :=
                                          read_gdffs_rec.insurance_acc_expense;
       	     x_interface_line_rec.header_gdf_attribute11 :=
                                          read_gdffs_rec.other_acc_expense;
       	     x_interface_line_rec.header_gdf_attribute12 := l_vehicle_number;
       	     x_interface_line_rec.header_gdf_attribute13 := l_volume_qty;
       	     x_interface_line_rec.header_gdf_attribute14 := l_volume_type;
       	     x_interface_line_rec.header_gdf_attribute15 := l_volume_number;
       	     x_interface_line_rec.header_gdf_attribute16 := fnd_number.number_to_canonical(l_gross_weight);
       	     x_interface_line_rec.header_gdf_attribute17 := fnd_number.number_to_canonical(l_net_weight);
             x_interface_line_rec.header_gdf_attribute21 := l_veh_plate_state_code;
             x_interface_line_rec.header_gdf_attribute22 := l_veh_antt_inscr;
             x_interface_line_rec.header_gdf_attribute23 := l_tow_veh_plate_num;
             x_interface_line_rec.header_gdf_attribute24 := l_tow_veh_plate_state_code;
             x_interface_line_rec.header_gdf_attribute25 := l_tow_veh_antt_inscr;
             x_interface_line_rec.header_gdf_attribute26 := l_seal_number;

             x_interface_line_rec.header_gdf_attr_category :=
                                          l_header_attr_category;
       	     x_interface_line_rec.line_gdf_attribute1 :=
                                          read_gdffs_rec.op_fiscal_code;
       	     x_interface_line_rec.line_gdf_attribute4 :=
                                          read_gdffs_rec.item_origin;
       	     x_interface_line_rec.line_gdf_attribute5 :=
                                          read_gdffs_rec.item_fiscal_type;
       	     x_interface_line_rec.line_gdf_attribute6 :=
                                          read_gdffs_rec.fed_trib_situation;
       	     x_interface_line_rec.line_gdf_attribute7 :=
                                          read_gdffs_rec.sta_trib_situation;

       	     x_interface_line_rec.line_gdf_attribute2 := l_fsc_cls_code;
       	     x_interface_line_rec.line_gdf_attribute3 := l_trx_cls_code;
             x_interface_line_rec.line_gdf_attr_category :=
                                          l_line_attr_category;

           END LOOP;

        ELSE -- Country code is AR or CO

           IF l_tax_method = 'LTE' THEN
              l_fsc_cls_code := NULL;
              l_trx_cls_code := NULL;
              BEGIN
                select global_attribute5,
                       global_attribute6
                into   l_fsc_cls_code,
                       l_trx_cls_code
                from   oe_order_lines
                where  line_id = l_line_id;
              EXCEPTION
                WHEN OTHERS THEN
                     l_fsc_cls_code := NULL;
                     l_trx_cls_code := NULL;
              END;
           END IF;

           IF p_interface_line_rec.line_type = 'LINE' THEN
              x_interface_line_rec.line_gdf_attribute2 := l_fsc_cls_code;
              x_interface_line_rec.line_gdf_attribute3 := l_trx_cls_code;

              x_interface_line_rec.line_gdf_attr_category :=
                                          l_line_attr_category;
           END IF;

        END IF;

     ELSE -- l_invoice_line_id or l_order_line_id is not null

        IF l_tax_method = 'LTE' THEN

           l_fsc_cls_code := NULL;
           l_trx_cls_code := NULL;
           IF l_invoice_line_id IS NOT NULL THEN

              -- RMA source is invoice

              BEGIN
                SELECT global_attribute2,
                       global_attribute3
                INTO   l_fsc_cls_code,
                       l_trx_cls_code
                FROM   ra_customer_trx_lines
                WHERE  customer_trx_line_id = l_invoice_line_id;
              EXCEPTION
                WHEN OTHERS THEN
                     l_fsc_cls_code := NULL;
                     l_trx_cls_code := NULL;
                     l_line_attr_category := NULL;
              END;
           ELSIF l_order_line_id IS NOT NULL THEN

              -- RMA source is Sales Order
              BEGIN
                select global_attribute5,
                       global_attribute6
                into   l_fsc_cls_code,
                       l_trx_cls_code
                from   oe_order_lines
                where  line_id = l_order_line_id;
              EXCEPTION
                WHEN OTHERS THEN
                     l_fsc_cls_code := NULL;
                     l_trx_cls_code := NULL;
                     l_line_attr_category := NULL;
              END;

           END IF;

           IF p_interface_line_rec.line_type = 'LINE' THEN
              x_interface_line_rec.line_gdf_attribute2 := l_fsc_cls_code;
              x_interface_line_rec.line_gdf_attribute3 := l_trx_cls_code;

              x_interface_line_rec.line_gdf_attr_category :=
                                                           l_line_attr_category;
           END IF;

        END IF; -- Tax method check

        IF l_country_code = 'BR' THEN

           IF l_invoice_line_id IS NOT NULL THEN
             BEGIN
               SELECT il.global_attribute1   op_fiscal_code,
                      il.global_attribute4   item_origin,
                      il.global_attribute5   item_fiscal_type,
                      il.global_attribute6   fed_trib_situation,
                      il.global_attribute7   sta_trib_situation
               INTO   l_op_fiscal_code,
                      l_item_origin,
                      l_item_fiscal_type,
                      l_fed_trib_situation,
                      l_sta_trib_situation
               FROM   ra_customer_trx_lines il
               WHERE  il.customer_trx_line_id = l_invoice_line_id;

             EXCEPTION WHEN OTHERS THEN
               l_op_fiscal_code := null;
               l_item_origin := null;
               l_item_fiscal_type := null;
               l_fed_trib_situation := null;
               l_sta_trib_situation := null;

             END;

           ELSIF l_order_line_id IS NOT NULL THEN

             l_so_organization_id :=
                to_number(oe_profile.value('SO_ORGANIZATION_ID'));

             BEGIN
               SELECT ol.global_attribute1    op_fiscal_code,
                      msi.global_attribute3   item_origin,
                      msi.global_attribute4   item_fiscal_type,
                      msi.global_attribute5   fed_trib_situation,
                      msi.global_attribute6   sta_trib_situation
               INTO   l_op_fiscal_code,
                      l_item_origin,
                      l_item_fiscal_type,
                      l_fed_trib_situation,
                      l_sta_trib_situation
               FROM   oe_order_lines ol, mtl_system_items msi
               WHERE  ol.line_id = l_order_line_id
               AND    msi.inventory_item_id(+) =
                        p_interface_line_rec.inventory_item_id
               AND    msi.organization_id = l_so_organization_id;

             EXCEPTION WHEN OTHERS THEN
               l_op_fiscal_code := null;
               l_item_origin := null;
               l_item_fiscal_type := null;
               l_fed_trib_situation := null;
               l_sta_trib_situation := null;

             END;

           END IF;

       	   x_interface_line_rec.line_gdf_attribute1 := l_op_fiscal_code;
       	   x_interface_line_rec.line_gdf_attribute4 := l_item_origin;
       	   x_interface_line_rec.line_gdf_attribute5 := l_item_fiscal_type;
       	   x_interface_line_rec.line_gdf_attribute6 := l_fed_trib_situation;
       	   x_interface_line_rec.line_gdf_attribute7 := l_sta_trib_situation;

           x_interface_line_rec.line_gdf_attr_category := l_line_attr_category;

        END IF; -- Country code BR for RMA

     END IF; -- l_invoice_line_id or l_order_line_id check

  END IF;  -- Country Code check

EXCEPTION
  WHEN OTHERS THEN
       OE_DEBUG_PUB.ADD('JL-Exception Others');
       x_error_buffer := SQLERRM;
       x_return_code := 2;

END copy_gdff;

PROCEDURE copy_gdf (
        x_interface_line_rec IN OUT NOCOPY OE_Invoice_PUB.OE_GDF_Rec_Type,
        x_return_code        IN OUT NOCOPY NUMBER,
	x_error_buffer       IN OUT NOCOPY VARCHAR2) IS

  l_so_organization_id 	 NUMBER(15);
  l_country_code 	 VARCHAR2(2);
  l_tax_method           VARCHAR2(30);

  l_header_attr_category VARCHAR2(30);
  l_line_attr_category   VARCHAR2(30);

  l_volume_qty            VARCHAR2(150);
  l_volume_type           VARCHAR2(150);
  l_volume_number         VARCHAR2(150);
  l_vehicle_number        VARCHAR2(150);
  l_gross_weight          NUMBER;
  l_net_weight            NUMBER;
  l_item_origin           VARCHAR2(150);
  l_item_fiscal_type      VARCHAR2(150);
  l_fsc_cls_code          VARCHAR2(30);
  l_trx_cls_code          VARCHAR2(30);
  l_inventory_item_id     NUMBER;
  l_line_id               NUMBER;
  l_order_line_id         NUMBER;
  l_invoice_line_id       NUMBER;
  l_op_fiscal_code        VARCHAR2(5);
  l_fed_trib_situation    VARCHAR2(25);
  l_sta_trib_situation    VARCHAR2(25);

  l_org_id                NUMBER;
  l_jl                    VARCHAR2(2);

  /* Added for Brazilian SPED */
  l_veh_plate_state_code VARCHAR2(5);
  l_veh_antt_inscr       VARCHAR2(50);
  l_tow_veh_plate_num    VARCHAR2(50);
  l_tow_veh_plate_state_code VARCHAR2(5);
  l_tow_veh_antt_inscr   VARCHAR2(50);
  l_seal_number          VARCHAR2(150);
  /*End*/


  CURSOR read_gdffs IS
    SELECT ol.global_attribute1    op_fiscal_code,
           ol.global_attribute2    freight_acc_expense,
           ol.global_attribute3    insurance_acc_expense,
           ol.global_attribute4    other_acc_expense,
           ol.global_attribute5    item_line_fiscal_class,
           ol.global_attribute6    item_line_trx_reason,
           msi.global_attribute3   item_origin,
           msi.global_attribute4   item_fiscal_type,
           msi.global_attribute5   fed_trib_situation,
           msi.global_attribute6   sta_trib_situation
    FROM   oe_order_lines ol,
           mtl_system_items msi
    WHERE  line_id = l_line_id
    AND    msi.inventory_item_id(+) = l_inventory_item_id
    AND    msi.organization_id      = l_so_organization_id;

  read_gdffs_rec  read_gdffs%ROWTYPE;

BEGIN

  x_return_code := 0;
  x_error_buffer := NULL;
-- Following line is commented for performance changes bug 1922093.
--  x_interface_line_rec := p_interface_line_rec;

  --Following line is commented as a part of bug 2133665
  --l_country_code := fnd_profile.value('JGZZ_COUNTRY_CODE');
  --
  l_country_code := SUBSTR(x_interface_line_rec.line_gdf_attr_category,4,2);

  l_jl := 'JL';
  --
  OE_DEBUG_PUB.ADD('JL-Country Code is ' || l_country_code);

  IF NVL(l_country_code,'$') IN ('BR','AR','CO') THEN

     l_org_id := mo_global.get_current_org_id;
     l_tax_method := JL_ZZ_AR_TX_LIB_PKG.get_tax_method(l_org_id);
     OE_DEBUG_PUB.ADD('JL-Tax Method is ' || l_tax_method);

     l_so_organization_id:= to_number(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',l_org_id));
     OE_DEBUG_PUB.ADD('JL-So Organization id is ' || l_so_organization_id);

     IF l_country_code = 'BR' THEN
        l_header_attr_category :=  'JL.BR.ARXTWMAI.Additional Info';
        l_line_attr_category   :=  'JL.BR.ARXTWMAI.Additional Info';
     ELSE
       -- l_header_attr_category :=  'JL'||'.'||l_country_code||'.ARXTWMAI.HEADER';
       -- l_line_attr_category   := 'JL'||'.'||l_country_code||'.ARXTWMAI.LINES';
        l_header_attr_category :=  l_jl||'.'||l_country_code||'.ARXTWMAI.HEADER';
        l_line_attr_category   := l_jl||'.'||l_country_code||'.ARXTWMAI.LINES';
     END IF;

     l_line_id := x_interface_line_rec.interface_line_attribute6;
     l_inventory_item_id := x_interface_line_rec.inventory_item_id;

     OE_DEBUG_PUB.ADD('JL-Line Id '|| l_line_id);
     OE_DEBUG_PUB.ADD('JL-Inventory Item Id '|| l_inventory_item_id);
     OE_DEBUG_PUB.ADD('JL-Line Type '|| x_interface_line_rec.line_type);

     l_invoice_line_id := NULL;
     l_order_line_id := NULL;
     IF l_tax_method = 'LTE' THEN

       --
       -- Bug#5588076- init GDF for LTE
       --
       init_gdf(x_interface_line_rec);

       BEGIN
         SELECT REFERENCE_CUSTOMER_TRX_LINE_ID,
                REFERENCE_LINE_ID
         INTO   l_invoice_line_id,
                l_order_line_id
         FROM   oe_order_lines
         WHERE  line_id = l_line_id;
       EXCEPTION
         WHEN OTHERS THEN
              l_invoice_line_id := NULL;
              l_order_line_id := NULL;
       END;

     END IF;

     OE_DEBUG_PUB.ADD('JL-Invoice Line Id '|| l_invoice_line_id);
     OE_DEBUG_PUB.ADD('JL-Return Id '|| l_order_line_id);

     IF (l_invoice_line_id IS NULL AND
         l_order_line_id IS NULL) THEN

        /* Copy Global DFF columns from OE tables */
        IF l_country_code = 'BR' THEN

           OPEN read_gdffs;
           LOOP

             FETCH read_gdffs INTO read_gdffs_rec;

             EXIT WHEN read_gdffs%NOTFOUND OR
                       read_gdffs%NOTFOUND is NULL;

             IF l_tax_method = 'LTE' THEN
                l_fsc_cls_code := read_gdffs_rec.item_line_fiscal_class;
                l_trx_cls_code := read_gdffs_rec.item_line_trx_reason;
             ELSE
                l_fsc_cls_code := NULL;
                l_trx_cls_code := NULL;
             END IF;

             IF x_interface_line_rec.line_type = 'LINE' THEN

                BEGIN
                  OE_DEBUG_PUB.ADD('JL-Delivery Name '||
                                x_interface_line_rec.interface_line_attribute3);
                  SELECT del.gross_weight,
                         del.net_weight,
                         del.global_attribute3,
                         del.global_attribute1,
                         del.global_attribute2,
                         del.global_attribute4,
                         del.global_attribute5,
                         del.global_attribute6,
                         del.global_attribute7,
                         del.global_attribute8,
                         del.global_attribute9
                  INTO   l_gross_weight,
                         l_net_weight,
                         l_volume_qty,
                         l_volume_type,
                         l_volume_number,
                         l_veh_plate_state_code,
                         l_veh_antt_inscr,
                         l_tow_veh_plate_num,
                         l_tow_veh_plate_state_code,
                         l_tow_veh_antt_inscr,
                         l_seal_number
                  FROM   wsh_new_deliveries del
                  WHERE  del.name =
                                 x_interface_line_rec.interface_line_attribute3;

                EXCEPTION
                  WHEN OTHERS THEN
                       l_gross_weight := NULL;
                       l_net_weight := NULL;
                       l_volume_qty := NULL;
                       l_volume_type := NULL;
                       l_volume_number := NULL;
                       l_veh_plate_state_code := NULL;
                       l_veh_antt_inscr := NULL;
                       l_tow_veh_plate_num := NULL;
                       l_tow_veh_plate_state_code := NULL;
                       l_tow_veh_antt_inscr := NULL;
                       l_seal_number := NULL;
                END;

                BEGIN
                  SELECT t.vehicle_number
                  INTO   l_vehicle_number
                  FROM   wsh_new_deliveries del,
                         wsh_delivery_legs dl,
                         wsh_trip_stops pickup_stop,
                         wsh_trips t
                  WHERE  del.name =
                                 x_interface_line_rec.interface_line_attribute3
                  AND    del.delivery_id = dl.delivery_id
                  AND    dl.pick_up_stop_id = pickup_stop.stop_id
                  AND    pickup_stop.trip_id = t.trip_id
                  AND    pickup_stop.actual_departure_date =
                               (SELECT min(pickup_stop_x.actual_departure_date)
                                FROM  wsh_new_deliveries del_x,
                                      wsh_delivery_legs dl_x,
                                      wsh_trip_stops pickup_stop_x,
                                      wsh_trips tx
                                WHERE del_x.delivery_id = del.delivery_id
                                AND   del_x.delivery_id = dl_x.delivery_id
                                AND   dl_x.pick_up_stop_id =
                                                           pickup_stop_x.stop_id
                                AND   pickup_stop_x.trip_id = tx.trip_id
                                );
                EXCEPTION
                  WHEN OTHERS THEN
                       l_vehicle_number := NULL;
                END;

             END IF;

             x_interface_line_rec.header_gdf_attribute9 :=
                                          read_gdffs_rec.freight_acc_expense;
       	     x_interface_line_rec.header_gdf_attribute10 :=
                                          read_gdffs_rec.insurance_acc_expense;
       	     x_interface_line_rec.header_gdf_attribute11 :=
                                          read_gdffs_rec.other_acc_expense;
       	     x_interface_line_rec.header_gdf_attribute12 := l_vehicle_number;
       	     x_interface_line_rec.header_gdf_attribute13 := l_volume_qty;
       	     x_interface_line_rec.header_gdf_attribute14 := l_volume_type;
       	     x_interface_line_rec.header_gdf_attribute15 := l_volume_number;
       	     x_interface_line_rec.header_gdf_attribute16 := fnd_number.number_to_canonical(l_gross_weight);
       	     x_interface_line_rec.header_gdf_attribute17 := fnd_number.number_to_canonical(l_net_weight);
             x_interface_line_rec.header_gdf_attribute21 := l_veh_plate_state_code;
             x_interface_line_rec.header_gdf_attribute22 := l_veh_antt_inscr;
             x_interface_line_rec.header_gdf_attribute23 := l_tow_veh_plate_num;
             x_interface_line_rec.header_gdf_attribute24 := l_tow_veh_plate_state_code;
             x_interface_line_rec.header_gdf_attribute25 := l_tow_veh_antt_inscr;
             x_interface_line_rec.header_gdf_attribute26 := l_seal_number;
             x_interface_line_rec.header_gdf_attr_category :=
                                          l_header_attr_category;

             x_interface_line_rec.line_gdf_attribute1 :=
                                          read_gdffs_rec.op_fiscal_code;
       	     x_interface_line_rec.line_gdf_attribute4 :=
                                          read_gdffs_rec.item_origin;
       	     x_interface_line_rec.line_gdf_attribute5 :=
                                          read_gdffs_rec.item_fiscal_type;
       	     x_interface_line_rec.line_gdf_attribute6 :=
                                          read_gdffs_rec.fed_trib_situation;
       	     x_interface_line_rec.line_gdf_attribute7 :=
                                          read_gdffs_rec.sta_trib_situation;

       	     x_interface_line_rec.line_gdf_attribute2 := l_fsc_cls_code;
       	     x_interface_line_rec.line_gdf_attribute3 := l_trx_cls_code;

             x_interface_line_rec.line_gdf_attr_category :=
                                          l_line_attr_category;

           END LOOP;

        ELSE -- Country code is AR or CO

           IF l_tax_method = 'LTE' THEN
              l_fsc_cls_code := NULL;
              l_trx_cls_code := NULL;
              BEGIN
                select global_attribute5,
                       global_attribute6
                into   l_fsc_cls_code,
                       l_trx_cls_code
                from   oe_order_lines
                where  line_id = l_line_id;
              EXCEPTION
                WHEN OTHERS THEN
                     l_fsc_cls_code := NULL;
                     l_trx_cls_code := NULL;
              END;
           END IF;

           IF x_interface_line_rec.line_type = 'LINE' THEN
              x_interface_line_rec.line_gdf_attribute2 := l_fsc_cls_code;
              x_interface_line_rec.line_gdf_attribute3 := l_trx_cls_code;

              x_interface_line_rec.line_gdf_attr_category :=
                                          l_line_attr_category;
           END IF;

        END IF;

     ELSE -- l_invoice_line_id or l_order_line_id is not null

        IF l_tax_method = 'LTE' THEN

           l_fsc_cls_code := NULL;
           l_trx_cls_code := NULL;
           IF l_invoice_line_id IS NOT NULL THEN

              -- RMA source is invoice

              BEGIN
                SELECT global_attribute2,
                       global_attribute3
                INTO   l_fsc_cls_code,
                       l_trx_cls_code
                FROM   ra_customer_trx_lines
                WHERE  customer_trx_line_id = l_invoice_line_id;
              EXCEPTION
                WHEN OTHERS THEN
                     l_fsc_cls_code := NULL;
                     l_trx_cls_code := NULL;
                     l_line_attr_category := NULL;
              END;
           ELSIF l_order_line_id IS NOT NULL THEN

              -- RMA source is Sales Order
              BEGIN
                select global_attribute5,
                       global_attribute6
                into   l_fsc_cls_code,
                       l_trx_cls_code
                from   oe_order_lines
                where  line_id = l_order_line_id;
              EXCEPTION
                WHEN OTHERS THEN
                     l_fsc_cls_code := NULL;
                     l_trx_cls_code := NULL;
                     l_line_attr_category := NULL;
              END;

           END IF;

           IF x_interface_line_rec.line_type = 'LINE' THEN
              x_interface_line_rec.line_gdf_attribute2 := l_fsc_cls_code;
              x_interface_line_rec.line_gdf_attribute3 := l_trx_cls_code;

              x_interface_line_rec.line_gdf_attr_category :=
                                                           l_line_attr_category;
           END IF;

        END IF; -- Tax method check

        IF l_country_code = 'BR' THEN

           IF l_invoice_line_id IS NOT NULL THEN
             BEGIN
               SELECT il.global_attribute1   op_fiscal_code,
                      il.global_attribute4   item_origin,
                      il.global_attribute5   item_fiscal_type,
                      il.global_attribute6   fed_trib_situation,
                      il.global_attribute7   sta_trib_situation
               INTO   l_op_fiscal_code,
                      l_item_origin,
                      l_item_fiscal_type,
                      l_fed_trib_situation,
                      l_sta_trib_situation
               FROM   ra_customer_trx_lines il
               WHERE  il.customer_trx_line_id = l_invoice_line_id;

             EXCEPTION WHEN OTHERS THEN
               l_op_fiscal_code := null;
               l_item_origin := null;
               l_item_fiscal_type := null;
               l_fed_trib_situation := null;
               l_sta_trib_situation := null;

             END;

           ELSIF l_order_line_id IS NOT NULL THEN

             l_so_organization_id :=
                to_number(oe_profile.value('SO_ORGANIZATION_ID'));

             BEGIN
               SELECT ol.global_attribute1    op_fiscal_code,
                      msi.global_attribute3   item_origin,
                      msi.global_attribute4   item_fiscal_type,
                      msi.global_attribute5   fed_trib_situation,
                      msi.global_attribute6   sta_trib_situation
               INTO   l_op_fiscal_code,
                      l_item_origin,
                      l_item_fiscal_type,
                      l_fed_trib_situation,
                      l_sta_trib_situation
               FROM   oe_order_lines ol, mtl_system_items msi
               WHERE  ol.line_id = l_order_line_id
               AND    msi.inventory_item_id(+) =
                        x_interface_line_rec.inventory_item_id
               AND    msi.organization_id = l_so_organization_id;

             EXCEPTION WHEN OTHERS THEN
               l_op_fiscal_code := null;
               l_item_origin := null;
               l_item_fiscal_type := null;
               l_fed_trib_situation := null;
               l_sta_trib_situation := null;

             END;

           END IF;

       	   x_interface_line_rec.line_gdf_attribute1 := l_op_fiscal_code;
       	   x_interface_line_rec.line_gdf_attribute4 := l_item_origin;
       	   x_interface_line_rec.line_gdf_attribute5 := l_item_fiscal_type;
       	   x_interface_line_rec.line_gdf_attribute6 := l_fed_trib_situation;
       	   x_interface_line_rec.line_gdf_attribute7 := l_sta_trib_situation;

           x_interface_line_rec.line_gdf_attr_category := l_line_attr_category;

        END IF; -- Country code BR for RMA

     END IF; -- l_invoice_line_id or l_order_line_id check

  END IF;  -- Country Code check

EXCEPTION
  WHEN OTHERS THEN
       OE_DEBUG_PUB.ADD('JL-Exception Others');
       x_error_buffer := SQLERRM;
       x_return_code := 2;

END copy_gdf;

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    default_gdff                           			      	      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    When the item is entered on Sales Order Line, if inventory item id is   |
 |    not null then this procedure will default global descriptive flexfield  |
 |    values if they are null                                                 |
 |									      |
 | PARAMETERS                                                                 |
 |   INPUT                                                 		      |
 |      p_line_rec              oe_order_pub.line_rec_type Interface line     |
 |                              record declared in OEXPOROS.pls               |
 |   OUTPUT                                                		      |
 |      x_line_rec              oe_order_pub.line_rec_type Interface line     |
 |                              record declared in OEXPOROS.pls               |
 |      x_error_buffer          VARCHAR2 -- Error Message  	              |
 |      x_return_code         	NUMBER   -- Error Code.           	      |
 |                                          0 - Success, 2 - Failure. 	      |
 |                                                                            |
 | HISTORY                                                                    |
 |                                                                            |
 |    24-JAN-2000 Harsh Takle      Created.                                   |
 *----------------------------------------------------------------------------*/
PROCEDURE default_gdff
     (p_line_rec     IN     oe_order_pub.line_rec_type,
      x_line_rec        OUT NOCOPY oe_order_pub.line_rec_type,
      x_return_code  IN OUT NOCOPY NUMBER,
      x_error_buffer IN OUT NOCOPY VARCHAR2,
      p_org_id       IN     NUMBER DEFAULT mo_global.get_current_org_id
     ) IS


  l_so_organization_id 	 NUMBER(15);
  l_inventory_org_id     NUMBER(15);

  l_country_code 	 VARCHAR2(2);
  l_tax_method           VARCHAR2(30);

  l_fcc_code      varchar2(30);
  l_tran_nat      varchar2(30);
  l_gdf_cat       VARCHAR2(30);

  l_org_id        NUMBER;
  l_jl            VARCHAR2(2);

BEGIN
  l_fcc_code := NULL;
  l_tran_nat := NULL;

  x_line_rec := p_line_rec;
  x_return_code := 0;
  x_error_buffer := NULL;

  --Bug fix 2367111
  --l_country_code := fnd_profile.value('JGZZ_COUNTRY_CODE');
  --l_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY(p_org_id, null);

  -- Bug#5090423
  l_org_id := p_line_rec.org_id;
  l_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY(l_org_id, null);

  l_jl := 'JL';

  IF NVL(l_country_code,'$') IN ('BR','AR','CO') THEN

     --l_gdf_cat := 'JL'||'.'||l_country_code||'.OEXOEORD.LINES';
     l_gdf_cat := l_jl||'.'||l_country_code||'.OEXOEORD.LINES';

     l_tax_method := JL_ZZ_AR_TX_LIB_PKG.get_tax_method(l_org_id);

     l_so_organization_id:= to_number(oe_profile.value('SO_ORGANIZATION_ID'));

     --
     -- Bug#4929759- use ship_from_org_id for Colombia
     -- replace WHERE  mtl.organization_id = l_so_organization_id
     -- with WHERE  mtl.organization_id = l_inventory_org_id
     --
     IF l_country_code = 'CO' THEN
       l_inventory_org_id := NVL(p_line_rec.ship_from_org_id,
                                 l_so_organization_id);
     ELSE
       -- AR, BR
       l_inventory_org_id := l_so_organization_id;
     END IF;

     IF p_line_rec.inventory_item_id IS NOT NULL THEN

       -- Bug#5090423: remove get fsc here

       BEGIN
         SELECT substr(mtl.global_attribute2,1,30)
         INTO   l_tran_nat
         FROM   mtl_system_items mtl
         WHERE  mtl.organization_id = l_inventory_org_id
         AND    mtl.inventory_item_id = p_line_rec.inventory_item_id;
       EXCEPTION
         WHEN OTHERS THEN
              OE_DEBUG_PUB.ADD('EXCEPTION: No Value for Transaction Nature');
              l_tran_nat := NULL;
       END;

       --Bug#6019028: No transaction class for CO as org id is picked from ship_from_org_id

       IF l_tran_nat IS NULL AND l_country_code = 'CO' THEN

         BEGIN
           SELECT substr(mtl.global_attribute2,1,30)
           INTO   l_tran_nat
           FROM   mtl_system_items mtl
           WHERE  mtl.organization_id = l_so_organization_id
           AND    mtl.inventory_item_id = p_line_rec.inventory_item_id;
         EXCEPTION
           WHEN OTHERS THEN
              OE_DEBUG_PUB.ADD('EXCEPTION: No Value for Transaction Nature');
              l_tran_nat := NULL;
         END;
       END IF;

       -- Bug#5090423
       -- get default fiscal classification
       BEGIN
         SELECT fc.classification_code
          INTO l_fcc_code
          FROM zx_fc_product_fiscal_v   fc,
               mtl_item_categories      mic
          WHERE
              ((fc.country_code    = l_country_code
                 AND fc.country_code in ('AR', 'BR', 'CO'))
                or
                fc.country_code is NULL
               )
          AND mic.inventory_item_id = p_line_rec.inventory_item_id
          AND mic.organization_id   = l_inventory_org_id
          AND mic.category_id       = fc.category_id
          AND mic.category_set_id   = fc.category_set_id
       -- AND fc.structure_name     = 'Fiscal Classification'  -- Commented for Bug#7125709
          AND fc.structure_code     = 'FISCAL_CLASSIFICATION'  -- Added as a fix for Bug#7125709
          AND EXISTS
                 (SELECT 1
                   FROM  JL_ZZ_AR_TX_FSC_CLS_ALL
                   WHERE fiscal_classification_code = fc.classification_code
                     AND org_id = l_org_id
                     AND enabled_flag = 'Y')
	  AND ROWNUM =1;
         EXCEPTION
           WHEN OTHERS THEN
                OE_DEBUG_PUB.ADD('EXCEPTION: No Value for Fiscal Classification');
                l_fcc_code := NULL;

       END;

       --Bug#6019028: No fiscal classification for CO as org id is picked from ship_from_org_id

       IF l_fcc_code IS NULL AND l_country_code = 'CO' THEN

        BEGIN
         SELECT fc.classification_code
          INTO l_fcc_code
          FROM zx_fc_product_fiscal_v   fc,
               mtl_item_categories      mic
          WHERE
              ((fc.country_code    = l_country_code
                 AND fc.country_code in ('AR', 'BR', 'CO'))
                or
                fc.country_code is NULL
               )
          AND mic.inventory_item_id = p_line_rec.inventory_item_id
          AND mic.organization_id   = l_so_organization_id
          AND mic.category_id       = fc.category_id
          AND mic.category_set_id   = fc.category_set_id
       -- AND fc.structure_name     = 'Fiscal Classification'  -- Commented for Bug#7125709
          AND fc.structure_code     = 'FISCAL_CLASSIFICATION'  -- Added as a fix for Bug#7125709
          AND EXISTS
                 (SELECT 1
                   FROM  JL_ZZ_AR_TX_FSC_CLS_ALL
                   WHERE fiscal_classification_code = fc.classification_code
                     AND org_id = l_org_id
                     AND enabled_flag = 'Y')
	  AND ROWNUM =1;
        EXCEPTION
           WHEN OTHERS THEN
              OE_DEBUG_PUB.ADD('EXCEPTION: No Value for Fiscal Classification');
                l_fcc_code := NULL;
        END;
       END IF;

     END IF;

     OE_DEBUG_PUB.ADD('Org ID: '|| to_char(l_org_id));
     OE_DEBUG_PUB.ADD('Tax Method: '||l_tax_method);
     OE_DEBUG_PUB.ADD('Inventory Item Id : '|| to_char(p_line_rec.inventory_item_id));
     OE_DEBUG_PUB.ADD('Ship From Inventory Org : '||
                       to_char(p_line_rec.ship_from_org_id));

     IF l_tax_method = 'LTE' THEN
        OE_DEBUG_PUB.ADD('Before Defaulting');
        OE_DEBUG_PUB.ADD('-----------------');
        OE_DEBUG_PUB.ADD('GA5: '|| x_line_rec.global_attribute5);
        OE_DEBUG_PUB.ADD('GA6: '|| x_line_rec.global_attribute6);
        OE_DEBUG_PUB.ADD('GA7: '|| x_line_rec.global_attribute7);
        OE_DEBUG_PUB.ADD('GA8: '|| x_line_rec.global_attribute8);

        x_line_rec.global_attribute7 :=
                                   nvl(x_line_rec.global_attribute7,l_fcc_code);
        x_line_rec.global_attribute8 :=
                                   nvl(x_line_rec.global_attribute8,l_tran_nat);
        x_line_rec.global_attribute5 :=
                                   nvl(x_line_rec.global_attribute5,l_fcc_code);
        x_line_rec.global_attribute6 :=
                                   nvl(x_line_rec.global_attribute6,l_tran_nat);
        x_line_rec.global_attribute_category :=
                                   nvl(x_line_rec.global_attribute_category,l_gdf_cat);

        OE_DEBUG_PUB.ADD('After Defaulting');
        OE_DEBUG_PUB.ADD('----------------');
        OE_DEBUG_PUB.ADD('Default from Inventory Org' ||
                          to_char(l_inventory_org_id));
        OE_DEBUG_PUB.ADD('GA5: '|| x_line_rec.global_attribute5);
        OE_DEBUG_PUB.ADD('GA6: '|| x_line_rec.global_attribute6);
        OE_DEBUG_PUB.ADD('GA7: '|| x_line_rec.global_attribute7);
        OE_DEBUG_PUB.ADD('GA8: '|| x_line_rec.global_attribute8);
     END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
       x_error_buffer := SQLERRM;
       x_return_code := 2;

END default_gdff;

PROCEDURE default_gdf
     (x_line_rec     IN OUT NOCOPY OE_ORDER_PUB.LINE_REC_TYPE,
      x_return_code  IN OUT NOCOPY NUMBER,
      x_error_buffer IN OUT NOCOPY VARCHAR2,
      p_org_id       IN NUMBER DEFAULT mo_global.get_current_org_id
     ) IS


  l_so_organization_id   NUMBER(15);
  l_inventory_org_id     NUMBER(15);

  l_order_type_id        NUMBER(15);
  l_def_value            VARCHAR2(50);
  errcode1               NUMBER(15);
  l_country_code         VARCHAR2(2);
  l_tax_method           VARCHAR2(30);

  l_fcc_code             VARCHAR2(30);
  l_tran_nat             VARCHAR2(30);
  l_gdf_cat              VARCHAR2(30);
  l_item_orig            VARCHAR2(30);
  l_fed_trib             VARCHAR2(30);
  l_sta_trib             VARCHAR2(30);

  l_org_id               NUMBER;
  l_jl                   VARCHAR2(2);

  -- bug#7827647
  CURSOR c_get_gdf_br
  (c_inventory_org_id      MTL_SYSTEM_ITEMS.organization_id%TYPE,
   c_inventory_item_id     MTL_SYSTEM_ITEMS.inventory_item_id%TYPE
  )
  IS
    SELECT   substr(mtl.global_attribute2,1,30),
             substr(mtl.global_attribute3,1,30),
             substr(mtl.global_attribute5,1,30),
             substr(mtl.global_attribute6,1,30)
      FROM   mtl_system_items mtl
      WHERE  mtl.organization_id = c_inventory_org_id
        AND  mtl.inventory_item_id = c_inventory_item_id;

   -- bug#7827647
   CURSOR c_get_fsc
   (c_country_code      ZX_FC_CODES_B.country_code%TYPE,
    c_inventory_item_id MTL_ITEM_CATEGORIES.inventory_item_id%TYPE,
    c_inventory_org_id  MTL_ITEM_CATEGORIES.organization_id%TYPE,
    c_org_id            JL_ZZ_AR_TX_FSC_CLS_ALL.org_id%TYPE
   )
   IS
     SELECT fc.classification_code
        FROM zx_fc_product_fiscal_v   fc,
             mtl_item_categories      mic
        WHERE
            ((fc.country_code    = c_country_code
               AND fc.country_code in ('AR', 'BR', 'CO'))
              or
              fc.country_code is NULL
             )
          AND mic.inventory_item_id = c_inventory_item_id
          AND mic.organization_id   = c_inventory_org_id
          AND mic.category_id       = fc.category_id
          AND mic.category_set_id   = fc.category_set_id
          AND fc.structure_code     = 'FISCAL_CLASSIFICATION'  -- Added as a fix for Bug#7125709
          AND rownum = 1
          AND EXISTS
                 (SELECT 1
                   FROM  JL_ZZ_AR_TX_FSC_CLS_ALL
                   WHERE fiscal_classification_code = fc.classification_code
                     AND org_id = c_org_id
                     AND enabled_flag = 'Y');



BEGIN
  l_fcc_code := NULL;
  l_tran_nat := NULL;
  l_item_orig := NULL;
  l_sta_trib := NULL;
  l_fed_trib := NULL;

  -- Following line commented for bug 1922093.
  --x_line_rec := p_line_rec;
  x_return_code := 0;
  x_error_buffer := NULL;

  --Bug fix 2367111 related to bug 2354736
  --l_country_code := fnd_profile.value('JGZZ_COUNTRY_CODE');
  --l_org_id := mo_global.get_current_org_id;

  l_org_id := x_line_rec.org_id;
  l_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY(l_org_id, null);

  l_jl := 'JL';

  IF NVL(l_country_code,'$') IN ('BR','AR','CO') THEN

     -- l_gdf_cat := 'JL'||'.'||l_country_code||'.OEXOEORD.LINES';
     l_gdf_cat := l_jl||'.'||l_country_code||'.OEXOEORD.LINES';

     l_tax_method := JL_ZZ_AR_TX_LIB_PKG.get_tax_method(l_org_id);

     l_so_organization_id:= to_number(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',l_org_id));

     --
     -- Bug#4929759- use ship_from_org_id for Colombia
     -- replace WHERE  mtl.organization_id = l_so_organization_id
     -- with WHERE  mtl.organization_id = l_inventory_org_id
     --
     IF l_country_code = 'CO' THEN
       l_inventory_org_id := NVL(x_line_rec.ship_from_org_id,
                                 l_so_organization_id);
     ELSE
       -- AR, BR
       l_inventory_org_id := l_so_organization_id;
     END IF;

     IF x_line_rec.inventory_item_id IS NOT NULL THEN

        IF l_country_code = 'BR'  THEN
            -- Forward port change. Refer bug 5224022

           /* bug#7827647- replace with code below
           BEGIN
             SELECT substr(mtl.global_attribute1,1,30),
                substr(mtl.global_attribute2,1,30),
                substr(mtl.global_attribute3,1,30),
                substr(mtl.global_attribute5,1,30),
                substr(mtl.global_attribute6,1,30)
             INTO   l_fcc_code,
                    l_tran_nat,
                    l_item_orig,
                    l_fed_trib,
                    l_sta_trib
             FROM   mtl_system_items mtl
             WHERE  mtl.organization_id = l_inventory_org_id
             AND    mtl.inventory_item_id = x_line_rec.inventory_item_id;
           EXCEPTION
             WHEN OTHERS THEN
                  OE_DEBUG_PUB.ADD('EXCEPTION: No Value for Global Attributes');
                  l_tran_nat := NULL;
          END;
          */

          l_tran_nat := NULL;
          -- bug#7827647: use inventory org first
          l_inventory_org_id := x_line_rec.ship_from_org_id;

          OPEN c_get_gdf_br ( l_inventory_org_id,
                              x_line_rec.inventory_item_id);
          FETCH c_get_gdf_br INTO
                    l_tran_nat,
                    l_item_orig,
                    l_fed_trib,
                    l_sta_trib;
          CLOSE c_get_gdf_br;

          IF l_tran_nat IS NULL THEN
            -- bug#7827647: gdf not defined at inventory org
            -- get them from master org
            --
            l_inventory_org_id := l_so_organization_id;

            OPEN c_get_gdf_br ( l_inventory_org_id,
                                x_line_rec.inventory_item_id);
            FETCH c_get_gdf_br INTO
                    l_tran_nat,
                    l_item_orig,
                    l_fed_trib,
                    l_sta_trib;
            CLOSE c_get_gdf_br;
          END IF;

        ELSE

	       -- Bug#5090423 : removed get fsc here

	       BEGIN
	         SELECT substr(mtl.global_attribute2,1,30)
	         INTO   l_tran_nat
	         FROM   mtl_system_items mtl
	         WHERE  mtl.organization_id   = l_inventory_org_id
	         AND    mtl.inventory_item_id = x_line_rec.inventory_item_id;
	       EXCEPTION
	         WHEN OTHERS THEN
	              OE_DEBUG_PUB.ADD('EXCEPTION: No Value for Global Attributes');
	              l_tran_nat := NULL;
	       END;
	END IF;
       --Bug#6019028: No transaction class for CO as org id is picked from ship_from_org_id

       IF l_tran_nat IS NULL AND l_country_code = 'CO' THEN

         BEGIN
           SELECT substr(mtl.global_attribute2,1,30)
           INTO   l_tran_nat
           FROM   mtl_system_items mtl
           WHERE  mtl.organization_id = l_so_organization_id
           AND    mtl.inventory_item_id = x_line_rec.inventory_item_id;
         EXCEPTION
           WHEN OTHERS THEN
              OE_DEBUG_PUB.ADD('EXCEPTION: No Value for Transaction Nature');
              l_tran_nat := NULL;
         END;
       END IF;

       -- Bug#5090423
       -- get default fiscal classification
       /* Bug#7827647- replace with code below
       BEGIN
         SELECT fc.classification_code
          INTO l_fcc_code
          FROM zx_fc_product_fiscal_v   fc,
               mtl_item_categories      mic
          WHERE
            ((fc.country_code    = l_country_code
               AND fc.country_code in ('AR', 'BR', 'CO'))
              or
              fc.country_code is NULL
             )
          AND mic.inventory_item_id = x_line_rec.inventory_item_id
          AND mic.organization_id   = x_line_rec.ship_from_org_id --l_inventory_org_id
          AND mic.category_id       = fc.category_id
          AND mic.category_set_id   = fc.category_set_id
       -- AND fc.structure_name     = 'Fiscal Classification'  -- Commented for Bug#7125709
          AND fc.structure_code     = 'FISCAL_CLASSIFICATION'  -- Added as a fix for Bug#7125709
	  AND rownum = 1
          AND EXISTS
                 (SELECT 1
                   FROM  JL_ZZ_AR_TX_FSC_CLS_ALL
                   WHERE fiscal_classification_code = fc.classification_code
                     AND org_id = l_org_id
                     AND enabled_flag = 'Y');
         EXCEPTION
           WHEN OTHERS THEN
                OE_DEBUG_PUB.ADD('EXCEPTION: No Value for Fiscal Classification');
                l_fcc_code := NULL;

       END;

              --Bug#6019028: No fiscal classification for CO as org id is picked from ship_from_org_id

       IF l_fcc_code IS NULL AND l_country_code = 'CO' THEN
        BEGIN
         SELECT fc.classification_code
          INTO l_fcc_code
          FROM zx_fc_product_fiscal_v   fc,
               mtl_item_categories      mic
          WHERE
              ((fc.country_code    = l_country_code
                 AND fc.country_code in ('AR', 'BR', 'CO'))
                or
                fc.country_code is NULL
               )
          AND mic.inventory_item_id = x_line_rec.inventory_item_id
          AND mic.organization_id   = l_so_organization_id
          AND mic.category_id       = fc.category_id
          AND mic.category_set_id   = fc.category_set_id
       -- AND fc.structure_name     = 'Fiscal Classification'  -- Commented for Bug#7125709
          AND fc.structure_code     = 'FISCAL_CLASSIFICATION'  -- Added as a fix for Bug#7125709
          AND EXISTS
                 (SELECT 1
                   FROM  JL_ZZ_AR_TX_FSC_CLS_ALL
                   WHERE fiscal_classification_code = fc.classification_code
                     AND org_id = l_org_id
                     AND enabled_flag = 'Y')
	  AND ROWNUM =1;
        EXCEPTION
           WHEN OTHERS THEN
              OE_DEBUG_PUB.ADD('EXCEPTION: No Value for Fiscal Classification');
                l_fcc_code := NULL;
        END;
       END IF;
       */

       -- Bug#7827647: use inventory org first
       l_fcc_code := NULL;
       l_inventory_org_id := x_line_rec.ship_from_org_id;

       OPEN c_get_fsc(l_country_code,
                      x_line_rec.inventory_item_id,
                      l_inventory_org_id,
                      l_org_id);
       FETCH c_get_fsc INTO l_fcc_code;
       CLOSE c_get_fsc;

       IF l_fcc_code IS NULL THEN
         --Bug#7827647: use master org
         l_inventory_org_id := l_so_organization_id;

         OPEN c_get_fsc(l_country_code,
                        x_line_rec.inventory_item_id,
                        l_inventory_org_id,
                        l_org_id);
         FETCH c_get_fsc INTO l_fcc_code;
         CLOSE c_get_fsc;
       END IF;

     END IF;

     -- BUG 3685144

       BEGIN
         SELECT order_type_id
         INTO   l_order_type_id
         FROM OE_ORDER_HEADERS_ALL
         WHERE header_id = x_line_rec.header_id;

       EXCEPTION
         WHEN OTHERS THEN
              OE_DEBUG_PUB.ADD('EXCEPTION: No Value for Order type Id ');
              l_order_type_id := NULL;
       END;

       JL_ZZ_OE_LIBRARY_1_PKG.get_global_attribute3 ( l_order_type_id, l_def_value, 1, errcode1 );

     OE_DEBUG_PUB.ADD('Org ID: '|| to_char(l_org_id));
     OE_DEBUG_PUB.ADD('Country Code: '|| l_country_code);
     OE_DEBUG_PUB.ADD('Tax Method: '||l_tax_method);
     OE_DEBUG_PUB.ADD('Inventory Item Id : '|| to_char(x_line_rec.inventory_item_id));
     OE_DEBUG_PUB.ADD('Ship From Inventory Org : '||
                       to_char(x_line_rec.ship_from_org_id));

     OE_DEBUG_PUB.ADD('Order Type Id : '|| l_order_type_id);
     IF l_tax_method = 'LTE' THEN
        OE_DEBUG_PUB.ADD('Before Defaulting');
        OE_DEBUG_PUB.ADD('-----------------');
        OE_DEBUG_PUB.ADD('GA1: '|| x_line_rec.global_attribute1);
        OE_DEBUG_PUB.ADD('GA5: '|| x_line_rec.global_attribute5);
        OE_DEBUG_PUB.ADD('GA6: '|| x_line_rec.global_attribute6);
        OE_DEBUG_PUB.ADD('GA7: '|| x_line_rec.global_attribute7);
        OE_DEBUG_PUB.ADD('GA8: '|| x_line_rec.global_attribute8);

        x_line_rec.global_attribute7 :=
                                   nvl(x_line_rec.global_attribute7,l_fcc_code);
        x_line_rec.global_attribute8 :=
                                   nvl(x_line_rec.global_attribute8,l_tran_nat);
        x_line_rec.global_attribute5 :=
                                   nvl(x_line_rec.global_attribute5,l_fcc_code);
        x_line_rec.global_attribute1 :=
                                   nvl(x_line_rec.global_attribute1,l_def_value);
        x_line_rec.global_attribute6 :=
                                   nvl(x_line_rec.global_attribute6,l_tran_nat);

        IF l_country_code = 'BR' THEN
            x_line_rec.global_attribute9 :=
                                       nvl(x_line_rec.global_attribute9,l_item_orig);
            x_line_rec.global_attribute10 :=
                                       nvl(x_line_rec.global_attribute10,l_fed_trib);
            x_line_rec.global_attribute11 :=
                                       nvl(x_line_rec.global_attribute11,l_sta_trib);
            x_line_rec.global_attribute12 :=
                                       nvl(x_line_rec.global_attribute12,l_item_orig);
            x_line_rec.global_attribute13 :=
                                       nvl(x_line_rec.global_attribute13,l_fed_trib);
            x_line_rec.global_attribute14 :=
                                       nvl(x_line_rec.global_attribute14,l_sta_trib);
        END IF;


        x_line_rec.global_attribute_category :=
                                   nvl(x_line_rec.global_attribute_category,l_gdf_cat);

        OE_DEBUG_PUB.ADD('After Defaulting');
        OE_DEBUG_PUB.ADD('----------------');
        OE_DEBUG_PUB.ADD('Default from Inventory Org' ||
                          to_char(l_inventory_org_id));

        OE_DEBUG_PUB.ADD('GA5: '|| x_line_rec.global_attribute5);
        OE_DEBUG_PUB.ADD('GA6: '|| x_line_rec.global_attribute6);
        OE_DEBUG_PUB.ADD('GA7: '|| x_line_rec.global_attribute7);
        OE_DEBUG_PUB.ADD('GA8: '|| x_line_rec.global_attribute8);
        OE_DEBUG_PUB.ADD('GDF attribute Cat: '|| x_line_rec.global_attribute_category);

     END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
       x_error_buffer := SQLERRM;
       x_return_code := 2;

END default_gdf;


-- Bug#5588076- new procedure to init LTE GDFs
/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    init_gdf                                                                |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    this procedure initializes global attribute columns used by LTE         |
 |                                                                            |
 | PARAMETERS                                                                 |
 |   INPUT                                                                    |
 |      p_line_rec              OE_Invoice_PUB.OE_GDF_Rec_Type                |
 |                              Interface line record in copy_gdff/copy_gdf   |
 |   OUTPUT                                                                   |
 |      p_line_rec              OE_Invoice_PUB.OE_GDF_Rec_Type                |
 |                              Interface line record in copy_gdff/copy_gdf   |
 |                                                                            |
 |                                                                            |
 | HISTORY                                                                    |
 |                                                                            |
 |   28-NOV-2006 Phong La       Created.                                      |
 *----------------------------------------------------------------------------*/

PROCEDURE init_gdf (
        p_line_rec     IN OUT NOCOPY OE_Invoice_PUB.OE_GDF_Rec_Type )
IS
BEGIN

    p_line_rec.line_gdf_attribute8  := NULL;
    p_line_rec.line_gdf_attribute9  := NULL;
    p_line_rec.line_gdf_attribute10 := NULL;
    p_line_rec.line_gdf_attribute11 := NULL;

    /* comment out for now
       p_line_rec.line_gdf_attribute2  := NULL;
       p_line_rec.line_gdf_attribute3  := NULL;
       p_line_rec.line_gdf_attribute12 := NULL;
       p_line_rec.line_gdf_attribute13 := NULL;
       p_line_rec.line_gdf_attribute14 := NULL;
       p_line_rec.line_gdf_attribute19 := NULL;
       p_line_rec.line_gdf_attribute20 := NULL;
    */

END init_gdf;

END JL_ZZ_RECEIV_INTERFACE;

/

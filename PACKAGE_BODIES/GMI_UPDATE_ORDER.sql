--------------------------------------------------------
--  DDL for Package Body GMI_UPDATE_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_UPDATE_ORDER" AS
/*  $Header: GMIUSITB.pls 115.2 2004/07/21 18:29:40 uphadtar noship $ */
/* +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIUSITB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This file is introduced for WSH J release.                          |
 |     The procedure process_order is called from WSHDDSHB.pls to process  |
 |     OPM Internal orders. The same procedure for earlier releases is     |
 |     already in use and declared in GMIUSHPB.pls and procedure is called |
 |     process_opm_orders                                                  |
 |                                                                         |
 | HISTORY                                                                 |
 |     HAW Initianl release 115.0                                          |
 +=========================================================================+
*/

PROCEDURE process_order(P_stop_tab  IN  wsh_util_core.id_tab_type
                             ,x_return_status OUT NOCOPY VARCHAR2  ) IS


l_completion_status     VARCHAR2(30) := 'NORMAL';

l_delivery_id number;
request_id number;
l_error_code number;
l_msg_count number;
l_msg_data varchar2(3000);
l_error_text varchar2(2000);
l_transaction_header_id number ;
l_return_status varchar2(30);
l_if_internal   number ;
l_request_id             NUMBER := NULL;
rcv_inter_req_submission exception;

CURSOR pickup_deliveries (p_stop_id NUMBER)IS
SELECT dg.delivery_id , st.transaction_header_id
     FROM   wsh_delivery_legs dg,
         wsh_new_deliveries dl,
         wsh_trip_stops st
     WHERE     st.stop_id = dg.pick_up_stop_id AND
         st.stop_id = p_stop_id AND
         st.stop_location_id = dl.initial_pickup_location_id AND
         dg.delivery_id = dl.delivery_id  ;

-- Bug 3779795 Added NOT EXISTS to the cursor below so that wdd which is already synchronized to PO
-- side is not inserted again in rcv_transactions_interface.
CURSOR c_detail_in_delivery is
   SELECT   dd.delivery_detail_id, dd.source_line_id
   FROM     wsh_delivery_details dd, wsh_delivery_assignments da
   WHERE    dd.delivery_detail_id             = da.delivery_detail_id
   AND      da.delivery_id                    = l_delivery_id
   AND      NVL(dd.inv_interfaced_flag , 'N') = 'Y'
   AND      dd.container_flag                 = 'N'
   AND      dd.source_code                    = 'OE'
   AND  NOT EXISTS(select 1
                   from   rcv_shipment_lines rsl, oe_order_lines_all oel
                   where  oel.line_id             = dd.source_line_id
                   and    rsl.requisition_line_id = oel.source_document_line_id
                   and    rsl.comments            = 'OPM WDD:'||to_char(dd.delivery_detail_id));

l_detail_in_delivery c_detail_in_delivery%ROWTYPE;

CURSOR c_order_line_info(c_order_line_id number) is
SELECT source_document_type_id
     , source_document_id
     , source_document_line_id
     , ship_from_org_id
from     oe_order_lines_all
where  line_id = c_order_line_id;

l_order_line_info c_order_line_info%ROWTYPE;

l_group_id                 NUMBER := 0;

CURSOR c_details_for_interface(p_del_detail_id number)  is
SELECT * from wsh_delivery_details
where delivery_detail_id = p_del_detail_id
and container_flag = 'N';

l_detail_rec c_details_for_interface%ROWTYPE;

del_rec_stop_id pickup_deliveries%ROWTYPE;


CURSOR c_trip_stop (c_trip_stop_id NUMBER ) IS
   SELECT * FROM WSH_TRIP_STOPS
   WHERE STOP_ID = c_trip_stop_id;

l_trip_stop_rec c_trip_stop%ROWTYPE;

 BEGIN


   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   l_if_internal := 0 ;

   gmi_reservation_util.println('Value of count in OPM_ORDERS for WSH J is '||p_stop_tab.count);
   for i in 1.. p_stop_tab.count LOOP
    ---FOR del IN pickup_deliveries LOOP
    GMI_RESERVATION_UTIL.Println ('Processing Stop: '||p_stop_tab(i) );
     OPEN pickup_deliveries(p_stop_tab(i));
     LOOP
       gmi_reservation_util.println('Fetching pickup_deliveries');
       FETCH pickup_deliveries into del_rec_stop_id ;
       l_delivery_id := del_rec_stop_id.delivery_id;
       EXIT WHEN pickup_deliveries%NOTFOUND;
       GMI_RESERVATION_UTIL.Println ('Found delivery: '  ||   l_delivery_id);
       OPEN c_detail_in_delivery ;

       LOOP
         gmi_reservation_util.println('Fetching c_detail_in_delivery');
         FETCH c_detail_in_delivery into l_detail_in_delivery;
         EXIT WHEN c_detail_in_delivery%NOTFOUND;

         OPEN c_order_line_info(l_detail_in_delivery.source_line_id);
         gmi_reservation_util.println('Fetching c_order_line_info for l_detail_in_delivery.source_line_id'||l_detail_in_delivery.source_line_id);
         FETCH c_order_line_info into l_order_line_info;
         if (c_order_line_info%NOTFOUND) THEN
            CLOSE c_order_line_info;
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            GMI_RESERVATION_UTIL.Println('Warning, Sales order not valid');
            CLOSE c_detail_in_delivery;  /* B2886561 close this cursor before return */
            return;
         END if;
         CLOSE c_order_line_info;

         IF (l_order_line_info.source_document_type_id = 10
             and INV_GMI_RSV_BRANCH.Process_Branch(l_order_line_info.ship_from_org_id) )
         THEN /* internal order */
            l_if_internal := 1;  -- internal order
            gmi_reservation_util.println('It is an internal Order');
            IF nvl(l_group_id,0) = 0 THEN
               /* only do this once */
               select RCV_INTERFACE_GROUPS_S.NEXTVAL INTO l_group_id FROM DUAL;
            END IF;
            gmi_reservation_util.println('Going to open c_details_for_interface and value of l_detail_in_delivery.delivery_detail_id is '||l_detail_in_delivery.delivery_detail_id);
            OPEN c_details_for_interface(l_detail_in_delivery.delivery_detail_id);
            FETCH c_details_for_interface into l_detail_rec;
            if c_details_for_interface%NOTFOUND then
               CLOSE c_details_for_interface;
               x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
               WSH_UTIL_CORE.Println('Warning, Delivery Detail ' ||l_detail_in_delivery.delivery_detail_id ||' not found');
               IF c_detail_in_delivery%ISOPEN THEN  /* B2886561 close this cursor before return */
                  CLOSE c_detail_in_delivery;
               END IF;
               return;
            end if;
            CLOSE c_details_for_interface;

            OPEN c_trip_stop(p_stop_tab(i));
            gmi_reservation_util.println('Going to fetch  c_trip_stop for  stop  '||p_stop_tab(i));
            FETCH c_trip_stop into l_trip_stop_rec;
              if c_trip_stop%NOTFOUND then
               CLOSE c_trip_stop;
               x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
               WSH_UTIL_CORE.Println('Warning, Trip Stop '|| p_stop_tab(i) ||' not found');
               IF c_detail_in_delivery%ISOPEN THEN  /* B2886561 close this cursor before return */
                  CLOSE c_detail_in_delivery;
               END IF;
               return;
              end if;
            oe_debug_pub.add('Found Trip Stop '|| p_stop_tab(i));
            CLOSE c_trip_stop;

            GMI_RESERVATION_UTIL.Println ('found internal order line in this delivery  '  ||   l_delivery_id);
            -- internal orders, insert into rcv_transactions_interface
            gmi_reservation_util.println('Going to call GMI_SHIPPING_UTIL.create_rcv_transaction');
            GMI_SHIPPING_UTIL.create_rcv_transaction
                ( p_shipping_line   => l_detail_rec
                , p_trip_stop_rec   => l_trip_stop_rec
                , p_group_id        => l_group_id
                , x_return_status    => l_return_status
                , x_msg_count        => l_msg_count
                , x_msg_data         => l_msg_data
                );
            gmi_reservation_util.println('Finished calling GMI_Shipping_Util.create_rcv_transaction');
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                WSH_UTIL_CORE.printmsg('Warning ...');
                WSH_UTIL_CORE.println('Failed GMI_Shipping_Util.create_rcv_transaction for delivery ID '
                      || l_detail_rec.DELIVERY_DETAIL_ID );
            END IF;

         END IF;
       END LOOP;   -- 2nd inner loop

       CLOSE c_detail_in_delivery;
     END LOOP;      -- 1st inner loop
     CLOSE pickup_deliveries;
   END LOOP; -- of For loop



   IF ( l_if_internal = 1 ) THEN
      l_request_id := fnd_request.submit_request(
          'PO',
          'RVCTP',
          null,
          null,
          false,
          'IMMEDIATE',
          l_group_id,
          fnd_global.local_chr(0),
          NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL, NULL, NULL);
   END IF;

   IF  (l_request_id = 0 ) THEN
     raise rcv_inter_req_submission;
   END IF;

   EXCEPTION
     WHEN rcv_inter_req_submission THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      gmi_reservation_util.println('Submitting Receivable Transaction failed');


END process_order;

END GMI_UPDATE_ORDER;


/

--------------------------------------------------------
--  DDL for Package Body OE_INV_IFACE_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_INV_IFACE_CONC" AS
/* $Header: OEXCIIFB.pls 120.4 2005/08/29 10:04:06 pkannan noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_INV_IFACE_CONC';

Function Line_Eligible(p_line_id IN NUMBER)
RETURN BOOLEAN
IS
  l_activity_status_code VARCHAR2(8);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  -- Check for workflow status to be Inventory Interface Eligible
  SELECT ACTIVITY_STATUS
  INTO l_activity_status_code
  FROM wf_item_activity_statuses wias, wf_process_activities wpa
  WHERE wias.item_type = 'OEOL' AND
        wias.item_key  = to_char(p_line_id) AND
	   wias.process_activity = wpa.instance_id AND
        wpa.activity_name = 'INVENTORY_INTERFACE_ELIGIBLE' AND
	   wias.activity_status = 'NOTIFIED';

  RETURN TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'INV IFACE CONC: LINE DOES NOT HAVE NOTIFIED INV IFACE ELIGIBLE' , 5 ) ;
       END IF;
       RETURN FALSE;
  WHEN OTHERS THEN
	  IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'INV IFACE CONC: OTHER EXCEPTION' , 5 ) ;
	  END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  RETURN FALSE;
END Line_Eligible;

/*-----------------------------------------------------------------
PROCEDURE  : Request
DESCRIPTION: Inventory Interface Concurrent Request
-----------------------------------------------------------------*/

Procedure Request
(ERRBUF OUT NOCOPY VARCHAR2,

RETCODE OUT NOCOPY VARCHAR2,
 /* Moac */
 p_org_id	      IN  NUMBER,
 p_order_number_low   IN  NUMBER,
 p_order_number_high  IN  NUMBER,
 p_request_date_low   IN  DATE,
 p_request_date_high  IN  DATE,
 p_customer_po_number IN  VARCHAR2,
 p_ship_from_org_id   IN  VARCHAR2,
 p_order_type         IN  VARCHAR2,
 p_customer           IN  VARCHAR2,
 p_item               IN  VARCHAR2
)IS

   l_msg_count               NUMBER;
   l_msg_data                VARCHAR2(2000) := NULL;

   j                         Integer;
   -- variable for debugging.
   l_file_val                VARCHAR2(80);

   CURSOR line_cur IS
      SELECT H.org_id, H.header_id, L.line_id
      FROM   oe_order_headers H, oe_order_lines_all L
      WHERE
          H.org_id = NVL(p_org_id, H.org_id)
      AND H.header_id = L.header_id
      AND H.order_number >= NVL(p_order_number_low, H.order_number)
      AND H.order_number <= NVL(p_order_number_high, H.order_number)
      AND H.order_type_id = NVL(p_order_type, H.order_type_id)
      AND nvl(H.sold_to_org_id, -1) = NVL(p_customer, nvl(H.sold_to_org_id, -1))
      AND nvl(H.request_date, sysdate) >= NVL(p_request_date_low, nvl(H.request_date, sysdate))
      AND nvl(H.request_date, sysdate) <= NVL(p_request_date_high, nvl(H.request_date, sysdate))
      AND NVL(H.cust_po_number,-1) = NVL(p_customer_po_number, NVL(H.cust_po_number,-1))
      AND H.open_flag = 'Y'
      AND L.inventory_item_id = NVL(p_item, L.inventory_item_id)
      AND NVL(L.ship_from_org_id, -1) = NVL(p_ship_from_org_id, NVL(L.ship_from_org_id, -1))
      AND L.open_flag = 'Y'
      ORDER BY H.org_id, H.header_id ;

/*
   CURSOR line_cur(p_header_id IN NUMBER) IS
         SELECT line_id, org_id
         FROM oe_order_lines_all
         WHERE header_id = p_header_id
	    AND inventory_item_id = NVL(p_item, inventory_item_id)
	    AND NVL(ship_from_org_id, -1) = NVL(p_ship_from_org_id, NVL(ship_from_org_id, -1))
	    AND open_flag = 'Y';
*/

         -- Moac : commented the below locking.
         --FOR UPDATE NOWAIT;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
-- Moac
l_single_org		BOOLEAN := FALSE;
l_old_org_id		NUMBER  := -99;

BEGIN

/*
   l_file_val := OE_DEBUG_PUB.Set_Debug_Mode('FILE');
   OE_DEBUG_PUB.Initialize;
   OE_DEBUG_PUB.Debug_Off;
   OE_DEBUG_PUB.Debug_On;
   oe_Debug_pub.setdebuglevel(5);
*/
   fnd_file.put_line(FND_FILE.LOG, 'Debug File: ' || l_file_val);
   fnd_file.put_line(FND_FILE.LOG, 'Parameters:');

   fnd_file.put_line(FND_FILE.LOG, 'p_org_id = '|| p_org_id);

   fnd_file.put_line(FND_FILE.LOG, '	order_number_low =  '||
                                        p_order_number_low);
   fnd_file.put_line(FND_FILE.LOG, '	order_number_high = '||
                                        p_order_number_high);
   fnd_file.put_line(FND_FILE.LOG, '	order_type = '||
                                        p_order_type);
   fnd_file.put_line(FND_FILE.LOG, '	sold_to_ord = '||
                                        p_customer);
   fnd_file.put_line(FND_FILE.LOG, '	request_date_low = '||
                                        p_request_date_low);
   fnd_file.put_line(FND_FILE.LOG, '	request_date_high = '||
                                        p_request_date_high);
   fnd_file.put_line(FND_FILE.LOG, '	cust_po_number = '||
                                        p_customer_po_number);
   fnd_file.put_line(FND_FILE.LOG, '    item = '||
								p_item);
   fnd_file.put_line(FND_FILE.LOG, '    warehouse = '||
								   p_ship_from_org_id);
   -- Moac Start
   IF MO_GLOBAL.get_access_mode = 'S' THEN
      l_single_org := TRUE;
   ELSIF p_org_id IS NOT NULL THEN
      l_single_org := TRUE;
      MO_GLOBAL.set_policy_context(p_access_mode => 'S', p_org_id  => p_org_id);
   END IF;
   -- Moac End


      SAVEPOINT lock_lines;

      FOR j in line_cur LOOP
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'INV IFACE CONC: LINE_ID - ' || TO_CHAR ( J.LINE_ID ) , 5 ) ;
		END IF;
          IF Line_Eligible(p_line_id => j.line_id) THEN
          BEGIN

                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'COMPLETING ACTIVITY FOR : ' || J.LINE_ID , 5 ) ;
                 END IF;

	   -- MOAC Start. Set policy context if the OU changes on lines.
	   IF NOT l_single_org and j.org_id <> l_old_org_id then
		  l_old_org_id := j.org_id;
 	      MO_GLOBAL.set_policy_context(p_access_mode => 'S', p_org_id  => j.org_id);
	   END IF;
	   -- MOAC End.

                 wf_engine.CompleteActivityInternalName
                             ('OEOL',
                              to_char(j.line_id),
                              'INVENTORY_INTERFACE_ELIGIBLE',
                              'COMPLETE');
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 null;
            WHEN OTHERS THEN
                 null;
          END;
		END IF;

      END LOOP;
      COMMIT;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
         fnd_file.put_line(FND_FILE.LOG,
            'Error executing Inventory Interface, Exception:G_EXC_ERROR');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        fnd_file.put_line(FND_FILE.LOG,
            'Error executing Inventory Interface, Exception:G_EXC_UNEXPECTED_ERROR');
   WHEN OTHERS THEN
	   fnd_file.put_line(FND_FILE.LOG,
            'Error executing Inventory Interface');

END Request;

END OE_INV_IFACE_CONC;

/

--------------------------------------------------------
--  DDL for Package Body WMS_SHIPPING_LPN_UTILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_SHIPPING_LPN_UTILS_PUB" AS
/* $Header: WMSSHUTB.pls 120.1.12010000.2 2008/08/19 09:56:36 anviswan ship $ */


PROCEDURE mydebug(msg in varchar2)
  IS
     l_msg VARCHAR2(5100);
     l_ts VARCHAR2(30);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
--   select to_char(sysdate,'MM/DD/YYYY HH:MM:SS') INTO l_ts from dual;
--   l_msg:=l_ts||'  '||msg;

   l_msg := msg;

   inv_mobile_helper_functions.tracelog
     (p_err_msg => l_msg,
      p_module => 'WMS_Shipping_LPN_Utils_PUB',
      p_level => 4);

END;


PROCEDURE update_lpn_context
  (  p_delivery_id            IN    NUMBER,
     x_return_status          OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
     x_msg_count              OUT NOCOPY /* file.sql.39 change */   NUMBER,
     x_msg_data               OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
  IS

     CURSOR child_lpns_cursor(l_lpn_id IN NUMBER) IS
	SELECT wlpn.lpn_id
	  FROM wms_license_plate_numbers wlpn
	  WHERE wlpn.lpn_context  <> wms_globals.lpn_context_inv
	  START WITH wlpn.lpn_id  =  l_lpn_id
	  CONNECT BY wlpn.lpn_id  =  PRIOR parent_lpn_id;

     CURSOR lpns_in_delivery IS
	SELECT wdd.lpn_id
	  FROM
	  wsh_delivery_assignments_v wda,
	  wsh_delivery_details wdd
	  WHERE wda.delivery_id        = p_delivery_id
	  AND   wda.delivery_detail_id = wdd.delivery_detail_id
	  AND   wdd.lpn_id IS NOT NULL;

     l_lpn_id            NUMBER;
     l_innermost_lpn_id  NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      mydebug('update_lpn_context: Begin update_lpn_context');
   END IF;

   OPEN lpns_in_delivery;
   LOOP
      FETCH lpns_in_delivery INTO l_innermost_lpn_id;
      EXIT WHEN lpns_in_delivery%notfound;

      OPEN child_lpns_cursor(l_innermost_lpn_id);
      LOOP
	 FETCH child_lpns_cursor INTO l_lpn_id;
	 EXIT WHEN child_lpns_cursor%notfound;

	 UPDATE  wms_license_plate_numbers
	   SET   lpn_context = wms_globals.lpn_context_inv
	   WHERE lpn_id      = l_lpn_id;

      END LOOP;
      CLOSE child_lpns_cursor;

   END LOOP;
   CLOSE lpns_in_delivery;

   IF (l_debug = 1) THEN
      mydebug('update_lpn_context: End update_lpn_context');
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:=FND_API.G_RET_STS_ERROR;

      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
      fnd_msg_pub.ADD;

      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

      IF (l_debug = 1) THEN
         mydebug('update_lpn_context: Error in update_lpn_context API: ' || sqlerrm);
      END IF;

   WHEN OTHERS THEN

      x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;

      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
      fnd_msg_pub.ADD;

      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

      IF (l_debug = 1) THEN
         mydebug('update_lpn_context: Unexpected Error in update_lpn_context API: ' || sqlerrm);
      END IF;

END;



END WMS_Shipping_LPN_Utils_PUB;

/

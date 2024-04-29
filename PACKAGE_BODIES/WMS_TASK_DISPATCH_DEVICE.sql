--------------------------------------------------------
--  DDL for Package Body WMS_TASK_DISPATCH_DEVICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_TASK_DISPATCH_DEVICE" AS
/* $Header: WMSTKDVB.pls 120.7 2005/10/09 03:42:43 simran noship $ */


--  Global constant holding the package name

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'WMS_Task_Dispatch_Device';



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
      p_module => 'WMS_Task_Dispatch_Device',
      p_level => 4);

   --dbms_output.put_line(l_msg);

   null;
END;



PROCEDURE insert_device
  (p_Employee_Id     IN NUMBER,
   p_device_id       IN NUMBER,
   p_org_id          IN NUMBER,
   x_return_status   OUT  NOCOPY VARCHAR2) IS
      l_assign_temp_id number;
      l_device_status VARCHAR2(400);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_wcs_enabled VARCHAR2(1);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (l_debug = 1) THEN
      mydebug('In insert_device');
   END IF;

   SELECT WMS_DEVICE_ASSIGNMENT_TEMP_S.nextval
     INTO l_assign_temp_id
     FROM DUAL;

   INSERT INTO WMS_DEVICE_ASSIGNMENT_TEMP
     ( 	ASSIGNMENT_TEMP_ID,
	EMPLOYEE_ID,
	ORGANIZATION_ID,
	DEVICE_ID,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN)
     VALUES
     (    l_assign_temp_id,
	  p_Employee_Id,
	  p_org_id,
	  p_device_id,
	  sysdate,
	  FND_GLOBAL.USER_ID,
	  sysdate,
	  FND_GLOBAL.USER_ID,
	  FND_GLOBAL.LOGIN_ID );

    l_wcs_enabled := wms_devices_pkg.is_wcs_enabled(P_ORG_ID);

    IF (l_wcs_enabled='Y') THEN
      -- Call Sync_device api
      IF (l_debug = 1) THEN
         mydebug('Calling WMS_DEVICE_INTEGRATION_WCS.sync_device for device id : '||p_device_id);
      END IF;

      WMS_DEVICE_INTEGRATION_WCS.sync_device(p_organization_id => p_org_id,
					  p_device_id => p_device_id,
					  p_employee_id => p_employee_id,
					  p_sign_on_flag => 'Y',
					  x_status_code => x_return_status,
					  x_device_status => l_device_status);
    ELSE
      -- Call Sync_device api
      IF (l_debug = 1) THEN
         mydebug('Calling wms_device_integration_pub.sync_device for device id : '||p_device_id);
      END IF;

      wms_device_integration_pub.sync_device(p_organization_id => p_org_id,
					  p_device_id => p_device_id,
					  p_employee_id => p_employee_id,
					  p_sign_on_flag => 'Y',
					  x_status_code => x_return_status,
					  x_device_status => l_device_status);
    END IF;

   IF (l_debug = 1) THEN
      mydebug('Status Code : '||x_return_status);
      mydebug('Device Status : '||l_device_status);
   END IF;

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      -- Have to commit it, so that the others can see it and current devices can see it
      COMMIT;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END insert_device;




PROCEDURE cleanup_device_and_tasks
  (p_Employee_Id     IN NUMBER,
   p_org_id          IN NUMBER,
   x_return_status   OUT  NOCOPY VARCHAR2,
   x_msg_count       OUT  NOCOPY NUMBER,
   x_msg_data        OUT  NOCOPY VARCHAR2,
   p_retain_dispatched_tasks IN VARCHAR2 default 'N') IS

      l_device_status VARCHAR2(400);
      l_device_id NUMBER;

      CURSOR get_devices_to_cleanup IS
	 SELECT device_id
	   FROM wms_device_assignment_temp
	   WHERE Employee_Id=p_employee_id
	   AND organization_id=p_org_id;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_wcs_enabled VARCHAR2(1);
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (l_debug = 1) THEN
      mydebug('In cleanup_device_and_tasks');
   END IF;

   l_wcs_enabled := wms_devices_pkg.is_wcs_enabled(P_ORG_ID);

   -- call sync_device api
   OPEN get_devices_to_cleanup;

   LOOP
      FETCH get_devices_to_cleanup INTO l_device_id;
      EXIT WHEN get_devices_to_cleanup%NOTFOUND;

    IF (l_wcs_enabled='Y') THEN
      IF (l_debug = 1) THEN
         mydebug('Calling WMS_DEVICE_INTEGRATION_WCS.sync_device for device id: '||l_device_id);
      END IF;

      WMS_DEVICE_INTEGRATION_WCS.SYNC_DEVICE (p_organization_id => p_org_id,
					      p_device_id => l_device_id,
					      p_employee_id => p_employee_id,
					      p_sign_on_flag => 'N',
					      x_status_code => x_return_status,
					      x_device_status => l_device_status);
    ELSE
      IF (l_debug = 1) THEN
         mydebug('Calling wms_device_integration_pub.sync_device for device id: '||l_device_id);
      END IF;

      WMS_Device_Integration_PUB.sync_device (p_organization_id => p_org_id,
					      p_device_id => l_device_id,
					      p_employee_id => p_employee_id,
					      p_sign_on_flag => 'N',
					      x_status_code => x_return_status,
					      x_device_status => l_device_status);
    END IF;

      IF (l_debug = 1) THEN
         mydebug('Status Code : '||x_return_status);
         mydebug('Device Status : '||l_device_status);
      END IF;

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 EXIT;
      END IF;

   END LOOP;

   CLOSE get_devices_to_cleanup;

   -- signed off all the devices for this person
   DELETE FROM WMS_DEVICE_ASSIGNMENT_TEMP
     WHERE Employee_Id=p_Employee_Id
     AND organization_id=p_org_id;

   IF p_retain_dispatched_tasks ='N' or SQL%ROWCOUNT >1 THEN
   -- signed off all the dispatched but not started tasks for this user
   DELETE FROM WMS_DISPATCHED_TASKS
     WHERE person_id = p_Employee_Id
     and organization_id = p_org_id
     and task_type IN (1, 3, 4, 5, 6)
     and status IN (1,3,9); -- delete the Active task too, patchset I
   ELSE
       UPDATE WMS_DISPATCHED_TASKS
       SET status = 3
       WHERE status = 9
         and person_id = p_Employee_ID
         and organization_id = p_org_id
         and task_type IN (1,3,4,5,6);
   END IF;

   -- Commit so that task dispatching can see it
   IF (x_return_status = FND_API.g_ret_sts_success) THEN
      COMMIT;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END cleanup_device_and_tasks;

/*
   This is the overloaded procedure
   It takes one additional parameter p_device_id
     The call to sync_device
     Deleting From Wms_device_assignment_temp &
     Deleting or Updating WDT
   will be only for that particular device
*/
   PROCEDURE cleanup_device_and_tasks
  (p_Employee_Id     IN NUMBER,
   p_org_id          IN NUMBER,
   p_device_id       IN NUMBER,
   x_return_status   OUT  NOCOPY VARCHAR2,
   x_msg_count       OUT  NOCOPY NUMBER,
   x_msg_data        OUT  NOCOPY VARCHAR2,
   p_retain_dispatched_tasks IN VARCHAR2 default 'N') IS

      l_device_status VARCHAR2(400);
      l_device_id NUMBER;

      CURSOR get_devices_to_cleanup IS
	 SELECT device_id
	   FROM wms_device_assignment_temp
	   WHERE Employee_Id=p_employee_id
	   AND organization_id=p_org_id
           AND device_id = p_device_id;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_wcs_enabled VARCHAR2(1);
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (l_debug = 1) THEN
      mydebug('In Overloaded cleanup_device_and_tasks');
   END IF;

   l_wcs_enabled := wms_devices_pkg.is_wcs_enabled(P_ORG_ID);

   -- call sync_device api
   OPEN get_devices_to_cleanup;

   LOOP
      FETCH get_devices_to_cleanup INTO l_device_id;
      EXIT WHEN get_devices_to_cleanup%NOTFOUND;

    IF (l_wcs_enabled='Y') THEN
      IF (l_debug = 1) THEN
         mydebug('Calling WMS_DEVICE_INTEGRATION_WCS.sync_device for device id: '||l_device_id);
      END IF;

      WMS_DEVICE_INTEGRATION_WCS.SYNC_DEVICE (p_organization_id => p_org_id,
					      p_device_id => l_device_id,
					      p_employee_id => p_employee_id,
					      p_sign_on_flag => 'N',
					      x_status_code => x_return_status,
					      x_device_status => l_device_status);
    ELSE
      IF (l_debug = 1) THEN
         mydebug('Calling wms_device_integration_pub.sync_device for device id: '||l_device_id);
      END IF;

      WMS_Device_Integration_PUB.sync_device (p_organization_id => p_org_id,
					      p_device_id => l_device_id,
					      p_employee_id => p_employee_id,
					      p_sign_on_flag => 'N',
					      x_status_code => x_return_status,
					      x_device_status => l_device_status);
    END IF;

      IF (l_debug = 1) THEN
         mydebug('Status Code : '||x_return_status);
         mydebug('Device Status : '||l_device_status);
      END IF;

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 EXIT;
      END IF;

   END LOOP;

   CLOSE get_devices_to_cleanup;

   -- signed off all the devices for this person
   DELETE FROM WMS_DEVICE_ASSIGNMENT_TEMP
     WHERE Employee_Id=p_Employee_Id
     AND organization_id=p_org_id
     AND device_id = p_device_id;

   IF p_retain_dispatched_tasks ='N' or SQL%ROWCOUNT >1 THEN
   -- signed off all the dispatched but not started tasks for this user
   DELETE FROM WMS_DISPATCHED_TASKS
     WHERE person_id = p_Employee_Id
     and organization_id = p_org_id
     and device_id = p_device_id
     and task_type IN (1, 3, 4, 5, 6)
     and status IN (1,3,9); -- delete the Active task too, patchset I
   ELSE
       UPDATE WMS_DISPATCHED_TASKS
       SET status = 3
       WHERE status = 9
         and person_id = p_Employee_ID
         and organization_id = p_org_id
         and device_id = p_device_id
         and task_type IN (1,3,4,5,6);
   END IF;

   -- Commit so that task dispatching can see it
   IF (x_return_status = FND_API.g_ret_sts_success) THEN
      COMMIT;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END cleanup_device_and_tasks; -- End of overloaded procedure

--J Develop

PROCEDURE get_device_info(p_organization_id IN NUMBER,
			  p_device_name IN VARCHAR2,
			  x_return_status OUT NOCOPY VARCHAR2,
			  x_device_id OUT NOCOPY NUMBER,
			  x_device_type OUT NOCOPY VARCHAR2,
			  x_device_desc OUT NOCOPY VARCHAR2,
			  x_subinventory OUT NOCOPY VARCHAR2,
           p_emp_id IN NUMBER,
           x_signed_onto_wrk_stn OUT NOCOPY VARCHAR2)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_is_device_signed NUMBER := 0;
    l_device_type_id NUMBER := -1;
    l_signed_onto_wrk_stn NUMBER;
    using_asrs_without_wrk_stn EXCEPTION;
    is_org_wcs_enabled VARCHAR2(1);
    l_is_multi_signon_dev  VARCHAR2(1);


   /***********************************************************************************
      Added for device Integration project. Check whether the device being singed onto
      is already signed on by some other user. If so then do not allow the current
      user to sign onto the device.
    ***********************************************************************************/

   /***********************************************************************************
      Allow multiple users to sign on if MULTI_SIGN_ON is checked
      For device_type_id=100 (Workstation) Sub will be NULL
    ***********************************************************************************/

   BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_signed_onto_wrk_stn := 'Y';
     l_is_multi_signon_dev := wms_devices_pkg.is_device_multisignon(p_organization_id, p_device_name);
     is_org_wcs_enabled := wms_devices_pkg.is_wcs_enabled(p_organization_id);
      IF (l_debug = 1) THEN
         mydebug('MHE: is_org_wcs_enabled = '||is_org_wcs_enabled);
      END IF;

      IF is_org_wcs_enabled = 'Y' THEN

         SELECT nvl(device_type_id, -1)
           INTO l_device_type_id
           FROM wms_devices_vl wdv
          WHERE wdv.organization_id = p_organization_id
            AND wdv.name            = p_device_name;

         IF (l_debug = 1) THEN
            mydebug('MHE: l_device_type_id = '||l_device_type_id);
         END IF;

      	/*
      	If the device type is ASRS (6) then check if the employee has signed on to a
      	Work Sation (device type 100). If he has not; then set x_return_status to "E"
   	   raise the user defined exception using_asrs_without_wrk_stn
      	*/
         IF l_device_type_id = 6 THEN
           BEGIN
              SELECT 1
                INTO l_signed_onto_wrk_stn
                FROM WMS_DEVICE_ASSIGNMENT_TEMP wda,
                     WMS_DEVICES_VL wvl
               WHERE wda.device_id = wvl.device_id
                 AND wvl.organization_id   = p_organization_id
                 AND wda.employee_id       = p_emp_id
                 AND device_type_id = 100;

               IF (l_debug = 1) THEN
                  mydebug('MHE: l_signed_onto_wrk_stn = '||l_signed_onto_wrk_stn);
               END IF;
           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  raise using_asrs_without_wrk_stn;
           END;
         END IF;
      END IF;

      SELECT 1
           , wvl.description
        INTO l_is_device_signed
           , x_device_desc
        FROM WMS_DEVICE_ASSIGNMENT_TEMP wda
           , WMS_DEVICES_VL wvl
       WHERE wda.device_id = wvl.device_id
         AND (wvl.subinventory_code IS NOT NULL OR device_type_id = 100)
         AND l_is_multi_signon_dev <> 'Y'
         AND wvl.organization_id	  = p_organization_id
         AND wvl.name              = p_device_name
         AND device_type_id <> 7 ;

         IF l_is_device_signed = 1 THEN
            x_return_status := 'A';
         END IF;

   EXCEPTION
      WHEN no_data_found THEN
         BEGIN
           SELECT device_type
                , description
                , device_id
                , subinventory_code
             INTO x_device_type
                , x_device_desc
                , x_device_id
                , x_subinventory
             FROM WMS_DEVICES_VL
            WHERE (subinventory_code IS NOT NULL OR device_type_id = 100)
              AND organization_id = p_organization_id
              AND name            = p_device_name
              AND device_type_id <> 7 ;
         EXCEPTION
            WHEN no_data_found THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
            WHEN OTHERS THEN
                 x_return_status := FND_API.g_ret_sts_unexp_error;
         END;
      WHEN using_asrs_without_wrk_stn THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_signed_onto_wrk_stn := 'N';
END get_device_info;


/***********************************************************************
 * FUNCTION get_eligible_device gets the device which will be used
 * for the User/Org/Sub and Loc combination. It will get the device
 * based on the most restrictive combination. The decreasing order
 * of choice of device is :
 *             1. User Level
 *             2. Locator Level
 *             3. Subinventory Level
 *             4. Organization Level
 ********************************************************************* */
FUNCTION get_eligible_device(
            p_organization_id  IN NUMBER
		    , p_subinventory     IN VARCHAR2
		    , p_locator_id       IN NUMBER
	       ) return NUMBER
IS
		l_device_id NUMBER;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
SELECT device_id
  INTO l_device_id
  FROM (
  SELECT wbed.DEVICE_ID
          FROM wms_bus_event_devices wbed  , wms_devices_b wd
	  WHERE wd.device_id = wbed.device_id
          AND WBED.organization_id = WD.organization_id
          AND wd.ENABLED_FLAG = 'Y'
          AND decode (level_type, 200,wbed.subinventory_code,level_value) =
	            decode(level_type,200,p_subinventory,100,p_organization_id ,300, p_locator_id,400,
                      FND_GLOBAL.USER_ID,level_value)
          AND Nvl(wbed.organization_id,-1) = Nvl(p_organization_id ,Nvl(wbed.organization_id ,-1))
         --AND wbed.AUTO_ENABLED_FLAG = decode('Y','Y','Y','N')
	  AND wbed.business_event_id = wms_device_integration_pvt.wms_be_pick_load
          ORDER BY level_type desc
       )
 WHERE rownum < 2;

IF (l_debug = 1) THEN
   mydebug('Device ID Fetched: '||l_device_id);
END IF;

RETURN l_device_id;
END get_eligible_device;






END wms_task_dispatch_device;


/

--------------------------------------------------------
--  DDL for Package Body WSH_INTERFACE_VALIDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_INTERFACE_VALIDATIONS_PKG" AS
/* $Header: WSHINVDB.pls 120.2.12010000.6 2010/02/25 15:57:51 sankarun ship $ */

/*==============================================================================

PROCEDURE NAME: Validate_Document

This Procedure is called from the XML Gateway, even before data is populated
into the interface tables.
This Procedure checks for basic validations in the incoming XML message.

   ** When the 940 or 945 comes in, it checks if the message received is not
      duplicate.

   ** When the 940 Cancellation comes in at the TPW instance, it checks
      if the corresponding 940 add exists.

   ** When the 945 comes in at the Supplier Instance, it checks if the
      corresponding 940 out exists.

==============================================================================*/

   --
   G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_INTERFACE_VALIDATIONS_PKG';
   --
   -- LSP PROJECT : Added new in parameter p_client_code.
   -- Trading Partner Id value comes from xml mapping when p_client_code is not NULL
   PROCEDURE validate_document (
      p_doc_type               IN       VARCHAR2,
      p_doc_number             IN       VARCHAR2,
      -- R12.1.1 STANDALONE PROJECT
      P_doc_revision           IN       NUMBER,
      p_trading_partner_Code   IN       VARCHAR2,
      p_action_type            IN       VARCHAR2,
      p_doc_direction          IN       VARCHAR2,
      p_orig_document_number   IN       VARCHAR2,
      p_client_code            IN       VARCHAR2 DEFAULT NULL, -- LSP PROJECT
      x_trading_partner_ID     IN OUT NOCOPY    NUMBER, -- LSP PROJECT: make it as in out
      x_valid_doc              OUT NOCOPY       VARCHAR2,
      x_return_status          OUT NOCOPY       VARCHAR2
   )
   IS

      p_duplicate             VARCHAR2 (1);
      p_940_exists            VARCHAR2 (1);
      --R12.1.1 STANDALONE PROJECT
      l_wms_deployment_mode   VARCHAR2(1);
      invalid_doc_revision    EXCEPTION;
      invalid_doc_number      EXCEPTION;
      invalid_tp              EXCEPTION;
      invalid_doc_direction   EXCEPTION;
      invalid_doc_type        EXCEPTION;
      invalid_action_type     EXCEPTION;
      --
      l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_DOCUMENT';
      --
   BEGIN
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name, 'VALIDATE_DOCUMENT');
      wsh_debug_sv.log (l_module_name, 'DOCUMENT TYPE', p_doc_type);
      wsh_debug_sv.log (l_module_name, 'DOCUMENT NUMBER', p_doc_number);
      --R12.1.1 STANDALONE PROJECT
      wsh_debug_sv.log (l_module_name, 'DOCUMENT REVISION', p_doc_revision);
      wsh_debug_sv.log (l_module_name, 'TRADING PARTNER', p_trading_partner_Code);
      wsh_debug_sv.log (l_module_name, 'ACTION TYPE', p_action_type);
      wsh_debug_sv.log (l_module_name, 'DOCUMENT DIRECTION', p_doc_direction);
      wsh_debug_sv.log (l_module_name, 'ORIGINAL DOC NUMBER', p_orig_document_number);
      wsh_debug_sv.log (l_module_name, 'CLIENT CODE', p_client_code);  -- LSP PROJECT
    END IF;

      -- Check if the values passed are Not Null and valid
      IF (p_doc_number IS NULL)
      THEN
         RAISE invalid_doc_number;
      END IF;

      IF (p_trading_partner_Code IS NULL)
      THEN
         RAISE invalid_tp;
      END IF;

      IF (p_doc_direction IS NULL)
      THEN
         RAISE invalid_doc_direction;
      END IF;
      --R12.1.1 STANDALONE PROJECT
      l_wms_deployment_mode := WMS_DEPLOY.WMS_DEPLOYMENT_MODE;

      IF (l_wms_deployment_mode = 'D' OR (l_wms_deployment_mode = 'L' AND p_client_code IS NOT NULL)) THEN --{ LSP PROJECT : consider LSP mode also

        IF ((p_doc_type IS NULL) OR (p_doc_type NOT IN ('SR'))) THEN
           RAISE invalid_doc_type;
        END IF;

        IF ((p_action_type IS NULL) OR (p_action_type NOT IN ('A', 'C', 'D'))) THEN
           RAISE invalid_action_type;
        END IF;

        IF ((p_doc_direction IS NULL) OR (p_doc_direction NOT IN ('I', 'O'))) THEN
           RAISE invalid_Doc_direction;
        END IF;

        IF ((p_doc_revision IS NULL) OR (p_doc_revision <= 0) OR (trunc(p_doc_revision) <> p_doc_revision)) THEN
           RAISE invalid_Doc_revision;
        END IF;

      ELSE --} {
        IF ((p_doc_type IS NULL) OR (p_doc_type NOT IN ('SR', 'SA'))) THEN
           RAISE invalid_doc_type;
        END IF;

        IF ((p_action_type IS NULL) OR (p_action_type NOT IN ('A', 'D'))) THEN
           RAISE invalid_action_type;
        END IF;

        IF ((p_doc_direction IS NULL) OR (p_doc_direction NOT IN ('I', 'O'))) THEN
           RAISE invalid_Doc_direction;
        END IF;

      END IF; --}

      IF l_debug_on THEN
        wsh_debug_sv.logmsg(l_module_name, 'Valid parameters for Validate Document');
      END IF;
	/* Derive Trading_Partner_Id based on Trading_Partner_code */

      BEGIN
        -- performance repository bug 4891939
        -- replace org_organization_definitions with mtl_parameters and
        --                                           hr_organization_information
        -- LSP PROJECT : get party_id value for the given client_id(cust_accnt_id)
           IF (p_client_code IS NULL) THEN
           --{
             SELECT mp.organization_id
             INTO x_trading_partner_ID
             FROM mtl_parameters mp, hr_organization_information hoi
             WHERE mp.organization_id = hoi.organization_id and
                  hoi.org_information1 = 'INV' and
                  hoi.org_information2 = 'Y' and
                  hoi.org_information_context = 'CLASS' and
                  mp.organization_code = p_trading_partner_Code;
           --}
           END IF;

      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	     --
             IF l_debug_on THEN
   	      wsh_debug_sv.logmsg(l_module_name, 'Inside No Data Found Exception to Derive TP ID');
             END IF;
   	     --
	     RAISE FND_API.G_EXC_ERROR;
	     --
	WHEN TOO_MANY_ROWS THEN
	     --
             IF l_debug_on THEN
   	      wsh_debug_sv.logmsg (l_module_name, 'Inside Too many rows Exception to derive TP ID');
             END IF;
   	     --
	     RAISE FND_API.G_EXC_ERROR;
      END;

      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'Derived TP ID successfully', x_trading_partner_ID);
      END IF;

      /* Check if the current record is a duplicate */
      BEGIN
         SELECT 'X'
           INTO p_duplicate
           FROM wsh_transactions_history wth
          WHERE wth.document_type      = p_doc_type
            AND wth.document_number    = p_doc_number
            AND wth.action_type        = p_action_type
            AND wth.trading_partner_id = x_trading_partner_id
            --R12.1.1 STANDALONE PROJECT
            -- LSP PROJECT : consider LSP mode also by checking the profile as well as client_code value on WNDI.
            AND ((l_wms_deployment_mode <> 'D' AND l_wms_deployment_mode <> 'L') OR ((l_wms_deployment_mode = 'D' AND wth.document_revision = p_doc_revision))
                  OR (l_wms_deployment_mode = 'L' AND wth.document_revision = p_doc_revision AND p_client_code IS NOT NULL))
            AND wth.document_direction = p_doc_direction;

         IF (p_duplicate = 'X')
         THEN
	    --
            IF l_debug_on THEN
	       wsh_debug_sv.log(l_module_name, 'EXCEPTION: Found duplicate', p_duplicate);
            END IF;
	    RAISE FND_API.G_EXC_ERROR;
	    --
         END IF;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
	    --
            x_return_status := wsh_util_core.g_ret_sts_success;
            x_valid_doc := fnd_api.g_true;
	    --
         WHEN TOO_MANY_ROWS THEN
	    --
	    IF l_debug_on THEN
	      wsh_debug_sv.logmsg(l_module_name, 'EXCEPTION: Too many rows when checking for duplicates');
	    END IF;
	    --
	    RAISE FND_API.G_EXC_ERROR;
	    --
      END;

      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'After checking for duplicates, x_return_status', X_Return_Status);
      END IF;

      IF (p_doc_type = 'SR') THEN --{

         IF p_action_type = 'D' THEN

            /* Check if the Corresponding 940 Add exists when a 940 Cancellation comes in */

            BEGIN
               -- R12.1.1 STANDALONE PROJECT
               IF (l_wms_deployment_mode = 'D' OR (l_wms_deployment_mode = 'L' AND p_client_code IS NOT NULL))  THEN ----{ LSP PROJECT : consider LSP mode also

               SELECT 'X'
                 INTO p_940_exists
                 FROM wsh_transactions_history
                WHERE document_number = p_doc_number
                  AND document_type = 'SR'
                  AND document_direction = 'I'
                  AND action_type in ('A', 'C')
                  AND rownum = 1;
               ELSE
               SELECT 'X'
                 INTO p_940_exists
                 FROM wsh_transactions_history
                WHERE document_number = p_orig_document_number
                  AND document_type = 'SR'
                  AND document_direction = 'I'
                  AND action_type = 'A';
               END IF;

               IF (p_940_exists = 'X')
               THEN
                  x_return_status := wsh_util_core.g_ret_sts_success;
                  x_valid_doc := fnd_api.g_true;
                  IF l_debug_on THEN
                   wsh_debug_sv.log(l_module_name, '940 Add Exists for the 940 Cancellation sent, Return Status',X_Return_Status );
                  END IF;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  IF l_debug_on THEN
		   WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION: No corresponding 940-Add exists');
		  END IF;
		  --
	          RAISE FND_API.G_EXC_ERROR;
            END;
         END IF; -- End of If (P_ACTION_TYPE = 'D') Then

        IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name, 'Return Status after checking for 940 Add Exists when 940 Cancellation. Return Status', X_Return_Status );
        END IF;

      ELSIF (p_doc_type = 'SA')  THEN --} {

        IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name, 'Before checking for 940 out when 945 comes in, x_return_status ',x_return_status );
        END IF;

         /* Check if the Corresponding 940 Out exists when a 945 Comes in */
         BEGIN
              SELECT 'X'
              INTO p_940_exists
              FROM wsh_transactions_history
              WHERE document_number = p_orig_document_number
              AND document_type = 'SR'
              AND document_direction = 'O'
              AND action_type = 'A';

            IF (p_940_exists = 'X')
            THEN
               x_return_status := wsh_util_core.g_ret_sts_success;
               x_valid_doc := fnd_api.g_true;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
		--
                IF l_debug_on THEN
		 wsh_debug_sv.logmsg(l_module_name, 'EXCEPTION: No data found when checking for 940-O when
							945-IN comes in');
		END IF;
	 	--
		RAISE FND_API.G_EXC_ERROR;
		--
         END;
      END IF; -- }

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Return Status from Validate Document', X_Return_Status );
       wsh_debug_sv.pop (l_module_name);
      END IF;

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
	--
	x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
	x_Valid_Doc     := FND_API.G_FALSE;
	--
	IF l_debug_on THEN
	 --
         WSH_DEBUG_SV.log(l_module_name, 'x_return_Status from Validate Document',X_Return_Status );
	 WSH_DEBUG_SV.log(l_module_name, 'x_valid_doc', x_Valid_Doc);
	 WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured',
				WSH_DEBUG_SV.C_EXCEP_LEVEL);
	 WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
         --
	END IF;
	--
      WHEN invalid_doc_number
      THEN
         x_return_status := wsh_util_core.g_ret_sts_error;
         x_valid_doc := fnd_api.g_false;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'invalid_doc_number exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_doc_number');
         END IF;
          --R12.1.1 STANDALONE PROJECT
      WHEN invalid_doc_revision
      THEN
         x_return_status := wsh_util_core.g_ret_sts_error;
         x_valid_doc := fnd_api.g_false;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'invalid_doc_revision exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_doc_revision');
         END IF;
      WHEN invalid_tp
      THEN
         x_return_status := wsh_util_core.g_ret_sts_error;
         x_valid_doc := fnd_api.g_false;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'invalid_tp exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_tp');
         END IF;
      WHEN invalid_doc_direction
      THEN
         x_return_status := wsh_util_core.g_ret_sts_error;
         x_valid_doc := fnd_api.g_false;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'invalid_doc_direction exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_doc_direction');
         END IF;
      WHEN invalid_doc_type
      THEN
         x_return_status := wsh_util_core.g_ret_sts_error;
         x_valid_doc := fnd_api.g_false;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'invalid_doc_type exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_doc_type');
         END IF;
      WHEN invalid_action_type
      THEN
         x_return_status := wsh_util_core.g_ret_sts_error;
         x_valid_doc := fnd_api.g_false;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'invalid_action_type exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_action_type');
         END IF;
      WHEN OTHERS
      THEN
         x_return_status := wsh_util_core.g_ret_sts_unexp_error;
         x_valid_doc := fnd_api.g_false;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
   END validate_document;

   -- LSP PROJECT : API returns client Code associated to the given
   -- party id and party site id values. It also returns item delimiter
   -- value. This api is being called from XML gateway inbound mapping.
   PROCEDURE Get_Client_details (
      P_trading_partner_id      IN         NUMBER,
      P_trading_partner_site_id IN         NUMBER,
      P_trading_partner_type    OUT NOCOPY VARCHAR2,
      P_client_code             OUT NOCOPY VARCHAR2,
      P_item_delimiter          OUT NOCOPY VARCHAR2,
      X_return_status           OUT NOCOPY VARCHAR2
   )
   IS
      --
      l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CLIENT_DETAILS';
      --
   BEGIN
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name, 'GET_CLIENT_DETAILS');
      wsh_debug_sv.log (l_module_name, 'P_trading_partner_id', P_trading_partner_id);
      wsh_debug_sv.log (l_module_name, 'P_trading_partner_site_id', P_trading_partner_site_id);
     --
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    BEGIN
      SELECT party_type
      INTO   P_trading_partner_type
      FROM   ecx_tp_headers
      WHERE  party_id      = P_trading_partner_id
        AND  party_site_id = P_trading_partner_site_id;

      IF P_trading_partner_type = 'C' AND WMS_DEPLOY.WMS_DEPLOYMENT_MODE = 'L' THEN
      --
        SELECT client_code
        INTO p_client_code
        FROM
          mtl_client_parameters
        WHERE trading_partner_site_id = P_trading_partner_site_id;
      --
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF l_debug_on THEN
	  WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION: No corresponding client exists');
  	END IF;
	--
        RAISE FND_API.G_EXC_ERROR;
    END;
    --
    -- Call inventory API to get the item delimiter..
    IF p_client_code IS NOT NULL THEN
      IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, 'Calling api WMS_DEPLOY.GET_ITEM_FLEX_DELIMITER', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      P_item_delimiter := wms_deploy.get_item_flex_delimiter;
    END IF;
    --
    --
    IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name, 'P_trading_partner_type', P_trading_partner_type);
      wsh_debug_sv.log (l_module_name, 'p_client_code', p_client_code);
      wsh_debug_sv.log (l_module_name, 'P_item_delimiter', P_item_delimiter);
      wsh_debug_sv.log (l_module_name, 'Return Status', x_return_Status );
      wsh_debug_sv.pop (l_module_name);
    END IF;
    --
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	--
	x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
	--
	IF l_debug_on THEN
	 --
         WSH_DEBUG_SV.log(l_module_name, 'x_return_Status from Get_Client_details',X_Return_Status );
	 WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured',
				WSH_DEBUG_SV.C_EXCEP_LEVEL);
	 WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
         --
	END IF;
	--
    WHEN OTHERS THEN
         x_return_status := wsh_util_core.g_ret_sts_unexp_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
   END Get_Client_details;

/*==============================================================================

PROCEDURE NAME: Validate_Deliveries

This Procedure is called from the Wsh_Inbound_Ship_Advice_Pkg.Process_Ship_Advice,
after data is populated into the interface tables.

This Procedure checks if the Delivery and Delivery Details received in the 945,
exists in the Supplier Instance base tables.

==============================================================================*/

   PROCEDURE validate_deliveries (
      p_delivery_id     IN       NUMBER,
      x_return_status   OUT NOCOPY       VARCHAR2
   )
   IS
      x_delivery_exists            VARCHAR2 (1);
      x_delivery_detail_exists     VARCHAR2 (1);
      invalid_delivery_id          EXCEPTION;
      invalid_delivery_detail_id   EXCEPTION;

      CURSOR delivery_detail_int_cur (p_delivery_id NUMBER)
      IS
         SELECT DISTINCT wdd.delivery_detail_id
                    FROM wsh_del_details_interface wdd,
                         wsh_del_assgn_interface wda
                   WHERE wdd.delivery_detail_interface_id = wda.delivery_detail_interface_id
                     AND wdd.container_flag = 'N'
                     AND wda.delivery_id = p_delivery_id
                     AND wda.interface_action_code = '94X_INBOUND'
		     AND wdd.interface_action_code = '94X_INBOUND';
                     --
l_debug_on BOOLEAN;
                     --
                     l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_DELIVERIES';
                     --
   BEGIN
     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     --
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name, 'VALIDATE_DELIVERIES');
      wsh_debug_sv.log (l_module_name, 'DELIVERY ID', p_delivery_id);
     END IF;

      /* Check if the Delivery ID from Interface table exists in WSH_NEW_DELIVERIES Table */

      IF (p_delivery_id IS NOT NULL)
      THEN
         BEGIN
              SELECT 'X'
              INTO x_delivery_exists
              FROM wsh_new_deliveries
              WHERE delivery_id = p_delivery_id;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RAISE invalid_delivery_id;
         END;

        IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name, 'Valid parameters for Validate Deliveries. Return Status : ',X_Return_Status );
        END IF;

         /* If the Delivery exists in WSH_New_Deliveries, Get the corresponding Delivery_Detail_IDs
         from the interface tables and check if they exist in the base tables, and if they are assigned
         to the same delivery */

         IF (x_delivery_exists = 'X')
         THEN
            BEGIN
               FOR delivery_detail_int_rec IN delivery_detail_int_cur (p_delivery_id) LOOP
                  BEGIN
                     SELECT 'X'
                       INTO x_delivery_detail_exists
                       FROM wsh_delivery_details wdd,
                            wsh_delivery_assignments_v wda
                      WHERE wdd.delivery_detail_id = wda.delivery_detail_id
                        AND wdd.delivery_detail_id = delivery_detail_int_rec.delivery_detail_id
                        AND wda.delivery_id = p_delivery_id;

                     x_return_status := wsh_util_core.g_ret_sts_success;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        RAISE invalid_delivery_detail_id;
                  END; -- End of Begin
               END LOOP; -- End of For Delivery ....
            END;
         END IF; -- End of if X_Delivery_Exists

      ELSIF (p_delivery_id IS NULL) THEN
         x_return_status := wsh_util_core.g_ret_sts_error;
      END IF; -- if p_delivery_id is null

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name,'940 Add Exists for the 940 Cancellation sent. Return Status',X_Return_Status );
       wsh_debug_sv.pop (l_module_name);
      END IF;
   EXCEPTION
      WHEN invalid_delivery_id
      THEN
         x_return_status := wsh_util_core.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'invalid_delivery_id exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_delivery_id');
         END IF;
      WHEN invalid_delivery_detail_id
      THEN
         x_return_status := wsh_util_core.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'invalid_delivery_detail_id exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_delivery_detail_id');
         END IF;
      WHEN OTHERS
      THEN
         x_return_status := wsh_util_core.g_ret_sts_unexp_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
   END validate_deliveries;

-- TPW - Distributed Organization Changes
/*==============================================================================

PROCEDURE NAME: Validate_Delivery_Details

This Procedure is called from the Wsh_Inbound_Ship_Advice_Pkg.Process_Ship_Advice,
after data is populated into the interface tables.

This Procedure checks if the Delivery Details received in the 945,
exists in the Supplier Instance base tables (for Batch based shipment request).

==============================================================================*/

   PROCEDURE validate_delivery_details (
      p_delivery_interface_id IN         NUMBER,
      x_return_status         OUT NOCOPY VARCHAR2
   )
   IS
      l_delivery_detail_exists     VARCHAR2 (1);
      invalid_delivery_detail_id   EXCEPTION;

      CURSOR delivery_detail_int_cur (p_delivery_id NUMBER)
      IS
         SELECT DISTINCT wdd.source_header_number, wdd.delivery_detail_id, wdd.line_direction
                    FROM wsh_del_details_interface wdd,
                         wsh_del_assgn_interface wda
                   WHERE wdd.delivery_detail_interface_id = wda.delivery_detail_interface_id
                     AND wdd.container_flag <> 'Y'
                     AND wda.delivery_interface_id = p_delivery_interface_id
                     AND wda.interface_action_code = '94X_INBOUND'
		     AND wdd.interface_action_code = '94X_INBOUND';
      --
      l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_DELIVERY_DETAILS';
      --
   BEGIN
      --
      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      --
      IF l_debug_on IS NULL
      THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      --
      IF l_debug_on THEN
       wsh_debug_sv.push (l_module_name, 'VALIDATE_DELIVERY_DETAILS');
       wsh_debug_sv.log (l_module_name, 'DELIVERY INTERFACE ID', p_delivery_interface_id);
      END IF;


      IF (p_delivery_interface_id IS NOT NULL)
      THEN
               FOR delivery_detail_int_rec IN delivery_detail_int_cur (p_delivery_interface_id) LOOP
                  BEGIN
                     IF (delivery_detail_int_rec.line_direction = 'IO') THEN
                        SELECT distinct 'X'
                          INTO l_delivery_detail_exists
                          FROM wsh_delivery_details wdd,
                               wsh_delivery_assignments wda,
                               oe_order_lines_all ol,
                               po_requisition_lines_all pl,
                               po_requisition_headers_all ph
                         WHERE wdd.delivery_detail_id = wda.delivery_detail_id
                           AND wdd.released_status in ('R','B','X')
                           AND wdd.source_code = 'OE'
                           AND wdd.source_line_id = ol.line_id
                           AND ol.source_document_line_id = pl.requisition_line_id
                           AND ol.source_document_id = pl.requisition_header_id
                           AND pl.requisition_header_id = ph.requisition_header_id
                           AND pl.line_num = delivery_detail_int_rec.delivery_detail_id
                           AND ph.segment1 = delivery_detail_int_rec.source_header_number;
                     ELSE
                        SELECT distinct 'X'
                          INTO l_delivery_detail_exists
                          FROM wsh_delivery_details wdd,
                               wsh_delivery_assignments wda,
                               wsh_shipment_batches wsb,
                               wsh_transactions_history wth
                         WHERE wdd.delivery_detail_id = wda.delivery_detail_id
                           AND wdd.shipment_line_number = delivery_detail_int_rec.delivery_detail_id
                           AND wdd.released_status in ('R','B')
                           AND wdd.source_code = 'OE'
                           AND wdd.shipment_batch_id = wsb.batch_id
                           AND wsb.name = wth.entity_number
                           AND wth.document_number = delivery_detail_int_rec.source_header_number
                           AND wth.entity_type = 'BATCH'
                           AND wth.document_type = 'SR'
                           AND wth.document_direction = 'O';
                     END IF;

                     x_return_status := wsh_util_core.g_ret_sts_success;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        RAISE invalid_delivery_detail_id;
                  END; -- End of Begin
               END LOOP;

      ELSIF (p_delivery_interface_id IS NULL) THEN
         x_return_status := wsh_util_core.g_ret_sts_error;
      END IF; -- if p_delivery_interface_id is null

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name,'Return Status',X_Return_Status );
       wsh_debug_sv.pop (l_module_name);
      END IF;
   EXCEPTION
      WHEN invalid_delivery_detail_id
      THEN
         x_return_status := wsh_util_core.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'invalid_delivery_detail_id exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_delivery_detail_id');
         END IF;
      WHEN OTHERS
      THEN
         x_return_status := wsh_util_core.g_ret_sts_unexp_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
   END validate_delivery_details;

/*==============================================================================

PROCEDURE NAME: Compare_Ship_Request_Advice

This Procedure is called from the Wsh_Inbound_Ship_Advice_Pkg.Process_Ship_Advice,
after data is populated into the interface tables.

This Procedure checks if the key data elements like Ship To, Inventory Item ID etc
have been modified by Third Party Warehouse.

==============================================================================*/

   PROCEDURE compare_ship_request_advice (
      p_delivery_id     IN       NUMBER,
      x_return_status   OUT NOCOPY       VARCHAR2
   )
   IS
      CURSOR delivery_cur
      IS
         SELECT customer_id, initial_pickup_location_id,
                intmed_ship_to_location_id, organization_id,
                ultimate_dropoff_location_id
           FROM wsh_new_deliveries
          WHERE delivery_id = p_delivery_id;

      CURSOR delivery_detail_cur (p_delivery_detail_id NUMBER)
      IS
         SELECT DISTINCT delivery_detail_id, customer_id, customer_item_id,
                deliver_to_location_id, intmed_ship_to_location_id,
                inventory_item_id, organization_id, ship_from_location_id,
                ship_to_location_id
           FROM wsh_delivery_details
          WHERE delivery_detail_id = p_delivery_detail_id;

      CURSOR delivery_int_cur
      IS
         SELECT customer_id, initial_pickup_location_id,
                intmed_ship_to_location_id, organization_id,
                ultimate_dropoff_location_id
           FROM wsh_new_del_interface
          WHERE delivery_id = p_delivery_id
             AND INTERFACE_ACTION_CODE ='94X_INBOUND';

      CURSOR delivery_detail_int_cur (p_delivery_id NUMBER)
      IS
         SELECT DISTINCT wdd.delivery_detail_id, wdd.customer_id, wdd.customer_item_id,
                wdd.deliver_to_location_id, wdd.intmed_ship_to_location_id,
                wdd.inventory_item_id, wdd.organization_id,
                wdd.ship_from_location_id, wdd.ship_to_location_id
           FROM wsh_del_assgn_interface wda, wsh_del_details_interface wdd
          WHERE wda.delivery_id = p_delivery_id
            AND wda.delivery_detail_interface_id = wdd.delivery_detail_interface_id
            AND wdd.container_flag = 'N'
            AND WDD.INTERFACE_ACTION_CODE = '94X_INBOUND'
            AND WDA.INTERFACE_ACTION_CODE ='94X_INBOUND';

      delivery              delivery_cur%ROWTYPE;
      delivery_int          delivery_cur%ROWTYPE;
      delivery_detail_int   delivery_detail_cur%ROWTYPE;
      invalid_delivery      EXCEPTION;
      data_changed          EXCEPTION;
      --
l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'COMPARE_SHIP_REQUEST_ADVICE';
      --
   BEGIN
     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     --
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name, 'Compare Ship Request Advice');
      wsh_debug_sv.log (l_module_name, 'DELIVERY ID', p_delivery_id);
     END IF;

      BEGIN
         IF (p_delivery_id IS NOT NULL) THEN
            OPEN delivery_cur;
            FETCH delivery_cur INTO delivery;

            IF (delivery_cur%NOTFOUND) THEN
               RAISE invalid_delivery;
            END IF;

            OPEN delivery_int_cur;
            FETCH delivery_int_cur INTO delivery_int;

            IF (delivery_int_cur%NOTFOUND)
            THEN
               RAISE invalid_delivery;
            END IF;

           IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name, 'Valid values for Compare Ship Request Advice');
           END IF;

            /* Compare values of the Delivery */

            IF    (NVL (delivery.customer_id, 0) <> NVL (delivery_int.customer_id, 0))
               OR (NVL (delivery.initial_pickup_location_id, 0) <> NVL (delivery_int.initial_pickup_location_id, 0))
               OR (NVL (delivery.intmed_ship_to_location_id, 0) <> NVL (delivery_int.intmed_ship_to_location_id, 0))
               OR (NVL (delivery.organization_id, 0) <> NVL (delivery_int.organization_id, 0))
               OR (NVL (delivery.ultimate_dropoff_location_id, 0) <> NVL (delivery_int.ultimate_dropoff_location_id, 0))
            THEN
               RAISE data_changed;
            ELSE

             IF l_debug_on THEN
              wsh_debug_sv.log (l_module_name, 'Compare Ship Request. Data Did Not Change for Delivery');
             END IF;

               /* Compare values of the Delivery Details */

               FOR delivery_detail_int IN delivery_detail_int_cur (p_delivery_id)
               LOOP
                 IF l_debug_on THEN
                  wsh_debug_sv.log (l_module_name, 'Delivery Detail Interface ID ',delivery_detail_int.delivery_detail_id);
                 END IF;
                  FOR delivery_detail IN delivery_detail_cur (delivery_detail_int.delivery_detail_id)
                  LOOP
                    IF l_debug_on THEN
                     wsh_debug_sv.log (l_module_name, 'Delivery Detail ID ',delivery_detail.delivery_detail_id);
                    END IF;

                     IF    (NVL (delivery_detail.customer_id, 0) <> NVL (delivery_detail_int.customer_id, 0))
                        OR (NVL (delivery_detail.customer_item_id, 0) <> NVL (delivery_detail_int.customer_item_id, 0))
                        OR (NVL (delivery_detail.deliver_to_location_id, 0) <> NVL (delivery_detail_int.deliver_to_location_id, 0))
                        OR (NVL (delivery_detail.intmed_ship_to_location_id, 0) <> NVL (delivery_detail_int.intmed_ship_to_location_id, 0))
                        OR (NVL (delivery_detail.inventory_item_id, 0) <> NVL (delivery_detail_int.inventory_item_id, 0))
                        OR (NVL (delivery_detail.organization_id, 0) <> NVL (delivery_detail_int.organization_id, 0))
                        OR (NVL (delivery_detail.ship_from_location_id, 0) <> NVL (delivery_detail_int.ship_from_location_id, 0))
                        OR (NVL (delivery_detail.ship_to_location_id, 0) <> NVL (delivery_detail_int.ship_to_location_id, 0))
                     THEN
                        RAISE data_changed;
                     ELSE
                       IF l_debug_on THEN
                        wsh_debug_sv.log (l_module_name, 'Compare Ship Request. Data Did Not Change for Delivery Details');
                       END IF;

                        x_return_status := wsh_util_core.g_ret_sts_success;
                     END IF; -- if delivery_detail checks
                  END LOOP;
               END LOOP;
            END IF; -- if delivery checks

            IF (delivery_int_cur%ISOPEN)
            THEN
               CLOSE delivery_int_cur;
            END IF;

            IF (delivery_cur%ISOPEN)
            THEN
               CLOSE delivery_cur;
            END IF;

            IF (delivery_detail_int_cur%ISOPEN)
            THEN
               CLOSE delivery_detail_int_cur;
            END IF;
         ELSIF p_delivery_id IS NULL
         THEN
            RAISE invalid_delivery;
         END IF; -- if p_delivery_id is not null

        IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name, 'Compare Ship Request. Return Status :'||X_Return_Status);
 	 wsh_debug_sv.pop (l_module_name);
        END IF;

      EXCEPTION
         WHEN invalid_delivery
         THEN
            x_return_status := wsh_util_core.g_ret_sts_error;
            IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'invalid_delivery exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_delivery');
            END IF;
         WHEN data_changed
         THEN
            x_return_status := wsh_util_core.g_ret_sts_error;
            IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'data_changed exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:data_changed');
            END IF;
         WHEN OTHERS
         THEN
            x_return_status := wsh_util_core.g_ret_sts_unexp_error;
            IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
            END IF;
      END;

   END compare_ship_request_advice;


/*==============================================================================

PROCEDURE NAME: Log_Interface_Errors

This Procedure is called from various procedure whenever an error is detected in
the data elements.

This Procedure accepts upto 6 different tokens and Values Concatenates and stores
the resulting message text in WSH_INTERFACE_ERRORS table.
==============================================================================*/

   PROCEDURE log_interface_errors (
      p_interface_errors_rec   IN       interface_errors_rec_type,
      p_msg_data               IN       VARCHAR2 DEFAULT NULL,
      p_api_name               IN       VARCHAR2,
      x_return_status          OUT NOCOPY       VARCHAR2
   )
   IS
      pragma AUTONOMOUS_TRANSACTION;
      invalid_parameters   EXCEPTION;
      l_text               VARCHAR2 (4000);
      l_text_token         VARCHAR2 (4000);
      l_msg_count          NUMBER;
      l_msg_data           VARCHAR2(4000);
      l_msg_details        VARCHAR2(4000);
      --
l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOG_INTERFACE_ERRORS';
      --
   BEGIN
       --
       l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
       --
       IF l_debug_on IS NULL
       THEN
           l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
       END IF;
       --
       IF l_debug_on THEN
	wsh_debug_sv.push(l_module_name, 'Log_Interface_Errors');
	wsh_debug_sv.log (l_module_name, 'Interface table name', p_interface_errors_rec.p_interface_table_name);
	wsh_debug_sv.log (l_module_name, 'Interface Id', p_interface_errors_rec.p_interface_id);
	wsh_debug_sv.log (l_module_name, 'Message Name', p_interface_errors_rec.p_message_name);
       END IF;

      IF (p_msg_data IS NULL) THEN
        wsh_util_core.get_messages('Y', l_msg_data, l_msg_details, l_msg_count);

        IF (l_msg_data IS NULL) THEN
           fnd_message.set_name ('WSH', 'WSH_ERROR_IN_API');
           fnd_message.set_token ('API_NAME',p_api_name);
           l_text := fnd_message.get;
        ELSE
           IF (l_msg_count >1 ) THEN
              l_text := l_msg_details;
           ELSE
              l_text := l_msg_data;
           END IF;
        END IF;

      ELSE
         l_text := p_msg_data;
      END IF;


      IF (p_interface_errors_rec.p_interface_table_name IS NOT NULL)
          AND (p_interface_errors_rec.p_interface_id IS NOT NULL) THEN

          IF l_debug_on THEN
	   wsh_debug_sv.log (l_module_name, 'Log Interface Errors. Valid Parameters');
          END IF;

        IF (p_interface_errors_rec.p_message_name IS NOT NULL) THEN
         -- Build the Error message string.
         fnd_message.set_name ('WSH', p_interface_errors_rec.p_message_name);

         -- Replace the tokens with Values.
         IF (p_interface_errors_rec.p_token1 IS NOT NULL)
         THEN
            fnd_message.set_token (p_interface_errors_rec.p_token1,p_interface_errors_rec.p_value1);
         END IF;

         IF (p_interface_errors_rec.p_token2 IS NOT NULL)
         THEN
            fnd_message.set_token (p_interface_errors_rec.p_token2,p_interface_errors_rec.p_value2);
         END IF;

         IF (p_interface_errors_rec.p_token3 IS NOT NULL)
         THEN
            fnd_message.set_token (p_interface_errors_rec.p_token3,p_interface_errors_rec.p_value3);
         END IF;

         IF (p_interface_errors_rec.p_token4 IS NOT NULL)
         THEN
            fnd_message.set_token (p_interface_errors_rec.p_token4,p_interface_errors_rec.p_value4);
         END IF;

         IF (p_interface_errors_rec.p_token5 IS NOT NULL)
         THEN
            fnd_message.set_token (p_interface_errors_rec.p_token5,p_interface_errors_rec.p_value5);
         END IF;

         IF (p_interface_errors_rec.p_token6 IS NOT NULL)
         THEN
            fnd_message.set_token (p_interface_errors_rec.p_token6,p_interface_errors_rec.p_value6);
         END IF;

         IF (p_interface_errors_rec.p_token7 IS NOT NULL)
         THEN
            fnd_message.set_token (p_interface_errors_rec.p_token7,p_interface_errors_rec.p_value7);
         END IF;

         IF (p_interface_errors_rec.p_token8 IS NOT NULL)
         THEN
            fnd_message.set_token (p_interface_errors_rec.p_token8,p_interface_errors_rec.p_value8);
         END IF;

         IF (p_interface_errors_rec.p_token9 IS NOT NULL)
         THEN
            fnd_message.set_token (p_interface_errors_rec.p_token9,p_interface_errors_rec.p_value9);
         END IF;

         IF (p_interface_errors_rec.p_token10 IS NOT NULL)
         THEN
            fnd_message.set_token (p_interface_errors_rec.p_token10,p_interface_errors_rec.p_value10);
         END IF;

         IF (p_interface_errors_rec.p_token11 IS NOT NULL)
         THEN
            fnd_message.set_token (p_interface_errors_rec.p_token11,p_interface_errors_rec.p_value11);
         END IF;

         --Retrieve the error message.
          l_text_token :=   fnd_message.get;

	END IF; -- if p_message_name is not null


        IF (l_text_token IS NOT NULL) THEN
          IF ( length(l_text)+length(l_text_token) < 3997 ) THEN
             l_text := l_text ||' , '||l_text_token;
          END IF;
        END IF;


      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Text: ', l_text);
      END IF;
        -- Insert error record in WSH_Interface_errors table.
	-- We need the check for l_text because the column error_message
	-- is a Not_Null column.

	IF (l_text IS NOT NULL) THEN
         IF l_debug_on THEN
	  wsh_debug_sv.log (l_module_name, 'Error Message', l_text);
	  wsh_debug_sv.log (l_module_name, 'Inserting into wsh_interface_errors');
         END IF;

         INSERT INTO wsh_interface_errors
                     (interface_error_id,
                      interface_table_name,
                      interface_id, error_message, creation_date,
                      created_by, last_update_date, last_updated_by,
                      last_update_login,INTERFACE_ACTION_CODE)
              VALUES (wsh_interface_errors_s.NEXTVAL,
                      p_interface_errors_rec.p_interface_table_name,
                      p_interface_errors_rec.p_interface_id, l_text, SYSDATE,
                      fnd_global.user_id, SYSDATE, fnd_global.user_id,
                      fnd_global.user_id,'94X_INBOUND');

         COMMIT;

	ELSE
               IF l_debug_on THEN
		wsh_debug_sv.log (l_module_name, 'Text for error_message is null');
               END IF;
	END IF; -- if l_text is not null
         x_return_status := wsh_util_core.g_ret_sts_success;
      ELSE
         RAISE invalid_parameters;
      END IF;

     IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name, 'Log Interface Errors. Return Status. :'||X_Return_Status);
      wsh_debug_sv.pop (l_module_name);
     END IF;
   EXCEPTION
      WHEN invalid_parameters
      THEN
         x_return_status := wsh_util_core.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
         END IF;
      WHEN OTHERS
      THEN
         x_return_status := wsh_util_core.g_ret_sts_unexp_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;

   END log_interface_errors;

 --R12.1.1 STANDALONE PROJECT
/*==============================================================================

PROCEDURE NAME: Log_Interface_Errors (Overloaded)

This Procedure is called from various procedure whenever an error is detected in
the data elements.

==============================================================================*/

   PROCEDURE log_interface_errors (
      p_interface_errors_rec_tab IN         interface_errors_rec_tab,
      p_interface_action_code    IN         VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2
   )
   IS
      pragma AUTONOMOUS_TRANSACTION;
      invalid_parameters   EXCEPTION;
      l_text               VARCHAR2 (2000);
      TYPE varchar30_Tab_Type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
      TYPE varchar2000_Tab_Type IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
      l_interface_errors_rec_tab interface_errors_rec_tab;
      l_interface_table_name_tab varchar30_Tab_Type;
      l_interface_id_tab wsh_util_core.Id_Tab_Type;
      l_text_tab varchar2000_Tab_Type;
      --
      l_debug_on BOOLEAN;
      --
      l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOG_INTERFACE_ERRORS';
      --
   BEGIN
       --
       l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
       --
       IF l_debug_on IS NULL
       THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
       END IF;
       --
       IF l_debug_on THEN
         wsh_debug_sv.push(l_module_name, 'Log_Interface_Errors');
	 wsh_debug_sv.log (l_module_name, 'Message Count', p_interface_errors_rec_tab.COUNT);
	 wsh_debug_sv.log (l_module_name, 'Interface Action Code', p_interface_action_code);
       END IF;

       x_return_status := wsh_util_core.g_ret_sts_success;

       IF (p_interface_errors_rec_tab.COUNT > 0) THEN
          FOR i in p_interface_errors_rec_tab.FIRST..p_interface_errors_rec_tab.LAST LOOP --{

             IF (p_interface_errors_rec_tab(i).p_interface_table_name IS NOT NULL)
                AND (p_interface_errors_rec_tab(i).p_interface_id IS NOT NULL) THEN

              IF (p_interface_errors_rec_tab(i).p_text is NOT NULL) THEN -- {

                 l_interface_table_name_tab(l_interface_table_name_tab.COUNT+1) := p_interface_errors_rec_tab(i).p_interface_table_name;
                 l_interface_id_tab(l_interface_id_tab.COUNT+1) := p_interface_errors_rec_tab(i).p_interface_id;
                 l_text_tab(l_text_tab.COUNT+1) := p_interface_errors_rec_tab(i).p_text;

              ELSIF (p_interface_errors_rec_tab(i).p_message_name IS NOT NULL) THEN
                 -- Build the Error message string.
                 fnd_message.set_name ('WSH', p_interface_errors_rec_tab(i).p_message_name);

                 -- Replace the tokens with Values.
                 IF (p_interface_errors_rec_tab(i).p_token1 IS NOT NULL)
                 THEN
                    fnd_message.set_token (p_interface_errors_rec_tab(i).p_token1,p_interface_errors_rec_tab(i).p_value1);
                 END IF;

                 IF (p_interface_errors_rec_tab(i).p_token2 IS NOT NULL)
                 THEN
                    fnd_message.set_token (p_interface_errors_rec_tab(i).p_token2,p_interface_errors_rec_tab(i).p_value2);
                 END IF;

                 IF (p_interface_errors_rec_tab(i).p_token3 IS NOT NULL)
                 THEN
                    fnd_message.set_token (p_interface_errors_rec_tab(i).p_token3,p_interface_errors_rec_tab(i).p_value3);
                 END IF;

                 IF (p_interface_errors_rec_tab(i).p_token4 IS NOT NULL)
                 THEN
                    fnd_message.set_token (p_interface_errors_rec_tab(i).p_token4,p_interface_errors_rec_tab(i).p_value4);
                 END IF;

                 IF (p_interface_errors_rec_tab(i).p_token5 IS NOT NULL)
                 THEN
                    fnd_message.set_token (p_interface_errors_rec_tab(i).p_token5,p_interface_errors_rec_tab(i).p_value5);
                 END IF;

                 IF (p_interface_errors_rec_tab(i).p_token6 IS NOT NULL)
                 THEN
                    fnd_message.set_token (p_interface_errors_rec_tab(i).p_token6,p_interface_errors_rec_tab(i).p_value6);
                 END IF;

                 IF (p_interface_errors_rec_tab(i).p_token7 IS NOT NULL)
                 THEN
                    fnd_message.set_token (p_interface_errors_rec_tab(i).p_token7,p_interface_errors_rec_tab(i).p_value7);
                 END IF;

                 IF (p_interface_errors_rec_tab(i).p_token8 IS NOT NULL)
                 THEN
                    fnd_message.set_token (p_interface_errors_rec_tab(i).p_token8,p_interface_errors_rec_tab(i).p_value8);
                 END IF;

                 IF (p_interface_errors_rec_tab(i).p_token9 IS NOT NULL)
                 THEN
                    fnd_message.set_token (p_interface_errors_rec_tab(i).p_token9,p_interface_errors_rec_tab(i).p_value9);
                 END IF;

                 IF (p_interface_errors_rec_tab(i).p_token10 IS NOT NULL)
                 THEN
                    fnd_message.set_token (p_interface_errors_rec_tab(i).p_token10,p_interface_errors_rec_tab(i).p_value10);
                 END IF;

                 IF (p_interface_errors_rec_tab(i).p_token11 IS NOT NULL)
                 THEN
                    fnd_message.set_token (p_interface_errors_rec_tab(i).p_token11,p_interface_errors_rec_tab(i).p_value11);
                 END IF;

                 --Retrieve the error message.
                 l_text := fnd_message.get;
                 IF (l_text IS NOT NULL) THEN
                   l_interface_table_name_tab(l_interface_table_name_tab.COUNT+1) := p_interface_errors_rec_tab(i).p_interface_table_name;
                   l_interface_id_tab(l_interface_id_tab.COUNT+1) := p_interface_errors_rec_tab(i).p_interface_id;
                   l_text_tab(l_text_tab.COUNT+1) := l_text;
                 END IF;

              ELSE
                IF l_debug_on THEN
   	         wsh_debug_sv.logmsg(l_module_name, 'Index '||i||' : Message Name or Text is Mandatory');
                END IF;
                 raise invalid_parameters;
              END IF; -- }
            ELSE
              IF l_debug_on THEN
   	       wsh_debug_sv.logmsg(l_module_name, 'Index '||i||' : Interface Table Name AND Interface Error Id are Mandatory');
              END IF;
              raise invalid_parameters;
            END IF;

         END LOOP;  --}
      END IF;

      IF (l_text_tab.COUNT > 0) THEN --{

         IF (l_text_tab.COUNT > 3) THEN
            FORALL i in l_text_tab.FIRST..l_text_tab.LAST
              INSERT INTO wsh_interface_errors(
                      interface_error_id,
                      interface_table_name,
                      interface_id,
                      error_message,
                      creation_date,
                      created_by,
                      last_update_date,
                      last_updated_by,
                      last_update_login,
                      program_application_id,
                      program_id,
                      program_update_date,
                      request_id,
                      interface_action_code)
              VALUES (wsh_interface_errors_s.NEXTVAL,
                      l_interface_table_name_tab(i),
                      l_interface_id_tab(i),
                      l_text_tab(i),
                      SYSDATE,
                      fnd_global.user_id,
                      SYSDATE,
                      fnd_global.user_id,
                      fnd_global.user_id,
                      fnd_global.prog_appl_id,
                      fnd_global.conc_program_id,
                      SYSDATE,
                      fnd_global.conc_request_id,
                      p_interface_action_code);
         ELSE
            FOR i in l_text_tab.FIRST..l_text_tab.LAST LOOP
              INSERT INTO wsh_interface_errors(
                      interface_error_id,
                      interface_table_name,
                      interface_id,
                      error_message,
                      creation_date,
                      created_by,
                      last_update_date,
                      last_updated_by,
                      last_update_login,
                      program_application_id,
                      program_id,
                      program_update_date,
                      request_id,
                      interface_action_code)
              VALUES (wsh_interface_errors_s.NEXTVAL,
                      l_interface_table_name_tab(i),
                      l_interface_id_tab(i),
                      l_text_tab(i),
                      SYSDATE,
                      fnd_global.user_id,
                      SYSDATE,
                      fnd_global.user_id,
                      fnd_global.user_id,
                      fnd_global.prog_appl_id,
                      fnd_global.conc_program_id,
                      SYSDATE,
                      fnd_global.conc_request_id,
                      p_interface_action_code);
           END LOOP;
         END IF;

         COMMIT;

      END IF; --}

     IF l_debug_on THEN
      wsh_debug_sv.logmsg (l_module_name, 'Inserted '||l_text_tab.COUNT||' Interface Error Records');
      wsh_debug_sv.log(l_module_name, 'Return Status',x_return_status);
      wsh_debug_sv.pop (l_module_name);
     END IF;
   EXCEPTION
      WHEN invalid_parameters
      THEN
         x_return_status := wsh_util_core.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_PARAMETERS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_PARAMETERS');
         END IF;
      WHEN OTHERS
      THEN
         x_return_status := wsh_util_core.g_ret_sts_unexp_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
   END log_interface_errors;

END wsh_interface_validations_pkg;

/

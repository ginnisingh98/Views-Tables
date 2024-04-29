--------------------------------------------------------
--  DDL for Package Body CSD_RECEIVE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_RECEIVE_UTIL" AS
/* $Header: csdvrutb.pls 120.4.12000000.2 2007/04/24 17:55:51 swai ship $ */

   -- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------
   g_pkg_name     CONSTANT VARCHAR2 (30) := 'CSD_RECEVIE_UTIL';
   g_file_name    CONSTANT VARCHAR2 (12) := 'csdvrutb.pls';
   g_debug_level   CONSTANT  NUMBER      := csd_gen_utility_pvt.g_debug_level;
   g_inspection_required   CONSTANT VARCHAR2 (30) := 'Inspection Required';
   g_inspection_routing    CONSTANT NUMBER        := 2;
   g_standard_routing      CONSTANT NUMBER        := 1;

/*--------------------------------------------------------------------------------------*/
/* function name: is_auto_rcv_available                                              */
/* description   : This function will check if the item is eligible for auto receive */
/*                                                                              */
/* Called from   : This is called from the LOGISTICS UI and also the            */
/*                 CSD_RECEIVE_PVT.RECEIVE_ITEM  API.                           */
/* Input Parm    : p_inventory_item_id         NUMBER      inventory item id    */
/*                 p_inv_org_id                NUMBER      org id of the receiving */
/*                                                         sub inventory        */
/*                 p_internal_ro_flag          VARCHAR2    indicates if the repair */
/*                                                         order is internal    */
/*                 p_from_inv_org_id           NUMBER      org id from which the */
/*                                                         transfer is  made in the */
/*                                                         case if internal orders */
/* returns         Routing header id.         NUMBER                             */
/*------------------------------------------------------------------------------------*/
   FUNCTION is_auto_rcv_available (
      p_inventory_item_id        IN       NUMBER,
      p_inv_org_id               IN       NUMBER,
      p_internal_ro_flag         IN       VARCHAR2,
      p_from_inv_org_id          IN       NUMBER
   )
      RETURN NUMBER
   IS
      l_routing_header_id       NUMBER;
      l_routing_name            VARCHAR2 (30);
      l_location_control_code   NUMBER;
      l_serial_control_code     NUMBER;

--Curosrs for Internal orders ---------------------------------
--Cursor to get the routing id from item parameters for internal orders
      CURSOR cur_item_routing_internal (
         p_org_id                            NUMBER,
         p_item_id                           NUMBER
      )
      IS
         SELECT itm.receiving_routing_id,
                itm.location_control_code, itm.serial_number_control_code
           FROM mtl_system_items_b itm
          WHERE itm.inventory_item_id = p_item_id
            AND itm.organization_id = p_org_id;

--Curosr to get the receive Parameters.
      CURSOR cur_rcv_routing (
         p_org_id                            NUMBER
      )
      IS
         SELECT rcp.receiving_routing_id
           FROM rcv_parameters rcp
          WHERE organization_id = p_org_id;

--Cursor for shipping network
      CURSOR cur_shipping_network (
         p_from_org                          NUMBER,
         p_to_org                            NUMBER
      )
      IS
         SELECT mip.routing_header_id
           FROM mtl_interorg_parameters mip
          WHERE from_organization_id = p_from_org
            AND to_organization_id = p_to_org;

-- Cursors for RMA-----------------------------
--Cursor to get the routing id from item parameters for regular RMA
      CURSOR cur_item_routing_rma (
         p_org_id                            NUMBER,
         p_item_id                           NUMBER
      )
      IS
         SELECT DECODE (itm.return_inspection_requirement,
                        1, g_inspection_routing,
                        null
                       ),
                itm.location_control_code, itm.serial_number_control_code
           FROM mtl_system_items_b itm
          WHERE itm.inventory_item_id = p_item_id
            AND itm.organization_id = p_org_id;

   BEGIN


      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                   (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_RECEIVE_UTIL.IS_AUTO_RCV_AVAILABLE.BEGIN',
                    'Entered IS_AUTO_RCV_AVAILABLE'
                   );
      END IF;

	 --auto receive fucntionality is available only in po patch level j.
	 -- hence return false if the po patch is not set
      if (PO_CODE_RELEASE_GRP.Current_Release < PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J ) then
	 	return -1;
	 End If;


      l_routing_header_id   := -1;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_RECEIVE_UTIL.IS_AUTO_RCV_AVAILABLE',
                            'Parameter:p_inventory_item_id['
                         || p_inventory_item_id
                         || ']'
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_RECEIVE_UTIL.IS_AUTO_RCV_AVAILABLE',
                         'Parameter:p_inv_org_id[' || p_inv_org_id || ']'
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_RECEIVE_UTIL.IS_AUTO_RCV_AVAILABLE',
                            'Parameter:p_internal_RO_flag['
                         || p_internal_ro_flag
                         || ']'
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_RECEIVE_UTIL.IS_AUTO_RCV_AVAILABLE',
                            'Parameter:p_from_inv_org_id['
                         || p_from_inv_org_id
                         || ']'
                        );
      END IF;

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         'CSD.PLSQL.CSD_RECEIVE_UTIL.IS_AUTO_RCV_AVAILABLE',
                         'Checking item level routing'
                        );
      END IF;

      IF (p_internal_ro_flag = 'Y')
      THEN
         --For internal orders
         -- Step i: Check item attribute
         --Item level
         --(Currently limiting to serialized non
         ---  locator controlled by Depot)
         OPEN cur_item_routing_internal (p_inv_org_id, p_inventory_item_id);

         FETCH cur_item_routing_internal
          INTO l_routing_header_id, l_location_control_code,
               l_serial_control_code;

         IF (cur_item_routing_internal%FOUND)
         THEN
            IF (   l_routing_header_id = g_inspection_routing
		  /* R12 development : removed the restrictions
                OR l_location_control_code <> 1
                OR l_serial_control_code = 1
			*/
               )
            THEN
               l_routing_header_id := -1;
            END IF;
         END IF;
         CLOSE cur_item_routing_internal;

         IF(l_routing_header_id is not null) THEN
             RETURN l_routing_header_id;
         END IF;


         -- Step 2: Check Shipping network
         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                         (fnd_log.level_event,
                          'CSD.PLSQL.CSD_RECEIVE_UTIL.IS_AUTO_RCV_AVAILABLE',
                          'Checking shipping network level routing'
                         );
         END IF;

         OPEN cur_shipping_network (p_from_inv_org_id, p_inv_org_id);

         FETCH cur_shipping_network
          INTO l_routing_header_id;

         IF (cur_shipping_network%FOUND)
         THEN
            IF (l_routing_header_id = g_inspection_routing)
            THEN
               l_routing_header_id := -1;
            END IF;
         END IF;
         CLOSE cur_shipping_network;

         IF(l_routing_header_id is not null) THEN
             RETURN l_routing_header_id;
         END IF;

   -- Organization level
        IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_event,
                            'CSD.PLSQL.CSD_RECEIVE_UTIL.IS_AUTO_RCV_AVAILABLE',
                            'Checking org level routing'
                           );
         END IF;

         OPEN cur_rcv_routing (p_inv_org_id);

         FETCH cur_rcv_routing
          INTO l_routing_header_id;

         IF (cur_rcv_routing%FOUND)
         THEN
            IF (l_routing_header_id = g_inspection_routing)
            THEN
               l_routing_header_id := -1;
            END IF;
         END IF;

         CLOSE cur_rcv_routing;

         IF(l_routing_header_id is not null) THEN
             RETURN l_routing_header_id;
         END IF;

      ELSE
         --For regular RMA's logic is, fist at item level and then at org level
         -- return_inspection_Requirement in mtl_system_items_b
         -- is used for item attribute
         OPEN cur_item_routing_rma (p_inv_org_id, p_inventory_item_id);

         FETCH cur_item_routing_rma
          INTO l_routing_header_id, l_location_control_code,
               l_serial_control_code;

         IF (cur_item_routing_rma%FOUND)
         THEN
            IF (   l_routing_header_id = g_inspection_routing
		  /* R12 development : removed the restrictions
                OR l_location_control_code <> 1
                OR l_serial_control_code = 1
			 */
               )
            THEN
               l_routing_header_id := -1;
            END IF;
         END IF;

         CLOSE cur_item_routing_rma;

         IF(l_routing_header_id is not null) THEN
             RETURN l_routing_header_id;
         END IF;

         -- At org level check rcv_parameters. This is kept as dynamic sql
         -- to remove code dependency for R10.

         BEGIN
             EXECUTE IMMEDIATE 'SELECT nvl(RMA_RECEIPT_ROUTING_ID, '||g_standard_routing ||')'
                              || 'FROM RCV_PARAMETERS WHERE organization_id =:1'
                            --|| p_inv_org_id --4277749 TBD
                         --4277749 changed the exec to use using clause
                         INTO l_routing_header_id using p_inv_org_id;
         EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      l_routing_header_id := g_standard_routing;
         END;

         IF (l_routing_header_id = g_inspection_routing ) THEN
             l_routing_header_id := -1;
         END IF;

         IF(l_routing_header_id is not null) THEN
             RETURN l_routing_header_id;
         END IF;

      END IF;



      -----
      -- Default the routing to standard if not set anywhere.

      IF(l_routing_header_id is null) THEN
          l_routing_header_id := g_standard_routing;
      END IF;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                     (fnd_log.level_procedure,
                      'CSD.PLSQL.CSD_RECEIVE_UTIL.IS_AUTO_RCV_AVAILABLE.END',
                      'Leaving IS_AUTO_RCV_AVAILABLE'
                     );
      END IF;

      RETURN l_routing_header_id;

   END is_auto_rcv_available;

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: VALIDATE_RCV_INPUT                                                                        */
/* description   : Validates the RMA data. Checks for mandatory fields for                                   */
/*                 Receiving Open interface API.                                                             */
/* Called from   : CSD_RECEIVE_PVT.RECEIVE_ITEM                                                 */
/* Input Parm    :
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.                             */
/*                 p_receive_rec         CSD_RCV_UTIL.RCV_REC_TYPE      Required                             */
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE validate_rcv_input (
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      p_receive_rec              IN       csd_receive_util.rcv_rec_type
   )
   IS
      l_tmp_char                      VARCHAR2 (1);
      l_srl_Status                    VARCHAR2(30);
      l_c_api_name             CONSTANT VARCHAR2 (30) := 'VALIDATE_RCV_INPUT';
	 l_c_srl_out_of_Stores    constant number := 4;
	 l_c_srl_in_Stores        constant number := 3;
	 l_c_srl_in_transit        constant number := 5;


      CURSOR cur_subinv (
         p_org_id                            NUMBER,
         p_subinv                            VARCHAR2
      )
      IS
         SELECT 'x'
           FROM mtl_secondary_inventories
          WHERE secondary_inventory_name = p_subinv
            AND organization_id = p_org_id;

      CURSOR cur_serial_status (
         p_org_id                            NUMBER,
         p_inventory_item_id                 NUMBER,
         p_serial_number                     VARCHAR2
      )
      IS
         SELECT Current_status
           FROM mtl_serial_numbers
          WHERE -- current_organization_id = p_org_id
		  --AND
		  inventory_item_id = p_inventory_item_id
            AND serial_number = p_serial_number;
		  --AND current_status = 4; -- 4=> out of stores
   BEGIN

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                      (fnd_log.level_procedure,
                       'CSD.PLSQL.CSD_RECEIVE_UTIL.VALIDATE_RCV_INPUT.BEGIN',
                       'Entered VALIDATE_RCV_INPUT'
                      );
      END IF;

      -- initialize return status
      x_return_status := fnd_api.g_ret_sts_success;
      -- Check for required parameters
      csd_process_util.check_reqd_param
                                    (p_param_value      => p_receive_rec.quantity,
                                     p_param_name       => 'P_RECEIVE_REC.QUANTITY',
                                     p_api_name         => l_c_api_name
                                    );

      -- Vlaidate the inventory item id.

      IF (NOT csd_process_util.validate_inventory_item_id
                       (p_inventory_item_id      => p_receive_rec.inventory_item_id)
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Validate the sub inventory.....
      OPEN cur_subinv (p_receive_rec.to_organization_id,
                       p_receive_rec.subinventory);

      FETCH cur_subinv
       INTO l_tmp_char;

      IF (cur_subinv%NOTFOUND)
      THEN
         fnd_message.set_name ('CSD', 'CSD_INVALID_SUBINV');
         fnd_msg_pub.ADD;

         CLOSE cur_subinv;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE cur_subinv;

	 -- validate the serial number status
	 -- if the status is not 'issued out of stores' do not allow it.
	 -- 10/31/05 validate only if the serial number is not null

      if(p_receive_rec.serial_number is not null ) then
		 OPEN cur_serial_status (p_receive_rec.to_organization_id,
							p_receive_rec.inventory_item_id,
							p_receive_rec.serial_number);

		 FETCH cur_serial_status
		  INTO l_srl_Status;

		 --IF (cur_serial_status %NOTFOUND)
		 --THEN
		 --   fnd_message.set_name ('CSD', 'CSD_INVALID_SRL_STATUS');
		 --   fnd_message.set_token ('STATUS', ' ');
		 --   fnd_msg_pub.ADD;
		 --   CLOSE cur_serial_status;
		 --   RAISE fnd_api.g_exc_error;
		 --
		 IF ( cur_serial_status %FOUND )
		 THEN
		   IF ( p_receive_rec.internal_order_flag <> 'Y' AND l_Srl_status <> l_c_srl_out_of_Stores) THEN
		     fnd_message.set_name ('CSD', 'CSD_INVALID_SRL_STATUS');
		     fnd_message.set_token ('STATUS', l_Srl_status);
		     fnd_msg_pub.ADD;
		     CLOSE cur_serial_status;
		     RAISE fnd_api.g_exc_error;
		    ELSIF ( p_receive_rec.internal_order_flag = 'Y' AND l_Srl_status <> l_c_srl_in_Stores
				  AND l_srl_Status <> l_c_srl_in_transit ) THEN
		     fnd_message.set_name ('CSD', 'CSD_INVALID_SRL_STATUS');
		     fnd_message.set_token ('STATUS', l_Srl_status);
		     fnd_msg_pub.ADD;
		     CLOSE cur_serial_status;
		     RAISE fnd_api.g_exc_error;

		   END IF;
                 END IF;

		 CLOSE cur_serial_status;
      END IF; -- end of if serail _number is not null


      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_RECEIVE_UTIL.VALIDATE_RCV_INPUT.END',
                         'Leaving VALIDATE_RCV_INPUT'
                        );
      END IF;

   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            'CSD.PLSQL.CSD_RECEIVE_UTIL.VALIDATE_RCV_INPUT',
                            'EXC_ERROR in validate_rcv_input '
                           );
         END IF;
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_c_api_name);
         END IF;

         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            'CSD.PLSQL.CSD_RECEIVE_UTIL.VALIDATE_RCV_INPUT',
                            'SQL Message in validate_rcv_input[' || SQLERRM || ']'
                           );
         END IF;
   END validate_rcv_input;

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: CHECK_RCV_ERRORS                                                                          */
/* description   : Checks the PO_INTERFACE_ERRORS table to see of there are any error records created by the */
/*                 receiving transaction processor..                                                             */
/* Called from   : CSD_RECEIVE_PVT.RECEIVE_ITEM */
/* Input Parm    :  p_request_group_id    NUMBER    Required                                                */
/* Output Parm   : x_return_status       VARCHAR2   Return status after the call. The status can be*/
/*                                                  fnd_api.g_ret_sts_success (success)            */
/*                                                  fnd_api.g_ret_sts_error (error)                */
/*                                                  fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE check_rcv_errors (
      x_return_status            OUT NOCOPY VARCHAR2,
      x_rcv_error_msg_tbl        OUT NOCOPY csd_receive_util.rcv_error_msg_tbl,
      p_request_group_id         IN       NUMBER
   )
   IS
      l_api_version_number   CONSTANT NUMBER        := 1.0;
      l_api_name             CONSTANT VARCHAR2 (30) := 'CHECK_RCV_ERRORS';
      l_header_id            NUMBER;
      l_line_id              NUMBER;
      i                      NUMBER;
      l_order_header_id      NUMBER;
      l_order_line_id        NUMBER;

      -- Cursor which gets the header interface transaction id from the
      -- rcv_transactions_interface for the given request group id.
      CURSOR cur_rcv_headers (
         p_group_id                          NUMBER
      )
      IS
         SELECT header_interface_id
           FROM rcv_headers_interface
          WHERE GROUP_ID = p_group_id;

      -- Cursor which gets the interface transaction id from the
      -- rcv_transactions_interface for the given request group id.
      CURSOR cur_rcv_lines (
         p_group_id                          NUMBER
      )
      IS
         SELECT interface_transaction_id
           FROM rcv_transactions_interface
          WHERE GROUP_ID = p_group_id;


      -- Cursor to select the receiving errors from po_interface_errors table
      CURSOR cur_rcv_errors (
         p_hdr_intf_id                       NUMBER,
         p_line_intf_id                      NUMBER
      )
      IS
         SELECT column_name, error_message
           FROM po_interface_errors
          WHERE (interface_header_id = p_hdr_intf_id OR
                 interface_line_id = p_line_intf_id) ;

      -- Cursor to derive the transaction_details
      CURSOR cur_get_txn_details ( p_interface_transaction_id NUMBER) IS
      SELECT  oe_order_header_id,
              oe_order_line_id
      FROM  rcv_transactions_interface
      WHERE interface_transaction_id = p_interface_transaction_id;

   BEGIN


      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_RECEIVE_UTIL.CHECK_RCV_ERRORS.BEGIN',
                         'Entered CHECK_RCV_ERRORS'
                        );
      END IF;

      -- initialize return status
      x_return_status := fnd_api.g_ret_sts_success;

      -- Open cursors to get header_interface id and trnasaction_interface_id
      open cur_rcv_headers (p_request_group_id);
      open cur_rcv_lines(p_request_group_id);


      --Fetch header_interface id and trnasaction_interface_id and
      -- loop through untill both are null.
      l_header_id := -1;
      l_line_id := -1;
      i := 0;

      LOOP

         if(l_header_id is not null ) then
             FETCH cur_rcv_headers into l_header_id;
             if(cur_rcv_headers%NOTFOUND) THEN
                 l_header_id := null;
                 close cur_rcv_headers;
             end if;
         end if;

	         if(l_line_id is not null ) then
             FETCH cur_rcv_lines into l_line_id;
             if(cur_rcv_lines%NOTFOUND) THEN
                 l_line_id := null;
                 close cur_rcv_lines;
             end if;
         end if;

         if(l_header_id is null and l_line_id is null ) then
             exit;
         else
             -- when one of the header_interface id or trnasaction_interface_id
             -- is  not null then fetch the interface errors.
             FOR rcv_error_rec IN
                cur_rcv_errors (l_header_id,l_line_id)
             LOOP

                i := i + 1;

                fnd_message.set_name ('CSD', 'CSD_AUTO_RCV_ERROR');
                fnd_message.set_token ('RCV_ERROR', rcv_error_rec.error_message);
                fnd_msg_pub.ADD;

                -- Derive the Transaction details
                if(l_line_id is not null ) then
                  open cur_get_txn_details(l_line_id);
                  fetch cur_get_txn_details into l_order_header_id,l_order_line_id;
                  close cur_get_txn_details;
                else
                  l_order_header_id := null;
                  l_order_line_id   := null;
                end if;

                -- Add message to the message table
                x_rcv_error_msg_tbl(i).group_id                 := p_request_group_id;
                x_rcv_error_msg_tbl(i).header_interface_id      := l_header_id;
                x_rcv_error_msg_tbl(i).interface_transaction_id := l_line_id;
                x_rcv_error_msg_tbl(i).order_header_id          := l_order_header_id;
                x_rcv_error_msg_tbl(i).order_line_id            := l_order_line_id;
                x_rcv_error_msg_tbl(i).column_name              := rcv_error_rec.column_name;
                x_rcv_error_msg_tbl(i).error_message            := rcv_error_rec.error_message;

                x_return_status := fnd_api.g_ret_sts_error;

             END LOOP;
         end if;
      END LOOP;

      if(cur_rcv_headers%ISOPEN) then
          close cur_rcv_headers;
      end if;
      if(cur_rcv_lines%ISOPEN) then
          close cur_rcv_lines;
      end if;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_RECEIVE_UTIL.CHECK_RCV_ERRORS.END',
                         'Leaving CHECK_RCV_ERRORS'
                        );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            'CSD.PLSQL.CSD_RECEIVE_UTIL.CHECK_RCV_ERRORS',
                            'SQL Error Message in check_rcv_errors[' || SQLERRM || ']'
                           );
         END IF;
   END check_rcv_errors;

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: get_employee_id                                                                         */
/* description   : This will return the employee id for the given user id.         */
/*                 */
/* Called from   : CSD_RECEIVE_PVT.RECEIVE_ITEM */
/* Input Parm    :  p_request_group_id    NUMBER    Required                                                */
/* Output Parm   : x_return_status       VARCHAR2   Return status after the call. The status can be*/
/*                                                  fnd_api.g_ret_sts_success (success)            */
/*                                                  fnd_api.g_ret_sts_error (error)                */
/*                                                  fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE get_employee_id (
      p_user_id                  IN       NUMBER,
      x_employee_id              OUT NOCOPY NUMBER
   )
   IS
      CURSOR cur_get_employee_id (
         p_user_id                           NUMBER
      )
      IS
         SELECT hr.employee_id
           FROM fnd_user fnd, per_employees_current_x hr
          WHERE fnd.user_id = p_user_id
            AND fnd.employee_id = hr.employee_id
            AND ROWNUM = 1;

      l_emp_id   NUMBER;
   BEGIN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_RECEIVE_UTIL.GET_EMPLOYEE_ID.BEGIN',
                         'Entered get_employee_id'
                        );
      END IF;

      --get the employee id
      OPEN cur_get_employee_id (p_user_id);

      FETCH cur_get_employee_id
       INTO x_employee_id;

      IF (cur_get_employee_id%NOTFOUND)
      THEN
        /* swai: Fixed for bug#5505490 / FP#5563349
           When employee_id not found then return null.
           User is not defined as employee that's why
           there is no record in table
           per_employees_current_x.
           In this case Depot should not raise any error.
         */
         /* CLOSE cur_get_employee_id;
            RAISE fnd_api.g_exc_unexpected_error; */

	    x_employee_id := NULL;
      END IF;

      CLOSE cur_get_employee_id;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_RECEIVE_UTIL.GET_EMPLOYEE_ID.END',
                         'Leaving get_employee_id'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_exception,
                            'CSD.PLSQL.CSD_RECEIVE_UTIL.GET_EMPLOYEE_ID',
                            'EXC_UNEXPECTED_ERROR in get_employee_id'
                           );
         END IF;

         RAISE;
      WHEN OTHERS
      THEN
         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            'CSD.PLSQL.CSD_RECEIVE_UTIL.GET_EMPLOYEE_ID',
                            'SQL MEssage in get_employee_id[' || SQLERRM
                            || ']'
                           );
         END IF;

         RAISE;
   END get_employee_id;

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: get_rcv_item_params                                                                        */
/* description   : This will populate some required fields in the receiving data structure    */
/*                 */
/* Called from   : CSD_RECEIVE_PVT.RECEIVE_ITEM */
/* Input Parm    : p_receive_rec         CSD_RCV_UTIL.RCV_REC_TYPE      Required                             */
/* Output Parm   : x_return_status       VARCHAR2   Return status after the call. The status can be*/
/*                                                  fnd_api.g_ret_sts_success (success)            */
/*                                                  fnd_api.g_ret_sts_error (error)                */
/*                                                  fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE get_rcv_item_params (
      p_receive_rec              IN OUT NOCOPY csd_receive_util.rcv_rec_type
   )
   IS
   --Define all the cursors
   -- Cursor to get the to organization id
    CURSOR cur_get_to_org (p_order_line_id NUMBER) IS
     SELECT SHIP_FROM_ORG_ID
	FROM OE_ORDER_LINES_ALL
	WHERE LINE_ID = p_order_line_id;

   -- cursor to select the category.
      CURSOR cur_get_category (
         p_org_id                            NUMBER,
         p_category_set_id                   NUMBER,
         p_item_id                           NUMBER
      )
      IS
         SELECT MAX (category_id)
           FROM mtl_item_categories
          WHERE inventory_item_id = p_item_id
            AND organization_id = p_org_id
            AND category_set_id = p_category_set_id;

     -- Cursor to select the category set for the
     -- purchasing functional area.
      CURSOR cur_get_category_set
      IS
         SELECT mdsv.category_set_id
           FROM mtl_default_sets_view mdsv
          WHERE mdsv.functional_area_id = 2;

      -- Cursor to select the primary UOM
      CURSOR cur_get_primary_uom (
         p_org_id                            NUMBER,
         p_item_id                           NUMBER
      )
      IS
         SELECT primary_unit_of_measure
           FROM mtl_item_flexfields
          WHERE inventory_item_id = p_item_id AND organization_id = p_org_id;

      -- Cursor to select the item attributes serial control code and
      --  lot control code.
      CURSOR cur_get_item_attribs (
         p_org_id                            NUMBER,
         p_item_id                           NUMBER
      )
      IS
         SELECT lot_control_code, serial_number_control_code
           FROM mtl_system_items
          WHERE organization_id = p_org_id AND inventory_item_id = p_item_id;


     -- Cursor to  get the unit of measure
      CURSOR cur_get_unit_of_measure (
         p_uom_code                         VARCHAR2
      )
      IS
         SELECT unit_of_measure
           FROM mtl_units_of_measure_vl
          WHERE uom_code = p_uom_Code ;

      -- define local vars
      l_category_set   NUMBER;

   BEGIN

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                     (fnd_log.level_procedure,
                      'CSD.PLSQL.CSD_RECEIVE_UTIL.GET_RCV_ITEM_PARAMS.BEGIN',
                      'Entered get_rcv_item_params'
                     );
      END IF;

      --get the to_org id if null
	 if(p_receive_rec.to_organization_id is null) then
		 OPEN cur_get_to_org(p_receive_rec.order_line_id) ;

		 FETCH cur_get_to_org
		  INTO p_receive_rec.to_organization_id;

		 IF (cur_get_to_org %NOTFOUND)
		 THEN
		    CLOSE cur_get_to_org ;

		    RAISE fnd_api.g_exc_unexpected_error;
		 END IF;

		 CLOSE cur_get_to_org ;
      End IF;
      --get the category set for purchasing functional area
      OPEN cur_get_category_set;

      FETCH cur_get_category_set
       INTO l_category_set;

      IF (cur_get_category_set%NOTFOUND)
      THEN
         CLOSE cur_get_category;

         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      CLOSE cur_get_category_set;

      -- Get the category
      OPEN cur_get_category (p_receive_rec.to_organization_id,
                             l_category_set,
                             p_receive_rec.inventory_item_id
                            );

      FETCH cur_get_category
       INTO p_receive_rec.category_id;

      IF (cur_get_category%NOTFOUND)
      THEN
         CLOSE cur_get_category;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE cur_get_category;

      --Get the primary UOM
      OPEN cur_get_primary_uom (p_receive_rec.to_organization_id,
                                p_receive_rec.inventory_item_id);

      FETCH cur_get_primary_uom
       INTO p_receive_rec.primary_unit_of_measure;

      IF (cur_get_primary_uom%NOTFOUND)
      THEN
         CLOSE cur_get_primary_uom;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE cur_get_primary_uom;

      --Get serial number control code and lot control code
      OPEN cur_get_item_attribs (p_receive_rec.to_organization_id,
                                 p_receive_rec.inventory_item_id);

      FETCH cur_get_item_attribs
       INTO p_receive_rec.lot_control_code, p_receive_rec.serial_control_code;

      IF (cur_get_item_attribs%NOTFOUND)
      THEN
         CLOSE cur_get_item_attribs;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE cur_get_item_attribs;

      --Get serial number control code and lot control code
      OPEN cur_get_unit_of_measure (p_receive_rec.uom_code);

      FETCH cur_get_unit_of_measure
       INTO p_receive_rec.unit_of_measure;

      IF (cur_get_unit_of_measure%NOTFOUND)
      THEN
         CLOSE cur_get_unit_of_measure;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE cur_get_unit_of_measure;


      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                       (fnd_log.level_procedure,
                        'CSD.PLSQL.CSD_RECEIVE_UTIL.GET_RCV_ITEM_PARAMS.END',
                        'Leaving get_rcv_item_params'
                       );
      END IF;

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_exception,
                            'CSD.PLSQL.CSD_RECEIVE_UTIL.GET_RCV_ITEM_PARAMS',
                            'EXC_UNEXPECTED_ERROR in get_rcv_item_params'
                           );
         END IF;

         RAISE;
      WHEN OTHERS
      THEN
         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            'CSD.PLSQL.CSD_RECEIVE_UTIL.GET_RCV_ITEM_PARAMS',
                               'SQL Error Message in get_rcv_item_params ['
                            || SQLERRM
                            || ']'
                           );
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
   END get_rcv_item_params;
END csd_receive_util;

/

--------------------------------------------------------
--  DDL for Package Body CSD_RECEIVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_RECEIVE_PVT" AS
/* $Header: csdvrcvb.pls 120.2.12010000.3 2009/09/02 05:36:21 subhat ship $ */

   -- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------
   g_pkg_name    CONSTANT VARCHAR2 (30) := 'CSD_RECEIVE_PVT';
   g_file_name   CONSTANT VARCHAR2 (12) := 'csdvrcvb.pls';
   g_debug_level CONSTANT NUMBER        := csd_gen_utility_pvt.g_debug_level;
   g_prcess_sts_pending CONSTANT  VARCHAR2(10) := 'PENDING';
   g_rcpt_source_customer CONSTANT VARCHAR2(10)  := 'CUSTOMER';
   g_txn_type_new     CONSTANT VARCHAR2(10)  := 'NEW';

   /*****
   PENDING',
                   'CUSTOMER', 'NEW'
   **/

   FUNCTION check_group_id (
      p_group_id                 IN       NUMBER
   )
      RETURN BOOLEAN;

   PROCEDURE dump_receive_tbl (
      p_receive_tbl              IN       csd_receive_util.rcv_tbl_type,
      p_level                             NUMBER,
      p_module                            VARCHAR2
   );

   PROCEDURE log_error_stack;

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: RECEIVE_ITEM                                                                        */
/* description   : Populates the Receive open interface tables and calls the Receive processor. This handles */
/*                 all types of receives a) Direct b) Standard                       */
/* Called from   : CSDREPLN.pld. logistics tab.*/
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
/*                                                            default value is fnd_api.g_false               */
/*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
/*                                                            fnd_api.g_false                                */
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.                             */
/*                 p_receive_rec         CSD_RECEIVE_UTIL.RCV_REC_TYPE      Required                             */
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*                 x_rcv_error_msg_tbl                        Returns table of error messages                */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE receive_item (
      p_api_version              IN         NUMBER,
      p_init_msg_list            IN         VARCHAR2,
      p_commit                   IN         VARCHAR2,
      p_validation_level         IN         NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      x_rcv_error_msg_tbl        OUT NOCOPY csd_receive_util.rcv_error_msg_tbl,
      p_receive_tbl              IN  OUT NOCOPY csd_receive_util.rcv_tbl_type
   )
   IS
      l_api_version_number   CONSTANT NUMBER        := 1.0;
      l_api_name             CONSTANT VARCHAR2 (30) := 'RECEIVE_ITEM';
      l_index                         NUMBER;
      l_request_group_id              NUMBER;
      l_retcode                       NUMBER;
   BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT sp_receive_item;


      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_RECEIVE_PVT.RECEIVE_ITEM.BEGIN',
                         'Entered RECEIVE_ITEM'
                        );
      END IF;

      dump_receive_tbl ( p_receive_tbl,
                           fnd_log.level_statement,
                           'CSD.PLSQL.CSD_RECEIVE_PVT.RECEIVE_ITEM.BEGIN'
                          );
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         -- initialize message list
         fnd_msg_pub.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version_number,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- initialize return status
      x_return_status := fnd_api.g_ret_sts_success;

      /**********Program logic ******************/

      --Validate all the records in the input table.
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         'CSD.PLSQL.CSD_RECEIVE_PVT.RECEIVE_ITEM',
                         'Validating Input'
                        );
      END IF;
-------------Validate Input data.
      FOR l_index IN p_receive_tbl.FIRST .. p_receive_tbl.LAST
      LOOP
         csd_receive_util.validate_rcv_input
                           (p_validation_level      => fnd_api.g_valid_level_full,
                            x_return_status         => x_return_status,
                            p_receive_rec           => p_receive_tbl (l_index)
                           );
         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         p_receive_tbl (l_index).routing_header_id :=
            csd_receive_util.is_auto_rcv_available
                                        (p_receive_tbl (l_index).inventory_item_id,
                                         p_receive_tbl (l_index).to_organization_id,
                                         p_receive_tbl (l_index).internal_order_flag,
                                         p_receive_tbl (l_index).from_organization_id
                                        );

         IF (p_receive_tbl (l_index).routing_header_id = -1)
         THEN
            fnd_message.set_name ('CSD', 'CSD_AUTO_RECV_NOT_POSSIBLE');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;

      END LOOP;

--------POpulate the interface tables.
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         'CSD.PLSQL.CSD_RECEIVE_PVT.RECEIVE_ITEM',
                         'Populating Interface tables'
                        );
      END IF;

      populate_rcv_intf_tbls
                            (p_api_version           => 1.0,
                             p_init_msg_list         => fnd_api.g_false,
                             p_validation_level      => fnd_api.g_valid_level_full,
                             x_return_status         => x_return_status,
                             x_msg_count             => x_msg_count,
                             x_msg_data              => x_msg_data,
                             p_receive_tbl           => p_receive_tbl,
                             x_request_group_id      => l_request_group_id
                            );

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

-- Call request online to invoke receiving processsor in online mode.
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         'CSD.PLSQL.CSD_RECEIVE_PVT.RECEIVE_ITEM',
                         'Calling the receive api online'
                        );
      END IF;

      rcv_req_online (p_api_version           => 1.0,
                      p_init_msg_list         => fnd_api.g_false,
                      p_commit                => fnd_api.g_false,
                      p_validation_level      => fnd_api.g_valid_level_full,
                      x_return_status         => x_return_status,
                      x_msg_count             => x_msg_count,
                      x_msg_data              => x_msg_data,
                      p_request_group_id      => l_request_group_id
                     );

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
            (fnd_log.level_event,
             'CSD.PLSQL.CSD_RECEIVE_PVT.RECEIVE_ITEM',
             'Checking the errors in interface tables after the receive process'
            );
      END IF;

--Call Check_Rcv_Errors to check the errors in the PO_INTERFACE_ERRORS table.
      csd_receive_util.check_rcv_errors
                            (x_return_status         => x_return_status,
                             x_rcv_error_msg_tbl     => x_rcv_error_msg_tbl,
                             p_request_group_id      => l_request_group_id
                            );

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;


 -- Delete the interface table records created.
 /************8

    DELETE_INTF_TBLS(
                   x_return_status    => x_return_status,
                   p_request_group_id => l_request_group_id
                   );
    l_request_group_id := null;
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    *****************/


      -- Standard call to get message count and IF count is  get message info.
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_RECEIVE_PVT.RECEIVE_ITEM.END',
                         'Leaving RECEIVE_ITEM'
                        );
      END IF;

      --Commit the changes.
      IF (p_commit = fnd_api.g_true)
      THEN
         COMMIT;
      END IF;

   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO sp_receive_item;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data);

                                    /*************************88
         if(l_request_group_id is not null) then
             DELETE_INTF_TBLS(
                            x_return_status    => x_return_status,
                            p_request_group_id => l_request_group_id
                            );
         end if;
         *****************************/

         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            'CSD.PLSQL.CSD_RECEIVE_PVT.RECEIVE_ITEM',
                            'EXC_ERROR in Receive_Item[' || x_msg_data || ']'
                           );
         END IF;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK TO sp_receive_item;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data);

         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_exception,
                            'CSD.PLSQL.CSD_RECEIVE_PVT.RECEIVE_ITEM',
                            'EXC_UNEXPECTED_ERROR in Receive_Item[' || x_msg_data || ']'
                           );
         END IF;
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK TO sp_receive_item;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data);

         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            'CSD.PLSQL.CSD_RECEIVE_PVT.RECEIVE_ITEM',
                            'SQL Message in Receive_Item[' || SQLERRM || ']'
                           );
         END IF;
   END receive_item;

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: POPULATE_INTF_TBLS                                                                          */
/* description   : Inserts records into open interface tables for receiving.                                                             */
/* Called from   : CSD_RCV_PVT.RECEIVE_ITEM api  */
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
/*                                                            default value is fnd_api.g_false               */
/*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
/*                                                            fnd_api.g_false                                */
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.                             */
/*                 p_receive_rec         CSD_RECEIVE_UTIL.RCV_REC_TYPE      Required                             */
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*                 x_request_group_id    NUMBER      Required                                                */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE populate_rcv_intf_tbls (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_receive_tbl              IN       csd_receive_util.rcv_tbl_type,
      x_request_group_id         OUT NOCOPY NUMBER
   )
   IS
      pragma AUTONOMOUS_TRANSACTION;
      l_api_version_number   CONSTANT NUMBER                        := 1.0;
      l_api_name             CONSTANT VARCHAR2 (30)
                                                  := 'Populate_Rcv_Intf_Tbls';
      l_hdr_intf_id                   NUMBER;
      i                               NUMBER;
      p_receive_rec                   csd_receive_util.rcv_rec_type;
      l_source_code                   VARCHAR2 (240);
      l_source_line_id                NUMBER  := 1;
      l_txn_tmp_id                    NUMBER;
      l_source_header_id              NUMBER   := 1;
      l_process_sts_pending           CONSTANT VARCHAR2(10) := 'PENDING';
      l_rcpt_source_customer          CONSTANT VARCHAR2(10) := 'CUSTOMER';
      l_txn_Type_new                  CONSTANT VARCHAR2(10) := 'NEW';
      l_validation_flag               CONSTANT VARCHAR2(1)  := 'Y';

      l_lot_expiration_date           DATE;
      l_process_flag                  CONSTANT VARCHAR2 (1)  := '1'; -- 1 means process
      l_intf_txn_id                   NUMBER;
      sql_str                         VARCHAR2 (2000);
      exec_flag                       BOOLEAN;
      l_emp_id                        NUMBER;
      l_receipt_source_code           VARCHAR2(30);
      l_source_document_code          VARCHAR2(30);
      l_org_id                        NUMBER;

      cursor c_get_org_id (p_order_line_id in number) is
      select org_id
      from oe_order_lines_all
      where line_id = p_order_line_id;

   BEGIN


      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                   (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_RECEIVE_PVT.POPULATE_RCV_INTF_TBLS.BEGIN',
                    'Entered Populate_Rcv_Intf_Tbls'
                   );
      END IF;

      l_source_code := 'CSD';

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         -- initialize message list
         fnd_msg_pub.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version_number,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- initialize return status
      x_return_status := fnd_api.g_ret_sts_success;

      ---Program logic.......
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         'CSD.PLSQL.CSD_RECEIVE_PVT.POPULATE_RCV_INTF_TBLS',
                         'Inserting header interface table data'
                        );
      END IF;

       if(p_receive_tbl (1).internal_order_flag = 'Y') then
           l_source_document_code := 'REQ';
           l_receipt_source_code  := 'INTERNAL ORDER';
       else
           l_source_document_code := 'RMA';
           l_receipt_source_Code := 'CUSTOMER';
       end if;

--    Insert header record.
      INSERT INTO rcv_headers_interface
                  (header_interface_id,
                   GROUP_ID,
                   ship_to_organization_id,
                   expected_receipt_date, last_update_date,
                   last_updated_by, last_update_login, creation_date,
                   created_by, validation_flag, processing_status_code,
                   receipt_source_code, transaction_type,
                   -- added for internal orders.
                   shipped_Date,
                   shipment_num
                  )
           VALUES (rcv_headers_interface_s.NEXTVAL,
                   rcv_interface_groups_s.NEXTVAL,
                   p_receive_tbl (1).to_organization_id,
                   p_receive_tbl (1).expected_receipt_date, SYSDATE,
                   fnd_global.user_id, fnd_global.login_id, SYSDATE,
                   fnd_global.user_id, l_validation_flag, l_process_sts_pending,
                   l_receipt_source_code, l_txn_Type_new,
                   -- added for internal orders.
                   p_receive_tbl (1).shipped_date,
                   p_receive_tbl (1).shipment_number
                  )
        RETURNING header_interface_id, GROUP_ID
             INTO l_hdr_intf_id, x_request_group_id;

--
-- Dynamic sql is being used to ensure that the code is not dependent on
-- the 11.5.0 PO code. This will be only run time dependent.(functional dependence)
      sql_str :=
         'UPDATE RCV_HEADERS_INTERFACE SET HEADER_INTERFACE_ID=HEADER_INTERFACE_ID';
      exec_flag := FALSE;

      IF (p_receive_tbl (1).customer_id IS NOT NULL)
      THEN
         sql_str :=
               sql_str
            || ',CUSTOMER_ID='
            || TO_CHAR (p_receive_tbl (1).customer_id);
         exec_flag := TRUE;
      END IF;

      IF (p_receive_tbl (1).customer_site_id IS NOT NULL)
      THEN
         sql_str :=
               sql_str
            || ',CUSTOMER_SITE_ID = '
            || TO_CHAR (p_receive_tbl (1).customer_site_id);
         exec_flag := TRUE;
      END IF;

	 /**********************Commented for 4277749
      sql_str := sql_str || ' WHERE HEADER_INTERFACE_ID=' || l_hdr_intf_id;
	 ***************************************/

      -- bug fix for performance bug 4277749 begin
      sql_str := sql_str || ' WHERE HEADER_INTERFACE_ID= :1';
      -- bug fix for performance bug 4277749 end

      IF (exec_flag)
      THEN
         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                         (fnd_log.level_event,
                          'CSD.PLSQL.CSD_RECEIVE_PVT.POPULATE_RCV_INTF_TBLS',
                             'Calling execute immediate with sql['
                          || sql_str
                          || ']'
                         );
         END IF;

         -- bug fix for performance bug 4277749 , added using clause
         EXECUTE IMMEDIATE sql_str using l_hdr_intf_id;
      END IF;

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         'CSD.PLSQL.CSD_RECEIVE_PVT.POPULATE_RCV_INTF_TBLS',
                         'Inserting transactions interface table data'
                        );
      END IF;

      csd_receive_util.get_employee_id (fnd_global.user_id, l_emp_id);

      --Insert data into the transactions interface table.
      FOR i IN p_receive_tbl.FIRST .. p_receive_tbl.LAST
      LOOP
         p_receive_rec := p_receive_tbl (i);
         p_receive_rec.employee_id := l_emp_id;
         csd_receive_util.get_rcv_item_params (p_receive_rec);

         -- Derive the Org id
         -- MOAC change Bug#4245577
         OPEN  c_get_org_id (p_receive_rec.order_line_id);
  	 FETCH c_get_org_id INTO l_org_id;
	 CLOSE c_get_org_id;

         if(p_receive_rec.internal_order_flag = 'Y') then
             l_source_document_code := 'REQ';
             l_receipt_source_code  := 'INTERNAL ORDER';
         else
             l_source_document_code := 'RMA';
             l_receipt_source_Code := 'CUSTOMER';
         end if;
-- bug#7509332,12.1 FP, subhat.
-- Locator information is not passed to rcv_transactions_interface.
-- currently we insert the locator_id into location_id column. Where as locator_id should be
-- inserted into locator_id of rcv_transactions_interface.
-- the column descriptions from eTRM.
-- LOCATOR_ID 	NUMBER Destination locator unique identifier
-- LOCATION_ID 	NUMBER Receiving location unique identifier

         INSERT INTO rcv_transactions_interface
                     (interface_transaction_id, header_interface_id,
                      GROUP_ID, transaction_date,
                      quantity, unit_of_measure,
                      oe_order_header_id,
                      document_num,
                      item_id,
                      item_revision,
                      to_organization_id,
                      ship_to_location_id,
                      subinventory, last_update_date,
                      last_updated_by, creation_date, created_by,
                      last_update_login, validation_flag,
                      source_document_code, interface_source_code,
                      auto_transact_code,
                      receipt_source_code,
                      transaction_type,
                      processing_status_code,
                      processing_mode_code,
                      transaction_status_code,
                      -- new columns to be updated,
                      category_id, uom_code,
                      employee_id,
                      primary_quantity,
                      primary_unit_of_measure,
                      routing_header_id, routing_step_id,
                      inspection_status_code,
                      destination_type_code, expected_receipt_date,
                      destination_context,
                      use_mtl_lot,
                      use_mtl_serial,
                      source_doc_quantity,
                      source_doc_unit_of_measure, oe_order_line_id,
                      --po_unit_price,
                      currency_code,
                      customer_id,
                      customer_site_id,
                      -- added for internal orders
                      requisition_line_id,
                      shipped_date,
                      shipment_num,
                      from_organization_id,
                      --location_id,
                      locator_id, --bug#7509332, 12.1 FP, subhat
                      deliver_to_location_id,
                      shipment_header_id,
                      shipment_line_id,
                      org_id             -- MOAC change Bug#4245577
                     )
              VALUES (rcv_transactions_interface_s.NEXTVAL, l_hdr_intf_id,
                      x_request_group_id, p_receive_rec.transaction_date,
                      p_receive_rec.quantity, p_receive_rec.unit_of_measure,
                      p_receive_rec.order_header_id,
                      p_receive_rec.doc_number,
                      p_receive_rec.inventory_item_id,
                      p_receive_rec.item_revision,
                      p_receive_rec.to_organization_id,
                      p_receive_rec.ship_to_location_id,
                      p_receive_rec.subinventory, SYSDATE,
                      fnd_global.user_id, SYSDATE, fnd_global.user_id,
                      fnd_global.login_id, 'Y',
                      l_source_document_code
                      , 'RCV'                     --Interface_source_Code
                      , 'DELIVER'                         -- auto _Transact_Code
                      , l_receipt_source_Code          --receipt_source_code
                      , 'RECEIVE'                             --Transaction_type
                      , 'PENDING'                      -- processing_status_Code
                      --, 'ONLINE'                         --processing_mode _Code
                      , decode(csd_bulk_receive_pvt.g_bulk_rcv_conc,'Y','IMMEDIATE','ONLINE') --processing_mode _Code
                      , 'PENDING'                      --transaction_status_Code
                      , p_receive_rec.category_id
                      , p_receive_rec.uom_code
                      , p_receive_rec.employee_id
                      , p_receive_rec.quantity               -- Primary quantity
                      , p_receive_rec.primary_unit_of_measure -- primary unit of measure.
                      , 1------------temp---------  p_receive_rec.routing_header_id
                      , 1
                      ,'NOT INSPECTED'                -- inspection status code
                      ,'INVENTORY'                     -- destination_type code
                                 , SYSDATE,
                      'INVENTORY'                       -- destination_context
                                 ,
                      p_receive_rec.lot_control_code,
                      p_receive_rec.serial_control_code,
                      p_receive_rec.quantity            -- Source doc quantity
                                            ,
                      p_receive_rec.unit_of_measure, -- source doc unit_of measure
                      p_receive_rec.order_line_id,
                      p_receive_rec.currency_code,
                      p_receive_rec.customer_id,
                      p_receive_rec.customer_site_id,
                      -- added for internal orders
                      p_receive_rec.requisition_line_id,
                      p_Receive_rec.shipped_date,
                      p_Receive_rec.shipment_number,
                      p_Receive_rec.from_organization_id,
                      p_Receive_rec.locator_id,
                      p_Receive_rec.deliver_to_location_id,
                      p_Receive_rec.shipment_header_id,
                      p_Receive_rec.shipment_line_id,
                      l_org_id                 -- MOAC change Bug#4245577
                     )
           RETURNING interface_transaction_id
                INTO l_intf_txn_id;

--
-- Dynamic sql is being used to ensure that the code is not dependent on
-- the 11.5.0 PO code. This will be only run time dependent.(functional dependence)
         sql_str := NULL;

         IF (p_receive_rec.order_number IS NOT NULL)
         THEN
	    /**********************Commented for 4277749
            sql_str :=
                  ' UPDATE RCV_TRANSACTIONS_INTERFACE SET OE_ORDER_NUM ='
               || p_receive_rec.order_number
               || ' WHERE INTERFACE_TRANSACTION_ID='
               || l_intf_txn_id;
	   *******************************/
			-- bug fix for performance bug 4277749 begin
                 sql_str :=
                  ' UPDATE RCV_TRANSACTIONS_INTERFACE SET OE_ORDER_NUM = :1'
                    || ' WHERE INTERFACE_TRANSACTION_ID=:2' ;

			  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
			  THEN
				fnd_log.STRING
						(fnd_log.level_event,
						 'CSD.PLSQL.CSD_RECEIVE_PVT.POPULATE_RCV_INTF_TBLS',
						    'Calling execute immediate with sql['
						 || sql_str
						 || ']'
						);
			  END IF;
                 EXECUTE IMMEDIATE sql_str using p_receive_rec.order_number,l_intf_txn_id;
			-- bug fix for performance bug 4277749 End
         END IF;

	    /**********************Commented for 4277749
         IF (sql_str IS NOT NULL)
         THEN
            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                         (fnd_log.level_event,
                          'CSD.PLSQL.CSD_RECEIVE_PVT.POPULATE_RCV_INTF_TBLS',
                             'Calling execute immediate with sql['
                          || sql_str
                          || ']'
                         );
            END IF;

            EXECUTE IMMEDIATE sql_str;
         END IF;
	    ************************************************/

         IF (p_receive_rec.lot_number IS NOT NULL)
         THEN
            IF (p_receive_rec.serial_number IS NOT NULL)
            THEN
               SELECT mtl_material_transactions_s.NEXTVAL
                 INTO l_txn_tmp_id
                 FROM DUAL;
            ELSE
               l_txn_tmp_id := l_intf_txn_id;
            END IF;

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                         (fnd_log.level_event,
                          'CSD.PLSQL.CSD_RECEIVE_PVT.POPULATE_RCV_INTF_TBLS',
                             'Inserting lot interface table data for ['
                          || l_intf_txn_id
                          || ']lot number['
                          || p_receive_rec.lot_number
                          || ']'
                         );
            END IF;

            INSERT INTO mtl_transaction_lots_interface
                        (transaction_interface_id, source_code,
                         source_line_id, last_update_date, last_updated_by,
                         creation_date, created_by, last_update_login,
                         lot_number, lot_expiration_date,
                         transaction_quantity, primary_quantity,
                         serial_transaction_temp_id
                        )
                 VALUES (l_intf_txn_id, l_source_code,
                         l_source_line_id, SYSDATE, fnd_global.user_id,
                         SYSDATE, fnd_global.user_id, fnd_global.login_id,
                         p_receive_rec.lot_number, l_lot_expiration_date,
                         p_receive_rec.quantity, p_receive_rec.quantity,
                         --l_txn_tmp_id
                         decode(p_receive_rec.serial_number,null, null,l_txn_tmp_id)
                        );
       --
       -- Dynamic sql is being used to ensure that the code is not dependent on
       -- the 11.5.0 PO code. This will be only run time dependent.(functional dependence)
             sql_str :=
                'UPDATE mtl_transaction_lots_interface SET product_code=''RCV'' ';
             sql_str :=
                      sql_str
                   || ',product_transaction_id='
                   || l_intf_txn_id
			-- bug fix for performance bug 4277749 changed the where clause
			-- to use using clause
                   || ' Where transaction_interface_id = :1';

             IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
             THEN
                fnd_log.STRING
                             (fnd_log.level_event,
                              'CSD.PLSQL.CSD_RECEIVE_PVT.POPULATE_RCV_INTF_TBLS',
                                 'Calling execute immediate with sql['
                              || sql_str
                              || ']'
                             );
             END IF;

			-- bug fix for performance bug 4277749 changed the where clause
			-- to use using clause
             EXECUTE IMMEDIATE sql_str using l_intf_txn_id;

         END IF;

         --If the serial controlled rec is not null then insert records
         -- into the serial numbers interface table
         IF (p_receive_rec.serial_number IS NOT NULL)
         THEN
            IF (p_receive_rec.lot_number IS NULL)
            THEN
               l_txn_tmp_id := l_intf_txn_id;
            END IF;

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                         (fnd_log.level_event,
                          'CSD.PLSQL.CSD_RECEIVE_PVT.POPULATE_RCV_INTF_TBLS',
                             'Inserting serial interface table data for ['
                          || l_intf_txn_id
                          || ']serial number['
                          || p_receive_rec.serial_number
                          || ']'
                         );
            END IF;

            INSERT INTO mtl_serial_numbers_interface
                        (transaction_interface_id, source_code,
                         source_line_id, last_update_date, last_updated_by,
                         creation_date, created_by, last_update_login,
                         fm_serial_number,
                         to_serial_number,
                         process_flag
                        )
                 VALUES (l_txn_tmp_id, l_source_code,
                         l_source_line_id, SYSDATE, fnd_global.user_id,
                         SYSDATE, fnd_global.user_id, fnd_global.login_id,
                         p_receive_rec.serial_number,
                         p_receive_rec.serial_number,
                         l_process_flag
                        );
       --
       -- Dynamic sql is being used to ensure that the code is not dependent on
       -- the 11.5.0 PO code. This will be only run time dependent.(functional dependence)
             sql_str :=
                'UPDATE mtl_serial_numbers_interface SET product_code=''RCV'' ';
             sql_str :=
                      sql_str
                   || ',product_transaction_id='
                   || l_intf_txn_id
			-- bug fix for performance bug 4277749 changed the where clause
			-- to use using clause
                   || ' Where transaction_interface_id = :1';

             IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
             THEN
                fnd_log.STRING
                             (fnd_log.level_event,
                              'CSD.PLSQL.CSD_RECEIVE_PVT.POPULATE_RCV_INTF_TBLS',
                                 'Calling execute immediate with sql['
                              || sql_str
                              || ']'
                             );
             END IF;

			-- bug fix for performance bug 4277749 changed the where clause
			-- to use using clause
             EXECUTE IMMEDIATE sql_str using l_txn_tmp_id;

         END IF;
      END LOOP;


      -- Standard call to get message count and IF count is  get message info.
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_RECEIVE_PVT.POPULATE_RCV_INTF_TBLS',
                         'Leaving POPULATE_RCV_INTF_TBLS'
                        );
      END IF;

      COMMIT;


   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK ;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data);

         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                         (fnd_log.level_error,
                          'CSD.PLSQL.CSD_RECEIVE_PVT.POPULATE_RCV_INTF_TBLS',
                          'EXC_EXC_ERROR in populate rcv intf tbls [' || x_msg_data || ']'
                         );
         END IF;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK ;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data);

         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                         (fnd_log.level_exception,
                          'CSD.PLSQL.CSD_RECEIVE_PVT.POPULATE_RCV_INTF_TBLS',
                          'EXC_UNEXPECTED_ERROR in populate rcv intf tbls[' || x_msg_data || ']'
                         );
         END IF;
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK ;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data);

         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                         (fnd_log.level_unexpected,
                          'CSD.PLSQL.CSD_RECEIVE_PVT.POPULATE_RCV_INTF_TBLS',
                          'SQL Message in populate rcv intf tbls[' || SQLERRM || ']'
                         );
         END IF;
   END populate_rcv_intf_tbls;


/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: RCV_REQ_ONLINE                                                                          */
/* description   : This API will submit the request for receiving in the online mode.                       */
/* Called from   : */
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
/*                                                            default value is fnd_api.g_false               */
/*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
/*                                                            fnd_api.g_false                                */
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.                             */
/*                 p_request_group_id    NUMBER      Required  The request group for which the receiving     */
/*                                                             processor
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE rcv_req_online (
      p_api_version              IN       NUMBER,
      p_commit                   IN       VARCHAR2,
      p_init_msg_list            IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_request_group_id         IN       NUMBER
   )
   IS
      --pragma AUTONOMOUS_TRANSACTION;
      l_api_version_number   CONSTANT NUMBER                           := 1.0;
      l_api_name             CONSTANT VARCHAR2 (30)       := 'RCV_REQ_ONLINE';
      l_ret_code                      NUMBER;
      l_outcome                       VARCHAR2 (200);
      l_message                       fnd_new_messages.MESSAGE_TEXT%TYPE;
      r_val1                          VARCHAR2 (200);
      r_val2                          VARCHAR2 (200);
      r_val3                          VARCHAR2 (200);
      r_val4                          VARCHAR2 (200);
      r_val5                          VARCHAR2 (200);
      r_val6                          VARCHAR2 (200);
      r_val7                          VARCHAR2 (200);
      r_val8                          VARCHAR2 (200);
      r_val9                          VARCHAR2 (200);
      r_val10                         VARCHAR2 (200);
      r_val11                         VARCHAR2 (200);
      r_val12                         VARCHAR2 (200);
      r_val13                         VARCHAR2 (200);
      r_val14                         VARCHAR2 (200);
      r_val15                         VARCHAR2 (200);
      r_val16                         VARCHAR2 (200);
      r_val17                         VARCHAR2 (200);
      r_val18                         VARCHAR2 (200);
      r_val19                         VARCHAR2 (200);
      r_val20                         VARCHAR2 (200);
      x_progress                      VARCHAR2 (4);
      l_TIMEOUT                         NUMBER;
      l_str1                          fnd_new_messages.MESSAGE_TEXT%TYPE
;
      l_str2                          fnd_new_messages.MESSAGE_TEXT%TYPE
;
      l_phase                         VARCHAR2 (200);
      l_status                        VARCHAR2 (200);
      l_dev_phase                     VARCHAR2 (200);
      l_dev_status                    VARCHAR2 (200);
      l_success                       BOOLEAN;
      l_msg_index_out                 NUMBER;
      l_index                         NUMBER;
      -- 12.1.2 Bulk Receive ER FP, subhat
      l_req_id                        NUMBER;
   BEGIN


      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_RECEIVE_PVT.RCV_REQ_ONLINE.BEGIN',
                         'Entered RCV_REQ_ONLINE'
                        );
      END IF;
      x_progress := '000';
      l_TIMEOUT  := 300;
      l_ret_code := 0;

      -- Standard Start of API savepoint
      SAVEPOINT sp_rcv_req_online;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         -- initialize message list
         fnd_msg_pub.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version_number,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- initialize return status
      x_return_status := fnd_api.g_ret_sts_success;

      /*
      ** Set the cursor style to working
      */

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         'CSD.PLSQL.CSD_RECEIVE_PVT.RCV_REQ_ONLINE',
                            'Calling receiving processor with req group id['
                         || p_request_group_id
                         || ']'
                        );
      END IF;

	-- 12.1.2 Bulk Receive ER FP, subhat.
	-- If the invoking target is bulk receiving, use the IMMEDIATE mode instead of ONLINE mode.
	-- IMMEDIATE mode gives record level control, where in only the errored records are rolled back.

	if NVL(csd_bulk_receive_pvt.g_bulk_rcv_conc,'N') = 'N' then
      l_ret_code :=
         fnd_transaction.synchronous (l_TIMEOUT,
                                      l_outcome,
                                      l_MESSAGE,
                                      'PO',
                                      'RCVTPO',
                                      'ONLINE',
                                      p_request_group_id,
                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                      NULL, NULL, NULL, NULL, NULL, NULL
                                     );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         'CSD.PLSQL.CSD_RECEIVE_PVT.RCV_REQ_ONLINE',
                            'receiving processor, rc=['
                         || l_ret_code
                         || '],message['
                         || l_MESSAGE
                         || ']l_outcome['
                         || l_outcome
                         || ']'
                        );
      END IF;

      IF l_ret_code <> 0 THEN
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
         THEN
            FOR l_index IN 1 .. fnd_msg_pub.count_msg
            LOOP
               fnd_msg_pub.get (p_msg_index          => l_index,
                                p_encoded            => 'F',
                                p_data               => l_MESSAGE,
                                p_msg_index_out      => l_msg_index_out
                               );
               fnd_log.STRING (fnd_log.level_error,
                               'CSD.PLSQL.CSD_RECEIVE_PVT.RCV_REQ_ONLINE',
                               'receiving processor, error[' || l_MESSAGE || ']'
                              );
            END LOOP;
         END IF;
      --FND_MESSAGE.SET_NAME('CSD', 'CSD_RECEIVE_ERROR');
      --FND_MSG_PUB.ADD;
      --RAISE FND_API.G_EXC_ERROR;
      END IF;

--   dbms_output.put_line('outcome=[-'||outcome||'-]');
--   dbms_output.put_line('message=[-'||message||'-]');

      /*
      ** E_SUCCESS constant number    := 0;           -- e_code is success
      ** E_TIMEOUT constant number    := 1;           -- e_code is timeout
      ** E_NOMGR   constant number    := 2;           -- e_code is no manager
      ** E_OTHER   constant number    := 3;           -- e_code is other
      */
      IF (l_ret_code = 0 AND (l_outcome NOT IN ('WARNING', 'ERROR')))
      THEN
         NULL;
      ELSIF (l_ret_code = 1)
      THEN
         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_event,
                            'CSD.PLSQL.CSD_RECEIVE_PVT.RCV_REQ_ONLINE',
                            'fnd_trnasaction.synchronous  TIMED OUT'
                           );
         END IF;

         IF (check_group_id (p_request_group_id))
         THEN
            fnd_message.set_name ('FND', 'TM-TIMEOUT');
            l_str1 := fnd_message.get;
            fnd_message.CLEAR;
            -- use rcv_all_rcvoltm to get translated message
            fnd_message.set_name ('PO', 'RCV_ALL_RCVOLTM');
            l_str2 := fnd_message.get;
            fnd_message.CLEAR;
            fnd_message.set_name ('FND', 'CONC-ERROR RUNNING STANDALONE');
            fnd_message.set_token ('PROGRAM', l_str2);
            fnd_message.set_token ('REQUEST', p_request_group_id);
            fnd_message.set_token ('REASON', l_str1);
            --fnd_message.show;
            fnd_msg_pub.ADD;
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      ELSIF (l_Ret_code = 2)
      THEN
         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
               (fnd_log.level_event,
                'CSD.PLSQL.CSD_RECEIVE_PVT.RCV_REQ_ONLINE',
                   'fnd_trnasaction.synchronous: no concurrent manager available,groupid['
                || TO_CHAR (p_request_group_id)
                || ']'
               );
         END IF;

         IF (check_group_id (p_request_group_id))
         THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               'CSD.PLSQL.CSD_RECEIVE_PVT.RCV_REQ_ONLINE',
                                  'Adding FND message, groupid['
                               || TO_CHAR (p_request_group_id)
                               || ']'
                              );
            END IF;

            fnd_message.set_name ('FND', 'TM-SVC LOCK HANDLE FAILED');
            l_str1 := fnd_message.get;
            fnd_message.CLEAR;
            fnd_message.set_name ('PO', 'RCV_ALL_RCVOLTM');
            l_str2 := fnd_message.get;
            fnd_message.CLEAR;
            fnd_message.set_name ('FND', 'CONC-ERROR RUNNING STANDALONE');
            fnd_message.set_token ('PROGRAM', l_str2);
            fnd_message.set_token ('REQUEST', p_request_group_id);
            fnd_message.set_token ('REASON', l_str1);

            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.MESSAGE (fnd_log.level_error,
                                'CSD.PLSQL.CSD_RECEIVE_PVT.RCV_REQ_ONLINE');
            END IF;

            fnd_msg_pub.ADD;
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      ELSIF (l_ret_code = 3 OR (l_outcome IN ('WARNING', 'ERROR')))
      THEN
         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_event,
                            'CSD.PLSQL.CSD_RECEIVE_PVT.RCV_REQ_ONLINE',
                               'fnd_synschronous:rc['
                            || l_Ret_code
                            || '],outcome['
                            || l_outcome
                            || '],for request group['
                            || p_request_group_id
                            || ']'
                           );
         END IF;

         log_error_stack ();
         --IF (check_group_id(p_request_group_id)) THEN
         x_progress := '010';
         l_Ret_Code :=
            fnd_transaction.get_values (r_val1,
                                        r_val2,
                                        r_val3,
                                        r_val4,
                                        r_val5,
                                        r_val6,
                                        r_val7,
                                        r_val8,
                                        r_val9,
                                        r_val10,
                                        r_val11,
                                        r_val12,
                                        r_val13,
                                        r_val14,
                                        r_val15,
                                        r_val16,
                                        r_val17,
                                        r_val18,
                                        r_val19,
                                        r_val20
                                       );
         l_str1 := r_val1;

         IF (r_val2 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val2;
         END IF;

         IF (r_val3 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val3;
         END IF;

         IF (r_val4 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val4;
         END IF;

         IF (r_val5 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val5;
         END IF;

         IF (r_val6 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val6;
         END IF;

         IF (r_val7 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val7;
         END IF;

         IF (r_val8 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val8;
         END IF;

         IF (r_val9 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val9;
         END IF;

         IF (r_val10 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val10;
         END IF;

         IF (r_val11 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val11;
         END IF;

         IF (r_val12 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val12;
         END IF;

         IF (r_val13 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val13;
         END IF;

         IF (r_val14 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val14;
         END IF;

         IF (r_val15 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val15;
         END IF;

         IF (r_val16 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val16;
         END IF;

         IF (r_val17 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val17;
         END IF;

         IF (r_val18 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val18;
         END IF;

         IF (r_val19 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val19;
         END IF;

         IF (r_val20 IS NOT NULL)
         THEN
            l_str1 := l_str1 || r_val20;
         END IF;

         FND_MESSAGE.SET_NAME('CSD','CSD_AUTO_RCV_ERROR');
         FND_MESSAGE.SET_TOKEN('RCV_ERROR',l_Str1);
         FND_MSG_PUB.add;

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_event,
                            'CSD.PLSQL.CSD_RECEIVE_PVT.RCV_REQ_ONLINE',
                            'fnd_trnasaction.synchronous:[' || l_str1 || ']'
                           );
         END IF;

         x_return_status := fnd_api.g_ret_sts_error;
      --END IF;
      END IF;
	 -- 12.1.2 Bulk Receive ER FP, subhat.
	 -- when the request is submitted from Bulk Receive Page,
	 -- launch the concurrent request in IMMEDIATE mode.
	  else

     	l_req_id := fnd_request.submit_request(application => 'PO',
      										   program     => 'RVCTP',
      										   sub_request => true,
      										   argument1   => 'IMMEDIATE',
                            			       argument2   => p_request_group_id
											    );

    	-- after submitting the request, put the parent in the paused status.
    	-- if the parent is not put into paused status, child may not get launched properly.
    	-- the request group id will be used for post processing.
    	fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
    								request_data => to_char(p_request_group_id));


    	-- Put the concurrent Id to global variable. This will be used in process bulk receive API
     	csd_bulk_receive_pvt.g_conc_req_id := l_req_id;

      end if;
      -- end 12.1.2 Bulk Receive ER FP, subhat..
      -- Standard call to get message count and IF count is  get message info.
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_RECEIVE_PVT.RCV_REQ_ONLINE.END',
                         'Leaving RCV_REQ_ONLINE'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO sp_rcv_req_online;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data);

         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            'CSD.PLSQL.CSD_RECEIVE_PVT.RCV_REQ_ONLINE',
                            'EXC_ERROR[' || x_msg_data || ']'
                           );
         END IF;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK TO sp_rcv_req_online;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data);

         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_exception,
                            'CSD.PLSQL.CSD_RECEIVE_PVT.RCV_REQ_ONLINE',
                            'EXC_UNEXPECTED_ERROR  in RCV_REQ_ONLINE[' || x_msg_data || ']'
                           );
         END IF;
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK TO sp_rcv_req_online;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data);

         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            'CSD.PLSQL.CSD_RECEIVE_PVT.RCV_REQ_ONLINE',
                            'SQL Error MEssage in RCV_REQ_ONLINE[' || SQLERRM || ']'
                           );
         END IF;
   END rcv_req_online;

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: DELETE_INTF_TBLS                                                                          */
/* description   : Deletes records in RCV_HEADERS_INTERFACE, RCV_TRANSACTIONS_INTERFACE., PO_INTERFACE_ERRORS*/
/*                 MTL_TRANSACTION_LOTS_INTERFACE_TBL, MTL_SERIAL_NUMBERS_INTERFACE_TBL tables.                                                                                   */
/* Called from   : receive_item api                                                                          */
/* Input Parm    :                                                                                           */
/*                 p_request_group_id            NUMBER      Required                                                */
/*                 p_interface_transaction_Id    NUMBER      Required                                                */
/*                 p_interface_header_Id         NUMBER      Required                                                */
/* Output Parm   : x_return_status               VARCHAR2    Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE delete_intf_tbls (
      x_return_status      OUT NOCOPY      VARCHAR2,
      p_request_group_id   IN              NUMBER
   )
   IS
      pragma AUTONOMOUS_TRANSACTION;
      l_api_version_number   CONSTANT NUMBER        := 1.0;
      l_api_name             CONSTANT VARCHAR2 (30) := 'Delete_Intf_Tbls';
      l_txn_temp_id          NUMBER ;

--Cursor to get the headers interface records.
      CURSOR cur_headers(p_group_Id NUMBER) is
        SELECT HEADER_INTERFACE_ID
        FROM RCV_HEADERS_INTERFACE
        WHERE GROUP_ID = p_group_id;
--Cursor to get the transactions interface records.
      CURSOR cur_transactions(p_group_Id NUMBER) is
        SELECT INTERFACE_TRANSACTION_ID
        FROM RCV_TRANSACTIONS_INTERFACE
        WHERE GROUP_ID = p_group_id;
   BEGIN

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_RECEIVE_PVT.DELETE_INTF_TBLS.BEGIN',
                         'Entered Delete_Intf_Tbls'
                        );
      END IF;

      -- initialize return status
      x_return_status := fnd_api.g_ret_sts_success;


      -----------------------------------------------Delete from errors table
      FOR l_hdr_rec in cur_headers(p_request_group_id) LOOP
          BEGIN
             DELETE FROM po_interface_errors err
                   WHERE err.interface_header_id = l_hdr_Rec.header_interface_id;

          EXCEPTION
             WHEN NO_DATA_FOUND
             THEN
                NULL;
             WHEN OTHERS
             THEN
                RAISE fnd_api.g_exc_unexpected_error;
          END;
      END LOOP;

      FOR l_txn_rec in cur_transactions(p_request_group_id) LOOP
          BEGIN
             DELETE FROM po_interface_errors err
                   WHERE err.interface_transaction_id = l_txn_rec.interface_transaction_id;

          EXCEPTION
             WHEN NO_DATA_FOUND
             THEN
                NULL;
             WHEN OTHERS
             THEN
                RAISE fnd_api.g_exc_unexpected_error;
          END;
      END LOOP;

      ----------------------------------------------Delete from the MTL lots/MTL serial numbers
      --------------------------------------------- interface table.
      FOR l_txn_rec in cur_transactions(p_request_group_id) LOOP
          BEGIN
             DELETE FROM mtl_transaction_lots_interface
                   WHERE TRANSACTION_INTERFACE_ID = l_txn_rec.interface_transaction_Id
                   RETURNING SERIAL_TRANSACTION_TEMP_ID into l_txn_temp_id;

             DELETE FROM mtl_serial_numbers_interface
                   WHERE (TRANSACTION_INTERFACE_ID = l_txn_rec.interface_transaction_Id
                         OR TRANSACTION_INTERFACE_ID = l_txn_temp_id);
          EXCEPTION
             WHEN NO_DATA_FOUND
             THEN
                NULL;
             WHEN OTHERS
             THEN
                RAISE fnd_api.g_exc_unexpected_error;
          END;
      END LOOP;

      ----------------------------------------------Delete from headers table.
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         'CSD.PLSQL.CSD_RECEIVE_PVT.DELETE_INTF_TBLS',
                         'Deleting from the headers table'
                        );
      END IF;

      BEGIN
         DELETE FROM rcv_headers_interface
               WHERE GROUP_ID = p_request_group_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
      END;
      ----------------------------------------------Delete from the detail txn records.
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         'CSD.PLSQL.CSD_RECEIVE_PVT.DELETE_INTF_TBLS',
                         'Deleting from the detail table'
                        );
      END IF;

      BEGIN
         DELETE FROM rcv_transactions_interface
               WHERE GROUP_ID = p_request_group_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
      END;


      COMMIT;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_RECEIVE_PVT.DELETE_INTF_TBLS.END',
                         'Leaving DELETE_INTF_TBLS'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK ;
         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_exception,
                            'CSD.PLSQL.CSD_RECEIVE_PVT.DELETE_INTF_TBLS',
                            'EXC_UNEXPECTED_ERROR in delete_intf_tbls'
                           );
         END IF;
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            'CSD.PLSQL.CSD_RECEIVE_PVT.DELETE_INTF_TBLS',
                            'SQL Message in delete_intf_tbls[' || SQLERRM || ']'
                           );
         END IF;
   END delete_intf_tbls;


/*=============================================================

  FUNCTION NAME:     check_group_id

=============================================================*/
   FUNCTION check_group_id (
      p_group_id                 IN       NUMBER
   )
      RETURN BOOLEAN
   IS
      l_rec_count   NUMBER := 0;
   BEGIN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_RECEIVE_PVT.CHECK_GROUP_ID.BEGIN',
                         'Entered check_group_id, groupid[' || p_group_id
                         || ']'
                        );
      END IF;

      SELECT COUNT (1)
        INTO l_rec_count
        FROM rcv_transactions_interface
       WHERE GROUP_ID = p_group_id;

      IF (l_rec_count = 0)
      THEN
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            'CSD.PLSQL.CSD_RECEIVE_PVT.CHECK_GROUP_ID.END',
                            'returning false from check_group_id'
                           );
         END IF;

         RETURN (FALSE);
      ELSE
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            'CSD.PLSQL.CSD_RECEIVE_PVT.CHECK_GROUP_ID.END',
                            'returning true from check_group_id'
                           );
         END IF;

         RETURN (TRUE);
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN (FALSE);
      WHEN OTHERS
      THEN
         RAISE;
   END check_group_id;

/****************************************************************
Dupms the input receive table records in to log
*****************************************************************/
   PROCEDURE dump_receive_tbl (
      p_receive_tbl              IN       csd_receive_util.rcv_tbl_type,
      p_level                             NUMBER,
      p_module                            VARCHAR2
   )
   IS
      i   INTEGER;
   BEGIN
	 FOR i IN p_receive_tbl.FIRST .. p_receive_tbl.LAST
	 LOOP
	    IF (p_level >= fnd_log.g_current_runtime_level)
	    THEN
		 fnd_log.STRING (p_level, p_module,
				    TO_CHAR (i)
				 || ':'
				 || TO_CHAR (p_receive_tbl (i).customer_id)
				);
		 fnd_log.STRING (p_level, p_module,
				    TO_CHAR (i)
				 || ':'
				 || TO_CHAR (p_receive_tbl (i).customer_site_id)
				);
		 fnd_log.STRING (p_level, p_module,
				    TO_CHAR (i)
				 || ':'
				 || TO_CHAR (p_receive_tbl (i).employee_id)
				);
		 fnd_log.STRING (p_level,
				 p_module,
				    TO_CHAR (i)
				 || ':'
				 || TO_CHAR (p_receive_tbl (i).quantity)
				);
		 fnd_log.STRING (p_level,
				 p_module,
				 TO_CHAR (i) || ':' || p_receive_tbl (i).uom_code
				);
		 fnd_log.STRING (p_level,
				 p_module,
				    TO_CHAR (i)
				 || ':'
				 || TO_CHAR (p_receive_tbl (i).inventory_item_id)
				);
		 fnd_log.STRING (p_level,
				 p_module,
				 TO_CHAR (i) || ':' || p_receive_tbl (i).item_revision
				);
		 fnd_log.STRING (p_level,
				 p_module,
				    TO_CHAR (i)
				 || ':'
				 || TO_CHAR (p_receive_tbl (i).to_organization_id)
				);
		 fnd_log.STRING (p_level,
				 p_module,
				    TO_CHAR (i)
				 || ':'
				 || p_receive_tbl (i).destination_type_code
				);
		 fnd_log.STRING (p_level,
				 p_module,
				 TO_CHAR (i) || ':' || p_receive_tbl (i).subinventory
				);
		 fnd_log.STRING (p_level,
				 p_module,
				    TO_CHAR (i)
				 || ':'
				 || TO_CHAR (p_receive_tbl (i).locator_id)
				);
		 fnd_log.STRING (p_level,
				 p_module,
				    TO_CHAR (i)
				 || ':'
				 || TO_CHAR (p_receive_tbl (i).deliver_to_location_id)
				);
		 fnd_log.STRING (p_level,
				 p_module,
				    TO_CHAR (i)
				 || ':'
				 || TO_CHAR (p_receive_tbl (i).requisition_number)
				);
		 fnd_log.STRING (p_level,
				 p_module,
				    TO_CHAR (i)
				 || ':'
				 || TO_CHAR (p_receive_tbl (i).order_header_id)
				);
		 fnd_log.STRING (p_level,
				 p_module,
				    TO_CHAR (i)
				 || ':'
				 || TO_CHAR (p_receive_tbl (i).order_line_id)
				);
		 fnd_log.STRING (p_level,
				 p_module,
				 TO_CHAR (i) || ':' || p_receive_tbl (i).order_number
				);
		 fnd_log.STRING (p_level,
				 p_module,
				 TO_CHAR (i) || ':' || p_receive_tbl (i).doc_number
				);
		 fnd_log.STRING (p_level,
				 p_module,
				    TO_CHAR (i)
				 || ':'
				 || p_receive_tbl (i).internal_order_flag
				);
		 fnd_log.STRING (p_level,
				 p_module,
				    TO_CHAR (i)
				 || ':'
				 || TO_CHAR (p_receive_tbl (i).from_organization_id)
				);
		 fnd_log.STRING (p_level,
				 p_module,
				    TO_CHAR (i)
				 || ':'
				 || TO_CHAR (p_receive_tbl (i).expected_receipt_date)
				);
		 fnd_log.STRING (p_level,
				 p_module,
				    TO_CHAR (i)
				 || ':'
				 || TO_CHAR (p_receive_tbl (i).transaction_date)
				);
		 fnd_log.STRING (p_level,
				 p_module,
				    TO_CHAR (i)
				 || ':'
				 || TO_CHAR (p_receive_tbl (i).ship_to_location_id)
				);
        END IF;
	 END LOOP;
   END dump_receive_tbl;

   /*************procedure to log the error stack..........
   ****************/
   PROCEDURE log_error_stack
   IS
      l_count       NUMBER;
      l_msg         VARCHAR2 (2000);
      l_index_out   NUMBER;
   BEGIN
      l_count := fnd_msg_pub.count_msg ();

      IF (l_count > 0)
      THEN
         FOR i IN 1 .. l_count
         LOOP
            fnd_msg_pub.get (p_msg_index          => i,
                             p_encoded            => 'F',
                             p_data               => l_msg,
                             p_msg_index_out      => l_index_out
                            );

            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_error,
                               'CSD.PLSQL.CSD_RECEIVE_PVT.log_error_stack',
                               'error[' || l_msg || ']'
                              );
            END IF;
         END LOOP;
      END IF;
   END log_error_stack;
END csd_receive_pvt;

/

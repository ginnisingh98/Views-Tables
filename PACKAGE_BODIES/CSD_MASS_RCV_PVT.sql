--------------------------------------------------------
--  DDL for Package Body CSD_MASS_RCV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_MASS_RCV_PVT" AS
/* $Header: csdvmssb.pls 120.8.12010000.7 2010/01/09 01:01:13 takwong ship $ */
--
-- Purpose: To  mass process repair orders
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- ---------   ------   ------------------------------------------
-- vparvath   05/27/03  Created new package body
------------------------------------------------------------------------------------
   g_pkg_name    CONSTANT VARCHAR2 (30) := 'CSD_MASS_RCV_PVT';
   g_file_name   CONSTANT VARCHAR2 (30) := 'csdvmssb.pls';

   TYPE number_arr IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

--local proc declarations
   PROCEDURE validate_product_txn_rec (
      p_product_txn_rec   IN   csd_process_pvt.product_txn_rec
   );

   PROCEDURE log_error_stack;

   FUNCTION is_item_pre_serialized (p_inv_item_id IN NUMBER)
      RETURN BOOLEAN;


   PROCEDURE validate_order (
      p_est_detail_id   IN              NUMBER,
      p_order_rec       IN OUT NOCOPY   csd_process_pvt.om_interface_rec,
      x_booked_flag     OUT NOCOPY      VARCHAR2
   );

   procedure upd_instance(p_repair_type_ref IN  VARCHAR2,
                          p_serial_number   IN  VARCHAR2,
                          p_instance_id     IN  NUMBER,
                          x_prod_txn_tbl    IN OUT NOCOPY   csd_process_pvt.product_txn_tbl
                         ) ;


   -- This procedure will be called from the Serial number capture screen, when user clicks the OK button
   -- It is a wrapper API, which subsequntly calls other API
   PROCEDURE mass_create_ro (
      p_api_version            IN              NUMBER,
      p_commit                 IN              VARCHAR2,
      p_init_msg_list          IN              VARCHAR2,
      p_validation_level       IN              NUMBER,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      p_repair_order_line_id   IN              NUMBER,
      p_add_to_order_flag      IN              VARCHAR2
   )
   IS
      l_api_version_number   CONSTANT NUMBER                          := 1.0;
      l_api_name             CONSTANT VARCHAR2 (30)       := 'MASS_CREATE_RO';
      l_return_status                 VARCHAR2 (1);
      l_msg_count                     NUMBER;
      l_msg_data                      VARCHAR2 (2000);
      l_repair_order_tbl              csd_repairs_pub.repln_tbl_type;
      l_prod_txn_tbl                  csd_process_pvt.product_txn_tbl;
      l_incident_id                   NUMBER;
      l_count_sn                         NUMBER;
      l_ro_qty                        NUMBER;
      l_count_sn_success              NUMBER;
      l_count_sn_blank                NUMBER;
      l_new_repln_id                  NUMBER;
      l_index_out                     NUMBER;
      l_item_id                       NUMBER;
      l_repair_line_status            VARCHAR2 (10);
      l_ib_trackable                  BOOLEAN;

      l_debug_level                   NUMBER ;
      l_stmt_level                    NUMBER ;
      l_event_level                   NUMBER ;
      c_draft_Status                  VARCHAR2(1);

      --Cursor to get the repair order record data and serial number data.
      CURSOR cur_sn_rec (p_repln_id NUMBER)
      IS
         SELECT instance_id, serial_number,mass_ro_sn_id
           FROM csd_mass_ro_sn
          WHERE repair_line_id = p_repln_id;

      CURSOR cur_repair_order( p_repln_id NUMBER)
      IS
         SELECT inventory_item_id, status, quantity
           FROM csd_repairs
           WHERE repair_line_id = p_repln_id;

   BEGIN

      SAVEPOINT sp_mass_create_ro;

	 l_return_status := fnd_api.g_ret_sts_success;
      l_debug_level   := fnd_log.g_current_runtime_level;
      l_stmt_level    := fnd_log.level_statement;
      l_event_level   := fnd_log.level_event;
      c_draft_Status  := 'D';

      IF (fnd_log.level_procedure >= l_debug_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO.BEGIN',
                         '-------------Entered Mass_Create_RO----------------'
                        );
      END IF;


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

      -- Purge the errors from generic errors table
      --Delete records from the CSD_GENRIC_ERRMSGS table.
      IF (l_event_level >= l_debug_level)
      THEN
         fnd_log.STRING (l_event_level,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO',
                         '-----purging the previous processing errors----'
                        );
      END IF;

      csd_gen_errmsgs_pvt.purge_entity_msgs
                            (p_api_version                  => 1.0,
                             x_return_status                => l_return_status,
                             x_msg_count                    => l_msg_count,
                             x_msg_data                     => l_msg_data,
                             p_module_code                  => 'SN',
                             p_source_entity_id1            => p_repair_order_line_id,
                             p_source_entity_type_code      => NULL,
                             p_source_entity_id2            => NULL
                            );
      IF (l_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      IF (l_event_level >= l_debug_level)
      THEN
         fnd_log.STRING
                   (l_event_level,
                    'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO',
                    '---after the call to CSD_GEN_ERRMSGS_PVT.PURGE_ENTITY_MSGS-----'
                   );
      END IF;


      -- get the repair order details.
      OPEN cur_repair_order (p_repair_order_line_id);

      FETCH cur_repair_order
       INTO l_item_id, l_repair_line_status, l_ro_qty;

      CLOSE cur_repair_order;

      --Validations: If te status of repair order is not 'Draft' then raise error.
      IF NVL (l_repair_line_status, ' ') <> c_draft_status
      THEN
         fnd_message.set_name ('CSD', 'CSD_INVALID_REPAIR_ORDER');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_event_level >= l_debug_level)
      THEN
         fnd_log.STRING (l_event_level,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO',
                         '-----------------Creating product transactions------------'
                        );
      END IF;

      --Call buil_prod_txn_tbl to create product transactions for each repair order.
      -- THis call will use serial number as null and instance id as -1. These fields
      -- are update later.
      CSD_PROCESS_UTIL.build_prodtxn_tbl_int(p_Repair_line_id => p_repair_order_line_id,
                            p_quantity       => 1,
                            p_serial_number  => '',
                            p_instance_id    => -1,
                            x_prod_txn_tbl   => l_prod_txn_tbl,
                            x_return_status  => x_return_status);

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_stmt_level >= l_debug_level)
      THEN
         fnd_log.STRING (l_stmt_level,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO',
                            'Count of product transactions created=['
                         || l_prod_txn_tbl.COUNT
                         || ']'
                        );
      END IF;

--Loop through CSD_MASS_RO_SN table records for the given repair order line id
-- and create repair order lines and product transactions for all the entered
-- serial numbers.

      -- l_count indicates the count of saved serial numbers.
      l_count_sn := 0;
      l_count_sn_success := 0;

      IF (l_event_level >= l_debug_level)
      THEN
         fnd_log.STRING (l_event_level,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO',
                            '---------------Start processing for repair lineid=['
                         || p_repair_order_line_id
                         || ']------------'
                        );
      END IF;

      FOR l_repair_order_sn_rec IN cur_sn_rec (p_repair_order_line_id)
      LOOP
         --Increment the array index
         l_count_sn := l_count_sn + 1;

         IF (l_stmt_level >= l_debug_level)
         THEN
            fnd_log.STRING (l_stmt_level,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO',
                               'Serial Number=['
                            || l_repair_order_sn_rec.serial_number
                            || ']'
                           );
            fnd_log.STRING (l_stmt_level,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO',
                               'Instance id=['
                            || TO_CHAR
                                      (l_repair_order_sn_rec.instance_id
                                      )
                            || ']'
                           );
         END IF;
         -- This save point is to make sure only the failed serial number is
         -- rolled back and the processing continues with the next serial number.
         SAVEPOINT sp_process_ro_start;
         l_return_status := fnd_api.g_ret_sts_success;

         --Call Process_RO with l_repair_order_tbl(i), Add_to_Order_flag, Mro_Serial_Number
         process_ro (p_api_version            => 1.0,
                     p_commit                 => fnd_api.g_false,
                     p_init_msg_list          => fnd_api.g_false,
                     p_validation_level       => fnd_api.g_valid_level_full,
                     x_return_status          => l_return_status,
                     x_msg_count              => l_msg_count,
                     x_msg_data               => l_msg_data,
                     p_repair_line_id   => p_repair_order_line_id,
                     p_prod_txn_tbl           => l_prod_txn_tbl,
                     p_add_to_order_flag      => p_add_to_order_flag,
                     p_mass_ro_sn_id          => l_repair_order_sn_rec.mass_ro_sn_id,
                     p_serial_number          => l_repair_order_sn_rec.serial_number,
                     p_instance_id            => l_repair_order_sn_rec.instance_id,
                     x_new_repln_id           => l_new_repln_id
                    );

         --If the return_status <> 'S' then
         --Insert a record in  CSD_MASS_RO_SN_ERRORS with the error message.
         IF (l_return_status = fnd_api.g_ret_sts_success)
         THEN
             IF (l_event_level >= l_debug_level)
             THEN
                fnd_log.STRING (l_event_level,
                                'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO',
                                   'Created the new repair order, repair line id=['
                                || l_new_repln_id
                                || ']'
                               );
             END IF;
             l_count_sn_success := l_count_sn_success + 1;
             csd_repairs_pvt.copy_attachments
                         (p_api_version           => 1.0,
                          p_commit                => fnd_api.g_false,
                          p_init_msg_list         => fnd_api.g_false,
                          p_validation_level      => fnd_api.g_valid_level_full,
                          p_original_ro_id        => p_repair_order_line_id,
                          p_new_ro_id             => l_new_repln_id,
                          x_return_status         => l_return_status,
                          x_msg_count             => l_msg_count,
                          x_msg_data              => l_msg_data
                         );
         --Error handling TBD
         ELSE
            --Rollback to Save point Process_RO
            ROLLBACK TO sp_process_ro_start;
            -- Select error messages from stack and insert into CSD_MASS_RO_SN_ERRORS
            csd_gen_errmsgs_pvt.save_fnd_msgs
                      (p_api_version                  => 1.0,
                       x_return_status                => l_return_status,
                       x_msg_count                    => l_msg_count,
                       x_msg_data                     => l_msg_data,
                       p_module_code                  => 'SN',
                       p_source_entity_id1            => p_repair_order_line_id,
                       p_source_entity_type_code      => 'SERIAL_NUMBER',
                       p_source_entity_id2            => l_repair_order_sn_rec.mass_ro_sn_id
                      );

            IF (l_return_status <> fnd_api.g_ret_sts_success)
            THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            l_return_status := fnd_api.g_ret_sts_success;
         END IF;

      END LOOP;

      IF (l_event_level >= l_debug_level)
      THEN
         fnd_log.STRING (l_event_level,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO',
                            'No. of serial numbers processed successfully=['
                         || TO_CHAR (l_count_sn_success)
                         || ']'
                        );
      END IF;



      --Process rows with blank serial numbes for non Ib items.
      l_ib_trackable :=   is_item_ib_trackable (l_item_id);

      IF (NOT l_ib_trackable)
      THEN
         l_count_sn_blank := l_ro_qty - l_count_sn;
         l_count_sn       := l_ro_qty;

         IF (l_event_level >= l_debug_level)
         THEN
            fnd_log.STRING (l_event_level,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO',
                               'Num of blank sn being added= ['
                            || TO_CHAR (l_count_sn_blank)
                            || ']'
                           );
         END IF;

         WHILE (l_count_sn_blank > 0)
         LOOP
             l_count_sn_blank := l_count_sn_blank - 1;
             -- This save point is to make sure only the failed serial number is
             -- rolled back and the processing continues with the next serial number.
             SAVEPOINT sp_process_ro_start;
             l_return_status := fnd_api.g_ret_sts_success;

             --Call Process_RO with l_repair_order_tbl(i), Add_to_Order_flag, Mro_Serial_Number
             process_ro (p_api_version            => 1.0,
                         p_commit                 => fnd_api.g_false,
                         p_init_msg_list          => fnd_api.g_false,
                         p_validation_level       => fnd_api.g_valid_level_full,
                         x_return_status          => l_return_status,
                         x_msg_count              => l_msg_count,
                         x_msg_data               => l_msg_data,
                         p_repair_line_id         => p_repair_order_line_id,
                         p_prod_txn_tbl           => l_prod_txn_tbl,
                         p_add_to_order_flag      => p_add_to_order_flag,
                         p_mass_ro_sn_id          => -1,
                         p_serial_number          => null,
                         p_instance_id            => null,
                         x_new_repln_id           => l_new_repln_id
                        );

             --If the return_status <> 'S' then
             --Insert a record in  CSD_MASS_RO_SN_ERRORS with the error message.
             IF (l_return_status = fnd_api.g_ret_sts_success)
             THEN
                l_count_sn_success := l_count_sn_success + 1;
                csd_repairs_pvt.copy_attachments
                            (p_api_version           => 1.0,
                             p_commit                => fnd_api.g_false,
                             p_init_msg_list         => fnd_api.g_false,
                             p_validation_level      => fnd_api.g_valid_level_full,
                             p_original_ro_id        => p_repair_order_line_id,
                             p_new_ro_id             => l_new_repln_id,
                             x_return_status         => l_return_status,
                             x_msg_count             => l_msg_count,
                             x_msg_data              => l_msg_data
                            );
             --Error handling TBD
             ELSE
                --Rollback to Save point Process_RO
                ROLLBACK TO sp_process_ro_start;
                -- Select error messages from stack and insert into CSD_MASS_RO_SN_ERRORS
                csd_gen_errmsgs_pvt.save_fnd_msgs
                          (p_api_version                  => 1.0,
                           x_return_status                => l_return_status,
                           x_msg_count                    => l_msg_count,
                           x_msg_data                     => l_msg_data,
                           p_module_code                  => 'SN',
                           p_source_entity_id1            => p_repair_order_line_id,
                           p_source_entity_type_code      => 'SERIAL_NUMBER',
                           p_source_entity_id2            => -1
                          );

                IF (l_return_status <> fnd_api.g_ret_sts_success)
                THEN
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                l_return_status := fnd_api.g_ret_sts_success;
             END IF;

             IF (l_event_level >= l_debug_level)
             THEN
                fnd_log.STRING (l_event_level,
                                'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO',
                                   'Created the new repair order, repair line id=['
                                || l_new_repln_id
                                || ']'
                               );
             END IF;
         END LOOP;
      END IF;

      IF (l_count_sn = 0)
      THEN
         fnd_message.set_name ('CSD', 'CSD_NO_SERIAL_NUMBERS');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;




--Delete record from CSD_REPAIRS for the input p_repair_order_line_id.
      IF (l_event_level >= l_debug_level)
      THEN
         fnd_log.STRING (l_event_level,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO',
                            'l_count_sn_success['
                         || l_count_sn_success
                         || ']l_count_sn['
                         || l_count_sn
                         || ']'
                        );
      END IF;

      IF (l_count_sn_success = l_count_sn)
      THEN
         IF (l_event_level >= l_debug_level)
         THEN
            fnd_log.STRING (l_event_level,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO',
                            'deleting the draft repair order'
                           );
         END IF;

         csd_repairs_pvt.delete_repair_order
                            (p_api_version_number      => 1.0,
                             p_init_msg_list           => fnd_api.g_false,
                             p_commit                  => fnd_api.g_false,
                             p_validation_level        => fnd_api.g_valid_level_full,
                             p_repair_line_id          => p_repair_order_line_id,
                             x_return_status           => l_return_status,
                             x_msg_count               => l_msg_count,
                             x_msg_data                => l_msg_data
                            );
      ELSE
         -- Update the repair order quantity. This condition occurrs when
         -- only  some of the serial numbers are processed.
         IF (l_event_level >= l_debug_level)
         THEN
            fnd_log.STRING (l_event_level,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO',
                            'Updating the CSD_REPAIRS table quantity'
                           );
         END IF;

         UPDATE csd_repairs
            SET quantity = quantity - l_count_sn_success,
                last_update_date = SYSDATE,
                last_update_login = fnd_global.login_id,
                last_updated_by = fnd_global.user_id
          WHERE repair_line_id = p_repair_order_line_id;
      END IF;

      -- Api body ends here

      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and IF count is  get message info.
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF (fnd_log.level_procedure >= l_debug_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO.END',
                         'Leaving Mass_Create_RO'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         log_error_stack ();
         ROLLBACK TO sp_mass_create_ro;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_error >= l_debug_level)
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO',
                            'EXC_ERROR[' || x_msg_data || ']'
                           );
         END IF;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK TO sp_mass_create_ro;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_exception >= l_debug_level)
         THEN
            fnd_log.STRING (fnd_log.level_exception,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO',
                            'EXC_UNEXP_ERROR[' || x_msg_data || ']'
                           );
         END IF;
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK TO sp_mass_create_ro;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_unexpected >= l_debug_level)
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.MASS_CREATE_RO',
                            'SQL MEssage[' || SQLERRM || ']'
                           );
         END IF;
   END mass_create_ro;

   PROCEDURE process_ro (
      p_api_version         IN              NUMBER,
      p_commit              IN              VARCHAR2,
      p_init_msg_list       IN              VARCHAR2,
      p_validation_level    IN              NUMBER,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      p_repair_line_id      IN             NUMBER,
      p_prod_txn_tbl        IN OUT NOCOPY   csd_process_pvt.product_txn_tbl,
      p_add_to_order_flag   IN              VARCHAR2,
      p_mass_ro_sn_id       IN              NUMBER,
      p_serial_number       IN              VARCHAR2,
      p_instance_id         IN              NUMBER,
      x_new_repln_id        OUT NOCOPY      NUMBER
   )
   IS
      l_api_version_number   CONSTANT NUMBER                          := 1.0;
      l_api_name             CONSTANT VARCHAR2 (30)           := 'PROCESS_RO';
      l_return_status                 VARCHAR2 (1) ;
      l_msg_count                     NUMBER;
      l_msg_data                      VARCHAR2 (2000);
      l_repair_number                 VARCHAR2 (30);
      l_repair_type_ref               VARCHAR2 (30);
      l_product_txn_rec               csd_process_pvt.product_txn_rec;
      c_refurbishment_type_ref   CONSTANT VARCHAR2 (30) := 'RF';
      l_repair_order_rec    csd_repairs_pub.repln_rec_type;

      -- swai: 12.1.1 bug 7176940 service bulletin check
      l_ro_sc_ids_tbl CSD_RO_BULLETINS_PVT.CSD_RO_SC_IDS_TBL_TYPE;

      --Define cursors
      CURSOR cur_repair_type_ref (p_repair_type_id NUMBER)
      IS
         SELECT repair_type_ref
           FROM csd_repair_types_vl
          WHERE repair_type_id = p_repair_type_id;

      --Cursor to get the repair order record data .
      CURSOR cur_repair_order (p_repln_id NUMBER)
      IS
         SELECT incident_id, inventory_item_id,
                customer_product_id, unit_of_measure, repair_type_id,
                owning_organization_id, -- swai: bug 7565999
                resource_id, project_id, task_id, contract_line_id,
                auto_process_rma, repair_mode, item_revision,
                NULL instance_id, status_reason_code,
                approval_required_flag, approval_status, promise_date,
                1 quantity, currency_code, default_po_num, ro_txn_status,   --added DEFAULT_PO_NUM, bug#9206256
                original_source_reference, NULL serial_number, 'O' status,
			 -- Added below cols when dff support is added
			 0 wip_quantity, 0 quantity_rcvd, 0 quantity_shipped,
			 attribute_category, attribute1, attribute2,
			 attribute3, attribute4, attribute5,
			 attribute6, attribute7, attribute8,
			 attribute9, attribute10, attribute11,
			 attribute12, attribute13, attribute14, attribute15,
			 original_source_header_id, original_source_line_id,
			 price_list_header_id, inventory_org_id, --bug#6415265
			 attribute16,attribute17,attribute18, -- bug#7497907, 12.1 FP, subhat
			 attribute19,attribute20,attribute21,attribute22,attribute23,
			 attribute24,attribute25,attribute26,attribute27,attribute28,attribute29,
			 attribute30
           FROM csd_repairs
          WHERE repair_line_id = p_repln_id;

   BEGIN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.PROCESS_RO.BEGIN',
                         'Entering Process_RO'
                        );
      END IF;

      SAVEPOINT sp_process_ro;

      l_return_status   := fnd_api.g_ret_sts_success;

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

      -- Get the repair order line details and populate the repair orde record
      --
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.Process_RO',
                            '--------------Fetching repair order details for[='
                         || p_repair_line_id
                         || ']---------------'
                        );
      END IF;

      OPEN cur_repair_order(p_repair_line_id);
      FETCH cur_repair_order INTO
          l_repair_order_rec.incident_id,
          l_repair_order_rec.inventory_item_id,
          l_repair_order_rec.customer_product_id,
          l_repair_order_rec.unit_of_measure,
          l_repair_order_rec.repair_type_id,
          l_repair_order_rec.resource_group,  -- swai: bug 7565999
          l_repair_order_rec.resource_id,
          l_repair_order_rec.project_id,
          l_repair_order_rec.task_id,
          l_repair_order_rec.contract_line_id,
          l_repair_order_rec.auto_process_rma,
          l_repair_order_rec.repair_mode,
          l_repair_order_rec.item_revision,
          l_repair_order_rec.instance_id,
          l_repair_order_rec.status_reason_code,
          l_repair_order_rec.approval_required_flag,
          l_repair_order_rec.approval_status,
          l_repair_order_rec.promise_date,
          l_repair_order_rec.quantity,
          l_repair_order_rec.currency_code,
          l_repair_order_rec.default_po_num,   --bug#9206256
          l_repair_order_rec.ro_txn_status,
          l_repair_order_rec.original_source_reference,
          l_repair_order_rec.serial_number,
          l_repair_order_rec.status,
		--- Added below while adding DFF support
          l_repair_order_rec.quantity_in_wip,
          l_repair_order_rec.quantity_rcvd,
          l_repair_order_rec.quantity_shipped,
          l_repair_order_rec.attribute_category,
          l_repair_order_rec.attribute1,
          l_repair_order_rec.attribute2,
          l_repair_order_rec.attribute3,
          l_repair_order_rec.attribute4,
          l_repair_order_rec.attribute5,
          l_repair_order_rec.attribute6,
          l_repair_order_rec.attribute7,
          l_repair_order_rec.attribute8,
          l_repair_order_rec.attribute9,
          l_repair_order_rec.attribute10,
          l_repair_order_rec.attribute11,
          l_repair_order_rec.attribute12,
          l_repair_order_rec.attribute13,
          l_repair_order_rec.attribute14,
          l_repair_order_rec.attribute15,
          l_repair_order_rec.original_source_header_id,
          l_repair_order_rec.original_source_line_id,
          l_repair_order_rec.price_list_header_id,
		      l_repair_order_rec.inventory_org_id,   ---bug#6415265
		      l_repair_order_rec.attribute16, -- bug#7497907, DFF changes, subhat
          l_repair_order_rec.attribute17,
          l_repair_order_rec.attribute18,
          l_repair_order_rec.attribute19,
          l_repair_order_rec.attribute20,
          l_repair_order_rec.attribute21,
          l_repair_order_rec.attribute22,
          l_repair_order_rec.attribute23,
          l_repair_order_rec.attribute24,
          l_repair_order_rec.attribute25,
          l_repair_order_rec.attribute26,
          l_repair_order_rec.attribute27,
          l_repair_order_rec.attribute28,
          l_repair_order_rec.attribute29,
          l_repair_order_rec.attribute30;

      IF (cur_repair_order%NOTFOUND)
      THEN
         fnd_message.set_name ('CSD', 'CSD_API_INV_REP_LINE_ID');
         fnd_message.set_token ('REPAIR_LINE_ID',
                                p_repair_line_id
                               );
         fnd_msg_pub.ADD;
         CLOSE cur_repair_order;
         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE cur_repair_order;

      --Get the repair type ref and populate product txn table
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.Process_RO',
                            '------------------Fetching repair type ref for[='
                         || l_repair_order_rec.repair_type_id
                         || ']----------------'
                        );
      END IF;


     OPEN cur_repair_type_ref (l_repair_order_rec.repair_type_id);

      FETCH cur_repair_type_ref
       INTO l_repair_type_ref;

      IF (cur_repair_type_ref%NOTFOUND)
      THEN
         FND_MESSAGE.SET_NAME('CSD','CSD_API_REPAIR_TYPE_ID');
         FND_MESSAGE.SET_TOKEN('REPAIR_TYPE_ID',l_repair_order_rec.repair_type_id);
         FND_MSG_PUB.Add;
         CLOSE cur_repair_type_ref;
         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE cur_repair_type_ref;

      ---Copy the serial number and the instance id into repair order rec.

      l_repair_order_rec.instance_id := p_instance_id;
      l_repair_order_rec.customer_product_id := p_instance_id;
      l_repair_order_rec.serial_number := p_serial_number;
      l_repair_order_rec.repair_number := null;
      l_repair_order_rec.repair_group_id := null;


      /*
      IF(p_repair_order_rec.SERIAL_NUMBER = 'SN_ERR') THEN
          dbms_output.put_line('Error condition');
          FND_MESSAGE.SET_NAME('CSD','ERROR_MSG');
          FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      */
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.Process_RO',
                            '------------------Calling csd_repairs_pvt.create_repair_order'
                        );
      END IF;

      csd_repairs_pvt.create_repair_order
                                    (p_api_version_number      => 1.0,
                                     p_commit                  => fnd_api.g_false,
                                     p_init_msg_list           => fnd_api.g_false,
                                     p_validation_level        => p_validation_level,
                                     p_repair_line_id          => NULL,
                                     p_repln_rec               => l_repair_order_rec,
                                     x_repair_line_id          => x_new_repln_id,
                                     x_repair_number           => l_repair_number,
                                     x_return_status           => x_return_status,
                                     x_msg_count               => x_msg_count,
                                     x_msg_data                => x_msg_data
                                    );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --Update Repair order line id in the record p_repair_Order_rec and prod txn table
      l_repair_order_rec.repair_number := l_repair_number;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.Process_RO',
                         '------------------New repair order number=[' || l_repair_number || ']'
                        );
      END IF;


      --If Reapir_type_Ref is not 'RF'(Refurbishment).
      --Call create_product_txn API to create the charge line and product txns.
      --If the return_status <> 'S' then rollback to savepoint SP_Process_RO, else
      --proceed to next step.
      IF (l_repair_type_ref <> c_refurbishment_type_ref)
      THEN

      -- Fix for bug#4884582
      -- Commented the call to create_product_txn api.
      -- csd_process_pvt.create_default_txn api is used to create
      -- product transactions
      --
      /****
         IF (p_prod_txn_tbl.COUNT > 0)
         THEN
            -- THis api will update the product txn records with the serial number
            --  and the isntance id.
            upd_instance(p_repair_type_ref        => l_Repair_type_ref,
                                p_serial_number   => p_serial_number,
                                p_instance_id     => p_instance_id,
                                x_prod_txn_tbl    => p_prod_txn_tbl);

            FOR i IN p_prod_txn_tbl.FIRST .. p_prod_txn_tbl.LAST
            LOOP
               p_prod_txn_tbl (i).repair_line_id := x_new_repln_id;
               p_prod_txn_tbl (i).product_transaction_id := NULL;

               --l_product_Txn_Rec := p_prod_txn_tbl(i);
               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                  'CSD.PLSQL.CSD_MASS_RCV_PVT.Process_RO',
                                     'Calling Create_Product_Txn for['
                                  || p_prod_txn_tbl (i).source_serial_number
                                  || ']'
                                 );
               END IF;

               create_product_txn
                            (p_api_version            => 1.0,
                             p_commit                 => fnd_api.g_false,
                             p_init_msg_list          => fnd_api.g_false,
                             p_validation_level       => fnd_api.g_valid_level_full,
                             x_return_status          => l_return_status,
                             x_msg_count              => x_msg_count,
                             x_msg_data               => x_msg_data,
                             p_product_txn_rec        => p_prod_txn_tbl (i),
                             p_add_to_order_flag      => p_add_to_order_flag
                            );

               IF (l_return_status <> fnd_api.g_ret_sts_success)
               THEN
                  --Rollback to Save point Process_RO
                  RAISE fnd_api.g_exc_error;
               END IF;

               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                  'CSD.PLSQL.CSD_MASS_RCV_PVT.Process_RO',
                                     'After Create_product_txn['
                                  || l_repair_order_rec.serial_number
                                  || ']'
                                 );
               END IF;
            END LOOP;
         END IF;
         *****/

        -- Fix for bug#4884582
        -- Call Default Product Txn creation
        --
        csd_process_pvt.create_default_prod_txn
                             (  p_api_version      => 1.0,
                                p_commit           => Fnd_Api.g_false,
                                p_init_msg_list    => Fnd_Api.g_false,
                                p_validation_level => Fnd_Api.g_valid_level_full,
                                p_repair_line_id   => x_new_repln_id,
                                x_return_status    => l_return_status,
                                x_msg_count        => x_msg_count,
                                x_msg_data         => x_msg_data
		             );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
          fnd_log.STRING (fnd_log.level_statement,
                                 'CSD.PLSQL.CSD_MASS_RCV_PVT.Process_RO',
                                   'After Create_default_product_txn['
                                 || l_repair_order_rec.serial_number|| ']');
        END IF;

        IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
          --Rollback to Save point Process_RO
          RAISE fnd_api.g_exc_error;
        END IF;

        -- swai: 12.1.1 bug 7176940 - check service bulletins after RO creation
        IF (nvl(fnd_profile.value('CSD_AUTO_CHECK_BULLETINS'),'N') = 'Y') THEN
            CSD_RO_BULLETINS_PVT.LINK_BULLETINS_TO_RO(
               p_api_version_number         => 1.0,
               p_init_msg_list              => Fnd_Api.G_FALSE,
               p_commit                     => Fnd_Api.G_FALSE,
               p_validation_level           => Fnd_Api.G_VALID_LEVEL_FULL,
               p_repair_line_id             => x_new_repln_id,
               px_ro_sc_ids_tbl             => l_ro_sc_ids_tbl,
               x_return_status              => l_return_status,
               x_msg_count                  => l_msg_count,
               x_msg_data                   => l_msg_data
            );
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
              fnd_log.STRING (fnd_log.level_statement,
                                     'CSD.PLSQL.CSD_MASS_RCV_PVT.Process_RO',
                                       'After CSD_RO_BULLETINS_PVT.LINK_BULLETINS_TO_RO['
                                     || x_new_repln_id || ']');
            END IF;
            -- ignore return status for now.
        END IF;

      END IF;


      --Delete the processed serial number from CSD_MASS_RO_SN if exists.
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.Process_RO',
                            'Deleting CSD_MASS_RO_SN record sn=['
                         || NVL (l_repair_order_rec.serial_number, '')
                         || ']'
                        );
      END IF;

      IF (NVL (l_repair_order_rec.serial_number, '-') <> '-')
      THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.Process_RO',
                            'Deleting CSD_MASS_RO_SN record '
                           );
         END IF;

         csd_mass_ro_sn_pkg.delete_row (p_mass_ro_sn_id => p_mass_ro_sn_id);
      END IF;

      -- Api body ends here

      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and IF count is  get message info.
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.PROCESS_RO.END',
                         'Leaving Process_RO'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO sp_process_ro;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.PROCESS_RO',
                            'EXC_ERROR[' || x_msg_data || ']'
                           );
         END IF;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK TO sp_process_ro;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_exception,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.PROCESS_RO',
                            'EXC_UNEXP_ERROR[' || x_msg_data || ']'
                           );
         END IF;
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK TO sp_process_ro;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_exception,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.PROCESS_RO',
                            'SQL MEssage[' || SQLERRM || ']'
                           );
         END IF;
   END process_ro;

--This API is called from the Process_RO API. This
--will create the product transaction, charge line, submit charge line and book the chargeline.
--
--
   PROCEDURE create_product_txn (
      p_api_version         IN              NUMBER,
      p_commit              IN              VARCHAR2,
      p_init_msg_list       IN              VARCHAR2,
      p_validation_level    IN              NUMBER,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      p_product_txn_rec     IN OUT NOCOPY   csd_process_pvt.product_txn_rec,
      p_add_to_order_flag   IN              VARCHAR2
   )
   IS
      ----Define Cursors
      CURSOR cur_cust_details (p_incident_id IN NUMBER)
      IS
         SELECT customer_id, account_id
           FROM cs_incidents_all_b
          WHERE incident_id = p_incident_id;

	 /*** contract rearch changes for R12

      CURSOR cur_coverage_details (p_bus_process_id NUMBER)
      IS
         SELECT cov.actual_coverage_id,
	           -- cov.coverage_name, -- commented for bugfix 3617932
			 ent.txn_group_id
           FROM oks_ent_coverages_v cov, oks_ent_txn_groups_v ent
          WHERE cov.contract_line_id = p_product_txn_rec.contract_id
            AND cov.actual_coverage_id = ent.coverage_id
            AND ent.business_process_id = p_bus_process_id;
		  ****************/

      CURSOR cur_ro_details (p_repair_line_id NUMBER)
      IS
         SELECT incident_id, original_source_reference,
                original_source_header_id, original_source_line_id
           FROM csd_repairs
          WHERE repair_line_id = p_repair_line_id;

      CURSOR cur_pricelist_details (p_price_list_id NUMBER)
      IS
         SELECT currency_code
           FROM oe_price_lists
          WHERE price_list_id = p_price_list_id;

      CURSOR cur_order_category (p_header_id NUMBER)
      IS
         SELECT oot.order_category_code
           FROM oe_order_headers_all ooh, oe_order_types_v oot
          WHERE ooh.order_type_id = oot.order_type_id
            AND ooh.header_id = p_header_id;

      CURSOR cur_po_number_rma (
         p_orig_src_header_id   NUMBER,
         p_po_number            VARCHAR2
      )
      IS
         SELECT cust_po_number
           FROM oe_order_headers_all
          WHERE header_id = p_orig_src_header_id
            AND cust_po_number = p_po_number;

      CURSOR cur_po_number (
         p_repair_line_id    NUMBER,
         p_order_header_id   NUMBER,
         p_po_number         VARCHAR2
      )
      IS
         SELECT ced.purchase_order_num
           FROM csd_product_transactions cpt, cs_estimate_details ced
          WHERE cpt.estimate_detail_id = ced.estimate_detail_id
            AND cpt.repair_line_id = p_repair_line_id
            AND ced.order_header_id = p_order_header_id
            AND ced.purchase_order_num = p_po_number;

      CURSOR cur_order_header (p_incident_id NUMBER)
      IS
         SELECT MAX (ced.order_header_id)
           FROM csd_repairs cr,
                csd_product_transactions cpt,
                cs_estimate_details ced
          WHERE cr.incident_id = p_incident_id
            AND cpt.repair_line_id = cr.repair_line_id
            AND ced.estimate_detail_id = cpt.estimate_detail_id
            AND ced.order_header_id IS NOT NULL
            AND ced.interface_to_oe_flag = 'Y';

      CURSOR cur_sub_inv (p_sub_inventory VARCHAR2, p_ship_from_org_id NUMBER)
      IS
         SELECT 'x'
           FROM mtl_secondary_inventories
          WHERE secondary_inventory_name = p_sub_inventory
            AND organization_id = p_ship_from_org_id;

      CURSOR cur_pick_rule (p_picking_rule_id NUMBER)
      IS
         SELECT picking_rule_id
           FROM wsh_picking_rules
          WHERE picking_rule_id = p_picking_rule_id;

      CURSOR cur_release_status (p_order_line_id NUMBER)
      IS
         SELECT released_status
           FROM wsh_delivery_details
          WHERE source_line_id = p_order_line_id;

      CURSOR cur_txn_type_id (p_txn_billing_type_id NUMBER)
      IS
         SELECT transaction_type_id
           FROM cs_txn_billing_types
          WHERE txn_billing_type_id = p_txn_billing_type_id;

---------------------------------------------------------------------------0
      l_api_version_number   CONSTANT NUMBER                            := 1.0;
      l_api_name             CONSTANT VARCHAR2 (30)            := 'PROCESS_RO';
      l_return_status                 VARCHAR2 (1) ;
      l_order_rec                     csd_process_pvt.om_interface_rec;
      l_sn_processed_count            NUMBER;
      l_index                         NUMBER;
      l_incident_id                   NUMBER;
      l_orig_src_reference            VARCHAR2 (30);
      l_orig_src_header_id            NUMBER;
      l_orig_src_line_id              NUMBER;
      l_bus_process_id                NUMBER;
      l_coverage_id                   NUMBER;
      -- l_coverage_name                 VARCHAR2 (150); -- commented for bugfix 3617932
      l_txn_group_id                  NUMBER    ;
      l_party_id                      NUMBER   ;
      l_account_id                    NUMBER   ;
      l_order_header_id               NUMBER   ;
      l_curr_code                     VARCHAR2 (10) ;
      l_line_category_code            VARCHAR2 (30) ;
      l_line_type_id                  NUMBER        ;
      l_serial_flag                   BOOLEAN;
      l_charges_rec                   cs_charge_details_pub.charges_rec_type;
      l_ro_txn_status                 VARCHAR2 (50);
      l_prod_txn_status               VARCHAR2 (50);
      l_add_to_same_order             VARCHAR2 (1);
      l_order_category_code           VARCHAR2 (30);
      l_orig_po_num                   VARCHAR2 (50);
      l_estimate_detail_id            NUMBER;
      l_booked_flag                   VARCHAR2 (1);
      l_transaction_type_id           NUMBER;
   BEGIN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                      (fnd_log.level_procedure,
                       'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN.BEGIN',
                       'Entered CREATE_PRODUCT_TXN'
                      );
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                            'Processing Serial Number:=['
                         || p_product_txn_rec.source_serial_number
                         || ']'
                        );
      END IF;

      SAVEPOINT sp_create_product_txn;

      l_return_status      := fnd_api.g_ret_sts_success;

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

--Validate input
--Check mandatory parameters Repair_line_id, Action_Code, Action_type, Txn_Billing_Type_Id, Inventory_Item_Id, UOM, Quantity
--and Price_list_Id.
--Validate the parameters, Repair_line_id, action_type, action_code and Prod_Txn_Status

      ---------------------------------------------------------------------------------1
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                         'Before calling validate_product_txn_Rec'
                        );
      END IF;

      validate_product_txn_rec (p_product_txn_rec);

---------------------------------------------------------------------------------2

      --Check if the input business_process_id is valid and if it is invalid get the business_process_id from the repair_type.
--Set error if the business process is invalid.

      -- Get service request from csd_repairs table
      -- using repair order
      OPEN cur_ro_details (p_product_txn_rec.repair_line_id);

      FETCH cur_ro_details
       INTO l_incident_id, l_orig_src_reference, l_orig_src_header_id,
            l_orig_src_line_id;

      IF (cur_ro_details%NOTFOUND)
      THEN
         fnd_message.set_name ('CSD', 'CSD_API_INV_REP_LINE_ID');
         fnd_message.set_token ('REPAIR_LINE_ID',
                                p_product_txn_rec.repair_line_id
                               );
         fnd_msg_pub.ADD;

         CLOSE cur_ro_details;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE cur_ro_details;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                         'l_incident_id    =' || l_incident_id
                        );
      END IF;

---------------------------------------------------------------------------------3
      -- Get the business process id
      l_bus_process_id :=
           csd_process_util.get_bus_process (p_product_txn_rec.repair_line_id);

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                         'l_bus_process_id =' || l_bus_process_id
                        );
      END IF;

      IF l_bus_process_id < 0
      THEN
         IF NVL (p_product_txn_rec.business_process_id, fnd_api.g_miss_num) <>
                                                           fnd_api.g_miss_num
         THEN
            l_bus_process_id := p_product_txn_rec.business_process_id;
         ELSE
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                            (fnd_log.level_statement,
                             'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                             'Business process Id does not exist '
                            );
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

---------------------------------------------------------------------------------
--Get the transaction type id
      IF    (p_product_txn_rec.transaction_type_id IS NULL)
         OR (p_product_txn_rec.transaction_type_id = fnd_api.g_miss_num)
      THEN
         OPEN cur_txn_type_id (p_product_txn_rec.txn_billing_type_id);

         FETCH cur_txn_type_id
          INTO l_transaction_type_id;

         IF (cur_txn_type_id%NOTFOUND)
         THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                            (fnd_log.level_statement,
                             'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                                'No Row found for the txn_billing_type_id='
                             || TO_CHAR (p_product_txn_rec.txn_billing_type_id)
                            );
            END IF;

            CLOSE cur_txn_type_id;

            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE cur_txn_type_id;

         p_product_txn_rec.transaction_type_id := l_transaction_type_id;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                               'p_product_txn_rec.transaction_type_id :'
                            || TO_CHAR (p_product_txn_rec.transaction_type_id)
                           );
         END IF;
      END IF;

---------------------------------------------------------------------------------4
--If the contract id is not null, derive the coverage details from oks_ent_coverages_v, oks_ent_txn_groups_v for the
--given contract id and business process id.
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                         'contract_line_id =' || p_product_txn_rec.contract_id
                        );
      END IF;

      -- Get the coverage details from the contract
	 /*** Contract re arch changes for R12
      IF NVL (p_product_txn_rec.contract_id, fnd_api.g_miss_num) <>
                                                            fnd_api.g_miss_num
      THEN
         OPEN cur_coverage_details (l_bus_process_id);

         FETCH cur_coverage_details
          INTO l_coverage_id,
		     -- l_coverage_name, -- commented for bugfix 3617932
			l_txn_group_id;

         IF (cur_coverage_details%NOTFOUND)
         THEN
            fnd_message.set_name ('CSD', 'CSD_API_CONTRACT_MISSING');
            fnd_message.set_token ('CONTRACT_LINE_ID',
                                   p_product_txn_rec.contract_id
                                  );
            fnd_msg_pub.ADD;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                            (fnd_log.level_statement,
                             'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                             'Contract Line Id missing'
                            );
            END IF;

            CLOSE cur_coverage_details;

            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE cur_coverage_details;

         p_product_txn_rec.coverage_id := l_coverage_id;
         p_product_txn_rec.coverage_txn_group_id := l_txn_group_id;

      END IF;
	    ****************/

---------------------------------------------------------------------------------5
--Get Party_ID and Account_ID from cs_incidents_all_b table for the given incident_Id. If the party_id is null raise error.
      IF l_incident_id IS NOT NULL
      THEN
         OPEN cur_cust_details (l_incident_id);

         FETCH cur_cust_details
          INTO l_party_id, l_account_id;

         IF (cur_cust_details%NOTFOUND OR l_party_id IS NULL)
         THEN
            fnd_message.set_name ('CSD', 'CSD_API_PARTY_MISSING');
            fnd_message.set_token ('INCIDENT_ID', l_incident_id);
            fnd_msg_pub.ADD;

            CLOSE cur_cust_details;

            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE cur_cust_details;
      END IF;

---------------------------------------------------------------------------------6

      --Derive the line_type and line_category from the txn_billing_Type_id and organization_id.
--If line_type or line_Category is null raise error.
      csd_process_util.get_line_type
              (p_txn_billing_type_id      => p_product_txn_rec.txn_billing_type_id,
               p_org_id                   => p_product_txn_rec.organization_id,
               x_line_type_id             => l_line_type_id,
               x_line_category_code       => l_line_category_code,
               x_return_status            => x_return_status
              );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                         'l_line_type_id                  =' || l_line_type_id
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                            'l_line_category_code            ='
                         || l_line_category_code
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                            'p_product_txn_rec.price_list_id ='
                         || p_product_txn_rec.price_list_id
                        );
      END IF;

      -- If line_type_id Or line_category_code is null
      -- then raise error
      IF (l_line_type_id IS NULL OR l_line_category_code IS NULL)
      THEN
         fnd_message.set_name ('CSD', 'CSD_API_LINE_TYPE_MISSING');
         fnd_message.set_token ('TXN_BILLING_TYPE_ID',
                                p_product_txn_rec.txn_billing_type_id
                               );
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

---------------------------------------------------------------------------------7

      --If the item is serialzed check if the serial number is provided.
      l_serial_flag :=
                  is_item_pre_serialized (p_product_txn_rec.inventory_item_id);

      -- Serial Number required if the item is serialized
      IF l_serial_flag AND p_product_txn_rec.source_serial_number IS NULL
      THEN
         IF (   p_product_txn_rec.action_type IN ('RMA', 'WALK_IN_RECEIPT')
             OR (    p_product_txn_rec.ship_sales_order_flag = 'Y'
                 AND p_product_txn_rec.process_txn_flag = 'Y'
                )
            )
         THEN
            fnd_message.set_name ('CSD', 'CSD_API_SERIAL_NUM_MISSING');
            fnd_message.set_token ('INVENTORY_ITEM_ID',
                                   p_product_txn_rec.inventory_item_id
                                  );
            fnd_msg_pub.ADD;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                           (fnd_log.level_statement,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                               'Serial Number missing for inventory_item_id='
                            || p_product_txn_rec.inventory_item_id
                           );
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

---------------------------------------------------------------------------------8
--Derive currency_Code from the oe_price_lists_all for the given price_list_id
      -- Get the currency code from the price list if it is null or g_miss
      IF NVL (p_product_txn_rec.price_list_id, fnd_api.g_miss_num) <>
                                                            fnd_api.g_miss_num
      THEN
         OPEN cur_pricelist_details (p_product_txn_rec.price_list_id);

         FETCH cur_pricelist_details
          INTO l_curr_code;

         IF (cur_pricelist_details%NOTFOUND)
         THEN
            fnd_message.set_name ('CSD', 'CSD_API_INV_PRICE_LIST_ID');
            fnd_message.set_token ('PRICE_LIST_ID',
                                   p_product_txn_rec.price_list_id
                                  );
            fnd_msg_pub.ADD;

            CLOSE cur_pricelist_details;

            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE cur_pricelist_details;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                            'l_curr_code          =' || l_curr_code
                           );
         END IF;
      END IF;

---------------------------------------------------------------------------------9

      l_add_to_same_order := p_add_to_order_flag;
      l_order_header_id := null;

      -- If the source is RMA then process differently
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                         'orignal source ref=[' || l_orig_src_reference || ']'
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                         'l_add_to_same_order=[' || l_add_to_same_order || ']'
                        );
      END IF;

      IF l_orig_src_reference = 'RMA'
      THEN                                                   -------------IF A
         l_order_header_id := l_orig_src_header_id;
      ELSE
         OPEN cur_order_header (l_incident_id);

         FETCH cur_order_header
          INTO l_order_header_id;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            IF (cur_order_header%NOTFOUND)
            THEN
               fnd_log.STRING
                            (fnd_log.level_statement,
                             'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                             'Getting max order header id failed '
                            );
            ELSE
               fnd_log.STRING
                            (fnd_log.level_statement,
                             'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                             'Order header id[' || l_order_header_id || ']'
                            );
            END IF;
         END IF;

         CLOSE cur_order_header;
      END IF;                                               --------------IF A

--Fixed for bug#4631642
/*      IF p_product_txn_rec.new_order_flag <> 'Y'
      THEN  */                                                    ----------IF B
         IF (    p_product_txn_rec.process_txn_flag = 'Y'
             AND p_product_txn_rec.interface_to_om_flag = 'Y'
            )
         THEN                                                    ---------IF C

            IF (l_add_to_same_order = 'Y' and l_order_header_id is not null)
            THEN
               p_product_txn_rec.add_to_order_flag := 'Y';
               p_product_txn_rec.order_header_id := l_order_header_id;
            ELSE
               p_product_txn_rec.add_to_order_flag := 'F';
               p_product_txn_rec.order_header_id := fnd_api.g_miss_num;
            END IF;
         END IF;                                          ----------------IF C
/*      END IF;    */                                               ----------IF B

      -- assigning values for the charge record
      p_product_txn_rec.incident_id := l_incident_id;
      p_product_txn_rec.business_process_id := l_bus_process_id;
      p_product_txn_rec.line_type_id := l_line_type_id;
      p_product_txn_rec.currency_code := l_curr_code;
      p_product_txn_rec.line_category_code := l_line_category_code;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                         'Convert product txn rec to charges rec'
                        );
      END IF;

---------------------------------------------------------------------------------10

      --Create Charge line
--Call CSD_PROCESS_UTIL.CONVERT_TO_CHG_REC to populate charges record.
      -- Convert the product txn record to
      -- charge record
      csd_process_util.convert_to_chg_rec
                                         (p_prod_txn_rec       => p_product_txn_rec,
                                          x_charges_rec        => l_charges_rec,
                                          x_return_status      => x_return_status
                                         );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                            'sql error[' || SQLERRM || ']'
                           );
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      ----------Temp code
      l_charges_rec.charge_line_type := 'ACTUAL';

---------------------------------------------------------------------------------11
--Call CSD_PROCESS_PVT.PROCESS_CHARGE_LINES with 'CREATE' as input parameter to create charge line.
--Update estimate_Detail_id in the Product_Txn_rec.
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                      (fnd_log.level_statement,
                       'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                       'Calling process_charge_lines to create charge lines '
                      );
      END IF;

      csd_process_pvt.process_charge_lines
                            (p_api_version             => 1.0,
                             p_commit                  => fnd_api.g_false,
                             p_init_msg_list           => fnd_api.g_false,
                             p_validation_level        => fnd_api.g_valid_level_full,
                             p_action                  => 'CREATE',
                             p_charges_rec             => l_charges_rec,
                             x_estimate_detail_id      => l_estimate_detail_id,
                             x_return_status           => x_return_status,
                             x_msg_count               => x_msg_count,
                             x_msg_data                => x_msg_data
                            );

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                            'Error[' || SUBSTR (x_msg_data, 1, 200) || ']'
                           );
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                         'Created charge line[' || l_estimate_detail_id || ']'
                        );
      END IF;

---------------------------------------------------------------------------------12
--Call CSD_PRODUCT_TRANSACTIONS_PKG.INSERT_ROW to add a product transaction record.
--Update product_transaction_id in the Product_Txn_Rec.
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                         'Creating product txn rec ..'
                        );
      END IF;

      csd_product_transactions_pkg.insert_row
         (px_product_transaction_id       => p_product_txn_rec.product_transaction_id,
          p_repair_line_id                => p_product_txn_rec.repair_line_id,
          p_estimate_detail_id            => l_estimate_detail_id,
          p_action_type                   => p_product_txn_rec.action_type,
          p_action_code                   => p_product_txn_rec.action_code,
          p_lot_number                    => p_product_txn_rec.lot_number,
          -- Following parameter is not used from 11.5.10 release
            -- p_SHIPPED_SERIAL_NUMBER     => p_product_txn_rec.SHIPPED_SERIAL_NUMBER,
          p_sub_inventory                 => p_product_txn_rec.sub_inventory,
          p_interface_to_om_flag          => p_product_txn_rec.interface_to_om_flag,
          p_book_sales_order_flag         => p_product_txn_rec.book_sales_order_flag,
          p_release_sales_order_flag      => p_product_txn_rec.release_sales_order_flag,
          p_ship_sales_order_flag         => p_product_txn_rec.ship_sales_order_flag,
          p_prod_txn_status               => p_product_txn_rec.prod_txn_status,
          p_prod_txn_code                 => p_product_txn_rec.prod_txn_code,
          p_last_update_date              => SYSDATE,
          p_creation_date                 => SYSDATE,
          p_last_updated_by               => fnd_global.user_id,
          p_created_by                    => fnd_global.user_id,
          p_last_update_login             => fnd_global.user_id,
          p_attribute1                    => p_product_txn_rec.attribute1,
          p_attribute2                    => p_product_txn_rec.attribute2,
          p_attribute3                    => p_product_txn_rec.attribute3,
          p_attribute4                    => p_product_txn_rec.attribute4,
          p_attribute5                    => p_product_txn_rec.attribute5,
          p_attribute6                    => p_product_txn_rec.attribute6,
          p_attribute7                    => p_product_txn_rec.attribute7,
          p_attribute8                    => p_product_txn_rec.attribute8,
          p_attribute9                    => p_product_txn_rec.attribute9,
          p_attribute10                   => p_product_txn_rec.attribute10,
          p_attribute11                   => p_product_txn_rec.attribute11,
          p_attribute12                   => p_product_txn_rec.attribute12,
          p_attribute13                   => p_product_txn_rec.attribute13,
          p_attribute14                   => p_product_txn_rec.attribute14,
          p_attribute15                   => p_product_txn_rec.attribute15,
          p_context                       => p_product_txn_rec.CONTEXT,
          p_object_version_number         => 1,
          p_req_header_id                 => p_product_txn_rec.req_header_id,
          p_req_line_id                   => p_product_txn_rec.req_line_id,
          p_order_header_id               => p_product_txn_rec.order_header_id,
          p_order_line_id                 => p_product_txn_rec.order_line_id,
          p_prd_txn_qty_received          => p_product_txn_rec.prd_txn_qty_received,
          p_prd_txn_qty_shipped           => p_product_txn_rec.prd_txn_qty_shipped,
          p_source_serial_number          => p_product_txn_rec.source_serial_number,
          p_source_instance_id            => p_product_txn_rec.source_instance_id,
          p_non_source_serial_number      => p_product_txn_rec.non_source_serial_number,
          p_non_source_instance_id        => p_product_txn_rec.non_source_instance_id,
          p_locator_id                    => p_product_txn_rec.locator_id,
          p_sub_inventory_rcvd            => p_product_txn_rec.sub_inventory_rcvd,
          p_lot_number_rcvd               => p_product_txn_rec.lot_number_rcvd,
          p_picking_rule_id               => p_product_txn_rec.picking_rule_id,
          p_project_id                    => p_product_txn_rec.project_id,
          p_task_id                       => p_product_txn_rec.task_id,
          p_unit_number                   => p_product_txn_rec.unit_number);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                            'PRODUCT_TRANSACTION_ID='
                         || p_product_txn_rec.product_transaction_id
                        );
      END IF;

---------------------------------------------------------------------------------13
--If Auto_RMA_Flag is 'Y' then create and book order.

      --Call CS_EST_APPLY_CONTRACT_PKG.APPLY_CONTRACT with incident_id as parameter.
--Call CS_Charge_Create_Order_PUB.Submit_Order with Incident_Id, party_id and
--account_id. For 11.5.8 use Process_Sales_orderSet book_order_flag = 'Y' if the
--Book_order_flag in Product_Txn_Rec is 'Y' otherwise 'N'.
--If the return_status <> 'S' then rollback to savepoint Create_product_txn and
--raise exception, else proceed to next step.
------------------------------------------------------------------------------------
      IF (p_product_txn_rec.interface_to_om_flag = 'Y')
      THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                    (fnd_log.level_statement,
                     'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                     'Call CSD_PROCESS_PVT.APPLY_CONTRACT to apply contract '
                    );
         END IF;

         csd_process_pvt.apply_contract
                            (p_api_version           => 1.0,
                             p_commit                => fnd_api.g_false,
                             p_init_msg_list         => fnd_api.g_false,
                             p_validation_level      => fnd_api.g_valid_level_full,
                             p_incident_id           => l_incident_id,
                             x_return_status         => x_return_status,
                             x_msg_count             => x_msg_count,
                             x_msg_data              => x_msg_data
                            );

         IF NOT (x_return_status = fnd_api.g_ret_sts_success)
         THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                            (fnd_log.level_statement,
                             'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                                'apply_contract failed['
                             || SUBSTR (x_msg_data, 1, 200)
                             || ']'
                            );
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

       -- THis api will interface and book the charge line
------------------------------------------------------------------------------------
--Update the status in CSD_PRODUCT_TXNS table and CSD_REPAIRS table. If the
--interface_to_oe_flag is 'Y' and book_order_flag is 'Y' then --set the
--prod_txn_status to 'BOOKED' and ro_txn_status to 'OM_BOOKED'. If
--interface_to_oe_flag is 'Y' and book_order_flag is 'N' set
--the prod_txn_status to 'SUBMITTED' and ro_txn_status to 'OM_SUBMITTED'. If
--interface_to_oe_flag is 'N', set the prod_txn_status
--to 'ENTERED' and ro_txn_status to 'CHARGE_ENTERED'.
----------------------------------------------------------------------------
         IF p_product_txn_rec.book_sales_order_flag = 'Y'
         THEN
            l_ro_txn_status := 'OM_BOOKED';
            l_prod_txn_status := 'BOOKED';
            l_booked_flag := 'Y';
         ELSE
            l_ro_txn_status := 'OM_SUBMITTED';
            l_prod_txn_status := 'SUBMITTED';
            l_booked_flag := 'N';
         END IF;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                            'calling CSD_PROCESS_PVT.PROCESS_SALES_ORDER to interface '
                            || 'Charge line without booking'
                           );
         END IF;

---Bug fix 3308435 [
          -- Assigning values for the order record
          l_order_rec.incident_id := l_incident_id;
          l_order_rec.party_id    := l_party_id   ;
          l_order_rec.account_id  := l_account_id ;
          l_order_rec.org_id      := p_product_txn_rec.organization_id ;

          CSD_PROCESS_PVT.PROCESS_SALES_ORDER
          ( p_api_version           =>  1.0 ,
            p_commit                =>  fnd_api.g_false,
            p_init_msg_list         =>  fnd_api.g_false,
            p_validation_level      =>  fnd_api.g_valid_level_full,
            p_action                =>  'CREATE',
            p_order_rec             =>  l_order_rec,
            x_return_status         =>  x_return_status,
            x_msg_count             =>  x_msg_count,
            x_msg_data              =>  x_msg_data  );

          IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
              THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                  'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                                  'process_sales_order failed['||x_msg_data||']');
              END IF;
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          Validate_order(p_est_detail_id => l_estimate_detail_id,
                         p_order_rec     => l_order_rec,
                         x_booked_flag   => l_booked_flag
                         );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
          THEN
              fnd_log.STRING (fnd_log.level_statement,
                              'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                              'Booking charge line with CSD_PROCESS_PVT.PROCESS_SALES_ORDER API');
          END IF;


          IF(l_booked_flag <> 'Y') THEN
              CSD_PROCESS_PVT.PROCESS_SALES_ORDER
              ( p_api_version           =>  1.0 ,
                p_commit                =>  fnd_api.g_false,
                p_init_msg_list         =>  fnd_api.g_false,
                p_validation_level      =>  fnd_api.g_valid_level_full,
                p_action                =>  'BOOK',
                p_order_rec             =>  l_order_rec,
                x_return_status         =>  x_return_status,
                x_msg_count             =>  x_msg_count,
                x_msg_data              =>  x_msg_data  );

              IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
                  THEN
                      fnd_log.STRING (fnd_log.level_statement,
                                      'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                                      'process_sales_order failed ['||x_msg_Data||']');
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
              END IF;
          END IF;
	    /****************
         cs_charge_create_order_pub.submit_order
                                    (p_api_version           => 1.0,
                                     p_init_msg_list         => p_init_msg_list,
                                     p_commit                => p_commit,
                                     p_validation_level      => p_validation_level,
                                     p_incident_id           => l_incident_id,
                                     p_party_id              => l_party_id,
                                     p_account_id            => l_account_id,
                                     p_book_order_flag       => l_booked_flag,
                                     x_return_status         => x_return_status,
                                     x_msg_count             => x_msg_count,
                                     x_msg_data              => x_msg_data
                                    );
		 *************/

--] 3308535
         IF NOT (x_return_status = fnd_api.g_ret_sts_success)
         THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                            (fnd_log.level_statement,
                             'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                                'submit_Order failed ['
                             || SUBSTR (x_msg_data, 1, 200)
                             || ']'
                            );
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE
         l_ro_txn_status := 'CHARGE_ENTERED';
         l_prod_txn_status := 'ENTERED';
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                         'Updating repair status[' || l_ro_txn_status || ']'
                        );
      END IF;

      UPDATE csd_repairs
         SET ro_txn_status = l_ro_txn_status
       WHERE repair_line_id = p_product_txn_rec.repair_line_id;

      IF SQL%NOTFOUND
      THEN
         fnd_message.set_name ('CSD', 'CSD_ERR_REPAIRS_UPDATE');
         fnd_message.set_token ('REPAIR_LINE_ID',
                                p_product_txn_rec.repair_line_id
                               );
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                         'Updating prod txn status[' || l_prod_txn_status
                         || ']'
                        );
      END IF;

      UPDATE csd_product_transactions
         SET prod_txn_status = l_prod_txn_status
       WHERE product_transaction_id = p_product_txn_rec.product_transaction_id;

      IF SQL%NOTFOUND
      THEN
         fnd_message.set_name ('CSD', 'CSD_ERR_PRD_TXN_UPDATE');
         fnd_message.set_token ('PRODUCT_TRANSACTION_ID',
                                p_product_txn_rec.product_transaction_id
                               );
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

----------------------------------------------------------------------------

      -- Api body ends here

      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and IF count is  get message info.
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN.END',
                         'Leaving CREATE_PRODUCT_TXN'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         log_error_stack ();
         ROLLBACK TO sp_create_product_txn;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                            'EXC_ERROR[' || x_msg_data || ']'
                           );
         END IF;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK TO sp_create_product_txn;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_exception,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                            'EXC_UNEXPECTED_ERROR[' || x_msg_data || ']'
                           );
         END IF;
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK TO sp_create_product_txn;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_PRODUCT_TXN',
                            'SQL Error[' || SQLERRM || ']'
                           );
         END IF;
   END create_product_txn;

-- This api would be called from the serial number capture screen.
-- If user enters serialized and ib trackable item,
-- and the serial number does not exist in IB, then message pops .
-- If users clicks OK button then this API would be called to create a new instance.
   PROCEDURE create_item_instance (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2,
      p_commit             IN              VARCHAR2,
      p_validation_level   IN              NUMBER,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      px_instance_rec      IN OUT NOCOPY   instance_rec_type,
      x_instance_id        OUT NOCOPY      NUMBER
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)        := 'Create_Item_Instance';
      l_api_version   CONSTANT NUMBER                                  := 1.0;
      l_return_status          VARCHAR2 (1);
      l_msg_data               VARCHAR2 (2000);
      l_msg_count              NUMBER;
--l_item_rec      Item_Rec_Type;
--l_defaulted_item_rec  Item_Rec_Type;
      l_instance_rec           csi_datastructures_pub.instance_rec;
                                          --csd_process_util.ui_instance_rec;
      l_parties_tbl            csi_datastructures_pub.party_tbl;
---csd_process_util.ui_party_tbl;
      l_pty_accts_tbl          csi_datastructures_pub.party_account_tbl;
      -- := csd_process_util.ui_party_account_tbl;
      l_org_units_tbl          csi_datastructures_pub.organization_units_tbl;
      --:= csd_process_util.ui_organization_units_tbl;
      l_ea_values_tbl          csi_datastructures_pub.extend_attrib_values_tbl;
      --:= csd_process_util.ui_extend_attrib_values_tbl;
      l_pricing_tbl            csi_datastructures_pub.pricing_attribs_tbl;
      -- := csd_process_util.ui_pricing_attribs_tbl;
      l_assets_tbl             csi_datastructures_pub.instance_asset_tbl;
      --:= csd_process_util.ui_instance_asset_tbl;
      l_txn_rec                csi_datastructures_pub.transaction_rec;
      -- := csd_process_util.ui_transaction_rec;
      l_party_site_id          NUMBER;
   BEGIN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                    (fnd_log.level_procedure,
                     'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_ITEM_INSTANCE.BEGIN',
                     'Entered CREATE_ITEM_INSTANCE'
                    );
      END IF;

      -- Standard Start of API savepoint
      SAVEPOINT create_item_instance;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
--                               l_api_name           ,
                                          g_pkg_name,
                                          g_file_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_ITEM_INSTANCE',
                            'Finding party_site_Id for party_site_use_Id=['
                         || px_instance_rec.party_site_use_id
                         || ']'
                        );
      END IF;

      BEGIN
         SELECT party_site_id
           INTO l_party_site_id
           FROM hz_party_site_uses
          WHERE party_site_use_id = px_instance_rec.party_site_use_id;
      --px_instance_rec.bill_to_site_use_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            fnd_message.set_name ('CSD', 'CSD_INVALID_SITE_USED_ID');
            fnd_message.set_token ('BILL_TO_SITE_USE_ID',
                                   px_instance_rec.party_site_use_id
                                  );
            --px_instance_rec.bill_to_site_use_id);
            RAISE fnd_api.g_exc_error;
      END;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_ITEM_INSTANCE',
                         'party_site_Id=[' || l_party_site_id || ']'
                        );
      END IF;

      l_instance_rec.inventory_item_id := px_instance_rec.inventory_item_id;
      l_instance_rec.inventory_revision := px_instance_rec.item_revision;
      l_instance_rec.serial_number := px_instance_rec.serial_number;
      --IF nvl(l_instance_rec.serial_number, 'AAA') <> 'AAA' THEN
      --  l_instance_rec.mfg_serial_number_flag := 'Y';
      --ELSE
      l_instance_rec.mfg_serial_number_flag := 'N';
      --END IF;

      --l_instance_rec.mfg_serial_number_flag :=
                                         --px_instance_rec.mfg_serial_number_flag;
      l_instance_rec.lot_number := px_instance_rec.lot_number;
      l_instance_rec.quantity := px_instance_rec.quantity;
      l_instance_rec.active_start_date := SYSDATE;
      l_instance_rec.active_end_date := NULL;
      l_instance_rec.unit_of_measure := px_instance_rec.uom;
      l_instance_rec.location_type_code := 'HZ_PARTY_SITES';
      l_instance_rec.location_id := l_party_site_id;
      l_instance_rec.instance_usage_code := 'OUT_OF_ENTERPRISE';
      --l_instance_rec.inv_master_organization_id :=
                         --cs_std.get_item_valdn_orgzn_id;
      l_instance_rec.vld_organization_id    := cs_std.get_item_valdn_orgzn_id;
      l_instance_rec.customer_view_flag := 'N';
      l_instance_rec.merchant_view_flag := 'Y';
      l_instance_rec.object_version_number := 1;
      l_instance_rec.external_reference := px_instance_rec.external_reference;
      l_parties_tbl (1).party_source_table := 'HZ_PARTIES';
      l_parties_tbl (1).party_id := px_instance_rec.party_id;
      l_parties_tbl (1).relationship_type_code := 'OWNER';
      l_parties_tbl (1).contact_flag := 'N';
      l_pty_accts_tbl (1).parent_tbl_index := 1;
      l_pty_accts_tbl (1).party_account_id := px_instance_rec.account_id;
      l_pty_accts_tbl (1).relationship_type_code := 'OWNER';
      l_pty_accts_tbl (1).active_start_date := SYSDATE;
      l_txn_rec.transaction_id := NULL;
      l_txn_rec.transaction_date := SYSDATE;
      l_txn_rec.source_transaction_date := SYSDATE;
      l_txn_rec.transaction_type_id := 1;
      l_txn_rec.txn_sub_type_id := NULL;
      l_txn_rec.source_group_ref_id := NULL;
      l_txn_rec.source_group_ref := '';
      l_txn_rec.source_header_ref_id := NULL;
      l_txn_rec.source_header_ref := '';
      l_txn_rec.source_line_ref_id := NULL;
      l_txn_rec.source_line_ref := '';
      l_txn_rec.source_dist_ref_id1 := NULL;
      l_txn_rec.source_dist_ref_id2 := NULL;
      l_txn_rec.inv_material_transaction_id := NULL;
      l_txn_rec.transaction_quantity := NULL;
      l_txn_rec.transaction_uom_code := '';
      l_txn_rec.transacted_by := NULL;
      l_txn_rec.transaction_status_code := '';
      l_txn_rec.transaction_action_code := '';
      l_txn_rec.message_id := NULL;
      l_txn_rec.object_version_number := NULL;
      l_txn_rec.split_reason_code := '';

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_ITEM_INSTANCE',
                         'Calling csi_item_instance_pub.create_item_instance'
                        );
      END IF;

      csi_item_instance_pub.create_item_instance
                   (p_api_version                => 1.0,
                    p_commit                     => csd_process_util.g_false,
                    p_init_msg_list              => csd_process_util.g_false,
                    p_validation_level           => csd_process_util.g_valid_level_full,
                    p_instance_rec               => l_instance_rec,
                    p_party_tbl                  => l_parties_tbl,
                    p_account_tbl                => l_pty_accts_tbl,
                    p_org_assignments_tbl        => l_org_units_tbl,
                    p_ext_attrib_values_tbl      => l_ea_values_tbl,
                    p_pricing_attrib_tbl         => l_pricing_tbl,
                    p_asset_assignment_tbl       => l_assets_tbl,
                    p_txn_rec                    => l_txn_rec,
                    x_return_status              => l_return_status,
                    x_msg_count                  => l_msg_count,
                    x_msg_data                   => l_msg_data
                   );

	 log_error_stack();
      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      x_instance_id := l_instance_rec.instance_id;
      px_instance_rec.instance_id := l_instance_rec.instance_id;
      px_instance_rec.instance_number := l_instance_rec.instance_number;

      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                      (fnd_log.level_procedure,
                       'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_ITEM_INSTANCE.END',
                       'Leaving CREATE_ITEM_INSTANCE'
                      );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO create_item_instance;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                          (fnd_log.level_error,
                           'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_ITEM_INSTANCE',
                           'EXC_ERROR[' || x_msg_data || ']'
                          );
         END IF;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_item_instance;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                          (fnd_log.level_exception,
                           'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_ITEM_INSTANCE',
                           'EXC_UNEXPECTED_ERROR[' || x_msg_data || ']'
                          );
         END IF;
      WHEN OTHERS
      THEN
         ROLLBACK TO create_item_instance;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_file_name, g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                          (fnd_log.level_unexpected,
                           'CSD.PLSQL.CSD_MASS_RCV_PVT.CREATE_ITEM_INSTANCE',
                           'SQL MEssage[' || SQLERRM || ']'
                          );
         END IF;
   END create_item_instance;


------------------------------------------------------------------------
   PROCEDURE validate_product_txn_rec (
      p_product_txn_rec   IN   csd_process_pvt.product_txn_rec
   )
   IS
      l_api_version_number   CONSTANT NUMBER        := 1.0;
      l_api_name             CONSTANT VARCHAR2 (30) := 'PROCESS_RO';
      l_return_status                 VARCHAR2 (1) ;
      l_check                         VARCHAR2 (1);
   BEGIN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                (fnd_log.level_procedure,
                 'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_PRODUCT_TXN_REC.BEGIN',
                 'Entered Validate_Product_Txn_Rec'
                );
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                (fnd_log.level_statement,
                 'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_PRODUCT_TXN_REC.BEGIN',
                 'Checking mandatory parameters'
                );
      END IF;

      l_return_status := fnd_api.g_ret_sts_success;

      csd_process_util.check_reqd_param
                           (p_param_value      => p_product_txn_rec.repair_line_id,
                            p_param_name       => 'REPAIR_LINE_ID',
                            p_api_name         => l_api_name
                           );
      -- Check the required parameter(action_code)
      csd_process_util.check_reqd_param
                              (p_param_value      => p_product_txn_rec.action_code,
                               p_param_name       => 'ACTION_CODE',
                               p_api_name         => l_api_name
                              );
      -- Check the required parameter(action_type)
      csd_process_util.check_reqd_param
                              (p_param_value      => p_product_txn_rec.action_type,
                               p_param_name       => 'ACTION_TYPE',
                               p_api_name         => l_api_name
                              );
      -- Check the required parameter(txn_billing_type_id)
      csd_process_util.check_reqd_param
                      (p_param_value      => p_product_txn_rec.txn_billing_type_id,
                       p_param_name       => 'TXN_BILLING_TYPE_ID',
                       p_api_name         => l_api_name
                      );
      -- Check the required parameter(inventory_item_id)
      csd_process_util.check_reqd_param
                        (p_param_value      => p_product_txn_rec.inventory_item_id,
                         p_param_name       => 'INVENTORY_ITEM_ID',
                         p_api_name         => l_api_name
                        );
      -- Check the required parameter(unit_of_measure_code)
      csd_process_util.check_reqd_param
                     (p_param_value      => p_product_txn_rec.unit_of_measure_code,
                      p_param_name       => 'UNIT_OF_MEASURE_CODE',
                      p_api_name         => l_api_name
                     );
      -- Check the required parameter(quantity)
      csd_process_util.check_reqd_param
                                 (p_param_value      => p_product_txn_rec.quantity,
                                  p_param_name       => 'QUANTITY',
                                  p_api_name         => l_api_name
                                 );
      -- Check the required parameter(price_list_id)
      csd_process_util.check_reqd_param
                            (p_param_value      => p_product_txn_rec.price_list_id,
                             p_param_name       => 'PRICE_LIST_ID',
                             p_api_name         => l_api_name
                            );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                      (fnd_log.level_statement,
                       'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_PRODUCT_TXN_REC',
                       'Validate repair line id'
                      );
      END IF;

      -- Validate the repair line ID if it exists in csd_repairs
      IF NOT (csd_process_util.validate_rep_line_id
                         (p_repair_line_id      => p_product_txn_rec.repair_line_id)
             )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                      (fnd_log.level_statement,
                       'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_PRODUCT_TXN_REC',
                       'Validate action type'
                      );
      END IF;

      -- Validate the Action Type if it exists in fnd_lookups
      IF NOT (csd_process_util.validate_action_type
                               (p_action_type      => p_product_txn_rec.action_type)
             )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                      (fnd_log.level_statement,
                       'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_PRODUCT_TXN_REC',
                       'Validate action code'
                      );
      END IF;

      -- Validate the repair line ID if it exists in fnd_lookups
      IF NOT (csd_process_util.validate_action_code
                               (p_action_code      => p_product_txn_rec.action_code)
             )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                      (fnd_log.level_statement,
                       'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_PRODUCT_TXN_REC',
                       'Validate product txn qty'
                      );
         fnd_log.STRING
                 (fnd_log.level_statement,
                  'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_PRODUCT_TXN_REC.BEGIN',
                  'p_product_txn_rec.quantity =' || p_product_txn_rec.quantity
                 );
      END IF;

      -- Validate if the product txn quantity (customer product only)
      -- is not exceeding the repair order quantity
      IF p_product_txn_rec.action_code = 'CUST_PROD'
      THEN
         csd_process_util.validate_quantity
                       (p_action_type         => p_product_txn_rec.action_type,
                        p_repair_line_id      => p_product_txn_rec.repair_line_id,
                        p_prod_txn_qty        => p_product_txn_rec.quantity,
                        x_return_status       => l_return_status
                       );

         IF NOT (l_return_status = fnd_api.g_ret_sts_success)
         THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                      (fnd_log.level_statement,
                       'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_PRODUCT_TXN_REC',
                       'Validate_Quantity failed '
                      );
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                      (fnd_log.level_statement,
                       'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_PRODUCT_TXN_REC',
                       'Validate product txn status'
                      );
         fnd_log.STRING
                 (fnd_log.level_statement,
                  'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_PRODUCT_TXN_REC.BEGIN',
                     'p_product_txn_rec.PROD_TXN_STATUS ='
                  || p_product_txn_rec.prod_txn_status
                 );
      END IF;

      -- Validate the PROD_TXN_STATUS if it exists in fnd_lookups
      IF     (p_product_txn_rec.prod_txn_status IS NOT NULL)
         AND (p_product_txn_rec.prod_txn_status <> fnd_api.g_miss_char)
      THEN
         BEGIN
            SELECT 'X'
              INTO l_check
              FROM fnd_lookups
             WHERE lookup_type = 'CSD_PRODUCT_TXN_STATUS'
               AND lookup_code = p_product_txn_rec.prod_txn_status;
         EXCEPTION
            WHEN OTHERS
            THEN
               fnd_message.set_name ('CSD', 'CSD_ERR_PROD_TXN_STATUS');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
         END;
      END IF;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                  (fnd_log.level_procedure,
                   'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_PRODUCT_TXN_REC.END',
                   'Leaving Validate_Product_Txn_Rec'
                  );
      END IF;
   END validate_product_txn_rec;

------------------------------------------------------------------------------
-------------------------------------------------------------------------------
   FUNCTION is_item_pre_serialized (p_inv_item_id IN NUMBER)
      RETURN BOOLEAN
   IS
      l_serial_code   NUMBER ;
   BEGIN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                  (fnd_log.level_procedure,
                   'CSD.PLSQL.CSD_MASS_RCV_PVT.Is_Item_Pre_serialized.BEGIN',
                   'Entered Is_Item_Pre_serialized'
                  );
      END IF;

      SELECT serial_number_control_code
        INTO l_serial_code
        FROM mtl_system_items
       WHERE inventory_item_id = p_inv_item_id
         AND organization_id = cs_std.get_item_valdn_orgzn_id;

      IF l_serial_code = 2
      THEN                                  -- 2 ==> predefined serial numbers
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                    (fnd_log.level_procedure,
                     'CSD.PLSQL.CSD_MASS_RCV_PVT.Is_Item_Pre_serialized.END',
                     'Leaving Is_Item_Pre_serialized'
                    );
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         fnd_message.set_name ('CSD', 'CSD_API_INV_ITEM_ID');
         fnd_message.set_token ('INVENTORY_ITEM_ID', p_inv_item_id);
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
   END is_item_pre_serialized;

------------------------------------------------------------------------------
-------------------------------------------------------------------------------
   FUNCTION is_item_ib_trackable (p_inv_item_id IN NUMBER)
      RETURN BOOLEAN
   IS
      l_ib_trackable_flag   VARCHAR2 (1) ;
   BEGIN
      SELECT NVL (comms_nl_trackable_flag, 'N')
        INTO l_ib_trackable_flag
        FROM mtl_system_items
       WHERE inventory_item_id = p_inv_item_id
         AND organization_id = cs_std.get_item_valdn_orgzn_id;

      IF l_ib_trackable_flag = 'Y'
      THEN                                                                   --
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         fnd_message.set_name ('CSD', 'CSD_API_INV_ITEM_ID');
         fnd_message.set_token ('INVENTORY_ITEM_ID', p_inv_item_id);
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
   END is_item_ib_trackable;

----------------------------------------------------------------------
-- Funciton to validate the order
----------------------------------------------------------------------
   PROCEDURE validate_order (
      p_est_detail_id   IN              NUMBER,
      p_order_rec       IN OUT NOCOPY   csd_process_pvt.om_interface_rec,
      x_booked_flag     OUT NOCOPY      VARCHAR2
   )
   IS
      l_order_header_id      NUMBER;
      l_order_line_id        NUMBER;
      l_ship_from_org_id     NUMBER;
      l_unit_selling_price   NUMBER;

      --Cursors
      CURSOR cur_ord_hdr (p_header_id NUMBER)
      IS
         SELECT booked_flag
           FROM oe_order_headers_all
          WHERE header_id = p_header_id;

      --
      CURSOR cur_ord_details (p_est_detial_id NUMBER)
      IS
         SELECT a.order_header_id, a.order_line_id
           FROM cs_estimate_details a
          WHERE a.estimate_detail_id = p_est_detial_id
            AND a.order_header_id IS NOT NULL;

      CURSOR cur_ord_line (p_order_line_id NUMBER)
      IS
         SELECT ship_from_org_id, unit_selling_price, org_id
           FROM oe_order_lines_all
          WHERE line_id = p_order_line_id;

        /*FP Fixed for bug#5368306
		  OM does not require sales rep at line to book it.
		  Depot should not check sales rep at line since oe
		  allows to book an order without a sales rep at
		  the line.
		  Following condition which checks sales rep at
		  order line has been commented.
 		  */
		  /*AND salesrep_id IS NOT NULL;*/

   BEGIN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_ORDER.BEGIN',
                         'Entered Validate_order'
                        );
      END IF;

      -- Get the order header id
      -- from the charge line
      OPEN cur_ord_details (p_est_detail_id);

      FETCH cur_ord_details
       INTO p_order_rec.order_header_id, l_order_line_id;

      IF (cur_ord_details%NOTFOUND)
      THEN
         fnd_message.set_name ('CSD','CSD_API_BOOKING_FAILED'); /*FP Fixed for bug#5147030 message changed*/
         /*
         fnd_message.set_name ('CSD', 'CSD_API_INV_EST_DETAIL_ID');
         fnd_message.set_token ('ESTIMATE_DETAIL_ID', p_est_detail_id);
         */
         fnd_msg_pub.ADD;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_ORDER',
                               'Sales Order missing for estimate_detail_id ='
                            || p_est_detail_id
                           );
         END IF;

         CLOSE cur_ord_details;

         RAISE fnd_api.g_exc_error;
      END IF;

      IF cur_ord_details%ROWCOUNT > 1
      THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_ORDER',
                            'Too many order header ids'
                           );
         END IF;
      END IF;

      CLOSE cur_ord_details;

      OPEN cur_ord_line (l_order_line_id);

      FETCH cur_ord_line
       INTO l_ship_from_org_id, l_unit_selling_price, p_order_rec.org_id;

      IF (cur_ord_line%NOTFOUND)
      THEN
         fnd_message.set_name ('CSD', 'CSD_API_SALES_REP_MISSING');
         fnd_message.set_token ('ORDER_LINE_ID', l_order_line_id);
         fnd_msg_pub.ADD;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_ORDER',
                            'Sales rep missing for Line_id='
                            || l_order_line_id
                           );
         END IF;

         CLOSE cur_ord_line;

         RAISE fnd_api.g_exc_error;
      END IF;

      IF cur_ord_line%ROWCOUNT > 1
      THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_ORDER',
                            'Too many order ship_from_org_id'
                           );
         END IF;
      END IF;

      CLOSE cur_ord_line;

      IF l_ship_from_org_id IS NULL
      THEN
         fnd_message.set_name ('CSD', 'CSD_API_SHIP_FROM_ORG_MISSING');
         fnd_message.set_token ('ORDER_LINE_ID', l_order_line_id);
         fnd_msg_pub.ADD;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_ORDER',
                               'Ship from Org Id missing for Line_id='
                            || l_order_line_id
                           );
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      IF l_unit_selling_price IS NULL
      THEN
         fnd_message.set_name ('CSD', 'CSD_API_PRICE_MISSING');
         fnd_message.set_token ('ORDER_LINE_ID', l_order_line_id);
         fnd_msg_pub.ADD;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_ORDER',
                               'Unit Selling price missing for Line_id='
                            || l_order_line_id
                           );
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      OPEN cur_ord_hdr (p_order_rec.order_header_id);

      FETCH cur_ord_hdr
       INTO x_booked_flag;

      IF (cur_ord_hdr%NOTFOUND)
      THEN
         fnd_message.set_name ('CSD', 'CSD_INV_ORDER_HEADER_ID');
         fnd_message.set_token ('ORDER_HEADER_ID',
                                p_order_rec.order_header_id
                               );
         fnd_msg_pub.ADD;

         CLOSE cur_ord_hdr;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE cur_ord_hdr;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_MASS_RCV_PVT.VALIDATE_ORDER.END',
                         'Leaving Validate_order'
                        );
      END IF;
   END validate_order;

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
                               'CSD.PLSQL.CSD_MASS_RCV_PVT.log_error_stack',
                               'error[' || l_msg || ']'
                              );
            END IF;
         END LOOP;
      END IF;
   END log_error_stack;


   procedure upd_instance(p_repair_type_ref IN  VARCHAR2,
                          p_serial_number   IN  VARCHAR2,
                          p_instance_id     IN  NUMBER,
                          x_prod_txn_tbl    IN OUT NOCOPY   csd_process_pvt.product_txn_tbl
                         ) IS
   BEGIN
       IF p_repair_type_ref = 'R' THEN
         -- in 11.5.10 we have place holder for non source item attributes
         -- like non_source_serial_number non_source_instance_id etc
         -- Shipping customer product txn line
         x_prod_txn_tbl(1).non_source_serial_number    := p_serial_number   ; -- 11.5.10
         x_prod_txn_tbl(1).non_source_instance_id      := p_instance_id; -- 11.5.10
         x_prod_txn_tbl(1).source_serial_number        := FND_API.G_MISS_CHAR;
         x_prod_txn_tbl(1).source_instance_id          := FND_API.G_MISS_NUM;
       ELSIF p_repair_type_ref in ('RR','WR','E' ) THEN
         x_prod_txn_tbl(1).source_serial_number        := p_serial_number   ;
         x_prod_txn_tbl(1).source_instance_id          := p_instance_id     ;
         x_prod_txn_tbl(1).non_source_serial_number    := FND_API.G_MISS_CHAR;
         x_prod_txn_tbl(1).non_source_instance_id      := FND_API.G_MISS_NUM;
        IF p_repair_type_ref = 'E' THEN
          x_prod_txn_tbl(2).non_source_instance_id     := p_instance_id;
          x_prod_txn_tbl(2).non_source_serial_number   := p_serial_number;
          x_prod_txn_tbl(2).source_instance_id         := FND_API.G_MISS_NUM;
          x_prod_txn_tbl(2).source_serial_number       :=  FND_API.G_MISS_CHAR;
        ELSE
          x_prod_txn_tbl(2).non_source_instance_id     := FND_API.G_MISS_NUM;
          x_prod_txn_tbl(2).non_source_serial_number   := FND_API.G_MISS_CHAR;
          x_prod_txn_tbl(2).source_instance_id         := p_instance_id;
          x_prod_txn_tbl(2).source_serial_number       :=  p_serial_number;
        END IF;


       ELSIF (p_repair_type_ref = 'AL') THEN
         x_prod_txn_tbl(1).source_serial_number        := FND_API.G_MISS_CHAR;
         x_prod_txn_tbl(1).non_source_serial_number    := FND_API.G_MISS_CHAR;
         x_prod_txn_tbl(1).source_instance_id          := FND_API.G_MISS_NUM;
         x_prod_txn_tbl(1).non_source_instance_id      := FND_API.G_MISS_NUM;
         x_prod_txn_tbl(2).source_serial_number        := p_serial_number;
         x_prod_txn_tbl(2).non_source_serial_number    := FND_API.G_MISS_CHAR;
         x_prod_txn_tbl(2).source_instance_id          := p_instance_id     ;
         x_prod_txn_tbl(2).non_source_instance_id      := FND_API.G_MISS_NUM;

       ELSIF ( p_repair_type_ref = 'AE' ) THEN

         x_prod_txn_tbl(1).source_serial_number        := FND_API.G_MISS_CHAR;
         x_prod_txn_tbl(1).non_source_serial_number    := p_serial_number ;
         x_prod_txn_tbl(1).source_instance_id          := FND_API.G_MISS_NUM;
         x_prod_txn_tbl(1).non_source_instance_id      := p_instance_id     ;
         x_prod_txn_tbl(2).source_serial_number        := p_serial_number  ;
         x_prod_txn_tbl(2).non_source_serial_number    := FND_API.G_MISS_CHAR;
         x_prod_txn_tbl(2).source_instance_id          := p_instance_id     ;
         x_prod_txn_tbl(2).non_source_instance_id      := FND_API.G_MISS_NUM;
       ELSIF p_repair_type_ref in ('ARR','WRL') THEN

         x_prod_txn_tbl(1).source_serial_number        := FND_API.G_MISS_CHAR;
         x_prod_txn_tbl(1).non_source_serial_number    := FND_API.G_MISS_CHAR;
         x_prod_txn_tbl(1).source_instance_id          := FND_API.G_MISS_NUM;
         x_prod_txn_tbl(1).non_source_instance_id      := FND_API.G_MISS_NUM;

         x_prod_txn_tbl(2).source_serial_number        := p_serial_number;
         x_prod_txn_tbl(2).non_source_serial_number    := FND_API.G_MISS_CHAR;
         x_prod_txn_tbl(2).source_instance_id          := p_instance_id     ;
         x_prod_txn_tbl(2).non_source_instance_id      := FND_API.G_MISS_NUM;
         x_prod_txn_tbl(3).source_serial_number        := p_serial_number ;
         x_prod_txn_tbl(3).non_source_serial_number    := FND_API.G_MISS_CHAR;
         x_prod_txn_tbl(3).source_instance_id          := p_instance_id ;
         x_prod_txn_tbl(3).non_source_instance_id      := FND_API.G_MISS_NUM;
         x_prod_txn_tbl(4).source_serial_number        := p_serial_number;
         x_prod_txn_tbl(4).non_source_serial_number    := FND_API.G_MISS_CHAR;
         x_prod_txn_tbl(4).source_instance_id          := p_instance_id    ;
         x_prod_txn_tbl(4).non_source_instance_id      := FND_API.G_MISS_NUM;

       END IF;

   END upd_instance;


END csd_mass_rcv_pvt;

/

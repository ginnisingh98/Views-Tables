--------------------------------------------------------
--  DDL for Package Body CSI_ML_REPLACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ML_REPLACE_PVT" AS
-- $Header: csimrplb.pls 115.23 2003/01/08 21:57:19 jpwilson noship $

   PROCEDURE process_replace (
      p_txn_identifier   IN  VARCHAR2,
      p_source_system_name IN  VARCHAR2,
      x_instance_tbl     OUT NOCOPY      csi_datastructures_pub.instance_tbl,
      x_party_tbl        OUT NOCOPY      csi_datastructures_pub.party_tbl,
      x_account_tbl      OUT NOCOPY      csi_datastructures_pub.party_account_tbl,
      x_eav_tbl          OUT NOCOPY      csi_datastructures_pub.extend_attrib_values_tbl,
      x_price_tbl        OUT NOCOPY      csi_datastructures_pub.pricing_attribs_tbl,
      x_org_assign_tbl   OUT NOCOPY      csi_datastructures_pub.organization_units_tbl,
      x_return_status    OUT NOCOPY      VARCHAR2,
      x_error_message    OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR csi_intf_repl_cur (c_id IN VARCHAR2,
                                c_source IN VARCHAR2)
      IS
         SELECT   *
         FROM csi_instance_interface
         WHERE transaction_identifier = c_id
         AND   source_system_name = c_source
         ORDER BY inst_interface_id;

      CURSOR csi_intf_party_acct_cur (c_inst_interface_id IN NUMBER)
      IS
         SELECT   *
             FROM csi_i_party_interface cpi
            WHERE cpi.inst_interface_id = c_inst_interface_id
         ORDER BY ip_interface_id;

      CURSOR csi_intf_ext_attrib_cur (c_inst_interface_id IN NUMBER)
      IS
         SELECT   *
             FROM csi_iea_value_interface ceai
            WHERE ceai.inst_interface_id = c_inst_interface_id
         ORDER BY ieav_interface_id;

      l_end_date                    DATE :=   SYSDATE + 1;
      l_api_name                    VARCHAR2 (255)
                                       := 'CSI_ML_REPLACE_PVT.PROCESS_REPLACE';
      l_instance_header_rec         csi_datastructures_pub.instance_header_rec;
      l_msg_count                   NUMBER (3);
      l_msg_data                    VARCHAR2 (200);
      l_msg_index                   NUMBER (3);
      l_sql_error                   VARCHAR2 (2000);
      l_api_version                 NUMBER (3)                   := 1.0;
      l_init_msg_list               VARCHAR2 (1)                 := fnd_api.g_true;
      l_commit                      VARCHAR2 (1)                 := fnd_api.g_false;
      e_error                       EXCEPTION;
      x_party_header_tbl            csi_datastructures_pub.party_header_tbl;
      x_party_cache_tbl             csi_datastructures_pub.party_header_tbl;
      x_party_account_header_tbl    csi_datastructures_pub.party_account_header_tbl;
      x_org_units_header_tbl        csi_datastructures_pub.org_units_header_tbl;
      x_pricing_attribs_tbl         csi_datastructures_pub.pricing_attribs_tbl;
      x_ext_attrib_value_tbl        csi_datastructures_pub.extend_attrib_values_tbl;
      x_extend_attrib_tbl           csi_datastructures_pub.extend_attrib_tbl;
      x_instance_asset_header_tbl   csi_datastructures_pub.instance_asset_header_tbl;
      l_price_index                 PLS_INTEGER;
      l_org_index                   PLS_INTEGER;
      l_party_index                 PLS_INTEGER;
      l_party_account_index         PLS_INTEGER;
      l_ieav_index                  PLS_INTEGER;
      inst_index                  PLS_INTEGER;
      i                             PLS_INTEGER;
      b_end_dated                   BOOLEAN                      := TRUE;
      l_miss_char          CONSTANT VARCHAR2 (1)                 := fnd_api.g_miss_char;
      l_miss_num           CONSTANT NUMBER                       := fnd_api.g_miss_num;
      l_miss_date          CONSTANT DATE                         := fnd_api.g_miss_date;
      r_instance_id       NUMBER;
      FUNCTION get_parent_tbl_index (
         p_instance_party_id        IN   NUMBER,
         p_relationship_type_code   IN   VARCHAR2
      )
         RETURN PLS_INTEGER
      IS
         l_miss_char   CONSTANT VARCHAR2 (1) := fnd_api.g_miss_char;
         l_miss_num    CONSTANT NUMBER       := fnd_api.g_miss_num;
         l_index                PLS_INTEGER;
      BEGIN
         l_index := NULL;
         IF x_party_tbl.COUNT >= 1
         THEN
            FOR i IN x_party_tbl.FIRST .. x_party_tbl.LAST
            LOOP
               IF      x_party_tbl.EXISTS (i)
                   AND NVL (x_party_tbl (i).instance_party_id, l_miss_num) =
                                        NVL (p_instance_party_id, l_miss_num)
                   AND NVL (
                          x_party_tbl (i).relationship_type_code,
                          l_miss_char
                       ) = NVL (p_relationship_type_code, l_miss_char)
               THEN
                  l_index := i;
               END IF;
            END LOOP;
         END IF;

         RETURN l_index;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN NULL;
      END get_parent_tbl_index;

      FUNCTION get_obj_ver_num (
         p_party_tbl           IN   csi_datastructures_pub.party_header_tbl,
         p_instance_party_id   IN   NUMBER
      )
         RETURN PLS_INTEGER
      IS
         l_num   NUMBER (30) := NULL;
      BEGIN
         IF p_party_tbl.COUNT >= 1
         THEN
            FOR i IN x_party_tbl.FIRST .. x_party_tbl.LAST
            LOOP
               IF      p_party_tbl.EXISTS (i)
                   AND p_party_tbl (i).instance_party_id =
                                                          p_instance_party_id
               THEN
                  l_num := p_party_tbl (i).object_version_number;
               END IF;
            END LOOP;
         END IF;

         RETURN l_num;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN NULL;
      END get_obj_ver_num;
   BEGIN

--dbms_output.put_line('BEGIN Replace group id is '||p_group_id);

      x_party_tbl.DELETE;
      x_account_tbl.DELETE;
      x_price_tbl.DELETE;
      x_org_assign_tbl.DELETE;
      x_eav_tbl.DELETE;

      FOR csi_intf_repl_rec IN csi_intf_repl_cur (p_txn_identifier,
                                                  p_source_system_name)
      LOOP
         BEGIN
            SAVEPOINT instance_entity;
            l_instance_header_rec.instance_id :=
                                                csi_intf_repl_rec.instance_id;

--dbms_output.put_line('calling get item instance details ');
            csi_item_instance_pub.get_item_instance_details (
               p_api_version=> l_api_version,
               p_commit=> l_commit,
               p_init_msg_list=> l_init_msg_list,
               p_validation_level=> fnd_api.g_valid_level_full,
               p_instance_rec=> l_instance_header_rec,
               p_get_parties=> fnd_api.g_true,
               p_party_header_tbl=> x_party_header_tbl,
               p_get_accounts=> fnd_api.g_true,
               p_account_header_tbl=> x_party_account_header_tbl,
               p_get_org_assignments=> fnd_api.g_true,
               p_org_header_tbl=> x_org_units_header_tbl,
               p_get_pricing_attribs=> fnd_api.g_true,
               p_pricing_attrib_tbl=> x_pricing_attribs_tbl,
               p_get_ext_attribs=> fnd_api.g_true,
               p_ext_attrib_tbl=> x_ext_attrib_value_tbl,
               p_ext_attrib_def_tbl=> x_extend_attrib_tbl,
               p_get_asset_assignments=> fnd_api.g_false,
               p_asset_header_tbl=> x_instance_asset_header_tbl,
               p_resolve_id_columns=> fnd_api.g_false,
               p_time_stamp=> NULL,
               x_return_status=> x_return_status,
               x_msg_count=> l_msg_count,
               x_msg_data=> l_msg_data
            );


--dbms_output.put_line('after get item instance details status : '||x_return_status);
            IF x_return_status <> fnd_api.g_ret_sts_success
            THEN
               l_msg_index := 1;
               x_error_message := l_msg_data;

               WHILE l_msg_count > 0
               LOOP
                  x_error_message :=    x_error_message
                                     || fnd_msg_pub.get (
                                           l_msg_index,
                                           fnd_api.g_false
                                        );
                  l_msg_index :=   l_msg_index
                                 + 1;
                  l_msg_count :=   l_msg_count
                                 - 1;
               END LOOP;

               RAISE e_error;
            END IF;

            x_instance_tbl(inst_index).instance_id := csi_intf_repl_rec.instance_id;
            x_instance_tbl(inst_index).vld_organization_id :=
                                     csi_intf_repl_rec.inv_vld_organization_id;


--dbms_output.put_line('after get item instance details ');
            IF NOT (    NVL (csi_intf_repl_rec.location_id, l_miss_num) =
                                  NVL (x_instance_tbl(inst_index).location_id, l_miss_num)
                    AND NVL (
                           csi_intf_repl_rec.inventory_revision,
                           l_miss_char
                        ) = NVL (
                               x_instance_tbl(inst_index).inventory_revision,
                               l_miss_char
                            )
                    AND NVL (csi_intf_repl_rec.lot_number, l_miss_char) =
                                  NVL (x_instance_tbl(inst_index).lot_number, l_miss_char)
                    AND NVL (csi_intf_repl_rec.quantity, l_miss_num) =
                                  NVL (x_instance_tbl(inst_index).location_id, l_miss_num)
                    AND NVL (csi_intf_repl_rec.unit_of_measure, l_miss_char) =
                             NVL (x_instance_tbl(inst_index).unit_of_measure, l_miss_char)
                    AND NVL (
                           csi_intf_repl_rec.accounting_class_code,
                           l_miss_char
                        ) = NVL (
                               x_instance_tbl(inst_index).accounting_class_code,
                               l_miss_char
                            )
                    AND NVL (csi_intf_repl_rec.instance_end_date, l_miss_date) =
                             NVL (x_instance_tbl(inst_index).active_end_date, l_miss_date)
                    AND NVL (
                           csi_intf_repl_rec.inv_subinventory_name,
                           l_miss_char
                        ) = NVL (
                               x_instance_tbl(inst_index).inv_subinventory_name,
                               l_miss_char
                            )
                    AND NVL (csi_intf_repl_rec.inv_locator_id, l_miss_num) =
                               NVL (x_instance_tbl(inst_index).inv_locator_id, l_miss_num)
                    AND NVL (csi_intf_repl_rec.project_id, l_miss_num) =
                                NVL (x_instance_tbl(inst_index).pa_project_id, l_miss_num)
                    AND NVL (csi_intf_repl_rec.task_id, l_miss_num) =
                           NVL (x_instance_tbl(inst_index).pa_project_task_id, l_miss_num)
                    AND NVL (
                           csi_intf_repl_rec.in_transit_order_line_id,
                           l_miss_num
                        ) = NVL (
                               x_instance_tbl(inst_index).in_transit_order_line_id,
                               l_miss_num
                            )
                    AND NVL (csi_intf_repl_rec.wip_job_id, l_miss_num) =
                                   NVL (x_instance_tbl(inst_index).wip_job_id, l_miss_num)
                    AND NVL (csi_intf_repl_rec.po_order_line_id, l_miss_num) =
                             NVL (x_instance_tbl(inst_index).po_order_line_id, l_miss_num)
                    AND NVL (csi_intf_repl_rec.oe_order_line_id, l_miss_num) =
                              NVL (
                                 x_instance_tbl(inst_index).last_oe_order_line_id,
                                 l_miss_num
                              )
                    AND NVL (csi_intf_repl_rec.install_date, l_miss_date) =
                                NVL (x_instance_tbl(inst_index).install_date, l_miss_date)
                    AND NVL (csi_intf_repl_rec.return_by_date, l_miss_date) =
                              NVL (x_instance_tbl(inst_index).return_by_date, l_miss_date)
                    AND NVL (
                           csi_intf_repl_rec.actual_return_date,
                           l_miss_date
                        ) = NVL (
                               x_instance_tbl(inst_index).actual_return_date,
                               l_miss_date
                            )
                    AND NVL (csi_intf_repl_rec.instance_context, l_miss_char) =
                                     NVL (x_instance_tbl(inst_index).CONTEXT, l_miss_char)
                    AND NVL (
                           csi_intf_repl_rec.instance_attribute1,
                           l_miss_char
                        ) = NVL (x_instance_tbl(inst_index).attribute1, l_miss_char)
                    AND NVL (
                           csi_intf_repl_rec.instance_attribute2,
                           l_miss_char
                        ) = NVL (x_instance_tbl(inst_index).attribute2, l_miss_char)
                    AND NVL (
                           csi_intf_repl_rec.instance_attribute3,
                           l_miss_char
                        ) = NVL (x_instance_tbl(inst_index).attribute3, l_miss_char)
                    AND NVL (
                           csi_intf_repl_rec.instance_attribute4,
                           l_miss_char
                        ) = NVL (x_instance_tbl(inst_index).attribute4, l_miss_char)
                    AND NVL (
                           csi_intf_repl_rec.instance_attribute5,
                           l_miss_char
                        ) = NVL (x_instance_tbl(inst_index).attribute5, l_miss_char)
                    AND NVL (
                           csi_intf_repl_rec.instance_attribute6,
                           l_miss_char
                        ) = NVL (x_instance_tbl(inst_index).attribute6, l_miss_char)
                    AND NVL (
                           csi_intf_repl_rec.instance_attribute7,
                           l_miss_char
                        ) = NVL (x_instance_tbl(inst_index).attribute7, l_miss_char)
                    AND NVL (
                           csi_intf_repl_rec.instance_attribute8,
                           l_miss_char
                        ) = NVL (x_instance_tbl(inst_index).attribute8, l_miss_char)
                    AND NVL (
                           csi_intf_repl_rec.instance_attribute9,
                           l_miss_char
                        ) = NVL (x_instance_tbl(inst_index).attribute9, l_miss_char)
                    AND NVL (
                           csi_intf_repl_rec.instance_attribute10,
                           l_miss_char
                        ) = NVL (x_instance_tbl(inst_index).attribute10, l_miss_char)
                    AND NVL (
                           csi_intf_repl_rec.instance_attribute11,
                           l_miss_char
                        ) = NVL (x_instance_tbl(inst_index).attribute11, l_miss_char)
                    AND NVL (
                           csi_intf_repl_rec.instance_attribute12,
                           l_miss_char
                        ) = NVL (x_instance_tbl(inst_index).attribute12, l_miss_char)
                    AND NVL (
                           csi_intf_repl_rec.instance_attribute13,
                           l_miss_char
                        ) = NVL (x_instance_tbl(inst_index).attribute13, l_miss_char)
                    AND NVL (
                           csi_intf_repl_rec.instance_attribute14,
                           l_miss_char
                        ) = NVL (x_instance_tbl(inst_index).attribute14, l_miss_char)
                    AND NVL (
                           csi_intf_repl_rec.instance_attribute15,
                           l_miss_char
                        ) = NVL (x_instance_tbl(inst_index).attribute15, l_miss_char)
                   )
            THEN

--dbms_output.put_line('instance changes are there');
               SELECT DECODE (
                         csi_intf_repl_rec.location_id,
                         l_instance_header_rec.location_id, l_miss_num,
                         NULL, DECODE (
                                  l_instance_header_rec.location_id,
                                  NULL, l_miss_num,
                                  NULL
                               ),
                         csi_intf_repl_rec.location_id
                      ),
                      DECODE (
                         csi_intf_repl_rec.inventory_revision,
                         l_instance_header_rec.inventory_revision, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.inventory_revision,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.inventory_revision
                      ),
                      DECODE (
                         csi_intf_repl_rec.lot_number,
                         l_instance_header_rec.lot_number, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.lot_number,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.lot_number
                      ),
                      DECODE (
                         csi_intf_repl_rec.quantity,
                         l_instance_header_rec.quantity, l_miss_num,
                         NULL, DECODE (
                                  l_instance_header_rec.quantity,
                                  NULL, l_miss_num,
                                  NULL
                               ),
                         csi_intf_repl_rec.quantity
                      ),
                      DECODE (
                         csi_intf_repl_rec.unit_of_measure_code,
                         l_instance_header_rec.unit_of_measure, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.unit_of_measure,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.unit_of_measure_code
                      ),
                      DECODE (
                         csi_intf_repl_rec.accounting_class_code,
                         l_instance_header_rec.accounting_class_code, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.accounting_class_code,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.accounting_class_code
                      ),
                      DECODE (
                         csi_intf_repl_rec.instance_end_date,
                         l_instance_header_rec.active_end_date, l_miss_date,
                         NULL, DECODE (
                                  l_instance_header_rec.active_end_date,
                                  NULL, l_miss_date,
                                  NULL
                               ),
                         csi_intf_repl_rec.instance_end_date
                      ),
                      DECODE (
                         csi_intf_repl_rec.location_type_code,
                         l_instance_header_rec.location_type_code, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.location_type_code,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.location_type_code
                      ),
                      DECODE (
                         csi_intf_repl_rec.inv_subinventory_name,
                         l_instance_header_rec.inv_subinventory_name, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.inv_subinventory_name,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.inv_subinventory_name
                      ),
                      DECODE (
                         csi_intf_repl_rec.inv_locator_id,
                         l_instance_header_rec.inv_locator_id, l_miss_num,
                         NULL, DECODE (
                                  l_instance_header_rec.inv_locator_id,
                                  NULL, l_miss_num,
                                  NULL
                               ),
                         csi_intf_repl_rec.inv_locator_id
                      ),
                      DECODE (
                         csi_intf_repl_rec.project_id,
                         l_instance_header_rec.pa_project_id, l_miss_num,
                         NULL, DECODE (
                                  l_instance_header_rec.pa_project_id,
                                  NULL, l_miss_num,
                                  NULL
                               ),
                         csi_intf_repl_rec.project_id
                      ),
                      DECODE (
                         csi_intf_repl_rec.task_id,
                         l_instance_header_rec.pa_project_task_id, l_miss_num,
                         NULL, DECODE (
                                  l_instance_header_rec.pa_project_task_id,
                                  NULL, l_miss_num,
                                  NULL
                               ),
                         csi_intf_repl_rec.task_id
                      ),
                      DECODE (
                         csi_intf_repl_rec.in_transit_order_line_id,
                         l_instance_header_rec.in_transit_order_line_id, l_miss_num,
                         NULL, DECODE (
                                  l_instance_header_rec.in_transit_order_line_id,
                                  NULL, l_miss_num,
                                  NULL
                               ),
                         csi_intf_repl_rec.in_transit_order_line_id
                      ),
                      DECODE (
                         csi_intf_repl_rec.wip_job_id,
                         l_instance_header_rec.wip_job_id, l_miss_num,
                         NULL, DECODE (
                                  l_instance_header_rec.wip_job_id,
                                  NULL, l_miss_num,
                                  NULL
                               ),
                         csi_intf_repl_rec.wip_job_id
                      ),
                      DECODE (
                         csi_intf_repl_rec.po_order_line_id,
                         l_instance_header_rec.po_order_line_id, l_miss_num,
                         NULL, DECODE (
                                  l_instance_header_rec.po_order_line_id,
                                  NULL, l_miss_num,
                                  NULL
                               ),
                         csi_intf_repl_rec.po_order_line_id
                      ),
                      DECODE (
                         csi_intf_repl_rec.oe_order_line_id,
                         l_instance_header_rec.last_oe_order_line_id, l_miss_num,
                         NULL, DECODE (
                                  l_instance_header_rec.last_oe_order_line_id,
                                  NULL, l_miss_num,
                                  NULL
                               ),
                         csi_intf_repl_rec.oe_order_line_id
                      ),
                      DECODE (
                         csi_intf_repl_rec.oe_rma_line_id,
                         l_instance_header_rec.last_oe_rma_line_id, l_miss_num,
                         NULL, DECODE (
                                  l_instance_header_rec.last_oe_rma_line_id,
                                  NULL, l_miss_num,
                                  NULL
                               ),
                         csi_intf_repl_rec.oe_rma_line_id
                      ),
                      DECODE (
                         csi_intf_repl_rec.po_order_line_id,
                         l_instance_header_rec.last_po_po_line_id, l_miss_num,
                         NULL, DECODE (
                                  l_instance_header_rec.po_order_line_id,
                                  NULL, l_miss_num,
                                  NULL
                               ),
                         csi_intf_repl_rec.po_order_line_id
                      ),
                      DECODE (
                         csi_intf_repl_rec.oe_po_number,
                         l_instance_header_rec.last_oe_po_number, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.last_oe_po_number,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.oe_po_number
                      ),
                      DECODE (
                         csi_intf_repl_rec.install_date,
                         l_instance_header_rec.install_date, l_miss_date,
                         NULL, DECODE (
                                  l_instance_header_rec.install_date,
                                  NULL, l_miss_date,
                                  NULL
                               ),
                         csi_intf_repl_rec.install_date
                      ),
                      DECODE (
                         csi_intf_repl_rec.return_by_date,
                         l_instance_header_rec.return_by_date, l_miss_date,
                         NULL, DECODE (
                                  l_instance_header_rec.return_by_date,
                                  NULL, l_miss_date,
                                  NULL
                               ),
                         csi_intf_repl_rec.return_by_date
                      ),
                      DECODE (
                         csi_intf_repl_rec.actual_return_date,
                         l_instance_header_rec.actual_return_date, l_miss_date,
                         NULL, DECODE (
                                  l_instance_header_rec.actual_return_date,
                                  NULL, l_miss_date,
                                  NULL
                               ),
                         csi_intf_repl_rec.actual_return_date
                      ),
                      DECODE (
                         csi_intf_repl_rec.instance_context,
                         l_instance_header_rec.CONTEXT, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.CONTEXT,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.instance_context
                      ),
                      DECODE (
                         csi_intf_repl_rec.instance_attribute1,
                         l_instance_header_rec.attribute1, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.attribute1,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.instance_attribute1
                      ),
                      DECODE (
                         csi_intf_repl_rec.instance_attribute2,
                         l_instance_header_rec.attribute2, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.attribute2,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.instance_attribute2
                      ),
                      DECODE (
                         csi_intf_repl_rec.instance_attribute3,
                         l_instance_header_rec.attribute3, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.attribute3,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.instance_attribute3
                      ),
                      DECODE (
                         csi_intf_repl_rec.instance_attribute4,
                         l_instance_header_rec.attribute4, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.attribute4,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.instance_attribute4
                      ),
                      DECODE (
                         csi_intf_repl_rec.instance_attribute5,
                         l_instance_header_rec.attribute5, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.attribute5,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.instance_attribute5
                      ),
                      DECODE (
                         csi_intf_repl_rec.instance_attribute6,
                         l_instance_header_rec.attribute6, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.attribute6,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.instance_attribute6
                      ),
                      DECODE (
                         csi_intf_repl_rec.instance_attribute7,
                         l_instance_header_rec.attribute7, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.attribute7,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.instance_attribute7
                      ),
                      DECODE (
                         csi_intf_repl_rec.instance_attribute8,
                         l_instance_header_rec.attribute8, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.attribute8,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.instance_attribute8
                      ),
                      DECODE (
                         csi_intf_repl_rec.instance_attribute9,
                         l_instance_header_rec.attribute9, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.attribute9,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.instance_attribute9
                      ),
                      DECODE (
                         csi_intf_repl_rec.instance_attribute10,
                         l_instance_header_rec.attribute10, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.attribute10,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.instance_attribute10
                      ),
                      DECODE (
                         csi_intf_repl_rec.instance_attribute11,
                         l_instance_header_rec.attribute11, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.attribute11,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.instance_attribute11
                      ),
                      DECODE (
                         csi_intf_repl_rec.instance_attribute12,
                         l_instance_header_rec.attribute12, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.attribute12,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.instance_attribute12
                      ),
                      DECODE (
                         csi_intf_repl_rec.instance_attribute13,
                         l_instance_header_rec.attribute13, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.attribute13,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.instance_attribute13
                      ),
                      DECODE (
                         csi_intf_repl_rec.instance_attribute14,
                         l_instance_header_rec.attribute14, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.attribute14,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.instance_attribute14
                      ),
                      DECODE (
                         csi_intf_repl_rec.instance_attribute15,
                         l_instance_header_rec.attribute15, l_miss_char,
                         NULL, DECODE (
                                  l_instance_header_rec.attribute15,
                                  NULL, l_miss_char,
                                  NULL
                               ),
                         csi_intf_repl_rec.instance_attribute15
                      ),
                      l_instance_header_rec.object_version_number
                 INTO x_instance_tbl(inst_index).location_id,
                      x_instance_tbl(inst_index).inventory_revision,
                      x_instance_tbl(inst_index).lot_number,
                      x_instance_tbl(inst_index).quantity,
                      x_instance_tbl(inst_index).unit_of_measure,
                      x_instance_tbl(inst_index).accounting_class_code,
                      x_instance_tbl(inst_index).active_end_date,
                      x_instance_tbl(inst_index).location_type_code,
                      x_instance_tbl(inst_index).inv_subinventory_name,
                      x_instance_tbl(inst_index).inv_locator_id,
                      x_instance_tbl(inst_index).pa_project_id,
                      x_instance_tbl(inst_index).pa_project_task_id,
                      x_instance_tbl(inst_index).in_transit_order_line_id,
                      x_instance_tbl(inst_index).wip_job_id,
                      x_instance_tbl(inst_index).po_order_line_id,
                      x_instance_tbl(inst_index).last_oe_order_line_id,
                      x_instance_tbl(inst_index).last_oe_rma_line_id,
                      x_instance_tbl(inst_index).last_po_po_line_id,
                      x_instance_tbl(inst_index).last_oe_po_number,
                      x_instance_tbl(inst_index).install_date,
                      x_instance_tbl(inst_index).return_by_date,
                      x_instance_tbl(inst_index).actual_return_date,
                      x_instance_tbl(inst_index).CONTEXT,
                      x_instance_tbl(inst_index).attribute1,
                      x_instance_tbl(inst_index).attribute2,
                      x_instance_tbl(inst_index).attribute3,
                      x_instance_tbl(inst_index).attribute4,
                      x_instance_tbl(inst_index).attribute5,
                      x_instance_tbl(inst_index).attribute6,
                      x_instance_tbl(inst_index).attribute7,
                      x_instance_tbl(inst_index).attribute8,
                      x_instance_tbl(inst_index).attribute9,
                      x_instance_tbl(inst_index).attribute10,
                      x_instance_tbl(inst_index).attribute11,
                      x_instance_tbl(inst_index).attribute12,
                      x_instance_tbl(inst_index).attribute13,
                      x_instance_tbl(inst_index).attribute14,
                      x_instance_tbl(inst_index).attribute15,
                      x_instance_tbl(inst_index).object_version_number
                 FROM DUAL;
            END IF;


--dbms_output.put_line('after instance accounting class code:'||x_instance_tbl(inst_index).accounting_class_code);
--dbms_output.put_line('after instance next pricing attributes');
-- cases handled
-- current pricing attributes NONE - new NONE - no changes
-- current pricing attributes NONE - new ONE  - to create
-- current pricing attributes ONE - new ONE - NO changes
-- current pricing attributes ONE - new ONE - changed attributes
-- current pricing attributes more than ONE - new more than ONE - changed attributes
-- current pricing attributes more than ONE - new more than ONE - no changes
            IF x_pricing_attribs_tbl.COUNT >= 1
            THEN
               FOR i IN
                   x_pricing_attribs_tbl.FIRST .. x_pricing_attribs_tbl.LAST
               LOOP
                  IF      x_pricing_attribs_tbl.EXISTS (i)
                      AND x_pricing_attribs_tbl (i).active_end_date IS NOT NULL
                  THEN
                     x_pricing_attribs_tbl.DELETE (i);
                  END IF;
               END LOOP;
            END IF;


--dbms_output.put_line('Pricing Zero :'||x_pricing_Attribs_tbl.COUNT);

            IF (x_pricing_attribs_tbl.COUNT >= 1)
            THEN
               FOR i IN
                   x_pricing_attribs_tbl.FIRST .. x_pricing_attribs_tbl.LAST
               LOOP
                  IF      x_pricing_attribs_tbl.EXISTS (i)
                      AND csi_intf_repl_rec.pricing_attribute_id IS NOT NULL
                      AND x_pricing_attribs_tbl (i).pricing_attribute_id =
                                       csi_intf_repl_rec.pricing_attribute_id
                  THEN

--dbms_output.put_line('pricing attributes two');
                     IF NOT (    NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute1,
                                    l_miss_char
                                 ) = NVL (
                                        csi_intf_repl_rec.pricing_attribute1,
                                        l_miss_char
                                     )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute2,
                                    l_miss_char
                                 ) = NVL (
                                        csi_intf_repl_rec.pricing_attribute2,
                                        l_miss_char
                                     )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute3,
                                    l_miss_char
                                 ) = NVL (
                                        csi_intf_repl_rec.pricing_attribute3,
                                        l_miss_char
                                     )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute4,
                                    l_miss_char
                                 ) = NVL (
                                        csi_intf_repl_rec.pricing_attribute4,
                                        l_miss_char
                                     )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute5,
                                    l_miss_char
                                 ) = NVL (
                                        csi_intf_repl_rec.pricing_attribute5,
                                        l_miss_char
                                     )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute6,
                                    l_miss_char
                                 ) = NVL (
                                        csi_intf_repl_rec.pricing_attribute6,
                                        l_miss_char
                                     )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute7,
                                    l_miss_char
                                 ) = NVL (
                                        csi_intf_repl_rec.pricing_attribute7,
                                        l_miss_char
                                     )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute8,
                                    l_miss_char
                                 ) = NVL (
                                        csi_intf_repl_rec.pricing_attribute8,
                                        l_miss_char
                                     )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute9,
                                    l_miss_char
                                 ) = NVL (
                                        csi_intf_repl_rec.pricing_attribute9,
                                        l_miss_char
                                     )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute10,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute10,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute11,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute11,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute12,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute12,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute13,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute13,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute14,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute14,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute15,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute15,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute16,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute16,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute17,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute17,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute18,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute18,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute19,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute19,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute20,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute20,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute21,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute21,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute22,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute22,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute23,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute23,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute24,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute24,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute25,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute25,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute26,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute26,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute27,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute27,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute28,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute28,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute29,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute29,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute30,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute30,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute31,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute31,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute32,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute32,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute33,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute33,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute34,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute34,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute35,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute35,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute36,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute36,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute37,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute37,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute38,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute38,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute39,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute39,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute40,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute40,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute41,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute41,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute42,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute42,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute43,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute43,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute44,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute44,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute45,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute45,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute46,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute46,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute47,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute47,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute48,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute48,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute49,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute49,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute50,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute50,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute51,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute51,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute52,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute52,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute53,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute53,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute54,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute54,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute55,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute55,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute56,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute56,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute57,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute57,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute58,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute58,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute59,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute59,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute60,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute60,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute61,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute61,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute62,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute62,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute63,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute63,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute64,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute64,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute65,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute65,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute66,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute66,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute67,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute67,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute68,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute68,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute69,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute69,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute70,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute70,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute71,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute71,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute72,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute72,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute73,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute73,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute74,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute74,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute75,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute75,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute76,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute76,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute77,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute77,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute78,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute78,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute79,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute79,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute80,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute80,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute81,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute81,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute82,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute82,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute83,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute83,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute84,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute84,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute85,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute85,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute86,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute86,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute87,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute87,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute88,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute88,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute89,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute89,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute90,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute90,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute91,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute91,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute92,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute92,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute93,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute93,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute94,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute94,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute95,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute95,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute96,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute96,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute97,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute97,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute98,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute98,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute99,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute99,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).pricing_attribute100,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_attribute100,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).CONTEXT,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_flex_context,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).attribute1,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_flex_attribute1,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).attribute2,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_flex_attribute2,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).attribute3,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_flex_attribute3,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).attribute4,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_flex_attribute4,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).attribute5,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_flex_attribute5,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).attribute6,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_flex_attribute6,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).attribute7,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_flex_attribute7,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).attribute8,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_flex_attribute8,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).attribute9,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_flex_attribute9,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).attribute10,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_flex_attribute10,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).attribute11,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_flex_attribute11,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).attribute12,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_flex_attribute12,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).attribute13,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_flex_attribute13,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).attribute14,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_flex_attribute14,
                                       l_miss_char
                                    )
                             AND NVL (
                                    x_pricing_attribs_tbl (i).attribute15,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       csi_intf_repl_rec.pricing_flex_attribute15,
                                       l_miss_char
                                    )
                            )
                     THEN
                        l_price_index :=   x_price_tbl.COUNT
                                         + 1;

--dbms_output.put_line('pricing attributes three');
                        x_price_tbl (l_price_index).pricing_attribute_id :=
                                       csi_intf_repl_rec.pricing_attribute_id;
                        x_price_tbl (l_price_index).instance_id :=
                                                csi_intf_repl_rec.instance_id;

                        SELECT DECODE (
                                  csi_intf_repl_rec.pricing_attribute1,
                                  x_pricing_attribs_tbl (i).pricing_attribute1, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute1
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute2,
                                  x_pricing_attribs_tbl (i).pricing_attribute2, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute2
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute3,
                                  x_pricing_attribs_tbl (i).pricing_attribute3, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute3
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute4,
                                  x_pricing_attribs_tbl (i).pricing_attribute4, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute4
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute5,
                                  x_pricing_attribs_tbl (i).pricing_attribute5, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute5
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute6,
                                  x_pricing_attribs_tbl (i).pricing_attribute6, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute6
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute7,
                                  x_pricing_attribs_tbl (i).pricing_attribute7, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute7
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute8,
                                  x_pricing_attribs_tbl (i).pricing_attribute8, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute8
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute9,
                                  x_pricing_attribs_tbl (i).pricing_attribute9, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute9
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute10,
                                  x_pricing_attribs_tbl (i).pricing_attribute10, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute10
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute11,
                                  x_pricing_attribs_tbl (i).pricing_attribute11, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute11
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute12,
                                  x_pricing_attribs_tbl (i).pricing_attribute12, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute12
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute13,
                                  x_pricing_attribs_tbl (i).pricing_attribute13, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute13
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute14,
                                  x_pricing_attribs_tbl (i).pricing_attribute14, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute14
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute15,
                                  x_pricing_attribs_tbl (i).pricing_attribute15, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute15
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute16,
                                  x_pricing_attribs_tbl (i).pricing_attribute16, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute16
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute17,
                                  x_pricing_attribs_tbl (i).pricing_attribute17, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute17
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute18,
                                  x_pricing_attribs_tbl (i).pricing_attribute18, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute18
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute19,
                                  x_pricing_attribs_tbl (i).pricing_attribute19, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute19
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute20,
                                  x_pricing_attribs_tbl (i).pricing_attribute20, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute20
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute21,
                                  x_pricing_attribs_tbl (i).pricing_attribute21, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute21
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute22,
                                  x_pricing_attribs_tbl (i).pricing_attribute22, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute22
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute23,
                                  x_pricing_attribs_tbl (i).pricing_attribute23, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute23
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute24,
                                  x_pricing_attribs_tbl (i).pricing_attribute24, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute24
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute25,
                                  x_pricing_attribs_tbl (i).pricing_attribute25, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute25
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute26,
                                  x_pricing_attribs_tbl (i).pricing_attribute26, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute26
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute27,
                                  x_pricing_attribs_tbl (i).pricing_attribute27, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute27
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute28,
                                  x_pricing_attribs_tbl (i).pricing_attribute28, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute28
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute29,
                                  x_pricing_attribs_tbl (i).pricing_attribute29, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute29
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute30,
                                  x_pricing_attribs_tbl (i).pricing_attribute30, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute30
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute31,
                                  x_pricing_attribs_tbl (i).pricing_attribute31, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute31
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute32,
                                  x_pricing_attribs_tbl (i).pricing_attribute32, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute32
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute33,
                                  x_pricing_attribs_tbl (i).pricing_attribute33, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute33
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute34,
                                  x_pricing_attribs_tbl (i).pricing_attribute34, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute34
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute35,
                                  x_pricing_attribs_tbl (i).pricing_attribute35, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute35
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute36,
                                  x_pricing_attribs_tbl (i).pricing_attribute36, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute36
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute37,
                                  x_pricing_attribs_tbl (i).pricing_attribute37, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute37
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute38,
                                  x_pricing_attribs_tbl (i).pricing_attribute38, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute38
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute39,
                                  x_pricing_attribs_tbl (i).pricing_attribute39, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute39
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute40,
                                  x_pricing_attribs_tbl (i).pricing_attribute40, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute40
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute41,
                                  x_pricing_attribs_tbl (i).pricing_attribute41, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute41
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute42,
                                  x_pricing_attribs_tbl (i).pricing_attribute42, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute42
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute43,
                                  x_pricing_attribs_tbl (i).pricing_attribute43, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute43
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute44,
                                  x_pricing_attribs_tbl (i).pricing_attribute44, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute44
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute45,
                                  x_pricing_attribs_tbl (i).pricing_attribute45, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute45
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute46,
                                  x_pricing_attribs_tbl (i).pricing_attribute46, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute46
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute47,
                                  x_pricing_attribs_tbl (i).pricing_attribute47, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute47
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute48,
                                  x_pricing_attribs_tbl (i).pricing_attribute48, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute48
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute49,
                                  x_pricing_attribs_tbl (i).pricing_attribute49, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute49
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute50,
                                  x_pricing_attribs_tbl (i).pricing_attribute50, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute50
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute51,
                                  x_pricing_attribs_tbl (i).pricing_attribute51, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute51
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute52,
                                  x_pricing_attribs_tbl (i).pricing_attribute52, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute52
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute53,
                                  x_pricing_attribs_tbl (i).pricing_attribute53, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute53
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute54,
                                  x_pricing_attribs_tbl (i).pricing_attribute54, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute54
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute55,
                                  x_pricing_attribs_tbl (i).pricing_attribute55, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute55
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute56,
                                  x_pricing_attribs_tbl (i).pricing_attribute56, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute55
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute57,
                                  x_pricing_attribs_tbl (i).pricing_attribute57, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute55
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute58,
                                  x_pricing_attribs_tbl (i).pricing_attribute58, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute58
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute59,
                                  x_pricing_attribs_tbl (i).pricing_attribute59, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute59
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute60,
                                  x_pricing_attribs_tbl (i).pricing_attribute60, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute60
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute61,
                                  x_pricing_attribs_tbl (i).pricing_attribute61, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute61
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute62,
                                  x_pricing_attribs_tbl (i).pricing_attribute62, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute62
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute63,
                                  x_pricing_attribs_tbl (i).pricing_attribute63, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute63
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute64,
                                  x_pricing_attribs_tbl (i).pricing_attribute64, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute64
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute65,
                                  x_pricing_attribs_tbl (i).pricing_attribute65, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute65
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute66,
                                  x_pricing_attribs_tbl (i).pricing_attribute66, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute66
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute67,
                                  x_pricing_attribs_tbl (i).pricing_attribute67, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute67
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute68,
                                  x_pricing_attribs_tbl (i).pricing_attribute68, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute68
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute69,
                                  x_pricing_attribs_tbl (i).pricing_attribute69, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute69
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute70,
                                  x_pricing_attribs_tbl (i).pricing_attribute70, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute70
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute71,
                                  x_pricing_attribs_tbl (i).pricing_attribute71, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute71
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute72,
                                  x_pricing_attribs_tbl (i).pricing_attribute72, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute72
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute73,
                                  x_pricing_attribs_tbl (i).pricing_attribute73, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute73
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute74,
                                  x_pricing_attribs_tbl (i).pricing_attribute74, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute74
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute75,
                                  x_pricing_attribs_tbl (i).pricing_attribute75, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute75
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute76,
                                  x_pricing_attribs_tbl (i).pricing_attribute76, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute76
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute77,
                                  x_pricing_attribs_tbl (i).pricing_attribute77, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute77
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute78,
                                  x_pricing_attribs_tbl (i).pricing_attribute78, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute78
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute79,
                                  x_pricing_attribs_tbl (i).pricing_attribute79, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute79
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute80,
                                  x_pricing_attribs_tbl (i).pricing_attribute80, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute80
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute81,
                                  x_pricing_attribs_tbl (i).pricing_attribute81, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute81
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute82,
                                  x_pricing_attribs_tbl (i).pricing_attribute82, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute82
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute83,
                                  x_pricing_attribs_tbl (i).pricing_attribute83, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute83
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute84,
                                  x_pricing_attribs_tbl (i).pricing_attribute84, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute84
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute85,
                                  x_pricing_attribs_tbl (i).pricing_attribute85, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute85
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute86,
                                  x_pricing_attribs_tbl (i).pricing_attribute86, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute86
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute87,
                                  x_pricing_attribs_tbl (i).pricing_attribute87, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute87
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute88,
                                  x_pricing_attribs_tbl (i).pricing_attribute88, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute88
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute89,
                                  x_pricing_attribs_tbl (i).pricing_attribute89, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute89
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute90,
                                  x_pricing_attribs_tbl (i).pricing_attribute90, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute90
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute91,
                                  x_pricing_attribs_tbl (i).pricing_attribute91, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute91
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute92,
                                  x_pricing_attribs_tbl (i).pricing_attribute92, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute92
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute93,
                                  x_pricing_attribs_tbl (i).pricing_attribute93, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute93
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute94,
                                  x_pricing_attribs_tbl (i).pricing_attribute94, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute94
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute95,
                                  x_pricing_attribs_tbl (i).pricing_attribute95, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute95
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute96,
                                  x_pricing_attribs_tbl (i).pricing_attribute96, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute96
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute97,
                                  x_pricing_attribs_tbl (i).pricing_attribute97, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute97
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute98,
                                  x_pricing_attribs_tbl (i).pricing_attribute98, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute98
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute99,
                                  x_pricing_attribs_tbl (i).pricing_attribute99, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute99
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_attribute100,
                                  x_pricing_attribs_tbl (i).pricing_attribute100, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).pricing_attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_attribute100
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_flex_context,
                                  x_pricing_attribs_tbl (i).CONTEXT, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).CONTEXT,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_flex_context
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_flex_attribute1,
                                  x_pricing_attribs_tbl (i).attribute1, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).attribute1,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_flex_attribute1
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_flex_attribute2,
                                  x_pricing_attribs_tbl (i).attribute2, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).attribute2,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_flex_attribute2
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_flex_attribute3,
                                  x_pricing_attribs_tbl (i).attribute3, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).attribute3,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_flex_attribute3
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_flex_attribute4,
                                  x_pricing_attribs_tbl (i).attribute4, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).attribute4,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_flex_attribute4
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_flex_attribute5,
                                  x_pricing_attribs_tbl (i).attribute5, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).attribute5,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_flex_attribute5
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_flex_attribute6,
                                  x_pricing_attribs_tbl (i).attribute6, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).attribute6,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_flex_attribute6
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_flex_attribute7,
                                  x_pricing_attribs_tbl (i).attribute7, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).attribute7,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_flex_attribute7
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_flex_attribute8,
                                  x_pricing_attribs_tbl (i).attribute8, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).attribute8,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_flex_attribute8
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_flex_attribute9,
                                  x_pricing_attribs_tbl (i).attribute9, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).attribute9,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_flex_attribute9
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_flex_attribute10,
                                  x_pricing_attribs_tbl (i).attribute10, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).attribute10,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_flex_attribute10
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_flex_attribute11,
                                  x_pricing_attribs_tbl (i).attribute11, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).attribute11,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_flex_attribute11
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_flex_attribute12,
                                  x_pricing_attribs_tbl (i).attribute12, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).attribute12,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_flex_attribute12
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_flex_attribute13,
                                  x_pricing_attribs_tbl (i).attribute13, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).attribute13,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_flex_attribute13
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_flex_attribute14,
                                  x_pricing_attribs_tbl (i).attribute14, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).attribute14,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_flex_attribute14
                               ),
                               DECODE (
                                  csi_intf_repl_rec.pricing_flex_attribute15,
                                  x_pricing_attribs_tbl (i).attribute15, l_miss_char,
                                  NULL, DECODE (
                                           x_pricing_attribs_tbl (i).attribute15,
                                           NULL, l_miss_char,
                                           NULL
                                        ),
                                  csi_intf_repl_rec.pricing_flex_attribute15
                               ),
                               x_pricing_attribs_tbl (i).object_version_number
                          INTO x_price_tbl (l_price_index).pricing_attribute1,
                               x_price_tbl (l_price_index).pricing_attribute2,
                               x_price_tbl (l_price_index).pricing_attribute3,
                               x_price_tbl (l_price_index).pricing_attribute4,
                               x_price_tbl (l_price_index).pricing_attribute5,
                               x_price_tbl (l_price_index).pricing_attribute6,
                               x_price_tbl (l_price_index).pricing_attribute7,
                               x_price_tbl (l_price_index).pricing_attribute8,
                               x_price_tbl (l_price_index).pricing_attribute9,
                               x_price_tbl (l_price_index).pricing_attribute10,
                               x_price_tbl (l_price_index).pricing_attribute11,
                               x_price_tbl (l_price_index).pricing_attribute12,
                               x_price_tbl (l_price_index).pricing_attribute13,
                               x_price_tbl (l_price_index).pricing_attribute14,
                               x_price_tbl (l_price_index).pricing_attribute15,
                               x_price_tbl (l_price_index).pricing_attribute16,
                               x_price_tbl (l_price_index).pricing_attribute17,
                               x_price_tbl (l_price_index).pricing_attribute18,
                               x_price_tbl (l_price_index).pricing_attribute19,
                               x_price_tbl (l_price_index).pricing_attribute20,
                               x_price_tbl (l_price_index).pricing_attribute21,
                               x_price_tbl (l_price_index).pricing_attribute22,
                               x_price_tbl (l_price_index).pricing_attribute23,
                               x_price_tbl (l_price_index).pricing_attribute24,
                               x_price_tbl (l_price_index).pricing_attribute25,
                               x_price_tbl (l_price_index).pricing_attribute26,
                               x_price_tbl (l_price_index).pricing_attribute27,
                               x_price_tbl (l_price_index).pricing_attribute28,
                               x_price_tbl (l_price_index).pricing_attribute29,
                               x_price_tbl (l_price_index).pricing_attribute30,
                               x_price_tbl (l_price_index).pricing_attribute31,
                               x_price_tbl (l_price_index).pricing_attribute32,
                               x_price_tbl (l_price_index).pricing_attribute33,
                               x_price_tbl (l_price_index).pricing_attribute34,
                               x_price_tbl (l_price_index).pricing_attribute35,
                               x_price_tbl (l_price_index).pricing_attribute36,
                               x_price_tbl (l_price_index).pricing_attribute37,
                               x_price_tbl (l_price_index).pricing_attribute38,
                               x_price_tbl (l_price_index).pricing_attribute39,
                               x_price_tbl (l_price_index).pricing_attribute40,
                               x_price_tbl (l_price_index).pricing_attribute41,
                               x_price_tbl (l_price_index).pricing_attribute42,
                               x_price_tbl (l_price_index).pricing_attribute43,
                               x_price_tbl (l_price_index).pricing_attribute44,
                               x_price_tbl (l_price_index).pricing_attribute45,
                               x_price_tbl (l_price_index).pricing_attribute46,
                               x_price_tbl (l_price_index).pricing_attribute47,
                               x_price_tbl (l_price_index).pricing_attribute48,
                               x_price_tbl (l_price_index).pricing_attribute49,
                               x_price_tbl (l_price_index).pricing_attribute50,
                               x_price_tbl (l_price_index).pricing_attribute51,
                               x_price_tbl (l_price_index).pricing_attribute52,
                               x_price_tbl (l_price_index).pricing_attribute53,
                               x_price_tbl (l_price_index).pricing_attribute54,
                               x_price_tbl (l_price_index).pricing_attribute55,
                               x_price_tbl (l_price_index).pricing_attribute56,
                               x_price_tbl (l_price_index).pricing_attribute57,
                               x_price_tbl (l_price_index).pricing_attribute58,
                               x_price_tbl (l_price_index).pricing_attribute59,
                               x_price_tbl (l_price_index).pricing_attribute60,
                               x_price_tbl (l_price_index).pricing_attribute61,
                               x_price_tbl (l_price_index).pricing_attribute62,
                               x_price_tbl (l_price_index).pricing_attribute63,
                               x_price_tbl (l_price_index).pricing_attribute64,
                               x_price_tbl (l_price_index).pricing_attribute65,
                               x_price_tbl (l_price_index).pricing_attribute66,
                               x_price_tbl (l_price_index).pricing_attribute67,
                               x_price_tbl (l_price_index).pricing_attribute68,
                               x_price_tbl (l_price_index).pricing_attribute69,
                               x_price_tbl (l_price_index).pricing_attribute70,
                               x_price_tbl (l_price_index).pricing_attribute71,
                               x_price_tbl (l_price_index).pricing_attribute72,
                               x_price_tbl (l_price_index).pricing_attribute73,
                               x_price_tbl (l_price_index).pricing_attribute74,
                               x_price_tbl (l_price_index).pricing_attribute75,
                               x_price_tbl (l_price_index).pricing_attribute76,
                               x_price_tbl (l_price_index).pricing_attribute77,
                               x_price_tbl (l_price_index).pricing_attribute78,
                               x_price_tbl (l_price_index).pricing_attribute79,
                               x_price_tbl (l_price_index).pricing_attribute80,
                               x_price_tbl (l_price_index).pricing_attribute81,
                               x_price_tbl (l_price_index).pricing_attribute82,
                               x_price_tbl (l_price_index).pricing_attribute83,
                               x_price_tbl (l_price_index).pricing_attribute84,
                               x_price_tbl (l_price_index).pricing_attribute85,
                               x_price_tbl (l_price_index).pricing_attribute86,
                               x_price_tbl (l_price_index).pricing_attribute87,
                               x_price_tbl (l_price_index).pricing_attribute88,
                               x_price_tbl (l_price_index).pricing_attribute89,
                               x_price_tbl (l_price_index).pricing_attribute90,
                               x_price_tbl (l_price_index).pricing_attribute91,
                               x_price_tbl (l_price_index).pricing_attribute92,
                               x_price_tbl (l_price_index).pricing_attribute93,
                               x_price_tbl (l_price_index).pricing_attribute94,
                               x_price_tbl (l_price_index).pricing_attribute95,
                               x_price_tbl (l_price_index).pricing_attribute96,
                               x_price_tbl (l_price_index).pricing_attribute97,
                               x_price_tbl (l_price_index).pricing_attribute98,
                               x_price_tbl (l_price_index).pricing_attribute99,
                               x_price_tbl (l_price_index).pricing_attribute100,
                               x_price_tbl (l_price_index).CONTEXT,
                               x_price_tbl (l_price_index).attribute1,
                               x_price_tbl (l_price_index).attribute2,
                               x_price_tbl (l_price_index).attribute3,
                               x_price_tbl (l_price_index).attribute4,
                               x_price_tbl (l_price_index).attribute5,
                               x_price_tbl (l_price_index).attribute6,
                               x_price_tbl (l_price_index).attribute7,
                               x_price_tbl (l_price_index).attribute8,
                               x_price_tbl (l_price_index).attribute9,
                               x_price_tbl (l_price_index).attribute10,
                               x_price_tbl (l_price_index).attribute11,
                               x_price_tbl (l_price_index).attribute12,
                               x_price_tbl (l_price_index).attribute13,
                               x_price_tbl (l_price_index).attribute14,
                               x_price_tbl (l_price_index).attribute15,
                               x_price_tbl (l_price_index).object_version_number
                          FROM DUAL;

                        x_pricing_attribs_tbl.DELETE (i);
                     ELSE
                        x_pricing_attribs_tbl.DELETE (i);
                     END IF;
                  END IF;
               END LOOP;
            END IF;

            IF x_pricing_attribs_tbl.COUNT >= 1
            THEN
               FOR i IN
                   x_pricing_attribs_tbl.FIRST .. x_pricing_attribs_tbl.LAST
               LOOP
                  IF      x_pricing_attribs_tbl.EXISTS (i)
                      AND x_pricing_attribs_tbl (i).pricing_attribute_id IS NOT NULL
                  THEN
                     --Pricing attributes are different
                     --Expire the existing one
                     l_price_index :=   x_price_tbl.COUNT
                                      + 1;
                     x_price_tbl (l_price_index).pricing_attribute_id :=
                           x_pricing_attribs_tbl (
                              x_pricing_attribs_tbl.FIRST
                           ).pricing_attribute_id;
                     x_price_tbl (l_price_index).object_version_number :=
                           x_pricing_attribs_tbl (
                              x_pricing_attribs_tbl.FIRST
                           ).object_version_number;
                     x_price_tbl (l_price_index).active_end_date :=
                                                                   l_end_date;
                     x_pricing_attribs_tbl.DELETE (i);
                  END IF;
               END LOOP;
            END IF;

            IF      csi_intf_repl_rec.pricing_attribute_id IS NULL
                AND csi_intf_repl_rec.pricing_context IS NOT NULL
            THEN
               l_price_index :=   x_price_tbl.COUNT
                                + 1;
               x_price_tbl (l_price_index).instance_id :=
                                                csi_intf_repl_rec.instance_id;
               x_price_tbl (l_price_index).active_start_date :=
                      NVL (csi_intf_repl_rec.pricing_att_start_date, SYSDATE);
               x_price_tbl (l_price_index).pricing_context :=
                                            csi_intf_repl_rec.pricing_context;
               --dbms_output.put_line('FOUR two:'||x_price_tbl(l_price_index).pricing_context);
               x_price_tbl (l_price_index).pricing_attribute1 :=
                                         csi_intf_repl_rec.pricing_attribute1;
               x_price_tbl (l_price_index).pricing_attribute2 :=
                                         csi_intf_repl_rec.pricing_attribute2;
               x_price_tbl (l_price_index).pricing_attribute3 :=
                                         csi_intf_repl_rec.pricing_attribute3;
               x_price_tbl (l_price_index).pricing_attribute4 :=
                                         csi_intf_repl_rec.pricing_attribute4;
               x_price_tbl (l_price_index).pricing_attribute5 :=
                                         csi_intf_repl_rec.pricing_attribute5;
               x_price_tbl (l_price_index).pricing_attribute6 :=
                                         csi_intf_repl_rec.pricing_attribute6;
               x_price_tbl (l_price_index).pricing_attribute7 :=
                                         csi_intf_repl_rec.pricing_attribute7;
               x_price_tbl (l_price_index).pricing_attribute8 :=
                                         csi_intf_repl_rec.pricing_attribute8;
               x_price_tbl (l_price_index).pricing_attribute9 :=
                                         csi_intf_repl_rec.pricing_attribute9;
               x_price_tbl (l_price_index).pricing_attribute10 :=
                                        csi_intf_repl_rec.pricing_attribute10;
               x_price_tbl (l_price_index).pricing_attribute11 :=
                                        csi_intf_repl_rec.pricing_attribute11;
               x_price_tbl (l_price_index).pricing_attribute12 :=
                                        csi_intf_repl_rec.pricing_attribute12;
               x_price_tbl (l_price_index).pricing_attribute13 :=
                                        csi_intf_repl_rec.pricing_attribute13;
               x_price_tbl (l_price_index).pricing_attribute14 :=
                                        csi_intf_repl_rec.pricing_attribute14;
               x_price_tbl (l_price_index).pricing_attribute15 :=
                                        csi_intf_repl_rec.pricing_attribute15;
               x_price_tbl (l_price_index).pricing_attribute16 :=
                                        csi_intf_repl_rec.pricing_attribute16;
               x_price_tbl (l_price_index).pricing_attribute17 :=
                                        csi_intf_repl_rec.pricing_attribute17;
               x_price_tbl (l_price_index).pricing_attribute18 :=
                                        csi_intf_repl_rec.pricing_attribute18;
               x_price_tbl (l_price_index).pricing_attribute19 :=
                                        csi_intf_repl_rec.pricing_attribute19;
               x_price_tbl (l_price_index).pricing_attribute20 :=
                                        csi_intf_repl_rec.pricing_attribute20;
               x_price_tbl (l_price_index).pricing_attribute21 :=
                                        csi_intf_repl_rec.pricing_attribute21;
               x_price_tbl (l_price_index).pricing_attribute22 :=
                                        csi_intf_repl_rec.pricing_attribute22;
               x_price_tbl (l_price_index).pricing_attribute23 :=
                                        csi_intf_repl_rec.pricing_attribute23;
               x_price_tbl (l_price_index).pricing_attribute24 :=
                                        csi_intf_repl_rec.pricing_attribute24;
               x_price_tbl (l_price_index).pricing_attribute25 :=
                                        csi_intf_repl_rec.pricing_attribute25;
               x_price_tbl (l_price_index).pricing_attribute26 :=
                                        csi_intf_repl_rec.pricing_attribute26;
               x_price_tbl (l_price_index).pricing_attribute27 :=
                                        csi_intf_repl_rec.pricing_attribute27;
               x_price_tbl (l_price_index).pricing_attribute28 :=
                                        csi_intf_repl_rec.pricing_attribute28;
               x_price_tbl (l_price_index).pricing_attribute29 :=
                                        csi_intf_repl_rec.pricing_attribute29;
               x_price_tbl (l_price_index).pricing_attribute30 :=
                                        csi_intf_repl_rec.pricing_attribute30;
               x_price_tbl (l_price_index).pricing_attribute31 :=
                                        csi_intf_repl_rec.pricing_attribute31;
               x_price_tbl (l_price_index).pricing_attribute32 :=
                                        csi_intf_repl_rec.pricing_attribute32;
               x_price_tbl (l_price_index).pricing_attribute33 :=
                                        csi_intf_repl_rec.pricing_attribute33;
               x_price_tbl (l_price_index).pricing_attribute34 :=
                                        csi_intf_repl_rec.pricing_attribute34;
               x_price_tbl (l_price_index).pricing_attribute35 :=
                                        csi_intf_repl_rec.pricing_attribute35;
               x_price_tbl (l_price_index).pricing_attribute36 :=
                                        csi_intf_repl_rec.pricing_attribute36;
               x_price_tbl (l_price_index).pricing_attribute37 :=
                                        csi_intf_repl_rec.pricing_attribute37;
               x_price_tbl (l_price_index).pricing_attribute38 :=
                                        csi_intf_repl_rec.pricing_attribute38;
               x_price_tbl (l_price_index).pricing_attribute39 :=
                                        csi_intf_repl_rec.pricing_attribute39;
               x_price_tbl (l_price_index).pricing_attribute40 :=
                                        csi_intf_repl_rec.pricing_attribute40;
               x_price_tbl (l_price_index).pricing_attribute41 :=
                                        csi_intf_repl_rec.pricing_attribute41;
               x_price_tbl (l_price_index).pricing_attribute42 :=
                                        csi_intf_repl_rec.pricing_attribute42;
               x_price_tbl (l_price_index).pricing_attribute43 :=
                                        csi_intf_repl_rec.pricing_attribute43;
               x_price_tbl (l_price_index).pricing_attribute44 :=
                                        csi_intf_repl_rec.pricing_attribute44;
               x_price_tbl (l_price_index).pricing_attribute45 :=
                                        csi_intf_repl_rec.pricing_attribute45;
               x_price_tbl (l_price_index).pricing_attribute46 :=
                                        csi_intf_repl_rec.pricing_attribute46;
               x_price_tbl (l_price_index).pricing_attribute47 :=
                                        csi_intf_repl_rec.pricing_attribute47;
               x_price_tbl (l_price_index).pricing_attribute48 :=
                                        csi_intf_repl_rec.pricing_attribute48;
               x_price_tbl (l_price_index).pricing_attribute49 :=
                                        csi_intf_repl_rec.pricing_attribute49;
               x_price_tbl (l_price_index).pricing_attribute50 :=
                                        csi_intf_repl_rec.pricing_attribute50;
               x_price_tbl (l_price_index).pricing_attribute51 :=
                                        csi_intf_repl_rec.pricing_attribute51;
               x_price_tbl (l_price_index).pricing_attribute52 :=
                                        csi_intf_repl_rec.pricing_attribute52;
               x_price_tbl (l_price_index).pricing_attribute53 :=
                                        csi_intf_repl_rec.pricing_attribute53;
               x_price_tbl (l_price_index).pricing_attribute54 :=
                                        csi_intf_repl_rec.pricing_attribute54;
               x_price_tbl (l_price_index).pricing_attribute55 :=
                                        csi_intf_repl_rec.pricing_attribute55;
               x_price_tbl (l_price_index).pricing_attribute56 :=
                                        csi_intf_repl_rec.pricing_attribute56;
               x_price_tbl (l_price_index).pricing_attribute57 :=
                                        csi_intf_repl_rec.pricing_attribute57;
               x_price_tbl (l_price_index).pricing_attribute58 :=
                                        csi_intf_repl_rec.pricing_attribute58;
               x_price_tbl (l_price_index).pricing_attribute59 :=
                                        csi_intf_repl_rec.pricing_attribute59;
               x_price_tbl (l_price_index).pricing_attribute60 :=
                                        csi_intf_repl_rec.pricing_attribute60;
               x_price_tbl (l_price_index).pricing_attribute61 :=
                                        csi_intf_repl_rec.pricing_attribute61;
               x_price_tbl (l_price_index).pricing_attribute62 :=
                                        csi_intf_repl_rec.pricing_attribute62;
               x_price_tbl (l_price_index).pricing_attribute63 :=
                                        csi_intf_repl_rec.pricing_attribute63;
               x_price_tbl (l_price_index).pricing_attribute64 :=
                                        csi_intf_repl_rec.pricing_attribute64;
               x_price_tbl (l_price_index).pricing_attribute65 :=
                                        csi_intf_repl_rec.pricing_attribute65;
               x_price_tbl (l_price_index).pricing_attribute66 :=
                                        csi_intf_repl_rec.pricing_attribute66;
               x_price_tbl (l_price_index).pricing_attribute67 :=
                                        csi_intf_repl_rec.pricing_attribute67;
               x_price_tbl (l_price_index).pricing_attribute68 :=
                                        csi_intf_repl_rec.pricing_attribute68;
               x_price_tbl (l_price_index).pricing_attribute69 :=
                                        csi_intf_repl_rec.pricing_attribute69;
               x_price_tbl (l_price_index).pricing_attribute70 :=
                                        csi_intf_repl_rec.pricing_attribute70;
               x_price_tbl (l_price_index).pricing_attribute71 :=
                                        csi_intf_repl_rec.pricing_attribute71;
               x_price_tbl (l_price_index).pricing_attribute72 :=
                                        csi_intf_repl_rec.pricing_attribute72;
               x_price_tbl (l_price_index).pricing_attribute73 :=
                                        csi_intf_repl_rec.pricing_attribute73;
               x_price_tbl (l_price_index).pricing_attribute74 :=
                                        csi_intf_repl_rec.pricing_attribute74;
               x_price_tbl (l_price_index).pricing_attribute75 :=
                                        csi_intf_repl_rec.pricing_attribute75;
               x_price_tbl (l_price_index).pricing_attribute76 :=
                                        csi_intf_repl_rec.pricing_attribute76;
               x_price_tbl (l_price_index).pricing_attribute77 :=
                                        csi_intf_repl_rec.pricing_attribute77;
               x_price_tbl (l_price_index).pricing_attribute78 :=
                                        csi_intf_repl_rec.pricing_attribute78;
               x_price_tbl (l_price_index).pricing_attribute79 :=
                                        csi_intf_repl_rec.pricing_attribute79;
               x_price_tbl (l_price_index).pricing_attribute80 :=
                                        csi_intf_repl_rec.pricing_attribute80;
               x_price_tbl (l_price_index).pricing_attribute81 :=
                                        csi_intf_repl_rec.pricing_attribute81;
               x_price_tbl (l_price_index).pricing_attribute82 :=
                                        csi_intf_repl_rec.pricing_attribute82;
               x_price_tbl (l_price_index).pricing_attribute83 :=
                                        csi_intf_repl_rec.pricing_attribute83;
               x_price_tbl (l_price_index).pricing_attribute84 :=
                                        csi_intf_repl_rec.pricing_attribute84;
               x_price_tbl (l_price_index).pricing_attribute85 :=
                                        csi_intf_repl_rec.pricing_attribute85;
               x_price_tbl (l_price_index).pricing_attribute86 :=
                                        csi_intf_repl_rec.pricing_attribute86;
               x_price_tbl (l_price_index).pricing_attribute87 :=
                                        csi_intf_repl_rec.pricing_attribute87;
               x_price_tbl (l_price_index).pricing_attribute88 :=
                                        csi_intf_repl_rec.pricing_attribute88;
               x_price_tbl (l_price_index).pricing_attribute89 :=
                                        csi_intf_repl_rec.pricing_attribute89;
               x_price_tbl (l_price_index).pricing_attribute90 :=
                                        csi_intf_repl_rec.pricing_attribute90;
               x_price_tbl (l_price_index).pricing_attribute91 :=
                                        csi_intf_repl_rec.pricing_attribute91;
               x_price_tbl (l_price_index).pricing_attribute92 :=
                                        csi_intf_repl_rec.pricing_attribute92;
               x_price_tbl (l_price_index).pricing_attribute93 :=
                                        csi_intf_repl_rec.pricing_attribute93;
               x_price_tbl (l_price_index).pricing_attribute94 :=
                                        csi_intf_repl_rec.pricing_attribute94;
               x_price_tbl (l_price_index).pricing_attribute95 :=
                                        csi_intf_repl_rec.pricing_attribute95;
               x_price_tbl (l_price_index).pricing_attribute96 :=
                                        csi_intf_repl_rec.pricing_attribute96;
               x_price_tbl (l_price_index).pricing_attribute97 :=
                                        csi_intf_repl_rec.pricing_attribute97;
               x_price_tbl (l_price_index).pricing_attribute98 :=
                                        csi_intf_repl_rec.pricing_attribute98;
               x_price_tbl (l_price_index).pricing_attribute99 :=
                                        csi_intf_repl_rec.pricing_attribute99;
               x_price_tbl (l_price_index).pricing_attribute100 :=
                                       csi_intf_repl_rec.pricing_attribute100;
               x_price_tbl (l_price_index).CONTEXT :=
                                       csi_intf_repl_rec.pricing_flex_context;
               x_price_tbl (l_price_index).attribute1 :=
                                    csi_intf_repl_rec.pricing_flex_attribute1;
               x_price_tbl (l_price_index).attribute2 :=
                                    csi_intf_repl_rec.pricing_flex_attribute2;
               x_price_tbl (l_price_index).attribute3 :=
                                    csi_intf_repl_rec.pricing_flex_attribute3;
               x_price_tbl (l_price_index).attribute4 :=
                                    csi_intf_repl_rec.pricing_flex_attribute4;
               x_price_tbl (l_price_index).attribute5 :=
                                    csi_intf_repl_rec.pricing_flex_attribute5;
               x_price_tbl (l_price_index).attribute6 :=
                                    csi_intf_repl_rec.pricing_flex_attribute6;
               x_price_tbl (l_price_index).attribute7 :=
                                    csi_intf_repl_rec.pricing_flex_attribute7;
               x_price_tbl (l_price_index).attribute8 :=
                                    csi_intf_repl_rec.pricing_flex_attribute8;
               x_price_tbl (l_price_index).attribute9 :=
                                    csi_intf_repl_rec.pricing_flex_attribute9;
               x_price_tbl (l_price_index).attribute10 :=
                                   csi_intf_repl_rec.pricing_flex_attribute10;
               x_price_tbl (l_price_index).attribute11 :=
                                   csi_intf_repl_rec.pricing_flex_attribute11;
               x_price_tbl (l_price_index).attribute12 :=
                                   csi_intf_repl_rec.pricing_flex_attribute12;
               x_price_tbl (l_price_index).attribute13 :=
                                   csi_intf_repl_rec.pricing_flex_attribute13;
               x_price_tbl (l_price_index).attribute14 :=
                                   csi_intf_repl_rec.pricing_flex_attribute14;
               x_price_tbl (l_price_index).attribute15 :=
                                   csi_intf_repl_rec.pricing_flex_attribute15;
            END IF;


--dbms_output.put_line('Org asignments zero count:'||x_org_units_header_tbl.COUNT);

            IF x_org_units_header_tbl.COUNT >= 1
            THEN
               FOR i IN
                   x_org_units_header_tbl.FIRST .. x_org_units_header_tbl.LAST
               LOOP
                  IF      x_org_units_header_tbl.EXISTS (i)
                      AND x_org_units_header_tbl (i).active_end_date IS NOT NULL
                  THEN
                     IF NOT csi_intf_repl_rec.ou_end_date IS NULL
                     THEN
                        x_party_header_tbl.DELETE (i);
                     END IF;
                  --dbms_output.put_line('Org Asignments ONE');
                  END IF;
               END LOOP;
            END IF;


--dbms_output.put_line('Org asignments one count:'||x_org_units_header_tbl.COUNT);
            l_org_index :=   x_org_assign_tbl.COUNT
                           + 1;

            IF x_org_units_header_tbl.COUNT >= 1
            THEN
               FOR i IN
                   x_org_units_header_tbl.FIRST .. x_org_units_header_tbl.LAST
               LOOP
                  IF      x_org_units_header_tbl.EXISTS (i)
                      AND csi_intf_repl_rec.instance_ou_id IS NOT NULL
                      AND x_org_units_header_tbl (i).instance_ou_id =
                                             csi_intf_repl_rec.instance_ou_id
                  THEN
                     IF NOT (    NVL (
                                    csi_intf_repl_rec.operating_unit,
                                    l_miss_num
                                 ) =
                                    NVL (
                                       x_org_units_header_tbl (i).operating_unit_id,
                                       l_miss_num
                                    )
                             AND NVL (
                                    csi_intf_repl_rec.ou_relation_type,
                                    l_miss_char
                                 ) =
                                    NVL (
                                       x_org_units_header_tbl (i).relationship_type_code,
                                       l_miss_char
                                    )
                             AND NVL (
                                    csi_intf_repl_rec.ou_end_date,
                                    l_miss_date
                                 ) =
                                    NVL (
                                       x_org_units_header_tbl (i).active_end_date,
                                       l_miss_date
                                    )
                            )
                     THEN
                        x_org_assign_tbl (l_org_index).instance_ou_id :=
                                    x_org_units_header_tbl (1).instance_ou_id;
                        x_org_assign_tbl (l_org_index).object_version_number :=
                             x_org_units_header_tbl (1).object_version_number;

                        SELECT DECODE (
                                  csi_intf_repl_rec.ou_relation_type,
                                  x_org_units_header_tbl (1).relationship_type_code, l_miss_char,
                                  DECODE (
                                     x_org_units_header_tbl (i).relationship_type_code,
                                     NULL, l_miss_char,
                                     NULL
                                  ), csi_intf_repl_rec.ou_relation_type
                               ),
                               DECODE (
                                  csi_intf_repl_rec.operating_unit,
                                  x_org_units_header_tbl (1).operating_unit_id, l_miss_num,
                                  DECODE (
                                     x_org_units_header_tbl (i).operating_unit_id,
                                     NULL, l_miss_num,
                                     NULL
                                  ), csi_intf_repl_rec.operating_unit
                               ),
                               DECODE (
                                  csi_intf_repl_rec.ou_start_date,
                                  x_org_units_header_tbl (1).active_start_date, l_miss_date,
                                  DECODE (
                                     x_org_units_header_tbl (i).active_start_date,
                                     NULL, l_miss_date,
                                     NULL
                                  ), csi_intf_repl_rec.ou_start_date
                               ),
                               DECODE (
                                  csi_intf_repl_rec.ou_end_date,
                                  NULL, NULL,
                                  l_miss_date
                               )
                          INTO x_org_assign_tbl (l_org_index).relationship_type_code,
                               x_org_assign_tbl (l_org_index).operating_unit_id,
                               x_org_assign_tbl (l_org_index).active_start_date,
                               x_org_assign_tbl (l_org_index).active_end_date
                          FROM DUAL;

                        x_org_units_header_tbl.DELETE (i);
                     ELSE
                        x_org_units_header_tbl.DELETE (i);
                     END IF;
                  END IF;
               END LOOP;
            END IF;

            IF x_org_units_header_tbl.COUNT >= 1
            THEN
               --Expire the existing one
               FOR i IN
                   x_org_units_header_tbl.FIRST .. x_org_units_header_tbl.LAST
               LOOP
                  IF x_org_units_header_tbl.EXISTS (i)
                  THEN
                     l_org_index :=   x_org_assign_tbl.COUNT
                                    + 1;
                     x_org_assign_tbl (l_org_index).instance_ou_id :=
                                    x_org_units_header_tbl (1).instance_ou_id;
                     x_org_assign_tbl (l_org_index).object_version_number :=
                             x_org_units_header_tbl (1).object_version_number;
                     x_org_assign_tbl (l_org_index).active_end_date :=
                                                                   l_end_date;
                     x_org_units_header_tbl.DELETE (i);
                  END IF;
               END LOOP;
            END IF;

            IF      csi_intf_repl_rec.instance_ou_id IS NULL
                AND csi_intf_repl_rec.operating_unit IS NOT NULL
            THEN
               l_org_index :=   x_org_assign_tbl.COUNT
                              + 1;
               ---create a new org assignment at the end
               x_org_assign_tbl (l_org_index).instance_id :=
                                                csi_intf_repl_rec.instance_id;
               x_org_assign_tbl (l_org_index).active_start_date :=
                                              csi_intf_repl_rec.ou_start_date;
               x_org_assign_tbl (l_org_index).operating_unit_id :=
                                             csi_intf_repl_rec.operating_unit;
               x_org_assign_tbl (l_org_index).relationship_type_code :=
                                           csi_intf_repl_rec.ou_relation_type;
            END IF;


--dbms_output.put_line('just before parties current count: '||to_char(x_party_header_tbl.COUNT));
            x_party_cache_tbl := x_party_header_tbl;

            IF x_party_header_tbl.COUNT >= 1
            THEN
               FOR i IN x_party_header_tbl.FIRST .. x_party_header_tbl.LAST
               LOOP
                  IF      x_party_header_tbl.EXISTS (i)
                      AND x_party_header_tbl (i).active_end_date IS NOT NULL
                  THEN
                     BEGIN
                        b_end_dated := TRUE;

                        FOR csi_intf_party_acct_rec IN
                            csi_intf_party_acct_cur (
                               csi_intf_repl_rec.inst_interface_id
                            )
                        LOOP
                           IF csi_intf_party_acct_rec.party_end_date IS NULL
                           THEN
                              b_end_dated := FALSE;
                              EXIT;
                           END IF;
                        END LOOP;
                     END;

                     IF b_end_dated
                     THEN
                        x_party_header_tbl.DELETE (i);
                     END IF;
                  --dbms_output.put_line('Parties ONE');
                  END IF;
               END LOOP;
            END IF;

            IF x_party_header_tbl.COUNT >= 1
            THEN
               FOR i IN x_party_header_tbl.FIRST .. x_party_header_tbl.LAST
               LOOP
                  FOR csi_intf_party_acct_rec IN
                      csi_intf_party_acct_cur (
                         csi_intf_repl_rec.inst_interface_id
                      )
                  LOOP
                     IF      x_party_header_tbl.EXISTS (i)
                         AND csi_intf_party_acct_rec.instance_party_id IS NOT NULL
                         AND x_party_header_tbl (i).instance_party_id =
                                    csi_intf_party_acct_rec.instance_party_id
                     THEN

--dbms_output.put_line('Parties four');
                        IF NOT (    NVL (
                                       csi_intf_party_acct_rec.party_id,
                                       l_miss_num
                                    ) = NVL (
                                           x_party_header_tbl (i).party_id,
                                           l_miss_num
                                        )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_source_table,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_header_tbl (i).party_source_table,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_relationship_type_code,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_header_tbl (i).relationship_type_code,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_end_date,
                                       l_miss_date
                                    ) =
                                       NVL (
                                          x_party_header_tbl (i).active_end_date,
                                          l_miss_date
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.contact_flag,
                                       l_miss_char
                                    ) = NVL (
                                           x_party_header_tbl (i).contact_flag,
                                           l_miss_char
                                        )
                                AND NVL (
                                       csi_intf_party_acct_rec.contact_ip_id,
                                       l_miss_num
                                    ) =
                                       NVL (
                                          x_party_header_tbl (i).contact_ip_id,
                                          l_miss_num
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_context,
                                       l_miss_char
                                    ) = NVL (
                                           x_party_header_tbl (i).CONTEXT,
                                           l_miss_char
                                        )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_attribute1,
                                       l_miss_char
                                    ) = NVL (
                                           x_party_header_tbl (i).attribute1,
                                           l_miss_char
                                        )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_attribute2,
                                       l_miss_char
                                    ) = NVL (
                                           x_party_header_tbl (i).attribute2,
                                           l_miss_char
                                        )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_attribute3,
                                       l_miss_char
                                    ) = NVL (
                                           x_party_header_tbl (i).attribute3,
                                           l_miss_char
                                        )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_attribute4,
                                       l_miss_char
                                    ) = NVL (
                                           x_party_header_tbl (i).attribute4,
                                           l_miss_char
                                        )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_attribute5,
                                       l_miss_char
                                    ) = NVL (
                                           x_party_header_tbl (i).attribute5,
                                           l_miss_char
                                        )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_attribute6,
                                       l_miss_char
                                    ) = NVL (
                                           x_party_header_tbl (i).attribute6,
                                           l_miss_char
                                        )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_attribute7,
                                       l_miss_char
                                    ) = NVL (
                                           x_party_header_tbl (i).attribute7,
                                           l_miss_char
                                        )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_attribute8,
                                       l_miss_char
                                    ) = NVL (
                                           x_party_header_tbl (i).attribute8,
                                           l_miss_char
                                        )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_attribute9,
                                       l_miss_char
                                    ) = NVL (
                                           x_party_header_tbl (i).attribute9,
                                           l_miss_char
                                        )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_attribute10,
                                       l_miss_char
                                    ) = NVL (
                                           x_party_header_tbl (i).attribute10,
                                           l_miss_char
                                        )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_attribute11,
                                       l_miss_char
                                    ) = NVL (
                                           x_party_header_tbl (i).attribute11,
                                           l_miss_char
                                        )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_attribute12,
                                       l_miss_char
                                    ) = NVL (
                                           x_party_header_tbl (i).attribute12,
                                           l_miss_char
                                        )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_attribute13,
                                       l_miss_char
                                    ) = NVL (
                                           x_party_header_tbl (i).attribute13,
                                           l_miss_char
                                        )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_attribute14,
                                       l_miss_char
                                    ) = NVL (
                                           x_party_header_tbl (i).attribute14,
                                           l_miss_char
                                        )
                                AND NVL (
                                       csi_intf_party_acct_rec.party_attribute15,
                                       l_miss_char
                                    ) = NVL (
                                           x_party_header_tbl (i).attribute15,
                                           l_miss_char
                                        )
                               )
                        THEN

--dbms_output.put_line('Parties five');
                           l_party_index :=   x_party_tbl.COUNT
                                            + 1;
                           x_party_tbl (l_party_index).instance_party_id :=
                                     x_party_header_tbl (i).instance_party_id;
                           x_party_tbl (l_party_index).instance_id :=
                                           x_party_header_tbl (i).instance_id;
                           x_party_tbl (l_party_index).object_version_number :=
                                 x_party_header_tbl (i).object_version_number;

                           SELECT DECODE (
                                     csi_intf_party_acct_rec.party_source_table,
                                     x_party_header_tbl (i).party_source_table, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).party_source_table,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_source_table
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_id,
                                     x_party_header_tbl (i).party_id, l_miss_num,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).party_id,
                                              NULL, l_miss_num,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_id
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_relationship_type_code,
                                     'OWNER', 'OWNER',
                                     x_party_header_tbl (i).relationship_type_code, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).relationship_type_code,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_relationship_type_code
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_start_date,
                                     x_party_header_tbl (i).active_start_date, l_miss_date,
                                     DECODE (
                                        x_party_header_tbl (i).active_start_date,
                                        NULL, l_miss_date,
                                        NULL
                                     ), csi_intf_party_acct_rec.party_start_date
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_end_date,
                                     x_party_header_tbl (i).active_end_date, l_miss_date,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).active_end_date,
                                              NULL, l_miss_date,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_end_date
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.contact_flag,
                                     x_party_header_tbl (i).contact_flag, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).contact_flag,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.contact_flag
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.contact_ip_id,
                                     x_party_header_tbl (i).contact_ip_id, l_miss_num,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).contact_ip_id,
                                              NULL, l_miss_num,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.contact_ip_id
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_attribute1,
                                     x_party_header_tbl (i).attribute1, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute1,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_attribute1
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_attribute2,
                                     x_party_header_tbl (i).attribute2, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute2,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_attribute2
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_attribute3,
                                     x_party_header_tbl (i).attribute3, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute3,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_attribute3
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_attribute4,
                                     x_party_header_tbl (i).attribute4, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute4,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_attribute4
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_attribute5,
                                     x_party_header_tbl (i).attribute5, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute5,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_attribute5
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_attribute6,
                                     x_party_header_tbl (i).attribute6, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute6,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_attribute6
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_attribute7,
                                     x_party_header_tbl (i).attribute7, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute7,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_attribute7
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_attribute8,
                                     x_party_header_tbl (i).attribute8, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute8,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_attribute8
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_attribute9,
                                     x_party_header_tbl (i).attribute9, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute9,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_attribute9
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_attribute10,
                                     x_party_header_tbl (i).attribute10, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute10,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_attribute10
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_attribute11,
                                     x_party_header_tbl (i).attribute11, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute11,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_attribute11
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_attribute12,
                                     x_party_header_tbl (i).attribute12, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute12,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_attribute12
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_attribute13,
                                     x_party_header_tbl (i).attribute13, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute13,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_attribute13
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_attribute14,
                                     x_party_header_tbl (i).attribute14, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute14,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_attribute14
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_attribute15,
                                     x_party_header_tbl (i).attribute15, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute15,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_attribute15
                                  )
                             INTO x_party_tbl (l_party_index).party_source_table,
                                  x_party_tbl (l_party_index).party_id,
                                  x_party_tbl (l_party_index).relationship_type_code,
                                  x_party_tbl (l_party_index).active_start_date,
                                  x_party_tbl (l_party_index).active_end_date,
                                  x_party_tbl (l_party_index).contact_flag,
                                  x_party_tbl (l_party_index).contact_ip_id,
                                  x_party_tbl (l_party_index).attribute1,
                                  x_party_tbl (l_party_index).attribute2,
                                  x_party_tbl (l_party_index).attribute3,
                                  x_party_tbl (l_party_index).attribute4,
                                  x_party_tbl (l_party_index).attribute5,
                                  x_party_tbl (l_party_index).attribute6,
                                  x_party_tbl (l_party_index).attribute7,
                                  x_party_tbl (l_party_index).attribute8,
                                  x_party_tbl (l_party_index).attribute9,
                                  x_party_tbl (l_party_index).attribute10,
                                  x_party_tbl (l_party_index).attribute11,
                                  x_party_tbl (l_party_index).attribute12,
                                  x_party_tbl (l_party_index).attribute13,
                                  x_party_tbl (l_party_index).attribute14,
                                  x_party_tbl (l_party_index).attribute15
                             FROM DUAL;

                           x_party_header_tbl.DELETE (i);
                        ELSE
                           x_party_header_tbl.DELETE (i);
                        END IF;
                     END IF;
                  END LOOP;
               END LOOP;
            END IF;

            IF x_party_header_tbl.COUNT >= 1
            THEN
               FOR i IN x_party_header_tbl.FIRST .. x_party_header_tbl.LAST
               LOOP
                  IF      x_party_header_tbl.EXISTS (i)
                      AND x_party_header_tbl (i).active_end_date IS NULL
                  THEN
                     --dbms_output.put_line('Parties Seven');
                     l_party_index :=   x_party_tbl.COUNT
                                      + 1;
                     x_party_tbl (l_party_index).instance_party_id :=
                                     x_party_header_tbl (i).instance_party_id;
                     --dbms_output.put_line('instance_party being end dated:'||x_party_header_tbl(i).instance_party_id);
                     x_party_tbl (l_party_index).object_version_number :=
                                 x_party_header_tbl (i).object_version_number;
                     x_party_tbl (l_party_index).active_end_date :=
                                                                   l_end_date;
                     x_party_header_tbl.DELETE (i);
                  END IF;
               END LOOP;
            END IF;

            FOR csi_intf_party_acct_rec IN
                csi_intf_party_acct_cur (csi_intf_repl_rec.inst_interface_id)
            LOOP
               --dbms_output.put_line('Parties nine');
               IF csi_intf_party_acct_rec.instance_party_id IS NULL
               THEN
                  --dbms_output.put_line('Parties ten');
                  l_party_index :=   x_party_tbl.COUNT
                                   + 1;
                  x_party_tbl (l_party_index).party_id :=
                                             csi_intf_party_acct_rec.party_id;
                  x_party_tbl (l_party_index).party_source_table :=
                                   csi_intf_party_acct_rec.party_source_table;
                  x_party_tbl (l_party_index).instance_id :=
                                          r_instance_id;
                  x_party_tbl (l_party_index).relationship_type_code :=
                         csi_intf_party_acct_rec.party_relationship_type_code;
                  x_party_tbl (l_party_index).active_start_date :=
                                     csi_intf_party_acct_rec.party_start_date;
                  x_party_tbl (l_party_index).contact_flag :=
                                         csi_intf_party_acct_rec.contact_flag;
                  x_party_tbl (l_party_index).contact_ip_id :=
                                        csi_intf_party_acct_rec.contact_ip_id;
                  x_party_tbl (l_party_index).CONTEXT :=
                                        csi_intf_party_acct_rec.party_context;
                  x_party_tbl (l_party_index).attribute1 :=
                                     csi_intf_party_acct_rec.party_attribute1;
                  x_party_tbl (l_party_index).attribute2 :=
                                     csi_intf_party_acct_rec.party_attribute2;
                  x_party_tbl (l_party_index).attribute3 :=
                                     csi_intf_party_acct_rec.party_attribute3;
                  x_party_tbl (l_party_index).attribute4 :=
                                     csi_intf_party_acct_rec.party_attribute4;
                  x_party_tbl (l_party_index).attribute5 :=
                                     csi_intf_party_acct_rec.party_attribute5;
                  x_party_tbl (l_party_index).attribute6 :=
                                     csi_intf_party_acct_rec.party_attribute6;
                  x_party_tbl (l_party_index).attribute7 :=
                                     csi_intf_party_acct_rec.party_attribute7;
                  x_party_tbl (l_party_index).attribute8 :=
                                     csi_intf_party_acct_rec.party_attribute8;
                  x_party_tbl (l_party_index).attribute9 :=
                                     csi_intf_party_acct_rec.party_attribute9;
                  x_party_tbl (l_party_index).attribute10 :=
                                    csi_intf_party_acct_rec.party_attribute10;
                  x_party_tbl (l_party_index).attribute11 :=
                                    csi_intf_party_acct_rec.party_attribute11;
                  x_party_tbl (l_party_index).attribute12 :=
                                    csi_intf_party_acct_rec.party_attribute12;
                  x_party_tbl (l_party_index).attribute13 :=
                                    csi_intf_party_acct_rec.party_attribute13;
                  x_party_tbl (l_party_index).attribute14 :=
                                    csi_intf_party_acct_rec.party_attribute14;
                  x_party_tbl (l_party_index).attribute15 :=
                                    csi_intf_party_acct_rec.party_attribute15;

                  IF csi_intf_party_acct_rec.party_account1_id IS NOT NULL
                  THEN
                     l_party_account_index :=   x_account_tbl.COUNT
                                              + 1;
                     x_account_tbl (l_party_account_index).parent_tbl_index :=
                                                                l_party_index;
                     x_account_tbl (l_party_account_index).party_account_id :=
                                    csi_intf_party_acct_rec.party_account1_id;
                     x_account_tbl (l_party_account_index).relationship_type_code :=
                         csi_intf_party_acct_rec.acct1_relationship_type_code;
                     x_account_tbl (l_party_account_index).active_start_date :=
                               csi_intf_party_acct_rec.party_acct1_start_date;
                     x_account_tbl (l_party_account_index).bill_to_address :=
                                     csi_intf_party_acct_rec.bill_to_address1;
                     x_account_tbl (l_party_account_index).ship_to_address :=
                                     csi_intf_party_acct_rec.ship_to_address1;
                     x_account_tbl (l_party_account_index).CONTEXT :=
                                     csi_intf_party_acct_rec.account1_context;
                     x_account_tbl (l_party_account_index).attribute1 :=
                                  csi_intf_party_acct_rec.account1_attribute1;
                     x_account_tbl (l_party_account_index).attribute2 :=
                                  csi_intf_party_acct_rec.account1_attribute2;
                     x_account_tbl (l_party_account_index).attribute3 :=
                                  csi_intf_party_acct_rec.account1_attribute3;
                     x_account_tbl (l_party_account_index).attribute4 :=
                                  csi_intf_party_acct_rec.account1_attribute4;
                     x_account_tbl (l_party_account_index).attribute5 :=
                                  csi_intf_party_acct_rec.account1_attribute5;
                     x_account_tbl (l_party_account_index).attribute6 :=
                                  csi_intf_party_acct_rec.account1_attribute6;
                     x_account_tbl (l_party_account_index).attribute7 :=
                                  csi_intf_party_acct_rec.account1_attribute7;
                     x_account_tbl (l_party_account_index).attribute8 :=
                                  csi_intf_party_acct_rec.account1_attribute8;
                     x_account_tbl (l_party_account_index).attribute9 :=
                                  csi_intf_party_acct_rec.account1_attribute9;
                     x_account_tbl (l_party_account_index).attribute10 :=
                                 csi_intf_party_acct_rec.account1_attribute10;
                     x_account_tbl (l_party_account_index).attribute11 :=
                                 csi_intf_party_acct_rec.account1_attribute11;
                     x_account_tbl (l_party_account_index).attribute12 :=
                                 csi_intf_party_acct_rec.account1_attribute12;
                     x_account_tbl (l_party_account_index).attribute13 :=
                                 csi_intf_party_acct_rec.account1_attribute13;
                     x_account_tbl (l_party_account_index).attribute14 :=
                                 csi_intf_party_acct_rec.account1_attribute14;
                     x_account_tbl (l_party_account_index).attribute15 :=
                                 csi_intf_party_acct_rec.account1_attribute15;
                  END IF;

                  IF csi_intf_party_acct_rec.party_account2_id IS NOT NULL
                  THEN
                     l_party_account_index :=   x_account_tbl.COUNT
                                              + 1;
                     x_account_tbl (l_party_account_index).parent_tbl_index :=
                                                                l_party_index;
                     x_account_tbl (l_party_account_index).party_account_id :=
                                    csi_intf_party_acct_rec.party_account2_id;
                     x_account_tbl (l_party_account_index).relationship_type_code :=
                         csi_intf_party_acct_rec.acct2_relationship_type_code;
                     x_account_tbl (l_party_account_index).active_start_date :=
                               csi_intf_party_acct_rec.party_acct2_start_date;
                     x_account_tbl (l_party_account_index).bill_to_address :=
                                     csi_intf_party_acct_rec.bill_to_address2;
                     x_account_tbl (l_party_account_index).ship_to_address :=
                                     csi_intf_party_acct_rec.ship_to_address2;
                     x_account_tbl (l_party_account_index).CONTEXT :=
                                     csi_intf_party_acct_rec.account2_context;
                     x_account_tbl (l_party_account_index).attribute1 :=
                                  csi_intf_party_acct_rec.account2_attribute1;
                     x_account_tbl (l_party_account_index).attribute2 :=
                                  csi_intf_party_acct_rec.account2_attribute2;
                     x_account_tbl (l_party_account_index).attribute3 :=
                                  csi_intf_party_acct_rec.account2_attribute3;
                     x_account_tbl (l_party_account_index).attribute4 :=
                                  csi_intf_party_acct_rec.account2_attribute4;
                     x_account_tbl (l_party_account_index).attribute5 :=
                                  csi_intf_party_acct_rec.account2_attribute5;
                     x_account_tbl (l_party_account_index).attribute6 :=
                                  csi_intf_party_acct_rec.account2_attribute6;
                     x_account_tbl (l_party_account_index).attribute7 :=
                                  csi_intf_party_acct_rec.account2_attribute7;
                     x_account_tbl (l_party_account_index).attribute8 :=
                                  csi_intf_party_acct_rec.account2_attribute8;
                     x_account_tbl (l_party_account_index).attribute9 :=
                                  csi_intf_party_acct_rec.account2_attribute9;
                     x_account_tbl (l_party_account_index).attribute10 :=
                                 csi_intf_party_acct_rec.account2_attribute10;
                     x_account_tbl (l_party_account_index).attribute11 :=
                                 csi_intf_party_acct_rec.account2_attribute11;
                     x_account_tbl (l_party_account_index).attribute12 :=
                                 csi_intf_party_acct_rec.account2_attribute12;
                     x_account_tbl (l_party_account_index).attribute13 :=
                                 csi_intf_party_acct_rec.account2_attribute13;
                     x_account_tbl (l_party_account_index).attribute14 :=
                                 csi_intf_party_acct_rec.account2_attribute14;
                     x_account_tbl (l_party_account_index).attribute15 :=
                                 csi_intf_party_acct_rec.account2_attribute15;
                  END IF;

                  IF csi_intf_party_acct_rec.party_account3_id IS NOT NULL
                  THEN
                     l_party_account_index :=   x_account_tbl.COUNT
                                              + 1;
                     x_account_tbl (l_party_account_index).parent_tbl_index :=
                                                                l_party_index;
                     x_account_tbl (l_party_account_index).party_account_id :=
                                    csi_intf_party_acct_rec.party_account3_id;
                     x_account_tbl (l_party_account_index).relationship_type_code :=
                         csi_intf_party_acct_rec.acct3_relationship_type_code;
                     x_account_tbl (l_party_account_index).active_start_date :=
                               csi_intf_party_acct_rec.party_acct3_start_date;
                     x_account_tbl (l_party_account_index).bill_to_address :=
                                     csi_intf_party_acct_rec.bill_to_address3;
                     x_account_tbl (l_party_account_index).ship_to_address :=
                                     csi_intf_party_acct_rec.ship_to_address3;
                     x_account_tbl (l_party_account_index).CONTEXT :=
                                     csi_intf_party_acct_rec.account3_context;
                     x_account_tbl (l_party_account_index).attribute1 :=
                                  csi_intf_party_acct_rec.account3_attribute1;
                     x_account_tbl (l_party_account_index).attribute2 :=
                                  csi_intf_party_acct_rec.account3_attribute2;
                     x_account_tbl (l_party_account_index).attribute3 :=
                                  csi_intf_party_acct_rec.account3_attribute3;
                     x_account_tbl (l_party_account_index).attribute4 :=
                                  csi_intf_party_acct_rec.account3_attribute4;
                     x_account_tbl (l_party_account_index).attribute5 :=
                                  csi_intf_party_acct_rec.account3_attribute5;
                     x_account_tbl (l_party_account_index).attribute6 :=
                                  csi_intf_party_acct_rec.account3_attribute6;
                     x_account_tbl (l_party_account_index).attribute7 :=
                                  csi_intf_party_acct_rec.account3_attribute7;
                     x_account_tbl (l_party_account_index).attribute8 :=
                                  csi_intf_party_acct_rec.account3_attribute8;
                     x_account_tbl (l_party_account_index).attribute9 :=
                                  csi_intf_party_acct_rec.account3_attribute9;
                     x_account_tbl (l_party_account_index).attribute10 :=
                                 csi_intf_party_acct_rec.account3_attribute10;
                     x_account_tbl (l_party_account_index).attribute11 :=
                                 csi_intf_party_acct_rec.account3_attribute11;
                     x_account_tbl (l_party_account_index).attribute12 :=
                                 csi_intf_party_acct_rec.account3_attribute12;
                     x_account_tbl (l_party_account_index).attribute13 :=
                                 csi_intf_party_acct_rec.account3_attribute13;
                     x_account_tbl (l_party_account_index).attribute14 :=
                                 csi_intf_party_acct_rec.account3_attribute14;
                     x_account_tbl (l_party_account_index).attribute15 :=
                                 csi_intf_party_acct_rec.account3_attribute15;
                  END IF;
               END IF;
            END LOOP;


--dbms_output.put_line('x_party_account.count before delete:'||x_party_account_header_tbl.COUNT);

            IF x_party_account_header_tbl.COUNT >= 1
            THEN
               FOR i IN
                   x_party_account_header_tbl.FIRST .. x_party_account_header_tbl.LAST
               LOOP
                  IF      x_party_account_header_tbl.EXISTS (i)
                      AND x_party_account_header_tbl (i).active_end_date IS NOT NULL
                  THEN
                     x_party_account_header_tbl.DELETE (i);
                  END IF;
               END LOOP;
            END IF;


--dbms_output.put_line('x_party_account.count after delete:'||x_party_account_header_tbl.COUNT);
            IF x_party_account_header_tbl.COUNT >= 1
            THEN
               FOR i IN
                   x_party_account_header_tbl.FIRST .. x_party_account_header_tbl.LAST
               LOOP
                  FOR csi_intf_party_acct_rec IN
                      csi_intf_party_acct_cur (
                         csi_intf_repl_rec.inst_interface_id
                      )
                  LOOP
                     IF      x_party_account_header_tbl.EXISTS (i)
                         AND csi_intf_party_acct_rec.ip_account1_id IS NOT NULL
                         AND x_party_account_header_tbl (i).ip_account_id =
                                       csi_intf_party_acct_rec.ip_account1_id
                     THEN
                        IF NOT (    NVL (
                                       csi_intf_party_acct_rec.party_account1_id,
                                       l_miss_num
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).party_account_id,
                                          l_miss_num
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.instance_party_id,
                                       l_miss_num
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).instance_party_id,
                                          l_miss_num
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.acct1_relationship_type_code,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).relationship_type_code,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.bill_to_address1,
                                       l_miss_num
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).bill_to_address,
                                          l_miss_num
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.ship_to_address1,
                                       l_miss_num
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).ship_to_address,
                                          l_miss_num
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account1_context,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).CONTEXT,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account1_attribute1,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute1,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account1_attribute2,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute2,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account1_attribute3,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute3,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account1_attribute4,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute4,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account1_attribute5,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute5,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account1_attribute6,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute6,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account1_attribute7,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute7,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account1_attribute8,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute8,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account1_attribute9,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute9,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account1_attribute10,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute10,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account1_attribute11,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute11,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account1_attribute12,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute12,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account1_attribute13,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute13,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account1_attribute14,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute14,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account1_attribute15,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute15,
                                          l_miss_char
                                       )
                               )
                        THEN
                           l_party_account_index :=   x_account_tbl.COUNT
                                                    + 1;
                           x_account_tbl (l_party_account_index).ip_account_id :=
                                 x_party_account_header_tbl (i).ip_account_id;
                           x_account_tbl (l_party_account_index).instance_party_id :=
                                 x_party_account_header_tbl (i).instance_party_id;
                           x_account_tbl (l_party_account_index).relationship_type_code :=
                                 x_party_account_header_tbl (i).relationship_type_code;
                           x_account_tbl (l_party_account_index).object_version_number :=
                                 x_party_account_header_tbl (i).object_version_number;
                           x_account_tbl (l_party_account_index).parent_tbl_index :=
                                 get_parent_tbl_index (
                                    x_account_tbl (l_party_account_index).instance_party_id,
                                    x_account_tbl (l_party_account_index).relationship_type_code
                                 );

                           IF x_account_tbl (l_party_account_index).parent_tbl_index IS NULL
                           THEN
                              l_party_index :=   x_party_tbl.COUNT
                                               + 1;
                              x_party_tbl (l_party_index).instance_party_id :=
                                    x_account_tbl (l_party_account_index).instance_party_id;
                              x_party_tbl (l_party_index).relationship_type_code :=
                                    x_account_tbl (l_party_account_index).relationship_type_code;
                              x_party_tbl (l_party_index).object_version_number :=
                                    get_obj_ver_num (
                                       x_party_cache_tbl,
                                       x_account_tbl (i).instance_party_id
                                    );
                           END IF;

                           --dbms_output.put_line('Before Select:');

                           SELECT DECODE (
                                     csi_intf_party_acct_rec.acct1_relationship_type_code,
                                     x_party_account_header_tbl (i).relationship_type_code, l_miss_char,
                                     DECODE (
                                        x_party_account_header_tbl (i).relationship_type_code,
                                        NULL, l_miss_char,
                                        NULL
                                     ), csi_intf_party_acct_rec.acct1_relationship_type_code
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_account1_id,
                                     x_party_account_header_tbl (i).party_account_id, l_miss_num,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).party_account_id,
                                              NULL, l_miss_num,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_account1_id
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.bill_to_address1,
                                     x_party_account_header_tbl (i).bill_to_address, l_miss_num,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).bill_to_address,
                                              NULL, l_miss_num,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.bill_to_address1
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.ship_to_address1,
                                     x_party_account_header_tbl (i).ship_to_address, l_miss_num,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).ship_to_address,
                                              NULL, l_miss_num,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.ship_to_address1
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account1_context,
                                     x_party_account_header_tbl (i).CONTEXT, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).CONTEXT,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account1_context
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account1_attribute1,
                                     x_party_account_header_tbl (i).attribute1, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute1,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account1_attribute1
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account1_attribute2,
                                     x_party_account_header_tbl (i).attribute2, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute2,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account1_attribute2
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account1_attribute3,
                                     x_party_account_header_tbl (i).attribute3, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute3,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account1_attribute3
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account1_attribute4,
                                     x_party_account_header_tbl (i).attribute4, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute4,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account1_attribute4
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account1_attribute5,
                                     x_party_account_header_tbl (i).attribute5, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute5,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account1_attribute5
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account1_attribute6,
                                     x_party_account_header_tbl (i).attribute6, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute6,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account1_attribute6
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account1_attribute7,
                                     x_party_account_header_tbl (i).attribute7, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute7,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account1_attribute7
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account1_attribute8,
                                     x_party_account_header_tbl (i).attribute8, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute8,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account1_attribute8
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account1_attribute9,
                                     x_party_account_header_tbl (i).attribute9, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute9,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account1_attribute9
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account1_attribute10,
                                     x_party_account_header_tbl (i).attribute10, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute10,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account1_attribute10
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account1_attribute11,
                                     x_party_account_header_tbl (i).attribute11, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute11,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account1_attribute11
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account1_attribute12,
                                     x_party_account_header_tbl (i).attribute12, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute12,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account1_attribute12
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account1_attribute13,
                                     x_party_account_header_tbl (i).attribute13, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute13,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account1_attribute13
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account1_attribute14,
                                     x_party_account_header_tbl (i).attribute14, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute14,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account1_attribute14
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account1_attribute15,
                                     x_party_account_header_tbl (i).attribute15, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute15,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account1_attribute15
                                  )
                             INTO x_account_tbl (l_party_account_index).relationship_type_code,
                                  x_account_tbl (l_party_account_index).party_account_id,
                                  x_account_tbl (l_party_account_index).bill_to_address,
                                  x_account_tbl (l_party_account_index).ship_to_address,
                                  x_account_tbl (l_party_account_index).CONTEXT,
                                  x_account_tbl (l_party_account_index).attribute1,
                                  x_account_tbl (l_party_account_index).attribute2,
                                  x_account_tbl (l_party_account_index).attribute3,
                                  x_account_tbl (l_party_account_index).attribute4,
                                  x_account_tbl (l_party_account_index).attribute5,
                                  x_account_tbl (l_party_account_index).attribute6,
                                  x_account_tbl (l_party_account_index).attribute7,
                                  x_account_tbl (l_party_account_index).attribute8,
                                  x_account_tbl (l_party_account_index).attribute9,
                                  x_account_tbl (l_party_account_index).attribute10,
                                  x_account_tbl (l_party_account_index).attribute11,
                                  x_account_tbl (l_party_account_index).attribute12,
                                  x_account_tbl (l_party_account_index).attribute13,
                                  x_account_tbl (l_party_account_index).attribute14,
                                  x_account_tbl (l_party_account_index).attribute15
                             FROM DUAL;

                           x_party_account_header_tbl.DELETE (i);
                        ELSE
                           x_party_account_header_tbl.DELETE (i);
                        END IF;
                     END IF;
                  END LOOP;
               END LOOP;
            END IF;

            --dbms_output.put_line('HUNDRED one');
            IF x_party_account_header_tbl.COUNT >= 1
            THEN
               FOR i IN
                   x_party_account_header_tbl.FIRST .. x_party_account_header_tbl.LAST
               LOOP
                  FOR csi_intf_party_acct_rec IN
                      csi_intf_party_acct_cur (
                         csi_intf_repl_rec.inst_interface_id
                      )
                  LOOP
                     IF      x_party_account_header_tbl.EXISTS (i)
                         AND csi_intf_party_acct_rec.ip_account2_id IS NOT NULL
                         AND x_party_account_header_tbl (i).ip_account_id =
                                       csi_intf_party_acct_rec.ip_account2_id
                     THEN
                        IF NOT (    NVL (
                                       csi_intf_party_acct_rec.party_account2_id,
                                       l_miss_num
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).party_account_id,
                                          l_miss_num
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.instance_party_id,
                                       l_miss_num
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).instance_party_id,
                                          l_miss_num
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.acct2_relationship_type_code,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).relationship_type_code,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.bill_to_address2,
                                       l_miss_num
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).bill_to_address,
                                          l_miss_num
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.ship_to_address2,
                                       l_miss_num
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).ship_to_address,
                                          l_miss_num
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account2_context,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).CONTEXT,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account2_attribute1,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute1,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account2_attribute2,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute2,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account2_attribute3,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute3,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account2_attribute4,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute4,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account2_attribute5,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute5,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account2_attribute6,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute6,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account2_attribute7,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute7,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account2_attribute8,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute8,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account2_attribute9,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute9,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account2_attribute10,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute10,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account2_attribute11,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute11,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account2_attribute12,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute12,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account2_attribute13,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute13,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account2_attribute14,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute14,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account2_attribute15,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute15,
                                          l_miss_char
                                       )
                               )
                        THEN
                           l_party_account_index := NVL (
                                                         x_account_tbl.COUNT
                                                       + 1,
                                                       x_account_tbl.FIRST
                                                    );
                           x_account_tbl (l_party_account_index).ip_account_id :=
                                 x_party_account_header_tbl (i).ip_account_id;
                           x_account_tbl (l_party_account_index).instance_party_id :=
                                 x_party_account_header_tbl (i).instance_party_id;
                           x_account_tbl (l_party_account_index).object_version_number :=
                                 x_party_account_header_tbl (i).object_version_number;
                           x_account_tbl (l_party_account_index).parent_tbl_index :=
                                 get_parent_tbl_index (
                                    x_account_tbl (l_party_account_index).instance_party_id,
                                    x_account_tbl (l_party_account_index).relationship_type_code
                                 );

                           IF x_account_tbl (l_party_account_index).parent_tbl_index IS NULL
                           THEN
                              l_party_index :=   x_party_tbl.COUNT
                                               + 1;
                              x_party_tbl (l_party_index).instance_party_id :=
                                    x_account_tbl (l_party_account_index).instance_party_id;
                              x_party_tbl (l_party_index).relationship_type_code :=
                                    x_account_tbl (l_party_account_index).relationship_type_code;
                              x_party_tbl (l_party_index).object_version_number :=
                                    get_obj_ver_num (
                                       x_party_cache_tbl,
                                       x_account_tbl (i).instance_party_id
                                    );
                           END IF;

                           SELECT DECODE (
                                     csi_intf_party_acct_rec.acct2_relationship_type_code,
                                     x_party_account_header_tbl (i).relationship_type_code, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).relationship_type_code,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.acct2_relationship_type_code
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_account2_id,
                                     x_party_account_header_tbl (i).party_account_id, l_miss_num,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).party_account_id,
                                              NULL, l_miss_num,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_account2_id
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.bill_to_address2,
                                     x_party_account_header_tbl (i).bill_to_address, l_miss_num,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).bill_to_address,
                                              NULL, l_miss_num,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.bill_to_address1
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.ship_to_address2,
                                     x_party_account_header_tbl (i).ship_to_address, l_miss_num,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).ship_to_address,
                                              NULL, l_miss_num,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.ship_to_address1
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account2_context,
                                     x_party_account_header_tbl (i).CONTEXT, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).CONTEXT,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account2_context
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account2_attribute1,
                                     x_party_account_header_tbl (i).attribute1, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute1,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account2_attribute1
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account2_attribute2,
                                     x_party_account_header_tbl (i).attribute2, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute2,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account2_attribute2
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account2_attribute3,
                                     x_party_account_header_tbl (i).attribute3, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute3,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account2_attribute3
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account2_attribute4,
                                     x_party_account_header_tbl (i).attribute4, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute4,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account2_attribute4
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account2_attribute5,
                                     x_party_account_header_tbl (i).attribute5, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute5,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account2_attribute5
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account2_attribute6,
                                     x_party_account_header_tbl (i).attribute6, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute6,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account2_attribute6
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account2_attribute7,
                                     x_party_account_header_tbl (i).attribute7, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute7,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account2_attribute7
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account2_attribute8,
                                     x_party_account_header_tbl (i).attribute8, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute8,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account2_attribute8
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account2_attribute9,
                                     x_party_account_header_tbl (i).attribute9, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute9,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account2_attribute9
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account2_attribute10,
                                     x_party_account_header_tbl (i).attribute10, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute10,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account2_attribute10
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account2_attribute11,
                                     x_party_account_header_tbl (i).attribute11, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute11,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account2_attribute11
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account2_attribute12,
                                     x_party_account_header_tbl (i).attribute12, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute12,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account2_attribute12
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account2_attribute13,
                                     x_party_account_header_tbl (i).attribute13, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute13,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account2_attribute13
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account2_attribute14,
                                     x_party_account_header_tbl (i).attribute14, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute14,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account2_attribute14
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account2_attribute14,
                                     x_party_account_header_tbl (i).attribute14, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).attribute15,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account2_attribute15
                                  )
                             INTO x_account_tbl (l_party_account_index).relationship_type_code,
                                  x_account_tbl (l_party_account_index).party_account_id,
                                  x_account_tbl (l_party_account_index).bill_to_address,
                                  x_account_tbl (l_party_account_index).ship_to_address,
                                  x_account_tbl (l_party_account_index).CONTEXT,
                                  x_account_tbl (l_party_account_index).attribute1,
                                  x_account_tbl (l_party_account_index).attribute2,
                                  x_account_tbl (l_party_account_index).attribute3,
                                  x_account_tbl (l_party_account_index).attribute4,
                                  x_account_tbl (l_party_account_index).attribute5,
                                  x_account_tbl (l_party_account_index).attribute6,
                                  x_account_tbl (l_party_account_index).attribute7,
                                  x_account_tbl (l_party_account_index).attribute8,
                                  x_account_tbl (l_party_account_index).attribute9,
                                  x_account_tbl (l_party_account_index).attribute10,
                                  x_account_tbl (l_party_account_index).attribute11,
                                  x_account_tbl (l_party_account_index).attribute12,
                                  x_account_tbl (l_party_account_index).attribute13,
                                  x_account_tbl (l_party_account_index).attribute14,
                                  x_account_tbl (l_party_account_index).attribute15
                             FROM DUAL;

                           x_party_account_header_tbl.DELETE (i);
                        ELSE
                           x_party_account_header_tbl.DELETE (i);
                        END IF;
                     END IF;
                  END LOOP;
               END LOOP;
            END IF;

            IF x_party_account_header_tbl.COUNT >= 1
            THEN
               FOR i IN
                   x_party_account_header_tbl.FIRST .. x_party_account_header_tbl.LAST
               LOOP
                  FOR csi_intf_party_acct_rec IN
                      csi_intf_party_acct_cur (
                         csi_intf_repl_rec.inst_interface_id
                      )
                  LOOP
                     IF      x_party_account_header_tbl.EXISTS (i)
                         AND csi_intf_party_acct_rec.ip_account3_id IS NOT NULL
                         AND x_party_account_header_tbl (i).ip_account_id =
                                       csi_intf_party_acct_rec.ip_account3_id
                     THEN
                        IF NOT (    NVL (
                                       csi_intf_party_acct_rec.party_account3_id,
                                       l_miss_num
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).party_account_id,
                                          l_miss_num
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.instance_party_id,
                                       l_miss_num
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).instance_party_id,
                                          l_miss_num
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.acct3_relationship_type_code,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).relationship_type_code,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.bill_to_address1,
                                       l_miss_num
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).bill_to_address,
                                          l_miss_num
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.ship_to_address1,
                                       l_miss_num
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).ship_to_address,
                                          l_miss_num
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account3_context,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).CONTEXT,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account3_attribute1,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute1,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account3_attribute2,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute2,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account3_attribute3,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute3,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account3_attribute4,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute4,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account3_attribute5,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute5,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account3_attribute6,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute6,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account3_attribute7,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute7,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account3_attribute8,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute8,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account3_attribute9,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute9,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account3_attribute10,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute10,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account3_attribute11,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute11,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account3_attribute12,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute12,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account3_attribute13,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute13,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account3_attribute14,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute14,
                                          l_miss_char
                                       )
                                AND NVL (
                                       csi_intf_party_acct_rec.account3_attribute15,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_party_account_header_tbl (i).attribute15,
                                          l_miss_char
                                       )
                               )
                        THEN
                           l_party_account_index :=   x_account_tbl.COUNT
                                                    + 1;
                           x_account_tbl (l_party_account_index).ip_account_id :=
                                 x_party_account_header_tbl (i).ip_account_id;
                           x_account_tbl (l_party_account_index).instance_party_id :=
                                 x_party_account_header_tbl (i).instance_party_id;
                           x_account_tbl (l_party_account_index).object_version_number :=
                                 x_party_account_header_tbl (i).object_version_number;
                           x_account_tbl (l_party_account_index).parent_tbl_index :=
                                 get_parent_tbl_index (
                                    x_account_tbl (l_party_account_index).instance_party_id,
                                    x_account_tbl (l_party_account_index).relationship_type_code
                                 );

                           IF x_account_tbl (l_party_account_index).parent_tbl_index IS NULL
                           THEN
                              l_party_index :=   x_party_tbl.COUNT
                                               + 1;
                              x_party_tbl (l_party_index).instance_party_id :=
                                    x_account_tbl (l_party_account_index).instance_party_id;
                              x_party_tbl (l_party_index).relationship_type_code :=
                                    x_account_tbl (l_party_account_index).relationship_type_code;
                              x_party_tbl (l_party_index).object_version_number :=
                                    get_obj_ver_num (
                                       x_party_cache_tbl,
                                       x_account_tbl (i).instance_party_id
                                    );
                           END IF;

                           SELECT DECODE (
                                     csi_intf_party_acct_rec.acct3_relationship_type_code,
                                     x_party_account_header_tbl (i).relationship_type_code, l_miss_char,
                                     NULL, DECODE (
                                              x_party_header_tbl (i).relationship_type_code,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.acct3_relationship_type_code
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.party_account3_id,
                                     x_party_account_header_tbl (i).party_account_id, l_miss_num,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).party_account_id,
                                              NULL, l_miss_num,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.party_account3_id
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.bill_to_address3,
                                     x_party_account_header_tbl (i).bill_to_address, l_miss_num,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).bill_to_address,
                                              NULL, l_miss_num,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.bill_to_address3
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.ship_to_address3,
                                     x_party_account_header_tbl (i).ship_to_address, l_miss_num,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).ship_to_address,
                                              NULL, l_miss_num,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.ship_to_address3
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account3_context,
                                     x_party_account_header_tbl (i).CONTEXT, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).CONTEXT,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account3_context
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account3_attribute1,
                                     x_party_account_header_tbl (i).attribute1, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute1,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account3_attribute1
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account3_attribute2,
                                     x_party_account_header_tbl (i).attribute2, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute2,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account3_attribute2
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account3_attribute3,
                                     x_party_account_header_tbl (i).attribute3, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute3,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account3_attribute3
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account3_attribute4,
                                     x_party_account_header_tbl (i).attribute4, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute4,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account3_attribute4
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account3_attribute5,
                                     x_party_account_header_tbl (i).attribute5, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute5,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account3_attribute5
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account3_attribute6,
                                     x_party_account_header_tbl (i).attribute6, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute6,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account3_attribute6
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account3_attribute7,
                                     x_party_account_header_tbl (i).attribute7, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute7,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account3_attribute7
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account3_attribute8,
                                     x_party_account_header_tbl (i).attribute8, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute8,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account3_attribute8
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account3_attribute9,
                                     x_party_account_header_tbl (i).attribute9, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute9,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account3_attribute9
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account3_attribute10,
                                     x_party_account_header_tbl (i).attribute10, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute10,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account3_attribute10
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account3_attribute11,
                                     x_party_account_header_tbl (i).attribute11, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute11,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account3_attribute11
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account3_attribute12,
                                     x_party_account_header_tbl (i).attribute12, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute12,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account3_attribute12
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account3_attribute13,
                                     x_party_account_header_tbl (i).attribute13, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute13,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account3_attribute13
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account3_attribute14,
                                     x_party_account_header_tbl (i).attribute14, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute14,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account3_attribute14
                                  ),
                                  DECODE (
                                     csi_intf_party_acct_rec.account3_attribute14,
                                     x_party_account_header_tbl (i).attribute14, l_miss_char,
                                     NULL, DECODE (
                                              x_party_account_header_tbl (i).attribute15,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_party_acct_rec.account3_attribute15
                                  )
                             INTO x_account_tbl (l_party_account_index).relationship_type_code,
                                  x_account_tbl (l_party_account_index).party_account_id,
                                  x_account_tbl (l_party_account_index).bill_to_address,
                                  x_account_tbl (l_party_account_index).ship_to_address,
                                  x_account_tbl (l_party_account_index).CONTEXT,
                                  x_account_tbl (l_party_account_index).attribute1,
                                  x_account_tbl (l_party_account_index).attribute2,
                                  x_account_tbl (l_party_account_index).attribute3,
                                  x_account_tbl (l_party_account_index).attribute4,
                                  x_account_tbl (l_party_account_index).attribute5,
                                  x_account_tbl (l_party_account_index).attribute6,
                                  x_account_tbl (l_party_account_index).attribute7,
                                  x_account_tbl (l_party_account_index).attribute8,
                                  x_account_tbl (l_party_account_index).attribute9,
                                  x_account_tbl (l_party_account_index).attribute10,
                                  x_account_tbl (l_party_account_index).attribute11,
                                  x_account_tbl (l_party_account_index).attribute12,
                                  x_account_tbl (l_party_account_index).attribute13,
                                  x_account_tbl (l_party_account_index).attribute14,
                                  x_account_tbl (l_party_account_index).attribute15
                             FROM DUAL;

                           x_party_account_header_tbl.DELETE (i);
                        ELSE
                           x_party_account_header_tbl.DELETE (i);
                        END IF;
                     END IF;
                  END LOOP;
               END LOOP;
            END IF;

            IF x_party_account_header_tbl.COUNT >= 1
            THEN
               FOR i IN
                   x_party_account_header_tbl.FIRST .. x_party_account_header_tbl.LAST
               LOOP
                  IF      x_party_account_header_tbl.EXISTS (i)
                      AND x_party_account_header_tbl (i).instance_party_id IS NOT NULL
                  THEN
                     l_party_account_index :=   x_account_tbl.COUNT
                                              + 1;
                     x_account_tbl (l_party_account_index).instance_party_id :=
                             x_party_account_header_tbl (i).instance_party_id;
                     x_account_tbl (l_party_account_index).object_version_number :=
                         x_party_account_header_tbl (i).object_version_number;
                     x_account_tbl (l_party_account_index).active_end_date :=
                                                                   l_end_date;
                     x_party_account_header_tbl.DELETE (i);
                  END IF;
               END LOOP;
            END IF;


--dbms_output.put_line('After party accounts count:'||x_account_tbl.COUNT);
            IF x_ext_attrib_value_tbl.COUNT >= 1
            THEN
               FOR i IN
                   x_ext_attrib_value_tbl.FIRST .. x_ext_attrib_value_tbl.LAST
               LOOP
                  IF x_ext_attrib_value_tbl (i).active_end_date IS NOT NULL
                  THEN
                     x_ext_attrib_value_tbl.DELETE (i);
                  END IF;
               END LOOP;
            END IF;

            IF x_ext_attrib_value_tbl.COUNT >= 1
            THEN
               FOR i IN
                   x_ext_attrib_value_tbl.FIRST .. x_ext_attrib_value_tbl.LAST
               LOOP
                  FOR csi_intf_ext_attrib_rec IN
                      csi_intf_ext_attrib_cur (
                         csi_intf_repl_rec.inst_interface_id
                      )
                  LOOP
                     IF x_ext_attrib_value_tbl (i).attribute_value_id =
                                   csi_intf_ext_attrib_rec.attribute_value_id
                     THEN
                        IF NOT (    NVL (
                                       csi_intf_ext_attrib_rec.attribute_id,
                                       l_miss_num
                                    ) =
                                       NVL (
                                          x_ext_attrib_value_tbl (i).attribute_id,
                                          l_miss_num
                                       )
                                AND NVL (
                                       csi_intf_ext_attrib_rec.attribute_value,
                                       l_miss_char
                                    ) =
                                       NVL (
                                          x_ext_attrib_value_tbl (i).attribute_value,
                                          l_miss_char
                                       )
                               )
                        THEN
                           l_ieav_index :=
                                 NVL (  x_eav_tbl.COUNT
                                      + 1, x_eav_tbl.FIRST);
                           x_eav_tbl (l_ieav_index).attribute_value_id :=
                                x_ext_attrib_value_tbl (i).attribute_value_id;
                           x_eav_tbl (l_ieav_index).instance_id :=
                                       r_instance_id;
                           x_eav_tbl (l_ieav_index).object_version_number :=
                                 x_ext_attrib_value_tbl (i).object_version_number;

                           SELECT DECODE (
                                     csi_intf_ext_attrib_rec.attribute_value,
                                     x_ext_attrib_value_tbl (i).attribute_value, l_miss_char,
                                     NULL, DECODE (
                                              x_ext_attrib_value_tbl (i).attribute_value,
                                              NULL, l_miss_char,
                                              NULL
                                           ),
                                     csi_intf_ext_attrib_rec.attribute_value
                                  )
                             INTO x_eav_tbl (l_ieav_index).attribute_value
                             FROM DUAL;

                           x_ext_attrib_value_tbl.DELETE (i);
                        ELSE
                           x_ext_attrib_value_tbl.DELETE (i);
                        END IF;
                     END IF;
                  END LOOP;
               END LOOP;
            END IF;

            IF x_ext_attrib_value_tbl.COUNT >= 1
            THEN
               FOR i IN
                   x_ext_attrib_value_tbl.FIRST .. x_ext_attrib_value_tbl.LAST
               LOOP
                  IF x_ext_attrib_value_tbl.EXISTS (i)
                  THEN
                     l_ieav_index :=   x_eav_tbl.COUNT + 1;
                     x_eav_tbl (l_ieav_index).attribute_value_id :=
                                x_ext_attrib_value_tbl (i).attribute_value_id;
                     x_eav_tbl (l_ieav_index).object_version_number :=
                             x_ext_attrib_value_tbl (i).object_version_number;
                     x_eav_tbl (l_ieav_index).active_end_date := l_end_date;
                     x_ext_attrib_value_tbl.DELETE (i);
                  END IF;
               END LOOP;
            END IF;

            FOR csi_intf_ext_attrib_rec IN
                csi_intf_ext_attrib_cur (csi_intf_repl_rec.inst_interface_id)
            LOOP
               IF csi_intf_ext_attrib_rec.attribute_value_id IS NULL
               THEN
                  l_ieav_index :=   x_eav_tbl.COUNT + 1;
                  x_eav_tbl (l_ieav_index).attribute_id :=
                                         csi_intf_ext_attrib_rec.attribute_id;
                  x_eav_tbl (l_ieav_index).attribute_value :=
                                      csi_intf_ext_attrib_rec.attribute_value;
                  x_eav_tbl (l_ieav_index).instance_id :=
                                          r_instance_id;
                  x_eav_tbl (l_ieav_index).active_start_date :=
                                      csi_intf_ext_attrib_rec.ieav_start_date;
               END IF;
            END LOOP;
         EXCEPTION
            WHEN e_error
            THEN
               ROLLBACK TO instance_entity;
               --dbms_output.put_line('in e_Error:'||substr(l_msg_data,1,200));
               x_error_message := fnd_message.get;
               x_return_status := fnd_api.g_ret_sts_error;
            WHEN OTHERS
            THEN
               l_sql_error := SQLERRM;
               fnd_message.set_name ('CSI', 'CSI_ML_UNEXP_SQL_ERROR');
               fnd_message.set_token ('API_NAME', l_api_name);
               fnd_message.set_token ('SQL_ERROR', SQLERRM);
               x_error_message := fnd_message.get;
               x_return_status := fnd_api.g_ret_sts_unexp_error;
         END;
      END LOOP; --csi_intf_repl_cur

   END process_replace;
END csi_ml_replace_pvt;

/

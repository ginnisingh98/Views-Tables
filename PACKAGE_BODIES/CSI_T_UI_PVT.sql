--------------------------------------------------------
--  DDL for Package Body CSI_T_UI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_T_UI_PVT" AS
/* $Header: csivtuib.pls 120.1 2005/07/12 18:27:24 brmanesh noship $*/

  FUNCTION g_miss_num RETURN number
  IS
  BEGIN
    RETURN fnd_api.g_miss_num;
  END g_miss_num;

  FUNCTION g_miss_char RETURN varchar2
  IS
  BEGIN
    RETURN fnd_api.g_miss_char ;
  END g_miss_char;

  FUNCTION g_miss_date RETURN date
  IS
  BEGIN
    RETURN fnd_api.g_miss_date ;
  END g_miss_date ;

  FUNCTION g_valid_level(p_level varchar2) RETURN number
  IS
  BEGIN
    IF p_level = 'NONE' then
      RETURN fnd_api.g_valid_level_none;
    ELSIF p_level = 'FULL' then
      RETURN fnd_api.g_valid_level_full;
    ELSE

      fnd_msg_pub.add_exc_msg(
        p_pkg_name       => G_PKG_NAME ,
        p_procedure_name => 'G_VALID_LEVEL',
        p_error_text     => 'Unrecognized Value: '||p_level);

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;
  END g_valid_level ;

  FUNCTION g_boolean(p_FLAG varchar2) RETURN varchar2
  IS
  BEGIN
    if p_flag = 'TRUE' then
      return FND_API.G_TRUE ;
    elsif p_flag = 'FALSE' then
      return FND_API.G_FALSE ;
    else
      fnd_msg_pub.add_exc_msg(
        p_pkg_name       => G_PKG_NAME,
        p_procedure_name => 'G_BOOLEAN',
        p_error_text     => 'Unrecognized Value: '||p_flag);
      RAISE fnd_api.g_exc_unexpected_error;
    END if;
  END g_boolean;

  FUNCTION get_error_constant(err_msg varchar2) RETURN varchar2
  IS
  BEGIN

    IF err_msg = 'G_RET_STS_ERROR' THEN
       RETURN fnd_api.g_ret_sts_error;
    ELSIF err_msg = 'G_RET_STS_UNEXP_ERROR' THEN
       RETURN fnd_api.g_ret_sts_unexp_error;
    ELSIF err_msg = 'G_RET_STS_SUCCESS' THEN
       RETURN fnd_api.g_ret_sts_success;
    END IF;

 END get_error_constant;

  FUNCTION ui_txn_source_rec RETURN csi_t_ui_pvt.txn_source_rec
  IS
    l_txn_source_rec csi_t_ui_pvt.txn_source_rec;
  BEGIN
    RETURN l_txn_source_rec;
  END ui_txn_source_rec;

  FUNCTION ui_txn_source_param_rec RETURN csi_t_ui_pvt.txn_source_param_rec
  IS
    l_txn_source_param_rec csi_t_ui_pvt.txn_source_param_rec;
  BEGIN
    RETURN l_txn_source_param_rec;
  END ui_txn_source_param_rec;

  FUNCTION ui_txn_line_rec RETURN csi_t_datastructures_grp.txn_line_rec
  IS
    l_txn_line_rec csi_t_datastructures_grp.txn_line_rec;
  BEGIN
    RETURN l_txn_line_rec;
  END ui_txn_line_rec;

  -- Partner ordering changes
  FUNCTION ui_partner_order_rec RETURN oe_install_base_util.partner_order_rec
  IS
    l_partner_order_rec  oe_install_base_util.partner_order_rec;
  BEGIN
    RETURN l_partner_order_rec;
  END ui_partner_order_rec;
  -- End partner ordering changes

  PROCEDURE get_src_txn_type_id(
    p_order_line_id IN            number,
    px_txn_type_id  IN OUT nocopy number,
    x_return_status    OUT nocopy varchar2)
  IS
    l_org_id                number;
    l_inventory_item_id     number;
    l_organization_id       number;
    l_shippable_flag        varchar2(1);
    l_receipt_node_found    boolean;
    l_source_doc_type_id    number;
    l_source_doc_line_id    number;
    l_destination_type_code varchar2(30);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    -- Added the condition for Bug 3808664
    IF px_txn_type_id <> 56
    THEN

      SELECT oel.inventory_item_id,
             oel.ship_from_org_id,
             oel.source_document_type_id,
             oel.source_document_line_id,
             oel.org_id
      INTO   l_inventory_item_id,
             l_organization_id,
             l_source_doc_type_id,
             l_source_doc_line_id,
             l_org_id
      FROM   oe_order_lines_all oel
      WHERE  oel.line_id = p_order_line_id;

      IF l_organization_id is null THEN
        l_organization_id := oe_sys_parameters.value(
                               param_name => 'MASTER_ORGANIZATION_ID',
                               p_org_id   => l_org_id);
      END IF;

      IF px_txn_type_id = 53  THEN

        SELECT nvl(shippable_item_flag,'N')
        INTO   l_shippable_flag
        FROM   mtl_system_items
        WHERE  inventory_item_id = l_inventory_item_id
        AND    organization_id   = l_organization_id;

        IF l_shippable_flag = 'N' THEN
          px_txn_type_id := 54;
        ELSE
          l_receipt_node_found := wf_engine.activity_exist_in_process(
                                    p_item_type          => 'OEOL',
                                    p_item_key           => to_char(p_order_line_id),
                                    p_activity_item_type => 'OEOL',
                                    p_activity_name      => 'RMA_RECEIVING_SUB');
          IF NOT(l_receipt_node_found) THEN
            px_txn_type_id := 54;
          END IF;
        END IF;
      ELSIF px_txn_type_id = 51 THEN
        IF l_source_doc_type_id = 10 THEN
          SELECT destination_type_code
          INTO   l_destination_type_code
          FROM   po_requisition_lines_all
          WHERE  requisition_line_id = l_source_doc_line_id;
          IF l_destination_type_code = 'EXPENSE' THEN
            px_txn_type_id := 126;
          END IF;
        END IF;
      END IF;
    END IF;
  END get_src_txn_type_id;

END csi_t_ui_pvt;

/

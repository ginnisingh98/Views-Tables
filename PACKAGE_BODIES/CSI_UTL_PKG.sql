--------------------------------------------------------
--  DDL for Package Body CSI_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_UTL_PKG" as
/* $Header: csiutlb.pls 120.21.12010000.3 2009/04/03 00:48:39 chihchan ship $ */

  /*----------------------------------------------------------*/
  /* Package Name  : csi_utl_pkg                              */
  /* Description   : used by the order shipment interface     */
  /*                 to do the validations                    */
  /*----------------------------------------------------------*/

  G_PKG_NAME  CONSTANT VARCHAR2(30) := 'csi_utl_pkg';
  G_FILE_NAME CONSTANT VARCHAR2(12) := 'csiutlb.pls';

  PROCEDURE debug(
    p_message     IN VARCHAR2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.add(p_message);
  END debug;

  PROCEDURE api_log(
    p_api_name    IN VARCHAR2)
  IS
  BEGIN

    csi_order_ship_pub.g_api_name := 'csi_utl_pkg.'||p_api_name;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => 'csi_utl_pkg',
      p_api_name => p_api_name);

  END api_log;

  PROCEDURE dump_txn_ps_tbl(
    p_txn_ps_tbl in txn_ps_tbl)
  IS
    l_ps_line varchar2(255);
  BEGIN

    csi_t_gen_utility_pvt.add('TxnLnId     QRatio      RemQty      Status');
    csi_t_gen_utility_pvt.add('----------  ----------  ----------  -------');

    IF p_txn_ps_tbl.COUNT > 0 THEN
      FOR l_ind in p_txn_ps_tbl.FIRST .. p_txn_ps_tbl.LAST
      LOOP
        l_ps_line := rpad(to_char(p_txn_ps_tbl(l_ind).txn_line_detail_id), 12, ' ')||
                     rpad(to_char(p_txn_ps_tbl(l_ind).quantity_ratio), 12, ' ')||
                     rpad(to_char(p_txn_ps_tbl(l_ind).quantity_remaining), 12, ' ')||
                     rpad(p_txn_ps_tbl(l_ind).processed_flag, 9, ' ');
        csi_t_gen_utility_pvt.add(l_ps_line);

      END LOOP;
    END IF;

  END dump_txn_ps_tbl;

  FUNCTION get_curr_party(
    p_instance_id   IN NUMBER,
    p_rel_type_code IN VARCHAR2)
  RETURN NUMBER
  IS
    l_inst_pty_id NUMBER;
  BEGIN

    api_log('get_curr_party');

    SELECT party_id
    INTO   l_inst_pty_id
    FROM   csi_i_parties
    WHERE  instance_id = p_instance_id
    AND    relationship_type_code = p_rel_type_code
    AND    ((active_end_date is null ) OR (active_end_date > sysdate));

    RETURN l_inst_pty_id;

  EXCEPTION
    WHEN no_data_found THEN
      fnd_message.set_name('CSI','CSI_INT_INV_INST_PARTY_ID');
      fnd_message.set_token('INSTANCE_ID',p_instance_id);
      fnd_message.set_token('RELATIONSHIP_TYPE_CODE',p_rel_type_code );
      fnd_msg_pub.add;
      l_inst_pty_id := -1;
      RETURN l_inst_pty_id;
    WHEN others THEN
      fnd_message.set_name('CSI','CSI_INT_INV_INST_PARTY_ID');
      fnd_message.set_token('INSTANCE_ID',p_instance_id);
      fnd_message.set_token('RELATIONSHIP_TYPE_CODE',p_rel_type_code );
      fnd_msg_pub.add;
      l_inst_pty_id := -1;
      RETURN l_inst_pty_id;
  END get_curr_party;

  FUNCTION get_org_obj_ver_num(
    p_instance_ou_id IN NUMBER)
  RETURN NUMBER
  IS
   l_obj_ver_num NUMBER;
  BEGIN

    api_log('get_org_obj_ver_num');

    SELECT object_version_number
    INTO   l_obj_ver_num
    FROM   csi_i_org_assignments
    WHERE  instance_ou_id  = p_instance_ou_id;
    RETURN l_obj_ver_num;
  EXCEPTION
    WHEN no_data_found THEN
      fnd_message.set_name('CSI','CSI_INT_INV_INST_OU_ID');
      fnd_message.set_token('INSTANCE_OU_ID',p_instance_ou_id);
      fnd_msg_pub.add;
      l_obj_ver_num := -1;
      RETURN l_obj_ver_num;
    WHEN others THEN
      fnd_message.set_name('CSI','CSI_INT_INV_INST_OU_ID');
      fnd_message.set_token('INSTANCE_OU_ID',p_instance_ou_id);
      fnd_msg_pub.add;
      l_obj_ver_num := -1;
      RETURN l_obj_ver_num;
  END get_org_obj_ver_num;

  FUNCTION get_ii_obj_ver_num(
    p_relationship_id IN NUMBER)
  RETURN NUMBER
  IS
    l_obj_ver_num NUMBER;
  BEGIN

    api_log('get_ii_obj_ver_num');

    SELECT object_version_number
    INTO   l_obj_ver_num
    FROM   csi_ii_relationships
    WHERE  relationship_id  = p_relationship_id
    AND  ((active_end_date is null ) OR
          (active_end_date > sysdate));

    RETURN l_obj_ver_num;

  EXCEPTION
    WHEN no_data_found THEN
      fnd_message.set_name('CSI','CSI_INT_INV_II_REL_ID');
      fnd_message.set_token('RELATIONSHIP_ID',p_relationship_id);
      fnd_msg_pub.add;
      l_obj_ver_num := -1;
      RETURN l_obj_ver_num;
    WHEN others THEN
      fnd_message.set_name('CSI','CSI_INT_INV_II_REL_ID');
      fnd_message.set_token('RELATIONSHIP_ID',p_relationship_id);
      fnd_msg_pub.add;
      l_obj_ver_num := -1;
      RETURN l_obj_ver_num;
   END get_ii_obj_ver_num;

  PROCEDURE get_ext_attribs(
    p_instance_id        IN  NUMBER,
    p_attribute_id       IN  NUMBER,
    x_attribute_value_id OUT NOCOPY NUMBER,
    x_obj_version_number OUT NOCOPY NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_ext_attribs');

    SELECT object_version_number,
           attribute_value_id
    INTO   x_obj_version_number,
           x_attribute_value_id
    FROM   csi_iea_values
    WHERE  instance_id = p_instance_id
    AND    attribute_id = p_attribute_id
    AND   ((active_end_date is null ) OR
           (active_end_date > sysdate));

  EXCEPTION
    WHEN no_data_found THEN
      fnd_message.set_name('CSI','CSI_INT_INV_EXT_ATTR_ID');
      fnd_message.set_token('INSTANCE_ID',p_instance_id);
      fnd_message.set_token('ATTRIBUTE_ID',p_attribute_id );
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN too_many_rows THEN
      fnd_message.set_name('CSI','CSI_INT_MANY_ATTR_FOUND');
      fnd_message.set_token('INSTANCE_ID',p_instance_id);
      fnd_message.set_token('ATTRIBUTE_ID',p_attribute_id );
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
  END get_ext_attribs;

  PROCEDURE get_org_assign(
    p_instance_id        IN  NUMBER,
    p_operating_unit_id  IN  NUMBER,
    p_rel_type_code      IN  VARCHAR2,
    x_instance_ou_id     OUT NOCOPY NUMBER,
    x_obj_version_number OUT NOCOPY NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_org_assign');

    SELECT object_version_number,
           instance_ou_id
    INTO   x_obj_version_number,
           x_instance_ou_id
    FROM   csi_i_org_assignments
    WHERE  instance_id = p_instance_id
    AND    operating_unit_id = p_operating_unit_id
    AND    relationship_type_code = p_rel_type_code
    AND   ((active_end_date is null ) OR
           (active_end_date > sysdate));
  EXCEPTION
    WHEN no_data_found THEN
      fnd_message.set_name('CSI','CSI_INT_INV_OU_ID');
      fnd_message.set_token('INSTANCE_ID',p_instance_id);
      fnd_message.set_token('OPERATING_UNIT_ID',p_operating_unit_id);
      fnd_message.set_token('RELATIONSHIP_TYPE_CODE',p_rel_type_code);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN too_many_rows THEN
      fnd_message.set_name('CSI','CSI_INT_MANY_OU_FOUND');
      fnd_message.set_token('INSTANCE_PARTY_ID',p_instance_id);
      fnd_message.set_token('OPERATING_UNIT_ID',p_operating_unit_id);
      fnd_message.set_token('RELATIONSHIP_TYPE_CODE',p_rel_type_code);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
  END get_org_assign;

  PROCEDURE get_party_account(
    p_instance_pty_id    IN  NUMBER ,
    p_rel_type_code      IN  VARCHAR2,
    x_ip_account_id      OUT NOCOPY NUMBER,
    x_obj_version_number OUT NOCOPY NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2)
  IS
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_party_account');

    SELECT object_version_number,
           ip_account_id
    INTO   x_obj_version_number,
           x_ip_account_id
    FROM   csi_ip_accounts
    WHERE  instance_party_id = p_instance_pty_id
    AND    relationship_type_code = p_rel_type_code
    AND   ((active_end_date is null ) OR
           (active_end_date > sysdate));

  EXCEPTION
    WHEN no_data_found THEN
      fnd_message.set_name('CSI','CSI_INT_INV_ACCT_ID');
      fnd_message.set_token('INSTANCE_PARTY_ID',p_instance_pty_id);
      fnd_message.set_token('RELATIONSHIP_TYPE_CODE',p_rel_type_code);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN too_many_rows THEN
      fnd_message.set_name('CSI','CSI_INT_MANY_ACCT_FOUND');
      fnd_message.set_token('INSTANCE_PARTY_ID',p_instance_pty_id);
      fnd_message.set_token('RELATIONSHIP_TYPE_CODE',p_rel_type_code);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
  END get_party_account;

  PROCEDURE get_instance_party(
    p_instance_id        IN  NUMBER ,
    p_rel_type_code      IN  VARCHAR2,
    x_inst_pty_qty       OUT NOCOPY NUMBER,
    x_obj_version_number OUT NOCOPY NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2)
  IS
  BEGIN

    api_log('get_instance_party');

    x_return_status := fnd_api.g_ret_sts_success;

    SELECT object_version_number,
           instance_party_id
    INTO   x_obj_version_number,
           x_inst_pty_qty
    FROM   csi_i_parties
    WHERE  instance_id = p_instance_id
    AND    relationship_type_code = p_rel_type_code
    AND   ((active_end_date is null ) OR
           (active_end_date > sysdate));


  EXCEPTION
    WHEN no_data_found THEN
      fnd_message.set_name('CSI','CSI_INT_INV_INSTA_PTY_ID');
      fnd_message.set_token('INSTANCE_ID',p_instance_id);
      fnd_message.set_token('RELATIONSHIP_TYPE_CODE',p_rel_type_code);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN too_many_rows THEN
      fnd_message.set_name('CSI','CSI_INT_MANY_INSTA_PTY_FOUND');
      fnd_message.set_token('INSTANCE_ID',p_instance_id);
      fnd_message.set_token('RELATIONSHIP_TYPE_CODE',p_rel_type_code);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;

  END get_instance_party;

  PROCEDURE get_instance(
    p_instance_id        IN  NUMBER ,
    x_obj_version_number OUT NOCOPY NUMBER,
    x_inst_qty           OUT NOCOPY NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2)
  IS
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_instance');

    SELECT object_version_number,
           quantity
    INTO   x_obj_version_number,
           x_inst_qty
    FROM   csi_item_instances
    WHERE  instance_id = p_instance_id;
    -- Commented these predicates as part of fix for Bug 2985193
    -- Because the get_item_instance is opened for expired instances also.
    -- AND   ((active_end_date is null ) OR
    --       (active_end_date > sysdate));

  EXCEPTION
    WHEN no_data_found THEN
      fnd_message.set_name('CSI','CSI_INT_INV_INST_ID');
      fnd_message.set_token('INSTANCE_ID',p_instance_id);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
  END get_instance;

  FUNCTION get_ext_obj_ver_num(
    p_attrib_value_id IN NUMBER)
  RETURN NUMBER
  IS
    l_obj_ver_num NUMBER;
  BEGIN

    api_log('get_ext_obj_ver_num');

    SELECT object_version_number
    INTO   l_obj_ver_num
    FROM   csi_iea_values
    WHERE  attribute_value_id  = p_attrib_value_id
    AND   ((active_end_date is null ) OR
           (active_end_date > sysdate));
    RETURN l_obj_ver_num;
  EXCEPTION
    WHEN no_data_found THEN
      fnd_message.set_name('CSI','CSI_INT_INV_ATTR_VALUE_ID');
      fnd_message.set_token('ATTRIBUTE_VALUE_ID',p_attrib_value_id);
      fnd_msg_pub.add;
      l_obj_ver_num := -1;
      RETURN l_obj_ver_num;
  END get_ext_obj_ver_num;

  FUNCTION get_pty_obj_ver_num(
    p_inst_pty_id  IN NUMBER)
  RETURN NUMBER
  IS
    l_obj_ver_num NUMBER;
  BEGIN

    api_log('get_pty_obj_ver_num');

    SELECT object_version_number
    INTO   l_obj_ver_num
    FROM   csi_i_parties
    WHERE  instance_party_id = p_inst_pty_id
    AND   ((active_end_date is null ) OR
           (active_end_date > sysdate));
    RETURN l_obj_ver_num;
  EXCEPTION
    WHEN no_data_found THEN
      fnd_message.set_name('CSI','CSI_INT_INST_PTY_MISSING');
      fnd_message.set_token('INSTANCE_PARTY_ID',p_inst_pty_id);
      fnd_msg_pub.add;
      l_obj_ver_num := -1;
      RETURN l_obj_ver_num;
  END get_pty_obj_ver_num;

  FUNCTION get_acct_obj_ver_num(
    p_ip_acct_id  IN NUMBER)
  RETURN NUMBER
  IS
    l_obj_ver_num NUMBER;
  BEGIN
    api_log('get_acct_obj_ver_num');

    SELECT object_version_number
    INTO   l_obj_ver_num
    FROM   csi_ip_accounts
    WHERE  ip_account_id  = p_ip_acct_id
    AND   ((active_end_date is null ) OR
           (active_end_date > sysdate));
    RETURN l_obj_ver_num;
  EXCEPTION
    WHEN no_data_found THEN
      fnd_message.set_name('CSI','CSI_INT_INV_IP_ACCT_ID');
      fnd_message.set_token('IP_ACCOUNT_ID',p_ip_acct_id);
      fnd_msg_pub.add;
      l_obj_ver_num := -1;
      RETURN l_obj_ver_num;
    WHEN others THEN
      fnd_message.set_name('CSI','CSI_INT_INV_IP_ACCT_ID');
      fnd_message.set_token('IP_ACCOUNT_ID',p_ip_acct_id);
      fnd_msg_pub.add;
      l_obj_ver_num := -1;
      RETURN l_obj_ver_num;
  END get_acct_obj_ver_num;

  PROCEDURE get_dflt_sub_type_id(
    p_transaction_type_id  IN         number,
    x_sub_type_id          OUT NOCOPY number,
    x_return_status        OUT NOCOPY varchar2)
  IS
  BEGIN

    api_log('get_dflt_sub_type_id');

    x_return_status := fnd_api.g_ret_sts_success;

    SELECT sub_type_id
    INTO   x_sub_type_id
    FROM   csi_source_ib_types
    WHERE  transaction_type_id    = p_transaction_type_id
    AND    nvl(default_flag, 'N') = 'Y';

    debug('  default sub type id : '||x_sub_type_id);

  EXCEPTION

    WHEN no_data_found THEN
      fnd_message.set_name('CSI', 'CSI_DFLT_SUB_TYPE_MISSING');
      fnd_message.set_token('TXN_TYPE_ID', p_transaction_type_id);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN too_many_rows THEN
      fnd_message.set_name('CSI', 'CSI_MANY_DFLT_SUB_TYPES');
      fnd_message.set_token('TXN_TYPE_ID', p_transaction_type_id);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
  END get_dflt_sub_type_id;

  PROCEDURE get_dflt_inst_status_id(
    x_instance_status_id  OUT NOCOPY number,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_status_name         varchar2(80);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    l_status_name := fnd_profile.value('CSI_DEFAULT_INSTANCE_STATUS');

    SELECT instance_status_id
    INTO   x_instance_status_id
    FROM   csi_instance_statuses
    WHERE  name = l_status_name;

  EXCEPTION
    WHEN no_data_found THEN
      fnd_message.set_name('CSI','CSI_API_INVALID_STATUS_ID');
      fnd_message.set_token('INSTANCE_STATUS', l_status_name);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN too_many_rows THEN
      fnd_message.set_name('CSI','CSI_API_INVALID_STATUS_ID');
      fnd_message.set_token('INSTANCE_STATUS', l_status_name);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
  END get_dflt_inst_status_id;

  FUNCTION get_primay_uom(
    p_inv_item_id IN NUMBER,
    p_inv_org_id  IN NUMBER)
  RETURN VARCHAR2
  IS
    l_uom_code VARCHAR2(30);
  BEGIN

    api_log('get_primay_uom');

    SELECT primary_uom_code
    INTO   l_uom_code
    FROM   mtl_system_items
    WHERE  inventory_item_id = p_inv_item_id
    AND    organization_id   = p_inv_org_id;

    RETURN l_uom_code;

  EXCEPTION
    WHEN no_data_found THEN
      fnd_message.set_name('CSI','CSI_INT_INV_ITEM_ID');
      fnd_message.set_token('INVENTORY_ITEM_ID',p_inv_item_id);
      fnd_message.set_token('INV_ORGANIZATION_ID',p_inv_org_id);
      fnd_msg_pub.add;
      l_uom_code := '';
      RETURN l_uom_code;
  END get_primay_uom;

  FUNCTION Check_relation_exists(
    p_txn_ii_rltns_tbl   IN csi_t_datastructures_grp.txn_ii_rltns_tbl,
    p_txn_line_detail_id IN NUMBER)
  RETURN BOOLEAN
  IS
    l_ret_flag BOOLEAN := FALSE;
  BEGIN

    api_log('check_relation_exists');

    IF p_txn_ii_rltns_tbl.count > 0 THEN
      FOR i in p_txn_ii_rltns_tbl.first..p_txn_ii_rltns_tbl.last loop

        debug('Object ID : '||p_txn_ii_rltns_tbl(i).object_id);
        debug('Subject ID: '||p_txn_ii_rltns_tbl(i).subject_id);
        debug('Rltns Code: '||p_txn_ii_rltns_tbl(i).relationship_type_code);


        IF ((p_txn_ii_rltns_tbl(i).subject_type = 'T'
		AND p_txn_ii_rltns_tbl(i).subject_id = p_txn_line_detail_id )
             OR
            (p_txn_ii_rltns_tbl(i).object_type = 'T'
		AND p_txn_ii_rltns_tbl(i).object_id = p_txn_line_detail_id ))
            AND
            (p_txn_ii_rltns_tbl(i).relationship_type_code in
                     ('COMPONENT-OF', 'REPLACED-BY', 'REPLACEMENT-FOR', 'UPGRADED-FROM') )
        THEN
          l_ret_flag := TRUE;
          exit;
        END IF;
      END LOOP;
    END IF;

    RETURN l_ret_flag;

  END Check_relation_exists;

  PROCEDURE Get_pricing_attribs(
    p_line_id               IN NUMBER,
    x_pricing_attb_tbl      IN OUT NOCOPY     csi_datastructures_pub.pricing_attribs_tbl,
    x_return_status         OUT NOCOPY VARCHAR2)
  IS
    l_index  NUMBER := 1;
    CURSOR Pric_attrib IS
      SELECT PRICING_CONTEXT,
             PRICING_ATTRIBUTE1,
             PRICING_ATTRIBUTE2,
             PRICING_ATTRIBUTE3,
             PRICING_ATTRIBUTE4,
             PRICING_ATTRIBUTE5,
             PRICING_ATTRIBUTE6,
             PRICING_ATTRIBUTE7,
             PRICING_ATTRIBUTE8,
             PRICING_ATTRIBUTE9,
             PRICING_ATTRIBUTE10,
             PRICING_ATTRIBUTE11,
             PRICING_ATTRIBUTE12,
             PRICING_ATTRIBUTE13,
             PRICING_ATTRIBUTE14,
             PRICING_ATTRIBUTE15,
             PRICING_ATTRIBUTE16,
             PRICING_ATTRIBUTE17,
             PRICING_ATTRIBUTE18,
             PRICING_ATTRIBUTE19,
             PRICING_ATTRIBUTE20,
             PRICING_ATTRIBUTE21,
             PRICING_ATTRIBUTE22,
             PRICING_ATTRIBUTE23,
             PRICING_ATTRIBUTE24,
             PRICING_ATTRIBUTE25,
             PRICING_ATTRIBUTE26,
             PRICING_ATTRIBUTE27,
             PRICING_ATTRIBUTE28,
             PRICING_ATTRIBUTE29,
             PRICING_ATTRIBUTE30,
             PRICING_ATTRIBUTE31,
             PRICING_ATTRIBUTE32,
             PRICING_ATTRIBUTE33,
             PRICING_ATTRIBUTE34,
             PRICING_ATTRIBUTE35,
             PRICING_ATTRIBUTE36,
             PRICING_ATTRIBUTE37,
             PRICING_ATTRIBUTE38,
             PRICING_ATTRIBUTE39,
             PRICING_ATTRIBUTE40,
             PRICING_ATTRIBUTE41,
             PRICING_ATTRIBUTE42,
             PRICING_ATTRIBUTE43,
             PRICING_ATTRIBUTE44,
             PRICING_ATTRIBUTE45,
             PRICING_ATTRIBUTE46,
             PRICING_ATTRIBUTE47,
             PRICING_ATTRIBUTE48,
             PRICING_ATTRIBUTE49,
             PRICING_ATTRIBUTE50,
             PRICING_ATTRIBUTE51,
             PRICING_ATTRIBUTE52,
             PRICING_ATTRIBUTE53,
             PRICING_ATTRIBUTE54,
             PRICING_ATTRIBUTE55,
             PRICING_ATTRIBUTE56,
             PRICING_ATTRIBUTE57,
             PRICING_ATTRIBUTE58,
             PRICING_ATTRIBUTE59,
             PRICING_ATTRIBUTE60,
             PRICING_ATTRIBUTE61,
             PRICING_ATTRIBUTE62,
             PRICING_ATTRIBUTE63,
             PRICING_ATTRIBUTE64,
             PRICING_ATTRIBUTE65,
             PRICING_ATTRIBUTE66,
             PRICING_ATTRIBUTE67,
             PRICING_ATTRIBUTE68,
             PRICING_ATTRIBUTE69,
             PRICING_ATTRIBUTE70,
             PRICING_ATTRIBUTE71,
             PRICING_ATTRIBUTE72,
             PRICING_ATTRIBUTE73,
             PRICING_ATTRIBUTE74,
             PRICING_ATTRIBUTE75,
             PRICING_ATTRIBUTE76,
             PRICING_ATTRIBUTE77,
             PRICING_ATTRIBUTE78,
             PRICING_ATTRIBUTE79,
             PRICING_ATTRIBUTE80,
             PRICING_ATTRIBUTE81,
             PRICING_ATTRIBUTE82,
             PRICING_ATTRIBUTE83,
             PRICING_ATTRIBUTE84,
             PRICING_ATTRIBUTE85,
             PRICING_ATTRIBUTE86,
             PRICING_ATTRIBUTE87,
             PRICING_ATTRIBUTE88,
             PRICING_ATTRIBUTE89,
             PRICING_ATTRIBUTE90,
             PRICING_ATTRIBUTE91,
             PRICING_ATTRIBUTE92,
             PRICING_ATTRIBUTE93,
             PRICING_ATTRIBUTE94,
             PRICING_ATTRIBUTE95,
             PRICING_ATTRIBUTE96,
             PRICING_ATTRIBUTE97,
             PRICING_ATTRIBUTE98,
             PRICING_ATTRIBUTE99,
             PRICING_ATTRIBUTE100
      FROM   OE_ORDER_PRICE_ATTRIBS
      WHERE  LINE_ID = p_line_id
      AND    FLEX_TITLE='QP_ATTR_DEFNS_PRICING'; -- Fix for bug 4151459

  BEGIN

    api_log('get_pricing_attribs');
    -- delate the pricing attribute table
    x_pricing_attb_tbl.delete;

    -- Build the  pricing attribute table
    FOR C1 IN Pric_attrib LOOP
      x_pricing_attb_tbl(l_index).PRICING_CONTEXT    := C1.PRICING_CONTEXT ;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE1 := C1.PRICING_ATTRIBUTE1;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE2 := C1.PRICING_ATTRIBUTE2;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE3 := C1.PRICING_ATTRIBUTE3;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE4 := C1.PRICING_ATTRIBUTE4;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE5 := C1.PRICING_ATTRIBUTE5;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE6 := C1.PRICING_ATTRIBUTE6;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE7 := C1.PRICING_ATTRIBUTE7;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE8 := C1.PRICING_ATTRIBUTE8;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE9 := C1.PRICING_ATTRIBUTE9;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE10 := C1.PRICING_ATTRIBUTE10;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE11 := C1.PRICING_ATTRIBUTE11;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE12 := C1.PRICING_ATTRIBUTE12;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE13 := C1.PRICING_ATTRIBUTE13;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE14 := C1.PRICING_ATTRIBUTE14;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE15 := C1.PRICING_ATTRIBUTE15;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE16 := C1.PRICING_ATTRIBUTE16;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE17 := C1.PRICING_ATTRIBUTE17;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE18 := C1.PRICING_ATTRIBUTE18;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE19 := C1.PRICING_ATTRIBUTE19;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE20 := C1.PRICING_ATTRIBUTE20;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE21 := C1.PRICING_ATTRIBUTE21;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE22 := C1.PRICING_ATTRIBUTE22;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE23 := C1.PRICING_ATTRIBUTE23;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE24 := C1.PRICING_ATTRIBUTE24;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE25 := C1.PRICING_ATTRIBUTE25;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE26 := C1.PRICING_ATTRIBUTE26;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE27 := C1.PRICING_ATTRIBUTE27;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE28 := C1.PRICING_ATTRIBUTE28;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE29 := C1.PRICING_ATTRIBUTE29;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE30 := C1.PRICING_ATTRIBUTE30;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE31 := C1.PRICING_ATTRIBUTE31;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE32 := C1.PRICING_ATTRIBUTE32;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE33 := C1.PRICING_ATTRIBUTE33;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE34 := C1.PRICING_ATTRIBUTE34;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE35 := C1.PRICING_ATTRIBUTE35;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE36 := C1.PRICING_ATTRIBUTE36;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE37 := C1.PRICING_ATTRIBUTE37;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE38 := C1.PRICING_ATTRIBUTE38;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE39 := C1.PRICING_ATTRIBUTE39;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE40 := C1.PRICING_ATTRIBUTE40;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE41 := C1.PRICING_ATTRIBUTE41;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE42 := C1.PRICING_ATTRIBUTE42;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE43 := C1.PRICING_ATTRIBUTE43;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE44 := C1.PRICING_ATTRIBUTE44;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE45 := C1.PRICING_ATTRIBUTE45;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE46 := C1.PRICING_ATTRIBUTE46;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE47 := C1.PRICING_ATTRIBUTE47;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE48 := C1.PRICING_ATTRIBUTE48;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE49 := C1.PRICING_ATTRIBUTE49;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE50 := C1.PRICING_ATTRIBUTE50;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE51 := C1.PRICING_ATTRIBUTE51;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE52 := C1.PRICING_ATTRIBUTE52;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE53 := C1.PRICING_ATTRIBUTE53;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE54 := C1.PRICING_ATTRIBUTE54;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE55 := C1.PRICING_ATTRIBUTE55;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE56 := C1.PRICING_ATTRIBUTE56;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE57 := C1.PRICING_ATTRIBUTE57;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE58 := C1.PRICING_ATTRIBUTE58;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE59 := C1.PRICING_ATTRIBUTE59;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE60 := C1.PRICING_ATTRIBUTE60;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE61 := C1.PRICING_ATTRIBUTE61;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE62 := C1.PRICING_ATTRIBUTE62;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE63 := C1.PRICING_ATTRIBUTE63;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE64 := C1.PRICING_ATTRIBUTE64;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE65 := C1.PRICING_ATTRIBUTE65;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE66 := C1.PRICING_ATTRIBUTE66;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE67 := C1.PRICING_ATTRIBUTE67;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE68 := C1.PRICING_ATTRIBUTE68;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE69 := C1.PRICING_ATTRIBUTE69;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE70 := C1.PRICING_ATTRIBUTE70;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE71 := C1.PRICING_ATTRIBUTE71;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE72 := C1.PRICING_ATTRIBUTE72;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE73 := C1.PRICING_ATTRIBUTE73;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE74 := C1.PRICING_ATTRIBUTE74;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE75 := C1.PRICING_ATTRIBUTE75;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE76 := C1.PRICING_ATTRIBUTE76;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE77 := C1.PRICING_ATTRIBUTE77;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE78 := C1.PRICING_ATTRIBUTE78;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE79 := C1.PRICING_ATTRIBUTE79;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE80 := C1.PRICING_ATTRIBUTE80;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE81 := C1.PRICING_ATTRIBUTE81;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE82 := C1.PRICING_ATTRIBUTE82;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE83 := C1.PRICING_ATTRIBUTE83;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE84 := C1.PRICING_ATTRIBUTE84;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE85 := C1.PRICING_ATTRIBUTE85;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE86 := C1.PRICING_ATTRIBUTE86;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE87 := C1.PRICING_ATTRIBUTE87;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE88 := C1.PRICING_ATTRIBUTE88;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE89 := C1.PRICING_ATTRIBUTE89;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE90 := C1.PRICING_ATTRIBUTE90;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE91 := C1.PRICING_ATTRIBUTE91;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE92 := C1.PRICING_ATTRIBUTE92;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE93 := C1.PRICING_ATTRIBUTE93;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE94 := C1.PRICING_ATTRIBUTE94;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE95 := C1.PRICING_ATTRIBUTE95;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE96 := C1.PRICING_ATTRIBUTE96;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE97 := C1.PRICING_ATTRIBUTE97;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE98 := C1.PRICING_ATTRIBUTE98;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE99 := C1.PRICING_ATTRIBUTE99;
      x_pricing_attb_tbl(l_index).PRICING_ATTRIBUTE100 := C1.PRICING_ATTRIBUTE100;

      l_index := l_index +1;
    END LOOP;

  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END get_pricing_attribs;

  PROCEDURE split_ship_rec(
    x_upd_txn_line_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_line_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_line_detail_rec     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    p_txn_sub_type_rec        IN csi_order_ship_pub.txn_sub_type_rec,
    p_order_shipment_rec      IN csi_order_ship_pub.order_shipment_rec,
    p_order_line_rec          IN csi_order_ship_pub.order_line_rec,
    p_proc_qty                IN NUMBER,
    x_return_status           OUT NOCOPY VARCHAR2)
  IS

    l_index         NUMBER := 0;
    l_ip_account_id NUMBER;
    l_instance_id   NUMBER;
    l_inst_party_id NUMBER;
    l_rem_qty_to_proc  NUMBER;
    l_upd_index     binary_integer;
    l_party_site_id NUMBER;
    x_msg_count     NUMBER;
    x_msg_data      VARCHAR2(2000);

    x_txn_line_dtl_rec            csi_t_datastructures_grp.txn_line_detail_rec;
    x_txn_party_dtl_tbl           csi_t_datastructures_grp.txn_party_detail_tbl ;
    x_txn_pty_acct_dtl_tbl        csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    x_txn_org_assgn_tbl           csi_t_datastructures_grp.txn_org_assgn_tbl;
    x_txn_ext_attrib_vals_tbl     csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    x_txn_ii_rltns_tbl            csi_t_datastructures_grp.txn_ii_rltns_tbl;

    l_install_party_site_id  NUMBER;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('split_ship_rec');

    l_rem_qty_to_proc  := p_proc_qty;
    l_upd_index    := x_upd_txn_line_dtl_tbl.count +1;

    debug('p_order_shipment_rec.instance_id ='||p_order_shipment_rec.instance_id);

    IF x_txn_line_detail_tbl.count > 0 THEN
      FOR j in x_txn_line_detail_tbl.first..x_txn_line_detail_tbl.last Loop
        IF x_txn_line_detail_tbl(j).processing_status = 'INST_MATCH' AND
           x_txn_line_detail_tbl(j).instance_id = p_order_shipment_rec.instance_id AND
           l_rem_qty_to_proc > 0
        THEN

          x_upd_txn_line_dtl_tbl(l_upd_index).txn_line_detail_id := x_txn_line_detail_tbl(j).txn_line_detail_id;
          x_upd_txn_line_dtl_tbl(l_upd_index).preserve_detail_flag := 'Y' ;
          x_upd_txn_line_dtl_tbl(l_upd_index).processing_status := 'IN_PROCESS';
          x_upd_txn_line_dtl_tbl(l_upd_index).serial_number     := x_txn_line_detail_tbl(j).serial_number;
          x_upd_txn_line_dtl_tbl(l_upd_index).inv_organization_id  := p_order_shipment_rec.organization_id;

          debug('Txn_line_detail_id ='||x_upd_txn_line_dtl_tbl(l_upd_index).txn_line_detail_id);
          debug('Txn instance_id    ='||x_txn_line_detail_tbl(j).instance_id);
          l_rem_qty_to_proc := l_rem_qty_to_proc- x_txn_line_detail_tbl(j).quantity;
          l_upd_index := l_upd_index +1;

        END IF;
      END LOOP;
    END IF;

    IF l_rem_qty_to_proc > 0  THEN

      l_index  := l_index +1 ;

      debug('For the remaining qty, Creating transaction details. ');

      l_instance_id := p_order_shipment_rec.instance_id;

      x_txn_line_dtl_rec := x_txn_line_detail_rec ;

      /* assign values for the columns in Txn_line_details_tbl */
      x_txn_line_dtl_rec.txn_line_detail_id      := FND_API.G_MISS_NUM;
      x_txn_line_dtl_rec.instance_id             := l_instance_id;
      x_txn_line_dtl_rec.instance_exists_flag    := 'Y';
      x_txn_line_dtl_rec.source_transaction_flag := 'Y';
      x_txn_line_dtl_rec.inventory_item_id       := p_order_shipment_rec.inventory_item_id  ;
      x_txn_line_dtl_rec.inv_organization_id     := p_order_shipment_rec.organization_id  ;
      x_txn_line_dtl_rec.inventory_revision      := p_order_shipment_rec.revision  ;
      x_txn_line_dtl_rec.item_condition_id       := fnd_api.g_miss_num;
      x_txn_line_dtl_rec.instance_type_code      := fnd_api.g_miss_char;
      x_txn_line_dtl_rec.quantity                := l_rem_qty_to_proc;
      x_txn_line_dtl_rec.unit_of_measure         := p_order_shipment_rec.transaction_uom ;
      x_txn_line_dtl_rec.serial_number           := p_order_shipment_rec.serial_number;
      x_txn_line_dtl_rec.processing_status       := 'IN_PROCESS';

      IF p_order_line_rec.serial_code <> 1   Then
        x_txn_line_dtl_rec.mfg_serial_number_flag  := 'Y';
      ELSE
        x_txn_line_dtl_rec.mfg_serial_number_flag  := 'N';
      END IF;

      BEGIN
        SELECT party_site_id
        INTO   l_party_site_id
        FROM   hz_cust_acct_sites_all c,
               hz_cust_site_uses_all u
        WHERE  c.cust_acct_site_id = u.cust_acct_site_id
        AND    u.site_use_id = p_order_shipment_rec.ib_current_loc_id; -- ship_to_org_id;
      EXCEPTION
        WHEN no_data_found THEN
          fnd_message.set_name('CSI','CSI_INT_PTY_SITE_MISSING');
          fnd_message.set_token('LOCATION_ID', p_order_shipment_rec.ib_current_loc_id); -- ship_to_org_id);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        WHEN too_many_rows THEN
          fnd_message.set_name('CSI','CSI_INT_MANY_PTY_SITE_FOUND');
          fnd_message.set_token('LOCATION_ID', p_order_shipment_rec.ib_current_loc_id); -- ship_to_org_id);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
      END ;

      IF p_order_shipment_rec.ib_install_loc is not null
        AND
         p_order_shipment_rec.ib_install_loc_id is not null
        AND
         p_order_shipment_rec.ib_install_loc_id <> fnd_api.g_miss_num
      Then
       BEGIN
         SELECT party_site_id
         INTO   l_install_party_site_id
         FROM   hz_cust_acct_sites_all c,
                hz_cust_site_uses_all u
         WHERE  c.cust_acct_site_id = u.cust_acct_site_id
         AND    u.site_use_id = p_order_shipment_rec.ib_install_loc_id; -- ship_to_org_id;
       Exception
         When no_data_found then
           fnd_message.set_name('CSI','CSI_INT_PTY_SITE_MISSING');
           fnd_message.set_token('LOCATION_ID', p_order_shipment_rec.ib_install_loc_id); -- ship_to_org_id);
           fnd_msg_pub.add;
           debug('Party_site_id not found');
           raise fnd_api.g_exc_error;
         when too_many_rows then
           fnd_message.set_name('CSI','CSI_INT_MANY_PTY_SITE_FOUND');
           fnd_message.set_token('LOCATION_ID', p_order_shipment_rec.ib_install_loc_id); -- ship_to_org_id);
           fnd_msg_pub.add;
           debug('Party_site_id not found');
           raise fnd_api.g_exc_error;
        end ;
       END IF;

      x_txn_line_dtl_rec.lot_number              := p_order_shipment_rec.lot_number;
      x_txn_line_dtl_rec.location_type_code      := 'HZ_PARTY_SITES';
      x_txn_line_dtl_rec.location_id             := l_party_site_id;
      -- Added for partner ordering
      x_txn_line_dtl_rec.install_location_type_code := x_txn_line_dtl_rec.location_type_code;
      x_txn_line_dtl_rec.install_location_id   := l_install_party_site_id;
      -- End for Partner Ordering
      x_txn_line_dtl_rec.sellable_flag           := 'Y';
      x_txn_line_dtl_rec.active_start_date       := sysdate;
      x_txn_line_dtl_rec.object_version_number   := 1  ;
      x_txn_line_dtl_rec.preserve_detail_flag    := 'Y';

      l_inst_party_id := csi_utl_pkg.get_instance_party_id(l_instance_id);
      IF l_inst_party_id = -1 THEN
        debug('get_instance_party_id failed');
        RAISE fnd_api.g_exc_error;
      END IF;

      -- assign values for the columns in x_txn_party_dtl_tbl
      x_txn_party_dtl_tbl(l_index).instance_party_id      := l_inst_party_id;
      x_txn_party_dtl_tbl(l_index).party_source_id        := p_order_shipment_rec.party_id;
      x_txn_party_dtl_tbl(l_index).party_source_table     := 'HZ_PARTIES';
      x_txn_party_dtl_tbl(l_index).relationship_type_code := 'OWNER';
      x_txn_party_dtl_tbl(l_index).contact_flag           := 'N';
      x_txn_party_dtl_tbl(l_index).active_start_date      := sysdate;
      x_txn_party_dtl_tbl(l_index).preserve_detail_flag   := 'Y';
      x_txn_party_dtl_tbl(l_index).object_version_number  := 1;
      x_txn_party_dtl_tbl(l_index).txn_line_details_index := l_index;

      /* get ip_account_id only if inst_party_id does not exist */

      IF l_inst_party_id is not null THEN
        l_ip_account_id := csi_utl_pkg.get_ip_account_id(l_inst_party_id);
        IF l_ip_account_id = -1 THEN
          l_ip_account_id := NULL;
          debug('Party account not found for instance ');
        END IF;
      END IF;

      -- assign values for the columns in txn_pty_acct_dtl_tbl
      x_txn_pty_acct_dtl_tbl(l_index).ip_account_id          := l_ip_account_id;
      x_txn_pty_acct_dtl_tbl(l_index).account_id             := p_order_shipment_rec.party_account_id;
      x_txn_pty_acct_dtl_tbl(l_index).bill_to_address_id     := p_order_shipment_rec.invoice_to_org_id;
      x_txn_pty_acct_dtl_tbl(l_index).ship_to_address_id     := p_order_shipment_rec.ship_to_org_id;
      x_txn_pty_acct_dtl_tbl(l_index).relationship_type_code := 'OWNER';
      x_txn_pty_acct_dtl_tbl(l_index).active_start_date      := sysdate;
      x_txn_pty_acct_dtl_tbl(l_index).preserve_detail_flag   := 'Y';
      x_txn_pty_acct_dtl_tbl(l_index).object_version_number  := 1;
      x_txn_pty_acct_dtl_tbl(l_index).txn_party_details_index := l_index;

      -- assign values for the columns in x_txn_org_assgn_tbl
      IF nvl(p_order_shipment_rec.sold_from_org_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
        x_txn_org_assgn_tbl(l_index).txn_operating_unit_id  := fnd_api.g_miss_num;
        x_txn_org_assgn_tbl(l_index).txn_line_detail_id     := fnd_api.g_miss_num;
        x_txn_org_assgn_tbl(l_index).instance_ou_id         := fnd_api.g_miss_num;
        x_txn_org_assgn_tbl(l_index).operating_unit_id      := p_order_shipment_rec.sold_from_org_id;
        x_txn_org_assgn_tbl(l_index).relationship_type_code := 'SOLD_FROM';
        x_txn_org_assgn_tbl(l_index).active_start_date      := sysdate;
        x_txn_org_assgn_tbl(l_index).preserve_detail_flag   := 'Y';
        x_txn_org_assgn_tbl(l_index).txn_line_details_index := l_index;
        x_txn_org_assgn_tbl(l_index).object_version_number  := 1;
      END IF;

      -- call api to create the transaction line details
      csi_t_txn_line_dtls_pvt.create_txn_line_dtls(
        p_api_version               => 1.0 ,
        p_commit                    => fnd_api.g_false,
        p_init_msg_list             => fnd_api.g_true,
        p_validation_level          => fnd_api.g_valid_level_none,
        p_txn_line_dtl_index        => l_index,
        p_txn_line_dtl_rec          => x_txn_line_dtl_rec,
        px_txn_party_dtl_tbl        => x_txn_party_dtl_tbl,
        px_txn_pty_acct_detail_tbl  => x_txn_pty_acct_dtl_tbl,
        px_txn_ii_rltns_tbl         => x_txn_ii_rltns_tbl,
        px_txn_org_assgn_tbl        => x_txn_org_assgn_tbl,
        px_txn_ext_attrib_vals_tbl  => x_txn_ext_attrib_vals_tbl,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        raise fnd_api.g_exc_error;
      END IF;

    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
  END split_ship_rec;

  PROCEDURE create_txn_details(
    x_txn_line_dtl_rec        IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    p_txn_sub_type_rec        IN csi_order_ship_pub.txn_sub_type_rec,
    p_order_shipment_rec      IN csi_order_ship_pub.order_shipment_rec,
    p_order_line_rec          IN csi_order_ship_pub.order_line_rec,
    x_return_status           OUT NOCOPY VARCHAR2)
  IS
    l_index         NUMBER := 0;
    l_ip_account_id NUMBER;
    l_instance_id   NUMBER;
    l_inst_party_id NUMBER;
    l_ind_pty       NUMBER;
    l_ind_acct      NUMBER;
    l_ind_org       NUMBER;
    l_party_site_id NUMBER;
    x_msg_data      VARCHAR2(2000);
    x_msg_count     NUMBER;

    x_txn_party_dtl_tbl           csi_t_datastructures_grp.txn_party_detail_tbl ;
    x_txn_pty_acct_dtl_tbl        csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    x_txn_org_assgn_tbl           csi_t_datastructures_grp.txn_org_assgn_tbl;
    x_txn_ext_attrib_vals_tbl     csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    x_txn_ii_rltns_tbl            csi_t_datastructures_grp.txn_ii_rltns_tbl;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('create_txn_details');

    x_txn_line_dtl_rec := x_txn_line_dtl_rec;

    l_index := l_index + 1;

    l_instance_id := p_order_shipment_rec.instance_id;

    /* assign values for the columns in Txn_line_details_tbl */
    x_txn_line_dtl_rec.txn_line_detail_id      := FND_API.G_MISS_NUM;
    x_txn_line_dtl_rec.instance_id             := l_instance_id;
    x_txn_line_dtl_rec.instance_exists_flag    := 'Y';
    x_txn_line_dtl_rec.source_transaction_flag := 'Y';
    x_txn_line_dtl_rec.sub_type_id             := p_txn_sub_type_rec.sub_type_id;
    x_txn_line_dtl_rec.inventory_item_id       := p_order_shipment_rec.inventory_item_id  ;
    x_txn_line_dtl_rec.inv_organization_id     := p_order_shipment_rec.organization_id  ;
    x_txn_line_dtl_rec.inventory_revision      := p_order_shipment_rec.revision  ;
    x_txn_line_dtl_rec.item_condition_id       := fnd_api.g_miss_num;
    x_txn_line_dtl_rec.instance_type_code      := fnd_api.g_miss_char;
    x_txn_line_dtl_rec.quantity                := p_order_shipment_rec.shipped_quantity  ;
    x_txn_line_dtl_rec.unit_of_measure         := p_order_shipment_rec.transaction_uom ;
    x_txn_line_dtl_rec.serial_number           := p_order_shipment_rec.serial_number;
    x_txn_line_dtl_rec.processing_status       := 'IN_PROCESS';

    IF p_order_line_rec.serial_code <> 1   Then
      x_txn_line_dtl_rec.mfg_serial_number_flag  := 'Y';
    ELSE
      x_txn_line_dtl_rec.mfg_serial_number_flag  := 'N';
    END IF;

    BEGIN
      SELECT party_site_id
      INTO   l_party_site_id
      FROM   hz_cust_acct_sites_all c,
             hz_cust_site_uses_all u
      WHERE  c.cust_acct_site_id = u.cust_acct_site_id
      AND    u.site_use_id = p_order_shipment_rec.ship_to_org_id;
    EXCEPTION
      WHEN no_data_found then
        fnd_message.set_name('CSI','CSI_INT_PTY_SITE_MISSING');
        fnd_message.set_token('LOCATION_ID', p_order_shipment_rec.ship_to_org_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      WHEN too_many_rows then
        fnd_message.set_name('CSI','CSI_INT_MANY_PTY_SITE_FOUND');
        fnd_message.set_token('LOCATION_ID', p_order_shipment_rec.ship_to_org_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;

    x_txn_line_dtl_rec.lot_number              := p_order_shipment_rec.lot_number;
    x_txn_line_dtl_rec.location_type_code      := 'HZ_PARTY_SITES';
    x_txn_line_dtl_rec.location_id             := l_party_site_id;
    x_txn_line_dtl_rec.sellable_flag           := 'Y';
    x_txn_line_dtl_rec.active_start_date       := sysdate;
    x_txn_line_dtl_rec.object_version_number   := 1  ;
    x_txn_line_dtl_rec.preserve_detail_flag    := 'Y';

    l_inst_party_id := csi_utl_pkg.get_instance_party_id(l_instance_id);

    IF l_inst_party_id = -1 THEN
      debug('get_instance_party_id failed');
      RAISE fnd_api.g_exc_error;
    END IF;

    -- assign values for the columns in txn_party_detail_tbl
    x_txn_party_dtl_tbl(l_index).instance_party_id      := l_inst_party_id;
    x_txn_party_dtl_tbl(l_index).party_source_id        := p_order_shipment_rec.party_id;
    x_txn_party_dtl_tbl(l_index).party_source_table     := 'HZ_PARTIES';
    x_txn_party_dtl_tbl(l_index).relationship_type_code := 'OWNER';
    x_txn_party_dtl_tbl(l_index).contact_flag           := 'N';
    x_txn_party_dtl_tbl(l_index).active_start_date      := sysdate;
    x_txn_party_dtl_tbl(l_index).preserve_detail_flag   := 'Y';
    x_txn_party_dtl_tbl(l_index).object_version_number  := 1;
    x_txn_party_dtl_tbl(l_index).txn_line_details_index := l_index;

    /* get ip_account_id only if inst_party_id does not exist */

    IF l_inst_party_id is not null THEN
      l_ip_account_id := csi_utl_pkg.get_ip_account_id(l_inst_party_id);

      /* If ip_account_id is -1 then account does not exist in IB */

      IF l_ip_account_id = -1 THEN
        l_ip_account_id := NULL;
        debug('Party account not found for instance ');
      END IF;
    END IF;

    -- assign values for the columns in txn_pty_acct_dtl_tbl
    x_txn_pty_acct_dtl_tbl(l_index).ip_account_id          := l_ip_account_id;
    x_txn_pty_acct_dtl_tbl(l_index).account_id             := p_order_shipment_rec.party_account_id;
    x_txn_pty_acct_dtl_tbl(l_index).bill_to_address_id     := p_order_shipment_rec.invoice_to_org_id;
    x_txn_pty_acct_dtl_tbl(l_index).ship_to_address_id     := p_order_shipment_rec.ship_to_org_id;
    x_txn_pty_acct_dtl_tbl(l_index).relationship_type_code := 'OWNER';
    x_txn_pty_acct_dtl_tbl(l_index).active_start_date      := sysdate;
    x_txn_pty_acct_dtl_tbl(l_index).preserve_detail_flag   := 'Y';
    x_txn_pty_acct_dtl_tbl(l_index).object_version_number  := 1;
    x_txn_pty_acct_dtl_tbl(l_index).txn_party_details_index := l_index;

    IF nvl(p_order_shipment_rec.sold_from_org_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      x_txn_org_assgn_tbl(l_index).txn_operating_unit_id  := fnd_api.g_miss_num;
      x_txn_org_assgn_tbl(l_index).txn_line_detail_id     := fnd_api.g_miss_num;
      x_txn_org_assgn_tbl(l_index).instance_ou_id         := fnd_api.g_miss_num;
      x_txn_org_assgn_tbl(l_index).operating_unit_id      := p_order_shipment_rec.sold_from_org_id;
      x_txn_org_assgn_tbl(l_index).relationship_type_code := 'SOLD_FROM';
      x_txn_org_assgn_tbl(l_index).active_start_date      := sysdate;
      x_txn_org_assgn_tbl(l_index).txn_line_details_index := l_index;
      x_txn_org_assgn_tbl(l_index).preserve_detail_flag   := 'Y';
      x_txn_org_assgn_tbl(l_index).object_version_number  := 1;
    END IF;

    -- call api to create the transaction line details
    csi_t_txn_line_dtls_pvt.create_txn_line_dtls(
      p_api_version               => 1.0 ,
      p_commit                    => fnd_api.g_false,
      p_init_msg_list             => fnd_api.g_true,
      p_validation_level          => fnd_api.g_valid_level_none,
      p_txn_line_dtl_index        => l_index,
      p_txn_line_dtl_rec          => x_txn_line_dtl_rec,
      px_txn_party_dtl_tbl        => x_txn_party_dtl_tbl,
      px_txn_pty_acct_detail_tbl  => x_txn_pty_acct_dtl_tbl,
      px_txn_ii_rltns_tbl         => x_txn_ii_rltns_tbl,
      px_txn_org_assgn_tbl        => x_txn_org_assgn_tbl,
      px_txn_ext_attrib_vals_tbl  => x_txn_ext_attrib_vals_tbl,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data);

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
  END create_txn_details;


  FUNCTION Check_config_exists(
    p_txn_ii_rltns_tbl  IN csi_t_datastructures_grp.txn_ii_rltns_tbl,
    p_txn_detail_id     IN NUMBER)
  RETURN BOOLEAN IS
    l_flag BOOLEAN := FALSE;
  BEGIN

    api_log('check_config_exists');

    IF p_txn_ii_rltns_tbl.count > 0 THEN
      FOR i in p_txn_ii_rltns_tbl.first..p_txn_ii_rltns_tbl.last LOOP
        IF p_txn_ii_rltns_tbl(i).object_id = p_txn_detail_id THEN
          l_flag := TRUE;
        END IF;
      END LOOP;
    END IF;
    RETURN l_flag;

  END Check_config_exists;

  PROCEDURE get_party_id(
    p_cust_acct_id  IN  number,
    x_party_id      OUT NOCOPY number,
    x_return_status OUT NOCOPY varchar2)
  IS
    l_party_id        number;
    l_account_status  hz_cust_accounts.status%type;
  BEGIN

    api_log('get_party_id');

    x_return_status := fnd_api.g_ret_sts_success;

    BEGIN
      SELECT party_id,
             status
      INTO   l_party_id,
             l_account_status
      FROM   hz_cust_accounts
      WHERE  cust_account_id = p_cust_acct_id;

      x_party_id := l_party_id;

      IF l_account_status <> 'A' THEN
        debug('This cust account '||p_cust_acct_id||' has status '||l_account_status);
      END IF;

    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('CSI','CSI_INT_INV_CUST_ACCT_ID');
        fnd_message.set_token('CUST_ACCOUNT_ID', p_cust_acct_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_party_id;


  FUNCTION validate_inst_party(
    p_instance_id   IN NUMBER,
    p_inst_party_id IN NUMBER,
    p_pty_rel_code  IN VARCHAR2)
  RETURN BOOLEAN IS
    l_ret_status BOOLEAN := FALSE;
    l_dummy      VARCHAR2(1);
  BEGIN

    api_log('validate_inst_party');

    SELECT 'x'
    INTO   l_dummy
    FROM   csi_i_parties
    WHERE  instance_id  = p_instance_id
    AND    instance_party_id = p_inst_party_id
    AND    relationship_type_code = p_pty_rel_code
    AND   ((active_end_date is null ) OR
           (active_end_date > sysdate));

    l_ret_status := TRUE;
    RETURN l_ret_status;

  EXCEPTION
    WHEN others THEN
      fnd_message.set_name('CSI','CSI_INT_INV_INST_PTY_ID');
      fnd_message.set_token('INSTANCE_ID', p_instance_id);
      fnd_message.set_token('INSTANCE_PARTY_ID', p_inst_party_id);
      fnd_message.set_token('RELATIONSHIP_TYPE_CODE', p_inst_party_id);
      fnd_msg_pub.add;
      RETURN l_ret_status;
  END validate_inst_party;

  FUNCTION get_instance(
    p_order_line_id IN NUMBER)
  RETURN NUMBER IS
    l_inst_id NUMBER;
  BEGIN

    api_log('get_instance');

    SELECT instance_id
    INTO l_inst_id
    FROM csi_item_instances
    WHERE last_oe_order_line_id = p_order_line_id;

    RETURN l_inst_id;
  EXCEPTION
    WHEN no_data_found THEN
      fnd_message.set_name('CSI','CSI_INT_INV_ORD_LINE_ID');
      fnd_message.set_token('ORDER_LINE_ID', p_order_line_id);
      fnd_msg_pub.add;
      l_inst_id := -1;
      RETURN l_inst_id;
    WHEN others THEN
      fnd_message.set_name('CSI','CSI_INT_INV_ORD_LINE_ID');
      fnd_message.set_token('ORDER_LINE_ID', p_order_line_id);
      fnd_msg_pub.add;
      l_inst_id := -1;
      RETURN l_inst_id;
  END get_instance;

  FUNCTION check_relation_exist(
    p_model_line_id IN NUMBER ,
    p_line_id       IN NUMBER)
  RETURN BOOLEAN IS
    l_dummy VARCHAR2(1);
  BEGIN

    api_log('check_relation_exist');

    SELECT 'x'
    INTO   l_dummy
    FROM   csi_ii_relationships
    WHERE  object_id  =  p_model_line_id
    AND    subject_id =  p_line_id
    AND  ((active_end_date is null ) OR
          (active_end_date > sysdate));

    RETURN TRUE;
  EXCEPTION
    WHEN others THEN
      RETURN FALSE;
  END check_relation_exist;

  FUNCTION get_instance_party_id(
    p_instance_id   IN NUMBER )
  RETURN NUMBER
  IS
    l_inst_party_id NUMBER;
  BEGIN
    api_log('get_instance_party_id');

    SELECT instance_party_id
    INTO   l_inst_party_id
    FROM   csi_i_parties
    WHERE  instance_id = p_instance_id
    AND    relationship_type_code = 'OWNER'
    AND    ((active_end_date is null)
             OR
            (active_end_date >= sysdate));

    debug('  Instance Party ID :'||l_inst_party_id);
    RETURN l_inst_party_id;

  EXCEPTION
    WHEN no_data_found THEN
      fnd_message.set_name('CSI','CSI_INT_INST_OWNER_MISSING');
      fnd_message.set_token('INSTANCE_ID',p_instance_id);
      fnd_msg_pub.add;
      l_inst_party_id := -1;
      RETURN l_inst_party_id;
    -- Added for 3185043
    WHEN too_many_rows THEN
      fnd_message.set_name('CSI','CSI_MANY_INST_OWNER_FOUND');
      fnd_message.set_token('INSTANCE_ID',p_instance_id);
      fnd_msg_pub.add;
      l_inst_party_id := -1;
      RETURN l_inst_party_id;
    WHEN others THEN
      -- fnd_message.set_name('CSI','CSI_INT_INST_OWNER_MISSING');
      -- fnd_message.set_token('INSTANCE_ID',p_instance_id);
      fnd_message.set_name('CSI','CSI_INT_UNEXP_SQL_ERROR');
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      fnd_msg_pub.add;
      l_inst_party_id := -1;
      RETURN l_inst_party_id;
  END get_instance_party_id;

FUNCTION Get_trx_type_id
      (p_trx_line_id IN NUMBER
       ) RETURN NUMBER IS

 l_trx_type_id  NUMBER;

BEGIN

  api_log('Get_trx_type_id');

SELECT source_transaction_type_id
INTO l_trx_type_id
FROM csi_t_transaction_lines
WHERE transaction_line_id = p_trx_line_id;
RETURN l_trx_type_id;

exception
  when others then
        fnd_message.set_name('CSI','CSI_INT_INV_TRX_LINE_ID');
    fnd_message.set_token('TRX_LINE_ID',p_trx_line_id);
    fnd_msg_pub.add;
    l_trx_type_id := -1;
    RETURN l_trx_type_id;

END Get_trx_type_id;

FUNCTION Get_trx_line_id
      (p_src_trx_id IN NUMBER,
       p_src_table_name IN VARCHAR2
       ) RETURN NUMBER IS

 l_trx_line_id  NUMBER;

BEGIN

  api_log('Get_trx_line_id');

SELECT transaction_line_id
INTO  l_trx_line_id
FROM csi_t_transaction_lines
WHERE source_transaction_id = p_src_trx_id
 AND  source_transaction_table = p_src_table_name;
RETURN l_trx_line_id;
exception
 when others then
        fnd_message.set_name('CSI','CSI_INT_INV_SRC_TRX_ID');
    fnd_message.set_token('SOURCE_TRANSACTION_ID',p_src_trx_id);
    fnd_message.set_token('SOURCE_TRANSACTION_TABLE',p_src_table_name);
    fnd_msg_pub.add;
    l_trx_line_id := -1;
    RETURN l_trx_line_id;
END Get_trx_line_id;

FUNCTION get_ip_account_id
 ( p_instance_party_id   IN NUMBER
   )RETURN NUMBER
  IS

l_ip_acct_id  NUMBER;

BEGIN
  api_log('get_ip_account_id');

 SELECT
      ip_account_id
 INTO l_ip_acct_id
 FROM csi_ip_accounts
 WHERE instance_party_id = p_instance_party_id
   AND relationship_type_code = 'OWNER'
   AND ((active_end_date is null)
     OR (active_end_date >= sysdate));
RETURN l_ip_acct_id;
exception
  when others then
        fnd_message.set_name('CSI','CSI_INT_OWNER_ACCT_MISSING');
    fnd_message.set_token('INSTANCE_PARTY_ID',p_instance_party_id);
        fnd_msg_pub.add;
    l_ip_acct_id := -1;
    RETURN l_ip_acct_id;
END get_ip_account_id;

  PROCEDURE get_master_organization
  (p_organization_id          IN  NUMBER,
   p_master_organization_id   OUT NOCOPY NUMBER,
   x_return_status            OUT NOCOPY VARCHAR2
   ) IS

l_fnd_success       VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_fnd_error         VARCHAR2(1) := fnd_api.g_ret_sts_error;
l_fnd_unexpected    VARCHAR2(1) := fnd_api.g_ret_sts_unexp_error;
l_master_org_id     NUMBER;

BEGIN

  api_log('get_master_organization');

  x_return_status := l_fnd_success;

  SELECT master_organization_id
  INTO  p_master_organization_id
  FROM   mtl_parameters
  WHERE  organization_id = p_organization_id;

EXCEPTION
  WHEN no_data_found THEN
     fnd_message.set_name('CSI','CSI_INT_MSTR_ORG_MISSING');
     fnd_message.set_token('ORGANIZATION_ID',p_organization_id);
     fnd_msg_pub.add;
     x_return_status := l_fnd_error;
  WHEN others THEN
     fnd_message.set_name('CSI','CSI_INT_UNEXP_SQL_ERROR');
     fnd_message.set_token('SQL_ERROR',SQLERRM);
     fnd_msg_pub.add;
     x_return_status := l_fnd_unexpected;
END get_master_organization;

PROCEDURE get_int_party
 ( x_int_party_id  OUT NOCOPY NUMBER,
   x_return_status OUT NOCOPY VARCHAR2
   )  is

BEGIN
  api_log('get_int_party');

 x_return_status := fnd_api.g_ret_sts_success;

--commented SQL below to make changes for the bug 4028827
/*
 SELECT internal_party_id
 INTO   x_int_party_id
 FROM   csi_install_parameters;
*/
 x_int_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;

 IF x_int_party_id IS NULL THEN
    fnd_message.set_name('CSI','CSI_INT_INT_PTY_ID_MISSING');
    fnd_msg_pub.add;
    x_return_status  := fnd_api.g_ret_sts_error;
 ELSE
    x_return_status  := fnd_api.g_ret_sts_success;
 END IF;

exception
 when others then
   fnd_message.set_name('CSI','CSI_INT_INT_PTY_ID_MISSING');
   fnd_msg_pub.add;
   x_return_status := fnd_api.g_ret_sts_error;
END get_int_party;

FUNCTION get_serial_contl_code
 ( p_inv_item_id IN NUMBER,
   p_inv_org_id  IN NUMBER)
RETURN NUMBER IS

 l_serial_code       NUMBER;

BEGIN

  api_log('get_serial_contl_code');

 /*----------------------------------------------------------*/
 /* serial number control code                               */
 /* '1' stands for - No serial number control                */
 /* '2' stands for - Predefined serial numbers               */
 /* '5' stands for - Dynamic entry at inventory receipt      */
 /* '6' stands for - Dynamic entry at sales order issue      */
 /*----------------------------------------------------------*/

  SELECT serial_number_control_code
   INTO  l_serial_code
   FROM  mtl_system_items
  WHERE  inventory_item_id = p_inv_item_id
   AND   organization_id = p_inv_org_id;

   RETURN l_serial_code;
exception
  when others then
        fnd_message.set_name('CSI','CSI_INT_ITEM_ID_MISSING');
    fnd_message.set_token('INVENTORY_ITEM_ID',p_inv_item_id);
    fnd_message.set_token('INV_ORGANIZATION_ID',p_inv_org_id);
        fnd_msg_pub.add;
    l_serial_code := -1;
    RETURN  l_serial_code;
END get_serial_contl_code;

  PROCEDURE get_order_line_dtls(
     p_mtl_transaction_id IN NUMBER,
     x_order_line_rec     OUT NOCOPY  csi_order_ship_pub.order_line_rec,
     x_return_status      OUT NOCOPY VARCHAR2)
  IS

    -- Partner Ordering
    l_partner_rec             oe_install_base_util.partner_order_rec;
    l_partner_owner_id        NUMBER;
    l_partner_owner_acct_id   NUMBER;
    l_order_line_rec          csi_order_ship_pub.order_line_rec;

    -- sumathur Added for TSO With Equipment bug 5459427
    l_om_session_key            csi_utility_grp.config_session_key;
    l_macd_processing           BOOLEAN     := FALSE;

  BEGIN
    api_log('get_order_line_dtls');

    x_return_status  := fnd_api.g_ret_sts_success;

    SELECT b.header_id,
           b.line_id,
           mmt.inventory_item_id,
           mmt.organization_id,
           mmt.transaction_date,
           b.ordered_quantity,
           b.shipped_quantity,
           b.top_model_line_id,
           b.ato_line_id,
           b.link_to_line_id,
           NVL(b.invoice_to_org_id,c.invoice_to_org_id) invoice_to_org_id,
           NVL(b.ship_to_org_id,c.ship_to_org_id) ship_to_org_id,
           NVL(b.sold_from_org_id,c.sold_from_org_id) sold_from_org_id ,
           NVL(b.sold_to_org_id,c.sold_to_org_id) sold_to_org_id,
           NVL(b.sold_to_org_id,c.sold_to_org_id) customer_id,
           NVL(b.ship_to_contact_id,c.ship_to_contact_id) ship_to_contact_id,
           NVL(b.invoice_to_contact_id,c.invoice_to_contact_id) invoice_to_contact_id ,
           b.order_quantity_uom  order_quantity_uom,
           b.item_type_code,
           NVL(b.agreement_id, c.agreement_id) agreement_id,
           c.order_number,
           b.line_number||'.'||b.shipment_number||'.'||option_number,
           b.actual_shipment_date actual_shipment_date,
           b.fulfillment_date fulfillment_date,
           b.org_id,
           NVL(b.deliver_to_org_id,c.deliver_to_org_id) deliver_to_org_id,
           b.ordered_item,
           b.config_header_id,
           b.config_rev_nbr,
           b.configuration_id,
           mmt.transaction_action_id,
           mmt.transaction_source_type_id,
           b.unit_selling_price,
           c.transactional_curr_code,
	   NVL(b.model_remnant_flag,'N'),  --4344316
           decode(c.order_source_Id, 28, 'SIEBEL',29,'SIEBEL',null) source_code
    INTO   l_order_line_rec.header_id,
           l_order_line_rec.order_line_id ,
           l_order_line_rec.inv_item_id,
           l_order_line_rec.inv_org_id,
           l_order_line_rec.transaction_date ,
           l_order_line_rec.ordered_quantity,
           l_order_line_rec.shipped_quantity ,
           l_order_line_rec.top_model_line_id,
           l_order_line_rec.ato_line_id,
           l_order_line_rec.link_to_line_id ,
           l_order_line_rec.invoice_to_org_id ,
           l_order_line_rec.ship_to_org_id ,
           l_order_line_rec.sold_from_org_id,
           l_order_line_rec.sold_to_org_id,
           l_order_line_rec.customer_id ,
           l_order_line_rec.ship_to_contact_id ,
           l_order_line_rec.invoice_to_contact_id ,
           l_order_line_rec.order_quantity_uom ,
           l_order_line_rec.item_type_code,
           l_order_line_rec.agreement_id,
           l_order_line_rec.order_number,
           l_order_line_rec.line_number,
           l_order_line_rec.actual_shipment_date,
           l_order_line_rec.fulfillment_date,
           l_order_line_rec.org_id,
           l_order_line_rec.deliver_to_org_id,
           l_order_line_rec.ordered_item,
           l_order_line_rec.config_header_id,
           l_order_line_rec.config_rev_nbr,
           l_order_line_rec.configuration_id,
           l_order_line_rec.mtl_action_id,
           l_order_line_rec.mtl_src_type_id,
           l_order_line_rec.unit_price,
           l_order_line_rec.currency_code,
	   l_order_line_rec.model_remnant_flag, --4344316
           l_order_line_rec.source_code
    FROM   mtl_material_transactions mmt,
           oe_order_lines_all b,
           oe_order_headers_all c
    WHERE  mmt.trx_source_line_id = b.line_id
    AND    b.header_id  = c.header_id
    AND    mmt.transaction_id = p_mtl_transaction_id;

    l_order_line_rec.om_vld_org_id := oe_sys_parameters.value(
                                        param_name => 'MASTER_ORGANIZATION_ID',
                                        p_org_id   => l_order_line_rec.org_id);
    BEGIN
      SELECT party_site_id
      INTO   l_order_line_rec.ship_to_party_site_id
      FROM   hz_cust_acct_sites_all hzcas,
             hz_cust_site_uses_all  hzcsu
      WHERE  hzcsu.site_use_id = l_order_line_rec.ship_to_org_id
      AND    hzcas.cust_acct_site_id = hzcsu.cust_acct_site_id;
    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('CSI','CSI_INT_PTY_SITE_MISSING');
        fnd_message.set_token('LOCATION_ID', l_order_line_rec.ship_to_org_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      WHEN too_many_rows THEN
        fnd_message.set_name('CSI','CSI_INT_MANY_PTY_SITE_FOUND');
        fnd_message.set_token('LOCATION_ID', l_order_line_rec.ship_to_org_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;

    debug('  order_number       : '||l_order_line_rec.order_number);
    debug('  header_id          : '||l_order_line_rec.header_id);
    debug('  line_number        : '||l_order_line_rec.line_number);
    debug('  item_type_code     : '||l_order_line_rec.item_type_code);
    debug('  line_id            : '||l_order_line_rec.order_line_id);
    debug('  inventory_item_id  : '||l_order_line_rec.inv_item_id);
    debug('  ordered_item       : '||l_order_line_rec.ordered_item);
    debug('  shipped_quantity   : '||l_order_line_rec.shipped_quantity);
    debug('  ship_from_org_id   : '||l_order_line_rec.inv_org_id);
    debug('  party_site_id      : '||l_order_line_rec.ship_to_party_site_id);
    debug('  source_code        : '||l_order_line_rec.source_code);

    -- for partner ordering
    oe_install_base_util.get_partner_ord_rec(
      p_order_line_id      => l_order_line_rec.order_line_id,
      x_partner_order_rec  => l_partner_rec);

    IF l_partner_rec.IB_OWNER = 'END_CUSTOMER'
    THEN
      l_order_line_rec.ib_owner := 'END_CUSTOMER';
      IF l_partner_rec.END_CUSTOMER_ID is null Then
         fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
         fnd_msg_pub.add;
         raise fnd_api.g_exc_error;
      ELSE
         l_order_line_rec.end_customer_id := l_partner_rec.end_customer_id;
      END IF;
    ELSIF l_partner_rec.IB_OWNER = 'INSTALL_BASE'
    THEN
      l_order_line_rec.ib_owner         :=  l_partner_rec.IB_OWNER;
      l_order_line_rec.end_customer_id  :=  fnd_api.g_miss_num;
    ELSE
      l_order_line_rec.end_customer_id := l_order_line_rec.sold_to_org_id;
    END IF;

    IF l_partner_rec.IB_INSTALLED_AT_LOCATION is not null
    THEN
      l_order_line_rec.ib_install_loc   := l_partner_rec.IB_INSTALLED_AT_LOCATION;
      IF l_order_line_rec.ib_install_loc = 'END_CUSTOMER'
      THEN
        IF l_partner_rec.end_customer_site_use_id is null
        THEN
          fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
        ELSE
          l_order_line_rec.ib_install_loc_id :=  l_partner_rec.end_customer_site_use_id;
        END IF;
      ELSIF l_order_line_rec.ib_install_loc = 'SHIP_TO'
      THEN
        IF  l_order_line_rec.ship_to_org_id is null
        THEN
          fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
        ELSE
          l_order_line_rec.ib_install_loc_id := l_order_line_rec.ship_to_org_id;
        END IF;
      ELSIF  l_order_line_rec.ib_install_loc = 'SOLD_TO'
      THEN
        IF l_partner_rec.SOLD_TO_SITE_USE_ID is null -- 3412544 l_order_line_rec.sold_to_org_id is null
        THEN
          fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
        ELSE
          l_order_line_rec.ib_install_loc_id := l_partner_rec.SOLD_TO_SITE_USE_ID; -- 3412544 l_order_line_rec.sold_to_org_id;
        END IF;
      ELSIF l_order_line_rec.ib_install_loc = 'DELIVER_TO'
      THEN
        IF  l_order_line_rec.deliver_to_org_id is null
        THEN
          fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
        ELSE
          l_order_line_rec.ib_install_loc_id := l_order_line_rec.deliver_to_org_id;
         END IF;
       ELSIF l_order_line_rec.ib_install_loc = 'BILL_TO'
       THEN
         IF l_order_line_rec.invoice_to_org_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
           l_order_line_rec.ib_install_loc_id := l_order_line_rec.invoice_to_org_id;
         END IF;
       ELSIF l_order_line_rec.ib_install_loc = 'INSTALL_BASE'
       THEN
           l_order_line_rec.ib_install_loc_id := fnd_api.g_miss_num;
       END IF;
     ELSE
        l_order_line_rec.ib_install_loc_id := l_order_line_rec.ship_to_org_id;
     END IF;

    IF l_partner_rec.IB_CURRENT_LOCATION is not null
    THEN
       l_order_line_rec.ib_current_loc   := l_partner_rec.IB_CURRENT_LOCATION;
       IF l_order_line_rec.ib_current_loc = 'END_CUSTOMER'
       THEN
         IF  l_partner_rec.end_customer_site_use_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
           l_order_line_rec.ib_current_loc_id :=  l_partner_rec.end_customer_site_use_id;
         END IF;
       ELSIF l_order_line_rec.ib_current_loc = 'SHIP_TO'
       THEN
         IF l_order_line_rec.ship_to_org_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
           l_order_line_rec.ib_current_loc_id := l_order_line_rec.ship_to_org_id;
         END IF;
       ELSIF l_order_line_rec.ib_current_loc = 'SOLD_TO'
       THEN
         IF l_partner_rec.SOLD_TO_SITE_USE_ID is null -- 3412544 l_order_line_rec.sold_to_org_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
           l_order_line_rec.ib_current_loc_id := l_partner_rec.SOLD_TO_SITE_USE_ID; -- 3412544 l_order_line_rec.sold_to_org_id;
         END IF;
       ELSIF l_order_line_rec.ib_current_loc = 'DELIVER_TO'
       THEN
         IF l_order_line_rec.deliver_to_org_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
          l_order_line_rec.ib_current_loc_id := l_order_line_rec.deliver_to_org_id;
         END IF;
       ELSIF l_order_line_rec.ib_current_loc = 'BILL_TO'
       THEN
         IF l_order_line_rec.invoice_to_org_id is null
         THEN
           fnd_message.set_name('CSI','CSI_PARTNER_VAL_MISSING');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
         ELSE
          l_order_line_rec.ib_current_loc_id := l_order_line_rec.invoice_to_org_id;
         END IF;
       ELSIF l_order_line_rec.ib_current_loc = 'INSTALL_BASE'
       THEN
            l_order_line_rec.ib_current_loc_id := fnd_api.g_miss_num;
       END IF;
     ELSE
       l_order_line_rec.ib_current_loc_id := l_order_line_rec.ship_to_org_id;
     END IF;

     IF  NVL(l_order_line_rec.config_header_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
        AND NVL(l_order_line_rec.config_rev_nbr,fnd_api.g_miss_num) <> fnd_api.g_miss_num
	AND NVL(l_order_line_rec.configuration_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
     THEN

      l_om_session_key.session_hdr_id  := l_order_line_rec.config_header_id;
      l_om_session_key.session_rev_num := l_order_line_rec.config_rev_nbr;
      l_om_session_key.session_item_id := l_order_line_rec.configuration_id;
      --
      l_macd_processing := csi_interface_pkg.check_macd_processing
                               ( p_config_session_key => l_om_session_key,
                                 x_return_status      => x_return_status
                               );
      --
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF NOT l_macd_processing THEN
         l_order_line_rec.macd_order_line := fnd_api.g_false ;
      ELSE
         l_order_line_rec.macd_order_line := fnd_api.g_true ;
      END IF;

     END IF;
     x_order_line_rec := l_order_line_rec;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN others THEN
      fnd_message.set_name('CSI','CSI_INT_ORD_LINE_MISSING');
      fnd_message.set_token('MTL_TRANSACTION_ID',p_mtl_transaction_id);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;

  END get_order_line_dtls;

  /* Added p_order_header_id as part of fix for Bug : 2897324 */

  PROCEDURE get_split_order_line(
    p_order_line_id     IN  NUMBER,
    p_order_header_id   IN  NUMBER,
    x_split_ord_line_id OUT NOCOPY NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    api_log('get_split_order_line');
    x_return_status  := fnd_api.g_ret_sts_success;

    /* Added p_order_header_id as part of fix for Bug : 2897324 */

    SELECT line_id
    INTO   x_split_ord_line_id
    FROM   oe_order_lines_all
    WHERE  split_from_line_id = p_order_line_id
    AND    header_id          = p_order_header_id;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status  := fnd_api.g_ret_sts_success;
    WHEN too_many_rows THEN
      x_return_status  := fnd_api.g_ret_sts_success;
    WHEN others THEN
      fnd_message.set_name('CSI','CSI_INT_SPL_ORD_LINE_MISSING');
      fnd_message.set_token('ORDER_LINE_ID', p_order_line_id);
      fnd_msg_pub.add;
      x_return_status :=  fnd_api.g_ret_sts_error;
  END get_split_order_line;

  PROCEDURE get_sub_type_rec(
    p_sub_type_id      IN NUMBER,
    p_trx_type_id      IN NUMBER,
    x_trx_sub_type_rec OUT NOCOPY csi_order_ship_pub.txn_sub_type_rec,
    x_return_status    OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    api_log('get_sub_type_rec');
    x_return_status  := fnd_api.g_ret_sts_success;
    SELECT sub_type_id   ,
           src_change_owner_to_code,
           src_status_id,
           nvl(src_change_owner,'N'),
           transaction_type_id,
           non_src_change_owner_to_code,
           non_src_status_id,
           nvl(non_src_change_owner,'N'),
           nvl(src_reference_reqd,'N'),
           nvl(non_src_reference_reqd,'N'),
           nvl(src_return_reqd,'N'),
           non_src_return_reqd
    INTO   x_trx_sub_type_rec.sub_type_id,
           x_trx_sub_type_rec.src_chg_owner_code,
           x_trx_sub_type_rec.src_status_id,
           x_trx_sub_type_rec.src_change_owner,
           x_trx_sub_type_rec.trx_type_id,
           x_trx_sub_type_rec.nsrc_chg_owner_code,
           x_trx_sub_type_rec.nsrc_status_id,
           x_trx_sub_type_rec.nsrc_change_owner,
           x_trx_sub_type_rec.src_reference_reqd,
           x_trx_sub_type_rec.nsrc_reference_reqd,
           x_trx_sub_type_rec.src_return_reqd,
           x_trx_sub_type_rec.nsrc_return_reqd
    FROM   csi_txn_sub_types
    WHERE  sub_type_id = p_sub_type_id
    AND    transaction_type_id = p_trx_type_id;

  EXCEPTION
    WHEN others THEN
      fnd_message.set_name('CSI','CSI_INT_SUB_TYPE_REC_MISSING');
      fnd_message.set_token('SUB_TYPE_ID', p_sub_type_id);
      fnd_message.set_token('TRANSACTION_TYPE_ID', p_trx_type_id);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
  END get_sub_type_rec;

PROCEDURE get_inst_relation
 (  p_ii_relationship_id IN NUMBER,
    x_object_id          OUT NOCOPY NUMBER ,
    x_subject_id         OUT NOCOPY NUMBER ,
    x_return_status      OUT NOCOPY VARCHAR2
   )  IS

BEGIN

  api_log('get_inst_relation');

x_return_status  := fnd_api.g_ret_sts_success;

SELECT
      object_id,
      subject_id
INTO  x_object_id,
      x_subject_id
FROM   csi_ii_relationships
WHERE  relationship_id = p_ii_relationship_id
 AND   ((active_end_date is null) OR
        (active_end_date > sysdate));

exception
 when others then
        fnd_message.set_name('CSI','CSI_INT_INV_II_REL_ID');
        fnd_message.set_token('RELATIONSHIP_ID', p_ii_relationship_id);
        fnd_msg_pub.add;
    x_return_status := fnd_api.g_ret_sts_error;
END get_inst_relation;

  PROCEDURE get_model_inst_lst(
    p_parent_line_id  IN  number,
    x_model_inst_tbl  OUT NOCOPY csi_order_ship_pub.model_inst_tbl,
    x_return_status   OUT NOCOPY varchar2)
  IS

    l_ind binary_integer := 0;

    CURSOR parent_inst_cur IS
      SELECT cii.instance_id,
             'N' process_flag
      FROM   csi_item_instances cii,
             oe_order_lines_all oel
      WHERE  oel.line_id               = p_parent_line_id
      AND    cii.inventory_item_id     = oel.inventory_item_id
      AND    cii.last_oe_order_line_id = oel.line_id;

  BEGIN

    api_log('get_model_inst_lst');

    FOR parent_inst_rec in parent_inst_cur
    LOOP
      l_ind := l_ind +1;
      x_model_inst_tbl(l_ind).parent_line_id := p_parent_line_id;
      x_model_inst_tbl(l_ind).instance_id    := parent_inst_rec.instance_id;
      x_model_inst_tbl(l_ind).process_flag   := parent_inst_rec.process_flag;
    END LOOP;

  END get_model_inst_lst;

--fix for 5096435
PROCEDURE get_qty_ratio
 ( p_order_line_qty   IN NUMBER,
   p_order_item_id    IN NUMBER,
   p_model_remnant_flag IN VARCHAR2,
   p_link_to_line_id  IN NUMBER,
   x_qty_ratio        OUT NOCOPY NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2
   ) IS

 l_ordered_quantity   NUMBER;
 l_parent_line_id     NUMBER;
 l_ib_trackable_flag  VARCHAR2(1);
 l_order_line_qty     NUMBER;

BEGIN

  api_log('get_qty_ratio');


  /* Initialize API return status to success */
  x_return_status := fnd_api.g_ret_sts_success;

 IF nvl(p_model_remnant_flag,'N') = 'Y' THEN
   BEGIN
	select sum(ordered_quantity)
	into l_order_line_qty
	from oe_order_lines_all
	where link_to_line_id = p_link_to_line_id
	and inventory_item_id = p_order_item_id
	and model_remnant_flag = 'Y';
  EXCEPTION
    WHEN no_data_found THEN
        fnd_message.set_name('CSI','CSI_INT_MOD_INST_MISSING');
        fnd_message.set_token('LINE_ID',p_link_to_line_id);
        fnd_msg_pub.add;
        l_ordered_quantity := 0;
    WHEN others THEN
        fnd_message.set_name('CSI','CSI_INT_MOD_INST_MISSING');
        fnd_message.set_token('LINE_ID',p_link_to_line_id);
        fnd_msg_pub.add;
        l_ordered_quantity := 0;
   END ;
  ELSE
   l_order_line_qty := p_order_line_qty;
 END IF;


  BEGIN
    SELECT ordered_quantity
     INTO  l_ordered_quantity
    FROM  oe_order_lines_all
    WHERE line_id  = p_link_to_line_id;

  EXCEPTION
    WHEN no_data_found THEN
        fnd_message.set_name('CSI','CSI_INT_MOD_INST_MISSING');
        fnd_message.set_token('LINE_ID',p_link_to_line_id);
        fnd_msg_pub.add;
        l_ordered_quantity := 0;
    WHEN others THEN
        fnd_message.set_name('CSI','CSI_INT_MOD_INST_MISSING');
        fnd_message.set_token('LINE_ID',p_link_to_line_id);
        fnd_msg_pub.add;
        l_ordered_quantity := 0;
  END ;

  -- Begin Fix for Bug 3419252
  Begin
    SELECT  a.link_to_line_id,
            nvl(msi.comms_nl_trackable_flag,'N')
    INTO    l_parent_line_id,
            l_ib_trackable_flag
    FROM    oe_order_lines_all a,
            mtl_system_items msi,
            oe_system_parameters_all osp
    WHERE   a.line_id = p_link_to_line_id
    AND     osp.org_id = a.org_id
    AND     msi.inventory_item_id = a.inventory_item_id
    AND     msi.organization_id   = osp.master_organization_id;

    debug('Parent Line ID '||l_parent_line_id);
    debug('IB Trackable   '||l_ib_trackable_flag);

  Exception
    WHEN no_data_found THEN
        fnd_message.set_name('CSI','CSI_INT_MOD_INST_MISSING');
        fnd_message.set_token('LINE_ID',p_link_to_line_id);
        fnd_msg_pub.add;
        l_ordered_quantity := 0;
  End;

  IF l_parent_line_id is null
    AND
     l_ib_trackable_flag <> 'Y'
  THEN
    l_ordered_quantity := 1;
  END IF;
  -- End fix for Bug 3419252

  debug('p_order_line_qty   = '||p_order_line_qty);
  debug('l_ordered_quantity = '||l_ordered_quantity);

  x_qty_ratio := l_order_line_qty/l_ordered_quantity;

  debug('Qty Ratio ='||x_qty_ratio);

END get_qty_ratio;

PROCEDURE get_link_to_line_id
 ( x_link_to_line_id  IN OUT NOCOPY NUMBER,
   x_return_status    OUT NOCOPY    VARCHAR2
  ) IS

l_dummy           VARCHAR2(1);
l_found           BOOLEAN := FALSE;
l_line_id	  NUMBER;

BEGIN

  api_log('get_link_to_line_id');

  /* Initialize API return status to success */
  x_return_status := fnd_api.g_ret_sts_success;

 WHILE NOT(l_found) LOOP

  BEGIN
    SELECT 'x'
     INTO  l_dummy
    FROM mtl_system_items msi,
         oe_order_lines_all orl,
         oe_order_headers_all orh
    WHERE msi.inventory_item_id = orl.inventory_item_id
     AND  msi.organization_id   = NVL(orl.ship_from_org_id,orh.ship_from_org_id)
     AND  orl.header_id         = orh.header_id
     AND  msi.comms_nl_trackable_flag = 'Y'
     AND  orl.line_id           = x_link_to_line_id;

    l_found := TRUE;
  EXCEPTION
    WHEN no_data_found THEN


        Begin
          SELECT link_to_line_id , line_id
           INTO  x_link_to_line_id, l_line_id
           FROM  oe_order_lines_all
          WHERE  line_id = x_link_to_line_id;

          IF x_link_to_line_id IS NULL THEN
            l_found := TRUE;
            x_link_to_line_id := l_line_id ; -- Bug 2401138 to set the link to line id correctly when the Top Model is identified in the loop
          END IF;

        exception
        when no_data_found then --fix for bug5045398--
          debug('Passed link_to_line_id '||x_link_to_line_id||' does not exists in oe order lines');
          fnd_message.set_name('CSI','CSI_OE_LINK_TO_LINE_ID_INVALID');
          fnd_message.set_token('OE_LINK_TO_LINE_ID', x_link_to_line_id);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
          l_found := TRUE;
        --end of fix--
        end;
    WHEN others THEN
        fnd_message.set_name('CSI','CSI_INT_MOD_INST_MISSING');
        fnd_message.set_token('LINE_ID',x_link_to_line_id);
        fnd_msg_pub.add;
  END ;

 END LOOP; --end of while loop

END get_link_to_line_id;


PROCEDURE build_inst_ii_tbl
    ( p_orig_inst_id     IN NUMBER,
      p_txn_ii_rltns_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
      p_new_instance_tbl IN csi_datastructures_pub.instance_tbl,
      x_return_status    OUT NOCOPY VARCHAR2
     ) IS

  l_temp_txn_ii_rltns_rec csi_t_datastructures_grp.txn_ii_rltns_rec;
  l_start                 NUMBER;
  l_ind                   BINARY_INTEGER;

BEGIN

  api_log('build_inst_ii_tbl');

 x_return_status := fnd_api.g_ret_sts_success;

 IF p_txn_ii_rltns_tbl.count > 0 THEN
   FOR i in p_txn_ii_rltns_tbl.first..p_txn_ii_rltns_tbl.last LOOP
     IF p_txn_ii_rltns_tbl(i).subject_id = p_orig_inst_id THEN
        p_txn_ii_rltns_tbl(i).subject_id :=  p_new_instance_tbl(1).instance_id ;
        l_temp_txn_ii_rltns_rec := p_txn_ii_rltns_tbl(i);
        exit;
     END IF;
   END LOOP;
 END IF;

 l_start := p_new_instance_tbl.first + 1 ;
 l_ind   := p_txn_ii_rltns_tbl.count + 1;

 IF p_new_instance_tbl.count > 0 THEN
   FOR i in l_start..p_new_instance_tbl.last LOOP
       p_txn_ii_rltns_tbl(l_ind) := l_temp_txn_ii_rltns_rec;
       p_txn_ii_rltns_tbl(l_ind).subject_id := p_new_instance_tbl(i).instance_id;
   END LOOP;
 END IF;

END build_inst_ii_tbl;

  PROCEDURE update_txn_line_dtl(
    p_source_trx_id    IN NUMBER,
    p_source_trx_table IN VARCHAR2,
    p_api_name         IN VARCHAR2,
    p_error_message    IN VARCHAR2)
  IS
    l_literal1   VARCHAR2(30) := 'PROCESSED';
  BEGIN

    UPDATE csi_t_txn_line_details a
    SET    error_code = p_api_name,
           error_explanation = substr(p_error_message,1,240),
           processing_status = 'ERROR'
    WHERE  a.processing_status <> l_literal1
    AND    a.source_transaction_flag = 'Y'
    AND    a.transaction_line_id =  (SELECT b.transaction_line_id -- changes for the bug 2851485
                    FROM csi_t_transaction_lines b
                    WHERE -- a.transaction_line_id = b.transaction_line_id AND -- Commented for Perf Bug 4311676
                    b.source_transaction_id    = p_source_trx_id
                    AND  b.source_transaction_table = p_source_trx_table);

    debug('No of rows updated= '||sql%rowcount);

  END update_txn_line_dtl;

  /* logic to check if wip has created some relations */
  FUNCTION wip_config_exists(
    p_instance_id      IN  NUMBER)
  RETURN boolean
  IS

    l_config_exists        BOOLEAN := FALSE;
    l_wip_job_id           NUMBER;
    l_location_type_code   VARCHAR2(30);
    l_instance_usage_code  VARCHAR2(30);

    CURSOR rltns_cur(pc_instance_id IN number) IS
      SELECT subject_id
      FROM   csi_ii_relationships
      WHERE  object_id              = pc_instance_id  -- parent instance id
      AND    relationship_type_code = 'COMPONENT-OF'
      AND    sysdate BETWEEN nvl(active_start_date, sysdate-1)
                     AND     nvl(active_end_date  , sysdate+1);
  BEGIN

    FOR rltns_rec IN rltns_cur(p_instance_id)
    LOOP

      SELECT last_wip_job_id,
             location_type_code,
             instance_usage_code
      INTO   l_wip_job_id,
             l_location_type_code,
             l_instance_usage_code
      FROM   csi_item_instances
      WHERE  instance_id = rltns_rec.subject_id;

      IF l_instance_usage_code = 'IN_RELATIONSHIP' THEN
        debug('  configuration found. no explosion.');
        l_config_exists := TRUE;
        exit;
      END IF;
    END LOOP;

    RETURN l_config_exists;

  END wip_config_exists;

  FUNCTION check_standard_bom(
    p_order_line_rec       IN csi_order_ship_pub.order_line_rec)
  RETURN BOOLEAN
  IS

    l_bom_item_type        mtl_system_items.bom_item_type%TYPE;
    l_bom_found            varchar2(1);
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;
    l_explosion_level      number;
    l_explode_flag         varchar2(3);
    l_leaf_node            varchar2(100);
    l_item_type_code       varchar2(30);
    no_explosion           exception;

  BEGIN

    api_log('check_standard_bom');

    l_explode_flag := nvl(fnd_profile.value('CSI_EXPLODE_BOM'),'N');
    debug('  profile_explode_bom     : '||l_explode_flag);
    debug('  inv_item_id             : '||p_order_line_rec.inv_item_id);
    debug('  vld_org_id              : '||p_order_line_rec.inv_org_id);

    IF nvl(l_explode_flag,'N') <> 'Y' THEN
      debug('  explode bom profile option is not set. no explosion');
      raise no_explosion;
    END IF;

    IF p_order_line_rec.bom_item_type <> 4  THEN
      debug('  bom item type in item master is not standard. no explosion');
      RAISE no_explosion;
    END IF;


    /* check if this item is at the leaf node */
    BEGIN
      SELECT 'Y'
      INTO   l_leaf_node
      FROM   sys.dual
      WHERE  exists (SELECT 'X' FROM oe_order_lines_all
                     WHERE  header_id       = p_order_line_rec.header_id
                     AND    link_to_line_id = p_order_line_rec.order_line_id);

      debug('  order line is not the leaf node in oe configuration. no explosion');
      RAISE no_explosion;
    EXCEPTION
      WHEN no_data_found THEN
        null;
    END;

    BEGIN
      SELECT 'Y'
      INTO   l_bom_found
      FROM   bom_bill_of_materials
      WHERE  assembly_item_id = p_order_line_rec.inv_item_id
      AND    organization_id  = p_order_line_rec.inv_org_id
      AND    alternate_bom_designator is NULL;

    EXCEPTION
      when no_data_found THEN
        debug('  primary bill of material not found. no explosion');
        RAISE no_explosion;
    END;

    /* 2457414 -- added this block */
    /* check if the item is completed by a wip job (config items) */
    /* config items need to be eliminated in the bom explosion    */
    DECLARE
      l_wip_job_id  number;
    BEGIN

      SELECT wip_entity_id
      INTO   l_wip_job_id
      FROM   wip_discrete_jobs
      WHERE  primary_item_id = p_order_line_rec.inv_item_id
      AND    organization_id = p_order_line_rec.inv_org_id
      AND    source_line_id  = p_order_line_rec.order_line_id
      AND    status_type     <> 7; -- exclude the cancelled job

      debug('  wip job exists and configuration will be build there. no explosion.');
      raise no_explosion;

    EXCEPTION
      WHEN no_data_found THEN
        null;
      WHEN too_many_rows THEN
        debug('  wip job exists and configuration will be build there. no explosion.');
        raise no_explosion;
    END;

    IF p_order_line_rec.item_type_code = 'CONFIG' THEN
      debug('  config item shipment. no explosion');
      RAISE no_explosion;
    END IF;

    debug('  check_standard_bom      : TRUE');
    RETURN TRUE;

  EXCEPTION
    WHEN no_explosion THEN
      debug('  check_standard_bom      : FALSE');
      RETURN FALSE;
    WHEN fnd_api.g_exc_error THEN
      RETURN FALSE;
  END check_standard_bom;

  PROCEDURE get_parties_and_accounts(
    p_instance_id      IN     number,
    p_tld_rec          IN     csi_t_datastructures_grp.txn_line_detail_rec,
    p_t_pty_tbl        IN     csi_t_datastructures_grp.txn_party_detail_tbl,
    p_t_pty_acct_tbl   IN     csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    p_owner_pty_rec    IN     csi_datastructures_pub.party_rec,
    p_owner_acct_rec   IN     csi_datastructures_pub.party_account_rec,
    p_order_line_rec   IN     csi_order_ship_pub.order_line_rec,
    x_i_pty_tbl           OUT nocopy csi_datastructures_pub.party_tbl,
    x_i_pty_acct_tbl      OUT nocopy csi_datastructures_pub.party_account_tbl,
    x_return_status       OUT nocopy varchar2)
  IS

    l_ship_to_con_entered     boolean := FALSE;
    l_bill_to_con_entered     boolean := FALSE;

    l_owner_inst_pty_id       number;
    l_owner_txn_pty_dtl_id    number;

    l_contact_party_id        number;
    l_con_parent_tbl_index    number;

    l_init_pty_rec            csi_datastructures_pub.party_rec;

    l_pty_ind                 binary_integer := 0;
    l_pa_ind                  binary_integer := 0;

    l_pty_rec                 csi_datastructures_pub.party_rec;
    l_pty_tbl                 csi_datastructures_pub.party_tbl;

    l_con_pty_tbl             csi_datastructures_pub.party_tbl;

    l_pa_rec                  csi_datastructures_pub.party_account_rec;
    l_pa_tbl                  csi_datastructures_pub.party_account_tbl;

    l_return_status           varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count               number;
    l_msg_data                varchar2(2000);

    PROCEDURE convert_tpty_to_ipty(
      p_instance_id       IN  number,
      p_t_party_rec       IN  csi_t_datastructures_grp.txn_party_detail_rec,
      x_i_party_rec       OUT nocopy  csi_datastructures_pub.party_rec)
    IS
      l_insance_party_id  number;
      l_ovn               number;
    BEGIN
      x_i_party_rec.instance_party_id      := p_t_party_rec.instance_party_id;
      x_i_party_rec.instance_id            := p_instance_id;
      x_i_party_rec.party_id               := p_t_party_rec.party_source_id;
      x_i_party_rec.party_source_table     := p_t_party_rec.party_source_table;
      x_i_party_rec.relationship_type_code := p_t_party_rec.relationship_type_code;
      x_i_party_rec.contact_flag           := p_t_party_rec.contact_flag;
      x_i_party_rec.active_start_date      := fnd_api.g_miss_date;
      x_i_party_rec.active_end_date        := p_t_party_rec.active_end_date;
      x_i_party_rec.context                := p_t_party_rec.context;
      x_i_party_rec.attribute1             := p_t_party_rec.attribute1;
      x_i_party_rec.attribute2             := p_t_party_rec.attribute2;
      x_i_party_rec.attribute3             := p_t_party_rec.attribute3;
      x_i_party_rec.attribute4             := p_t_party_rec.attribute4;
      x_i_party_rec.attribute5             := p_t_party_rec.attribute5;
      x_i_party_rec.attribute6             := p_t_party_rec.attribute6;
      x_i_party_rec.attribute7             := p_t_party_rec.attribute7;
      x_i_party_rec.attribute8             := p_t_party_rec.attribute8;
      x_i_party_rec.attribute9             := p_t_party_rec.attribute9;
      x_i_party_rec.attribute10            := p_t_party_rec.attribute10;
      x_i_party_rec.attribute11            := p_t_party_rec.attribute11;
      x_i_party_rec.attribute12            := p_t_party_rec.attribute12;
      x_i_party_rec.attribute13            := p_t_party_rec.attribute13;
      x_i_party_rec.attribute14            := p_t_party_rec.attribute14;
      x_i_party_rec.attribute15            := p_t_party_rec.attribute15;

      IF nvl(p_t_party_rec.instance_party_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
        BEGIN
          SELECT instance_party_id,
                 object_version_number
          INTO   x_i_party_rec.instance_party_id,
                 x_i_party_rec.object_version_number
          FROM   csi_i_parties
          WHERE  instance_id            = p_instance_id
          AND    party_id               = x_i_party_rec.party_id
          AND    relationship_type_code = x_i_party_rec.relationship_type_code
          AND    contact_flag           = x_i_party_rec.contact_flag;
        EXCEPTION
          WHEN no_data_found THEN
            x_i_party_rec.object_version_number  := fnd_api.g_miss_num;
        END;
      /*null check added-bug 6455823*/
      ELSIF Nvl(p_t_party_rec.instance_party_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
        SELECT object_version_number
        INTO   x_i_party_rec.object_version_number
        FROM   csi_i_parties
        WHERE  instance_party_id = p_t_party_rec.instance_party_id;
      END IF;
    END convert_tpty_to_ipty;

    PROCEDURE convert_tpa_to_ipa(
      p_instance_party_id   IN  number,
      p_parent_tbl_index    IN  number,
      p_order_line_rec      IN  csi_order_ship_pub.order_line_rec,
      p_t_pa_rec            IN  csi_t_datastructures_grp.txn_pty_acct_detail_rec,
      x_i_pa_rec            OUT nocopy csi_datastructures_pub.party_account_rec)
    IS
    BEGIN
      x_i_pa_rec.parent_tbl_index       := p_parent_tbl_index;
      x_i_pa_rec.ip_account_id          := p_t_pa_rec.ip_account_id;
      x_i_pa_rec.instance_party_id      := p_instance_party_id;
      x_i_pa_rec.party_account_id       := p_t_pa_rec.account_id;
      x_i_pa_rec.relationship_type_code := p_t_pa_rec.relationship_type_code;
      x_i_pa_rec.bill_to_address        := p_t_pa_rec.bill_to_address_id ;
      x_i_pa_rec.ship_to_address        := p_t_pa_rec.ship_to_address_id;
      x_i_pa_rec.active_end_date        := p_t_pa_rec.active_end_date;
      x_i_pa_rec.active_end_date        := p_t_pa_rec.active_end_date;
      x_i_pa_rec.context                := p_t_pa_rec.context;
      x_i_pa_rec.attribute1             := p_t_pa_rec.attribute1;
      x_i_pa_rec.attribute2             := p_t_pa_rec.attribute2;
      x_i_pa_rec.attribute3             := p_t_pa_rec.attribute3;
      x_i_pa_rec.attribute4             := p_t_pa_rec.attribute4;
      x_i_pa_rec.attribute5             := p_t_pa_rec.attribute5;
      x_i_pa_rec.attribute6             := p_t_pa_rec.attribute6;
      x_i_pa_rec.attribute7             := p_t_pa_rec.attribute7;
      x_i_pa_rec.attribute8             := p_t_pa_rec.attribute8;
      x_i_pa_rec.attribute9             := p_t_pa_rec.attribute9;
      x_i_pa_rec.attribute10            := p_t_pa_rec.attribute10;
      x_i_pa_rec.attribute11            := p_t_pa_rec.attribute11;
      x_i_pa_rec.attribute12            := p_t_pa_rec.attribute12;
      x_i_pa_rec.attribute13            := p_t_pa_rec.attribute13;
      x_i_pa_rec.attribute14            := p_t_pa_rec.attribute14;
      x_i_pa_rec.attribute15            := p_t_pa_rec.attribute15;

      IF nvl(p_t_pa_rec.ip_account_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
         AND
         nvl(p_instance_party_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
      THEN
        BEGIN
          SELECT ip_account_id,
                 object_version_number
          INTO   x_i_pa_rec.ip_account_id,
                 x_i_pa_rec.object_version_number
          FROM   csi_ip_accounts
          WHERE  instance_party_id      = p_instance_party_id
          AND    party_account_id       = x_i_pa_rec.party_account_id
          AND    relationship_type_code = x_i_pa_rec.relationship_type_code;
        EXCEPTION
          WHEN no_data_found THEN
            x_i_pa_rec.object_version_number := 1;
        END;
      END IF;

      IF nvl(x_i_pa_rec.bill_to_address, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
        x_i_pa_rec.bill_to_address := p_order_line_rec.invoice_to_org_id;
      END IF;

      IF nvl(x_i_pa_rec.ship_to_address, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
        x_i_pa_rec.ship_to_address := p_order_line_rec.ship_to_org_id;
      END IF;

    END convert_tpa_to_ipa;

    PROCEDURE get_contact_parties(
      p_instance_id       IN  number,
      p_t_party_dtl_id    IN  number,
      p_t_pty_tbl       IN  csi_t_datastructures_grp.txn_party_detail_tbl,
      x_i_pty_tbl       OUT nocopy  csi_datastructures_pub.party_tbl)
    IS
      x_ind               binary_integer := 0;
      l_i_pty_rec         csi_datastructures_pub.party_rec;
    BEGIN
      IF p_t_pty_tbl.COUNT > 0 THEN
        FOR l_ind IN p_t_pty_tbl.FIRST .. p_t_pty_tbl.LAST
        LOOP
          IF p_t_pty_tbl(l_ind).contact_party_id = p_t_party_dtl_id THEN
            convert_tpty_to_ipty(
              p_instance_id  => p_instance_id,
              p_t_party_rec  => p_t_pty_tbl(l_ind),
              x_i_party_rec  => l_i_pty_rec);
            x_ind := x_ind + 1;
            x_i_pty_tbl(x_ind) := l_i_pty_rec;
          END IF;
        END LOOP;
      END IF;
    END get_contact_parties;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_parties_and_accounts');

    BEGIN
      SELECT instance_party_id
      INTO   l_owner_inst_pty_id
      FROM   csi_i_parties
      WHERE  instance_id = p_instance_id
      AND    relationship_type_code = 'OWNER';
    EXCEPTION
      WHEN no_data_found THEN
        l_owner_inst_pty_id := null;
    END;

    /* loop to find out the owner txn party detail id */
    IF p_t_pty_tbl.count > 0 THEN
      FOR ind in p_t_pty_tbl.FIRST..p_t_pty_tbl.LAST LOOP
        IF p_t_pty_tbl(ind).relationship_type_code = 'OWNER' THEN
          l_owner_txn_pty_dtl_id  := p_t_pty_tbl(ind).txn_party_detail_id;
        END IF;
      END LOOP;
    END IF;

    IF nvl(p_owner_pty_rec.party_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      l_pty_ind := l_pty_ind + 1;
      l_pty_tbl(l_pty_ind) := p_owner_pty_rec;

      IF nvl(p_owner_acct_rec.party_account_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
        l_pa_ind := l_pa_ind + 1;
        l_pa_tbl(l_pa_ind) := p_owner_acct_rec;
        l_pa_tbl(l_pa_ind).parent_tbl_index := l_pty_ind;
      END IF;
    END IF;

    IF p_t_pty_tbl.count > 0 THEN

      FOR pty_ind in p_t_pty_tbl.FIRST..p_t_pty_tbl.LAST
      LOOP

        IF p_t_pty_tbl(pty_ind).relationship_type_code <> 'OWNER'
           AND
           p_t_pty_tbl(pty_ind).contact_flag = 'N'
        THEN

          convert_tpty_to_ipty(
            p_instance_id       => p_instance_id,
            p_t_party_rec       => p_t_pty_tbl(pty_ind),
            x_i_party_rec       => l_pty_rec);

          l_pty_ind := l_pty_ind + 1;
          l_pty_tbl(l_pty_ind) := l_pty_rec;

          IF l_pty_rec.relationship_type_code = 'SHIP_TO'
             AND
             l_pty_rec.contact_flag = 'Y'
             AND
             p_t_pty_tbl(pty_ind).contact_party_id = l_owner_txn_pty_dtl_id
          THEN
            l_ship_to_con_entered := TRUE;
          END IF;

          IF l_pty_rec.relationship_type_code = 'BILL_TO'
             AND
             l_pty_rec.contact_flag = 'Y'
             AND
             p_t_pty_tbl(pty_ind).contact_party_id = l_owner_txn_pty_dtl_id
          THEN
            l_bill_to_con_entered := TRUE;
          END IF;

          /*  Build party account table for create/update */
          IF p_t_pty_acct_tbl.count > 0 THEN

            FOR k in p_t_pty_acct_tbl.FIRST..p_t_pty_acct_tbl.LAST
            LOOP

              IF p_t_pty_acct_tbl(k).txn_party_detail_id = p_t_pty_tbl(pty_ind).txn_party_detail_id
              THEN

                convert_tpa_to_ipa(
                  p_instance_party_id => l_pty_rec.instance_party_id,
                  p_parent_tbl_index  => l_pty_ind,
                  p_order_line_rec    => p_order_line_rec,
                  p_t_pa_rec          => p_t_pty_acct_tbl(k),
                  x_i_pa_rec          => l_pa_rec);

                l_pa_ind := l_pa_ind + 1;
                l_pa_tbl(l_pa_ind) := l_pa_rec;

              END IF; -- end if for pty.txn_party_detail_id = acct.txn_party_detail_id
            END LOOP; -- end of party acct table loop
          END IF; -- party account count > 0

          get_contact_parties(
            p_instance_id     => p_instance_id,
            p_t_party_dtl_id  => p_t_pty_tbl(pty_ind).txn_party_detail_id,
            p_t_pty_tbl     => p_t_pty_tbl,
            x_i_pty_tbl     => l_con_pty_tbl);

          IF l_con_pty_tbl.COUNT > 0 THEN

            l_con_parent_tbl_index := l_pty_ind;

            FOR con_ind IN l_con_pty_tbl.FIRST .. l_con_pty_tbl.LAST
            LOOP
              l_pty_ind := l_pty_ind + 1;
              l_pty_tbl(l_pty_ind) := l_con_pty_tbl(con_ind);
              l_pty_tbl(l_pty_ind).contact_parent_tbl_index := l_con_parent_tbl_index;
            END LOOP;
          END IF;


        END IF; -- <> 'OWNER'

      END LOOP;

    END IF; -- party table count > 0

    /* Build BILL_TO and SHIP_TO from OM line if the TD does not have it */
    IF NOT(l_ship_to_con_entered)
       AND
       nvl(p_order_line_rec.ship_to_contact_id, fnd_api.g_miss_num ) <> fnd_api.g_miss_num
    THEN

      csi_utl_pkg.derive_party_id(
        p_cust_acct_role_id  => p_order_line_rec.ship_to_contact_id,
        x_party_id           => l_contact_party_id,
        x_return_status      => x_return_status );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      debug('  ship_to_contact_id       :'||p_order_line_rec.ship_to_contact_id);
      debug('  ship_to_contact_party_id :'||l_contact_party_id);

      l_pty_rec := l_init_pty_rec;
      l_pty_rec.instance_party_id      := fnd_api.g_miss_num;
      l_pty_rec.instance_id            := p_instance_id;
      l_pty_rec.party_id               := l_contact_party_id;
      l_pty_rec.party_source_table     := 'HZ_PARTIES';
      l_pty_rec.relationship_type_code := 'SHIP_TO';
      l_pty_rec.contact_flag           := 'Y';
      l_pty_rec.contact_ip_id          := l_owner_inst_pty_id;
      l_pty_rec.active_start_date      := fnd_api.g_miss_date;
      l_pty_rec.object_version_number  := fnd_api.g_miss_num;

      BEGIN
        SELECT instance_party_id,
               object_version_number
        INTO   l_pty_rec.instance_party_id,
               l_pty_rec.object_version_number
        FROM   csi_i_parties
        WHERE  instance_id            = p_instance_id
        AND    party_id               = l_pty_rec.party_id
        AND    relationship_type_code = l_pty_rec.relationship_type_code
        AND    contact_flag           = 'Y';
        l_pty_rec.active_end_date := null;
      EXCEPTION
        WHEN no_data_found THEN
          l_pty_rec.instance_party_id := null;
          l_pty_rec.object_version_number := 1.0;
      END;

      l_pty_ind := l_pty_ind + 1;
      l_pty_tbl(l_pty_ind) := l_pty_rec;

    END IF;

    IF NOT(l_bill_to_con_entered)
       AND
       nvl(p_order_line_rec.invoice_to_contact_id, fnd_api.g_miss_num ) <> fnd_api.g_miss_num
    THEN

      csi_utl_pkg.derive_party_id(
        p_cust_acct_role_id  => p_order_line_rec.invoice_to_contact_id,
        x_party_id           => l_contact_party_id,
        x_return_status      => x_return_status );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      debug('  bill_to_contact_id       :'||p_order_line_rec.invoice_to_contact_id);
      debug('  bill_to_contact_party_id :'||l_contact_party_id);

      l_pty_rec := l_init_pty_rec;

      l_pty_rec.instance_party_id      := fnd_api.g_miss_num;
      l_pty_rec.instance_id            := p_instance_id;
      l_pty_rec.party_id               := l_contact_party_id;
      l_pty_rec.party_source_table     := 'HZ_PARTIES';
      l_pty_rec.relationship_type_code := 'BILL_TO';
      l_pty_rec.contact_flag           := 'Y';
      l_pty_rec.contact_ip_id          := l_owner_inst_pty_id;
      l_pty_rec.active_start_date      := fnd_api.g_miss_date;
      l_pty_rec.object_version_number  := fnd_api.g_miss_num;

      BEGIN
        SELECT instance_party_id,
               object_version_number
        INTO   l_pty_rec.instance_party_id,
               l_pty_rec.object_version_number
        FROM   csi_i_parties
        WHERE  instance_id            = p_instance_id
        AND    party_id               = l_pty_rec.party_id
        AND    relationship_type_code = l_pty_rec.relationship_type_code
        AND    contact_flag           = 'Y';
        l_pty_rec.active_end_date := null;
      EXCEPTION
        WHEN no_data_found THEN
          l_pty_rec.instance_party_id     := null;
          l_pty_rec.object_version_number := 1.0;
      END;

      l_pty_ind := l_pty_ind + 1;
      l_pty_tbl(l_pty_ind) := l_pty_rec;

    END IF; -- l_bill_to_contact

    x_i_pty_tbl     := l_pty_tbl;
    x_i_pty_acct_tbl  := l_pa_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
  END get_parties_and_accounts;

  PROCEDURE create_txn_dtls(
    p_source_trx_id    IN         number,
    p_source_trx_table IN         varchar2,
    x_return_status    OUT NOCOPY varchar2)
  IS

    l_txn_line_query_rec        csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec csi_t_datastructures_grp.txn_line_detail_query_rec;

    o_line_dtl_tbl      csi_t_datastructures_grp.txn_line_detail_tbl;
    o_pty_dtl_tbl       csi_t_datastructures_grp.txn_party_detail_tbl;
    o_pty_acct_tbl      csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    o_ii_rltns_tbl      csi_t_datastructures_grp.txn_ii_rltns_tbl;
    o_org_assgn_tbl     csi_t_datastructures_grp.txn_org_assgn_tbl;
    o_ext_attrib_tbl    csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    o_csi_ea_tbl        csi_t_datastructures_grp.csi_ext_attribs_tbl;
    o_csi_eav_tbl       csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    o_txn_systems_tbl   csi_t_datastructures_grp.txn_systems_tbl;

    l_line_dtl_rec      csi_t_datastructures_grp.txn_line_detail_rec;

    l_line_dtl_tbl      csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl       csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl      csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl      csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl     csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_ext_attrib_tbl    csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_csi_ea_tbl        csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_csi_eav_tbl       csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_txn_systems_tbl   csi_t_datastructures_grp.txn_systems_tbl;

    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count         number;
    l_msg_data          varchar2(2000);

    CURSOR tld_cur(
      p_src_txn_id    IN NUMBER,
      p_src_txn_table IN VARCHAR2)
    IS
      SELECT ctld.txn_line_detail_id,
             ctld.quantity,
             ctld.transaction_line_id,
             ctld.transaction_system_id,
             ctld.csi_system_id
      FROM   csi_t_txn_line_details  ctld,
             csi_t_transaction_lines ctl
      WHERE  ctl.source_transaction_id    = p_src_txn_id
      AND    ctl.source_transaction_table = p_src_txn_table
      AND    ctld.transaction_line_id     = ctl.transaction_line_id
      AND    ctld.quantity                > 1;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('create_txn_dtls');

    FOR tld_rec IN tld_cur( p_source_trx_id, p_source_trx_table )
    LOOP

      l_txn_line_detail_query_rec.txn_line_detail_id := tld_rec.txn_line_detail_id;

      csi_t_txn_details_grp.get_transaction_details(
        p_api_version                => 1.0,
        p_commit                     => fnd_api.g_false,
        p_init_msg_list              => fnd_api.g_true,
        p_validation_level           => fnd_api.g_valid_level_full,
        p_txn_line_query_rec         => l_txn_line_query_rec,
        p_txn_line_detail_query_rec  => l_txn_line_detail_query_rec,
        x_txn_line_detail_tbl        => o_line_dtl_tbl,
        p_get_parties_flag           => fnd_api.g_true,
        x_txn_party_detail_tbl       => o_pty_dtl_tbl,
        p_get_pty_accts_flag         => fnd_api.g_true,
        x_txn_pty_acct_detail_tbl    => o_pty_acct_tbl,
        p_get_ii_rltns_flag          => fnd_api.g_true,
        x_txn_ii_rltns_tbl           => o_ii_rltns_tbl,
        p_get_org_assgns_flag        => fnd_api.g_true,
        x_txn_org_assgn_tbl          => o_org_assgn_tbl,
        p_get_ext_attrib_vals_flag   => fnd_api.g_true,
        x_txn_ext_attrib_vals_tbl    => o_ext_attrib_tbl,
        p_get_csi_attribs_flag       => fnd_api.g_false,
        x_csi_ext_attribs_tbl        => o_csi_ea_tbl,
        p_get_csi_iea_values_flag    => fnd_api.g_false,
        x_csi_iea_values_tbl         => o_csi_eav_tbl,
        p_get_txn_systems_flag       => fnd_api.g_false,
        x_txn_systems_tbl            => o_txn_systems_tbl,
        x_return_status              => l_return_status,
        x_msg_count                  => l_msg_count,
        x_msg_data                   => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;


      debug('after csi_t_txn_details_grp.get_transaction_details for splitting  ');
      debug('  line_dtl_tbl.count   :'||o_line_dtl_tbl.count);
      debug('  pty_dtl_tbl.count    :'||o_pty_dtl_tbl.count);
      debug('  pty_acct_tbl.count   :'||o_pty_acct_tbl.count);
      debug('  org_assgn_tbl.count  :'||o_org_assgn_tbl.count);
      debug('  ext_attrib_tbl.count :'||o_ext_attrib_tbl.count);
      debug('  ii_rltns_tbl.count   :'||o_ii_rltns_tbl.count);

      IF o_line_dtl_tbl.COUNT > 0 THEN

        UPDATE csi_t_txn_line_details
        SET    quantity = 1
        WHERE  txn_line_detail_id = o_line_dtl_tbl(1).txn_line_detail_id;


        FOR l_index in 1..o_line_dtl_tbl(1).quantity - 1
        LOOP

          l_line_dtl_tbl      := o_line_dtl_tbl;
          l_pty_dtl_tbl       := o_pty_dtl_tbl;
          l_pty_acct_tbl      := o_pty_acct_tbl;
          l_ii_rltns_tbl      := o_ii_rltns_tbl;
          l_org_assgn_tbl     := o_org_assgn_tbl;
          l_ext_attrib_tbl    := o_ext_attrib_tbl;
          l_txn_systems_tbl   := o_txn_systems_tbl;

          csi_t_utilities_pvt.convert_ids_to_index(
            px_line_dtl_tbl    => l_line_dtl_tbl,
            px_pty_dtl_tbl     => l_pty_dtl_tbl,
            px_pty_acct_tbl    => l_pty_acct_tbl,
            px_ii_rltns_tbl    => l_ii_rltns_tbl,
            px_org_assgn_tbl   => l_org_assgn_tbl,
            px_ext_attrib_tbl  => l_ext_attrib_tbl,
            px_txn_systems_tbl => l_txn_systems_tbl);

          l_line_dtl_rec      := l_line_dtl_tbl(1);

          --l_line_dtl_rec.source_txn_line_detail_id := tld_rec.source_txn_line_detail_id;
          l_line_dtl_rec.txn_line_detail_id        := fnd_api.g_miss_num;
          l_line_dtl_rec.transaction_system_id     := tld_rec.transaction_system_id;
          l_line_dtl_rec.csi_system_id             := tld_rec.csi_system_id;
          l_line_dtl_rec.quantity                  := 1 ;
          l_line_dtl_rec.transaction_line_id       := tld_rec.transaction_line_id ;

          csi_t_txn_line_dtls_pvt.create_txn_line_dtls(
            p_api_version              => 1.0,
            p_commit                   => fnd_api.g_false,
            p_init_msg_list            => fnd_api.g_true,
            p_validation_level         => fnd_api.g_valid_level_full,
            p_txn_line_dtl_index       => 1,
            p_txn_line_dtl_rec         => l_line_dtl_rec,
            px_txn_party_dtl_tbl       => l_pty_dtl_tbl,
            px_txn_pty_acct_detail_tbl => l_pty_acct_tbl,
            px_txn_ii_rltns_tbl        => l_ii_rltns_tbl,
            px_txn_org_assgn_tbl       => l_org_assgn_tbl,
            px_txn_ext_attrib_vals_tbl => l_ext_attrib_tbl,
            x_return_status            => l_return_status,
            x_msg_count                => l_msg_count,
            x_msg_data                 => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END LOOP;
      END IF; -- count chk
    END LOOP;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
  END create_txn_dtls;

  PROCEDURE conv_to_prim_uom(
    p_inv_organization_id IN NUMBER,
    p_inventory_item_id   IN NUMBER,
    p_uom                 IN VARCHAR2,
    x_txn_line_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status       OUT NOCOPY VARCHAR2)
  IS
    l_primary_uom  varchar2(100);
    l_uom_rate     NUMBER;
  BEGIN

    api_log('conv_to_prim_uom');

    /* Initialize API return status to success */
    x_return_status := fnd_api.g_ret_sts_success;

    l_primary_uom := csi_utl_pkg.get_primay_uom(
       p_inv_item_id => p_inventory_item_id,
       p_inv_org_id  => p_inv_organization_id);

    debug('Primary UOM :'||l_primary_uom);

    /* Convert the shipped qty to UOM as in OM */
    inv_convert.inv_um_conversion (
      from_unit  => p_uom,
      to_unit    => l_primary_uom,
      item_id    => p_inventory_item_id,
      uom_rate   => l_uom_rate );

    debug('UOM Rate    :'||l_uom_rate);

    IF l_uom_rate = -99999 THEN
      debug('inv_convert.inv_um_conversion failed ');
      RAISE fnd_api.g_exc_error;
    END IF;

    IF x_txn_line_dtl_tbl.count > 0 THEN
      FOR i in x_txn_line_dtl_tbl.first..x_txn_line_dtl_tbl.last
      LOOP
        x_txn_line_dtl_tbl(i).quantity := x_txn_line_dtl_tbl(i).quantity * l_uom_rate;
      END LOOP;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
  END conv_to_prim_uom;

  PROCEDURE build_non_source_rec(
    p_transaction_line_id   IN number,
    p_parent_line_id        IN number,
    p_instance_id           IN number,
    x_txn_line_dtl_id       OUT NOCOPY number,
    x_return_status         OUT NOCOPY varchar2)
  IS

    l_instance_rec          csi_datastructures_pub.instance_rec;
    l_g_instance_rec        csi_datastructures_pub.instance_header_rec;
    l_g_ph_tbl              csi_datastructures_pub.party_header_tbl;
    l_g_pah_tbl             csi_datastructures_pub.party_account_header_tbl;
    l_g_ouh_tbl             csi_datastructures_pub.org_units_header_tbl;
    l_g_pa_tbl              csi_datastructures_pub.pricing_attribs_tbl;
    l_g_eav_tbl             csi_datastructures_pub.extend_attrib_values_tbl;
    l_g_ea_tbl              csi_datastructures_pub.extend_attrib_tbl;
    l_g_iah_tbl             csi_datastructures_pub.instance_asset_header_tbl;
    l_g_time_stamp          date;

    -- create_txn_line_dtls variables
    l_n_line_dtl_rec        csi_t_datastructures_grp.txn_line_detail_rec;
    l_n_pty_dtl_tbl         csi_t_datastructures_grp.txn_party_detail_tbl;
    l_n_pty_acct_tbl        csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_n_org_assgn_tbl       csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_n_ext_attrib_tbl      csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_n_ii_rltns_tbl        csi_t_datastructures_grp.txn_ii_rltns_tbl;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count             number;
    l_msg_data              varchar2(4000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('build_non_source_rec');

    l_g_instance_rec.instance_id := p_instance_id;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => 'csi_item_instance_pub',
      p_api_name => 'get_item_instance_details');

    -- get the instance party and party account info
    csi_item_instance_pub.get_item_instance_details(
      p_api_version           => 1.0,
      p_commit                => fnd_api.g_false,
      p_init_msg_list         => fnd_api.g_true,
      p_validation_level      => fnd_api.g_valid_level_full,
      p_instance_rec          => l_g_instance_rec,
      p_get_parties           => fnd_api.g_false,
      p_party_header_tbl      => l_g_ph_tbl,
      p_get_accounts          => fnd_api.g_false,
      p_account_header_tbl    => l_g_pah_tbl,
      p_get_org_assignments   => fnd_api.g_false,
      p_org_header_tbl        => l_g_ouh_tbl,
      p_get_pricing_attribs   => fnd_api.g_false,
      p_pricing_attrib_tbl    => l_g_pa_tbl,
      p_get_ext_attribs       => fnd_api.g_false,
      p_ext_attrib_tbl        => l_g_eav_tbl,
      p_ext_attrib_def_tbl    => l_g_ea_tbl,
      p_get_asset_assignments => fnd_api.g_false,
      p_asset_header_tbl      => l_g_iah_tbl,
      p_time_stamp            => l_g_time_stamp,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_n_line_dtl_rec.txn_line_detail_id      := fnd_api.g_miss_num;
    l_n_line_dtl_rec.transaction_line_id     := p_transaction_line_id;
    l_n_line_dtl_rec.sub_type_id             := csi_order_ship_pub.g_dflt_sub_type_id;
    l_n_line_dtl_rec.processing_status       := 'IN_PROCESS';
    l_n_line_dtl_rec.source_transaction_flag := 'N';
    l_n_line_dtl_rec.inventory_item_id       := l_g_instance_rec.inventory_item_id;
    l_n_line_dtl_rec.inventory_revision      := l_g_instance_rec.inventory_revision;
    /* fix for bug 4941832 */
    l_n_line_dtl_rec.inv_organization_id     := l_g_instance_rec.vld_organization_id;
    l_n_line_dtl_rec.quantity                := l_g_instance_rec.quantity;
    l_n_line_dtl_rec.unit_of_measure         := l_g_instance_rec.unit_of_measure;
    l_n_line_dtl_rec.installation_date       := sysdate;
    l_n_line_dtl_rec.external_reference      := 'INTERFACE';
    l_n_line_dtl_rec.location_type_code      := l_g_instance_rec.location_type_code;
    l_n_line_dtl_rec.location_id             := l_g_instance_rec.location_id;
    l_n_line_dtl_rec.active_start_date       := sysdate;
    l_n_line_dtl_rec.preserve_detail_flag    := 'Y';
    l_n_line_dtl_rec.instance_exists_flag    := 'Y';
    l_n_line_dtl_rec.instance_id             := l_g_instance_rec.instance_id;
    l_n_line_dtl_rec.serial_number           := l_g_instance_rec.serial_number;
    l_n_line_dtl_rec.mfg_serial_number_flag  := l_g_instance_rec.mfg_serial_number_flag;
    l_n_line_dtl_rec.lot_number              := l_g_instance_rec.lot_number;
    l_n_line_dtl_rec.object_version_number   := 1.0;

    csi_t_txn_line_dtls_pvt.create_txn_line_dtls(
      p_api_version              => 1.0,
      p_commit                   => fnd_api.g_false,
      p_init_msg_list            => fnd_api.g_true,
      p_validation_level         => fnd_api.g_valid_level_full,
      p_txn_line_dtl_index       => 1,
      p_txn_line_dtl_rec         => l_n_line_dtl_rec,
      px_txn_party_dtl_tbl       => l_n_pty_dtl_tbl,
      px_txn_pty_acct_detail_tbl => l_n_pty_acct_tbl,
      px_txn_ii_rltns_tbl        => l_n_ii_rltns_tbl,
      px_txn_org_assgn_tbl       => l_n_org_assgn_tbl,
      px_txn_ext_attrib_vals_tbl => l_n_ext_attrib_tbl,
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('Non Source Txn Line Detail ID :'||l_n_line_dtl_rec.txn_line_detail_id);
    x_txn_line_dtl_id := l_n_line_dtl_rec.txn_line_detail_id;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END build_non_source_rec;

  PROCEDURE build_parent_relation(
    p_order_line_rec    IN csi_order_ship_pub.order_line_rec,
    x_model_inst_tbl    IN OUT NOCOPY csi_order_ship_pub.model_inst_tbl,
    x_txn_line_dtl_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_ii_rltns_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status     OUT NOCOPY VARCHAR2)
  IS
    l_txn_ii                number := 0;
    l_nsrc_line_dtl_id      number;
    x_txn_line_dtls_lst     txn_line_dtl_tbl;
    l_txn_processed         varchar2(1);
    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;

    PROCEDURE filter_model_instances( --modified for bug5096435
     p_child_item_id    IN            number,
     px_model_inst_tbl  IN OUT NOCOPY csi_order_ship_pub.model_inst_tbl)
    IS
      CURSOR iir_cur(p_object_id in number, p_item_id in number) IS
        SELECT cii.quantity alloc_quantity
        FROM   csi_ii_relationships ciir,
               csi_item_instances   cii
        WHERE  ciir.object_id        = p_object_id
        AND    cii.instance_id       = ciir.subject_id
        AND    cii.inventory_item_id = p_item_id
        AND    sysdate BETWEEN nvl(ciir.active_start_date, sysdate - 1)
                       AND     nvl(ciir.active_end_date, sysdate + 1);
    BEGIN
      IF px_model_inst_tbl.COUNT > 0 THEN
        FOR l_ind IN px_model_inst_tbl.FIRST .. px_model_inst_tbl.LAST
        LOOP
          FOR iir_rec IN iir_cur(px_model_inst_tbl(l_ind).instance_id, p_child_item_id)
          LOOP
	       x_model_inst_tbl(l_ind).rem_qty := x_model_inst_tbl(l_ind).rem_qty - iir_rec.alloc_quantity;
          END LOOP;
          IF x_model_inst_tbl(l_ind).rem_qty <= 0  THEN
            px_model_inst_tbl(l_ind).process_flag := 'Y';
          END IF;
        END LOOP;
      END IF;
    END filter_model_instances;

  BEGIN

    api_log('build_parent_relation');

    /* Initialize API return status to success */
    x_return_status := fnd_api.g_ret_sts_success;

    x_txn_ii_rltns_tbl.delete;

    filter_model_instances(
      p_child_item_id    => p_order_line_rec.inv_item_id,
      px_model_inst_tbl  => x_model_inst_tbl);

    /*
    IF x_model_inst_tbl.count > 0 THEN
      FOR l_mod in x_model_inst_tbl.first..x_model_inst_tbl.last
      LOOP

        build_non_source_rec(
          p_transaction_line_id  => p_trx_line_id,
          p_parent_line_id       => x_model_inst_tbl(l_mod).parent_line_id,
          p_instance_id          => x_model_inst_tbl(l_mod).instance_id,
          x_txn_line_dtl_id      => l_nsrc_line_dtl_id,
          x_return_status        => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        x_model_inst_tbl(l_mod).txn_line_detail_id := l_nsrc_line_dtl_id;
      END LOOP;
    END IF;
    */

    IF x_model_inst_tbl.count = 1 THEN

      IF x_txn_line_dtl_tbl.count > 0 THEN
        FOR l_ind in x_txn_line_dtl_tbl.first..x_txn_line_dtl_tbl.last
        LOOP

          build_non_source_rec(
            p_transaction_line_id  => p_order_line_rec.trx_line_id,
            p_parent_line_id       => x_model_inst_tbl(1).parent_line_id,
            p_instance_id          => x_model_inst_tbl(1).instance_id,
            x_txn_line_dtl_id      => l_nsrc_line_dtl_id,
            x_return_status        => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          x_model_inst_tbl(1).txn_line_detail_id := l_nsrc_line_dtl_id;

          l_txn_ii := l_txn_ii + 1;

          --Build the table for creating the new instance relationships

          x_txn_ii_rltns_tbl(l_txn_ii).transaction_line_id := x_txn_line_dtl_tbl(l_ind).transaction_line_id;
          x_txn_ii_rltns_tbl(l_txn_ii).relationship_type_code := 'COMPONENT-OF';
          x_txn_ii_rltns_tbl(l_txn_ii).object_id  := x_model_inst_tbl(1).txn_line_detail_id;
          x_txn_ii_rltns_tbl(l_txn_ii).subject_id := x_txn_line_dtl_tbl(l_ind).txn_line_detail_id ;
          x_txn_ii_rltns_tbl(l_txn_ii).active_start_date := sysdate;--FND_API.G_MISS_DATE;

          -- mark the model instance that it is processed
          x_model_inst_tbl(1).process_flag := 'Y';

          ---Added (Start) for m-to-m enhancements
          x_txn_ii_rltns_tbl(l_txn_ii).subject_type  := 'T';
          x_txn_ii_rltns_tbl(l_txn_ii).object_type   :=  'T' ;
          ---Added (End) for m-to-m enhancements

        END LOOP;
      END IF;

    ELSIF x_model_inst_tbl.count > 1 THEN
      IF p_order_line_rec.item_type_code = 'CONFIG' THEN
        IF x_txn_line_dtl_tbl.count > 0 THEN
          FOR l_ind in x_txn_line_dtl_tbl.first..x_txn_line_dtl_tbl.last
          LOOP

            IF x_model_inst_tbl.count  > 0 THEN
              FOR k in x_model_inst_tbl.first..x_model_inst_tbl.last
              LOOP

                IF x_model_inst_tbl(k).process_flag <> 'Y' THEN

                  build_non_source_rec(
                    p_transaction_line_id  => p_order_line_rec.trx_line_id,
                    p_parent_line_id       => x_model_inst_tbl(k).parent_line_id,
                    p_instance_id          => x_model_inst_tbl(k).instance_id,
                    x_txn_line_dtl_id      => l_nsrc_line_dtl_id,
                    x_return_status        => l_return_status);

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                    RAISE fnd_api.g_exc_error;
                  END IF;

                  x_model_inst_tbl(k).txn_line_detail_id := l_nsrc_line_dtl_id;

                  /*Build the table for creating the new instance relationships */
                  l_txn_ii := l_txn_ii + 1;

                  x_txn_ii_rltns_tbl(l_txn_ii).transaction_line_id := x_txn_line_dtl_tbl(l_ind).transaction_line_id;
                  x_txn_ii_rltns_tbl(l_txn_ii).relationship_type_code := 'COMPONENT-OF';
                  x_txn_ii_rltns_tbl(l_txn_ii).object_id  := x_model_inst_tbl(k).txn_line_detail_id;
                  x_txn_ii_rltns_tbl(l_txn_ii).subject_id := x_txn_line_dtl_tbl(l_ind).txn_line_detail_id ;
                  x_txn_ii_rltns_tbl(l_txn_ii).active_start_date := sysdate;--FND_API.G_MISS_DATE;

                  -- mark the model instance that it is processed
                  x_model_inst_tbl(k).process_flag := 'Y';

                  ---Added (Start) for m-to-m enhancements
                  --- 04/24
                  x_txn_ii_rltns_tbl(l_txn_ii).subject_type  := 'T';
                  x_txn_ii_rltns_tbl(l_txn_ii).object_type   :=  'T' ;
                  ---Added (End) for m-to-m enhancements

                  EXIT;
                END IF;
              END LOOP;
            END IF; --x_model_inst_tbl.count  > 0
          END LOOP;
        END IF; -- x_txn_line_dtl_tbl.count > 0
      ELSE -- Item_type_code other than CONFIG
        IF x_txn_line_dtl_tbl.count > 0 THEN
          FOR l_ind in x_txn_line_dtl_tbl.first..x_txn_line_dtl_tbl.last
          LOOP
            l_txn_processed := 'N';

            IF x_model_inst_tbl.count > 0 THEN
              FOR j in x_model_inst_tbl.first..x_model_inst_tbl.last
              LOOP

                IF (x_model_inst_tbl(j).process_flag = 'N')
                   AND
                   (x_model_inst_tbl(j).rem_qty >= x_txn_line_dtl_tbl(l_ind).quantity) THEN

                  build_non_source_rec(
                    p_transaction_line_id  => p_order_line_rec.trx_line_id,
                    p_parent_line_id       => x_model_inst_tbl(j).parent_line_id,
                    p_instance_id          => x_model_inst_tbl(j).instance_id,
                    x_txn_line_dtl_id      => l_nsrc_line_dtl_id,
                    x_return_status        => l_return_status);

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                    RAISE fnd_api.g_exc_error;
                  END IF;

                  x_model_inst_tbl(j).txn_line_detail_id := l_nsrc_line_dtl_id;

                  l_txn_ii := l_txn_ii + 1;

                  /*Build the table for creating the new instance relationships */

                  x_txn_ii_rltns_tbl(l_txn_ii).transaction_line_id := x_txn_line_dtl_tbl(l_ind).transaction_line_id;
                  x_txn_ii_rltns_tbl(l_txn_ii).relationship_type_code := 'COMPONENT-OF';
                  x_txn_ii_rltns_tbl(l_txn_ii).subject_id :=  x_txn_line_dtl_tbl(l_ind).txn_line_detail_id;
                  x_txn_ii_rltns_tbl(l_txn_ii).object_id  :=  x_model_inst_tbl(j).txn_line_detail_id;
                  x_txn_ii_rltns_tbl(l_txn_ii).active_start_date := sysdate;--FND_API.G_MISS_DATE;

                  x_model_inst_tbl(j).rem_qty := x_model_inst_tbl(j).rem_qty - x_txn_line_dtl_tbl(l_ind).quantity;

                  l_txn_processed := 'Y';

                  IF x_model_inst_tbl(j).rem_qty = 0 THEN
                    x_model_inst_tbl(j).process_flag := 'Y';
                  END IF;

                  ---Added (Start) for m-to-m enhancements
                  ---04/24
                  x_txn_ii_rltns_tbl(l_txn_ii).subject_type  := 'T';
                  x_txn_ii_rltns_tbl(l_txn_ii).object_type   :=  'T' ;
                  ---Added (End) for m-to-m enhancements

                  EXIT;
                END IF;

              END LOOP;
            END IF; -- x_model_inst_tbl.count > 0

            IF l_txn_processed = 'N' THEN

              IF x_txn_line_dtl_tbl(l_ind).quantity > 1 THEN

                x_txn_line_dtls_lst.delete;

                split_txn_dtls(
                  split_txn_dtl_id      => x_txn_line_dtl_tbl(l_ind).txn_line_detail_id,
                  x_txn_line_dtls_lst   => x_txn_line_dtls_lst,
                  x_return_status       => l_return_status  );

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  debug('split_txn_dtls failed ');
                  RAISE fnd_api.g_exc_error;
                END IF;
              END IF;

              debug('x_txn_line_dtls_lst.count ='||x_txn_line_dtls_lst.count);

              IF x_txn_line_dtls_lst.count > 0 THEN
                FOR x_txn in x_txn_line_dtls_lst.first..x_txn_line_dtls_lst.last
                LOOP

                  IF x_model_inst_tbl.count > 0 THEN
                    FOR j in x_model_inst_tbl.first..x_model_inst_tbl.last
                    LOOP

                      IF (x_model_inst_tbl(j).process_flag = 'N') THEN

                        build_non_source_rec(
                          p_transaction_line_id  => p_order_line_rec.trx_line_id,
                          p_parent_line_id       => x_model_inst_tbl(j).parent_line_id,
                          p_instance_id          => x_model_inst_tbl(j).instance_id,
                          x_txn_line_dtl_id      => l_nsrc_line_dtl_id,
                          x_return_status        => l_return_status);

                        IF l_return_status <> fnd_api.g_ret_sts_success THEN
                          RAISE fnd_api.g_exc_error;
                        END IF;

                        x_model_inst_tbl(j).txn_line_detail_id := l_nsrc_line_dtl_id;

                        l_txn_ii := l_txn_ii + 1;

                        /*Build the table for creating the new instance relationships */

                        x_txn_ii_rltns_tbl(l_txn_ii).transaction_line_id := x_txn_line_dtl_tbl(l_ind).transaction_line_id;
                        x_txn_ii_rltns_tbl(l_txn_ii).relationship_type_code := 'COMPONENT-OF';
                        x_txn_ii_rltns_tbl(l_txn_ii).subject_id :=  x_txn_line_dtls_lst(x_txn).txn_line_detail_id;
                        x_txn_ii_rltns_tbl(l_txn_ii).object_id  :=  x_model_inst_tbl(j).txn_line_detail_id;
                        x_txn_ii_rltns_tbl(l_txn_ii).active_start_date := sysdate;--FND_API.G_MISS_DATE;

                        x_model_inst_tbl(j).rem_qty := x_model_inst_tbl(j).rem_qty - 1;

                        ---Added (Start) for m-to-m enhancements
                        x_txn_ii_rltns_tbl(l_txn_ii).subject_type  := 'T';
                        x_txn_ii_rltns_tbl(l_txn_ii).object_type   :=  'T' ;
                        ---Added (End) for m-to-m enhancements

                        debug('Relation Num   :'||l_txn_ii);
                        debug('Txn Object ID  :'||x_txn_ii_rltns_tbl(l_txn_ii).object_id);
                        debug('Txn Subject ID :'||x_txn_ii_rltns_tbl(l_txn_ii).subject_id);
                        debug('Remaining Qty  :'||x_model_inst_tbl(j).rem_qty);

                        IF x_model_inst_tbl(j).rem_qty = 0 THEN
                          x_model_inst_tbl(j).process_flag := 'Y';
                        END IF;

                        EXIT;
                      END IF; --(x_model_inst_tbl(j).process_flag = 'N')

                    END LOOP;
                  END IF; --x_txn_line_dtls_lst.count > 0

                  l_txn_processed := 'Y';

                END LOOP;
              END IF; --x_txn_line_dtls_lst.count > 0
            END IF; -- l_txn_processed = 'N
          END LOOP;
        END IF; --x_txn_line_dtl_tbl.count > 0
      END IF;
    END IF;

   debug('x_txn_ii_rltns_tbl.count ='||x_txn_ii_rltns_tbl.count );

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
  END build_parent_relation;


  PROCEDURE get_source_trx_dtls(
    p_mtl_transaction_id IN NUMBER,
    x_mtl_txn_rec        OUT NOCOPY csi_order_ship_pub.MTL_TXN_REC,
    x_error_message      OUT NOCOPY VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2)
  IS
  BEGIN

    api_log('get_source_trx_dtls');

    SELECT mmt.transaction_id ,
           oel.line_id,
           oeh.header_id,
           oeh.order_number,
           oel.line_id,
           oel.line_number||'.'||oel.shipment_number,
           mmt.transaction_date,
           mmt.transaction_id
    INTO   x_mtl_txn_rec.mtl_transaction_id,
           x_mtl_txn_rec.source_line_id,
           x_mtl_txn_rec.source_header_ref_id,
           x_mtl_txn_rec.source_header_ref,
           x_mtl_txn_rec.source_line_ref_id,
           x_mtl_txn_rec.source_line_ref,
           x_mtl_txn_rec.source_transaction_date,
           x_mtl_txn_rec.inv_material_transaction_id
    FROM   oe_order_headers_all oeh,
           oe_order_lines_all oel,
           mtl_material_transactions mmt
    WHERE  mmt.transaction_id = p_mtl_transaction_id
    AND    oel.line_id        = mmt.trx_source_line_id
    AND    oeh.header_id      = oel.header_id;

    debug('  Order Number :'||x_mtl_txn_rec.source_header_ref);
    debug('  Line Number  :'||x_mtl_txn_rec.source_line_ref);

    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('CSI','CSI_INT_ORD_LINE_MISSING');
      fnd_message.set_token('MTL_TRANSACTION_ID',p_mtl_transaction_id);
      fnd_msg_pub.add;
  END get_source_trx_dtls;

 PROCEDURE split_txn_dtls_with_qty( --Included the API for bug 4354267
    split_txn_dtl_id            IN  NUMBER,
    p_split_qty			IN NUMBER,
    x_return_status             OUT NOCOPY varchar2)
   IS
    l_txn_line_query_rec        csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_line_dtl_rec      csi_t_datastructures_grp.txn_line_detail_rec;
    l_line_dtl_tbl      csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl       csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl      csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl      csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl     csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_ext_attrib_tbl    csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_csi_ea_tbl        csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_csi_eav_tbl       csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_txn_systems_tbl   csi_t_datastructures_grp.txn_systems_tbl;
    l_transaction_line_id number;

    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count         number;
    l_msg_data          varchar2(2000);

  BEGIN

    api_log('split_txn_dtls_with_qty');

    x_return_status := fnd_api.g_ret_sts_success;


    l_txn_line_detail_query_rec.txn_line_detail_id := split_txn_dtl_id;

    csi_t_txn_details_grp.get_transaction_details(
      p_api_version                => 1.0,
      p_commit                     => fnd_api.g_false,
      p_init_msg_list              => fnd_api.g_true,
      p_validation_level           => fnd_api.g_valid_level_full,
      p_txn_line_query_rec         => l_txn_line_query_rec,
      p_txn_line_detail_query_rec  => l_txn_line_detail_query_rec,
      x_txn_line_detail_tbl        => l_line_dtl_tbl,
      p_get_parties_flag           => fnd_api.g_true,
      x_txn_party_detail_tbl       => l_pty_dtl_tbl,
      p_get_pty_accts_flag         => fnd_api.g_true,
      x_txn_pty_acct_detail_tbl    => l_pty_acct_tbl,
      p_get_ii_rltns_flag          => fnd_api.g_false,
      x_txn_ii_rltns_tbl           => l_ii_rltns_tbl,
      p_get_org_assgns_flag        => fnd_api.g_true,
      x_txn_org_assgn_tbl          => l_org_assgn_tbl,
      p_get_ext_attrib_vals_flag   => fnd_api.g_true,
      x_txn_ext_attrib_vals_tbl    => l_ext_attrib_tbl,
      p_get_csi_attribs_flag       => fnd_api.g_false,
      x_csi_ext_attribs_tbl        => l_csi_ea_tbl,
      p_get_csi_iea_values_flag    => fnd_api.g_false,
      x_csi_iea_values_tbl         => l_csi_eav_tbl,
      p_get_txn_systems_flag       => fnd_api.g_false,
      x_txn_systems_tbl            => l_txn_systems_tbl,
      x_return_status              => l_return_status,
      x_msg_count                  => l_msg_count,
      x_msg_data                   => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      debug('Get_transaction_details  failed ');
      RAISE fnd_api.g_exc_error;
    END IF;

    l_transaction_line_id := l_line_dtl_tbl(1).transaction_line_id;

    csi_t_utilities_pvt.convert_ids_to_index(
      px_line_dtl_tbl            => l_line_dtl_tbl,
      px_pty_dtl_tbl             => l_pty_dtl_tbl,
      px_pty_acct_tbl            => l_pty_acct_tbl,
      px_ii_rltns_tbl            => l_ii_rltns_tbl,
      px_org_assgn_tbl           => l_org_assgn_tbl,
      px_ext_attrib_tbl          => l_ext_attrib_tbl,
      px_txn_systems_tbl         => l_txn_systems_tbl);

    l_line_dtl_rec                     := l_line_dtl_tbl(1);
    l_line_dtl_rec.txn_line_detail_id  := FND_API.G_MISS_NUM;
    l_line_dtl_rec.transaction_line_id := l_transaction_line_id;
    l_line_dtl_rec.quantity            := p_split_qty ;
    l_line_dtl_rec.processing_status   := 'SUBMIT';

    debug('Splitting the txn_line_dtls INTO qty of '||p_split_qty);



      csi_t_txn_line_dtls_pvt.create_txn_line_dtls(
        p_api_version              => 1.0,
        p_commit                   => fnd_api.g_false,
        p_init_msg_list            => fnd_api.g_true,
        p_validation_level         => fnd_api.g_valid_level_full,
        p_txn_line_dtl_index       => 1,
        p_txn_line_dtl_rec         => l_line_dtl_rec,
        px_txn_party_dtl_tbl       => l_pty_dtl_tbl,
        px_txn_pty_acct_detail_tbl => l_pty_acct_tbl,
        px_txn_ii_rltns_tbl        => l_ii_rltns_tbl,
        px_txn_org_assgn_tbl       => l_org_assgn_tbl,
        px_txn_ext_attrib_vals_tbl => l_ext_attrib_tbl,
        x_return_status            => l_return_status,
        x_msg_count                => l_msg_count,
        x_msg_data                 => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        debug('Error Splitting txn line detail ');
        RAISE fnd_api.g_exc_error;
      END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
  END split_txn_dtls_with_qty;


  PROCEDURE split_txn_dtls(
    split_txn_dtl_id            IN  NUMBER,
    x_txn_line_dtls_lst         OUT NOCOPY txn_line_dtl_tbl,
    x_return_status             OUT NOCOPY varchar2)
  IS

    l_txn_line_query_rec        csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_line_dtl_rec      csi_t_datastructures_grp.txn_line_detail_rec;
    l_line_dtl_tbl      csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl       csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl      csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl      csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl     csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_ext_attrib_tbl    csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_csi_ea_tbl        csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_csi_eav_tbl       csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_txn_systems_tbl   csi_t_datastructures_grp.txn_systems_tbl;

    x_msg_count         number;
    x_msg_data          varchar2(2000);
    l_transaction_line_id number;

  BEGIN

    api_log('split_txn_dtls');

    x_return_status := fnd_api.g_ret_sts_success;

    x_txn_line_dtls_lst.delete;

    l_txn_line_detail_query_rec.txn_line_detail_id := split_txn_dtl_id;

    csi_t_txn_details_grp.get_transaction_details(
      p_api_version                => 1.0,
      p_commit                     => fnd_api.g_false,
      p_init_msg_list              => fnd_api.g_true,
      p_validation_level           => fnd_api.g_valid_level_full,
      p_txn_line_query_rec         => l_txn_line_query_rec,
      p_txn_line_detail_query_rec  => l_txn_line_detail_query_rec,
      x_txn_line_detail_tbl        => l_line_dtl_tbl,
      p_get_parties_flag           => fnd_api.g_true,
      x_txn_party_detail_tbl       => l_pty_dtl_tbl,
      p_get_pty_accts_flag         => fnd_api.g_true,
      x_txn_pty_acct_detail_tbl    => l_pty_acct_tbl,
      p_get_ii_rltns_flag          => fnd_api.g_false,
      x_txn_ii_rltns_tbl           => l_ii_rltns_tbl,
      p_get_org_assgns_flag        => fnd_api.g_true,
      x_txn_org_assgn_tbl          => l_org_assgn_tbl,
      p_get_ext_attrib_vals_flag   => fnd_api.g_true,
      x_txn_ext_attrib_vals_tbl    => l_ext_attrib_tbl,
      p_get_csi_attribs_flag       => fnd_api.g_false,
      x_csi_ext_attribs_tbl        => l_csi_ea_tbl,
      p_get_csi_iea_values_flag    => fnd_api.g_false,
      x_csi_iea_values_tbl         => l_csi_eav_tbl,
      p_get_txn_systems_flag       => fnd_api.g_false,
      x_txn_systems_tbl            => l_txn_systems_tbl,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data);

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      debug('Get_transaction_details  failed ');
      RAISE fnd_api.g_exc_error;
    END IF;

    l_transaction_line_id := l_line_dtl_tbl(1).transaction_line_id;

    csi_t_utilities_pvt.convert_ids_to_index(
      px_line_dtl_tbl            => l_line_dtl_tbl,
      px_pty_dtl_tbl             => l_pty_dtl_tbl,
      px_pty_acct_tbl            => l_pty_acct_tbl,
      px_ii_rltns_tbl            => l_ii_rltns_tbl,
      px_org_assgn_tbl           => l_org_assgn_tbl,
      px_ext_attrib_tbl          => l_ext_attrib_tbl,
      px_txn_systems_tbl         => l_txn_systems_tbl);

    l_line_dtl_rec                     := l_line_dtl_tbl(1);
    l_line_dtl_rec.txn_line_detail_id  := FND_API.G_MISS_NUM;
    l_line_dtl_rec.transaction_line_id := l_transaction_line_id;
    l_line_dtl_rec.quantity            := 1 ;
    l_line_dtl_rec.processing_status   := 'IN_PROCESS';

    debug('Splitting the txn_line_dtls INTO qty of one');

    update csi_t_txn_line_details
    set quantity = 1
    WHERE txn_line_detail_id = split_txn_dtl_id;

    x_txn_line_dtls_lst(x_txn_line_dtls_lst.count+1).txn_line_detail_id := split_txn_dtl_id;

    FOR l_index in 1..(l_line_dtl_tbl(1).quantity -1 )
    LOOP

      csi_t_txn_line_dtls_pvt.create_txn_line_dtls(
        p_api_version              => 1.0,
        p_commit                   => fnd_api.g_false,
        p_init_msg_list            => fnd_api.g_true,
        p_validation_level         => fnd_api.g_valid_level_full,
        p_txn_line_dtl_index       => 1,
        p_txn_line_dtl_rec         => l_line_dtl_rec,
        px_txn_party_dtl_tbl       => l_pty_dtl_tbl,
        px_txn_pty_acct_detail_tbl => l_pty_acct_tbl,
        px_txn_ii_rltns_tbl        => l_ii_rltns_tbl,
        px_txn_org_assgn_tbl       => l_org_assgn_tbl,
        px_txn_ext_attrib_vals_tbl => l_ext_attrib_tbl,
        x_return_status            => x_return_status,
        x_msg_count                => x_msg_count,
        x_msg_data                 => x_msg_data);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        debug('Error Splitting txn line detail ');
        RAISE fnd_api.g_exc_error;
      END IF;

      x_txn_line_dtls_lst(x_txn_line_dtls_lst.count+1).txn_line_detail_id :=
      l_line_dtl_rec.txn_line_detail_id;

      l_line_dtl_tbl(1) := l_line_dtl_rec;

      csi_t_utilities_pvt.convert_ids_to_index(
        px_line_dtl_tbl            => l_line_dtl_tbl,
        px_pty_dtl_tbl             => l_pty_dtl_tbl,
        px_pty_acct_tbl            => l_pty_acct_tbl,
        px_ii_rltns_tbl            => l_ii_rltns_tbl,
        px_org_assgn_tbl           => l_org_assgn_tbl,
        px_ext_attrib_tbl          => l_ext_attrib_tbl,
        px_txn_systems_tbl         => l_txn_systems_tbl);

      l_line_dtl_rec                     := l_line_dtl_tbl(1);
      l_line_dtl_rec.txn_line_detail_id  := FND_API.G_MISS_NUM;
      l_line_dtl_rec.transaction_line_id := l_transaction_line_id;
      l_line_dtl_rec.quantity            := 1 ;
      l_line_dtl_rec.processing_status   := 'IN_PROCESS';


    END LOOP;

    debug('No of txn line detail ='||x_txn_line_dtls_lst.count);
    debug('Txn line detail for Non Source created Successfully');

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
  END split_txn_dtls;

  PROCEDURE get_system_tbl(
    p_txn_systems_rec            IN  csi_t_datastructures_grp.txn_system_rec,
    x_cre_systems_rec            OUT NOCOPY csi_datastructures_pub.system_rec)
  IS
  BEGIN

    api_log('get_system_tbl');

    x_cre_systems_rec.name                  := p_txn_systems_rec.system_name;
    x_cre_systems_rec.description           := p_txn_systems_rec.description;
    x_cre_systems_rec.system_type_code      := p_txn_systems_rec.system_type_code;
    x_cre_systems_rec.system_number         := p_txn_systems_rec.system_number;
    x_cre_systems_rec.customer_id           := p_txn_systems_rec.customer_id;
    x_cre_systems_rec.ship_to_contact_id    := p_txn_systems_rec.ship_to_contact_id;
    x_cre_systems_rec.bill_to_contact_id    := p_txn_systems_rec.bill_to_contact_id;
    x_cre_systems_rec.technical_contact_id  := p_txn_systems_rec.technical_contact_id;
    x_cre_systems_rec.service_admin_contact_id := p_txn_systems_rec.service_admin_contact_id;
    x_cre_systems_rec.ship_to_site_use_id   := p_txn_systems_rec.ship_to_site_use_id;
    x_cre_systems_rec.bill_to_site_use_id   := p_txn_systems_rec.bill_to_site_use_id;
    x_cre_systems_rec.install_site_use_id   := p_txn_systems_rec.install_site_use_id;
    x_cre_systems_rec.coterminate_day_month := p_txn_systems_rec.coterminate_day_month;
    x_cre_systems_rec.config_system_type    := p_txn_systems_rec.config_system_type;
    x_cre_systems_rec.start_date_active     := p_txn_systems_rec.start_date_active;
    x_cre_systems_rec.end_date_active       := p_txn_systems_rec.end_date_active ;
    x_cre_systems_rec.context               := p_txn_systems_rec.context;
    x_cre_systems_rec.attribute1            := p_txn_systems_rec.attribute1;
    x_cre_systems_rec.attribute2            := p_txn_systems_rec.attribute2;
    x_cre_systems_rec.attribute3            := p_txn_systems_rec.attribute3;
    x_cre_systems_rec.attribute4            := p_txn_systems_rec.attribute4;
    x_cre_systems_rec.attribute5            := p_txn_systems_rec.attribute5;
    x_cre_systems_rec.attribute6            := p_txn_systems_rec.attribute6;
    x_cre_systems_rec.attribute7            := p_txn_systems_rec.attribute7;
    x_cre_systems_rec.attribute8            := p_txn_systems_rec.attribute8;
    x_cre_systems_rec.attribute9            := p_txn_systems_rec.attribute9;
    x_cre_systems_rec.attribute10           := p_txn_systems_rec.attribute10;
    x_cre_systems_rec.attribute11           := p_txn_systems_rec.attribute11;
    x_cre_systems_rec.attribute12           := p_txn_systems_rec.attribute12;
    x_cre_systems_rec.attribute13           := p_txn_systems_rec.attribute13;
    x_cre_systems_rec.attribute14           := p_txn_systems_rec.attribute14;
    x_cre_systems_rec.attribute15           := p_txn_systems_rec.attribute15;
    x_cre_systems_rec.object_version_numbeR := fnd_api.g_miss_num;

  END get_system_tbl;


  PROCEDURE get_org_assignment_tbl(
    p_txn_line_detail_rec        IN  csi_t_datastructures_grp.txn_line_detail_rec,
    p_txn_org_assgn_tbl          IN  csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_cre_org_units_tbl          OUT NOCOPY csi_datastructures_pub.organization_units_tbl,
    x_upd_org_units_tbl          OUT NOCOPY csi_datastructures_pub.organization_units_tbl,
    x_return_status              OUT NOCOPY VARCHAR2)
  IS
    l_upd_org                  NUMBER := 1;
    l_cre_org                  NUMBER := 1;
    l_date                     DATE := TO_DATE('01/01/4712', 'MM/DD/YYYY');
    l_obj_ver_num              NUMBER;

    l_instance_ou_id           number;

  BEGIN

    api_log('get_org_assignment_tbl');

    x_return_status := fnd_api.g_ret_sts_success;

    /* Build org_assignment table for create/update */
    IF p_txn_org_assgn_tbl.count > 0 THEN
      FOR j in p_txn_org_assgn_tbl.FIRST..p_txn_org_assgn_tbl.LAST LOOP

        IF (p_txn_org_assgn_tbl(j).txn_line_detail_id = p_txn_line_detail_rec.txn_line_detail_id) AND
           (( NVL(p_txn_org_assgn_tbl(j).active_end_date,l_date) > sysdate ) OR
            (p_txn_org_assgn_tbl(j).active_end_date = FND_API.G_MISS_DATE )) THEN


          l_instance_ou_id := p_txn_org_assgn_tbl(j).instance_ou_id;

          IF NVL(p_txn_org_assgn_tbl(j).instance_ou_id ,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then

            /* there should be only one org assign rec for the alternate primary key
               this is a rectriction from the api
            */
            BEGIN
              SELECT instance_ou_id
              INTO   l_instance_ou_id
              FROM   csi_i_org_assignments
              WHERE  instance_id            = p_txn_line_detail_rec.instance_id
              AND    relationship_type_code = p_txn_org_assgn_tbl(j).relationship_type_code;
             -- AND    operating_unit_id      = p_txn_org_assgn_tbl(j).operating_unit_id; for 4293740
            EXCEPTION
              WHEN no_data_found THEN
                l_instance_ou_id := null;
              WHEN too_many_rows THEN
                /* in case many found taking the active one */

                BEGIN
                  SELECT instance_ou_id
                  INTO   l_instance_ou_id
                  FROM   csi_i_org_assignments
                  WHERE  instance_id            = p_txn_line_detail_rec.instance_id
                  AND    relationship_type_code = p_txn_org_assgn_tbl(j).relationship_type_code
                  AND    operating_unit_id      = p_txn_org_assgn_tbl(j).operating_unit_id
                  AND    (sysdate > nvl(active_start_date, sysdate-1)
                          AND
                          sysdate < nvl(active_end_date, sysdate + 1));
                EXCEPTION
                  WHEN others THEN
                    l_instance_ou_id := null;
                END;
            END;
          END IF;

          IF NVL(l_instance_ou_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then

            /* if the instance_ou_id does not exist then update for org_units  */
            l_obj_ver_num := csi_utl_pkg.get_org_obj_ver_num(
                               l_instance_ou_id);

            IF l_obj_ver_num = -1  THEN
              debug('csi_utl_pkg.get_org_obj_ver_num failed ');
              RAISE fnd_api.g_exc_error;
            END IF;

            x_upd_org_units_tbl(l_upd_org).instance_ou_id    := l_instance_ou_id;
            x_upd_org_units_tbl(l_upd_org).instance_id       := p_txn_line_detail_rec.instance_id;
            x_upd_org_units_tbl(l_upd_org).operating_unit_id := p_txn_org_assgn_tbl(j).operating_unit_id;
            x_upd_org_units_tbl(l_upd_org).relationship_type_code := p_txn_org_assgn_tbl(j).relationship_type_code;
            x_upd_org_units_tbl(l_upd_org).active_end_date  := null;
            x_upd_org_units_tbl(l_upd_org).context          := p_txn_org_assgn_tbl(j).context    ;
            x_upd_org_units_tbl(l_upd_org).attribute1       := p_txn_org_assgn_tbl(j).attribute1 ;
            x_upd_org_units_tbl(l_upd_org).attribute2       := p_txn_org_assgn_tbl(j).attribute2 ;
            x_upd_org_units_tbl(l_upd_org).attribute3       := p_txn_org_assgn_tbl(j).attribute3 ;
            x_upd_org_units_tbl(l_upd_org).attribute4       := p_txn_org_assgn_tbl(j).attribute4 ;
            x_upd_org_units_tbl(l_upd_org).attribute5       := p_txn_org_assgn_tbl(j).attribute5 ;
            x_upd_org_units_tbl(l_upd_org).attribute6       := p_txn_org_assgn_tbl(j).attribute6 ;
            x_upd_org_units_tbl(l_upd_org).attribute7       := p_txn_org_assgn_tbl(j).attribute7 ;
            x_upd_org_units_tbl(l_upd_org).attribute8       := p_txn_org_assgn_tbl(j).attribute8 ;
            x_upd_org_units_tbl(l_upd_org).attribute9       := p_txn_org_assgn_tbl(j).attribute9 ;
            x_upd_org_units_tbl(l_upd_org).attribute10      := p_txn_org_assgn_tbl(j).attribute10;
            x_upd_org_units_tbl(l_upd_org).attribute11      := p_txn_org_assgn_tbl(j).attribute11;
            x_upd_org_units_tbl(l_upd_org).attribute12      := p_txn_org_assgn_tbl(j).attribute12;
            x_upd_org_units_tbl(l_upd_org).attribute13      := p_txn_org_assgn_tbl(j).attribute13;
            x_upd_org_units_tbl(l_upd_org).attribute14      := p_txn_org_assgn_tbl(j).attribute14;
            x_upd_org_units_tbl(l_upd_org).attribute15      := p_txn_org_assgn_tbl(j).attribute15 ;
            x_upd_org_units_tbl(l_upd_org).object_version_number := l_obj_ver_num;

            l_upd_org := l_upd_org + 1;
          ELSE

            /* if instance_ou_id does  exist then create for org assignment  */

            x_cre_org_units_tbl(l_cre_org).instance_ou_id    := FND_API.G_MISS_NUM;
            x_cre_org_units_tbl(l_cre_org).operating_unit_id := p_txn_org_assgn_tbl(j).operating_unit_id;
            x_cre_org_units_tbl(l_cre_org).instance_id       := p_txn_line_detail_rec.instance_id;
            x_cre_org_units_tbl(l_cre_org).relationship_type_code := p_txn_org_assgn_tbl(j).relationship_type_code;
            x_cre_org_units_tbl(l_cre_org).active_start_date := FND_API.G_MISS_DATE ;
            x_cre_org_units_tbl(l_cre_org).active_end_date   := p_txn_org_assgn_tbl(j).active_end_date;
            x_cre_org_units_tbl(l_cre_org).context          := p_txn_org_assgn_tbl(j).context    ;
            x_cre_org_units_tbl(l_cre_org).attribute1       := p_txn_org_assgn_tbl(j).attribute1 ;
            x_cre_org_units_tbl(l_cre_org).attribute2       := p_txn_org_assgn_tbl(j).attribute2 ;
            x_cre_org_units_tbl(l_cre_org).attribute3       := p_txn_org_assgn_tbl(j).attribute3 ;
            x_cre_org_units_tbl(l_cre_org).attribute4       := p_txn_org_assgn_tbl(j).attribute4 ;
            x_cre_org_units_tbl(l_cre_org).attribute5       := p_txn_org_assgn_tbl(j).attribute5 ;
            x_cre_org_units_tbl(l_cre_org).attribute6       := p_txn_org_assgn_tbl(j).attribute6 ;
            x_cre_org_units_tbl(l_cre_org).attribute7       := p_txn_org_assgn_tbl(j).attribute7 ;
            x_cre_org_units_tbl(l_cre_org).attribute8       := p_txn_org_assgn_tbl(j).attribute8 ;
            x_cre_org_units_tbl(l_cre_org).attribute9       := p_txn_org_assgn_tbl(j).attribute9 ;
            x_cre_org_units_tbl(l_cre_org).attribute10      := p_txn_org_assgn_tbl(j).attribute10;
            x_cre_org_units_tbl(l_cre_org).attribute11      := p_txn_org_assgn_tbl(j).attribute11;
            x_cre_org_units_tbl(l_cre_org).attribute12      := p_txn_org_assgn_tbl(j).attribute12;
            x_cre_org_units_tbl(l_cre_org).attribute13      := p_txn_org_assgn_tbl(j).attribute13;
            x_cre_org_units_tbl(l_cre_org).attribute14      := p_txn_org_assgn_tbl(j).attribute14;
            x_cre_org_units_tbl(l_cre_org).attribute15      := p_txn_org_assgn_tbl(j).attribute15 ;
            x_cre_org_units_tbl(l_cre_org).object_version_number := FND_API.G_MISS_NUM;

            l_cre_org := l_cre_org + 1;
          END IF; -- end if for instance_ou_id is not null

        END IF; -- end if for txn.txn_line_detail_id = org.txn_line_detail_id

      END LOOP; -- end of org assignment table loop
    END IF;-- end of org assignment table count > 0

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
  END get_org_assignment_tbl;

  PROCEDURE get_ext_attribs_tbl(
    p_txn_line_detail_rec        IN  csi_t_datastructures_grp.txn_line_detail_rec,
    p_txn_ext_attrib_vals_tbl    IN  csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_cre_ext_attrib_val_tbl     OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl,
    x_upd_ext_attrib_val_tbl     OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl,
    x_return_status              OUT NOCOPY VARCHAR2)
  IS

    l_cre_ext                  NUMBER := 1;
    l_upd_ext                  NUMBER := 1;
    l_date                     DATE   := TO_DATE('01/01/4712', 'MM/DD/YYYY');
    l_obj_ver_num              NUMBER;

  BEGIN

    api_log('get_ext_attribs_tbl');

    x_return_status := fnd_api.g_ret_sts_success;

    /* Build ext attribs table for create/update */
    IF p_txn_ext_attrib_vals_tbl.count > 0 THEN
      FOR j in p_txn_ext_attrib_vals_tbl.FIRST..p_txn_ext_attrib_vals_tbl.LAST LOOP

        IF (p_txn_ext_attrib_vals_tbl(j).txn_line_detail_id = p_txn_line_detail_rec.txn_line_detail_id ) AND
           ((NVL(p_txn_ext_attrib_vals_tbl(j).active_end_date,l_date) > sysdate ) OR
            (p_txn_ext_attrib_vals_tbl(j).active_end_date = FND_API.G_MISS_DATE )) AND
           (p_txn_ext_attrib_vals_tbl(j).PROCESS_FLAG = 'Y') THEN

          debug('attrib_source_table  ='||p_txn_ext_attrib_vals_tbl(j).attrib_source_table);

          IF (p_txn_ext_attrib_vals_tbl(j).attrib_source_table = 'CSI_I_EXTENDED_ATTRIBS') THEN

            x_cre_ext_attrib_val_tbl(l_cre_ext).attribute_id     := p_txn_ext_attrib_vals_tbl(j).attribute_source_id;
            x_cre_ext_attrib_val_tbl(l_cre_ext).instance_id      := p_txn_line_detail_rec.instance_id;
            x_cre_ext_attrib_val_tbl(l_cre_ext).attribute_value  := p_txn_ext_attrib_vals_tbl(j).attribute_value;
            x_cre_ext_attrib_val_tbl(l_cre_ext).active_start_date := FND_API.G_MISS_DATE ;
            x_cre_ext_attrib_val_tbl(l_cre_ext).active_end_date  := p_txn_ext_attrib_vals_tbl(j).active_end_date;
            x_cre_ext_attrib_val_tbl(l_cre_ext).context          := p_txn_ext_attrib_vals_tbl(j).context    ;
            x_cre_ext_attrib_val_tbl(l_cre_ext).attribute1       := p_txn_ext_attrib_vals_tbl(j).attribute1 ;
            x_cre_ext_attrib_val_tbl(l_cre_ext).attribute2       := p_txn_ext_attrib_vals_tbl(j).attribute2 ;
            x_cre_ext_attrib_val_tbl(l_cre_ext).attribute3       := p_txn_ext_attrib_vals_tbl(j).attribute3 ;
            x_cre_ext_attrib_val_tbl(l_cre_ext).attribute4       := p_txn_ext_attrib_vals_tbl(j).attribute4 ;
            x_cre_ext_attrib_val_tbl(l_cre_ext).attribute5       := p_txn_ext_attrib_vals_tbl(j).attribute5 ;
            x_cre_ext_attrib_val_tbl(l_cre_ext).attribute6       := p_txn_ext_attrib_vals_tbl(j).attribute6 ;
            x_cre_ext_attrib_val_tbl(l_cre_ext).attribute7       := p_txn_ext_attrib_vals_tbl(j).attribute7 ;
            x_cre_ext_attrib_val_tbl(l_cre_ext).attribute8       := p_txn_ext_attrib_vals_tbl(j).attribute8 ;
            x_cre_ext_attrib_val_tbl(l_cre_ext).attribute9       := p_txn_ext_attrib_vals_tbl(j).attribute9 ;
            x_cre_ext_attrib_val_tbl(l_cre_ext).attribute10      := p_txn_ext_attrib_vals_tbl(j).attribute10;
            x_cre_ext_attrib_val_tbl(l_cre_ext).attribute11      := p_txn_ext_attrib_vals_tbl(j).attribute11;
            x_cre_ext_attrib_val_tbl(l_cre_ext).attribute12      := p_txn_ext_attrib_vals_tbl(j).attribute12;
            x_cre_ext_attrib_val_tbl(l_cre_ext).attribute13      := p_txn_ext_attrib_vals_tbl(j).attribute13;
            x_cre_ext_attrib_val_tbl(l_cre_ext).attribute14      := p_txn_ext_attrib_vals_tbl(j).attribute14;
            x_cre_ext_attrib_val_tbl(l_cre_ext).attribute15      := p_txn_ext_attrib_vals_tbl(j).attribute15 ;
            x_cre_ext_attrib_val_tbl(l_cre_ext).object_version_number  := FND_API.G_MISS_NUM;

            l_cre_ext := l_cre_ext + 1;
          ELSIF (p_txn_ext_attrib_vals_tbl(j).attrib_source_table = 'CSI_IEA_VALUES') THEN

            l_obj_ver_num := csi_utl_pkg.get_ext_obj_ver_num(
                               p_txn_ext_attrib_vals_tbl(j).attribute_source_id);

            IF l_obj_ver_num = -1  THEN
              debug('csi_utl_pkg.get_ext_obj_ver_num failed ');
              RAISE fnd_api.g_exc_error;
            END IF;

            x_upd_ext_attrib_val_tbl(l_upd_ext).attribute_value_id := p_txn_ext_attrib_vals_tbl(j).attribute_source_id;
            x_upd_ext_attrib_val_tbl(l_upd_ext).attribute_value  := p_txn_ext_attrib_vals_tbl(j).attribute_value;
            x_upd_ext_attrib_val_tbl(l_upd_ext).instance_id      := p_txn_line_detail_rec.instance_id;
            x_upd_ext_attrib_val_tbl(l_upd_ext).active_end_date  := p_txn_ext_attrib_vals_tbl(j).active_end_date;
            x_upd_ext_attrib_val_tbl(l_upd_ext).context          := p_txn_ext_attrib_vals_tbl(j).context    ;
            x_upd_ext_attrib_val_tbl(l_upd_ext).attribute1       := p_txn_ext_attrib_vals_tbl(j).attribute1 ;
            x_upd_ext_attrib_val_tbl(l_upd_ext).attribute2       := p_txn_ext_attrib_vals_tbl(j).attribute2 ;
            x_upd_ext_attrib_val_tbl(l_upd_ext).attribute3       := p_txn_ext_attrib_vals_tbl(j).attribute3 ;
            x_upd_ext_attrib_val_tbl(l_upd_ext).attribute4       := p_txn_ext_attrib_vals_tbl(j).attribute4 ;
            x_upd_ext_attrib_val_tbl(l_upd_ext).attribute5       := p_txn_ext_attrib_vals_tbl(j).attribute5 ;
            x_upd_ext_attrib_val_tbl(l_upd_ext).attribute6       := p_txn_ext_attrib_vals_tbl(j).attribute6 ;
            x_upd_ext_attrib_val_tbl(l_upd_ext).attribute7       := p_txn_ext_attrib_vals_tbl(j).attribute7 ;
            x_upd_ext_attrib_val_tbl(l_upd_ext).attribute8       := p_txn_ext_attrib_vals_tbl(j).attribute8 ;
            x_upd_ext_attrib_val_tbl(l_upd_ext).attribute9       := p_txn_ext_attrib_vals_tbl(j).attribute9 ;
            x_upd_ext_attrib_val_tbl(l_upd_ext).attribute10      := p_txn_ext_attrib_vals_tbl(j).attribute10;
            x_upd_ext_attrib_val_tbl(l_upd_ext).attribute11      := p_txn_ext_attrib_vals_tbl(j).attribute11;
            x_upd_ext_attrib_val_tbl(l_upd_ext).attribute12      := p_txn_ext_attrib_vals_tbl(j).attribute12;
            x_upd_ext_attrib_val_tbl(l_upd_ext).attribute13      := p_txn_ext_attrib_vals_tbl(j).attribute13;
            x_upd_ext_attrib_val_tbl(l_upd_ext).attribute14      := p_txn_ext_attrib_vals_tbl(j).attribute14;
            x_upd_ext_attrib_val_tbl(l_upd_ext).attribute15      := p_txn_ext_attrib_vals_tbl(j).attribute15 ;
            x_upd_ext_attrib_val_tbl(l_upd_ext).object_version_number := l_obj_ver_num;

            l_upd_ext := l_upd_ext + 1;
          END IF; -- end if for ATTRIB_SOURCE_TABLE comparison

        END IF; -- end if for ext.txn_line_detail_id = txn.txn_line_detail_id

      END LOOP; -- end of ext attributes table loop
    END IF;-- end of ext attributes count > 0

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
  END get_ext_attribs_tbl;

    /*  Added p_trx_rec for ER 2581101 */

  PROCEDURE amend_contracts(
    p_relationship_type_code in  varchar2,
    p_object_instance_id     in  number,
    p_subject_instance_id    in  number,
    p_trx_rec                in  csi_datastructures_pub.transaction_rec,
    x_return_status          OUT NOCOPY varchar2)
  IS
    l_return_status  varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count      number;
    l_msg_data       varchar2(2000);

    l_old_instance_id  number := null;
    l_new_instance_id  number := null;
    l_process_flag     boolean := TRUE;

   /*  Fix for ER 2581101  */

    l_upd_instance_rec           csi_datastructures_pub.instance_rec;
    l_upd_party_tbl              csi_datastructures_pub.party_tbl;
    l_upd_party_acct_tbl         csi_datastructures_pub.party_account_tbl;
    l_upd_pricing_attribs_tbl    csi_datastructures_pub.pricing_attribs_tbl;
    l_upd_ext_attrib_val_tbl     csi_datastructures_pub.extend_attrib_values_tbl;
    l_upd_org_units_tbl          csi_datastructures_pub.organization_units_tbl;
    l_upd_inst_asset_tbl         csi_datastructures_pub.instance_asset_tbl;
    l_upd_inst_id_lst            csi_datastructures_pub.id_tbl;
    l_upd_txn_rec                csi_datastructures_pub.transaction_rec;
    l_non_source_change_owner    VARCHAR2(1);
    l_non_src_change_owner_code  VARCHAR2(1);
    l_location_code              VARCHAR2(30);
    l_object_version_number      NUMBER;
    px_oks_txn_inst_tbl          oks_ibint_pub.txn_instance_tbl;

   /* End of  Fix for ER 2581101  */

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    l_upd_txn_rec   := p_trx_rec;

    api_log('amend_contracts');

    l_process_flag := TRUE;

    /* bug 2355589 the relationship should be read from subject to object */
    IF p_relationship_type_code    = 'REPLACED-BY' THEN

      -- SUBJECT replaced by OBJECT
      -- OLD replaced by NEW
      --
      l_old_instance_id := p_subject_instance_id;
      l_new_instance_id := p_object_instance_id;

    ELSIF p_relationship_type_code = 'REPLACEMENT-FOR' THEN

      -- SUBJECT replacement for OBJECT
      -- NEW replacement for OLD
      --
      l_new_instance_id := p_subject_instance_id;
      l_old_instance_id := p_object_instance_id;

    ELSIF p_relationship_type_code = 'UPGRADED-FROM' THEN

      -- SUBJECT upgraded from OBJECT
      -- NEW upgraded from OLD
      --
      l_new_instance_id := p_subject_instance_id;
      l_old_instance_id := p_object_instance_id;

    ELSE
      l_process_flag := FALSE;
      debug('  Not a valid relationship to process contracts.');
    END IF;

    -- additional check to see if both the source and non source points to the same instance
    IF l_process_flag THEN
      debug(' old_instance_id :'||l_old_instance_id);
      debug(' new_instance_id :'||l_new_instance_id);

      -- do nothing if both are same
      IF l_old_instance_id = l_new_instance_id THEN
        l_process_flag := FALSE;
      END IF;

    END IF;

    IF l_process_flag THEN

      csi_t_gen_utility_pvt.dump_api_info(
        p_pkg_name => 'csi_item_instance_pvt',
        p_api_name => 'call_to_contracts');

      csi_item_instance_pvt.call_to_contracts(
        p_transaction_type   => 'RPL',
        p_instance_id        => l_old_instance_id,
        p_new_instance_id    => l_new_instance_id,
        p_vld_org_id         => null,
        p_quantity           => null,
        p_party_account_id1  => null,
        p_party_account_id2  => null,
        p_transaction_date   => p_trx_rec.transaction_date, -- null for Bug # 3483763
        p_source_transaction_date   => p_trx_rec.source_transaction_date,
        p_oks_txn_inst_tbl   => px_oks_txn_inst_tbl,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        raise fnd_api.g_exc_error;
      END IF;
      --
      IF px_oks_txn_inst_tbl.count > 0 THEN
	 csi_gen_utility_pvt.dump_oks_txn_inst_tbl(px_oks_txn_inst_tbl);
	 csi_gen_utility_pvt.put_line('Calling OKS Core API...');
	 --
         UPDATE CSI_TRANSACTIONS
         set contracts_invoked = 'Y'
         where transaction_id = p_trx_rec.transaction_id;
         --
	 OKS_IBINT_PUB.IB_interface
	    (
	      P_Api_Version           =>  1.0,
	      P_init_msg_list         =>  fnd_api.g_true,
	      P_single_txn_date_flag  =>  'Y',
	      P_Batch_type            =>  NULL,
	      P_Batch_ID              =>  NULL,
	      P_OKS_Txn_Inst_tbl      =>  px_oks_txn_inst_tbl,
	      x_return_status         =>  l_return_status,
	      x_msg_count             =>  l_msg_count,
	      x_msg_data              =>  l_msg_data
	   );
	 --
	 IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF;

      /*  Code fix for ER 2581101 */

      debug('Inside amend contracts sub type id :'|| p_trx_rec.txn_sub_type_id);

        BEGIN
          SELECT  non_src_change_owner,
                  non_src_change_owner_to_code
          INTO    l_non_source_change_owner,
                  l_non_src_change_owner_code
          FROM    csi_txn_sub_types
          WHERE   transaction_type_id = csi_order_ship_pub.g_txn_type_id
          AND     sub_type_id = p_trx_rec.txn_sub_type_id;

        EXCEPTION
          WHEN no_data_found THEN
              null;
        END;

        BEGIN
          SELECT object_version_number,
                 location_type_code
          INTO   l_object_version_number,
                 l_location_code
          FROM   csi_item_instances
          WHERE  instance_id = l_old_instance_id;

        EXCEPTION
          WHEN no_data_found THEN
              null;
        END;

      debug('  Instance ID     :'||l_old_instance_id);
      debug('  location Code   :'||l_location_code);
      DEBUG(' l_non_src_change_owner_code : '||l_non_src_change_owner_code);
      DEBUG(' l_non_source_change_owner   : '||l_non_source_change_owner);

      IF l_location_code = 'INVENTORY'
        AND
         l_non_source_change_owner = 'Y'
        AND
         l_non_src_change_owner_code = 'I'
      THEN
        debug(' Building Party Table');

        l_upd_party_tbl(1).instance_id            :=  l_old_instance_id;
        l_upd_party_tbl(1).party_source_table     :=  'HZ_PARTIES';
        l_upd_party_tbl(1).relationship_type_code :=  'OWNER';
        l_upd_party_tbl(1).contact_flag           :=  'N';

        BEGIN
          Select instance_party_id,
                 object_version_number
          Into   l_upd_party_tbl(1).instance_party_id,
                 l_upd_party_tbl(1).object_version_number
         From   csi_i_parties
         Where  instance_id = l_old_instance_id
         And    relationship_Type_code = 'OWNER';

        EXCEPTION
          When No_Data_Found Then
               NULL;
         END;

--commented SQL below to make changes for the bug 4028827
/*
         BEGIN
           Select internal_party_id
           Into   l_upd_party_tbl(1).party_id
           From   csi_install_parameters;

         EXCEPTION
           When NO_Data_Found Then
                NULL;
         END;
*/
        l_upd_party_tbl(1).party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;

        debug('Updating the Instance in Non Source Detail to Internal Party..');
        debug('Party Tbl count : '||l_upd_party_tbl.count);

        csi_t_gen_utility_pvt.dump_api_info(
           p_pkg_name => 'csi_item_instance_pub',
           p_api_name => 'update_item_instance');

          csi_item_instance_pub.update_item_instance(
            p_api_version           => 1.0,
            p_commit                => fnd_api.g_false,
            p_init_msg_list         => fnd_api.g_true,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_instance_rec          => l_upd_instance_rec,
            p_ext_attrib_values_tbl => l_upd_ext_attrib_val_tbl,
            p_party_tbl             => l_upd_party_tbl,
            p_account_tbl           => l_upd_party_acct_tbl,
            p_pricing_attrib_tbl    => l_upd_pricing_attribs_tbl,
            p_org_assignments_tbl   => l_upd_org_units_tbl,
            p_txn_rec               => l_upd_txn_rec,
            p_asset_assignment_tbl  => l_upd_inst_asset_tbl,
            x_instance_id_lst       => l_upd_inst_id_lst,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data );

         -- For Bug 4057183
         -- IF l_return_status <> fnd_api.g_ret_sts_success THEN
         IF l_return_status not in (fnd_api.g_ret_sts_success,'W') THEN
            RAISE fnd_api.g_exc_error;
         END IF;

      END IF;

      /*  End Of fix for ER 2581101 */

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END amend_contracts;

 /*  Added p_trx_rec for ER 2581101 */
  PROCEDURE get_ii_relation_tbl(
    p_txn_line_detail_tbl     IN csi_t_datastructures_grp.txn_line_detail_tbl,
    p_txn_ii_rltns_tbl        IN csi_t_datastructures_grp.txn_ii_rltns_tbl,
    p_trx_rec                 IN csi_datastructures_pub.transaction_rec,
    p_order_line_rec          IN csi_order_ship_pub.order_line_rec,
    x_cre_ii_rltns_tbl        OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
    x_upd_ii_rltns_tbl        OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
    x_return_status           OUT NOCOPY VARCHAR2)
  IS
    l_cre_ii             NUMBER := 1;
    l_upd_ii             NUMBER := 1;
    l_date               DATE := TO_DATE('01/01/4712', 'MM/DD/YYYY');
    l_object_inst_id     NUMBER;
    l_trx_type_id        NUMBER;
    l_subject_inst_id    NUMBER;
    l_obj_ver_num        NUMBER;
    l_return_status      varchar2(1) := fnd_api.g_ret_sts_success;

    /*  Added p_trx_rec for ER 2581101 */
    l_nsrc_sub_type_id   NUMBER;
    l_trx_rec            csi_datastructures_pub.transaction_rec;

    --l_srl_code           number := null;
    l_source_txn_header_id  NUMBER ;
    l_txn_line_query_rec    csi_t_datastructures_grp.txn_line_query_rec ;
    l_txn_line_detail_query_rec  csi_t_datastructures_grp.txn_line_detail_query_rec ;
    l_txn_line_detail_tbl  csi_t_datastructures_grp.txn_line_detail_tbl ;
    x_txn_party_detail_tbl csi_t_datastructures_grp.txn_party_detail_tbl ;
    x_txn_pty_acct_detail_tbl  csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    x_txn_ii_rltns_tbl     csi_t_datastructures_grp.txn_ii_rltns_tbl ;
    x_txn_org_assgn_tbl    csi_t_datastructures_grp.txn_org_assgn_tbl ;
    x_txn_ext_attrib_vals_tbl  csi_t_datastructures_grp.txn_ext_attrib_vals_tbl ;
    x_csi_ext_attribs_tbl  csi_t_datastructures_grp.csi_ext_attribs_tbl;
    x_csi_iea_values_tbl   csi_t_datastructures_grp.csi_ext_attrib_vals_tbl ;
    x_txn_systems_tbl      csi_t_datastructures_grp.txn_systems_tbl ;
    x_msg_count            NUMBER ;
    x_msg_data             VARCHAR2(2000);
    x_xface_to_IB_flag     VARCHAR2(1);
    l_index                NUMBER ;
    l_txn_dtl_line_found   BOOLEAN ;
    l_relation_exists      BOOLEAN ;
    l_tmp_txn_line_detail_tbl  csi_t_datastructures_grp.txn_line_detail_tbl ;
    x_tmp_txn_ii_rltns_tbl     csi_t_datastructures_grp.txn_ii_rltns_tbl ;
    l_exp_ii_relationship_rec  csi_datastructures_pub.ii_relationship_rec;
    l_exp_instance_id_tbl      csi_datastructures_pub.id_tbl;
    g_api_name                 varchar2(80);
    l_old_instance_id          NUMBER;
    l_new_instance_id          NUMBER;
    l_relationship_id          NUMBER;
    l_ii_rel_obj_ver_num       NUMBER;
    l_expire_object_id         NUMBER;
    l_object_version_number    NUMBER;
    l_object_id                NUMBER;
    l_relationship_type_code   VARCHAR2(30);
    l_valid_instance_no        NUMBER;
    l_transfer_components_flag VARCHAR2(1);
    l_config_instance          VARCHAR2(1);
    l_item_status              VARCHAR2(10);
    l_location_type_code       VARCHAR2(30);
    l_allow_object_replacement VARCHAR2(1);
    l_parent_instance_id       NUMBER;
    l_t_ii_count               NUMBER;
    l_found                    VARCHAR2(1);
    l_active_end_date          DATE;
    l_line_tbl                 oe_order_pub.line_tbl_type;
    /* Added for Bug 2972082 */
    l_cascade_owner_flag varchar2(1);

    CURSOR new_transfer_comp(p_instance_id IN NUMBER) IS
    SELECT relationship_id, object_version_number,
           subject_id, object_id, relationship_type_code
    FROM   csi_ii_relationships
    WHERE  object_id = p_instance_id
    AND    relationship_type_code = 'COMPONENT-OF'
    AND    (active_end_date is null OR active_end_date >= sysdate);

    CURSOR check_instance_status(p_instance_id IN NUMBER) IS
    SELECT distinct instance_number
    FROM   CSI_ITEM_INSTANCES cii, CSI_II_RELATIONSHIPS cir
    WHERE  owner_party_id NOT IN (SELECT internal_party_id
                                  FROM   csi_install_parameters)
    AND (cii.instance_id = cir.object_id or cii.instance_id = cir.subject_id)
    AND  cir.relationship_type_code = 'COMPONENT-OF'
    AND (cii.active_end_date is null or cii.active_end_date > sysdate)
    AND (cir.active_end_date is null or cir.active_end_date > sysdate)
    AND  cii.instance_id = p_instance_id;

    CURSOR check_instance_history(p_instance_id IN NUMBER) IS
    SELECT instance_history_id, new_location_type_code,
           new_instance_status_id
    FROM   csi_item_instances_h
    WHERE  instance_id = p_instance_id
    ORDER  BY instance_history_id desc;

    CURSOR rmarp_transfer_comp(p_instance_id IN NUMBER) IS
    SELECT relationship_id, object_version_number,
           subject_id, object_id, relationship_type_code
    FROM   csi_ii_relationships
    WHERE  object_id = p_instance_id
    AND    relationship_type_code = 'COMPONENT-OF';

    CURSOR check_item_status_validity(p_instance_id IN NUMBER) IS
    SELECT 'RMA' item_status
    FROM   csi_ii_relationships
    WHERE  subject_id = p_instance_id
    AND    relationship_type_code = 'COMPONENT-OF'
    AND    (active_end_date IS NOT NULL OR active_end_date <= sysdate)
    ORDER  BY RELATIONSHIP_ID DESC;

    CURSOR check_csi_t_ii_rel(p_instance_id IN NUMBER) IS
    SELECT txn_relationship_id, object_id, relationship_type_code
    FROM   csi_t_ii_relationships
    WHERE  object_id = p_instance_id
    AND    relationship_type_code = 'COMPONENT-OF'
    AND    active_end_date IS NULL;

    CURSOR chk_item_config(p_instance_id IN NUMBER) IS
    SELECT 'Y' config_instance, active_end_date
    FROM   csi_ii_relationships
    WHERE  subject_id = p_instance_id
    AND    relationship_type_code = 'COMPONENT-OF'
    ORDER  BY relationship_id DESC;
BEGIN

    api_log('get_ii_relation_tbl');

    x_return_status := fnd_api.g_ret_sts_success;

    l_trx_rec       := p_trx_rec;

   ---Get the relations(partners only) associated with the p_txn_line_detail_tbl

    FOR k IN p_txn_line_detail_tbl.FIRST ..  p_txn_line_detail_tbl.LAST
    LOOP
       ---get partner TLD and its details.
       get_partner_rltns
          (p_txn_line_detail_rec  => p_txn_line_detail_tbl(k) ,
          x_txn_ii_rltns_tbl => x_tmp_txn_ii_rltns_tbl ,
          x_txn_line_detail_tbl  => l_tmp_txn_line_detail_tbl,
          x_return_status => x_return_status );

           IF x_return_status <> fnd_api.g_ret_sts_success
           THEN
             raise fnd_api.g_exc_error;
           END IF;

      ---APpend the relations to main tbl

     IF x_tmp_txn_ii_rltns_tbl.COUNT > 0
     THEN
      FOR i IN x_tmp_txn_ii_rltns_tbl.FIRST .. x_tmp_txn_ii_rltns_tbl.LAST
      LOOP
        debug ('x_tmp_txn_ii_rltns_tbl(i).txn_relationship_id : '||
                  x_tmp_txn_ii_rltns_tbl(i).txn_relationship_id);
        l_relation_exists := FALSE ;

       IF x_txn_ii_rltns_tbl.COUNT > 0
       THEN
        FOR j IN x_txn_ii_rltns_tbl.FIRST .. x_txn_ii_rltns_tbl.LAST
        LOOP
           IF x_tmp_txn_ii_rltns_tbl(i).txn_relationship_id = x_txn_ii_rltns_tbl(j).txn_relationship_id
           THEN
              l_relation_exists := TRUE;
              EXIT ;
           END IF ;
        END LOOP ;
       END IF ;
        IF NOT l_relation_exists AND x_tmp_txn_ii_rltns_tbl.COUNT > 0
        THEN
           l_index := NVL(x_txn_ii_rltns_tbl.LAST,0)+1 ;
           x_txn_ii_rltns_tbl(l_index) := x_tmp_txn_ii_rltns_tbl(i) ;
        END IF ;
      END LOOP ;
     END IF ;

      ---APpend the txn line dtls to main tbl
     IF l_tmp_txn_line_detail_tbl.COUNT > 0
     THEN
      FOR i IN l_tmp_txn_line_detail_tbl.FIRST .. l_tmp_txn_line_detail_tbl.LAST
      LOOP
        l_txn_dtl_line_found := FALSE ;
       IF l_txn_line_detail_tbl.COUNT > 0
       THEN
        FOR j IN l_txn_line_detail_tbl.FIRST .. l_txn_line_detail_tbl.LAST
        LOOP
           IF l_tmp_txn_line_detail_tbl(i).txn_line_detail_id = l_txn_line_detail_tbl(j).txn_line_detail_id
           THEN
              l_txn_dtl_line_found := TRUE;
              EXIT ;
           END IF ;
        END LOOP ;
       END IF ;
        IF NOT l_txn_dtl_line_found AND l_tmp_txn_line_detail_tbl.COUNT > 0
        THEN
           l_txn_line_detail_tbl(NVL(l_txn_line_detail_tbl.LAST,0)+1) := l_tmp_txn_line_detail_tbl(i) ;
        END IF ;
      END LOOP ;
     END IF ;
    END LOOP ; ---p_txn_line_detail_tbl


       ---Append these partner tlds with the other tld
       FOR i IN p_txn_line_detail_tbl.FIRST .. p_txn_line_detail_tbl.LAST
       LOOP
	 l_txn_dtl_line_found := FALSE ;
        IF l_txn_line_detail_tbl.COUNT > 0
        THEN
	 FOR j IN l_txn_line_detail_tbl.FIRST .. l_txn_line_detail_tbl.LAST
	 LOOP
	   IF l_txn_line_detail_tbl(j).txn_line_detail_id = p_txn_line_detail_tbl(i).txn_line_detail_id
	   THEN
	      ---This txn line already exists in p_txn_line_detail_tbl
	      ---so copy it from p_txn_line_detail_tbl
              l_txn_line_detail_tbl(j) := p_txn_line_detail_tbl(i) ;
	      l_txn_dtl_line_found := TRUE ;
	      EXIT ;
           END IF ;
	 END LOOP ;
        END IF ;
	 IF NOT l_txn_dtl_line_found
	 THEN
	   ---apend at the end of the table
           l_index := NVL(l_txn_line_detail_tbl.LAST,0) + 1 ;
           l_txn_line_detail_tbl(l_index) := p_txn_line_detail_tbl(i) ;
         END IF ;
       END LOOP ;

    /* Process the instance_relationship */
    IF x_txn_ii_rltns_tbl.count > 0
    THEN
      FOR j in x_txn_ii_rltns_tbl.FIRST..x_txn_ii_rltns_tbl.LAST LOOP


        ---Added (Start) for m-to-m enhancements
        --04/24 added 'CONNECTED-TO' and did changes for
        --subject_type and object_type.
        -- process only these relations at this time

        rltns_xfaced_to_IB(x_txn_ii_rltns_tbl(j),
                          x_xface_to_IB_flag,x_return_status) ;

           IF x_return_status <> fnd_api.g_ret_sts_success
           THEN
             raise fnd_api.g_exc_error;
           END IF;


        ---Added (End) for m-to-m enhancements

        IF x_txn_ii_rltns_tbl(j).relationship_type_code
           IN ('COMPONENT-OF', 'REPLACED-BY', 'REPLACEMENT-FOR', 'UPGRADED-FROM','CONNECTED-TO')
        THEN

         IF x_txn_ii_rltns_tbl(j).object_type='T'
         THEN
         IF x_xface_to_IB_flag = 'N'
         THEN
            --Does this relations already interfaced to IB?
            ---If yes igonre
          /* derive object instance_id  */
          IF l_txn_line_detail_tbl.count > 0 THEN
            FOR i IN l_txn_line_detail_tbl.FIRST..l_txn_line_detail_tbl.LAST
            LOOP
              IF l_txn_line_detail_tbl(i).txn_line_detail_id = x_txn_ii_rltns_tbl(j).object_id
              THEN
                IF l_txn_line_detail_tbl(i).source_transaction_flag = 'Y' THEN
                  l_object_inst_id := l_txn_line_detail_tbl(i).changed_instance_id;
                ELSE
                  l_parent_instance_id := l_txn_line_detail_tbl(i).parent_instance_id;
                  l_object_inst_id := l_txn_line_detail_tbl(i).instance_id;
                      /*  Added p_trx_rec for ER 2581101 */
                  l_nsrc_sub_type_id := p_txn_line_detail_tbl(i).sub_type_id;
                END IF;
                EXIT;
              END IF;
            END LOOP;
          END IF; ---x_xface_to_IB_flag = 'N'
          END IF ;
         ELSE
           l_object_inst_id := x_txn_ii_rltns_tbl(j).object_id ;
         END IF ; ---x_txn_ii_rltns_tbl(j).object_type='T'

         IF x_txn_ii_rltns_tbl(j).subject_type='T'
         THEN
         IF x_xface_to_IB_flag = 'N'
         THEN
          /* derive subject instance_id */
          IF l_txn_line_detail_tbl.count > 0
          THEN
            FOR i IN l_txn_line_detail_tbl.FIRST..l_txn_line_detail_tbl.LAST LOOP
              IF l_txn_line_detail_tbl(i).txn_line_detail_id = x_txn_ii_rltns_tbl(j).subject_id
              THEN

                -- Begin Fix for Bug 2972082
                debug('txn_line_detail_id  = '||to_char(p_txn_line_detail_tbl(i).txn_line_detail_id));
                l_cascade_owner_flag := nvl(p_txn_line_detail_tbl(i).cascade_owner_flag,'N');
                -- End fix for Bug 2972082

                IF l_txn_line_detail_tbl(i).source_transaction_flag = 'Y' THEN
                  l_subject_inst_id := l_txn_line_detail_tbl(i).changed_instance_id;
                ELSE
                  l_subject_inst_id    := l_txn_line_detail_tbl(i).instance_id;
                  l_parent_instance_id := l_txn_line_detail_tbl(i).parent_instance_id;
                      /*  Added p_trx_rec for ER 2581101 */
                  l_nsrc_sub_type_id := p_txn_line_detail_tbl(i).sub_type_id;
                END IF;
                EXIT;
              END IF;
            END LOOP;
          END IF;
         END IF ; --x_xface_to_IB_flag
       ELSE
           l_subject_inst_id := x_txn_ii_rltns_tbl(j).subject_id ;
       END IF ;

         debug('  Parent Instance ID  :'||l_parent_instance_id );
         debug('  Object Instance ID  :'||l_object_inst_id );
         debug('  Subject Instance ID :'||l_subject_inst_id );
         debug('  Relationship Code   :'||x_txn_ii_rltns_tbl(j).relationship_type_code);
         debug('  II Relationship ID  :'||x_txn_ii_rltns_tbl(j).csi_inst_relationship_id );

       ---Added (Start) for m-to-m enhancements
       ---05/13

       debug('  Parent Instance Id : '||l_parent_instance_id);

       IF l_subject_inst_id IS NOT NULL
       AND l_object_inst_id IS NOT NULL
       THEN
       ---Added (End) for m-to-m enhancements
         IF x_txn_ii_rltns_tbl(j).relationship_type_code IN ('COMPONENT-OF',
            'CONNECTED-TO')
         THEN

           IF NVL(x_txn_ii_rltns_tbl(j).csi_inst_relationship_id,fnd_api.g_miss_num ) <>
              fnd_api.g_miss_num
              AND
              (NVL(x_txn_ii_rltns_tbl(j).active_end_date,l_date ) > sysdate)
           THEN

             /* Build the table for updating the instance relationship */

             l_obj_ver_num := csi_utl_pkg.get_ii_obj_ver_num(
                            x_txn_ii_rltns_tbl(j).csi_inst_relationship_id);

             IF l_obj_ver_num = -1  THEN
                 RAISE fnd_api.g_exc_error;
             END IF;

             x_upd_ii_rltns_tbl(l_upd_ii).relationship_id    := x_txn_ii_rltns_tbl(j).csi_inst_relationship_id;
             x_upd_ii_rltns_tbl(l_upd_ii).relationship_type_code := x_txn_ii_rltns_tbl(j).relationship_type_code;
             x_upd_ii_rltns_tbl(l_upd_ii).object_id := l_object_inst_id;
             x_upd_ii_rltns_tbl(l_upd_ii).subject_id := l_subject_inst_id;
             x_upd_ii_rltns_tbl(l_upd_ii).position_reference := x_txn_ii_rltns_tbl(j).position_reference;
             x_upd_ii_rltns_tbl(l_upd_ii).active_end_date := x_txn_ii_rltns_tbl(j).active_end_date;
             x_upd_ii_rltns_tbl(l_upd_ii).display_order := x_txn_ii_rltns_tbl(j).display_order;
             x_upd_ii_rltns_tbl(l_upd_ii).mandatory_flag := x_txn_ii_rltns_tbl(j).mandatory_flag;
             x_upd_ii_rltns_tbl(l_upd_ii).context := x_txn_ii_rltns_tbl(j).context;
             x_upd_ii_rltns_tbl(l_upd_ii).attribute1 := x_txn_ii_rltns_tbl(j).attribute1;
             x_upd_ii_rltns_tbl(l_upd_ii).attribute2 := x_txn_ii_rltns_tbl(j).attribute2;
             x_upd_ii_rltns_tbl(l_upd_ii).attribute3 := x_txn_ii_rltns_tbl(j).attribute3;
             x_upd_ii_rltns_tbl(l_upd_ii).attribute4 := x_txn_ii_rltns_tbl(j).attribute4;
             x_upd_ii_rltns_tbl(l_upd_ii).attribute5 := x_txn_ii_rltns_tbl(j).attribute5;
             x_upd_ii_rltns_tbl(l_upd_ii).attribute6 := x_txn_ii_rltns_tbl(j).attribute6;
             x_upd_ii_rltns_tbl(l_upd_ii).attribute7 := x_txn_ii_rltns_tbl(j).attribute7;
             x_upd_ii_rltns_tbl(l_upd_ii).attribute8 := x_txn_ii_rltns_tbl(j).attribute8;
             x_upd_ii_rltns_tbl(l_upd_ii).attribute9 := x_txn_ii_rltns_tbl(j).attribute9;
             x_upd_ii_rltns_tbl(l_upd_ii).attribute10 := x_txn_ii_rltns_tbl(j).attribute10;
             x_upd_ii_rltns_tbl(l_upd_ii).attribute11 := x_txn_ii_rltns_tbl(j).attribute11;
             x_upd_ii_rltns_tbl(l_upd_ii).attribute12 := x_txn_ii_rltns_tbl(j).attribute12;
             x_upd_ii_rltns_tbl(l_upd_ii).attribute13 := x_txn_ii_rltns_tbl(j).attribute13;
             x_upd_ii_rltns_tbl(l_upd_ii).attribute14 := x_txn_ii_rltns_tbl(j).attribute14;
             x_upd_ii_rltns_tbl(l_upd_ii).attribute15 := x_txn_ii_rltns_tbl(j).attribute15;

             -- Begin fix for Bug 2972082
             x_upd_ii_rltns_tbl(l_upd_ii).cascade_ownership_flag := l_cascade_owner_flag;
             -- End fix for Bug 2972082

             x_upd_ii_rltns_tbl(l_upd_ii).object_version_number := l_obj_ver_num;

             l_upd_ii := l_upd_ii + 1;
           ELSE
             /* Build the table for creating the new instance relationships */

             x_cre_ii_rltns_tbl(l_cre_ii).relationship_type_code := x_txn_ii_rltns_tbl(j).relationship_type_code;
             x_cre_ii_rltns_tbl(l_cre_ii).object_id  := l_object_inst_id ;
             x_cre_ii_rltns_tbl(l_cre_ii).subject_id := l_subject_inst_id;
             x_cre_ii_rltns_tbl(l_cre_ii).position_reference := x_txn_ii_rltns_tbl(j).position_reference;
             x_cre_ii_rltns_tbl(l_cre_ii).display_order := x_txn_ii_rltns_tbl(j).display_order ;
             x_cre_ii_rltns_tbl(l_cre_ii).mandatory_flag := x_txn_ii_rltns_tbl(j).mandatory_flag;
             x_cre_ii_rltns_tbl(l_cre_ii).active_start_date  := NVL(x_txn_ii_rltns_tbl(l_cre_ii).active_start_date, SYSDATE );
             x_cre_ii_rltns_tbl(l_cre_ii).active_end_date := NULL ;
             x_cre_ii_rltns_tbl(l_cre_ii).context     := x_txn_ii_rltns_tbl(j).context;
             x_cre_ii_rltns_tbl(l_cre_ii).attribute1  := x_txn_ii_rltns_tbl(j).attribute1;
             x_cre_ii_rltns_tbl(l_cre_ii).attribute2  := x_txn_ii_rltns_tbl(j).attribute2;
             x_cre_ii_rltns_tbl(l_cre_ii).attribute3  := x_txn_ii_rltns_tbl(j).attribute3;
             x_cre_ii_rltns_tbl(l_cre_ii).attribute4  := x_txn_ii_rltns_tbl(j).attribute4;
             x_cre_ii_rltns_tbl(l_cre_ii).attribute5  := x_txn_ii_rltns_tbl(j).attribute5;
             x_cre_ii_rltns_tbl(l_cre_ii).attribute6  := x_txn_ii_rltns_tbl(j).attribute6;
             x_cre_ii_rltns_tbl(l_cre_ii).attribute7  := x_txn_ii_rltns_tbl(j).attribute7;
             x_cre_ii_rltns_tbl(l_cre_ii).attribute8  := x_txn_ii_rltns_tbl(j).attribute8;
             x_cre_ii_rltns_tbl(l_cre_ii).attribute9  := x_txn_ii_rltns_tbl(j).attribute9;
             x_cre_ii_rltns_tbl(l_cre_ii).attribute10 := x_txn_ii_rltns_tbl(j).attribute10;
             x_cre_ii_rltns_tbl(l_cre_ii).attribute11 := x_txn_ii_rltns_tbl(j).attribute11;
             x_cre_ii_rltns_tbl(l_cre_ii).attribute12 := x_txn_ii_rltns_tbl(j).attribute12;
             x_cre_ii_rltns_tbl(l_cre_ii).attribute13 := x_txn_ii_rltns_tbl(j).attribute13;
             x_cre_ii_rltns_tbl(l_cre_ii).attribute14 := x_txn_ii_rltns_tbl(j).attribute14;
             x_cre_ii_rltns_tbl(l_cre_ii).attribute15 := x_txn_ii_rltns_tbl(j).attribute15;

             -- Begin fix for Bug 2972082
             x_cre_ii_rltns_tbl(l_cre_ii).cascade_ownership_flag := l_cascade_owner_flag;
             -- End fix for Bug 2972082

             x_cre_ii_rltns_tbl(l_cre_ii).object_version_number := fnd_api.g_miss_num;

             l_cre_ii := l_cre_ii + 1;
           END IF;

         ELSE

           /*  Added p_trx_rec for ER 2581101 */
           l_trx_rec.txn_sub_type_id := l_nsrc_sub_type_id;

          /*  Added p_trx_rec for ER 2581101 */

           amend_contracts(
             p_relationship_type_code => x_txn_ii_rltns_tbl(j).relationship_type_code,
             p_object_instance_id     => l_object_inst_id,
             p_subject_instance_id    => l_subject_inst_id,
             p_trx_rec                => l_trx_rec,
             x_return_status          => l_return_status);

           IF l_return_status <> fnd_api.g_ret_sts_success THEN
             raise fnd_api.g_exc_error;
           END IF;

           IF x_txn_ii_rltns_tbl(j).relationship_type_code = 'REPLACED-BY' THEN
              -- SUBJECT replaced by OBJECT
              -- OLD replaced by NEW
              --
              l_old_instance_id := l_subject_inst_id;
              l_new_instance_id := l_object_inst_id;
           ELSIF x_txn_ii_rltns_tbl(j).relationship_type_code = 'REPLACEMENT-FOR' THEN
              -- SUBJECT replacement for OBJECT
              -- NEW replacement for OLD
              --
              l_new_instance_id := l_subject_inst_id;
              l_old_instance_id := l_object_inst_id;
           ELSIF x_txn_ii_rltns_tbl(j).relationship_type_code = 'UPGRADED-FROM' THEN
              -- SUBJECT upgraded from OBJECT
              -- NEW upgraded from OLD
              --
              l_new_instance_id := l_subject_inst_id;
              l_old_instance_id := l_object_inst_id;
           ELSE
              debug(' Unable to re-assign subject/object instance id.');
           END IF;
           -----
           /* Replacement Enhancement for 11.5.10 */
           IF x_txn_ii_rltns_tbl(j).relationship_type_code IN ('REPLACED-BY', 'REPLACEMENT-FOR', 'UPGRADED-FROM')  THEN

              /* Check if item is in a configuration */
              FOR itm_cfg_rec in chk_item_config(l_old_instance_id) LOOP
                  l_config_instance := itm_cfg_rec.config_instance;
                  l_active_end_date := itm_cfg_rec.active_end_date;
                  EXIT;
              END LOOP;

              IF l_config_instance IS NULL THEN
                 l_config_instance := 'N';
              END IF;

              IF l_config_instance = 'Y' THEN
                 IF l_active_end_date is NOT NULL and l_parent_instance_id IS NULL THEN
                    l_config_instance := 'N';
                 END IF;
              END IF;

              debug('l_config_instance = '||l_config_instance);
              IF l_config_instance = 'Y' THEN
                 /* Check if item being replaced is in the same configuration */
                 BEGIN
                    SELECT 'x'
                    INTO   l_found
                    FROM   csi_ii_relationships
                    WHERE  subject_id = l_old_instance_id
                    AND    object_id  = l_parent_instance_id;
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       fnd_message.set_name('CSI','CSI_REPLACEMENT_TXN_INVALID');
                       fnd_message.set_token('INSTANCE_ID',l_subject_inst_id);
                       fnd_msg_pub.add;
                       debug('Item being replaced belongs to a different configuration.');
                       RAISE fnd_api.g_exc_error;
                    WHEN OTHERS THEN
                       fnd_message.set_name('CSI','CSI_REPLACEMENT_TXN_INVALID');
                       fnd_message.set_token('INSTANCE_ID',l_subject_inst_id);
                       fnd_msg_pub.add;
                       debug('Item being replaced belongs to a different configuration.');
                       RAISE fnd_api.g_exc_error;
                 END;

                 /* Check item location */
                 BEGIN
                    SELECT location_type_code
                    INTO   l_location_type_code
                    FROM   csi_item_instances
                    WHERE  instance_id = l_old_instance_id;
                 EXCEPTION
                    WHEN OTHERS THEN
                       fnd_message.set_name('CSI','CSI_REPLACEMENT_TXN_INVALID');
                       fnd_message.set_token('INSTANCE_ID',l_subject_inst_id);
                       fnd_msg_pub.add;
                       debug('Item being replaced belongs to a different configuration.');
                       RAISE fnd_api.g_exc_error;
                 END;
                 debug('Item location_type_code = '||l_location_type_code);

                 IF l_location_type_code NOT IN ('HZ_PARTY_SITES','HZ_LOCATIONS') THEN
                    /* Check item history */
                    l_item_status := null;

                    FOR instance_rec in check_instance_history(l_old_instance_id)
                    LOOP
                       debug('instance_rec.location_type_code = '||instance_rec.new_location_type_code);

                       /* Check if item is an RMA or a REPAIR */
                       IF instance_rec.new_location_type_code = 'INVENTORY' THEN
                          FOR inst_rec in check_item_status_validity(l_old_instance_id)
                          LOOP
                             l_item_status := inst_rec.item_status;
                             EXIT;
                          END LOOP;

                          debug('l_item_status = '||l_item_status);
                          IF l_item_status is null THEN
                             fnd_message.set_name('CSI','CSI_REPLACEMENT_TXN_INVALID');
                             fnd_message.set_token('INSTANCE_ID',l_subject_inst_id);
                             fnd_msg_pub.add;
                             debug('Item is in INVENTORY and relationship is Active');
                             RAISE fnd_api.g_exc_error;
                          ELSE
                             /* Check if it is a repair */
                             IF l_old_instance_id = l_new_instance_id THEN
                                l_item_status := 'REPAIR';
                             END IF;
                          END IF;
                          EXIT;
                       END IF;
                    END LOOP;

                    IF l_item_status IS NULL THEN
                       /* Check if it is a repair */
                       IF l_old_instance_id = l_new_instance_id THEN
                          l_item_status := 'REPAIR';
                       ELSE
                          l_item_status := 'NEW';
                       END IF;
                    END IF;
                 ELSE
                    /* Check if it is a repair */
                    IF l_old_instance_id = l_new_instance_id THEN
                       l_item_status := 'REPAIR';
                    ELSE
                       l_item_status := 'NEW';
                    END IF;
                 END IF;
                 l_transfer_components_flag :=  nvl(x_txn_ii_rltns_tbl(j).transfer_components_flag,'N');
                 debug('Transfer Component is '||l_transfer_components_flag);
                 debug('item status is '||l_item_status);

                 /* If tranfer component flag is 'Y' then do more checking*/
                 IF l_transfer_components_flag = 'Y' THEN
                    /* Check for csi_t_ii_relationships for BOM expl */
                    l_t_ii_count := 0;
                    FOR i in check_csi_t_ii_rel(l_new_instance_id)
                    LOOP
                       l_t_ii_count := l_t_ii_count + 1;
                    END LOOP;

                    IF l_t_ii_count > 0 THEN
                       l_transfer_components_flag := 'N';
                    END IF;
                 END IF;

                 debug('Trf Comp After BOM Check = '||l_transfer_components_flag);
                 IF l_transfer_components_flag = 'Y' THEN
                 debug('New Instance Id = '||to_char(l_new_instance_id));
                    /* Check for csi_ii_relationships(item being shipped) */
                    BEGIN
                       SELECT 'N'
                       INTO   l_transfer_components_flag
                       FROM   csi_ii_relationships
                       WHERE  object_id = l_new_instance_id
                       AND    relationship_type_code = 'COMPONENT-OF'
                       AND    active_end_date IS NULL;
                    EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                          null;
                       WHEN TOO_MANY_ROWS THEN
                          l_transfer_components_flag := 'N';
                    END;
                 END IF;
                 debug('Trf Comp After CSI_II Check = '||l_transfer_components_flag);

                 IF l_transfer_components_flag = 'Y' THEN
                    /* Check for get_ib_trackable_children */
                    get_ib_trackable_children(
                       p_order_line_rec     => p_order_line_rec,
                       x_trackable_line_tbl => l_line_tbl,
                       x_return_status      => l_return_status);

                       IF l_return_status <> fnd_api.g_ret_sts_success THEN
                          RAISE fnd_api.g_exc_error;
                       END IF;

                       debug('IB Trackable Children Count :'||l_line_tbl.COUNT);

                       IF l_line_tbl.COUNT > 0 THEN
                          l_transfer_components_flag := 'N';
                       END IF;
                 END IF;
                 /* End of transfer component flag checking */
                 debug('Trf Comp After IB track Check = '||l_transfer_components_flag);

                 IF l_item_status = 'NEW' THEN
                    debug('Item is NEW');
                    /* Check if it is valid for replacement */
                    OPEN check_instance_status(l_old_instance_id);
                    FETCH check_instance_status into l_valid_instance_no;

                    IF check_instance_status%notfound THEN
                       close check_instance_status;
                       fnd_message.set_name('CSI','CSI_REPLACEMENT_TXN_INVALID');
                       fnd_message.set_token('INSTANCE_ID',l_old_instance_id);
                       fnd_msg_pub.add;
                       debug('Check instance status - The item being replaced is no longer valid.');
                       RAISE fnd_api.g_exc_error;
                    ELSE
                       close check_instance_status;
                    END IF;

                    BEGIN
                       SELECT relationship_id, object_version_number,
                              object_id, relationship_type_code
                       INTO   l_relationship_id, l_ii_rel_obj_ver_num,
                              l_expire_object_id, l_relationship_type_code
                       FROM   csi_ii_relationships
                       WHERE  subject_id = l_old_instance_id
                       AND    relationship_type_code = 'COMPONENT-OF'
                       AND    (active_end_date is null OR active_end_date > sysdate);

                       x_upd_ii_rltns_tbl(l_upd_ii).relationship_id    :=  l_relationship_id;
                       x_upd_ii_rltns_tbl(l_upd_ii).subject_id := l_new_instance_id;
                       x_upd_ii_rltns_tbl(l_upd_ii).object_id := l_expire_object_id;
                       x_upd_ii_rltns_tbl(l_upd_ii).relationship_type_code := l_relationship_type_code;
                       x_upd_ii_rltns_tbl(l_upd_ii).object_version_number := l_ii_rel_obj_ver_num;
                       x_upd_ii_rltns_tbl(l_upd_ii).cascade_ownership_flag := l_cascade_owner_flag;

                       l_upd_ii := l_upd_ii + 1;
                    EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                          fnd_message.set_name('CSI','CSI_REPLACEMENT_TXN_INVALID');
                          fnd_message.set_token('INSTANCE_ID',l_old_instance_id);
                          fnd_msg_pub.add;
                          debug('No data found - Item being replaced is no longer valid.');
                          RAISE fnd_api.g_exc_error;
                       WHEN OTHERS THEN
                          fnd_message.set_name('CSI','CSI_REPLACEMENT_TXN_INVALID');
                          fnd_message.set_token('INSTANCE_ID',l_old_instance_id);
                          fnd_msg_pub.add;
                          debug('Others - Item being replaced is no longer valid');
                          RAISE fnd_api.g_exc_error;
                    END;

                    /* Transfer the child components */
                    IF nvl(l_transfer_components_flag,'N') = 'Y' THEN
                       FOR i in new_transfer_comp(l_old_instance_id)
                       LOOP
                          IF i.relationship_id IS NOT NULL THEN
                             x_upd_ii_rltns_tbl(l_upd_ii).relationship_id    := i.relationship_id;
                             x_upd_ii_rltns_tbl(l_upd_ii).object_id := i.object_id;
                             x_upd_ii_rltns_tbl(l_upd_ii).relationship_type_code := i.relationship_type_code;
                             x_upd_ii_rltns_tbl(l_upd_ii).subject_id := i.subject_id;
                             x_upd_ii_rltns_tbl(l_upd_ii).active_end_date := sysdate;
                             x_upd_ii_rltns_tbl(l_upd_ii).object_version_number := i.object_version_number;
                             x_upd_ii_rltns_tbl(l_upd_ii).cascade_ownership_flag := l_cascade_owner_flag;
                             l_upd_ii := l_upd_ii + 1;

                             x_cre_ii_rltns_tbl(l_cre_ii).relationship_type_code := 'COMPONENT-OF';
                             x_cre_ii_rltns_tbl(l_cre_ii).object_id  := l_new_instance_id;
                             x_cre_ii_rltns_tbl(l_cre_ii).subject_id := i.subject_id;
                             x_cre_ii_rltns_tbl(l_cre_ii).object_version_number := 1;
                             x_cre_ii_rltns_tbl(l_cre_ii).cascade_ownership_flag  := l_cascade_owner_flag;
                             l_cre_ii := l_cre_ii + 1;
                          END IF;
                       END LOOP;
                    END IF;
                 ELSE
                    debug('Item is in REPAIR/RMA');
                    /* Repair or RMA item */
                    BEGIN
                       SELECT relationship_id, object_version_number,
                              object_id, relationship_type_code
                       INTO   l_relationship_id, l_object_version_number,
                              l_object_id, l_relationship_type_code
                       FROM   csi_ii_relationships
                       WHERE  subject_id = l_old_instance_id
                       AND    object_id  = l_parent_instance_id
                       AND    relationship_type_code = 'COMPONENT-OF'
                       AND    (active_end_date IS NOT NULL OR active_end_date <= sysdate);

                       x_upd_ii_rltns_tbl(l_upd_ii).relationship_id    :=  l_relationship_id;
                       x_upd_ii_rltns_tbl(l_upd_ii).subject_id := l_new_instance_id;
                       x_upd_ii_rltns_tbl(l_upd_ii).object_id := l_object_id;
                       x_upd_ii_rltns_tbl(l_upd_ii).active_end_date := null;
                       x_upd_ii_rltns_tbl(l_upd_ii).relationship_type_code := l_relationship_type_code;
                       x_upd_ii_rltns_tbl(l_upd_ii).object_version_number := l_object_version_number;
                       x_upd_ii_rltns_tbl(l_upd_ii).cascade_ownership_flag := l_cascade_owner_flag;
                       l_upd_ii := l_upd_ii + 1;

                       IF nvl(l_transfer_components_flag,'N') = 'Y' THEN
                          FOR i in rmarp_transfer_comp(l_old_instance_id)
                          LOOP
                             IF i.relationship_id IS NOT NULL THEN
                                x_upd_ii_rltns_tbl(l_upd_ii).relationship_id    := i.relationship_id;
                                x_upd_ii_rltns_tbl(l_upd_ii).object_id := i.object_id;
                                x_upd_ii_rltns_tbl(l_upd_ii).relationship_type_code := i.relationship_type_code;
                                x_upd_ii_rltns_tbl(l_upd_ii).subject_id := i.subject_id;
                                x_upd_ii_rltns_tbl(l_upd_ii).active_end_date := sysdate;
                                x_upd_ii_rltns_tbl(l_upd_ii).object_version_number := i.object_version_number;
                                x_upd_ii_rltns_tbl(l_upd_ii).cascade_ownership_flag := l_cascade_owner_flag;
                                l_upd_ii := l_upd_ii + 1;

                                x_upd_ii_rltns_tbl(l_upd_ii).relationship_type_code := 'COMPONENT-OF';
                                x_upd_ii_rltns_tbl(l_upd_ii).object_id  := l_new_instance_id;
                                x_upd_ii_rltns_tbl(l_upd_ii).subject_id := i.subject_id;
                                x_upd_ii_rltns_tbl(l_upd_ii).object_version_number := 1;
                                x_upd_ii_rltns_tbl(l_upd_ii).cascade_ownership_flag := l_cascade_owner_flag;
                                l_upd_ii := l_upd_ii + 1;

                                -- x_cre_ii_rltns_tbl(l_cre_ii).relationship_type_code := 'COMPONENT-OF';
                                -- x_cre_ii_rltns_tbl(l_cre_ii).object_id  := l_new_instance_id;
                                -- x_cre_ii_rltns_tbl(l_cre_ii).subject_id := i.subject_id;
                                -- x_cre_ii_rltns_tbl(l_cre_ii).object_version_number := 1;
                                -- l_cre_ii := l_cre_ii + 1;
                             END IF;
                          END LOOP;
                       END IF;
                    EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                          fnd_message.set_name('CSI','CSI_REPLACEMENT_TXN_INVALID');
                          fnd_message.set_token('INSTANCE_ID',l_old_instance_id);
                          fnd_msg_pub.add;
                          debug('No data found - Item being replaced is no longer valid.');
                          RAISE fnd_api.g_exc_error;
                       WHEN OTHERS THEN
                          fnd_message.set_name('CSI','CSI_REPLACEMENT_TXN_INVALID');
                          fnd_message.set_token('INSTANCE_ID',l_old_instance_id);
                          fnd_msg_pub.add;
                          debug('Others - Item being replaced is no longer valid');
                          RAISE fnd_api.g_exc_error;
                    END;
                 END IF;
              END IF;
              debug('End of transfer components check');
           END IF; --  End of replacement enhancement
         END IF; -- component-of
       END IF ;----l_subject_id , object_id is NOT NULL
     END IF; -- component of, replaced by, replacement for, upgraded from relation
    END LOOP; -- end of inst relationship table loop
   END IF;-- end of inst relationship table count > 0

  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
          x_return_status := fnd_api.g_ret_sts_error ;
     WHEN fnd_api.g_exc_unexpected_error THEN
          x_return_status := fnd_api.g_ret_sts_unexp_error ;
  END get_ii_relation_tbl;


  PROCEDURE rebuild_tbls(
    p_new_instance_id         IN NUMBER,
    x_upd_party_tbl           IN OUT NOCOPY csi_datastructures_pub.party_tbl,
    x_upd_party_acct_tbl      IN OUT NOCOPY csi_datastructures_pub.party_account_tbl,
    x_upd_org_units_tbl       IN OUT NOCOPY csi_datastructures_pub.organization_units_tbl,
    x_upd_ext_attrib_val_tbl  IN OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl,
    x_cre_org_units_tbl       IN OUT NOCOPY csi_datastructures_pub.organization_units_tbl,
    x_cre_ext_attrib_val_tbl  IN OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl,
    x_txn_ii_rltns_tbl        IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_txn_line_detail_rec     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    x_return_status           OUT NOCOPY VARCHAR2)
  IS

    l_instance_party_id    NUMBER;
    l_instance_id          NUMBER;
    l_inst_pty_obj_ver_num NUMBER;
    l_ip_account_id        NUMBER;
    l_pty_acct_obj_ver_num NUMBER;
    l_instance_ou_id       NUMBER;
	l_instance_ou_id_check NUMBER; -- added for 8309196
    l_ou_obj_ver_num       NUMBER;
    l_attrib_value_id      NUMBER;
    l_av_obj_ver_num       NUMBER;
    l_inst_pty_id          NUMBER;

	l_update_ou_found  boolean; 	-- added for 8309196
    l_ou_found         boolean;
    l_cou_ind          binary_integer := 0;
    l_uou_ind          binary_integer := 0;
    l_upd_ou_tbl       csi_datastructures_pub.organization_units_tbl;
    l_cre_ou_tbl       csi_datastructures_pub.organization_units_tbl;

    l_return_status    varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    api_log('rebuild_tbls');

    x_return_status := fnd_api.g_ret_sts_success;

    l_instance_id := p_new_instance_id;

    IF x_upd_party_tbl.count > 0 THEN
      FOR i in x_upd_party_tbl.first..x_upd_party_tbl.last
      LOOP

        IF x_upd_party_tbl(i).relationship_type_code = 'OWNER'
        THEN

          BEGIN
            SELECT instance_id,
                   instance_party_id,
                   object_version_number
            INTO   x_upd_party_tbl(i).instance_id,
                   x_upd_party_tbl(i).instance_party_id,
                   x_upd_party_tbl(i).object_version_number
            FROM   csi_i_parties
            WHERE  instance_id = l_instance_id
            AND    relationship_type_code = 'OWNER'
            AND   (sysdate > nvl(active_start_date, sysdate -1)
                   OR
                   sysdate < nvl(active_end_date, sysdate +1) );
          EXCEPTION
            WHEN no_data_found THEN
              fnd_message.set_name('CSI','CSI_INT_INST_OWNER_MISSING');
              fnd_message.set_token('INSTANCE_ID',l_instance_id);
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
          END;

          IF x_upd_party_acct_tbl.count > 0 THEN
            FOR j IN x_upd_party_acct_tbl.first..x_upd_party_acct_tbl.last
            LOOP
              -- Commented thecondition for 11.5.9 porting bug 3625218
              -- IF x_upd_party_acct_tbl(j).relationship_type_code = 'OWNER' THEN
                x_upd_party_acct_tbl(j).instance_party_id := x_upd_party_tbl(i).instance_party_id;
              -- END IF;
            END LOOP;
          END IF;

        END IF;

      END LOOP;
    END IF;

    -- Rebuilding the Organization assignments
    IF x_upd_org_units_tbl.count > 0 THEN
      FOR l_upd_org in x_upd_org_units_tbl.first..x_upd_org_units_tbl.last
      LOOP

		-- Code Addition for the bug  8309196
		l_update_ou_found := FALSE;

        BEGIN
          SELECT instance_ou_id
          INTO   l_instance_ou_id_check
          FROM   csi_i_org_assignments
          WHERE  instance_id            = l_instance_id
          AND    relationship_type_code = x_upd_org_units_tbl(l_upd_org).relationship_type_code
		  AND   ((active_end_date is null ) OR (active_end_date > sysdate));                     -- Added for the bug 7333901

          l_update_ou_found := TRUE;

        EXCEPTION
          WHEN no_data_found THEN
            null;
          WHEN too_many_rows THEN
            null;
        END;

		IF l_update_ou_found THEN
			l_uou_ind := l_upd_ou_tbl.count + 1;
		-- If the instance_ou_id is found, update the org assignment
		-- End of Code Addition for the bug 8309196

			l_upd_ou_tbl(l_uou_ind) := x_upd_org_units_tbl(l_upd_org); -- Modified for the bug  8309196

			csi_utl_pkg.get_org_assign(
			  p_instance_id        => l_instance_id ,
			  p_operating_unit_id  => x_upd_org_units_tbl(l_upd_org).operating_unit_id,
			  p_rel_type_code      => x_upd_org_units_tbl(l_upd_org).relationship_type_code,
			  x_instance_ou_id     => l_instance_ou_id,
			  x_obj_version_number => l_ou_obj_ver_num,
			  x_return_status      => x_return_status);

			IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
			  RAISE fnd_api.g_exc_error;
			END IF;

			l_upd_ou_tbl(l_uou_ind).instance_ou_id        := l_instance_ou_id; -- Modified for the bug  8309196
			l_upd_ou_tbl(l_uou_ind).instance_id           := l_instance_id; -- Modified for the bug  8309196
			l_upd_ou_tbl(l_uou_ind).object_version_number := l_ou_obj_ver_num; -- Modified for the bug  8309196

		-- Code Addition for the bug  8309196
        ELSE
			-- If the instance_ou_id is not found, assign the update record to create
			x_upd_org_units_tbl(l_upd_org).instance_ou_id    := FND_API.G_MISS_NUM;
			x_cre_org_units_tbl(x_cre_org_units_tbl.count + 1) := x_upd_org_units_tbl(l_upd_org);
        END IF;
		-- End of Code Addition for the bug 8309196

      END LOOP;
    END IF; -- l_upd_org_units_tbl.count > 0

    -- Rebuilding the extended attributes
    IF x_upd_ext_attrib_val_tbl.count > 0 THEN
      FOR l_upd_ext in x_upd_ext_attrib_val_tbl.first..x_upd_ext_attrib_val_tbl.last
      LOOP

        csi_utl_pkg.get_ext_attribs(
          p_instance_id        => l_instance_id ,
          p_attribute_id       => x_upd_ext_attrib_val_tbl(l_upd_ext).attribute_id,
          x_attribute_value_id => l_attrib_value_id,
          x_obj_version_number => l_av_obj_ver_num,
          x_return_status      => x_return_status);

        IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        x_upd_ext_attrib_val_tbl(l_upd_ext).attribute_value_id    := l_attrib_value_id;
        x_upd_ext_attrib_val_tbl(l_upd_ext).instance_id           := l_instance_id;
        x_upd_ext_attrib_val_tbl(l_upd_ext).object_version_number := l_av_obj_ver_num;

      END LOOP;
    END IF; --x_upd_ext_attrib_val_tbl.count > 0

    -- Rebuilding the Create org assignment table
    IF x_cre_org_units_tbl.count > 0 THEN
      FOR l_cre_org in x_cre_org_units_tbl.first..x_cre_org_units_tbl.last
      LOOP

        l_ou_found := FALSE;

        x_cre_org_units_tbl(l_cre_org).instance_id := l_instance_id;

        BEGIN
          SELECT instance_ou_id ,
                 object_version_number
          INTO   x_cre_org_units_tbl(l_cre_org).instance_ou_id,
                 x_cre_org_units_tbl(l_cre_org).object_version_number
          FROM   csi_i_org_assignments
          WHERE  instance_id            = l_instance_id
          AND    relationship_type_code = x_cre_org_units_tbl(l_cre_org).relationship_type_code;
         -- and    operating_unit_id      = x_cre_org_units_tbl(l_cre_org).operating_unit_id; for 4293740

          l_ou_found := TRUE;
        EXCEPTION
          WHEN no_data_found THEN
            null;
          WHEN too_many_rows THEN
            null;
        END;

        IF l_ou_found THEN
          l_uou_ind := l_upd_ou_tbl.count + 1;
          l_upd_ou_tbl(l_uou_ind) := x_cre_org_units_tbl(l_cre_org);
        ELSE
          l_cou_ind := l_cre_ou_tbl.count + 1;
          l_cre_ou_tbl(l_cou_ind) := x_cre_org_units_tbl(l_cre_org);
        END IF;

      END LOOP;
    END IF; --l_cre_org_units_tbl.count > 0

    -- Rebuilding the Create extend arribs table
    IF x_cre_ext_attrib_val_tbl.count > 0 THEN
      FOR l_cre_ext in x_cre_ext_attrib_val_tbl.first..x_cre_ext_attrib_val_tbl.last
      LOOP
        x_cre_ext_attrib_val_tbl(l_cre_ext).instance_id  := l_instance_id;
      END LOOP;
    END IF; --l_cre_ext_attrib_val_tbl.count > 0

    -- Rebuilding the txn ii relationship table
    IF x_txn_ii_rltns_tbl.count > 0 THEN
      FOR l_txn_ii in x_txn_ii_rltns_tbl.first..x_txn_ii_rltns_tbl.last
      LOOP
        IF  ( x_txn_ii_rltns_tbl(l_txn_ii).subject_type = 'T' AND
	      x_txn_ii_rltns_tbl(l_txn_ii).subject_id = x_txn_line_detail_rec.txn_line_detail_id)
	THEN
          x_txn_line_detail_rec.instance_id := l_instance_id;
        ELSIF  ( x_txn_ii_rltns_tbl(l_txn_ii).object_type = 'T' AND
	      x_txn_ii_rltns_tbl(l_txn_ii).object_id = x_txn_line_detail_rec.txn_line_detail_id)
	THEN
          x_txn_line_detail_rec.instance_id := l_instance_id;
        END IF;
      END LOOP;
    END IF;

    x_cre_org_units_tbl := l_cre_ou_tbl;
    x_upd_org_units_tbl := l_upd_ou_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
  END rebuild_tbls ;

PROCEDURE cascade_txn_dtls
   (p_source_trx_id    IN  NUMBER,
    p_source_trx_table IN  VARCHAR2,
    p_ratio            IN  NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2
    ) IS

  l_txn_line_query_rec        csi_t_datastructures_grp.txn_line_query_rec;
  l_txn_line_detail_query_rec csi_t_datastructures_grp.txn_line_detail_query_rec;

  l_line_dtl_rec      csi_t_datastructures_grp.txn_line_detail_rec;
  l_line_dtl_tbl      csi_t_datastructures_grp.txn_line_detail_tbl;
  l_pty_dtl_tbl       csi_t_datastructures_grp.txn_party_detail_tbl;
  l_pty_acct_tbl      csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
  l_ii_rltns_tbl      csi_t_datastructures_grp.txn_ii_rltns_tbl;
  l_org_assgn_tbl     csi_t_datastructures_grp.txn_org_assgn_tbl;
  l_ext_attrib_tbl    csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
  l_csi_ea_tbl        csi_t_datastructures_grp.csi_ext_attribs_tbl;
  l_csi_eav_tbl       csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
  l_txn_systems_tbl   csi_t_datastructures_grp.txn_systems_tbl;

  x_msg_count         number;
  x_msg_data          varchar2(2000);
  l_end               integer;
  l_mod_value         NUMBER;

CURSOR get_txn_dtls(p_src_trx_id    IN NUMBER,
                    p_src_trx_table IN VARCHAR2) IS
SELECT a.txn_line_detail_id,
       a.quantity,
       a.transaction_line_id,
       a.transaction_system_id,
       a.csi_system_id
FROM csi_t_txn_line_details a,
     csi_t_transaction_lines b
WHERE a.transaction_line_id   = b.transaction_line_id
 AND  b.source_transaction_id = p_src_trx_id
 AND  b.source_transaction_table = p_src_trx_table
 AND  a.source_transaction_flag  = 'Y'
 AND  a.quantity > p_ratio;

BEGIN

   api_log('cascade_txn_dtls');

     x_return_status := fnd_api.g_ret_sts_success;

    FOR C1 IN get_txn_dtls( p_source_trx_id,p_source_trx_table )LOOP

      l_txn_line_detail_query_rec.txn_line_detail_id := C1.txn_line_detail_id;

      csi_t_txn_details_grp.get_transaction_details(
            p_api_version                => 1.0,
            p_commit                     => fnd_api.g_false,
            p_init_msg_list              => fnd_api.g_true,
            p_validation_level           => fnd_api.g_valid_level_full,
            p_txn_line_query_rec         => l_txn_line_query_rec,
            p_txn_line_detail_query_rec  => l_txn_line_detail_query_rec,
            x_txn_line_detail_tbl        => l_line_dtl_tbl,
            p_get_parties_flag           => fnd_api.g_true,
            x_txn_party_detail_tbl       => l_pty_dtl_tbl,
            p_get_pty_accts_flag         => fnd_api.g_true,
            x_txn_pty_acct_detail_tbl    => l_pty_acct_tbl,
            p_get_ii_rltns_flag          => fnd_api.g_false,
            x_txn_ii_rltns_tbl           => l_ii_rltns_tbl,
            p_get_org_assgns_flag        => fnd_api.g_true,
            x_txn_org_assgn_tbl          => l_org_assgn_tbl,
            p_get_ext_attrib_vals_flag   => fnd_api.g_true,
            x_txn_ext_attrib_vals_tbl    => l_ext_attrib_tbl,
            p_get_csi_attribs_flag       => fnd_api.g_false,
            x_csi_ext_attribs_tbl        => l_csi_ea_tbl,
            p_get_csi_iea_values_flag    => fnd_api.g_false,
            x_csi_iea_values_tbl         => l_csi_eav_tbl,
            p_get_txn_systems_flag       => fnd_api.g_false,
            x_txn_systems_tbl            => l_txn_systems_tbl,
            x_return_status              => x_return_status,
            x_msg_count                  => x_msg_count,
            x_msg_data                   => x_msg_data);

          IF x_return_status <> fnd_api.g_ret_sts_success THEN
            debug('Get_transaction_details  failed ');
            RAISE fnd_api.g_exc_error;
          END IF;

      debug('After getting txn details ');
      debug('l_line_dtl_tbl.count   = '||l_line_dtl_tbl.count);
      debug('l_pty_dtl_tbl.count    = '||l_pty_dtl_tbl.count);
      debug('l_pty_acct_tbl.count   = '||l_pty_acct_tbl.count);
      debug('l_ii_rltns_tbl.count   = '||l_ii_rltns_tbl.count);
      debug('l_org_assgn_tbl.count  = '||l_org_assgn_tbl.count);
      debug('l_ext_attrib_tbl.count = '||l_ext_attrib_tbl.count);

      l_end := l_line_dtl_tbl(1).quantity/p_ratio ;

      debug('l_end  ='||l_end );

      SELECT mod(l_line_dtl_tbl(1).quantity,p_ratio)
      INTO l_mod_value
      FROM dual;

      debug('l_line_dtl_tbl(1).quantity ='||l_line_dtl_tbl(1).quantity);

      debug('l_mod_value ='||l_mod_value);
      debug('p_ratio     ='||p_ratio);

          update csi_t_txn_line_details
          set quantity = p_ratio
          WHERE txn_line_detail_id = C1.txn_line_detail_id;

          debug('Converting the ids to index ');

            csi_t_utilities_pvt.convert_ids_to_index(
              px_line_dtl_tbl            => l_line_dtl_tbl,
              px_pty_dtl_tbl             => l_pty_dtl_tbl,
              px_pty_acct_tbl            => l_pty_acct_tbl,
              px_ii_rltns_tbl            => l_ii_rltns_tbl,
              px_org_assgn_tbl           => l_org_assgn_tbl,
              px_ext_attrib_tbl          => l_ext_attrib_tbl,
              px_txn_systems_tbl         => l_txn_systems_tbl);

      debug('l_line_dtl_rec.quantity ='||l_line_dtl_rec.quantity);

            l_line_dtl_rec                     := l_line_dtl_tbl(1);
            l_line_dtl_rec.txn_line_detail_id  := FND_API.G_MISS_NUM;
            l_line_dtl_rec.transaction_system_id := C1.transaction_system_id;
            l_line_dtl_rec.csi_system_id       := C1.csi_system_id;
            l_line_dtl_rec.quantity            := p_ratio ;
            l_line_dtl_rec.transaction_line_id := C1.transaction_line_id ;

      debug('Splitting the txn_line_dtls ');


      FOR l_index in 1..l_end-1
      LOOP

          debug('  line_dtl_tbl.count   = '||l_line_dtl_tbl.count);
          debug('  pty_dtl_tbl.count    = '||l_pty_dtl_tbl.count);
          debug('  pty_acct_tbl.count   = '||l_pty_acct_tbl.count);
          debug('  ii_rltns_tbl.count   = '||l_ii_rltns_tbl.count);
          debug('  org_assgn_tbl.count  = '||l_org_assgn_tbl.count);
          debug('  ext_attrib_tbl.count = '||l_ext_attrib_tbl.count);

            csi_t_txn_line_dtls_pvt.create_txn_line_dtls(
              p_api_version              => 1.0,
              p_commit                   => fnd_api.g_false,
              p_init_msg_list            => fnd_api.g_true,
              p_validation_level         => fnd_api.g_valid_level_full,
              p_txn_line_dtl_index       => 1,
              p_txn_line_dtl_rec         => l_line_dtl_rec,
              px_txn_party_dtl_tbl       => l_pty_dtl_tbl,
              px_txn_pty_acct_detail_tbl => l_pty_acct_tbl,
              px_txn_ii_rltns_tbl        => l_ii_rltns_tbl,
              px_txn_org_assgn_tbl       => l_org_assgn_tbl,
              px_txn_ext_attrib_vals_tbl => l_ext_attrib_tbl,
              x_return_status            => x_return_status,
              x_msg_count                => x_msg_count,
              x_msg_data                 => x_msg_data);

            IF x_return_status <> fnd_api.g_ret_sts_success THEN
              debug('Error Splitting txn line detail ');
              RAISE fnd_api.g_exc_error;
            END IF;

          debug('Converting the ids to index ');

          l_line_dtl_tbl(1) := l_line_dtl_rec;

            csi_t_utilities_pvt.convert_ids_to_index(
              px_line_dtl_tbl            => l_line_dtl_tbl,
              px_pty_dtl_tbl             => l_pty_dtl_tbl,
              px_pty_acct_tbl            => l_pty_acct_tbl,
              px_ii_rltns_tbl            => l_ii_rltns_tbl,
              px_org_assgn_tbl           => l_org_assgn_tbl,
              px_ext_attrib_tbl          => l_ext_attrib_tbl,
              px_txn_systems_tbl         => l_txn_systems_tbl);

            l_line_dtl_rec                     := l_line_dtl_tbl(1);
            l_line_dtl_rec.txn_line_detail_id  := FND_API.G_MISS_NUM;
            l_line_dtl_rec.quantity            := p_ratio;
            l_line_dtl_rec.transaction_system_id := C1.transaction_system_id;
            l_line_dtl_rec.csi_system_id       := C1.csi_system_id;
            l_line_dtl_rec.transaction_line_id := C1.transaction_line_id ;

           debug('Txn line detail for splitted INTO qty of one Successfully');

      END LOOP;

    END LOOP;

EXCEPTION
     WHEN fnd_api.g_exc_error THEN
          x_return_status := fnd_api.g_ret_sts_error ;
     WHEN fnd_api.g_exc_unexpected_error THEN
          x_return_status := fnd_api.g_ret_sts_unexp_error ;

END cascade_txn_dtls;

  PROCEDURE derive_party_id(
    p_cust_acct_role_id IN  NUMBER,
    x_party_id          OUT NOCOPY NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2)
  IS
  BEGIN

    api_log('derive_party_id');

    x_return_status := fnd_api.g_ret_sts_success;

    SELECT ship_rel.subject_id
    INTO   x_party_id
    FROM   hz_relationships       ship_rel,
           hz_cust_account_roles  ship_roles
    WHERE  ship_roles.cust_account_role_id = p_cust_acct_role_id
    AND    ship_rel.party_id               = ship_roles.party_id
    AND   subject_table_name               = 'HZ_PARTIES'
    AND   object_table_name                = 'HZ_PARTIES'
    AND   directional_flag                 = 'F';

  EXCEPTION
    WHEN no_data_found THEN
      fnd_message.set_name('CSI','CSI_INT_CUST_ROLEID_MISSING');
      fnd_message.set_token('CUST_ACCOUNT_ROLE_ID',p_cust_acct_role_id);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error ;
  END derive_party_id;

  PROCEDURE get_party_owner(
    p_txn_line_detail_rec        IN  csi_t_datastructures_grp.txn_line_detail_rec,
    p_txn_party_detail_tbl       IN  csi_t_datastructures_grp.txn_party_detail_tbl,
    p_txn_pty_acct_dtl_tbl       IN  csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_trx_sub_type_rec           IN  csi_order_ship_pub.txn_sub_type_rec,
    p_order_line_rec             IN  csi_order_ship_pub.order_line_rec,
    x_upd_party_tbl              OUT NOCOPY csi_datastructures_pub.party_tbl ,
    x_upd_party_acct_tbl         OUT NOCOPY csi_datastructures_pub.party_account_tbl,
    x_cre_party_tbl              OUT NOCOPY csi_datastructures_pub.party_tbl ,
    x_cre_party_acct_tbl         OUT NOCOPY csi_datastructures_pub.party_account_tbl,
    x_return_status              OUT NOCOPY VARCHAR2)
  IS

    l_debug_level              NUMBER;
    l_date                     DATE := TO_DATE('01/01/4712', 'MM/DD/YYYY');
    l_upd_pty                  NUMBER := 1;
    l_cre_pty                  NUMBER := 1;
    l_upd_pty_acct             NUMBER := 1;
    l_cre_pty_acct             NUMBER := 1;
    l_obj_ver_num              NUMBER;
    l_owner_pty_id             NUMBER;
    l_party_id                 NUMBER;

  BEGIN

    api_log('get_party_owner');

    x_return_status := fnd_api.g_ret_sts_success;

    /* get the debug level FROM the profile */
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

   IF p_txn_party_detail_tbl.count > 0 THEN
      FOR j in p_txn_party_detail_tbl.FIRST..p_txn_party_detail_tbl.LAST LOOP

       IF (p_txn_line_detail_rec.txn_line_detail_id = p_txn_party_detail_tbl(j).txn_line_detail_id) AND
          (p_txn_party_detail_tbl(j).relationship_type_code = 'OWNER' )  AND
          ((NVL(p_txn_party_detail_tbl(j).active_end_date,l_date ) > sysdate) OR
          (p_txn_party_detail_tbl(j).active_end_date = FND_API.G_MISS_DATE ))
       THEN

         x_cre_party_tbl.delete;
         x_upd_party_tbl.delete;
         x_cre_party_acct_tbl.delete;
         x_upd_party_acct_tbl.delete;

         IF (NVL(p_txn_party_detail_tbl(j).instance_party_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) THEN

           x_cre_party_tbl(l_cre_pty).instance_party_id := FND_API.G_MISS_NUM;
           x_cre_party_tbl(l_cre_pty).instance_id := FND_API.G_MISS_NUM;
           x_cre_party_tbl(l_cre_pty).party_id    := p_txn_party_detail_tbl(j).party_source_id;
           x_cre_party_tbl(l_cre_pty).party_source_table := p_txn_party_detail_tbl(j).party_source_table;
           x_cre_party_tbl(l_cre_pty).relationship_type_code := p_txn_party_detail_tbl(j).relationship_type_code;
           x_cre_party_tbl(l_cre_pty).contact_flag    := p_txn_party_detail_tbl(j).contact_flag;
           x_cre_party_tbl(l_cre_pty).contact_ip_id   := p_txn_party_detail_tbl(j).contact_party_id;
           x_cre_party_tbl(l_cre_pty).active_end_date := p_txn_party_detail_tbl(j).active_end_date;
           x_cre_party_tbl(l_cre_pty).context     := p_txn_party_detail_tbl(j).context;
           x_cre_party_tbl(l_cre_pty).attribute1  := p_txn_party_detail_tbl(j).attribute1;
           x_cre_party_tbl(l_cre_pty).attribute2  := p_txn_party_detail_tbl(j).attribute2;
           x_cre_party_tbl(l_cre_pty).attribute3  := p_txn_party_detail_tbl(j).attribute3;
           x_cre_party_tbl(l_cre_pty).attribute4  := p_txn_party_detail_tbl(j).attribute4;
           x_cre_party_tbl(l_cre_pty).attribute5  := p_txn_party_detail_tbl(j).attribute5;
           x_cre_party_tbl(l_cre_pty).attribute6  := p_txn_party_detail_tbl(j).attribute6;
           x_cre_party_tbl(l_cre_pty).attribute7  := p_txn_party_detail_tbl(j).attribute7;
           x_cre_party_tbl(l_cre_pty).attribute8  := p_txn_party_detail_tbl(j).attribute8;
           x_cre_party_tbl(l_cre_pty).attribute9  := p_txn_party_detail_tbl(j).attribute9;
           x_cre_party_tbl(l_cre_pty).attribute10 := p_txn_party_detail_tbl(j).attribute10;
           x_cre_party_tbl(l_cre_pty).attribute11 := p_txn_party_detail_tbl(j).attribute11;
           x_cre_party_tbl(l_cre_pty).attribute12 := p_txn_party_detail_tbl(j).attribute12;
           x_cre_party_tbl(l_cre_pty).attribute13 := p_txn_party_detail_tbl(j).attribute13;
           x_cre_party_tbl(l_cre_pty).attribute14 := p_txn_party_detail_tbl(j).attribute14;
           x_cre_party_tbl(l_cre_pty).attribute15 := p_txn_party_detail_tbl(j).attribute15;
           x_cre_party_tbl(l_cre_pty).object_version_number :=  FND_API.G_MISS_NUM;

           l_cre_pty := l_cre_pty + 1;

         ELSE

           l_obj_ver_num := csi_utl_pkg.get_pty_obj_ver_num(
                              p_txn_party_detail_tbl(j).instance_party_id);

           IF l_obj_ver_num = -1 THEN
             RAISE fnd_api.g_exc_error;
           END IF;

           x_upd_party_tbl(l_upd_pty).instance_party_id := p_txn_party_detail_tbl(j).instance_party_id;
           x_upd_party_tbl(l_upd_pty).instance_id :=  p_txn_line_detail_rec.instance_id ;
           x_upd_party_tbl(l_upd_pty).party_id    :=  p_txn_party_detail_tbl(j).party_source_id;
           x_upd_party_tbl(l_upd_pty).party_source_table := p_txn_party_detail_tbl(j).party_source_table;
           x_upd_party_tbl(l_upd_pty).relationship_type_code := p_txn_party_detail_tbl(j).relationship_type_code;
           x_upd_party_tbl(l_upd_pty).contact_flag    := p_txn_party_detail_tbl(j).contact_flag;
           x_upd_party_tbl(l_upd_pty).contact_ip_id   := p_txn_party_detail_tbl(j).contact_party_id;
           x_upd_party_tbl(l_upd_pty).active_end_date := p_txn_party_detail_tbl(j).active_end_date;
           x_upd_party_tbl(l_upd_pty).context     := p_txn_party_detail_tbl(j).context;
           x_upd_party_tbl(l_upd_pty).attribute1  := p_txn_party_detail_tbl(j).attribute1;
           x_upd_party_tbl(l_upd_pty).attribute2  := p_txn_party_detail_tbl(j).attribute2;
           x_upd_party_tbl(l_upd_pty).attribute3  := p_txn_party_detail_tbl(j).attribute3;
           x_upd_party_tbl(l_upd_pty).attribute4  := p_txn_party_detail_tbl(j).attribute4;
           x_upd_party_tbl(l_upd_pty).attribute5  := p_txn_party_detail_tbl(j).attribute5;
           x_upd_party_tbl(l_upd_pty).attribute6  := p_txn_party_detail_tbl(j).attribute6;
           x_upd_party_tbl(l_upd_pty).attribute7  := p_txn_party_detail_tbl(j).attribute7;
           x_upd_party_tbl(l_upd_pty).attribute8  := p_txn_party_detail_tbl(j).attribute8;
           x_upd_party_tbl(l_upd_pty).attribute9  := p_txn_party_detail_tbl(j).attribute9;
           x_upd_party_tbl(l_upd_pty).attribute10 := p_txn_party_detail_tbl(j).attribute10;
           x_upd_party_tbl(l_upd_pty).attribute11 := p_txn_party_detail_tbl(j).attribute11;
           x_upd_party_tbl(l_upd_pty).attribute12 := p_txn_party_detail_tbl(j).attribute12;
           x_upd_party_tbl(l_upd_pty).attribute13 := p_txn_party_detail_tbl(j).attribute13;
           x_upd_party_tbl(l_upd_pty).attribute14 := p_txn_party_detail_tbl(j).attribute14;
           x_upd_party_tbl(l_upd_pty).attribute15 := p_txn_party_detail_tbl(j).attribute15;
           x_upd_party_tbl(l_upd_pty).object_version_number := l_obj_ver_num;

           l_upd_pty := l_upd_pty + 1;

         END IF; -- end if for instance_party_id is null

         IF p_txn_pty_acct_dtl_tbl.count > 0 THEN
           FOR k in p_txn_pty_acct_dtl_tbl.FIRST..p_txn_pty_acct_dtl_tbl.LAST LOOP

             IF (p_txn_pty_acct_dtl_tbl(k).txn_party_detail_id = p_txn_party_detail_tbl(j).txn_party_detail_id) AND
                -- Commenting this condition (Porting fix for Bug 3625218)
                -- (p_txn_pty_acct_dtl_tbl(k).relationship_type_code = 'OWNER') AND
                ((NVL(p_txn_pty_acct_dtl_tbl(k).active_end_date, l_date ) > sysdate ) OR
                (p_txn_pty_acct_dtl_tbl(k).active_end_date = FND_API.G_MISS_DATE))
             THEN
               IF NVL(p_txn_pty_acct_dtl_tbl(k).ip_account_id,FND_API.G_MISS_NUM)= FND_API.G_MISS_NUM THEN
                 x_cre_party_acct_tbl(l_cre_pty_acct).ip_account_id := FND_API.G_MISS_NUM;
                 x_cre_party_acct_tbl(l_cre_pty_acct).party_account_id := p_txn_pty_acct_dtl_tbl(k).account_id;
                 x_cre_party_acct_tbl(l_cre_pty_acct).relationship_type_code := p_txn_pty_acct_dtl_tbl(k).relationship_type_code;
                 x_cre_party_acct_tbl(l_cre_pty_acct).bill_to_address := p_txn_pty_acct_dtl_tbl(k).bill_to_address_id ;
                 x_cre_party_acct_tbl(l_cre_pty_acct).ship_to_address := p_txn_pty_acct_dtl_tbl(k).ship_to_address_id;
                 x_cre_party_acct_tbl(l_cre_pty_acct).instance_party_id := p_txn_party_detail_tbl(j).instance_party_id;
                 x_cre_party_acct_tbl(l_cre_pty_acct).active_start_date := FND_API.G_MISS_DATE ;
                 x_cre_party_acct_tbl(l_cre_pty_acct).active_end_date := p_txn_pty_acct_dtl_tbl(k).active_end_date;
                 x_cre_party_acct_tbl(l_cre_pty_acct).context    := p_txn_pty_acct_dtl_tbl(k).context        ;
                 x_cre_party_acct_tbl(l_cre_pty_acct).attribute1 := p_txn_pty_acct_dtl_tbl(k).attribute1     ;
                 x_cre_party_acct_tbl(l_cre_pty_acct).attribute2 := p_txn_pty_acct_dtl_tbl(k).attribute2     ;
                 x_cre_party_acct_tbl(l_cre_pty_acct).attribute3 := p_txn_pty_acct_dtl_tbl(k).attribute3     ;
                 x_cre_party_acct_tbl(l_cre_pty_acct).attribute4 := p_txn_pty_acct_dtl_tbl(k).attribute4     ;
                 x_cre_party_acct_tbl(l_cre_pty_acct).attribute5 := p_txn_pty_acct_dtl_tbl(k).attribute5     ;
                 x_cre_party_acct_tbl(l_cre_pty_acct).attribute6 := p_txn_pty_acct_dtl_tbl(k).attribute6     ;
                 x_cre_party_acct_tbl(l_cre_pty_acct).attribute7 := p_txn_pty_acct_dtl_tbl(k).attribute7     ;
                 x_cre_party_acct_tbl(l_cre_pty_acct).attribute8 := p_txn_pty_acct_dtl_tbl(k).attribute8     ;
                 x_cre_party_acct_tbl(l_cre_pty_acct).attribute9 := p_txn_pty_acct_dtl_tbl(k).attribute9     ;
                 x_cre_party_acct_tbl(l_cre_pty_acct).attribute10 := p_txn_pty_acct_dtl_tbl(k).attribute10    ;
                 x_cre_party_acct_tbl(l_cre_pty_acct).attribute11 := p_txn_pty_acct_dtl_tbl(k).attribute11    ;
                 x_cre_party_acct_tbl(l_cre_pty_acct).attribute12 := p_txn_pty_acct_dtl_tbl(k).attribute12    ;
                 x_cre_party_acct_tbl(l_cre_pty_acct).attribute13 := p_txn_pty_acct_dtl_tbl(k).attribute13    ;
                 x_cre_party_acct_tbl(l_cre_pty_acct).attribute14 := p_txn_pty_acct_dtl_tbl(k).attribute14    ;
                 x_cre_party_acct_tbl(l_cre_pty_acct).attribute15 := p_txn_pty_acct_dtl_tbl(k).attribute15    ;
                 x_cre_party_acct_tbl(l_cre_pty_acct).object_version_number := l_obj_ver_num;
                 x_cre_party_acct_tbl(l_cre_pty_acct).parent_tbl_index   := 1;
                 l_cre_pty_acct := l_cre_pty_acct + 1;
               ELSE
                 x_upd_party_acct_tbl(l_upd_pty_acct).ip_account_id := FND_API.G_MISS_NUM;
                 x_upd_party_acct_tbl(l_upd_pty_acct).party_account_id := p_txn_pty_acct_dtl_tbl(k).account_id;
                 x_upd_party_acct_tbl(l_upd_pty_acct).relationship_type_code := p_txn_pty_acct_dtl_tbl(k).relationship_type_code;
                 x_upd_party_acct_tbl(l_upd_pty_acct).bill_to_address := p_txn_pty_acct_dtl_tbl(k).bill_to_address_id ;
                 x_upd_party_acct_tbl(l_upd_pty_acct).ship_to_address := p_txn_pty_acct_dtl_tbl(k).ship_to_address_id;
                 x_upd_party_acct_tbl(l_upd_pty_acct).instance_party_id := p_txn_party_detail_tbl(j).instance_party_id;
                 x_upd_party_acct_tbl(l_upd_pty_acct).active_start_date := FND_API.G_MISS_DATE ;
                 x_upd_party_acct_tbl(l_upd_pty_acct).active_end_date := p_txn_pty_acct_dtl_tbl(k).active_end_date;
                 x_upd_party_acct_tbl(l_upd_pty_acct).context := p_txn_pty_acct_dtl_tbl(k).context        ;
                 x_upd_party_acct_tbl(l_upd_pty_acct).attribute1 := p_txn_pty_acct_dtl_tbl(k).attribute1     ;
                 x_upd_party_acct_tbl(l_upd_pty_acct).attribute2 := p_txn_pty_acct_dtl_tbl(k).attribute2     ;
                 x_upd_party_acct_tbl(l_upd_pty_acct).attribute3 := p_txn_pty_acct_dtl_tbl(k).attribute3     ;
                 x_upd_party_acct_tbl(l_upd_pty_acct).attribute4 := p_txn_pty_acct_dtl_tbl(k).attribute4     ;
                 x_upd_party_acct_tbl(l_upd_pty_acct).attribute5 := p_txn_pty_acct_dtl_tbl(k).attribute5     ;
                 x_upd_party_acct_tbl(l_upd_pty_acct).attribute6 := p_txn_pty_acct_dtl_tbl(k).attribute6     ;
                 x_upd_party_acct_tbl(l_upd_pty_acct).attribute7 := p_txn_pty_acct_dtl_tbl(k).attribute7     ;
                 x_upd_party_acct_tbl(l_upd_pty_acct).attribute8 := p_txn_pty_acct_dtl_tbl(k).attribute8     ;
                 x_upd_party_acct_tbl(l_upd_pty_acct).attribute9 := p_txn_pty_acct_dtl_tbl(k).attribute9     ;
                 x_upd_party_acct_tbl(l_upd_pty_acct).attribute10 := p_txn_pty_acct_dtl_tbl(k).attribute10    ;
                 x_upd_party_acct_tbl(l_upd_pty_acct).attribute11 := p_txn_pty_acct_dtl_tbl(k).attribute11    ;
                 x_upd_party_acct_tbl(l_upd_pty_acct).attribute12 := p_txn_pty_acct_dtl_tbl(k).attribute12    ;
                 x_upd_party_acct_tbl(l_upd_pty_acct).attribute13 := p_txn_pty_acct_dtl_tbl(k).attribute13    ;
                 x_upd_party_acct_tbl(l_upd_pty_acct).attribute14 := p_txn_pty_acct_dtl_tbl(k).attribute14    ;
                 x_upd_party_acct_tbl(l_upd_pty_acct).attribute15 := p_txn_pty_acct_dtl_tbl(k).attribute15    ;
                 x_upd_party_acct_tbl(l_upd_pty_acct).object_version_number := l_obj_ver_num;
                 x_upd_party_acct_tbl(l_upd_pty_acct).parent_tbl_index   := 1;
                 l_upd_pty_acct := l_upd_pty_acct + 1;
               END IF;
             END IF;
           END LOOP;
         END IF;
       END IF;
     END LOOP;
   END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
  END get_party_owner;


  /* -------------------------------------------------------------------- */
  /* This routine converts the instance header table to instance table .  */
  /* We need to do this because the get_item_instances returns the header */
  /* table AND we operate on the instance table.                          */
  /* -------------------------------------------------------------------- */

  PROCEDURE make_non_header_tbl(
    p_instance_header_tbl IN  csi_datastructures_pub.instance_header_tbl,
    x_instance_tbl        OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_inst_tbl            csi_datastructures_pub.instance_tbl;
    l_inst_hdr_tbl        csi_datastructures_pub.instance_header_tbl;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('make_non_header_tbl');

    l_inst_hdr_tbl := p_instance_header_tbl;

    IF l_inst_hdr_tbl.COUNT > 0 THEN

      FOR l_ind IN l_inst_hdr_tbl.FIRST .. l_inst_hdr_tbl.LAST
      LOOP

       l_inst_tbl(l_ind).instance_id           := l_inst_hdr_tbl(l_ind).instance_id;
       l_inst_tbl(l_ind).instance_number       := l_inst_hdr_tbl(l_ind).instance_number;
       l_inst_tbl(l_ind).external_reference    := l_inst_hdr_tbl(l_ind).external_reference;
       l_inst_tbl(l_ind).inventory_item_id     := l_inst_hdr_tbl(l_ind).inventory_item_id;
       l_inst_tbl(l_ind).inventory_revision    := l_inst_hdr_tbl(l_ind).inventory_revision;
       l_inst_tbl(l_ind).inv_master_organization_id := l_inst_hdr_tbl(l_ind).inv_master_organization_id;
       l_inst_tbl(l_ind).serial_number         := l_inst_hdr_tbl(l_ind).serial_number;
       l_inst_tbl(l_ind).mfg_serial_number_flag:= l_inst_hdr_tbl(l_ind).mfg_serial_number_flag;
       l_inst_tbl(l_ind).lot_number            := l_inst_hdr_tbl(l_ind).lot_number;
       l_inst_tbl(l_ind).quantity              := l_inst_hdr_tbl(l_ind).quantity;
       l_inst_tbl(l_ind).unit_of_measure       := l_inst_hdr_tbl(l_ind).unit_of_measure;
       l_inst_tbl(l_ind).accounting_class_code := l_inst_hdr_tbl(l_ind).accounting_class_code;
       l_inst_tbl(l_ind).instance_condition_id := l_inst_hdr_tbl(l_ind).instance_condition_id;
       l_inst_tbl(l_ind).instance_status_id    := l_inst_hdr_tbl(l_ind).instance_status_id;
       l_inst_tbl(l_ind).customer_view_flag    := l_inst_hdr_tbl(l_ind).customer_view_flag;
       l_inst_tbl(l_ind).merchant_view_flag    := l_inst_hdr_tbl(l_ind).merchant_view_flag;
       l_inst_tbl(l_ind).sellable_flag         := l_inst_hdr_tbl(l_ind).sellable_flag;
       l_inst_tbl(l_ind).system_id             := l_inst_hdr_tbl(l_ind).system_id;
       l_inst_tbl(l_ind).instance_type_code    := l_inst_hdr_tbl(l_ind).instance_type_code;
       l_inst_tbl(l_ind).active_start_date     := l_inst_hdr_tbl(l_ind).active_start_date;
       l_inst_tbl(l_ind).active_end_date       := l_inst_hdr_tbl(l_ind).active_end_date;
       l_inst_tbl(l_ind).location_type_code    := l_inst_hdr_tbl(l_ind).location_type_code;
       l_inst_tbl(l_ind).location_id           := l_inst_hdr_tbl(l_ind).location_id;
       l_inst_tbl(l_ind).inv_organization_id   := l_inst_hdr_tbl(l_ind).inv_organization_id;
       l_inst_tbl(l_ind).inv_subinventory_name := l_inst_hdr_tbl(l_ind).inv_subinventory_name;
       l_inst_tbl(l_ind).inv_locator_id        := l_inst_hdr_tbl(l_ind).inv_locator_id;
       l_inst_tbl(l_ind).pa_project_id         := l_inst_hdr_tbl(l_ind).pa_project_id;
       l_inst_tbl(l_ind).pa_project_task_id    := l_inst_hdr_tbl(l_ind).pa_project_task_id;
       l_inst_tbl(l_ind).in_transit_order_line_id := l_inst_hdr_tbl(l_ind).in_transit_order_line_id;
       l_inst_tbl(l_ind).wip_job_id            := l_inst_hdr_tbl(l_ind).wip_job_id;
       l_inst_tbl(l_ind).po_order_line_id      := l_inst_hdr_tbl(l_ind).po_order_line_id;
       l_inst_tbl(l_ind).last_oe_order_line_id := l_inst_hdr_tbl(l_ind).last_oe_order_line_id;
       l_inst_tbl(l_ind).last_oe_rma_line_id   := l_inst_hdr_tbl(l_ind).last_oe_rma_line_id;
       l_inst_tbl(l_ind).last_po_po_line_id    := l_inst_hdr_tbl(l_ind).last_po_po_line_id;
       l_inst_tbl(l_ind).last_oe_po_number     := l_inst_hdr_tbl(l_ind).last_oe_po_number;
       l_inst_tbl(l_ind).last_wip_job_id       := l_inst_hdr_tbl(l_ind).last_wip_job_id;
       l_inst_tbl(l_ind).last_pa_project_id    := l_inst_hdr_tbl(l_ind).last_pa_project_id;
       l_inst_tbl(l_ind).last_pa_task_id       := l_inst_hdr_tbl(l_ind).last_pa_task_id;
       l_inst_tbl(l_ind).last_oe_agreement_id  := l_inst_hdr_tbl(l_ind).last_oe_agreement_id;
       l_inst_tbl(l_ind).install_date          := l_inst_hdr_tbl(l_ind).install_date;
       l_inst_tbl(l_ind).manually_created_flag := l_inst_hdr_tbl(l_ind).manually_created_flag;
       l_inst_tbl(l_ind).return_by_date        := l_inst_hdr_tbl(l_ind).return_by_date;
       l_inst_tbl(l_ind).actual_return_date    := l_inst_hdr_tbl(l_ind).actual_return_date;
       l_inst_tbl(l_ind).creation_complete_flag:= l_inst_hdr_tbl(l_ind).creation_complete_flag;
       l_inst_tbl(l_ind).completeness_flag     := l_inst_hdr_tbl(l_ind).completeness_flag;
       l_inst_tbl(l_ind).context               := l_inst_hdr_tbl(l_ind).context;
       l_inst_tbl(l_ind).attribute1            := l_inst_hdr_tbl(l_ind).attribute1;
       l_inst_tbl(l_ind).attribute2            := l_inst_hdr_tbl(l_ind).attribute2;
       l_inst_tbl(l_ind).attribute3            := l_inst_hdr_tbl(l_ind).attribute3;
       l_inst_tbl(l_ind).attribute4            := l_inst_hdr_tbl(l_ind).attribute4;
       l_inst_tbl(l_ind).attribute5            := l_inst_hdr_tbl(l_ind).attribute5;
       l_inst_tbl(l_ind).attribute6            := l_inst_hdr_tbl(l_ind).attribute6;
       l_inst_tbl(l_ind).attribute7            := l_inst_hdr_tbl(l_ind).attribute7;
       l_inst_tbl(l_ind).attribute8            := l_inst_hdr_tbl(l_ind).attribute8;
       l_inst_tbl(l_ind).attribute9            := l_inst_hdr_tbl(l_ind).attribute9;
       l_inst_tbl(l_ind).attribute10           := l_inst_hdr_tbl(l_ind).attribute10;
       l_inst_tbl(l_ind).attribute11           := l_inst_hdr_tbl(l_ind).attribute11;
       l_inst_tbl(l_ind).attribute12           := l_inst_hdr_tbl(l_ind).attribute12;
       l_inst_tbl(l_ind).attribute13           := l_inst_hdr_tbl(l_ind).attribute13;
       l_inst_tbl(l_ind).attribute14           := l_inst_hdr_tbl(l_ind).attribute14;
       l_inst_tbl(l_ind).attribute15           := l_inst_hdr_tbl(l_ind).attribute15;
       l_inst_tbl(l_ind).object_version_number := l_inst_hdr_tbl(l_ind).object_version_number;
       l_inst_tbl(l_ind).instance_usage_code   := l_inst_hdr_tbl(l_ind).instance_usage_code;
       l_inst_tbl(l_ind).vld_organization_id   := l_inst_hdr_tbl(l_ind).vld_organization_id;

      END LOOP;
    END IF;
    x_instance_tbl := l_inst_tbl;
  END make_non_header_tbl;

  /* Adding this reoutine to make the decision whether to call the contracts or not
     if the source instance is a replacement component.
  */
  PROCEDURE call_contracts_chk(
    p_txn_line_detail_id   in  number,
    p_txn_ii_rltns_tbl     in  csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_call_contracts       OUT NOCOPY varchar2,
    x_return_status        OUT NOCOPY varchar2)
  IS
  BEGIN

    x_return_status  := fnd_api.g_ret_sts_success;
    x_call_contracts := fnd_api.g_true;

    api_log('call_contracts_chk');

    IF p_txn_ii_rltns_tbl.count > 0 THEN
      FOR l_ind IN p_txn_ii_rltns_tbl.FIRST .. p_txn_ii_rltns_tbl.LAST
      LOOP
        IF ((p_txn_ii_rltns_tbl(l_ind).subject_type = 'T'
		AND p_txn_ii_rltns_tbl(l_ind).subject_id = p_txn_line_detail_id )
             OR
            (p_txn_ii_rltns_tbl(l_ind).object_type = 'T'
		AND p_txn_ii_rltns_tbl(l_ind).object_id = p_txn_line_detail_id ))
        THEN
          IF p_txn_ii_rltns_tbl(l_ind).relationship_type_code IN
            ('REPLACED-BY','REPLACEMENT-FOR', 'UPGRADED-FROM') THEN
            x_call_contracts := fnd_api.g_false;
          END IF;
        END IF;
      END LOOP;
    END IF;

    debug('  l_contracts_flag :'||x_call_contracts);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END call_contracts_chk;


  /* local debug dump routines */
  PROCEDURE dump_item_control_rec(
    p_item_control_rec IN csi_order_ship_pub.item_control_rec)
  IS
    l_rec              csi_order_ship_pub.item_control_rec;
  BEGIN

    l_rec := p_item_control_rec;

    debug('  inventory_item_id  : '||l_rec.inventory_item_id);
    debug('  organization_id    : '||l_rec.organization_id);
    debug('  primary_uom_code   : '||l_rec.primary_uom_code);
    debug('  serial_control_code: '||l_rec.serial_control_code);
    debug('  lot_control_code   : '||l_rec.lot_control_code);
    debug('  rev_control_code   : '||l_rec.revision_control_code);
    debug('  bom_item_type      : '||l_rec.bom_item_type);
    debug('  shippable_flag     : '||l_rec.shippable_flag);
    debug('  transactable_flag  : '||l_rec.transactable_flag);
    debug('  reservable_type    : '||l_rec.reservable_type);
    debug('  negative_bal_code  : '||l_rec.negative_balances_code);

  END dump_item_control_rec;

  PROCEDURE get_item_control_rec(
    p_mtl_txn_id        IN  number,
    x_item_control_rec  OUT NOCOPY csi_order_ship_pub.item_control_rec,
    x_return_status     OUT NOCOPY varchar2)
  IS

    l_item_control_rec  csi_order_ship_pub.item_control_rec;

  BEGIN

    api_log('get_item_control_rec');

    x_return_status := fnd_api.g_ret_sts_success;

    BEGIN

      SELECT inventory_item_id,
             organization_id
      INTO   l_item_control_rec.inventory_item_id,
             l_item_control_rec.organization_id
      FROM   mtl_material_transactions
      WHERE  transaction_id = p_mtl_txn_id;

    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('CSI','CSI_NO_INVENTORY_RECORDS');
        fnd_message.set_token('MTL_TRANSACTION_ID',p_mtl_txn_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;

    END;

    BEGIN

      SELECT serial_number_control_code,
             lot_control_code,
             revision_qty_control_code,
             location_control_code,
             bom_item_type,
             primary_uom_code,
             base_item_id,
             pick_components_flag,
             comms_nl_trackable_flag,
             reservable_type,
             shippable_item_flag,
             mtl_transactions_enabled_flag
      INTO   l_item_control_rec.serial_control_code,
             l_item_control_rec.lot_control_code,
             l_item_control_rec.revision_control_code,
             l_item_control_rec.locator_control_code,
             l_item_control_rec.bom_item_type,
             l_item_control_rec.primary_uom_code,
             l_item_control_rec.model_item_id,
             l_item_control_rec.pick_components_flag,
             l_item_control_rec.ib_trackable_flag,
             l_item_control_rec.reservable_type,
             l_item_control_rec.shippable_flag,
             l_item_control_rec.transactable_flag
      FROM   mtl_system_items
      WHERE  inventory_item_id = l_item_control_rec.inventory_item_id
      AND    organization_id   = l_item_control_rec.organization_id;

    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('CSI', 'CSI_INT_ITEM_ID_MISSING');
        fnd_message.set_token('INVENTORY_ITEM_ID', l_item_control_rec.inventory_item_id);
        fnd_message.set_token('INV_ORGANZATION_ID', l_item_control_rec.organization_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;

    BEGIN
      SELECT nvl(negative_inv_receipt_code,1)
      INTO   l_item_control_rec.negative_balances_code
      FROM   mtl_parameters
      WHERE  organization_id = l_item_control_rec.organization_id;
    END;

    dump_item_control_rec(
      p_item_control_rec => l_item_control_rec);

    x_item_control_rec := l_item_control_rec;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END get_item_control_rec;


---Added (Start) for m-to-m enhancements
-----------------------------------------------------------------------
--- 05/16 added procedure to check whether the TXN relations
---are already interfaced to IB
-----------------------------------------------------------------------

PROCEDURE rltns_xfaced_to_IB (p_xtn_ii_rltns_rec IN csi_t_datastructures_grp.txn_ii_rltns_rec,
                              x_xface_to_IB_flag OUT NOCOPY VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2)
IS
CURSOR get_instance_id (c_txn_line_detail_id IN NUMBER)
IS
SELECT instance_id
FROM   csi_t_txn_line_details
WHERE  txn_line_detail_id = c_txn_line_detail_id ;

l_subject_instance_id NUMBER ;
l_object_instance_id NUMBER ;
l_relationship_query_rec  csi_datastructures_pub.relationship_query_rec ;
l_ii_relationship_tbl csi_datastructures_pub.ii_relationship_tbl ;
x_msg_count NUMBER ;
x_msg_data  VARCHAR2 (2000);


BEGIN
   x_xface_to_IB_flag := 'N' ;
   --get the isntances associated with the subject and object TLD's
   OPEN get_instance_id (p_xtn_ii_rltns_rec.subject_id) ;
   FETCH get_instance_id INTO l_subject_instance_id ;
   CLOSE get_instance_id ;

   OPEN get_instance_id (p_xtn_ii_rltns_rec.object_id) ;
   FETCH get_instance_id INTO l_object_instance_id ;
   CLOSE get_instance_id ;

   IF l_subject_instance_id IS NOT NULL
   AND l_object_instance_id IS NOT NULL
   THEN

      ---For connected-to only subject or object needs to be passed.
      IF p_xtn_ii_rltns_rec.relationship_type_code = 'CONNECTED-TO'
      THEN
         l_relationship_query_rec.object_id := l_object_instance_id ;
         l_relationship_query_rec.relationship_type_code := p_xtn_ii_rltns_rec.relationship_type_code ;
      ELSE
         l_relationship_query_rec.object_id := l_object_instance_id ;
         l_relationship_query_rec.subject_id := l_subject_instance_id ;
         l_relationship_query_rec.relationship_type_code := p_xtn_ii_rltns_rec.relationship_type_code ;
      END IF ;

      debug('l_relationship_query_rec.object_id :'|| l_relationship_query_rec.object_id);
      debug('l_relationship_query_rec.subject_id :'|| l_relationship_query_rec.subject_id);
      debug('l_relationship_query_rec.relationship_type_code :'|| l_relationship_query_rec.relationship_type_code);

    csi_ii_relationships_pub.get_relationships (
     p_api_version             => 1.0 ,
     p_commit                    => fnd_api.g_false,
     p_init_msg_list             => fnd_api.g_false,
     p_validation_level          => fnd_api.g_valid_level_full,
     p_relationship_query_rec    => l_relationship_query_rec,
     p_depth                     => NULL,
     p_time_stamp                => NULL ,
     p_active_relationship_only  => fnd_api.g_true,
     x_relationship_tbl          => l_ii_relationship_tbl,
     x_return_status             => x_return_status,
     x_msg_count                 => x_msg_count ,
     x_msg_data                  => x_msg_data) ;

     IF NOT(x_return_status = fnd_api.g_ret_sts_success)
     THEN
        debug('csi_ii_relationships_pub.get_relationships call failed :'||
x_msg_data);
       RAISE fnd_api.g_exc_error;
     END IF;
     IF l_ii_relationship_tbl.count > 0
     THEN
        debug('Relations are already interfaced to IB');
        x_xface_to_IB_flag := 'Y' ;
     ELSE
      x_xface_to_IB_flag := 'N' ;
     END IF ;

   ELSE
      x_xface_to_IB_flag := 'N' ;
   END IF ;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
       debug ('Unexpected error in  rltns_xfaced_to_IB '||SQLERRM);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       debug ('Unexpected error in  rltns_xfaced_to_IB '||SQLERRM);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END rltns_xfaced_to_IB ;

---Added (End) for m-to-m enhancements

---Added (Start) for m-to-m enhancements
-----------------------------------------------------------------------
---05/20 procedure builds the relations after copying/splitting
---between TLD's based on the user entered TLD relations
-----------------------------------------------------------------------

PROCEDURE build_txn_relations (
    p_txn_line_detail_tbl IN csi_t_datastructures_grp.txn_line_detail_tbl ,
    x_txn_ii_rltns_tbl OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status OUT NOCOPY VARCHAR2)
IS
l_orig_oe_tld NUMBER ;
l_partner_oe_tld NUMBER ;
l_relations_exists BOOLEAN := FALSE ;
l_oe_txn_ii_rltns_tbl  csi_t_datastructures_grp.txn_ii_rltns_tbl;
l_partner_tld VARCHAR2(10) ;
l_ii_indx NUMBER ;
l_index NUMBER ;
l_src_txn_table VARCHAR2(100);
l_orig_oe_src_txn_id NUMBER ;
l_src_txn_id NUMBER ;
l_src_txn_line_dtl_id NUMBER ;


CURSOR source_txn_table_cur (c_txn_line_detail_id IN NUMBER)
IS
SELECT source_transaction_table, source_transaction_id
FROM csi_t_txn_line_details a ,
     csi_t_transaction_lines b
WHERE a.transaction_line_id = b.transaction_line_id
AND   a.txn_line_detail_id = c_txn_line_detail_id ;


CURSOR oe_tld_relns_cur (c_orig_oe_tld IN NUMBER)
IS
SELECT *
FROM csi_t_ii_relationships
WHERE (( subject_type = 'T' AND subject_id = c_orig_oe_tld)
       OR ( object_type = 'T' AND object_id = c_orig_oe_tld))
AND NVL(active_end_date ,SYSDATE) >= SYSDATE ;

CURSOR wsh_partner_tld_cur (c_partner_oe_tld IN NUMBER)
IS
---For Shippable and Non-shippable Items--
SELECT a.*
FROM csi_t_txn_line_details a ,
     csi_t_transaction_lines b ,
     mtl_system_items_b c
WHERE a.transaction_line_id = b.transaction_line_id
AND   ((b.source_transaction_table = 'WSH_DELIVERY_DETAILS' AND c.shippable_item_flag = 'Y')
OR     (b.source_transaction_table = 'OE_ORDER_LINES_ALL' AND c.shippable_item_flag = 'N'))
AND   a.instance_id IS NOT NULL ---meaning it is already processed. or it is Non Source
AND   a.source_txn_line_detail_id = c_partner_oe_tld
AND   a.inventory_item_id = c.inventory_item_id
AND   a.inv_organization_id = c.organization_id;

BEGIN
   debug ('Begin : build_txn_relations');

   IF p_txn_line_detail_tbl.COUNT > 0 THEN

   FOR i IN p_txn_line_detail_tbl.FIRST .. p_txn_line_detail_tbl.LAST
   LOOP

   OPEN source_txn_table_cur(p_txn_line_detail_tbl(i).txn_line_detail_id) ;
   FETCH source_txn_table_cur  INTO l_src_txn_table , l_src_txn_id ;
   CLOSE source_txn_table_cur ;

   debug ('process status '|| p_txn_line_detail_tbl(i).processing_status);

   IF l_src_txn_table IN('WSH_DELIVERY_DETAILS' ,
                         'OE_ORDER_LINES_ALL')
   AND p_txn_line_detail_tbl(i).processing_status NOT IN
         ('UNPROCESSED','ERROR','SUBMIT','PROCESSED')
   THEN
     ---In Case of Non-Shippable Items Txn Detail Line may NOT
     ---have source_txn_line_detail_id at all
-- This IF is introduced for bug 2814779 . The source TLD ID was g_miss_num for Models 'cause it wasn't getting properly earlier ..

     IF p_txn_line_detail_tbl(i).source_txn_line_detail_id = fnd_api.g_miss_num THEN
         l_src_txn_line_dtl_id := NULL;
     ELSIF p_txn_line_detail_tbl(i).source_txn_line_detail_id <> NULL THEN
         l_src_txn_line_dtl_id := p_txn_line_detail_tbl(i).source_txn_line_detail_id;
     END IF;

     l_orig_oe_tld := NVL(l_src_txn_line_dtl_id ,
                          p_txn_line_detail_tbl(i).txn_line_detail_id);
     debug ('TLD ID : '||p_txn_line_detail_tbl(i).txn_line_detail_id || ' User created TLD is '|| l_orig_oe_tld);
     l_index := 0 ;

     Begin
        Select source_transaction_id
        Into l_orig_oe_src_txn_id
        From csi_t_transaction_lines tl, csi_t_txn_line_details tld
        Where tld.transaction_line_id = tl.transaction_line_id
        And tld.txn_line_detail_id = l_orig_oe_tld;
     Exception when others Then
          fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
          fnd_message.set_token('MESSAGE', substr(sqlerrm, 1, 240));
          fnd_msg_pub.add;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          raise FND_API.G_EXC_UNEXPECTED_ERROR ;
     End;

     IF l_src_txn_id <> l_orig_oe_src_txn_id THEN  --added this for bug 2795136
      FOR oe_tld_relns_rec IN oe_tld_relns_cur (l_orig_oe_tld)
      LOOP
        l_index := l_index + 1 ;
        IF oe_tld_relns_rec.subject_id = l_orig_oe_tld
        THEN
           l_partner_oe_tld :=  oe_tld_relns_rec.object_id ;
           l_partner_tld := 'OBJECT';
        ELSE
           l_partner_oe_tld :=  oe_tld_relns_rec.subject_id ;
           l_partner_tld := 'SUBJECT';
        END IF ; ---oe_tld_relns_rec.subject_id = l_orig_oe_tld

        debug ('Partner OE TLD ID : ' || l_partner_oe_tld);

        l_oe_txn_ii_rltns_tbl(l_index).txn_relationship_id := oe_tld_relns_rec.txn_relationship_id  ;
       l_oe_txn_ii_rltns_tbl(l_index).transaction_line_id := oe_tld_relns_rec.transaction_line_id;
       l_oe_txn_ii_rltns_tbl(l_index).csi_inst_relationship_id := oe_tld_relns_rec.csi_inst_relationship_id;
       l_oe_txn_ii_rltns_tbl(l_index).subject_id := oe_tld_relns_rec.subject_id ;
       l_oe_txn_ii_rltns_tbl(l_index).subject_type := oe_tld_relns_rec.subject_type ;
       l_oe_txn_ii_rltns_tbl(l_index).object_id := oe_tld_relns_rec.object_id ;
       l_oe_txn_ii_rltns_tbl(l_index).object_type := oe_tld_relns_rec.object_type ;
       l_oe_txn_ii_rltns_tbl(l_index).relationship_type_code := oe_tld_relns_rec.relationship_type_code ;
       l_oe_txn_ii_rltns_tbl(l_index).display_order := oe_tld_relns_rec.display_order ;
       l_oe_txn_ii_rltns_tbl(l_index).position_reference := oe_tld_relns_rec.position_reference  ;
       l_oe_txn_ii_rltns_tbl(l_index).mandatory_flag := oe_tld_relns_rec.mandatory_flag ;
       l_oe_txn_ii_rltns_tbl(l_index).active_start_date := oe_tld_relns_rec.active_start_date  ;
       l_oe_txn_ii_rltns_tbl(l_index).active_end_date := oe_tld_relns_rec.active_end_date ;
       l_oe_txn_ii_rltns_tbl(l_index).context := oe_tld_relns_rec.context  ;
       l_oe_txn_ii_rltns_tbl(l_index).attribute1 := oe_tld_relns_rec.attribute1  ;
       l_oe_txn_ii_rltns_tbl(l_index).attribute2 := oe_tld_relns_rec.attribute2  ;
       l_oe_txn_ii_rltns_tbl(l_index).attribute3 := oe_tld_relns_rec.attribute3  ;
       l_oe_txn_ii_rltns_tbl(l_index).attribute4 := oe_tld_relns_rec.attribute4  ;
       l_oe_txn_ii_rltns_tbl(l_index).attribute5 := oe_tld_relns_rec.attribute5  ;
       l_oe_txn_ii_rltns_tbl(l_index).attribute6 := oe_tld_relns_rec.attribute6  ;
       l_oe_txn_ii_rltns_tbl(l_index).attribute7 := oe_tld_relns_rec.attribute7  ;
       l_oe_txn_ii_rltns_tbl(l_index).attribute8 := oe_tld_relns_rec.attribute8  ;
       l_oe_txn_ii_rltns_tbl(l_index).attribute9 := oe_tld_relns_rec.attribute9  ;
       l_oe_txn_ii_rltns_tbl(l_index).attribute10 := oe_tld_relns_rec.attribute10  ;
       l_oe_txn_ii_rltns_tbl(l_index).attribute11 := oe_tld_relns_rec.attribute11 ;
       l_oe_txn_ii_rltns_tbl(l_index).attribute12 := oe_tld_relns_rec.attribute12  ;
       l_oe_txn_ii_rltns_tbl(l_index).attribute13 := oe_tld_relns_rec.attribute13  ;
       l_oe_txn_ii_rltns_tbl(l_index).attribute14 := oe_tld_relns_rec.attribute14  ;
       l_oe_txn_ii_rltns_tbl(l_index).attribute15 := oe_tld_relns_rec.attribute15  ;
       l_oe_txn_ii_rltns_tbl(l_index).object_version_number  := oe_tld_relns_rec.object_version_number   ;
       l_oe_txn_ii_rltns_tbl(l_index).transfer_components_flag  := oe_tld_relns_rec.transfer_components_flag;

        FOR wsh_partner_tld_rec IN wsh_partner_tld_cur (l_partner_oe_tld)
        LOOP
          debug ('Inside wsh_partner_tld_cur');
         ---Copy from the relations from the original relations
         ---and then overwrite subject/object
         l_ii_indx := NVL(x_txn_ii_rltns_tbl.LAST,0)+ 1 ;
         x_txn_ii_rltns_tbl(l_ii_indx) := l_oe_txn_ii_rltns_tbl(1);

         IF l_partner_tld = 'SUBJECT'
         THEN
           x_txn_ii_rltns_tbl(l_ii_indx).subject_id := wsh_partner_tld_rec.txn_line_detail_id ;
           x_txn_ii_rltns_tbl(l_ii_indx).object_id := p_txn_line_detail_tbl(i).txn_line_detail_id ;
         ELSE
           x_txn_ii_rltns_tbl(l_ii_indx).object_id := wsh_partner_tld_rec.txn_line_detail_id ;
           x_txn_ii_rltns_tbl(l_ii_indx).subject_id := p_txn_line_detail_tbl(i).txn_line_detail_id ;
         END IF ; ---l_partner_tld = SUBJECT
           x_txn_ii_rltns_tbl(l_ii_indx).txn_relationship_id := fnd_api.g_miss_num ;
           x_txn_ii_rltns_tbl(l_ii_indx).object_version_number := 1;
        END LOOP ; --wsh_partner_tld_cur

          debug ('x_txn_ii_rltns_tbl.count :'|| x_txn_ii_rltns_tbl.count);
      END LOOP ; -- oe_tld_relns_cur
     END IF; -- src_txn_id check
   END IF ; --p_txn_line_detail_tbl(i).source_transaction_table
   END LOOP ; ---p_txn_line_detail_tbl.FIRST
   END IF;

   debug ('End : build_txn_relations');

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      debug (' Unexpected error in build_txn_relations '||SQLERRM);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    WHEN OTHERS
    THEN
      debug (' build_txn_relations failed '||SQLERRM);
      x_return_status := FND_API.G_RET_STS_ERROR ;
END build_txn_relations ;
---Added (End) for m-to-m enhancements


---Added (Start) for m-to-m enhancements
-------------------------------------------------------------------------------
-- For the given TLD , this procedure gets all the immediate relations
--associated with it. It also gets the details of the partner TLD's
-------------------------------------------------------------------------------


PROCEDURE get_partner_rltns (p_txn_line_detail_rec  IN csi_t_datastructures_grp.txn_line_detail_rec ,
    x_txn_ii_rltns_tbl OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_txn_line_detail_tbl OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status OUT NOCOPY VARCHAR2)
IS
CURSOR txn_ii_relns_cur (c_txn_line_detail_id IN NUMBER)
IS
SELECT *
FROM csi_t_ii_relationships
WHERE (( subject_type = 'T' AND subject_id = c_txn_line_detail_id )
       OR (object_type = 'T' AND object_id = c_txn_line_detail_id ))
AND NVL(active_end_date ,SYSDATE) >= SYSDATE ;

l_txn_line_detail_query_rec  csi_t_datastructures_grp.txn_line_detail_query_rec ;
l_txn_line_detail_tbl  csi_t_datastructures_grp.txn_line_detail_tbl ;
x_txn_party_detail_tbl csi_t_datastructures_grp.txn_party_detail_tbl ;
x_txn_pty_acct_detail_tbl  csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
x_txn_org_assgn_tbl    csi_t_datastructures_grp.txn_org_assgn_tbl ;
x_txn_ext_attrib_vals_tbl  csi_t_datastructures_grp.txn_ext_attrib_vals_tbl ;
x_csi_ext_attribs_tbl  csi_t_datastructures_grp.csi_ext_attribs_tbl;
x_csi_iea_values_tbl   csi_t_datastructures_grp.csi_ext_attrib_vals_tbl ;
x_txn_systems_tbl      csi_t_datastructures_grp.txn_systems_tbl ;
x_msg_count            NUMBER ;
x_msg_data             VARCHAR2(2000);
l_index                NUMBER := 0 ;
l_indx                 NUMBER := 0;
l_txn_line_query_rec        csi_t_datastructures_grp.txn_line_query_rec;
l_temp_txn_ii_rltns_tbl  csi_t_datastructures_grp.txn_ii_rltns_tbl ;

BEGIN
   debug('Begin get_partner_rltns'|| p_txn_line_detail_rec.txn_line_detail_id );
   FOR txn_ii_relns_rec IN txn_ii_relns_cur(p_txn_line_detail_rec.txn_line_detail_id)
   LOOP
      l_txn_line_detail_query_rec.txn_line_detail_id := fnd_api.g_miss_num ;
      debug('Subject id : '|| txn_ii_relns_rec.subject_id);
      debug('object id : '|| txn_ii_relns_rec.object_id);
      l_index := l_index+1 ;
      debug('l_index :'|| l_index);
      x_txn_ii_rltns_tbl(l_index).txn_relationship_id := txn_ii_relns_rec.txn_relationship_id  ;
      x_txn_ii_rltns_tbl(l_index).transaction_line_id := txn_ii_relns_rec.transaction_line_id;
      x_txn_ii_rltns_tbl(l_index).csi_inst_relationship_id := txn_ii_relns_rec.csi_inst_relationship_id;
      x_txn_ii_rltns_tbl(l_index).subject_id := txn_ii_relns_rec.subject_id ;
      x_txn_ii_rltns_tbl(l_index).subject_type := txn_ii_relns_rec.subject_type ;
      x_txn_ii_rltns_tbl(l_index).object_id := txn_ii_relns_rec.object_id ;
      x_txn_ii_rltns_tbl(l_index).object_type := txn_ii_relns_rec.object_type ;
      x_txn_ii_rltns_tbl(l_index).relationship_type_code := txn_ii_relns_rec.relationship_type_code ;
      x_txn_ii_rltns_tbl(l_index).display_order := txn_ii_relns_rec.display_order ;
      x_txn_ii_rltns_tbl(l_index).position_reference := txn_ii_relns_rec.position_reference  ;
      x_txn_ii_rltns_tbl(l_index).mandatory_flag := txn_ii_relns_rec.mandatory_flag ;
      x_txn_ii_rltns_tbl(l_index).active_start_date := txn_ii_relns_rec.active_start_date  ;
      x_txn_ii_rltns_tbl(l_index).active_end_date := txn_ii_relns_rec.active_end_date ;
      x_txn_ii_rltns_tbl(l_index).context := txn_ii_relns_rec.context  ;
      x_txn_ii_rltns_tbl(l_index).attribute1 := txn_ii_relns_rec.attribute1  ;
      x_txn_ii_rltns_tbl(l_index).attribute2 := txn_ii_relns_rec.attribute2  ;
      x_txn_ii_rltns_tbl(l_index).attribute3 := txn_ii_relns_rec.attribute3  ;
      x_txn_ii_rltns_tbl(l_index).attribute4 := txn_ii_relns_rec.attribute4  ;
      x_txn_ii_rltns_tbl(l_index).attribute5 := txn_ii_relns_rec.attribute5  ;
      x_txn_ii_rltns_tbl(l_index).attribute6 := txn_ii_relns_rec.attribute6  ;
      x_txn_ii_rltns_tbl(l_index).attribute7 := txn_ii_relns_rec.attribute7  ;
      x_txn_ii_rltns_tbl(l_index).attribute8 := txn_ii_relns_rec.attribute8  ;
      x_txn_ii_rltns_tbl(l_index).attribute9 := txn_ii_relns_rec.attribute9  ;
      x_txn_ii_rltns_tbl(l_index).attribute10 := txn_ii_relns_rec.attribute10  ;
      x_txn_ii_rltns_tbl(l_index).attribute11 := txn_ii_relns_rec.attribute11 ;
      x_txn_ii_rltns_tbl(l_index).attribute12 := txn_ii_relns_rec.attribute12  ;
      x_txn_ii_rltns_tbl(l_index).attribute13 := txn_ii_relns_rec.attribute13  ;
      x_txn_ii_rltns_tbl(l_index).attribute14 := txn_ii_relns_rec.attribute14  ;
      x_txn_ii_rltns_tbl(l_index).attribute15 := txn_ii_relns_rec.attribute15  ;
      x_txn_ii_rltns_tbl(l_index).object_version_number  := txn_ii_relns_rec.object_version_number   ;
      x_txn_ii_rltns_tbl(l_index).transfer_components_flag := nvl(txn_ii_relns_rec.transfer_components_flag,'N');

      IF txn_ii_relns_rec.object_id = p_txn_line_detail_rec.txn_line_detail_id
      AND txn_ii_relns_rec.object_type = 'T'
      AND txn_ii_relns_rec.subject_type = 'T'
      THEN
         debug('p_txn_line_detail_rec.txn_line_detail_id is the Object ID :'||
             p_txn_line_detail_rec.txn_line_detail_id);
         l_txn_line_detail_query_rec.txn_line_detail_id := txn_ii_relns_rec.subject_id ;
      ELSIF txn_ii_relns_rec.subject_id = p_txn_line_detail_rec.txn_line_detail_id
      AND txn_ii_relns_rec.object_type = 'T'
      AND txn_ii_relns_rec.subject_type = 'T'
      THEN
         debug('p_txn_line_detail_rec.txn_line_detail_id is the Subject ID :'||
             p_txn_line_detail_rec.txn_line_detail_id);
         l_txn_line_detail_query_rec.txn_line_detail_id := txn_ii_relns_rec.object_id ;
      END IF ;

      ---get the txn line details
    csi_t_txn_details_grp.get_transaction_details(
     p_api_version          => 1.0,
    p_commit               => fnd_api.g_false,
    p_init_msg_list        => fnd_api.g_false,
    p_validation_level     => fnd_api.g_valid_level_full,
    p_txn_line_query_rec   => l_txn_line_query_rec ,
    p_txn_line_detail_query_rec   => l_txn_line_detail_query_rec,
    x_txn_line_detail_tbl  => l_txn_line_detail_tbl ,
    p_get_parties_flag     => fnd_api.g_false,
    x_txn_party_detail_tbl => x_txn_party_detail_tbl ,
    p_get_pty_accts_flag   => fnd_api.g_false,
    x_txn_pty_acct_detail_tbl  => x_txn_pty_acct_detail_tbl,
    p_get_ii_rltns_flag    => fnd_api.g_false,
    x_txn_ii_rltns_tbl     => l_temp_txn_ii_rltns_tbl,
    p_get_org_assgns_flag  => fnd_api.g_false,
    x_txn_org_assgn_tbl    => x_txn_org_assgn_tbl,
    p_get_ext_attrib_vals_flag  => fnd_api.g_false,
    x_txn_ext_attrib_vals_tbl => x_txn_ext_attrib_vals_tbl,
    p_get_csi_attribs_flag => fnd_api.g_false,
    x_csi_ext_attribs_tbl  => x_csi_ext_attribs_tbl,
    p_get_csi_iea_values_flag => fnd_api.g_false,
    x_csi_iea_values_tbl  => x_csi_iea_values_tbl ,
    p_get_txn_systems_flag => fnd_api.g_false ,
    x_txn_systems_tbl      => x_txn_systems_tbl ,
    x_return_status        => x_return_status,
    x_msg_count            => x_msg_count,
    x_msg_data             => x_msg_data);

    IF x_return_status <> fnd_api.g_ret_sts_success
    THEN
        RAISE fnd_api.g_exc_error;
    END IF;

    IF l_txn_line_detail_tbl.COUNT > 0 THEN
    FOR i IN l_txn_line_detail_tbl.FIRST .. l_txn_line_detail_tbl.LAST
    LOOP
      l_indx := NVL(x_txn_line_detail_tbl.LAST,0)+1 ;
      x_txn_line_detail_tbl(l_indx) := l_txn_line_detail_tbl(i) ;
    END LOOP ;
    END IF;

   END LOOP ; --txn_ii_relns_cur
      debug('End get_partner_relations');
EXCEPTION
WHEN OTHERS
THEN
x_return_status :=  FND_API.G_RET_STS_ERROR ;
debug ('Error in get_partner_relations : '|| sqlerrm);
END get_partner_rltns ;
---Added (End) for m-to-m enhancements


  /* -------------------------------------------------------------------- */
  /* This routine takes in a table of instances and split them in to each */
  /* The output is a splitted instance table. This is done to match the   */
  /* transaction details quantities to the instances                      */
  /* -------------------------------------------------------------------- */

  PROCEDURE split_instances(
    px_instance_tbl  IN OUT NOCOPY csi_datastructures_pub.instance_tbl,
    px_csi_txn_rec   IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status     OUT NOCOPY varchar2)
  IS

    l_n_instance_tbl    csi_datastructures_pub.instance_tbl;
    l_instance_tbl      csi_datastructures_pub.instance_tbl;
    l_o_instance_tbl    csi_datastructures_pub.instance_tbl;
    l_o_ind             binary_integer;

    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data          varchar2(512);
    l_msg_count         number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('split_instances');

    l_instance_tbl := px_instance_tbl;
    l_o_ind := 0;

    IF l_instance_tbl.count > 0 THEN
      FOR l_ind in l_instance_tbl.FIRST..l_instance_tbl.LAST
      LOOP
      --Added IF ELSE condition loop for bug5956694--
      IF l_instance_tbl(1).quantity > 1 and l_instance_tbl(1).serial_number is null THEN
        csi_t_gen_utility_pvt.dump_api_info(
          p_api_name => 'split_item_instance_lines',
          p_pkg_name => 'csi_item_instance_pvt');

        csi_item_instance_pvt.split_item_instance_lines(
          p_api_version            => 1.0,
          p_commit                 => fnd_api.g_false,
          p_init_msg_list          => fnd_api.g_true,
          p_validation_level       => fnd_api.g_valid_level_full,
          p_source_instance_rec    => l_instance_tbl(1),
          p_copy_ext_attribs       => fnd_api.g_true,
          p_copy_org_assignments   => fnd_api.g_true,
          p_copy_parties           => fnd_api.g_true,
          p_copy_accounts          => fnd_api.g_true,
          p_copy_asset_assignments => fnd_api.g_true,
          p_copy_pricing_attribs   => fnd_api.g_true,
          p_txn_rec                => px_csi_txn_rec,
          x_new_instance_tbl       => l_n_instance_tbl,
          x_return_status          => l_return_status,
          x_msg_count              => l_msg_count,
          x_msg_data               => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          debug('Error splitting the item instances for distribution.');
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSE
        l_n_instance_tbl := l_instance_tbl;
      END IF;
      --End of fix for bug5956694--

        IF l_n_instance_tbl.COUNT > 0 THEN
          FOR l_ind IN l_n_instance_tbl.FIRST..l_n_instance_tbl.LAST
          LOOP
            l_o_ind := l_o_ind + 1;
            l_o_instance_tbl(l_o_ind) := l_n_instance_tbl(l_ind);
          END LOOP;
        END IF;

      END LOOP;
    END IF;

    px_instance_tbl := l_o_instance_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END split_instances;


  /* ------------------------------------------------------------------- */
  /* This routine distributes the CHILD instances to the PARENT instance */
  /* in the model to component ratio determined from the oe line order   */
  /* quantities. This is to build the realtion between the model and its */
  /* children in the appropriate ratio                                   */
  /* ------------------------------------------------------------------- */

  PROCEDURE distribute_instances(
    p_quantity_ratio       IN     number,
    p_model_txn_line_rec   IN     csi_t_datastructures_grp.txn_line_rec,
    px_instance_tbl        IN OUT NOCOPY csi_datastructures_pub.instance_tbl,
    px_txn_ps_tbl          IN OUT NOCOPY csi_utl_pkg.txn_ps_tbl,
    x_return_status           OUT NOCOPY varchar2)
  IS

    l_txn_type_id           number := csi_order_ship_pub.g_txn_type_id;

    l_instance_tbl          csi_datastructures_pub.instance_tbl;

    l_line_dtl_rec          csi_t_datastructures_grp.txn_line_detail_rec;
    l_pty_dtl_tbl           csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl          csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl          csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl         csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_ext_attrib_tbl        csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_txn_systems_tbl       csi_t_datastructures_grp.txn_systems_tbl;

    l_object_id             number;
    l_inst_ind              binary_integer;

    l_debug_level           NUMBER;
    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data              varchar2(512);
    l_msg_count             number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('distribute_instances');

    l_instance_tbl := px_instance_tbl;

    IF l_instance_tbl.COUNT > 0 THEN
      FOR l_ind in l_instance_tbl.FIRST..l_instance_tbl.LAST
      LOOP

        /* do a quick check to see if the shipping has not violated the
           quantity raito while splitting the instance */
        IF l_instance_tbl(l_ind).quantity  > p_quantity_ratio THEN
          fnd_message.set_name('CSI','CSI_INT_CHILD_RATIO_INVALID');
          fnd_message.set_token('CHILD_QTY',l_instance_tbl(l_ind).quantity);
          fnd_message.set_token('RATIO', p_quantity_ratio);
          fnd_msg_pub.add;
          debug ('The instance qty generated by the shipment interface '||
             l_instance_tbl(l_ind).quantity||' is greater than the MODEL/CHILD ratio '||
             p_quantity_ratio);

          RAISE fnd_api.g_exc_error;
        END IF;

        l_object_id := null;

        IF px_txn_ps_tbl.COUNT > 0 THEN
          FOR l_ps_ind IN px_txn_ps_tbl.FIRST ..px_txn_ps_tbl.LAST
          LOOP
            IF px_txn_ps_tbl(l_ps_ind).processed_flag = 'N' THEN
              IF l_instance_tbl(l_ind).quantity <= px_txn_ps_tbl(l_ps_ind).quantity_remaining
              THEN

                px_txn_ps_tbl(l_ps_ind).quantity_remaining :=
                  px_txn_ps_tbl(l_ps_ind).quantity_remaining - l_instance_tbl(l_ind).quantity;

                l_instance_tbl(l_ind).attribute15 := 'Y'; -- marking the redord as pricessed

                IF px_txn_ps_tbl(l_ps_ind).quantity_remaining = 0 THEN
                  px_txn_ps_tbl(l_ps_ind).processed_flag := 'Y';
                END IF;

                l_object_id := px_txn_ps_tbl(l_ps_ind).txn_line_detail_id;

                EXIT;

              END IF;
            END IF;
          END LOOP;
        END IF;

        IF l_object_id is not null THEN

          l_line_dtl_rec.txn_line_detail_id      := fnd_api.g_miss_num;
          l_line_dtl_rec.transaction_line_id     := p_model_txn_line_rec.transaction_line_id;
          l_line_dtl_rec.sub_type_id             := csi_order_ship_pub.g_dflt_sub_type_id;
          l_line_dtl_rec.processing_status       := 'IN_PROCESS';
          l_line_dtl_rec.source_transaction_flag := 'N';
          l_line_dtl_rec.inventory_item_id       := l_instance_tbl(l_ind).inventory_item_id;
          l_line_dtl_rec.inventory_revision      := l_instance_tbl(l_ind).inventory_revision;
	  /* fix for bug 4941832 */
          l_line_dtl_rec.inv_organization_id     := l_instance_tbl(l_ind).vld_organization_id;
          l_line_dtl_rec.quantity                := l_instance_tbl(l_ind).quantity;
          l_line_dtl_rec.unit_of_measure         := l_instance_tbl(l_ind).unit_of_measure;
          l_line_dtl_rec.installation_date       := sysdate;
          l_line_dtl_rec.external_reference      := 'INTERFACE';
          l_line_dtl_rec.location_type_code      := l_instance_tbl(l_ind).location_type_code;
          l_line_dtl_rec.location_id             := l_instance_tbl(l_ind).location_id;
          l_line_dtl_rec.active_start_date       := sysdate;
          l_line_dtl_rec.preserve_detail_flag    := 'Y';
          l_line_dtl_rec.instance_exists_flag    := 'Y';
          l_line_dtl_rec.instance_id             := l_instance_tbl(l_ind).instance_id;
          l_line_dtl_rec.serial_number           := l_instance_tbl(l_ind).serial_number;
          l_line_dtl_rec.mfg_serial_number_flag  := l_instance_tbl(l_ind).mfg_serial_number_flag;
          l_line_dtl_rec.lot_number              := l_instance_tbl(l_ind).lot_number;
          l_line_dtl_rec.object_version_number   := 1.0;

          csi_t_txn_line_dtls_pvt.create_txn_line_dtls(
            p_api_version              => 1.0,
            p_commit                   => fnd_api.g_false,
            p_init_msg_list            => fnd_api.g_true,
            p_validation_level         => fnd_api.g_valid_level_full,
            p_txn_line_dtl_index       => 1,
            p_txn_line_dtl_rec         => l_line_dtl_rec,
            px_txn_party_dtl_tbl       => l_pty_dtl_tbl,
            px_txn_pty_acct_detail_tbl => l_pty_acct_tbl,
            px_txn_ii_rltns_tbl        => l_ii_rltns_tbl,
            px_txn_org_assgn_tbl       => l_org_assgn_tbl,
            px_txn_ext_attrib_vals_tbl => l_ext_attrib_tbl,
            x_return_status            => l_return_status,
            x_msg_count                => l_msg_count,
            x_msg_data                 => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            raise fnd_api.g_exc_error;
          END IF;

          -- build ii_rltns table
          l_ii_rltns_tbl(1).txn_relationship_id    :=  fnd_api.g_miss_num;
          l_ii_rltns_tbl(1).transaction_line_id    :=  p_model_txn_line_rec.transaction_line_id;
          l_ii_rltns_tbl(1).subject_id             :=  l_line_dtl_rec.txn_line_detail_id;
          l_ii_rltns_tbl(1).object_id              :=  l_object_id;
          l_ii_rltns_tbl(1).relationship_type_code :=  'COMPONENT-OF';
          l_ii_rltns_tbl(1).active_start_date      :=  sysdate;

          csi_t_txn_rltnshps_grp.create_txn_ii_rltns_dtls(
            p_api_version       => 1.0,
            p_commit            => fnd_api.g_false,
            p_init_msg_list     => fnd_api.g_true,
            p_validation_level  => fnd_api.g_valid_level_full,
            px_txn_ii_rltns_tbl => l_ii_rltns_tbl,
            x_return_status     => l_return_status,
            x_msg_count         => l_msg_count,
            x_msg_data          => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            debug('Error creating txn ii relation for the ATO/PTO Child');
            raise fnd_api.g_exc_error;
          END IF;

        END IF;

      END LOOP;

      /* loop thru the table to split the instance as needed for distribution*/
      l_inst_ind := 0;
      px_instance_tbl.DELETE;
      FOR l_ind in l_instance_tbl.FIRST..l_instance_tbl.LAST
      LOOP

        IF l_instance_tbl(l_ind).attribute15 <> 'Y' THEN
          l_inst_ind := l_inst_ind + 1;
          px_instance_tbl(l_inst_ind) := l_instance_tbl(l_ind);
        END IF;

      END LOOP;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END distribute_instances;

  PROCEDURE query_immediate_children (
    p_header_id          IN  number,
    p_parent_line_id     IN  number,
    x_line_tbl           OUT NOCOPY oe_order_pub.line_tbl_type)
  IS

    l_line_rec  oe_order_pub.line_rec_type := oe_order_pub.g_miss_line_rec;

    CURSOR op_cur is
      SELECT line_id
      FROM   oe_order_lines_all
      WHERE  header_id       = p_header_id
      AND    link_to_line_id = p_parent_line_id
      ORDER BY line_number, shipment_number;

  BEGIN

    debug('Getting next level children for Line ID :'||p_parent_line_id);

    FOR op_rec IN op_cur
    LOOP

      IF op_rec.line_id <> p_parent_line_id THEN

        oe_line_util.query_row(
          p_line_id  => op_rec.line_id,
          x_line_rec => l_line_rec );

        x_line_tbl(x_line_tbl.COUNT + 1) := l_line_rec;

      END IF;

    END LOOP;

    debug('  Children count :'||x_line_tbl.COUNT);

  END query_immediate_children;


  /* --------------------------------------------------------------------- */
  /* This routine gets the next level trackable order line details for the */
  /* currently processed order line id(MODEL, CLASS, KIT)                  */
  /*                                                                       */
  /* Here is an example:                                                   */
  /*                           A (MODEL)                                   */
  /*                          / \                                          */
  /*            Non Trk (OC) B   C (OC) Trk                                */
  /*                        / \   \                                        */
  /*                       D   E   F                                       */
  /*  Both D and E are  trackable option items. In this example while      */
  /*  processing the Model (A) the relationship will be build between      */
  /*  A => C, A => D, A = E. Option class B will be ignored                */
  /* --------------------------------------------------------------------- */

  PROCEDURE get_config_children(
    p_header_id          IN  number,
    p_current_line_id    IN  number,
    p_om_vld_org_id      IN  number,
    x_trackable_line_tbl OUT NOCOPY oe_order_pub.line_tbl_type,
    x_return_status      OUT NOCOPY varchar2)
  IS

    l_line_tbl           oe_order_pub.line_tbl_type;
    l_line_tbl_nxt_lvl   oe_order_pub.line_tbl_type;
    l_line_tbl_temp      oe_order_pub.line_tbl_type;
    l_line_tbl_final     oe_order_pub.line_tbl_type;

    l_nxt_ind            binary_integer;
    l_final_ind          binary_integer;

    l_ib_trackable_flag  varchar2(1);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_config_children');

    l_final_ind := 0;

    query_immediate_children (
      p_header_id       => p_header_id,
      p_parent_line_id  => p_current_line_id,
      x_line_tbl        => l_line_tbl);

    <<Next_Level>>

    l_line_tbl_nxt_lvl.delete;
    l_nxt_ind := 0;

    IF l_line_tbl.count > 0 THEN

      FOR l_ind IN l_line_tbl.FIRST .. l_line_tbl.LAST
      LOOP

        IF l_line_tbl(l_ind).item_type_code <> 'CONFIG' THEN

          SELECT nvl(msi.comms_nl_trackable_flag,'N')
          INTO   l_ib_trackable_flag
          FROM   mtl_system_items msi
          WHERE  msi.inventory_item_id = l_line_tbl(l_ind).inventory_item_id
          AND    msi.organization_id   = p_om_vld_org_id;

          /* if trackable populate it for the final out table */
          IF l_ib_trackable_flag = 'Y' THEN

            l_final_ind := l_final_ind + 1;
            l_line_tbl_final(l_final_ind) := l_line_tbl(l_ind);

          ELSE --[NOT Trackable]

            /* get the next level using this line ID as the parent */

            query_immediate_children (
              p_header_id       => l_line_tbl(l_ind).header_id,
              p_parent_line_id  => l_line_tbl(l_ind).line_id,
              x_line_tbl        => l_line_tbl_temp);

            IF l_line_tbl_temp.count > 0 THEN
              FOR l_temp_ind IN l_line_tbl_temp.FIRST .. l_line_tbl_temp.LAST
              LOOP

                l_nxt_ind := l_nxt_ind + 1;
                l_line_tbl_nxt_lvl (l_nxt_ind) := l_line_tbl_temp(l_temp_ind);

              END LOOP;
            END IF;
          END IF;
        END IF; -- <> CONFIG
      END LOOP;

      IF l_line_tbl_nxt_lvl.COUNT > 0 THEN
        l_line_tbl.DELETE;
        l_line_tbl := l_line_tbl_nxt_lvl;
        goto Next_Level;
      END IF;

    END IF;

    x_trackable_line_tbl := l_line_tbl_final;

  END get_config_children;

  PROCEDURE get_ib_trackable_children(
    p_order_line_rec     IN csi_order_ship_pub.order_line_rec,
    x_trackable_line_tbl OUT NOCOPY oe_order_pub.line_tbl_type,
    x_return_status      OUT NOCOPY varchar2)
  IS
    l_line_tbl           oe_order_pub.line_tbl_type;
    l_return_status      varchar2(1) := fnd_api.g_ret_sts_success;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_ib_trackable_children');
    IF p_order_line_rec.item_type_code = 'CONFIG' THEN
      get_config_children(
        p_header_id          => p_order_line_rec.header_id,
        p_current_line_id    => p_order_line_rec.ato_line_id,
        p_om_vld_org_id      => p_order_line_rec.om_vld_org_id,
        x_trackable_line_tbl => l_line_tbl,
        x_return_status      => l_return_status);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSE
      csi_order_fulfill_pub.get_ib_trackable_children(
        p_current_line_id    => p_order_line_rec.order_line_id,
        p_om_vld_org_id      => p_order_line_rec.om_vld_org_id,
        x_trackable_line_tbl => l_line_tbl,
        x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
    x_trackable_line_tbl := l_line_tbl;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_ib_trackable_children;


  PROCEDURE filter_processed_instances(
    p_order_line_id      IN     number,
    px_instance_tbl      IN OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status         OUT NOCOPY varchar2)
  IS
    l_instance_tbl       csi_datastructures_pub.instance_tbl;
    l_i_ind              binary_integer := 0;
    l_processed          boolean        := FALSE;

    CURSOR tld_cur (p_ord_line_id IN number, p_instance_id IN number) IS
      SELECT 'X'
      FROM   csi_t_transaction_lines ctl,
             csi_t_txn_line_details  ctld
      WHERE  ctl.source_transaction_id    = p_ord_line_id
      AND    ctl.source_transaction_table = 'WSH_DELIVERY_DETAILS'
      AND    ctld.transaction_line_id     = ctl.transaction_line_id
      AND    nvl(ctld.source_transaction_flag,'N') = 'N'
      AND    ctld.instance_id             = p_instance_id
      AND    ctld.processing_status       = 'PROCESSED';

   --fix for bug4607042
    CURSOR rel_build_cur(p_instance_id IN NUMBER) IS
     SELECT 'X'
     FROM csi_ii_relationships
     WHERE subject_id = p_instance_id
     AND relationship_type_code = 'COMPONENT-OF'
     AND active_end_date IS NULL;
    --end of fix bug4607042


  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('filter_processed_instances');

    debug('    instance_tbl count :'||px_instance_tbl.COUNT);

    IF px_instance_tbl.COUNT > 0 THEN
      FOR l_ind IN px_instance_tbl.FIRST .. px_instance_tbl.LAST
      LOOP
        l_processed := FALSE;
        FOR tld_rec IN tld_cur(p_order_line_id, px_instance_tbl(l_ind).instance_id)
        LOOP
          l_processed := TRUE;
          exit;
        END LOOP;
     --fix for bug4607042
        IF NOT (l_processed) THEN
        FOR rel_build_rec IN rel_build_cur(px_instance_tbl(l_ind).instance_id)
        LOOP
            l_processed := TRUE;
           exit;
        END LOOP;
        END IF;
    --end of fix bug4607042
        IF NOT(l_processed) THEN
          l_i_ind := l_i_ind + 1;
          l_instance_tbl(l_i_ind) := px_instance_tbl(l_ind);
        END IF;
      END LOOP;
      px_instance_tbl := l_instance_tbl;
      debug('    filtered instance_tbl count :'||px_instance_tbl.COUNT);
    END IF;

  END filter_processed_instances;

  PROCEDURE build_child_relation(
    p_order_line_rec     IN csi_order_ship_pub.order_line_rec,
    p_model_txn_line_rec IN csi_t_datastructures_grp.txn_line_rec,
    px_csi_txn_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status         OUT NOCOPY varchar2)
  IS

    l_inst_query_rec        csi_datastructures_pub.instance_query_rec;
    l_party_query_rec       csi_datastructures_pub.party_query_rec;
    l_pty_acct_query_rec    csi_datastructures_pub.party_account_query_rec;

    l_instance_hdr_tbl      csi_datastructures_pub.instance_header_tbl;
    l_instance_tbl          csi_datastructures_pub.instance_tbl;

    l_txn_line_query_rec        csi_t_datastructures_grp.txn_line_query_rec;
    l_txn_line_detail_query_rec csi_t_datastructures_grp.txn_line_detail_query_rec;

    l_line_dtl_rec          csi_t_datastructures_grp.txn_line_detail_rec;
    l_line_dtl_tbl          csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl           csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl          csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_ii_rltns_tbl          csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_org_assgn_tbl         csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_ext_attrib_tbl        csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_csi_ea_tbl            csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_csi_eav_tbl           csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_txn_systems_tbl       csi_t_datastructures_grp.txn_systems_tbl;

    l_line_tbl              oe_order_pub.line_tbl_type;
    l_quantity_ratio        number;

    l_model_order_qty       number;

    l_instance_found        boolean;
    l_instance_created      boolean;

    l_object_id             number;
    l_debug_level           number;

    l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_data              varchar2(512);
    l_msg_count             number;

    l_txn_ps_tbl           csi_utl_pkg.txn_ps_tbl;

    --fix for bug5096435
    l_order_line_qty        number;
    l_temp_line_rec         oe_order_pub.Line_Rec_Type;
    l_next_item_id          number := 0;
    l_temp_idx              number := 0;
    l_temp_instance_hdr_tbl csi_datastructures_pub.instance_header_tbl;
    l_temp_index            number := 0;


  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    api_log('build_child_relation');

    get_ib_trackable_children(
      p_order_line_rec     => p_order_line_rec,
      x_trackable_line_tbl => l_line_tbl,
      x_return_status      => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('IB Trackable Children Count :'||l_line_tbl.COUNT);

    IF l_line_tbl.COUNT > 0 THEN
        --fix for bug5096435
        --Here child_line_tbl is sorted and rearranged to ensure that
	--two/more different remnant lines of same inventory item are put together
	--in the plsql table.
        IF nvl(p_order_line_rec.model_remnant_flag,'N') = 'Y' THEN
        FOR i IN 1..l_line_tbl.COUNT
        LOOP
            IF l_line_tbl(i).model_remnant_flag = 'Y' THEN
                l_temp_index := i+1;
                FOR j IN l_temp_index..l_line_tbl.COUNT
                LOOP
                    IF l_line_tbl(j).inventory_item_id = l_line_tbl(i).inventory_item_id
                    AND j <> l_temp_index THEN
                        l_temp_line_rec := l_line_tbl(l_temp_index);
                        l_line_tbl(l_temp_index) := l_line_tbl(j);
                        l_line_tbl(j)   := l_temp_line_rec;
                        EXIT;
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
        END IF;
        --end of fix for bug5096435

      debug('Getting Transaction Details for Building Relation.');

      l_txn_line_query_rec.source_transaction_table        := 'WSH_DELIVERY_DETAILS';
      l_txn_line_query_rec.source_transaction_id           := p_order_line_rec.order_line_id;
      l_txn_line_detail_query_rec.source_transaction_flag  := 'Y';
      l_txn_line_detail_query_rec.processing_status        := 'IN_PROCESS';

      csi_t_txn_details_grp.get_transaction_details(
        p_api_version               => 1,
        p_commit                    => fnd_api.g_false,
        p_init_msg_list             => fnd_api.g_true,
        p_validation_level          => fnd_api.g_valid_level_full,
        p_txn_line_query_rec        => l_txn_line_query_rec,
        p_txn_line_detail_query_rec => l_txn_line_detail_query_rec,
        x_txn_line_detail_tbl       => l_line_dtl_tbl,
        p_get_parties_flag          => fnd_api.g_false,
        x_txn_party_detail_tbl      => l_pty_dtl_tbl,
        p_get_pty_accts_flag        => fnd_api.g_false,
        x_txn_pty_acct_detail_tbl   => l_pty_acct_tbl,
        p_get_ii_rltns_flag         => fnd_api.g_false,
        x_txn_ii_rltns_tbl          => l_ii_rltns_tbl,
        p_get_org_assgns_flag       => fnd_api.g_false,
        x_txn_org_assgn_tbl         => l_org_assgn_tbl,
        p_get_ext_attrib_vals_flag  => fnd_api.g_false,
        x_txn_ext_attrib_vals_tbl   => l_ext_attrib_tbl,
        p_get_csi_attribs_flag      => fnd_api.g_false,
        x_csi_ext_attribs_tbl       => l_csi_ea_tbl,
        p_get_csi_iea_values_flag   => fnd_api.g_false,
        x_csi_iea_values_tbl        => l_csi_eav_tbl,
        p_get_txn_systems_flag      => fnd_api.g_false,
        x_txn_systems_tbl           => l_txn_systems_tbl,
        x_return_status             => l_return_status,
        x_msg_count                 => l_msg_count,
        x_msg_data                  => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        raise fnd_api.g_exc_error;
      END IF;
      debug('  Source Txn Line Detail COUNT :'||l_line_dtl_tbl.COUNT);

      FOR l_ol_ind in l_line_tbl.FIRST..l_line_tbl.LAST
      LOOP
        --fix for 5096435
        --This check ensures that we figure out quantity ratio by summing
        --order quantity,incase if remnant lines of same item are put
        --unpreportionate quantity.
         IF nvl(p_order_line_rec.model_remnant_flag,'N') = 'Y' THEN
           IF l_ol_ind <> l_line_tbl.LAST THEN
                l_next_item_id := l_line_tbl(l_ol_ind+1).inventory_item_id;
           ELSE
		l_next_item_id := -99;
           END IF;
           IF l_line_tbl(l_ol_ind).inventory_item_id <> l_next_item_id THEN
             BEGIN
            	select sum(ordered_quantity)
            	into l_order_line_qty
            	from oe_order_lines_all
            	where link_to_line_id = l_line_tbl(l_ol_ind).link_to_line_id
            	and inventory_item_id = l_line_tbl(l_ol_ind).inventory_item_id
            	and model_remnant_flag = 'Y';
             EXCEPTION
             WHEN others THEN
                NULL;
             END;
              l_quantity_ratio := l_order_line_qty / p_order_line_rec.ordered_quantity;
           ELSE
              l_quantity_ratio := -99;
	      debug('Remnant order line splitted across inproper qty,so qty_ratio calculated with adding ordered quantity');
           END IF;
         ELSE
           l_quantity_ratio := l_line_tbl(l_ol_ind).ordered_quantity/p_order_line_rec.ordered_quantity;
         END IF;
          debug('l_quantity_ratio : ' || l_quantity_ratio);
         --end of fix for bug 5096435
        l_inst_query_rec.inventory_item_id     := l_line_tbl(l_ol_ind).inventory_item_id;
        l_inst_query_rec.last_oe_order_line_id := l_line_tbl(l_ol_ind).line_id;
	l_instance_found := FALSE;

        debug('  query criteria for get_item_instances - '||l_line_tbl(l_ol_ind).item_type_code);
        debug('  inventory_item_id     : '||l_inst_query_rec.inventory_item_id);
        debug('  last_oe_order_line_id : '||l_inst_query_rec.last_oe_order_line_id);

        debug('Child item type :'||l_line_tbl(l_ol_ind).item_type_code);

        csi_t_gen_utility_pvt.dump_api_info(
          p_api_name => 'get_item_instances',
          p_pkg_name => 'csi_item_instance_pub');

        csi_item_instance_pub.get_item_instances(
          p_api_version          => 1.0,
          p_commit               => fnd_api.g_false,
          p_init_msg_list        => fnd_api.g_true,
          p_validation_level     => fnd_api.g_valid_level_full,
          p_instance_query_rec   => l_inst_query_rec,
          p_party_query_rec      => l_party_query_rec,
          p_account_query_rec    => l_pty_acct_query_rec,
          p_transaction_id       => null,
          p_resolve_id_columns   => fnd_api.g_false,
          p_active_instance_only => fnd_api.g_true,
          x_instance_header_tbl  => l_instance_hdr_tbl,
          x_return_status        => l_return_status,
          x_msg_count            => l_msg_count,
          x_msg_data             => l_msg_data  );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          raise fnd_api.g_exc_error;
        END IF;
        --fix for bug5096435
	IF l_instance_hdr_tbl.COUNT > 0 THEN
              debug('instances found for the child order line : '||l_instance_hdr_tbl.COUNT);
	      l_instance_found := TRUE;
        ELSE
              debug('instances not found for the child order line');
	      l_instance_found := FALSE;
        END IF;
	IF l_instance_found THEN
  	 IF nvl(p_order_line_rec.model_remnant_flag,'N') = 'Y' THEN
	      FOR i IN l_instance_hdr_tbl.FIRST..l_instance_hdr_tbl.LAST
              LOOP
               l_temp_idx := l_temp_idx + 1;
               l_temp_instance_hdr_tbl(l_temp_idx) := l_instance_hdr_tbl(i);
              END LOOP;
	    IF l_quantity_ratio <> -99 THEN
                l_temp_idx := 0;
            END IF;
         ELSE
           l_temp_instance_hdr_tbl := l_instance_hdr_tbl;
         END IF;
	END IF;
      --end of fix for bug5096435
      --Here we ensure that we go for building non-source rec only after accumulating
      --all the instances created among two/more remnant lines belonging to same inv item.
       IF nvl(p_order_line_rec.model_remnant_flag,'N') <> 'Y' OR --fix for bug5096435
         (nvl(p_order_line_rec.model_remnant_flag,'N') = 'Y' AND l_quantity_ratio <> -99) THEN

        IF l_temp_instance_hdr_tbl.COUNT > 0 THEN
          make_non_header_tbl(
            p_instance_header_tbl => l_temp_instance_hdr_tbl, --fix for bug5096435
            x_instance_tbl        => l_instance_tbl,
            x_return_status       => l_return_status);

	  IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          l_temp_instance_hdr_tbl.DELETE;

          filter_processed_instances(
            p_order_line_id  => p_order_line_rec.order_line_id,
            px_instance_tbl  => l_instance_tbl,
            x_return_status  => l_return_status);

	  IF l_return_status <> fnd_api.g_ret_sts_success THEN
             RAISE fnd_api.g_exc_error;
          END IF;

          IF l_instance_tbl.count > 0 THEN

	   l_txn_ps_tbl.DELETE;

           /* initialize  txn_ps_tbl */

          IF l_line_dtl_tbl.COUNT > 0 THEN

            FOR l_ind IN l_line_dtl_tbl.FIRST..l_line_dtl_tbl.LAST
            LOOP

              l_txn_ps_tbl(l_ind).txn_line_detail_id := l_line_dtl_tbl(l_ind).txn_line_detail_id;
              l_txn_ps_tbl(l_ind).quantity           := l_line_dtl_tbl(l_ind).quantity;
              l_txn_ps_tbl(l_ind).processed_flag     := 'N';
              l_txn_ps_tbl(l_ind).quantity_ratio     := l_quantity_ratio;
              l_txn_ps_tbl(l_ind).quantity_remaining := l_quantity_ratio;

            END LOOP;

            dump_txn_ps_tbl(
              p_txn_ps_tbl => l_txn_ps_tbl);

          END IF;

          -- call distribute instances
          distribute_instances(
            p_quantity_ratio       => l_quantity_ratio,
            p_model_txn_line_rec   => p_model_txn_line_rec,
            px_instance_tbl        => l_instance_tbl,
            px_txn_ps_tbl          => l_txn_ps_tbl,
            x_return_status        => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_instance_tbl.COUNT > 0 THEN
            debug('There exist unresolved instances. So splitting instances.');

            split_instances(
              px_csi_txn_rec   => px_csi_txn_rec,
              px_instance_tbl  => l_instance_tbl,
              x_return_status  => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            debug('Re-distributing after the split.');

            distribute_instances(
              p_quantity_ratio       => l_quantity_ratio,
              p_model_txn_line_rec   => p_model_txn_line_rec,
              px_instance_tbl        => l_instance_tbl,
              px_txn_ps_tbl          => l_txn_ps_tbl,
              x_return_status        => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF; --<<end if l_instance_tbl.count > 0>>
          END IF; --<<end if l_instance_tbl.COUNT > 0>>
	END IF; --<<end if l_instance_hdr_tbl.COUNT > 0>>
        END IF; --remnant check cond for bug 5096435
      END LOOP; -- child order lines loop
    END IF; --<<end if l_line_tbl.COUNT > 0>>

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END build_child_relation;

  PROCEDURE get_unit_price_in_primary_uom(
    p_unit_price                IN     number,
    p_unit_price_uom            IN     varchar2,
    px_item_control_rec         IN OUT nocopy csi_order_ship_pub.item_control_rec,
    x_unit_price_in_primary_uom    OUT nocopy number,
    x_return_status                OUT nocopy varchar2)
  IS
    l_uom_conv_rate             number;
  BEGIN

    api_log('get_unit_price_in_primary_uom');

    x_return_status := fnd_api.g_ret_sts_success;

    IF nvl(px_item_control_rec.primary_uom_code, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN

      px_item_control_rec.primary_uom_code := csi_utl_pkg.get_primay_uom(
        p_inv_item_id => px_item_control_rec.inventory_item_id,
        p_inv_org_id  => px_item_control_rec.organization_id);

    END IF;

    inv_convert.inv_um_conversion (
      from_unit  => p_unit_price_uom,
      to_unit    => px_item_control_rec.primary_uom_code,
      item_id    => px_item_control_rec.inventory_item_id,
      uom_rate   => l_uom_conv_rate);

    debug('  uom conv rate             : '||l_uom_conv_rate);

    IF l_uom_conv_rate = -99999 THEN
      debug('  inv_convert.inv_um_conversion failed ');
      RAISE fnd_api.g_exc_error;
    END IF;

    x_unit_price_in_primary_uom := p_unit_price/l_uom_conv_rate;

    debug('  unit price in primary uom : '||x_unit_price_in_primary_uom);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_unit_price_in_primary_uom;

END csi_utl_pkg ;

/

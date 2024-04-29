--------------------------------------------------------
--  DDL for Package Body CSI_T_VLDN_ROUTINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_T_VLDN_ROUTINES_PVT" AS
/* $Header: csivtvlb.pls 120.4.12000000.2 2007/06/12 09:50:11 smrsharm ship $ */

  /*-----------------------------------------------------------*/
  /* Procedure name: Check_Reqd_Param                          */
  /* Description : To Check if the reqd parameter is passed    */
  /* Overloading the procedure to handle all the data types    */
  /*-----------------------------------------------------------*/

  PROCEDURE check_reqd_param(
    p_value             IN  NUMBER,
    p_param_name        IN  VARCHAR2,
    p_api_name          IN  VARCHAR2)
  IS
  BEGIN

    IF (NVL(p_value,FND_API.g_miss_num) = FND_API.g_miss_num) THEN

      FND_MESSAGE.set_name('CSI','CSI_API_REQD_PARAM_MISSING');
      FND_MESSAGE.set_token('API_NAME',p_api_name);
      FND_MESSAGE.set_token('MISSING_PARAM',p_param_name);
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;

    END IF;

  END Check_Reqd_Param;

  PROCEDURE Check_Reqd_Param(
    p_value             IN  VARCHAR2,
    p_param_name        IN  VARCHAR2,
    p_api_name          IN  VARCHAR2)
  IS
  BEGIN

    IF (NVL(p_value,FND_API.g_miss_char) = FND_API.g_miss_char) THEN

      FND_MESSAGE.set_name('CSI','CSI_API_REQD_PARAM_MISSING');
      FND_MESSAGE.set_token('API_NAME',p_api_name);
      FND_MESSAGE.set_token('MISSING_PARAM',p_param_name);
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;

    END IF;

  END Check_Reqd_Param;

  PROCEDURE Check_Reqd_Param(
    p_value             IN  DATE,
    p_param_name        IN  VARCHAR2,
    p_api_name          IN  VARCHAR2)
  IS
  BEGIN

    IF (NVL(p_value,FND_API.g_miss_date) = FND_API.g_miss_date) THEN

      FND_MESSAGE.set_name('CSI','CSI_API_REQD_PARAM_MISSING');
      FND_MESSAGE.set_token('API_NAME',p_api_name);
      FND_MESSAGE.set_token('MISSING_PARAM',p_param_name);
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;

    END IF;

  END Check_Reqd_Param;

  /* Validate transaction line id */
  PROCEDURE validate_transaction_line_id (
    p_transaction_line_id    IN  NUMBER,
    x_transaction_line_rec   OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    x_return_status          OUT NOCOPY VARCHAR2)
  IS
    l_found VARCHAR2(1);
    -- SELECT 'X' INTO l_found -- changed for Mass update R12
    Cursor txn_line_cur (p_txn_line_id IN Number) is
        SELECT transaction_line_id,
           source_transaction_type_id,
           source_transaction_id,
           source_transaction_table,
           source_txn_header_id,
           processing_status,
           error_code,
           error_explanation,
           config_session_hdr_id,
           config_session_item_id,
           config_session_rev_num,
           config_valid_status
    FROM   csi_t_transaction_lines
    where  transaction_line_id = p_txn_line_id;

    l_txn_line_rec  txn_line_cur%rowtype;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    Open txn_line_cur(p_transaction_line_id) ;
    Fetch txn_line_cur Into l_txn_line_rec;

    IF NOT txn_line_cur%FOUND THEN
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    Close txn_line_cur;

    x_transaction_line_rec.transaction_line_id             := l_txn_line_rec.transaction_line_id;
    x_transaction_line_rec.source_transaction_type_id      := l_txn_line_rec.source_transaction_type_id;
    x_transaction_line_rec.source_transaction_id           := l_txn_line_rec.source_transaction_id;
    x_transaction_line_rec.source_transaction_table        := l_txn_line_rec.source_transaction_table;
    x_transaction_line_rec.source_txn_header_id            := l_txn_line_rec.source_txn_header_id;
    x_transaction_line_rec.processing_status               := l_txn_line_rec.processing_status;
    x_transaction_line_rec.error_code                      := l_txn_line_rec.error_code;
    x_transaction_line_rec.error_explanation               := l_txn_line_rec.error_explanation;
    x_transaction_line_rec.config_session_hdr_id           := l_txn_line_rec.config_session_hdr_id;
    x_transaction_line_rec.config_session_item_id          := l_txn_line_rec.config_session_item_id;
    x_transaction_line_rec.config_session_rev_num          := l_txn_line_rec.config_session_rev_num;
    x_transaction_line_rec.config_valid_status             := l_txn_line_rec.config_valid_status;

  EXCEPTION
    WHEN others THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_transaction_line_id;


  /* Validate txn_line_detail_id */
  PROCEDURE validate_txn_line_detail_id(
    p_txn_line_detail_id IN  NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2)
  IS
    l_found varchar2(1);
  BEGIN

    SELECT 'X'
    INTO   l_found
    FROM   csi_t_txn_line_details
    WHERE  txn_line_detail_id = p_txn_line_detail_id;

    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_txn_line_detail_id;

  /* Validate txn_line_detail_id */ -- Added this overloaded routine for M-M
  PROCEDURE validate_txn_line_detail_id(
    p_txn_line_detail_id IN  NUMBER,
    x_txn_line_detail_rec OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    x_return_status      OUT NOCOPY VARCHAR2)
  IS
    Cursor txn_line_dtl_cur (p_txn_line_dtl_id IN Number) IS
      SELECT txn_line_detail_id,
          transaction_line_id,
          source_transaction_flag,
          instance_id,
          location_type_code,
          location_id,
          active_start_date,
          active_end_date,
          changed_instance_id,
          source_txn_line_detail_id,
          processing_status,
          config_inst_hdr_id,
          config_inst_rev_num,
          config_inst_item_id
      FROM   csi_t_txn_line_details
      WHERE  txn_line_detail_id = p_txn_line_dtl_id;

    l_txn_line_detail_rec  txn_line_dtl_cur%rowtype;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    Open txn_line_dtl_cur (p_txn_line_detail_id);
    Fetch txn_line_dtl_cur into l_txn_line_detail_rec;

    IF NOT txn_line_dtl_cur%FOUND THEN
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    Close txn_line_dtl_cur;

        x_txn_line_detail_rec.txn_line_detail_id        := l_txn_line_detail_rec.txn_line_detail_id;
        x_txn_line_detail_rec.transaction_line_id       := l_txn_line_detail_rec.transaction_line_id;
        x_txn_line_detail_rec.source_transaction_flag   := l_txn_line_detail_rec.source_transaction_flag;
        x_txn_line_detail_rec.instance_id               := l_txn_line_detail_rec.instance_id;
        x_txn_line_detail_rec.location_type_code        := l_txn_line_detail_rec.location_type_code;
        x_txn_line_detail_rec.location_id               := l_txn_line_detail_rec.location_id;
        x_txn_line_detail_rec.active_start_date         := l_txn_line_detail_rec.active_start_date;
        x_txn_line_detail_rec.active_end_date           := l_txn_line_detail_rec.active_end_date;
        x_txn_line_detail_rec.changed_instance_id       := l_txn_line_detail_rec.changed_instance_id;
        x_txn_line_detail_rec.source_txn_line_detail_id := l_txn_line_detail_rec.source_txn_line_detail_id;
        x_txn_line_detail_rec.processing_status         := l_txn_line_detail_rec.processing_status;
        x_txn_line_detail_rec.config_inst_hdr_id        := l_txn_line_detail_rec.config_inst_hdr_id;
        x_txn_line_detail_rec.config_inst_rev_num       := l_txn_line_detail_rec.config_inst_rev_num;
        x_txn_line_detail_rec.config_inst_item_id       := l_txn_line_detail_rec.config_inst_item_id;

  EXCEPTION
    WHEN others THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_txn_line_detail_id;

  /* Validate txn_party_detail_id */
  PROCEDURE validate_txn_party_detail_id(
    p_txn_party_detail_id IN  NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2)
  IS
    l_found varchar2(1);
  BEGIN

    SELECT 'X'
    INTO   l_found
    FROM   csi_t_party_details
    WHERE  txn_party_detail_id = p_txn_party_detail_id;

    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN others then
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_txn_party_detail_id;


  /* validate transaction party account detail id */
  PROCEDURE validate_txn_acct_detail_id(
    p_txn_acct_detail_id  IN  NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2)
  IS
    l_found varchar2(1);
  BEGIN

    SELECT 'X'
    INTO   l_found
    FROM   csi_t_party_accounts
    WHERE  txn_account_detail_id = p_txn_acct_detail_id;

    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN others then
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_txn_acct_detail_id;


  /* validate relationship id */
  PROCEDURE validate_txn_relationship_id(
    p_txn_relationship_id  IN  NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2)
  IS
    l_found varchar2(1);
  BEGIN

    SELECT 'X'
    INTO   l_found
    FROM   csi_t_ii_relationships
    WHERE  txn_relationship_id = p_txn_relationship_id;

    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END validate_txn_relationship_id;

  /* validate transaction operating unit_id */
  PROCEDURE validate_txn_ou_id(
    p_txn_operating_unit_id  IN  NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2)
  IS
    l_found varchar2(1);
  BEGIN

    SELECT 'X'
    INTO   l_found
    FROM   csi_t_org_assignments
    WHERE  txn_operating_unit_id = p_txn_operating_unit_id;

    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END validate_txn_ou_id;


  /* validate the transaction attrib detail id */
  PROCEDURE validate_txn_attrib_detail_id(
    p_txn_attrib_detail_id  IN  NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2)
  IS
    l_found varchar2(1);
  BEGIN

    SELECT 'X'
    INTO   l_found
    FROM   csi_t_extend_attribs
    WHERE  txn_attrib_detail_id = p_txn_attrib_detail_id;

    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END validate_txn_attrib_detail_id;

  /* Validate the txn_source_id */
  PROCEDURE validate_txn_source_id(
    p_txn_source_name    IN  VARCHAR2,
    p_txn_source_id      IN  NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2)
  IS
    l_found      VARCHAR2(1);
  BEGIN

    IF p_txn_source_name = 'ORDER_ENTRY' THEN

      SELECT 'X'
      INTO   l_found
      FROM   oe_order_lines_all
      WHERE  line_id = p_txn_source_id;

      x_return_status := fnd_api.g_ret_sts_success;

    END IF;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN others THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END validate_txn_source_id;


  /* check whether the TD has been converted in to IB */
  PROCEDURE check_ib_creation(
    p_transaction_line_id  IN  NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2)
  IS

    l_processing_status  csi_t_transaction_lines.processing_status%TYPE;
    l_processed_found    BOOLEAN := FALSE;

    CURSOR proc_cur IS
      SELECT 'X'
      FROM   csi_t_txn_line_details
      WHERE  transaction_line_id = p_transaction_line_id
      AND    (csi_transaction_id is not null
              OR
              processing_status = 'PROCESSED');

  BEGIN

    SELECT processing_status
    INTO   l_processing_status
    FROM   csi_t_transaction_lines
    WHERE  transaction_line_id = p_transaction_line_id;

    FOR proc_rec in proc_cur
    LOOP
      l_processed_found := TRUE;
    END LOOP;

    IF (l_processing_status = 'PROCESSED') OR (l_processed_found = TRUE) THEN
      x_return_status := fnd_api.g_true;
    ELSE
      x_return_status := fnd_api.g_false;
    END IF;

  END check_ib_creation;


  /* Validate subject_id */
  PROCEDURE validate_subject_id(
    p_subject_id       IN  NUMBER,
    p_txn_line_dtl_id  IN  NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2)
  IS

    l_instance_exists_flag csi_t_txn_line_details.instance_exists_flag%TYPE;
    l_instance_id          csi_t_txn_line_details.instance_id%TYPE;
    l_inventory_item_id    csi_t_txn_line_details.inventory_item_id%TYPE;
    l_inv_organization_id  csi_t_txn_line_details.inv_organization_id%TYPE;

    l_subject_id            NUMBER;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    SELECT instance_exists_flag,
           instance_id,
           inventory_item_id,
           inv_organization_id
    INTO   l_instance_exists_flag,
           l_instance_id,
           l_inventory_item_id,
           l_inv_organization_id
    FROM   csi_t_txn_line_details
    WHERE  txn_line_detail_id = p_txn_line_dtl_id;

    IF l_instance_exists_flag = 'Y' THEN
      l_subject_id := l_instance_id;
    ELSE
      l_subject_id := l_inventory_item_id;
    END IF;

    IF p_subject_id <> l_subject_id THEN
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_subject_id;


  PROCEDURE validate_object_id(
    p_object_id      IN  NUMBER,
    x_return_status  OUT NOCOPY varchar2)
  IS
    l_found     VARCHAR2(1);
  BEGIN

    SELECT 'X'
    INTO   l_found
    FROM   csi_item_instances
    WHERE  instance_id = p_object_id;

    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_object_id;

  /* validate relationship type code for item instances */
  PROCEDURE validate_ii_rltns_type_code(
    p_rltns_type_code    IN  VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2)
  IS
    v_found         varchar2(1);
  BEGIN

    SELECT 'X'
    INTO   v_found
    FROM   csi_ii_relation_types
    WHERE  relationship_type_code = p_rltns_type_code;

    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END validate_ii_rltns_type_code;

  /* validate instance party id from csi_i_parties */
  PROCEDURE validate_instance_party_id(
    p_instance_id        IN  number,
    p_instance_party_id  IN  number,
    x_return_status      OUT NOCOPY VARCHAR2)
  IS
    v_found         varchar2(1);
  BEGIN

    SELECT 'X'
    INTO   v_found
    FROM   csi_i_parties
    WHERE  instance_id = p_instance_id
    AND    instance_party_id = p_instance_party_id;

    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END validate_instance_party_id;

  PROCEDURE validate_ip_account_id(
    p_ip_account_id     IN  number,
    x_return_status     OUT NOCOPY varchar2)
  IS
    l_found varchar2(1);
  BEGIN

    SELECT 'X'
    INTO   l_found
    FROM   csi_ip_accounts
    WHERE  ip_account_id     = p_ip_account_id;

    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_ip_account_id;

  PROCEDURE validate_instance_ou_id(
    p_instance_id IN  number,
    p_instance_ou_id     IN  number,
    x_return_status     OUT NOCOPY varchar2)
  IS
    l_found varchar2(1);
  BEGIN

    SELECT 'X'
    INTO   l_found
    FROM   csi_i_org_assignments
    WHERE  instance_id = p_instance_id
    AND    instance_ou_id = p_instance_ou_id;

    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_instance_ou_id;

  PROCEDURE validate_instance_rltns_id(
    p_csi_inst_rltns_id IN  number,
    x_object_id         OUT NOCOPY number,
    x_return_status     OUT NOCOPY varchar2)
  IS
  BEGIN

    SELECT object_id
    INTO   x_object_id
    FROM   csi_ii_relationships
    WHERE  relationship_id = p_csi_inst_rltns_id;

    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END validate_instance_rltns_id;

  /* integrity check for the source transaction */
  PROCEDURE check_source_integrity(
    p_validation_level   IN  varchar2,
    p_txn_line_rec       IN  csi_t_datastructures_grp.txn_line_rec,
    p_txn_line_dtl_tbl   IN  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status      OUT NOCOPY VARCHAR2)
  IS

    l_total_quantity         NUMBER;
    l_primary_uom_code       mtl_system_items.primary_uom_code%TYPE;

    l_src_item_id            mtl_system_items.inventory_item_id%TYPE;
    l_src_organization_id    mtl_parameters.organization_id%TYPE;
    l_src_quantity           NUMBER;
    l_src_uom_code           VARCHAR2(3);
    l_src_primary_qty        NUMBER;
    l_mo_org_id              oe_order_lines_all.org_id%type;

    l_inst_item_id           csi_item_instances.inventory_item_id%type;
    l_inst_organization_id   csi_item_instances.inv_organization_id%type;
    l_inst_quantity          csi_item_instances.quantity%type;
    l_inst_uom_code          csi_item_instances.unit_of_measure%type;

    l_dtl_item_id            csi_t_txn_line_details.inventory_item_id%type;
    l_dtl_organization_id    csi_t_txn_line_details.inv_organization_id%type;
    l_dtl_quantity           csi_t_txn_line_details.quantity%type;
    l_dtl_uom_code           csi_t_txn_line_details.unit_of_measure%type;
    l_dtl_primary_qty        NUMBER;

    l_src_param_rec          csi_t_ui_pvt.txn_source_param_rec;
    l_src_rec                csi_t_ui_pvt.txn_source_rec;
    l_txn_line_rec           csi_t_datastructures_grp.txn_line_rec;
    l_line_dtl_tbl           csi_t_datastructures_grp.txn_line_detail_tbl;
    l_pty_dtl_tbl            csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acct_tbl           csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_org_assgn_tbl          csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_return_status          varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    l_total_quantity := 0;


    l_src_param_rec.standalone_mode            := 'Y';
    l_src_param_rec.source_transaction_type_id := p_txn_line_rec.source_transaction_type_id;
    l_src_param_rec.source_transaction_table   := p_txn_line_rec.source_transaction_table;
    l_src_param_rec.source_transaction_id      := p_txn_line_rec.source_transaction_id;

    csi_t_utilities_pvt.get_source_dtls(
      p_txn_source_param_rec    => l_src_param_rec,
      x_txn_source_rec          => l_src_rec,
      x_txn_line_rec            => l_txn_line_rec,
      x_txn_line_detail_tbl     => l_line_dtl_tbl,
      x_txn_party_detail_tbl    => l_pty_dtl_tbl,
      x_txn_pty_acct_detail_tbl => l_pty_acct_tbl,
      x_txn_org_assgn_tbl       => l_org_assgn_tbl,
      x_return_status           => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_src_organization_id := l_src_rec.organization_id;
    l_src_item_id         := l_src_rec.inventory_item_id;
    l_src_uom_code        := l_src_rec.source_uom;
    l_src_quantity        := l_src_rec.source_quantity;
    l_primary_uom_code    := l_src_rec.primary_uom;

    -- if the source uom is not the primary uom then convert it to primary

    IF l_src_uom_code <> l_primary_uom_code THEN

      csi_t_gen_utility_pvt.add('Converting to Primary UOM.');

      l_src_primary_qty :=
        inv_convert.inv_um_convert(
          item_id       => l_src_item_id,
          precision     => 6,
          from_quantity => l_src_quantity,
          from_unit     => l_src_uom_code,
          to_unit       => l_primary_uom_code,
          from_name     => null,
          to_name       => null);

      l_src_quantity := l_src_primary_qty;

    END IF;

    IF p_txn_line_dtl_tbl.COUNT > 0 THEN

      FOR l_index IN p_txn_line_dtl_tbl.FIRST..p_txn_line_dtl_tbl.LAST
      LOOP

        l_dtl_item_id         := p_txn_line_dtl_tbl(l_index).inventory_item_id;
        l_dtl_organization_id := p_txn_line_dtl_tbl(l_index).
                                   inv_organization_id;
        l_dtl_uom_code        := p_txn_line_dtl_tbl(l_index).unit_of_measure;
        l_dtl_quantity        := p_txn_line_dtl_tbl(l_index).quantity;

        /* check source item with the instance or the txn line detail item */
        IF p_txn_line_dtl_tbl(l_index).instance_exists_flag = 'Y' THEN

          BEGIN
            --get the instance info like the item, org and quantity
            SELECT inventory_item_id,
                   inv_master_organization_id,
                   unit_of_measure,
                   quantity
            INTO   l_inst_item_id,
                   l_inst_organization_id,
                   l_inst_uom_code,
                   l_inst_quantity
            FROM   csi_item_instances
            WHERE  instance_id = p_txn_line_dtl_tbl(l_index).instance_id;

            l_dtl_item_id         := l_inst_item_id;
            l_dtl_organization_id := l_inst_organization_id;

          EXCEPTION
            WHEN no_data_found THEN
              fnd_message.set_name('CSI', 'CSI_API_INVALID_INSTANCE_ID');
              fnd_message.set_token('INSTANCE_ID',
                          p_txn_line_dtl_tbl(l_index).instance_id);
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
          END;

        END IF;

        ---Added (Start) for m-to-m enhancements
        ---For non Source lines , item id will not match
        ---with order item , so do the following validation
        ---for source lines only.
       IF p_txn_line_dtl_tbl(l_index).source_transaction_flag = 'Y'
       THEN
        IF l_dtl_item_id <> l_src_item_id THEN
          FND_MESSAGE.set_name('CSI','CSI_TXN_SRC_ITEM_CHK_FAILED');
          FND_MESSAGE.set_token('SRC_ITEM_ID',l_src_item_id);
          FND_MESSAGE.set_token('DTL_ITEM_ID',l_dtl_item_id);
          FND_MESSAGE.set_token('SRC_NAME',p_txn_line_rec.source_transaction_table);
          FND_MESSAGE.set_token('SRC_LINE_ID',p_txn_line_rec.source_transaction_id);
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
        END IF;
       END IF ;
       ---Added (End) for m-to-m enhancements

        /* check the td quantity with the source qty  */
        /* sum up the quantity only if txn detail is source based */
        IF p_txn_line_dtl_tbl(l_index).source_transaction_flag = 'Y' THEN

          IF l_dtl_uom_code <> l_primary_uom_code
          THEN

            l_dtl_primary_qty :=
              inv_convert.inv_um_convert(
                item_id       => l_dtl_item_id,
                precision     => 6,
                from_quantity => l_dtl_quantity,
                from_unit     => l_dtl_uom_code,
                to_unit       => l_primary_uom_code,
                from_name     => null,
                to_name       => null);

            l_total_quantity := l_total_quantity + l_dtl_primary_qty;

          ELSE

            l_total_quantity := l_total_quantity +
                             p_txn_line_dtl_tbl(l_index).quantity;
          END IF;

        END IF; -- quantity chk for td with source txn flag - 'Y'


        /* check the location_type_code for the source */
        IF p_txn_line_rec.source_transaction_table = 'OE_ORDER_LINES_ALL' THEN

          IF nvl(p_txn_line_dtl_tbl(l_index).location_id , fnd_api.g_miss_num) <>
             fnd_api.g_miss_num
          THEN

            IF p_txn_line_dtl_tbl(l_index).location_type_code <> 'HZ_PARTY_SITES'
            THEN

              FND_MESSAGE.set_name('CSI','CSI_TXN_SRC_LOC_INVALID');
              FND_MESSAGE.set_token('SRC_NAME',p_txn_line_rec.source_transaction_table);
              FND_MESSAGE.set_token('LOC_code', p_txn_line_dtl_tbl(l_index).
                                              location_type_code);

              FND_MSG_PUB.add;
              RAISE fnd_api.g_exc_error;

            END IF;
          END IF;
        ELSE
          IF nvl(p_txn_line_dtl_tbl(l_index).location_id, fnd_api.g_miss_num)<>
             fnd_api.g_miss_num THEN
            FND_MESSAGE.set_name('CSI','CSI_TXN_PARAM_IGNORED_WARN');
            FND_MESSAGE.set_token('VALUE', p_txn_line_dtl_tbl(l_index).
                                           location_id);
            FND_MESSAGE.set_token('PARAM','LOCATION_ID');
            FND_MESSAGE.set_token('REASON','This is not required for '||
                   'this transaction type '||p_txn_line_rec.source_transaction_table);
            FND_MSG_PUB.add;

          END IF;
        END IF;
      END LOOP;
     -- Added filter criteria for handling RMA cases bug 4244887
     IF nvl(p_txn_line_rec.source_transaction_type_id,0) <> 53 and l_total_quantity <> l_src_quantity THEN

        FND_MESSAGE.set_name('CSI','CSI_TXN_SRC_QTY_CHK_FAILED');
        FND_MESSAGE.set_token('SRC_LINE_ID',p_txn_line_rec.source_transaction_id);
        FND_MESSAGE.set_token('SRC_NAME',p_txn_line_rec.source_transaction_table);
        FND_MESSAGE.set_token('SRC_QTY',l_src_quantity);
        FND_MESSAGE.set_token('DTL_QTY',l_total_quantity);
        FND_MSG_PUB.add;
        IF p_validation_level = fnd_api.g_valid_level_full THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END check_source_integrity;

  /* This procedure checks for the validity of the party details supplied */
  /* Only one owner should be defined for a txn detail record (Instance)  */
  /* Having multiple owner is an error condition                          */

  PROCEDURE check_party_integrity(
    p_txn_line_rec       IN  csi_t_datastructures_grp.txn_line_rec,
    p_txn_line_dtl_tbl   IN  csi_t_datastructures_grp.txn_line_detail_tbl,
    p_party_dtl_tbl      IN  csi_t_datastructures_grp.txn_party_detail_tbl,
    x_return_status      OUT NOCOPY VARCHAR2)
  IS
   l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
   l_owner_count       number;
   l_sub_type_rec      csi_txn_sub_types%rowtype;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    --loop thru line detail table
    IF p_txn_line_dtl_tbl.COUNT > 0 THEN
      FOR l_td_ind IN p_txn_line_dtl_tbl.FIRST.. p_txn_line_dtl_tbl.LAST
      LOOP

        csi_t_vldn_routines_pvt.check_reqd_param(
          p_value       => p_txn_line_dtl_tbl(l_td_ind).sub_type_id,
          p_param_name  => 'p_txn_line_dtl_rec.sub_type_id',
          p_api_name    => 'check_party_integrity');

        BEGIN

          SELECT src_change_owner,
                 non_src_change_owner
          INTO   l_sub_type_rec.src_change_owner,
                 l_sub_type_rec.non_src_change_owner
          FROM   csi_txn_sub_types
          WHERE  sub_type_id = p_txn_line_dtl_tbl(l_td_ind).sub_type_id
          AND    transaction_type_id = p_txn_line_rec.source_transaction_type_id;

        EXCEPTION
          WHEN no_data_found THEN

            FND_MESSAGE.set_name('CSI','CSI_TXN_SUB_TYPE_ID_INVALID');
            FND_MESSAGE.set_token('SUB_TYPE_ID',p_txn_line_dtl_tbl(l_td_ind).sub_type_id);
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_error;

        END;

        l_owner_count := 0;

        IF p_party_dtl_tbl.COUNT > 0 THEN
          FOR l_index IN p_party_dtl_tbl.FIRST .. p_party_dtl_tbl.LAST
          LOOP
            IF p_party_dtl_tbl(l_index).txn_line_details_index = l_td_ind
            THEN
              IF p_party_dtl_tbl(l_index).relationship_type_code = 'OWNER' THEN
                l_owner_count := l_owner_count + 1;
              END IF;
            END IF;

          END LOOP;
        END IF;

        IF (l_owner_count > 1) THEN
          FND_MESSAGE.set_name('CSI','CSI_TXN_MULTIPLE_OWNER');
          FND_MESSAGE.set_token('INDEX',l_td_ind);
          FND_MESSAGE.set_token('ITEM_ID', p_txn_line_dtl_tbl(l_td_ind).
                                               inventory_item_id);
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF p_txn_line_dtl_tbl(l_td_ind).source_transaction_flag = 'Y' THEN
          IF l_sub_type_rec.src_change_owner = 'Y' THEN

            IF (l_owner_count = 0) THEN
              FND_MESSAGE.set_name('CSI','CSI_TXN_OWNER_NOT_FOUND');
              FND_MESSAGE.set_token('INDEX',l_td_ind);
              FND_MESSAGE.set_token('ITEM_ID', p_txn_line_dtl_tbl(l_td_ind).
                                               inventory_item_id);
              FND_MSG_PUB.add;
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;
        ELSE
          IF l_sub_type_rec.non_src_change_owner = 'Y' THEN

            IF (l_owner_count = 0) THEN
              FND_MESSAGE.set_name('CSI','CSI_TXN_OWNER_NOT_FOUND');
              FND_MESSAGE.set_token('INDEX',l_td_ind);
              FND_MESSAGE.set_token('ITEM_ID', p_txn_line_dtl_tbl(l_td_ind).
                                               inventory_item_id);
              FND_MSG_PUB.add;
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;
        END IF;

      END LOOP;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END check_party_integrity;

  /* private routine used within check_rltns_integrity */ -- Modified this routine to address M-M changes
  procedure get_iir_details(
    p_sub_obj_id        IN  NUMBER,
    p_object_yn         IN  varchar2,
    p_iir_tbl           IN  csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_src_dtl_count     OUT NOCOPY NUMBER,
    x_return_status     OUT NOCOPY varchar2,
    x_iir_tbl           OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl)
  IS
   l_loc_ind         binary_integer;
   l_comp_of_count   number;

  BEGIN
    l_loc_ind       := 0;
    l_comp_of_count := 0;
    x_src_dtl_count := 0;
    x_return_status := fnd_api.g_ret_sts_success;

    IF p_iir_tbl.COUNT > 0 THEN
      FOR l_ind IN p_iir_tbl.FIRST .. p_iir_tbl.LAST
      LOOP
        IF p_object_yn = 'N' THEN

            IF p_iir_tbl(l_ind).subject_id = p_sub_obj_id THEN
                IF ( p_iir_tbl(l_ind).subject_type =  p_iir_tbl(l_ind).object_type
                    AND p_iir_tbl(l_ind).subject_type = 'I' ) THEN --atleast one of them should be 'T'

                      FND_MESSAGE.set_name('CSI','CSI_TXN_INVALID_SUB_OBJ_TYPES');
                      FND_MESSAGE.set_token('TXN_DTL_ID',p_sub_obj_id);
                      FND_MSG_PUB.add;
                      x_return_status := fnd_api.g_ret_sts_error;
                    exit;
                END IF;

                IF p_iir_tbl(l_ind).relationship_type_code = 'COMPONENT-OF' THEN
                    l_comp_of_count := l_comp_of_count + 1;
                END IF;

                IF p_iir_tbl(l_ind).object_type = 'T' THEN
                    x_src_dtl_count := x_src_dtl_count + 1; -- count to check if a Non-Source atleast has one TLD tied to it
                END IF;

              l_loc_ind := l_loc_ind + 1;
              x_iir_tbl(l_loc_ind).csi_inst_relationship_id :=
                        p_iir_tbl(l_ind).csi_inst_relationship_id;
              x_iir_tbl(l_loc_ind).subject_id               :=
                        p_iir_tbl(l_ind).subject_id;
              x_iir_tbl(l_loc_ind).object_id                :=
                        p_iir_tbl(l_ind).object_id;
              x_iir_tbl(l_loc_ind).relationship_type_code   :=
                        p_iir_tbl(l_ind).relationship_type_code;
              x_iir_tbl(l_loc_ind).subject_type             :=
                        p_iir_tbl(l_ind).subject_type;
              x_iir_tbl(l_loc_ind).object_type              :=
                        p_iir_tbl(l_ind).object_type;
              x_iir_tbl(l_loc_ind).object_index_flag              :=
                        p_iir_tbl(l_ind).object_index_flag;
              x_iir_tbl(l_loc_ind).subject_index_flag             :=
                        p_iir_tbl(l_ind).subject_index_flag;
            END IF;
          ELSE  -- p_object_yn = 'Y'; repeat the same above
            IF p_iir_tbl(l_ind).object_id = p_sub_obj_id THEN

                IF ( ( p_iir_tbl(l_ind).subject_type not in  ('T','I') ) OR
                     ( p_iir_tbl(l_ind).object_type not in  ('T','I') ) ) THEN
                      FND_MESSAGE.set_name('CSI','CSI_TXN_INVALID_SUB_OBJ_TYPES');
                      FND_MESSAGE.set_token('TXN_DTL_ID',p_sub_obj_id);
                      FND_MSG_PUB.add;
                      x_return_status := fnd_api.g_ret_sts_error;
                      exit;
                ELSIF ( ( p_iir_tbl(l_ind).subject_type =  p_iir_tbl(l_ind).object_type) AND
                        (p_iir_tbl(l_ind).object_type = 'I' ) ) THEN --atleast one of them should be 'T'

                      FND_MESSAGE.set_name('CSI','CSI_TXN_INVALID_SUB_OBJ_TYPES');
                      FND_MESSAGE.set_token('TXN_DTL_ID',p_sub_obj_id);
                      FND_MSG_PUB.add;
                      x_return_status := fnd_api.g_ret_sts_error;
                      exit;
                END IF;

                IF p_iir_tbl(l_ind).relationship_type_code = 'COMPONENT-OF' THEN
                    l_comp_of_count := l_comp_of_count + 1;
                END IF;

                IF p_iir_tbl(l_ind).subject_type = 'T' THEN
                    x_src_dtl_count := x_src_dtl_count + 1; -- count to check if a Non-Source atleast has one TLD tied to it
                END IF;

              l_loc_ind := l_loc_ind + 1;
              x_iir_tbl(l_loc_ind).csi_inst_relationship_id :=
                        p_iir_tbl(l_ind).csi_inst_relationship_id;
              x_iir_tbl(l_loc_ind).subject_id               :=
                        p_iir_tbl(l_ind).subject_id;
              x_iir_tbl(l_loc_ind).object_id                :=
                        p_iir_tbl(l_ind).object_id;
              x_iir_tbl(l_loc_ind).relationship_type_code   :=
                        p_iir_tbl(l_ind).relationship_type_code;
              x_iir_tbl(l_loc_ind).subject_type             :=
                        p_iir_tbl(l_ind).subject_type;
              x_iir_tbl(l_loc_ind).object_type              :=
                        p_iir_tbl(l_ind).object_type;
              x_iir_tbl(l_loc_ind).object_index_flag              :=
                        p_iir_tbl(l_ind).object_index_flag;
              x_iir_tbl(l_loc_ind).subject_index_flag             :=
                        p_iir_tbl(l_ind).subject_index_flag;
            END IF;
          END IF; --object_yn = 'N'
        END LOOP;

         IF l_comp_of_count > 1 THEN
           x_return_status := fnd_api.g_ret_sts_error; -- this status is then used to determine the multiple comp-of condition
         END IF;

    END IF;
  END get_iir_details;

  /* this routine makes sure that if a non sourced line detail is passed then
     it should be tied to its sourced parent using the item relationship link.
     The basic assumption there cannot be a non sourced (configuration item)
     line detail hanging in without a parent
     Plus added additional checks because of M-M changes
  */

  PROCEDURE check_rltns_integrity(
    p_txn_line_detail_tbl  IN  csi_t_datastructures_grp.txn_line_detail_tbl,
    p_txn_ii_rltns_tbl     IN  csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status        OUT NOCOPY VARCHAR2)
  IS
    l_line_dtl_tbl    csi_t_datastructures_grp.txn_line_detail_tbl;
    l_line_dtl_rec    csi_t_datastructures_grp.txn_line_detail_rec;
    l_line_dtl_g_miss csi_t_datastructures_grp.txn_line_detail_rec;
    l_iir_tbl         csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_return_status   VARCHAR2(1);
    l_subject_id      NUMBER ;
    l_object_id       NUMBER ;
    l_object_type     VARCHAR2(30);
    l_subject_type    VARCHAR2(30);
    l_sub_obj_id      NUMBER  := fnd_api.g_miss_num;
    l_object_yn       VARCHAR2(1);
    l_line_id1        NUMBER;
    l_line_id2        NUMBER;
    l_src_flag1       VARCHAR2(1);
    l_src_flag2       VARCHAR2(1);
    l_src_dtl_count   number;
    l_subject_index_flag  varchar2(1);
    l_object_index_flag  varchar2(1);


  BEGIN

    l_line_dtl_tbl := p_txn_line_detail_tbl;

    IF l_line_dtl_tbl.COUNT > 0
    THEN
     IF p_txn_ii_rltns_tbl.COUNT > 0
     THEN
      FOR l_td_ind IN l_line_dtl_tbl.FIRST .. l_line_dtl_tbl.LAST
        LOOP
          l_object_yn := 'N';
          l_sub_obj_id := l_line_dtl_tbl(l_td_ind).txn_line_detail_id;

          IF ( l_sub_obj_id = fnd_api.g_miss_num OR l_sub_obj_id = NULL ) THEN
              FND_MESSAGE.set_name('CSI','CSI_TXN_INVALID_TXN_DTL_REF');
              FND_MESSAGE.set_token('SUBJECT_ID',l_sub_obj_id);
              FND_MESSAGE.set_token('OBJECT_ID', NULL);
              FND_MSG_PUB.add;
              RAISE FND_API.g_exc_error;
          END IF;
            -- get the corresponding ii_rltns (where subject_id = line detail index / id)

                get_iir_details(
                  p_sub_obj_id       => l_sub_obj_id,
                  p_object_yn        => l_object_yn,
                  p_iir_tbl          => p_txn_ii_rltns_tbl,
                  x_src_dtl_count    => l_src_dtl_count,
                  x_return_status    => l_return_status,
                  x_iir_tbl          => l_iir_tbl); -- first call to see if the TLD was ref. as a subject in the rltns.

           IF l_iir_tbl.COUNT = 0 AND l_object_yn = 'N' THEN
              l_object_yn := 'Y';

                get_iir_details(
                  p_sub_obj_id       => l_sub_obj_id,
                  p_object_yn        => l_object_yn,
                  p_iir_tbl          => p_txn_ii_rltns_tbl,
                  x_src_dtl_count    => l_src_dtl_count,
                  x_return_status    => l_return_status,
                  x_iir_tbl          => l_iir_tbl); -- Second call to see if it's ref. as a object

           END IF;
           IF l_line_dtl_tbl(l_td_ind).source_transaction_flag = 'N' THEN
            IF l_src_dtl_count = 0 THEN

              FND_MESSAGE.set_name('CSI','CSI_TXN_NON_SRC_AND_NO_RLTN');
              FND_MESSAGE.set_token('INDEX',l_sub_obj_id);
              FND_MESSAGE.set_token('ITEM_ID',
                                 l_line_dtl_tbl(l_td_ind).inventory_item_id);
              FND_MSG_PUB.add;
              RAISE FND_API.g_exc_error;
            END IF;
           END IF; -- source flag chk = 'N'

            IF l_iir_tbl.COUNT > 1 THEN
             IF l_return_status <> fnd_api.g_ret_sts_success THEN -- status set to error in the get iir routine when Multiple comp - of relationships are found for a given TLD
              FND_MESSAGE.set_name('CSI','CSI_TXN_MULTIPLE_PARENT');
              FND_MESSAGE.set_token('INDEX',l_td_ind);
              FND_MESSAGE.set_token('ITEM_ID',
                                 l_line_dtl_tbl(l_td_ind).inventory_item_id);
              FND_MSG_PUB.add;
              RAISE FND_API.g_exc_error;
             END IF;
            ELSIF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE FND_API.g_exc_error;
            END IF;

        END LOOP;
     END IF ; --- p_txn_ii_rltns_tbl.count > 0
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN

      x_return_status := fnd_api.g_ret_sts_error;

  END check_rltns_integrity;


  PROCEDURE convert_rltns_index_to_ids(
    p_line_dtl_tbl  IN     csi_t_datastructures_grp.txn_line_detail_tbl,
    px_ii_rltns_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status OUT NOCOPY    varchar2)
  IS
    l_line_dtl_rec   csi_t_datastructures_grp.txn_line_detail_rec;
    l_ii_rltns_tbl   csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_return_status  varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN
    IF p_line_dtl_tbl.COUNT > 0 THEN
      FOR l_td_ind IN p_line_dtl_tbl.FIRST..p_line_dtl_tbl.LAST
      LOOP
        IF px_ii_rltns_tbl.COUNT > 0 THEN
          FOR l_ii_ind IN px_ii_rltns_tbl.FIRST..px_ii_rltns_tbl.LAST
          LOOP
		/* Added the defaulting of values to the index flags for M-M */

           IF  nvl(px_ii_rltns_tbl(l_ii_ind).subject_index_flag,fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
			px_ii_rltns_tbl(l_ii_ind).subject_index_flag := 'Y';
		 END IF;

           IF  nvl(px_ii_rltns_tbl(l_ii_ind).object_index_flag,fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
			px_ii_rltns_tbl(l_ii_ind).object_index_flag := 'Y';
		 END IF;

           IF  px_ii_rltns_tbl(l_ii_ind).subject_type = 'T'
           ---m-to-m 05/10
           AND  nvl(px_ii_rltns_tbl(l_ii_ind).subject_index_flag,'Y') = 'Y'
           THEN
            csi_t_vldn_routines_pvt.get_txn_line_dtl_rec(
              p_index_id            => px_ii_rltns_tbl(l_ii_ind).subject_id,
              p_txn_line_detail_tbl => p_line_dtl_tbl,
              x_txn_line_detail_rec => l_line_dtl_rec,
              x_return_status       => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              FND_MESSAGE.set_name('CSI','CSI_TXN_SUBJECT_INDEX_INVALID');
              FND_MESSAGE.set_token('INDEX_ID',px_ii_rltns_tbl(l_ii_ind).
                                                   subject_id);
              FND_MSG_PUB.add;
              RAISE FND_API.g_exc_error;
            END IF;

            l_ii_rltns_tbl(l_ii_ind).subject_id :=
               l_line_dtl_rec.txn_line_detail_id;
           END IF;

           IF  px_ii_rltns_tbl(l_ii_ind).object_type = 'T'
           ---m-to-m 05/10
           AND  nvl(px_ii_rltns_tbl(l_ii_ind).object_index_flag,'Y') = 'Y'
           THEN

            csi_t_vldn_routines_pvt.get_txn_line_dtl_rec(
              p_index_id            => px_ii_rltns_tbl(l_ii_ind).object_id,
              p_txn_line_detail_tbl => p_line_dtl_tbl,
              x_txn_line_detail_rec => l_line_dtl_rec,
              x_return_status       => l_return_status);


            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              FND_MESSAGE.set_name('CSI','CSI_TXN_OBJECT_INDEX_INVALID');
              FND_MESSAGE.set_token('INDEX_ID',px_ii_rltns_tbl(l_ii_ind).
                                                   object_id);
              FND_MSG_PUB.add;
              RAISE FND_API.g_exc_error;
            END IF;

            l_ii_rltns_tbl(l_ii_ind).object_id :=
               l_line_dtl_rec.txn_line_detail_id;
           END IF;

           l_ii_rltns_tbl(l_ii_ind).transaction_line_id :=
              p_line_dtl_tbl(l_td_ind).transaction_line_id;

          END LOOP;

        END IF;
      END LOOP;

      IF px_ii_rltns_tbl.count > 0 THEN
        FOR l_tmp_ind in px_ii_rltns_tbl.FIRST..px_ii_rltns_tbl.LAST
        LOOP
         IF px_ii_rltns_tbl(l_tmp_ind).object_type = 'T'
         ---m-to-m 05/10
         AND  nvl(px_ii_rltns_tbl(l_tmp_ind).object_index_flag,'Y') = 'Y'
         THEN
          px_ii_rltns_tbl(l_tmp_ind).object_id :=
            l_ii_rltns_tbl(l_tmp_ind).object_id;
         END IF;

         IF px_ii_rltns_tbl(l_tmp_ind).subject_type = 'T'
         ---m-to-m 05/10
         AND  nvl(px_ii_rltns_tbl(l_tmp_ind).subject_index_flag,'Y') = 'Y'
         THEN
          px_ii_rltns_tbl(l_tmp_ind).subject_id :=
            l_ii_rltns_tbl(l_tmp_ind).subject_id;
         END IF;

          px_ii_rltns_tbl(l_tmp_ind).transaction_line_id :=
            l_ii_rltns_tbl(l_tmp_ind).transaction_line_id;

        END LOOP;
      END IF;

    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END convert_rltns_index_to_ids;


  PROCEDURE is_valid_owner_for_create(
    p_txn_line_detail_id     IN  NUMBER,
    p_instance_party_id      IN  NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2)
  IS

    l_found                VARCHAR2(1);
    l_instance_exists_flag csi_t_txn_line_details.instance_exists_flag%TYPE;
    l_csi_instance_id      csi_t_party_details.instance_party_id%TYPE;

    CURSOR csi_pty_cur(p_csi_instance_id IN NUMBER) IS
      SELECT instance_party_id
      FROM   csi_i_parties
      WHERE  instance_id = p_csi_instance_id
      AND    relationship_type_code = 'OWNER';

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    SELECT instance_exists_flag,
           instance_id
    INTO   l_instance_exists_flag,
           l_csi_instance_id
    FROM   csi_t_txn_line_details
    WHERE  txn_line_detail_id = p_txn_line_detail_id;

    /* if an instance is referred, then look if the instance party is referred
       if the instance party is referred then skip the chk.
    */
    IF NVL(l_instance_exists_flag,'N') = 'Y' THEN

      IF nvl(p_instance_party_id ,fnd_api.g_miss_num) = fnd_api.g_miss_num
      THEN

        FOR csi_pty_rec in csi_pty_cur(l_csi_instance_id)
        LOOP
          x_return_status := fnd_api.g_ret_sts_error;
          exit;
        END LOOP;

      /* we might have to put the logic if the caller is trying to change the
         relationship type code from NON OWNER to OWNER (in the else part)
      */

      END IF;

    ELSE

      BEGIN

        SELECT 'x' INTO l_found
        FROM   csi_t_party_details
        WHERE  txn_line_detail_id = p_txn_line_detail_id
        AND    relationship_type_code = 'OWNER';

        x_return_status := fnd_api.g_ret_sts_error;

      EXCEPTION
        WHEN no_data_found THEN
          x_return_status := fnd_api.g_ret_sts_success;

      END;

    END IF;
  END is_valid_owner_for_create;

  procedure get_txn_line_dtl_rec(
    p_index_id            IN  NUMBER,
    p_txn_line_detail_tbl IN  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_line_detail_rec OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    x_return_status       OUT NOCOPY VARCHAR2)
  IS
    l_found BOOLEAN := FALSE;
--    l_line_dtl_rec    csi_t_datastructures_grp.txn_line_detail_rec;
  BEGIN

    IF p_txn_line_detail_tbl.COUNT > 0 THEN

      FOR l_ind in p_txn_line_detail_tbl.FIRST .. p_txn_line_detail_tbl.LAST
      LOOP

	IF l_ind = p_index_id OR
	   p_txn_line_detail_tbl(l_ind).txn_line_detail_id = p_index_id THEN
          l_found := TRUE;
          x_txn_line_detail_rec := p_txn_line_detail_tbl(l_ind);
          exit;
        END IF;
      END LOOP;

    END IF;

    IF l_found THEN
      x_return_status := fnd_api.g_ret_sts_success;
    ELSE
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

  END get_txn_line_dtl_rec;


  PROCEDURE get_processing_status(
    p_level              IN  varchar2,
    p_level_dtl_id       IN  number,
    x_processing_status  OUT NOCOPY varchar2,
    x_return_status      OUT NOCOPY varchar2)
  IS

    l_txn_line_dtl_id      csi_t_txn_line_details.txn_line_detail_id%TYPE;
    l_transaction_line_id  csi_t_transaction_lines.transaction_line_id%TYPE;
    l_processing_status    csi_t_transaction_lines.processing_status%TYPE;

  BEGIN

    IF p_level in ('PARTY', 'II_RLTNS', 'EXT_ATTRIB', 'ORG_ASSGN') THEN

      l_txn_line_dtl_id := p_level_dtl_id;

    ELSIF p_level = 'PARTY_ACCT' THEN

      SELECT txn_line_detail_id
      INTO   l_txn_line_dtl_id
      FROM   csi_t_party_details
      WHERE  txn_party_detail_id = p_level_dtl_id;

    END IF;

    SELECT transaction_line_id
    INTO   l_transaction_line_id
    FROM   csi_t_txn_line_details
    WHERE  txn_line_detail_id = l_txn_line_dtl_id;

    SELECT nvl(processing_status, '#NONE#')
    INTO   l_processing_status
    FROM   csi_t_transaction_lines
    WHERE  transaction_line_id = l_transaction_line_id;

    x_processing_status := l_processing_status;
    x_return_status     := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END get_processing_status ;

  PROCEDURE validate_attrib_source_id(
    p_attrib_source_table IN  varchar2,
    p_attrib_source_id    IN  number,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_found               varchar2(1);

  BEGIN

    IF p_attrib_source_table = 'CSI_I_EXTENDED_ATTRIBS' THEN

      SELECT 'X'
      INTO   l_found
      FROM   csi_i_extended_attribs
      WHERE  attribute_id = p_attrib_source_id;

    ELSIF p_attrib_source_table = 'CSI_IEA_VALUES' THEN

      SELECT 'X'
      INTO   l_found
      FROM   csi_iea_values
      WHERE  attribute_value_id = p_attrib_source_id;

    ELSE

      FND_MESSAGE.set_name('CSI','CSI_TXN_ATT_SRC_TBL_INVALID');
      FND_MESSAGE.set_token('ATT_SRC_TBL',p_attrib_source_table);
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;

    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN no_data_found THEN

      FND_MESSAGE.set_name('CSI','CSI_TXN_ATT_SRC_ID_INVALID');
      FND_MESSAGE.set_token('ATT_SRC_TBL',p_attrib_source_table);
      FND_MESSAGE.set_token('ATT_SRC_ID',p_attrib_source_id);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_error;

    WHEN fnd_api.g_exc_error THEN

      x_return_status := fnd_api.g_ret_sts_error;

  END validate_attrib_source_id;

  PROCEDURE validate_party_account_id(
    p_party_id          IN  NUMBER,
    p_party_account_id  IN  NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2)
  IS
    l_found varchar2(1);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    SELECT 'X'
    INTO   l_found
    FROM   hz_cust_accounts
    WHERE  party_id = p_party_id
    AND    cust_account_id = p_party_account_id;

  EXCEPTION
    WHEN no_data_found THEN

      x_return_status := fnd_api.g_ret_sts_error;

  END validate_party_account_id;

  PROCEDURE get_instance_ref_info(
    p_level                IN  varchar2,
    p_level_dtl_id         IN  number,
    x_instance_id          OUT NOCOPY varchar2,
    x_instance_exists_flag OUT NOCOPY varchar2,
    x_return_status        OUT NOCOPY varchar2)
  IS

    l_txn_line_dtl_id      csi_t_txn_line_details.txn_line_detail_id%TYPE;

  BEGIN

    IF p_level in ('PARTY', 'II_RLTNS', 'EXT_ATTRIB', 'ORG_ASSGN') THEN

      l_txn_line_dtl_id := p_level_dtl_id;

    ELSIF p_level = 'PARTY_ACCT' THEN

      SELECT txn_line_detail_id
      INTO   l_txn_line_dtl_id
      FROM   csi_t_party_details
      WHERE  txn_party_detail_id = p_level_dtl_id;

    END IF;

    SELECT instance_id ,
           instance_exists_flag
    INTO   x_instance_id,
           x_instance_exists_flag
    FROM   csi_t_txn_line_details
    WHERE  txn_line_detail_id = l_txn_line_dtl_id;

    x_return_status     := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END get_instance_ref_info;

  PROCEDURE get_party_detail_rec(
    p_party_detail_id   IN  number,
    x_party_detail_rec  OUT NOCOPY csi_t_party_details%rowtype,
    x_return_status    OUT NOCOPY varchar2)
  IS
  BEGIN

    SELECT *
    INTO   x_party_detail_rec
    FROM   csi_t_party_details
    WHERE  txn_party_detail_id = p_party_detail_id;

    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_party_detail_rec;


  PROCEDURE validate_instance_id(
    p_instance_id   IN  number,
    x_return_status OUT NOCOPY varchar2)
  IS
   l_found    VARCHAR2(1);
  BEGIN

    SELECT 'X'
    INTO   l_found
    FROM   csi_item_instances
    WHERE  instance_id = p_instance_id;
    -- AND unexpired condition

    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;

  END validate_instance_id;

  procedure validate_instance_reference(
    p_level              IN  varchar2,
    p_level_dtl_id       IN  number,
    p_level_inst_ref_id  IN  number,
    x_return_status      OUT NOCOPY varchar2)
  IS
    l_instance_id          csi_t_txn_line_details.instance_id%TYPE;
    l_instance_exists_flag csi_t_txn_line_details.instance_exists_flag%TYPE;
    l_return_status        varchar2(1) := fnd_api.g_ret_sts_success;

    l_td_object_id         number;
    l_inst_object_id       number;
  BEGIN

    get_instance_ref_info(
      p_level                => p_level,
      p_level_dtl_id         => p_level_dtl_id,
      x_instance_id          => l_instance_id,
      x_instance_exists_flag => l_instance_exists_flag,
      x_return_status        => l_return_status);

    IF l_return_status = fnd_api.g_ret_sts_success THEN

      --IF nvl(l_instance_exists_flag,'N') <> 'Y' THEN
      IF l_instance_id is null THEN -- instance is not refernced

        IF p_level <> 'II_RLTNS' THEN
          --instance reference not allowed
          fnd_message.set_name('CSI','CSI_TXN_INST_REF_NOT_ALLOWED');
          fnd_message.set_token('LVL',p_level);
          fnd_message.set_token('LVL_DTL_ID',p_level_inst_ref_id);
          fnd_msg_pub.add;

          raise fnd_api.g_exc_error;
        END IF;

      END IF;

        IF p_level = 'PARTY' THEN

          validate_instance_party_id(
            p_instance_id       => l_instance_id,
            p_instance_party_id => p_level_inst_ref_id,
            x_return_status     => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN

            fnd_message.set_name('CSI','CSI_TXN_INST_PARTY_REF_INVALID');
            fnd_message.set_token('INST_ID',l_instance_id);
            fnd_message.set_token('INST_PTY_ID',p_level_inst_ref_id);
            fnd_msg_pub.add;

            RAISE fnd_api.g_exc_error;
          END IF;

        ELSIF p_level = 'ORG_ASSGN' THEN

          validate_instance_ou_id(
            p_instance_id        => l_instance_id,
            p_instance_ou_id     => p_level_inst_ref_id,
            x_return_status      => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            fnd_message.set_name('CSI','CSI_TXN_INST_OU_REF_INVALID');
            fnd_message.set_token('INST_ID',l_instance_id);
            fnd_message.set_token('INST_OU_ID',p_level_inst_ref_id);
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
          END IF;

        ELSIF p_level = 'ORG_ATTRIB' THEN
          null;
        ELSIF p_level = 'II_RLTNS' THEN

          -- in IB
          -- get the object id(instance) for the instance_relationship_id

          -- in TD
          -- get the instance reference for the object_id(txn_line_detail_id)
          -- compare both the instances

          -- if both are not same then raise exception

          IF nvl(l_instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

            l_td_object_id := l_instance_id;

            validate_instance_rltns_id(
              p_csi_inst_rltns_id => p_level_inst_ref_id,
              x_object_id         => l_inst_object_id,
              x_return_status     => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              null;
              -- invalid csi_inst_relation_id
              RAISE fnd_api.g_exc_error;
            END IF;

            IF l_td_object_id <> l_inst_object_id THEN
              null;
              -- cannot change the parent (object id) in IB
              RAISE fnd_api.g_exc_error;

            END IF;

          END IF;

        END IF;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_instance_reference;

  PROCEDURE validate_account_id(
    p_account_id    in  number,
    x_return_status OUT NOCOPY varchar2)
  IS
    l_found varchar2(1);
  BEGIN

    SELECT 'X' INTO l_found
    FROM   hz_cust_accounts
    WHERE  cust_account_id = p_account_id;

    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    when no_data_found then
      x_return_status := fnd_api.g_ret_sts_error;

  END validate_account_id;

  PROCEDURE validate_site_use_id(
    p_account_id      IN  number,
    p_site_use_id     IN  number,
    p_site_use_code   IN  varchar2,
    x_return_status   OUT NOCOPY varchar2)
  IS

    CURSOR site_cur IS
      SELECT csu.site_use_id
      FROM   hz_cust_site_uses_all csu
      WHERE  csu.site_use_id       = p_site_use_id
      AND    csu.site_use_code     = p_site_use_code;

    /* BUG # 2159414
    CURSOR site_cur IS
      SELECT csu.site_use_id
      FROM   hz_cust_site_uses_all csu ,
             hz_cust_acct_sites_all cas
      WHERE  csu.site_use_id       = p_site_use_id
      AND    csu.site_use_code     = p_site_use_code
      AND    csu.cust_acct_site_id = cas.cust_acct_site_id
      AND    cas.cust_account_id   = p_account_id;
    */

    l_found BOOLEAN;

  BEGIN
    l_found := FALSE;

    FOR site_rec in site_cur
    LOOP
      l_found := TRUE;
      exit;
    END LOOP;

    IF l_found THEN
      x_return_status := fnd_api.g_ret_sts_success;
    ELSE
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

  END validate_site_use_id;

  PROCEDURE get_txn_system_id(
    p_txn_systems_index  IN  number,
    p_txn_systems_tbl    IN  csi_t_datastructures_grp.txn_systems_tbl,
    x_txn_system_id      OUT NOCOPY number,
    x_return_status      OUT NOCOPY varchar2)
  IS
  BEGIN

    x_txn_system_id := fnd_api.g_miss_num;

    IF nvl(p_txn_systems_index,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      IF p_txn_systems_tbl.COUNT > 0 THEN
        FOR l_ind in p_txn_systems_tbl.FIRST .. p_txn_systems_tbl.LAST
        LOOP

          IF l_ind = p_txn_systems_index THEN
            x_txn_system_id := p_txn_systems_tbl(l_ind).transaction_system_id;
            exit;
          END IF;

        END LOOP;
      END IF;
    END IF;
  END get_txn_system_id;

  PROCEDURE get_txn_systems_index(
    p_txn_system_id      IN  number,
    p_txn_systems_tbl    IN  csi_t_datastructures_grp.txn_systems_tbl,
    x_txn_systems_index  OUT NOCOPY number,
    x_return_status      OUT NOCOPY varchar2)
  IS
  BEGIN

    x_txn_systems_index := fnd_api.g_miss_num;

    IF nvl(p_txn_system_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      IF p_txn_systems_tbl.COUNT > 0 THEN
        FOR l_ind in p_txn_systems_tbl.FIRST .. p_txn_systems_tbl.LAST
        LOOP

          IF p_txn_systems_tbl(l_ind).transaction_system_id = p_txn_system_id THEN
            x_txn_systems_index := l_ind;
            exit;
          END IF;

        END LOOP;
      END IF;
    END IF;

  END get_txn_systems_index;

  PROCEDURE validate_contact_flag(
   p_contact_flag in varchar2,
   x_return_status OUT NOCOPY varchar2)
  IS
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    IF p_contact_flag not in ('Y','N') THEN
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
  END validate_contact_flag;

  /* validtion routine for sub_type_id */
  PROCEDURE validate_sub_type_id(
    p_transaction_line_id IN  number,
    p_sub_type_id         IN  number,
    x_return_status       OUT NOCOPY varchar2)
  IS

    l_txn_type_id    number;

    CURSOR sub_type_cur(p_txn_type_id IN number) IS
      SELECT 'X'
      FROM   csi_txn_sub_types
      WHERE  sub_type_id         = p_sub_type_id
      AND    transaction_type_id = nvl(p_txn_type_id, transaction_type_id);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_error;

    SELECT source_transaction_type_id
    INTO   l_txn_type_id
    FROM   csi_t_transaction_lines
    WHERE  transaction_line_id = p_transaction_line_id;

    FOR sub_type_rec in sub_type_cur(l_txn_type_id)
    LOOP
      x_return_status := fnd_api.g_ret_sts_success;
      exit;
    END LOOP;


  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_sub_type_id;

  PROCEDURE check_duplicate(
    p_txn_line_rec  IN  csi_t_datastructures_grp.txn_line_rec,
    x_return_status OUT NOCOPY varchar2)
  IS
    l_td_found  char;
  BEGIN

    SELECT 'x'
    INTO   l_td_found
    FROM   csi_t_transaction_lines
    WHERE  source_transaction_table = p_txn_line_rec.source_transaction_table
    AND    source_transaction_id    = p_txn_line_rec.source_transaction_id;

    x_return_status := fnd_api.g_ret_sts_error;

  EXCEPTION
    WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_success;
  END check_duplicate;

  PROCEDURE validate_lot_number(
    p_inventory_item_id  IN  number,
    p_organization_id    IN  number,
    p_lot_number         IN  varchar2,
    x_return_status      OUT NOCOPY varchar2)
  IS
    l_lot_control_code   mtl_system_items.lot_control_code%TYPE;
    l_item_name          mtl_system_items.segment1%TYPE;
    l_found              char;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    -- check whether the item is under lot control or not...

    -- 1 - No Control
    -- 2 - Full Control

    BEGIN
      SELECT lot_control_code,
             segment1
      INTO   l_lot_control_code,
             l_item_name
      FROM   mtl_system_items
      WHERE  inventory_item_id = p_inventory_item_id
      AND    organization_id   = p_organization_id;
    EXCEPTION
      WHEN no_data_found THEN

        fnd_message.set_name('CSI','CSI_INT_ITEM_ID_MISSING');
        fnd_message.set_token('INVENTORY_ITEM_ID',p_inventory_item_id);
        fnd_message.set_token('INV_ORGANIZATION_ID',p_organization_id);
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;
    END;

    IF l_lot_control_code = 2 THEN

      BEGIN

        SELECT 'X'
        INTO   l_found
        FROM   mtl_lot_numbers
        WHERE  inventory_item_id = p_inventory_item_id
        AND    lot_number        = p_lot_number;

        -- AND    organization_id   = p_organization_id
        -- commenting this as from order management the inventory organization
        -- is not visible. Only the validation organization is passed

      EXCEPTION

        WHEN no_data_found THEN
          fnd_message.set_name('CSI','CSI_API_INVALID_LOT_NUM');
          fnd_message.set_token('LOT_NUMBER',p_lot_number);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;

        -- adding this because I took of the organization check
        WHEN too_many_rows THEN
          null;
      END;

    ELSE
      fnd_message.set_name('CSI', 'CSI_API_NOT_LOT_CONTROLLED');
      fnd_message.set_token('LOT_NUMBER', l_item_name);
      fnd_msg_pub.add;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_lot_number;

  PROCEDURE validate_serial_number(
    p_inventory_item_id  IN  number,
    p_organization_id    IN  number,
    p_serial_number      IN  varchar2,
    x_return_status      OUT NOCOPY varchar2)
  IS
    l_serial_control_code mtl_system_items.serial_number_control_code%TYPE;
    l_item_name           mtl_system_items.segment1%TYPE;
    l_found               char;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    -- check whether the item is serial controlled or not

    -- '1' No serial number control
    -- '2' Predefined serial numbers
    -- '5' Dynamic entry at inventory receipt
    -- '6' Dynamic entry at sales order issue

    BEGIN
      SELECT serial_number_control_code,
             segment1
      INTO   l_serial_control_code,
             l_item_name
      FROM   mtl_system_items
      WHERE  inventory_item_id = p_inventory_item_id
      AND    organization_id   = p_organization_id;
    EXCEPTION

      WHEN no_data_found THEN

        fnd_message.set_name('CSI','CSI_INT_ITEM_ID_MISSING');
        fnd_message.set_token('INVENTORY_ITEM_ID',p_inventory_item_id);
        fnd_message.set_token('INV_ORGANIZATION_ID',p_organization_id);
        fnd_msg_pub.add;

        RAISE fnd_api.g_exc_error;
    END;

    IF l_serial_control_code <> 1 THEN

      BEGIN

        SELECT 'X'
        INTO   l_found
        FROM   mtl_serial_numbers
        WHERE  inventory_item_id = p_inventory_item_id
        AND    serial_number     = p_serial_number;

        -- AND    current_organization_id = p_organization_id
        -- commenting this as from order management the inventory organization
        -- is not visible. Only the validation organization is passed

      EXCEPTION
        WHEN no_data_found THEN

          fnd_message.set_name('CSI','CSI_API_INVALID_SERIAL_NUM');
          fnd_message.set_token('SERIAL_NUMBER',p_serial_number);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;

        -- adding this because I took of the organization check
        WHEN too_many_rows THEN
          null;
      END;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_serial_number;

/* Added this new routine for M-M Changes */

  PROCEDURE  validate_txn_rltnshp (
                p_txn_line_detail_rec1 IN  csi_t_datastructures_grp.txn_line_detail_rec,
                p_txn_line_detail_rec2 IN  csi_t_datastructures_grp.txn_line_detail_rec,
                p_iir_rec              IN  csi_t_datastructures_grp.txn_ii_rltns_rec,
                x_return_status        OUT NOCOPY varchar2)
   IS

    l_routine_name       CONSTANT VARCHAR2(30)  := 'vldn.validate_txn_rltnshp';
    l_line_dtl_rec1   csi_t_datastructures_grp.txn_line_detail_rec;
    l_line_dtl_rec2   csi_t_datastructures_grp.txn_line_detail_rec;
    l_ii_rltns_rec    csi_t_datastructures_grp.txn_ii_rltns_rec;
    l_subject_id      NUMBER;
    l_object_id       NUMBER;
    l_object_type     VARCHAR2(30);
    l_subject_type    VARCHAR2(30);
    l_sub_obj_id      NUMBER;
    l_object_yn       VARCHAR2(1);
    l_csi_rel_id      NUMBER;
    l_rel_type        VARCHAR2(30);
    l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;


CURSOR txn_ii_rltns_cur (c_subject_id IN NUMBER,
                         c_object_id IN NUMBER ,
                         c_relationship_type_code IN VARCHAR2)
IS
SELECT txn_relationship_id , object_type, subject_type
FROM   csi_t_ii_relationships
WHERE  subject_id = c_subject_id
AND    object_id = c_object_id
AND    relationship_type_code = c_relationship_type_code
AND    NVL(active_end_date , SYSDATE) >= SYSDATE ;

l_txn_relationship_id NUMBER := NULL ;
l_sub_type	      VARCHAR2(30);
l_obj_type	      VARCHAR2(30);

            /* Validations performed :: If both sub and obj are TLD's then
                i) Sub and Obj have source flag = 'Y' , the source hdr id and source txn type ID for both must be same for connected to
                ii)One of them have source flag = 'Y' and the other has 'N' -- source txn ID and source txn type ID for both must be same i.e. they should be within the same txn line
                iii)Sub and Obj have source flag= 'N' -- not allowed
			 iv) Validate instance references
			 v) validate the relationship for bus rules if instance is involved
            */
  BEGIN
          csi_t_gen_utility_pvt.add('Begin : '||l_routine_name);
          l_line_dtl_rec1   := p_txn_line_detail_rec1;
          l_line_dtl_rec2   := p_txn_line_detail_rec2;
          l_ii_rltns_rec    := p_iir_rec;
          l_object_type     := l_ii_rltns_rec.object_type;
          l_object_id       := l_ii_rltns_rec.object_id;
          l_subject_type    := l_ii_rltns_rec.subject_type;
          l_subject_id      := l_ii_rltns_rec.subject_id;
          l_csi_rel_id      := l_ii_rltns_rec.csi_inst_relationship_id;
          l_rel_type        := l_ii_rltns_rec.relationship_type_code;
          x_return_status   := fnd_api.g_ret_sts_success ;

               IF l_line_dtl_rec1.txn_line_detail_id = fnd_api.g_miss_num  THEN
                    -- call validate_inst_details to validate it in instance context

                               validate_inst_details (
                                    p_iir_rec       => l_ii_rltns_rec,
                                    p_txn_dtl_rec   => l_line_dtl_rec2,
                                    x_return_status => l_return_status );

                                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                                  RAISE fnd_api.g_exc_error;
                                END IF;

               ELSIF l_line_dtl_rec2.txn_line_detail_id = fnd_api.g_miss_num  THEN

                               validate_inst_details (
                                    p_iir_rec       => l_ii_rltns_rec,
                                    p_txn_dtl_rec   => l_line_dtl_rec1,
                                    x_return_status => l_return_status );

                                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                                  RAISE fnd_api.g_exc_error;
                                END IF;
               ELSE
                  /* validate the source txn hdr ID */
               ---Bypass this check if the source is Configurator
               -- Added for CZ Integration
               IF (NVL(l_line_dtl_rec1.config_inst_hdr_id , fnd_api.g_miss_num)
                  = fnd_api.g_miss_num AND
                   NVL(l_line_dtl_rec2.config_inst_hdr_id , fnd_api.g_miss_num)
                  = fnd_api.g_miss_num )
               THEN
                  validate_src_header (
                          p_txn_line_id1   => l_line_dtl_rec1.transaction_line_id,
                          p_txn_line_id2   => l_line_dtl_rec2.transaction_line_id,
                          p_rel_type_code  => l_ii_rltns_rec.relationship_type_code,
                          x_return_status  => l_return_status);
                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                     FND_MESSAGE.set_name('CSI','CSI_TXN_INVALID_TXN_REL');
                     FND_MESSAGE.set_token('TXN_DTL_ID1', l_line_dtl_rec1.txn_line_detail_id);
                     FND_MESSAGE.set_token('TXN_DTL_ID2', l_line_dtl_rec2.txn_line_detail_id);
                     FND_MSG_PUB.add;
                     RAISE fnd_api.g_exc_error;
                  END IF;
                 END IF ;

                  IF ( l_line_dtl_rec1.transaction_line_id = l_line_dtl_rec2.transaction_line_id )
                    AND l_ii_rltns_rec.relationship_type_code <> 'CONNECTED-TO' THEN
                        IF  l_line_dtl_rec1.source_transaction_flag = l_line_dtl_rec2.source_transaction_flag THEN
                             FND_MESSAGE.set_name('CSI','CSI_TXN_INVALID_TXN_REL');
                             FND_MESSAGE.set_token('TXN_DTL_ID1', l_line_dtl_rec1.txn_line_detail_id);
                             FND_MESSAGE.set_token('TXN_DTL_ID2', l_line_dtl_rec2.txn_line_detail_id);
                             FND_MSG_PUB.add;
                             RAISE fnd_api.g_exc_error;
                        END IF;
                  END IF;

               END IF;

               l_txn_relationship_id := NULL ;
               OPEN txn_ii_rltns_cur (l_ii_rltns_rec.subject_id,
               		l_ii_rltns_rec.object_id,
                        l_ii_rltns_rec.relationship_type_code) ;

               FETCH txn_ii_rltns_cur INTO l_txn_relationship_id ,
					   l_obj_type,
					   l_sub_type;
               CLOSE txn_ii_rltns_cur ;
	       IF nvl(l_ii_rltns_rec.txn_relationship_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
	        IF ( l_ii_rltns_rec.object_type = l_obj_type
                 AND l_ii_rltns_rec.subject_type = l_sub_type) THEN
                   IF l_txn_relationship_id IS NOT NULL
		    AND l_ii_rltns_rec.txn_relationship_id <> l_txn_relationship_id
                   THEN
                         FND_MESSAGE.set_name('CSI','CSI_TXN_DUP_RLTNS');
                         FND_MSG_PUB.add;
                         RAISE fnd_api.g_exc_error;
                   END IF ;
	        END IF;
	       END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_txn_rltnshp ;

/* Added new routine for M-M Changes */

  PROCEDURE validate_inst_details (
    p_iir_rec       IN csi_t_datastructures_grp.txn_ii_rltns_rec,
    p_txn_dtl_rec   IN csi_t_datastructures_grp.txn_line_detail_rec,
    x_return_status OUT NOCOPY varchar2)

   IS
    l_routine_name       CONSTANT VARCHAR2(30)  := 'vldn.validate_inst_details';
    l_line_dtl_rec    csi_t_datastructures_grp.txn_line_detail_rec;
    l_txn_rltns_rec   csi_t_datastructures_grp.txn_ii_rltns_rec;
    l_iir_rec         csi_ii_relationships%rowtype;
    l_subject_id      NUMBER;
    l_object_id       NUMBER;
    l_object_type     VARCHAR2(30);
    l_subject_type    VARCHAR2(30);
    l_csi_rel_id      NUMBER;
    l_rel_type        VARCHAR2(30);
    l_active_end_date DATE;
    l_instance_id     NUMBER;
    l_found           VARCHAR2(1) := 'N';
    l_loc_type        VARCHAR2(30);

    BEGIN
          csi_t_gen_utility_pvt.add('Begin : '||l_routine_name);
          l_line_dtl_rec    := p_txn_dtl_rec;
          l_txn_rltns_rec   := p_iir_rec;
          l_object_type     := l_txn_rltns_rec.object_type;
          l_object_id       := l_txn_rltns_rec.object_id;
          l_subject_type    := l_txn_rltns_rec.subject_type;
          l_subject_id      := l_txn_rltns_rec.subject_id;
          l_csi_rel_id      := l_txn_rltns_rec.csi_inst_relationship_id;
          l_rel_type        := l_txn_rltns_rec.relationship_type_code;
          x_return_status   := fnd_api.g_ret_sts_success ;

      IF l_txn_rltns_rec.subject_type = 'I' THEN
         l_instance_id := l_subject_id;
      ELSIF l_txn_rltns_rec.object_type = 'I' THEN
         l_instance_id := l_object_id;
      ELSE
         l_instance_id := fnd_api.g_miss_num;
      END IF;
      IF l_txn_rltns_rec.csi_inst_relationship_id = NULL THEN
         l_csi_rel_id := fnd_api.g_miss_num;
      END IF;
      IF l_txn_rltns_rec.active_end_date = NULL THEN
         l_active_end_date := fnd_api.g_miss_date;
      END IF;

      IF l_csi_rel_id <> fnd_api.g_miss_num  THEN

         BEGIN

            SELECT subject_id,
                   object_id,
                   relationship_type_code
            INTO   l_iir_rec.subject_id,
                   l_iir_rec.object_id,
                   l_iir_rec.relationship_type_code
            FROM   csi_ii_relationships
            WHERE  relationship_id = l_csi_rel_id
             AND sysdate between nvl(active_start_date, sysdate) and nvl(active_end_date,sysdate);
         EXCEPTION
            WHEN no_data_found THEN
              x_return_status := fnd_api.g_ret_sts_error;
         END ;
         IF l_iir_rec.relationship_type_code = 'COMPONENT-OF' THEN
            IF l_iir_rec.object_id <> l_object_id THEN
                FND_MESSAGE.set_name('CSI','CSI_TXN_INVALID_OPERATION');
                FND_MESSAGE.set_token('SUBJECT_ID', l_subject_id);
                FND_MESSAGE.set_token('OBJECT_ID' , l_object_id);
                FND_MSG_PUB.add;
                x_return_status := fnd_api.g_ret_sts_error; -- cannot swap parent in IB
            ELSIF (( l_iir_rec.subject_id <> l_subject_id ) OR
                   ( l_line_dtl_rec.instance_id <> l_subject_id) OR
                   ( l_active_end_date <> fnd_api.g_miss_date) ) THEN
                 BEGIN

                    SELECT location_type_code
                    INTO   l_loc_type
                    FROM   csi_item_instances
                    WHERE  instance_id = l_iir_rec.subject_id -- either one should not be in Inventory
                     AND sysdate between nvl(active_start_date, sysdate) and nvl(active_end_date,sysdate);
                  EXCEPTION
                    WHEN OTHERS THEN
                      x_return_status := fnd_api.g_ret_sts_error; -- unexpected error
                  END;
                  IF l_loc_type = 'INVENTORY' THEN
                      FND_MESSAGE.set_name('CSI','CSI_TXN_INVALID_OPERATION');
                      FND_MESSAGE.set_token('SUBJECT_ID', l_subject_id);
                      FND_MESSAGE.set_token('OBJECT_ID' , l_object_id);
                      FND_MSG_PUB.add;
                      x_return_status := fnd_api.g_ret_sts_error; -- this txn is not allowed when in Inventory
                  END IF;
             END IF;
         END IF;
      ELSIF l_instance_id <> fnd_api.g_miss_num THEN

         BEGIN

            SELECT 'Y'
            INTO   l_found
            FROM   csi_item_instances
            WHERE  instance_id = l_instance_id
             AND sysdate between nvl(active_start_date, sysdate) and nvl(active_end_date,sysdate);
          EXCEPTION
            WHEN no_data_found THEN
              FND_MESSAGE.set_name('CSI','CSI_TXN_INVALID_INST_REF');
              FND_MESSAGE.set_token('INSTANCE_ID', l_instance_id);
              FND_MSG_PUB.add;
              x_return_status := fnd_api.g_ret_sts_error;
          END;

          BEGIN
            SELECT 'Y'
            INTO l_found
            FROM CSI_II_RELATIONSHIPS
            WHERE relationship_type_code = 'COMPONENT-OF'
            AND subject_id = l_instance_id;
          EXCEPTION
            WHEN no_data_found THEN
               l_found := 'N';
          END;

          IF l_found = 'Y' THEN
            IF l_rel_type = 'COMPONENT-OF' THEN
              x_return_status := fnd_api.g_ret_sts_error; -- Multiple parents not allowed for 'COMPONENT-OF'
            END IF;
          END IF;
      END IF; -- l_csi_rel_id <> g_miss / null
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_inst_details;

/* Added new routine for M-M Changes */

  PROCEDURE validate_src_header (
    p_txn_line_id1       IN  NUMBER,
    p_txn_line_id2       IN  NUMBER,
    p_rel_type_code      IN  varchar2,
    x_return_status      OUT NOCOPY varchar2)

   IS

    l_routine_name       CONSTANT VARCHAR2(30)  := 'vldn.validate_src_header';
    l_txn_hdr_id1       NUMBER;
    l_txn_type_id1      NUMBER;
    l_txn_hdr_id2       NUMBER;
    l_txn_type_id2      NUMBER;
    l_query             varchar2(200);
    l_txn_line_rec      csi_t_transaction_lines%rowtype;

    BEGIN

       csi_t_gen_utility_pvt.add('Begin : '||l_routine_name);
       x_return_status   := fnd_api.g_ret_sts_success ;
       l_query := 'Select source_txn_header_id, source_transaction_type_id '||
                        'from csi_t_transaction_lines where transaction_line_id = :line_id';
        EXECUTE IMMEDIATE l_query
        INTO l_txn_hdr_id1 , l_txn_type_id1
        USING p_txn_line_id1;

        EXECUTE IMMEDIATE l_query
        INTO l_txn_hdr_id2 , l_txn_type_id2
        USING p_txn_line_id2;

      csi_t_gen_utility_pvt.add('In Validate_src_header :'||'header id1'||l_txn_hdr_id1||'header id2'||l_txn_hdr_id2||'relationship type'||p_rel_type_code);

       IF l_txn_hdr_id1 is NULL THEN
          l_txn_hdr_id1  := fnd_api.g_miss_num;
       END IF;
       IF l_txn_hdr_id2 is NULL THEN
          l_txn_hdr_id2  := fnd_api.g_miss_num;
       END IF;
       IF ( p_rel_type_code = 'CONNECTED-TO' AND
            (l_txn_hdr_id1 = fnd_api.g_miss_num OR l_txn_hdr_id2 = fnd_api.g_miss_num) ) THEN
           FND_MESSAGE.set_name('CSI','CSI_TXN_SRC_HDR_ID_REQD');
           FND_MESSAGE.set_token('TXN_LINE_ID1',p_txn_line_id1);
           FND_MESSAGE.set_token('TXN_LINE_ID2',p_txn_line_id2);
           FND_MSG_PUB.add;
           Raise fnd_api.g_exc_error;
       END IF;

       IF ((l_txn_hdr_id1 <> l_txn_hdr_id2 ) AND (l_txn_type_id1 = l_txn_type_id2) ) THEN
            FND_MESSAGE.set_name('CSI','CSI_TXN_RLT_XSO_NOT_ALLOWED');
            FND_MSG_PUB.add;
            Raise fnd_api.g_exc_error;
       END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END validate_src_header;

-- Added for CZ Integration (Begin)
PROCEDURE check_exists_in_cz(
     p_txn_line_dtl_tbl  IN  csi_t_datastructures_grp.txn_line_detail_tbl ,
     x_return_status     OUT NOCOPY VARCHAR2 )
IS
l_config_hdr_id  NUMBER ;
l_td_rec  csi_t_datastructures_grp.txn_line_detail_rec ;

CURSOR cz_config_dtl_cur (c_config_inst_hdr_id IN NUMBER ,
                          c_config_inst_rev_num IN NUMBER ,
                          c_config_inst_item_id IN NUMBER )
IS
SELECT instance_hdr_id
FROM   cz_config_items_v
WHERE  instance_hdr_id = c_config_inst_hdr_id
AND    instance_rev_nbr = c_config_inst_rev_num
AND    config_item_id = c_config_inst_item_id ;
BEGIN

  x_return_status := fnd_api.g_ret_sts_success;

  IF p_txn_line_dtl_tbl.COUNT > 0
  THEN
     FOR i IN p_txn_line_dtl_tbl.FIRST .. p_txn_line_dtl_tbl.LAST
     LOOP
     l_config_hdr_id := NULL ;
	l_td_rec := p_txn_line_dtl_tbl(i);

     OPEN cz_config_dtl_cur (l_td_rec.config_inst_hdr_id,
                             l_td_rec.config_inst_rev_num,
                             l_td_rec.config_inst_item_id ) ;
     FETCH cz_config_dtl_cur INTO l_config_hdr_id ;
     CLOSE cz_config_dtl_cur ;

     IF l_config_hdr_id is NULL
     THEN
        fnd_message.set_name('CSI','CSI_TXN_CZ_INVALID_INST_KEY');
        fnd_message.set_token('INST_HDR_ID',l_td_rec.config_inst_hdr_id);
        fnd_message.set_token('INST_REV_NBR',l_td_rec.config_inst_rev_num);
        fnd_message.set_token('CONFIG_ITEM_ID',l_td_rec.config_inst_item_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
     END IF ;
     END LOOP ;
  END IF ; ---p_txn_line_dtl_tbl.COUNT
EXCEPTION
WHEN fnd_api.g_exc_error
THEN
   x_return_status := fnd_api.g_ret_sts_error;
WHEN OTHERS
THEN
   x_return_status := fnd_api.g_ret_sts_error ;
END check_exists_in_cz ;


PROCEDURE get_cz_inst_or_tld_id (
       p_config_inst_hdr_id       IN NUMBER ,
       p_config_inst_rev_num      IN NUMBER ,
       p_config_inst_item_id      IN NUMBER ,
       x_instance_id              OUT NOCOPY NUMBER ,
       x_txn_line_detail_id       OUT NOCOPY NUMBER ,
       x_return_status            OUT NOCOPY VARCHAR2)
IS
l_sysdate DATE ;
CURSOR get_inst_id_cur (c_sysdate IN DATE)
IS
SELECT instance_id
FROM   csi_item_instances
WHERE  config_inst_hdr_id = p_config_inst_hdr_id
AND    config_inst_rev_num = p_config_inst_rev_num
AND    config_inst_item_id = p_config_inst_item_id
AND    trunc(active_start_date) <= c_sysdate
AND    ( trunc(active_end_date) > c_sysdate OR
          active_end_date is NULL) ;

CURSOR get_tld_id_cur
IS
SELECT txn_line_detail_id
FROM   csi_t_txn_line_details
WHERE  config_inst_hdr_id = p_config_inst_hdr_id
AND    config_inst_rev_num = p_config_inst_rev_num
AND    config_inst_item_id = p_config_inst_item_id  ;

BEGIN
 csi_t_gen_utility_pvt.add('Begin : in get_cz_inst_or_tld_id  ');
 csi_t_gen_utility_pvt.add('p_config_inst_hdr_id :'||p_config_inst_hdr_id
||' p_config_inst_rev_num :'|| p_config_inst_rev_num ||
' p_config_inst_item_id :'|| p_config_inst_item_id);

x_return_status := fnd_api.g_ret_sts_success ;
x_instance_id := NULL ;
x_txn_line_detail_id := NULL ;

--SELECT TRUNC(sysdate) INTO l_sysdate from dual ;
OPEN get_inst_id_cur (l_sysdate) ;
FETCH get_inst_id_cur INTO x_instance_id ;
CLOSE get_inst_id_cur ;

IF x_instance_id IS NULL
THEN
  OPEN get_tld_id_cur ;
  FETCH get_tld_id_cur INTO x_txn_line_detail_id ;
  CLOSE get_tld_id_cur ;
END IF ;

IF x_instance_id IS NULL
AND x_txn_line_detail_id IS NULL
THEN
   fnd_message.set_name('CSI','CSI_TXN_CZ_INVALID_DATA');
   fnd_message.set_token('INST_HDR_ID',p_config_inst_hdr_id);
   fnd_message.set_token('INST_REV_NBR',p_config_inst_rev_num);
   fnd_message.set_token('CONFIG_ITEM_ID',p_config_inst_item_id);
   fnd_msg_pub.add;
   RAISE fnd_api.g_exc_error;
END IF ;

EXCEPTION
WHEN fnd_api.g_exc_error
THEN
   x_return_status := fnd_api.g_ret_sts_error ;
WHEN OTHERS
THEN
   x_return_status := fnd_api.g_ret_sts_error ;
END get_cz_inst_or_tld_id ;


PROCEDURE get_cz_txn_line_id (
       p_config_session_hdr_id       IN NUMBER ,
       p_config_session_rev_num      IN NUMBER ,
       p_config_session_item_id      IN NUMBER ,
       x_txn_line_id               OUT NOCOPY NUMBER ,
       x_return_status            OUT NOCOPY VARCHAR2)
IS
CURSOR cz_txn_line_cur
  IS
  SELECT a.transaction_line_id
  FROM   csi_t_transaction_lines a
  WHERE  a.config_session_hdr_id = p_config_session_hdr_id
  AND    a.config_session_rev_num = p_config_session_rev_num
  AND    a.config_session_item_id = p_config_session_item_id
  AND    a.source_transaction_table = 'CONFIGURATOR'; --fix for bug 5632296

BEGIN
 csi_t_gen_utility_pvt.add('Begin : in get_cz_txn_line_id  ');
x_txn_line_id := NULL ;
x_return_status := fnd_api.g_ret_sts_success ;

OPEN cz_txn_line_cur ;
FETCH cz_txn_line_cur INTO x_txn_line_id ;
CLOSE cz_txn_line_cur ;
 csi_t_gen_utility_pvt.add('x_txn_line_id :'|| x_txn_line_id);

EXCEPTION
WHEN OTHERS
THEN
   x_return_status := fnd_api.g_ret_sts_error ;
END get_cz_txn_line_id;


PROCEDURE check_cz_session_keys (
       p_config_session_hdr_id IN NUMBER ,
       p_config_session_rev_num IN NUMBER ,
       p_config_session_item_id IN NUMBER ,
       x_return_status          OUT NOCOPY VARCHAR2)
IS
l_config_session_hdr_id NUMBER ;
CURSOR cz_config_cur
IS
SELECT config_hdr_id
FROM   cz_config_items_v
WHERE  config_hdr_id = p_config_session_hdr_id
AND    config_rev_nbr = p_config_session_rev_num
AND    config_item_id = p_config_session_item_id ;
BEGIN

   x_return_status   := fnd_api.g_ret_sts_success ;
   l_config_session_hdr_id := NULL ;
   OPEN cz_config_cur ;
   FETCH cz_config_cur INTO l_config_session_hdr_id;
   CLOSE cz_config_cur ;

   IF l_config_session_hdr_id is NULL
   THEN
      fnd_message.set_name('CSI','CSI_TXN_CZ_INVALID_SESSION_KEY');
      fnd_message.set_token('CONFIG_SESSION_HDR_ID',p_config_session_hdr_id);
      fnd_message.set_token('CONFIG_SESSION_REV_NUM',p_config_session_rev_num);
      fnd_message.set_token('CONFIG_SESSION_ITEM_ID',p_config_session_item_id);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF ;
EXCEPTION
WHEN fnd_api.g_exc_error
THEN
x_return_status := fnd_api.g_ret_sts_error ;
WHEN OTHERS
THEN
   x_return_status := fnd_api.g_ret_sts_error ;
END check_cz_session_keys ;


-- Added for CZ Integration (End)

END csi_t_vldn_routines_pvt;

/

--------------------------------------------------------
--  DDL for Package Body CSI_T_TXN_LINE_DTLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_T_TXN_LINE_DTLS_PVT" AS
/* $Header: csivttdb.pls 120.8.12010000.2 2008/11/27 00:02:24 anjgupta ship $*/

  g_user_id          number := fnd_global.user_id;
  g_login_id         number := fnd_global.login_id;

  /* local routine to wrap the gen utility debug stuff */

  PROCEDURE debug(
    p_message IN varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.add(p_message);
  END debug;

  PROCEDURE api_log(
    p_api_name IN varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => 'csi_t_txn_line_dtls_pvt',
      p_api_name => p_api_name);
  END api_log;

  PROCEDURE create_txn_line_dtls(
    p_api_version              IN     number,
    p_commit                   IN     varchar2 := fnd_api.g_false,
    p_init_msg_list            IN     varchar2 := fnd_api.g_false,
    p_validation_level         IN     number   := fnd_api.g_valid_level_full,
    p_txn_line_dtl_index       IN     number,
    p_txn_line_dtl_rec         IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    px_txn_party_dtl_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_pty_acct_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_ii_rltns_tbl        IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    px_txn_org_assgn_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    px_txn_ext_attrib_vals_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status               OUT NOCOPY varchar2,
    x_msg_count                   OUT NOCOPY number,
    x_msg_data                    OUT NOCOPY varchar2)

  IS

    l_api_name       CONSTANT varchar2(30)  := 'create_txn_line_dtls';
    l_api_version    CONSTANT number        := 1.0;
    l_debug_level             number;
    l_return_status           varchar2(1);
    l_msg_count               number;
    l_msg_data                varchar2(2000);

    l_txn_line_detail_id      number;
    l_uom_code                mtl_units_of_measure.uom_code%TYPE;
    l_quantity                number;
    l_processing_status       varchar2(30);
    l_preserve_detail_flag    varchar2(1);
    l_valid                   boolean     := TRUE;
    l_creation_flag           varchar2(1) := 'N';

    l_txn_party_rec           csi_t_datastructures_grp.txn_party_detail_rec;
    l_txn_ii_rltns_rec        csi_t_datastructures_grp.txn_ii_rltns_rec;
    l_txn_oa_rec              csi_t_datastructures_grp.txn_org_assgn_rec;
    l_txn_ea_rec              csi_t_datastructures_grp.txn_ext_attrib_vals_rec;

    --contact party id variables
    l_tmp_party_dtl_tbl      csi_t_datastructures_grp.txn_party_detail_tbl;
    l_contact_party_id       number;
    l_cascade_owner_flag     varchar2(1);-- bug 2972082
    l_contact_party_index    varchar2(1) := 'N';

    l_src_transaction_type_id NUMBER; -- ER 6936037

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT create_txn_line_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Standard call to check for call compatibility.
    IF NOT

       fnd_api.compatible_API_call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    -- debug messages
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    debug(p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

    IF l_debug_level > 1 then

      csi_t_gen_utility_pvt.dump_line_detail_rec(
        p_line_detail_rec => p_txn_line_dtl_rec);

    END IF;

    -- Main API code

    -- check for required parameters

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value       => p_txn_line_dtl_rec.sub_type_id,
      p_param_name  => 'p_txn_line_dtl_rec.sub_type_id',
      p_api_name    => l_api_name);

/* Commenting/Removing this restriction and API will default value for this flag based on the value for instance id column - shegde*/
/*
  IF p_txn_line_dtl_rec.instance_exists_flag = 'Y' THEN
    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value       => p_txn_line_dtl_rec.instance_exists_flag,
      p_param_name  => 'p_txn_line_dtl_rec.instance_exists_flag',
      p_api_name    => l_api_name);
  END IF;
*/

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value       => p_txn_line_dtl_rec.inventory_item_id,
      p_param_name  => 'p_txn_line_dtl_rec.inventory_item_id',
      p_api_name    => l_api_name);

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value       => p_txn_line_dtl_rec.inv_organization_id,
      p_param_name  => 'p_txn_line_dtl_rec.inv_organization_id',
      p_api_name    => l_api_name);

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value       => p_txn_line_dtl_rec.quantity,
      p_param_name  => 'p_txn_line_dtl_rec.quantity',
      p_api_name    => l_api_name);

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value       => p_txn_line_dtl_rec.unit_of_measure,
      p_param_name  => 'p_txn_line_dtl_rec.unit_of_measure',
      p_api_name    => l_api_name);

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value       => p_txn_line_dtl_rec.source_transaction_flag,
      p_param_name  => 'p_txn_line_dtl_rec.source_transaction_flag',
      p_api_name    => l_api_name);

    IF NVL(p_txn_line_dtl_rec.location_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN

      csi_t_vldn_routines_pvt.check_reqd_param(
        p_value       => p_txn_line_dtl_rec.location_type_code,
        p_param_name  => 'p_txn_line_dtl_rec.location_type_code',
        p_api_name    => l_api_name);

    END IF;
/* no longer required. all serialized item instances have the serials numbers in INV now. 3593990
    IF NVL(p_txn_line_dtl_rec.serial_number, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN

      csi_t_vldn_routines_pvt.check_reqd_param(
        p_value       => p_txn_line_dtl_rec.mfg_serial_number_flag,
        p_param_name  => 'p_txn_line_dtl_rec.mfg_serial_number_flag',
        p_api_name    => l_api_name);

    END IF;
*/

    debug('Dtls: End of required parameters check .');

    -- validate txn sub_type_id
    IF nvl(p_txn_line_dtl_rec.sub_type_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

      --debug('Validate sub type id.');

      csi_t_vldn_routines_pvt.validate_sub_type_id(
        p_transaction_line_id => p_txn_line_dtl_rec.transaction_line_id,
        p_sub_type_id         => p_txn_line_dtl_rec.sub_type_id,
        x_return_status       => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        debug('Validate sub type id failed.');

        fnd_message.set_name('CSI','CSI_TXN_SUB_TYPE_ID_INVALID');
        fnd_message.set_token('SUB_TYPE_ID',p_txn_line_dtl_rec.sub_type_id);
        fnd_msg_pub.add;
        raise fnd_api.g_exc_error;

      END IF;

    END IF;

    -- validate instance type
    IF NVL(p_txn_line_dtl_rec.instance_type_code, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN

      --debug('Validate instance type code.');

      IF NOT
         csi_item_instance_vld_pvt.is_valid_instance_type(
           p_instance_type_code => p_txn_line_dtl_rec.instance_type_code)
      THEN
        debug('Validate instance type code failed.');
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    -- validate item instance
--    IF p_txn_line_dtl_rec.instance_exists_flag = 'Y' THEN
    IF nvl(p_txn_line_dtl_rec.instance_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num THEN

      --debug('Validate instance id .');
      csi_t_vldn_routines_pvt.validate_instance_id(
        p_instance_id    => p_txn_line_dtl_rec.instance_id,
        x_return_status  => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN

        debug('Validate instance id failed.');

        FND_MESSAGE.set_name('CSI','CSI_API_INVALID_INSTANCE_ID');
        FND_MESSAGE.set_token('INSTANCE_ID',p_txn_line_dtl_rec.instance_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;

      END IF;

    END IF;

    -- validate system id
    IF NVL(p_txn_line_dtl_rec.csi_system_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN

      --debug('Validate csi system id .');
      IF NOT
         csi_item_instance_vld_pvt.is_valid_system_id(
           p_system_id => p_txn_line_dtl_rec.csi_system_id) THEN

        debug('Validate csi system id failed.');
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    -- Start of Addition for ER 6936037
    BEGIN
    SELECT source_transaction_type_id
           into l_src_transaction_type_id
           from CSI_T_TRANSACTION_LINES
           WHERE transaction_line_id = p_txn_line_dtl_rec.transaction_line_id;
    EXCEPTION
      WHEN OTHERS THEN
        debug('No Transaction Type Id found for transaction_line_id - ' || p_txn_line_dtl_rec.transaction_line_id);
        null;
    END;
    -- End of Addition for ER 6936037

    -- If the transaction is a mass update, IB trackable checking is skipped
    -- as per ER 6936037
    IF NVL(l_src_transaction_type_id, fnd_api.g_miss_num) <> 3 THEN

    -- is item trackable (inventory_item_id)
    IF NVL(p_txn_line_dtl_rec.inventory_item_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num THEN

      --debug('Validate item id for trackabality .');
      IF NOT
         csi_item_instance_vld_pvt.is_trackable(
           p_inv_item_id => p_txn_line_dtl_rec.inventory_item_id,
           p_org_id      => p_txn_line_dtl_rec.inv_organization_id) THEN

        debug('Validate item id for trackabality failed.');
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    END IF; -- Checking for Mass Addition transaction

    -- item condition codes against the mtl_material_statuses
    IF NVL(p_txn_line_dtl_rec.item_condition_id,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN

      --debug('Validate item condition id .');

      csi_item_instance_vld_pvt.is_valid_condition(
        p_instance_condition_id  => p_txn_line_dtl_rec.item_condition_id,
        p_creation_complete_flag => l_creation_flag,
        l_return_value           => l_valid);

      IF not(l_valid) THEN
        debug('Validate item condition id failed.');
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    -- item revision
    IF nvl(p_txn_line_dtl_rec.inventory_revision, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN

      --debug('Validate item revision .');

      csi_item_instance_vld_pvt.validate_revision(
        p_inv_item_id            => p_txn_line_dtl_rec.inventory_item_id,
        p_inv_org_id             => p_txn_line_dtl_rec.inv_organization_id,
        p_revision               => p_txn_line_dtl_rec.inventory_revision,
        p_creation_complete_flag => l_creation_flag,
        l_return_value           => l_valid);

      IF NOT(l_valid) THEN
        debug('Validate item revision failed.');
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    l_uom_code := p_txn_line_dtl_rec.unit_of_measure;
    l_quantity := p_txn_line_dtl_rec.quantity;

    -- validate quantity
    IF nvl(l_quantity,0) <= 0 THEN
      fnd_message.set_name('CSI','CSI_TXN_QTY_INVALID');
      fnd_message.set_token('ITEM_ID',p_txn_line_dtl_rec.inventory_item_id);
      fnd_message.set_token('QTY',l_quantity);
      fnd_msg_pub.add;
      raise fnd_api.g_exc_error;
    END IF;

    --debug('Validate item uom .');
    -- validate uom
    csi_item_instance_vld_pvt.is_valid_uom(
      p_inv_org_id             => p_txn_line_dtl_rec.inv_organization_id,
      p_inv_item_id            => p_txn_line_dtl_rec.inventory_item_id,
      p_uom_code               => l_uom_code,
      p_quantity               => l_quantity,
      p_creation_complete_flag => l_creation_flag,
      l_return_value           => l_valid);

    IF not (l_valid)  then
      debug('Validate item uom failed.');
      RAISE fnd_api.g_exc_error;
    END IF;

    -- serial number
    IF nvl(p_txn_line_dtl_rec.serial_number, fnd_api.g_miss_char) <> fnd_api.g_miss_char
       --AND
       --nvl(p_txn_line_dtl_rec.mfg_serial_number_flag, fnd_api.g_miss_char) = 'Y' bug 3593990
    THEN

      debug('Validating Serial Number.');

      csi_t_vldn_routines_pvt.validate_serial_number(
        p_inventory_item_id => p_txn_line_dtl_rec.inventory_item_id,
        p_organization_id   => p_txn_line_dtl_rec.inv_organization_id,
        p_serial_number     => p_txn_line_dtl_rec.serial_number,
        x_return_status     => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        debug('csi_t_vldn_routines_pvt.validate_serial_number Failed.');
        RAISE fnd_api.g_exc_error;
      END IF;

      /*
      csi_item_instance_vld_pvt.validate_serial_number(
        p_inv_org_id             => p_txn_line_dtl_rec.inv_organization_id,
        p_inv_item_id            => p_txn_line_dtl_rec.inventory_item_id,
        p_serial_number          => p_txn_line_dtl_rec.serial_number,
        p_mfg_serial_number_flag => p_txn_line_dtl_rec.mfg_serial_number_flag,
        p_creation_complete_flag => l_creation_flag,
        l_return_value           => l_valid);

      IF NOT(l_valid) THEN
        debug('Validate item serial number failed.');
        RAISE fnd_api.g_exc_error;
      END IF;
      */

    END IF;

    -- lot number
    IF nvl(p_txn_line_dtl_rec.lot_number, fnd_api.g_miss_char) <> fnd_api.g_miss_char
    THEN

      debug('Validating line details lot number .');

      csi_t_vldn_routines_pvt.validate_lot_number(
        p_inventory_item_id  => p_txn_line_dtl_rec.inventory_item_id,
        p_organization_id    => p_txn_line_dtl_rec.inv_organization_id,
        p_lot_number         => p_txn_line_dtl_rec.lot_number,
        x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        debug('csi_t_vldn_routines_pvt.validate_lot_number Failed.');
        RAISE fnd_api.g_exc_error;
      END IF;

      /*
      csi_item_instance_vld_pvt.validate_lot_number(
        p_inv_org_id             => p_txn_line_dtl_rec.inv_organization_id,
        p_inv_item_id            => p_txn_line_dtl_rec.inventory_item_id,
        p_lot_number             => p_txn_line_dtl_rec.lot_number,
        p_mfg_serial_number_flag => p_txn_line_dtl_rec.mfg_serial_number_flag,
        p_creation_complete_flag => l_creation_flag,
        l_return_value           => l_valid);

      IF NOT(l_valid) THEN
        debug('Validate item lot number failed.');
        RAISE fnd_api.g_exc_error;
      END IF;
      */

    END IF;

    --debug('Validate location type code .');

    -- location_type_code
    IF NOT
       csi_item_instance_vld_pvt.is_valid_location_source(
         p_loc_source_table => p_txn_line_dtl_rec.location_type_code)
    THEN
      debug('Validate location type code failed.');
      RAISE fnd_api.g_exc_error;
    END IF;

    IF NVL(p_txn_line_dtl_rec.location_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
    THEN

      -- debug('Validate location id .');
      l_valid := csi_item_instance_vld_pvt.is_valid_location_id(
                   p_location_source_table => p_txn_line_dtl_rec.location_type_code,
                   p_location_id           => p_txn_line_dtl_rec.location_id);

      IF NOT (l_valid) then
         debug('Validate location id failed.');
         RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

   /* SELECT decode(nvl(p_txn_line_dtl_rec.processing_status,fnd_api.g_miss_char),
            fnd_api.g_miss_char, 'SUBMIT', p_txn_line_dtl_rec.processing_status)
    INTO   l_processing_status
    FROM   sys.dual;

    SELECT decode(nvl(p_txn_line_dtl_rec.preserve_detail_flag,fnd_api.g_miss_char),
             fnd_api.g_miss_char, 'Y', p_txn_line_dtl_rec.preserve_detail_flag)
    INTO   l_preserve_detail_flag
    FROM   sys.dual;*/

     -- Start Removed decode from sys.dual for bug  5897107
 	     IF  nvl(p_txn_line_dtl_rec.processing_status,fnd_api.g_miss_char) = fnd_api.g_miss_char then
 	       l_processing_status :=  'SUBMIT';
 	     ELSE
 	       l_processing_status := p_txn_line_dtl_rec.processing_status;
 	     END IF;

 	     IF nvl(p_txn_line_dtl_rec.preserve_detail_flag,fnd_api.g_miss_char) = fnd_api.g_miss_char then
 	       l_preserve_detail_flag :=  'Y';
 	     ELSE
 	       l_preserve_detail_flag :=  p_txn_line_dtl_rec.preserve_detail_flag;
 	     END IF;
     -- End Removed decode from sys.dual for bug  5897107

    IF NVL(p_txn_line_dtl_rec.reference_source_line_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num -- RMA fulfillment 11.5.9 ER
    THEN

      csi_t_vldn_routines_pvt.validate_txn_source_id(
            p_txn_source_name  => 'ORDER_ENTRY',
            p_txn_source_id    =>  p_txn_line_dtl_rec.reference_source_line_id,
            x_return_status    => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        debug('csi_t_vldn_routines_pvt.validate_txn_source_id.');
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

/*
--commented for the M-M enhancement since txn_line_detail_id will now be passed as sort of an index identifier
  in the ii relationships table (passed as a parameter)
    IF nvl(p_txn_line_dtl_rec.txn_line_detail_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      l_txn_line_detail_id := p_txn_line_dtl_rec.txn_line_detail_id;
    END IF;
*/
      l_txn_line_detail_id := fnd_api.g_miss_num;


    IF nvl(p_txn_line_dtl_rec.cascade_owner_flag, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN

     --commented SQL below to make changes for the bug 4028827
      /*
	 Begin
	 Select nvl(ownership_cascade_at_txn, 'N')
	 Into l_cascade_owner_flag
	 From csi_install_parameters;
	 Exception when others then
         l_cascade_owner_flag := 'N';
          End;
      */
      l_cascade_owner_flag := NVL(csi_datastructures_pub.g_install_param_rec. ownership_cascade_at_txn,'N');
    ELSE
      l_cascade_owner_flag := p_txn_line_dtl_rec.cascade_owner_flag;
    END IF;

    IF nvl(p_txn_line_dtl_rec.parent_instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      csi_t_vldn_routines_pvt.validate_instance_id(
        p_instance_id    => p_txn_line_dtl_rec.parent_instance_id,
        x_return_status  => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN

        debug('Validate instance id failed.');

        FND_MESSAGE.set_name('CSI','CSI_API_INVALID_INSTANCE_ID');
        FND_MESSAGE.set_token('INSTANCE_ID',p_txn_line_dtl_rec.parent_instance_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;

      END IF;
    END IF;
    -- Added the below IF for the R12 TSO with Equipment MACD to handle removal
    -- of CZ keys on Disconnect in the Core APIs by stamping instance_id in CSIT
    -- upfront and later depending on it

    IF (NVL(p_txn_line_dtl_rec.config_inst_hdr_id , fnd_api.g_miss_num) <>  fnd_api.g_miss_num
     AND NVL(p_txn_line_dtl_rec.config_inst_item_id , fnd_api.g_miss_num) <> fnd_api.g_miss_num
     AND NVL(p_txn_line_dtl_rec.config_inst_baseline_rev_num , fnd_api.g_miss_num) <> fnd_api.g_miss_num)
    THEN
     -- with the baseline rev and config keys , get the associated instance id
     -- if there is a baseline rev num then it is a existing item instance
	 Begin
	     Select serial_number, instance_id, lot_number
	     Into p_txn_line_dtl_rec.serial_number, p_txn_line_dtl_rec.instance_id,
		      p_txn_line_dtl_rec.lot_number
           From csi_item_instances
	     Where config_inst_hdr_id = p_txn_line_dtl_rec.config_inst_hdr_id
            AND config_inst_item_id = p_txn_line_dtl_rec.config_inst_item_id;
            --AND config_inst_rev_num = p_txn_line_dtl_rec.config_inst_baseline_rev_num;
       Exception when others then
         null;  -- do nothing...
       End;
    END IF ;

    -- Added the below IF for bug 2563265
    IF nvl(p_txn_line_dtl_rec.serial_number, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
     IF nvl(p_txn_line_dtl_rec.instance_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
      Begin
       Select serial_number, instance_id, lot_number
       Into p_txn_line_dtl_rec.serial_number, p_txn_line_dtl_rec.instance_id,
            p_txn_line_dtl_rec.lot_number
       From csi_item_instances
       Where inventory_item_id = p_txn_line_dtl_rec.inventory_item_id
         and serial_number = p_txn_line_dtl_rec.serial_number;
        Exception when others then
         null;-- do nothing. This is just to sync instance data on the tld rec...
        End;
     END IF;
    ELSIF nvl(p_txn_line_dtl_rec.instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      Begin
       Select serial_number, instance_id, lot_number
       Into p_txn_line_dtl_rec.serial_number, p_txn_line_dtl_rec.instance_id,
           p_txn_line_dtl_rec.lot_number
       From csi_item_instances
       Where instance_id = p_txn_line_dtl_rec.instance_id;
      Exception when others then
         null;-- do nothing. This should not arise though.
        End;
    END IF;

    -- validate instance status id
    IF NVL(p_txn_line_dtl_rec.instance_status_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN
      --debug('Validate instance status id .');
         csi_item_instance_vld_pvt.is_valid_status(
           p_instance_status_id     => p_txn_line_dtl_rec.instance_status_id,
           p_creation_complete_flag => l_creation_flag,
           l_return_value           => l_valid);

      IF not(l_valid) THEN
        debug('Validate instance status id failed.');
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;


    -- call table handler to insert in to table
    begin

      csi_t_gen_utility_pvt.dump_api_info(
        p_api_name => 'insert_row',
        p_pkg_name => 'csi_t_txn_line_details_pkg');

      csi_t_txn_line_details_pkg.insert_row(
        px_txn_line_detail_id     => l_txn_line_detail_id,
        p_transaction_line_id     => p_txn_line_dtl_rec.transaction_line_id,
        p_sub_type_id             => p_txn_line_dtl_rec.sub_type_id,
        p_instance_exists_flag    => p_txn_line_dtl_rec.instance_exists_flag,
        p_source_transaction_flag => p_txn_line_dtl_rec.source_transaction_flag,
        p_instance_id             => p_txn_line_dtl_rec.instance_id,
        p_csi_system_id           => p_txn_line_dtl_rec.csi_system_id,
        p_inventory_item_id       => p_txn_line_dtl_rec.inventory_item_id,
        p_inv_organization_id     => p_txn_line_dtl_rec.inv_organization_id,
        p_inventory_revision      => p_txn_line_dtl_rec.inventory_revision,
        p_instance_type_code      => p_txn_line_dtl_rec.instance_type_code,
        p_item_condition_id       => p_txn_line_dtl_rec.item_condition_id,
        p_quantity                => p_txn_line_dtl_rec.quantity,
        p_unit_of_measure         => p_txn_line_dtl_rec.unit_of_measure,
        p_qty_remaining           => p_txn_line_dtl_rec.qty_remaining,
        p_serial_number           => p_txn_line_dtl_rec.serial_number,
        p_lot_number              => p_txn_line_dtl_rec.lot_number,
        p_mfg_serial_number_flag  => p_txn_line_dtl_rec.mfg_serial_number_flag,
        p_location_type_code      => p_txn_line_dtl_rec.location_type_code,
        p_location_id             => p_txn_line_dtl_rec.location_id,
        p_installation_date       => p_txn_line_dtl_rec.installation_date,
        p_in_service_date         => p_txn_line_dtl_rec.in_service_date,
        p_external_reference      => p_txn_line_dtl_rec.external_reference,
        p_version_label           => p_txn_line_dtl_rec.version_label,
        p_transaction_system_id   => p_txn_line_dtl_rec.transaction_system_id,
        p_sellable_flag           => p_txn_line_dtl_rec.sellable_flag,
        p_return_by_date          => p_txn_line_dtl_rec.return_by_date,
        p_active_start_date       => p_txn_line_dtl_rec.active_start_date,
        p_active_end_date         => p_txn_line_dtl_rec.active_end_date,
        p_preserve_detail_flag    => l_preserve_detail_flag,
        p_changed_instance_id     => p_txn_line_dtl_rec.changed_instance_id,
        p_reference_source_id     => p_txn_line_dtl_rec.reference_source_id,
        p_reference_source_line_id => p_txn_line_dtl_rec.reference_source_line_id,
        p_reference_source_date   => p_txn_line_dtl_rec.reference_source_date,
        p_csi_transaction_id      => p_txn_line_dtl_rec.csi_transaction_id,
        p_source_txn_line_detail_id => p_txn_line_dtl_rec.source_txn_line_detail_id,
        p_inv_mtl_transaction_id  => p_txn_line_dtl_rec.inv_mtl_transaction_id,
        p_processing_status       => l_processing_status,
        p_error_code              => p_txn_line_dtl_rec.error_code,
        p_error_explanation       => p_txn_line_dtl_rec.error_explanation,
        -- Added for CZ Integration (Begin)
        p_config_inst_hdr_id      => p_txn_line_dtl_rec.config_inst_hdr_id ,
        p_config_inst_rev_num     => p_txn_line_dtl_rec.config_inst_rev_num ,
        p_config_inst_item_id    => p_txn_line_dtl_rec.config_inst_item_id ,
        p_config_inst_baseline_rev_num    => p_txn_line_dtl_rec.config_inst_baseline_rev_num ,
        p_target_commitment_date    => p_txn_line_dtl_rec.target_commitment_date ,
        p_instance_description    => p_txn_line_dtl_rec.instance_description ,
        -- Added for CZ Integration (End)
        -- Added for Partner Ordering (Begin)
        p_install_location_type_code  => p_txn_line_dtl_rec.install_location_type_code,
        p_install_location_id         => p_txn_line_dtl_rec.install_location_id,
        -- Added for Partner Ordering (End)
        p_cascade_owner_flag      => l_cascade_owner_flag, -- bug 2972082
        p_attribute1              => p_txn_line_dtl_rec.attribute1,
        p_attribute2              => p_txn_line_dtl_rec.attribute2,
        p_attribute3              => p_txn_line_dtl_rec.attribute3,
        p_attribute4              => p_txn_line_dtl_rec.attribute4,
        p_attribute5              => p_txn_line_dtl_rec.attribute5,
        p_attribute6              => p_txn_line_dtl_rec.attribute6,
        p_attribute7              => p_txn_line_dtl_rec.attribute7,
        p_attribute8              => p_txn_line_dtl_rec.attribute8,
        p_attribute9              => p_txn_line_dtl_rec.attribute9,
        p_attribute10             => p_txn_line_dtl_rec.attribute10,
        p_attribute11             => p_txn_line_dtl_rec.attribute11,
        p_attribute12             => p_txn_line_dtl_rec.attribute12,
        p_attribute13             => p_txn_line_dtl_rec.attribute13,
        p_attribute14             => p_txn_line_dtl_rec.attribute14,
        p_attribute15             => p_txn_line_dtl_rec.attribute15,
        p_created_by              => g_user_id,
        p_creation_date           => sysdate,
        p_last_updated_by         => g_user_id,
        p_last_update_date        => sysdate,
        p_last_update_login       => g_login_id,
        p_object_version_number   => 1.0,
        p_context                 => p_txn_line_dtl_rec.context,
        p_parent_instance_id      => p_txn_line_dtl_rec.parent_instance_id,
        p_assc_txn_line_detail_id => p_txn_line_dtl_rec.assc_txn_line_detail_id,
        p_overriding_csi_txn_id   => p_txn_line_dtl_rec.overriding_csi_txn_id,
        p_instance_status_id      => p_txn_line_dtl_rec.instance_status_id);
    exception
      when others then
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE',
           'csi_t_txn_line_details_pkg.insert_row Failed. '||substr(sqlerrm,1,200));
        fnd_msg_pub.add;
        raise fnd_api.g_exc_error;
    end;

    p_txn_line_dtl_rec.txn_line_detail_id := l_txn_line_detail_id;

    IF px_txn_party_dtl_tbl.COUNT > 0 THEN

      --loop thru party detail table
      -- new attribute, R12 Mass Update API call, due to the API call from EO, UI is unable to correctly identify
      -- and collect and pass the correct indexes.. need a additional attribute for update_transaction_dtls
      -- first loop through and identify this new attribute is passed by caller or not...
      l_contact_party_index := 'N';
      FOR l_index IN px_txn_party_dtl_tbl.FIRST..px_txn_party_dtl_tbl.LAST
      LOOP

        IF  l_contact_party_index = 'N' THEN
         IF nvl(px_txn_party_dtl_tbl(l_index).txn_contact_party_index, fnd_api.g_miss_num) <>
            fnd_api.g_miss_num
         THEN
             -- new attribute passed by caller, set the flag once
             l_contact_party_index := 'Y';
         END IF;
        END IF;
        --initialize row variable

        if px_txn_party_dtl_tbl(l_index).txn_line_details_index =
          p_txn_line_dtl_index then

          l_txn_party_rec := px_txn_party_dtl_tbl(l_index);
          l_txn_party_rec.txn_line_detail_id     := l_txn_line_detail_id;

          -- call api to create party detail records
          csi_t_txn_parties_pvt.create_txn_party_dtls(
            p_api_version          => p_api_version,
            p_commit               => p_commit,
            p_init_msg_list        => p_init_msg_list,
            p_validation_level     => p_validation_level,
            p_txn_party_dtl_index  => l_index,
            p_txn_party_detail_rec => l_txn_party_rec,
            px_txn_pty_acct_detail_tbl => px_txn_pty_acct_detail_tbl,
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          px_txn_party_dtl_tbl(l_index).txn_line_detail_id :=
               l_txn_party_rec.txn_line_detail_id;
          px_txn_party_dtl_tbl(l_index).txn_party_detail_id :=
               l_txn_party_rec.txn_party_detail_id;
        END IF;

      END LOOP;

      l_tmp_party_dtl_tbl := px_txn_party_dtl_tbl;

      /* process the contact party id */
      FOR cont_ind IN px_txn_party_dtl_tbl.FIRST .. px_txn_party_dtl_tbl.LAST
      LOOP
        IF nvl(px_txn_party_dtl_tbl(cont_ind).contact_party_id, fnd_api.g_miss_num) <>
           fnd_api.g_miss_num AND nvl(px_txn_party_dtl_tbl(cont_ind).contact_flag, 'N') = 'Y'
        THEN
           IF nvl(l_contact_party_index, 'N') = 'Y' THEN
             l_contact_party_id := null;
             FOR p_ind IN l_tmp_party_dtl_tbl.FIRST .. l_tmp_party_dtl_tbl.LAST
             LOOP
                IF ( l_tmp_party_dtl_tbl(p_ind).txn_contact_party_index is not null
                   AND l_tmp_party_dtl_tbl(p_ind).txn_contact_party_index <>  fnd_api.g_miss_num )
                THEN
                   IF l_tmp_party_dtl_tbl(p_ind).txn_contact_party_index = px_txn_party_dtl_tbl(cont_ind).contact_party_id
                     AND ( nvl(l_tmp_party_dtl_tbl(p_ind).contact_flag,'N') = 'N' OR
                        nvl(l_tmp_party_dtl_tbl(p_ind).contact_flag,fnd_api.g_miss_char) = fnd_api.g_miss_char)
                   THEN
                       l_contact_party_id := l_tmp_party_dtl_tbl(p_ind).txn_party_detail_id;
                       exit;
                   END IF;
                END IF;
              END LOOP;
           ELSE
              l_contact_party_id := null;
              FOR p_ind IN l_tmp_party_dtl_tbl.FIRST .. l_tmp_party_dtl_tbl.LAST
              LOOP
                IF p_ind = px_txn_party_dtl_tbl(cont_ind).contact_party_id
                  AND nvl(l_tmp_party_dtl_tbl(p_ind).contact_flag,'N') = 'N'
                THEN
                   l_contact_party_id := l_tmp_party_dtl_tbl(p_ind).txn_party_detail_id;
                   exit;
                END IF;
              END LOOP;
           END IF;

           IF l_contact_party_id is not null THEN
               update csi_t_party_details
               set    contact_party_id    = l_contact_party_id
               where  txn_party_detail_id = px_txn_party_dtl_tbl(cont_ind).txn_party_detail_id;
           END IF;
        END IF;
      END LOOP;
    END IF;

    IF px_txn_org_assgn_tbl.COUNT > 0 THEN

      -- loop thru org assignments table
      FOR l_index IN px_txn_org_assgn_tbl.FIRST..px_txn_org_assgn_tbl.LAST
      LOOP

        if px_txn_org_assgn_tbl(l_index).txn_line_details_index =
           p_txn_line_dtl_index THEN

          l_txn_oa_rec := px_txn_org_assgn_tbl(l_index);
          l_txn_oa_rec.txn_line_detail_id     := l_txn_line_detail_id;

          -- call api to create organization assignment records
          csi_t_txn_ous_pvt.create_txn_org_assgn_dtls(
            p_api_version         => p_api_version,
            p_commit              => p_commit,
            p_init_msg_list       => p_init_msg_list,
            p_validation_level    => p_validation_level,
            p_txn_org_assgn_rec   => l_txn_oa_rec,
            x_return_status       => l_return_status,
            x_msg_count           => l_msg_count,
            x_msg_data            => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            raise fnd_api.g_exc_error;
          END IF;

          px_txn_org_assgn_tbl(l_index).txn_line_detail_id :=
             l_txn_oa_rec.txn_line_detail_id;

          px_txn_org_assgn_tbl(l_index).txn_operating_unit_id :=
             l_txn_oa_rec.txn_operating_unit_id;

        END IF;

      END LOOP;

    END IF;

    IF px_txn_ext_attrib_vals_tbl.COUNT > 0 then

      -- loop thru ext attrib table
      FOR l_index IN px_txn_ext_attrib_vals_tbl.FIRST..px_txn_ext_attrib_vals_tbl.LAST
      LOOP

        IF px_txn_ext_attrib_vals_tbl(l_index).txn_line_details_index =
           p_txn_line_dtl_index THEN

          l_txn_ea_rec := px_txn_ext_attrib_vals_tbl(l_index);
          l_txn_ea_rec.txn_line_detail_id     := l_txn_line_detail_id;

          -- call api to create extended attribute
          csi_t_txn_attribs_pvt.create_txn_ext_attrib_dtls(
            p_api_version             => p_api_version,
            p_commit                  => p_commit,
            p_init_msg_list           => p_init_msg_list,
            p_validation_level        => p_validation_level,
            p_txn_ext_attrib_vals_rec => l_txn_ea_rec,
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            debug('call to csi_t_txn_attribs_pvt.create_txn_ext_attrib_dtls failed ');
            RAISE fnd_api.g_exc_error;
          END IF;
          px_txn_ext_attrib_vals_tbl(l_index).txn_line_detail_id :=
             l_txn_ea_rec.txn_line_detail_id;
          px_txn_ext_attrib_vals_tbl(l_index).txn_attrib_detail_id :=
             l_txn_ea_rec.txn_attrib_detail_id;

        END IF;

      END LOOP;

    END IF;

    -- Standard check of p_commit.
    IF fnd_api.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    csi_t_gen_utility_pvt.set_debug_off;

    -- Standard call to get message count and if count is  get message info.
    fnd_msg_pub.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN

      ROLLBACK TO create_txn_line_dtls;
      x_return_status := fnd_api.g_ret_sts_error ;
      fnd_msg_pub.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);
      csi_t_gen_utility_pvt.set_debug_off;

    WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK TO Create_Txn_Line_Dtls;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;

      fnd_msg_pub.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);
      csi_t_gen_utility_pvt.set_debug_off;

    WHEN OTHERS THEN

      ROLLBACK TO Create_Txn_Line_Dtls;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;

      IF fnd_msg_pub.Check_Msg_Level(
           p_message_level => fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN

        fnd_msg_pub.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      fnd_msg_pub.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);
      csi_t_gen_utility_pvt.set_debug_off;

  END create_txn_line_dtls;

  /* This procedure is used to update the transaction line details.  */
  PROCEDURE update_txn_line_dtls (
    p_api_version              IN     NUMBER,
    p_commit                   IN     VARCHAR2 := fnd_api.g_false,
    p_init_msg_list            IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level         IN     NUMBER   := fnd_api.g_valid_level_full,
    p_txn_line_rec             IN     csi_t_datastructures_grp.txn_line_rec,
    p_txn_line_detail_tbl      IN     csi_t_datastructures_grp.txn_line_detail_tbl,
    px_txn_ii_rltns_tbl        IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    px_txn_party_detail_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_pty_acct_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_org_assgn_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    px_txn_ext_attrib_vals_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER ,
    x_msg_data                    OUT NOCOPY VARCHAR2)
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'update_txn_line_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;

    l_return_status           VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);

    l_td_rec                  csi_t_txn_line_details%ROWTYPE;
    l_valid                   BOOLEAN;
    l_creation_flag           VARCHAR2(1) := 'N';
    l_preserve_detail_flag    varchar2(1);
    l_found     	      VARCHAR2(1) ;
    l_src_transaction_type_id NUMBER;

    CURSOR td_cur (p_line_dtl_id in number) IS
      SELECT *
      FROM   csi_t_txn_line_details
      WHERE  txn_line_detail_id = p_line_dtl_id;

    l_instance_party_id       csi_i_parties.instance_party_id%TYPE;
    l_pty_ids_tbl             csi_t_datastructures_grp.txn_party_ids_tbl;
    l_pty_ind                 binary_integer;
    l_pty_acct_ids_tbl        csi_t_datastructures_grp.txn_pty_acct_ids_tbl;
    l_x_pty_acct_ids_tbl      csi_t_datastructures_grp.txn_pty_acct_ids_tbl;
    l_pty_acc_ind             binary_integer;

    CURSOR pty_cur (p_line_dtl_id in number) IS
      SELECT *
      FROM   csi_t_party_details
      WHERE  txn_line_detail_id = p_line_dtl_id;

    l_iir_ids_tbl             csi_t_datastructures_grp.txn_ii_rltns_ids_tbl;
    l_oa_ids_tbl              csi_t_datastructures_grp.txn_org_assgn_ids_tbl;
    l_oa_ind                  binary_integer;
    l_instance_ou_id          csi_t_org_assignments.instance_ou_id%type;

    CURSOR oa_cur(p_line_dtl_id in number) IS
      SELECT *
      FROM   csi_t_org_assignments
      WHERE  txn_line_detail_id = p_line_dtl_id;

    l_ea_ids_tbl              csi_t_datastructures_grp.txn_ext_attrib_ids_tbl;
    l_ea_ind                  binary_integer;
    l_attrib_source_id        csi_t_extend_attribs.attrib_source_id%type;

    CURSOR ea_cur(p_line_dtl_id in number) IS
      SELECT *
      FROM   csi_t_extend_attribs
      WHERE  txn_line_detail_id = p_line_dtl_id;

    l_pty_tbl                 csi_t_datastructures_grp.txn_party_detail_tbl;
    l_pty_acc_tbl             csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_pty_upd_ind             binary_integer;

    l_u_eav_tbl               csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_u_ea_ind                binary_integer;

    l_c_pty_tbl               csi_t_datastructures_grp.txn_party_detail_tbl;
    l_u_pty_tbl               csi_t_datastructures_grp.txn_party_detail_tbl;
    l_c_pty_ind               binary_integer;
    l_u_pty_ind               binary_integer;

    l_c_pty_acct_tbl          csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_u_pty_acct_tbl          csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_c_pa_ind                binary_integer;
    l_u_pa_ind                binary_integer;

    l_c_oa_tbl                csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_u_oa_tbl                csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_c_oa_ind                binary_integer;
    l_u_oa_ind                binary_integer;

    l_c_ii_tbl                csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_u_ii_tbl                csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_c_ii_ind                binary_integer;
    l_u_ii_ind                binary_integer;

    l_tmp_party_dtl_tbl      csi_t_datastructures_grp.txn_party_detail_tbl;
    l_contact_party_id       number;
    l_contact_party_index    VARCHAR2(1) := 'N';
    l_tmp_party_detail_tbl   csi_t_datastructures_grp.txn_party_detail_tbl;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT update_txn_line_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       fnd_api.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => G_PKG_NAME) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    IF l_debug_level > 1 THEN
      debug(p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);
    END IF;

    -- Main API code

    csi_t_txn_line_dtls_pvt.update_txn_line(
      p_txn_line_rec  => p_txn_line_rec,
      x_return_status => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      debug('Update transaction lines failed.');
      RAISE fnd_api.g_exc_error;
    END IF;

    IF p_txn_line_detail_tbl.COUNT > 0 THEN

      FOR l_ind in p_txn_line_detail_tbl.FIRST..p_txn_line_detail_tbl.LAST
      LOOP
        IF l_debug_level > 1 THEN
          csi_t_gen_utility_pvt.dump_line_detail_rec(
            p_line_detail_rec => p_txn_line_detail_tbl(l_ind));
        END IF;

        l_td_rec.txn_line_detail_id := p_txn_line_detail_tbl(l_ind).txn_line_detail_id;
        l_td_rec.config_inst_hdr_id := p_txn_line_detail_tbl(l_ind).config_inst_hdr_id;
        l_td_rec.config_inst_rev_num := p_txn_line_detail_tbl(l_ind).config_inst_rev_num;
        l_td_rec.config_inst_item_id := p_txn_line_detail_tbl(l_ind).config_inst_item_id;

        csi_t_vldn_routines_pvt.check_reqd_param(
          p_value      => l_td_rec.txn_line_detail_id,
          p_param_name => 'l_td_rec.txn_line_detail_id',
          p_api_name   => l_api_name);

        csi_t_vldn_routines_pvt.validate_txn_line_detail_id(
          p_txn_line_detail_id => l_td_rec.txn_line_detail_id,
          x_return_status      => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN

          FND_MESSAGE.set_name('CSI','CSI_TXN_LINE_DTL_ID_INVALID');
          FND_MESSAGE.set_token('LINE_DTL_ID',l_td_rec.txn_line_detail_id);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;

        END IF;

        IF   ( nvl(l_td_rec.config_inst_hdr_id,fnd_api.g_miss_num ) <> fnd_api.g_miss_num
	  OR   nvl(l_td_rec.config_inst_hdr_id,fnd_api.g_miss_num ) <> fnd_api.g_miss_num
	  OR   nvl(l_td_rec.config_inst_hdr_id,fnd_api.g_miss_num ) <> fnd_api.g_miss_num )
	THEN

            csi_t_gen_utility_pvt.add('Validating against CZ view ');
	    Begin
		SELECT 'Y'
		into l_found
		FROM   cz_config_items_v
		WHERE  instance_hdr_id  =  l_td_rec.config_inst_hdr_id
		AND    instance_rev_nbr =  l_td_rec.config_inst_rev_num
		AND    config_item_id   =  l_td_rec.config_inst_item_id;
	    Exception when no_data_found then
        		fnd_message.set_name('CSI','CSI_TXN_CZ_INVALID_INST_KEY');
        		fnd_message.set_token('INST_HDR_ID',l_td_rec.config_inst_hdr_id);
        		fnd_message.set_token('INST_REV_NBR',l_td_rec.config_inst_rev_num);
        		fnd_message.set_token('CONFIG_ITEM_ID',l_td_rec.config_inst_item_id);
        		fnd_msg_pub.add;
          	RAISE fnd_api.g_exc_error;
	    when others then
              	fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
              	fnd_message.set_token('MESSAGE',
                 'Error in getting Config Inst data Check Failed. '||substr(sqlerrm,1,200));
        	    	fnd_msg_pub.add;
              	RAISE fnd_api.g_exc_error;
	    End;
	END IF;

        -- fetch the old values using the cursor
        FOR l_td_cur_rec in td_cur(l_td_rec.txn_line_detail_id)
        LOOP

          l_td_rec.transaction_line_id := l_td_cur_rec.transaction_line_id;
          l_td_rec.sub_type_id         := p_txn_line_detail_tbl(l_ind).sub_type_id;
          l_td_rec.inv_organization_id := p_txn_line_detail_tbl(l_ind).inv_organization_id;
          l_td_rec.inventory_item_id   := p_txn_line_detail_tbl(l_ind).inventory_item_id;

          --validate sub_type_id
          IF l_td_rec.sub_type_id <> fnd_api.g_miss_num
          THEN

            csi_t_vldn_routines_pvt.check_reqd_param(
              p_value      => l_td_rec.sub_type_id,
              p_param_name => 'l_td_rec.sub_type_id',
              p_api_name   => l_api_name);

            --debug('To Validate subtype ID, We require more parameters.');

            csi_t_vldn_routines_pvt.check_reqd_param(
              p_value      => l_td_rec.transaction_line_id,
              p_param_name => 'l_td_rec.transaction_line_id',
              p_api_name   => l_api_name);
            /* not sure why the following are required for an update OR validating sub type - commenting

            csi_t_vldn_routines_pvt.check_reqd_param(
              p_value      => l_td_rec.inventory_item_id,
              p_param_name => 'l_td_rec.inventory_item_id',
              p_api_name   => l_api_name);

            csi_t_vldn_routines_pvt.check_reqd_param(
              p_value      => l_td_rec.inv_organization_id,
              p_param_name => 'l_td_rec.inv_organization_id',
              p_api_name   => l_api_name);
           */

            csi_t_vldn_routines_pvt.validate_sub_type_id(
              p_transaction_line_id => l_td_rec.transaction_line_id,
              p_sub_type_id         => l_td_rec.sub_type_id,
              x_return_status       => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN

              debug('Validate sub type id failed.');
              fnd_message.set_name('CSI','CSI_TXN_SUB_TYPE_ID_INVALID');
              fnd_message.set_token('SUB_TYPE_ID',l_td_rec.sub_type_id);
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;

            END IF;
          END IF;

          l_td_rec.instance_exists_flag := p_txn_line_detail_tbl(l_ind).instance_exists_flag;
          l_td_rec.instance_id          := p_txn_line_detail_tbl(l_ind).instance_id;

         /* Added this IF piece so that API will derive value for this based on the value for                       instance id column - shegde
         */

         -- Commented and Added the following code as part of fix 2756727
        /*
          IF nvl(l_td_cur_rec.instance_exists_flag,fnd_api.g_miss_char)
            <> nvl(l_td_rec.instance_exists_flag,fnd_api.g_miss_char) THEN
		IF ( l_td_rec.instance_exists_flag = fnd_api.g_miss_char
                   OR l_td_rec.instance_exists_flag is NULL ) THEN
                      IF  ( l_td_rec.instance_id <> fnd_api.g_miss_num
                         AND l_td_rec.instance_id is NOT NULL ) THEN
			 l_td_rec.instance_exists_flag := 'Y';
		      ELSE
			 l_td_rec.instance_exists_flag := 'N';
		      END IF;
		END IF;
	  END IF;
      */

      IF nvl(l_td_rec.instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
      THEN
         l_td_rec.instance_exists_flag := 'Y';
      ELSE
         l_td_rec.instance_exists_flag := 'N';
      END IF;

     -- End code fix as part of fix for Bug 2756727.

          -- validate instance ID
     --     IF l_td_rec.instance_exists_flag = 'Y' THEN
          IF nvl(l_td_rec.instance_id, fnd_api.g_miss_num) <>
               fnd_api.g_miss_num THEN
     --            csi_t_vldn_routines_pvt.check_reqd_param(
     --              p_value      => l_td_rec.instance_id,
     --              p_param_name => 'l_td_rec.instance_id',
     --              p_api_name   => l_api_name);

            csi_t_vldn_routines_pvt.validate_instance_id(
              p_instance_id   => l_td_rec.instance_id,
              x_return_status => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN

              FND_MESSAGE.set_name('CSI','CSI_API_INVALID_INSTANCE_ID');
              FND_MESSAGE.set_token('INSTANCE_ID',l_td_rec.instance_id);
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;

            END IF;

          END IF;

          l_td_rec.source_transaction_flag :=
            p_txn_line_detail_tbl(l_ind).source_transaction_flag;
          l_td_rec.quantity            := p_txn_line_detail_tbl(l_ind).quantity;
          l_td_rec.unit_of_measure     := p_txn_line_detail_tbl(l_ind).unit_of_measure;

          IF l_td_rec.source_transaction_flag = 'Y' THEN

            /* not sure why the following are required for an update OR the tld is sourced - commenting
               in any case, for validating serial, lot, revision etc WHEN CHANGED
               we are checking for the same again...

            -- mandate item , organization and quantity and uom
            csi_t_vldn_routines_pvt.check_reqd_param(
              p_value      => l_td_rec.inv_organization_id,
              p_param_name => 'l_td_rec.inv_organization_id',
              p_api_name   => l_api_name);

            csi_t_vldn_routines_pvt.check_reqd_param(
              p_value      => l_td_rec.inventory_item_id,
              p_param_name => 'l_td_rec.inventory_item_id',
              p_api_name   => l_api_name);

            csi_t_vldn_routines_pvt.check_reqd_param(
              p_value      => l_td_rec.quantity,
              p_param_name => 'l_td_rec.quantity',
              p_api_name   => l_api_name);

            csi_t_vldn_routines_pvt.check_reqd_param(
              p_value      => l_td_rec.unit_of_measure,
              p_param_name => 'l_td_rec.unit_of_measure',
              p_api_name   => l_api_name);
            */
           -- need to add code here to call validate_source_integrity cause we do not seem to be revalidating
           -- if the quantity OR UOM is being changed. right now making it null since a complete check
           -- for the current usage of this API needs to be done
            null;
          END IF;

          l_td_rec.csi_system_id := p_txn_line_detail_tbl(l_ind).csi_system_id;

          -- validate csi_system_id
          IF l_td_rec.csi_system_id <> fnd_api.g_miss_num
             AND
             l_td_rec.csi_system_id is not null
          THEN

            l_valid := csi_item_instance_vld_pvt.is_valid_system_id(
                         p_system_id => l_td_rec.csi_system_id);

            IF NOT (l_valid) THEN
              debug('Validate csi system id failed.');
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;

          -- ##validate organization_id
          IF l_td_rec.inv_organization_id <> fnd_api.g_miss_num THEN
            null;
          END IF;

          -- Start of Addition for ER 6936037
          BEGIN
          SELECT source_transaction_type_id
                 into l_src_transaction_type_id
                 from CSI_T_TRANSACTION_LINES
                 WHERE transaction_line_id = l_td_rec.transaction_line_id;
          EXCEPTION
            WHEN OTHERS THEN
              debug('No Transaction Type Id found for transaction_line_id - ' || l_td_rec.transaction_line_id);
              null;
          END;
          -- End of Addition for ER 6936037

          -- validate inventory_item_id
          IF l_td_rec.inventory_item_id <> fnd_api.g_miss_num THEN

            csi_t_vldn_routines_pvt.check_reqd_param(
              p_value      => l_td_rec.inventory_item_id,
              p_param_name => 'l_td_rec.inventory_item_id',
              p_api_name   => l_api_name);

              -- If the transaction is mass update, IB trackable checking is skipped
              -- as per ER 6936037
              IF NVL(l_src_transaction_type_id, fnd_api.g_miss_num) <> 3 THEN
                l_valid := csi_item_instance_vld_pvt.is_trackable(
                  p_inv_item_id => l_td_rec.inventory_item_id,
                  p_org_id      => l_td_rec.inv_organization_id);

                IF NOT (l_valid) THEN
                  debug('Validate item for trackabality failed.');
                  RAISE fnd_api.g_exc_error;
                END IF;
              END IF; -- Checking for Mass Addition transaction
          END IF;

          l_td_rec.inventory_revision := p_txn_line_detail_tbl(l_ind).inventory_revision;
          -- ##validate item_revision
          IF l_td_rec.inventory_revision <> fnd_api.g_miss_char
             AND
             l_td_rec.inventory_revision is not null
          THEN
            null;
          END IF;

          l_td_rec.instance_type_code := p_txn_line_detail_tbl(l_ind).instance_type_code;
          -- validate instance_type_code
          IF l_td_rec.instance_type_code <> fnd_api.g_miss_char
             AND
             l_td_rec.instance_type_code is not null
          THEN

            l_valid :=
              csi_item_instance_vld_pvt.is_valid_instance_type(
                p_instance_type_code => l_td_rec.instance_type_code);

            IF NOT (l_valid) THEN
              debug('Validate instance type code failed.');
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;

          l_td_rec.item_condition_id := p_txn_line_detail_tbl(l_ind).item_condition_id;

          --validate item_condition_id
          IF l_td_rec.item_condition_id <> fnd_api.g_miss_num
             AND
             l_td_rec.item_condition_id is not null
          THEN

            csi_item_instance_vld_pvt.is_valid_condition(
              p_instance_condition_id  => l_td_rec.item_condition_id,
              p_creation_complete_flag => l_creation_flag,
              l_return_value           => l_valid);

            IF not(l_valid) THEN
              debug('Validate item condition failed.');
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;


          -- ##validate uom_code
          IF l_td_rec.unit_of_measure <> fnd_api.g_miss_char
          THEN
            null;
          END IF;

          l_td_rec.qty_remaining   := p_txn_line_detail_tbl(l_ind).qty_remaining;

          l_td_rec.lot_number      := p_txn_line_detail_tbl(l_ind).lot_number;
          -- validate lot number
          IF l_td_rec.lot_number <> fnd_api.g_miss_char
             AND
             l_td_rec.lot_number is not null
          THEN

            csi_t_vldn_routines_pvt.check_reqd_param(
              p_value      => l_td_rec.inventory_item_id,
              p_param_name => 'l_td_rec.inventory_item_id',
              p_api_name   => l_api_name);

            csi_t_vldn_routines_pvt.check_reqd_param(
              p_value      => l_td_rec.inv_organization_id,
              p_param_name => 'l_td_rec.inv_organization_id',
              p_api_name   => l_api_name);

            debug('Validating line details lot number .');

            csi_t_vldn_routines_pvt.validate_lot_number(
              p_inventory_item_id  => l_td_rec.inventory_item_id,
              p_organization_id    => l_td_rec.inv_organization_id,
              p_lot_number         => l_td_rec.lot_number,
              x_return_status      => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              debug('csi_t_vldn_routines_pvt.validate_lot_number Failed.');
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;

          l_td_rec.serial_number   := p_txn_line_detail_tbl(l_ind).serial_number;
          l_td_rec.mfg_serial_number_flag := p_txn_line_detail_tbl(l_ind).mfg_serial_number_flag;

          -- IF l_td_rec.mfg_serial_number_flag = 'Y'
          --    AND bug 3593990
          IF nvl(l_td_rec.serial_number, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN

            csi_t_vldn_routines_pvt.check_reqd_param(
              p_value      => l_td_rec.inventory_item_id,
              p_param_name => 'l_td_rec.inventory_item_id',
              p_api_name   => l_api_name);

            csi_t_vldn_routines_pvt.check_reqd_param(
              p_value      => l_td_rec.inv_organization_id,
              p_param_name => 'l_td_rec.inv_organization_id',
              p_api_name   => l_api_name);

            debug('Validating Serial Number.');

            csi_t_vldn_routines_pvt.validate_serial_number(
              p_inventory_item_id => l_td_rec.inventory_item_id,
              p_organization_id   => l_td_rec.inv_organization_id,
              p_serial_number     => l_td_rec.serial_number,
              x_return_status     => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              debug('csi_t_vldn_routines_pvt.validate_serial_number Failed.');
              RAISE fnd_api.g_exc_error;
            END IF;

            /*
            --validate serial_number
            csi_item_instance_vld_pvt.validate_serial_number(
              p_inv_org_id             => l_td_rec.inv_organization_id,
              p_inv_item_id            => l_td_rec.inventory_item_id,
              p_serial_number          => l_td_rec.serial_number,
              p_mfg_serial_number_flag => l_td_rec.mfg_serial_number_flag,
              p_creation_complete_flag => l_creation_flag,
              l_return_value           => l_valid);

            IF NOT (l_valid) THEN
              debug('Validate serial number failed.');
              RAISE fnd_api.g_exc_error;
            END IF;
            */

          END IF;

          l_td_rec.location_type_code := p_txn_line_detail_tbl(l_ind).location_type_code;

          -- validate location_type_code
          IF l_td_rec.location_type_code <> fnd_api.g_miss_char
             AND
             l_td_rec.location_type_code is not null
          THEN

            l_valid :=
              csi_item_instance_vld_pvt.is_valid_location_source(
                p_loc_source_table => l_td_rec.location_type_code);

            IF NOT (l_valid) THEN
              debug('Validate location type code failed.');
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;

          l_td_rec.location_id := p_txn_line_detail_tbl(l_ind).location_id;

          --validate location_id
          IF l_td_rec.location_id <> fnd_api.g_miss_num
             AND
             l_td_rec.location_id is not null
          THEN

            l_valid := csi_item_instance_vld_pvt.is_valid_location_id(
                         p_location_source_table => l_td_rec.location_type_code,
                         p_location_id           => l_td_rec.location_id);

            IF NOT (l_valid) then
              debug('Validate location id failed.');
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;

          /*  Begin FOR install Locationo_Id and Install_Location_Type_Code*/

          l_td_rec.install_location_type_code := p_txn_line_detail_tbl(l_ind).install_location_type_code;

          -- validate install_location_type_code
          IF l_td_rec.install_location_type_code <> fnd_api.g_miss_char
            AND
             l_td_rec.install_location_type_code is not null
          THEN
            l_valid := csi_item_instance_vld_pvt.is_valid_location_source(
                            p_loc_source_table => l_td_rec.install_location_type_code);

            IF NOT (l_valid) THEN
              debug('Validate Install location type code failed.');
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;

          l_td_rec.install_location_id := p_txn_line_detail_tbl(l_ind).install_location_id;

          -- validate install_location_id
          IF l_td_rec.install_location_id <> fnd_api.g_miss_num
            AND
             l_td_rec.install_location_id is not null
          THEN
            l_valid := csi_item_instance_vld_pvt.is_valid_location_id(
                         p_location_source_table => l_td_rec.install_location_type_code,
                         p_location_id           => l_td_rec.install_location_id);

            IF NOT (l_valid) then
              debug('Validate Install location id failed.');
              RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

          /*  End FOR install Locationo_Id and Install_Location_Type_Code */

          IF NVL(l_td_rec.reference_source_line_id, fnd_api.g_miss_num)
             <> fnd_api.g_miss_num
          THEN

              csi_t_vldn_routines_pvt.validate_txn_source_id(
                p_txn_source_name  => 'ORDER_ENTRY',
                p_txn_source_id    =>  l_td_rec.reference_source_line_id,
                x_return_status    => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
                debug('csi_t_vldn_routines_pvt.validate_txn_source_id.');
                RAISE fnd_api.g_exc_error;
              END IF;

          END IF;

          l_td_rec.instance_status_id            := p_txn_line_detail_tbl(l_ind).instance_status_id;
          l_td_rec.overriding_csi_txn_id         := p_txn_line_detail_tbl(l_ind).overriding_csi_txn_id;
    -- validate instance status id
          IF NVL(l_td_rec.instance_status_id, fnd_api.g_miss_num) <>
             fnd_api.g_miss_num
          THEN
            --debug('Validate instance status id .');
               csi_item_instance_vld_pvt.is_valid_status(
                 p_instance_status_id     => l_td_rec.instance_status_id,
                 p_creation_complete_flag => l_creation_flag,
                 l_return_value           => l_valid);

            IF not(l_valid) THEN
              debug('Validate instance status id failed.');
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;

          l_td_rec.installation_date := p_txn_line_detail_tbl(l_ind).installation_date;
          l_td_rec.in_service_date   := p_txn_line_detail_tbl(l_ind).in_service_date;
          l_td_rec.external_reference:= p_txn_line_detail_tbl(l_ind).external_reference;
          l_td_rec.version_label     := p_txn_line_detail_tbl(l_ind).version_label;
          l_td_rec.transaction_system_id := p_txn_line_detail_tbl(l_ind).transaction_system_id;
          l_td_rec.sellable_flag     := p_txn_line_detail_tbl(l_ind).sellable_flag;
          l_td_rec.return_by_date    := p_txn_line_detail_tbl(l_ind).return_by_date;
          l_td_rec.active_start_date := p_txn_line_detail_tbl(l_ind).active_start_date;
          l_td_rec.active_end_date   := p_txn_line_detail_tbl(l_ind).active_end_date;
          l_td_rec.preserve_detail_flag := p_txn_line_detail_tbl(l_ind).preserve_detail_flag;
          l_td_rec.changed_instance_id  := p_txn_line_detail_tbl(l_ind).changed_instance_id;
          l_td_rec.reference_source_id  := p_txn_line_detail_tbl(l_ind).reference_source_id;
          l_td_rec.reference_source_line_id  := p_txn_line_detail_tbl(l_ind).reference_source_line_id;
          l_td_rec.reference_source_date:= p_txn_line_detail_tbl(l_ind).reference_source_date;
          l_td_rec.csi_transaction_id:= p_txn_line_detail_tbl(l_ind).csi_transaction_id;
          l_td_rec.source_txn_line_detail_id := p_txn_line_detail_tbl(l_ind).source_txn_line_detail_id;
          l_td_rec.inv_mtl_transaction_id := p_txn_line_detail_tbl(l_ind).inv_mtl_transaction_id;
          l_td_rec.processing_status := p_txn_line_detail_tbl(l_ind).processing_status;
          l_td_rec.error_code        := p_txn_line_detail_tbl(l_ind).error_code;
          l_td_rec.error_explanation := p_txn_line_detail_tbl(l_ind).error_explanation;
          l_td_rec.config_inst_hdr_id := p_txn_line_detail_tbl(l_ind).config_inst_hdr_id;
          l_td_rec.config_inst_rev_num := p_txn_line_detail_tbl(l_ind).config_inst_rev_num;
          l_td_rec.config_inst_item_id := p_txn_line_detail_tbl(l_ind).config_inst_item_id;
          l_td_rec.config_inst_baseline_rev_num := p_txn_line_detail_tbl(l_ind).config_inst_baseline_rev_num;
          l_td_rec.target_commitment_date := p_txn_line_detail_tbl(l_ind).target_commitment_date;
          l_td_rec.instance_description := p_txn_line_detail_tbl(l_ind).instance_description;
          l_td_rec.cascade_owner_flag := p_txn_line_detail_tbl(l_ind).cascade_owner_flag;
          l_td_rec.attribute1        := p_txn_line_detail_tbl(l_ind).attribute1;
          l_td_rec.attribute2        := p_txn_line_detail_tbl(l_ind).attribute2;
          l_td_rec.attribute3        := p_txn_line_detail_tbl(l_ind).attribute3;
          l_td_rec.attribute4        := p_txn_line_detail_tbl(l_ind).attribute4;
          l_td_rec.attribute5        := p_txn_line_detail_tbl(l_ind).attribute5;
          l_td_rec.attribute6        := p_txn_line_detail_tbl(l_ind).attribute6;
          l_td_rec.attribute7        := p_txn_line_detail_tbl(l_ind).attribute7;
          l_td_rec.attribute8        := p_txn_line_detail_tbl(l_ind).attribute8;
          l_td_rec.attribute9        := p_txn_line_detail_tbl(l_ind).attribute9;
          l_td_rec.attribute10       := p_txn_line_detail_tbl(l_ind).attribute10;
          l_td_rec.attribute11       := p_txn_line_detail_tbl(l_ind).attribute11;
          l_td_rec.attribute12       := p_txn_line_detail_tbl(l_ind).attribute12;
          l_td_rec.attribute13       := p_txn_line_detail_tbl(l_ind).attribute13;
          l_td_rec.attribute14       := p_txn_line_detail_tbl(l_ind).attribute14;
          l_td_rec.attribute15       := p_txn_line_detail_tbl(l_ind).attribute15;
          l_td_rec.created_by        := l_td_cur_rec.created_by;
          l_td_rec.creation_date     := l_td_cur_rec.creation_date;
          l_td_rec.last_updated_by   := g_user_id;
          l_td_rec.last_update_date  := sysdate;
          l_td_rec.last_update_login := g_login_id;
          l_td_rec.object_version_number := p_txn_line_detail_tbl(l_ind).object_version_number;
          l_td_rec.context           := p_txn_line_detail_tbl(l_ind).context;
          l_td_rec.parent_instance_id:= p_txn_line_detail_tbl(l_ind).parent_instance_id;
          l_td_rec.assc_txn_line_detail_id := p_txn_line_detail_tbl(l_ind).assc_txn_line_detail_id;

          --logic for preserving children using the preserve detail flag
          l_pty_ind := 0;
          IF ( l_td_rec.instance_id <> fnd_api.g_miss_num
              AND nvl(l_td_rec.instance_id,-9999) <> nvl(l_td_cur_rec.instance_id,-9999) ) THEN

            debug('Entering code for preserve details.');

            /* I have to do this update statement here because all the child entities
               are processed before the txn line detail is updated */

            update csi_t_txn_line_details
            set    instance_id          = l_td_rec.instance_id,
                   instance_exists_flag = l_td_rec.instance_exists_flag
            where  txn_line_detail_id   = l_td_rec.txn_line_detail_id;

            IF l_td_rec.instance_id <> nvl(l_td_cur_rec.instance_id,fnd_api.g_miss_num) THEN

              debug('User is trying to switch the instance id.');

              l_pty_upd_ind := 0;

              FOR l_pty_cur_rec IN pty_cur(l_td_rec.txn_line_detail_id)
              LOOP

                /* If the old instance id is null then preserve the children */

                IF nvl(l_td_cur_rec.instance_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
                  l_preserve_detail_flag := 'Y';
                ELSE
                  l_preserve_detail_flag  := nvl(l_pty_cur_rec.preserve_detail_flag,'N');
                END IF;

                IF l_preserve_detail_flag = 'Y' OR
                   l_pty_cur_rec.relationship_type_code = 'OWNER' THEN

                  debug('Trying to presere the party record. txn_party_detail_id :'||
                         l_pty_cur_rec.txn_party_detail_id);

                  BEGIN
                     IF l_pty_cur_rec.Contact_party_id is NULL THEN

                    SELECT instance_party_id
                    INTO   l_instance_party_id
                    FROM   csi_i_parties
                    WHERE  instance_id = l_td_rec.instance_id -- new instance
                    AND    party_id    = l_pty_cur_rec.party_source_id -- old party
                    AND    party_source_table = l_pty_cur_rec.party_source_table
                    AND    relationship_type_code = l_pty_cur_rec.relationship_type_code
                    AND    nvl(contact_flag,'N') = nvl(l_pty_cur_rec.contact_flag,'N')
                    AND    sysdate between nvl(active_start_date, sysdate-1)
                                   and     nvl(active_end_date, sysdate+1);

		   ELSE

		/* NEW QUERY FOR CONTACT_PARTY_ID is not null ADDED for the bug 4251709 */

			SELECT csiip.instance_party_id
			INTO   l_instance_party_id
			FROM
			csi_i_parties csiip,
			csi_i_parties csiipc,
			csi_t_party_details csitpd,
			csi_t_party_details csitpdc
			WHERE csitpdc.party_SOURCE_id   = l_pty_cur_rec.party_source_id
			AND   csiipc.instance_id=l_td_rec.instance_id
			AND   csiip.contact_ip_id=csiipc.instance_party_id
			AND   csitpdc.contact_party_id=csitpd.txn_party_detail_id
			AND   csitpdc.party_source_table = csiip.party_source_table
			AND   csitpdc.relationship_type_code =  csiip.relationship_type_code
			AND   nvl(csitpdc.contact_flag,'N')=   nvl(csiip.contact_flag,'N')
			AND   csitpdc.party_SOURCE_id=csiip.party_id
			AND   csitpdc.party_source_table = l_pty_cur_rec.party_source_table
			AND   csitpdc.relationship_type_code = l_pty_cur_rec.relationship_type_code
			AND   csitpdc.txn_party_detail_id=  l_pty_cur_rec.txn_party_detail_id
			AND   nvl(csitpdc.contact_flag,'N') =nvl(l_pty_cur_rec.contact_flag,'N')
			AND   csitpd.party_source_id= csiipc.party_id
			AND   csitpd.party_source_table= csiipc.party_source_table
			AND   csitpd.relationship_type_code = csiipc.relationship_type_code
			AND   csitpd.contact_flag = csiipc.contact_flag
			AND    sysdate between nvl(csiip.active_start_date, sysdate-1)
			AND    nvl(csiip.active_end_date, sysdate+1);

			END IF;

                  EXCEPTION
                    WHEN no_data_found THEN

                      /* this query will return one and only one record */
                      /* to make sure multiple parents are not created */
                      IF l_pty_cur_rec.relationship_type_code = 'OWNER' THEN

                        SELECT instance_party_id
                        INTO   l_instance_party_id
                        FROM   csi_i_parties
                        WHERE  instance_id = l_td_rec.instance_id
                        AND    relationship_type_code = 'OWNER';

                      ELSE

                        l_instance_party_id := null;

                      END IF;
                  END;

                  -- populate the party table to update the foreign key (instance party id)

                  l_pty_upd_ind := l_pty_upd_ind + 1;

                  l_pty_tbl(l_pty_upd_ind).txn_party_detail_id :=
                                              l_pty_cur_rec.txn_party_detail_id;
                  l_pty_tbl(l_pty_upd_ind).txn_line_detail_id  :=
                            l_pty_cur_rec.txn_line_detail_id;
                  l_pty_tbl(l_pty_upd_ind).instance_party_id   :=
                            l_instance_party_id;
                  l_pty_tbl(l_pty_upd_ind).party_source_table  :=
                            l_pty_cur_rec.party_source_table;
                  l_pty_tbl(l_pty_upd_ind).party_source_id     :=
                            l_pty_cur_rec.party_source_id;
                  l_pty_tbl(l_pty_upd_ind).relationship_type_code :=
                            l_pty_cur_rec.relationship_type_code;
                  l_pty_tbl(l_pty_upd_ind).contact_flag        :=
                            l_pty_cur_rec.contact_flag;
                  l_pty_tbl(l_pty_upd_ind).contact_party_id    :=
                            l_pty_cur_rec.contact_party_id;
                  l_pty_tbl(l_pty_upd_ind).active_start_date   :=
                            l_pty_cur_rec.active_start_date;
                  l_pty_tbl(l_pty_upd_ind).active_end_date     :=
                            l_pty_cur_rec.active_end_date;
                  l_pty_tbl(l_pty_upd_ind).preserve_detail_flag :=
                            l_pty_cur_rec.preserve_detail_flag;
                  l_pty_tbl(l_pty_upd_ind).context    := l_pty_cur_rec.context;
                  l_pty_tbl(l_pty_upd_ind).attribute1 := l_pty_cur_rec.attribute1;
                  l_pty_tbl(l_pty_upd_ind).attribute2 := l_pty_cur_rec.attribute2;
                  l_pty_tbl(l_pty_upd_ind).attribute3 := l_pty_cur_rec.attribute3;
                  l_pty_tbl(l_pty_upd_ind).attribute4 := l_pty_cur_rec.attribute4;
                  l_pty_tbl(l_pty_upd_ind).attribute5 := l_pty_cur_rec.attribute5;
                  l_pty_tbl(l_pty_upd_ind).attribute6 := l_pty_cur_rec.attribute6;
                  l_pty_tbl(l_pty_upd_ind).attribute7 := l_pty_cur_rec.attribute7;
                  l_pty_tbl(l_pty_upd_ind).attribute8 := l_pty_cur_rec.attribute8;
                  l_pty_tbl(l_pty_upd_ind).attribute9 := l_pty_cur_rec.attribute9;
                  l_pty_tbl(l_pty_upd_ind).attribute10:= l_pty_cur_rec.attribute10;
                  l_pty_tbl(l_pty_upd_ind).attribute11:= l_pty_cur_rec.attribute11;
                  l_pty_tbl(l_pty_upd_ind).attribute12:= l_pty_cur_rec.attribute12;
                  l_pty_tbl(l_pty_upd_ind).attribute13:= l_pty_cur_rec.attribute13;
                  l_pty_tbl(l_pty_upd_ind).attribute14:= l_pty_cur_rec.attribute14;
                  l_pty_tbl(l_pty_upd_ind).attribute15:= l_pty_cur_rec.attribute15;
                  l_pty_tbl(l_pty_upd_ind).object_version_number  :=
                            l_pty_cur_rec.object_version_number;
                  l_pty_tbl(l_pty_upd_ind).primary_flag        :=
                            l_pty_cur_rec.primary_flag;
                  l_pty_tbl(l_pty_upd_ind).preferred_flag        :=
                            l_pty_cur_rec.preferred_flag;

                ELSE
                  -- delete the non preserved children for parties
                  l_pty_ind := l_pty_ind + 1;

                  l_pty_acct_ids_tbl(l_pty_ind).txn_party_detail_id :=
                     l_pty_cur_rec.txn_party_detail_id;
                  l_pty_acct_ids_tbl(l_pty_ind).txn_account_detail_id :=
                     fnd_api.g_miss_num;

                  l_pty_ids_tbl(l_pty_ind).txn_line_detail_id :=
                     l_pty_cur_rec.txn_line_detail_id;
                  l_pty_ids_tbl(l_pty_ind).txn_party_detail_id :=
                     l_pty_cur_rec.txn_party_detail_id;

                END IF;

              END LOOP;

              IF l_pty_tbl.count > 0 THEN

                csi_t_txn_parties_grp.update_txn_party_dtls(
                  p_api_version              => p_api_version,
                  p_commit                   => p_commit,
                  p_init_msg_list            => p_init_msg_list,
                  p_validation_level         => p_validation_level,
                  p_txn_party_detail_tbl     => l_pty_tbl,
                  px_txn_pty_acct_detail_tbl => l_pty_acc_tbl,
                  x_return_status            => l_return_status,
                  x_msg_count                => l_msg_count,
                  x_msg_data                 => l_msg_data);

                IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
                END IF;

              END IF;

            END IF;

            -- ii_relationships
            IF (l_td_rec.instance_id <> nvl(l_td_cur_rec.instance_id, fnd_api.g_miss_num))
               OR
               (l_td_rec.inventory_item_id <> nvl(l_td_cur_rec.inventory_item_id, fnd_api.g_miss_num))
            THEN

              IF nvl(l_td_cur_rec.instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
                l_iir_ids_tbl(1).transaction_line_id := l_td_rec.transaction_line_id;
                l_iir_ids_tbl(1).txn_relationship_id := fnd_api.g_miss_num;
              END IF;

            END IF;

            -- org assignments
            l_oa_ind := 0;

            IF (l_td_rec.instance_id <> nvl(l_td_cur_rec.instance_id, fnd_api.g_miss_num))
            THEN

              FOR l_oa_cur_rec IN oa_cur(l_td_rec.txn_line_detail_id)
              LOOP

                IF nvl(l_td_cur_rec.instance_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
                  l_preserve_detail_flag := 'Y';
                ELSE
                  l_preserve_detail_flag := nvl(l_oa_cur_rec.preserve_detail_flag,'N');
                END IF;

                IF l_preserve_detail_flag = 'Y' THEN
                  IF nvl(l_oa_cur_rec.instance_ou_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
                  THEN
                    BEGIN

                      SELECT instance_ou_id
                      INTO   l_instance_ou_id
                      FROM   csi_i_org_assignments
                      WHERE  instance_id = l_td_rec.instance_id
                      AND    operating_unit_id = l_oa_cur_rec.operating_unit_id;

                     EXCEPTION
                       WHEN no_data_found THEN
                         l_instance_ou_id := null;
                     END;

                     UPDATE csi_t_org_assignments
                     SET    instance_ou_id = l_instance_ou_id
                     WHERE  txn_operating_unit_id = l_oa_cur_rec.txn_operating_unit_id;

                  END IF;
                ELSE

                  l_oa_ind := l_oa_ind + 1;

                  l_oa_ids_tbl(l_oa_ind).txn_line_detail_id :=
                    l_oa_cur_rec.txn_line_detail_id;
                  l_oa_ids_tbl(l_oa_ind).txn_operating_unit_id :=
                    l_oa_cur_rec.txn_operating_unit_id;

                END IF;

              END LOOP;

            END IF;

            -- extended attributes
            l_ea_ind := 0;

            IF (l_td_rec.instance_id <> nvl(l_td_cur_rec.instance_id, fnd_api.g_miss_num))
            THEN

              FOR l_ea_cur_rec IN ea_cur(l_td_rec.txn_line_detail_id)
              LOOP

                IF nvl(l_td_cur_rec.instance_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
                  l_preserve_detail_flag := 'Y';
                ELSE
                  l_preserve_detail_flag := nvl(l_ea_cur_rec.preserve_detail_flag,'N');
                END IF;

                IF l_preserve_detail_flag = 'Y' THEN

                  IF l_ea_cur_rec.attrib_source_table = 'CSI_IEA_VALUES' THEN

                    BEGIN

                      SELECT attribute_value_id
                      INTO   l_attrib_source_id
                      FROM   csi_iea_values
                      WHERE  instance_id     = l_td_rec.instance_id
                      AND    attribute_value = l_ea_cur_rec.attribute_value;

                      UPDATE csi_t_extend_attribs
                      SET    attrib_source_id = l_attrib_source_id
                      WHERE  txn_attrib_detail_id =
                             l_ea_cur_rec.txn_attrib_detail_id;

                    EXCEPTION
                      WHEN no_data_found THEN
                        l_ea_ind := l_ea_ind + 1;

                        l_ea_ids_tbl(l_ea_ind).txn_line_detail_id :=
                          l_ea_cur_rec.txn_line_detail_id;
                        l_ea_ids_tbl(l_ea_ind).txn_attrib_detail_id :=
                          l_ea_cur_rec.txn_attrib_detail_id;
                    END;

                  END IF;

                ELSE
                  l_ea_ind := l_ea_ind + 1;

                  l_ea_ids_tbl(l_ea_ind).txn_line_detail_id :=
                    l_ea_cur_rec.txn_line_detail_id;
                  l_ea_ids_tbl(l_ea_ind).txn_attrib_detail_id :=
                    l_ea_cur_rec.txn_attrib_detail_id;
                END IF;

              END LOOP;

            END IF;

          END IF;

          IF l_pty_ids_tbl.COUNT > 0 THEN

            csi_t_txn_parties_pvt.delete_txn_party_dtls(
              p_api_version          => p_api_version,
              p_commit               => p_commit,
              p_init_msg_list        => p_init_msg_list,
              p_validation_level     => p_validation_level,
              p_txn_party_ids_tbl    => l_pty_ids_tbl,
              x_txn_pty_acct_ids_tbl => l_x_pty_acct_ids_tbl,
              x_return_status        => l_return_status,
              x_msg_count            => l_msg_count,
              x_msg_data             => l_msg_data);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              raise fnd_api.g_exc_error;
            END IF;

          END IF;

          IF l_pty_acct_ids_tbl.COUNT > 0 THEN

            csi_t_txn_parties_pvt.delete_txn_pty_acct_dtls(
              p_api_version          => p_api_version,
              p_commit               => p_commit,
              p_init_msg_list        => p_init_msg_list,
              p_validation_level     => p_validation_level,
              p_txn_pty_acct_ids_tbl => l_pty_acct_ids_tbl,
              x_return_status        => l_return_status,
              x_msg_count            => l_msg_count,
              x_msg_data             => l_msg_data);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              raise fnd_api.g_exc_error;
            END IF;

          END IF;

          IF l_iir_ids_tbl.COUNT > 0 THEN

            csi_t_txn_rltnshps_pvt.delete_txn_ii_rltns_dtls(
              p_api_version          => p_api_version,
              p_commit               => p_commit,
              p_init_msg_list        => p_init_msg_list,
              p_validation_level     => p_validation_level,
              p_txn_ii_rltns_ids_tbl => l_iir_ids_tbl,
              x_return_status        => l_return_status,
              x_msg_count            => l_msg_count,
              x_msg_data             => l_msg_data);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              raise fnd_api.g_exc_error;
            END IF;

          END IF;

          IF l_oa_ids_tbl.COUNT > 0 THEN

            csi_t_txn_ous_pvt.delete_txn_org_assgn_dtls(
              p_api_version           => p_api_version,
              p_commit                => p_commit,
              p_init_msg_list         => p_init_msg_list,
              p_validation_level      => p_validation_level,
              p_txn_org_assgn_ids_tbl => l_oa_ids_tbl,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg_data);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              raise fnd_api.g_exc_error;
            END IF;

          END IF;

          IF l_ea_ids_tbl.COUNT > 0 THEN

            csi_t_txn_attribs_pvt.delete_txn_ext_attrib_dtls(
              p_api_version            => p_api_version,
              p_commit                 => p_commit,
              p_init_msg_list          => p_init_msg_list,
              p_validation_level       => p_validation_level,
              p_txn_ext_attrib_ids_tbl => l_ea_ids_tbl,
              x_return_status          => l_return_status,
              x_msg_count              => l_msg_count,
              x_msg_data               => l_msg_data);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              raise fnd_api.g_exc_error;
            END IF;

          END IF;


    -- Added the below IF for bug 2563265
          IF nvl(l_td_rec.serial_number, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
           IF nvl(l_td_rec.instance_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
            Begin
	       Select serial_number, instance_id, lot_number
	       Into l_td_rec.serial_number, l_td_rec.instance_id,
		       l_td_rec.lot_number
	       From csi_item_instances
	       Where inventory_item_id = l_td_rec.inventory_item_id
	         and serial_number = l_td_rec.serial_number;
	       Exception when others then
               null;-- do nothing. This is just to sync instance data on the tld rec...
            End;
	   END IF;

          ELSIF nvl(l_td_rec.instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
	    Begin
	       Select serial_number, instance_id, lot_number
	       Into l_td_rec.serial_number, l_td_rec.instance_id,
		       l_td_rec.lot_number
	       From csi_item_instances
	       Where instance_id = l_td_rec.instance_id;
	       Exception when others then
               null;-- do nothing. This should not arise though.
            End;
          END IF;

          begin

            csi_t_gen_utility_pvt.dump_api_info(
              p_api_name => 'update_row',
              p_pkg_name => 'csi_t_txn_line_details_pkg');

            csi_t_txn_line_details_pkg.update_row(
              p_txn_line_detail_id      => l_td_rec.txn_line_detail_id,
              p_transaction_line_id     => l_td_rec.transaction_line_id,
              p_sub_type_id             => l_td_rec.sub_type_id,
              p_instance_exists_flag    => l_td_rec.instance_exists_flag,
              p_source_transaction_flag => l_td_rec.source_transaction_flag,
              p_instance_id             => l_td_rec.instance_id,
              p_csi_system_id           => l_td_rec.csi_system_id,
              p_inventory_item_id       => l_td_rec.inventory_item_id,
              p_inv_organization_id     => l_td_rec.inv_organization_id,
              p_inventory_revision      => l_td_rec.inventory_revision,
              p_instance_type_code      => l_td_rec.instance_type_code,
              p_item_condition_id       => l_td_rec.item_condition_id,
              p_quantity                => l_td_rec.quantity,
              p_unit_of_measure         => l_td_rec.unit_of_measure,
              p_qty_remaining           => l_td_rec.qty_remaining,
              p_serial_number           => l_td_rec.serial_number,
              p_lot_number              => l_td_rec.lot_number,
              p_mfg_serial_number_flag  => l_td_rec.mfg_serial_number_flag,
              p_location_type_code      => l_td_rec.location_type_code,
              p_location_id             => l_td_rec.location_id,
              p_installation_date       => l_td_rec.installation_date,
              p_in_service_date         => l_td_rec.in_service_date,
              p_external_reference      => l_td_rec.external_reference,
              p_version_label           => l_td_rec.version_label,
              p_transaction_system_id   => l_td_rec.transaction_system_id,
              p_sellable_flag           => l_td_rec.sellable_flag,
              p_return_by_date          => l_td_rec.return_by_date,
              p_active_start_date       => l_td_rec.active_start_date,
              p_active_end_date         => l_td_rec.active_end_date,
              p_preserve_detail_flag    => l_td_rec.preserve_detail_flag,
              p_changed_instance_id     => l_td_rec.changed_instance_id,
              p_reference_source_id     => l_td_rec.reference_source_id,
              p_reference_source_line_id  => l_td_rec.reference_source_line_id,
              p_reference_source_date   => l_td_rec.reference_source_date,
              p_csi_transaction_id      => l_td_rec.csi_transaction_id,
              p_source_txn_line_detail_id => l_td_rec.source_txn_line_detail_id,
              p_inv_mtl_transaction_id  => l_td_rec.inv_mtl_transaction_id,
              p_processing_status       => l_td_rec.processing_status,
              p_error_code              => l_td_rec.error_code,
              p_error_explanation       => l_td_rec.error_explanation,
             -- Added for CZ Integration (Begin)
              p_config_inst_hdr_id      => l_td_rec.config_inst_hdr_id ,
              p_config_inst_rev_num     => l_td_rec.config_inst_rev_num ,
              p_config_inst_item_id    => l_td_rec.config_inst_item_id ,
              p_config_inst_baseline_rev_num    => l_td_rec.config_inst_baseline_rev_num ,
              p_target_commitment_date    => l_td_rec.target_commitment_date ,
              p_instance_description    => l_td_rec.instance_description ,
             -- Added for CZ Integration (End)
             -- Added for partner ordering
              p_install_location_type_code      => l_td_rec.install_location_type_code,
              p_install_location_id             => l_td_rec.install_location_id,
             -- Added for partner ordering
              p_cascade_owner_flag      => l_td_rec.cascade_owner_flag,
              p_attribute1              => l_td_rec.attribute1,
              p_attribute2              => l_td_rec.attribute2,
              p_attribute3              => l_td_rec.attribute3,
              p_attribute4              => l_td_rec.attribute4,
              p_attribute5              => l_td_rec.attribute5,
              p_attribute6              => l_td_rec.attribute6,
              p_attribute7              => l_td_rec.attribute7,
              p_attribute8              => l_td_rec.attribute8,
              p_attribute9              => l_td_rec.attribute9,
              p_attribute10             => l_td_rec.attribute10,
              p_attribute11             => l_td_rec.attribute11,
              p_attribute12             => l_td_rec.attribute12,
              p_attribute13             => l_td_rec.attribute13,
              p_attribute14             => l_td_rec.attribute14,
              p_attribute15             => l_td_rec.attribute15,
              p_created_by              => l_td_rec.created_by,
              p_creation_date           => l_td_rec.creation_date,
              p_last_updated_by         => l_td_rec.last_updated_by,
              p_last_update_date        => l_td_rec.last_update_date,
              p_last_update_login       => l_td_rec.last_update_login,
              p_object_version_number   => l_td_rec.object_version_number,
              p_context                 => l_td_rec.context,
              p_parent_instance_id      => l_td_rec.parent_instance_id,
              p_assc_txn_line_detail_id => l_td_rec.assc_txn_line_detail_id,
              p_overriding_csi_txn_id   => l_td_rec.overriding_csi_txn_id,
              p_instance_status_id      => l_td_rec.instance_status_id);
          exception
            when others then
              fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
              fnd_message.set_token('MESSAGE',
                 'csi_t_txn_line_details_pkg.update_row Failed. '||substr(sqlerrm,1,200));
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
          end;

        END LOOP;

      END LOOP;

      -- call grp api for parties

      IF px_txn_party_detail_tbl.COUNT > 0 THEN

        debug('Found party records for processing.'||px_txn_party_detail_tbl.COUNT);

        l_c_pty_ind := 0;
        l_u_pty_ind := 0;
       -- Added for self bug, Mass update , Acct tables are not build or passed below
        l_c_pa_ind  := 0;
        l_u_pa_ind  := 0;

        l_contact_party_index  := 'N' ;
        l_tmp_party_detail_tbl := px_txn_party_detail_tbl;
        FOR l_ind IN px_txn_party_detail_tbl.FIRST .. px_txn_party_detail_tbl.LAST
        LOOP

          IF nvl(px_txn_party_detail_tbl(l_ind).txn_party_detail_id, fnd_api.g_miss_num) =
             fnd_api.g_miss_num
          THEN
            -- new attribute added in R12
            IF nvl(px_txn_party_detail_tbl(l_ind).txn_contact_party_index, fnd_api.g_miss_num)
                  <> fnd_api.g_miss_num
            THEN
                l_contact_party_index  := 'Y' ;
            END IF;
            IF px_txn_pty_acct_detail_tbl.count > 0 THEN
             FOR m_ind IN px_txn_pty_acct_detail_tbl.FIRST .. px_txn_pty_acct_detail_tbl.LAST
             LOOP
              IF ( (nvl(px_txn_pty_acct_detail_tbl(m_ind).txn_account_detail_id,fnd_api.g_miss_num)
                     = fnd_api.g_miss_num)  AND
                   (nvl(px_txn_pty_acct_detail_tbl(m_ind).txn_party_detail_id,fnd_api.g_miss_num)
                     = fnd_api.g_miss_num)  AND
                   ( px_txn_pty_acct_detail_tbl(m_ind).txn_party_details_index = l_ind )
                 )
              THEN
                l_c_pty_acct_tbl(l_c_pa_ind ) := px_txn_pty_acct_detail_tbl(m_ind);
                l_c_pty_acct_tbl(l_c_pa_ind).txn_party_details_index := l_c_pty_ind;
                l_c_pa_ind  := l_c_pa_ind  + 1;

              END IF;
             END LOOP; -- acct tbl loop
            END IF; --acct tbl.count
            -- Resetting the Transaction Party Contacts table
            l_tmp_party_detail_tbl := px_txn_party_detail_tbl;

            FOR con_ind IN l_tmp_party_detail_tbl.FIRST .. l_tmp_party_detail_tbl.LAST
            LOOP
              IF nvl(l_tmp_party_detail_tbl(con_ind).txn_party_detail_id,fnd_api.g_miss_num) = fnd_api.g_miss_num
               AND nvl(l_tmp_party_detail_tbl(con_ind).contact_party_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
               AND nvl(l_tmp_party_detail_tbl(con_ind).contact_flag, 'N') = 'Y' THEN
                IF nvl(px_txn_party_detail_tbl(l_ind).txn_contact_party_index,fnd_api.g_miss_num) <> fnd_api.g_miss_num
                 AND ( nvl(px_txn_party_detail_tbl(l_ind).contact_flag,fnd_api.g_miss_char) = fnd_api.g_miss_char
                       OR nvl(px_txn_party_detail_tbl(l_ind).contact_flag,'N') = 'N') THEN
                  IF l_tmp_party_detail_tbl(con_ind).contact_party_id
                     = px_txn_party_detail_tbl(l_ind).txn_contact_party_index THEN

                     l_tmp_party_detail_tbl(con_ind).contact_party_id := l_c_pty_ind;
                  END IF;
                END IF;
              END IF;
            END LOOP;

            px_txn_party_detail_tbl := l_tmp_party_detail_tbl;

            IF nvl(px_txn_party_detail_tbl(l_ind).txn_contact_party_index,fnd_api.g_miss_num) <> fnd_api.g_miss_num
              AND ( nvl(px_txn_party_detail_tbl(l_ind).contact_flag, fnd_api.g_miss_char) = fnd_api.g_miss_char
                OR nvl(px_txn_party_detail_tbl(l_ind).contact_flag, 'N') = 'N')
            THEN
                px_txn_party_detail_tbl(l_ind).txn_contact_party_index := l_c_pty_ind;
            END IF;

            l_tmp_party_detail_tbl := px_txn_party_detail_tbl;
            l_c_pty_tbl(l_c_pty_ind) := px_txn_party_detail_tbl(l_ind);
            l_c_pty_ind := l_c_pty_ind + 1;
          ELSE
            debug('PTY Record No.: '||l_ind||' marked for update.');
            l_u_pty_tbl(l_u_pty_ind) := px_txn_party_detail_tbl(l_ind);
            IF px_txn_pty_acct_detail_tbl.count > 0 THEN
              FOR n_ind IN px_txn_pty_acct_detail_tbl.FIRST .. px_txn_pty_acct_detail_tbl.LAST
              LOOP
               IF ( (nvl(px_txn_pty_acct_detail_tbl(n_ind).txn_party_detail_id,fnd_api.g_miss_num)
                     <> fnd_api.g_miss_num)
                              AND
                    ( px_txn_pty_acct_detail_tbl(n_ind).txn_party_detail_id
                          = l_u_pty_tbl(l_u_pty_ind).txn_party_detail_id )
                  ) THEN

                    l_u_pty_acct_tbl(l_u_pa_ind ) := px_txn_pty_acct_detail_tbl(n_ind);
                    l_u_pa_ind  := l_u_pa_ind  + 1;
               END IF;
              END LOOP; -- acct loop
            END IF; -- acct tbl.count

            l_u_pty_ind := l_u_pty_ind + 1;

          END IF; -- update/create pty
        END LOOP;

        IF l_c_pty_tbl.COUNT > 0 THEN

          csi_t_txn_parties_grp.create_txn_party_dtls(
            p_api_version              => p_api_version,
            p_commit                   => p_commit,
            p_init_msg_list            => p_init_msg_list,
            p_validation_level         => p_validation_level,
            px_txn_party_detail_tbl    => l_c_pty_tbl,
            px_txn_pty_acct_detail_tbl => l_c_pty_acct_tbl,
            x_return_status            => l_return_status,
            x_msg_count                => l_msg_count,
            x_msg_data                 => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          -- we now need this code below for those cases where it is a new contact for an existing
          --txn pty detail , since for the rest of it, this is taken care of in the Party GRP
          -- need to assign the entire set of passed pty records

          l_tmp_party_dtl_tbl := l_tmp_party_detail_tbl;--px_txn_party_detail_tbl;

          --          process the contact party id
          FOR cont_ind IN l_c_pty_tbl.FIRST .. l_c_pty_tbl.LAST
          LOOP
            IF nvl(l_c_pty_tbl(cont_ind).contact_party_id, fnd_api.g_miss_num) <>
               fnd_api.g_miss_num AND l_c_pty_tbl(cont_ind).contact_flag = 'Y'
            THEN
              IF nvl(l_contact_party_index, 'N') = 'Y' THEN
                l_contact_party_id := null;
                FOR p_ind IN l_tmp_party_dtl_tbl.FIRST .. l_tmp_party_dtl_tbl.LAST
                LOOP
                  IF ( l_tmp_party_dtl_tbl(p_ind).txn_contact_party_index is not null
                    AND l_tmp_party_dtl_tbl(p_ind).txn_contact_party_index <>  fnd_api.g_miss_num )
                  THEN
                       --do nothing 'cause the creates are already handled in the Party Grp
                       null;
                  ELSIF l_tmp_party_dtl_tbl(p_ind).txn_party_detail_id = l_c_pty_tbl(cont_ind).contact_party_id
                      AND ( nvl(l_tmp_party_dtl_tbl(p_ind).contact_flag,fnd_api.g_miss_char) = fnd_api.g_miss_char
                            OR nvl(l_tmp_party_dtl_tbl(p_ind).contact_flag,'N') = 'N')  THEN
                       l_contact_party_id := l_tmp_party_dtl_tbl(p_ind).txn_party_detail_id;
                       exit;
                  END IF;
                END LOOP;
              ELSE
                 l_contact_party_id := null;
                 FOR p_ind IN l_tmp_party_dtl_tbl.FIRST .. l_tmp_party_dtl_tbl.LAST
                 LOOP
                   IF p_ind = l_c_pty_tbl(cont_ind).contact_party_id
                     AND ( nvl(l_tmp_party_dtl_tbl(p_ind).contact_flag,fnd_api.g_miss_char) = fnd_api.g_miss_char
                          OR nvl(l_tmp_party_dtl_tbl(p_ind).contact_flag,'N') = 'N' )
                   THEN
                     --do nothing 'cause the creates are already handled in the Party Grp
                       null;
                   ELSIF l_tmp_party_dtl_tbl(p_ind).txn_party_detail_id = l_c_pty_tbl(cont_ind).contact_party_id
                       AND ( nvl(l_tmp_party_dtl_tbl(p_ind).contact_flag,fnd_api.g_miss_char) = fnd_api.g_miss_char
                            OR nvl(l_tmp_party_dtl_tbl(p_ind).contact_flag,'N') = 'N' ) THEN
                      l_contact_party_id := l_tmp_party_dtl_tbl(p_ind).txn_party_detail_id;
                      exit;
                   END IF;
                 END LOOP;
              END IF;

              IF l_contact_party_id is not null THEN
                  update csi_t_party_details
                  set    contact_party_id    = l_contact_party_id
                  where  txn_party_detail_id = l_c_pty_tbl(cont_ind).txn_party_detail_id;
              END IF;
            END IF;
          END LOOP;
        END IF;

        IF l_u_pty_tbl.COUNT > 0 THEN

          csi_t_txn_parties_grp.update_txn_party_dtls(
            p_api_version              => p_api_version,
            p_commit                   => p_commit,
            p_init_msg_list            => p_init_msg_list,
            p_validation_level         => p_validation_level,
            p_txn_party_detail_tbl     => l_u_pty_tbl,
            px_txn_pty_acct_detail_tbl => l_u_pty_acct_tbl,
            x_return_status            => l_return_status,
            x_msg_count                => l_msg_count,
            x_msg_data                 => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

      END IF; -- pty tbl.count

      -- call grp api for ii_relationships
      IF px_txn_ii_rltns_tbl.COUNT > 0 THEN

        debug('Found ii relationships for processing.');

        l_c_ii_ind := 0;
        l_u_ii_ind := 0;

        FOR l_ind IN px_txn_ii_rltns_tbl.FIRST .. px_txn_ii_rltns_tbl.LAST
        LOOP
          IF nvl(px_txn_ii_rltns_tbl(l_ind).txn_relationship_id, fnd_api.g_miss_num) =
             fnd_api.g_miss_num
          THEN
            debug('RLTNS Record No.: '||l_ind||' marked for create.');
            l_c_ii_tbl(l_ind) := px_txn_ii_rltns_tbl(l_ind);
            l_c_ii_ind := l_c_ii_ind + 1;

          ELSE
            debug('RLTNS Record No.: '||l_ind||' marked for update.');
            l_u_ii_tbl(l_ind) := px_txn_ii_rltns_tbl(l_ind);
            l_u_ii_ind := l_u_ii_ind + 1;
          END IF;

        END LOOP;

        IF l_c_ii_tbl.COUNT > 0 THEN

          csi_t_txn_rltnshps_grp.create_txn_ii_rltns_dtls(
            p_api_version       => p_api_version,
            p_commit            => p_commit,
            p_init_msg_list     => p_init_msg_list,
            p_validation_level  => p_validation_level,
            px_txn_ii_rltns_tbl => l_c_ii_tbl,
            x_return_status     => l_return_status,
            x_msg_count         => l_msg_count,
            x_msg_data          => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;

        IF l_u_ii_tbl.COUNT > 0 THEN

          csi_t_txn_rltnshps_grp.update_txn_ii_rltns_dtls (
            p_api_version      => p_api_version,
            p_commit           => p_commit,
            p_init_msg_list    => p_init_msg_list,
            p_validation_level => p_validation_level,
            p_txn_ii_rltns_tbl => l_u_ii_tbl,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;

      END IF;

      -- call grp api for org_assignments
      IF px_txn_org_assgn_tbl.COUNT > 0 THEN

        debug('Found org assignments records for processing.');
        l_c_oa_ind := 0;
        l_u_oa_ind := 0;

        FOR l_ind IN px_txn_org_assgn_tbl.FIRST .. px_txn_org_assgn_tbl.LAST
        LOOP

          IF nvl(px_txn_org_assgn_tbl(l_ind).txn_operating_unit_id, fnd_api.g_miss_num) =
             fnd_api.g_miss_num
          THEN
            debug('ORG Record No.: '||l_ind||' marked for create.');
            l_c_oa_tbl(l_c_oa_ind) := px_txn_org_assgn_tbl(l_ind);
            l_c_oa_ind := l_c_oa_ind + 1;

          ELSE
            debug('ORG Record No.: '||l_ind||' marked for update.');
            l_u_oa_tbl(l_u_oa_ind) := px_txn_org_assgn_tbl(l_ind);
            l_u_oa_ind := l_u_oa_ind + 1;
          END IF;

        END LOOP;

        IF l_c_oa_tbl.COUNT > 0 THEN

          csi_t_txn_ous_grp.create_txn_org_assgn_dtls(
            p_api_version        => p_api_version,
            p_commit             => p_commit,
            p_init_msg_list      => p_init_msg_list,
            p_validation_level   => p_validation_level,
            px_txn_org_assgn_tbl => l_c_oa_tbl,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;

        IF l_u_oa_tbl.COUNT > 0 THEN

          csi_t_txn_ous_grp.update_txn_org_assgn_dtls(
            p_api_version          => p_api_version,
            p_commit               => p_commit,
            p_init_msg_list        => p_init_msg_list,
            p_validation_level     => p_validation_level,
            p_txn_org_assgn_tbl    => l_u_oa_tbl,
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

      END IF;

      -- call grp api for ext attribs
      IF px_txn_ext_attrib_vals_tbl.COUNT > 0 THEN

        debug('Found extended attributes to be processed.');
        l_u_ea_ind := 0;

        FOR l_ind IN px_txn_ext_attrib_vals_tbl.FIRST .. px_txn_ext_attrib_vals_tbl.LAST
        LOOP

          IF nvl(px_txn_ext_attrib_vals_tbl(l_ind).txn_attrib_detail_id,fnd_api.g_miss_num)
             = fnd_api.g_miss_num
          THEN

            debug('EAV Record No.: '||l_ind||' marked for create.');

            csi_t_txn_attribs_pvt.create_txn_ext_attrib_dtls(
              p_api_version             => p_api_version,
              p_commit                  => p_commit,
              p_init_msg_list           => p_init_msg_list,
              p_validation_level        => p_validation_level,
              p_txn_ext_attrib_vals_rec => px_txn_ext_attrib_vals_tbl(l_ind),
              x_return_status           => l_return_status,
              x_msg_count               => l_msg_count,
              x_msg_data                => l_msg_data);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSE

            debug('EAV Record No.: '||l_ind||' marked for update.');

            l_u_eav_tbl(l_u_ea_ind) := px_txn_ext_attrib_vals_tbl(l_ind);
            l_u_ea_ind := l_u_ea_ind + 1;

          END IF;

        END LOOP;

        IF l_u_eav_tbl.COUNT > 0 THEN

          csi_t_txn_attribs_pvt.update_txn_ext_attrib_dtls(
            p_api_version             => p_api_version,
            p_commit                  => p_commit,
            p_init_msg_list           => p_init_msg_list,
            p_validation_level        => p_validation_level,
            p_txn_ext_attrib_vals_tbl => l_u_eav_tbl,
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

        END IF;

      END IF;

    END IF;

    debug('Transaction details updated successfully.');

    -- Standard check of p_commit.
    IF fnd_api.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    fnd_msg_pub.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN

      ROLLBACK TO update_txn_line_dtls;
      x_return_status := fnd_api.g_ret_sts_error ;
      fnd_msg_pub.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK TO update_txn_line_dtls;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;

      fnd_msg_pub.count_and_get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO Update_Txn_Line_Dtls;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;

      IF fnd_msg_pub.Check_Msg_Level(
           p_message_level => fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN

        fnd_msg_pub.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      fnd_msg_pub.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END update_txn_line_dtls;

  PROCEDURE bind_query_variables(
    p_dtl_qry_cur_id             in  integer,
    p_txn_line_query_rec         in  csi_t_datastructures_grp.txn_line_query_rec,
    p_txn_line_detail_query_rec  in  csi_t_datastructures_grp.txn_line_detail_query_rec,
    x_return_status              OUT NOCOPY varchar2)
  IS
  BEGIN

    api_log('bind_query_variables');

    x_return_status := fnd_api.g_ret_sts_success;

    -- transaction lines variables bind
    IF nvl(p_txn_line_query_rec.transaction_line_id,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'transaction_line_id',
                         p_txn_line_query_rec.transaction_line_id);
    END IF;

    IF nvl(p_txn_line_query_rec.source_txn_header_id,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'source_txn_header_id',
                         p_txn_line_query_rec.source_txn_header_id);
    END IF;

    IF nvl(p_txn_line_query_rec.source_transaction_id,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'source_transaction_id',
                         p_txn_line_query_rec.source_transaction_id);
    END IF;

    IF nvl(p_txn_line_query_rec.source_transaction_table,fnd_api.g_miss_char) <>
       fnd_api.g_miss_char THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'source_transaction_table',
                           p_txn_line_query_rec.source_transaction_table);
    END IF;

    IF nvl(p_txn_line_query_rec.error_code,fnd_api.g_miss_char) <>
       fnd_api.g_miss_char THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'error_code',
                           p_txn_line_query_rec.error_code);
    END IF;

    IF nvl(p_txn_line_query_rec.processing_status,fnd_api.g_miss_char) <>
       fnd_api.g_miss_char THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'processing_status',
                           p_txn_line_query_rec.processing_status);
    END IF;

    IF nvl(p_txn_line_query_rec.config_session_hdr_id,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'config_session_hdr_id',
                           p_txn_line_query_rec.config_session_hdr_id);
    END IF;

    IF nvl(p_txn_line_query_rec.config_session_rev_num,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'config_session_rev_num',
                           p_txn_line_query_rec.config_session_rev_num);
    END IF;

    IF nvl(p_txn_line_query_rec.config_session_item_id,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'config_session_item_id',
                           p_txn_line_query_rec.config_session_item_id);
    END IF;

    -- txn_line details variables bind

    IF nvl(p_txn_line_detail_query_rec.transaction_line_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN
       dbms_sql.bind_variable(p_dtl_qry_cur_id, 'dtl_transaction_line_id',
          p_txn_line_detail_query_rec.transaction_line_id);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.txn_line_detail_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'txn_line_detail_id',
                         p_txn_line_detail_query_rec.txn_line_detail_id);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.sub_type_id,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'sub_type_id',
                         p_txn_line_detail_query_rec.sub_type_id);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.instance_exists_flag, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'instance_exists_flag',
                           p_txn_line_detail_query_rec.instance_exists_flag);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.instance_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'instance_id',
                         p_txn_line_detail_query_rec.instance_id);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.csi_transaction_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'csi_transaction_id',
                         p_txn_line_detail_query_rec.csi_transaction_id);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.source_transaction_flag, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'source_transaction_flag',
                           p_txn_line_detail_query_rec.source_transaction_flag);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.csi_system_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'csi_system_id',
                         p_txn_line_detail_query_rec.csi_system_id);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.transaction_system_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'transaction_system_id',
                      p_txn_line_detail_query_rec.transaction_system_id);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.inventory_item_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'inventory_item_id',
                      p_txn_line_detail_query_rec.inventory_item_id);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.inventory_revision, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'inventory_revision',
                           p_txn_line_detail_query_rec.inventory_revision);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.inv_organization_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'inv_organization_id',
                      p_txn_line_detail_query_rec.inv_organization_id);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.serial_number, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'serial_number',
                           p_txn_line_detail_query_rec.serial_number);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.mfg_serial_number_flag, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'mfg_serial_number_flag',
                           p_txn_line_detail_query_rec.mfg_serial_number_flag);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.lot_number, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'lot_number',
                           p_txn_line_detail_query_rec.lot_number);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.location_type_code, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'location_type_code',
                           p_txn_line_detail_query_rec.location_type_code);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.external_reference, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'external_reference',
                           p_txn_line_detail_query_rec.external_reference);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.error_code, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'dtl_error_code',
                           p_txn_line_detail_query_rec.error_code);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.error_explanation, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'dtl_error_explanation',
                           p_txn_line_detail_query_rec.error_explanation);
    END IF;

    IF nvl(p_txn_line_detail_query_rec.return_by_date, fnd_api.g_miss_date) <>
       fnd_api.g_miss_date
    THEN
      dbms_sql.bind_variable(p_dtl_qry_cur_id,'return_by_date',
                           p_txn_line_detail_query_rec.return_by_date);
    END IF;

  EXCEPTION
    WHEN others THEN
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE',substr(sqlerrm, 1, 255));
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;

  END bind_query_variables;

  PROCEDURE get_dtls_dynamic(
    p_txn_line_query_rec        IN  csi_t_datastructures_grp.txn_line_query_rec,
    p_txn_line_detail_query_rec IN  csi_t_datastructures_grp.txn_line_detail_query_rec,
    p_dtl_select_stmt           IN  varchar2,
    x_line_dtls_tbl             OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status             OUT NOCOPY varchar2)
  IS

    l_dtl_qry_cur_id    integer;
    l_dtl_qry_cur_rows  number;
    l_line_dtl_rec      csi_t_datastructures_grp.txn_line_detail_rec;
    l_processed_rows    number := 0;
    l_ind               binary_integer;
    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    api_log('get_dtls_dynamic');

    l_dtl_qry_cur_id := dbms_sql.open_cursor;

    dbms_sql.parse(l_dtl_qry_cur_id, p_dtl_select_stmt , dbms_sql.native);

    bind_query_variables(
      p_dtl_qry_cur_id            => l_dtl_qry_cur_id,
      p_txn_line_query_rec        => p_txn_line_query_rec,
      p_txn_line_detail_query_rec => p_txn_line_detail_query_rec,
      x_return_status             => l_return_status);

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    dbms_sql.define_column(l_dtl_qry_cur_id, 1, l_line_dtl_rec.txn_line_detail_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 2, l_line_dtl_rec.transaction_line_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 3, l_line_dtl_rec.sub_type_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 4, l_line_dtl_rec.instance_exists_flag, 1);
    dbms_sql.define_column(l_dtl_qry_cur_id, 5, l_line_dtl_rec.source_transaction_flag,1);
    dbms_sql.define_column(l_dtl_qry_cur_id, 6, l_line_dtl_rec.instance_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 7, l_line_dtl_rec.changed_instance_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 8, l_line_dtl_rec.csi_system_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 9, l_line_dtl_rec.inventory_item_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 10, l_line_dtl_rec.inventory_revision,3);
    dbms_sql.define_column(l_dtl_qry_cur_id, 11, l_line_dtl_rec.inv_organization_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 12, l_line_dtl_rec.item_condition_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 13, l_line_dtl_rec.instance_type_code, 30);
    dbms_sql.define_column(l_dtl_qry_cur_id, 14, l_line_dtl_rec.quantity);
    dbms_sql.define_column(l_dtl_qry_cur_id, 15, l_line_dtl_rec.unit_of_measure,3);
    dbms_sql.define_column(l_dtl_qry_cur_id, 16, l_line_dtl_rec.qty_remaining);
    dbms_sql.define_column(l_dtl_qry_cur_id, 17, l_line_dtl_rec.serial_number,30);
    dbms_sql.define_column(l_dtl_qry_cur_id, 18, l_line_dtl_rec.mfg_serial_number_flag,1);
    dbms_sql.define_column(l_dtl_qry_cur_id, 19, l_line_dtl_rec.lot_number,80);
    dbms_sql.define_column(l_dtl_qry_cur_id, 20, l_line_dtl_rec.location_type_code,30);
    dbms_sql.define_column(l_dtl_qry_cur_id, 21, l_line_dtl_rec.location_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 22, l_line_dtl_rec.installation_date);
    dbms_sql.define_column(l_dtl_qry_cur_id, 23, l_line_dtl_rec.in_service_date);
    dbms_sql.define_column(l_dtl_qry_cur_id, 24, l_line_dtl_rec.external_reference,30);
    dbms_sql.define_column(l_dtl_qry_cur_id, 25, l_line_dtl_rec.transaction_system_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 26, l_line_dtl_rec.sellable_flag, 1);
    dbms_sql.define_column(l_dtl_qry_cur_id, 27, l_line_dtl_rec.version_label,240);
    dbms_sql.define_column(l_dtl_qry_cur_id, 28, l_line_dtl_rec.return_by_date);
    dbms_sql.define_column(l_dtl_qry_cur_id, 29, l_line_dtl_rec.active_start_date);
    dbms_sql.define_column(l_dtl_qry_cur_id, 30, l_line_dtl_rec.active_end_date);
    dbms_sql.define_column(l_dtl_qry_cur_id, 31, l_line_dtl_rec.preserve_detail_flag,1);
    dbms_sql.define_column(l_dtl_qry_cur_id, 32, l_line_dtl_rec.reference_source_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 33, l_line_dtl_rec.reference_source_date);
    dbms_sql.define_column(l_dtl_qry_cur_id, 34, l_line_dtl_rec.csi_transaction_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 35, l_line_dtl_rec.processing_status,30);
    dbms_sql.define_column(l_dtl_qry_cur_id, 36, l_line_dtl_rec.error_code,240);
    dbms_sql.define_column(l_dtl_qry_cur_id, 37, l_line_dtl_rec.error_explanation,240);
    dbms_sql.define_column(l_dtl_qry_cur_id, 38, l_line_dtl_rec.context,30);
    dbms_sql.define_column(l_dtl_qry_cur_id, 39, l_line_dtl_rec.attribute1, 150);
    dbms_sql.define_column(l_dtl_qry_cur_id, 40, l_line_dtl_rec.attribute2, 150);
    dbms_sql.define_column(l_dtl_qry_cur_id, 41, l_line_dtl_rec.attribute3, 150);
    dbms_sql.define_column(l_dtl_qry_cur_id, 42, l_line_dtl_rec.attribute4, 150);
    dbms_sql.define_column(l_dtl_qry_cur_id, 43, l_line_dtl_rec.attribute5, 150);
    dbms_sql.define_column(l_dtl_qry_cur_id, 44, l_line_dtl_rec.attribute6, 150);
    dbms_sql.define_column(l_dtl_qry_cur_id, 45, l_line_dtl_rec.attribute7, 150);
    dbms_sql.define_column(l_dtl_qry_cur_id, 46, l_line_dtl_rec.attribute8, 150);
    dbms_sql.define_column(l_dtl_qry_cur_id, 47, l_line_dtl_rec.attribute9, 150);
    dbms_sql.define_column(l_dtl_qry_cur_id, 48, l_line_dtl_rec.attribute10, 150);
    dbms_sql.define_column(l_dtl_qry_cur_id, 49, l_line_dtl_rec.attribute11, 150);
    dbms_sql.define_column(l_dtl_qry_cur_id, 50, l_line_dtl_rec.attribute12, 150);
    dbms_sql.define_column(l_dtl_qry_cur_id, 51, l_line_dtl_rec.attribute13, 150);
    dbms_sql.define_column(l_dtl_qry_cur_id, 52, l_line_dtl_rec.attribute14, 150);
    dbms_sql.define_column(l_dtl_qry_cur_id, 53, l_line_dtl_rec.attribute15, 150);
    dbms_sql.define_column(l_dtl_qry_cur_id, 54, l_line_dtl_rec.object_version_number);
    dbms_sql.define_column(l_dtl_qry_cur_id, 55, l_line_dtl_rec.source_txn_line_detail_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 56, l_line_dtl_rec.inv_mtl_transaction_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 57, l_line_dtl_rec.config_inst_hdr_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 58, l_line_dtl_rec.config_inst_rev_num);
    dbms_sql.define_column(l_dtl_qry_cur_id, 59, l_line_dtl_rec.config_inst_item_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 60, l_line_dtl_rec.target_commitment_date);
    dbms_sql.define_column(l_dtl_qry_cur_id, 61 , l_line_dtl_rec.instance_description,240);
    dbms_sql.define_column(l_dtl_qry_cur_id, 62 , l_line_dtl_rec.config_inst_baseline_rev_num);
    dbms_sql.define_column(l_dtl_qry_cur_id, 63, l_line_dtl_rec.reference_source_line_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 64, l_line_dtl_rec.install_location_type_code,60);
    dbms_sql.define_column(l_dtl_qry_cur_id, 65, l_line_dtl_rec.install_location_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 66, l_line_dtl_rec.cascade_owner_flag,1);
    dbms_sql.define_column(l_dtl_qry_cur_id, 67, l_line_dtl_rec.parent_instance_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 68, l_line_dtl_rec.assc_txn_line_detail_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 69, l_line_dtl_rec.overriding_csi_txn_id);
    dbms_sql.define_column(l_dtl_qry_cur_id, 70, l_line_dtl_rec.instance_status_id);

    l_ind := 0;

    l_processed_rows := dbms_sql.execute(l_dtl_qry_cur_id);
    LOOP
      exit when dbms_sql.fetch_rows(l_dtl_qry_cur_id) = 0;

      l_ind := l_ind + 1;

      dbms_sql.column_value(l_dtl_qry_cur_id, 1, x_line_dtls_tbl(l_ind).txn_line_detail_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 2, x_line_dtls_tbl(l_ind).transaction_line_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 3, x_line_dtls_tbl(l_ind).sub_type_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 4, x_line_dtls_tbl(l_ind).instance_exists_flag);
      dbms_sql.column_value(l_dtl_qry_cur_id, 5, x_line_dtls_tbl(l_ind).source_transaction_flag);
      dbms_sql.column_value(l_dtl_qry_cur_id, 6, x_line_dtls_tbl(l_ind).instance_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 7, x_line_dtls_tbl(l_ind).changed_instance_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 8, x_line_dtls_tbl(l_ind).csi_system_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 9, x_line_dtls_tbl(l_ind).inventory_item_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 10, x_line_dtls_tbl(l_ind).inventory_revision);
      dbms_sql.column_value(l_dtl_qry_cur_id, 11, x_line_dtls_tbl(l_ind).inv_organization_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 12, x_line_dtls_tbl(l_ind).item_condition_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 13, x_line_dtls_tbl(l_ind).instance_type_code);
      dbms_sql.column_value(l_dtl_qry_cur_id, 14, x_line_dtls_tbl(l_ind).quantity);
      dbms_sql.column_value(l_dtl_qry_cur_id, 15, x_line_dtls_tbl(l_ind).unit_of_measure);
      dbms_sql.column_value(l_dtl_qry_cur_id, 16, x_line_dtls_tbl(l_ind).qty_remaining);
      dbms_sql.column_value(l_dtl_qry_cur_id, 17, x_line_dtls_tbl(l_ind).serial_number);
      dbms_sql.column_value(l_dtl_qry_cur_id, 18, x_line_dtls_tbl(l_ind).mfg_serial_number_flag);
      dbms_sql.column_value(l_dtl_qry_cur_id, 19, x_line_dtls_tbl(l_ind).lot_number);
      dbms_sql.column_value(l_dtl_qry_cur_id, 20, x_line_dtls_tbl(l_ind).location_type_code);
      dbms_sql.column_value(l_dtl_qry_cur_id, 21, x_line_dtls_tbl(l_ind).location_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 22, x_line_dtls_tbl(l_ind).installation_date);
      dbms_sql.column_value(l_dtl_qry_cur_id, 23, x_line_dtls_tbl(l_ind).in_service_date);
      dbms_sql.column_value(l_dtl_qry_cur_id, 24, x_line_dtls_tbl(l_ind).external_reference);
      dbms_sql.column_value(l_dtl_qry_cur_id, 25, x_line_dtls_tbl(l_ind).transaction_system_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 26, x_line_dtls_tbl(l_ind).sellable_flag);
      dbms_sql.column_value(l_dtl_qry_cur_id, 27, x_line_dtls_tbl(l_ind).version_label);
      dbms_sql.column_value(l_dtl_qry_cur_id, 28, x_line_dtls_tbl(l_ind).return_by_date);
      dbms_sql.column_value(l_dtl_qry_cur_id, 29, x_line_dtls_tbl(l_ind).active_start_date);
      dbms_sql.column_value(l_dtl_qry_cur_id, 30, x_line_dtls_tbl(l_ind).active_end_date);
      dbms_sql.column_value(l_dtl_qry_cur_id, 31, x_line_dtls_tbl(l_ind).preserve_detail_flag);
      dbms_sql.column_value(l_dtl_qry_cur_id, 32, x_line_dtls_tbl(l_ind).reference_source_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 33, x_line_dtls_tbl(l_ind).reference_source_date);
      dbms_sql.column_value(l_dtl_qry_cur_id, 34, x_line_dtls_tbl(l_ind).csi_transaction_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 35, x_line_dtls_tbl(l_ind).processing_status);
      dbms_sql.column_value(l_dtl_qry_cur_id, 36, x_line_dtls_tbl(l_ind).error_code);
      dbms_sql.column_value(l_dtl_qry_cur_id, 37, x_line_dtls_tbl(l_ind).error_explanation);
      dbms_sql.column_value(l_dtl_qry_cur_id, 38, x_line_dtls_tbl(l_ind).context);
      dbms_sql.column_value(l_dtl_qry_cur_id, 39, x_line_dtls_tbl(l_ind).attribute1);
      dbms_sql.column_value(l_dtl_qry_cur_id, 40, x_line_dtls_tbl(l_ind).attribute2);
      dbms_sql.column_value(l_dtl_qry_cur_id, 41, x_line_dtls_tbl(l_ind).attribute3);
      dbms_sql.column_value(l_dtl_qry_cur_id, 42, x_line_dtls_tbl(l_ind).attribute4);
      dbms_sql.column_value(l_dtl_qry_cur_id, 43, x_line_dtls_tbl(l_ind).attribute5);
      dbms_sql.column_value(l_dtl_qry_cur_id, 44, x_line_dtls_tbl(l_ind).attribute6);
      dbms_sql.column_value(l_dtl_qry_cur_id, 45, x_line_dtls_tbl(l_ind).attribute7);
      dbms_sql.column_value(l_dtl_qry_cur_id, 46, x_line_dtls_tbl(l_ind).attribute8);
      dbms_sql.column_value(l_dtl_qry_cur_id, 47, x_line_dtls_tbl(l_ind).attribute9);
      dbms_sql.column_value(l_dtl_qry_cur_id, 48, x_line_dtls_tbl(l_ind).attribute10);
      dbms_sql.column_value(l_dtl_qry_cur_id, 49, x_line_dtls_tbl(l_ind).attribute11);
      dbms_sql.column_value(l_dtl_qry_cur_id, 50, x_line_dtls_tbl(l_ind).attribute12);
      dbms_sql.column_value(l_dtl_qry_cur_id, 51, x_line_dtls_tbl(l_ind).attribute13);
      dbms_sql.column_value(l_dtl_qry_cur_id, 52, x_line_dtls_tbl(l_ind).attribute14);
      dbms_sql.column_value(l_dtl_qry_cur_id, 53, x_line_dtls_tbl(l_ind).attribute15);
      dbms_sql.column_value(l_dtl_qry_cur_id, 54, x_line_dtls_tbl(l_ind).object_version_number);
      dbms_sql.column_value(l_dtl_qry_cur_id, 55, x_line_dtls_tbl(l_ind).source_txn_line_detail_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 56, x_line_dtls_tbl(l_ind).inv_mtl_transaction_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 57, x_line_dtls_tbl(l_ind).config_inst_hdr_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 58, x_line_dtls_tbl(l_ind).config_inst_rev_num);
      dbms_sql.column_value(l_dtl_qry_cur_id, 59, x_line_dtls_tbl(l_ind).config_inst_item_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 60, x_line_dtls_tbl(l_ind).target_commitment_date);
      dbms_sql.column_value(l_dtl_qry_cur_id, 61, x_line_dtls_tbl(l_ind).instance_description);
      dbms_sql.column_value(l_dtl_qry_cur_id, 62 , l_line_dtl_rec.config_inst_baseline_rev_num);
      dbms_sql.column_value(l_dtl_qry_cur_id, 63, x_line_dtls_tbl(l_ind).reference_source_line_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 64, x_line_dtls_tbl(l_ind).install_location_type_code);
      dbms_sql.column_value(l_dtl_qry_cur_id, 65, x_line_dtls_tbl(l_ind).install_location_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 66, x_line_dtls_tbl(l_ind).cascade_owner_flag);
      dbms_sql.column_value(l_dtl_qry_cur_id, 67, x_line_dtls_tbl(l_ind).parent_instance_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 68, x_line_dtls_tbl(l_ind).assc_txn_line_detail_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 69, x_line_dtls_tbl(l_ind).overriding_csi_txn_id);
      dbms_sql.column_value(l_dtl_qry_cur_id, 70, x_line_dtls_tbl(l_ind).instance_status_id);
    END LOOP;

    dbms_sql.close_cursor(l_dtl_qry_cur_id);

  EXCEPTION

    WHEN fnd_api.g_exc_error THEN

      IF dbms_sql.is_open(l_dtl_qry_cur_id) THEN
        dbms_sql.close_cursor(l_dtl_qry_cur_id);
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;

    WHEN others THEN

      IF dbms_sql.is_open(l_dtl_qry_cur_id) THEN
        dbms_sql.close_cursor(l_dtl_qry_cur_id);
      END IF;

      debug('Error : '|| SQLERRM);
      x_return_status := fnd_api.g_ret_sts_unexp_error;

  END get_dtls_dynamic;

  PROCEDURE build_line_dtls_select(
    p_txn_line_detail_query_rec     in  csi_t_datastructures_grp.txn_line_detail_query_rec,
    x_dtl_select_stmt   OUT NOCOPY varchar2,
    x_dtl_where_clause  OUT NOCOPY varchar2,
    x_return_status     OUT NOCOPY varchar2)
  IS

   l_select_stmt  varchar2(32767);
   l_where_clause varchar2(32767);

  BEGIN

    api_log('build_line_dtls_select');

    x_return_status := fnd_api.g_ret_sts_success;

    l_select_stmt :=
     'select txn_line_detail_id, transaction_line_id, sub_type_id, instance_exists_flag, '||
     '  source_transaction_flag, instance_id, changed_instance_id, '||
     '  csi_system_id, inventory_item_id, inventory_revision, '||
     '  inv_organization_id, item_condition_id, instance_type_code, '||
     '  quantity, unit_of_measure, qty_remaining, serial_number, '||
     '  mfg_serial_number_flag, lot_number, location_type_code, location_id, '||
     '  installation_date, in_service_date, external_reference, '||
     '  transaction_system_id, sellable_flag, version_label, return_by_date, '||
     '  active_start_date, active_end_date, preserve_detail_flag, reference_source_id, '||
     '  reference_source_date, csi_transaction_id, processing_status, error_code, '||
     '  error_explanation, context, attribute1, attribute2, attribute3, attribute4, '||
     '  attribute5, attribute6, attribute7, attribute8, attribute9, attribute10, '||
     '  attribute11, attribute12, attribute13, attribute14, attribute15, '||
     '  object_version_number, source_txn_line_detail_id, inv_mtl_transaction_id  '||
     '  , config_inst_hdr_id, config_inst_rev_num , config_inst_item_id , target_commitment_date, '||
     '  instance_description , config_inst_baseline_rev_num , reference_source_line_id, '||
     '  install_location_type_code,install_location_id, '|| '  cascade_owner_flag,   '||
     '  parent_instance_id, assc_txn_line_detail_id, '||
     '  overriding_csi_txn_id, instance_status_id '||
     ' from  csi_t_txn_line_details ';

    l_where_clause := null;

    IF nvl(p_txn_line_detail_query_rec.transaction_line_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN
      l_where_clause := l_where_clause||' transaction_line_id = :dtl_transaction_line_id and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.txn_line_detail_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN
      l_where_clause := l_where_clause||' txn_line_detail_id = :txn_line_detail_id and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.sub_type_id,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN
      l_where_clause := l_where_clause||' sub_type_id = :sub_type_id and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.instance_exists_flag, Fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      l_where_clause := l_where_clause||' instance_exists_flag = :instance_exists_flag and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.instance_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN
      l_where_clause := l_where_clause||' instance_id = :instance_id and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.csi_transaction_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN
      l_where_clause := l_where_clause||' csi_transaction_id = :csi_transaction_id and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.source_transaction_flag, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      l_where_clause := l_where_clause||' source_transaction_flag = :source_transaction_flag and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.csi_system_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN
      l_where_clause := l_where_clause||' csi_system_id = :csi_system_id and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.transaction_system_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN
      l_where_clause := l_where_clause||' transaction_system_id = :transaction_system_id and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.inventory_item_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN
      l_where_clause := l_where_clause||' inventory_item_id = :inventory_item_id and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.inventory_revision, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      l_where_clause := l_where_clause||' inventory_revision = :inventory_revision and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.inv_organization_id, fnd_api.g_miss_num) <>
       fnd_api.g_miss_num
    THEN
      l_where_clause := l_where_clause||' inv_organization_id = :inv_organization_id and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.serial_number, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      l_where_clause := l_where_clause||' serial_number = :serial_number and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.mfg_serial_number_flag, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      l_where_clause := l_where_clause||' mfg_serial_number_flag = :mfg_serial_number_flag and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.lot_number, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      l_where_clause := l_where_clause||' lot_number = :lot_number and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.location_type_code, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      l_where_clause := l_where_clause||' location_type_code = :location_type_code and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.external_reference, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      l_where_clause := l_where_clause||' external_reference = :external_reference and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.processing_status, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      IF p_txn_line_detail_query_rec.processing_status = 'UNPROCESSED' THEN

        l_where_clause := l_where_clause||
                 ' nvl(processing_status,''SUBMIT'') <> ''PROCESSED'' and ';

      ELSE
        l_where_clause := l_where_clause||' processing_status = '''||
                nvl(p_txn_line_detail_query_rec.processing_status,'SUBMIT')||''' and ';
      END IF;
    END IF;

    IF nvl(p_txn_line_detail_query_rec.error_code, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      l_where_clause := l_where_clause||' error_code = :dtl_error_code and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.error_explanation, fnd_api.g_miss_char) <>
       fnd_api.g_miss_char
    THEN
      l_where_clause := l_where_clause||' error_explanation = :dtl_error_explanation and ';
    END IF;

    IF nvl(p_txn_line_detail_query_rec.return_by_date, fnd_api.g_miss_date) <>
       fnd_api.g_miss_date
    THEN
      l_where_clause := l_where_clause||' return_by_date = '''||
                           p_txn_line_detail_query_rec.return_by_date||''' and ';
    END IF;

    l_where_clause := substr(l_where_clause,1,(instr(l_where_clause, ' and', -1)-1));

    x_dtl_select_stmt  := l_select_stmt;
    x_dtl_where_clause := l_where_clause;

    debug(l_where_clause);

  END build_line_dtls_select;

  PROCEDURE build_txn_lines_select(
    p_txn_line_query_rec IN  csi_t_datastructures_grp.txn_line_query_rec,
    x_lines_select_stmt  OUT NOCOPY varchar2,
    x_lines_restrict     OUT NOCOPY varchar2,
    x_return_status      OUT NOCOPY varchar2)
  IS

   l_select_stmt  varchar2(32767);
   l_where_clause varchar2(32767);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('build_txn_lines_select');

    x_lines_restrict := 'N';

    l_select_stmt :=
     ' transaction_line_id in (select transaction_line_id from  csi_t_transaction_lines ';

    l_where_clause := null;

    IF nvl(p_txn_line_query_rec.transaction_line_id,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num THEN
      l_where_clause := l_where_clause||' transaction_line_id = :transaction_line_id and ';
    END IF;

    IF nvl(p_txn_line_query_rec.source_txn_header_id,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num THEN
      l_where_clause := l_where_clause||' source_txn_header_id = :source_txn_header_id and ';
    END IF;


    IF nvl(p_txn_line_query_rec.source_transaction_id,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num THEN
      l_where_clause := l_where_clause||' source_transaction_id = :source_transaction_id and ';
    END IF;

    IF nvl(p_txn_line_query_rec.source_transaction_table,fnd_api.g_miss_char) <>
       fnd_api.g_miss_char THEN
      l_where_clause := l_where_clause||' source_transaction_table = :source_transaction_table and ';
    END IF;

    IF nvl(p_txn_line_query_rec.error_code,fnd_api.g_miss_char) <>
       fnd_api.g_miss_char THEN
      l_where_clause := l_where_clause||' error_code = :error_code and ';
    END IF;

    IF nvl(p_txn_line_query_rec.processing_status,fnd_api.g_miss_char) <>
       fnd_api.g_miss_char THEN
      l_where_clause := l_where_clause||' processing_status = :processing_status and ';
    END IF;

    IF nvl(p_txn_line_query_rec.config_session_hdr_id,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num THEN
      l_where_clause := l_where_clause||' config_session_hdr_id = :config_session_hdr_id and ';
    END IF;

    IF nvl(p_txn_line_query_rec.config_session_rev_num,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num THEN
      l_where_clause := l_where_clause||' config_session_rev_num = :config_session_rev_num and ';
    END IF;

    IF nvl(p_txn_line_query_rec.config_session_item_id,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num THEN
      l_where_clause := l_where_clause||' config_session_item_id = :config_session_item_id and ';
    END IF;

    IF l_where_clause is not null then
      x_lines_restrict := 'Y';

    END IF;

    l_where_clause := ' where '||substr(l_where_clause,1,(instr(l_where_clause,' and',-1) -1));
    debug(l_where_clause);

    l_select_stmt := l_select_stmt||l_where_clause||')';

    x_lines_select_stmt := l_select_stmt;

  END build_txn_lines_select;


  PROCEDURE get_txn_line_dtls(
    p_txn_line_query_rec        IN  csi_t_datastructures_grp.txn_line_query_rec,
    p_txn_line_detail_query_rec IN  csi_t_datastructures_grp.txn_line_detail_query_rec,
    x_txn_line_dtl_tbl          OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status             OUT NOCOPY varchar2)
  IS

   l_dtl_select_stmt       varchar2(32767);
   l_dtl_where_clause      varchar2(32767);
   l_lines_restrict_clause varchar2(32767);
   l_lines_restrict        varchar2(1);
   l_return_status         varchar2(1) := fnd_api.g_ret_sts_success;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    api_log('get_txn_line_dtls');

    -- apply txn_line_detail filter first and then the txn_ line_ filter

    build_line_dtls_select(
      p_txn_line_detail_query_rec => p_txn_line_detail_query_rec,
      x_dtl_select_stmt           => l_dtl_select_stmt,
      x_dtl_where_clause          => l_dtl_where_clause,
      x_return_status             => l_return_status);

    build_txn_lines_select(
      p_txn_line_query_rec => p_txn_line_query_rec,
      x_lines_select_stmt  => l_lines_restrict_clause,
      x_lines_restrict     => l_lines_restrict,
      x_return_status      => l_return_status);


    IF l_dtl_where_clause is not null then

      l_dtl_select_stmt := l_dtl_select_stmt||' where '||l_dtl_where_clause;

      IF l_lines_restrict = 'Y' THEN
        l_dtl_select_stmt := l_dtl_select_stmt||' and '||l_lines_restrict_clause;
      END IF;

    ELSE
      IF l_lines_restrict = 'Y' THEN
        l_dtl_select_stmt := l_dtl_select_stmt||' where '||l_lines_restrict_clause;
      END IF;
    END IF;

    get_dtls_dynamic(
      p_txn_line_query_rec        => p_txn_line_query_rec,
      p_txn_line_detail_query_rec => p_txn_line_detail_query_rec,
      p_dtl_select_stmt           => l_dtl_select_stmt,
      x_line_dtls_tbl             => x_txn_line_dtl_tbl,
      x_return_status             => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    debug('get_txn_line_dtls successful.');

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_txn_line_dtls;

  PROCEDURE delete_txn_line_dtls(
    p_api_version             IN  NUMBER,
    p_commit                  IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full,
    p_txn_line_detail_ids_tbl IN  csi_t_datastructures_grp.txn_line_detail_ids_tbl,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2)
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'delete_txn_line_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;


  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT delete_txn_line_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       fnd_api.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => G_PKG_NAME) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    -- debug messages
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    debug(p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

    -- Main API code
    IF p_txn_line_detail_ids_tbl.COUNT > 0 THEN
      FOR l_ind in p_txn_line_detail_ids_tbl.FIRST..
                   p_txn_line_detail_ids_tbl.LAST
      LOOP

        csi_t_txn_line_details_pkg.delete_row(
          p_txn_line_detail_id  => p_txn_line_detail_ids_tbl(l_ind).
                                     txn_line_detail_id);

      END LOOP;

    END IF;


    -- Standard check of p_commit.
    IF fnd_api.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    fnd_msg_pub.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN

      ROLLBACK TO delete_txn_line_dtls;
      x_return_status := fnd_api.g_ret_sts_error ;
      fnd_msg_pub.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK TO delete_txn_line_dtls;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;

      fnd_msg_pub.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN others THEN

      rollback to delete_txn_line_dtls;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(
           p_message_level => fnd_msg_pub.g_msg_lvl_unexp_error) THEN

        fnd_msg_pub.add_exc_msg(
          p_pkg_name       => g_pkg_name,
          p_procedure_name => l_api_name);

      END IF;

      fnd_msg_pub.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END delete_txn_line_dtls;

  PROCEDURE update_txn_line(
    p_txn_line_rec     IN  csi_t_datastructures_grp.txn_line_rec,
    x_return_status    OUT NOCOPY varchar2)
  IS


    CURSOR txn_line_cur (p_txn_line_id in number)is
      SELECT *
      FROM   csi_t_transaction_lines
      WHERE  transaction_line_id = p_txn_line_id;

    l_txn_line_rec  csi_t_datastructures_grp.txn_line_rec;
    l_transaction_line_rec  csi_t_datastructures_grp.txn_line_rec;
    l_return_status varchar2(1)  := fnd_api.g_ret_sts_success;
    l_api_name      varchar2(30) := 'update_txn_line';
    l_debug_level   number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_api_name => l_api_name,
      p_pkg_name => g_pkg_name);

    IF l_debug_level > 1 then
      csi_t_gen_utility_pvt.dump_txn_line_rec(
        p_txn_line_rec => p_txn_line_rec);
    END IF;

    -- adding this for transparency of transaction line id to callers.

    l_txn_line_rec.transaction_line_id := p_txn_line_rec.transaction_line_id;

    IF nvl(l_txn_line_rec.transaction_line_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN

      IF nvl(p_txn_line_rec.source_transaction_table, fnd_api.g_miss_char) = fnd_api.g_miss_char
         OR
         nvl(p_txn_line_rec.source_transaction_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN

        fnd_message.set_name('CSI','CSI_TXN_SRC_INFO_MISSING');
        fnd_message.set_token('SRC_NAME',p_txn_line_rec.source_transaction_table);
        fnd_message.set_token('SRC_ID',p_txn_line_rec.source_transaction_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;

      ELSE

        BEGIN

          SELECT transaction_line_id
          INTO   l_txn_line_rec.transaction_line_id
          FROM   csi_t_transaction_lines
          WHERE  source_transaction_table = p_txn_line_rec.source_transaction_table
          AND    source_transaction_id    = p_txn_line_rec.source_transaction_id;

        EXCEPTION
          WHEN no_data_found THEN

            fnd_message.set_name('CSI','CSI_TXN_SOURCE_ID_INVALID');
            fnd_message.set_token('SRC_LINE_ID',p_txn_line_rec.source_transaction_id);
            fnd_message.set_token('SRC_NAME',p_txn_line_rec.source_transaction_table);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
        END;

      END IF;

    END IF;

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value      => l_txn_line_rec.transaction_line_id,
      p_param_name => 'p_txn_line_rec.transaction_line_id',
      p_api_name   => 'update_txn_line_dtls');

    -- validate txn_line_id
    csi_t_vldn_routines_pvt.validate_transaction_line_id(
      p_transaction_line_id    => l_txn_line_rec.transaction_line_id,
      x_transaction_line_rec   => l_transaction_line_rec, -- changed for Mass Update R12
      x_return_status          => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_message.set_name('CSI','CSI_TXN_LINE_ID_INVALID');
      fnd_message.set_token('TXN_LINE_ID', l_txn_line_rec.transaction_line_id);
      fnd_msg_pub.add;
      raise fnd_api.g_exc_error;
    END IF;

    IF ( nvl(p_txn_line_rec.config_session_hdr_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
      OR nvl(p_txn_line_rec.config_session_rev_num, fnd_api.g_miss_num) <> fnd_api.g_miss_num
      OR nvl(p_txn_line_rec.config_session_item_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num )
    THEN

       csi_t_gen_utility_pvt.add('Validating against CZ view ');

       csi_t_vldn_routines_pvt.check_cz_session_keys
                 (p_config_session_hdr_id => p_txn_line_rec.config_session_hdr_id,
                 p_config_session_rev_num => p_txn_line_rec.config_session_rev_num,
                 p_config_session_item_id => p_txn_line_rec.config_session_item_id,
                 x_return_status => l_return_status);

       IF l_return_status <> fnd_api.g_ret_sts_success
       THEN
         RAISE FND_API.g_exc_error;
       END IF;

    END IF;

    FOR l_cur_rec in txn_line_cur (l_txn_line_rec.transaction_line_id)
    LOOP

      l_txn_line_rec.transaction_line_id      := l_cur_rec.transaction_line_id;

      l_txn_line_rec.source_transaction_type_id := l_cur_rec.source_transaction_type_id;
      l_txn_line_rec.source_transaction_table := l_cur_rec.source_transaction_table;
      l_txn_line_rec.source_txn_header_id     := l_cur_rec.source_txn_header_id;
      l_txn_line_rec.source_transaction_id    := l_cur_rec.source_transaction_id;
      l_txn_line_rec.config_session_hdr_id    := l_cur_rec.config_session_hdr_id;
      l_txn_line_rec.config_session_rev_num    := l_cur_rec.config_session_rev_num;
      l_txn_line_rec.config_session_item_id    := l_cur_rec.config_session_item_id;
      l_txn_line_rec.config_valid_status      := l_cur_rec.config_valid_status;
      l_txn_line_rec.source_transaction_status      := l_cur_rec.source_transaction_status;
      l_txn_line_rec.error_code               := p_txn_line_rec.error_code;
      l_txn_line_rec.error_explanation        := p_txn_line_rec.error_explanation;
      l_txn_line_rec.processing_status        := p_txn_line_rec.processing_status;
      l_txn_line_rec.context                  := p_txn_line_rec.context;
      l_txn_line_rec.attribute1               := p_txn_line_rec.attribute1;
      l_txn_line_rec.attribute2               := p_txn_line_rec.attribute2;
      l_txn_line_rec.attribute3               := p_txn_line_rec.attribute3;
      l_txn_line_rec.attribute4               := p_txn_line_rec.attribute4;
      l_txn_line_rec.attribute5               := p_txn_line_rec.attribute5;
      l_txn_line_rec.attribute6               := p_txn_line_rec.attribute6;
      l_txn_line_rec.attribute7               := p_txn_line_rec.attribute7;
      l_txn_line_rec.attribute8               := p_txn_line_rec.attribute8;
      l_txn_line_rec.attribute9               := p_txn_line_rec.attribute9;
      l_txn_line_rec.attribute10              := p_txn_line_rec.attribute10;
      l_txn_line_rec.attribute11              := p_txn_line_rec.attribute11;
      l_txn_line_rec.attribute12              := p_txn_line_rec.attribute12;
      l_txn_line_rec.attribute13              := p_txn_line_rec.attribute13;
      l_txn_line_rec.attribute14              := p_txn_line_rec.attribute14;
      l_txn_line_rec.attribute15              := p_txn_line_rec.attribute15;
      l_txn_line_rec.object_version_number    := p_txn_line_rec.object_version_number;

      csi_t_gen_utility_pvt.dump_api_info(
        p_api_name => 'update_row',
        p_pkg_name => 'csi_t_transaction_lines_pkg');

      csi_t_transaction_lines_pkg.update_row(
        p_transaction_line_id      => l_txn_line_rec.transaction_line_id,
        p_source_transaction_type_id => l_txn_line_rec.source_transaction_type_id,
        p_source_transaction_table => l_txn_line_rec.source_transaction_table,
        p_source_txn_header_id     => l_txn_line_rec.source_txn_header_id,
        p_source_transaction_id    => l_txn_line_rec.source_transaction_id,
        p_error_code               => l_txn_line_rec.error_code,
        p_error_explanation        => l_txn_line_rec.error_explanation,
        -- Added for CZ Integration (Begin)
        p_config_session_hdr_id      => l_txn_line_rec.config_session_hdr_id ,
        p_config_session_rev_num     => l_txn_line_rec.config_session_rev_num ,
        p_config_session_item_id    => l_txn_line_rec.config_session_item_id ,
        p_config_valid_status    => l_txn_line_rec.config_valid_status ,
        p_source_transaction_status    => l_txn_line_rec.source_transaction_status ,
        -- Added for CZ Integration (End)
        p_processing_status        => l_txn_line_rec.processing_status,
        p_attribute1               => l_txn_line_rec.attribute1,
        p_attribute2               => l_txn_line_rec.attribute2,
        p_attribute3               => l_txn_line_rec.attribute3,
        p_attribute4               => l_txn_line_rec.attribute4,
        p_attribute5               => l_txn_line_rec.attribute5,
        p_attribute6               => l_txn_line_rec.attribute6,
        p_attribute7               => l_txn_line_rec.attribute7,
        p_attribute8               => l_txn_line_rec.attribute8,
        p_attribute9               => l_txn_line_rec.attribute9,
        p_attribute10              => l_txn_line_rec.attribute10,
        p_attribute11              => l_txn_line_rec.attribute11,
        p_attribute12              => l_txn_line_rec.attribute12,
        p_attribute13              => l_txn_line_rec.attribute13,
        p_attribute14              => l_txn_line_rec.attribute14,
        p_attribute15              => l_txn_line_rec.attribute15,
        p_created_by               => l_cur_rec.created_by,
        p_creation_date            => l_cur_rec.creation_date,
        p_last_updated_by          => fnd_global.user_id,
        p_last_update_date         => sysdate,
        p_last_update_login        => fnd_global.login_id,
        p_object_version_number    => l_txn_line_rec.object_version_number,
        p_context                  => l_txn_line_rec.context);

    END LOOP;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END update_txn_line;

END csi_t_txn_line_dtls_pvt;

/

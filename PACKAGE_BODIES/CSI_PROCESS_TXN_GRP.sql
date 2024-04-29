--------------------------------------------------------
--  DDL for Package Body CSI_PROCESS_TXN_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_PROCESS_TXN_GRP" as
/* $Header: csigptxb.pls 120.2 2006/03/17 04:33:42 bnarayan noship $ */


  /* local debugging procedure */
  PROCEDURE debug(
    p_message IN varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.add(p_message);
  END debug;

  /*-------------------------------------------------------------------*/
  /* Group API used to process one source transaction line             */
  /* This api reads a set op pl/sql tables and converts them in to     */
  /* instances .If an instance reference is found then it updates the  */
  /* instance with the new location and party attributes               */
  /*-------------------------------------------------------------------*/

  PROCEDURE process_transaction(
    p_api_version             IN     NUMBER,
    p_commit                  IN     VARCHAR2 := fnd_api.g_false,
    p_init_msg_list           IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level        IN     NUMBER   := fnd_api.g_valid_level_full,
    p_validate_only_flag      IN     VARCHAR2,
    p_in_out_flag             IN     VARCHAR2, -- valid values are 'IN','OUT'
    p_dest_location_rec       IN OUT NOCOPY dest_location_rec,
    p_txn_rec                 IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    p_instances_tbl           IN OUT NOCOPY txn_instances_tbl,
    p_i_parties_tbl           IN OUT NOCOPY txn_i_parties_tbl,
    p_ip_accounts_tbl         IN OUT NOCOPY txn_ip_accounts_tbl,
    p_org_units_tbl           IN OUT NOCOPY txn_org_units_tbl,
    p_ext_attrib_vlaues_tbl   IN OUT NOCOPY txn_ext_attrib_values_tbl,
    p_pricing_attribs_tbl     IN OUT NOCOPY txn_pricing_attribs_tbl,
    p_instance_asset_tbl      IN OUT NOCOPY txn_instance_asset_tbl,
    p_ii_relationships_tbl    IN OUT NOCOPY txn_ii_relationships_tbl,
    px_txn_error_rec          IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2 )
  IS

    g_user_id                      NUMBER        := fnd_global.user_id;
    g_login_id                     NUMBER        := fnd_global.login_id;
    g_sysdate                      DATE          := sysdate;

    l_api_name            CONSTANT VARCHAR2(30)  := 'process_transaction';
    l_api_version         CONSTANT NUMBER        := 1.0;
    l_return_status                VARCHAR2(1)   := fnd_api.g_ret_sts_success;
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(2000);
    l_debug_level                  NUMBER;

    l_transaction_rec              csi_datastructures_pub.transaction_rec;
    l_sub_type_rec                 csi_txn_sub_types%rowtype;
    l_instances_tbl                csi_process_txn_grp.txn_instances_tbl;
    l_parties_tbl                  csi_process_txn_grp.txn_i_parties_tbl;
    l_item_attr_rec                csi_process_txn_pvt.item_attr_rec;
    l_instance_id                  csi_item_instances.instance_id%TYPE;

  BEGIN

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Standard Start of API savepoint
    SAVEPOINT process_transaction;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT

       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    -- debug messages
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    debug('Transaction Flow: '||p_in_out_flag);

    -- MAIN API code starts here

    /* check if IB is active */
    csi_utility_grp.check_ib_active;

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_instances_tbl  := p_instances_tbl;
    l_parties_tbl    := p_i_parties_tbl;

    csi_process_txn_pvt.get_sub_type_rec(
      p_txn_type_id       => p_txn_rec.transaction_type_id,
      p_sub_type_id       => p_txn_rec.txn_sub_type_id,
      x_sub_type_rec      => l_sub_type_rec,
      x_return_status     => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    /* ---------------------------------------------------------------- */
    /* This routine validates the sub types and the passed instance     */
    /* information with the sub type definition                         */
    /* ---------------------------------------------------------------- */

    csi_process_txn_pvt.sub_type_validations(
      p_sub_type_rec      => l_sub_type_rec,
      p_txn_instances_tbl => l_instances_tbl,
      p_txn_i_parties_tbl => l_parties_tbl,
      x_return_status     => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    csi_process_txn_pvt.validate_dest_location_rec(
      p_in_out_flag       => p_in_out_flag,
      p_dest_location_rec => p_dest_location_rec,
      x_return_status     => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    debug('Parse I');

    IF l_instances_tbl.COUNT > 0 THEN

      /* Create transaction and use the same transaction rec throughout the program */

      l_transaction_rec := p_txn_rec;

      IF nvl(l_transaction_rec.transaction_id,fnd_api.g_miss_num) = fnd_api.g_miss_num THEN

        csi_t_gen_utility_pvt.dump_api_info(
          p_pkg_name => 'csi_transactions_pvt',
          p_api_name => 'create_transaction');

        csi_transactions_pvt.create_transaction (
          p_api_version             => 1.0,
          p_commit                  => fnd_api.g_false,
          p_init_msg_list           => fnd_api.g_true,
          p_validation_level        => fnd_api.g_valid_level_full,
          p_success_if_exists_flag  =>  'Y',
          p_transaction_rec         => l_transaction_rec,
          x_return_status           => l_return_status,
          x_msg_count               => l_msg_count,
          x_msg_data                => l_msg_data  );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        p_txn_rec := l_transaction_rec;

      END IF;

      debug('CSI Transaction ID: '||l_transaction_rec.transaction_id);

      FOR l_i_ind IN l_instances_tbl.FIRST .. l_instances_tbl.LAST
      LOOP

        IF nvl(l_instances_tbl(l_i_ind).instance_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
        THEN

          debug('Source instance reference not specified.');

          /* ------------------------------------------------------------- */
          /* This routine gets all the item attributes required for        */
          /* validating the instance and to determine the query parameters */
          /* ------------------------------------------------------------- */

          csi_process_txn_pvt.get_item_attributes(
            p_in_out_flag         =>  p_in_out_flag,
            p_sub_type_rec        =>  l_sub_type_rec,
            p_inventory_item_id   =>  l_instances_tbl(l_i_ind).inventory_item_id,
            p_organization_id     =>  l_instances_tbl(l_i_ind).vld_organization_id,
            x_item_attr_rec       =>  l_item_attr_rec,
            x_return_status       =>  l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_item_attr_rec.stockable_flag = 'Y' THEN

            debug('Stockable item, So trying to figure OUT NOCOPY the source instance.');

            /* ------------------------------------------------------------- */
            /* This routine validates the mandatory components to query the  */
            /* instance, builds the query record and fetches the instance    */
            /* This routine returns an error when multiple instances matches */
            /* the given criteria                                            */
            /* ------------------------------------------------------------- */

            /* exclude misc receipt (source location attributes are null)    */
            /*     and WIP assy completion. These transactions will not have */
            /*     source instances.                                         */

            IF nvl(l_instances_tbl(l_i_ind).location_type_code,fnd_api.g_miss_char) <> fnd_api.g_miss_char
               OR
               nvl(l_instances_tbl(l_i_ind).location_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
               OR
               nvl(l_instances_tbl(l_i_ind).inv_organization_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
               OR
               nvl(l_instances_tbl(l_i_ind).inv_subinventory_name, fnd_api.g_miss_char)<> fnd_api.g_miss_char
            THEN

              csi_process_txn_pvt.get_src_instance_id(
                p_in_out_flag       => p_in_out_flag,
                p_sub_type_rec      => l_sub_type_rec,
                p_instance_rec      => l_instances_tbl(l_i_ind),
                p_dest_location_rec => p_dest_location_rec,
                p_item_attr_rec     => l_item_attr_rec,
                p_transaction_rec   => l_transaction_rec,
                x_instance_id       => l_instance_id,
                x_return_status     => l_return_status);

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
              END IF;

               l_instances_tbl(l_i_ind).new_instance_id := l_instance_id;

            ELSE
               l_instances_tbl(l_i_ind).new_instance_id := fnd_api.g_miss_num;
            END IF;

            IF nvl(l_instances_tbl(l_i_ind).new_instance_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
              debug('Source instance identified. Instance ID :'||l_instances_tbl(l_i_ind).new_instance_id);
            ELSE
              debug('Process Transaction could not identity a source instance.');
            END IF;

          END IF; -- stockable flag = 'Y'

        ELSE

          debug('Source instance reference specified.');

          l_instances_tbl(l_i_ind).new_instance_id := l_instances_tbl(l_i_ind).instance_id;

        END IF; -- instance_id = fnd_api.g_miss_num

      END LOOP; -- txn_instance_tbl loop

    END IF; -- IF txn_instance_tbl.COUNT > 0


    /* --------------------------------------------------------------- */
    /* SECOND Parse -- call process IB when validate_only flag = FALSE */
    /* This section actually does the interface with IB                */
    /* --------------------------------------------------------------- */

    debug('Parse II');

    IF nvl(p_validate_only_flag, fnd_api.g_false) = fnd_api.g_false THEN

      IF l_instances_tbl.COUNT > 0 THEN

        FOR l_instance_index IN l_instances_tbl.FIRST .. l_instances_tbl.LAST
        LOOP

          /* process only the source transaction lines */

          IF l_instances_tbl(l_instance_index).ib_txn_segment_flag = 'S' THEN

            /* ------------------------------------------------------------- */
            /* This routine gets all the item attributes required for        */
            /* validating the instance and to determine the query parameters */
            /* ------------------------------------------------------------- */

            csi_process_txn_pvt.get_item_attributes(
              p_in_out_flag         =>  p_in_out_flag,
              p_sub_type_rec        =>  l_sub_type_rec,
              p_inventory_item_id   =>  l_instances_tbl(l_instance_index).inventory_item_id,
              p_organization_id     =>  l_instances_tbl(l_instance_index).vld_organization_id,
              x_item_attr_rec       =>  l_item_attr_rec,
              x_return_status       =>  l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            /* -------------------------------------------------------------- */
            /* call the process_IB routine that either creates a new instance */
            /* or updates the instances for the location and party attributes */
            /* based on the value in the instance_id/new_instance_id column   */
            /* if an inst ID is found at this level it is treated for update  */
            /* otherwise create an instance                                   */
            /* -------------------------------------------------------------- */


             /* Added the validation for considering the serialised at sales order
	        issue items with a not null serial number for deployment transactions
	        as serialised items  */

      IF  p_in_out_flag = 'INT' and l_instances_tbl(l_instance_index).serial_number IS NOT NULL  THEN

	IF l_transaction_rec.transaction_type_id IN (106,107,108,109,110,111)   THEN



	       debug('Processing of serial  items for deployment transaction');
               l_item_attr_rec.src_serial_control_flag := 'Y';
               l_item_attr_rec.dst_serial_control_flag := 'Y';

	   END IF;

	END IF;

            csi_process_txn_pvt.process_ib(
              p_in_out_flag         => p_in_out_flag,
              p_sub_type_rec        => l_sub_type_rec,
              p_item_attr_rec       => l_item_attr_rec,
              p_instance_index      => l_instance_index,
              p_instance_rec        => l_instances_tbl(l_instance_index),
              p_dest_location_rec   => p_dest_location_rec,
              p_i_parties_tbl       => p_i_parties_tbl,
              p_ip_accounts_tbl     => p_ip_accounts_tbl,
              p_ext_attrib_vals_tbl => p_ext_attrib_vlaues_tbl,
              p_pricing_attribs_tbl => p_pricing_attribs_tbl,
              p_org_units_tbl       => p_org_units_tbl,
              p_instance_asset_tbl  => p_instance_asset_tbl,
              p_transaction_rec     => l_transaction_rec,
              px_txn_error_rec      => px_txn_error_rec,
              x_return_status       => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF;

        END LOOP; -- txn_instance_tbl loop

      END IF; -- txn_instance_tbl COUNT > 0

      p_instances_tbl := l_instances_tbl;

      -- call the build relations routine

      IF p_ii_relationships_tbl.COUNT > 0 THEN

        csi_process_txn_pvt.process_relation(
          p_instances_tbl         => p_instances_tbl,
          p_ii_relationships_tbl  => p_ii_relationships_tbl,
          p_transaction_rec       => l_transaction_rec,
          x_return_status         => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF;

    END IF; -- validate_only_flag = FALSE

    -- END MAIN API Code

    -- Standard check of p_commit.
    IF fnd_api.to_boolean( p_commit ) then
      commit work;
    END IF;

    debug('Process transaction successful.');

    csi_t_gen_utility_pvt.set_debug_off;

    -- Standard call to get message count and if count is  get message info.
    fnd_msg_pub.count_and_get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN

      rollback to process_transaction;
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      x_msg_data := csi_t_gen_utility_pvt.dump_error_stack;
      debug('Error(E) :'||x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN

      rollback to process_transaction;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      x_msg_data := csi_t_gen_utility_pvt.dump_error_stack;
      debug('Error(U) :'||x_msg_data);

    WHEN others THEN

      rollback to process_transaction;

      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      fnd_msg_pub.add_exc_msg(
        p_pkg_name       => g_pkg_name,
        p_procedure_name => l_api_name);

      fnd_msg_pub.count_and_get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      x_msg_data := csi_t_gen_utility_pvt.dump_error_stack;
      debug('Error(E) :'||x_msg_data);

  END process_transaction;

  PROCEDURE process_transaction (
    p_api_version             IN     NUMBER,
    p_commit                  IN     VARCHAR2 := fnd_api.g_false,
    p_init_msg_list           IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level        IN     NUMBER   := fnd_api.g_valid_level_full,
    p_validate_only_flag      IN     VARCHAR2 := fnd_api.g_false,
    p_in_out_flag             IN     VARCHAR2, -- valid values are 'IN', 'OUT'
    p_dest_location_rec       IN OUT NOCOPY dest_location_rec,
    p_txn_rec                 IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    p_instances_tbl           IN OUT NOCOPY txn_instances_tbl,
    p_i_parties_tbl           IN OUT NOCOPY txn_i_parties_tbl,
    p_ip_accounts_tbl         IN OUT NOCOPY txn_ip_accounts_tbl,
    p_org_units_tbl           IN OUT NOCOPY txn_org_units_tbl,
    p_ext_attrib_vlaues_tbl   IN OUT NOCOPY txn_ext_attrib_values_tbl,
    p_pricing_attribs_tbl     IN OUT NOCOPY txn_pricing_attribs_tbl,
    p_instance_asset_tbl      IN OUT NOCOPY txn_instance_asset_tbl,
    p_ii_relationships_tbl    IN OUT NOCOPY txn_ii_relationships_tbl,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2 )
  IS
    l_error_rec      csi_datastructures_pub.transaction_error_rec;
    l_return_status  varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count      number;
    l_msg_data       varchar2(2000);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    csi_process_txn_grp.process_transaction(
      p_api_version             => p_api_version,
      p_commit                  => p_commit,
      p_init_msg_list           => p_init_msg_list,
      p_validation_level        => p_validation_level,
      p_validate_only_flag      => p_validate_only_flag,
      p_in_out_flag             => p_in_out_flag,
      p_dest_location_rec       => p_dest_location_rec,
      p_txn_rec                 => p_txn_rec,
      p_instances_tbl           => p_instances_tbl,
      p_i_parties_tbl           => p_i_parties_tbl,
      p_ip_accounts_tbl         => p_ip_accounts_tbl,
      p_org_units_tbl           => p_org_units_tbl,
      p_ext_attrib_vlaues_tbl   => p_ext_attrib_vlaues_tbl,
      p_pricing_attribs_tbl     => p_pricing_attribs_tbl,
      p_instance_asset_tbl      => p_instance_asset_tbl,
      p_ii_relationships_tbl    => p_ii_relationships_tbl,
      px_txn_error_rec          => l_error_rec,
      x_return_status           => l_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

    WHEN others THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.add_exc_msg(
        p_pkg_name       => 'csi_process_txn_grp',
        p_procedure_name => 'process_transaction');

      x_msg_data := csi_t_gen_utility_pvt.dump_error_stack;
      debug('Error(E) :'||x_msg_data);

  END process_transaction;

END csi_process_txn_grp;

/

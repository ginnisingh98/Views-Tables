--------------------------------------------------------
--  DDL for Package Body CSI_EAM_INTERFACE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_EAM_INTERFACE_GRP" AS
/* $Header: csigeamb.pls 120.2 2005/10/07 11:35:35 brmanesh noship $ */


  PROCEDURE debug(p_message IN varchar2) IS
  BEGIN
    csi_t_gen_utility_pvt.add(p_message);
  EXCEPTION
    WHEN others THEN
      null;
  END debug;

  PROCEDURE wip_completion(
    p_wip_entity_id   IN  number,
    p_organization_id IN  number,
    x_return_status   OUT nocopy varchar2,
    x_error_message   OUT nocopy varchar2)
  IS
    l_message_id          number;
    l_error_code          number;
    l_error_message       varchar2(4000);
    l_bypass_flag         varchar2(1);
    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_rec           csi_datastructures_pub.transaction_error_rec;
    publish_error         exception;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

   csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csiinv',
      p_file_segment2 => 'hook');

    debug('START IB integration from EAM process :'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
    debug('  wip_entity_id       : '||p_wip_entity_id);
    debug('  organization_id     : '||p_organization_id);

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_bypass_flag := nvl(csi_datastructures_pub.g_install_param_rec.sfm_queue_bypass_flag, 'N');
    debug('  bypass flag         : '||l_bypass_flag);

    l_error_rec.source_type          := 'CSIEAMWC';
    l_error_rec.source_id            := p_wip_entity_id;
    l_error_rec.source_header_ref_id := p_wip_entity_id;
    l_error_rec.source_line_ref_id   := p_organization_id;
    l_error_rec.transaction_type_id  := 92;
    l_error_rec.processed_flag       := 'E';

    IF l_bypass_flag = 'N' THEN

      debug('  publishing message CSIEAMWC for '||p_wip_entity_id);

      XNP_CSIEAMWC_U.publish(
        xnp$wip_entity_id     => p_wip_entity_id,
        xnp$organization_id   => p_organization_id,
        x_message_id          => l_message_id,
        x_error_code          => l_error_code,
        x_error_message       => l_error_message);

      IF l_error_message is not null THEN
        RAISE publish_error;
      END IF;

    ELSE

      debug('  bypassing the SFM Queue for CSIEAMWC '||p_wip_entity_id);

      csi_wip_trxs_pkg.eam_wip_completion(
        p_wip_entity_id    => p_wip_entity_id,
        p_organization_id  => p_organization_id,
        px_trx_error_rec   => l_error_rec,
        x_return_status    => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      csi_inv_trxs_pkg.log_csi_error(l_error_rec);
      x_return_status := fnd_api.g_ret_sts_success;
    WHEN publish_error THEN
      csi_inv_trxs_pkg.log_csi_error(l_error_rec);
      x_return_status := fnd_api.g_ret_sts_success;
  END wip_completion;


  PROCEDURE rebuildable_return(
    p_wip_entity_id   IN  number,
    p_organization_id IN  number,
    p_instance_id     IN number,
    x_return_status   OUT nocopy varchar2,
    x_error_message   OUT nocopy varchar2)
  IS
    l_message_id          number;
    l_error_code          number;
    l_error_message       varchar2(4000);
    l_inventory_item_id   number;
    l_bypass_flag         varchar2(1);
    l_return_status       varchar2(1) := fnd_api.g_ret_sts_success;
    l_error_rec           csi_datastructures_pub.transaction_error_rec;
    publish_error         exception;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

   csi_t_gen_utility_pvt.build_file_name(
      p_file_segment1 => 'csiinv',
      p_file_segment2 => 'hook');

    debug('START IB integration from EAM process :'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
    debug('  wip_entity_id       : '||p_wip_entity_id);
    debug('  organization_id     : '||p_organization_id);

    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
    END IF;

    l_bypass_flag := nvl(csi_datastructures_pub.g_install_param_rec.sfm_queue_bypass_flag, 'N');

    debug('  bypass flag         : '||l_bypass_flag);

    l_error_rec.source_type          := 'CSIEAMRR';
    l_error_rec.source_id            := p_instance_id;
    l_error_rec.source_header_ref_id := p_wip_entity_id;
    l_error_rec.source_line_ref_id   := p_organization_id;
    l_error_rec.transaction_type_id  := 93;
    l_error_rec.processed_flag       := 'E';

    IF l_bypass_flag = 'N' THEN

      debug('  publishing message CSIEAMRR for '||p_instance_id);

      XNP_CSIEAMRR_U.publish(
        xnp$wip_entity_id     => p_wip_entity_id,
        xnp$organization_id   => p_organization_id,
        xnp$instance_id       => p_instance_id,
        x_message_id          => l_message_id,
        x_error_code          => l_error_code,
        x_error_message       => l_error_message);

      IF l_error_message is not null THEN
        RAISE publish_error;
      END IF;

    ELSE

      debug('  bypassing the SFM Queue for CSIEAMRR '||p_instance_id);

      csi_wip_trxs_pkg.eam_rebuildable_return(
        p_wip_entity_id    => p_wip_entity_id,
        p_organization_id  => p_organization_id,
        p_instance_id      => p_instance_id,
        px_trx_error_rec   => l_error_rec,
        x_return_status    => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      csi_inv_trxs_pkg.log_csi_error(l_error_rec);
      x_return_status := fnd_api.g_ret_sts_success;
    WHEN publish_error THEN
      csi_inv_trxs_pkg.log_csi_error(l_error_rec);
      x_return_status := fnd_api.g_ret_sts_success;
  END rebuildable_return;

END csi_eam_interface_grp;

/

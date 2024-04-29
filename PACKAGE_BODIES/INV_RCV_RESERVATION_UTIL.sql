--------------------------------------------------------
--  DDL for Package Body INV_RCV_RESERVATION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RCV_RESERVATION_UTIL" AS
/* $Header: INVRUTLB.pls 120.20.12010000.3 2009/07/24 11:31:19 asugandh ship $*/

g_source_type_oe NUMBER := inv_reservation_global.g_source_type_oe;
g_source_type_po NUMBER := inv_reservation_global.g_source_type_po;
g_source_type_asn NUMBER := inv_reservation_global.g_source_type_asn;
g_source_type_internal_req NUMBER := inv_reservation_global.g_source_type_internal_req;
g_source_type_internal_ord NUMBER := inv_reservation_global.g_source_type_internal_ord;
g_source_type_in_transit NUMBER := inv_reservation_global.g_source_type_intransit;
g_source_type_inv NUMBER := inv_reservation_global.g_source_type_inv;
g_source_type_rcv NUMBER := inv_reservation_global.g_source_type_rcv;
g_source_type_wip NUMBER := inv_reservation_global.g_source_type_wip;

g_query_demand_ship_date_desc NUMBER := inv_reservation_global.g_query_demand_ship_date_desc;
g_query_demand_ship_date_asc  NUMBER := inv_reservation_global.g_query_demand_ship_date_asc ;

PROCEDURE print_debug(p_err_msg VARCHAR2
		      ,p_module IN VARCHAR2
		      ,p_level NUMBER DEFAULT 4)
  IS
     l_debug NUMBER;
BEGIN
   l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   inv_mobile_helper_functions.tracelog
     (p_err_msg => p_err_msg
      ,p_module => 'INV_RCV_RESERVATION_UTIL.'||p_module
      ,p_level => p_level);
END;

PROCEDURE update_wdd
  (x_return_status OUT NOCOPY 	VARCHAR2
   ,x_msg_count    OUT NOCOPY 	NUMBER
   ,x_msg_data     OUT NOCOPY 	VARCHAR2
   ,p_wdd_id           IN NUMBER
   ,p_released_status IN VARCHAR2
   ,p_mol_id          IN NUMBER
   ) IS

      --l_detail_info_tab wsh_glbl_var_strct_grp.delivery_details_attr_tbl_type;
      --l_in_rec          wsh_glbl_var_strct_grp.detailinrectype;
      --l_out_Rec         wsh_glbl_var_strct_grp.detailoutrectype;

      l_detail_info_tab WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type;
      l_in_rec          WSH_INTERFACE_EXT_GRP.detailInRecType;
      l_out_rec         WSH_INTERFACE_EXT_GRP.detailOutRecType;


      l_return_status VARCHAR2(1);
      l_msg_count     NUMBER;
      l_msg_data      VARCHAR2(2000);

      l_debug    NUMBER;
      l_progress VARCHAR2(10);
      l_module_name VARCHAR2(30);

BEGIN

   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'UPDATE_WDD';

   l_progress := '@@@';

   IF (l_debug = 1) THEN
      print_debug('Entering update_wdd...',l_module_name,4);
      print_debug(' p_wdd_id          => ' ||p_wdd_id,l_module_name,4);
      print_debug(' p_mol_id          => ' ||p_mol_id,l_module_name,4);
      print_debug(' p_released_status => ' ||p_released_status,l_module_name,4);
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;

   l_progress := '@@@';

   l_detail_info_tab(1).delivery_detail_id := p_wdd_id;

   IF (p_released_status IS NOT NULL) THEN
      l_progress := '@@@';
      l_detail_info_tab(1).released_status := p_released_status;
    ELSE
      l_progress := '@@@';
      --If we don't populate released_status, shipping's API
      --will update it to NULL.  So pass 'S' here since
      --when p_released_status is null, we will always be calling
      --update_wdd for WDD that have status 'S'
      l_detail_info_tab(1).released_status := 'S';
   END IF;

   IF (p_mol_id IS NOT NULL) THEN
      l_progress := '@@@';
      l_detail_info_tab(1).move_order_line_id := p_mol_id;
   END IF;

   l_progress := '@@@';
   l_in_rec.caller 			      := 'WMS_XDOCK_INVRUTLB';
   l_in_rec.action_code 		      := 'UPDATE';

   IF (l_debug = 1) THEN
      print_debug('Calling wsh_interface_ext_grp.create_update_delivery_detail',l_module_name,4);
   END IF;

   l_progress := '@@@';
   wsh_interface_ext_grp.create_update_delivery_detail
     (p_api_version_number      => 1.0,
      p_init_msg_list           => fnd_api.g_false,
      p_commit                  => fnd_api.g_false,
      x_return_status           => l_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data,
      p_detail_info_tab         => l_detail_info_tab,
      p_in_rec                  => l_in_rec,
      x_out_rec                 => l_out_rec);
   l_progress := '@@@';

   IF (l_debug = 1) THEN
      print_debug('Returned from wsh_interface_ext_grp.create_update_delivery_detail',l_module_name,4);
      print_debug('l_return_status =>'||l_return_status,l_module_name,4);
   END IF;

   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      l_progress := '@@@';
      IF (l_debug = 1) THEN
	 print_debug('wsh_interface_ext_grp.create_update_delivery_detail returned with error',l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	 print_debug('Raising Exception!!!',l_module_name,4);
      END IF;
      l_progress := '@@@';
      RAISE fnd_api.g_exc_unexpected_error;
    ELSE
      IF (l_debug = 1) THEN
	 print_debug('wsh_interface_ext_grp.create_update_delivery_detail returned with success',l_module_name,4);
      END IF;
      l_progress := '@@@';
   END IF;

   IF (l_debug = 1) THEN
      print_debug('Exitting update_wdd with the following values:',l_module_name,4);
      print_debug('x_return_status  => '||x_return_status,l_module_name,4);
      print_debug('x_msg_count      => '||x_msg_count,l_module_name,4);
      print_debug('x_msg_data       => '||x_msg_data,l_module_name,4);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred at progress:'||l_progress,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
      END IF;
      x_return_status :=  fnd_api.g_ret_sts_error;
END update_wdd;

PROCEDURE split_wdd
  (x_return_status OUT NOCOPY 	VARCHAR2
   ,x_msg_count    OUT NOCOPY 	NUMBER
   ,x_msg_data     OUT NOCOPY 	VARCHAR2
   ,x_new_wdd_id   OUT NOCOPY   NUMBER
   ,p_wdd_id       IN           NUMBER
   ,p_new_mol_id   IN           NUMBER
   ,p_qty_to_splt  IN           NUMBER
   ) IS
      l_action_prms    wsh_glbl_var_strct_grp.dd_action_parameters_rec_type;
      l_action_out_rec wsh_glbl_var_strct_grp.dd_action_out_rec_type;
      l_detail_ids     wsh_util_core.id_tab_type;
      l_tmp            NUMBER;

      l_return_status VARCHAR2(1);
      l_msg_count     NUMBER;
      l_msg_data      VARCHAR2(2000);
      l_debug    NUMBER;
      l_progress VARCHAR2(10);
      l_module_name VARCHAR2(30);
BEGIN

   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'SPLIT_WDD';
   x_return_status := fnd_api.g_ret_sts_success;

   IF (l_debug = 1) THEN
      print_debug('Entering split_wdd...',l_module_name,4);
      print_debug(' p_wdd_id      => ' ||p_wdd_id,l_module_name,4);
      print_debug(' p_new_mol_id  => ' ||p_new_mol_id,l_module_name,4);
      print_debug(' p_qty_to_splt => ' ||p_qty_to_splt,l_module_name,4);
   END IF;

   l_progress := '@@@';

   l_detail_ids(1) := p_wdd_id;
   l_action_prms.caller := 'WMS_XDOCK_INVRUTLB';
   l_action_prms.action_code := 'SPLIT-LINE';
   l_action_prms.split_quantity := p_qty_to_splt;

   l_progress := '@@@';

   IF (l_debug = 1) THEN
      print_debug('Calling wsh_interface_grp.delivery_detail_action',l_module_name,4);
   END IF;

   wsh_interface_grp.delivery_detail_action
     (p_api_version_number    => 1.0,
      p_init_msg_list         => fnd_api.g_false,
      p_commit                => fnd_api.g_false,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data,
      p_detail_id_tab         => l_detail_ids,
      p_action_prms           => l_action_prms ,
      x_action_out_rec        => l_action_out_rec);

   l_progress := '@@@';

   IF (l_debug = 1) THEN
      print_debug('Returned from wsh_interface_grp.delivery_detail_action',l_module_name,4);
      print_debug('l_return_status =>'||l_return_status,l_module_name,4);
   END IF;

   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
	 print_debug('wsh_interface_grp.delivery_detail_action returned with error',l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	 print_debug('Raising Exception!!!',l_module_name,4);
      END IF;
      l_progress := '@@@';
      RAISE fnd_api.g_exc_unexpected_error;
    ELSE
      l_progress := '@@@';

      l_tmp := l_action_out_rec.result_id_tab.first;
      x_new_wdd_id := l_action_out_rec.result_id_tab(l_tmp);

      IF (l_debug = 1) THEN
	 print_debug('wsh_interface_grp.delivery_detail_action returned with success',l_module_name,4);
	 print_debug('l_action_out_rec.split_quantity  => '||l_action_out_rec.split_quantity,l_module_name,4);
	 print_debug('l_action_out_rec.split_quantity2 => '||l_action_out_rec.split_quantity2,l_module_name,4);
	 print_debug('l_tmp                            => '||l_tmp,l_module_name,4);
	 print_debug('x_new_detail_id                  => '||l_action_out_rec.result_id_tab(l_tmp),l_module_name,4);
      END IF;
   END IF;

   l_progress := '@@@';

   IF (p_new_mol_id IS NOT NULL) THEN
      IF (l_debug = 1) THEN
	 print_debug('Calling update_wdd',l_module_name,4);
      END IF;

      l_progress := '@@@';
      update_wdd
	(x_return_status            => l_return_status
	 ,x_msg_count               => l_msg_count
	 ,x_msg_data                => l_msg_data
	 ,p_wdd_id                  => x_new_wdd_id
	 ,p_released_status         => NULL
	 ,p_mol_id                  => p_new_mol_id);
      l_progress := '@@@';

      IF (l_debug = 1) THEN
	 print_debug('Returned from update_wdd',l_module_name,4);
	 print_debug('l_return_status =>'||l_return_status,l_module_name,4);
      END IF;

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	 l_progress := '@@@';
	 IF (l_debug = 1) THEN
	    print_debug('update_wdd returned with error',l_module_name,4);
	    print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	    print_debug('Raising Exception!!!',l_module_name,4);
	 END IF;
	 l_progress := '@@@';
	 RAISE fnd_api.g_exc_unexpected_error;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('update_wdd returned with success',l_module_name,4);
	 END IF;
      l_progress := '@@@';
      END IF;
   END IF;

   IF (l_debug = 1) THEN
      print_debug('Exitting split_wdd with the following values:',l_module_name,4);
      print_debug('x_return_status  => '||x_return_status,l_module_name,4);
      print_debug('x_msg_count      => '||x_msg_count,l_module_name,4);
      print_debug('x_msg_data       => '||x_msg_data,l_module_name,4);
      print_debug('x_new_wdd_id     => '||x_new_wdd_id,l_module_name,4);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred at progress: '||l_progress,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
      END IF;
      x_return_status :=  fnd_api.g_ret_sts_error;
END split_wdd;

PROCEDURE query_reservation
  (p_query_input       IN inv_reservation_global.mtl_reservation_rec_type
   ,p_sort_by_req_date IN NUMBER
   ,x_rsv_results      OUT nocopy inv_reservation_global.mtl_reservation_tbl_type
   ,x_return_status    OUT nocopy VARCHAR2
   ) IS

      l_rsv_results_count NUMBER;
      l_error_code        NUMBER;
      l_return_status     VARCHAR2(1);
      l_msg_count         NUMBER;
      l_msg_data          VARCHAR2(2000);

      l_debug    NUMBER;
      l_progress VARCHAR2(10);
      l_module_name VARCHAR2(30);
BEGIN

   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'QUERY_RESERVATION';
   x_return_status := fnd_api.g_ret_sts_success;

   IF NOT wms_install.check_install(l_return_status,
				    l_msg_count,
				    l_msg_data,
				    p_query_input.organization_id) THEN
      IF (l_debug = 1) THEN
	 print_debug('This is not a WMS org.  No need to deal with reservation here.',l_module_name,4);
      END IF;
      RETURN;
   END IF;

   IF (l_debug = 1) THEN
      print_debug('Calling inv_reservation_pub.query_reservation',l_module_name,4);
   END IF;

   inv_reservation_pub.query_reservation
     (p_api_version_number          => 1.0
      , x_return_status             => l_return_status
      , x_msg_count                 => l_msg_count
      , x_msg_data                  => l_msg_data
      , p_query_input               => p_query_input
      , p_lock_records              => fnd_api.g_true --???
      , p_sort_by_req_date          => p_sort_by_req_date
      , x_mtl_reservation_tbl       => x_rsv_results
      , x_mtl_reservation_tbl_count => l_rsv_results_count
      , x_error_code                => l_error_code
      );

   IF (l_debug = 1) THEN
      print_debug('Returned from inv_reservation_pub.query_reservation',l_module_name,4);
      print_debug('x_return_status: '||l_return_status,l_module_name,4);
   END IF;

   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
	 print_debug('x_error_code: '||l_error_code,l_module_name,4);
	 print_debug('x_msg_data:   '||l_msg_data,l_module_name,4);
	 print_debug('x_msg_count:  '||l_msg_count,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	 print_debug('Raising Exception!!!',l_module_name,4);
      END IF;
      l_progress := '@@@';
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   l_progress := '@@@';

   IF (l_debug = 1) THEN
      print_debug('x_rsv_results.COUNT:     '||x_rsv_results.COUNT,l_module_name,4);
      print_debug('l_rsv_results_count:     '||l_rsv_results_count,l_module_name,4);
      print_debug('Exiting query_reservation with success',l_module_name,4);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred at progress: '||l_progress,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	 print_debug('Exiting query_reservation with error',l_module_name,4);
      END IF;
      x_return_status :=  fnd_api.g_ret_sts_error;
END query_reservation;

PROCEDURE transfer_reservation
  (p_original_rsv_rec IN inv_reservation_global.mtl_reservation_rec_type
   ,p_to_rsv_rec      IN inv_reservation_global.mtl_reservation_rec_type
   ,x_new_rsv_id      OUT nocopy NUMBER
   ,x_return_status   OUT nocopy VARCHAR2)
  IS
      l_dummy_serial      inv_reservation_global.serial_number_tbl_type;
      l_return_status     VARCHAR2(1);
      l_msg_count         NUMBER;
      l_msg_data          VARCHAR2(2000);

      l_debug    NUMBER;
      l_progress VARCHAR2(10);
      l_module_name VARCHAR2(30);
BEGIN
   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'TRANSFER_RESERVATIONS';

   x_return_status := fnd_api.g_ret_sts_success;

   IF NOT wms_install.check_install(l_return_status,
				    l_msg_count,
				    l_msg_data,
				    p_original_rsv_rec.organization_id) THEN
      IF (l_debug = 1) THEN
	 print_debug('This is not a WMS org.  No need to deal with reservation here.',l_module_name,4);
      END IF;
      RETURN;
   END IF;

   IF (l_debug = 1) THEN
      print_debug('Calling inv_reservation_pub.transfer_reservation',l_module_name,4);
   END IF;

   inv_reservation_pub.transfer_reservation
     (p_api_version_number         => 1.0
      ,x_return_status              => l_return_status
      ,x_msg_count                  => l_msg_count
      ,x_msg_data                   => l_msg_data
      ,p_original_rsv_rec           => p_original_rsv_rec
      ,p_to_rsv_rec                 => p_to_rsv_rec
      ,p_original_serial_number     => l_dummy_serial
      ,p_to_serial_number           => l_dummy_serial
      ,p_validation_flag            => fnd_api.g_false --??
      ,x_to_reservation_id          => x_new_rsv_id);

   IF (l_debug = 1) THEN
      print_debug('Returned from inv_reservation_pub.transfer_reservation',l_module_name,4);
      print_debug('x_return_status =>'||l_return_status,l_module_name,4);
   END IF;

   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
	 print_debug('x_msg_data:  '||l_msg_data,l_module_name,4);
	 print_debug('x_msg_count: '||l_msg_count,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	 print_debug('Raising Exception!!!',l_module_name,4);
      END IF;
      l_progress := '@@@';
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   l_progress := '@@@';

   IF (l_debug = 1) THEN
      print_debug('x_new_rsv_id = '||x_new_rsv_id,l_module_name,4);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred at progress: '||l_progress,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	 print_debug('Exiting transfer_reservation with error',l_module_name,4);
      END IF;
      x_return_status :=  fnd_api.g_ret_sts_error;
END transfer_reservation;

PROCEDURE relieve_reservation
  (p_rsv_rec IN inv_reservation_global.mtl_reservation_rec_type
   ,p_prim_qty_to_relieve IN NUMBER
   ,x_return_status OUT nocopy VARCHAR2
   )
  IS
     l_dummy_serial          inv_reservation_global.serial_number_tbl_type;
     l_tmp_prim_relieved_qty NUMBER;
     l_tmp_prim_remain_qty   NUMBER;

     l_return_status         VARCHAR2(1);
     l_msg_count             NUMBER;
     l_msg_data              VARCHAR2(2000);

     l_debug    NUMBER;
     l_progress VARCHAR2(10);
     l_module_name VARCHAR2(30);

BEGIN

   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'RELIEVE_RESERVATIONS';

   x_return_status := fnd_api.g_ret_sts_success;

   IF NOT wms_install.check_install(l_return_status,
				    l_msg_count,
				    l_msg_data,
				    p_rsv_rec.organization_id) THEN
      IF (l_debug = 1) THEN
	 print_debug('This is not a WMS org.  No need to deal with reservation here.',l_module_name,4);
      END IF;
      RETURN;
   END IF;

   IF (l_debug = 1) THEN
      print_debug('Calling inv_reservation_pub.relieve_reservation',l_module_name,4);
      print_debug('  p_relieve_all =>               '||fnd_api.g_false,l_module_name,4);
      print_debug('  p_primary_relieved_quantity => '||p_prim_qty_to_relieve,l_module_name,4);
   END IF;

   inv_reservation_pub.relieve_reservation
     (p_api_version_number         => 1.0
      , x_return_status            => l_return_status
      , x_msg_count                => l_msg_count
      , x_msg_data                 => l_msg_data
      , p_rsv_rec                  => p_rsv_rec
      , p_primary_relieved_quantity=> p_prim_qty_to_relieve
      , p_original_serial_number   => l_dummy_serial
      , x_primary_relieved_quantity=> l_tmp_prim_relieved_qty
      , x_primary_remain_quantity  => l_tmp_prim_remain_qty
      , p_relieve_all              => fnd_api.g_false
      );

   IF (l_debug = 1) THEN
      print_debug('Returned from inv_reservation_pub.query_reservation',l_module_name,4);
      print_debug('x_return_status: '||l_return_status,l_module_name,4);
   END IF;

   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
	 print_debug('x_msg_data:   '||l_msg_data,l_module_name,4);
	 print_debug('x_msg_count:  '||l_msg_count,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	 print_debug('Raising Exception!!!',l_module_name,4);
      END IF;
      l_progress := '@@@';
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   l_progress := '@@@';

   IF (l_debug = 1) THEN

      print_debug('l_tmp_prim_relieved_qty: '||l_tmp_prim_relieved_qty,4);
      print_debug('l_tmp_prim_remain_qty:   '||l_tmp_prim_remain_qty,4);
      print_debug('Exiting relieve_reservation with success',l_module_name,4);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred at progress:'||l_progress,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	 print_debug('Exiting relieve_reservation with success',l_module_name,4);
      END IF;
      x_return_status :=  fnd_api.g_ret_sts_error;
END relieve_reservation;

PROCEDURE delete_reservation
  (p_rsv_rec  IN inv_reservation_global.mtl_reservation_rec_type
   ,x_return_status OUT nocopy VARCHAR2)
  IS
     l_dummy_serial      inv_reservation_global.serial_number_tbl_type;
     l_return_status     VARCHAR2(1);
     l_msg_count         NUMBER;
     l_msg_data          VARCHAR2(2000);

     l_debug    NUMBER;
     l_progress VARCHAR2(10);
     l_module_name VARCHAR2(30);

BEGIN

   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'DELETE_RESERVATION';

   IF NOT wms_install.check_install(l_return_status,
				    l_msg_count,
				    l_msg_data,
				    p_rsv_rec.organization_id) THEN
      IF (l_debug = 1) THEN
	 print_debug('This is not a WMS org.  No need to deal with reservation here.',l_module_name,4);
      END IF;
      RETURN;
   END IF;

   IF (l_debug = 1) THEN
      print_debug('Calling inv_reservation_pub.delete_reservation',l_module_name,4);
   END IF;

   inv_reservation_pub.delete_reservation
     (p_api_version_number       => 1.0
      , x_return_status          => l_return_status
      , x_msg_count              => l_msg_count
      , x_msg_data               => l_msg_data
      , p_rsv_rec                => p_rsv_rec
      , p_serial_number          => l_dummy_serial
       );

   IF (l_debug = 1) THEN
      print_debug('Returned from inv_reservation_pub.delete_reservation',l_module_name,4);
      print_debug('x_return_status =>'||l_return_status,l_module_name,4);
   END IF;

   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
	 print_debug('x_msg_data:  '||l_msg_data,l_module_name,4);
	 print_debug('x_msg_count: '||l_msg_count,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	 print_debug('Raising Exception!!!',l_module_name,4);
      END IF;
      l_progress := '@@@';
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   l_progress := '@@@';

   IF (l_debug = 1) THEN
      print_debug('Exiting delete_reservation with success',l_module_name,4);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred at progress: '||l_progress,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	 print_debug('Exiting delete_reservation with error',l_module_name,4);
      END IF;
      x_return_status :=  fnd_api.g_ret_sts_error;
END delete_reservation;

PROCEDURE reduce_reservation
  (p_mtl_rsv_rec    IN inv_reservation_global.mtl_maintain_rsv_rec_type
   ,x_return_status OUT nocopy VARCHAR2
   )
  IS
     l_qty_modified      NUMBER;

     l_return_status VARCHAR2(1);
     l_msg_count     NUMBER;
     l_msg_data      VARCHAR2(2000);

     l_debug    NUMBER;
     l_progress VARCHAR2(10);
     l_module_name VARCHAR2(30);

BEGIN

   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'REDUCE_RESERVATION';

   IF NOT wms_install.check_install(l_return_status,
				    l_msg_count,
				    l_msg_data,
				    p_mtl_rsv_rec.organization_id) THEN
      IF (l_debug = 1) THEN
	 print_debug('This is not a WMS org.  No need to deal with reservation here.',l_module_name,4);
      END IF;
      RETURN;
   END IF;

   IF (l_debug = 1) THEN
      print_debug('Calling inv_maintain_reservations_pub.reduce_reservation',l_module_name,4);
   END IF;
   inv_maintain_reservation_pub.reduce_reservation
       (x_return_status          => l_return_status
  	, x_msg_count            => l_msg_count
	, x_msg_data             => l_msg_data
	, x_quantity_modified    => l_qty_modified
  	, p_mtl_maintain_rsv_rec => p_mtl_rsv_rec
  	, p_delete_flag	         => fnd_api.g_true
	, p_sort_by_criteria     => g_query_demand_ship_date_desc --???
	);
   IF (l_debug = 1) THEN
      print_debug('Returned from inv_maintain_reservations_pub.reduce_reservation',l_module_name,4);
      print_debug('x_return_status =>'||l_return_status,l_module_name,4);
   END IF;

   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
	 print_debug('x_msg_data:  '||l_msg_data,l_module_name,4);
	 print_debug('x_msg_count: '||l_msg_count,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	 print_debug('Raising Exception!!!',l_module_name,4);
      END IF;
      l_progress := '@@@';
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   l_progress := '@@@';

   IF (l_debug = 1) THEN
      print_debug('inv_reservation_pub.transfer_reservation returned with success',l_module_name,4);
      print_debug('l_qty_modified = '||l_qty_modified,l_module_name,4);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred at progress: '||l_progress,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	 print_debug('Exiting reduce_reservation with error',l_module_name,4);
      END IF;
      x_return_status :=  fnd_api.g_ret_sts_error;
END reduce_reservation;

--This will be called from maintain_rsv_receive
PROCEDURE set_mol_wdd_tbl
  (p_orig_rcpt_rec      IN     inv_rcv_integration_pvt.cas_mol_rec_type
   ,p_cas_mol_rec_tb    IN OUT nocopy inv_rcv_integration_pvt.cas_mol_rec_tb_tp
   ,p_prim_qty          IN NUMBER
   ,p_wdd_id            IN NUMBER
   ,p_crossdock_type    IN NUMBER
   ) IS

      l_new_index NUMBER;
      l_txn_qty   NUMBER;
      l_sec_qty   NUMBER;

      l_return_status VARCHAR2(1);
      l_msg_count     NUMBER;
      l_msg_data      VARCHAR2(2000);

      l_debug    NUMBER;
      l_progress VARCHAR2(10);
      l_module_name VARCHAR2(30);

BEGIN

   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'SET_MOL_WDD_TBL';


   IF (l_debug = 1) THEN
      print_debug('Entering set_mol_wdd_tbl...',l_module_name,4);
      print_debug(' p_prim_qty                         => '||p_prim_qty,l_module_name,4);
      print_debug(' p_orig_rcpt_rec.uom_code           => '||p_orig_rcpt_rec.uom_code,l_module_name,4);
      print_debug(' p_orig_rcpt_rec.primary_uom_code   => '||p_orig_rcpt_rec.primary_uom_code,l_module_name,4);
      print_debug(' p_orig_rcpt_rec.secondary_quantity => '||p_orig_rcpt_rec.secondary_quantity ,l_module_name,4);
   END IF;

   l_txn_qty := inv_rcv_cache.convert_qty(p_orig_rcpt_rec.inventory_item_id
			    ,p_prim_qty
			    ,p_orig_rcpt_rec.primary_uom_code
			    ,p_orig_rcpt_rec.uom_code);

   IF (Nvl(p_orig_rcpt_rec.secondary_quantity,0) <> 0) THEN
      l_sec_qty := Round((p_prim_qty*p_orig_rcpt_rec.secondary_quantity)/p_orig_rcpt_rec.primary_qty,
			 inv_rcv_cache.g_conversion_precision);
   END IF;

   IF p_cas_mol_rec_tb.exists(Nvl(p_wdd_id,-1)) THEN
      p_cas_mol_rec_tb(Nvl(p_wdd_id,-1)).primary_qty := p_cas_mol_rec_tb(Nvl(p_wdd_id,-1)).primary_qty+p_prim_qty;
      p_cas_mol_rec_tb(Nvl(p_wdd_id,-1)).quantity := p_cas_mol_rec_tb(Nvl(p_wdd_id,-1)).quantity+l_txn_qty;
      p_cas_mol_rec_tb(Nvl(p_wdd_id,-1)).secondary_quantity := p_cas_mol_rec_tb(Nvl(p_wdd_id,-1)).secondary_quantity+l_sec_qty;
    ELSE
      p_cas_mol_rec_tb(Nvl(p_wdd_id,-1)) := p_orig_rcpt_rec;
      p_cas_mol_rec_tb(Nvl(p_wdd_id,-1)).primary_qty := p_prim_qty;
      p_cas_mol_rec_tb(Nvl(p_wdd_id,-1)).quantity := l_txn_qty;
      p_cas_mol_rec_tb(Nvl(p_wdd_id,-1)).backorder_delivery_detail_id := p_wdd_id;
      p_cas_mol_rec_tb(Nvl(p_wdd_id,-1)).crossdock_type := p_crossdock_type;
      p_cas_mol_rec_tb(Nvl(p_wdd_id,-1)).secondary_quantity := l_sec_qty;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Error in set_mol_wdd_tbl...',l_module_name,4);
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
END set_mol_wdd_tbl;

PROCEDURE maintain_rsv_import_asn
  (x_return_status        OUT NOCOPY 	VARCHAR2
   ,x_msg_count           OUT NOCOPY 	NUMBER
   ,x_msg_data            OUT NOCOPY 	VARCHAR2
   ,p_cas_mol_rec_tb      IN inv_rcv_integration_pvt.cas_mol_rec_tb_tp
   ) IS
      l_rsv_query_rec      inv_reservation_global.mtl_reservation_rec_type;
      l_rsv_results_tbl    inv_reservation_global.mtl_reservation_tbl_type;
      l_rsv_update_rec     inv_reservation_global.mtl_reservation_rec_type;
      l_rsv_results_count  NUMBER;
      l_remaining_prim_qty NUMBER;
      l_reservation_id     NUMBER;
      l_new_wdd_id         NUMBER;
      l_dummy_serial       VARCHAR2(30);
      l_dummy              NUMBER;

      l_return_status VARCHAR2(1);
      l_error_code    NUMBER;
      l_msg_count     NUMBER;
      l_msg_data      VARCHAR2(2000);

      l_debug    NUMBER;
      l_progress VARCHAR2(10);
      l_module_name VARCHAR2(30);

BEGIN

   --{{
   --********** PROCEDURE maintain_rsv_import_asn *********}}

   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'maintain_rsv_import_asn';
   x_return_status := fnd_api.g_ret_sts_success;

   IF (l_debug = 1) THEN
      print_debug('Entering maintain_rsv_import_asn...',l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).po_header_id        => '||p_cas_mol_rec_tb(1).po_header_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).po_line_location_id => '||p_cas_mol_rec_tb(1).po_line_location_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).inventory_item_id   => '||p_cas_mol_rec_tb(1).inventory_item_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).organization_id     => '||p_cas_mol_rec_tb(1).organization_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).primary_qty         => '||p_cas_mol_rec_tb(1).primary_qty,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).shipment_line_id    => '||p_cas_mol_rec_tb(1).shipment_line_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).project_id          => '||p_cas_mol_rec_tb(1).project_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).task_id             => '||p_cas_mol_rec_tb(1).task_id,l_module_name,4);
   END IF;

   --{{
   --Test import asn for the following cases:
   --1. Import an ASN whose document matches to a manual reservation
   --2. Import an ASN whose document matches to a xdock reservation
   --3. Import an ASN whose document does not match to any reservations
   --4. Import an ASN whose document matches to mixed reservations types }}

   --1.0 Query reservation for the particular PO
   l_rsv_query_rec.supply_source_type_id   := g_source_type_po;
   l_rsv_query_rec.supply_source_header_id := p_cas_mol_rec_tb(1).po_header_id;
   l_rsv_query_rec.supply_source_line_id   := p_cas_mol_rec_tb(1).po_line_location_id;
   l_rsv_query_rec.inventory_item_id       := p_cas_mol_rec_tb(1).inventory_item_id;
   l_rsv_query_rec.organization_id         := p_cas_mol_rec_tb(1).organization_id;

   IF (p_cas_mol_rec_tb(1).project_id IS NOT NULL) THEN
      l_rsv_query_rec.project_id := p_cas_mol_rec_tb(1).project_id;
      IF (p_cas_mol_rec_tb(1).task_id IS NOT NULL) THEN
	 l_rsv_query_rec.task_id := p_cas_mol_rec_tb(1).task_id;
      END IF;
   END IF ;

   l_progress := '@@@';
   BEGIN
      SELECT 1
	INTO l_dummy
	FROM po_line_locations_all
	WHERE line_location_id = p_cas_mol_rec_tb(1).po_line_location_id
	FOR UPDATE NOWAIT;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('Some other exception occurred!',l_module_name,4);
	    print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	 END IF;
	 l_progress := '@@@';
	 RAISE fnd_api.g_exc_unexpected_error;
   END;
   l_progress := '@@@';

   IF (l_debug = 1) THEN
      print_debug('Calling query_reservation',l_module_name,4);
   END IF;

   --2.0 Query reservation
   l_progress := '@@@';
   query_reservation
     (p_query_input => l_rsv_query_rec
      ,p_sort_by_req_date => g_query_demand_ship_date_asc
      ,x_rsv_results => l_rsv_results_tbl
      ,x_return_status => l_return_status
      );
   l_progress := '@@@';

   IF (l_debug = 1) THEN
      print_debug('Returned from query_reservation',l_module_name,4);
      print_debug('x_return_status: '||l_return_status,l_module_name,4);
   END IF;

   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      l_progress := '@@@';
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   l_remaining_prim_qty := p_cas_mol_rec_tb(1).primary_qty;

   IF (l_debug = 1) THEN
      print_debug('l_remaining_prim_qty    = ' ||l_remaining_prim_qty,l_module_name,4);
      print_debug('l_rsv_results_tbl.COUNT = ' ||l_rsv_results_tbl.COUNT,l_module_name,4);
   END IF;

   FOR i IN 1..l_rsv_results_tbl.COUNT LOOP
      EXIT WHEN l_remaining_prim_qty <= 0;

      IF (l_debug = 1) THEN
	 print_debug('l_remaining_prim_qty:'||l_remaining_prim_qty||
		     ' i:'||i||
		     ' rsv_id:'||l_rsv_results_tbl(i).reservation_id||
		     ' prim_qty:'||l_rsv_results_tbl(i).primary_reservation_quantity||
		     ' rsv_qty:'||l_rsv_results_tbl(i).reservation_quantity||
		     ' uom_code:'||l_rsv_results_tbl(i).reservation_uom_code||
		     ' orig_supply_src_type_id:'||l_rsv_results_tbl(i).orig_supply_source_type_id||
		     ' demand_src_line_detail:'||l_rsv_results_tbl(i).demand_source_line_detail||
		     ' ext_src_code:'||l_rsv_results_tbl(i).external_source_code
		     ,l_module_name,4);
      END IF;

      l_rsv_update_rec := l_rsv_results_tbl(i);

      IF (l_rsv_results_tbl(i).primary_reservation_quantity > l_remaining_prim_qty) THEN
	 -- Reservation has more than enough to satisfy remaining qty, so split

	 IF (l_debug = 1) THEN
	    print_debug('l_rsv_results_tbl(i).primary_reservation_quantity > l_remaining_prim_qty',
			l_module_name,4);
	 END IF;

	 l_rsv_update_rec.primary_reservation_quantity := l_remaining_prim_qty;
	 l_rsv_update_rec.reservation_quantity := inv_rcv_cache.convert_qty(p_cas_mol_rec_tb(1).inventory_item_id
							      ,l_remaining_prim_qty
							      ,l_rsv_results_tbl(i).primary_uom_code
							      ,l_rsv_results_tbl(i).reservation_uom_code);

	 IF (l_rsv_results_tbl(i).demand_source_line_detail IS NOT NULL) THEN
	    IF (l_debug = 1) THEN
	       print_debug('Calling split_wdd',l_module_name,4);
	    END IF;

	    l_progress := '@@@';
	    split_wdd
	      (x_return_status => l_return_status
	       ,x_msg_count    => l_msg_count
	       ,x_msg_data     => l_msg_data
	       ,x_new_wdd_id   => l_new_wdd_id
	       ,p_wdd_id       => l_rsv_results_tbl(i).demand_source_line_detail
	       ,p_new_mol_id   => NULL
	       ,p_qty_to_splt  => l_remaining_prim_qty);
	    l_progress := '@@@';

	    IF (l_debug = 1) THEN
	       print_debug('Returned from split_wdd',l_module_name,4);
	       print_debug('l_return_status =>'||l_return_status,l_module_name,4);
	    END IF;

	    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	       l_progress := '@@@';
	       RAISE fnd_api.g_exc_unexpected_error;
	    END IF;

	    l_rsv_update_rec.demand_source_line_detail := l_new_wdd_id;
	 END IF;

	 l_remaining_prim_qty := 0;

       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('l_rsv_results_tbl(i).primary_reservation_quantity <= l_remaining_prim_qty',
			l_module_name,4);
	 END IF;
	 l_remaining_prim_qty := l_remaining_prim_qty - l_rsv_results_tbl(i).primary_reservation_quantity;
      END IF; --END IF (l_rsv_results_tbl(i).primary_reservation_quantity > l_remaining_prim_qty)

      --Transfer reservation to ASN
      l_rsv_update_rec.supply_source_type_id     := g_source_type_asn;
      l_rsv_update_rec.supply_source_line_detail := p_cas_mol_rec_tb(1).shipment_line_id;

      IF (l_debug = 1) THEN
	 print_debug('Calling transfer_reservation...',l_module_name,4);
      END IF;

      transfer_reservation
	(p_original_rsv_rec => l_rsv_results_tbl(i)
	 ,p_to_rsv_rec      => l_rsv_update_rec
	 ,x_new_rsv_id      => l_reservation_id
	 ,x_return_status   => l_return_status);

      IF (l_debug = 1) THEN
	 print_debug('Returned from transfer_reservation',l_module_name,4);
	 print_debug('x_return_status: '||l_return_status,l_module_name,4);
      END IF;

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	 l_progress := '@@@';
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_debug = 1) THEN
	 print_debug('l_reservation_id: '||l_reservation_id,l_module_name,4);
      END IF;

   END LOOP;

   IF (l_debug = 1) THEN
      print_debug('Exitting maintain_rsv_import_asn with the following values:',l_module_name,4);
      print_debug('x_return_status  => '||x_return_status,l_module_name,4);
      print_debug('x_msg_count      => '||x_msg_count,l_module_name,4);
      print_debug('x_msg_data       => '||x_msg_data,l_module_name,4);
   END IF;

   --{{
   --********** END PROCEDURE maintain_rsv_import_asn *********}}
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred at progress: '||l_progress,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
      END IF;
      x_return_status :=  fnd_api.g_ret_sts_error;
END maintain_rsv_import_asn;

PROCEDURE maintain_rsv_cancel_asn
  (x_return_status        OUT NOCOPY 	VARCHAR2
   ,x_msg_count           OUT NOCOPY 	NUMBER
   ,x_msg_data            OUT NOCOPY 	VARCHAR2
   ,p_cas_mol_rec_tb      IN inv_rcv_integration_pvt.cas_mol_rec_tb_tp
   ) IS
      l_rsv_query_rec      inv_reservation_global.mtl_reservation_rec_type;
      l_rsv_results_tbl    inv_reservation_global.mtl_reservation_tbl_type;
      l_rsv_update_rec     inv_reservation_global.mtl_reservation_rec_type;
      l_reservation_id     NUMBER;
      l_dummy         NUMBER;

      l_return_status VARCHAR2(1);
      l_error_code    NUMBER;
      l_msg_count     NUMBER;
      l_msg_data      VARCHAR2(2000);

      l_debug    NUMBER;
      l_progress VARCHAR2(10);
      l_module_name VARCHAR2(30);

BEGIN

   --{{
   --********** PROCEDURE maintain_rsv_cancel_asn *********}}

   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'MAINTAIN_RSV_CANCEL_ASN';
   x_return_status := fnd_api.g_ret_sts_success;

   IF (l_debug = 1) THEN
      print_debug('Entering maintain_rsv_cancel_asn...',l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).po_header_id        => '||p_cas_mol_rec_tb(1).po_header_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).po_line_location_id => '||p_cas_mol_rec_tb(1).po_line_location_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).inventory_item_id   => '||p_cas_mol_rec_tb(1).inventory_item_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).organization_id     => '||p_cas_mol_rec_tb(1).organization_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).primary_qty         => '||p_cas_mol_rec_tb(1).primary_qty,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).shipment_line_id    => '||p_cas_mol_rec_tb(1).shipment_line_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).project_id          => '||p_cas_mol_rec_tb(1).project_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).task_id             => '||p_cas_mol_rec_tb(1).task_id,l_module_name,4);
   END IF;

   --{{
   --Test 1) Cancelling an ASN that can be matched to a reservation whose original
   --        source type is 'ASN'
   --     2) Cancelling an ASN that can be matched to a reservation who original
   --        source type is not 'ASN' (it would probably be PO)
   --     3) Cancelling an ASN that does to match to any reservation}}

   l_rsv_query_rec.supply_source_type_id     := g_source_type_asn;
   l_rsv_query_rec.supply_source_header_id   := p_cas_mol_rec_tb(1).po_header_id;
   l_rsv_query_rec.supply_source_line_id     := p_cas_mol_rec_tb(1).po_line_location_id;
   l_rsv_query_rec.supply_source_line_detail := p_cas_mol_rec_tb(1).shipment_line_id;
   l_rsv_query_rec.inventory_item_id         := p_cas_mol_rec_tb(1).inventory_item_id;
   l_rsv_query_rec.organization_id           := p_cas_mol_rec_tb(1).organization_id;

   IF (p_cas_mol_rec_tb(1).project_id IS NOT NULL) THEN
      l_rsv_query_rec.project_id := p_cas_mol_rec_tb(1).project_id;
      IF (p_cas_mol_rec_tb(1).task_id IS NOT NULL) THEN
	 l_rsv_query_rec.task_id := p_cas_mol_rec_tb(1).task_id;
      END IF;
   END IF ;

   l_progress := '@@@';
   BEGIN
      SELECT 1
	INTO l_dummy
	FROM rcv_shipment_lines
	WHERE shipment_line_id = p_cas_mol_rec_tb(1).shipment_line_id
	FOR UPDATE NOWAIT;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('Some other exception occurred!',l_module_name,4);
	    print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	 END IF;
	 l_progress := '@@@';
	 RAISE fnd_api.g_exc_unexpected_error;
   END;
   l_progress := '@@@';

   IF (l_debug = 1) THEN
      print_debug('Calling query_reservation:',l_module_name,4);
   END IF;

   l_progress := '###';
   query_reservation
     (p_query_input => l_rsv_query_rec
      ,p_sort_by_req_date => g_query_demand_ship_date_asc
      ,x_rsv_results => l_rsv_results_tbl
      ,x_return_status => l_return_status
      );
   l_progress := '###';

   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      l_progress := '@@@';
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF (l_debug = 1) THEN
      print_debug('l_rsv_results_tbl.COUNT = ' ||l_rsv_results_tbl.COUNT,l_module_name,4);
   END IF;

   FOR i IN 1..l_rsv_results_tbl.COUNT LOOP
      IF (l_debug = 1) THEN
	 print_debug(' i:'||i||
		     ' rsv_id:'||l_rsv_results_tbl(i).reservation_id||
		     ' prim_qty:'||l_rsv_results_tbl(i).primary_reservation_quantity||
		     ' rsv_qty:'||l_rsv_results_tbl(i).reservation_quantity||
		     ' uom_code:'||l_rsv_results_tbl(i).reservation_uom_code||
		     ' orig_supply_src_type_id:'||l_rsv_results_tbl(i).orig_supply_source_type_id||
		     ' demand_src_line_detail:'||l_rsv_results_tbl(i).demand_source_line_detail||
		     ' ext_src_code:'||l_rsv_results_tbl(i).external_source_code||
		     ' orig_supply_src_code:'||l_rsv_results_tbl(i).orig_supply_source_type_id
		     ,l_module_name,4);
      END IF;

      IF (l_rsv_results_tbl(i).orig_supply_source_type_id = g_source_type_asn) THEN

	 IF (l_debug = 1) THEN
	    print_debug('Calling delete_reservation...',l_module_name,4);
	 END IF;


	 delete_reservation
	   (p_rsv_rec        => l_rsv_results_tbl(i)
	    ,x_return_status => l_return_status
	    );

	 IF (l_debug = 1) THEN
	    print_debug('Returned from delete_reservation',l_module_name,4);
	    print_debug('x_return_status: '||l_return_status,l_module_name,4);
	 END IF;

	 IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	       print_debug('Raising Exception!!!',l_module_name,4);
	    END IF;
	    l_progress := '@@@';
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
       ELSE --IF this is a manual rsv transferred from PO
	 l_rsv_update_rec := l_rsv_results_tbl(i);
	 l_rsv_update_rec.supply_source_type_id := g_source_type_po;
	 l_rsv_update_rec.supply_source_line_detail := NULL;

	 IF (l_debug = 1) THEN
	    print_debug('Calling transfer_reservation...',l_module_name,4);
	 END IF;

	 transfer_reservation
	   (p_original_rsv_rec => l_rsv_results_tbl(i)
	    ,p_to_rsv_rec      => l_rsv_update_rec
	    ,x_new_rsv_id      => l_reservation_id
	    ,x_return_status   => l_return_status);

	 IF (l_debug = 1) THEN
	    print_debug('Returned from transfer_reservation',l_module_name,4);
	    print_debug('x_return_status: '||l_return_status,l_module_name,4);
	 END IF;

	 IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    l_progress := '@@@';
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;

	 IF (l_debug = 1) THEN
	    print_debug('l_reservation_id: '||l_reservation_id,l_module_name,4);
	 END IF;
      END IF;--END l_rsv_results_tbl(i).external_source_code = 'XDOCK'
   END LOOP;

   IF (l_debug = 1) THEN
      print_debug('Exitting maintain_rsv_cancel_asn with the following values:',l_module_name,4);
      print_debug('x_return_status  => '||x_return_status,l_module_name,4);
      print_debug('x_msg_count      => '||x_msg_count,l_module_name,4);
      print_debug('x_msg_data       => '||x_msg_data,l_module_name,4);
   END IF;

   --{{
   --********** END PROCEDURE maintain_rsv_cancel_asn *********}}

EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred at progress: '||l_progress,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
      END IF;
      x_return_status :=  fnd_api.g_ret_sts_error;
END maintain_rsv_cancel_asn;

PROCEDURE maintain_rsv_receive
  (x_return_status        OUT NOCOPY 	VARCHAR2
   ,x_msg_count           OUT NOCOPY 	NUMBER
   ,x_msg_data            OUT NOCOPY 	VARCHAR2
   ,p_cas_mol_rec_tb      IN inv_rcv_integration_pvt.cas_mol_rec_tb_tp
   ,x_cas_mol_rec_tb      OUT nocopy inv_rcv_integration_pvt.cas_mol_rec_tb_tp
   ) IS
      l_rsv_query_rec         inv_reservation_global.mtl_reservation_rec_type;
      l_rsv_results_tbl       inv_reservation_global.mtl_reservation_tbl_type;
      l_rsv_update_rec        inv_reservation_global.mtl_reservation_rec_type;
      l_shipment_header_id    NUMBER;
      l_requisition_header_id NUMBER;
      l_rsv_results_count     NUMBER;
      l_remaining_prim_qty    NUMBER;
      l_new_rsv_id            NUMBER;
      l_new_wdd_id            NUMBER;
      l_dummy                 NUMBER;
      l_primary_qty           NUMBER;

      l_return_status  VARCHAR2(1);
      l_error_code    NUMBER;
      l_msg_count     NUMBER;
      l_msg_data      VARCHAR2(2000);

      l_debug    NUMBER;
      l_progress VARCHAR2(10);
      l_module_name VARCHAR2(30);

BEGIN

   --{{
   --********** PROCEDURE maintain_rsv_receive *********}}

   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name  := 'MAINTAIN_RSV_RECEIVE';
   x_return_status := fnd_api.g_ret_sts_success;

   IF (l_debug = 1) THEN
      print_debug('Entering maintain_rsv_receive...',l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).inventory_item_id   => '||p_cas_mol_rec_tb(1).inventory_item_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).organization_id     => '||p_cas_mol_rec_tb(1).organization_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).primary_qty         => '||p_cas_mol_rec_tb(1).primary_qty,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).po_header_id        => '||p_cas_mol_rec_tb(1).po_header_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).po_line_location_id => '||p_cas_mol_rec_tb(1).po_line_location_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).shipment_line_id    => '||p_cas_mol_rec_tb(1).shipment_line_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).requisition_line_id => '||p_cas_mol_rec_tb(1).requisition_line_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).auto_transact_code  => '||p_cas_mol_rec_tb(1).auto_transact_code,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).project_id          => '||p_cas_mol_rec_tb(1).project_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).task_id             => '||p_cas_mol_rec_tb(1).task_id,l_module_name,4);
   END IF;

   l_primary_qty := abs(p_cas_mol_rec_tb(1).primary_qty);

   --1.0 Set up query criteria

   --{{
   --Test ASN recept and PO receipt.  Make sure that ASN receipt
   --would not pick up PO reservation, and vice versa }}
   IF p_cas_mol_rec_tb(1).po_line_location_id IS NOT NULL THEN
      IF p_cas_mol_rec_tb(1).asn_line_flag = 'Y' THEN
	 IF (l_debug = 1) THEN
	   print_debug('This is an ASN receipt',l_module_name,4);
	 END IF;

	 l_rsv_query_rec.supply_source_type_id     := g_source_type_asn;
	 l_rsv_query_rec.supply_source_header_id   := p_cas_mol_rec_tb(1).po_header_id;
	 l_rsv_query_rec.supply_source_line_id     := p_cas_mol_rec_tb(1).po_line_location_id;
	 l_rsv_query_rec.supply_source_line_detail := p_cas_mol_rec_tb(1).shipment_line_id;

	 l_progress := '###';
         BEGIN
	    SELECT 1
	      INTO l_dummy
	      FROM rcv_shipment_lines
	      WHERE shipment_line_id = p_cas_mol_rec_tb(1).shipment_line_id
	      FOR UPDATE NOWAIT;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('Some other exception occurred! Raising Exception!',l_module_name,4);
		 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	       END IF;
	       l_progress := '###';
	      RAISE fnd_api.g_exc_unexpected_error;
	 END;
	 l_progress := '###';
       ELSE --asn_line_flag = 'Y' THEN
	 IF (l_debug = 1) THEN
	    print_debug('This is a PO receipt',l_module_name,4);
	 END IF;

	 l_rsv_query_rec.supply_source_type_id     := g_source_type_po;
	 l_rsv_query_rec.supply_source_header_id   := p_cas_mol_rec_tb(1).po_header_id;
	 l_rsv_query_rec.supply_source_line_id     := p_cas_mol_rec_tb(1).po_line_location_id;

	 l_progress := '###';
         BEGIN
	    SELECT 1
	      INTO l_dummy
	      FROM po_line_locations_all
	      WHERE line_location_id = p_cas_mol_rec_tb(1).po_line_location_id
	      FOR UPDATE NOWAIT;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('Some other exception occurred! Raising Exception!',l_module_name,4);
		  print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	       END IF;
	       l_progress := '###';
	       RAISE fnd_api.g_exc_unexpected_error;
	 END;
	 l_progress := '###';
      END IF;

    --{{
    --Test REQ receipt }}
     ELSIF p_cas_mol_rec_tb(1).requisition_line_id IS NOT NULL THEN -- INTREQ
      l_progress := '###';
      BEGIN
	 SELECT requisition_header_id
	   INTO l_requisition_header_id
	   FROM po_requisition_lines_all
	   WHERE requisition_line_id = p_cas_mol_rec_tb(1).requisition_line_id
	   FOR UPDATE NOWAIT;

	 l_progress := '###';
	 SELECT 1
	   INTO l_dummy
	   FROM rcv_shipment_lines
	   WHERE requisition_line_id = p_cas_mol_rec_tb(1).requisition_line_id
	   AND   shipment_line_id = p_cas_mol_rec_tb(1).shipment_line_id

	   FOR UPDATE NOWAIT;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('Some other exception occurred! Raising Exception!',l_module_name,4);
	       print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	    END IF;
	    RAISE fnd_api.g_exc_unexpected_error;
      END;
      l_progress := '###';

      l_rsv_query_rec.supply_source_type_id     := g_source_type_internal_req;
      l_rsv_query_rec.supply_source_header_id   := l_requisition_header_id;
      l_rsv_query_rec.supply_source_line_id     := p_cas_mol_rec_tb(1).requisition_line_id;

   --{{
   --Test Intrasit Shipment receipt.  Also test receipt of INTREQ
   --through the intrasit Shipment option}}
    ELSIF p_cas_mol_rec_tb(1).shipment_line_id IS NOT NULL THEN --INTSHIP

      l_progress := '###';
      BEGIN
	 SELECT shipment_header_id
	   INTO l_shipment_header_id
	   FROM rcv_shipment_lines
	   WHERE shipment_line_id = p_cas_mol_rec_tb(1).shipment_line_id
	   FOR UPDATE NOWAIT;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('Some other exception occurred! Raising Exception!',l_module_name,4);
	       print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	    END IF;
	    l_progress := '###';
	    RAISE fnd_api.g_exc_unexpected_error;
      END;
      l_progress := '###';

      l_rsv_query_rec.supply_source_type_id   := g_source_type_in_transit;
      l_rsv_query_rec.supply_source_header_id := l_shipment_header_id;
      l_rsv_query_rec.supply_source_line_id   := p_cas_mol_rec_tb(1).shipment_line_id;

   --{{
   --Test RMA receipt}}
    ELSE --RMA
      IF (l_debug = 1) THEN
	 print_debug('This is an RMA receipt.  No need to query reservations',l_module_name,4);
      END IF;

      l_progress := '###';
      set_mol_wdd_tbl(p_cas_mol_rec_tb(1),
		      x_cas_mol_rec_tb,
		      l_primary_qty,
		      NULL,
		      NULL);
      l_progress := '###';

      RETURN;
   END IF;

   l_rsv_query_rec.inventory_item_id       := p_cas_mol_rec_tb(1).inventory_item_id;
   l_rsv_query_rec.organization_id         := p_cas_mol_rec_tb(1).organization_id;

   IF (p_cas_mol_rec_tb(1).project_id IS NOT NULL) THEN
      l_rsv_query_rec.project_id := p_cas_mol_rec_tb(1).project_id;
      IF (p_cas_mol_rec_tb(1).task_id IS NOT NULL) THEN
	 l_rsv_query_rec.task_id := p_cas_mol_rec_tb(1).task_id;
      END IF;
   END IF ;

   --2.0 Query reservation
   IF (l_debug = 1) THEN
      print_debug('Calling query_reservation:',l_module_name,4);
   END IF;

   l_progress := '###';
   query_reservation
     (p_query_input => l_rsv_query_rec
      ,p_sort_by_req_date => g_query_demand_ship_date_asc
      ,x_rsv_results => l_rsv_results_tbl
      ,x_return_status => l_return_status
      );
   l_progress := '###';

   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      l_progress := '@@@';
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --3.0 Process reservations
   l_remaining_prim_qty := l_primary_qty;

   IF (l_debug = 1) THEN
      print_debug('l_remaining_prim_qty    = ' ||l_remaining_prim_qty,l_module_name,4);
      print_debug('l_rsv_results_tbl.COUNT = ' ||l_rsv_results_tbl.COUNT,l_module_name,4);
   END IF;


   --{{
   --Create multiple reservations for the same document and item.
   --Make sure that the results returned are in the correct order according
   --to the demand ship date}}
   FOR i IN 1..l_rsv_results_tbl.COUNT LOOP
      EXIT WHEN l_remaining_prim_qty <= 0;

      IF (l_debug = 1) THEN
	 print_debug('l_remaining_prim_qty:'||l_remaining_prim_qty||
		     ' i:'||i||
		     ' rsv_id:'||l_rsv_results_tbl(i).reservation_id||
		     ' prim_qty:'||l_rsv_results_tbl(i).primary_reservation_quantity||
		     ' rsv_qty:'||l_rsv_results_tbl(i).reservation_quantity||
		     ' uom_code:'||l_rsv_results_tbl(i).reservation_uom_code||
		     ' orig_supply_src_type_id:'||l_rsv_results_tbl(i).orig_supply_source_type_id||
		     ' demand_src_line_detail:'||l_rsv_results_tbl(i).demand_source_line_detail||
		     ' ext_src_code:'||l_rsv_results_tbl(i).external_source_code
		     ,l_module_name,4);
      END IF;

      l_rsv_update_rec := l_rsv_results_tbl(i);

      --MANEESH: For direct receipt and the case where reservation is
      --modifyed BY pegging engine, delete the reservation, which should
      --also update WDD accordingly
      --{{
      --Create a reservations, have it modified by pegging engine, then
      --Perform direct receipt.  Make sure that reservations are
      --relieved/deleted appropriately }}
      IF Nvl(p_cas_mol_rec_tb(1).auto_transact_code,'RECEIVE') = 'DELIVER' AND l_rsv_results_tbl(i).external_source_code = 'XDOCK' THEN
	 IF (l_rsv_results_tbl(i).primary_reservation_quantity >= l_remaining_prim_qty) THEN
	    l_rsv_update_rec.primary_reservation_quantity := l_remaining_prim_qty;
	    l_remaining_prim_qty := 0;
	  ELSE
	    l_rsv_update_rec.primary_reservation_quantity := l_rsv_results_tbl(i).primary_reservation_quantity;
	    l_remaining_prim_qty := l_remaining_prim_qty - l_rsv_results_tbl(i).primary_reservation_quantity;
	 END IF;

	 IF (l_debug = 1) THEN
	    print_debug('Calling relieve_reservation...',l_module_name,4);
	    print_debug(' l_rsv_update_rec.primary_reservation_quantity => '||l_rsv_update_rec.primary_reservation_quantity,l_module_name,4);
	 END IF;

	 --Relieve/delete reservation
	 l_progress := '###';
	 relieve_reservation
	   (p_rsv_rec              => l_rsv_results_tbl(i)
	    ,p_prim_qty_to_relieve => l_rsv_update_rec.primary_reservation_quantity
	    ,x_return_status       => l_return_status
	    );
	 l_progress := '###';

	 IF (l_debug = 1) THEN
	    print_debug('Returned from delete_reservation',l_module_name,4);
	    print_debug('x_return_status: '||l_return_status,l_module_name,4);
	 END IF;

	 IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    l_progress := '@@@';
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;


       --{{
       --Test the following cases:
       --1. standard Receipt that will match to a manual reservations
       --2. standard receipt that will match to a xdock reservations
       --3. direct receipt that will match to a manual reservations whose
       --   ext_src_code is not crossdock
       --4. direct receipt that will match to a xdock reservation whose
       --   ext_src_code is not crossdock}}
       ELSE --Reservation is not modified by pegging engine

	 --{{
	 --Test cases in which reservations/WDD need to be split}}
	 IF (l_rsv_results_tbl(i).primary_reservation_quantity > l_remaining_prim_qty) THEN
	    -- Reservation has more than enough to satisfy remaining qty, so split

	    IF (l_debug = 1) THEN
	       print_debug('l_rsv_results_tbl(i).primary_reservation_quantity > l_remaining_prim_qty',
			   l_module_name,4);
	    END IF;

	    l_rsv_update_rec.primary_reservation_quantity := l_remaining_prim_qty;
	    l_rsv_update_rec.reservation_quantity := inv_rcv_cache.convert_qty(p_cas_mol_rec_tb(1).inventory_item_id
								 ,l_remaining_prim_qty
								 ,l_rsv_results_tbl(i).primary_uom_code
								 ,l_rsv_results_tbl(i).reservation_uom_code);

	    IF (l_rsv_results_tbl(i).demand_source_line_detail IS NOT NULL) THEN
	       IF (l_debug = 1) THEN
		  print_debug('Calling split_wdd...',l_module_name,4);
	       END IF;

	       l_progress := '@@@';
	       split_wdd
		 (x_return_status => l_return_status
		  ,x_msg_count    => l_msg_count
		  ,x_msg_data     => l_msg_data
		  ,x_new_wdd_id   => l_new_wdd_id
		  ,p_wdd_id       => l_rsv_results_tbl(i).demand_source_line_detail
		  ,p_new_mol_id   => NULL
		  ,p_qty_to_splt  => l_remaining_prim_qty);
	       l_progress := '@@@';

	       IF (l_debug = 1) THEN
		  print_debug('Returned from split_wdd',l_module_name,4);
		  print_debug('x_return_status: '||l_return_status,l_module_name,4);
	       END IF;

	       IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
		  l_progress := '@@@';
		  RAISE fnd_api.g_exc_unexpected_error;
	       END IF;

	       IF (l_debug = 1) THEN
		  print_debug('l_new_wdd_id: '||l_new_wdd_id,l_module_name,4);
	       END IF;

	       --Depending on the routing, I will transfer/update released
	       --status later
	       l_rsv_update_rec.demand_source_line_detail := l_new_wdd_id;

	    END IF;

	    l_remaining_prim_qty := 0;

	  ELSE --l_rsv_results_tbl(i).primary_reservation_quantity <= l_remaining_prim_qty THEN
	    IF (l_debug = 1) THEN
	       print_debug('l_rsv_results_tbl(i).primary_reservation_quantity <= l_remaining_prim_qty',
			   l_module_name,4);
	    END IF;
	    l_remaining_prim_qty := l_remaining_prim_qty - l_rsv_results_tbl(i).primary_reservation_quantity;
	 END IF; --END IF (l_rsv_results_tbl(i).primary_reservation_quantity > l_remaining_prim_qty)

	 IF Nvl(p_cas_mol_rec_tb(1).auto_transact_code,'RECEIVE') = 'DELIVER' THEN
	    --Direct Receipt and the reservation has not been modified by the
	    --xdock pegging engine
	    l_rsv_update_rec.supply_source_type_id     := g_source_type_inv;
	    l_rsv_update_rec.demand_source_line_detail := NULL;
	  ELSE
	    --Standard/Inspection routing receipt
	    l_rsv_update_rec.supply_source_type_id := g_source_type_rcv;
	 END IF;

	 --Null out supply source info
	 l_rsv_update_rec.supply_source_header_id   := NULL;
	 l_rsv_update_rec.supply_source_line_id     := NULL;
	 l_rsv_update_rec.supply_source_line_detail := NULL;

	 IF Nvl(p_cas_mol_rec_tb(1).auto_transact_code,'RECEIVE') = 'DELIVER' AND l_rsv_results_tbl(i).demand_source_line_detail IS NOT NULL THEN

	    IF (l_debug = 1) THEN
	       print_debug('Calling update_wdd...',l_module_name,4);
	    END IF;

	    l_progress := '@@@';
	    update_wdd
	      (x_return_status    => l_return_status
	       ,x_msg_count       => l_msg_count
	       ,x_msg_data        => l_msg_data
	       ,p_wdd_id          => l_rsv_update_rec.demand_source_line_detail
	       ,p_released_status => 'R' --Ready to released
	       ,p_mol_id          => NULL
	       );
	    l_progress := '@@@';

	    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	       l_progress := '@@@';
	       RAISE fnd_api.g_exc_unexpected_error;
	    END IF;

	    l_rsv_update_rec.demand_source_line_detail := NULL;
	 END IF;

	 IF (l_debug = 1) THEN
	    print_debug('Calling transfer_reservation...',l_module_name,4);
	 END IF;

	 l_progress := '@@@';
	 transfer_reservation
	   (p_original_rsv_rec => l_rsv_results_tbl(i)
	    ,p_to_rsv_rec      => l_rsv_update_rec
	    ,x_new_rsv_id      => l_new_rsv_id
	    ,x_return_status   => l_return_status);
	 l_progress := '@@@';

	 IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    l_progress := '@@@';
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;

	 IF (l_debug = 1) THEN
	    print_debug('l_new_rsv_id: '||l_new_rsv_id,l_module_name,4);
	 END IF;
      END IF;--IF p_cas_mol_rec_tb(1).auto_transact_code = 'DELIVER' AND l_rsv_results_tbl(i).external_source_code = 'XDOCK' THEN

      --For standard/inspection routing receipt, populate x_cas_mol_rec_tb
      --so that maintain_mo_cons API can create MOL with the specific WDD
      IF (Nvl(p_cas_mol_rec_tb(1).auto_transact_code,'RECEIVE') <> 'DELIVER') THEN
	 IF l_rsv_update_rec.demand_source_type_id IN (g_source_type_internal_ord,g_source_type_oe) THEN
	    set_mol_wdd_tbl(p_cas_mol_rec_tb(1),
			    x_cas_mol_rec_tb,
			    l_rsv_update_rec.primary_reservation_quantity,
			    l_rsv_update_rec.demand_source_line_detail,
			    1
			 );
          /* Bug 5244500 : If source type is INV, then cross dock type should be set
          to null.*/
          ELSIF (l_rsv_update_rec.demand_source_type_id = g_source_type_inv ) THEN
            set_mol_wdd_tbl(p_cas_mol_rec_tb(1),
                            x_cas_mol_rec_tb,
                            l_rsv_update_rec.primary_reservation_quantity,
                            l_rsv_update_rec.demand_source_line_detail,
                            null
                            );
	  ELSE
	    set_mol_wdd_tbl(p_cas_mol_rec_tb(1),
			    x_cas_mol_rec_tb,
			    l_rsv_update_rec.primary_reservation_quantity,
			    l_rsv_update_rec.demand_source_line_detail,
			    2
			    );
	 END IF;
      END IF;
   END LOOP;

   --For standard/inspection routing receipt, populate x_cas_mol_rec_tb
   --so that MOL will be created for the the quantity with no reservation

   --??? For + Corr of Receive, auto_transact_code is passed NULL.  Assume
   --that NULL is same as RECEIVE.  Is it the right assumption???
   IF (Nvl(p_cas_mol_rec_tb(1).auto_transact_code,'RECEIVE') <> 'DELIVER' AND l_remaining_prim_qty > 0) THEN
      set_mol_wdd_tbl(p_cas_mol_rec_tb(1),
		      x_cas_mol_rec_tb,
		      l_remaining_prim_qty,
		      NULL,
		      NULL);
   END IF;

   IF (l_debug = 1) THEN
      print_debug('Exitting maintain_rsv_receive with the following values:',l_module_name,4);
      print_debug('x_return_status  => '||x_return_status,l_module_name,4);
      print_debug('x_msg_count      => '||x_msg_count,l_module_name,4);
      print_debug('x_msg_data       => '||x_msg_data,l_module_name,4);
   END IF;

   --{{
   --********** END PROCEDURE maintain_rsv_receive *********}}

EXCEPTION
   WHEN OTHERS THEN
      x_return_status :=  fnd_api.g_ret_sts_error;
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred at progress: '||l_progress,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	 print_debug('Exiting maintain_rsv_receive with error: '||l_progress,l_module_name,4);
      END IF;
END maintain_rsv_receive;

PROCEDURE maintain_rsv_deliver
  (x_return_status        OUT NOCOPY 	VARCHAR2
   ,x_msg_count           OUT NOCOPY 	NUMBER
   ,x_msg_data            OUT NOCOPY 	VARCHAR2
   ,p_cas_mol_rec_tb      IN inv_rcv_integration_pvt.cas_mol_rec_tb_tp
   ) IS
      l_rsv_reduce_rec        inv_reservation_global.mtl_maintain_rsv_rec_type;
      l_rsv_query_rec         inv_reservation_global.mtl_reservation_rec_type;
      l_rsv_results_tbl       inv_reservation_global.mtl_reservation_tbl_type;
      l_rsv_update_rec        inv_reservation_global.mtl_reservation_rec_type;
      l_remaining_prim_qty    NUMBER;
      l_new_rsv_id            NUMBER;
      l_new_wdd_id            NUMBER;
      l_dummy                 NUMBER;
      l_doc_type              NUMBER;

      l_return_status VARCHAR2(1);
      l_error_code    NUMBER;
      l_msg_count     NUMBER;
      l_msg_data      VARCHAR2(2000);

      l_debug    NUMBER;
      l_progress VARCHAR2(10);
      l_module_name VARCHAR2(30);
      l_reference VARCHAR2(240); --Bug 8641693
      l_reference_id NUMBER; --Bug 8641693
      l_orig_supply_source_line_id NUMBER; --Bug 8641693
BEGIN

   --{{
   --********** PROCEDURE maintain_rsv_deliver *********}}

   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'MAINTAIN_RSV_DELIVER';
   x_return_status := fnd_api.g_ret_sts_success;

   IF (l_debug = 1) THEN
      print_debug('Entering maintain_rsv_deliver...',l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).line_id             => '||p_cas_mol_rec_tb(1).line_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).inventory_item_id   => '||p_cas_mol_rec_tb(1).inventory_item_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).organization_id     => '||p_cas_mol_rec_tb(1).organization_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).primary_qty         => '||p_cas_mol_rec_tb(1).primary_qty,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).project_id          => '||p_cas_mol_rec_tb(1).project_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).task_id             => '||p_cas_mol_rec_tb(1).task_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).bdd_id              => '||p_cas_mol_rec_tb(1).backorder_delivery_detail_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).crossdock_type      => '||p_cas_mol_rec_tb(1).crossdock_type,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).wip_supply_type     => '||p_cas_mol_rec_tb(1).wip_supply_type,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).subinventory_code   => '||p_cas_mol_rec_tb(1).subinventory_code,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).locator_id          => '||p_cas_mol_rec_tb(1).locator_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).lot_number          => '||p_cas_mol_rec_tb(1).lot_number,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).item_revision       => '||p_cas_mol_rec_tb(1).item_revision,l_module_name,4);
   END IF;

   --{{
   --Try to lock the MOL row from SQLPLUS, and see if transaction would
   --fail at this point}}
   l_progress := '@@@';
   BEGIN
      SELECT 1
	INTO l_dummy
	FROM mtl_txn_request_lines
	WHERE line_id = p_cas_mol_rec_tb(1).line_id
	FOR UPDATE NOWAIT;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('Some other exception occurred!',l_module_name,4);
	    print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
	 END IF;
	 l_progress := '@@@';
	 RAISE fnd_api.g_exc_unexpected_error;
   END;

   l_progress := '@@@';

   --{{
   --Test WIP Push xdock}}
   IF p_cas_mol_rec_tb(1).crossdock_type = 2 AND p_cas_mol_rec_tb(1).wip_supply_type = 1 THEN
      IF (l_debug = 1) THEN
	 print_debug('No Need to Handle Reservations for crossdock to a WIP push demand',l_module_name,4);
      END IF;

      --Bug 5249929 - No need to call reduce reservations for WIP demands
      --as we do not support wip as a demand in reservations

      --l_rsv_reduce_rec.action                  := 1; --Supply
      --l_rsv_reduce_rec.inventory_item_id       := p_cas_mol_rec_tb(1).inventory_item_id;
      --l_rsv_reduce_rec.organization_id         := p_cas_mol_rec_tb(1).organization_id;
      --l_rsv_reduce_rec.supply_source_type_id   := g_source_type_rcv;
      --l_rsv_reduce_rec.demand_source_type_id   := g_source_type_wip;
      --l_rsv_reduce_rec.demand_source_header_id :=  p_cas_mol_rec_tb(1).backorder_delivery_detail_id;--???

      --???
      /*IF (p_cas_mol_rec_tb(1).project_id IS NOT NULL) THEN
	 l_rsv_reduce_rec.project_id := p_cas_mol_rec_tb(1).project_id;
	 IF (p_cas_mol_rec_tb(1).task_id IS NOT NULL) THEN
	    l_rsv_reduce_rec.task_id := p_cas_mol_rec_tb(1).task_id;
	 END IF;
      END IF ;
	   */

      --{{
      --Make sure that the reservations are reduced appropriately}}
      --l_progress := '@@@';
      --reduce_reservation
	--(p_mtl_rsv_rec    => l_rsv_reduce_rec
	 --,x_return_status => l_return_status
	 --);
      --l_progress := '@@@';

      --IF (l_debug = 1) THEN
	-- print_debug('Returned from update_wdd',l_module_name,4);
	-- print_debug('x_return_status: '||l_return_status,l_module_name,4);
      --END IF;

      --IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	-- l_progress := '@@@';
	-- RAISE fnd_api.g_exc_unexpected_error;
      --END IF;

    --{{
    --Test SO Xdock, WIP Pull or non-crossdock cases}}
    ELSE
      IF (l_debug = 1) THEN
	 print_debug('SO Xdock/WIP-Pull/Non-xdock',l_module_name,4);
      END IF;

      l_rsv_query_rec.inventory_item_id       := p_cas_mol_rec_tb(1).inventory_item_id;
      l_rsv_query_rec.organization_id         := p_cas_mol_rec_tb(1).organization_id;
      l_rsv_query_rec.supply_source_type_id   := g_source_type_rcv;


      IF (p_cas_mol_rec_tb(1).project_id IS NOT NULL) THEN
	 l_rsv_query_rec.project_id := p_cas_mol_rec_tb(1).project_id;
	 IF (p_cas_mol_rec_tb(1).task_id IS NOT NULL) THEN
	    l_rsv_query_rec.task_id := p_cas_mol_rec_tb(1).task_id;
	 END IF;
      END IF ;

      IF p_cas_mol_rec_tb(1).crossdock_type = 2 THEN --WIP
	 --{{
	 --Test deliver of WIP crossdock PULL. Make sure that mr.backorder_delivery_detail_id corresponds
	 --to mol.backorder_delivery_detail_id }}
	 IF (l_debug = 1) THEN
	    print_debug('This is a WIP pull xdock',4);
	 END IF;
	 l_rsv_query_rec.demand_source_type_id := g_source_type_wip;
	 l_rsv_query_rec.demand_source_header_id :=  p_cas_mol_rec_tb(1).backorder_delivery_detail_id;--???
       ELSIF p_cas_mol_rec_tb(1).crossdock_type = 1
	 AND p_cas_mol_rec_tb(1).backorder_delivery_detail_id IS NOT NULL THEN --SO
	 IF (l_debug = 1) THEN
	    print_debug('This is a SO xdock',4);
	 END IF;

	 --{{
	 --Test deliver of a SO (for both Internal Order and Sale order.
	 --When processing results for SO xdock.  Make sure that
	 --1) There is only 1 result returned
	 --2) The appropriate wdd are updated to STAGED status
	 --3) The appropriate reservation is transferred to INVENTORY (Check source_type columns)}}

         BEGIN
	    SELECT  Nvl(source_document_type_id, -1)
	      INTO  l_doc_type
	      FROM  wsh_delivery_details
	      WHERE delivery_detail_id =  p_cas_mol_rec_tb(1).backorder_delivery_detail_id;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('Error retrieving doc type for SO',l_module_name,4);
	       END IF;
	       RAISE fnd_api.g_exc_unexpected_error;
	 END;

	 IF (l_debug = 1) THEN
	    print_debug('l_doc_type:'||l_doc_type,4);
	 END IF;

	 IF l_doc_type = 10 THEN
	    l_rsv_query_rec.demand_source_type_id := g_source_type_internal_ord;
	  ELSE
	    l_rsv_query_rec.demand_source_type_id := g_source_type_oe;
	 END if;
	 l_rsv_query_rec.demand_source_line_detail := p_cas_mol_rec_tb(1).backorder_delivery_detail_id;
       ELSE -- Non-crossdock cases
	 IF (l_debug = 1) THEN
	    print_debug('This is a non-xdock case',4);
	 END IF;



        --Bug 8641693
	l_reference_id := NULL;
	l_reference := NULL;
	l_orig_supply_source_line_id := NULL;

         BEGIN

	    SELECT reference, reference_id
            INTO l_reference, l_reference_id
            FROM  mtl_txn_request_lines
            WHERE line_id = p_cas_mol_rec_tb(1).line_id  AND reference_type_code = 4;

     	   print_debug('l_reference'|| l_reference ,l_module_name,4);
	   print_debug('l_reference_id' || l_reference_id,l_module_name,4);

            IF (l_reference IS NOT NULL) THEN
            IF (l_reference = 'PO_DISTRIBUTION_ID') THEN
	    SELECT prda.requisition_line_id INTO l_orig_supply_source_line_id
	    FROM po_req_distributions_all prda, po_distributions_all pda
            WHERE pda.req_distribution_id = prda.distribution_id AND pda.po_distribution_id = l_reference_id;
	    ELSIF (l_reference = 'PO_LINE_LOCATION_ID') THEN
	        SELECT requisition_line_id INTO l_orig_supply_source_line_id
		FROM po_requisition_lines_all
		WHERE line_location_id = l_reference_id;
	    ELSIF (l_reference = 'SHIPMENT_LINE_ID') THEN
	        SELECT prla.requisition_line_id INTO l_orig_supply_source_line_id
		FROM po_requisition_lines_all prla, rcv_shipment_lines rsl
		WHERE rsl.shipment_line_id = l_reference_id AND rsl.po_line_location_id = prla.line_location_id;
	    END IF;
            END IF;

     	   print_debug('l_orig_supply_source_line_id'|| l_orig_supply_source_line_id ,l_module_name,4);
         EXCEPTION
         WHEN OTHERS THEN

           IF (l_debug = 1) THEN
             print_debug('Some other exception occurred in getting the reference id',l_module_name,4);
             print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
           END IF;
         END;

	 --{{
	 --Deliver of non-crossdock cases.  Make sure that only manual
	 --reservations are picked up.
	 --When processing results for non-crossdock cases.  Make sure that
	 --reservations are transfered to Inventory properly.  }}
	 l_rsv_query_rec.demand_source_line_detail := NULL;
      END IF;

      IF (l_debug = 1) THEN
	 print_debug('Calling query_reservations...',l_module_name,4);
      END IF;

      l_progress := '@@@';
      query_reservation
	(p_query_input => l_rsv_query_rec
	 ,p_sort_by_req_date => g_query_demand_ship_date_asc
	 ,x_rsv_results => l_rsv_results_tbl
	 ,x_return_status => l_return_status
	 );
      l_progress := '@@@';

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	 l_progress := '@@@';
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_remaining_prim_qty := p_cas_mol_rec_tb(1).primary_qty;

      IF (l_debug = 1) THEN
	 print_debug('l_remaining_prim_qty    = ' ||l_remaining_prim_qty,l_module_name,4);
	 print_debug('l_rsv_results_tbl.COUNT = ' ||l_rsv_results_tbl.COUNT,l_module_name,4);
      END IF;

      --{{
      --LOOP results.  Make sure the results are correct according to
      --the criteria entered (checking ordering also}}
      FOR i IN 1..l_rsv_results_tbl.COUNT LOOP
	 EXIT WHEN l_remaining_prim_qty <= 0;
	 IF l_rsv_results_tbl(i).orig_supply_source_line_id IS NOT NULL THEN
      	    print_debug('l_rsv_results_tbl(i).orig_supply_source_line_id is ' || l_rsv_results_tbl(i).orig_supply_source_line_id ,l_module_name,4);
         END IF;

	 IF (l_orig_supply_source_line_id IS NOT NULL AND l_rsv_results_tbl(i).orig_supply_source_line_id IS NOT NULL
	    AND (l_orig_supply_source_line_id <> l_rsv_results_tbl(i).orig_supply_source_line_id) ) THEN
     	    print_debug('l_orig_supply_source_line_id' || l_orig_supply_source_line_id ,l_module_name,4);
     	    print_debug('l_rsv_results_tbl(i).orig_supply_source_line_id'|| l_rsv_results_tbl(i).orig_supply_source_line_id ,l_module_name,4);
	    -- CONTINUE;
	    GOTO ENDOFTHELOOP;
	 END IF;

	 --{{
	 --Make sure that l_remaining_prim_qty are updated properly}}
	 IF (l_debug = 1) THEN
	    print_debug('l_remaining_prim_qty:'||l_remaining_prim_qty||
			' i:'||i||
			' rsv_id:'||l_rsv_results_tbl(i).reservation_id||
			' prim_qty:'||l_rsv_results_tbl(i).primary_reservation_quantity||
			' rsv_qty:'||l_rsv_results_tbl(i).reservation_quantity||
			' uom_code:'||l_rsv_results_tbl(i).reservation_uom_code||
			' orig_supply_src_type_id:'||l_rsv_results_tbl(i).orig_supply_source_type_id||
			' demand_src_line_detail:'||l_rsv_results_tbl(i).demand_source_line_detail||
			' ext_src_code:'||l_rsv_results_tbl(i).external_source_code
			,l_module_name,4);
	 END IF;

	 l_rsv_update_rec := l_rsv_results_tbl(i);

	 IF (l_rsv_results_tbl(i).primary_reservation_quantity > l_remaining_prim_qty) THEN
	    IF (l_debug = 1) THEN
	       print_debug('l_rsv_results_tbl(i).primary_reservation_quantity > l_remaining_prim_qty',
			   l_module_name,4);
	    END IF;

	    l_rsv_update_rec.primary_reservation_quantity := l_remaining_prim_qty;
	    l_rsv_update_rec.reservation_quantity := inv_rcv_cache.convert_qty
	                                                (p_cas_mol_rec_tb(1).inventory_item_id
							 ,l_remaining_prim_qty
							 ,l_rsv_results_tbl(i).primary_uom_code
							 ,l_rsv_results_tbl(i).reservation_uom_code);

	    IF (l_rsv_results_tbl(i).demand_source_line_detail IS NOT NULL) THEN
	       IF (l_debug = 1) THEN
		  print_debug('Calling split_wdd',l_module_name,4);
	       END IF;

	       l_progress := '@@@';
	       split_wdd
		 (x_return_status => l_return_status
		  ,x_msg_count    => l_msg_count
		  ,x_msg_data     => l_msg_data
		  ,x_new_wdd_id   => l_new_wdd_id
		  ,p_wdd_id       => l_rsv_results_tbl(i).demand_source_line_detail
		  ,p_new_mol_id   => NULL
		  ,p_qty_to_splt  => l_remaining_prim_qty);
	       l_progress := '@@@';

	       IF (l_debug = 1) THEN
		  print_debug('Returned from split_wdd',l_module_name,4);
		  print_debug('l_return_status =>'||l_return_status,l_module_name,4);
	       END IF;

	       IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
		  l_progress := '@@@';
		  RAISE fnd_api.g_exc_unexpected_error;
	       END IF;

	       l_rsv_update_rec.demand_source_line_detail := l_new_wdd_id;
	    END IF;

	    l_remaining_prim_qty := 0;

	  ELSE --l_rsv_results_tbl(i).primary_reservation_quantity <= l_remaining_prim_qty
	    IF (l_debug = 1) THEN
	       print_debug('l_rsv_results_tbl(i).primary_reservation_quantity <= l_remaining_prim_qty',
			   l_module_name,4);
	    END IF;
	    l_remaining_prim_qty := l_remaining_prim_qty - l_rsv_results_tbl(i).primary_reservation_quantity;
	 END IF;

	 -- Lei's complete_crossdock API will update wdd

	 l_rsv_update_rec.supply_source_type_id        := g_source_type_inv;
	 l_rsv_update_rec.supply_source_header_id      := NULL;
	 l_rsv_update_rec.supply_source_line_id        := NULL;
	 l_rsv_update_rec.supply_source_line_detail    := NULL;
	 l_rsv_update_rec.demand_source_line_detail    := NULL;

	 --6/30/05: Also update lpn/sub/loc info for xdock scenario
----	 IF l_rsv_results_tbl(i).demand_source_line_detail IS NOT NULL THEN   --Bug 8641693
	    l_rsv_update_rec.lpn_id                       := p_cas_mol_rec_tb(1).lpn_id;
	    l_rsv_update_rec.subinventory_code            := p_cas_mol_rec_tb(1).subinventory_code;
	    l_rsv_update_rec.locator_id                   := p_cas_mol_rec_tb(1).locator_id;
	    l_rsv_update_rec.lot_number                   := p_cas_mol_rec_tb(1).lot_number;
	    l_rsv_update_rec.revision                     := p_cas_mol_rec_tb(1).item_revision;
	 IF l_rsv_results_tbl(i).demand_source_line_detail IS NOT NULL THEN
	    l_rsv_update_rec.staged_flag                  := 'Y';
	    l_rsv_update_rec.crossdock_flag               := NULL;
	 END IF;

	 IF (l_debug = 1) THEN
	    print_debug('Calling transfer_reservation...',l_module_name,4);
	 END IF;

	 l_progress := '@@@';
	 transfer_reservation
	   (p_original_rsv_rec => l_rsv_results_tbl(i)
	    ,p_to_rsv_rec      => l_rsv_update_rec
	    ,x_new_rsv_id      => l_new_rsv_id
	    ,x_return_status   => l_return_status);
	 l_progress := '@@@';

	 IF (l_debug = 1) THEN
	    print_debug('Returned from transfer_reservation',l_module_name,4);
	    print_debug('x_return_status: '||l_return_status,l_module_name,4);
	 END IF;

	 IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    l_progress := '@@@';
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;

	 IF (l_debug = 1) THEN
	    print_debug('l_new_rsv_id: '||l_new_rsv_id,l_module_name,4);
	 END IF;
	 <<ENDOFTHELOOP>> NULL;
      END LOOP;
   END IF;--IF p_cas_mol_rec_tb(1).crossdock_type = 2 AND p_cas_mol_rec_tb(1).wip_supply_type = 1 THEN

   IF (l_debug = 1) THEN
      print_debug('Exitting maintain_rsv_deliver with the following values:',l_module_name,4);
      print_debug('x_return_status  => '||x_return_status,l_module_name,4);
      print_debug('x_msg_count      => '||x_msg_count,l_module_name,4);
      print_debug('x_msg_data       => '||x_msg_data,l_module_name,4);
   END IF;

   --{{
   --********** END PROCEDURE maintain_rsv_deliver *********}}
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred at progress: '||l_progress,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
      END IF;
      x_return_status :=  fnd_api.g_ret_sts_error;
END maintain_rsv_deliver;

PROCEDURE maintain_rsv_returns
  (x_return_status        OUT NOCOPY 	VARCHAR2
   ,x_msg_count           OUT NOCOPY 	NUMBER
   ,x_msg_data            OUT NOCOPY 	VARCHAR2
   ,p_cas_mol_rec_tb      IN inv_rcv_integration_pvt.cas_mol_rec_tb_tp
   ) IS
      l_rsv_query_rec         inv_reservation_global.mtl_reservation_rec_type;
      l_rsv_update_rec        inv_reservation_global.mtl_reservation_rec_type;
      l_remaining_prim_qty    NUMBER;
      l_shipment_header_id    NUMBER;
      l_requisition_header_id NUMBER;
      l_supply_source_type_id NUMBER;
      l_supply_source_header_id NUMBER;
      l_supply_source_line_id NUMBER;
      l_supply_source_line_detail NUMBER;
      l_avail_qty_to_reserve  NUMBER;
      l_avail_qty             NUMBER;
      l_available_rcv_qty     NUMBER;
      l_qty_with_no_wdd       NUMBER;
      l_deal_with_reservation NUMBER;
      l_new_rsv_id            NUMBER;
      TYPE varchar25_tb IS TABLE OF VARCHAR2(25) INDEX BY BINARY_INTEGER;
      l_pt_txn_types          varchar25_tb;
      l_inspect_status        NUMBER;
      l_loose_qty_to_splt     NUMBER;
      l_receipt_source_code   VARCHAR2(25);
      l_mo_line_id            NUMBER;
      l_mo_split_tb     inv_rcv_integration_apis.mo_in_tb_tp;
      l_dummy                 NUMBER;
      l_qty_to_close          NUMBER;
      l_tmp_line_id           NUMBER;
      l_primary_qty           NUMBER;

      l_return_status VARCHAR2(1);
      l_error_code    NUMBER;
      l_msg_count     NUMBER;
      l_msg_data      VARCHAR2(2000);

      l_debug    NUMBER;
      l_progress VARCHAR2(10);
      l_module_name VARCHAR2(30);

BEGIN

   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'MAINTAIN_RSV_RETURNS';

   --For - Corr, primary_qty will come as a negative number.  Take the abs
   --value here

   l_primary_qty := abs(p_cas_mol_rec_tb(1).primary_qty);

   IF (l_debug = 1) THEN
      print_debug('Entering maintain_rsv_returns...',l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).organization_id     => '||p_cas_mol_rec_tb(1).organization_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).inventory_item_id   => '||p_cas_mol_rec_tb(1).inventory_item_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).lpn_id              => '||p_cas_mol_rec_tb(1).lpn_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).from_subinventory_code => '||p_cas_mol_rec_tb(1).from_subinventory_code,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).from_locator_id     => '||p_cas_mol_rec_tb(1).from_locator_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).item_revision       => '||p_cas_mol_rec_tb(1).item_revision,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).lot_number          => '||p_cas_mol_rec_tb(1).lot_number,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).primary_qty         => '||l_primary_qty,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).project_id          => '||p_cas_mol_rec_tb(1).project_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).task_id             => '||p_cas_mol_rec_tb(1).task_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).shipment_line_id    => '||p_cas_mol_rec_tb(1).shipment_line_id,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).inspection_status   => '||p_cas_mol_rec_tb(1).inspection_status,l_module_name,4);
      print_debug(' p_cas_mol_rec_tb(1).asn_line_flag       => '||p_cas_mol_rec_tb(1).asn_line_flag,l_module_name,4);
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;

   --2.0 Query availability in RCV
   IF (l_debug = 1) THEN
      print_debug('Calling inv_reservation_avail_pvt.available_supply_to_reserve',l_module_name,4);
   END IF;

   inv_reservation_avail_pvt.available_supply_to_reserve
     (x_return_status                   => l_return_status
      , x_msg_count                     => l_msg_count
      , x_msg_data                      => l_msg_data
      , p_organization_id               => p_cas_mol_rec_tb(1).organization_id
      , p_item_id                       => p_cas_mol_rec_tb(1).inventory_item_id
      , p_revision                      => p_cas_mol_rec_tb(1).item_revision
      , p_lot_number                    => p_cas_mol_rec_tb(1).lot_number
      , p_supply_source_type_id         => g_source_type_rcv
      , p_supply_source_header_id       => NULL
      , p_supply_source_line_id         => NULL
      , p_supply_source_line_detail     => NULL
      , p_project_id                    => p_cas_mol_rec_tb(1).project_id
      , p_task_id                       => p_cas_mol_rec_tb(1).task_id
      , x_qty_available_to_reserve      => l_avail_qty_to_reserve
      , x_qty_available                 => l_avail_qty
      );

   IF (l_debug = 1) THEN
      print_debug('After calling inv_reservation_avail_pvt.available_supply_to_reserve',l_module_name,4);
      print_debug('l_avail_qty_to_reserve: ' || l_avail_qty_to_reserve,l_module_name,4);
   END IF;

   l_available_rcv_qty := l_avail_qty_to_reserve + l_primary_qty;

   IF (l_debug = 1) THEN
      print_debug('l_available_rcv_qty: ' || l_available_rcv_qty,l_module_name,4);
   END IF;

   --3.0 Determine whether there is a need to deal with reservations
   IF l_available_rcv_qty > l_primary_qty THEN

      --3.1 If there is enough total available quantity, we still need
      --    to check if the LPN has available MOL quantity that has no wdd stamped
      BEGIN
	 SELECT SUM(primary_quantity)
	   INTO l_qty_with_no_wdd
	   FROM mtl_txn_request_lines mtrl
	   WHERE nvl(mtrl.lpn_id,-999)=nvl(p_cas_mol_rec_tb(1).lpn_id,-999)
	   AND nvl(mtrl.from_subinventory_code,'&&&')=nvl(p_cas_mol_rec_tb(1).from_subinventory_code,'&&&')--???
	   AND nvl(mtrl.from_locator_id,-999)=nvl(p_cas_mol_rec_tb(1).from_locator_id,-999)--???
	   AND mtrl.organization_id = p_cas_mol_rec_tb(1).organization_id
	   AND mtrl.inventory_item_id = p_cas_mol_rec_tb(1).inventory_item_id
	   AND Nvl(mtrl.lot_number,'*&*') = Nvl(p_cas_mol_rec_tb(1).lot_number,'*&*')
	   AND nvl(mtrl.revision,'&&&') = nvl(p_cas_mol_rec_tb(1).item_revision,'&&&')
	   AND mtrl.line_status = 7
	   AND Nvl(mtrl.inspection_status,-1) = Nvl(p_cas_mol_rec_tb(1).inspection_status,-1)
	   AND (NVL(mtrl.project_id, -999) = NVL(p_cas_mol_rec_tb(1).project_id, -999)
                or p_cas_mol_rec_tb(1).lpn_id  is null) -- Bug 6618890 --Bug#8627996
	   AND (NVL(mtrl.task_id, -999) = NVL(p_cas_mol_rec_tb(1).task_id, -999)
                or p_cas_mol_rec_tb(1).lpn_id is null) -- Bug 6618890 --Bug#8627996
	   AND (mtrl.quantity - Nvl(mtrl.quantity_delivered,0)) > 0
	   AND mtrl.backorder_delivery_detail_id IS NULL
	     AND exists (SELECT 1
			 FROM mtl_txn_request_headers mtrh
			 WHERE mtrh.move_order_type = inv_globals.g_move_order_put_away
			 AND mtrh.header_id = mtrl.header_id);
      EXCEPTION
	 WHEN OTHERS THEN
	    RAISE fnd_api.g_exc_unexpected_error;
      END;

      IF (l_debug = 1) THEN
	 print_debug('l_qty_qith_no_wdd : ' || l_qty_with_no_wdd ,l_module_name,4);
      END IF;

      IF (l_qty_with_no_wdd >= l_primary_qty) THEN
	 --3.1.1 Can simply split MOL.  No need to deal with reservations
	 l_deal_with_reservation := 0;
       ELSE
	 --3.1.2 Must deal with wdd.  So need to deal with reservations
	 l_deal_with_reservation := 1;
      END IF;
    ELSE
      --3.2 total available qty is less the txn qty.  So must deal with reservations
      l_deal_with_reservation := 1;
   END IF;--END IF l_available_rcv_qty > l_primary_qty THEN

   IF (l_debug = 1) THEN
        print_debug('L_DEAL_WITH_RESERVATION := ' || l_deal_with_reservation ,l_module_name,4);
   END IF;

   l_remaining_prim_qty := 0;
   l_loose_qty_to_splt := 0;

   IF (l_deal_with_reservation = 0) THEN
      --4.1 Jump directly to split mo
      l_loose_qty_to_splt := l_primary_qty;
      IF (l_debug = 1) THEN
        print_debug('LOOSE QTY TO SPLI =  ' || l_loose_qty_to_splt ,l_module_name,4);
      END IF;
    ELSE -- l_deal_with_reservation = 1

      --4.2.2 Query reservations
      l_remaining_prim_qty := l_primary_qty;
      l_loose_qty_to_splt := 0;

      IF (l_debug = 1) THEN
        print_debug('Before Opening the cusror on l_rsv_results  ' ,l_module_name,4);
      END IF;

      FOR l_rsv_results IN (SELECT
			      reservation_id
			    , primary_uom_code
			    , primary_reservation_quantity
			    , reservation_uom_code
			    , demand_source_line_detail
			      FROM mtl_reservations mr
			      WHERE mr.supply_source_type_id = inv_reservation_global.g_source_type_rcv
			      AND mr.organization_id = p_cas_mol_rec_tb(1).organization_id
			      AND mr.inventory_item_id = p_cas_mol_rec_tb(1).inventory_item_id
			      AND ((mr.demand_source_line_detail IS NOT NULL
				    AND mr.demand_source_line_detail
				    IN (SELECT mol.backorder_delivery_detail_id
					FROM mtl_txn_request_lines mol
					WHERE mol.organization_id = p_cas_mol_rec_tb(1).organization_id
					AND mol.inventory_item_id = p_cas_mol_rec_tb(1).inventory_item_id
					AND NVL(mol.revision, '@@@') = NVL(p_cas_mol_rec_tb(1).item_revision, '@@@')
					AND (NVL(mol.project_id, -999) = NVL(p_cas_mol_rec_tb(1).project_id, -999)
                                             or p_cas_mol_rec_tb(1).lpn_id is null) -- Bug 6618890 --Bug#8627996
					AND (NVL(mol.task_id, -999) = NVL(p_cas_mol_rec_tb(1).task_id, -999)
                                             or p_cas_mol_rec_tb(1).lpn_id is null) -- Bug 6618890 --Bug#8627996
					AND MOL.CROSSDOCK_TYPE = 1 --RESERVATION COULD BE FOR WIP ALSO???
					AND NVL(mol.lpn_id, -999) = NVL(p_cas_mol_rec_tb(1).lpn_id, -999)
					AND nvl(mol.inspection_status,-1) = Nvl(p_cas_mol_rec_tb(1).inspection_status,-1)
					AND Nvl(mol.lot_number,'&^+') = Nvl(p_cas_mol_rec_tb(1).lot_number,'&^+')
					AND mol.line_status = 7
					AND (mol.quantity-Nvl(mol.quantity_delivered,0))>0
					AND exists (SELECT 1
						    FROM mtl_txn_request_headers mtrh
						    WHERE mtrh.move_order_type = inv_globals.g_move_order_put_away
						    AND   mtrh.header_id = mol.header_id)
				    )) OR
				   (mr.demand_source_line_detail IS NULL
				    AND exists (SELECT mol.backorder_delivery_detail_id
						FROM mtl_txn_request_lines mol
						WHERE mol.organization_id = p_cas_mol_rec_tb(1).organization_id
						AND mol.inventory_item_id = p_cas_mol_rec_tb(1).inventory_item_id
						AND NVL(mol.revision, '@@@') = NVL(p_cas_mol_rec_tb(1).item_revision, '@@@')
						AND (NVL(mol.project_id, -999) = NVL(p_cas_mol_rec_tb(1).project_id, -999)
                                                     or p_cas_mol_rec_tb(1).lpn_id is null) -- Bug 6618890 --Bug#8627996
						AND (NVL(mol.task_id, -999) = NVL(p_cas_mol_rec_tb(1).task_id, -999)
                                                     or p_cas_mol_rec_tb(1).lpn_id is null) -- Bug 6618890 --Bug#8627996
						AND NVL(mol.lpn_id, -999) = NVL(p_cas_mol_rec_tb(1).lpn_id, -999)
						AND mol.backorder_delivery_detail_id IS NULL
						AND nvl(mol.inspection_status,-1) = Nvl(p_cas_mol_rec_tb(1).inspection_status,-1)
						AND Nvl(mol.lot_number,'&#+') = Nvl(p_cas_mol_rec_tb(1).lot_number,'&#+')
						AND mol.line_status = 7
						AND (mol.quantity-Nvl(mol.quantity_delivered,0))>0
						AND exists (SELECT 1
							    FROM mtl_txn_request_headers mtrh
							    WHERE mtrh.move_order_type = inv_globals.g_move_order_put_away
							    AND   mtrh.header_id = mol.header_id)
						)
				    )
			       )
			       ORDER BY NVL(MR.DEMAND_SHIP_DATE, REQUIREMENT_DATE)) LOOP
	 EXIT WHEN l_remaining_prim_qty <= 0;

         IF (l_debug = 1) THEN
           print_debug('Looping through l_rsv_results  ' ,l_module_name,4);
         END IF;

	 IF l_rsv_results.demand_source_line_detail IS NOT NULL THEN

            IF (l_debug = 1) THEN
              print_debug('l_rsv_results.demand_source_line_detail := '|| l_rsv_results.demand_source_line_detail ,l_module_name,4);
            END IF;

	    BEGIN
	       SELECT line_id
		 INTO l_mo_line_id
		 FROM mtl_txn_request_lines mol
		 WHERE backorder_delivery_detail_id = l_rsv_results.demand_source_line_detail
		 AND mol.organization_id = p_cas_mol_rec_tb(1).organization_id
		 AND mol.inventory_item_id = p_cas_mol_rec_tb(1).inventory_item_id
		 AND NVL(mol.revision, '@@@') = NVL(p_cas_mol_rec_tb(1).item_revision, '@@@')
		 AND (NVL(mol.project_id, -999) = NVL(p_cas_mol_rec_tb(1).project_id , -999)
                      or p_cas_mol_rec_tb(1).lpn_id is null) -- Bug 6618890 --Bug#8627996
		 AND (NVL(mol.task_id, -999) = NVL(p_cas_mol_rec_tb(1).task_id, -999)
                      or p_cas_mol_rec_tb(1).lpn_id is null) -- Bug 6618890 --Bug#8627996
		 AND mol.crossdock_type = 1
		 AND NVL(mol.lpn_id, -999) = NVL(p_cas_mol_rec_tb(1).lpn_id, -999)
		 AND exists (SELECT 1
			     FROM mtl_txn_request_headers mtrh
			     WHERE mtrh.move_order_type = inv_globals.g_move_order_put_away
			     AND   mtrh.header_id = mol.header_id);
	    EXCEPTION
	       WHEN OTHERS THEN
		  IF (l_debug = 1) THEN
		     print_debug('Some other exception occurred!',l_module_name,4);
		     print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
		  END IF;
		  RAISE fnd_api.g_exc_unexpected_error;
	    END;

	    IF (l_rsv_results.primary_reservation_quantity > l_remaining_prim_qty) THEN
	       IF (l_debug = 1) THEN
		  print_debug('l_rsv_results.primary_reservation_quantity > l_remaining_prim_qty',
			      l_module_name,4);
		  print_debug('Calling split_mo...',l_module_name,4);
	       END IF;

	       l_mo_split_tb(1).prim_qty := l_remaining_prim_qty;
	       l_mo_split_tb(1).line_id := NULL;

	       inv_rcv_integration_apis.split_mo
		 (p_orig_mol_id => l_mo_line_id,
		  p_mo_splt_tb => l_mo_split_tb,
		  x_return_status => l_return_status,
		  x_msg_count => l_msg_count,
		  x_msg_data => l_msg_data);

	       IF (l_debug = 1) THEN
		  print_debug('Returned from split_mo',l_module_name,4);
		  print_debug('x_return_status: '||l_return_status,l_module_name,4);
	       END IF;

	       IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
		  IF (l_debug = 1) THEN
		     print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
		     print_debug('Raising Exception!!!',l_module_name,4);
		  END IF;
		  l_progress := '@@@';
		  RAISE fnd_api.g_exc_unexpected_error;
	       END IF;

	       l_tmp_line_id := l_mo_split_tb(1).line_id;

	       /* Lei's cancel operation will take care of this
	       l_rsv_query_rec.reservation_id := l_mo_split_tb(1).reservation_id;
	       l_rsv_query_rec.demand_source_line_detail := l_mo_split_tb(1).wdd_id;

	       IF (l_debug = 1) THEN
		  print_debug('Calling relieve_reservation...',l_module_name,4);
	       END IF;

	       relieve_reservation
		 (p_rsv_rec              => l_rsv_query_rec
		  ,p_prim_qty_to_relieve => l_remaining_prim_qty
		  ,x_return_status       => l_return_status
		  );

	       IF (l_debug = 1) THEN
		  print_debug('Returned from relieve_reservation',l_module_name,4);
		  print_debug('x_return_status: '||l_return_status,l_module_name,4);
	       END IF;

	       IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
		  IF (l_debug = 1) THEN
		     print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
		     print_debug('Raising Exception!!!',l_module_name,4);
		  END IF;
		  l_progress := '@@@';
		  RAISE fnd_api.g_exc_unexpected_error;
	       END IF;

	       IF (l_debug = 1) THEN
		  print_debug('Calling update_wdd...',l_module_name,4);
	       END IF;

	       update_wdd
		 (x_return_status    => l_return_status
		  ,x_msg_count       => l_msg_count
		  ,x_msg_data        => l_msg_data
		  ,p_wdd_id          => l_mo_split_tb(1).wdd_id
		  ,p_released_status => 'R'
		  ,p_mol_id          => NULL
		  );

	       IF (l_debug = 1) THEN
		  print_debug('Returned from update_wdd',l_module_name,4);
		  print_debug('x_return_status: '||l_return_status,l_module_name,4);
	       END IF;

	       IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
		  IF (l_debug = 1) THEN
		     print_debug('x_msg_count: '||l_msg_count,l_module_name,4);
		     print_debug('x_msg_data:  '||l_msg_data,l_module_name,4);
		     print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
		     print_debug('Raising Exception!!!',l_module_name,4);
		  END IF;
		  l_progress := '@@@';
		  RAISE fnd_api.g_exc_unexpected_error;
		 END IF;
*/


	       l_remaining_prim_qty := 0;

	     ELSE
	       /* Lei's cancel operation will take care of this
	       l_rsv_query_rec.reservation_id := l_rsv_results.reservation_id;

	       IF (l_debug = 1) THEN
		  print_debug('l_rsv_results(i).primary_reservation_quantity <= l_remaining_prim_qty',
			      l_module_name,4);
		  print_debug('Calling delete_reservation...',l_module_name,4);
	       END IF;

	       delete_reservation
		 (p_rsv_rec => l_rsv_query_rec
		  ,x_return_status => l_return_status
		  );

	       IF (l_debug = 1) THEN
		  print_debug('Returned from delete_reservation',l_module_name,4);
		  print_debug('x_return_status: '||l_return_status,l_module_name,4);
	       END IF;

	       IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
		  IF (l_debug = 1) THEN
		     print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
		     print_debug('Raising Exception!!!',l_module_name,4);
		  END IF;
		  l_progress := '@@@';
		  RAISE fnd_api.g_exc_unexpected_error;
	       END IF;

	       IF (l_debug = 1) THEN
		  print_debug('Calling update_wdd...',l_module_name,4);
	       END IF;

	       update_wdd
		 (x_return_status    => l_return_status
		  ,x_msg_count       => l_msg_count
		  ,x_msg_data        => l_msg_data
		  ,p_wdd_id          => l_rsv_results.demand_source_line_detail
		  ,p_released_status => 'R'
		  ,p_mol_id          => NULL
		  );

	       IF (l_debug = 1) THEN
		  print_debug('Returned from update_wdd',l_module_name,4);
		  print_debug('x_return_status: '||l_return_status,l_module_name,4);
	       END IF;

	       IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
		  IF (l_debug = 1) THEN
		     print_debug('x_msg_count: '||l_msg_count,l_module_name,4);
		     print_debug('x_msg_data:  '||l_msg_data,l_module_name,4);
		     print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
		     print_debug('Raising Exception!!!',l_module_name,4);
		  END IF;
		  l_progress := '@@@';
		  RAISE fnd_api.g_exc_unexpected_error;
	       END IF;

		 */
	       l_tmp_line_id := l_mo_line_id;
	       l_remaining_prim_qty := l_remaining_prim_qty - l_rsv_results.primary_reservation_quantity;
	    END IF;

	    UPDATE mtl_txn_request_lines
	      SET quantity = Nvl(quantity_delivered,0)
	      , primary_quantity = ((primary_quantity*Nvl(quantity_delivered,0))/quantity)
	      , quantity_detailed = Decode(quantity_detailed,NULL,quantity_detailed,quantity_delivered)
	      -- OPMConvergence
	      , secondary_quantity = Nvl(secondary_quantity_delivered,0)
	      , secondary_quantity_detailed = Decode(secondary_quantity_detailed,NULL,secondary_quantity_detailed,secondary_quantity_delivered)
	      -- OPMConvergence
	      , line_status = 5
	      , wms_process_flag = 1
	      WHERE line_id = l_tmp_line_id;

	       inv_rcv_integration_pvt.call_atf_api(x_return_status => l_return_status,
						    x_msg_data => l_msg_data,
						    x_msg_count => l_msg_count,
						    x_error_code => l_error_code,
						    p_source_task_id => NULL,
						    p_activity_type_id => 1,
						    p_operation_type_id => NULL,
						    p_mol_id => l_tmp_line_id,
						    p_atf_api_name => inv_rcv_integration_pvt.g_atf_api_cancel);


	  ELSE --l_rsv_result_tbl(i).demand_source_line_detail IS NULL THEN

            IF (l_debug = 1) THEN
              print_debug('l_rsv_results.demand_source_line_detail is null ',l_module_name,4);
            END IF;

	    IF (l_rsv_results.primary_reservation_quantity > l_remaining_prim_qty) THEN
	       l_loose_qty_to_splt := l_loose_qty_to_splt + l_remaining_prim_qty;
	       l_rsv_update_rec.primary_reservation_quantity := l_remaining_prim_qty;
	       l_rsv_update_rec.reservation_quantity := inv_rcv_cache.convert_qty(p_cas_mol_rec_tb(1).inventory_item_id
								    ,l_remaining_prim_qty
								    ,l_rsv_results.primary_uom_code
								    ,l_rsv_results.reservation_uom_code);
	       l_remaining_prim_qty := 0;
	     ELSE
	       l_remaining_prim_qty := l_remaining_prim_qty - l_rsv_results.primary_reservation_quantity;
	       l_loose_qty_to_splt := l_loose_qty_to_splt - l_rsv_results.primary_reservation_quantity;
	       --close entire line
	    END IF;

	    BEGIN
	       SELECT rsh.receipt_source_code
		 INTO l_receipt_source_code
		 FROM rcv_shipment_headers rsh, rcv_shipment_lines rsl
		 WHERE rsl.shipment_line_id = p_cas_mol_rec_tb(1).shipment_line_id
		 AND   rsl.shipment_header_id = rsh.shipment_header_id;
	    EXCEPTION
	       WHEN no_data_found THEN
		  IF (l_debug = 1) THEN
		     print_debug(' NO_DATA_FOUND Exception thrown  when retrieving receipt_source_cod!',l_module_name,4);
		  RAISE fnd_api.g_exc_unexpected_error;
		  END IF;
	       WHEN OTHERS THEN
		  IF (l_debug = 1) THEN
		     print_debug(' Other exceptions thrown when retrieving receipt_source_cod!',l_module_name,4);
		  END IF;
		  RAISE fnd_api.g_exc_unexpected_error;
	    END;

            IF (l_debug = 1) THEN
              print_debug('l_remaining_prim_qty= '|| l_remaining_prim_qty,l_module_name,4);
              print_debug('l_loose_qty_to_splt = '|| l_loose_qty_to_splt ,l_module_name,4);
              print_debug('l_rsv_update_rec.primary_reservation_quantity = '||l_rsv_update_rec.primary_reservation_quantity ,l_module_name,4);
              print_debug('l_rsv_update_rec.reservation_quantity = '||l_rsv_update_rec.reservation_quantity ,l_module_name,4);
	      print_debug('l_receipt_source_code = '||l_receipt_source_code,l_module_name,4);
            END IF;

	    IF (l_receipt_source_code = 'VENDOR' AND p_cas_mol_rec_tb(1).asn_line_flag = 'Y') THEN
	       l_rsv_update_rec.supply_source_type_id := g_source_type_asn;
	       l_rsv_update_rec.supply_source_header_id := p_cas_mol_rec_tb(1).po_header_id;
	       l_rsv_update_rec.supply_source_line_id := p_cas_mol_rec_tb(1).po_line_location_id;
	       l_rsv_update_rec.supply_source_line_detail := p_cas_mol_rec_tb(1).shipment_line_id;
	     ELSIF (l_receipt_source_code = 'VENDOR' AND p_cas_mol_rec_tb(1).asn_line_flag = 'N') THEN
	       l_rsv_update_rec.supply_source_type_id := inv_reservation_global.g_source_type_po;
	       l_rsv_update_rec.supply_source_header_id := p_cas_mol_rec_tb(1).po_header_id;
	       l_rsv_update_rec.supply_source_line_id := p_cas_mol_rec_tb(1).po_line_location_id;
	       l_rsv_update_rec.supply_source_line_detail := NULL;
	     ELSIF (l_receipt_source_code = 'INTERNAL ORDER') THEN
	       l_rsv_update_rec.supply_source_type_id :=
		 inv_reservation_global.g_source_type_internal_req;
	       l_rsv_update_rec.supply_source_header_id := l_requisition_header_id;
	       l_rsv_update_rec.supply_source_line_id := p_cas_mol_rec_tb(1).requisition_line_id;
	       l_rsv_update_rec.supply_source_line_detail := NULL;
	     ELSIF (l_receipt_source_code = 'INVENTORY') THEN
                BEGIN
		   SELECT shipment_header_id
		     INTO l_shipment_header_id
		     FROM rcv_shipment_lines
		     WHERE shipment_line_id = p_cas_mol_rec_tb(1).shipment_line_id
		     FOR UPDATE NOWAIT;
		EXCEPTION
		   WHEN OTHERS THEN
		      IF (l_debug = 1) THEN
			 print_debug('Some other exception occurred in getting shipment details',l_module_name,4);
			 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
		      END IF;
		      RAISE fnd_api.g_exc_unexpected_error;
		END;
	       l_rsv_update_rec.supply_source_type_id := g_source_type_in_transit;
	       l_rsv_update_rec.supply_source_header_id := l_shipment_header_id;
	       l_rsv_update_rec.supply_source_line_id := l_shipment_header_id;
	       l_rsv_update_rec.supply_source_line_detail := NULL;
	     ELSIF (l_receipt_source_code = 'CUSTOMER') THEN
	       IF (l_debug = 1) THEN
		  print_debug('RMA lines. Should not reach here!',l_module_name,4);
	       END IF;
	       RAISE fnd_api.g_exc_unexpected_error;
	    END IF;

	    IF (l_debug = 1) THEN
	       print_debug('Calling transfer_reservation...',l_module_name,4);
	    END IF;

	    l_rsv_query_rec.reservation_id := l_rsv_results.reservation_id;
	    l_rsv_query_rec.organization_id := p_cas_mol_rec_tb(1).organization_id;

	    transfer_reservation
	      (p_original_rsv_rec => l_rsv_query_rec
	       ,p_to_rsv_rec      => l_rsv_update_rec
	       ,x_new_rsv_id      => l_new_rsv_id
	       ,x_return_status   => l_return_status);

	    IF (l_debug = 1) THEN
	       print_debug('Returned from transfer_reservation',l_module_name,4);
	       print_debug('x_return_status: '||l_return_status,l_module_name,4);
	    END IF;

	    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('x_msg_data:   '||l_msg_data,l_module_name,4);
		  print_debug('x_msg_count:  '||l_msg_count,l_module_name,4);
		  print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
		  print_debug('Raising Exception!!!',l_module_name,4);
	       END IF;
	       l_progress := '@@@';
	       RAISE fnd_api.g_exc_unexpected_error;
	    END IF;

	    IF (l_debug = 1) THEN
	       print_debug('l_new_rsv_id: '||l_new_rsv_id,l_module_name,4);
	    END IF;
	 END IF;--IF l_rsv_result_tbl(i).demand_source_line_detail IS NOT NULL THEN
      END LOOP;--FOR i IN 1..l_rsv_results.COUNT LOOP
   END IF;--IF (l_deal_with_reservation = 0) THEN

   IF (l_debug = 1) THEN
      print_debug('l_loose_qty_to_splt:'||l_loose_qty_to_splt||' l_remaining_prim_qty:'||l_remaining_prim_qty,l_module_name,4);
   END IF;

   IF l_loose_qty_to_splt + l_remaining_prim_qty > 0 THEN

      IF (l_debug = 1) THEN
         print_debug('Before getting l_qty_to_close' ,l_module_name,4);
      END IF;

      l_qty_to_close := l_loose_qty_to_splt + l_remaining_prim_qty;

      IF (l_debug = 1) THEN
         print_debug('l_qty_to_close = ' || l_qty_to_close ,l_module_name,4);
         print_debug('Before Opening MOL cursor' ,l_module_name,4);
         print_debug('p_cas_mol_rec_tb(1).organization_id = '|| p_cas_mol_rec_tb(1).organization_id ,l_module_name,4);
         print_debug('p_cas_mol_rec_tb(1).lpn_id = '|| p_cas_mol_rec_tb(1).lpn_id ,l_module_name,4);
         print_debug('p_cas_mol_rec_tb(1).inventory_item_id = '|| p_cas_mol_rec_tb(1).inventory_item_id ,l_module_name,4);
         print_debug('p_cas_mol_rec_tb(1).item_revision = '|| p_cas_mol_rec_tb(1).item_revision ,l_module_name,4);
         print_debug('p_cas_mol_rec_tb(1).inspection_status = '|| p_cas_mol_rec_tb(1).inspection_status ,l_module_name,4);
         print_debug('p_cas_mol_rec_tb(1).project_id = '|| p_cas_mol_rec_tb(1).project_id ,l_module_name,4);
         print_debug('p_cas_mol_rec_tb(1).task_id = '|| p_cas_mol_rec_tb(1).task_id ,l_module_name,4);
         print_debug('p_cas_mol_rec_tb(1).lot_number = '|| p_cas_mol_rec_tb(1).lot_number ,l_module_name,4);
      END IF;

      FOR l_mol_rec IN (SELECT mtrl.line_id
			,      mtrl.primary_quantity
			FROM   mtl_txn_request_lines mtrl
			WHERE  mtrl.line_status = 7
			AND    (mtrl.quantity-Nvl(mtrl.quantity_delivered,0)) > 0
			-- AND    mtrl.backorder_delivery_detail_id IS NULL --Bug#6040524
			AND    mtrl.organization_id = p_cas_mol_rec_tb(1).organization_id
                        --  Bug 4508608
                        --  hadling of non lpn cases are done properly
			--  AND    mtrl.lpn_id = p_cas_mol_rec_tb(1).lpn_id
		        AND    nvl(mtrl.lpn_id, -999) = nvl(p_cas_mol_rec_tb(1).lpn_id, -999)
			AND    mtrl.inventory_item_id = p_cas_mol_rec_tb(1).inventory_item_id
			AND    Nvl(mtrl.revision,'%^$') = Nvl(p_cas_mol_rec_tb(1).item_revision,'%^$')
			AND    Nvl(mtrl.inspection_status,-1) = Nvl(p_cas_mol_rec_tb(1).inspection_status,-1)
			AND    (NVL(mtrl.project_id, -999) = NVL(p_cas_mol_rec_tb(1).project_id, -999)
                                OR  p_cas_mol_rec_tb(1).lpn_id IS NULL) -- Bug 6618890 --Bug#8627996
			AND    (NVL(mtrl.task_id, -999) = NVL(p_cas_mol_rec_tb(1).task_id, -999)
                                OR  p_cas_mol_rec_tb(1).lpn_id IS NULL) -- Bug 6618890 --Bug#8627996
			AND    Nvl(mtrl.lot_number,'&*_') = Nvl(p_cas_mol_rec_tb(1).lot_number,'&*_')
			AND    exists (SELECT 1
				       FROM mtl_txn_request_headers mtrh
				       WHERE mtrh.move_order_type = inv_globals.g_move_order_put_away
				       AND   mtrh.header_id = mtrl.header_id)
			  )
      LOOP
	 IF (l_debug = 1) THEN
	    print_debug('MOL found: '|| l_mol_rec.line_id||' QTY: '||l_mol_rec.primary_quantity,l_module_name,4);
	 END IF;

	 IF l_qty_to_close < l_mol_rec.primary_quantity THEN
	    IF (l_debug = 1) THEN
	       print_debug('Calling split_mo...',l_module_name,4);
	    END IF;

	    l_mo_split_tb(1).prim_qty := l_qty_to_close;
	    l_mo_split_tb(1).line_id := NULL;

	    inv_rcv_integration_apis.split_mo
	      (p_orig_mol_id => l_mol_rec.line_id,
	       p_mo_splt_tb => l_mo_split_tb,
	       x_return_status => l_return_status,
	       x_msg_count => l_msg_count,
	       x_msg_data => l_msg_data);

	    IF (l_debug = 1) THEN
	       print_debug('Returned from split_mo',l_module_name,4);
	       print_debug('x_return_status: '||l_return_status,l_module_name,4);
	    END IF;

	    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
		  print_debug('Raising Exception!!!',l_module_name,4);
	       END IF;
	       l_progress := '@@@';
	       RAISE fnd_api.g_exc_unexpected_error;
	    END IF;

	    l_tmp_line_id := l_mo_split_tb(1).line_id;
	    l_qty_to_close := l_qty_to_close - l_mol_rec.primary_quantity;
	  ELSE
	    l_tmp_line_id := l_mol_rec.line_id;
	    l_qty_to_close := 0;
	 END IF;

	 IF (l_debug = 1) THEN
	    print_debug('Call cancel ATF',l_module_name,9);
	 END IF;

	 inv_rcv_integration_pvt.call_atf_api(x_return_status => l_return_status,
					      x_msg_data => l_msg_data,
					      x_msg_count => l_msg_count,
					      x_error_code => l_error_code,
					      p_source_task_id => NULL,
					      p_activity_type_id => 1,
					      p_operation_type_id => NULL,
					      p_mol_id => l_tmp_line_id,
					      p_atf_api_name => inv_rcv_integration_pvt.g_atf_api_cancel);

	 IF (l_debug = 1) THEN
	    print_debug('Closing MOL '||l_tmp_line_id,l_module_name,9);
	 END IF;

	 UPDATE mtl_txn_request_lines
	   SET quantity = Nvl(quantity_delivered,0)
	   , primary_quantity = ((primary_quantity*Nvl(quantity_delivered,0))/quantity)
	   , quantity_detailed = Decode(quantity_detailed,NULL,quantity_detailed,quantity_delivered)
	   -- OPMConvergence
	   , secondary_quantity = Nvl(secondary_quantity_delivered,0)
	   , secondary_quantity_detailed = Decode(secondary_quantity_detailed,NULL,secondary_quantity_detailed,secondary_quantity_delivered)
	   -- OPMConvergence
	   , line_status = 5
	   , wms_process_flag = 1
	   WHERE line_id = l_tmp_line_id;

	 IF (l_qty_to_close <= 0) THEN
	    IF (l_debug = 1) THEN
	       print_debug('Exiting from the MOL Loop' ,l_module_name,9);
	    END IF;
	    EXIT;
	 END if;
      END LOOP;

      IF (l_qty_to_close > 0) THEN
	 IF (l_debug = 1) THEN
	    print_debug('l_qty_to_close > 0.  Could not find matching move order for the qty !',l_module_name,4);
	 END IF;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;

   IF (l_debug = 1) THEN
      print_debug('Exitting maintain_rsv_returns with the following values:',l_module_name,4);
      print_debug('x_return_status  => '||x_return_status,l_module_name,4);
      print_debug('x_msg_count      => '||x_msg_count,l_module_name,4);
      print_debug('x_msg_data       => '||x_msg_data,l_module_name,4);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred at progress: '||l_progress,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
      END IF;
      x_return_status :=  fnd_api.g_ret_sts_error;
END maintain_rsv_returns;

PROCEDURE split_close_mo_for_ret_corr
  (x_return_status OUT NOCOPY 	VARCHAR2
   ,x_msg_count    OUT NOCOPY 	NUMBER
   ,x_msg_data     OUT NOCOPY 	VARCHAR2
   ,p_cas_mol_tb   IN  inv_rcv_integration_pvt.cas_mol_rec_tb_tp
   ) IS
     CURSOR c_mol_no_mmtt (p_org_id NUMBER,
                           p_item NUMBER,
                           p_lpn NUMBER,
			   p_lot VARCHAR2,
                           p_rev VARCHAR2,
                           p_from_sub varchar2,
                           p_from_locator_id NUMBER,
                           -- p_cost_group_id NUMBER, ????
                           p_project_id NUMBER,
                           p_task_id NUMBER,
                           p_inspection_status NUMBER ,
                           p_uom_code varchar2
                   ) IS
  			      --Bug 5231114:Added the condition on transaction_source_type_id and
                              -- transaction_action_id for the following combinations:13/12 and 4/27
			      SELECT DISTINCT mtrl.line_id
                                , Decode(p_uom_code,mtrl.uom_code,1,2) UOM_ORDERING
				, Decode(mmtt.transaction_source_type_id||'#'||mmtt.transaction_action_id,'1#27',1,
					 '7#12',1,'12#27',1,'13#12',1,'4#27',1,null) transaction_temp_id
				, mtrl.wms_process_flag
				, (mtrl.quantity - Nvl(mtrl.quantity_delivered, 0)) quantity
				, mtrl.primary_quantity
				, mtrl.uom_code
				, mtrl.lpn_id
				, mtrl.inventory_item_id
				, mtrl.lot_number
                                -- OPMConvergence
				, (mtrl.secondary_quantity - Nvl(mtrl.secondary_quantity_delivered, 0)) secondary_quantity_2
	                        , mtrl.secondary_quantity
	                        , mtrl.secondary_uom_code
                                -- OPMConvergence
                                , mtrl.crossdock_type
                                , mtrl.backorder_delivery_detail_id
                                , mmtt.wip_supply_type
                                , mtrl.reference
                                , mtrl.reference_type_code
                                , mtrl.reference_id
				FROM mtl_txn_request_lines mtrl
				, mtl_material_transactions_temp mmtt
				WHERE mtrl.organization_id = p_org_id
                                AND nvl(mtrl.from_subinventory_code,'@$#_') = nvl(p_from_sub,'@$#_')
                                AND nvl(mtrl.from_locator_id,-1) = nvl(p_from_locator_id,-1)
                                AND (nvl(mtrl.project_id,-1) = nvl(p_project_id,-1)
                                     or p_lpn is null) -- Bug 6618890 --Bug#8627996
                                AND (nvl(mtrl.task_id,-1) = nvl(p_task_id,-1)
                                     or p_lpn is null) -- Bug 6618890 --Bug#8627996
                                AND Nvl(inspection_status,-1)    = Nvl(p_inspection_status,-1)
				AND mtrl.inventory_item_id = p_item
				AND Nvl(mtrl.revision, Nvl(p_rev, '@@@@')) = Nvl(p_rev, '@@@@')
				AND Nvl(mtrl.lpn_id, -1) = Nvl(p_lpn, -1)
				AND Nvl(mtrl.lot_number, Nvl(p_lot,'@$#_')) = Nvl(p_lot, '@$#_')
				AND (mtrl.quantity - Nvl(mtrl.quantity_delivered, 0)) > 0
				AND mmtt.move_order_line_id (+) = mtrl.line_id
				AND mmtt.organization_id (+) = mtrl.organization_id
				AND exists (SELECT 1
					    FROM  mtl_txn_request_headers mtrh
					    WHERE mtrh.move_order_type = inv_globals.g_move_order_put_away
					    AND   mtrh.header_id = mtrl.header_id)
				--only pick up lines that are NOT loaded
				AND (mmtt.transaction_temp_id IS NULL
				     OR
				     (mmtt.transaction_temp_id IS NOT NULL
				     --Bug 5231114:Added the condition on transaction_source_type_id and
				     --transaction_action_id for the following combinations:13/12 and 4/27.
				      AND ((mmtt.transaction_source_type_id = 1 AND mmtt.transaction_action_id = 27)
					   OR (mmtt.transaction_source_type_id = 7 AND mmtt.transaction_action_id = 12)
					   OR (mmtt.transaction_source_type_id = 12 AND mmtt.transaction_action_id = 27)
					   OR (mmtt.transaction_source_type_id = 13 AND mmtt.transaction_action_id = 12)
					   OR (mmtt.transaction_source_type_id = 4 AND mmtt.transaction_action_id = 27))
				      AND NOT exists (SELECT 1
						      FROM wms_dispatched_tasks wdt
						      WHERE wdt.transaction_temp_id = mmtt.transaction_temp_id
						      AND wdt.status IN (3, 4) -- dispached or loaded
						      AND wdt.task_type = 2 -- putaway
						      )
				      )
				     )
				 ORDER BY 2 DESC, Nvl(transaction_temp_id, -1) ASC ;

     l_mol_rec c_mol_no_mmtt%ROWTYPE;

     l_remaining_primary_quantity NUMBER;
     l_dummy VARCHAR2(1);
     l_mol_qty_in_puom NUMBER;
     l_error_code    NUMBER;
     l_mo_split_tb     inv_rcv_integration_apis.mo_in_tb_tp;

     l_debug    NUMBER;
     l_progress VARCHAR2(10);
     l_module_name VARCHAR2(30);

BEGIN

   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

   IF (l_debug = 1) THEN
      print_debug('Entering split_close_mo_for_ret_corr...',l_module_name,4);
      print_debug(' p_cas_mol_tb(1).organization_id        => '||p_cas_mol_tb(1).organization_id,l_module_name,4);
      print_debug(' p_cas_mol_tb(1).inventory_item_id      => '||p_cas_mol_tb(1).inventory_item_id,l_module_name,4);
      print_debug(' p_cas_mol_tb(1).lpn_id                 => '||p_cas_mol_tb(1).lpn_id,l_module_name,4);
      print_debug(' p_cas_mol_tb(1).lot_number             => '||p_cas_mol_tb(1).lot_number,l_module_name,4);
      print_debug(' p_cas_mol_tb(1).item_revision          => '||p_cas_mol_tb(1).item_revision,l_module_name,4);
      print_debug(' p_cas_mol_tb(1).from_subinventory_code => '||p_cas_mol_tb(1).from_subinventory_code,l_module_name,4);
      print_debug(' p_cas_mol_tb(1).from_locator_id        => '||p_cas_mol_tb(1).from_locator_id,l_module_name,4);
      print_debug(' p_cas_mol_tb(1).project_id             => '||p_cas_mol_tb(1).project_id,l_module_name,4);
      print_debug(' p_cas_mol_tb(1).task_id                => '||p_cas_mol_tb(1).task_id,l_module_name,4);
      print_debug(' p_cas_mol_tb(1).inspection_status      => '||p_cas_mol_tb(1).inspection_status,l_module_name,4);
      print_debug(' p_cas_mol_tb(1).uom_code               => '||p_cas_mol_tb(1).uom_code,l_module_name,4);
  END IF;

   l_progress := '10';
   l_module_name := 'SET_CLOSE_MO_FOR_RET_CORR';
   x_return_status := fnd_api.g_ret_sts_success;

   OPEN c_mol_no_mmtt(p_cas_mol_tb(1).organization_id
		      ,p_cas_mol_tb(1).inventory_item_id
		      ,p_cas_mol_tb(1).lpn_id
		      ,p_cas_mol_tb(1).lot_number
		      ,p_cas_mol_tb(1).item_revision
		      ,p_cas_mol_tb(1).from_subinventory_code
		      ,p_cas_mol_tb(1).from_locator_id
		      ,p_cas_mol_tb(1).project_id
		      ,p_cas_mol_tb(1).task_id
		      ,p_cas_mol_tb(1).inspection_status
		      ,p_cas_mol_tb(1).uom_code
		      );

   l_remaining_primary_quantity := Abs(p_cas_mol_tb(1).primary_qty);

   IF (l_debug = 1) THEN
      print_debug('Remaining Primary Quantity:'||l_remaining_primary_quantity,l_module_name,4);
   END IF;

   LOOP
      FETCH c_mol_no_mmtt INTO l_mol_rec;
      EXIT WHEN c_mol_no_mmtt%notfound;


      /* per Karun's request, this query has been moved into the cursor above
      IF (l_mol_rec.transaction_temp_id IS NOT NULL) THEN
         BEGIN
	    SELECT '1'
	      INTO l_dummy
	      FROM dual
	      WHERE exists
	      (SELECT 1
	       FROM wms_dispatched_tasks wdt
	       , mtl_material_transactions_temp mmtt
	       WHERE mmtt.move_order_line_id = l_mol_rec.line_id
		     AND ((transaction_source_type_id = 1 AND transaction_action_id = 27)
			  OR (transaction_source_type_id = 7 AND transaction_action_id = 12)
			  OR (transaction_source_type_id = 12 AND transaction_action_id = 27))
	       AND wdt.transaction_temp_id = mmtt.transaction_temp_id
	       AND wdt.status IN (3, 4) -- dispached or loaded
	       AND wdt.task_type = 2 -- putaway
	       );

	    RAISE fnd_api.g_exc_error;
	 EXCEPTION
	    WHEN no_data_found THEN
	       NULL;
	 END;
      END IF;
	*/


      l_mol_qty_in_puom := inv_rcv_cache.convert_qty(l_mol_rec.inventory_item_id,
				       l_mol_rec.quantity,
				       l_mol_rec.uom_code,
				       p_cas_mol_tb(1).primary_uom_code);

      IF  l_mol_qty_in_puom <= l_remaining_primary_quantity THEN
	 --update the mol
	 UPDATE mtl_txn_request_lines
	   SET quantity = Nvl(quantity_delivered,0)
	   , primary_quantity = ((primary_quantity*Nvl(quantity_delivered,0))/quantity)
	   , quantity_detailed = Decode(quantity_detailed,NULL,quantity_detailed,quantity_delivered)
	   -- OPMConvergence
	   , secondary_quantity = Nvl(secondary_quantity_delivered,0)
	   , secondary_quantity_detailed = Decode(secondary_quantity_detailed,NULL,secondary_quantity_detailed,secondary_quantity_delivered)
	   -- OPMConvergence
	   , line_status = 5
	   , wms_process_flag = 1
	   WHERE line_id = l_mol_rec.line_id;

	 -- Call cancel operation plan
	 IF (l_debug = 1) THEN
	    print_debug('calling call_atf_api:'||l_mol_rec.line_id,l_module_name,4);
	 END IF;

	 inv_rcv_integration_pvt.call_atf_api(x_return_status => x_return_status,
					      x_msg_data => x_msg_data,
					      x_msg_count => x_msg_count,
					      x_error_code => l_error_code,
					      p_source_task_id => NULL,
					      p_activity_type_id => 1,
					      p_operation_type_id => NULL,
					      p_mol_id => l_mol_rec.line_id,
					      p_atf_api_name => inv_rcv_integration_pvt.g_atf_api_cancel);

	 IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('call_atf_api failed:'||l_mol_rec.line_id,l_module_name,4);
	    END IF;
	    --raise error
	    RAISE fnd_api.g_exc_error;
	 END IF;

	 l_remaining_primary_quantity := l_remaining_primary_quantity -
	   l_mol_qty_in_puom;
       ELSE
	 -- Call split_mo and then update the new line to quantity
	 -- = 0  and then
	 -- Call cancel operation plan for new line

	 IF (l_debug = 1) THEN
	    print_debug('CALLING SPLIT_MO:'||l_remaining_primary_quantity,l_module_name,4);
	 END IF;

	 l_mo_split_tb(1).prim_qty := l_remaining_primary_quantity;
	 l_mo_split_tb(1).line_id := NULL;

	 inv_rcv_integration_apis.split_mo
	   (p_orig_mol_id => l_mol_rec.line_id,
	    p_mo_splt_tb => l_mo_split_tb,
	    x_return_status => x_return_status,
	    x_msg_count => x_msg_count,
	    x_msg_data => x_msg_data);

	 IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
	    RAISE fnd_api.g_exc_error;
	 END IF;


	 IF (l_debug = 1) THEN
	    print_debug('NEW LINE ID:'||l_mo_split_tb(1).line_id,l_module_name,4);
	 END IF;

	 --update the new line for return
	 UPDATE mtl_txn_request_lines
	   SET quantity = Nvl(quantity_delivered,0)
	   , primary_quantity = ((primary_quantity*Nvl(quantity_delivered,0))/quantity)
	   , quantity_detailed = Decode(quantity_detailed,NULL,quantity_detailed,quantity_delivered)
	   -- OPMConvergence
	   , secondary_quantity = Nvl(secondary_quantity_delivered,0)
	   , secondary_quantity_detailed = Decode(secondary_quantity_detailed,NULL,secondary_quantity_detailed,secondary_quantity_delivered)
	   -- OPMConvergence
	   , line_status = 5
	   , wms_process_flag = 1
	   WHERE line_id = l_mo_split_tb(1).line_id;

	 -- Call cancel operation plan for the new line
	 inv_rcv_integration_pvt.call_atf_api(x_return_status => x_return_status,
		      x_msg_data => x_msg_data,
		      x_msg_count => x_msg_count,
		      x_error_code => l_error_code,
		      p_source_task_id => NULL,
		      p_activity_type_id => 1,
		      p_operation_type_id => NULL,
		      p_mol_id => l_mo_split_tb(1).line_id,
		      p_atf_api_name => inv_rcv_integration_pvt.g_atf_api_cancel);

	 IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('call_atf_api failed:'||l_mo_split_tb(1).line_id,l_module_name,4);
	    END IF;
	    --raise error
	    RAISE fnd_api.g_exc_error;
	 END IF;

	 --update the old line for wms process flag
	 UPDATE mtl_txn_request_lines
	   SET wms_process_flag = 1
	   WHERE line_id = l_mol_rec.line_id;

	 l_remaining_primary_quantity := 0;
      END IF;

      IF (l_remaining_primary_quantity = 0) THEN
	 EXIT;
      END IF;

   END LOOP;

   IF l_remaining_primary_quantity > 0 THEN
      --raise error
      IF (l_debug = 1) THEN
	 print_debug('Quantity Still Remaining!!! WHY???:'||l_remaining_primary_quantity,l_module_name,4);
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred at progress:'||l_progress,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
      END IF;
      x_return_status :=  fnd_api.g_ret_sts_error;
END split_close_mo_for_ret_corr;

PROCEDURE maintain_reservations
  (x_return_status OUT NOCOPY 	VARCHAR2
   ,x_msg_count    OUT NOCOPY 	NUMBER
   ,x_msg_data     OUT NOCOPY 	VARCHAR2
   ,x_mol_tb       OUT NOCOPY   inv_rcv_integration_pvt.cas_mol_rec_tb_tp
   ,p_cas_mol_tb   IN  inv_rcv_integration_pvt.cas_mol_rec_tb_tp
   )
  IS
     l_debug    NUMBER;
     l_progress VARCHAR2(10);
     l_module_name VARCHAR2(30);
BEGIN
   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

   IF (l_debug = 1) THEN
      print_debug('Entering maintain_reservations...',l_module_name,4);
      print_debug(' p_cas_mol_tb(1).transaction_type => ' ||p_cas_mol_tb(1).transaction_type,l_module_name,4);
   END IF;

   l_progress := '10';
   l_module_name := 'MAINTAIN_RESERVATIONS';
   x_return_status := fnd_api.g_ret_sts_success;



   --{{
   --********** PROCEDURE maintain_reservations *********
   --Make sure that the following transaction are tested, and
   --the correct private APIs are called }}

   --{{
   --Test Receipt, Match, positive correction on receipt}}
   IF (p_cas_mol_tb(1).transaction_type IN ('RECEIVE','MATCH')
       OR
       (p_cas_mol_tb(1).transaction_type = 'CORRECT'
	AND p_cas_mol_tb(1).primary_qty  > 0
	AND p_cas_mol_tb(1).parent_txn_type IN ('RECEIVE'))
       OR
       (p_cas_mol_tb(1).transaction_type = 'CORRECT'
	AND p_cas_mol_tb(1).primary_qty  < 0
	AND p_cas_mol_tb(1).parent_txn_type IN ('RETURN TO VENDOR','RETURN TO CUSTOMER'))
       ) THEN
      maintain_rsv_receive
	(x_return_status => x_return_status
	 ,x_msg_count    => x_msg_count
	 ,x_msg_data     => x_msg_data
	 ,x_cas_mol_rec_tb   => x_mol_tb
	 ,p_cas_mol_rec_tb   => p_cas_mol_tb);

   --{{
   --Test deliver and positive correction of deliver}}
    ELSIF (p_cas_mol_tb(1).transaction_type = 'DELIVER'
	   OR
	   (p_cas_mol_tb(1).transaction_type = 'CORRECT'
	    AND p_cas_mol_tb(1).primary_qty  > 0
	    AND p_cas_mol_tb(1).parent_txn_type IN ('DELIVER'))) THEN
      maintain_rsv_deliver
	(x_return_status => x_return_status
	 ,x_msg_count    => x_msg_count
	 ,x_msg_data     => x_msg_data
	 ,p_cas_mol_rec_tb   => p_cas_mol_tb);

   --{{
   --Test cancelling an ASN that has reservation tied to it}}
    ELSIF p_cas_mol_tb(1).transaction_type = 'CANCEL' THEN
      maintain_rsv_cancel_asn
	(x_return_status => x_return_status
	 ,x_msg_count    => x_msg_count
	 ,x_msg_data     => x_msg_data
	 ,p_cas_mol_rec_tb   => p_cas_mol_tb);

   --{{
   --Test import ASN of a PO against which a reservation is created}}
    ELSIF p_cas_mol_tb(1).transaction_type = 'SHIP' AND p_cas_mol_tb(1).source_document_code = 'PO' THEN
      maintain_rsv_import_asn
      (x_return_status => x_return_status
       ,x_msg_count    => x_msg_count
       ,x_msg_data     => x_msg_data
       ,p_cas_mol_rec_tb   => p_cas_mol_tb);

   --{{
   --Test 1. Negative correction of Receipt
   --     2. Positive correction of RTV and RTC
   --     3. RTV and RTC
   --MOL should be reduced from receiving
    ELSIF ((p_cas_mol_tb(1).transaction_type IN ('CORRECT')
	    AND p_cas_mol_tb(1).primary_qty < 0
	    AND p_cas_mol_tb(1).parent_txn_type IN ('RECEIVE'))
	   OR
	   (p_cas_mol_tb(1).transaction_type IN ('CORRECT')
	    AND p_cas_mol_tb(1).primary_qty > 0
	    AND p_cas_mol_tb(1).parent_txn_type IN ('RETURN TO VENDOR','RETURN TO CUSTOMER')
	    AND Nvl(p_cas_mol_tb(1).grand_parent_txn_type,'#@#') <> 'DELIVER')
	   OR
	   (p_cas_mol_tb(1).transaction_type IN ('RETURN TO VENDOR','RETURN TO CUSTOMER')
	    AND p_cas_mol_tb(1).parent_txn_type <> 'DELIVER')) THEN

      IF (l_debug = 1) THEN
	 print_debug('- Corr of Receive/+ Corr of RTV and RTC/RTV and RTC.  Calling maintain_rsv_returns',l_module_name,4);
      END IF;

      maintain_rsv_returns
	(x_return_status => x_return_status
	 ,x_msg_count    => x_msg_count
	 ,x_msg_data     => x_msg_data
	 ,p_cas_mol_rec_tb   => p_cas_mol_tb);


   --{{
   --Test 1. Negative corr of inspect and transfer
   --     2. Positive corr of inspect and transfer
   --MOL should be transfered within receiving
    ELSIF ((p_cas_mol_tb(1).transaction_type IN ('CORRECT')
	    AND p_cas_mol_tb(1).primary_qty < 0
	    AND p_cas_mol_tb(1).parent_txn_type IN ('ACCEPT','REJECT','TRANSFER'))
	   OR
	   (p_cas_mol_tb(1).transaction_type IN ('CORRECT')
	    AND p_cas_mol_tb(1).primary_qty > 0
	    AND p_cas_mol_tb(1).parent_txn_type IN ('ACCEPT','REJECT','TRANSFER'))) THEN

      IF (l_debug = 1) THEN
	 print_debug('-/+ Corr of Inspect and Transfer. Need to close and create MOL',l_module_name,4);
      END IF;

      split_close_mo_for_ret_corr(x_return_status => x_return_status
				  ,x_msg_count    => x_msg_count
				  ,x_msg_data     => x_msg_data
				  ,p_cas_mol_tb   => p_cas_mol_tb);

      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
               print_debug('split_mo_ret_corr failed for this process ',l_module_name,4);
            END IF;
            --raise error
            RAISE fnd_api.g_exc_error;
      END IF;

      set_mol_wdd_tbl(p_cas_mol_tb(1),
		      x_mol_tb,
		      p_cas_mol_tb(1).primary_qty,
		      NULL,
		      NULL);


   --{{
   --Test negative correction of RTC
   --Materials should be reduced into receiving}}
    ELSIF (p_cas_mol_tb(1).transaction_type IN ('CORRECT')
	   AND p_cas_mol_tb(1).primary_qty < 0
	   AND p_cas_mol_tb(1).parent_txn_type IN ('RETURN TO RECEIVING')) THEN

      IF (l_debug = 1) THEN
	 print_debug('- Corr of RTR.  Need to close MOL',l_module_name,4);
      END IF;

      split_close_mo_for_ret_corr(x_return_status => x_return_status
				  ,x_msg_count    => x_msg_count
				  ,x_msg_data     => x_msg_data
				  ,p_cas_mol_tb   => p_cas_mol_tb);

     IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
               print_debug('split_mo_ret_corr failed for this process ',l_module_name,4);
            END IF;
            --raise error
            RAISE fnd_api.g_exc_error;
      END IF;


   --{{
   --Test 1. negative correction of deliver
   --     2. positive correction of RTR
   --     3. RTR
   --Materials should be added to receiving }}
    ELSIF ((p_cas_mol_tb(1).transaction_type IN ('CORRECT')
	    AND p_cas_mol_tb(1).primary_qty < 0
	    AND p_cas_mol_tb(1).parent_txn_type = 'DELIVER')
	   OR
	   (p_cas_mol_tb(1).transaction_type IN ('CORRECT')
	    AND p_cas_mol_tb(1).primary_qty > 0
	    AND p_cas_mol_tb(1).parent_txn_type IN ('RETURN TO RECEIVING'))
	   OR
	   p_cas_mol_tb(1).transaction_type = 'RETURN TO RECEIVING') THEN

      IF (l_debug = 1) THEN
	 print_debug('- Corr of deliver/+ Corr of RTR/RTR. Need to create MOL',l_module_name,4);
      END IF;

      set_mol_wdd_tbl(p_cas_mol_tb(1),
		      x_mol_tb,
		      p_cas_mol_tb(1).primary_qty,
		      NULL,
		      NULL);
   END IF;

   --{{
   --********** END PROCEDURE maintain_reservations *********}}

EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred at progress:'||l_progress,l_module_name,4);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,4);
      END IF;
      x_return_status :=  fnd_api.g_ret_sts_error;
END maintain_reservations;
END inv_rcv_reservation_util;


/

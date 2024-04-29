--------------------------------------------------------
--  DDL for Package Body WMS_CROSSDOCK_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CROSSDOCK_GRP" AS
  /* $Header: WMSXDGRB.pls 120.4 2005/07/06 14:13:33 stdavid noship $ */

  g_pkg_body_ver  CONSTANT VARCHAR2(100) := '$Header: WMSXDGRB.pls 120.4 2005/07/06 14:13:33 stdavid noship $';
  g_newline       CONSTANT VARCHAR2(10)  := fnd_global.newline;



  PROCEDURE print_debug
  ( p_msg      IN VARCHAR2
  , p_api_name IN VARCHAR2
  ) IS
  BEGIN
    inv_log_util.trace
    ( p_message => p_msg
    , p_module  => g_pkg_name || '.' || p_api_name
    , p_level   => 4
    );
  END print_debug;



  PROCEDURE print_version_info
    IS
  BEGIN
    print_debug ('Spec::  ' || g_pkg_spec_ver, 'print_version_info');
    print_debug ('Body::  ' || g_pkg_body_ver, 'print_version_info');
  END print_version_info;



  PROCEDURE validate_planxdock_crt_id
  ( x_return_status  OUT NOCOPY  VARCHAR2
  , p_criterion_id   IN          NUMBER
  ) IS

    l_api_name   VARCHAR2(30);
    l_debug      NUMBER;
    l_dummy      NUMBER;
    l_msg_count  NUMBER;
    l_msg_data   VARCHAR2(2000);

    CURSOR c_check_if_planned_criterion
    ( p_crt_id  IN  NUMBER
    ) IS
       SELECT wcc.criterion_id
         FROM wms_crossdock_criteria  wcc
        WHERE wcc.criterion_id   = p_crt_id
          AND wcc.criterion_type = wms_xdock_utils_pvt.G_CRT_TYPE_PLAN;

  BEGIN
    l_api_name      := 'validate_planxdock_crt_id';
    l_debug         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    x_return_status := fnd_api.g_ret_sts_success;

    print_version_info;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline              ||
         'p_criterion_id => '        || to_char(p_criterion_id)
       , l_api_name
       );
    END IF;

    OPEN c_check_if_planned_criterion (p_criterion_id);
    FETCH c_check_if_planned_criterion INTO l_dummy;

    IF c_check_if_planned_criterion%NOTFOUND
    THEN
       IF l_debug = 1 THEN
          print_debug('Criterion ID not found', l_api_name);
       END IF;
       fnd_message.set_name('WMS', 'WMS_XDCRT_INVLD_PLAN_CRT');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    END IF;

    CLOSE c_check_if_planned_criterion;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      IF c_check_if_planned_criterion%ISOPEN THEN
         CLOSE c_check_if_planned_criterion;
      END IF;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF c_check_if_planned_criterion%ISOPEN THEN
         CLOSE c_check_if_planned_criterion;
      END IF;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END validate_planxdock_crt_id;



  PROCEDURE chk_planxd_crt_id_name
  ( x_return_status    OUT    NOCOPY   VARCHAR2
  , p_criterion_id     IN OUT NOCOPY   NUMBER
  , p_criterion_name   IN OUT NOCOPY   VARCHAR2
  ) IS

    l_api_name   VARCHAR2(30);
    l_debug      NUMBER;
    l_msg_count  NUMBER;
    l_msg_data   VARCHAR2(2000);

    l_crt_id     NUMBER;
    l_crt_name   VARCHAR2(80);

    CURSOR c_get_plan_crt_name
    ( p_crt_id  IN  NUMBER
    ) IS
       SELECT wccv.criterion_name
         FROM wms_crossdock_criteria_vl  wccv
        WHERE wccv.criterion_id   = p_crt_id
          AND wccv.criterion_type = wms_xdock_utils_pvt.G_CRT_TYPE_PLAN;

    CURSOR c_get_plan_crt_id
    ( p_crt_name  IN  VARCHAR2
    ) IS
       SELECT wccv.criterion_id
         FROM wms_crossdock_criteria_vl  wccv
        WHERE wccv.criterion_name = p_crt_name
          AND wccv.criterion_type = wms_xdock_utils_pvt.G_CRT_TYPE_PLAN;

  BEGIN
    l_api_name      := 'chk_planxd_crt_id_name';
    l_debug         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    x_return_status := fnd_api.g_ret_sts_success;

    print_version_info;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline               ||
         'p_criterion_id   => '      || to_char(p_criterion_id) ||
         'p_criterion_name => '      || p_criterion_name
       , l_api_name
       );
    END IF;

    IF p_criterion_id IS NOT NULL
    THEN
       OPEN c_get_plan_crt_name (p_criterion_id);
       FETCH c_get_plan_crt_name INTO l_crt_name;
       IF c_get_plan_crt_name%NOTFOUND
       THEN
          IF l_debug = 1 THEN
             print_debug('Criterion ID not found', l_api_name);
          END IF;
          fnd_message.set_name('WMS', 'WMS_XDCRT_INVLD_PLAN_CRT');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
       END IF;
       CLOSE c_get_plan_crt_name;
       p_criterion_name := l_crt_name;
    ELSIF p_criterion_name IS NOT NULL
    THEN
       OPEN c_get_plan_crt_id (p_criterion_name);
       FETCH c_get_plan_crt_id INTO l_crt_id;
       IF c_get_plan_crt_id%NOTFOUND
       THEN
          IF l_debug = 1 THEN
             print_debug('Criterion name not found', l_api_name);
          END IF;
          fnd_message.set_name('WMS', 'WMS_XDCRT_INVLD_PLAN_CRT');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
       END IF;
       CLOSE c_get_plan_crt_id;
       p_criterion_id := l_crt_id;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      IF c_get_plan_crt_name%ISOPEN THEN
         CLOSE c_get_plan_crt_name;
      END IF;

      IF c_get_plan_crt_id%ISOPEN THEN
         CLOSE c_get_plan_crt_id;
      END IF;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF c_get_plan_crt_name%ISOPEN THEN
         CLOSE c_get_plan_crt_name;
      END IF;

      IF c_get_plan_crt_id%ISOPEN THEN
         CLOSE c_get_plan_crt_id;
      END IF;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END chk_planxd_crt_id_name;



  PROCEDURE chk_mo_type
  ( x_return_status   OUT NOCOPY   VARCHAR2
  , x_mo_header_id    OUT NOCOPY   NUMBER
  , x_mo_type         OUT NOCOPY   NUMBER
  , x_is_putaway_mo   OUT NOCOPY   VARCHAR2
  , p_mo_line_id      IN           NUMBER
  ) IS

    l_api_name       VARCHAR2(30);
    l_debug          NUMBER;
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);

    l_mo_header_id   NUMBER;
    l_mo_type        NUMBER;

    CURSOR c_get_mo_header_info
    ( p_line_id  IN  NUMBER
    ) IS
       SELECT mtrh.header_id
            , mtrh.move_order_type
         FROM mtl_txn_request_lines    mtrl
            , mtl_txn_request_headers  mtrh
        WHERE mtrl.line_id   = p_line_id
          AND mtrh.header_id = mtrl.header_id;

  BEGIN
    l_api_name      := 'chk_mo_type';
    l_debug         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    x_return_status := fnd_api.g_ret_sts_success;

    print_version_info;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: ' || g_newline ||
         'p_mo_line_id => '          || to_char(p_mo_line_id)
       , l_api_name
       );
    END IF;

    IF p_mo_line_id IS NULL
    THEN
       print_debug('MO line ID is null!', l_api_name);
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    OPEN c_get_mo_header_info(p_mo_line_id);
    FETCH c_get_mo_header_info INTO l_mo_header_id,l_mo_type;
    IF c_get_mo_header_info%NOTFOUND
    THEN
       IF l_debug = 1 THEN
          print_debug('MO line ID not found', l_api_name);
       END IF;
       fnd_message.set_name('WMS', 'WMS_MOL_NOT_FOUND');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_get_mo_header_info;

    x_mo_header_id := l_mo_header_id;
    x_mo_type      := l_mo_type;
    IF l_mo_type = INV_GLOBALS.g_move_order_put_away
    THEN
       x_is_putaway_mo := 'Y';
    ELSE
       x_is_putaway_mo := 'N';
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      IF c_get_mo_header_info%ISOPEN THEN
         CLOSE c_get_mo_header_info;
      END IF;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF c_get_mo_header_info%ISOPEN THEN
         CLOSE c_get_mo_header_info;
      END IF;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

  END chk_mo_type;

END wms_crossdock_grp;

/
